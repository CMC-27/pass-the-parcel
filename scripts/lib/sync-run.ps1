# sync-run.ps1 — the two halves of a sync run that are not the manifest read, the bindings,
# the prune, the prefix gate or the verification stack: the profile-aware drift report
# (`-Check`) and the profile-aware surface copy (dirs, skills, files, then the prune plan).
#
# Extracted from the entry script by T1-E4.05. Both halves read ONE derived skill set
# (`Get-SkillTier`) and ONE prune manifest (`Get-EffectivePruneManifest`), both computed by
# the entry and passed in, so a second dialect of the tier rule cannot appear here.
#
# Results are reported through the caller's hashtable, never as a return value: every message
# in these functions is `Write-Output`, and a returned value would capture it. (`Invoke-CheckReport`
# does exit the process itself - it owns the `-Check` mode's exit-code contract, which is
# `0` IN SYNC / `1` OUT OF SYNC.)
#
# Dot-sourced by scripts/sync-architecture.ps1. Portable.

function Invoke-CheckReport {
    param(
        [string]$SrcRoot,
        [string]$TgtRoot,
        $Manifest,
        $PruneManifest,
        [string[]]$PortableSkills,
        $Scalars
    )
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

function Invoke-SurfaceCopy {
    # The portable surface, copied in manifest order: dirs, then the profile-aware skill set,
    # then standalone files - then the prune plan (retired files and directories). The caller
    # stamps the manifest, reconciles bindings and verifies afterwards; this function only
    # materialises and prunes.
    param(
        [string]$SrcRoot,
        [string]$TgtRoot,
        $Manifest,
        [string[]]$PortableSkills,
        $PruneManifest,
        [switch]$DryRun,
        [hashtable]$Result
    )
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
    $Result.Copied = $copied
    $Result.Skipped = $skipped
}
