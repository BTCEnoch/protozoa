/**
 * @fileoverview Formation Domain Exports
 * @module @/domains/formation
 */

// Service exports
export { FormationService } from './services/FormationService'
export { formationBlendingService } from './services/formationBlendingService'
export { DynamicFormationGenerator } from './services/dynamicFormationGenerator'
export { scalePattern } from './services/formationEnhancer'

// Interface exports
export type { IFormationService } from './interfaces/IFormationService'
export type { IFormationBlendingService } from './interfaces/IFormationBlendingService'

// Type exports
export type {
  IFormationPattern,
  IFormationGeometry,
  FormationConfig,
  FormationType,
} from './types/formation.types'

// Data exports
export { FormationGeometry } from './data/formationGeometry'
export { FormationPatterns } from './data/formationPatterns' 
