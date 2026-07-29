import {
  AssetType,
  Buffer,
  BufferBindFlag,
  BufferUsage,
  ComputePass,
  Shader,
  ShaderLanguage,
  Texture2D,
  TextureFilterMode,
  TextureFormat,
  WebGLGraphicDevice,
  WebGPUEngine
} from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { describe, expect, it, vi } from "vitest";

function createComputeShaderSource(name: string): string {
  return `
Shader "${name}" {
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
}

function createSampledTextureShaderSource(name: string): string {
  return `
Shader "${name}" {
  SubShader "Default" {
    Pass "ReadTexture" {
      sampler2D inputTexture;
      buffer vec4 outputValues[];

      void readTexels() {
        uint index = gl_GlobalInvocationID.x;
        outputValues[index] = texelFetch(inputTexture, ivec2(int(index), 0), 0);
      }

      ComputeShader = readTexels;
    }
  }
}
`;
}

async function readStorageBuffer(device: GPUDevice, buffer: Buffer, byteLength: number): Promise<ArrayBuffer> {
  const readback = device.createBuffer({
    size: byteLength,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
  });
  const encoder = device.createCommandEncoder();
  encoder.copyBufferToBuffer(
    (buffer._platformBuffer as unknown as { _gpuBuffer: GPUBuffer })._gpuBuffer,
    0,
    readback,
    0,
    byteLength
  );
  device.queue.submit([encoder.finish()]);
  await readback.mapAsync(GPUMapMode.READ);
  const data = readback.getMappedRange().slice(0);
  readback.unmap();
  readback.destroy();
  return data;
}

describe("ComputePass", () => {
  it("dispatches generated WGSL through the engine RHI and writes storage data", async () => {
    if (!navigator.gpu) {
      return;
    }

    const canvas = document.createElement("canvas");
    const engine = await WebGPUEngine.create({ canvas, shaderCompiler: new ShaderCompiler() });
    const shader = Shader.create(createComputeShaderSource("RHI/ComputeCopy"), ShaderLanguage.WGSL);
    const computePass = new ComputePass(engine, shader);
    const values = Uint32Array.from({ length: 64 * 4 }, (_, index) => index * 5 + 11);
    const input = new Buffer(engine, BufferBindFlag.StorageBuffer, values, BufferUsage.Dynamic);
    const output = new Buffer(engine, BufferBindFlag.StorageBuffer, values.byteLength, BufferUsage.Dynamic);
    computePass.setBuffer("inputValues", input);
    expect(() => computePass.dispatch(1)).toThrowError('Compute storage buffer "outputValues" is not bound.');
    computePass.setBuffer("outputValues", output);
    computePass.dispatch(1);
    engine._hardwareRenderer.flush();

    const graphicDevice = engine._hardwareRenderer as {
      device: GPUDevice;
      computeCapabilities: { recommendedWorkgroupSizeX: number };
    };
    expect(engine.computeCapabilities).toBe(graphicDevice.computeCapabilities);
    const nativeOutput = (output._platformBuffer as unknown as { _gpuBuffer: GPUBuffer })._gpuBuffer;
    const readback = graphicDevice.device.createBuffer({
      size: values.byteLength,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    const encoder = graphicDevice.device.createCommandEncoder();
    encoder.copyBufferToBuffer(nativeOutput, 0, readback, 0, values.byteLength);
    graphicDevice.device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);

    expect(new Uint32Array(readback.getMappedRange().slice(0))).toEqual(values);
    expect(computePass.workgroupSize).toEqual([graphicDevice.computeCapabilities.recommendedWorkgroupSizeX, 1, 1]);

    readback.unmap();
    readback.destroy();
    computePass.destroy();
    input.destroy(true);
    output.destroy(true);
    engine.destroy();
  });

  it("shares native pipeline and pass state across consecutive compute programs", async () => {
    if (!navigator.gpu) {
      return;
    }

    const canvas = document.createElement("canvas");
    const engine = await WebGPUEngine.create({ canvas, shaderCompiler: new ShaderCompiler() });
    const shader = Shader.create(createComputeShaderSource("RHI/ComputeShared"), ShaderLanguage.WGSL);
    const firstPass = new ComputePass(engine, shader);
    const secondPass = new ComputePass(engine, shader);
    const values = Uint32Array.from({ length: 64 * 4 }, (_, index) => index * 7 + 3);
    const input = new Buffer(engine, BufferBindFlag.StorageBuffer, values, BufferUsage.Dynamic);
    const firstOutput = new Buffer(engine, BufferBindFlag.StorageBuffer, values.byteLength, BufferUsage.Dynamic);
    const secondOutput = new Buffer(engine, BufferBindFlag.StorageBuffer, values.byteLength, BufferUsage.Dynamic);
    firstPass.setBuffer("inputValues", input);
    firstPass.setBuffer("outputValues", firstOutput);
    secondPass.setBuffer("inputValues", input);
    secondPass.setBuffer("outputValues", secondOutput);

    const graphicDevice = engine._hardwareRenderer as {
      device: GPUDevice;
      _computePass: GPUComputePassEncoder | null;
      _computePipelines: Map<string, unknown>;
    };
    firstPass.dispatch(1);
    const nativePass = graphicDevice._computePass;
    secondPass.dispatch(1);

    expect(nativePass).toBeDefined();
    expect(graphicDevice._computePass).toBe(nativePass);
    expect(graphicDevice._computePipelines.size).toBe(1);
    const shaderPass = shader.subShaders[0].passes[0];
    expect(shaderPass._compileComputeShaderSource(engine)).toBe(shaderPass._compileComputeShaderSource(engine));
    engine._hardwareRenderer.flush();
    expect(graphicDevice._computePass).toBeNull();

    const readback = graphicDevice.device.createBuffer({
      size: values.byteLength * 2,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    const encoder = graphicDevice.device.createCommandEncoder();
    encoder.copyBufferToBuffer(
      (firstOutput._platformBuffer as unknown as { _gpuBuffer: GPUBuffer })._gpuBuffer,
      0,
      readback,
      0,
      values.byteLength
    );
    encoder.copyBufferToBuffer(
      (secondOutput._platformBuffer as unknown as { _gpuBuffer: GPUBuffer })._gpuBuffer,
      0,
      readback,
      values.byteLength,
      values.byteLength
    );
    graphicDevice.device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);
    const copiedValues = readback.getMappedRange().slice(0);

    expect(new Uint32Array(copiedValues, 0, values.length)).toEqual(values);
    expect(new Uint32Array(copiedValues, values.byteLength, values.length)).toEqual(values);

    readback.unmap();
    readback.destroy();
    firstPass.destroy();
    secondPass.destroy();
    input.destroy(true);
    firstOutput.destroy(true);
    secondOutput.destroy(true);
    engine.destroy();
  });

  it("binds sampled textures by reflection and rebuilds only changed native bindings", async () => {
    if (!navigator.gpu) {
      return;
    }

    const compiler = new ShaderCompiler();
    const engine = await WebGPUEngine.create({ canvas: document.createElement("canvas"), shaderCompiler: compiler });
    const foreignEngine = await WebGPUEngine.create({
      canvas: document.createElement("canvas"),
      shaderCompiler: compiler
    });
    const shader = Shader.create(createSampledTextureShaderSource("RHI/ComputeSampledTexture"), ShaderLanguage.WGSL);
    const computePass = new ComputePass(engine, shader);
    const outputByteLength = 64 * 4 * Float32Array.BYTES_PER_ELEMENT;
    const output = new Buffer(engine, BufferBindFlag.StorageBuffer, outputByteLength, BufferUsage.Dynamic);
    const firstPixels = Uint8Array.from({ length: 64 * 4 }, (_, index) => (index * 13 + 7) % 256);
    const secondPixels = Uint8Array.from({ length: 64 * 4 }, (_, index) => (index * 29 + 3) % 256);
    const firstTexture = new Texture2D(engine, 64, 1, TextureFormat.R8G8B8A8, false, false);
    const secondTexture = new Texture2D(engine, 64, 1, TextureFormat.R8G8B8A8, false, false);
    const foreignTexture = new Texture2D(foreignEngine, 64, 1, TextureFormat.R8G8B8A8, false, false);
    firstTexture.setPixelBuffer(firstPixels);
    secondTexture.setPixelBuffer(secondPixels);
    computePass.setBuffer("outputValues", output);

    expect(() => computePass.setTexture("missingTexture", firstTexture)).toThrowError(
      'Compute shader "RHI/ComputeSampledTexture" has no sampled texture named "missingTexture".'
    );
    expect(() => computePass.setTexture("inputTexture", foreignTexture)).toThrowError(
      'Compute texture "inputTexture" belongs to a different engine.'
    );
    expect(() => computePass.dispatch(1)).toThrowError('Compute sampled texture "inputTexture" is not bound.');

    computePass.setTexture("inputTexture", firstTexture);
    expect(firstTexture.refCount).toBe(1);
    computePass.dispatch(1);
    const platformProgram = (
      computePass as unknown as {
        _platformProgram: { _bindGroup: GPUBindGroup };
      }
    )._platformProgram;
    const firstBindGroup = platformProgram._bindGroup;

    computePass.setTexture("inputTexture", firstTexture);
    computePass.dispatch(1);
    expect(platformProgram._bindGroup).toBe(firstBindGroup);

    firstTexture.filterMode = TextureFilterMode.Point;
    computePass.dispatch(1);
    const samplerUpdatedBindGroup = platformProgram._bindGroup;
    expect(samplerUpdatedBindGroup).not.toBe(firstBindGroup);

    computePass.setTexture("inputTexture", secondTexture);
    expect(firstTexture.refCount).toBe(0);
    expect(secondTexture.refCount).toBe(1);
    computePass.dispatch(1);
    expect(platformProgram._bindGroup).not.toBe(samplerUpdatedBindGroup);
    engine._hardwareRenderer.flush();

    const device = (engine._hardwareRenderer as { device: GPUDevice }).device;
    const result = new Float32Array(await readStorageBuffer(device, output, outputByteLength));
    for (let index = 0; index < secondPixels.length; index++) {
      expect(result[index]).toBeCloseTo(secondPixels[index] / 255, 5);
    }

    computePass.destroy();
    expect(secondTexture.refCount).toBe(0);
    output.destroy(true);
    firstTexture.destroy(true);
    secondTexture.destroy(true);
    foreignTexture.destroy(true);
    engine.destroy();
    foreignEngine.destroy();
  });

  it("executes sampled-texture compute from a serialized WGSL artifact", async () => {
    if (!navigator.gpu) {
      return;
    }

    const compiler = new ShaderCompiler();
    const engine = await WebGPUEngine.create({ canvas: document.createElement("canvas"), shaderCompiler: compiler });
    const source = createSampledTextureShaderSource("RHI/ComputeSampledTexturePrecompiled");
    const artifact = JSON.parse(JSON.stringify(compiler._precompile(source, ShaderLanguage.WGSL, "shaders://root/")));
    const request = vi.spyOn(engine.resourceManager, "_request").mockResolvedValue(artifact);
    const shader = await engine.resourceManager.load<Shader>({
      type: AssetType.Shader,
      url: "/RHI/ComputeSampledTexturePrecompiled.wgslc"
    });
    expect(request).toHaveBeenCalledWith(
      "/RHI/ComputeSampledTexturePrecompiled.wgslc",
      expect.objectContaining({ type: "json" })
    );
    const computePass = new ComputePass(engine, shader);
    const outputByteLength = 64 * 4 * Float32Array.BYTES_PER_ELEMENT;
    const pixels = Uint8Array.from({ length: 64 * 4 }, (_, index) => (index * 17 + 5) % 256);
    const texture = new Texture2D(engine, 64, 1, TextureFormat.R8G8B8A8, false, false);
    const output = new Buffer(engine, BufferBindFlag.StorageBuffer, outputByteLength, BufferUsage.Dynamic);
    texture.setPixelBuffer(pixels);
    computePass.setTexture("inputTexture", texture);
    computePass.setBuffer("outputValues", output);
    computePass.dispatch(1);
    engine._hardwareRenderer.flush();

    const device = (engine._hardwareRenderer as { device: GPUDevice }).device;
    const result = new Float32Array(await readStorageBuffer(device, output, outputByteLength));
    for (let index = 0; index < pixels.length; index++) {
      expect(result[index]).toBeCloseTo(pixels[index] / 255, 5);
    }

    computePass.destroy();
    output.destroy(true);
    texture.destroy(true);
    engine.destroy();
  });

  it("keeps WebGL compute explicitly unsupported", () => {
    const graphicDevice = new WebGLGraphicDevice();

    expect(graphicDevice.computeCapabilities.supported).toBe(false);
    expect(() => graphicDevice.createPlatformComputeProgram()).toThrowError(
      "Compute passes are not supported by the WebGL backend."
    );
  });
});
