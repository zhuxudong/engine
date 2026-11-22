import { SetDataOptions } from "../graphic";

export interface IPlatformBuffer {
  bind(): void;

  setData(
    byteLength: number,
    data: ArrayBuffer | ArrayBufferView,
    bufferByteOffset?: number,
    dataOffset?: number,
    dataLength?: number,
    options?: SetDataOptions
  ): void;

  /** Append the active instance records and return an aligned offset for the shader's full declared block. */
  writeInstanceData?(data: Float32Array, activeWords: number, bindingSize: number): number;

  /** Begin a new cycle in a private sequential uniform arena. Its owner invalidates
   * every prior range and overwrites each new range before it can be bound. */
  restartUniformArena?(): void;

  readonly supportsSynchronousReadback?: boolean;
  /** Changes when a GPU shader writes the buffer without supplying CPU data. */
  readonly shaderWriteRevision?: number;

  getData(data: ArrayBufferView, bufferByteOffset?: number, dataOffset?: number, dataLength?: number): void;

  /** Native readback for asynchronous devices. */
  getDataAsync?(
    data: ArrayBufferView,
    bufferByteOffset?: number,
    dataOffset?: number,
    dataLength?: number
  ): Promise<void>;

  copyFromBuffer(srcBuffer: IPlatformBuffer, srcByteOffset: number, dstByteOffset: number, byteLength: number): void;

  destroy(): void;
}
