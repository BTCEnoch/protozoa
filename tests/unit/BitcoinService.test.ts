/**
 * @fileoverview Unit tests for BitcoinService
 * @description Tests retry logic, LRU caching, and API integration
 */

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { BitcoinService } from '@/domains/bitcoin/services/BitcoinService'
import type { BitcoinConfig } from '@/domains/bitcoin/interfaces/IBitcoinService'

// Mock fetch globally
global.fetch = vi.fn()

describe('BitcoinService', () => {
  let bitcoinService: BitcoinService
  const mockFetch = global.fetch as any

  beforeEach(() => {
    bitcoinService = BitcoinService.getInstance()
    mockFetch.mockClear()
    bitcoinService.clearCache()
  })

  afterEach(() => {
    bitcoinService.dispose()
    vi.restoreAllMocks()
  })

  describe('Retry Logic', () => {
    it('should retry on network failures with exponential backoff', async () => {
      // Mock fetch to fail twice, then succeed
      mockFetch
        .mockRejectedValueOnce(new Error('Network error'))
        .mockRejectedValueOnce(new Error('Network error'))
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve({ height: 700000, timestamp: 123456789 }),
        })

      const startTime = Date.now()
      const result = await bitcoinService.getBlockInfo(700000)
      const endTime = Date.now()

      // Should succeed after retries
      expect(result.data.height).toBe(700000)
      expect(mockFetch).toHaveBeenCalledTimes(3)

      // Should have taken at least 3 seconds due to exponential backoff (1s + 2s)
      expect(endTime - startTime).toBeGreaterThan(3000)
    })

    it('should fail after max retries are exhausted', async () => {
      // Mock fetch to always fail
      mockFetch.mockRejectedValue(new Error('Persistent network error'))

      await expect(bitcoinService.getBlockInfo(700001)).rejects.toThrow('Persistent network error')

      // Should have tried maxRetries + 1 times (initial + 3 retries = 4 total)
      expect(mockFetch).toHaveBeenCalledTimes(4)
    })

    it('should not retry on abort signal', async () => {
      mockFetch.mockRejectedValue(new Error('AbortError'))
      mockFetch.mockImplementation(() => {
        const error = new Error('AbortError')
        error.name = 'AbortError'
        return Promise.reject(error)
      })

      await expect(bitcoinService.getBlockInfo(700002)).rejects.toThrow('AbortError')

      // Should not retry on abort
      expect(mockFetch).toHaveBeenCalledTimes(1)
    })
  })

  describe('LRU Cache Implementation', () => {
    beforeEach(() => {
      // Initialize with small cache size for testing
      const config: BitcoinConfig = {
        cacheSize: 3,
        cacheTTL: 60000,
        enableCaching: true,
      }
      bitcoinService.initialize(config)
    })

    it('should cache successful responses', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ height: 800000, timestamp: 123456789 }),
      })

      // First call should hit the API
      const result1 = await bitcoinService.getBlockInfo(800000)
      expect(result1.fromCache).toBe(false)
      expect(mockFetch).toHaveBeenCalledTimes(1)

      // Second call should hit the cache
      const result2 = await bitcoinService.getBlockInfo(800000)
      expect(result2.fromCache).toBe(true)
      expect(mockFetch).toHaveBeenCalledTimes(1) // No additional API call
    })

    it('should evict least recently used entries when cache is full', async () => {
      mockFetch.mockImplementation((url: string) => {
        const blockHeight = url.split('/').pop()
        return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({ height: parseInt(blockHeight!), timestamp: 123456789 }),
        })
      })

      // Fill cache to capacity (3 entries)
      await bitcoinService.getBlockInfo(800000)
      await bitcoinService.getBlockInfo(800001)
      await bitcoinService.getBlockInfo(800002)

      // Access 800001 to make it recently used
      await bitcoinService.getBlockInfo(800001)

      // Add a new entry - should evict 800000 (least recently used)
      await bitcoinService.getBlockInfo(800003)

      // 800000 should be evicted and require a new API call
      mockFetch.mockClear()
      await bitcoinService.getBlockInfo(800000)
      expect(mockFetch).toHaveBeenCalledTimes(1)

      // 800001 should still be cached
      mockFetch.mockClear()
      await bitcoinService.getBlockInfo(800001)
      expect(mockFetch).toHaveBeenCalledTimes(0)
    })

    it('should respect cache TTL and expire old entries', async () => {
      // Initialize with very short TTL for testing
      const config: BitcoinConfig = {
        cacheSize: 10,
        cacheTTL: 100, // 100ms
        enableCaching: true,
      }
      bitcoinService.initialize(config)

      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ height: 800000, timestamp: 123456789 }),
      })

      // First call caches the result
      await bitcoinService.getBlockInfo(800000)
      expect(mockFetch).toHaveBeenCalledTimes(1)

      // Wait for cache to expire
      await new Promise((resolve) => setTimeout(resolve, 150))

      // Should make a new API call as cache expired
      await bitcoinService.getBlockInfo(800000)
      expect(mockFetch).toHaveBeenCalledTimes(2)
    })
  })

  describe('Cache Statistics', () => {
    it('should track cache hits and misses correctly', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ height: 800000, timestamp: 123456789 }),
      })

      // Initial stats should be zero
      let stats = bitcoinService.getCacheStats()
      expect(stats.hits).toBe(0)
      expect(stats.misses).toBe(0)
      expect(stats.hitRate).toBe(0)

      // First call is a cache miss
      await bitcoinService.getBlockInfo(800000)
      stats = bitcoinService.getCacheStats()
      expect(stats.misses).toBe(1)
      expect(stats.hitRate).toBe(0)

      // Second call is a cache hit
      await bitcoinService.getBlockInfo(800000)
      stats = bitcoinService.getCacheStats()
      expect(stats.hits).toBe(1)
      expect(stats.misses).toBe(1)
      expect(stats.hitRate).toBe(50)
    })
  })

  describe('Error Handling', () => {
    it('should handle HTTP error responses', async () => {
      mockFetch.mockResolvedValue({
        ok: false,
        status: 404,
        statusText: 'Not Found',
      })

      await expect(bitcoinService.getBlockInfo(900000)).rejects.toThrow('HTTP 404: Not Found')
    })

    it('should handle JSON parsing errors', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.reject(new Error('Invalid JSON')),
      })

      await expect(bitcoinService.getBlockInfo(800000)).rejects.toThrow('Invalid JSON')
    })
  })

  describe('Rate Limiting', () => {
    it('should enforce rate limiting between requests', async () => {
      const config: BitcoinConfig = {
        rateLimitDelay: 1000, // 1 second delay
      }
      bitcoinService.initialize(config)

      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ height: 800000, timestamp: 123456789 }),
      })

      const startTime = Date.now()

      // Make two sequential requests
      await bitcoinService.getBlockInfo(800000)
      await bitcoinService.getBlockInfo(800001)

      const endTime = Date.now()

      // Should have taken at least 1 second due to rate limiting
      expect(endTime - startTime).toBeGreaterThan(1000)
    })
  })

  describe('Metrics Tracking', () => {
    it('should track performance metrics correctly', async () => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ height: 800000, timestamp: 123456789 }),
      })

      // Make some successful requests
      await bitcoinService.getBlockInfo(800000)
      await bitcoinService.getBlockInfo(800001)

      const metrics = bitcoinService.getMetrics()
      expect(metrics.totalRequests).toBe(2)
      expect(metrics.successfulRequests).toBe(2)
      expect(metrics.failedRequests).toBe(0)
      expect(metrics.averageResponseTime).toBeGreaterThan(0)
    })

    it('should track failed requests in metrics', async () => {
      mockFetch.mockRejectedValue(new Error('Network error'))

      try {
        await bitcoinService.getBlockInfo(800000)
      } catch {
        // Expected to fail
      }

      const metrics = bitcoinService.getMetrics()
      expect(metrics.totalRequests).toBe(4) // Initial attempt + 3 retries
      expect(metrics.successfulRequests).toBe(0)
      expect(metrics.failedRequests).toBe(4)
    })
  })
})
