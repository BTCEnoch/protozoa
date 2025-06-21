# 26-GenerateBitcoinService.ps1 - Phase 3 Data & Blockchain Integration
# Generates complete BitcoinService with API integration and LRU caching
# ARCHITECTURE: Singleton pattern with retry logic and environment-aware endpoints
# Reference: script_checklist.md lines 26-GenerateBitcoinService.ps1
# Reference: build_design.md lines 850-1050 - Bitcoin service implementation and caching
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = $PWD
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "Bitcoin Service Generation - Phase 3 Data & Blockchain Integration"
    Write-InfoLog "Generating complete BitcoinService with API integration and LRU caching"

    # Define paths
    $bitcoinDomainPath = Join-Path $ProjectRoot "src/domains/bitcoin"
    $servicesPath = Join-Path $bitcoinDomainPath "services"
    $typesPath = Join-Path $bitcoinDomainPath "types"
    $interfacesPath = Join-Path $bitcoinDomainPath "interfaces"
    $utilsPath = Join-Path $bitcoinDomainPath "utils"

    # Ensure directories exist
    Write-InfoLog "Creating Bitcoin domain directory structure"
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $typesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $utilsPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "Bitcoin domain directories created successfully"

    # Generate IBitcoinService interface from template
    Write-InfoLog "Generating IBitcoinService interface from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/bitcoin/interfaces/IBitcoinService.ts.template"
    $outputPath = Join-Path $interfacesPath "IBitcoinService.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "IBitcoinService interface generated successfully"

    # Generate Bitcoin types from template
    Write-InfoLog "Generating Bitcoin types definitions from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/bitcoin/types/bitcoin.types.ts.template"
    $outputPath = Join-Path $typesPath "bitcoin.types.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "Bitcoin types generated successfully"

    # Generate BlockInfo types from template
    Write-InfoLog "Generating BlockInfo types from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/bitcoin/types/blockInfo.types.ts.template"
    $outputPath = Join-Path $typesPath "blockInfo.types.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "BlockInfo types generated successfully"

    # Generate BitcoinService implementation from template
    Write-InfoLog "Generating BitcoinService implementation from template"
    $templatePath = Join-Path $ProjectRoot "templates/domains/bitcoin/services/BitcoinService.ts.template"
    $outputPath = Join-Path $servicesPath "BitcoinService.ts"
    Copy-Item -Path $templatePath -Destination $outputPath -Force
    Write-SuccessLog "BitcoinService implementation generated successfully"

    # Generate export index file
    Write-InfoLog "Generating Bitcoin domain export index"
    $indexContent = @'
/**
 * @fileoverview Bitcoin Domain Exports
 * @description Main export file for Bitcoin domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { BitcoinService, bitcoinService } from "./services/BitcoinService";

// Interface exports
export type {
  IBitcoinService,
  BitcoinConfig,
  BlockInfo,
  InscriptionContent,
  ApiResponse,
  CacheStats,
  BitcoinMetrics
} from "./interfaces/IBitcoinService";

// Type exports
export type {
  ApiEnvironment,
  HttpMethod,
  CacheEntry,
  LRUCache,
  RetryConfig,
  RequestOptions,
  ApiErrorType,
  ApiError
} from "./types/bitcoin.types";
'@

    Set-Content -Path (Join-Path $bitcoinDomainPath "index.ts") -Value $indexContent -Encoding UTF8
    Write-SuccessLog "Bitcoin domain export index generated successfully"

    Write-SuccessLog "Bitcoin Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/bitcoin/interfaces/IBitcoinService.ts"
    Write-InfoLog "  - src/domains/bitcoin/types/bitcoin.types.ts"
    Write-InfoLog "  - src/domains/bitcoin/types/blockInfo.types.ts"
    Write-InfoLog "  - src/domains/bitcoin/services/BitcoinService.ts"
    Write-InfoLog "  - src/domains/bitcoin/index.ts"

    exit 0
}
catch {
    Write-ErrorLog "Bitcoin Service generation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 