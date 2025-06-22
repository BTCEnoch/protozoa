# 00a-NpmInstallWithProgress.ps1
# npm-only installation with enhanced monitoring and stall detection
# Provides detailed progress monitoring and troubleshooting for npm installs
# Replaces pnpm-based installation with pure npm approach

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$TimeoutMinutes = 15,

    [Parameter(Mandatory = $false)]
    [switch]$VerboseOutput,

    [Parameter(Mandatory = $false)]
    [switch]$CleanInstall,

    [Parameter(Mandatory = $false)]
    [switch]$ForceReinstall,

    [Parameter(Mandatory = $false)]
    [string]$LogLevel = "Info"
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

# Initialize logging
Initialize-LogFile

Write-StepHeader "npm Install with Enhanced Progress Monitoring"
Write-InfoLog "Pure npm approach - no pnpm dependencies"
Write-InfoLog "Timeout: $TimeoutMinutes minutes"
Write-InfoLog "Clean Install: $CleanInstall"
Write-InfoLog "Force Reinstall: $ForceReinstall"

# Navigate to project root
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot

try {
    # Pre-installation diagnostics
    Write-InfoLog "Running pre-installation diagnostics..."
    
    # Check npm availability
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm is not available. Please run 00-NpmEnvironmentSetup.ps1 first."
    }
    
    $npmVersion = npm --version
    Write-SuccessLog "npm version detected: $npmVersion"
    
    # Check Node.js version
    if (-not (Test-NodeInstalled)) {
        throw "Node.js is not available. Please run 00-NpmEnvironmentSetup.ps1 first."
    }
    
    $nodeVersion = node --version
    Write-SuccessLog "Node.js version detected: $nodeVersion"

    # Check network connectivity
    Write-InfoLog "Testing network connectivity to npm registry..."
    try {
        $registryTest = Invoke-WebRequest -Uri "https://registry.npmjs.org/" -Method HEAD -TimeoutSec 10
        Write-SuccessLog "npm registry accessible (Status: $($registryTest.StatusCode))"
    }
    catch {
        Write-WarningLog "npm registry connectivity issue: $($_.Exception.Message)"
        Write-InfoLog "This may cause installation delays or failures"
    }

    # Check disk space
    $drive = (Get-Location).Drive
    $freeSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$($drive.Name)'").FreeSpace / 1GB
    Write-InfoLog "Available disk space: $([math]::Round($freeSpace, 2)) GB"
    
    if ($freeSpace -lt 2) {
        Write-WarningLog "Low disk space detected. Recommend at least 2GB free for node_modules"
    }

    # Check existing installation state
    $nodeModulesExists = Test-Path "node_modules"
    $packageLockExists = Test-Path "package-lock.json"
    $pnpmLockExists = Test-Path "pnpm-lock.yaml"
    $yarnLockExists = Test-Path "yarn.lock"
    
    Write-InfoLog "Current state:"
    Write-InfoLog "  node_modules: $(if ($nodeModulesExists) { 'exists' } else { 'missing' })"
    Write-InfoLog "  package-lock.json: $(if ($packageLockExists) { 'exists' } else { 'missing' })"
    Write-InfoLog "  pnpm-lock.yaml: $(if ($pnpmLockExists) { 'exists (will be removed)' } else { 'missing' })"
    Write-InfoLog "  yarn.lock: $(if ($yarnLockExists) { 'exists (will be removed)' } else { 'missing' })"

    # Validate package.json
    if (-not (Test-Path "package.json")) {
        throw "package.json not found. Please ensure you're in the correct project directory."
    }
    
    try {
        $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
        Write-SuccessLog "package.json validated: $($packageJson.name) v$($packageJson.version)"
        
        # Count dependencies
        $depCount = 0
        $devDepCount = 0
        if ($packageJson.dependencies) { $depCount = $packageJson.dependencies.PSObject.Properties.Count }
        if ($packageJson.devDependencies) { $devDepCount = $packageJson.devDependencies.PSObject.Properties.Count }
        
        Write-InfoLog "Dependencies to install: $depCount production, $devDepCount development"
    }
    catch {
        throw "Invalid package.json: $($_.Exception.Message)"
    }

    # Clean up legacy package manager files
    if ($pnpmLockExists -or $yarnLockExists) {
        Write-InfoLog "Cleaning up legacy package manager files..."
        
        if ($pnpmLockExists) {
            Remove-Item -Path "pnpm-lock.yaml" -Force
            Write-InfoLog "Removed pnpm-lock.yaml"
        }
        
        if ($yarnLockExists) {
            Remove-Item -Path "yarn.lock" -Force
            Write-InfoLog "Removed yarn.lock"
        }
        
        Write-SuccessLog "Legacy package manager cleanup completed"
    }

    # Clean install if requested
    if ($CleanInstall -or $ForceReinstall) {
        Write-InfoLog "Performing clean installation..."
        
        if ($nodeModulesExists) {
            Write-InfoLog "Removing node_modules directory..."
            Remove-Item -Path "node_modules" -Recurse -Force
        }
        
        if ($packageLockExists) {
            Write-InfoLog "Removing package-lock.json..."
            Remove-Item -Path "package-lock.json" -Force
        }
        
        Write-SuccessLog "Clean installation preparation completed"
    }

    # Prepare installation command (avoiding deprecated flags)
    # Note: Removed --omit=optional to ensure Rollup native dependencies are installed
    $installArgs = @("install", "--no-fund", "--no-audit", "--progress=false", "--timing=false")
    
    if ($VerboseOutput) { 
        $installArgs += "--loglevel=verbose" 
    } else {
        $installArgs += "--loglevel=info"
    }

    Write-InfoLog "Installation command: npm $($installArgs -join ' ')"

    # Create log files
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $installLogPath = "npm_install_$timestamp.log"
    $errorLogPath = "npm_error_$timestamp.log"
    
    Write-InfoLog "Logs will be saved to:"
    Write-InfoLog "  Install log: $installLogPath"
    Write-InfoLog "  Error log: $errorLogPath"

    # Start installation with enhanced monitoring
    Write-InfoLog "Starting npm installation with enhanced monitoring..."
    
    $startTime = Get-Date
    $timeoutSeconds = $TimeoutMinutes * 60
    $progressInterval = 15 # Update every 15 seconds
    $lastProgressTime = $startTime
    $lastLogSize = 0
    $stallDetectionThreshold = 120 # 2 minutes without log growth = stall
    
    # Start the installation process
    $process = Start-Process -FilePath "npm" -ArgumentList $installArgs -NoNewWindow -PassThru -RedirectStandardOutput $installLogPath -RedirectStandardError $errorLogPath
    
    Write-InfoLog "Installation process started (PID: $($process.Id))"
    Write-InfoLog "Monitoring for stalls and progress..."

    # Monitor the installation
    do {
        $elapsed = (Get-Date) - $startTime
        $elapsedSeconds = [math]::Round($elapsed.TotalSeconds)
        
        # Calculate progress percentage (estimated)
        $percentComplete = [math]::Min(($elapsedSeconds / $timeoutSeconds) * 100, 95)
        
        # Update progress display
        if (((Get-Date) - $lastProgressTime).TotalSeconds -ge $progressInterval) {
            $statusMessage = "Running... ($elapsedSeconds/$timeoutSeconds seconds)"
            Write-Progress -Activity "[NPM] Installing Dependencies (npm)" -Status $statusMessage -PercentComplete $percentComplete
            
            # Check for log file growth (stall detection)
            if (Test-Path $installLogPath) {
                $currentLogSize = (Get-Item $installLogPath).Length
                $logGrowth = $currentLogSize - $lastLogSize
                
                $currentLogSizeKB = [math]::Round($currentLogSize/1KB, 1)
                $logGrowthKB = [math]::Round($logGrowth/1KB, 1)
                Write-InfoLog "Progress update: $elapsedSeconds seconds elapsed (Log: $currentLogSizeKB KB, Growth: +$logGrowthKB KB)"
                
                # Show recent log activity
                $recentLines = Get-Content $installLogPath -Tail 2 -ErrorAction SilentlyContinue
                if ($recentLines) {
                    $lastLine = $recentLines[-1]
                    if ($lastLine -and $lastLine.Trim() -ne "") {
                        Write-InfoLog "Recent activity: $lastLine"
                    }
                }
                
                # Stall detection
                if ($logGrowth -eq 0 -and $elapsedSeconds -gt $stallDetectionThreshold) {
                    Write-WarningLog "Potential stall detected - no log growth for $stallDetectionThreshold seconds"
                    Write-InfoLog "Current process status: $(if ($process.HasExited) { 'Exited' } else { 'Running' })"
                    
                    # Show process details
                    try {
                        $processInfo = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
                        if ($processInfo) {
                            Write-InfoLog "Process CPU time: $($processInfo.TotalProcessorTime)"
                            Write-InfoLog "Process memory: $([math]::Round($processInfo.WorkingSet64/1MB, 1)) MB"
                        }
                    }
                    catch {
                        Write-InfoLog "Could not retrieve process information"
                    }
                }
                
                $lastLogSize = $currentLogSize
            }
            
            $lastProgressTime = Get-Date
        }
        
        Start-Sleep -Seconds 5
        
        # Check if process has exited
        if ($process.HasExited) {
            break
        }
        
    } while ($elapsed.TotalSeconds -lt $timeoutSeconds)

    # Handle completion or timeout
    if (-not $process.HasExited) {
        Write-WarningLog "Installation exceeded $TimeoutMinutes minute timeout"
        Write-InfoLog "Attempting graceful termination..."
        
        try {
            $process.Kill()
            $process.WaitForExit(30000) # Wait up to 30 seconds for graceful exit
        }
        catch {
            Write-WarningLog "Could not terminate process gracefully: $($_.Exception.Message)"
        }
        
        throw "npm installation timed out after $TimeoutMinutes minutes"
    }

    # Process completed - check exit code
    $exitCode = $process.ExitCode
    Write-Progress -Activity "[NPM] Installing Dependencies (npm)" -Completed
    
    # Handle null exit code (sometimes happens with npm)
    if ($null -eq $exitCode) {
        $exitCode = 0  # Assume success if no error was thrown
        Write-InfoLog "Exit code was null, assuming success based on process completion"
    }
    
    if ($exitCode -eq 0) {
        Write-SuccessLog "npm installation completed successfully"
        
        # Check for Rollup native dependency issues (Windows-specific fix)
        Write-InfoLog "Checking for Rollup native dependencies..."
        $rollupNativePath = "node_modules/@rollup/rollup-win32-x64-msvc"
        if (-not (Test-Path $rollupNativePath)) {
            Write-WarningLog "Rollup native dependency missing, attempting fix..."
            try {
                $rollupFixArgs = @("install", "@rollup/rollup-win32-x64-msvc", "--no-fund", "--no-audit")
                $rollupFixProcess = Start-Process -FilePath "npm" -ArgumentList $rollupFixArgs -NoNewWindow -PassThru -Wait
                if ($rollupFixProcess.ExitCode -eq 0) {
                    Write-SuccessLog "Rollup native dependency fix applied successfully"
                } else {
                    Write-WarningLog "Rollup native dependency fix failed, but installation may still work"
                }
            }
            catch {
                Write-WarningLog "Could not apply Rollup native dependency fix: $($_.Exception.Message)"
            }
        } else {
            Write-SuccessLog "Rollup native dependencies are properly installed"
        }
        
        # Post-installation validation
        if (Test-Path "node_modules") {
            $nodeModulesSize = (Get-ChildItem "node_modules" -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-InfoLog "node_modules size: $([math]::Round($nodeModulesSize, 1)) MB"
        }
        
        if (Test-Path "package-lock.json") {
            Write-SuccessLog "package-lock.json created successfully"
        }
        
        # Summary
        Write-StepHeader "npm Installation Summary"
        Write-SuccessLog "[OK] Installation completed successfully"
        Write-SuccessLog "[OK] Exit code: $exitCode"
        Write-SuccessLog "[OK] Duration: $([math]::Round($elapsed.TotalMinutes, 1)) minutes"
        Write-SuccessLog "[OK] Pure npm approach - no pnpm dependencies"
        
        Write-InfoLog " "
        Write-InfoLog "Installation logs saved to:"
        Write-InfoLog "  Success log: $installLogPath"
        Write-InfoLog "  Error log: $errorLogPath"
        Write-InfoLog " "
        Write-InfoLog "Ready for development with 'npm run dev'"
        
    } else {
        Write-ErrorLog "npm installation failed with exit code: $exitCode"
        
        # Show error details
        if (Test-Path $errorLogPath) {
            $errorContent = Get-Content $errorLogPath -Raw
            if ($errorContent.Trim() -ne "") {
                Write-ErrorLog "Error details:"
                Write-ErrorLog $errorContent
            }
        }
        
        throw "npm installation failed with exit code $exitCode"
    }
    
}
catch {
    Write-ErrorLog "Installation failed: $($_.Exception.Message)"
    Write-ErrorLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
} 