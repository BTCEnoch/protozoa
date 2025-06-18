# 05-performance-analysis.ps1
# Performance Analysis for PowerShell Script Suite
# Analyzes execution time, memory usage, bottlenecks, and performance patterns

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptDirectory,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "performance-analysis.json",
    
    [Parameter(Mandatory = $false)]
    [int]$SampleRuns = 3,
    
    [Parameter(Mandatory = $false)]
    [int]$TimeoutSeconds = 120,
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeMemoryProfiling,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipSlowScripts
)

$ErrorActionPreference = "Stop"

# Import required modules
Import-Module "$PSScriptRoot\utils\ast-parser.psm1" -Force

function Measure-ScriptPerformance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory = $false)]
        [int]$Runs = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds = 120
    )
    
    $performanceData = @{
        ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
        FilePath = $ScriptPath
        FileSize = (Get-Item $ScriptPath).Length
        ExecutionTimes = @()
        MemoryUsage = @()
        ExecutionResults = @()
        AverageExecutionTime = 0
        MinExecutionTime = 0
        MaxExecutionTime = 0
        MemoryPeak = 0
        PerformanceRating = 'Unknown'
        Bottlenecks = @()
        Recommendations = @()
        ExecutionMetrics = @{
            TotalOutputLines = 0
            AverageOutputLines = 0
            ErrorRate = 0
            SuccessfulRuns = 0
            FailedRuns = 0
        }
    }
    
    try {
        Write-Host "    Measuring performance for $($performanceData.ScriptName)..." -ForegroundColor Gray
        
        for ($i = 1; $i -le $Runs; $i++) {
            Write-Host "      Run $i/$Runs..." -ForegroundColor DarkGray
            
            # Get initial memory
            $initialMemory = [System.GC]::GetTotalMemory($false)
            
            # Measure execution time
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            try {
                # Execute script with timeout
                $job = Start-Job -ScriptBlock {
                    param($ScriptPath)
                    & $ScriptPath -WhatIf 2>$null
                } -ArgumentList $ScriptPath
                
                $completed = Wait-Job $job -Timeout $TimeoutSeconds
                
                if ($null -eq $completed) {
                    Stop-Job $job
                    Remove-Job $job
                    throw "Script execution timed out after $TimeoutSeconds seconds"
                }
                
                $result = Receive-Job $job
                Remove-Job $job
                
                $stopwatch.Stop()
                
                # Get final memory
                $finalMemory = [System.GC]::GetTotalMemory($true)
                $memoryUsed = $finalMemory - $initialMemory
                
                # Process and store execution results
                $executionResult = @{
                    Output = $result
                    OutputLines = if ($result) { @($result).Count } else { 0 }
                    HasErrors = $false
                    ErrorCount = 0
                }
                
                # Check for error indicators in output
                if ($result) {
                    $errorIndicators = @($result | Where-Object { $_ -match "error|exception|failed|warning" })
                    $executionResult.HasErrors = $errorIndicators.Count -gt 0
                    $executionResult.ErrorCount = $errorIndicators.Count
                }
                
                # Store execution metadata
                if (-not $performanceData.ContainsKey('ExecutionResults')) {
                    $performanceData.ExecutionResults = @()
                }
                $performanceData.ExecutionResults += $executionResult
                
                $performanceData.ExecutionTimes += $stopwatch.ElapsedMilliseconds
                $performanceData.MemoryUsage += [Math]::Max(0, $memoryUsed)
                
            }
            catch {
                $stopwatch.Stop()
                Write-Warning "Run $i failed: $($_.Exception.Message)"
                
                # Store failure information in execution results
                $failureResult = @{
                    Output = $null
                    OutputLines = 0
                    HasErrors = $true
                    ErrorCount = 1
                    FailureReason = $_.Exception.Message
                }
                
                if (-not $performanceData.ContainsKey('ExecutionResults')) {
                    $performanceData.ExecutionResults = @()
                }
                $performanceData.ExecutionResults += $failureResult
                
                $performanceData.ExecutionTimes += -1  # Mark failed runs
                $performanceData.MemoryUsage += 0
            }
        }
        
        # Calculate statistics
        $validTimes = $performanceData.ExecutionTimes | Where-Object { $_ -gt 0 }
        if ($validTimes.Count -gt 0) {
            $performanceData.AverageExecutionTime = ($validTimes | Measure-Object -Average).Average
            $performanceData.MinExecutionTime = ($validTimes | Measure-Object -Minimum).Minimum
            $performanceData.MaxExecutionTime = ($validTimes | Measure-Object -Maximum).Maximum
        }
        
        $performanceData.MemoryPeak = ($performanceData.MemoryUsage | Measure-Object -Maximum).Maximum
        
        # Calculate execution metrics from results
        if ($performanceData.ExecutionResults.Count -gt 0) {
            $successfulResults = $performanceData.ExecutionResults | Where-Object { -not $_.HasErrors }
            $failedResults = $performanceData.ExecutionResults | Where-Object { $_.HasErrors }
            
            $performanceData.ExecutionMetrics.SuccessfulRuns = $successfulResults.Count
            $performanceData.ExecutionMetrics.FailedRuns = $failedResults.Count
            $performanceData.ExecutionMetrics.ErrorRate = if ($performanceData.ExecutionResults.Count -gt 0) {
                [Math]::Round(($failedResults.Count / $performanceData.ExecutionResults.Count) * 100, 2)
            } else { 0 }
            
            $outputLinesArray = $performanceData.ExecutionResults | ForEach-Object { $_.OutputLines }
            $totalOutputLines = ($outputLinesArray | Measure-Object -Sum).Sum
            $performanceData.ExecutionMetrics.TotalOutputLines = $totalOutputLines
            $performanceData.ExecutionMetrics.AverageOutputLines = if ($performanceData.ExecutionResults.Count -gt 0) {
                [Math]::Round($totalOutputLines / $performanceData.ExecutionResults.Count, 2)
            } else { 0 }
        }
        
        return $performanceData
    }
    catch {
        Write-Warning "Failed to measure performance for $($performanceData.ScriptName): $($_.Exception.Message)"
        return $performanceData
    }
}

function Get-PerformanceRating {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$PerformanceData
    )
    
    $rating = 'Good'
    $issues = @()
    
    # Check execution time (thresholds in milliseconds)
    if ($PerformanceData.AverageExecutionTime -gt 30000) {  # > 30 seconds
        $rating = 'Poor'
        $issues += 'Very slow execution time (>30s average)'
    }
    elseif ($PerformanceData.AverageExecutionTime -gt 10000) {  # > 10 seconds
        $rating = 'Fair'
        $issues += 'Slow execution time (>10s average)'
    }
    elseif ($PerformanceData.AverageExecutionTime -gt 5000) {   # > 5 seconds
        if ($rating -eq 'Good') { $rating = 'Fair' }
        $issues += 'Moderate execution time (>5s average)'
    }
    
    # Check memory usage (thresholds in bytes)
    if ($PerformanceData.MemoryPeak -gt 100MB) {
        $rating = 'Poor'
        $issues += 'High memory usage (>100MB peak)'
    }
    elseif ($PerformanceData.MemoryPeak -gt 50MB) {
        if ($rating -ne 'Poor') { $rating = 'Fair' }
        $issues += 'Moderate memory usage (>50MB peak)'
    }
    
    # Check file size (large scripts may be slow)
    if ($PerformanceData.FileSize -gt 100KB) {
        if ($rating -eq 'Good') { $rating = 'Fair' }
        $issues += 'Large script file size (>100KB)'
    }
    
    # Check execution time variance (inconsistent performance)
    if ($PerformanceData.MaxExecutionTime -gt 0 -and $PerformanceData.MinExecutionTime -gt 0) {
        $variance = ($PerformanceData.MaxExecutionTime - $PerformanceData.MinExecutionTime) / $PerformanceData.AverageExecutionTime
        if ($variance -gt 0.5) {  # More than 50% variance
            if ($rating -eq 'Good') { $rating = 'Fair' }
            $issues += 'Inconsistent execution times (high variance)'
        }
    }
    
    $PerformanceData.PerformanceRating = $rating
    $PerformanceData.Bottlenecks = $issues
    
    return $PerformanceData
}

function Find-PerformanceBottlenecks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$PerformanceData
    )
    
    $recommendations = @()
    
    try {
        $content = Get-Content -Path $ScriptPath -Raw
        $scriptName = $PerformanceData.ScriptName
        
        # Check for known performance anti-patterns
        $antiPatterns = @(
            @{ Pattern = 'Get-ChildItem.*-Recurse'; Issue = 'Recursive file operations can be slow'; Suggestion = 'Consider limiting depth or using more specific filters' },
            @{ Pattern = 'foreach.*Get-'; Issue = 'Cmdlet calls in tight loops'; Suggestion = 'Consider batching operations or using pipeline' },
            @{ Pattern = 'Start-Sleep\s+\d+'; Issue = 'Unnecessary delays'; Suggestion = 'Remove or reduce sleep durations' },
            @{ Pattern = 'Invoke-Expression'; Issue = 'Dynamic code execution overhead'; Suggestion = 'Use direct cmdlet calls instead' },
            @{ Pattern = 'Get-WmiObject'; Issue = 'WMI queries can be slow'; Suggestion = 'Consider using Get-CimInstance or caching results' },
            @{ Pattern = '\|\s*Sort-Object.*\|\s*Select-Object'; Issue = 'Inefficient pipeline ordering'; Suggestion = 'Use Select-Object before Sort-Object when possible' },
            @{ Pattern = 'Import-Module.*-Force'; Issue = 'Forced module reloading'; Suggestion = 'Check if module is already loaded first' },
            @{ Pattern = 'Write-Host.*foreach'; Issue = 'Excessive console output in loops'; Suggestion = 'Reduce output frequency or use Write-Progress' }
        )
        
        foreach ($antiPattern in $antiPatterns) {
            if ($content -match $antiPattern.Pattern) {
                $recommendations += @{
                    Type = 'Performance Anti-Pattern'
                    Pattern = $antiPattern.Pattern
                    Issue = $antiPattern.Issue
                    Suggestion = $antiPattern.Suggestion
                    Priority = if ($PerformanceData.PerformanceRating -eq 'Poor') { 'High' } 
                              elseif ($PerformanceData.PerformanceRating -eq 'Fair') { 'Medium' } 
                              else { 'Low' }
                }
            }
        }
        
        # Check for large loops that might benefit from optimization
        $loopPatterns = @('foreach', 'for\s*\(', 'while\s*\(', 'do\s*\{')
        $loopCount = 0
        foreach ($pattern in $loopPatterns) {
            $loopCount += ([regex]::Matches($content, $pattern, 'IgnoreCase')).Count
        }
        
        if ($loopCount -gt 5 -and $PerformanceData.AverageExecutionTime -gt 3000) {
            $recommendations += @{
                Type = 'Loop Optimization'
                Issue = "Script contains $loopCount loops and has slow execution"
                Suggestion = 'Consider optimizing loop logic, using pipeline operations, or parallel processing'
                Priority = 'Medium'
            }
        }
        
        # Check for potential memory leaks
        if ($PerformanceData.MemoryPeak -gt 25MB) {
            if ($content -match '\$global:' -or $content -match 'New-Object.*ArrayList' -or $content -match '\+=.*\@\(') {
                $recommendations += @{
                    Type = 'Memory Management'
                    Issue = 'High memory usage with potential leak patterns'
                    Suggestion = 'Review global variables, ArrayList usage, and array concatenation patterns'
                    Priority = 'High'
                }
            }
        }
        
        # Analyze execution results for additional insights
        if ($PerformanceData.ExecutionResults.Count -gt 0) {
            # Check for high error rates
            if ($PerformanceData.ExecutionMetrics.ErrorRate -gt 20) {
                $recommendations += @{
                    Type = 'Execution Quality'
                    Issue = "High error rate: $($PerformanceData.ExecutionMetrics.ErrorRate)% of runs produced errors/warnings"
                    Suggestion = 'Review script logic and error handling to reduce failure rate'
                    Priority = 'High'
                }
            }
            
            # Check for excessive output
            if ($PerformanceData.ExecutionMetrics.AverageOutputLines -gt 100) {
                $recommendations += @{
                    Type = 'Output Management'
                    Issue = "Excessive output: Average $($PerformanceData.ExecutionMetrics.AverageOutputLines) lines per execution"
                    Suggestion = 'Consider reducing verbose output or using Write-Progress for long operations'
                    Priority = 'Medium'
                }
            }
            
            # Check for inconsistent execution results
            $outputLines = $PerformanceData.ExecutionResults | ForEach-Object { $_.OutputLines }
            if ($outputLines.Count -gt 1) {
                $minOutput = ($outputLines | Measure-Object -Minimum).Minimum
                $maxOutput = ($outputLines | Measure-Object -Maximum).Maximum
                $outputRange = $maxOutput - $minOutput
                
                if ($outputRange -gt ($PerformanceData.ExecutionMetrics.AverageOutputLines * 0.5)) {
                    $recommendations += @{
                        Type = 'Execution Consistency'
                        Issue = 'Inconsistent execution output across runs suggests non-deterministic behavior'
                        Suggestion = 'Review script for conditional logic that may cause variable output'
                        Priority = 'Low'
                    }
                }
            }
        }
        
        $PerformanceData.Recommendations = $recommendations
        
    }
    catch {
        Write-Warning "Failed to analyze bottlenecks for $scriptName : $($_.Exception.Message)"
    }
    
    return $PerformanceData
}

try {
    Write-Host "=== PERFORMANCE ANALYSIS STARTING ===" -ForegroundColor Cyan
    Write-Host "Analyzing scripts in: $ScriptDirectory" -ForegroundColor Yellow
    Write-Host "Sample runs per script: $SampleRuns" -ForegroundColor Yellow
    Write-Host "Timeout per run: $TimeoutSeconds seconds" -ForegroundColor Yellow
    
    # Get all PowerShell scripts
    $scripts = Get-ChildItem -Path $ScriptDirectory -Filter "*.ps1" -Recurse | Where-Object { 
        $_.Name -notlike "*test*" -and $_.Name -notlike "*temp*" 
    }
    Write-Host "Found $($scripts.Count) PowerShell scripts to analyze" -ForegroundColor Green
    
    # Initialize results
    $analysisResults = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ScriptDirectory = $ScriptDirectory
        SampleRuns = $SampleRuns
        TimeoutSeconds = $TimeoutSeconds
        Statistics = @{
            TotalScripts = $scripts.Count
            SuccessfullyAnalyzed = 0
            FailedAnalysis = 0
            AverageExecutionTime = 0
            TotalExecutionTime = 0
            PoorPerformanceScripts = 0
            FairPerformanceScripts = 0
            GoodPerformanceScripts = 0
            HighMemoryScripts = 0
            TotalRecommendations = 0
        }
        PerformanceData = @()
        TopSlowScripts = @()
        TopMemoryScripts = @()
        Recommendations = @()
        Summary = @()
    }
    
    Write-Host "Running performance analysis..." -ForegroundColor Green
    
    # Analyze each script
    foreach ($script in $scripts) {
        Write-Host "  Processing: $($script.Name)" -ForegroundColor Gray
        
        # Skip slow scripts if requested
        if ($SkipSlowScripts -and $script.Length -gt 200KB) {
            Write-Host "    Skipping large script (>200KB)" -ForegroundColor DarkGray
            continue
        }
        
        try {
            # Measure performance
            $performanceData = Measure-ScriptPerformance -ScriptPath $script.FullName -Runs $SampleRuns -TimeoutSeconds $TimeoutSeconds
            
            # Calculate performance rating
            $performanceData = Get-PerformanceRating -PerformanceData $performanceData
            
            # Find bottlenecks and recommendations
            $performanceData = Find-PerformanceBottlenecks -ScriptPath $script.FullName -PerformanceData $performanceData
            
            $analysisResults.PerformanceData += $performanceData
            $analysisResults.Statistics.SuccessfullyAnalyzed++
            
            # Update statistics
            if ($performanceData.AverageExecutionTime -gt 0) {
                $analysisResults.Statistics.TotalExecutionTime += $performanceData.AverageExecutionTime
            }
            
            switch ($performanceData.PerformanceRating) {
                'Poor' { $analysisResults.Statistics.PoorPerformanceScripts++ }
                'Fair' { $analysisResults.Statistics.FairPerformanceScripts++ }
                'Good' { $analysisResults.Statistics.GoodPerformanceScripts++ }
            }
            
            if ($performanceData.MemoryPeak -gt 50MB) {
                $analysisResults.Statistics.HighMemoryScripts++
            }
            
            $analysisResults.Statistics.TotalRecommendations += $performanceData.Recommendations.Count
            
        }
        catch {
            Write-Warning "Failed to analyze $($script.Name): $($_.Exception.Message)"
            $analysisResults.Statistics.FailedAnalysis++
        }
    }
    
    # Calculate summary statistics
    if ($analysisResults.Statistics.SuccessfullyAnalyzed -gt 0) {
        $analysisResults.Statistics.AverageExecutionTime = $analysisResults.Statistics.TotalExecutionTime / $analysisResults.Statistics.SuccessfullyAnalyzed
    }
    
    # Generate summary
    $analysisResults.Summary += "PERFORMANCE ANALYSIS COMPLETE: $($analysisResults.Statistics.SuccessfullyAnalyzed)/$($analysisResults.Statistics.TotalScripts) scripts analyzed"
    
    if ($analysisResults.Statistics.PoorPerformanceScripts -gt 0) {
        $analysisResults.Summary += "CRITICAL: $($analysisResults.Statistics.PoorPerformanceScripts) scripts have poor performance - immediate optimization needed"
    }
    
    $avgTime = [Math]::Round($analysisResults.Statistics.AverageExecutionTime, 2)
    $analysisResults.Summary += "AVERAGE EXECUTION TIME: ${avgTime}ms across all scripts"
    
    # Save results
    $outputPath = if ([System.IO.Path]::IsPathRooted($OutputFile)) { $OutputFile } else { Join-Path $PWD $OutputFile }
    $analysisResults | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8
    
    # Display summary
    Write-Host "`n=== PERFORMANCE ANALYSIS SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Scripts Analyzed: $($analysisResults.Statistics.SuccessfullyAnalyzed)/$($analysisResults.Statistics.TotalScripts)" -ForegroundColor White
    Write-Host "Average Execution Time: ${avgTime}ms" -ForegroundColor White
    Write-Host "Poor Performance: $($analysisResults.Statistics.PoorPerformanceScripts)" -ForegroundColor $(if ($analysisResults.Statistics.PoorPerformanceScripts -gt 0) { "Red" } else { "Green" })
    Write-Host "Fair Performance: $($analysisResults.Statistics.FairPerformanceScripts)" -ForegroundColor $(if ($analysisResults.Statistics.FairPerformanceScripts -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Good Performance: $($analysisResults.Statistics.GoodPerformanceScripts)" -ForegroundColor "Green"
    Write-Host "High Memory Usage: $($analysisResults.Statistics.HighMemoryScripts)" -ForegroundColor $(if ($analysisResults.Statistics.HighMemoryScripts -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Total Recommendations: $($analysisResults.Statistics.TotalRecommendations)" -ForegroundColor $(if ($analysisResults.Statistics.TotalRecommendations -gt 0) { "Cyan" } else { "Green" })
    
    Write-Host "`nAnalysis complete. Results saved to: $outputPath" -ForegroundColor Green
    Write-Host "=== PERFORMANCE ANALYSIS COMPLETE ===" -ForegroundColor Cyan
    
    # Exit with warning code if performance issues found
    exit $(if ($analysisResults.Statistics.PoorPerformanceScripts -gt 0) { 1 } else { 0 })
}
catch {
    Write-Error "Performance analysis failed: $($_.Exception.Message)"
    exit 1
}