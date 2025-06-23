# Animation Domain Guide

## Purpose

The **Animation** domain drives temporal changes – moving, scaling or rotating scene entities (particles, groups, post-processing parameters, etc.).  It provides a *single timeline of truth* that other domains can subscribe to, ensuring deterministic playback at the target FPS.

## Public API

```1:22:src/domains/animation/interfaces/IAnimationService.ts
// IAnimationService – core contract
```

Key methods:

| Method | Responsibility |
|--------|----------------|
| `startAnimation(role, config)` | Register a new animation track for the object identified by `role` (usually a particle-id or group-id). |
| `updateAnimations(delta)` | Called each frame (from `RenderingService.renderFrame`) to advance all active animations. |
| `stopAll()` | Cancel and clean up every active animation. |
| `dispose()` | Free resources – mandatory on Hot-Module-Reload. |

### Config Shape

```typescript
interface AnimationConfig {
  duration: number            // seconds
  easing?: 'linear' | 'ease-in' | 'ease-out' | 'ease-in-out'
  type: 'move' | 'scale' | 'rotation' | 'custom'
  // custom key-values depending on type
}
```

## Default Behaviour

* **`duration`** defaults to `1.0` second when omitted.
* **`easing`** falls back to *linear* (no curve).
* All animations are executed on the *client* only – physics remains authoritative for spatial truth.

## Adding a New Animation Type (Template Workflow)

1. Add interface extension token in `templates/domains/animation/types/animation.types.ts.template` (e.g. `type 'color'`).
2. Implement execution logic inside `templates/domains/animation/services/AnimationService.ts.template` → `switch(config.type)`.
3. Scaffold regeneration:

```powershell
scripts/45a-AddAnimationType.ps1 -Type "color"
```

4. Add docs below and create unit tests in `tests/animation/colorAnimation.test.ts`.

## Dependency Injection

`AnimationService` can accept an injected `PhysicsService` (optional) to ensure animated transformations do not conflict with physics constraints (e.g. prevent tunnelling).

## Logging

* Tag: `ANIMATION_SERVICE`
* `logger.debug` – per-frame update details when `process.env.DEBUG_ANIMATION` is `true`.
* `logger.info` – animation start / complete.
* `logger.warn` – illegal parameters, unknown roles.

## Testing Matrix

| Test | File |
|------|------|
| Unit: start/stop lifecycle | `tests/animation/lifecycle.test.ts` |
| Unit: easing curves | `tests/animation/easing.test.ts` |
| Integration: Physics + Animation sync | `tests/integration/physics-animation.test.ts` |

## Future Work

* **Animation blending** – smooth transitions between two config states.
* **GPU timelines** – Offload large-scale animations to GPU instancing matrices.
* **Author-time tooling** – Visual timeline editor in devtools.

---

Return to [Domain Guides index](./README.md).