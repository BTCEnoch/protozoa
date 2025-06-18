
/**
 * @fileoverview Particle Domain Exports
 * @description Main export file for Particle domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { ParticleService, particleService } from './services/particleService';

// Interface exports
export type {
    IParticleService,
    ParticleConfig,
    ParticleInstance, ParticleMetrics, ParticleSystem
} from './interfaces/IParticleService';

// Type exports
export type {
    BlendingMode, ParticleBatch, ParticleCreationData, ParticleCulling, ParticleGeometry, ParticleLOD, ParticleMaterial, ParticleSystemConfig, ParticleType, ParticleUpdateData, RenderingMode
} from './types/particle.types';

