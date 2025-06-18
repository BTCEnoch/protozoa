/**
 * @fileoverview Particle Service Implementation
 * @description High-performance particle system with THREE.js integration and GPU optimization
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import type { IParticleService, ParticleConfig, ParticleInstance, ParticleSystem } from '@/domains/particle/interfaces/IParticleService'
import { rngService } from '@/domains/rng/services/RngService'
import { createPerformanceLogger, createServiceLogger } from '@/shared/lib/logger'
import { BufferGeometry, Points, PointsMaterial, Scene, Vector3 } from 'three'

/**
 * Minimal but functional ParticleService to restore build correctness.
 * Provides basic in-memory particle management; can be incrementally enhanced.
 */
export class ParticleService implements IParticleService {
  static #instance: ParticleService | null = null

  // Internal collections
  #systems: Map<string, ParticleSystem> = new Map()

  // Config & logging
  #config: Required<ParticleConfig> = {
    maxParticles: 10_000,
    useInstancing: false,
    useObjectPooling: false,
    defaultMaterial: 'basic',
    enableLOD: false,
    cullingDistance: 1_000
  }
  #log  = createServiceLogger('PARTICLE_SERVICE')
  #perf = createPerformanceLogger('PARTICLE_SERVICE')

  private constructor() {
    this.#log.info('ParticleService singleton created')
  }

  public static getInstance(): ParticleService {
    if (!ParticleService.#instance) ParticleService.#instance = new ParticleService()
    return ParticleService.#instance
  }

  async initialize(config?: ParticleConfig): Promise<void> {
    if (config) this.#config = { ...this.#config, ...config }
    this.#log.info('ParticleService initialized', { config: this.#config })
  }

  createSystem(systemConfig: Omit<ParticleSystem, 'id' | 'activeParticles' | 'particles' | 'createdAt'>): ParticleSystem {
    const id = `ps-${Math.floor(rngService.random() * 1e8).toString(36)}`
    const system: ParticleSystem = {
      id,
      active: true,
      activeParticles: 0,
      particles: [],
      createdAt: Date.now(),
      ...systemConfig
    }
    this.#systems.set(id, system)
    this.#log.info('Particle system created', { id })
    return system
  }

  addParticles(systemId: string, particleData: Partial<ParticleInstance>[]): string[] {
    const system = this.#systems.get(systemId)
    if (!system) throw new Error(`System ${systemId} not found`)
    const ids: string[] = []
    for (const data of particleData) {
      if (system.activeParticles >= system.maxParticles) break
      const id = `p-${Math.floor(rngService.random() * 1e8).toString(36)}`
      const instance: ParticleInstance = {
        id,
        position: data.position ?? new Vector3(),
        velocity: data.velocity ?? new Vector3(),
        scale: data.scale ?? new Vector3(1, 1, 1),
        rotation: data.rotation ?? 0,
        color: data.color ?? { r: 1, g: 1, b: 1 },
        opacity: data.opacity ?? 1,
        age: 0,
        lifetime: data.lifetime ?? 5,
        active: true,
        type: data.type ?? 'default' as any,
        userData: data.userData ?? {}
      }
      system.particles.push(instance)
      system.activeParticles++
      ids.push(id)
    }
    return ids
  }

  removeParticles(systemId: string, particleIds: string[]): void {
    const system = this.#systems.get(systemId)
    if (!system) return
    system.particles = system.particles.filter(p => !particleIds.includes(p.id))
    system.activeParticles = system.particles.length
  }

  update(deltaTime: number): void {
    const start = performance.now()
    for (const sys of this.#systems.values()) {
      if (!sys.active) continue
      for (const p of sys.particles) {
        p.position.addScaledVector(p.velocity, deltaTime)
        p.age += deltaTime
        if (p.age >= p.lifetime) p.active = false
      }
      sys.particles = sys.particles.filter(p => p.active)
      sys.activeParticles = sys.particles.length
    }
    this.#perf.debug(`update took ${(performance.now() - start).toFixed(2)}ms`)
  }

  render(scene: Scene): void {
    const start = performance.now()
    for (const sys of this.#systems.values()) {
      if (!sys.active || sys.activeParticles === 0) continue

      // Very naive rendering: one Points per system
      const geometry = new BufferGeometry().setFromPoints(sys.particles.map(p => p.position))
      const material = new PointsMaterial({ size: 1, color: 0xffffff })
      const points = new Points(geometry, material)
      scene.add(points)
    }
    this.#perf.debug(`render took ${(performance.now() - start).toFixed(2)}ms`)
  }

  getSystem(systemId: string): ParticleSystem | undefined {
    return this.#systems.get(systemId)
  }

  getMetrics(): { totalSystems: number; totalParticles: number } {
    return {
      totalSystems: this.#systems.size,
      totalParticles: Array.from(this.#systems.values()).reduce((a, s) => a + s.activeParticles, 0)
    }
  }

  dispose(): void {
    this.#systems.clear()
    this.#log.info('ParticleService disposed')
    ParticleService.#instance = null
  }
}

export const particleService = ParticleService.getInstance()
