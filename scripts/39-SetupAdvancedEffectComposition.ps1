# 39-SetupAdvancedEffectComposition.ps1 - Phase 5 Visual Enhancement
# Generates EffectComposerService for layered visual/audio effect composition
# Reference: script_checklist.md lines 1850-1950
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Advanced Effect Composition Generation"
 $effectPath=Join-Path $ProjectRoot 'src/domains/effect'
 $services=Join-Path $effectPath 'services'
 $interfaces=Join-Path $effectPath 'interfaces'
 $data=Join-Path $effectPath 'data'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null
 New-Item -Path $data -ItemType Directory -Force | Out-Null

 # Generate templates
 Write-TemplateFile -TemplateRelPath 'domains/effect/interfaces/IEffectComposerService.ts.template' `
                   -DestinationPath (Join-Path $interfaces 'IEffectComposerService.ts')

 Write-TemplateFile -TemplateRelPath 'domains/effect/services/effectComposerService.ts.template' `
                   -DestinationPath (Join-Path $services 'effectComposerService.ts')

 Write-SuccessLog "EffectComposerService generated"
 exit 0
}catch{Write-ErrorLog "Effect composition generation failed: $($_.Exception.Message)";exit 1}
