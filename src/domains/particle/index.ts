/**
 * @fileoverview Particle Domain Exports
 * @module @/domains/particle
 */

// Service exports
export { ParticleInitService, particleInitService } from './services/particleInitService'
export { ParticleService, particleService } from './services/ParticleService'

// Interface exports
export type { IParticleInitService } from './interfaces/IParticleInitService'
export type { IParticleService } from './interfaces/IParticleService'

// Type exports
export type {
  IParticle,
  ParticleRole,
  EmergentBehavior,
  ParticleState,
  ParticleVisuals,
  ParticlePhysics,
  ParticleEnergy,
  ParticleFactoryConfig,
  ParticleUpdateResult,
} from './types/particle.types'

export type {
  ParticleInitConfig,
  ParticleAllocationResult,
  BatchInitOptions,
  ParticleDistributionMetrics,
} from './interfaces/IParticleInitService'
