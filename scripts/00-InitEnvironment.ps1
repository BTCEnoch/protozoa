# 00-InitEnvironment.ps1
# Enhanced environment initialization with PowerShell best practices
# Installs Node.js LTS, pnpm, and all global dev-deps required by .cursorrules

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("LTS", "Current", "18", "20", "22")]
    [string]$NodeVersion = "LTS",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipNodeInstall,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipPnpmInstall,
    
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

# Main execution wrapped in error handling
try {
    Write-StepHeader "Environment Initialization - Phase 0"
    
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
                
                if (-not $Force) {
                    Write-InfoLog "Use -Force to reinstall Node.js"
                } else {
                    Write-InfoLog "Force flag specified, will attempt to update Node.js"
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
    
    # pnpm Installation
    if (-not $SkipPnpmInstall) {
        Invoke-ScriptWithErrorHandling -OperationName "pnpm Installation" -ScriptBlock {
            Write-InfoLog "Checking pnpm installation..."
            
            if (Test-PnpmInstalled) {
                $currentVersion = pnpm --version
                Write-SuccessLog "pnpm already installed: v$currentVersion"
            } else {
                Write-InfoLog "pnpm not found, installing via npm..."
                
                # Verify npm is available (comes with Node.js)
                if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
                    throw "npm is not available. Please ensure Node.js is properly installed."
                }
                
                Write-InfoLog "Installing pnpm globally..."
                $npmResult = npm install -g pnpm 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-SuccessLog "pnpm installation completed"
                    
                    # Verify installation
                    if (Test-PnpmInstalled) {
                        $installedVersion = pnpm --version
                        Write-SuccessLog "pnpm verified: v$installedVersion"
                    } else {
                        Write-WarningLog "pnpm installation may require PATH refresh"
                    }
                } else {
                    throw "npm install failed with exit code $LASTEXITCODE. Output: $npmResult"
                }
            }
        }
    } else {
        Write-InfoLog "Skipping pnpm installation (SkipPnpmInstall flag specified)"
    }
    
    # Project Dependencies Installation
    Invoke-ScriptWithErrorHandling -OperationName "Project Dependencies Setup" -ScriptBlock {
        Write-InfoLog "Setting up project workspace..."
        
        # Navigate to project root (parent of scripts directory)
        $projectRoot = Split-Path $PSScriptRoot -Parent
        Push-Location $projectRoot
        
        try {
            # Initialize package.json if it doesn't exist
            if (-not (Test-Path "package.json")) {
                Write-InfoLog "Initializing package.json..."
                $initResult = pnpm init -y 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-SuccessLog "package.json created"
                } else {
                    throw "pnpm init failed: $initResult"
                }
            } else {
                Write-InfoLog "package.json already exists"
            }
            
            # Define required dependencies
            $devDependencies = @(
                "typescript@latest",
                "eslint@latest",
                "@typescript-eslint/parser@latest",
                "@typescript-eslint/eslint-plugin@latest",
                "typedoc@latest",
                "@types/node@latest"
            )
            
            $dependencies = @(
                "winston@latest",
                "three@latest",
                "@types/three@latest",
                "zustand@latest",
                "cross-fetch@latest"
            )
            
            # Install development dependencies
            Write-InfoLog "Installing development dependencies..."
            $devInstallCmd = "pnpm add -D " + ($devDependencies -join " ")
            Write-DebugLog "Executing: $devInstallCmd"
            
            $devResult = Invoke-Expression $devInstallCmd 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-SuccessLog "Development dependencies installed: $($devDependencies.Count) packages"
            } else {
                throw "Development dependencies installation failed: $devResult"
            }
            
            # Install production dependencies
            Write-InfoLog "Installing production dependencies..."
            $prodInstallCmd = "pnpm add " + ($dependencies -join " ")
            Write-DebugLog "Executing: $prodInstallCmd"
            
            $prodResult = Invoke-Expression $prodInstallCmd 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-SuccessLog "Production dependencies installed: $($dependencies.Count) packages"
            } else {
                throw "Production dependencies installation failed: $prodResult"
            }
            
            # Verify critical packages
            $packageJson = Get-Content "package.json" | ConvertFrom-Json
            $allDeps = @()
            if ($packageJson.dependencies) { $allDeps += $packageJson.dependencies.PSObject.Properties.Name }
            if ($packageJson.devDependencies) { $allDeps += $packageJson.devDependencies.PSObject.Properties.Name }
            
            $criticalPackages = @("typescript", "winston", "three", "zustand")
            $missingPackages = $criticalPackages | Where-Object { $_ -notin $allDeps }
            
            if ($missingPackages.Count -eq 0) {
                Write-SuccessLog "All critical packages verified in package.json"
            } else {
                Write-WarningLog "Missing critical packages: $($missingPackages -join ', ')"
            }
        }
        finally {
            Pop-Location
        }
    }
    
    # Environment Summary
    Write-StepHeader "Environment Setup Summary"
    
    $summary = @{
        NodeJS = if (Test-NodeInstalled) { node --version } else { "Not installed" }
        pnpm = if (Test-PnpmInstalled) { "v$(pnpm --version)" } else { "Not installed" }
        PowerShell = $PSVersionTable.PSVersion.ToString()
        Administrator = $isAdmin
        ExecutionPolicy = Get-ExecutionPolicy
        ProjectRoot = Split-Path $PSScriptRoot -Parent
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    Write-InfoLog "Environment Configuration:"
    foreach ($key in $summary.Keys) {
        Write-InfoLog "  $key : $($summary[$key])"
    }
    
    # Create environment marker file
    $envInfo = $summary | ConvertTo-Json -Depth 2
    $envFile = Join-Path (Split-Path $PSScriptRoot -Parent) ".env-setup-complete"
    Set-Content -Path $envFile -Value $envInfo
    Write-SuccessLog "Environment setup marker created: .env-setup-complete"
    
    Write-SuccessLog "🎉 Environment initialization completed successfully!"
    Write-InfoLog "Ready for Phase 1: Project Structure Scaffolding"
    
    exit 0
}
catch {
    Write-ErrorLog "Environment initialization failed: $($_.Exception.Message)"
    Write-ErrorLog "Stack trace: $($_.ScriptStackTrace)"
    
    # Cleanup on failure
    $envFile = Join-Path (Split-Path $PSScriptRoot -Parent) ".env-setup-failed"
    $errorInfo = @{
        Error = $_.Exception.Message
        StackTrace = $_.ScriptStackTrace
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Parameters = $PSBoundParameters
    } | ConvertTo-Json -Depth 3
    
    Set-Content -Path $envFile -Value $errorInfo
    Write-InfoLog "Error details saved to: .env-setup-failed"
    
    exit 1
} 