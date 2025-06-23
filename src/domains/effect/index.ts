/**
 * @fileoverview Effect Domain Exports
 * @description Main export file for Effect domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { EffectService, effectService } from "./services/EffectService";
export { EffectComposerService, effectComposerService } from "./services/EffectComposerService";

// Interface exports
export type {
  IEffectService,
  IEffectConfig,
  IEffectInstance,
  IMutationHook,
  IEffectMetrics,
  IEffectHealthStatus,
  IEffectServiceConfig,
  IEffectServiceFactory
} from "./interfaces/IEffectService";

// Type exports
export type {
  EffectType,
  EffectCategory,
  AnimationCurve,
  BlendMode,
  EffectTrigger,
  IColorKeyframe,
  IScaleKeyframe,
  IPositionKeyframe,
  IEffectAnimation,
  IEffectParticleConfig,
  IEffectShaderConfig,
  IEffectResource,
  IEffectTemplate,
  IEffectContext,
  IEffectEvent,
  IEffectPerformanceProfile,
  IEffectLOD,
  IMutationEffectMapping,
  IEffectPoolConfig,
  EffectUpdateCallback,
  EffectCompletionCallback,
  EffectErrorCallback,
  EffectEventCallback
} from "./types/effect.types";

export {
  EffectState,
  EffectPriority
} from "./types/effect.types";

// Data exports
export {
  EFFECT_PRESETS,
  MUTATION_EFFECT_MAPPINGS
} from "./data/effectPresets";
