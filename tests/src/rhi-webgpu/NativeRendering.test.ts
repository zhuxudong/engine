import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  Buffer, BufferBindFlag, BufferUsage, Camera, CameraClearFlags, Color, CullMode, EngineEventType, IndexBufferBinding,
  IndexFormat, MeshRenderer, MeshTopology, ModelMesh, PrimitiveMesh, RenderState, RenderTarget, Texture2D,
  Texture2DArray, TextureCube, TextureCubeFace, TextureFormat, UnlitMaterial, Vector4, WebGPUEngine, WebGPUGraphicDevice
} from "@galacean/engine-webgpu";

/** These tests exercise real native encoders and read GPU results back through the engine. */
describe.skipIf(!navigator.gpu)("Native WebGPU rendering", () => {
  let canvas: HTMLCanvasElement;
  let engine: WebGPUEngine;
  let rhi: WebGPUGraphicDevice;

  beforeEach(async () => {
    canvas = document.createElement("canvas");
    document.body.appendChild(canvas);
    engine = await WebGPUEngine.create({canvas});
    engine.canvas.setResolution(64,64);
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

  it("renders a mesh into the expected upper quadrant and preserves it when another camera clears the right half",async () => {
    const scene = engine.sceneManager.activeScene;
    const root = scene.createRootEntity("root");
    const camera = root.createChild("camera").addComponent(Camera);
    camera.entity.transform.setPosition(0,0,4);
    const color = new Texture2D(engine,64,64,TextureFormat.R8G8B8A8_UNorm,false,false);
    const target = camera.renderTarget = new RenderTarget(engine,64,64,color,TextureFormat.Depth24Stencil8);
    const object = root.createChild("red cube");
    object.transform.setPosition(-0.6,0.6,0);
    const renderer = object.addComponent(MeshRenderer);
    renderer.mesh = PrimitiveMesh.createCuboid(engine,1,1,1);
    const material = new UnlitMaterial(engine);
    material.baseColor.set(1,0,0,1);
    renderer.setMaterial(material);
    scene.background.solidColor.set(0,0,1,1);
    engine.update();
    const before = new Uint8Array(64*64*4);
    await color.getPixelBufferAsync(before);
    const at = (bytes:Uint8Array,x:number,y:number) => Array.from(bytes.subarray((y*64+x)*4,(y*64+x)*4+4));
    expect(at(before,18,18)).toEqual([255,0,0,255]);
    expect(at(before,18,46)).toEqual([0,0,255,255]);

    const other = root.createChild("right camera").addComponent(Camera);
    other.renderTarget = target;
    other.viewport.set(0.5,0,0.5,1);
    other.cullingMask = 0;
    scene.background.solidColor.set(0,1,0,1);
    other.render();
    const after = new Uint8Array(before.length);
    await color.getPixelBufferAsync(after);
    for (let y = 0; y < 64; y++) {
      const row = y*64*4;
      expect(after.subarray(row,row+32*4)).toEqual(before.subarray(row,row+32*4));
      expect(at(after,32,y)).toEqual([0,255,0,255]);
      expect(at(after,63,y)).toEqual([0,255,0,255]);
    }
  });

  it("keeps both draws when an external UInt8 index buffer and a uniform range are overwritten in one frame", async () => {
    const color = new Texture2D(engine,8,4,TextureFormat.R8G8B8A8_UNorm,false,false);
    const target = new RenderTarget(engine,8,4,color,null);
    const mesh = new ModelMesh(engine);
    const indices = new Buffer(engine,BufferBindFlag.IndexBuffer,new Uint8Array([0,1,2]),BufferUsage.Dynamic);
    mesh._primitive.setIndexBufferBinding(new IndexBufferBinding(indices,IndexFormat.UInt8));
    const sub = mesh.addSubMesh(0,3,MeshTopology.Triangles);
    const program = rhi.createPlatformShaderProgram(engine,{
      vertexSource:`@vertex fn main(@builtin(vertex_index) i: u32) -> @builtin(position) vec4f {
        let p=vec2f(f32((i<<1u)&2u),f32(i&2u)); return vec4f(p*2.0-1.0,0.0,1.0);
      }`,
      fragmentSource:"@group(1) @binding(0) var<uniform> color:vec4f; @fragment fn main()->@location(0) vec4f { return color; }",
      reflection:{vertexInputs:[],vertexOutputs:[],fragmentOutputs:[0],textures:[],uniformBlocks:[
        {name:"Camera",bindingName:"Camera",physicalBinding:2,group:1,binding:0,visibility:GPUShaderStage.FRAGMENT,byteLength:16,members:[]}
      ]}
    });
    const state = new RenderState();
    state.rasterState.cullMode = CullMode.Off;
    await program.prewarm!(mesh._primitive,sub,target,state,false);
    rhi.activeRenderTarget(target,new Vector4(0,0,1,1),false);
    rhi.clearRenderTarget(engine,CameraClearFlags.Color,new Color(0,0,0,1));
    rhi.applyRenderState(state,state,false);
    const uniform = new Buffer(engine,BufferBindFlag.ConstantBuffer,256,BufferUsage.Dynamic);
    rhi.bindUniformBufferRange(2,uniform._platformBuffer,0,16,new Float32Array([1,0,0,1]));
    rhi.viewport(0,0,4,4);
    rhi.drawPrimitive(mesh._primitive,sub,program);
    indices.setData(new Uint8Array([2,1,0]));
    rhi.bindUniformBufferRange(2,uniform._platformBuffer,0,16,new Float32Array([0,0,1,1]),true);
    rhi.viewport(4,0,4,4);
    rhi.drawPrimitive(mesh._primitive,sub,program);
    rhi.scissor(3,1,2,2);
    rhi.clearRenderTarget(engine,CameraClearFlags.Color,new Color(0,1,0,1));
    const pixels = new Uint8Array(8*4*4);
    await color.getPixelBufferAsync(pixels);
    for (let y=0;y<4;y++) for (let x=0;x<8;x++) {
      const offset = (y*8+x)*4;
      const expected = (x===3 || x===4) && (y===1 || y===2) ? [0,255,0,255] : x<4 ? [255,0,0,255] : [0,0,255,255];
      expect(Array.from(pixels.subarray(offset,offset+4))).toEqual(expected);
    }
    program.destroy();
  });

  it("rebuilds live mesh, render target and shader resources after device loss", async () => {
    const scene=engine.sceneManager.activeScene;
    const root=scene.createRootEntity();
    const camera=root.createChild().addComponent(Camera);
    camera.entity.transform.setPosition(0,0,3);
    const texture=new Texture2D(engine,16,16,TextureFormat.R8G8B8A8_UNorm,false,false);
    camera.renderTarget=new RenderTarget(engine,16,16,texture,TextureFormat.Depth24Stencil8);
    const renderer=root.createChild().addComponent(MeshRenderer);
    renderer.mesh=PrimitiveMesh.createCuboid(engine,1,1,1);
    const material=new UnlitMaterial(engine);
    material.baseColor.set(1,0,0,1);
    renderer.setMaterial(material);
    camera.render();
    const pixels=new Uint8Array(16*16*4);
    await texture.getPixelBufferAsync(pixels);
    expect(Array.from(pixels.slice(544,548))).toEqual([255,0,0,255]);
    expect(await rhi.device.popErrorScope()).toBeNull();
    const lost=new Promise(resolve=>engine.once(EngineEventType.DeviceLost,resolve));
    const restored=new Promise(resolve=>engine.once(EngineEventType.DeviceRestored,resolve));
    const previous=rhi.device;
    engine.forceLoseDevice();
    await lost;
    engine.forceRestoreDevice();
    await restored;
    expect(rhi.device).not.toBe(previous);
    rhi.device.pushErrorScope("validation");
    material.baseColor.set(0,1,0,1);
    camera.render();
    await texture.getPixelBufferAsync(pixels);
    expect(Array.from(pixels.slice(544,548))).toEqual([0,255,0,255]);
  });

  it("preserves GPU-produced neighboring bytes and copies only the requested array layer and cube face",async () => {
    const storage = new Buffer(engine,BufferBindFlag.StorageBuffer,16,BufferUsage.Dynamic);
    rhi.dispatchCompute(`@group(0) @binding(0) var<storage,read_write> data:array<u32>;
      @compute @workgroup_size(1) fn main(@builtin(global_invocation_id) i:vec3u){data[i.x]=0x11223344u;}`,
      "main",[4,1,1],[{binding:0,buffer:storage._platformBuffer,access:"read_write"}]);
    storage.setData(new Uint8Array([0xaa,0xbb]),1);
    const bytes=new Uint8Array(8);
    await storage.getDataAsync(bytes);
    expect(Array.from(bytes)).toEqual([0x44,0xaa,0xbb,0x11,0x44,0x33,0x22,0x11]);
    const layer=new Texture2DArray(engine,3,3,2,TextureFormat.R8G8B8A8_UNorm,false,false);
    const cube=new TextureCube(engine,3,TextureFormat.R8G8B8A8_UNorm,false,false);
    const data=Uint8Array.from({length:3*3*4},(_,i)=>i);
    layer.setPixelBuffer(1,data,0,0,0,3,3,1);
    cube.setPixelBuffer(TextureCubeFace.PositiveX,data);
    const out=new Uint8Array(16);
    for (const read of [
      () => layer.getPixelBufferAsync(1,1,1,2,2,out),
      () => cube.getPixelBufferAsync(TextureCubeFace.PositiveX,1,1,2,2,out)
    ]) {
      await read();
      expect(Array.from(out)).toEqual([...data.slice(16,24),...data.slice(28,36)]);
      out.fill(0);
    }
  });
});
