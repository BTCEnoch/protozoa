# 49-SetupAutomatedDocumentation.ps1 - Phase 7 Automation
# Generates TypeDoc configuration, doc generator script, and GH Actions docs workflow
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
    Write-StepHeader "Automated Documentation Setup"
    
    # Create simple typedoc.json
    $typedocConfig = '{ "entryPoints": ["src/index.ts"], "out": "docs/api", "excludePrivate": true }'
    Set-Content -Path (Join-Path $ProjectRoot 'typedoc.json') -Value $typedocConfig -Encoding UTF8

    # Create doc generation script
    $genScript = 'console.log("Generating TypeDoc..."); import("child_process").then(cp => cp.spawnSync("npx", ["typedoc"], { stdio: "inherit" }))'
    New-Item -Path (Join-Path $ProjectRoot 'scripts') -ItemType Directory -Force | Out-Null
    Set-Content -Path (Join-Path $ProjectRoot 'scripts/generateDocs.ts') -Value $genScript -Encoding UTF8

    # Create GitHub Actions workflow directory
    $wfPath = Join-Path $ProjectRoot '.github/workflows'
    New-Item -Path $wfPath -ItemType Directory -Force | Out-Null
    
    # Create simple workflow file
    $workflow = 'name: Docs
on:
  push:
    branches: [main]
jobs:
  build-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm run docs'
    Set-Content -Path (Join-Path $wfPath 'docs.yml') -Value $workflow -Encoding UTF8

    Write-SuccessLog "Automated documentation artifacts generated"
    exit 0
} catch {
    Write-ErrorLog "Docs setup failed: $($_.Exception.Message)"
    exit 1
} 