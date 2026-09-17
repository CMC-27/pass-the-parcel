# sync-prune.ps1 — the prune plan (retirement transport). A path declared under
# `prune_files:` in .devops/sync-manifest.yaml and present in the target is planned,
# named under -DryRun, and deleted on sync. `prune_dirs:` (W8.1) mirrors the same plan
# for retired skill directories, recursively.
# Dot-sourced by scripts/sync-architecture.ps1 (see scripts/lib/README.md). Portable.

function Get-PrunePlan {
    # Existence test, once: every declared prune path present in the target.
    param([string]$TgtRoot, $Manifest)
    $plan = @()
    foreach ($pf in $Manifest['prune_files']) {
        if (Test-Path (Join-Path $TgtRoot $pf)) { $plan += $pf }
    }
    return $plan
}

function Test-PrunePresent {
    # -Check verdict: a lingering retired path is PRUNE, never a parent-dir DRIFT.
    param([string]$TgtRoot, $Manifest)
    foreach ($pf in @(Get-PrunePlan -TgtRoot $TgtRoot -Manifest $Manifest)) {
        Add-Verdict 'prune' $pf 'PRUNE' 'redundant file present in target; sync will delete it'
    }
}

function Invoke-PrunePlan {
    # Names every planned prune under -DryRun; deletes otherwise.
    param([string]$TgtRoot, [string[]]$Paths, [switch]$DryRun)
    foreach ($pf in $Paths) {
        if ($DryRun) {
            Write-Output "DRYRUN would prune $pf"
        } else {
            Remove-Item (Join-Path $TgtRoot $pf) -Force
            Write-Output "PRUNED $pf"
        }
    }
}
