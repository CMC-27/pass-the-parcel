# Encoding guard: detect UTF-8 mojibake and replacement chars in machinery files.
# Scans agent files (.devops/agents/*.agent.md + *.subagent.md), all skill sources
# (.devops/skills/**/*.md), plan-state surfaces (plans, backlog, logs, sprints), the
# dev-rules layer + seed templates (.devops/rules, .devops/templates — both portable
# and agent-read, so mojibake there propagates to every satellite), the full wiki
# (.wiki/**/*.md), AND the root README/AGENTS/CHANGELOG set plus generated `docs/`
# and `.github/` markdown — the wiki scan closes the guard gap where corrupted glyphs
# in documentation prose (which wiki_lint never inspects) survived unchecked.
#
# Markers, BY HEX BYTE SEQUENCE ONLY — never as literal glyphs, because a glyph here
# would depend on this file's own bytes and on the host's BOM-less read (PowerShell 5.1
# assumes ANSI), and `scripts/` sits outside this guard's own scan set, so a mangled
# guard could not catch itself:
#   C3 A2             CP1252 double-encoded em-dash lead
#   C3 B0 C2          CP1252 double-encoded emoji lead
#   CE 93 + C2|C3     CP437 double-encoded dash / emoji lead
#   E2 89 A1 C6 92    CP437 double-encoded 4-byte emoji lead
#   EF BF BD          U+FFFD replacement character
# The CP437 pairs catch UTF-8 bytes misread through code page 437 — a second corruption
# path the CP1252 markers alone missed.
#
# Mechanism: each file is decoded ONCE as Latin-1 (code page 28591 — 1 byte maps to 1
# char), then the five sequences are matched with one compiled regex alternation built
# from .NET `\u` escapes. That replaces the interpreted per-index byte loop with native
# search, and — the declared delta — it scans the WHOLE file: the old loop bound was
# `$i -lt $bytes.Length - 2`, which never tested the final two bytes, so a file whose last
# two bytes were C3 A2 passed silently. Fixing that is a deliberate, stated strengthening,
# not a moved goalpost.
#
# Immutable history: `.devops/archive` is EXCLUDED from the recurring scan (roughly half
# the scanned bytes, and its verdict is unactionable — the archive is never retro-edited
# and is not portable). `-All` reproduces the former whole-tree scan on demand; nothing
# schedules it, so the default run's file count is the live surface, not the full tree.
param(
    [string]$Root = "",
    [switch]$All
)
$ErrorActionPreference = 'Stop'
$root = if ($Root) { (Resolve-Path $Root).Path } else { Split-Path -Parent $PSScriptRoot }

$targets = [System.Collections.Generic.List[string]]::new()
# .NET enumeration rather than Get-ChildItem -Recurse: the provider materialises a
# FileInfo per entry and is markedly slower on PS 5.1 over a large .wiki. GetFiles
# returns bare path strings, so the scan loop reads them directly.
function Add-MarkdownTargets {
    param([string]$Dir, [string]$Filter = '*.md', [switch]$Recurse)
    if (-not (Test-Path -LiteralPath $Dir)) { return }
    $option = if ($Recurse) { [System.IO.SearchOption]::AllDirectories } else { [System.IO.SearchOption]::TopDirectoryOnly }
    $targets.AddRange([System.IO.Directory]::GetFiles($Dir, $Filter, $option))
}
$agentsDir = Join-Path $root '.devops\agents'
Add-MarkdownTargets $agentsDir '*.agent.md'
Add-MarkdownTargets $agentsDir '*.subagent.md'
Add-MarkdownTargets (Join-Path $root '.devops\skills') -Recurse
$dirs = @('.devops\plans', '.devops\backlog', '.devops\logs', '.devops\rules', '.devops\templates', '.devops\sprints')
if ($All) { $dirs += '.devops\archive' }
foreach ($dir in $dirs) {
    Add-MarkdownTargets (Join-Path $root $dir) -Recurse
}
# Full wiki tree (supersedes the former KC-only scan) — docs prose is invisible to
# wiki_lint, so the byte guard is the only mojibake detector for .wiki content.
Add-MarkdownTargets (Join-Path $root '.wiki') -Recurse
# Root docs + generated/github markdown — also agent-read surfaces.
Add-MarkdownTargets $root
Add-MarkdownTargets (Join-Path $root 'docs') -Recurse
Add-MarkdownTargets (Join-Path $root '.github') -Recurse

$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$markerPattern = '\u00C3\u00A2|\u00C3\u00B0\u00C2|\u00EF\u00BF\u00BD|\u00CE\u0093[\u00C2\u00C3]|\u00E2\u0089\u00A1\u00C6\u0092'
$markerRegex = [System.Text.RegularExpressions.Regex]::new(
    $markerPattern,
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

$bad = @()
foreach ($file in $targets) {
    $text = $latin1.GetString([System.IO.File]::ReadAllBytes($file))
    if ($markerRegex.IsMatch($text)) {
        $bad += $file.Substring($root.Length + 1)
    }
}
if ($bad.Count -gt 0) {
    Write-Output "MANGLED:"
    $bad | ForEach-Object { Write-Output "  $_" }
    exit 1
}
Write-Output "ALL CLEAN ($($targets.Count) files scanned)"
