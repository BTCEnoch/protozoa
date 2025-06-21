/**
 * @fileoverview Physics Types Definition
 * @description Type definitions for physics simulation domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3 } from "three";

/**
 * Physics simulation algorithm types
 */
export type PhysicsAlgorithm = "verlet" | "euler" | "runge-kutta";

/**
 * Collision detection methods
 */
export type CollisionMethod = "basic" | "spatial-hash" | "octree" | "bvh";

/**
 * Physics simulation state
 */
export interface PhysicsState {
  /** Whether physics is running */
  isRunning: boolean;
  /** Current simulation time */
  simulationTime: number;
  /** Last frame delta time */
  lastDeltaTime: number;
  /** Physics algorithm being used */
  algorithm: PhysicsAlgorithm;
  /** Collision detection method */
  collisionMethod: CollisionMethod;
  /** Number of active particles */
  activeParticles: number;
}

/**
 * Geometry distribution patterns
 */
export type DistributionPattern =
  | "grid"
  | "circle"
  | "sphere"
  | "random"
  | "fibonacci"
  | "hexagonal";

/**
 * Kinematic interpolation types
 */
export type InterpolationType =
  | "linear"
  | "smooth"
  | "ease-in"
  | "ease-out"
  | "ease-in-out";

/**
 * Geometry bounds definition
 */
export interface GeometryBounds {
  /** Minimum coordinates */
  min: Vector3;
  /** Maximum coordinates */
  max: Vector3;
  /** Center point */
  center: Vector3;
  /** Radius (for spherical bounds) */
  radius?: number;
}
