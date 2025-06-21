/**
 * @fileoverview EffectService Implementation
 * @description Singleton service managing particle visual effects and presets.
 */

import { createServiceLogger } from '@/shared/lib/logger'
import type { IEffectService, EffectConfig } from '@/domains/effect/interfaces/IEffectService'

class EffectService implements IEffectService {
  /** Singleton instance */
  static #instance: EffectService | null = null

  /** Preset registry */
  #presets: Map<string, EffectConfig> = new Map()

  /** Logger */
  #log = createServiceLogger('EFFECT_SERVICE')

  private constructor () {
    this.#log.info('EffectService singleton created')
    // Default presets
    this.registerEffectPreset('nebula', { duration: 5000, intensity: 0.8 })
    this.registerEffectPreset('explosion', { duration: 1000, intensity: 1.0 })
  }

  /** Get singleton instance */
  public static getInstance (): EffectService {
    if (!EffectService.#instance) EffectService.#instance = new EffectService()
    return EffectService.#instance
  }

  public registerEffectPreset (name: string, config: EffectConfig): void {
    this.#presets.set(name, config)
    this.#log.debug('Preset registered', { name, config })
  }

  public triggerEffect (name: string, options: unknown = {}): void {
    const preset = this.#presets.get(name)
    if (!preset) {
      this.#log.error('Effect preset not found', { name, availablePresets: Array.from(this.#presets.keys()) })
      return
    }
    const merged = { ...preset, ...(options as Record<string, unknown>) }
    this.#log.info('Effect triggered', { name, merged })
    // Placeholder: actual Three.js particle / shader spawning occurs here.
  }

  public dispose (): void {
    this.#presets.clear()
    this.#log.info('EffectService disposed')
    EffectService.#instance = null
  }
}

export const effectService = EffectService.getInstance()
