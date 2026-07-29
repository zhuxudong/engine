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

    profiler.addTimestampWrites(descriptor);

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
    const first: GPURenderPassDescriptor = { colorAttachments: [] };
    const second: GPUComputePassDescriptor = {};
    const encoder = createEncoder();

    expect(profiler.requestSample()).toBe(true);
    profiler.addTimestampWrites(first);
    profiler.addTimestampWrites(second);

    expect(first.timestampWrites).toMatchObject({
      beginningOfPassWriteIndex: 0,
      endOfPassWriteIndex: 1
    });
    expect(second.timestampWrites).toMatchObject({ endOfPassWriteIndex: 1 });
    expect(second.timestampWrites?.beginningOfPassWriteIndex).toBeUndefined();
    expect(second.timestampWrites?.querySet).toBe(first.timestampWrites?.querySet);

    const pending = profiler.resolve(encoder.encoder);
    expect(encoder.resolveQuerySet).toHaveBeenCalledWith(first.timestampWrites?.querySet, 0, 2, fixture.buffers[0], 0);
    expect(encoder.copyBufferToBuffer).toHaveBeenCalledWith(fixture.buffers[0], 0, fixture.buffers[1], 0, 16);

    fixture.buffers[1].setTimestamps(1_000_000n, 7_250_000n);
    profiler.readAfterSubmit(pending);
    await vi.waitFor(() => expect(profiler.latestSample).not.toBeNull());

    expect(profiler.latestSample).toEqual({
      submissionId: 1,
      passCount: 2,
      durationMs: 6.25
    });
    expect(fixture.buffers[1].unmap).toHaveBeenCalledOnce();
  });

  it("drops measurements instead of blocking when every staging buffer is pending", () => {
    const fixture = createDevice(true, true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();

    for (let index = 0; index < 4; index++) {
      expect(profiler.requestSample()).toBe(true);
      profiler.addTimestampWrites({} as GPUComputePassDescriptor);
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
    profiler.addTimestampWrites(initial);
    profiler.readAfterSubmit(profiler.resolve(encoder.encoder));

    const idle: GPUComputePassDescriptor = {};
    profiler.addTimestampWrites(idle);
    expect(idle.timestampWrites).toBeUndefined();
    expect(profiler.resolve(encoder.encoder)).toBeNull();

    expect(profiler.requestSample()).toBe(true);
    expect(profiler.requestSample()).toBe(false);
    const requested: GPUComputePassDescriptor = {};
    profiler.addTimestampWrites(requested);
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
    profiler.addTimestampWrites(requested);
    expect(requested.timestampWrites).toBeDefined();
    profiler.readAfterSubmit(profiler.resolve(encoder.encoder));
    profiler.destroy();
  });

  it("ignores non-positive timestamps and destroys owned resources", async () => {
    const fixture = createDevice(true);
    const profiler = new WebGPUTimingProfiler(fixture.device, true, true);
    const encoder = createEncoder();

    expect(profiler.requestSample()).toBe(true);
    profiler.addTimestampWrites({} as GPURenderPassDescriptor);
    const pending = profiler.resolve(encoder.encoder);
    fixture.buffers[1].setTimestamps(5_000n, 5_000n);
    profiler.readAfterSubmit(pending);
    await vi.waitFor(() => expect(fixture.buffers[1].unmap).toHaveBeenCalledOnce());

    expect(profiler.latestSample).toBeNull();
    profiler.destroy();
    expect(fixture.querySet.destroy).toHaveBeenCalledOnce();
    expect(fixture.buffers.every((buffer) => buffer.destroy.mock.calls.length === 1)).toBe(true);
  });
});

class FakeGPUBuffer {
  readonly destroy = vi.fn();
  readonly unmap = vi.fn(() => {
    this.mapState = "unmapped";
  });
  mapState: GPUBufferMapState = "unmapped";
  private readonly _data = new ArrayBuffer(16);

  constructor(private readonly _keepPending: boolean) {}

  setTimestamps(beginning: bigint, end: bigint): void {
    const timestamps = new BigUint64Array(this._data);
    timestamps[0] = beginning;
    timestamps[1] = end;
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
    createBuffer: vi.fn(() => {
      const buffer = new FakeGPUBuffer(keepReadbacksPending && buffers.length > 0);
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
