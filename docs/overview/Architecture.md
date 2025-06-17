# Domain-Driven Architecture

The New-Protozoa project implements a strict domain-driven architecture with complete service isolation and dependency injection. This architecture ensures maintainability, testability, and scalability while adhering to the project's `.cursorrules` standards.

## Core Architectural Principles

### 1. Domain Isolation
Each domain is completely isolated with **zero cross-domain imports**. Domains communicate only through:
- **Interface contracts** (e.g., `IPhysicsService`, `IRenderingService`)
- **Dependency injection** at service initialization
- **Shared types** from `@/shared/types` (never domain-specific types)

### 2. Singleton Service Pattern
All services implement the **standardized singleton pattern**:

```typescript
class DomainService implements IDomainService {
  static #instance: DomainService | null = null;
  
  private constructor() {
    // Initialize service
  }
  
  public static getInstance(): DomainService {
    if (!DomainService.#instance) {
      DomainService.#instance = new DomainService();
    }
    return DomainService.#instance;
  }
  
  public dispose(): void {
    // Cleanup resources
    DomainService.#instance = null;
  }
}

// Singleton export
export const domainService = DomainService.getInstance();
```

### 3. Interface-First Development
Every service must implement a corresponding interface:
- Services depend on interfaces, not concrete implementations
- Enables dependency injection and testing
- Maintains loose coupling between domains

### 4. Resource Management
All services implement mandatory `dispose()` methods:
- **Three.js resources**: Geometries, materials, textures
- **Event listeners**: DOM events, service subscriptions  
- **Caches**: Memory cleanup and garbage collection
- **Singleton reset**: Nullify static instances

## Domain Architecture

### Service Layer Structure
```
src/domains/
├── rendering/
│   ├── services/
│   │   └── renderingService.ts    # IRenderingService implementation
│   ├── types/
│   │   └── renderingService.d.ts  # Interface definitions
│   └── data/                      # Static data/configurations
├── animation/
│   ├── services/
│   │   └── animationService.ts    # IAnimationService implementation
│   └── types/
└── [other domains...]
```

### Domain Boundaries and Responsibilities

**Rendering Domain** *(Reference: build_design.md Section 2)*
- **Responsibility**: Three.js scene management, WebGL rendering, GPU resource optimization
- **Dependencies**: Formation, Effect services (via injection)
- **Key Features**: Scene initialization, frame rendering, object management, performance monitoring
- **Exports**: `renderingService` singleton
- **Critical Implementation**: Consolidated from multiple legacy managers into single `RenderingService` class

**Animation Domain** *(Reference: build_design.md Section 3)*
- **Responsibility**: Particle movement, easing functions, keyframe management, 60fps optimization
- **Dependencies**: None (pure mathematical operations)
- **Key Features**: Animation state tracking, role-based variations, performance-optimized updates
- **Exports**: `animationService` singleton
- **Critical Implementation**: Unified animation logic from separate systems/coordinators

**Effect Domain** *(Reference: build_design.md Section 4)*
- **Responsibility**: Visual effects, particle systems, Bitcoin-triggered events, preset management
- **Dependencies**: None (stateless effect definitions)
- **Key Features**: Effect presets (nebula, explosion), Bitcoin data integration, resource cleanup
- **Exports**: `effectService` singleton
- **Critical Implementation**: Class-based architecture replacing functional approach

**Trait Domain** *(Reference: build_design.md Section 5)*
- **Responsibility**: Organism characteristics, Bitcoin-seeded generation, mutations, evolution
- **Dependencies**: RNG, Bitcoin services (via injection)
- **Key Features**: Deterministic trait generation from Bitcoin blocks, mutation algorithms
- **Exports**: `traitService` singleton
- **Critical Implementation**: Consolidated trait logic from multiple separate services

**Physics Domain** *(Reference: build_design.md Section 6)*
- **Responsibility**: Particle distribution, gravity simulation, collision detection, 60fps performance
- **Dependencies**: None (pure physics calculations)
- **Key Features**: Sphere distribution algorithms, gravity application, physics optimization
- **Exports**: `physicsService` singleton
- **Critical Implementation**: Standardized singleton pattern with mathematical optimizations

**Particle Domain** *(Reference: build_design.md Section 7)*
- **Responsibility**: Digital organism lifecycle, state management, particle registry
- **Dependencies**: Physics, Rendering services (via injection)
- **Key Features**: Particle creation/disposal, trait application, state updates
- **Exports**: `particleService` singleton
- **Critical Implementation**: Removed cross-domain imports via dependency injection

**Formation Domain** *(Reference: build_design.md - Formation references)*
- **Responsibility**: Geometric patterns, position calculations, formation transitions
- **Dependencies**: Physics, RNG services (via injection)
- **Key Features**: Pattern definitions, position calculations, caching system
- **Exports**: `formationService` singleton
- **Critical Implementation**: New domain extracted from rendering logic

**Group Domain** *(Reference: build_design.md Section 9)*
- **Responsibility**: Particle clustering, team management, formation coordination
- **Dependencies**: RNG service (via injection)
- **Key Features**: Group formation, dissolution, particle assignment
- **Exports**: `groupService` singleton
- **Critical Implementation**: Excellent compliance, minimal adjustments needed

**RNG Domain** *(Reference: build_design.md Section 10)*
- **Responsibility**: Seeded random number generation, deterministic algorithms
- **Dependencies**: None (core utility service)
- **Key Features**: Mulberry32 PRNG, Bitcoin block seeding, reproducible randomness
- **Exports**: `rngService` singleton
- **Critical Implementation**: Exemplary service following all standards

**Bitcoin Domain** *(Reference: build_design.md Section 8)*
- **Responsibility**: Blockchain data fetching, ordinals integration, caching, API management
- **Dependencies**: None (external API integration)
- **Key Features**: Block info caching, rate limiting, dev/prod endpoint configuration
- **Exports**: `bitcoinService` singleton
- **Critical Implementation**: LRU cache with cleanup, network retry logic

## Dependency Injection Pattern

### Service Configuration
Services accept dependencies through `configureDependencies()` methods:

```typescript
// Composition root example from build_design.md
const renderingService = RenderingService.getInstance();
const formationService = FormationService.getInstance();
const effectService = EffectService.getInstance();

// Configure dependencies
renderingService.initialize(canvas, {
  formation: formationService,
  effect: effectService
});

particleService.configureDependencies(
  physicsService,
  renderingService
);

traitService.configureDependencies(rngService, bitcoinService);
```

### Dependency Flow Rules
1. **No circular dependencies**: Services constructed in topological order
2. **Interface dependencies**: Services depend on interfaces, not concrete classes
3. **Lazy initialization**: Dependencies resolved during service configuration
4. **Null safety**: Services handle missing dependencies gracefully

## Memory Management & Performance

### Resource Cleanup Strategy
```typescript
// Application shutdown sequence from build_design.md
const cleanupServices = [
  renderingService,  // THREE.js scene cleanup
  animationService,  // Stop all animations
  effectService,     // Clear effect presets
  particleService,   // Clear particle registry
  formationService,  // Clear pattern cache
  groupService,      // Clear group mappings
  traitService,      // Clear trait definitions
  physicsService,    // Release physics state
  bitcoinService,    // Clear API cache
  rngService         // Reset seed state
];

cleanupServices.forEach(service => service.dispose());
```

### Leak Prevention Standards
- **Three.js objects**: Explicit disposal in RenderingService (`scene.clear()`, `renderer.dispose()`)
- **Event listeners**: Removed in service dispose methods
- **Caches**: Size-limited maps with automatic eviction
- **Singleton instances**: Nullified to enable garbage collection

### Performance Targets *(Reference: .cursorrules)*
- **60fps rendering**: All services optimized for real-time performance
- **Memory efficiency**: <200MB for 1000+ organisms using object pooling
- **Load performance**: <3 second initial page load with code splitting
- **Bundle optimization**: <2MB initial load with tree shaking

## Quality Assurance & Automation

### Architectural Enforcement Scripts *(Reference: build_design.md Sections 11-14)*

**ScaffoldProjectStructure.ps1**
```powershell
# Creates domain-driven directory structure
$domains = @("rendering", "animation", "effect", "trait", "physics", 
            "particle", "formation", "group", "rng", "bitcoin")
foreach ($domain in $domains) {
    New-Item -Path "src/domains/$domain" -Name "services" -ItemType Directory -Force
    New-Item -Path "src/domains/$domain" -Name "types" -ItemType Directory -Force
    New-Item -Path "src/domains/$domain" -Name "data" -ItemType Directory -Force
    New-Item -Path "tests" -Name $domain -ItemType Directory -Force
}
```

**EnforceSingletonPatterns.ps1**
```powershell
# Enforces singleton and export patterns
$serviceFiles = Get-ChildItem -Path src\domains -Recurse -Include "*Service.ts"
foreach ($file in $serviceFiles) {
    # Replace private static instance with static #instance
    $content = $content -replace "private static instance", "static #instance"
    # Ensure export const singleton is present
    $className = ($content | Select-String -Pattern "class\s+(\w+Service)").Matches[0].Groups[1].Value
    $instanceName = ($className.Substring(0,1).ToLower() + $className.Substring(1))
    $exportPattern = "export const $instanceName = $className.getInstance();"
}
```

**VerifyCompliance.ps1**
```powershell
# Scans for architectural violations
# 1. Check files exceeding 500 lines
Get-ChildItem -Path src -Recurse -Include *.ts,*.tsx | ForEach-Object {
    $lineCount = (Get-Content $_.FullName).Length
    if ($lineCount -gt 500) {
        Write-Warning "File too large ($lineCount lines): $($_.FullName)"
    }
}

# 2. Check for cross-domain imports
foreach ($file in $domainServices) {
    $currentDomain = $file.Directory.Name
    $imports = $text -split "`r`n" | Where-Object { $_ -match "from '.*/domains/" }
    foreach ($imp in $imports) {
        if ($imp -match "domains\/([^\/]+)\/" -and $Matches[1] -ne $currentDomain) {
            Write-Warning "$($file.Name) imports from another domain: $imp"
        }
    }
}
```

### Testing Strategy *(Reference: .cursorrules Testing Standards)*
- **Unit tests**: Individual service method validation with 80%+ coverage
- **Integration tests**: Cross-service interaction verification
- **End-to-end tests**: Complete organism creation workflow
- **Performance tests**: 60fps maintenance and memory leak prevention
- **Visual regression**: Critical UI component testing

This architecture provides a robust foundation for the Bitcoin Ordinals digital organism ecosystem while maintaining strict separation of concerns and enabling easy testing and maintenance.
