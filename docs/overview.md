# Overview

**Protozoa** is an on-chain application that uses the Bitcoin Ordinals protocol to create, render and evolve digital unicellular organisms, simulated through a custom physics engine and displayed in 3D with Three.js & React-Three-Fiber.

> "Each Bitcoin block becomes the primordial soup that seeds a brand-new organism – its DNA encoded by block header entropy and nurtured by particle-level physics."  
> — Project Vision

## MVP Goals

1. **On-chain provenance** – every organism is minted as an Ordinals inscription; its initial trait values are deterministically derived from the chosen Bitcoin block.
2. **Particle-based simulation** – organisms are rendered as interacting particles governed by Newtonian + custom forces (domains: `physics`, `particle`, `animation`).
3. **Extensible traits & evolution** – traits mutate across blocks or user interactions, enabling emergent behaviour (domain: `trait`).
4. **Composable formations** – reusable templates (e.g. spiral, lattice, swarm) define initial particle layouts (domain: `formation`).
5. **Template-First automation** – all code is generated from PowerShell templates in `/templates`, guaranteeing consistency and rapid scaffolding.

## Tech Stack at a Glance

| Layer         | Technology                                        | Rationale                                                |
| ------------- | ------------------------------------------------- | -------------------------------------------------------- |
| Blockchain    | Bitcoin Ordinals + Ord client                     | Immutable storage & provenance                           |
| Simulation    | TypeScript, custom physics engine                 | Deterministic, reproducible in browser & Node            |
| Rendering     | Three.js, React-Three-Fiber, React 18             | Declarative 3D UI with hook-based components             |
| State         | Zustand                                           | Lightweight reactive stores per domain                   |
| Observability | OpenTelemetry + custom logger (console + Winston) | End-to-end tracing & structured logs                     |
| Tooling       | Vite, Vitest, Playwright, Husky, ESLint, Prettier | Fast DX, strict quality gates                            |
| Automation    | 57+ PowerShell scripts                            | Scaffold domains, services, tests & infra from templates |

## Domain-Driven Structure

```text
domains/
  bitcoin/      # Blockchain access (block info, inscriptions)
  rng/          # Cryptographically-seeded RNGs
  physics/      # Force calculators & integrators
  particle/     # Particle data-structures & pooling
  formation/    # Formation algorithms & templates
  animation/    # Timeline, easing & key-framed effects
  rendering/    # Three.js scene orchestration
  trait/        # Organism traits, mutation rules
  group/        # Swarm & group-level behaviours
  effect/       # Post-processing & visual shaders
```

Each domain follows **Service-First, Singleton** architecture: public contracts live in `interfaces/`, core logic in `services/`, plain data in `types/` and helper maths in `utils/`.

---

Read the rest of the documentation for a deep dive into architecture, contribution guidelines, template mechanics, and per-domain extension hooks.
