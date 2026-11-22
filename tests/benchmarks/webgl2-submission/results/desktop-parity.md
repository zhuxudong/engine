# Desktop rendering parity

These measurements use an Apple M5 Pro with a 20-core GPU and macOS 26.3.2 (25D2140). Chromium 140.0.7339.16 used ANGLE/Metal for WebGL2. The system WKWebView used WebKit 21623.2.7.11.7, shipped with Safari 26.3.1. Desktop WKWebView exercises Apple's installed WebKit and GPU driver. iPhone measurements require a separate run.

## Image measurements

Mean RGB is the average absolute difference over all red, green and blue bytes on a 0–255 scale. A changed pixel has at least one channel differing by more than 20. The 99th percentile and maximum use the largest channel difference at each pixel. Alpha is excluded. Captures below use the native framebuffer. Each S2, S3 and S5 run used a fixed 640 × 360 buffer, 30 warmup frames, 300 measured frames and one final inspection frame.

| Workload | Browser | Reference | Mean RGB | Changed pixels |
| --- | --- | --- | ---: | ---: |
| S2, 71 PBR meshes, four shadow cascades, 4× MSAA, Bloom and high-quality SAO | System WebKit | Same-browser WebGL2 | 0.02095 | 0 / 230,400 |
| S3, 50,000 particles with fixed particle seeds, mesh emission and a birth sub-emitter | System WebKit | Same-browser WebGL2 | 0.00217 | 14 / 230,400 |
| S5, Sponza with all effects | Chromium | Same-browser WebGL2 | 0.07740 | 0 / 230,400 |
| S5, Sponza with all effects | System WebKit | Same-browser WebGL2 | 0.07742 | 0 / 230,400 |
| S5, default Sponza workload | System WebKit | Same-browser WebGL2 | 0.26809 | 366 / 230,400 |

The S5 fixture loads the glTF from the repository's Sponza example, with 103 primitives and 262,267 triangles. The camera follows a closed path through the central nave. The effects option enables HDR, high-quality SAO, four soft directional shadow cascades and 4× MSAA. The Chromium image differs by at most 16, with a 99th percentile of 1. Before correcting the screen-space Y coordinate used to sample the camera AO texture, the same Chromium pair had a mean error of 7.54285, 6.448% changed pixels and a maximum error of 48. The WebGL2 captures before and after the correction were byte-identical.

On system WebKit, the full camera walk exposed a second issue. Before recording sampled bind groups for each bundled draw, the all-effects pair had a mean error of 6.64467 and 10.868% changed pixels at the end of the walk. Keeping the camera still for 300 frames hid this difference. The corrected full walk has a 99th percentile of 1 and a maximum of 2. The default workload has a 99th percentile of 4 and a maximum of 126. Both comparisons use the WebGL2 output from the same system WebKit version.

## Historical gallery images

All 101 existing gallery scenes ran in Chromium at 1,200 × 800, using the gallery's normal page template, font and asset paths. Each backend's frozen frame was compared with the original JPEG in Git LFS and the two backends were compared directly. All 303 comparisons passed the thresholds of mean RGB error ≤ 3 and changed pixels ≤ 2.5%. Each cell below is the maximum across all scenes.

| Captured backend | Reference | Largest mean RGB | Largest changed fraction |
| --- | --- | ---: | ---: |
| WebGL2 | Historical JPEG | 0.04631 | 0.000313% |
| WebGPU | Historical JPEG | 1.04841 | 0.782292% |
| WebGPU | Same-run WebGL2 | 1.04833 | 0.782292% |

The particle-noise scene had the largest cross-backend difference. Horizontal billboard particles had the largest WebGL2 mean difference from a historical image. The gallery covers the original particle modules, skinned and morph-target meshes, compression, instancing, transparent shadows, postprocessing, primitive topologies, physics, text and Spine. The force-over-lifetime variant exercises scalar output arguments targeting vector components. After compilation its WebGPU image differed from its historical JPEG by 0.02831 RGB levels on average and at most 6 per channel.

## Localized regressions

The camera texture test places a dark row above a white row in the AO texture. A second case renders tinted transmissive glass in front of a red upper half and a green lower half. Both tests sample the output rows of the presented canvas and a user-supplied render target on each backend. This checks the vertical orientation of the PBR consumers independently of the AO generator and uses distinct colors to verify transmission. The dynamic cube probe test captures six distinct colored directions with 4× MSAA, changes the scene and verifies both the new cube and the previous cube by native readback.

## Reproduction

Follow the [benchmark instructions](../README.md#desktop-image-comparisons) to build both backends, capture S5 with its optional effects and compare the resulting PNG files. For the gallery JPEGs run `GOLDENS=1 node tests/benchmarks/backend-parity/run.mjs --all`. The camera texture and cube probe tests live in [CameraTextureUV.test.ts](../../../src/rhi-webgpu/CameraTextureUV.test.ts) and [CubeProbe.test.ts](../../../src/rhi-webgpu/CubeProbe.test.ts).
