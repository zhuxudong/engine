import { TextureCubeFace } from "../texture";

/**
 * Off-screen rendering target specification.
 */
export interface IPlatformRenderTarget {
  /**
   * Set which face and mipLevel of the cube texture to render to.
   * @param mipLevel - Set mip level the data want to write
   * @param faceIndex - Cube texture face
   * @param depthReadOnly - Whether the depth aspect is read-only for this pass.
   */
  activeRenderTarget(mipLevel: number, faceIndex?: TextureCubeFace, depthReadOnly?: boolean): void;

  /**
   * Blit FBO.
   */
  blitRenderTarget(): void;

  /**
   * Destroy render target.
   */
  destroy(): void;
}
