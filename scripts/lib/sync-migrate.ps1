# sync-migrate.ps1 — the T1-E1.05 `opencode.json` key-shape migration, extracted whole from
# `Update-TargetModelBindings` (T1-E4.05) so the bindings module keeps its seam and the
# migration keeps its own. The result is returned through the caller's `$State` hashtable,
# never as a function return value: the function's own lines are `Write-Output`, and a
# returned value would capture them into the caller's variable and drop them from the run's
# output - the same reason `Invoke-StructuralVerify` reports through a hashtable.
#
# Dot-sourced by scripts/sync-architecture.ps1. Portable.
#
    # 5. Config key-shape migration (T1-E1.05): move the target's `skills` to the
    #    V2-native flat array and delete the config member V2 accepts but does not load
    #    ("instructions"). Both halves are line-level, like the model strip above, and
    #    run under the same re-parse-and-revert guard. This is the first template-side
    #    write over keys the satellite authored: the `skills` path ENTRIES are carried
    #    verbatim (never replaced with the default), and a shape the migration cannot
    #    migrate without destroying a declaration (a `urls` member) is left exactly as
    #    authored with a printed operator remedy. A refusal is shape-scoped - it skips
    #    only the shape rewrite, while the member delete is an independent half.
    #    ponytail: exactly the two keys named, by their exact literals - not a general
    #    V2 renamer and not a declarative key-shape map; a future rename needs a new rule.
function Invoke-ConfigShapeMigration {
    param(
        [string]$Raw,
        [hashtable]$State
    )
    $ocMigrated = 0
    $ocRaw = $Raw
    $ocMigrateRaw = $ocRaw
    $ocMigrated = 0
    $ocMigrateRaw = $ocRaw
    $skM = [regex]::Match($ocMigrateRaw, '"skills"\s*:\s*\{')
    if ($skM.Success) {
        $skOpen = $ocMigrateRaw.IndexOf('{', $skM.Index)
        $skClose = Find-MatchingBrace $ocMigrateRaw $skOpen
        if ($skOpen -ge 0 -and $skClose -gt $skOpen) {
            $skObj = $ocMigrateRaw.Substring($skOpen, $skClose - $skOpen + 1)
            if ($skObj -match '"urls"\s*:') {
                Write-Output "BINDINGS: opencode.json 'skills' carries 'urls' - left exactly as authored (the V2 flat array has no 'urls' slot); keep the V1 object and stay -Verify-red, or drop the declaration and re-run the sync"
            } else {
                $skPathsM = [regex]::Match($skObj, '"paths"\s*:\s*\[([^\]]*)\]')
                $skEntries = @()
                if ($skPathsM.Success) {
                    foreach ($skE in [regex]::Matches($skPathsM.Groups[1].Value, '"([^"]*)"')) {
                        if ($skE.Groups[1].Value) { $skEntries += $skE.Groups[1].Value }
                    }
                }
                if (-not $skPathsM.Success -or $skEntries.Count -eq 0) {
                    Write-Output "BINDINGS: opencode.json 'skills' is an object without a non-empty 'paths' array - left exactly as authored; rewrite the key as the flat V2 array by hand and re-run the sync"
                } else {
                    $skFlat = '[' + (($skEntries | ForEach-Object { '"' + $_ + '"' }) -join ', ') + ']'
                    $ocMigrateRaw = $ocMigrateRaw.Remove($skOpen, $skClose - $skOpen + 1).Insert($skOpen, $skFlat)
                    $ocMigrated++
                }
            }
        }
    }
    # (b) the member V2 accepts but does not load - ROOT-SCOPED BY BRACE DEPTH, never by
    #     indent: the only candidate is the member line whose ENCLOSING brace chain is
    #     exactly the root object's own opening brace (string-aware stack scan), so a
    #     same-named member nested inside an agent entry - or one that merely follows a
    #     closed sibling object - is never selected. If the
    #     root object cannot be located, the migration refuses and reports.
    $ocRootOpen = $ocMigrateRaw.IndexOf('{')
    $ocRootClose = if ($ocRootOpen -ge 0) { Find-MatchingBrace $ocMigrateRaw $ocRootOpen } else { -1 }
    if ($ocRootOpen -lt 0 -or $ocRootClose -lt 0) {
        Write-Output "BINDINGS: opencode.json root object could not be located - the config member V2 accepts but does not load was left as authored; make the edit by hand and re-run the sync"
    } else {
        $ocInstrMoves = @()
        foreach ($im in [regex]::Matches($ocMigrateRaw, '(?m)^[ \t]*"instructions"\s*:')) {
            $at = $im.Index
            # Enclosing brace chain at the member's line start: the member is root-scoped
            # only when the ONLY open brace enclosing it is the root object's own. A
            # sibling object that opened and closed earlier is not an ancestor.
            $braceStack = New-Object System.Collections.Generic.List[int]
            $inStr = $false; $esc = $false
            for ($i = $ocRootOpen; $i -lt $at; $i++) {
                $ch = $ocMigrateRaw[$i]
                if ($inStr) {
                    if ($esc) { $esc = $false }
                    elseif ($ch -eq '\') { $esc = $true }
                    elseif ($ch -eq '"') { $inStr = $false }
                } else {
                    if ($ch -eq '"') { $inStr = $true }
                    elseif ($ch -eq '{') { $braceStack.Add($i) }
                    elseif ($ch -eq '}') { if ($braceStack.Count -gt 0) { $braceStack.RemoveAt($braceStack.Count - 1) } }
                }
            }
            if (($braceStack.Count -eq 1) -and ($braceStack[0] -eq $ocRootOpen)) {
                $ocLineStart = $ocMigrateRaw.LastIndexOf("`n", $at) + 1
                $ocLineEnd = $ocMigrateRaw.IndexOf("`n", $at)
                $ocInstrMoves += , @($ocLineStart, $ocLineEnd)
            }
        }
        for ($c = $ocInstrMoves.Count - 1; $c -ge 0; $c--) {
            $ls = $ocInstrMoves[$c][0]; $le = $ocInstrMoves[$c][1]
            if ($le -lt 0) { $ocMigrateRaw = $ocMigrateRaw.Substring(0, $ls) }
            else { $ocMigrateRaw = $ocMigrateRaw.Remove($ls, $le - $ls + 1) }
            $ocMigrated++
        }
    }
    if ($ocMigrateRaw -ne $ocRaw) {
        $ocMigrateParses = $true
        try { $null = $ocMigrateRaw | ConvertFrom-Json } catch { $ocMigrateParses = $false }
        # Both verdicts (see the model strip above): the migration's own delete is what
        # produces the dangling comma on this host's lenient parser (T1-E2.11).
        if ($ocMigrateParses -and (Test-JsonShape $ocMigrateRaw)) {
            $ocRaw = $ocMigrateRaw
        } else {
            $ocMigrated = 0
            Write-Output "BINDING-SKIP opencode.json (the key-shape migration would break the JSON - reverted; fix the file by hand)"
            Write-Output "BINDINGS: opencode.json key-shape migration reverted - the file was left byte-identical; make the named edit by hand, then re-run the sync"
        }
    }
    $State.Text = $ocRaw
    $State.Count = $ocMigrated
}
