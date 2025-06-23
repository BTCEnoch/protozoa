/**
 * @fileoverview Integration tests for service interactions
 * @description Tests how services work together in real scenarios
 * @version 1.0.0
 * @author Protozoa Development Team
 *
 * PHASE 3 TASK 3.2: Integration Test Example
 * Tests multi-service workflows and data flow between services
 */

import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { RNGService } from '@/domains/rng/services/RNGService'
import { ParticleService } from '@/domains/particle/services/ParticleService'
import { BitcoinService } from '@/domains/bitcoin/services/BitcoinService'
import type { ParticleCreationData } from '@/domains/particle/types/particle.types'

describe('Service Integration Tests', () => {
  let rngService: RNGService
  let particleService: ParticleService
  let bitcoinService: BitcoinService

  beforeEach(() => {
    // Get singleton instances
    rngService = RNGService.getInstance()
    particleService = ParticleService.getInstance()
    bitcoinService = BitcoinService.getInstance()
  })

  afterEach(() => {
    // Proper cleanup for integration tests
    rngService.dispose()
    particleService.dispose()
    bitcoinService.dispose()
  })

  describe('Bitcoin-Seeded Particle Generation', () => {
    it('should use Bitcoin block data to seed deterministic particle creation', async () => {
      // Step 1: Seed RNG from Bitcoin block
      const testBlockNumber = 750000 // Safe block number
      await rngService.seedFromBlock(testBlockNumber)

      // Step 2: Create particle system
      const systemConfig = {
        id: 'bitcoin-seeded-system',
        name: 'Bitcoin Seeded Particles',
        maxParticles: 100,
        position: { x: 0, y: 0, z: 0 },
        bounds: {
          min: { x: -10, y: -10, z: -10 },
          max: { x: 10, y: 10, z: 10 },
        },
      }

      const particleSystem = particleService.createSystem(systemConfig)
      expect(particleSystem.id).toBe('bitcoin-seeded-system')

      // Step 3: Generate particles using seeded RNG
      const particleData: ParticleCreationData = {
        position: {
          x: rngService.randomFloat(-5, 5),
          y: rngService.randomFloat(-5, 5),
          z: rngService.randomFloat(-5, 5),
        },
        velocity: {
          x: rngService.randomFloat(-1, 1),
          y: rngService.randomFloat(-1, 1),
          z: rngService.randomFloat(-1, 1),
        },
        type: 'BASIC' as any,
        userData: {},
      }

      const particle = particleService.createParticle(particleData)
      expect(particle).toBeDefined()
      expect(particle?.id).toBeDefined()

      // Step 4: Verify deterministic behavior
      // Reset RNG to same block and verify same particle positions
      await rngService.seedFromBlock(testBlockNumber)

      const secondParticleData: ParticleCreationData = {
        position: {
          x: rngService.randomFloat(-5, 5),
          y: rngService.randomFloat(-5, 5),
          z: rngService.randomFloat(-5, 5),
        },
        velocity: {
          x: rngService.randomFloat(-1, 1),
          y: rngService.randomFloat(-1, 1),
          z: rngService.randomFloat(-1, 1),
        },
        type: 'BASIC' as any,
        userData: {},
      }

      // Should generate same positions due to deterministic seeding
      expect(particleData.position.x).toBeCloseTo(secondParticleData.position.x, 10)
      expect(particleData.position.y).toBeCloseTo(secondParticleData.position.y, 10)
      expect(particleData.position.z).toBeCloseTo(secondParticleData.position.z, 10)
    })

    it('should handle service initialization dependencies', async () => {
      // Test that services can be initialized in any order
      const config = {
        maxParticles: 50,
        useInstancing: true,
        useObjectPooling: true,
      }

      await particleService.initialize(config)

      const bitcoinConfig = {
        enableCaching: true,
        cacheSize: 10,
        cacheTTL: 30000,
      }

      await bitcoinService.initialize(bitcoinConfig)

      const rngConfig = {
        defaultSeed: 12345,
        useBitcoinSeeding: true,
      }

      await rngService.initialize(rngConfig)

      // All services should be initialized and functional
      expect(particleService.getAllSystems()).toEqual([])
      expect(bitcoinService.getMetrics().totalRequests).toBe(0)
      expect(rngService.getMetrics().totalGenerated).toBe(0)
    })
  })

  describe('Cross-Service Data Flow', () => {
    it('should maintain data consistency across service boundaries', async () => {
      // Create a particle system
      const system = particleService.createSystem({
        id: 'data-flow-test',
        name: 'Data Flow Test',
        maxParticles: 10,
        position: { x: 0, y: 0, z: 0 },
        bounds: {
          min: { x: -1, y: -1, z: -1 },
          max: { x: 1, y: 1, z: 1 },
        },
      })

      // Seed RNG deterministically
      rngService.seed(54321)

      // Create multiple particles with RNG-generated data
      const particles = []
      for (let i = 0; i < 5; i++) {
        const particleData: ParticleCreationData = {
          position: {
            x: rngService.randomFloat(-1, 1),
            y: rngService.randomFloat(-1, 1),
            z: rngService.randomFloat(-1, 1),
          },
          velocity: {
            x: rngService.randomFloat(-0.5, 0.5),
            y: rngService.randomFloat(-0.5, 0.5),
            z: rngService.randomFloat(-0.5, 0.5),
          },
          type: 'BASIC' as any,
          userData: { index: i },
        }

        const particle = particleService.createParticle(particleData)
        if (particle) {
          particles.push(particle)
        }
      }

      expect(particles).toHaveLength(5)

      // Verify RNG state is consistent
      const rngState = rngService.getState()
      expect(rngState.counter).toBe(10) // 5 particles × 2 randoms each (position + velocity)

      // Verify particle service state
      const particleMetrics = particleService.getMetrics()
      expect(particleMetrics.totalSystems).toBe(1)
    })
  })

  describe('Error Handling Across Services', () => {
    it('should gracefully handle failures in service interactions', async () => {
      // Test that failure in one service doesn't crash others

      // Attempt to seed from invalid block (should handle gracefully)
      try {
        await rngService.seedFromBlock(-1) // Invalid block number
      } catch (error) {
        // Expected to throw, but other services should remain functional
      }

      // Other services should still work
      const particle = particleService.createParticle({
        position: { x: 0, y: 0, z: 0 },
        type: 'BASIC' as any,
        userData: {},
      })

      expect(particle).toBeDefined()

      // RNG should still work with fallback
      const randomValue = rngService.random()
      expect(randomValue).toBeGreaterThanOrEqual(0)
      expect(randomValue).toBeLessThan(1)
    })
  })
})
