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

  it("keeps WebGL compute explicitly unsupported", () => {
    const graphicDevice = new WebGLGraphicDevice();

    expect(graphicDevice.computeCapabilities.supported).toBe(false);
    expect(() => graphicDevice.createPlatformComputeProgram()).toThrowError(
      "Compute passes are not supported by the WebGL backend."
    );
  });
});
