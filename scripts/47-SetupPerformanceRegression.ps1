# 47-SetupPerformanceRegression.ps1 - Phase 7 Automation
# Generates PerformanceRegressionService and benchmark script
# Reference: script_checklist.md lines 1700-1750
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Performance Regression Setup"
 $sharedPath=Join-Path $ProjectRoot 'src/shared'
 $services=Join-Path $sharedPath 'services'
 $benchDir=Join-Path $ProjectRoot 'benchmarks'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $benchDir -ItemType Directory -Force | Out-Null

 # Service
 $impl=@"import { performance } from 'perf_hooks'
import { createServiceLogger } from '@/shared/lib/logger'

export interface PerfSample{ label:string; duration:number }

export class PerformanceRegressionService{
 static #instance:PerformanceRegressionService|null=null
 #log=createServiceLogger('PERF_REGRESSION')
 #samples:PerfSample[]=[]
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new PerformanceRegressionService())}
 start(label:string){return performance.now()}
 end(label:string,startTime:number){const d=performance.now()-startTime;this.#samples.push({label,duration:d});}
 report(){
  this.#log.info('Performance samples',this.#samples)
  return this.#samples
 }
 dispose(){this.#samples=[];PerformanceRegressionService.#instance=null}
}
export const perfRegressionService=PerformanceRegressionService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'performanceRegressionService.ts') -Value $impl -Encoding UTF8

 # Benchmark script
 $bench=@"import { perfRegressionService as perf } from '@/shared/services/performanceRegressionService'

async function heavyOperation(){
 let sum=0
 for(let i=0;i<1e6;i++) sum+=i
 return sum
}
(async()=>{
 const t=perf.start('heavy-op')
 await heavyOperation()
 perf.end('heavy-op',t)
 console.log(perf.report())
})()
"@
 Set-Content -Path (Join-Path $benchDir 'benchmark.ts') -Value $bench -Encoding UTF8

 Write-SuccessLog "Performance regression artifacts generated"
 exit 0
}catch{Write-ErrorLog "Perf regression setup failed: $($_.Exception.Message)";exit 1}