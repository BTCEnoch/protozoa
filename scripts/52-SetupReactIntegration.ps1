# 52-SetupReactIntegration.ps1 - Phase 8 UI
# Sets up React components for simulation canvas and control UI
#Requires -Version 5.1
[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path $PSScriptRoot -Parent))
try{Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop}catch{Write-Error $_;exit 1}
$ErrorActionPreference='Stop'
try{
 Write-StepHeader "React Integration Setup"
 $compDir=Join-Path $ProjectRoot 'src/components'
 New-Item -Path $compDir -ItemType Directory -Force | Out-Null

 Write-TemplateFile -TemplateRelPath 'components/SimulationCanvas.tsx.template' `
                   -DestinationPath (Join-Path $compDir 'SimulationCanvas.tsx')

 Write-TemplateFile -TemplateRelPath 'components/App.tsx.template' `
                   -DestinationPath (Join-Path $compDir 'App.tsx')

 Write-SuccessLog "React components generated"
 exit 0
}catch{Write-ErrorLog "React integration failed: $($_.Exception.Message)";exit 1}
