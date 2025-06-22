/**
 * @fileoverview Trait Domain Dependency Injection Configuration
 * @description Configures dependency injection for TraitService with RNG and Bitcoin services
 * @author Protozoia Development Team
 * @version 1.0.0
 */

import { TraitService } from './TraitService'
import { RNGService } from '@/domains/rng/services/RNGService'
import { BitcoinService } from '@/domains/bitcoin/services/BitcoinService'
import { createServiceLogger } from '@/shared/lib/logger'

const logger = createServiceLogger('TraitDependencyInjection')

/**
 * Dependency injection configuration interface for TraitService
 */
export interface ITraitDependencyConfig {
  rngService: RNGService
  bitcoinService: BitcoinService
  enableBlockchainSeed: boolean
  enableMutationLogging: boolean
}

/**
 * Default dependency configuration
 */
const DEFAULT_CONFIG: ITraitDependencyConfig = {
  rngService: RNGService.getInstance(),
  bitcoinService: BitcoinService.getInstance(),
  enableBlockchainSeed: true,
  enableMutationLogging: true
}

/**
 * Dependency injection manager for TraitService
 */
export class TraitDependencyInjection {
  private static instance: TraitDependencyInjection
  private config: ITraitDependencyConfig
  private isConfigured: boolean = false

  private constructor() {
    this.config = { ...DEFAULT_CONFIG }
    logger.debug('TraitDependencyInjection initialized with default configuration')
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): TraitDependencyInjection {
    if (!TraitDependencyInjection.instance) {
      TraitDependencyInjection.instance = new TraitDependencyInjection()
    }
    return TraitDependencyInjection.instance
  }

  /**
   * Configure dependencies for TraitService
   */
  public configureDependencies(config?: Partial<ITraitDependencyConfig>): void {
    logger.info('Configuring TraitService dependencies')

    // Merge with default config
    if (config) {
      this.config = {
        ...this.config,
        ...config
      }
    }

    // Validate RNG service
    if (!this.config.rngService) {
      logger.error('RNG service is required for trait generation')
      throw new Error('RNG service is required for TraitService configuration')
    }

    // Validate Bitcoin service
    if (!this.config.bitcoinService) {
      logger.error('Bitcoin service is required for blockchain-seeded traits')
      throw new Error('Bitcoin service is required for TraitService configuration')
    }

    // Configure TraitService with dependencies
    const traitService = TraitService.getInstance()
    
    // Inject RNG service
    if (typeof traitService.setRNGService === 'function') {
      traitService.setRNGService(this.config.rngService)
      logger.debug('RNG service injected into TraitService')
    }
    
    // Inject Bitcoin service
    if (typeof traitService.setBitcoinService === 'function') {
      traitService.setBitcoinService(this.config.bitcoinService)
      logger.debug('Bitcoin service injected into TraitService')
    }

    // Configure blockchain seeding
    if (typeof traitService.setBlockchainSeedEnabled === 'function') {
      traitService.setBlockchainSeedEnabled(this.config.enableBlockchainSeed)
      logger.debug(`Blockchain seeding ${this.config.enableBlockchainSeed ? 'enabled' : 'disabled'}`)
    }

    // Configure mutation logging
    if (typeof traitService.setMutationLoggingEnabled === 'function') {
      traitService.setMutationLoggingEnabled(this.config.enableMutationLogging)
      logger.debug(`Mutation logging ${this.config.enableMutationLogging ? 'enabled' : 'disabled'}`)
    }

    this.isConfigured = true
    logger.success('TraitService dependencies configured successfully')
  }

  /**
   * Get current configuration
   */
  public getConfiguration(): ITraitDependencyConfig {
    return { ...this.config }
  }

  /**
   * Check if dependencies are configured
   */
  public isConfigurationComplete(): boolean {
    return this.isConfigured && 
           !!this.config.rngService && 
           !!this.config.bitcoinService
  }

  /**
   * Reset configuration to defaults
   */
  public resetConfiguration(): void {
    logger.info('Resetting TraitService configuration to defaults')
    this.config = { ...DEFAULT_CONFIG }
    this.isConfigured = false
    
    // Reconfigure with defaults
    this.configureDependencies()
  }

  /**
   * Validate dependency health
   */
  public async validateDependencies(): Promise<boolean> {
    logger.debug('Validating TraitService dependencies')

    try {
      // Test RNG service
      if (this.config.rngService) {
        const testRandom = this.config.rngService.random()
        if (typeof testRandom !== 'number' || testRandom < 0 || testRandom > 1) {
          logger.error('RNG service validation failed')
          return false
        }
        logger.debug('RNG service validation passed')
      }

      // Test Bitcoin service
      if (this.config.bitcoinService) {
        try {
          // Test basic functionality - non-blocking
          const testConfig = this.config.bitcoinService.getConfiguration()
          if (!testConfig) {
            logger.warn('Bitcoin service configuration not available')
          } else {
            logger.debug('Bitcoin service validation passed')
          }
        } catch (error) {
          logger.warn(`Bitcoin service validation warning: ${error}`)
          // Non-critical - continue
        }
      }

      logger.success('Dependency validation completed successfully')
      return true

    } catch (error) {
      logger.error(`Dependency validation failed: ${error}`)
      return false
    }
  }

  /**
   * Create test configuration for unit tests
   */
  public createTestConfiguration(): ITraitDependencyConfig {
    logger.debug('Creating test configuration for TraitService')
    
    // Create mock services for testing
    const mockRNGService = {
      random: () => 0.5,
      randomInt: (min: number, max: number) => Math.floor((min + max) / 2),
      seed: (seed: number) => {},
      getPurposeRng: (purpose: string) => ({ random: () => 0.5 }),
      getInstance: () => mockRNGService
    } as any

    const mockBitcoinService = {
      getBlockInfo: async (blockNumber: number) => ({ 
        blockNumber, 
        difficulty: 1000, 
        timestamp: Date.now() 
      }),
      getInstance: () => mockBitcoinService
    } as any

    return {
      rngService: mockRNGService,
      bitcoinService: mockBitcoinService,
      enableBlockchainSeed: false, // Disable for consistent tests
      enableMutationLogging: false // Reduce test noise
    }
  }
}

/**
 * Global configuration function for easy setup
 */
export function configureDependencies(config?: Partial<ITraitDependencyConfig>): void {
  const injector = TraitDependencyInjection.getInstance()
  injector.configureDependencies(config)
}

/**
 * Validation function for dependency health checks
 */
export async function validateTraitDependencies(): Promise<boolean> {
  const injector = TraitDependencyInjection.getInstance()
  return await injector.validateDependencies()
}

/**
 * Export singleton instance for external use
 */
export const traitDependencyInjection = TraitDependencyInjection.getInstance()

/**
 * Export configuration defaults for reference
 */
export { DEFAULT_CONFIG as TRAIT_DEPENDENCY_DEFAULTS } 