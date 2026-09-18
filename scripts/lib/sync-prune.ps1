# sync-prune.ps1 — the prune plan (retirement transport). A path declared under
# `prune_files:` (a file) or `prune_dirs:` (a directory) in .devops/sync-manifest.yaml and
# present in the target is planned, named under -DryRun, and deleted on sync. Directories
# delete recursively — a non-empty directory defeats a flat delete.
#
# Why `prune_dirs` exists: portable skills are DERIVED (every folder in .devops/skills minus
# `excluded_skills`), so a retired skill folder is simply absent from the derived set — it is
# never compared, never copied and never deleted, and every already-synced satellite keeps a
# silent orphan. `prune_files` cannot express that (it is files-only and cannot remove a
# directory shell), and adding a retired slug to `excluded_skills` only narrows fresh syncs
# and produces NO verdict at all. One declarative line per retirement is the whole mechanism.
#
# Parent-dir prune mask: `prune_files` entries that sit inside a `portable_dirs` root
# or a portable skill are stripped from the target's hash map in -Check so a retired
# file reports PRUNE instead of a misleading parent-dir DRIFT. That mask is NOT
# mirrored for `prune_dirs`, and deliberately so: the directories this key retires
# sit under `.devops/skills`, which is compared per slug over the derived portable
# set and is not a `portable_dirs` root, so a mask branch could never fire for them.
# The direct existence test below is what reports a lingering retired folder —
# document the limitation instead of writing code that cannot run.
#
# Dot-sourced by scripts/sync-architecture.ps1 (see scripts/lib/README.md). Portable.

function Get-PrunePlan {
    # One existence test per declared prune path, so there is exactly one place that decides
    # what a prune is. Returns objects: @{ Path; Recurse; Kind }.
    param([string]$TgtRoot, $Manifest)
    $plan = @()
    foreach ($pf in @($Manifest['prune_files'])) {
        if (Test-Path (Join-Path $TgtRoot $pf)) {
            $plan += [pscustomobject]@{ Path = $pf; Recurse = $false; Kind = 'file' }
        }
    }
    foreach ($pd in @($Manifest['prune_dirs'])) {
        if (Test-Path (Join-Path $TgtRoot $pd)) {
            $plan += [pscustomobject]@{ Path = $pd; Recurse = $true; Kind = 'directory' }
        }
    }
    return $plan
}

function Test-PrunePresent {
    # -Check verdict: a lingering retired path is PRUNE, never a parent-dir DRIFT.
    param([string]$TgtRoot, $Manifest)
    foreach ($item in @(Get-PrunePlan -TgtRoot $TgtRoot -Manifest $Manifest)) {
        Add-Verdict 'prune' $item.Path 'PRUNE' "redundant $($item.Kind) present in target; sync will delete it"
    }
}

function Invoke-PrunePlan {
    # Names every planned prune under -DryRun; deletes otherwise.
    param([string]$TgtRoot, $Plan, [switch]$DryRun)
    foreach ($item in $Plan) {
        if ($DryRun) {
            Write-Output "DRYRUN would prune $($item.Path)"
        } else {
            Remove-Item (Join-Path $TgtRoot $item.Path) -Recurse:$item.Recurse -Force
            Write-Output "PRUNED $($item.Path)"
        }
    }
}
