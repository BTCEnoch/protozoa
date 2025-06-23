/**
 * @fileoverview RNG Types Definition (Template)
 * @module @/domains/rng/types/rng.types
 * @version 2.0.0
 */

/**
 * Pseudo-Random Number Generator algorithms supported
 */
export type PRNGAlgorithm = "mulberry32" | "xoshiro128" | "mersenne-twister"

/**
 * Source of the RNG seed
 */
export type SeedSource = "manual" | "bitcoin-block" | "timestamp" | "crypto-random" | "rehash-chain"

/**
 * RNG configuration options
 */
export interface RNGConfig {
  /** Default seed value */
  defaultSeed?: number
  
  /** Enable Bitcoin block seeding */
  useBitcoinSeeding?: boolean
  
  /** Maximum length of rehash chains to prevent infinite loops */
  maxChainLength?: number
  
  /** PRNG algorithm to use */
  algorithm?: PRNGAlgorithm
  
  /** Enable purpose-specific RNG generators */
  enablePurposeRngs?: boolean
}

/**
 * Enhanced RNG state with chain tracking
 */
export interface RNGState {
  /** Current seed value */
  seed: number
  
  /** Number of random values generated */
  counter: number
  
  /** Current rehash chain length */
  chainLength: number
  
  /** Timestamp when state was last modified */
  lastModified?: number
}

/**
 * RNG generation options
 */
export interface RNGOptions {
  /** Minimum value (inclusive) */
  min?: number
  
  /** Maximum value (exclusive) */
  max?: number
  
  /** Number of values to generate */
  count?: number
  
  /** Optional seed override */
  seed?: number
  
  /** Purpose identifier for purpose-specific RNG */
  purpose?: string
}

/**
 * Enhanced RNG metrics and performance data
 */
export interface RNGMetrics {
  /** Total number of random values generated */
  totalGenerated: number
  
  /** Average time per generation in milliseconds */
  averageGenerationTime: number
  
  /** Algorithm currently in use */
  algorithm: PRNGAlgorithm
  
  /** Source of current seed */
  source: SeedSource
  
  /** Number of rehash operations performed */
  rehashCount: number
  
  /** Number of purpose-specific generators created */
  purposeGenerators?: number
  
  /** Memory usage statistics */
  memoryUsage?: {
    /** Bytes used by RNG state */
    stateSize: number
    
    /** Bytes used by purpose generators */
    purposeGeneratorsSize: number
  }
  
  /** Performance statistics */
  performance?: {
    /** Fastest generation time */
    fastestGeneration: number
    
    /** Slowest generation time */
    slowestGeneration: number
    
    /** Standard deviation of generation times */
    standardDeviation: number
  }
}

/**
 * Purpose-specific RNG configuration
 */
export interface PurposeRNGConfig {
  /** Purpose identifier */
  purpose: string
  
  /** Optional seed override for this purpose */
  seed?: number
  
  /** Whether to isolate this RNG from main generator */
  isolated?: boolean
  
  /** Custom configuration for this purpose */
  config?: Partial<RNGConfig>
}

/**
 * RNG validation result
 */
export interface RNGValidationResult {
  /** Whether the RNG passes basic validation */
  isValid: boolean
  
  /** Validation errors, if any */
  errors: string[]
  
  /** Statistical tests performed */
  tests: {
    /** Chi-square test result */
    chiSquare?: number
    
    /** Kolmogorov-Smirnov test result */
    kolmogorovSmirnov?: number
    
    /** Autocorrelation test result */
    autocorrelation?: number
  }
  
  /** Quality metrics */
  quality: {
    /** Uniformity score (0-1) */
    uniformity: number
    
    /** Independence score (0-1) */
    independence: number
    
    /** Randomness score (0-1) */
    randomness: number
  }
}

/**
 * Batch RNG operation configuration
 */
export interface BatchRNGConfig {
  /** Number of values per batch */
  batchSize: number
  
  /** Number of batches to generate */
  batchCount: number
  
  /** Generation options for each batch */
  options: RNGOptions
  
  /** Whether to use Web Workers for generation */
  useWorkers?: boolean
  
  /** Progress callback */
  onProgress?: (completed: number, total: number) => void
}

/**
 * RNG worker message types
 */
export interface RNGWorkerMessage {
  /** Message type */
  type: 'generate' | 'seed' | 'configure' | 'dispose'
  
  /** Message payload */
  payload: any
  
  /** Request ID for response correlation */
  requestId?: string
}

// All types are exported individually above via 'export interface' or 'export enum'
