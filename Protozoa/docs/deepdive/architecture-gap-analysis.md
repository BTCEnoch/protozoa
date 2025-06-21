# Protozoa Deep-Dive

## 0. Purpose

This document enumerates **every architectural, domain, scripting, testing, and DevOps feature** promised in `docs/design_lists/build_design.md` (the "Blueprint") that is **NOT yet implemented** in the current `src/` and `scripts/` directories.

_Use this as the authoritative backlog. Each unchecked item must eventually map to either:_

1. **A new PowerShell automation script** in `scripts/`, **or**
2. **Source-code additions / refactors** under `src/`, **or**
3. **Documentation / configuration artefacts** (e.g. VS Code, ESLint, CI).

> **Legend**  
> 🔲 = not started ☐ = partially implemented ✅ = complete ⚠️ = blocked / needs clarification

---

## 1. High-Level Checklist (Build Phases ➜ Status)

| #   | Phase          | Blueprint Deliverable                                               | Status       |
| --- | -------------- | ------------------------------------------------------------------- | ------------ |
| 1   | Scaffolding    | `ScaffoldProjectStructure.ps1` fully idempotent & cross-platform    | 🔲           |
| 2   | RNG Domain     | `RNGService` – seedable Mulberry32, rehash chain, purpose RNG API   | ☑ (basic)   |
| 3   | Physics Domain | Collision detection; worker off-load; 60 fps perf tests             | 🔲           |
| 4   | Bitcoin Domain | Retry w/ exponential back-off; rate-limit; prod/dev endpoint switch | ☑ (partial) |
| 5   | Trait Domain   | Evolution engine; mutation probability tables; milestone logic      | 🔲           |
| 6   | Particle Init  | `ParticleInitService` & 500-particle allocation algorithm           | 🔲           |
| 7   | Formation      | `FormationService`, `FormationBlendingService`, caching & DI        | 🔲           |
| 8   | Rendering      | R3F integration; colour-theme CSS generator; material factory       | ☑ (partial) |
| 9   | Effect         | Mutation visual hooks (`nebula_burst`, etc.)                        | 🔲           |
| 10  | Animation      | Gyroscopic CONTROL rotation; easing/keyframe library                | 🔲           |
| 11  | Group          | Evolution milestone polling hook (`useConfirmationPoll`)            | 🔲           |
| 12  | Stores         | `useSimulationStore`, `useParticleStore`, devtools                  | 🔲           |
| 13  | Memory/Workers | `MemoryPool.ts`, `WorkerManager.ts`, build flag `USE_WORKERS`       | 🔲           |
| 14  | Observability  | OpenTelemetry spans via Winston meta; FPS, mem metrics              | 🔲           |
| 15  | Compliance     | Verify scripts update to assert _worker.terminate()_ on dispose     | 🔲           |
| 16  | Testing        | Mutation probability statistical test; visual regression            | 🔲           |
| 17  | Dev Env        | `04-GenerateThemeCSS.ps1`, ESLint custom rules, Husky hooks         | 🔲           |
| 18  | CI/CD          | Bundle-size budget gate; SonarQube quality gate                     | 🔲           |

---

## 2. Detailed Gap Analysis by Domain

### 2.1 RNG (`src/domains/rng`)

- ☑ **Basic service present** but **missing**:
  - 🔲 _rehash chain_ & `maxChainLength` guard.
  - 🔲 `getPurposeRng(purpose: string)` helper.
  - 🔲 Unit tests covering deterministic sequences.

### 2.2 Physics (`src/domains/physics`)

- ☑ Core service exists; however:
  - 🔲 Collision detection utilities.
  - 🔲 Worker-based physics engine (`physicsWorker.ts`) not wired via `WorkerManager`.
  - 🔲 60 fps benchmark & Winston performance logs.

### 2.3 Bitcoin (`src/domains/bitcoin`)

- 🔲 Retry (max 3) with exponential back-off.
- 🔲 Client-side rate limiter (shared `rate-limiter.ts`).
- 🔲 Prod/dev endpoint switch via `environmentService`.
- 🔲 `IDependencyLoader` for ordinal script deps.

### 2.4 Trait (`src/domains/trait`)

- 🔲 Evolution & mutation algorithms.
- 🔲 Trait definition data files in `trait/data/`.
- 🔲 `configureDependencies()` injection of RNG + Bitcoin.
- 🔲 Comprehensive unit tests (>80% cov.).

### 2.5 Particle (`src/domains/particle`)

- 🔲 `ParticleInitService` + batch init.
- 🔲 500-particle allocation & emergent behaviour enums.
- 🔲 Refactor to use injected stores rather than direct imports.

### 2.6 Formation (`src/domains/formation`)

- 🔲 `IFormationService` interface file.
- 🔲 `FormationService` singleton with pattern library.
- 🔲 `FormationBlendingService` interpolation.
- 🔲 Caching w/ eviction on dispose.
- 🔲 Geometry data moved to `formation/data/*` templates ➜ real files.

### 2.7 Rendering (`src/domains/rendering`)

- ☑ Service refactor started but missing:
  - 🔲 R3F integration (currently imperative Three.js only).
  - 🔲 CSS palette generator script + `COLOR_PALETTES` dataset.
  - 🔲 Material factory & role-based colours.
  - 🔲 FPS overlay / perf metrics.

### 2.8 Effect (`src/domains/effect`)

- 🔲 Effect presets beyond 'nebula'.
- 🔲 Mutation visual hooks (`nebula_burst`, `type_change_transition`, etc.).
- 🔲 dispose() cleans GPU resources.

### 2.9 Animation (`src/domains/animation`)

- 🔲 Keyframe/easing helpers.
- 🔲 Gyroscopic CONTROL rotation update algorithm.
- 🔲 Animation devtools & frame-skip detector.

### 2.10 Group (`src/domains/group`)

- 🔲 RNG injection not yet configured.
- 🔲 Confirmation polling hook (`useConfirmationPoll`).

### 2.11 Shared / Config

- 🔲 `environmentService.ts` dev/prod base URL exports.
- 🔲 OpenTelemetry + Winston bridge.
- 🔲 Zustand stores (`useSimulationStore`, `useParticleStore`).
- 🔲 EventBus integration with services.

---

## 3. Missing Automation Scripts (`/scripts`)

| Script Name                            | Purpose                                                       | Dependencies            |
| -------------------------------------- | ------------------------------------------------------------- | ----------------------- |
| **04-GenerateThemeCSS.ps1**            | Loop `COLOR_PALETTES` ➜ write `src/assets/themes/*.css`       | Node (ts-node), file IO |
| **07-SmartMemoryAndWorkers.ps1**       | Generate `MemoryPool.ts`, `WorkerManager.ts`, add build flag  | none                    |
| **12-GenerateParticleInitService.ps1** | Scaffold `ParticleInitService` with allocation algo           | Trait, Physics, RNG     |
| **18-ImplementEvolutionEngine.ps1**    | Adds mutation probability tables, milestone logic             | RNG, Bitcoin            |
| **23-GenerateFormationService.ps1**    | Scaffold IFormationService, FormationService, BlendingService | RNG (optional)          |
| **29-SetupOpenTelemetry.ps1**          | Install OT libs, wrap Winston logger                          | npm install, env vars   |
| **33-GenerateStores.ps1**              | Create Zustand stores & devtools config                       | Zustand                 |
| **41-SetupR3FIntegration.ps1**         | Replace imperative Rendering with R3F components              | react-three-fiber       |
| **54-SetupPerformanceBenchmarks.ps1**  | Adds `vitest` perf tests & bench harness                      | vitest, tiny-bench      |
| **60-VerifyWorkerDisposal.ps1**        | AST scan: ensure `worker.terminate()` in dispose()            | PowerShell regex        |
| **72-GenerateCIConfig.ps1**            | GitHub Actions: lint, test, bundle budget, SonarQube          | gh CLI                  |

_(Full script templates to be authored after checklist approval.)_

---

## 4. Cross-Cutting Concerns Still Unaddressed

1. **Dispose Enforcement** – several services still lack cleanup; compliance script must assert presence + worker termination.
2. **Domain-Boundary Imports** – manual scan shows a few direct imports between particle ↔ physics; formation ↔ rendering; need DI refactor.
3. **Test Relocation** – some `tests/performance` still reside under `src` backup copies; move to `/tests`.
4. **File-Size Violations** – `utils.psm1` (764 lines) > 500 line limit; requires modular split.
5. **Windows-Only Scripts** – all PowerShell; consider generating cross-platform Node CLI wrappers.
6. **Observability** – no OpenTelemetry spans, no real-time FPS/memory overlay.
7. **Bundle Size Guard** – vite config lacks rollup-plugin-visualizer & budget CI.
8. **Rate Limiter** – stub exists but not wired into BitcoinService nor global fetch.
9. **Colour-Palette Data** – placeholder only; generator script + CSS missing.
10. **EventBus** – interface exists, but services neither publish nor subscribe.

---

## 5. Recommended Next Steps

1. **Team Review** – validate each unchecked item, mark false positives ✅, clarify blockers ⚠️.
2. **Script Wave 1** – implement foundational scripts: `environmentService`, RNG upgrades, rate limiter, dispose enforcement.
3. **Script Wave 2** – domain scaffolding (`FormationService`, `ParticleInitService`, evolution engine).
4. **Script Wave 3** – UI & UX: R3F integration, colour themes, Zustand stores.
5. **CI/DevOps** – set up GitHub Actions, bundle budget, SonarQube.
6. **Observability & Perf** – integrate OpenTelemetry, FPS overlay, vitest benchmarks.
7. **Cross-Platform Effort** – gradually port PoSh scripts to Node CLI for macOS/Linux devs.

---

## 6. Appendix – File/Path Quick Refs

```
src/domains/*/services      ⟶ domain service classes
src/domains/*/workers       ⟶ Web Worker entrypoints
src/shared/state            ⟶ Zustand stores (to be generated)
scripts                     ⟶ PowerShell automations
```

---

**Authored by:** Architecture Deep-Dive Bot  
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
