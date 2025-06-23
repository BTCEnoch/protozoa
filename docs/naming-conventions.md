# Naming & Coding Conventions

Protozoa enforces strict conventions to guarantee predictability, tooling support and zero duplication. This doc distils the rules from `.cursorrules`, `repo_specific_rule`, and the architectural guidelines.

## 1. Files & Folders

| Entity | Pattern | Example |
|--------|---------|---------|
| Domain directory | `domains/<kebab-name>/` | `domains/particle/` |
| Service file | `domainNameService.ts` (camelCase + *Service* suffix) | `ParticleService.ts` |
| Interface | `IDomainName.ts` (PascalCase with `I` prefix) | `IParticleService.ts` |
| Types file | `domainName.types.ts` | `particle.types.ts` |
| Store | `domainName.store.ts` | `particle.store.ts` |
| Utility | `utilityName.utils.ts` | `vectorMath.utils.ts` |
| Component (default export) | `ComponentName.tsx` | `SimulationCanvas.tsx` |
| Tests | `<subject>.test.ts` | `ParticleService.test.ts` |
| Template | `<runtime-file>.template` | `ParticleService.ts.template` |

## 2. Code Style

* **TypeScript everywhere** – `*.ts` / `*.tsx`; no `.js` in `src/`.
* **Interfaces over `type`** (except unions / mapped types).
* **Enums discouraged** – prefer `const enum` or `Record` maps.
* **Guard-clauses** – early returns for invalid state.
* **Function length ≤ 50 lines**; class ≤ 300 lines; file ≤ 500 lines.
* **Logging** – `logger.debug` for branching logic, `info` for milestones, `error` in `catch`.

## 3. Imports & Exports

* Use **absolute aliases**: `@/domains/particle/...` (configured via TypeScript paths).
* Domains **must not** import from each other directly – only via interfaces.
* Default exports allowed only for React components; everything else uses named exports.

## 4. Commit Messages (Conventional Commits)

```
feat(domain): short description
fix(scripts): handle missing template
chore(deps): bump vitest to 1.1.0
```

## 5. CSS / Assets

* CSS themes reside in `assets/themes/*.css` using *BEM* block naming.
* Images use WebP; optimise via `squoosh` CLI.

---

Any divergence from these conventions triggers ESLint, Husky pre-commit or the **domain boundary validator**.