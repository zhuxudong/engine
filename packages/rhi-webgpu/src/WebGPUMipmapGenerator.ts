/**
 * Generates mip chains for renderable, filterable WebGPU textures.
 * @internal
 */
export class WebGPUMipmapGenerator {
  private readonly _device: GPUDevice;
  private readonly _sampler: GPUSampler;
  private readonly _bindGroupLayout: GPUBindGroupLayout;
  private readonly _pipelineLayout: GPUPipelineLayout;
  private readonly _vertexModule: GPUShaderModule;
  private readonly _fragmentModule: GPUShaderModule;
  private readonly _pipelines = new Map<GPUTextureFormat, GPURenderPipeline>();

  constructor(device: GPUDevice) {
    this._device = device;
    this._sampler = device.createSampler({
      minFilter: "linear",
      magFilter: "linear"
    });
    this._bindGroupLayout = device.createBindGroupLayout({
      label: "Galacean mipmap bind group layout",
      entries: [
        {
          binding: 0,
          visibility: GPUShaderStage.FRAGMENT,
          texture: { sampleType: "float", viewDimension: "2d" }
        },
        {
          binding: 1,
          visibility: GPUShaderStage.FRAGMENT,
          sampler: { type: "filtering" }
        }
      ]
    });
    this._pipelineLayout = device.createPipelineLayout({
      label: "Galacean mipmap pipeline layout",
      bindGroupLayouts: [this._bindGroupLayout]
    });

    // This is a backend-private copy operation, not an alternate source for a
    // user shader. ShaderLab remains the only source for material shaders.
    this._vertexModule = device.createShaderModule({
      label: "Galacean mipmap vertex",
      code: `
        struct VertexOutput {
          @builtin(position) position: vec4f,
          @location(0) uv: vec2f
        }

        @vertex
        fn main(@builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
          var output: VertexOutput;
          let uv = vec2f(
            f32((vertexIndex << 1u) & 2u),
            f32(vertexIndex & 2u)
          );
          output.position = vec4f(uv * vec2f(2.0, -2.0) + vec2f(-1.0, 1.0), 0.0, 1.0);
          output.uv = uv;
          return output;
        }
      `
    });
    this._fragmentModule = device.createShaderModule({
      label: "Galacean mipmap fragment",
      code: `
        @group(0) @binding(0) var sourceTexture: texture_2d<f32>;
        @group(0) @binding(1) var sourceSampler: sampler;

        @fragment
        fn main(@location(0) uv: vec2f) -> @location(0) vec4f {
          return textureSample(sourceTexture, sourceSampler, uv);
        }
      `
    });
  }

  generate(
    texture: GPUTexture,
    format: GPUTextureFormat,
    width: number,
    height: number,
    mipLevelCount: number,
    layerCount: number
  ): void {
    if (mipLevelCount <= 1) {
      return;
    }
    if (!WebGPUMipmapGenerator._isSupportedFormat(format)) {
      throw new Error(`WebGPU mipmap generation does not support ${format}.`);
    }

    const pipeline = this._getPipeline(format);
    const encoder = this._device.createCommandEncoder({
      label: "Galacean mipmap generation"
    });
    for (let layer = 0; layer < layerCount; layer++) {
      for (let mipLevel = 1; mipLevel < mipLevelCount; mipLevel++) {
        const sourceView = texture.createView({
          dimension: "2d",
          baseMipLevel: mipLevel - 1,
          mipLevelCount: 1,
          baseArrayLayer: layer,
          arrayLayerCount: 1
        });
        const destinationView = texture.createView({
          dimension: "2d",
          baseMipLevel: mipLevel,
          mipLevelCount: 1,
          baseArrayLayer: layer,
          arrayLayerCount: 1
        });
        const bindGroup = this._device.createBindGroup({
          label: `Galacean mipmap layer ${layer} level ${mipLevel}`,
          layout: this._bindGroupLayout,
          entries: [
            { binding: 0, resource: sourceView },
            { binding: 1, resource: this._sampler }
          ]
        });
        const pass = encoder.beginRenderPass({
          label: `Galacean mipmap layer ${layer} level ${mipLevel}`,
          colorAttachments: [
            {
              view: destinationView,
              loadOp: "clear",
              storeOp: "store",
              clearValue: { r: 0, g: 0, b: 0, a: 0 }
            }
          ]
        });
        pass.setPipeline(pipeline);
        pass.setBindGroup(0, bindGroup);
        pass.setViewport(0, 0, Math.max(1, width >> mipLevel), Math.max(1, height >> mipLevel), 0, 1);
        pass.draw(3);
        pass.end();
      }
    }
    this._device.queue.submit([encoder.finish()]);
  }

  private _getPipeline(format: GPUTextureFormat): GPURenderPipeline {
    let pipeline = this._pipelines.get(format);
    if (!pipeline) {
      pipeline = this._device.createRenderPipeline({
        label: `Galacean mipmap ${format}`,
        layout: this._pipelineLayout,
        vertex: {
          module: this._vertexModule,
          entryPoint: "main"
        },
        fragment: {
          module: this._fragmentModule,
          entryPoint: "main",
          targets: [{ format }]
        },
        primitive: { topology: "triangle-list" }
      });
      this._pipelines.set(format, pipeline);
    }
    return pipeline;
  }

  private static _isSupportedFormat(format: GPUTextureFormat): boolean {
    return (
      format === "r8unorm" ||
      format === "rg8unorm" ||
      format === "rgba8unorm" ||
      format === "rgba8unorm-srgb" ||
      format === "rgba16float" ||
      format === "rg11b10ufloat"
    );
  }
}
