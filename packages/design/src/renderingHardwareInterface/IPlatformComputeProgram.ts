/**
 * Backend compute program consumed by the core compute API.
 */
export interface IPlatformComputeProgram {
  /**
   * Bind a platform buffer to a reflected storage binding.
   * @param binding - Reflected bind-group binding index.
   * @param buffer - Backend platform-buffer object.
   */
  setBuffer(binding: number, buffer: unknown): void;

  /**
   * Encode a direct compute dispatch.
   * @param workgroupCountX - Workgroup count on the X axis.
   * @param workgroupCountY - Workgroup count on the Y axis.
   * @param workgroupCountZ - Workgroup count on the Z axis.
   */
  dispatch(workgroupCountX: number, workgroupCountY: number, workgroupCountZ: number): void;

  /** Release backend compute resources. */
  destroy(): void;
}
