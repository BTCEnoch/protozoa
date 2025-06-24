# Group Domain Guide

## Purpose

The **Group** domain adds higher-level organisation on top of individual particles. Groups enable _collective behaviours_ (flocking, schooling, hive-mind) and efficient batch operations (formation changes, effect triggers at once).

There are currently two core services:

1. `GroupService` – organise particles into static groups.
2. `SwarmService` – real-time behavioural flocking (Boids-like).

## Public API

```1:10:src/domains/group/interfaces/IGroupService.ts
// IGroupService (particle grouping)
```

Swarm update interface:

```1:5:src/domains/group/interfaces/ISwarmService.ts

```

## Default Behaviour

- Group ID auto-generated UUID (v4).
- `formGroup` enforces **unique membership** – a particle belongs to only one group at a time.
- `SwarmService.update(delta)` applies separation, cohesion & alignment forces and pipes them into `PhysicsService`.

## Adding Behaviour Templates

1. Add template config to `templates/domains/group/data/behaviours/<behaviour>.json.template` (e.g. `schooling`).
2. Implement rule set inside `SwarmService` `applyBehaviour()`.
3. Document behaviour in this file.

## Dependency Injection

- `PhysicsService` – required for force application.
- `RNGService` – randomness in behavioural variation.

Configure via:

```typescript
SwarmService.getInstance().configureDependencies({ physics, rng })
```

## Logging

- Tag: `SWARM_SERVICE`
- `logger.info` – group create/dissolve.
- `logger.debug` – per-frame alignment vectors when `DEBUG_SWARM=1`.

## Testing Matrix

| Test                        | File                                      |
| --------------------------- | ----------------------------------------- |
| Unit: group lifecycle       | `tests/group/lifecycle.test.ts`           |
| Unit: membership uniqueness | `tests/group/membership.test.ts`          |
| Integration: swarm physics  | `tests/integration/swarm-physics.test.ts` |

## Future Work

- **Dynamic leadership** – elect lead particle per group.
- **Hierarchical groups** – allow nesting (flock of swarms).
- **GPU compute** – flocking shader for 50k+ particles.

---

Back to [Domain Guides index](./README.md).
