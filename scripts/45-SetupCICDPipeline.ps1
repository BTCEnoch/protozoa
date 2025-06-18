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

 # Generate workflows from templates
 Write-TemplateFile -TemplateRelPath '.github/workflows/ci.yml.template' `
                   -DestinationPath (Join-Path $wfPath 'ci.yml')

 Write-TemplateFile -TemplateRelPath '.github/workflows/deploy.yml.template' `
                   -DestinationPath (Join-Path $wfPath 'deploy.yml')

 Write-TemplateFile -TemplateRelPath '.github/workflows/release.yml.template' `
                   -DestinationPath (Join-Path $wfPath 'release.yml')

 Write-SuccessLog "GitHub Actions workflows created"
 exit 0
}catch{Write-ErrorLog "CI/CD setup failed: $($_.Exception.Message)";exit 1}
