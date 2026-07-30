import {
  BufferBindFlag,
  BufferUsage,
  CameraClearFlags,
  Canvas,
  Engine,
  GLCapabilityType,
  IPlatformBuffer,
  IPlatformRenderTarget,
  IPlatformTexture2D,
  IPlatformTexture2DArray,
  IPlatformTextureCube,
  Mesh,
  type InstanceBufferLayout,
  Primitive,
  RenderStateElementKey,
  RenderTarget,
  SubMesh,
  Texture2D,
  Texture2DArray,
  TextureCube,
  type VertexBufferBinding
} from "@galacean/engine-core";
import type {
  ComputeCapabilities,
  IHardwareRenderer,
  IPlatformComputeProgram,
  IPlatformPrimitive,
  IPlatformShaderProgram,
  IShaderReflection,
  IShaderResourceReflection,
  IShaderStorageBufferReflection,
  ShaderCapabilities
} from "@galacean/engine-design";
import { Color, Vector4 } from "@galacean/engine-math";
import { WebGPUBuffer } from "./WebGPUBuffer";
import { WebGPUCanvas } from "./WebGPUCanvas";
import { WebGPUCapability } from "./WebGPUCapability";
import { WebGPUComputeProgram, type WebGPUComputePipelineState } from "./WebGPUComputeProgram";
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
  /** Reuse eligible single-sample depth prepasses during forward rendering. */
  enableDepthPriming?: boolean;
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
  /** Compatibility flag for engine features that require a modern graphics API. */
  readonly isWebGL2 = true;
  /** @internal */
  readonly _isWebGL2 = true;
  /** @internal */
  readonly _options: {
    _forceFlush: true;
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
  /** Device capability facade. */
  readonly capability: WebGPUCapability;
  /** Maximum uniform-buffer binding size in bytes. */
  readonly maxUniformBlockSize: number;
  /** Compute support and native device limits. */
  readonly computeCapabilities: ComputeCapabilities;
  /** Shader arithmetic features enabled on the WebGPU device. */
  readonly shaderCapabilities: ShaderCapabilities;
  /** Adapter description exposed for diagnostics. */
  readonly renderer: string;
  /** Optional GPU timestamp collection state. */
  readonly gpuTiming: WebGPUTimingProfiler;
  /** Whether eligible single-sample depth prepasses are reused by the forward pass. */
  readonly depthPrimingEnabled: boolean;

  /** @internal */
  _currentBindShaderProgram: unknown;
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
  private readonly _usedPrograms = new Set<WebGPUShaderProgram>();
  private readonly _computePipelines = new Map<string, WebGPUComputePipelineState>();
  private readonly _constantBuffers = new Map<number, WebGPUBuffer>();
  private _retiredBuffers: GPUBuffer[] = [];
  private _appliedRenderPipeline?: GPURenderPipeline;
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
    this.capability = new WebGPUCapability(device);
    this._mipmapGenerator = new WebGPUMipmapGenerator(device);
    this._gpuTimingProfiler = new WebGPUTimingProfiler(
      device,
      adapter.features.has("timestamp-query"),
      options.enableGPUTiming ?? false
    );
    this.gpuTiming = this._gpuTimingProfiler;
    this.depthPrimingEnabled = options.enableDepthPriming ?? false;
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
      _forceFlush: true,
      depth: options.depth ?? true,
      stencil: options.stencil ?? true
    };
    this.maxUniformBlockSize = device.limits.maxUniformBufferBindingSize;
    this.computeCapabilities = {
      supported: true,
      maxWorkgroupsPerDimension: device.limits.maxComputeWorkgroupsPerDimension,
      maxWorkgroupSizeX: device.limits.maxComputeWorkgroupSizeX,
      maxWorkgroupSizeY: device.limits.maxComputeWorkgroupSizeY,
      maxWorkgroupSizeZ: device.limits.maxComputeWorkgroupSizeZ,
      maxInvocationsPerWorkgroup: device.limits.maxComputeInvocationsPerWorkgroup,
      maxStorageBufferBindingSize: device.limits.maxStorageBufferBindingSize,
      maxStorageBuffersPerStage: device.limits.maxStorageBuffersPerShaderStage,
      recommendedWorkgroupSizeX: Math.max(
        1,
        Math.min(64, device.limits.maxComputeWorkgroupSizeX, device.limits.maxComputeInvocationsPerWorkgroup)
      )
    };
    this.shaderCapabilities = {
      float16: device.features.has("shader-f16")
    };
    this.renderer = adapter.info?.description || adapter.info?.device || "WebGPU";
    context.configure({
      device,
      format,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC,
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
  static async create(canvas: WebGPUCanvas, options: WebGPUGraphicDeviceOptions = {}): Promise<WebGPUGraphicDevice> {
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
      "float32-filterable",
      "float32-blendable",
      "rg11b10ufloat-renderable",
      "texture-compression-astc",
      "texture-compression-bc",
      "texture-compression-etc2"
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
    this.device.lost.then((info) => {
      if (!this._destroyed && info.reason !== "destroyed") {
        this._onDeviceLost();
      }
    });
  }

  createPlatformPrimitive(primitive: Mesh | Primitive): IPlatformPrimitive {
    return new WebGPUPrimitive(this, primitive as Primitive);
  }

  /**
   * Create WebGPU shader modules and their resource layout.
   * @param engine - Owning engine.
   * @param vertexSource - WGSL vertex source.
   * @param fragmentSource - WGSL fragment source.
   * @param reflection - Variant-specific ShaderLab reflection.
   * @returns Platform shader program.
   * @internal
   */
  createPlatformShaderProgram(
    engine: Engine,
    vertexSource: string,
    fragmentSource: string,
    reflection: IShaderReflection,
    instanceLayout?: InstanceBufferLayout | null
  ): IPlatformShaderProgram {
    return new WebGPUShaderProgram(this, engine, vertexSource, fragmentSource, reflection, instanceLayout);
  }

  /**
   * Create a WebGPU compute pipeline and storage-binding owner.
   * @param computeSource - Generated WGSL compute source.
   * @param reflection - Resolved ShaderLab resource reflection.
   * @returns Platform compute program.
   * @internal
   */
  createPlatformComputeProgram(computeSource: string, reflection: IShaderReflection): IPlatformComputeProgram {
    return new WebGPUComputeProgram(this, computeSource, reflection);
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

  bindUniformBufferBase(bindingPoint: number, buffer: IPlatformBuffer): void {
    this._constantBuffers.set(bindingPoint, buffer as WebGPUBuffer);
  }

  bindUniformBlock(): number {
    throw new Error("WebGPU uniform blocks are bound through pipeline bind groups.");
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

  colorMask(): void {}

  clearRenderTarget(_engine: Engine, clearFlags: CameraClearFlags, clearColor?: Color): void {
    this._endCurrentPass();
    this._pendingClearFlags = clearFlags;
    if (clearColor) {
      this._pendingClearColor.copyFrom(clearColor);
    }
  }

  drawPrimitive(primitive: Primitive, subPrimitive: SubMesh, shaderProgram: IPlatformShaderProgram): void {
    const platformProgram =
      (shaderProgram as IPlatformShaderProgram & { _platformProgram?: IPlatformShaderProgram })._platformProgram ??
      shaderProgram;
    primitive.draw(platformProgram, subPrimitive);
  }

  /**
   * Encodes an indirect draw using the primitive's current pipeline and bindings.
   * @param primitive Primitive supplying vertex and optional index buffers.
   * @param subPrimitive Sub-primitive supplying topology for pipeline selection.
   * @param shaderProgram Shader program supplying pipeline and bind groups.
   * @param indirectBuffer Platform buffer containing WebGPU draw arguments.
   * @param indirectOffset Byte offset of the argument record.
   * @param vertexBufferBindings Optional per-draw buffer replacements preserving the primitive layout.
   */
  drawPrimitiveIndirect(
    primitive: Primitive,
    subPrimitive: SubMesh,
    shaderProgram: IPlatformShaderProgram,
    indirectBuffer: IPlatformBuffer,
    indirectOffset: number = 0,
    vertexBufferBindings?: readonly (VertexBufferBinding | undefined)[]
  ): void {
    const platformProgram =
      (shaderProgram as IPlatformShaderProgram & { _platformProgram?: IPlatformShaderProgram })._platformProgram ??
      shaderProgram;
    primitive._drawIndirect(platformProgram, subPrimitive, indirectBuffer, indirectOffset, vertexBufferBindings);
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
    gpuTimingLabel?: string,
    depthReadOnly?: boolean
  ): void {
    this._endCurrentPass();
    this._renderPassLabel = gpuTimingLabel || (renderTarget ? "offscreen-render" : "main-render");
    if (renderTarget) {
      (
        renderTarget as RenderTarget & { _platformRenderTarget: IPlatformRenderTarget }
      )._platformRenderTarget.activeRenderTarget(mipLevel, faceIndex, depthReadOnly);
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

  blitInternalRTByBlitFrameBuffer(): never {
    throw new Error("WebGPU render-target blitting requires the neutral blit pass and is not available yet.");
  }

  copyRenderTargetToSubTexture(): never {
    throw new Error("WebGPU render-target copying requires an explicit command pass and is not available yet.");
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
    for (const program of this._usedPrograms) {
      program._resetFrame();
    }
    this._usedPrograms.clear();
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
    this.device.destroy();
  }

  forceRestoreDevice(): never {
    throw new Error("A WebGPU device cannot be restored in place; create a new WebGPUEngine.");
  }

  isContextLost(): boolean {
    return this._destroyed;
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
  setRenderState(state: any, frontFaceInvert: boolean, customStates?: Record<number, any>): void {
    this._renderState = { state, frontFaceInvert, customStates };
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
    return {
      enabled: this._enableGlobalDepthBias,
      bias: this._globalDepthBias,
      slopeBias: this._globalSlopeScaledDepthBias
    };
  }

  /** @internal */
  _getAttachmentState(): {
    colorFormats: readonly GPUTextureFormat[];
    depthStencilFormat?: GPUTextureFormat;
    sampleCount: number;
    key: string;
  } {
    if (this._currentRenderTarget) {
      const target = this._currentRenderTarget;
      const colorFormats = target.colorFormats;
      const depthStencilFormat = target.depthStencilFormat;
      const sampleCount = target.sampleCount;
      return {
        colorFormats,
        depthStencilFormat,
        sampleCount,
        key: `${colorFormats.join(",")}|${depthStencilFormat ?? ""}|${sampleCount}`
      };
    }
    return {
      colorFormats: [this.canvasFormat],
      depthStencilFormat: "depth24plus-stencil8",
      sampleCount: 1,
      key: `${this.canvasFormat}|depth24plus-stencil8|1`
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

  /**
   * Reuse immutable pipeline state for identical generated compute WGSL.
   * @param source - Generated WGSL compute source.
   * @param resources - Reflected sampled-texture declarations.
   * @param storageBuffers - Reflected storage-buffer declarations.
   * @returns Device-owned native pipeline state.
   * @internal
   */
  _getComputePipeline(
    source: string,
    resources: readonly IShaderResourceReflection[],
    storageBuffers: readonly IShaderStorageBufferReflection[]
  ): WebGPUComputePipelineState {
    const cached = this._computePipelines.get(source);
    if (cached) {
      return cached;
    }

    const pipelineId = this._computePipelines.size;
    const module = this.device.createShaderModule({
      label: `ComputePipeline ${pipelineId}`,
      code: source
    });
    this._reportComputeCompilationErrors(module, source, pipelineId);
    const bindGroupLayout = this.device.createBindGroupLayout({
      label: `ComputePipeline ${pipelineId} resources`,
      entries: [
        ...resources.flatMap<GPUBindGroupLayoutEntry>((resource) => [
          {
            binding: resource.textureBinding,
            visibility: GPUShaderStage.COMPUTE,
            texture: {
              sampleType: WebGPUGraphicDevice._textureSampleType(resource.textureType),
              viewDimension: WebGPUGraphicDevice._textureViewDimension(resource.textureType),
              multisampled: false
            }
          },
          {
            binding: resource.samplerBinding,
            visibility: GPUShaderStage.COMPUTE,
            sampler: {
              type: resource.comparison
                ? "comparison"
                : resource.textureType.includes("depth")
                  ? "non-filtering"
                  : "filtering"
            }
          }
        ]),
        ...storageBuffers.map<GPUBindGroupLayoutEntry>((storageBuffer) => ({
          binding: storageBuffer.binding,
          visibility: GPUShaderStage.COMPUTE,
          buffer: {
            type: storageBuffer.access === "read" ? "read-only-storage" : "storage"
          }
        }))
      ]
    });
    const state = {
      bindGroupLayout,
      pipeline: this.device.createComputePipeline({
        label: `ComputePipeline ${pipelineId}`,
        layout: this.device.createPipelineLayout({
          label: `ComputePipeline ${pipelineId} layout`,
          bindGroupLayouts: [bindGroupLayout]
        }),
        compute: {
          module,
          entryPoint: "main"
        }
      })
    };
    this._computePipelines.set(source, state);
    return state;
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

  /** @internal */
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
  _setRenderPipeline(pass: GPURenderPassEncoder, pipeline: GPURenderPipeline): void {
    if (this._appliedRenderPipeline !== pipeline) {
      pass.setPipeline(pipeline);
      this._appliedRenderPipeline = pipeline;
    }
  }

  /** @internal */
  _useProgram(program: WebGPUShaderProgram): void {
    this._usedPrograms.add(program);
  }

  /** @internal */
  _retireBuffer(buffer: GPUBuffer): void {
    this._retiredBuffers.push(buffer);
  }

  /** @internal */
  _getConstantBuffer(bindingPoint: number): WebGPUBuffer | undefined {
    return this._constantBuffers.get(bindingPoint);
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
    this._ensureMainDepthTexture();
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
      depthStencilAttachment: {
        view: this._mainDepthTexture.createView(),
        depthClearValue: clearDepth ? 1 : undefined,
        depthLoadOp: clearDepth ? "clear" : "load",
        depthStoreOp: "store",
        stencilClearValue: clearStencil ? 0 : undefined,
        stencilLoadOp: clearStencil ? "clear" : "load",
        stencilStoreOp: "store"
      }
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
      format: "depth24plus-stencil8",
      usage: GPUTextureUsage.RENDER_ATTACHMENT
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
    this._appliedRenderPipeline = undefined;
    this._viewportDirty = true;
    this._scissorDirty = true;
    this._appliedBlendConstant = undefined;
    this._appliedStencilReference = undefined;
  }

  private _reportComputeCompilationErrors(module: GPUShaderModule, source: string, pipelineId: number): void {
    module.getCompilationInfo().then((info) => {
      const errors = info.messages.filter((message) => message.type === "error");
      if (errors.length > 0 && !this._destroyed) {
        const lines = source.split("\n");
        console.error(
          `WebGPU compute pipeline ${pipelineId} failed:\n${errors
            .map((message) => {
              const sourceLine = lines[message.lineNum - 1]?.trim();
              return `${message.lineNum}:${message.linePos} ${message.message}${sourceLine ? `\n> ${sourceLine}` : ""}`;
            })
            .join("\n")}`
        );
      }
    });
  }
}
