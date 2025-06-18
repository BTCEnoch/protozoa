# 46-SetupDockerDeployment.ps1 - Phase 7 Automation
# Generates Dockerfile, .dockerignore and GH Actions deploy workflow
# Reference: script_checklist.md lines 1410-1450
#Requires -Version 5.1

[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))

try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'

try{
 Write-StepHeader "Docker Deployment Setup"
 # Generate Docker artifacts from templates
 Write-TemplateFile -TemplateRelPath 'docker/Dockerfile.template' `
                   -DestinationPath (Join-Path $ProjectRoot 'Dockerfile')

 Write-TemplateFile -TemplateRelPath 'docker/.dockerignore.template' `
                   -DestinationPath (Join-Path $ProjectRoot '.dockerignore')

 $wfPath = Join-Path $ProjectRoot '.github/workflows'
 New-Item -Path $wfPath -ItemType Directory -Force | Out-Null

 Write-TemplateFile -TemplateRelPath '.github/workflows/docker-publish.yml.template' `
                   -DestinationPath (Join-Path $wfPath 'docker-publish.yml')

 Write-SuccessLog "Docker deployment artifacts generated"
 exit 0
}catch{Write-ErrorLog "Docker setup failed: $($_.Exception.Message)";exit 1}
