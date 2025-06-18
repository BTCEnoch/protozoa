# 04-code-quality-analysis.ps1
# Code Quality Analysis for PowerShell Script Suite
# PSScriptAnalyzer-style checks for common PowerShell coding issues and best practices

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptDirectory,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "code-quality-analysis.json",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Error', 'Warning', 'Information', 'All')]
    [string]$Severity = 'All',
    
    [Parameter(Mandatory = $false)]
    [switch]$FixableIssuesOnly
)

$ErrorActionPreference = "Stop"

# Import required modules
Import-Module "$PSScriptRoot\utils\ast-parser.psm1" -Force

# Define automatic variables that should not be assigned to
$AutomaticVariables = @(
    'matches', 'true', 'false', 'null', 'args', 'input', 'lastexitcode',
    'myinvocation', 'pscmdlet', 'psitem', 'pwd', 'foreach', 'switch',
    'stacktrace', 'error', 'host', 'home', 'pshome', 'profile'
)

function Test-AutomaticVariableAssignment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false)]
        [string]$Content
    )
    
    $issues = @()
    if (-not $Content) {
        $Content = Get-Content -Path $ScriptPath -Raw
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    
    foreach ($autoVar in $AutomaticVariables) {
        # Pattern to find assignments to automatic variables
        $pattern = "\`$$autoVar\s*="
        $regexMatches = [regex]::Matches($Content, $pattern, 'IgnoreCase')
        
        foreach ($match in $regexMatches) {
            $lineNumber = ($Content.Substring(0, $match.Index) -split "`n").Count
            $issues += @{
                RuleName = 'PSAvoidAssignmentToAutomaticVariable'
                Severity = 'Warning'
                ScriptName = $scriptName
                LineNumber = $lineNumber
                Message = "The Variable '$autoVar' is an automatic variable that is built into PowerShell, assigning to it might have undesired side effects."
                Suggestion = "Use a different variable name instead of '$autoVar'"
                Context = $match.Value
                Fixable = $true
            }
        }
    }
    
    return $issues
}

function Test-NullComparison {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false)]
        [string]$Content
    )
    
    $issues = @()
    if (-not $Content) {
        $Content = Get-Content -Path $ScriptPath -Raw
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    
    # Pattern to find incorrect null comparisons (variable -eq $null instead of $null -eq variable)
    $patterns = @(
        '\$\w+\s+-eq\s+\$null',
        '\$\w+\s+-ne\s+\$null',
        '\$\w+\.[\w\.]+\s+-eq\s+\$null',
        '\$\w+\.[\w\.]+\s+-ne\s+\$null'
    )
    
    foreach ($pattern in $patterns) {
        $regexMatches = [regex]::Matches($Content, $pattern, 'IgnoreCase')
        
        foreach ($match in $regexMatches) {
            $lineNumber = ($Content.Substring(0, $match.Index) -split "`n").Count
            $issues += @{
                RuleName = 'PSPossibleIncorrectComparisonWithNull'
                Severity = 'Warning'
                ScriptName = $scriptName
                LineNumber = $lineNumber
                Message = "`$null should be on the left side of equality comparisons."
                Suggestion = "Change '$($match.Value)' to put `$null on the left side"
                Context = $match.Value
                Fixable = $true
            }
        }
    }
    
    return $issues
}

function Test-SwitchParameterDefaults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false)]
        [string]$Content
    )
    
    $issues = @()
    if (-not $Content) {
        $Content = Get-Content -Path $ScriptPath -Raw
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    
    # Pattern to find switch parameters with default values
    $pattern = '\[switch\]\s*\$\w+\s*=\s*(?:\$true|\$false)'
    $regexMatches = [regex]::Matches($Content, $pattern, 'IgnoreCase')
    
    foreach ($match in $regexMatches) {
        $lineNumber = ($Content.Substring(0, $match.Index) -split "`n").Count
        $issues += @{
            RuleName = 'PSAvoidDefaultValueSwitchParameter'
            Severity = 'Warning'
            ScriptName = $scriptName
            LineNumber = $lineNumber
            Message = "Script definition has a switch parameter default to true."
            Suggestion = "Remove the default value and handle the logic within the script body"
            Context = $match.Value
            Fixable = $true
        }
    }
    
    return $issues
}

function Test-UnapprovedVerbs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false)]
        [string]$Content
    )
    
    $issues = @()
    if (-not $Content) {
        $Content = Get-Content -Path $ScriptPath -Raw
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    
    # Get approved verbs
    $approvedVerbs = Get-Verb | Select-Object -ExpandProperty Verb
    
    # Pattern to find function definitions
    $functionPattern = 'function\s+(\w+)-(\w+)'
    $regexMatches = [regex]::Matches($Content, $functionPattern, 'IgnoreCase')
    
    foreach ($match in $regexMatches) {
        $verb = $match.Groups[1].Value
        $noun = $match.Groups[2].Value
        
        if ($approvedVerbs -notcontains $verb) {
            $lineNumber = ($Content.Substring(0, $match.Index) -split "`n").Count
            $issues += @{
                RuleName = 'PSUseApprovedVerbs'
                Severity = 'Warning'
                ScriptName = $scriptName
                LineNumber = $lineNumber
                Message = "The function '$verb-$noun' uses an unapproved verb '$verb'."
                Suggestion = "Use an approved PowerShell verb. Run 'Get-Verb' to see approved verbs."
                Context = $match.Value
                Fixable = $false
            }
        }
    }
    
    return $issues
}

function Test-EmptyCatchBlocks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false)]
        [string]$Content
    )
    
    $issues = @()
    if (-not $Content) {
        $Content = Get-Content -Path $ScriptPath -Raw
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    
    # Pattern to find empty catch blocks
    $pattern = 'catch\s*\{\s*\}'
    $regexMatches = [regex]::Matches($Content, $pattern, 'IgnoreCase')
    
    foreach ($match in $regexMatches) {
        $lineNumber = ($Content.Substring(0, $match.Index) -split "`n").Count
        $issues += @{
            RuleName = 'PSAvoidEmptyCatchBlock'
            Severity = 'Warning'
            ScriptName = $scriptName
            LineNumber = $lineNumber
            Message = "Empty catch block found. This will hide errors."
            Suggestion = "Add proper error handling or logging in the catch block"
            Context = $match.Value
            Fixable = $false
        }
    }
    
    return $issues
}

function Test-UsingShouldProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false)]
        [string]$Content
    )
    
    $issues = @()
    if (-not $Content) {
        $Content = Get-Content -Path $ScriptPath -Raw
    }
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    
    # Check if script uses SupportsShouldProcess but doesn't call ShouldProcess
    if ($Content -match 'SupportsShouldProcess' -and $Content -notmatch '\$PSCmdlet\.ShouldProcess') {
        $issues += @{
            RuleName = 'PSUseShouldProcessForStateChangingFunctions'
            Severity = 'Warning'
            ScriptName = $scriptName
            LineNumber = 1
            Message = "Function declares SupportsShouldProcess but never calls ShouldProcess."
            Suggestion = "Add `$PSCmdlet.ShouldProcess() calls before making changes"
            Context = "SupportsShouldProcess declared without ShouldProcess calls"
            Fixable = $false
        }
    }
    
    return $issues
}

try {
    Write-Host "=== CODE QUALITY ANALYSIS STARTING ===" -ForegroundColor Cyan
    Write-Host "Analyzing scripts in: $ScriptDirectory" -ForegroundColor Yellow
    Write-Host "Severity filter: $Severity" -ForegroundColor Yellow
    
    # Get all PowerShell scripts and modules
    $scripts = Get-ChildItem -Path $ScriptDirectory -Include "*.ps1", "*.psm1" -Recurse
    Write-Host "Found $($scripts.Count) PowerShell scripts to analyze" -ForegroundColor Green
    
    # Initialize results
    $analysisResults = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ScriptDirectory = $ScriptDirectory
        SeverityFilter = $Severity
        Statistics = @{
            TotalScripts = $scripts.Count
            TotalIssues = 0
            ErrorIssues = 0
            WarningIssues = 0
            InformationIssues = 0
            FixableIssues = 0
            SkippedLargeFiles = 0
        }
        Issues = @()
        IssuesByScript = @{}
        IssuesByRule = @{}
        Summary = @()
    }
    
    Write-Host "Running quality checks with progress logging..." -ForegroundColor Green
    Write-Host "Will analyze $($scripts.Count) scripts..." -ForegroundColor Yellow
    
    # Define quality test functions
    $qualityTests = @(
        @{ Name = 'AutomaticVariableAssignment'; Function = 'Test-AutomaticVariableAssignment' },
        @{ Name = 'NullComparison'; Function = 'Test-NullComparison' },
        @{ Name = 'SwitchParameterDefaults'; Function = 'Test-SwitchParameterDefaults' },
        @{ Name = 'UnapprovedVerbs'; Function = 'Test-UnapprovedVerbs' },
        @{ Name = 'EmptyCatchBlocks'; Function = 'Test-EmptyCatchBlocks' },
        @{ Name = 'UsingShouldProcess'; Function = 'Test-UsingShouldProcess' }
    )
    
    # Run quality tests on each script with progress logging
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
            # Check file size and skip if too large to prevent performance issues
            $fileInfo = Get-Item -Path $script.FullName
            if ($fileInfo.Length -gt 1MB) {
                Write-Warning "Skipping large file: $($fileInfo.Name) ($([Math]::Round($fileInfo.Length/1KB))KB)"
                $analysisResults.Statistics.SkippedLargeFiles++
                continue
            }
            
            $scriptIssues = @()
            
            # Read file content once and pass to all tests
            $content = Get-Content -Path $script.FullName -Raw
            if ([string]::IsNullOrEmpty($content)) {
                continue
            }
            
            foreach ($test in $qualityTests) {
                try {
                    $testFunction = Get-Item "function:$($test.Function)"
                    $issues = & $testFunction -ScriptPath $script.FullName -Content $content
                    $scriptIssues += $issues
                }
                catch {
                    Write-Warning "Failed to run $($test.Name) test on $($script.Name): $($_.Exception.Message)"
                }
            }
            
            # Filter by severity if specified
            if ($Severity -ne 'All') {
                $scriptIssues = $scriptIssues | Where-Object { $_.Severity -eq $Severity }
            }
            
            # Filter by fixable issues if specified
            if ($FixableIssuesOnly) {
                $scriptIssues = $scriptIssues | Where-Object { $_.Fixable -eq $true }
            }
            
            # Add to results
            $analysisResults.Issues += $scriptIssues
            $analysisResults.IssuesByScript[$script.BaseName] = $scriptIssues
            
            # Update statistics
            foreach ($issue in $scriptIssues) {
                $analysisResults.Statistics.TotalIssues++
                
                switch ($issue.Severity) {
                    'Error' { $analysisResults.Statistics.ErrorIssues++ }
                    'Warning' { $analysisResults.Statistics.WarningIssues++ }
                    'Information' { $analysisResults.Statistics.InformationIssues++ }
                }
                
                if ($issue.Fixable) {
                    $analysisResults.Statistics.FixableIssues++
                }
                
                # Group by rule
                if (-not $analysisResults.IssuesByRule.ContainsKey($issue.RuleName)) {
                    $analysisResults.IssuesByRule[$issue.RuleName] = @()
                }
                $analysisResults.IssuesByRule[$issue.RuleName] += $issue
            }
        }
        catch {
            Write-Warning "Failed to analyze $($script.Name): $($_.Exception.Message)"
        }
    }
    
    # Generate recommendations based on findings
    if ($analysisResults.Statistics.ErrorIssues -gt 0) {
        $analysisResults.Summary += "CRITICAL: Found $($analysisResults.Statistics.ErrorIssues) error-level code quality issues that must be fixed"
    }
    
    if ($analysisResults.Statistics.WarningIssues -gt 0) {
        $analysisResults.Summary += "WARNING: Found $($analysisResults.Statistics.WarningIssues) warning-level code quality issues that should be addressed"
    }
    
    if ($analysisResults.Statistics.FixableIssues -gt 0) {
        $analysisResults.Summary += "INFO: $($analysisResults.Statistics.FixableIssues) issues can be automatically fixed"
    }
    
    # Top issue types
    $topIssues = $analysisResults.IssuesByRule.GetEnumerator() | 
                 Sort-Object { $_.Value.Count } -Descending | 
                 Select-Object -First 3
    
    if ($topIssues) {
        $analysisResults.Summary += "TOP ISSUES:"
        foreach ($issue in $topIssues) {
            $analysisResults.Summary += "  - $($issue.Key): $($issue.Value.Count) occurrences"
        }
    }
    
    # Save results
    $outputPath = if ([System.IO.Path]::IsPathRooted($OutputFile)) { $OutputFile } else { Join-Path $PWD $OutputFile }
    $analysisResults | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8
    
    # Display summary
    Write-Host "`n=== CODE QUALITY ANALYSIS SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Total Scripts: $($analysisResults.Statistics.TotalScripts)" -ForegroundColor White
    Write-Host "Total Issues: $($analysisResults.Statistics.TotalIssues)" -ForegroundColor $(if ($analysisResults.Statistics.TotalIssues -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Error Issues: $($analysisResults.Statistics.ErrorIssues)" -ForegroundColor $(if ($analysisResults.Statistics.ErrorIssues -gt 0) { "Red" } else { "Green" })
    Write-Host "Warning Issues: $($analysisResults.Statistics.WarningIssues)" -ForegroundColor $(if ($analysisResults.Statistics.WarningIssues -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Information Issues: $($analysisResults.Statistics.InformationIssues)" -ForegroundColor $(if ($analysisResults.Statistics.InformationIssues -gt 0) { "Cyan" } else { "Green" })
    Write-Host "Fixable Issues: $($analysisResults.Statistics.FixableIssues)" -ForegroundColor $(if ($analysisResults.Statistics.FixableIssues -gt 0) { "Cyan" } else { "Green" })
    
    Write-Host "`nAnalysis complete. Results saved to: $outputPath" -ForegroundColor Green
    Write-Host "=== CODE QUALITY ANALYSIS COMPLETE ===" -ForegroundColor Cyan
    
    # Exit with error code if critical issues found
    exit $(if ($analysisResults.Statistics.ErrorIssues -gt 0) { 1 } else { 0 })
}
catch {
    Write-Error "Code quality analysis failed: $($_.Exception.Message)"
    exit 1
} 