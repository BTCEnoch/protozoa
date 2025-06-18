# 32-SetupParticleLifecycleManagement.ps1 - Phase 4 Enhancement
# Generates lifecycle hooks and EvolutionEngine for particles
# Reference: script_checklist.md lines 2050-2100
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Particle Lifecycle Management Setup"
 $particlePath=Join-Path $ProjectRoot 'src/domains/particle'
 $services=Join-Path $particlePath 'services'
 New-Item -Path $services -ItemType Directory -Force | Out-Null

 # Generate files from templates
 Write-TemplateFile -TemplateRelPath 'domains/particle/interfaces/ILifecycleEngine.ts.template' `
                   -DestinationPath (Join-Path $particlePath 'interfaces\ILifecycleEngine.ts')

 Write-TemplateFile -TemplateRelPath 'domains/particle/services/lifecycleEngine.ts.template' `
                   -DestinationPath (Join-Path $services 'lifecycleEngine.ts')

 Write-SuccessLog "LifecycleEngine generated"
 exit 0
}catch{Write-ErrorLog "Lifecycle setup failed: $($_.Exception.Message)";exit 1}
