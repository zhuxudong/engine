import { BufferBindFlag, BufferUsage, IPlatformBuffer, SetDataOptions } from "@galacean/engine-core";
import { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";

/**
 * WebGPU buffer resource.
 * @internal
 */
export class WebGPUBuffer implements IPlatformBuffer {
  private static _counter = 0;

  /** @internal */
  readonly _gpuBuffer: GPUBuffer;
  /** @internal */
  readonly _bindingId = WebGPUBuffer._counter++;

  private readonly _device: WebGPUGraphicDevice;
  private readonly _bindingFlags: BufferBindFlag;
  private readonly _byteLength: number;
  private readonly _shadowData: Uint8Array;
  private _lastUploadEnd = 0;

  constructor(
    device: WebGPUGraphicDevice,
    type: BufferBindFlag,
    byteLength: number,
    _bufferUsage: BufferUsage,
    data?: ArrayBuffer | ArrayBufferView
  ) {
    this._device = device;
    this._bindingFlags = type;
    this._byteLength = byteLength;
    const size = Math.max(4, WebGPUBuffer._alignToFour(byteLength));
    this._shadowData = new Uint8Array(size);
    this._gpuBuffer = device.device.createBuffer({
      label: WebGPUBuffer._getLabel(type),
      size,
      usage: WebGPUBuffer._getUsage(type)
    });
    if (data) {
      this.setData(byteLength, data);
    }
  }

  bind(): void {}

  setData(
    _byteLength: number,
    data: ArrayBuffer | ArrayBufferView,
    bufferByteOffset: number = 0,
    dataOffset: number = 0,
    dataLength?: number,
    _options: SetDataOptions = SetDataOptions.None
  ): void {
    const source = WebGPUBuffer._getSourceRange(data, dataOffset, dataLength);
    const sourceEnd = bufferByteOffset + source.byteLength;
    if (bufferByteOffset < 0 || sourceEnd > this._shadowData.byteLength) {
      throw new RangeError(
        `Buffer upload range [${bufferByteOffset}, ${sourceEnd}) exceeds ${this._shadowData.byteLength} bytes.`
      );
    }

    this._shadowData.set(source, bufferByteOffset);
    this._lastUploadEnd = Math.max(this._lastUploadEnd, sourceEnd);
    const uploadStart = bufferByteOffset & ~3;
    const uploadEnd = WebGPUBuffer._alignToFour(sourceEnd);
    this._device.device.queue.writeBuffer(
      this._gpuBuffer,
      uploadStart,
      this._shadowData.buffer,
      uploadStart,
      uploadEnd - uploadStart
    );
  }

  getData(): void {
    throw new Error("Synchronous buffer readback is not supported by the WebGPU backend.");
  }

  copyFromBuffer(srcBuffer: IPlatformBuffer, srcByteOffset: number, dstByteOffset: number, byteLength: number): void {
    const webGPUSource = srcBuffer as WebGPUBuffer;
    const sourceEnd = srcByteOffset + byteLength;
    const destinationEnd = dstByteOffset + byteLength;
    if (
      srcByteOffset < 0 ||
      dstByteOffset < 0 ||
      sourceEnd > webGPUSource._shadowData.byteLength ||
      destinationEnd > this._shadowData.byteLength
    ) {
      throw new RangeError("Buffer copy range exceeds the source or destination buffer.");
    }

    this._shadowData.set(webGPUSource._shadowData.subarray(srcByteOffset, sourceEnd), dstByteOffset);
    this._lastUploadEnd = Math.max(this._lastUploadEnd, destinationEnd);
    if ((srcByteOffset | dstByteOffset | byteLength) & 3) {
      const uploadStart = dstByteOffset & ~3;
      const uploadEnd = WebGPUBuffer._alignToFour(destinationEnd);
      this._device.device.queue.writeBuffer(
        this._gpuBuffer,
        uploadStart,
        this._shadowData.buffer,
        uploadStart,
        uploadEnd - uploadStart
      );
      return;
    }

    const encoder = this._device.device.createCommandEncoder({ label: "Buffer copy" });
    encoder.copyBufferToBuffer(webGPUSource._gpuBuffer, srcByteOffset, this._gpuBuffer, dstByteOffset, byteLength);
    this._device.device.queue.submit([encoder.finish()]);
  }

  destroy(): void {
    this._gpuBuffer.destroy();
  }

  /** @internal */
  _getUploadedData(): Uint8Array {
    return this._shadowData.subarray(0, this._lastUploadEnd);
  }

  /** @internal */
  _validateIndirectDraw(indexed: boolean, offset: number): void {
    if (!(this._bindingFlags & BufferBindFlag.IndirectBuffer)) {
      throw new Error("Indirect draw requires a buffer created with BufferBindFlag.IndirectBuffer.");
    }
    if (!Number.isInteger(offset) || offset < 0 || (offset & 3) !== 0) {
      throw new RangeError(`Indirect draw offset ${offset} must be a non-negative multiple of 4.`);
    }
    const argumentByteLength = indexed ? 20 : 16;
    if (offset + argumentByteLength > this._byteLength) {
      throw new RangeError(
        `Indirect draw arguments [${offset}, ${offset + argumentByteLength}) exceed ${this._byteLength} bytes.`
      );
    }
  }

  private static _getUsage(type: BufferBindFlag): GPUBufferUsageFlags {
    const copyUsage = GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC;
    const supportedBindings =
      BufferBindFlag.VertexBuffer |
      BufferBindFlag.IndexBuffer |
      BufferBindFlag.ConstantBuffer |
      BufferBindFlag.StorageBuffer |
      BufferBindFlag.IndirectBuffer;
    if (!Number.isInteger(type) || (type as number) === 0 || (type & ~supportedBindings) !== 0) {
      throw new Error(`Unsupported buffer bindings: ${type}`);
    }
    let usage = copyUsage;
    if (type & BufferBindFlag.VertexBuffer) usage |= GPUBufferUsage.VERTEX;
    if (type & BufferBindFlag.IndexBuffer) usage |= GPUBufferUsage.INDEX;
    if (type & BufferBindFlag.ConstantBuffer) usage |= GPUBufferUsage.UNIFORM;
    if (type & BufferBindFlag.StorageBuffer) usage |= GPUBufferUsage.STORAGE;
    if (type & BufferBindFlag.IndirectBuffer) usage |= GPUBufferUsage.INDIRECT;
    return usage;
  }

  private static _getLabel(type: BufferBindFlag): string {
    const labels: string[] = [];
    if (type & BufferBindFlag.VertexBuffer) labels.push("Vertex");
    if (type & BufferBindFlag.IndexBuffer) labels.push("Index");
    if (type & BufferBindFlag.ConstantBuffer) labels.push("Constant");
    if (type & BufferBindFlag.StorageBuffer) labels.push("Storage");
    if (type & BufferBindFlag.IndirectBuffer) labels.push("Indirect");
    return labels.length > 0 ? `${labels.join("|")} buffer` : "Invalid buffer";
  }

  private static _alignToFour(byteLength: number): number {
    return (byteLength + 3) & ~3;
  }

  private static _getSourceRange(
    data: ArrayBuffer | ArrayBufferView,
    dataOffset: number,
    dataLength?: number
  ): Uint8Array {
    if (data instanceof ArrayBuffer) {
      const length = dataLength ?? data.byteLength - dataOffset;
      return new Uint8Array(data, dataOffset, length);
    }

    const bytesPerElement = (data as { BYTES_PER_ELEMENT?: number }).BYTES_PER_ELEMENT ?? 1;
    const byteOffset = data.byteOffset + dataOffset * bytesPerElement;
    const byteLength =
      dataLength === undefined ? data.byteLength - dataOffset * bytesPerElement : dataLength * bytesPerElement;
    return new Uint8Array(data.buffer, byteOffset, byteLength);
  }
}
