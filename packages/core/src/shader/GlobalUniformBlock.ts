import type { IShaderUniformBlock, IShaderUniformBlockMember } from "@galacean/engine-design";
import type { Color, Matrix, Vector4 } from "@galacean/engine-math";
import type { Engine } from "../Engine";
import { Buffer } from "../graphic/Buffer";
import { BufferBindFlag } from "../graphic/enums/BufferBindFlag";
import { BufferUsage } from "../graphic/enums/BufferUsage";
import { SetDataOptions } from "../graphic/enums/SetDataOptions";
import type { ShaderData, ShaderPropertyValueType } from "./ShaderData";
import { ShaderProperty } from "./ShaderProperty";

/** Engine-owned, reference-counted storage for one compiler-defined std140 layout. */
export class GlobalUniformBlock {
  static acquire(engine: Engine, layout: IShaderUniformBlock, binding: number): GlobalUniformBlock {
    const cache = (engine._globalUniformBlocks ??= new Map());
    // Constructed at program link, never during drawing. Different shaders may declare
    // different layouts with the same block name, including the same total byte length.
    const key = JSON.stringify([
      layout.name,
      layout.byteLength,
      ...layout.members.map((m) => [m.name, m.type, m.offset, m.arrayLength, m.arrayStride, m.matrixStride])
    ]);
    let block = cache.get(key);
    if (!block) {
      block = new GlobalUniformBlock(engine, layout, binding, key);
      cache.set(key, block);
    }
    block._references++;
    return block;
  }

  private _references = 0;
  private readonly _fields: UniformBlockField[];
  private readonly _staging: Uint32Array;
  private readonly _previous: Uint32Array;
  private readonly _stride: number;
  private readonly _buffer: Buffer;
  private _offset = -1;

  private constructor(
    private readonly _engine: Engine,
    layout: IShaderUniformBlock,
    private readonly _binding: number,
    private readonly _key: string
  ) {
    const rhi = _engine._hardwareRenderer;
    const size = layout.byteLength;
    if (size <= 0 || size % 16 !== 0 || size > rhi.maxUniformBlockSize) {
      throw new Error(`Uniform block ${layout.name} has unsupported byte length ${size}.`);
    }
    const data = new ArrayBuffer(size);
    const floats = new Float32Array(data);
    const integers = new Int32Array(data);
    this._staging = new Uint32Array(data);
    this._previous = new Uint32Array(size / 4);
    this._fields = layout.members.map((member) => new UniformBlockField(member, floats, integers));
    const alignment = rhi.uniformBufferOffsetAlignment;
    this._stride = Math.ceil(size / alignment) * alignment;
    const slots = Math.max(2, Math.floor(16384 / this._stride));
    this._buffer = new Buffer(_engine, BufferBindFlag.ConstantBuffer, this._stride * slots, BufferUsage.Dynamic);
    this._buffer.isGCIgnored = true;
  }

  bind(data: ShaderData): void {
    const fields = this._fields;
    const values = data._propertyValueMap;
    for (let i = 0; i < fields.length; ++i) {
      const field = fields[i];
      field.write(values[field.propertyId]);
    }

    const staging = this._staging;
    const buffer = this._buffer;
    if (this._offset < 0 || buffer.isContentLost || !this._matchesPrevious()) {
      let next = this._offset < 0 ? 0 : this._offset + this._stride;
      let options = SetDataOptions.None;
      if (next >= buffer.byteLength) {
        // Orphan the old backing store before reusing offsets, including when an
        // application calls Camera.render repeatedly without advancing engine time.
        next = 0;
        options = SetDataOptions.Discard;
      }
      buffer.setData(staging, next, 0, staging.length, options);
      this._previous.set(staging);
      this._offset = next;
    }
    this._engine._hardwareRenderer.bindUniformBufferRange(
      this._binding,
      buffer._platformBuffer,
      this._offset,
      staging.byteLength
    );
  }

  release(): void {
    if (--this._references === 0) {
      this._engine._globalUniformBlocks!.delete(this._key);
      this._buffer.destroy();
    }
  }

  private _matchesPrevious(): boolean {
    const staging = this._staging;
    const previous = this._previous;
    for (let i = 0; i < staging.length; ++i) {
      if (staging[i] !== previous[i]) return false;
    }
    return true;
  }
}

/** Caches word offsets and ShaderData property IDs at link time. */
class UniformBlockField {
  private static readonly _components = [0, 0, 0, 0];
  readonly propertyId: number;
  private readonly _view: Float32Array | Int32Array;
  private readonly _offset: number;
  private readonly _arrayCount: number;
  private readonly _arrayStride: number;
  private readonly _columns: number;
  private readonly _rows: number;
  private readonly _matrixStride: number;
  private readonly _contiguousLength: number;

  constructor(member: IShaderUniformBlockMember, floats: Float32Array, integers: Int32Array) {
    const { type } = member;
    const matrix = /^mat([234])(?:x([234]))?$/.exec(type);
    const vector = /^[iub]?vec([234])$/.exec(type);
    if (!matrix && !vector && !/^(float|int|uint|bool)$/.test(type)) {
      throw new Error(`Unsupported uniform block member type ${type}.`);
    }
    this.propertyId = ShaderProperty.getByName(member.name)._uniqueId;
    this._view = /^[iub]/.test(type) ? integers : floats;
    this._offset = member.offset / 4;
    this._arrayCount = member.arrayLength || 1;
    this._arrayStride = member.arrayStride / 4;
    this._matrixStride = member.matrixStride / 4;
    this._columns = matrix ? Number(matrix[1]) : 1;
    this._rows = matrix ? Number(matrix[2] || matrix[1]) : vector ? Number(vector[1]) : 1;
    const components = this._columns * this._rows;
    this._contiguousLength =
      (!matrix || this._matrixStride === this._rows) && (!member.arrayLength || this._arrayStride === components)
        ? components * this._arrayCount
        : 0;
  }

  write(value: ShaderPropertyValueType): void {
    if (typeof value === "number") {
      this._writeVector(value, 0, 0, 0);
    } else if (value && "x" in value) {
      const v = value as Vector4;
      this._writeVector(v.x, v.y, v.z ?? 0, v.w ?? 0);
    } else if (value && "r" in value) {
      const color = value as Color;
      this._writeVector(color.r, color.g, color.b, color.a);
    } else {
      // Matrix.elements and ShaderData arrays contain tightly packed column-major values.
      const source =
        value && "elements" in value ? (value as Matrix).elements : ArrayBuffer.isView(value) ? value : null;
      this._writeArray(source);
    }
  }

  private _writeVector(x: number, y: number, z: number, w: number): void {
    if (this._arrayStride === 0 && this._columns === 1) {
      const view = this._view;
      const offset = this._offset;
      view[offset] = x;
      if (this._rows > 1) view[offset + 1] = y;
      if (this._rows > 2) view[offset + 2] = z;
      if (this._rows > 3) view[offset + 3] = w;
      return;
    }
    const components = UniformBlockField._components;
    components[0] = x;
    components[1] = y;
    components[2] = z;
    components[3] = w;
    this._writeArray(components);
  }

  private _writeArray(source: ArrayLike<number> | null): void {
    const view = this._view;
    const offset = this._offset;
    if (source && source.length === this._contiguousLength && source.length > 0) {
      view.set(source, offset);
      return;
    }
    let index = 0;
    for (let element = 0; element < this._arrayCount; ++element) {
      const base = offset + element * this._arrayStride;
      for (let col = 0; col < this._columns; ++col) {
        const column = base + col * this._matrixStride;
        for (let row = 0; row < this._rows; ++row) {
          view[column + row] = source?.[index++] ?? 0;
        }
      }
    }
  }
}
