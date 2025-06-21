# Implementation Specifications for Outstanding Automation Scripts

_Companion to **architecture-gap-analysis.md**_

Each section below provides:
1. **Purpose** – Why the script exists.
2. **Inputs / Outputs** – Parameters, files touched/created.
3. **Algorithmic Steps** – Ordered operations.
4. **Logging & Error Strategy** – Winston levels + exit codes.
5. **Template File** – Path of the newly-added `.ps1.template`.

---

## 04-GenerateThemeCSS.ps1

**Purpose**
Generate Tailwind-compatible CSS theme files for every palette listed in `src/shared/data/colorPalettes.ts`.

**I/O**
- _Input_: `src/shared/data/colorPalettes.ts` (exports COLOR_PALETTES).
- _Output_: `src/assets/themes/<paletteName>.css`.

**Steps**
1. Import/parse the TS file via `ts-node` so script stays DRY.
2. Loop palettes → emit CSS vars (e.g., `--particle-core`).
3. Write file, overwriting existing.
4. Log `info` per palette, `error` on disk failures.

**Logging**
- `INFO` – palette processed.
- `DEBUG` – full path written.
- Exit `1` with `ERROR` if generation fails.

**Template**: `templates/scripts/04-GenerateThemeCSS.ps1.template`

---

## 07-SmartMemoryAndWorkers.ps1

**Purpose**
Scaffold adaptive `MemoryPool.ts`, `WorkerManager.ts`, and optional build flag in `vite.config.ts`.

**I/O**
- _Creates_: `src/shared/memory/MemoryPool.ts`, `src/shared/workers/WorkerManager.ts`.
- _Modifies_: `vite.config.ts` (inject `define: { USE_WORKERS: true }`).

**Steps**
1. Generate TS files from templates with placeholder logic.
2. Append/merge build flag.
3. Perform `tsc --noEmit` sanity-check; revert on failure.

**Logging**
- `INFO` – files generated.
- `WARN` – build flag already present.

**Template**: `templates/scripts/07-SmartMemoryAndWorkers.ps1.template`

---

## 12-GenerateParticleInitService.ps1

**Purpose**
Create `ParticleInitService` with 500-particle allocation + emergent behaviour enums.

**I/O**
- _Creates_: `src/domains/particle/services/particleInitService.ts`.

**Steps**
1. Insert interface if missing.
2. Generate service with allocation algorithm & DI hooks.
3. Wire into composition root via comment TODO.

**Logging**
- `INFO` – service generated.
- `ERROR` – interface missing.

**Template**: `templates/scripts/12-GenerateParticleInitService.ps1.template`

---

## 18-ImplementEvolutionEngine.ps1

**Purpose**
Augment `TraitService` with mutation probability tables, milestone logic, and visual hooks.

**I/O**
- _Modifies_: `src/domains/trait/services/TraitService.ts`.
- _Creates_: `src/domains/trait/data/mutationProbabilities.ts`.

**Steps**
1. Append import + probability constants.
2. Inject `applyEvolutionMilestone()` into service.
3. Update exports.

**Template**: `templates/scripts/18-ImplementEvolutionEngine.ps1.template`

---

## 23-GenerateFormationService.ps1

**Purpose**
Scaffold `IFormationService`, `FormationService`, `FormationBlendingService`, and data stubs.

**I/O**
- _Creates_: corresponding TS files in formation domain.

**Steps**
1. Generate interface.
2. Generate services with DI and caching skeleton.
3. Copy default patterns to `formation/data/`.

**Template**: `templates/scripts/23-GenerateFormationService.ps1.template`

---

## 29-SetupOpenTelemetry.ps1

**Purpose**
Install OT libs, create `tracing.ts`, and patch Winston transport.

**Template**: `templates/scripts/29-SetupOpenTelemetry.ps1.template`

---

## 33-GenerateStores.ps1

Creates Zustand `useSimulationStore` & `useParticleStore` with devtools opt-in.

**Template**: `templates/scripts/33-GenerateStores.ps1.template`

---

## 41-SetupR3FIntegration.ps1

Converts imperative Three.js to R3F components, wraps `RenderingService`.

**Template**: `templates/scripts/41-SetupR3FIntegration.ps1.template`

---

## 54-SetupPerformanceBenchmarks.ps1

Adds vitest + tiny-bench suites and CI script hook.

**Template**: `templates/scripts/54-SetupPerformanceBenchmarks.ps1.template`

---

## 60-VerifyWorkerDisposal.ps1

AST scan for `worker.terminate()` inside every `dispose()`.

**Template**: `templates/scripts/60-VerifyWorkerDisposal.ps1.template`

---

## 72-GenerateCIConfig.ps1

Produce GitHub Actions pipeline with lint/test/size/SonarQube.

**Template**: `templates/scripts/72-GenerateCIConfig.ps1.template`

---

> **Next step**: implement each `.ps1.template` & push for review.