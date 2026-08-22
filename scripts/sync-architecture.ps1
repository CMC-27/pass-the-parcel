param(
    [string]$Source = "",
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [switch]$NoVerify,
    [switch]$DryRun
)

<#
.SYNOPSIS
    Materialises the transportable architecture layer from the template repo into a satellite repo.

.DESCRIPTION
    The parcel/wiki architecture is engineered to be transportable between workspaces. The
    portable surface is declared in .devops/sync-manifest.yaml:

        portable_dirs:     directories copied recursively (overwrite) into the target
        portable_skills:   skill slugs copied from .devops/skills/ (overwrite that skill)
        portable_files:    standalone files copied verbatim into the target
        verify_commands:   commands run in the target after sync to prove integrity

    The repo-specific surface is NOT copied: base-context.md, opencode.json, AGENTS.md and the
    wiki content itself embed the target's own layout, task lookup and permissions. After the
    portable surface is copied, the script regenerates each agent's PREFIX-LOCKED prefix from
    the TARGET's own .opencode/plans/base-context.md so the cache anchor always matches the
    local workspace.

.NOTES
    Usage:
        powershell -File scripts\sync-architecture.ps1 -Target C:\path\to\satellite
        powershell -File scripts\sync-architecture.ps1 -Target C:\path\ -DryRun
#>

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot
$src = if ($Source) { $Source } else { $here }

if (-not (Test-Path $src)) { throw "Source repo not found: $src" }
if (-not (Test-Path $Target)) { throw "Target repo not found: $Target" }

$srcRoot = (Resolve-Path $src).Path
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
        Copy-Item $s $t -Recurse -Force
        Write-Output "COPIED $dir"
    }
    $copied++
}

# 2. Portable skills (copy each skill folder into the target's .devops/skills/).
foreach ($slug in $manifest['portable_skills']) {
    $s = Join-Path $srcRoot ".devops\skills\$slug"
    if (-not (Test-Path $s)) { $skipped += "missing in source: skills/$slug"; continue }
    $t = Join-Path $tgtRoot ".devops\skills\$slug"
    if ($DryRun) {
        $n = (Get-ChildItem $s -Recurse -File).Count
        Write-Output "DRYRUN would copy skill $slug ($n files)"
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path $t) | Out-Null
        Copy-Item $s $t -Recurse -Force
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
Write-Output "Sync complete. $copied items materialised into $tgtRoot"
Write-Output "Next: update $tgtRoot\.opencode\plans\base-context.md + opencode.json + AGENTS.md to the target layout."