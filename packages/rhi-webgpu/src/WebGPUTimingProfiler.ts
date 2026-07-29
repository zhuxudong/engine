import type { GPUTiming, GPUTimingSample } from "@galacean/engine-design";

const TIMESTAMP_QUERY_COUNT = 2;
const TIMESTAMP_BYTE_SIZE = 8;
// Three in-flight readbacks cover the browser/GPU pipeline without allowing profiler memory to grow unbounded.
const MAX_PENDING_READBACKS = 3;

interface PendingGPUTimingReadback {
  readonly buffer: GPUBuffer;
  readonly submissionId: number;
  readonly passCount: number;
}

/**
 * Non-blocking timestamp span collector shared by render and compute passes.
 * @internal
 */
export class WebGPUTimingProfiler implements GPUTiming {
  /** @inheritdoc */
  readonly supported: boolean;
  /** @inheritdoc */
  readonly enabled: boolean;

  private readonly _device: GPUDevice;
  private readonly _querySet?: GPUQuerySet;
  private readonly _resolveBuffer?: GPUBuffer;
  private readonly _availableReadbacks: GPUBuffer[] = [];
  private readonly _pendingReadbacks = new Set<GPUBuffer>();
  private _latestSample: GPUTimingSample | null = null;
  private _droppedSampleCount = 0;
  private _allocatedReadbackCount = 0;
  private _passCount = 0;
  private _submissionId = 0;
  private _collectCurrentSubmission = false;
  private _destroyed = false;

  /** @inheritdoc */
  get latestSample(): GPUTimingSample | null {
    return this._latestSample;
  }

  /** @inheritdoc */
  get droppedSampleCount(): number {
    return this._droppedSampleCount;
  }

  /**
   * Create a timestamp collector without making support a device-creation requirement.
   * @param device - Native device used for queries and asynchronous readback.
   * @param supported - Whether the selected adapter advertised timestamp queries.
   * @param requested - Whether the engine initialization requested GPU timing.
   */
  constructor(device: GPUDevice, supported: boolean, requested: boolean) {
    this._device = device;
    this.supported = supported;
    this.enabled = requested && device.features.has("timestamp-query");
    if (!this.enabled) {
      return;
    }

    this._querySet = device.createQuerySet({
      label: "Galacean GPU submission timestamps",
      type: "timestamp",
      count: TIMESTAMP_QUERY_COUNT
    });
    this._resolveBuffer = device.createBuffer({
      label: "Galacean GPU timestamp resolve",
      size: TIMESTAMP_QUERY_COUNT * TIMESTAMP_BYTE_SIZE,
      usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC
    });
  }

  /** @inheritdoc */
  requestSample(): boolean {
    if (!this.enabled || this._destroyed || this._collectCurrentSubmission) {
      return false;
    }
    this._collectCurrentSubmission = true;
    return true;
  }

  /**
   * Add the current submission span to a pass descriptor.
   * @param descriptor - Render or compute descriptor about to begin a native pass.
   */
  addTimestampWrites(descriptor: GPURenderPassDescriptor | GPUComputePassDescriptor): void {
    if (!this.enabled || !this._collectCurrentSubmission) {
      return;
    }
    descriptor.timestampWrites =
      this._passCount++ === 0
        ? {
            querySet: this._querySet!,
            beginningOfPassWriteIndex: 0,
            endOfPassWriteIndex: 1
          }
        : {
            querySet: this._querySet!,
            endOfPassWriteIndex: 1
          };
  }

  /**
   * Resolve the current submission into a non-mapped staging buffer.
   * @param encoder - Command encoder containing every measured pass.
   * @returns Pending readback to start after queue submission, or null when no sample was encoded.
   */
  resolve(encoder: GPUCommandEncoder): PendingGPUTimingReadback | null {
    if (!this.enabled || !this._collectCurrentSubmission) {
      return null;
    }

    if (this._passCount === 0) {
      return null;
    }

    this._collectCurrentSubmission = false;
    const submissionId = ++this._submissionId;
    const passCount = this._passCount;
    this._passCount = 0;
    const readback = this._acquireReadback();
    if (!readback) {
      this._droppedSampleCount++;
      return null;
    }

    encoder.resolveQuerySet(this._querySet!, 0, TIMESTAMP_QUERY_COUNT, this._resolveBuffer!, 0);
    encoder.copyBufferToBuffer(this._resolveBuffer!, 0, readback, 0, TIMESTAMP_QUERY_COUNT * TIMESTAMP_BYTE_SIZE);
    this._pendingReadbacks.add(readback);
    return { buffer: readback, submissionId, passCount };
  }

  /**
   * Start asynchronous CPU readback after the command buffer was submitted.
   * @param pending - Readback returned by {@link resolve}.
   */
  readAfterSubmit(pending: PendingGPUTimingReadback | null): void {
    if (!pending || this._destroyed) {
      return;
    }
    const { buffer, submissionId, passCount } = pending;
    void buffer
      .mapAsync(GPUMapMode.READ)
      .then(() => {
        if (this._destroyed) {
          return;
        }
        const timestamps = new BigUint64Array(buffer.getMappedRange());
        const beginning = timestamps[0];
        const end = timestamps[1];
        if (end > beginning && (!this._latestSample || submissionId > this._latestSample.submissionId)) {
          this._latestSample = Object.freeze({
            submissionId,
            passCount,
            durationMs: Number(end - beginning) * 0.000001
          });
        }
      })
      .catch(() => {
        if (!this._destroyed) {
          this._droppedSampleCount++;
        }
      })
      .finally(() => {
        this._pendingReadbacks.delete(buffer);
        if (buffer.mapState === "mapped") {
          buffer.unmap();
        }
        if (!this._destroyed) {
          this._availableReadbacks.push(buffer);
        }
      });
  }

  /**
   * Destroy timestamp and readback resources.
   */
  destroy(): void {
    if (this._destroyed) {
      return;
    }
    this._destroyed = true;
    this._querySet?.destroy();
    this._resolveBuffer?.destroy();
    for (const buffer of this._availableReadbacks) {
      buffer.destroy();
    }
    this._availableReadbacks.length = 0;
    for (const buffer of this._pendingReadbacks) {
      buffer.destroy();
    }
    this._pendingReadbacks.clear();
  }

  private _acquireReadback(): GPUBuffer | null {
    const available = this._availableReadbacks.pop();
    if (available) {
      return available;
    }
    if (this._allocatedReadbackCount >= MAX_PENDING_READBACKS) {
      return null;
    }
    this._allocatedReadbackCount++;
    return this._device.createBuffer({
      label: `Galacean GPU timestamp readback ${this._allocatedReadbackCount}`,
      size: TIMESTAMP_QUERY_COUNT * TIMESTAMP_BYTE_SIZE,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
  }
}
