# RNG Domain Guide

## Purpose

Randomness is foundational – it seeds organism traits, particle distribution, mutation events and shader noise.  The **RNG** domain provides *deterministic, seed-able* random number generators with purpose-specific streams.

## Public API

```1:150:src/domains/rng/interfaces/IRNGService.ts
```

Key concepts:

* **Main generator** – PRNG seeded from Bitcoin block hash; used for default randomness.
* **Purpose RNG** – isolated generators obtained via `getPurposeRng('particle-init')`.
* **Batch generation** – high-volume generation for physics jitter.

## Default Behaviour

* Algorithm: *Mulberry32* (fast, 2^32 period) – can be swapped by setting `RNGConfig.algorithm`.
* Max chain length in `rehashSeed()` limited to 10 to prevent infinite loops.

## Seeding from Blockchain

`seedFromBlock(blockNumber)` fetches header via `BitcoinService.getBlockInfo` and hashes `(nonce + merkleRoot)`.

## Adding a New Algorithm

1. Implement function in `templates/domains/rng/utils/algorithms/<name>.utils.ts.template` returning `[0,1)` float.
2. Add to `RNGConfig.algorithm` union.
3. Unit-test with `tests/rng/quality/<name>.test.ts` (Chi-square, KS tests).

## Dependency Injection

Stateless; however, other domains *inject* RNG via constructor or `configureDependencies`.

## Logging

* Tag: `RNG_SERVICE`
* `logger.debug` – seed changes, purpose RNG creation.

## Testing Matrix

| Test | File |
|------|------|
| Unit: determinism | `tests/rng/determinism.test.ts` |
| Unit: purpose isolation | `tests/rng/purpose.test.ts` |
| Stat: Chi-square | `tests/rng/quality/chisquare.test.ts` |

## Future Work

* **Crypto-secure RNG** fallback using WebCrypto for security-sensitive flows.
* **WebAssembly SIMD** to speed up batch generation.

---

Back to [Domain Guides index](./README.md).