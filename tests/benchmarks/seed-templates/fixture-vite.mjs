import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath, pathToFileURL } from "node:url";
import { adaptSeedCapabilities } from "./fixture-capabilities.mjs";
import { exposeSeedBenchmarkContext } from "./demo.mjs";

const benchmark = path.dirname(fileURLToPath(import.meta.url));
const demo = "/world/demos/seed-world/";

function instrumentation(backend) {
  return {
    name: "seed-benchmark",
    enforce: "pre",
    resolveId(id) {
      if (id === "virtual:seed-benchmark-metrics") return path.join(benchmark, "metrics.mjs");
    },
    transform(source, id) {
      if (backend !== "reference" && id.endsWith("/runtime-inspection/runtime-pick-occlusion.ts")) {
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
      if (backend !== "reference" && id.endsWith("/building/runtime/ConstructionSceneLighting.ts")) {
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
      if (id.endsWith(demo + "main.ts")) {
        return 'import { installSeedMetrics } from "virtual:seed-benchmark-metrics"; installSeedMetrics();\n' + source;
      }
      if (!id.endsWith(demo + "SeedWorldDemo.ts")) return;
      let result = exposeSeedBenchmarkContext(source);
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

export async function createSeedServer({ root, engine, backend, merged, shaders, port }) {
  root = fs.realpathSync(root);
  if (!["reference", "webgl2", "webgpu"].includes(backend)) throw Error("Unknown Seed backend " + backend);
  if (backend !== "reference" && (!merged || !shaders))
    throw Error("Candidate backends require --merged and --shaders.");
  process.env.WORLD_DEMO = "seed-world";
  const world = path.join(root, "world");
  const { default: base } = await import(pathToFileURL(path.join(world, "vite.config.mjs")).href);
  const { createServer } = createRequire(path.join(world, "package.json"))("vite");
  const plugins = [instrumentation(backend)];
  const allow = [root, benchmark];
  if (backend !== "reference") {
    plugins.push(candidateSources({ root, engine, merged, shaders }));
    allow.push(fs.realpathSync(merged), fs.realpathSync(shaders), engine);
  }
  return createServer({
    ...base,
    configFile: false,
    cacheDir: path.join(root, "node_modules", ".vite-seed-" + backend + "-" + port),
    plugins: [...plugins, ...base.plugins],
    server: { ...base.server, open: false, hmr: false, host: "127.0.0.1", port, strictPort: true, fs: { allow } }
  });
}
