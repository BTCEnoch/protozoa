# 48-SetupAdvancedBundleAnalysis.ps1 - Phase 7 Automation
# Generates BundleAnalyzerService and workflow for bundle-size monitoring
# Reference: script_checklist.md lines 1750-1800
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Advanced Bundle Analysis Setup"
 $sharedPath=Join-Path $ProjectRoot 'src/shared'
 $services=Join-Path $sharedPath 'services'
 New-Item -Path $services -ItemType Directory -Force | Out-Null

 # Service implementation
 $impl=@"
import { execSync } from 'child_process'
import { createServiceLogger } from '@/shared/lib/logger'

export class BundleAnalyzerService {
  static #instance: BundleAnalyzerService | null = null
  #log = createServiceLogger('BUNDLE_ANALYZER')

  private constructor() {}

  static getInstance() {
    return this.#instance ?? (this.#instance = new BundleAnalyzerService())
  }

  analyze() {
    this.#log.info('Running webpack-bundle-analyzer')
    execSync('npx webpack --profile --json > stats.json', { stdio: 'inherit' })
    execSync('npx webpack-bundle-analyzer stats.json --mode static --no-open', { stdio: 'inherit' })
  }

  dispose() {
    BundleAnalyzerService.#instance = null
  }
}

export const bundleAnalyzerService = BundleAnalyzerService.getInstance()
"@
 Set-Content -Path (Join-Path $services 'bundleAnalyzerService.ts') -Value $impl -Encoding UTF8

 # GH Actions job append (bundle-analysis)
 $wf=Join-Path $ProjectRoot '.github/workflows/ci.yml'
 if(Test-Path $wf){
  $content=Get-Content $wf -Raw
  if($content -notmatch 'bundle-analysis:'){ # append only once
   $append=@"
  bundle-analysis:
    runs-on: ubuntu-latest
    needs: build-test
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - name: Install deps
        run: pnpm install --frozen-lockfile
      - name: Run bundle analyzer
        run: pnpm ts-node ./src/shared/services/bundleAnalyzerService.ts
      - uses: actions/upload-artifact@v3
        with:
          name: bundle-report
          path: dist/report.html
"@
   Add-Content -Path $wf -Value $append
  }
 }
 Write-SuccessLog "Bundle analysis artifacts generated"
 exit 0
}catch{Write-ErrorLog "Bundle analysis setup failed: $($_.Exception.Message)";exit 1}