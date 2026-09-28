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
                            every folder in .devops/skills minus this exclusion list, then
                            intersected with core_skills when the target is profile: CORE)
        portable_files:     standalone files copied verbatim into the target
        prune_files:        files deleted from the target if present (retired upstream)
        prune_dirs:         directories deleted from the target if present, recursively
                            (retired skill folders; portable skills are derived, so a
                            removed folder is otherwise never compared and never deleted)
        machinery-version:  the transport set version (major.minor.patch, dotted-tolerant);
                            the comparison is ORDERING-AWARE - behind -> UPGRADE, ahead ->
                            AHEAD and a lineage shape crossing -> MIGRATION (both halt-and-
                            reconcile). Drives UPGRADE vs DRIFT classification for non-skill items
        profile:            the skill tier THIS repo carries - FULL (default: every skill) or
                            CORE (the pipeline set). A satellite declares CORE in its own copy
                            of the manifest; the sync reads it from the TARGET, falling back to
                            the source's value, so a satellite that has never set the key is
                            unchanged. An unrecognised value HALTS before anything is written.
        core_skills:        the CORE membership - template-published DATA read from the SOURCE,
                            never from the target (measured from the plan record; the manifest
                            header cites the evidence). A skill the measurement cannot see is
                            CORE-excluded by default, and the opt-in is profile: FULL.

    PROFILE-AWARE COMPARISON: the effective skill set is derived in exactly one place
    (Get-SkillTier, scripts/lib/sync-manifest.ps1) - the source's skills minus excluded_skills,
    intersected with core_skills when the target declares CORE. -Check and the copy path both
    consume that one set, so an un-installed tiered-out skill is never MISSING (it is simply
    not compared), while a tiered-out skill PRESENT in a CORE target reports PRUNE and is
    deleted by a sync - the existing prune mechanism, so a downgrade is reversible by
    declaring FULL again (purely additive). Directories and standalone files are not tiered.

    -Check compares source vs target per manifest item (SHA256 per file + version metadata)
    and prints a CURRENT/UPGRADE/AHEAD/MIGRATION/DRIFT/MISSING/PRUNE/SOURCE-ABSENT verdict
    table without writing. AHEAD and MIGRATION are halt-and-reconcile verdicts: an equality-only
    test cannot tell behind from ahead, which is how a target-ahead counter is silently rewound.
    A retired file still present in the target is a PRUNE verdict, and like every other
    non-CURRENT verdict it makes -Check exit 1. Prune files are excluded from their parent
    directory's comparison, so a lingering retired file surfaces as PRUNE rather than a
    misleading parent-dir DRIFT ("locally customized") when the live content matches upstream.
    A retired DIRECTORY (a `prune_dirs:` entry — a skill folder retired upstream) is reported
    by a direct existence test on the declared path, and sync deletes it recursively. That
    mask is not mirrored for directories: the folders this key retires sit under .devops/skills,
    which is compared per slug over the derived portable set and is not a portable_dirs root,
    so a mask branch could never fire for them.
    For the PREFIX-LOCKED agents (.devops/agents/parcel*.agent.md + ptp-*.subagent.md) only
    the agent-unique content is hashed: the prefix region is regenerated from each repo's
    own base-context.md after every sync, so it legitimately differs between source and
    target and must never mask a CURRENT verdict.

    After copying, the script stamps the TARGET's own .devops/sync-manifest.yaml with the
    source machinery-version (installing a copy of the manifest on first sync). Without
    this bookkeeping, -Check would report a phantom UPGRADE forever after every successful
    sync, because the manifest itself is not on the portable surface. Before writing anything
    it pre-flights the counter ordering and HALTS when the target is ahead of, or
    shape-incompatible with, the source - a target-ahead counter is never silently rewound;
    the reconcile recipe is printed and the operator writes the value by hand.

    It also reconciles the source capability-class registry into the target and STRIPS
    every concrete model binding from it (T1-E1.04 - the invariant is now absence). No agent
    declares a model; every agent inherits the model selected in the CLI / picker. The
    target's registry table is REWRITTEN to the two-cell shape, rows are INSERTED for keys
    the source added, and rows are DELETED for keys the source retired, so template-side
    registry growth and retirement both reach an already-bootstrapped satellite. Any
    `model:` line in a target agent file's frontmatter is REMOVED, and any
    agent.<key>.model member in the target's opencode.json is REMOVED (the strip is
    JSON-validated and reverted rather than left unparsable). The same in-place edit also
    MIGRATES the target's `skills` key to the V2-native flat array (carrying the path entries
    the satellite declared, verbatim) and DELETES the config member V2 accepts but does not
    load - a member delete root-scoped by brace depth and run under the same step-local
    re-parse-and-revert guard. A `skills` shape the migration cannot rewrite without
    destroying a declaration the satellite authored (e.g. a `urls` member) is REFUSED, left
    exactly as authored, and reported with a printed operator remedy. An entry for a registry key
    the target has NEVER authored is still INSERTED whole from the target's own synced seed
    (.devops/templates/opencode.template.json) - so a newly shipped agent arrives runnable
    instead of arriving as a file the runtime never mounts. A missing key therefore
    self-heals on a normal pull. BINDING-SKIP means neither the target nor the seed could
    supply an entry - still a loud failure in the target's own check-parcel-prefix.ps1 run.
    This runs BEFORE prefix regeneration.

    -SelfTest runs an end-to-end smoke test against a throwaway temp target: materialises
    the full portable surface, asserts every manifest dir/skill/file landed with matching
    content hashes and the target manifest version was stamped, then cleans up. Every child
    invocation it JUDGES goes through one process-level capture helper, so a non-zero child exit
    is echoed as `SELFTEST child failed:` carrying the child command, its exit code, its stdout
    and its stderr - never converted into a bare assertion about behaviour the harness never
    observed. Exit 0 = engine healthy. Use after editing this script or the manifest (CI runs
    it on every push).

    -Verify runs the verification stack against an already-materialised target WITHOUT
    copying anything: structural checks of the satellite-authored surface (AGENTS.md
    machinery markers, opencode.json wiring, base-context.md, wiki anchor, machinery
    presence, .ptp-source) plus the machinery gates (prefix check-only, UTF-8, wiki lint).
    Exit 0 = VERIFIED. Run after authoring the repo-specific files (bootstrap step 4).

    The repo-specific surface is NOT copied: base-context.md, opencode.json, AGENTS.md and the
    wiki content itself embed the target's own layout, task lookup and permissions. base-context.md
    and opencode.json ARE edited in place, but only to reconcile the capability-class registry
    rows, to REMOVE model bindings (registry row shape, agent frontmatter `model:` lines and
    agent.<key>.model members), to MIGRATE the `skills` key to the V2-native flat array and to
    DELETE the config member V2 accepts but does not load. Every one of those edits is
    step-local: a candidate is accepted only when BOTH the host's parse and a host-monotone
    shape scan accept it - a comma left dangling before a closing brace or bracket, or braces
    or brackets that do not balance, is rejected identically on every host - and is DISCARDED
    otherwise. The verdict therefore no longer depends on which host's parser runs, and a
    candidate a strict consumer would refuse can no longer be shipped by a lenient one. A
    `skills`
    shape the migration cannot rewrite without destroying a declaration the satellite authored
    is refused and reported with a printed remedy - the file's other formatting is always left
    as authored, never copied wholesale and never re-serialised. After the
    portable surface is copied, the script regenerates each agent's PREFIX-LOCKED prefix from
    the TARGET's own .opencode/plans/base-context.md so the cache anchor always matches the
    local workspace.

.NOTES
    Usage:
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/to/satellite
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/ -DryRun
        powershell -File scripts/sync-architecture.ps1 -Target C:/path/to/satellite -Verify
        powershell -File scripts/sync-architecture.ps1 -SelfTest

    Structure: this file is the entry point and the CLI. The engine itself is dot-sourced
    from scripts/lib/ (manifest, bindings, prune, prefix, verify); every module is declared
    in .devops/sync-manifest.yaml portable_files. See scripts/lib/README.md.
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

# --- engine modules: dot-sourced by explicit path, in dependency order ---------
# A partial split ships a satellite a broken engine, so every module is declared in
# .devops/sync-manifest.yaml portable_files and -SelfTest asserts the mirror.
$libRoot = Join-Path $PSScriptRoot 'lib'
. (Join-Path $libRoot 'sync-manifest.ps1')
. (Join-Path $libRoot 'sync-bindings.ps1')
. (Join-Path $libRoot 'sync-migrate.ps1')
. (Join-Path $libRoot 'sync-run.ps1')
. (Join-Path $libRoot 'sync-prune.ps1')
. (Join-Path $libRoot 'sync-prefix.ps1')
. (Join-Path $libRoot 'sync-verify.ps1')
. (Join-Path $libRoot 'sync-selftest.ps1')
. (Join-Path $libRoot 'sync-selftest-fixtures.ps1')


# --- self-test mode: the harness lives in scripts/lib/sync-selftest.ps1; it receives the
# ENTRY path explicitly (a dot-sourced module's own path is not the entry's) and scans
# itself for the F3 direct-child-launch check. ---
if ($SelfTest) {
    Invoke-EngineSelfTest -SrcRoot $srcRoot -EntryPath $PSCommandPath `
        -HarnessPath (Join-Path $libRoot 'sync-selftest.ps1') -ShellExe $shellExe
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

# --- verification helpers ---------------------------------------------------

# --- parse the manifest (single shared parser — see Read-Manifest) ---
$man = Read-Manifest $manifestPath
$manifest = $man.Lists
$scalars = $man.Scalars

# The effective portable skill surface - ONE derivation, profile-aware: the source's skills
# minus `excluded_skills`, intersected with `core_skills` when the target declares `profile:
# CORE`. It drives BOTH the -Check comparison and the copy loop, so the two cannot disagree.
$tier = Get-SkillTier -SrcRoot $srcRoot -TgtRoot $tgtRoot
$portableSkills = @($tier.Effective)
# The prune input: the manifest's retired paths PLUS the tier's tiered-out skill dirs, so a
# downgraded CORE target sheds them through the existing PRUNE mechanism (sync-prune.ps1
# untouched).
$pruneManifest = Get-EffectivePruneManifest -Manifest $manifest -Tier $tier

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
    # The drift report lives in scripts/lib/sync-run.ps1; it owns the -Check exit codes.
    Invoke-CheckReport -SrcRoot $srcRoot -TgtRoot $tgtRoot -Manifest $manifest `
        -PruneManifest $pruneManifest -PortableSkills $portableSkills -Scalars $scalars
}

# --- pre-flight: the counter ordering. A target AHEAD of, or shape-incompatible with, the
# source must halt BEFORE any write: the stamp pass would otherwise rewind a counter the
# target earned, and a partial pull is worse than none. The reconcile recipe is printed -
# the script never rewrites a counter it did not earn (GRID-Link 78 vs template 72).
$pfSrcV = $scalars['machinery-version']
$pfTgtV = Get-ManifestMachineVersion $tgtRoot
$pfCmp = Compare-MachineryVersion ([string]$pfTgtV) ([string]$pfSrcV)
if ($pfCmp -eq 'ahead' -or $pfCmp -eq 'migration') {
    Write-Output ""
    if ($pfCmp -eq 'ahead') {
        Write-Output "HALT: target machinery-version $pfTgtV is AHEAD of source $pfSrcV."
    } else {
        Write-Output "HALT: machinery-version lineage shape differs - target '$pfTgtV' vs source '$pfSrcV'."
    }
    Write-Output "Reconcile recipe (operator action):"
    Write-Output "  0. Commonest cause: the target bumped machinery-version itself. The counter is template-owned and sync-stamped - a satellite never bumps it, so a satellite-side increment is inert and must never be defended."
    Write-Output "  1. Confirm the target's .devops/logs/version-history.md records no release row in the diverged range"
    Write-Output "     (a rewound counter must not orphan a recorded release)."
    Write-Output "  2. Write 'machinery-version: $pfSrcV' into the target's .devops/sync-manifest.yaml by hand."
    Write-Output "  3. Re-run this sync. This run wrote nothing."
    exit 1
}

# 1-3b. The portable surface, then the prune plan - scripts/lib/sync-run.ps1.
$copyState = @{ Copied = 0; Skipped = @() }
Invoke-SurfaceCopy -SrcRoot $srcRoot -TgtRoot $tgtRoot -Manifest $manifest `
    -PortableSkills $portableSkills -PruneManifest $pruneManifest -DryRun:$DryRun -Result $copyState
$copied = $copyState.Copied
$skipped = $copyState.Skipped

# 3c. Stamp the target's manifest with the source machinery-version (post-sync bookkeeping).
Update-TargetManifestVersion -TgtRoot $tgtRoot -SrcRoot $srcRoot -Version $scalars['machinery-version'] -DryRun:$DryRun

# 3d. Reconcile the source capability-class registry into the target and STRIP every concrete
# model binding from it (registry rows + agent frontmatter + opencode.json). Must run BEFORE the
# PREFIX-LOCKED regeneration below, so the regenerated orchestrator prefixes inline the
# reconciled table rather than a stale one.
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
