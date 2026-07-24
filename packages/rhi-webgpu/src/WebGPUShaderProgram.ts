import {
  BlendFactor,
  BlendOperation,
  CompareFunction,
  ConstantBufferBindingPoint,
  CullMode,
  Engine,
  type InstanceBufferLayout,
  RenderStateElementKey,
  ShaderProperty,
  StencilOperation,
  SubPrimitive,
  Texture
} from "@galacean/engine-core";
import type { IPlatformShaderProgram, IShaderReflection, IShaderResourceReflection } from "@galacean/engine-design";
import type { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";
import type { WebGPUPrimitive } from "./WebGPUPrimitive";
import type { WebGPUBuffer } from "./WebGPUBuffer";
import { WebGPUTexture } from "./WebGPUTexture";
import { WebGPUUniformFieldLayout, WebGPUUniformLayout } from "./WebGPUUniformLayout";

/**
 * WebGPU shader modules, resource layout, and lazy render-pipeline cache.
 * @internal
 */
export class WebGPUShaderProgram implements IPlatformShaderProgram {
  private static _counter = 0;

  readonly id = WebGPUShaderProgram._counter++;
  readonly attributeLocation: Record<string, GLint> = Object.create(null);
  readonly isValid = true;

  private readonly _graphicDevice: WebGPUGraphicDevice;
  private readonly _engine: Engine;
  private readonly _reflection: IShaderReflection;
  private readonly _vertexModule: GPUShaderModule;
  private readonly _fragmentModule: GPUShaderModule;
  private readonly _bindGroupLayout: GPUBindGroupLayout;
  private readonly _instanceBindGroupLayout?: GPUBindGroupLayout;
  private readonly _pipelineLayout: GPUPipelineLayout;
  private readonly _uniformLayout: WebGPUUniformLayout;
  private readonly _instanceLayout?: InstanceBufferLayout;
  private readonly _propertyValues: Record<number, unknown> = Object.create(null);
  private readonly _propertyIds = new Map<string, number>();
  private readonly _resourcePropertyIds = new Map<string, number>();
  private readonly _pipelines = new Map<string, GPURenderPipeline>();
  private readonly _bindGroups = new Map<string, GPUBindGroup>();

  private _uniformBuffer: GPUBuffer;
  private _uniformCapacity = 64;
  private _uniformStride = 0;
  private _uniformCursor = 0;
  private _uniformGeneration = 0;
  private _instanceBuffer: GPUBuffer;
  private _instanceBindGroup: GPUBindGroup;
  private _instanceCapacity = 1;
  private _instanceCursor = 0;
  private _instanceStride = 0;
  private _instanceBlockSize = 0;
  private _destroyed = false;

  constructor(
    graphicDevice: WebGPUGraphicDevice,
    engine: Engine,
    vertexSource: string,
    fragmentSource: string,
    reflection: IShaderReflection,
    instanceLayout?: InstanceBufferLayout | null
  ) {
    this._graphicDevice = graphicDevice;
    this._engine = engine;
    this._reflection = reflection;
    this._instanceLayout = instanceLayout ?? undefined;
    this._uniformLayout = new WebGPUUniformLayout(reflection);

    for (const input of reflection.vertexInputs) {
      this.attributeLocation[input.name] = input.location;
    }
    this._collectPropertyIds(this._uniformLayout.fields);
    for (const resource of reflection.resources) {
      this._resourcePropertyIds.set(
        resource.name,
        (ShaderProperty.getByName(resource.name) as ShaderPropertyInternal)._uniqueId
      );
    }

    const device = graphicDevice.device;
    this._vertexModule = device.createShaderModule({
      label: `ShaderProgram ${this.id} vertex`,
      code: vertexSource
    });
    this._fragmentModule = device.createShaderModule({
      label: `ShaderProgram ${this.id} fragment`,
      code: fragmentSource
    });
    this._reportCompilationErrors("vertex", this._vertexModule);
    this._reportCompilationErrors("fragment", this._fragmentModule);

    const entries: GPUBindGroupLayoutEntry[] = [];
    if (this._uniformLayout.byteLength > 0) {
      this._uniformStride = WebGPUShaderProgram._roundUp(
        graphicDevice.device.limits.minUniformBufferOffsetAlignment,
        this._uniformLayout.byteLength
      );
      this._uniformBuffer = this._createUniformBuffer(this._uniformCapacity);
      entries.push({
        binding: 0,
        visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
        buffer: {
          type: "uniform",
          hasDynamicOffset: true,
          minBindingSize: this._uniformLayout.byteLength
        }
      });
    }
    for (const resource of reflection.resources) {
      entries.push({
        binding: resource.textureBinding,
        visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
        texture: {
          sampleType: WebGPUShaderProgram._textureSampleType(resource.textureType),
          viewDimension: WebGPUShaderProgram._textureViewDimension(resource.textureType),
          multisampled: false
        }
      });
      entries.push({
        binding: resource.samplerBinding,
        visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
        sampler: {
          type: resource.comparison ? "comparison" : "filtering"
        }
      });
    }
    this._bindGroupLayout = device.createBindGroupLayout({
      label: `ShaderProgram ${this.id} resources`,
      entries
    });
    const bindGroupLayouts = [this._bindGroupLayout];
    if (this._instanceLayout) {
      this._instanceBlockSize = this._instanceLayout.instanceMaxCount * this._instanceLayout.structSize;
      this._instanceStride = WebGPUShaderProgram._roundUp(
        device.limits.minUniformBufferOffsetAlignment,
        this._instanceBlockSize
      );
      this._instanceBindGroupLayout = device.createBindGroupLayout({
        label: `ShaderProgram ${this.id} renderer instances`,
        entries: [
          {
            binding: 0,
            visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
            buffer: {
              type: "uniform",
              hasDynamicOffset: true,
              minBindingSize: this._instanceBlockSize
            }
          }
        ]
      });
      bindGroupLayouts.push(this._instanceBindGroupLayout);
    }
    this._pipelineLayout = device.createPipelineLayout({
      label: `ShaderProgram ${this.id} pipeline layout`,
      bindGroupLayouts
    });
  }

  uploadData(propertyValues: Readonly<Record<number, unknown>>): void {
    for (const key in propertyValues) {
      this._propertyValues[key] = propertyValues[key];
    }
  }

  bind(): boolean {
    return true;
  }

  destroy(): void {
    if (this._destroyed) {
      return;
    }
    this._destroyed = true;
    this._uniformBuffer?.destroy();
    this._instanceBuffer?.destroy();
    this._pipelines.clear();
    this._bindGroups.clear();
  }

  /** @internal */
  draw(primitive: WebGPUPrimitive, subPrimitive: SubPrimitive): void {
    if (this._destroyed) {
      throw new Error("Cannot draw with a destroyed WebGPU shader program.");
    }

    const graphicDevice = this._graphicDevice;
    const pass = graphicDevice._getRenderPass();
    const vertexState = primitive._getVertexState(this._reflection.vertexInputs);
    const pipeline = this._getPipeline(primitive, subPrimitive, vertexState);
    const { bindGroup, dynamicOffset } = this._getBindGroup();

    pass.setPipeline(pipeline);
    pass.setBindGroup(0, bindGroup, this._uniformLayout.byteLength > 0 ? [dynamicOffset] : []);
    if (this._instanceLayout) {
      const instanceBinding = this._getInstanceBinding();
      pass.setBindGroup(1, instanceBinding.bindGroup, [instanceBinding.dynamicOffset]);
    }
    graphicDevice._applyDynamicState(pass);
    primitive._encodeDraw(pass, subPrimitive);
    graphicDevice._useProgram(this);
  }

  /** @internal */
  _resetFrame(): void {
    this._uniformCursor = 0;
    this._instanceCursor = 0;
  }

  private _getPipeline(
    primitive: WebGPUPrimitive,
    subPrimitive: SubPrimitive,
    vertexState: { buffers: Array<GPUVertexBufferLayout | null>; key: string }
  ): GPURenderPipeline {
    const graphicDevice = this._graphicDevice;
    const attachmentState = graphicDevice._getAttachmentState();
    const renderState = graphicDevice._getRenderState();
    const primitiveState = {
      ...primitive._getPrimitiveState(subPrimitive.topology),
      frontFace: renderState.frontFaceInvert ? "cw" : "ccw",
      cullMode: WebGPUShaderProgram._cullMode(
        renderState.customStates?.[RenderStateElementKey.RasterStateCullMode] ?? renderState.state.rasterState.cullMode
      )
    } as GPUPrimitiveState;
    const targetBlendState = renderState.state.blendState.targetBlendState;
    const writeMask =
      renderState.customStates?.[RenderStateElementKey.BlendStateColorWriteMask0] ?? targetBlendState.colorWriteMask;
    const blend: GPUBlendState | undefined = targetBlendState.enabled
      ? {
          color: {
            operation: WebGPUShaderProgram._blendOperation(targetBlendState.colorBlendOperation),
            srcFactor: WebGPUShaderProgram._blendFactor(targetBlendState.sourceColorBlendFactor),
            dstFactor: WebGPUShaderProgram._blendFactor(targetBlendState.destinationColorBlendFactor)
          },
          alpha: {
            operation: WebGPUShaderProgram._blendOperation(targetBlendState.alphaBlendOperation),
            srcFactor: WebGPUShaderProgram._blendFactor(targetBlendState.sourceAlphaBlendFactor),
            dstFactor: WebGPUShaderProgram._blendFactor(targetBlendState.destinationAlphaBlendFactor)
          }
        }
      : undefined;
    const targets: GPUColorTargetState[] = attachmentState.colorFormats.map((format) => ({
      format,
      blend,
      writeMask
    }));
    const depthStencil = this._createDepthStencilState(attachmentState.depthStencilFormat, renderState);
    const descriptor: GPURenderPipelineDescriptor = {
      label: `ShaderProgram ${this.id} pipeline`,
      layout: this._pipelineLayout,
      vertex: {
        module: this._vertexModule,
        entryPoint: "main",
        buffers: vertexState.buffers
      },
      fragment: {
        module: this._fragmentModule,
        entryPoint: "main",
        targets
      },
      primitive: primitiveState,
      depthStencil,
      multisample: {
        count: attachmentState.sampleCount,
        alphaToCoverageEnabled: renderState.state.blendState.alphaToCoverage
      }
    };
    const key = [
      vertexState.key,
      JSON.stringify(primitiveState),
      attachmentState.key,
      JSON.stringify({
        blend,
        writeMask,
        depthStencil,
        alphaToCoverageEnabled: descriptor.multisample.alphaToCoverageEnabled
      })
    ].join("|");
    let pipeline = this._pipelines.get(key);
    if (!pipeline) {
      pipeline = graphicDevice.device.createRenderPipeline(descriptor);
      this._pipelines.set(key, pipeline);
    }
    return pipeline;
  }

  private _createDepthStencilState(
    format: GPUTextureFormat | undefined,
    renderState: ReturnType<WebGPUGraphicDevice["_getRenderState"]>
  ): GPUDepthStencilState | undefined {
    if (!format) {
      return undefined;
    }
    const depth = renderState.state.depthState;
    const depthEnabled = renderState.customStates?.[RenderStateElementKey.DepthStateEnabled] ?? depth.enabled;
    const stencil = renderState.state.stencilState;
    const stencilEnabled = renderState.customStates?.[RenderStateElementKey.StencilStateEnabled] ?? stencil.enabled;
    const hasStencil = format.includes("stencil");
    if (stencilEnabled && !hasStencil) {
      throw new Error(`Stencil rendering requires a stencil attachment, received ${format}.`);
    }

    const globalDepthBias = this._graphicDevice._getGlobalDepthBias();
    const descriptor: GPUDepthStencilState = {
      format,
      depthWriteEnabled: depthEnabled && depth.writeEnabled,
      depthCompare: depthEnabled ? WebGPUShaderProgram._compareFunction(depth.compareFunction) : "always",
      depthBias: Math.trunc(globalDepthBias.enabled ? globalDepthBias.bias : renderState.state.rasterState.depthBias),
      depthBiasSlopeScale: globalDepthBias.enabled
        ? globalDepthBias.slopeBias
        : renderState.state.rasterState.slopeScaledDepthBias
    };
    if (hasStencil) {
      descriptor.stencilReadMask = renderState.customStates?.[RenderStateElementKey.StencilStateMask] ?? stencil.mask;
      descriptor.stencilWriteMask =
        renderState.customStates?.[RenderStateElementKey.StencilStateWriteMask] ?? stencil.writeMask;
      descriptor.stencilFront = stencilEnabled
        ? {
            compare: WebGPUShaderProgram._compareFunction(
              renderState.customStates?.[RenderStateElementKey.StencilStateCompareFunctionFront] ??
                stencil.compareFunctionFront
            ),
            failOp: WebGPUShaderProgram._stencilOperation(
              renderState.customStates?.[RenderStateElementKey.StencilStateFailOperationFront] ??
                stencil.failOperationFront
            ),
            depthFailOp: WebGPUShaderProgram._stencilOperation(
              renderState.customStates?.[RenderStateElementKey.StencilStateZFailOperationFront] ??
                stencil.zFailOperationFront
            ),
            passOp: WebGPUShaderProgram._stencilOperation(
              renderState.customStates?.[RenderStateElementKey.StencilStatePassOperationFront] ??
                stencil.passOperationFront
            )
          }
        : {};
      descriptor.stencilBack = stencilEnabled
        ? {
            compare: WebGPUShaderProgram._compareFunction(
              renderState.customStates?.[RenderStateElementKey.StencilStateCompareFunctionBack] ??
                stencil.compareFunctionBack
            ),
            failOp: WebGPUShaderProgram._stencilOperation(
              renderState.customStates?.[RenderStateElementKey.StencilStateFailOperationBack] ??
                stencil.failOperationBack
            ),
            depthFailOp: WebGPUShaderProgram._stencilOperation(
              renderState.customStates?.[RenderStateElementKey.StencilStateZFailOperationBack] ??
                stencil.zFailOperationBack
            ),
            passOp: WebGPUShaderProgram._stencilOperation(
              renderState.customStates?.[RenderStateElementKey.StencilStatePassOperationBack] ??
                stencil.passOperationBack
            )
          }
        : {};
    }
    return descriptor;
  }

  private _getBindGroup(): { bindGroup: GPUBindGroup; dynamicOffset: number } {
    const entries: GPUBindGroupEntry[] = [];
    let dynamicOffset = 0;
    if (this._uniformLayout.byteLength > 0) {
      this._ensureUniformCapacity();
      dynamicOffset = this._uniformCursor++ * this._uniformStride;
      const data = this._packUniforms();
      this._graphicDevice.device.queue.writeBuffer(this._uniformBuffer, dynamicOffset, data);
      entries.push({
        binding: 0,
        resource: {
          buffer: this._uniformBuffer,
          offset: 0,
          size: this._uniformLayout.byteLength
        }
      });
    }

    const bindingKeys = [this._uniformGeneration.toString()];
    for (const resource of this._reflection.resources) {
      const texture = this._resolveTexture(resource);
      const platformTexture = (texture as TextureInternal)._platformTexture;
      platformTexture.setUseDepthCompareMode(resource.comparison);
      bindingKeys.push(platformTexture.bindingKey);
      entries.push({
        binding: resource.textureBinding,
        resource: platformTexture.view
      });
      entries.push({
        binding: resource.samplerBinding,
        resource: platformTexture.sampler
      });
    }

    const key = bindingKeys.join("|");
    let bindGroup = this._bindGroups.get(key);
    if (!bindGroup) {
      bindGroup = this._graphicDevice.device.createBindGroup({
        label: `ShaderProgram ${this.id} bind group`,
        layout: this._bindGroupLayout,
        entries
      });
      this._bindGroups.set(key, bindGroup);
    }
    return { bindGroup, dynamicOffset };
  }

  private _resolveTexture(resource: IShaderResourceReflection): Texture {
    const propertyId = this._resourcePropertyIds.get(resource.name);
    const value = this._propertyValues[propertyId] as Texture | undefined;
    if (value && !value.destroyed) {
      return value;
    }

    const engine = this._engine as EngineInternal;
    const basic = engine._basicResources;
    if (resource.comparison || resource.textureType.includes("depth")) {
      return engine._depthTexture2D;
    }
    if (resource.textureType.includes("cube")) {
      return basic.whiteTextureCube;
    }
    if (resource.textureType.includes("2d_array")) {
      return basic.whiteTexture2DArray;
    }
    if (resource.textureType.includes("<u32>")) {
      return basic.uintWhiteTexture2D;
    }
    return basic.whiteTexture2D;
  }

  private _getInstanceBinding(): { bindGroup: GPUBindGroup; dynamicOffset: number } {
    const source = this._graphicDevice._getConstantBuffer(ConstantBufferBindingPoint.RendererInstance);
    if (!source) {
      throw new Error("WebGPU renderer-instance buffer was not bound before drawing.");
    }
    this._ensureInstanceCapacity();
    const dynamicOffset = this._instanceCursor++ * this._instanceStride;
    const uploadedData = source._getUploadedData();
    if (uploadedData.byteLength > this._instanceBlockSize) {
      throw new Error(
        `Renderer-instance upload is ${uploadedData.byteLength} bytes, exceeding the ${this._instanceBlockSize}-byte shader layout.`
      );
    }
    if (uploadedData.byteLength > 0) {
      this._graphicDevice.device.queue.writeBuffer(
        this._instanceBuffer,
        dynamicOffset,
        uploadedData.buffer,
        uploadedData.byteOffset,
        uploadedData.byteLength
      );
    }
    return { bindGroup: this._instanceBindGroup, dynamicOffset };
  }

  private _ensureInstanceCapacity(): void {
    if (this._instanceBuffer && this._instanceCursor < this._instanceCapacity) {
      return;
    }
    const oldBuffer = this._instanceBuffer;
    if (oldBuffer) {
      this._instanceCapacity *= 2;
    }
    this._instanceBuffer = this._graphicDevice.device.createBuffer({
      label: `ShaderProgram ${this.id} renderer instances`,
      size: this._instanceStride * this._instanceCapacity,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
    });
    this._instanceBindGroup = this._graphicDevice.device.createBindGroup({
      label: `ShaderProgram ${this.id} renderer-instance bind group`,
      layout: this._instanceBindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: {
            buffer: this._instanceBuffer,
            offset: 0,
            size: this._instanceBlockSize
          }
        }
      ]
    });
    if (oldBuffer) {
      this._graphicDevice._retireBuffer(oldBuffer);
    }
  }

  private _packUniforms(): ArrayBuffer {
    const data = new ArrayBuffer(this._uniformLayout.byteLength);
    const view = new DataView(data);
    this._writeFields(view, this._uniformLayout.fields);
    return data;
  }

  private _writeFields(view: DataView, fields: readonly WebGPUUniformFieldLayout[]): void {
    for (const field of fields) {
      if (field.members) {
        if (field.arrayLength > 0) {
          throw new Error(`Arrays of uniform structs are not supported yet: ${field.propertyName}.`);
        }
        this._writeFields(view, field.members);
        continue;
      }

      const propertyId = this._propertyIds.get(field.propertyName);
      const value = this._propertyValues[propertyId];
      if (value == null || !field.native) {
        continue;
      }
      const components = WebGPUShaderProgram._components(value);
      const native = field.native;
      const elementCount = field.arrayLength || 1;
      const componentCount = native.columns * native.rows;
      for (let element = 0; element < elementCount; element++) {
        const elementOffset = field.offset + (field.arrayLength > 0 ? element * field.arrayStride : 0);
        for (let column = 0; column < native.columns; column++) {
          const columnStride = native.size / native.columns;
          for (let row = 0; row < native.rows; row++) {
            const sourceIndex = element * componentCount + column * native.rows + row;
            const targetOffset = elementOffset + column * columnStride + row * 4;
            WebGPUShaderProgram._writeScalar(view, targetOffset, native.scalar, components[sourceIndex] ?? 0);
          }
        }
      }
    }
  }

  private _collectPropertyIds(fields: readonly WebGPUUniformFieldLayout[]): void {
    for (const field of fields) {
      if (field.members) {
        this._collectPropertyIds(field.members);
      } else {
        this._propertyIds.set(
          field.propertyName,
          (ShaderProperty.getByName(field.propertyName) as ShaderPropertyInternal)._uniqueId
        );
      }
    }
  }

  private _ensureUniformCapacity(): void {
    if (this._uniformCursor < this._uniformCapacity) {
      return;
    }
    const oldBuffer = this._uniformBuffer;
    this._uniformCapacity *= 2;
    this._uniformBuffer = this._createUniformBuffer(this._uniformCapacity);
    this._uniformGeneration++;
    this._bindGroups.clear();
    this._graphicDevice._retireBuffer(oldBuffer);
  }

  private _createUniformBuffer(capacity: number): GPUBuffer {
    return this._graphicDevice.device.createBuffer({
      label: `ShaderProgram ${this.id} draw uniforms`,
      size: this._uniformStride * capacity,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
    });
  }

  private _reportCompilationErrors(stage: string, module: GPUShaderModule): void {
    module.getCompilationInfo().then((info) => {
      const errors = info.messages.filter((message) => message.type === "error");
      if (errors.length > 0 && !this._destroyed) {
        console.error(
          `WebGPU ${stage} shader ${this.id} failed:\n${errors
            .map((message) => `${message.lineNum}:${message.linePos} ${message.message}`)
            .join("\n")}`
        );
      }
    });
  }

  private static _components(value: unknown): ArrayLike<number> {
    if (typeof value === "number") {
      return [value];
    }
    if (Array.isArray(value) || ArrayBuffer.isView(value)) {
      return value as ArrayLike<number>;
    }
    const object = value as {
      elements?: ArrayLike<number>;
      x?: number;
      y?: number;
      z?: number;
      w?: number;
      r?: number;
      g?: number;
      b?: number;
      a?: number;
    };
    if (object.elements) {
      return object.elements;
    }
    return [object.x ?? object.r ?? 0, object.y ?? object.g ?? 0, object.z ?? object.b ?? 0, object.w ?? object.a ?? 0];
  }

  private static _writeScalar(
    view: DataView,
    offset: number,
    type: "f32" | "i32" | "u32" | "bool",
    value: number
  ): void {
    switch (type) {
      case "f32":
        view.setFloat32(offset, value, true);
        break;
      case "i32":
        view.setInt32(offset, value, true);
        break;
      case "u32":
      case "bool":
        view.setUint32(offset, type === "bool" ? (value ? 1 : 0) : value, true);
        break;
    }
  }

  private static _textureSampleType(type: string): GPUTextureSampleType {
    if (type.includes("depth")) {
      return "depth";
    }
    if (type.includes("<u32>")) {
      return "uint";
    }
    if (type.includes("<i32>")) {
      return "sint";
    }
    return "float";
  }

  private static _textureViewDimension(type: string): GPUTextureViewDimension {
    if (type.includes("cube_array")) {
      return "cube-array";
    }
    if (type.includes("cube")) {
      return "cube";
    }
    if (type.includes("2d_array")) {
      return "2d-array";
    }
    if (type.includes("3d")) {
      return "3d";
    }
    return "2d";
  }

  private static _blendFactor(factor: BlendFactor): GPUBlendFactor {
    return (
      [
        "zero",
        "one",
        "src",
        "one-minus-src",
        "dst",
        "one-minus-dst",
        "src-alpha",
        "one-minus-src-alpha",
        "dst-alpha",
        "one-minus-dst-alpha",
        "src-alpha-saturated",
        "constant",
        "one-minus-constant"
      ] as GPUBlendFactor[]
    )[factor];
  }

  private static _blendOperation(operation: BlendOperation): GPUBlendOperation {
    return (["add", "subtract", "reverse-subtract", "min", "max"] as GPUBlendOperation[])[operation];
  }

  private static _compareFunction(compare: CompareFunction): GPUCompareFunction {
    return (
      [
        "never",
        "less",
        "equal",
        "less-equal",
        "greater",
        "not-equal",
        "greater-equal",
        "always"
      ] as GPUCompareFunction[]
    )[compare];
  }

  private static _stencilOperation(operation: StencilOperation): GPUStencilOperation {
    return (
      [
        "keep",
        "zero",
        "replace",
        "increment-clamp",
        "decrement-clamp",
        "invert",
        "increment-wrap",
        "decrement-wrap"
      ] as GPUStencilOperation[]
    )[operation];
  }

  private static _cullMode(mode: CullMode): GPUCullMode {
    return mode === CullMode.Off ? "none" : mode === CullMode.Front ? "front" : "back";
  }

  private static _roundUp(alignment: number, value: number): number {
    return Math.ceil(value / alignment) * alignment;
  }
}

type ShaderPropertyInternal = ShaderProperty & {
  _uniqueId: number;
};

type TextureInternal = Texture & {
  _platformTexture: WebGPUTexture;
};

type EngineInternal = Engine & {
  _basicResources: {
    whiteTexture2D: Texture;
    whiteTextureCube: Texture;
    whiteTexture2DArray: Texture;
    uintWhiteTexture2D: Texture;
  };
  _depthTexture2D: Texture;
};
