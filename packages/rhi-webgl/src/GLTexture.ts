import {
  GLCapabilityType,
  IPlatformTexture,
  Logger,
  RenderBufferColorFormat,
  RenderBufferDepthFormat,
  Texture,
  TextureCubeFace,
  TextureFilterMode,
  TextureFormat,
  TextureWrapMode
} from "@oasis-engine/core";
import { GLCompressedTextureInternalFormat, TextureFormatDetail } from "./type";
import { WebGLRenderer } from "./WebGLRenderer";

/**
 * Texture in WebGL platform.
 */
export class GLTexture implements IPlatformTexture {
  /** @internal */
  static _readFrameBuffer: WebGLFramebuffer = null;

  /** @internal */
  static _isPowerOf2(v: number): boolean {
    return (v & (v - 1)) === 0;
  }

  /**
   * Get more texture info from TextureFormat.
   * @internal
   */
  static _getFormatDetail(
    format: TextureFormat,
    gl: WebGLRenderingContext & WebGL2RenderingContext,
    isWebGL2: boolean
  ): TextureFormatDetail {
    switch (format) {
      case TextureFormat.R8G8B8:
        return {
          internalFormat: isWebGL2 ? gl.RGB8 : gl.RGB,
          baseFormat: gl.RGB,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false
        };
      case TextureFormat.R8G8B8A8:
        return {
          internalFormat: isWebGL2 ? gl.RGBA8 : gl.RGBA,
          baseFormat: gl.RGBA,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false
        };
      case TextureFormat.R4G4B4A4:
        return {
          internalFormat: isWebGL2 ? gl.RGBA4 : gl.RGBA,
          baseFormat: gl.RGBA,
          dataType: gl.UNSIGNED_SHORT_4_4_4_4,
          isCompressed: false
        };
      case TextureFormat.R5G5B5A1:
        return {
          internalFormat: isWebGL2 ? gl.RGB5_A1 : gl.RGBA,
          baseFormat: gl.RGBA,
          dataType: gl.UNSIGNED_SHORT_5_5_5_1,
          isCompressed: false
        };
      case TextureFormat.R5G6B5:
        return {
          internalFormat: isWebGL2 ? gl.RGB565 : gl.RGB,
          baseFormat: gl.RGB,
          dataType: gl.UNSIGNED_SHORT_5_6_5,
          isCompressed: false
        };
      case TextureFormat.Alpha8:
        return {
          internalFormat: gl.ALPHA,
          baseFormat: gl.ALPHA,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false
        };
      case TextureFormat.R32G32B32A32:
        return {
          internalFormat: gl.RGBA32F,
          baseFormat: gl.RGBA,
          dataType: gl.FLOAT,
          isCompressed: false
        };
      case TextureFormat.R11G11B10:
        return {
          internalFormat: isWebGL2 ? gl.R11F_G11F_B10F : gl.R11F_G11F_B10F,
          baseFormat: gl.RGB,
          dataType: gl.UNSIGNED_INT_10F_11F_11F_REV,
          isCompressed: false
        };
      case TextureFormat.DXT1:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGB_S3TC_DXT1_EXT,
          isCompressed: true
        };
      case TextureFormat.DXT5:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_S3TC_DXT5_EXT,
          isCompressed: true
        };
      case TextureFormat.ETC1_RGB:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGB_ETC1_WEBGL,
          isCompressed: true
        };
      case TextureFormat.ETC2_RGB:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGB8_ETC2,
          isCompressed: true
        };
      case TextureFormat.ETC2_RGBA5:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGB8_PUNCHTHROUGH_ALPHA1_ETC2,
          isCompressed: true
        };
      case TextureFormat.ETC2_RGBA8:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA8_ETC2_EAC,
          isCompressed: true
        };
      case TextureFormat.PVRTC_RGB2:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGB_PVRTC_2BPPV1_IMG,
          isCompressed: true
        };
      case TextureFormat.PVRTC_RGBA2:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_PVRTC_2BPPV1_IMG,
          isCompressed: true
        };
      case TextureFormat.PVRTC_RGB4:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGB_PVRTC_4BPPV1_IMG,
          isCompressed: true
        };
      case TextureFormat.PVRTC_RGBA4:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_PVRTC_4BPPV1_IMG,
          isCompressed: true
        };
      case TextureFormat.ASTC_4x4:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_ASTC_4X4_KHR,
          isCompressed: true
        };
      case TextureFormat.ASTC_5x5:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_ASTC_5X5_KHR,
          isCompressed: true
        };
      case TextureFormat.ASTC_6x6:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_ASTC_6X6_KHR,
          isCompressed: true
        };
      case TextureFormat.ASTC_8x8:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_ASTC_8X8_KHR,
          isCompressed: true
        };
      case TextureFormat.ASTC_10x10:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_ASTC_10X10_KHR,
          isCompressed: true
        };
      case TextureFormat.ASTC_12x12:
        return {
          internalFormat: GLCompressedTextureInternalFormat.RGBA_ASTC_12X12_KHR,
          isCompressed: true
        };
      default:
        throw new Error(`this TextureFormat is not supported in Oasis Engine: ${format}`);
    }
  }

  /**
   * @internal
   */
  static _getRenderBufferColorFormatDetail(
    format: RenderBufferColorFormat,
    gl: WebGLRenderingContext & WebGL2RenderingContext,
    isWebGL2: boolean
  ): TextureFormatDetail {
    switch (format) {
      case RenderBufferColorFormat.R8G8B8:
        return {
          internalFormat: isWebGL2 ? gl.RGB8 : gl.RGB,
          baseFormat: gl.RGB,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false
        };
      case RenderBufferColorFormat.R8G8B8A8:
        return {
          internalFormat: isWebGL2 ? gl.RGBA8 : gl.RGBA,
          baseFormat: gl.RGBA,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false
        };
      case RenderBufferColorFormat.R4G4B4A4:
        return {
          internalFormat: isWebGL2 ? gl.RGBA4 : gl.RGBA,
          baseFormat: gl.RGBA,
          dataType: gl.UNSIGNED_SHORT_4_4_4_4,
          isCompressed: false
        };
      case RenderBufferColorFormat.R5G5B5A1:
        return {
          internalFormat: isWebGL2 ? gl.RGB5_A1 : gl.RGBA,
          baseFormat: gl.RGBA,
          dataType: gl.UNSIGNED_SHORT_5_5_5_1,
          isCompressed: false
        };
      case RenderBufferColorFormat.R5G6B5:
        return {
          internalFormat: isWebGL2 ? gl.RGB565 : gl.RGB,
          baseFormat: gl.RGB,
          dataType: gl.UNSIGNED_SHORT_5_6_5,
          isCompressed: false
        };
      case RenderBufferColorFormat.Alpha8:
        return {
          internalFormat: gl.ALPHA,
          baseFormat: gl.ALPHA,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false
        };
      case RenderBufferColorFormat.R16G16B16A16:
        return {
          internalFormat: gl.RGBA16F,
          baseFormat: gl.RGBA,
          dataType: gl.HALF_FLOAT,
          isCompressed: false
        };
      case RenderBufferColorFormat.R32G32B32A32:
        return {
          internalFormat: gl.RGBA32F,
          baseFormat: gl.RGBA,
          dataType: gl.FLOAT,
          isCompressed: false
        };
      default:
        throw new Error(`this RenderBufferColorFormat is not supported in Oasis Engine: ${format}`);
    }
  }

  /**
   * In WebGL 1, internalformat must be the same as baseFormat when call texImage2D.
   * @internal
   */
  static _getRenderBufferDepthFormatDetail(
    format: RenderBufferDepthFormat,
    gl: WebGLRenderingContext & WebGL2RenderingContext,
    isWebGL2: boolean
  ): TextureFormatDetail {
    switch (format) {
      case RenderBufferDepthFormat.Depth:
        return {
          internalFormat: isWebGL2 ? gl.DEPTH_COMPONENT32F : gl.DEPTH_COMPONENT16,
          baseFormat: gl.DEPTH_COMPONENT,
          dataType: isWebGL2 ? gl.FLOAT : gl.UNSIGNED_INT,
          isCompressed: false,
          attachment: gl.DEPTH_ATTACHMENT
        };
      case RenderBufferDepthFormat.DepthStencil:
        return {
          internalFormat: isWebGL2 ? gl.DEPTH24_STENCIL8 : gl.DEPTH_STENCIL,
          baseFormat: gl.DEPTH_STENCIL,
          dataType: gl.UNSIGNED_INT_24_8,
          isCompressed: false,
          attachment: gl.DEPTH_STENCIL_ATTACHMENT
        };
      case RenderBufferDepthFormat.Stencil:
        return {
          internalFormat: gl.STENCIL_INDEX8,
          baseFormat: gl.STENCIL_ATTACHMENT,
          dataType: gl.UNSIGNED_BYTE,
          isCompressed: false,
          attachment: gl.STENCIL_ATTACHMENT
        };
      case RenderBufferDepthFormat.Depth16:
        return {
          internalFormat: isWebGL2 ? gl.DEPTH_COMPONENT16 : gl.DEPTH_COMPONENT16,
          baseFormat: gl.DEPTH_COMPONENT,
          dataType: gl.UNSIGNED_INT,
          isCompressed: false,
          attachment: gl.DEPTH_ATTACHMENT
        };
      case RenderBufferDepthFormat.Depth24:
        return {
          internalFormat: gl.DEPTH_COMPONENT24,
          baseFormat: gl.DEPTH_COMPONENT,
          dataType: gl.UNSIGNED_INT,
          isCompressed: false,
          attachment: gl.DEPTH_ATTACHMENT
        };
      case RenderBufferDepthFormat.Depth32:
        return {
          internalFormat: gl.DEPTH_COMPONENT32F,
          baseFormat: gl.DEPTH_COMPONENT,
          dataType: gl.FLOAT,
          isCompressed: false,
          attachment: gl.DEPTH_ATTACHMENT
        };
      case RenderBufferDepthFormat.Depth24Stencil8:
        return {
          internalFormat: isWebGL2 ? gl.DEPTH24_STENCIL8 : gl.DEPTH_STENCIL,
          baseFormat: gl.DEPTH_STENCIL,
          dataType: gl.UNSIGNED_INT_24_8,
          isCompressed: false,
          attachment: gl.DEPTH_STENCIL_ATTACHMENT
        };
      case RenderBufferDepthFormat.Depth32Stencil8:
        return {
          internalFormat: gl.DEPTH32F_STENCIL8,
          baseFormat: gl.DEPTH_STENCIL,
          dataType: gl.FLOAT_32_UNSIGNED_INT_24_8_REV,
          isCompressed: false,
          attachment: gl.DEPTH_STENCIL_ATTACHMENT
        };
      default:
        throw new Error(`this RenderBufferDepthFormat is not supported in Oasis Engine: ${format}`);
    }
  }

  /**
   * Check whether the corresponding texture format is supported.
   * @internal
   */
  static _supportTextureFormat(format: TextureFormat, rhi: WebGLRenderer): boolean {
    let isSupported = true;

    switch (format) {
      case TextureFormat.R32G32B32A32:
        {
          if (!rhi.canIUse(GLCapabilityType.textureFloat)) {
            isSupported = false;
          }
        }
        break;
    }

    return isSupported;
  }

  /**
   * @internal
   */
  static _supportRenderBufferColorFormat(format: RenderBufferColorFormat, rhi: WebGLRenderer): boolean {
    let isSupported = true;

    switch (format) {
      case RenderBufferColorFormat.R32G32B32A32:
        {
          if (!rhi.canIUse(GLCapabilityType.colorBufferFloat) || !rhi.canIUse(GLCapabilityType.textureFloat)) {
            isSupported = false;
          }
        }
        break;
      case RenderBufferColorFormat.R16G16B16A16:
        {
          if (!rhi.canIUse(GLCapabilityType.colorBufferHalfFloat) || !rhi.canIUse(GLCapabilityType.textureHalfFloat)) {
            isSupported = false;
          }
        }
        break;
    }

    return isSupported;
  }

  /**
   * @internal
   */
  static _supportRenderBufferDepthFormat(
    format: RenderBufferDepthFormat,
    rhi: WebGLRenderer,
    isTexture: boolean
  ): boolean {
    const isWebGL2: boolean = rhi.isWebGL2;
    let isSupported = true;

    if (isTexture && !rhi.canIUse(GLCapabilityType.depthTexture)) {
      return false;
    }

    switch (format) {
      case RenderBufferDepthFormat.Stencil:
        {
          isSupported = false;
        }
        break;
      case RenderBufferDepthFormat.Depth24:
      case RenderBufferDepthFormat.Depth32:
      case RenderBufferDepthFormat.Depth32Stencil8:
        {
          if (!isWebGL2) {
            isSupported = false;
          }
        }
        break;
    }

    return isSupported;
  }

  /** @internal */
  _texture: Texture;
  /** @internal */
  _glTexture: WebGLTexture;
  /** @internal */
  _rhi: WebGLRenderer;
  /** @internal */
  _gl: WebGLRenderingContext & WebGL2RenderingContext;
  /** @internal */
  _isWebGL2: boolean;
  /** @internal */
  _target: GLenum; // gl.TEXTURE_2D | gl.TEXTURE_CUBE_MAP
  /** @internal */
  _formatDetail: TextureFormatDetail;

  /**
   * Wrapping mode for texture coordinate S.
   */
  set wrapModeU(value: TextureWrapMode) {
    this._bind();
    this._setWrapMode(value, this._gl.TEXTURE_WRAP_S);
  }

  /**
   * Wrapping mode for texture coordinate T.
   */
  set wrapModeV(value: TextureWrapMode) {
    this._bind();
    this._setWrapMode(value, this._gl.TEXTURE_WRAP_T);
  }

  /**
   * Filter mode for texture.
   */
  set filterMode(value: TextureFilterMode) {
    const gl = this._gl;
    const target = this._target;
    /** @ts-ignore */
    const { _mipmap } = this._texture;

    this._bind();
    switch (value) {
      case TextureFilterMode.Point:
        gl.texParameteri(target, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
        gl.texParameteri(target, gl.TEXTURE_MIN_FILTER, _mipmap ? gl.NEAREST_MIPMAP_NEAREST : gl.NEAREST);
        break;
      case TextureFilterMode.Bilinear:
        gl.texParameteri(target, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(target, gl.TEXTURE_MIN_FILTER, _mipmap ? gl.LINEAR_MIPMAP_NEAREST : gl.LINEAR);
        break;
      case TextureFilterMode.Trilinear:
        gl.texParameteri(target, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(target, gl.TEXTURE_MIN_FILTER, _mipmap ? gl.LINEAR_MIPMAP_LINEAR : gl.LINEAR);
        break;
    }
  }

  /**
   * Anisotropic level for texture.
   */
  set anisoLevel(value: number) {
    const gl = this._gl as WebGLRenderingContext & WebGL2RenderingContext & EXT_texture_filter_anisotropic;

    this._bind();
    gl.texParameterf(this._target, gl.TEXTURE_MAX_ANISOTROPY_EXT, value);
  }

  /**
   * Create texture in WebGL platform.
   */
  constructor(rhi: WebGLRenderer, texture: Texture, target: GLenum) {
    this._texture = texture;
    this._rhi = rhi;
    this._gl = rhi.gl as WebGLRenderingContext & WebGL2RenderingContext;
    this._isWebGL2 = rhi.isWebGL2;
    this._target = target;
    this._glTexture = this._gl.createTexture();
  }

  /**
   * Destroy texture.
   */
  destroy() {
    this._gl.deleteTexture(this._glTexture);
    this._texture = null;
    this._glTexture = null;
    this._formatDetail = null;
  }

  /**
   * Generate multi-level textures based on the 0th level data.
   */
  generateMipmaps(): void {
    this._bind();
    this._gl.generateMipmap(this._target);
  }

  protected _bind() {
    this._rhi.bindTexture(this);
  }

  /**
   * Pre-development mipmapping GPU memory.
   */
  protected _initMipmap(isCube: boolean): void {
    const gl = this._gl;
    const isWebGL2 = this._isWebGL2;
    let { internalFormat, baseFormat, dataType } = this._formatDetail;
    const { mipmapCount, width, height } = this._texture;

    this._bind();

    if (isWebGL2) {
      gl.texStorage2D(this._target, mipmapCount, internalFormat, width, height);
    } else {
      // In WebGL 1, internalformat must be the same as baseFormat
      if (baseFormat !== internalFormat) {
        internalFormat = baseFormat;
      }

      if (!isCube) {
        for (let i = 0; i < mipmapCount; i++) {
          const mipWidth = Math.max(1, width >> i);
          const mipHeight = Math.max(1, height >> i);

          gl.texImage2D(this._target, i, internalFormat, mipWidth, mipHeight, 0, baseFormat, dataType, null);
        }
      } else {
        for (let i = 0; i < mipmapCount; i++) {
          const size = Math.max(1, width >> i);
          for (let faceIndex = 0; faceIndex < 6; faceIndex++) {
            gl.texImage2D(
              gl.TEXTURE_CUBE_MAP_POSITIVE_X + faceIndex,
              i,
              internalFormat,
              size,
              size,
              0,
              baseFormat,
              dataType,
              null
            );
          }
        }
      }
    }
  }

  /**
   * Get the pixel color buffer according to the specified cube face and area.
   * @param face - You can choose which cube face to read
   * @param x - X coordinate of area start
   * @param y - Y coordinate of area start
   * @param width - Area width
   * @param height - Area height
   * @param out - Color buffer
   */
  protected _getPixelBuffer(
    face: TextureCubeFace | null,
    x: number,
    y: number,
    width: number,
    height: number,
    out: ArrayBufferView
  ): void {
    const gl = this._gl;
    const { baseFormat, dataType } = this._formatDetail;

    if (!GLTexture._readFrameBuffer) {
      GLTexture._readFrameBuffer = gl.createFramebuffer();
    }

    gl.bindFramebuffer(gl.FRAMEBUFFER, GLTexture._readFrameBuffer);

    if (face != null) {
      gl.framebufferTexture2D(
        gl.FRAMEBUFFER,
        gl.COLOR_ATTACHMENT0,
        gl.TEXTURE_CUBE_MAP_POSITIVE_X + face,
        this._glTexture,
        0
      );
    } else {
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, this._glTexture, 0);
    }
    gl.readPixels(x, y, width, height, baseFormat, dataType, out);

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  private _setWrapMode(value: TextureWrapMode, pname: GLenum): void {
    const gl = this._gl;
    const isWebGL2 = this._isWebGL2;
    const target = this._target;
    const { width, height } = this._texture;

    if (
      !isWebGL2 &&
      value !== TextureWrapMode.Clamp &&
      (!GLTexture._isPowerOf2(width) || !GLTexture._isPowerOf2(height))
    ) {
      Logger.warn(
        "non-power-2 texture is not supported for REPEAT or MIRRORED_REPEAT in WebGL1,and has automatically downgraded to CLAMP_TO_EDGE"
      );
      value = TextureWrapMode.Clamp;
    }

    switch (value) {
      case TextureWrapMode.Clamp:
        gl.texParameteri(target, pname, gl.CLAMP_TO_EDGE);
        break;
      case TextureWrapMode.Repeat:
        gl.texParameteri(target, pname, gl.REPEAT);
        break;
      case TextureWrapMode.Mirror:
        gl.texParameteri(target, pname, gl.MIRRORED_REPEAT);
        break;
    }
  }
}
