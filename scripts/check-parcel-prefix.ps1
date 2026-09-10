param(
    [switch]$Sync
)

<#
.SYNOPSIS
    Verifies (and optionally repairs) the PREFIX-LOCKED byte-for-byte contract
    between .opencode/plans/base-context.md and every PREFIX-LOCKED agent file
    (.devops/agents/parcel.agent.md + .devops/agents/ptp-*.subagent.md), the
    verbatim skill-embed contract inside each ptp-* agent file, and the
    opencode.json <-> Model Registry model-binding agreement.

.DESCRIPTION
    The pass-the-parcel pipeline relies on a byte-for-byte identical shared prefix
    inlined into every parcel/ptp agent file. That identical prefix maximizes KV-cache
    hits across agent invocations. Any drift (editing one file, not the others, or
    CRLF/LF corruption) silently destroys the cache benefit.

    base-context.md carries an optional ORCHESTRATOR-ONLY block (delegation map +
    model registry). Content ABOVE that block is the shared prefix (inlined into all
    locked agents); the full file (markers stripped) is the orchestrator prefix (inlined
    into parcel.agent.md only). If the markers are absent, every agent gets the full
    canonical prefix (backward compatible).

    Each ptp-* agent also embeds its delegated skill VERBATIM between
    <!-- EMBED:START:<skill> --> / <!-- EMBED:END --> markers. The embed must be
    byte-identical to the SKILL.md body (frontmatter stripped). -Sync regenerates it.

    Agents physically live in .devops/agents/ as VS Code custom agent files
    (parcel.agent.md = selectable, ptp-*.subagent.md = subagents). Each carries
    YAML frontmatter (description/tools/model/user-invocable) followed by the
    PREFIX-LOCKED prefix and the agent-unique content (everything from the first
    "## Delegated Skill:" heading, or "You are the" for the orchestrator).

    The opencode runtime binding lives in opencode.json `agent.<key>.model` and is
    validated against the Model Registry's opencode column. A present agent block
    fails on a missing key, a mismatched model, or the unresolved
    `<your provider/model>` placeholder. An absent opencode.json, or an absent/empty
    agent block, is a documented opt-out for VS Code-only satellites -> SKIP.

    Without -Sync:  prints PASS/FAIL per agent file and exits non-zero if any drift.
    With -Sync:     rebuilds each agent file's prefix from base-context.md and refreshes
                    each skill embed from its SKILL.md, preserving frontmatter and the
                    agent-unique content outside the embed markers.

.NOTES
    Run after editing base-context.md or any ptp SKILL.md:
        powershell -File scripts\check-parcel-prefix.ps1 -Sync
    Run as a pre-commit / CI gate:
        powershell -File scripts\check-parcel-prefix.ps1
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$canonicalPath = Join-Path $root '.opencode\plans\base-context.md'
$agentsDir = Join-Path $root '.devops\agents'

if (-not (Test-Path $canonicalPath)) { throw "Canonical header not found: $canonicalPath" }
if (-not (Test-Path $agentsDir)) { throw "Agent runbook directory not found: $agentsDir" }

# Read canonical prefix as UTF-8. Normalize to LF so CRLF/LF drift never masks real drift.
$canonical = [System.IO.File]::ReadAllText($canonicalPath)
$canonical = $canonical -replace "`r`n", "`n"
$canonical = $canonical.TrimEnd("`n")

# --- Split the canonical prefix at the ORCHESTRATOR-ONLY block (if present) ---
# shared = content above the START marker (inlined into ALL locked agents).
# full   = whole file with the two marker lines stripped (inlined into parcel.agent.md only).
# No markers -> shared == full == canonical (backward compatible with pre-split satellites).
$canonicalLines = $canonical -split "`n"
$orchStartIdx = -1; $orchEndIdx = -1
for ($i = 0; $i -lt $canonicalLines.Count; $i++) {
    if ($orchStartIdx -lt 0 -and $canonicalLines[$i] -match '^<!--\s*ORCHESTRATOR-ONLY:START') { $orchStartIdx = $i }
    elseif ($orchStartIdx -ge 0 -and $orchEndIdx -lt 0 -and $canonicalLines[$i] -match '^<!--\s*ORCHESTRATOR-ONLY:END') { $orchEndIdx = $i }
}
if ($orchStartIdx -ge 0 -and $orchEndIdx -gt $orchStartIdx) {
    $sharedPrefix = (($canonicalLines[0..($orchStartIdx - 1)]) -join "`n").TrimEnd("`n")
    $fullPrefix = (($canonicalLines | Where-Object { $_ -notmatch '^<!--\s*ORCHESTRATOR-ONLY:(START|END)' }) -join "`n").TrimEnd("`n")
} else {
    $sharedPrefix = $canonical
    $fullPrefix = $canonical
}

# PREFIX-LOCKED set: the selectable parcel agent + the ptp-* subagents.
# All agents are VS Code custom agent files in .devops/agents/ (no .opencode/agents/
# mirror exists; the opencode runtime is configured in opencode.json, validated below).
$agentFiles = @()
$agentFiles += @(Get-ChildItem -Path $agentsDir -Filter 'parcel.agent.md' -ErrorAction SilentlyContinue)
$agentFiles += @(Get-ChildItem -Path $agentsDir -Filter 'ptp-*.subagent.md' -ErrorAction SilentlyContinue)
$agentFiles = @($agentFiles | Where-Object { $_ }) | Sort-Object Name
if (-not $agentFiles) { throw "No PREFIX-LOCKED agent files found (parcel.agent.md / ptp-*.subagent.md in $agentsDir)" }

$failures = @()

# --- Model binding registry (see .devops/skills/model-routing/SKILL.md) ---
# Parse the canonical Model Registry table: | Agent key | Capability class | VS Code model | opencode model |
# Each agent file's frontmatter `model:` must equal the value in the column matching its runtime.
$modelBindings = @{}
foreach ($line in ($canonical -split "`n")) {
    if ($line -match '^\|\s*(parcel|ptp-[a-z0-9-]+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|') {
        $modelBindings[$Matches[1]] = @{ vscode = $Matches[3]; opencode = $Matches[4] }
    }
}

foreach ($file in $agentFiles) {
    # Read as UTF-8 (PS 5.1 Get-Content would misread UTF-8 as ANSI and mangle chars).
    $raw = [System.IO.File]::ReadAllText($file.FullName)
    $raw = $raw -replace "`r`n", "`n"

    # VS Code agent files carry YAML frontmatter. Strip it; the PREFIX-LOCKED prefix
    # sits immediately after the closing ---.
    $frontmatter = ""
    $body = $raw
    if ($raw.StartsWith("---`n")) {
        $closeIdx = $raw.IndexOf("`n---`n", 4)
        if ($closeIdx -ge 0) {
            $frontmatter = $raw.Substring(0, $closeIdx + 5)  # includes closing --- + newline
            $body = $raw.Substring($closeIdx + 5)
        }
    }

    # Locate the agent-unique content start.
    $skillIdx = $body.IndexOf("## Delegated Skill:")
    $orchestratorIdx = $body.IndexOf("You are the")
    if ($skillIdx -ge 0 -and $orchestratorIdx -ge 0) {
        $uniqueStart = [Math]::Min($skillIdx, $orchestratorIdx)
    } elseif ($skillIdx -ge 0) {
        $uniqueStart = $skillIdx
    } elseif ($orchestratorIdx -ge 0) {
        $uniqueStart = $orchestratorIdx
    } else {
        $failures += "$($file.Name): no unique-content marker found"; continue
    }

    $unique = $body.Substring($uniqueStart).TrimStart("`n")

    # --- Skill-embed contract (ptp-* agents only) ---
    # The region between EMBED markers must be byte-identical to the delegated skill's
    # SKILL.md body (frontmatter stripped, LF-normalized, trimmed). -Sync regenerates it.
    $key = $file.BaseName -replace '\.(agent|subagent)$', ''
    $embedFail = $false
    if ($key -like 'ptp-*') {
        $startMarker = "<!-- EMBED:START:$key -->"
        $endMarker = "<!-- EMBED:END -->"
        $sIdx = $unique.IndexOf($startMarker)
        $eIdx = $unique.IndexOf($endMarker)
        if ($sIdx -lt 0 -or $eIdx -lt 0 -or $eIdx -lt $sIdx) {
            $failures += "$($file.Name): missing EMBED markers ('$startMarker' / '$endMarker') - add them around the embedded skill copy"; $embedFail = $true
        } else {
            $skillPath = Join-Path $root ".devops\skills\$key\SKILL.md"
            if (-not (Test-Path $skillPath)) {
                $failures += "$($file.Name): delegated skill not found at .devops\skills\$key\SKILL.md"; $embedFail = $true
            } else {
                $skillRaw = [System.IO.File]::ReadAllText($skillPath)
                $skillRaw = $skillRaw -replace "`r`n", "`n"
                $skillBody = $skillRaw
                if ($skillRaw.StartsWith("---`n")) {
                    $sc = $skillRaw.IndexOf("`n---`n", 4)
                    if ($sc -ge 0) { $skillBody = $skillRaw.Substring($sc + 5) }
                }
                $skillBody = $skillBody.Trim("`n")
                $inner = $unique.Substring($sIdx + $startMarker.Length, $eIdx - ($sIdx + $startMarker.Length)).Trim("`n")
                if ($inner -ne $skillBody) {
                    if ($Sync) {
                        $unique = $unique.Substring(0, $sIdx) + $startMarker + "`n" + $skillBody + "`n" + $unique.Substring($eIdx)
                        Write-Output "EMBED $($file.Name): refreshed from .devops\skills\$key\SKILL.md"
                    } else {
                        $failures += "$($file.Name): skill embed drift vs .devops\skills\$key\SKILL.md (run with -Sync to repair)"; $embedFail = $true
                    }
                }
            }
        }
    }

    # Rebuild expected content: frontmatter + prefix (shared or full) + blank line + unique.
    $prefixForFile = if ($key -eq 'parcel') { $fullPrefix } else { $sharedPrefix }
    $expected = $frontmatter + $prefixForFile + "`n`n" + $unique

    if ($raw.TrimEnd("`n") -eq $expected.TrimEnd("`n")) {
        Write-Output "PASS  $($file.Name)"
    } else {
        if ($Sync -and -not $embedFail) {
            # Write with LF, then let .gitattributes normalize on commit.
            [System.IO.File]::WriteAllText($file.FullName, $expected, (New-Object System.Text.UTF8Encoding($false)))
            Write-Output "FIXED $($file.Name)"
        } elseif ($Sync) {
            $failures += "$($file.Name): skipped -Sync write due to unresolved embed error above"
        } else {
            $failures += "$($file.Name): prefix drift detected (run with -Sync to repair)"
        }
    }

    # --- Model binding check (declarative routing; see model-routing skill) ---
    if ($frontmatter -and $modelBindings.Count -gt 0) {
        # Derive registry key: strip .agent.md / .subagent.md / .md.
        if (-not $key) { $key = $file.BaseName -replace '\.(agent|subagent)$', '' }
        if (-not $modelBindings.ContainsKey($key)) {
            Write-Output "SKIP  $($file.Name): no Model Registry row for '$key' (non-parcel agent)"
        } else {
            $modelMatch = [regex]::Match($frontmatter, '(?m)^model:\s*(.+?)\s*$')
            if (-not $modelMatch.Success) {
                $failures += "$($file.Name): frontmatter has no 'model:' line but a registry row exists"
            } else {
                # All PREFIX-LOCKED agents are VS Code files now (.devops/agents/).
                $runtime = 'vscode'
                $actual = $modelMatch.Groups[1].Value.Trim('`', ' ')
                $expectedModel = $modelBindings[$key][$runtime]
                if ($actual -ne $expectedModel) {
                    $failures += "$($file.Name): model binding mismatch - frontmatter '$actual' != registry '$expectedModel' ($runtime). See model-routing skill section 3."
                } else {
                    Write-Output "MODEL $actual  $($file.Name)"
                }
            }
        }
    }
}

Write-Output "---"
Write-Output ("Canonical source: " + $canonicalPath)

# --- opencode.json <-> Model Registry validation ---
# Present agent block: every registry key must exist, with a model matching the registry's
# opencode column and not the unresolved `<your provider/model>` placeholder.
# Absent opencode.json, or an absent/empty `agent` block, is a documented opt-out for
# VS Code-only satellites -> SKIP, no failure (the pre-v20 seed instructed satellites to
# delete the block, so it must stay valid).
$ocPath = Join-Path $root 'opencode.json'
if (-not (Test-Path $ocPath)) {
    Write-Output 'SKIP  opencode.json: not present (VS Code-only satellite)'
} else {
    try {
        $oc = Get-Content -Raw $ocPath | ConvertFrom-Json
        $ocAgents = $oc.agent
        $agentProps = if ($ocAgents) { @($ocAgents.PSObject.Properties) } else { @() }
        if ($agentProps.Count -eq 0) {
            Write-Output 'SKIP  opencode.json: no agent block (VS Code-only satellite)'
        } else {
            foreach ($key in ($modelBindings.Keys | Sort-Object)) {
                $prop = $ocAgents.PSObject.Properties[$key]
                if (-not $prop) {
                    $failures += "opencode.json: no agent entry for registry key '$key'"
                    continue
                }
                $val = [string]$prop.Value.model
                $expected = $modelBindings[$key]['opencode']
                if (-not $val) {
                    $failures += "opencode.json: agent '$key' has no model (registry expects '$expected')"
                } elseif ($val -eq '<your provider/model>') {
                    $failures += "opencode.json: agent '$key' still has the placeholder model '<your provider/model>'"
                } elseif ($val -ne $expected) {
                    $failures += "opencode.json: agent '$key' model '$val' != registry '$expected'"
                } else {
                    Write-Output "OC-MODEL $val  agent.$key"
                }
            }
        }
    } catch {
        $failures += "opencode.json: not valid JSON ($($_.Exception.Message))"
    }
}

if ($failures.Count -gt 0) {
    Write-Output "FAILURES:"
    $failures | ForEach-Object { Write-Output "  $_" }
    exit 1
}
Write-Output "OK: all PREFIX-LOCKED agents share a byte-identical prefix."
