# Particle Domain

Maintains the simulation's particle entities. Creation and updates rely on injected Physics and Rendering services.

## Interface
```ts
export interface IParticleService {
  createParticle(initialTraits?: object): Particle;
  getParticleById(id: string): Particle | undefined;
  updateParticles(delta: number): void;
  dispose(): void;
}
```

Particles are stored in a private map keyed by ID. `configureDependencies` injects `IPhysicsService` and `IRenderingService` so this domain remains decoupled. Trait assignment uses `TraitService` during creation.
