param(
    [string]$Source = "",
    [switch]$Check,
    [switch]$DryRun,
    [switch]$Verify,
    [switch]$NoVerify
)

<#
.SYNOPSIS
    Satellite-side pull: refresh this workspace's .devops machinery from the template repo.

.DESCRIPTION
    Thin wrapper over the template repo's sync-architecture.ps1 (the push engine). Resolves a
    source (explicit -Source param > .ptp-source file in this repo root), caches git URLs under
    $env:USERPROFILE\.ptp\template, validates the source, then invokes sync-architecture.ps1
    with -Source <template> -Target <this repo>. Switches pass through: -Check (drift report,
    never writes), -DryRun (preview), -Verify (structural + gate verification, never writes),
    -NoVerify (skip post-sync verification).

    The first -Source value given is remembered in .ptp-source at this repo's root so future
    runs need no arguments.

.NOTES
    Usage:
        powershell -File scripts\pull-architecture.ps1 -Source https://github.com/you/template.git
        powershell -File scripts\pull-architecture.ps1 -Check
        powershell -File scripts\pull-architecture.ps1 -Verify
        powershell -File scripts\pull-architecture.ps1
#>

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $root '.ptp-source'

# 1. Resolve source: explicit param > .ptp-source > error.
if (-not $Source -and (Test-Path $sourceFile)) {
    $Source = (Get-Content $sourceFile -TotalCount 1).Trim()
}
if (-not $Source) {
    Write-Output "No source configured for this workspace."
    Write-Output "Run once with -Source <path-or-git-url>; it will be remembered in .ptp-source."
    Write-Output "Example: powershell -NoProfile -File scripts\pull-architecture.ps1 -Source https://github.com/you/pass-the-parcel.git"
    exit 2
}

$resolved = $Source
$isGitUrl = ($Source -match '^https?://' -or $Source -match '^git@' -or $Source -match '\.git$' -or $Source -match '://')

# 2. Git URLs -> cache under %USERPROFILE%\.ptp\template; local paths used directly.
if ($isGitUrl) {
    $cacheDir = Join-Path $env:USERPROFILE '.ptp\template'
    if (-not (Test-Path (Join-Path $cacheDir '.git'))) {
        New-Item -ItemType Directory -Force -Path (Split-Path $cacheDir) | Out-Null
        Write-Output "Cloning template repo into cache: $cacheDir"
        & git clone --depth 1 $Source $cacheDir
        if ($LASTEXITCODE -ne 0) { throw "git clone failed for $Source" }
    } else {
        Write-Output "Updating template cache: $cacheDir"
        & git -C $cacheDir pull --ff-only
        if ($LASTEXITCODE -ne 0) { throw "git pull --ff-only failed in $cacheDir (local changes in the cache? delete it and re-run)." }
    }
    $resolved = $cacheDir
}

if (-not (Test-Path $resolved)) { throw "Source path not found: $resolved" }
$resolved = (Resolve-Path $resolved).Path

# 3. Validate the source actually is a template repo.
$syncScript = Join-Path $resolved 'scripts\sync-architecture.ps1'
$manifest = Join-Path $resolved '.devops\sync-manifest.yaml'
if (-not (Test-Path $syncScript)) { throw "Not a template repo (missing scripts\sync-architecture.ps1): $resolved" }
if (-not (Test-Path $manifest)) { throw "Not a template repo (missing .devops\sync-manifest.yaml): $resolved" }

# 4. Remember an explicitly supplied source.
if ($PSBoundParameters.ContainsKey('Source')) {
    Set-Content -Path $sourceFile -Value $Source -Encoding UTF8
    Write-Output "Remembered source in .ptp-source : $Source"
}

$mode = if ($Check) { 'check (report only)' } elseif ($DryRun) { 'dry-run (no writes)' } elseif ($Verify) { 'verify (no writes)' } else { 'sync' }
Write-Output "Pulling architecture layer:"
Write-Output "  source : $resolved"
Write-Output "  target : $root"
Write-Output "  mode   : $mode"
Write-Output ""

# 5. Invoke the push engine against this repo, passing switches through.
$args = @('-NoProfile', '-File', $syncScript, '-Source', $resolved, '-Target', $root)
if ($Check) { $args += '-Check' }
if ($DryRun) { $args += '-DryRun' }
if ($Verify) { $args += '-Verify' }
if ($NoVerify) { $args += '-NoVerify' }
& powershell @args
exit $LASTEXITCODE
