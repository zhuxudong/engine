import { IRenderStates } from "./IRenderStates";
import { IStatement } from "./IStatement";

export interface IShaderPassSource {
  name: string;
  pendingContents: IStatement[];
  isUsePass: boolean;
  tags?: Record<string, number | string | boolean>;
  renderStates: IRenderStates;
  /** Shader source code. */
  contents: string;
  /** Vertex-stage entry point for a render pass. */
  vertexEntry?: string;
  /** Fragment-stage entry point for a render pass. */
  fragmentEntry?: string;
  /** Compute-stage entry point for a compute pass. */
  computeEntry?: string;
  /** Compile-time workgroup dimensions. */
  computeWorkgroupSize?: readonly [string, string, string];
}
