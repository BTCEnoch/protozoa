# 54-SetupPerformanceTesting.ps1 - Phase 8 Testing
# Adds performance Vitest suite and CI job
# Reference: script_checklist.md lines 2150-2200
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Performance Testing Setup"
 $testDir=Join-Path $ProjectRoot 'tests/performance'
 New-Item -Path $testDir -ItemType Directory -Force | Out-Null

 $perfTest=@"import { describe, it, expect } from 'vitest'
import { perfRegressionService as perf } from '@/shared/services/performanceRegressionService'
import { particleService } from '@/domains/particle/services/particleService'

describe('Particle update performance',()=>{
 it('should update 10k particles under 16ms',()=>{
  for(let i=0;i<10000;i++) particleService.createParticle()
  const t=perf.start('update')
  particleService.updateParticles(16)
  perf.end('update',t)
  const duration=perf.report().find(s=>s.label==='update')!.duration
  expect(duration).toBeLessThan(16)
 })
})
"@
 Set-Content -Path (Join-Path $testDir 'particle.perf.test.ts') -Value $perfTest -Encoding UTF8

 # Append CI job
 $ci=Join-Path $ProjectRoot '.github/workflows/ci.yml'
 if(Test-Path $ci){
  $raw=Get-Content $ci -Raw
  if($raw -notmatch 'perf-test:'){
   $append=@"  perf-test:
    runs-on: ubuntu-latest
    needs: build-test
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with: { version: 8 }
      - run: pnpm install --frozen-lockfile
      - run: pnpm vitest run tests/performance --reporter verbose
"@
   Add-Content -Path $ci -Value $append
  }
 }
 Write-SuccessLog "Performance test added"
 exit 0
}catch{Write-ErrorLog "Perf test setup failed: $($_.Exception.Message)";exit 1}