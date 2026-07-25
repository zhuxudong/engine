# Terrain demos

The terrain category contains two runtime entries:

- `Terrain · Realistic` validates replaceable height/control inputs, geometry-clipmap LOD, terrain material sampling, lighting, and the portable `SurfaceWorld`.
- `Terrain · Grasslands` reuses the same terrain and surface runtime with exported 3 km scene data, authored architecture, and a demo-only atmosphere layer.

## Boundaries

`SurfaceWorld` consumes versioned manifests, cell-indexed instance binaries, prototype LODs, density masks, and deterministic placement data. Runtime code only selects visible cells, LODs, and precompiled instances; it never calls `Math.random()` or regenerates authored layouts.

Grasslands architecture, HDR sky, fog, clouds, cloud shadows, exposure, and post-processing remain under `grasslands/`. They do not add fields to the portable surface contract.

## Commands

From the repository root:

```bash
pnpm --filter @galacean/world-gallery typecheck:terrain
pnpm --filter @galacean/world-gallery test:terrain:e2e
```

Set `TERRAIN_E2E_URL` to validate an existing gallery server. Set `TERRAIN_E2E_CAPTURE=1` to add fixed visual captures, including the 1280×720 DPR 2 Grasslands static/animated baseline.

## Runtime diagnostics

The realistic entry exposes terrain and surface controls through its inspector and `window.terrainDebug`, including:

- terrain output, clipmap LOD/wireframe, lighting, world background, sampling, and material controls;
- `getSurface`, `setSurface`, `inspectSurface`, and `setSurfaceDebugView`;
- deterministic camera poses and CPU height/control probes.

The Grasslands entry exposes authored-scene switches through `window.grasslandsDebug`:

- `getScene` and `setScene` for architecture, clouds, light, sky, fog, and post-processing;
- `inspectClouds` for cloud batching and animation time;
- `inspectSurface` and `setSurface` for the shared portable runtime.
