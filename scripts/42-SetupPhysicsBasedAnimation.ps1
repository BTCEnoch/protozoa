# 42-SetupPhysicsBasedAnimation.ps1 - Phase 6 Enhancement
# Generates PhysicsAnimationService integrating physics constraints with animations
# Reference: script_checklist.md lines 1500-1550
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Physics-Based Animation Service Generation"
 $animPath=Join-Path $ProjectRoot 'src/domains/animation'
 $services=Join-Path $animPath 'services'
 $interfaces=Join-Path $animPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Interface
 $iface= @"
export interface IPhysicsAnimationService{
  addSpring(particleId:string,anchor:{x:number,y:number,z:number},k:number,damper:number):void
  update(delta:number):void
  dispose():void
}
"@
 Set-Content -Path (Join-Path $interfaces 'IPhysicsAnimationService.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl= @"
import { createServiceLogger } from '@/shared/lib/logger'
import { particleService } from '@/domains/particle/services/particleService'
import type { IPhysicsAnimationService } from '@/domains/animation/interfaces/IPhysicsAnimationService'

interface Spring{ pid:string; anchor:{x:number,y:number,z:number}; k:number; d:number; }

class PhysicsAnimationService implements IPhysicsAnimationService{
 static #instance:PhysicsAnimationService|null=null
 #log=createServiceLogger('PHYS_ANIM')
 #springs:Spring[]=[]
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new PhysicsAnimationService())}
 addSpring(particleId:string,anchor:{x:number,y:number,z:number},k:number,damper:number){
  this.#springs.push({pid:particleId,anchor,k,d:damper})
 }
 update(delta:number){
  this.#springs.forEach(s=>{
   const p=particleService.getParticleById(s.pid)
   if(!p) return
   const dx=s.anchor.x-p.position.x
   const dy=s.anchor.y-p.position.y
   const dz=s.anchor.z-p.position.z
   const fx=dx*s.k - p.velocity.x*s.d
   const fy=dy*s.k - p.velocity.y*s.d
   const fz=dz*s.k - p.velocity.z*s.d
   // naive Euler update
   p.velocity.x+=fx*delta/1000
   p.velocity.y+=fy*delta/1000
   p.velocity.z+=fz*delta/1000
  })
 }
 dispose(){this.#springs=[];PhysicsAnimationService.#instance=null}
}
export const physicsAnimationService=PhysicsAnimationService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'physicsAnimationService.ts') -Value $impl -Encoding UTF8
 Write-SuccessLog "PhysicsAnimationService generated"
 exit 0
}catch{Write-ErrorLog "Physics-based animation generation failed: $($_.Exception.Message)";exit 1}
