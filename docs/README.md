# Protozoa Documentation Suite

Welcome to the **Protozoa** documentation suite. This directory provides a comprehensive reference for every part of the Bitcoin Ordinals digital-organism ecosystem – from high-level architecture down to domain-specific extension templates.

## How this documentation is organised

| Section | Purpose |
|---------|---------|
| [overview.md](./overview.md) | Executive summary of the project, MVP scope and key concepts |
| [architecture-overview.md](./architecture-overview.md) | Deep-dive into the Domain-Driven, Template-First architecture, service interactions and data-flow diagrams |
| [directory-structure.md](./directory-structure.md) | Up-to-date map of every folder / significant file, grouped by responsibility |
| [dependencies.md](./dependencies.md) | Third-party libraries (runtime & dev) with concise rationale and version pinning |
| [naming-conventions.md](./naming-conventions.md) | Source-of-truth for files, types, services and React component naming rules |
| [templates-system.md](./templates-system.md) | How the PowerShell automation & `templates/` folder work, plus walk-through for adding new templates |
| [issues-and-gaps.md](./issues-and-gaps.md) | Known technical-debt items, duplication hot-spots, gaps & improvement backlog |
| [domain-guides/](./domain-guides/) | One Markdown file per domain (`bitcoin`, `particle`, …) containing: domain overview, public interfaces, extension points, logging hooks, testing strategy |
| [style-guide/](./style-guide/) | Coding, logging, testing & performance guidelines (mirrors `.cursorrules`) |

> 💡  All documents live inside `docs/` so they can be version-controlled, viewed on GitHub and published via static-site generators (e.g. Docusaurus) later.

## Updating this documentation

1. Follow the Template-First principle – if a script generates new code, introduce the corresponding template **and** update the relevant doc file.
2. Keep tables alphabetically sorted.
3. Link directly to source files using the `startLine:endLine:path` citation format when referencing code snippets.
4. Run `npm run docs` to regenerate API docs with TypeDoc.

---

For a quick start, read `[overview.md](./overview.md)` next.