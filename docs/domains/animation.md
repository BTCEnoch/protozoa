# Animation Domain

Controls frame-based animations for particles. Consolidates all animation logic into a singleton service.

## Interface
```ts
export interface IAnimationService {
  startAnimation(role: string, config: AnimationConfig): void;
  updateAnimations(delta: number): void;
  stopAll(): void;
  dispose(): void;
}
```

`startAnimation` begins an animation sequence for a group or role. `updateAnimations` advances all active animations each frame. `stopAll` cancels any running sequences. Logging occurs via `createServiceLogger` and `createPerformanceLogger`.
