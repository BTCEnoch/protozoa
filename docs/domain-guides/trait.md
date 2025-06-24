# Trait Domain Guide

## Purpose

The **Trait** domain manages _organism DNA_ – numerical descriptors like colour palette, metabolism rate, aggressiveness, etc. Traits are **deterministically** generated from Bitcoin block data and can mutate across generations.

## Public API

```1:66:src/domains/trait/interfaces/ITraitService.ts

```

### Core Methods

| Method                                    | Role                                                                                                                              |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `generateTraits(blockNumber, parentIds?)` | Deterministically derive a new `OrganismTraits` object, seeded by block hash and optionally blended with parents for inheritance. |
| `mutateTraits(traits, rate?)`             | Apply stochastic mutations (rate `0–1`) using `RNGService`.                                                                       |
| `getMetrics()`                            | Returns counters for traits generated, mutations applied, cache hit-rate.                                                         |

## Trait Data Model

`OrganismTraits` is defined in `domains/trait/types/trait.types.ts` and grouped into _visual_, _behavioural_, _evolutionary_, _mutation_ categories to enable future expansion.

## Cache System

To avoid expensive hash→trait calculations, `TraitService` caches the most-recent 256 generations keyed by `blockNumber`. LRU eviction on overflow.

## Mutation Engine

- Base mutation rate from `TraitConfig.baseMutationRate` (default 2%).
- Individual trait weights loaded from `templates/domains/trait/data/mutationWeights.json.template`.
- Hooks – `EffectService.registerMutationHook` visualises mutations.

## Dependency Injection

`TraitService` uses:

- `BitcoinService` – to fetch block header data. 800 ms retry w/ exponential back-off.
- `RNGService` – to apply mutation randomness.

Configure via `compositionRoot.ts`.

## Logging

- Tag: `TRAIT_SERVICE`
- `logger.info` – trait generation, mutation events.
- `logger.warn` – cache misses over threshold.
- `logger.error` – Bitcoin API failures.

## Testing Matrix

| Test                           | File                                     |
| ------------------------------ | ---------------------------------------- |
| Unit: deterministic generation | `tests/trait/generation.test.ts`         |
| Unit: mutation distribution    | `tests/trait/mutation.test.ts`           |
| Integration: effect hook       | `tests/integration/trait-effect.test.ts` |

## Future Work

- **Epigenetic traits** – environment-driven (FPS, user interaction) adjustments.
- **Cross-organism interaction** – trait influence via proximity.

---

Back to [Domain Guides index](./README.md).
