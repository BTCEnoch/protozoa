Referenced from build_design.md – A comprehensive implementation guide with phase-by-phase breakdown <details><summary><strong>PHASE 1: Foundation & Infrastructure Setup</strong> (Session 1)</summary>
Project Structure
Reference: build_design.md Section 1 - "Project Structure and Scaffolding"
 Create domain-driven directory structure (src/domains/)
Reference: build_design.md lines 30-45 - ScaffoldProjectStructure.ps1
 Set up parallel tests/ directory structure
Reference: build_design.md lines 35-40 - "Create corresponding test directory"
 Create each domain folder: rendering, animation, effect, trait, physics, particle, formation, group, rng, bitcoin
Reference: build_design.md line 25 - "Define domains to scaffold"
 Add required subfolders: /services/, /types/, /data/ in each domain
Reference: build_design.md lines 40-45 - "Within each domain, create standard subfolders"
 Configure TypeScript path aliases (@/domains/*, @/shared/*)
Reference: .cursorrules lines 180-185 - "Import Path Rules"
Shared Infrastructure
Reference: .cursorrules lines 15-25 - "LOGGING" section
 Implement Winston logging system (create helpers: createServiceLogger, createPerformanceLogger, createErrorLogger)
Reference: build_design.md lines 75-80 - Logger imports in RenderingService
 Create shared interfaces/types directory structure
Reference: .cursorrules lines 155-165 - "Type Definition Standards"
 Define cross-domain shared types and interfaces (e.g., Vector3, Particle, OrganismTraits) in @/shared/types/
Reference: .cursorrules lines 155-165 - "Type Definition Standards"
 Set up environment configuration (dev vs production API endpoints)
Reference: .cursorrules lines 340-345 - "Development vs Production API Usage"
 Create environment configuration service/module to manage env-specific settings (e.g., API base URLs, feature flags)
Reference: .cursorrules lines 340-345 - "Development vs Production API Usage"
 Configure ESLint rules to enforce domain boundaries
Reference: build_design.md lines 1400-1420 - "DomainLint.ps1"
 Set up build system with bundle size monitoring
Reference: .cursorrules lines 260-265 - "Bundle size MUST be monitored"
Dependencies to Install:
 winston for logging
 three and @types/three for 3D rendering
 zustand for state management
 cross-fetch for API calls
Reference: build_design.md line 950 - "import fetch from 'cross-fetch'"
</details> <details><summary><strong>PHASE 2: Core Utility Domains</strong> (Session 2)</summary>
RNG Domain Implementation
Reference: build_design.md Section 10 - "RNG Domain (Randomness Service)"
 Create IRNGService interface with seeding support
Reference: build_design.md lines 1150-1155 - IRNGService interface definition
 Implement RNGService class with singleton pattern (static #instance)
Reference: build_design.md lines 1160-1200 - Complete RNGService implementation
 Add Mulberry32 or similar seeded PRNG algorithm for reproducible randomness
Reference: build_design.md lines 1185-1195 - "seeded PRNG (e.g., linear congruential or mulberry32)"
 Include dispose() method for RNGService
Reference: build_design.md lines 1200-1205 - RNGService dispose method
 Add comprehensive JSDoc3 documentation to all RNG methods
Reference: .cursorrules lines 5-10 - "Ensure comments are JSDoc3 styled"
 Export singleton instance: export const rngService = RNGService.getInstance()
Reference: build_design.md line 1210 - "export const rngService"
Physics Domain Implementation
Reference: build_design.md Section 6 - "Physics Domain Refinement"
 Create IPhysicsService interface
Reference: build_design.md lines 1020-1025 - IPhysicsService interface
 Implement PhysicsService class with particle distribution algorithms
Reference: build_design.md lines 1050-1070 - calculateDistribution method
 Add gravity simulation methods to PhysicsService
Reference: build_design.md lines 1075-1090 - applyGravity method
 Include collision detection framework for particles
Reference: build_design.md lines 1095-1100 - "collision detection, movement integration"
 Ensure physics calculations meet 60fps optimization targets
Reference: .cursorrules line 270 - "Physics calculations MUST be optimized for 60fps"
 Add comprehensive logging in PhysicsService for performance monitoring
Reference: build_design.md line 1030 - "#log = createServiceLogger('PHYSICS_SERVICE')"
</details> <details><summary><strong>PHASE 3: Data & Blockchain Integration</strong> (Session 3)</summary>
Bitcoin Domain Implementation
Reference: build_design.md Section 8 - "Bitcoin Domain Updates"
 Create IBitcoinService interface
Reference: build_design.md lines 940-945 - IBitcoinService interface definition
 Implement caching system (e.g., simple LRU cache) for block data in BitcoinService
Reference: build_design.md line 955 - "#cache = new Map<number, BlockInfo>()"
 Add API endpoint configuration (dev: https://ordinals.com/r/blockinfo/{blockNumber}, prod: /r/blockinfo/{blockNumber})
Reference: build_design.md lines 975-980 - API URL configuration
Reference: .cursorrules lines 25-30 - "SOURCING BLOCKDATA" section
 Implement network retry logic (max 3 attempts with exponential backoff) for API calls
Reference: .cursorrules lines 35-40 - "Network errors: Retry up to 3 times"
 Add inscription content fetching support (/content/{inscription_ID})
Reference: .cursorrules lines 30-35 - "ORDINAL INSCRIPTION CALLING"
 Include comprehensive error handling and Winston logging in BitcoinService
Reference: build_design.md lines 985-990 - Error handling in fetchBlockInfo
 Enforce API rate limiting compliance (throttle requests as needed)
Reference: .cursorrules line 350 - "Rate limiting MUST be respected"
Trait Domain Implementation
Reference: build_design.md Section 5 - "Trait Domain Consolidation"
 Consolidate all trait-related logic into a single TraitService class
Reference: build_design.md lines 720-730 - "consolidate all trait-related logic into a single TraitService"
 Implement ITraitService interface and have TraitService implement it
Reference: build_design.md lines 770-785 - loadTraitDefinitions method (trait definitions setup)
 Create trait definition data structures (visual traits, behavior traits, mutation traits, etc.)
Reference: build_design.md lines 770-785 - loadTraitDefinitions method
 Implement Bitcoin block-seeded trait generation in TraitService
Reference: build_design.md lines 800-820 - generateTraitsForOrganism with blockNonce
 Add trait mutation algorithms for evolving traits over time
Reference: build_design.md lines 850-880 - mutateTrait method
 Include organism evolution logic using trait combinations
Reference: build_design.md line 725 - "even orchestrates evolutionary updates"
 Ensure RNG service is injected (no direct rngService imports in TraitService)
Reference: build_design.md lines 745-750 - configureDependencies method (for RNG injection)
</details> <details><summary><strong>PHASE 4: Particle System Core</strong> (Session 4)</summary>
Particle Domain Implementation
Reference: build_design.md Section 7 - "Particle Domain Revision"
 Create IParticleService interface
Reference: build_design.md lines 890-895 - IParticleService interface definition
 Implement particle lifecycle management methods (create, update, dispose) in ParticleService
Reference: build_design.md lines 930-935 - createParticle, updateParticles, dispose methods
 Add particle registry system with efficient lookups (e.g., #particles: Map<string, Particle>)
Reference: build_design.md line 905 - "#particles: Map<string, Particle> = new Map()"
 Include trait application to particles (use TraitService to assign traits on creation)
Reference: build_design.md lines 940-945 - "Use TraitService to get traits"
 Implement dependency injection for PhysicsService and RenderingService in ParticleService
Reference: build_design.md lines 915-920 - configureDependencies method
 Add comprehensive state management for particles (track active particles, removed particles, etc.)
Reference: build_design.md lines 950-970 - Particle creation and state tracking
 Extract particle initialization logic into a separate ParticleInitService if creation logic is complex
Reference: FULL_AUDIT.md lines 165-168 - "Particle initialization logic should be in separate service"
Formation Domain Implementation
Reference: build_design.md Section 2 (Rendering Overhaul) - formation integration notes
 Create IFormationService interface defining formation pattern methods
Reference: FULL_AUDIT.md lines 123-127 - "Proper interface implementation (IFormationService)"
 Implement FormationService class with singleton pattern and formation management
Reference: FULL_AUDIT.md lines 141-143 - "Standardize singleton pattern with static #instance"
 Create formation pattern definitions (e.g., shapes or coordinate sets for patterns)
Reference: build_design.md lines 180-190 - applyFormation method (pattern handling)
 Implement geometric formation algorithms (position particles according to pattern geometry)
Reference: build_design.md lines 185-190 - "reposition particles according to formation.positions"
 Add formation pattern transitions and animations (smoothly morph between formations)
Reference: build_design.md lines 190-195 - formation integration logging (transition feedback)
 Include particle positioning calculations in FormationService (assign coordinates to each particle for a formation)
Reference: build_design.md line 185 - "formation.positions.length"
 Ensure PhysicsService integration (e.g., apply physics adjustments after setting formation positions)
Reference: build_design.md lines 960-965 - Physics service usage in particle creation
 Extract complex formation blending logic into a dedicated service or module (e.g., FormationBlendingService) for formation merging
Reference: FULL_AUDIT.md lines 136-139 - "COMPLEX BLENDING LOGIC: Should be extracted to separate service"
 Implement caching with limits in FormationService for formation results, and clear cache on dispose to prevent memory leaks
Reference: FULL_AUDIT.md lines 142-144 - "Add cache size limits and cleanup"
</details> <details><summary><strong>PHASE 5: Visual Systems</strong> (Session 5)</summary>
Rendering Domain Overhaul
Reference: build_design.md Section 2 - "Rendering Domain Overhaul"
 Consolidate all rendering managers into a single RenderingService class
Reference: build_design.md lines 50-55 - "consolidate all rendering functionality into a cohesive RenderingService"
 Implement Three.js scene management in RenderingService (initialize Scene, Camera, Renderer)
Reference: build_design.md lines 85-95 - Scene, Camera, Renderer initialization
 Add proper resource cleanup in RenderingService (dispose() to free GPU memory, clear scene on teardown)
Reference: build_design.md lines 205-215 - dispose method with scene.clear() and renderer.dispose()
 Include performance monitoring in the render loop (frame rate tracking and logging)
Reference: build_design.md lines 145-150 - renderFrame with performance logging
 Add integration points to apply formation patterns and trigger effects from RenderingService
Reference: build_design.md lines 175-200 - applyFormation and applyEffect methods
 Implement dependency injection for external services in RenderingService (accept FormationService, EffectService in init)
Reference: build_design.md lines 115-125 - initialize method with deps parameter
Effect Domain Implementation
Reference: build_design.md Section 4 - "Effect Domain Reimplementation"
 Convert existing effect logic to a class-based EffectService (replace old functional approach)
Reference: build_design.md lines 620-630 - "create a class-based EffectService that encapsulates all effect logic"
 Implement IEffectService interface and use it in the EffectService class
Reference: build_design.md lines 625-630 - "any data mapping (formerly bitcoinEffectMapper)"
 Create effect preset system (e.g., predefined effects like nebula, explosion)
Reference: build_design.md lines 655-665 - preset initialization with nebula and explosion
 Add Bitcoin data integration in effects (use BitcoinService data in effect parameters)
Reference: build_design.md lines 625-630 - incorporate block/inscription data into effects
 Integrate particle effect rendering (methods to spawn or update particles for visual effects)
Reference: build_design.md lines 690-700 - triggerEffect method implementation
 Implement effect lifecycle management (dispose() in EffectService to clean up resources after effects)
Reference: build_design.md lines 705-715 - dispose method for effect cleanup
</details> <details><summary><strong>PHASE 6: Animation & Interaction</strong> (Session 6)</summary>
Animation Domain Refactor
Reference: build_design.md Section 3 - "Animation Domain Refactor"
 Consolidate all animation systems into a single AnimationService class
Reference: build_design.md lines 220-230 - "merge all core animation logic into a single AnimationService"
 Implement animation state management in AnimationService (e.g., maintain #animations: Map<string, AnimationState>)
Reference: build_design.md lines 240-250 - "#animations: Map<string, AnimationState>"
 Add easing functions and keyframe support to AnimationService
Reference: build_design.md lines 285-295 - "complex math (e.g., easing functions, keyframe definitions)"
 Include role-based animation variations (allow different behavior per organism role)
Reference: build_design.md lines 270-275 - startAnimation with role parameter
 Optimize animation updates for 60fps (minimize heavy calculations in updateAnimations)
Reference: build_design.md lines 300-310 - updateAnimations with performance logging
Group Domain Cleanup
Reference: build_design.md Section 9 - "Group Domain Cleanup"
 Update group service export pattern to use a singleton constant
Reference: build_design.md lines 1100-1105 - "export groupService constant"
 Implement RNG service injection in GroupService (no direct RNG imports)
Reference: build_design.md lines 1120-1125 - configure method for RNG injection
 Add comprehensive group lifecycle management (methods: formGroup, getGroup, dissolveGroup)
Reference: build_design.md lines 1130-1145 - formGroup, getGroup, dissolveGroup methods
 Include formation integration in GroupService (coordinate group formation patterns and assign particles to groups)
Reference: build_design.md lines 1140-1145 - group formation and particle assignment
</details> <details><summary><strong>PHASE 7: Automation & Compliance</strong> (Session 7)</summary>
Cleanup Scripts
Reference: build_design.md Sections 11-14 - "Automation Scripts"
 Implement ScaffoldProjectStructure.ps1 (PowerShell script to generate the folder scaffolding)
Reference: build_design.md lines 1215-1240 - Complete PowerShell scaffolding script
 Create MoveAndCleanCodebase.ps1 (script to move legacy code and remove obsolete files)
Reference: build_design.md lines 1245-1285 - File cleanup and restructuring script
 Develop EnforceSingletonPatterns.ps1 (script to scan and enforce singleton export patterns across domains)
Reference: build_design.md lines 1290-1330 - Singleton pattern enforcement script
 Build VerifyCompliance.ps1 (script to verify all .cursorrules standards are met)
Reference: build_design.md lines 1335-1380 - Compliance verification script
 Create DomainLint.ps1 (script for domain-specific linting to enforce boundaries)
Reference: build_design.md lines 1385-1410 - Domain-specific linting script
Quality Assurance
Reference: .cursorrules Quality Metrics & Targets
 Run file size verification (ensure no source file exceeds 500 lines)
Reference: .cursorrules lines 295-300 - "File size MUST not exceed 500 lines"
 Verify domain boundary compliance (no cross-domain imports violating architecture)
Reference: .cursorrules lines 70-80 - "Domain Boundary Rules"
 Check singleton pattern consistency across all services
Reference: .cursorrules lines 95-105 - "Service Architecture Standards"
 Validate presence of dispose() methods in all services
Reference: .cursorrules line 105 - "Resource cleanup MUST be implemented in dispose()"
 Confirm standardized export patterns for singletons (export const serviceName = ServiceName.getInstance())
Reference: .cursorrules lines 195-200 - "Export Standards"
</details> <details><summary><strong>PHASE 8: Integration & Testing</strong> (Session 8)</summary>
Service Integration
Reference: .cursorrules Service Layer Guidelines
 Implement application composition root (initialize all services and orchestrate dependencies in one place)
Reference: .cursorrules lines 225-230 - "Class-based dependency injection"
 Configure dependency injection between services (use configureDependencies methods to supply RNG, Bitcoin, etc. where needed)
Reference: build_design.md (multiple references) - configureDependencies methods
 Add service health checks (each service provides a status or init check to ensure it’s functioning)
Reference: .cursorrules lines 280-285 - "Service health checks MUST be implemented"
 Include performance benchmarking suite (measure and log performance of key operations across domains)
Reference: .cursorrules lines 305-310 - "Performance benchmarks MUST be established"
State Management & UI Integration
Reference: .cursorrules React/UI guidelines and state management standards
 Implement global simulation state store (e.g., useSimulationStore via Zustand for overall app state)
Reference: .cursorrules lines 345-355 - "State Management (Zustand) Guidelines"
 Implement particle state store (e.g., useParticleStore via Zustand to track particle-specific state)
Reference: .cursorrules lines 345-355 - "State Management (Zustand) Guidelines"
 Implement React component(s) for visualization of the simulation (e.g., a Three.js Canvas using React Three Fiber and any control UI for interactions)
Reference: .cursorrules lines 335-340 - "React UI integration standards"
Final Validation
Reference: .cursorrules Testing Standards & Validation
 End-to-end organism creation workflow test (simulate creating an organism and verify all domain interactions)
Reference: .cursorrules lines 320-325 - "Full organism creation workflow MUST be tested"
 Bitcoin API integration validation (test that blockchain data is correctly fetched and integrated)
Reference: .cursorrules lines 325-330 - "Bitcoin API integration MUST be tested"
 THREE.js rendering pipeline verification (ensure rendering output is correct and performant)
Reference: .cursorrules lines 330-335 - "THREE.js rendering pipeline MUST be tested"
 Memory leak prevention testing (run tests to confirm all dispose() methods free resources properly)
Reference: .cursorrules lines 265-270 - "Memory leaks MUST be prevented with proper cleanup"
 Bundle size optimization verification (check final bundle size and tree-shaking to meet size targets)
Reference: .cursorrules lines 260-265 - "Bundle size MUST be monitored and optimized"
</details> Status: All phases are updated with previously missing steps and critical gap resolutions integrated into the relevant phases. Ready for implementation in 8 sequential sessions.