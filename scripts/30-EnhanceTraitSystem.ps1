# 30-EnhanceTraitSystem.ps1 - Phase 3 Enhancement
# Enhances TraitService with genetic inheritance and mutation rates
#Reference: script_checklist.md lines 1950-2050
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent))
try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}

try{
 Write-StepHeader "Trait System Enhancement"
 $traitDomain=Join-Path $ProjectRoot 'src/domains/trait'
 $services=Join-Path $traitDomain 'services'
 $enhanceFile=Join-Path $services 'traitEnhancements.ts'

 $content= @"
/**
 * traitEnhancements.ts – Adds genetic inheritance & dynamic mutation logic to TraitService
 */
import { traitService } from '@/domains/trait/services/traitService'
import { rngService } from '@/domains/rng/services/rngService'

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
"@
 Set-Content -Path $enhanceFile -Value $content -Encoding UTF8
 Write-SuccessLog "Trait enhancements added"
 exit 0
}catch{Write-ErrorLog "Trait enhancement failed: $($_.Exception.Message)";exit 1}
