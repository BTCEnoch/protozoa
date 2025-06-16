# **New-Protozoa Full Rebuild Checklist**

*Referenced from build_design.md - A comprehensive implementation guide with phase-by-phase breakdown*

---

## **PHASE 1: Foundation & Infrastructure Setup** (Session 1)

### Project Structure
*Reference: build_design.md Section 1 - "Project Structure and Scaffolding"*

- [ ] Create domain-driven directory structure (`src/domains/`)
  - *Reference: build_design.md lines 30-45 - ScaffoldProjectStructure.ps1*
- [ ] Set up parallel `tests/` directory structure  
  - *Reference: build_design.md lines 35-40 - "Create corresponding test directory"*
- [ ] Create each domain folder: `rendering`, `animation`, `effect`, `trait`, `physics`, `particle`, `formation`, `group`, `rng`, `bitcoin`
  - *Reference: build_design.md line 25 - "Define domains to scaffold"*
- [ ] Add required subfolders: `/services/`, `/types/`, `/data/` per domain
  - *Reference: build_design.md lines 40-45 - "Within each domain, create standard subfolders"*
- [ ] Configure TypeScript path aliases (`@/domains/`, `@/shared/`)
  - *Reference: .cursorrules lines 180-185 - "Import Path Rules"*

### Shared Infrastructure  
*Reference: .cursorrules lines 15-25 - "LOGGING" section*

- [ ] Implement Winston logging system (`createServiceLogger`, `createPerformanceLogger`, `createErrorLogger`)
  - *Reference: build_design.md lines 75-80 - Logger imports in RenderingService*  
- [ ] Create shared interfaces directory structure
  - *Reference: .cursorrules lines 155-165 - "Type Definition Standards"*
- [ ] **Define cross-domain shared types and interfaces** (e.g., `Vector3`, `Particle`, `OrganismTraits`) in `@/shared/types/`
  - *Reference: addin.md "Define Cross-Domain Shared Types" - Complete implementation guide*
  - *Reference: .cursorrules lines 155-165 - "Type Definition Standards"*
- [ ] Set up environment configuration (dev vs production API endpoints)
  - *Reference: .cursorrules lines 340-345 - "Development vs Production API Usage"*
- [ ] **Create environment configuration service/module** to manage env-specific settings (e.g., API base URLs, feature flags)
  - *Reference: addin.md "Create Environment Configuration Service" - Complete implementation guide*
  - *Reference: .cursorrules lines 340-345 - "Development vs Production API Usage"*
- [ ] Configure ESLint rules for domain boundaries
  - *Reference: build_design.md lines 1400-1420 - "DomainLint.ps1"*
- [ ] Set up build system with bundle size monitoring
  - *Reference: .cursorrules lines 260-265 - "Bundle size MUST be monitored"*

**Dependencies to Install:**
- [ ] `winston` for logging
- [ ] `three` and `@types/three` for 3D rendering
- [ ] `zustand` for state management  
- [ ] `cross-fetch` for API calls
  - *Reference: build_design.md line 950 - "import fetch from 'cross-fetch'"*

---

## **PHASE 2: Core Utility Domains** (Session 2)

### RNG Domain Implementation
*Reference: build_design.md Section 10 - "RNG Domain (Randomness Service)"*

- [ ] Create `IRNGService` interface with seeding support
  - *Reference: build_design.md lines 1150-1155 - IRNGService interface definition*
- [ ] Implement `RNGService` class with singleton pattern (`static #instance`)
  - *Reference: build_design.md lines 1160-1200 - Complete RNGService implementation*
- [ ] Add Mulberry32 or similar seeded PRNG algorithm
  - *Reference: build_design.md lines 1185-1195 - "seeded PRNG (e.g., linear congruential or mulberry32)"*
- [ ] Include `dispose()` method
  - *Reference: build_design.md lines 1200-1205 - RNGService dispose method*
- [ ] Add comprehensive JSDoc3 documentation
  - *Reference: .cursorrules lines 5-10 - "Ensure comments are JSDoc3 styled"*
- [ ] Export singleton: `export const rngService = RNGService.getInstance()`
  - *Reference: build_design.md line 1210 - "export const rngService"*

### Physics Domain Implementation
*Reference: build_design.md Section 6 - "Physics Domain Refinement"*

- [ ] Create `IPhysicsService` interface
  - *Reference: build_design.md lines 1020-1025 - IPhysicsService interface*
- [ ] Implement `PhysicsService` with particle distribution algorithms
  - *Reference: build_design.md lines 1050-1070 - calculateDistribution method*
- [ ] Add gravity simulation methods
  - *Reference: build_design.md lines 1075-1090 - applyGravity method*
- [ ] Include collision detection framework
  - *Reference: build_design.md lines 1095-1100 - "collision detection, movement integration"*
- [ ] Ensure 60fps optimization targets
  - *Reference: .cursorrules line 270 - "Physics calculations MUST be optimized for 60fps"*
- [ ] Add comprehensive logging for performance monitoring
  - *Reference: build_design.md line 1030 - "#log = createServiceLogger('PHYSICS_SERVICE')"*

---

## **PHASE 3: Data & Blockchain Integration** (Session 3)

### Bitcoin Domain Implementation  
*Reference: build_design.md Section 8 - "Bitcoin Domain Updates"*

- [ ] Create `IBitcoinService` interface
  - *Reference: build_design.md lines 940-945 - IBitcoinService interface definition*
- [ ] Implement caching system (LRU cache for block data)
  - *Reference: build_design.md line 955 - "#cache = new Map<number, BlockInfo>()"*
- [ ] Add API endpoint configuration (dev: `https://ordinals.com/r/blockinfo/{blockNumber}`, prod: `/r/blockinfo/{blockNumber}`)
  - *Reference: build_design.md lines 975-980 - API URL configuration*
  - *Reference: .cursorrules lines 25-30 - "SOURCING BLOCKDATA" section*
- [ ] Implement retry logic (max 3 attempts) with exponential backoff
  - *Reference: .cursorrules lines 35-40 - "Network errors: Retry up to 3 times"*
- [ ] Add inscription content fetching (dev: `https://ordinals.com/content/{inscription_ID}`, prod: `/content/{inscription_ID}`)
  - *Reference: .cursorrules lines 30-35 - "ORDINAL INSCRIPTION CALLING"*
- [ ] Include comprehensive error handling and logging
  - *Reference: build_design.md lines 985-990 - Error handling in fetchBlockInfo*
- [ ] Add rate limiting compliance
  - *Reference: .cursorrules line 350 - "Rate limiting MUST be respected"*

### Trait Domain Implementation
*Reference: build_design.md Section 5 - "Trait Domain Consolidation"*

- [ ] Consolidate all trait services into single `TraitService`
  - *Reference: build_design.md lines 720-730 - "consolidate all trait-related logic into a single TraitService"*
- [ ] Create trait definition data structures (visual, behavior, mutation)
  - *Reference: build_design.md lines 770-785 - loadTraitDefinitions method*
- [ ] Implement Bitcoin block-seeded trait generation
  - *Reference: build_design.md lines 800-820 - generateTraitsForOrganism with blockNonce*
- [ ] Add trait mutation algorithms
  - *Reference: build_design.md lines 850-880 - mutateTrait method*
- [ ] Include organism evolution logic
  - *Reference: build_design.md line 725 - "even orchestrates evolutionary updates"*
- [ ] Ensure RNG service dependency injection (no direct imports)
  - *Reference: build_design.md lines 745-750 - configureDependencies method*

---

## **PHASE 4: Particle System Core** (Session 4)

### Particle Domain Implementation
*Reference: build_design.md Section 7 - "Particle Domain Revision"*

- [ ] Create `IParticleService` interface
  - *Reference: build_design.md lines 890-895 - IParticleService interface definition*
- [ ] Implement particle lifecycle management (create/update/dispose)
  - *Reference: build_design.md lines 930-935 - createParticle, updateParticles, dispose methods*
- [ ] Add particle registry system with efficient lookup
  - *Reference: build_design.md line 905 - "#particles: Map<string, Particle> = new Map()"*
- [ ] Include trait application to particles
  - *Reference: build_design.md lines 940-945 - "Use TraitService to get traits"*
- [ ] Implement dependency injection for physics/rendering services
  - *Reference: build_design.md lines 915-920 - configureDependencies method*
- [ ] Add comprehensive state management
  - *Reference: build_design.md lines 950-970 - Particle creation and state tracking*
- [ ] **Extract particle initialization logic into a separate `ParticleInitService`** if creation logic is complex
  - *Reference: addin.md "Extract Particle Initialization to ParticleInitService" - Complete implementation guide*
  - *Reference: build_design.md lines 930-935 - createParticle, updateParticles, dispose methods*

### Formation Domain Implementation
*Reference: build_design.md Section 2 - "Rendering Domain Overhaul" (formation integration)*

- [ ] **Create `IFormationService` interface** defining formation pattern methods
  - *Reference: addin.md "Create IFormationService Interface" - Complete interface specification*
  - *Reference: build_design.md lines 180-190 - applyFormation method integration*
- [ ] **Implement `FormationService` class** with singleton pattern and formation management
  - *Reference: addin.md "Implement FormationService Class" - Complete implementation guide*
  - *Reference: build_design.md lines 185-190 - "reposition particles according to formation.positions"*
- [ ] Create formation pattern definitions (e.g., shapes or coordinate sets for patterns)
  - *Reference: build_design.md lines 180-190 - applyFormation method*
- [ ] Implement geometric formation algorithms (position particles according to pattern geometry)
  - *Reference: build_design.md lines 185-190 - "reposition particles according to formation.positions"*
- [ ] Add formation pattern transitions and animations (smoothly morph between formations)
  - *Reference: build_design.md lines 190-195 - formation integration logging*
- [ ] Include particle positioning calculations in FormationService (assign coordinates to each particle for a formation)
  - *Reference: build_design.md line 185 - "formation.positions.length"*
- [ ] Ensure PhysicsService integration (e.g., apply physics adjustments after setting formation positions)
  - *Reference: build_design.md lines 960-965 - Physics service usage in particle creation*
- [ ] **Extract complex formation blending logic into a dedicated service or module** (e.g., `FormationBlendingService`) for formation merging
  - *Reference: addin.md "Extract Formation Blending Logic to Separate Service" - Complete implementation guide*
  - *Reference: build_design.md lines 285-295 - "complex math (e.g., easing functions, keyframe definitions)"*
- [ ] **Implement caching with limits in FormationService** for formation results, and clear cache on dispose to prevent memory leaks
  - *Reference: addin.md "Implement Formation Caching Mechanism" - Complete caching implementation*
  - *Reference: .cursorrules lines 265-270 - "Memory leaks MUST be prevented with proper cleanup"*

---

## **PHASE 5: Visual Systems** (Session 5)

### Rendering Domain Overhaul
*Reference: build_design.md Section 2 - "Rendering Domain Overhaul"*

- [ ] Consolidate all rendering managers into single `RenderingService`
  - *Reference: build_design.md lines 50-55 - "consolidate all rendering functionality into a cohesive RenderingService"*
- [ ] Implement THREE.js scene management
  - *Reference: build_design.md lines 85-95 - Scene, Camera, Renderer initialization*
- [ ] Add proper resource cleanup (`dispose()` for GPU memory)
  - *Reference: build_design.md lines 205-215 - dispose method with scene.clear() and renderer.dispose()*
- [ ] Include performance monitoring (frame rate tracking)
  - *Reference: build_design.md lines 145-150 - renderFrame with performance logging*
- [ ] Add formation and effect integration points
  - *Reference: build_design.md lines 175-200 - applyFormation and applyEffect methods*
- [ ] Implement dependency injection pattern
  - *Reference: build_design.md lines 115-125 - initialize method with deps parameter* 

### Effect Domain Implementation  
*Reference: build_design.md Section 4 - "Effect Domain Reimplementation"*

- [ ] Convert functional approach to class-based `EffectService`
  - *Reference: build_design.md lines 620-630 - "create a class-based EffectService that encapsulates all effect logic"*
- [ ] Create effect preset system (nebula, explosion, etc.)
  - *Reference: build_design.md lines 655-665 - preset initialization with nebula and explosion*
- [ ] Add Bitcoin data to effect mapping
  - *Reference: build_design.md lines 625-630 - "any data mapping (formerly bitcoinEffectMapper)"*
- [ ] Include particle effect rendering integration
  - *Reference: build_design.md lines 690-700 - triggerEffect method implementation*
- [ ] Implement effect lifecycle management
  - *Reference: build_design.md lines 705-715 - dispose method for effect cleanup*

---

## **PHASE 6: Animation & Interaction** (Session 6)

### Animation Domain Refactor
*Reference: build_design.md Section 3 - "Animation Domain Refactor"*

- [ ] Consolidate animation systems into single `AnimationService`
  - *Reference: build_design.md lines 220-230 - "merge all core animation logic into a single AnimationService"*
- [ ] Implement animation state management
  - *Reference: build_design.md lines 240-250 - "#animations: Map<string, AnimationState>"*
- [ ] Add easing functions and keyframe support
  - *Reference: build_design.md lines 285-295 - "complex math (e.g., easing functions, keyframe definitions)"*
- [ ] Include role-based animation variations
  - *Reference: build_design.md lines 270-275 - startAnimation with role parameter*
- [ ] Add performance optimization for 60fps target
  - *Reference: build_design.md lines 300-310 - updateAnimations with performance logging*

### Group Domain Cleanup
*Reference: build_design.md Section 9 - "Group Domain Cleanup"*

- [ ] Update export patterns to use singleton constant  
  - *Reference: build_design.md lines 1100-1105 - "export groupService constant"*
- [ ] Implement RNG service injection
  - *Reference: build_design.md lines 1120-1125 - configure method for RNG injection*
- [ ] Add comprehensive group lifecycle management
  - *Reference: build_design.md lines 1130-1145 - formGroup, getGroup, dissolveGroup methods*
- [ ] Include formation integration
  - *Reference: build_design.md lines 1140-1145 - group formation and particle assignment*

---

## **PHASE 7: Automation & Compliance** (Session 7)

### Cleanup Scripts
*Reference: build_design.md Section 11-14 - "Automation Scripts"*

- [ ] Implement `ScaffoldProjectStructure.ps1`
  - *Reference: build_design.md lines 1215-1240 - Complete PowerShell scaffolding script*
- [ ] Create `MoveAndCleanCodebase.ps1`
  - *Reference: build_design.md lines 1245-1285 - File cleanup and restructuring script*
- [ ] Develop `EnforceSingletonPatterns.ps1`
  - *Reference: build_design.md lines 1290-1330 - Singleton pattern enforcement script*
- [ ] Build `VerifyCompliance.ps1`
  - *Reference: build_design.md lines 1335-1380 - Compliance verification script*
- [ ] Create `DomainLint.ps1`
  - *Reference: build_design.md lines 1385-1410 - Domain-specific linting script*

### Quality Assurance
*Reference: .cursorrules Quality Metrics & Targets sections*

- [ ] Run file size verification (500 line limit)
  - *Reference: .cursorrules lines 295-300 - "File size MUST not exceed 500 lines"*
- [ ] Verify domain boundary compliance
  - *Reference: .cursorrules lines 70-80 - "Domain Boundary Rules"*
- [ ] Check singleton pattern consistency
  - *Reference: .cursorrules lines 95-105 - "Service Architecture Standards"*
- [ ] Validate dispose() method presence
  - *Reference: .cursorrules line 105 - "Resource cleanup MUST be implemented in dispose()"*
- [ ] Confirm export pattern standardization
  - *Reference: .cursorrules lines 195-200 - "Export Standards"*

### CI/CD Pipeline & Automation
*Reference: .cursorrules Automation & Tooling Integration sections*

- [ ] Set up GitHub Actions workflow with comprehensive validation pipeline
  - *Reference: .cursorrules lines 355-360 - "GitHub Actions MUST be set up for CI/CD pipeline"*
  - [ ] Configure lint validation (ESLint must pass without warnings)
    - *Reference: .cursorrules line 350 - "ESLint MUST pass without warnings"*
  - [ ] Add unit test execution with coverage requirements
    - *Reference: .cursorrules lines 305-310 - "Test coverage MUST be maintained above 80%"*
  - [ ] Integrate VerifyCompliance.ps1 script execution
    - *Reference: build_design.md lines 1335-1380 - Compliance verification script*
  - [ ] Include DomainLint.ps1 domain boundary validation
    - *Reference: build_design.md lines 1385-1410 - Domain-specific linting script*
  - [ ] Implement bundle-size check with size limits
    - *Reference: .cursorrules lines 260-265 - "Bundle size MUST be monitored and optimized"*
  - [ ] Configure Istanbul coverage reporting (≥ 80% threshold)
    - *Reference: .cursorrules lines 305-310 - "Test coverage MUST be maintained above 80%"*
- [ ] Build & push Docker image on tagged releases (`docker build .`)
  - *Reference: .cursorrules lines 355-365 - "Build-time Validations" and deployment automation*
- [ ] Implement security scanning with npm-audit / Snyk integration
  - *Reference: .cursorrules line 365 - "Security vulnerability scanning MUST be performed"*
  - [ ] Configure pipeline failure on high CVE discoveries
    - *Reference: .cursorrules lines 385-390 - "Security vulnerabilities MUST be patched within 4 hours"*
- [ ] Set up automated documentation publishing
  - [ ] Generate TypeDoc documentation for all services
    - *Reference: .cursorrules lines 375-380 - "Auto-documentation generation MUST be set up for services"*
  - [ ] Create Mermaid diagrams for system architecture
  - [ ] Publish documentation to GitHub Pages on releases

---

## **PHASE 8: Integration & Testing** (Session 8)

### Service Integration
*Reference: .cursorrules Service Layer Guidelines*

- [ ] Implement application composition root
  - *Reference: .cursorrules lines 225-230 - "Class-based dependency injection"*
- [ ] Configure dependency injection between services
  - *Reference: build_design.md multiple references - configureDependencies methods*
- [ ] Add service health checks
  - *Reference: .cursorrules lines 280-285 - "Service health checks MUST be implemented"*
- [ ] Include performance benchmarking
  - *Reference: .cursorrules lines 305-310 - "Performance benchmarks MUST be established"*

### State Management & UI Integration
*Reference: .cursorrules React/UI guidelines and state management standards*

- [ ] **Implement global simulation state store** (e.g., `useSimulationStore` via Zustand for overall app state)
  - *Reference: addin.md "Implement Global Simulation Store (useSimulationStore)" - Complete implementation guide*
  - *Reference: .cursorrules lines 145-150 - "State Management Standards"*
- [ ] **Implement particle state store** (e.g., `useParticleStore` via Zustand to track particle-specific state)
  - *Reference: addin.md "Implement Particle State Store (useParticleStore)" - Complete implementation guide*
  - *Reference: .cursorrules lines 145-150 - "State Management Standards"*
- [ ] **Implement React component(s) for visualization** of the simulation (e.g., a Three.js Canvas using React Three Fiber and any control UI for interactions)
  - *Reference: addin.md "Implement React Visualization Components" - Complete React implementation guide*
  - *Reference: .cursorrules lines 240-250 - "React Components Guidelines"*

### Advanced Integration & Event Systems
*Reference: .cursorrules Service Architecture Standards and React guidelines*

- [ ] Implement EventBus system using Node EventEmitter pattern
  - *Reference: .cursorrules lines 95-105 - "Service Architecture Standards" for cross-service communication*
  - [ ] Register domain-specific events (particle creation, formation changes, trait mutations)
  - [ ] Configure event listeners for cross-domain communication
  - [ ] Add event logging for debugging and monitoring
- [ ] Wire React Error Boundary around simulation components
  - *Reference: .cursorrules lines 250-255 - "Use error boundaries for unexpected errors"*
  - [ ] Implement `<ErrorBoundary>` wrapper around `<SimulationCanvas>`
  - [ ] Add fallback UI for rendering failures
  - [ ] Include error reporting and recovery mechanisms

### Performance & Stress Testing
*Reference: .cursorrules Performance Targets and Quality Metrics*

- [ ] Implement comprehensive performance testing suite
  - *Reference: .cursorrules lines 275-280 - "Frame rate MUST maintain 60fps during normal operations"*
  - [ ] Stress test with 10,000+ particles simulation
  - [ ] Validate 60fps threshold maintenance under load
  - [ ] Test worker thread off-loading toggle functionality
  - [ ] Monitor memory usage during extended simulations
  - [ ] Benchmark Bitcoin API response times under load
- [ ] Performance monitoring and alerting
  - *Reference: .cursorrules lines 280-285 - "Performance metrics MUST be captured"*
  - [ ] Implement frame rate monitoring with alerts
  - [ ] Add memory leak detection for long-running simulations
  - [ ] Monitor GPU memory usage for THREE.js objects

### Data Persistence & Lineage Tracking
*Reference: .cursorrules Service Architecture Standards for new service implementation*

- [ ] Prototype persistence layer implementation
  - [ ] Create `IPersistenceService` interface for data storage contracts
    - *Reference: .cursorrules lines 95-105 - "All services MUST implement IServiceName interface"*
  - [ ] Implement organism lineage tracking system
  - [ ] Add evolutionary history storage capabilities
  - [ ] Include trait mutation timeline persistence
  - [ ] Configure data serialization for organism state
- [ ] Integration with existing services
  - [ ] Connect persistence layer to TraitService for evolution tracking
  - [ ] Integrate with ParticleService for organism state snapshots
  - [ ] Add persistence hooks to formation and effect changes

### Final Validation
*Reference: .cursorrules Testing Standards & Validation*

- [ ] End-to-end organism creation workflow test
  - *Reference: .cursorrules lines 320-325 - "Full organism creation workflow MUST be tested"*
- [ ] Bitcoin API integration validation
  - *Reference: .cursorrules lines 325-330 - "Bitcoin API integration MUST be tested"*
- [ ] THREE.js rendering pipeline verification
  - *Reference: .cursorrules lines 330-335 - "THREE.js rendering pipeline MUST be tested"*
- [ ] Memory leak prevention testing
  - *Reference: .cursorrules lines 265-270 - "Memory leaks MUST be prevented with proper cleanup"*
- [ ] Bundle size optimization verification
  - *Reference: .cursorrules lines 260-265 - "Bundle size MUST be monitored and optimized"*
- [ ] EventBus system integration testing
  - [ ] Validate cross-domain event communication
  - [ ] Test event listener cleanup and memory management
- [ ] Error boundary functionality validation
  - [ ] Test error recovery scenarios
  - [ ] Validate fallback UI rendering
- [ ] Persistence layer data integrity testing
  - [ ] Validate organism lineage data accuracy
  - [ ] Test data serialization/deserialization consistency

---

## **IDENTIFIED GAPS AND CRITICAL ISSUES**

### **Critical Implementation Gaps - RESOLVED:**
*Issues discovered during checklist creation - Now addressed with detailed implementation guides*

1. **✅ Formation Domain Complete Implementation** - *RESOLVED*
   - *Reference: addin.md complete FormationService implementation guides*
   - **Action Completed:** Complete `IFormationService` and `FormationService` class specifications added

2. **✅ Shared Types/Interfaces Defined** - *RESOLVED*
   - *Reference: addin.md "Define Cross-Domain Shared Types" guide*
   - **Action Completed:** Cross-domain types specification in `@/shared/types/` added

3. **✅ State Management Layer Implemented** - *RESOLVED*
   - *Reference: addin.md Zustand store implementation guides*
   - **Action Completed:** `useSimulationStore`, `useParticleStore` implementation guides added

4. **✅ React Component Layer Defined** - *RESOLVED*
   - *Reference: addin.md React Three Fiber implementation guide*
   - **Action Completed:** Complete organism visualization components specification added

5. **✅ Environment Configuration Service** - *RESOLVED*
   - *Reference: addin.md environment configuration implementation guide*
   - **Action Completed:** Complete environment config service specification added

### **Technical Debt Prevention:**
*Compliance items that must be validated before completion*

- [ ] Verify no file exceeds 500 lines
- [ ] Confirm all services use `static #instance` pattern
- [ ] Validate all cross-domain communication uses interfaces only
- [ ] Ensure all services have `dispose()` methods
- [ ] Check Winston logging implementation across all services
- [ ] Verify Bitcoin Ordinals API integration follows specification

**Status:** ✅ **COMPLETE AND READY** - All critical gaps resolved with detailed implementation guides. Ready for implementation in 8 sequential sessions. All missing components now have complete specifications in `addin.md`. 