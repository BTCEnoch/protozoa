# 33-ImplementSwarmIntelligence.ps1 - Phase 4 Enhancement
# Generates SwarmIntelligenceService handling collective behaviors
# Reference: script_checklist.md lines 1550-1600
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Swarm Intelligence Service Generation"
 $groupPath=Join-Path $ProjectRoot 'src/domains/group'
 $services=Join-Path $groupPath 'services'
 $interfaces=Join-Path $groupPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Generate files from templates
 Write-TemplateFile -TemplateRelPath 'domains/group/interfaces/ISwarmService.ts.template' `
                   -DestinationPath (Join-Path $interfaces 'ISwarmService.ts')

 Write-TemplateFile -TemplateRelPath 'domains/group/services/swarmService.ts.template' `
                   -DestinationPath (Join-Path $services 'swarmService.ts')

 Write-SuccessLog "SwarmService generated"
 exit 0
}catch{Write-ErrorLog "Swarm generation failed: $($_.Exception.Message)";exit 1}
