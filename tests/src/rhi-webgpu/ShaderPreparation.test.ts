import {
  AssetType,
  Camera,
  Material,
  MeshRenderer,
  PrimitiveMesh,
  RenderTarget,
  Shader,
  Texture2D,
  TextureFormat,
  UnlitMaterial,
  WebGPUEngine,
  WebGPUGraphicDevice
} from "@galacean/engine-webgpu";
import { expect, it, vi } from "vitest";

it.skipIf(!navigator.gpu)("draws an older shaderc with a runtime macro on its first frame", async () => {
  const engine = await WebGPUEngine.create({ canvas: document.createElement("canvas") });
  const { device } = engine._hardwareRenderer as WebGPUGraphicDevice;
  const asset = {
    name: "Tests/Legacy",
    platformTarget: 0,
    subShaders: [
      {
        name: "Default",
        passes: [
          {
            name: "Forward",
            isUsePass: false,
            renderStates: { constantMap: {}, variableMap: {} },
            vertexShaderInstructions: [[0, "in vec3 POSITION; void main(){gl_Position=vec4(POSITION.xy,0.,1.);}"]],
            fragmentShaderInstructions: [
              [0, "uniform float oldTint; out vec4 c; void main(){c=vec4(oldTint*USER_STRENGTH,0.,0.,1.);}"]
            ]
          }
        ]
      }
    ]
  };
  const url = URL.createObjectURL(new Blob([JSON.stringify(asset)]));
  device.pushErrorScope("validation");
  try {
    const shader = await engine.resourceManager.load<Shader>({ url, type: AssetType.Shader });
    const root = engine.sceneManager.activeScene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    camera.entity.transform.setPosition(0, 0, 3);
    const texture = new Texture2D(engine, 16, 16, TextureFormat.R8G8B8A8_UNorm, false, false);
    camera.renderTarget = new RenderTarget(engine, 16, 16, texture, TextureFormat.Depth24Stencil8);
    const renderer = root.createChild().addComponent(MeshRenderer);
    renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    const material = new Material(engine, shader);
    renderer.setMaterial(material);
    material.shaderData.setFloat("oldTint", 0.5);
    material.shaderData.enableMacro("USER_STRENGTH", "2.0");
    camera.render();
    const bytes = new Uint8Array(4);
    await texture.getPixelBufferAsync(8, 8, 1, 1, bytes);
    expect([...bytes]).toEqual([255, 0, 0, 255]);
    expect(await device.popErrorScope()).toBeNull();
  } finally {
    URL.revokeObjectURL(url);
    engine.destroy();
  }
});

it.skipIf(!navigator.gpu)("reuses an asynchronously prepared mesh pipeline on its first camera draw", async () => {
  const engine = await WebGPUEngine.create({ canvas: document.createElement("canvas") });
  const { device } = engine._hardwareRenderer as WebGPUGraphicDevice;
  device.pushErrorScope("validation");
  try {
    const root = engine.sceneManager.activeScene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    camera.entity.transform.setPosition(0, 0, 3);
    const color = new Texture2D(engine, 16, 16, TextureFormat.R8G8B8A8_UNorm, false, false);
    const target = (camera.renderTarget = new RenderTarget(engine, 16, 16, color, TextureFormat.Depth24Stencil8));
    const renderer = root.createChild().addComponent(MeshRenderer);
    const mesh = (renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1));
    const material = new UnlitMaterial(engine);
    material.baseColor.set(1, 0, 0, 1);
    renderer.setMaterial(material);
    const pass = material.shader.subShaders[0].passes.find((p) => p.getTagValue("pipelineStage") === "Forward")!;
    const asynchronous = vi.spyOn(device, "createRenderPipelineAsync");
    await pass.preparePipeline(mesh, material, target, { camera, renderer });
    expect(asynchronous).toHaveBeenCalledTimes(1);
    const synchronous = vi.spyOn(device, "createRenderPipeline");
    camera.render();
    expect(synchronous).not.toHaveBeenCalled();
    const rgba = new Uint8Array(4);
    await color.getPixelBufferAsync(8, 8, 1, 1, rgba);
    expect([...rgba]).toEqual([255, 0, 0, 255]);
    expect(await device.popErrorScope()).toBeNull();
  } finally {
    vi.restoreAllMocks();
    engine.destroy();
  }
});

it.skipIf(!navigator.gpu)("prepares the forward attachments used by a camera rendering to the canvas", async () => {
  const engine = await WebGPUEngine.create({ canvas: document.createElement("canvas") });
  const { device } = engine._hardwareRenderer as WebGPUGraphicDevice;
  device.pushErrorScope("validation");
  try {
    const root = engine.sceneManager.activeScene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    camera.entity.transform.setPosition(0, 0, 3);
    // Scene and camera macros are active, but the final blit has exactly the baked shader and uniform layout.
    const translate = vi.spyOn(engine._webGPUShaderCompiler!, "compileWebGPUVariant");
    camera.render();
    expect(translate).not.toHaveBeenCalled();
    const renderer = root.createChild().addComponent(MeshRenderer);
    const mesh = (renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1));
    const material = new UnlitMaterial(engine);
    renderer.setMaterial(material);
    const pass = material.shader.subShaders[0].passes.find((p) => p.getTagValue("pipelineStage") === "Forward")!;
    const asynchronous = vi.spyOn(device, "createRenderPipelineAsync");
    await pass.preparePipeline(mesh, material, null, { camera, renderer });
    expect(translate).toHaveBeenCalled();
    expect(asynchronous).toHaveBeenCalledTimes(1);
    const synchronous = vi.spyOn(device, "createRenderPipeline");
    camera.render();
    expect(synchronous).not.toHaveBeenCalled();
    expect(await device.popErrorScope()).toBeNull();
  } finally {
    vi.restoreAllMocks();
    engine.destroy();
  }
});
