import { IndexFormat, MeshTopology, Primitive, SubPrimitive, VertexElementFormat } from "@galacean/engine-core";
import type { IPlatformPrimitive, IPlatformShaderProgram, IShaderVertexInputReflection } from "@galacean/engine-design";
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

  constructor(device: WebGPUGraphicDevice, primitive: Primitive) {
    this._device = device;
    this.primitive = primitive;
  }

  draw(shaderProgram: IPlatformShaderProgram, subPrimitive: SubPrimitive): void {
    (shaderProgram as WebGPUShaderProgram).draw(this, subPrimitive);
  }

  destroy(): void {}

  /** @internal */
  _getVertexState(inputs: readonly IShaderVertexInputReflection[]): {
    buffers: Array<GPUVertexBufferLayout | null>;
    key: string;
  } {
    const locations = new Map(inputs.map((input) => [input.name, input.location]));
    const primitive = this.primitive;
    const bufferCount = primitive.vertexBufferBindings.length;
    const buffers = new Array<GPUVertexBufferLayout | null>(bufferCount).fill(null);

    for (let bindingIndex = 0; bindingIndex < bufferCount; bindingIndex++) {
      const binding = primitive.vertexBufferBindings[bindingIndex];
      if (!binding) {
        continue;
      }

      const attributes: GPUVertexAttribute[] = [];
      let instanceStepRate = 0;
      for (const element of primitive.vertexElements) {
        if (element.bindingIndex !== bindingIndex) {
          continue;
        }
        const shaderLocation = locations.get(element.attribute);
        if (shaderLocation === undefined) {
          continue;
        }
        if (element.instanceStepRate > 1) {
          throw new Error(
            `WebGPU vertex attribute "${element.attribute}" uses unsupported instance step rate ${element.instanceStepRate}.`
          );
        }
        if (attributes.length > 0 && instanceStepRate !== element.instanceStepRate) {
          throw new Error(`WebGPU vertex buffer ${bindingIndex} mixes vertex and instance attributes.`);
        }
        instanceStepRate = element.instanceStepRate;
        attributes.push({
          shaderLocation,
          offset: element.offset,
          format: WebGPUPrimitive._vertexFormat(element.format)
        });
      }

      if (attributes.length > 0) {
        attributes.sort((left, right) => left.shaderLocation - right.shaderLocation);
        buffers[bindingIndex] = {
          arrayStride: binding.stride,
          stepMode: instanceStepRate === 0 ? "vertex" : "instance",
          attributes
        };
      }
    }

    return { buffers, key: JSON.stringify(buffers) };
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
    return state;
  }

  /** @internal */
  _encodeDraw(pass: GPURenderPassEncoder, subPrimitive: SubPrimitive): void {
    const primitive = this.primitive;
    for (let index = 0; index < primitive.vertexBufferBindings.length; index++) {
      const binding = primitive.vertexBufferBindings[index];
      if (binding) {
        pass.setVertexBuffer(index, (binding.buffer._platformBuffer as WebGPUBuffer)._gpuBuffer);
      }
    }

    const instanceCount = primitive.instanceCount || 1;
    const indexBinding = primitive.indexBufferBinding;
    if (indexBinding) {
      const format = this._indexFormat();
      pass.setIndexBuffer((indexBinding.buffer._platformBuffer as WebGPUBuffer)._gpuBuffer, format);
      pass.drawIndexed(subPrimitive.count, instanceCount, subPrimitive.start, 0, 0);
    } else {
      pass.draw(subPrimitive.count, instanceCount, subPrimitive.start, 0);
    }
  }

  private _indexFormat(): GPUIndexFormat {
    switch (this.primitive.indexBufferBinding.format) {
      case IndexFormat.UInt16:
        return "uint16";
      case IndexFormat.UInt32:
        return "uint32";
      case IndexFormat.UInt8:
        throw new Error("WebGPU does not support 8-bit index buffers.");
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
        throw new Error("WebGPU does not support line-loop topology.");
      case MeshTopology.TriangleFan:
        throw new Error("WebGPU does not support triangle-fan topology.");
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
}
