/**
 * @fileoverview Effect Service Interface
 * @description Interface for managing visual effects, mutations hooks, and GPU resources
 * @author Protozoa Development Team
 * @version 1.0.0
 */

import { Vector3 } from 'three'

/**
 * Effect types for different visual mutations
 */
export type EffectType = 
  | 'nebula_burst'
  | 'type_change_transition' 
  | 'evolution_pulse'
  | 'mutation_sparkle'
  | 'formation_shift'
  | 'particle_trail'
  | 'energy_wave'
  | 'dissolve_effect'

/**
 * Effect configuration parameters
 */
export interface IEffectConfig {
  duration: number
  intensity: number
  fadeIn: number
  fadeOut: number
  scale: Vector3
  color: string
  opacity: number
  particleCount?: number
  animationSpeed?: number
  blendMode?: string
}

/**
 * Effect instance representing an active effect
 */
export interface IEffectInstance {
  id: string
  type: EffectType
  config: IEffectConfig
  startTime: number
  endTime: number
  isActive: boolean
  position: Vector3
  targetId?: string
  onComplete?: () => void
  onUpdate?: (progress: number) => void
}

/**
 * Mutation visual hook configuration
 */
export interface IMutationHook {
  traitName: string
  effectType: EffectType
  trigger: 'immediate' | 'delayed' | 'on_change'
  config: Partial<IEffectConfig>
  condition?: (oldValue: any, newValue: any) => boolean
}

/**
 * Effect performance metrics
 */
export interface IEffectMetrics {
  activeEffects: number
  totalEffectsCreated: number
  averageFrameTime: number
  gpuMemoryUsage: number
  particleCount: number
  lastFrameDrops: number
}

/**
 * Effect service health status
 */
export interface IEffectHealthStatus {
  isHealthy: boolean
  metrics: IEffectMetrics
  errors: string[]
  warnings: string[]
  lastUpdate: number
}

/**
 * Effect service interface
 */
export interface IEffectService {
  /**
   * Create a new effect instance
   */
  createEffect(
    type: EffectType,
    position: Vector3,
    config: Partial<IEffectConfig>,
    targetId?: string
  ): Promise<IEffectInstance>

  /**
   * Remove an effect by ID
   */
  removeEffect(effectId: string): boolean

  /**
   * Update all active effects
   */
  updateEffects(deltaTime: number): void

  /**
   * Get effect by ID
   */
  getEffect(effectId: string): IEffectInstance | null

  /**
   * Get all active effects
   */
  getActiveEffects(): IEffectInstance[]

  /**
   * Clear all effects
   */
  clearAllEffects(): void

  /**
   * Register mutation visual hook
   */
  registerMutationHook(hook: IMutationHook): string

  /**
   * Unregister mutation visual hook
   */
  unregisterMutationHook(hookId: string): boolean

  /**
   * Trigger mutation effect for trait change
   */
  triggerMutationEffect(
    traitName: string,
    oldValue: any,
    newValue: any,
    position: Vector3,
    targetId?: string
  ): Promise<IEffectInstance | null>

  /**
   * Trigger a generic effect at position
   */
  triggerEffect(
    effectType: EffectType,
    position: Vector3,
    config?: Partial<IEffectConfig>
  ): Promise<IEffectInstance>

  /**
   * Create nebula burst effect
   */
  createNebulaBurst(
    position: Vector3,
    intensity: number,
    color?: string
  ): Promise<IEffectInstance>

  /**
   * Create type change transition effect
   */
  createTypeChangeTransition(
    position: Vector3,
    fromType: string,
    toType: string
  ): Promise<IEffectInstance>

  /**
   * Create evolution pulse effect
   */
  createEvolutionPulse(
    position: Vector3,
    generation: number,
    targetId?: string
  ): Promise<IEffectInstance>

  /**
   * Create mutation sparkle effect
   */
  createMutationSparkle(
    position: Vector3,
    traitName: string,
    intensity: number
  ): Promise<IEffectInstance>

  /**
   * Preload effect resources
   */
  preloadEffects(effectTypes: EffectType[]): Promise<void>

  /**
   * Get effect performance metrics
   */
  getMetrics(): IEffectMetrics

  /**
   * Get service health status
   */
  getHealthStatus(): IEffectHealthStatus

  /**
   * Dispose GPU resources and cleanup
   */
  dispose(): void

  /**
   * Set maximum concurrent effects limit
   */
  setEffectLimit(limit: number): void

  /**
   * Get current effect limit
   */
  getEffectLimit(): number

  /**
   * Enable/disable effect quality optimization
   */
  setQualityOptimization(enabled: boolean): void

  /**
   * Check if effect type is supported
   */
  isEffectSupported(effectType: EffectType): boolean

  /**
   * Get default configuration for effect type
   */
  getDefaultConfig(effectType: EffectType): IEffectConfig

  /**
   * Pause all effects
   */
  pauseAllEffects(): void

  /**
   * Resume all effects
   */
  resumeAllEffects(): void

  /**
   * Set global effect intensity multiplier
   */
  setGlobalIntensity(multiplier: number): void
}

/**
 * Effect service configuration
 */
export interface IEffectServiceConfig {
  maxConcurrentEffects: number
  enableGPUOptimization: boolean
  defaultDuration: number
  enableMutationHooks: boolean
  enablePerformanceMonitoring: boolean
  particlePoolSize: number
  gpuMemoryLimit: number
}

/**
 * Effect service factory interface
 */
export interface IEffectServiceFactory {
  createEffectService(config?: Partial<IEffectServiceConfig>): IEffectService
}
