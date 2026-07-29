import { TextureCubeFace } from "../texture";

/**
 * Controls which attachments are active for one render pass.
 */
export interface RenderTargetActivationOptions {
  /** Whether the depth aspect is read-only. Defaults to `false`. */
  depthReadOnly?: boolean;
  /** Whether configured color attachments participate in the pass. Defaults to `true`. */
  colorAttachments?: boolean;
}

/**
 * Off-screen rendering target specification.
 */
export interface IPlatformRenderTarget {
  /**
   * Set which face and mipLevel of the cube texture to render to.
   * @param mipLevel - Set mip level the data want to write
   * @param faceIndex - Cube texture face
   * @param options - Attachment state for this pass.
   */
  activeRenderTarget(mipLevel: number, faceIndex?: TextureCubeFace, options?: RenderTargetActivationOptions): void;

  /**
   * Blit FBO.
   */
  blitRenderTarget(): void;

  /**
   * Destroy render target.
   */
  destroy(): void;
}
