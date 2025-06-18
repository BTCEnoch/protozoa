# 50-SetupServiceIntegration.ps1 - Phase 8 Integration
# Generates composition root to wire singleton services and health checks
# Reference: script_checklist.md lines 1950-2000
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Service Integration Setup"
 $rootDir=Join-Path $ProjectRoot 'src'
 New-Item -Path $rootDir -ItemType Directory -Force | Out-Null
 $comp=@"
// compositionRoot.ts – initializes all domain singletons and wires dependencies
"@
import { rngService } from '@/domains/rng/services/rngService'
import { bitcoinService } from '@/domains/bitcoin/services/bitcoinService'
import { traitService } from '@/domains/trait/services/traitService'
import { physicsService } from '@/domains/physics/services/physicsService'
import { particleService } from '@/domains/particle/services/particleService'
import { formationService } from '@/domains/formation/services/formationService'
import { renderingService } from '@/domains/rendering/services/renderingService'
import { effectService } from '@/domains/effect/services/effectService'
import { animationService } from '@/domains/animation/services/animationService'
import { groupService } from '@/domains/group/services/groupService'
import { lifecycleEngine } from '@/domains/particle/services/lifecycleEngine'

export function initServices(){
  // configure cross dependencies
  traitService.configureDependencies(rngService, bitcoinService)
  particleService.configureDependencies(physicsService, renderingService)
  groupService.configure(rngService)
  renderingService.initialize(document.getElementById('canvas') as HTMLCanvasElement,{formation:formationService,effect:effectService})
  // any other setup
  console.info('Services initialized')
}

export function disposeServices(){
  renderingService.dispose(); physicsService.dispose(); traitService.dispose();
  effectService.dispose(); animationService.dispose(); groupService.dispose();
  lifecycleEngine.dispose();
}

if(typeof window!=='undefined'){(window as any).initServices=initServices}
"@
 Set-Content -Path (Join-Path $rootDir 'compositionRoot.ts') -Value $comp -Encoding UTF8
 Write-SuccessLog "compositionRoot.ts generated"
 exit 0
}catch{Write-ErrorLog "Service integration setup failed: $($_.Exception.Message)";exit 1}