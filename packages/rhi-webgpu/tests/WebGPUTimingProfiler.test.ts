import { describe, expect, it, vi } from "vitest";
import { WebGPUTimingProfiler } from "../src/WebGPUTimingProfiler";

Object.defineProperty(globalThis, "GPUBufferUsage", {
  configurable: true,
  value: {
    MAP_READ: 1,
    COPY_SRC: 4,
    COPY_DST: 8,
    QUERY_RESOLVE: 512
  }
});

Object.defineProperty(globalThis, "GPUMapMode", {
  configurable: true,
  value: {
    READ: 1
  }
});

describe("WebGPU timestamp profiling", () => {
  it("stays disabled when timing was not requested or supported", () => {
    const fixture = createDevice(false);
    const profiler = new WebGPUTimingProfiler(fixture.device, false, true);
    const descriptor: GPUComputePassDescriptor = {};

    profiler.addTimestampWrites(descriptor, "compute");

    expect(profiler).toMatchObject({
      supported: false,
      enabled: false,
      latestSample: null,
      droppedSampleCount: 0
    });
    expect(descriptor.timestampWrites).toBeUndefined();
    expect(profiler.requestSample()).toBe(false);
    expect(fixture.createQuerySet).not.toHaveBeenCalled();
  });

  it("measures the span from the first pass beginning to the last pass ending", async () => {
    const fixture = createDevice(true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const first: GPURenderPassDescriptor = { label: "shadow", colorAttachments: [] };
    const second: GPUComputePassDescriptor = { label: "compute" };
    const encoder = createEncoder();

    expect(profiler.requestSample()).toBe(true);
    profiler.addTimestampWrites(first, "render");
    profiler.addTimestampWrites(second, "compute");

    expect(first.timestampWrites).toMatchObject({
      beginningOfPassWriteIndex: 0,
      endOfPassWriteIndex: 1
    });
    expect(second.timestampWrites).toMatchObject({
      beginningOfPassWriteIndex: 2,
      endOfPassWriteIndex: 3
    });
    expect(second.timestampWrites?.querySet).toBe(first.timestampWrites?.querySet);

    const pending = profiler.resolve(encoder.encoder);
    expect(encoder.resolveQuerySet).toHaveBeenCalledWith(first.timestampWrites?.querySet, 0, 4, fixture.buffers[0], 0);
    expect(encoder.copyBufferToBuffer).toHaveBeenCalledWith(fixture.buffers[0], 0, fixture.buffers[1], 0, 32);

    fixture.buffers[1].setTimestamps(1_000_000n, 3_000_000n, 2_000_000n, 7_250_000n);
    profiler.readAfterSubmit(pending);
    await vi.waitFor(() => expect(profiler.latestSample).not.toBeNull());

    expect(profiler.latestSample).toEqual({
      submissionId: 1,
      passCount: 2,
      durationMs: 6.25,
      passes: [
        { name: "shadow", kind: "render", durationMs: 2 },
        { name: "compute", kind: "compute", durationMs: 5.25 }
      ]
    });
    expect(Object.isFrozen(profiler.latestSample)).toBe(true);
    expect(Object.isFrozen(profiler.latestSample?.passes)).toBe(true);
    expect(profiler.latestSample?.passes.every((pass) => Object.isFrozen(pass))).toBe(true);
    expect(fixture.buffers[1].unmap).toHaveBeenCalledOnce();
  });

  it("drops measurements instead of blocking when every staging buffer is pending", () => {
    const fixture = createDevice(true, true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();

    for (let index = 0; index < 4; index++) {
      expect(profiler.requestSample()).toBe(true);
      profiler.addTimestampWrites({} as GPUComputePassDescriptor, "compute");
      profiler.readAfterSubmit(profiler.resolve(encoder.encoder));
    }

    expect(fixture.buffers).toHaveLength(4);
    expect(fixture.buffers.slice(1).every((buffer) => buffer.mapState === "pending")).toBe(true);
    expect(profiler.droppedSampleCount).toBe(1);
    profiler.destroy();
  });

  it("omits timestamp descriptors until another one-shot sample is requested", () => {
    const fixture = createDevice(true, true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();
    const initial: GPUComputePassDescriptor = {};
    expect(profiler.requestSample()).toBe(true);
    profiler.addTimestampWrites(initial, "compute");
    profiler.readAfterSubmit(profiler.resolve(encoder.encoder));

    const idle: GPUComputePassDescriptor = {};
    profiler.addTimestampWrites(idle, "compute");
    expect(idle.timestampWrites).toBeUndefined();
    expect(profiler.resolve(encoder.encoder)).toBeNull();

    expect(profiler.requestSample()).toBe(true);
    expect(profiler.requestSample()).toBe(false);
    const requested: GPUComputePassDescriptor = {};
    profiler.addTimestampWrites(requested, "compute");
    expect(requested.timestampWrites).toBeDefined();
    profiler.readAfterSubmit(profiler.resolve(encoder.encoder));
    profiler.destroy();
  });

  it("keeps a request queued when a submission contains no measured pass", () => {
    const fixture = createDevice(true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();

    expect(profiler.requestSample()).toBe(true);
    expect(profiler.resolve(encoder.encoder)).toBeNull();
    expect(profiler.requestSample()).toBe(false);

    const requested: GPUComputePassDescriptor = {};
    profiler.addTimestampWrites(requested, "compute");
    expect(requested.timestampWrites).toBeDefined();
    profiler.readAfterSubmit(profiler.resolve(encoder.encoder));
    profiler.destroy();
  });

  it("ignores non-positive timestamps and destroys owned resources", async () => {
    const fixture = createDevice(true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();

    expect(profiler.requestSample()).toBe(true);
    profiler.addTimestampWrites({} as GPURenderPassDescriptor, "render");
    const pending = profiler.resolve(encoder.encoder);
    fixture.buffers[1].setTimestamps(5_000n, 5_000n);
    profiler.readAfterSubmit(pending);
    await vi.waitFor(() => expect(fixture.buffers[1].unmap).toHaveBeenCalledOnce());

    expect(profiler.latestSample).toBeNull();
    profiler.destroy();
    expect(fixture.querySet.destroy).toHaveBeenCalledOnce();
    expect(fixture.buffers.every((buffer) => buffer.destroy.mock.calls.length === 1)).toBe(true);
  });

  it("keeps invalid pass durations at zero without widening a valid span", async () => {
    const fixture = createDevice(true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();

    expect(profiler.requestSample()).toBe(true);
    profiler.addTimestampWrites({ label: "invalid" } as GPUComputePassDescriptor, "compute");
    profiler.addTimestampWrites({ label: "valid" } as GPUComputePassDescriptor, "compute");
    const pending = profiler.resolve(encoder.encoder);
    fixture.buffers[1].setTimestamps(9_000_000n, 1_000_000n, 2_000_000n, 5_000_000n);
    profiler.readAfterSubmit(pending);
    await vi.waitFor(() => expect(profiler.latestSample).not.toBeNull());

    expect(profiler.latestSample).toMatchObject({
      durationMs: 3,
      passes: [
        { name: "invalid", durationMs: 0 },
        { name: "valid", durationMs: 3 }
      ]
    });
    profiler.destroy();
  });

  it("drops the whole sample when a submission exceeds the pass capacity", () => {
    const fixture = createDevice(true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();
    const descriptors: GPURenderPassDescriptor[] = [];

    expect(profiler.requestSample()).toBe(true);
    for (let index = 0; index < 65; index++) {
      const descriptor: GPURenderPassDescriptor = { label: `render-${index}`, colorAttachments: [] };
      descriptors.push(descriptor);
      profiler.addTimestampWrites(descriptor, "render");
    }

    expect(descriptors[63].timestampWrites).toMatchObject({
      beginningOfPassWriteIndex: 126,
      endOfPassWriteIndex: 127
    });
    expect(descriptors[64].timestampWrites).toBeUndefined();
    expect(profiler.resolve(encoder.encoder)).toBeNull();
    expect(profiler.droppedSampleCount).toBe(1);
    expect(encoder.resolveQuerySet).not.toHaveBeenCalled();
    expect(profiler.requestSample()).toBe(true);
    profiler.destroy();
  });
});

class FakeGPUBuffer {
  readonly destroy = vi.fn();
  readonly unmap = vi.fn(() => {
    this.mapState = "unmapped";
  });
  mapState: GPUBufferMapState = "unmapped";
  private readonly _data: ArrayBuffer;

  constructor(
    private readonly _keepPending: boolean,
    size: number
  ) {
    this._data = new ArrayBuffer(size);
  }

  setTimestamps(...values: bigint[]): void {
    new BigUint64Array(this._data).set(values);
  }

  mapAsync(): Promise<void> {
    this.mapState = "pending";
    if (this._keepPending) {
      return new Promise(() => undefined);
    }
    return Promise.resolve().then(() => {
      this.mapState = "mapped";
    });
  }

  getMappedRange(): ArrayBuffer {
    return this._data;
  }
}

function createDevice(
  timestampFeature: boolean,
  keepReadbacksPending = false
): {
  readonly device: GPUDevice;
  readonly buffers: FakeGPUBuffer[];
  readonly querySet: { readonly destroy: ReturnType<typeof vi.fn> };
  readonly createQuerySet: ReturnType<typeof vi.fn>;
} {
  const buffers: FakeGPUBuffer[] = [];
  const querySet = { destroy: vi.fn() };
  const createQuerySet = vi.fn(() => querySet);
  const device = {
    features: {
      has: (feature: GPUFeatureName) => feature === "timestamp-query" && timestampFeature
    },
    createQuerySet,
    createBuffer: vi.fn((descriptor: GPUBufferDescriptor) => {
      const buffer = new FakeGPUBuffer(keepReadbacksPending && buffers.length > 0, descriptor.size);
      buffers.push(buffer);
      return buffer;
    })
  } as unknown as GPUDevice;
  return { device, buffers, querySet, createQuerySet };
}

function createEncoder(): {
  readonly encoder: GPUCommandEncoder;
  readonly resolveQuerySet: ReturnType<typeof vi.fn>;
  readonly copyBufferToBuffer: ReturnType<typeof vi.fn>;
} {
  const resolveQuerySet = vi.fn();
  const copyBufferToBuffer = vi.fn();
  return {
    encoder: {
      resolveQuerySet,
      copyBufferToBuffer
    } as unknown as GPUCommandEncoder,
    resolveQuerySet,
    copyBufferToBuffer
  };
}
