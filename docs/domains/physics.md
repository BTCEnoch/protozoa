# Physics Domain

Provides vector math utilities and distribution algorithms for particle positioning.

## Interface
```ts
export interface IPhysicsService {
  calculateDistribution(count: number, radius: number): Vector3[];
  applyGravity(position: Vector3, delta: number): Vector3;
  dispose(): void;
}
```

`calculateDistribution` returns random positions within a sphere. `applyGravity` updates a vector using a gravity constant. Logging records calculations for debugging.
