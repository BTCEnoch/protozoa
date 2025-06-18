import { particleService } from '@/domains/particle/services/particleService'
import { createServiceLogger } from '@/shared/lib/logger'
import type { ILifecycleEngine } from '@/domains/particle/interfaces/ILifecycleEngine'

export class LifecycleEngine implements ILifecycleEngine {
  static #instance: LifecycleEngine | null = null
  #log = createServiceLogger('LIFECYCLE')
  private constructor() {}
  static getInstance() {
    return this.#instance ?? (this.#instance = new LifecycleEngine())
  }
  birth(count: number) {
    for (let i = 0; i < count; i++) particleService.createParticle()
    this.#log.info('Particles birthed', { count })
  }
  update(delta: number) {
    particleService.updateParticles(delta)
  }
  kill(id: string) {
    /* remove from service */
  }
  dispose() {
    LifecycleEngine.#instance = null
  }
}
export const lifecycleEngine = LifecycleEngine.getInstance()
