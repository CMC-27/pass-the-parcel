param(
    [switch]$Sync
)

<#
.SYNOPSIS
    Verifies (and optionally repairs) the PREFIX-LOCKED byte-for-byte contract
    between .opencode/plans/base-context.md and every PREFIX-LOCKED agent file
    (.devops/agents/parcel*.agent.md + .devops/agents/ptp-*.subagent.md), the
    verbatim skill-embed contract inside each ptp-* agent file, and the
    model-ABSENCE invariant across every binding surface: no binding file
    frontmatter, neither opencode config, and no registry row may declare a model.

.DESCRIPTION
    The pass-the-parcel pipeline relies on a byte-for-byte identical shared prefix
    inlined into every parcel/ptp agent file. That identical prefix maximizes KV-cache
    hits across agent invocations. Any drift (editing one file, not the others, or
    CRLF/LF corruption) silently destroys the cache benefit.

    base-context.md carries an optional ORCHESTRATOR-ONLY block (delegation map +
    capability-class registry). Content ABOVE that block is the shared prefix (inlined into all
    locked agents); the full file (markers stripped) is the orchestrator prefix (inlined
    into the orchestrator agents only). If the markers are absent, every agent gets the full
    canonical prefix (backward compatible).

    Each ptp-* agent also embeds its delegated skill VERBATIM between
    <!-- EMBED:START:<skill> --> / <!-- EMBED:END --> markers. The embed must be
    byte-identical to the SKILL.md body (frontmatter stripped). -Sync regenerates it.

    Agents physically live in .devops/agents/ as VS Code custom agent files
    (parcel.agent.md / parcel-sprint.agent.md = selectable, ptp-*.subagent.md = subagents). Each carries
    YAML frontmatter (description/tools/user-invocable) followed by the
    PREFIX-LOCKED prefix and the agent-unique content (everything from the first
    "## Delegated Skill:" heading, or "You are the" for the orchestrator).

    Model routing is INHERITED (T1-E1.04). No agent declares a model; every agent runs on the
    model selected in the CLI / picker. The `## Model Registry` in base-context.md is now a
    CAPABILITY-CLASS reference (two cells per row) that feeds the run-time selection question -
    it is not a binding. This script asserts the invariant by ABSENCE, reporting `NOMODEL` per
    clean binding surface and failing on:
      - a `model:` line in any binding file's frontmatter;
      - an `agent.<key>.model` in opencode.json or its seed;
      - a registry row carrying anything other than exactly two cells;
      - a registry key with no agent file, or a binding file with no registry row (coverage).

    Binding files (parcel* / ptp-* / wiki-*) are resolved from registry keys, NOT from
    the PREFIX-LOCKED file list: wiki-writer.agent.md and wiki-verifier.subagent.md
    carry no shared prefix, so they must never enter the prefix pass.

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
# full   = whole file with the two marker lines stripped (inlined into parcel.agent.md / parcel-sprint.agent.md only).
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

# PREFIX-LOCKED set: the selectable orchestrator agents + the ptp-* subagents.
# All agents are VS Code custom agent files in .devops/agents/ (no .opencode/agents/
# mirror exists; the opencode runtime is configured in opencode.json, validated below).
$agentFiles = @()
$agentFiles += @(Get-ChildItem -Path $agentsDir -Filter 'parcel*.agent.md' -ErrorAction SilentlyContinue)
$agentFiles += @(Get-ChildItem -Path $agentsDir -Filter 'ptp-*.subagent.md' -ErrorAction SilentlyContinue)
$agentFiles = @($agentFiles | Where-Object { $_ }) | Sort-Object Name
if (-not $agentFiles) { throw "No PREFIX-LOCKED agent files found (parcel*.agent.md / ptp-*.subagent.md in $agentsDir)" }

$failures = @()

# --- Capability-class registry (see .devops/skills/model-routing/SKILL.md) ---
# Parse the canonical `## Model Registry` table: | Agent key | Capability class |
# Rows must carry EXACTLY TWO cells. A model column is the failure this check now asserts -
# the invariant inverted in T1-E1.04: no binding surface may declare a concrete model.
$registryKeys = @{}
foreach ($line in ($canonical -split "`n")) {
    if ($line -match '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|') {
        $cells = @(($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
        if ($cells.Count -ne 2) {
            $failures += "registry row must carry exactly 2 cells - found $($cells.Count) for key '$($cells[0])' in .opencode/plans/base-context.md"
        } else {
            $registryKeys[$cells[0]] = $cells[1]
        }
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
    # Orchestrator agents (parcel*, keyed) get the full prefix incl. the ORCHESTRATOR-ONLY block.
    $prefixForFile = if ($key -like 'parcel*') { $fullPrefix } else { $sharedPrefix }
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

}

# --- Model-absence pass (INVERTED; see model-routing skill §4) ---
# Decoupled from the prefix pass on purpose: binding files include the wiki-* agents,
# which carry no shared PREFIX-LOCKED prefix.
# The invariant is now ABSENCE. No binding surface may declare a concrete model:
#   (a) a `model:` line in any binding file's frontmatter  -> FAIL
#   (b) an `agent.<key>.model` in either config            -> FAIL
#   (c) a third cell in any registry row                   -> FAIL (checked above)
# Coverage stays bidirectional: key-without-file and file-without-row both FAIL.
$bindingFiles = @{}
foreach ($bf in @(Get-ChildItem -Path $agentsDir -File -ErrorAction SilentlyContinue)) {
    if ($bf.Name -notmatch '\.(agent|subagent)\.md$') { continue }
    $bKey = $bf.Name -replace '\.(agent|subagent)\.md$', ''
    if ($bKey -notlike 'parcel*' -and $bKey -notlike 'ptp-*' -and $bKey -notlike 'wiki-*') { continue }
    $bindingFiles[$bKey] = $bf
}

foreach ($key in ($registryKeys.Keys | Sort-Object)) {
    if (-not $bindingFiles.ContainsKey($key)) {
        $failures += "Model Registry key '$key' has no agent file in .devops/agents/ ($key.agent.md or $key.subagent.md)"
    }
}

foreach ($key in ($bindingFiles.Keys | Sort-Object)) {
    if (-not $registryKeys.ContainsKey($key)) {
        $failures += "$($bindingFiles[$key].Name): no Model Registry row for '$key' - every binding file needs a row in base-context.md"
    }
    $bfile = $bindingFiles[$key]
    $braw = [System.IO.File]::ReadAllText($bfile.FullName) -replace "`r`n", "`n"
    $bfm = ""
    if ($braw.StartsWith("---`n")) {
        $bclose = $braw.IndexOf("`n---`n", 4)
        if ($bclose -ge 0) { $bfm = $braw.Substring(0, $bclose + 5) }
    }
    $bModelMatch = [regex]::Match($bfm, '(?m)^model:\s*(.+?)\s*$')
    if ($bModelMatch.Success) {
        $failures += "$($bfile.Name): model binding declared - frontmatter must not carry 'model:' (found '$($bModelMatch.Groups[1].Value.Trim('`', ' '))'). See model-routing skill section 4."
    } else {
        Write-Output "NOMODEL $($bfile.Name)"
    }
}

# --- Seed registry <-> live registry alignment ---
# The seed a satellite authors from must describe the same capability classes the template
# runs, so a bootstrapped satellite starts aligned. Rows are 2 cells; a model column is a FAIL.
$seedRegistryPath = Join-Path $root '.devops\templates\base-context.template.md'
if (-not (Test-Path $seedRegistryPath)) {
    $failures += "seed registry not found: .devops/templates/base-context.template.md"
} else {
    $seedText = ([System.IO.File]::ReadAllText($seedRegistryPath)) -replace "`r`n", "`n"
    $seedKeys = @{}
    foreach ($line in ($seedText -split "`n")) {
        if ($line -match '^\|\s*(parcel[a-z0-9-]*|ptp-[a-z0-9-]+|wiki-[a-z0-9-]+)\s*\|') {
            $cells = @(($line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim() })
            if ($cells.Count -ne 2) {
                $failures += "seed base-context.template.md: registry row must carry exactly 2 cells - found $($cells.Count) for key '$($cells[0])'"
            } else {
                $seedKeys[$cells[0]] = $cells[1]
            }
        }
    }
    foreach ($key in ($registryKeys.Keys | Sort-Object)) {
        if (-not $seedKeys.ContainsKey($key)) {
            $failures += "seed base-context.template.md: no registry row for '$key'"
        }
    }
    foreach ($key in ($seedKeys.Keys | Sort-Object)) {
        if (-not $registryKeys.ContainsKey($key)) {
            $failures += "seed base-context.template.md: registry row '$key' has no live registry row"
        }
    }
    Write-Output "SEED-REGISTRY ok  ($($seedKeys.Count) capability-class rows)"
}

# --- Seed opencode config must carry the same bindings (no placeholders) ---
$seedOcPath = Join-Path $root '.devops\templates\opencode.template.json'
if (-not (Test-Path $seedOcPath)) {
    $failures += "seed opencode config not found: .devops/templates/opencode.template.json"
} else {
    try {
        $seedOc = (Get-Content -Raw $seedOcPath | ConvertFrom-Json).agent
        if (-not $seedOc) {
            $failures += "seed opencode.template.json: no agent block"
        } else {
            $seedDeclared = 0
            foreach ($key in ($registryKeys.Keys | Sort-Object)) {
                $seedProp = $seedOc.PSObject.Properties[$key]
                if (-not $seedProp) {
                    $failures += "seed opencode.template.json: no agent entry for '$key'"
                    continue
                }
                $seedVal = [string]$seedProp.Value.model
                if ($seedVal) {
                    $failures += "seed opencode.template.json: agent '$key' declares model '$seedVal' - no agent may declare a model"
                    $seedDeclared++
                }
            }
            if ($seedDeclared -eq 0) { Write-Output "NOMODEL seed opencode.template.json" }
        }
    } catch {
        $failures += "seed opencode.template.json: not valid JSON ($($_.Exception.Message))"
    }
}

Write-Output "---"
Write-Output ("Canonical source: " + $canonicalPath)

# --- opencode.json: no agent may declare a model ---
# Every registry key must exist in the target's agent block (coverage retained).
# A declared `model` on ANY agent entry - registry key or not - is a FAIL: the invariant is
# now absence, so a stray model is as wrong as a mismatched one. An absent opencode.json, or
# an absent/empty `agent` block, is still a FAIL (the VS Code-only opt-out is retired).
$ocPath = Join-Path $root 'opencode.json'
if (-not (Test-Path $ocPath)) {
    $failures += "opencode.json: not present - every satellite carries it (seed: .devops/templates/opencode.template.json)"
} else {
    try {
        $oc = Get-Content -Raw $ocPath | ConvertFrom-Json
        $ocAgents = $oc.agent
        $agentProps = if ($ocAgents) { @($ocAgents.PSObject.Properties) } else { @() }
        if ($agentProps.Count -eq 0) {
            $failures += "opencode.json: no 'agent' block - every satellite carries one (seed: .devops/templates/opencode.template.json)"
        } else {
            foreach ($key in ($registryKeys.Keys | Sort-Object)) {
                if (-not $ocAgents.PSObject.Properties[$key]) {
                    $failures += "opencode.json: no agent entry for registry key '$key'"
                }
            }
            $ocDeclared = 0
            foreach ($p in $agentProps) {
                $val = [string]$p.Value.model
                if ($val) {
                    $failures += "opencode.json: agent '$($p.Name)' declares model '$val' - no agent may declare a model"
                    $ocDeclared++
                }
            }
            if ($ocDeclared -eq 0) { Write-Output "NOMODEL opencode.json" }
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
Write-Output "OK: all PREFIX-LOCKED agents share a byte-identical prefix, no binding surface declares a model, and the seed surfaces match the live registry."
