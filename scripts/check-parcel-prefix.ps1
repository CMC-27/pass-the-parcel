param(
    [switch]$Sync
)

<#
.SYNOPSIS
    Verifies (and optionally repairs) the PREFIX-LOCKED byte-for-byte contract
    between .opencode/plans/base-context.md and every .devops/agents/parcel-*.md.

.DESCRIPTION
    The pass-the-parcel pipeline relies on a byte-for-byte identical shared prefix
    inlined into every parcel-* agent file. That identical prefix maximizes KV-cache
    hits across agent invocations. Any drift (editing one file, not the others, or
    CRLF/LF corruption) silently destroys the cache benefit.

    Agents physically live in .devops/agents/ and are loaded by opencode via the
    `prompt: {file: .devops/agents/parcel-*.md}` reference in opencode.json. The
    runbook file is PURE BODY: the PREFIX-LOCKED prefix followed by the agent-unique
    content (everything from the first "## Delegated Skill:" heading, or "You are
    the" for the orchestrator). Frontmatter (description/mode/model/permission)
    lives in opencode.json, not in the runbook file.

    Without -Sync:  prints PASS/FAIL per agent file and exits non-zero if any drift.
    With -Sync:     rebuilds each agent file's prefix from base-context.md, preserving
                    the agent-unique content.

.NOTES
    Run after editing base-context.md:
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

$agentFiles = Get-ChildItem -Path $agentsDir -Filter 'parcel-*.md' | Sort-Object Name
if (-not $agentFiles) { throw "No parcel-* agent files found in $agentsDir" }

$failures = @()
foreach ($file in $agentFiles) {
    # Read as UTF-8 (PS 5.1 Get-Content would misread UTF-8 as ANSI and mangle chars).
    $raw = [System.IO.File]::ReadAllText($file.FullName)
    $raw = $raw -replace "`r`n", "`n"

    # Runbooks are PURE BODY (no frontmatter). Locate the agent-unique content start.
    $body = $raw
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

    # Rebuild expected content: canonical + blank line + unique.
    $expected = $canonical + "`n`n" + $unique

    if ($raw.TrimEnd("`n") -eq $expected.TrimEnd("`n")) {
        Write-Output "PASS  $($file.Name)"
    } else {
        if ($Sync) {
            # Write with LF, then let .gitattributes normalize on commit.
            [System.IO.File]::WriteAllText($file.FullName, $expected, (New-Object System.Text.UTF8Encoding($false)))
            Write-Output "FIXED $($file.Name)"
        } else {
            $failures += "$($file.Name): prefix drift detected (run with -Sync to repair)"
        }
    }
}

Write-Output "---"
Write-Output ("Canonical source: " + $canonicalPath)
if ($failures.Count -gt 0) {
    Write-Output "FAILURES:"
    $failures | ForEach-Object { Write-Output "  $_" }
    exit 1
}
Write-Output "OK: all parcel-* agents share a byte-identical PREFIX-LOCKED prefix."
