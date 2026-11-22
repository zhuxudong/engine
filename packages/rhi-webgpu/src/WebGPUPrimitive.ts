import {
  IndexFormat,
  type IPlatformPrimitive,
  type IPlatformShaderProgram,
  MeshTopology,
  Primitive,
  SubPrimitive,
  VertexElementFormat
} from "@galacean/engine-core";
import type { IPlatformShaderSource } from "@galacean/engine-core";
interface VertexStream {
  binding: number;
  rate: number;
  slot: number;
  expanded?: GPUBuffer;
}
interface VertexLayout {
  buffers: Array<GPUVertexBufferLayout | null>;
  defaultBufferSlot?: number;
  key: string;
  streams: VertexStream[];
}
type IShaderVertexInputReflection = NonNullable<IPlatformShaderSource["reflection"]>["vertexInputs"][number];
import { WebGPUPrimitiveEmulation } from "./WebGPUPrimitiveEmulation";
import { WebGPUBuffer } from "./WebGPUBuffer";
import type { WebGPUGraphicDevice } from "./WebGPUGraphicDevice";
import { WebGPUShaderProgram } from "./WebGPUShaderProgram";

/**
 * WebGPU primitive binding.
 * @internal
 */
export class WebGPUPrimitive implements IPlatformPrimitive {
  /** @internal */
  readonly primitive: Primitive;

  private readonly _device: WebGPUGraphicDevice;
  private readonly _layouts = new Map<readonly IShaderVertexInputReflection[], VertexLayout>();
  private _emulation?: WebGPUPrimitiveEmulation;

  constructor(device: WebGPUGraphicDevice, primitive: Primitive) {
    this._device = device;
    this.primitive = primitive;
  }

  draw(shaderProgram: IPlatformShaderProgram, subPrimitive: SubPrimitive): void {
    (shaderProgram as WebGPUShaderProgram).draw(this, subPrimitive);
  }

  destroy(): void {
    this._emulation?.destroy();
    this._layouts.clear();
  }

  _prepareIndexBuffer(sub: SubPrimitive, vertex: VertexLayout): GPUBuffer | undefined {
    for (const stream of vertex.streams) {
      if (stream.rate > 1) {
        this._emulation ??= new WebGPUPrimitiveEmulation(this._device);
        stream.expanded = this._emulation.instances(
          this.primitive.vertexBufferBindings[stream.binding]!,
          stream.rate,
          this.primitive.instanceCount || 1
        );
      }
    }
    if (sub.topology === MeshTopology.LineLoop || sub.topology === MeshTopology.TriangleFan) {
      this._emulation ??= new WebGPUPrimitiveEmulation(this._device);
      return this._emulation.indexBuffer(sub, this.primitive.indexBufferBinding);
    }
    const binding = this.primitive.indexBufferBinding;
    if (!binding) return undefined;
    const buffer = binding.buffer._platformBuffer as WebGPUBuffer;
    return binding.format === IndexFormat.UInt8 ? buffer._getUInt16Indices() : buffer._gpuBuffer;
  }

  /** @internal */
  _getVertexState(inputs: readonly IShaderVertexInputReflection[]): VertexLayout {
    if (this.primitive._bufferStructChanged) this._layouts.clear();
    const cached = this._layouts.get(inputs);
    if (cached) return cached;
    const locations = new Map(inputs.map((input) => [input.name, input.location]));
    const boundLocations = new Set<number>();
    const primitive = this.primitive;
    const bufferCount = primitive.vertexBufferBindings.length;
    const buffers = new Array<GPUVertexBufferLayout | null>(bufferCount).fill(null);

    const streams: VertexStream[] = [];
    for (let bindingIndex = 0; bindingIndex < bufferCount; bindingIndex++) {
      const binding = primitive.vertexBufferBindings[bindingIndex];
      if (!binding) {
        continue;
      }

      const byRate = new Map<number, GPUVertexAttribute[]>();
      for (const element of primitive.vertexElements) {
        if (element.bindingIndex !== bindingIndex) {
          continue;
        }
        const shaderLocation = locations.get(element.attribute);
        if (shaderLocation === undefined) {
          continue;
        }
        let attributes = byRate.get(element.instanceStepRate);
        if (!attributes) byRate.set(element.instanceStepRate, (attributes = []));
        attributes.push({
          shaderLocation,
          offset: element.offset,
          format: WebGPUPrimitive._vertexFormat(element.format)
        });
        boundLocations.add(shaderLocation);
      }

      let first = true;
      for (const [instanceStepRate, attributes] of byRate) {
        const slot = first ? bindingIndex : buffers.length;
        first = false;
        streams.push({ binding: bindingIndex, rate: instanceStepRate, slot });
        attributes.sort((left, right) => left.shaderLocation - right.shaderLocation);
        buffers[slot] = {
          arrayStride: binding.stride,
          stepMode: instanceStepRate === 0 ? "vertex" : "instance",
          attributes
        };
      }
    }

    const missingInputs = inputs.filter((input) => !boundLocations.has(input.location));
    let defaultBufferSlot: number | undefined;
    if (missingInputs.length > 0) {
      defaultBufferSlot = buffers.findIndex((buffer) => buffer === null);
      if (defaultBufferSlot < 0) {
        defaultBufferSlot = buffers.length;
        buffers.push(null);
      }
      if (defaultBufferSlot >= this._device.device.limits.maxVertexBuffers) {
        throw new Error(
          `WebGPU primitive needs a fallback vertex buffer at slot ${defaultBufferSlot}, exceeding maxVertexBuffers ${this._device.device.limits.maxVertexBuffers}.`
        );
      }
      buffers[defaultBufferSlot] = {
        arrayStride: 0,
        stepMode: "vertex",
        attributes: missingInputs.map(WebGPUPrimitive._defaultVertexAttribute)
      };
    }

    const result = { buffers, defaultBufferSlot, streams, key: JSON.stringify(buffers) };
    this._layouts.set(inputs, result);
    return result;
  }

  /** @internal */
  _getPrimitiveState(topology: MeshTopology): GPUPrimitiveState {
    const state: GPUPrimitiveState = {
      topology: WebGPUPrimitive._topology(topology)
    };
    if (
      this.primitive.indexBufferBinding &&
      (topology === MeshTopology.LineStrip || topology === MeshTopology.TriangleStrip)
    ) {
      state.stripIndexFormat = this._indexFormat();
    }
    if (topology === MeshTopology.LineLoop) state.stripIndexFormat = "uint32";
    return state;
  }

  /** @internal */
  _encodeDraw(
    pass: GPURenderPassEncoder,
    subPrimitive: SubPrimitive,
    vertex: VertexLayout,
    indexBuffer?: GPUBuffer
  ): void {
    const primitive = this.primitive;
    const { defaultBufferSlot, streams } = vertex;
    for (let i = 0; i < streams.length; i++) {
      const stream = streams[i];
      const buffer = primitive.vertexBufferBindings[stream.binding]!.buffer._platformBuffer as WebGPUBuffer;
      buffer._markUsed();
      this._device._setVertexBuffer(pass, stream.slot, stream.expanded ?? buffer._gpuBuffer);
    }
    if (defaultBufferSlot !== undefined) {
      this._device._setVertexBuffer(pass, defaultBufferSlot, this._device._getDefaultVertexBuffer());
    }

    const instanceCount = primitive.instanceCount || 1;
    const indexBinding = primitive.indexBufferBinding;
    if (subPrimitive.topology === MeshTopology.LineLoop || subPrimitive.topology === MeshTopology.TriangleFan) {
      this._device._setIndexBuffer(pass, indexBuffer!, "uint32");
      pass.drawIndexed(this._emulation!.expandedCount(subPrimitive), instanceCount);
    } else if (indexBinding) {
      const format = this._indexFormat();
      const buffer = indexBinding.buffer._platformBuffer as WebGPUBuffer;
      buffer._markUsed();
      this._device._setIndexBuffer(pass, indexBuffer, format);
      pass.drawIndexed(subPrimitive.count, instanceCount, subPrimitive.start, 0, 0);
    } else {
      pass.draw(subPrimitive.count, instanceCount, subPrimitive.start, 0);
    }
  }

  private _indexFormat(): GPUIndexFormat {
    switch (this.primitive.indexBufferBinding.format) {
      case IndexFormat.UInt8:
      case IndexFormat.UInt16:
        return "uint16";
      case IndexFormat.UInt32:
        return "uint32";
      default:
        throw new Error(`Unsupported index format ${this.primitive.indexBufferBinding.format}.`);
    }
  }

  private static _topology(topology: MeshTopology): GPUPrimitiveTopology {
    switch (topology) {
      case MeshTopology.Points:
        return "point-list";
      case MeshTopology.Lines:
        return "line-list";
      case MeshTopology.LineStrip:
        return "line-strip";
      case MeshTopology.Triangles:
        return "triangle-list";
      case MeshTopology.TriangleStrip:
        return "triangle-strip";
      case MeshTopology.LineLoop:
        return "line-strip";
      case MeshTopology.TriangleFan:
        return "triangle-list";
    }
  }

  private static _vertexFormat(format: VertexElementFormat): GPUVertexFormat {
    switch (format) {
      case VertexElementFormat.Float:
        return "float32";
      case VertexElementFormat.Vector2:
        return "float32x2";
      case VertexElementFormat.Vector3:
        return "float32x3";
      case VertexElementFormat.Vector4:
        return "float32x4";
      case VertexElementFormat.Byte4:
        return "sint8x4";
      case VertexElementFormat.UByte4:
        return "uint8x4";
      case VertexElementFormat.NormalizedByte4:
        return "snorm8x4";
      case VertexElementFormat.NormalizedUByte4:
        return "unorm8x4";
      case VertexElementFormat.Short2:
        return "sint16x2";
      case VertexElementFormat.UShort2:
        return "uint16x2";
      case VertexElementFormat.NormalizedShort2:
        return "snorm16x2";
      case VertexElementFormat.NormalizedUShort2:
        return "unorm16x2";
      case VertexElementFormat.Short4:
        return "sint16x4";
      case VertexElementFormat.UShort4:
        return "uint16x4";
      case VertexElementFormat.NormalizedShort4:
        return "snorm16x4";
      case VertexElementFormat.NormalizedUShort4:
        return "unorm16x4";
    }
  }

  private static _defaultVertexAttribute(input: IShaderVertexInputReflection): GPUVertexAttribute {
    const { type, location: shaderLocation, components } = input;
    const scalar = type === "float" ? "float32" : type === "sint" ? "sint32" : "uint32";
    const format = (components === 1 ? scalar : `${scalar}x${components}`) as GPUVertexFormat;
    return { shaderLocation, offset: type === "float" ? 0 : type === "sint" ? 16 : 32, format };
  }
}
