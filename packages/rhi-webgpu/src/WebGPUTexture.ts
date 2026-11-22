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
  private readonly _samplers: Partial<Record<GPUSamplerBindingType,GPUSampler>> = {};
  private _view: GPUTextureView;
  private _depthView?: GPUTextureView;


  get wrapModeU(): TextureWrapMode {
    return this._wrapModeU;
  }

  set wrapModeU(value: TextureWrapMode) {
    this._wrapModeU = value;
    this._samplers.filtering = this._samplers.comparison = this._samplers["non-filtering"] = undefined;
  }

  get wrapModeV(): TextureWrapMode {
    return this._wrapModeV;
  }

  set wrapModeV(value: TextureWrapMode) {
    this._wrapModeV = value;
    this._samplers.filtering = this._samplers.comparison = this._samplers["non-filtering"] = undefined;
  }

  get filterMode(): TextureFilterMode {
    return this._filterMode;
  }

  set filterMode(value: TextureFilterMode) {
    this._filterMode = value;
    this._samplers.filtering = this._samplers.comparison = this._samplers["non-filtering"] = undefined;
  }

  get anisoLevel(): number {
    return this._anisoLevel;
  }

  set anisoLevel(value: number) {
    this._anisoLevel = value;
    this._samplers.filtering = this._samplers.comparison = this._samplers["non-filtering"] = undefined;
  }

  get depthCompareFunction(): TextureDepthCompareFunction {
    return this._depthCompareFunction;
  }

  set depthCompareFunction(value: TextureDepthCompareFunction) {
    this._depthCompareFunction = value;
    this._samplers.filtering = this._samplers.comparison = this._samplers["non-filtering"] = undefined;
  }

  /** @internal */
  get view(): GPUTextureView {
    return (this._view ??= this._gpuTexture.createView({ dimension: this._viewDimension }));
  }

  sampleView(type: GPUTextureSampleType): GPUTextureView | undefined {
    if (this._format.startsWith("depth")) {
      return this._depthView ??= this._gpuTexture.createView({dimension:this._viewDimension, aspect:"depth-only"});
    }
    if (type === "depth") return undefined;
    return this.view;
  }

  getSampler(type: GPUSamplerBindingType): GPUSampler {
    let sampler = this._samplers[type];
    if (!sampler) {
      const nearest = type === "non-filtering" || this._filterMode === TextureFilterMode.Point;
      const anisotropy = nearest ? 1 : Math.min(16,Math.max(1,Math.floor(this._anisoLevel)));
      sampler = this._device._getSampler({
        addressModeU: WebGPUTexture._getAddressMode(this._wrapModeU),
        addressModeV: WebGPUTexture._getAddressMode(this._wrapModeV),
        minFilter: nearest ? "nearest" : "linear",
        magFilter: nearest ? "nearest" : "linear",
        mipmapFilter: !nearest && (this._filterMode === TextureFilterMode.Trilinear || anisotropy > 1) ? "linear" : "nearest",
        maxAnisotropy: anisotropy,
        compare: type === "comparison" ? WebGPUTexture._getCompareFunction(this.depthCompareFunction) : undefined
      });
      this._samplers[type] = sampler;
    }
    return sampler;
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
        (device.supportsRenderTargetColorFormat(texture.format) || /^(depth|stencil)/.test(this._format) ? GPUTextureUsage.RENDER_ATTACHMENT : 0)
    });
  }

  destroy(): void {
    this._device.flush();
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

  // The shader binding selects comparison or ordinary sampling for each use of the texture.
  setUseDepthCompareMode(): void {}

  protected _writeTexture(
    colorBuffer: ArrayBufferView,
    mipLevel: number,
    origin: GPUOrigin3D,
    width: number,
    height: number,
    depthOrArrayLayers: number
  ): void {
    const layout = WebGPUTexture._getTexelLayout(this._format);
    if (this._texture.format === TextureFormat.R8G8B8_UNorm) {
      const source = new Uint8Array(colorBuffer.buffer,colorBuffer.byteOffset,colorBuffer.byteLength);
      const expanded = new Uint8Array(width*height*depthOrArrayLayers*4);
      if (source.length < expanded.length/4*3) throw new RangeError("RGB texture upload is too small.");
      for (let i=0,j=0;j<expanded.length;i+=3,j+=4) {
        expanded[j]=source[i]; expanded[j+1]=source[i+1]; expanded[j+2]=source[i+2]; expanded[j+3]=255;
      }
      colorBuffer = expanded;
    }
    this._device.flush();
    this._device.device.queue.writeTexture(
      { texture: this._gpuTexture, mipLevel, origin },
      colorBuffer,
      {
        bytesPerRow: Math.ceil(width / layout.blockWidth) * layout.bytesPerBlock,
        rowsPerImage: Math.ceil(height / layout.blockHeight)
      },
      { width: Math.ceil(width/layout.blockWidth)*layout.blockWidth, height:Math.ceil(height/layout.blockHeight)*layout.blockHeight, depthOrArrayLayers }
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
    this._device.flush();
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

  protected async _readPixels(layer: number,x: number,y: number,width: number,height: number,mipLevel: number,out: ArrayBufferView): Promise<void> {
    const layout = WebGPUTexture._getTexelLayout(this._format);
    const bytes = Math.ceil(width/layout.blockWidth)*layout.bytesPerBlock;
    const rows = Math.ceil(height/layout.blockHeight);
    const pitch = Math.ceil(bytes/256)*256;
    const rgb=this._texture.format === TextureFormat.R8G8B8_UNorm;
    if (out.byteLength < (rgb ? width*3 : bytes)*rows) throw new RangeError("Readback destination is too small.");
    if (!rows || !bytes) return;
    const staging = this._device.device.createBuffer({size:rows*pitch,usage:GPUBufferUsage.MAP_READ|GPUBufferUsage.COPY_DST});
    try {
      this._device._getCommandEncoder().copyTextureToBuffer(
        {texture:this._gpuTexture,mipLevel,origin:{x,y,z:layer}},
        {buffer:staging,bytesPerRow:pitch},
        {width:Math.ceil(width/layout.blockWidth)*layout.blockWidth,height:rows*layout.blockHeight}
      );
      this._device.flush();
      await staging.mapAsync(GPUMapMode.READ);
      const mapped = new Uint8Array(staging.getMappedRange());
      const dst = new Uint8Array(out.buffer,out.byteOffset,out.byteLength);
      for (let i=0;i<rows;i++) {
        if (rgb) for (let x=0;x<width;x++) {
          const src=i*pitch+x*4,j=(i*width+x)*3;
          dst[j]=mapped[src]; dst[j+1]=mapped[src+1]; dst[j+2]=mapped[src+2];
        } else dst.set(mapped.subarray(i*pitch,i*pitch+bytes),i*bytes);
      }
    } finally { staging.destroy(); }
  }

  /** @internal */
  static _getFormat(format: TextureFormat, srgb: boolean): GPUTextureFormat {
    switch (format) {
      case TextureFormat.R16_UNorm: return "r16unorm";
      case TextureFormat.R16G16_SFloat: return "rg16float";
      case TextureFormat.R32_SFloat: return "r32float";
      case TextureFormat.R32G32_SFloat: return "rg32float";
      case TextureFormat.Stencil: return "stencil8";
      case TextureFormat.R8G8B8_UNorm:
      case TextureFormat.R8G8B8A8_UNorm:
        return srgb ? "rgba8unorm-srgb" : "rgba8unorm";
      case TextureFormat.R16G16B16A16_SFloat:
        return "rgba16float";
      case TextureFormat.R32G32B32A32_SFloat:
        return "rgba32float";
      case TextureFormat.R32G32B32A32_UInt:
        return "rgba32uint";
      case TextureFormat.R11G11B10_UFloat:
        return "rg11b10ufloat";
      case TextureFormat.R8_UNorm:
        return "r8unorm";
      case TextureFormat.R8G8_UNorm:
        return "rg8unorm";
      case TextureFormat.R16_SFloat:
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
      case "r16unorm":
      case "r16float":
      case "depth16unorm":
        return { bytesPerBlock: 2, blockWidth: 1, blockHeight: 1 };
      case "rgba16float":
      case "rg32float":
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
