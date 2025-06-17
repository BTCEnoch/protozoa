# Formation Domain

Defines geometric formations for particle positioning. Provides caching for computed layouts and supports transitions via a separate blending service.

## Interface (excerpt)
```ts
export interface IFormationService {
  getFormationPattern(patternId: string): FormationPattern | undefined;
  applyFormation(patternId: string, particleIds: string[]): void;
  dispose(): void;
}
```

Formations may be loaded from `formation/data` files. `applyFormation` positions particles using injected services (e.g., PhysicsService) without importing them directly. Blending between formations can be delegated to `FormationBlendingService`.
