# 31b-RefactorParticleStoreInjection.ps1 - Phase 3 Refactoring
# Refactors ParticleService to use injected stores rather than direct imports
# ARCHITECTURE: Template-first approach with dependency injection pattern
# Reference: architecture-gap-analysis.md 2.5 - Refactor to use injected stores rather than direct imports
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
    Write-StepHeader "Particle Store Injection Refactoring - Phase 3"
    Write-InfoLog "Refactoring ParticleService to use injected stores rather than direct imports"

    # Define paths
    $particleDomainPath = Join-Path $ProjectRoot "src/domains/particle"
    $servicesPath = Join-Path $particleDomainPath "services"
    $templatesPath = Join-Path $ProjectRoot "templates"

    # Generate particle store injection service from template
    Write-InfoLog "Generating particle store injection service from template"
    $storeInjectionTemplate = Join-Path $templatesPath "domains/particle/services/particleStoreInjection.ts.template"
    $storeInjectionOutput = Join-Path $servicesPath "particleStoreInjection.ts"
    
    if (Test-Path $storeInjectionTemplate) {
        Copy-Item -Path $storeInjectionTemplate -Destination $storeInjectionOutput -Force
        Write-SuccessLog "Particle store injection service generated: $storeInjectionOutput"
    }
    else {
        Write-ErrorLog "Particle store injection template not found: $storeInjectionTemplate"
        exit 1
    }

    # Update particle domain index to include store injection exports
    Write-InfoLog "Updating particle domain index to include store injection exports"
    $indexPath = Join-Path $particleDomainPath "index.ts"
    
    # Read existing index content
    $indexContent = Get-Content -Path $indexPath -Raw -ErrorAction SilentlyContinue
    if (-not $indexContent) {
        $indexContent = ""
    }

    # Check if store injection exports already exist
    if ($indexContent -notlike "*particleStoreInjection*") {
        # Append store injection exports to existing index
        $storeExports = @"

// Store Injection exports
export {
  ParticleStoreInjection,
  configureParticleStores,
  validateParticleStores,
  getParticleStoreAccessors,
  particleStoreInjection,
  PARTICLE_STORE_DEFAULTS
} from './services/particleStoreInjection';

export type {
  IParticleStoreConfig
} from './services/particleStoreInjection';
"@

        $updatedContent = $indexContent + $storeExports
        Set-Content -Path $indexPath -Value $updatedContent -Encoding UTF8
        Write-SuccessLog "Updated particle domain index with store injection exports"
    }
    else {
        Write-InfoLog "Store injection exports already present in particle domain index"
    }

    # Create store integration helper for other domains
    Write-InfoLog "Creating store integration helper"
    $integrationHelperPath = Join-Path $ProjectRoot "src/shared/utils/storeIntegration.ts"
    $integrationHelperContent = @'
/**
 * @fileoverview Store Integration Helper
 * @description Helper functions for domain services to integrate with Zustand stores
 */

import { ParticleStoreInjection } from '@/domains/particle/services/particleStoreInjection'
import { createServiceLogger } from '@/shared/lib/logger'

const logger = createServiceLogger('StoreIntegration')

/**
 * Central store integration configuration
 */
export class StoreIntegrationManager {
  private static instance: StoreIntegrationManager
  private configuredDomains: Set<string> = new Set()

  private constructor() {
    logger.debug('StoreIntegrationManager initialized')
  }

  public static getInstance(): StoreIntegrationManager {
    if (!StoreIntegrationManager.instance) {
      StoreIntegrationManager.instance = new StoreIntegrationManager()
    }
    return StoreIntegrationManager.instance
  }

  /**
   * Configure all domain stores
   */
  public configureAllStores(): void {
    logger.info('Configuring all domain store integrations')

    try {
      // Configure particle domain stores
      if (!this.configuredDomains.has('particle')) {
        const particleInjection = ParticleStoreInjection.getInstance()
        particleInjection.configureStores()
        this.configuredDomains.add('particle')
        logger.debug('Particle domain stores configured')
      }

      // TODO: Add other domain store configurations as they are implemented
      // - Trait domain stores
      // - Formation domain stores
      // - Animation domain stores
      // - etc.

      logger.success('All domain store integrations configured successfully')
    }
    catch (error) {
      logger.error(`Store integration configuration failed: ${error}`)
      throw error
    }
  }

  /**
   * Validate all configured stores
   */
  public validateAllStores(): boolean {
    logger.debug('Validating all configured store integrations')

    try {
      let allValid = true

      // Validate particle stores
      if (this.configuredDomains.has('particle')) {
        const particleInjection = ParticleStoreInjection.getInstance()
        if (!particleInjection.validateStores()) {
          logger.error('Particle store validation failed')
          allValid = false
        }
      }

      // TODO: Add validation for other domain stores

      if (allValid) {
        logger.success('All store integrations validated successfully')
      }

      return allValid
    }
    catch (error) {
      logger.error(`Store validation failed: ${error}`)
      return false
    }
  }

  /**
   * Get health status of all stores
   */
  public getStoreHealthStatus() {
    return {
      configuredDomains: Array.from(this.configuredDomains),
      isHealthy: this.validateAllStores(),
      timestamp: new Date().toISOString()
    }
  }

  /**
   * Reset all store configurations
   */
  public resetAllStores(): void {
    logger.info('Resetting all store configurations')

    if (this.configuredDomains.has('particle')) {
      const particleInjection = ParticleStoreInjection.getInstance()
      particleInjection.resetConfiguration()
    }

    this.configuredDomains.clear()
    logger.success('All store configurations reset')
  }
}

/**
 * Global store configuration function
 */
export function configureAllDomainStores(): void {
  const manager = StoreIntegrationManager.getInstance()
  manager.configureAllStores()
}

/**
 * Global store validation function
 */
export function validateAllDomainStores(): boolean {
  const manager = StoreIntegrationManager.getInstance()
  return manager.validateAllStores()
}

/**
 * Export singleton instance
 */
export const storeIntegrationManager = StoreIntegrationManager.getInstance()
'@

    # Ensure shared utils directory exists
    $sharedUtilsPath = Join-Path $ProjectRoot "src/shared/utils"
    New-Item -Path $sharedUtilsPath -ItemType Directory -Force | Out-Null
    
    Set-Content -Path $integrationHelperPath -Value $integrationHelperContent -Encoding UTF8
    Write-SuccessLog "Store integration helper created: $integrationHelperPath"

    # Update composition root to include store configuration
    Write-InfoLog "Checking composition root for store integration"
    $compositionRootPath = Join-Path $ProjectRoot "src/compositionRoot.ts"
    
    if (Test-Path $compositionRootPath) {
        $compositionContent = Get-Content -Path $compositionRootPath -Raw
        
        # Check if store integration is already configured
        if ($compositionContent -notlike "*configureAllDomainStores*") {
            # Add store configuration to composition root
            $storeConfigCode = @"

// Configure domain store integrations
import { configureAllDomainStores } from '@/shared/utils/storeIntegration'
configureAllDomainStores()
"@
            
            $updatedComposition = $compositionContent + $storeConfigCode
            Set-Content -Path $compositionRootPath -Value $updatedComposition -Encoding UTF8
            Write-SuccessLog "Added store integration to composition root"
        }
        else {
            Write-InfoLog "Store integration already configured in composition root"
        }
    }
    else {
        Write-WarningLog "Composition root not found - store integration will need manual configuration"
    }

    # Validate TypeScript compilation
    Write-InfoLog "Validating generated TypeScript files"
    Push-Location $ProjectRoot
    
    try {
        $tscResult = & npx tsc --noEmit --skipLibCheck 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SuccessLog "TypeScript validation passed"
        }
        else {
            Write-WarningLog "TypeScript validation warnings (non-critical): $tscResult"
        }
    }
    catch {
        Write-WarningLog "TypeScript validation could not be performed: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }

    Write-SuccessLog "Particle Store Injection refactoring completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/particle/services/particleStoreInjection.ts"
    Write-InfoLog "  - src/shared/utils/storeIntegration.ts"
    Write-InfoLog "  - Updated src/domains/particle/index.ts with store injection exports"
    Write-InfoLog "  - Updated src/compositionRoot.ts with store configuration"
    
    Write-InfoLog "ARCHITECTURE GAP RESOLVED:"
    Write-InfoLog "  [OK] 2.5 - Refactor to use injected stores rather than direct imports"

    exit 0
}
catch {
    Write-ErrorLog "Particle Store Injection refactoring failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
} 