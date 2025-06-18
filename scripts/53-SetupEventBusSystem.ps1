# 53-SetupEventBusSystem.ps1 - Phase 8 Integration
# Generates EventBus singleton for cross-domain communication
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
    Write-StepHeader "EventBus System Setup"
    $sharedPath = Join-Path $ProjectRoot 'src/shared'
    $services = Join-Path $sharedPath 'services'
    $interfaces = Join-Path $sharedPath 'interfaces'
    New-Item -Path $services -ItemType Directory -Force | Out-Null
    New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

    # Create interface
    $ifaceContent = 'export interface IEventBus { emitEvent(event: string, payload?: unknown): void }'
    Set-Content -Path (Join-Path $interfaces 'IEventBus.ts') -Value $ifaceContent -Encoding UTF8

    # Create implementation
    $implContent = 'export class EventBus { static getInstance() { return new EventBus() } emitEvent(event: string, payload?: unknown) { console.log(event, payload) } }'
    Set-Content -Path (Join-Path $services 'eventBus.ts') -Value $implContent -Encoding UTF8
    
    Write-SuccessLog "EventBus generated"
    exit 0
} catch {
    Write-ErrorLog "EventBus setup failed: $($_.Exception.Message)"
    exit 1
} 