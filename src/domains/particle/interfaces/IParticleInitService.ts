/**
 * @fileoverview IParticleInitService Interface (Template)
 * @module @/domains/particle/interfaces/IParticleInitService
 * @version 1.0.0
 */

import type { IParticle, ParticleRole, EmergentBehavior } from "@/domains/particle/types/particle.types"
import type { IVector3 } from "@/shared/types/vectorTypes"
import type { IRNGService } from "@/domains/rng/interfaces/IRNGService"
import type { IPhysicsService } from "@/domains/physics/interfaces/IPhysicsService"
import type { ITraitService } from "@/domains/trait/interfaces/ITraitService"

/**
 * Particle initialization configuration
 */
export interface ParticleInitConfig {
  /** Total number of particles to initialize */
  totalCount: number
  
  /** Base particle count (consistent across initializations) */
  baseCount: number
  
  /** Variable particle count (RNG-generated) */
  variableCount: number
  
  /** Spatial bounds for particle placement */
  bounds: {
    min: IVector3
    max: IVector3
  }
  
  /** Role distribution weights */
  roleWeights: Record<ParticleRole, number>
  
  /** Enable emergent behavior initialization */
  enableEmergentBehavior: boolean
  
  /** Bitcoin block seed for deterministic generation */
  blockSeed?: number
}

/**
 * Batch initialization options
 */
export interface BatchInitOptions {
  /** Batch size for memory-efficient initialization */
  batchSize: number
  
  /** Progress callback */
  onProgress?: (completed: number, total: number) => void
  
  /** Use Web Workers for parallel initialization */
  useWorkers?: boolean
  
  /** Maximum concurrent workers */
  maxWorkers?: number
}

/**
 * Particle allocation result
 */
export interface ParticleAllocationResult {
  /** Successfully allocated particles */
  particles: IParticle[]
  
  /** Allocation statistics */
  stats: {
    /** Total particles allocated */
    totalAllocated: number
    
    /** Particles by role */
    byRole: Record<ParticleRole, number>
    
    /** Particles with emergent behavior */
    withEmergentBehavior: number
    
    /** Allocation time in milliseconds */
    allocationTime: number
    
    /** Memory usage in bytes */
    memoryUsage: number
  }
  
  /** Any allocation errors */
  errors: string[]
}

/**
 * Particle distribution metrics
 */
export interface ParticleDistributionMetrics {
  /** Spatial distribution analysis */
  spatial: {
    /** Average distance between particles */
    averageDistance: number
    
    /** Clustering coefficient */
    clusteringCoefficient: number
    
    /** Density per unit volume */
    density: number
  }
  
  /** Role distribution analysis */
  roles: {
    /** Entropy of role distribution */
    entropy: number
    
    /** Most common role */
    dominantRole: ParticleRole
    
    /** Balance score (0-1, 1 = perfectly balanced) */
    balanceScore: number
  }
  
  /** Emergent behavior metrics */
  emergentBehavior: {
    /** Percentage with emergent behavior */
    percentage: number
    
    /** Most common behavior */
    dominantBehavior: EmergentBehavior
    
    /** Behavior diversity index */
    diversityIndex: number
  }
}

/**
 * Enhanced Particle Initialization Service Interface
 * Handles bulk particle creation with role distribution and emergent behavior
 */
export interface IParticleInitService {
  /**
   * Initialize the service with dependencies
   * @param deps - Service dependencies
   */
  initialize(deps: {
    rng: IRNGService
    physics: IPhysicsService
    trait: ITraitService
  }): Promise<void>
  
  /**
   * Initialize particles with 500-particle allocation algorithm
   * @param config - Initialization configuration
   * @returns Allocation result
   */
  initializeParticles(config: ParticleInitConfig): Promise<ParticleAllocationResult>
  
  /**
   * Initialize particles in batches for memory efficiency
   * @param config - Initialization configuration
   * @param batchOptions - Batch processing options
   * @returns Allocation result
   */
  initializeParticlesBatch(
    config: ParticleInitConfig,
    batchOptions: BatchInitOptions
  ): Promise<ParticleAllocationResult>
  
  /**
   * Allocate particles with specific role distribution
   * @param totalCount - Total particles to allocate
   * @param roleWeights - Role distribution weights
   * @returns Array of particles with assigned roles
   */
  allocateWithRoleDistribution(
    totalCount: number,
    roleWeights: Record<ParticleRole, number>
  ): Promise<IParticle[]>
  
  /**
   * Apply emergent behavior to particles
   * @param particles - Particles to enhance
   * @param behaviorProbability - Probability of emergent behavior (0-1)
   * @returns Enhanced particles
   */
  applyEmergentBehavior(
    particles: IParticle[],
    behaviorProbability: number
  ): Promise<IParticle[]>
  
  /**
   * Analyze particle distribution quality
   * @param particles - Particles to analyze
   * @returns Distribution metrics
   */
  analyzeDistribution(particles: IParticle[]): Promise<ParticleDistributionMetrics>
  
  /**
   * Validate particle initialization results
   * @param result - Allocation result to validate
   * @returns Validation success
   */
  validateAllocation(result: ParticleAllocationResult): Promise<boolean>
  
  /**
   * Get default initialization configuration
   * @returns Default configuration
   */
  getDefaultConfig(): ParticleInitConfig
  
  /**
   * Calculate optimal batch size for given constraints
   * @param totalParticles - Total particles to process
   * @param memoryLimit - Memory limit in bytes
   * @returns Optimal batch size
   */
  calculateOptimalBatchSize(totalParticles: number, memoryLimit: number): number
  
  /**
   * Perform health check on the service
   * @returns Service health status
   */
  healthCheck(): Promise<boolean>
  
  /**
   * Dispose service and cleanup resources
   */
  dispose(): void
}
