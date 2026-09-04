param(
    [string]$Source = "",
    [string]$Target = "",
    [switch]$NoVerify,
    [switch]$DryRun,
    [switch]$Check,
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
    and prints a CURRENT/UPGRADE/DRIFT/MISSING/SOURCE-ABSENT verdict table without writing.

    -SelfTest runs an end-to-end smoke test against a throwaway temp target: materialises
    the full portable surface, asserts every manifest dir/skill/file landed with matching
    content hashes, then cleans up. Exit 0 = engine healthy. Use after editing this script
    or the manifest (CI runs it on every push).

    The repo-specific surface is NOT copied: base-context.md, opencode.json, AGENTS.md and the
    wiki content itself embed the target's own layout, task lookup and permissions. After the
    portable surface is copied, the script regenerates each agent's PREFIX-LOCKED prefix from
    the TARGET's own .opencode/plans/base-context.md so the cache anchor always matches the
    local workspace.

.NOTES
    Usage:
        powershell -File scripts\sync-architecture.ps1 -Target C:\path\to\satellite
        powershell -File scripts\sync-architecture.ps1 -Target C:\path\ -DryRun
        powershell -File scripts\sync-architecture.ps1 -SelfTest
#>

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot
$src = if ($Source) { $Source } else { $here }

if (-not (Test-Path $src)) { throw "Source repo not found: $src" }

$srcRoot = (Resolve-Path $src).Path

# --- self-test mode: build a throwaway satellite, sync into it, verify, tear down ---
if ($SelfTest) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-selftest-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        Write-Output "SELFTEST: temp target = $tmp"
        & powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify
        if ($LASTEXITCODE -ne 0) { throw "selftest: sync run failed (exit $LASTEXITCODE)" }
        # Manifest must parse identically inside the test process — re-parse here.
        $stManifestPath = Join-Path $srcRoot '.devops\sync-manifest.yaml'
        $stDirs = @(); $stFiles = @(); $stExcluded = @(); $stPrune = @(); $cur = $null
        foreach ($line in Get-Content $stManifestPath) {
            $t = $line.Trim()
            if (-not $t -or $t.StartsWith('#')) { continue }
            if ($t -match '^([a-z_-]+):\s*$') { $cur = $Matches[1]; continue }
            if ($t -match '^([a-z_-]+):\s*\[\s*\]\s*(?:#.*)?$') { if ($Matches[1] -eq 'excluded_skills') { $stExcluded = @() }; $cur = $null; continue }
            if ($t -match '^([a-z_-]+):\s+(.+)$') { $cur = $null; continue }
            if ($t.StartsWith('- ') -and $cur) {
                switch ($cur) {
                    'portable_dirs'  { $stDirs += $t.Substring(2).Trim().Trim('"') }
                    'portable_files' { $stFiles += $t.Substring(2).Trim().Trim('"') }
                    'prune_files'    { $stPrune += $t.Substring(2).Trim().Trim('"') }
                    'excluded_skills' { $stExcluded += $t.Substring(2).Trim().Trim('"') }
                }
            }
        }
        $skillsRoot = Join-Path $srcRoot '.devops\skills'
        $stSkills = @(Get-ChildItem $skillsRoot -Directory | ForEach-Object { $_.Name } | Where-Object { $stExcluded -notcontains $_ })
        $fail = @()
        function Assert-Mirror {
            param([string]$Rel)
            $sp = Join-Path $srcRoot $Rel
            $tp = Join-Path $tmp $Rel
            if (-not (Test-Path $tp)) { $script:fail += "missing in target: $Rel"; return }
            $sh = Get-ChildItem $sp -Recurse -File | ForEach-Object { $_.FullName.Substring($sp.Length) } | Sort-Object
            $th = Get-ChildItem $tp -Recurse -File | ForEach-Object { $_.FullName.Substring($tp.Length) } | Sort-Object
            if (($sh -join '|') -ne ($th -join '|')) { $script:fail += "file set differs: $Rel" }
        }
        foreach ($d in $stDirs) { Assert-Mirror $d }
        foreach ($s in $stSkills) { Assert-Mirror ".devops\skills\$s" }
        foreach ($f in $stFiles) { Assert-Mirror $f }
        # Guard the historical Copy-Item nesting defect: no doubled directory names.
        $nested = Get-ChildItem $tmp -Recurse -Directory | Where-Object { $_.FullName -match '\\(\.wiki|\.devops)\\\1|\\skills\\([^\\]+)\\\2' }
        if ($nested) { $fail += "nested-copy defect: $($nested.FullName -join ', ')" }
        # Prune test: plant a stale file, re-sync, assert it is removed.
        if ($stPrune.Count -gt 0) {
            $stale = Join-Path $tmp $stPrune[0]
            New-Item -ItemType Directory -Force -Path (Split-Path $stale) | Out-Null
            Set-Content -Path $stale -Value "stale" -NoNewline
            & powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Target $tmp -NoVerify
            if ($LASTEXITCODE -ne 0) { throw "selftest: prune re-sync failed (exit $LASTEXITCODE)" }
            if (Test-Path $stale) { $fail += "prune failed: $($stPrune[0]) still present after re-sync" }
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

$manifestPath = Join-Path $srcRoot '.devops\sync-manifest.yaml'
if (-not (Test-Path $manifestPath)) { throw "Manifest not found: $manifestPath" }

Write-Output "Syncing architecture layer:"
Write-Output "  source : $srcRoot"
Write-Output "  target : $tgtRoot"
Write-Output "  manifest: $manifestPath"
Write-Output ""

# Parse the manifest (simple YAML subset - key: - item lines).
$manifest = [ordered]@{}
$currentKey = $null
foreach ($line in Get-Content $manifestPath) {
    $t = $line.Trim()
    if (-not $t -or $t.StartsWith('#')) { continue }
    if ($t -match '^([a-z_]+):\s*$') {
        $currentKey = $Matches[1]
        $manifest[$currentKey] = @()
    } elseif ($t.StartsWith('- ') -and $currentKey) {
        $manifest[$currentKey] += $t.Substring(2).Trim().Trim('"')
    }
}

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
    $mp = Join-Path $Root '.devops\sync-manifest.yaml'
    if (-not (Test-Path $mp)) { return $null }
    foreach ($line in Get-Content $mp) {
        if ($line -match '^machinery-version:\s*(\d+)') { return [int]$Matches[1] }
    }
    return $null
}

function Get-ItemHashes {
    param([string]$Path)
    $map = @{}
    function Hash-Normalized {
        param([string]$File)
        # Normalize CRLF -> LF before hashing: git smudge filters (core.autocrlf /
        # eol=lf in .gitattributes) materialize LF blobs as CRLF on Windows, so raw
        # byte hashes would report false DRIFT after any checkout.
        $bytes = [System.IO.File]::ReadAllBytes($File)
        $text = [System.Text.Encoding]::UTF8.GetString($bytes) -replace "`r`n", "`n"
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try { ($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text)) | ForEach-Object { $_.ToString('X2') }) -join '' } finally { $sha.Dispose() }
    }
    if ((Get-Item $Path).PSIsContainer) {
        Get-ChildItem $Path -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($Path.TrimEnd('\').Length + 1)
            $map[$rel] = Hash-Normalized $_.FullName
        }
    } else {
        $map[(Split-Path -Leaf $Path)] = Hash-Normalized $Path
    }
    return $map
}

# --- parse the manifest (simple YAML subset - key: / - item lines; scalars supported) ---
$manifest = [ordered]@{}
$scalars = [ordered]@{}
$currentKey = $null
foreach ($line in Get-Content $manifestPath) {
    $t = $line.Trim()
    if (-not $t -or $t.StartsWith('#')) { continue }
    if ($t -match '^([a-z_-]+):\s+(.+)$') {
        $scalars[$Matches[1]] = $Matches[2].Trim().Trim('"')
        $currentKey = $null
    } elseif ($t -match '^([a-z_-]+):\s*$') {
        $currentKey = $Matches[1]
        $manifest[$currentKey] = @()
    } elseif ($t -match '^([a-z_-]+):\s*\[\s*\]\s*(?:#.*)?$') {
        $manifest[$Matches[1]] = @()
        $currentKey = $null
    } elseif ($t.StartsWith('- ') -and $currentKey) {
        $manifest[$currentKey] += $t.Substring(2).Trim().Trim('"')
    }
}

# Derive the portable skill surface: all skills minus excluded_skills.
$skillsRoot = Join-Path $srcRoot '.devops\skills'
$allSkills = @(Get-ChildItem $skillsRoot -Directory | ForEach-Object { $_.Name })
$excluded = @($manifest['excluded_skills'])
$portableSkills = @($allSkills | Where-Object { $excluded -notcontains $_ })

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
        param($Kind, $Name, $SrcPath, $TgtPath)
        if (-not (Test-Path $SrcPath)) { Add-Verdict $Kind $Name 'SOURCE-ABSENT' 'manifest lists it, source missing'; return }
        if (-not (Test-Path $TgtPath)) { Add-Verdict $Kind $Name 'MISSING' 'first-time install'; return }
        $sh = Get-ItemHashes $SrcPath
        $th = Get-ItemHashes $TgtPath
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

    foreach ($dir in $manifest['portable_dirs']) { Compare-Item 'dir' $dir (Join-Path $srcRoot $dir) (Join-Path $tgtRoot $dir) }
    foreach ($slug in $portableSkills) { Compare-Item 'skill' $slug (Join-Path $srcRoot ".devops\skills\$slug") (Join-Path $tgtRoot ".devops\skills\$slug") }
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
    foreach ($b in @('UPGRADE', 'DRIFT', 'MISSING', 'SOURCE-ABSENT')) { $bad += [int]$counts[$b] }
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
    $s = Join-Path $srcRoot ".devops\skills\$slug"
    if (-not (Test-Path $s)) { $skipped += "missing in source: skills/$slug"; continue }
    $t = Join-Path $tgtRoot ".devops\skills\$slug"
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
Push-Location $tgtRoot
try {
    if (Test-Path "$tgtRoot\.opencode\plans\base-context.md") {
        Write-Output "Regenerating PREFIX-LOCKED prefixes from target base-context..."
        & powershell -NoProfile -File "$tgtRoot\scripts\check-parcel-prefix.ps1" -Sync
        if ($LASTEXITCODE -ne 0) { Write-Output "VERIFY FAILED: check-parcel-prefix"; Pop-Location; exit 1 }
        Write-Output "PREFIX-LOCKED: OK"
    } else {
        Write-Output "SKIP: target has no base-context.md yet - edit it, then run check-parcel-prefix -Sync"
    }
    & powershell -NoProfile -File "$tgtRoot\scripts\check-utf8-agents.ps1"
    if ($LASTEXITCODE -ne 0) { Write-Output "VERIFY FAILED: check-utf8-agents"; Pop-Location; exit 1 }
    Write-Output "UTF-8: OK"
    if (Test-Path "$tgtRoot\scripts\wiki_lint.py") {
        & python "$tgtRoot\scripts\wiki_lint.py" --quiet
        if ($LASTEXITCODE -ne 0) { Write-Output "VERIFY FAILED: wiki_lint"; Pop-Location; exit 1 }
        Write-Output "WIKI LINT: OK"
    }
} finally {
    Pop-Location
}

Write-Output ""
if ($scalars['machinery-version']) { Write-Output "machinery-version: $($scalars['machinery-version']) materialised" }
Write-Output "Sync complete. $copied items materialised into $tgtRoot"
Write-Output "Next: update $tgtRoot\.opencode\plans\base-context.md + opencode.json + AGENTS.md to the target layout."