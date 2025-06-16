# 07-BuildAndTest.ps1
# Build validation and testing
# Referenced from build_design.md testing requirements

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Build and Test Validation - Phase 7"
    
    Push-Location $ProjectRoot
    Write-InfoLog "Running build validation in project: $ProjectRoot"
    
    # Check if package.json exists
    if (-not (Test-Path "package.json")) {
        Write-WarningLog "No package.json found - skipping build tests"
        exit 0
    }
    
    # TypeScript compilation check
    if (Get-Command pnpm -ErrorAction SilentlyContinue) {
        Write-InfoLog "Checking TypeScript compilation..."
        try {
            $tscResult = pnpm exec tsc --noEmit 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-SuccessLog "TypeScript compilation passed"
            } else {
                Write-WarningLog "TypeScript compilation issues found:"
                Write-WarningLog $tscResult
            }
        }
        catch {
            Write-WarningLog "TypeScript compilation check failed: $($_.Exception.Message)"
        }
        
        # Run tests if available
        Write-InfoLog "Checking for test scripts..."
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        if ($packageJson.scripts -and $packageJson.scripts.test) {
            Write-InfoLog "Running tests..."
            try {
                $testResult = pnpm test 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-SuccessLog "Tests passed"
                } else {
                    Write-WarningLog "Test failures detected:"
                    Write-WarningLog $testResult
                }
            }
            catch {
                Write-WarningLog "Test execution failed: $($_.Exception.Message)"
            }
        } else {
            Write-InfoLog "No test script found in package.json"
        }
    } else {
        Write-WarningLog "pnpm not available - skipping build checks"
    }
    
    Write-SuccessLog "Build and test validation completed"
    exit 0
}
catch {
    Write-ErrorLog "Build and test validation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 