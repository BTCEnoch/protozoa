# 35-GenerateRenderingService.ps1 - Phase 5 Core Domain Implementation
# Generates RenderingService for THREE.js scene management and associated interface
# Reference: script_checklist.md | build_design.md lines 60-300 (Rendering domain)
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
    Write-StepHeader "Rendering Service Generation - Phase 5 Core Domain Implementation"
    Write-InfoLog "Generating RenderingService and interfaces"

    # Define paths
    $renderingDomainPath = Join-Path $ProjectRoot "src/domains/rendering"
    $servicesPath       = Join-Path $renderingDomainPath "services"
    $interfacesPath     = Join-Path $renderingDomainPath "interfaces"

    # Ensure directories exist
    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Rendering domain directories ensured"

    # Generate files from templates
    Write-TemplateFile -TemplateRelPath 'domains/rendering/interfaces/IRenderingService.ts.template' `
                      -DestinationPath (Join-Path $interfacesPath 'IRenderingService.ts')

    Write-TemplateFile -TemplateRelPath 'domains/rendering/services/renderingService.ts.template' `
                      -DestinationPath (Join-Path $servicesPath 'RenderingService.ts')

    Write-SuccessLog "35-GenerateRenderingService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Rendering Service Generation failed: $($_.Exception.Message)"
    exit 1
}
