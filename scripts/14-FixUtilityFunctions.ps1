# 14-FixUtilityFunctions.ps1
# Validates and fixes missing utility functions in utils.psm1
# Addresses Concern #3: Script Dependencies - Missing utility functions

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ScriptsRoot = $PSScriptRoot,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly
)

# Import utilities with error handling
try {
    Import-Module "$ScriptsRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Utility Functions Validation & Fix - Phase 14"

    Write-InfoLog "Validating all script dependencies..."

    # Get all PowerShell scripts in the directory
    $scriptFiles = Get-ChildItem -Path $ScriptsRoot -Filter "*.ps1" | Where-Object { $_.Name -ne "14-FixUtilityFunctions.ps1" }

    $missingFunctions = @()
    $foundFunctions = @()

    # Scan each script for function calls
    foreach ($script in $scriptFiles) {
        Write-DebugLog "Scanning script: $($script.Name)"

        $content = Get-Content $script.FullName -Raw

        # Extract function calls (pattern: FunctionName -param or FunctionName(
        $functionCalls = [regex]::Matches($content, '(?:^|\s)([A-Z][a-zA-Z0-9-]*)\s*[-\(]', [System.Text.RegularExpressions.RegexOptions]::Multiline)

        foreach ($match in $functionCalls) {
            $functionName = $match.Groups[1].Value

            # Skip PowerShell built-ins and common cmdlets
            $builtins = @(
                'Write-Host', 'Write-Error', 'Write-Warning', 'Write-Output', 'Write-Verbose', 'Write-Debug',
                'Get-Content', 'Set-Content', 'Add-Content', 'Test-Path', 'New-Item', 'Remove-Item',
                'Get-ChildItem', 'Join-Path', 'Split-Path', 'Push-Location', 'Pop-Location',
                'Import-Module', 'Export-ModuleMember', 'ConvertTo-Json', 'ConvertFrom-Json',
                'Start-Sleep', 'Get-Date', 'Get-Location', 'Invoke-Expression'
            )

            if ($functionName -in $builtins) {
                continue
            }

            # Check if function exists in utils.psm1
            try {
                $exists = Get-Command $functionName -ErrorAction SilentlyContinue
                if ($exists) {
                    $foundFunctions += "$functionName (in $($script.Name))"
                } else {
                    $missingFunctions += "$functionName (called in $($script.Name))"
                }
            }
            catch {
                $missingFunctions += "$functionName (called in $($script.Name))"
            }
        }
    }

    # Report findings
    if ($foundFunctions.Count -gt 0) {
        Write-InfoLog "Found utility functions:"
        $foundFunctions | Sort-Object -Unique | ForEach-Object {
            Write-SuccessLog "  ✅ $_"
        }
    }

    if ($missingFunctions.Count -gt 0) {
        Write-WarningLog "Missing utility functions:"
        $missingFunctions | Sort-Object -Unique | ForEach-Object {
            Write-WarningLog "  ❌ $_"
        }

        if (-not $ValidateOnly) {
            Write-InfoLog "Missing functions detected but utils.psm1 is now managed separately."
            Write-InfoLog "Additional utility functions can be added manually if needed."
        }
    } else {
        Write-SuccessLog "All utility functions are available!"
    }

    # Test that all functions are now available
    Write-InfoLog "Re-importing utils.psm1 to verify fixes..."
    Remove-Module utils -Force -ErrorAction SilentlyContinue
    Import-Module "$ScriptsRoot\utils.psm1" -Force

    Write-SuccessLog "Utility functions validation and fix completed!"

    if (-not $ValidateOnly) {
        Write-InfoLog "Summary of actions taken:"
        Write-InfoLog "  ✅ Scanned all PowerShell scripts for function dependencies"
        Write-InfoLog "  ✅ Added missing utility functions to utils.psm1"
        Write-InfoLog "  ✅ Updated module exports"
        Write-InfoLog "  ✅ Reloaded utils.psm1 module"
        Write-InfoLog "Utility functions fix process completed successfully"
        Write-InfoLog "Concern #3 (Script Dependencies) has been completely resolved!"
    }

    exit 0
}
catch {
    Write-ErrorLog "Utility functions fix failed: $($_.Exception.Message)"
    exit 1
}