# Template-First System

**Key Principle:** *No script may emit inline code.* All source files originate from a template in `templates/`. Automation guarantees consistency, reduces duplication, and makes large-scale refactorings trivial (edit the template once → regenerate).

## 1. Anatomy of a Template

* **Extension**: `.template` appended to the runtime filename.
* **Token placeholders**: `__DATE__`, `__DOMAIN__`, `__SERVICE_NAME__`, etc. replaced by PowerShell scripts.
* **Comment markers**: `// @generated` header warns developers not to edit runtime files directly – edit templates instead.

```typescript
// @generated [scripts/33a-GenerateStores.ps1] – DO NOT EDIT BY HAND

export interface __INTERFACE_NAME__ {
  // ...
}
```

## 2. Generation Workflow

1. **Developer** executes a scaffold script, e.g.:

```bash
npm run automation:scaffold # delegates to scripts/*.ps1
```

2. **PowerShell** script searches `templates/` for the correct path, performs string-interpolation, writes to `src/`.
3. **Backups** of overwritten files saved to `backup/{timestamp}`.
4. **Tests & linters** run automatically to ensure generated code compiles.

## 3. Adding a New Formation Template

1. Create a file: `templates/domains/formation/data/fibonacciSpiral.json.template`.
2. Use tokens if needed (e.g. `__PARTICLE_COUNT__`).
3. Implement companion docs inside `docs/domain-guides/formation.md`.
4. Run: `powershell scripts/44a-AddFormationTemplate.ps1 -Name "fibonacciSpiral"`.

## 4. Template Tokens Reference

| Token | Replaced With |
|-------|---------------|
| `__DATE__` | UTC ISO timestamp |
| `__AUTHOR__` | Git config user.name |
| `__DOMAIN__` | Domain name (e.g. `particle`) |
| `__SERVICE_NAME__` | CamelCase service name |
| `__CLASS_NAME__` | PascalCase class name |

> Scripts failing to find a required token will halt and emit an error – preventing half-generated code.

## 5. Validation

* `scripts/20-SetupPreCommitValidation.ps1` ensures templates are in-sync with runtime files (hash comparison).
* CI step `compare-templates` blocks merge if drift detected.

## 6. Frequently Asked Questions

**Q:** *Can I bypass templates for a quick hot-fix?*  
**A:** No. Edit the template then regenerate – or your fix will be overwritten.

**Q:** *Can templates be nested?*  
**A:** Yes. Scripts perform recursive copy, preserving hierarchy.

---

See `[directory-structure.md](./directory-structure.md#template-hierarchy)` for folder mapping.