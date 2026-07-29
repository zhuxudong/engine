import { Buffer, Camera, Texture, Texture2D, TextureFilterMode, TextureFormat, WebGPUEngine } from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { SurfaceDepthTiles } from "../../../src/surface/SurfaceDepthTiles";

interface NativeReadbackBuffer {
  mapAsync(mode: number): Promise<void>;
  getMappedRange(): ArrayBuffer;
  unmap(): void;
  destroy(): void;
}

interface NativeCommandEncoder {
  beginRenderPass(descriptor: {
    colorAttachments: unknown[];
    depthStencilAttachment: {
      view: unknown;
      depthClearValue: number;
      depthLoadOp: "clear";
      depthStoreOp: "store";
    };
  }): { end(): void };
  copyBufferToBuffer(
    source: unknown,
    sourceOffset: number,
    destination: NativeReadbackBuffer,
    destinationOffset: number,
    size: number
  ): void;
  finish(): unknown;
}

interface NativeDevice {
  createBuffer(descriptor: { size: number; usage: number }): NativeReadbackBuffer;
  createCommandEncoder(): NativeCommandEncoder;
  queue: { submit(commands: unknown[]): void };
}

const result = document.querySelector<HTMLPreElement>("#result")!;

try {
  const engine = await WebGPUEngine.create({
    canvas: document.querySelector<HTMLCanvasElement>("#canvas")!,
    shaderCompiler: new ShaderCompiler()
  });
  const camera = engine.sceneManager.activeScene.createRootEntity("camera").addComponent(Camera);
  const depthTiles = new SurfaceDepthTiles(engine, camera);
  const tileEdge = Math.ceil(Math.sqrt(engine.computeCapabilities.recommendedWorkgroupSizeX));
  const width = tileEdge * 2 + 1;
  const height = tileEdge + 1;
  const tilesX = Math.ceil(width / tileEdge);
  const tilesY = Math.ceil(height / tileEdge);
  const expected = new Array<number>(tilesX * tilesY).fill(0.625);
  const hardwareRenderer = (
    engine as unknown as {
      _hardwareRenderer: { device: NativeDevice; flush(): void };
    }
  )._hardwareRenderer;
  const device = hardwareRenderer.device;
  const depthTexture = new Texture2D(engine, width, height, TextureFormat.Depth24, false, false);
  depthTexture.filterMode = TextureFilterMode.Point;
  const nativeDepthTexture = (
    depthTexture as unknown as {
      _platformTexture: { _gpuTexture: { createView(): unknown } };
    }
  )._platformTexture._gpuTexture;
  const clearEncoder = device.createCommandEncoder();
  const clearPass = clearEncoder.beginRenderPass({
    colorAttachments: [],
    depthStencilAttachment: {
      view: nativeDepthTexture.createView(),
      depthClearValue: expected[0],
      depthLoadOp: "clear",
      depthStoreOp: "store"
    }
  });
  clearPass.end();
  device.queue.submit([clearEncoder.finish()]);
  (
    depthTiles as unknown as {
      _build(depthTexture: Texture): void;
    }
  )._build(depthTexture);
  hardwareRenderer.flush();

  const output = (
    depthTiles as unknown as {
      _outputBuffer: Buffer;
    }
  )._outputBuffer;
  const gpuConstants = globalThis as unknown as {
    GPUBufferUsage: { COPY_DST: number; MAP_READ: number };
    GPUMapMode: { READ: number };
  };
  const readback = device.createBuffer({
    size: expected.length * Uint32Array.BYTES_PER_ELEMENT,
    usage: gpuConstants.GPUBufferUsage.COPY_DST | gpuConstants.GPUBufferUsage.MAP_READ
  });
  const encoder = device.createCommandEncoder();
  encoder.copyBufferToBuffer(
    (output as unknown as { _platformBuffer: { _gpuBuffer: unknown } })._platformBuffer._gpuBuffer,
    0,
    readback,
    0,
    expected.length * Uint32Array.BYTES_PER_ELEMENT
  );
  device.queue.submit([encoder.finish()]);
  await readback.mapAsync(gpuConstants.GPUMapMode.READ);
  const depthBits = new Uint32Array(readback.getMappedRange().slice(0));
  const actual = Array.from(new Float32Array(depthBits.buffer));
  readback.unmap();
  readback.destroy();
  const maxError = Math.max(...actual.map((value, index) => Math.abs(value - expected[index])));
  result.textContent =
    maxError < 0.0001
      ? `PASS · ${tilesX}x${tilesY} tiles · max error ${maxError}`
      : `FAIL · expected ${expected.join(",")} · actual ${actual.join(",")}`;
} catch (error) {
  result.textContent = `ERROR · ${error instanceof Error ? error.stack : String(error)}`;
  console.error(error);
}
