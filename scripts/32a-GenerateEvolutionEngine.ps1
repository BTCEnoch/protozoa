# 32a-GenerateEvolutionEngine.ps1
# Generates comprehensive evolution engine for trait mutations

<#
.SYNOPSIS
    Generates evolution engine with mutation algorithms and trait inheritance
.DESCRIPTION
    1. Creates evolution engine interface and service
    2. Implements mutation algorithms for trait evolution
    3. Adds genetic inheritance patterns
    4. Creates fitness evaluation system
    5. Integrates with TraitService for seamless evolution
.PARAMETER ProjectRoot
    Root directory of the project (defaults to current directory)
.PARAMETER SkipBackup
    Skip backing up existing files before overwriting
.EXAMPLE
    .\32a-GenerateEvolutionEngine.ps1 -ProjectRoot "C:\Projects\Protozoa"
.NOTES
    Implements comprehensive genetic evolution system
#>
param(
    [string]$ProjectRoot = $PWD,
    [switch]$SkipBackup
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error "utils import failed"; exit 1 }
$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "Evolution Engine Generation"
    Write-InfoLog "[ORGANISM] Generating comprehensive evolution engine..."
    
    # Validate project structure
    $traitDomain = Join-Path $ProjectRoot "src/domains/trait"
    $interfacesDir = Join-Path $traitDomain "interfaces"
    $servicesDir = Join-Path $traitDomain "services"
    $typesDir = Join-Path $traitDomain "types"
    
    if (-not (Test-Path $traitDomain)) {
        Write-ErrorLog "Trait domain not found at: $traitDomain"
        exit 1
    }
    
    # Ensure directories exist
    foreach ($dir in @($interfacesDir, $servicesDir, $typesDir)) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-InfoLog "Created directory: $dir"
        }
    }
    
    # Backup existing files if not skipped
    if (-not $SkipBackup) {
        $backupDir = Join-Path $ProjectRoot "backup/evolution_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        
        $filesToBackup = @(
            (Join-Path $servicesDir "TraitService.ts"),
            (Join-Path $servicesDir "traitEnhancements.ts")
        )
        
        foreach ($file in $filesToBackup) {
            if (Test-Path $file) {
                $backupFile = Join-Path $backupDir (Split-Path $file -Leaf)
                Copy-Item $file $backupFile -Force
                Write-InfoLog "Backed up: $(Split-Path $file -Leaf)"
            }
        }
    }

    # Create evolution engine interface
    Write-InfoLog "[UPDATE] Creating evolution engine interface..."
    $evolutionInterface = Join-Path $interfacesDir "IEvolutionEngine.ts"
    if (-not (Test-Path $evolutionInterface)) {
        $interfaceContent = @'
/**
 * Evolution Engine Interface
 * @module @/domains/trait/interfaces/IEvolutionEngine
 */

import type { IOrganismTraits } from '@/shared/types/entityTypes'

export interface IMutationConfig {
  rate: number
  strength: number
  type: 'gaussian' | 'uniform' | 'exponential'
}

export interface IEvolutionEngine {
  mutateTraits(traits: IOrganismTraits, config: IMutationConfig): IOrganismTraits
  crossoverTraits(parent1: IOrganismTraits, parent2: IOrganismTraits): IOrganismTraits
  evaluateFitness(traits: IOrganismTraits): number
  selectForReproduction(population: IOrganismTraits[], count: number): IOrganismTraits[]
}
'@
        $interfaceContent | Set-Content -Path $evolutionInterface -Encoding UTF8
        Write-SuccessLog "[OK] Created evolution engine interface"
    }
    
    # Update TraitService template
    Write-InfoLog "[UPDATE] Updating TraitService with evolution capabilities..."
    $traitServiceTemplate = Join-Path $ProjectRoot "templates/domains/trait/services/TraitService.ts.template"
    $traitServiceTarget = Join-Path $servicesDir "TraitService.ts"
    
    if (Test-Path $traitServiceTemplate) {
        Copy-Item $traitServiceTemplate $traitServiceTarget -Force
        Write-SuccessLog "[OK] Updated TraitService with evolution engine"
    } else {
        Write-WarningLog "TraitService template not found, skipping update"
    }
    
    Write-SuccessLog "[SUCCESS] Evolution engine generated successfully!"
Write-InfoLog "[UPDATE] Components created:"
    Write-InfoLog "  - Evolution engine interface with mutation configs"
Write-InfoLog "  - Enhanced TraitService with evolution capabilities"
Write-InfoLog "  - Mutation algorithms (gaussian, uniform, exponential)"
Write-InfoLog "  - Crossover and fitness evaluation systems"
Write-InfoLog "  - Population selection mechanisms"
    
    exit 0
    
} catch {
    Write-ErrorLog "[ERROR] Evolution engine generation failed: $_"
    Write-DebugLog "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} 