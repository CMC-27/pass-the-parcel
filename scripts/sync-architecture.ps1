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
        machinery-version:  integer version of the dirs/files/agents/rules set; drives
                            UPGRADE vs DRIFT classification for non-skill items

    -Check compares source vs target per manifest item (SHA256 per file + version metadata)
    and prints a CURRENT/UPGRADE/DRIFT/MISSING/PRUNE/SOURCE-ABSENT verdict table without writing.
    A retired file still present in the target is a PRUNE verdict, and like every other
    non-CURRENT verdict it makes -Check exit 1. Prune files are excluded from their parent
    directory's comparison, so a lingering retired file surfaces as PRUNE rather than a
    misleading parent-dir DRIFT ("locally customized") when the live content matches upstream.
    For the PREFIX-LOCKED agents (.devops/agents/parcel*.agent.md + ptp-*.subagent.md) only
    the agent-unique content is hashed: the prefix region is regenerated from each repo's
    own base-context.md after every sync, so it legitimately differs between source and
    target and must never mask a CURRENT verdict.

    After copying, the script stamps the TARGET's own .devops/sync-manifest.yaml with the
    source machinery-version (installing a copy of the manifest on first sync). Without
    this bookkeeping, -Check would report a phantom UPGRADE forever after every successful
    sync, because the manifest itself is not on the portable surface.

    It also force-propagates the source Model Registry into the target's three binding
    surfaces (registry rows in base-context.md, agent frontmatter `model:` lines, and
    opencode.json agent.<key>.model values). Model bindings are template-owned: there is
    no preservation branch. The target's registry table is REWRITTEN for keys it already
    carries and rows are INSERTED for keys it lacks, so a template-side registry growth
    reaches an already-bootstrapped satellite. Only the opencode.json surface can report
    a BINDING-SKIP (a key absent from the target's agent block - sync never restructures
    the repo-specific opencode.json). This runs BEFORE prefix regeneration.

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
    and opencode.json ARE edited in place, but only for model bindings (registry rows and
    agent.<key>.model values) - never copied wholesale, never restructured. After the
    portable surface is copied, the script regenerates each agent's PREFIX-LOCKED prefix from
    the TARGET's own .opencode/plans/base-context.md so the cache anchor always matches the
    local workspace.

.NOTES
    Usage:
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/to/satellite
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/ -DryRun
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/to/satellite -Verify
        powershell -File scripts/sync-architecture.ps1 -SelfTest
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

function Read-Manifest {
    # Parse the sync-manifest.yaml YAML subset once: list keys (key: followed by
    # '- item' lines, or 'key: []') and scalar keys (key: value). Single source of
    # truth for both the main path and -SelfTest.
    param([string]$Path)
    $lists = [ordered]@{}
    $scalars = [ordered]@{}
    $currentKey = $null
    foreach ($line in Get-Content $Path) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith('#')) { continue }
        if ($t -match '^([a-z_-]+):\s*\[\s*\]\s*(?:#.*)?$') {
            $lists[$Matches[1]] = @()
            $currentKey = $null
        } elseif ($t -match '^([a-z_-]+):\s*$') {
            $currentKey = $Matches[1]
            $lists[$currentKey] = @()
        } elseif ($t -match '^([a-z_-]+):\s+(.+)$') {
            $scalars[$Matches[1]] = $Matches[2].Trim().Trim('"')
            $currentKey = $null
        } elseif ($t.StartsWith('- ') -and $currentKey) {
            $lists[$currentKey] += $t.Substring(2).Trim().Trim('"')
        }
    }
    return @{ Lists = $lists; Scalars = $scalars }
}

function Get-RegistryBindings {
    # Parse a `## Model Registry` table out of a base-context file:
    # key -> @{class;vscode;opencode} (class is the capability-class cell, used when
    # INSERTING a row for a key the target registry does not carry yet).
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { return $map }
    $text = ([System.IO.File]::ReadAllText($Path)) -replace "`r`n", "`n"
    foreach ($line in ($text -split "`n")) {
        if ($line -match '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|') {
            $map[$Matches[1]] = @{ class = $Matches[2]; vscode = $Matches[3]; opencode = $Matches[4] }
        }
    }
    return $map
}

function Update-TargetModelBindings {
    # Force-propagate the SOURCE Model Registry into the target's binding surfaces:
    # (1) the target's registry table rows (rewritten, plus rows INSERTED for keys the
    # target lacks - registry growth must reach an existing satellite), (2) each target
    # agent file's frontmatter `model:` line, (3) each present target opencode.json
    # `agent.<key>.model` value.
    # There is no preservation branch: a satellite-side rebind is transient by contract.
    # ponytail: naive 4-cell registry row rewrite keyed on the first cell - a reordered or
    # 3-cell table is left alone and fails loudly in check-parcel-prefix instead.
    # ponytail: only keys already present in the target's agent block are stamped - sync
    # never adds or restructures the repo-specific opencode.json (permission blocks differ
    # per satellite). Missing keys are reported; the validator FAILs on them.
    param([string]$SrcRoot, [string]$TgtRoot, [switch]$DryRun)
    $srcRegistry = Get-RegistryBindings (Join-Path $SrcRoot '.opencode/plans/base-context.md')
    if ($srcRegistry.Count -eq 0) {
        Write-Output 'BINDINGS: source registry empty or unreadable - nothing stamped'
        return
    }
    if ($DryRun) {
        Write-Output ("DRYRUN would stamp {0} model binding(s) into the target" -f $srcRegistry.Count)
        return
    }

    # 1. Target registry table (repo-specific file: rows only, prose untouched).
    #    Existing rows are REWRITTEN to the source binding; rows for keys the target
    #    does not carry are INSERTED after the last existing registry row, so a
    #    template-side registry growth (e.g. v39's 10 -> 12 rows) reaches an
    #    already-bootstrapped satellite instead of leaving the target's own
    #    check-parcel-prefix.ps1 permanently red (`no Model Registry row for '<key>'`).
    $tgtBc = Join-Path $TgtRoot '.opencode/plans/base-context.md'
    $rows = 0
    if (Test-Path $tgtBc) {
        $raw = [System.IO.File]::ReadAllText($tgtBc) -replace "`r`n", "`n"
        $end = if ($raw.EndsWith("`n")) { "`n" } else { "" }
        $lines = [System.Collections.Generic.List[string]]($raw -split "`n")
        $present = @{}
        $lastRowIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -notmatch '^\|\s*([a-z0-9-]+)\s*\|') { continue }
            $rk = $Matches[1]
            $present[$rk] = $true
            $lastRowIdx = $i
            if (-not $srcRegistry.ContainsKey($rk)) { continue }
            $cls = ([regex]::Match($lines[$i], '^\|\s*[a-z0-9-]+\s*\|\s*([^|]+?)\s*\|')).Groups[1].Value
            $newRow = "| $rk | $cls | $($srcRegistry[$rk]['vscode']) | $($srcRegistry[$rk]['opencode']) |"
            if ($lines[$i] -ne $newRow) { $lines[$i] = $newRow; $rows++ }
        }
        # Insert rows for keys the target registry is missing. ponytail: anchored on the
        # last existing registry row; a re-laid-out table is not detected - the target's
        # check-parcel-prefix fails loud instead of a row being silently misplaced.
        $missing = @($srcRegistry.Keys | Where-Object { -not $present.ContainsKey($_) } | Sort-Object)
        if ($lastRowIdx -ge 0 -and $missing.Count -gt 0) {
            $insertAt = $lastRowIdx + 1
            foreach ($mk in $missing) {
                $lines.Insert($insertAt, "| $mk | $($srcRegistry[$mk]['class']) | $($srcRegistry[$mk]['vscode']) | $($srcRegistry[$mk]['opencode']) |")
                $insertAt++
                $rows++
            }
            Write-Output ("BINDINGS: inserted {0} new registry row(s): {1}" -f $missing.Count, ($missing -join ', '))
        }
        if ($rows -gt 0) {
            [System.IO.File]::WriteAllText($tgtBc, (($lines -join "`n") + $end), (New-Object System.Text.UTF8Encoding($false)))
        }
    } else {
        Write-Output 'BINDINGS: target has no base-context.md yet - registry not stamped'
    }

    # 2. Target agent frontmatter.
    $files = 0
    foreach ($key in ($srcRegistry.Keys | Sort-Object)) {
        $target = Join-Path $TgtRoot ".devops/agents/$key.agent.md"
        if (-not (Test-Path $target)) { $target = Join-Path $TgtRoot ".devops/agents/$key.subagent.md" }
        if (-not (Test-Path $target)) { Write-Output "BINDING-SKIP $key (no agent file in target)"; continue }
        $fraw = [System.IO.File]::ReadAllText($target) -replace "`r`n", "`n"
        $m = [regex]::Match($fraw, '(?m)^model:\s*(.+?)\s*$')
        if (-not $m.Success) { Write-Output "BINDING-SKIP $key (no model: line in $key)"; continue }
        $want = $srcRegistry[$key]['vscode']
        if ($m.Groups[1].Value -ne $want) {
            $fraw = $fraw.Remove($m.Index, $m.Length).Insert($m.Index, "model: $want")
            [System.IO.File]::WriteAllText($target, $fraw, (New-Object System.Text.UTF8Encoding($false)))
            $files++
        }
    }

    # 3. Target opencode.json (repo-specific: model values only, structure untouched).
    $ocTarget = Join-Path $TgtRoot 'opencode.json'
    $ocCount = 0
    if (Test-Path $ocTarget) {
        $ocRaw = [System.IO.File]::ReadAllText($ocTarget)
        $ocJson = $null
        try { $ocJson = $ocRaw | ConvertFrom-Json } catch { $ocJson = $null }
        if ($ocJson -and $ocJson.agent) {
            foreach ($key in ($srcRegistry.Keys | Sort-Object)) {
                if (-not $ocJson.agent.PSObject.Properties[$key]) {
                    Write-Output "BINDING-SKIP $key (no agent entry in target opencode.json)"
                    continue
                }
                $wantOc = $srcRegistry[$key]['opencode']
                $pattern = '("' + [regex]::Escape($key) + '"\s*:\s*\{[^}]*?"model"\s*:\s*")([^"]*)(")'
                $hit = [regex]::Match($ocRaw, $pattern)
                if (-not $hit.Success) { Write-Output "BINDING-SKIP $key (model value not locatable in target opencode.json)"; continue }
                if ($hit.Groups[2].Value -ne $wantOc) {
                    $ocRaw = $ocRaw.Remove($hit.Index, $hit.Length).Insert($hit.Index, $hit.Groups[1].Value + $wantOc + $hit.Groups[3].Value)
                    $ocCount++
                }
            }
            if ($ocCount -gt 0) { [System.IO.File]::WriteAllText($ocTarget, $ocRaw, (New-Object System.Text.UTF8Encoding($false))) }
        }
    }
    Write-Output "BINDINGS: stamped/inserted $rows registry row(s), $files frontmatter line(s), $ocCount opencode model value(s)"
}

# --- self-test mode: build a throwaway satellite, sync into it, verify, tear down ---
if ($SelfTest) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-selftest-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        Write-Output "SELFTEST: temp target = $tmp"
        & $shellExe -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify
        if ($LASTEXITCODE -ne 0) { throw "selftest: sync run failed (exit $LASTEXITCODE)" }
        # Manifest must parse identically inside the test process — reuse Read-Manifest.
        $stManifestPath = Join-Path $srcRoot '.devops/sync-manifest.yaml'
        $stMan = Read-Manifest $stManifestPath
        $stDirs = @($stMan.Lists['portable_dirs'])
        $stFiles = @($stMan.Lists['portable_files'])
        $stPrune = @($stMan.Lists['prune_files'])
        $stExcluded = @($stMan.Lists['excluded_skills'])
        $skillsRoot = Join-Path $srcRoot '.devops/skills'
        $stSkills = @(Get-ChildItem $skillsRoot -Directory | ForEach-Object { $_.Name } | Where-Object { $stExcluded -notcontains $_ })
        $fail = @()
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
        # Model binding propagation: every source registry key's frontmatter binding must
        # land in the target's agent file (guards the force-stamp / no-preservation contract).
        $stSrcRegistry = Get-RegistryBindings (Join-Path $srcRoot '.opencode/plans/base-context.md')
        if ($stSrcRegistry.Count -eq 0) { $fail += "selftest: source Model Registry parsed as empty" }
        foreach ($bk in ($stSrcRegistry.Keys | Sort-Object)) {
            $bTgt = Join-Path $tmp ".devops/agents/$bk.agent.md"
            if (-not (Test-Path $bTgt)) { $bTgt = Join-Path $tmp ".devops/agents/$bk.subagent.md" }
            if (-not (Test-Path $bTgt)) { $fail += "binding file missing in target: $bk"; continue }
            $bm = [regex]::Match(([System.IO.File]::ReadAllText($bTgt) -replace "`r`n", "`n"), '(?m)^model:\s*(.+?)\s*$')
            $bWant = $stSrcRegistry[$bk]['vscode']
            if (-not $bm.Success -or $bm.Groups[1].Value -ne $bWant) {
                $bGot = if ($bm.Success) { $bm.Groups[1].Value } else { '<no model: line>' }
                $fail += "binding not propagated for $bk (target frontmatter '$bGot' != registry '$bWant')"
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

function Get-FrontmatterVersion {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    $raw = [System.IO.File]::ReadAllText($Path)
    $m = [regex]::Match($raw, '^---\r?\n.*?\r?\n---', 'Singleline')
    if (-not $m.Success) { return $null }
    $vm = [regex]::Match($m.Value, '(?m)^version:\s*"?(\d+)"?\s*$')
    if ($vm.Success) { return [int]$vm.Groups[1].Value }
    return $null
}

function Get-ManifestMachineVersion {
    param([string]$Root)
    $mp = Join-Path $Root '.devops/sync-manifest.yaml'
    if (-not (Test-Path $mp)) { return $null }
    foreach ($line in Get-Content $mp) {
        if ($line -match '^machinery-version:\s*(\d+)') { return [int]$Matches[1] }
    }
    return $null
}

function Update-TargetManifestVersion {
    # Post-sync bookkeeping: stamp the target's own sync-manifest.yaml with the source
    # machinery-version so -Check classifies the target as CURRENT instead of reporting a
    # phantom UPGRADE forever. The manifest is not on the portable surface (satellites may
    # carry target-local notes in it), so only the version line is rewritten in place; a
    # missing manifest (first-time install) is seeded verbatim from the source.
    param([string]$TgtRoot, [string]$SrcRoot, [string]$Version, [switch]$DryRun)
    if (-not $Version) { Write-Host 'SKIP: source manifest has no machinery-version - target not stamped'; return }
    $tgtManifest = Join-Path $TgtRoot '.devops/sync-manifest.yaml'
    $srcManifest = Join-Path $SrcRoot '.devops/sync-manifest.yaml'
    if (-not (Test-Path $tgtManifest)) {
        if ($DryRun) { Write-Output "DRYRUN would install .devops/sync-manifest.yaml (machinery-version $Version)"; return }
        New-Item -ItemType Directory -Force -Path (Split-Path $tgtManifest) | Out-Null
        Copy-Item $srcManifest $tgtManifest -Force
        Write-Output "INSTALLED .devops/sync-manifest.yaml (machinery-version $Version)"
        return
    }
    $raw = [System.IO.File]::ReadAllText($tgtManifest)
    if ($raw -match '(?m)^machinery-version:\s*(\d+)') {
        if ($Matches[1] -eq $Version) { return }
        if ($DryRun) { Write-Output "DRYRUN would bump machinery-version $($Matches[1]) -> $Version"; return }
        $raw = [regex]::Replace($raw, '(?m)^machinery-version:\s*\d+', "machinery-version: $Version")
        [System.IO.File]::WriteAllText($tgtManifest, $raw)
        Write-Output "STAMPED .devops/sync-manifest.yaml machinery-version $($Matches[1]) -> $Version"
    } else {
        if ($DryRun) { Write-Output "DRYRUN would add machinery-version: $Version to target manifest"; return }
        [System.IO.File]::WriteAllText($tgtManifest, $raw.TrimEnd() + "`r`n`r`nmachinery-version: $Version`r`n")
        Write-Output "STAMPED .devops/sync-manifest.yaml machinery-version -> $Version (key was absent)"
    }
}

function Get-ItemHashes {
    param([string]$Path)
    $map = @{}
    function Hash-Normalized {
        param([string]$File)
        # Normalize CRLF -> LF before hashing: git smudge filters (core.autocrlf /
        # eol=lf in .gitattributes) materialize LF blobs as CRLF on Windows, so raw
        # byte hashes would report false DRIFT after any checkout.
        #
        # PREFIX-LOCKED agents (.devops/agents/parcel*.agent.md + ptp-*.subagent.md):
        # the prefix region is regenerated from each repo's own base-context.md after
        # every sync, so it legitimately differs between source and target. Hash only
        # the agent-unique content (everything from the first "## Delegated Skill:" /
        # "You are the" marker, frontmatter stripped) so -Check can report CURRENT for
        # satellites with a customized base-context; real drift in the unique content
        # still reports DRIFT/UPGRADE as normal.
        $name = Split-Path -Leaf $File
        $text = $null
        if (($name -like 'parcel*.agent.md' -or $name -like 'ptp-*.subagent.md') -and $File.Replace('\','/') -like '*/.devops/agents/*') {
            $raw = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($File)) -replace "`r`n", "`n"
            $body = $raw
            if ($raw.StartsWith("---`n")) {
                $closeIdx = $raw.IndexOf("`n---`n", 4)
                if ($closeIdx -ge 0) { $body = $raw.Substring($closeIdx + 5) }
            }
            $skillIdx = $body.IndexOf('## Delegated Skill:')
            $orchIdx = $body.IndexOf('You are the')
            if ($skillIdx -ge 0 -and $orchIdx -ge 0) { $text = $body.Substring([Math]::Min($skillIdx, $orchIdx)) }
            elseif ($skillIdx -ge 0) { $text = $body.Substring($skillIdx) }
            elseif ($orchIdx -ge 0) { $text = $body.Substring($orchIdx) }
        }
        if ($null -eq $text) {
            $text = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($File)) -replace "`r`n", "`n"
        }
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try { ($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text)) | ForEach-Object { $_.ToString('X2') }) -join '' } finally { $sha.Dispose() }
    }
    # -Force: on Unix, dot-prefixed names are hidden and Get-Item/Get-ChildItem
    # ignore hidden items by default. .vscode is the only portable-surface leaf
    # that is dot-prefixed (.wiki/rules, .devops/agents, ... end in visible
    # names), so without -Force -Check dies on it under Linux/pwsh — the
    # "Could not find item .../.vscode" crash that reddens the CI self-test.
    if ((Get-Item -Force $Path).PSIsContainer) {
        Get-ChildItem -Force $Path -Recurse -File | ForEach-Object {
            $base = $Path.TrimEnd('\', '/'); $rel = $_.FullName.Substring($base.Length + 1).Replace('\','/')
            $map[$rel] = Hash-Normalized $_.FullName
        }
    } else {
        $map[(Split-Path -Leaf $Path)] = Hash-Normalized $Path
    }
    return $map
}

# --- verification helpers ---------------------------------------------------

function Invoke-StructuralVerify {
    # Checks the satellite-authored surface (the files a satellite authors from the seeds
    # in .devops/templates/) against the template blueprint. Read-only. Returns a
    # hashtable with Fail/Warn counts; each check prints a [PASS]/[FAIL]/[WARN] line.
    # Status lines use Write-Host (not Write-Output) so the caller's return-value
    # assignment does not capture them into the result variable.
    param([string]$SrcRoot, [string]$TgtRoot)
    $fail = 0; $warn = 0
    function Line { param($Status, $Msg) Write-Host ("  [{0,-4}] {1}" -f $Status, $Msg) }

    # 1. AGENTS.md - present, with the machinery markers agents rely on.
    $agentsPath = Join-Path $TgtRoot 'AGENTS.md'
    if (-not (Test-Path $agentsPath)) {
        Line 'FAIL' 'AGENTS.md missing at repo root (seed: .devops/templates/AGENTS.template.md)'; $fail++
    } else {
        $raw = [System.IO.File]::ReadAllText($agentsPath)
        $missing = @()
        foreach ($marker in @('MANDATORY READING', '.wiki/core/00-system-index.md', '@pass-the-parcel', '@agent-wrap-up')) {
            if ($raw -notmatch [regex]::Escape($marker)) { $missing += $marker }
        }
        if ($missing.Count -gt 0) {
            Line 'FAIL' ('AGENTS.md missing machinery marker(s): ' + ($missing -join ', ')); $fail++
        } else {
            Line 'PASS' 'AGENTS.md present with machinery markers intact'
        }
    }

    # 2. opencode.json - valid JSON, wired to AGENTS.md + the skills path.
    $ocPath = Join-Path $TgtRoot 'opencode.json'
    if (-not (Test-Path $ocPath)) {
        Line 'FAIL' 'opencode.json missing at repo root (seed: .devops/templates/opencode.template.json)'; $fail++
    } else {
        try {
            $cfg = Get-Content $ocPath -Raw | ConvertFrom-Json
            $ocOk = $true
            if (-not ($cfg.instructions -contains 'AGENTS.md')) { Line 'FAIL' "opencode.json 'instructions' must include 'AGENTS.md'"; $fail++; $ocOk = $false }
            if (-not ($cfg.skills.paths -contains '.devops/skills')) { Line 'FAIL' "opencode.json 'skills.paths' must include '.devops/skills'"; $fail++; $ocOk = $false }
            if ($ocOk) { Line 'PASS' 'opencode.json valid; instructions + skills.paths wired' }
        } catch {
            Line 'FAIL' "opencode.json is not valid JSON: $($_.Exception.Message)"; $fail++
        }
    }

    # 3. base-context.md - the prefix-lock source.
    if (Test-Path (Join-Path $TgtRoot '.opencode/plans/base-context.md')) {
        Line 'PASS' 'base-context.md present (.opencode/plans/)'
    } else {
        Line 'FAIL' 'base-context.md missing (seed: .devops/templates/base-context.template.md -> .opencode/plans/)'; $fail++
    }

    # 4. Wiki anchor - the mandatory-reading entry point.
    if (Test-Path (Join-Path $TgtRoot '.wiki/core/00-system-index.md')) {
        Line 'PASS' 'wiki anchor present (.wiki/core/00-system-index.md)'
    } else {
        Line 'FAIL' 'wiki anchor missing: .wiki/core/00-system-index.md (mandatory reading entry point)'; $fail++
    }

    # 5. Machinery surface - the portable dirs/files a sync materialises.
    foreach ($rel in @('.devops/skills', '.devops/agents', '.devops/rules', '.wiki/rules', '.devops/templates', 'scripts/check-parcel-prefix.ps1', 'scripts/check-utf8-agents.ps1', 'scripts/wiki_lint.py')) {
        if (Test-Path (Join-Path $TgtRoot $rel)) { continue }
        Line 'FAIL' "machinery missing: $rel (run a sync first)"; $fail++
    }

    # 6. .ptp-source - needed for future pulls (advisory only).
    if (Test-Path (Join-Path $TgtRoot '.ptp-source')) {
        Line 'PASS' '.ptp-source present (pull source remembered)'
    } else {
        Line 'WARN' '.ptp-source missing - future pulls need -Source once (pull-architecture.ps1 -Source <path-or-url>)'; $warn++
    }

    return @{ Fail = $fail; Warn = $warn }
}

function Invoke-VerificationGates {
    # Runs the machinery gates inside the target repo. Returns $true when all pass.
    # -RegenPrefix regenerates PREFIX-LOCKED prefixes first (post-sync); without it the
    # prefix check runs check-only (-Verify mode never writes). Status lines use
    # Write-Host so the caller's return-value assignment does not capture them.
    param([string]$TgtRoot, [switch]$RegenPrefix)
    Push-Location $TgtRoot
    try {
        $ok = $true
        $hasBaseContext = Test-Path (Join-Path $TgtRoot '.opencode/plans/base-context.md')
        $prefixScript = Join-Path $TgtRoot 'scripts/check-parcel-prefix.ps1'
        if ($RegenPrefix) {
            if ($hasBaseContext) {
                Write-Host "Regenerating PREFIX-LOCKED prefixes from target base-context..."
                & $shellExe -NoProfile -File $prefixScript -Sync | Out-Host
                if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: check-parcel-prefix'; $ok = $false }
                else { Write-Host 'PREFIX-LOCKED: OK' }
            } else {
                Write-Host 'SKIP: target has no base-context.md yet - edit it, then run check-parcel-prefix -Sync'
            }
        } elseif ($hasBaseContext -and (Test-Path $prefixScript)) {
            & $shellExe -NoProfile -File $prefixScript | Out-Host
            if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: check-parcel-prefix (check-only)'; $ok = $false }
            else { Write-Host 'PREFIX-LOCKED: OK' }
        } else {
            Write-Host 'SKIP: prefix check not applicable (no base-context.md or prefix script)'
        }
        $utf8Script = Join-Path $TgtRoot 'scripts/check-utf8-agents.ps1'
        if (Test-Path $utf8Script) {
            & $shellExe -NoProfile -File $utf8Script | Out-Host
            if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: check-utf8-agents'; $ok = $false }
            else { Write-Host 'UTF-8: OK' }
        } else {
            Write-Host 'VERIFY FAILED: check-utf8-agents.ps1 missing (machinery not materialised?)'; $ok = $false
        }
        if (Test-Path (Join-Path $TgtRoot 'scripts/wiki_lint.py')) {
            # A fresh satellite has no wiki content yet - the synced structure manifest
            # declares anchors that cannot exist, so linting there is a false positive.
            if (Test-Path (Join-Path $TgtRoot '.wiki/core')) {
                & python (Join-Path $TgtRoot 'scripts/wiki_lint.py') --quiet | Out-Host
                if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: wiki_lint'; $ok = $false }
                else { Write-Host 'WIKI LINT: OK' }
            } else {
                Write-Host 'SKIP: wiki lint not applicable yet (no .wiki/core content)'
            }
        } else {
            Write-Host 'SKIP: wiki_lint.py missing (machinery not materialised?)'
        }
        return $ok
    } finally {
        Pop-Location
    }
}

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

    $script:verdicts = @()
    function Add-Verdict {
        param($Kind, $Name, $Verdict, $Detail)
        $script:verdicts += [pscustomobject]@{ Kind = $Kind; Item = $Name; Verdict = $Verdict; Detail = $Detail }
    }

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

    function Compare-Item {
        param($Kind, $Name, $SrcPath, $TgtPath, [string[]]$IgnoreInTarget)
        if (-not (Test-Path $SrcPath)) { Add-Verdict $Kind $Name 'SOURCE-ABSENT' 'manifest lists it, source missing'; return }
        if (-not (Test-Path $TgtPath)) { Add-Verdict $Kind $Name 'MISSING' 'first-time install'; return }
        $sh = Get-ItemHashes $SrcPath
        $th = Get-ItemHashes $TgtPath
        # A retired file lingering in the target is reported separately as PRUNE. Strip it
        # from the target hash map so it does not also make the parent directory look
        # DRIFT ("locally customized") when the dir's live content actually matches upstream.
        # Only the target is stripped: a prune path present in the source would be a manifest
        # bug and should still surface as a directory difference.
        if ($IgnoreInTarget) { foreach ($i in $IgnoreInTarget) { [void]$th.Remove($i) } }
        $equal = ($sh.Count -eq $th.Count)
        if ($equal) {
            foreach ($k in $sh.Keys) { if (-not $th.ContainsKey($k) -or $th[$k] -ne $sh[$k]) { $equal = $false; break } }
        }
        if ($equal) { Add-Verdict $Kind $Name 'CURRENT' ''; return }
        if ($Kind -eq 'skill') {
            $sv = Get-FrontmatterVersion (Join-Path $SrcPath 'SKILL.md')
            $tv = Get-FrontmatterVersion (Join-Path $TgtPath 'SKILL.md')
            if ($null -ne $sv -and $null -ne $tv -and $tv -lt $sv) {
                Add-Verdict $Kind $Name 'UPGRADE' "v$tv -> v$sv"
            } else {
                Add-Verdict $Kind $Name 'DRIFT' "target v$tv vs source v$sv (locally customized?)"
            }
        } else {
            if ($null -eq $tgtMachV -or [string]$tgtMachV -ne [string]$srcMachV) {
                Add-Verdict $Kind $Name 'UPGRADE' 'machinery-version differs'
            } else {
                Add-Verdict $Kind $Name 'DRIFT' 'hashes differ at same machinery-version'
            }
        }
    }

    $prunePaths = @($manifest['prune_files'] | ForEach-Object { $_.Replace('\','/') })
    foreach ($dir in $manifest['portable_dirs']) {
        $dirPrefix = $dir.TrimEnd('/') + '/'
        $ignore = @($prunePaths | Where-Object { $_.StartsWith($dirPrefix) } | ForEach-Object { $_.Substring($dirPrefix.Length) })
        Compare-Item 'dir' $dir (Join-Path $srcRoot $dir) (Join-Path $tgtRoot $dir) $ignore
    }
    foreach ($slug in $portableSkills) { Compare-Item 'skill' $slug (Join-Path $srcRoot ".devops/skills/$slug") (Join-Path $tgtRoot ".devops/skills/$slug") }
    foreach ($file in $manifest['portable_files']) { Compare-Item 'file' $file (Join-Path $srcRoot $file) (Join-Path $tgtRoot $file) }
    foreach ($pf in $manifest['prune_files']) {
        if (Test-Path (Join-Path $tgtRoot $pf)) {
            Add-Verdict 'prune' $pf 'PRUNE' 'redundant file present in target; sync will delete it'
        }
    }

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

# 3b. Prune redundant files from the target (files retired upstream).
foreach ($pf in $manifest['prune_files']) {
    $tp = Join-Path $tgtRoot $pf
    if (Test-Path $tp) {
        if ($DryRun) {
            Write-Output "DRYRUN would prune $pf"
        } else {
            Remove-Item $tp -Force
            Write-Output "PRUNED $pf"
        }
    }
}

# 3c. Stamp the target's manifest with the source machinery-version (post-sync bookkeeping).
Update-TargetManifestVersion -TgtRoot $tgtRoot -SrcRoot $srcRoot -Version $scalars['machinery-version'] -DryRun:$DryRun

# 3d. Force-propagate the source Model Registry into the target's binding surfaces
# (registry rows + agent frontmatter + opencode.json model values). Must run BEFORE the
# PREFIX-LOCKED regeneration below, so the regenerated orchestrator prefixes inline the
# stamped registry rather than a stale one.
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