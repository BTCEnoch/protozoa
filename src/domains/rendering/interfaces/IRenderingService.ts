/**
 * @fileoverview IRenderingService Interface Definition
 * @description Contract for THREE.js rendering operations used across the application.
 */

import type { Object3D, PerspectiveCamera, Scene, WebGLRenderer } from 'three'
import type { IFormationService } from '@/domains/formation/interfaces/IFormationService'
import type { IEffectService }    from '@/domains/effect/interfaces/IEffectService'

export interface IRenderingService {
  /** Attach renderer to canvas and wire optional domain dependencies */
  initialize(canvas: HTMLCanvasElement, deps?: { formation?: IFormationService; effect?: IEffectService }): void
  /** Render one animation frame */
  renderFrame(delta: number): void
  /** Add an Object3D to the scene graph */
  addObject(obj: Object3D): void
  /** Remove an Object3D from the scene graph */
  removeObject(obj: Object3D): void
  /** Apply a formation pattern to current particle system */
  applyFormation(patternId: string): void
  /** Trigger a visual effect */
  applyEffect(effectName: string, options?: unknown): void
  /** Access underlying Three.js objects (for advanced usage) */
  readonly scene: Scene
  readonly camera: PerspectiveCamera
  readonly renderer: WebGLRenderer
  /** Cleanup GPU resources and detach event listeners */
  dispose(): void
}
