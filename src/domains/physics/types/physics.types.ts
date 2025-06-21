/**
 * @fileoverview Physics Domain Type Definitions (Template)
 * @module @/domains/physics/types
 * @version 1.0.0
 */

import { Vector3 } from "three"

// Supported physics integration algorithms
export type PhysicsAlgorithm = "euler" | "verlet" | "runge-kutta"

// Supported collision detection strategies
export type CollisionMethod = "basic" | "spatial-hash" | "octree" | "bvh"

// Distribution patterns offered by PhysicsService.distributeParticles
export type DistributionPattern =
  | "grid"
  | "circle"
  | "sphere"
  | "fibonacci"
  | "random"

// Interpolation styles used in interpolateTransform
export type InterpolationType =
  | "linear"
  | "smooth"
  | "ease-in"
  | "ease-out"
  | "ease-in-out"

// Generic geometry bounds helper used by distribution utilities
export interface GeometryBounds {
  min: Vector3
  max: Vector3
  center: Vector3
  /** Optional radius for spherical bounds */
  radius?: number
}

// Internal PhysicsService state snapshot
export interface PhysicsState {
  isRunning: boolean
  simulationTime: number
  lastDeltaTime: number
  algorithm: PhysicsAlgorithm
  collisionMethod: CollisionMethod
  activeParticles: number
}