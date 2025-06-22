/**
 * @fileoverview EffectService Implementation
 * @description Singleton service managing particle visual effects and presets.
 */

import { createServiceLogger } from '@/shared/lib/logger'
import type { IEffectService, IEffectConfig } from '@/domains/effect/interfaces/IEffectService'
import { Vector3 } from 'three'

class EffectService implements IEffectService {
  /** Singleton instance */
  static #instance: EffectService | null = null

  /** Preset registry */
  #presets: Map<string, IEffectConfig> = new Map()

  /** Logger */
  #log = createServiceLogger('EFFECT_SERVICE')

  private constructor () {
    this.#log.info('EffectService singleton created')
    // Default presets with full IEffectConfig structure
    this.registerEffectPreset('nebula', { 
      duration: 5000, 
      intensity: 0.8,
      fadeIn: 500,
      fadeOut: 1000,
      scale: new Vector3(1, 1, 1),
      color: '#00FFFF',
      opacity: 0.8
    })
    this.registerEffectPreset('explosion', { 
      duration: 1000, 
      intensity: 1.0,
      fadeIn: 100,
      fadeOut: 500,
      scale: new Vector3(2, 2, 2),
      color: '#FF4500',
      opacity: 1.0
    })
  }

  /** Get singleton instance */
  public static getInstance (): EffectService {
    if (!EffectService.#instance) EffectService.#instance = new EffectService()
    return EffectService.#instance
  }

  public registerEffectPreset (name: string, config: IEffectConfig): void {
    this.#presets.set(name, config)
    this.#log.debug('Preset registered', { name, config })
  }

  public async triggerEffect (effectType: any, position: Vector3, config?: Partial<IEffectConfig>): Promise<any> {
    this.#log.info('Effect triggered', { effectType, position, config })
    
    // Create effect instance
    const effectInstance = {
      id: `effect_${Date.now()}`,
      type: effectType,
      position: position.clone(),
      config: config || this.getDefaultConfig(effectType),
      createdAt: Date.now(),
      active: true
    }
    
    this.#log.debug('Effect instance created', { effectInstance })
    return effectInstance
  }

  // Implementation of IEffectService interface methods
  async createEffect(type: any, position: Vector3, config: Partial<IEffectConfig>, targetId?: string): Promise<any> {
    this.#log.info('[EFFECT] Creating effect', { type, targetId })
    return { id: 'temp', type, position, config, targetId }
  }

  removeEffect(effectId: string): boolean {
    this.#log.info('[EFFECT] Removing effect', { effectId })
    return true
  }

  updateEffects(deltaTime: number): void {
    this.#log.debug('[EFFECT] Updating effects', { deltaTime })
  }

  getEffect(effectId: string): any {
    this.#log.debug('[EFFECT] Getting effect', { effectId })
    return null
  }

  getActiveEffects(): any[] {
    this.#log.debug('[EFFECT] Getting active effects')
    return []
  }

  clearAllEffects(): void {
    this.#log.info('[EFFECT] Clearing all effects')
  }

  registerMutationHook(hook: any): string {
    this.#log.info('[EFFECT] Registering mutation hook', { hook })
    return 'hook-id'
  }

  unregisterMutationHook(hookId: string): boolean {
    this.#log.info('[EFFECT] Unregistering mutation hook', { hookId })
    return true
  }

  async triggerMutationEffect(traitName: string, oldValue: any, newValue: any, position: Vector3, targetId?: string): Promise<any> {
    this.#log.info('[EFFECT] Triggering mutation effect', { traitName, oldValue, newValue, targetId })
    return null
  }

  async createNebulaBurst(position: Vector3, intensity: number, color?: string): Promise<any> {
    this.#log.info('[EFFECT] Creating nebula burst', { intensity, color })
    return { id: 'nebula', position, intensity, color }
  }

  async createTypeChangeTransition(position: Vector3, fromType: string, toType: string): Promise<any> {
    this.#log.info('[EFFECT] Creating type change transition', { fromType, toType })
    return { id: 'transition', position, fromType, toType }
  }

  async createEvolutionPulse(position: Vector3, generation: number, targetId?: string): Promise<any> {
    this.#log.info('[EFFECT] Creating evolution pulse', { generation, targetId })
    return { id: 'pulse', position, generation, targetId }
  }

  async createMutationSparkle(position: Vector3, traitName: string, intensity: number): Promise<any> {
    this.#log.info('[EFFECT] Creating mutation sparkle', { traitName, intensity })
    return { id: 'sparkle', position, traitName, intensity }
  }

  async preloadEffects(effectTypes: any[]): Promise<void> {
    this.#log.info('[EFFECT] Preloading effects', { effectTypes })
  }

  getMetrics(): any {
    return {
      activeEffects: 0,
      totalEffectsCreated: 0,
      averageFrameTime: 0,
      gpuMemoryUsage: 0,
      particleCount: 0,
      lastFrameDrops: 0
    }
  }

  getHealthStatus(): any {
    return {
      isHealthy: true,
      metrics: this.getMetrics(),
      errors: [],
      warnings: [],
      lastUpdate: Date.now()
    }
  }

  setEffectLimit(limit: number): void {
    this.#log.info('[EFFECT] Setting effect limit', { limit })
  }

  getEffectLimit(): number {
    return 100
  }

  setQualityOptimization(enabled: boolean): void {
    this.#log.info('[EFFECT] Setting quality optimization', { enabled })
  }

  isEffectSupported(effectType: any): boolean {
    return true
  }

  getDefaultConfig(effectType: any): IEffectConfig {
    return {
      duration: 1000,
      intensity: 1.0,
      fadeIn: 100,
      fadeOut: 200,
      scale: new Vector3(1, 1, 1),
      color: '#FFFFFF',
      opacity: 1.0
    }
  }

  pauseAllEffects(): void {
    this.#log.info('[EFFECT] Pausing all effects')
  }

  resumeAllEffects(): void {
    this.#log.info('[EFFECT] Resuming all effects')
  }

  setGlobalIntensity(multiplier: number): void {
    this.#log.info('[EFFECT] Setting global intensity', { multiplier })
  }

  public dispose (): void {
    this.#presets.clear()
    this.#log.info('EffectService disposed')
    EffectService.#instance = null
  }
}

export const effectService = EffectService.getInstance()