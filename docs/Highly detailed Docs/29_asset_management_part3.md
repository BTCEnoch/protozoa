## Function Definitions

All key functions should be pre-defined with clear signatures and documentation:

### Utility Functions

```typescript
// src/utils/vectorUtils.ts
import { Vector3 } from '../types/core';

/**
 * Create a new Vector3
 */
export function createVector3(x: number = 0, y: number = 0, z: number = 0): Vector3 {
  return { x, y, z };
}

/**
 * Add two vectors
 */
export function addVectors(a: Vector3, b: Vector3): Vector3 {
  return {
    x: a.x + b.x,
    y: a.y + b.y,
    z: a.z + b.z
  };
}

/**
 * Subtract vector b from vector a
 */
export function subtractVectors(a: Vector3, b: Vector3): Vector3 {
  return {
    x: a.x - b.x,
    y: a.y - b.y,
    z: a.z - b.z
  };
}

/**
 * Multiply vector by scalar
 */
export function multiplyVector(vector: Vector3, scalar: number): Vector3 {
  return {
    x: vector.x * scalar,
    y: vector.y * scalar,
    z: vector.z * scalar
  };
}

/**
 * Calculate distance between two vectors
 */
export function distance(a: Vector3, b: Vector3): number {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  const dz = a.z - b.z;
  return Math.sqrt(dx * dx + dy * dy + dz * dz);
}

/**
 * Calculate squared distance between two vectors (more efficient)
 */
export function distanceSquared(a: Vector3, b: Vector3): number {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  const dz = a.z - b.z;
  return dx * dx + dy * dy + dz * dz;
}

/**
 * Normalize a vector (make it unit length)
 */
export function normalizeVector(vector: Vector3): Vector3 {
  const length = Math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
  if (length === 0) return { x: 0, y: 0, z: 0 };
  return {
    x: vector.x / length,
    y: vector.y / length,
    z: vector.z / length
  };
}
```

### RNG Functions

```typescript
// src/utils/rngUtils.ts

/**
 * Mulberry32 RNG function
 * @param seed - Numeric seed value
 * @returns A function that returns a random number between 0 and 1
 */
export function mulberry32(seed: number): () => number {
  return function() {
    let t = seed += 0x6D2B79F5;
    t = Math.imul(t ^ t >>> 15, t | 1);
    t ^= t + Math.imul(t ^ t >>> 7, t | 61);
    return ((t ^ t >>> 14) >>> 0) / 4294967296;
  };
}

/**
 * Generate a random integer between min and max (inclusive)
 */
export function randomInt(random: () => number, min: number, max: number): number {
  return Math.floor(random() * (max - min + 1)) + min;
}

/**
 * Generate a random float between min and max
 */
export function randomFloat(random: () => number, min: number, max: number): number {
  return random() * (max - min) + min;
}

/**
 * Choose a random item from an array
 */
export function randomChoice<T>(random: () => number, array: T[]): T {
  return array[Math.floor(random() * array.length)];
}

/**
 * Shuffle an array using Fisher-Yates algorithm
 */
export function shuffleArray<T>(random: () => number, array: T[]): T[] {
  const result = [...array];
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}
```

### Factory Functions

```typescript
// src/factories/particleFactory.ts
import { Particle, ParticleRole, ParticleShape, ParticleGroup } from '../types/particle';
import { Vector3, ID } from '../types/core';
import { createVector3 } from '../utils/vectorUtils';
import { mulberry32, randomFloat, randomChoice } from '../utils/rngUtils';

/**
 * Create a new particle
 */
export function createParticle(
  id: ID,
  position: Vector3,
  velocity: Vector3,
  role: ParticleRole,
  group: number,
  shape: ParticleShape,
  color: string,
  scale: number = 1,
  mass: number = 1
): Particle {
  return {
    id,
    position,
    velocity,
    acceleration: createVector3(),
    role,
    group,
    shape,
    color,
    scale,
    mass,
    age: 0,
    active: true
  };
}

/**
 * Generate particles for a group
 */
export function generateParticlesForGroup(
  nonce: number,
  group: ParticleGroup,
  startId: number,
  centerPosition: Vector3,
  radius: number
): Particle[] {
  const random = mulberry32(nonce + group.id);
  const particles: Particle[] = [];
  
  for (let i = 0; i < group.count; i++) {
    const angle1 = randomFloat(random, 0, Math.PI * 2);
    const angle2 = randomFloat(random, 0, Math.PI);
    
    const x = centerPosition.x + radius * Math.sin(angle2) * Math.cos(angle1);
    const y = centerPosition.y + radius * Math.sin(angle2) * Math.sin(angle1);
    const z = centerPosition.z + radius * Math.cos(angle2);
    
    const position = createVector3(x, y, z);
    const velocity = createVector3(
      randomFloat(random, -0.1, 0.1),
      randomFloat(random, -0.1, 0.1),
      randomFloat(random, -0.1, 0.1)
    );
    
    const id = `${group.id}-${startId + i}`;
    
    particles.push(createParticle(
      id,
      position,
      velocity,
      group.role,
      group.id,
      group.shape,
      group.color,
      group.scale,
      1.0
    ));
  }
  
  return particles;
}
```
