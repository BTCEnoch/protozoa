/**
 * @fileoverview RNG Service Implementation
 * @description High-performance deterministic random number generation with Bitcoin block seeding
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { IRNGService, RNGConfig, RNGOptions, RNGState } from '@/domains/rng/interfaces/IRNGService';
import { RNGMetrics } from '@/domains/rng/types/rng.types';
import { createServiceLogger } from '@/shared/lib/logger';

/**
 * RNG Service implementing high-performance deterministic random number generation
 * Uses Mulberry32 PRNG algorithm with Bitcoin block-based seeding for unique organism traits
 * Follows singleton pattern for application-wide consistency
 */
export class RNGService implements IRNGService {
  /** Singleton instance */
  private static _instance: RNGService | null = null;
  
  /** Current PRNG algorithm state */
  private _internalState: number = 0;
  
  /** Current seed value */
  private _seed: number = 0;
  
  /** Generation counter for metrics */
  private _counter: number = 0;
  
  /** Service configuration */
  private _config: RNGConfig;
  
  /** Performance metrics */
  private _metrics: RNGMetrics;
  
  /** Winston logger instance */
  private _logger = createServiceLogger('RNGService');
  
  /** Generated value cache for performance */
  private _cache: number[] = [];
  
  /** Cache pointer for efficient access */
  private _cachePointer: number = 0;
  
  /** Last Bitcoin block used for seeding */
  private _lastBitcoinBlock: number = 0;
  
  /**
   * Private constructor enforcing singleton pattern
   * Initializes RNG service with Mulberry32 algorithm
   */
  private constructor() {
    this._logger.info('Initializing RNGService singleton instance');
    
    // Initialize default configuration
    this._config = {
      defaultSeed: Date.now(),
      useBitcoinSeeding: true,
      cacheSize: 1000,
      highPrecision: false
    };
    
    // Initialize performance metrics
    this._metrics = {
      totalGenerated: 0,
      algorithm: 'mulberry32',
      seedingMethod: 'timestamp',
      lastSeed: 0,
      generationRate: 0,
      averageGenerationTime: 0
    };
    
    // Set initial seed
    this.setSeed(this._config.defaultSeed!);
    
    this._logger.info('RNGService initialized successfully', {
      seed: this._seed,
      algorithm: this._metrics.algorithm
    });
  }
  
  /**
   * Get singleton instance of RNGService
   * Creates new instance if none exists
   * @returns RNGService singleton instance
   */
  public static getInstance(): RNGService {
    if (!RNGService._instance) {
      RNGService._instance = new RNGService();
    }
    return RNGService._instance;
  }

  /**
   * Initialize the RNG service with configuration
   * @param config - Optional RNG configuration
   */
  public async initialize(config?: RNGConfig): Promise<void> {
    this._logger.info('Initializing RNGService with configuration', { config });
    
    if (config) {
      this._config = { ...this._config, ...config };
    }
    
    // Initialize cache if size changed
    if (this._config.cacheSize !== this._cache.length) {
      this._cache = new Array(this._config.cacheSize!);
      this._cachePointer = 0;
    }
    
    this._logger.info('RNGService initialization completed');
  }

  /**
   * Set seed for deterministic generation
   * @param seed - Seed value for PRNG
   */
  public setSeed(seed: number): void {
    this._seed = seed;
    this._internalState = seed;
    this._counter = 0;
    this._cachePointer = 0;
    this._metrics.lastSeed = seed;
    this._metrics.seedingMethod = 'manual';
    
    this._logger.debug('RNG seed set', { seed, state: this._internalState });
  }

  /**
   * Seed from Bitcoin block hash
   * @param blockNumber - Bitcoin block number
   */
  public async seedFromBlock(blockNumber: number): Promise<void> {
    this._logger.info('Seeding RNG from Bitcoin block', { blockNumber });
    
    try {
      // This would normally fetch from BitcoinService
      // For now, use block number as seed base
      const blockSeed = this._hashBlockNumber(blockNumber);
      this.setSeed(blockSeed);
      
      this._lastBitcoinBlock = blockNumber;
      this._metrics.seedingMethod = 'bitcoin-block';
      
      this._logger.info('RNG seeded from Bitcoin block successfully', {
        blockNumber,
        seed: blockSeed
      });
    } catch (error) {
      this._logger.error('Failed to seed from Bitcoin block', { blockNumber, error });
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
    this._internalState |= 0;
    this._internalState = (this._internalState + 0x6D2B79F5) | 0;
    let t = Math.imul(this._internalState ^ (this._internalState >>> 15), 1 | this._internalState);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    const result = ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    
    // Update metrics
    this._counter++;
    this._metrics.totalGenerated++;
    
    const endTime = performance.now();
    this._updateGenerationMetrics(endTime - startTime);
    
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
      throw new Error('Invalid range: min must be less than max');
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
      throw new Error('Invalid range: min must be less than max');
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
    const originalSeed = this._seed;
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

  // Private helper methods

  /**
   * Hash block number to generate seed
   * @param blockNumber - Bitcoin block number
   * @returns Numeric seed value
   */
  private _hashBlockNumber(blockNumber: number): number {
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
  private _updateGenerationMetrics(time: number): void {
    const total = this._metrics.totalGenerated;
    
    if (total === 1) {
      this._metrics.averageGenerationTime = time;
      this._metrics.generationRate = 1000 / time;
    } else {
      this._metrics.averageGenerationTime = 
        ((this._metrics.averageGenerationTime * (total - 1)) + time) / total;
      this._metrics.generationRate = 1000 / this._metrics.averageGenerationTime;
    }
  }

  /**
   * Get current RNG state for serialization
   * @returns Current RNG state
   */
  public getState(): RNGState {
    return {
      seed: this._seed,
      state: this._internalState,
      counter: this._counter,
      lastBlock: this._lastBitcoinBlock
    };
  }

  /**
   * Restore RNG state from serialized data
   * @param state - RNG state to restore
   */
  public setState(state: RNGState): void {
    this._seed = state.seed;
    this._internalState = state.state;
    this._counter = state.counter;
    this._cachePointer = 0;
    this._lastBitcoinBlock = state.lastBlock || 0;
    
    this._metrics.lastSeed = state.seed;
    this._metrics.totalGenerated = state.counter;
    
    this._logger.debug('RNG state restored', { seed: state.seed, counter: state.counter });
  }

  /**
   * Reset RNG to initial state
   */
  public reset(): void {
    this._logger.info('Resetting RNG service to initial state');
    
    this.setSeed(this._config.defaultSeed!);
    this._metrics.totalGenerated = 0;
    this._metrics.averageGenerationTime = 0;
    this._cache.fill(0);
    this._cachePointer = 0;
    
    this._logger.info('RNG service reset successfully');
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this._logger.info('Disposing RNG service resources');
    
    this._cache = [];
    RNGService._instance = null;
    
    this._logger.info('RNG service disposed successfully');
  }

  /**
   * Get performance metrics
   * @returns Current RNG performance metrics
   */
  public getMetrics(): RNGMetrics {
    return { ...this._metrics };
  }
}

// Export singleton instance getter
export const rngService = RNGService.getInstance();
