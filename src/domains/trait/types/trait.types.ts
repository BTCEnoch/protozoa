/**
 * @fileoverview Trait Types Definition
 * @description Type definitions for organism trait management domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Trait categories
 */
export type TraitCategory = "visual" | "behavioral" | "physical" | "evolutionary";

/**
 * Trait data types
 */
export type TraitType = "number" | "string" | "boolean" | "color" | "enum";

/**
 * Trait value union type for all possible trait values
 */
export type TraitValue = number | string | boolean;

/**
 * Mutation record for tracking trait changes
 */
export interface MutationRecord {
  /** Mutation timestamp */
  timestamp: number;
  /** Block number that triggered mutation */
  blockNumber: number;
  /** Trait category that mutated */
  category: TraitCategory;
  /** Specific trait that changed */
  traitName: string;
  /** Previous value */
  previousValue: any;
  /** New value */
  newValue: any;
  /** Mutation strength (0.0-1.0) */
  mutationStrength: number;
}

/**
 * Trait validation result
 */
export interface TraitValidation {
  /** Whether traits are valid */
  isValid: boolean;
  /** Validation errors if any */
  errors: string[];
  /** Warnings for unusual values */
  warnings: string[];
}

/**
 * Trait generation parameters
 */
export interface TraitGenerationParams {
  /** Bitcoin block number for seeding */
  blockNumber: number;
  /** Parent organism traits for inheritance */
  parentTraits?: OrganismTraits[];
  /** Custom mutation rate override */
  mutationRate?: number;
  /** Generation type */
  generationType: GenerationType;
}

/**
 * Generation type
 */
export type GenerationType = "genesis" | "inheritance" | "mutation" | "crossover";

/**
 * Organism trait collection (moved from ITraitService.ts to centralize type definitions)
 */
export interface OrganismTraits {
  /** Unique organism identifier */
  organismId: string;
  /** Parent organism IDs for inheritance */
  parentIds?: string[];
  /** Block number used for trait generation */
  blockNumber: number;
  /** Visual appearance traits */
  visual: VisualTraits;
  /** Behavioral pattern traits */
  behavioral: BehavioralTraits;
  /** Physical property traits */
  physical: PhysicalTraits;
  /** Evolutionary traits */
  evolutionary: EvolutionaryTraits;
  /** Generation timestamp */
  generatedAt: number;
  /** Mutation history */
  mutationHistory: MutationRecord[];
}

/**
 * Visual appearance traits
 */
export interface VisualTraits {
  /** Primary color (RGB hex) */
  primaryColor: string;
  /** Secondary color (RGB hex) */
  secondaryColor: string;
  /** Size multiplier (0.5-2.0) */
  size: number;
  /** Opacity (0.0-1.0) */
  opacity: number;
  /** Shape identifier */
  shape: string;
  /** Particle count multiplier */
  particleDensity: number;
  /** Glow intensity (0.0-1.0) */
  glowIntensity: number;
}

/**
 * Behavioral pattern traits
 */
export interface BehavioralTraits {
  /** Movement speed multiplier */
  speed: number;
  /** Aggression level (0.0-1.0) */
  aggression: number;
  /** Social tendency (0.0-1.0) */
  sociability: number;
  /** Exploration drive (0.0-1.0) */
  curiosity: number;
  /** Energy efficiency (0.0-1.0) */
  efficiency: number;
  /** Adaptation rate (0.0-1.0) */
  adaptability: number;
}

/**
 * Physical property traits
 */
export interface PhysicalTraits {
  /** Mass multiplier */
  mass: number;
  /** Collision radius multiplier */
  collisionRadius: number;
  /** Energy capacity multiplier */
  energyCapacity: number;
  /** Durability multiplier */
  durability: number;
  /** Regeneration rate */
  regeneration: number;
}

/**
 * Evolutionary traits
 */
export interface EvolutionaryTraits {
  /** Current generation number */
  generation: number;
  /** Fitness score */
  fitness: number;
  /** Mutation resistance (0.0-1.0) */
  stability: number;
  /** Reproductive success rate */
  reproductivity: number;
  /** Lifespan multiplier */
  longevity: number;
}

/**
 * Trait service performance metrics
 */
export interface TraitMetrics {
  /** Total traits generated */
  totalGenerated: number;
  /** Total mutations performed */
  totalMutations: number;
  /** Average generation time in milliseconds */
  averageGenerationTime: number;
  /** Cache hit rate percentage */
  cacheHitRate: number;
  /** Unique block numbers used */
  uniqueBlocks: number;
  /** Generation distribution by type */
  generationTypes: Record<GenerationType, number>;
}

/**
 * Color utility type for RGB values
 */
export interface RGBColor {
  /** Red component (0-255) */
  r: number;
  /** Green component (0-255) */
  g: number;
  /** Blue component (0-255) */
  b: number;
}

/**
 * Trait range definition
 */
export interface TraitRange {
  /** Minimum value */
  min: number;
  /** Maximum value */
  max: number;
  /** Default value */
  default: number;
}

/**
 * Genetic inheritance weights
 */
export interface InheritanceWeights {
  /** Parent 1 influence (0.0-1.0) */
  parent1Weight: number;
  /** Parent 2 influence (0.0-1.0) */
  parent2Weight: number;
  /** Random mutation influence (0.0-1.0) */
  mutationWeight: number;
  /** Block data influence (0.0-1.0) */
  blockWeight: number;
} 