import {
  CameraClearFlags,
  IPlatformRenderTarget,
  RenderTarget,
  Texture,
  TextureCube,
  TextureCubeFace,
  TextureFormat
} from "@galacean/engine-core";
import { Color } from "@galacean/engine-math";
import { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";
import { WebGPUTexture } from "./WebGPUTexture";

/**
 * WebGPU render target attachments.
 * @internal
 */
export class WebGPURenderTarget implements IPlatformRenderTarget {
  private readonly _device: WebGPUGraphicDevice;
  private readonly _target: RenderTarget;
  private readonly _multisampledColors: GPUTexture[] = [];
  private readonly _ownedDepth: GPUTexture;
  private _mipLevel = 0;
  private _faceIndex?: TextureCubeFace;
  private _depthReadOnly = false;

  constructor(device: WebGPUGraphicDevice, target: RenderTarget) {
    this._device = device;
    this._target = target;

    const sampleCount = target.antiAliasing;
    if (sampleCount > 1) {
      for (const color of target.colorTextures) {
        const platformTexture = (color as TextureInternal)._platformTexture as WebGPUTexture;
        this._multisampledColors.push(
          device.device.createTexture({
            label: `${color.name || "RenderTarget"} MSAA`,
            size: { width: target.width, height: target.height },
            sampleCount,
            format: platformTexture._format,
            usage: GPUTextureUsage.RENDER_ATTACHMENT
          })
        );
      }
    }

    const depth = (target as RenderTargetInternal)._depth;
    if (typeof depth === "number") {
      this._ownedDepth = device.device.createTexture({
        label: "RenderTarget depth",
        size: { width: target.width, height: target.height },
        sampleCount,
        format: WebGPUTexture._getFormat(depth, false),
        usage: GPUTextureUsage.RENDER_ATTACHMENT
      });
    } else if (depth instanceof Texture && sampleCount > 1) {
      this._ownedDepth = device.device.createTexture({
        label: `${depth.name || "RenderTarget"} depth MSAA`,
        size: { width: target.width, height: target.height },
        sampleCount,
        format: ((depth as TextureInternal)._platformTexture as WebGPUTexture)._format,
        usage: GPUTextureUsage.RENDER_ATTACHMENT
      });
    }
  }

  activeRenderTarget(mipLevel: number = 0, faceIndex?: TextureCubeFace, depthReadOnly: boolean = false): void {
    this._mipLevel = mipLevel;
    this._faceIndex = faceIndex;
    this._depthReadOnly = depthReadOnly;
    this._device._setRenderTarget(this);
  }

  blitRenderTarget(): void {}

  destroy(): void {
    for (const texture of this._multisampledColors) {
      texture.destroy();
    }
    this._ownedDepth?.destroy();
  }

  /** @internal */
  get colorFormats(): readonly GPUTextureFormat[] {
    return this._target.colorTextures.map(
      (texture) => ((texture as TextureInternal)._platformTexture as WebGPUTexture)._format
    );
  }

  /** @internal */
  get depthStencilFormat(): GPUTextureFormat | undefined {
    const depthFormat = (this._target as RenderTargetInternal)._depthFormat;
    return depthFormat === null ? undefined : WebGPUTexture._getFormat(depthFormat, false);
  }

  /** @internal */
  get sampleCount(): number {
    return this._target.antiAliasing;
  }

  /** @internal */
  get width(): number {
    return Math.max(1, this._target.width >> this._mipLevel);
  }

  /** @internal */
  get height(): number {
    return Math.max(1, this._target.height >> this._mipLevel);
  }

  /** @internal */
  createDescriptor(clearFlags: CameraClearFlags, clearColor?: Color): GPURenderPassDescriptor {
    const target = this._target;
    const sampleCount = target.antiAliasing;
    const clearColorAttachment = (clearFlags & CameraClearFlags.Color) !== 0;
    const clearDepth = (clearFlags & CameraClearFlags.Depth) !== 0;
    const clearStencil = (clearFlags & CameraClearFlags.Stencil) !== 0;
    const colorAttachments: GPURenderPassColorAttachment[] = target.colorTextures.map((texture, index) => {
      const platformTexture = (texture as TextureInternal)._platformTexture as WebGPUTexture;
      const resolveTarget = platformTexture._gpuTexture.createView(this._viewDescriptor(texture));
      return {
        view: sampleCount > 1 ? this._multisampledColors[index].createView() : resolveTarget,
        resolveTarget: sampleCount > 1 ? resolveTarget : undefined,
        clearValue: clearColorAttachment
          ? {
              r: clearColor?.r ?? 0,
              g: clearColor?.g ?? 0,
              b: clearColor?.b ?? 0,
              a: clearColor?.a ?? 0
            }
          : undefined,
        loadOp: clearColorAttachment ? "clear" : "load",
        storeOp: "store"
      };
    });

    const targetInternal = target as RenderTargetInternal;
    const depth = targetInternal._depth;
    let depthStencilAttachment: GPURenderPassDepthStencilAttachment;
    if (depth !== null) {
      const view =
        this._ownedDepth?.createView() ??
        ((depth as TextureInternal)._platformTexture as WebGPUTexture)._gpuTexture.createView(
          this._viewDescriptor(depth as Texture)
        );
      const depthFormat = targetInternal._depthFormat;
      const hasStencil =
        depthFormat === TextureFormat.DepthStencil ||
        depthFormat === TextureFormat.Depth24Stencil8 ||
        depthFormat === TextureFormat.Depth32Stencil8;
      depthStencilAttachment = {
        view,
        depthReadOnly: this._depthReadOnly,
        depthClearValue: !this._depthReadOnly && clearDepth ? 1 : undefined,
        depthLoadOp: this._depthReadOnly ? undefined : clearDepth ? "clear" : "load",
        depthStoreOp: this._depthReadOnly ? undefined : "store",
        stencilClearValue: clearStencil ? 0 : undefined,
        stencilLoadOp: hasStencil ? (clearStencil ? "clear" : "load") : undefined,
        stencilStoreOp: hasStencil ? "store" : undefined
      };
    }

    return { colorAttachments, depthStencilAttachment };
  }

  private _viewDescriptor(texture: Texture): GPUTextureViewDescriptor {
    const isCube = texture instanceof TextureCube;
    return {
      dimension: "2d",
      baseMipLevel: this._mipLevel,
      mipLevelCount: 1,
      baseArrayLayer: isCube ? (this._faceIndex ?? 0) : 0,
      arrayLayerCount: 1
    };
  }
}

type TextureInternal = Texture & {
  _platformTexture: WebGPUTexture;
};

type RenderTargetInternal = RenderTarget & {
  _depth: Texture | TextureFormat | null;
  _depthFormat: TextureFormat | null;
};
