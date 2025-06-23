/**
 * @fileoverview Particle Service Interface Definition
 * @description Defines the contract for particle system management services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Scene, Vector3 } from 'three'
import {
  ParticleCreationData,
  ParticleMetrics,
  ParticleSystemConfig,
  ParticleType,
} from '../types/particle.types'

/**
 * Configuration options for Particle service initialization
 */
export interface ParticleConfig {
  /** Maximum number of particles in the system */
  maxParticles?: number
  /** Enable GPU instancing for performance */
  useInstancing?: boolean
  /** Enable object pooling */
  useObjectPooling?: boolean
  /** Default particle material type */
  defaultMaterial?: string
  /** Enable LOD (Level of Detail) optimization */
  enableLOD?: boolean
  /** Culling distance for particles */
  cullingDistance?: number
}

/**
 * Particle instance data
 */
export interface ParticleInstance {
  /** Unique particle identifier */
  id: string
  /** Particle position */
  position: { x: number; y: number; z: number }
  /** Particle velocity */
  velocity: { x: number; y: number; z: number }
  /** Particle scale */
  scale: Vector3
  /** Particle rotation */
  rotation: number
  /** Particle color (RGB) */
  color: string
  /** Particle opacity */
  opacity: number
  /** Particle age in seconds */
  age: number
  /** Particle lifetime in seconds */
  lifetime: number
  /** Initial lifetime for age calculations */
  initialLifetime?: number
  /** Initial size for size over lifetime calculations */
  initialSize?: number
  /** Size change over lifetime (0-1) */
  sizeOverLifetime?: number
  /** Whether particle is active */
  active: boolean
  /** Particle type identifier */
  type: ParticleType
  /** Custom particle data */
  userData: Record<string, any>
  /** Particle size */
  size: number
}

/**
 * Particle system definition
 */
export interface ParticleSystem {
  /** System identifier */
  id: string
  /** System name */
  name: string
  /** Maximum particles in this system */
  maxParticles: number
  /** Active particles count */
  activeParticles: number
  /** Particles array */
  particles: ParticleInstance[]
  /** System position */
  position: Vector3
  /** System bounds */
  bounds: {
    min: Vector3
    max: Vector3
  }
  /** Whether system is active */
  active: boolean
  /** System creation timestamp */
  createdAt: number
}

/**
 * Particle service interface defining particle system management
 * Provides high-performance particle rendering with THREE.js integration
 */
export interface IParticleService {
  /**
   * Initialize the Particle service with configuration
   * @param config - Particle service configuration
   */
  initialize(config?: ParticleConfig): Promise<void>

  /**
   * Create a new particle system
   * @param systemConfig - System configuration
   * @returns Created particle system
   */
  createSystem(systemConfig: ParticleSystemConfig): ParticleSystem

  /**
   * Add particles to a system
   * @param systemId - System identifier
   * @param particleData - Particle creation data
   * @returns Array of created particle IDs
   */
  addParticles(systemId: string, particleData: ParticleCreationData[]): string[]

  /**
   * Remove particles from a system
   * @param systemId - System identifier
   * @param particleIds - Particle IDs to remove
   */
  removeParticles(systemId: string, particleIds: string[]): void

  /**
   * Update all particle systems
   * @param deltaTime - Time delta in seconds
   */
  update(deltaTime: number): void

  /**
   * Render particles to THREE.js scene
   * @param scene - THREE.js scene
   */
  render(scene: Scene): void

  /**
   * Get particle system by ID
   * @param systemId - System identifier
   * @returns Particle system or undefined
   */
  getSystem(systemId: string): ParticleSystem | undefined

  /**
   * Get all particle systems
   * @returns Array of all particle systems
   */
  getAllSystems(): ParticleSystem[]

  /**
   * Get particle performance metrics
   * @returns Particle service metrics
   */
  getMetrics(): ParticleMetrics

  /**
   * Dispose of resources and cleanup
   */
  dispose(): void
}
