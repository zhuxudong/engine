import { beforeAll, describe, expect, it } from "vitest";
import { compileWebGPUShaderPass, createWebGPUShaderCompiler } from "@galacean/engine-shader-compiler/webgpu";
import * as assets from "@galacean/engine-shader/webgpu";
import { type IPrecompiledShader, type IWebGPUShaderCompiler, type IWebGPUShaderProgram } from "@galacean/engine-design";
import { AssetType, Camera, Material, MeshRenderer, PrimitiveMesh, RenderTarget, Shader, Texture2D, Vector4, WebGPUEngine } from "@galacean/engine-webgpu";

const vs = "void main() { gl_Position = vec4(0.0); }";
let compiler: IWebGPUShaderCompiler;
beforeAll(async () => { compiler = await createWebGPUShaderCompiler(); });

it("bakes both native stages and reflection in every built-in render pass", () => {
  const shaders = Object.entries(assets).filter(([key]) => key.endsWith("Source"));
  expect(shaders).toHaveLength(23);
  let passes = 0;
  for (const [, asset] of shaders) {
    const shader = asset as IPrecompiledShader;
    expect(shader.platformTarget).toBe(1);
    for (const group of shader.subShaders) for (const pass of group.passes) {
      if (pass.isUsePass) continue;
      expect(pass.wgsl?.vertex).toContain("@vertex");
      expect(pass.wgsl?.fragment).toContain("@fragment");
      expect(pass.vertexShaderInstructions?.length).toBeGreaterThan(0);
      passes++;
    }
  }
  expect(passes).toBe(27);
});

it("elides samplers for a texture fetched through two helper functions", () => {
  const fragment = `uniform sampler2D pixels;
    out vec4 color;
    vec4 load(sampler2D t) { return texelFetch(t, ivec2(0), 0); }
    vec4 loadIndirect(sampler2D t) { return load(t); }
    void main() { color = loadIndirect(pixels); }`;
  const { reflection, fragment: code } = compiler.compileWebGPUVariant(vs, fragment, {maxSamplersPerStage: 0});
  expect(reflection.textures).toHaveLength(1);
  expect(reflection.textures[0]).toMatchObject({name:"pixels", sampleType:"unfilterable-float"});
  expect(reflection.textures[0].samplerBinding).toBeUndefined();
  expect(code).toContain("textureLoad");
  expect(code).not.toMatch(/:\s*sampler\b/);
});

it("specializes integer vertex formats and float/depth sampling independently", () => {
  const vertex = "in vec4 JOINTS_0; void main() { gl_Position = JOINTS_0; }";
  const fragment = `uniform sampler2D colors; uniform sampler2DShadow shadow; out vec4 color;
    void main(){ color=texture(colors,vec2(0.5))*texture(shadow,vec3(0.5)); }`;
  const {vertex:code, reflection} = compiler.compileWebGPUVariant(vertex,fragment,{
    vertexInputTypes:{JOINTS_0:"uint"},unfilterableTextures:new Set(["colors"])
  });
  expect(reflection.vertexInputs[0]).toMatchObject({name:"JOINTS_0",type:"uint",components:4});
  expect(code).toContain("vec4<u32>");
  expect(reflection.textures.map(t=>[t.sampleType,t.samplerType])).toEqual([
    ["unfilterable-float","non-filtering"],["depth","comparison"]
  ]);
  expect(()=>compiler.compileWebGPUVariant(vertex,fragment,{maxSamplersPerStage:1})).toThrow(/sampler limit/);
});

it("preserves public leaf and array names when separating opaque struct resources", () => {
  const fragment=`struct Layer {sampler2D images[2]; vec4 tint;};
    uniform Layer material_layer; out vec4 color; const int INDEX=1;
    void main(){color=texture(material_layer.images[INDEX],vec2(0.5))*material_layer.tint;}`;
  const program=compiler.compileWebGPUVariant(vs,fragment);
  const reflected=program.reflection;
  expect(reflected.textures.map(t=>[t.name,t.arrayIndex,t.group])).toEqual([
    ["material_layer.images",0,2],["material_layer.images",1,2]
  ]);
  expect(reflected.uniformBlocks.flatMap(b=>b.members).map(m=>m.name)).toEqual(["material_layer.tint"]);
});

describe.skipIf(!navigator.gpu)("Native WGSL compatibility", () => {
  it("links every built-in pass with its default, lighting, joint texture, and instancing interfaces", async () => {
    const adapter=await navigator.gpu.requestAdapter();
    const device=await adapter!.requestDevice();
    const features: Record<string,string>[] = [
      {},
      { MATERIAL_HAS_BASETEXTURE:"",MATERIAL_HAS_NORMALTEXTURE:"",MATERIAL_HAS_EMISSIVETEXTURE:"",
        MATERIAL_HAS_OCCLUSION_TEXTURE:"",MATERIAL_HAS_ROUGHNESS_METALLIC_TEXTURE:"",RENDERER_HAS_UV:"",
        RENDERER_HAS_NORMAL:"",RENDERER_HAS_TANGENT:"",RENDERER_HAS_VERTEXCOLOR:"",SCENE_FOG_MODE:"1",
        SCENE_DIRECT_LIGHT_COUNT:"2",SCENE_POINT_LIGHT_COUNT:"2",SCENE_SPOT_LIGHT_COUNT:"1",SCENE_USE_SH:"",
        SCENE_USE_SPECULAR_ENV:"",RENDERER_IS_RECEIVE_SHADOWS:"",SCENE_SHADOW_CASCADED_COUNT:"4",SCENE_SHADOW_TYPE:"2",MATERIAL_NEED_WORLD_POS:"" },
      {RENDERER_HAS_SKIN:"",RENDERER_USE_JOINT_TEXTURE:"",RENDERER_JOINTS_NUM:"4",RENDERER_HAS_UV:"",RENDERER_HAS_NORMAL:"",MATERIAL_HAS_BASETEXTURE:""},
      {RENDERER_GPU_INSTANCE:"",RENDERER_HAS_UV:"",MATERIAL_HAS_BASETEXTURE:""}
    ];
    try {
      for(const [key,asset] of Object.entries(assets)) {
        if(!key.endsWith("Source"))continue;
        for(const group of (asset as IPrecompiledShader).subShaders) for(const pass of group.passes) {
          if(pass.isUsePass)continue;
          for(const [index,set] of features.entries()){
            const p=index?compileWebGPUShaderPass(compiler,pass,new Map(Object.entries(set))):pass.wgsl!;
            await validatePipeline(device,p,key+"."+pass.name+"."+index);
          }
        }
      }
    } finally {device.destroy();}
  },30000);
  it("preserves the camera tint and macro branches in a released alpha.59 instruction asset", async () => {
    const engine = await WebGPUEngine.create({canvas:document.createElement("canvas")});
    try {
      engine.canvas.setResolution(16,16);
      const url = new URL("/fixtures/shader-loader/released-alpha59.shaderc", location.origin).href;
      const shader = await engine.resourceManager.load<Shader>({url,type:AssetType.Shader});
      const scene = engine.sceneManager.activeScene;
      const camera = scene.createRootEntity().addComponent(Camera);
      camera.entity.transform.setPosition(0,0,3);
      camera.isOrthographic = true;
      camera.orthographicSize = 1;
      camera.shaderData.setVector4("camera_LegacyTint",new Vector4(1,0,1,1));
      const color = new Texture2D(engine,16,16,undefined,false);
      camera.renderTarget = new RenderTarget(engine,16,16,color);
      const renderer = scene.createRootEntity().addComponent(MeshRenderer);
      renderer.mesh = PrimitiveMesh.createCuboid(engine,1,1,1);
      const material = new Material(engine,shader);
      renderer.setMaterial(material);
      const pixel = new Uint8Array(4);
      camera.render();
      await color.getPixelBufferAsync(8,8,1,1,pixel);
      expect(Array.from(pixel)).toEqual([0,0,255,255]);
      material.shaderData.enableMacro("LEGACY_SHOW_TINT");
      camera.render();
      await color.getPixelBufferAsync(8,8,1,1,pixel);
      expect(Array.from(pixel)).toEqual([255,0,255,255]);
    } finally {engine.destroy();}
  });
});

async function validatePipeline(device:GPUDevice, p:IWebGPUShaderProgram, label:string):Promise<void>{
  const {reflection:r}=p;
  const groups: GPUBindGroupLayoutEntry[][]=[[],[],[],[]];
  for(const b of r.uniformBlocks)groups[b.group].push({binding:b.binding,visibility:b.visibility,buffer:{type:"uniform",minBindingSize:b.byteLength}});
  for(const t of r.textures){
    groups[t.group].push({binding:t.textureBinding,visibility:t.visibility,texture:{sampleType:t.sampleType,viewDimension:t.viewDimension}});
    if(t.samplerBinding!==undefined)groups[t.group].push({binding:t.samplerBinding,visibility:t.samplerVisibility??t.visibility,sampler:{type:t.samplerType}});
  }
  device.pushErrorScope("validation");
  const layout=device.createPipelineLayout({bindGroupLayouts:groups.map(entries=>device.createBindGroupLayout({entries}))});
  const inputs=r.vertexInputs.map(a=>({shaderLocation:a.location,offset:a.location*16,format:
    ((a.type==="float"?"float32":a.type==="sint"?"sint32":"uint32")+(a.components===1?"":"x"+a.components)) as GPUVertexFormat}));
  const vertex=device.createShaderModule({code:p.vertex,label});
  const fragment=device.createShaderModule({code:p.fragment,label});
  device.createRenderPipeline({label,layout,
    vertex:{module:vertex,entryPoint:p.vertexEntryPoint,buffers:inputs.length?[{arrayStride:(Math.max(...inputs.map(a=>a.shaderLocation))+1)*16,attributes:inputs}]:[]},
    fragment:{module:fragment,entryPoint:p.fragmentEntryPoint,targets:Array.from({length:Math.max(-1,...r.fragmentOutputs)+1},(_,i)=>r.fragmentOutputs.includes(i)?{format:"rgba8unorm"}:null)},
    depthStencil:{format:"depth24plus",depthWriteEnabled:true,depthCompare:"less"}
  });
  expect((await device.popErrorScope())?.message,label).toBeUndefined();
}
