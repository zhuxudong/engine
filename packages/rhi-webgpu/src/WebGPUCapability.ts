import { GLCapabilityType } from "@galacean/engine-core";

/**
 * WebGPU limits and optional features exposed through the engine capability facade.
 */
export class WebGPUCapability {
  /** Maximum 2D texture dimension. */
  readonly maxTextureSize: number;
  /** Maximum number of color attachments. */
  readonly maxDrawBuffers: number;
  /** Maximum supported sample count used by the current WebGPU backend. */
  readonly maxAntiAliasing: number = 4;
  /** Maximum anisotropy currently exposed by the WebGPU sampler API. */
  readonly maxAnisoLevel: number = 16;
  /** WebGPU fragment shaders support 32-bit floating-point arithmetic. */
  readonly isFragmentHighPrecision: boolean = true;
  /** Whether float textures can store blend-shape data. */
  readonly canUseFloatTextureBlendShape: boolean = true;
  /** Whether the device can use the texture-based joint path. */
  readonly canIUseMoreJoints: boolean = true;

  private readonly _features: GPUSupportedFeatures;

  /**
   * Create the capability facade.
   * @param device - Initialized WebGPU device.
   */
  constructor(device: GPUDevice) {
    this._features = device.features;
    this.maxTextureSize = device.limits.maxTextureDimension2D;
    this.maxDrawBuffers = device.limits.maxColorAttachments;
  }

  /**
   * Query a legacy capability by its semantic equivalent in WebGPU.
   * @param capability - Capability to query.
   * @returns Whether WebGPU provides the requested capability.
   */
  canIUse(capability: GLCapabilityType): boolean {
    switch (capability) {
      case GLCapabilityType.astc:
        return this._features.has("texture-compression-astc");
      case GLCapabilityType.etc:
      case GLCapabilityType.etc1:
        return this._features.has("texture-compression-etc2");
      case GLCapabilityType.s3tc:
      case GLCapabilityType.s3tc_srgb:
      case GLCapabilityType.bptc:
        return this._features.has("texture-compression-bc");
      case GLCapabilityType.pvrtc:
        return false;
      case GLCapabilityType.textureFilterAnisotropic:
        return false;
      default:
        return true;
    }
  }

  /**
   * Query a backend-native compressed texture format.
   * @param _format - Backend-native format identifier.
   * @returns `false`; WebGPU callers use named device features instead.
   */
  canIUseCompressedTextureInternalFormat(_format: number): boolean {
    return false;
  }
}
