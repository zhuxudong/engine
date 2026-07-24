import { Engine, EngineConfiguration, Scene } from "@galacean/engine-core";
import { WebGPUCanvas } from "./WebGPUCanvas";
import { WebGPUGraphicDevice, WebGPUGraphicDeviceOptions } from "./WebGPUGraphicDevice";

/**
 * Galacean engine backed by WebGPU.
 */
export class WebGPUEngine extends Engine {
  /**
   * Create a WebGPU engine.
   * @param configuration - WebGPU engine configuration.
   * @returns Initialized WebGPU engine.
   */
  static async create(configuration: WebGPUEngineConfiguration): Promise<WebGPUEngine> {
    const canvas = WebGPUEngine._resolveCanvas(configuration.canvas);
    const webCanvas = new WebGPUCanvas(canvas);
    const graphicDevice = await WebGPUGraphicDevice.create(webCanvas, configuration.graphicDeviceOptions);

    try {
      const engine = new WebGPUEngine(webCanvas, graphicDevice, configuration);
      // @ts-ignore - Engine initialization is intentionally internal across RHI packages.
      await engine._initialize(configuration);
      engine.sceneManager.addScene(new Scene(engine, "DefaultScene"));
      return engine;
    } catch (error) {
      graphicDevice.destroy();
      throw error;
    }
  }

  /**
   * Web canvas.
   */
  override get canvas(): WebGPUCanvas {
    // @ts-ignore - Engine canvas storage is intentionally internal across RHI packages.
    return this._canvas as WebGPUCanvas;
  }

  private static _resolveCanvas(
    canvasOrId: HTMLCanvasElement | OffscreenCanvas | string
  ): HTMLCanvasElement | OffscreenCanvas {
    if (typeof canvasOrId !== "string") {
      return canvasOrId;
    }

    const canvas = document.getElementById(canvasOrId);
    if (!(canvas instanceof HTMLCanvasElement)) {
      throw new Error(`Canvas element "${canvasOrId}" was not found.`);
    }
    return canvas;
  }
}

/**
 * WebGPU engine configuration.
 */
export interface WebGPUEngineConfiguration extends EngineConfiguration {
  /** Canvas element or canvas id. */
  canvas: HTMLCanvasElement | OffscreenCanvas | string;
  /** WebGPU adapter, device, and canvas options. */
  graphicDeviceOptions?: WebGPUGraphicDeviceOptions;
}
