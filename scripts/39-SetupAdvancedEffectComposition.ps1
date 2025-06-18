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

 # Interface
 $iface=@"
export interface EffectLayer{ name:string; weight:number; params?:Record<string,unknown> }
"@
export interface IEffectComposerService{
  addLayer(layer:EffectLayer):void
  removeLayer(name:string):void
  play():void
  stop():void
  update(delta:number):void
  dispose():void
}
"@
 Set-Content -Path (Join-Path $interfaces 'IEffectComposerService.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl=@"
import { createServiceLogger } from '@/shared/lib/logger'
"@
import { effectService } from '@/domains/effect/services/effectService'
import type { EffectLayer, IEffectComposerService } from '@/domains/effect/interfaces/IEffectComposerService'

class EffectComposerService implements IEffectComposerService{
 static #instance:EffectComposerService|null=null
 #log=createServiceLogger('EFFECT_COMPOSER')
 #layers:EffectLayer[]=[]
 #running=false
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new EffectComposerService())}
 addLayer(layer:EffectLayer){
  this.#layers.push(layer)
  this.#log.info('Layer added',layer)
 }
 removeLayer(name:string){ this.#layers = this.#layers.filter(l=>l.name!==name) }
 play(){ this.#running=true; this.#log.info('Composer play') }
 stop(){ this.#running=false; this.#log.info('Composer stop') }
 update(delta:number){ if(!this.#running) return; this.#layers.forEach(l=>{ effectService.triggerEffect(l.name,{...l.params,delta,weight:l.weight}) }) }
 dispose(){this.#layers=[];EffectComposerService.#instance=null}
}
export const effectComposerService=EffectComposerService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'effectComposerService.ts') -Value $impl -Encoding UTF8

 Write-SuccessLog "EffectComposerService generated"
 exit 0
}catch{Write-ErrorLog "Effect composition generation failed: $($_.Exception.Message)";exit 1}