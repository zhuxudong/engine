import { expect, it } from "vitest";
import { compileWebGPUShaderPass, createWebGPUShaderCompiler } from "@galacean/engine-shader-compiler/webgpu";

it.skipIf(!navigator.gpu)("writes distinct struct members and keeps a GLSL local named textureDimensions", async () => {
  const compiler = await createWebGPUShaderCompiler();
  const program = compiler.compileWebGPUVariant(
    "void main(){ int i=gl_VertexID; gl_Position=vec4(vec2((i<<1)&2,i&2)*2.0-1.0,0.0,1.0); }",
    `struct Lighting {vec3 diffuse; vec3 specular;};
    uniform sampler2D scene_image; out vec4 color;
    void light(float energy, inout vec3 a, out vec3 b) { a += vec3(energy,0.,0.); b=vec3(0.,2.*energy,0.); }
    void main() {
      ivec2 textureDimensions=textureSize(scene_image,0);
      Lighting result; result.diffuse=vec3(0.);
      light(float(textureDimensions.x)/3.,result.diffuse,result.specular);
      color=vec4(result.diffuse+result.specular+vec3(0.,0.,1.),1.);
    }`
  );
  const device = await (await navigator.gpu.requestAdapter())!.requestDevice();
  try {
    const pipeline = await device.createRenderPipelineAsync({
      layout: "auto",
      vertex: { module: device.createShaderModule({ code: program.vertex }) },
      fragment: { module: device.createShaderModule({ code: program.fragment }), targets: [{ format: "rgba8unorm" }] }
    });
    const texture = device.createTexture({
      size: [1, 1],
      format: "rgba8unorm",
      usage: GPUTextureUsage.TEXTURE_BINDING
    });
    const target = device.createTexture({
      size: [1, 1],
      format: "rgba8unorm",
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC
    });
    const read = device.createBuffer({ size: 4, usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST });
    const binding = program.reflection.textures[0];
    const group = device.createBindGroup({
      layout: pipeline.getBindGroupLayout(binding.group),
      entries: [{ binding: binding.textureBinding, resource: texture.createView() }]
    });
    const encoder = device.createCommandEncoder();
    const render = encoder.beginRenderPass({
      colorAttachments: [{ view: target.createView(), loadOp: "clear", storeOp: "store", clearValue: [0, 0, 0, 0] }]
    });
    render.setPipeline(pipeline);
    render.setBindGroup(binding.group, group);
    render.draw(3);
    render.end();
    encoder.copyTextureToBuffer({ texture: target }, { buffer: read }, [1, 1]);
    device.queue.submit([encoder.finish()]);
    await read.mapAsync(GPUMapMode.READ);
    expect([...new Uint8Array(read.getMappedRange())]).toEqual([85, 170, 255, 255]);
    read.unmap();
  } finally {
    device.destroy();
  }
});

it.skipIf(!navigator.gpu)("specializes raw Text directives and samples the base mip in vertex shaders", async () => {
  const compiler = await createWebGPUShaderCompiler();
  const source = `#version 300 es
    #define SAMPLE(T, UV) texture(T, UV)
    /* An inactive directive inside a comment must not change the program.
    #define SAMPLE(T, UV) invalid
    */
    #if defined(FIELD)
      uniform sampler2D field;
      #define OFFSET ivec2(0)
      void main() { gl_Position = SAMPLE(field, vec2(0.5)) + textureOffset(field, vec2(0.5), OFFSET); }
    #else
      void main() { gl_Position = vec4(1.0); }
    #endif`;
  const pass = {
    vertexShaderInstructions: [[0, source] as const],
    fragmentShaderInstructions: [[0, "void main(){}"] as const]
  };
  const on = compileWebGPUShaderPass(compiler, pass, new Map([["FIELD", ""]]));
  const off = compileWebGPUShaderPass(compiler, pass);
  expect(on.vertex).toContain("textureSampleLevel");
  expect(on.reflection.textures.map((t) => t.name)).toEqual(["field"]);
  expect(off.reflection.textures).toHaveLength(0);
  const device = await (await navigator.gpu.requestAdapter())!.requestDevice();
  try {
    const module = device.createShaderModule({ code: on.vertex });
    expect((await module.getCompilationInfo()).messages.filter((message) => message.type === "error")).toEqual([]);
    await device.createRenderPipelineAsync({
      layout: "auto",
      vertex: { module },
      primitive: { topology: "point-list" },
      depthStencil: { format: "depth24plus", depthCompare: "always", depthWriteEnabled: true }
    });
  } finally {
    device.destroy();
  }
});
