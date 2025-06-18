/**
 * @fileoverview RNG Types Definition
 * @description Type definitions for random number generation domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

/**
 * PRNG algorithm types supported
 */
export type PRNGAlgorithm = 'mulberry32' | 'xorshift' | 'lcg' | 'mt19937';

/**
 * Seeding method types
 */
export type SeedingMethod = 'manual' | 'bitcoin-block' | 'timestamp' | 'crypto-random';

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
