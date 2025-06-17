# Group Domain

Handles clustering of particles into named groups. Supports RNG injection for random assignments.

## Interface
```ts
export interface IGroupService {
  formGroup(particleIds: string[]): ParticleGroup;
  getGroup(id: string): ParticleGroup | undefined;
  dissolveGroup(id: string): void;
  dispose(): void;
}
```

Groups are stored in an internal map. `configure` can inject an `IRNGService` for generating unique identifiers or random assignments.
