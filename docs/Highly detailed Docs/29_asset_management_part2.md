## Class Definitions

All classes should be pre-defined with clear interfaces and inheritance hierarchies:

### Core Classes

```typescript
// src/domains/core/Entity.ts
import { ID } from '../../types/core';

/**
 * Base entity class for all game objects
 */
export abstract class Entity {
  protected _id: ID;
  
  constructor(id: ID) {
    this._id = id;
  }
  
  get id(): ID {
    return this._id;
  }
  
  abstract update(deltaTime: number): void;
}
```

### Particle System Classes

```typescript
// src/domains/particle/ParticleSystem.ts
import { Entity } from '../core/Entity';
import { Particle, ParticleGroup } from '../../types/particle';
import { ForceRuleMatrix, ForceField } from '../../types/physics';
import { Vector3 } from '../../types/core';

/**
 * Manages all particles and their interactions
 */
export class ParticleSystem extends Entity {
  private _particles: Particle[];
  private _groups: ParticleGroup[];
  private _forceRules: ForceRuleMatrix;
  private _forceFields: ForceField[];
  
  constructor(
    id: string,
    particles: Particle[],
    groups: ParticleGroup[],
    forceRules: ForceRuleMatrix,
    forceFields: ForceField[]
  ) {
    super(id);
    this._particles = particles;
    this._groups = groups;
    this._forceRules = forceRules;
    this._forceFields = forceFields;
  }
  
  get particles(): Particle[] {
    return [...this._particles];
  }
  
  get groups(): ParticleGroup[] {
    return [...this._groups];
  }
  
  get forceRules(): ForceRuleMatrix {
    return { ...this._forceRules };
  }
  
  get forceFields(): ForceField[] {
    return [...this._forceFields];
  }
  
  update(deltaTime: number): void {
    // Update particles based on forces
    // Implementation will be provided in the actual class
  }
  
  addParticle(particle: Particle): void {
    this._particles.push(particle);
  }
  
  removeParticle(particleId: string): void {
    const index = this._particles.findIndex(p => p.id === particleId);
    if (index !== -1) {
      this._particles.splice(index, 1);
    }
  }
  
  updateForceRules(forceRules: ForceRuleMatrix): void {
    this._forceRules = { ...forceRules };
  }
}
```

### Physics Engine Classes

```typescript
// src/domains/physics/PhysicsEngine.ts
import { Entity } from '../core/Entity';
import { Particle } from '../../types/particle';
import { ForceRuleMatrix, ForceField } from '../../types/physics';
import { Vector3 } from '../../types/core';

/**
 * Handles physics calculations for the particle system
 */
export class PhysicsEngine extends Entity {
  private _cutoffDistance: number;
  private _timeScale: number;
  private _viscosity: number;
  private _collisionRadius: number;
  
  constructor(
    id: string,
    cutoffDistance: number = 100,
    timeScale: number = 0.8,
    viscosity: number = 0.1,
    collisionRadius: number = 0.5
  ) {
    super(id);
    this._cutoffDistance = cutoffDistance;
    this._timeScale = timeScale;
    this._viscosity = viscosity;
    this._collisionRadius = collisionRadius;
  }
  
  update(deltaTime: number): void {
    // Update physics state
    // Implementation will be provided in the actual class
  }
  
  calculateForces(
    particles: Particle[],
    forceRules: ForceRuleMatrix,
    forceFields: ForceField[]
  ): void {
    // Calculate forces between particles
    // Implementation will be provided in the actual class
  }
  
  applyForceFields(
    particles: Particle[],
    forceFields: ForceField[]
  ): void {
    // Apply force field influences
    // Implementation will be provided in the actual class
  }
  
  handleCollisions(particles: Particle[]): void {
    // Handle collisions between particles
    // Implementation will be provided in the actual class
  }
}
```

### Creature Class

```typescript
// src/domains/creature/Creature.ts
import { Entity } from '../core/Entity';
import { ParticleSystem } from '../particle/ParticleSystem';
import { PhysicsEngine } from '../physics/PhysicsEngine';
import { BlockInfo } from '../../types/core';

/**
 * Represents a complete creature with its particle system and physics
 */
export class Creature extends Entity {
  private _blockInfo: BlockInfo;
  private _particleSystem: ParticleSystem;
  private _physicsEngine: PhysicsEngine;
  private _age: number;
  private _mutations: string[];
  
  constructor(
    id: string,
    blockInfo: BlockInfo,
    particleSystem: ParticleSystem,
    physicsEngine: PhysicsEngine
  ) {
    super(id);
    this._blockInfo = blockInfo;
    this._particleSystem = particleSystem;
    this._physicsEngine = physicsEngine;
    this._age = 0;
    this._mutations = [];
  }
  
  get blockInfo(): BlockInfo {
    return { ...this._blockInfo };
  }
  
  get particleSystem(): ParticleSystem {
    return this._particleSystem;
  }
  
  get physicsEngine(): PhysicsEngine {
    return this._physicsEngine;
  }
  
  get age(): number {
    return this._age;
  }
  
  get mutations(): string[] {
    return [...this._mutations];
  }
  
  update(deltaTime: number): void {
    // Update age
    this._age += deltaTime;
    
    // Update physics
    this._physicsEngine.calculateForces(
      this._particleSystem.particles,
      this._particleSystem.forceRules,
      this._particleSystem.forceFields
    );
    
    // Update particle system
    this._particleSystem.update(deltaTime);
    
    // Check for mutations based on confirmations
    this.checkForMutations();
  }
  
  private checkForMutations(): void {
    // Check if new mutations should be applied based on confirmations
    // Implementation will be provided in the actual class
  }
}
```
