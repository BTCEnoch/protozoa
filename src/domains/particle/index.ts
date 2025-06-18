/**
 * @fileoverview Particle Domain Exports
 * @description Main export file for Particle domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { ParticleService, particleService } from "./services/particleService";

// Interface exports
export type {
  IParticleService,
  ParticleConfig,
  ParticleInstance,
  ParticleSystem,
  ParticleMetrics
} from "./interfaces/IParticleService";

// Type exports
export type {
  ParticleType,
  RenderingMode,
  BlendingMode,
  ParticleSystemConfig,
  ParticleCreationData,
  ParticleUpdateData,
  ParticleGeometry,
  ParticleMaterial,
  ParticleBatch,
  ParticleLOD,
  ParticleCulling
} from "./types/particle.types";
