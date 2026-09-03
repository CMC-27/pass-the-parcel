# Encoding guard: detect UTF-8 mojibake and replacement chars in machinery files.
# Scans agent runbooks (.devops/agents/parcel-*.md) AND all skill sources
# (.devops/skills/**/*.md) — the latter closes the documented guard gap where
# corrupted glyphs propagated through sync into instruction surfaces.
# Markers: C3 A2 (double-encoded em-dash lead, "â€"), EF BF BD (U+FFFD replacement).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$targets = @()
$targets += Get-ChildItem -Path (Join-Path $root '.devops\agents') -Filter 'parcel-*.md' -ErrorAction SilentlyContinue
$targets += Get-ChildItem -Path (Join-Path $root '.devops\skills') -Recurse -Filter '*.md' -ErrorAction SilentlyContinue

$bad = @()
foreach ($file in $targets) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $mojibake = $false
    for ($i = 0; $i -lt $bytes.Length - 2; $i++) {
        if ($bytes[$i] -eq 0xC3 -and $bytes[$i + 1] -eq 0xA2) { $mojibake = $true; break }
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
