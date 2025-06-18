# 37-SetupCustomShaderSystem.ps1 - Phase 5 Visual Enhancement
# Generates ShaderService and shader library for custom GLSL effects
# Reference: script_checklist.md lines 2400-2450
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Custom Shader System Setup"
 $renderPath=Join-Path $ProjectRoot 'src/domains/rendering'
 $services=Join-Path $renderPath 'services'
 $interfaces=Join-Path $renderPath 'interfaces'
 $data=Join-Path $renderPath 'data'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null
 New-Item -Path $data -ItemType Directory -Force | Out-Null

 # Generate files from templates
 Write-TemplateFile -TemplateRelPath 'domains/rendering/data/shaderLibrary.ts.template' `
                   -DestinationPath (Join-Path $data 'shaderLibrary.ts')

 Write-TemplateFile -TemplateRelPath 'domains/rendering/interfaces/IShaderService.ts.template' `
                   -DestinationPath (Join-Path $interfaces 'IShaderService.ts')

 Write-TemplateFile -TemplateRelPath 'domains/rendering/services/shaderService.ts.template' `
                   -DestinationPath (Join-Path $services 'shaderService.ts')

 Write-SuccessLog "Shader system generated"
 exit 0
}catch{Write-ErrorLog "Shader system generation failed: $($_.Exception.Message)";exit 1}
