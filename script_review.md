# Script Suite Review Checklist

> Status: Initial review generated on $(Get-Date)

## 1. Duplicate / Overlapping Scripts

- **09-GenerateEnvironmentConfig.ps1** and **17-GenerateEnvironmentConfig.ps1** both generate an Environment Configuration Service. 17 is the superseded, more comprehensive implementation (adds logging, feature flags). 09 should be removed or merged to prevent conflicting generated files (environment.config.ts vs environmentService.ts duplicates).
- **12-GenerateSharedTypes.ps1** and **16-GenerateSharedTypesService.ps1** both generate shared types. 16 provides an expanded superset. 12 introduces a parallel type hierarchy (`core.types.ts`, `base.interfaces.ts`) that collides with `vectorTypes.ts`, `entityTypes.ts`, etc. Consolidate into a single unified Shared-Types generator.
- **13-GenerateTypeScriptConfig.ps1** and **19-ConfigureAdvancedTypeScript.ps1** both create/modify `tsconfig.*.json`. 19 extends the base configuration created by 13. Combine into one script to avoid double-writes and conflicting compiler options.
- **09/17 vs 21-ConfigureDevEnvironment.ps1** – 21 duplicates several actions (NODE_ENV detection, Vite config) that are already handled inside 17's generated service.

## 2. Execution Order Gaps

- **runAll.ps1** stops after phase 18 and therefore never triggers scripts 19-56. All downstream automation (TypeScript, CI/CD, React integration, etc.) is silently skipped.
- Duplicate entries in `runAll.ps1`: both **09** and **17** are invoked, causing duplicate source generation and possible file overwrites.
- Missing prerequisite-dependency ordering: `SetupPreCommitValidation.ps1` (20) should precede any script that commits generated code (08/45). `ConfigureAdvancedTypeScript.ps1` (19) must run before service generation scripts that rely on advanced TS paths (≥23).

## 3. Standards Compliance Issues

- No dedicated script for **Winston logger plumbing** as mandated by repo rules. Logging code exists inside 17 but a standalone reusable `SetupLoggingService.ps1` is missing.
- Domain boundary validation relies on `06-DomainLint.ps1`, but the script doesn't enforce import-path alias rules (`@/domains/...`). Needs enhancement.
- No script sets up **Husky** hooks (& pre-commit) to trigger the validation suite, despite guideline.
- `SetupPerformanceRegression.ps1` (47) adds Lighthouse-style checks but is not wired into CI (45) nor executed by runAll.

## 4. File / Directory Collisions

- Environment config scripts create identical filenames in two locations (`src/shared/config/environment.config.ts` and `src/domains/bitcoin/services/EnvironmentService.ts`). Path overlap with shared vs domain causes import ambiguity.
- Shared type scripts write to both `src/shared/types` and `src/shared/interfaces` but the index file only re-exports one folder. Some generated types become unreachable.

## 5. Missing Coverage per Rule Set

- No automation script creates the **Winston logger module** (`src/shared/lib/logger.ts`). Required by multiple generated services.
- No script scaffolds **tests** for generated services although guidelines demand >80 % coverage.
- **Observability & health-check service** scaffolding missing.
- **Store generation** (Zustand) for each domain (rule) not present.

## 6. Miscellaneous

- utils.psm1: lacks function to parse semantic version numbers; duplicate regex utilities exist across scripts 14 & 24.
- Hard-coded colorized console output in multiple scripts – should centralise into utils.
- Several scripts still use string interpolation with `$` inside here-docs leading to malformed TS strings (e.g., 09-GenerateEnvironmentConfig lines 160-170).

---

### Action Items (Fix Plan)

1. **Consolidate Duplicates**
   1.1 Replace 09 with 17; remove 09 from repo & runAll.
   1.2 Merge 12 & 16 into new **12-GenerateSharedTypes.ps1** (keep richer schema).
   1.3 Merge 13 & 19 into **13-ConfigureTypeScript.ps1**.
2. **Extend runAll.ps1**
   2.1 Include phases 19-56 in logical order.
   2.2 Ensure pre-commit validation (20) runs before Git operations (08,45).
3. **Add Missing Scripts**
   3.1 **18a-SetupLoggingService.ps1** – generate `src/shared/lib/logger.ts` + winston config.
   3.2 **18b-SetupTestingFramework.ps1** – scaffold Jest/Vitest + coverage pipeline.
4. **Enhance Domain Lint**
   4.1 Update 06-DomainLint.ps1 to validate import aliases & enforce new duplicate-type rules.
5. **Update Utilities**
   5.1 Move console styling helpers to utils.psm1.
   5.2 Deduplicate regex helpers across scripts 14/24.
6. **Documentation**
   6.1 Update `build_design.md` and `script_execution_order.md` to reflect new unified scripts.

> End of review