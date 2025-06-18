import type { ISwarmService } from '@/domains/group/interfaces/ISwarmService'
import { groupService } from '@/domains/group/services/groupService'
import { createServiceLogger } from '@/shared/lib/logger'

export class SwarmService implements ISwarmService{
 static #instance:SwarmService|null=null
 #log=createServiceLogger('SWARM')
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new SwarmService())}
 update(delta:number){
  // simple flocking placeholder: iterate groups
  groupService['#groups']?.forEach((g:any)=>{
   // pretend to adjust positions
  })
  this.#log.debug('Swarm update', {delta})
 }
 dispose(){SwarmService.#instance=null}
}
export const swarmService=SwarmService.getInstance()
