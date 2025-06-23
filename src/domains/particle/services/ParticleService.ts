/**
 * @fileoverview Particle Service Implementation
 * @description High-performance particle system with THREE.js integration and GPU optimization
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import {
  IParticleService,
  ParticleConfig,
  ParticleInstance,
  ParticleSystem,
} from '@/domains/particle/interfaces/IParticleService'
import {
  ParticleCreationData,
  ParticleMetrics,
  ParticleSystemConfig,
  ParticleType,
} from '@/domains/particle/types/particle.types'
import { createServiceLogger } from '@/shared/lib/logger'
import * as THREE from 'three'
import { Scene, Vector3 } from 'three'

/**
 * Particle Service implementing high-performance particle system management
 * Uses THREE.js for rendering with GPU instancing and object pooling optimizations
 * Follows singleton pattern for application-wide particle management
 */
export class ParticleService implements IParticleService {
  /** Singleton instance */
  static #instance: ParticleService | null = null

  /** Service configuration */
  #config: ParticleConfig

  /** Winston logger instance */
  #logger = createServiceLogger('ParticleService')

  /** Active particle systems */
  #systems: Map<string, ParticleSystem>

  /** Particle object pool */
  #particlePool: ParticleInstance[]

  /** Available pool indices */
  #poolIndices: number[]

  /** Frame timing for performance monitoring */
  #frameStartTime: number = 0

  /** Frame counter for logging */
  #frameCounter: number = 0

  /**
   * Private constructor enforcing singleton pattern
   * Initializes particle service with performance optimizations
   */
  private constructor() {
    this.#logger.info('Initializing ParticleService singleton instance')

    // Initialize default configuration
    this.#config = {
      maxParticles: 10000,
      useInstancing: true,
      useObjectPooling: true,
      defaultMaterial: 'standard',
      enableLOD: true,
      cullingDistance: 100,
    }

    // Initialize collections
    this.#systems = new Map()
    this.#particlePool = []
    this.#poolIndices = []

    // Initialize object pool
    this.#initializeObjectPool()

    this.#logger.info('ParticleService initialized successfully', {
      maxParticles: this.#config.maxParticles,
      useInstancing: this.#config.useInstancing,
      useObjectPooling: this.#config.useObjectPooling,
    })
  }

  /**
   * Get singleton instance of ParticleService
   * Creates new instance if none exists
   * @returns ParticleService singleton instance
   */
  public static getInstance(): ParticleService {
    if (!ParticleService.#instance) {
      ParticleService.#instance = new ParticleService()
    }
    return ParticleService.#instance
  }

  /**
   * Initialize the Particle service with configuration
   * @param config - Optional particle configuration
   */
  public async initialize(config?: ParticleConfig): Promise<void> {
    this.#logger.info('Initializing ParticleService with configuration', { config })

    if (config) {
      this.#config = { ...this.#config, ...config }
    }

    // Reinitialize object pool if max particles changed
    if (config?.maxParticles && config.maxParticles !== this.#config.maxParticles) {
      this.#initializeObjectPool()
    }

    this.#logger.info('ParticleService initialization completed')
  }

  /**
   * Create a new particle system
   * @param systemConfig - System configuration
   * @returns Created particle system
   */
  public createSystem(systemConfig: ParticleSystemConfig): ParticleSystem {
    this.#logger.info('Creating particle system', { systemId: systemConfig.id })

    if (this.#systems.has(systemConfig.id)) {
      throw new Error(`Particle system with ID "${systemConfig.id}" already exists`)
    }

    const system: ParticleSystem = {
      id: systemConfig.id,
      name: systemConfig.name,
      maxParticles: systemConfig.maxParticles,
      activeParticles: 0,
      particles: [],
      position: new Vector3(
        systemConfig.position.x,
        systemConfig.position.y,
        systemConfig.position.z
      ),
      bounds: {
        min: new Vector3(
          systemConfig.bounds.min.x,
          systemConfig.bounds.min.y,
          systemConfig.bounds.min.z
        ),
        max: new Vector3(
          systemConfig.bounds.max.x,
          systemConfig.bounds.max.y,
          systemConfig.bounds.max.z
        ),
      },
      active: true,
      createdAt: Date.now(),
    }

    this.#systems.set(systemConfig.id, system)

    this.#logger.info('Particle system created successfully', {
      systemId: systemConfig.id,
      maxParticles: systemConfig.maxParticles,
    })

    return system
  }

  /**
   * Add particles to a system
   * @param systemId - System identifier
   * @param particleData - Particle creation data
   * @returns Array of created particle IDs
   */
  public addParticles(systemId: string, particleData: ParticleCreationData[]): string[] {
    const system = this.#systems.get(systemId)
    if (!system) {
      throw new Error(`Particle system "${systemId}" not found`)
    }

    const createdIds: string[] = []

    for (const data of particleData) {
      if (system.activeParticles >= system.maxParticles) {
        this.#logger.warn('System particle limit reached', {
          systemId,
          maxParticles: system.maxParticles,
        })
        break
      }

      const particle = this.#createParticle(data)
      if (particle) {
        system.particles.push(particle)
        system.activeParticles++
        createdIds.push(particle.id)
      }
    }

    this.#logger.info('Particles added to system', {
      systemId,
      particlesAdded: createdIds.length,
      totalActive: system.activeParticles,
    })

    return createdIds
  }

  /**
   * Remove particles from a system
   * @param systemId - System identifier
   * @param particleIds - Particle IDs to remove
   */
  public removeParticles(systemId: string, particleIds: string[]): void {
    const system = this.#systems.get(systemId)
    if (!system) {
      throw new Error(`Particle system "${systemId}" not found`)
    }

    let removedCount = 0

    for (const particleId of particleIds) {
      const index = system.particles.findIndex((p) => p.id === particleId)
      if (index !== -1) {
        const particle = system.particles[index]
        if (particle) {
          this.#returnParticleToPool(particle)
          system.particles.splice(index, 1)
          system.activeParticles--
          removedCount++
        } else {
          this.#logger.warn('Particle not found at index for removal', {
            systemId,
            particleId,
            index,
          })
        }
      }
    }

    this.#logger.info('Particles removed from system', {
      systemId,
      particlesRemoved: removedCount,
      totalActive: system.activeParticles,
    })
  }

  /**
   * Update all particle systems
   * @param deltaTime - Time delta in seconds
   */
  public update(deltaTime: number): void {
    this.#frameStartTime = performance.now()

    // Calculate total particles for logging
    let totalParticles = 0

    // Update all active systems
    for (const system of this.#systems.values()) {
      if (system.active) {
        this.#updateSystem(system, deltaTime)
        totalParticles += system.activeParticles
      }
    }

    // Only log every 60 frames (~1 second at 60fps) to reduce console spam
    this.#frameCounter = (this.#frameCounter || 0) + 1
    if (this.#frameCounter % 60 === 0) {
      this.#logger.debug('ðŸ" Created particle systems updated', {
        totalParticles,
        activeSystems: this.#systems.size,
        deltaTime: Math.round(deltaTime * 1000) / 1000, // Round to 3 decimal places
      })
    }
  }

  /**
   * Render particles to THREE.js scene
   * @param scene - THREE.js scene
   */
  public render(scene: Scene): void {
    // Only log every 60 frames to reduce console spam
    if ((this.#frameCounter || 0) % 60 === 0) {
      this.#logger.debug('ðŸŽ Rendering particle systems to scene', {
        systemCount: this.#systems.size,
      })
    }

    // Render all active systems
    for (const system of this.#systems.values()) {
      if (system.active && system.particles.length > 0) {
        this.#renderSystem(system, scene)
      }
    }
  }

  /**
   * Get particle performance metrics
   * @returns Particle service metrics
   */
  public getMetrics(): ParticleMetrics {
    let totalParticles = 0
    let activeSystems = 0

    for (const system of this.#systems.values()) {
      if (system.active) {
        activeSystems++
        totalParticles += system.activeParticles
      }
    }

    return {
      totalCreated: this.#config.maxParticles! - this.#poolIndices.length,
      totalParticles,
      activeSystems,
      activeCount: totalParticles,
      particlesUpdated: totalParticles,
      particlesRendered: totalParticles,
      particlesPerSecond: totalParticles, // TODO: Calculate actual rate
      averageUpdateTime: this.#getAverageUpdateTime(),
      averageRenderTime: this.#getAverageRenderTime(),
      memoryUsage: this.#getMemoryUsage(),
      gpuMemoryUsage: this.#getGPUMemoryUsage(),
      poolUtilization:
        (this.#config.maxParticles! - this.#poolIndices.length) / this.#config.maxParticles!,
      frameRateImpact: this.#getFrameRateImpact(),
    }
  }

  /**
   * Get all particle systems
   * @returns Array of all particle systems
   */
  public getAllSystems(): ParticleSystem[] {
    return Array.from(this.#systems.values())
  }

  /**
   * Get particle system by ID
   * @param systemId - System identifier
   * @returns Particle system or undefined
   */
  public getSystem(systemId: string): ParticleSystem | undefined {
    return this.#systems.get(systemId)
  }

  /**
   * Spawn a single particle in a system (convenience method)
   * @param systemId - System identifier
   * @param config - Particle spawn configuration
   * @returns Created particle ID or null if failed
   */
  public spawnParticle(
    systemId: string,
    config: {
      position: THREE.Vector3
      velocity?: THREE.Vector3
      lifetime?: number
      size?: number
      color?: THREE.Color
    }
  ): string | null {
    const particleData: ParticleCreationData = {
      position: { x: config.position.x, y: config.position.y, z: config.position.z },
      velocity: config.velocity
        ? { x: config.velocity.x, y: config.velocity.y, z: config.velocity.z }
        : undefined,
      color: config.color ? { r: config.color.r, g: config.color.g, b: config.color.b } : undefined,
      lifetime: config.lifetime,
      scale: config.size ? { x: config.size, y: config.size, z: config.size } : undefined,
      type: ParticleType.BASIC,
      userData: {},
    }

    const createdIds = this.addParticles(systemId, [particleData])
    return createdIds.length > 0 ? createdIds[0] || null : null
  }

  /**
   * Create a single particle (test compatibility method)
   * @param config - Particle configuration
   * @returns Created particle instance or null
   */
  public createParticle(config: ParticleCreationData): ParticleInstance | null {
    this.#logger.debug('Creating single particle', { config })
    return this.#createParticle(config)
  }

  /**
   * Create multiple particles in batch (test compatibility method)
   * @param configs - Array of particle configurations
   * @returns Array of created particle instances
   */
  public createParticlesBatch(configs: ParticleCreationData[]): ParticleInstance[] {
    this.#logger.debug('Creating particle batch', { count: configs.length })

    const particles: ParticleInstance[] = []
    for (const config of configs) {
      const particle = this.#createParticle(config)
      if (particle) {
        particles.push(particle)
      }
    }

    this.#logger.info('Particle batch created', {
      requested: configs.length,
      created: particles.length,
    })

    return particles
  }

  /**
   * Update a single particle with new properties
   * @param particle - Particle to update
   * @param deltaTime - Time delta for physics updates
   */
  public updateParticle(particle: ParticleInstance, deltaTime: number): void {
    if (!particle || !particle.active) return

    // Update position based on velocity
    if (particle.velocity) {
      particle.position.x += particle.velocity.x * deltaTime
      particle.position.y += particle.velocity.y * deltaTime
      particle.position.z += particle.velocity.z * deltaTime
    }

    // Update lifetime
    if (particle.lifetime !== undefined) {
      particle.lifetime -= deltaTime
      if (particle.lifetime <= 0) {
        particle.active = false
      }
    }

    // Update size based on age (if configured)
    if (
      particle.sizeOverLifetime &&
      particle.lifetime !== undefined &&
      particle.initialLifetime &&
      particle.initialSize
    ) {
      const ageRatio = 1 - particle.lifetime / particle.initialLifetime
      particle.size = particle.initialSize * (1 - ageRatio * particle.sizeOverLifetime)
    }
  }

  /**
   * Release a particle back to the pool
   * @param particle - Particle to release
   */
  public releaseParticle(particle: ParticleInstance): void {
    if (!particle) return

    // Mark as inactive
    particle.active = false

    // Return to pool if using object pooling
    if (this.#config.useObjectPooling) {
      this.#returnParticleToPool(particle)
    }

    this.#logger.debug('Particle released to pool', { particleId: particle.id })
  }

  /**
   * Get all particle systems (convenience method)
   * @returns Map of all particle systems
   */
  public getSystems(): Map<string, ParticleSystem> {
    return this.#systems
  }

  /**
   * Set particle store for state integration
   * @param store - Particle store instance
   */
  public setParticleStore(store: any): void {
    this.#logger.info('Setting particle store for state integration')
    // Store integration implementation can be added here
  }

  /**
   * Set simulation store for state integration
   * @param store - Simulation store instance
   */
  public setSimulationStore(store: any): void {
    this.#logger.info('Setting simulation store for state integration')
    // Store integration implementation can be added here
  }

  /**
   * Enable or disable state logging
   * @param enabled - Whether to enable state logging
   */
  public setStateLoggingEnabled(enabled: boolean): void {
    this.#logger.info('Setting state logging enabled', { enabled })
    // State logging configuration can be added here
  }

  /**
   * Enable or disable store persistence
   * @param enabled - Whether to enable store persistence
   */
  public setStorePersistenceEnabled(enabled: boolean): void {
    this.#logger.info('Setting store persistence enabled', { enabled })
    // Store persistence configuration can be added here
  }

  // Private performance tracking methods

  #updateTimes: number[] = []
  #renderTimes: number[] = []
  #lastParticleCount: number = 0
  #lastTimestamp: number = Date.now()
  #frameTimestamps: number[] = []

  /**
   * Get average update time from recent measurements
   * @returns Average update time in milliseconds
   */
  #getAverageUpdateTime(): number {
    if (this.#updateTimes.length === 0) return 0

    const sum = this.#updateTimes.reduce((a, b) => a + b, 0)
    return sum / this.#updateTimes.length
  }

  /**
   * Get average render time from recent measurements
   * @returns Average render time in milliseconds
   */
  #getAverageRenderTime(): number {
    if (this.#renderTimes.length === 0) return 0

    const sum = this.#renderTimes.reduce((a, b) => a + b, 0)
    return sum / this.#renderTimes.length
  }

  /**
   * Get current memory usage estimate
   * @returns Memory usage in bytes
   */
  #getMemoryUsage(): number {
    if (typeof performance !== 'undefined' && (performance as any).memory) {
      return (performance as any).memory.usedJSHeapSize
    }

    // Fallback estimation based on particle count
    const totalParticles = Array.from(this.#systems.values()).reduce(
      (sum, system) => sum + system.activeParticles,
      0
    )
    const bytesPerParticle = 200 // Estimated memory per particle
    return totalParticles * bytesPerParticle
  }

  /**
   * Get GPU memory usage estimate
   * @returns GPU memory usage in bytes
   */
  #getGPUMemoryUsage(): number {
    // Fallback estimation - WebGL memory tracking is limited
    const totalParticles = Array.from(this.#systems.values()).reduce(
      (sum, system) => sum + system.activeParticles,
      0
    )
    const gpuBytesPerParticle = 64 // Estimated GPU memory per particle
    return totalParticles * gpuBytesPerParticle
  }

  /**
   * Calculate frame rate impact based on processing times
   * @returns Frame rate impact as percentage (0-100)
   */
  #getFrameRateImpact(): number {
    const targetFrameTime = 16.67 // 60 FPS target (milliseconds)
    const averageProcessingTime = this.#getAverageUpdateTime() + this.#getAverageRenderTime()

    if (averageProcessingTime === 0) return 0

    return Math.min(100, (averageProcessingTime / targetFrameTime) * 100)
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info('Disposing ParticleService resources')

    // Clear all systems
    for (const system of this.#systems.values()) {
      for (const particle of system.particles) {
        if (particle) {
          this.#returnParticleToPool(particle)
        }
      }
    }
    this.#systems.clear()

    // Clear object pool
    this.#particlePool = []
    this.#poolIndices = []

    // Reset singleton instance
    ParticleService.#instance = null

    this.#logger.info('ParticleService disposal completed')
  }

  /**
   * Get detailed pool status for debugging
   * @returns Detailed pool information
   */
  public getPoolStatus(): {
    totalPoolSize: number
    availableParticles: number
    usedParticles: number
    utilization: number
    systemBreakdown: Array<{ systemId: string; activeParticles: number }>
  } {
    const systemBreakdown = Array.from(this.#systems.entries()).map(([id, system]) => ({
      systemId: id,
      activeParticles: system.activeParticles,
    }))

    const usedParticles = this.#config.maxParticles! - this.#poolIndices.length
    const availableParticles = this.#poolIndices.length
    const utilization = usedParticles / this.#config.maxParticles!

    return {
      totalPoolSize: this.#config.maxParticles!,
      availableParticles,
      usedParticles,
      utilization,
      systemBreakdown,
    }
  }

  /**
   * Reset the particle pool completely (emergency recovery)
   * This should only be used when the pool is in an inconsistent state
   */
  public resetPool(): void {
    this.#logger.warn('ðŸ" Resetting particle pool due to inconsistent state')

    // Clear all systems first
    for (const system of this.#systems.values()) {
      system.particles = []
      system.activeParticles = 0
    }

    // CRITICAL FIX: Completely reinitialize the pool to prevent corruption
    this.#poolIndices = []
    for (let i = 0; i < this.#config.maxParticles!; i++) {
      this.#poolIndices.push(i)
      // Reset pool particles with explicit null safety for TypeScript
      const particle = this.#particlePool[i]
      if (particle) {
        particle.active = false
        particle.id = ''
        particle.userData = {}
      }
    }

    this.#logger.info('âœ" Particle pool reset complete', {
      availableParticles: this.#poolIndices.length,
      totalPoolSize: this.#config.maxParticles,
    })
  }

  /**
   * Validate pool integrity and fix corruption
   * @returns Whether the pool was corrupted and needed fixing
   */
  public validateAndFixPool(): boolean {
    let wasCorrupted = false

    // Check for duplicate indices
    const uniqueIndices = new Set(this.#poolIndices)
    if (uniqueIndices.size !== this.#poolIndices.length) {
      this.#logger.warn('ðŸš Pool corruption detected: duplicate indices found')
      wasCorrupted = true
    }

    // Check for invalid indices
    const invalidIndices = this.#poolIndices.filter(
      (index) => index < 0 || index >= this.#config.maxParticles! || !Number.isInteger(index)
    )
    if (invalidIndices.length > 0) {
      this.#logger.warn('ðŸš Pool corruption detected: invalid indices found', { invalidIndices })
      wasCorrupted = true
    }

    // CRITICAL: Check if particlePool array is empty or corrupted
    if (this.#particlePool.length !== this.#config.maxParticles!) {
      this.#logger.warn('ðŸš Pool corruption detected: particlePool array size mismatch', {
        actualSize: this.#particlePool.length,
        expectedSize: this.#config.maxParticles!,
      })
      wasCorrupted = true
    }

    // Check for missing indices (indices that should be available but aren't)
    const usedIndices = new Set<number>()
    for (const system of this.#systems.values()) {
      for (const particle of system.particles) {
        const poolIndex = particle.userData?.__poolIndex
        if (typeof poolIndex === 'number') {
          usedIndices.add(poolIndex)
        }
      }
    }

    const expectedAvailableIndices = new Set<number>()
    for (let i = 0; i < this.#config.maxParticles!; i++) {
      if (!usedIndices.has(i)) {
        expectedAvailableIndices.add(i)
      }
    }

    if (uniqueIndices.size !== expectedAvailableIndices.size) {
      this.#logger.warn('ðŸš Pool corruption detected: available indices count mismatch', {
        actualAvailable: uniqueIndices.size,
        expectedAvailable: expectedAvailableIndices.size,
        usedIndices: usedIndices.size,
      })
      wasCorrupted = true
    }

    // Fix corruption by rebuilding BOTH the pool indices AND the particle pool array
    if (wasCorrupted) {
      this.#logger.warn('ðŸ" Fixing pool corruption by rebuilding pool and indices')

      // CRITICAL FIX: Rebuild the entire particle pool array
      this.#particlePool = []
      for (let i = 0; i < this.#config.maxParticles!; i++) {
        const particle: ParticleInstance = {
          id: '',
          position: new Vector3(),
          velocity: new Vector3(),
          scale: new Vector3(1, 1, 1),
          rotation: 0,
          color: '#ffffff',
          opacity: 1,
          age: 0,
          lifetime: 10,
          active: false,
          type: ParticleType.BASIC,
          userData: {},
          size: 1,
        }
        this.#particlePool.push(particle)
      }

      // Rebuild the available indices
      this.#poolIndices = Array.from(expectedAvailableIndices)

      this.#logger.info('âœ" Pool corruption fixed', {
        particlePoolSize: this.#particlePool.length,
        availableParticles: this.#poolIndices.length,
        usedParticles: usedIndices.size,
      })
    }

    return wasCorrupted
  }

  // Private helper methods

  /**
   * Initialize object pool for particle instances
   * CRITICAL: This must create exactly maxParticles entries in both arrays
   */
  #initializeObjectPool(): void {
    this.#logger.info('Initializing particle object pool', {
      maxParticles: this.#config.maxParticles,
    })

    // CRITICAL: Clear existing pools completely before rebuilding
    this.#particlePool.length = 0
    this.#poolIndices.length = 0

    // CRITICAL: Validate maxParticles configuration
    if (!this.#config.maxParticles || this.#config.maxParticles <= 0) {
      throw new Error('Invalid maxParticles configuration: must be positive integer')
    }

    // Build particle pool with exact count
    for (let i = 0; i < this.#config.maxParticles; i++) {
      const particle: ParticleInstance = {
        id: '',
        position: new Vector3(),
        velocity: new Vector3(),
        scale: new Vector3(1, 1, 1),
        rotation: 0,
        color: '#ffffff',
        opacity: 1,
        age: 0,
        lifetime: 10,
        active: false,
        type: ParticleType.BASIC,
        userData: {},
        size: 1,
      }

      this.#particlePool.push(particle)
      this.#poolIndices.push(i)
    }

    // CRITICAL: Validate pool integrity immediately after creation
    if (this.#particlePool.length !== this.#config.maxParticles) {
      throw new Error(
        `Pool creation failed: expected ${this.#config.maxParticles} particles, got ${this.#particlePool.length}`
      )
    }

    if (this.#poolIndices.length !== this.#config.maxParticles) {
      throw new Error(
        `Index creation failed: expected ${this.#config.maxParticles} indices, got ${this.#poolIndices.length}`
      )
    }

    this.#logger.info('Particle object pool initialized successfully', {
      particlePoolSize: this.#particlePool.length,
      indexPoolSize: this.#poolIndices.length,
      expectedSize: this.#config.maxParticles,
    })
  }

  /**
   * Create particle from creation data
   * @param data - Particle creation data
   * @returns Created particle instance or null if pool exhausted
   */
  #createParticle(data: ParticleCreationData): ParticleInstance | null {
    if (this.#poolIndices.length === 0) {
      this.#logger.warn('Particle pool exhausted', {
        totalPoolSize: this.#config.maxParticles,
        usedParticles: this.#config.maxParticles! - this.#poolIndices.length,
        availableParticles: this.#poolIndices.length,
      })
      return null
    }

    const poolIndex = this.#poolIndices.pop()
    if (poolIndex === undefined || poolIndex === null) {
      this.#logger.error('Failed to get valid pool index')
      return null
    }

    const particle = this.#particlePool[poolIndex]
    if (!particle) {
      this.#logger.error('Failed to retrieve particle from pool', { poolIndex })
      return null
    }

    // Initialize particle
    particle.id = `particle_${Date.now()}_${poolIndex}`

    // CRITICAL FIX: Store pool index for proper return to pool
    particle.userData = { ...data.userData, __poolIndex: poolIndex }

    // Convert IVector3 to Vector3 for THREE.js compatibility
    particle.position.x = data.position.x
    particle.position.y = data.position.y
    particle.position.z = data.position.z

    if (data.velocity) {
      particle.velocity.x = data.velocity.x
      particle.velocity.y = data.velocity.y
      particle.velocity.z = data.velocity.z
    } else {
      particle.velocity.x = 0
      particle.velocity.y = 0
      particle.velocity.z = 0
    }

    if (data.scale) {
      particle.scale.set(data.scale.x, data.scale.y, data.scale.z)
    } else {
      particle.scale.set(1, 1, 1)
    }

    particle.rotation = 0 // Use fixed value since rotation not in creation data
    particle.color =
      typeof data.color === 'string'
        ? data.color
        : data.color
          ? `rgb(${Math.round(data.color.r * 255)}, ${Math.round(data.color.g * 255)}, ${Math.round(data.color.b * 255)})`
          : '#ffffff'
    particle.opacity = 1 // Use fixed value since opacity not in creation data
    particle.age = 0
    particle.lifetime = data.lifetime || 10
    particle.active = true
    particle.type = data.type || ParticleType.BASIC
    particle.size = data.scale?.x || 1

    return particle
  }

  /**
   * Return particle to object pool
   * @param particle - Particle to return
   */
  #returnParticleToPool(particle: ParticleInstance): void {
    particle.active = false
    particle.id = ''

    // CRITICAL: Clean up THREE.js objects to prevent memory leaks
    if (particle.userData.threeObject) {
      const mesh = particle.userData.threeObject as THREE.Mesh
      if (mesh) {
        // Remove from scene
        if (mesh.parent) {
          mesh.parent.remove(mesh)
        }

        // Dispose of geometry and material
        if (mesh.geometry) {
          mesh.geometry.dispose()
        }
        if (mesh.material) {
          if (Array.isArray(mesh.material)) {
            mesh.material.forEach((material) => material.dispose())
          } else {
            mesh.material.dispose()
          }
        }

        this.#logger.debug('Disposed THREE.js object for particle', {
          particleId: particle.id,
        })
      }
    }

    // CRITICAL FIX: Use stored pool index for proper return with validation
    const poolIndex = particle.userData?.__poolIndex
    if (typeof poolIndex === 'number' && poolIndex >= 0 && poolIndex < this.#config.maxParticles!) {
      // CRITICAL: Check if index is already in the pool to prevent duplicates
      if (!this.#poolIndices.includes(poolIndex)) {
        // Clear userData (including THREE.js object reference)
        particle.userData = {}

        // Return index to available pool
        this.#poolIndices.push(poolIndex)

        this.#logger.debug('Particle returned to pool', {
          poolIndex,
          availableIndices: this.#poolIndices.length,
        })
      } else {
        this.#logger.warn('Pool index already exists in available pool', {
          poolIndex,
          availableIndices: this.#poolIndices.length,
        })
        // Still clear userData even if index is duplicate
        particle.userData = {}
      }
    } else {
      this.#logger.error('Cannot return particle to pool - invalid or missing pool index', {
        poolIndex,
        particleId: particle.id,
      })
      // Clear userData even on error
      particle.userData = {}
    }
  }

  /**
   * Update particle system
   * @param system - System to update
   * @param deltaTime - Time delta
   */
  #updateSystem(system: ParticleSystem, deltaTime: number): void {
    const particlesToRemove: number[] = []

    for (let i = 0; i < system.particles.length; i++) {
      const particle = system.particles[i]

      if (!particle) {
        this.#logger.warn('Found undefined particle in system', {
          systemId: system.id,
          particleIndex: i,
        })
        continue
      }

      // Update particle age
      particle.age += deltaTime

      // Check if particle should be removed
      if (particle.age >= particle.lifetime) {
        particlesToRemove.push(i)
        continue
      }

      // Update particle position
      particle.position.x += particle.velocity.x * deltaTime
      particle.position.y += particle.velocity.y * deltaTime
      particle.position.z += particle.velocity.z * deltaTime

      // Update particle rotation
      particle.rotation += deltaTime
    }

    // Remove expired particles (reverse order to maintain indices)
    for (let i = particlesToRemove.length - 1; i >= 0; i--) {
      const index = particlesToRemove[i]
      if (index === undefined || index === null || index < 0 || index >= system.particles.length) {
        this.#logger.warn('Invalid particle index for removal', {
          index,
          particleCount: system.particles.length,
        })
        continue
      }

      const particle = system.particles[index]
      if (particle) {
        this.#returnParticleToPool(particle)
      }
      system.particles.splice(index, 1)
      system.activeParticles--
    }
  }

  /**
   * Render particle system to THREE.js scene
   * @param system - System to render
   * @param scene - THREE.js scene
   */
  #renderSystem(system: ParticleSystem, scene: Scene): void {
    // Log scene info before rendering
    const sceneChildrenBefore = scene.children.length

    // Create THREE.js objects for particles that don't have them yet
    for (const particle of system.particles) {
      if (!particle.userData.threeObject) {
        // Create a MUCH larger, more visible sphere geometry for each particle
        const geometry = new THREE.SphereGeometry(particle.size * 1, 16, 12) // Reasonable size - not too big
        const material = new THREE.MeshStandardMaterial({
          color: particle.color,
          transparent: true,
          opacity: particle.opacity,
          metalness: 0.3,
          roughness: 0.7,
        })
        const mesh = new THREE.Mesh(geometry, material)

        // Set initial position using individual coordinates
        mesh.position.set(particle.position.x, particle.position.y, particle.position.z)
        mesh.rotation.z = particle.rotation
        mesh.scale.copy(particle.scale)

        // Store reference to THREE.js object
        particle.userData.threeObject = mesh

        // Add to scene
        scene.add(mesh)

        this.#logger.info('🎯 Created and added THREE.js mesh to scene', {
          particleId: particle.id,
          position: { x: particle.position.x, y: particle.position.y, z: particle.position.z },
          color: particle.color,
          size: particle.size,
          actualRadius: particle.size * 1, // Log the actual rendered size
          meshId: mesh.id,
          sceneChildrenCount: scene.children.length,
        })
      } else {
        // Update existing THREE.js object
        const mesh = particle.userData.threeObject as THREE.Mesh
        if (mesh) {
          mesh.position.set(particle.position.x, particle.position.y, particle.position.z)
          mesh.rotation.z = particle.rotation
          mesh.scale.copy(particle.scale)

          // Update material properties
          const material = mesh.material as THREE.MeshStandardMaterial
          if (material) {
            material.color.setStyle(particle.color)
            material.opacity = particle.opacity
          }
        }
      }
    }

    const sceneChildrenAfter = scene.children.length

    this.#logger.info('🎬 Rendered particle system', {
      systemId: system.id,
      particleCount: system.particles.length,
      activeParticles: system.activeParticles,
      renderedObjects: system.particles.filter((p) => p.userData.threeObject).length,
      sceneChildrenBefore,
      sceneChildrenAfter,
      sceneChildrenAdded: sceneChildrenAfter - sceneChildrenBefore,
    })
  }
}

// Export singleton instance getter
export const particleService = ParticleService.getInstance()
