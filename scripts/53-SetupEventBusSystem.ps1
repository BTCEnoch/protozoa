# 53-SetupEventBusSystem.ps1 - Phase 8 Integration
# Generates EventBus singleton for cross-domain communication
# Reference: script_checklist.md lines 2100-2150
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "EventBus System Setup"
 $sharedPath=Join-Path $ProjectRoot 'src/shared'
 $services=Join-Path $sharedPath 'services'
 $interfaces=Join-Path $sharedPath 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Interface
 $iface=@"
import { EventEmitter } from 'events'
"@
export interface IEventBus extends EventEmitter {
  emitEvent(event:string,payload?:unknown):void
}
"@
 Set-Content -Path (Join-Path $interfaces 'IEventBus.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl=@"
import { EventEmitter } from 'events'
"@
import { createServiceLogger } from '@/shared/lib/logger'
import type { IEventBus } from '@/shared/interfaces/IEventBus'

class EventBus extends EventEmitter implements IEventBus{
 static #instance:EventBus|null=null
 #log=createServiceLogger('EVENT_BUS')
 private constructor(){super()}
 static getInstance(){return this.#instance??(this.#instance=new EventBus())}
 emitEvent(event:string,payload?:unknown){ this.emit(event,payload); this.#log.debug('Event emitted',{event}) }
}
export const eventBus=EventBus.getInstance()
"@
 Set-Content -Path (Join-Path $services 'eventBus.ts') -Value $impl -Encoding UTF8
 Write-SuccessLog "EventBus generated"
 exit 0
}catch{Write-ErrorLog "EventBus setup failed: $($_.Exception.Message)";exit 1}