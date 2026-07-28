import { BufferBindFlag, BufferUsage } from "@galacean/engine-core";
import { describe, expect, it } from "vitest";
import { GLBuffer } from "../../rhi-webgl/src/GLBuffer";
import type { WebGLGraphicDevice } from "../../rhi-webgl/src/WebGLGraphicDevice";
import { WebGPUBuffer } from "../src/WebGPUBuffer";
import type { WebGPUGraphicDevice } from "../src/WebGPUGraphicDevice";

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
