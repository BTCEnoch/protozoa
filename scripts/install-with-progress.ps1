# PowerShell Script: install-with-progress.ps1
# =====================================================
# Enhanced dependency installation with detailed progress tracking and logging
# Standalone script with built-in progress utilities

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter(Mandatory = $false)]
    [switch]$Production,
    
    [Parameter(Mandatory = $false)]
    [switch]$CleanInstall
)

# Built-in progress and logging functions
function Write-ColoredLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [ConsoleColor]$Color = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage -ForegroundColor $Color
}

function Write-InfoLog { param([string]$Message) Write-ColoredLog $Message "INFO" "Cyan" }
function Write-SuccessLog { param([string]$Message) Write-ColoredLog $Message "SUCCESS" "Green" }
function Write-WarningLog { param([string]$Message) Write-ColoredLog $Message "WARNING" "Yellow" }
function Write-ErrorLog { param([string]$Message) Write-ColoredLog $Message "ERROR" "Red" }

function Write-StepHeader {
    param([string]$Title)
    
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor "DarkCyan"
    Write-Host "  $Title" -ForegroundColor "Cyan"
    Write-Host "=" * 80 -ForegroundColor "DarkCyan"
    Write-Host ""
}

function Write-InstallProgress {
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete,
        [string]$CurrentOperation = "",
        [int]$Id = 1
    )
    
    Write-Progress -Id $Id -Activity $Activity -Status $Status -PercentComplete $PercentComplete -CurrentOperation $CurrentOperation
}

function Write-PackageLog {
    param(
        [string]$Package,
        [string]$Status,
        [string]$Version = "",
        [string]$Category = ""
    )
    
    $prefix = switch ($Status.ToLower()) {
        "queued" { "[QUEUE]" }
        "downloading" { "[DOWNLOAD]" }
        "installing" { "[INSTALL]" }
        "installed" { "[OK]" }
        "verified" { "[VERIFIED]" }
        "failed" { "[FAILED]" }
        "skipped" { "[SKIP]" }
        default { "[INFO]" }
    }
    
    $message = "$prefix $Package"
    if ($Version) { $message += " v$Version" }
    if ($Category) { $message += " [$Category]" }
    
    $color = switch ($Status.ToLower()) {
        "installed" { "Green" }
        "verified" { "Green" }
        "failed" { "Red" }
        "downloading" { "Yellow" }
        "installing" { "Yellow" }
        default { "White" }
    }
    
    Write-Host $message -ForegroundColor $color
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Enhanced Bitcoin Ordinals Dependency Installation"
    Write-InfoLog "Installing Bitcoin Ordinals Digital Organism Ecosystem dependencies..."

    # Navigate to project root
    Push-Location $ProjectRoot

    # Check if package.json exists
    if (-not (Test-Path "package.json")) {
        throw "package.json not found in project root: $ProjectRoot"
    }

    # Parse package.json to get dependency lists
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    $dependencies = @()
    $devDependencies = @()

    # Extract dependencies
    if ($packageJson.dependencies) {
        $dependencies = $packageJson.dependencies.PSObject.Properties | ForEach-Object {
            @{ Name = $_.Name; Version = $_.Value; Type = "production" }
        }
    }

    if ($packageJson.devDependencies -and -not $Production) {
        $devDependencies = $packageJson.devDependencies.PSObject.Properties | ForEach-Object {
            @{ Name = $_.Name; Version = $_.Value; Type = "development" }
        }
    }

    $allPackages = $dependencies + $devDependencies
    $totalPackages = $allPackages.Count

    Write-InfoLog "Found $($dependencies.Count) production dependencies and $($devDependencies.Count) development dependencies"

    # Clean install if requested
    if ($CleanInstall) {
        Write-InfoLog "Performing clean install - removing node_modules and lock files..."
        
        if (Test-Path "node_modules") {
            Write-InstallProgress -Activity "Clean Installation" -Status "Removing node_modules..." -PercentComplete 5 -CurrentOperation "Cleanup"
            Remove-Item "node_modules" -Recurse -Force
            Write-SuccessLog "Removed node_modules directory"
        }
        
        if (Test-Path "pnpm-lock.yaml") {
            Remove-Item "pnpm-lock.yaml" -Force
            Write-SuccessLog "Removed pnpm-lock.yaml"
        }
    }

    # Display package categories
    Write-InfoLog "Package Overview:"
    $corePackages = @("react", "react-dom", "three")
    $threeJsPackages = @("three", "@types/three", "@react-three/fiber", "@react-three/drei")
    $toolingPackages = @("vite", "typescript", "eslint", "prettier")
    $testingPackages = @("vitest", "@playwright/test", "@vitest/coverage-v8")

    $categories = @{
        "Core UI Framework" = $corePackages
        "3D Graphics Engine" = $threeJsPackages
        "Development Tooling" = $toolingPackages
        "Testing Framework" = $testingPackages
    }

    foreach ($category in $categories.Keys) {
        $packages = $categories[$category]
        $found = ($allPackages | Where-Object { $_.Name -in $packages }).Count
        if ($found -gt 0) {
            Write-InfoLog "  * $category`: $found packages"
        }
    }

    # Show detailed package preparation with progress
    Write-InfoLog "Preparing package installation..."
    $currentPackage = 0

    foreach ($package in $allPackages) {
        $currentPackage++
        $percentComplete = [math]::Round(($currentPackage / $totalPackages) * 30, 2)
        
        $category = "General"
        foreach ($catName in $categories.Keys) {
            if ($package.Name -in $categories[$catName]) {
                $category = $catName
                break
            }
        }
        
        if ($package.Name.StartsWith("@types/")) { $category = "Type Definitions" }
        elseif ($package.Name.StartsWith("eslint")) { $category = "Code Quality" }
        elseif ($package.Name -eq "winston") { $category = "Logging" }
        elseif ($package.Name -eq "zustand") { $category = "State Management" }
        
        Write-InstallProgress -Activity "Analyzing Dependencies" -Status "Analyzing $($package.Name)..." -PercentComplete $percentComplete -CurrentOperation "$category"
        Write-PackageLog -Package $package.Name -Status "queued" -Version $package.Version.TrimStart('^~') -Category $category
        
        Start-Sleep -Milliseconds 100
    }

    # Execute the actual pnpm install with progress tracking
    Write-InfoLog "Executing pnpm install..."
    Write-InstallProgress -Activity "Installing Packages" -Status "Running pnpm install..." -PercentComplete 40 -CurrentOperation "Package Manager"

    # Prepare pnpm command
    $pnpmArgs = @("install")
    if ($Production) {
        $pnpmArgs += "--prod"
        Write-InfoLog "Production-only installation (excluding devDependencies)"
    }

    # Execute pnpm install with output capture
    $pnpmStartTime = Get-Date
    
    Write-InstallProgress -Activity "Installing Packages" -Status "Downloading and installing packages..." -PercentComplete 60 -CurrentOperation "Network Download"

    # Run pnpm install
    $pnpmOutput = & pnpm $pnpmArgs 2>&1
    $pnpmExitCode = $LASTEXITCODE
    
    $pnpmInstallTime = [math]::Round(((Get-Date) - $pnpmStartTime).TotalSeconds, 2)

    # Process results
    if ($pnpmExitCode -eq 0) {
        Write-InstallProgress -Activity "Installation Complete" -Status "Verifying installation..." -PercentComplete 90 -CurrentOperation "Verification"
        
        # Verify installation by checking node_modules
        $installedCount = 0
        
        foreach ($package in $allPackages) {
            $packagePath = Join-Path "node_modules" $package.Name
            if (Test-Path $packagePath) {
                $installedCount++
                Write-PackageLog -Package $package.Name -Status "installed" -Version $package.Version.TrimStart('^~')
            } else {
                Write-PackageLog -Package $package.Name -Status "missing" -Version $package.Version.TrimStart('^~')
            }
        }

        Write-Progress -Id 1 -Completed

        # Display installation summary
        Write-StepHeader "Installation Complete!"
        Write-SuccessLog "Package installation completed successfully!"
        Write-InfoLog "Installation Summary:"
        Write-InfoLog "   Total packages: $totalPackages"
        Write-InfoLog "   Successfully installed: $installedCount"
        Write-InfoLog "   Installation time: $pnpmInstallTime seconds"
        Write-InfoLog "   Production dependencies: $($dependencies.Count)"
        if (-not $Production) {
            Write-InfoLog "   Development dependencies: $($devDependencies.Count)"
        }

        # Check for critical packages
        Write-InfoLog "Verifying critical packages..."
        $criticalPackages = @("react", "three", "winston", "typescript", "vite")
        $missingCritical = @()
        
        foreach ($criticalPackage in $criticalPackages) {
            $packagePath = Join-Path "node_modules" $criticalPackage
            if (Test-Path $packagePath) {
                Write-PackageLog -Package $criticalPackage -Status "verified"
            } else {
                $missingCritical += $criticalPackage
                Write-PackageLog -Package $criticalPackage -Status "missing"
            }
        }

        if ($missingCritical.Count -eq 0) {
            Write-SuccessLog "All critical packages verified successfully!"
        } else {
            Write-WarningLog "Missing critical packages: $($missingCritical -join ', ')"
        }

        # Display next steps
        Write-StepHeader "Next Steps"
        Write-InfoLog "Your Bitcoin Ordinals ecosystem is ready! You can now:"
        Write-InfoLog "   1. 'pnpm dev' - Start the development server"
        Write-InfoLog "   2. 'pnpm build' - Build for production"
        Write-InfoLog "   3. 'pnpm test' - Run the test suite"
        Write-InfoLog "   4. 'pnpm lint' - Check code quality"

    } else {
        # Handle installation failure
        Write-Progress -Id 1 -Completed
        
        Write-ErrorLog "pnpm install failed with exit code $pnpmExitCode"
        Write-ErrorLog "Error output:"
        Write-Host $pnpmOutput -ForegroundColor Red
        
        # Log failed packages
        foreach ($package in $allPackages) {
            Write-PackageLog -Package $package.Name -Status "failed" -Version $package.Version.TrimStart('^~')
        }
        
        throw "Package installation failed. Check the error output above for details."
    }

} catch {
    Write-ErrorLog "Enhanced dependency installation failed: $($_.Exception.Message)"
    
    # Cleanup progress bars
    Write-Progress -Id 1 -Completed
    
    exit 1
} finally {
    Pop-Location
} 