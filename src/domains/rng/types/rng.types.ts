/**
 * @fileoverview RNG Domain Types (Template)
 */

// Supported PRNG algorithms
export type PRNGAlgorithm = "mulberry32" | "xorshift" | "lcg"

// Seed source enumeration
export type SeedSource = "manual" | "bitcoin-block" | "timestamp"

export interface RNGMetrics {
  totalGenerated: number
  averageGenerationTime: number
  algorithm: PRNGAlgorithm
  source: SeedSource
}