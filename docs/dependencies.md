# Dependencies

This document lists all third-party packages used in **Protozoa** along with a short description and justification.

> Versions are pinned in `package.json` to guarantee deterministic builds.

## 1. Runtime Dependencies (`dependencies`)

| Package | Version | Purpose |
|---------|---------|---------|
| `@opentelemetry/api` | 1.7.0 | Trace API surface – vendor-agnostic instrumentation |
| `@opentelemetry/auto-instrumentations-node` | 0.42.0 | Auto-instrument common Node modules for telemetry |
| `@opentelemetry/exporter-jaeger` | 1.23.0 | Export spans to Jaeger backend |
| `@opentelemetry/exporter-zipkin` | 1.23.0 | Export spans to Zipkin backend |
| `@opentelemetry/instrumentation-fs` | 0.12.0 | File-system instrumentation |
| `@opentelemetry/instrumentation-http` | 0.49.1 | HTTP(s) instrumentation |
| `@opentelemetry/resources` | 1.23.0 | Resource attributes for traces |
| `@opentelemetry/sdk-node` | 0.49.1 | Node.js trace SDK |
| `@opentelemetry/semantic-conventions` | 1.23.0 | Semantic attribute constants |
| `@react-three/drei` | ^9.92.7 | R3F helpers (OrbitControls, Text, shader toys) |
| `@react-three/fiber` | ^8.15.11 | React renderer for Three.js |
| `axios` | ^1.6.2 | HTTP client (Ordinals API fetches) |
| `cross-fetch` | ^4.0.0 | Isomorphic fetch polyfill |
| `react` | ^18.2.0 | UI framework |
| `react-dom` | ^18.2.0 | React renderer |
| `three` | ^0.160.0 | GPU-accelerated WebGL 3D engine |
| `winston` | ^3.11.0 | Structured logging (Node fallback) |
| `zustand` | ^4.4.7 | Minimalistic state-management per domain |

## 2. Development Dependencies (`devDependencies`)

| Package | Version | Role |
|---------|---------|------|
| `@playwright/test` | 1.53.1 | End-to-end browser testing |
| `@testing-library/jest-dom` | 6.6.3 | DOM assertions for React tests |
| `@testing-library/react` | 16.3.0 | React Testing Library core |
| `@testing-library/user-event` | 14.6.1 | Simulate user interactions |
| `@types/*` | * | TypeScript typings for Node, React, Three, Winston |
| `@typescript-eslint/*` | 6.14.0 | ESLint rules & parser for TS |
| `@vitejs/plugin-react` | 4.2.1 | FastRefresh, JSX transform |
| `@vitest/*` | 1.0.4 | Vitest coverage & UI |
| `concurrently` | ^8.2.2 | Run scripts in parallel (DX) |
| `cross-env` | ^7.0.3 | Set env vars cross-platform |
| `dotenv` | ^16.3.1 | `.env` loader |
| `eslint` | ^8.55.0 | Static analysis |
| `eslint-plugin-react-*` | 4.6.0 / 0.4.5 | React ESLint rules |
| `husky` | ^8.0.3 | Git hooks |
| `jsdom` | 26.1.0 | DOM env in Node tests |
| `lint-staged` | ^15.2.0 | Run linters on staged files |
| `playwright` | 1.53.1 | Browser automation core |
| `prettier` | ^3.1.1 | Code formatter |
| `rimraf` | ^5.0.5 | Cross-platform `rm -rf` |
| `typedoc` | ^0.25.4 | API documentation generator |
| `typescript` | ^5.2.2 | Type checker |
| `vite` | ^5.0.8 | Lightning-fast dev server & bundler |
| `vitest` | ^1.0.4 | Blazing-fast unit testing |

## 3. Optional Dependencies

| Package | Version | Reason |
|---------|---------|--------|
| `@rollup/rollup-win32-x64-msvc` | ^4.9.0 | Windows CI build fallback (optional) |

## 4. Why no *xyz*?

* **Redux / MobX** – Zustand is sufficient for per-domain stores and reduces boilerplate.
* **Styled-Components / Emotion** – Tailwind CSS (via static `index.css`) covers styling.
* **Backend frameworks** – The app is entirely client-side; blockchain acts as the backend.

---

For details on how these dependencies interact, see `[architecture-overview.md](./architecture-overview.md)` and per-domain guides.