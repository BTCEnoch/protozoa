# 42-SetupPhysicsBasedAnimation.ps1 - Phase 6 Enhancement
# Generates PhysicsAnimationService integrating physics constraints with animations
# Reference: script_checklist.md lines 1500-1550
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Physics-Based Animation Service Generation"
 $animPath=Join-Path $ProjectRoot 'src/domains/animation'
 $services=Join-Path $animPath 'services'
 $interfaces=Join-Path $animPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Generate files from templates
 Write-TemplateFile -TemplateRelPath 'domains/animation/interfaces/IPhysicsAnimationService.ts.template' `
                   -DestinationPath (Join-Path $interfaces 'IPhysicsAnimationService.ts')

 Write-TemplateFile -TemplateRelPath 'domains/animation/services/physicsAnimationService.ts.template' `
                   -DestinationPath (Join-Path $services 'physicsAnimationService.ts')

 Write-SuccessLog "PhysicsAnimationService generated"
 exit 0
}catch{Write-ErrorLog "Physics-based animation generation failed: $($_.Exception.Message)";exit 1}
