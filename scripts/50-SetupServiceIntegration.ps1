# 50-SetupServiceIntegration.ps1 - Phase 8 Integration
# Generates composition root to wire singleton services and health checks
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
    Write-StepHeader "Service Integration Setup"
    $rootDir = Join-Path $ProjectRoot 'src'
    New-Item -Path $rootDir -ItemType Directory -Force | Out-Null
    
    # Generate composition root from template
    Write-TemplateFile -TemplateRelPath 'src/compositionRoot.ts.template' `
                      -DestinationPath (Join-Path $rootDir 'compositionRoot.ts')
    
    Write-SuccessLog "compositionRoot.ts generated"
    exit 0
} catch {
    Write-ErrorLog "Service integration setup failed: $($_.Exception.Message)"
    exit 1
} 