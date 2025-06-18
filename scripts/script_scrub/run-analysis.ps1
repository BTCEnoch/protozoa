# run-analysis.ps1
# Master runner for the script scrub analysis suite
# Executes all analysis scripts and generates comprehensive report

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptDirectory = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "$PSScriptRoot\results",
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateReport
)

$ErrorActionPreference = "Stop"

try {
    Write-Host "=== SCRIPT SCRUB ANALYSIS SUITE STARTING ===" -ForegroundColor Cyan
    Write-Host "Analyzing script directory: $ScriptDirectory" -ForegroundColor Yellow
    Write-Host "Output directory: $OutputDirectory" -ForegroundColor Yellow
    
    # Create output directory
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
        Write-Host "Created output directory: $OutputDirectory" -ForegroundColor Green
    }
    
    # Initialize results tracking
    $analysisResults = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ScriptDirectory = $ScriptDirectory
        OutputDirectory = $OutputDirectory
        AnalysisSteps = @()
        OverallResults = @{
            TotalIssues = 0
            CriticalIssues = 0
            WarningIssues = 0
            InfoIssues = 0
            TotalRecommendations = 0
            PerformanceIssues = 0
        }
        Summary = @()
    }
    
    # Define analysis steps with progress tracking
    $analysisSteps = @(
        @{ 
            Name = "Dependency Analysis"
            Script = "01-analyze-dependencies.ps1"
            OutputFile = "dependency-analysis.json"
            Description = "Analyzing script dependencies and relationships"
        },
        @{ 
            Name = "Duplicate Detection"
            Script = "02-detect-duplicates.ps1"
            OutputFile = "duplicate-analysis.json"
            Description = "Detecting duplicate code and similar functions"
        },
        @{ 
            Name = "Resource Usage Analysis"
            Script = "03-analyze-resource-usage.ps1"
            OutputFile = "resource-usage-analysis.json"
            Description = "Analyzing resource usage patterns and potential issues"
        },
        @{ 
            Name = "Code Quality Analysis"
            Script = "04-code-quality-analysis.ps1"
            OutputFile = "code-quality-analysis.json"
            Description = "Checking code quality and best practices"
        },
        @{ 
            Name = "Performance Analysis"
            Script = "05-performance-analysis.ps1"
            OutputFile = "performance-analysis.json"
            Description = "Analyzing script performance and execution metrics"
        }
    )
    
    Write-Host "`nStarting comprehensive analysis with $($analysisSteps.Count) steps..." -ForegroundColor Green
    Write-Host "Estimated completion time: 2-5 minutes depending on script count" -ForegroundColor Yellow
    
    # Execute each analysis step with progress tracking
    $currentStep = 0
    foreach ($step in $analysisSteps) {
        $currentStep++
        $percentComplete = [Math]::Round(($currentStep / $analysisSteps.Count) * 100, 1)
        
        Write-Host "`n--- STEP $currentStep/$($analysisSteps.Count): $($step.Name.ToUpper()) ($percentComplete%) ---" -ForegroundColor Magenta
        Write-Host "$($step.Description)..." -ForegroundColor Gray
        
        try {
            $outputFile = Join-Path $OutputDirectory $step.OutputFile
            $scriptPath = Join-Path $PSScriptRoot $step.Script
            
            # Check if script exists
            if (-not (Test-Path $scriptPath)) {
                throw "Analysis script not found: $scriptPath"
            }
            
            # Execute analysis with timing
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            # Run with optimized parameters for faster execution
            switch ($step.Script) {
                "05-performance-analysis.ps1" {
                    & $scriptPath -ScriptDirectory $ScriptDirectory -OutputFile $outputFile -SampleRuns 1 -SkipSlowScripts
                }
                default {
                    & $scriptPath -ScriptDirectory $ScriptDirectory -OutputFile $outputFile
                }
            }
            
            $stopwatch.Stop()
            $executionTime = [Math]::Round($stopwatch.ElapsedMilliseconds / 1000, 2)
            
            # Process results if output file exists
            if (Test-Path $outputFile) {
                try {
                    $stepResults = Get-Content $outputFile | ConvertFrom-Json
                    
                    # Create step summary
                    $stepSummary = @{
                        Step = $step.Name
                        Status = "Success"
                        OutputFile = $outputFile
                        ExecutionTime = "${executionTime}s"
                        Issues = @{}
                        Recommendations = @()
                    }
                    
                    # Extract relevant metrics based on step type
                    switch ($step.Script) {
                        "01-analyze-dependencies.ps1" {
                            $stepSummary.Issues = @{
                                CircularDependencies = if ($stepResults.Statistics.CircularDependencyCount) { $stepResults.Statistics.CircularDependencyCount } else { 0 }
                                IsolatedScripts = if ($stepResults.Statistics.IsolatedScripts) { $stepResults.Statistics.IsolatedScripts } else { 0 }
                            }
                            $analysisResults.OverallResults.CriticalIssues += $stepSummary.Issues.CircularDependencies
                            if ($stepSummary.Issues.IsolatedScripts -gt 5) {
                                $analysisResults.OverallResults.InfoIssues += 1
                            }
                        }
                        "02-detect-duplicates.ps1" {
                            $stepSummary.Issues = @{
                                ExactDuplicates = if ($stepResults.Statistics.ExactDuplicates) { $stepResults.Statistics.ExactDuplicates } else { 0 }
                                SimilarFunctions = if ($stepResults.Statistics.SimilarFunctions) { $stepResults.Statistics.SimilarFunctions } else { 0 }
                            }
                            $analysisResults.OverallResults.CriticalIssues += $stepSummary.Issues.ExactDuplicates
                            $analysisResults.OverallResults.WarningIssues += $stepSummary.Issues.SimilarFunctions
                        }
                        "03-analyze-resource-usage.ps1" {
                            $stepSummary.Issues = @{
                                HighMemoryRiskScripts = if ($stepResults.Statistics.HighMemoryRiskScripts) { $stepResults.Statistics.HighMemoryRiskScripts } else { 0 }
                                NetworkDependentScripts = if ($stepResults.Statistics.NetworkDependentScripts) { $stepResults.Statistics.NetworkDependentScripts } else { 0 }
                            }
                            $analysisResults.OverallResults.WarningIssues += $stepSummary.Issues.HighMemoryRiskScripts
                            $analysisResults.OverallResults.InfoIssues += $stepSummary.Issues.NetworkDependentScripts
                        }
                        "04-code-quality-analysis.ps1" {
                            $stepSummary.Issues = @{
                                ErrorIssues = if ($stepResults.Statistics.ErrorIssues) { $stepResults.Statistics.ErrorIssues } else { 0 }
                                WarningIssues = if ($stepResults.Statistics.WarningIssues) { $stepResults.Statistics.WarningIssues } else { 0 }
                                FixableIssues = if ($stepResults.Statistics.FixableIssues) { $stepResults.Statistics.FixableIssues } else { 0 }
                            }
                            $analysisResults.OverallResults.CriticalIssues += $stepSummary.Issues.ErrorIssues
                            $analysisResults.OverallResults.WarningIssues += $stepSummary.Issues.WarningIssues
                        }
                        "05-performance-analysis.ps1" {
                            $stepSummary.Issues = @{
                                PoorPerformanceScripts = if ($stepResults.Statistics.PoorPerformanceScripts) { $stepResults.Statistics.PoorPerformanceScripts } else { 0 }
                                HighMemoryScripts = if ($stepResults.Statistics.HighMemoryScripts) { $stepResults.Statistics.HighMemoryScripts } else { 0 }
                                TotalRecommendations = if ($stepResults.Statistics.TotalRecommendations) { $stepResults.Statistics.TotalRecommendations } else { 0 }
                            }
                            $analysisResults.OverallResults.PerformanceIssues += $stepSummary.Issues.PoorPerformanceScripts
                            $analysisResults.OverallResults.WarningIssues += $stepSummary.Issues.HighMemoryScripts
                            $analysisResults.OverallResults.TotalRecommendations += $stepSummary.Issues.TotalRecommendations
                        }
                    }
                    
                    # Add recommendations if available
                    if ($stepResults.Recommendations) {
                        $stepSummary.Recommendations = $stepResults.Recommendations
                    }
                    
                    $analysisResults.AnalysisSteps += $stepSummary
                    
                    Write-Host "✅ $($step.Name) completed successfully in ${executionTime}s" -ForegroundColor Green
                }
                catch {
                    Write-Warning "⚠️ Could not parse results from $($step.Name): $($_.Exception.Message)"
                    $analysisResults.AnalysisSteps += @{
                        Step = $step.Name
                        Status = "Completed with parsing errors"
                        OutputFile = $outputFile
                        ExecutionTime = "${executionTime}s"
                        Error = "Result parsing failed: $($_.Exception.Message)"
                    }
                }
            } else {
                throw "Output file not created: $outputFile"
            }
        }
        catch {
            Write-Warning "❌ $($step.Name) failed: $($_.Exception.Message)"
            $analysisResults.AnalysisSteps += @{
                Step = $step.Name
                Status = "Failed"
                Error = $_.Exception.Message
                ExecutionTime = if ($stopwatch) { "$([Math]::Round($stopwatch.ElapsedMilliseconds / 1000, 2))s" } else { "Unknown" }
            }
        }
    }
    
    Write-Host "`n--- ANALYSIS COMPLETE - GENERATING SUMMARY ---" -ForegroundColor Magenta
    
    # Calculate total issues
    $analysisResults.OverallResults.TotalIssues = 
        $analysisResults.OverallResults.CriticalIssues + 
        $analysisResults.OverallResults.WarningIssues + 
        $analysisResults.OverallResults.InfoIssues +
        $analysisResults.OverallResults.PerformanceIssues
    
    # Generate executive summary
    $analysisResults.Summary += "=== SCRIPT SCRUB ANALYSIS SUMMARY ==="
    $analysisResults.Summary += "Analysis Date: $($analysisResults.Timestamp)"
    $analysisResults.Summary += "Scripts Directory: $ScriptDirectory"
    $analysisResults.Summary += ""
    $analysisResults.Summary += "ANALYSIS STEPS COMPLETED:"
    foreach ($step in $analysisResults.AnalysisSteps) {
        $status = if ($step.Status -eq "Success") { "✅" } else { "❌" }
        $analysisResults.Summary += "  $status $($step.Step) - $($step.Status)"
    }
    $analysisResults.Summary += ""
    $analysisResults.Summary += "ISSUE SUMMARY:"
    $analysisResults.Summary += "  Total Issues: $($analysisResults.OverallResults.TotalIssues)"
    $analysisResults.Summary += "  Critical Issues: $($analysisResults.OverallResults.CriticalIssues)"
    $analysisResults.Summary += "  Warning Issues: $($analysisResults.OverallResults.WarningIssues)"
    $analysisResults.Summary += "  Info Issues: $($analysisResults.OverallResults.InfoIssues)"
    $analysisResults.Summary += "  Performance Issues: $($analysisResults.OverallResults.PerformanceIssues)"
    $analysisResults.Summary += "  Total Recommendations: $($analysisResults.OverallResults.TotalRecommendations)"
    $analysisResults.Summary += ""
    
    if ($analysisResults.OverallResults.TotalIssues -eq 0) {
        $analysisResults.Summary += "🎉 EXCELLENT: No critical issues found! Scripts are ready for execution."
    }
    elseif ($analysisResults.OverallResults.CriticalIssues -gt 0) {
        $analysisResults.Summary += "🚨 CRITICAL: Found $($analysisResults.OverallResults.CriticalIssues) critical issues that must be resolved before script execution."
    }
    else {
        $analysisResults.Summary += "⚠️ WARNING: Found $($analysisResults.OverallResults.WarningIssues) warning issues that should be reviewed."
    }
    
    # Generate comprehensive report (default to true if not specified)
    if ($GenerateReport -or -not $PSBoundParameters.ContainsKey('GenerateReport')) {
        $reportPath = Join-Path $OutputDirectory "comprehensive-analysis-report.json"
        $analysisResults | ConvertTo-Json -Depth 10 | Set-Content -Path $reportPath -Encoding UTF8
        Write-Host "`nComprehensive report saved to: $reportPath" -ForegroundColor Green
    }
    
    # Display final summary
    Write-Host "`n=== FINAL ANALYSIS SUMMARY ===" -ForegroundColor Cyan
    foreach ($line in $analysisResults.Summary) {
        $color = "White"
        if ($line -like "*CRITICAL*") { $color = "Red" }
        elseif ($line -like "*WARNING*") { $color = "Yellow" }
        elseif ($line -like "*EXCELLENT*") { $color = "Green" }
        
        Write-Host $line -ForegroundColor $color
    }
    
    Write-Host "`n=== SCRIPT SCRUB ANALYSIS COMPLETE ===" -ForegroundColor Cyan
    
    # Exit with appropriate code
    exit $(if ($analysisResults.OverallResults.CriticalIssues -gt 0) { 1 } else { 0 })
}
catch {
    Write-Error "Script scrub analysis failed: $($_.Exception.Message)"
    exit 1
} 