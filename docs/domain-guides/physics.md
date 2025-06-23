# Physics Domain Guide

## Purpose

The **Physics** domain simulates forces, gravity, collisions and kinematics.  It provides deterministic, frame-rate–independent integration that keeps particle motion believable at 60 fps.

## Public API

```1:58:src/domains/physics/interfaces/IPhysicsService.ts
```

Highlights:

| Method | Use |
|--------|-----|
| `initialize(config)` | Configure gravity, damping & FPS budget. |
| `applyGravity(particle, dt)` | Mutate `ParticlePhysics` in-place. |
| `distributeParticles(count, pattern, bounds)` | Helper for random/spherical placements. |
| `createTransform/ interpolateTransform` | Utility for scene graph transforms (used by Animation & Rendering). |
| `getMetrics()` | Real-time performance numbers. |

## Integration Loop

`RenderingService.renderFrame` does:

```typescript
const dt = clock.getDelta()
physicsService.applyGlobalForces(dt)
particleService.update(dt)
physicsService.resolveCollisions()
renderingService.renderFrame(dt)
```

## Configuration Defaults

```typescript
const DEFAULT_PHYSICS: PhysicsConfig = {
  targetFPS: 60,
  gravity: -9.81,
  damping: 0.02
}
```

## Adding Custom Force Fields

1. Template: `templates/domains/physics/services/PhysicsService.ts.template` – add case in `applyForces()`.
2. Document force in `docs/physics-custom-forces.md`.
3. Unit-test under `tests/physics/forces/<force>.test.ts`.

## Dependency Injection

`PhysicsService` injects `RNGService` for stochastic forces and `TraitService` for mass scaling per organism.

## Logging

* Tag: `PHYSICS_SERVICE`
* `logger.debug` – per-particle force vector when `DEBUG_PHYSICS=1`.
* `perfLog.info` – frame time >16 ms.

## Testing Matrix

| Test | File |
|------|------|
| Unit: gravity | `tests/physics/gravity.test.ts` |
| Unit: collision impulse | `tests/physics/collision.test.ts` |
| Perf: 60 fps budget | `tests/performance/physics.perf.test.ts` |

## Future Work

* **GPU collision grid** – compute shader broad-phase.
* **Soft-body dynamics** – for membranous organisms.
* **Physics debug HUD** – overlay vectors & bounding boxes.

---

Back to [Domain Guides index](./README.md).