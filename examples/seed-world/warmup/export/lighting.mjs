import fs from "node:fs";
import path from "node:path";
export function loadSceneLighting(load, fixture, root) {
  const { ShaderPrecompiler } = load("../dist/precompile.main.js");
  const comp = new ShaderPrecompiler();
  const includes = {};
  function read(dir) {
    for (const f of fs.readdirSync(dir, { withFileTypes: true })) {
      const file = path.join(dir, f.name);
      if (f.isDirectory()) read(file);
      else if (file.endsWith(".glsl"))
        includes["ShaderLibrary/" + path.relative(root, file).split(path.sep).join("/")] = fs.readFileSync(
          file,
          "utf8"
        );
    }
  }
  read(root);
  const source = fs.readFileSync(
    path.join(fixture, "packages/building/src/building/runtime/ConstructionSceneLighting.ts"),
    "utf8"
  );
  includes["Masonry/SceneLighting.glsl"] = fs.readFileSync(
    path.join(fixture, "packages/building/src/building/runtime/ConstructionSceneLighting.glsl"),
    "utf8"
  );
  comp.setIncludeMap(includes);
  const bridge = comp.precompile(source.match(/constructionLightingBridgeSource = `([\s\S]*?)`;/)[1], 0);
  const pass = bridge.subShaders[0].passes[0];
  // Recover helper GLSL from the same bridge as the page; use the same default macro set as compileDefaultVariant.
  const core = load("@galacean/engine-core");
  let f = core.ShaderMacroProcessor.evaluate(
    pass.fragmentShaderInstructions,
    new Map(core.ShaderMacroProcessor._defaultWebGPUMacros)
  );
  f = f
    .replace(/uniform (?:vec3|float) masonryBridge\w+;\s*/g, "")
    .replace(/(?:layout\s*\([^)]*\)\s*)?\bout\s+(?:(?:lowp|mediump|highp)\s+)?vec4\s+\w+\s*;\s*/g, "")
    .replace(/void\s+BridgeFragment\s*\(\s*\)\s*\{[^{}]*\}/g, "")
    .replace(/void main\(\)\s*\{[^{}]*\}/g, "");
  if (!/masonryResidentSceneLight\s*\(/.test(f) || /void\s+main\s*\(/.test(f))
    throw Error("Missing lighting link or duplicate entry");
  return { source: f, uniformBlocks: pass.uniformBlocks, uniformPlan: pass.uniformPlan };
}
