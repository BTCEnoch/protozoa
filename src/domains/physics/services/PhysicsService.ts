/**
 * @fileoverview Physics Service Implementation (Simplified)
 * @description Kinematic helpers and geometry utilities - formations handle movement
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3, Matrix4, Quaternion } from "three";
import { IPhysicsService, PhysicsConfig, ParticlePhysics, Transform, PhysicsMetrics } from "@/domains/physics/interfaces/IPhysicsService";
import {
  PhysicsState,
  DistributionPattern,
  InterpolationType,
  GeometryBounds,
  PhysicsAlgorithm,
  CollisionMethod
} from "@/domains/physics/types/physics.types";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * Physics Service implementing kinematic helpers and geometry utilities
 * Simplified service - formations now handle all movement calculations
 * Follows singleton pattern for application-wide geometry consistency
 */
export class PhysicsService implements IPhysicsService {
  /** Singleton instance */
  static #instance: PhysicsService | null = null;

  /** Physics simulation state */
  #state: PhysicsState;

  /** Service configuration */
  #config: PhysicsConfig;

  /** Performance metrics */
  #metrics: PhysicsMetrics;

  /** Winston logger instance */
  #logger = createServiceLogger("PhysicsService");

  /** Frame timing for performance monitoring */
  #frameStartTime: number = 0;
  #frameHistory: number[] = [];

  /**
   * Private constructor enforcing singleton pattern
   * Initializes physics service with kinematic helpers
   */
  private constructor() {
    this.#logger.info("Initializing PhysicsService singleton instance (kinematic mode)");

    // Initialize default configuration
    this.#config = {
      targetFPS: 60,
      gravity: -9.81,
      damping: 0.99
    };

    // Initialize physics state
    this.#state = {
      isRunning: false,
      simulationTime: 0,
      lastDeltaTime: 0,
      algorithm: "euler",
      collisionMethod: "basic",
      activeParticles: 0
    };

    // Initialize performance metrics
    this.#metrics = {
      currentFPS: 0,
      averageFrameTime: 0,
      transformCalculations: 0,
      geometryOperations: 0,
      memoryUsage: 0
    };

    this.#logger.info("PhysicsService initialized successfully (simplified kinematic mode)");
  }

  /**
   * Get singleton instance of PhysicsService
   * Creates new instance if none exists
   * @returns PhysicsService singleton instance
   */
  public static getInstance(): PhysicsService {
    if (!PhysicsService.#instance) {
      PhysicsService.#instance = new PhysicsService();
    }
    return PhysicsService.#instance;
  }

  /**
   * Initialize the physics service with configuration
   * @param config - Optional physics configuration
   */
  public async initialize(config?: PhysicsConfig): Promise<void> {
    this.#logger.info("Initializing PhysicsService with configuration", { config });

    if (config) {
      this.#config = { ...this.#config, ...config };
    }

    this.#state.isRunning = true;
    this.#logger.info("PhysicsService initialization completed (kinematic mode)");
  }

  /**
   * Distribute particles in a geometric pattern
   * @param count - Number of particles to distribute
   * @param pattern - Distribution pattern type
   * @param bounds - Boundary constraints
   * @returns Array of positions
   */
  public distributeParticles(count: number, pattern: string, bounds: Vector3): Vector3[] {
    this.#frameStartTime = performance.now();
    const positions: Vector3[] = [];

    this.#logger.debug("Distributing particles", { count, pattern, bounds });

    switch (pattern) {
      case "grid":
        positions.push(...this.#distributeGrid(count, bounds));
        break;
      case "circle":
        positions.push(...this.#distributeCircle(count, bounds));
        break;
      case "sphere":
        positions.push(...this.#distributeSphere(count, bounds));
        break;
      case "fibonacci":
        positions.push(...this.#distributeFibonacci(count, bounds));
        break;
      case "random":
      default:
        positions.push(...this.#distributeRandom(count, bounds));
        break;
    }

    this.#metrics.geometryOperations++;
    this.#updateMetrics();

    return positions;
  }

  /**
   * Create transform matrix from position, rotation, scale
   * @param position - Position vector
   * @param rotation - Rotation quaternion
   * @param scale - Scale vector
   * @returns Transform object with matrix
   */
  public createTransform(position: Vector3, rotation: any, scale: Vector3): Transform {
    const matrix = new Matrix4();
    matrix.compose(position, new Quaternion(rotation.x, rotation.y, rotation.z, rotation.w), scale);

    this.#metrics.transformCalculations++;

    return {
      position: position.clone(),
      rotation: { ...rotation },
      scale: scale.clone(),
      matrix: new Float32Array(matrix.elements)
    };
  }

  /**
   * Interpolate between two transforms
   * @param from - Starting transform
   * @param to - Target transform
   * @param alpha - Interpolation factor (0-1)
   * @returns Interpolated transform
   */
  public interpolateTransform(from: Transform, to: Transform, alpha: number): Transform {
    const clampedAlpha = Math.max(0, Math.min(1, alpha));

    const position = from.position.clone().lerp(to.position, clampedAlpha);
    const scale = from.scale.clone().lerp(to.scale, clampedAlpha);

    const fromQuat = new Quaternion(from.rotation.x, from.rotation.y, from.rotation.z, from.rotation.w);
    const toQuat = new Quaternion(to.rotation.x, to.rotation.y, to.rotation.z, to.rotation.w);
    const rotation = fromQuat.slerp(toQuat, clampedAlpha);

    this.#metrics.transformCalculations++;

    return this.createTransform(position, rotation, scale);
  }

  /**
   * Apply gravity to a particle
   * @param particle - Particle to apply gravity to
   * @param deltaTime - Time delta
   */
  public applyGravity(particle: ParticlePhysics, deltaTime: number): void {
    if (!particle.useGravity) return;

    const gravityForce = new Vector3(0, this.#config.gravity! * particle.mass, 0);
    particle.acceleration.add(gravityForce.divideScalar(particle.mass));
  }

  // Private geometry distribution methods

  /**
   * Distribute particles in a grid pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints
   * @returns Array of positions in grid formation
   */
  #distributeGrid(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const side = Math.ceil(Math.cbrt(count));
    const spacing = new Vector3(bounds.x / side, bounds.y / side, bounds.z / side);

    for (let x = 0; x < side; x++) {
      for (let y = 0; y < side; y++) {
        for (let z = 0; z < side && positions.length < count; z++) {
          positions.push(new Vector3(
            (x - side/2) * spacing.x,
            (y - side/2) * spacing.y,
            (z - side/2) * spacing.z
          ));
        }
      }
    }

    return positions;
  }

  /**
   * Distribute particles in a circle pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints (uses x as radius)
   * @returns Array of positions in circular formation
   */
  #distributeCircle(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const radius = bounds.x;

    for (let i = 0; i < count; i++) {
      const angle = (i / count) * 2 * Math.PI;
      positions.push(new Vector3(
        Math.cos(angle) * radius,
        0,
        Math.sin(angle) * radius
      ));
    }

    return positions;
  }

  /**
   * Distribute particles in a sphere pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints (uses x as radius)
   * @returns Array of positions in spherical formation
   */
  #distributeSphere(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const radius = bounds.x;
    const goldenAngle = Math.PI * (3 - Math.sqrt(5));

    for (let i = 0; i < count; i++) {
      const y = 1 - (i / (count - 1)) * 2;
      const radiusAtY = Math.sqrt(1 - y * y);
      const theta = goldenAngle * i;

      const x = Math.cos(theta) * radiusAtY;
      const z = Math.sin(theta) * radiusAtY;

      positions.push(new Vector3(x * radius, y * radius, z * radius));
    }

    return positions;
  }

  /**
   * Distribute particles in a fibonacci spiral pattern
   * @param count - Number of particles
   * @param bounds - Boundary constraints
   * @returns Array of positions in fibonacci formation
   */
  #distributeFibonacci(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];
    const radius = bounds.x;
    const goldenRatio = (1 + Math.sqrt(5)) / 2;
    const angleIncrement = 2 * Math.PI / (goldenRatio * goldenRatio);

    for (let i = 0; i < count; i++) {
      const angle = i * angleIncrement;
      const r = Math.sqrt(i / count) * radius;
      
      positions.push(new Vector3(
        Math.cos(angle) * r,
        0,
        Math.sin(angle) * r
      ));
    }

    return positions;
  }

  /**
   * Distribute particles randomly within bounds
   * @param count - Number of particles
   * @param bounds - Boundary constraints
   * @returns Array of random positions
   */
  #distributeRandom(count: number, bounds: Vector3): Vector3[] {
    const positions: Vector3[] = [];

    for (let i = 0; i < count; i++) {
      positions.push(new Vector3(
        (Math.random() - 0.5) * bounds.x,
        (Math.random() - 0.5) * bounds.y,
        (Math.random() - 0.5) * bounds.z
      ));
    }

    return positions;
  }

  /**
   * Update performance metrics
   * @private
   */
  #updateMetrics(): void {
    const frameTime = performance.now() - this.#frameStartTime;
    this.#frameHistory.push(frameTime);

    if (this.#frameHistory.length > 60) {
      this.#frameHistory.shift();
    }

    this.#metrics.currentFPS = 1000 / frameTime;
    this.#metrics.averageFrameTime = this.#frameHistory.reduce((a, b) => a + b, 0) / this.#frameHistory.length;
  }

  /**
   * Get current physics performance metrics
   * @returns Physics performance data
   */
  public getMetrics(): PhysicsMetrics {
    return { ...this.#metrics };
  }

  /**
   * Reset physics simulation state
   */
  public reset(): void {
    this.#logger.info("Resetting physics simulation state");

    this.#state = {
      isRunning: false,
      simulationTime: 0,
      lastDeltaTime: 0,
      algorithm: "euler",
      collisionMethod: "basic",
      activeParticles: 0
    };

    this.#metrics = {
      currentFPS: 0,
      averageFrameTime: 0,
      transformCalculations: 0,
      geometryOperations: 0,
      memoryUsage: 0
    };

    this.#frameHistory = [];
    this.#logger.info("Physics simulation reset completed");
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info("Disposing PhysicsService resources");

    this.reset();
    PhysicsService.#instance = null;

    this.#logger.info("PhysicsService disposal completed");
  }
}

// Singleton export
export const physicsService = PhysicsService.getInstance();

// Utility functions for physics calculations
export function calculatePhysicsStep(deltaTime: number): number {
  return Math.min(deltaTime, 1/30); // Cap at 30fps minimum
}

export function clampVelocity(velocity: Vector3, maxSpeed: number): Vector3 {
  if (velocity.length() > maxSpeed) {
    return velocity.normalize().multiplyScalar(maxSpeed);
  }
  return velocity;
}
