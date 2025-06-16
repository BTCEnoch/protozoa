# System Architecture

## High-Level Architecture
Beast Import is designed with a modular, scalable architecture that consists of several interconnected systems:

```
┌─────────────────────────────────────────────────────────────┐
│                     Beast Import Platform                    │
├─────────────┬─────────────┬────────────────┬────────────────┤
│   Particle  │  Bitcoin    │    Physics     │    Memory      │
│   Ecosystem │ Integration │    Engine      │   Management   │
├─────────────┼─────────────┼────────────────┼────────────────┤
│   Worker    │    State    │  Development   │   Rendering    │
│   System    │ Management  │    Tools       │ Optimization   │
└─────────────┴─────────────┴────────────────┴────────────────┘
```

## Core Components

### 1. Particle Ecosystem
- Role-based particle system (CORE, CONTROL, MOVEMENT, DEFENSE, ATTACK)
- Deterministic trait generation using nonce-based RNG
- Instanced rendering for 500 particles
- Force field-based interactions
- Spring-based motion with noise perturbation
- Emergent behaviors (flocking, pulsation, rotation, oscillation, bifurcation)

### 2. Blockchain Integration
- Bitcoin Ordinals protocol for deployment
- Block data retrieval from ordinals.com API
- Nonce-based deterministic RNG
- Confirmation-based evolution mechanics
- Recursive inscription for dependencies
- Immutable deployment on Bitcoin

### 3. Physics Engine
- Invisible polygonal force fields
- Gyroscopic rotation for force fields
- Verlet integration for stable physics
- Role-based attraction/repulsion matrix
- Spatial partitioning for efficient collision detection
- Frustum culling for performance optimization

### 4. Memory Management
- Object pooling for Vector3, particles, and matrices
- Memory monitoring system with utilization metrics
- Comprehensive resource cleanup strategy
- Memory leak prevention through tracking
- Typed arrays for efficient data storage
- Shared geometry and materials for performance

### 5. Worker System
- Separate worker pools for physics, rendering, and data
- Priority-based task queue system
- Load balancing across available CPU cores
- Transferable objects for efficient data transfer
- Performance monitoring and metrics
- Adaptive worker allocation based on system capabilities

### 6. State Management
- Zustand for lightweight state management
- Immutable state updates with Immer
- Component memoization to prevent unnecessary re-renders
- Throttled updates based on priority
- Efficient animation loop with delta time clamping

### 7. Development Tools
- Comprehensive development UI for testing
- Performance monitoring and metrics visualization
- Parameter adjustment interface
- Preset system for saving and loading configurations
- Visual debugging tools for force fields and physics

### 8. Rendering Optimization
- Instanced mesh rendering for particles
- Efficient material management and sharing
- Geometry optimization and merging
- Custom shaders for visual effects
- Proper resource cleanup and disposal
- WebGL context optimization

## Integration Points

### Component Communication
- Event-based communication between systems
- Shared memory for efficient data exchange
- Worker message passing for parallel processing
- React component composition and props

### External Integration
- Bitcoin block data retrieval from ordinals.com API
- Dependency loading from inscription IDs
- Development/production environment switching
- Local caching for development testing
