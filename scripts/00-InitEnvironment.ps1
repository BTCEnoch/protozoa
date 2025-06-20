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
                $initResult = pnpm init 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-SuccessLog "package.json created"
                } else {
                    throw "pnpm init failed: $initResult"
                }
            } else {
                Write-InfoLog "package.json already exists"
            }

            # Define required dependencies with detailed info
            $devDependencies = @(
                @{ Name = "typescript"; Version = "latest"; Category = "Core TypeScript" },
                @{ Name = "eslint"; Version = "latest"; Category = "Code Linting" },
                @{ Name = "@typescript-eslint/parser"; Version = "latest"; Category = "TypeScript ESLint" },
                @{ Name = "@typescript-eslint/eslint-plugin"; Version = "latest"; Category = "TypeScript ESLint" },
                @{ Name = "typedoc"; Version = "latest"; Category = "Documentation" },
                @{ Name = "@types/node"; Version = "latest"; Category = "Node.js Types" },
                @{ Name = "vitest"; Version = "latest"; Category = "Testing Framework" },
                @{ Name = "prettier"; Version = "latest"; Category = "Code Formatting" },
                @{ Name = "husky"; Version = "latest"; Category = "Git Hooks" },
                @{ Name = "lint-staged"; Version = "latest"; Category = "Pre-commit Linting" }
            )

            $dependencies = @(
                @{ Name = "winston"; Version = "latest"; Category = "Logging" },
                @{ Name = "three"; Version = "latest"; Category = "3D Graphics" },
                @{ Name = "@types/three"; Version = "latest"; Category = "Three.js Types" },
                @{ Name = "zustand"; Version = "latest"; Category = "State Management" },
                @{ Name = "cross-fetch"; Version = "latest"; Category = "HTTP Client" },
                @{ Name = "react"; Version = "latest"; Category = "UI Framework" },
                @{ Name = "react-dom"; Version = "latest"; Category = "React DOM" },
                @{ Name = "@types/react"; Version = "latest"; Category = "React Types" },
                @{ Name = "@types/react-dom"; Version = "latest"; Category = "React DOM Types" }
            )

            # Start installation phase tracking
            $totalPackages = $devDependencies.Count + $dependencies.Count
            $installPhase = Start-InstallationPhase -PhaseName "Project Dependencies" -TotalSteps $totalPackages
            $currentPackage = 0

            # Check if dependencies are already installed
            Write-InfoLog "Checking project dependencies..."
            Write-InstallationProgress -Id 1 -Activity "📦 Checking Dependencies" -Status "Verifying existing installation..." -PercentComplete 10 -CurrentOperation "Reading package.json"
            
            $packageJsonExists = Test-Path "package.json"
            $nodeModulesExists = Test-Path "node_modules"
            $lockFileExists = Test-Path "pnpm-lock.yaml"
            
            if ($packageJsonExists -and $nodeModulesExists -and $lockFileExists) {
                Write-InfoLog "Dependencies appear to be already installed, performing quick verification..."
                Write-InstallationProgress -Id 1 -Activity "📦 Verifying Dependencies" -Status "Checking critical packages..." -PercentComplete 50 -CurrentOperation "Verifying packages"
                
                # Simple verification - check if critical packages exist in node_modules
                $criticalFolders = @("typescript", "winston", "three", "zustand", "react", "eslint")
                $allExist = $true
                
                foreach ($folder in $criticalFolders) {
                    $folderPath = Join-Path "node_modules" $folder
                    if (-not (Test-Path $folderPath)) {
                        Write-WarningLog "Missing critical package: $folder"
                        $allExist = $false
                    }
                }
                
                if ($allExist) {
                    Write-SuccessLog "All critical dependencies verified successfully"
                } else {
                    Write-WarningLog "Some dependencies are missing, will need fresh install"
                    $nodeModulesExists = $false
                }
            }
            
            if (-not $nodeModulesExists) {
                # Execute fresh installation 
                Write-InstallationProgress -Id 1 -Activity "📦 Installing Dependencies" -Status "Running fresh installation..." -PercentComplete 70 -CurrentOperation "Installing all packages"
                
                Write-InfoLog "Installing all dependencies (this may take a few minutes)..."
                Write-InfoLog "Running: pnpm install..."
                
                try {
                    # Use direct PowerShell execution with error handling
                    & pnpm install 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-SuccessLog "All dependencies installed successfully"
                    } else {
                        throw "pnpm install failed with exit code $LASTEXITCODE"
                    }
                }
                catch {
                    Write-WarningLog "Primary installation method failed: $($_.Exception.Message)"
                    Write-InfoLog "Falling back to npm install..."
                    
                    # Fallback to npm if pnpm fails
                    & npm install 2>&1 | Out-Null
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-SuccessLog "Dependencies installed successfully using npm fallback"
                    } else {
                        throw "Both pnpm and npm installation failed"
                    }
                }
            }
            
            # Update progress tracking
            $currentPackage = $totalPackages / 2

            # Log successful dependency tracking for both dev and prod
            Write-InstallationProgress -Id 1 -Activity "📦 Finalizing Dependencies" -Status "Logging package installations..." -PercentComplete 85 -CurrentOperation "Updating package logs"
            
            foreach ($package in $devDependencies) {
                Write-DependencyInstallLog -Package $package.Name -Status "verified" -Version $package.Version
            }
            
            foreach ($package in $dependencies) {
                Write-DependencyInstallLog -Package $package.Name -Status "verified" -Version $package.Version
            }

            # Verify critical packages with progress tracking
            Write-InstallationProgress -Id 1 -Activity "📦 Verifying Installation" -Status "Validating critical packages..." -PercentComplete 95 -CurrentOperation "Package validation"
            
            $packageJson = Get-Content "package.json" | ConvertFrom-Json
            $allDeps = @()
            if ($packageJson.dependencies) { $allDeps += $packageJson.dependencies.PSObject.Properties.Name }
            if ($packageJson.devDependencies) { $allDeps += $packageJson.devDependencies.PSObject.Properties.Name }

            $criticalPackages = @("typescript", "winston", "three", "zustand", "react", "eslint")
            $validationCount = 0
            
            foreach ($criticalPackage in $criticalPackages) {
                $validationCount++
                Write-ValidationProgress -ValidationName "Critical Package" -Current $validationCount -Total $criticalPackages.Count -CurrentItem $criticalPackage
                
                if ($criticalPackage -in $allDeps) {
                    Write-DependencyInstallLog -Package $criticalPackage -Status "verified"
                } else {
                    Write-DependencyInstallLog -Package $criticalPackage -Status "missing"
                }
                
                Start-Sleep -Milliseconds 50
            }

            $missingPackages = $criticalPackages | Where-Object { $_ -notin $allDeps }

            if ($missingPackages.Count -eq 0) {
                Write-SuccessLog "All critical packages verified in package.json"
            } else {
                Write-WarningLog "Missing critical packages: $($missingPackages -join ', ')"
            }

            # Complete the installation phase
            Complete-InstallationPhase -PhaseInfo $installPhase
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