import { describe, expect, it, vi } from "vitest";
import { WebGPUGraphicDevice } from "../src/WebGPUGraphicDevice";

interface GraphicDeviceInternals {
  _canvas: { width: number; height: number };
  _currentRenderTarget: null;
  _viewport: { x: number; y: number; z: number; w: number; set(x: number, y: number, z: number, w: number): void };
  _scissor: { x: number; y: number; z: number; w: number; set(x: number, y: number, z: number, w: number): void };
  _renderState: {
    state: {
      blendState: { blendColor: { r: number; g: number; b: number; a: number } };
      stencilState: { referenceValue: number };
    };
    frontFaceInvert: boolean;
    customStates?: Record<number, unknown>;
  };
  viewport(x: number, y: number, width: number, height: number): void;
  _setRenderPipeline(pass: GPURenderPassEncoder, pipeline: GPURenderPipeline): void;
  _applyDynamicState(pass: GPURenderPassEncoder): void;
  _resetRenderPassState(): void;
}

function createDevice(): GraphicDeviceInternals {
  const device = Object.create(WebGPUGraphicDevice.prototype) as GraphicDeviceInternals;
  const createVector = (x: number, y: number, z: number, w: number) => ({
    x,
    y,
    z,
    w,
    set(nextX: number, nextY: number, nextZ: number, nextW: number): void {
      this.x = nextX;
      this.y = nextY;
      this.z = nextZ;
      this.w = nextW;
    }
  });
  Object.assign(device, {
    _canvas: { width: 100, height: 80 },
    _currentRenderTarget: null,
    _viewport: createVector(0, 0, 100, 80),
    _scissor: createVector(0, 0, 100, 80),
    _renderState: {
      state: {
        blendState: { blendColor: { r: 0, g: 0, b: 0, a: 0 } },
        stencilState: { referenceValue: 0 }
      },
      frontFaceInvert: false
    }
  });
  device._resetRenderPassState();
  return device;
}

function createPass(): GPURenderPassEncoder {
  return {
    setPipeline: vi.fn(),
    setVertexBuffer: vi.fn(),
    setIndexBuffer: vi.fn(),
    setViewport: vi.fn(),
    setScissorRect: vi.fn(),
    setBlendConstant: vi.fn(),
    setStencilReference: vi.fn()
  } as unknown as GPURenderPassEncoder;
}

describe("WebGPU render-pass state cache", () => {
  it("sets each pipeline once until the pass state is reset", () => {
    const device = createDevice();
    const pass = createPass();
    const first = {} as GPURenderPipeline;
    const second = {} as GPURenderPipeline;

    device._setRenderPipeline(pass, first);
    device._setRenderPipeline(pass, first);
    device._setRenderPipeline(pass, second);
    device._resetRenderPassState();
    device._setRenderPipeline(pass, second);

    expect(pass.setPipeline).toHaveBeenCalledTimes(3);
    expect(pass.setPipeline).toHaveBeenNthCalledWith(1, first);
    expect(pass.setPipeline).toHaveBeenNthCalledWith(2, second);
    expect(pass.setPipeline).toHaveBeenNthCalledWith(3, second);
  });

  it("compares final dynamic-state values and reapplies them after reset", () => {
    const device = createDevice();
    const pass = createPass();

    device._applyDynamicState(pass);
    device._applyDynamicState(pass);
    device.viewport(0, 0, 64, 80);
    device._renderState.state.blendState.blendColor.r = 0.5;
    device._renderState.state.stencilState.referenceValue = 3;
    device._applyDynamicState(pass);

    expect(pass.setViewport).toHaveBeenCalledTimes(2);
    expect(pass.setViewport).toHaveBeenNthCalledWith(1, 0, 0, 100, 80, 0, 1);
    expect(pass.setViewport).toHaveBeenNthCalledWith(2, 0, 0, 64, 80, 0, 1);
    expect(pass.setScissorRect).toHaveBeenCalledTimes(1);
    expect(pass.setScissorRect).toHaveBeenCalledWith(0, 0, 100, 80);
    expect(pass.setBlendConstant).toHaveBeenCalledTimes(2);
    expect(pass.setStencilReference).toHaveBeenCalledTimes(2);

    device._resetRenderPassState();
    device._applyDynamicState(pass);

    expect(pass.setViewport).toHaveBeenCalledTimes(3);
    expect(pass.setScissorRect).toHaveBeenCalledTimes(2);
    expect(pass.setBlendConstant).toHaveBeenCalledTimes(3);
    expect(pass.setStencilReference).toHaveBeenCalledTimes(3);
  });
});
