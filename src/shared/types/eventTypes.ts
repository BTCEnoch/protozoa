/**
 * Event Types for Domain Communication
 * Standardized event interfaces for inter-domain messaging
 */

/**
 * Base event interface
 */
export interface IBaseEvent {
  /** Event type identifier */
  type: string;
  /** Event timestamp */
  timestamp: Date;
  /** Source domain/service */
  source: string;
  /** Event payload */
  payload: Record<string, any>;
  /** Correlation ID for tracking */
  correlationId?: string;
}

/**
 * Particle lifecycle events
 */
export interface IParticleEvent extends IBaseEvent {
  /** Particle ID */
  particleId: string;
}

export interface IParticleCreatedEvent extends IParticleEvent {
  type: 'particle.created';
  payload: {
    particle: import('./entityTypes').IParticle;
  };
}

export interface IParticleUpdatedEvent extends IParticleEvent {
  type: 'particle.updated';
  payload: {
    previousState: Partial<import('./entityTypes').IParticle>;
    currentState: import('./entityTypes').IParticle;
  };
}

export interface IParticleRemovedEvent extends IParticleEvent {
  type: 'particle.removed';
  payload: {
    reason: string;
  };
}

/**
 * Formation events
 */
export interface IFormationEvent extends IBaseEvent {
  /** Formation pattern ID */
  formationId: string;
}

export interface IFormationAppliedEvent extends IFormationEvent {
  type: 'formation.applied';
  payload: {
    particleIds: string[];
    pattern: import('./entityTypes').IFormationPattern;
  };
}

export interface IFormationTransitionEvent extends IFormationEvent {
  type: 'formation.transition';
  payload: {
    fromFormationId: string;
    toFormationId: string;
    progress: number;
  };
}

/**
 * Trait mutation events
 */
export interface ITraitMutationEvent extends IBaseEvent {
  type: 'trait.mutated';
  payload: {
    organismId: string;
    traitType: string;
    oldValue: any;
    newValue: any;
    mutationFactor: number;
  };
}

/**
 * Effect events
 */
export interface IEffectEvent extends IBaseEvent {
  /** Effect name */
  effectName: string;
}

export interface IEffectTriggeredEvent extends IEffectEvent {
  type: 'effect.triggered';
  payload: {
    targetIds: string[];
    duration: number;
    intensity: number;
  };
}

/**
 * Union type for all domain events
 */
export type DomainEvent = 
  | IParticleCreatedEvent
  | IParticleUpdatedEvent
  | IParticleRemovedEvent
  | IFormationAppliedEvent
  | IFormationTransitionEvent
  | ITraitMutationEvent
  | IEffectTriggeredEvent;

/**
 * Event handler function type
 */
export type EventHandler<T extends IBaseEvent = IBaseEvent> = (event: T) => void | Promise<void>;

/**
 * Event bus interface
 */
export interface IEventBus {
  /** Subscribe to events */
  subscribe<T extends IBaseEvent>(eventType: string, handler: EventHandler<T>): void;
  /** Unsubscribe from events */
  unsubscribe<T extends IBaseEvent>(eventType: string, handler: EventHandler<T>): void;
  /** Emit an event */
  emit<T extends IBaseEvent>(event: T): Promise<void>;
  /** Remove all listeners */
  removeAllListeners(): void;
}
