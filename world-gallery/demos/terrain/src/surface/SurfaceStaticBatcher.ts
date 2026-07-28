import {
  BoundingBox,
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Engine,
  Entity,
  GLTFResource,
  MeshRenderer,
  Vector3
} from "@galacean/engine";
import type { SurfaceCategory, SurfaceCellRange } from "./SurfaceContract";
import {
  createSurfaceInstancedMesh,
  expandSurfaceBounds,
  findSurfaceModelMeshes,
  SURFACE_INSTANCE_STRIDE,
  transformSurfaceBounds
} from "./SurfaceInstancedMesh";
import { SurfaceMaterial } from "./SurfaceMaterial";
import { SURFACE_RUNTIME_SCALE_MAX, type SurfacePrototypeSpec } from "./SurfaceRuntimeContract";

/** One decoded cell range consumed by a compacted single-LOD renderer batch. */
export interface SurfaceStaticBatcherRange {
  /** Manifest range retaining the visibility and diagnostic cell boundary. */
  readonly range: SurfaceCellRange;
  /** Runtime transform/color records sorted by density priority. */
  readonly data: Float32Array;
  /** Largest authored instance scale in this range. */
  readonly maxScale: number;
}

interface SurfaceStaticRangeState extends SurfaceStaticBatcherRange {
  visibleCount: number;
}

interface InternalIndirectDrawRenderer extends MeshRenderer {
  _setIndirectDrawBuffer(subMeshIndex: number, buffer: Buffer | null, offset?: number): void;
}

const INDIRECT_ARGUMENT_WORD_STRIDE = 5;

/**
 * Compacts visible single-LOD cell ranges into one instance stream per prototype.
 *
 * @internal
 */
export class SurfaceStaticBatcher {
  /** Surface category shared by the compacted prototype. */
  readonly category: SurfaceCategory;
  /** Prototype-space radius used by cell culling. */
  readonly prototypeRadius: number;
  /** LOD-0 prototype height used by projected-size selection. */
  readonly lodHeight: number;

  private readonly _instanceBuffer: Buffer;
  private readonly _instanceOutput: Float32Array;
  private readonly _indirectBuffer: Buffer;
  private readonly _indirectArguments: Uint32Array;
  private readonly _ranges: ReadonlyMap<number, SurfaceStaticRangeState>;
  private readonly _renderers: readonly MeshRenderer[];
  private _dirty = true;
  private _instanceCount = 0;

  private constructor(
    instanceBuffer: Buffer,
    instanceOutput: Float32Array,
    indirectBuffer: Buffer,
    indirectArguments: Uint32Array,
    ranges: ReadonlyMap<number, SurfaceStaticRangeState>,
    renderers: readonly MeshRenderer[],
    category: SurfaceCategory,
    prototypeRadius: number,
    lodHeight: number
  ) {
    this._instanceBuffer = instanceBuffer;
    this._instanceOutput = instanceOutput;
    this._indirectBuffer = indirectBuffer;
    this._indirectArguments = indirectArguments;
    this._ranges = ranges;
    this._renderers = renderers;
    this.category = category;
    this.prototypeRadius = prototypeRadius;
    this.lodHeight = lodHeight;
  }

  /**
   * Creates one renderer set and growable output stream for a single-LOD prototype.
   * @param engine Engine owning the output buffers.
   * @param root Parent entity for the compacted renderer set.
   * @param prototype Single-LOD prototype shared by every input range.
   * @param ranges Decoded source ranges retaining independent culling state.
   * @param models Loaded model resources keyed by absolute URL.
   * @param materials Shared surface materials keyed by manifest material id.
   * @param manifestUrl URL used to resolve prototype model references.
   * @returns Ready compacted batcher with no submitted instances.
   */
  static create(
    engine: Engine,
    root: Entity,
    prototype: SurfacePrototypeSpec,
    ranges: readonly SurfaceStaticBatcherRange[],
    models: ReadonlyMap<string, GLTFResource>,
    materials: ReadonlyMap<string, SurfaceMaterial>,
    manifestUrl: string
  ): SurfaceStaticBatcher {
    if (prototype.lods.length !== 1 || prototype.lodCrossfade) {
      throw new Error(`[SurfaceStaticBatcher] ${prototype.id} must be a single-LOD prototype without cross-fade`);
    }
    const capacity = ranges.reduce((count, item) => count + item.range.count, 0);
    const instanceBuffer = new Buffer(
      engine,
      BufferBindFlag.VertexBuffer | BufferBindFlag.StorageBuffer,
      capacity * SURFACE_INSTANCE_STRIDE,
      BufferUsage.Dynamic
    );
    const states = new Map<number, SurfaceStaticRangeState>();
    for (const item of ranges) {
      states.set(item.range.offset, { ...item, visibleCount: 0 });
    }

    const lod = prototype.lods[0];
    const renderSources = lod.renderers.flatMap((rendererSpec, rendererIndex) => {
      const modelUrl = new URL(rendererSpec.model, manifestUrl).href;
      return findSurfaceModelMeshes(models.get(modelUrl)!, rendererSpec.meshName).map((sourceMesh, primitiveIndex) => ({
        rendererSpec,
        rendererIndex,
        sourceMesh,
        primitiveIndex
      }));
    });
    const indirectArguments = new Uint32Array(
      renderSources.reduce((count, source) => count + source.sourceMesh.subMeshes.length, 0) *
        INDIRECT_ARGUMENT_WORD_STRIDE
    );
    let indirectWordOffset = 0;
    for (const source of renderSources) {
      for (const subMesh of source.sourceMesh.subMeshes) {
        indirectArguments[indirectWordOffset] = subMesh.count;
        indirectArguments[indirectWordOffset + 2] = subMesh.start;
        indirectWordOffset += INDIRECT_ARGUMENT_WORD_STRIDE;
      }
    }
    const indirectBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer | BufferBindFlag.IndirectBuffer,
      indirectArguments,
      BufferUsage.Dynamic
    );

    const renderers: MeshRenderer[] = [];
    let prototypeRadius = 0;
    let lodHeight = 0;
    let indirectRecordIndex = 0;
    for (const source of renderSources) {
      const { rendererSpec, rendererIndex, sourceMesh, primitiveIndex } = source;
      const prototypeBounds = transformSurfaceBounds(sourceMesh.bounds, rendererSpec);
      lodHeight = Math.max(lodHeight, prototypeBounds.max.y - prototypeBounds.min.y);
      prototypeRadius = Math.max(prototypeRadius, boundsRadius(prototypeBounds));
      const bounds = mergedRangeBounds(ranges, prototypeBounds);
      const entity = root.createChild(
        `${prototype.id}-compacted-lod${lod.index}-renderer${rendererIndex}-primitive${primitiveIndex}`
      );
      const renderer = entity.addComponent(MeshRenderer) as InternalIndirectDrawRenderer;
      renderer.mesh = createSurfaceInstancedMesh(engine, sourceMesh, instanceBuffer, bounds, 0);
      renderer.castShadows = rendererSpec.castShadows;
      renderer.receiveShadows = rendererSpec.receiveShadows;
      renderer.enableVertexColor = sourceMesh.vertexElements.some((element) => element.attribute === "COLOR_0");
      SurfaceMaterial.setRendererVertexColor(renderer.enableVertexColor, renderer.shaderData);
      SurfaceMaterial.setRendererInstanced(true, renderer.shaderData);
      SurfaceMaterial.setRendererBillboard(prototype.impostor, renderer.shaderData);
      SurfaceMaterial.setRendererTransform(rendererSpec, renderer.shaderData);
      SurfaceMaterial.setRendererDebugInfo(prototype.category, [0, 0], renderer.shaderData);
      SurfaceMaterial.setRendererLodFade(false, 1, renderer.shaderData);
      SurfaceMaterial.setRendererWorldNoise(false, renderer.shaderData);
      SurfaceMaterial.setRendererWorldCellSize(0, renderer.shaderData);
      SurfaceMaterial.setRendererTuning([1, 1, 1], 1, renderer.shaderData);
      const materialId = rendererSpec.materials[Math.min(primitiveIndex, rendererSpec.materials.length - 1)];
      const material = materials.get(materialId);
      if (!material)
        throw new Error(`[SurfaceStaticBatcher] ${prototype.id} references unknown material ${materialId}`);
      for (let subMeshIndex = 0; subMeshIndex < sourceMesh.subMeshes.length; subMeshIndex++) {
        renderer.setMaterial(subMeshIndex, material);
        renderer._setIndirectDrawBuffer(
          subMeshIndex,
          indirectBuffer,
          indirectRecordIndex * INDIRECT_ARGUMENT_WORD_STRIDE * Uint32Array.BYTES_PER_ELEMENT
        );
        indirectRecordIndex++;
      }
      entity.isActive = false;
      renderers.push(renderer);
    }

    return new SurfaceStaticBatcher(
      instanceBuffer,
      new Float32Array(capacity * 16),
      indirectBuffer,
      indirectArguments,
      states,
      renderers,
      prototype.category,
      prototypeRadius,
      Math.max(lodHeight, 0.01)
    );
  }

  /** Number of renderer/primitive batches owned by this prototype. */
  get rendererBatchCount(): number {
    return this._renderers.length;
  }

  /** Number of active renderer/primitive batches owned by this prototype. */
  get activeRendererBatchCount(): number {
    return this._instanceCount > 0 ? this._renderers.length : 0;
  }

  /**
   * Updates one cell's retained density prefix.
   * @param rangeOffset Stable source offset identifying the manifest range.
   * @param visibleCount Number of sorted source records retained for rendering.
   */
  setRangeVisibleCount(rangeOffset: number, visibleCount: number): void {
    const state = this._ranges.get(rangeOffset);
    if (!state) throw new Error(`[SurfaceStaticBatcher] unknown source range ${rangeOffset}`);
    if (!Number.isInteger(visibleCount) || visibleCount < 0 || visibleCount > state.range.count) {
      throw new RangeError(`[SurfaceStaticBatcher] invalid visible count ${visibleCount} for range ${rangeOffset}`);
    }
    if (state.visibleCount === visibleCount) return;
    state.visibleCount = visibleCount;
    this._dirty = true;
  }

  /**
   * Uploads compacted instance prefixes when range visibility changes.
   * @returns Submitted instance count after compaction.
   */
  flush(): number {
    if (!this._dirty) return this._instanceCount;
    let instanceOffset = 0;
    for (const state of this._ranges.values()) {
      const count = state.visibleCount;
      if (count === 0) continue;
      const instanceLength = count * 16;
      this._instanceOutput.set(state.data.subarray(0, instanceLength), instanceOffset);
      instanceOffset += instanceLength;
    }
    this._instanceCount = instanceOffset / 16;
    if (instanceOffset > 0) {
      this._instanceBuffer.setData(this._instanceOutput, 0, 0, instanceOffset);
    }
    const indirectArguments = this._indirectArguments;
    for (let offset = 1; offset < indirectArguments.length; offset += INDIRECT_ARGUMENT_WORD_STRIDE) {
      indirectArguments[offset] = this._instanceCount;
    }
    this._indirectBuffer.setData(indirectArguments);
    for (const renderer of this._renderers) {
      renderer.entity.isActive = this._instanceCount > 0;
      (renderer.mesh as BufferMesh).instanceCount = this._instanceCount;
    }
    this._dirty = false;
    return this._instanceCount;
  }

  /**
   * Applies live category tint and scale to every compacted renderer.
   * @param tint Linear RGB category multiplier.
   * @param scale Uniform prototype scale multiplier.
   */
  setTuning(tint: readonly [number, number, number], scale: number): void {
    for (const renderer of this._renderers) {
      SurfaceMaterial.setRendererTuning(tint, scale, renderer.shaderData);
    }
  }
}

function mergedRangeBounds(ranges: readonly SurfaceStaticBatcherRange[], prototypeBounds: BoundingBox): BoundingBox {
  const minimum = new Vector3(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY);
  const maximum = new Vector3(Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY);
  for (const item of ranges) {
    const bounds = expandSurfaceBounds(item.range.bounds, prototypeBounds, item.maxScale * SURFACE_RUNTIME_SCALE_MAX);
    minimum.x = Math.min(minimum.x, bounds.min.x);
    minimum.y = Math.min(minimum.y, bounds.min.y);
    minimum.z = Math.min(minimum.z, bounds.min.z);
    maximum.x = Math.max(maximum.x, bounds.max.x);
    maximum.y = Math.max(maximum.y, bounds.max.y);
    maximum.z = Math.max(maximum.z, bounds.max.z);
  }
  return new BoundingBox(minimum, maximum);
}

function boundsRadius(bounds: BoundingBox): number {
  return Math.max(
    Math.abs(bounds.min.x),
    Math.abs(bounds.min.y),
    Math.abs(bounds.min.z),
    Math.abs(bounds.max.x),
    Math.abs(bounds.max.y),
    Math.abs(bounds.max.z)
  );
}
