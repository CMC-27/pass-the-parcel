# sync-verify.ps1 — structural verification of the satellite-authored surface, plus the
# machinery gates run inside the target. Dot-sourced by scripts/sync-architecture.ps1.
# Portable.

function Invoke-StructuralVerify {
    # Checks the satellite-authored surface (the files a satellite authors from the seeds
    # in .devops/templates/) against the template blueprint. Read-only. Returns a
    # hashtable with Fail/Warn counts; each check prints a [PASS]/[FAIL]/[WARN] line.
    # Status lines use Write-Host (not Write-Output) so the caller's return-value
    # assignment does not capture them into the result variable.
    param([string]$SrcRoot, [string]$TgtRoot)
    $fail = 0; $warn = 0
    function Line { param($Status, $Msg) Write-Host ("  [{0,-4}] {1}" -f $Status, $Msg) }

    # 1. AGENTS.md - present, with the machinery markers agents rely on.
    $agentsPath = Join-Path $TgtRoot 'AGENTS.md'
    if (-not (Test-Path $agentsPath)) {
        Line 'FAIL' 'AGENTS.md missing at repo root (seed: .devops/templates/AGENTS.template.md)'; $fail++
    } else {
        $raw = [System.IO.File]::ReadAllText($agentsPath)
        $missing = @()
        foreach ($marker in @('MANDATORY READING', '.wiki/core/00-system-index.md', '@pass-the-parcel', '@agent-wrap-up')) {
            if ($raw -notmatch [regex]::Escape($marker)) { $missing += $marker }
        }
        if ($missing.Count -gt 0) {
            Line 'FAIL' ('AGENTS.md missing machinery marker(s): ' + ($missing -join ', ')); $fail++
        } else {
            Line 'PASS' 'AGENTS.md present with machinery markers intact'
        }
    }

    # 2. opencode.json - valid JSON, wired to AGENTS.md + the skills path.
    $ocPath = Join-Path $TgtRoot 'opencode.json'
    if (-not (Test-Path $ocPath)) {
        Line 'FAIL' 'opencode.json missing at repo root (seed: .devops/templates/opencode.template.json)'; $fail++
    } else {
        try {
            $cfg = Get-Content $ocPath -Raw | ConvertFrom-Json
            $ocOk = $true
            if (-not ($cfg.instructions -contains 'AGENTS.md')) { Line 'FAIL' "opencode.json 'instructions' must include 'AGENTS.md'"; $fail++; $ocOk = $false }
            if (-not ($cfg.skills.paths -contains '.devops/skills')) { Line 'FAIL' "opencode.json 'skills.paths' must include '.devops/skills'"; $fail++; $ocOk = $false }
            if ($ocOk) { Line 'PASS' 'opencode.json valid; instructions + skills.paths wired' }
        } catch {
            Line 'FAIL' "opencode.json is not valid JSON: $($_.Exception.Message)"; $fail++
        }
    }

    # 3. base-context.md - the prefix-lock source.
    if (Test-Path (Join-Path $TgtRoot '.opencode/plans/base-context.md')) {
        Line 'PASS' 'base-context.md present (.opencode/plans/)'
    } else {
        Line 'FAIL' 'base-context.md missing (seed: .devops/templates/base-context.template.md -> .opencode/plans/)'; $fail++
    }

    # 4. Wiki anchor - the mandatory-reading entry point.
    if (Test-Path (Join-Path $TgtRoot '.wiki/core/00-system-index.md')) {
        Line 'PASS' 'wiki anchor present (.wiki/core/00-system-index.md)'
    } else {
        Line 'FAIL' 'wiki anchor missing: .wiki/core/00-system-index.md (mandatory reading entry point)'; $fail++
    }

    # 5. Machinery surface - the portable dirs/files a sync materialises.
    foreach ($rel in @('.devops/skills', '.devops/agents', '.devops/rules', '.wiki/rules', '.devops/templates', 'scripts/check-parcel-prefix.ps1', 'scripts/check-utf8-agents.ps1', 'scripts/wiki_lint.py')) {
        if (Test-Path (Join-Path $TgtRoot $rel)) { continue }
        Line 'FAIL' "machinery missing: $rel (run a sync first)"; $fail++
    }

    # 6. .ptp-source - needed for future pulls (advisory only).
    if (Test-Path (Join-Path $TgtRoot '.ptp-source')) {
        Line 'PASS' '.ptp-source present (pull source remembered)'
    } else {
        Line 'WARN' '.ptp-source missing - future pulls need -Source once (pull-architecture.ps1 -Source <path-or-url>)'; $warn++
    }

    return @{ Fail = $fail; Warn = $warn }
}

function Invoke-VerificationGates {
    # Runs the machinery gates inside the target repo. Returns $true when all pass.
    # -RegenPrefix regenerates PREFIX-LOCKED prefixes first (post-sync); without it the
    # prefix check runs check-only (-Verify mode never writes). Status lines use
    # Write-Host so the caller's return-value assignment does not capture them.
    param([string]$TgtRoot, [switch]$RegenPrefix)
    Push-Location $TgtRoot
    try {
        $ok = $true
        $prefixResult = Invoke-TargetPrefixGate -TgtRoot $TgtRoot -ShellExe $shellExe -Regen:$RegenPrefix
        if ($prefixResult -eq $false) { $ok = $false }
        $utf8Script = Join-Path $TgtRoot 'scripts/check-utf8-agents.ps1'
        if (Test-Path $utf8Script) {
            & $shellExe -NoProfile -File $utf8Script | Out-Host
            if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: check-utf8-agents'; $ok = $false }
            else { Write-Host 'UTF-8: OK' }
        } else {
            Write-Host 'VERIFY FAILED: check-utf8-agents.ps1 missing (machinery not materialised?)'; $ok = $false
        }
        if (Test-Path (Join-Path $TgtRoot 'scripts/wiki_lint.py')) {
            # A fresh satellite has no wiki content yet - the synced structure manifest
            # declares anchors that cannot exist, so linting there is a false positive.
            if (Test-Path (Join-Path $TgtRoot '.wiki/core')) {
                & python (Join-Path $TgtRoot 'scripts/wiki_lint.py') --quiet | Out-Host
                if ($LASTEXITCODE -ne 0) { Write-Host 'VERIFY FAILED: wiki_lint'; $ok = $false }
                else { Write-Host 'WIKI LINT: OK' }
            } else {
                Write-Host 'SKIP: wiki lint not applicable yet (no .wiki/core content)'
            }
        } else {
            Write-Host 'SKIP: wiki_lint.py missing (machinery not materialised?)'
        }
        return $ok
    } finally {
        Pop-Location
    }
}
