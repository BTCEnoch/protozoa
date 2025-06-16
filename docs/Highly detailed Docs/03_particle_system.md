# Particle System Design

## Particle Types and Roles

The particle system follows a strict role hierarchy that determines behavior, appearance, and interactions:

### CORE Particles
- **Appearance**: Golden color scheme (r: 1.0, g: 0.8, b: 0.2)
- **Visual Effects**: Gentle pulsing glow
- **Behavior**: Foundation of the system, balanced energy consumption
- **Trail Properties**: Moderate trail length
- **Purpose**: Acts as the nucleus/center point
- **Hierarchy**: Smallest, central position

### CONTROL Particles
- **Appearance**: Blue-white color scheme
- **Visual Effects**: Dynamic, gyroscopic motion
- **Behavior**: Directs other particles, orbits close to the core
- **Trail Properties**: Medium trail length with distinctive pattern
- **Purpose**: Acts as the "head" or brain of the creature
- **Hierarchy**: Small, orbits close to the core

### MOVEMENT Particles
- **Appearance**: Green-blue color scheme
- **Visual Effects**: Directional indicators
- **Behavior**: Propels the entire structure
- **Trail Properties**: Long, directional trails
- **Purpose**: Acts like fins or phylanges for direction
- **Hierarchy**: Medium size, positioned at periphery

### DEFENSE Particles
- **Appearance**: Blue-purple color scheme
- **Visual Effects**: Semi-transparent protective boundary
- **Behavior**: Forms protective barriers around the core
- **Trail Properties**: Short, membrane-like trails
- **Purpose**: Creates a membrane-like boundary
- **Hierarchy**: Large, surrounds the core structure

### ATTACK Particles
- **Appearance**: Red color scheme (r: 1.0, g: 0.2, b: 0.2)
- **Visual Effects**: Intense pulsing glow
- **Behavior**: Aggressive and energetic, higher energy consumption
- **Trail Properties**: Longer trails
- **Purpose**: Patrols the perimeter
- **Hierarchy**: Largest, positioned at strategic locations

## Particle Properties

### Physical Properties
- Position (Vector3)
- Velocity (Vector3)
- Acceleration (Vector3)
- Mass (float)
- Size (float)
- Role (enum: CORE, CONTROL, MOVEMENT, DEFENSE, ATTACK)

### Visual Properties
- Color (RGB)
- Glow intensity (float)
- Trail length (float)
- Pulse rate (float)
- Scale (float)

### Behavioral Properties
- Energy level (float)
- Lifetime (float)
- Interaction radius (float)
- Role-specific behaviors (strategy pattern)
- Force field influence (float)

### Role Relationships
- Dominance relationships (which roles influence others)
- Protective relationships (which roles protect others)
- Movement relationships (how roles affect movement)
- Attraction/repulsion matrix between roles

## Lifecycle Management

### Spawn Process
1. Creation trigger (time-based, event-based, or blockchain-based)
2. Role assignment
3. Initial property configuration
4. Addition to appropriate spatial partition
5. Initialization of visual effects

### Active Life
1. Physics update (position, velocity, acceleration)
2. Behavior execution based on role
3. Interaction with other particles
4. Energy consumption
5. Visual effect updates

### Death Process
1. Death trigger (energy depletion, lifetime expiration, or event)
2. Visual fade-out effect
3. Removal from spatial partition
4. Resource reclamation (memory pool)
5. Event notification

## Interaction System

### Particle-to-Particle Interactions
- Collision detection and response
- Role-based behavior modifications
- Energy transfer
- Force application
- Role-based attraction/repulsion matrix

### Force Field Interactions
- Polygonal force fields with role-specific properties
- Gyroscopic rotation for CONTROL fields
- Role-specific field responses
- Boundary interactions
- Hierarchical field relationships

### Force Matrix
Interactions between particles of different roles are governed by a force matrix:

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

## Memory Management

### Particle Pool
- Pre-allocated memory for particle objects
- Efficient reuse of particle instances
- Configurable pool size (default: 20 buffers)
- Automatic expansion/contraction based on demand

### Vector Buffer Management
- Optimized storage for position, velocity, and acceleration
- Batch processing for performance
- Cache-friendly memory layout

## Implementation Considerations
- Data-oriented design for performance
- Component-based architecture for flexibility
- Event system for decoupled communication
- Strategy pattern for role-based behaviors
- Factory pattern for particle creation
- Deterministic generation from Bitcoin block data
- Total of 500 particles per creature (40 base per role + 300 distributed via RNG)
- Web-based implementation with focus on physics and logic
- Optimized for Bitcoin Ordinals deployment
- Verlet integration for physics simulation
- Hybrid animation with spring-based motion and noise perturbation
- Invisible force fields with role-specific formations
- Emergent behaviors (flocking, pulsation, rotation, oscillation, bifurcation)
- Optimized for average PC hardware with adaptive quality settings
