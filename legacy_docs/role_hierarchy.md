# Role Hierarchy System

## Overview

The Role Hierarchy System defines the relationships between different types of particles and force fields within the particle ecosystem. This hierarchy determines:

- Which roles can influence other roles
- How particles and force fields interact based on their roles
- The visual and behavioral characteristics of each role

## Core Concepts

### Particle Roles

Particles are assigned specific roles that define their behavior, appearance, and interactions:

```typescript
enum ParticleRole {
  CORE = 'core',       // Acts as the nucleus
  CONTROL = 'control', // Acts as the head/brain
  ATTACK = 'attack',   // Patrols the perimeter
  DEFENSE = 'defense', // Surrounds like a membrane
  MOVEMENT = 'movement' // Acts like a fin or phylange
}
```

### Role Relationships

The hierarchy defines which roles can influence others:

1. **Dominance Relationships**:
   - CORE influences all other roles
   - CONTROL influences ATTACK, DEFENSE, and MOVEMENT
   - DEFENSE protects CORE from external forces
   - ATTACK influences external entities
   - MOVEMENT determines overall direction

2. **Protective Relationships**:
   - DEFENSE primarily protects CORE
   - ATTACK secondarily protects all other roles
   - CORE strengthens all other roles

3. **Movement Relationships**:
   - CONTROL directs MOVEMENT
   - MOVEMENT propels the entire structure
   - ATTACK can adjust position based on external threats

## Force Field Role Enforcement

Force fields enforce role hierarchy through:

### 1. Containment Rules

- A force field can only contain particles of roles it can influence
- Example: A CORE force field can contain particles of all roles

```typescript
function canContain(fieldRole: ParticleRole, particleRole: ParticleRole): boolean {
  switch (fieldRole) {
    case ParticleRole.CORE:
      return true; // Can contain any role
    case ParticleRole.CONTROL:
      return particleRole !== ParticleRole.CORE;
    case ParticleRole.DEFENSE:
      return particleRole === ParticleRole.DEFENSE;
    case ParticleRole.ATTACK:
      return particleRole === ParticleRole.ATTACK;
    case ParticleRole.MOVEMENT:
      return particleRole === ParticleRole.MOVEMENT;
    default:
      return false;
  }
}
```

### 2. Influence Strength

- The strength of influence decreases with role distance in the hierarchy
- CORE has strongest influence on all roles

```typescript
function getInfluenceStrength(fieldRole: ParticleRole, particleRole: ParticleRole): number {
  if (!canContain(fieldRole, particleRole)) return 0;
  
  // Define strength based on role relationship
  if (fieldRole === ParticleRole.CORE) {
    if (particleRole === ParticleRole.CORE) return 1.0;
    if (particleRole === ParticleRole.CONTROL) return 0.9;
    return 0.8; // Other roles
  }
  
  if (fieldRole === ParticleRole.CONTROL) {
    if (particleRole === ParticleRole.MOVEMENT) return 0.9;
    if (particleRole === ParticleRole.ATTACK) return 0.8;
    return 0.7; // DEFENSE
  }
  
  // Same role interactions
  return 0.6;
}
```

## Force Matrix

Interactions between particles of different roles are governed by a force matrix that determines attraction and repulsion:

```
                  | Core | Control | Movement | Defense | Attack
--------------------|------|---------|----------|---------|--------
Core particle       | +0.5 |   +0.8  |   +0.3   |   +0.2  |  -0.1
Control particle    | +0.8 |   +0.3  |   +0.6   |   +0.4  |  +0.2
Movement particle   | +0.3 |   +0.6  |   +0.2   |   +0.3  |  +0.5
Defense particle    | +0.2 |   +0.4  |   +0.3   |   +0.4  |  +0.7
Attack particle     | -0.1 |   +0.2  |   +0.5   |   +0.7  |  +0.3
```

Positive values indicate attraction, negative values indicate repulsion, and the magnitude represents the strength of the interaction.

## Visual Representations

Each role has distinct visual characteristics:

1. **CORE**:
   - Dense, central polygonal force field
   - Brightest illumination
   - Distinctive color based on blockchain signature data

2. **CONTROL**:
   - Gyroscopic polygonal force field (rotating in 3D)
   - Orbits around the CORE at a slight distance
   - Bright illumination with dynamic effects

3. **DEFENSE**:
   - Regular polygon force field surrounding the CORE
   - Medium illumination
   - Semi-transparent protective boundary

4. **ATTACK**:
   - Angular polygon force fields
   - Bright, sharper illumination
   - Positioned at strategic locations around the structure

5. **MOVEMENT**:
   - Elongated polygon force fields
   - Subtle illumination with directional indicators
   - Positioned at the periphery like fins or phylanges

## Gyroscopic Movement

The CONTROL force field demonstrates leadership through its unique gyroscopic movement pattern:

1. The CONTROL force field rotates around its center point in 3D space
2. This rotation creates a constantly changing polygonal boundary
3. The movement is deterministic, based on blockchain data
4. The CONTROL field orbits around the CORE
5. Other fields follow the direction established by CONTROL

```typescript
function updateGyroscopicRotation(field: ForceField, timestep: number): void {
  if (field.role !== ParticleRole.CONTROL) return;
  
  // Update rotation angles based on deterministic parameters
  field.rotationX += field.rotationSpeed.x * timestep;
  field.rotationY += field.rotationSpeed.y * timestep;
  field.rotationZ += field.rotationSpeed.z * timestep;
  
  // Apply rotation to each vertex
  applyRotationMatrix(field.vertices, field.rotationX, field.rotationY, field.rotationZ);
}
```

## Implementation Guidelines

When implementing the role hierarchy:

1. Always check role compatibility before processing interactions
2. Ensure visual distinctions between roles are clear and consistent
3. Maintain the deterministic nature of all role-based behaviors
4. Balance the influence strengths to create engaging emergent behaviors
5. Use the role system to drive meaningful interactions in the particle system

## Deterministic Generation

All role distributions and behaviors should be generated deterministically from Bitcoin block data:

```typescript
function determineRoleFromBlockData(particleId: string, blockData: BlockData): ParticleRole {
  // Use particle ID and block data to deterministically assign role
  const hash = deterministicHash(particleId + blockData.merkleRoot);
  const value = normalizeHash(hash, 0, 100);
  
  if (value < 10) return ParticleRole.CORE;      // 10% chance
  if (value < 25) return ParticleRole.CONTROL;   // 15% chance
  if (value < 45) return ParticleRole.ATTACK;    // 20% chance
  if (value < 70) return ParticleRole.DEFENSE;   // 25% chance
  return ParticleRole.MOVEMENT;                  // 30% chance
}
```
