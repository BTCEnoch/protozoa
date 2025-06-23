# Architecture Improvements

## 1. Strengthen Domain Boundary Enforcement

**Problem**: The domain boundary validator is currently a *manual* PowerShell script (`scripts/60-VerifyWorkerDisposal.ps1`). Developers may forget to run it.

**Proposal**:

1. Build an ESLint custom rule that forbids cross-domain relative imports (`../../physics/…`).
2. Integrate rule into existing ESLint config → CI will fail instantly.
3. Optionally create a VS Code extension that shows red squiggles for boundary violations.

**Effort**: 2 days  
**Benefit**: Zero-tolerance domain integrity.

---

## 2. Replace PowerShell with Node-based CLI

**Problem**: PowerShell scripts cause portability friction on macOS/Linux (though they run via `pwsh`, new contributors stumble).

**Proposal**:

* Port critical scripts (scaffold, validate, test) to **TS + ts-node** CLI using Commander.js.
* Keep PowerShell as thin wrappers for Windows devs.

**Effort**: 1 week  
**Benefit**: Cross-platform DX, easier unit-testing of generators.

---

## 3. Incremental Template Compilation

Current template-first approach rewrites entire files → editor loses context, React FastRefresh invalidates.  Implement **incremental generators** that diff AST and only patch changed nodes.

* Use Recast or TS Morph to transform code.
* Keeps git diffs minimal.

---

## 4. Introduce Hexagonal (Ports-&-Adapters) Layer

Right now services talk to each other directly.  Introduce **application service layer** that orchestrates domain calls, enabling future backends (server-side simulation, mobile).

---

## 5. Typed DI Container

`compositionRoot.ts` manually wires singletons. Switch to **InversifyJS** or lightweight DI to allow multiple instances (unit tests, SSR).

---

## 6. Public API Package

Extract stable interfaces into separate NPM package (`@protozoa/api`) so external tooling or plugins can depend without full repo.