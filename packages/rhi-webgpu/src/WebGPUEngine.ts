import { Engine, EngineConfiguration, WebCanvas } from "@galacean/engine-core";
import { WebGPUGraphicDevice, WebGPUGraphicDeviceOptions } from "./WebGPUGraphicDevice";

export interface WebGPUEngineConfiguration extends EngineConfiguration {
  canvas: HTMLCanvasElement | OffscreenCanvas | string;
  graphicDeviceOptions?: WebGPUGraphicDeviceOptions;
}

/** Engine running on the browser's native WebGPU device. */
export class WebGPUEngine extends Engine {
  static async create(configuration: WebGPUEngineConfiguration): Promise<WebGPUEngine> {
    const native = configuration.canvas;
    const canvas = new WebCanvas(typeof native === "string" ? document.getElementById(native) : native);
    const device = await WebGPUGraphicDevice.create(canvas, configuration.graphicDeviceOptions);
    const engine = new this(canvas, device, configuration);
    canvas.setAutoResolution();
    try {
      return await engine._initialize(configuration);
    } catch (error) {
      engine.destroy();
      throw error;
    }
  }

  override get canvas(): WebCanvas {
    return this._canvas as WebCanvas;
  }
}
