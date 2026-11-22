# Desktop Seed World benchmark

The benchmark loads the original Sakura Pearl and Titan Wasteland projects from Galacean's `experimental/engine-next` commit `92ea60eaee49b2f1188b373c178c34ca511c9f87`. It exercises the native grass, vegetation, terrain horizon, SSR, Bloom and published assets. The WebGL2 and WebGPU comparison uses the same Seed packages, source overrides and target-specific compilations of the same shader catalog. A third server can run the original WebGL2 distribution for calibration.

## Prepare the sources

From the candidate engine checkout, install its dependencies and build `pnpm b:module`. The checkout needs the Git objects for the Seed commit and the two engine revisions pinned in `merge-engine.py`. Python 3.9+, Node, pnpm, Git and the repo's Playwright Chromium build are required. Use an empty scratch directory outside the checkout. The following commands create an extracted project, merged engine sources and compiled shaders without checking out another branch.

```sh
work=$(mktemp -d)
bench=tests/benchmarks/seed-templates
node "$bench/fixture.mjs" prepare "$work/fixture"
python3 "$bench/merge-engine.py" "$work/engine"
python3 "$bench/prepare-shaders.py" "$work/fixture" "$PWD" "$work/engine" "$work/shaders"

node "$bench/fixture.mjs" serve "$work/fixture" --backend reference --port 15484 &
node "$bench/fixture.mjs" serve "$work/fixture" --backend webgl2 --merged "$work/engine" --shaders "$work/shaders" --port 15483 &
node "$bench/fixture.mjs" serve "$work/fixture" --backend webgpu --merged "$work/engine" --shaders "$work/shaders" --port 15482 &
```

The fixture uses the Seed revision's native overrides for features such as realtime IBL, staged building publication, horizon culling and reflection history. The integration patch reconciles those differences with the candidate's native command, buffer and texture interfaces. Built-in ShaderLab assets are recompiled for both targets. The Seed application's own precompiled shaders still load as compiled instruction streams. The application fetches its original CDN assets during boot.

## Measure

```sh
RESULTS="$work/results" WARMUP=90 FRAMES=180 node "$bench/run.mjs"
node "$bench/analyze.mjs" "$work/results" "$work/results" "$work/report"
```

Defaults select both templates, both backends, and the full scene followed by individual grass, vegetation, horizon, SSR and Bloom ablations. Set `TEMPLATES`, `BACKENDS`, `VARIANTS` or `MODES` to comma-separated lists to repeat a subset. Use `GL_URL=http://127.0.0.1:15484` for the original reference. Copy the two `*-camera.json` files to each new results directory when collecting repeats or reference runs. The first visit generates the five camera keyframes for each template from its authored spawn.

Each row starts a fresh world at seed 20261122 and 960 × 540 at DPR 1. The benchmark waits for publication, freezes navigation, advances simulation at 1/60 s and traverses the camera route once before measuring. CPU visits measure engine update time without GPU queries. GPU visits use native timers every tenth frame. Three inspected frames record draws, published population counts, terrain-horizon diagnostics and shader passes. PNG files contain the presentation canvas. Standard WebGL2 GPU measurements use a disjoint elapsed query. WebGPU brackets the recorded command buffers with two native timestamps within each engine queue submission. Uploads made via queue.writeBuffer before submission fall outside those markers. The two APIs have different measurement boundaries. For direct cross-backend GPU comparisons on a Mac, use the union of Metal active intervals over the same measured frames. Set `PASS_TIMINGS=1 MODES=gpu` in a separate output directory for per-pass diagnostics. This mode times WebGPU native passes and individual WebGL2 SSR and Bloom draws.

The vegetation switch controls both original population roots and includes grass. The horizon switch removes terrain-horizon rejection while retaining frustum culling and LOD. The Hi-Z trace inside SSR serves reflections. Shader passes, effect flags, camera poses and repeat captures should be checked alongside the timing rows. Seed publishes some fine detail under a frame budget and fresh visits can differ by a few draws.

The stationary camera routes exercise the terrain horizon with rocks behind a ridge. [Stationary viewpoints and geometry reference](horizon/README.md)
