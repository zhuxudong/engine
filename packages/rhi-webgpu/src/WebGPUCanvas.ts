import { Canvas } from "@galacean/engine-core";
import { Vector2 } from "@galacean/engine-math";

/**
 * Web canvas used by a WebGPU engine.
 */
export class WebGPUCanvas extends Canvas {
  /** @internal */
  readonly _webCanvas: HTMLCanvasElement | OffscreenCanvas;

  private readonly _scale = new Vector2();

  /**
   * Scale between the visible and rendering sizes.
   */
  get scale(): Vector2 {
    const canvas = this._webCanvas;
    if (typeof HTMLCanvasElement !== "undefined" && canvas instanceof HTMLCanvasElement) {
      this._scale.set(
        (canvas.clientWidth * devicePixelRatio) / canvas.width,
        (canvas.clientHeight * devicePixelRatio) / canvas.height
      );
    }
    return this._scale;
  }

  set scale(value: Vector2) {
    const canvas = this._webCanvas;
    if (typeof HTMLCanvasElement !== "undefined" && canvas instanceof HTMLCanvasElement) {
      canvas.style.transformOrigin = "left top";
      canvas.style.transform = `scale(${value.x}, ${value.y})`;
    }
  }

  /**
   * Create a web canvas wrapper.
   * @param canvas - Native canvas.
   */
  constructor(canvas: HTMLCanvasElement | OffscreenCanvas) {
    super();
    this._webCanvas = canvas;
    this.width = canvas.width;
    this.height = canvas.height;
  }

  /**
   * Resize the rendering size from the canvas client size.
   * @param pixelRatio - Device pixel ratio used for the rendering size.
   */
  resizeByClientSize(pixelRatio: number = globalThis.devicePixelRatio ?? 1): void {
    const canvas = this._webCanvas;
    if (typeof HTMLCanvasElement !== "undefined" && canvas instanceof HTMLCanvasElement) {
      this.width = canvas.clientWidth * pixelRatio;
      this.height = canvas.clientHeight * pixelRatio;
    }
  }

  /**
   * Set the visible-to-rendering scale.
   * @param x - Horizontal scale.
   * @param y - Vertical scale.
   */
  setScale(x: number, y: number): void {
    this._scale.set(x, y);
    this.scale = this._scale;
  }

  protected override _onWidthChanged(value: number): void {
    this._webCanvas.width = value;
  }

  protected override _onHeightChange(value: number): void {
    this._webCanvas.height = value;
  }
}
