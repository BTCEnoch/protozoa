/**
 * @fileoverview Particle Domain Export Index
 * @description Central export point for particle domain components
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { ParticleService, particleService } from "./services/ParticleService";
export { ParticleInitService, particleInitService } from "./services/particleInitService";

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
