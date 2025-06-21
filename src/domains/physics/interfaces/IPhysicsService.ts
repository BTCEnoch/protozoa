/**
 * @fileoverview Physics Service Interface Definition
 * @description Defines the contract for physics simulation services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3 } from "three";

/**
 * Configuration options for physics service initialization
 */
export interface PhysicsConfig {
  /** Target frame rate for physics calculations */
  targetFPS?: number;
  /** Gravity strength */
  gravity?: number;
  /** Air resistance factor */
  damping?: number;
}

/**
 * Particle physics properties
 */
export interface ParticlePhysics {
  /** Particle position */
  position: Vector3;
  /** Particle velocity */
  velocity: Vector3;
  /** Particle acceleration */
  acceleration: Vector3;
  /** Particle mass */
  mass: number;
  /** Particle radius for collision detection */
  radius: number;
  /** Whether particle is affected by gravity */
  useGravity: boolean;
}

/**
 * Transform matrix for kinematic updates
 */
export interface Transform {
  /** Position vector */
  position: Vector3;
  /** Rotation quaternion */
  rotation: { x: number; y: number; z: number; w: number };
  /** Scale vector */
  scale: Vector3;
  /** Combined transformation matrix */
  matrix: Float32Array;
}

/**
 * Physics service interface defining kinematic operations and geometry helpers
 * Formations now handle all movement - this service provides utility functions
 */
export interface IPhysicsService {
  /**
   * Initialize the physics service with configuration
   * @param config - Physics configuration options
   */
  initialize(config?: PhysicsConfig): Promise<void>;

  /**
   * Apply gravity to a particle (utility function)
   * @param particle - Particle to apply gravity to
   * @param deltaTime - Time delta
   */
  applyGravity(particle: ParticlePhysics, deltaTime: number): void;

  /**
   * Distribute particles in a geometric pattern
   * @param count - Number of particles to distribute
   * @param pattern - Distribution pattern type
   * @param bounds - Boundary constraints
   * @returns Array of positions
   */
  distributeParticles(count: number, pattern: string, bounds: Vector3): Vector3[];

  /**
   * Create transform matrix from position, rotation, scale
   * @param position - Position vector
   * @param rotation - Rotation quaternion
   * @param scale - Scale vector
   * @returns Transform object with matrix
   */
  createTransform(position: Vector3, rotation: any, scale: Vector3): Transform;

  /**
   * Interpolate between two transforms
   * @param from - Starting transform
   * @param to - Target transform
   * @param alpha - Interpolation factor (0-1)
   * @returns Interpolated transform
   */
  interpolateTransform(from: Transform, to: Transform, alpha: number): Transform;

  /**
   * Get current physics performance metrics
   * @returns Physics performance data
   */
  getMetrics(): PhysicsMetrics;

  /**
   * Reset physics simulation state
   */
  reset(): void;

  /**
   * Dispose of resources and cleanup
   */
  dispose(): void;
}

/**
 * Physics performance metrics (simplified for kinematic helpers)
 */
export interface PhysicsMetrics {
  /** Current frame rate */
  currentFPS: number;
  /** Average frame time in milliseconds */
  averageFrameTime: number;
  /** Number of transform calculations per frame */
  transformCalculations: number;
  /** Number of geometry operations per frame */
  geometryOperations: number;
  /** Memory usage in MB */
  memoryUsage: number;
}
