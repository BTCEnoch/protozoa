# 60-SetupBrowserServerRequirements.ps1
# Template-driven browser/server requirements setup
# ZERO inline code generation - Templates ONLY

<#
.SYNOPSIS
    Sets up browser and server requirements using templates only (NO inline generation)
.DESCRIPTION
    Creates browser/server files from comprehensive templates:
    - vite.config.ts from template
    - index.html from template  
    - App.tsx from template
    - main.tsx from template
    - compositionRoot.ts from template
    Follows template-first architecture with zero tolerance for inline generation
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER DryRun
    Preview changes without writing files
.EXAMPLE
    .\60-SetupBrowserServerRequirements.ps1 -ProjectRoot "C:\Projects\Protozoa"
.NOTES
    Template-first architecture enforcement - NO inline generation allowed
#>
param(
    [string]$ProjectRoot = $PWD,
    [switch]$DryRun
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "Template-Only Browser/Server Requirements Setup"
    Write-InfoLog "Setting up browser requirements using templates only..."
    
    # Setup paths
    $srcPath = Join-Path $ProjectRoot "src"
    $componentsPath = Join-Path $srcPath "components"
    $publicPath = Join-Path $ProjectRoot "public"
    
    # Ensure directories exist
    foreach ($dir in @($srcPath, $componentsPath, $publicPath)) {
        if (-not (Test-Path $dir)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            Write-InfoLog "Created directory: $dir"
        }
    }

    # Generate vite.config.ts from template
    Write-InfoLog "Generating vite.config.ts from template"
    $viteConfigTemplate = Join-Path $ProjectRoot "templates/vite.config.ts.template"
    $viteConfigPath = Join-Path $ProjectRoot "vite.config.ts"
    
    if (Test-Path $viteConfigTemplate) {
        if (-not $DryRun) {
            Copy-Item $viteConfigTemplate $viteConfigPath -Force
        }
        Write-SuccessLog "vite.config.ts generated from template successfully"
    } else {
        Write-ErrorLog "vite.config.ts template not found: $viteConfigTemplate"
        throw "Template file missing: vite.config.ts.template"
    }

    # Generate index.html from template
    Write-InfoLog "Generating index.html from template"
    $indexHtmlTemplate = Join-Path $ProjectRoot "templates/index.html.template"
    $indexHtmlPath = Join-Path $ProjectRoot "index.html"
    
    if (Test-Path $indexHtmlTemplate) {
        if (-not $DryRun) {
            Copy-Item $indexHtmlTemplate $indexHtmlPath -Force
        }
        Write-SuccessLog "index.html generated from template successfully"
    } else {
        Write-ErrorLog "index.html template not found: $indexHtmlTemplate"
        throw "Template file missing: index.html.template"
    }

    # Generate App.tsx from template
    Write-InfoLog "Generating App.tsx from template"
    $appComponentTemplate = Join-Path $ProjectRoot "templates/components/App.tsx.template"
    $appComponentPath = Join-Path $componentsPath "App.tsx"
    
    if (Test-Path $appComponentTemplate) {
        if (-not $DryRun) {
            Copy-Item $appComponentTemplate $appComponentPath -Force
        }
        Write-SuccessLog "App.tsx generated from template successfully"
    } else {
        Write-ErrorLog "App.tsx template not found: $appComponentTemplate"
        throw "Template file missing: App.tsx.template"
    }

    # Generate main.tsx from template
    Write-InfoLog "Generating main.tsx from template"
    $mainTemplate = Join-Path $ProjectRoot "templates/src/main.tsx.template"
    $mainPath = Join-Path $srcPath "main.tsx"
    
    if (Test-Path $mainTemplate) {
        if (-not $DryRun) {
            Copy-Item $mainTemplate $mainPath -Force
        }
        Write-SuccessLog "main.tsx generated from template successfully"
    } else {
        Write-ErrorLog "main.tsx template not found: $mainTemplate"
        throw "Template file missing: main.tsx.template"
    }

    # Generate compositionRoot.ts from template
    Write-InfoLog "Generating compositionRoot.ts from template"
    $compositionRootTemplate = Join-Path $ProjectRoot "templates/src/compositionRoot.ts.template"
    $compositionRootPath = Join-Path $srcPath "compositionRoot.ts"
    
    if (Test-Path $compositionRootTemplate) {
        if (-not $DryRun) {
            Copy-Item $compositionRootTemplate $compositionRootPath -Force
        }
        Write-SuccessLog "compositionRoot.ts generated from template successfully"
    } else {
        Write-ErrorLog "compositionRoot.ts template not found: $compositionRootTemplate"
        throw "Template file missing: compositionRoot.ts.template"
    }

    # Create public directory placeholder
    if (-not (Test-Path $publicPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $publicPath -Force | Out-Null
        }
        Write-InfoLog "Created public directory for assets"
    }

    Write-SuccessLog "Browser/Server requirements setup completed successfully!"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - vite.config.ts (from template)"
    Write-InfoLog "  - index.html (from template)"
    Write-InfoLog "  - App.tsx (from template)"
    Write-InfoLog "  - main.tsx (from template)"
    Write-InfoLog "  - compositionRoot.ts (from template)"
    Write-InfoLog "Architecture: 100% template-driven, ZERO inline generation"

    exit 0
    
} catch {
    Write-ErrorLog "Browser/Server requirements setup failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 