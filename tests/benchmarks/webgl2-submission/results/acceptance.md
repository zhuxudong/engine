# Rendering acceptance on macOS

The reference is `b9faebd53`, which contains the explicit uniform buffers, automatic packing, instancing and #3227 load/store work. Each build used the same benchmark scene source and a fresh Chromium 140.0.7339.16 process per scenario. The machine was an Apple M5 Pro running macOS 26.3.2. Each visit warmed up for 30 frames and recorded the next 300. The S1 canvas is 256 × 256 and the remaining scenes use 640 × 360 at DPR 1.

## Full engine update and frame pacing

Each cell contains the median CPU update time and the P90 interval between animation frames, in milliseconds. Updates include scene traversal, culling, sorting, binding and submission. In a refresh-limited scene a 16.7 ms interval represents one display refresh.

| Scene | Reference WebGL2 | Candidate WebGL2 | Candidate WebGPU |
| --- | ---: | ---: | ---: |
| S1 | 3.4 / 16.7 | 2.5 / 16.7 | 2.7 / 16.7 |
| S2 | 0.6 / 16.7 | 0.8 / 16.7 | 0.9 / 16.7 |
| S3 | 0.3 / 16.7 | 0.4 / 16.7 | 0.4 / 16.7 |
| S4 | 0.3 / 16.7 | 0.4 / 16.7 | 0.7 / 16.7 |
| S5 | 0.6 / 16.7 | 0.3 / 16.7 | 0.6 / 16.7 |

S1 renders 2,048 independently allocated indexed meshes with eight alternating materials. All three outputs had RGBA8 hash `284056bb`. An additional six visits in GL/GPU/GPU/GL/GL/GPU order instrumented the interval from camera draw-pass entry through final queue submission. Median full-update costs across each backend's three visits were 3.2 ms on reference WebGL2 and 2.9 ms on WebGPU (9.4% lower). The corresponding draw-through-submit times were 2.2 ms and 2.1 ms (4.5% lower).

S3 reported 50,000 live particles following GPU compute simulation. The WebGL2 baseline independently counted the same number of transform-feedback outputs. S5 loads Sponza and measures a full camera circuit after its assets are available. The all-effects Sponza renders are covered by the [image measurements](desktop-parity.md).

## Cold first use and preparation

S4 stages fifty different PBR variants in groups of five. First draw measures the first engine update before those groups enter the scene. Time to first frame includes module load, engine initialization, scene setup and that draw. Preparation runs before the timed appearances of the groups.

| S4 visit | First draw, ms | Time to first frame, ms | Preparation, ms | Switch P99, ms | Switch maximum, ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Reference WebGL2 | 5.2 | 53.4 | 0.0 | 30.1 | 34.4 |
| Candidate WebGL2 | 6.1 | 58.3 | 0.0 | 29.5 | 35.8 |
| WebGPU on first use | 3.6 | 81.6 | 0.0 | 21.6 | 50.3 |
| WebGPU with asynchronous preparation | 3.6 | 81.5 | 330.0 | 1.5 | 1.9 |

The platform shader cache persists across browser processes. In a separate controlled WebGL2 experiment, a fixed tiny change to the fragment output produced a new native program. Its first five-program batch took 837.8 ms, including 821.2 ms waiting for the native link result. A new browser process running the same modified shader took 35.8 ms for that batch, including 23.2 ms waiting for the link result. JavaScript macro expansion and layout took 11.5 and 8.0 ms respectively. This explains why cold hitches can exceed the repeat-visit values above on either WebGL2 revision.

Eight additional visits to a loopback HTTP production server used a fresh browser profile each time. Median navigation-to-first-update time was 74.45 ms for reference WebGL2 and 85.85 ms for WebGPU. Module import took 26.10 and 30.45 ms, engine creation took 11.25 and 13.45 ms, and the first update itself took 5.15 and 3.70 ms. WebGPU acquired its adapter and device in a combined 2.70 ms while configuration and WASM setup ran concurrently.

## Native GPU and memory

The final S2 Metal trace alternated WebGL2, WebGPU, WebGPU and WebGL2 in one Chrome GPU process at nominal temperature. Over 600 frames per backend, all-depth GPU-active interval medians were 1.648 and 1.458 ms. The observed allocation peaks varied by visit. The Mac exposed timing counters. Register spills and offscreen tile-store bytes still require separate hardware measurements. [Metal captures, resource attribution and procedure](metal-s2.md)

## Delivery status

Build verification at source revision `9a4235b35` passed all 4,439 tests across 241 suites, 54 package-consumer checks and five Spine packaging checks. Lint reported zero errors and 1,359 warnings. All 101 gallery cases passed the two-backend and historical-JPEG comparisons.

The S1 draw submission improvement remains below the 30% target. The S4 results distinguish faster prepared variant switches from total cold-start latency. On the Mac, S3 and S5 had the same 16.7 ms P90 frame interval on both backends. The iPhone Safari measurements, background/foreground recovery and on-device Xcode counters are deferred at the owner's request.
