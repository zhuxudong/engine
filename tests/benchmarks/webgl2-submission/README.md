# WebGL2 and WebGPU rendering benchmarks

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
BACKEND=webgpu node tests/benchmarks/webgl2-submission/run.mjs /tmp/galacean-webgl2-benchmark
BACKEND=webgpu PREWARM=1 node tests/benchmarks/webgl2-submission/run.mjs /tmp/galacean-webgl2-benchmark S4
```

| Scene | Workload |
| --- | --- |
| S1 | 2,048 independent indexed draws with eight alternating materials at 256 × 256 |
| S2 | PBR scene with four shadow cascades, 4× MSAA, Bloom and ambient occlusion |
| S3 | 50,000 GPU particles with noise, mesh-surface emission and birth sub-emitters |
| S4 | Fifty PBR variants made visible in ten groups during measurement |
| S5 | The Sponza asset from the repository's glTF example, rendered along a fixed camera path |

The page warms up for 30 frames, times 300 consecutive frames, then counts draw, numeric uniform and buffer calls in a separate frame. S2 through S5 render at a fixed 640 × 360. S5 loads its assets before the timed walk. The JSON includes CPU submission times and intervals between animation frames. Use Metal System Trace separately for GPU time, bandwidth, memory and thermal measurements.

S4 records engine initialization, first draw, elapsed time to first frame and variant preparation separately from the steady frame measurements. `PREWARM=1` prepares the fifty PBR pipelines before introducing those meshes into the scene. On a directly served page use `?scene=S4&backend=webgpu&prewarm`.

Set `CAPTURE_DIRECTORY` to save a PNG of each final framebuffer. The WebGPU runner counts both direct native commands and the indexed draws recorded in render bundles. S1 verifies the 2,048 independent mesh draws before reporting a score.

For a revision comparison, build both engine versions with the same benchmark source and use the same browser, device, scene and canvas size. On iPhone Safari, serve the page from an HTTPS origin trusted by the device or from the device's loopback interface. Collect Metal System Trace separately at nominal thermal state.

To compare the existing gallery scenes, run `node tests/benchmarks/backend-parity/run.mjs` from the repository root after building the packages. Append case names to select scenes and set `CAPTURE_DIRECTORY` to keep both images. The runner reports mean RGB error and the fraction of pixels with a channel difference greater than 20 on an 8-bit scale.
