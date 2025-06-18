/**
 * @fileoverview Trait Service Interface Definition
 * @description Defines the contract for organism trait management services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Configuration options for Trait service initialization
 */
export interface TraitConfig {
  /** Enable Bitcoin block-based trait seeding */
  useBitcoinSeeding?: boolean;
  /** Base mutation rate (0-1) */
  baseMutationRate?: number;
  /** Enable genetic inheritance */
  enableInheritance?: boolean;
  /** Maximum trait variations */
  maxVariations?: number;
  /** Trait generation cache size */
  cacheSize?: number;
}

/**
 * Organism trait collection
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
 * Trait service interface defining organism trait management
 * Provides Bitcoin block-seeded trait generation and genetic inheritance
 */
export interface ITraitService {
  /**
   * Initialize the Trait service with configuration
   * @param config - Trait service configuration
   */
  initialize(config?: TraitConfig): Promise<void>;
  
  /**
   * Generate traits for a new organism from Bitcoin block data
   * @param blockNumber - Bitcoin block number for seeding
   * @param parentIds - Optional parent organism IDs for inheritance
   * @returns Promise resolving to generated traits
   */
  generateTraits(blockNumber: number, parentIds?: string[]): Promise<OrganismTraits>;
  
  /**
   * Mutate existing organism traits
   * @param traits - Current organism traits
   * @param mutationRate - Optional custom mutation rate
   * @returns Mutated traits
   */
  mutateTraits(traits: OrganismTraits, mutationRate?: number): OrganismTraits;
  
  /**
   * Get trait generation statistics
   * @returns Trait service metrics
   */
  getMetrics(): TraitMetrics;
  
  /**
   * Dispose of resources and cleanup
   */
  dispose(): void;
}
