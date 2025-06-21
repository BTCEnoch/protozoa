# PowerShell Script: 18-GenerateFormationDomain.ps1
# =====================================================
# Generates complete Formation Domain implementation using template-based generation
# 
# - IFormationService interface from template
# - FormationService singleton class from template
# - Formation pattern data definitions from templates
# - Formation geometry utilities from templates
# - Proper dependency injection and Winston logging
# - Full .cursorrules compliance (singleton patterns, domain isolation)
#
# This addresses the critical Formation Domain implementation gap identified in build_checklist.md
# Reference: build_design.md Section 2 - Formation integration, addon.md Formation implementation guides

param(
    [string]$ProjectRoot = ".",
    [switch]$Verbose = $false
)

# Import utilities module for consistent logging and file operations
try {
    Import-Module (Join-Path $PSScriptRoot "utils.psm1") -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

Write-InfoLog "Starting Formation Domain generation using template-based approach..."

# Ensure domain directory structure exists
$formationDomainPath = Join-Path $ProjectRoot "src/domains/formation"
$servicesPath = Join-Path $formationDomainPath "services"
$typesPath = Join-Path $formationDomainPath "types"
$dataPath = Join-Path $formationDomainPath "data"
$interfacesPath = Join-Path $formationDomainPath "interfaces"

# Create directory structure
@($formationDomainPath, $servicesPath, $typesPath, $dataPath, $interfacesPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
        Write-InfoLog "Created directory: $_"
    }
}

# Generate IFormationService interface from template
Write-InfoLog "Generating IFormationService interface from template..."
$interfaceTemplate = Join-Path $ProjectRoot "templates/domains/formation/interfaces/IFormationService.ts.template"
$interfaceOutput = Join-Path $interfacesPath "IFormationService.ts"

if (Test-Path $interfaceTemplate) {
    Copy-Item -Path $interfaceTemplate -Destination $interfaceOutput -Force
    Write-SuccessLog "Generated IFormationService interface: $interfaceOutput"
} else {
    Write-ErrorLog "Interface template not found: $interfaceTemplate"
    exit 1
}

# Generate FormationService implementation from template
Write-InfoLog "Generating FormationService implementation from template..."
$serviceTemplate = Join-Path $ProjectRoot "templates/domains/formation/services/FormationService.ts.template"
$serviceOutput = Join-Path $servicesPath "FormationService.ts"

if (Test-Path $serviceTemplate) {
    Copy-Item -Path $serviceTemplate -Destination $serviceOutput -Force
    Write-SuccessLog "Generated FormationService implementation: $serviceOutput"
} else {
    Write-ErrorLog "Service template not found: $serviceTemplate"
    exit 1
}

# Generate formation geometry utilities from template
Write-InfoLog "Generating formation geometry utilities from template..."
$geometryTemplate = Join-Path $ProjectRoot "templates/domains/formation/data/formationGeometry.ts.template"
$geometryOutput = Join-Path $dataPath "formationGeometry.ts"

if (Test-Path $geometryTemplate) {
    Copy-Item -Path $geometryTemplate -Destination $geometryOutput -Force
    Write-SuccessLog "Generated formation geometry utilities: $geometryOutput"
} else {
    Write-ErrorLog "Geometry template not found: $geometryTemplate"
    exit 1
}

# Generate formation patterns from template
Write-InfoLog "Generating formation patterns from template..."
$patternsTemplate = Join-Path $ProjectRoot "templates/domains/formation/data/formationPatterns.ts.template"
$patternsOutput = Join-Path $dataPath "formationPatterns.ts"

if (Test-Path $patternsTemplate) {
    Copy-Item -Path $patternsTemplate -Destination $patternsOutput -Force
    Write-SuccessLog "Generated formation patterns: $patternsOutput"
} else {
    Write-ErrorLog "Patterns template not found: $patternsTemplate"
    exit 1
}

# Generate dynamic formation generator from existing template
Write-InfoLog "Generating dynamic formation generator from template..."
$dynamicTemplate = Join-Path $ProjectRoot "templates/domains/formation/services/dynamicFormationGenerator.ts.template"
$dynamicOutput = Join-Path $servicesPath "dynamicFormationGenerator.ts"

if (Test-Path $dynamicTemplate) {
    Copy-Item -Path $dynamicTemplate -Destination $dynamicOutput -Force
    Write-SuccessLog "Generated dynamic formation generator: $dynamicOutput"
} else {
    Write-WarningLog "Dynamic formation generator template not found: $dynamicTemplate"
}

# Generate formation types from existing template
Write-InfoLog "Generating formation types..."
$typesTemplate = Join-Path $ProjectRoot "templates/domains/formation/types/IFormationService.ts.template"
$typesOutput = Join-Path $typesPath "IFormationService.ts"

if (Test-Path $typesTemplate) {
    Copy-Item -Path $typesTemplate -Destination $typesOutput -Force
    Write-SuccessLog "Generated formation types: $typesOutput"
} else {
    Write-WarningLog "Formation types template not found, using interface as fallback"
    Copy-Item -Path $interfaceOutput -Destination $typesOutput -Force
}

# Generate domain index file
Write-InfoLog "Generating formation domain index file..."
$indexContent = @"
/**
 * @fileoverview Formation Domain Exports
 * @module @/domains/formation
 * @version 1.0.0
 */

// Service exports
export { FormationService } from "./services/FormationService";
export { formationService } from "./services/FormationService";

// Interface exports
export type { IFormationService, IFormationPattern, IFormationConfig, IFormationResult } from "./interfaces/IFormationService";

// Data exports
export { FormationGeometry } from "./data/formationGeometry";
export { FormationPatterns } from "./data/formationPatterns";

// Type exports
export type * from "./types/IFormationService";
"@

$indexOutput = Join-Path $formationDomainPath "index.ts"
Set-Content -Path $indexOutput -Value $indexContent -Encoding UTF8
Write-SuccessLog "Generated formation domain index: $indexOutput"

Write-SuccessLog "Formation Domain generation completed successfully!"
Write-InfoLog "Generated files:"
Write-InfoLog "  - Interface: $interfaceOutput"
Write-InfoLog "  - Service: $serviceOutput"
Write-InfoLog "  - Geometry: $geometryOutput"
Write-InfoLog "  - Patterns: $patternsOutput"
Write-InfoLog "  - Dynamic: $dynamicOutput"
Write-InfoLog "  - Types: $typesOutput"
Write-InfoLog "  - Index: $indexOutput"

Write-InfoLog "Formation Domain generation completed successfully with template-based approach!" 