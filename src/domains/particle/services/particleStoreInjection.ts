/**
 * @fileoverview Particle Store Injection Configuration
 * @description Configures store injection for ParticleService to use injected stores rather than direct imports
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { ParticleService } from './ParticleService'
import { useParticleStore } from '@/shared/state/useParticleStore'
import { useSimulationStore } from '@/shared/state/useSimulationStore'
import { createServiceLogger } from '@/shared/lib/logger'

const logger = createServiceLogger('ParticleStoreInjection')

/**
 * Store injection configuration interface for ParticleService
 */
export interface IParticleStoreConfig {
  particleStore: typeof useParticleStore
  simulationStore: typeof useSimulationStore
  enableStateLogging: boolean
  enableStorePersistence: boolean
}

/**
 * Default store configuration
 */
const DEFAULT_STORE_CONFIG: IParticleStoreConfig = {
  particleStore: useParticleStore,
  simulationStore: useSimulationStore,
  enableStateLogging: true,
  enableStorePersistence: true
}

/**
 * Store injection manager for ParticleService
 */
export class ParticleStoreInjection {
  private static instance: ParticleStoreInjection
  private config: IParticleStoreConfig
  private isConfigured: boolean = false

  private constructor() {
    this.config = { ...DEFAULT_STORE_CONFIG }
    logger.debug('ParticleStoreInjection initialized with default configuration')
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): ParticleStoreInjection {
    if (!ParticleStoreInjection.instance) {
      ParticleStoreInjection.instance = new ParticleStoreInjection()
    }
    return ParticleStoreInjection.instance
  }

  /**
   * Configure stores for ParticleService
   */
  public configureStores(config?: Partial<IParticleStoreConfig>): void {
    logger.info('Configuring ParticleService store injection')

    // Merge with default config
    if (config) {
      this.config = {
        ...this.config,
        ...config
      }
    }

    // Validate particle store
    if (!this.config.particleStore) {
      logger.error('Particle store is required for particle management')
      throw new Error('Particle store is required for ParticleService configuration')
    }

    // Validate simulation store
    if (!this.config.simulationStore) {
      logger.error('Simulation store is required for simulation state')
      throw new Error('Simulation store is required for ParticleService configuration')
    }

    // Configure ParticleService with store injection
    const particleService = ParticleService.getInstance()
    
    // Inject particle store
    if (typeof particleService.setParticleStore === 'function') {
      particleService.setParticleStore(this.config.particleStore)
      logger.debug('Particle store injected into ParticleService')
    }
    
    // Inject simulation store
    if (typeof particleService.setSimulationStore === 'function') {
      particleService.setSimulationStore(this.config.simulationStore)
      logger.debug('Simulation store injected into ParticleService')
    }

    // Configure state logging
    if (typeof particleService.setStateLoggingEnabled === 'function') {
      particleService.setStateLoggingEnabled(this.config.enableStateLogging)
      logger.debug(`State logging ${this.config.enableStateLogging ? 'enabled' : 'disabled'}`)
    }

    // Configure store persistence
    if (typeof particleService.setStorePersistenceEnabled === 'function') {
      particleService.setStorePersistenceEnabled(this.config.enableStorePersistence)
      logger.debug(`Store persistence ${this.config.enableStorePersistence ? 'enabled' : 'disabled'}`)
    }

    this.isConfigured = true
    logger.success('ParticleService store injection configured successfully')
  }

  /**
   * Get current configuration
   */
  public getConfiguration(): IParticleStoreConfig {
    return { ...this.config }
  }

  /**
   * Check if store injection is configured
   */
  public isConfigurationComplete(): boolean {
    return this.isConfigured && 
           !!this.config.particleStore && 
           !!this.config.simulationStore
  }

  /**
   * Reset configuration to defaults
   */
  public resetConfiguration(): void {
    logger.info('Resetting ParticleService store configuration to defaults')
    this.config = { ...DEFAULT_STORE_CONFIG }
    this.isConfigured = false
    
    // Reconfigure with defaults
    this.configureStores()
  }

  /**
   * Validate store health
   */
  public validateStores(): boolean {
    logger.debug('Validating ParticleService store injection')

    try {
      // Test particle store
      if (this.config.particleStore) {
        const particleState = this.config.particleStore.getState()
        if (!particleState) {
          logger.error('Particle store state validation failed')
          return false
        }
        logger.debug('Particle store validation passed')
      }

      // Test simulation store
      if (this.config.simulationStore) {
        const simulationState = this.config.simulationStore.getState()
        if (!simulationState) {
          logger.error('Simulation store state validation failed')
          return false
        }
        logger.debug('Simulation store validation passed')
      }

      logger.success('Store validation completed successfully')
      return true

    } catch (error) {
      logger.error(`Store validation failed: ${error}`)
      return false
    }
  }

  /**
   * Create mock store configuration for unit tests
   */
  public createTestConfiguration(): IParticleStoreConfig {
    logger.debug('Creating test store configuration for ParticleService')
    
    // Create mock stores for testing
    const mockParticleStore = {
      getState: () => ({
        particles: [],
        particleSystems: [],
        activeSystem: null
      }),
      setState: () => {},
      subscribe: () => () => {},
      destroy: () => {}
    } as any

    const mockSimulationStore = {
      getState: () => ({
        isRunning: false,
        isPlaying: false,
        currentTime: 0,
        deltaTime: 0
      }),
      setState: () => {},
      subscribe: () => () => {},
      destroy: () => {}
    } as any

    return {
      particleStore: mockParticleStore,
      simulationStore: mockSimulationStore,
      enableStateLogging: false, // Reduce test noise
      enableStorePersistence: false // Disable for consistent tests
    }
  }

  /**
   * Create store accessor methods for ParticleService
   */
  public createStoreAccessors() {
    return {
      /**
       * Get particle store state
       */
      getParticleState: () => {
        if (!this.config.particleStore) {
          throw new Error('Particle store not configured')
        }
        return this.config.particleStore.getState()
      },

      /**
       * Update particle store state
       */
      updateParticleState: (updates: Partial<any>) => {
        if (!this.config.particleStore) {
          throw new Error('Particle store not configured')
        }
        this.config.particleStore.setState(updates)
        
        if (this.config.enableStateLogging) {
          logger.debug('Particle store state updated', updates)
        }
      },

      /**
       * Get simulation store state
       */
      getSimulationState: () => {
        if (!this.config.simulationStore) {
          throw new Error('Simulation store not configured')
        }
        return this.config.simulationStore.getState()
      },

      /**
       * Update simulation store state
       */
      updateSimulationState: (updates: Partial<any>) => {
        if (!this.config.simulationStore) {
          throw new Error('Simulation store not configured')
        }
        this.config.simulationStore.setState(updates)
        
        if (this.config.enableStateLogging) {
          logger.debug('Simulation store state updated', updates)
        }
      },

      /**
       * Subscribe to particle store changes
       */
      subscribeToParticleStore: (callback: (state: any) => void) => {
        if (!this.config.particleStore) {
          throw new Error('Particle store not configured')
        }
        return this.config.particleStore.subscribe(callback)
      },

      /**
       * Subscribe to simulation store changes
       */
      subscribeToSimulationStore: (callback: (state: any) => void) => {
        if (!this.config.simulationStore) {
          throw new Error('Simulation store not configured')
        }
        return this.config.simulationStore.subscribe(callback)
      }
    }
  }
}

/**
 * Global configuration function for easy setup
 */
export function configureParticleStores(config?: Partial<IParticleStoreConfig>): void {
  const injector = ParticleStoreInjection.getInstance()
  injector.configureStores(config)
}

/**
 * Validation function for store health checks
 */
export function validateParticleStores(): boolean {
  const injector = ParticleStoreInjection.getInstance()
  return injector.validateStores()
}

/**
 * Get store accessor methods
 */
export function getParticleStoreAccessors() {
  const injector = ParticleStoreInjection.getInstance()
  return injector.createStoreAccessors()
}

/**
 * Export singleton instance for external use
 */
export const particleStoreInjection = ParticleStoreInjection.getInstance()

/**
 * Export configuration defaults for reference
 */
export { DEFAULT_STORE_CONFIG as PARTICLE_STORE_DEFAULTS } 
