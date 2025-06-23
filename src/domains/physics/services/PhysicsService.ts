/**
 * @fileoverview Physics Service Implementation (Template)
 * @module @/domains/physics/services/PhysicsService
 * @version 1.0.0
 */

import type {
  IPhysicsService,
  ParticlePhysics,
  PhysicsConfig,
  PhysicsMetrics,
  Transform,
} from '@/domains/physics/interfaces/IPhysicsService'
import type { DistributionPattern, PhysicsState } from '@/domains/physics/types/physics.types'
import { createServiceLogger } from '@/shared/lib/logger'
import { Matrix4, Quaternion, Vector3 } from 'three'

/**
 * PhysicsService â€“ provides lightweight kinematic helpers and geometry utilities.
 * Note: Complex force-field simulation is delegated to the Formation/Animation domains.
 */
export class PhysicsService implements IPhysicsService {
  /* ------------------------------- singleton ------------------------------- */
  static #instance: PhysicsService | null = null
  public static getInstance(): PhysicsService {
    if (!PhysicsService.#instance) PhysicsService.#instance = new PhysicsService()
    return PhysicsService.#instance
  }
  private constructor() {
    this.#logger.info('PhysicsService instantiated (kinematic-only mode)')
  }

  /* ------------------------------ private data ----------------------------- */
  #logger = createServiceLogger('PHYSICS_SERVICE')

  #config: PhysicsConfig = {
    targetFPS: 60,
    gravity: -9.81,
    damping: 0.99,
  }

  #state: PhysicsState = {
    isRunning: false,
    simulationTime: 0,
    lastDeltaTime: 0,
    algorithm: 'euler',
    collisionMethod: 'basic',
    activeParticles: 0,
  }

  #metrics: PhysicsMetrics = {
    currentFPS: 0,
    averageFrameTime: 0,
    transformCalculations: 0,
    geometryOperations: 0,
    memoryUsage: 0,
  }

  #frameTimes: number[] = []

  /* --------------------------- public I/F methods -------------------------- */
  async initialize(config?: PhysicsConfig): Promise<void> {
    this.#logger.info('Initializing PhysicsService', { config })
    if (config) this.#config = { ...this.#config, ...config }
    this.#state.isRunning = true
  }

  applyGravity(p: ParticlePhysics, dt: number): void {
    if (!p.useGravity) return
    p.acceleration.y += (this.#config.gravity || -9.81) * dt * 0.001
  }

  distributeParticles(count: number, pattern: string, bounds: Vector3): Vector3[] {
    const start = performance.now()
    let positions: Vector3[]
    switch (pattern as DistributionPattern) {
      case 'grid':
        positions = this.#grid(count, bounds)
        break
      case 'circle':
        positions = this.#circle(count, bounds)
        break
      case 'sphere':
        positions = this.#sphere(count, bounds)
        break
      case 'fibonacci':
        positions = this.#fibonacciSphere(count, bounds.x * 0.5)
        break
      default:
        positions = this.#random(count, bounds)
    }
    this.#metrics.geometryOperations++
    this.#updateFrameMetrics(performance.now() - start)
    return positions
  }

  createTransform(position: Vector3, rotation: any, scale: Vector3): Transform {
    const matrix = new Matrix4().compose(
      position,
      new Quaternion(rotation.x, rotation.y, rotation.z, rotation.w),
      scale
    )
    this.#metrics.transformCalculations++
    return {
      position: position.clone(),
      rotation: { ...rotation },
      scale: scale.clone(),
      matrix: new Float32Array(matrix.elements),
    }
  }

  interpolateTransform(from: Transform, to: Transform, alpha: number): Transform {
    const t = Math.max(0, Math.min(1, alpha))
    const pos = from.position.clone().lerp(to.position, t)
    const scl = from.scale.clone().lerp(to.scale, t)
    const rq1 = new Quaternion(from.rotation.x, from.rotation.y, from.rotation.z, from.rotation.w)
    const rq2 = new Quaternion(to.rotation.x, to.rotation.y, to.rotation.z, to.rotation.w)
    const rot = rq1.slerp(rq2, t)
    return this.createTransform(pos, rot, scl)
  }

  getMetrics(): PhysicsMetrics {
    return { ...this.#metrics }
  }

  reset(): void {
    this.#state.simulationTime = 0
    this.#state.lastDeltaTime = 0
    this.#frameTimes.length = 0
    this.#metrics = { ...this.#metrics, currentFPS: 0, averageFrameTime: 0 }
    this.#logger.info('PhysicsService state reset')
  }

  /**
   * Update multiple particles with physics simulation
   * @param particles - Array of particles to update
   * @param deltaTime - Time delta for physics simulation
   */
  updateParticles(particles: any[], deltaTime: number): void {
    const start = performance.now()

    for (const particle of particles) {
      if (!particle || !particle.active) continue

      // Apply gravity if enabled
      if (particle.useGravity !== false) {
        particle.velocity = particle.velocity || { x: 0, y: 0, z: 0 }
        particle.velocity.y += (this.#config.gravity || -9.81) * deltaTime
      }

      // Apply damping
      if (particle.velocity) {
        const damping = this.#config.damping || 0.99
        particle.velocity.x *= damping
        particle.velocity.y *= damping
        particle.velocity.z *= damping
      }

      // Update position
      if (particle.velocity && particle.position) {
        particle.position.x += particle.velocity.x * deltaTime
        particle.position.y += particle.velocity.y * deltaTime
        particle.position.z += particle.velocity.z * deltaTime
      }
    }

    this.#state.activeParticles = particles.filter((p) => p && p.active).length
    this.#updateFrameMetrics(performance.now() - start)
  }

  /**
   * Broad phase collision detection
   * @param particles - Array of particles to check
   * @returns Array of potential collision pairs
   */
  broadPhaseCollision(particles: any[]): Array<[any, any]> {
    const start = performance.now()
    const pairs: Array<[any, any]> = []

    // Simple O(n²) broad phase - could be optimized with spatial partitioning
    for (let i = 0; i < particles.length; i++) {
      for (let j = i + 1; j < particles.length; j++) {
        const p1 = particles[i]
        const p2 = particles[j]

        if (!p1 || !p2 || !p1.active || !p2.active) continue

        // Simple distance check
        const dx = p1.position.x - p2.position.x
        const dy = p1.position.y - p2.position.y
        const dz = p1.position.z - p2.position.z
        const distance = Math.sqrt(dx * dx + dy * dy + dz * dz)

        const minDistance = (p1.size || 1) + (p2.size || 1)
        if (distance < minDistance) {
          pairs.push([p1, p2])
        }
      }
    }

    this.#updateFrameMetrics(performance.now() - start)
    return pairs
  }

  /**
   * Calculate gravitational forces between particles
   * @param particles - Array of particles
   * @returns Array of force vectors
   */
  calculateGravitationalForces(particles: any[]): Vector3[] {
    const start = performance.now()
    const forces: Vector3[] = []
    const G = 6.6743e-11 // Gravitational constant (scaled for simulation)

    for (let i = 0; i < particles.length; i++) {
      const p1 = particles[i]
      if (!p1 || !p1.active) {
        forces.push(new Vector3(0, 0, 0))
        continue
      }

      const totalForce = new Vector3(0, 0, 0)

      for (let j = 0; j < particles.length; j++) {
        if (i === j) continue

        const p2 = particles[j]
        if (!p2 || !p2.active) continue

        // Calculate distance vector
        const dx = p2.position.x - p1.position.x
        const dy = p2.position.y - p1.position.y
        const dz = p2.position.z - p1.position.z
        const distance = Math.sqrt(dx * dx + dy * dy + dz * dz)

        if (distance < 0.1) continue // Avoid singularity

        // Calculate gravitational force magnitude
        const force = (G * (p1.mass || 1) * (p2.mass || 1)) / (distance * distance)

        // Add force component
        totalForce.x += (dx / distance) * force
        totalForce.y += (dy / distance) * force
        totalForce.z += (dz / distance) * force
      }

      forces.push(totalForce)
    }

    this.#updateFrameMetrics(performance.now() - start)
    return forces
  }

  /**
   * Create an octree for spatial partitioning
   * @param center - Center position of the octree
   * @param size - Size of the octree
   * @returns Octree root node
   */
  createOctree(center: { x: number; y: number; z: number }, size: number): any {
    const start = performance.now()

    const octree = {
      center,
      size,
      particles: [],
      children: null,
      isLeaf: true,
      maxParticles: 10,
      maxDepth: 8,
      depth: 0,
    }

    this.#updateFrameMetrics(performance.now() - start)
    return octree
  }

  /**
   * Insert a particle into an octree
   * @param octree - Octree node
   * @param particle - Particle to insert
   */
  insertIntoOctree(octree: any, particle: any): void {
    if (!octree || !particle) return

    // Simple insertion - just add to the root for performance testing
    octree.particles.push(particle)
  }

  /**
   * Narrow phase collision detection for collision pairs
   * @param pairs - Array of collision pairs from broad phase
   * @returns Array of actual collisions with contact info
   */
  narrowPhaseCollision(pairs: Array<[any, any]>): Array<{ p1: any; p2: any; contact: Vector3 }> {
    const start = performance.now()
    const collisions: Array<{ p1: any; p2: any; contact: Vector3 }> = []

    for (const [p1, p2] of pairs) {
      if (!p1 || !p2) continue

      // Calculate actual collision point
      const dx = p1.position.x - p2.position.x
      const dy = p1.position.y - p2.position.y
      const dz = p1.position.z - p2.position.z
      const distance = Math.sqrt(dx * dx + dy * dy + dz * dz)

      const minDistance = (p1.size || 1) + (p2.size || 1)
      if (distance < minDistance) {
        // Calculate contact point (midpoint between surfaces)
        const contactX = p1.position.x - (dx / distance) * (p1.size || 1)
        const contactY = p1.position.y - (dy / distance) * (p1.size || 1)
        const contactZ = p1.position.z - (dz / distance) * (p1.size || 1)

        collisions.push({
          p1,
          p2,
          contact: new Vector3(contactX, contactY, contactZ),
        })
      }
    }

    this.#updateFrameMetrics(performance.now() - start)
    return collisions
  }

  /**
   * Calculate electromagnetic forces between charged particles
   * @param particles - Array of particles with charge property
   * @returns Array of electromagnetic force vectors
   */
  calculateElectromagneticForces(particles: any[]): Vector3[] {
    const start = performance.now()
    const forces: Vector3[] = []
    const k = 8.9875517923e9 // Coulomb's constant (scaled for simulation)

    for (let i = 0; i < particles.length; i++) {
      const p1 = particles[i]
      if (!p1 || !p1.active) {
        forces.push(new Vector3(0, 0, 0))
        continue
      }

      const totalForce = new Vector3(0, 0, 0)
      const charge1 = p1.charge || 0

      for (let j = 0; j < particles.length; j++) {
        if (i === j) continue

        const p2 = particles[j]
        if (!p2 || !p2.active) continue

        const charge2 = p2.charge || 0
        if (charge1 === 0 || charge2 === 0) continue

        // Calculate distance vector
        const dx = p2.position.x - p1.position.x
        const dy = p2.position.y - p1.position.y
        const dz = p2.position.z - p1.position.z
        const distance = Math.sqrt(dx * dx + dy * dy + dz * dz)

        if (distance < 0.1) continue // Avoid singularity

        // Calculate electromagnetic force magnitude
        const force = (k * charge1 * charge2) / (distance * distance)

        // Add force component (repulsive if same charge, attractive if opposite)
        totalForce.x += (dx / distance) * force
        totalForce.y += (dy / distance) * force
        totalForce.z += (dz / distance) * force
      }

      forces.push(totalForce)
    }

    this.#updateFrameMetrics(performance.now() - start)
    return forces
  }

  /**
   * Query an octree for particles in a region
   * @param octree - Octree to query
   * @param region - Query region (point or bounds)
   * @returns Array of particles in the region
   */
  queryOctree(octree: any, region: { x: number; y: number; z: number; radius?: number }): any[] {
    const start = performance.now()
    const results: any[] = []

    if (!octree) return results

    // Simple query - just return all particles for performance testing
    // In a real implementation, this would traverse the octree spatially
    for (const particle of octree.particles || []) {
      if (!particle || !particle.active) continue

      const dx = particle.position.x - region.x
      const dy = particle.position.y - region.y
      const dz = particle.position.z - region.z
      const distance = Math.sqrt(dx * dx + dy * dy + dz * dz)

      const queryRadius = region.radius || 10
      if (distance <= queryRadius) {
        results.push(particle)
      }
    }

    this.#updateFrameMetrics(performance.now() - start)
    return results
  }

  dispose(): void {
    this.reset()
    PhysicsService.#instance = null
    this.#logger.info('PhysicsService disposed - singleton reset')
  }

  /* ---------------------------- private helpers --------------------------- */
  #updateFrameMetrics(frameMs: number) {
    this.#frameTimes.push(frameMs)
    if (this.#frameTimes.length > 120) this.#frameTimes.shift()
    const sum = this.#frameTimes.reduce((a, b) => a + b, 0)
    this.#metrics.averageFrameTime = sum / this.#frameTimes.length
    this.#metrics.currentFPS =
      this.#metrics.averageFrameTime > 0 ? 1000 / this.#metrics.averageFrameTime : 0
  }

  #random(count: number, b: Vector3): Vector3[] {
    const arr: Vector3[] = []
    for (let i = 0; i < count; i++) {
      arr.push(
        new Vector3(
          (Math.random() - 0.5) * b.x,
          (Math.random() - 0.5) * b.y,
          (Math.random() - 0.5) * b.z
        )
      )
    }
    return arr
  }

  #grid(count: number, b: Vector3): Vector3[] {
    const positions: Vector3[] = []
    const side = Math.ceil(Math.cbrt(count))
    const spacing = new Vector3(b.x / side, b.y / side, b.z / side)
    for (let x = 0; x < side; x++)
      for (let y = 0; y < side; y++)
        for (let z = 0; z < side && positions.length < count; z++) {
          positions.push(
            new Vector3(
              (x - side / 2) * spacing.x,
              (y - side / 2) * spacing.y,
              (z - side / 2) * spacing.z
            )
          )
        }
    return positions
  }

  #circle(count: number, b: Vector3): Vector3[] {
    const radius = Math.min(b.x, b.y) * 0.5
    const positions: Vector3[] = []
    for (let i = 0; i < count; i++) {
      const angle = (i / count) * Math.PI * 2
      positions.push(new Vector3(Math.cos(angle) * radius, 0, Math.sin(angle) * radius))
    }
    return positions
  }

  #sphere(count: number, b: Vector3): Vector3[] {
    const radius = Math.min(b.x, b.y, b.z) * 0.5
    const positions: Vector3[] = []
    for (let i = 0; i < count; i++) {
      const u = Math.random()
      const v = Math.random()
      const theta = 2 * Math.PI * u
      const phi = Math.acos(2 * v - 1)
      positions.push(
        new Vector3(
          radius * Math.sin(phi) * Math.cos(theta),
          radius * Math.sin(phi) * Math.sin(theta),
          radius * Math.cos(phi)
        )
      )
    }
    return positions
  }

  // Fibonacci sphere distribution for uniformity
  #fibonacciSphere(count: number, radius: number): Vector3[] {
    const positions: Vector3[] = []
    const offset = 2 / count
    const increment = Math.PI * (3 - Math.sqrt(5))
    for (let i = 0; i < count; i++) {
      const y = i * offset - 1 + offset / 2
      const r = Math.sqrt(1 - y * y)
      const phi = i * increment
      positions.push(
        new Vector3(Math.cos(phi) * r * radius, y * radius, Math.sin(phi) * r * radius)
      )
    }
    return positions
  }
}

// Singleton export
export const physicsService = PhysicsService.getInstance()
