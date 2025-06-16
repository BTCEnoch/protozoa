# Development UI

## Overview

The Development UI is a critical component during the development phase, providing a robust interface for testing, parameter adjustment, and visualization of the particle ecosystem. This UI will not be included in the final production version that will be inscribed on Bitcoin.

## Core Requirements

1. **Full Visualization**: Clear, full-screen view of the particle simulation
2. **Parameter Controls**: Interface to adjust and test different properties and variables
3. **Data Overlays**: Display of relevant metrics and system state
4. **Debugging Tools**: Visualization of force fields, collision detection, and other internal systems
5. **Preset Management**: Tools to create and save presets for trait assets

## UI Components

### Main Visualization Area

- Full-screen canvas for particle rendering
- Toggle for different visualization modes (normal, debug, wireframe)
- Camera controls for zooming, panning, and rotating
- Performance metrics overlay (FPS, particle count, etc.)

### Control Panel

- Collapsible sidebar for parameter adjustments
- Organized into logical sections (Physics, Particles, Force Fields, etc.)
- Real-time parameter adjustment with immediate visual feedback
- Preset saving and loading functionality

### Block Data Controls

- Block height input for deterministic creature generation
- Block data display (nonce, confirmations, etc.)
- Manual override options for testing specific scenarios
- Simulation of confirmation increases for evolution testing

### Role Management

- Visualization of role distribution
- Manual adjustment of role percentages for testing
- Color coding and filtering by role
- Role interaction matrix visualization and adjustment

### Force Field Editor

- Visual editor for force field shapes and properties
- Force field creation and deletion tools
- Adjustment of rotation parameters for gyroscopic fields
- Visualization of field influence areas

### Debug Visualization

- Toggle for force field boundaries
- Particle velocity and acceleration vectors
- Collision detection visualization
- Spatial partitioning grid display
- Energy level and interaction radius visualization

## Implementation Approach

### Component Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Development UI                       │
├─────────────┬─────────────┬────────────────┬────────────┤
│ Visualization│  Parameter  │   Debugging    │  Preset    │
│    Panel     │   Controls  │     Tools      │  Manager   │
├─────────────┼─────────────┼────────────────┼────────────┤
│             Simulation Engine Interface                  │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

- React for UI components
- Three.js for 3D visualization
- Custom parameter control components
- State management for UI state
- Event system for communication with simulation engine

### Parameter Categories

1. **Physics Parameters**
   - Gravity strength
   - Collision elasticity
   - Damping factors
   - Time step size

2. **Particle Parameters**
   - Size ranges by role
   - Color schemes
   - Energy consumption rates
   - Trail properties

3. **Force Field Parameters**
   - Field strengths
   - Rotation speeds
   - Vertex counts
   - Influence radii

4. **Role Parameters**
   - Role distribution percentages
   - Force matrix values
   - Visual characteristics by role
   - Behavioral properties

5. **System Parameters**
   - Memory pool size
   - Worker count
   - Spatial grid resolution
   - Rendering quality

## Preset System

The preset system allows saving and loading of parameter configurations:

```typescript
interface Preset {
  id: string;
  name: string;
  description: string;
  timestamp: number;
  parameters: {
    physics: PhysicsParams;
    particles: ParticleParams;
    forceFields: ForceFieldParams;
    roles: RoleParams;
    system: SystemParams;
  };
  blockData?: BlockInfo;
}
```

Presets can be:
- Saved to local storage
- Exported as JSON
- Imported from JSON
- Applied to the current simulation

## Development-Only Code Separation

To ensure clean separation between development and production code:

1. **Conditional Imports**:
   ```typescript
   // Only import in development mode
   import { DevUI } from './dev/ui';
   ```

2. **Feature Flags**:
   ```typescript
   if (process.env.NODE_ENV === 'development') {
     // Initialize development UI
     initDevUI();
   }
   ```

3. **Build Configuration**:
   - Development build includes UI components
   - Production build excludes all development UI code
   - Separate entry points for development and production

## Transition to Production

When moving from development to production:

1. Remove all development UI code
2. Apply optimized parameters discovered during development
3. Strip debugging and visualization tools
4. Implement minimal production UI for end-users
5. Optimize for size to minimize inscription cost

## Production UI

The final production UI will be minimal but effective:

1. **Full-screen visualization** of the particle creature
2. **Simple data overlay** showing basic information
3. **No controls** for end-users to modify the creature
4. **Optimized for performance** on various devices
5. **Responsive design** for different screen sizes

## Implementation Guidelines

1. Keep UI code separate from core simulation logic
2. Use reactive programming patterns for UI updates
3. Implement efficient rendering for UI components
4. Design for both mouse and touch interaction
5. Ensure UI performance doesn't impact simulation performance
