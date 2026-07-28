import type { IShaderReflection, IShaderUniformReflection } from "@galacean/engine-design";
import { ShaderFactory, ShaderLanguage, ShaderPass } from "@galacean/engine-core";
import { ShaderMacroProcessor } from "@galacean/engine-core/src/shader/ShaderMacroProcessor";
import { shaderLibrary } from "@galacean/engine-shader";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { server } from "@vitest/browser/context";
import { describe, expect, it } from "vitest";

const { readFile } = server.commands;

for (const include of shaderLibrary) {
  ShaderFactory.includeMap[include.path] = include.source;
}

const basicShader = `
Shader "WGSL/Basic" {
  SubShader "Default" {
    Pass "Forward" {
      mat4 renderer_MVPMat;
      vec4 material_BaseColor;

      struct Attributes {
        vec3 POSITION;
      };

      struct Varyings {
        vec2 v_uv;
      };

      VertexShader = vert;
      FragmentShader = frag;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.v_uv = attributes.POSITION.xz;
        return output;
      }

      vec4 frag(Varyings varyings) {
        return vec4(varyings.v_uv, 0.0, 1.0) * material_BaseColor;
      }
    }
  }
}
`;

function generateWGSL(): { vertex: string; fragment: string } {
  return generateWGSLFromSource(basicShader);
}

function generateWGSLFromSource(
  source: string,
  macros: ReadonlyMap<string, string> = new Map()
): { vertex: string; fragment: string } {
  const compiler = new ShaderCompiler();
  compiler._setIncludeMap(ShaderFactory.includeMap);
  const shader = compiler._parseShaderSource(source);
  const pass = shader.subShaders[0].passes[0];
  const program = compiler._parseShaderPass(
    pass.contents,
    pass.vertexEntry,
    pass.fragmentEntry,
    ShaderLanguage.WGSL,
    "shaders://root/"
  );

  expect(program).toBeDefined();
  return {
    vertex: ShaderMacroProcessor.evaluate(program!.vertexShaderInstructions!, macros),
    fragment: ShaderMacroProcessor.evaluate(program!.fragmentShaderInstructions!, macros)
  };
}

function formatCompilationErrors(stage: string, info: GPUCompilationInfo, source: string): string[] {
  const lines = source.split("\n");
  return info.messages
    .filter((message) => message.type === "error")
    .map(
      (message) =>
        `${stage} ${message.lineNum}:${message.linePos} ${message.message}\n${lines
          .slice(Math.max(0, message.lineNum - 5), message.lineNum + 4)
          .join("\n")}`
    );
}

describe("ShaderCompiler WGSL codegen", () => {
  it("emits backend-neutral ShaderLab as WGSL with structured reflection", () => {
    const compiler = new ShaderCompiler();
    const shader = compiler._parseShaderSource(basicShader);
    const pass = shader.subShaders[0].passes[0];
    const program = compiler._parseShaderPass(
      pass.contents,
      pass.vertexEntry,
      pass.fragmentEntry,
      ShaderLanguage.WGSL,
      "shaders://root/"
    );

    expect(program?.reflection).toEqual({
      uniforms: [
        { name: "renderer_MVPMat", type: "mat4x4<f32>", arrayLength: undefined },
        { name: "material_BaseColor", type: "vec4<f32>", arrayLength: undefined }
      ],
      structs: [],
      resources: [],
      vertexInputs: [{ name: "POSITION", type: "vec3<f32>", location: 0 }],
      fragmentOutputs: [0]
    });

    const { vertex, fragment } = generateWGSL();
    expect(vertex).toContain("@vertex fn main");
    expect(fragment).toContain("@fragment fn main");
    expect(vertex).toContain("@group(0) @binding(0) var<uniform> gsUniforms");
    expect(vertex).not.toContain("#");
    expect(fragment).not.toContain("#");
  });

  it("passes native WebGPU shader-module validation when WebGPU is available", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const { vertex, fragment } = generateWGSL();

    const vertexInfo = await device.createShaderModule({ code: vertex }).getCompilationInfo();
    const fragmentInfo = await device.createShaderModule({ code: fragment }).getCompilationInfo();
    const errors = [...vertexInfo.messages, ...fragmentInfo.messages].filter((message) => message.type === "error");

    expect(errors.map((message) => message.message)).toEqual([]);
  });

  it("resolves macro aliases to renamed functions and preserves out parameters", () => {
    const source = `
Shader "WGSL/MacroAlias" {
  SubShader "Default" {
    Pass "Forward" {
      struct Attributes {
        vec3 POSITION;
      };

      struct Varyings {
        float copied;
      };

      void copyValue(float input, out float output) {
        output = input;
      }

      #define COPY_VALUE(input, output) copyValue(input, output)

      Varyings vert(Attributes attributes) {
        Varyings output;
        float copiedValue;
        COPY_VALUE(attributes.POSITION.x, copiedValue);
        gl_Position = vec4(attributes.POSITION, 1.0);
        output.copied = copiedValue;
        return output;
      }

      vec4 frag(Varyings varyings) {
        return vec4(varyings.copied);
      }

      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}
`;
    const { vertex } = generateWGSLFromSource(source);

    expect(vertex).not.toContain("COPY_VALUE");
    expect(vertex).toMatch(/\bgs_copyValue\w*\([^;]+,\s*&copiedValue\)/);
  });

  it("rewrites explicit depth samples to vertex-stage legal comparison samples", () => {
    const reflection: IShaderReflection = {
      uniforms: [],
      structs: [],
      resources: [
        {
          name: "scene_ShadowMap",
          textureBinding: 0,
          samplerBinding: 1,
          textureType: "texture_depth_2d",
          comparison: true
        }
      ],
      vertexInputs: [],
      fragmentOutputs: [0]
    };
    const source = "let attenuation = textureSampleLevel(scene_ShadowMap, scene_ShadowMap_sampler, shadowCoord, 0.0);";
    const shaderPassInternals = ShaderPass as unknown as {
      _rewriteWGSLComparisonSamples(source: string, reflection: IShaderReflection): string;
    };

    expect(shaderPassInternals._rewriteWGSLComparisonSamples(source, reflection)).toBe(
      "let attenuation = textureSampleCompareLevel(scene_ShadowMap, scene_ShadowMap_sampler, (shadowCoord).xy, (shadowCoord).z);"
    );
  });

  it("rewrites comparison samples for depth texture function parameters", () => {
    const reflection: IShaderReflection = {
      uniforms: [],
      structs: [],
      resources: [],
      vertexInputs: [],
      fragmentOutputs: [0]
    };
    const source = `
fn sampleShadow(
  shadowMap: texture_depth_2d,
  shadowMap_sampler: sampler_comparison,
  shadowCoord: vec3<f32>
) -> f32 {
  return textureSampleLevel(shadowMap, shadowMap_sampler, shadowCoord, 0.0);
}`;
    const shaderPassInternals = ShaderPass as unknown as {
      _rewriteWGSLComparisonSamples(source: string, reflection: IShaderReflection): string;
    };

    expect(shaderPassInternals._rewriteWGSLComparisonSamples(source, reflection)).toContain(
      "return textureSampleCompareLevel(shadowMap, shadowMap_sampler, (shadowCoord).xy, (shadowCoord).z);"
    );
  });

  it("compacts sparse active locations and keeps varyings paired between stages", () => {
    const vertex = `
struct GSVertexInput {
  @location(0) POSITION: vec3<f32>,
  @location(14) TEXCOORD_0: vec2<f32>,
}
struct GSVertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(12) v_uv: vec2<f32>,
}
`;
    const fragment = `
struct GSFragmentInput {
  @location(12) v_uv: vec2<f32>,
}
`;
    const shaderPassInternals = ShaderPass as unknown as {
      _compactWGSLLocations(
        vertexSource: string,
        fragmentSource: string
      ): { vertexSource: string; fragmentSource: string };
    };
    const compacted = shaderPassInternals._compactWGSLLocations(vertex, fragment);

    expect(compacted.vertexSource).toContain("@location(0) POSITION");
    expect(compacted.vertexSource).toContain("@location(1) TEXCOORD_0");
    expect(compacted.vertexSource).toContain("@location(0) v_uv");
    expect(compacted.fragmentSource).toContain("@location(0) v_uv");
  });

  it("injects instance indices regardless of generated wrapper indentation", () => {
    const source = `
struct GSVertexInput {
  @location(0) POSITION: vec3<f32>,
}
struct GSVertexOutput {
  @builtin(position) position: vec4<f32>,
}
@vertex fn main(input: GSVertexInput) -> GSVertexOutput {
_gsInstanceIndex = i32(input.instanceIndex);
gs_vertexEntry();
var output: GSVertexOutput;
return output;
}
`;
    const uniforms = new Map<string, IShaderUniformReflection>([
      ["renderer_ModelMat", { name: "renderer_ModelMat", type: "mat4x4<f32>" }]
    ]);
    const shaderFactoryInternals = ShaderFactory as unknown as {
      _rewriteWGSLInstanceUniforms(
        source: string,
        uniforms: ReadonlyMap<string, IShaderUniformReflection>,
        vertex: boolean,
        varyingLocation: number
      ): string;
    };
    const rewritten = shaderFactoryInternals._rewriteWGSLInstanceUniforms(source, uniforms, true, 1);

    expect(rewritten.match(/_gsInstanceIndex = i32\(input\.instanceIndex\);/g)).toHaveLength(1);
    expect(rewritten).toContain("output.gsInstanceIndex = input.instanceIndex;");
    expect(rewritten).toContain("@location(1) @interpolate(flat) gsInstanceIndex: u32");
  });

  it("lowers the camera depth texture to a native WGSL depth resource", () => {
    const reflection: IShaderReflection = {
      uniforms: [],
      structs: [],
      resources: [
        {
          name: "camera_DepthTexture",
          textureBinding: 1,
          samplerBinding: 2,
          textureType: "texture_2d<f32>",
          comparison: false
        }
      ],
      vertexInputs: [],
      fragmentOutputs: [0]
    };
    const lowered = ShaderFactory.lowerWGSLDepthTextures(
      `@group(0) @binding(1) var camera_DepthTexture: texture_2d<f32>;
@group(0) @binding(2) var camera_DepthTexture_sampler: sampler;
let depth = textureSample(camera_DepthTexture, camera_DepthTexture_sampler, screenUv).r;`,
      reflection
    );

    expect(lowered.source).toContain("var camera_DepthTexture: texture_depth_2d;");
    expect(lowered.source).toContain(
      "gs_sampleDepth_camera_DepthTexture(camera_DepthTexture, camera_DepthTexture_sampler, screenUv).r"
    );
    expect(lowered.reflection.resources[0].textureType).toBe("texture_depth_2d");
  });

  it("compiles the world terrain ShaderLab pass to native-valid WGSL", async () => {
    const source = await readFile("../world-gallery/demos/terrain/src/shaders/Terrain.shader");
    const compiler = new ShaderCompiler();
    compiler._setIncludeMap(ShaderFactory.includeMap);
    const shader = compiler._parseShaderSource(source);
    const pass = shader.subShaders[0].passes[0];
    const program = compiler._parseShaderPass(
      pass.contents,
      pass.vertexEntry,
      pass.fragmentEntry,
      ShaderLanguage.WGSL,
      "shaders://root/"
    );

    expect(program).toBeDefined();
    expect(program!.reflection?.resources.length).toBeGreaterThan(0);
    expect(program!.reflection?.fragmentOutputs).toEqual([0]);

    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const macros = new Map([
      ["GRAPHICS_API_WEBGPU", ""],
      ["GRAPHICS_API_WEBGL2", ""],
      ["SCENE_SHADOW_CASCADED_COUNT", "1"],
      ["SCENE_DIRECT_LIGHT_COUNT", "1"],
      ["SCENE_POINT_LIGHT_COUNT", "1"],
      ["SCENE_SPOT_LIGHT_COUNT", "1"],
      ["TERRAIN_DIRECT_LIGHTING", ""],
      ["TERRAIN_INDIRECT_LIGHTING", ""]
    ]);
    const vertex = ShaderMacroProcessor.evaluate(program!.vertexShaderInstructions!, macros);
    const fragment = ShaderMacroProcessor.evaluate(program!.fragmentShaderInstructions!, macros);
    const vertexInfo = await device.createShaderModule({ code: vertex }).getCompilationInfo();
    const fragmentInfo = await device.createShaderModule({ code: fragment }).getCompilationInfo();
    const errors = [
      ...formatCompilationErrors("vertex", vertexInfo, vertex),
      ...formatCompilationErrors("fragment", fragmentInfo, fragment)
    ];

    expect(errors).toEqual([]);
  });

  it("compiles Grasslands surface and cloud variants to native-valid WGSL", async () => {
    const [surfaceSource, cloudSource, cloudShadowInclude, worldNoiseInclude] = await Promise.all([
      readFile("../world-gallery/demos/terrain/src/shaders/Surface.shader"),
      readFile("../world-gallery/demos/terrain/grasslands/src/shaders/GrasslandsCloud.shader"),
      readFile("../world-gallery/demos/terrain/src/shaders/Terrain/GrasslandsCloudShadow.glsl"),
      readFile("../world-gallery/demos/terrain/src/shaders/Terrain/TerrainWorldNoise.glsl")
    ]);
    ShaderFactory.includeMap["Terrain/GrasslandsCloudShadow.glsl"] = cloudShadowInclude;
    ShaderFactory.includeMap["Terrain/TerrainWorldNoise.glsl"] = worldNoiseInclude;
    const sharedMacros = new Map([
      ["GRAPHICS_API_WEBGPU", ""],
      ["GRAPHICS_API_WEBGL2", ""],
      ["HAS_TEX_LOD", ""],
      ["HAS_DERIVATIVES", ""],
      ["SCENE_FOG_MODE", "2"],
      ["SCENE_SHADOW_CASCADED_COUNT", "4"],
      ["SCENE_DIRECT_LIGHT_COUNT", "1"],
      ["SCENE_POINT_LIGHT_COUNT", "0"],
      ["SCENE_SPOT_LIGHT_COUNT", "0"]
    ]);
    const variants = [
      {
        name: "surface",
        source: surfaceSource,
        macros: new Map([
          ...sharedMacros,
          ["RENDERER_SURFACE_INSTANCED", ""],
          ["RENDERER_HAS_TANGENT", ""],
          ["MATERIAL_HAS_BASETEXTURE", ""],
          ["MATERIAL_HAS_NORMALTEXTURE", ""],
          ["MATERIAL_HAS_METALROUGHNESSTEXTURE", ""],
          ["MATERIAL_HAS_OCCLUSIONTEXTURE", ""]
        ])
      },
      {
        name: "cloud",
        source: cloudSource,
        macros: sharedMacros
      }
    ];

    if (!navigator.gpu) {
      return;
    }
    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const errors: string[] = [];
    for (const variant of variants) {
      const generated = generateWGSLFromSource(variant.source, variant.macros);
      const [vertexInfo, fragmentInfo] = await Promise.all([
        device.createShaderModule({ label: `${variant.name} vertex`, code: generated.vertex }).getCompilationInfo(),
        device.createShaderModule({ label: `${variant.name} fragment`, code: generated.fragment }).getCompilationInfo()
      ]);
      errors.push(
        ...formatCompilationErrors(`${variant.name} vertex`, vertexInfo, generated.vertex),
        ...formatCompilationErrors(`${variant.name} fragment`, fragmentInfo, generated.fragment)
      );
    }

    expect(errors).toEqual([]);
  });
});
