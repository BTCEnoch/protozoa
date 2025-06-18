# 02-detect-duplicates.ps1
# Detects duplicate functions and overlapping logic across PowerShell scripts
# Part of the script scrub analysis suite

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptDirectory = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "duplicate-analysis.json"
)

try {
    # Import required utilities
    Import-Module "$PSScriptRoot\utils\ast-parser.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import required utilities: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

function Get-LevenshteinDistance {
    param(
        [string]$String1,
        [string]$String2
    )
    
    if ([string]::IsNullOrEmpty($String1)) { return $String2.Length }
    if ([string]::IsNullOrEmpty($String2)) { return $String1.Length }
    
    $len1 = $String1.Length
    $len2 = $String2.Length
    
    # Create matrix as array of arrays to avoid PowerShell multidimensional array syntax issues
    $matrix = @()
    for ($i = 0; $i -le $len1; $i++) {
        $row = @()
        for ($j = 0; $j -le $len2; $j++) {
            $row += 0
        }
        $matrix += , $row
    }
    
    # Initialize first row and column
    for ($i = 0; $i -le $len1; $i++) { $matrix[$i][0] = $i }
    for ($j = 0; $j -le $len2; $j++) { $matrix[0][$j] = $j }
    
    # Fill the matrix
    for ($i = 1; $i -le $len1; $i++) {
        for ($j = 1; $j -le $len2; $j++) {
            # Use .Substring() to avoid indexing syntax issues
            $char1 = $String1.Substring($i - 1, 1)
            $char2 = $String2.Substring($j - 1, 1)
            
            $cost = if ($char1 -eq $char2) { 0 } else { 1 }
            
            $matrix[$i][$j] = [Math]::Min(
                [Math]::Min($matrix[$i - 1][$j] + 1, $matrix[$i][$j - 1] + 1),
                $matrix[$i - 1][$j - 1] + $cost
            )
        }
    }
    
    return $matrix[$len1][$len2]
}

function Get-SimilarityPercentage {
    param(
        [string]$String1,
        [string]$String2,
        [int]$MinimumThreshold = 70
    )
    
    if ([string]::IsNullOrEmpty($String1) -and [string]::IsNullOrEmpty($String2)) {
        return 100
    }
    
    if ([string]::IsNullOrEmpty($String1) -or [string]::IsNullOrEmpty($String2)) {
        return 0
    }
    
    # Normalize strings (remove extra whitespace, case-insensitive)
    $norm1 = ($String1 -replace '\s+', ' ').Trim().ToLower()
    $norm2 = ($String2 -replace '\s+', ' ').Trim().ToLower()
    
    $distance = Get-LevenshteinDistance -String1 $norm1 -String2 $norm2
    $maxLength = [Math]::Max($norm1.Length, $norm2.Length)
    
    if ($maxLength -eq 0) { return 100 }
    
    $similarity = [Math]::Round((1 - ($distance / $maxLength)) * 100, 2)
    return [Math]::Max(0, $similarity)
}

try {
    Write-Host "=== DUPLICATE FUNCTION ANALYSIS STARTING ===" -ForegroundColor Cyan
    Write-Host "Analyzing scripts in: $ScriptDirectory" -ForegroundColor Yellow
    
    # Get all PowerShell scripts
    $scripts = Get-ChildItem -Path $ScriptDirectory -Filter "*.ps1" -Recurse
    $allFunctions = @()
    
    # Extract functions from all scripts
    Write-Host "Extracting functions from scripts..." -ForegroundColor Green
    foreach ($script in $scripts) {
        try {
            $parsedScript = Get-ScriptAst -ScriptPath $script.FullName
            $functions = Get-FunctionDefinitions -ParsedScript $parsedScript
            
            foreach ($function in $functions) {
                $allFunctions += [PSCustomObject]@{
                    Name = $function.Name
                    Parameters = ($function.Parameters -join ', ')
                    Body = $function.Body
                    BodyLength = $function.Body.Length
                    FilePath = $script.FullName
                    FileName = $script.BaseName
                    StartLine = $function.StartLine
                    EndLine = $function.EndLine
                    IsAdvanced = $function.IsAdvancedFunction
                }
            }
        }
        catch {
            Write-Warning "Failed to analyze functions in $($script.Name): $($_.Exception.Message)"
        }
    }
    
    Write-Host "Found $($allFunctions.Count) functions across $($scripts.Count) scripts" -ForegroundColor Yellow
    
    # Detect exact duplicates by body
    Write-Host "Detecting exact duplicates..." -ForegroundColor Green
    $exactDuplicates = @()
    $bodyGroups = $allFunctions | Group-Object -Property Body
    
    foreach ($group in $bodyGroups) {
        if ($group.Count -gt 1) {
            $exactDuplicates += @{
                FunctionBody = $group.Name.Substring(0, [Math]::Min(100, $group.Name.Length)) + "..."
                Instances = $group.Group | ForEach-Object {
                    @{
                        Name = $_.Name
                        FileName = $_.FileName
                        FilePath = $_.FilePath
                        StartLine = $_.StartLine
                        EndLine = $_.EndLine
                    }
                }
                DuplicateCount = $group.Count
            }
        }
    }
    
    # Detect similar functions by name patterns
    Write-Host "Detecting similar function names..." -ForegroundColor Green
    $similarNames = @()
    $nameGroups = $allFunctions | Group-Object -Property Name
    
    foreach ($group in $nameGroups) {
        if ($group.Count -gt 1) {
            $similarNames += @{
                FunctionName = $group.Name
                Instances = $group.Group | ForEach-Object {
                    @{
                        FileName = $_.FileName
                        FilePath = $_.FilePath
                        StartLine = $_.StartLine
                        Parameters = $_.Parameters
                    }
                }
                InstanceCount = $group.Count
            }
        }
    }
    
    # Detect similar function bodies using Levenshtein distance
    Write-Host "Detecting similar function bodies (>70% similarity)..." -ForegroundColor Green
    $similarFunctions = @()
    
    for ($i = 0; $i -lt $allFunctions.Count; $i++) {
        for ($j = $i + 1; $j -lt $allFunctions.Count; $j++) {
            $func1 = $allFunctions[$i]
            $func2 = $allFunctions[$j]
            
            # Skip if same file to avoid noise
            if ($func1.FileName -eq $func2.FileName) {
                continue
            }
            
            # Only compare functions with substantial bodies (>50 characters)
            if ($func1.BodyLength -lt 50 -or $func2.BodyLength -lt 50) {
                continue
            }
            
            $similarity = Get-SimilarityPercentage -String1 $func1.Body -String2 $func2.Body
            
            if ($similarity -ge 70) {
                $similarFunctions += @{
                    Function1 = @{
                        Name = $func1.Name
                        FileName = $func1.FileName
                        StartLine = $func1.StartLine
                        BodyLength = $func1.BodyLength
                    }
                    Function2 = @{
                        Name = $func2.Name
                        FileName = $func2.FileName
                        StartLine = $func2.StartLine
                        BodyLength = $func2.BodyLength
                    }
                    SimilarityPercentage = $similarity
                }
            }
        }
    }
    
    # Generate analysis results
    $analysisResult = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ScriptDirectory = $ScriptDirectory
        Statistics = @{
            TotalScripts = $scripts.Count
            TotalFunctions = $allFunctions.Count
            ExactDuplicates = $exactDuplicates.Count
            SimilarNames = $similarNames.Count
            SimilarFunctions = $similarFunctions.Count
        }
        ExactDuplicates = $exactDuplicates
        SimilarNames = $similarNames
        SimilarFunctions = $similarFunctions
        Recommendations = @()
    }
    
    # Generate recommendations
    if ($exactDuplicates.Count -gt 0) {
        $analysisResult.Recommendations += "CRITICAL: Found $($exactDuplicates.Count) exact duplicate function bodies - consolidate immediately"
    }
    
    if ($similarFunctions.Count -gt 0) {
        $analysisResult.Recommendations += "WARNING: Found $($similarFunctions.Count) similar function implementations - review for consolidation opportunities"
    }
    
    if ($similarNames.Count -gt 0) {
        $analysisResult.Recommendations += "INFO: Found $($similarNames.Count) functions with identical names across files - verify intentional overrides"
    }
    
    # Resolve output path – honour caller-provided directories / rooted paths
    if ([System.IO.Path]::IsPathRooted($OutputFile) -or (Split-Path $OutputFile -Parent)) {
        $outputPath = (Resolve-Path -Path $OutputFile -ErrorAction SilentlyContinue)?.Path
        if (-not $outputPath) { $outputPath = $OutputFile }
    } else {
        $outputPath = Join-Path $PSScriptRoot $OutputFile
    }
    # Export results
    $analysisResult | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8
    
    # Display summary
    Write-Host "`n=== DUPLICATE ANALYSIS SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Functions: $($allFunctions.Count)" -ForegroundColor White
    Write-Host "Exact Duplicates: $($exactDuplicates.Count)" -ForegroundColor $(if ($exactDuplicates.Count -gt 0) { "Red" } else { "Green" })
    Write-Host "Similar Functions: $($similarFunctions.Count)" -ForegroundColor $(if ($similarFunctions.Count -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Identical Names: $($similarNames.Count)" -ForegroundColor $(if ($similarNames.Count -gt 0) { "Cyan" } else { "Green" })
    
    Write-Host "`nAnalysis complete. Results saved to: $outputPath" -ForegroundColor Green
    Write-Host "=== DUPLICATE ANALYSIS COMPLETE ===" -ForegroundColor Cyan
    
    exit 0
}
catch {
    Write-Error "Duplicate analysis failed: $($_.Exception.Message)"
    exit 1
} 