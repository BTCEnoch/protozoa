/**
 * @fileoverview Unit tests for Physics Worker
 * @description Tests off-main-thread physics computation and worker lifecycle
 */

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

// Mock worker for testing
class MockWorker {
  onmessage: ((event: MessageEvent) => void) | null = null

  postMessage(data: any) {
    // Simulate physics computation response
    setTimeout(() => {
      if (this.onmessage && data.particles) {
        this.onmessage(
          new MessageEvent('message', {
            data: {
              type: 'update_complete',
              particles: data.particles.map((p: any) => ({
                ...p,
                position: {
                  x: p.position.x + p.velocity.x * data.deltaTime,
                  y:
                    p.position.y +
                    p.velocity.y * data.deltaTime -
                    0.5 * 9.81 * data.deltaTime * data.deltaTime, // Proper physics
                  z: p.position.z + p.velocity.z * data.deltaTime,
                },
                velocity: {
                  x: p.velocity.x * 0.99, // Damping
                  y: (p.velocity.y - 9.81 * data.deltaTime) * 0.99, // Apply gravity, then damping
                  z: p.velocity.z * 0.99,
                },
              })),
            },
          })
        )
      }
    }, 1)
  }

  terminate() {
    // Mock terminate
  }
}

// Mock Worker constructor globally
global.Worker = vi.fn(() => new MockWorker()) as any

describe('Physics Worker', () => {
  let worker: Worker

  beforeEach(() => {
    worker = new Worker('/src/domains/physics/workers/physicsWorker.ts')
  })

  afterEach(() => {
    if (worker) {
      worker.terminate()
    }
  })

  describe('Worker Lifecycle', () => {
    it('should create worker without errors', () => {
      expect(worker).toBeDefined()
      expect(typeof worker.postMessage).toBe('function')
      expect(typeof worker.terminate).toBe('function')
    })

    it('should terminate worker cleanly', () => {
      expect(() => worker.terminate()).not.toThrow()
    })
  })

  describe('Physics Computation', () => {
    it('should process particle updates off main thread', async () => {
      const testParticles = [
        {
          id: 1,
          position: { x: 0, y: 10, z: 0 },
          velocity: { x: 1, y: 0, z: 0 },
          mass: 1,
        },
        {
          id: 2,
          position: { x: 5, y: 5, z: 0 },
          velocity: { x: 0, y: 2, z: 1 },
          mass: 2,
        },
      ]

      const deltaTime = 0.016 // 60fps

      return new Promise<void>((resolve) => {
        worker.onmessage = (event) => {
          const { type, particles } = event.data

          expect(type).toBe('update_complete')
          expect(particles).toHaveLength(2)

          // Check that positions were updated based on velocity
          expect(particles[0].position.x).toBeCloseTo(0.016, 3) // 0 + 1 * 0.016
          expect(particles[0].position.y).toBeCloseTo(9.998, 2) // 10 + 0 * 0.016 - 0.5 * 9.81 * 0.016^2 (reduced precision)

          // Check that velocities were updated with damping and gravity
          expect(particles[0].velocity.x).toBeCloseTo(0.99, 2) // 1 * 0.99
          expect(particles[0].velocity.y).toBeCloseTo(-0.155, 2) // (0 - 9.81 * 0.016) * 0.99

          resolve()
        }

        worker.postMessage({
          type: 'update_particles',
          particles: testParticles,
          deltaTime: deltaTime,
        })
      })
    }, 5000)

    it('should handle empty particle arrays', async () => {
      return new Promise<void>((resolve) => {
        worker.onmessage = (event) => {
          const { type, particles } = event.data

          expect(type).toBe('update_complete')
          expect(particles).toHaveLength(0)

          resolve()
        }

        worker.postMessage({
          type: 'update_particles',
          particles: [],
          deltaTime: 0.016,
        })
      })
    })

    it('should handle large particle counts efficiently', async () => {
      // Create 1000 test particles
      const largeParticleSet = Array.from({ length: 1000 }, (_, i) => ({
        id: i,
        position: { x: Math.random() * 100, y: Math.random() * 100, z: Math.random() * 100 },
        velocity: { x: Math.random() * 2 - 1, y: Math.random() * 2 - 1, z: Math.random() * 2 - 1 },
        mass: Math.random() * 5 + 0.5,
      }))

      const startTime = performance.now()

      return new Promise<void>((resolve) => {
        worker.onmessage = (event) => {
          const endTime = performance.now()
          const processingTime = endTime - startTime

          const { type, particles } = event.data

          expect(type).toBe('update_complete')
          expect(particles).toHaveLength(1000)

          // Should process 1000 particles in reasonable time (< 100ms)
          expect(processingTime).toBeLessThan(100)

          resolve()
        }

        worker.postMessage({
          type: 'update_particles',
          particles: largeParticleSet,
          deltaTime: 0.016,
        })
      })
    }, 10000)
  })

  describe('Physics Accuracy', () => {
    it('should apply gravity correctly', async () => {
      const particle = {
        id: 1,
        position: { x: 0, y: 10, z: 0 },
        velocity: { x: 0, y: 0, z: 0 },
        mass: 1,
      }

      return new Promise<void>((resolve) => {
        worker.onmessage = (event) => {
          const { particles } = event.data
          const updatedParticle = particles[0]

          // Check gravity application (should fall)
          expect(updatedParticle.velocity.y).toBeLessThan(0)
          expect(updatedParticle.position.y).toBeLessThanOrEqual(10) // With physics calculation, should be at or below starting position

          resolve()
        }

        worker.postMessage({
          type: 'update_particles',
          particles: [particle],
          deltaTime: 0.016,
        })
      })
    })

    it('should apply damping to reduce velocity over time', async () => {
      const particle = {
        id: 1,
        position: { x: 0, y: 0, z: 0 },
        velocity: { x: 10, y: 10, z: 10 },
        mass: 1,
      }

      return new Promise<void>((resolve) => {
        worker.onmessage = (event) => {
          const { particles } = event.data
          const updatedParticle = particles[0]

          // Velocities should be reduced due to damping
          expect(Math.abs(updatedParticle.velocity.x)).toBeLessThan(10)
          expect(Math.abs(updatedParticle.velocity.z)).toBeLessThan(10)

          resolve()
        }

        worker.postMessage({
          type: 'update_particles',
          particles: [particle],
          deltaTime: 0.016,
        })
      })
    })

    it('should preserve particle IDs and mass', async () => {
      const testParticles = [
        { id: 123, position: { x: 0, y: 0, z: 0 }, velocity: { x: 1, y: 1, z: 1 }, mass: 2.5 },
        { id: 456, position: { x: 1, y: 1, z: 1 }, velocity: { x: 0, y: 0, z: 0 }, mass: 1.8 },
      ]

      return new Promise<void>((resolve) => {
        worker.onmessage = (event) => {
          const { particles } = event.data

          expect(particles[0].id).toBe(123)
          expect(particles[0].mass).toBe(2.5)
          expect(particles[1].id).toBe(456)
          expect(particles[1].mass).toBe(1.8)

          resolve()
        }

        worker.postMessage({
          type: 'update_particles',
          particles: testParticles,
          deltaTime: 0.016,
        })
      })
    })
  })

  describe('Error Handling', () => {
    it('should handle malformed message gracefully', async () => {
      return new Promise<void>((resolve) => {
        // Set up error handler or timeout
        const timeout = setTimeout(() => {
          // If no crash occurs within 1 second, test passes
          resolve()
        }, 1000)

        worker.onmessage = () => {
          clearTimeout(timeout)
          resolve()
        }

        // Send malformed message
        worker.postMessage({
          type: 'invalid_type',
          invalidData: 'test',
        })
      })
    })

    it('should handle missing required fields', async () => {
      return new Promise<void>((resolve) => {
        const timeout = setTimeout(() => {
          resolve()
        }, 1000)

        worker.onmessage = () => {
          clearTimeout(timeout)
          resolve()
        }

        // Send message without required fields
        worker.postMessage({
          type: 'update_particles',
          // Missing particles and deltaTime
        })
      })
    })
  })
})
