# Domain Specifications

**Complete technical specifications for the 10 isolated domains in the New-Protozoa Bitcoin Ordinals digital organism simulation**

This directory contains detailed implementation guides for each domain extracted from `build_design.md`. All domains follow strict architectural standards with singleton services, interface-first design, and zero cross-domain imports.

## Domain Architecture Overview

### Core Design Principles
- **Domain Isolation**: Each domain handles a specific aspect with clear boundaries
- **Singleton Pattern**: All services use `static #instance` with `getInstance()` methods
- **Interface-First**: Services implement strict TypeScript interfaces for dependency injection
- **Resource Management**: Mandatory `dispose()` methods for cleanup and leak prevention
- **Performance Optimization**: 60fps targets with comprehensive logging and monitoring

### Domain Organization
```
src/domains/
├── {domain}/
│   ├── services/
│   │   └── {domain}Service.ts    # Main service implementation
│   ├── types/
│   │   └── {domain}Service.d.ts  # Interface definitions
│   └── data/                     # Static configurations
```

## Core Rendering & Visual Systems

### [Rendering Domain](rendering.md)
**Three.js scene management, WebGL rendering, and GPU resource optimization**
- **Service**: `RenderingService` - Consolidated THREE.js scene management
- **Key Features**: Scene initialization, frame rendering, object management, performance monitoring
- **Dependencies**: Formation and Effect services (via injection)
- **Critical Fix**: Consolidated multiple legacy managers into single service class

### [Animation Domain](animation.md)  
**Particle animation systems, easing functions, and 60fps performance optimization**
- **Service**: `AnimationService` - Unified animation state management
- **Key Features**: Animation state tracking, role-based variations, performance-optimized updates
- **Dependencies**: None (pure mathematical operations)
- **Critical Fix**: Merged separate animation systems/coordinators into single service

### [Effect Domain](effect.md)
**Visual effects engine, preset management, and Bitcoin data integration**
- **Service**: `EffectService` - Class-based effect management
- **Key Features**: Effect presets (nebula, explosion), Bitcoin data integration, resource cleanup
- **Dependencies**: None (stateless effect definitions)
- **Critical Fix**: Converted from functional to class-based architecture

## Data & Blockchain Integration

### [Bitcoin Domain](bitcoin.md)
**Blockchain data fetching, caching strategies, and Ordinals protocol integration**
- **Service**: `BitcoinService` - Ordinals protocol integration with caching
- **Key Features**: Block info caching, rate limiting, dev/prod endpoint configuration
- **Dependencies**: None (external API integration)
- **Critical Fix**: Standardized singleton pattern with LRU cache cleanup

### [Trait Domain](trait.md)
**Organism trait generation, mutation algorithms, and blockchain-seeded evolution**
- **Service**: `TraitService` - Consolidated trait management
- **Key Features**: Deterministic trait generation from Bitcoin blocks, mutation algorithms
- **Dependencies**: RNG and Bitcoin services (via injection)
- **Critical Fix**: Consolidated multiple trait services into single class

## Particle System Core

### [Particle Domain](particle.md)
**Digital organism lifecycle management and state tracking**
- **Service**: `ParticleService` - Particle lifecycle and registry management
- **Key Features**: Particle creation/disposal, trait application, state updates
- **Dependencies**: Physics and Rendering services (via injection)
- **Critical Fix**: Removed cross-domain imports via dependency injection

### [Physics Domain](physics.md)
**Particle physics calculations, gravity simulation, and collision detection**
- **Service**: `PhysicsService` - Pure physics calculations with optimization
- **Key Features**: Sphere distribution algorithms, gravity application, physics optimization
- **Dependencies**: None (pure physics calculations)
- **Critical Fix**: Standardized singleton pattern with mathematical optimizations

### [Formation Domain](formation.md)
**Geometric pattern arrangements and particle positioning algorithms**
- **Service**: `FormationService` - Pattern management and position calculations
- **Key Features**: Pattern definitions, position calculations, caching system
- **Dependencies**: Physics and RNG services (via injection)
- **Critical Fix**: New domain extracted from rendering logic with caching

### [Group Domain](group.md)
**Particle clustering behavior and formation management**
- **Service**: `GroupService` - Particle clustering and team management
- **Key Features**: Group formation, dissolution, particle assignment
- **Dependencies**: RNG service (via injection)
- **Critical Fix**: Excellent compliance, minimal adjustments needed

## Utility Services

### [RNG Domain](rng.md)
**Deterministic random number generation with Bitcoin block seeding**
- **Service**: `RNGService` - Seeded PRNG with Mulberry32 algorithm
- **Key Features**: Mulberry32 PRNG, Bitcoin block seeding, reproducible randomness
- **Dependencies**: None (core utility service)
- **Critical Fix**: Exemplary service following all standards (no changes needed)

## Implementation Standards

### Service Pattern Template
All services follow this exact pattern from `build_design.md`:

```typescript
/**
 * {Domain}Service – {description}
 * {Additional context about implementation}
 */
class DomainService implements IDomainService {
  static #instance: DomainService | null = null;
  
  #log = createServiceLogger('DOMAIN_SERVICE');
  #perfLog = createPerformanceLogger('DOMAIN_SERVICE');
  #errorLog = createErrorLogger('DOMAIN_SERVICE');
  
  private constructor() {
    this.#log.info('DomainService initialized');
  }
  
  public static getInstance(): DomainService {
    if (!DomainService.#instance) {
      DomainService.#instance = new DomainService();
    }
    return DomainService.#instance;
  }
  
  public dispose(): void {
    // Resource cleanup implementation
    this.#log.info('DomainService disposed');
    DomainService.#instance = null;
  }
}

// Singleton export
export const domainService = DomainService.getInstance();
```

### Dependency Injection Pattern
Services use `configureDependencies()` methods to avoid cross-domain imports:

```typescript
// Example from TraitService
public configureDependencies(rngService: IRNGService, bitcoinService: IBitcoinService) {
  this.#rngService = rngService;
  this.#bitcoinService = bitcoinService;
  this.#log.debug('TraitService dependencies configured');
}
```

### Quality Standards
- **File Size Limit**: Maximum 500 lines per file
- **Zero Cross-Domain Imports**: Strict boundary enforcement
- **Comprehensive Logging**: Service, performance, and error loggers
- **Memory Management**: Mandatory `dispose()` implementations
- **Type Safety**: 100% TypeScript coverage with JSDoc3 documentation

---

**All domain implementations derived from `build_design.md` - Complete service specifications with working code examples**
