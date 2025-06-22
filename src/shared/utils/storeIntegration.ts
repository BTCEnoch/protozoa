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
