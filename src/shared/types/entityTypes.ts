/**
 * Core Entity Types
 * Base interfaces and types for all domain entities
 */

import { IVector3, IColor, ITransform } from "./vectorTypes";

/**
 * Base entity interface that all domain entities should implement
 */
export interface IEntity {
  /** Unique identifier for the entity */
  id: string;
  /** Creation timestamp */
  createdAt: Date;
  /** Last update timestamp */
  updatedAt: Date;
  /** Entity type identifier */
  type: string;
}

/**
 * Particle entity representing a digital organism
 */
export interface IParticle extends IEntity {
  /** 3D position in world space */
  position: IVector3;
  /** Velocity vector for movement */
  velocity: IVector3;
  /** Visual color properties */
  color: IColor;
  /** Size/radius of the particle */
  size: number;
  /** Organism traits */
  traits: IOrganismTraits;
  /** Current formation group membership */
  groupId?: string;
  /** Active status */
  active: boolean;
}

/**
 * Formation pattern definition
 */
export interface IFormationPattern extends IEntity {
  /** Pattern name for reference */
  name: string;
  /** Array of relative positions for particles */
  positions: IVector3[];
  /** Optional metadata for pattern behavior */
  metadata?: Record<string, any>;
}

/**
 * Organism traits collection
 */
export interface IOrganismTraits {
  /** Visual appearance traits */
  visual: IVisualTraits;
  /** Behavioral characteristics */
  behavioral: IBehavioralTraits;
  /** Evolutionary properties */
  evolutionary: IEvolutionaryTraits;
  /** Mutation capabilities */
  mutation: IMutationTraits;
}

/**
 * Visual traits affecting appearance
 */
export interface IVisualTraits {
  color: string;
  shape: "sphere" | "cube" | "tetrahedron" | "octahedron";
  size: number;
  luminosity: number;
  pattern?: string;
}

/**
 * Behavioral traits affecting movement and interaction
 */
export interface IBehavioralTraits {
  aggressiveness: number; // 1-10 scale
  sociability: number; // 1-10 scale
  energy: number; // 1-10 scale
  adaptability: number; // 1-10 scale
  curiosity: number; // 1-10 scale
}

/**
 * Evolutionary traits for organism development
 */
export interface IEvolutionaryTraits {
  generation: number;
  parentIds: string[];
  mutationRate: number;
  fitnessScore: number;
  lineageHash: string;
}

/**
 * Mutation traits controlling evolutionary changes
 */
export interface IMutationTraits {
  visualMutationChance: number;
  behavioralMutationChance: number;
  sizeMutationRange: IRange;
  colorMutationIntensity: number;
}

/**
 * Group entity for particle collections
 */
export interface IParticleGroup extends IEntity {
  /** Name of the group */
  name: string;
  /** Member particle IDs */
  memberIds: string[];
  /** Group formation pattern */
  formationId?: string;
  /** Group behavior settings */
  behavior: IGroupBehavior;
}

/**
 * Group behavior configuration
 */
export interface IGroupBehavior {
  cohesion: number;
  separation: number;
  alignment: number;
  maxSpeed: number;
  maxForce: number;
}
