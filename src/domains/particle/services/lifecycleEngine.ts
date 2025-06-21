/**
 * @fileoverview Particle Lifecycle Engine Implementation
 * @description Manages particle birth, aging, death, and cleanup cycles
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3 } from "three";
import { particleService } from '@/domains/particle/services/ParticleService'
import { createServiceLogger } from '@/shared/lib/logger'
import type { ILifecycleEngine } from '@/domains/particle/interfaces/ILifecycleEngine'
import type { ParticleCreationData } from '@/domains/particle/types/particle.types'

/**
 * Lifecycle Engine managing particle birth, aging, death cycles
 * Implements singleton pattern for centralized lifecycle management
 */
export class LifecycleEngine implements ILifecycleEngine {
  /** Singleton instance */
  static #instance: LifecycleEngine | null = null
  
  /** Winston logger instance */
  #log = createServiceLogger('PARTICLE_LIFECYCLE')
  
  /** Particles scheduled for death */
  #deathQueue: Set<string> = new Set()
  
  /** Birth rate limit (particles per second) */
  #birthRateLimit: number = 100
  
  /** Last birth timestamp for rate limiting */
  #lastBirthTime: number = 0
  
  /** Private constructor enforcing singleton pattern */
  private constructor() {
    this.#log.info("LifecycleEngine initialized")
  }
  
  /**
   * Get singleton instance of LifecycleEngine
   * @returns LifecycleEngine singleton instance
   */
  static getInstance(): LifecycleEngine {
    if (!this.#instance) {
      this.#instance = new LifecycleEngine()
    }
    return this.#instance
  }
  
  /**
   * Birth new particles with specified configuration
   * @param count - Number of particles to create
   * @param systemId - Target particle system ID
   * @param baseConfig - Base configuration for new particles
   */
  birth(count: number, systemId: string = "default", baseConfig?: Partial<ParticleCreationData>): void {
    const now = performance.now()
    
    // Apply birth rate limiting
    if (now - this.#lastBirthTime < (1000 / this.#birthRateLimit)) {
      this.#log.warn("Birth rate limit exceeded", { 
        count, 
        timeSinceLastBirth: now - this.#lastBirthTime 
      })
      return
    }
    
    try {
      const particleData: ParticleCreationData[] = []
      
      for (let i = 0; i < count; i++) {
        const newParticleData: ParticleCreationData = {
          type: baseConfig?.type || "core",
          position: baseConfig?.position || new Vector3(
            (Math.random() - 0.5) * 10,
            (Math.random() - 0.5) * 10,
            (Math.random() - 0.5) * 10
          ),
          velocity: baseConfig?.velocity || new Vector3(
            (Math.random() - 0.5) * 2,
            (Math.random() - 0.5) * 2,
            (Math.random() - 0.5) * 2
          ),
          scale: baseConfig?.scale || new Vector3(1, 1, 1),
          rotation: baseConfig?.rotation || Math.random() * Math.PI * 2,
          color: baseConfig?.color || {
            r: Math.random(),
            g: Math.random(),
            b: Math.random()
          },
          opacity: baseConfig?.opacity || 1.0,
          lifetime: baseConfig?.lifetime || (5 + Math.random() * 10), // 5-15 seconds
          userData: { ...baseConfig?.userData }
        }
        
        particleData.push(newParticleData)
      }
      
      const createdIds = particleService.addParticles(systemId, particleData)
      this.#lastBirthTime = now
      
      this.#log.info('Particles birthed successfully', { 
        count, 
        systemId, 
        createdIds: createdIds.length 
      })
      
    } catch (error) {
      this.#log.error('Failed to birth particles', { 
        count, 
        systemId, 
        error: error.message 
      })
    }
  }
  
  /**
   * Update particle lifecycles (aging, death detection)
   * @param deltaTime - Time elapsed since last update in seconds
   */
  update(deltaTime: number): void {
    try {
      // Update particle service
      particleService.update(deltaTime)
      
      // Process death queue
      this.#processDeathQueue()
      
      // Check for particles that have exceeded their lifetime
      this.#checkForNaturalDeath()
      
    } catch (error) {
      this.#log.error('Lifecycle update failed', { 
        deltaTime, 
        error: error.message 
      })
    }
  }
  
  /**
   * Mark particle for death (adds to death queue)
   * @param particleId - ID of particle to kill
   * @param immediate - Whether to kill immediately or queue for next update
   */
  kill(particleId: string, immediate: boolean = false): void {
    try {
      if (immediate) {
        this.#executeKill(particleId)
      } else {
        this.#deathQueue.add(particleId)
        this.#log.debug('Particle queued for death', { particleId })
      }
    } catch (error) {
      this.#log.error('Failed to kill particle', { 
        particleId, 
        immediate, 
        error: error.message 
      })
    }
  }
  
  /**
   * Process death queue and remove dead particles
   */
  #processDeathQueue(): void {
    if (this.#deathQueue.size === 0) return
    
    const particlesToKill = Array.from(this.#deathQueue)
    this.#deathQueue.clear()
    
    for (const particleId of particlesToKill) {
      this.#executeKill(particleId)
    }
    
    this.#log.debug('Processed death queue', { 
      killedCount: particlesToKill.length 
    })
  }
  
  /**
   * Execute particle death (remove from service)
   * @param particleId - ID of particle to remove
   */
  #executeKill(particleId: string): void {
    try {
      // Find which system contains this particle
      const systems = particleService.getAllSystems()
      
      for (const system of systems) {
        const particleIndex = system.particles.findIndex(p => p.id === particleId)
        if (particleIndex !== -1) {
          particleService.removeParticles(system.id, [particleId])
          this.#log.debug('Particle killed', { particleId, systemId: system.id })
          return
        }
      }
      
      this.#log.warn('Particle not found for killing', { particleId })
      
    } catch (error) {
      this.#log.error('Failed to execute particle kill', { 
        particleId, 
        error: error.message 
      })
    }
  }
  
  /**
   * Check all particles for natural death (exceeded lifetime)
   */
  #checkForNaturalDeath(): void {
    try {
      const systems = particleService.getAllSystems()
      let naturalDeathCount = 0
      
      for (const system of systems) {
        for (const particle of system.particles) {
          if (particle.age >= particle.lifetime) {
            this.#deathQueue.add(particle.id)
            naturalDeathCount++
          }
        }
      }
      
      if (naturalDeathCount > 0) {
        this.#log.debug('Particles marked for natural death', { 
          count: naturalDeathCount 
        })
      }
      
    } catch (error) {
      this.#log.error('Failed to check for natural death', { 
        error: error.message 
      })
    }
  }
  
  /**
   * Get lifecycle statistics
   * @returns Lifecycle metrics object
   */
  getMetrics(): {
    queuedForDeath: number;
    birthRateLimit: number;
    lastBirthTime: number;
  } {
    return {
      queuedForDeath: this.#deathQueue.size,
      birthRateLimit: this.#birthRateLimit,
      lastBirthTime: this.#lastBirthTime
    }
  }
  
  /**
   * Set birth rate limit
   * @param ratePerSecond - Maximum births per second
   */
  setBirthRateLimit(ratePerSecond: number): void {
    this.#birthRateLimit = Math.max(1, ratePerSecond)
    this.#log.info('Birth rate limit updated', { ratePerSecond: this.#birthRateLimit })
  }
  
  /**
   * Dispose of resources and cleanup
   */
  dispose(): void {
    this.#log.info("Disposing LifecycleEngine")
    
    // Clear death queue
    this.#deathQueue.clear()
    
    // Reset singleton instance
    LifecycleEngine.#instance = null
    
    this.#log.info("LifecycleEngine disposed")
  }
}

// Export singleton instance
export const lifecycleEngine = LifecycleEngine.getInstance()
