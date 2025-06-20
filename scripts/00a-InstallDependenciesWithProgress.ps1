# PowerShell Script: 00a-InstallDependenciesWithProgress.ps1
# =====================================================
# Enhanced dependency installation with detailed progress tracking and logging
# Wraps pnpm install with comprehensive progress bars and package-by-package status updates

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent),
    
    [Parameter(Mandatory = $false)]
    [switch]$Production,
    
    [Parameter(Mandatory = $false)]
    [switch]$CleanInstall
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
    Write-StepHeader "📦 Enhanced Dependency Installation with Progress Tracking"
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
            Write-InstallationProgress -Id 1 -Activity "🧹 Clean Installation" -Status "Removing node_modules..." -PercentComplete 5 -CurrentOperation "Cleanup"
            Remove-Item "node_modules" -Recurse -Force
            Write-SuccessLog "Removed node_modules directory"
        }
        
        if (Test-Path "pnpm-lock.yaml") {
            Remove-Item "pnpm-lock.yaml" -Force
            Write-SuccessLog "Removed pnpm-lock.yaml"
        }
    }

    # Start installation phase tracking
    $installPhase = Start-InstallationPhase -PhaseName "Bitcoin Ordinals Dependencies" -TotalSteps $totalPackages

    # Display package categories
    Write-InfoLog "Package categories detected:"
    $corePackages = @("react", "react-dom", "three")
    $threeJsPackages = @("three", "@types/three", "@react-three/fiber", "@react-three/drei")
    $toolingPackages = @("vite", "typescript", "eslint", "prettier")
    $testingPackages = @("vitest", "@playwright/test", "@vitest/coverage-v8")

    foreach ($category in @("Core UI Framework", "3D Graphics Engine", "Development Tooling", "Testing Framework")) {
        $packages = switch ($category) {
            "Core UI Framework" { $corePackages }
            "3D Graphics Engine" { $threeJsPackages }
            "Development Tooling" { $toolingPackages }
            "Testing Framework" { $testingPackages }
        }
        $found = ($allPackages | Where-Object { $_.Name -in $packages }).Count
        if ($found -gt 0) {
            Write-InfoLog "  �� $category`: $found packages"
        }
    }

    # Show detailed package list with progress simulation
    Write-InfoLog "📦 Preparing to install packages..."
    $currentPackage = 0

    foreach ($package in $allPackages) {
        $currentPackage++
        $percentComplete = [math]::Round(($currentPackage / $totalPackages) * 30, 2) # Reserve 30% for preparation
        
        $category = switch ($package.Name) {
            { $_ -in $corePackages } { "Core UI" }
            { $_ -in $threeJsPackages } { "3D Graphics" }
            { $_ -in $toolingPackages } { "Development" }
            { $_ -in $testingPackages } { "Testing" }
            { $_.StartsWith("@types/") } { "Type Definitions" }
            { $_.StartsWith("eslint") } { "Code Quality" }
            "winston" { "Logging" }
            "zustand" { "State Management" }
            default { $package.Type }
        }
        
        Write-InstallationProgress -Id 1 -Activity "📦 Analyzing Dependencies" -Status "Analyzing $($package.Name)..." -PercentComplete $percentComplete -CurrentOperation "$category - $($package.Name)"
        Write-DependencyInstallLog -Package $package.Name -Status "queued" -Version $package.Version.TrimStart('^~')
        
        Start-Sleep -Milliseconds 50
    }

    # Execute the actual pnpm install with progress tracking
    Write-InfoLog "🚀 Executing pnpm install..."
    Write-InstallationProgress -Id 1 -Activity "📦 Installing Packages" -Status "Running pnpm install..." -PercentComplete 40 -CurrentOperation "Package Manager Execution"

    # Prepare pnpm command
    $pnpmArgs = @("install")
    if ($Production) {
        $pnpmArgs += "--prod"
        Write-InfoLog "Production-only installation (excluding devDependencies)"
    }

    # Execute pnpm install with output capture
    $pnpmStartTime = Get-Date
    
    Write-InstallationProgress -Id 1 -Activity "📦 Installing Packages" -Status "Downloading and installing packages..." -PercentComplete 50 -CurrentOperation "Network Download"

    # Run pnpm install
    $pnpmProcess = Start-Process -FilePath "pnpm" -ArgumentList $pnpmArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$env:TEMP\pnpm-output.log" -RedirectStandardError "$env:TEMP\pnpm-error.log"
    
    $pnpmInstallTime = [math]::Round(((Get-Date) - $pnpmStartTime).TotalSeconds, 2)

    # Process results
    if ($pnpmProcess.ExitCode -eq 0) {
        Write-InstallationProgress -Id 1 -Activity "📦 Installation Complete" -Status "Verifying installation..." -PercentComplete 90 -CurrentOperation "Post-install Verification"
        
        # Display installation summary
        Write-SuccessLog "✅ Package installation completed successfully!"
        Write-InfoLog "📊 Installation Summary:"
        Write-InfoLog "   📦 Total packages: $totalPackages"
        Write-InfoLog "   ⏱️ Total time: $pnpmInstallTime seconds"
        Write-InfoLog "   🏠 Production dependencies: $($dependencies.Count)"
        if (-not $Production) {
            Write-InfoLog "   🛠️ Development dependencies: $($devDependencies.Count)"
        }

        # Check for critical packages
        $criticalPackages = @("react", "three", "winston", "typescript", "vite")
        $missingCritical = @()
        
        Write-ValidationProgress -ValidationName "Critical Package" -Current 0 -Total $criticalPackages.Count -CurrentItem "Starting validation..."
        
        $validationCount = 0
        foreach ($criticalPackage in $criticalPackages) {
            $validationCount++
            Write-ValidationProgress -ValidationName "Critical Package" -Current $validationCount -Total $criticalPackages.Count -CurrentItem $criticalPackage
            
            $packagePath = Join-Path "node_modules" $criticalPackage
            if (Test-Path $packagePath) {
                Write-DependencyInstallLog -Package $criticalPackage -Status "verified"
            } else {
                $missingCritical += $criticalPackage
                Write-DependencyInstallLog -Package $criticalPackage -Status "missing"
            }
            Start-Sleep -Milliseconds 100
        }

        Complete-Progress -Id 2

        if ($missingCritical.Count -eq 0) {
            Write-SuccessLog "🎯 All critical packages verified successfully!"
        } else {
            Write-WarningLog "⚠️ Missing critical packages: $($missingCritical -join ', ')"
        }

        # Complete the installation phase
        Complete-InstallationPhase -PhaseInfo $installPhase

        # Display next steps
        Write-InfoLog "🚀 Next steps:"
        Write-InfoLog "   1. Run 'pnpm dev' to start the development server"
        Write-InfoLog "   2. Run 'pnpm build' to build for production"
        Write-InfoLog "   3. Run 'pnpm test' to run the test suite"

    } else {
        # Handle installation failure
        Complete-Progress -Id 1
        
        $errorOutput = ""
        if (Test-Path "$env:TEMP\pnpm-error.log") {
            $errorOutput = Get-Content "$env:TEMP\pnpm-error.log" -Raw
        }
        
        Write-ErrorLog "❌ pnpm install failed with exit code $($pnpmProcess.ExitCode)"
        Write-ErrorLog "Error output: $errorOutput"
        
        # Log failed packages
        foreach ($package in $allPackages) {
            Write-DependencyInstallLog -Package $package.Name -Status "failed" -Version $package.Version.TrimStart('^~')
        }
        
        throw "Package installation failed. Check the error output above for details."
    }

} catch {
    Write-ErrorLog "Enhanced dependency installation failed: $($_.Exception.Message)"
    Write-ErrorLog "Stack trace: $($_.ScriptStackTrace)"
    
    # Cleanup progress bars
    Complete-Progress -Id 1
    Complete-Progress -Id 2
    
    exit 1
} finally {
    # Cleanup temp files
    if (Test-Path "$env:TEMP\pnpm-output.log") {
        Remove-Item "$env:TEMP\pnpm-output.log" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:TEMP\pnpm-error.log") {
        Remove-Item "$env:TEMP\pnpm-error.log" -Force -ErrorAction SilentlyContinue
    }
    
    Pop-Location
} 