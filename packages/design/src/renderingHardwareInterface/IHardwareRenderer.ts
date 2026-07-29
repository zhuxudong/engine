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
 * Backend-neutral native pass kind reported by GPU timestamp profiling.
 */
export type GPUTimingPassKind = "render" | "compute";

/**
 * Completed GPU timestamp measurement for one native pass.
 */
export interface GPUTimingPassSample {
  /** Stable diagnostic name assigned by the core render pipeline. */
  readonly name: string;
  /** Native pass kind. */
  readonly kind: GPUTimingPassKind;
  /** GPU duration between this pass's beginning and end timestamps, in milliseconds. */
  readonly durationMs: number;
}

/**
 * Completed GPU timestamp measurement for one command submission.
 */
export interface GPUTimingSample {
  /** Monotonic submission identifier assigned by the active backend. */
  readonly submissionId: number;
  /** Number of render and compute passes covered by the measurement. */
  readonly passCount: number;
  /** GPU span from the first pass beginning to the last pass ending, in milliseconds. */
  readonly durationMs: number;
  /** Ordered native render and compute pass measurements. */
  readonly passes: readonly GPUTimingPassSample[];
}

/**
 * Backend-neutral GPU timestamp state.
 */
export interface GPUTiming {
  /** Whether the adapter can expose timestamp queries. */
  readonly supported: boolean;
  /** Whether timestamp collection was enabled when the engine was created. */
  readonly enabled: boolean;
  /** Most recent asynchronously completed measurement. */
  readonly latestSample: GPUTimingSample | null;
  /** Measurements skipped because asynchronous readback capacity was exhausted. */
  readonly droppedSampleCount: number;
  /**
   * Request one timestamp measurement for the next command submission.
   * @returns True when a new sample was queued.
   */
  requestSample(): boolean;
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
  /** Optional GPU timestamp collection state. */
  readonly gpuTiming: GPUTiming;
  /** Whether eligible single-sample depth prepasses are reused by the forward pass. */
  readonly depthPrimingEnabled: boolean;

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
