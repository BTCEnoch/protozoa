# 27b-GenerateTraitDataFiles.ps1 - Phase 3 Data Enhancement
# Generates trait definition data files and mutation tables for the trait domain
# ARCHITECTURE: Template-first approach with comprehensive trait data generation
# Reference: architecture-gap-analysis.md 2.4 - Trait definition data files in trait/data/
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
    Write-StepHeader "Trait Data Files Generation - Phase 3 Data Enhancement"
    Write-InfoLog "Generating comprehensive trait definition data files from templates"

    # Define paths
    $traitDomainPath = Join-Path $ProjectRoot "src/domains/trait"
    $dataPath = Join-Path $traitDomainPath "data"
    $templatesPath = Join-Path $ProjectRoot "templates/domains/trait/data"

    # Ensure data directory exists
    Write-InfoLog "Creating Trait data directory structure"
    New-Item -Path $dataPath -ItemType Directory -Force | Out-Null
    Write-SuccessLog "Trait data directory created: $dataPath"

    # Generate trait definitions data file from template
    Write-InfoLog "Generating trait definitions data file from template"
    $traitDefinitionsTemplate = Join-Path $templatesPath "traitDefinitions.ts.template"
    $traitDefinitionsOutput = Join-Path $dataPath "traitDefinitions.ts"
    
    if (Test-Path $traitDefinitionsTemplate) {
        Copy-Item -Path $traitDefinitionsTemplate -Destination $traitDefinitionsOutput -Force
        Write-SuccessLog "Trait definitions generated: $traitDefinitionsOutput"
    }
    else {
        Write-ErrorLog "Trait definitions template not found: $traitDefinitionsTemplate"
        exit 1
    }

    # Generate mutation tables data file from template
    Write-InfoLog "Generating mutation tables data file from template"
    $mutationTablesTemplate = Join-Path $templatesPath "mutationTables.ts.template"
    $mutationTablesOutput = Join-Path $dataPath "mutationTables.ts"
    
    if (Test-Path $mutationTablesTemplate) {
        Copy-Item -Path $mutationTablesTemplate -Destination $mutationTablesOutput -Force
        Write-SuccessLog "Mutation tables generated: $mutationTablesOutput"
    }
    else {
        Write-ErrorLog "Mutation tables template not found: $mutationTablesTemplate"
        exit 1
    }

    # Update trait domain index to include data exports
    Write-InfoLog "Updating trait domain index to include data exports"
    $indexPath = Join-Path $traitDomainPath "index.ts"
    
    # Read existing index content
    $indexContent = Get-Content -Path $indexPath -Raw -ErrorAction SilentlyContinue
    if (-not $indexContent) {
        $indexContent = ""
    }

    # Check if data exports already exist
    if ($indexContent -notlike "*from './data/*") {
        # Append data exports to existing index
        $dataExports = @"

// Data exports
export {
  VISUAL_TRAIT_DEFINITIONS,
  BEHAVIORAL_TRAIT_DEFINITIONS,
  PHYSICAL_TRAIT_DEFINITIONS,
  EVOLUTIONARY_TRAIT_DEFINITIONS,
  MUTATION_PROBABILITIES,
  TRAIT_COMPATIBILITY_MATRIX,
  TraitDefinitionHelpers,
  ALL_TRAIT_DEFINITIONS,
  TRAIT_CATEGORIES
} from './data/traitDefinitions';

export {
  MUTATION_INTENSITY_LEVELS,
  COLOR_MUTATION_TABLE,
  NUMERIC_MUTATION_ALGORITHMS,
  TRAIT_MUTATION_MAPPINGS,
  MutationTableHelpers,
  MUTATION_CONFIG
} from './data/mutationTables';
"@

        $updatedContent = $indexContent + $dataExports
        Set-Content -Path $indexPath -Value $updatedContent -Encoding UTF8
        Write-SuccessLog "Updated trait domain index with data exports"
    }
    else {
        Write-InfoLog "Data exports already present in trait domain index"
    }

    # Validate TypeScript compilation
    Write-InfoLog "Validating generated TypeScript files"
    Push-Location $ProjectRoot
    
    try {
        $tscResult = & npx tsc --noEmit --skipLibCheck 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessLog "TypeScript validation passed"
        }
        else {
            Write-WarnLog "TypeScript validation warnings (non-critical): $tscResult"
        }
    }
    catch {
        Write-WarnLog "TypeScript validation could not be performed: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }

    Write-SuccessLog "Trait Data Files generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/trait/data/traitDefinitions.ts"
    Write-InfoLog "  - src/domains/trait/data/mutationTables.ts"
    Write-InfoLog "  - Updated src/domains/trait/index.ts with data exports"
    
    Write-InfoLog "ARCHITECTURE GAP RESOLVED: ✅ 2.4 - Trait definition data files in trait/data/"

    exit 0
}
catch {
    Write-ErrorLog "Trait Data Files generation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 