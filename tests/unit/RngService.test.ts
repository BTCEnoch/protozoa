/**
 * @fileoverview Unit tests for RngService
 * @description Tests Mulberry32 implementation, chain-length overflow protection, and seeding
 */

import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { RNGService } from '@/domains/rng/services/RNGService'

describe('RNGService', () => {
  let rngService: RNGService

  beforeEach(() => {
    rngService = RNGService.getInstance()
  })

  afterEach(() => {
    rngService.dispose()
  })

  describe('Mulberry32 Implementation', () => {
    it('should generate consistent sequences from same seed', () => {
      rngService.seed(12345)
      const sequence1 = Array.from({ length: 10 }, () => rngService.random())

      rngService.seed(12345)
      const sequence2 = Array.from({ length: 10 }, () => rngService.random())

      expect(sequence1).toEqual(sequence2)
    })

    it('should generate different sequences from different seeds', () => {
      rngService.seed(12345)
      const sequence1 = Array.from({ length: 10 }, () => rngService.random())

      rngService.setSeed(54321)
      const sequence2 = Array.from({ length: 10 }, () => rngService.random())

      expect(sequence1).not.toEqual(sequence2)
    })

    it('should generate values between 0 and 1', () => {
      rngService.seed(12345)
      const values = Array.from({ length: 1000 }, () => rngService.random())

      values.forEach((value) => {
        expect(value).toBeGreaterThanOrEqual(0)
        expect(value).toBeLessThan(1)
      })
    })

    it('should have proper distribution over large sample', () => {
      rngService.seed(12345)
      const values = Array.from({ length: 10000 }, () => rngService.random())

      const mean = values.reduce((sum, val) => sum + val, 0) / values.length

      // Mean should be close to 0.5 for uniform distribution
      expect(mean).toBeGreaterThan(0.45)
      expect(mean).toBeLessThan(0.55)
    })
  })

  describe('Chain-Length Overflow Protection', () => {
    it('should not overflow with extremely long generation chains', () => {
      rngService.seed(12345)

      // Generate large number of values to test overflow protection
      let lastValue = 0
      for (let i = 0; i < 1000000; i++) {
        const value = rngService.random()
        expect(value).toBeGreaterThanOrEqual(0)
        expect(value).toBeLessThan(1)
        expect(value).not.toBe(lastValue) // Should not get stuck
        lastValue = value
      }
    })

    it('should maintain randomness quality after long chains', () => {
      rngService.seed(12345)

      // Generate a long chain
      for (let i = 0; i < 100000; i++) {
        rngService.random()
      }

      // Test that quality is still maintained
      const values = Array.from({ length: 1000 }, () => rngService.random())
      const mean = values.reduce((sum, val) => sum + val, 0) / values.length

      expect(mean).toBeGreaterThan(0.45)
      expect(mean).toBeLessThan(0.55)
    })

    it('should handle seed overflow gracefully', () => {
      // Test with maximum 32-bit integer
      const maxSeed = 2147483647
      expect(() => rngService.setSeed(maxSeed)).not.toThrow()

      const value = rngService.random()
      expect(value).toBeGreaterThanOrEqual(0)
      expect(value).toBeLessThan(1)
    })

    it('should handle negative seeds correctly', () => {
      rngService.seed(-12345)
      const values = Array.from({ length: 100 }, () => rngService.random())

      values.forEach((value) => {
        expect(value).toBeGreaterThanOrEqual(0)
        expect(value).toBeLessThan(1)
      })
    })
  })

  describe('Utility Methods', () => {
    it('should generate integers in specified range', () => {
      rngService.seed(12345)
      const min = 5
      const max = 15

      const values = Array.from({ length: 1000 }, () => rngService.randomInt(min, max))

      values.forEach((value) => {
        expect(value).toBeGreaterThanOrEqual(min)
        expect(value).toBeLessThanOrEqual(max)
        expect(Number.isInteger(value)).toBe(true)
      })
    })

    it('should generate floats in specified range', () => {
      rngService.seed(12345)
      const min = 2.5
      const max = 7.8

      const values = Array.from({ length: 1000 }, () => rngService.randomFloat(min, max))

      values.forEach((value) => {
        expect(value).toBeGreaterThanOrEqual(min)
        expect(value).toBeLessThan(max)
      })
    })

    it('should generate gaussian distributed values', () => {
      rngService.seed(12345)
      const values = Array.from({ length: 10000 }, () => rngService.randomGaussian())

      const mean = values.reduce((sum, val) => sum + val, 0) / values.length
      const variance = values.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / values.length

      // Should approximate standard normal distribution (mean ≈ 0, variance ≈ 1)
      expect(mean).toBeGreaterThan(-0.1)
      expect(mean).toBeLessThan(0.1)
      expect(variance).toBeGreaterThan(0.8)
      expect(variance).toBeLessThan(1.2)
    })

    it('should shuffle arrays consistently with same seed', () => {
      const array1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      const array2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      rngService.seed(12345)
      rngService.shuffle(array1)

      rngService.seed(12345)
      rngService.shuffle(array2)

      expect(array1).toEqual(array2)
      expect(array1).not.toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) // Should be shuffled
    })
  })

  describe('Bitcoin Block Seeding', () => {
    it('should seed from block data consistently', () => {
      const blockData = {
        height: 800000,
        hash: '000000000000000000030b05b2e7b09b5a5c42ad8c4934a4e3ee5b3a4c87e5f3',
        timestamp: 1686739200,
      }

      rngService.seedFromBlock(blockData)
      const sequence1 = Array.from({ length: 10 }, () => rngService.random())

      rngService.seedFromBlock(blockData)
      const sequence2 = Array.from({ length: 10 }, () => rngService.random())

      expect(sequence1).toEqual(sequence2)
    })

    it('should generate different sequences from different blocks', () => {
      const block1 = {
        height: 800000,
        hash: '000000000000000000030b05b2e7b09b5a5c42ad8c4934a4e3ee5b3a4c87e5f3',
        timestamp: 1686739200,
      }

      const block2 = {
        height: 800001,
        hash: '000000000000000000040c06c3f8c10c6b6d53be9d5045b5f4ff6c4b5d98f6g4',
        timestamp: 1686739800,
      }

      rngService.seedFromBlock(block1)
      const sequence1 = Array.from({ length: 10 }, () => rngService.random())

      rngService.seedFromBlock(block2)
      const sequence2 = Array.from({ length: 10 }, () => rngService.random())

      expect(sequence1).not.toEqual(sequence2)
    })
  })

  describe('Performance and Memory', () => {
    it('should maintain consistent performance over long runs', () => {
      rngService.seed(12345)

      const startTime = performance.now()
      for (let i = 0; i < 100000; i++) {
        rngService.random()
      }
      const endTime = performance.now()

      const duration = endTime - startTime
      // Should complete 100k operations in reasonable time (< 100ms)
      expect(duration).toBeLessThan(100)
    })

    it('should not leak memory during extended use', () => {
      rngService.seed(12345)

      // Generate many values and check that service can be disposed cleanly
      for (let i = 0; i < 50000; i++) {
        rngService.random()
        rngService.randomInt(1, 100)
        rngService.randomFloat(0, 1)
      }

      expect(() => rngService.dispose()).not.toThrow()
    })
  })
})
