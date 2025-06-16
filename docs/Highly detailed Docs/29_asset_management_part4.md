## Service Definitions

Services handle business logic and provide an interface between components:

### Core Services

```typescript
// src/services/coreService.ts
import { BlockInfo } from '../types/core';

/**
 * Core service interface
 */
export interface ICoreService {
  initialize(): Promise<void>;
  getBlockInfo(blockNumber: number): Promise<BlockInfo>;
  getCurrentBlock(): Promise<BlockInfo>;
}

/**
 * Implementation of core service
 */
export class CoreService implements ICoreService {
  private _initialized: boolean = false;
  private _currentBlock: BlockInfo | null = null;
  
  async initialize(): Promise<void> {
    if (this._initialized) return;
    
    try {
      // Initialize core service
      this._currentBlock = await this.fetchLatestBlock();
      this._initialized = true;
    } catch (error) {
      console.error('Failed to initialize core service:', error);
      throw error;
    }
  }
  
  async getBlockInfo(blockNumber: number): Promise<BlockInfo> {
    try {
      return await this.fetchBlockInfo(blockNumber);
    } catch (error) {
      console.error(`Failed to get block info for block ${blockNumber}:`, error);
      throw error;
    }
  }
  
  async getCurrentBlock(): Promise<BlockInfo> {
    if (!this._currentBlock) {
      this._currentBlock = await this.fetchLatestBlock();
    }
    return this._currentBlock;
  }
  
  private async fetchBlockInfo(blockNumber: number): Promise<BlockInfo> {
    // Implementation will fetch block info from API
    // Placeholder implementation
    return {
      blockNumber,
      nonce: 0,
      timestamp: Date.now(),
      hash: '',
      confirmations: 0
    };
  }
  
  private async fetchLatestBlock(): Promise<BlockInfo> {
    // Implementation will fetch latest block info
    // Placeholder implementation
    return {
      blockNumber: 0,
      nonce: 0,
      timestamp: Date.now(),
      hash: '',
      confirmations: 0
    };
  }
}

// Singleton instance
export const coreService = new CoreService();
```

### Particle Service

```typescript
// src/services/particleService.ts
import { ParticleSystem } from '../domains/particle/ParticleSystem';
import { Particle, ParticleGroup } from '../types/particle';
import { ForceRuleMatrix, ForceField } from '../types/physics';
import { BlockInfo } from '../types/core';
import { generateParticlesForGroup } from '../factories/particleFactory';
import { createVector3 } from '../utils/vectorUtils';

/**
 * Particle service interface
 */
export interface IParticleService {
  initialize(): Promise<void>;
  createParticleSystem(blockInfo: BlockInfo): Promise<ParticleSystem>;
  updateParticleSystem(particleSystem: ParticleSystem, deltaTime: number): void;
}

/**
 * Implementation of particle service
 */
export class ParticleService implements IParticleService {
  private _initialized: boolean = false;
  
  async initialize(): Promise<void> {
    if (this._initialized) return;
    
    try {
      // Initialize particle service
      this._initialized = true;
    } catch (error) {
      console.error('Failed to initialize particle service:', error);
      throw error;
    }
  }
  
  async createParticleSystem(blockInfo: BlockInfo): Promise<ParticleSystem> {
    // Generate groups, particles, force rules, and force fields
    const groups = this.generateGroups(blockInfo.nonce);
    const particles = this.generateParticles(blockInfo.nonce, groups);
    const forceRules = this.generateForceRules(blockInfo.nonce, groups);
    const forceFields = this.generateForceFields(blockInfo.nonce, groups);
    
    // Create and return particle system
    return new ParticleSystem(
      `ps-${blockInfo.blockNumber}`,
      particles,
      groups,
      forceRules,
      forceFields
    );
  }
  
  updateParticleSystem(particleSystem: ParticleSystem, deltaTime: number): void {
    particleSystem.update(deltaTime);
  }
  
  private generateGroups(nonce: number): ParticleGroup[] {
    // Implementation will generate particle groups
    // Placeholder implementation
    return [];
  }
  
  private generateParticles(nonce: number, groups: ParticleGroup[]): Particle[] {
    const particles: Particle[] = [];
    let startId = 0;
    
    for (const group of groups) {
      const centerPosition = createVector3(0, 0, 0);
      const groupParticles = generateParticlesForGroup(
        nonce,
        group,
        startId,
        centerPosition,
        50
      );
      
      particles.push(...groupParticles);
      startId += group.count;
    }
    
    return particles;
  }
  
  private generateForceRules(nonce: number, groups: ParticleGroup[]): ForceRuleMatrix {
    // Implementation will generate force rules
    // Placeholder implementation
    return {};
  }
  
  private generateForceFields(nonce: number, groups: ParticleGroup[]): ForceField[] {
    // Implementation will generate force fields
    // Placeholder implementation
    return [];
  }
}

// Singleton instance
export const particleService = new ParticleService();
```

### Physics Service

```typescript
// src/services/physicsService.ts
import { PhysicsEngine } from '../domains/physics/PhysicsEngine';
import { ParticleSystem } from '../domains/particle/ParticleSystem';

/**
 * Physics service interface
 */
export interface IPhysicsService {
  initialize(): Promise<void>;
  createPhysicsEngine(): PhysicsEngine;
  updatePhysics(particleSystem: ParticleSystem, physicsEngine: PhysicsEngine, deltaTime: number): void;
}

/**
 * Implementation of physics service
 */
export class PhysicsService implements IPhysicsService {
  private _initialized: boolean = false;
  
  async initialize(): Promise<void> {
    if (this._initialized) return;
    
    try {
      // Initialize physics service
      this._initialized = true;
    } catch (error) {
      console.error('Failed to initialize physics service:', error);
      throw error;
    }
  }
  
  createPhysicsEngine(): PhysicsEngine {
    return new PhysicsEngine(
      'physics-engine',
      100,  // cutoffDistance
      0.8,  // timeScale
      0.1,  // viscosity
      0.5   // collisionRadius
    );
  }
  
  updatePhysics(particleSystem: ParticleSystem, physicsEngine: PhysicsEngine, deltaTime: number): void {
    physicsEngine.calculateForces(
      particleSystem.particles,
      particleSystem.forceRules,
      particleSystem.forceFields
    );
    
    physicsEngine.applyForceFields(
      particleSystem.particles,
      particleSystem.forceFields
    );
    
    physicsEngine.handleCollisions(
      particleSystem.particles
    );
    
    physicsEngine.update(deltaTime);
  }
}

// Singleton instance
export const physicsService = new PhysicsService();
```
