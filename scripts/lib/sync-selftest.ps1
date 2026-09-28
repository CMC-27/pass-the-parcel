# sync-selftest.ps1 — the `-SelfTest` harness: build a throwaway satellite, sync into it,
# verify, tear down. Owns the judged-child capture helper (`Invoke-CapturedChild`, T1-E2.11),
# the F3 self-check that no direct child launch exists outside it, the manifest-mirror
# assertions and the transport-contract fixtures.
#
# Moved out of the entry script by T1-E4.05 (the W6 split precedent, re-applied): the entry
# keeps the CLI, and the harness receives the ENTRY path explicitly as `-EntryPath` instead of
# relying on `$PSCommandPath`, which inside a dot-sourced module no longer names the entry file.
# `-HarnessPath` is this file: the F3 self-check scans the file that DEFINES the helper, which
# is exactly the text it scanned when the helper lived in the entry - same coverage, one home.
#
# The fixture families live in sync-selftest-fixtures.ps1 and are called from the end of
# `Invoke-EngineSelfTest`, in the order they were added, so the shared throwaway target is
# evolved in exactly the sequence it was before the split. Both modules are dot-sourced by
# scripts/sync-architecture.ps1 and declared in .devops/sync-manifest.yaml portable_files.

function Invoke-EngineSelfTest {
    param(
        [string]$SrcRoot,
        [string]$EntryPath,
        [string]$HarnessPath,
        [string]$ShellExe
    )

    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-selftest-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        Write-Output "SELFTEST: temp target = $tmp"
        # Accumulate fixture findings from the very start so the F8/F9 assertions below
        # survive into the final $fail check (the later `$script:fail = @()` is intentionally gone).
        $script:fail = @()

        function Invoke-CapturedChild {
            # Runs the engine as a child process and returns its exit code and BOTH streams,
            # captured at the PROCESS level - a native command's stderr is not reliably
            # catchable under $ErrorActionPreference = 'Stop' (process-lessons [2026-09-25]),
            # which is why a bare `2>&1 | Out-String` is a false-pass hazard. On a non-zero
            # exit the record also carries a `Diagnostic` block naming the child command, its
            # exit code, its stdout and its stderr; unless the caller declared the failure with
            # -AllowNonZero, that block is EMITTED and one $fail is appended - so no assertion
            # about target behaviour is ever derived from a child the harness did not hear
            # from (T1-E2.11, F3). Defined at the TOP of the body, not beside Assert-Mirror:
            # the F8/F9 fixture below launches a child before Assert-Mirror is defined.
            # ponytail: two temp files per judged invocation (~29 per run) - the file's own
            # corrected single-fixture pattern, generalised; upgrade path is one temp dir per
            # run, or named pipes.
            param([string[]]$Arguments, [switch]$AllowNonZero)
            $cccOut = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-child-" + [guid]::NewGuid().ToString('N').Substring(0, 8) + ".out")
            $cccErr = Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-child-" + [guid]::NewGuid().ToString('N').Substring(0, 8) + ".err")
            $cccProc = Start-Process -FilePath $shellExe -ArgumentList $Arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput $cccOut -RedirectStandardError $cccErr
            $cccSo = [System.IO.File]::ReadAllText($cccOut)
            $cccSe = [System.IO.File]::ReadAllText($cccErr)
            Remove-Item $cccOut, $cccErr -Force -ErrorAction SilentlyContinue
            $cccCmd = ('& ' + $shellExe + ' ' + ($Arguments -join ' '))
            $cccRec = @{ Command = $cccCmd; ExitCode = $cccProc.ExitCode; Stdout = $cccSo; Stderr = $cccSe; Combined = ($cccSo + "`n" + $cccSe) }
            if ($cccProc.ExitCode -ne 0) {
                $cccRec.Diagnostic = ("SELFTEST child failed: {0}`n  exit code: {1}`n  stdout: {2}`n  stderr: {3}" -f $cccCmd, $cccProc.ExitCode, $cccSo, $cccSe)
                if (-not $AllowNonZero) {
                    Write-Host $cccRec.Diagnostic
                    $script:fail += "SELFTEST child failed: $cccCmd (exit $($cccProc.ExitCode)) - its stdout/stderr are captured above; no behaviour assertion was made"
                }
            }
            return $cccRec
        }

        # --- F3 self-check: no direct child launch may sit outside Invoke-CapturedChild ------
        # Written and RUN before the call-site migration: its failing run against the
        # un-migrated body is the recorded pre-fix observation (C-R2-2), not a prediction.
        # It reads this file's own text, locates the helper's definition span BY NAME with the
        # reused Find-MatchingBrace, and fails if either launch literal occurs outside that
        # span. It FAILS CLOSED: an unlocatable or unbalanced span is a failure, never a skip.
        # The span is also BOUNDED - exactly one `function ` declaration inside it - because
        # Find-MatchingBrace is a JSON-oriented matcher (double-quote/backslash aware only,
        # blind to PowerShell single-quoted strings and `#` comments): an inflated-but-valid
        # span would swallow the very launches this check exists to find and pass vacuously
        # (C-R3-1). The needles are assembled from fragments so this text cannot self-match.
        $scNeedleA = '& ' + '$shell' + 'Exe'
        $scNeedleB = 'Start-' + 'Process'
        $scText = [System.IO.File]::ReadAllText($HarnessPath)
        $scHm = [regex]::Match($scText, 'function\s+Invoke-CapturedChild\b')
        $scHOpen = if ($scHm.Success) { $scText.IndexOf('{', $scHm.Index) } else { -1 }
        $scHClose = if ($scHOpen -ge 0) { Find-MatchingBrace $scText $scHOpen } else { -1 }
        if (-not $scHm.Success -or $scHOpen -lt 0 -or $scHClose -lt 0) {
            $script:fail += "selftest F3: Invoke-CapturedChild's definition span is not locatable in $HarnessPath - the self-check failed closed"
        } else {
            $scSpan = $scText.Substring($scHm.Index, $scHClose - $scHm.Index + 1)
            $scOutside = $scText.Substring(0, $scHm.Index) + $scText.Substring($scHClose + 1)
            $scFnCount = ([regex]::Matches($scSpan, '\bfunction\s')).Count
            if ($scFnCount -ne 1) {
                $script:fail += "selftest F3: the located Invoke-CapturedChild span is not exact (it holds $scFnCount function declarations) - the self-check failed closed"
            } else {
                if ($scOutside.Contains($scNeedleA)) { $script:fail += "selftest F3: a direct child launch ('$scNeedleA') sits outside Invoke-CapturedChild" }
                if ($scOutside.Contains($scNeedleB)) { $script:fail += "selftest F3: a direct child launch ('$scNeedleB') sits outside Invoke-CapturedChild" }
            }
        }

        # --- F3 fixture: a failed child is reported as a child failure, never as an assertion -
        # Induces a deterministic child failure - the engine refuses a target that does not
        # exist - and asserts the diagnostic the helper builds: the literal
        # `SELFTEST child failed:` carrying the child command, its exit code, its stdout and
        # its stderr. The induction is deliberate, so -AllowNonZero suppresses the finding the
        # helper would otherwise raise; the asserted text is the same block the helper emits
        # on an UNexpected failure.
        $cdArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', (Join-Path ([System.IO.Path]::GetTempPath()) ("ptp-absent-" + [guid]::NewGuid().ToString('N').Substring(0, 8))), '-Check')
        $cdRec = Invoke-CapturedChild -Arguments $cdArgs -AllowNonZero
        if ($cdRec.ExitCode -eq 0) {
            $script:fail += "selftest F3: a child pointed at a nonexistent target exited 0 - the induction is not a failure"
        } else {
            $cdDiag = [string]$cdRec.Diagnostic
            if ($cdDiag -notmatch 'SELFTEST child failed:') { $script:fail += "selftest F3: the failed child produced no 'SELFTEST child failed:' diagnostic" }
            if (-not $cdDiag.Contains($cdRec.Command)) { $script:fail += "selftest F3: the child diagnostic does not name the child command" }
            if ($cdDiag -notmatch [regex]::Escape("exit code: $($cdRec.ExitCode)")) { $script:fail += "selftest F3: the child diagnostic does not carry the child's exit code" }
            if ($cdDiag -notmatch 'stdout:') { $script:fail += "selftest F3: the child diagnostic carries no stdout field" }
            if ($cdDiag -notmatch 'stderr:') { $script:fail += "selftest F3: the child diagnostic carries no stderr field" }
            if ($cdRec.Stderr.Length -eq 0) { $script:fail += "selftest F3: the induced child failure wrote nothing to stderr - the capture is not wired" }
            if (-not $cdDiag.Contains($cdRec.Stderr)) { $script:fail += "selftest F3: the child diagnostic does not carry the child's stderr" }
        }
        # --- F8/F9 fixture: a satellite-shaped target BEFORE the first sync -----------------
        # F8: simulate a satellite bootstrapped before a registry key existed - plant the seed
        #     config minus one registry key, sync, then assert the sync inserts it whole.
        # F9: the plan template is named by the shared prefix, so the target must receive it.
        $stSrcRegistry = Get-RegistryBindings (Join-Path $srcRoot '.opencode/plans/base-context.md')
        $stPick = $null; $stKeep = $null; $stKeepBefore = $null
        if ($stSrcRegistry.Count -gt 0) {
            $stPick = ($stSrcRegistry.Keys | Sort-Object)[-1]
            $stKeep = ($stSrcRegistry.Keys | Sort-Object)[0]
            $stSeedOc = Get-Content -Raw (Join-Path $srcRoot '.devops/templates/opencode.template.json') | ConvertFrom-Json
            $stSeedOc.PSObject.Properties.Remove('_comment') | Out-Null
            $stSeedOc.agent.PSObject.Properties.Remove($stPick) | Out-Null
            $stPlantedRaw = ($stSeedOc | ConvertTo-Json -Depth 10)
            [System.IO.File]::WriteAllText((Join-Path $tmp 'opencode.json'), $stPlantedRaw, (New-Object System.Text.UTF8Encoding($false)))
            $k0 = [regex]::Match($stPlantedRaw, '"' + [regex]::Escape($stKeep) + '"\s*:\s*\{')
            if ($k0.Success) {
                $k0o = $stPlantedRaw.IndexOf('{', $k0.Index); $k0c = Find-MatchingBrace $stPlantedRaw $k0o
                if ($k0o -ge 0 -and $k0c -ge 0) { $stKeepBefore = $stPlantedRaw.Substring($k0o, $k0c - $k0o + 1) }
            }
            Write-Output "SELFTEST fixture: opencode.json planted missing '$stPick' (sibling '$stKeep' must not move)"
        } else {
            Write-Output "SELFTEST fixture: skipped (source Model Registry empty)"
        }
        $stSync1 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
        if ($stSync1.ExitCode -ne 0) { throw "selftest: sync run failed (exit $($stSync1.ExitCode))" }
        # --- F8 assertions: inserted key present with NO model, sibling untouched, idempotent
        if ($stPick) {
            $stOcPath = Join-Path $tmp 'opencode.json'
            $stOcRaw = [System.IO.File]::ReadAllText($stOcPath)
            $stOcJson = $null
            try { $stOcJson = $stOcRaw | ConvertFrom-Json } catch { $stOcJson = $null }
            if (-not $stOcJson) {
                $script:fail += "selftest F8: target opencode.json invalid after sync"
            } else {
                $stProp = $stOcJson.agent.PSObject.Properties[$stPick]
                if (-not $stProp) {
                    $script:fail += "selftest F8: '$stPick' was not inserted into the target opencode.json"
                } else {
                    # T1-E1.04: the invariant is ABSENCE - an inserted entry must carry no model.
                    if ([string]$stProp.Value.model) { $script:fail += "selftest F8: inserted '$stPick' declares model '$($stProp.Value.model)' - no agent may declare a model" }
                }
                $k1 = [regex]::Match($stOcRaw, '"' + [regex]::Escape($stKeep) + '"\s*:\s*\{')
                if (-not $k1.Success) {
                    $script:fail += "selftest F8: sibling '$stKeep' vanished from the target opencode.json"
                } else {
                    $k1o = $stOcRaw.IndexOf('{', $k1.Index); $k1c = Find-MatchingBrace $stOcRaw $k1o
                    $stKeepAfter = if ($k1o -ge 0 -and $k1c -ge 0) { $stOcRaw.Substring($k1o, $k1c - $k1o + 1) } else { $null }
                    if ($stKeepBefore -ne $stKeepAfter) { $script:fail += "selftest F8: existing entry '$stKeep' was restructured by sync" }
                }
                $stHash1 = (Get-FileHash $stOcPath -Algorithm SHA256).Hash
                $stSync2 = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
                if ($stSync2.ExitCode -ne 0) { throw "selftest F8: idempotence re-sync failed (exit $($stSync2.ExitCode))" }
                $stHash2 = (Get-FileHash $stOcPath -Algorithm SHA256).Hash
                if ($stHash1 -ne $stHash2) { $script:fail += "selftest F8: second sync changed opencode.json (insert is not idempotent)" }
            }
        }
        # --- F9 assertion: the plan template the shared prefix names must reach the target ---
        $stTmplMatch = [regex]::Match(([System.IO.File]::ReadAllText((Join-Path $srcRoot '.opencode/plans/base-context.md'))), 'Plan template:\s*`([^`]+)`')
        if (-not $stTmplMatch.Success) {
            $script:fail += "selftest F9: no 'Plan template: <path>' reference found in the source prefix"
        } elseif (-not (Test-Path (Join-Path $tmp $stTmplMatch.Groups[1].Value.Trim()))) {
            $script:fail += "selftest F9: referenced plan template '$($stTmplMatch.Groups[1].Value.Trim())' missing from the target"
        }
        # Manifest must parse identically inside the test process — reuse Read-Manifest.
        $stManifestPath = Join-Path $srcRoot '.devops/sync-manifest.yaml'
        $stMan = Read-Manifest $stManifestPath
        $stDirs = @($stMan.Lists['portable_dirs'])
        $stFiles = @($stMan.Lists['portable_files'])
        $stPrune = @($stMan.Lists['prune_files'])
        $stPruneDirs = @($stMan.Lists['prune_dirs'])
        $stExcluded = @($stMan.Lists['excluded_skills'])
        $skillsRoot = Join-Path $srcRoot '.devops/skills'
        $stSkills = @(Get-ChildItem $skillsRoot -Directory | ForEach-Object { $_.Name } | Where-Object { $stExcluded -notcontains $_ })
        # $fail was initialised before the F8/F9 fixture above - do not reset it here.
        function Assert-Mirror {
            param([string]$Rel)
            $sp = Join-Path $srcRoot $Rel
            $tp = Join-Path $tmp $Rel
            if (-not (Test-Path $tp)) { $script:fail += "missing in target: $Rel"; return }
            # -Force keeps the source/target file-set comparison honest for hidden
            # (dot-prefixed) entries on Unix; both sides are filtered identically.
            $sh = Get-ChildItem -Force $sp -Recurse -File | ForEach-Object { $_.FullName.Substring($sp.Length) } | Sort-Object
            $th = Get-ChildItem -Force $tp -Recurse -File | ForEach-Object { $_.FullName.Substring($tp.Length) } | Sort-Object
            if (($sh -join '|') -ne ($th -join '|')) { $script:fail += "file set differs: $Rel" }
        }
        foreach ($d in $stDirs) { Assert-Mirror $d }
        foreach ($s in $stSkills) { Assert-Mirror ".devops/skills/$s" }
        foreach ($f in $stFiles) { Assert-Mirror $f }
        # Guard the historical Copy-Item nesting defect: no doubled directory names.
        $nested = Get-ChildItem -Force $tmp -Recurse -Directory | Where-Object { $_.FullName.Replace('\','/') -match '/(\.wiki|\.devops)/\1|/skills/([^/]+)/\2' }
        if ($nested) { $script:fail += "nested-copy defect: $($nested.FullName -join ', ')" }
        # Manifest stamping: the target's machinery-version must now match the source's,
        # otherwise -Check reports a phantom UPGRADE after every successful sync.
        $stSrcV = $null; $stTgtV = $null
        foreach ($line in Get-Content $stManifestPath) { if ($line -match '^machinery-version:\s*(\d+(?:\.\d+)*)') { $stSrcV = $Matches[1]; break } }
        $stTgtManifest = Join-Path $tmp '.devops/sync-manifest.yaml'
        if (Test-Path $stTgtManifest) {
            foreach ($line in Get-Content $stTgtManifest) { if ($line -match '^machinery-version:\s*(\d+(?:\.\d+)*)') { $stTgtV = $Matches[1]; break } }
        }
        if ($stTgtV -ne $stSrcV) { $script:fail += "manifest stamp failed: target machinery-version '$stTgtV' vs source '$stSrcV'" }
        # Model ABSENCE propagation (T1-E1.04): no target agent file may carry a `model:` line
        # after a sync, and no target opencode.json agent entry may declare a model. Guards the
        # strip contract (the old force-stamp direction is retired).
        $stSrcRegistry = Get-RegistryBindings (Join-Path $srcRoot '.opencode/plans/base-context.md')
        if ($stSrcRegistry.Count -eq 0) { $script:fail += "selftest: source Model Registry parsed as empty" }
        foreach ($bk in ($stSrcRegistry.Keys | Sort-Object)) {
            $bTgt = Join-Path $tmp ".devops/agents/$bk.agent.md"
            if (-not (Test-Path $bTgt)) { $bTgt = Join-Path $tmp ".devops/agents/$bk.subagent.md" }
            if (-not (Test-Path $bTgt)) { $script:fail += "binding file missing in target: $bk"; continue }
            $bm = [regex]::Match(([System.IO.File]::ReadAllText($bTgt) -replace "`r`n", "`n"), '(?m)^model:\s*(.+?)\s*$')
            if ($bm.Success) { $script:fail += "model binding survived the sync for $bk (target frontmatter still declares '$($bm.Groups[1].Value)')" }
        }
        $stTgtOc = Join-Path $tmp 'opencode.json'
        if (Test-Path $stTgtOc) {
            $stTgtOcJson = $null
            try { $stTgtOcJson = ([System.IO.File]::ReadAllText($stTgtOc)) | ConvertFrom-Json } catch { $stTgtOcJson = $null }
            if (-not $stTgtOcJson) {
                $script:fail += "selftest: target opencode.json invalid after sync"
            } else {
                foreach ($p in @($stTgtOcJson.agent.PSObject.Properties)) {
                    if ([string]$p.Value.model) { $script:fail += "model binding survived the sync for opencode agent '$($p.Name)' ('$($p.Value.model)')" }
                }
            }
        }
        # Prune test: plant a retired file, assert -Check reports PRUNE (not a parent-dir
        # DRIFT) and exits out-of-sync; re-sync, assert it is removed and Check is clean.
        # The planted file lives inside a portable dir, so this guards both the PRUNE
        # tally and the parent-dir masking fix.
        if ($stPrune.Count -gt 0) {
            $stale = Join-Path $tmp $stPrune[0]
            New-Item -ItemType Directory -Force -Path (Split-Path $stale) | Out-Null
            Set-Content -Path $stale -Value "stale" -NoNewline
            $stOutRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stOut = $stOutRec.Combined
            if ($stOutRec.ExitCode -eq 0) { $script:fail += "-Check reported IN SYNC with a prune file present (exit 0)" }
            if (-not ($stOut -match 'PRUNE')) { $script:fail += "-Check did not report a PRUNE verdict for $($stPrune[0])" }
            if ($stOut -match 'DRIFT') { $script:fail += "-Check reported DRIFT (not PRUNE) for a retired file inside a portable dir" }
            $stPruneSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
            if ($stPruneSync.ExitCode -ne 0) { throw "selftest: prune re-sync failed (exit $($stPruneSync.ExitCode))" }
            if (Test-Path $stale) { $script:fail += "prune failed: $($stPrune[0]) still present after re-sync" }
        }
        # Prune-DIRECTORY test: a retired skill folder is invisible to the derived portable
        # skill set, so it can only be removed by the explicit prune_dirs existence test.
        # Plant a NON-EMPTY directory (a flat delete would fail on it) and assert the same
        # three-phase contract: -Check reports PRUNE and exits non-zero, re-sync deletes it
        # recursively, -Check is then clean.
        if ($stPruneDirs.Count -gt 0) {
            $staleDir = Join-Path $tmp $stPruneDirs[0]
            New-Item -ItemType Directory -Force -Path $staleDir | Out-Null
            Set-Content -Path (Join-Path $staleDir 'SKILL.md') -Value "stale" -NoNewline
            $stOutDirRec = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-Check') -AllowNonZero
            $stOutDir = $stOutDirRec.Combined
            if ($stOutDirRec.ExitCode -eq 0) { $script:fail += "-Check reported IN SYNC with a prune directory present (exit 0)" }
            if (-not ($stOutDir -match 'PRUNE')) { $script:fail += "-Check did not report a PRUNE verdict for $($stPruneDirs[0])" }
            $stPruneDirSync = Invoke-CapturedChild -Arguments @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $EntryPath, '-Target', $tmp, '-NoVerify')
            if ($stPruneDirSync.ExitCode -ne 0) { throw "selftest: prune-dir re-sync failed (exit $($stPruneDirSync.ExitCode))" }
            if (Test-Path $staleDir) { $script:fail += "prune_dirs failed: $($stPruneDirs[0]) still present after re-sync" }
        }

        # --- fixture families: scripts/lib/sync-selftest-fixtures.ps1 -------------------
        Invoke-EngineFixtureFamilies -Tmp $tmp -SrcRoot $SrcRoot -EntryPath $EntryPath `
            -StManifestPath $stManifestPath -StSkills $stSkills -StMan $stMan -StSrcRegistry $stSrcRegistry
        if ($fail.Count -gt 0) {
            Write-Output "SELFTEST FAILED:"
            $fail | ForEach-Object { Write-Output "  $_" }
            exit 1
        }
        Write-Output "SELFTEST OK: $($stDirs.Count) dirs, $($stSkills.Count) skills, $($stFiles.Count) files materialised correctly."
        exit 0
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
