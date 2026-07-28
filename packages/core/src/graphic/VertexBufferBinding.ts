import { Buffer } from "./Buffer";

/**
 * Vertex buffer binding.
 */
export class VertexBufferBinding {
  /** @internal */
  _buffer: Buffer;
  /** @internal */
  _stride: number;
  /** @internal */
  _offset: number;

  /**
   * Vertex buffer.
   */
  get buffer(): Buffer {
    return this._buffer;
  }

  /**
   * Vertex buffer stride.
   */
  get stride(): number {
    return this._stride;
  }

  /**
   * Byte offset of the first vertex record in the buffer.
   */
  get offset(): number {
    return this._offset;
  }

  /**
   * Create vertex buffer.
   * @param buffer - Vertex buffer
   * @param stride - Vertex buffer stride
   * @param offset - Byte offset of the first vertex record
   */
  constructor(buffer: Buffer, stride: number, offset: number = 0) {
    this._buffer = buffer;
    this._stride = stride;
    this._offset = offset;
  }
}
