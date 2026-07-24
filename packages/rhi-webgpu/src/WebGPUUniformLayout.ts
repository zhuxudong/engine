import type { IShaderReflection, IShaderStructReflection, IShaderUniformReflection } from "@galacean/engine-design";

type ScalarKind = "f32" | "i32" | "u32" | "bool";

type NativeLayout = {
  align: number;
  size: number;
  scalar: ScalarKind;
  columns: number;
  rows: number;
};

/**
 * One resolved field in the WebGPU uniform-buffer layout.
 * @internal
 */
export interface WebGPUUniformFieldLayout {
  readonly name: string;
  readonly propertyName: string;
  readonly type: string;
  readonly offset: number;
  readonly size: number;
  readonly arrayLength: number;
  readonly arrayStride: number;
  readonly native?: NativeLayout;
  readonly members?: readonly WebGPUUniformFieldLayout[];
}

/**
 * Resolved WGSL uniform-buffer layout.
 * @internal
 */
export class WebGPUUniformLayout {
  /** Uniform-buffer byte length, rounded to the WGSL struct alignment. */
  readonly byteLength: number;
  /** Top-level fields in shader declaration order. */
  readonly fields: readonly WebGPUUniformFieldLayout[];

  private readonly _structs = new Map<string, IShaderStructReflection>();

  constructor(reflection: IShaderReflection) {
    for (const struct of reflection.structs) {
      this._structs.set(struct.name, struct);
    }
    const result = this._layoutMembers(reflection.uniforms, "", 0, true);
    this.fields = result.fields;
    this.byteLength = result.fields.length > 0 ? WebGPUUniformLayout._roundUp(16, result.end) : 0;
  }

  private _layoutMembers(
    members: readonly IShaderUniformReflection[],
    propertyPrefix: string,
    baseOffset: number,
    uniformAddressSpace: boolean
  ): { fields: WebGPUUniformFieldLayout[]; align: number; end: number } {
    const fields: WebGPUUniformFieldLayout[] = [];
    let offset = baseOffset;
    let structAlign = 1;

    for (const member of members) {
      const arrayLength = member.arrayLength ? Number(member.arrayLength) : 0;
      const typeLayout = this._typeLayout(member.type, uniformAddressSpace);
      const requiredAlign =
        uniformAddressSpace && (arrayLength > 0 || typeLayout.members)
          ? WebGPUUniformLayout._roundUp(16, typeLayout.align)
          : typeLayout.align;
      offset = WebGPUUniformLayout._roundUp(requiredAlign, offset);
      structAlign = Math.max(structAlign, typeLayout.align);

      const propertyName = propertyPrefix ? `${propertyPrefix}.${member.name}` : member.name;
      let size = typeLayout.size;
      let arrayStride = 0;
      let nestedMembers = typeLayout.members;
      if (arrayLength > 0) {
        arrayStride = WebGPUUniformLayout._roundUp(
          uniformAddressSpace ? Math.max(16, typeLayout.align) : typeLayout.align,
          typeLayout.size
        );
        size = arrayStride * arrayLength;
        if (nestedMembers) {
          nestedMembers = nestedMembers.map((field) => ({
            ...field,
            offset: field.offset + offset,
            propertyName: `${propertyName}.${field.name}`
          }));
        }
      } else if (nestedMembers) {
        nestedMembers = nestedMembers.map((field) => ({
          ...field,
          offset: field.offset + offset,
          propertyName: `${propertyName}.${field.name}`
        }));
      }

      fields.push({
        name: member.name,
        propertyName,
        type: member.type,
        offset,
        size,
        arrayLength,
        arrayStride,
        native: typeLayout.native,
        members: nestedMembers
      });
      offset += uniformAddressSpace && typeLayout.members ? WebGPUUniformLayout._roundUp(16, size) : size;
    }

    return {
      fields,
      align: structAlign,
      end: WebGPUUniformLayout._roundUp(structAlign, offset)
    };
  }

  private _typeLayout(
    type: string,
    uniformAddressSpace: boolean
  ): {
    align: number;
    size: number;
    native?: NativeLayout;
    members?: WebGPUUniformFieldLayout[];
  } {
    const native = WebGPUUniformLayout._nativeLayout(type);
    if (native) {
      return { align: native.align, size: native.size, native };
    }

    const struct = this._structs.get(type);
    if (!struct) {
      throw new Error(`WGSL uniform type "${type}" has no reflected layout.`);
    }
    const result = this._layoutMembers(struct.members, "", 0, uniformAddressSpace);
    return {
      align: result.align,
      size: result.end,
      members: result.fields
    };
  }

  private static _nativeLayout(type: string): NativeLayout | undefined {
    const scalar = /^(bool|i32|u32|f32)$/.exec(type);
    if (scalar) {
      return {
        align: 4,
        size: 4,
        scalar: scalar[1] as ScalarKind,
        columns: 1,
        rows: 1
      };
    }

    const vector = /^vec([234])<(bool|i32|u32|f32)>$/.exec(type);
    if (vector) {
      const rows = Number(vector[1]);
      return {
        align: rows === 2 ? 8 : 16,
        size: rows * 4,
        scalar: vector[2] as ScalarKind,
        columns: 1,
        rows
      };
    }

    const matrix = /^mat([234])x([234])<f32>$/.exec(type);
    if (matrix) {
      const columns = Number(matrix[1]);
      const rows = Number(matrix[2]);
      const columnAlign = rows === 2 ? 8 : 16;
      const columnStride = WebGPUUniformLayout._roundUp(columnAlign, rows * 4);
      return {
        align: columnAlign,
        size: columns * columnStride,
        scalar: "f32",
        columns,
        rows
      };
    }

    return undefined;
  }

  private static _roundUp(alignment: number, value: number): number {
    return Math.ceil(value / alignment) * alignment;
  }
}
