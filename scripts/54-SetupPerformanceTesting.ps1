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

 Write-TemplateFile -TemplateRelPath 'tests/performance/particle.perf.test.ts.template' `
                   -DestinationPath (Join-Path $testDir 'particle.perf.test.ts')

 # Append CI job
 $ci=Join-Path $ProjectRoot '.github/workflows/ci.yml'
 if(Test-Path $ci){
  $raw=Get-Content $ci -Raw
  if($raw -notmatch 'perf-test:'){
   $append= @"
  perf-test:
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
