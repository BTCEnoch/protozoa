/**
 * @fileoverview Trait Domain Exports
 * @description Main export file for Trait domain
 * @author Protozoa Development Team
 * @version 1.0.0
 */

// Service exports
export { TraitService, traitService } from "./services/TraitService";

// Interface exports
export type {
  ITraitService,
  TraitConfig
} from "./interfaces/ITraitService";

// Type exports
export type {
  OrganismTraits,
  VisualTraits,
  BehavioralTraits,
  PhysicalTraits,
  EvolutionaryTraits,
  TraitMetrics,
  TraitCategory,
  TraitType,
  MutationRecord,
  TraitValidation,
  TraitGenerationParams,
  GenerationType,
  RGBColor,
  TraitRange,
  InheritanceWeights
} from "./types/trait.types";

// Data exports
export {
  VISUAL_TRAIT_DEFINITIONS,
  BEHAVIORAL_TRAIT_DEFINITIONS,
  PHYSICAL_TRAIT_DEFINITIONS,
  EVOLUTIONARY_TRAIT_DEFINITIONS,
  MUTATION_PROBABILITIES,
  TRAIT_COMPATIBILITY_MATRIX,
  TraitDefinitionHelpers,
  ALL_TRAIT_DEFINITIONS,
  TRAIT_CATEGORIES
} from './data/traitDefinitions';

export {
  MUTATION_INTENSITY_LEVELS,
  COLOR_MUTATION_TABLE,
  NUMERIC_MUTATION_ALGORITHMS,
  TRAIT_MUTATION_MAPPINGS,
  MutationTableHelpers,
  MUTATION_CONFIG
} from './data/mutationTables';

// Dependency Injection exports
export {
  TraitDependencyInjection,
  configureDependencies,
  validateTraitDependencies,
  traitDependencyInjection,
  TRAIT_DEPENDENCY_DEFAULTS
} from './services/traitDependencyInjection';

export type {
  ITraitDependencyConfig
} from './services/traitDependencyInjection';
