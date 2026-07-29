import { Color, Vector4 } from "@galacean/engine-math";
import { describe, expect, it, vi } from "vitest";
import { WebGPUGraphicDevice } from "../src/WebGPUGraphicDevice";

describe("WebGPU dynamic render state", () => {
  it("encodes only changed values within one render pass", () => {
    const state = createRenderState();
    const device = createGraphicDevice(state);
    const pass = createRenderPass();

    device._applyDynamicState(pass.encoder);
    device._applyDynamicState(pass.encoder);

    expect(pass.setViewport).toHaveBeenCalledTimes(1);
    expect(pass.setViewport).toHaveBeenCalledWith(10, 5, 90, 45, 0, 1);
    expect(pass.setScissorRect).toHaveBeenCalledTimes(1);
    expect(pass.setScissorRect).toHaveBeenCalledWith(10, 5, 90, 45);
    expect(pass.setBlendConstant).toHaveBeenCalledTimes(1);
    expect(pass.setBlendConstant).toHaveBeenCalledWith({ r: 0.1, g: 0.2, b: 0.3, a: 0.4 });
    expect(pass.setStencilReference).toHaveBeenCalledTimes(1);
    expect(pass.setStencilReference).toHaveBeenCalledWith(7);

    device.viewport(12, 5, 120, 60);
    device._applyDynamicState(pass.encoder);
    expect(pass.setViewport).toHaveBeenCalledTimes(2);
    expect(pass.setScissorRect).toHaveBeenCalledTimes(1);

    device.scissor(12, 5, 120, 60);
    device._applyDynamicState(pass.encoder);
    expect(pass.setScissorRect).toHaveBeenCalledTimes(2);

    state.blendState.blendColor.r = 0.5;
    device._applyDynamicState(pass.encoder);
    expect(pass.setBlendConstant).toHaveBeenCalledTimes(2);

    state.stencilState.referenceValue = 9;
    device._applyDynamicState(pass.encoder);
    expect(pass.setStencilReference).toHaveBeenCalledTimes(2);
  });

  it("compares clamped values and re-encodes the first state of a new pass", () => {
    const device = createGraphicDevice(createRenderState());
    const firstPass = createRenderPass();

    device._applyDynamicState(firstPass.encoder);
    device.viewport(10, 5, 1_000, 1_000);
    device.scissor(10, 5, 1_000, 1_000);
    device._applyDynamicState(firstPass.encoder);

    expect(firstPass.setViewport).toHaveBeenCalledTimes(1);
    expect(firstPass.setScissorRect).toHaveBeenCalledTimes(1);

    const secondPass = createRenderPass();
    device._applyDynamicState(secondPass.encoder);

    expect(secondPass.setViewport).toHaveBeenCalledTimes(1);
    expect(secondPass.setScissorRect).toHaveBeenCalledTimes(1);
    expect(secondPass.setBlendConstant).toHaveBeenCalledTimes(1);
    expect(secondPass.setStencilReference).toHaveBeenCalledTimes(1);
  });
});

function createGraphicDevice(state: ReturnType<typeof createRenderState>): WebGPUGraphicDevice {
  const device = Object.create(WebGPUGraphicDevice.prototype) as WebGPUGraphicDevice;
  Object.assign(device, {
    _canvas: { width: 100, height: 50 },
    _currentRenderTarget: null,
    _viewport: new Vector4(),
    _scissor: new Vector4(),
    _dynamicStateCache: null
  });
  device.viewport(10, 5, 120, 60);
  device.scissor(10, 5, 120, 60);
  device.setRenderState(state, false);
  return device;
}

function createRenderState(): {
  blendState: { blendColor: Color };
  stencilState: { referenceValue: number };
} {
  return {
    blendState: { blendColor: new Color(0.1, 0.2, 0.3, 0.4) },
    stencilState: { referenceValue: 7 }
  };
}

function createRenderPass(): {
  encoder: GPURenderPassEncoder;
  setViewport: ReturnType<typeof vi.fn>;
  setScissorRect: ReturnType<typeof vi.fn>;
  setBlendConstant: ReturnType<typeof vi.fn>;
  setStencilReference: ReturnType<typeof vi.fn>;
} {
  const setViewport = vi.fn();
  const setScissorRect = vi.fn();
  const setBlendConstant = vi.fn();
  const setStencilReference = vi.fn();
  return {
    encoder: {
      setViewport,
      setScissorRect,
      setBlendConstant,
      setStencilReference
    } as unknown as GPURenderPassEncoder,
    setViewport,
    setScissorRect,
    setBlendConstant,
    setStencilReference
  };
}
