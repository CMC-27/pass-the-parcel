# Quick check: detect UTF-8 mojibake (double-encoded em-dash) in agent files.
# Looks for the byte sequence E2 80 94 (em-dash) appearing as a valid char,
# vs. the mojibake sequence C3 A2 E2 82 AC C5 93 (double-encoded "—").
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$agentsDir = Join-Path $root '.opencode\agents'

$bad = @()
foreach ($file in Get-ChildItem -Path $agentsDir -Filter 'parcel-*.md') {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    # Mojibake marker: the sequence C3 A2 ... appears when UTF-8 was read as ANSI.
    $mojibake = $false
    for ($i = 0; $i -lt $bytes.Length - 1; $i++) {
        if ($bytes[$i] -eq 0xC3 -and $bytes[$i + 1] -eq 0xA2) { $mojibake = $true; break }
    }
    if ($mojibake) {
        $bad += $file.Name
    } else {
        Write-Output "clean: $($file.Name)"
    }
}
if ($bad.Count -gt 0) {
    Write-Output "MANGLED: $($bad -join ', ')"
    exit 1
}
Write-Output "ALL CLEAN"
