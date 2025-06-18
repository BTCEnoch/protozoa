import type { ILODService, LODConfig } from '@/domains/rendering/interfaces/ILODService';
import { createServiceLogger } from '@/shared/lib/logger';
import { Object3D, Vector3 } from 'three';

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
