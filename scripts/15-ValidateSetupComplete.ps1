# 15-ValidateSetupComplete.ps1
# Comprehensive validation that Concerns #3 and #4 are completely resolved
# Tests script dependencies and TypeScript configuration

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$Detailed
)

# Import utilities with error handling
try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Setup Validation - Concerns #3 & #4 Resolution"

    Push-Location $ProjectRoot
    Write-InfoLog "Validating setup in project root: $ProjectRoot"

    $allTestsPassed = $true
    $testResults = @()

    # Test 1: Validate Concern #3 - Script Dependencies
    Write-InfoLog "🔍 Testing Concern #3: Script Dependencies Resolution"

    $concern3Tests = @(
        @{
            Name = "utils.psm1 module import"
            Test = {
                try {
                    Remove-Module utils -Force -ErrorAction SilentlyContinue
                    Import-Module "$PSScriptRoot\utils.psm1" -Force
                    return $true
                } catch { return $false }
            }
        },
        @{
            Name = "Test-DirectoryStructure function availability"
            Test = { (Get-Command Test-DirectoryStructure -ErrorAction SilentlyContinue) -ne $null }
        },
        @{
            Name = "Test-ProjectStructure function availability"
            Test = { (Get-Command Test-ProjectStructure -ErrorAction SilentlyContinue) -ne $null }
        },
        @{
            Name = "Get-DomainList function availability"
            Test = { (Get-Command Get-DomainList -ErrorAction SilentlyContinue) -ne $null }
        },
        @{
            Name = "Invoke-ScriptWithErrorHandling function availability"
            Test = { (Get-Command Invoke-ScriptWithErrorHandling -ErrorAction SilentlyContinue) -ne $null }
        },
        @{
            Name = "All logging functions available"
            Test = {
                $logFunctions = @('Write-InfoLog', 'Write-SuccessLog', 'Write-WarningLog', 'Write-ErrorLog', 'Write-DebugLog')
                foreach ($func in $logFunctions) {
                    if (-not (Get-Command $func -ErrorAction SilentlyContinue)) { return $false }
                }
                return $true
            }
        }
    )

    $testCount = 0
    foreach ($test in $concern3Tests) {
        $testCount++
        Write-ValidationProgress -ValidationName "Script Dependencies" -Current $testCount -Total $concern3Tests.Count -CurrentItem $test.Name
        
        try {
            $result = & $test.Test
            if ($result) {
                Write-SuccessLog "  ✅ $($test.Name)"
                $testResults += @{ Test = $test.Name; Status = "PASS"; Category = "Concern #3" }
            } else {
                Write-ErrorLog "  ❌ $($test.Name)"
                $testResults += @{ Test = $test.Name; Status = "FAIL"; Category = "Concern #3" }
                $allTestsPassed = $false
            }
        }
        catch {
            Write-ErrorLog "  ❌ $($test.Name) - Exception: $($_.Exception.Message)"
            $testResults += @{ Test = $test.Name; Status = "ERROR"; Category = "Concern #3" }
            $allTestsPassed = $false
        }
        
        Start-Sleep -Milliseconds 200  # Brief pause for progress visibility
    }

    Complete-Progress -Id 2  # Complete the validation progress bar

    # Test 2: Validate Concern #4 - TypeScript Configuration
    Write-InfoLog "Beginning TypeScript configuration validation"
    Write-InfoLog "🔍 Testing Concern #4: TypeScript Configuration"

    $concern4Tests = @(
        @{
            Name = "package.json exists and is valid"
            Test = {
                if (-not (Test-Path "package.json")) { return $false }
                try {
                    $pkg = Get-Content "package.json" | ConvertFrom-Json
                    return ($pkg.name -eq "protozoa" -and $pkg.dependencies -and $pkg.devDependencies)
                } catch { return $false }
            }
        },
        @{
            Name = "tsconfig.json exists with path aliases"
            Test = {
                if (-not (Test-Path "tsconfig.json")) { return $false }
                try {
                    $tsconfig = Get-Content "tsconfig.json" | ConvertFrom-Json
                    $paths = $tsconfig.compilerOptions.paths
                    return ($paths.'@/*' -and $paths.'@/domains/*' -and $paths.'@/shared/*')
                } catch { return $false }
            }
        },
        @{
            Name = ".eslintrc.json exists with domain rules"
            Test = {
                if (-not (Test-Path ".eslintrc.json")) { return $false }
                try {
                    $eslint = Get-Content ".eslintrc.json" | ConvertFrom-Json
                    return ($eslint.rules -and $eslint.parser -and $eslint.extends)
                } catch { return $false }
            }
        },
        @{
            Name = ".gitignore exists"
            Test = { Test-Path ".gitignore" }
        },
        @{
            Name = "Required dependencies are specified"
            Test = {
                if (-not (Test-Path "package.json")) { return $false }
                try {
                    $pkg = Get-Content "package.json" | ConvertFrom-Json
                    $required = @('winston', 'three', 'zustand', 'cross-fetch')
                    foreach ($dep in $required) {
                        if (-not $pkg.dependencies.$dep) { return $false }
                    }
                    return $true
                } catch { return $false }
            }
        },
        @{
            Name = "Development dependencies are specified"
            Test = {
                if (-not (Test-Path "package.json")) { return $false }
                try {
                    $pkg = Get-Content "package.json" | ConvertFrom-Json
                    $required = @('typescript', 'eslint', '@typescript-eslint/parser')
                    foreach ($dep in $required) {
                        if (-not $pkg.devDependencies.$dep) { return $false }
                    }
                    return $true
                } catch { return $false }
            }
        },
        @{
            Name = "Node modules installation check"
            Test = {
                return (Test-Path "node_modules" -PathType Container)
            }
        },
        @{
            Name = "Critical package installation validation"
            Test = {
                $criticalPackages = @('typescript', 'winston', 'three', 'react', 'zustand')
                foreach ($package in $criticalPackages) {
                    $packagePath = Join-Path "node_modules" $package
                    if (-not (Test-Path $packagePath)) { return $false }
                }
                return $true
            }
        }
    )

    $testCount = 0
    foreach ($test in $concern4Tests) {
        $testCount++
        Write-ValidationProgress -ValidationName "TypeScript Configuration" -Current $testCount -Total $concern4Tests.Count -CurrentItem $test.Name
        
        try {
            $result = & $test.Test
            if ($result) {
                Write-SuccessLog "  ✅ $($test.Name)"
                $testResults += @{ Test = $test.Name; Status = "PASS"; Category = "Concern #4" }
            } else {
                Write-ErrorLog "  ❌ $($test.Name)"
                $testResults += @{ Test = $test.Name; Status = "FAIL"; Category = "Concern #4" }
                $allTestsPassed = $false
            }
        }
        catch {
            Write-ErrorLog "  ❌ $($test.Name) - Exception: $($_.Exception.Message)"
            $testResults += @{ Test = $test.Name; Status = "ERROR"; Category = "Concern #4" }
            $allTestsPassed = $false
        }
        
        Start-Sleep -Milliseconds 200  # Brief pause for progress visibility
    }

    Complete-Progress -Id 2  # Complete the validation progress bar

    # Summary Report
    Write-InfoLog "Generating validation summary report"
    Write-StepHeader "VALIDATION SUMMARY"

    $concern3Results = $testResults | Where-Object { $_.Category -eq "Concern #3" }
    $concern4Results = $testResults | Where-Object { $_.Category -eq "Concern #4" }

    $concern3Passed = ($concern3Results | Where-Object { $_.Status -eq "PASS" }).Count
    $concern3Total = $concern3Results.Count
    $concern4Passed = ($concern4Results | Where-Object { $_.Status -eq "PASS" }).Count
    $concern4Total = $concern4Results.Count

    Write-InfoLog "Concern #3 (Script Dependencies): $concern3Passed/$concern3Total tests passed"
    Write-InfoLog "Concern #4 (TypeScript Configuration): $concern4Passed/$concern4Total tests passed"

    if ($allTestsPassed) {
        Write-SuccessLog "ALL VALIDATION TESTS PASSED!"
        Write-SuccessLog "🎉 Complete validation success achieved!"
        Write-SuccessLog "Validation results summary:"
        Write-SuccessLog "✅ Concern #3: Script Dependencies - COMPLETELY RESOLVED"
        Write-SuccessLog "✅ Concern #4: TypeScript Configuration - COMPLETELY RESOLVED"
        Write-SuccessLog "Project setup validation completed successfully"
        Write-InfoLog "Your new-protozoa project setup is now complete and ready for development!"
        Write-InfoLog "Development environment is ready for next phase"
        Write-InfoLog "Next steps:"
        Write-InfoLog "  1. Run 'npm install' to install dependencies"
        Write-InfoLog "  2. Begin domain implementation with Cursor AI"
        Write-InfoLog "  3. Use the generated service stubs as starting points"

        exit 0
    } else {
        Write-ErrorLog "Error condition occurred"
        Write-ErrorLog "❌ VALIDATION FAILED"
        Write-ErrorLog "Some tests did not pass. Please review the errors above."

        if ($Detailed) {
            Write-InfoLog "Processing step completed"
            Write-InfoLog "Detailed test results:"
            $testResults | ForEach-Object {
                $status = switch ($_.Status) {
                    "PASS" { "✅" }
                    "FAIL" { "❌" }
                    "ERROR" { "⚠️" }
                }
                Write-InfoLog "  $status [$($_.Category)] $($_.Test)"
            }
        }

        exit 1
    }
}
catch {
    Write-ErrorLog "Validation failed with exception: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}
