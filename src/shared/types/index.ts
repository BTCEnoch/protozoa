/**
 * Shared Types Index
 * Central export point for all shared types and interfaces
 */

// Vector and mathematical types
export * from "./vectorTypes";

// Core entity types
export * from "./entityTypes";

// Service configuration types
export * from "./configTypes";

// Logging and error types
export * from "./loggingTypes";

// Event types for domain communication
export * from "./eventTypes";

// Import specific interfaces for type aliases
import type { 
  IOrganismTraits, 
  IVisualTraits, 
  IBehavioralTraits, 
  IEvolutionaryTraits, 
  IMutationTraits
} from "./entityTypes";
import type { IVector3 } from "./vectorTypes";

// Type aliases for backward compatibility with service code
export type OrganismTraits = IOrganismTraits;
export type VisualTraits = IVisualTraits;
export type BehavioralTraits = IBehavioralTraits;
export type EvolutionaryTraits = IEvolutionaryTraits;
export type MutationTraits = IMutationTraits;
export type TraitValue = string | number | boolean;
export type ParticleType = "basic" | "enhanced" | "mutated";
export type ParticleCreationData = {
  id: string;
  position: IVector3;
  traits: IOrganismTraits;
  type: ParticleType;
};
export type ParticleMetrics = {
  count: number;
  activeCount: number;
  memoryUsage: number;
  creationRate: number;
  removalRate: number;
};
