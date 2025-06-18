# 23-GenerateRNGService.ps1 - Phase 2 Core Domain Implementation
# Generates complete RNGService with Bitcoin block-seeded deterministic random number generation
# ARCHITECTURE: Singleton pattern with Mulberry32 PRNG algorithm for high-quality entropy
# Reference: script_checklist.md lines 23-GenerateRNGService.ps1
# Reference: build_design.md lines 1200-1320 - RNG service implementation and Bitcoin integration
#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

try {
    Import-Module "$PSScriptRoot\utils.psm1" -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import utilities module: $($_.Exception.Message)"
    exit 1
}

$ErrorActionPreference = "Stop"

try {
    Write-StepHeader "RNG Service Generation - Phase 2 Core Domain Implementation"
    Write-InfoLog "Generating complete RNGService with Bitcoin block-seeded deterministic PRNG"

    # Define paths
    $rngDomainPath = Join-Path $ProjectRoot "src/domains/rng"
    $servicesPath = Join-Path $rngDomainPath "services"
    $typesPath = Join-Path $rngDomainPath "types"
    $interfacesPath = Join-Path $rngDomainPath "interfaces"
    $utilsPath = Join-Path $rngDomainPath "utils"

    # Ensure directories exist
    Write-InfoLog "Creating RNG domain directory structure"
    New-Item -Path $servicesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $typesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $interfacesPath -ItemType Directory -Force | Out-Null
    New-Item -Path $utilsPath -ItemType Directory -Force | Out-Null

    Write-SuccessLog "RNG domain directories created successfully"

    # Generate RNG service interface
    Write-InfoLog "Generating IRNGService interface"
    $interfaceContent = @'
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
'@

    Set-Content -Path (Join-Path $interfacesPath "IRNGService.ts") -Value $interfaceContent -Encoding UTF8
    Write-SuccessLog "IRNGService interface generated successfully"

    # Generate RNG types
    Write-InfoLog "Generating RNG types definitions"
    $typesContent = @'
/**
 * @fileoverview RNG Types Definition
 * @description Type definitions for random number generation domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * PRNG algorithm types supported
 */
export type PRNGAlgorithm = ''mulberry32'' | ''xorshift'' | ''lcg'' | ''mt19937'';

/**
 * Seeding method types
 */
export type SeedingMethod = ''manual'' | ''bitcoin-block'' | ''timestamp'' | ''crypto-random'';

/**
 * RNG performance metrics
 */
export interface RNGMetrics {
  /** Total numbers generated */
  totalGenerated: number;
  /** Current algorithm being used */
  algorithm: PRNGAlgorithm;
  /** Seeding method used */
  seedingMethod: SeedingMethod;
  /** Last seed value used */
  lastSeed: number;
  /** Generation rate (numbers per second) */
  generationRate: number;
  /** Average generation time in microseconds */
  averageGenerationTime: number;
}

/**
 * Bitcoin block seeding configuration
 */
export interface BitcoinSeedConfig {
  /** Block number to use for seeding */
  blockNumber: number;
  /** Use block hash for seeding */
  useBlockHash: boolean;
  /** Use merkle root for additional entropy */
  useMerkleRoot: boolean;
  /** Use timestamp for temporal seeding */
  useTimestamp: boolean;
}

/**
 * RNG validation result
 */
export interface RNGValidation {
  /** Whether the sequence passes randomness tests */
  isValid: boolean;
  /** Chi-square test result */
  chiSquareTest: number;
  /** Autocorrelation test result */
  autocorrelationTest: number;
  /** Period length detected */
  periodLength: number;
  /** Validation errors if any */
  errors: string[];
}
'@

    Set-Content -Path (Join-Path $typesPath "rng.types.ts") -Value $typesContent -Encoding UTF8
    Write-SuccessLog "RNG types generated successfully"

    # Generate RNG Service implementation - Part 1 (Class structure and core methods)
    Write-InfoLog "Generating RNGService implementation - Part 1 (Core structure)"
    $serviceContent1 = @'
/**
 * @fileoverview RNG Service Implementation
 * @description High-performance deterministic random number generation with Bitcoin block seeding
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { IRNGService, RNGConfig, RNGState, RNGOptions } from ''@/domains/rng/interfaces/IRNGService'';
import {
  PRNGAlgorithm,
  SeedingMethod,
  RNGMetrics,
  BitcoinSeedConfig,
  RNGValidation
} from ''@/domains/rng/types/rng.types'';
import { createServiceLogger } from ''@/shared/lib/logger'';

/**
 * RNG Service implementing high-performance deterministic random number generation
 * Uses Mulberry32 PRNG algorithm with Bitcoin block-based seeding for unique organism traits
 * Follows singleton pattern for application-wide consistency
 */
export class RNGService implements IRNGService {
  /** Singleton instance */
  static #instance: RNGService | null = null;

  /** Current PRNG algorithm state */
  #state: number = 0;

  /** Current seed value */
  #seed: number = 0;

  /** Generation counter for metrics */
  #counter: number = 0;

  /** Service configuration */
  #config: RNGConfig;

  /** Performance metrics */
  #metrics: RNGMetrics;

  /** Winston logger instance */
  #logger = createServiceLogger(''RNGService'');

  /** Generated value cache for performance */
  #cache: number[] = [];

  /** Cache pointer for efficient access */
  #cachePointer: number = 0;

  /** Last Bitcoin block used for seeding */
  #lastBitcoinBlock: number = 0;

  /**
   * Private constructor enforcing singleton pattern
   * Initializes RNG service with Mulberry32 algorithm
   */
  private constructor() {
    this.#logger.info(''Initializing RNGService singleton instance'');

    // Initialize default configuration
    this.#config = {
      defaultSeed: Date.now(),
      useBitcoinSeeding: true,
      cacheSize: 1000,
      highPrecision: false
    };

    // Initialize performance metrics
    this.#metrics = {
      totalGenerated: 0,
      algorithm: ''mulberry32'',
      seedingMethod: ''timestamp'',
      lastSeed: 0,
      generationRate: 0,
      averageGenerationTime: 0
    };

    // Set initial seed
    this.setSeed(this.#config.defaultSeed!);

    this.#logger.info(''RNGService initialized successfully'', {
      seed: this.#seed,
      algorithm: this.#metrics.algorithm
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
}
'@

    Set-Content -Path (Join-Path $servicesPath "rngService.ts") -Value $serviceContent1 -Encoding UTF8
    Write-SuccessLog "RNGService implementation Part 1 generated successfully"

    # Generate RNG Service implementation - Part 2 (Core methods)
    Write-InfoLog "Generating RNGService implementation - Part 2 (Core methods)"
    $serviceContent2 = @'
/**
 * @fileoverview RNG Service Implementation
 * @description High-performance deterministic random number generation with Bitcoin block seeding
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { IRNGService, RNGConfig } from ''@/domains/rng/interfaces/IRNGService'';
import { RNGState, RNGMetrics, BlockHashSeed, RNGAlgorithm, SeedSource } from ''@/domains/rng/types/rng.types'';
import { BlockInfo } from ''@/domains/bitcoin/types/blockInfo.types'';
import { createServiceLogger } from ''@/shared/lib/logger'';

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
  #logger = createServiceLogger(''RNGService'');

  /** Internal random state for Mulberry32 algorithm */
  #internalState: number;

  /**
   * Private constructor enforcing singleton pattern
   * Initializes RNG with default configuration and state
   */
  private constructor() {
    this.#logger.info(''Initializing RNGService singleton instance'');

    // Initialize default configuration
    this.#config = {
      defaultSeed: 12345,
      useBitcoinSeeding: true,
      seedCacheSize: 100
    };

    // Initialize state with default values
    this.#state = {
      seed: this.#config.defaultSeed!,
      algorithm: ''mulberry32'',
      source: ''manual'',
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

    this.#logger.info(''RNGService initialized successfully'', {
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
    this.#logger.info(''Initializing RNGService with configuration'', { config });

    if (config) {
      this.#config = { ...this.#config, ...config };
    }

    // Initialize cache if size changed
    if (this.#config.cacheSize !== this.#cache.length) {
      this.#cache = new Array(this.#config.cacheSize!);
      this.#cachePointer = 0;
    }

    this.#logger.info(''RNGService initialization completed'');
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
    this.#metrics.seedingMethod = ''manual'';

    this.#logger.debug(''RNG seed set'', { seed, state: this.#state });
  }

  /**
   * Seed from Bitcoin block hash
   * @param blockNumber - Bitcoin block number
   */
  public async seedFromBlock(blockNumber: number): Promise<void> {
    this.#logger.info(''Seeding RNG from Bitcoin block'', { blockNumber });

    try {
      // This would normally fetch from BitcoinService
      // For now, use block number as seed base
      const blockSeed = this.#hashBlockNumber(blockNumber);
      this.setSeed(blockSeed);

      this.#lastBitcoinBlock = blockNumber;
      this.#metrics.seedingMethod = ''bitcoin-block'';

      this.#logger.info(''RNG seeded from Bitcoin block successfully'', {
        blockNumber,
        seed: blockSeed
      });
    } catch (error) {
      this.#logger.error(''Failed to seed from Bitcoin block'', { blockNumber, error });
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
      throw new Error(''Invalid range: min must be less than max'');
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
      throw new Error(''Invalid range: min must be less than max'');
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

    this.#logger.debug(''RNG state restored'', { seed: state.seed, counter: state.counter });
  }

  /**
   * Reset RNG to initial state
   */
  public reset(): void {
    this.#logger.info(''Resetting RNG service to initial state'');

    this.setSeed(this.#config.defaultSeed!);
    this.#metrics.totalGenerated = 0;
    this.#metrics.averageGenerationTime = 0;
    this.#cache.fill(0);
    this.#cachePointer = 0;

    this.#logger.info(''RNG service reset successfully'');
  }

  /**
   * Dispose of resources and cleanup
   */
  public dispose(): void {
    this.#logger.info(''Disposing RNG service resources'');

    this.#cache = [];
    RNGService.#instance = null;

    this.#logger.info(''RNG service disposed successfully'');
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
'@

    Add-Content -Path (Join-Path $servicesPath "rngService.ts") -Value $serviceContent2 -Encoding UTF8
    Write-SuccessLog "RNGService implementation Part 2 generated successfully"

    # Generate RNG Service implementation - Part 3 (State management and helpers)
    Write-InfoLog "Generating RNGService implementation - Part 3 (State management and completion)"
    $serviceContent3 = @'
/**
 * @fileoverview RNG Service Implementation
 * @description Complete random number generation service with Bitcoin block seeding
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { IRNGService, RNGConfig } from ''@/domains/rng/interfaces/IRNGService'';
import { RNGState, RNGMetrics, BlockHashSeed, RNGAlgorithm, SeedSource } from ''@/domains/rng/types/rng.types'';
import { BlockInfo } from ''@/domains/bitcoin/types/blockInfo.types'';
import { createServiceLogger } from ''@/shared/lib/logger'';

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
  #logger = createServiceLogger(''RNGService'');

  /** Internal random state for Mulberry32 algorithm */
  #internalState: number;

  /**
   * Private constructor enforcing singleton pattern
   * Initializes RNG with default configuration and state
   */
  private constructor() {
    this.#logger.info(''Initializing RNGService singleton instance'');

    // Initialize default configuration
    this.#config = {
      defaultSeed: 12345,
      useBitcoinSeeding: true,
      seedCacheSize: 100
    };

    // Initialize state with default values
    this.#state = {
      seed: this.#config.defaultSeed!,
      algorithm: ''mulberry32'',
      source: ''manual'',
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

    this.#logger.info(''RNGService initialized successfully'', {
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
   * Initialize the RNG service with custom configuration
   * @param config - Optional configuration settings
   */
  public initialize(config?: RNGConfig): void {
    this.#logger.info(''Initializing RNGService with configuration'', { config });

    if (config) {
      this.#config = { ...this.#config, ...config };
    }

    // Update seed cache size if specified
    if (config?.seedCacheSize && config.seedCacheSize !== this.#seedCache.size) {
      this.#seedCache.clear();
      this.#logger.debug(''Seed cache cleared due to size change'', {
        newSize: config.seedCacheSize
      });
    }

    this.#logger.info(''RNGService configuration updated successfully'');
  }

  /**
   * Seed the RNG using Bitcoin block hash data
   * Converts block hash to numeric seed for deterministic generation
   * @param blockInfo - Bitcoin block information
   * @returns Promise resolving to the seed value used
   */
  public async seedFromBlock(blockInfo: BlockInfo): Promise<number> {
    this.#logger.info(''Seeding RNG from Bitcoin block'', {
      blockNumber: blockInfo.height,
      blockHash: blockInfo.hash?.substring(0, 16) + ''...''
    });

    // Check cache first
    const cacheKey = `${blockInfo.height}_${blockInfo.hash}`;
    if (this.#seedCache.has(cacheKey)) {
      const cachedSeed = this.#seedCache.get(cacheKey)!;
      this.#setSeed(cachedSeed.seedValue, ''bitcoin-block'');
      this.#updateCacheHitRate(true);
      this.#logger.debug(''Used cached seed for block'', { blockNumber: blockInfo.height });
      return cachedSeed.seedValue;
    }

    // Generate seed from block hash
    const seed = this.#generateSeedFromHash(blockInfo.hash);

    // Cache the result
    const blockHashSeed: BlockHashSeed = {
      blockNumber: blockInfo.height,
      blockHash: blockInfo.hash,
      seedValue: seed,
      blockTimestamp: blockInfo.timestamp
    };

    this.#cacheSeed(cacheKey, blockHashSeed);
    this.#setSeed(seed, ''bitcoin-block'');
    this.#updateCacheHitRate(false);

    this.#logger.info(''RNG seeded from Bitcoin block successfully'', {
      blockNumber: blockInfo.height,
      seedValue: seed
    });

    return seed;
  }

  /**
   * Generate a random float between 0 and 1 using Mulberry32 algorithm
   * @returns Random number between 0 and 1
   */
  public random(): number {
    const startTime = performance.now();

    // Mulberry32 algorithm implementation
    this.#internalState |= 0;
    this.#internalState = (this.#internalState + 0x6D2B79F5) | 0;
    let t = Math.imul(this.#internalState ^ (this.#internalState >>> 15), this.#internalState | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    const result = ((t ^ (t >>> 14)) >>> 0) / 4294967296;

    // Update metrics
    this.#state.generationCount++;
    this.#metrics.totalGenerated++;
    this.#updateAverageTime(performance.now() - startTime);

    return result;
  }

  /**
   * Generate a random integer between min and max (inclusive)
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (inclusive)
   * @returns Random integer in specified range
   */
  public randomInt(min: number, max: number): number {
    if (min > max) {
      throw new Error(`Invalid range: min (${min}) must be <= max (${max})`);
    }

    const range = max - min + 1;
    return Math.floor(this.random() * range) + min;
  }

  /**
   * Generate a random float between min and max
   * @param min - Minimum value
   * @param max - Maximum value
   * @returns Random float in specified range
   */
  public randomFloat(min: number, max: number): number {
    if (min > max) {
      throw new Error(`Invalid range: min (${min}) must be <= max (${max})`);
    }

    return this.random() * (max - min) + min;
  }

  /**
   * Generate a random boolean with specified probability
   * @param probability - Probability of true (default 0.5)
   * @returns Random boolean value
   */
  public randomBoolean(probability: number = 0.5): boolean {
    if (probability < 0 || probability > 1) {
      throw new Error(`Invalid probability: ${probability}. Must be between 0 and 1`);
    }

    return this.random() < probability;
  }

  /**
   * Generate an array of random numbers
   * @param count - Number of values to generate
   * @param min - Minimum value (default 0)
   * @param max - Maximum value (default 1)
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
   * Get current seed value
   * @returns Current seed value
   */
  public getCurrentSeed(): number {
    return this.#state.seed;
  }

  /**
   * Reset RNG to initial state
   * Clears metrics and resets to default seed
   */
  public reset(): void {
    this.#logger.info(''Resetting RNG service to initial state'');

    this.#state = {
      seed: this.#config.defaultSeed!,
      algorithm: ''mulberry32'',
      source: ''manual'',
      generationCount: 0,
      lastSeeded: Date.now()
    };

    this.#internalState = this.#state.seed;
    this.#metrics.totalGenerated = 0;
    this.#metrics.averageGenerationTime = 0;
    this.#metrics.uniqueSeeds = 0;

    this.#logger.info(''RNG service reset successfully'');
  }

  /**
   * Dispose of resources and cleanup
   * Clears caches and resets singleton instance
   */
  public dispose(): void {
    this.#logger.info(''Disposing RNG service resources'');

    this.#seedCache.clear();
    RNGService.#instance = null;

    this.#logger.info(''RNG service disposed successfully'');
  }

  // Private helper methods

  /**
   * Generate numeric seed from Bitcoin block hash
   * @param hash - Bitcoin block hash string
   * @returns Numeric seed value
   */
  #generateSeedFromHash(hash: string): number {
    let seed = 0;
    for (let i = 0; i < Math.min(hash.length, 8); i++) {
      seed = (seed << 4) + parseInt(hash[i], 16);
    }
    return Math.abs(seed) || 1; // Ensure non-zero seed
  }

  /**
   * Set internal seed and update state
   * @param seed - New seed value
   * @param source - Source of the seed
   */
  #setSeed(seed: number, source: SeedSource): void {
    this.#state.seed = seed;
    this.#state.source = source;
    this.#state.lastSeeded = Date.now();
    this.#state.generationCount = 0;
    this.#internalState = seed;
    this.#metrics.uniqueSeeds++;
  }

  /**
   * Cache a block hash seed
   * @param key - Cache key
   * @param blockHashSeed - Seed data to cache
   */
  #cacheSeed(key: string, blockHashSeed: BlockHashSeed): void {
    // Implement LRU eviction if cache is full
    if (this.#seedCache.size >= this.#config.seedCacheSize!) {
      const firstKey = this.#seedCache.keys().next().value;
      this.#seedCache.delete(firstKey);
    }

    this.#seedCache.set(key, blockHashSeed);
  }

  /**
   * Update cache hit rate metrics
   * @param isHit - Whether this was a cache hit
   */
  #updateCacheHitRate(isHit: boolean): void {
    const totalRequests = this.#metrics.uniqueSeeds + (isHit ? 0 : 1);
    const hits = Math.floor(this.#metrics.cacheHitRate * totalRequests) + (isHit ? 1 : 0);
    this.#metrics.cacheHitRate = hits / totalRequests;
  }

  /**
   * Update average generation time
   * @param time - Time taken for this generation
   */
  #updateAverageTime(time: number): void {
    const total = this.#metrics.totalGenerated;
    this.#metrics.averageGenerationTime =
      ((this.#metrics.averageGenerationTime * (total - 1)) + time) / total;
  }
}

// Export singleton instance getter
export const rngService = RNGService.getInstance();
'@

    # Append Part 3 to complete the service
    Add-Content -Path (Join-Path $servicesPath "rngService.ts") -Value $serviceContent3 -Encoding UTF8
    Write-SuccessLog "RNGService implementation Part 3 generated successfully"

    # Generate export index file
    Write-InfoLog "Generating RNG domain export index"
    $indexContent = @'
/**
 * @fileoverview RNG Domain Exports
 * @description Main export file for RNG domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { RNGService, rngService } from ''./services/rngService'';

// Interface exports
export type { IRNGService, RNGConfig } from ''./interfaces/IRNGService'';

// Type exports
export type {
  RNGState,
  RNGMetrics,
  BlockHashSeed,
  RNGAlgorithm,
  SeedSource
} from ''./types/rng.types'';
'@

    Set-Content -Path (Join-Path $rngDomainPath "index.ts") -Value $indexContent -Encoding UTF8
    Write-SuccessLog "RNG domain export index generated successfully"

    Write-SuccessLog "RNG Service generation completed successfully"
    Write-InfoLog "Generated files:"
    Write-InfoLog "  - src/domains/rng/interfaces/IRNGService.ts"
    Write-InfoLog "  - src/domains/rng/types/rng.types.ts"
    Write-InfoLog "  - src/domains/rng/services/rngService.ts"
    Write-InfoLog "  - src/domains/rng/index.ts"

    exit 0
}
catch {
    Write-ErrorLog "RNG Service generation failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Pop-Location -ErrorAction SilentlyContinue } catch { }
}