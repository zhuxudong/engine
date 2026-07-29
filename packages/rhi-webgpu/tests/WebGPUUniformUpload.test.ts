import { describe, expect, it, vi } from "vitest";
import { WebGPUShaderProgram } from "../src/WebGPUShaderProgram";

Object.defineProperty(globalThis, "GPUBufferUsage", {
  configurable: true,
  value: {
    COPY_DST: 8,
    UNIFORM: 64
  }
});

describe("WebGPU draw-uniform uploads", () => {
  it("uploads one contiguous range for multiple draws", () => {
    const fixture = createProgramFixture(4);

    expect(fixture.program.getBindGroup().dynamicOffset).toBe(0);
    expect(fixture.program.getBindGroup().dynamicOffset).toBe(256);
    expect(fixture.writeBuffer).not.toHaveBeenCalled();

    fixture.program.flushUploads();

    expect(fixture.writeBuffer).toHaveBeenCalledTimes(1);
    expect(fixture.writeBuffer).toHaveBeenCalledWith(
      fixture.initialBuffer,
      0,
      fixture.program.uniformUploadData,
      0,
      272
    );
    expect(fixture.program.uniformUploadView.getFloat32(0, true)).toBe(7);
    expect(fixture.program.uniformUploadView.getFloat32(256, true)).toBe(7);
  });

  it("uploads independently for consecutive submissions", () => {
    const fixture = createProgramFixture(4);

    fixture.program.getBindGroup();
    fixture.program.flushUploads();
    fixture.program.resetFrame();
    fixture.program.propertyValues[1] = 9;
    fixture.program.getBindGroup();
    fixture.program.flushUploads();

    expect(fixture.writeBuffer).toHaveBeenCalledTimes(2);
    expect(fixture.writeBuffer.mock.calls[0][4]).toBe(16);
    expect(fixture.writeBuffer.mock.calls[1][4]).toBe(16);
    expect(fixture.program.uniformUploadView.getFloat32(0, true)).toBe(9);
  });

  it("flushes the old ring before growing and restarts at offset zero", () => {
    const fixture = createProgramFixture(1);

    const first = fixture.program.getBindGroup();
    const second = fixture.program.getBindGroup();

    expect(first.dynamicOffset).toBe(0);
    expect(second.dynamicOffset).toBe(0);
    expect(fixture.writeBuffer).toHaveBeenCalledTimes(1);
    expect(fixture.writeBuffer.mock.calls[0][0]).toBe(fixture.initialBuffer);
    expect(fixture.retireBuffer).toHaveBeenCalledWith(fixture.initialBuffer);

    fixture.program.flushUploads();

    expect(fixture.writeBuffer).toHaveBeenCalledTimes(2);
    expect(fixture.writeBuffer.mock.calls[1][0]).not.toBe(fixture.initialBuffer);
    expect(fixture.writeBuffer.mock.calls[1][4]).toBe(16);
  });

  it("does not upload a program without draws", () => {
    const fixture = createProgramFixture(4);

    fixture.program.flushUploads();

    expect(fixture.writeBuffer).not.toHaveBeenCalled();
  });
});

interface ProgramFixture {
  program: ProgramInternals;
  initialBuffer: GPUBuffer;
  writeBuffer: ReturnType<typeof vi.fn>;
  retireBuffer: ReturnType<typeof vi.fn>;
}

interface ProgramInternals {
  uniformUploadData: ArrayBuffer;
  uniformUploadView: DataView;
  propertyValues: Record<number, unknown>;
  getBindGroup(): { bindGroup: GPUBindGroup; dynamicOffset: number };
  flushUploads(): void;
  resetFrame(): void;
}

function createProgramFixture(capacity: number): ProgramFixture {
  let nextBufferId = 0;
  const writeBuffer = vi.fn();
  const retireBuffer = vi.fn();
  const device = {
    queue: { writeBuffer },
    createBuffer: vi.fn(() => ({ id: nextBufferId++ }) as unknown as GPUBuffer),
    createBindGroup: vi.fn(() => ({}) as GPUBindGroup)
  };
  const graphicDevice = {
    device,
    _retireBuffer: retireBuffer
  };
  const program = Object.create(WebGPUShaderProgram.prototype) as WebGPUShaderProgram & Record<string, unknown>;
  const uniformUploadData = new ArrayBuffer(256 * capacity);
  const propertyValues: Record<number, unknown> = { 1: 7 };
  Object.assign(program, {
    _graphicDevice: graphicDevice,
    _reflection: { resources: [] },
    _uniformLayout: {
      byteLength: 16,
      fields: [
        {
          name: "value",
          propertyName: "value",
          type: "f32",
          offset: 0,
          size: 4,
          arrayLength: 0,
          arrayStride: 0,
          native: {
            align: 4,
            size: 4,
            scalar: "f32",
            columns: 1,
            rows: 1
          }
        }
      ]
    },
    _propertyValues: propertyValues,
    _propertyIds: new Map([["value", 1]]),
    _uniformBuffer: device.createBuffer(),
    _uniformUploadData: uniformUploadData,
    _uniformUploadView: new DataView(uniformUploadData),
    _uniformCapacity: capacity,
    _uniformStride: 256,
    _uniformCursor: 0,
    _uniformUploadEnd: 0,
    _uniformGeneration: 0,
    _instanceCursor: 0,
    _bindGroupLayout: {},
    _bindGroups: new Map()
  });
  const internal = program as unknown as {
    _uniformBuffer: GPUBuffer;
    _uniformUploadData: ArrayBuffer;
    _uniformUploadView: DataView;
    _propertyValues: Record<number, unknown>;
    _getBindGroup(): { bindGroup: GPUBindGroup; dynamicOffset: number };
    _flushUploads(): void;
    _resetFrame(): void;
  };
  const fixtureProgram: ProgramInternals = {
    get uniformUploadData() {
      return internal._uniformUploadData;
    },
    get uniformUploadView() {
      return internal._uniformUploadView;
    },
    propertyValues: internal._propertyValues,
    getBindGroup: () => internal._getBindGroup(),
    flushUploads: () => internal._flushUploads(),
    resetFrame: () => internal._resetFrame()
  };
  return {
    program: fixtureProgram,
    initialBuffer: internal._uniformBuffer,
    writeBuffer,
    retireBuffer
  };
}
