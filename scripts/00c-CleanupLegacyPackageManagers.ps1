# 00c-CleanupLegacyPackageManagers.ps1
# Remove pnpm/yarn traces and ensure npm-only approach
# Cleans up legacy package manager files and configurations
# Ensures pure npm environment for Protozoa development

#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$IncludeGlobal,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

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

Write-StepHeader "Legacy Package Manager Cleanup"
Write-InfoLog "Removing pnpm/yarn traces for pure npm approach"
Write-InfoLog "Include global cleanup: $IncludeGlobal"
Write-InfoLog "Force removal: $Force"

# Navigate to project root
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot

$cleanupResults = @{
    LockFilesRemoved = @()
    CacheCleared = @()
    GlobalPackagesRemoved = @()
    ConfigurationsRemoved = @()
    Issues = @()
}

try {
    # Remove legacy lock files
    Write-InfoLog "Checking for legacy lock files..."
    
    $legacyLockFiles = @(
        "pnpm-lock.yaml",
        "yarn.lock",
        ".pnpm-store.json"
    )
    
    foreach ($lockFile in $legacyLockFiles) {
        if (Test-Path $lockFile) {
            Write-InfoLog "Found $lockFile"
            
            if ($PSCmdlet.ShouldProcess($lockFile, "Remove legacy lock file")) {
                try {
                    Remove-Item -Path $lockFile -Force
                    $cleanupResults.LockFilesRemoved += $lockFile
                    Write-SuccessLog "Removed $lockFile"
                }
                catch {
                    $issue = "Failed to remove $lockFile`: $($_.Exception.Message)"
                    $cleanupResults.Issues += $issue
                    Write-ErrorLog $issue
                }
            }
        }
    }
    
    if ($cleanupResults.LockFilesRemoved.Count -eq 0) {
        Write-InfoLog "No legacy lock files found"
    }

    # Remove legacy cache directories
    Write-InfoLog "Checking for legacy cache directories..."
    
    $legacyCacheDirs = @(
        ".pnpm-store",
        "node_modules/.pnpm",
        ".yarn/cache",
        ".yarn/install-state.gz"
    )
    
    foreach ($cacheDir in $legacyCacheDirs) {
        if (Test-Path $cacheDir) {
            Write-InfoLog "Found cache directory: $cacheDir"
            
            if ($PSCmdlet.ShouldProcess($cacheDir, "Remove legacy cache directory")) {
                try {
                    if (Test-Path $cacheDir -PathType Container) {
                        Remove-Item -Path $cacheDir -Recurse -Force
                    } else {
                        Remove-Item -Path $cacheDir -Force
                    }
                    $cleanupResults.CacheCleared += $cacheDir
                    Write-SuccessLog "Removed cache: $cacheDir"
                }
                catch {
                    $issue = "Failed to remove cache $cacheDir`: $($_.Exception.Message)"
                    $cleanupResults.Issues += $issue
                    Write-ErrorLog $issue
                }
            }
        }
    }

    # Check for legacy configuration files
    Write-InfoLog "Checking for legacy configuration files..."
    
    $legacyConfigFiles = @(
        ".pnpmfile.cjs",
        ".pnpmfile.js",
        ".yarnrc",
        ".yarnrc.yml"
    )
    
    foreach ($configFile in $legacyConfigFiles) {
        if (Test-Path $configFile) {
            Write-WarningLog "Found legacy config file: $configFile"
            
            if ($Force -and $PSCmdlet.ShouldProcess($configFile, "Remove legacy config file")) {
                try {
                    Remove-Item -Path $configFile -Force
                    $cleanupResults.ConfigurationsRemoved += $configFile
                    Write-SuccessLog "Removed config: $configFile"
                }
                catch {
                    $issue = "Failed to remove config $configFile`: $($_.Exception.Message)"
                    $cleanupResults.Issues += $issue
                    Write-ErrorLog $issue
                }
            } else {
                Write-InfoLog "Use -Force to remove configuration files"
                Write-InfoLog "Manual review recommended for: $configFile"
            }
        }
    }

    # Global cleanup if requested
    if ($IncludeGlobal) {
        Write-InfoLog "Performing global package manager cleanup..."
        
        # Check for global pnpm installation
        if (Get-Command pnpm -ErrorAction SilentlyContinue) {
            Write-WarningLog "Global pnpm installation detected"
            
            if ($Force -and $PSCmdlet.ShouldProcess("pnpm", "Remove global pnpm")) {
                try {
                    # Try to uninstall pnpm globally via npm
                    $uninstallResult = npm uninstall -g pnpm 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $cleanupResults.GlobalPackagesRemoved += "pnpm"
                        Write-SuccessLog "Removed global pnpm package"
                    } else {
                        Write-WarningLog "Could not remove global pnpm via npm: $uninstallResult"
                        Write-InfoLog "Manual removal may be required"
                    }
                }
                catch {
                    $issue = "Failed to remove global pnpm: $($_.Exception.Message)"
                    $cleanupResults.Issues += $issue
                    Write-ErrorLog $issue
                }
            } else {
                Write-InfoLog "Use -Force -IncludeGlobal to remove global pnpm installation"
            }
        }
        
        # Check for global yarn installation
        if (Get-Command yarn -ErrorAction SilentlyContinue) {
            Write-WarningLog "Global yarn installation detected"
            Write-InfoLog "Note: Yarn removal should be done manually to avoid conflicts"
        }
        
        # Clear global caches
        Write-InfoLog "Clearing global npm cache..."
        try {
            $cacheCleanResult = npm cache clean --force 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-SuccessLog "npm cache cleared"
            } else {
                Write-WarningLog "npm cache clean warning: $cacheCleanResult"
            }
        }
        catch {
            Write-WarningLog "Could not clean npm cache: $($_.Exception.Message)"
        }
    }

    # Update .gitignore to ensure npm-only approach
    Write-InfoLog "Updating .gitignore for npm-only approach..."
    
    $gitignorePath = ".gitignore"
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath
        $npmOnlyEntries = @(
            "# npm-only approach",
            "pnpm-lock.yaml",
            "yarn.lock", 
            ".pnpm-store/",
            ".yarn/",
            "# Keep package-lock.json",
            "!package-lock.json"
        )
        
        $needsUpdate = $false
        foreach ($entry in $npmOnlyEntries) {
            if ($entry -notin $gitignoreContent) {
                $needsUpdate = $true
                break
            }
        }
        
        if ($needsUpdate -and $PSCmdlet.ShouldProcess($gitignorePath, "Update .gitignore")) {
            try {
                Add-Content -Path $gitignorePath -Value "`n# npm-only package manager entries"
                Add-Content -Path $gitignorePath -Value $npmOnlyEntries
                Write-SuccessLog "Updated .gitignore for npm-only approach"
            }
            catch {
                $issue = "Failed to update .gitignore: $($_.Exception.Message)"
                $cleanupResults.Issues += $issue
                Write-ErrorLog $issue
            }
        } else {
            Write-InfoLog ".gitignore already configured for npm-only approach"
        }
    } else {
        Write-WarningLog ".gitignore not found - consider creating one"
    }
    
}
catch {
    $issue = "Cleanup error: $($_.Exception.Message)"
    $cleanupResults.Issues += $issue
    Write-ErrorLog $issue
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
}

# Generate cleanup summary
Write-StepHeader "Legacy Package Manager Cleanup Summary"

$totalItemsRemoved = $cleanupResults.LockFilesRemoved.Count + $cleanupResults.CacheCleared.Count + $cleanupResults.ConfigurationsRemoved.Count + $cleanupResults.GlobalPackagesRemoved.Count

Write-InfoLog "Cleanup results:"
Write-InfoLog "  Lock files removed: $($cleanupResults.LockFilesRemoved.Count)"
Write-InfoLog "  Cache directories cleared: $($cleanupResults.CacheCleared.Count)"  
Write-InfoLog "  Configuration files removed: $($cleanupResults.ConfigurationsRemoved.Count)"
Write-InfoLog "  Global packages removed: $($cleanupResults.GlobalPackagesRemoved.Count)"
Write-InfoLog "  Total items cleaned: $totalItemsRemoved"
Write-InfoLog "  Issues encountered: $($cleanupResults.Issues.Count)"

if ($cleanupResults.Issues.Count -gt 0) {
    Write-ErrorLog " "
    Write-ErrorLog "Issues during cleanup:"
    foreach ($issue in $cleanupResults.Issues) {
        Write-ErrorLog "  - $issue"
    }
}

if ($totalItemsRemoved -gt 0) {
    Write-SuccessLog " "
    Write-SuccessLog "[SUCCESS] Cleanup completed successfully!"
    Write-InfoLog "Removed $totalItemsRemoved legacy package manager items"
    Write-InfoLog "Environment is now configured for pure npm approach"
} else {
    Write-InfoLog " "
    Write-InfoLog "[OK] Environment was already clean"
    Write-InfoLog "No legacy package manager files found"
}

Write-InfoLog " "
Write-InfoLog "Environment ready for pure npm development"
Write-InfoLog "Next steps:"
Write-InfoLog "  1. Run 00a-NpmInstallWithProgress.ps1 for dependency installation"
Write-InfoLog "  2. Use 'npm run dev' to start development server"

# Return results for programmatic use
return $cleanupResults 