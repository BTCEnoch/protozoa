# Issues, Gaps & Technical Debt

This document aggregates known shortcomings discovered via automation (`script_scrub`), manual review and historical context stored in agent memory.

| ID | Category | Severity | Summary | File(s) / Location |
|----|----------|----------|---------|--------------------|
| 1 | Template Drift | ⚠️ Warning | A handful of *runtime* files were manually edited instead of their `.template` source (e.g. `src/domains/formation/services/formationEnhancer.ts`). These edits will be overwritten by next scaffold. | var * | 
| 2 | Duplicate Backups | ℹ️ Info | Hundreds of timestamped backups exist under `backup/`. They bloat repo size and can cause duplicate symbol warnings in IDE indexers. | `backup/**` |
| 3 | Incomplete Duplicate Detection | ⚠️ Warning | `script_scrub` duplicate-analysis step failed due to Windows ADS path (see `comprehensive-analysis-report.json`). Duplicate functions may still exist. Action: fix path issue & re-run. | `scripts/script_scrub/*` |
| 4 | High Memory Risk Scripts | ⚠️ Warning | 3 PowerShell scripts flagged as potential high-RAM consumers (>500 MB) – optimisation recommended. | See `resource-usage-analysis.json` |
| 5 | Domain Boundary Violations | ❗ Critical | Some early prototypes imported `particle` utils directly inside `physics` services. Scripts added alias fix but legacy imports may linger. Run the *domain boundary validator* (`scripts/60-VerifyWorkerDisposal.ps1`) periodically. | `src/domains/physics/**` |
| 6 | Winston in Browser | ✅ Resolved | Original Winston logger caused `process is not defined` in browsers. Replaced with UniversalLogger (see `/shared/lib/logger.ts`). | **Fixed** |
| 7 | PostCSS JSON Parsing | ✅ Resolved | `package.json` corruption due to PowerShell `ConvertTo-Json` whitespace bug. Switched to templates. | **Fixed** |
| 8 | VS Code Settings Template | ✅ Resolved | Missing `.vscode` JSON templates blocked environment setup script – now added. | **Fixed** |

## Recommendations

1. **Delete old backups** – or move to Git LFS.
2. **Repair duplicate-analysis script** – patch ADS path handling for cross-platform.
3. **Automate boundary checks** – integrate into CI pipeline instead of ad-hoc script.
4. **Bundle size monitoring** – integrate `rollup-plugin-visualizer` to track webpack chunks.

_This list is non-exhaustive – please append new issues as they are discovered._