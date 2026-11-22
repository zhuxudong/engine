# Stationary terrain-horizon diagnostic

These two camera positions face terrain ridges in the published Seed worlds at seed 20261122. Each position is 1.8 metres above the template’s canonical terrain surface. The two equal keyframes hold the camera still while Seed builds its horizon and confirms visibility over consecutive frames. The standard spawn route remains available for measuring traversal.

Start the fixture servers following the [Seed benchmark instructions](../README.md). From the repository root, run the two ablations in a separate output directory.

```sh
bench=tests/benchmarks/seed-templates
out=$(mktemp -d)
cp "$bench"/horizon/*-camera.json "$out"/
RESULTS="$out" VARIANTS=full,no-occlusion WARMUP=90 FRAMES=180 node "$bench/run.mjs"
node "$bench/analyze.mjs" "$out" "$out" "$out/report"
```

Set `TEMPLATES=titan-wasteland` for the shorter single-template test. To repeat the comparison, create a second output directory and copy the same camera files into it before running. Pass this directory to the analyzer as both `--repeat-reference=DIR` and `--repeat-candidate=DIR`.

## Geometry reference

The following counts were obtained offline using the original planner at `92ea60eaee49b2f1188b373c178c34ca511c9f87`. The calculation generated each template’s canonical 1024 × 1024 height field, selected its seeded rock variants, transformed the original glTF POSITION bounds with `rockVariantFit`, and grouped the resulting bounds in the 64 m cells owned by `RockLodView`. It ran the production `SeedWorldTerrainOcclusionCuller` and `SeedWorldExactInstanceCellRuntime` for 64 frames with 50° vertical FOV and a 16:9 viewport. Both viewpoints first rejected a rock cell on frame 2.

| Template | Camera XYZ in metres | Pitch / yaw | Rock instances in world | In frustum | Horizon-rejected cells | Horizon-rejected instances | Remaining candidates |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| Sakura Pearl | 352, 3.203, 832 | 2°, −30° | 352 | 300 | 75 | 291 | 9 |
| Titan Wasteland | 496, 13.955, 736 | 2°, 60° | 691 | 223 | 33 | 92 | 131 |

For each browser visit, use the `rockCells` object in the three inspected frames. In a settled full scene, `terrainOccludedInstanceCount` shows how many instances the horizon removed from cells in the frustum. With `no-occlusion`, that value should reach zero and `candidateInstanceCount` should rise. The disabled run can report zero instances *tested* because it bypasses the terrain query altogether. Frustum, LOD, and subsequent draw preparation still apply. The separate population and exact-prefab counters cover their respective owners.

The report pairs the two captures within each backend and records draw counts and native timings. Inspect the images and live counts alongside timings to verify what each browser actually displayed and submitted.
