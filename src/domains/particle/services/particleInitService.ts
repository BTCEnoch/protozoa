/**
 * @fileoverview ParticleInitService Implementation (Template)
 * @module @/domains/particle/services/particleInitService
 * @version 1.0.0
 */

import type { 
  IParticleInitService, 
  ParticleInitConfig, 
  ParticleAllocationResult 
} from "@/domains/particle/interfaces/IParticleInitService"
import type { IParticle, ParticleRole, EmergentBehavior } from "@/domains/particle/types/particle.types"
import type { IRNGService } from "@/domains/rng/interfaces/IRNGService"
import type { IPhysicsService } from "@/domains/physics/interfaces/IPhysicsService"
import type { ITraitService } from "@/domains/trait/interfaces/ITraitService"
import { logger, perfLogger } from "@/shared/lib/logger"

/**
 * Basic Particle Initialization Service
 * Handles bulk particle creation with 500-particle allocation algorithm
 */
export class ParticleInitService implements IParticleInitService {
  private static instance: ParticleInitService | null = null
  
  /**
   * Get singleton instance
   */
  public static getInstance(): ParticleInitService {
    if (!ParticleInitService.instance) {
      ParticleInitService.instance = new ParticleInitService()
    }
    return ParticleInitService.instance
  }

  private constructor() {
    logger.info("🎯 ParticleInitService instantiated")
  }

  /* ------------------------------- Private Fields ------------------------------- */
  #rngService: IRNGService | null = null
  #physicsService: IPhysicsService | null = null
  #traitService: ITraitService | null = null
  #initialized = false

  /* ------------------------------- Public Methods ------------------------------- */
  
  /**
   * Initialize service with dependencies
   */
  async initialize(deps: {
    rng: IRNGService
    physics: IPhysicsService
    trait: ITraitService
  }): Promise<void> {
    const timer = 'particle_init_initialize'
    perfLogger.startTimer(timer)
    
    try {
      this.#rngService = deps.rng
      this.#physicsService = deps.physics
      this.#traitService = deps.trait
      this.#initialized = true
      
      const duration = perfLogger.endTimer(timer)
      logger.info("✅ ParticleInitService initialized", { duration: `${duration.toFixed(2)}ms` })
      
    } catch (error) {
      perfLogger.endTimer(timer)
      logger.error("❌ ParticleInitService initialization failed", { error })
      throw error
    }
  }

  /**
   * Initialize particles with 500-particle allocation algorithm
   * Implementation: 40 base particles + 460 variable particles
   */
  async initializeParticles(config: ParticleInitConfig): Promise<ParticleAllocationResult> {
    if (!this.#initialized) {
      throw new Error("ParticleInitService not initialized")
    }

    const timer = 'particle_init_allocate'
    perfLogger.startTimer(timer)
    
    try {
      logger.info("🎯 Starting particle allocation", { totalCount: config.totalCount })
      
      const particles: IParticle[] = []
      const roleStats: Record<ParticleRole, number> = {} as any
      
      // Initialize role stats
      Object.values(ParticleRole).forEach(role => {
        roleStats[role] = 0
      })

      // Phase 1: Allocate base particles (deterministic)
      const baseParticles = await this.#allocateBaseParticles(config.baseCount)
      particles.push(...baseParticles)
      
      // Update stats for base particles
      baseParticles.forEach(p => roleStats[p.role]++)
      
      // Phase 2: Allocate variable particles (RNG-based)
      const variableParticles = await this.#allocateVariableParticles(config.variableCount, config.roleWeights)
      particles.push(...variableParticles)
      
      // Update stats for variable particles
      variableParticles.forEach(p => roleStats[p.role]++)

      const duration = perfLogger.endTimer(timer)
      
      const result: ParticleAllocationResult = {
        particles,
        stats: {
          totalAllocated: particles.length,
          byRole: roleStats,
          withEmergentBehavior: particles.filter(p => p.emergentBehavior !== EmergentBehavior.NONE).length,
          allocationTime: duration,
          memoryUsage: this.#estimateMemoryUsage(particles)
        },
        errors: []
      }
      
      logger.info("✅ Particle allocation completed", { 
        total: result.stats.totalAllocated,
        duration: `${duration.toFixed(2)}ms`
      })
      
      return result
      
    } catch (error) {
      perfLogger.endTimer(timer)
      logger.error("❌ Particle allocation failed", { error })
      throw error
    }
  }

  /**
   * Get default configuration for 500-particle allocation
   */
  getDefaultConfig(): ParticleInitConfig {
    return {
      totalCount: 500,
      baseCount: 40,
      variableCount: 460,
      bounds: {
        min: { x: -100, y: -100, z: -100 },
        max: { x: 100, y: 100, z: 100 }
      },
      roleWeights: {
        [ParticleRole.CORE]: 0.2,
        [ParticleRole.ENERGY]: 0.25,
        [ParticleRole.BARRIER]: 0.15,
        [ParticleRole.SENSOR]: 0.1,
        [ParticleRole.TRANSPORT]: 0.1,
        [ParticleRole.REPRODUCTIVE]: 0.05,
        [ParticleRole.DEFENSIVE]: 0.1,
        [ParticleRole.ADAPTIVE]: 0.05
      },
      enableEmergentBehavior: true
    }
  }

  /**
   * Health check
   */
  async healthCheck(): Promise<boolean> {
    try {
      const isHealthy = this.#initialized && 
        this.#rngService !== null && 
        this.#physicsService !== null && 
        this.#traitService !== null
        
      if (isHealthy) {
        logger.debug("✅ ParticleInitService health check passed")
      } else {
        logger.error("❌ ParticleInitService health check failed")
      }
      
      return isHealthy
    } catch (error) {
      logger.error("❌ ParticleInitService health check error", { error })
      return false
    }
  }

  /**
   * Dispose service and cleanup
   */
  dispose(): void {
    logger.info("🧹 Disposing ParticleInitService")
    
    this.#rngService = null
    this.#physicsService = null
    this.#traitService = null
    this.#initialized = false
    
    ParticleInitService.instance = null
    
    logger.info("✅ ParticleInitService disposed")
  }

  /* ------------------------------- Private Helpers ------------------------------- */
  
  /**
   * Allocate base particles (deterministic distribution)
   */
  async #allocateBaseParticles(count: number): Promise<IParticle[]> {
    logger.debug("🎯 Allocating base particles", { count })
    
    const particles: IParticle[] = []
    const rolesPerType = Math.floor(count / Object.keys(ParticleRole).length)
    
    for (const role of Object.values(ParticleRole)) {
      for (let i = 0; i < rolesPerType; i++) {
        const particle = this.#createParticle(role, EmergentBehavior.NONE)
        particles.push(particle)
      }
    }
    
    return particles
  }

  /**
   * Allocate variable particles (RNG-based distribution)
   */
  async #allocateVariableParticles(
    count: number, 
    roleWeights: Record<ParticleRole, number>
  ): Promise<IParticle[]> {
    logger.debug("🎯 Allocating variable particles", { count })
    
    const particles: IParticle[] = []
    
    for (let i = 0; i < count; i++) {
      const role = this.#selectRoleByWeight(roleWeights)
      const behavior = this.#selectEmergentBehavior()
      const particle = this.#createParticle(role, behavior)
      particles.push(particle)
    }
    
    return particles
  }

  /**
   * Create a single particle with given properties
   */
  #createParticle(role: ParticleRole, behavior: EmergentBehavior): IParticle {
    const id = `particle_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    
    // Basic particle implementation - will be enhanced in next chunk
    return {
      id,
      role,
      state: "active" as any,
      emergentBehavior: behavior,
      age: 0,
      maxLifespan: 10000,
      visuals: {
        color: '#ffffff',
        size: 1.0,
        opacity: 1.0,
        effects: {},
        material: { metallic: 0.5, roughness: 0.5, emission: 0.0 }
      },
      physics: {
        position: { x: 0, y: 0, z: 0 },
        velocity: { x: 0, y: 0, z: 0 },
        acceleration: { x: 0, y: 0, z: 0 },
        mass: 1.0,
        drag: 0.1,
        collisionRadius: 1.0,
        collidable: true,
        forces: {
          gravity: { x: 0, y: 0, z: 0 },
          electromagnetic: { x: 0, y: 0, z: 0 },
          interParticle: { x: 0, y: 0, z: 0 },
          external: { x: 0, y: 0, z: 0 }
        }
      },
      energy: {
        current: 1.0,
        maximum: 1.0,
        consumptionRate: 0.01,
        generationRate: 0.02,
        efficiency: 0.8,
        storageCapacity: 1.0,
        transfer: { canGive: true, canReceive: true, rate: 0.1, efficiency: 0.9 }
      },
      genetics: { dna: '', mutationRate: 0.01, generation: 0, parents: [] },
      connections: { connected: [], strengths: [], types: [] },
      metrics: { distanceTraveled: 0, energyConsumed: 0, energyProduced: 0, collisions: 0, reproductions: 0 },
      userData: {},
      lastUpdated: Date.now()
    }
  }

  /**
   * Select role based on weighted probabilities
   */
  #selectRoleByWeight(weights: Record<ParticleRole, number>): ParticleRole {
    const random = this.#rngService!.random()
    let cumulative = 0
    
    for (const [role, weight] of Object.entries(weights)) {
      cumulative += weight
      if (random <= cumulative) {
        return role as ParticleRole
      }
    }
    
    return ParticleRole.CORE // fallback
  }

  /**
   * Select emergent behavior with 30% probability
   */
  #selectEmergentBehavior(): EmergentBehavior {
    const random = this.#rngService!.random()
    
    if (random < 0.3) {
      const behaviors = Object.values(EmergentBehavior).filter(b => b !== EmergentBehavior.NONE)
      const index = Math.floor(this.#rngService!.random() * behaviors.length)
      return behaviors[index]
    }
    
    return EmergentBehavior.NONE
  }

  /**
   * Estimate memory usage of particle array
   */
  #estimateMemoryUsage(particles: IParticle[]): number {
    // Rough estimate: ~2KB per particle
    return particles.length * 2048
  }
}

export const particleInitService = ParticleInitService.getInstance()