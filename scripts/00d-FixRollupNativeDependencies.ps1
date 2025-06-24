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
                
                # Use timeout to prevent hanging
                $timeoutSeconds = 120  # 2 minutes max per dependency
                $process = Start-Process -FilePath "npm" -ArgumentList $installArgs -NoNewWindow -PassThru
                
                # Wait with timeout
                $finished = $process.WaitForExit($timeoutSeconds * 1000)
                
                if ($finished) {
                    if ($process.ExitCode -eq 0) {
                        Write-SuccessLog "Successfully installed $dependency"
                    } else {
                        $exitCode = $process.ExitCode
                        Write-WarningLog "Failed to install $dependency (exit code: $exitCode)"
                    }
                } else {
                    # Process didn't finish within timeout
                    Write-WarningLog "Installation of $dependency timed out after $timeoutSeconds seconds"
                    try {
                        $process.Kill()
                        Write-InfoLog "Terminated hanging npm process for $dependency"
                    }
                    catch {
                        Write-WarningLog "Could not terminate npm process: $($_.Exception.Message)"
                    }
                }
                
                # Cleanup process object
                $process.Dispose()
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
        
        # Use timeout to prevent hanging
        $timeoutSeconds = 180  # 3 minutes for Rollup reinstall
        $rollupProcess = Start-Process -FilePath "npm" -ArgumentList $rollupReinstallArgs -NoNewWindow -PassThru
        
        # Wait with timeout
        $rollupFinished = $rollupProcess.WaitForExit($timeoutSeconds * 1000)
        
        if ($rollupFinished) {
            if ($rollupProcess.ExitCode -eq 0) {
                Write-SuccessLog "Rollup reinstalled successfully"
            } else {
                $rollupExitCode = $rollupProcess.ExitCode
                Write-WarningLog "Rollup reinstall had issues (exit code: $rollupExitCode)"
            }
        } else {
            # Process didn't finish within timeout
            Write-WarningLog "Rollup reinstall timed out after $timeoutSeconds seconds"
            try {
                $rollupProcess.Kill()
                Write-InfoLog "Terminated hanging Rollup reinstall process"
            }
            catch {
                Write-WarningLog "Could not terminate Rollup reinstall process: $($_.Exception.Message)"
            }
        }
        
        # Cleanup process object
        $rollupProcess.Dispose()
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
            $timeoutSeconds = 60  # 1 minute for cache operations
            $cacheProcess = Start-Process -FilePath "npm" -ArgumentList $cacheArgs -NoNewWindow -PassThru
            
            $cacheFinished = $cacheProcess.WaitForExit($timeoutSeconds * 1000)
            if ($cacheFinished -and $cacheProcess.ExitCode -eq 0) {
                Write-SuccessLog "npm cache cleared successfully"
            } elseif (-not $cacheFinished) {
                Write-WarningLog "Cache clear timed out after $timeoutSeconds seconds"
                try { $cacheProcess.Kill() } catch { }
            }
            $cacheProcess.Dispose()
            
            # Rebuild native modules
            $rebuildArgs = @("rebuild")
            $rebuildTimeoutSeconds = 300  # 5 minutes for rebuild
            $rebuildProcess = Start-Process -FilePath "npm" -ArgumentList $rebuildArgs -NoNewWindow -PassThru
            
            $rebuildFinished = $rebuildProcess.WaitForExit($rebuildTimeoutSeconds * 1000)
            if ($rebuildFinished -and $rebuildProcess.ExitCode -eq 0) {
                Write-SuccessLog "Native modules rebuilt successfully"
            } elseif (-not $rebuildFinished) {
                Write-WarningLog "Rebuild timed out after $rebuildTimeoutSeconds seconds"
                try { $rebuildProcess.Kill() } catch { }
            }
            $rebuildProcess.Dispose()
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
        $viteTimeoutSeconds = 90  # 1.5 minutes for Vite test
        $viteTestProcess = Start-Process -FilePath "npm" -ArgumentList $viteTestArgs -NoNewWindow -PassThru -RedirectStandardError "vite-test-error.log"
        
        $viteFinished = $viteTestProcess.WaitForExit($viteTimeoutSeconds * 1000)
        if ($viteFinished) {
            if ($viteTestProcess.ExitCode -eq 0) {
                Write-SuccessLog "Vite configuration loads successfully"
            } else {
                Write-WarningLog "Vite configuration test failed, check vite-test-error.log for details"
            }
        } else {
            Write-WarningLog "Vite configuration test timed out after $viteTimeoutSeconds seconds"
            try { $viteTestProcess.Kill() } catch { }
        }
        $viteTestProcess.Dispose()
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