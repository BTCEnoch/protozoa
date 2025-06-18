/**
 * @fileoverview RenderingService Implementation
 * @description Singleton THREE.js renderer orchestrating scene, camera, and domain integrations.
 */

import type { IEffectService } from '@/domains/effect/interfaces/IEffectService'
import type { IFormationService } from '@/domains/formation/interfaces/IFormationService'
import type { IRenderingService } from '@/domains/rendering/interfaces/IRenderingService'
import { createErrorLogger, createPerformanceLogger, createServiceLogger } from '@/shared/lib/logger'
import { Object3D, PerspectiveCamera, Scene, WebGLRenderer } from 'three'

class RenderingService implements IRenderingService {
  /** Singleton instance */
  static #instance: RenderingService | null = null

  // THREE.js core
  #scene = new Scene()
  #camera: PerspectiveCamera
  #renderer: WebGLRenderer

  // Injected domain services
  #formationService?: IFormationService
  #effectService?: IEffectService

  // Loggers
  #log  = createServiceLogger('RENDERING_SERVICE')
  #perf = createPerformanceLogger('RENDERING_SERVICE')
  #err  = createErrorLogger('RENDERING_SERVICE')

  private constructor() {
    // Camera init
    this.#camera = new PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
    this.#camera.position.z = 50
    // Renderer init
    this.#renderer = new WebGLRenderer({ antialias: true })
    this.#renderer.setSize(window.innerWidth, window.innerHeight)
    this.#log.info('RenderingService constructor complete')
  }

  /** Get singleton */
  public static getInstance(): RenderingService {
    if (!RenderingService.#instance) RenderingService.#instance = new RenderingService()
    return RenderingService.#instance
  }

  /** Public getters for low-level access (read-only) */
  get scene()     { return this.#scene }
  get camera()    { return this.#camera }
  get renderer()  { return this.#renderer }

  /** Initialize renderer on canvas and wire dependencies */
  public initialize(canvas: HTMLCanvasElement, deps: { formation?: IFormationService; effect?: IEffectService } = {}): void {
    // Attach renderer canvas, re-parent if necessary
    if (
      this.#renderer.domElement.parentElement &&
      this.#renderer.domElement.parentElement !== canvas
    ) {
      this.#renderer.domElement.remove()
    }
    if (!canvas.contains(this.#renderer.domElement)) {
      canvas.appendChild(this.#renderer.domElement)
    }

    // Dependency injection
    this.#formationService = deps.formation
    this.#effectService    = deps.effect

    this.#log.info('RenderingService initialized with dependencies', { hasFormation: !!deps.formation, hasEffect: !!deps.effect })
  }

  /** Render a single frame */
  public renderFrame(delta: number): void {
    this.#renderer.render(this.#scene, this.#camera)
    this.#perf.debug(`Frame rendered in ${delta.toFixed(2)} ms`)
  }

  public addObject(obj: Object3D): void {
    this.#scene.add(obj)
    this.#log.debug('Object added', { id: obj.id })
  }

  public removeObject(obj: Object3D): void {
    this.#scene.remove(obj)
    this.#log.debug('Object removed', { id: obj.id })
  }

  public applyFormation(patternId: string): void {
    if (!this.#formationService) {
      this.#err.logError(new Error('FormationService unavailable'), { patternId })
      return
    }
    const pattern = this.#formationService.getFormationPattern(patternId)
    if (!pattern) {
      this.#log.warn('Formation pattern not found', { patternId })
      return
    }
    // Actual particle repositioning delegated outside; log for now.
    this.#log.info('Formation applied', { patternId, positions: pattern.positions?.length })
  }

  public applyEffect(effectName: string, options?: unknown): void {
    if (!this.#effectService) {
      this.#err.logError(new Error('EffectService unavailable'), { effectName })
      return
    }
    this.#effectService.triggerEffect(effectName, options)
    this.#log.info('Effect triggered', { effectName })
  }

  /** Dispose GPU resources and detach */
  public dispose(): void {
    this.#scene.clear()
    this.#renderer.dispose()
    this.#log.info('RenderingService disposed')
    RenderingService.#instance = null
  }
}

export const renderingService = RenderingService.getInstance()
