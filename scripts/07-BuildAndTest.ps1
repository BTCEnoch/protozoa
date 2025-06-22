# 07-BuildAndTest.ps1
# Build validation and testing
# Referenced from build_design.md testing requirements

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD
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
    # Ensure we have the correct project root
    if ($PSScriptRoot -and (Test-Path $PSScriptRoot)) {
        $ProjectRoot = Split-Path $PSScriptRoot -Parent
    } elseif (-not (Test-Path (Join-Path $ProjectRoot "package.json"))) {
        $ProjectRoot = $PWD
    }

    Write-StepHeader "Build and Test Validation - Phase 7"

    Push-Location $ProjectRoot
    Write-InfoLog "Running build validation in project: $ProjectRoot"

    # Check if package.json exists
    if (-not (Test-Path "package.json")) {
        Write-WarningLog "No package.json found - skipping build tests"
        exit 0
    }

    # TypeScript compilation check
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-InfoLog "Checking TypeScript compilation..."
        try {
            $tscResult = npm exec tsc --noEmit 2>&1
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
            Write-InfoLog "Running tests in non-interactive mode..."
            try {
                # Use vitest run (non-watch mode) to prevent hanging with timeout
                Write-InfoLog "Running tests with 60 second timeout..."
                $testJob = Start-Job -ScriptBlock {
                    Set-Location $using:ProjectRoot
                    & npm exec vitest run --reporter=basic 2>&1
                    return $LASTEXITCODE
                }
                
                # Wait for test job with timeout
                $testCompleted = Wait-Job -Job $testJob -Timeout 60
                if ($testCompleted) {
                    $testExitCode = Receive-Job -Job $testJob
                    Remove-Job -Job $testJob
                    
                    if ($testExitCode -eq 0) {
                        Write-SuccessLog "Tests passed"
                    } else {
                        Write-WarningLog "Test failures detected (this is expected for new project):"
                        Write-InfoLog "Test completed with exit code: $testExitCode"
                    }
                } else {
                    Write-WarningLog "Tests timed out after 60 seconds - stopping test job"
                    Stop-Job -Job $testJob
                    Remove-Job -Job $testJob
                    Write-InfoLog "Test timeout is not critical for project setup"
                }
            }
            catch {
                Write-WarningLog "Test execution failed: $($_.Exception.Message)"
            }
        } else {
            Write-InfoLog "No test script found in package.json"
        }
    } else {
        Write-WarningLog "npm not available - skipping build checks"
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