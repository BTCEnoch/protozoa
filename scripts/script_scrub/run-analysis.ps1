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
        }
        Summary = @()
    }
    
    # Step 1: Dependency Analysis
    Write-Host "`n--- STEP 1: DEPENDENCY ANALYSIS ---" -ForegroundColor Magenta
    try {
        $depOutputFile = Join-Path $OutputDirectory "dependency-analysis.json"
        & "$PSScriptRoot\01-analyze-dependencies.ps1" -ScriptDirectory $ScriptDirectory -OutputFile $depOutputFile
        
        if (Test-Path $depOutputFile) {
            $depResults = Get-Content $depOutputFile | ConvertFrom-Json
            $analysisResults.AnalysisSteps += @{
                Step = "Dependency Analysis"
                Status = "Success"
                OutputFile = $depOutputFile
                Issues = @{
                    CircularDependencies = $depResults.Statistics.CircularDependencyCount
                    IsolatedScripts = $depResults.Statistics.IsolatedScripts
                }
                Recommendations = $depResults.Recommendations
            }
            
            # Add to overall counts
            $analysisResults.OverallResults.CriticalIssues += $depResults.Statistics.CircularDependencyCount
            if ($depResults.Statistics.IsolatedScripts -gt 5) {
                $analysisResults.OverallResults.InfoIssues += 1
            }
        }
        Write-Host "✅ Dependency analysis completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Warning "❌ Dependency analysis failed: $($_.Exception.Message)"
        $analysisResults.AnalysisSteps += @{
            Step = "Dependency Analysis"
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
    
    # Step 2: Duplicate Detection
    Write-Host "`n--- STEP 2: DUPLICATE DETECTION ---" -ForegroundColor Magenta
    try {
        $dupOutputFile = Join-Path $OutputDirectory "duplicate-analysis.json"
        & "$PSScriptRoot\02-detect-duplicates.ps1" -ScriptDirectory $ScriptDirectory -OutputFile $dupOutputFile
        
        if (Test-Path $dupOutputFile) {
            $dupResults = Get-Content $dupOutputFile | ConvertFrom-Json
            $analysisResults.AnalysisSteps += @{
                Step = "Duplicate Detection"
                Status = "Success"
                OutputFile = $dupOutputFile
                Issues = @{
                    ExactDuplicates = $dupResults.Statistics.ExactDuplicates
                    SimilarNames = $dupResults.Statistics.SimilarNames
                }
                Recommendations = $dupResults.Recommendations
            }
            
            # Add to overall counts
            $analysisResults.OverallResults.CriticalIssues += $dupResults.Statistics.ExactDuplicates
            $analysisResults.OverallResults.WarningIssues += $dupResults.Statistics.SimilarNames
        }
        Write-Host "✅ Duplicate detection completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Warning "❌ Duplicate detection failed: $($_.Exception.Message)"
        $analysisResults.AnalysisSteps += @{
            Step = "Duplicate Detection"
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
    
    # Calculate total issues
    $analysisResults.OverallResults.TotalIssues = 
        $analysisResults.OverallResults.CriticalIssues + 
        $analysisResults.OverallResults.WarningIssues + 
        $analysisResults.OverallResults.InfoIssues
    
    # Generate executive summary
    $analysisResults.Summary += "=== SCRIPT SCRUB ANALYSIS SUMMARY ==="
    $analysisResults.Summary += "Analysis Date: $($analysisResults.Timestamp)"
    $analysisResults.Summary += "Scripts Directory: $ScriptDirectory"
    $analysisResults.Summary += ""
    $analysisResults.Summary += "ISSUE SUMMARY:"
    $analysisResults.Summary += "  Total Issues: $($analysisResults.OverallResults.TotalIssues)"
    $analysisResults.Summary += "  Critical Issues: $($analysisResults.OverallResults.CriticalIssues)"
    $analysisResults.Summary += "  Warning Issues: $($analysisResults.OverallResults.WarningIssues)"
    $analysisResults.Summary += "  Info Issues: $($analysisResults.OverallResults.InfoIssues)"
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