import { IPlatformShaderProgram } from "./IPlatformShaderProgram";

export interface IPlatformPrimitive {
  draw(shaderProgram: IPlatformShaderProgram, subPrimitive: any): void;
  /**
   * Draw with arguments read from a platform indirect buffer.
   * @param shaderProgram - Platform shader program used by the draw.
   * @param subPrimitive - Backend-neutral sub-primitive draw range.
   * @param indirectBuffer - Platform buffer containing indirect arguments.
   * @param indirectOffset - Byte offset of the selected argument record.
   * @param vertexBufferBindings - Optional backend-neutral vertex-buffer replacements.
   */
  drawIndirect(
    shaderProgram: IPlatformShaderProgram,
    subPrimitive: any,
    indirectBuffer: unknown,
    indirectOffset: number,
    vertexBufferBindings?: readonly unknown[]
  ): void;
  destroy(): void;
}
