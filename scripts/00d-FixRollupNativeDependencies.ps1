# 00c-FixRollupNativeDependencies.ps1
# Fixes Rollup native dependency issues on Windows
# Addresses the common "@rollup/rollup-win32-x64-msvc" missing module error

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Import utilities
try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

Write-StepHeader "Rollup Native Dependencies Fix"
Write-InfoLog "Addressing Windows-specific Rollup native module issues"

# Navigate to project root
Push-Location $ProjectRoot

try {
    # Check if npm is available
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm is not available. Please run 00-NpmEnvironmentSetup.ps1 first."
    }

    # Check current state
    $nodeModulesExists = Test-Path "node_modules"
    if (-not $nodeModulesExists) {
        Write-WarningLog "node_modules directory not found. Run npm install first."
        throw "node_modules directory not found"
    }

    # Check for specific Rollup native dependencies
    $rollupNativePaths = @(
        "node_modules/@rollup/rollup-win32-x64-msvc",
        "node_modules/@rollup/rollup-win32-ia32-msvc",
        "node_modules/@rollup/rollup-win32-arm64-msvc"
    )

    $missingDependencies = @()
    foreach ($path in $rollupNativePaths) {
        if (-not (Test-Path $path)) {
            $packageName = Split-Path $path -Leaf
            $missingDependencies += "@rollup/$packageName"
        }
    }

    if ($missingDependencies.Count -eq 0 -and -not $Force) {
        Write-SuccessLog "All Rollup native dependencies are already installed"
        return
    }

    if ($missingDependencies.Count -gt 0) {
        Write-InfoLog "Missing Rollup native dependencies:"
        foreach ($dep in $missingDependencies) {
            Write-InfoLog "  - $dep"
        }
    }

    # Method 1: Try installing missing native dependencies directly
    if ($missingDependencies.Count -gt 0 -or $Force) {
        Write-InfoLog "Attempting to install missing Rollup native dependencies..."
        
        foreach ($dependency in $missingDependencies) {
            try {
                Write-InfoLog "Installing $dependency..."
                $installArgs = @("install", $dependency, "--save-optional", "--no-fund", "--no-audit")
                $process = Start-Process -FilePath "npm" -ArgumentList $installArgs -NoNewWindow -PassThru -Wait
                
                if ($process.ExitCode -eq 0) {
                    Write-SuccessLog "Successfully installed $dependency"
                } else {
                    $exitCode = $process.ExitCode
                    Write-WarningLog "Failed to install $dependency (exit code: $exitCode)"
                }
            }
            catch {
                $errorMessage = $_.Exception.Message
                Write-WarningLog "Error installing $dependency`: $errorMessage"
            }
        }
    }

    # Method 2: Force reinstall of Rollup itself if issues persist
    Write-InfoLog "Checking if Rollup core package needs reinstalling..."
    try {
        $rollupVersion = npm list rollup --depth=0 2>$null | Select-String "rollup@"
        if ($rollupVersion) {
            Write-InfoLog "Current Rollup version: $($rollupVersion.Line.Trim())"
        }
        
        # Force reinstall Rollup to ensure native dependencies are properly linked
        Write-InfoLog "Force reinstalling Rollup to ensure native dependencies..."
        $rollupReinstallArgs = @("install", "rollup", "--force", "--no-fund", "--no-audit")
        $rollupProcess = Start-Process -FilePath "npm" -ArgumentList $rollupReinstallArgs -NoNewWindow -PassThru -Wait
        
        if ($rollupProcess.ExitCode -eq 0) {
            Write-SuccessLog "Rollup reinstalled successfully"
        } else {
            $rollupExitCode = $rollupProcess.ExitCode
            Write-WarningLog "Rollup reinstall had issues (exit code: $rollupExitCode)"
        }
    }
    catch {
        Write-WarningLog "Could not reinstall Rollup: $($_.Exception.Message)"
    }

    # Method 3: Clear npm cache and rebuild if necessary
    if ($Force) {
        Write-InfoLog "Force mode: Clearing npm cache and rebuilding native modules..."
        
        try {
            # Clear npm cache
            $cacheArgs = @("cache", "clean", "--force")
            $cacheProcess = Start-Process -FilePath "npm" -ArgumentList $cacheArgs -NoNewWindow -PassThru -Wait
            
            if ($cacheProcess.ExitCode -eq 0) {
                Write-SuccessLog "npm cache cleared successfully"
            }
            
            # Rebuild native modules
            $rebuildArgs = @("rebuild")
            $rebuildProcess = Start-Process -FilePath "npm" -ArgumentList $rebuildArgs -NoNewWindow -PassThru -Wait
            
            if ($rebuildProcess.ExitCode -eq 0) {
                Write-SuccessLog "Native modules rebuilt successfully"
            }
        }
        catch {
            Write-WarningLog "Cache clear/rebuild had issues: $($_.Exception.Message)"
        }
    }

    # Final validation
    Write-InfoLog "Performing final validation..."
    $finalMissingDependencies = @()
    foreach ($path in $rollupNativePaths) {
        if (-not (Test-Path $path)) {
            $packageName = Split-Path $path -Leaf
            $finalMissingDependencies += "@rollup/$packageName"
        }
    }

    if ($finalMissingDependencies.Count -eq 0) {
        Write-SuccessLog "All Rollup native dependencies are now properly installed"
        Write-InfoLog "Vite development server should now start without Rollup native module errors"
    } else {
        Write-WarningLog "Some Rollup native dependencies are still missing:"
        foreach ($dep in $finalMissingDependencies) {
            Write-WarningLog "  - $dep"
        }
        Write-InfoLog "This may not prevent development, but could cause startup warnings"
    }

    # Test Vite config loading
    Write-InfoLog "Testing Vite configuration loading..."
    try {
        $viteTestArgs = @("run", "build", "--dry-run")
        $viteTestProcess = Start-Process -FilePath "npm" -ArgumentList $viteTestArgs -NoNewWindow -PassThru -Wait -RedirectStandardError "vite-test-error.log"
        
        if ($viteTestProcess.ExitCode -eq 0) {
            Write-SuccessLog "Vite configuration loads successfully"
        } else {
            Write-WarningLog "Vite configuration test failed, check vite-test-error.log for details"
        }
    }
    catch {
        Write-WarningLog "Could not test Vite configuration: $($_.Exception.Message)"
    }

    Write-StepHeader "Rollup Native Dependencies Fix Summary"
    Write-SuccessLog "Fix process completed"
    Write-InfoLog "If 'npm run dev' still fails with Rollup errors, try:"
    Write-InfoLog "  1. Delete node_modules and package-lock.json"
    Write-InfoLog "  2. Run: npm install"
    Write-InfoLog "  3. Run this script again with -Force"

}
catch {
    Write-ErrorLog "Rollup native dependencies fix failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
} 