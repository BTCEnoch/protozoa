# 01-analyze-dependencies.ps1
# Analyzes dependency patterns across all PowerShell scripts in the suite
# Part of the script scrub analysis suite

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptDirectory = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "dependency-analysis.json"
)

try {
    # Import required utilities
    Import-Module "$PSScriptRoot\utils\dependency-graph.psm1" -Force -ErrorAction Stop
    Import-Module "$PSScriptRoot\utils\ast-parser.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import required utilities: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-Host "=== DEPENDENCY ANALYSIS STARTING ===" -ForegroundColor Cyan
    Write-Host "Analyzing scripts in: $ScriptDirectory" -ForegroundColor Yellow
    
    # Build the complete dependency graph
    Write-Host "Building dependency graph..." -ForegroundColor Green
    $dependencyGraph = New-DependencyGraph -ScriptDirectory $ScriptDirectory
    
    # Analyze import patterns
    Write-Host "Analyzing import patterns..." -ForegroundColor Green
    $importAnalysis = @{}
    $utilsUsage = @{}
    
    foreach ($scriptName in $dependencyGraph.Keys) {
        $scriptPath = $dependencyGraph[$scriptName].FilePath
        
        try {
            $parsedScript = Get-ScriptAst -ScriptPath $scriptPath
            $imports = Get-ImportStatements -ParsedScript $parsedScript
            
            $importAnalysis[$scriptName] = @{
                FilePath = $scriptPath
                Imports = $imports
                ImportCount = $imports.Count
                UsesUtils = ($imports | Where-Object { $_.ModulePath -like "*utils*" }).Count -gt 0
            }
            
            # Track utils.psm1 usage specifically
            $utilsImport = $imports | Where-Object { $_.ModulePath -like "*utils.psm1" }
            if ($utilsImport) {
                $utilsUsage[$scriptName] = @{
                    ImportLine = $utilsImport.StartLine
                    ImportType = $utilsImport.Type
                }
            }
        }
        catch {
            Write-Warning "Failed to analyze imports for $scriptName`: $($_.Exception.Message)"
        }
    }
    
    # Detect circular dependencies
    Write-Host "Detecting circular dependencies..." -ForegroundColor Green
    $circularDependencies = Test-CircularDependencies -DependencyGraph $dependencyGraph
    
    # Analyze dependency patterns
    Write-Host "Analyzing dependency patterns..." -ForegroundColor Green
    $dependencyStats = @{
        TotalScripts = $dependencyGraph.Count
        ScriptsWithDependencies = ($dependencyGraph.Values | Where-Object { $_.Dependencies.Count -gt 0 }).Count
        ScriptsWithDependents = ($dependencyGraph.Values | Where-Object { $_.Dependents.Count -gt 0 }).Count
        UtilsUsageCount = $utilsUsage.Count
        CircularDependencyCount = $circularDependencies.Count
        IsolatedScripts = ($dependencyGraph.Values | Where-Object { 
            $_.Dependencies.Count -eq 0 -and $_.Dependents.Count -eq 0 
        }).Count
    }
    
    # Generate comprehensive analysis report
    $analysisResult = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ScriptDirectory = $ScriptDirectory
        DependencyGraph = $dependencyGraph
        ImportAnalysis = $importAnalysis
        UtilsUsage = $utilsUsage
        CircularDependencies = $circularDependencies
        Statistics = $dependencyStats
        Recommendations = @()
    }
    
    # Generate recommendations
    if ($circularDependencies.Count -gt 0) {
        $analysisResult.Recommendations += "CRITICAL: Found $($circularDependencies.Count) circular dependencies that must be resolved"
    }
    
    if ($utilsUsage.Count -lt ($dependencyStats.TotalScripts * 0.8)) {
        $analysisResult.Recommendations += "WARNING: Only $($utilsUsage.Count) of $($dependencyStats.TotalScripts) scripts use utils.psm1 - consider standardizing"
    }
    
    if ($dependencyStats.IsolatedScripts -gt 5) {
        $analysisResult.Recommendations += "INFO: $($dependencyStats.IsolatedScripts) isolated scripts found - verify if consolidation is possible"
    }
    
    # Export results
    $outputPath = Join-Path $PSScriptRoot $OutputFile
    $analysisResult | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8
    
    # Display summary
    Write-Host "`n=== DEPENDENCY ANALYSIS SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Scripts Analyzed: $($dependencyStats.TotalScripts)" -ForegroundColor White
    Write-Host "Scripts with Dependencies: $($dependencyStats.ScriptsWithDependencies)" -ForegroundColor White
    Write-Host "Utils.psm1 Usage: $($utilsUsage.Count) scripts" -ForegroundColor White
    Write-Host "Circular Dependencies: $($circularDependencies.Count)" -ForegroundColor $(if ($circularDependencies.Count -gt 0) { "Red" } else { "Green" })
    Write-Host "Isolated Scripts: $($dependencyStats.IsolatedScripts)" -ForegroundColor White
    
    if ($circularDependencies.Count -gt 0) {
        Write-Host "`nCIRCULAR DEPENDENCIES FOUND:" -ForegroundColor Red
        foreach ($cycle in $circularDependencies) {
            Write-Host "  $($cycle -join ' -> ')" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nAnalysis complete. Results saved to: $outputPath" -ForegroundColor Green
    Write-Host "=== DEPENDENCY ANALYSIS COMPLETE ===" -ForegroundColor Cyan
    
    exit 0
}
catch {
    Write-Error "Dependency analysis failed: $($_.Exception.Message)"
    exit 1
} 