# 34-EnhanceFormationSystem.ps1 - Phase 4 Enhancement
# Adds dynamic pattern generation and caching to FormationService
# Reference: script_checklist.md lines 1600-1650
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Formation System Enhancement"
 $formationPath=Join-Path $ProjectRoot 'src/domains/formation'
 $services=Join-Path $formationPath 'services'
 New-Item -Path $services -ItemType Directory -Force | Out-Null

 Write-TemplateFile -TemplateRelPath 'domains/formation/services/dynamicFormationGenerator.ts.template' `
                   -DestinationPath (Join-Path $services 'dynamicFormationGenerator.ts')

 Write-SuccessLog "DynamicFormationGenerator generated"
 exit 0
}catch{Write-ErrorLog "Formation enhancement failed: $($_.Exception.Message)";exit 1}
