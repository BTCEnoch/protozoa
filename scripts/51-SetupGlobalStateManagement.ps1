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
 $sim= @"
import create from 'zustand'
interface SimulationState{ running:boolean; formation:string|null; setRunning:(v:boolean)=>void; setFormation:(f:string|null)=>void }
export const useSimulationStore=create<SimulationState>(set=>({ running:false, formation:null, setRunning:v=>set({running:v}), setFormation:f=>set({formation:f}) }))
"@
 Set-Content -Path (Join-Path $storeDir 'useSimulationStore.ts') -Value $sim -Encoding UTF8
 $part= @"
import create from 'zustand'
interface ParticleUIState{ selected:string|null; select:(id:string|null)=>void }
export const useParticleStore=create<ParticleUIState>(set=>({selected:null,select:id=>set({selected:id})}))
"@
 Set-Content -Path (Join-Path $storeDir 'useParticleStore.ts') -Value $part -Encoding UTF8
 Write-SuccessLog "Zustand stores generated"
 exit 0
}catch{Write-ErrorLog "State setup failed: $($_.Exception.Message)";exit 1}
