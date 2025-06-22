/** AnimationService Implementation */
import { createServiceLogger, createPerformanceLogger } from '@/shared/lib/logger'
import type { IAnimationService, AnimationConfig, AnimationState } from '@/domains/animation/interfaces/IAnimationService'

class AnimationService implements IAnimationService {
  static #instance: AnimationService | null = null
  #animations: Map<string, AnimationState> = new Map()
  #log = createServiceLogger('ANIMATION_SERVICE')
  #perf = createPerformanceLogger('ANIMATION_SERVICE')
  private constructor () {}
  static getInstance () {
    return this.#instance ?? (this.#instance = new AnimationService())
  }
  startAnimation (role: string, config: AnimationConfig): void {
    const state: AnimationState = { role, progress: 0, duration: config.duration, type: config.type }
    this.#animations.set(role, state)
    this.#log.info('Animation started', { role, config })
  }
  updateAnimations (delta: number): void {
    const start = performance.now()
    this.#animations.forEach((state, role) => {
      state.progress += delta
      if (state.progress >= state.duration) {
        this.#animations.delete(role)
        this.#log.debug('Animation completed', { role })
      }
    })
    const elapsed = performance.now() - start
    if (this.#animations.size) this.#perf.debug('Animations updated', { count: this.#animations.size, elapsed })
  }
  stopAll (): void {
    const count = this.#animations.size
    this.#animations.clear()
    this.#log.warn('All animations stopped', { count })
  }
  dispose (): void {
    this.stopAll()
    AnimationService.#instance = null
  }
}
export const animationService = AnimationService.getInstance()
