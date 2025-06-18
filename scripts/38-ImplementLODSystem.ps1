# 38-ImplementLODSystem.ps1 - Phase 5 Visual Enhancement
# Generates LODService for distance-based rendering optimization
# Reference: script_checklist.md lines 1100-1200
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "LOD System Generation"
 $renderPath=Join-Path $ProjectRoot 'src/domains/rendering'
 $services=Join-Path $renderPath 'services'
 $interfaces=Join-Path $renderPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Interface
 $iface=@'
import type { Object3D } from 'three'
'@
export interface LODConfig{ near:number; far:number; minDetail:number; maxDetail:number }
export interface ILODService{
 register(obj:Object3D,config:LODConfig): void
 update(cameraPosition:{x:number,y:number,z:number}): void
 dispose(): void
}
'@
 Set-Content -Path (Join-Path $interfaces 'ILODService.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl=@'
import { Vector3, Object3D } from 'three'
'@
import { createServiceLogger } from '@/shared/lib/logger'
import type { ILODService, LODConfig } from '@/domains/rendering/interfaces/ILODService'

interface LODEntry{ obj:Object3D; cfg: LODConfig }

class LODService implements ILODService{
 static #instance:LODService|null=null
 #log=createServiceLogger('LOD_SERVICE')
 #entries:LODEntry[]=[]
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new LODService())}
 register(obj:Object3D,config:LODConfig){
  this.#entries.push({obj,cfg:config})
  this.#log.debug('Object registered for LOD',{id:obj.id,config})
 }
 update(camPosLike:{x:number,y:number,z:number}){
  const camPos=new Vector3(camPosLike.x,camPosLike.y,camPosLike.z)
  this.#entries.forEach(e=>{
   const dist=camPos.distanceTo(e.obj.position)
   const t=Math.min(Math.max((dist-e.cfg.near)/(e.cfg.far-e.cfg.near),0),1)
   const detail=e.cfg.maxDetail-(e.cfg.maxDetail-e.cfg.minDetail)*t
   if(e.obj.userData.currentDetail!==detail){
     e.obj.userData.currentDetail=detail
     e.obj.visible=detail>0.1
   }
  })
 }
 dispose(){this.#entries=[];LODService.#instance=null}
}
export const lodService=LODService.getInstance()
'@
 Set-Content -Path (Join-Path $services 'lodService.ts') -Value $impl -Encoding UTF8
 Write-SuccessLog "LODService generated"
 exit 0
}catch{Write-ErrorLog "LOD system generation failed: $($_.Exception.Message)";exit 1}
