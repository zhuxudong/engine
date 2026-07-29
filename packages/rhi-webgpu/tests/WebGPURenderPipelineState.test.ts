import { describe, expect, it, vi } from "vitest";
import { WebGPUGraphicDevice } from "../src/WebGPUGraphicDevice";

describe("WebGPU render pipeline state", () => {
  it("encodes pipeline identity changes within one render pass", () => {
    const device = createGraphicDevice();
    const pass = createRenderPass();
    const firstPipeline = {} as GPURenderPipeline;
    const secondPipeline = {} as GPURenderPipeline;

    device._setRenderPipeline(pass.encoder, firstPipeline);
    device._setRenderPipeline(pass.encoder, firstPipeline);
    device._setRenderPipeline(pass.encoder, secondPipeline);
    device._setRenderPipeline(pass.encoder, firstPipeline);

    expect(pass.setPipeline.mock.calls).toEqual([[firstPipeline], [secondPipeline], [firstPipeline]]);
  });

  it("encodes the first pipeline of a new pass and releases ended pass state", () => {
    const device = createGraphicDevice();
    const pipeline = {} as GPURenderPipeline;
    const firstPass = createRenderPass();
    const secondPass = createRenderPass();

    device._setRenderPipeline(firstPass.encoder, pipeline);
    device._setRenderPipeline(secondPass.encoder, pipeline);

    expect(firstPass.setPipeline).toHaveBeenCalledOnce();
    expect(secondPass.setPipeline).toHaveBeenCalledOnce();

    const internalDevice = device as unknown as {
      _renderPass: GPURenderPassEncoder;
      _currentRenderPipelinePass: GPURenderPassEncoder | null;
      _currentRenderPipeline: GPURenderPipeline | null;
      _endRenderPass(): void;
    };
    internalDevice._renderPass = secondPass.encoder;
    internalDevice._endRenderPass();

    expect(secondPass.end).toHaveBeenCalledOnce();
    expect(internalDevice._currentRenderPipelinePass).toBeNull();
    expect(internalDevice._currentRenderPipeline).toBeNull();
  });
});

function createGraphicDevice(): WebGPUGraphicDevice {
  const device = Object.create(WebGPUGraphicDevice.prototype) as WebGPUGraphicDevice;
  Object.assign(device, {
    _currentRenderPipelinePass: null,
    _currentRenderPipeline: null
  });
  return device;
}

function createRenderPass(): {
  encoder: GPURenderPassEncoder;
  setPipeline: ReturnType<typeof vi.fn>;
  end: ReturnType<typeof vi.fn>;
} {
  const setPipeline = vi.fn();
  const end = vi.fn();
  return {
    encoder: { setPipeline, end } as unknown as GPURenderPassEncoder,
    setPipeline,
    end
  };
}
