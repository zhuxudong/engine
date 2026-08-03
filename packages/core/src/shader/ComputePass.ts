import type { IPlatformComputeProgram } from "@galacean/engine-design";
import { EngineObject } from "../base/EngineObject";
import { Engine } from "../Engine";
import { Buffer } from "../graphic/Buffer";
import { BufferBindFlag } from "../graphic/enums/BufferBindFlag";
import { Texture } from "../texture/Texture";
import { Shader } from "./Shader";

/**
 * Backend-neutral compute execution for one ShaderLab compute pass.
 */
export class ComputePass extends EngineObject {
  private readonly _shader: Shader;
  private readonly _platformProgram: IPlatformComputeProgram;
  private readonly _storageBindings = new Map<string, number>();
  private readonly _textureBindings = new Map<string, number>();
  private readonly _buffers = new Map<string, Buffer>();
  private readonly _textures = new Map<string, Texture>();
  private readonly _workgroupSize: readonly [number, number, number];

  /**
   * Resolved device-compatible workgroup dimensions.
   */
  get workgroupSize(): readonly [number, number, number] {
    return this._workgroupSize;
  }

  /**
   * Create a compute pass from a ShaderLab shader.
   * @param engine - Engine that owns the compute device and buffers.
   * @param shader - Shader containing the compute pass.
   * @param subShaderIndex - Sub-shader index.
   * @param passIndex - Pass index inside the sub-shader.
   * @throws If the selected backend or shader pass does not support compute.
   */
  constructor(engine: Engine, shader: Shader, subShaderIndex: number = 0, passIndex: number = 0) {
    super(engine);
    const shaderPass = shader.subShaders[subShaderIndex]?.passes[passIndex];
    if (!shaderPass) {
      throw new RangeError(
        `Compute shader "${shader.name}" has no pass at sub-shader ${subShaderIndex}, pass ${passIndex}.`
      );
    }

    const { source, reflection, workgroupSize } = shaderPass._compileComputeShaderSource(engine);
    for (const storageBuffer of reflection.storageBuffers ?? []) {
      this._storageBindings.set(storageBuffer.name, storageBuffer.binding);
    }
    for (const resource of reflection.resources) {
      this._textureBindings.set(resource.name, resource.textureBinding);
    }

    this._shader = shader;
    this._workgroupSize = workgroupSize;
    this._platformProgram = engine._hardwareRenderer.createPlatformComputeProgram(source, reflection);
    this._shader._addReferCount(1);
  }

  /**
   * Bind a storage buffer by its ShaderLab property name.
   * @param name - ShaderLab storage-buffer name.
   * @param buffer - Buffer created with `BufferBindFlag.StorageBuffer`.
   * @throws If the name is absent, the buffer belongs to another engine, or it lacks storage usage.
   */
  setBuffer(name: string, buffer: Buffer): void {
    const binding = this._storageBindings.get(name);
    if (binding === undefined) {
      throw new Error(`Compute shader "${this._shader.name}" has no storage buffer named "${name}".`);
    }
    if (buffer.engine !== this.engine) {
      throw new Error(`Compute buffer "${name}" belongs to a different engine.`);
    }
    if (!(buffer.type & BufferBindFlag.StorageBuffer)) {
      throw new Error(`Compute buffer "${name}" requires BufferBindFlag.StorageBuffer.`);
    }

    const previous = this._buffers.get(name);
    if (previous === buffer) {
      return;
    }
    previous?._addReferCount(-1);
    buffer._addReferCount(1);
    this._buffers.set(name, buffer);
    this._platformProgram.setBuffer(binding, buffer._platformBuffer);
  }

  /**
   * Bind a sampled texture by its ShaderLab property name.
   * @param name - ShaderLab texture property name.
   * @param texture - Texture owned by the same engine as this pass.
   * @throws If the name is absent or the texture belongs to another engine.
   */
  setTexture(name: string, texture: Texture): void {
    const binding = this._textureBindings.get(name);
    if (binding === undefined) {
      throw new Error(`Compute shader "${this._shader.name}" has no sampled texture named "${name}".`);
    }
    if (texture.engine !== this.engine) {
      throw new Error(`Compute texture "${name}" belongs to a different engine.`);
    }

    const previous = this._textures.get(name);
    if (previous === texture) {
      return;
    }
    previous?._addReferCount(-1);
    texture._addReferCount(1);
    this._textures.set(name, texture);
    this._platformProgram.setTexture(binding, texture._platformTexture);
  }

  /**
   * Encode a direct compute dispatch into the current frame.
   * @param workgroupCountX - Workgroup count on the X axis.
   * @param workgroupCountY - Workgroup count on the Y axis.
   * @param workgroupCountZ - Workgroup count on the Z axis.
   */
  dispatch(workgroupCountX: number, workgroupCountY: number = 1, workgroupCountZ: number = 1): void {
    if (this.destroyed) {
      throw new Error("Cannot dispatch a destroyed compute pass.");
    }
    this._platformProgram.dispatch(workgroupCountX, workgroupCountY, workgroupCountZ);
  }

  protected override _onDestroy(): void {
    this._platformProgram.destroy();
    for (const buffer of this._buffers.values()) {
      buffer._addReferCount(-1);
    }
    this._buffers.clear();
    for (const texture of this._textures.values()) {
      texture._addReferCount(-1);
    }
    this._textures.clear();
    this._shader._addReferCount(-1);
    super._onDestroy();
  }
}
