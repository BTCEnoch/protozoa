/**
 * @fileoverview Particle Domain Export Index
 * @description Central export point for particle domain components
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { ParticleService } from "./services/ParticleService";

// Interface exports
export type { IParticleService, ParticleConfig, ParticleInstance, ParticleSystem } from "./interfaces/IParticleService";

// Type exports
export type {
  ParticleType,
  RenderingMode,
  BlendingMode,
  ParticleSystemConfig,
  ParticleCreationData,
  ParticleUpdateData,
  ParticleMetrics
} from "./types/particle.types";
