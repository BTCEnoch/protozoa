# Project Questions Checklist

This document serves as a comprehensive checklist of questions to address throughout the development process. We'll work through these questions systematically to ensure all aspects of the project are thoroughly considered.

## Status Overview

- ✅ Completed: 48 questions
- ⏳ Pending: 10 questions
- 🆕 New Categories: 4 categories with 20 questions

## Technical Implementation Questions

- [x] **JavaScript Framework**: Use React with React Three Fiber for 3D rendering integration
- [x] **3D Rendering**: Use Three.js as the core rendering engine
- [x] **Web Workers**: Implement worker pools for physics, rendering, and data with load balancing
- [x] **Memory Management**: Use object pooling, monitoring system, and proper cleanup strategies
- [x] **Testing Environment**: Test in browser with incremental development approach

### Follow-up Technical Questions

- [x] **React Three Fiber Integration**: Use instanced meshes, efficient animation loop, geometry merging, proper cleanup, and component memoization
- [x] **WebGL Optimization**: Use instanced rendering, optimized renderer config, frustum culling, and custom shaders
- [x] **State Management**: Use Zustand for state management
- [x] **Build System**: Use Vite for development and building
- [x] **TypeScript Usage**: Use TypeScript for type safety during development
- [ ] **Module Structure**: How should we organize the codebase for maintainability and performance?
- [ ] **Asset Loading**: What's the best approach for loading and managing assets?
- [ ] **Error Boundary Strategy**: How should we implement error boundaries in React?
- [ ] **Performance Monitoring**: Address performance monitoring when base application is built
- [ ] **Code Splitting**: How should we approach code splitting for optimal loading?
- [x] **Testing Framework**: Use Vitest with React Testing Library

## Particle System Design Questions

- [x] **Particle Appearance**: Use nonce-based RNG for varied traits (color, shape, formation, effects)
- [x] **Force Field Visualization**: Implement invisible force fields with role-specific formations
- [x] **Interaction Complexity**: Dynamic interactions with role-specific behaviors resembling cellular organisms
- [x] **Physics Simulation Fidelity**: Use Verlet integration with simplified force calculations
- [x] **Emergent Behaviors**: Implement flocking, pulsation, rotation, oscillation, bifurcation based on roles
- [x] **Particle Count Distribution**: 40 base particles per role + 300 distributed via normalized RNG (10-30% per role)
- [ ] **Particle Lifecycle**: To be addressed in future stages using Bitcoin confirmations
- [x] **Animation Smoothness**: Combine spring-based motion with subtle noise perturbation
- [x] **Special Effects**: Build a bank of effects optimized for performance (instanced rendering, priority system)
- [x] **Performance Tradeoffs**: Target average PCs with adaptive quality and level-of-detail systems

## Bitcoin Integration Questions

- [x] **Inscription Process**: Manual inscription with packaging of modules as exports with inscription IDs
- [x] **Dependency Loading**: Load via script src tags with appropriate sequencing
- [x] **Error Handling**: Focus on thorough testing as code will be immutable once inscribed
- [x] **Local Development**: Use local caching of inscription content and development-only fallbacks
- [x] **Size Constraints**: Up to 200kb per inscription with gzip compression
- [x] **Caching Strategy**: Resources will be loaded from immutable on-chain locations
- [x] **Versioning Approach**: Build base engine first, design for future extensibility (combat, breeding, etc.)
- [x] **Fallback Mechanisms**: No fallbacks needed as all resources will be on Bitcoin network
- [x] **Testing Methodology**: Test with actual inscription sources using ordinals.com endpoints
- [x] **Optimization Priorities**: Code size reduction and loading performance

## User Experience Questions

- [x] **Target Devices**: Standard PC hardware with optimization for current average specs
- [x] **Performance Expectations**: Target 60 FPS
- [x] **Loading Experience**: Loading screen followed by simulation in action
- [x] **Interaction Model**: Initially observation only (like an aquarium), with possible interactions later
- [x] **Data Display**: Stats for creature and particle groups, trait listings, data overlays
- [x] **Accessibility Considerations**: Keep open for all users, prepare for future accessibility protocols
- [x] **Responsive Design**: Auto-adjust to common screen resolution ratios
- [x] **Visual Styling**: Sleek UI with dark grey and Bitcoin orange color scheme
- [x] **Error Messaging**: Focus on error prevention with immutable resources
- [ ] **Performance Degradation**: To be addressed during detailed optimization work

## Evolution Mechanics Questions

- [x] **Confirmation-Based Evolution**: Use milestone-based mutation system with confirmation thresholds
- [x] **Visual Transformation**: Add visual effects specific to each mutation type
- [x] **Trait Modification**: Apply attribute boosts, type changes, count increases, and group splits
- [x] **Evolution Triggers**: Use specific confirmation milestones (10k, 50k, 100k, 250k, 500k, 1M)
- [x] **Mutation Chance**: Roll for mutation chance at each milestone with rarity-based selection

## Attribute and Trait Questions

- [x] **Group Attributes**: Core attributes include perception, force field shapes, color, visual effects, scale, particle shape, and force values
- [x] **Attribute Ranges**: Attributes typically range from 0-1, with rarity affecting the range (common: 0.1-0.3, mythic: 0.9-1.0)
- [x] **Trait Categories**: Categories include visual traits, formation traits, behavior traits, and force calculation traits
- [x] **Visual Traits**: Visual traits include particle shape, color, effects (trails, glow, etc.), organized by rarity tiers
- [x] **Trait Interactions**: Role-based interactions with specific attraction/repulsion values between different group types
- [x] **Formation Traits**: Role-specific formations (e.g., sphere, toroid for defense) organized by rarity tiers
- [x] **Behavior Traits**: Emergent behaviors organized by rarity tiers with role-specific variations

## Trait System Details

- [x] **Trait Categories**: Visual traits (shape, color, effects), formation traits, behavior traits, force calculation traits
- [x] **Trait Rarity**: Six rarity tiers (common: 40%, uncommon: 30%, rare: 20%, epic: 8%, legendary: 1.5%, mythic: 0.5%)
- [x] **Trait Combinations**: Traits interact through the force matrix and role-specific behaviors
- [x] **Trait Visualization**: Visual traits implemented with Three.js geometries, materials, and effects with rarity-based complexity
- [x] **Trait Impact**: Traits affect particle behavior through modular behavior components with rarity-based enhancements

## Testing Strategy

- [ ] **Unit Testing Approach**: What specific components and functions should have unit tests?
- [ ] **Integration Testing**: How should we test the integration between different systems?
- [ ] **Visual Testing**: How should we test the visual appearance of creatures?
- [ ] **Performance Testing**: What performance metrics should we test?
- [ ] **Cross-Browser Testing**: What browsers should we support and test?

## Deployment Pipeline

- [ ] **Development Workflow**: What should the development workflow look like?
- [ ] **Staging Environment**: Should we have a staging environment before inscription?
- [ ] **Final Verification**: What verification steps should be performed before inscription?
- [ ] **Post-Deployment Testing**: How should we test after deployment?
- [ ] **Documentation**: What documentation should be created for users?
