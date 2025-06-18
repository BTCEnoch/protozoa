# 40-GenerateAnimationService.ps1 - Phase 6 Core Domain Implementation
# Generates AnimationService and interface for managing particle animations
# Reference: script_checklist.md | build_design.md lines 200-350 (Animation domain)
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
    Write-StepHeader "Animation Service Generation - Phase 6 Core Domain Implementation"
    Write-InfoLog "Generating AnimationService and interfaces"

    # Paths
    $animationDomainPath = Join-Path $ProjectRoot "src/domains/animation"
    $servicesPath        = Join-Path $animationDomainPath "services"
    $interfacesPath      = Join-Path $animationDomainPath "interfaces"

    New-Item -Path $servicesPath   -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Animation domain directories ensured"

    # Generate templates
    Write-TemplateFile -TemplateRelPath 'domains/animation/interfaces/IAnimationService.ts.template' `
                      -DestinationPath (Join-Path $interfacesPath 'IAnimationService.ts')

    Write-TemplateFile -TemplateRelPath 'domains/animation/services/animationService.ts.template' `
                      -DestinationPath (Join-Path $servicesPath 'animationService.ts')

    Write-SuccessLog "40-GenerateAnimationService.ps1 completed successfully"
    exit 0
}
catch {
    Write-ErrorLog "Animation Service Generation failed: $($_.Exception.Message)"
    exit 1
}
