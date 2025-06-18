/**
 * @fileoverview RNG Service Interface Definition
 * @description Defines the contract for random number generation services
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * Configuration options for RNG service initialization
 */
export interface RNGConfig {
  /** Default seed for deterministic generation */
  defaultSeed?: number;
  /** Enable Bitcoin block-based seeding */
  useBitcoinSeeding?: boolean;
  /** Cache size for generated sequences */
  cacheSize?: number;
  /** Enable high-precision mode */
  highPrecision?: boolean;
}

/**
 * RNG state for serialization and persistence
 */
export interface RNGState {
  /** Current seed value */
  seed: number;
  /** Internal algorithm state */
  state: number;
  /** Generation counter */
  counter: number;
  /** Last Bitcoin block used for seeding */
  lastBlock?: number;
}

/**
 * RNG generation options
 */
export interface RNGOptions {
  /** Minimum value (inclusive) */
  min?: number;
  /** Maximum value (exclusive) */
  max?: number;
  /** Number of values to generate */
  count?: number;
  /** Use specific seed for this generation */
  seed?: number;
}

/**
 * RNG service interface defining deterministic random number generation
 * Uses Bitcoin block data for seeding to ensure unique organism traits
 */
export interface IRNGService {
  /**
   * Initialize the RNG service with configuration
   * @param config - RNG configuration options
   */
  initialize(config?: RNGConfig): Promise<void>;

  /**
   * Set seed for deterministic generation
   * @param seed - Seed value for PRNG
   */
  setSeed(seed: number): void;

  /**
   * Seed from Bitcoin block hash
   * @param blockNumber - Bitcoin block number
   */
  seedFromBlock(blockNumber: number): Promise<void>;

  /**
   * Generate random float between 0 and 1
   * @returns Random float [0, 1)
   */
  random(): number;

  /**
   * Generate random integer within range
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (exclusive)
   * @returns Random integer
   */
  randomInt(min: number, max: number): number;

  /**
   * Generate random float within range
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (exclusive)
   * @returns Random float
   */
  randomFloat(min: number, max: number): number;

  /**
   * Generate array of random values
   * @param options - Generation options
   * @returns Array of random numbers
   */
  randomArray(options: RNGOptions): number[];

  /**
   * Get current RNG state for serialization
   * @returns Current RNG state
   */
  getState(): RNGState;

  /**
   * Restore RNG state from serialized data
   * @param state - RNG state to restore
   */
  setState(state: RNGState): void;

  /**
   * Reset RNG to initial state
   */
  reset(): void;

  /**
   * Dispose of resources and cleanup
   */
  dispose(): void;
}
