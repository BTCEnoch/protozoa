# RNG Domain

Provides deterministic random numbers with optional seeding.

## Interface
```ts
export interface IRNGService {
  random(): number;
  randomInt(min: number, max: number, seed?: number): number;
  dispose(): void;
}
```

A seed can be passed to `randomInt` to reproduce values based on Bitcoin block data. Logging is minimal, but initialization and disposal events are recorded.
