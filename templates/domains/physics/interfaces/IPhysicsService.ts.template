/**
 * @fileoverview Physics Service Interface Definition (Template)
 * @module @/domains/physics/interfaces/IPhysicsService
 * @version 1.0.0
 */

import { Vector3 } from "three"

/** Configuration options for PhysicsService */
export interface PhysicsConfig {
  /** Target frame rate for physics calculations */
  targetFPS?: number
  /** Gravity strength (Y axis, negative is downward) */
  gravity?: number
  /** Linear damping factor applied each update */
  damping?: number
}

/** Core kinematic state for a single particle */
export interface ParticlePhysics {
  position: Vector3
  velocity: Vector3
  acceleration: Vector3
  mass: number
  radius: number
  useGravity: boolean
}

/** Transform helper returned by createTransform */
export interface Transform {
  position: Vector3
  rotation: { x: number; y: number; z: number; w: number }
  scale: Vector3
  /** Flattened 4×4 matrix elements */
  matrix: Float32Array
}

/** Simplified performance metrics reported by PhysicsService */
export interface PhysicsMetrics {
  currentFPS: number
  averageFrameTime: number
  transformCalculations: number
  geometryOperations: number
  memoryUsage: number
}

/** Primary PhysicsService contract */
export interface IPhysicsService {
  initialize(config?: PhysicsConfig): Promise<void>
  applyGravity(particle: ParticlePhysics, deltaTime: number): void
  distributeParticles(count: number, pattern: string, bounds: Vector3): Vector3[]
  createTransform(position: Vector3, rotation: any, scale: Vector3): Transform
  interpolateTransform(from: Transform, to: Transform, alpha: number): Transform
  getMetrics(): PhysicsMetrics
  reset(): void
  dispose(): void
}