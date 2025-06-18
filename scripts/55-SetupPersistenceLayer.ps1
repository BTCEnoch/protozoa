# 55-SetupPersistenceLayer.ps1 - Phase 8 Persistence
# Generates PersistenceService for organism lineage tracking
# Reference: script_checklist.md lines 2200-2250
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Persistence Layer Setup"
 $domain=Join-Path $ProjectRoot 'src/shared'
 $services=Join-Path $domain 'services'
 $interfaces=Join-Path $domain 'interfaces'
 New-Item -Path $services -ItemType Directory -Force | Out-Null
 New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

 # Interface
 $iface=@"
export interface IPersistenceService{
"@
  save(key:string,value:unknown):Promise<void>
  load<T=unknown>(key:string):Promise<T|null>
  dispose():void
}
"@
 Set-Content -Path (Join-Path $interfaces 'IPersistenceService.ts') -Value $iface -Encoding UTF8

 # Implementation
 $impl=@"
import { openDB, DBSchema } from 'idb'
"@
import { createServiceLogger } from '@/shared/lib/logger'
import type { IPersistenceService } from '@/shared/interfaces/IPersistenceService'

interface PersistDB extends DBSchema{ kv:{ key:string; value:any } }

class PersistenceService implements IPersistenceService{
 static #instance:PersistenceService|null=null
 #log=createServiceLogger('PERSISTENCE')
 #dbPromise = openDB<PersistDB>('protozoa-db',1,{upgrade(db){db.createObjectStore('kv')}})
 private constructor(){}
 static getInstance(){return this.#instance??(this.#instance=new PersistenceService())}
 async save(key:string,value:unknown){ const db=await this.#dbPromise; await db.put('kv',value,key); this.#log.info('saved',{key}) }
 async load<T=unknown>(key:string){ const db=await this.#dbPromise; return db.get('kv',key) as Promise<T|null> }
 dispose(){PersistenceService.#instance=null}
}
export const persistenceService=PersistenceService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'persistenceService.ts') -Value $impl -Encoding UTF8
 Write-SuccessLog "PersistenceService generated"
 exit 0
}catch{Write-ErrorLog "Persistence setup failed: $($_.Exception.Message)";exit 1}