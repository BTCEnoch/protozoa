/**
 * @fileoverview Trait Types Definition
 * @description Type definitions for organism trait management domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Trait categories
 */
export type TraitCategory = 'visual' | 'behavioral' | 'physical' | 'evolutionary';

/**
 * Trait data types
 */
export type TraitType = 'number' | 'string' | 'boolean' | 'color' | 'enum';

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
export type GenerationType = 'genesis' | 'inheritance' | 'mutation' | 'crossover';

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
