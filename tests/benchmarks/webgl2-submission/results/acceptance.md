# Rendering acceptance on macOS

The desktop comparison uses WebGL2 revision `b9faebd53`, which includes explicit uniform buffers, automatic packing, instancing and the #3227 load/store changes. The candidate has independent WebGL2 and WebGPU package entries. The benchmark uses the same scene source for all three builds, with 30 warmup frames and 300 measured frames per visit. Chromium 140.0.7339.16 ran on an Apple M5 Pro with macOS 26.3.2. S1 uses a 256 × 256 canvas and S2–S5 use 640 × 360 at DPR 1. The Metal trace uses the Chrome and Xcode versions recorded in its own report. [Benchmark and commands](../README.md)

## Implementation and coverage

| Roadmap stage | What the branch implements and checks |
| --- | --- |
| PR-1, explicit uniform buffers | `8897269de` and `5b0ead9cc` introduce explicit Scene and Camera blocks. WebGL2 checks linked-driver offsets and strides, rendered values, same-frame matrix mutation, and two camera views. [Driver and pixel tests](../../../src/rhi-webgl/GlobalUniformBlocks.test.ts) |
| PR-2, automatic blocks and instancing | `f31cc6d1c` and the subsequent range-cache work generate variant-specific numeric blocks and instance layouts. The suite checks built-in reflection against WebGL2, property ownership, and historical instruction-only assets. The compiler documents which inputs use the compatibility path. [Built-in reflection](../../../src/rhi-webgl/BuiltinUniformReflection.test.ts) · [Shader asset compatibility](../../../../packages/shader-compiler/README.md) |
| Shared contracts and PR-3, WGSL compilation | The six contracts cover data groups, uniform alignment, texture and sampler limits, coordinates, vertex formats and feedback particles. GLSL ES 300 retains language ID 0 and WGSL has ID 1. Native tests link the built-in passes and draw 21 PBR texture properties with a 16-view limit. [Contracts](../../../../packages/rhi-webgpu/README.md#backend-contracts) · [Compiler and native pipeline tests](../../../src/shader-compiler/WebGPUBackend.test.ts) |
| WGPU-1 and WGPU-2, binding and render passes | Bind groups and pipeline state use variant reflection, actual vertex layouts and attachment state. Explicit pass handling preserves partial viewport clears, MSAA across an interrupted pass, and later same-frame writes. Common rendering and loader code use platform interfaces. [Native rendering tests](../../../src/rhi-webgpu/NativeRendering.test.ts) |
| WGPU-3, engine and distribution | The WebGPU package creates a device, renders through the engine, recycles discarded buffers and prepares pipelines asynchronously. Consumer tests exercise ESM and CommonJS and check backend package isolation. [Engine use](../../../../packages/rhi-webgpu/README.md) · [Distribution tests](../../../package-consumer/WebGPUDistribution.test.ts) |
| WGPU-4, effects and scene coverage | WebGPU runs the selected feedback shader as compute, including noise, inherited and orbital velocity, sub-emitters and mesh-surface emission. The desktop gallery and system WebKit captures cover additional rendering paths. The two original Seed projects have a separate fixed-route comparison. [Particle tests](../../../src/rhi-webgpu/ParticleParity.test.ts) · [Image results](desktop-parity.md) · [Sakura and Titan results](../../seed-templates/results.md) |

The earlier PR-1/PR-2 WebGL2 checkpoint also ran S1–S5 on an iPhone 17 Pro Max with Safari 26.6.1. In its single 300-frame S1 visit per revision, median update time fell from 7 to 2 ms. The inspection frame in each visit issued 2,048 indexed draws and produced hash `284056bb`. Separate S1 Xcode traces recorded GPU activity and thermal state without per-frame alignment to the JavaScript samples. The final iPhone WebGPU versus WebGL2 comparison is pending.

## Full engine update and frame pacing

Each cell contains the median CPU update time and the P90 interval between animation frames, in milliseconds. Updates include scene traversal, culling, sorting, binding and submission. S1 uses the final interleaved visits described below for the reference and WebGPU columns. Its candidate WebGL2 cell comes from the earlier single visit. S2–S5 use the archived `b9faebd53` reference and fresh single visits on each candidate backend. In a refresh-limited scene a 16.7 ms interval represents one display refresh.

| Scene | Reference WebGL2 | Candidate WebGL2 | Candidate WebGPU |
| ----- | ---------------: | ---------------: | ---------------: |
| S1    |       3.3 / 16.7 |       2.5 / 16.7 |       2.8 / 16.7 |
| S2    |       0.6 / 16.7 |       0.5 / 16.7 |       0.7 / 16.7 |
| S3    |       0.3 / 16.7 |       0.3 / 16.7 |       0.6 / 16.7 |
| S4    |       0.3 / 16.7 |       0.4 / 16.7 |       0.5 / 16.7 |
| S5    |       0.6 / 16.7 |       0.4 / 16.7 |       0.9 / 16.7 |

S1 renders 2,048 independently allocated indexed meshes with eight alternating materials. The final six visits ran in GL/GPU/GPU/GL/GL/GPU order. Every visit rendered the same RGBA8 hash `284056bb` and reported a 16.7 ms P90 frame interval. Across each backend's three visits, median full-update costs were 3.3 ms on reference WebGL2 and 2.8 ms on WebGPU (15.2% lower). From camera draw-pass entry through final submission, the median fell from 2.2 to 2.0 ms (9.1% lower). The per-visit submission medians were 2.2, 2.3 and 2.2 ms on WebGL2 and 1.9, 2.0 and 2.1 ms on WebGPU.

S3 reported 50,000 live particles following GPU compute simulation. The WebGL2 baseline independently counted the same number of transform-feedback outputs. S5 loads Sponza and measures a full camera circuit after its assets are available. The all-effects Sponza renders are covered by the [image measurements](desktop-parity.md).

## Cold first use and preparation

S4 stages fifty different PBR variants in groups of five. First draw measures the first engine update before those groups enter the scene. Time to first frame includes module load, engine initialization, scene setup and that draw. Preparation runs before the timed appearances of the groups. Switch P99 and maximum cover all 300 measured frame updates, including the ten batch appearances.

| S4 visit | First draw, ms | Time to first frame, ms | Preparation, ms | Switch P99, ms | Switch maximum, ms |
| --- | --: | --: | --: | --: | --: |
| Reference WebGL2 | 5.2 | 53.4 | 0.0 | 30.1 | 34.4 |
| Candidate WebGL2 | 6.3 | 61.3 | 0.0 | 29.7 | 37.6 |
| WebGPU on first use | 3.7 | 75.8 | 0.0 | 23.8 | 72.8 |
| WebGPU with asynchronous preparation | 3.6 | 69.8 | 328.8 | 1.8 | 2.2 |

The platform shader cache persists across browser processes. In a separate controlled WebGL2 experiment, a fixed tiny change to the fragment output produced a new native program. Its first five-program batch took 837.8 ms, including 821.2 ms waiting for the native link result. A new browser process running the same modified shader took 35.8 ms for that batch, including 23.2 ms waiting for the link result. JavaScript macro expansion and layout took 11.5 and 8.0 ms respectively. This explains why cold hitches can exceed the repeat-visit values above on either WebGL2 revision.

Eight additional visits to a loopback HTTP production server used a fresh browser profile each time. Median navigation-to-first-update time was 74.45 ms for reference WebGL2 and 85.85 ms for WebGPU. Module import took 26.10 and 30.45 ms, engine creation took 11.25 and 13.45 ms, and the first update itself took 5.15 and 3.70 ms. WebGPU acquired its adapter and device in a combined 2.70 ms while configuration and WASM setup ran concurrently.

## Native GPU and memory

The final S2 Metal trace alternated WebGL2, WebGPU, WebGPU and WebGL2 in one Chrome GPU process at nominal temperature. Over 600 frames per backend, all-depth GPU-active interval medians were 1.648 and 1.458 ms. The observed allocation peaks varied by visit. The Mac exposed timing counters. Register spills and offscreen tile-store bytes still require separate hardware measurements. [Metal captures, resource attribution and procedure](metal-s2.md)

## Performance gates

| Dimension | Desktop result | Acceptance status |
| --- | --- | --- |
| CPU draw submission | S1 camera entry through submission improves from 2.2 to 2.0 ms across six interleaved visits (9.1%). | Below the 30% target. The table above also gives the separate costs of running WebGL2 through the new code on all five scenes. |
| GPU execution | S2 Metal median active time falls from 1.648 to 1.458 ms (11.5%). | The measured GPU time clears the non-regression threshold. Register-spill counts remain unmeasured. |
| Bandwidth and memory | S2's two WebGPU visits peak at 31.42 and 42.07 MB in tracked Metal resources, compared with 43.45 and 42.73 MB for WebGL2. Engine-accounted logical resources peak at 15.35 and 14.68 MB for WebGPU and WebGL2 respectively. | Partial. The trace sums reported sizes of live Metal objects, including texture views. Physical residency, tile store bytes and long-run growth remain open. [Allocation scope](metal-s2.md) |
| First frame and shader switches | With preparation, S4 switch P99 and maximum fall to 1.8 and 2.2 ms. Eight fresh-profile HTTP visits give median navigation-to-first-update times of 74.45 ms on reference WebGL2 and 85.85 ms on WebGPU. | Prepared switching clears the baseline in these visits. Total cold-start latency misses the non-regression goal. |
| Compute and large scenes | S3 simulates 50,000 particles. S3 and Sponza S5 both record a 16.7 ms P90 frame interval on each backend. | Desktop pacing reaches parity at this display refresh rate. Real-world Seed results are reported per template, effect and camera path. Final iPhone frame pacing and background/foreground recovery remain pending. [Seed results](../../seed-templates/results.md) |

## Verification

On November 22, 2026 at revision `025ceb7b0`, `pnpm build` completed shader precompilation, module bundling and package type generation. The Chromium integration suite passed **4,446 tests across 241 files**. Package-consumer tests passed **54/54** and Spine packaging passed **5/5**. `pnpm lint` reported zero errors and 1,359 warnings.

The final desktop gallery rerun passed **303 image comparisons across 101 scenes**. Each scene compared WebGL2 and WebGPU separately with its historical JPEG, then compared their two live framebuffers. Particle noise produced the largest live-backend difference, 1.04833 RGB levels on average, with 0.782292% of pixels differing by more than 20 levels in at least one channel. [Gallery measurements and reproduction](desktop-parity.md)

The remaining device gates are Safari WebGPU versus WebGL2 timing, foreground recovery after backgrounding the app, and the iPhone hardware counters for the final candidate. Desktop Chromium also exercises resource recreation after device loss. [Native recovery test](../../../src/rhi-webgpu/NativeRendering.test.ts)
