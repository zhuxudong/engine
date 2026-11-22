import { BlendFactor, BlendOperation, CompareFunction, CullMode, Engine, IPlatformShaderProgram, IPlatformShaderSource, IPlatformUniform, RenderStateElementKey, ShaderProperty, StencilOperation, SubPrimitive, Texture } from "@galacean/engine-core";
import type { IWebGPUShaderReflection, IWebGPUShaderUniformBlock, IWebGPUShaderTexture } from "@galacean/engine-design";
import type { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";
import { WebGPUPrimitive } from "./WebGPUPrimitive";
import type { Primitive, RenderTarget, RenderState } from "@galacean/engine-core";
import type { WebGPURenderTarget } from "./WebGPURenderTarget";
import type { WebGPUTexture } from "./WebGPUTexture";

interface BlockBinding { layout: IWebGPUShaderUniformBlock; point: number; dynamic: boolean; }
interface TextureBinding { layout: IWebGPUShaderTexture; value?: Texture; }
interface GroupBindings {
  blocks: BlockBinding[];
  textures: TextureBinding[];
  offsets: Uint32Array;
  entries: GPUBindGroupEntry[];
  cached?: GPUBindGroup;
  byBuffer?: WeakMap<GPUBuffer,GPUBindGroup>;
  recent?: { entries:GPUBindGroupEntry[]; group:GPUBindGroup }[];
}

/** Device modules and bind group layouts for one selected shader variant. */
export class WebGPUShaderProgram implements IPlatformShaderProgram {
  private static _counter = 0;
  readonly id = WebGPUShaderProgram._counter++;
  readonly attributeLocation: Record<string, number> = Object.create(null);
  readonly isValid = true;
  readonly uniforms: IPlatformUniform[] = [];
  readonly uniformBlockIds: number[] = [];
  readonly _groupLayouts: GPUBindGroupLayout[] = [];
  readonly reflection: IWebGPUShaderReflection;
  private readonly _groups: GroupBindings[] = [];
  private readonly _pipelines = new Map<string, GPURenderPipeline>();
  private readonly _states: { vertex: string; target: string; primitive: number; blend: number; front:number; back:number; masks:number; bias:number; slope:number; pipeline:GPURenderPipeline }[] = [];
  private readonly _pendingPipelines = new Map<string,Promise<void>>();
  private readonly _pipelineLayout: GPUPipelineLayout;
  private readonly _vertexModule: GPUShaderModule;
  private readonly _fragmentModule: GPUShaderModule;

  constructor(private readonly _graphicDevice: WebGPUGraphicDevice, engine: Engine, readonly _source: IPlatformShaderSource) {
    this.reflection = _source.reflection;
    if (!this.reflection) throw new Error("WebGPU shader requires compiled resource reflection.");
    const {device} = _graphicDevice;
    this._vertexModule = device.createShaderModule({label:"Galacean vertex",code:_source.vertexSource});
    this._fragmentModule = device.createShaderModule({label:"Galacean fragment",code:_source.fragmentSource});
    for (const input of this.reflection.vertexInputs) this.attributeLocation[input.name] = input.location;
    const arrays = new Map<string,{slots:TextureBinding[]; defaults:Texture[]}>();
    let dynamicLeft = device.limits.maxDynamicUniformBuffersPerPipelineLayout - (_source.feedbackVaryings?.length ? 1 : 0);
    for (let group = 0; group < 4; group++) {
      const entries: GPUBindGroupLayoutEntry[] = [];
      const blocks: BlockBinding[] = [];
      const textures: TextureBinding[] = [];
      let dynamicCount = 0;
      for (const layout of this.reflection.uniformBlocks.filter(b => b.group === group).sort((a,b) => a.binding-b.binding)) {
        const dynamic = dynamicLeft > 0;
        if (dynamic) { dynamicLeft--; dynamicCount++; }
        blocks.push({layout,point:layout.physicalBinding,dynamic});
        entries.push({binding:layout.binding, visibility:this._visibility(layout.visibility),buffer:{type:"uniform",hasDynamicOffset:dynamic,minBindingSize:layout.byteLength}});
      }
      for (const layout of this.reflection.textures) {
        if (layout.group !== group) continue;
        const res = engine._basicResources;
        const fallback = layout.viewDimension === "cube" ? res.whiteTextureCube : layout.viewDimension === "2d-array" ? res.whiteTexture2DArray : layout.sampleType === "uint" ? res.uintWhiteTexture2D : res.whiteTexture2D;
        const slot: TextureBinding = {layout, value:fallback};
        textures.push(slot);
        const index = (layout as IWebGPUShaderTexture & {arrayIndex?:number}).arrayIndex;
        if (index === undefined) {
          this.uniforms.push({name:layout.name,propertyId:ShaderProperty.getByName(layout.name)._uniqueId,isTexture:true,textureDefault:fallback,apply(value){ slot.value = value as Texture; }});
        } else {
          let array = arrays.get(layout.name);
          if (!array) {
            array = {slots:[],defaults:[]};
            arrays.set(layout.name,array);
            const {slots,defaults}=array;
            this.uniforms.push({name:layout.name,propertyId:ShaderProperty.getByName(layout.name)._uniqueId,isTexture:true,textureDefault:defaults,
              apply(value) {
                const input = value as Texture[];
                for (let i=0;i<slots.length;i++) if (slots[i]) slots[i].value=input?.[i] && !input[i].destroyed ? input[i] : defaults[i];
              }});
          }
          array.slots[index]=slot;
          array.defaults[index]=fallback;
        }
        const visibility = this._visibility(layout.visibility);
        entries.push({binding:layout.textureBinding,visibility,texture:{sampleType:layout.sampleType,viewDimension:layout.viewDimension}});
        if (layout.samplerBinding !== undefined) entries.push({binding:layout.samplerBinding,visibility:this._visibility(layout.samplerVisibility ?? layout.visibility),sampler:{type:layout.samplerType}});
      }
      const singleDynamic = dynamicCount === 1 && blocks.length === 1 && !textures.length;
      this._groups.push({blocks,textures,offsets:new Uint32Array(dynamicCount),entries:[],
        byBuffer:singleDynamic ? new WeakMap() : undefined,recent:entries.length && !singleDynamic ? [] : undefined});
      this._groupLayouts.push(device.createBindGroupLayout({entries}));
    }
    this._pipelineLayout = device.createPipelineLayout({bindGroupLayouts:this._groupLayouts});
  }

  bind(): boolean {
    if (this._graphicDevice._currentBindShaderProgram === this) return false;
    this._graphicDevice._currentBindShaderProgram = this;
    return true;
  }
  bindUniformBlock(name: string, binding: number): boolean {
    for (const group of this._groups) for (const block of group.blocks) {
      if (block.layout.bindingName === name) { block.point = binding; return true; }
    }
    return false;
  }
  destroy(): void { this._pipelines.clear(); this._groups.length = 0; }

  draw(primitive: WebGPUPrimitive, subPrimitive: SubPrimitive): void {
    const vertexState = primitive._getVertexState(this.reflection.vertexInputs);
    const pipeline = this._drawPipeline(primitive,subPrimitive,vertexState);
    const indexBuffer = primitive._prepareIndexBuffer(subPrimitive,vertexState);
    const pass = this._graphicDevice._getRenderPass();
    this._graphicDevice._setRenderPipeline(pass,pipeline);
    this._graphicDevice._applyDynamicState(pass);
    this._bindGroups(pass);
    primitive._encodeDraw(pass,subPrimitive,vertexState,indexBuffer);
  }

  _bindGroups(pass: GPUComputePassEncoder | GPURenderPassEncoder, count = 4): void {
    for (let index = 0; index < count; index++) {
      const group = this._groups[index];
      if (group.byBuffer) {
        const {point,layout}=group.blocks[0];
        const range=this._graphicDevice.uniformRanges[point];
        if (!range || range.size<layout.byteLength) throw new Error("Missing uniform buffer range for "+layout.bindingName);
        range.buffer._markUsed(range.offset,layout.byteLength);
        const buffer=range.buffer._gpuBuffer;
        let native=group.byBuffer.get(buffer);
        if (!native) {
          native=this._graphicDevice.device.createBindGroup({layout:this._groupLayouts[index],entries:[
            {binding:layout.binding,resource:{buffer,size:layout.byteLength}}
          ]});
          group.byBuffer.set(buffer,native);
        }
        group.offsets[0]=range.offset;
        this._graphicDevice._setBindGroup(pass,index,native,group.offsets);
        continue;
      }
      let dirty = !group.cached, i = 0, d = 0;
      for (const {layout,point,dynamic} of group.blocks) {
        const range = this._graphicDevice.uniformRanges[point];
        if (!range || range.size < layout.byteLength) throw new Error("Missing uniform buffer range for " + layout.bindingName);
        range.buffer._markUsed(range.offset,layout.byteLength);
        const offset = dynamic ? 0 : range.offset;
        if (dynamic) group.offsets[d++] = range.offset;
        let entry = group.entries[i++];
        const previous = entry?.resource as GPUBufferBinding;
        if (!previous || previous.buffer !== range.buffer._gpuBuffer || previous.offset !== offset) {
          group.entries[i-1] = {binding: layout.binding,resource:{buffer: range.buffer._gpuBuffer,offset,size:layout.byteLength}};
          dirty = true;
        }
      }
      for (const {layout,value} of group.textures) {
        const texture = value?._platformTexture as WebGPUTexture;
        const view = texture?.sampleView(layout.sampleType) ?? this._graphicDevice._fallbackView(layout);
        if (group.entries[i]?.resource !== view) {
          group.entries[i] = {binding:layout.textureBinding,resource:view}; dirty = true;
        }
        i++;
        if (layout.samplerBinding !== undefined) {
          const sampler = texture?.getSampler(layout.samplerType) ?? this._graphicDevice._fallbackSampler(layout.samplerType);
          if (group.entries[i]?.resource !== sampler) { group.entries[i] = {binding:layout.samplerBinding,resource:sampler}; dirty = true; }
          i++;
        }
      }
      if (dirty) group.cached = this._resolveGroup(index,group);
      this._graphicDevice._setBindGroup(pass,index,group.cached,group.offsets);
    }
  }

  private _resolveGroup(index:number, group:GroupBindings):GPUBindGroup {
    const recent=group.recent;
    if (recent) {
      for (let i=recent.length-1;i>=0;i--) {
        const entry=recent[i];
        let same=true;
        for(let j=0;j<entry.entries.length;j++) {
          const a=entry.entries[j].resource,b=group.entries[j].resource;
          if (a===b) continue;
          if (j < group.blocks.length) {
            const previous=a as GPUBufferBinding,current=b as GPUBufferBinding;
            if (previous.buffer===current.buffer && previous.offset===current.offset) continue;
          }
          same=false; break;
        }
        if (same) return entry.group;
      }
    }
    const native=this._graphicDevice.device.createBindGroup({layout:this._groupLayouts[index],entries:group.entries});
    if(recent) {
      if (recent.length===64) recent.shift();
      recent.push({entries:group.entries.slice(),group:native});
    }
    return native;
  }

  private _visibility(flags: number): number {
    return flags | (this._source.feedbackVaryings?.length && (flags & GPUShaderStage.VERTEX) ? GPUShaderStage.COMPUTE : 0);
  }

  /** Immutable pipeline fields fit into four small integer keys. Keep native descriptors off the draw path. */
  private _drawPipeline(mesh:WebGPUPrimitive,sub:SubPrimitive,vertex:ReturnType<WebGPUPrimitive["_getVertexState"]>):GPURenderPipeline {
    const driver=this._graphicDevice, target=driver._getAttachmentState();
    const {state,customStates:c,frontFaceInvert}=driver._getRenderState();
    const raster=state.rasterState, depth=state.depthState, blend=state.blendState.targetBlendState, stencil=state.stencilState;
    const cull=c?.[RenderStateElementKey.RasterStateCullMode] ?? raster.cullMode;
    const depthOn=c?.[RenderStateElementKey.DepthStateEnabled] ?? depth.enabled;
    const mask=c?.[RenderStateElementKey.BlendStateColorWriteMask0] ?? blend.colorWriteMask;
    const primitive = sub.topology | (((mesh.primitive.indexBufferBinding?.format ?? 0) & 3)<<3) | (+frontFaceInvert<<5) | (cull<<6) | (mask<<8) |
      (+depthOn<<12) | (+depth.writeEnabled<<13) | (depth.compareFunction<<14) | (+state.blendState.alphaToCoverage<<17);
    const blendKey=blend.enabled ? 1 | (blend.sourceColorBlendFactor<<1) | (blend.destinationColorBlendFactor<<5) |
      (blend.sourceAlphaBlendFactor<<9) | (blend.destinationAlphaBlendFactor<<13) | (blend.colorBlendOperation<<17) | (blend.alphaBlendOperation<<20) : 0;
    let front=0,back=0,masks=0;
    if (c?.[RenderStateElementKey.StencilStateEnabled] ?? stencil.enabled) {
      front=1 | ((c?.[RenderStateElementKey.StencilStateCompareFunctionFront] ?? stencil.compareFunctionFront)<<1) |
        ((c?.[RenderStateElementKey.StencilStatePassOperationFront] ?? stencil.passOperationFront)<<4) |
        ((c?.[RenderStateElementKey.StencilStateFailOperationFront] ?? stencil.failOperationFront)<<7) |
        ((c?.[RenderStateElementKey.StencilStateZFailOperationFront] ?? stencil.zFailOperationFront)<<10);
      back=(c?.[RenderStateElementKey.StencilStateCompareFunctionBack] ?? stencil.compareFunctionBack) |
        ((c?.[RenderStateElementKey.StencilStatePassOperationBack] ?? stencil.passOperationBack)<<3) |
        ((c?.[RenderStateElementKey.StencilStateFailOperationBack] ?? stencil.failOperationBack)<<6) |
        ((c?.[RenderStateElementKey.StencilStateZFailOperationBack] ?? stencil.zFailOperationBack)<<9);
      masks=((c?.[RenderStateElementKey.StencilStateMask] ?? stencil.mask)&255) |
        (((c?.[RenderStateElementKey.StencilStateWriteMask] ?? stencil.writeMask)&255)<<8);
    }
    const override=driver._getGlobalDepthBias();
    const bias=override.enabled ? override.bias:raster.depthBias, slope=override.enabled ? override.slopeBias:raster.slopeScaledDepthBias;
    const states=this._states;
    for (let i=states.length-1;i>=0;i--) {
      const s=states[i];
      if(s.primitive===primitive && s.blend===blendKey && s.front===front && s.back===back && s.masks===masks &&
         s.bias===bias && s.slope===slope && s.target===target.key && s.vertex===vertex.key) return s.pipeline;
    }
    const {key,descriptor}=this._pipelineDescriptor(mesh,sub,vertex,target,driver._getRenderState());
    let pipeline=this._pipelines.get(key);
    if (!pipeline) { pipeline=driver.device.createRenderPipeline(descriptor); this._pipelines.set(key,pipeline); }
    states.push({vertex:vertex.key,target:target.key,primitive,blend:blendKey,front,back,masks,bias,slope,pipeline});
    return pipeline;
  }

  prewarm(primitive: Primitive, sub: SubPrimitive, target: RenderTarget | null, state: RenderState, frontFaceInvert: boolean): Promise<void> {
    const webPrimitive = new WebGPUPrimitive(this._graphicDevice,primitive);
    const vertex = webPrimitive._getVertexState(this.reflection.vertexInputs);
    const attachment = this._graphicDevice._getAttachmentState(target ? target._platformRenderTarget as WebGPURenderTarget : null);
    const {key,descriptor} = this._pipelineDescriptor(webPrimitive,sub,vertex,attachment,{state,frontFaceInvert});
    if (this._pipelines.has(key)) return Promise.resolve();
    let pending = this._pendingPipelines.get(key);
    if (!pending) {
      pending = this._graphicDevice.device.createRenderPipelineAsync(descriptor).then(p => {
        this._pipelines.set(key,p);
      }).finally(() => this._pendingPipelines.delete(key));
      this._pendingPipelines.set(key,pending);
    }
    return pending;
  }

  private _pipelineDescriptor(
    primitive: WebGPUPrimitive,
    subPrimitive: SubPrimitive,
    vertexState: { buffers: Array<GPUVertexBufferLayout | null>; key: string },
    attachmentState = this._graphicDevice._getAttachmentState(),
    renderState = this._graphicDevice._getRenderState()
  ): {key: string; descriptor: GPURenderPipelineDescriptor} {
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
        entryPoint: this._source.vertexEntryPoint ?? "main",
        buffers: vertexState.buffers
      },
      fragment: {
        module: this._fragmentModule,
        entryPoint: this._source.fragmentEntryPoint ?? "main",
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
    return {key, descriptor};
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

}
