import type { IPhysicsAnimationService } from '@/domains/animation/interfaces/IPhysicsAnimationService';
import { particleService } from '@/domains/particle/services/particleService';
import { createServiceLogger } from '@/shared/lib/logger';

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
