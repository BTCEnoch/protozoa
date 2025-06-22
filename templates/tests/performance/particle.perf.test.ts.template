/**
 * Particle system performance benchmarks
 * Tests particle allocation, updates, and memory management
 * 
 * @author Protozoa Automation Suite
 * @generated from template
 */

import { describe, test, expect, beforeEach } from 'vitest'
import { Bench } from 'tinybench'
import { ParticleService } from '@/domains/particle/services/ParticleService'
import { PhysicsService } from '@/domains/physics/services/PhysicsService'
import { RNGService } from '@/domains/rng/services/RNGService'

describe('Particle System Performance', () => {
  let particleService: ParticleService
  let physicsService: PhysicsService
  let rngService: RNGService

  beforeEach(() => {
    rngService = RNGService.getInstance()
    physicsService = PhysicsService.getInstance()
    particleService = ParticleService.getInstance()
  })

  test('Particle Allocation Benchmarks', async () => {
    const bench = new Bench({ time: 1000 })

    bench
      .add('allocate 100 particles', () => {
        for (let i = 0; i < 100; i++) {
          particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })
      .add('allocate 500 particles', () => {
        for (let i = 0; i < 500; i++) {
          particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })
      .add('allocate 1000 particles', () => {
        for (let i = 0; i < 1000; i++) {
          particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })

    await bench.run()

    console.table(bench.table())

    // Performance assertions
    const allocate100 = bench.tasks.find(t => t.name === 'allocate 100 particles')
    const allocate500 = bench.tasks.find(t => t.name === 'allocate 500 particles')
    const allocate1000 = bench.tasks.find(t => t.name === 'allocate 1000 particles')

    // Should be able to allocate 100 particles in under 10ms
    expect(allocate100?.result?.mean).toBeLessThan(10)
    
    // 500 particles should scale reasonably (under 50ms)
    expect(allocate500?.result?.mean).toBeLessThan(50)
    
    // 1000 particles should still be performant (under 100ms)
    expect(allocate1000?.result?.mean).toBeLessThan(100)
  })

  test('Particle Update Performance', async () => {
    // Pre-allocate particles for testing
    const particles = []
    for (let i = 0; i < 1000; i++) {
      particles.push(particleService.createParticle({
        position: { x: Math.random() * 100, y: Math.random() * 100, z: Math.random() * 100 },
        velocity: { x: Math.random() * 10, y: Math.random() * 10, z: Math.random() * 10 },
        type: 'basic'
      }))
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('update 100 particles', () => {
        for (let i = 0; i < 100; i++) {
          particleService.updateParticle(particles[i], 0.016) // 60fps delta
        }
      })
      .add('update 500 particles', () => {
        for (let i = 0; i < 500; i++) {
          particleService.updateParticle(particles[i], 0.016)
        }
      })
      .add('update 1000 particles', () => {
        for (let i = 0; i < 1000; i++) {
          particleService.updateParticle(particles[i], 0.016)
        }
      })

    await bench.run()

    console.table(bench.table())

    // Performance assertions for 60fps target (16.67ms frame budget)
    const update100 = bench.tasks.find(t => t.name === 'update 100 particles')
    const update500 = bench.tasks.find(t => t.name === 'update 500 particles')
    const update1000 = bench.tasks.find(t => t.name === 'update 1000 particles')

    // Should update 100 particles well within frame budget
    expect(update100?.result?.mean).toBeLessThan(2)
    
    // 500 particles should still be fast
    expect(update500?.result?.mean).toBeLessThan(8)
    
    // 1000 particles should be manageable
    expect(update1000?.result?.mean).toBeLessThan(16)
  })

  test('Memory Pool Performance', async () => {
    const bench = new Bench({ time: 1000 })

    bench
      .add('allocate and release 1000 particles', () => {
        const allocated = []
        
        // Allocate
        for (let i = 0; i < 1000; i++) {
          allocated.push(particleService.createParticle({
            position: { x: 0, y: 0, z: 0 },
            velocity: { x: 0, y: 0, z: 0 },
            type: 'basic'
          }))
        }
        
        // Release
        for (const particle of allocated) {
          particleService.releaseParticle(particle)
        }
      })
      .add('pool reuse test', () => {
        const particles = []
        
        // Allocate from pool
        for (let i = 0; i < 100; i++) {
          particles.push(particleService.createParticle({
            position: { x: i, y: i, z: i },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          }))
        }
        
        // Return to pool
        for (const particle of particles) {
          particleService.releaseParticle(particle)
        }
        
        // Reallocate (should reuse pooled objects)
        const reused = []
        for (let i = 0; i < 100; i++) {
          reused.push(particleService.createParticle({
            position: { x: i * 2, y: i * 2, z: i * 2 },
            velocity: { x: 2, y: 2, z: 2 },
            type: 'basic'
          }))
        }
        
        // Clean up
        for (const particle of reused) {
          particleService.releaseParticle(particle)
        }
      })

    await bench.run()

    console.table(bench.table())

    // Memory pool should be efficient
    const poolTest = bench.tasks.find(t => t.name === 'allocate and release 1000 particles')
    const reuseTest = bench.tasks.find(t => t.name === 'pool reuse test')

    expect(poolTest?.result?.mean).toBeLessThan(50)
    expect(reuseTest?.result?.mean).toBeLessThan(10)
  })

  test('Batch Operations Performance', async () => {
    const bench = new Bench({ time: 1000 })

    bench
      .add('batch create 1000 particles', () => {
        const configs = Array.from({ length: 1000 }, (_, i) => ({
          position: { x: i, y: i, z: i },
          velocity: { x: 1, y: 1, z: 1 },
          type: 'basic' as const
        }))
        
        particleService.createParticlesBatch(configs)
      })
      .add('individual create 1000 particles', () => {
        for (let i = 0; i < 1000; i++) {
          particleService.createParticle({
            position: { x: i, y: i, z: i },
            velocity: { x: 1, y: 1, z: 1 },
            type: 'basic'
          })
        }
      })

    await bench.run()

    console.table(bench.table())

    // Batch operations should be faster
    const batchCreate = bench.tasks.find(t => t.name === 'batch create 1000 particles')
    const individualCreate = bench.tasks.find(t => t.name === 'individual create 1000 particles')

    if (batchCreate && individualCreate) {
      expect(batchCreate.result?.mean).toBeLessThan(individualCreate.result?.mean)
    }
  })
})