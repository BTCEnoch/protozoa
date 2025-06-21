/**
 * @fileoverview Particle Types Definition (Template)
 * @module @/domains/particle/types/particle.types
 * @version 1.0.0
 */

import type { IVector3 } from "@/shared/types/vectorTypes"

/**
 * Particle roles within the organism ecosystem
 */
export enum ParticleRole {
  /** Core structural particles - central to organism */
  CORE = "core",
  
  /** Energy particles - handle metabolism and power */
  ENERGY = "energy",
  
  /** Barrier particles - form protective boundaries */
  BARRIER = "barrier",
  
  /** Sensor particles - detect environmental changes */
  SENSOR = "sensor",
  
  /** Transport particles - move resources around */
  TRANSPORT = "transport",
  
  /** Reproductive particles - handle organism replication */
  REPRODUCTIVE = "reproductive",
  
  /** Defensive particles - protect against threats */
  DEFENSIVE = "defensive",
  
  /** Adaptive particles - respond to evolution pressure */
  ADAPTIVE = "adaptive"
}

/**
 * Emergent behaviors that particles can exhibit
 */
export enum EmergentBehavior {
  /** No special behavior */
  NONE = "none",
  
  /** Forms flocking patterns with nearby particles */
  FLOCKING = "flocking",
  
  /** Creates spiral movement patterns */
  SPIRALING = "spiraling",
  
  /** Exhibits pulsating size/energy changes */
  PULSATING = "pulsating",
  
  /** Forms network connections with other particles */
  NETWORKING = "networking",
  
  /** Moves in oscillating patterns */
  OSCILLATING = "oscillating",
  
  /** Exhibits magnetic-like attraction/repulsion */
  MAGNETIC = "magnetic",
  
  /** Shows collective intelligence behavior */
  COLLECTIVE = "collective",
  
  /** Adapts behavior based on environment */
  ADAPTIVE = "adaptive"
}

/**
 * Particle lifecycle states
 */
export enum ParticleState {
  /** Particle is being initialized */
  INITIALIZING = "initializing",
  
  /** Particle is active and functioning */
  ACTIVE = "active",
  
  /** Particle is dormant/sleeping */
  DORMANT = "dormant",
  
  /** Particle is reproducing */
  REPRODUCING = "reproducing",
  
  /** Particle is mutating */
  MUTATING = "mutating",
  
  /** Particle is dying/degrading */
  DYING = "dying",
  
  /** Particle is dead and ready for cleanup */
  DEAD = "dead"
}

/**
 * Visual appearance properties for particles
 */
export interface ParticleVisuals {
  /** Current color in hex format */
  color: string
  
  /** Particle size/radius */
  size: number
  
  /** Opacity/transparency (0-1) */
  opacity: number
  
  /** Visual effects applied */
  effects: {
    /** Glow intensity */
    glow?: number
    
    /** Pulsing animation */
    pulse?: boolean
    
    /** Trail effect */
    trail?: boolean
    
    /** Particle system for visual effects */
    particles?: boolean
  }
  
  /** Material properties */
  material: {
    /** Metallic appearance */
    metallic: number
    
    /** Surface roughness */
    roughness: number
    
    /** Emission strength */
    emission: number
  }
}

/**
 * Physics properties for particle simulation
 */
export interface ParticlePhysics {
  /** Current position in 3D space */
  position: IVector3
  
  /** Current velocity vector */
  velocity: IVector3
  
  /** Current acceleration vector */
  acceleration: IVector3
  
  /** Particle mass */
  mass: number
  
  /** Drag coefficient */
  drag: number
  
  /** Collision radius */
  collisionRadius: number
  
  /** Whether particle can collide with others */
  collidable: boolean
  
  /** Force accumulators */
  forces: {
    /** Gravitational forces */
    gravity: IVector3
    
    /** Electromagnetic forces */
    electromagnetic: IVector3
    
    /** Inter-particle forces */
    interParticle: IVector3
    
    /** External forces */
    external: IVector3
  }
}

/**
 * Particle energy and metabolism
 */
export interface ParticleEnergy {
  /** Current energy level (0-1) */
  current: number
  
  /** Maximum energy capacity */
  maximum: number
  
  /** Energy consumption rate per tick */
  consumptionRate: number
  
  /** Energy generation rate per tick */
  generationRate: number
  
  /** Energy efficiency factor */
  efficiency: number
  
  /** Energy storage capacity */
  storageCapacity: number
  
  /** Energy transfer capabilities */
  transfer: {
    /** Can give energy to others */
    canGive: boolean
    
    /** Can receive energy from others */
    canReceive: boolean
    
    /** Transfer rate per tick */
    rate: number
    
    /** Transfer efficiency */
    efficiency: number
  }
}

/**
 * Main particle interface
 */
export interface IParticle {
  /** Unique particle identifier */
  id: string
  
  /** Particle role in ecosystem */
  role: ParticleRole
  
  /** Current lifecycle state */
  state: ParticleState
  
  /** Emergent behavior exhibited */
  emergentBehavior: EmergentBehavior
  
  /** Age of particle in simulation ticks */
  age: number
  
  /** Maximum lifespan in ticks */
  maxLifespan: number
  
  /** Visual appearance properties */
  visuals: ParticleVisuals
  
  /** Physics simulation properties */
  physics: ParticlePhysics
  
  /** Energy and metabolism */
  energy: ParticleEnergy
  
  /** Genetic/trait information */
  genetics: {
    /** DNA sequence for traits */
    dna: string
    
    /** Mutation probability */
    mutationRate: number
    
    /** Generation number */
    generation: number
    
    /** Parent particle IDs */
    parents: string[]
  }
  
  /** Network connections to other particles */
  connections: {
    /** Connected particle IDs */
    connected: string[]
    
    /** Connection strengths */
    strengths: number[]
    
    /** Connection types */
    types: string[]
  }
  
  /** Performance metrics */
  metrics: {
    /** Distance traveled */
    distanceTraveled: number
    
    /** Energy consumed total */
    energyConsumed: number
    
    /** Energy produced total */
    energyProduced: number
    
    /** Collisions experienced */
    collisions: number
    
    /** Reproductions performed */
    reproductions: number
  }
  
  /** Custom data storage */
  userData: Record<string, any>
  
  /** Timestamp of last update */
  lastUpdated: number
}

/**
 * Particle factory configuration
 */
export interface ParticleFactoryConfig {
  /** Default role to assign */
  defaultRole: ParticleRole
  
  /** Default emergent behavior */
  defaultBehavior: EmergentBehavior
  
  /** Position bounds */
  bounds: {
    min: IVector3
    max: IVector3
  }
  
  /** Energy configuration */
  energy: {
    /** Default maximum energy */
    defaultMaximum: number
    
    /** Default consumption rate */
    defaultConsumption: number
    
    /** Default generation rate */
    defaultGeneration: number
  }
  
  /** Physics configuration */
  physics: {
    /** Default mass */
    defaultMass: number
    
    /** Default drag */
    defaultDrag: number
    
    /** Default collision radius */
    defaultCollisionRadius: number
  }
  
  /** Visual configuration */
  visuals: {
    /** Default size */
    defaultSize: number
    
    /** Default opacity */
    defaultOpacity: number
    
    /** Color palette */
    colorPalette: string[]
  }
}

/**
 * Particle update result
 */
export interface ParticleUpdateResult {
  /** Whether update was successful */
  success: boolean
  
  /** Updated particle state */
  particle: IParticle
  
  /** Events generated during update */
  events: string[]
  
  /** Performance metrics */
  performance: {
    /** Update time in milliseconds */
    updateTime: number
    
    /** Memory usage change */
    memoryDelta: number
  }
}

/**
 * Type exports for convenience
 */
export type {
  IParticle,
  ParticleVisuals,
  ParticlePhysics,
  ParticleEnergy,
  ParticleFactoryConfig,
  ParticleUpdateResult
} 