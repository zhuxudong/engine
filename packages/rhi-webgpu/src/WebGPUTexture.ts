import {
  IPlatformTexture,
  Texture,
  TextureDepthCompareFunction,
  TextureFilterMode,
  TextureFormat,
  TextureWrapMode
} from "@galacean/engine-core";
import { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";

/**
 * Shared WebGPU texture implementation.
 * @internal
 */
export abstract class WebGPUTexture implements IPlatformTexture {
  private static _counter = 0;

  /** @internal */
  readonly _bindingId = WebGPUTexture._counter++;
  /** @internal */
  readonly _gpuTexture: GPUTexture;
  /** @internal */
  readonly _format: GPUTextureFormat;
  /** @internal */
  readonly _viewDimension: GPUTextureViewDimension;

  protected readonly _device: WebGPUGraphicDevice;
  protected readonly _texture: Texture;
  protected readonly _layerCount: number;

  private _wrapModeU = TextureWrapMode.Clamp;
  private _wrapModeV = TextureWrapMode.Clamp;
  private _filterMode = TextureFilterMode.Bilinear;
  private _anisoLevel = 1;
  private _depthCompareFunction = TextureDepthCompareFunction.LessEqual;
  private _useDepthCompareMode = false;
  private _sampler: GPUSampler;
  private _view: GPUTextureView;
  private _bindingVersion = 0;

  get wrapModeU(): TextureWrapMode {
    return this._wrapModeU;
  }

  set wrapModeU(value: TextureWrapMode) {
    this._wrapModeU = value;
    this._sampler = null;
    this._bindingVersion++;
  }

  get wrapModeV(): TextureWrapMode {
    return this._wrapModeV;
  }

  set wrapModeV(value: TextureWrapMode) {
    this._wrapModeV = value;
    this._sampler = null;
    this._bindingVersion++;
  }

  get filterMode(): TextureFilterMode {
    return this._filterMode;
  }

  set filterMode(value: TextureFilterMode) {
    this._filterMode = value;
    this._sampler = null;
    this._bindingVersion++;
  }

  get anisoLevel(): number {
    return this._anisoLevel;
  }

  set anisoLevel(value: number) {
    this._anisoLevel = value;
    this._sampler = null;
    this._bindingVersion++;
  }

  get depthCompareFunction(): TextureDepthCompareFunction {
    return this._depthCompareFunction;
  }

  set depthCompareFunction(value: TextureDepthCompareFunction) {
    this._depthCompareFunction = value;
    this._sampler = null;
    this._bindingVersion++;
  }

  /** @internal */
  get sampler(): GPUSampler {
    if (!this._sampler) {
      const point = this._filterMode === TextureFilterMode.Point;
      this._sampler = this._device.device.createSampler({
        addressModeU: WebGPUTexture._getAddressMode(this._wrapModeU),
        addressModeV: WebGPUTexture._getAddressMode(this._wrapModeV),
        magFilter: point ? "nearest" : "linear",
        minFilter: point ? "nearest" : "linear",
        mipmapFilter: this._filterMode === TextureFilterMode.Trilinear ? "linear" : "nearest",
        maxAnisotropy: this._anisoLevel,
        compare: this._useDepthCompareMode ? WebGPUTexture._getCompareFunction(this._depthCompareFunction) : undefined
      });
    }
    return this._sampler;
  }

  /** @internal */
  get view(): GPUTextureView {
    return (this._view ??= this._gpuTexture.createView({ dimension: this._viewDimension }));
  }

  /** @internal */
  get bindingKey(): string {
    return `${this._bindingId}:${this._bindingVersion}`;
  }

  protected constructor(
    device: WebGPUGraphicDevice,
    texture: Texture,
    dimension: GPUTextureDimension,
    viewDimension: GPUTextureViewDimension,
    layerCount: number
  ) {
    this._device = device;
    this._texture = texture;
    this._layerCount = layerCount;
    this._viewDimension = viewDimension;
    this._format = WebGPUTexture._getFormat(texture.format, texture.isSRGBColorSpace);
    this._gpuTexture = device.device.createTexture({
      label: texture.name,
      size: {
        width: texture.width,
        height: texture.height,
        depthOrArrayLayers: layerCount
      },
      mipLevelCount: texture.mipmapCount,
      sampleCount: 1,
      dimension,
      format: this._format,
      usage:
        GPUTextureUsage.TEXTURE_BINDING |
        GPUTextureUsage.COPY_DST |
        GPUTextureUsage.COPY_SRC |
        GPUTextureUsage.RENDER_ATTACHMENT
    });
  }

  destroy(): void {
    this._gpuTexture.destroy();
  }

  generateMipmaps(): void {
    this._device._generateMipmaps(
      this._gpuTexture,
      this._format,
      this._texture.width,
      this._texture.height,
      this._texture.mipmapCount,
      this._layerCount
    );
  }

  setUseDepthCompareMode(value: boolean): void {
    if (value === this._useDepthCompareMode) {
      return;
    }
    this._useDepthCompareMode = value;
    this._sampler = null;
    this._bindingVersion++;
  }

  protected _writeTexture(
    colorBuffer: ArrayBufferView,
    mipLevel: number,
    origin: GPUOrigin3D,
    width: number,
    height: number,
    depthOrArrayLayers: number
  ): void {
    const layout = WebGPUTexture._getTexelLayout(this._format);
    this._device.device.queue.writeTexture(
      { texture: this._gpuTexture, mipLevel, origin },
      colorBuffer,
      {
        bytesPerRow: Math.ceil(width / layout.blockWidth) * layout.bytesPerBlock,
        rowsPerImage: Math.ceil(height / layout.blockHeight)
      },
      { width, height, depthOrArrayLayers }
    );
  }

  protected _copyExternalImage(
    source: TexImageSource,
    mipLevel: number,
    origin: GPUOrigin3D,
    flipY: boolean,
    premultipliedAlpha: boolean
  ): void {
    const dimensions = WebGPUTexture._getExternalImageSize(source);
    this._device.device.queue.copyExternalImageToTexture(
      { source, flipY },
      {
        texture: this._gpuTexture,
        mipLevel,
        origin,
        premultipliedAlpha
      },
      {
        width: dimensions.width,
        height: dimensions.height,
        depthOrArrayLayers: 1
      }
    );
  }

  protected _unsupportedReadback(): never {
    throw new Error("Synchronous texture readback is not supported by the WebGPU backend.");
  }

  /** @internal */
  static _getFormat(format: TextureFormat, srgb: boolean): GPUTextureFormat {
    switch (format) {
      case TextureFormat.R8G8B8:
      case TextureFormat.R8G8B8A8:
        return srgb ? "rgba8unorm-srgb" : "rgba8unorm";
      case TextureFormat.R16G16B16A16:
        return "rgba16float";
      case TextureFormat.R32G32B32A32:
        return "rgba32float";
      case TextureFormat.R32G32B32A32_UInt:
        return "rgba32uint";
      case TextureFormat.R11G11B10_UFloat:
        return "rg11b10ufloat";
      case TextureFormat.R8:
        return "r8unorm";
      case TextureFormat.R8G8:
        return "rg8unorm";
      case TextureFormat.R16:
        return "r16float";
      case TextureFormat.BC1:
        return srgb ? "bc1-rgba-unorm-srgb" : "bc1-rgba-unorm";
      case TextureFormat.BC3:
        return srgb ? "bc3-rgba-unorm-srgb" : "bc3-rgba-unorm";
      case TextureFormat.BC7:
        return srgb ? "bc7-rgba-unorm-srgb" : "bc7-rgba-unorm";
      case TextureFormat.BC6H:
        return "bc6h-rgb-ufloat";
      case TextureFormat.ETC2_RGB:
      case TextureFormat.ETC1_RGB:
        return srgb ? "etc2-rgb8unorm-srgb" : "etc2-rgb8unorm";
      case TextureFormat.ETC2_RGBA5:
        return srgb ? "etc2-rgb8a1unorm-srgb" : "etc2-rgb8a1unorm";
      case TextureFormat.ETC2_RGBA8:
        return srgb ? "etc2-rgba8unorm-srgb" : "etc2-rgba8unorm";
      case TextureFormat.ASTC_4x4:
        return srgb ? "astc-4x4-unorm-srgb" : "astc-4x4-unorm";
      case TextureFormat.ASTC_5x5:
        return srgb ? "astc-5x5-unorm-srgb" : "astc-5x5-unorm";
      case TextureFormat.ASTC_6x6:
        return srgb ? "astc-6x6-unorm-srgb" : "astc-6x6-unorm";
      case TextureFormat.ASTC_8x8:
        return srgb ? "astc-8x8-unorm-srgb" : "astc-8x8-unorm";
      case TextureFormat.ASTC_10x10:
        return srgb ? "astc-10x10-unorm-srgb" : "astc-10x10-unorm";
      case TextureFormat.ASTC_12x12:
        return srgb ? "astc-12x12-unorm-srgb" : "astc-12x12-unorm";
      case TextureFormat.Depth:
      case TextureFormat.Depth32:
        return "depth32float";
      case TextureFormat.Depth16:
        return "depth16unorm";
      case TextureFormat.DepthStencil:
      case TextureFormat.Depth24Stencil8:
        return "depth24plus-stencil8";
      case TextureFormat.Depth24:
        return "depth24plus";
      case TextureFormat.Depth32Stencil8:
        return "depth32float-stencil8";
      default:
        throw new Error(`Texture format ${TextureFormat[format]} is not supported by the WebGPU backend.`);
    }
  }

  private static _getAddressMode(mode: TextureWrapMode): GPUAddressMode {
    switch (mode) {
      case TextureWrapMode.Repeat:
        return "repeat";
      case TextureWrapMode.Mirror:
        return "mirror-repeat";
      default:
        return "clamp-to-edge";
    }
  }

  private static _getCompareFunction(compare: TextureDepthCompareFunction): GPUCompareFunction {
    return (
      [
        "never",
        "less",
        "equal",
        "less-equal",
        "greater",
        "not-equal",
        "greater-equal",
        "always"
      ] as GPUCompareFunction[]
    )[compare];
  }

  private static _getTexelLayout(format: GPUTextureFormat): {
    bytesPerBlock: number;
    blockWidth: number;
    blockHeight: number;
  } {
    if (format.startsWith("bc1") || format.startsWith("etc2-rgb8") || format.startsWith("etc2-rgb8a1")) {
      return { bytesPerBlock: 8, blockWidth: 4, blockHeight: 4 };
    }
    if (format.startsWith("bc") || format.startsWith("etc2-rgba8") || format.startsWith("astc-4x4")) {
      return { bytesPerBlock: 16, blockWidth: 4, blockHeight: 4 };
    }
    const astcMatch = /^astc-(\d+)x(\d+)/.exec(format);
    if (astcMatch) {
      return {
        bytesPerBlock: 16,
        blockWidth: Number(astcMatch[1]),
        blockHeight: Number(astcMatch[2])
      };
    }
    switch (format) {
      case "r8unorm":
        return { bytesPerBlock: 1, blockWidth: 1, blockHeight: 1 };
      case "rg8unorm":
      case "r16float":
      case "depth16unorm":
        return { bytesPerBlock: 2, blockWidth: 1, blockHeight: 1 };
      case "rgba16float":
        return { bytesPerBlock: 8, blockWidth: 1, blockHeight: 1 };
      case "rgba32float":
      case "rgba32uint":
        return { bytesPerBlock: 16, blockWidth: 1, blockHeight: 1 };
      default:
        return { bytesPerBlock: 4, blockWidth: 1, blockHeight: 1 };
    }
  }

  private static _getExternalImageSize(source: TexImageSource): { width: number; height: number } {
    if ("codedWidth" in source) {
      return { width: source.codedWidth, height: source.codedHeight };
    }
    if ("videoWidth" in source && source.videoWidth) {
      return { width: source.videoWidth, height: source.videoHeight };
    }
    return { width: source.width, height: source.height };
  }
}
