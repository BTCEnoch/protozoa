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

 # interface
 $iface= @"
export interface ILifecycleEngine{
  birth(count:number): void
  update(delta:number): void
  kill(id:string): void
  dispose():void
}
"@
 Set-Content -Path (Join-Path $particlePath 'interfaces\ILifecycleEngine.ts') -Value $iface -Encoding UTF8

 # implementation
 $impl= @"
import { particleService } from '@/domains/particle/services/particleService'
import { createServiceLogger } from '@/shared/lib/logger'
import type { ILifecycleEngine } from '@/domains/particle/interfaces/ILifecycleEngine'
export class LifecycleEngine implements ILifecycleEngine{
 static #instance:LifecycleEngine|null=null
 #log=createServiceLogger('LIFECYCLE')
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new LifecycleEngine())}
 birth(count:number){
  for(let i=0;i<count;i++) particleService.createParticle()
  this.#log.info('Particles birthed',{count})
 }
 update(delta:number){particleService.updateParticles(delta)}
 kill(id:string){/* remove from service */}
 dispose(){LifecycleEngine.#instance=null}
}
export const lifecycleEngine=LifecycleEngine.getInstance()
"@
 Set-Content -Path (Join-Path $services 'lifecycleEngine.ts') -Value $impl -Encoding UTF8
 Write-SuccessLog "LifecycleEngine generated"
 exit 0
}catch{Write-ErrorLog "Lifecycle setup failed: $($_.Exception.Message)";exit 1}
