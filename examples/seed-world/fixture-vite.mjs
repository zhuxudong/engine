import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { pathToFileURL } from "node:url";
import { adaptSeedCapabilities } from "./fixture-capabilities.mjs";

const demo = "/world/demos/seed-world/";

function installFpsHud(engine, lifetime) {
  const hud = document.createElement("span");
  hud.dataset.seedFps = "";
  hud.style.cssText =
    "position:fixed;top:calc(env(safe-area-inset-top,0px) + 8px);left:calc(env(safe-area-inset-left,0px) + 8px);" +
    "z-index:100001;pointer-events:none;background:#111d;color:white;padding:4px 8px;border-radius:4px;" +
    "font:600 14px/1.3 ui-monospace,monospace;font-variant-numeric:tabular-nums";
  document.body.append(hud);
  let since, frames;
  function reset() {
    since = performance.now();
    frames = engine.time.frameCount;
    hud.textContent = "FPS …";
  }
  reset();
  const timer = setInterval(() => {
    if (document.hidden) return;
    const now = performance.now();
    const current = engine.time.frameCount;
    hud.textContent = "FPS " + (((current - frames) * 1000) / (now - since)).toFixed(1);
    since = now;
    frames = current;
  }, 500);
  document.addEventListener("visibilitychange", reset, { signal: lifetime });
  lifetime.addEventListener(
    "abort",
    () => {
      clearInterval(timer);
      hud.remove();
    },
    { once: true }
  );
}

function adaptSeedDemo(backend) {
  return {
    name: "seed-engine-adapter",
    enforce: "pre",
    transform(source, id) {
      if (id.endsWith("/runtime-inspection/runtime-pick-occlusion.ts")) {
        // The depth-only pick pass retains both source stages. Their compiler metadata follows the pair.
        return source.replace(
          "src._fragmentShaderInstructions,\n    ShaderLanguage.GLSLES300",
          `src._fragmentShaderInstructions,
    ShaderLanguage.GLSLES300,
    undefined,
    src._vertexOutputNames,
    src._uniformBlocks,
    src._uniformPlan,
    src._wgsl`
        );
      }
      if (id.endsWith("/building/runtime/ConstructionSceneLighting.ts")) {
        // The candidate emits its fragment entry wrapper in adjacent literal VM instructions.
        // Join only that known wrapper, leaving all macro jumps and other instructions in place.
        return source.replace(
          "const result = instructions.map((instruction) => {",
          `const literal = (index) =>
          instructions[index]?.[0] === 0 ? instructions[index][1].trim() : "";
          const split = instructions.findIndex((instruction, index) =>
            literal(index) === "void main() {" && literal(index + 1) === "BridgeFragment(); }");
          const result = instructions.map((instruction, index) => {
            if (split >= 0 && index === split) { entries++; return [0, ""]; }
            if (split >= 0 && index === split + 1) return [0, ""];`
        );
      }
      if (backend === "webgpu") {
        const adapted = adaptSeedCapabilities(source, id);
        if (adapted !== undefined) return adapted;
      }
      if (!id.endsWith(demo + "SeedWorldDemo.ts")) return;
      const start = "engine!.run();";
      if (!source.includes(start)) throw Error("Cannot locate the Seed World frame loop.");
      let result = source.replace(
        start,
        () =>
          start +
          '\nif (pageUrl.searchParams.get("fps") !== "0") (' +
          installFpsHud.toString() +
          ")(engine, editorLifetime.signal);"
      );
      if (backend === "webgpu") {
        const marker = "WebGLEngine.create({";
        if (result.split(marker).length !== 2) throw Error("Cannot locate the Seed World engine creation site.");
        result =
          'import { WebGPUEngine as SeedWebGPUEngine } from "@galacean/engine-webgpu";\n' +
          result.replace(marker, "SeedWebGPUEngine.create({").replace("shaderCompiler: new ShaderCompiler()", "");
      }
      return result;
    }
  };
}

function candidateSources({ root, engine, merged, shaders }) {
  const packages = path.join(fs.realpathSync(merged), "packages") + path.sep;
  const shaderModules = fs.realpathSync(shaders);
  const paths = new Map();
  for (const dir of fs.readdirSync(packages)) {
    const manifest = JSON.parse(fs.readFileSync(path.join(packages, dir, "package.json"), "utf8"));
    paths.set(manifest.name, path.join(packages, dir, "src/index.ts"));
  }
  paths.set("@galacean/engine-shader", path.join(shaderModules, "shaders-webgl.mjs"));
  paths.set("@galacean/engine-shader/webgpu", path.join(shaderModules, "shaders-webgpu.mjs"));
  paths.set("@galacean/engine-shader/sources", path.join(shaderModules, "shader-sources.mjs"));
  paths.set("@galacean/engine-shader-compiler/webgpu", path.join(packages, "shader-compiler/src/webgpu.ts"));
  paths.set("@galacean/engine-shader-parser/internal", path.join(packages, "shader-parser/src/runtime.ts"));
  const naga = createRequire(path.join(engine, "packages/shader-compiler/package.json")).resolve("web-naga");
  paths.set("web-naga", naga);
  const { transformSync } = createRequire(path.join(root, "packages/modify/package.json"))("@swc/core");
  const version = JSON.parse(fs.readFileSync(path.join(engine, "package.json"), "utf8")).version;
  return {
    name: "seed-candidate-native-modules",
    enforce: "pre",
    config() {
      return { optimizeDeps: { exclude: [...paths.keys()] } };
    },
    resolveId(id, importer) {
      if (paths.has(id)) return paths.get(id);
      if (importer?.startsWith(packages) && !id.startsWith(".") && !id.startsWith("/") && !id.startsWith("\0")) {
        const pkg = importer.slice(packages.length).split("/")[0];
        return this.resolve(id, path.join(root, "packages", pkg, "src/index.ts"), { skipSelf: true });
      }
    },
    transform(source, id) {
      if (!id.startsWith(packages) || !id.endsWith(".ts")) return;
      // The reference toolkit subclasses engine constructors with ES5 .apply().
      return transformSync(source.replace(/`__buildVersion`/g, JSON.stringify(version)), {
        filename: id,
        sourceMaps: true,
        jsc: {
          parser: { syntax: "typescript", decorators: true },
          target: "es5",
          loose: true,
          externalHelpers: true,
          transform: { legacyDecorator: true, useDefineForClassFields: false }
        },
        module: { type: "es6" }
      });
    }
  };
}

export async function buildSeed({ root, engine, merged, shaders, backend, outDir, warmup = false }) {
  root = fs.realpathSync(root);
  process.env.WORLD_DEMO = "seed-world";
  const world = path.join(root, "world");
  // Each production build owns the Seed plugins that collect and publish its assets.
  const config = pathToFileURL(path.join(world, "vite.config.mjs"));
  config.searchParams.set("backend", backend);
  const { default: base } = await import(config.href);
  const { build } = createRequire(path.join(world, "package.json"))("vite");
  const warmupPlugins = [];
  if (warmup) {
    const { default: recordedVariants } = await import("./warmup/residual/plugin.mjs");
    const { default: loadingWarmup } = await import("./warmup/loading/plugin.mjs");
    warmupPlugins.push(recordedVariants, loadingWarmup);
  }
  const plugins = () => [
    ...warmupPlugins.map((plugin) => plugin()),
    adaptSeedDemo(backend),
    candidateSources({ root, engine, merged, shaders })
  ];
  await build({
    ...base,
    configFile: false,
    plugins: [...plugins(), ...base.plugins],
    worker: { ...base.worker, plugins: [...plugins(), ...base.worker.plugins] },
    build: { ...base.build, outDir, sourcemap: false, reportCompressedSize: false }
  });
}

export async function previewSeed(root, outDir, port) {
  const { preview } = createRequire(path.join(root, "world/package.json"))("vite");
  return preview({
    root,
    configFile: false,
    build: { outDir },
    preview: { host: "127.0.0.1", port, strictPort: true }
  });
}
