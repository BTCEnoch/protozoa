# Force Field System

## Overview

The Force Field System is a core component that creates emergent behaviors in the particle simulation. Force fields create containment areas, guide particle movement, and enforce role-based interactions between particles. The force fields will be invisible in the final rendering but will play a crucial role in creating organic, cellular organism-like behaviors through a hybrid approach combining force fields and role-specific formations.

## Key Concepts

### Gyroscopic Polygon Force Fields

Force fields are implemented as 3D polygonal shapes that rotate independently around multiple axes, creating complex orbital patterns that influence particle movement:

- Fields rotate around X, Y, and Z axes simultaneously
- Rotation speeds vary by field role
- Orbits follow hierarchical patterns based on role importance
- Field shapes are polygonal for most roles, with the core using a spherical shape

### Role Hierarchy Integration

Force fields enforce the role hierarchy system through:

1. **Core Field** (smallest): Acts as the nucleus/center point
2. **Control Field** (small): Orbits close to the core, acts as the "head"
3. **Movement Field** (medium): Positioned like fins or phylanges
4. **Defense Field** (large): Creates a membrane-like boundary
5. **Attack Field** (largest): Patrols the perimeter

This hierarchy is reflected in field scaling, with each level being proportionally larger than the previous.

## Force Field Types and Behaviors

### CORE Force Fields
- Dense, central polygonal force field
- Minimal movement for visual interest
- Can contain particles of all roles
- Highest influence strength
- Brightest illumination
- Central position in the creature structure

### CONTROL Force Fields
- Feature gyroscopic 3D rotation
- Orbit around the CORE
- Can influence ATTACK, DEFENSE, and MOVEMENT
- High influence strength
- Distinctive visual appearance with dynamic effects
- Direct the movement of the entire structure

### DEFENSE Force Fields
- Regular polygonal shapes forming a membrane
- Position themselves around the CORE
- Primarily contain DEFENSE particles
- Medium influence strength
- Semi-transparent protective boundary
- Form protective barriers around the core structure

### ATTACK Force Fields
- Angular polygonal shapes
- Patrol the perimeter of the structure
- Contain ATTACK particles
- Medium-high influence strength
- Bright, sharper illumination
- Positioned at strategic locations

### MOVEMENT Force Fields
- Elongated polygonal shapes
- Position themselves as fins or phylanges
- Contain MOVEMENT particles
- Medium influence strength
- Subtle directional indicators
- Determine the overall movement direction

## Implementation Details

### Force Field Structure

```typescript
interface ForceField {
  id: string;
  role: ParticleRole;
  center: Vector3;
  vertices: Vector3[];
  baseVertices: Vector3[];  // Original vertices before rotation
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
  associatedFieldId?: string;  // Parent field in hierarchy
}
```

### Gyroscopic Rotation Implementation

The gyroscopic rotation is implemented through matrix transformations:

```typescript
// Calculate rotation matrices
const rotationX = createRotationMatrixX(angleX);
const rotationY = createRotationMatrixY(angleY);
const rotationZ = createRotationMatrixZ(angleZ);

// Apply to each vertex
for (let i = 0; i < field.vertices.length; i++) {
  const baseVertex = field.baseVertices[i];

  // Translate to origin
  const translated = baseVertex.clone().subtract(field.center);

  // Apply rotations
  let rotated = translated;
  rotated = rotationX.multiplyVector(rotated);
  rotated = rotationY.multiplyVector(rotated);
  rotated = rotationZ.multiplyVector(rotated);

  // Translate back
  rotated.add(field.center);

  // Update actual vertex
  field.vertices[i].copy(rotated);
}
```

## Spatial Optimization

For efficient containment testing, force fields use a specialized spatial index:

```typescript
class ForceFieldSpatialIndex {
  // Grid-based spatial partitioning for fields
  private grid: Map<string, ForceField[]>;
  private cellSize: number;

  // Quick lookup of fields that might contain a point
  getFieldsAtPoint(point: Vector3): ForceField[] {
    // Get grid cell coordinates
    const cellX = Math.floor(point.x / this.cellSize);
    const cellY = Math.floor(point.y / this.cellSize);

    // Check surrounding cells
    const potentialFields: ForceField[] = [];
    for (let x = cellX - 1; x <= cellX + 1; x++) {
      for (let y = cellY - 1; y <= cellY + 1; y++) {
        const cellKey = `${x},${y}`;
        const fieldsInCell = this.grid.get(cellKey) || [];
        potentialFields.push(...fieldsInCell);
      }
    }

    // Filter by bounding sphere first (fast test)
    return potentialFields.filter(field =>
      isPointInBoundingSphere(point, field.boundingSphere)
    );
  }
}
```

## Deterministic Generation

All force field properties are generated deterministically from Bitcoin block data:

```typescript
function determineForceFieldProperty(
  fieldId: string,
  property: string,
  blockData: BlockData
): number {
  const hash = deterministicHash(fieldId + property + blockData.merkleRoot);

  // Normalize the hash to a value between 0 and 1
  return normalizeHash(hash, 0, 1);
}
```

## Integration with Particle System

Force fields interact with particles through:

1. **Containment**: Fields exert forces on contained particles
2. **Role influence**: The strength of influence depends on role relationship
3. **Movement patterns**: Hierarchical relationships affect particle movement
4. **Visual effects**: Particles inherit visual properties from containing fields

## Performance Considerations

- Force fields use efficient mathematical models to calculate influence
- Spatial partitioning optimizes field-particle interaction checks
- Object pooling reduces memory allocation overhead
- The number of fields is typically small (5-10) compared to the number of particles (500+)

## Implementation Guidelines

When implementing the Force Field System:

1. Always generate fields deterministically from blockchain data
2. Maintain role hierarchy relationships through field associations
3. Optimize vertex operations through pooling and matrix pre-calculation
4. Use bounding spheres for quick containment testing
5. Apply spatial partitioning for efficient field lookup
6. Keep force fields invisible but functional in the final rendering
7. Implement role-specific formations within each force field
8. Use Verlet integration for stable physics simulation
9. Implement emergent behaviors (flocking, pulsation, rotation, oscillation, bifurcation)
10. Optimize for performance on average PC hardware
