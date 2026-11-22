import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import fs from "node:fs";
import { createRequire } from "node:module";
import os from "node:os";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { adaptSeedCapabilities } from "../../fixture-capabilities.mjs";
import { loadSceneLighting } from "./lighting.mjs";
import { vertexES3, fragmentES3, textureES3, nativeBuilding } from "./native-shaders.mjs";
import { nativeTranslator } from "./translate-native.mjs";

const [previewDir, toolDir, outputDir, engineDir] = process.argv.slice(2);
if (!outputDir) throw Error("Usage: node convert.mjs PREPARED_PREVIEW TOOLS EMPTY_OUTPUT [ENGINE_CHECKOUT]");
const preview = path.resolve(previewDir),
  output = path.resolve(outputDir),
  tools = path.resolve(toolDir);
const engine = path.resolve(engineDir ?? fileURLToPath(new URL("../../../../", import.meta.url)));
const { seed, build } = JSON.parse(fs.readFileSync(path.join(preview, "seed-preview.json")));
assert.equal(seed, "679453a52c8aa874b81124b9990320f9580369a8", "This export targets the pinned Seed revision.");
fs.mkdirSync(output, { recursive: true });
assert.equal(fs.readdirSync(output).length, 0, "Use an empty output directory.");
const load = createRequire(path.join(engine, "packages/shader-compiler/bundler/cli.js"));
const { createWebGPUShaderCompiler, compileWebGPUShaderPass } = load("../dist/webgpu.main.js");
const compiler = await createWebGPUShaderCompiler(fs.readFileSync(load.resolve("web-naga/web_naga_bg.wasm")));
const fixture = path.join(preview, "fixture");
const lighting = loadSceneLighting(load, fixture, path.join(preview, build, "shaders/shader-src/ShaderLibrary"));
const { engineShaderSource } = await import(
  pathToFileURL(path.join(fixture, "packages/building/src/building/runtime/EngineShaderSource.ts"))
);
// Use the actual preview adapter's coordinate conventions for the emitted defaults. The stored
// instruction streams must continue to match the original inputs for runtime specialization.
const marker = "const subShaderList = data.subShaders.map";
const adapt = adaptSeedCapabilities(marker, "/core/src/shader/Shader.ts");
const orient = new Function("data", adapt.replace(marker, "return data;"));

function prepareNativePass(pass) {
  const native = { ...pass };
  if (pass.fragmentShaderInstructions.some(([op, text]) => op === 0 && text.includes("masonryResidentSceneLight"))) {
    native.uniformBlocks = lighting.uniformBlocks;
  }
  for (const [key, isVertex] of [
    ["vertexShaderInstructions", true],
    ["fragmentShaderInstructions", false]
  ]) {
    const instructions = pass[key];
    assert.equal(instructions.length, 1, "Expected a single recovered building source per stage");
    assert.equal(instructions[0][0], 0);
    native[key] = [[0, nativeBuilding(instructions[0][1], isVertex, engineShaderSource, lighting.source)]];
  }
  return native;
}

function standardizeLiterals(result, shader, pass) {
  for (const stage of ["vertex", "fragment"]) {
    // Naga rounds f32::MAX up to an unrepresentable decimal literal.
    result[stage] = result[stage].replaceAll("340282350000000000000000000000000000000f", "0x1.fffffep+127f");
    if (result[stage].includes("0x1.fffffep+128f")) {
      // The recovered plaster shader clips vertices using a specific NaN. Delay the bitcast to
      // runtime because WGSL disallows the resulting non-finite constant.
      assert.equal(shader.name.split("/")[1], "plaster");
      assert.match(pass.vertexShaderInstructions[0][1], /uintBitsToFloat\s*\(\s*0x7fbfffffu\b/);
      result[stage] =
        result[stage].replaceAll("0x1.fffffep+128f", "seedBitsToFloat(0x7fbfffffu)") +
        "\nfn seedBitsToFloat(bits: u32) -> f32 { return bitcast<f32>(bits); }\n";
    }
    assert.ok(
      result[stage].includes("@" + stage) && result[stage].includes("fn " + result[stage + "EntryPoint"] + "("),
      "Missing " + stage + " entry point"
    );
  }
  assert.ok(Array.isArray(result.reflection.vertexInputs));
}

const es2Backend = {
  compileWebGPUVariant(vertex, fragment, options) {
    return compiler.compileWebGPUVariant(textureES3(vertexES3(vertex)), textureES3(fragmentES3(fragment)), options);
  }
};
function convert(bytes, compileNative) {
  const shader = JSON.parse(bytes),
    oriented = orient(shader);
  for (const [subIndex, sub] of shader.subShaders.entries()) {
    for (const [passIndex, pass] of sub.passes.entries()) {
      if (pass.isUsePass) continue;
      const source = oriented.subShaders[subIndex].passes[passIndex];
      try {
        if (shader.name.startsWith("BuildingUnit/")) {
          pass.wgsl = compileNative(compiler, prepareNativePass(source));
        } else if (shader.platformTarget === 0) {
          pass.wgsl = compileWebGPUShaderPass(es2Backend, source);
        } else {
          pass.wgsl = compiler.compileDefaultVariant(source);
        }
        standardizeLiterals(pass.wgsl, shader, source);
      } catch (error) {
        throw Error("Cannot convert " + shader.name + " pass " + pass.name, { cause: error });
      }
    }
  }
  const result = Buffer.from(JSON.stringify(shader));
  for (const sub of shader.subShaders) for (const pass of sub.passes) delete pass.wgsl;
  assert.deepEqual(shader, JSON.parse(bytes));
  return result;
}

const git = (args) => execFileSync("git", ["-C", engine, ...args], { maxBuffer: 16 * 1024 * 1024 });
const paths = git([
  "ls-tree",
  "-r",
  "--name-only",
  "-z",
  seed,
  "--",
  "packages/terrain/src/data/seed-world/public/Shader",
  "packages/building/src/building/assets/native/Shaders",
  "packages/water/src/water/native/assets/Water/Shaders"
])
  .toString()
  .split("\0")
  .filter((name) => name.endsWith(".shaderc"))
  .sort();
assert.equal(paths.length, 26, "Unexpected Seed shader inventory");
const cache = new Map();
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "seed-wgsl-"));
try {
  const compileNative = await nativeTranslator(load, tools, scratch);
  for (const relative of paths) {
    const bytes = git(["show", seed + ":" + relative]);
    const key = createHash("sha256").update(bytes).digest("hex");
    if (!cache.has(key)) cache.set(key, convert(bytes, compileNative));
    const dest = path.join(output, "published", relative);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, cache.get(key));
  }
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
console.log(
  "Exported " + paths.length + " files (" + cache.size + " distinct inputs) to " + path.join(output, "published")
);
