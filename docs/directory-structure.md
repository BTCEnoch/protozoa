# Directory Structure

> ⚠️  This document is generated from `npm run docs` and should reflect the *current* state of `main`.

## 1. Top-Level Folders

| Path | Purpose |
|------|---------|
| `assets/` | Static CSS, themes, images |
| `components/` | React 18 client components (functional, hook-based) |
| `domains/` | DDD bounded-contexts; each sub-folder is a domain |
| `shared/` | Cross-domain helpers (logger, config, workers, utilities) |
| `state/` | Auto-generated Zustand stores (one per domain) |
| `templates/` | Authoritative PowerShell templates for scaffolding code |
| `scripts/` | 57+ PowerShell automation scripts (template scaffolding, validation) |
| `tests/` | Vitest + Playwright unit, integration, perf & e2e suites |
| `benchmarks/` | Micro-benchmarks used in CI (Vitest perf) |
| `docs/` | **← You are here** – Markdown documentation |

> The project root also hosts configuration (ESLint, Prettier, Vite, husky) and CI artifacts.

## 2. Domain Folder Anatomy

Each domain adheres to the same internal sub-layout:

```text
domains/<domain-name>/
  index.ts               # Barrel exporting public API
  interfaces/            # *Contracts* – e.g. ITraitService
  services/              # Class-based singleton implementations
  types/                 # Pure TypeScript data types / enums / maps
  utils/                 # Pure functions, domain-specific helpers
  data/                  # (optional) Static JSON / formation presets
  tests/                 # (optional) Domain-specific tests
```

### Example: `domains/formation/`

```text
domains/formation/
  index.ts
  interfaces/
    IFormationService.ts
  services/
    FormationService.ts
    formationBlendingService.ts
    dynamicFormationGenerator.ts
  types/
    formation.types.ts
  data/
    helix.json           # Example formation template
```

## 3. Template Hierarchy

The `templates/` folder mirrors **exactly** the runtime folders – any new runtime file *must* originate from an equivalent `.template` counterpart.

```text
templates/
  domains/
    formation/
      services/FormationService.ts.template
      data/helix.json.template
  components/
    SimulationCanvas.tsx.template
  shared/
    lib/logger.ts.template
  src/
    compositionRoot.ts.template
```

Scaffolding scripts locate these templates based on path conventions, perform token replacement (`__DOMAIN__`, `__DATE__`, etc.) and copy them into `src/`.

## 4. Automation Scripts

* **scripts/00-** : Environment setup (npm, VS Code)
* **scripts/10-** : Core infra (logging, testing, OpenTelemetry)
* **scripts/30-** : Domain scaffolds (particle, physics, rendering)
* **scripts/40-** : Front-end integration (R3F, React)
* **scripts/50-** : Performance & monitoring
* **scripts/60-** : Validation (worker disposal, domain boundaries)

> Scripts must never emit inline code – the *Template-First* rule.

## 5. Backups & Generated Artifacts

`backup/` contains timestamped safety copies of files touched by automation scripts. **These are not part of the runtime bundle** but are useful for diffing and rollback.

## 6. Future Conventions

* **No runtime code outside `src/`**
* **No duplicate test files in production folders**
* **PowerShell scripts must reside in `scripts/` only**

---

For naming specifics see `[naming-conventions.md](./naming-conventions.md)`, and for dependency mapping see `[dependencies.md](./dependencies.md)`.