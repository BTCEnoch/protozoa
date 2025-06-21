/**
 * @fileoverview Composition Root - Dependency Injection Container
 * @description Initializes and manages all domain services with proper dependency injection
 * @author Protozoa Development Team
 * @version 2.0.0
 */

import { logger, initializeLogging, perfLogger } from '@/shared/lib/logger'

// Domain Service Imports
import { RNGService } from '@/domains/rng/services/RNGService'
import { PhysicsService } from '@/domains/physics/services/PhysicsService'
import { ParticleService } from '@/domains/particle/services/ParticleService'
import { BitcoinService } from '@/domains/bitcoin/services/BitcoinService'
import { TraitService } from '@/domains/trait/services/TraitService'
import { FormationService } from '@/domains/formation/services/FormationService'
import { GroupService } from '@/domains/group/services/GroupService'

// Shared Service Imports
import { EventBus } from '@/shared/services/eventBus'

// Service State Management
let servicesInitialized = false
let initializationPromise: Promise<void> | null = null

// Service Registry for Dependency Injection
const serviceRegistry = new Map<string, any>()

/**
 * Service Initialization Configuration
 */
interface ServiceConfig {
  name: string
  factory: () => Promise<any>
  dependencies: string[]
  critical: boolean // If true, failure will halt initialization
}

/**
 * Define service initialization order and dependencies
 */
const serviceConfigs: ServiceConfig[] = [
  // Phase 1: Core Infrastructure Services (no dependencies)
  {
    name: 'RNGService',
    factory: async () => RNGService.getInstance(),
    dependencies: [],
    critical: true
  },
  {
    name: 'BitcoinService', 
    factory: async () => BitcoinService.getInstance(),
    dependencies: [],
    critical: true
  },
  
  // Phase 2: Domain Logic Services (depend on core services)
  {
    name: 'PhysicsService',
    factory: async () => PhysicsService.getInstance(),
    dependencies: ['RNGService'],
    critical: true
  },
  {
    name: 'TraitService',
    factory: async () => TraitService.getInstance(),
    dependencies: ['RNGService', 'BitcoinService'],
    critical: true
  },
  
  // Phase 3: Entity Management Services
  {
    name: 'ParticleService',
    factory: async () => ParticleService.getInstance(),
    dependencies: ['PhysicsService', 'TraitService'],
    critical: true
  },
  {
    name: 'FormationService',
    factory: async () => FormationService.getInstance(),
    dependencies: ['ParticleService', 'PhysicsService'],
    critical: true
  },
  
  // Phase 4: Group and Swarm Services
  {
    name: 'GroupService',
    factory: async () => GroupService.getInstance(),
    dependencies: ['ParticleService', 'FormationService'],
    critical: true
  },
  {
    name: 'SwarmService',
    factory: async () => {
      const { swarmService } = await import('@/domains/group/services/SwarmService')
      return swarmService
    },
    dependencies: ['GroupService', 'PhysicsService'],
    critical: false // Non-critical for basic functionality
  },
  
  // Phase 5: Rendering and Visual Services
  {
    name: 'RenderingService',
    factory: async () => {
      const { renderingService } = await import('@/domains/rendering/services/RenderingService')
      return renderingService
    },
    dependencies: ['ParticleService', 'GroupService'],
    critical: true
  },
  {
    name: 'AnimationService',
    factory: async () => {
      const { animationService } = await import('@/domains/animation/services/AnimationService')
      return animationService
    },
    dependencies: ['RenderingService', 'PhysicsService'],
    critical: false
  },
  {
    name: 'EffectService',
    factory: async () => {
      const { effectService } = await import('@/domains/effect/services/EffectService')
      return effectService
    },
    dependencies: ['RenderingService', 'AnimationService'],
    critical: false
  }
]

/**
 * Initialize a single service with dependency injection
 */
async function initializeService(config: ServiceConfig): Promise<void> {
  const timer = `${config.name}_init`
  perfLogger.startTimer(timer)
  
  try {
    logger.info(`🔧 Initializing ${config.name}...`)
    
    // Check if dependencies are available
    for (const dep of config.dependencies) {
      if (!serviceRegistry.has(dep)) {
        throw new Error(`Dependency ${dep} not available for ${config.name}`)
      }
    }
    
    // Initialize the service
    const service = await config.factory()
    
    // Register the service
    serviceRegistry.set(config.name, service)
    
    // Log successful initialization
    const duration = perfLogger.endTimer(timer)
    logger.info(`✅ ${config.name} initialized successfully (${duration.toFixed(2)}ms)`)
    
  } catch (error) {
    perfLogger.endTimer(timer)
    const errorMsg = `Failed to initialize ${config.name}: ${error}`
    
    if (config.critical) {
      logger.error(`❌ CRITICAL: ${errorMsg}`)
      throw new Error(errorMsg)
    } else {
      logger.warn(`⚠️ NON-CRITICAL: ${errorMsg}`)
      // Register a null placeholder for non-critical services
      serviceRegistry.set(config.name, null)
    }
  }
}

/**
 * Initialize all domain services with proper dependency injection
 */
export async function initServices(): Promise<void> {
  // Return existing promise if initialization is in progress
  if (initializationPromise) {
    return initializationPromise
  }
  
  // Return immediately if already initialized
  if (servicesInitialized) {
    logger.info('⚠️ Services already initialized')
    return Promise.resolve()
  }

  // Create and store the initialization promise
  initializationPromise = (async () => {
    const totalTimer = 'total_service_initialization'
    perfLogger.startTimer(totalTimer)
    
    try {
      logger.info('🚀 Initializing Protozoa domain services...')
      
      // Initialize logging system first
      initializeLogging()
      
      // Initialize event bus
      logger.info('📡 Initializing event bus...')
      const eventBus = EventBus.getInstance()
      serviceRegistry.set('EventBus', eventBus)
      
      // Initialize services in dependency order
      for (const config of serviceConfigs) {
        await initializeService(config)
      }
      
      // Mark as initialized
      servicesInitialized = true
      
      const totalDuration = perfLogger.endTimer(totalTimer)
      logger.info(`🎉 All services initialized successfully in ${totalDuration.toFixed(2)}ms`)
      
    } catch (error) {
      perfLogger.endTimer(totalTimer)
      logger.error(`❌ Service initialization failed: ${error}`)
      throw error
    } finally {
      // Reset initialization promise
      initializationPromise = null
    }
  })()

  return initializationPromise
}

/**
 * Dispose all services and clean up resources
 */
export async function disposeServices(): Promise<void> {
  if (!servicesInitialized) {
    logger.info('⚠️ Services not initialized, nothing to dispose')
    return
  }

  logger.info('🧹 Disposing all services...')
  const disposeTimer = 'service_disposal'
  perfLogger.startTimer(disposeTimer)

  // Dispose services in reverse order
  const services = Array.from(serviceRegistry.entries()).reverse()
  
  for (const [name, service] of services) {
    try {
      if (service && typeof service.dispose === 'function') {
        await service.dispose()
        logger.info(`🗑️ Disposed ${name}`)
      }
    } catch (error) {
      logger.warn(`⚠️ Failed to dispose ${name}: ${error}`)
    }
  }

  // Clear registry and reset state
  serviceRegistry.clear()
  servicesInitialized = false
  
  const disposeDuration = perfLogger.endTimer(disposeTimer)
  logger.info(`✅ All services disposed in ${disposeDuration.toFixed(2)}ms`)
}

/**
 * Get a service instance from the registry
 */
export function getService<T>(serviceName: string): T | null {
  const service = serviceRegistry.get(serviceName)
  if (!service) {
    logger.warn(`⚠️ Service '${serviceName}' not found in registry`)
    return null
  }
  return service as T
}

/**
 * Check if a specific service is initialized
 */
export function isServiceInitialized(serviceName: string): boolean {
  return serviceRegistry.has(serviceName)
}

/**
 * Get overall service initialization status
 */
export function getServiceStatus(): boolean {
  return servicesInitialized
}

/**
 * Get information about all registered services
 */
export function getServiceRegistryInfo(): Record<string, any> {
  const info: Record<string, any> = {}
  for (const [name, service] of serviceRegistry.entries()) {
    info[name] = {
      initialized: true,
      type: service?.constructor?.name || 'Unknown',
      hasDispose: typeof service?.dispose === 'function'
    }
  }
  return info
}

/**
 * Health check for all services
 */
export async function healthCheck(): Promise<Record<string, boolean>> {
  const health: Record<string, boolean> = {}
  
  for (const [name, service] of serviceRegistry.entries()) {
    try {
      if (service && typeof service.healthCheck === 'function') {
        health[name] = await service.healthCheck()
      } else {
        // Basic health check - service exists and is not null
        health[name] = service !== null && service !== undefined
      }
    } catch (error) {
      logger.error(`❌ Health check failed for ${name}: ${error}`)
      health[name] = false
    }
  }
  
  return health
}

/**
 * Restart a specific service
 */
export async function restartService(serviceName: string): Promise<boolean> {
  try {
    logger.info(`🔄 Restarting service: ${serviceName}`)
    
    // Find service config
    const config = serviceConfigs.find(c => c.name === serviceName)
    if (!config) {
      logger.error(`❌ Service config not found: ${serviceName}`)
      return false
    }
    
    // Dispose existing service
    const existingService = serviceRegistry.get(serviceName)
    if (existingService && typeof existingService.dispose === 'function') {
      await existingService.dispose()
    }
    
    // Remove from registry
    serviceRegistry.delete(serviceName)
    
    // Reinitialize
    await initializeService(config)
    
    logger.info(`✅ Service restarted successfully: ${serviceName}`)
    return true
    
  } catch (error) {
    logger.error(`❌ Failed to restart service ${serviceName}: ${error}`)
    return false
  }
}

// Export service registry for advanced use cases
export { serviceRegistry } 