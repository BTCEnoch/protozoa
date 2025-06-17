# Domain‑Driven Architecture

The project uses a strict domain structure. Each domain exposes a single service implementing an interface. All services follow the `static #instance` singleton pattern and provide a `dispose()` method for cleanup. Domains interact only via interfaces injected at initialization to maintain isolation.

## Domain List
- **Rendering** – Three.js scene management
- **Animation** – Frame updates and easing functions
- **Effect** – Visual particle effects
- **Trait** – Organism trait definitions and mutations
- **Physics** – Vector math and particle distribution
- **Particle** – Lifecycle management of particles
- **Formation** – Geometric pattern placement
- **Group** – Clustering and management of particle groups
- **RNG** – Seeded random number generation
- **Bitcoin** – Access to blockchain data

Scripts automate project scaffolding, pattern enforcement and compliance checks.
