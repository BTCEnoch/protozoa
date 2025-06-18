# 56-SetupEndToEndValidation.ps1 - Phase 8 Validation
# Sets up Playwright e2e tests and CI job
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
} catch {
    Write-Error $_
    exit 1
}

$ErrorActionPreference = 'Stop'

try {
    Write-StepHeader "End-to-End Validation Setup"
    $e2eDir = Join-Path $ProjectRoot 'tests/e2e'
    New-Item -Path $e2eDir -ItemType Directory -Force | Out-Null
    
    # Create simple test file
    $testContent = 'import { test, expect } from "@playwright/test"; test("organism creation", async ({ page }) => { await page.goto("http://localhost:3000"); await page.waitForSelector("canvas"); expect(await page.locator("canvas").count()).toBe(1); });'
    Set-Content -Path (Join-Path $e2eDir 'organism.spec.ts') -Value $testContent -Encoding UTF8
    
    # Create playwright config
    $configContent = 'import { defineConfig } from "@playwright/test"; export default defineConfig({ use: { headless: true, baseURL: "http://localhost:3000" } });'
    Set-Content -Path (Join-Path $ProjectRoot 'playwright.config.ts') -Value $configContent -Encoding UTF8

    # Create GitHub workflows directory
    $wfPath = Join-Path $ProjectRoot '.github/workflows'
    New-Item -Path $wfPath -ItemType Directory -Force | Out-Null
    
    # Create simple CI workflow
    $ciContent = 'name: E2E Tests
on: [push]
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npx playwright install
      - run: npm run test:e2e'
    Set-Content -Path (Join-Path $wfPath 'e2e.yml') -Value $ciContent -Encoding UTF8

    Write-SuccessLog "E2E validation setup complete"
    exit 0
} catch {
    Write-ErrorLog "E2E setup failed: $($_.Exception.Message)"
    exit 1
} 