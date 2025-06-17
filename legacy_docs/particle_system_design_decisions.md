# Particle System Design Decisions

This document outlines the key design decisions for the particle system based on our discussions and requirements.

## Particle Traits and Appearance

### Nonce-Based RNG for Traits
- Use Bitcoin block nonce as the initial seed for deterministic RNG
- Each trait requires a new random number in the chain
- Convert 32-bit numbers to [0,1] scale for trait assignment
- Use each generated number as seed for the next trait's random number
- Traits include: color, shape, formation, force calculations, particle distribution, visual effects

### Trait Randomization Process
```
1. Start with Bitcoin block nonce as initial seed
2. Generate random number using mulberry32 algorithm
3. Use this number to determine first trait
4. Use the same number as seed for next random number
5. Continue chain for all required traits
```

This approach ensures:
- Each creature is unique but deterministic
- Same block height always produces identical creatures
- Millions of possible combinations
- No external randomness required

##  Formations

- **Role-specific formations** 
- Pre-designed 3d formations designed in array per Role
- Animations are configured within the formation


### Formation Implementation
- Each role has specific formation tendencies
- Formations are influenced by the role's purpose
- Formations help create the appearance of a cohesive organism


## Particle Distribution

### 500 Particles Total
- **Base allocation**: 40 particles per role (200 total)
- **Dynamic allocation**: 300 remaining particles distributed via RNG

### Distribution Algorithm
```
1. Assign 40 base particles to each of the 5 roles (200 total)
2. For the remaining 300 particles:
   a. Generate 5 random values between 0.1 and 0.3 (10-30%)
   b. Normalize these values to sum to 1.0
   c. Multiply each by 300 to get additional particles per role
   d. Round to integers while ensuring total remains 300
```

This ensures:
- Every role has a minimum functional number of particles
- Distribution is fair regardless of allocation order
- Each creature has a unique distribution pattern
- Distribution is deterministic based on block nonce

## Animation and Movement

### Hybrid Animation Approach
- Combine **spring-based motion** with **subtle noise perturbation**
- Spring-based motion provides organic feel with natural momentum
- Noise perturbation adds subtle variation to prevent mechanical-looking behavior
- Parameters tuned for cellular organism aesthetic

### Implementation Considerations
- Optimize spring calculations for performance
- Use coherent noise for perturbation (Perlin or Simplex)
- Pre-compute noise patterns where possible
- Implement adaptive detail based on performance

## Special Effects - using Three Nebula to create beautiful, role and formation specific animation effects.

### Effect Bank Approach
- Build a library of particle effects
- Effects assigned based on role and RNG
- Optimize for performance and visual impact

### Optimization Strategies
- Use instanced rendering for similar effects
- Implement priority system for effects
- Use shader-based effects where possible
- Pre-compute effect animations where possible

## Performance Considerations

### Target Hardware
- Average standard PC hardware
- Some headroom for future improvements
- Adaptive quality settings based on performance

### Optimization Techniques
- Level-of-detail systems that scale based on performance
- Prioritize physics accuracy for visible particles
- Use efficient rendering techniques (instanced meshes, shared materials)
- Implement adaptive quality settings that adjust based on framerate

## Future Enhancements

### Particle Lifecycle
- Mutations are checked on confirmation thresholds. 
- Mutations stack and creatures evolve through threshold unlocks. 
- Using the Evolution Mechanics

### Advanced Behaviors
- Sensory perception
- More complex emergent behaviors
- Environmental interactions
