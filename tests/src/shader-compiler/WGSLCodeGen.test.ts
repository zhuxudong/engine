import type { IShaderReflection, IShaderUniformReflection } from "@galacean/engine-design";
import { ShaderFactory, ShaderLanguage, ShaderPass } from "@galacean/engine-core";
import { ShaderMacroProcessor } from "@galacean/engine-core/src/shader/ShaderMacroProcessor";
import { shaderLibrary } from "@galacean/engine-shader";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { describe, expect, it } from "vitest";

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

const halfValueShader = `
Shader "WGSL/HalfValue" {
  SubShader "Default" {
    Pass "Forward" {
      mat4 renderer_MVPMat;

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
        half3 localPosition = half3(attributes.POSITION);
        gl_Position = renderer_MVPMat * vec4(half4(localPosition, half(1.0)));
        output.v_uv = vec2(localPosition.xy);
        return output;
      }

      vec4 frag(Varyings varyings) {
        half2 localUv = half2(varyings.v_uv);
        half4 localColor = half4(localUv, half(0.25), half(1.0));
        return vec4(localColor);
      }
    }
  }
}
`;

const invalidHalfInterfaceShader = `
Shader "WGSL/InvalidHalfInterface" {
  SubShader "Default" {
    Pass "Forward" {
      half4 material_Color;

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
        gl_Position = vec4(attributes.POSITION, 1.0);
        output.v_uv = attributes.POSITION.xy;
        return output;
      }

      vec4 frag(Varyings varyings) {
        return material_Color;
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
      shared uint outputOffsets[1];
      buffer uint counters[];
      buffer uint outputValues[];

      void appendValues() {
        uint index = gl_GlobalInvocationID.x;
        if (gl_LocalInvocationID.x == 0u) {
          outputOffsets[0u] = atomicAdd(counters[0u], uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X));
        }
        barrier();
        outputValues[outputOffsets[0u] + gl_LocalInvocationID.x] = index;
      }

      ComputeShader = appendValues;
    }
  }
}
`;

const workgroupAtomicComputeShader = `
Shader "WGSL/ComputeWorkgroupAtomicAppend" {
  SubShader "Default" {
    Pass "Append" {
      shared uint groupCount;
      shared uint groupBase;
      buffer uint counters[];
      buffer uint outputValues[];

      void appendValues() {
        uint index = gl_GlobalInvocationID.x;
        if (gl_LocalInvocationID.x == 0u) {
          atomicStore(groupCount, 0u);
        }
        barrier();

        bool valid = index % 3u != 0u;
        uint localSlot = 0u;
        if (valid) {
          localSlot = atomicAdd(groupCount, 1u);
        }
        barrier();

        if (gl_LocalInvocationID.x == 0u) {
          groupBase = atomicAdd(counters[0u], atomicLoad(groupCount));
        }
        barrier();
        if (valid) {
          outputValues[groupBase + localSlot] = index;
        }
      }

      ComputeShader = appendValues;
    }
  }
}
`;

const workgroupAtomicMaxComputeShader = `
Shader "WGSL/ComputeWorkgroupAtomicMax" {
  SubShader "Default" {
    Pass "ReduceMax" {
      shared uint maximum;
      buffer uint outputValues[];

      void reduceMax() {
        if (gl_LocalInvocationID.x == 0u) {
          atomicStore(maximum, 0u);
        }
        barrier();
        atomicMax(maximum, gl_LocalInvocationID.x * 3u + 7u);
        barrier();
        if (gl_LocalInvocationID.x == 0u) {
          outputValues[0u] = atomicLoad(maximum);
        }
      }

      ComputeShader = reduceMax;
    }
  }
}
`;

const halfPackingComputeShader = `
Shader "WGSL/ComputeHalfPacking" {
  SubShader "Default" {
    Pass "Pack" {
      readonly buffer vec4 inputValues[];
      buffer uint outputValues[];

      void packValues() {
        uint index = gl_GlobalInvocationID.x;
        outputValues[index * 2u] = packHalf2x16(inputValues[index].xy);
        outputValues[index * 2u + 1u] = packHalf2x16(inputValues[index].zw);
      }

      ComputeShader = packValues;
    }
  }
}
`;

const bitcastComputeShader = `
Shader "WGSL/ComputeBitcast" {
  SubShader "Default" {
    Pass "Cast" {
      readonly buffer vec4 inputValues[];
      buffer uint scalarValues[];
      buffer uvec2 vectorValues[];

      void castValues() {
        uint index = gl_GlobalInvocationID.x;
        scalarValues[index] = floatBitsToUint(inputValues[index].x);
        vectorValues[index] = floatBitsToUint(inputValues[index].yz);
      }

      ComputeShader = castValues;
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

function generateGLESFromSource(
  source: string,
  language: ShaderLanguage.GLSLES100 | ShaderLanguage.GLSLES300
): { vertex: string; fragment: string } {
  const compiler = new ShaderCompiler();
  const shader = compiler._parseShaderSource(source);
  const pass = shader.subShaders[0].passes[0];
  const program = compiler._parseShaderPass(
    pass.contents,
    pass.vertexEntry,
    pass.fragmentEntry,
    language,
    "shaders://root/"
  );

  expect(program).toBeDefined();
  return {
    vertex: ShaderMacroProcessor.evaluate(program!.vertexShaderInstructions!, new Map()),
    fragment: ShaderMacroProcessor.evaluate(program!.fragmentShaderInstructions!, new Map())
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
  it("emits explicit half values with native f16 and f32 fallback aliases", () => {
    const native = generateWGSLFromSource(halfValueShader, new Map([["GRAPHICS_FEATURE_SHADER_F16", ""]]));
    const fallback = generateWGSLFromSource(halfValueShader);
    const unchanged = generateWGSL();

    for (const source of [native.vertex, native.fragment]) {
      expect(source).toContain("enable f16;");
      expect(source).toContain("alias half = f16;");
      expect(source).toContain("alias half4 = vec4<f16>;");
      expect(source).not.toContain("#");
    }
    for (const source of [fallback.vertex, fallback.fragment]) {
      expect(source).not.toContain("enable f16;");
      expect(source).toContain("alias half = f32;");
      expect(source).toContain("alias half4 = vec4<f32>;");
      expect(source).not.toContain("#");
    }
    expect(native.vertex).toContain("var localPosition: half3 = half3(POSITION)");
    expect(native.fragment).toContain("var localColor: half4 = half4(localUv, half(0.25), half(1.0))");
    expect(unchanged.vertex).not.toContain("alias half");
    expect(unchanged.fragment).not.toContain("alias half");
  });

  it("lowers explicit half values to valid GLES precision declarations", () => {
    for (const language of [ShaderLanguage.GLSLES100, ShaderLanguage.GLSLES300] as const) {
      const generated = generateGLESFromSource(halfValueShader, language);
      expect(generated.vertex).toContain("mediump vec3 localPosition");
      expect(generated.vertex).toContain("vec3 ( POSITION )");
      expect(generated.fragment).toContain("mediump vec4 localColor");
      expect(generated.fragment).not.toMatch(/\bhalf[234]?\b/);
    }
  });

  it("rejects half values in shader interfaces", () => {
    expect(() => generateWGSLFromSource(invalidHalfInterfaceShader)).toThrow(
      "ShaderLab half4 is only supported in function-local declarations and explicit constructors."
    );
    expect(() => generateGLESFromSource(invalidHalfInterfaceShader, ShaderLanguage.GLSLES300)).toThrow(
      "ShaderLab half4 is only supported in function-local declarations and explicit constructors."
    );
  });

  it("passes native WebGPU validation for half native and fallback variants", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const nativeAdapter = adapter!.features.has("shader-f16") ? await navigator.gpu.requestAdapter() : null;

    const fallback = generateWGSLFromSource(halfValueShader);
    const fallbackDevice = await adapter!.requestDevice();
    const fallbackInfos = await Promise.all([
      fallbackDevice.createShaderModule({ code: fallback.vertex }).getCompilationInfo(),
      fallbackDevice.createShaderModule({ code: fallback.fragment }).getCompilationInfo()
    ]);
    expect([
      ...formatCompilationErrors("fallback vertex", fallbackInfos[0], fallback.vertex),
      ...formatCompilationErrors("fallback fragment", fallbackInfos[1], fallback.fragment)
    ]).toEqual([]);

    if (!nativeAdapter) {
      return;
    }
    const native = generateWGSLFromSource(halfValueShader, new Map([["GRAPHICS_FEATURE_SHADER_F16", ""]]));
    const nativeDevice = await nativeAdapter.requestDevice({ requiredFeatures: ["shader-f16"] });
    const nativeInfos = await Promise.all([
      nativeDevice.createShaderModule({ code: native.vertex }).getCompilationInfo(),
      nativeDevice.createShaderModule({ code: native.fragment }).getCompilationInfo()
    ]);
    expect([
      ...formatCompilationErrors("native vertex", nativeInfos[0], native.vertex),
      ...formatCompilationErrors("native fragment", nativeInfos[1], native.fragment)
    ]).toEqual([]);
  });

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

  it("lowers ShaderLab storage atomics and workgroup synchronization to valid WGSL", async () => {
    const { compute, reflection } = generateWGSLCompute(atomicComputeShader);

    expect(compute).toContain("var<workgroup> outputOffsets: array<u32, 1>;");
    expect(compute).toContain("var<storage, read_write> counters: array<atomic<u32>>");
    expect(compute).toContain("atomicAdd(&counters[0u], u32(64))");
    expect(compute).toContain("workgroupBarrier()");
    expect(reflection.storageBuffers?.[0]).toMatchObject({
      name: "counters",
      access: "read_write",
      elementType: "u32"
    });
    expect(reflection.storageBuffers).toHaveLength(2);
    expect(reflection.uniforms.some(({ name }) => name === "outputOffsets")).toBe(false);

    if (!navigator.gpu) {
      return;
    }
    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const info = await device.createShaderModule({ code: compute }).getCompilationInfo();

    expect(formatCompilationErrors("compute", info, compute)).toEqual([]);
  });

  it("lowers shared atomics with load and store to valid WGSL", async () => {
    const { compute, reflection } = generateWGSLCompute(workgroupAtomicComputeShader);

    expect(compute).toContain("var<workgroup> groupCount: atomic<u32>;");
    expect(compute).toContain("var<workgroup> groupBase: u32;");
    expect(compute).toContain("atomicStore(&groupCount, 0u)");
    expect(compute).toContain("atomicAdd(&groupCount, 1u)");
    expect(compute).toContain("atomicLoad(&groupCount)");
    expect(compute).toContain("atomicAdd(&counters[0u], atomicLoad(&groupCount))");
    expect(reflection.storageBuffers?.map(({ name }) => name)).toEqual(["counters", "outputValues"]);
    expect(reflection.uniforms.some(({ name }) => name === "groupCount" || name === "groupBase")).toBe(false);

    if (!navigator.gpu) {
      return;
    }
    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const info = await device.createShaderModule({ code: compute }).getCompilationInfo();

    expect(formatCompilationErrors("compute", info, compute)).toEqual([]);
  });

  it("lowers shared atomic maximum reduction to valid WGSL", async () => {
    const { compute } = generateWGSLCompute(workgroupAtomicMaxComputeShader);

    expect(compute).toContain("var<workgroup> maximum: atomic<u32>;");
    expect(compute).toContain("atomicMax(&maximum, _gsLocalInvocationID.x * 3u + 7u)");

    if (!navigator.gpu) {
      return;
    }
    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const info = await device.createShaderModule({ code: compute }).getCompilationInfo();

    expect(formatCompilationErrors("compute", info, compute)).toEqual([]);
  });

  it("lowers and executes half-float storage packing", async () => {
    const { compute } = generateWGSLCompute(
      halfPackingComputeShader,
      new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "1"]])
    );

    expect(compute).toContain("pack2x16float(inputValues[index].xy)");
    expect(compute).not.toContain("packHalf2x16");
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const module = device.createShaderModule({ code: compute });
    const info = await module.getCompilationInfo();
    expect(formatCompilationErrors("compute", info, compute)).toEqual([]);

    const pipeline = device.createComputePipeline({
      layout: "auto",
      compute: { module, entryPoint: "main" }
    });
    const input = device.createBuffer({
      size: 16,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST
    });
    const output = device.createBuffer({
      size: 8,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
    });
    const readback = device.createBuffer({
      size: 8,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    device.queue.writeBuffer(input, 0, new Float32Array([1, -2, 0.5, 65504]));
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
    encoder.copyBufferToBuffer(output, 0, readback, 0, 8);
    device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);

    expect(new Uint32Array(readback.getMappedRange().slice(0))).toEqual(new Uint32Array([0xc0003c00, 0x7bff3800]));
    readback.unmap();
  });

  it("lowers scalar and vector bit reinterpretation to valid WGSL targets", async () => {
    const { compute } = generateWGSLCompute(
      bitcastComputeShader,
      new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "1"]])
    );

    expect(compute).toContain("bitcast<u32>(inputValues[index].x)");
    expect(compute).toContain("bitcast<vec2<u32>>(inputValues[index].yz)");
    expect(compute).not.toContain("bitcast<3000>");
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

  it("executes generated workgroup append and preserves every invocation", async () => {
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

  it("executes two generated workgroups with one global reservation each", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const { compute } = generateWGSLCompute(workgroupAtomicComputeShader);
    const pipeline = device.createComputePipeline({
      layout: "auto",
      compute: { module: device.createShaderModule({ code: compute }), entryPoint: "main" }
    });
    const invocationCount = 128;
    const expected = Array.from({ length: invocationCount }, (_, index) => index).filter((index) => index % 3 !== 0);
    const counter = device.createBuffer({
      size: Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST
    });
    const output = device.createBuffer({
      size: invocationCount * Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
    });
    const readback = device.createBuffer({
      size: (invocationCount + 1) * Uint32Array.BYTES_PER_ELEMENT,
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
    pass.dispatchWorkgroups(2);
    pass.end();
    encoder.copyBufferToBuffer(counter, 0, readback, 0, Uint32Array.BYTES_PER_ELEMENT);
    encoder.copyBufferToBuffer(
      output,
      0,
      readback,
      Uint32Array.BYTES_PER_ELEMENT,
      invocationCount * Uint32Array.BYTES_PER_ELEMENT
    );
    device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);

    const result = new Uint32Array(readback.getMappedRange().slice(0));
    expect(result[0]).toBe(expected.length);
    expect(Array.from(result.slice(1, expected.length + 1)).sort((left, right) => left - right)).toEqual(expected);
    readback.unmap();
  });

  it("executes generated workgroup atomic maximum reduction", async () => {
    if (!navigator.gpu) {
      return;
    }

    const adapter = await navigator.gpu.requestAdapter();
    expect(adapter, "WebGPU adapter is unavailable").not.toBeNull();
    const device = await adapter!.requestDevice();
    const { compute } = generateWGSLCompute(workgroupAtomicMaxComputeShader);
    const pipeline = device.createComputePipeline({
      layout: "auto",
      compute: { module: device.createShaderModule({ code: compute }), entryPoint: "main" }
    });
    const output = device.createBuffer({
      size: Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
    });
    const readback = device.createBuffer({
      size: Uint32Array.BYTES_PER_ELEMENT,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    const bindGroup = device.createBindGroup({
      layout: pipeline.getBindGroupLayout(0),
      entries: [{ binding: 0, resource: { buffer: output } }]
    });
    const encoder = device.createCommandEncoder();
    const pass = encoder.beginComputePass();
    pass.setPipeline(pipeline);
    pass.setBindGroup(0, bindGroup);
    pass.dispatchWorkgroups(1);
    pass.end();
    encoder.copyBufferToBuffer(output, 0, readback, 0, Uint32Array.BYTES_PER_ELEMENT);
    device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);

    expect(new Uint32Array(readback.getMappedRange())[0]).toBe(196);
    readback.unmap();
  });

  it("rejects unsupported non-atomic access to an atomic storage buffer", () => {
    const source = atomicComputeShader.replace(
      "outputValues[outputOffsets[0u] + gl_LocalInvocationID.x] = index;",
      "outputValues[outputOffsets[0u] + gl_LocalInvocationID.x] = counters[0u];"
    );

    expect(() => generateWGSLCompute(source)).toThrow(
      'ShaderLab storage buffer "counters" uses atomic elements; only atomic operations are supported.'
    );
  });

  it("rejects non-atomic access to a shared atomic variable", () => {
    const source = workgroupAtomicComputeShader.replace("uint localSlot = 0u;", "uint localSlot = groupCount;");

    expect(() => generateWGSLCompute(source)).toThrow(
      'ShaderLab shared variable "groupCount" is atomic; only atomic operations are supported.'
    );
  });

  it("preserves atomic and workgroup lowering in a WGSL precompiled artifact", () => {
    const compiler = new ShaderCompiler();
    const artifact = compiler._precompile(atomicComputeShader, ShaderLanguage.WGSL, "shaders://root/");
    const pass = artifact.subShaders[0].passes[0];
    const compute = ShaderMacroProcessor.evaluate(
      pass.computeShaderInstructions!,
      new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "64"]])
    );

    expect(compute).toContain("var<workgroup> outputOffsets: array<u32, 1>;");
    expect(compute).toContain("var<storage, read_write> counters: array<atomic<u32>>");
    expect(compute).toContain("atomicAdd(&counters[0u], u32(64))");
    expect(compute).toContain("workgroupBarrier()");
  });

  it("preserves shared atomic lowering in a WGSL precompiled artifact", () => {
    const compiler = new ShaderCompiler();
    const artifact = compiler._precompile(workgroupAtomicComputeShader, ShaderLanguage.WGSL, "shaders://root/");
    const pass = artifact.subShaders[0].passes[0];
    const compute = ShaderMacroProcessor.evaluate(
      pass.computeShaderInstructions!,
      new Map([["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "64"]])
    );

    expect(compute).toContain("var<workgroup> groupCount: atomic<u32>;");
    expect(compute).toContain("atomicStore(&groupCount, 0u)");
    expect(compute).toContain("atomicLoad(&groupCount)");
  });

  it("rejects workgroup memory and barriers in render passes", () => {
    const sharedSource = basicShader.replace(
      "mat4 renderer_MVPMat;",
      "shared uint outputOffsets[1];\n      mat4 renderer_MVPMat;"
    );
    expect(() => generateWGSLFromSource(sharedSource)).toThrow(
      'ShaderLab shared variable "outputOffsets" is only supported in compute passes.'
    );

    const barrierSource = basicShader.replace(
      "Varyings vert(Attributes attributes) {",
      "Varyings vert(Attributes attributes) {\n        barrier();"
    );
    expect(() => generateWGSLFromSource(barrierSource)).toThrow(
      "ShaderLab barrier is only supported in compute passes."
    );
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
let sampledDepth = textureSample(camera_DepthTexture, camera_DepthTexture_sampler, screenUv).r;
let levelDepth = textureSampleLevel(camera_DepthTexture, camera_DepthTexture_sampler, screenUv, 0.0).r;
let loadedDepth = textureLoad(camera_DepthTexture, pixelCoord, 0).r;`,
      reflection
    );

    expect(lowered.source).toContain("var camera_DepthTexture: texture_depth_2d;");
    expect(lowered.source).toContain(
      "gs_sampleDepth_camera_DepthTexture(camera_DepthTexture, camera_DepthTexture_sampler, screenUv).r"
    );
    expect(lowered.source).toContain(
      "gs_sampleDepthLevel_camera_DepthTexture(camera_DepthTexture, camera_DepthTexture_sampler, screenUv, 0.0).r"
    );
    expect(lowered.source).toContain("gs_loadDepth_camera_DepthTexture(camera_DepthTexture, pixelCoord, 0).r");
    expect(lowered.reflection.resources[0].textureType).toBe("texture_depth_2d");
  });

});
