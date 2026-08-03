import { IPlatformTexture2D, Texture2D, TextureFormat } from "@galacean/engine-core";
import { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";
import { WebGPUTexture } from "./WebGPUTexture";

/**
 * WebGPU two-dimensional texture.
 * @internal
 */
export class WebGPUTexture2D extends WebGPUTexture implements IPlatformTexture2D {
  constructor(device: WebGPUGraphicDevice, texture: Texture2D) {
    super(device, texture, "2d", "2d", 1);
  }

  setPixelBuffer(
    colorBuffer: ArrayBufferView,
    mipLevel: number,
    x: number,
    y: number,
    width?: number,
    height?: number
  ): void {
    width ??= Math.max(1, this._texture.width >> mipLevel) - x;
    height ??= Math.max(1, this._texture.height >> mipLevel) - y;

    if (this._texture.format === TextureFormat.R8G8B8) {
      colorBuffer = WebGPUTexture2D._expandRGB(colorBuffer);
    }
    this._writeTexture(colorBuffer, mipLevel, { x, y, z: 0 }, width, height, 1);
  }

  setImageSource(
    imageSource: TexImageSource,
    mipLevel: number,
    flipY: boolean,
    premultiplyAlpha: boolean,
    x: number,
    y: number
  ): void {
    this._copyExternalImage(imageSource, mipLevel, { x, y, z: 0 }, flipY, premultiplyAlpha);
  }

  getPixelBuffer(): void {
    this._unsupportedReadback();
  }

  private static _expandRGB(source: ArrayBufferView): Uint8Array {
    const input = new Uint8Array(source.buffer, source.byteOffset, source.byteLength);
    const output = new Uint8Array((input.length / 3) * 4);
    for (let sourceOffset = 0, targetOffset = 0; sourceOffset < input.length; sourceOffset += 3, targetOffset += 4) {
      output[targetOffset] = input[sourceOffset];
      output[targetOffset + 1] = input[sourceOffset + 1];
      output[targetOffset + 2] = input[sourceOffset + 2];
      output[targetOffset + 3] = 255;
    }
    return output;
  }
}
