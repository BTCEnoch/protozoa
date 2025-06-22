/**
 * @fileoverview Formation Domain Exports
 * @module @/domains/formation
 */

// Service exports
export { FormationService } from './services/FormationService'
export { formationBlendingService } from './services/formationBlendingService'
export { dynamicFormationGenerator } from './services/dynamicFormationGenerator'
export { formationEnhancer } from './services/formationEnhancer'

// Interface exports  
export type { IFormationService } from './interfaces/IFormationService'
export type { IFormationBlendingService } from './interfaces/IFormationBlendingService'

// Type exports
export type { 
  IFormationPattern,
  IFormationGeometry,
  FormationConfig,
  FormationType
} from './types/formation.types'

// Data exports
export { FORMATION_GEOMETRIES } from './data/formationGeometry'
export { FORMATION_PATTERNS } from './data/formationPatterns'
