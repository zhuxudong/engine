import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  Buffer,
  BufferBindFlag,
  BufferUsage,
  Camera,
  MeshRenderer,
  MeshTopology,
  ModelMesh,
  RenderTarget,
  Texture2D,
  SetDataOptions,
  TextureFormat,
  UnlitMaterial,
  Vector3,
  VertexBufferBinding,
  WebGPUEngine,
  WebGPUGraphicDevice
} from "@galacean/engine-webgpu";

describe.skipIf(!navigator.gpu)("WebGPU compatibility inputs", () => {
  let engine: WebGPUEngine, hardware: WebGPUGraphicDevice;
  beforeEach(async () => {
    engine = await WebGPUEngine.create({ canvas: document.createElement("canvas") });
    hardware = engine._hardwareRenderer as WebGPUGraphicDevice;
    hardware.device.pushErrorScope("validation");
  });
  afterEach(async () => {
    try {
      hardware.flush();
      expect((await hardware.device.popErrorScope())?.message).toBeUndefined();
    } finally {
      engine.destroy();
    }
  });

  it("invalidates CPU data after GPU writes and synchronizes a partial discard with its native allocation", async () => {
    const buffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      new Uint8Array([1, 2, 3, 4, 5, 6, 7, 8]),
      BufferUsage.Dynamic,
      true
    );
    hardware.dispatchCompute(
      "@group(0) @binding(0) var<storage,read_write> data:array<u32>; @compute @workgroup_size(1) fn run(){data[0]=0x12345678u;}",
      "run",
      [1, 1, 1],
      [{ binding: 0, buffer: buffer._platformBuffer, access: "read_write" }]
    );
    const out = new Uint8Array(8);
    expect(() => buffer.getData(out)).toThrow(/getDataAsync/);
    buffer.setData(new Uint8Array([99]), 7);
    expect(buffer._readableData).toBeNull();
    await buffer.getDataAsync(out);
    expect([...out]).toEqual([0x78, 0x56, 0x34, 0x12, 5, 6, 7, 99]);
    buffer.setData(buffer.data!.subarray(4, 6), 1, 0, 2, SetDataOptions.Discard);
    buffer.getData(out);
    expect([...out]).toEqual([0, 5, 6, 0, 0, 0, 0, 0]);
    out.fill(77);
    await buffer.getDataAsync(out);
    expect([...out]).toEqual([0, 5, 6, 0, 0, 0, 0, 0]);
  });

  it("expands indexed fans and line loops from the selected submesh range and honors primitive restart", async () => {
    const root = engine.sceneManager.activeScene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    camera.entity.transform.setPosition(0, 0, 4);
    camera.isOrthographic = true;
    camera.orthographicSize = 2;
    const color = new Texture2D(engine, 48, 48, TextureFormat.R8G8B8A8_UNorm, false, false);
    camera.renderTarget = new RenderTarget(engine, 48, 48, color, TextureFormat.Depth24Stencil8);
    const mesh = new ModelMesh(engine);
    mesh.setPositions([new Vector3(-1, -1, 0), new Vector3(1, -1, 0), new Vector3(1, 1, 0), new Vector3(-1, 1, 0)]);
    const sub = mesh.addSubMesh(0, 0);
    const renderer = root.createChild().addComponent(MeshRenderer);
    renderer.mesh = mesh;
    const material = new UnlitMaterial(engine);
    material.baseColor.set(1, 0, 0, 1);
    renderer.setMaterial(material);
    async function render(indices: number[], mode: MeshTopology, start: number) {
      mesh.setIndices(new Uint16Array(indices));
      mesh.uploadData(false);
      sub.start = start;
      sub.count = indices.length - start;
      sub.topology = mode;
      engine.update();
      const pixels = new Uint8Array(48 * 48 * 4);
      await color.getPixelBufferAsync(pixels);
      return pixels;
    }
    const triangles = await render([0, 1, 2, 0, 2, 3], MeshTopology.Triangles, 0);
    const fan = await render([2, 0, 1, 2, 65535, 0, 2, 3], MeshTopology.TriangleFan, 1);
    expect(fan).toEqual(triangles);
    expect(fan.some((x, i) => !(i % 4) && x === 255)).toBe(true);
    const lines = await render([0, 1, 1, 2, 2, 0, 2, 3, 3, 2], MeshTopology.Lines, 0);
    const loop = await render([1, 0, 1, 2, 65535, 2, 3], MeshTopology.LineLoop, 1);
    expect(loop).toEqual(lines);
  });

  it("reads a prepared texture subregion synchronously and invalidates the snapshot after a write", async () => {
    const texture = new Texture2D(engine, 2, 2, TextureFormat.R8G8B8A8_UNorm, false, false);
    texture.setPixelBuffer(new Uint8Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]));
    await texture.makePixelBufferReadable();
    const output = new Uint8Array(10).fill(99);
    texture.getPixelBuffer(1, 0, 1, 2, output.subarray(1, 9));
    expect([...output]).toEqual([99, 5, 6, 7, 8, 13, 14, 15, 16, 99]);
    texture.setPixelBuffer(new Uint8Array([41, 42, 43, 44]), 0, 1, 0, 1, 1);
    expect(() => texture.getPixelBuffer(output)).toThrow(/getPixelBufferAsync/);
    await texture.makePixelBufferReadable();
    texture.getPixelBuffer(1, 0, 1, 1, output);
    expect([...output.subarray(0, 4)]).toEqual([41, 42, 43, 44]);
  });

  it("gathers each parent trajectory into the requested child slots without overwriting neighboring particles", async () => {
    const parent = new Float32Array(4 * 12);
    for (let i = 0; i < parent.length; i++) parent[i] = i + 0.5;
    const children = new Float32Array(7 * 6).fill(-2);
    const src = new VertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, parent), 48);
    const dst = new VertexBufferBinding(
      new Buffer(engine, BufferBindFlag.VertexBuffer, children, BufferUsage.Dynamic),
      24
    );
    const kernel = hardware.createFeedbackCompute();
    try {
      kernel.gather(src, dst, 1, 2, 2, 2);
      const result = new Float32Array(children.length);
      await dst.buffer.getDataAsync(result);
      const expected = children.slice();
      for (let j = 0; j < 4; j++) {
        const offset = (1 + (j >> 1)) * 12 + 6;
        expected.set(parent.subarray(offset, offset + 6), (2 + j) * 6);
      }
      expect(result).toEqual(expected);
    } finally {
      kernel.destroy();
    }
  });
});
