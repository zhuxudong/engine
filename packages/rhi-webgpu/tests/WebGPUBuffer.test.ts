import {
  BufferBindFlag,
  BufferUsage,
  DataType,
  IndexFormat,
  MeshTopology,
  type Primitive,
  SubMesh,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine-core";
import { describe, expect, it, vi } from "vitest";
import { GLBuffer } from "../../rhi-webgl/src/GLBuffer";
import { GLPrimitive } from "../../rhi-webgl/src/GLPrimitive";
import type { WebGLGraphicDevice } from "../../rhi-webgl/src/WebGLGraphicDevice";
import { WebGPUBuffer } from "../src/WebGPUBuffer";
import type { WebGPUGraphicDevice } from "../src/WebGPUGraphicDevice";
import { WebGPUPrimitive } from "../src/WebGPUPrimitive";

Object.defineProperty(globalThis, "GPUBufferUsage", {
  configurable: true,
  value: {
    MAP_READ: 1,
    MAP_WRITE: 2,
    COPY_SRC: 4,
    COPY_DST: 8,
    INDEX: 16,
    VERTEX: 32,
    UNIFORM: 64,
    STORAGE: 128,
    INDIRECT: 256,
    QUERY_RESOLVE: 512
  }
});

describe("WebGPU buffer bindings", () => {
  it("combines vertex and storage usage", () => {
    const descriptors: GPUBufferDescriptor[] = [];
    const buffer = new WebGPUBuffer(
      createDevice(descriptors),
      BufferBindFlag.VertexBuffer | BufferBindFlag.StorageBuffer,
      64,
      BufferUsage.Dynamic
    );

    expect(descriptors).toHaveLength(1);
    const usage = descriptors[0].usage;
    expect(usage & GPUBufferUsage.VERTEX).toBeTruthy();
    expect(usage & GPUBufferUsage.STORAGE).toBeTruthy();
    expect(usage & GPUBufferUsage.COPY_SRC).toBeTruthy();
    expect(usage & GPUBufferUsage.COPY_DST).toBeTruthy();
    expect(descriptors[0].label).toBe("Vertex|Storage buffer");
    buffer.destroy();
  });

  it("combines storage and indirect usage", () => {
    const descriptors: GPUBufferDescriptor[] = [];
    const buffer = new WebGPUBuffer(
      createDevice(descriptors),
      BufferBindFlag.StorageBuffer | BufferBindFlag.IndirectBuffer,
      20,
      BufferUsage.Dynamic
    );

    const descriptor = descriptors[0];
    expect(descriptor.size).toBe(20);
    expect(descriptor.usage & GPUBufferUsage.STORAGE).toBeTruthy();
    expect(descriptor.usage & GPUBufferUsage.INDIRECT).toBeTruthy();
    expect(descriptor.label).toBe("Storage|Indirect buffer");
    buffer.destroy();
  });

  it("rejects empty and unknown WebGPU bindings", () => {
    expect(() => new WebGPUBuffer(createDevice([]), 0, 4, BufferUsage.Static)).toThrow(
      "Unsupported buffer bindings: 0"
    );
    expect(() => new WebGPUBuffer(createDevice([]), 1 << 10, 4, BufferUsage.Static)).toThrow(
      "Unsupported buffer bindings: 1024"
    );
  });

  it("rejects storage and indirect bindings on WebGL", () => {
    expect(
      () =>
        new GLBuffer(
          {} as WebGLGraphicDevice,
          BufferBindFlag.VertexBuffer | BufferBindFlag.StorageBuffer,
          64,
          BufferUsage.Dynamic
        )
    ).toThrow("Storage and indirect buffer bindings are not supported by the WebGL backend.");
  });

  it("maps half-float vertex attributes on WebGPU", () => {
    const packed2 = new VertexElement("PACKED2", 0, VertexElementFormat.Float16Vector2, 0, 1);
    const packed4 = new VertexElement("PACKED4", 4, VertexElementFormat.Float16Vector4, 0, 1);
    const primitive = new WebGPUPrimitive(
      {
        device: { limits: { maxVertexBuffers: 8 } }
      } as unknown as WebGPUGraphicDevice,
      {
        vertexBufferBindings: [{ stride: 12 }],
        vertexElements: [packed2, packed4]
      } as unknown as Primitive
    );

    const state = primitive._getVertexState([
      { name: "PACKED2", location: 0, type: "vec2" },
      { name: "PACKED4", location: 1, type: "vec4" }
    ]);

    expect(packed2._formatMetaInfo).toMatchObject({ size: 2, type: DataType.HALF_FLOAT, normalized: false });
    expect(packed4._formatMetaInfo).toMatchObject({ size: 4, type: DataType.HALF_FLOAT, normalized: false });
    expect(state.buffers[0]?.attributes).toEqual([
      { shaderLocation: 0, offset: 0, format: "float16x2" },
      { shaderLocation: 1, offset: 4, format: "float16x4" }
    ]);
  });

  it("rejects half-float vertex attributes on WebGL1", () => {
    const packed = new VertexElement("PACKED", 0, VertexElementFormat.Float16Vector4, 0, 1);
    const glPrimitive = new GLPrimitive(
      {
        canIUse: () => false,
        isWebGL2: false,
        gl: {
          bindBuffer: vi.fn(),
          enableVertexAttribArray: vi.fn()
        }
      } as unknown as WebGLGraphicDevice,
      {
        enableVAO: false,
        vertexBufferBindings: [{ buffer: { _platformBuffer: { _glBuffer: {} } }, stride: 8, offset: 0 }],
        _vertexElementMap: { PACKED: packed }
      } as unknown as Primitive
    );

    expect(() => glPrimitive.draw({ attributeLocation: { PACKED: 0 } } as never, new SubMesh(0, 3))).toThrow(
      "Half-float vertex attributes require WebGL2."
    );
  });

  it("encodes indexed and non-indexed indirect draws", () => {
    const indirect = new WebGPUBuffer(
      createDevice([]),
      BufferBindFlag.StorageBuffer | BufferBindFlag.IndirectBuffer,
      36,
      BufferUsage.Dynamic
    );
    const indexGPUBuffer = {} as GPUBuffer;
    const indexedPrimitive = createPrimitive({
      format: IndexFormat.UInt16,
      buffer: { _platformBuffer: { _gpuBuffer: indexGPUBuffer } }
    });
    const indexedPass = createRenderPass();

    indexedPrimitive._encodeDraw(indexedPass.pass, new SubMesh(2, 6, MeshTopology.Triangles), undefined, indirect, 16);

    expect(indexedPass.setIndexBuffer).toHaveBeenCalledWith(indexGPUBuffer, "uint16");
    expect(indexedPass.drawIndexedIndirect).toHaveBeenCalledWith(indirect._gpuBuffer, 16);
    expect(indexedPass.drawIndexed).not.toHaveBeenCalled();

    const nonIndexedPrimitive = createPrimitive();
    const nonIndexedPass = createRenderPass();
    nonIndexedPrimitive._encodeDraw(
      nonIndexedPass.pass,
      new SubMesh(0, 3, MeshTopology.Triangles),
      undefined,
      indirect,
      0
    );
    expect(nonIndexedPass.drawIndirect).toHaveBeenCalledWith(indirect._gpuBuffer, 0);
    expect(nonIndexedPass.draw).not.toHaveBeenCalled();
    indirect.destroy();
  });

  it("validates indirect bindings, alignment, and record size", () => {
    const pass = createRenderPass().pass;
    const indexedPrimitive = createPrimitive({
      format: IndexFormat.UInt16,
      buffer: { _platformBuffer: { _gpuBuffer: {} as GPUBuffer } }
    });
    const directOnly = new WebGPUBuffer(createDevice([]), BufferBindFlag.StorageBuffer, 20, BufferUsage.Dynamic);
    const indirect = new WebGPUBuffer(createDevice([]), BufferBindFlag.IndirectBuffer, 20, BufferUsage.Dynamic);

    expect(() => indexedPrimitive._encodeDraw(pass, new SubMesh(0, 3), undefined, directOnly, 0)).toThrow(
      "Indirect draw requires a buffer created with BufferBindFlag.IndirectBuffer."
    );
    expect(() => indexedPrimitive._encodeDraw(pass, new SubMesh(0, 3), undefined, indirect, 2)).toThrow(
      "Indirect draw offset 2 must be a non-negative multiple of 4."
    );
    expect(() => indexedPrimitive._encodeDraw(pass, new SubMesh(0, 3), undefined, indirect, 4)).toThrow(
      "Indirect draw arguments [4, 24) exceed 20 bytes."
    );
    directOnly.destroy();
    indirect.destroy();
  });
});

function createDevice(descriptors: GPUBufferDescriptor[]): WebGPUGraphicDevice {
  return {
    device: {
      createBuffer(descriptor: GPUBufferDescriptor): GPUBuffer {
        descriptors.push(descriptor);
        return { destroy() {} } as GPUBuffer;
      }
    }
  } as unknown as WebGPUGraphicDevice;
}

function createPrimitive(indexBufferBinding?: unknown): WebGPUPrimitive {
  return new WebGPUPrimitive(
    {} as WebGPUGraphicDevice,
    {
      vertexBufferBindings: [],
      indexBufferBinding,
      instanceCount: 0
    } as Primitive
  );
}

function createRenderPass(): {
  pass: GPURenderPassEncoder;
  setIndexBuffer: ReturnType<typeof vi.fn>;
  drawIndexed: ReturnType<typeof vi.fn>;
  drawIndexedIndirect: ReturnType<typeof vi.fn>;
  draw: ReturnType<typeof vi.fn>;
  drawIndirect: ReturnType<typeof vi.fn>;
} {
  const setIndexBuffer = vi.fn();
  const drawIndexed = vi.fn();
  const drawIndexedIndirect = vi.fn();
  const draw = vi.fn();
  const drawIndirect = vi.fn();
  return {
    pass: {
      setIndexBuffer,
      drawIndexed,
      drawIndexedIndirect,
      draw,
      drawIndirect
    } as unknown as GPURenderPassEncoder,
    setIndexBuffer,
    drawIndexed,
    drawIndexedIndirect,
    draw,
    drawIndirect
  };
}
