/**
 * traitEnhancements.ts – Adds genetic inheritance & dynamic mutation logic to TraitService
 */
import { rngService } from '@/domains/rng/services/rngService'
import { traitService } from '@/domains/trait/services/traitService'

export function inheritTraits(parentA:any,parentB:any){
 const child:any={}
 for(const cat in parentA){
  child[cat]={}
  for(const key in parentA[cat]){
   // 50/50 inherit then possible mutation
   child[cat][key]= rngService.random()<0.5? parentA[cat][key]:parentB[cat][key]
   child[cat][key]= maybeMutate(key,child[cat][key])
  }
 }
 return child
}

function maybeMutate(trait:string,value:any){
 const difficultyInfluence=1//placeholder for block difficulty influence
 const rate=0.01*difficultyInfluence
 if(rngService.random()<rate){
   return traitService.mutateTrait(trait,value)
 }
 return value
}
