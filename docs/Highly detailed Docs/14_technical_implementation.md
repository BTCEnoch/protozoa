# Technical Implementation

Based on our discussions and the research document, this document outlines the technical implementation approach for the Beast Import project.

## Core Technology Stack

### Frontend Framework
- **React**: Primary UI framework
- **React Three Fiber**: React bindings for Three.js
- **React Three Drei**: Helper components for React Three Fiber

### 3D Rendering
- **Three.js**: Core 3D rendering engine
- **InstancedMesh**: For efficient particle rendering (500 particles)
- **Custom Shaders**: For advanced visual effects
- **WebGL Optimizations**: Frustum culling, renderer configuration

### State Management
- **Zustand**: Lightweight state management library (confirmed)
- **Immer**: For immutable state updates
- **Component Memoization**: Prevent unnecessary re-renders

### Build System
- **Vite**: Fast, modern build tool (confirmed)
- **TypeScript**: For type safety during development (confirmed)
- **ESBuild**: For efficient bundling and minification

### Testing Framework
- **Vitest**: Testing framework designed for Vite (confirmed)
- **React Testing Library**: For testing React components

### Performance Optimization
- **Web Workers**: Separate pools for physics, rendering, and data processing
- **Memory Pooling**: Object reuse for Vector3, particles, and matrices
- **Spatial Partitioning**: Grid-based system for efficient collision detection

## Performance Optimization Strategies

### React Three Fiber Optimization Patterns

#### 1. Instanced Meshes for Particles

The most significant rendering optimization will be the use of `THREE.InstancedMesh` instead of individual meshes for particles:

```typescript
// Use instanced meshes instead of individual meshes
const instancedMesh = new THREE.InstancedMesh(
  geometry,
  material,
  particleCount
);

// Use a single dummy object for matrix updates
const dummy = new THREE.Object3D();

// Batch update matrices
for (let i = 0; i < particleCount; i++) {
  dummy.position.copy(particles[i].position);
  dummy.updateMatrix();
  instancedMesh.setMatrixAt(i, dummy.matrix);
}

// Only update buffer once per frame
instancedMesh.instanceMatrix.needsUpdate = true;
```

Benefits:
- Reduced draw calls (5 calls for all roles instead of 500 for individual particles)
- GPU efficiency through batched rendering
- Memory efficiency by sharing geometry and material
- Better scaling for future expansion

#### 2. Efficient Animation Loop

```typescript
useEffect(() => {
  if (!isInitialized) return;

  let frameId: number;
  let lastTime = 0;

  const animate = (time: number) => {
    frameId = requestAnimationFrame(animate);

    // Calculate delta time in seconds
    const delta = (time - lastTime) / 1000;
    lastTime = time;

    // Skip if delta is too large (tab was inactive)
    const clampedDelta = Math.min(delta, 100);

    // Execute render callbacks
    renderCallbacks.current.forEach(callback => {
      callback(clampedDelta);
    });

    // Render scene
    renderer.current.render(scene.current, camera.current);
  };

  frameId = requestAnimationFrame(animate);

  return () => cancelAnimationFrame(frameId);
}, [isInitialized]);
```

#### 3. Geometry Merging for Static Elements

```typescript
// Merge geometries for static elements like grid lines
const gridLines = [];
// ... create individual line geometries
const mergedGrid = BufferGeometryUtils.mergeGeometries(gridLines);
```

#### 4. Efficient Material Management

```typescript
// Create materials once and reuse
const materials = useMemo(() => {
  const mats: { [key: string]: THREE.MeshStandardMaterial } = {};
  colors.forEach(color => {
    mats[color] = new THREE.MeshStandardMaterial({
      color: color,
      emissive: color,
      emissiveIntensity: 0.5,
      toneMapped: false
    });
  });
  return mats;
}, [colors]);
```

#### 5. Proper Cleanup

```typescript
// Clean up resources properly
return () => {
  // Stop animation loop
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }

  // Dispose controls
  if (controlsRef.current?.dispose) {
    controlsRef.current.dispose();
  }

  // Dispose renderer
  renderer.dispose();

  // Clear scene
  while (scene.children.length > 0) {
    const object = scene.children[0];
    scene.remove(object);
  }
};
```

#### 6. Component Memoization

```typescript
// Memoize context value
const contextValue = useMemo(() => ({
  isInitialized,
  isLoading,
  error,
  scene: sceneRef.current,
  camera: cameraRef.current,
  renderer: rendererRef.current,
  particleGroup: particleGroupRef.current,
  controls: controlsRef.current,
  registerRenderCallback,
  unregisterRenderCallback,
}), [isInitialized, isLoading, error, registerRenderCallback, unregisterRenderCallback]);
```

### Fixed Timestep Physics

We'll implement a fixed timestep for physics calculations to ensure consistent simulation regardless of framerate:

```javascript
const PHYSICS_TIMESTEP = 1000 / 60; // 60 fps physics
let physicsAccumulator = 0;

// In animation loop:
physicsAccumulator += adjustedDelta;
while (physicsAccumulator >= PHYSICS_TIMESTEP) {
  particleSystemService().update(PHYSICS_TIMESTEP);
  physicsAccumulator -= PHYSICS_TIMESTEP;
}
```

### Memory Management

We'll implement several memory optimization techniques:

1. **Object Pooling**: Reusing objects to reduce garbage collection
   ```typescript
   // Get a Vector3 from the pool
   const position = vector3Pool.get();
   position.x = 10;
   position.y = 20;
   position.z = 30;

   // When done with it, return it to the pool
   vector3Pool.release(position);
   ```

2. **Typed Arrays**: Using typed arrays for large datasets
   ```typescript
   const positionArray = new Float32Array(particleCount * 3);
   // Update particles
   for (let i = 0; i < particleCount; i++) {
     const index = i * 3;
     positionArray[index] = x;     // x
     positionArray[index + 1] = y; // y
     positionArray[index + 2] = z; // z
   }
   ```

3. **Shared Geometry and Materials**: Using one geometry and material per particle role

### Spatial Partitioning

To optimize collision detection and force field calculations, we'll implement a grid-based spatial partitioning system:

```typescript
const grid = new SpatialGrid(cellSize, worldBounds);

// Add particles to the grid
particles.forEach(particle => {
  grid.addParticle(particle);
});

// For each particle, only check nearby particles
particles.forEach(particle => {
  const nearbyParticles = grid.getNearbyParticles(particle.position);
  // Check interactions with nearby particles only
});
```

## Web Workers Implementation

We'll use Web Workers to move physics calculations to a separate thread, preventing UI freezing:

```typescript
// Main thread
const physicsWorker = new Worker('./physicsWorker.ts');
physicsWorker.postMessage({
  type: 'UPDATE',
  deltaTime: 16.7 // ms for 60fps
});

physicsWorker.onmessage = (e) => {
  const { particleData } = e.data;
  // Update renderer with new particle positions
};

// Physics worker thread
self.onmessage = (e) => {
  const { type, deltaTime } = e.data;
  if (type === 'UPDATE') {
    // Update particle positions based on physics
    self.postMessage({
      particleData: serializeParticles(particles)
    });
  }
};
```

### Data Transfer Optimization

When sending data between threads, we'll minimize structured cloning:

```typescript
// Send just the necessary data
const positions = new Float32Array(particles.length * 3);
// Fill positions array
worker.postMessage({ positions }, [positions.buffer]); // Transfer ownership of the buffer
```

## React Optimizations

### Component Optimization

```typescript
// Memoize components
const ParticleRenderer = React.memo(({ particles }) => {
  // Render particles
});

// Memoize callbacks
const handleClick = useCallback(() => {
  // Handle click
}, [dependencies]);
```

### Custom Hooks for Shared Logic

```typescript
function useParticles(blockData) {
  const [particles, setParticles] = useState([]);

  useEffect(() => {
    // Generate particles based on block data
  }, [blockData]);

  return particles;
}
```

### Throttled Updates

Not every component needs to update at 60fps. Updates will be throttled based on importance:

```typescript
// High-priority updates (60fps)
useFrame(() => {
  updateParticlePositions();
});

// Medium-priority updates (30fps)
useFrame(({ clock }) => {
  if (Math.floor(clock.getElapsedTime() * 30) % 2 === 0) {
    updateForceFields();
  }
});

// Low-priority updates (10fps)
useFrame(({ clock }) => {
  if (Math.floor(clock.getElapsedTime() * 10) % 6 === 0) {
    updateUI();
  }
});
```

## Force Field Optimizations

### Gyroscopic Movement Optimization

```typescript
// Pre-compute rotation matrices for gyroscopic movement
const rotationCache = new Map<string, THREE.Matrix4[]>();

function precomputeRotations(field: ForceField, steps: number): void {
  const rotations: THREE.Matrix4[] = [];
  const quaternion = new THREE.Quaternion();
  const axis = field.rotation.axis;

  // Pre-compute rotation steps
  for (let i = 0; i < steps; i++) {
    const angle = (field.rotation.speed * i) % (Math.PI * 2);
    quaternion.setFromAxisAngle(axis, angle);
    const matrix = new THREE.Matrix4().makeRotationFromQuaternion(quaternion);
    rotations.push(matrix);
  }

  rotationCache.set(field.id, rotations);
}
```

### Containment Testing Optimization

```typescript
// First do a quick bounding sphere check
const distSq = particle.position.distanceToSquared(field.center);
if (distSq > field.boundingSphereRadiusSq) {
  // Particle is outside the bounding sphere, definitely outside the field
  return false;
}

// Only if inside the bounding sphere, do the more expensive polygon containment test
return isPointInPolygon(particle.position, field.vertices);
```

## Module Structure

The application will be organized into the following module structure:

```
src/
├── components/         # React components
│   ├── ui/             # UI components
│   └── three/          # Three.js components
├── services/           # Core services
│   ├── particle/       # Particle system
│   ├── forceField/     # Force field system
│   ├── physics/        # Physics engine
│   ├── rng/            # RNG system
│   └── bitcoin/        # Bitcoin integration
├── workers/            # Web Workers
│   └── physics/        # Physics worker
├── utils/              # Utility functions
├── hooks/              # Custom React hooks
├── types/              # TypeScript types
└── constants/          # Constants and configuration
```

## Development vs. Production

### Development Build
- Includes full development UI
- Comprehensive debugging tools
- Performance monitoring
- Parameter adjustment interfaces
- Hot module replacement for fast iteration

### Production Build
- Stripped of all development UI and tools
- Optimized for size and performance
- Minimal, focused UI for end-users
- No debugging or development features
- Ready for Bitcoin inscription

## Testing Strategy

1. **Unit Tests**: For core algorithms and utilities
2. **Integration Tests**: For service interactions
3. **Visual Tests**: For rendering and visual effects
4. **Performance Tests**: For measuring and optimizing performance
5. **Browser Compatibility Tests**: For ensuring cross-browser support

## Implementation Plan

1. **Core Framework Setup**: React, Three.js, and build system
2. **Basic Particle System**: Simple particle rendering and physics
3. **Force Field Implementation**: Polygonal force fields with basic interactions
4. **Role Hierarchy**: Implement the five particle roles and their relationships
5. **RNG System**: Bitcoin-based deterministic random number generation
6. **Development UI**: Comprehensive UI for testing and parameter adjustment
7. **Optimization**: Performance optimization and memory management
8. **Production Build**: Prepare for Bitcoin inscription

This technical implementation approach leverages modern web technologies and optimization techniques to create a high-performance particle system that can be deployed on Bitcoin through the Ordinals protocol.
