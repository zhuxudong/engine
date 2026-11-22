import { BufferBindFlag, BufferUsage, CameraClearFlags, Canvas, Engine, GLCapabilityType, IHardwareRenderer, IPlatformBuffer, IPlatformRenderTarget, IPlatformShaderProgram, IPlatformShaderSource, IPlatformPrimitive, IPlatformTexture2D, IPlatformTexture2DArray, IPlatformTextureCube, Primitive, RenderState, RenderStateElementKey, RenderTarget, SetDataOptions, SubPrimitive, Texture2D, Texture2DArray, TextureCube, TextureFormat, WebCanvas } from "@galacean/engine-core";
import { RenderBufferLoadAction, RenderBufferStoreAction } from "@galacean/engine-core";
import { WebGPUTexture } from "./WebGPUTexture";
import { WebGPUAttachmentOps } from "./WebGPUAttachmentOps";
import { WebGPUFeedbackKernel } from "./WebGPUFeedbackKernel";
import type { IWebGPUShaderTexture } from "@galacean/engine-design";
import { Color, Vector4 } from "@galacean/engine-math";
import { WebGPUBuffer } from "./WebGPUBuffer";
import { WebGPUCapability } from "./WebGPUCapability";
import { WebGPUMipmapGenerator } from "./WebGPUMipmapGenerator";
import { WebGPUPrimitive } from "./WebGPUPrimitive";
import { WebGPURenderTarget } from "./WebGPURenderTarget";
import { WebGPUShaderProgram } from "./WebGPUShaderProgram";
import { WebGPUTexture2D } from "./WebGPUTexture2D";
import { WebGPUTexture2DArray } from "./WebGPUTexture2DArray";
import { WebGPUTextureCube } from "./WebGPUTextureCube";
import { WebGPUTimingProfiler } from "./WebGPUTimingProfiler";

/**
 * Options used to request and configure a WebGPU device.
 */
export interface WebGPUGraphicDeviceOptions {
  /** Adapter power preference. */
  powerPreference?: GPUPowerPreference;
  /** Force a software or fallback adapter when the browser supports it. */
  forceFallbackAdapter?: boolean;
  /** Required optional WebGPU features. */
  requiredFeatures?: GPUFeatureName[];
  /** Required WebGPU limits. */
  requiredLimits?: Record<string, GPUSize64>;
  /** Request optional non-blocking GPU timestamp collection. */
  enableGPUTiming?: boolean;
  /** Canvas alpha compositing mode. */
  alphaMode?: GPUCanvasAlphaMode;
  /** Canvas color space. */
  colorSpace?: PredefinedColorSpace;
  /** Whether camera render targets allocate depth attachments. */
  depth?: boolean;
  /** Whether camera render targets allocate stencil attachments. */
  stencil?: boolean;
}

/**
 * WebGPU graphic device.
 */
export class WebGPUGraphicDevice implements IHardwareRenderer {
  /** Graphics backend implemented by this device. */
  readonly backend = "webgpu" as const;
  /** Origin used when sampling WebGPU render-target textures. */
  readonly renderTargetOrigin = "upper-left" as const;
  readonly supportsRendering = true;
  readonly supportsCompute = true;
  readonly supportsTransformFeedback = false;
  createFeedbackCompute(): WebGPUFeedbackKernel { return new WebGPUFeedbackKernel(this); }
  private readonly _defaults = new Map<string,GPUTextureView>();
  private readonly _samplers = new Map<string,GPUSampler>();
  _fallbackView(layout: IWebGPUShaderTexture): GPUTextureView {
    const key = layout.sampleType + layout.viewDimension;
    let view = this._defaults.get(key);
    if (!view) {
      const format = layout.sampleType === "uint" ? "rgba8uint" : layout.sampleType === "sint" ? "rgba8sint" : layout.sampleType === "depth" ? "depth16unorm" : "rgba8unorm";
      const texture = this.device.createTexture({size:[1,1,layout.viewDimension === "cube" ? 6 : 1], format,dimension:layout.viewDimension === "3d" ? "3d":"2d",usage:GPUTextureUsage.TEXTURE_BINDING});
      view = texture.createView({dimension:layout.viewDimension});
      this._defaults.set(key,view);
    }
    return view;
  }
  _fallbackSampler(type: GPUSamplerBindingType): GPUSampler {
    return this._getSampler({compare:type === "comparison" ? "less-equal" : undefined});
  }
  _getSampler(descriptor: GPUSamplerDescriptor): GPUSampler {
    const key = [descriptor.addressModeU ?? "clamp-to-edge",descriptor.addressModeV ?? "clamp-to-edge",
      descriptor.minFilter ?? "nearest",descriptor.magFilter ?? "nearest",descriptor.mipmapFilter ?? "nearest",
      descriptor.compare ?? "",descriptor.maxAnisotropy ?? 1].join("/");
    let sampler = this._samplers.get(key);
    if (!sampler) { sampler = this.device.createSampler(descriptor); this._samplers.set(key,sampler); }
    return sampler;
  }
  get maxVertexUniformBlocks(): number { return this.device.limits.maxUniformBuffersPerShaderStage; }
  get maxFragmentUniformBlocks(): number { return this.maxVertexUniformBlocks; }
  get maxUniformBufferBindings(): number { return this.maxVertexUniformBlocks * 2; }
  get uniformBufferOffsetAlignment(): number { return this.device.limits.minUniformBufferOffsetAlignment; }
  readonly resolveShaderConstant = (name: string): number | undefined => {
    const l = this.device.limits;
    switch (name) {
      case "gl_MaxVertexAttribs": return l.maxVertexAttributes;
      case "gl_MaxDrawBuffers": return l.maxColorAttachments;
      case "gl_MaxVertexUniformVectors":
      case "gl_MaxFragmentUniformVectors": return this.maxUniformBlockSize / 16;
      case "gl_MaxTextureImageUnits":
      case "gl_MaxVertexTextureImageUnits": return l.maxSampledTexturesPerShaderStage;
      case "gl_MaxCombinedTextureImageUnits": return l.maxSampledTexturesPerShaderStage * 2;
    }
  };
  /** @internal */
  readonly _options: {
    _forceFlush: boolean;
    depth: boolean;
    stencil: boolean;
  };
  /** Native WebGPU adapter. */
  readonly adapter: GPUAdapter;
  /** Native WebGPU device. */
  readonly device: GPUDevice;
  /** Native WebGPU canvas context. */
  readonly context: GPUCanvasContext;
  /** Preferred canvas texture format. */
  readonly canvasFormat: GPUTextureFormat;
  private readonly _surfaceDepthFormat?: GPUTextureFormat;
  /** Device capability facade. */
  readonly capability: WebGPUCapability;
  /** Maximum uniform-buffer binding size in bytes. */
  readonly maxUniformBlockSize: number;
  submissionSerial = 0;
  private readonly _ops: WebGPUAttachmentOps;
  private readonly _computePipelines = new Map<string, GPUComputePipeline>();
  private readonly _deviceOptions: WebGPUGraphicDeviceOptions;
  private _lost = false;
  private _forcedLoss = false;
  private _restoreRequested = false;
  private _restoring = false;
  private _onDeviceRestored: () => void;
  /** Adapter description exposed for diagnostics. */
  readonly renderer: string;
  /** Optional GPU timestamp collection state. */
  readonly gpuTiming: WebGPUTimingProfiler;

  /** @internal */
  _currentBindShaderProgram: IPlatformShaderProgram;
  /** @internal */
  _enableGlobalDepthBias = false;

  private readonly _canvas: HTMLCanvasElement | OffscreenCanvas;
  private _onDeviceLost: () => void;
  private _currentRenderTarget: WebGPURenderTarget | null = null;
  private _viewport = new Vector4();
  private _scissor = new Vector4();
  private _commandEncoder: GPUCommandEncoder;
  private _renderPass: GPURenderPassEncoder;
  private _computePass: GPUComputePassEncoder;
  private _pendingClearFlags = CameraClearFlags.None;
  private _colorStore = RenderBufferStoreAction.Store;
  private _depthStore = RenderBufferStoreAction.Store;
  private _touchedTarget = false;
  private _pendingClearColor = new Color();
  private _mainDepthTexture: GPUTexture;
  private _mainDepthWidth = 0;
  private _mainDepthHeight = 0;
  private _renderState: {
    state: any;
    frontFaceInvert: boolean;
    customStates?: Record<number, any>;
  };
  private readonly _mipmapGenerator: WebGPUMipmapGenerator;
  private readonly _gpuTimingProfiler: WebGPUTimingProfiler;
  private readonly _defaultVertexBuffer: GPUBuffer;
  readonly uniformRanges: { buffer: WebGPUBuffer; offset: number; size: number }[] = [];
  private _retiredBuffers: GPUBuffer[] = [];
  private _appliedRenderPipeline?: GPURenderPipeline;
  private readonly _appliedGroups: GPUBindGroup[] = [];
  private readonly _groupOffsets: Uint32Array[] = [];
  private readonly _vertexBuffers: GPUBuffer[] = [];
  private _indexBuffer?: GPUBuffer;
  private _indexFormat?: GPUIndexFormat;
  private _cachedTarget?: WebGPURenderTarget | null;
  private _attachments?: { colorFormats: readonly GPUTextureFormat[]; depthStencilFormat?: GPUTextureFormat; sampleCount:number; key:string };
  readonly _globalBias = {enabled:false,bias:0,slopeBias:0};
  private _viewportDirty = true;
  private _scissorDirty = true;
  private _appliedBlendConstant?: number[];
  private _appliedStencilReference?: number;
  private _destroyed = false;
  private _globalDepthBias = 0;
  private _globalSlopeScaledDepthBias = 0;
  private _renderPassLabel = "render";

  /**
   * Whether the texture-based joint path is available.
   */
  get canIUseMoreJoints(): boolean {
    return this.capability.canIUseMoreJoints;
  }

  private constructor(
    canvas: HTMLCanvasElement | OffscreenCanvas,
    adapter: GPUAdapter,
    device: GPUDevice,
    context: GPUCanvasContext,
    format: GPUTextureFormat,
    options: WebGPUGraphicDeviceOptions
  ) {
    this._canvas = canvas;
    this.adapter = adapter;
    this.device = device;
    this.context = context;
    this.canvasFormat = format;
    this._surfaceDepthFormat = options.stencil !== false ? (options.depth === false ? "stencil8" : "depth24plus-stencil8") : options.depth !== false ? "depth24plus" : undefined;
    this.capability = new WebGPUCapability(device);
    this._mipmapGenerator = new WebGPUMipmapGenerator(device);
    this._gpuTimingProfiler = new WebGPUTimingProfiler(
      device,
      adapter.features.has("timestamp-query"),
      options.enableGPUTiming ?? false
    );
    this.gpuTiming = this._gpuTimingProfiler;
    const defaultVertexData = new ArrayBuffer(48);
    new Float32Array(defaultVertexData, 0, 4)[3] = 1;
    new Int32Array(defaultVertexData, 16, 4)[3] = 1;
    new Uint32Array(defaultVertexData, 32, 4)[3] = 1;
    this._defaultVertexBuffer = device.createBuffer({
      label: "Galacean default vertex attributes",
      size: defaultVertexData.byteLength,
      usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST
    });
    device.queue.writeBuffer(this._defaultVertexBuffer, 0, defaultVertexData);
    this._options = {
      _forceFlush: false,
      depth: options.depth ?? true,
      stencil: options.stencil ?? true
    };
    this.maxUniformBlockSize = device.limits.maxUniformBufferBindingSize;
    this._ops = new WebGPUAttachmentOps(this);
    this._deviceOptions = options;
    this.renderer = adapter.info?.description || adapter.info?.device || "WebGPU";
    context.configure({
      device,
      format,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC | GPUTextureUsage.TEXTURE_BINDING,
      alphaMode: options.alphaMode ?? "premultiplied",
      colorSpace: options.colorSpace ?? "srgb"
    });
  }

  /**
   * Request an adapter and device for a canvas.
   * @param canvas - Web canvas wrapper.
   * @param options - Adapter, device, and canvas options.
   * @returns Initialized WebGPU graphic device.
   */
  static async create(canvas: WebCanvas, options: WebGPUGraphicDeviceOptions = {}): Promise<WebGPUGraphicDevice> {
    if (!navigator.gpu) {
      throw new Error("WebGPU is not available in this browser.");
    }

    const adapter = await navigator.gpu.requestAdapter({
      powerPreference: options.powerPreference,
      forceFallbackAdapter: options.forceFallbackAdapter
    });
    if (!adapter) {
      throw new Error("No WebGPU adapter is available.");
    }

    const unsupportedFeatures = (options.requiredFeatures ?? []).filter((feature) => !adapter.features.has(feature));
    if (unsupportedFeatures.length > 0) {
      throw new Error(`Required WebGPU features are unavailable: ${unsupportedFeatures.join(", ")}`);
    }

    const preferredFeatures: GPUFeatureName[] = [
      "shader-f16",
      "float32-blendable",
      "rg11b10ufloat-renderable",
      "texture-compression-astc",
      "texture-compression-bc",
      "texture-compression-etc2",
      "depth32float-stencil8",
      "texture-formats-tier1"
    ];
    const requestedFeatures = new Set(options.requiredFeatures ?? []);
    for (const feature of preferredFeatures) {
      if (adapter.features.has(feature)) {
        requestedFeatures.add(feature);
      }
    }
    if (options.enableGPUTiming && adapter.features.has("timestamp-query")) {
      requestedFeatures.add("timestamp-query");
    }
    const device = await adapter.requestDevice({
      requiredFeatures: Array.from(requestedFeatures),
      requiredLimits: options.requiredLimits
    });
    const nativeCanvas = canvas._webCanvas;
    const context = nativeCanvas.getContext("webgpu") as GPUCanvasContext | null;
    if (!context) {
      device.destroy();
      throw new Error("Unable to create a WebGPU canvas context.");
    }

    return new WebGPUGraphicDevice(
      nativeCanvas,
      adapter,
      device,
      context,
      navigator.gpu.getPreferredCanvasFormat(),
      options
    );
  }

  init(_canvas: Canvas, onDeviceLost: () => void, _onDeviceRestored: () => void): void {
    this._onDeviceLost = onDeviceLost;
    this._onDeviceRestored = _onDeviceRestored;
    const device = this.device;
    device.lost.then(info => {
      if (this.device === device && !this._destroyed && !this._lost) {
        this._lost = true;
        this._onDeviceLost();
        if (info.reason !== "destroyed" || this._restoreRequested) this.forceRestoreDevice();
      }
    });
  }

  createPlatformPrimitive(primitive: Primitive): IPlatformPrimitive { return new WebGPUPrimitive(this, primitive); }
  createPlatformShaderProgram(engine: Engine, source: IPlatformShaderSource): IPlatformShaderProgram {
    return new WebGPUShaderProgram(this, engine, source);
  }
  createPlatformTexture2D(texture: Texture2D): IPlatformTexture2D {
    return new WebGPUTexture2D(this, texture);
  }

  createPlatformTexture2DArray(texture: Texture2DArray): IPlatformTexture2DArray {
    return new WebGPUTexture2DArray(this, texture);
  }

  createPlatformTextureCube(texture: TextureCube): IPlatformTextureCube {
    return new WebGPUTextureCube(this, texture);
  }

  createPlatformRenderTarget(target: RenderTarget): IPlatformRenderTarget {
    return new WebGPURenderTarget(this, target);
  }

  createPlatformBuffer(
    type: BufferBindFlag,
    byteLength: number,
    usage: BufferUsage = BufferUsage.Static,
    data?: ArrayBuffer | ArrayBufferView
  ): IPlatformBuffer {
    return new WebGPUBuffer(this, type, byteLength, usage, data);
  }

  createPlatformTransformFeedback(): never {
    throw new Error("Transform Feedback is not supported by WebGPU; use a compute pipeline.");
  }

  createPlatformTransformFeedbackPrimitive(): never {
    throw new Error("Transform Feedback is not supported by WebGPU; use a compute pipeline.");
  }

  bindUniformBufferBase(binding: number, buffer: WebGPUBuffer): void {
    this.bindUniformBufferRange(binding,buffer,0,buffer.byteLength);
  }
  bindUniformBufferRange(binding: number, buffer: WebGPUBuffer, offset: number, size: number, data?: ArrayBufferView, discard = false): void {
    if (offset % this.uniformBufferOffsetAlignment || offset < 0 || size <= 0 || offset + size > buffer.byteLength) throw new RangeError("Invalid WebGPU uniform buffer range.");
    if (data) buffer.setData(buffer.byteLength, data, offset, 0, undefined, discard ? SetDataOptions.Discard : SetDataOptions.None);
    const range = this.uniformRanges[binding];
    if (range) {range.buffer = buffer; range.offset = offset; range.size = size;}
    else this.uniformRanges[binding] = {buffer,offset,size};
  }

  enableRasterizerDiscard(): never {
    throw new Error("Rasterizer discard is not supported by WebGPU; use a compute pipeline.");
  }

  disableRasterizerDiscard(): never {
    throw new Error("Rasterizer discard is not supported by WebGPU; use a compute pipeline.");
  }

  invalidateShaderProgramState(): void {
    this._currentBindShaderProgram = null;
  }

  requireExtension(): undefined {
    return undefined;
  }

  canIUse(capability: GLCapabilityType): boolean {
    return this.capability.canIUse(capability);
  }

  canIUseCompressedTextureInternalFormat(format: number): boolean {
    return this.capability.canIUseCompressedTextureInternalFormat(format);
  }

  viewport(x: number, y: number, width: number, height: number): void {
    const viewport = this._viewport;
    if (viewport.x !== x || viewport.y !== y || viewport.z !== width || viewport.w !== height) {
      viewport.set(x, y, width, height);
      this._viewportDirty = true;
    }
  }

  scissor(x: number, y: number, width: number, height: number): void {
    const scissor = this._scissor;
    if (scissor.x !== x || scissor.y !== y || scissor.z !== width || scissor.w !== height) {
      scissor.set(x, y, width, height);
      this._scissorDirty = true;
    }
  }

  clearRenderTarget(_engine: Engine, clearFlags: CameraClearFlags, clearColor?: Color): void {
    if (!clearFlags) return;
    const width = this._currentRenderTarget?.width ?? this._canvas.width;
    const height = this._currentRenderTarget?.height ?? this._canvas.height;
    const r = this._scissor;
    if (r.x !== 0 || r.y !== 0 || r.z !== width || r.w !== height) {
      this._ops.clear(this._getRenderPass(), this._getAttachmentState(), r, clearFlags, clearColor ?? this._pendingClearColor);
      this._resetRenderPassState();
    } else {
      this._endCurrentPass();
      this._pendingClearFlags |= clearFlags;
      if (clearColor) this._pendingClearColor.copyFrom(clearColor);
      this._getRenderPass();
    }
  }

  drawPrimitive(primitive: Primitive, subPrimitive: SubPrimitive, program: IPlatformShaderProgram): void {
    primitive.draw(program, subPrimitive);
  }

  activeTexture(): void {}
  bindTexture(): void {}
  beginFrame(): void {}
  endFrame(): void { this.flush(); }
  endRenderPass(): void {
    this._endCurrentPass();
    const target = this._currentRenderTarget;
    if (this._touchedTarget && target) {
      const discardColor = this._colorStore === RenderBufferStoreAction.DontCare || (this._colorStore === RenderBufferStoreAction.Resolve && target.sampleCount > 1);
      const discardDepth = this._depthStore === RenderBufferStoreAction.DontCare;
      if (discardColor || discardDepth) {
        // A copy, compute dispatch or overlapping upload can split a logical pass. Only its last segment may discard.
        const descriptor = target.createDescriptor(CameraClearFlags.None);
        for (const a of descriptor.colorAttachments) {
          a.resolveTarget = undefined;
          if (discardColor) a.storeOp = "discard";
        }
        const depth = descriptor.depthStencilAttachment;
        if (discardDepth && depth) {
          if (depth.depthStoreOp) depth.depthStoreOp = "discard";
          if (depth.stencilStoreOp) depth.stencilStoreOp = "discard";
        }
        descriptor.label = this._renderPassLabel + " store";
        this._getCommandEncoder().beginRenderPass(descriptor).end();
      }
    }
    this._touchedTarget = false;
    this._pendingClearFlags = CameraClearFlags.None;
  }
  supportsTextureFormat(format: TextureFormat): boolean {
    let f: GPUTextureFormat;
    try { f = WebGPUTexture._getFormat(format, false); } catch { return false; }
    const feature: GPUFeatureName | undefined = f.startsWith("bc") ? "texture-compression-bc" :
      f.startsWith("etc") ? "texture-compression-etc2" : f.startsWith("astc") ? "texture-compression-astc" :
      f === "depth32float-stencil8" ? "depth32float-stencil8" : f === "r16unorm" ? "texture-formats-tier1" : undefined;
    return !feature || this.device.features.has(feature);
  }
  supportsRenderTargetColorFormat(format: TextureFormat): boolean {
    if (!this.supportsTextureFormat(format)) return false;
    const f = WebGPUTexture._getFormat(format,false);
    return !/^(bc|etc|astc|depth|stencil)/.test(f) && (f !== "rg11b10ufloat" || this.device.features.has("rg11b10ufloat-renderable"));
  }
  supportsGenerateMipmaps(format: TextureFormat, srgb: boolean): boolean {
    if (!this.supportsRenderTargetColorFormat(format)) return false;
    const f = WebGPUTexture._getFormat(format,srgb);
    return !f.endsWith("uint") && (!f.includes("32float") || this.device.features.has("float32-filterable"));
  }
  getMainFrameBufferWidth(): number {
    return this._canvas.width;
  }

  getMainFrameBufferHeight(): number {
    return this._canvas.height;
  }

  activeRenderTarget(
    renderTarget: RenderTarget | null,
    viewport: Vector4,
    _isFlipProjection?: boolean,
    mipLevel: number = 0,
    faceIndex?: number,
    colorLoad:RenderBufferLoadAction = RenderBufferLoadAction.Load,
    colorStore:RenderBufferStoreAction = RenderBufferStoreAction.Store,
    depthLoad:RenderBufferLoadAction = RenderBufferLoadAction.Load,
    depthStore:RenderBufferStoreAction = RenderBufferStoreAction.Store,
    label?:string
  ): void {
    this.endRenderPass();
    this._colorStore = colorStore;
    this._depthStore = depthStore;
    this._renderPassLabel = label ?? (renderTarget ? "offscreen-render" : "main-render");
    if (viewport.x === 0 && viewport.y === 0 && viewport.z === 1 && viewport.w === 1) {
      if (colorLoad === RenderBufferLoadAction.DontCare) this._pendingClearFlags |= CameraClearFlags.Color;
      if (depthLoad === RenderBufferLoadAction.DontCare) this._pendingClearFlags |= CameraClearFlags.DepthStencil;
    }
    if (renderTarget) {
      (
        renderTarget as RenderTarget & { _platformRenderTarget: IPlatformRenderTarget }
      )._platformRenderTarget.activeRenderTarget(mipLevel, faceIndex);
    } else {
      this._currentRenderTarget = null;
    }
    const targetWidth = renderTarget ? Math.max(1, renderTarget.width >> mipLevel) : this._canvas.width;
    const targetHeight = renderTarget ? Math.max(1, renderTarget.height >> mipLevel) : this._canvas.height;
    const width = targetWidth * viewport.z;
    const height = targetHeight * viewport.w;
    const x = targetWidth * viewport.x;
    const y = targetHeight * viewport.y;
    this.viewport(x, y, width, height);
    this.scissor(x, y, width, height);
  }

  blitInternalRTByBlitFrameBuffer(source: RenderTarget | null, destination: RenderTarget, flags: CameraClearFlags, viewport: Vector4): void {
    const target = destination._platformRenderTarget as WebGPURenderTarget;
    if (!(flags & CameraClearFlags.Color) && destination.colorTextureCount) this._ops.copyColor(this._sourceColor(source), target.colorAttachment(), viewport);
    const sourceDepth = source ? (source._platformRenderTarget as WebGPURenderTarget).depthTexture() : this._mainDepthTexture;
    const destDepth = target.depthTexture();
    if (sourceDepth && destDepth && (flags & CameraClearFlags.DepthStencil) !== CameraClearFlags.DepthStencil) this._ops.copyDepth(sourceDepth, destDepth, viewport, flags);
  }
  copyRenderTargetToSubTexture(source: RenderTarget | null, texture: Texture2D, viewport: Vector4): void {
    this._ops.copyColor(this._sourceColor(source), (texture._platformTexture as WebGPUTexture)._gpuTexture, viewport);
  }
  _resolveDepth(source:GPUTexture,destination:GPUTexture):void {
    this._ops.copyDepth(source,destination,new Vector4(0,0,1,1),CameraClearFlags.None);
  }
  private _sourceColor(source: RenderTarget | null): GPUTexture {
    return source ? (source._platformRenderTarget as WebGPURenderTarget).colorTexture() : this.context.getCurrentTexture();
  }
  /**
   * Override raster depth bias until the override is reset to zero.
   * @param bias - Constant depth bias.
   * @param slopeBias - Slope-scaled depth bias.
   */
  setGlobalDepthBias(bias: number, slopeBias: number): void {
    this._enableGlobalDepthBias = bias !== 0 || slopeBias !== 0;
    this._globalDepthBias = bias;
    this._globalSlopeScaledDepthBias = slopeBias;
    this._globalBias.enabled = this._enableGlobalDepthBias;
    this._globalBias.bias = bias;
    this._globalBias.slopeBias = slopeBias;
  }

  flush(): void {
    if (!this._commandEncoder && this._pendingClearFlags !== CameraClearFlags.None) {
      this._getRenderPass();
    }
    this._endCurrentPass();
    if (this._commandEncoder) {
      const timingReadback = this._gpuTimingProfiler.resolve(this._commandEncoder);
      this.device.queue.submit([this._commandEncoder.finish()]);
      this._gpuTimingProfiler.readAfterSubmit(timingReadback);
      this._commandEncoder = null;
    }
    this.submissionSerial++;
    if (this._retiredBuffers.length > 0) {
      const retired = this._retiredBuffers;
      this._retiredBuffers = [];
      this.device.queue.onSubmittedWorkDone().then(() => {
        for (const buffer of retired) {
          buffer.destroy();
        }
      });
    }
  }

  forceLoseDevice(): void {
    this._forcedLoss = true;
    this.device.destroy();
  }

  forceRestoreDevice(): void {
    if (this._restoring || this._destroyed) return;
    if (!this._lost) { this._restoreRequested = this._forcedLoss; return; }
    this._restoring = true;
    WebGPUGraphicDevice.create(new WebCanvas(this._canvas), this._deviceOptions).then(replacement => {
      if (this._destroyed) { replacement.destroy(); return; }
      const lost = this._onDeviceLost, restored = this._onDeviceRestored;
      Object.assign(this,replacement);
      this._mainDepthTexture = undefined;
      this._attachments = undefined;
      this._renderPass = this._computePass = this._commandEncoder = undefined;
      this._currentRenderTarget = this._currentBindShaderProgram = null;
      this._resetRenderPassState();
      this._ops.deviceOwner = this;
      this.init(null, lost, restored);
      restored();
    }).catch(error => console.error("WebGPU device restoration failed.", error)).finally(() => { this._restoring = false; });
  }

  isContextLost(): boolean {
    return this._lost || this._destroyed;
  }

  resetState(): void {
    this._endCurrentPass();
    this._currentBindShaderProgram = null;
    this._currentRenderTarget = null;
  }

  destroy(): void {
    if (!this._destroyed) {
      this._destroyed = true;
      this._endCurrentPass();
      this._computePipelines.clear();
      this._ops.destroy();
      this._gpuTimingProfiler.destroy();
      this._mainDepthTexture?.destroy();
      this._defaultVertexBuffer.destroy();
      for (const buffer of this._retiredBuffers) {
        buffer.destroy();
      }
      this.context.unconfigure();
      this.device.destroy();
    }
  }

  /** @internal */
  _setRenderTarget(target: WebGPURenderTarget): void {
    this._endCurrentPass();
    this._currentRenderTarget = target;
  }

  /** @internal */
  _getDefaultVertexBuffer(): GPUBuffer {
    return this._defaultVertexBuffer;
  }

  /** @internal */
  applyRenderState(state: RenderState, _last: RenderState, frontFaceInvert: boolean, customStates?: Record<number, any>): void {
    if (this._renderState) {
      this._renderState.state = state; this._renderState.frontFaceInvert = frontFaceInvert; this._renderState.customStates = customStates;
    } else this._renderState = {state,frontFaceInvert,customStates};
  }

  /** @internal */
  _getRenderState(): {
    state: any;
    frontFaceInvert: boolean;
    customStates?: Record<number, any>;
  } {
    if (!this._renderState) {
      throw new Error("WebGPU draw was issued before a render state was applied.");
    }
    return this._renderState;
  }

  /** @internal */
  _getGlobalDepthBias(): {
    enabled: boolean;
    bias: number;
    slopeBias: number;
  } {
    return this._globalBias;
  }

  /** @internal */
  _getAttachmentState(target = this._currentRenderTarget): {
    colorFormats: readonly GPUTextureFormat[];
    depthStencilFormat?: GPUTextureFormat;
    sampleCount: number;
    key: string;
  } {
    if (this._attachments && this._cachedTarget === target) return this._attachments;
    this._cachedTarget = target;
    if (target) {
      const colorFormats = target.colorFormats;
      const depthStencilFormat = target.depthStencilFormat;
      const sampleCount = target.sampleCount;
      return this._attachments = {
        colorFormats,
        depthStencilFormat,
        sampleCount,
        key: `${colorFormats.join(",")}|${depthStencilFormat ?? ""}|${sampleCount}`
      };
    }
    return this._attachments = {
      colorFormats: [this.canvasFormat],
      depthStencilFormat: this._surfaceDepthFormat,
      sampleCount: 1,
      key: `${this.canvasFormat}|${this._surfaceDepthFormat ?? ""}|1`
    };
  }

  /**
   * Return the active render pass, closing any preceding compute group.
   * @returns Current or newly encoded render pass.
   * @internal
   */
  _getRenderPass(): GPURenderPassEncoder {
    if (this._renderPass) {
      return this._renderPass;
    }
    this._endComputePass();
    this._commandEncoder ??= this.device.createCommandEncoder({
      label: "Galacean WebGPU frame"
    });
    const descriptor = this._currentRenderTarget
      ? this._currentRenderTarget.createDescriptor(this._pendingClearFlags, this._pendingClearColor)
      : this._createMainRenderPassDescriptor();
    descriptor.label = this._renderPassLabel;
    this._gpuTimingProfiler.addTimestampWrites(descriptor, "render");
    this._renderPass = this._commandEncoder.beginRenderPass(descriptor);
    this._touchedTarget = true;
    this._resetRenderPassState();
    this._pendingClearFlags = CameraClearFlags.None;
    return this._renderPass;
  }

  /**
   * Return the active compute pass so consecutive dispatches share one native pass.
   * @returns Current or newly encoded compute pass.
   * @internal
   */
  _beginComputePass(): GPUComputePassEncoder {
    if (this._computePass) {
      return this._computePass;
    }
    this._endRenderPass();
    this._commandEncoder ??= this.device.createCommandEncoder({
      label: "Galacean WebGPU frame"
    });
    const descriptor: GPUComputePassDescriptor = {
      label: "compute"
    };
    this._gpuTimingProfiler.addTimestampWrites(descriptor, "compute");
    return (this._computePass = this._commandEncoder.beginComputePass(descriptor));
  }

  _getCommandEncoder(): GPUCommandEncoder {
    this._endCurrentPass();
    return this._commandEncoder ??= this.device.createCommandEncoder({label:"Galacean commands"});
  }
  /** Merge unaligned byte ranges with the destination's current GPU values. */
  _expandIndices(src:GPUBuffer,dst:GPUBuffer,words:number): void {
    const key = "Galacean UInt8 indices";
    let pipeline = this._computePipelines.get(key);
    if (!pipeline) {
      const module = this.device.createShaderModule({code:`
        @group(0) @binding(0) var<storage,read> src: array<u32>;
        @group(0) @binding(1) var<storage,read_write> dst: array<u32>;
        @compute @workgroup_size(64) fn expand(@builtin(global_invocation_id) id:vec3u) {
          if(id.x>=arrayLength(&src)) { return; }
          let value=src[id.x];
          dst[id.x*2u]=(value&255u)|((value&65280u)<<8u);
          dst[id.x*2u+1u]=((value>>16u)&255u)|((value>>24u)<<16u);
        }`});
      pipeline = this.device.createComputePipeline({layout:"auto",compute:{module,entryPoint:"expand"}});
      this._computePipelines.set(key,pipeline);
    }
    const pass=this._beginComputePass();
    pass.setPipeline(pipeline);
    pass.setBindGroup(0,this.device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[
      {binding:0,resource:{buffer:src}},{binding:1,resource:{buffer:dst}}]}));
    pass.dispatchWorkgroups(Math.ceil(words/64));
    this._endComputePass();
  }

  _copyBytes(src: GPUBuffer, dst: GPUBuffer, srcOffset: number, dstOffset: number, size: number): void {
    const key = "Galacean copy bytes";
    let pipeline = this._computePipelines.get(key);
    if (!pipeline) {
      const module = this.device.createShaderModule({code:`
        @group(0) @binding(0) var<storage,read> src: array<u32>;
        @group(0) @binding(1) var<storage,read_write> dst: array<u32>;
        @group(0) @binding(2) var<uniform> p: vec4u;
        @compute @workgroup_size(64) fn copyBytes(@builtin(global_invocation_id) id: vec3u) {
          let index = p.y/4u + id.x;
          if (index*4u >= p.y+p.z) { return; }
          var word = dst[index];
          for (var i=0u;i<4u;i++) {
            let offset = index*4u+i;
            if (offset>=p.y && offset<p.y+p.z) {
              let s = offset-p.y+p.x;
              let byte = (src[s/4u] >> ((s%4u)*8u)) & 255u;
              word = (word & ~(255u<<(i*8u))) | (byte<<(i*8u));
            }
          }
          dst[index] = word;
        }`});
      pipeline = this.device.createComputePipeline({layout:"auto",compute:{module,entryPoint:"copyBytes"}});
      this._computePipelines.set(key,pipeline);
    }
    const params = this.device.createBuffer({size:16,usage:GPUBufferUsage.UNIFORM,mappedAtCreation:true});
    new Uint32Array(params.getMappedRange()).set([srcOffset,dstOffset,size]); params.unmap();
    const pass = this._beginComputePass();
    pass.setPipeline(pipeline);
    pass.setBindGroup(0,this.device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries:[src,dst,params].map((buffer,binding)=>({binding,resource:{buffer}}))}));
    pass.dispatchWorkgroups(Math.ceil(((dstOffset%4)+size)/256));
    this._endComputePass();
    this._retireBuffer(params);
  }
  dispatchCompute(source: string, entryPoint: string, workgroups: readonly [number,number,number], bindings: readonly {binding: number; buffer: IPlatformBuffer; access: "read"|"read_write"|"uniform"; offset?: number; size?: number}[]): void {
    const key = entryPoint + ":" + source;
    let pipeline = this._computePipelines.get(key);
    if (!pipeline) {
      pipeline = this.device.createComputePipeline({layout:"auto",compute:{module:this.device.createShaderModule({code:source}),entryPoint}});
      this._computePipelines.set(key,pipeline);
    }
    const entries = bindings.map(b => {
      const buffer = b.buffer as WebGPUBuffer;
      buffer._markUsed(b.offset, b.size ?? (buffer.byteLength - (b.offset ?? 0)));
      return {binding:b.binding,resource:{buffer:buffer._gpuBuffer,offset:b.offset,size:b.size}};
    });
    const group = this.device.createBindGroup({layout:pipeline.getBindGroupLayout(0),entries});
    const pass = this._beginComputePass();
    pass.setPipeline(pipeline); pass.setBindGroup(0,group); pass.dispatchWorkgroups(...workgroups);
    this._endComputePass();
  }

  _applyDynamicState(pass: GPURenderPassEncoder): void {
    if (this._viewportDirty) {
      const targetWidth = this._currentRenderTarget?.width ?? this._canvas.width;
      const targetHeight = this._currentRenderTarget?.height ?? this._canvas.height;
      const viewportWidth = Math.max(0, Math.min(this._viewport.z, targetWidth - this._viewport.x));
      const viewportHeight = Math.max(0, Math.min(this._viewport.w, targetHeight - this._viewport.y));
      pass.setViewport(this._viewport.x, this._viewport.y, viewportWidth, viewportHeight, 0, 1);
      this._viewportDirty = false;
    }
    if (this._scissorDirty) {
      const targetWidth = this._currentRenderTarget?.width ?? this._canvas.width;
      const targetHeight = this._currentRenderTarget?.height ?? this._canvas.height;
      const scissorX = Math.max(0, Math.floor(this._scissor.x));
      const scissorY = Math.max(0, Math.floor(this._scissor.y));
      const scissorWidth = Math.max(0, Math.floor(Math.min(this._scissor.z, targetWidth - this._scissor.x)));
      const scissorHeight = Math.max(0, Math.floor(Math.min(this._scissor.w, targetHeight - this._scissor.y)));
      pass.setScissorRect(scissorX, scissorY, scissorWidth, scissorHeight);
      this._scissorDirty = false;
    }
    const { state, customStates } = this._getRenderState();
    const blendColor = state.blendState.blendColor;
    const blendConstant = this._appliedBlendConstant;
    if (
      !blendConstant ||
      blendConstant[0] !== blendColor.r ||
      blendConstant[1] !== blendColor.g ||
      blendConstant[2] !== blendColor.b ||
      blendConstant[3] !== blendColor.a
    ) {
      pass.setBlendConstant({
        r: blendColor.r,
        g: blendColor.g,
        b: blendColor.b,
        a: blendColor.a
      });
      this._appliedBlendConstant = [blendColor.r, blendColor.g, blendColor.b, blendColor.a];
    }
    const stencilReference =
      customStates?.[RenderStateElementKey.StencilStateReferenceValue] ?? state.stencilState.referenceValue;
    if (this._appliedStencilReference !== stencilReference) {
      pass.setStencilReference(stencilReference);
      this._appliedStencilReference = stencilReference;
    }
  }

  /**
   * Set the active pipeline when it differs from the current render-pass state.
   * @param pass - Active render-pass encoder.
   * @param pipeline - Pipeline required by the next draw.
   * @internal
   */
  _setBindGroup(pass:GPURenderPassEncoder|GPUComputePassEncoder,index:number,group:GPUBindGroup,offsets:Uint32Array):void {
    if (pass !== this._renderPass) { pass.setBindGroup(index,group,offsets,0,offsets.length); return; }
    let cached = this._groupOffsets[index];
    let changed = this._appliedGroups[index] !== group;
    if (!cached || cached.length < offsets.length) {
      this._groupOffsets[index] = cached = new Uint32Array(offsets.length);
      changed = true;
    }
    for (let i=0;i<offsets.length;i++) {
      if (cached[i] !== offsets[i]) { cached[i] = offsets[i]; changed = true; }
    }
    if (changed) {
      this._appliedGroups[index] = group;
      if (offsets.length) pass.setBindGroup(index,group,offsets,0,offsets.length);
      else pass.setBindGroup(index,group);
    }
  }

  _setVertexBuffer(pass: GPURenderPassEncoder, slot:number, buffer:GPUBuffer):void {
    if (this._vertexBuffers[slot] !== buffer) {pass.setVertexBuffer(slot,buffer); this._vertexBuffers[slot]=buffer;}
  }
  _setIndexBuffer(pass: GPURenderPassEncoder,buffer:GPUBuffer,format:GPUIndexFormat):void {
    if (this._indexBuffer !== buffer || this._indexFormat !== format) {
      pass.setIndexBuffer(buffer,format); this._indexBuffer=buffer; this._indexFormat=format;
    }
  }
  _setRenderPipeline(pass: GPURenderPassEncoder, pipeline: GPURenderPipeline): void {
    if (this._appliedRenderPipeline !== pipeline) {
      pass.setPipeline(pipeline);
      this._appliedRenderPipeline = pipeline;
    }
  }

  /** @internal */
  /** @internal */
  _retireBuffer(buffer: GPUBuffer): void {
    this._retiredBuffers.push(buffer);
  }

  /** @internal */
  _generateMipmaps(
    texture: GPUTexture,
    format: GPUTextureFormat,
    width: number,
    height: number,
    mipLevelCount: number,
    layerCount: number
  ): void {
    this.flush();
    this._mipmapGenerator.generate(texture, format, width, height, mipLevelCount, layerCount);
  }

  private _createMainRenderPassDescriptor(): GPURenderPassDescriptor {
    const format=this._surfaceDepthFormat;
    const hasDepth=format?.startsWith("depth"),hasStencil=format?.includes("stencil");
    if(format) this._ensureMainDepthTexture();
    const clearColor = (this._pendingClearFlags & CameraClearFlags.Color) !== 0;
    const clearDepth = (this._pendingClearFlags & CameraClearFlags.Depth) !== 0;
    const clearStencil = (this._pendingClearFlags & CameraClearFlags.Stencil) !== 0;
    return {
      colorAttachments: [
        {
          view: this.context.getCurrentTexture().createView(),
          clearValue: clearColor
            ? {
                r: this._pendingClearColor.r,
                g: this._pendingClearColor.g,
                b: this._pendingClearColor.b,
                a: this._pendingClearColor.a
              }
            : undefined,
          loadOp: clearColor ? "clear" : "load",
          storeOp: "store"
        }
      ],
      depthStencilAttachment: format ? {
        view: this._mainDepthTexture.createView(),
        depthClearValue: clearDepth && hasDepth ? 1 : undefined,
        depthLoadOp: hasDepth ? (clearDepth ? "clear":"load") : undefined,
        depthStoreOp: hasDepth ? "store" : undefined,
        stencilClearValue: clearStencil && hasStencil ? 0 : undefined,
        stencilLoadOp: hasStencil ? (clearStencil ? "clear":"load") : undefined,
        stencilStoreOp: hasStencil ? "store" : undefined
      } : undefined
    };
  }

  private _ensureMainDepthTexture(): void {
    const width = this._canvas.width;
    const height = this._canvas.height;
    if (this._mainDepthTexture && this._mainDepthWidth === width && this._mainDepthHeight === height) {
      return;
    }
    this._mainDepthTexture?.destroy();
    this._mainDepthWidth = width;
    this._mainDepthHeight = height;
    this._mainDepthTexture = this.device.createTexture({
      label: "Galacean main depth-stencil",
      size: { width, height },
      format: this._surfaceDepthFormat,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING
    });
  }

  private _endRenderPass(): void {
    if (this._renderPass) {
      this._renderPass.end();
      this._renderPass = null;
    }
  }

  private _endComputePass(): void {
    if (this._computePass) {
      this._computePass.end();
      this._computePass = null;
    }
  }

  private _endCurrentPass(): void {
    this._endRenderPass();
    this._endComputePass();
  }

  private _resetRenderPassState(): void {
    this._appliedGroups.length = this._vertexBuffers.length = 0;
    this._indexBuffer = undefined;
    this._appliedRenderPipeline = undefined;
    this._viewportDirty = true;
    this._scissorDirty = true;
    this._appliedBlendConstant = undefined;
    this._appliedStencilReference = undefined;
  }

}
