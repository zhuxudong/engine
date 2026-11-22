# Native Metal timing for Seed templates

Use a Mac with Xcode Instruments, Python 3.10 or newer and the repository’s Playwright Chromium. Start the two fixture servers and collect their camera paths with the [desktop benchmark](../README.md). Keep other GPU workloads idle during capture. The default ports are 15483 for WebGL2 and 15482 for WebGPU.

From the repository root, set the input directory to the existing camera files and choose a fresh output directory.

```sh
metal=tests/benchmarks/seed-templates/metal
export CAMERA_DIR="$work/results"
export RESULTS="$work/metal"
node "$metal/capture.cjs" --plan
node "$metal/capture.cjs" --record
python3 "$metal/analyze.py" "$RESULTS" --compress-exports
```

The default workload visits Sakura Pearl and Titan Wasteland twice. Each comparison runs both backends in the same Chromium GPU process and the second pair reverses the order. Each page warms up for 90 frames and records 120 frames at 960 × 540, DPR 1. The other page stays paused and frozen. Xcode attaches directly to the GPU process and the capture checks its PID before and after each workload.

The recorder starts Xcode using the Mac’s native CPU architecture and host-device default. It verifies that the PID supplied by Chromium belongs to a local GPU process. Analysis checks the recorded macOS hardware UUID and process ID against the capture manifest and requires native GPU activity during each workload.

For module attribution, use a new output directory and include a contemporaneous full-scene visit. The stationary horizon route uses the [checked-in camera files](../horizon/README.md).

```sh
RESULTS="$work/metal-effects" REPS=1 VARIANTS=full,no-landmark-tree,no-ssr,no-vegetation,no-grass,no-bloom node "$metal/capture.cjs" --record
python3 "$metal/analyze.py" "$work/metal-effects" --compress-exports

RESULTS="$work/metal-horizon" CAMERA_DIR=tests/benchmarks/seed-templates/horizon REPS=1 VARIANTS=full,no-occlusion node "$metal/capture.cjs" --record
python3 "$metal/analyze.py" "$work/metal-horizon" --compress-exports
```

`TEMPLATES`, `REPS`, `VARIANTS`, `FRAMES`, `WARMUP`, `WIDTH`, `HEIGHT`, `SEED`, `GL_URL`, `GPU_URL` and `DEVELOPER_DIR` can be overridden. A manifest records the device, browser, checkout revision, camera and metrics hashes, and the exact group order. An interrupted run can use `RESUME=1` with the same configuration. Incomplete group files are moved aside and each missing pair is recorded again.

To retry a specific pair, set `CAPTURE_GROUPS` to one or more comma-separated group IDs from `--plan`. The manifest retains the full workload order so later runs can fill in the other groups. The collector gives its own Xcode recorder 150 seconds to save after the workload stops, then reaps it and reports a failure if it hangs. The completed groups and interrupted trace files remain available.

Each group retains the native `.trace`, the two workload JSON files, validation results and wall-clock frame boundaries. The analyzer exports native GPU activity and thermal data. Its `native-busy.json` reports the union of Active Metal intervals attributed to the browser GPU process within each animation frame. Overlapping hardware channels count once. The interior summary excludes the inspection frames, their successors and the edge frames. Thermal state, per-channel activity, per-frame nanoseconds and the actual camera poses are included for verification.
