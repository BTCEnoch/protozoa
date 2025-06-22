# runAll.ps1
# Master orchestrator that runs all automation scripts in the correct sequence
# Implements the complete 8-phase automation pipeline for new-protozoa setup
# Updated: Added 60-SetupBrowserServerRequirements.ps1 for complete dev server setup

Import-Module "$PSScriptRoot\utils.psm1" -Force

Write-StepHeader "NEW-PROTOZOA AUTOMATION PIPELINE"
Write-InfoLog "Starting complete project setup automation..."

# Define script execution sequence following optimal 8-phase architecture
$scriptSequence = @(
    # === PHASE 0: ENVIRONMENT & FOUNDATION (12 Scripts - npm-only) ===
    # Critical infrastructure - must execute first
    @{ Phase = 0; Script = "00-NpmEnvironmentSetup.ps1"; Description = "Node.js and npm-only environment setup" },
    @{ Phase = 0; Script = "00a-NpmInstallWithProgress.ps1"; Description = "npm installation with enhanced monitoring and stall detection" },
    @{ Phase = 0; Script = "00b-ValidateNpmEnvironment.ps1"; Description = "npm environment and package integrity validation" },
    @{ Phase = 0; Script = "00c-CleanupLegacyPackageManagers.ps1"; Description = "Remove pnpm/yarn traces and ensure npm-only approach" },
    @{ Phase = 0; Script = "00d-FixRollupNativeDependencies.ps1"; Description = "Fix Rollup native dependencies for Windows development" },
    @{ Phase = 0; Script = "01-ScaffoldProjectStructure.ps1"; Description = "Domain-driven directory structure" },
    @{ Phase = 0; Script = "02-GenerateDomainStubs.ps1"; Description = "Service interfaces and stubs" },
    @{ Phase = 0; Script = "03-MoveAndCleanCodebase.ps1"; Description = "Legacy cleanup" },
    @{ Phase = 0; Script = "04-EnforceSingletonPatterns.ps1"; Description = "Architectural patterns" },
    @{ Phase = 0; Script = "04a-GenerateThemeCSS.ps1"; Description = "Theme CSS generation from TypeScript palettes" },
    @{ Phase = 0; Script = "04b-SmartMemoryAndWorkers.ps1"; Description = "Memory pooling and worker management infrastructure" },
    @{ Phase = 0; Script = "05-VerifyCompliance.ps1"; Description = "Domain compliance validation" },
    @{ Phase = 0; Script = "06-DomainLint.ps1"; Description = "Domain-specific linting rules" },
    @{ Phase = 0; Script = "07-BuildAndTest.ps1"; Description = "Build verification" },
    @{ Phase = 0; Script = "08-DeployToGitHub.ps1"; Description = "Git setup and GitHub integration" },
    @{ Phase = 0; Script = "20-SetupPreCommitValidation.ps1"; Description = "Husky hooks and validation" },

    # === PHASE 1: SHARED INFRASTRUCTURE (5 Scripts) ===
    # Cross-domain services and configuration
    @{ Phase = 1; Script = "16-GenerateSharedTypesService.ps1"; Description = "Unified type system" },
    @{ Phase = 1; Script = "17-GenerateEnvironmentConfig.ps1"; Description = "Environment detection & config" },
    @{ Phase = 1; Script = "18a-SetupLoggingService.ps1"; Description = "Winston logging infrastructure" },
    @{ Phase = 1; Script = "18-GenerateFormationDomain.ps1"; Description = "Formation domain implementation" },
    @{ Phase = 1; Script = "10a-EnhanceParticleInitService.ps1"; Description = "Enhanced particle initialization with 500-particle allocation" },
    @{ Phase = 1; Script = "14-FixUtilityFunctions.ps1"; Description = "Utility function validation" },

    # === PHASE 2: DEVELOPMENT ENVIRONMENT (2 Scripts) ===
    # TypeScript and development tooling
    @{ Phase = 2; Script = "19-ConfigureAdvancedTypeScript.ps1"; Description = "Advanced TS config with path mapping" },
    @{ Phase = 2; Script = "21-ConfigureDevEnvironment.ps1"; Description = "VS Code, Prettier, dev tools" },

    # === PHASE 3: CORE PROTOCOL SERVICES (10 Scripts) ===
    # Fundamental domain services
    @{ Phase = 3; Script = "22-SetupBitcoinProtocol.ps1"; Description = "Bitcoin Ordinals protocol" },
    @{ Phase = 3; Script = "23-GenerateRNGService.ps1"; Description = "Random number generation service" },
    @{ Phase = 3; Script = "23a-GenerateFormationService.ps1"; Description = "Formation service with pattern library and caching" },
    @{ Phase = 3; Script = "24-GeneratePhysicsService.ps1"; Description = "Physics engine service" },
    @{ Phase = 3; Script = "25-SetupPhysicsWebWorkers.ps1"; Description = "Physics worker threads" },
    @{ Phase = 3; Script = "26-GenerateBitcoinService.ps1"; Description = "Bitcoin blockchain service" },
    @{ Phase = 3; Script = "26a-EnhanceBitcoinServiceRetry.ps1"; Description = "Bitcoin service retry logic and rate limiting" },
    @{ Phase = 3; Script = "27-GenerateTraitService.ps1"; Description = "Trait management service" },
    @{ Phase = 3; Script = "27b-GenerateTraitDataFiles.ps1"; Description = "Generate trait definition data files and mutation tables" },
    @{ Phase = 3; Script = "27c-ConfigureTraitDependencyInjection.ps1"; Description = "Configure trait service dependency injection and generate comprehensive tests" },
    @{ Phase = 3; Script = "28-SetupBlockchainDataIntegration.ps1"; Description = "Real-time blockchain data" },
    @{ Phase = 3; Script = "29-SetupDataValidationLayer.ps1"; Description = "Data validation framework" },
    @{ Phase = 3; Script = "29a-SetupOpenTelemetry.ps1"; Description = "OpenTelemetry observability with Winston integration" },

    # === PHASE 4: DOMAIN SERVICES (12 Scripts) ===
    # Core entity and behavior services
    @{ Phase = 4; Script = "30-EnhanceTraitSystem.ps1"; Description = "Enhanced trait system" },
    @{ Phase = 4; Script = "31-GenerateParticleService.ps1"; Description = "Particle service (core entity)" },
    @{ Phase = 4; Script = "31b-RefactorParticleStoreInjection.ps1"; Description = "Refactor particle service to use injected stores instead of direct imports" },
    @{ Phase = 4; Script = "32-SetupParticleLifecycleManagement.ps1"; Description = "Particle lifecycle" },
    @{ Phase = 4; Script = "32a-GenerateEvolutionEngine.ps1"; Description = "Evolution engine with mutation algorithms and trait inheritance" },
    @{ Phase = 4; Script = "33-ImplementSwarmIntelligence.ps1"; Description = "Swarm behavior" },
    @{ Phase = 4; Script = "33a-GenerateStores.ps1"; Description = "Zustand stores with devtools integration" },
    @{ Phase = 4; Script = "34-EnhanceFormationSystem.ps1"; Description = "Formation enhancements" },
    @{ Phase = 4; Script = "35-GenerateRenderingService.ps1"; Description = "THREE.js rendering service" },
    @{ Phase = 4; Script = "36-GenerateEffectService.ps1"; Description = "Visual effects service" },
    @{ Phase = 4; Script = "36a-GenerateEffectDomain.ps1"; Description = "Generate complete effect domain with mutation visual hooks and GPU resource management" },
    @{ Phase = 4; Script = "37-SetupCustomShaderSystem.ps1"; Description = "Custom shader pipeline" },
    @{ Phase = 4; Script = "38-ImplementLODSystem.ps1"; Description = "Level-of-detail optimization" },
    @{ Phase = 4; Script = "39-SetupAdvancedEffectComposition.ps1"; Description = "Effect composition" },
    # === PHASE 5: BEHAVIORAL SERVICES (9 Scripts) ===
    # Animation and advanced behaviors
    @{ Phase = 5; Script = "40-GenerateAnimationService.ps1"; Description = "Animation service" },
    @{ Phase = 5; Script = "41-GenerateGroupService.ps1"; Description = "Group management service" },
    @{ Phase = 5; Script = "41a-SetupR3FIntegration.ps1"; Description = "React Three Fiber declarative rendering" },
    @{ Phase = 5; Script = "42-SetupPhysicsBasedAnimation.ps1"; Description = "Physics-driven animation" },
    @{ Phase = 5; Script = "43-ImplementAdvancedTimeline.ps1"; Description = "Timeline system" },
    @{ Phase = 5; Script = "44-SetupAnimationBlending.ps1"; Description = "Animation blending" },
    @{ Phase = 5; Script = "18b-SetupTestingFramework.ps1"; Description = "Vitest testing framework" },

    # === PHASE 6: ADVANCED TOOLING (4 Scripts) ===
    # Analysis and documentation
    @{ Phase = 6; Script = "45-SetupCICDPipeline.ps1"; Description = "CI/CD pipeline" },
    @{ Phase = 6; Script = "46-SetupDockerDeployment.ps1"; Description = "Docker deployment" },
    @{ Phase = 6; Script = "47-SetupPerformanceRegression.ps1"; Description = "Performance monitoring" },
    @{ Phase = 6; Script = "48-SetupAdvancedBundleAnalysis.ps1"; Description = "Bundle size analysis" },
    @{ Phase = 6; Script = "49-SetupAutomatedDocumentation.ps1"; Description = "TypeDoc documentation" },
    @{ Phase = 6; Script = "50-SetupServiceIntegration.ps1"; Description = "Dependency injection setup" },

    # === PHASE 7: FRONTEND INTEGRATION (7 Scripts) ===
    # React and state management
    @{ Phase = 7; Script = "51-SetupGlobalStateManagement.ps1"; Description = "Zustand state management" },
            @{ Phase = 7; Script = "52-SetupReactIntegration.ps1"; Description = "React component integration" },
        @{ Phase = 7; Script = "59-GenerateMainEntryPoint.ps1"; Description = "Generate React main.tsx entry point" },
        @{ Phase = 7; Script = "60-SetupBrowserServerRequirements.ps1"; Description = "Vite config, path aliases, and development server setup" },
        @{ Phase = 7; Script = "60a-VerifyWorkerDisposal.ps1"; Description = "AST validation for proper worker cleanup" },
        @{ Phase = 7; Script = "53-SetupEventBusSystem.ps1"; Description = "Event bus system" },
    @{ Phase = 7; Script = "54-SetupPerformanceTesting.ps1"; Description = "Performance testing suite" },
    @{ Phase = 7; Script = "54a-SetupPerformanceBenchmarks.ps1"; Description = "Vitest performance benchmarks with CI integration" },
    @{ Phase = 7; Script = "55-SetupPersistenceLayer.ps1"; Description = "Data persistence" },
    @{ Phase = 7; Script = "56-SetupEndToEndValidation.ps1"; Description = "E2E testing" },

    # === PHASE 8: TYPESCRIPT FIXES (1 Script) ===
    # Critical TypeScript issue resolution
    @{ Phase = 8; Script = "57-FixCriticalTypeScriptIssues.ps1"; Description = "Critical TypeScript fixes and template regeneration" },

    # === PHASE 9: FINAL VALIDATION (1 Script) ===
    # Complete system validation
    @{ Phase = 9; Script = "15-ValidateSetupComplete.ps1"; Description = "Comprehensive final validation" }
)

# Track execution results
$results = @()
$startTime = Get-Date

# Execute each script in sequence
for ($i = 0; $i -lt $scriptSequence.Count; $i++) {
    $step = $scriptSequence[$i]
    $stepNumber = $i + 1
    $scriptPath = Join-Path $PSScriptRoot $step.Script

    Write-StepHeader "PHASE $($step.Phase) - STEP $stepNumber : $($step.Description)"
    Write-InfoLog "Executing: $($step.Script) (Step $stepNumber of $($scriptSequence.Count))"

    if (-not (Test-Path $scriptPath)) {
        Write-ErrorLog "Script not found: $scriptPath"
        $results += [PSCustomObject]@{
            Phase = $step.Phase
            Script = $step.Script
            Status = "MISSING"
            Duration = 0
            Error = "Script file not found"
        }
        continue
    }

    $stepStartTime = Get-Date
    try {
        # Reset exit code before execution
        $global:LASTEXITCODE = 0
        
        # Execute the script and capture output
        & $scriptPath 2>&1
        $stepDuration = (Get-Date) - $stepStartTime
        $scriptExitCode = $LASTEXITCODE

        if ($scriptExitCode -eq 0 -or $scriptExitCode -eq $null) {
            Write-SuccessLog "PHASE $($step.Phase) completed successfully in $($stepDuration.TotalSeconds) seconds"
            $results += [PSCustomObject]@{
                Phase = $step.Phase
                Script = $step.Script
                Status = "SUCCESS"
                Duration = $stepDuration.TotalSeconds
                Error = $null
            }
        } else {
            throw "Script exited with code $scriptExitCode"
        }
    }
    catch {
        $stepDuration = (Get-Date) - $stepStartTime
        Write-ErrorLog "PHASE $($step.Phase) FAILED: $($_.Exception.Message)"
        $results += [PSCustomObject]@{
            Phase = $step.Phase
            Script = $step.Script
            Status = "FAILED"
            Duration = $stepDuration.TotalSeconds
            Error = $_.Exception.Message
        }

        # Ask user if they want to continue despite failure
        $choice = Read-Host "Phase $($step.Phase) failed. Continue with remaining phases? (y/N)"
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
        "SUCCESS" { "[OK]" }
        "FAILED" { "[FAIL]" }
        "MISSING" { "[MISS]" }
    }
    $durationText = if ($result.Duration -gt 0) { " ($($result.Duration.ToString('F1'))s)" } else { "" }
    Write-InfoLog "  Phase $($result.Phase): $status $($result.Script)$durationText"

    if ($result.Error) {
        Write-WarningLog "    Error: $($result.Error)"
    }
}

# Final status determination
if ($failedCount -eq 0 -and $missingCount -eq 0) {
    Write-SuccessLog "[SUCCESS] ALL AUTOMATION PHASES COMPLETED SUCCESSFULLY!"
    Write-InfoLog "Your new-protozoa project is ready for Cursor AI implementation."
    Write-InfoLog "Processing step completed"
    Write-InfoLog "Next steps:"
    Write-InfoLog "1. Open the project in Cursor"
    Write-InfoLog "2. Paste the XML instructions from the documentation"
    Write-InfoLog "3. Start implementing domain logic phase by phase"
    Write-InfoLog "4. Run 05-VerifyCompliance.ps1 after each phase to maintain standards"

    exit 0
} elseif ($successCount -gt 0) {
            Write-WarningLog "[WARNING] AUTOMATION PARTIALLY COMPLETED"
    Write-InfoLog "Some phases succeeded, but manual intervention may be required."
    Write-InfoLog "Check the error messages above and resolve issues before proceeding."

    exit 1
} else {
            Write-ErrorLog "[ERROR] AUTOMATION FAILED"
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
