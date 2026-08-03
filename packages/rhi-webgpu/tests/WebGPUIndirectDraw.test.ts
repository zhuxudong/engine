import type { IPlatformPrimitive, IPlatformShaderProgram } from "@galacean/engine-design";
import { describe, expect, it, vi } from "vitest";
import { Primitive } from "../../core/src/graphic/Primitive";
import { SubMesh } from "../../core/src/graphic/SubMesh";
import { MeshTopology } from "../../core/src/graphic/enums/MeshTopology";
import type { IPlatformBuffer } from "../../core/src/renderingHardwareInterface/IPlatformBuffer";
import { WebGPUGraphicDevice } from "../src/WebGPUGraphicDevice";

describe("WebGPU indirect draw routing", () => {
  it("forwards core primitive draws to the platform indirect entry point", () => {
    const platformProgram = { id: 7 } as IPlatformShaderProgram;
    const wrappedProgram = { _platformProgram: platformProgram } as unknown as IPlatformShaderProgram;
    const indirectBuffer = { id: "indirect" } as unknown as IPlatformBuffer;
    const platformPrimitive: IPlatformPrimitive = {
      draw: vi.fn(),
      drawIndirect: vi.fn(),
      destroy: vi.fn()
    };
    const primitive = Object.create(Primitive.prototype) as Primitive;
    (primitive as unknown as { _platformPrimitive: IPlatformPrimitive })._platformPrimitive = platformPrimitive;
    primitive._bufferStructChanged = true;
    const subPrimitive = new SubMesh(3, 12, MeshTopology.Triangles);
    const device = Object.create(WebGPUGraphicDevice.prototype) as WebGPUGraphicDevice;

    device.drawPrimitiveIndirect(primitive, subPrimitive, wrappedProgram, indirectBuffer, 40);

    expect(platformPrimitive.draw).not.toHaveBeenCalled();
    expect(platformPrimitive.drawIndirect).toHaveBeenCalledWith(platformProgram, subPrimitive, indirectBuffer, 40);
    expect(primitive._bufferStructChanged).toBe(false);
  });
});
