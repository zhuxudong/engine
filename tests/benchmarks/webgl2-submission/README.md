# WebGL2 rendering benchmarks

Build the engine and the benchmark page from the revision under test, then serve the resulting static files. The same page runs in desktop Chromium and iPhone Safari.

```sh
pnpm build
pnpm -C examples exec vite build ../tests/benchmarks/webgl2-submission --outDir /tmp/galacean-webgl2-benchmark
python3 -m http.server 4173 --directory /tmp/galacean-webgl2-benchmark
```

Choose the scene with the query parameter, for example `http://localhost:4173/?scene=S1`.

For desktop Chromium, the following command runs each scene in a fresh browser and prints the measurements as JSON. Append scene IDs to select a subset.

```sh
node tests/benchmarks/webgl2-submission/run.mjs /tmp/galacean-webgl2-benchmark
```

| Scene | Workload |
| --- | --- |
| S1 | 2,048 independent indexed draws with eight alternating materials at 256 × 256 |
| S2 | PBR scene with four shadow cascades, 4× MSAA, Bloom and ambient occlusion |
| S3 | GPU particle feedback with noise, mesh-surface emission and birth sub-emitters |
| S4 | Fifty PBR variants made visible in ten groups during measurement |
| S5 | The Sponza asset from the repository's glTF example, rendered along a fixed camera path |

The page warms up for 30 frames, times 300 consecutive frames, then counts draw, numeric uniform and buffer calls in a separate frame. S2 through S5 render at a fixed 640 × 360. S5 loads its assets before the timed walk. The JSON includes CPU submission times and intervals between animation frames. Use Metal System Trace separately for GPU time, bandwidth, memory and thermal measurements.

For a revision comparison, build both engine versions with the same benchmark source and use the same browser, device, scene and canvas size. On iPhone, open the server's local network address and collect both traces at nominal thermal state.
