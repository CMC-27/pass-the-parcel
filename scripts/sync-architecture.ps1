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
                            every folder in .devops/skills minus this exclusion list, then
                            intersected with core_skills when the target is profile: CORE)
        portable_files:     standalone files copied verbatim into the target
        prune_files:        files deleted from the target if present (retired upstream)
        prune_dirs:         directories deleted from the target if present, recursively
                            (retired skill folders; portable skills are derived, so a
                            removed folder is otherwise never compared and never deleted)
        machinery-version:  the transport set version (major.minor.patch, dotted-tolerant);
                            the comparison is ORDERING-AWARE - behind -> UPGRADE, ahead ->
                            AHEAD and a lineage shape crossing -> MIGRATION (both halt-and-
                            reconcile). Drives UPGRADE vs DRIFT classification for non-skill items
        profile:            the skill tier THIS repo carries - FULL (default: every skill) or
                            CORE (the pipeline set). A satellite declares CORE in its own copy
                            of the manifest; the sync reads it from the TARGET, falling back to
                            the source's value, so a satellite that has never set the key is
                            unchanged. An unrecognised value HALTS before anything is written.
        core_skills:        the CORE membership - template-published DATA read from the SOURCE,
                            never from the target (measured from the plan record; the manifest
                            header cites the evidence). A skill the measurement cannot see is
                            CORE-excluded by default, and the opt-in is profile: FULL.

    PROFILE-AWARE COMPARISON: the effective skill set is derived in exactly one place
    (Get-SkillTier, scripts/lib/sync-manifest.ps1) - the source's skills minus excluded_skills,
    intersected with core_skills when the target declares CORE. -Check and the copy path both
    consume that one set, so an un-installed tiered-out skill is never MISSING (it is simply
    not compared), while a tiered-out skill PRESENT in a CORE target reports PRUNE and is
    deleted by a sync - the existing prune mechanism, so a downgrade is reversible by
    declaring FULL again (purely additive). Directories and standalone files are not tiered.

    -Check compares source vs target per manifest item (SHA256 per file + version metadata)
    and prints a CURRENT/UPGRADE/AHEAD/MIGRATION/DRIFT/MISSING/PRUNE/SOURCE-ABSENT verdict
    table without writing. AHEAD and MIGRATION are halt-and-reconcile verdicts: an equality-only
    test cannot tell behind from ahead, which is how a target-ahead counter is silently rewound.
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
    sync, because the manifest itself is not on the portable surface. Before writing anything
    it pre-flights the counter ordering and HALTS when the target is ahead of, or
    shape-incompatible with, the source - a target-ahead counter is never silently rewound;
    the reconcile recipe is printed and the operator writes the value by hand.

    It also reconciles the source capability-class registry into the target and STRIPS
    every concrete model binding from it (T1-E1.04 - the invariant is now absence). No agent
    declares a model; every agent inherits the model selected in the CLI / picker. The
    target's registry table is REWRITTEN to the two-cell shape, rows are INSERTED for keys
    the source added, and rows are DELETED for keys the source retired, so template-side
    registry growth and retirement both reach an already-bootstrapped satellite. Any
    `model:` line in a target agent file's frontmatter is REMOVED, and any
    agent.<key>.model member in the target's opencode.json is REMOVED (the strip is
    JSON-validated and reverted rather than left unparsable). The same in-place edit also
    MIGRATES the target's `skills` key to the V2-native flat array (carrying the path entries
    the satellite declared, verbatim) and DELETES the config member V2 accepts but does not
    load - a member delete root-scoped by brace depth and run under the same step-local
    re-parse-and-revert guard. A `skills` shape the migration cannot rewrite without
    destroying a declaration the satellite authored (e.g. a `urls` member) is REFUSED, left
    exactly as authored, and reported with a printed operator remedy. An entry for a registry key
    the target has NEVER authored is still INSERTED whole from the target's own synced seed
    (.devops/templates/opencode.template.json) - so a newly shipped agent arrives runnable
    instead of arriving as a file the runtime never mounts. A missing key therefore
    self-heals on a normal pull. BINDING-SKIP means neither the target nor the seed could
    supply an entry - still a loud failure in the target's own check-parcel-prefix.ps1 run.
    This runs BEFORE prefix regeneration.

    -SelfTest runs an end-to-end smoke test against a throwaway temp target: materialises
    the full portable surface, asserts every manifest dir/skill/file landed with matching
    content hashes and the target manifest version was stamped, then cleans up. Every child
    invocation it JUDGES goes through one process-level capture helper, so a non-zero child exit
    is echoed as `SELFTEST child failed:` carrying the child command, its exit code, its stdout
    and its stderr - never converted into a bare assertion about behaviour the harness never
    observed. Exit 0 = engine healthy. Use after editing this script or the manifest (CI runs
    it on every push).

    -Verify runs the verification stack against an already-materialised target WITHOUT
    copying anything: structural checks of the satellite-authored surface (AGENTS.md
    machinery markers, opencode.json wiring, base-context.md, wiki anchor, machinery
    presence, .ptp-source) plus the machinery gates (prefix check-only, UTF-8, wiki lint).
    Exit 0 = VERIFIED. Run after authoring the repo-specific files (bootstrap step 4).

    The repo-specific surface is NOT copied: base-context.md, opencode.json, AGENTS.md and the
    wiki content itself embed the target's own layout, task lookup and permissions. base-context.md
    and opencode.json ARE edited in place, but only to reconcile the capability-class registry
    rows, to REMOVE model bindings (registry row shape, agent frontmatter `model:` lines and
    agent.<key>.model members), to MIGRATE the `skills` key to the V2-native flat array and to
    DELETE the config member V2 accepts but does not load. Every one of those edits is
    step-local: a candidate is accepted only when BOTH the host's parse and a host-monotone
    shape scan accept it - a comma left dangling before a closing brace or bracket, or braces
    or brackets that do not balance, is rejected identically on every host - and is DISCARDED
    otherwise. The verdict therefore no longer depends on which host's parser runs, and a
    candidate a strict consumer would refuse can no longer be shipped by a lenient one. A
    `skills`
    shape the migration cannot rewrite without destroying a declaration the satellite authored
    is refused and reported with a printed remedy - the file's other formatting is always left
    as authored, never copied wholesale and never re-serialised. After the
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

        function Invoke-CapturedChild {
            # Runs the engine as a child process and returns its exit code and BOTH streams,
            # captured at the PROCESS level - a native command's stderr is not reliably
            # catchable under $ErrorActionPreference = 'Stop' (process-lessons [2026-09-25]),
            # which is why a bare `2>&1 | Out-String` is a false-pass hazard. On a non-zero
            # exit the record also carries a `Diagnostic` block naming the child command, its
            # exit code, its stdout and its stderr; unless the caller declared the failure with
            # -AllowNonZero, that block is EMITTED and one $fail is appended - so no assertion
            # about target behaviour is ever derived from a child the harness did not hear
            # from (T1-E2.11, F3). Defined at the TOP of the body, not beside Assert-Mirror:
            # the F8/F9 fixture below launches a child before Assert-Mirror is defined.
            # ponytail: two temp files per judged invocation (~29 per run) - the file's own
            # corrected single-fixture pattern, generalised; upgrade path is one temp dir per
            # run, or named pipes.
            param([string[]]$Arguments, [switch]$AllowNonZero)
            $cccOut = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-child-" + [guid]::NewGuid().ToString('N').Substring(0, 8) + ".out")
            $cccErr = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-child-" + [guid]::NewGuid().ToString('N').Substring(0, 8) + ".err")
            $cccProc = Start-Process -FilePath $shellExe -ArgumentList $Arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput $cccOut -RedirectStandardError $cccErr
            $cccSo = [System.IO.File]::ReadAllText($cccOut)
            $cccSe = [System.IO.File]::ReadAllText($cccErr)
            Remove-Item $cccOut, $cccErr -Force -ErrorAction SilentlyContinue
            $cccCmd = ('& ' + $shellExe + ' ' + ($Arguments -join ' '))
            $cccRec = @{ Command = $cccCmd; ExitCode = $cccProc.ExitCode; Stdout = $cccSo; Stderr = $cccSe; Combined = ($cccSo + "`n" + $cccSe) }
            if ($cccProc.ExitCode -ne 0) {
                $cccRec.Diagnostic = ("SELFTEST child failed: {0}`n  exit code: {1}`n  stdout: {2}`n  stderr: {3}" -f $cccCmd, $cccProc.ExitCode, $cccSo, $cccSe)
                if (-not $AllowNonZero) {
                    Write-Host $cccRec.Diagnostic
                    $script:fail += "SELFTEST child failed: $cccCmd (exit $($cccProc.ExitCode)) - its stdout/stderr are captured above; no behaviour assertion was made"
                }
            }
            return $cccRec
        }

        # --- F3 self-check: no direct child launch may sit outside Invoke-CapturedChild ------
        # Written and RUN before the call-site migration: its failing run against the
        # un-migrated body is the recorded pre-fix observation (C-R2-2), not a prediction.
        # It reads this file's own text, locates the helper's definition span BY NAME with the
        # reused Find-MatchingBrace, and fails if either launch literal occurs outside that
        # span. It FAILS CLOSED: an unlocatable or unbalanced span is a failure, never a skip.
        # The span is also BOUNDED - exactly one `function ` declaration inside it - because
        # Find-MatchingBrace is a JSON-oriented matcher (double-quote/backslash aware only,
        # blind to PowerShell single-quoted strings and `#` comments): an inflated-but-valid
        # span would swallow the very launches this check exists to find and pass vacuously
        # (C-R3-1). The needles are assembled from fragments so this text cannot self-match.
        $scNeedleA = '& ' + '$shell' + 'Exe'
        $scNeedleB = 'Start-' + 'Process'
        $scText = [System.IO.File]::ReadAllText($PSCommandPath)
        $scHm = [regex]::Match($scText, 'function\s+Invoke-CapturedChild\b')
        $scHOpen = if ($scHm.Success) { $scText.IndexOf('{', $scHm.Index) } else { -1 }
        $scHClose = if ($scHOpen -ge 0) { Find-MatchingBrace $scText $scHOpen } else { -1 }
        if (-not $scHm.Success -or $scHOpen -lt 0 -or $scHClose -lt 0) {
            $fail += "selftest F3: Invoke-CapturedChild's definition span is not locatable in $PSCommandPath - the self-check failed closed"
        } else {
            $scSpan = $scText.Substring($scHm.Index, $scHClose - $scHm.Index + 1)
            $scOutside = $scText.Substring(0, $scHm.Index) + $scText.Substring($scHClose + 1)
            $scFnCount = ([regex]::Matches($scSpan, '\bfunction\s')).Count
            if ($scFnCount -ne 1) {
                $fail += "selftest F3: the located Invoke-CapturedChild span is not exact (it holds $scFnCount function declarations) - the self-check failed closed"
            } else {
                if ($scOutside.Contains($scNeedleA)) { $fail += "selftest F3: a direct child launch ('$scNeedleA') sits outside Invoke-CapturedChild" }
                if ($scOutside.Contains($scNeedleB)) { $fail += "selftest F3: a direct child launch ('$scNeedleB') sits outside Invoke-CapturedChild" }
            }
        }

        # --- F3 fixture: a failed child is reported as a child failure, never as an assertion -
        # Induces a deterministic child failure - the engine refuses a target that does not
        # exist - and asserts the diagnostic the helper builds: the literal
        # `SELFTEST child failed:` carrying the child command, its exit code, its stdout and
        # its stderr. The induction is deliberate, so -AllowNonZero suppresses the finding the
        # helper would otherwise raise; the asserted text is the same block the helper emits
        # on an UNexpected failure.
        $cdArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', (Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-absent-" + [guid]::NewGuid().ToString('N').Substring(0, 8))), '-Check')
        $cdRec = Invoke-CapturedChild -Arguments $cdArgs -AllowNonZero
        if ($cdRec.ExitCode -eq 0) {
            $fail += "selftest F3: a child pointed at a nonexistent target exited 0 - the induction is not a failure"
        } else {
            $cdDiag = [string]$cdRec.Diagnostic
            if ($cdDiag -notmatch 'SELFTEST child failed:') { $fail += "selftest F3: the failed child produced no 'SELFTEST child failed:' diagnostic" }
            if (-not $cdDiag.Contains($cdRec.Command)) { $fail += "selftest F3: the child diagnostic does not name the child command" }
            if ($cdDiag -notmatch [regex]::Escape("exit code: $($cdRec.ExitCode)")) { $fail += "selftest F3: the child diagnostic does not carry the child's exit code" }
            if ($cdDiag -notmatch 'stdout:') { $fail += "selftest F3: the child diagnostic carries no stdout field" }
            if ($cdDiag -notmatch 'stderr:') { $fail += "selftest F3: the child diagnostic carries no stderr field" }
            if ($cdRec.Stderr.Length -eq 0) { $fail += "selftest F3: the induced child failure wrote nothing to stderr - the capture is not wired" }
            if (-not $cdDiag.Contains($cdRec.Stderr)) { $fail += "selftest F3: the child diagnostic does not carry the child's stderr" }
        }
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
        $stSync1 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
        if ($stSync1.ExitCode -ne 0) { throw "selftest: sync run failed (exit $($stSync1.ExitCode))" }
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
                $stSync2 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
                if ($stSync2.ExitCode -ne 0) { throw "selftest F8: idempotence re-sync failed (exit $($stSync2.ExitCode))" }
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
        foreach ($s in $stSkills) { Assert-Mirror ".devops/skills/$s" }
        foreach ($f in $stFiles) { Assert-Mirror $f }
        # Guard the historical Copy-Item nesting defect: no doubled directory names.
        $nested = Get-ChildItem -Force $tmp -Recurse -Directory | Where-Object { $_.FullName.Replace('\','/') -match '/(\.wiki|\.devops)/\1|/skills/([^/]+)/\2' }
        if ($nested) { $fail += "nested-copy defect: $($nested.FullName -join ', ')" }
        # Manifest stamping: the target's machinery-version must now match the source's,
        # otherwise -Check reports a phantom UPGRADE after every successful sync.
        $stSrcV = $null; $stTgtV = $null
        foreach ($line in Get-Content $stManifestPath) { if ($line -match '^machinery-version:\s*(\d+(?:\.\d+)*)') { $stSrcV = $Matches[1]; break } }
        $stTgtManifest = Join-Path $tmp '.devops/sync-manifest.yaml'
        if (Test-Path $stTgtManifest) {
            foreach ($line in Get-Content $stTgtManifest) { if ($line -match '^machinery-version:\s*(\d+(?:\.\d+)*)') { $stTgtV = $Matches[1]; break } }
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
            $stOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stOut = $stOutRec.Combined
            if ($stOutRec.ExitCode -eq 0) { $fail += "-Check reported IN SYNC with a prune file present (exit 0)" }
            if (-not ($stOut -match 'PRUNE')) { $fail += "-Check did not report a PRUNE verdict for $($stPrune[0])" }
            if ($stOut -match 'DRIFT') { $fail += "-Check reported DRIFT (not PRUNE) for a retired file inside a portable dir" }
            $stPruneSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
            if ($stPruneSync.ExitCode -ne 0) { throw "selftest: prune re-sync failed (exit $($stPruneSync.ExitCode))" }
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
            $stOutDirRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stOutDir = $stOutDirRec.Combined
            if ($stOutDirRec.ExitCode -eq 0) { $fail += "-Check reported IN SYNC with a prune directory present (exit 0)" }
            if (-not ($stOutDir -match 'PRUNE')) { $fail += "-Check did not report a PRUNE verdict for $($stPruneDirs[0])" }
            $stPruneDirSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
            if ($stPruneDirSync.ExitCode -ne 0) { throw "selftest: prune-dir re-sync failed (exit $($stPruneDirSync.ExitCode))" }
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
        $stOutRtRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
        $stOutRt = $stOutRtRec.Combined
        if ($stOutRtRec.ExitCode -eq 0) { $fail += "selftest T1-E2.07: -Check reported IN SYNC with retirement states planted (exit 0)" }
        if (-not ($stOutRt -match 'PRUNE')) { $fail += "selftest T1-E2.07: -Check did not report PRUNE for the stale skill-internal file" }
        if ($stOutRt -match 'DRIFT') { $fail += "selftest T1-E2.07: -Check reported DRIFT instead of PRUNE for a retired skill-internal file" }
        if (-not ($stOutRt -match 'skill\s+wiki-bootstrap\s+CURRENT')) { $fail += "selftest T1-E2.07: wiki-bootstrap skill did not report CURRENT beside its PRUNE" }
        $stRtSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
        if ($stRtSync.ExitCode -ne 0) { throw "selftest T1-E2.07: convergence re-sync failed (exit $($stRtSync.ExitCode))" }
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
        $rtSync2 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
        if ($rtSync2.ExitCode -ne 0) { throw "selftest T1-E2.07: idempotence re-sync failed (exit $($rtSync2.ExitCode))" }
        $rtHash2 = @((Get-FileHash $rtBc -Algorithm SHA256).Hash, (Get-FileHash $rtOcPath -Algorithm SHA256).Hash)
        if (($rtHash1 -join '|') -ne ($rtHash2 -join '|')) { $fail += "selftest T1-E2.07: second sync moved base-context.md or opencode.json (retirement transport not idempotent)" }
        # End-to-end -Check gate: immediately after a successful sync the target must
        # report IN SYNC (manifest stamped, prefix-locked agents excluded from the hash).
        # This guards both post-sync bookkeeping bugs: the phantom UPGRADE from an
        # unstamped manifest and the eternal agents DRIFT from the regenerated prefix.
        $stE2eCheck = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check')
        if ($stE2eCheck.ExitCode -ne 0) { $fail += "-Check reported OUT OF SYNC immediately after a successful sync" }
        # --- T1-E2.08 fixture: the ordering-aware counter (behind / ahead / shape crossing) ---
        # Plant an AHEAD value in the target manifest and assert three things: -Check reports
        # AHEAD (never UPGRADE), -Check exits non-zero, and a SYNC halts BEFORE writing so the
        # target value is never silently rewound. Then plant a shape-crossed value, assert
        # MIGRATION + non-zero, and restore the source value so later fixtures stay isolated.
        $mvSrcRaw = Get-Content -Raw $stManifestPath
        $mvSrc = [regex]::Match($mvSrcRaw, '(?m)^machinery-version:\s*(\d+(?:\.\d+)*)').Groups[1].Value
        $mvAhead = if ($mvSrc -match '\.') { "$mvSrc.1" } else { [string]([int]$mvSrc + 1) }
        $mvShape = if ($mvSrc -match '\.') { '99' } else { '1.0.73' }
        $mvTgtPath = Join-Path $tmp '.devops/sync-manifest.yaml'
        [System.IO.File]::WriteAllText($mvTgtPath, [regex]::Replace([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $mvAhead"))
        Write-Output "SELFTEST fixture T1-E2.08: target counter planted AHEAD ($mvSrc -> $mvAhead)"
        $mvOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
        $mvOut = $mvOutRec.Combined
        if ($mvOutRec.ExitCode -eq 0) { $fail += "selftest T1-E2.08: -Check reported IN SYNC with a target-ahead counter (exit 0)" }
        if (-not ($mvOut -match 'AHEAD')) { $fail += "selftest T1-E2.08: -Check did not report AHEAD for a target-ahead counter" }
        if ($mvOut -match 'meta\s+machinery-version\s+UPGRADE') { $fail += "selftest T1-E2.08: -Check mislabelled a target-ahead counter as UPGRADE" }
        $mvHalt = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify') -AllowNonZero
        if ($mvHalt.ExitCode -eq 0) { $fail += "selftest T1-E2.08: sync proceeded against a target-ahead counter (no halt)" }
        $mvAfterAhead = [regex]::Match([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*(\d+(?:\.\d+)*)').Groups[1].Value
        if ($mvAfterAhead -ne $mvAhead) { $fail += "selftest T1-E2.08: sync rewound an ahead counter ($mvAhead -> $mvAfterAhead)" }
        [System.IO.File]::WriteAllText($mvTgtPath, [regex]::Replace([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $mvShape"))
        Write-Output "SELFTEST fixture T1-E2.08: target counter planted shape-crossed ($mvShape vs source $mvSrc)"
        $mvOut2Rec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
        $mvOut2 = $mvOut2Rec.Combined
        if ($mvOut2Rec.ExitCode -eq 0) { $fail += "selftest T1-E2.08: -Check reported IN SYNC with a shape-crossed counter (exit 0)" }
        if (-not ($mvOut2 -match 'MIGRATION')) { $fail += "selftest T1-E2.08: -Check did not report MIGRATION for a shape-crossed counter" }
        [System.IO.File]::WriteAllText($mvTgtPath, [regex]::Replace([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $mvSrc"))
        $mvRestored = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check')
        if ($mvRestored.ExitCode -ne 0) { $fail += "selftest T1-E2.08: -Check not IN SYNC after restoring the counter to the source value" }
        # Claims checker smoke: the ported script must execute in a satellite against
        # the synced .wiki/rules corpus and report clean (imports wiki_lint, same dir).
        if (Test-Path (Join-Path $tmp 'scripts/wiki_claims.py')) {
            & python (Join-Path $tmp 'scripts/wiki_claims.py') check --quiet | Out-Null
            if ($LASTEXITCODE -ne 0) { $fail += "wiki_claims.py check failed in target (exit $LASTEXITCODE)" }
        } else {
            $fail += "wiki_claims.py missing from target scripts/"
        }
        # --- T3-E1.04 fixture: the skill tier (`profile: FULL | CORE`) -----------------------
        # A satellite declares how much of the library it carries; the sync respects it. Proves
        # the contracts that would otherwise ship silently wrong: CORE narrows the compared set,
        # an un-installed tiered-out skill is never MISSING, a PRESENT one is PRUNE and a sync
        # sheds it, FULL restores it additively, and an unknown value HALTS naming itself.
        # Runs LAST: it leaves the temp target back at `profile: FULL`.
        $stCore = @($stMan.Lists['core_skills'])
        $stFullOnly = @($stSkills | Where-Object { $stCore -notcontains $_ })
        if ($stCore.Count -eq 0) {
            $fail += "T3-E1.04: source manifest declares no core_skills"
        } elseif ($stFullOnly.Count -eq 0) {
            $fail += "T3-E1.04: core_skills covers the whole library - no tier left to test"
        } else {
            foreach ($slug in $stCore) {
                if ($stSkills -notcontains $slug) { $fail += "T3-E1.04: core_skills entry '$slug' resolves to no source skill folder" }
            }
            if ($stCore.Count -ge $stSkills.Count) { $fail += "T3-E1.04: core_skills is not a strict subset of the portable set" }
            $stTgtManifest = Join-Path $tmp '.devops/sync-manifest.yaml'
            function Set-FixtureProfile {
                # A satellite's OWN declaration: rewrite the key in place, exactly as an operator
                # would. The sync must never clobber it (it rewrites only machinery-version).
                param([string]$Value)
                $raw = [System.IO.File]::ReadAllText($stTgtManifest)
                if ($raw -match '(?m)^profile:') {
                    $raw = [regex]::Replace($raw, '(?m)^profile:.*$', "profile: $Value")
                } else {
                    $raw = $raw.TrimEnd() + "`r`nprofile: $Value`r`n"
                }
                [System.IO.File]::WriteAllText($stTgtManifest, $raw)
            }
            $stProbe = $stFullOnly[0]
            # (iii) CORE: the present FULL-only skills are PRUNE (never MISSING) and a sync sheds
            # them; the CORE set survives and -Check is then IN SYNC with no MISSING at all.
            Set-FixtureProfile 'CORE'
            Write-Output "SELFTEST fixture T3-E1.04: target profile set to CORE (full-only probe '$stProbe')"
            $stCoreOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stCoreOut = $stCoreOutRec.Combined
            if ($stCoreOutRec.ExitCode -eq 0) { $fail += "T3-E1.04: -Check reported IN SYNC with tiered-out skills present (exit 0)" }
            if (-not ($stCoreOut -match 'PRUNE')) { $fail += "T3-E1.04: -Check did not report PRUNE for a present tiered-out skill" }
            if ($stCoreOut -match 'MISSING') { $fail += "T3-E1.04: -Check reported MISSING under a CORE profile" }
            $stCoreSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
            if ($stCoreSync.ExitCode -ne 0) { throw "selftest T3-E1.04: CORE sync failed (exit $($stCoreSync.ExitCode))" }
            foreach ($slug in $stFullOnly) {
                if (Test-Path (Join-Path $tmp ".devops/skills/$slug")) { $fail += "T3-E1.04: tiered-out skill '$slug' survived the CORE sync"; break }
            }
            foreach ($slug in $stCore) {
                if (-not (Test-Path (Join-Path $tmp ".devops/skills/$slug"))) { $fail += "T3-E1.04: CORE skill '$slug' was pruned by the tier switch"; break }
            }
            $stCoreCheckRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check')
            $stCoreCheck = $stCoreCheckRec.Combined
            if ($stCoreCheckRec.ExitCode -ne 0) { $fail += "T3-E1.04: -Check not IN SYNC for a settled CORE target" }
            if ($stCoreCheck -match 'MISSING') { $fail += "T3-E1.04: an un-installed tiered-out skill was reported MISSING (it must not be compared at all)" }
            if ($stCoreCheck -match [regex]::Escape($stProbe)) { $fail += "T3-E1.04: -Check named the tiered-out skill '$stProbe'" }
            # (iv) a tiered-out skill PRESENT in a CORE target: PRUNE, then deleted by a sync.
            $stStaleSkill = Join-Path $tmp ".devops/skills/$stProbe"
            New-Item -ItemType Directory -Force -Path $stStaleSkill | Out-Null
            Set-Content -Path (Join-Path $stStaleSkill 'SKILL.md') -Value "stale" -NoNewline
            $stPruneOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stPruneOut = $stPruneOutRec.Combined
            if ($stPruneOutRec.ExitCode -eq 0) { $fail += "T3-E1.04: -Check reported IN SYNC with a tiered-out skill present (exit 0)" }
            if (-not ($stPruneOut -match 'PRUNE')) { $fail += "T3-E1.04: -Check did not report PRUNE for a tiered-out skill present in a CORE target" }
            $stTierPruneSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
            if ($stTierPruneSync.ExitCode -ne 0) { throw "selftest T3-E1.04: tier prune re-sync failed (exit $($stTierPruneSync.ExitCode))" }
            if (Test-Path $stStaleSkill) { $fail += "T3-E1.04: the tiered-out skill survived the sync (tier prune failed)" }
            $stTierCheck = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check')
            if ($stTierCheck.ExitCode -ne 0) { $fail += "T3-E1.04: -Check not IN SYNC after the tier prune" }
            # (v) CORE -> FULL is purely additive: the tiered-out skill comes back, byte-identical.
            Set-FixtureProfile 'FULL'
            $stFullSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
            if ($stFullSync.ExitCode -ne 0) { throw "selftest T3-E1.04: FULL restore sync failed (exit $($stFullSync.ExitCode))" }
            $stProbeFile = Join-Path $stStaleSkill 'SKILL.md'
            if (-not (Test-Path $stProbeFile)) {
                $fail += "T3-E1.04: declaring FULL did not re-materialise the tiered-out skill (not additive)"
            } else {
                $hSrc = (Get-FileHash (Join-Path $srcRoot ".devops/skills/$stProbe/SKILL.md") -Algorithm SHA256).Hash
                $hTgt = (Get-FileHash $stProbeFile -Algorithm SHA256).Hash
                if ($hSrc -ne $hTgt) { $fail += "T3-E1.04: the restored skill '$stProbe' differs from its source (restore is not a clean copy)" }
            }
            $stFullCheck = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check')
            if ($stFullCheck.ExitCode -ne 0) { $fail += "T3-E1.04: -Check not IN SYNC after the FULL restore" }
            # (vi) an unknown profile HALTS loudly, naming the value, and exits non-zero. The
            # child's streams are captured at the PROCESS level by Invoke-CapturedChild: a
            # native command's stderr routed through PowerShell's error stream is not reliably
            # catchable under $ErrorActionPreference = 'Stop', and this fixture must assert the
            # halt, not swallow it.
            Set-FixtureProfile 'BOGUS'
            $stBogusRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stBogusMsg = $stBogusRec.Combined
            if ($stBogusRec.ExitCode -eq 0) { $fail += "T3-E1.04: -Check accepted an unknown profile value (exit 0)" }
            if ($stBogusMsg -notmatch 'unknown profile') { $fail += "T3-E1.04: the unknown-profile halt did not carry the engine's message (got: $stBogusMsg)" }
            if ($stBogusMsg -notmatch 'BOGUS') { $fail += "T3-E1.04: the unknown-profile halt did not name the value" }
            # ...and the SYNC path halts too, before writing anything (the tier resolves ahead of
            # the copy loops), so a bad declaration can never half-install a surface.
            $stSkillsBefore = (Get-ChildItem (Join-Path $tmp '.devops/skills') -Directory).Count
            $stBogusSyncRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify') -AllowNonZero
            if ($stBogusSyncRec.ExitCode -eq 0) { $fail += "T3-E1.04: the sync path accepted an unknown profile value (exit 0)" }
            $stSkillsAfter = (Get-ChildItem (Join-Path $tmp '.devops/skills') -Directory).Count
            if ($stSkillsAfter -ne $stSkillsBefore) { $fail += "T3-E1.04: the unknown-profile sync wrote to the target ($stSkillsBefore -> $stSkillsAfter skills)" }
            Set-FixtureProfile 'FULL'
        }
        # --- T1-E1.05 fixture: the opencode.json key-shape migration -------------------------
        # Three plants. Each re-downgrades the target's OWN opencode.json first (the harness
        # syncs above leave it V2-native) and asserts the pre-state it assumes, so no plant can
        # pass vacuously. They run LAST in the family.
        # (1) migration plant: an all-keys-present, task-already-stamped satellite whose ONLY
        #     pending change is the key-shape migration - so the migration's own flag is the
        #     only reason the write fires, and its own declared path must survive verbatim.
        $oc15SeedPath = Join-Path $srcRoot '.devops/templates/opencode.template.json'
        $oc15OcPath = Join-Path $tmp 'opencode.json'
        $oc15SeedText = ([System.IO.File]::ReadAllText($oc15SeedPath)) -replace "`r`n", "`n"
        $oc15Key = ($stSrcRegistry.Keys | Sort-Object)[-1]
        $mpPlanted = $oc15SeedText.Replace('  "skills": [".devops/skills"],', '  "skills": { "paths": ["custom/skills", ".devops/skills"] },')
        # The planted value carries the candidate-verdict scan's FALSE-POSITIVE control (C-R3-2):
        # a comma immediately before a closing brace INSIDE a string literal, plus an escaped
        # quote. A scan that is not string-aware flags the first; one that is quote-aware but not
        # escape-aware ends the string early and flags the second. Both must read VALID, or the
        # fix's "must never reject valid JSON" clause ships with no permanent owner. The anchor
        # is THIS text, read BEFORE the sync child below: the member carrying it is the member
        # the migration deletes, so an assertion read off the post-sync file would pass vacuously.
        $mpPlanted = $mpPlanted.Replace('  "$schema":', '  "instructions": ["AGENTS.md", "a,}", "a\"b"],' + "`n" + '  "$schema":')
        if ($mpPlanted -notmatch '"instructions"\s*:') { $fail += "selftest T1-E1.05: migration plant carries no config member to delete" }
        if (-not (Test-JsonShape $mpPlanted)) { $fail += "selftest T1-E1.05: the candidate-verdict scan rejected a VALID config (false positive on a comma/brace inside a string, or on an escaped quote)" }
        $mpPre = $null; try { $mpPre = $mpPlanted | ConvertFrom-Json } catch { $mpPre = $null }
        if (-not $mpPre -or -not $mpPre.skills.paths) { $fail += "selftest T1-E1.05: migration plant pre-state invalid ('skills' is not the V1 object)" }
        Write-Output "SELFTEST fixture T1-E1.05: migration plant planted (V1 skills object + the ignored config member)"
        [System.IO.File]::WriteAllText($oc15OcPath, $mpPlanted, (New-Object System.Text.UTF8Encoding($false)))
        $mpAgentM = [regex]::Match($mpPlanted, '"agent"\s*:\s*\{'); $mpAgentOpen = $mpPlanted.IndexOf('{', $mpAgentM.Index); $mpAgentClose = Find-MatchingBrace $mpPlanted $mpAgentOpen
        $mpAgentBefore = $mpPlanted.Substring($mpAgentOpen, $mpAgentClose - $mpAgentOpen + 1)
        $mpHash1 = (Get-FileHash $oc15OcPath -Algorithm SHA256).Hash
        $mpSync1 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
        if ($mpSync1.ExitCode -ne 0) { throw "selftest T1-E1.05: migration-plant sync failed (exit $($mpSync1.ExitCode))" }
        $mpAfter = [System.IO.File]::ReadAllText($oc15OcPath)
        $mpJson = $null; try { $mpJson = $mpAfter | ConvertFrom-Json } catch { $mpJson = $null }
        if (-not $mpJson) {
            $fail += "selftest T1-E1.05: migration plant left opencode.json unparsable"
        } else {
            if (-not ($mpJson.skills -is [array])) { $fail += "selftest T1-E1.05: migration plant 'skills' is not the V2 flat array" }
            elseif (($mpJson.skills -join ',') -ne 'custom/skills,.devops/skills') { $fail += "selftest T1-E1.05: migration plant did not preserve the declared path entries" }
            if ($mpJson.PSObject.Properties['instructions']) { $fail += "selftest T1-E1.05: migration plant left the ignored config member in place" }
            $mpAgentM2 = [regex]::Match($mpAfter, '"agent"\s*:\s*\{'); $mpAgentOpen2 = $mpAfter.IndexOf('{', $mpAgentM2.Index); $mpAgentClose2 = Find-MatchingBrace $mpAfter $mpAgentOpen2
            if ($mpAgentBefore -ne $mpAfter.Substring($mpAgentOpen2, $mpAgentClose2 - $mpAgentOpen2 + 1)) { $fail += "selftest T1-E1.05: migration plant restructured the agent block" }
            $mpHash2 = (Get-FileHash $oc15OcPath -Algorithm SHA256).Hash
            if ($mpHash2 -eq $mpHash1) { $fail += "selftest T1-E1.05: the migration alone did not trigger the write (hash unchanged)" }
            $mpSync2 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')
            if ($mpSync2.ExitCode -ne 0) { throw "selftest T1-E1.05: migration-plant idempotence re-sync failed (exit $($mpSync2.ExitCode))" }
            if ((Get-FileHash $oc15OcPath -Algorithm SHA256).Hash -ne $mpHash2) { $fail += "selftest T1-E1.05: a second sync moved the migrated opencode.json (not idempotent)" }
        }
        # (2) unsafe-rewrite plant: the removed member is the LAST root member, so the line-level
        #     delete would leave a trailing comma -> step-local revert. An omitted registry key
        #     must still be inserted (step-locality), the file must still parse, and the strict
        #     V2-only gate must be OBSERVED rejecting the surviving legacy object.
        $urSeed = Get-Content -Raw $oc15SeedPath | ConvertFrom-Json
        $urSeed.PSObject.Properties.Remove('_comment') | Out-Null
        $urSeed.agent.PSObject.Properties.Remove($oc15Key) | Out-Null
        $urSeed.skills = [pscustomobject]@{ paths = @('.devops/skills') }
        $urBody = (($urSeed | ConvertTo-Json -Depth 10) -replace "`r`n", "`n").TrimEnd()
        $urPlanted = $urBody.Substring(0, $urBody.Length - 1).TrimEnd() + ',' + "`n" + '  "instructions": ["AGENTS.md"]' + "`n}" + "`n"
        if ($urPlanted -notmatch '(?s)"instructions"\s*:\s*\["AGENTS\.md"\]\s*\}\s*$') { $fail += "selftest T1-E1.05: unsafe plant pre-state invalid (the member is not the last root member)" }
        if ($urPlanted -match ('"' + [regex]::Escape($oc15Key) + '"\s*:\s*\{')) { $fail += "selftest T1-E1.05: unsafe plant pre-state invalid (registry key '$oc15Key' was not omitted)" }
        Write-Output "SELFTEST fixture T1-E1.05: unsafe-rewrite plant planted (member last, registry key '$oc15Key' omitted)"
        [System.IO.File]::WriteAllText($oc15OcPath, $urPlanted, (New-Object System.Text.UTF8Encoding($false)))
        $urSkM = [regex]::Match($urPlanted, '"skills"\s*:\s*\{'); $urSkOpen = $urPlanted.IndexOf('{', $urSkM.Index); $urSkClose = Find-MatchingBrace $urPlanted $urSkOpen
        $urSkillsBefore = $urPlanted.Substring($urSkOpen, $urSkClose - $urSkOpen + 1)
        $urInstrBefore = [regex]::Match($urPlanted, '(?m)^[ \t]*"instructions"\s*:.*$').Value
        # Combined stdout+stderr, exactly as the old `2>&1 | Out-String` capture was (CONCERN-2).
        $urOut = (Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')).Combined
        if ($urOut -notmatch 'would break the JSON - reverted') { $fail += "selftest T1-E1.05: unsafe plant did not print the revert line" }
        $urAfter = [System.IO.File]::ReadAllText($oc15OcPath)
        $urJson = $null; try { $urJson = $urAfter | ConvertFrom-Json } catch { $urJson = $null }
        if (-not $urJson) { $fail += "selftest T1-E1.05: unsafe plant left opencode.json unparsable" }
        $urSkM2 = [regex]::Match($urAfter, '"skills"\s*:\s*\{'); $urSkOpen2 = $urAfter.IndexOf('{', $urSkM2.Index); $urSkClose2 = Find-MatchingBrace $urAfter $urSkOpen2
        if ($urSkillsBefore -ne $urAfter.Substring($urSkOpen2, $urSkClose2 - $urSkOpen2 + 1)) { $fail += "selftest T1-E1.05: unsafe plant rewrote the legacy 'skills' object (the revert was not step-local)" }
        if ([regex]::Match($urAfter, '(?m)^[ \t]*"instructions"\s*:.*$').Value -ne $urInstrBefore) { $fail += "selftest T1-E1.05: unsafe plant deleted the member despite the revert" }
        if ($urJson -and -not $urJson.agent.PSObject.Properties[$oc15Key]) { $fail += "selftest T1-E1.05: unsafe plant's omitted registry key was not inserted (reconciliation was not step-local)" }
        # `-Verify` exits non-zero here by design (the legacy object survives), so the failure
        # is declared; the assertions below read the combined stream (CONCERN-2).
        $urV = (Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-Verify') -AllowNonZero).Combined
        $urStruct = ($urV -split '=== Machinery gates ===')[0]
        if ($urStruct -notmatch "\[FAIL\][^\n]*opencode\.json[^\n]*skills") { $fail += "selftest T1-E1.05: the strict gate did not FAIL the surviving legacy 'skills' object" }
        if ($urStruct -match "\[PASS\][^\n]*opencode\.json") { $fail += "selftest T1-E1.05: the strict gate PASSed opencode.json while the legacy object survived" }
        # (3) urls-refusal plant: the `skills` object also carries `urls`, so the shape rewrite is
        #     REFUSED (left byte-identical) while the separate member delete still runs and the
        #     omitted registry key is inserted - observed THROUGH a write, never silently.
        $urlSeed = Get-Content -Raw $oc15SeedPath | ConvertFrom-Json
        $urlSeed.PSObject.Properties.Remove('_comment') | Out-Null
        $urlSeed.agent.PSObject.Properties.Remove($oc15Key) | Out-Null
        $urlSeed.skills = [pscustomobject]@{ paths = @('.devops/skills'); urls = @('https://example.invalid') }
        $urlRaw0 = ($urlSeed | ConvertTo-Json -Depth 10) -replace "`r`n", "`n"
        $urlPlanted = $urlRaw0 -replace '(?s)("skills"\s*:\s*\{[^}]*\}\s*,)', ('$1' + "`n  " + '"instructions": ["AGENTS.md"],')
        if ($urlPlanted -notmatch '"instructions"\s*:') { $fail += "selftest T1-E1.05: urls plant carries no config member to delete" }
        if ($urlPlanted -match '(?s)"instructions"\s*:\s*\[[^\]]*\]\s*\}\s*$') { $fail += "selftest T1-E1.05: urls plant pre-state invalid (the member must not be last)" }
        Write-Output "SELFTEST fixture T1-E1.05: urls-refusal plant planted (skills carries urls, registry key '$oc15Key' omitted)"
        [System.IO.File]::WriteAllText($oc15OcPath, $urlPlanted, (New-Object System.Text.UTF8Encoding($false)))
        $urlSkM = [regex]::Match($urlPlanted, '"skills"\s*:\s*\{'); $urlSkOpen = $urlPlanted.IndexOf('{', $urlSkM.Index); $urlSkClose = Find-MatchingBrace $urlPlanted $urlSkOpen
        $urlSkillsBefore = $urlPlanted.Substring($urlSkOpen, $urlSkClose - $urlSkOpen + 1)
        # Combined stdout+stderr, exactly as the old `2>&1 | Out-String` capture was (CONCERN-2).
        $urlOut = (Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Target', $tmp, '-NoVerify')).Combined
        $urlAfter = [System.IO.File]::ReadAllText($oc15OcPath)
        $urlJson = $null; try { $urlJson = $urlAfter | ConvertFrom-Json } catch { $urlJson = $null }
        if (-not $urlJson) { $fail += "selftest T1-E1.05: urls plant left opencode.json unparsable" }
        $urlSkM2 = [regex]::Match($urlAfter, '"skills"\s*:\s*\{'); $urlSkOpen2 = $urlAfter.IndexOf('{', $urlSkM2.Index); $urlSkClose2 = Find-MatchingBrace $urlAfter $urlSkOpen2
        if ($urlSkillsBefore -ne $urlAfter.Substring($urlSkOpen2, $urlSkClose2 - $urlSkOpen2 + 1)) { $fail += "selftest T1-E1.05: urls plant rewrote a 'skills' shape it must refuse" }
        if ($urlOut -notmatch "'urls'") { $fail += "selftest T1-E1.05: urls plant printed no refusal line naming 'urls'" }
        if ($urlJson) {
            if ($urlJson.PSObject.Properties['instructions']) { $fail += "selftest T1-E1.05: urls plant did not delete the config member (a refusal must be shape-scoped)" }
            if (-not $urlJson.agent.PSObject.Properties[$oc15Key]) { $fail += "selftest T1-E1.05: urls plant's omitted registry key was not inserted (no write fired)" }
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

# The effective portable skill surface - ONE derivation, profile-aware: the source's skills
# minus `excluded_skills`, intersected with `core_skills` when the target declares `profile:
# CORE`. It drives BOTH the -Check comparison and the copy loop, so the two cannot disagree.
$tier = Get-SkillTier -SrcRoot $srcRoot -TgtRoot $tgtRoot
$portableSkills = @($tier.Effective)
# The prune input: the manifest's retired paths PLUS the tier's tiered-out skill dirs, so a
# downgraded CORE target sheds them through the existing PRUNE mechanism (sync-prune.ps1
# untouched).
$pruneManifest = Get-EffectivePruneManifest -Manifest $manifest -Tier $tier

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

    # Header item: machinery-version itself. ORDERING-AWARE - behind -> UPGRADE (pull),
    # ahead -> AHEAD and a lineage shape crossing -> MIGRATION (both halt-and-reconcile).
    # An equality-only test cannot tell behind from ahead, which is how a target-ahead
    # counter is silently rewound by the next pull (GRID-Link 78 vs template 72).
    $srcMachV = $scalars['machinery-version']
    $tgtMachV = Get-ManifestMachineVersion $tgtRoot
    switch (Compare-MachineryVersion ([string]$tgtMachV) ([string]$srcMachV)) {
        'absent'    { Add-Verdict 'meta' 'machinery-version' 'MISSING' "target manifest absent or has no machinery-version (source: $srcMachV)" }
        'behind'    { Add-Verdict 'meta' 'machinery-version' 'UPGRADE' "target $tgtMachV -> source $srcMachV (target behind)" }
        'ahead'     { Add-Verdict 'meta' 'machinery-version' 'AHEAD' "target $tgtMachV is AHEAD of source $srcMachV - the commonest cause is a satellite that bumped a counter it does not own (template-owned and sync-stamped: a satellite never bumps it) - halt and reconcile: confirm the target has no release rows in the diverged range, then write $srcMachV into its manifest by hand; the sync never rewinds a counter it did not earn" }
        'migration' { Add-Verdict 'meta' 'machinery-version' 'MIGRATION' "target '$tgtMachV' vs source '$srcMachV' - lineage shape crossed (integer vs dotted); halt and reconcile by hand before pulling" }
        default     { Add-Verdict 'meta' 'machinery-version' 'CURRENT' "$srcMachV" }
    }

    $prunePaths = @($pruneManifest['prune_files'] | ForEach-Object { $_.Replace('\','/') })
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
    Test-PrunePresent -TgtRoot $tgtRoot -Manifest $pruneManifest

    Write-Output ("{0,-6} {1,-42} {2,-14} {3}" -f 'KIND', 'ITEM', 'VERDICT', 'DETAIL')
    foreach ($v in $script:verdicts) { Write-Output ("{0,-6} {1,-42} {2,-14} {3}" -f $v.Kind, $v.Item, $v.Verdict, $v.Detail) }

    $counts = @{}
    foreach ($v in $script:verdicts) { $counts[$v.Verdict] = 1 + [int]$counts[$v.Verdict] }
    $bad = 0
    foreach ($b in @('UPGRADE', 'DRIFT', 'MISSING', 'SOURCE-ABSENT', 'PRUNE', 'AHEAD', 'MIGRATION')) { $bad += [int]$counts[$b] }
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

# --- pre-flight: the counter ordering. A target AHEAD of, or shape-incompatible with, the
# source must halt BEFORE any write: the stamp pass would otherwise rewind a counter the
# target earned, and a partial pull is worse than none. The reconcile recipe is printed -
# the script never rewrites a counter it did not earn (GRID-Link 78 vs template 72).
$pfSrcV = $scalars['machinery-version']
$pfTgtV = Get-ManifestMachineVersion $tgtRoot
$pfCmp = Compare-MachineryVersion ([string]$pfTgtV) ([string]$pfSrcV)
if ($pfCmp -eq 'ahead' -or $pfCmp -eq 'migration') {
    Write-Output ""
    if ($pfCmp -eq 'ahead') {
        Write-Output "HALT: target machinery-version $pfTgtV is AHEAD of source $pfSrcV."
    } else {
        Write-Output "HALT: machinery-version lineage shape differs - target '$pfTgtV' vs source '$pfSrcV'."
    }
    Write-Output "Reconcile recipe (operator action):"
    Write-Output "  0. Commonest cause: the target bumped machinery-version itself. The counter is template-owned and sync-stamped - a satellite never bumps it, so a satellite-side increment is inert and must never be defended."
    Write-Output "  1. Confirm the target's .devops/logs/version-history.md records no release row in the diverged range"
    Write-Output "     (a rewound counter must not orphan a recorded release)."
    Write-Output "  2. Write 'machinery-version: $pfSrcV' into the target's .devops/sync-manifest.yaml by hand."
    Write-Output "  3. Re-run this sync. This run wrote nothing."
    exit 1
}

$copied = 0
$skipped = @()

# 1. Portable directories.
foreach ($dir in $manifest['portable_dirs']) {
    $s = Join-Path $srcRoot $dir
    if (-not (Test-Path $s)) { $skipped += "missing in source: $dir"; continue }
    $t = Join-Path $tgtRoot $dir
    if ($DryRun) {
        # -Force: Unix hides dot-prefixed entries from a bare Get-ChildItem, so the reported
        # count would differ by host - the v0.3.17 precedent (make the walker host-monotone).
        $n = (Get-ChildItem $s -Recurse -File -Force).Count
        Write-Output "DRYRUN would copy $dir ($n files)"
    } else {
        New-Item -ItemType Directory -Force -Path $t | Out-Null
        Copy-Item (Join-Path $s '*') $t -Recurse -Force
        Write-Output "COPIED $dir"
    }
    $copied++
}

# 2. Portable skills (the profile-aware effective set; copy each folder).
foreach ($slug in $portableSkills) {
    $s = Join-Path $srcRoot ".devops/skills/$slug"
    if (-not (Test-Path $s)) { $skipped += "missing in source: skills/$slug"; continue }
    $t = Join-Path $tgtRoot ".devops/skills/$slug"
    if ($DryRun) {
        $n = (Get-ChildItem $s -Recurse -File -Force).Count
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
$prunePlan = @(Get-PrunePlan -TgtRoot $tgtRoot -Manifest $pruneManifest)
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