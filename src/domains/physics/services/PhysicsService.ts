/**
 * @fileoverview Physics Service Implementation (Template)
 * @module @/domains/physics/services/PhysicsService
 * @version 1.0.0
 */

import { Vector3, Matrix4, Quaternion } from "three"
import type {
  IPhysicsService,
  PhysicsConfig,
  ParticlePhysics,
  Transform,
  PhysicsMetrics
} from "@/domains/physics/interfaces/IPhysicsService"
import type {
  PhysicsState,
  DistributionPattern,
  GeometryBounds
} from "@/domains/physics/types/physics.types"
import { createServiceLogger } from "@/shared/lib/logger"

/**
 * PhysicsService – provides lightweight kinematic helpers and geometry utilities.
 * Note: Complex force-field simulation is delegated to the Formation/Animation domains.
 */
export class PhysicsService implements IPhysicsService {
  /* ------------------------------- singleton ------------------------------- */
  private static #instance: PhysicsService | null = null
  public static getInstance(): PhysicsService {
    if (!PhysicsService.#instance) PhysicsService.#instance = new PhysicsService()
    return PhysicsService.#instance
  }
  private constructor() {
    this.#logger.info("PhysicsService instantiated (kinematic-only mode)")
  }

  /* ------------------------------ private data ----------------------------- */
  #logger = createServiceLogger("PHYSICS_SERVICE")

  #config: PhysicsConfig = {
    targetFPS: 60,
    gravity: -9.81,
    damping: 0.99
  }

  #state: PhysicsState = {
    isRunning: false,
    simulationTime: 0,
    lastDeltaTime: 0,
    algorithm: "euler",
    collisionMethod: "basic",
    activeParticles: 0
  }

  #metrics: PhysicsMetrics = {
    currentFPS: 0,
    averageFrameTime: 0,
    transformCalculations: 0,
    geometryOperations: 0,
    memoryUsage: 0
  }

  #frameTimes: number[] = []

  /* --------------------------- public I/F methods -------------------------- */
  async initialize(config?: PhysicsConfig): Promise<void> {
    this.#logger.info("Initializing PhysicsService", { config })
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
      case "grid":
        positions = this.#grid(count, bounds)
        break
      case "circle":
        positions = this.#circle(count, bounds)
        break
      case "sphere":
        positions = this.#sphere(count, bounds)
        break
      case "fibonacci":
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
    return { position: position.clone(), rotation: { ...rotation }, scale: scale.clone(), matrix: new Float32Array(matrix.elements) }
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
    this.#logger.info("PhysicsService state reset")
  }

  dispose(): void {
    this.reset()
    PhysicsService.#instance = null
    this.#logger.info("PhysicsService disposed – singleton reset")
  }

  /* ---------------------------- private helpers --------------------------- */
  #updateFrameMetrics(frameMs: number) {
    this.#frameTimes.push(frameMs)
    if (this.#frameTimes.length > 120) this.#frameTimes.shift()
    const sum = this.#frameTimes.reduce((a, b) => a + b, 0)
    this.#metrics.averageFrameTime = sum / this.#frameTimes.length
    this.#metrics.currentFPS = this.#metrics.averageFrameTime > 0 ? 1000 / this.#metrics.averageFrameTime : 0
  }

  #random(count: number, b: Vector3): Vector3[] {
    const arr: Vector3[] = []
    for (let i = 0; i < count; i++) {
      arr.push(new Vector3((Math.random() - 0.5) * b.x, (Math.random() - 0.5) * b.y, (Math.random() - 0.5) * b.z))
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
          positions.push(new Vector3((x - side / 2) * spacing.x, (y - side / 2) * spacing.y, (z - side / 2) * spacing.z))
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
      positions.push(new Vector3(Math.cos(phi) * r * radius, y * radius, Math.sin(phi) * r * radius))
    }
    return positions
  }
}

// Singleton export
export const physicsService = PhysicsService.getInstance()