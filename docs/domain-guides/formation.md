# Formation Domain Guide

## Purpose

The **Formation** domain is responsible for calculating _where_ particles should be positioned in 3-D space based on reusable geometric patterns (spiral, lattice, sphere, etc.). It is **purely geometric** – it does not mutate physics state or rendering directly.

## Public API

```typescript
// 12:34:src/domains/formation/interfaces/IFormationService.ts
export interface IFormationService {
  getFormationPattern(id: string): IFormationPattern | undefined
  registerFormationPattern(pattern: IFormationPattern): boolean
  unregisterFormationPattern(id: string): boolean
  listAvailablePatterns(): string[]
  applyFormation(config: IFormationConfig): Promise<IFormationResult>
  calculatePositions(
    patternId: string,
    particleCount: number,
    opts?: { scale?: number; rotation?: IVector3 }
  ): IVector3[]
  clearCache(): number
  dispose(): void
}
```

`FormationService` implements the interface as a **singleton**. Obtain it via:

```typescript
import { FormationService } from '@/domains/formation/services/FormationService'
const formation = FormationService.getInstance()
```

## Default Patterns

Patterns are defined in `domains/formation/data/formationPatterns.ts` (generated from template). Each pattern implements:

```typescript
interface IFormationPattern {
  id: string
  name: string
  type: 'sphere' | 'spiral' | 'lattice' | 'custom'
  maxParticles: number
  positions: IVector3[] // pre-computed or empty for procedural
}
```

During service boot, `loadDefaultPatterns()` registers all patterns (see `FormationService` constructor lines 33-56).

## Adding a New Pattern (Template Workflow)

1. Duplicate _pattern_ template: `templates/domains/formation/data/formationPattern.template` → rename to `<yourId>.json.template`.
2. Fill tokens:
   - `__PATTERN_ID__`
   - `__NAME__`
   - `__TYPE__`
   - `__MAX_PARTICLES__`
   - `__POSITIONS__` (array or empty for procedural)
3. Run scaffold script:

```powershell
scripts/44a-AddFormationTemplate.ps1 -Name "<yourId>"
```

4. Script copies JSON → `src/domains/formation/data/` and updates export barrel.
5. Add a unit-test under `tests/formation/<yourId>.test.ts` verifying `validateFormationPattern` passes.
6. Document your pattern below.

## Caching Strategy

- **Key**: `pattern_<id>`
- **Capacity**: 50 entries (LRU eviction via `addToCache` at lines 511-537).
- **Metrics**: `#metrics` tracks `cacheHits`, `cacheMisses`, etc. Exposed via `FormationService.getMetrics()`.

## Dependency Injection

`configureDependencies({ physics, rng, rendering })` injects optional services. Use cases:

- `rng` – generate procedural formations deterministically.
- `physics` – validate particle overlap pre-simulation.
- `rendering` – pre-allocate instanced mesh matrices.

## Logging

- `ServiceLogger` tag: `FORMATION_SERVICE`
- `logger.info` – pattern registration / application success.
- `logger.warn` – validation failures, pattern not found.
- `logger.error` – unexpected exceptions.
- `perfLog.*` – execution time per apply.

## Testing Matrix

| Test                    | File                                      | Responsibility                           |
| ----------------------- | ----------------------------------------- | ---------------------------------------- |
| Unit: validate defaults | `tests/formation/defaultPatterns.test.ts` | All default patterns pass validation     |
| Unit: apply formation   | `tests/formation/applySphere.test.ts`     | Sphere application positions N particles |
| Perf: calculation speed | `tests/performance/particle.perf.test.ts` | Ensure ≤16 ms for 10 k particles         |

## Future Work

- **Formation blending** – `formationBlendingService.ts` placeholder ready for morphing between patterns.
- **GPU-driven generation** – offload heavy procedural maths to compute shader.

---

Return to [Domain Guides index](./README.md).
