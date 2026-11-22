import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";
import { pathToFileURL } from "node:url";

export async function nativeTranslator(load, tools, scratch) {
  const provenance = JSON.parse(fs.readFileSync(new URL("./tool-provenance.json", import.meta.url)));
  for (const file of ["twgsl.cjs", "twgsl.wasm"]) {
    const bytes = fs.readFileSync(path.join(tools, file));
    assert.equal(
      createHash("sha256").update(bytes).digest("hex"),
      provenance[file].sha256,
      file + " checksum mismatch"
    );
  }
  const glslang = path.join(tools, process.platform === "win32" ? "glslang.exe" : "glslang");
  assert.match(execFileSync(glslang, ["--version"], { encoding: "utf8" }), /Glslang Version: [^\n]*\b16\.6\.0\b/);
  const twgsl = await createRequire(import.meta.url)(path.join(tools, "twgsl.cjs"))(path.join(tools, "twgsl.wasm"));
  const naga = await import(pathToFileURL(load.resolve("web-naga")));
  const proto = naga.GlslFrontend.prototype;
  // Keep the engine's uniform packing, binding assignment and reflection. Replace only the final stage
  // translation for the native building shaders, whose recovered GLSL uses features outside Naga's frontend.
  return function compileNative(compiler, pass) {
    const parse = proto.parse;
    proto.parse = function (source, stage) {
      const input = path.join(scratch, "shader.glsl"),
        binary = path.join(scratch, "shader.spv");
      fs.writeFileSync(input, source);
      execFileSync(glslang, [
        "-V",
        "-Os",
        "-S",
        stage === naga.ShaderStage.Vertex ? "vert" : "frag",
        input,
        "-o",
        binary
      ]);
      const data = fs.readFileSync(binary);
      const code = twgsl.convertSpirV2WGSL(new Uint32Array(data.buffer, data.byteOffset, data.length / 4));
      assert.ok(code.trim() && !code.trimStart().startsWith("error"), "Failed to translate SPIR-V to WGSL: " + code);
      return { to_wgsl: () => code, free() {} };
    };
    try {
      return compiler.compileDefaultVariant(pass);
    } finally {
      proto.parse = parse;
    }
  };
}
