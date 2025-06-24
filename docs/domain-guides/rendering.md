# Rendering Domain Guide

## Purpose

The **Rendering** domain orchestrates Three.js – scene setup, camera, renderer and the render-loop. It mediates between the React-Three-Fiber component tree and the imperative domain services (Particle, Effect, Formation).

## Public API

```1:33:src/domains/rendering/interfaces/IRenderingService.ts

```

Key responsibilities:

- Mount `<canvas>` into the provided DOM element.
- Invoke `renderFrame(delta)` each tick (hooked to `requestAnimationFrame`).
- Provide `addObject/removeObject` to other domains for direct Three.js injection.
- Proxy formation & effect calls for convenience.

## Default Pipeline

1. Clear → 2. Update camera controls → 3. Render base scene → 4. Apply post-processing stack (Effect domain) → 5. Read performance metrics.

## Integrating with React

`SimulationCanvas.tsx` obtains the singleton via DI container (`compositionRoot.ts`) and hooks into R3F `useFrame`:

```typescript
function Scene() {
  const rendering = useRenderingService()
  useFrame((_, delta) => rendering.renderFrame(delta))
  return null
}
```

## Dependency Injection

`initialize(parent, { formation, effect })` wires optional domain services to enable UI-driven triggers (e.g. dropdown -> `applyFormation('helix')`).

## Logging

- Tag: `RENDERING_SERVICE`
- `logger.info` – canvas resize, WebGL context loss.
- `perfLog.debug` – ms per frame.

## Testing Matrix

| Test                           | File                                            |
| ------------------------------ | ----------------------------------------------- |
| Unit: add/remove object        | `tests/rendering/object.test.ts`                |
| Integration: formation trigger | `tests/integration/rendering-formation.test.ts` |
| Perf: FPS stability            | `tests/performance/physics.perf.test.ts`        |

## Future Work

- **WebGPU** backend once stable.
- **Multi-canvas** support for minimap or VR.
- **Dynamic resolution scaling** for mobile performance.

---

Back to [Domain Guides index](./README.md).
