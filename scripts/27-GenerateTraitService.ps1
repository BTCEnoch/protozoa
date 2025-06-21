# 27-GenerateTraitService.ps1 - Phase 3 Data & Blockchain Integration
# Generates complete TraitService with Bitcoin block-seeded trait generation and mutation algorithms
# ARCHITECTURE: Singleton pattern with genetic inheritance and blockchain-influenced evolution
# Reference: script_checklist.md lines 27-GenerateTraitService.ps1
# Reference: build_design.md lines 600-800 - Trait service and mutation algorithms
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Trait Service Generation - Phase 3 Data & Blockchain Integration"
    Write-InfoLog "Generating complete TraitService with Bitcoin block-seeded trait generation"

    # Define paths
    $traitDomainPath = Join-Path $ProjectRoot "src/domains/trait"
    $servicesPath = Join-Path $traitDomainPath "services"
    $typesPath = Join-Path $traitDomainPath "types"
    $interfacesPath = Join-Path $traitDomainPath "interfaces"
    $utilsPath = Join-Path $traitDomainPath "utils"

    # Ensure directories exist
    Write-InfoLog "Creating Trait domain directory structure"
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $typesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $utilsPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Trait domain directories created successfully"

    # Generate ITraitService interface from template
    Write-InfoLog "Generating ITraitService interface from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/trait/interfaces/ITraitService.ts.template"
    $outputPath = Join-Path $interfacesPath "ITraitService.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "ITraitService interface generated successfully"

    # Generate trait types from template
    Write-InfoLog "Generating Trait types definitions from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/trait/types/trait.types.ts.template"
    $outputPath = Join-Path $typesPath "trait.types.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "Trait types generated successfully"

    # Generate TraitService implementation from template
    Write-InfoLog "Generating TraitService implementation from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/trait/services/TraitService.ts.template"
    $outputPath = Join-Path $servicesPath "TraitService.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "TraitService implementation generated successfully"

    # Generate export index file
    Write-InfoLog "Generating Trait domain export index"
    $indexContent = @'
/**
 * @fileoverview Trait Domain Exports
 * @description Main export file for Trait domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { TraitService, traitService } from "./services/TraitService";

// Interface exports
export type {
  ITraitService,
  TraitConfig
} from "./interfaces/ITraitService";

// Type exports
export type {
  OrganismTraits,
  VisualTraits,
  BehavioralTraits,
  PhysicalTraits,
  EvolutionaryTraits,
  TraitMetrics,
  TraitCategory,
  TraitType,
  MutationRecord,
  TraitValidation,
  TraitGenerationParams,
  GenerationType,
  RGBColor,
  TraitRange,
  InheritanceWeights
} from "./types/trait.types";
'@

    Set-Content -Path (Join-Path $traitDomainPath "index.ts") -Value $indexContent -Encoding UTF8
    Write-SuccessLog "Trait domain export index generated successfully"

    Write-SuccessLog "Trait Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/trait/interfaces/ITraitService.ts"
    Write-InfoLog "  - src/domains/trait/types/trait.types.ts"
    Write-InfoLog "  - src/domains/trait/services/TraitService.ts"
    Write-InfoLog "  - src/domains/trait/index.ts"

    exit 0
}
catch {
    Write-ErrorLog "Trait Service generation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 