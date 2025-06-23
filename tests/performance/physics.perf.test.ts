/**
 * Physics system performance benchmarks
 * Tests physics calculations, collision detection, and force simulations
 * 
 * @author Protozoa Automation Suite
 * @generated from template
 */

import { describe, test, expect, beforeEach } from 'vitest'
import { Bench } from 'tinybench'
import { PhysicsService } from '@/domains/physics/services/PhysicsService'
import { ParticleService } from '@/domains/particle/services/ParticleService'
import { RNGService } from '@/domains/rng/services/RNGService'

describe('Physics System Performance', () => {
  let physicsService: PhysicsService
  let particleService: ParticleService
  let rngService: RNGService

  beforeEach(() => {
    rngService = RNGService.getInstance()
    physicsService = PhysicsService.getInstance()
    particleService = ParticleService.getInstance()
  })

  test('Physics Update Performance', async () => {
    // Create test particles
    const particles = []
    for (let i = 0; i < 1000; i++) {
      particles.push(particleService.createParticle({
        position: { x: Math.random() * 100, y: Math.random() * 100, z: Math.random() * 100 },
        velocity: { x: Math.random() * 10, y: Math.random() * 10, z: Math.random() * 10 },
        mass: 1 + Math.random() * 5,
        type: 'basic'
      }))
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('physics update 100 particles', () => {
        physicsService.updateParticles(particles.slice(0, 100), 0.016)
      })
      .add('physics update 500 particles', () => {
        physicsService.updateParticles(particles.slice(0, 500), 0.016)
      })
      .add('physics update 1000 particles', () => {
        physicsService.updateParticles(particles, 0.016)
      })

    await bench.run()

    console.table(bench.table())

    // Performance assertions for 60fps target
    const update100 = bench.tasks.find(t => t.name === 'physics update 100 particles')
    const update500 = bench.tasks.find(t => t.name === 'physics update 500 particles')
    const update1000 = bench.tasks.find(t => t.name === 'physics update 1000 particles')

    expect(update100?.result?.mean).toBeLessThan(3)
    expect(update500?.result?.mean).toBeLessThan(10)
    expect(update1000?.result?.mean).toBeLessThan(16)
  })

  test('Collision Detection Performance', async () => {
    const particles = []
    for (let i = 0; i < 500; i++) {
      particles.push(particleService.createParticle({
        position: { x: Math.random() * 50, y: Math.random() * 50, z: Math.random() * 50 },
        velocity: { x: Math.random() * 5, y: Math.random() * 5, z: Math.random() * 5 },
        radius: 0.5 + Math.random() * 1.5,
        type: 'basic'
      }))
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('broad phase collision 100 particles', () => {
        physicsService.broadPhaseCollision(particles.slice(0, 100))
      })
      .add('broad phase collision 250 particles', () => {
        physicsService.broadPhaseCollision(particles.slice(0, 250))
      })
      .add('broad phase collision 500 particles', () => {
        physicsService.broadPhaseCollision(particles)
      })
      .add('narrow phase collision pairs', () => {
        const pairs = physicsService.broadPhaseCollision(particles.slice(0, 100))
        physicsService.narrowPhaseCollision(pairs)
      })

    await bench.run()

    console.table(bench.table())

    // Collision detection should be efficient
    const broad100 = bench.tasks.find(t => t.name === 'broad phase collision 100 particles')
    const broad500 = bench.tasks.find(t => t.name === 'broad phase collision 500 particles')

    expect(broad100?.result?.mean).toBeLessThan(5)
    expect(broad500?.result?.mean).toBeLessThan(15)
  })

  test('Force Calculation Performance', async () => {
    const particles = []
    for (let i = 0; i < 200; i++) {
      particles.push(particleService.createParticle({
        position: { x: Math.random() * 20, y: Math.random() * 20, z: Math.random() * 20 },
        velocity: { x: 0, y: 0, z: 0 },
        mass: 1 + Math.random() * 3,
        charge: Math.random() * 2 - 1,
        type: 'charged'
      }))
    }

    const bench = new Bench({ time: 1000 })

    bench
      .add('gravitational forces 50 particles', () => {
        physicsService.calculateGravitationalForces(particles.slice(0, 50))
      })
      .add('gravitational forces 100 particles', () => {
        physicsService.calculateGravitationalForces(particles.slice(0, 100))
      })
      .add('electromagnetic forces 50 particles', () => {
        physicsService.calculateElectromagneticForces(particles.slice(0, 50))
      })
      .add('combined forces 100 particles', () => {
        const subset = particles.slice(0, 100)
        physicsService.calculateGravitationalForces(subset)
        physicsService.calculateElectromagneticForces(subset)
      })

    await bench.run()

    console.table(bench.table())

    // Force calculations should be manageable
    const gravity50 = bench.tasks.find(t => t.name === 'gravitational forces 50 particles')
    const gravity100 = bench.tasks.find(t => t.name === 'gravitational forces 100 particles')

    expect(gravity50?.result?.mean).toBeLessThan(8)
    expect(gravity100?.result?.mean).toBeLessThan(20)
  })

  test('Spatial Partitioning Performance', async () => {
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
      .add('octree insertion 1000 particles', () => {
        const octree = physicsService.createOctree({ x: 0, y: 0, z: 0 }, 100)
        for (const particle of particles) {
          physicsService.insertIntoOctree(octree, particle)
        }
      })
      .add('octree query 100 points', () => {
        const octree = physicsService.createOctree({ x: 0, y: 0, z: 0 }, 100)
        for (const particle of particles) {
          physicsService.insertIntoOctree(octree, particle)
        }
        
        for (let i = 0; i < 100; i++) {
          physicsService.queryOctree(octree, {
            x: Math.random() * 100,
            y: Math.random() * 100,
            z: Math.random() * 100
          }, 5)
        }
      })

    await bench.run()

    console.table(bench.table())

    // Spatial partitioning should be efficient
    const insertion = bench.tasks.find(t => t.name === 'octree insertion 1000 particles')
    const query = bench.tasks.find(t => t.name === 'octree query 100 points')

    expect(insertion?.result?.mean).toBeLessThan(20)
    expect(query?.result?.mean).toBeLessThan(10)
  })
}) 
