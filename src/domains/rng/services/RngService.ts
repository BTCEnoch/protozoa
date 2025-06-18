/**
 * @fileoverview RNG Service Implementation
 * @description High-performance deterministic random number generation with Bitcoin block seeding
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { IRNGService, RNGConfig } from "@/domains/rng/interfaces/IRNGService";
import { RNGState, RNGMetrics, BlockHashSeed, RNGAlgorithm, SeedSource } from "@/domains/rng/types/rng.types";
import { BlockInfo } from "@/domains/bitcoin/types/blockInfo.types";
import { createServiceLogger } from "@/shared/lib/logger";

/**
 * RNG Service implementing Mulberry32 seeded PRNG with Bitcoin block hash seeding
 * Provides deterministic random number generation for organism trait calculation
 * Follows singleton pattern for application-wide consistent random sequences
 */
export class RNGService implements IRNGService {
  /** Singleton instance */
  static #instance: RNGService | null = null;

  /** Current RNG state */
  #state: RNGState;

  /** Service configuration */
  #config: RNGConfig;

  /** Performance metrics */
  #metrics: RNGMetrics;

  /** Seed cache for Bitcoin block hashes */
  #seedCache: Map<string, BlockHashSeed>;

  /** Winston logger instance */
  #logger = createServiceLogger("RNGService");

  /** Internal random state for Mulberry32 algorithm */
  #internalState: number;

  /**
   * Private constructor enforcing singleton pattern
   * Initializes RNG with default configuration and state
   */
  private constructor() {
    this.#logger.info("Initializing RNGService singleton instance");

    // Initialize default configuration
    this.#config = {
      defaultSeed: 12345,
      useBitcoinSeeding: true,
      seedCacheSize: 100
    };

    // Initialize state with default values
    this.#state = {
      seed: this.#config.defaultSeed!,
      algorithm: "mulberry32",
      source: "manual",
      generationCount: 0,
      lastSeeded: Date.now()
    };

    // Initialize metrics
    this.#metrics = {
      totalGenerated: 0,
      averageGenerationTime: 0,
      cacheHitRate: 0.0,
      uniqueSeeds: 0
    };

    // Initialize seed cache
    this.#seedCache = new Map();

    // Set internal state for Mulberry32
    this.#internalState = this.#state.seed;

    this.#logger.info("RNGService initialized successfully", {
      defaultSeed: this.#state.seed,
      algorithm: this.#state.algorithm
    });
  }

  /**
   * Get singleton instance of RNGService
   * Creates new instance if none exists
   * @returns RNGService singleton instance
   */
  public static getInstance(): RNGService {
    if (!RNGService.#instance) {
      RNGService.#instance = new RNGService();
    }
    return RNGService.#instance;
  }

  /**
   * Initialize the RNG service with configuration
   * @param config - Optional RNG configuration
   */
  public async initialize(config?: RNGConfig): Promise<void> {
    this.#logger.info("Initializing RNGService with configuration", { config });

    if (config) {
      this.#config = { ...this.#config, ...config };
    }

    // Initialize cache if size changed
    if (this.#config.cacheSize !== this.#cache.length) {
      this.#cache = new Array(this.#config.cacheSize!);
      this.#cachePointer = 0;
    }

    this.#logger.info("RNGService initialization completed");
  }

  /**
   * Set seed for deterministic generation
   * @param seed - Seed value for PRNG
   */
  public setSeed(seed: number): void {
    this.#seed = seed;
    this.#state = seed;
    this.#counter = 0;
    this.#cachePointer = 0;
    this.#metrics.lastSeed = seed;
    this.#metrics.seedingMethod = "manual";

    this.#logger.debug("RNG seed set", { seed, state: this.#state });
  }

  /**
   * Seed from Bitcoin block hash
   * @param blockNumber - Bitcoin block number
   */
  public async seedFromBlock(blockNumber: number): Promise<void> {
    this.#logger.info("Seeding RNG from Bitcoin block", { blockNumber });

    try {
      // This would normally fetch from BitcoinService
      // For now, use block number as seed base
      const blockSeed = this.#hashBlockNumber(blockNumber);
      this.setSeed(blockSeed);

      this.#lastBitcoinBlock = blockNumber;
      this.#metrics.seedingMethod = "bitcoin-block";

      this.#logger.info("RNG seeded from Bitcoin block successfully", {
        blockNumber,
        seed: blockSeed
      });
    } catch (error) {
      this.#logger.error("Failed to seed from Bitcoin block", { blockNumber, error });
      throw error;
    }
  }

  /**
   * Generate random float between 0 and 1 using Mulberry32 algorithm
   * @returns Random float [0, 1)
   */
  public random(): number {
    const startTime = performance.now();

    // Mulberry32 PRNG algorithm
    this.#state |= 0;
    this.#state = (this.#state + 0x6D2B79F5) | 0;
    let t = Math.imul(this.#state ^ (this.#state >>> 15), 1 | this.#state);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    const result = ((t ^ (t >>> 14)) >>> 0) / 4294967296;

    // Update metrics
    this.#counter++;
    this.#metrics.totalGenerated++;

    const endTime = performance.now();
    this.#updateGenerationMetrics(endTime - startTime);

    return result;
  }

  /**
   * Generate random integer within range
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (exclusive)
   * @returns Random integer
   */
  public randomInt(min: number, max: number): number {
    if (min >= max) {
      throw new Error("Invalid range: min must be less than max");
    }

    const range = max - min;
    return Math.floor(this.random() * range) + min;
  }

  /**
   * Generate random float within range
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (exclusive)
   * @returns Random float
   */
  public randomFloat(min: number, max: number): number {
    if (min >= max) {
      throw new Error("Invalid range: min must be less than max");
    }

    const range = max - min;
    return this.random() * range + min;
  }

  /**
   * Generate array of random values
   * @param options - Generation options
   * @returns Array of random numbers
   */
  public randomArray(options: RNGOptions): number[] {
    const { min = 0, max = 1, count = 1, seed } = options;

    // Use specific seed if provided
    const originalSeed = this.#seed;
    if (seed !== undefined) {
      this.setSeed(seed);
    }

    const result: number[] = [];
    for (let i = 0; i < count; i++) {
      result.push(this.randomFloat(min, max));
    }

    // Restore original seed if temporary seed was used
    if (seed !== undefined) {
      this.setSeed(originalSeed);
    }

    return result;
  }

  /**
   * Get current RNG state for serialization
   * @returns Current RNG state
   */
  public getState(): RNGState {
    return {
      seed: this.#seed,
      state: this.#state,
      counter: this.#counter,
      lastBlock: this.#lastBitcoinBlock
    };
  }

  /**
   * Restore RNG state from serialized data
   * @param state - RNG state to restore
   */
  public setState(state: RNGState): void {
    this.#seed = state.seed;
    this.#state = state.state;
    this.#counter = state.counter;
    this.#cachePointer = 0;
    this.#lastBitcoinBlock = state.lastBlock || 0;

    this.#metrics.lastSeed = state.seed;
    this.#metrics.totalGenerated = state.counter;

    this.#logger.debug("RNG state restored", { seed: state.seed, counter: state.counter });
  }

  /**
   * Reset RNG to initial state
   */
  public reset(): void {
    this.#logger.info("Resetting RNG service to initial state");

    this.setSeed(this.#config.defaultSeed!);
    this.#metrics.totalGenerated = 0;
    this.#metrics.averageGenerationTime = 0;
    this.#cache.fill(0);
    this.#cachePointer = 0;

    this.#logger.info("RNG service reset successfully");
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info("Disposing RNG service resources");

    this.#cache = [];
    RNGService.#instance = null;

    this.#logger.info("RNG service disposed successfully");
  }

  // Private helper methods

  /**
   * Hash block number to generate seed
   * @param blockNumber - Bitcoin block number
   * @returns Numeric seed value
   */
  #hashBlockNumber(blockNumber: number): number {
    // Simple hash function for block number
    let hash = blockNumber;
    hash = ((hash >> 16) ^ hash) * 0x45d9f3b;
    hash = ((hash >> 16) ^ hash) * 0x45d9f3b;
    hash = (hash >> 16) ^ hash;
    return Math.abs(hash) || 1;
  }

  /**
   * Update generation performance metrics
   * @param time - Time taken for generation in milliseconds
   */
  #updateGenerationMetrics(time: number): void {
    const total = this.#metrics.totalGenerated;

    if (total === 1) {
      this.#metrics.averageGenerationTime = time;
      this.#metrics.generationRate = 1000 / time;
    } else {
      this.#metrics.averageGenerationTime =
        ((this.#metrics.averageGenerationTime * (total - 1)) + time) / total;
      this.#metrics.generationRate = 1000 / this.#metrics.averageGenerationTime;
    }
  }

  /**
   * Get performance metrics
   * @returns Current RNG performance metrics
   */
  public getMetrics(): RNGMetrics {
    return { ...this.#metrics };
  }
}

// Export singleton instance getter
export const rngService = RNGService.getInstance();
