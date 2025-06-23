# Effect Domain Guide

## Purpose

The **Effect** domain is responsible for **transient visual phenomena** – particle trails, nebula bursts, mutation sparkles, etc.  Effects do *not* affect physics or traits; they purely enhance aesthetics and user feedback.

## Public API

```1:33:src/domains/effect/interfaces/IEffectService.ts
// IEffectService – abbreviated excerpt
```

Critical entry-points:

| Method | Description |
|--------|-------------|
| `createEffect(type, position, config)` | Factory generating an effect instance. Returns `Promise<IEffectInstance>` once GPU resources are uploaded. |
| `updateEffects(delta)` | Ticked from `RenderingService.renderFrame`. |
| `registerMutationHook(hook)` | Binds trait changes → effect triggers (cross-domain). |
| `getMetrics()` | Real-time performance data (GPU memory, active effects). |
| `dispose()` | Destroy FBOs, release materials & geometries. |

Full interface also contains convenience helpers for common effects (nebula, sparkle, etc.).

## Default Configuration

Values live in `templates/domains/effect/services/EffectService.ts.template`:

```typescript
const DEFAULT_CONFIG: IEffectServiceConfig = {
  maxConcurrentEffects: 128,
  enableGPUOptimization: true,
  defaultDuration: 2,
  enableMutationHooks: true,
  enablePerformanceMonitoring: true,
  particlePoolSize: 10_000,
  gpuMemoryLimit: 256 * 1024 * 1024 // 256 MB
}
```

## Adding a New Effect

1. Extend `EffectType` union in `templates/domains/effect/interfaces/IEffectService.ts.template`.
2. Create GLSL / shader-material under `templates/domains/effect/shaders/<yourEffect>.glsl.template`.
3. Implement builder in `EffectFactory` switch.
4. Regenerate via:

```powershell
scripts/46a-AddEffectType.ps1 -Type "energy_wave"
```

## Caching & Pooling

* **Particle pool** reused across effects to minimise GPU allocate/free. Resize via `setEffectLimit()`.
* Framebuffer objects (FBO) cached by resolution.

## Dependency Injection

`EffectService` is injected into `RenderingService` so that post-processing passes (Bloom, DOF) can be chained seamlessly.

## Logging

* Tag: `EFFECT_SERVICE`
* `logger.debug` – per-frame update & GPU stats.
* `perfLog.info` – long-frame (>33 ms) warnings.

## Testing Matrix

| Test | File |
|------|------|
| Unit: create/remove lifecycle | `tests/effect/lifecycle.test.ts` |
| Unit: mutation hook dispatch | `tests/effect/mutationHook.test.ts` |
| Performance: max concurrent | `tests/performance/effect.perf.test.ts` |

## Future Work

* **VFX graph editor** – node-based authoring.
* **GPU Compute** – harness WebGPU once available.
* **Audio reactivity** – link FFT bins to effect intensity.

---

Back to [Domain Guides index](./README.md).