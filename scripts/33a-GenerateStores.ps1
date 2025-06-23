# 33a-GenerateStores.ps1
# Template-driven Zustand store generation
# ZERO inline code generation - Templates ONLY

<#
.SYNOPSIS
    Generates Zustand stores using templates only (NO inline generation)
.DESCRIPTION
    Creates state management stores from comprehensive templates:
    - useSimulationStore from template
    - useParticleStore from template
    Follows template-first architecture with zero tolerance for inline generation
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER DryRun
    Preview changes without writing files
.EXAMPLE
    .\33a-GenerateStores.ps1 -ProjectRoot "C:\Projects\Protozoa"
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
    Write-StepHeader "Template-Only Zustand Store Generation"
    Write-InfoLog "Generating stores using templates only..."
    
    # Setup paths
    $sharedPath = Join-Path $ProjectRoot "src/shared"
    $statePath = Join-Path $sharedPath "state"
    
    # Ensure state directory exists
    if (-not (Test-Path $statePath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $statePath -Force | Out-Null
        }
        Write-InfoLog "Created state directory: $statePath"
    }

    # Generate useSimulationStore from template
    Write-InfoLog "Generating useSimulationStore from template"
    $simulationStoreTemplate = Join-Path $ProjectRoot "templates/shared/state/useSimulationStore.ts.template"
    $simulationStorePath = Join-Path $statePath "useSimulationStore.ts"
    
    if (Test-Path $simulationStoreTemplate) {
        if (-not $DryRun) {
            Copy-Item $simulationStoreTemplate $simulationStorePath -Force
        }
        Write-SuccessLog "useSimulationStore generated from template successfully"
    } else {
        Write-ErrorLog "useSimulationStore template not found: $simulationStoreTemplate"
        throw "Template file missing: useSimulationStore.ts.template"
    }

    # Generate useParticleStore from template
    Write-InfoLog "Generating useParticleStore from template"
    $particleStoreTemplate = Join-Path $ProjectRoot "templates/shared/state/useParticleStore.ts.template"
    $particleStorePath = Join-Path $statePath "useParticleStore.ts"
    
    if (Test-Path $particleStoreTemplate) {
        if (-not $DryRun) {
            Copy-Item $particleStoreTemplate $particleStorePath -Force
        }
        Write-SuccessLog "useParticleStore generated from template successfully"
    } else {
        Write-ErrorLog "useParticleStore template not found: $particleStoreTemplate"
        throw "Template file missing: useParticleStore.ts.template"
    }

    # Generate state index from template for proper exports
    Write-InfoLog "Generating state index from template"
    $stateIndexTemplate = Join-Path $ProjectRoot "templates/shared/state/index.ts.template"
    $stateIndexPath = Join-Path $statePath "index.ts"
    
    if (Test-Path $stateIndexTemplate) {
        if (-not $DryRun) {
            Copy-Item $stateIndexTemplate $stateIndexPath -Force
        }
        Write-SuccessLog "State index generated from template successfully"
    } else {
        Write-WarningLog "State index template not found: $stateIndexTemplate"
        Write-InfoLog "Continuing without index file - may cause import issues"
    }

    Write-SuccessLog "Zustand store generation completed successfully!"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - useSimulationStore.ts (from template)"
    Write-InfoLog "  - useParticleStore.ts (from template)"
    Write-InfoLog "  - index.ts (from template)"
    Write-InfoLog "Architecture: 100% template-driven, ZERO inline generation"

    exit 0
    
} catch {
    Write-ErrorLog "Zustand store generation failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 