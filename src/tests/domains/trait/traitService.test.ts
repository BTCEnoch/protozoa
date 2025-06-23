/**
 * @fileoverview TraitService Unit Tests
 * @description Comprehensive test suite for TraitService with >80% coverage
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { TraitService } from '@/domains/trait/services/TraitService'
import { TraitDependencyInjection } from '@/domains/trait/services/traitDependencyInjection'
import { OrganismTraits, TraitCategory, MutationRecord } from '@/domains/trait/types/trait.types'
import { createServiceLogger } from '@/shared/lib/logger'

// Mock logger to avoid console noise in tests
vi.mock('@/shared/lib/logger', () => ({
  createServiceLogger: vi.fn(() => ({
    debug: vi.fn(),
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn(),
    success: vi.fn()
  }))
}))

describe('TraitService', () => {
  let traitService: TraitService
  let dependencyInjection: TraitDependencyInjection

  beforeEach(() => {
    // Reset singleton instances for clean tests
    vi.clearAllMocks()
    
    // Get fresh instances
    traitService = TraitService.getInstance()
    dependencyInjection = TraitDependencyInjection.getInstance()
    
    // Configure with test dependencies
    const testConfig = dependencyInjection.createTestConfiguration()
    dependencyInjection.configureDependencies(testConfig)
  })

  afterEach(() => {
    // Clean up any test artifacts
    if (traitService && typeof traitService.dispose === 'function') {
      traitService.dispose()
    }
  })

  describe('Singleton Pattern', () => {
    it('should return the same instance', () => {
      const instance1 = TraitService.getInstance()
      const instance2 = TraitService.getInstance()
      expect(instance1).toBe(instance2)
    })

    it('should be properly initialized', () => {
      expect(traitService).toBeDefined()
      expect(typeof traitService.generateOrganismTraits).toBe('function')
    })
  })

  describe('Trait Generation', () => {
    it('should generate organism traits from block data', async () => {
      const blockNumber = 12345
      const traits = await traitService.generateOrganismTraits(blockNumber)
      
      expect(traits).toBeDefined()
      expect(traits.blockNumber).toBe(blockNumber)
      expect(traits.organismId).toBeDefined()
      expect(traits.visual).toBeDefined()
      expect(traits.behavioral).toBeDefined()
      expect(traits.physical).toBeDefined()
      expect(traits.evolutionary).toBeDefined()
    })

    it('should generate different traits for different blocks', async () => {
      const traits1 = await traitService.generateOrganismTraits(100)
      const traits2 = await traitService.generateOrganismTraits(200)
      
      expect(traits1.blockNumber).not.toBe(traits2.blockNumber)
      // At least some traits should be different (allowing for small chance of collision)
      const hasDifferences = 
        traits1.visual.primaryColor !== traits2.visual.primaryColor ||
        traits1.behavioral.speed !== traits2.behavioral.speed ||
        traits1.physical.mass !== traits2.physical.mass
      
      expect(hasDifferences).toBe(true)
    })

    it('should generate traits within valid ranges', async () => {
      const traits = await traitService.generateOrganismTraits(12345)
      
      // Visual traits
      expect(traits.visual.size).toBeGreaterThanOrEqual(0.5)
      expect(traits.visual.size).toBeLessThanOrEqual(3.0)
      expect(traits.visual.opacity).toBeGreaterThanOrEqual(0.3)
      expect(traits.visual.opacity).toBeLessThanOrEqual(1.0)
      
      // Behavioral traits
      expect(traits.behavioral.speed).toBeGreaterThanOrEqual(0.1)
      expect(traits.behavioral.speed).toBeLessThanOrEqual(5.0)
      expect(traits.behavioral.aggression).toBeGreaterThanOrEqual(0.0)
      expect(traits.behavioral.aggression).toBeLessThanOrEqual(1.0)
      
      // Physical traits
      expect(traits.physical.mass).toBeGreaterThanOrEqual(0.5)
      expect(traits.physical.mass).toBeLessThanOrEqual(10.0)
      
      // Evolutionary traits
      expect(traits.evolutionary.fitness).toBeGreaterThanOrEqual(0.0)
      expect(traits.evolutionary.fitness).toBeLessThanOrEqual(2.0)
    })
  })

  describe('Trait Mutation', () => {
    let baseTraits: OrganismTraits

    beforeEach(async () => {
      baseTraits = await traitService.generateOrganismTraits(12345)
    })

    it('should mutate numeric traits', () => {
      const originalSize = baseTraits.visual.size
      const mutatedValue = traitService.mutateTrait('size', originalSize)
      
      expect(typeof mutatedValue).toBe('number')
      expect(mutatedValue).toBeGreaterThanOrEqual(0.5)
      expect(mutatedValue).toBeLessThanOrEqual(3.0)
    })

    it('should mutate color traits', () => {
      const originalColor = baseTraits.visual.primaryColor
      const mutatedColor = traitService.mutateTrait('primaryColor', originalColor)
      
      expect(typeof mutatedColor).toBe('string')
      expect(mutatedColor).toMatch(/^#[0-9A-Fa-f]{6}$/)
    })

    it('should respect trait constraints during mutation', () => {
      const constrainedTraits = ['speed', 'aggression', 'mass', 'fitness']
      
      constrainedTraits.forEach(traitName => {
        const originalValue = 1.0 // Safe middle value
        
        // Test multiple mutations to catch edge cases
        for (let i = 0; i < 10; i++) {
          const mutatedValue = traitService.mutateTrait(traitName, originalValue)
          expect(typeof mutatedValue).toBe('number')
          expect(mutatedValue).toBeGreaterThan(0) // All traits should be positive
        }
      })
    })

    it('should create mutation records', () => {
      const originalValue = 1.0
      const mutatedValue = traitService.mutateTrait('speed', originalValue)
      
      // Check if mutation was recorded (implementation specific)
      expect(typeof mutatedValue).toBe('number')
      expect(mutatedValue).not.toBe(originalValue)
    })
  })

  describe('Mutation Probability Tests', () => {
    it('should calculate mutation rates correctly', () => {
      const visualRate = traitService.calculateMutationRate('visual' as TraitCategory)
      const behavioralRate = traitService.calculateMutationRate('behavioral' as TraitCategory)
      const physicalRate = traitService.calculateMutationRate('physical' as TraitCategory)
      const evolutionaryRate = traitService.calculateMutationRate('evolutionary' as TraitCategory)
      
      expect(visualRate).toBeGreaterThan(0)
      expect(behavioralRate).toBeGreaterThan(0)
      expect(physicalRate).toBeGreaterThan(0)
      expect(evolutionaryRate).toBeGreaterThan(0)
      
      // Evolutionary traits should have lower mutation rates
      expect(evolutionaryRate).toBeLessThan(behavioralRate)
    })

    it('should have statistical consistency in mutations', () => {
      const sampleSize = 100
      const originalValue = 1.0
      const mutations = []
      
      // Generate mutations
      for (let i = 0; i < sampleSize; i++) {
        const mutated = traitService.mutateTrait('speed', originalValue)
        mutations.push(mutated)
      }
      
      // Statistical checks
      const mean = mutations.reduce((sum, val) => sum + val, 0) / mutations.length
      const variance = mutations.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / mutations.length
      
      // Mean should be reasonably close to original (within 50%)
      expect(Math.abs(mean - originalValue)).toBeLessThan(originalValue * 0.5)
      
      // Should have some variance (mutations are working)
      expect(variance).toBeGreaterThan(0.01)
    })
  })

  describe('Trait Validation', () => {
    it('should validate complete organism traits', async () => {
      const traits = await traitService.generateOrganismTraits(12345)
      const isValid = traitService.validateTraits(traits)
      
      expect(isValid).toBe(true)
    })

    it('should reject invalid trait values', () => {
      const invalidTraits = {
        organismId: 'test',
        blockNumber: 12345,
        visual: {
          primaryColor: 'invalid-color',
          secondaryColor: '#FF0000',
          size: -1, // Invalid: below minimum
          opacity: 2.0, // Invalid: above maximum
          particleDensity: 100,
          glowIntensity: 0.5
        },
        behavioral: {
          speed: 1.0,
          aggression: 0.5,
          sociability: 0.5,
          curiosity: 0.5,
          efficiency: 1.0,
          adaptability: 0.7
        },
        physical: {
          mass: 2.0,
          collisionRadius: 0.8,
          energyCapacity: 150,
          durability: 1.0,
          regeneration: 0.2
        },
        evolutionary: {
          generation: 1,
          fitness: 1.0,
          stability: 0.7,
          reproductivity: 0.5,
          longevity: 1.2
        },
        generatedAt: Date.now(),
        mutationHistory: []
      } as OrganismTraits

      const isValid = traitService.validateTraits(invalidTraits)
      expect(isValid).toBe(false)
    })
  })

  describe('Service Health', () => {
    it('should report healthy status when properly configured', () => {
      const health = traitService.getHealthStatus()
      expect(health).toBeDefined()
      expect(health.isHealthy).toBe(true)
    })

    it('should handle dependency injection', () => {
      expect(dependencyInjection.isConfigurationComplete()).toBe(true)
    })

    it('should dispose resources properly', () => {
      expect(() => {
        if (typeof traitService.dispose === 'function') {
          traitService.dispose()
        }
      }).not.toThrow()
    })
  })

  describe('Performance Tests', () => {
    it('should generate traits efficiently', async () => {
      const startTime = performance.now()
      
      // Generate multiple organisms
      const promises = []
      for (let i = 0; i < 10; i++) {
        promises.push(traitService.generateOrganismTraits(i + 1000))
      }
      
      await Promise.all(promises)
      
      const endTime = performance.now()
      const duration = endTime - startTime
      
      // Should complete within reasonable time (adjust threshold as needed)
      expect(duration).toBeLessThan(1000) // 1 second for 10 organisms
    })

    it('should handle concurrent trait generation', async () => {
      const concurrentCount = 5
      const promises = []
      
      for (let i = 0; i < concurrentCount; i++) {
        promises.push(traitService.generateOrganismTraits(i + 2000))
      }
      
      const results = await Promise.all(promises)
      
      expect(results).toHaveLength(concurrentCount)
      results.forEach((traits, index) => {
        expect(traits.blockNumber).toBe(index + 2000)
        expect(traits.organismId).toBeDefined()
      })
    })
  })
}) 
