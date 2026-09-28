# sync-selftest-fixtures.ps1 — the capability fixture families of the `-SelfTest` harness:
# retirement transport (T1-E2.07), the ordering-aware counter (T1-E2.08), the claims smoke,
# the skill tier (T3-E1.04) and the `opencode.json` key-shape migration (T1-E1.05).
#
# Each family was added by the parcel that added the behaviour it guards, and they run in the
# order they were added against the ONE throwaway target the harness materialises - so the
# sequence, and therefore each family's starting state, is exactly what it was when the whole
# harness lived in the entry script. Findings accumulate in the harness's own `$script:fail`
# list (dot-sourcing shares the entry's script scope), which is why the bodies read
# `$script:fail +=` where they once read `$fail +=`.
#
# Moved out of the entry script by T1-E4.05. Portable; declared in .devops/sync-manifest.yaml
# portable_files.

function Invoke-EngineFixtureFamilies {
    param(
        [string]$Tmp,
        [string]$SrcRoot,
        [string]$EntryPath,
        [string]$StManifestPath,
        [string[]]$StSkills,
        [hashtable]$StMan,
        [hashtable]$StSrcRegistry
    )

        # --- T1-E2.07 fixture: retirement transport (registry prune + skill prune mask + structural task stamp)
        # Plant the three pre-retirement states GRID-Link carried at the 54 -> 59 pull,
        # then assert one sync converges all three: the orphan registry row is pruned
        # (F1), the stale skill-internal file reports PRUNE and never a skill DRIFT (F2),
        # and the old parcel-sprint task allow-list is stamped from the seed (F3).
        $rtBcDir = Join-Path $tmp '.opencode/plans'
        New-Item -ItemType Directory -Force -Path $rtBcDir | Out-Null
        Copy-Item (Join-Path $srcRoot '.opencode/plans/base-context.md') (Join-Path $tmp '.opencode/plans/base-context.md') -Force
        $rtBc = Join-Path $tmp '.opencode/plans/base-context.md'
        $rtBcRaw = [System.IO.File]::ReadAllText($rtBc)
        if ($rtBcRaw -match '\| parcel-fast \|') {
            $script:fail += "selftest T1-E2.07: target already carries a parcel-fast row; fixture not isolated"
        } else {
            $rtBcEol = if ($rtBcRaw -match "`r`n") { "`r`n" } else { "`n" }
            $rtBcRaw = $rtBcRaw.TrimEnd("`r", "`n") + $rtBcEol + "| parcel-fast | orchestration |" + $rtBcEol
            [System.IO.File]::WriteAllText($rtBc, $rtBcRaw, (New-Object System.Text.UTF8Encoding($false)))
            Write-Output "SELFTEST fixture: orphan registry row 'parcel-fast' planted"
        }
        $rtStaleSkill = Join-Path $tmp '.devops/skills/wiki-bootstrap/references/qa-14-testing-standards.md'
        New-Item -ItemType Directory -Force -Path (Split-Path $rtStaleSkill) | Out-Null
        Set-Content -Path $rtStaleSkill -Value "stale" -NoNewline
        Write-Output "SELFTEST fixture: stale skill-internal file planted"
        $rtOcPath = Join-Path $tmp 'opencode.json'
        $rtOcRaw = [System.IO.File]::ReadAllText($rtOcPath)
        $rtPsM = [regex]::Match($rtOcRaw, '"parcel-sprint"\s*:\s*\{')
        if (-not $rtPsM.Success) {
            $script:fail += "selftest T1-E2.07: parcel-sprint entry missing from target opencode.json"
        } else {
            $rtPsOpen = $rtOcRaw.IndexOf('{', $rtPsM.Index); $rtPsClose = Find-MatchingBrace $rtOcRaw $rtPsOpen
            $rtPsBlock = $rtOcRaw.Substring($rtPsOpen, $rtPsClose - $rtPsOpen + 1)
            if ($rtPsBlock -notmatch '"wiki-writer":\s*"allow"') {
                $script:fail += "selftest T1-E2.07: target parcel-sprint already lacks wiki-writer; fixture not isolated"
            } else {
                $rtPsNew = $rtPsBlock -replace ',\s*"wiki-writer":\s*"allow"', ''
                $rtOcRaw = $rtOcRaw.Remove($rtPsOpen, $rtPsClose - $rtPsOpen + 1).Insert($rtPsOpen, $rtPsNew)
                [System.IO.File]::WriteAllText($rtOcPath, $rtOcRaw, (New-Object System.Text.UTF8Encoding($false)))
                Write-Output "SELFTEST fixture: parcel-sprint task allow-list aged (wiki-writer removed)"
            }
        }
        $stOutRtRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
        $stOutRt = $stOutRtRec.Combined
        if ($stOutRtRec.ExitCode -eq 0) { $script:fail += "selftest T1-E2.07: -Check reported IN SYNC with retirement states planted (exit 0)" }
        if (-not ($stOutRt -match 'PRUNE')) { $script:fail += "selftest T1-E2.07: -Check did not report PRUNE for the stale skill-internal file" }
        if ($stOutRt -match 'DRIFT') { $script:fail += "selftest T1-E2.07: -Check reported DRIFT instead of PRUNE for a retired skill-internal file" }
        if (-not ($stOutRt -match 'skill\s+wiki-bootstrap\s+CURRENT')) { $script:fail += "selftest T1-E2.07: wiki-bootstrap skill did not report CURRENT beside its PRUNE" }
        $stRtSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
        if ($stRtSync.ExitCode -ne 0) { throw "selftest T1-E2.07: convergence re-sync failed (exit $($stRtSync.ExitCode))" }
        if ([System.IO.File]::ReadAllText($rtBc) -match '\| parcel-fast \|') { $script:fail += "selftest T1-E2.07: orphan registry row survived the sync (F1 delete pass failed)" }
        if (Test-Path $rtStaleSkill) { $script:fail += "selftest T1-E2.07: stale skill-internal file survived the sync (F2 prune failed)" }
        $rtOcAfter = [System.IO.File]::ReadAllText($rtOcPath)
        $rtPsM2 = [regex]::Match($rtOcAfter, '"parcel-sprint"\s*:\s*\{')
        $rtPs2Open = $rtOcAfter.IndexOf('{', $rtPsM2.Index); $rtPs2Close = Find-MatchingBrace $rtOcAfter $rtPs2Open
        if ($rtOcAfter.Substring($rtPs2Open, $rtPs2Close - $rtPs2Open + 1) -notmatch '"wiki-writer":\s*"allow"') {
            $script:fail += "selftest T1-E2.07: parcel-sprint task allow-list was not stamped from the seed (F3 stamp failed)"
        }
        try { $null = $rtOcAfter | ConvertFrom-Json } catch { $script:fail += "selftest T1-E2.07: target opencode.json invalid after structural stamp" }
        $rtHash1 = @((Get-FileHash $rtBc -Algorithm SHA256).Hash, (Get-FileHash $rtOcPath -Algorithm SHA256).Hash)
        $rtSync2 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
        if ($rtSync2.ExitCode -ne 0) { throw "selftest T1-E2.07: idempotence re-sync failed (exit $($rtSync2.ExitCode))" }
        $rtHash2 = @((Get-FileHash $rtBc -Algorithm SHA256).Hash, (Get-FileHash $rtOcPath -Algorithm SHA256).Hash)
        if (($rtHash1 -join '|') -ne ($rtHash2 -join '|')) { $script:fail += "selftest T1-E2.07: second sync moved base-context.md or opencode.json (retirement transport not idempotent)" }
        # End-to-end -Check gate: immediately after a successful sync the target must
        # report IN SYNC (manifest stamped, prefix-locked agents excluded from the hash).
        # This guards both post-sync bookkeeping bugs: the phantom UPGRADE from an
        # unstamped manifest and the eternal agents DRIFT from the regenerated prefix.
        $stE2eCheck = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check')
        if ($stE2eCheck.ExitCode -ne 0) { $script:fail += "-Check reported OUT OF SYNC immediately after a successful sync" }
        # --- T1-E2.08 fixture: the ordering-aware counter (behind / ahead / shape crossing) ---
        # Plant an AHEAD value in the target manifest and assert three things: -Check reports
        # AHEAD (never UPGRADE), -Check exits non-zero, and a SYNC halts BEFORE writing so the
        # target value is never silently rewound. Then plant a shape-crossed value, assert
        # MIGRATION + non-zero, and restore the source value so later fixtures stay isolated.
        $mvSrcRaw = Get-Content -Raw $stManifestPath
        $mvSrc = [regex]::Match($mvSrcRaw, '(?m)^machinery-version:\s*(\d+(?:\.\d+)*)').Groups[1].Value
        $mvAhead = if ($mvSrc -match '\.') { "$mvSrc.1" } else { [string]([int]$mvSrc + 1) }
        $mvShape = if ($mvSrc -match '\.') { '99' } else { '1.0.73' }
        $mvTgtPath = Join-Path $tmp '.devops/sync-manifest.yaml'
        [System.IO.File]::WriteAllText($mvTgtPath, [regex]::Replace([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $mvAhead"))
        Write-Output "SELFTEST fixture T1-E2.08: target counter planted AHEAD ($mvSrc -> $mvAhead)"
        $mvOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
        $mvOut = $mvOutRec.Combined
        if ($mvOutRec.ExitCode -eq 0) { $script:fail += "selftest T1-E2.08: -Check reported IN SYNC with a target-ahead counter (exit 0)" }
        if (-not ($mvOut -match 'AHEAD')) { $script:fail += "selftest T1-E2.08: -Check did not report AHEAD for a target-ahead counter" }
        if ($mvOut -match 'meta\s+machinery-version\s+UPGRADE') { $script:fail += "selftest T1-E2.08: -Check mislabelled a target-ahead counter as UPGRADE" }
        $mvHalt = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify') -AllowNonZero
        if ($mvHalt.ExitCode -eq 0) { $script:fail += "selftest T1-E2.08: sync proceeded against a target-ahead counter (no halt)" }
        $mvAfterAhead = [regex]::Match([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*(\d+(?:\.\d+)*)').Groups[1].Value
        if ($mvAfterAhead -ne $mvAhead) { $script:fail += "selftest T1-E2.08: sync rewound an ahead counter ($mvAhead -> $mvAfterAhead)" }
        [System.IO.File]::WriteAllText($mvTgtPath, [regex]::Replace([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $mvShape"))
        Write-Output "SELFTEST fixture T1-E2.08: target counter planted shape-crossed ($mvShape vs source $mvSrc)"
        $mvOut2Rec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
        $mvOut2 = $mvOut2Rec.Combined
        if ($mvOut2Rec.ExitCode -eq 0) { $script:fail += "selftest T1-E2.08: -Check reported IN SYNC with a shape-crossed counter (exit 0)" }
        if (-not ($mvOut2 -match 'MIGRATION')) { $script:fail += "selftest T1-E2.08: -Check did not report MIGRATION for a shape-crossed counter" }
        [System.IO.File]::WriteAllText($mvTgtPath, [regex]::Replace([System.IO.File]::ReadAllText($mvTgtPath), '(?m)^machinery-version:\s*\d+(?:\.\d+)*', "machinery-version: $mvSrc"))
        $mvRestored = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check')
        if ($mvRestored.ExitCode -ne 0) { $script:fail += "selftest T1-E2.08: -Check not IN SYNC after restoring the counter to the source value" }
        # Claims checker smoke: the ported script must execute in a satellite against
        # the synced .wiki/rules corpus and report clean (imports wiki_lint, same dir).
        if (Test-Path (Join-Path $tmp 'scripts/wiki_claims.py')) {
            & python (Join-Path $tmp 'scripts/wiki_claims.py') check --quiet | Out-Null
            if ($LASTEXITCODE -ne 0) { $script:fail += "wiki_claims.py check failed in target (exit $LASTEXITCODE)" }
        } else {
            $script:fail += "wiki_claims.py missing from target scripts/"
        }
        # --- T3-E1.04 fixture: the skill tier (`profile: FULL | CORE`) -----------------------
        # A satellite declares how much of the library it carries; the sync respects it. Proves
        # the contracts that would otherwise ship silently wrong: CORE narrows the compared set,
        # an un-installed tiered-out skill is never MISSING, a PRESENT one is PRUNE and a sync
        # sheds it, FULL restores it additively, and an unknown value HALTS naming itself.
        # Runs LAST: it leaves the temp target back at `profile: FULL`.
        $stCore = @($stMan.Lists['core_skills'])
        $stFullOnly = @($stSkills | Where-Object { $stCore -notcontains $_ })
        if ($stCore.Count -eq 0) {
            $script:fail += "T3-E1.04: source manifest declares no core_skills"
        } elseif ($stFullOnly.Count -eq 0) {
            $script:fail += "T3-E1.04: core_skills covers the whole library - no tier left to test"
        } else {
            foreach ($slug in $stCore) {
                if ($stSkills -notcontains $slug) { $script:fail += "T3-E1.04: core_skills entry '$slug' resolves to no source skill folder" }
            }
            if ($stCore.Count -ge $stSkills.Count) { $script:fail += "T3-E1.04: core_skills is not a strict subset of the portable set" }
            $stTgtManifest = Join-Path $tmp '.devops/sync-manifest.yaml'
            function Set-FixtureProfile {
                # A satellite's OWN declaration: rewrite the key in place, exactly as an operator
                # would. The sync must never clobber it (it rewrites only machinery-version).
                param([string]$Value)
                $raw = [System.IO.File]::ReadAllText($stTgtManifest)
                if ($raw -match '(?m)^profile:') {
                    $raw = [regex]::Replace($raw, '(?m)^profile:.*$', "profile: $Value")
                } else {
                    $raw = $raw.TrimEnd() + "`r`nprofile: $Value`r`n"
                }
                [System.IO.File]::WriteAllText($stTgtManifest, $raw)
            }
            $stProbe = $stFullOnly[0]
            # (iii) CORE: the present FULL-only skills are PRUNE (never MISSING) and a sync sheds
            # them; the CORE set survives and -Check is then IN SYNC with no MISSING at all.
            Set-FixtureProfile 'CORE'
            Write-Output "SELFTEST fixture T3-E1.04: target profile set to CORE (full-only probe '$stProbe')"
            $stCoreOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stCoreOut = $stCoreOutRec.Combined
            if ($stCoreOutRec.ExitCode -eq 0) { $script:fail += "T3-E1.04: -Check reported IN SYNC with tiered-out skills present (exit 0)" }
            if (-not ($stCoreOut -match 'PRUNE')) { $script:fail += "T3-E1.04: -Check did not report PRUNE for a present tiered-out skill" }
            if ($stCoreOut -match 'MISSING') { $script:fail += "T3-E1.04: -Check reported MISSING under a CORE profile" }
            $stCoreSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
            if ($stCoreSync.ExitCode -ne 0) { throw "selftest T3-E1.04: CORE sync failed (exit $($stCoreSync.ExitCode))" }
            foreach ($slug in $stFullOnly) {
                if (Test-Path (Join-Path $tmp ".devops/skills/$slug")) { $script:fail += "T3-E1.04: tiered-out skill '$slug' survived the CORE sync"; break }
            }
            foreach ($slug in $stCore) {
                if (-not (Test-Path (Join-Path $tmp ".devops/skills/$slug"))) { $script:fail += "T3-E1.04: CORE skill '$slug' was pruned by the tier switch"; break }
            }
            $stCoreCheckRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check')
            $stCoreCheck = $stCoreCheckRec.Combined
            if ($stCoreCheckRec.ExitCode -ne 0) { $script:fail += "T3-E1.04: -Check not IN SYNC for a settled CORE target" }
            if ($stCoreCheck -match 'MISSING') { $script:fail += "T3-E1.04: an un-installed tiered-out skill was reported MISSING (it must not be compared at all)" }
            if ($stCoreCheck -match [regex]::Escape($stProbe)) { $script:fail += "T3-E1.04: -Check named the tiered-out skill '$stProbe'" }
            # (iv) a tiered-out skill PRESENT in a CORE target: PRUNE, then deleted by a sync.
            $stStaleSkill = Join-Path $tmp ".devops/skills/$stProbe"
            New-Item -ItemType Directory -Force -Path $stStaleSkill | Out-Null
            Set-Content -Path (Join-Path $stStaleSkill 'SKILL.md') -Value "stale" -NoNewline
            $stPruneOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stPruneOut = $stPruneOutRec.Combined
            if ($stPruneOutRec.ExitCode -eq 0) { $script:fail += "T3-E1.04: -Check reported IN SYNC with a tiered-out skill present (exit 0)" }
            if (-not ($stPruneOut -match 'PRUNE')) { $script:fail += "T3-E1.04: -Check did not report PRUNE for a tiered-out skill present in a CORE target" }
            $stTierPruneSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
            if ($stTierPruneSync.ExitCode -ne 0) { throw "selftest T3-E1.04: tier prune re-sync failed (exit $($stTierPruneSync.ExitCode))" }
            if (Test-Path $stStaleSkill) { $script:fail += "T3-E1.04: the tiered-out skill survived the sync (tier prune failed)" }
            $stTierCheck = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check')
            if ($stTierCheck.ExitCode -ne 0) { $script:fail += "T3-E1.04: -Check not IN SYNC after the tier prune" }
            # (v) CORE -> FULL is purely additive: the tiered-out skill comes back, byte-identical.
            Set-FixtureProfile 'FULL'
            $stFullSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
            if ($stFullSync.ExitCode -ne 0) { throw "selftest T3-E1.04: FULL restore sync failed (exit $($stFullSync.ExitCode))" }
            $stProbeFile = Join-Path $stStaleSkill 'SKILL.md'
            if (-not (Test-Path $stProbeFile)) {
                $script:fail += "T3-E1.04: declaring FULL did not re-materialise the tiered-out skill (not additive)"
            } else {
                $hSrc = (Get-FileHash (Join-Path $srcRoot ".devops/skills/$stProbe/SKILL.md") -Algorithm SHA256).Hash
                $hTgt = (Get-FileHash $stProbeFile -Algorithm SHA256).Hash
                if ($hSrc -ne $hTgt) { $script:fail += "T3-E1.04: the restored skill '$stProbe' differs from its source (restore is not a clean copy)" }
            }
            $stFullCheck = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check')
            if ($stFullCheck.ExitCode -ne 0) { $script:fail += "T3-E1.04: -Check not IN SYNC after the FULL restore" }
            # (vi) an unknown profile HALTS loudly, naming the value, and exits non-zero. The
            # child's streams are captured at the PROCESS level by Invoke-CapturedChild: a
            # native command's stderr routed through PowerShell's error stream is not reliably
            # catchable under $ErrorActionPreference = 'Stop', and this fixture must assert the
            # halt, not swallow it.
            Set-FixtureProfile 'BOGUS'
            $stBogusRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stBogusMsg = $stBogusRec.Combined
            if ($stBogusRec.ExitCode -eq 0) { $script:fail += "T3-E1.04: -Check accepted an unknown profile value (exit 0)" }
            if ($stBogusMsg -notmatch 'unknown profile') { $script:fail += "T3-E1.04: the unknown-profile halt did not carry the engine's message (got: $stBogusMsg)" }
            if ($stBogusMsg -notmatch 'BOGUS') { $script:fail += "T3-E1.04: the unknown-profile halt did not name the value" }
            # ...and the SYNC path halts too, before writing anything (the tier resolves ahead of
            # the copy loops), so a bad declaration can never half-install a surface.
            $stSkillsBefore = (Get-ChildItem (Join-Path $tmp '.devops/skills') -Directory).Count
            $stBogusSyncRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify') -AllowNonZero
            if ($stBogusSyncRec.ExitCode -eq 0) { $script:fail += "T3-E1.04: the sync path accepted an unknown profile value (exit 0)" }
            $stSkillsAfter = (Get-ChildItem (Join-Path $tmp '.devops/skills') -Directory).Count
            if ($stSkillsAfter -ne $stSkillsBefore) { $script:fail += "T3-E1.04: the unknown-profile sync wrote to the target ($stSkillsBefore -> $stSkillsAfter skills)" }
            Set-FixtureProfile 'FULL'
        }
        # --- T1-E1.05 fixture: the opencode.json key-shape migration -------------------------
        # Three plants. Each re-downgrades the target's OWN opencode.json first (the harness
        # syncs above leave it V2-native) and asserts the pre-state it assumes, so no plant can
        # pass vacuously. They run LAST in the family.
        # (1) migration plant: an all-keys-present, task-already-stamped satellite whose ONLY
        #     pending change is the key-shape migration - so the migration's own flag is the
        #     only reason the write fires, and its own declared path must survive verbatim.
        $oc15SeedPath = Join-Path $srcRoot '.devops/templates/opencode.template.json'
        $oc15OcPath = Join-Path $tmp 'opencode.json'
        $oc15SeedText = ([System.IO.File]::ReadAllText($oc15SeedPath)) -replace "`r`n", "`n"
        $oc15Key = ($stSrcRegistry.Keys | Sort-Object)[-1]
        $mpPlanted = $oc15SeedText.Replace('  "skills": [".devops/skills"],', '  "skills": { "paths": ["custom/skills", ".devops/skills"] },')
        # The planted value carries the candidate-verdict scan's FALSE-POSITIVE control (C-R3-2):
        # a comma immediately before a closing brace INSIDE a string literal, plus an escaped
        # quote. A scan that is not string-aware flags the first; one that is quote-aware but not
        # escape-aware ends the string early and flags the second. Both must read VALID, or the
        # fix's "must never reject valid JSON" clause ships with no permanent owner. The anchor
        # is THIS text, read BEFORE the sync child below: the member carrying it is the member
        # the migration deletes, so an assertion read off the post-sync file would pass vacuously.
        $mpPlanted = $mpPlanted.Replace('  "$schema":', '  "instructions": ["AGENTS.md", "a,}", "a\"b"],' + "`n" + '  "$schema":')
        if ($mpPlanted -notmatch '"instructions"\s*:') { $script:fail += "selftest T1-E1.05: migration plant carries no config member to delete" }
        if (-not (Test-JsonShape $mpPlanted)) { $script:fail += "selftest T1-E1.05: the candidate-verdict scan rejected a VALID config (false positive on a comma/brace inside a string, or on an escaped quote)" }
        $mpPre = $null; try { $mpPre = $mpPlanted | ConvertFrom-Json } catch { $mpPre = $null }
        if (-not $mpPre -or -not $mpPre.skills.paths) { $script:fail += "selftest T1-E1.05: migration plant pre-state invalid ('skills' is not the V1 object)" }
        Write-Output "SELFTEST fixture T1-E1.05: migration plant planted (V1 skills object + the ignored config member)"
        [System.IO.File]::WriteAllText($oc15OcPath, $mpPlanted, (New-Object System.Text.UTF8Encoding($false)))
        $mpAgentM = [regex]::Match($mpPlanted, '"agent"\s*:\s*\{'); $mpAgentOpen = $mpPlanted.IndexOf('{', $mpAgentM.Index); $mpAgentClose = Find-MatchingBrace $mpPlanted $mpAgentOpen
        $mpAgentBefore = $mpPlanted.Substring($mpAgentOpen, $mpAgentClose - $mpAgentOpen + 1)
        $mpHash1 = (Get-FileHash $oc15OcPath -Algorithm SHA256).Hash
        $mpSync1 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
        if ($mpSync1.ExitCode -ne 0) { throw "selftest T1-E1.05: migration-plant sync failed (exit $($mpSync1.ExitCode))" }
        $mpAfter = [System.IO.File]::ReadAllText($oc15OcPath)
        $mpJson = $null; try { $mpJson = $mpAfter | ConvertFrom-Json } catch { $mpJson = $null }
        if (-not $mpJson) {
            $script:fail += "selftest T1-E1.05: migration plant left opencode.json unparsable"
        } else {
            if (-not ($mpJson.skills -is [array])) { $script:fail += "selftest T1-E1.05: migration plant 'skills' is not the V2 flat array" }
            elseif (($mpJson.skills -join ',') -ne 'custom/skills,.devops/skills') { $script:fail += "selftest T1-E1.05: migration plant did not preserve the declared path entries" }
            if ($mpJson.PSObject.Properties['instructions']) { $script:fail += "selftest T1-E1.05: migration plant left the ignored config member in place" }
            $mpAgentM2 = [regex]::Match($mpAfter, '"agent"\s*:\s*\{'); $mpAgentOpen2 = $mpAfter.IndexOf('{', $mpAgentM2.Index); $mpAgentClose2 = Find-MatchingBrace $mpAfter $mpAgentOpen2
            if ($mpAgentBefore -ne $mpAfter.Substring($mpAgentOpen2, $mpAgentClose2 - $mpAgentOpen2 + 1)) { $script:fail += "selftest T1-E1.05: migration plant restructured the agent block" }
            $mpHash2 = (Get-FileHash $oc15OcPath -Algorithm SHA256).Hash
            if ($mpHash2 -eq $mpHash1) { $script:fail += "selftest T1-E1.05: the migration alone did not trigger the write (hash unchanged)" }
            $mpSync2 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
            if ($mpSync2.ExitCode -ne 0) { throw "selftest T1-E1.05: migration-plant idempotence re-sync failed (exit $($mpSync2.ExitCode))" }
            if ((Get-FileHash $oc15OcPath -Algorithm SHA256).Hash -ne $mpHash2) { $script:fail += "selftest T1-E1.05: a second sync moved the migrated opencode.json (not idempotent)" }
        }
        # (2) unsafe-rewrite plant: the removed member is the LAST root member, so the line-level
        #     delete would leave a trailing comma -> step-local revert. An omitted registry key
        #     must still be inserted (step-locality), the file must still parse, and the strict
        #     V2-only gate must be OBSERVED rejecting the surviving legacy object.
        $urSeed = Get-Content -Raw $oc15SeedPath | ConvertFrom-Json
        $urSeed.PSObject.Properties.Remove('_comment') | Out-Null
        $urSeed.agent.PSObject.Properties.Remove($oc15Key) | Out-Null
        $urSeed.skills = [pscustomobject]@{ paths = @('.devops/skills') }
        $urBody = (($urSeed | ConvertTo-Json -Depth 10) -replace "`r`n", "`n").TrimEnd()
        $urPlanted = $urBody.Substring(0, $urBody.Length - 1).TrimEnd() + ',' + "`n" + '  "instructions": ["AGENTS.md"]' + "`n}" + "`n"
        if ($urPlanted -notmatch '(?s)"instructions"\s*:\s*\["AGENTS\.md"\]\s*\}\s*$') { $script:fail += "selftest T1-E1.05: unsafe plant pre-state invalid (the member is not the last root member)" }
        if ($urPlanted -match ('"' + [regex]::Escape($oc15Key) + '"\s*:\s*\{')) { $script:fail += "selftest T1-E1.05: unsafe plant pre-state invalid (registry key '$oc15Key' was not omitted)" }
        Write-Output "SELFTEST fixture T1-E1.05: unsafe-rewrite plant planted (member last, registry key '$oc15Key' omitted)"
        [System.IO.File]::WriteAllText($oc15OcPath, $urPlanted, (New-Object System.Text.UTF8Encoding($false)))
        $urSkM = [regex]::Match($urPlanted, '"skills"\s*:\s*\{'); $urSkOpen = $urPlanted.IndexOf('{', $urSkM.Index); $urSkClose = Find-MatchingBrace $urPlanted $urSkOpen
        $urSkillsBefore = $urPlanted.Substring($urSkOpen, $urSkClose - $urSkOpen + 1)
        $urInstrBefore = [regex]::Match($urPlanted, '(?m)^[ \t]*"instructions"\s*:.*$').Value
        # Combined stdout+stderr, exactly as the old `2>&1 | Out-String` capture was (CONCERN-2).
        $urOut = (Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')).Combined
        if ($urOut -notmatch 'would break the JSON - reverted') { $script:fail += "selftest T1-E1.05: unsafe plant did not print the revert line" }
        $urAfter = [System.IO.File]::ReadAllText($oc15OcPath)
        $urJson = $null; try { $urJson = $urAfter | ConvertFrom-Json } catch { $urJson = $null }
        if (-not $urJson) { $script:fail += "selftest T1-E1.05: unsafe plant left opencode.json unparsable" }
        $urSkM2 = [regex]::Match($urAfter, '"skills"\s*:\s*\{'); $urSkOpen2 = $urAfter.IndexOf('{', $urSkM2.Index); $urSkClose2 = Find-MatchingBrace $urAfter $urSkOpen2
        if ($urSkillsBefore -ne $urAfter.Substring($urSkOpen2, $urSkClose2 - $urSkOpen2 + 1)) { $script:fail += "selftest T1-E1.05: unsafe plant rewrote the legacy 'skills' object (the revert was not step-local)" }
        if ([regex]::Match($urAfter, '(?m)^[ \t]*"instructions"\s*:.*$').Value -ne $urInstrBefore) { $script:fail += "selftest T1-E1.05: unsafe plant deleted the member despite the revert" }
        if ($urJson -and -not $urJson.agent.PSObject.Properties[$oc15Key]) { $script:fail += "selftest T1-E1.05: unsafe plant's omitted registry key was not inserted (reconciliation was not step-local)" }
        # `-Verify` exits non-zero here by design (the legacy object survives), so the failure
        # is declared; the assertions below read the combined stream (CONCERN-2).
        $urV = (Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Verify') -AllowNonZero).Combined
        $urStruct = ($urV -split '=== Machinery gates ===')[0]
        if ($urStruct -notmatch "\[FAIL\][^\n]*opencode\.json[^\n]*skills") { $script:fail += "selftest T1-E1.05: the strict gate did not FAIL the surviving legacy 'skills' object" }
        if ($urStruct -match "\[PASS\][^\n]*opencode\.json") { $script:fail += "selftest T1-E1.05: the strict gate PASSed opencode.json while the legacy object survived" }
        # (3) urls-refusal plant: the `skills` object also carries `urls`, so the shape rewrite is
        #     REFUSED (left byte-identical) while the separate member delete still runs and the
        #     omitted registry key is inserted - observed THROUGH a write, never silently.
        $urlSeed = Get-Content -Raw $oc15SeedPath | ConvertFrom-Json
        $urlSeed.PSObject.Properties.Remove('_comment') | Out-Null
        $urlSeed.agent.PSObject.Properties.Remove($oc15Key) | Out-Null
        $urlSeed.skills = [pscustomobject]@{ paths = @('.devops/skills'); urls = @('https://example.invalid') }
        $urlRaw0 = ($urlSeed | ConvertTo-Json -Depth 10) -replace "`r`n", "`n"
        $urlPlanted = $urlRaw0 -replace '(?s)("skills"\s*:\s*\{[^}]*\}\s*,)', ('$1' + "`n  " + '"instructions": ["AGENTS.md"],')
        if ($urlPlanted -notmatch '"instructions"\s*:') { $script:fail += "selftest T1-E1.05: urls plant carries no config member to delete" }
        if ($urlPlanted -match '(?s)"instructions"\s*:\s*\[[^\]]*\]\s*\}\s*$') { $script:fail += "selftest T1-E1.05: urls plant pre-state invalid (the member must not be last)" }
        Write-Output "SELFTEST fixture T1-E1.05: urls-refusal plant planted (skills carries urls, registry key '$oc15Key' omitted)"
        [System.IO.File]::WriteAllText($oc15OcPath, $urlPlanted, (New-Object System.Text.UTF8Encoding($false)))
        $urlSkM = [regex]::Match($urlPlanted, '"skills"\s*:\s*\{'); $urlSkOpen = $urlPlanted.IndexOf('{', $urlSkM.Index); $urlSkClose = Find-MatchingBrace $urlPlanted $urlSkOpen
        $urlSkillsBefore = $urlPlanted.Substring($urlSkOpen, $urlSkClose - $urlSkOpen + 1)
        # Combined stdout+stderr, exactly as the old `2>&1 | Out-String` capture was (CONCERN-2).
        $urlOut = (Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')).Combined
        $urlAfter = [System.IO.File]::ReadAllText($oc15OcPath)
        $urlJson = $null; try { $urlJson = $urlAfter | ConvertFrom-Json } catch { $urlJson = $null }
        if (-not $urlJson) { $script:fail += "selftest T1-E1.05: urls plant left opencode.json unparsable" }
        $urlSkM2 = [regex]::Match($urlAfter, '"skills"\s*:\s*\{'); $urlSkOpen2 = $urlAfter.IndexOf('{', $urlSkM2.Index); $urlSkClose2 = Find-MatchingBrace $urlAfter $urlSkOpen2
        if ($urlSkillsBefore -ne $urlAfter.Substring($urlSkOpen2, $urlSkClose2 - $urlSkOpen2 + 1)) { $script:fail += "selftest T1-E1.05: urls plant rewrote a 'skills' shape it must refuse" }
        if ($urlOut -notmatch "'urls'") { $script:fail += "selftest T1-E1.05: urls plant printed no refusal line naming 'urls'" }
        if ($urlJson) {
            if ($urlJson.PSObject.Properties['instructions']) { $script:fail += "selftest T1-E1.05: urls plant did not delete the config member (a refusal must be shape-scoped)" }
            if (-not $urlJson.agent.PSObject.Properties[$oc15Key]) { $script:fail += "selftest T1-E1.05: urls plant's omitted registry key was not inserted (no write fired)" }
        }
}
