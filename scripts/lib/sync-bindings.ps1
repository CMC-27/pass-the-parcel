# sync-bindings.ps1 — the Model Registry force-propagation over the three binding surfaces
# (registry rows in base-context.md, agent frontmatter, opencode.json model values).
# Dot-sourced by scripts/sync-architecture.ps1 (see scripts/lib/README.md). Portable.

function Get-RegistryBindings {
    # Parse a `## Model Registry` table out of a base-context file:
    # key -> @{class;vscode;opencode} (class is the capability-class cell, used when
    # INSERTING a row for a key the target registry does not carry yet).
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { return $map }
    $text = ([System.IO.File]::ReadAllText($Path)) -replace "`r`n", "`n"
    foreach ($line in ($text -split "`n")) {
        if ($line -match '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|') {
            $map[$Matches[1]] = @{ class = $Matches[2]; vscode = $Matches[3]; opencode = $Matches[4] }
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
    # Force-propagate the SOURCE Model Registry into the target's binding surfaces:
    # (1) the target's registry table rows (rewritten, plus rows INSERTED for keys the
    # target lacks - registry growth must reach an existing satellite - and rows
    # DELETED for keys the source retired, so a retirement does not leave the
    # target gate-failing), (2) each target agent file's frontmatter `model:` line,
    # (3) each present target opencode.json `agent.<key>.model` value, plus (4) the
    # structural `permission.task` allow-list of the locked-preset host `parcel-sprint`.
    # There is no preservation branch: a satellite-side rebind is transient by contract.
    # ponytail: naive 4-cell registry row rewrite keyed on the first cell - a reordered or
    # 3-cell table is left alone and fails loudly in check-parcel-prefix instead.
    # ponytail: missing agent entries are inserted whole from the target's own synced seed;
    # an entry the satellite already authored only ever has its `model` value rewritten.
    # A target whose `agent` object cannot be located (empty object / hand-minified JSON) is
    # still not repaired - it reports BINDING-SKIP and the validator FAILs loudly.
    param([string]$SrcRoot, [string]$TgtRoot, [switch]$DryRun)
    $srcRegistry = Get-RegistryBindings (Join-Path $SrcRoot '.opencode/plans/base-context.md')
    if ($srcRegistry.Count -eq 0) {
        Write-Output 'BINDINGS: source registry empty or unreadable - nothing stamped'
        return
    }
    if ($DryRun) {
        Write-Output ("DRYRUN would stamp {0} model binding(s) into the target" -f $srcRegistry.Count)
        return
    }

    # 1. Target registry table (repo-specific file: rows only, prose untouched).
    #    Existing rows are REWRITTEN to the source binding; rows for keys the target
    #    does not carry are INSERTED after the last existing registry row, so a
    #    template-side registry growth (e.g. v39's 10 -> 12 rows) reaches an
    #    already-bootstrapped satellite instead of leaving the target's own
    #    check-parcel-prefix.ps1 permanently red (`no Model Registry row for '<key>'`).
    $tgtBc = Join-Path $TgtRoot '.opencode/plans/base-context.md'
    $rows = 0
    if (Test-Path $tgtBc) {
        $raw = [System.IO.File]::ReadAllText($tgtBc) -replace "`r`n", "`n"
        $end = if ($raw.EndsWith("`n")) { "`n" } else { "" }
        $lines = [System.Collections.Generic.List[string]]($raw -split "`n")
        $present = @{}
        $lastRowIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -notmatch '^\|\s*([a-z0-9-]+)\s*\|') { continue }
            $rk = $Matches[1]
            $present[$rk] = $true
            $lastRowIdx = $i
            if (-not $srcRegistry.ContainsKey($rk)) { continue }
            $cls = ([regex]::Match($lines[$i], '^\|\s*[a-z0-9-]+\s*\|\s*([^|]+?)\s*\|')).Groups[1].Value
            $newRow = "| $rk | $cls | $($srcRegistry[$rk]['vscode']) | $($srcRegistry[$rk]['opencode']) |"
            if ($lines[$i] -ne $newRow) { $lines[$i] = $newRow; $rows++ }
        }
        # Insert rows for keys the target registry is missing. ponytail: anchored on the
        # last existing registry row; a re-laid-out table is not detected - the target's
        # check-parcel-prefix fails loud instead of a row being silently misplaced.
        $missing = @($srcRegistry.Keys | Where-Object { -not $present.ContainsKey($_) } | Sort-Object)
        if ($lastRowIdx -ge 0 -and $missing.Count -gt 0) {
            $insertAt = $lastRowIdx + 1
            foreach ($mk in $missing) {
                $lines.Insert($insertAt, "| $mk | $($srcRegistry[$mk]['class']) | $($srcRegistry[$mk]['vscode']) | $($srcRegistry[$mk]['opencode']) |")
                $insertAt++
                $rows++
            }
            Write-Output ("BINDINGS: inserted {0} new registry row(s): {1}" -f $missing.Count, ($missing -join ', '))
        }
        # Delete rows for keys the source registry has retired (machinery T1-E2.07): a
        # retirement must reach an already-bootstrapped satellite, or its own
        # check-parcel-prefix fails `Model Registry key '<key>' has no agent file` and
        # the next pull exits 1. ponytail: keyed on the same 4-cell binding-row shape
        # Get-RegistryBindings parses - any other table row is left alone even when its
        # first cell is lowercase. Prose is untouched; only rows are removed.
        $pruned = @()
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            $pm = [regex]::Match($lines[$i], '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|')
            if (-not $pm.Success) { continue }
            if (-not $srcRegistry.ContainsKey($pm.Groups[1].Value)) { $pruned += $pm.Groups[1].Value; $lines.RemoveAt($i); $rows++ }
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

    # 2. Target agent frontmatter.
    $files = 0
    foreach ($key in ($srcRegistry.Keys | Sort-Object)) {
        $target = Join-Path $TgtRoot ".devops/agents/$key.agent.md"
        if (-not (Test-Path $target)) { $target = Join-Path $TgtRoot ".devops/agents/$key.subagent.md" }
        if (-not (Test-Path $target)) { Write-Output "BINDING-SKIP $key (no agent file in target)"; continue }
        $fraw = [System.IO.File]::ReadAllText($target) -replace "`r`n", "`n"
        $m = [regex]::Match($fraw, '(?m)^model:\s*(.+?)\s*$')
        if (-not $m.Success) { Write-Output "BINDING-SKIP $key (no model: line in $key)"; continue }
        $want = $srcRegistry[$key]['vscode']
        if ($m.Groups[1].Value -ne $want) {
            $fraw = $fraw.Remove($m.Index, $m.Length).Insert($m.Index, "model: $want")
            [System.IO.File]::WriteAllText($target, $fraw, (New-Object System.Text.UTF8Encoding($false)))
            $files++
        }
    }

    # 3. Target opencode.json (repo-specific). Entries the target ALREADY carries: only the
    #    `model` value is rewritten - permissions, key order and formatting stay as authored -
    #    EXCEPT the locked-preset host's `permission.task` allow-list (step 4 below), which
    #    is structural, like `model`. Entries for registry keys the target has NEVER
    #    authored: inserted whole from the target's own synced seed, then stamped.
    #    Entries for registry keys the target has NEVER authored: inserted whole from the
    #    target's own synced seed, then stamped. A key the satellite never authored carries no
    #    local intent to preserve, so the seed's permission block is the sanctioned default
    #    (machinery v41 - the ponytail ceiling's own named upgrade path; the ceiling's
    #    guarantee, "never restructure an entry the satellite authored", still holds).
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
            foreach ($key in ($srcRegistry.Keys | Sort-Object)) {
                $wantOc = $srcRegistry[$key]['opencode']
                $pattern = '("' + [regex]::Escape($key) + '"\s*:\s*\{[^}]*?"model"\s*:\s*")([^"]*)(")'
                $hit = [regex]::Match($ocRaw, $pattern)
                if (-not $hit.Success) { Write-Output "BINDING-SKIP $key (model value not locatable in target opencode.json)"; continue }
                if ($hit.Groups[2].Value -ne $wantOc) {
                    $ocRaw = $ocRaw.Remove($hit.Index, $hit.Length).Insert($hit.Index, $hit.Groups[1].Value + $wantOc + $hit.Groups[3].Value)
                    $ocCount++
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
    Write-Output "BINDINGS: stamped/inserted $rows registry row(s), $files frontmatter line(s), $ocCount opencode model value(s)"
}
