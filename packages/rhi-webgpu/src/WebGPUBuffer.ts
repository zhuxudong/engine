import { BufferBindFlag, BufferUsage, IPlatformBuffer, SetDataOptions } from "@galacean/engine-core";
import type { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";

export class WebGPUBuffer implements IPlatformBuffer {
  readonly supportsSynchronousReadback = false;
  readonly byteLength: number;
  _contentVersion = 0;
  _gpuBuffer: GPUBuffer;
  private readonly _allocationSize: number;
  private readonly _usage: GPUBufferUsageFlags;
  private _serial = -1;
  private _usedStart = 0;
  private _usedEnd = 0;
  private _expandedIndices?: GPUBuffer;
  private _indicesDirty = true;

  constructor(private readonly _device: WebGPUGraphicDevice, type: BufferBindFlag, size: number, usage: BufferUsage, data?: ArrayBuffer | ArrayBufferView) {
    this.byteLength = size;
    this._allocationSize = Math.max(4, Math.ceil(size / 4) * 4);
    const binding = type === BufferBindFlag.ConstantBuffer ? GPUBufferUsage.UNIFORM
      : type === BufferBindFlag.IndexBuffer ? GPUBufferUsage.INDEX
      : GPUBufferUsage.VERTEX | GPUBufferUsage.STORAGE;
    this._usage = binding | GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST;
    this._gpuBuffer = this._allocate();
    if (data) this.setData(size, data);
  }

  bind(): void {}

  _markUsed(offset = 0, size = this.byteLength): void {
    const serial = this._device.submissionSerial;
    if (this._serial !== serial) {
      this._serial = serial;
      this._usedStart = offset;
      this._usedEnd = offset + size;
    } else {
      this._usedStart = Math.min(this._usedStart, offset);
      this._usedEnd = Math.max(this._usedEnd, offset + size);
    }
  }

  setData(_byteLength: number, data: ArrayBuffer | ArrayBufferView, offset = 0, dataOffset = 0, dataLength?: number, options = SetDataOptions.None): void {
    const source = WebGPUBuffer._getSourceRange(data, dataOffset, dataLength);
    const end = offset + source.length;
    if (offset < 0 || end > this.byteLength) throw new RangeError("WebGPU buffer write exceeds allocation.");
    if (!source.length) return;
    this._contentVersion++;
    this._indicesDirty = true;
    const aligned = Math.floor(offset / 4) * 4;
    const length = Math.ceil(end / 4) * 4 - aligned;
    if (this._serial === this._device.submissionSerial && this._usedStart < aligned + length && aligned < this._usedEnd) {
      if (options === SetDataOptions.Discard || (offset === 0 && end === this.byteLength)) {
        this._device._retireBuffer(this._gpuBuffer);
        this._gpuBuffer = this._allocate();
        this._serial = -1;
      } else {
        this._device.flush();
      }
    }
    if (aligned === offset && length === source.length) {
      this._device.device.queue.writeBuffer(this._gpuBuffer,offset,source);
    } else if (aligned === offset && end === this.byteLength) {
      const padded = new Uint8Array(length);
      padded.set(source);
      this._device.device.queue.writeBuffer(this._gpuBuffer,offset,padded);
    } else {
      const staging = this._device.device.createBuffer({size:Math.ceil(source.length/4)*4,usage:GPUBufferUsage.STORAGE,mappedAtCreation:true});
      new Uint8Array(staging.getMappedRange()).set(source);
      staging.unmap();
      this._device._copyBytes(staging,this._gpuBuffer,0,offset,source.length);
      this._device._retireBuffer(staging);
      this._markUsed(aligned,length);
    }
  }

  getData(): never { throw new Error("Use getDataAsync() for WebGPU buffer readback."); }

  async getDataAsync(data: ArrayBufferView, offset = 0, dataOffset = 0, dataLength?: number): Promise<void> {
    const destination = WebGPUBuffer._getSourceRange(data, dataOffset, dataLength);
    if (offset < 0 || offset + destination.length > this.byteLength) throw new RangeError("WebGPU buffer read exceeds allocation.");
    if (!destination.length) return;
    const start = Math.floor(offset / 4) * 4;
    const size = Math.ceil((offset + destination.length - start) / 4) * 4;
    const staging = this._device.device.createBuffer({size,usage:GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ});
    try {
      this._device._getCommandEncoder().copyBufferToBuffer(this._gpuBuffer, start, staging, 0, size);
      this._device.flush();
      await staging.mapAsync(GPUMapMode.READ);
      destination.set(new Uint8Array(staging.getMappedRange(), offset-start, destination.length));
    } finally { staging.destroy(); }
  }

  copyFromBuffer(source: IPlatformBuffer, sourceOffset: number, offset: number, size: number): void {
    const src = source as WebGPUBuffer;
    if (sourceOffset < 0 || offset < 0 || size < 0 || sourceOffset+size>src.byteLength || offset+size>this.byteLength) throw new RangeError("WebGPU buffer copy exceeds allocation.");
    if (!size) return;
    this._contentVersion++;
    this._indicesDirty = true;
    if ((sourceOffset | offset | size) & 3 || src === this) {
      let input = src._gpuBuffer, start = sourceOffset;
      if (src === this) {
        const aligned = Math.floor(sourceOffset/4)*4, length = Math.ceil((sourceOffset-aligned+size)/4)*4;
        input = this._device.device.createBuffer({size:length,usage:GPUBufferUsage.COPY_DST | GPUBufferUsage.STORAGE});
        this._device._getCommandEncoder().copyBufferToBuffer(src._gpuBuffer,aligned,input,0,length);
        start -= aligned;
        this._device._retireBuffer(input);
      }
      this._device._copyBytes(input,this._gpuBuffer,start,offset,size);
    } else {
      this._device._getCommandEncoder().copyBufferToBuffer(src._gpuBuffer,sourceOffset,this._gpuBuffer,offset,size);
    }
    src._markUsed(sourceOffset,size);
    this._markUsed(offset,size);
  }

  /** Expand external UInt8 indices on the GPU. Only index buffers actually drawn as UInt8 allocate this view. */
  _getUInt16Indices(): GPUBuffer {
    if (!this._indicesDirty) return this._expandedIndices;
    this._expandedIndices ??= this._device.device.createBuffer({size:this._allocationSize*2,usage:GPUBufferUsage.INDEX|GPUBufferUsage.STORAGE});
    this._device._expandIndices(this._gpuBuffer,this._expandedIndices,this._allocationSize/4);
    this._markUsed();
    this._indicesDirty = false;
    return this._expandedIndices;
  }

  destroy(): void {
    this._device._retireBuffer(this._gpuBuffer);
    if (this._expandedIndices) this._device._retireBuffer(this._expandedIndices);
  }

  private _allocate(): GPUBuffer {
    return this._device.device.createBuffer({size:this._allocationSize, usage:this._usage});
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
