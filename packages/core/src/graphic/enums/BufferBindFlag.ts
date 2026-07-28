/**
 * Buffer binding flags.
 */
export enum BufferBindFlag {
  /** Vertex buffer binding flag. */
  VertexBuffer = 1 << 0,
  /** Index buffer binding flag. */
  IndexBuffer = 1 << 1,
  /** Constant/uniform buffer binding flag. */
  ConstantBuffer = 1 << 2,
  /** Read-only or read-write shader storage buffer binding flag (WebGPU only). */
  StorageBuffer = 1 << 3,
  /** Indirect draw or dispatch argument buffer binding flag (WebGPU only). */
  IndirectBuffer = 1 << 4
}
