import {
  Buffer,
  BufferBindFlag,
  BufferUsage,
  ComputePass,
  Shader,
  ShaderLanguage,
  WebGLGraphicDevice,
  WebGPUEngine
} from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { describe, expect, it } from "vitest";

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

  it("keeps WebGL compute explicitly unsupported", () => {
    const graphicDevice = new WebGLGraphicDevice();

    expect(graphicDevice.computeCapabilities.supported).toBe(false);
    expect(() => graphicDevice.createPlatformComputeProgram()).toThrowError(
      "Compute passes are not supported by the WebGL backend."
    );
  });
});
