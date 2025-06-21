/**
 * @fileoverview Particle System Type Definitions
 * @description Comprehensive type definitions for particle systems and rendering
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3, BufferGeometry, Material, Color } from "three";

/**
 * Particle type enumeration
 */
export type ParticleType = "basic" | "enhanced" | "mutated" | "evolved" | "composite";

/**
 * Rendering mode for particles
 */
export type RenderingMode = "points" | "sprites" | "instanced" | "geometry";

/**
 * Blending mode for particle rendering
 */
export type BlendingMode = "normal" | "additive" | "subtractive" | "multiply" | "screen";

/**
 * Particle system configuration
 */
export interface ParticleSystemConfig {
  /** Unique system identifier */
  id: string;
  /** Human-readable system name */
  name: string;
  /** Maximum particles in this system */
  maxParticles: number;
  /** System world position */
  position: Vector3;
  /** System bounding box */
  bounds: Vector3;
  /** Particle type for this system */
  particleType: ParticleType;
  /** Rendering mode */
  renderingMode: RenderingMode;
  /** Blending mode */
  blendingMode: BlendingMode;
  /** Enable physics simulation */
  enablePhysics: boolean;
  /** Enable collision detection */
  enableCollisions: boolean;
  /** System lifetime (-1 for infinite) */
  lifetime: number;
}

/**
 * Data required to create new particles
 */
export interface ParticleCreationData {
  /** Particle spawn position */
  position: Vector3;
  /** Initial velocity */
  velocity?: Vector3;
  /** Particle scale */
  scale?: Vector3;
  /** Particle color */
  color?: Color;
  /** Particle lifetime */
  lifetime?: number;
  /** Particle type */
  type?: ParticleType;
  /** Custom user data */
  userData?: Record<string, any>;
}

/**
 * Data for updating existing particles
 */
export interface ParticleUpdateData {
  /** Particle ID to update */
  id: string;
  /** New position */
  position?: Vector3;
  /** New velocity */
  velocity?: Vector3;
  /** New scale */
  scale?: Vector3;
  /** New color */
  color?: Color;
  /** New opacity */
  opacity?: number;
  /** Custom update data */
  userData?: Record<string, any>;
}

/**
 * Particle performance metrics
 */
export interface ParticleMetrics {
  /** Total particles across all systems */
  totalParticles: number;
  /** Number of active systems */
  activeSystems: number;
  /** Particles updated this frame */
  particlesUpdated: number;
  /** Particles rendered this frame */
  particlesRendered: number;
  /** Average update time (ms) */
  averageUpdateTime: number;
  /** Average render time (ms) */
  averageRenderTime: number;
  /** System memory usage (bytes) */
  memoryUsage: number;
  /** GPU memory usage (bytes) */
  gpuMemoryUsage: number;
  /** Object pool utilization (0-1) */
  poolUtilization: number;
}
