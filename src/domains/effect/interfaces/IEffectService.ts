/**
 * @fileoverview IEffectService Interface Definition
 * @description Contract for managing visual particle effects.
 */

export interface EffectConfig {
  /** Duration of the effect in milliseconds */
  duration: number
  /** Intensity factor (0.0 â€“ 1.0) */
  intensity: number
  /** Arbitrary extra parameters */
  [key: string]: unknown
}

export interface IEffectService {
  /** Register a reusable effect preset */
  registerEffectPreset(name: string, config: EffectConfig): void
  /** Trigger an effect */
  triggerEffect(name: string, options?: unknown): void
  /** Cleanup and release resources */
  dispose(): void
}
