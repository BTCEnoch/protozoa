// src/shared/types/index.ts
// Cross-domain shared types and interfaces
// Referenced from build_checklist.md Phase 1 requirements

// Vector types for 3D coordinates
export interface Vector3 {
  x: number;
  y: number;
  z: number;
}

// Base particle interface used across domains
export interface Particle {
  id: string;
  position: Vector3;
  velocity: Vector3;
  traits: OrganismTraits;
}

// Organism traits structure
export interface OrganismTraits {
  visual?: Record<string, any>;
  behavior?: Record<string, any>;
  mutation?: Record<string, any>;
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
