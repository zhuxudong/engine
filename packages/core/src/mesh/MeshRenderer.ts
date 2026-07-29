import { BoundingBox } from "@galacean/engine-math";
import type { Engine } from "../Engine";
import { Entity } from "../Entity";
import { RenderContext } from "../RenderPipeline/RenderContext";
import { RenderElement } from "../RenderPipeline/RenderElement";
import { Renderer, RendererUpdateFlags } from "../Renderer";
import { Logger } from "../base/Logger";
import { ignoreClone } from "../clone/CloneManager";
import { Buffer, BufferBindFlag } from "../graphic";
import { Mesh, MeshModifyFlags } from "../graphic/Mesh";
import type { Primitive } from "../graphic/Primitive";
import { ShaderMacro } from "../shader/ShaderMacro";
import type { ShadowSliceData } from "../shadow/ShadowSliceData";

/**
 * Draw resources prepared for one renderer in one directional shadow cascade.
 * @internal
 */
export interface MeshRendererShadowViewBinding {
  /** Primitive whose instance stream belongs to the cascade. */
  readonly primitive: Primitive;
  /** Indirect arguments generated for the cascade. */
  readonly indirectBuffer: Buffer;
  /** Byte offset of this sub-mesh's indirect record. */
  readonly indirectOffset: number;
}

/**
 * Prepares and resolves cascade-specific draw streams without modifying the renderer's Forward state.
 * @internal
 */
export interface MeshRendererShadowViewProvider {
  /**
   * Prepares all active directional shadow views before any cascade is rendered.
   * @param context Render context that owns the active camera.
   * @param shadowSlices Stable storage containing the active slices at the beginning of the array.
   * @param shadowSliceCount Number of active slices.
   */
  prepareShadowViews(context: RenderContext, shadowSlices: readonly ShadowSliceData[], shadowSliceCount: number): void;

  /**
   * Resolves the draw resources for one renderer sub-mesh and cascade.
   * @param renderer Renderer requesting the binding.
   * @param shadowCascadeIndex Active directional shadow cascade.
   * @param subMeshIndex Renderer sub-mesh index.
   * @returns Prepared draw resources for the cascade.
   */
  getShadowViewBinding(
    renderer: MeshRenderer,
    shadowCascadeIndex: number,
    subMeshIndex: number
  ): MeshRendererShadowViewBinding;
}

/**
 * MeshRenderer Component.
 */
export class MeshRenderer extends Renderer {
  /** @internal */
  static _enableVertexColorMacro = ShaderMacro.getByName("RENDERER_ENABLE_VERTEXCOLOR");
  private static _shadowViewProviderCounts: WeakMap<Engine, number> = new WeakMap();

  private static _uvMacro = ShaderMacro.getByName("RENDERER_HAS_UV");
  private static _uv1Macro = ShaderMacro.getByName("RENDERER_HAS_UV1");
  private static _normalMacro = ShaderMacro.getByName("RENDERER_HAS_NORMAL");
  private static _tangentMacro = ShaderMacro.getByName("RENDERER_HAS_TANGENT");

  private _enableVertexColor: boolean = false;

  @ignoreClone
  private _indirectDrawBindings: Array<MeshRendererIndirectDrawBinding | undefined> = [];

  /** @internal */
  @ignoreClone
  _shadowViewProvider: MeshRendererShadowViewProvider | null = null;

  /** @internal */
  @ignoreClone
  _mesh: Mesh;

  /**
   * Mesh assigned to the renderer.
   */
  get mesh(): Mesh {
    return this._mesh;
  }

  set mesh(value: Mesh) {
    if (this._mesh !== value) {
      this._setMesh(value);
    }
  }

  /**
   * Whether enable vertex color.
   */
  get enableVertexColor(): boolean {
    return this._enableVertexColor;
  }

  set enableVertexColor(value: boolean) {
    if (value !== this._enableVertexColor) {
      this._dirtyUpdateFlag |= MeshRendererUpdateFlags.VertexElementMacro;
      this._enableVertexColor = value;
    }
  }

  /** @internal */
  _setIndirectDrawBuffer(subMeshIndex: number, buffer: Buffer | null, offset: number = 0): void {
    if (!Number.isInteger(subMeshIndex) || subMeshIndex < 0) {
      throw new RangeError(`Indirect draw sub-mesh index ${subMeshIndex} must be a non-negative integer.`);
    }
    if (!Number.isInteger(offset) || offset < 0 || (offset & 3) !== 0) {
      throw new RangeError(`Indirect draw offset ${offset} must be a non-negative multiple of 4.`);
    }
    if (buffer) {
      if (buffer.engine !== this.engine) {
        throw new Error("Indirect draw buffer must belong to the renderer's engine.");
      }
      if (!(buffer.type & BufferBindFlag.IndirectBuffer)) {
        throw new Error("Indirect draw buffer must include BufferBindFlag.IndirectBuffer.");
      }
    }

    const bindings = this._indirectDrawBindings;
    const previous = bindings[subMeshIndex];
    if (previous?.buffer === buffer && previous.offset === offset) return;
    if (previous && !previous.buffer.destroyed) this._addResourceReferCount(previous.buffer, -1);
    if (buffer) {
      this._addResourceReferCount(buffer, 1);
      bindings[subMeshIndex] = { buffer, offset };
    } else {
      bindings[subMeshIndex] = undefined;
    }
  }

  /** @internal */
  _setShadowViewProvider(provider: MeshRendererShadowViewProvider | null): void {
    const previous = this._shadowViewProvider;
    if (provider === previous) return;

    const engine = this.engine;
    const counts = MeshRenderer._shadowViewProviderCounts;
    const previousCount = counts.get(engine) ?? 0;
    if (previous) {
      if (previousCount === 1) {
        counts.delete(engine);
      } else {
        counts.set(engine, previousCount - 1);
      }
    }
    if (provider) {
      counts.set(engine, (counts.get(engine) ?? 0) + 1);
    }
    this._shadowViewProvider = provider;
  }

  /** @internal */
  static _hasShadowViewProviders(engine: Engine): boolean {
    return MeshRenderer._shadowViewProviderCounts.has(engine);
  }

  /**
   * @internal
   */
  constructor(entity: Entity) {
    super(entity);
    this._onMeshChanged = this._onMeshChanged.bind(this);
  }

  /**
   * @internal
   */
  protected override _onDestroy(): void {
    for (const binding of this._indirectDrawBindings) {
      if (binding && !binding.buffer.destroyed) this._addResourceReferCount(binding.buffer, -1);
    }
    this._indirectDrawBindings.length = 0;
    this._setShadowViewProvider(null);
    const mesh = this._mesh;
    if (mesh) {
      mesh.destroyed || this._addResourceReferCount(mesh, -1);
      mesh._updateFlagManager.removeListener(this._onMeshChanged);
      this._mesh = null;
    }

    super._onDestroy();
  }

  /**
   * @internal
   */
  override _cloneTo(target: MeshRenderer): void {
    super._cloneTo(target);
    target.mesh = this._mesh;
  }

  /**
   * @internal
   */
  override _prepareRender(context: RenderContext): void {
    if (!this._mesh) {
      Logger.error("mesh is null.");
      return;
    }
    if (this._mesh.destroyed) {
      Logger.error("mesh is destroyed.");
      return;
    }
    super._prepareRender(context);
  }

  /**
   * @internal
   */
  protected override _updateBounds(worldBounds: BoundingBox): void {
    const mesh = this._mesh;
    if (mesh) {
      const localBounds = mesh.bounds;
      BoundingBox.transform(localBounds, this._transformEntity.transform.worldMatrix, worldBounds);
    } else {
      const { worldPosition } = this._transformEntity.transform;
      worldBounds.min.copyFrom(worldPosition);
      worldBounds.max.copyFrom(worldPosition);
    }
  }

  /**
   * @internal
   */
  protected override _render(context: RenderContext): void {
    const mesh = this._mesh;
    if (this._dirtyUpdateFlag & MeshRendererUpdateFlags.VertexElementMacro) {
      const shaderData = this.shaderData;
      const vertexElements = mesh._primitive.vertexElements;

      shaderData.disableMacro(MeshRenderer._uvMacro);
      shaderData.disableMacro(MeshRenderer._uv1Macro);
      shaderData.disableMacro(MeshRenderer._normalMacro);
      shaderData.disableMacro(MeshRenderer._tangentMacro);
      shaderData.disableMacro(MeshRenderer._enableVertexColorMacro);

      for (let i = 0, n = vertexElements.length; i < n; i++) {
        switch (vertexElements[i].attribute) {
          case "TEXCOORD_0":
            shaderData.enableMacro(MeshRenderer._uvMacro);
            break;
          case "TEXCOORD_1":
            shaderData.enableMacro(MeshRenderer._uv1Macro);
            break;
          case "NORMAL":
            shaderData.enableMacro(MeshRenderer._normalMacro);
            break;
          case "TANGENT":
            shaderData.enableMacro(MeshRenderer._tangentMacro);
            break;
          case "COLOR_0":
            this._enableVertexColor && shaderData.enableMacro(MeshRenderer._enableVertexColorMacro);
            break;
        }
      }
      this._dirtyUpdateFlag &= ~MeshRendererUpdateFlags.VertexElementMacro;
    }

    const { _materials: materials, _engine: engine } = this;
    const subMeshes = mesh.subMeshes;
    const priority = this.priority;
    const distanceForSort = this._distanceForSort;
    const renderElementPool = engine._renderElementPool;
    const renderPipeline = context.camera._renderPipeline;
    const shadowCascadeIndex = context.shadowCascadeIndex;
    const shadowViewProvider = shadowCascadeIndex >= 0 ? this._shadowViewProvider : null;
    for (let i = 0, n = subMeshes.length; i < n; i++) {
      let material = materials[i];
      if (!material) {
        continue;
      }
      if (material.destroyed || material.shader.destroyed) {
        material = this.engine._basicResources.meshMagentaMaterial;
      }

      const renderElement = renderElementPool.get();
      if (shadowViewProvider) {
        const shadowBinding = shadowViewProvider.getShadowViewBinding(this, shadowCascadeIndex, i);
        if (!shadowBinding) {
          throw new Error(`Missing shadow-view draw binding for cascade ${shadowCascadeIndex}, sub-mesh ${i}.`);
        }
        renderElement.set(this, material, shadowBinding.primitive, subMeshes[i]);
        renderElement.indirectBuffer = shadowBinding.indirectBuffer;
        renderElement.indirectOffset = shadowBinding.indirectOffset;
      } else {
        renderElement.set(this, material, mesh._primitive, subMeshes[i]);
        const indirectBinding = this._indirectDrawBindings[i];
        if (indirectBinding) {
          renderElement.indirectBuffer = indirectBinding.buffer;
          renderElement.indirectOffset = indirectBinding.offset;
        }
      }
      renderElement.priority = priority;
      renderElement.distanceForSort = distanceForSort;
      renderPipeline.pushRenderElement(context, renderElement);
    }
  }

  /**
   * @internal
   */
  override _canBatch(preElement: RenderElement, curElement: RenderElement): boolean {
    // Indirect arguments already define a complete instance stream and cannot be replaced by CPU renderer instancing.
    if (preElement.indirectBuffer || curElement.indirectBuffer) return false;
    if (!this._engine._hardwareRenderer.isWebGL2) return false;
    const curShaderData = curElement.component.shaderData;
    return (
      preElement.primitive === curElement.primitive &&
      preElement.subPrimitive === curElement.subPrimitive &&
      preElement.material === curElement.material &&
      this._isFrontFaceInvert() === (<MeshRenderer>curElement.component)._isFrontFaceInvert() &&
      this.shaderData._macroCollection.isEqual(curShaderData._macroCollection) &&
      // Renderer-group samplers/arrays are shared across the whole instanced draw call
      this.shaderData._matchesRendererBatchShared(curShaderData)
    );
  }

  /**
   * @internal
   */
  override _batch(preElement: RenderElement | null, curElement: RenderElement): void {
    if (!preElement) return;
    const renderers = preElement.instancedRenderers;
    if (renderers.length === 0) {
      renderers.push(preElement.component);
    }
    renderers.push(curElement.component);
  }

  private _setMesh(mesh: Mesh): void {
    const lastMesh = this._mesh;
    if (lastMesh) {
      this._addResourceReferCount(lastMesh, -1);
      lastMesh._updateFlagManager.removeListener(this._onMeshChanged);
    }
    if (mesh) {
      this._addResourceReferCount(mesh, 1);
      mesh._updateFlagManager.addListener(this._onMeshChanged);
      this._dirtyUpdateFlag |= MeshRendererUpdateFlags.All;
    }
    this._mesh = mesh;
  }

  @ignoreClone
  private _onMeshChanged(type: MeshModifyFlags): void {
    type & MeshModifyFlags.Bounds && (this._dirtyUpdateFlag |= RendererUpdateFlags.WorldVolume);
    type & MeshModifyFlags.VertexElements && (this._dirtyUpdateFlag |= MeshRendererUpdateFlags.VertexElementMacro);
  }
}

interface MeshRendererIndirectDrawBinding {
  readonly buffer: Buffer;
  readonly offset: number;
}

/**
 * @remarks Extends `RendererUpdateFlags`.
 */
enum MeshRendererUpdateFlags {
  /** VertexElementMacro. */
  VertexElementMacro = 0x2,
  /** All. */
  All = 0x3
}
