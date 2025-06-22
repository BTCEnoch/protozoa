# 41a-SetupR3FIntegration.ps1
# Template-driven React Three Fiber integration setup
# ZERO inline code generation - Templates ONLY

<#
.SYNOPSIS
    Sets up React Three Fiber integration using templates only (NO inline generation)
.DESCRIPTION
    Creates R3F components from comprehensive templates:
    - Scene.tsx from template
    - ParticleSystem.tsx from template
    - hooks.ts from template
    - index.ts from template
    Follows template-first architecture with zero tolerance for inline generation
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER DryRun
    Preview changes without writing files
.EXAMPLE
    .\41a-SetupR3FIntegration.ps1 -ProjectRoot "C:\Projects\Protozoa"
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
    Write-StepHeader "Template-Only React Three Fiber Integration Setup"
    Write-InfoLog "Setting up R3F integration using templates only..."
    
    # Setup paths
    $r3fComponentsPath = Join-Path $ProjectRoot "src/components/r3f"
    
    # Ensure R3F components directory exists
    if (-not (Test-Path $r3fComponentsPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $r3fComponentsPath -Force | Out-Null
        }
        Write-InfoLog "Created R3F components directory: $r3fComponentsPath"
    }

    # Generate Scene component from template
    Write-InfoLog "Generating R3F Scene component from template"
    $sceneTemplate = Join-Path $ProjectRoot "templates/components/r3f/Scene.tsx.template"
    $scenePath = Join-Path $r3fComponentsPath "Scene.tsx"
    
    if (Test-Path $sceneTemplate) {
        if (-not $DryRun) {
            Copy-Item $sceneTemplate $scenePath -Force
        }
        Write-SuccessLog "Scene.tsx generated from template successfully"
    } else {
        Write-ErrorLog "Scene template not found: $sceneTemplate"
        throw "Template file missing: Scene.tsx.template"
    }

    # Generate ParticleSystem component from template
    Write-InfoLog "Generating R3F ParticleSystem component from template"
    $particleSystemTemplate = Join-Path $ProjectRoot "templates/components/r3f/ParticleSystem.tsx.template"
    $particleSystemPath = Join-Path $r3fComponentsPath "ParticleSystem.tsx"
    
    if (Test-Path $particleSystemTemplate) {
        if (-not $DryRun) {
            Copy-Item $particleSystemTemplate $particleSystemPath -Force
        }
        Write-SuccessLog "ParticleSystem.tsx generated from template successfully"
    } else {
        Write-ErrorLog "ParticleSystem template not found: $particleSystemTemplate"
        throw "Template file missing: ParticleSystem.tsx.template"
    }

    # Generate R3F hooks from template
    Write-InfoLog "Generating R3F hooks from template"
    $hooksTemplate = Join-Path $ProjectRoot "templates/components/r3f/hooks.ts.template"
    $hooksPath = Join-Path $r3fComponentsPath "hooks.ts"
    
    if (Test-Path $hooksTemplate) {
        if (-not $DryRun) {
            Copy-Item $hooksTemplate $hooksPath -Force
        }
        Write-SuccessLog "hooks.ts generated from template successfully"
    } else {
        Write-ErrorLog "hooks template not found: $hooksTemplate"
        throw "Template file missing: hooks.ts.template"
    }

    # Generate R3F index from template
    Write-InfoLog "Generating R3F index from template"
    $indexTemplate = Join-Path $ProjectRoot "templates/components/r3f/index.ts.template"
    $indexPath = Join-Path $r3fComponentsPath "index.ts"
    
    if (Test-Path $indexTemplate) {
        if (-not $DryRun) {
            Copy-Item $indexTemplate $indexPath -Force
        }
        Write-SuccessLog "index.ts generated from template successfully"
    } else {
        Write-ErrorLog "index template not found: $indexTemplate"
        throw "Template file missing: index.ts.template"
    }

    Write-SuccessLog "React Three Fiber integration setup completed successfully!"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - Scene.tsx (from template)"
    Write-InfoLog "  - ParticleSystem.tsx (from template)"
    Write-InfoLog "  - hooks.ts (from template)"
    Write-InfoLog "  - index.ts (from template)"
    Write-InfoLog "Architecture: 100% template-driven, ZERO inline generation"

    exit 0
    
} catch {
    Write-ErrorLog "React Three Fiber integration setup failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 