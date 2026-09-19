param(
    [string]$Source = "",
    [string]$Target = "",
    [switch]$NoVerify,
    [switch]$DryRun,
    [switch]$Check,
    [switch]$Verify,
    [switch]$SelfTest
)

<#
.SYNOPSIS
    Materialises the transportable architecture layer from the template repo into a satellite repo.

.DESCRIPTION
    The parcel/wiki architecture is engineered to be transportable between workspaces. The
    portable surface is declared in .devops/sync-manifest.yaml:

        portable_dirs:      directories copied recursively (overwrite) into the target
        excluded_skills:    skill slugs NOT portable (portable skills are derived:
                            every folder in .devops/skills minus this exclusion list)
        portable_files:     standalone files copied verbatim into the target
        prune_files:        files deleted from the target if present (retired upstream)
        prune_dirs:         directories deleted from the target if present, recursively
                            (retired skill folders; portable skills are derived, so a
                            removed folder is otherwise never compared and never deleted)
        machinery-version:  integer version of the dirs/files/agents/rules set; drives
                            UPGRADE vs DRIFT classification for non-skill items

    -Check compares source vs target per manifest item (SHA256 per file + version metadata)
    and prints a CURRENT/UPGRADE/DRIFT/MISSING/PRUNE/SOURCE-ABSENT verdict table without writing.
    A retired file still present in the target is a PRUNE verdict, and like every other
    non-CURRENT verdict it makes -Check exit 1. Prune files are excluded from their parent
    directory's comparison, so a lingering retired file surfaces as PRUNE rather than a
    misleading parent-dir DRIFT ("locally customized") when the live content matches upstream.
    A retired DIRECTORY (a `prune_dirs:` entry — a skill folder retired upstream) is reported
    by a direct existence test on the declared path, and sync deletes it recursively. That
    mask is not mirrored for directories: the folders this key retires sit under .devops/skills,
    which is compared per slug over the derived portable set and is not a portable_dirs root,
    so a mask branch could never fire for them.
    For the PREFIX-LOCKED agents (.devops/agents/parcel*.agent.md + ptp-*.subagent.md) only
    the agent-unique content is hashed: the prefix region is regenerated from each repo's
    own base-context.md after every sync, so it legitimately differs between source and
    target and must never mask a CURRENT verdict.

    After copying, the script stamps the TARGET's own .devops/sync-manifest.yaml with the
    source machinery-version (installing a copy of the manifest on first sync). Without
    this bookkeeping, -Check would report a phantom UPGRADE forever after every successful
    sync, because the manifest itself is not on the portable surface.

    It also reconciles the source capability-class registry into the target and STRIPS
    every concrete model binding from it (T1-E1.04 - the invariant is now absence). No agent
    declares a model; every agent inherits the model selected in the CLI / picker. The
    target's registry table is REWRITTEN to the two-cell shape, rows are INSERTED for keys
    the source added, and rows are DELETED for keys the source retired, so template-side
    registry growth and retirement both reach an already-bootstrapped satellite. Any
    `model:` line in a target agent file's frontmatter is REMOVED, and any
    agent.<key>.model member in the target's opencode.json is REMOVED (the strip is
    JSON-validated and reverted rather than left unparsable). An entry for a registry key
    the target has NEVER authored is still INSERTED whole from the target's own synced seed
    (.devops/templates/opencode.template.json) - so a newly shipped agent arrives runnable
    instead of arriving as a file the runtime never mounts. A missing key therefore
    self-heals on a normal pull. BINDING-SKIP means neither the target nor the seed could
    supply an entry - still a loud failure in the target's own check-parcel-prefix.ps1 run.
    This runs BEFORE prefix regeneration.

    -SelfTest runs an end-to-end smoke test against a throwaway temp target: materialises
    the full portable surface, asserts every manifest dir/skill/file landed with matching
    content hashes and the target manifest version was stamped, then cleans up. Exit 0 =
    engine healthy. Use after editing this script or the manifest (CI runs it on every push).

    -Verify runs the verification stack against an already-materialised target WITHOUT
    copying anything: structural checks of the satellite-authored surface (AGENTS.md
    machinery markers, opencode.json wiring, base-context.md, wiki anchor, machinery
    presence, .ptp-source) plus the machinery gates (prefix check-only, UTF-8, wiki lint).
    Exit 0 = VERIFIED. Run after authoring the repo-specific files (bootstrap step 4).

    The repo-specific surface is NOT copied: base-context.md, opencode.json, AGENTS.md and the
    wiki content itself embed the target's own layout, task lookup and permissions. base-context.md
    and opencode.json ARE edited in place, but only to reconcile the capability-class registry
    rows and to REMOVE model bindings (registry row shape, agent frontmatter `model:` lines and
    agent.<key>.model members) - never copied wholesale, never restructured. After the
    portable surface is copied, the script regenerates each agent's PREFIX-LOCKED prefix from
    the TARGET's own .opencode/plans/base-context.md so the cache anchor always matches the
    local workspace.

.NOTES
    Usage:
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/to/satellite
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/ -DryRun
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/to/satellite -Verify
        powershell -File scripts/sync-architecture.ps1 -SelfTest

    Structure: this file is the entry point and the CLI. The engine itself is dot-sourced
    from scripts/lib/ (manifest, bindings, prune, prefix, verify); every module is declared
    in .devops/sync-manifest.yaml portable_files. See scripts/lib/README.md.
#>

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot
$src = if ($Source) { $Source } else { $here }

if (-not (Test-Path $src)) { throw "Source repo not found: $src" }

$srcRoot = (Resolve-Path $src).Path

# Cross-platform: re-invocations must use the current PowerShell host executable.
# 'powershell' does not exist on Linux CI runners; 'pwsh' does. (Get-Process).Path
# gives the running host, so the same script works on both.
$shellExe = (Get-Process -Id $PID).Path

# --- engine modules: dot-sourced by explicit path, in dependency order ---------
# A partial split ships a satellite a broken engine, so every module is declared in
# .devops/sync-manifest.yaml portable_files and -SelfTest asserts the mirror.
$libRoot = Join-Path $PSScriptRoot 'lib'
. (Join-Path $libRoot 'sync-manifest.ps1')
. (Join-Path $libRoot 'sync-bindings.ps1')
. (Join-Path $libRoot 'sync-prune.ps1')
. (Join-Path $libRoot 'sync-prefix.ps1')
. (Join-Path $libRoot 'sync-verify.ps1')


# --- self-test mode: build a throwaway satellite, sync into it, verify, tear down ---
if ($SelfTest) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-selftest-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        Write-Output "SELFTEST: temp target = $tmp"
        # Accumulate fixture findings from the very start so the F8/F9 assertions below
        # survive into the final $fail check (the later `$fail = @()` is intentionally gone).
        $fail = @()
        # --- F8/F9 fixture: a satellite-shaped target BEFORE the first sync -----------------
        # F8: simulate a satellite bootstrapped before a registry key existed - plant the seed
        #     config minus one registry key, sync, then assert the sync inserts it whole.
        # F9: the plan template is named by the shared prefix, so the target must receive it.
        $stSrcRegistry = Get-RegistryBindings (Join-Path $srcRoot '.opencode/plans/base-context.md')
        $stPick = $null; $stKeep = $null; $stKeepBefore = $null
        if ($stSrcRegistry.Count -gt 0) {
            $stPick = ($stSrcRegistry.Keys | Sort-Object)[-1]
            $stKeep = ($stSrcRegistry.Keys | Sort-Object)[0]
            $stSeedOc = Get-Content -Raw (Join-Path $srcRoot '.devops/templates/opencode.template.json') | ConvertFrom-Json
            $stSeedOc.PSObject.Properties.Remove('_comment') | Out-Null
            $stSeedOc.agent.PSObject.Properties.Remove($stPick) | Out-Null
            $stPlantedRaw = ($stSeedOc | ConvertTo-Json -Depth 10)
            [System.IO.File]::WriteAllText((Join-Path $tmp 'opencode.json'), $stPlantedRaw, (New-Object System.Text.UTF8Encoding($false)))
            $k0 = [regex]::Match($stPlantedRaw, '"' + [regex]::Escape($stKeep) + '"\s*:\s*\{')
            if ($k0.Success) {
                $k0o = $stPlantedRaw.IndexOf('{', $k0.Index); $k0c = Find-MatchingBrace $stPlantedRaw $k0o
                if ($k0o -ge 0 -and $k0c -ge 0) { $stKeepBefore = $stPlantedRaw.Substring($k0o, $k0c - $k0o + 1) }
            }
            Write-Output "SELFTEST fixture: opencode.json planted missing '$stPick' (sibling '$stKeep' must not move)"
        } else {
            Write-Output "SELFTEST fixture: skipped (source Model Registry empty)"
        }
        & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify
        if ($LASTEXITCODE -ne 0) { throw "selftest: sync run failed (exit $LASTEXITCODE)" }
        # --- F8 assertions: inserted key present with NO model, sibling untouched, idempotent
        if ($stPick) {
            $stOcPath = Join-Path $tmp 'opencode.json'
            $stOcRaw = [System.IO.File]::ReadAllText($stOcPath)
            $stOcJson = $null
            try { $stOcJson = $stOcRaw | ConvertFrom-Json } catch { $stOcJson = $null }
            if (-not $stOcJson) {
                $fail += "selftest F8: target opencode.json invalid after sync"
            } else {
                $stProp = $stOcJson.agent.PSObject.Properties[$stPick]
                if (-not $stProp) {
                    $fail += "selftest F8: '$stPick' was not inserted into the target opencode.json"
                } else {
                    # T1-E1.04: the invariant is ABSENCE - an inserted entry must carry no model.
                    if ([string]$stProp.Value.model) { $fail += "selftest F8: inserted '$stPick' declares model '$($stProp.Value.model)' - no agent may declare a model" }
                }
                $k1 = [regex]::Match($stOcRaw, '"' + [regex]::Escape($stKeep) + '"\s*:\s*\{')
                if (-not $k1.Success) {
                    $fail += "selftest F8: sibling '$stKeep' vanished from the target opencode.json"
                } else {
                    $k1o = $stOcRaw.IndexOf('{', $k1.Index); $k1c = Find-MatchingBrace $stOcRaw $k1o
                    $stKeepAfter = if ($k1o -ge 0 -and $k1c -ge 0) { $stOcRaw.Substring($k1o, $k1c - $k1o + 1) } else { $null }
                    if ($stKeepBefore -ne $stKeepAfter) { $fail += "selftest F8: existing entry '$stKeep' was restructured by sync" }
                }
                $stHash1 = (Get-FileHash $stOcPath -Algorithm SHA256).Hash
                & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify | Out-Null
                if ($LASTEXITCODE -ne 0) { throw "selftest F8: idempotence re-sync failed (exit $LASTEXITCODE)" }
                $stHash2 = (Get-FileHash $stOcPath -Algorithm SHA256).Hash
                if ($stHash1 -ne $stHash2) { $fail += "selftest F8: second sync changed opencode.json (insert is not idempotent)" }
            }
        }
        # --- F9 assertion: the plan template the shared prefix names must reach the target ---
        $stTmplMatch = [regex]::Match(([System.IO.File]::ReadAllText((Join-Path $srcRoot '.opencode/plans/base-context.md'))), 'Plan template:\s*`([^`]+)`')
        if (-not $stTmplMatch.Success) {
            $fail += "selftest F9: no 'Plan template: <path>' reference found in the source prefix"
        } elseif (-not (Test-Path (Join-Path $tmp $stTmplMatch.Groups[1].Value.Trim()))) {
            $fail += "selftest F9: referenced plan template '$($stTmplMatch.Groups[1].Value.Trim())' missing from the target"
        }
        # Manifest must parse identically inside the test process — reuse Read-Manifest.
        $stManifestPath = Join-Path $srcRoot '.devops/sync-manifest.yaml'
        $stMan = Read-Manifest $stManifestPath
        $stDirs = @($stMan.Lists['portable_dirs'])
        $stFiles = @($stMan.Lists['portable_files'])
        $stPrune = @($stMan.Lists['prune_files'])
        $stPruneDirs = @($stMan.Lists['prune_dirs'])
        $stExcluded = @($stMan.Lists['excluded_skills'])
        $skillsRoot = Join-Path $srcRoot '.devops/skills'
        $stSkills = @(Get-ChildItem $skillsRoot -Directory | ForEach-Object { $_.Name } | Where-Object { $stExcluded -notcontains $_ })
        # $fail was initialised before the F8/F9 fixture above - do not reset it here.
        function Assert-Mirror {
            param([string]$Rel)
            $sp = Join-Path $srcRoot $Rel
            $tp = Join-Path $tmp $Rel
            if (-not (Test-Path $tp)) { $script:fail += "missing in target: $Rel"; return }
            # -Force keeps the source/target file-set comparison honest for hidden
            # (dot-prefixed) entries on Unix; both sides are filtered identically.
            $sh = Get-ChildItem -Force $sp -Recurse -File | ForEach-Object { $_.FullName.Substring($sp.Length) } | Sort-Object
            $th = Get-ChildItem -Force $tp -Recurse -File | ForEach-Object { $_.FullName.Substring($tp.Length) } | Sort-Object
            if (($sh -join '|') -ne ($th -join '|')) { $script:fail += "file set differs: $Rel" }
        }
        foreach ($d in $stDirs) { Assert-Mirror $d }
        foreach ($s in $stSkills) { Assert-Mirror ".devops\skills\$s" }
        foreach ($f in $stFiles) { Assert-Mirror $f }
        # Guard the historical Copy-Item nesting defect: no doubled directory names.
        $nested = Get-ChildItem -Force $tmp -Recurse -Directory | Where-Object { $_.FullName.Replace('\','/') -match '/(\.wiki|\.devops)/\1|/skills/([^/]+)/\2' }
        if ($nested) { $fail += "nested-copy defect: $($nested.FullName -join ', ')" }
        # Manifest stamping: the target's machinery-version must now match the source's,
        # otherwise -Check reports a phantom UPGRADE after every successful sync.
        $stSrcV = $null; $stTgtV = $null
        foreach ($line in Get-Content $stManifestPath) { if ($line -match '^machinery-version:\s*(\d+)') { $stSrcV = $Matches[1]; break } }
        $stTgtManifest = Join-Path $tmp '.devops/sync-manifest.yaml'
        if (Test-Path $stTgtManifest) {
            foreach ($line in Get-Content $stTgtManifest) { if ($line -match '^machinery-version:\s*(\d+)') { $stTgtV = $Matches[1]; break } }
        }
        if ($stTgtV -ne $stSrcV) { $fail += "manifest stamp failed: target machinery-version '$stTgtV' vs source '$stSrcV'" }
        # Model ABSENCE propagation (T1-E1.04): no target agent file may carry a `model:` line
        # after a sync, and no target opencode.json agent entry may declare a model. Guards the
        # strip contract (the old force-stamp direction is retired).
        $stSrcRegistry = Get-RegistryBindings (Join-Path $srcRoot '.opencode/plans/base-context.md')
        if ($stSrcRegistry.Count -eq 0) { $fail += "selftest: source Model Registry parsed as empty" }
        foreach ($bk in ($stSrcRegistry.Keys | Sort-Object)) {
            $bTgt = Join-Path $tmp ".devops/agents/$bk.agent.md"
            if (-not (Test-Path $bTgt)) { $bTgt = Join-Path $tmp ".devops/agents/$bk.subagent.md" }
            if (-not (Test-Path $bTgt)) { $fail += "binding file missing in target: $bk"; continue }
            $bm = [regex]::Match(([System.IO.File]::ReadAllText($bTgt) -replace "`r`n", "`n"), '(?m)^model:\s*(.+?)\s*$')
            if ($bm.Success) { $fail += "model binding survived the sync for $bk (target frontmatter still declares '$($bm.Groups[1].Value)')" }
        }
        $stTgtOc = Join-Path $tmp 'opencode.json'
        if (Test-Path $stTgtOc) {
            $stTgtOcJson = $null
            try { $stTgtOcJson = ([System.IO.File]::ReadAllText($stTgtOc)) | ConvertFrom-Json } catch { $stTgtOcJson = $null }
            if (-not $stTgtOcJson) {
                $fail += "selftest: target opencode.json invalid after sync"
            } else {
                foreach ($p in @($stTgtOcJson.agent.PSObject.Properties)) {
                    if ([string]$p.Value.model) { $fail += "model binding survived the sync for opencode agent '$($p.Name)' ('$($p.Value.model)')" }
                }
            }
        }
        # Prune test: plant a retired file, assert -Check reports PRUNE (not a parent-dir
        # DRIFT) and exits out-of-sync; re-sync, assert it is removed and Check is clean.
        # The planted file lives inside a portable dir, so this guards both the PRUNE
        # tally and the parent-dir masking fix.
        if ($stPrune.Count -gt 0) {
            $stale = Join-Path $tmp $stPrune[0]
            New-Item -ItemType Directory -Force -Path (Split-Path $stale) | Out-Null
            Set-Content -Path $stale -Value "stale" -NoNewline
            $stOut = @(& $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -Check)
            if ($LASTEXITCODE -eq 0) { $fail += "-Check reported IN SYNC with a prune file present (exit 0)" }
            if (-not ($stOut -match 'PRUNE')) { $fail += "-Check did not report a PRUNE verdict for $($stPrune[0])" }
            if ($stOut -match 'DRIFT') { $fail += "-Check reported DRIFT (not PRUNE) for a retired file inside a portable dir" }
            & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify
            if ($LASTEXITCODE -ne 0) { throw "selftest: prune re-sync failed (exit $LASTEXITCODE)" }
            if (Test-Path $stale) { $fail += "prune failed: $($stPrune[0]) still present after re-sync" }
        }
        # Prune-DIRECTORY test: a retired skill folder is invisible to the derived portable
        # skill set, so it can only be removed by the explicit prune_dirs existence test.
        # Plant a NON-EMPTY directory (a flat delete would fail on it) and assert the same
        # three-phase contract: -Check reports PRUNE and exits non-zero, re-sync deletes it
        # recursively, -Check is then clean.
        if ($stPruneDirs.Count -gt 0) {
            $staleDir = Join-Path $tmp $stPruneDirs[0]
            New-Item -ItemType Directory -Force -Path $staleDir | Out-Null
            Set-Content -Path (Join-Path $staleDir 'SKILL.md') -Value "stale" -NoNewline
            $stOutDir = @(& $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -Check)
            if ($LASTEXITCODE -eq 0) { $fail += "-Check reported IN SYNC with a prune directory present (exit 0)" }
            if (-not ($stOutDir -match 'PRUNE')) { $fail += "-Check did not report a PRUNE verdict for $($stPruneDirs[0])" }
            & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify
            if ($LASTEXITCODE -ne 0) { throw "selftest: prune-dir re-sync failed (exit $LASTEXITCODE)" }
            if (Test-Path $staleDir) { $fail += "prune_dirs failed: $($stPruneDirs[0]) still present after re-sync" }
        }
        # --- T1-E2.07 fixture: retirement transport (registry prune + skill prune mask + structural task stamp)
        # Plant the three pre-retirement states GRID-Link carried at the 54 -> 59 pull,
        # then assert one sync converges all three: the orphan registry row is pruned
        # (F1), the stale skill-internal file reports PRUNE and never a skill DRIFT (F2),
        # and the old parcel-sprint task allow-list is stamped from the seed (F3).
        $rtBcDir = Join-Path $tmp '.opencode/plans'
        New-Item -ItemType Directory -Force -Path $rtBcDir | Out-Null
        Copy-Item (Join-Path $srcRoot '.opencode/plans/base-context.md') (Join-Path $tmp '.opencode/plans/base-context.md') -Force
        $rtBc = Join-Path $tmp '.opencode/plans/base-context.md'
        $rtBcRaw = [System.IO.File]::ReadAllText($rtBc)
        if ($rtBcRaw -match '\| parcel-fast \|') {
            $fail += "selftest T1-E2.07: target already carries a parcel-fast row; fixture not isolated"
        } else {
            $rtBcEol = if ($rtBcRaw -match "`r`n") { "`r`n" } else { "`n" }
            $rtBcRaw = $rtBcRaw.TrimEnd("`r", "`n") + $rtBcEol + "| parcel-fast | orchestration |" + $rtBcEol
            [System.IO.File]::WriteAllText($rtBc, $rtBcRaw, (New-Object System.Text.UTF8Encoding($false)))
            Write-Output "SELFTEST fixture: orphan registry row 'parcel-fast' planted"
        }
        $rtStaleSkill = Join-Path $tmp '.devops/skills/wiki-bootstrap/references/qa-14-testing-standards.md'
        New-Item -ItemType Directory -Force -Path (Split-Path $rtStaleSkill) | Out-Null
        Set-Content -Path $rtStaleSkill -Value "stale" -NoNewline
        Write-Output "SELFTEST fixture: stale skill-internal file planted"
        $rtOcPath = Join-Path $tmp 'opencode.json'
        $rtOcRaw = [System.IO.File]::ReadAllText($rtOcPath)
        $rtPsM = [regex]::Match($rtOcRaw, '"parcel-sprint"\s*:\s*\{')
        if (-not $rtPsM.Success) {
            $fail += "selftest T1-E2.07: parcel-sprint entry missing from target opencode.json"
        } else {
            $rtPsOpen = $rtOcRaw.IndexOf('{', $rtPsM.Index); $rtPsClose = Find-MatchingBrace $rtOcRaw $rtPsOpen
            $rtPsBlock = $rtOcRaw.Substring($rtPsOpen, $rtPsClose - $rtPsOpen + 1)
            if ($rtPsBlock -notmatch '"wiki-writer":\s*"allow"') {
                $fail += "selftest T1-E2.07: target parcel-sprint already lacks wiki-writer; fixture not isolated"
            } else {
                $rtPsNew = $rtPsBlock -replace ',\s*"wiki-writer":\s*"allow"', ''
                $rtOcRaw = $rtOcRaw.Remove($rtPsOpen, $rtPsClose - $rtPsOpen + 1).Insert($rtPsOpen, $rtPsNew)
                [System.IO.File]::WriteAllText($rtOcPath, $rtOcRaw, (New-Object System.Text.UTF8Encoding($false)))
                Write-Output "SELFTEST fixture: parcel-sprint task allow-list aged (wiki-writer removed)"
            }
        }
        $stOutRt = @(& $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -Check)
        if ($LASTEXITCODE -eq 0) { $fail += "selftest T1-E2.07: -Check reported IN SYNC with retirement states planted (exit 0)" }
        if (-not ($stOutRt -match 'PRUNE')) { $fail += "selftest T1-E2.07: -Check did not report PRUNE for the stale skill-internal file" }
        if ($stOutRt -match 'DRIFT') { $fail += "selftest T1-E2.07: -Check reported DRIFT instead of PRUNE for a retired skill-internal file" }
        if (-not ($stOutRt -match 'skill\s+wiki-bootstrap\s+CURRENT')) { $fail += "selftest T1-E2.07: wiki-bootstrap skill did not report CURRENT beside its PRUNE" }
        & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "selftest T1-E2.07: convergence re-sync failed (exit $LASTEXITCODE)" }
        if ([System.IO.File]::ReadAllText($rtBc) -match '\| parcel-fast \|') { $fail += "selftest T1-E2.07: orphan registry row survived the sync (F1 delete pass failed)" }
        if (Test-Path $rtStaleSkill) { $fail += "selftest T1-E2.07: stale skill-internal file survived the sync (F2 prune failed)" }
        $rtOcAfter = [System.IO.File]::ReadAllText($rtOcPath)
        $rtPsM2 = [regex]::Match($rtOcAfter, '"parcel-sprint"\s*:\s*\{')
        $rtPs2Open = $rtOcAfter.IndexOf('{', $rtPsM2.Index); $rtPs2Close = Find-MatchingBrace $rtOcAfter $rtPs2Open
        if ($rtOcAfter.Substring($rtPs2Open, $rtPs2Close - $rtPs2Open + 1) -notmatch '"wiki-writer":\s*"allow"') {
            $fail += "selftest T1-E2.07: parcel-sprint task allow-list was not stamped from the seed (F3 stamp failed)"
        }
        try { $null = $rtOcAfter | ConvertFrom-Json } catch { $fail += "selftest T1-E2.07: target opencode.json invalid after structural stamp" }
        $rtHash1 = @((Get-FileHash $rtBc -Algorithm SHA256).Hash, (Get-FileHash $rtOcPath -Algorithm SHA256).Hash)
        & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "selftest T1-E2.07: idempotence re-sync failed (exit $LASTEXITCODE)" }
        $rtHash2 = @((Get-FileHash $rtBc -Algorithm SHA256).Hash, (Get-FileHash $rtOcPath -Algorithm SHA256).Hash)
        if (($rtHash1 -join '|') -ne ($rtHash2 -join '|')) { $fail += "selftest T1-E2.07: second sync moved base-context.md or opencode.json (retirement transport not idempotent)" }
        # End-to-end -Check gate: immediately after a successful sync the target must
        # report IN SYNC (manifest stamped, prefix-locked agents excluded from the hash).
        # This guards both post-sync bookkeeping bugs: the phantom UPGRADE from an
        # unstamped manifest and the eternal agents DRIFT from the regenerated prefix.
        & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -Check | Out-Null
        if ($LASTEXITCODE -ne 0) { $fail += "-Check reported OUT OF SYNC immediately after a successful sync" }
        # Claims checker smoke: the ported script must execute in a satellite against
        # the synced .wiki/rules corpus and report clean (imports wiki_lint, same dir).
        if (Test-Path (Join-Path $tmp 'scripts/wiki_claims.py')) {
            & python (Join-Path $tmp 'scripts/wiki_claims.py') check --quiet | Out-Null
            if ($LASTEXITCODE -ne 0) { $fail += "wiki_claims.py check failed in target (exit $LASTEXITCODE)" }
        } else {
            $fail += "wiki_claims.py missing from target scripts/"
        }
        if ($fail.Count -gt 0) {
            Write-Output "SELFTEST FAILED:"
            $fail | ForEach-Object { Write-Output "  $_" }
            exit 1
        }
        Write-Output "SELFTEST OK: $($stDirs.Count) dirs, $($stSkills.Count) skills, $($stFiles.Count) files materialised correctly."
        exit 0
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

if (-not $Target) { throw "-Target is required (or use -SelfTest)." }
if (-not (Test-Path $Target)) { throw "Target repo not found: $Target" }
$tgtRoot = (Resolve-Path $Target).Path
if ($srcRoot -eq $tgtRoot) { throw "Source and target are the same repo." }

$manifestPath = Join-Path $srcRoot '.devops/sync-manifest.yaml'
if (-not (Test-Path $manifestPath)) { throw "Manifest not found: $manifestPath" }

Write-Output "Syncing architecture layer:"
Write-Output "  source : $srcRoot"
Write-Output "  target : $tgtRoot"
Write-Output "  manifest: $manifestPath"
Write-Output ""

# --- helpers ---------------------------------------------------------------

# --- verification helpers ---------------------------------------------------

# --- parse the manifest (single shared parser — see Read-Manifest) ---
$man = Read-Manifest $manifestPath
$manifest = $man.Lists
$scalars = $man.Scalars

# Derive the portable skill surface: all skills minus excluded_skills.
$skillsRoot = Join-Path $srcRoot '.devops/skills'
$allSkills = @(Get-ChildItem $skillsRoot -Directory | ForEach-Object { $_.Name })
$excluded = @($manifest['excluded_skills'])
$portableSkills = @($allSkills | Where-Object { $excluded -notcontains $_ })

# --- verify-only mode: structural checks + machinery gates, no copying ---
if ($Verify) {
    Write-Output "Verifying architecture layer (no writes):"
    Write-Output "  source : $srcRoot"
    Write-Output "  target : $tgtRoot"
    Write-Output ""
    Write-Output "=== Structural verification (satellite-authored surface vs template seeds) ==="
    $structure = Invoke-StructuralVerify -SrcRoot $srcRoot -TgtRoot $tgtRoot
    Write-Output ""
    Write-Output "=== Machinery gates ==="
    $gatesOk = Invoke-VerificationGates -TgtRoot $tgtRoot
    Write-Output ""
    if (-not $gatesOk -or $structure.Fail -gt 0) {
        $suffix = if ($structure.Warn -gt 0) { ", $($structure.Warn) warning(s)" } else { '' }
        Write-Output "VERIFY FAILED: $($structure.Fail) structural failure(s)$suffix"
        exit 1
    }
    $suffix = if ($structure.Warn -gt 0) { " ($($structure.Warn) warning(s))" } else { '' }
    Write-Output "VERIFIED$suffix"
    exit 0
}

if ($Check) {
    # --- drift report: never writes, never regenerates prefixes ---
    Write-Output "Checking architecture layer:"
    Write-Output "  source : $srcRoot"
    Write-Output "  target : $tgtRoot"
    Write-Output ""

    # Header item: machinery-version itself.
    $srcMachV = $scalars['machinery-version']
    $tgtMachV = Get-ManifestMachineVersion $tgtRoot
    if ($null -eq $tgtMachV) {
        Add-Verdict 'meta' 'machinery-version' 'MISSING' "target manifest absent or has no machinery-version (source: $srcMachV)"
    } elseif ([string]$tgtMachV -ne [string]$srcMachV) {
        Add-Verdict 'meta' 'machinery-version' 'UPGRADE' "target $tgtMachV -> source $srcMachV"
    } else {
        Add-Verdict 'meta' 'machinery-version' 'CURRENT' "$srcMachV"
    }

    $prunePaths = @($manifest['prune_files'] | ForEach-Object { $_.Replace('\','/') })
    foreach ($dir in $manifest['portable_dirs']) {
        $dirPrefix = $dir.TrimEnd('/') + '/'
        $ignore = @($prunePaths | Where-Object { $_.StartsWith($dirPrefix) } | ForEach-Object { $_.Substring($dirPrefix.Length) })
        Compare-Item 'dir' $dir (Join-Path $srcRoot $dir) (Join-Path $tgtRoot $dir) $ignore
    }
    foreach ($slug in $portableSkills) {
        $skillPrefix = ".devops/skills/$slug/"
        $skillIgnore = @($prunePaths | Where-Object { $_.StartsWith($skillPrefix) } | ForEach-Object { $_.Substring($skillPrefix.Length) })
        Compare-Item 'skill' $slug (Join-Path $srcRoot ".devops/skills/$slug") (Join-Path $tgtRoot ".devops/skills/$slug") $skillIgnore
    }
    foreach ($file in $manifest['portable_files']) { Compare-Item 'file' $file (Join-Path $srcRoot $file) (Join-Path $tgtRoot $file) }
    Test-PrunePresent -TgtRoot $tgtRoot -Manifest $manifest

    Write-Output ("{0,-6} {1,-42} {2,-14} {3}" -f 'KIND', 'ITEM', 'VERDICT', 'DETAIL')
    foreach ($v in $script:verdicts) { Write-Output ("{0,-6} {1,-42} {2,-14} {3}" -f $v.Kind, $v.Item, $v.Verdict, $v.Detail) }

    $counts = @{}
    foreach ($v in $script:verdicts) { $counts[$v.Verdict] = 1 + [int]$counts[$v.Verdict] }
    $bad = 0
    foreach ($b in @('UPGRADE', 'DRIFT', 'MISSING', 'SOURCE-ABSENT', 'PRUNE')) { $bad += [int]$counts[$b] }
    Write-Output ""
    Write-Output ("Summary: " + (($counts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ' '))
    if ($bad -eq 0) {
        Write-Output "IN SYNC"
        exit 0
    } else {
        Write-Output "OUT OF SYNC"
        exit 1
    }
}

$copied = 0
$skipped = @()

# 1. Portable directories.
foreach ($dir in $manifest['portable_dirs']) {
    $s = Join-Path $srcRoot $dir
    if (-not (Test-Path $s)) { $skipped += "missing in source: $dir"; continue }
    $t = Join-Path $tgtRoot $dir
    if ($DryRun) {
        $n = (Get-ChildItem $s -Recurse -File).Count
        Write-Output "DRYRUN would copy $dir ($n files)"
    } else {
        New-Item -ItemType Directory -Force -Path $t | Out-Null
        Copy-Item (Join-Path $s '*') $t -Recurse -Force
        Write-Output "COPIED $dir"
    }
    $copied++
}

# 2. Portable skills (derived: all skills minus excluded_skills; copy each folder).
foreach ($slug in $portableSkills) {
    $s = Join-Path $srcRoot ".devops/skills/$slug"
    if (-not (Test-Path $s)) { $skipped += "missing in source: skills/$slug"; continue }
    $t = Join-Path $tgtRoot ".devops/skills/$slug"
    if ($DryRun) {
        $n = (Get-ChildItem $s -Recurse -File).Count
        Write-Output "DRYRUN would copy skill $slug ($n files)"
    } else {
        New-Item -ItemType Directory -Force -Path $t | Out-Null
        Copy-Item (Join-Path $s '*') $t -Recurse -Force
        Write-Output "COPIED skill $slug"
    }
    $copied++
}

# 3. Portable files.
foreach ($file in $manifest['portable_files']) {
    $s = Join-Path $srcRoot $file
    if (-not (Test-Path $s)) { $skipped += "missing in source: $file"; continue }
    $t = Join-Path $tgtRoot $file
    if ($DryRun) {
        Write-Output "DRYRUN would copy $file"
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path $t) | Out-Null
        Copy-Item $s $t -Force
        Write-Output "COPIED $file"
    }
    $copied++
}

# 3b. Prune redundant files and directories from the target (retired upstream).
$prunePlan = @(Get-PrunePlan -TgtRoot $tgtRoot -Manifest $manifest)
Invoke-PrunePlan -TgtRoot $tgtRoot -Plan $prunePlan -DryRun:$DryRun

# 3c. Stamp the target's manifest with the source machinery-version (post-sync bookkeeping).
Update-TargetManifestVersion -TgtRoot $tgtRoot -SrcRoot $srcRoot -Version $scalars['machinery-version'] -DryRun:$DryRun

# 3d. Reconcile the source capability-class registry into the target and STRIP every concrete
# model binding from it (registry rows + agent frontmatter + opencode.json). Must run BEFORE the
# PREFIX-LOCKED regeneration below, so the regenerated orchestrator prefixes inline the
# reconciled table rather than a stale one.
Update-TargetModelBindings -SrcRoot $srcRoot -TgtRoot $tgtRoot -DryRun:$DryRun

if ($skipped.Count -gt 0) {
    Write-Output ""
    Write-Output "Skipped:"
    $skipped | ForEach-Object { Write-Output "  $_" }
}

if ($DryRun) {
    Write-Output ""
    Write-Output "DRYRUN complete - $copied items. Re-run without -DryRun to write."
    return
}

if ($NoVerify) {
    Write-Output ""
    Write-Output "Sync complete. Verification skipped (-NoVerify)."
    return
}

# 4. Regenerate PREFIX-LOCKED prefixes from the TARGET's own base-context, then verify.
Write-Output ""
Write-Output "=== Post-sync verification ==="
$gatesOk = Invoke-VerificationGates -TgtRoot $tgtRoot -RegenPrefix
$structure = Invoke-StructuralVerify -SrcRoot $srcRoot -TgtRoot $tgtRoot
if (-not $gatesOk) { exit 1 }
if ($structure.Fail -gt 0) {
    # Informational on a first-time bootstrap (authored files are expected to be missing
    # until step 2 of SATELLITE-BOOTSTRAP); -Verify is the strict gate after authoring.
    Write-Output ""
    Write-Output "STRUCTURE: $($structure.Fail) item(s) need authoring/fixing (see [FAIL] rows above)."
    Write-Output "After authoring, run: powershell -NoProfile -File scripts/pull-architecture.ps1 -Verify"
}

Write-Output ""
if ($scalars['machinery-version']) { Write-Output "machinery-version: $($scalars['machinery-version']) materialised" }
Write-Output "Sync complete. $copied items materialised into $tgtRoot"