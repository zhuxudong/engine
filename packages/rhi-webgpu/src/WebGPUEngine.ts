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
    const [deviceResult, configurationResult] = await Promise.allSettled([
      WebGPUGraphicDevice.create(canvas, configuration.graphicDeviceOptions),
      this._prepareConfiguration(configuration)
    ]);
    if (deviceResult.status === "rejected") throw deviceResult.reason;
    const device = deviceResult.value;
    if (configurationResult.status === "rejected") {
      device.destroy();
      throw configurationResult.reason;
    }
    const options = configurationResult.value;
    let engine: WebGPUEngine | undefined;
    try {
      engine = new this(canvas, device, options);
      canvas.setAutoResolution();
      return await engine._initialize(options);
    } catch (error) {
      if (engine) engine.destroy();
      else device.destroy();
      throw error;
    }
  }

  /** @internal Flavors can load their shader tools while the adapter and device are being requested. */
  protected static async _prepareConfiguration(
    configuration: WebGPUEngineConfiguration
  ): Promise<WebGPUEngineConfiguration> {
    return configuration;
  }

  override get canvas(): WebCanvas {
    return this._canvas as WebCanvas;
  }
}
