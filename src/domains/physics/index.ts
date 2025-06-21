/**
 * @fileoverview Physics Domain Exports
 * @description Main export file for Physics domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { PhysicsService, physicsService, calculatePhysicsStep, clampVelocity } from "./services/PhysicsService";

// Interface exports
export type {
  IPhysicsService,
  PhysicsConfig,
  ParticlePhysics,
  Transform,
  PhysicsMetrics
} from "./interfaces/IPhysicsService";

// Type exports
export type {
  PhysicsState,
  DistributionPattern,
  InterpolationType,
  GeometryBounds,
  PhysicsAlgorithm,
  CollisionMethod
} from "./types/physics.types";
