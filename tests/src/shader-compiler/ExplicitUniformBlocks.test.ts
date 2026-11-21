import { ShaderLanguage } from "@galacean/engine-core";
import { ShaderMacroProcessor } from "@galacean/engine-core/src/shader/ShaderMacroProcessor";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { ShaderPrecompiler } from "@galacean/engine-shader-compiler/precompile";
import { describe, expect, it } from "vitest";

const declarations = `uniform Camera {
  vec3 eye;
  float exposure;
  float planes[2];
  vec3 points[2];
  mat3 normal;
  mat4 views[2];
};`;

function shader(block: string, vertex = "vec4(eye, 1.0)", fragment = "vec4(exposure)") {
  return `Shader "blocks" { SubShader "s" { Pass "p" {
    ${block}
    void vert() { gl_Position = ${vertex}; }
    void frag() { gl_FragColor = ${fragment}; }
    VertexShader = vert;
    FragmentShader = frag;
  } } }`;
}

describe("explicit uniform blocks", () => {
  it("keeps the complete std140 layout identical across live and offline compilation and both stages", () => {
    const source = shader(`#ifndef CAMERA_INCLUDED\n#define CAMERA_INCLUDED\n${declarations}\n#endif`);
    const compiler = new ShaderCompiler();
    const parsed = compiler._parseShaderSource(source).subShaders[0].passes[0];
    const live = compiler._parseShaderPass(
      parsed.contents,
      parsed.vertexEntry,
      parsed.fragmentEntry,
      ShaderLanguage.GLSLES300
    )!;
    const offline = JSON.parse(JSON.stringify(new ShaderPrecompiler().precompile(source))).subShaders[0].passes[0];
    expect(offline.uniformBlocks).toEqual(live.uniformBlocks);
    const [block] = live.uniformBlocks!;
    expect(block.name).toBe("Camera");
    expect(block.byteLength).toBe(256);
    expect(block.members.map((m) => [m.name, m.offset, m.arrayLength, m.arrayStride, m.matrixStride])).toEqual([
      ["eye", 0, 0, 0, 0],
      ["exposure", 12, 0, 0, 0],
      ["planes", 16, 2, 16, 0],
      ["points", 48, 2, 16, 0],
      ["normal", 80, 0, 0, 16],
      ["views", 128, 2, 64, 16]
    ]);
    for (const instructions of [offline.vertexShaderInstructions, offline.fragmentShaderInstructions]) {
      const glsl = ShaderMacroProcessor.evaluate(instructions, new Map());
      expect(glsl).toContain("layout(std140) uniform Camera {");
      expect(glsl).toContain("highp mat4 views[2];");
      expect(glsl).not.toMatch(/uniform\s+(?:highp\s+)?(?:float|vec3)\s+(?:eye|exposure)/);
    }
  });

  it("omits unreferenced blocks and keeps legacy passes free of reflection payload", () => {
    const precompiler = new ShaderPrecompiler();
    for (const block of ["", declarations]) {
      const pass = precompiler.precompile(shader(block, "vec4(0.)", "vec4(1.)")).subShaders[0].passes[0];
      expect(JSON.parse(JSON.stringify(pass))).not.toHaveProperty("uniformBlocks");
    }
  });

  it("preserves block offsets when a pass overrides one inherited member with a loose uniform", () => {
    const source = shader("float eye;", "vec4(eye + exposure)", "vec4(exposure)").replace(
      "SubShader",
      declarations + "\nSubShader"
    );
    const pass = new ShaderPrecompiler().precompile(source).subShaders[0].passes[0];
    expect(pass.uniformBlocks![0].members[1].offset).toBe(12);
    for (const instructions of [pass.vertexShaderInstructions!, pass.fragmentShaderInstructions!]) {
      const glsl = ShaderMacroProcessor.evaluate(instructions, new Map());
      expect(glsl).toContain("highp vec3 gs_Camera_eye;");
      expect(glsl).not.toContain("highp vec3 eye;");
    }
  });

  it("forwards a complete overriding block before an inherited helper that reads it", () => {
    const source = shader(declarations, "vec4(readEye(), exposure)", "vec4(exposure)").replace(
      "SubShader",
      "vec3 eye; vec3 readEye() { return eye; }\nSubShader"
    );
    const pass = new ShaderPrecompiler().precompile(source).subShaders[0].passes[0];
    const glsl = ShaderMacroProcessor.evaluate(pass.vertexShaderInstructions!, new Map());
    expect(glsl.match(/layout\(std140\) uniform Camera/g)).toHaveLength(1);
    expect(glsl.indexOf("layout(std140) uniform Camera")).toBeLessThan(glsl.indexOf("vec3 readEye"));
    expect(glsl).not.toContain("uniform vec3 eye");
  });

  it.each([
    ["uniform Camera { sampler2D bad; };", /Unsupported uniform block member type/],
    ["uniform Camera { vec3 bad[]; };", /positive literal/],
    ["uniform Camera { float bad = 2.; };", /unqualified type/],
    ["uniform Unknown { float bad; };", /named Scene or Camera/]
  ])("rejects invalid layout %s before driver compilation", (block, error) => {
    expect(() => new ShaderPrecompiler().precompile(shader(block, "vec4(0.)", "vec4(1.)"))).toThrow(error);
  });
});
