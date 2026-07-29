import type {
  IPlatformComputeProgram,
  IShaderReflection,
  IShaderResourceReflection,
  IShaderStorageBufferReflection
} from "@galacean/engine-design";
import { WebGPUBuffer } from "./WebGPUBuffer";
import { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";
import { WebGPUTexture } from "./WebGPUTexture";

/**
 * Immutable native compute state shared by programs with identical generated WGSL.
 * @internal
 */
export interface WebGPUComputePipelineState {
  /** Native compute pipeline. */
  readonly pipeline: GPUComputePipeline;
  /** Bind-group layout reflected from ShaderLab sampled textures and storage buffers. */
  readonly bindGroupLayout: GPUBindGroupLayout;
}

/**
 * WebGPU compute pipeline and reflected resource bindings.
 * @internal
 */
export class WebGPUComputeProgram implements IPlatformComputeProgram {
  private static _counter = 0;

  private readonly _id = WebGPUComputeProgram._counter++;
  private readonly _graphicDevice: WebGPUGraphicDevice;
  private readonly _resources: readonly IShaderResourceReflection[];
  private readonly _storageBuffers: readonly IShaderStorageBufferReflection[];
  private readonly _pipeline: GPUComputePipeline;
  private readonly _bindGroupLayout: GPUBindGroupLayout;
  private readonly _boundBuffers = new Map<number, WebGPUBuffer>();
  private readonly _boundTextures = new Map<number, WebGPUTexture>();
  private _bindGroup?: GPUBindGroup;
  private _bindGroupTextureKey = "";
  private _destroyed = false;

  /**
   * Create a WebGPU compute program.
   * @param graphicDevice - Owning WebGPU device.
   * @param source - Generated WGSL compute source.
   * @param reflection - Resolved ShaderLab reflection.
   */
  constructor(graphicDevice: WebGPUGraphicDevice, source: string, reflection: IShaderReflection) {
    if (reflection.uniforms.length > 0) {
      throw new Error("Compute uniforms are not supported yet; use reflected storage buffers.");
    }

    const resources = reflection.resources;
    const storageBuffers = reflection.storageBuffers ?? [];
    if (resources.length > graphicDevice.device.limits.maxSampledTexturesPerShaderStage) {
      throw new RangeError(
        `Compute pass requires ${resources.length} sampled textures, but the device supports ` +
          `${graphicDevice.device.limits.maxSampledTexturesPerShaderStage}.`
      );
    }
    if (resources.length > graphicDevice.device.limits.maxSamplersPerShaderStage) {
      throw new RangeError(
        `Compute pass requires ${resources.length} samplers, but the device supports ` +
          `${graphicDevice.device.limits.maxSamplersPerShaderStage}.`
      );
    }
    if (storageBuffers.length > graphicDevice.computeCapabilities.maxStorageBuffersPerStage) {
      throw new RangeError(
        `Compute pass requires ${storageBuffers.length} storage buffers, but the device supports ` +
          `${graphicDevice.computeCapabilities.maxStorageBuffersPerStage}.`
      );
    }

    this._graphicDevice = graphicDevice;
    this._resources = resources;
    this._storageBuffers = storageBuffers;
    const pipelineState = graphicDevice._getComputePipeline(source, resources, storageBuffers);
    this._pipeline = pipelineState.pipeline;
    this._bindGroupLayout = pipelineState.bindGroupLayout;
  }

  /** @inheritdoc */
  setBuffer(binding: number, buffer: unknown): void {
    if (this._destroyed) {
      throw new Error("Cannot bind a destroyed WebGPU compute program.");
    }
    if (!this._storageBuffers.some((storageBuffer) => storageBuffer.binding === binding)) {
      throw new Error(`Compute program ${this._id} has no storage binding ${binding}.`);
    }
    if (!(buffer instanceof WebGPUBuffer)) {
      throw new TypeError("WebGPU compute requires a WebGPU platform buffer.");
    }
    if (buffer._gpuBuffer.size > this._graphicDevice.computeCapabilities.maxStorageBufferBindingSize) {
      throw new RangeError(
        `Storage binding ${binding} is ${buffer._gpuBuffer.size} bytes, exceeding the device limit ` +
          `${this._graphicDevice.computeCapabilities.maxStorageBufferBindingSize}.`
      );
    }
    if (this._boundBuffers.get(binding) !== buffer) {
      this._boundBuffers.set(binding, buffer);
      this._bindGroup = undefined;
    }
  }

  /** @inheritdoc */
  setTexture(binding: number, texture: unknown): void {
    if (this._destroyed) {
      throw new Error("Cannot bind a destroyed WebGPU compute program.");
    }
    if (!this._resources.some((resource) => resource.textureBinding === binding)) {
      throw new Error(`Compute program ${this._id} has no sampled-texture binding ${binding}.`);
    }
    if (!(texture instanceof WebGPUTexture)) {
      throw new TypeError("WebGPU compute requires a WebGPU platform texture.");
    }
    if (this._boundTextures.get(binding) !== texture) {
      this._boundTextures.set(binding, texture);
      this._bindGroup = undefined;
    }
  }

  /** @inheritdoc */
  dispatch(workgroupCountX: number, workgroupCountY: number, workgroupCountZ: number): void {
    if (this._destroyed) {
      throw new Error("Cannot dispatch a destroyed WebGPU compute program.");
    }
    const counts = [workgroupCountX, workgroupCountY, workgroupCountZ];
    const maximum = this._graphicDevice.computeCapabilities.maxWorkgroupsPerDimension;
    if (counts.some((count) => !Number.isInteger(count) || count < 0 || count > maximum)) {
      throw new RangeError(
        `Compute workgroup counts must be integers in [0, ${maximum}], received ${counts.join("x")}.`
      );
    }

    const bindGroup = this._resources.length > 0 || this._storageBuffers.length > 0 ? this._getBindGroup() : undefined;
    const pass = this._graphicDevice._beginComputePass();
    pass.setPipeline(this._pipeline);
    if (bindGroup) {
      pass.setBindGroup(0, bindGroup);
    }
    pass.dispatchWorkgroups(workgroupCountX, workgroupCountY, workgroupCountZ);
  }

  /** @inheritdoc */
  destroy(): void {
    if (!this._destroyed) {
      this._destroyed = true;
      this._boundBuffers.clear();
      this._boundTextures.clear();
      this._bindGroup = undefined;
      this._bindGroupTextureKey = "";
    }
  }

  private _getBindGroup(): GPUBindGroup {
    const textureEntries: GPUBindGroupEntry[] = [];
    const textureKeys: string[] = [];
    for (const resource of this._resources) {
      const texture = this._boundTextures.get(resource.textureBinding);
      if (!texture) {
        throw new Error(`Compute sampled texture "${resource.name}" is not bound.`);
      }
      texture.setUseDepthCompareMode(resource.comparison);
      textureKeys.push(texture.bindingKey);
      textureEntries.push(
        {
          binding: resource.textureBinding,
          resource: texture.view
        },
        {
          binding: resource.samplerBinding,
          resource: texture.sampler
        }
      );
    }
    const textureKey = textureKeys.join("|");
    if (this._bindGroup && this._bindGroupTextureKey === textureKey) {
      return this._bindGroup;
    }

    const bufferEntries = this._storageBuffers.map((storageBuffer) => {
      const buffer = this._boundBuffers.get(storageBuffer.binding);
      if (!buffer) {
        throw new Error(`Compute storage buffer "${storageBuffer.name}" is not bound.`);
      }
      return {
        binding: storageBuffer.binding,
        resource: { buffer: buffer._gpuBuffer }
      };
    });
    this._bindGroupTextureKey = textureKey;
    return (this._bindGroup = this._graphicDevice.device.createBindGroup({
      label: `ComputeProgram ${this._id} bindings`,
      layout: this._bindGroupLayout,
      entries: [...textureEntries, ...bufferEntries]
    }));
  }
}
