# Regenerate Seed's default WGSL programs

The preview uses the checked-in WGSL catalog. To reproduce that catalog, first prepare the preview as described in the [Seed instructions](../../README.md). Use Node.js 22.18 or newer for the optional exporter, which imports the pinned Seed building shader adapter from TypeScript.

The export needs three files in one tools directory. Install the release `glslang` executable for your platform from [Khronos glslang 16.6.0](https://github.com/KhronosGroup/glslang/releases/tag/16.6.0). Download the [TWGSL JavaScript wrapper](https://raw.githubusercontent.com/BabylonJS/Babylon.js/47f84cf6dc635e97bfef29408be1cea41279334a/packages/tools/babylonServer/public/twgsl/twgsl.js) as `twgsl.cjs` and the [matching WebAssembly module](https://raw.githubusercontent.com/BabylonJS/Babylon.js/47f84cf6dc635e97bfef29408be1cea41279334a/packages/tools/babylonServer/public/twgsl/twgsl.wasm) as `twgsl.wasm`. The exporter checks both TWGSL hashes and the glslang version. The SHA-256 of the macOS universal glslang executable used for the reference export is recorded in [tool-provenance.json](tool-provenance.json).

From the repository root, set `SEED_WGSL_TOOLS` to your tools directory and run

```sh
export_dir=$(mktemp -d)
node examples/seed-world/warmup/export/convert.mjs ../engine-webgpu-preview "$SEED_WGSL_TOOLS" "$export_dir"
```

The command reads the original 26 instruction streams directly from the Seed commit recorded in the prepared preview. It uses the engine's shader compiler, the prepared shader include tree, and Seed's own building material and lighting adapters. Each output in `$export_dir/published` has its original relative path and program instructions plus WGSL for every concrete pass.

To produce the catalog and compare it with the checked-in data, use the original fixture from the prepared preview.

```sh
python3 examples/seed-world/warmup/assets/catalog.py ../engine-webgpu-preview/fixture "$export_dir/published" "$export_dir/catalog"
diff -r examples/seed-world/warmup/assets/modules "$export_dir/catalog/modules"
cmp examples/seed-world/warmup/assets/catalog.json "$export_dir/catalog/catalog.json"
```
