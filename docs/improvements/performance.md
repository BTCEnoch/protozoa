# Performance Improvements

| Area | Current | Issue | Improvement | Est. Gain |
|------|---------|-------|-------------|-----------|
| FPS budget | 58–62 fps on desktop (100k particles) | Occasional 20 ms spikes when applying effects | Move effect particle updates to Web Worker with OffscreenCanvas | +8 fps consistency |
| Bundle size | 2.6 MB gzipped | Drei + Three full build pulled in | Use `three/examples/jsm/…` tree-shake imports; leverage `vite-plugin-three` | –400 KB |
| Physics | JS single-thread | Main thread saturates with >150k particles | WebAssembly SIMD for integrator loop | 3× throughput |
| Memory | 350 MB peak GPU | InstancedMesh geometry not disposed on organism switch | Call `geometry.dispose()` in `RenderingService.dispose` | −150 MB |
| API latency | 800 ms avg block fetch | No CDN; fetches `ordinals.com` | Implement Cloudflare Worker cache or multihomed endpoints | 10× faster misses |

---

## Micro-Optimisations

1. Replace `new Vector3()` in loops with shared pool objects.  
2. Use `Float32Array` for particle attributes; upload as interleaved buffer.
3. Clamp `delta` in physics to 1/30 s to avoid spiral of death.
4. Debounce resize handler in `RenderingService`.

---

## Monitoring Plan

* Integrate `stats.js` overlay in dev builds.
* Add Prometheus exporter for performance metrics (fps, memory, drawCalls).