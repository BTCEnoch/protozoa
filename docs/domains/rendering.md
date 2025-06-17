# Rendering Domain

Handles Three.js scene management and rendering. Follows the singleton pattern with dependency injection for Formation and Effect services.

## Interface
```ts
export interface IRenderingService {
  initialize(canvas: HTMLCanvasElement, deps?: { formation?: IFormationService; effect?: IEffectService }): void;
  renderFrame(delta: number): void;
  addObject(obj: Object3D): void;
  removeObject(obj: Object3D): void;
  applyFormation(patternId: string): void;
  applyEffect(effectName: string, options?: any): void;
  dispose(): void;
}
```

## Example Usage
```ts
import { renderingService } from '@/domains/rendering/services/renderingService';

renderingService.initialize(document.querySelector('canvas')!);
requestAnimationFrame(function loop(now) {
  renderingService.renderFrame(now);
  requestAnimationFrame(loop);
});
```

Logging is performed using `createServiceLogger`, `createPerformanceLogger`, and `createErrorLogger` to trace frame timing and errors.
