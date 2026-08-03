import type { GraphicsBackend } from "./GraphicsBackend";

/**
 * Origin used by render-target texture coordinates.
 */
export type RenderTargetOrigin = "lower-left" | "upper-left";

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

  // todo: implements
  [key: string]: any;
}
