# sync-bindings.ps1 — the Model Registry force-propagation over the three binding surfaces
# (registry rows in base-context.md, agent frontmatter, opencode.json model values).
# Dot-sourced by scripts/sync-architecture.ps1 (see scripts/lib/README.md). Portable.

function Get-RegistryBindings {
    # Parse a `## Model Registry` table out of a base-context file:
    # key -> @{class=<capability class>}. Rows must carry EXACTLY two cells; a row with the
    # retired model columns is skipped here and fails loudly in check-parcel-prefix.ps1.
    # Used by the sync to keep the target's capability-class table in step with the source
    # (rows INSERTED for source growth, PRUNED for source retirement).
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { return $map }
    $text = ([System.IO.File]::ReadAllText($Path)) -replace "`r`n", "`n"
    foreach ($line in ($text -split "`n")) {
        if ($line -match '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|') {
            $cells = @(($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
            if ($cells.Count -eq 2) { $map[$cells[0]] = @{ class = $cells[1] } }
        }
    }
    return $map
}

function Find-MatchingBrace {
    # Index of the '}' matching the '{' at $Open, ignoring braces inside JSON string
    # literals and honouring backslash escapes. Returns -1 when unbalanced.
    # ponytail: single-pass scanner - the only structural parse this script needs; a JSON
    # library would re-serialize and destroy the target file's byte formatting, which is the
    # whole point of the textual rewrite.
    param([string]$Text, [int]$Open)
    $depth = 0; $inStr = $false; $esc = $false
    for ($i = $Open; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($inStr) {
            if ($esc) { $esc = $false }
            elseif ($c -eq '\') { $esc = $true }
            elseif ($c -eq '"') { $inStr = $false }
        } else {
            if ($c -eq '"') { $inStr = $true }
            elseif ($c -eq '{') { $depth++ }
            elseif ($c -eq '}') { $depth--; if ($depth -eq 0) { return $i } }
        }
    }
    return -1
}

function Get-SeedAgentEntry {
    # Reads the TARGET's own synced seed config and returns agent.<Key> as
    # @{ Body = '{...}'; Indent = '<leading whitespace of the entry line>' }.
    # Body is sliced VERBATIM from the seed - never ConvertTo-Json, which would re-escape
    # non-ASCII descriptions and change the seeded text. $null when the seed, the key, or a
    # balanced object is absent. The seed is a portable file, so a target that has synced
    # always carries it.
    param([string]$TgtRoot, [string]$Key)
    $seed = Join-Path $TgtRoot '.devops/templates/opencode.template.json'
    if (-not (Test-Path $seed)) { return $null }
    $raw = ([System.IO.File]::ReadAllText($seed)) -replace "`r`n", "`n"
    $km = [regex]::Match($raw, '"' + [regex]::Escape($Key) + '"\s*:\s*\{')
    if (-not $km.Success) { return $null }
    $open = $raw.IndexOf('{', $km.Index)
    $close = Find-MatchingBrace $raw $open
    if ($open -lt 0 -or $close -lt 0) { return $null }
    $lineStart = $raw.LastIndexOf("`n", $km.Index) + 1
    $indent = $raw.Substring($lineStart, $km.Index - $lineStart)
    return @{ Body = $raw.Substring($open, $close - $open + 1); Indent = $indent }
}

function Add-TargetAgentEntry {
    # Appends a seed-shaped agent.<Key> entry to the END of the target's "agent" object
    # (mirrors Update-TargetModelBindings step 1: anchor after the last existing entry).
    # Returns @{ Text = '<new raw>'; Ok = $true } or @{ Ok = $false } when the agent object
    # cannot be located. Emits the file's own EOL so a CRLF target is not left mixed.
    param([string]$Raw, [string]$Key, [hashtable]$Seed)
    $am = [regex]::Match($Raw, '"agent"\s*:\s*\{')
    if (-not $am.Success) { return @{ Ok = $false } }
    $open = $Raw.IndexOf('{', $am.Index)
    $close = Find-MatchingBrace $Raw $open
    if ($open -lt 0 -or $close -lt 0) { return @{ Ok = $false } }
    $eol = if ($Raw -match "`r`n") { "`r`n" } else { "`n" }
    $agentLineStart = $Raw.LastIndexOf("`n", $am.Index) + 1
    $agentIndent = $Raw.Substring($agentLineStart, $am.Index - $agentLineStart)
    $entryIndent = $agentIndent + '  '
    $bodyLines = ($Seed.Body -replace "`r`n", "`n") -split "`n"
    if ($Seed.Indent) {
        for ($i = 1; $i -lt $bodyLines.Count; $i++) {
            if ($bodyLines[$i].StartsWith($Seed.Indent)) {
                $bodyLines[$i] = $entryIndent + $bodyLines[$i].Substring($Seed.Indent.Length)
            }
        }
    }
    $entry = $entryIndent + '"' + $Key + '": ' + ($bodyLines -join $eol)
    $nl = $Raw.LastIndexOf("`n", $close - 1)
    if ($nl -lt $open) { return @{ Ok = $false } }
    $insertAt = if ($eol -eq "`r`n" -and $nl -ge 1 -and $Raw[$nl - 1] -eq "`r") { $nl - 1 } else { $nl }
    $head = $Raw.Substring(0, $insertAt)
    $tail = $Raw.Substring($insertAt + $eol.Length)
    return @{ Text = $head + ',' + $eol + $entry + $eol + $tail; Ok = $true }
}

function Update-TargetModelBindings {
    # Propagate the SOURCE capability-class registry into the target, and REMOVE every
    # concrete model binding from it (T1-E1.04 - the invariant is now absence):
    # (1) the target's registry table rows (rewritten to 2 cells, rows INSERTED for source
    #     growth, rows DELETED for source retirement),
    # (2) any `model:` line in a target agent file's frontmatter is REMOVED,
    # (3) any `agent.<key>.model` in the target's opencode.json is REMOVED,
    # (4) the structural `permission.task` allow-list of the locked-preset host
    #     `parcel-sprint` is stamped (unchanged - it is not a model binding).
    # ponytail: the removal is a member-line delete keyed on the exact `model` JSON key -
    # a model smuggled under another key is not detected; the target's own
    # check-parcel-prefix.ps1 fails loudly instead. JSON validity is re-checked after the
    # strip and the edit is REVERTED if it would not parse, so a satellite is never left
    # with a broken config.
    param([string]$SrcRoot, [string]$TgtRoot, [switch]$DryRun)
    $srcRegistry = Get-RegistryBindings (Join-Path $SrcRoot '.opencode/plans/base-context.md')
    if ($srcRegistry.Count -eq 0) {
        Write-Output 'BINDINGS: source registry empty or unreadable - nothing stamped'
        return
    }
    if ($DryRun) {
        Write-Output ("DRYRUN would reconcile {0} capability-class row(s) and strip model bindings from the target" -f $srcRegistry.Count)
        return
    }

    # 1. Target registry table (repo-specific file: rows only, prose untouched).
    #    Rows are REWRITTEN to the 2-cell shape (dropping any retired model columns), rows
    #    for keys the target lacks are INSERTED after the last existing row so template-side
    #    growth still reaches a bootstrapped satellite, and rows for keys the source retired
    #    are DELETED so a retirement does not leave the target gate-failing.
    $tgtBc = Join-Path $TgtRoot '.opencode/plans/base-context.md'
    $rows = 0
    if (Test-Path $tgtBc) {
        $raw = [System.IO.File]::ReadAllText($tgtBc) -replace "`r`n", "`n"
        $end = if ($raw.EndsWith("`n")) { "`n" } else { "" }
        $lines = [System.Collections.Generic.List[string]]($raw -split "`n")
        $present = @{}
        $lastRowIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -notmatch '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|') { continue }
            $cells = @(($lines[$i].Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
            $rk = $cells[0]
            $present[$rk] = $true
            $lastRowIdx = $i
            if (-not $srcRegistry.ContainsKey($rk)) { continue }
            $newRow = "| $rk | $($srcRegistry[$rk]['class']) |"
            if ($lines[$i] -ne $newRow) { $lines[$i] = $newRow; $rows++ }
        }
        $missing = @($srcRegistry.Keys | Where-Object { -not $present.ContainsKey($_) } | Sort-Object)
        if ($lastRowIdx -ge 0 -and $missing.Count -gt 0) {
            $insertAt = $lastRowIdx + 1
            foreach ($mk in $missing) {
                $lines.Insert($insertAt, "| $mk | $($srcRegistry[$mk]['class']) |")
                $insertAt++
                $rows++
            }
            Write-Output ("BINDINGS: inserted {0} new registry row(s): {1}" -f $missing.Count, ($missing -join ', '))
        }
        # Delete rows for keys the source registry has retired (machinery T1-E2.07): a
        # retirement must reach an already-bootstrapped satellite, or its own
        # check-parcel-prefix fails `Model Registry key '<key>' has no agent file`.
        # ponytail: keyed on the same bare-key row shape Get-RegistryBindings parses - the
        # backticked `## Orchestrator Presets` rows are never matched, and prose is untouched.
        $pruned = @()
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            if ($lines[$i] -notmatch '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|') { continue }
            $pk = @(($lines[$i].Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })[0]
            if (-not $srcRegistry.ContainsKey($pk)) { $pruned += $pk; $lines.RemoveAt($i); $rows++ }
        }
        if ($pruned.Count -gt 0) {
            Write-Output ("BINDINGS: pruned {0} stale registry row(s): {1}" -f $pruned.Count, (($pruned | Sort-Object) -join ', '))
        }
        if ($rows -gt 0) {
            [System.IO.File]::WriteAllText($tgtBc, (($lines -join "`n") + $end), (New-Object System.Text.UTF8Encoding($false)))
        }
    } else {
        Write-Output 'BINDINGS: target has no base-context.md yet - registry not stamped'
    }

    # 2. Target agent frontmatter: strip any `model:` line (the absence invariant).
    #    Frontmatter-scoped so a `model:` string in the agent body is never touched.
    $files = 0
    foreach ($key in ($srcRegistry.Keys | Sort-Object)) {
        $target = Join-Path $TgtRoot ".devops/agents/$key.agent.md"
        if (-not (Test-Path $target)) { $target = Join-Path $TgtRoot ".devops/agents/$key.subagent.md" }
        if (-not (Test-Path $target)) { Write-Output "BINDING-SKIP $key (no agent file in target)"; continue }
        $fraw = [System.IO.File]::ReadAllText($target) -replace "`r`n", "`n"
        $flines = [System.Collections.Generic.List[string]]($fraw -split "`n")
        if ($flines.Count -lt 3 -or $flines[0] -ne '---') {
            Write-Output "BINDING-SKIP $key (target agent file has no frontmatter)"; continue
        }
        $fEnd = -1
        for ($j = 1; $j -lt $flines.Count; $j++) { if ($flines[$j] -eq '---') { $fEnd = $j; break } }
        if ($fEnd -lt 0) { Write-Output "BINDING-SKIP $key (target agent frontmatter unterminated)"; continue }
        $stripped = 0
        for ($j = $fEnd - 1; $j -ge 1; $j--) {
            if ($flines[$j] -match '^model:\s') { $flines.RemoveAt($j); $stripped++ }
        }
        if ($stripped -gt 0) {
            [System.IO.File]::WriteAllText($target, ($flines -join "`n"), (New-Object System.Text.UTF8Encoding($false)))
            $files += $stripped
        }
    }

    # 3. Target opencode.json (repo-specific). Every `"model"` member line is REMOVED so the
    #    target declares no binding. Entries for registry keys the target has NEVER authored
    #    are still inserted whole from the target's own synced seed (a satellite that never
    #    authored the key carries no local intent to preserve), and the locked-preset host's
    #    `permission.task` allow-list (step 4) is still stamped - it is structural, not a model.
    #    The strip is VALIDATED: a JSON that no longer parses is reverted rather than shipped.
    $ocTarget = Join-Path $TgtRoot 'opencode.json'
    $ocCount = 0
    $ocInserted = @()
    if (Test-Path $ocTarget) {
        $ocRaw = [System.IO.File]::ReadAllText($ocTarget)
        $ocJson = $null
        try { $ocJson = $ocRaw | ConvertFrom-Json } catch { $ocJson = $null }
        if ($ocJson -and $ocJson.agent) {
            $present = @{}
            foreach ($p in $ocJson.agent.PSObject.Properties) { $present[$p.Name] = $true }
            foreach ($key in ($srcRegistry.Keys | Sort-Object)) {
                if ($present.ContainsKey($key)) { continue }
                $seedEntry = Get-SeedAgentEntry -TgtRoot $TgtRoot -Key $key
                if ($null -eq $seedEntry) {
                    Write-Output "BINDING-SKIP $key (no agent entry in target opencode.json and no seed entry to insert)"
                    continue
                }
                $added = Add-TargetAgentEntry -Raw $ocRaw -Key $key -Seed $seedEntry
                if (-not $added.Ok) {
                    Write-Output "BINDING-SKIP $key (could not locate the target opencode.json 'agent' object to insert into)"
                    continue
                }
                $ocRaw = $added.Text
                $ocInserted += $key
            }
            # 3b. Strip every `"model": "..."` member line from the target config, then prove
            #     the result still parses. A strip that would break the JSON is REVERTED and
            #     reported - a satellite is never left holding a config it cannot load.
            $ocStripped = $ocRaw
            $ocLines = [System.Collections.Generic.List[string]]($ocStripped -split "`n")
            $strippedLines = 0
            for ($j = $ocLines.Count - 1; $j -ge 0; $j--) {
                if ($ocLines[$j] -match '^\s*"model"\s*:\s*"') { $ocLines.RemoveAt($j); $strippedLines++ }
            }
            if ($strippedLines -gt 0) {
                $candidate = ($ocLines -join "`n")
                $parses = $true
                try { $null = $candidate | ConvertFrom-Json } catch { $parses = $false }
                if ($parses) {
                    $ocRaw = $candidate
                    $ocCount = $strippedLines
                } else {
                    Write-Output "BINDING-SKIP opencode.json (stripping $strippedLines model member(s) would break the JSON - reverted; fix the file by hand)"
                }
            }
            # 4. Structural task stamp (machinery T1-E2.07): the locked-preset host's
            #    `permission.task` allow-list is template-owned - the shared prefix prose
            #    names exactly which targets the batch host may spawn, so a satellite that
            #    authored the entry before a permission shipped would otherwise diverge
            #    silently from its own documented contract. Rewrite the target's
            #    parcel-sprint task object from the target's own synced seed (whole object,
            #    re-indented to the target's entry). Every other permission, key order and
            #    formatting stays as authored; any other agent's block is never touched.
            $ocTaskStamped = $false
            $psSeed = Get-SeedAgentEntry -TgtRoot $TgtRoot -Key 'parcel-sprint'
            if ($null -eq $psSeed) {
                Write-Output "BINDING-SKIP parcel-sprint (no seed entry to stamp the structural task allow-list from)"
            } else {
                $seedTaskM = [regex]::Match($psSeed.Body, '"task"\s*:\s*\{')
                if (-not $seedTaskM.Success) {
                    Write-Output "BINDING-SKIP parcel-sprint (seed entry carries no task object)"
                } else {
                    $seedTaskOpen = $psSeed.Body.IndexOf('{', $seedTaskM.Index)
                    $seedTaskClose = Find-MatchingBrace $psSeed.Body $seedTaskOpen
                    $psEntryM = [regex]::Match($ocRaw, '"parcel-sprint"\s*:\s*\{')
                    if ($seedTaskOpen -lt 0 -or $seedTaskClose -lt 0 -or -not $psEntryM.Success) {
                        Write-Output "BINDING-SKIP parcel-sprint (task object not locatable for structural stamp)"
                    } else {
                        $psEntryOpen = $ocRaw.IndexOf('{', $psEntryM.Index)
                        $psEntryClose = Find-MatchingBrace $ocRaw $psEntryOpen
                        $tgtTaskM = [regex]::Match($ocRaw.Substring($psEntryOpen, $psEntryClose - $psEntryOpen), '"task"\s*:\s*\{')
                        if (-not $tgtTaskM.Success) {
                            Write-Output "BINDING-SKIP parcel-sprint (target task is not an object; structural stamp skipped)"
                        } else {
                            $tgtTaskOpen = $psEntryOpen + $tgtTaskM.Index + $tgtTaskM.Value.IndexOf('{')
                            $tgtTaskClose = Find-MatchingBrace $ocRaw $tgtTaskOpen
                            $seedTaskText = $psSeed.Body.Substring($seedTaskOpen, $seedTaskClose - $seedTaskOpen + 1)
                            $tgtEol = if ($ocRaw -match "`r`n") { "`r`n" } else { "`n" }
                            $seedKeyLineStart = $psSeed.Body.LastIndexOf("`n", $seedTaskM.Index) + 1
                            $seedKeyIndent = $psSeed.Body.Substring($seedKeyLineStart, $seedTaskM.Index - $seedKeyLineStart)
                            $tgtTaskKeyIdx = $psEntryOpen + $tgtTaskM.Index
                            $tgtKeyLineStart = $ocRaw.LastIndexOf("`n", $tgtTaskKeyIdx) + 1
                            $tgtKeyIndent = $ocRaw.Substring($tgtKeyLineStart, $tgtTaskKeyIdx - $tgtKeyLineStart)
                            $rebuilt = @()
                            foreach ($sline in ($seedTaskText -split "`n")) {
                                if ($sline.StartsWith($seedKeyIndent)) { $rebuilt += $tgtKeyIndent + $sline.Substring($seedKeyIndent.Length) }
                                else { $rebuilt += $sline }
                            }
                            $newTaskText = $rebuilt -join $tgtEol
                            $oldTaskText = $ocRaw.Substring($tgtTaskOpen, $tgtTaskClose - $tgtTaskOpen + 1)
                            if ($oldTaskText -ne $newTaskText) {
                                $ocRaw = $ocRaw.Remove($tgtTaskOpen, $tgtTaskClose - $tgtTaskOpen + 1).Insert($tgtTaskOpen, $newTaskText)
                                $ocTaskStamped = $true
                            }
                        }
                    }
                }
            }
            if ($ocTaskStamped) { Write-Output "BINDINGS: stamped parcel-sprint structural task allow-list from seed" }
            if ($ocCount -gt 0 -or $ocInserted.Count -gt 0 -or $ocTaskStamped) { [System.IO.File]::WriteAllText($ocTarget, $ocRaw, (New-Object System.Text.UTF8Encoding($false))) }
            if ($ocInserted.Count -gt 0) { Write-Output ("BINDINGS: inserted {0} missing agent entry/entries: {1}" -f $ocInserted.Count, ($ocInserted -join ', ')) }
        }
    }
    Write-Output "BINDINGS: reconciled $rows registry row(s), stripped $files frontmatter model line(s), stripped $ocCount opencode model member(s)"
}
