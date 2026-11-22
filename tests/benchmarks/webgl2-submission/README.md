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
| S1 | 2,048 distinct meshes and indexed draws with eight alternating materials at 256 × 256 |
| S2 | PBR scene with four shadow cascades, 4× MSAA, Bloom and ambient occlusion |
| S3 | 50,000 GPU particles with noise, mesh-surface emission and birth sub-emitters |
| S4 | Fifty PBR variants made visible in ten groups during measurement |
| S5 | The Sponza asset from the repository's glTF example, rendered along a fixed camera path |

The page warms up for 30 frames, times 300 consecutive frames, then counts draw, numeric uniform and buffer calls in a separate frame. S2 through S5 render at a fixed 640 × 360. S5 loads its assets before the timed walk. The JSON includes CPU submission times and intervals between animation frames. Use Metal System Trace separately for GPU time, bandwidth, memory and thermal measurements.

S4 records engine initialization, first draw, elapsed time to first frame and variant preparation separately from the steady frame measurements. `PREWARM=1` prepares the fifty PBR pipelines before introducing those meshes into the scene. On a directly served page use `?scene=S4&backend=webgpu&prewarm`.

Set `CAPTURE_DIRECTORY` to save a PNG of each final framebuffer. The WebGPU runner counts both direct native commands and the indexed draws recorded in render bundles. S1 verifies the 2,048 independent mesh draws before reporting a score.

For a separate instrumented run, set `GPU_TIMING=1`. WebGL2 reports completed, non-disjoint frame timer queries when supported. WebGPU reports available submission timestamp spans. A frame can contain several submissions. The JSON identifies the scope and sample count. Engine resource bytes cover textures and buffers accounted for by the engine. Use Metal System Trace for the driver's allocation peak and tile traffic.

For a revision comparison, build both engine versions with the same benchmark source and use the same browser, device, scene and canvas size. On iPhone Safari, serve the page from an HTTPS origin trusted by the device or from the device's loopback interface. Collect Metal System Trace separately at nominal thermal state.

To compare the existing gallery scenes, run `node tests/benchmarks/backend-parity/run.mjs` from the repository root after building the packages. Append case names to select scenes and set `CAPTURE_DIRECTORY` to keep both images. The runner reports mean RGB error and the fraction of pixels with a channel difference greater than 20 on an 8-bit scale.

Set `GOLDENS=1` to compare each backend with the corresponding historical gallery JPEG in the checkout or its local Git LFS object store. This catches regressions shared by both backends. For example, a mesh emitting no particles can otherwise produce two identical backgrounds.

Use `?scene=Recovery&backend=webgpu&background` to exercise a real page background/foreground transition. Switch away once the page's result element has `data-recovery="awaiting-background"`, then return. The result reports visibility events, spontaneous device losses, and the readback of a red mesh before and a green mesh after an explicit loss and restore. Omit `background` to run only the explicit device-loss regression.

S1 allocates independent geometry for every renderer. Add `&sharedMesh` to the page URL for the companion case with the same draw count, pixels and materials, and a single shared mesh resource.

### Desktop image comparisons

Set `S5_EFFECTS=all` to render Sponza with HDR, high-quality ambient occlusion, four soft shadow cascades and 4× MSAA. Choose `no-sao`, `no-shadows` or `no-msaa` to isolate one effect. The page accepts the same values through `?scene=S5&effects=all`. Without the option the original S5 performance workload is unchanged.

```sh
export S5_EFFECTS=all CAPTURE_DIRECTORY=/tmp/galacean-sponza
node tests/benchmarks/webgl2-submission/run.mjs /tmp/galacean-webgl2-benchmark S5
BACKEND=webgpu node tests/benchmarks/webgl2-submission/run.mjs /tmp/galacean-webgl2-benchmark S5
node tests/benchmarks/backend-parity/compare.mjs "$CAPTURE_DIRECTORY/webgl2-S5.png" "$CAPTURE_DIRECTORY/webgpu-S5.png"
```

On macOS, compile the small WKWebView runner with the installed Xcode tools and visit the same locally served page through the system WebKit framework. Each invocation writes the benchmark JSON to standard output and the optional PNG from the final framebuffer to disk.

```sh
xcrun swiftc tests/benchmarks/webgl2-submission/SystemWebKit.swift -o /tmp/galacean-system-webkit
/tmp/galacean-system-webkit 'http://127.0.0.1:4173/?scene=S5&effects=all&backend=webgl2' /tmp/wk-gl.png
/tmp/galacean-system-webkit 'http://127.0.0.1:4173/?scene=S5&effects=all&backend=webgpu' /tmp/wk-gpu.png
node tests/benchmarks/backend-parity/compare.mjs /tmp/wk-gl.png /tmp/wk-gpu.png
```

The AO and refraction regression exercises the canvas and an explicit render target on each backend. The dynamic cube probe regression reads back each face before and after a second capture. See the [desktop image results](results/desktop-parity.md) for the measured differences and their references.
