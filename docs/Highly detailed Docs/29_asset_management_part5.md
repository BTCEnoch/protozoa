## Module Structure and Import/Export Chain

The import/export chain must be carefully planned to avoid circular dependencies and ensure proper loading order:

### Domain Module Structure

```
src/
├── domains/
│   ├── core/
│   │   ├── index.ts           # Public API
│   │   ├── Entity.ts          # Base entity class
│   │   └── ...
│   ├── particle/
│   │   ├── index.ts           # Public API
│   │   ├── ParticleSystem.ts  # Particle system class
│   │   └── ...
│   ├── physics/
│   │   ├── index.ts           # Public API
│   │   ├── PhysicsEngine.ts   # Physics engine class
│   │   └── ...
│   └── creature/
│       ├── index.ts           # Public API
│       ├── Creature.ts        # Creature class
│       └── ...
```

### Service Module Structure

```
src/
├── services/
│   ├── index.ts               # Public API
│   ├── coreService.ts         # Core service
│   ├── particleService.ts     # Particle service
│   ├── physicsService.ts      # Physics service
│   └── ...
```

### Utility Module Structure

```
src/
├── utils/
│   ├── index.ts               # Public API
│   ├── vectorUtils.ts         # Vector utilities
│   ├── rngUtils.ts            # RNG utilities
│   └── ...
```

### Factory Module Structure

```
src/
├── factories/
│   ├── index.ts               # Public API
│   ├── particleFactory.ts     # Particle factory
│   ├── forceFieldFactory.ts   # Force field factory
│   └── ...
```

### Type Module Structure

```
src/
├── types/
│   ├── index.ts               # Public API
│   ├── core.ts                # Core types
│   ├── particle.ts            # Particle types
│   ├── physics.ts             # Physics types
│   └── ...
```

### Import/Export Chain

To ensure proper loading and avoid circular dependencies, follow these guidelines:

1. **Types First**: Types should be imported before classes or functions
2. **Bottom-Up Imports**: Lower-level modules should not import higher-level modules
3. **Public APIs**: Always export through the domain's index.ts file
4. **Explicit Imports**: Always import specific items, not entire modules

Example of proper import/export chain:

```typescript
// src/domains/core/index.ts
export { Entity } from './Entity';
// Export other core domain items

// src/domains/particle/index.ts
export { ParticleSystem } from './ParticleSystem';
// Export other particle domain items

// src/domains/physics/index.ts
export { PhysicsEngine } from './PhysicsEngine';
// Export other physics domain items

// src/domains/creature/index.ts
export { Creature } from './Creature';
// Export other creature domain items
```

```typescript
// src/domains/creature/Creature.ts
import { Entity } from '../core';
import { ParticleSystem } from '../particle';
import { PhysicsEngine } from '../physics';
import { BlockInfo } from '../../types/core';

// Creature class implementation
```

## Asset Loading Strategy

### Synchronous vs. Asynchronous Loading

Determine which assets need to be loaded synchronously vs. asynchronously:

1. **Synchronous Loading**:
   - Core types and utilities
   - Essential services
   - Base classes

2. **Asynchronous Loading**:
   - Domain-specific modules
   - Visual assets
   - Non-critical services

### Dependency Graph

Create a dependency graph to visualize the loading order:

```
Types → Utils → Factories → Core Domain → Services → Other Domains → UI
```

### Lazy Loading

Implement lazy loading for non-critical assets:

```typescript
// src/domains/index.ts
export const loadParticleDomain = () => import('./particle');
export const loadPhysicsDomain = () => import('./physics');
export const loadCreatureDomain = () => import('./creature');

// Usage
const initializeParticleSystem = async () => {
  const { ParticleSystem } = await loadParticleDomain();
  return new ParticleSystem(/* ... */);
};
```

## Asset Versioning

### Version Tracking

Track versions of all assets to ensure compatibility:

```typescript
// src/version.ts
export const VERSION = {
  core: '1.0.0',
  particle: '1.0.0',
  physics: '1.0.0',
  creature: '1.0.0'
};

// Usage
import { VERSION } from './version';

if (VERSION.particle !== '1.0.0') {
  console.warn('Incompatible particle module version');
}
```

### Migration Strategy

Plan for asset migrations when versions change:

```typescript
// src/migrations/index.ts
export const migrations = {
  particle: {
    '0.9.0-to-1.0.0': (oldData) => {
      // Convert old data format to new format
      return newData;
    }
  }
};

// Usage
import { migrations } from './migrations';

const migrateData = (data, fromVersion, toVersion) => {
  const migrationKey = `${fromVersion}-to-${toVersion}`;
  if (migrations.particle[migrationKey]) {
    return migrations.particle[migrationKey](data);
  }
  return data;
};
```

## Conclusion

Proper asset management is crucial for the Beast Import project. By pre-defining all types, classes, functions, and mapping the import/export chain, we ensure a clean architecture and smooth integration with Bitcoin Ordinals. This approach minimizes dependencies, ensures deterministic loading, and provides a clear versioning strategy for all assets.

The asset management strategy outlined in this document should be followed throughout the development process to maintain code quality and ensure a successful deployment on Bitcoin Ordinals.
