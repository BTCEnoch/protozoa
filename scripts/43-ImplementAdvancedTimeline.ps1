# 43-ImplementAdvancedTimeline.ps1 - Phase 6 Enhancement
# Creates TimelineService for complex animation sequencing
# Reference: script_checklist.md lines 2150-2200
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference="Stop"

try{
 Write-StepHeader "Advanced Timeline Service Generation"
 $animPath=Join-Path $ProjectRoot 'src/domains/animation'
 $services=Join-Path $animPath 'services'
 $interfaces=Join-Path $animPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Interface
 $iface=@"export interface Keyframe{ time:number; action:()=>void }
export interface ITimelineService{
  addKeyframe(frame:Keyframe):void
  play():void
  pause():void
  seek(time:number):void
  update(delta:number):void
  dispose():void
}
"@
 Set-Content -Path (Join-Path $interfaces 'ITimelineService.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl=@"import { createServiceLogger } from '@/shared/lib/logger'
import type { ITimelineService, Keyframe } from '@/domains/animation/interfaces/ITimelineService'

class TimelineService implements ITimelineService{
 static #instance:TimelineService|null=null
 #log=createServiceLogger('TIMELINE')
 #frames:Keyframe[]=[]
 #time=0
 #running=false
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new TimelineService())}
 addKeyframe(frame:Keyframe){ this.#frames.push(frame); this.#frames.sort((a,b)=>a.time-b.time) }
 play(){ this.#running=true; this.#log.info('Timeline play') }
 pause(){ this.#running=false; this.#log.info('Timeline pause') }
 seek(t:number){ this.#time=t; this.#log.debug('Timeline seek',{t}) }
 update(delta:number){if(!this.#running) return; this.#time+=delta; while(this.#frames.length && this.#frames[0].time<=this.#time){ const f=this.#frames.shift()!; try{f.action()}catch(e){this.#log.error('Keyframe error',e)} }}
 dispose(){this.#frames=[];TimelineService.#instance=null}
}
export const timelineService=TimelineService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'timelineService.ts') -Value $impl -Encoding UTF8
 Write-SuccessLog "TimelineService generated"
 exit 0
}catch{Write-ErrorLog "Timeline generation failed: $($_.Exception.Message)";exit 1}