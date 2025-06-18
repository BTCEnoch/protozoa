#!/usr/bin/env pwsh
# cleanup-for-automation-suite.ps1
# Transforms the full Protozoa repository into a clean automation suite package
# Keeps only the scripts, documentation, templates, and dependencies needed for automation

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateBackup
)

$ErrorActionPreference = 'Stop'

Write-Host "PROTOZOA AUTOMATION SUITE CLEANUP" -ForegroundColor Cyan
Write-Host "Transforming repository into clean automation infrastructure..." -ForegroundColor White

# Import utilities if available
$utilsPath = Join-Path $ProjectRoot "scripts\utils.psm1"
if (Test-Path $utilsPath) {
    Import-Module $utilsPath -Force
    Write-Host "[SUCCESS] Loaded utils.psm1" -ForegroundColor Green
} else {
    Write-Host "[WARNING] utils.psm1 not found - using basic logging" -ForegroundColor Yellow
    function Write-InfoLog($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
    function Write-SuccessLog($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
    function Write-WarningLog($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
    function Write-ErrorLog($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }
}

# Skip backup due to potential long path issues with node_modules
Write-InfoLog "Skipping backup to avoid long path issues with node_modules"

# ESSENTIAL FILES TO KEEP
$keepPaths = @(
    "scripts",
    "docs", 
    "templates",
    "package.json",
    "environment-dependencies.json",
    "tsconfig.json",
    "Dockerfile",
    ".dockerignore",
    ".gitignore",
    ".gitattributes",
    "README.md",
    "AUTOMATION-SUITE-README.md",
    "LICENSE",
    ".vscode",
    ".github"
)

# DIRECTORIES/FILES TO REMOVE
$removePaths = @(
    "src",
    "tests", 
    "dist",
    "build",
    "node_modules",
    "results",
    "benchmarks",
    "legacy_docs",
    "pwsh",
    "OVERSIZE_FILES_REPORT.md",
    "automation.log",
    ".automation-complete"
)

Write-InfoLog "Analyzing repository structure..."

# Get all items in project root
$allItems = Get-ChildItem -Path $ProjectRoot -Force | Where-Object { $_.Name -ne '.' -and $_.Name -ne '..' }

$itemsToRemove = @()
$itemsToKeep = @()

foreach ($item in $allItems) {
    $itemName = $item.Name
    $shouldKeep = $false
    
    # Check if item should be kept
    foreach ($keepPattern in $keepPaths) {
        if ($itemName -eq $keepPattern) {
            $shouldKeep = $true
            $itemsToKeep += $item
            break
        }
    }
    
    # Check if item should be removed
    if (-not $shouldKeep) {
        foreach ($removePattern in $removePaths) {
            if ($itemName -eq $removePattern) {
                $itemsToRemove += $item
                break
            }
        }
    }
    
    # If not explicitly kept or removed, check if it's a generated/temp file
    if (-not $shouldKeep -and $item -notin $itemsToRemove) {
        if ($itemName -match '\.(log|tmp|temp|cache)$' -or 
            $itemName -match '^temp-' -or 
            $itemName -match '^debug-' -or
            $itemName -match '^test-' -or
            $itemName -match '\.old$' -or
            $itemName -match '\.backup$' -or
            $itemName -match '_backup_') {
            $itemsToRemove += $item
        } else {
            $itemsToKeep += $item
        }
    }
}

# Display summary
Write-Host "`nCLEANUP SUMMARY:" -ForegroundColor Cyan
Write-Host "Items to keep ($($itemsToKeep.Count)):" -ForegroundColor Green
foreach ($item in $itemsToKeep | Sort-Object Name) {
    Write-Host "  [KEEP] $($item.Name)" -ForegroundColor Green
}

Write-Host "`nItems to remove ($($itemsToRemove.Count)):" -ForegroundColor Red
foreach ($item in $itemsToRemove | Sort-Object Name) {
    if ($item.PSIsContainer) {
        $size = "(directory)"
    } else {
        $sizeKB = [math]::Round($item.Length/1024, 2)
        $size = "($sizeKB KB)"
    }
    Write-Host "  [REMOVE] $($item.Name) $size" -ForegroundColor Red
}

# Calculate space savings
$filesToRemove = $itemsToRemove | Where-Object { -not $_.PSIsContainer }
if ($filesToRemove) {
    $totalSizeToRemove = ($filesToRemove | Measure-Object -Property Length -Sum).Sum
    $totalSizeMB = [math]::Round($totalSizeToRemove / 1MB, 2)
    Write-Host "`nEstimated space savings: $totalSizeMB MB" -ForegroundColor Yellow
}

# Perform cleanup
if ($WhatIf) {
    Write-Host "`n[WHATIF] WhatIf mode - no changes made" -ForegroundColor Yellow
    Write-Host "Run without -WhatIf to apply changes" -ForegroundColor Yellow
} else {
    Write-Host "`nRemoving unnecessary files and directories..." -ForegroundColor Yellow
    
    $removedCount = 0
    foreach ($item in $itemsToRemove) {
        try {
            if ($item.PSIsContainer) {
                Remove-Item -Path $item.FullName -Recurse -Force
                Write-InfoLog "Removed directory: $($item.Name)"
            } else {
                Remove-Item -Path $item.FullName -Force
                Write-InfoLog "Removed file: $($item.Name)"
            }
            $removedCount++
        }
        catch {
            Write-WarningLog "Failed to remove $($item.Name): $($_.Exception.Message)"
        }
    }
    
    Write-SuccessLog "Cleanup completed! Removed $removedCount items"
}

# Verify essential automation files are present
Write-Host "`nVERIFYING AUTOMATION INFRASTRUCTURE:" -ForegroundColor Cyan

$criticalFiles = @(
    "scripts\utils.psm1",
    "scripts\runAll.ps1", 
    "scripts\00-InitEnvironment.ps1",
    "package.json",
    "templates"
)

$missingCritical = @()
foreach ($file in $criticalFiles) {
    $fullPath = Join-Path $ProjectRoot $file
    if (Test-Path $fullPath) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $file" -ForegroundColor Red
        $missingCritical += $file
    }
}

# Count scripts
$scriptsPath = Join-Path $ProjectRoot "scripts"
if (Test-Path $scriptsPath) {
    $scriptFiles = Get-ChildItem -Path $scriptsPath -Filter "*.ps1" | Where-Object { $_.Name -match "^\d+" }
    $scriptCount = ($scriptFiles | Measure-Object).Count
    Write-Host "  [INFO] Found $scriptCount numbered automation scripts" -ForegroundColor Cyan
}

# Count templates
$templatesPath = Join-Path $ProjectRoot "templates"
if (Test-Path $templatesPath) {
    $templateFiles = Get-ChildItem -Path $templatesPath -Recurse -Filter "*.template"
    $templateCount = ($templateFiles | Measure-Object).Count
    Write-Host "  [INFO] Found $templateCount template files" -ForegroundColor Cyan
}

if ($missingCritical.Count -eq 0) {
    Write-Host "`n[SUCCESS] Automation suite is ready!" -ForegroundColor Green
    Write-Host "Repository has been cleaned and contains only essential automation infrastructure." -ForegroundColor White
    Write-Host "`nTo build the complete project, run:" -ForegroundColor Cyan
    Write-Host "  powershell scripts\runAll.ps1" -ForegroundColor White
} else {
    Write-Host "`n[WARNING] Missing critical files!" -ForegroundColor Red
    Write-Host "The following files are required for automation:" -ForegroundColor Yellow
    foreach ($file in $missingCritical) {
        Write-Host "  - $file" -ForegroundColor Red
    }
}

Write-Host "`nCleanup process completed!" -ForegroundColor Green 