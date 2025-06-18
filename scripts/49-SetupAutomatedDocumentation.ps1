# 49-SetupAutomatedDocumentation.ps1 - Phase 7 Automation
# Generates TypeDoc configuration, doc generator script, and GH Actions docs workflow
# Reference: script_checklist.md lines 1800-1850
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Automated Documentation Setup"
 # typedoc.json
 $typedoc= @"
{
  "entryPoints": ["src/index.ts"],
  "out": "docs/api",
  "excludePrivate": true,
  "excludeProtected": true,
  "hideGenerator": true,
  "tsconfig": "tsconfig.json"
}
"@
 Set-Content -Path (Join-Path $ProjectRoot 'typedoc.json') -Value $typedoc -Encoding UTF8

 # doc generation script
 $gen= @"
import { spawnSync } from 'child_process'
console.log('Generating TypeDoc...')
spawnSync('npx', ['typedoc'], { stdio: 'inherit' })
"@
 New-Item -Path (Join-Path $ProjectRoot 'scripts') -ItemType Directory -Force | Out-Null
 Set-Content -Path (Join-Path $ProjectRoot 'scripts/generateDocs.ts') -Value $gen -Encoding UTF8

 # GH Actions workflow
 $wfPath=Join-Path $ProjectRoot '.github/workflows'
 New-Item -Path $wfPath -ItemType Directory -Force | Out-Null
 $docs= @'
name: Docs
on:
  push:
    branches: [main]
    paths: [ 'src/**', 'typedoc.json' ]

jobs:
  build-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with: { version: 8 }
      - name: Install deps
        run: pnpm install --frozen-lockfile
      - name: Generate docs
        run: pnpm ts-node scripts/generateDocs.ts
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ">${{ secrets.GITHUB_TOKEN }}"
          publish_dir: ./docs/api
'@
 Set-Content -Path (Join-Path $wfPath 'docs.yml') -Value $docs -Encoding UTF8

 Write-SuccessLog "Automated documentation artifacts generated"
 exit 0
}catch{Write-ErrorLog "Docs setup failed: $($_.Exception.Message)";exit 1}
