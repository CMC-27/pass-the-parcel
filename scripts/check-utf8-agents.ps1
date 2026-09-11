# Encoding guard: detect UTF-8 mojibake and replacement chars in machinery files.
# Scans agent files (.devops/agents/*.agent.md + *.subagent.md), all skill sources
# (.devops/skills/**/*.md), plan-state surfaces (plans, archive, backlog, logs),
# the full wiki (.wiki/**/*.md), AND the root README/AGENTS/CHANGELOG set plus
# generated `docs/` and `.github/` markdown — the wiki scan closes the guard gap
# where corrupted glyphs in documentation prose (which wiki_lint never inspects)
# survived unchecked.
# Markers: C3 A2 (double-encoded em-dash lead, "â€"), C3 B0 C2 (double-encoded emoji lead, "ðŸ"),
# EF BF BD (U+FFFD replacement).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$targets = @()
$targets += Get-ChildItem -Path (Join-Path $root '.devops\agents') -Filter '*.agent.md' -ErrorAction SilentlyContinue
$targets += Get-ChildItem -Path (Join-Path $root '.devops\agents') -Filter '*.subagent.md' -ErrorAction SilentlyContinue
$targets += Get-ChildItem -Path (Join-Path $root '.devops\skills') -Recurse -Filter '*.md' -ErrorAction SilentlyContinue
foreach ($dir in @('.devops\plans', '.devops\archive', '.devops\backlog', '.devops\logs')) {
    $targets += Get-ChildItem -Path (Join-Path $root $dir) -Recurse -Filter '*.md' -ErrorAction SilentlyContinue
}
# Full wiki tree (supersedes the former KC-only scan) — docs prose is invisible to
# wiki_lint, so the byte guard is the only mojibake detector for .wiki content.
$targets += Get-ChildItem -Path (Join-Path $root '.wiki') -Recurse -Filter '*.md' -ErrorAction SilentlyContinue
# Root docs + generated/github markdown — also agent-read surfaces. `docs/` is
# generated (visualizer export) but committed, so it must stay clean too.
$targets += Get-ChildItem -Path $root -Filter '*.md' -File -ErrorAction SilentlyContinue
$targets += Get-ChildItem -Path (Join-Path $root 'docs') -Recurse -Filter '*.md' -ErrorAction SilentlyContinue
$targets += Get-ChildItem -Path (Join-Path $root '.github') -Recurse -Filter '*.md' -ErrorAction SilentlyContinue

$bad = @()
foreach ($file in $targets) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $mojibake = $false
    for ($i = 0; $i -lt $bytes.Length - 2; $i++) {
        if ($bytes[$i] -eq 0xC3 -and $bytes[$i + 1] -eq 0xA2) { $mojibake = $true; break }
        if ($bytes[$i] -eq 0xC3 -and $bytes[$i + 1] -eq 0xB0 -and $bytes[$i + 2] -eq 0xC2) { $mojibake = $true; break }
        if ($bytes[$i] -eq 0xEF -and $bytes[$i + 1] -eq 0xBF -and $bytes[$i + 2] -eq 0xBD) { $mojibake = $true; break }
    }
    if ($mojibake) {
        $bad += $file.FullName.Substring($root.Length + 1)
    }
}
if ($bad.Count -gt 0) {
    Write-Output "MANGLED:"
    $bad | ForEach-Object { Write-Output "  $_" }
    exit 1
}
Write-Output "ALL CLEAN ($($targets.Count) files scanned)"
