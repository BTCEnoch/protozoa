/**
 * Formation Types Definition
 * @fileoverview Comprehensive type definitions for the formation domain
 * @module @/domains/formation/types/formation.types
 * 
 * Defines interfaces and types for particle formation systems including:
 * - Formation patterns and geometries
 * - Formation configuration and parameters
 * - Formation state management
 * - Formation interpolation and blending
 */

import type { IVector3 } from '@/shared/types/vectorTypes'

/**
 * Core formation pattern interface
 * Defines the structure of a formation pattern with metadata
 */
export interface IFormationPattern {
  /** Unique identifier for the pattern */
  id: string
  /** Human-readable name */
  name: string
  /** Pattern category for organization */
  type: 'geometric' | 'organic' | 'mathematical' | 'dynamic'
  /** Complexity level (0-10) for performance optimization */
  complexity: number
  /** Pattern-specific parameters */
  parameters: Record<string, any>
  /** Pattern description for documentation */
  description?: string
  /** Tags for search and filtering */
  tags?: string[]
}

/**
 * 3D geometric data for formations
 * Contains vertices, faces, and optional rendering data
 */
export interface IFormationGeometry {
  /** Array of vertex positions [x, y, z] */
  vertices: number[][]
  /** Array of face indices (triangles) */
  faces: number[][]
  /** Optional vertex normals for lighting */
  normals?: number[][]
  /** Optional UV coordinates for texturing */
  uvs?: number[][]
  /** Bounding box for optimization */
  bounds?: {
    min: IVector3
    max: IVector3
  }
}

/**
 * Configuration for formation creation
 * Used by FormationService to create formations
 */
export interface FormationConfig {
  /** Pattern identifier to use */
  pattern: string
  /** Scale factor (1.0 = default size) */
  scale: number
  /** Rotation in radians */
  rotation: IVector3
  /** Position offset */
  position: IVector3
  /** Number of particles in formation */
  particleCount: number
  /** Formation-specific parameters */
  parameters?: Record<string, any>
  /** Animation configuration */
  animation?: {
    enabled: boolean
    duration: number
    type: 'linear' | 'ease' | 'bounce'
  }
}

/**
 * Runtime formation state
 * Tracks the current state of an active formation
 */
export interface IFormationState {
  /** Formation unique identifier */
  id: string
  /** Configuration used to create this formation */
  config: FormationConfig
  /** Current particle positions */
  positions: IVector3[]
  /** Formation lifecycle state */
  state: 'creating' | 'active' | 'transitioning' | 'destroyed'
  /** Creation timestamp */
  createdAt: number
  /** Last update timestamp */
  updatedAt: number
  /** Performance metrics */
  metrics?: {
    renderTime: number
    particleCount: number
    memoryUsage: number
  }
}

/**
 * Formation blending parameters
 * Used by FormationBlendingService for interpolation
 */
export interface IFormationBlend {
  /** Source formation state */
  from: IFormationState
  /** Target formation state */
  to: IFormationState
  /** Blend progress (0.0 to 1.0) */
  progress: number
  /** Blending algorithm */
  algorithm: 'linear' | 'spherical' | 'bezier' | 'custom'
  /** Easing function */
  easing?: 'ease-in' | 'ease-out' | 'ease-in-out'
  /** Custom blending function */
  customBlend?: (from: IVector3, to: IVector3, progress: number) => IVector3
}

/**
 * Formation enhancement options
 * Used by FormationEnhancer for optimization
 */
export interface IFormationEnhancement {
  /** Level of detail optimization */
  lod: {
    enabled: boolean
    levels: number
    distanceThresholds: number[]
  }
  /** Particle culling */
  culling: {
    enabled: boolean
    frustum: boolean
    occlusion: boolean
  }
  /** Instancing for performance */
  instancing: {
    enabled: boolean
    maxInstances: number
  }
  /** Quality vs performance trade-offs */
  quality: 'low' | 'medium' | 'high' | 'ultra'
}

/**
 * Formation generation result
 * Returned by formation generation methods
 */
export interface IFormationResult {
  /** Success flag */
  success: boolean
  /** Generated formation state */
  formation?: IFormationState
  /** Error message if failed */
  error?: string
  /** Generation metrics */
  metrics: {
    generationTime: number
    particleCount: number
    complexity: number
  }
  /** Warnings during generation */
  warnings?: string[]
}

/**
 * Predefined formation types
 * Common formation patterns for quick access
 */
export type FormationType = 
  | 'sphere' 
  | 'cube' 
  | 'pyramid' 
  | 'torus' 
  | 'spiral' 
  | 'grid' 
  | 'cluster' 
  | 'wave' 
  | 'helix' 
  | 'mandala' 
  | 'fractal' 
  | 'organic'

/**
 * Formation parameter constraints
 * Defines valid ranges for formation parameters
 */
export interface IFormationConstraints {
  /** Minimum and maximum particle counts */
  particleCount: { min: number; max: number }
  /** Scale factor limits */
  scale: { min: number; max: number }
  /** Complexity limits for performance */
  complexity: { min: number; max: number }
  /** Memory usage limits in MB */
  memoryLimit: number
}

/**
 * Formation event types for event system
 * Used with event bus for formation lifecycle events
 */
export type FormationEventType = 
  | 'formation:created'
  | 'formation:updated' 
  | 'formation:destroyed'
  | 'formation:blend:start'
  | 'formation:blend:complete'
  | 'formation:error'

/**
 * Formation event data
 * Payload for formation events
 */
export interface IFormationEvent {
  /** Event type */
  type: FormationEventType
  /** Formation ID */
  formationId: string
  /** Event timestamp */
  timestamp: number
  /** Event-specific data */
  data?: Record<string, any>
}

// Re-export for backwards compatibility and convenience
export type {
  IFormationPattern as FormationPattern,
  IFormationGeometry as FormationGeometry,
  IFormationState as FormationState,
  IFormationBlend as FormationBlend,
  IFormationEnhancement as FormationEnhancement,
  IFormationResult as FormationResult,
  IFormationConstraints as FormationConstraints,
  IFormationEvent as FormationEvent
} 
