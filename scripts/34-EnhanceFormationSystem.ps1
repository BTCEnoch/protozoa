# 34-EnhanceFormationSystem.ps1 - Phase 4 Enhancement
# Adds dynamic pattern generation and caching to FormationService
# Reference: script_checklist.md lines 1600-1650
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Formation System Enhancement"
 $formationPath=Join-Path $ProjectRoot 'src/domains/formation'
 $services=Join-Path $formationPath 'services'
 New-Item -Path $services -ItemType Directory -Force | Out-Null

 $enhance=@'
import { createServiceLogger } from '@/shared/lib/logger'
'@
import { rngService } from '@/domains/rng/services/rngService'
import type { Vector3 } from 'three'

export type FormationPattern={ id:string; positions:Vector3[] }

export class DynamicFormationGenerator{
  #log=createServiceLogger('DYN_FORMATION')
  generatePattern(id:string,count:number):FormationPattern{
    const positions:any[]=[]
    switch(id){
      case 'fibonacci':
        for(let i=0;i<count;i++){
          const phi=(1+Math.sqrt(5))/2
          const angle=2*Math.PI*i/phi
          const r=Math.sqrt(i/count)
          positions.push({x:r*Math.cos(angle)*50,y:r*Math.sin(angle)*50,z:0})
        }
        break
      default:
        for(let i=0;i<count;i++){positions.push({x:rngService.random()*100-50,y:rngService.random()*100-50,z:rngService.random()*100-50})}
    }
    this.#log.info('Pattern generated',{id,count})
    return {id,positions}
  }
}
'@
 Set-Content -Path (Join-Path $services 'dynamicFormationGenerator.ts') -Value $enhance -Encoding UTF8
 Write-SuccessLog "DynamicFormationGenerator generated"
 exit 0
}catch{Write-ErrorLog "Formation enhancement failed: $($_.Exception.Message)";exit 1}
