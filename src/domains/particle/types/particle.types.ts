/**
 * @fileoverview Particle Types Definition
 * @description Type definitions for particle system management domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3, BufferGeometry, Material } from 'three';

/**
 * Particle type identifiers
 */
export type ParticleType = 'core' | 'membrane' | 'nucleus' | 'cytoplasm' | 'organelle' | 'effect';

/**
 * Particle rendering modes
 */
export type RenderingMode = 'instanced' | 'geometry' | 'points' | 'sprites';

/**
 * Particle blending modes
 */
export type BlendingMode = 'normal' | 'additive' | 'subtractive' | 'multiply';

/**
 * Particle system configuration
 */
export interface ParticleSystemConfig {
  /** System identifier */
  id: string;
  /** System name */
  name: string;
  /** Maximum number of particles */
  maxParticles: number;
  /** System position */
  position: Vector3;
  /** System bounds */
  bounds: Vector3;
  /** Particle rendering mode */
  renderingMode: RenderingMode;
  /** Particle blending mode */
  blendingMode: BlendingMode;
  /** Whether system auto-updates */
  autoUpdate: boolean;
}

/**
 * Particle creation data
 */
export interface ParticleCreationData {
  /** Particle type */
  type: ParticleType;
  /** Initial position */
  position: Vector3;
  /** Initial velocity */
  velocity?: Vector3;
  /** Initial scale */
  scale?: Vector3;
  /** Initial rotation */
  rotation?: number;
  /** Initial color */
  color?: { r: number; g: number; b: number };
  /** Initial opacity */
  opacity?: number;
  /** Particle lifetime */
  lifetime?: number;
  /** Custom user data */
  userData?: Record<string, any>;
}

/**
 * Particle update data
 */
export interface ParticleUpdateData {
  /** Position update */
  position?: Vector3;
  /** Velocity update */
  velocity?: Vector3;
  /** Scale update */
  scale?: Vector3;
  /** Rotation update */
  rotation?: number;
  /** Color update */
  color?: { r: number; g: number; b: number };
  /** Opacity update */
  opacity?: number;
}

/**
 * Particle service performance metrics
 */
export interface ParticleMetrics {
  /** Total active particles */
  totalParticles: number;
  /** Number of active systems */
  activeSystems: number;
  /** Particles updated per frame */
  particlesUpdated: number;
  /** Particles rendered per frame */
  particlesRendered: number;
  /** Average update time in milliseconds */
  averageUpdateTime: number;
  /** Average render time in milliseconds */
  averageRenderTime: number;
  /** Memory usage in MB */
  memoryUsage: number;
  /** GPU memory usage in MB */
  gpuMemoryUsage: number;
  /** Object pool utilization percentage */
  poolUtilization: number;
}

/**
 * Particle geometry definition
 */
export interface ParticleGeometry {
  /** Geometry identifier */
  id: string;
  /** THREE.js buffer geometry */
  geometry: BufferGeometry;
  /** Vertex count */
  vertexCount: number;
  /** Whether geometry is instanced */
  isInstanced: boolean;
  /** Reference count for memory management */
  refCount: number;
}

/**
 * Particle material definition
 */
export interface ParticleMaterial {
  /** Material identifier */
  id: string;
  /** THREE.js material */
  material: Material;
  /** Blending mode */
  blendingMode: BlendingMode;
  /** Whether material is transparent */
  transparent: boolean;
  /** Reference count for memory management */
  refCount: number;
}

/**
 * Particle batch for instanced rendering
 */
export interface ParticleBatch {
  /** Batch identifier */
  id: string;
  /** Particle type for this batch */
  type: ParticleType;
  /** Geometry reference */
  geometry: ParticleGeometry;
  /** Material reference */
  material: ParticleMaterial;
  /** Instance data array */
  instances: Float32Array;
  /** Maximum instances in batch */
  maxInstances: number;
  /** Current instance count */
  instanceCount: number;
  /** Whether batch needs update */
  needsUpdate: boolean;
}

/**
 * Particle LOD (Level of Detail) configuration
 */
export interface ParticleLOD {
  /** Distance thresholds for LOD levels */
  distances: number[];
  /** Particle counts for each LOD level */
  particleCounts: number[];
  /** Quality levels (0.0-1.0) */
  qualityLevels: number[];
}

/**
 * Particle culling configuration
 */
export interface ParticleCulling {
  /** Enable frustum culling */
  frustumCulling: boolean;
  /** Enable distance culling */
  distanceCulling: boolean;
  /** Maximum render distance */
  maxDistance: number;
  /** Occlusion culling threshold */
  occlusionThreshold: number;
}
