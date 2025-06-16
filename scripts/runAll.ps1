# runAll.ps1
# Master orchestrator that runs all automation scripts in the correct sequence
# Implements the complete 8-phase automation pipeline for new-protozoa setup

Import-Module "$PSScriptRoot\utils.psm1" -Force

Write-StepHeader "NEW-PROTOZOA AUTOMATION PIPELINE"
Write-InfoLog "Starting complete project setup automation..."

# Define script execution sequence
$scriptSequence = @(
    @{ Script = "00-InitEnvironment.ps1"; Description = "Environment setup and dependencies" },
    @{ Script = "01-ScaffoldProjectStructure.ps1"; Description = "Domain-driven directory structure" },
    @{ Script = "02-GenerateDomainStubs.ps1"; Description = "Service and interface stubs" },
    @{ Script = "03-MoveAndCleanCodebase.ps1"; Description = "Legacy code cleanup" },
    @{ Script = "04-EnforceSingletonPatterns.ps1"; Description = "Singleton pattern enforcement" },
    @{ Script = "05-VerifyCompliance.ps1"; Description = "Architecture compliance verification" },
    @{ Script = "06-DomainLint.ps1"; Description = "Domain-specific linting" },
    @{ Script = "07-BuildAndTest.ps1"; Description = "Build verification and testing" },
    @{ Script = "08-DeployToGitHub.ps1"; Description = "Git initialization and GitHub deployment" },
    @{ Script = "09-GenerateEnvironmentConfig.ps1"; Description = "Environment configuration service generation" },
    @{ Script = "10-GenerateParticleInitService.ps1"; Description = "Particle initialization service extraction" },
    @{ Script = "11-GenerateFormationBlendingService.ps1"; Description = "Formation blending and caching service" },
    @{ Script = "12-GenerateSharedTypes.ps1"; Description = "Cross-domain shared types generation" },
    @{ Script = "13-GenerateTypeScriptConfig.ps1"; Description = "TypeScript configuration files generation" },
    @{ Script = "14-FixUtilityFunctions.ps1"; Description = "Utility functions validation and fixes" }
)

# Track execution results
$results = @()
$startTime = Get-Date

# Execute each script in sequence
for ($i = 0; $i -lt $scriptSequence.Count; $i++) {
    $step = $scriptSequence[$i]
    $stepNumber = $i
    $scriptPath = Join-Path $PSScriptRoot $step.Script
    
    Write-StepHeader "PHASE $stepNumber : $($step.Description)"
    Write-InfoLog "Executing: $($step.Script)"
    
    if (-not (Test-Path $scriptPath)) {
        Write-ErrorLog "Script not found: $scriptPath"
        $results += [PSCustomObject]@{
            Phase = $stepNumber
            Script = $step.Script
            Status = "MISSING"
            Duration = 0
            Error = "Script file not found"
        }
        continue
    }
    
    $stepStartTime = Get-Date
    try {
        # Execute the script and capture output
        & $scriptPath 2>&1
        $stepDuration = (Get-Date) - $stepStartTime
        
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
            Write-SuccessLog "PHASE $stepNumber completed successfully in $($stepDuration.TotalSeconds) seconds"
                    $results += [PSCustomObject]@{
            Phase = $stepNumber
            Script = $step.Script
            Status = "SUCCESS"
            Duration = $stepDuration.TotalSeconds
            Error = $null
        }
        } else {
            throw "Script exited with code $LASTEXITCODE"
        }
    }
    catch {
        $stepDuration = (Get-Date) - $stepStartTime
        Write-ErrorLog "PHASE $stepNumber FAILED: $($_.Exception.Message)"
        $results += [PSCustomObject]@{
            Phase = $stepNumber
            Script = $step.Script
            Status = "FAILED"
            Duration = $stepDuration.TotalSeconds
            Error = $_.Exception.Message
        }
        
        # Ask user if they want to continue despite failure
        $choice = Read-Host "Phase $stepNumber failed. Continue with remaining phases? (y/N)"
        if ($choice -notmatch '^[Yy]') {
            Write-ErrorLog "Automation pipeline aborted by user"
            break
        }
    }
}

# Calculate total execution time
$totalDuration = (Get-Date) - $startTime

# Generate execution summary
Write-StepHeader "AUTOMATION PIPELINE SUMMARY"
Write-InfoLog "Total execution time: $($totalDuration.TotalMinutes.ToString('F2')) minutes"

$successCount = ($results | Where-Object { $_.Status -eq "SUCCESS" }).Count
$failedCount = ($results | Where-Object { $_.Status -eq "FAILED" }).Count
$missingCount = ($results | Where-Object { $_.Status -eq "MISSING" }).Count

Write-InfoLog "Results: $successCount succeeded, $failedCount failed, $missingCount missing"

# Detailed results
foreach ($result in $results) {
    $status = switch ($result.Status) {
        "SUCCESS" { "✅" }
        "FAILED" { "❌" }
        "MISSING" { "⚠️" }
    }
    $durationText = if ($result.Duration -gt 0) { " ($($result.Duration.ToString('F1'))s)" } else { "" }
    Write-InfoLog "  Phase $($result.Phase): $status $($result.Script)$durationText"
    
    if ($result.Error) {
        Write-WarningLog "    Error: $($result.Error)"
    }
}

# Final status determination
if ($failedCount -eq 0 -and $missingCount -eq 0) {
    Write-SuccessLog "🎉 ALL AUTOMATION PHASES COMPLETED SUCCESSFULLY!"
    Write-InfoLog "Your new-protozoa project is ready for Cursor AI implementation."
    Write-InfoLog ""
    Write-InfoLog "Next steps:"
    Write-InfoLog "1. Open the project in Cursor"
    Write-InfoLog "2. Paste the XML instructions from the documentation"
    Write-InfoLog "3. Start implementing domain logic phase by phase"
    Write-InfoLog "4. Run 05-VerifyCompliance.ps1 after each phase to maintain standards"
    
    exit 0
} elseif ($successCount -gt 0) {
    Write-WarningLog "⚠️ AUTOMATION PARTIALLY COMPLETED"
    Write-InfoLog "Some phases succeeded, but manual intervention may be required."
    Write-InfoLog "Check the error messages above and resolve issues before proceeding."
    
    exit 1
} else {
    Write-ErrorLog "❌ AUTOMATION FAILED"
    Write-InfoLog "Critical failures occurred. Review logs and resolve issues before retrying."
    
    exit 2
}

# Create completion marker file
$completionInfo = @{
    CompletedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    TotalDuration = $totalDuration.TotalMinutes
    Results = $results
} | ConvertTo-Json -Depth 3

Set-Content -Path ".automation-complete" -Value $completionInfo
Write-InfoLog "Automation completion marker created: .automation-complete" 