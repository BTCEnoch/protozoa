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

// MOVED: All trait interfaces moved to trait.types.ts to centralize type definitions and prevent circular imports

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