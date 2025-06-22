# 31-GenerateParticleService.ps1 - Phase 4 Rendering & Optimization
# Generates complete ParticleService with THREE.js integration and GPU optimization
# ARCHITECTURE: Singleton pattern with object pooling and instanced rendering
# Reference: script_checklist.md lines 31-GenerateParticleService.ps1
# Reference: build_design.md lines 500-650 - Particle service and THREE.js integration
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
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
    Write-StepHeader "Particle Service Generation - Phase 4 Rendering & Optimization"
    Write-InfoLog "Generating complete ParticleService with THREE.js integration and GPU optimization"

    # Define paths
    $particleDomainPath = Join-Path $ProjectRoot "src/domains/particle"
    $servicesPath = Join-Path $particleDomainPath "services"
    $typesPath = Join-Path $particleDomainPath "types"
    $interfacesPath = Join-Path $particleDomainPath "interfaces"
    $utilsPath = Join-Path $particleDomainPath "utils"

    # Ensure directories exist
    Write-InfoLog "Creating Particle domain directory structure"
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $typesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $utilsPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Particle domain directories created successfully"

    # Generate IParticleService interface from template
    Write-InfoLog "Generating IParticleService interface from template"
    $interfaceTemplate = Join-Path $ProjectRoot "templates/domains/particle/interfaces/IParticleService.ts.template"
    
    if (Test-Path $interfaceTemplate) {
        Copy-Item $interfaceTemplate (Join-Path $interfacesPath "IParticleService.ts") -Force
        Write-SuccessLog "IParticleService interface generated from template successfully"
    } else {
        Write-ErrorLog "IParticleService template not found: $interfaceTemplate"
        throw "Template file missing: IParticleService.ts.template"
    }

    # Generate ParticleService from template
    Write-InfoLog "Generating ParticleService from template"
    $serviceTemplate = Join-Path $ProjectRoot "templates/domains/particle/services/ParticleService.ts.template"
    
    if (Test-Path $serviceTemplate) {
        $serviceContent = Get-Content -Path $serviceTemplate -Raw
        Set-Content -Path (Join-Path $servicesPath "ParticleService.ts") -Value $serviceContent -Encoding UTF8
        Write-SuccessLog "ParticleService generated from template successfully"
    } else {
        Write-ErrorLog "ParticleService template not found: $serviceTemplate"
        throw "Template file missing: $serviceTemplate"
    }

    # Generate particle types from template  
    Write-InfoLog "Generating particle types from template"
    $typesTemplate = Join-Path $ProjectRoot "templates/domains/particle/types/particle.types.ts.template"
    
    if (Test-Path $typesTemplate) {
        Copy-Item $typesTemplate (Join-Path $typesPath "particle.types.ts") -Force
        Write-SuccessLog "Particle types generated from template successfully"
    } else {
        Write-ErrorLog "Particle types template not found: $typesTemplate"
        throw "Template file missing: particle.types.ts.template"
    }

    # Generate domain index file from template
    Write-InfoLog "Generating particle domain index from template"
    $indexTemplate = Join-Path $ProjectRoot "templates/domains/particle/index.ts.template"
    
    if (Test-Path $indexTemplate) {
        Copy-Item $indexTemplate (Join-Path $particleDomainPath "index.ts") -Force
        Write-SuccessLog "Particle domain index generated from template successfully"
    } else {
        Write-ErrorLog "Particle domain index template not found: $indexTemplate"
        throw "Template file missing: particle domain index.ts.template"
    }

    Write-SuccessLog "Particle Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - IParticleService interface"
    Write-InfoLog "  - ParticleService implementation (from template)"
    Write-InfoLog "  - Particle type definitions"
    Write-InfoLog "  - Domain index file"

    return $true

} catch {
    Write-ErrorLog "Failed to generate Particle Service: $($_.Exception.Message)"
    Write-ErrorLog "Stack trace: $($_.ScriptStackTrace)"
    return $false
} 