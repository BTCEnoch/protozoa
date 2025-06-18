# runAll.ps1
# Master orchestrator that runs all automation scripts in the correct sequence
# Implements the complete 8-phase automation pipeline for new-protozoa setup

Import-Module "$PSScriptRoot\utils.psm1" -Force

Write-StepHeader "NEW-PROTOZOA AUTOMATION PIPELINE"
Write-InfoLog "Starting complete project setup automation..."

# Define script execution sequence
$scriptSequence = @(
    # --- Phase 0 : Environment & Tooling ---
    @{ Script = "00-InitEnvironment.ps1"; Description = "Environment setup and dependencies" },
    @{ Script = "01-ScaffoldProjectStructure.ps1"; Description = "Domain-driven directory structure" },
    @{ Script = "02-GenerateDomainStubs.ps1"; Description = "Service and interface stubs" },
    @{ Script = "03-MoveAndCleanCodebase.ps1"; Description = "Legacy code cleanup" },
    @{ Script = "04-EnforceSingletonPatterns.ps1"; Description = "Singleton pattern enforcement" },
    @{ Script = "05-VerifyCompliance.ps1"; Description = "Architecture compliance verification" },
    @{ Script = "06-DomainLint.ps1"; Description = "Domain-specific linting" },
    @{ Script = "07-BuildAndTest.ps1"; Description = "Build verification and testing" },
    @{ Script = "20-SetupPreCommitValidation.ps1"; Description = "Pre-commit hooks and validation" },
    @{ Script = "08-DeployToGitHub.ps1"; Description = "Git initialization and GitHub deployment" },

    # --- Phase 1 : Shared Infrastructure ---
    @{ Script = "16-GenerateSharedTypesService.ps1"; Description = "Unified shared types generation" },
    @{ Script = "17-GenerateEnvironmentConfig.ps1"; Description = "Environment configuration and logging services" },
    @{ Script = "18a-SetupLoggingService.ps1"; Description = "Central Winston logging setup" },
    @{ Script = "18-GenerateFormationDomain.ps1"; Description = "Complete Formation Domain implementation" },
    @{ Script = "14-FixUtilityFunctions.ps1"; Description = "Utility functions validation and fixes" },

    # --- Phase 2 : TypeScript & Dev-Env ---
    @{ Script = "19-ConfigureAdvancedTypeScript.ps1"; Description = "Advanced TypeScript config" },
    @{ Script = "21-ConfigureDevEnvironment.ps1"; Description = "Dev environment fine-tuning" },

    # --- Phase 3 : Core Protocols & Services ---
    @{ Script = "22-SetupBitcoinProtocol.ps1"; Description = "Bitcoin Ordinals protocol setup" },
    @{ Script = "23-GenerateRNGService.ps1"; Description = "Random number generator service" },
    @{ Script = "24-GeneratePhysicsService.ps1"; Description = "Physics engine service" },
    @{ Script = "25-SetupPhysicsWebWorkers.ps1"; Description = "Physics WebWorker scaffolding" },
    @{ Script = "26-GenerateBitcoinService.ps1"; Description = "Bitcoin blockchain service" },
    @{ Script = "27-GenerateTraitService.ps1"; Description = "Trait management service" },
    @{ Script = "28-SetupBlockchainDataIntegration.ps1"; Description = "Blockchain data integration" },
    @{ Script = "29-SetupDataValidationLayer.ps1"; Description = "Data validation layer" },

    # --- Phase 4 : Domain Enhancements ---
    @{ Script = "30-EnhanceTraitSystem.ps1"; Description = "Trait system enhancements" },
    @{ Script = "31-GenerateParticleService.ps1"; Description = "Particle service generation" },
    @{ Script = "32-SetupParticleLifecycleManagement.ps1"; Description = "Particle lifecycle management" },
    @{ Script = "33-ImplementSwarmIntelligence.ps1"; Description = "Swarm intelligence" },
    @{ Script = "34-EnhanceFormationSystem.ps1"; Description = "Formation system enhancements" },
    @{ Script = "35-GenerateRenderingService.ps1"; Description = "Rendering service" },
    @{ Script = "36-GenerateEffectService.ps1"; Description = "Effect service" },
    @{ Script = "37-SetupCustomShaderSystem.ps1"; Description = "Custom shader system" },
    @{ Script = "38-ImplementLODSystem.ps1"; Description = "Level-of-detail system" },
    @{ Script = "39-SetupAdvancedEffectComposition.ps1"; Description = "Advanced effect composition" },
    @{ Script = "40-GenerateAnimationService.ps1"; Description = "Animation service" },
    @{ Script = "41-GenerateGroupService.ps1"; Description = "Group service" },
    @{ Script = "42-SetupPhysicsBasedAnimation.ps1"; Description = "Physics-based animation" },
    @{ Script = "43-ImplementAdvancedTimeline.ps1"; Description = "Advanced timeline" },
    @{ Script = "44-SetupAnimationBlending.ps1"; Description = "Animation blending" },

    # --- Phase 4.5 : Testing Infrastructure ---
    @{ Script = "18b-SetupTestingFramework.ps1"; Description = "Vitest testing framework setup" },

    # --- Phase 5 : CI / CD & Tooling ---
    @{ Script = "45-SetupCICDPipeline.ps1"; Description = "CI/CD pipeline" },
    @{ Script = "46-SetupDockerDeployment.ps1"; Description = "Docker deployment" },
    @{ Script = "47-SetupPerformanceRegression.ps1"; Description = "Performance regression testing" },
    @{ Script = "48-SetupAdvancedBundleAnalysis.ps1"; Description = "Bundle analysis" },
    @{ Script = "49-SetupAutomatedDocumentation.ps1"; Description = "Automated documentation" },
    @{ Script = "50-SetupServiceIntegration.ps1"; Description = "Service integration" },

    # --- Phase 6 : Front-End Integration ---
    @{ Script = "51-SetupGlobalStateManagement.ps1"; Description = "Global state management" },
    @{ Script = "52-SetupReactIntegration.ps1"; Description = "React integration" },
    @{ Script = "53-SetupEventBusSystem.ps1"; Description = "Event bus system" },
    @{ Script = "54-SetupPerformanceTesting.ps1"; Description = "Performance testing" },
    @{ Script = "55-SetupPersistenceLayer.ps1"; Description = "Persistence layer" },
    @{ Script = "56-SetupEndToEndValidation.ps1"; Description = "End-to-end validation" },
    # --- Final Validation ---
    @{ Script = "15-ValidateSetupComplete.ps1"; Description = "Final validation and setup completion" }
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
        
        # CI/non-interactive mode – continue automatically when environment variable CI=1
        if ($env:CI -eq '1') {
            Write-WarningLog "CI mode detected – continuing pipeline despite failure in phase $stepNumber"
            continue
        }

        # Ask user interactively otherwise
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