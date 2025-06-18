#!/usr/bin/env pwsh
param([switch]$WhatIf = $false)

Write-Host "🔧 Fixing PowerShell parsing issues with HERE-STRING content..." -ForegroundColor Cyan

# Get scripts that failed due to parsing issues
$problemScripts = @(
    "17-GenerateEnvironmentConfig.ps1",
    "18a-SetupLoggingService.ps1",
    "29-SetupDataValidationLayer.ps1",
    "32-SetupParticleLifecycleManagement.ps1",
    "33-ImplementSwarmIntelligence.ps1",
    "34-EnhanceFormationSystem.ps1",
    "37-SetupCustomShaderSystem.ps1",
    "38-ImplementLODSystem.ps1",
    "39-SetupAdvancedEffectComposition.ps1",
    "42-SetupPhysicsBasedAnimation.ps1",
    "43-ImplementAdvancedTimeline.ps1",
    "44-SetupAnimationBlending.ps1",
    "45-SetupCICDPipeline.ps1",
    "46-SetupDockerDeployment.ps1",
    "47-SetupPerformanceRegression.ps1",
    "48-SetupAdvancedBundleAnalysis.ps1",
    "49-SetupAutomatedDocumentation.ps1",
    "50-SetupServiceIntegration.ps1",
    "51-SetupGlobalStateManagement.ps1",
    "52-SetupReactIntegration.ps1",
    "53-SetupEventBusSystem.ps1",
    "54-SetupPerformanceTesting.ps1",
    "55-SetupPersistenceLayer.ps1",
    "56-SetupEndToEndValidation.ps1"
)

$totalFixed = 0
$scriptsModified = 0

foreach ($scriptName in $problemScripts) {
    $scriptPath = "scripts/$scriptName"
    if (-not (Test-Path $scriptPath)) {
        Write-Host "Skipping $scriptName - not found" -ForegroundColor Yellow
        continue
    }

    Write-Host "Processing: $scriptName" -ForegroundColor Yellow

    $content = Get-Content $scriptPath -Raw
    $fixesInScript = 0

    # Convert all double-quoted HERE-STRINGs to single-quoted ones
    # This prevents PowerShell from parsing the content as PowerShell code

    $lines = $content -split "`r`n|`n"
    $newLines = @()
    $inHereString = $false
    $hereStringStartLine = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if (-not $inHereString -and $line -match '^\s*\$\w+\s*=\s*@"$') {
            # Start of double-quoted HERE-STRING - convert to single-quoted
            $inHereString = $true
            $hereStringStartLine = $i
            $newLines += $line -replace '@"$', "@'"
            Write-Host "    Found HERE-STRING start at line $($i + 1)" -ForegroundColor Cyan
            continue
        }

        if ($inHereString -and $line -match '^"@\s*$') {
            # End of double-quoted HERE-STRING - convert to single-quoted
            $inHereString = $false
            $newLines += $line -replace '^"@', "'@"
            $fixesInScript++
            Write-Host "    Converted HERE-STRING block (lines $($hereStringStartLine + 1)-$($i + 1))" -ForegroundColor Green
            $hereStringStartLine = -1
            continue
        }

        if ($inHereString) {
            # Inside HERE-STRING - escape any single quotes by doubling them
            $escapedLine = $line -replace [char]39, ([char]39 + [char]39)
            $newLines += $escapedLine
        } else {
            # Outside HERE-STRING - keep line as-is
            $newLines += $line
        }
    }

    # Check for unclosed HERE-STRING
    if ($inHereString) {
        Write-Host "    WARNING: Unclosed HERE-STRING starting at line $($hereStringStartLine + 1)" -ForegroundColor Red
    }

    if ($fixesInScript -gt 0) {
        $content = $newLines -join "`r`n"
        $scriptsModified++
        $totalFixed += $fixesInScript

        if ($WhatIf) {
            Write-Host "  Would modify $scriptName" -ForegroundColor Green
        } else {
            Set-Content -Path $scriptPath -Value $content -Encoding UTF8
            Write-Host "  Fixed $scriptName" -ForegroundColor Green
        }
    } else {
        Write-Host "  No changes needed for $scriptName" -ForegroundColor Gray
    }
}

Write-Host "`n🎯 SUMMARY:" -ForegroundColor Cyan
Write-Host "Scripts processed: $($problemScripts.Count)" -ForegroundColor White
Write-Host "Scripts modified: $scriptsModified" -ForegroundColor Green
Write-Host "Total blocks converted: $totalFixed" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "`nRun without -WhatIf to apply changes" -ForegroundColor Yellow
} else {
    Write-Host "`nFixes applied successfully!" -ForegroundColor Green
}