/**
 * Event type definitions for inter-domain communication
 */

// Base event interface
export interface BaseEvent {
  type: string;
  timestamp: number;
  source: string;
  data: Record<string, any>;
}

// Particle events
export interface ParticleEvent extends BaseEvent {
  particleId: string;
}

export interface ParticleBirthEvent extends ParticleEvent {
  type: "particle:birth";
  data: {
    position: { x: number; y: number; z: number };
    traits: Record<string, any>;
  };
}

export interface ParticleDeathEvent extends ParticleEvent {
  type: "particle:death";
  data: {
    age: number;
    cause: string;
  };
}

// Group events
export interface GroupEvent extends BaseEvent {
  groupId: string;
}

export interface GroupFormationEvent extends GroupEvent {
  type: "group:formation";
  data: {
    memberIds: string[];
    pattern: string;
  };
}

// Animation events
export interface AnimationEvent extends BaseEvent {
  animationId: string;
}

export interface AnimationCompleteEvent extends AnimationEvent {
  type: "animation:complete";
  data: {
    duration: number;
    success: boolean;
  };
}
