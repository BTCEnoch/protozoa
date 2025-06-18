# 56-SetupEndToEndValidation.ps1 - Phase 8 Validation
# Sets up Playwright e2e tests and CI job
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))
try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "End-to-End Validation Setup"
 $e2eDir=Join-Path $ProjectRoot 'tests/e2e'
 New-Item -Path $e2eDir -ItemType Directory -Force | Out-Null
 # sample test
 $test= @"
import { test, expect } from '@playwright/test'

test('organism creation flow',async({ page })=>{
  await page.goto('http://localhost:3000')
  await page.waitForSelector('canvas')
  expect(await page.locator('canvas').count()).toBe(1)
})
"@
 Set-Content -Path (Join-Path $e2eDir 'organism.spec.ts') -Value $test -Encoding UTF8
 # playwright config
 $cfg= @"
import { defineConfig } from '@playwright/test'
export default defineConfig({ use:{ headless:true, baseURL:'http://localhost:3000' } })
"@
 Set-Content -Path (Join-Path $ProjectRoot 'playwright.config.ts') -Value $cfg -Encoding UTF8

 # add CI job
 $ci=Join-Path $ProjectRoot '.github/workflows/ci.yml'
 if(Test-Path $ci){
  $raw=Get-Content $ci -Raw
  if($raw -notmatch 'e2e-test:'){
   $append= @"
  e2e-test:
    runs-on: ubuntu-latest
    needs: build-test
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with: { version: 8 }
      - run: pnpm install --frozen-lockfile
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps
      - name: Run e2e tests
        run: pnpm playwright test
"@
   Add-Content -Path $ci -Value $append
  }
 }
 Write-SuccessLog "E2E validation setup complete"
 exit 0
}catch{Write-ErrorLog "E2E setup failed: $($_.Exception.Message)";exit 1}
