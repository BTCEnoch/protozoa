# 03-analyze-resource-usage.ps1
# Resource Usage Analysis for PowerShell Script Suite
# Analyzes memory usage, execution time, file I/O patterns, and resource dependencies

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptDirectory,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "resource-usage-analysis.json",
    
    [Parameter(Mandatory = $false)]
    [int]$MaxAnalysisTimeSeconds = 300,
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludePerformanceMetrics
)

$ErrorActionPreference = "Stop"

# Import required modules
Import-Module "$PSScriptRoot\utils\ast-parser.psm1" -Force

function Get-ResourceUsagePatterns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )
    
    $resourcePatterns = @{
        FileOperations = @()
        MemoryIntensive = @()
        NetworkCalls = @()
        ProcessCalls = @()
        DatabaseCalls = @()
        RegistryAccess = @()
        WMIQueries = @()
        ServiceCalls = @()
    }
    
    try {
        # Check file size and skip if too large to prevent performance issues
        $fileInfo = Get-Item -Path $ScriptPath
        if ($fileInfo.Length -gt 1MB) {
            Write-Warning "Skipping large file: $($fileInfo.Name) ($([Math]::Round($fileInfo.Length/1KB))KB)"
            return $resourcePatterns
        }
        
        $content = Get-Content -Path $ScriptPath -Raw
        if ([string]::IsNullOrEmpty($content)) {
            return $resourcePatterns
        }
        
        $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
        
        # Optimize: Create combined patterns for better performance
        $patternCategories = @{
            FileOperations = @(
                'Get-Content', 'Set-Content', 'Add-Content', 'Out-File', 'Import-Csv', 'Export-Csv',
                'Get-ChildItem', 'Copy-Item', 'Move-Item', 'Remove-Item', 'New-Item', 'Test-Path',
                '\[System\.IO\.File\]', '\[System\.IO\.Directory\]'
            )
            MemoryIntensive = @(
                'Get-WmiObject', 'Get-CimInstance', 'Import-Module.*-Global', '\$global:',
                'foreach.*\$.*in.*Get-ChildItem.*-Recurse', 'Get-Content.*-Raw',
                '\[System\.Collections\.ArrayList\]', '\[System\.Collections\.Generic'
            )
            NetworkCalls = @(
                'Invoke-WebRequest', 'Invoke-RestMethod', 'Start-BitsTransfer', 'Test-NetConnection',
                'Get-NetAdapter', 'New-WebServiceProxy', '\[System\.Net\.WebClient\]',
                '\[System\.Net\.HttpWebRequest\]', 'Download.*String', 'DownloadFile'
            )
            ProcessCalls = @(
                'Start-Process', 'Stop-Process', 'Get-Process', 'Wait-Process', 'Invoke-Expression',
                '& ".*"', "& '.*'", 'cmd /c', 'powershell -Command', '\[System\.Diagnostics\.Process\]'
            )
            DatabaseCalls = @(
                'Invoke-Sqlcmd', 'New-Object.*System\.Data\.SqlClient', 'System\.Data\.OleDb',
                'System\.Data\.Odbc', 'Microsoft\.SqlServer', 'Oracle\.DataAccess', 'MySql\.Data'
            )
            RegistryAccess = @(
                'Get-ItemProperty.*HKLM', 'Set-ItemProperty.*HKLM', 'New-ItemProperty.*HKLM',
                'Remove-ItemProperty.*HKLM', 'Get-ChildItem.*HKLM', '\[Microsoft\.Win32\.Registry\]', 'Registry::'
            )
            WMIQueries = @(
                'Get-WmiObject.*Win32_', 'Get-CimInstance.*Win32_', 'Get-WmiObject.*-Computer',
                'Get-CimInstance.*-Computer', 'Invoke-WmiMethod', 'Register-WmiEvent'
            )
            ServiceCalls = @(
                'Get-Service', 'Start-Service', 'Stop-Service', 'Restart-Service',
                'Set-Service', 'New-Service', 'Remove-Service'
            )
        }
        
        # Process each category with optimized regex
        foreach ($category in $patternCategories.Keys) {
            $categoryPatterns = $patternCategories[$category]
            
            # Create a single combined regex pattern for better performance
            $combinedPattern = '(' + ($categoryPatterns -join '|') + ')'
            
            try {
                $regexMatches = [regex]::Matches($content, $combinedPattern, 'IgnoreCase')
                
                foreach ($match in $regexMatches) {
                    $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
                    
                    $patternMatch = @{
                        Pattern = $match.Value
                        LineNumber = $lineNumber
                        Context = $match.Value
                        ScriptName = $scriptName
                    }
                    
                    # Add category-specific properties
                    switch ($category) {
                        'MemoryIntensive' {
                            $patternMatch.RiskLevel = if ($match.Value -like '*-Recurse*' -or $match.Value -like '*-Raw*') { 'High' } else { 'Medium' }
                        }
                        'NetworkCalls' {
                            $patternMatch.RequiresInternet = $true
                        }
                        'ProcessCalls' {
                            $patternMatch.SecurityRisk = if ($match.Value -like '*Invoke-Expression*' -or $match.Value -like '*cmd /c*') { 'High' } else { 'Medium' }
                        }
                        'RegistryAccess' {
                            $patternMatch.RequiresElevation = $true
                        }
                        'WMIQueries' {
                            $patternMatch.PerformanceImpact = 'Medium'
                        }
                        'ServiceCalls' {
                            $patternMatch.RequiresElevation = ($match.Value -like '*Start-*' -or $match.Value -like '*Stop-*' -or $match.Value -like '*Set-*')
                        }
                    }
                    
                    $resourcePatterns[$category] += $patternMatch
                }
            }
            catch {
                Write-Warning "Failed to process $category patterns in $scriptName : $($_.Exception.Message)"
            }
        }
        
        return $resourcePatterns
    }
    catch {
        Write-Warning "Failed to analyze resource patterns in $ScriptPath : $($_.Exception.Message)"
        return $resourcePatterns
    }
} 

try {
    Write-Host "=== RESOURCE USAGE ANALYSIS STARTING ===" -ForegroundColor Cyan
    Write-Host "Analyzing scripts in: $ScriptDirectory" -ForegroundColor Yellow
    
    # Get all PowerShell scripts
    $scripts = Get-ChildItem -Path $ScriptDirectory -Filter "*.ps1" -Recurse
    Write-Host "Found $($scripts.Count) PowerShell scripts to analyze" -ForegroundColor Green
    
    # Initialize results
    $analysisResults = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ScriptDirectory = $ScriptDirectory
        Statistics = @{
            TotalScripts = $scripts.Count
            HighMemoryRiskScripts = 0
            NetworkDependentScripts = 0
            ElevationRequiredScripts = 0
            DatabaseConnectedScripts = 0
            TotalResourceUsagePatterns = 0
        }
        ResourcePatterns = @{
            FileOperations = @()
            MemoryIntensive = @()
            NetworkCalls = @()
            ProcessCalls = @()
            DatabaseCalls = @()
            RegistryAccess = @()
            WMIQueries = @()
            ServiceCalls = @()
        }
        Recommendations = @()
        ScriptRiskProfiles = @()
    }
    
    Write-Host "Analyzing resource usage patterns..." -ForegroundColor Green
    Write-Host "Will analyze $($scripts.Count) scripts with progress logging..." -ForegroundColor Yellow
    
    # Analyze each script with progress logging
    $currentScript = 0
    $progressInterval = [Math]::Max(1, [Math]::Floor($scripts.Count / 10)) # Update every 10%
    
    foreach ($script in $scripts) {
        $currentScript++
        
        # Progress logging
        if ($currentScript % $progressInterval -eq 0 -or $currentScript -eq $scripts.Count) {
            $percentComplete = [Math]::Round(($currentScript / $scripts.Count) * 100, 1)
            Write-Host "  Progress: $percentComplete% ($currentScript/$($scripts.Count)) - Processing: $($script.Name)" -ForegroundColor Gray
        } else {
            Write-Host "  Processing ($currentScript/$($scripts.Count)): $($script.Name)" -ForegroundColor DarkGray
        }
        
        try {
            $resourcePatterns = Get-ResourceUsagePatterns -ScriptPath $script.FullName
            
            # Aggregate patterns
            $categories = @($analysisResults.ResourcePatterns.Keys)
            foreach ($category in $categories) {
                if ($resourcePatterns.ContainsKey($category)) {
                    $analysisResults.ResourcePatterns[$category] += $resourcePatterns[$category]
                }
            }
            
            # Calculate risk profile for this script
            $riskProfile = @{
                ScriptName = $script.BaseName
                FilePath = $script.FullName
                MemoryRisk = if ($resourcePatterns.MemoryIntensive.Count -gt 0) { 'Medium' } else { 'Low' }
                NetworkDependency = ($resourcePatterns.NetworkCalls.Count -gt 0)
                ElevationRequired = ($resourcePatterns.RegistryAccess.Count -gt 0 -or 
                                   ($resourcePatterns.ServiceCalls | Where-Object { $_.RequiresElevation }).Count -gt 0)
                PerformanceImpact = if ($resourcePatterns.WMIQueries.Count -gt 3 -or $resourcePatterns.MemoryIntensive.Count -gt 2) { 'High' } 
                                   elseif ($resourcePatterns.WMIQueries.Count -gt 0 -or $resourcePatterns.MemoryIntensive.Count -gt 0) { 'Medium' } 
                                   else { 'Low' }
                ResourceScore = ($resourcePatterns.FileOperations.Count * 1) + 
                               ($resourcePatterns.MemoryIntensive.Count * 3) + 
                               ($resourcePatterns.NetworkCalls.Count * 2) + 
                               ($resourcePatterns.ProcessCalls.Count * 2) + 
                               ($resourcePatterns.DatabaseCalls.Count * 4) + 
                               ($resourcePatterns.RegistryAccess.Count * 3) + 
                               ($resourcePatterns.WMIQueries.Count * 2) + 
                               ($resourcePatterns.ServiceCalls.Count * 2)
            }
            
            $analysisResults.ScriptRiskProfiles += $riskProfile
            
            # Update statistics
            if ($riskProfile.MemoryRisk -eq 'High' -or $resourcePatterns.MemoryIntensive.Count -gt 2) {
                $analysisResults.Statistics.HighMemoryRiskScripts++
            }
            if ($riskProfile.NetworkDependency) {
                $analysisResults.Statistics.NetworkDependentScripts++
            }
            if ($riskProfile.ElevationRequired) {
                $analysisResults.Statistics.ElevationRequiredScripts++
            }
            if ($resourcePatterns.DatabaseCalls.Count -gt 0) {
                $analysisResults.Statistics.DatabaseConnectedScripts++
            }
        }
        catch {
            Write-Warning "Failed to analyze $($script.Name): $($_.Exception.Message)"
        }
    }
    
    # Calculate total resource patterns
    $categories = @($analysisResults.ResourcePatterns.Keys)
    foreach ($category in $categories) {
        $analysisResults.Statistics.TotalResourceUsagePatterns += $analysisResults.ResourcePatterns[$category].Count
    }
    
    # Generate recommendations
    if ($analysisResults.Statistics.HighMemoryRiskScripts -gt 0) {
        $analysisResults.Recommendations += "WARNING: $($analysisResults.Statistics.HighMemoryRiskScripts) scripts have high memory usage risk - consider optimization"
    }
    
    if ($analysisResults.Statistics.NetworkDependentScripts -gt 0) {
        $analysisResults.Recommendations += "INFO: $($analysisResults.Statistics.NetworkDependentScripts) scripts require network connectivity - ensure internet access during execution"
    }
    
    if ($analysisResults.Statistics.ElevationRequiredScripts -gt 0) {
        $analysisResults.Recommendations += "CRITICAL: $($analysisResults.Statistics.ElevationRequiredScripts) scripts require administrator privileges - run as administrator"
    }
    
    if ($analysisResults.Statistics.DatabaseConnectedScripts -gt 0) {
        $analysisResults.Recommendations += "INFO: $($analysisResults.Statistics.DatabaseConnectedScripts) scripts connect to databases - ensure database connectivity and credentials"
    }
    
    # Sort scripts by resource score (highest risk first)
    $analysisResults.ScriptRiskProfiles = $analysisResults.ScriptRiskProfiles | Sort-Object ResourceScore -Descending
    
    # Save results
    $outputPath = if ([System.IO.Path]::IsPathRooted($OutputFile)) { $OutputFile } else { Join-Path $PWD $OutputFile }
    $analysisResults | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8
    
    # Display summary
    Write-Host "`n=== RESOURCE USAGE ANALYSIS SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Scripts: $($analysisResults.Statistics.TotalScripts)" -ForegroundColor White
    Write-Host "High Memory Risk: $($analysisResults.Statistics.HighMemoryRiskScripts)" -ForegroundColor $(if ($analysisResults.Statistics.HighMemoryRiskScripts -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Network Dependent: $($analysisResults.Statistics.NetworkDependentScripts)" -ForegroundColor $(if ($analysisResults.Statistics.NetworkDependentScripts -gt 0) { "Cyan" } else { "Green" })
    Write-Host "Elevation Required: $($analysisResults.Statistics.ElevationRequiredScripts)" -ForegroundColor $(if ($analysisResults.Statistics.ElevationRequiredScripts -gt 0) { "Red" } else { "Green" })
    Write-Host "Database Connected: $($analysisResults.Statistics.DatabaseConnectedScripts)" -ForegroundColor $(if ($analysisResults.Statistics.DatabaseConnectedScripts -gt 0) { "Cyan" } else { "Green" })
    Write-Host "Resource Patterns Found: $($analysisResults.Statistics.TotalResourceUsagePatterns)" -ForegroundColor White
    
    Write-Host "`nAnalysis complete. Results saved to: $outputPath" -ForegroundColor Green
    Write-Host "=== RESOURCE USAGE ANALYSIS COMPLETE ===" -ForegroundColor Cyan
}
catch {
    Write-Error "Resource usage analysis failed: $($_.Exception.Message)"
    exit 1
} 