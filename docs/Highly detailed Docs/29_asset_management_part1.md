# Asset Management

## Overview

This document outlines the asset management strategy for the Bitcoin Protozoa project, focusing on pre-defining types, classes, functions, and mapping the import/export chain. Proper asset management is crucial for maintaining a clean architecture and ensuring smooth integration with Bitcoin Ordinals.

## Core Principles

1. **Pre-definition**: All types, classes, and functions must be pre-defined before implementation
2. **Explicit imports/exports**: All module dependencies must be explicitly declared
3. **Minimal dependencies**: Keep external dependencies to a minimum
4. **Deterministic loading**: Ensure assets load in a predictable order
5. **Versioning**: Maintain clear versioning for all assets

## Type Definitions

### Core Types

All core types must be defined in a central location to ensure consistency across the application:

```typescript
// src/types/core.ts

/**
 * Vector3 type for 3D coordinates
 */
export type Vector3 = {
  x: number;
  y: number;
  z: number;
};

/**
 * Color type using hexadecimal string
 */
export type Color = string;

/**
 * Unique identifier type
 */
export type ID = string;

/**
 * Timestamp in milliseconds
 */
export type Timestamp = number;

/**
 * Bitcoin block information
 */
export type BlockInfo = {
  blockNumber: number;
  nonce: number;
  timestamp: Timestamp;
  hash: string;
  confirmations: number;
};
```

### Domain-Specific Types

Each domain should have its own type definitions:

```typescript
// src/types/particle.ts
import { Vector3, Color, ID } from './core';

/**
 * Particle roles
 */
export enum ParticleRole {
  CORE = 'core',
  CONTROL = 'control',
  ATTACK = 'attack',
  DEFENSE = 'defense',
  MOVEMENT = 'movement'
}

/**
 * Particle shape types
 */
export enum ParticleShape {
  SPHERE = 'sphere',
  CUBE = 'cube',
  TETRAHEDRON = 'tetrahedron',
  OCTAHEDRON = 'octahedron',
  DODECAHEDRON = 'dodecahedron',
  ICOSAHEDRON = 'icosahedron',
  TORUS = 'torus'
}

/**
 * Particle properties
 */
export type Particle = {
  id: ID;
  position: Vector3;
  velocity: Vector3;
  acceleration: Vector3;
  role: ParticleRole;
  group: number;
  shape: ParticleShape;
  color: Color;
  scale: number;
  mass: number;
  age: number;
  active: boolean;
};

/**
 * Particle group properties
 */
export type ParticleGroup = {
  id: number;
  role: ParticleRole;
  color: Color;
  shape: ParticleShape;
  count: number;
  scale: number;
};
```

```typescript
// src/types/physics.ts
import { Vector3, ID } from './core';
import { ParticleRole } from './particle';

/**
 * Force field type
 */
export type ForceField = {
  id: ID;
  role: ParticleRole;
  center: Vector3;
  vertices: Vector3[];
  baseVertices: Vector3[];
  boundingSphere: {
    center: Vector3;
    radius: number;
  };
  rotationSpeed?: {
    x: number;
    y: number;
    z: number;
  };
  color: string;
  strength: number;
  associatedFieldId?: ID;
  direction?: Vector3;
};

/**
 * Force rule matrix
 */
export type ForceRuleMatrix = {
  [sourceGroup: string]: {
    [targetGroup: string]: number;
  };
};
```
