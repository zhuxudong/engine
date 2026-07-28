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

const computeShader = `
Shader "WGSL/ComputeCopy" {
  SubShader "Default" {
    Pass "Copy" {
      readonly buffer uvec4 inputValues[];
      buffer uvec4 outputValues[];

      void copyValues() {
        uint index = gl_GlobalInvocationID.x;
        outputValues[index] = inputValues[index];
      }

      ComputeShader = copyValues;
    }
  }
}
`;

const atomicComputeShader = `
Shader "WGSL/ComputeAtomicAppend" {
  SubShader "Default" {
    Pass "Append" {
      buffer uint counters[];
      buffer uint outputValues[];

      void appendValues() {
        uint index = gl_GlobalInvocationID.x;
        uint outputIndex = atomicAdd(counters[0u], 1u);
        outputValues[outputIndex] = index;
      }

      ComputeShader = appendValues;
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

function generateWGSLCompute(
  source: string = computeShader,
  macros: ReadonlyMap<string, string> = new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "64"]])
): { compute: string; reflection: IShaderReflection } {
  const compiler = new ShaderCompiler();
  const shader = compiler._parseShaderSource(source);
  const pass = shader.subShaders[0].passes[0];
  const program = compiler._parseShaderPass(
    pass.contents,
    pass.vertexEntry,
    pass.fragmentEntry,
    ShaderLanguage.WGSL,
    "shaders://root/",
    pass.computeEntry,
    pass.computeWorkgroupSize
  );

  expect(program?.computeShaderInstructions).toBeDefined();
  expect(program?.reflection).toBeDefined();
  return {
    compute: ShaderMacroProcessor.evaluate(program!.computeShaderInstructions!, new Map(macros)),
    reflection: program!.reflection!
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
  it("emits storage bindings and a compute wrapper from ShaderLab", () => {
    const compiler = new ShaderCompiler();
    const shader = compiler._parseShaderSource(computeShader);
    const pass = shader.subShaders[0].passes[0];

    expect(pass.computeEntry).toBe("copyValues");
    expect(pass.computeWorkgroupSize).toBeUndefined();

    const { compute, reflection } = generateWGSLCompute();
    expect(compute).toContain("@compute @workgroup_size(64, 1, 1)");
    expect(compute).toContain("@builtin(global_invocation_id)");
    expect(compute).toContain("var<storage, read> inputValues: array<vec4<u32>>");
    expect(compute).toContain("var<storage, read_write> outputValues: array<vec4<u32>>");
    expect(compute).not.toContain("#");
    expect(reflection.storageBuffers).toEqual([
      {
        name: "inputValues",
        binding: 0,
        access: "read",
        elementType: "vec4<u32>",
        arrayLength: undefined,
        conditions: undefined
      },
      {
        name: "outputValues",
        binding: 1,
        access: "read_write",
        elementType: "vec4<u32>",
        arrayLength: undefined,
        conditions: undefined
      }
    ]);
  });

  it("passes native WebGPU compute shader-module validation when WebGPU is available", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const { compute } = generateWGSLCompute();
    const info = await device.createShaderModule({ code: compute }).getCompilationInfo();
    const errors = info.messages.filter((message) => message.type === "error");

    expect(formatCompilationErrors("compute", info, compute)).toEqual([]);
    expect(errors.map((message) => message.message)).toEqual([]);
  });

  it("lowers ShaderLab storage atomicAdd to valid WGSL", async () => {
    const { compute, reflection } = generateWGSLCompute(atomicComputeShader);

    expect(compute).toContain("var<storage, read_write> counters: array<atomic<u32>>");
    expect(compute).toContain("atomicAdd(&counters[0u], 1u)");
    expect(reflection.storageBuffers?.[0]).toMatchObject({
      name: "counters",
      access: "read_write",
      elementType: "u32"
    });

    if (!navigator.gpu) {
      return;
    }
    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const info = await device.createShaderModule({ code: compute }).getCompilationInfo();

    expect(formatCompilationErrors("compute", info, compute)).toEqual([]);
  });

  it("executes the generated compute artifact and copies storage-buffer data", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const { compute } = generateWGSLCompute();
    const pipeline = device.createComputePipeline({
      layout: "auto",
      compute: { module: device.createShaderModule({ code: compute }), entryPoint: "main" }
    });
    const values = Uint32Array.from({ length: 64 * 4 }, (_, index) => index * 3 + 7);
    const input = device.createBuffer({
      size: values.byteLength,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST
    });
    const output = device.createBuffer({
      size: values.byteLength,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
    });
    const readback = device.createBuffer({
      size: values.byteLength,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    device.queue.writeBuffer(input, 0, values);
    const bindGroup = device.createBindGroup({
      layout: pipeline.getBindGroupLayout(0),
      entries: [
        { binding: 0, resource: { buffer: input } },
        { binding: 1, resource: { buffer: output } }
      ]
    });
    const encoder = device.createCommandEncoder();
    const pass = encoder.beginComputePass();
    pass.setPipeline(pipeline);
    pass.setBindGroup(0, bindGroup);
    pass.dispatchWorkgroups(1);
    pass.end();
    encoder.copyBufferToBuffer(output, 0, readback, 0, values.byteLength);
    device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);

    expect(new Uint32Array(readback.getMappedRange().slice(0))).toEqual(values);
    readback.unmap();
  });

  it("executes generated atomic append and preserves every invocation", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const { compute } = generateWGSLCompute(atomicComputeShader);
    const pipeline = device.createComputePipeline({
      layout: "auto",
      compute: { module: device.createShaderModule({ code: compute }), entryPoint: "main" }
    });
    const counter = device.createBuffer({
      size: Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST
    });
    const output = device.createBuffer({
      size: 64 * Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
    });
    const readback = device.createBuffer({
      size: 65 * Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    device.queue.writeBuffer(counter, 0, new Uint32Array([0]));
    const bindGroup = device.createBindGroup({
      layout: pipeline.getBindGroupLayout(0),
      entries: [
        { binding: 0, resource: { buffer: counter } },
        { binding: 1, resource: { buffer: output } }
      ]
    });
    const encoder = device.createCommandEncoder();
    const pass = encoder.beginComputePass();
    pass.setPipeline(pipeline);
    pass.setBindGroup(0, bindGroup);
    pass.dispatchWorkgroups(1);
    pass.end();
    encoder.copyBufferToBuffer(counter, 0, readback, 0, Uint32Array.BYTES_PER_ELEMENT);
    encoder.copyBufferToBuffer(output, 0, readback, Uint32Array.BYTES_PER_ELEMENT, 64 * Uint32Array.BYTES_PER_ELEMENT);
    device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);

    const result = new Uint32Array(readback.getMappedRange().slice(0));
    expect(result[0]).toBe(64);
    expect(Array.from(result.slice(1)).sort((left, right) => left - right)).toEqual(
      Array.from({ length: 64 }, (_, index) => index)
    );
    readback.unmap();
  });

  it("rejects unsupported non-atomic access to an atomic storage buffer", () => {
    const source = atomicComputeShader.replace(
      "outputValues[outputIndex] = index;",
      "outputValues[outputIndex] = counters[0u];"
    );

    expect(() => generateWGSLCompute(source)).toThrow(
      'ShaderLab storage buffer "counters" uses atomic elements; only atomicAdd access is supported.'
    );
  });

  it("preserves atomic lowering in a WGSL precompiled artifact", () => {
    const compiler = new ShaderCompiler();
    const artifact = compiler._precompile(atomicComputeShader, ShaderLanguage.WGSL, "shaders://root/");
    const pass = artifact.subShaders[0].passes[0];
    const compute = ShaderMacroProcessor.evaluate(
      pass.computeShaderInstructions!,
      new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "64"]])
    );

    expect(compute).toContain("var<storage, read_write> counters: array<atomic<u32>>");
    expect(compute).toContain("atomicAdd(&counters[0u], 1u)");
  });

  it("preserves compute instructions and reflection in a WGSL precompiled artifact", () => {
    const compiler = new ShaderCompiler();
    const artifact = compiler._precompile(computeShader, ShaderLanguage.WGSL, "shaders://root/");
    const restored = JSON.parse(JSON.stringify(artifact)) as typeof artifact;
    const pass = restored.subShaders[0].passes[0];

    expect(pass.computeShaderInstructions?.length).toBeGreaterThan(0);
    expect(pass.computeWorkgroupSize).toEqual(["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "1", "1"]);
    expect(pass.reflection?.storageBuffers?.map(({ name, access }) => ({ name, access }))).toEqual([
      { name: "inputValues", access: "read" },
      { name: "outputValues", access: "read_write" }
    ]);

    const compute = ShaderMacroProcessor.evaluate(
      pass.computeShaderInstructions!,
      new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "32"]])
    );
    expect(compute).toContain("@workgroup_size(32, 1, 1)");
  });

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
