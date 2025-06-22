# 00-NpmEnvironmentSetup.ps1
# Pure npm environment initialization for Protozoa automation suite
# Installs Node.js LTS and npm, validates environment, no pnpm dependencies
# ARCHITECTURE: npm-only approach aligned with React/Vite/THREE.js stack

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("LTS", "Current", "18", "20", "22")]
    [string]$NodeVersion = "LTS",

    [Parameter(Mandatory = $false)]
    [switch]$SkipNodeInstall,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [string]$LogLevel = "Info"
)

# Import utilities with error handling
try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

# Set global error action preference
$ErrorActionPreference = "Stop"

# Initialize logging
Initialize-LogFile

# Main execution wrapped in error handling
try {
    Write-StepHeader "npm Environment Setup - Phase 0 (Pure npm)"

    # Validate PowerShell environment
    Invoke-ScriptWithErrorHandling -OperationName "PowerShell Environment Validation" -ScriptBlock {
        if (-not (Test-PowerShellVersion -MinimumVersion "5.1")) {
            throw "PowerShell 5.1 or higher is required"
        }

        if (-not (Test-ExecutionPolicy)) {
            Write-WarningLog "Execution policy may cause issues. Consider running as administrator."
        }

        Write-SuccessLog "PowerShell environment validated: $($PSVersionTable.PSVersion)"
    }

    # Check administrator privileges for global installs
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        Write-WarningLog "Not running as administrator. Some global installs may require elevation."
        Write-InfoLog "Consider running PowerShell as Administrator for best results."
    } else {
        Write-SuccessLog "Running with administrator privileges"
    }

    # Node.js Installation
    if (-not $SkipNodeInstall) {
        Invoke-ScriptWithErrorHandling -OperationName "Node.js Installation" -ScriptBlock {
            Write-InfoLog "Checking Node.js installation (target: $NodeVersion)..."

            if (Test-NodeInstalled) {
                $currentVersion = node --version
                Write-SuccessLog "Node.js already installed: $currentVersion"

                # Validate minimum Node.js version for React/Vite
                $nodeVersionNumber = $currentVersion -replace '^v', ''
                $majorVersion = [int]($nodeVersionNumber -split '\.')[0]
                
                if ($majorVersion -lt 18) {
                    Write-WarningLog "Node.js version $currentVersion is below recommended minimum (v18.x)"
                    if ($Force) {
                        Write-InfoLog "Force flag specified, will attempt to update Node.js"
                    } else {
                        Write-InfoLog "Use -Force to update Node.js to a newer version"
                    }
                } else {
                    Write-SuccessLog "Node.js version meets React/Vite requirements (v18+)"
                }

                if (-not $Force) {
                    Write-InfoLog "Use -Force to reinstall Node.js"
                }
            } else {
                Write-InfoLog "Node.js not found, installing via winget..."

                # Check if winget is available
                if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                    throw "winget is not available. Please install Node.js manually from https://nodejs.org/"
                }

                $nodePackage = switch ($NodeVersion) {
                    "LTS" { "OpenJS.NodeJS.LTS" }
                    "Current" { "OpenJS.NodeJS" }
                    "18" { "OpenJS.NodeJS.LTS" }
                    "20" { "OpenJS.NodeJS.LTS" }
                    "22" { "OpenJS.NodeJS" }
                    default { "OpenJS.NodeJS.LTS" }
                }

                Write-InfoLog "Installing $nodePackage via winget..."
                $installResult = winget install $nodePackage --silent --accept-package-agreements --accept-source-agreements 2>&1

                if ($LASTEXITCODE -eq 0) {
                    Write-SuccessLog "Node.js installation completed"

                    # Refresh PATH for current session
                    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

                    # Verify installation
                    Start-Sleep -Seconds 3
                    if (Test-NodeInstalled) {
                        $installedVersion = node --version
                        Write-SuccessLog "Node.js verified: $installedVersion"
                    } else {
                        Write-WarningLog "Node.js installation may require a new PowerShell session to take effect"
                    }
                } else {
                    throw "winget installation failed with exit code $LASTEXITCODE. Output: $installResult"
                }
            }
        }
    } else {
        Write-InfoLog "Skipping Node.js installation (SkipNodeInstall flag specified)"
    }

    # npm Validation and Update
    Invoke-ScriptWithErrorHandling -OperationName "npm Validation and Update" -ScriptBlock {
        Write-InfoLog "Validating npm installation..."

        if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
            throw "npm is not available. This should come with Node.js installation."
        }

        $currentNpmVersion = npm --version
        Write-SuccessLog "npm version: $currentNpmVersion"

        # Check for npm updates
        Write-InfoLog "Checking for npm updates..."
        try {
            $latestNpmVersion = npm view npm version --silent 2>$null
            Write-InfoLog "Latest npm version available: $latestNpmVersion"
            
            if ($currentNpmVersion -ne $latestNpmVersion) {
                Write-InfoLog "npm update available: $currentNpmVersion -> $latestNpmVersion"
                if ($Force) {
                    Write-InfoLog "Updating npm to latest version..."
                    $updateResult = npm install -g npm@latest 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-SuccessLog "npm updated successfully"
                        $newVersion = npm --version
                        Write-SuccessLog "npm version after update: $newVersion"
                    } else {
                        Write-WarningLog "npm update failed: $updateResult"
                    }
                } else {
                    Write-InfoLog "Use -Force to update npm automatically"
                }
            } else {
                Write-SuccessLog "npm is up to date"
            }
        }
        catch {
            Write-WarningLog "Could not check for npm updates: $($_.Exception.Message)"
        }
    }

    # npm Configuration for Protozoa Project
    Invoke-ScriptWithErrorHandling -OperationName "npm Configuration" -ScriptBlock {
        Write-InfoLog "Configuring npm for optimal Protozoa development..."

        # Set npm configuration for better performance and reliability (excluding deprecated options)
        $npmConfigs = @{
            "fund" = "false"
            "audit" = "false"
            "save-exact" = "true"
            "engine-strict" = "true"
            "progress" = "false"
            "timing" = "false"
            "fetch-retries" = "3"
            "fetch-retry-factor" = "2"
            "fetch-retry-mintimeout" = "10000"
            "fetch-retry-maxtimeout" = "60000"
        }

        foreach ($config in $npmConfigs.GetEnumerator()) {
            try {
                $currentValue = npm config get $config.Key 2>$null
                if ($currentValue -ne $config.Value) {
                    Write-InfoLog "Setting npm config: $($config.Key) = $($config.Value)"
                    npm config set $config.Key $config.Value --global
                    if ($LASTEXITCODE -eq 0) {
                        Write-DebugLog "npm config $($config.Key) set successfully"
                    } else {
                        Write-WarningLog "Failed to set npm config: $($config.Key)"
                    }
                } else {
                    Write-DebugLog "npm config $($config.Key) already set to: $($config.Value)"
                }
            }
            catch {
                Write-WarningLog "Error setting npm config $($config.Key): $($_.Exception.Message)"
            }
        }

        Write-SuccessLog "npm configuration completed"
    }

    # Environment Validation
    Invoke-ScriptWithErrorHandling -OperationName "Environment Validation" -ScriptBlock {
        Write-InfoLog "Validating complete npm environment..."

        # Test Node.js
        if (-not (Test-NodeInstalled)) {
            throw "Node.js validation failed"
        }

        # Test npm functionality
        $npmTestResult = npm --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "npm functionality test failed: $npmTestResult"
        }

        # Test npm registry connectivity
        Write-InfoLog "Testing npm registry connectivity..."
        try {
            $registryTest = npm ping --registry=https://registry.npmjs.org/ --silent 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-SuccessLog "npm registry connectivity verified"
            } else {
                Write-WarningLog "npm registry ping failed - this may not affect functionality"
            }
        }
        catch {
            Write-WarningLog "Could not test npm registry connectivity: $($_.Exception.Message)"
        }

        # Verify cache directory
        $cacheDir = npm config get cache
        Write-InfoLog "npm cache directory: $cacheDir"
        if (Test-Path $cacheDir) {
            Write-SuccessLog "npm cache directory accessible"
        } else {
            Write-WarningLog "npm cache directory not found, may be created automatically"
        }

        Write-SuccessLog "Environment validation completed successfully"
    }

    # Summary
    Write-StepHeader "npm Environment Setup Summary"
    Write-SuccessLog "[OK] Node.js installation: $(if (Test-NodeInstalled) { 'OK' } else { 'FAILED' })"
    Write-SuccessLog "[OK] npm functionality: $(if (Get-Command npm -ErrorAction SilentlyContinue) { 'OK' } else { 'FAILED' })"
    Write-SuccessLog "[OK] npm configuration: Applied Protozoa-optimized settings"
    $registryStatus = try { 
        npm ping --silent 2>$null
        if ($LASTEXITCODE -eq 0) { 'OK' } else { 'WARNING' }
    } catch { 'WARNING' }
    Write-SuccessLog "[OK] Registry connectivity: $registryStatus"
    
    Write-InfoLog " "
    Write-InfoLog "Environment ready for Protozoa development with pure npm approach"
    Write-InfoLog "No pnpm dependencies - fully compatible with React/Vite/THREE.js stack"
    Write-InfoLog " "
    Write-InfoLog "Next steps:"
    Write-InfoLog "  1. Run 00a-NpmInstallWithProgress.ps1 for dependency installation"
    Write-InfoLog "  2. Use 'npm run dev' to start development server"
    Write-InfoLog "  3. Use 'npm run build' for production builds"

} catch {
    Write-ErrorLog "Environment setup failed: $($_.Exception.Message)"
    Write-ErrorLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} finally {
    # Cleanup
    Pop-Location -ErrorAction SilentlyContinue
} 