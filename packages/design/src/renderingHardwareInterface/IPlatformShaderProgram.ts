/**
 * Native shader-program operations consumed by the core render pipeline.
 */
export interface IPlatformShaderProgram {
  /** Stable program identifier used by pipeline caches. */
  readonly id: number;
  /** Vertex semantic to shader-location map. */
  readonly attributeLocation: Record<string, GLint>;
  /** Whether native shader modules were created successfully. */
  readonly isValid: boolean;

  /**
   * Merge one engine shader-data group into the values for the next draw.
   * @param propertyValues - Shader property id to value map.
   */
  uploadData(propertyValues: Readonly<Record<number, unknown>>): void;

  /**
   * Bind the program for subsequent draw calls.
   * @returns Whether the bound program changed.
   */
  bind(): boolean;

  /** Release native program resources. */
  destroy(): void;
}
