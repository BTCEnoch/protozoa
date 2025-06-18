# 36-GenerateEffectService.ps1 - Phase 5 Core Domain Implementation
# Generates EffectService for particle visual effects and preset management
# Reference: script_checklist.md | build_design.md lines 300-500 (Effect domain)
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
    Write-StepHeader "Effect Service Generation - Phase 5 Core Domain Implementation"
    Write-InfoLog "Generating EffectService and interfaces"

    # Define paths
    $effectDomainPath = Join-Path $ProjectRoot "src/domains/effect"
    $servicesPath     = Join-Path $effectDomainPath "services"
    $interfacesPath   = Join-Path $effectDomainPath "interfaces"
    $dataPath         = Join-Path $effectDomainPath "data"

    # Ensure directories exist
    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $dataPath       -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Effect domain directories ensured"

    # Generate files from templates
    Write-TemplateFile -TemplateRelPath 'domains/effect/interfaces/IEffectService.ts.template' `
                      -DestinationPath (Join-Path $interfacesPath 'IEffectService.ts')

    Write-TemplateFile -TemplateRelPath 'domains/effect/services/effectService.ts.template' `
                      -DestinationPath (Join-Path $servicesPath 'effectService.ts')

    Write-SuccessLog "36-GenerateEffectService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Effect Service Generation failed: $($_.Exception.Message)"
    exit 1
}
