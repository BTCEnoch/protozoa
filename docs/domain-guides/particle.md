# Particle Domain Guide

## Purpose

The **Particle** domain is the *heart* of Protozoa – it stores particle state, performs pooling, and interfaces with physics and rendering.  A **particle** represents the smallest visual constituent of an organism.

## Public API

```1:150:src/domains/particle/interfaces/IParticleService.ts
```

Important structs: `ParticleInstance`, `ParticleSystem`, `ParticleConfig`.

## Default Configuration

Defined in `templates/domains/particle/services/ParticleService.ts.template`:

```typescript
const DEFAULT_CONFIG: ParticleConfig = {
  maxParticles: 100_000,
  useInstancing: true,
  useObjectPooling: true,
  defaultMaterial: 'basic',
  enableLOD: true,
  cullingDistance: 1500
}
```

## Object Pooling Strategy

* **Pool size** equals `maxParticles`; freelist implemented as stack (`#poolIndices`).
* `returnParticleToPool()` called from `ParticleLifecycleEngine` when `age > lifetime`.

## Interactions with Other Domains

| Domain | Interaction |
|--------|-------------|
| `Physics` | `update(delta)` syncs position/velocity/acceleration. |
| `Rendering` | `render(scene)` writes particle data into instanced mesh matrices. |
| `Formation` | `addParticles()` positions new particles according to pattern. |
| `Group` | Group membership stored in `ParticleInstance.userData.groupId`. |

## Adding a New Particle Type

1. Extend `ParticleType` enum in `templates/domains/particle/types/particle.types.ts.template`.
2. Provide default material & size in `ParticleDefaults` map.
3. Run scaffold:

```powershell
scripts/47a-AddParticleType.ps1 -Type "spore"
```

4. Add rendering shader snippet in `templates/domains/particle/shaders/`.

## Logging

* Tag: `PARTICLE_SERVICE`
* `logger.debug` – pool hits/misses when `DEBUG_PARTICLE_POOL=1`.
* `perfLog.info` – frame metrics (particles rendered, memory usage).

## Testing Matrix

| Test | File |
|------|------|
| Unit: pool reclaim | `tests/particle/pool.test.ts` |
| Unit: lifetime expiry | `tests/particle/lifetime.test.ts` |
| Performance: 100k particles | `tests/performance/particle.perf.test.ts` |

## Future Work

* **GPU Instancing v2** – structured buffers for per-particle data.
* **Physics-on-GPU** – compute shader to update positions.
* **Editor overlays** – gizmos for particle system bounds.

---

Back to [Domain Guides index](./README.md).