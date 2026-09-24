# sync-manifest.ps1 — manifest read, hashing and the compare/verdict emitters.
# Dot-sourced by scripts/sync-architecture.ps1 (see scripts/lib/README.md). Portable:
# every module is declared in .devops/sync-manifest.yaml portable_files.

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
    # Dotted-tolerant: the tiered scheme is major.minor.patch. Returned as a STRING - a
    # [int] cast would truncate 1.0.73 to 1 and make the ordering check lie.
    foreach ($line in Get-Content $mp) {
        if ($line -match '^machinery-version:\s*(\d+(?:\.\d+)*)') { return $Matches[1] }
    }
    return $null
}

function Get-VersionShape {
    # 'dotted' (major.minor[.patch]) / 'integer' / 'absent' / 'malformed'. The SHAPE, not the
    # magnitude, decides comparability: the tiered lineage crosses a boundary once
    # (integer 73 -> 1.0.73), and a numeric comparison across that crossing is meaningless
    # (73 > 1.0.73). Callers halt-and-reconcile on 'migration' instead of guessing.
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return 'absent' }
    if ($Value -notmatch '^\d+(\.\d+)*$') { return 'malformed' }
    if ($Value -match '\.') { return 'dotted' }
    return 'integer'
}

function Compare-MachineryVersion {
    # Ordering-aware comparison of two machinery-version values. Returns one of:
    #   'absent'    - target carries no value (first install)
    #   'equal'     - same value
    #   'behind'    - target older than source -> UPGRADE (pull)
    #   'ahead'     - target newer than source -> AHEAD (halt-and-reconcile; NEVER a silent rewind)
    #   'migration' - shapes differ, or a value is unparsable -> halt-and-reconcile
    # Only same-shape values are ordered numerically; a shape crossing is never ordered.
    param([string]$Target, [string]$Source)
    $ts = Get-VersionShape $Target
    if ($ts -eq 'absent') { return 'absent' }
    $ss = Get-VersionShape $Source
    if ($ts -eq 'malformed' -or $ss -eq 'malformed' -or $ts -ne $ss) { return 'migration' }
    $t = @($Target -split '\.' | ForEach-Object { [int]$_ })
    $s = @($Source -split '\.' | ForEach-Object { [int]$_ })
    $n = [Math]::Max($t.Count, $s.Count)
    for ($i = 0; $i -lt $n; $i++) {
        $tv = if ($i -lt $t.Count) { $t[$i] } else { 0 }
        $sv = if ($i -lt $s.Count) { $s[$i] } else { 0 }
        if ($tv -lt $sv) { return 'behind' }
        if ($tv -gt $sv) { return 'ahead' }
    }
    return 'equal'
}

function Update-TargetManifestVersion {
    # Post-sync bookkeeping: stamp the target's own sync-manifest.yaml with the source
    # machinery-version so -Check classifies the target as CURRENT instead of reporting a
    # phantom UPGRADE forever. The manifest is not on the portable surface (satellites may
    # carry target-local notes in it), so only the version line is rewritten in place; a
    # missing manifest (first-time install) is seeded verbatim from the source.
    # Ordering guard: the CALLER (sync-architecture.ps1) pre-flights the counter and halts
    # before any write when the target is ahead of, or shape-incompatible with, the source,
    # so this stamp only ever moves a target FORWARD - never a silent rewind.
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
    if ($raw -match '(?m)^machinery-version:\s*(\d+(?:\.\d+)*)') {
        if ($Matches[1] -eq $Version) { return }
        if ($DryRun) { Write-Output "DRYRUN would bump machinery-version $($Matches[1]) -> $Version"; return }
        $raw = [regex]::Replace($raw, '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $Version")
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
        try { ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text)))).Replace('-','') } finally { $sha.Dispose() }
    }
    # -Force on the provider side: on Unix, dot-prefixed names are hidden and
    # Get-Item/Get-ChildItem ignore hidden items by default. .vscode is the only
    # portable-surface leaf that is dot-prefixed (.wiki/rules, .devops/agents, ...
    # end in visible names), so without -Force -Check dies on it under Linux/pwsh —
    # the "Could not find item .../.vscode" crash that reddens the CI self-test.
    # .NET enumeration replaces `Get-ChildItem -Force -Recurse -File`: the provider
    # materialises a FileInfo per entry, which dominates -Check over a large
    # machinery tree on PS 5.1, and it includes dot-prefixed entries anyway.
    if ([System.IO.Directory]::Exists($Path)) {
        $base = $Path.TrimEnd('\', '/')
        foreach ($file in [System.IO.Directory]::EnumerateFiles($Path, '*', [System.IO.SearchOption]::AllDirectories)) {
            $map[$file.Substring($base.Length + 1).Replace('\','/')] = Hash-Normalized $file
        }
    } else {
        $map[(Split-Path -Leaf $Path)] = Hash-Normalized $Path
    }
    return $map
}

$script:verdicts = @()
function Add-Verdict {
    param($Kind, $Name, $Verdict, $Detail)
    $script:verdicts += [pscustomobject]@{ Kind = $Kind; Item = $Name; Verdict = $Verdict; Detail = $Detail }
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
        # Ordering-aware: 'behind'/'absent' -> UPGRADE (pull); 'ahead' -> AHEAD and
        # 'migration' -> MIGRATION (both halt-and-reconcile); equal values with differing
        # hashes stay DRIFT (locally customized at the same counter).
        $cmp = Compare-MachineryVersion ([string]$tgtMachV) ([string]$srcMachV)
        if ($cmp -eq 'ahead') {
            Add-Verdict $Kind $Name 'AHEAD' 'target ahead of source machinery-version'
        } elseif ($cmp -eq 'migration') {
            Add-Verdict $Kind $Name 'MIGRATION' 'machinery-version lineage shape differs'
        } elseif ($cmp -eq 'behind' -or $cmp -eq 'absent') {
            Add-Verdict $Kind $Name 'UPGRADE' 'target behind source machinery-version'
        } else {
            Add-Verdict $Kind $Name 'DRIFT' 'hashes differ at same machinery-version'
        }
    }
}
