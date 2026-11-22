# S2 on Apple Metal

S2 renders 71 PBR meshes, four directional shadow cascades, 4× MSAA, Bloom and high-quality ambient occlusion at 640 × 360. The Mac had an Apple M5 Pro with a 20-core GPU and ran macOS 26.3.2 (25D2140), Chrome 158 and Xcode 26.6 (17F113). The WebGL2 baseline uses engine commit `b9faebd53`, which includes the uniform-buffer work and the explicit render-pass load/store changes from #3227. The WebGPU candidate includes the instance stream in `fd977b015` and direct uniform-array reads in `441adaeb7`.

## Final GPU busy time

One Metal System Trace attached to Chrome GPU process 9441 throughout four fresh benchmark pages, in WebGL2, WebGPU, WebGPU, WebGL2 order. Each page ran 30 warmup frames and 300 measured frames. GPU busy time is the union of active intervals at all nesting depths within a measured animation-frame window. Overlapping vertex, fragment and compute intervals count once. All 1,200 measured windows contained GPU activity. The thermal state was nominal throughout each window.

| GPU busy per frame, pooled from 600 samples per backend | WebGL2 baseline | WebGPU candidate | Change |
| --- | ---: | ---: | ---: |
| Median | 1.648 ms | 1.458 ms | −11.5% |
| Mean | 2.019 ms | 1.924 ms | −4.7% |
| P90 | 3.268 ms | 3.390 ms | +3.7% |
| P99 | 4.664 ms | 3.977 ms | −14.7% |

The four individual medians were 1.645, 1.462, 1.458 and 1.648 ms, in capture order. All four inspection frames contained 41 draws. Framebuffer hashes repeated within each backend, `d76730c3` for WebGL2 and `9eb83d85` for WebGPU. The candidate meets the S2 GPU-time tolerance on this Mac. System-managed GPU clocks and display scheduling contribute to variation between visits.

## Metal allocation lifetimes

The allocation table follows individual Metal resource IDs from attach time. Each row below gives the total of their reported live sizes at the highest observed point inside that visit, and again at its final measured frame boundary. Times are relative to the first measured frame boundary. The export listed buffers and textures. It did not separately report pipeline layouts or physical residency.

| Visit | Time of peak | Buffer bytes at peak | Texture bytes at peak | Total at peak | Buffer bytes at end | Texture bytes at end |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| WebGL2 first | 551.21 ms | 14,450,688 | 28,999,680 | 43,450,368 | 9,764,864 | 20,398,080 |
| WebGPU first | 1.67 ms | 7,110,656 | 24,313,856 | 31,424,512 | 7,110,656 | 20,316,160 |
| WebGPU second | 1.81 ms | 12,648,448 | 29,425,664 | 42,074,112 | 7,110,656 | 20,316,160 |
| WebGL2 second | 1,636.36 ms | 14,614,528 | 28,114,944 | 42,729,472 | 10,027,008 | 20,398,080 |

Both WebGPU visits finished with 43 buffers and 20 textures. WebGL2 finished with 140 and 142 buffers, respectively, and 31 textures each. The 10,649,600-byte difference between the two WebGPU peaks was already present before their first measured frame. It included a 4,194,304-byte buffer and a 4,325,376-byte texture and had disappeared by the final frame. The per-object labels in the timed capture do not associate these IDs with particular engine attachments or uniform blocks.

WebGPU also produced one 933,888-byte texture entry and release per measured frame in both visits. A separate recording with Dawn labels identified the same per-frame entries as `Dawn_TextureView` throughout all 331 frames. Its labeled upload resources included a 4,194,304-byte `Dawn_DynamicUploaderStaging` buffer, a 131,072-byte `Dawn_MappedAtCreationStaging` buffer and a 65,536-byte engine ordered-update buffer. This table can assign sizes to texture views that reference other storage. The engine's logical resource peaks were 14,677,562 bytes for WebGL2 and 15,346,038 bytes for WebGPU. Physical resident bytes and L1 usage were unavailable.

## Pass attribution before the shader compiler optimization

Earlier separate-process Metal traces used the same scene with the instance stream and the original WGSL uniform-array reads. Across 300 frames per backend the all-depth median was 1.312 ms for WebGL2 and 2.530 ms for WebGPU. The respective means were 1.645 and 2.636 ms. Those traces showed a 737,280-byte higher peak observed allocation size for WebGPU, comprising 1,114,112 more texture bytes and 376,832 fewer buffer bytes. This earlier comparison motivated the following pass investigation.

Whole-frame elapsed GPU queries in a separate run gave medians of 2.325 ms for WebGL2 and 2.519 ms for WebGPU. The WebGL query bracketed the engine update and the WebGPU query spanned the first render timestamp through the last. These elapsed times include gaps between GPU work and differ from the active intervals in Instruments.

The following diagnostic captured the native commands for one steady-state frame and replayed them against the original buffers, shaders and attachments. Each pass completed on the GPU before the next one began. WebGL2 used a 64-bit `TIME_ELAPSED_EXT` query. WebGPU used pass beginning and end timestamps. The figures are medians of the final 11 of 13 replays. Normal rendering permits overlap between these passes.

| Isolated S2 pass | WebGL2 baseline | WebGPU before direct uniform-array reads |
| --- | ---: | ---: |
| Directional shadows, 16 draws | 0.213 ms | 0.134 ms |
| Camera depth, 4 draws | 0.105 ms | 0.089 ms |
| Scalable ambient occlusion | 0.230 ms | 0.258 ms |
| Horizontal bilateral blur | 0.145 ms | 0.269 ms |
| Vertical bilateral blur | 0.145 ms | 0.268 ms |
| Opaque forward, 3 draws with 4× MSAA and color resolve | 0.655 ms | 0.914 ms |
| Transparent forward with color resolve | 0.184 ms | 0.182 ms |

The two blur passes and opaque forward account for 0.506 ms of extra serialized pass time in this build. The two backends used the same target dimensions and draw counts, including two 4× color resolves. The captured WGSL copied 12 blur kernel weights per fragment into a private array. The opaque forward shader copied additional uniform arrays before shading.

The compiler change reads those values directly from the uniform block. A second replay alternated original and optimized pipelines on the same WebGPU device with identical buffers, bind groups and attachments. Over 27 rounds, the median paired duration ratios were 0.508 for horizontal blur, 0.515 for vertical blur and 0.608 for opaque forward. Both 640 × 360 blur textures matched their original RGBA8 bytes exactly. Switching the optimized blur from implicit sampling to explicit LOD zero gave the same timings. Integer texel loads took longer. The shipped shader retains its original sampling behavior.

The emitted GLSL and WGSL both use 16 spiral taps for high-quality SAO, 23 texture reads per bilateral blur and nine native comparison samples for soft-high shadows. The WebGL2 driver’s translated Metal source uses 32-bit floats for these stages and PBR, as does WGSL. The original forward WGSL copied five shadow matrices, four cascade spheres and three light arrays into per-invocation storage. The optimized shader indexes the same std140 data in place. Scalar and two-component arrays use 16-byte physical elements and select their original components at the point of access. A helper which accepts an entire array retains its GLSL value type. The full optimized S2 framebuffer retained the original RGBA8 hash `9eb83d85`. [WGSL compiler](../../../../packages/shader-compiler/src/webgpu/StageInterface.ts)

## Instance uniform uploads

The WebGPU comparison below uses the same S2 input before and after streaming active instance records. Both builds produced the same final RGBA8 hash `9eb83d85`, submitted 41 draws including the draw in a render bundle, and issued one queue submission in the inspection frame.

| Native operations in one steady-state S2 frame | Previous upload | Instance stream |
| --- | ---: | ---: |
| Render passes across the frame | 38 | 21 |
| Directional shadow passes | 13 | 1 |
| Camera depth passes | 4 | 1 |
| Camera forward passes | 3 | 1 |
| Clears of unused instance-buffer bytes | 9 / 1,166,304 bytes | 0 |
| Ordered copies into previously used instance-buffer ranges | 9 / 23,360 bytes | 0 |
| Render-pass bind-group calls | 160 | 112 |
| Peak tracked native instance-buffer backing bytes over the run | 2,228,224 | 262,144 |

Both versions reported 15,346,038 bytes through the engine's logical resource counters. The native instance peak tracks the physical 131,072-byte buffers receiving instance data across initialization and all measured frames. The old allocator reached 17 live buffers and the stream reached two. Other allocations, textures, staging buffers and driver memory fall outside this measurement.

In three interleaved runs per version, the medians from 299 WebGPU submission timestamp samples per run were 2.605, 2.971 and 2.575 ms before streaming and 2.400, 2.135 and 2.489 ms with the stream. The median of the three run medians fell 7.9%. The CPU submission median across the three runs was 0.7 ms for both. This A/B measures the two WebGPU builds separately from the cross-backend Metal GPU measurements.

## Render pass actions and counters

The transparent pass uses `load` for its existing color, depth and stencil attachments. The draw-containing native pass resolves the 4× color attachment and discards its multisample color, depth and stencil at the end. All 331 inspected frames selected these actions. The interrupted-pass regression reads the first set of rendered pixels before continuing, then checks the final resolve and both native store descriptors. [Native rendering tests](../../../src/rhi-webgpu/NativeRendering.test.ts)

The default WebGPU Metal System Trace exported one hardware counter, `RT Unit Active`. The WebGL2 capture exported zero hardware counters. The public Metal counter-set query on this machine returned `timestamp / GPUTimestamp`. Tile-load bytes, tile-store bytes and register spills remain unmeasured. The byte counts in the instance upload table describe explicit buffer operations.

To see engine pass names in Instruments, launch the diagnostic Chrome instance with `--enable-dawn-features=use_user_defined_labels_in_backend`. The separate labeled trace showed `Directional Shadows`, `Camera Depth`, `Camera Forward`, `Camera Transparent`, `ScalableAmbientOcclusion`, `BilateralBlur` and the Bloom passes in the GPU process's Metal encoder events. Its render-interval byte column returned zero for all 12,191 active rows bearing these labels. The timing run used Chrome's normal label settings. [Dawn debugging options](https://dawn.googlesource.com/dawn.git/+/b4ea001870c1e05e4588470e6c8de7f6d17c8845/docs/dawn/debugging.md)

## Reproduction

1. Build the benchmark page against the WebGL2 baseline and the WebGPU candidate. Select `?scene=S2&backend=webgl2` or `?scene=S2&backend=webgpu` respectively. [Benchmark setup](../README.md)
2. Launch a fresh Chrome process, obtain its GPU PID from Chrome DevTools Protocol `SystemInfo.getProcessInfo`, and start `xcrun xctrace record --template 'Metal System Trace' --attach <GPU_PID> --output <name>.trace`. Keep this process alive while opening and retiring four fresh benchmark pages in the order used above. Record the animation-frame boundaries with the browser's time origin for every visit.
3. Stop Instruments after the last inspection frame. Export the `metal-gpu-intervals`, `metal-resource-allocations`, `gpu-counter-info` and `device-thermal-state-intervals` tables. Align the animation-frame boundaries to the trace start time. Filter by GPU PID, clip each active interval to the measured frame and merge overlapping intervals before summing GPU busy time. Pool all measured frames for each backend to calculate the reported percentiles.
4. For allocation peaks, replay the captured allocation and deallocation events in time order, keyed by native resource ID. Start at trace attach time so resources from warmup are included. Sample the live set at each measured boundary and each intervening event, then group the sizes by resource type.
