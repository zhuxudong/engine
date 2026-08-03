import type { GraphicsBackend } from "./GraphicsBackend";
import type { IShaderReflection } from "../shader-compiler";
import type { IPlatformComputeProgram } from "./IPlatformComputeProgram";

/**
 * Origin used by render-target texture coordinates.
 */
export type RenderTargetOrigin = "lower-left" | "upper-left";

/**
 * Backend-neutral compute limits.
 */
export interface ComputeCapabilities {
  /** Whether compute dispatch is available. */
  readonly supported: boolean;
  /** Maximum dispatch count along one dimension. */
  readonly maxWorkgroupsPerDimension: number;
  /** Maximum X dimension of a compute workgroup. */
  readonly maxWorkgroupSizeX: number;
  /** Maximum Y dimension of a compute workgroup. */
  readonly maxWorkgroupSizeY: number;
  /** Maximum Z dimension of a compute workgroup. */
  readonly maxWorkgroupSizeZ: number;
  /** Maximum invocations in one compute workgroup. */
  readonly maxInvocationsPerWorkgroup: number;
  /** Maximum bytes in one storage-buffer binding. */
  readonly maxStorageBufferBindingSize: number;
  /** Maximum storage buffers visible to one shader stage. */
  readonly maxStorageBuffersPerStage: number;
  /** Mobile-oriented default X workgroup size chosen within device limits. */
  readonly recommendedWorkgroupSizeX: number;
}

/**
 * Backend-neutral shader arithmetic capabilities.
 */
export interface ShaderCapabilities {
  /** Whether shaders can use native 16-bit floating-point arithmetic. */
  readonly float16: boolean;
}

/**
 * Hardware graphics API renderer.
 */
export interface IHardwareRenderer {
  /** Graphics backend implemented by this renderer. */
  readonly backend: GraphicsBackend;
  /** Origin used when sampling a texture written by a render pass. */
  readonly renderTargetOrigin: RenderTargetOrigin;
  /** Maximum uniform-buffer binding size in bytes. */
  readonly maxUniformBlockSize: number;
  /** Compute support and device limits. */
  readonly computeCapabilities: ComputeCapabilities;
  /** Shader arithmetic features enabled on the active device. */
  readonly shaderCapabilities: ShaderCapabilities;

  /**
   * Create a backend compute program.
   * @param computeSource - Backend compute source.
   * @param reflection - Resolved ShaderLab resource reflection.
   * @returns Platform compute program.
   */
  createPlatformComputeProgram(computeSource: string, reflection: IShaderReflection): IPlatformComputeProgram;

  // todo: implements
  [key: string]: any;
}
