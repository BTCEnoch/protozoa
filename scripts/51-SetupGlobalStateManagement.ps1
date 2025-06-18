# 51-SetupGlobalStateManagement.ps1 - Phase 8 State
# Creates useSimulationStore and useParticleStore Zustand stores
#Requires -Version 5.1
[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))
try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'
try{
 Write-StepHeader "Global State Management Setup"
 $storeDir=Join-Path $ProjectRoot 'src/shared/state'
 New-Item -Path $storeDir -ItemType Directory -Force | Out-Null
 Write-TemplateFile -TemplateRelPath 'shared/state/useSimulationStore.ts.template' `
                   -DestinationPath (Join-Path $storeDir 'useSimulationStore.ts')

 Write-TemplateFile -TemplateRelPath 'shared/state/useParticleStore.ts.template' `
                   -DestinationPath (Join-Path $storeDir 'useParticleStore.ts')

 Write-SuccessLog "Zustand stores generated"
 exit 0
}catch{Write-ErrorLog "State setup failed: $($_.Exception.Message)";exit 1}
