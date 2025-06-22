/**
 * @fileoverview RNG Service Implementation (Template)
 * @module @/domains/rng/services/RNGService
 * @version 2.0.0
 */

import type { IRNGService, RNGConfig, RNGState, RNGOptions } from "@/domains/rng/interfaces/IRNGService"
import type { RNGMetrics, PRNGAlgorithm, SeedSource } from "@/domains/rng/types/rng.types"
import { logger, perfLogger } from "@/shared/lib/logger"

/**
 * Mulberry32 PRNG Algorithm Implementation
 * @param seed - The seed value for the PRNG
 * @returns A function that generates pseudo-random numbers
 */
function mulberry32(seed: number): () => number {
  return function () {
    let t = (seed += 0x6d2b79f5)
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

/**
 * Enhanced RNG Service with rehash chain and purpose-specific generators
 * Implements singleton pattern with comprehensive logging and metrics
 */
export class RNGService implements IRNGService {
  private static instance: RNGService | null = null
  
  /**
   * Get singleton instance of RNGService
   * @returns RNGService instance
   */
  public static getInstance(): RNGService {
    if (!RNGService.instance) {
      RNGService.instance = new RNGService()
    }
    return RNGService.instance
  }

  private constructor() {
    // Initialize configuration
    this.#config = {
      defaultSeed: 12345,
      useBitcoinSeeding: true,
      maxChainLength: 1000
    }
    
    // Initialize state
    this.#state = {
      seed: 12345,
      counter: 0,
      chainLength: 0
    }
    
    // Initialize metrics
    this.#metrics = {
      totalGenerated: 0,
      averageGenerationTime: 0,
      algorithm: "mulberry32",
      source: "manual",
      rehashCount: 0
    }
    
    logger.info("🎲 RNGService instantiated with enhanced features")
    this.setSeed(this.#state.seed)
  }

  /* ------------------------------- Private Fields ------------------------------ */
  #config!: RNGConfig
  #state!: RNGState
  #metrics!: RNGMetrics
  
  #prng: () => number = mulberry32(12345)
  
  // New: Purpose-specific RNG generators
  #purposeRngs: Map<string, () => number> = new Map()

  /* ------------------------------- Public Methods ------------------------------ */
  
  /**
   * Initialize RNG service with configuration
   * @param config - Optional configuration overrides
   */
  async initialize(config?: RNGConfig): Promise<void> {
    const timer = 'rng_initialize'
    perfLogger.startTimer(timer)
    
    try {
      if (config) {
        this.#config = { ...this.#config, ...config }
        logger.info("🔧 RNGService configuration updated", { config })
      }
      
      if (config?.defaultSeed !== undefined) {
        this.setSeed(config.defaultSeed)
      }
      
      const duration = perfLogger.endTimer(timer)
      logger.info("✅ RNGService initialized", { duration: `${duration.toFixed(2)}ms` })
      
    } catch (error) {
      perfLogger.endTimer(timer)
      logger.error("❌ RNGService initialization failed", { error })
      throw error
    }
  }

  /**
   * Set seed for main RNG generator
   * @param seed - Seed value
   */
  setSeed(seed: number): void {
    this.#state.seed = seed >>> 0
    this.#prng = mulberry32(this.#state.seed)
    this.#state.counter = 0
    this.#state.chainLength = 0 // Reset chain length
    this.#metrics.source = "manual"
    
    logger.debug("🎯 RNG seed set", { seed: this.#state.seed })
  }

  /**
   * NEW: Rehash current seed to create new seed value
   * Implements chain length protection to prevent infinite loops
   */
  rehashSeed(): void {
    if (this.#state.chainLength >= (this.#config.maxChainLength || 1000)) {
      logger.warn("⚠️ Rehash chain length limit reached, resetting to default seed")
      this.setSeed(this.#config.defaultSeed || 12345)
      return
    }
    
    // Generate new seed from current state - ensure #prng is available
    if (!this.#prng) {
      logger.error("⚠️ PRNG not initialized, resetting to default")
      this.setSeed(this.#config.defaultSeed || 12345)
      return
    }
    
    const newSeed = Math.floor(this.#prng!() * 0xFFFFFFFF)
    this.#state.chainLength++
    this.#metrics.rehashCount++
    
    this.setSeed(newSeed)
    logger.debug("🔄 Seed rehashed", { 
      newSeed, 
      chainLength: this.#state.chainLength,
      totalRehashes: this.#metrics.rehashCount
    })
  }

  /**
   * NEW: Get purpose-specific RNG generator
   * Creates isolated RNG streams for different use cases
   * @param purpose - Purpose identifier (e.g., 'particle-init', 'trait-mutation')
   * @returns Dedicated RNG function for this purpose
   */
  getPurposeRng(purpose: string): () => number {
    if (!this.#purposeRngs.has(purpose)) {
      // Create purpose-specific seed by hashing purpose string with main seed
      const purposeHash = this.#hashString(purpose)
      const purposeSeed = (this.#state.seed ^ purposeHash) >>> 0
      const purposeRng = mulberry32(purposeSeed)
      
      this.#purposeRngs.set(purpose, purposeRng)
      logger.debug("[RNG] Purpose RNG created", { purpose, seed: purposeSeed })
    }
    
    // [RNG] Safe retrieval with fallback
    const purposeRng = this.#purposeRngs.get(purpose)
    if (!purposeRng) {
      logger.error("[RNG] Purpose RNG not found after creation", { purpose })
      throw new Error(`Failed to create purpose RNG for: ${purpose}`)
    }
    
    return purposeRng
  }

  /**
   * Seed RNG from Bitcoin block data
   * @param blockNumber - Bitcoin block number
   */
  async seedFromBlock(blockNumber: number): Promise<void> {
    const timer = 'rng_seed_from_block'
    perfLogger.startTimer(timer)
    
    try {
      // Simplified: use blockNumber as deterministic seed
      // Real implementation would fetch and hash block header
      this.setSeed(blockNumber)
      this.#metrics.source = "bitcoin-block"
      
      const duration = perfLogger.endTimer(timer)
      logger.info("🔗 RNG seeded from Bitcoin block", { 
        blockNumber, 
        seed: this.#state.seed,
        duration: `${duration.toFixed(2)}ms`
      })
      
    } catch (error) {
      perfLogger.endTimer(timer)
      logger.error("❌ Failed to seed from Bitcoin block", { blockNumber, error })
      throw error
    }
  }

  /**
   * Generate random number [0, 1)
   * @returns Random float between 0 and 1
   */
  random(): number {
    const timer = 'rng_generate'
    perfLogger.startTimer(timer)
    
    // Ensure PRNG is initialized
    if (!this.#prng) {
      logger.error("⚠️ PRNG not initialized in random(), resetting to default")
      this.setSeed(this.#config.defaultSeed || 12345)
    }
    
    this.#state.counter++
    this.#metrics.totalGenerated++
    
    const result = this.#prng!()
    const duration = perfLogger.endTimer(timer)
    
    // Update average generation time
    this.#metrics.averageGenerationTime = 
      (this.#metrics.averageGenerationTime * (this.#metrics.totalGenerated - 1) + duration) / 
      this.#metrics.totalGenerated
      
    return result
  }

  /**
   * Generate random integer in range [min, max)
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (exclusive)
   * @returns Random integer
   */
  randomInt(min: number, max: number): number {
    return Math.floor(this.random() * (max - min)) + min
  }

  /**
   * Generate random float in range [min, max)
   * @param min - Minimum value (inclusive)
   * @param max - Maximum value (exclusive)
   * @returns Random float
   */
  randomFloat(min: number, max: number): number {
    return this.random() * (max - min) + min
  }

  /**
   * Generate array of random numbers with optional seeding
   * @param options - Generation options
   * @returns Array of random numbers
   */
  randomArray({ min = 0, max = 1, count = 1, seed }: RNGOptions): number[] {
    const timer = 'rng_generate_array'
    perfLogger.startTimer(timer)
    
    const originalSeed = this.#state.seed
    if (seed !== undefined) {
      this.setSeed(seed)
    }
    
    const arr = Array.from({ length: count }, () => this.randomFloat(min, max))
    
    if (seed !== undefined) {
      this.setSeed(originalSeed)
    }
    
    const duration = perfLogger.endTimer(timer)
    logger.debug("📊 Random array generated", { count, duration: `${duration.toFixed(2)}ms` })
    
    return arr
  }

  /**
   * Get current RNG state
   * @returns Copy of current state
   */
  getState(): RNGState {
    return { ...this.#state }
  }

  /**
   * Set RNG state
   * @param state - State to restore
   */
  setState(state: RNGState): void {
    this.#state = { ...state }
    this.setSeed(state.seed)
    
    logger.debug("📂 RNG state restored", { state })
  }

  /**
   * Get RNG metrics and performance data
   * @returns Current metrics
   */
  getMetrics(): RNGMetrics {
    return { ...this.#metrics }
  }

  /**
   * Reset RNG to default state
   */
  reset(): void {
    this.setSeed(this.#config.defaultSeed || 12345)
    this.#state.chainLength = 0
    this.#metrics.totalGenerated = 0
    this.#metrics.averageGenerationTime = 0
    this.#metrics.rehashCount = 0
    this.#purposeRngs.clear()
    
    logger.info("🔄 RNG service reset to default state")
  }

  /**
   * Health check for RNG service
   * @returns Service health status
   */
  async healthCheck(): Promise<boolean> {
    try {
      // Test basic functionality
      const testValue = this.random()
      const isHealthy = testValue >= 0 && testValue < 1
      
      if (isHealthy) {
        logger.debug("✅ RNG health check passed")
      } else {
        logger.error("❌ RNG health check failed - invalid random value", { testValue })
      }
      
      return isHealthy
    } catch (error) {
      logger.error("❌ RNG health check failed with error", { error })
      return false
    }
  }

  /**
   * Dispose RNG service and cleanup resources
   */
  dispose(): void {
    logger.info("🧹 Disposing RNG service")
    
    // Clear purpose RNGs
    this.#purposeRngs.clear()
    
    // Reset metrics
    this.#metrics = {
      totalGenerated: 0,
      averageGenerationTime: 0,
      algorithm: "mulberry32",
      source: "manual",
      rehashCount: 0
    }
    
    // Clear singleton instance
    RNGService.instance = null
    
    logger.info("✅ RNG service disposed successfully")
  }

  /* ------------------------------- Private Helpers ------------------------------ */
  
  /**
   * Simple string hash function for purpose-specific seeding
   * @param str - String to hash
   * @returns Hash value
   */
  #hashString(str: string): number {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash // Convert to 32-bit integer
    }
    return Math.abs(hash)
  }
}

export const rngService = RNGService.getInstance()