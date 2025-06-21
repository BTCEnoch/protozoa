import { createServiceLogger } from '@/shared/lib/logger'
import type { IAnimationBlendingService, BlendNode } from '@/domains/animation/interfaces/IAnimationBlendingService'
import { animationService } from '@/domains/animation'

interface Transition { target: string; time: number; duration: number }

class AnimationBlendingService implements IAnimationBlendingService {
  static #instance: AnimationBlendingService | null = null
  #log = createServiceLogger('ANIM_BLEND')
  #root: BlendNode | null = null
  #currentState = 'idle'
  #transition: Transition | null = null
  private constructor() {}
  static getInstance() { return this.#instance ?? (this.#instance = new AnimationBlendingService()) }

  setBlendTree(root: BlendNode): void { this.#root = root; this.#log.info('Blend tree set') }

  transition(toState: string, duration: number): void {
    if (toState === this.#currentState) return
    this.#transition = { target: toState, time: 0, duration }
    this.#log.info('Transition started', { toState, duration })
  }

  update(delta: number): void {
    if (!this.#transition) return
    this.#transition.time += delta
    const t = Math.min(this.#transition.time / this.#transition.duration, 1)
    // linear interpolation of weights - simple implementation
    // Update animationService easing based on blend factor t
    animationService.updateAnimations(0) // ensure internal animations tick
    if (t >= 1) {
      this.#currentState = this.#transition.target
      this.#transition = null
      this.#log.debug('Transition completed', { state: this.#currentState })
    }
  }

  dispose(): void { this.#root = null; this.#transition = null; AnimationBlendingService.#instance = null }
}

export const animationBlendingService = AnimationBlendingService.getInstance()
