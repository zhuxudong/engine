import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  Buffer,
  BufferBindFlag,
  BufferUsage,
  Camera,
  CameraClearFlags,
  Color,
  CullMode,
  EngineEventType,
  IndexBufferBinding,
  IndexFormat,
  MeshRenderer,
  MeshTopology,
  ModelMesh,
  PrimitiveMesh,
  RenderState,
  RenderTarget,
  SetDataOptions,
  Texture2D,
  Texture2DArray,
  TextureCube,
  TextureCubeFace,
  TextureFormat,
  UnlitMaterial,
  Vector4,
  WebGPUEngine,
  WebGPUGraphicDevice
} from "@galacean/engine-webgpu";

/** These tests exercise real native encoders and read GPU results back through the engine. */
describe.skipIf(!navigator.gpu)("Native WebGPU rendering", () => {
  let canvas: HTMLCanvasElement;
  let engine: WebGPUEngine;
  let rhi: WebGPUGraphicDevice;

  beforeEach(async () => {
    canvas = document.createElement("canvas");
    document.body.appendChild(canvas);
    engine = await WebGPUEngine.create({ canvas });
    engine.canvas.setResolution(64, 64);
    rhi = engine._hardwareRenderer as WebGPUGraphicDevice;
    rhi.device.pushErrorScope("validation");
  });

  afterEach(async () => {
    try {
      if (!rhi) return;
      rhi.flush();
      expect((await rhi.device.popErrorScope())?.message).toBeUndefined();
    } finally {
      engine?.destroy();
      canvas.remove();
    }
  });

  it("renders a mesh into the expected upper quadrant and preserves it when another camera clears the right half", async () => {
    const scene = engine.sceneManager.activeScene;
    const root = scene.createRootEntity("root");
    const camera = root.createChild("camera").addComponent(Camera);
    camera.entity.transform.setPosition(0, 0, 4);
    const color = new Texture2D(engine, 64, 64, TextureFormat.R8G8B8A8_UNorm, false, false);
    const target = (camera.renderTarget = new RenderTarget(engine, 64, 64, color, TextureFormat.Depth24Stencil8));
    const object = root.createChild("red cube");
    object.transform.setPosition(-0.6, 0.6, 0);
    const renderer = object.addComponent(MeshRenderer);
    renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    const material = new UnlitMaterial(engine);
    material.baseColor.set(1, 0, 0, 1);
    renderer.setMaterial(material);
    scene.background.solidColor.set(0, 0, 1, 1);
    engine.update();
    const before = new Uint8Array(64 * 64 * 4);
    await color.getPixelBufferAsync(before);
    const at = (bytes: Uint8Array, x: number, y: number) =>
      Array.from(bytes.subarray((y * 64 + x) * 4, (y * 64 + x) * 4 + 4));
    expect(at(before, 18, 18)).toEqual([255, 0, 0, 255]);
    expect(at(before, 18, 46)).toEqual([0, 0, 255, 255]);

    const other = root.createChild("right camera").addComponent(Camera);
    other.renderTarget = target;
    other.viewport.set(0.5, 0, 0.5, 1);
    other.cullingMask = 0;
    scene.background.solidColor.set(0, 1, 0, 1);
    other.render();
    const after = new Uint8Array(before.length);
    await color.getPixelBufferAsync(after);
    for (let y = 0; y < 64; y++) {
      const row = y * 64 * 4;
      expect(after.subarray(row, row + 32 * 4)).toEqual(before.subarray(row, row + 32 * 4));
      expect(at(after, 32, y)).toEqual([0, 255, 0, 255]);
      expect(at(after, 63, y)).toEqual([0, 255, 0, 255]);
    }
  });

  it("keeps both draws when an external UInt8 index buffer and a uniform range are overwritten in one frame", async () => {
    const color = new Texture2D(engine, 8, 4, TextureFormat.R8G8B8A8_UNorm, false, false);
    const target = new RenderTarget(engine, 8, 4, color, null);
    const mesh = new ModelMesh(engine);
    const indices = new Buffer(engine, BufferBindFlag.IndexBuffer, new Uint8Array([0, 1, 2]), BufferUsage.Dynamic);
    mesh._primitive.setIndexBufferBinding(new IndexBufferBinding(indices, IndexFormat.UInt8));
    const sub = mesh.addSubMesh(0, 3, MeshTopology.Triangles);
    const program = rhi.createPlatformShaderProgram(engine, {
      vertexSource: `@vertex fn main(@builtin(vertex_index) i: u32) -> @builtin(position) vec4f {
        let p=vec2f(f32((i<<1u)&2u),f32(i&2u)); return vec4f(p*2.0-1.0,0.0,1.0);
      }`,
      fragmentSource:
        "@group(1) @binding(0) var<uniform> color:vec4f; @fragment fn main()->@location(0) vec4f { return color; }",
      reflection: {
        vertexInputs: [],
        vertexOutputs: [],
        fragmentOutputs: [0],
        textures: [],
        uniformBlocks: [
          {
            name: "Camera",
            bindingName: "Camera",
            physicalBinding: 2,
            group: 1,
            binding: 0,
            visibility: GPUShaderStage.FRAGMENT,
            byteLength: 16,
            members: []
          }
        ]
      }
    });
    const state = new RenderState();
    state.rasterState.cullMode = CullMode.Off;
    await program.prewarm!(mesh._primitive, sub, target, state, false);
    rhi.activeRenderTarget(target, new Vector4(0, 0, 1, 1), false);
    rhi.clearRenderTarget(engine, CameraClearFlags.Color, new Color(0, 0, 0, 1));
    rhi.applyRenderState(state, state, false);
    const uniform = new Buffer(engine, BufferBindFlag.ConstantBuffer, 256, BufferUsage.Dynamic);
    rhi.bindUniformBufferRange(2, uniform._platformBuffer, 0, 16, new Float32Array([1, 0, 0, 1]));
    rhi.viewport(0, 0, 4, 4);
    rhi.drawPrimitive(mesh._primitive, sub, program);
    indices.setData(new Uint8Array([2, 1, 0]));
    rhi.bindUniformBufferRange(2, uniform._platformBuffer, 0, 16, new Float32Array([0, 0, 1, 1]), true);
    rhi.viewport(4, 0, 4, 4);
    rhi.drawPrimitive(mesh._primitive, sub, program);
    rhi.scissor(3, 1, 2, 2);
    rhi.clearRenderTarget(engine, CameraClearFlags.Color, new Color(0, 1, 0, 1));
    const pixels = new Uint8Array(8 * 4 * 4);
    await color.getPixelBufferAsync(pixels);
    for (let y = 0; y < 4; y++)
      for (let x = 0; x < 8; x++) {
        const offset = (y * 8 + x) * 4;
        const expected =
          (x === 3 || x === 4) && (y === 1 || y === 2) ? [0, 255, 0, 255] : x < 4 ? [255, 0, 0, 255] : [0, 0, 255, 255];
        expect(Array.from(pixels.subarray(offset, offset + 4))).toEqual(expected);
      }
    program.destroy();
  });

  it("recycles submitted Discard backings while preserving earlier copies and clearing untouched bytes", async () => {
    const input = new Buffer(engine, BufferBindFlag.VertexBuffer, 8, BufferUsage.Dynamic);
    const snapshots = new Buffer(engine, BufferBindFlag.VertexBuffer, 16, BufferUsage.Dynamic);
    const allocations = vi.spyOn(rhi.device, "createBuffer");
    try {
      for (let frame = 0; frame < 3; frame++) {
        input.setData(new Uint8Array(8).fill(frame + 1));
        snapshots.copyFromBuffer(input, 0, 0, 8);
        input.setData(new Uint8Array([20 + frame]), 3, 0, 1, SetDataOptions.Discard);
        snapshots.copyFromBuffer(input, 0, 8, 8);
        if (frame) expect(allocations).not.toHaveBeenCalled();
        const result = new Uint8Array(16);
        await snapshots.getDataAsync(result);
        expect(Array.from(result)).toEqual([...Array(8).fill(frame + 1), 0, 0, 0, 20 + frame, 0, 0, 0, 0]);
        allocations.mockClear();
      }
    } finally {
      allocations.mockRestore();
    }
  });

  it("rebuilds live mesh, render target and shader resources after device loss", async () => {
    const scene = engine.sceneManager.activeScene;
    const root = scene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    camera.entity.transform.setPosition(0, 0, 3);
    const texture = new Texture2D(engine, 16, 16, TextureFormat.R8G8B8A8_UNorm, false, false);
    camera.renderTarget = new RenderTarget(engine, 16, 16, texture, TextureFormat.Depth24Stencil8);
    const renderer = root.createChild().addComponent(MeshRenderer);
    renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    const material = new UnlitMaterial(engine);
    material.baseColor.set(1, 0, 0, 1);
    renderer.setMaterial(material);
    camera.render();
    const pixels = new Uint8Array(16 * 16 * 4);
    await texture.getPixelBufferAsync(pixels);
    expect(Array.from(pixels.slice(544, 548))).toEqual([255, 0, 0, 255]);
    expect(await rhi.device.popErrorScope()).toBeNull();
    const lost = new Promise((resolve) => engine.once(EngineEventType.DeviceLost, resolve));
    const restored = new Promise((resolve) => engine.once(EngineEventType.DeviceRestored, resolve));
    const previous = rhi.device;
    engine.forceLoseDevice();
    await lost;
    engine.forceRestoreDevice();
    await restored;
    expect(rhi.device).not.toBe(previous);
    rhi.device.pushErrorScope("validation");
    material.baseColor.set(0, 1, 0, 1);
    camera.render();
    await texture.getPixelBufferAsync(pixels);
    expect(Array.from(pixels.slice(544, 548))).toEqual([0, 255, 0, 255]);
  });

  it("preserves GPU-produced neighboring bytes and copies only the requested array layer and cube face", async () => {
    const storage = new Buffer(engine, BufferBindFlag.StorageBuffer, 16, BufferUsage.Dynamic);
    rhi.dispatchCompute(
      `@group(0) @binding(0) var<storage,read_write> data:array<u32>;
      @compute @workgroup_size(1) fn main(@builtin(global_invocation_id) i:vec3u){data[i.x]=0x11223344u;}`,
      "main",
      [4, 1, 1],
      [{ binding: 0, buffer: storage._platformBuffer, access: "read_write" }]
    );
    storage.setData(new Uint8Array([0xaa, 0xbb]), 1);
    const bytes = new Uint8Array(8);
    await storage.getDataAsync(bytes);
    expect(Array.from(bytes)).toEqual([0x44, 0xaa, 0xbb, 0x11, 0x44, 0x33, 0x22, 0x11]);
    const layer = new Texture2DArray(engine, 3, 3, 2, TextureFormat.R8G8B8A8_UNorm, false, false);
    const cube = new TextureCube(engine, 3, TextureFormat.R8G8B8A8_UNorm, false, false);
    const data = Uint8Array.from({ length: 3 * 3 * 4 }, (_, i) => i);
    layer.setPixelBuffer(1, data, 0, 0, 0, 3, 3, 1);
    cube.setPixelBuffer(TextureCubeFace.PositiveX, data);
    const out = new Uint8Array(16);
    for (const read of [
      () => layer.getPixelBufferAsync(1, 1, 1, 2, 2, out),
      () => cube.getPixelBufferAsync(TextureCubeFace.PositiveX, 1, 1, 2, 2, out)
    ]) {
      await read();
      expect(Array.from(out)).toEqual([...data.slice(16, 24), ...data.slice(28, 36)]);
      out.fill(0);
    }
  });

  it("round trips packed colors, floats and compressed blocks across cubemap faces, array layers and mips", async () => {
    const formats = [
      [TextureFormat.R8G8B8_UNorm, new Uint8Array([0, 1, 2, 5, 8, 13, 21, 34, 55, 89, 144, 233])],
      [TextureFormat.R5G6B5_UNorm, new Uint16Array([0xf81f, 0x07e0, 0x7813, 0x1234])],
      [TextureFormat.R5G5B5A1_UNorm, new Uint16Array([0xffff, 0x8001, 0x6ea4, 0x4120])],
      [TextureFormat.R4G4B4A4_UNorm, new Uint16Array([0x0fd1, 0x4a6e, 0x0246, 0xac1f])],
      [TextureFormat.R16G16_SFloat, new Uint16Array([0x0000, 0x3400, 0x3800, 0x3c00, 0x4000, 0x4400, 0xbc00, 0xb800])],
      [TextureFormat.R32_SFloat, new Float32Array([0, 0.125, 1, -1.5])],
      [TextureFormat.R16_UNorm, new Uint16Array([0, 12345, 40960, 65535])]
    ] as const;
    for (const [format, data] of formats) {
      if (format === TextureFormat.R16_UNorm && !rhi.device.features.has("texture-formats-tier1")) {
        expect(rhi.supportsTextureFormat(format)).toBe(false);
        continue;
      }
      const cube = new TextureCube(engine, 4, format, true, false);
      const array = new Texture2DArray(engine, 4, 4, 3, format, true, false);
      cube.setPixelBuffer(TextureCubeFace.NegativeZ, data, 1);
      array.setPixelBuffer(2, data, 1, 0, 0, 2, 2, 1);
      const out = new Uint8Array(data.byteLength);
      const expected = new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
      await cube.getPixelBufferAsync(TextureCubeFace.NegativeZ, 1, out);
      expect(out).toEqual(expected);
      out.fill(0);
      await array.getPixelBufferAsync(2, 1, out);
      expect(out).toEqual(expected);
      cube.destroy();
      array.destroy();
    }
    const bc = rhi.device.features.has("texture-compression-bc");
    const etc = rhi.device.features.has("texture-compression-etc2");
    const astc = rhi.device.features.has("texture-compression-astc");
    if (bc || etc || astc) {
      const format = bc ? TextureFormat.BC1 : etc ? TextureFormat.ETC2_RGB : TextureFormat.ASTC_4x4;
      const bytes = Uint8Array.from({ length: format === TextureFormat.ASTC_4x4 ? 16 : 8 }, (_, i) => 7 + i);
      const compressed = new Texture2D(engine, 8, 8, format, true, false);
      compressed.setPixelBuffer(bytes, 2, 0, 0, 2, 2);
      const out = new Uint8Array(bytes.length);
      await compressed.getPixelBufferAsync(2, out);
      expect(out).toEqual(bytes);
    }
  });

  it("reuses stable render bundles and changes a later draw's dynamic offset without replaying stale state", async () => {
    const output = new Texture2D(engine, 8, 4, TextureFormat.R8G8B8A8_UNorm, false, false);
    const target = new RenderTarget(engine, 8, 4, output, null);
    const mesh = new ModelMesh(engine);
    const sub = mesh.addSubMesh(0, 3, MeshTopology.Triangles);
    const program = rhi.createPlatformShaderProgram(engine, {
      vertexSource: `@vertex fn main(@builtin(vertex_index) i:u32)->@builtin(position) vec4f {
        return vec4f(vec2f(f32((i<<1u)&2u),f32(i&2u))*2.0-1.0,0.0,1.0); }`,
      fragmentSource:
        "@group(0) @binding(0) var<uniform> color:vec4f; @fragment fn main()->@location(0) vec4f{return color;}",
      reflection: {
        vertexInputs: [],
        vertexOutputs: [],
        textures: [],
        fragmentOutputs: [0],
        uniformBlocks: [
          {
            name: "Scene",
            bindingName: "Scene",
            physicalBinding: 1,
            group: 0,
            binding: 0,
            visibility: GPUShaderStage.FRAGMENT,
            byteLength: 16,
            members: []
          }
        ]
      }
    });
    const stride = rhi.uniformBufferOffsetAlignment;
    const buffer = rhi.createPlatformBuffer(BufferBindFlag.ConstantBuffer, stride + 16, BufferUsage.Dynamic);
    buffer.setData(stride + 16, new Float32Array([1, 0, 0, 1]));
    buffer.setData(stride + 16, new Float32Array([0, 0, 1, 1]), stride);
    const state = new RenderState();
    state.rasterState.cullMode = CullMode.Off;
    const encode = vi.spyOn(GPUDevice.prototype, "createRenderBundleEncoder");
    const replay = vi.spyOn(GPURenderPassEncoder.prototype, "executeBundles");
    const bytes = new Uint8Array(8 * 4 * 4);
    try {
      for (let frame = 0; frame < 4; frame++) {
        rhi.activeRenderTarget(target, new Vector4(0, 0, 1, 1), false);
        rhi.clearRenderTarget(engine, CameraClearFlags.Color, new Color(0, 0, 0, 1));
        rhi.applyRenderState(state, state, false);
        rhi.bindUniformBufferRange(1, buffer, 0, 16);
        for (let i = 0; i < 164; i++) {
          if (i === 129) {
            rhi.scissor(4, 0, 4, 4);
            if (frame === 3) rhi.bindUniformBufferRange(1, buffer, stride, 16);
          }
          rhi.drawPrimitive(mesh._primitive, sub, program);
        }
        await output.getPixelBufferAsync(bytes);
        expect(Array.from(bytes.slice(0, 4))).toEqual([255, 0, 0, 255]);
        expect(Array.from(bytes.slice(28, 32))).toEqual(frame === 3 ? [0, 0, 255, 255] : [255, 0, 0, 255]);
        if (frame === 2) {
          expect(encode).not.toHaveBeenCalled();
          expect(replay).toHaveBeenCalled();
        }
        encode.mockClear();
        replay.mockClear();
      }
    } finally {
      encode.mockRestore();
      replay.mockRestore();
      program.destroy();
    }
  });

  it("binds a physical texture array and refreshes the exact sources after CPU uploads and render-target writes", async () => {
    const makeTexture = () => new Texture2D(engine, 4, 4, TextureFormat.R8G8B8A8_UNorm, true, false);
    const a = makeTexture(),
      b = makeTexture(),
      output = makeTexture();
    const target = new RenderTarget(engine, 4, 4, output, null),
      sourceTarget = new RenderTarget(engine, 4, 4, b, null);
    const solid = (r: number, g: number, b: number) =>
      new Uint8Array([r, g, b, 255, r, g, b, 255, r, g, b, 255, r, g, b, 255]);
    a.setPixelBuffer(solid(255, 0, 0), 1);
    b.setPixelBuffer(solid(0, 255, 0), 1);
    const mesh = new ModelMesh(engine),
      sub = mesh.addSubMesh(0, 3, MeshTopology.Triangles);
    const program = rhi.createPlatformShaderProgram(engine, {
      vertexSource: `@vertex fn main(@builtin(vertex_index) i:u32)->@builtin(position) vec4f {
        return vec4f(vec2f(f32((i<<1u)&2u),f32(i&2u))*2.0-1.0,0.0,1.0); }`,
      fragmentSource: `@group(2) @binding(0) var maps:texture_2d_array<f32>;
        @fragment fn main(@builtin(position) p:vec4f)->@location(0) vec4f {
          return textureLoad(maps,vec2i(0,0),select(0,1,p.x>=2.0),1); }`,
      reflection: {
        uniformBlocks: [],
        vertexInputs: [],
        vertexOutputs: [],
        fragmentOutputs: [0],
        textures: ["a", "b"].map((name, arrayLayer) => ({
          name,
          arrayLayer,
          group: 2,
          textureBinding: 0,
          visibility: 2,
          sampleType: "float",
          viewDimension: "2d-array"
        }))
      }
    });
    program.uniforms[0].apply(a);
    program.uniforms[1].apply(b);
    const state = new RenderState(),
      viewport = new Vector4(0, 0, 1, 1),
      pixels = new Uint8Array(64);
    state.rasterState.cullMode = CullMode.Off;
    for (let step = 0; step < 3; step++) {
      if (step === 1) a.setPixelBuffer(solid(0, 0, 255), 1);
      if (step === 2) {
        rhi.activeRenderTarget(sourceTarget, viewport, false, 1);
        rhi.clearRenderTarget(engine, CameraClearFlags.Color, new Color(1, 0, 1, 1));
      }
      rhi.activeRenderTarget(target, viewport, false);
      rhi.applyRenderState(state, state, false);
      rhi.drawPrimitive(mesh._primitive, sub, program);
      await output.getPixelBufferAsync(pixels);
      expect(Array.from(pixels.slice(0, 4))).toEqual(step ? [0, 0, 255, 255] : [255, 0, 0, 255]);
      expect(Array.from(pixels.slice(12, 16))).toEqual(step === 2 ? [255, 0, 255, 255] : [0, 255, 0, 255]);
    }
    program.destroy();
  });

  it("uploads and reads packed depth and stencil in a cubemap subregion without changing neighboring stencil bits", async () => {
    const texture = new TextureCube(engine, 8, TextureFormat.Depth24Stencil8, true, false);
    const face = TextureCubeFace.PositiveY;
    const original = new Uint32Array(16).fill(0xffffff81);
    texture.setPixelBuffer(face, original, 1);
    texture.setPixelBuffer(face, new Uint32Array([0x80000024, 0x00000040]), 1, 1, 2, 2, 1);
    const pixels = new Uint32Array(16);
    await texture.getPixelBufferAsync(face, 1, pixels);
    expect(Array.from(pixels)).toEqual(
      Array.from(original, (p, i) => (i === 9 ? 0x80000024 : i === 10 ? 0x00000040 : p))
    );
    await texture.makePixelBufferReadable(1, face);
    const region = new Uint32Array(2);
    texture.getPixelBuffer(face, 1, 2, 2, 1, 1, region);
    expect(Array.from(region)).toEqual([0x80000024, 0x00000040]);
  });

  it("resolves MSAA color and sampled depth into the selected cubemap face and mip", async () => {
    const color = new TextureCube(engine, 8, TextureFormat.R8G8B8A8_UNorm, true, false);
    const depth = new TextureCube(engine, 8, TextureFormat.Depth32, true, false);
    const target = new RenderTarget(engine, 8, 8, color, depth, 4);
    target.autoGenerateMipmaps = false;
    rhi.activeRenderTarget(target, new Vector4(0, 0, 1, 1), false, 1, TextureCubeFace.PositiveX);
    rhi.clearRenderTarget(engine, CameraClearFlags.All, new Color(0, 1, 1, 1));
    target._blitRenderTarget();
    const pixels = new Uint8Array(4 * 4 * 4),
      z = new Float32Array(16);
    await color.getPixelBufferAsync(TextureCubeFace.PositiveX, 1, pixels);
    expect(Array.from(pixels.slice(0, 4))).toEqual([0, 255, 255, 255]);
    await color.getPixelBufferAsync(TextureCubeFace.NegativeX, 1, pixels);
    expect(pixels.every((value) => value === 0)).toBe(true);
    await depth.getPixelBufferAsync(TextureCubeFace.PositiveX, 1, z);
    expect(z.every((value) => value === 1)).toBe(true);
  });
});
