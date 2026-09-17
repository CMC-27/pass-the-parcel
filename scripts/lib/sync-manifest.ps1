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
        if ($null -eq $tgtMachV -or [string]$tgtMachV -ne [string]$srcMachV) {
            Add-Verdict $Kind $Name 'UPGRADE' 'machinery-version differs'
        } else {
            Add-Verdict $Kind $Name 'DRIFT' 'hashes differ at same machinery-version'
        }
    }
}
