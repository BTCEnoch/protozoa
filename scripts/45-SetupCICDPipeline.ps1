# 45-SetupCICDPipeline.ps1 - Phase 7 Automation
# Generates GitHub Actions CI workflow and supporting scripts
# Reference: script_checklist.md lines 1215-1240
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "CI/CD Pipeline Setup"
 $wfPath=Join-Path $ProjectRoot '.github/workflows'
 New-Item -Path $wfPath -ItemType Directory -Force | Out-Null

 $ci=@'
name: CI
'@

on:
  pull_request:
  push:
    branches: [main]

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - name: Install deps
        run: pnpm install --frozen-lockfile
      - name: Lint
        run: pnpm eslint . --max-warnings=0
      - name: Type Check
        run: pnpm tsc --noEmit
      - name: Unit Tests
        run: pnpm vitest run --coverage
      - name: Validate Scripts
        run: pwsh ./scripts/VerifyCompliance.ps1
      - name: Bundle Size
        run: pnpm webpack --profile --json > stats.json
      - uses: actions/upload-artifact@v3
        with:
          name: bundle-stats
          path: stats.json
'@
 Set-Content -Path (Join-Path $wfPath 'ci.yml') -Value $ci -Encoding UTF8
 Write-SuccessLog "GitHub Actions workflow created"
 exit 0
}catch{Write-ErrorLog "CI/CD setup failed: $($_.Exception.Message)";exit 1}
