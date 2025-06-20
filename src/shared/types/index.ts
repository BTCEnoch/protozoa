/**
 * Shared Types Index
 * Central export point for all shared types and interfaces
 */

// Export THREE.js Vector3 as the standard vector type
export { Vector3 } from "three";

// Core entity types
export * from "./entityTypes";

// Service configuration types  
export * from "./configTypes";

// Event types for domain communication
export * from "./eventTypes";

// Logging types
export * from "./loggingTypes";

// Organism traits structure
export interface OrganismTraits {
  visual: {
    color: { r: number; g: number; b: number };
    size: number;
    opacity: number;
  };
  behavioral: {
    speed: number;
    aggressiveness: number;
    socialness: number;
  };
  evolutionary: {
    mutationRate: number;
    adaptability: number;
    survivability: number;
  };
}

// Trait component interfaces
export interface VisualTraits {
  color: { r: number; g: number; b: number };
  size: number;
  opacity: number;
}

export interface BehavioralTraits {
  speed: number;
  aggressiveness: number;
  socialness: number;
}

export interface EvolutionaryTraits {
  mutationRate: number;
  adaptability: number;
  survivability: number;
}

export interface MutationTraits {
  rate: number;
  intensity: number;
  stability: number;
}

// Common trait value type
export type TraitValue = string | number | boolean;

// Particle type definitions
export type ParticleType = "core" | "membrane" | "nucleus" | "cytoplasm" | "organelle" | "effect";

// Particle creation data
export interface ParticleCreationData {
  id: string;
  position: Vector3;
  traits: OrganismTraits;
  type: ParticleType;
}

// Particle performance metrics
export interface ParticleMetrics {
  count: number;
  activeCount: number;
  memoryUsage: number;
  creationRate: number;
  removalRate: number;
}

// Formation pattern data structure
export interface FormationPattern {
  id: string;
  name: string;
  positions: Vector3[];
  metadata?: Record<string, any>;
}

// Animation configuration
export interface AnimationConfig {
  duration: number;
  type: string;
  parameters?: Record<string, any>;
}

// Animation state tracking
export interface AnimationState {
  role: string;
  progress: number;
  duration: number;
  type: string;
}
