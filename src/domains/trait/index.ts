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
