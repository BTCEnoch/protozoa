# 29-SetupDataValidationLayer.ps1 - Phase 3 Enhancement
# Generates DataValidationService to validate bitcoin block data and inscriptions
# Reference: script_checklist.md | build_design.md lines 1700-1800
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$false)]
  [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try { Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop } catch { Write-Error $_; exit 1 }
$ErrorActionPreference="Stop"

try {
  Write-StepHeader "Data Validation Layer Setup - Phase 3 Enhancement"
  $validationDomainPath = Join-Path $ProjectRoot "src/domains/bitcoin"
  $services = Join-Path $validationDomainPath "services"
  $interfaces = Join-Path $validationDomainPath "interfaces"
  New-Item -Path $services -ItemType Directory -Force | Out-Null
  New-Item -Path $interfaces -ItemType Directory -Force | Out-Null
  
  # Interface
  $iface = @'
/**
'@
* IDataValidationService – validates block info, inscriptions and merkle proofs.
*/
export interface IDataValidationService {
  validateBlockInfo(data: unknown): boolean
  validateInscription(content: string): boolean
  verifyMerkleProof(txId: string, proof: string[]): boolean
  dispose(): void
}
'@
  Set-Content -Path (Join-Path $interfaces "IDataValidationService.ts") -Value $iface -Encoding UTF8

  # Implementation
  $impl = @'
import { createServiceLogger, createErrorLogger } from '@/shared/lib/logger'
'@
import type { IDataValidationService } from '@/domains/bitcoin/interfaces/IDataValidationService'

export class DataValidationService implements IDataValidationService {
  static #instance: DataValidationService|null = null
  #log = createServiceLogger('DATA_VALIDATION')
  #err = createErrorLogger('DATA_VALIDATION')
  private constructor() {}
  static getInstance(){return this.#instance??(this.#instance=new DataValidationService())}
  validateBlockInfo(data: any): boolean {
    if(!data||!data.hash||!data.merkle_root){this.#err.logError(new Error('Invalid block'),{data});return false}
    return true
  }
  validateInscription(content: string): boolean {
    const isValid = content.length>0 && content.startsWith('{')
    if(!isValid) this.#log.warn('Inscription content failed validation')
    return isValid
  }
  verifyMerkleProof(txId: string, proof: string[]): boolean {
    // Placeholder: actual merkle proof verification later
    return proof.length>0 && txId.length>0
  }
  dispose(){DataValidationService.#instance=null}
}
export const dataValidationService = DataValidationService.getInstance()
'@
  Set-Content -Path (Join-Path $services "dataValidationService.ts") -Value $impl -Encoding UTF8
  Write-SuccessLog "DataValidationService generated"
  exit 0
}
catch { Write-ErrorLog "Data Validation setup failed: $($_.Exception.Message)"; exit 1 }
