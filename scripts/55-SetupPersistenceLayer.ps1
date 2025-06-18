# 55-SetupPersistenceLayer.ps1 - Phase 8 Persistence
# Generates PersistenceService for organism lineage tracking
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
    Write-StepHeader "Persistence Layer Setup"
    $domain = Join-Path $ProjectRoot 'src/shared'
    $services = Join-Path $domain 'services'
    $interfaces = Join-Path $domain 'interfaces'
    New-Item -Path $services -ItemType Directory -Force | Out-Null
    New-Item -Path $interfaces -ItemType Directory -Force | Out-Null

    # Create interface
    $ifaceContent = 'export interface IPersistenceService { save(key: string, value: unknown): Promise<void>; load<T=unknown>(key: string): Promise<T|null>; dispose(): void; }'
    Set-Content -Path (Join-Path $interfaces 'IPersistenceService.ts') -Value $ifaceContent -Encoding UTF8

    # Create implementation
    $implContent = 'export class PersistenceService { static getInstance() { return new PersistenceService() } async save(key: string, value: unknown) { localStorage.setItem(key, JSON.stringify(value)) } async load<T=unknown>(key: string): Promise<T|null> { const item = localStorage.getItem(key); return item ? JSON.parse(item) : null } dispose() {} }'
    Set-Content -Path (Join-Path $services 'persistenceService.ts') -Value $implContent -Encoding UTF8
    
    Write-SuccessLog "PersistenceService generated"
    exit 0
} catch {
    Write-ErrorLog "Persistence setup failed: $($_.Exception.Message)"
    exit 1
} 