# sync-prefix.ps1 — PREFIX-LOCKED prefix regeneration, extracted from the verification gate so
# the prefix seam has one home. -Regen rewrites each agent's prefix from the TARGET's own
# base-context.md; without it the check runs check-only and never writes.
# Dot-sourced by scripts/sync-architecture.ps1 (see scripts/lib/README.md). Portable.

function Invoke-TargetPrefixGate {
    # Returns $true on pass, $false on a failed check, $null when not applicable (skip).
    param([string]$TgtRoot, [string]$ShellExe, [switch]$Regen)
    $hasBaseContext = Test-Path (Join-Path $TgtRoot '.opencode/plans/base-context.md')
    $prefixScript = Join-Path $TgtRoot 'scripts/check-parcel-prefix.ps1'
    if ($Regen) {
        if ($hasBaseContext) {
            Write-Host "Regenerating PREFIX-LOCKED prefixes from target base-context..."
            & $ShellExe -NoProfile -File $prefixScript -Sync | Out-Host
            if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: check-parcel-prefix'; return $false }
            Write-Host 'PREFIX-LOCKED: OK'
            return $true
        }
        Write-Host 'SKIP: target has no base-context.md yet - edit it, then run check-parcel-prefix -Sync'
        return $null
    }
    if ($hasBaseContext -and (Test-Path $prefixScript)) {
        & $ShellExe -NoProfile -File $prefixScript | Out-Host
        if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: check-parcel-prefix (check-only)'; return $false }
        Write-Host 'PREFIX-LOCKED: OK'
        return $true
    }
    Write-Host 'SKIP: prefix check not applicable (no base-context.md or prefix script)'
    return $null
}
