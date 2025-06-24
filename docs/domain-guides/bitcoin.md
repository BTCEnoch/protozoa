# Bitcoin Domain Guide

_Comprehensive documentation for the Bitcoin domain is under construction._

## Quick Facts

- `BitcoinService` – singleton providing block & inscription data with caching & retry logic.
- Interfaces defined in `domains/bitcoin/interfaces/`.
- Environment-aware endpoints: `https://ordinals.com` in dev, relative paths in prod.

## TODO

- [ ] Diagram request flow & retry back-off.
- [ ] Explain LRU cache internals.
- [ ] Document configuration options (`BitcoinConfig`).
- [ ] Provide usage snippets.
