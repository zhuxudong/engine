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
  ModelMesh,
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
import {
  createSurfaceStaticCompactionPass,
  SURFACE_COMPACTION_COMMAND_WORD_STRIDE,
  SURFACE_COMPACTION_INDIRECT_WORD_STRIDE,
  SURFACE_COMPACTION_INSTANCE_FLOAT_STRIDE,
  SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE
} from "./SurfaceStaticCompaction";
import {
  SURFACE_RUNTIME_SCALE_MAX,
  type SurfacePrototypeLodSpec,
  type SurfacePrototypeRendererSpec,
  type SurfacePrototypeSpec
} from "./SurfaceRuntimeContract";

/** One decoded cell range consumed by a compacted prototype LOD batch. */
export interface SurfaceStaticBatcherRange {
  /** Manifest range retaining the visibility and diagnostic cell boundary. */
  readonly range: SurfaceCellRange;
  /** Runtime transform/color records sorted by density priority. */
  readonly data: Float32Array;
  /** Largest authored instance scale in this range. */
  readonly maxScale: number;
}

interface SurfaceStaticRangeState {
  readonly range: SurfaceCellRange;
  readonly sourceInstanceOffset: number;
  visibleCount: number;
  lodFade: number;
}

interface SurfaceStaticRenderSource {
  readonly rendererSpec: SurfacePrototypeRendererSpec;
  readonly rendererIndex: number;
  readonly sourceMesh: ModelMesh;
  readonly primitiveIndex: number;
}

interface SurfaceStaticBatchPlan {
  readonly prototype: SurfacePrototypeSpec;
  readonly lod: SurfacePrototypeLodSpec;
  readonly ranges: readonly SurfaceStaticBatcherRange[];
  readonly renderSources: readonly SurfaceStaticRenderSource[];
  readonly outputInstanceOffset: number;
  readonly indirectRecordOffset: number;
  readonly indirectRecordCount: number;
}

interface InternalIndirectDrawRenderer extends MeshRenderer {
  _setIndirectDrawBuffer(subMeshIndex: number, buffer: Buffer | null, offset?: number): void;
}

/**
 * Owns one storage atlas and one compute dispatch for all finite prototype LOD batches.
 *
 * @internal
 */
export class SurfaceStaticBatchGroup {
  private readonly _commandBuffer: Buffer;
  private readonly _commands: Uint32Array;
  private readonly _compactionPass: ReturnType<typeof createSurfaceStaticCompactionPass>;
  private readonly _batchers: readonly SurfaceStaticBatcher[];

  private constructor(
    commandBuffer: Buffer,
    commands: Uint32Array,
    compactionPass: ReturnType<typeof createSurfaceStaticCompactionPass>,
    batchers: readonly SurfaceStaticBatcher[]
  ) {
    this._commandBuffer = commandBuffer;
    this._commands = commands;
    this._compactionPass = compactionPass;
    this._batchers = batchers;
  }

  /**
   * Creates one device-limited storage atlas for every finite WebGPU surface batch.
   * @param engine Engine owning the shared buffers.
   * @param root Parent entity for compacted renderer sets.
   * @param sourcesByPrototype Decoded source ranges keyed by prototype id.
   * @param prototypes Prototype contracts keyed by id.
   * @param models Loaded model resources keyed by absolute URL.
   * @param materials Shared surface materials keyed by manifest material id.
   * @param manifestUrl URL used to resolve prototype model references.
   * @returns Shared compaction group and its prototype LOD batchers.
   * @throws If a required storage binding or dispatch dimension exceeds the active device limits.
   */
  static create(
    engine: Engine,
    root: Entity,
    sourcesByPrototype: ReadonlyMap<string, readonly SurfaceStaticBatcherRange[]>,
    prototypes: ReadonlyMap<string, SurfacePrototypeSpec>,
    models: ReadonlyMap<string, GLTFResource>,
    materials: ReadonlyMap<string, SurfaceMaterial>,
    manifestUrl: string
  ): SurfaceStaticBatchGroup {
    const sourceOffsetsByPrototype = new Map<string, ReadonlyMap<number, number>>();
    let sourceInstanceCapacity = 0;
    for (const [prototypeId, ranges] of sourcesByPrototype) {
      const offsets = new Map<number, number>();
      for (const item of ranges) {
        offsets.set(item.range.offset, sourceInstanceCapacity);
        sourceInstanceCapacity += item.range.count;
      }
      sourceOffsetsByPrototype.set(prototypeId, offsets);
    }

    const plans: SurfaceStaticBatchPlan[] = [];
    let outputInstanceCapacity = 0;
    let copyCommandCapacity = 0;
    let indirectRecordCapacity = 0;
    for (const [prototypeId, ranges] of sourcesByPrototype) {
      const prototype = prototypes.get(prototypeId);
      if (!prototype) throw new Error(`[SurfaceStaticBatchGroup] unknown prototype ${prototypeId}`);
      const batchCapacity = ranges.reduce((count, item) => count + item.range.count, 0);
      for (const lod of prototype.lods) {
        const renderSources = collectRenderSources(lod, models, manifestUrl);
        const indirectRecordCount = renderSources.reduce(
          (count, source) => count + source.sourceMesh.subMeshes.length,
          0
        );
        plans.push({
          prototype,
          lod,
          ranges,
          renderSources,
          outputInstanceOffset: outputInstanceCapacity,
          indirectRecordOffset: indirectRecordCapacity,
          indirectRecordCount
        });
        outputInstanceCapacity += batchCapacity;
        copyCommandCapacity += ranges.length;
        indirectRecordCapacity += indirectRecordCount;
      }
    }

    validateGroupCapacity(
      engine,
      sourceInstanceCapacity,
      outputInstanceCapacity,
      1 + plans.length + copyCommandCapacity,
      indirectRecordCapacity,
      Math.max(plans.length, copyCommandCapacity)
    );

    const sourceData = new Float32Array(sourceInstanceCapacity * SURFACE_COMPACTION_INSTANCE_FLOAT_STRIDE);
    for (const [prototypeId, ranges] of sourcesByPrototype) {
      const sourceOffsets = sourceOffsetsByPrototype.get(prototypeId)!;
      for (const item of ranges) {
        sourceData.set(item.data, sourceOffsets.get(item.range.offset)! * SURFACE_COMPACTION_INSTANCE_FLOAT_STRIDE);
      }
    }
    const sourceBuffer = new Buffer(engine, BufferBindFlag.StorageBuffer, sourceData, BufferUsage.Static);
    const outputBuffer = new Buffer(
      engine,
      BufferBindFlag.VertexBuffer | BufferBindFlag.StorageBuffer,
      outputInstanceCapacity * SURFACE_INSTANCE_STRIDE,
      BufferUsage.Dynamic
    );
    const indirectArguments = new Uint32Array(indirectRecordCapacity * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE);
    for (const plan of plans) {
      let indirectRecordIndex = plan.indirectRecordOffset;
      for (const source of plan.renderSources) {
        for (const subMesh of source.sourceMesh.subMeshes) {
          const wordOffset = indirectRecordIndex * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE;
          indirectArguments[wordOffset] = subMesh.count;
          indirectArguments[wordOffset + 2] = subMesh.start;
          indirectRecordIndex++;
        }
      }
    }
    const indirectBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer | BufferBindFlag.IndirectBuffer,
      indirectArguments,
      BufferUsage.Dynamic
    );
    const commands = new Uint32Array((1 + plans.length + copyCommandCapacity) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE);
    const commandBuffer = new Buffer(engine, BufferBindFlag.StorageBuffer, commands, BufferUsage.Dynamic);
    const compactionPass = createSurfaceStaticCompactionPass(engine);
    compactionPass.setBuffer("sourceInstances", sourceBuffer);
    compactionPass.setBuffer("copyCommands", commandBuffer);
    compactionPass.setBuffer("outputInstances", outputBuffer);
    compactionPass.setBuffer("indirectArguments", indirectBuffer);

    const prototypeRoots = new Map(
      Array.from(sourcesByPrototype.keys(), (prototypeId) => [
        prototypeId,
        root.createChild(`${prototypeId}-compacted`)
      ])
    );
    const batchers = plans.map((plan) =>
      createBatcher(
        engine,
        prototypeRoots.get(plan.prototype.id)!,
        plan,
        sourceOffsetsByPrototype.get(plan.prototype.id)!,
        outputBuffer,
        indirectBuffer,
        materials
      )
    );
    return new SurfaceStaticBatchGroup(commandBuffer, commands, compactionPass, batchers);
  }

  /**
   * Prototype LOD batches sharing this group's storage atlas.
   * @returns Immutable batcher list.
   */
  get batchers(): readonly SurfaceStaticBatcher[] {
    return this._batchers;
  }

  /**
   * Compacts every dirty prototype LOD through one flattened compute dispatch.
   */
  flush(): void {
    const dirtyBatchers = this._batchers.filter((batcher) => batcher._needsFlush());
    if (dirtyBatchers.length === 0) return;

    const commands = this._commands;
    const copyCommandStart = 1 + dirtyBatchers.length;
    let copyCommandCount = 0;
    for (let index = 0; index < dirtyBatchers.length; index++) {
      copyCommandCount += dirtyBatchers[index]._writeCommands(
        commands,
        (1 + index) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE,
        (copyCommandStart + copyCommandCount) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE
      );
    }
    commands[0] = copyCommandCount;
    commands[1] = dirtyBatchers.length;
    commands[2] = 0;
    commands[3] = 0;
    this._commandBuffer.setData(
      commands,
      0,
      0,
      (copyCommandStart + copyCommandCount) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE
    );
    this._compactionPass.dispatch(Math.max(copyCommandCount, dirtyBatchers.length));
  }
}

/**
 * Retains visibility and renderer state for one prototype LOD inside a shared compaction group.
 *
 * @internal
 */
export class SurfaceStaticBatcher {
  /** Prototype id shared by this compacted stream. */
  readonly prototypeId: string;
  /** Surface category shared by the compacted prototype. */
  readonly category: SurfaceCategory;
  /** Prototype LOD rendered by this compacted stream. */
  readonly lodIndex: number;
  /** Prototype-space radius used by cell culling. */
  readonly prototypeRadius: number;
  /** Prototype LOD height used by projected-size selection. */
  readonly lodHeight: number;

  private readonly _packedMetadata: boolean;
  private readonly _outputInstanceOffset: number;
  private readonly _indirectWordOffset: number;
  private readonly _indirectRecordCount: number;
  private readonly _ranges: ReadonlyMap<number, SurfaceStaticRangeState>;
  private readonly _renderers: readonly MeshRenderer[];
  private _dirty = true;
  private _instanceCount = 0;

  /**
   * Creates one prototype LOD view into a shared compaction group.
   * @param prototypeId Prototype identifier.
   * @param packedMetadata Whether instance metadata stores LOD cross-fade.
   * @param outputInstanceOffset First instance in the shared output atlas.
   * @param indirectRecordOffset First draw record in the shared indirect atlas.
   * @param indirectRecordCount Number of draw records owned by this batch.
   * @param ranges Retained visibility state keyed by source range offset.
   * @param renderers Renderers consuming this batch's output slice.
   * @param category Surface category.
   * @param lodIndex Prototype LOD index.
   * @param prototypeRadius Prototype-space culling radius.
   * @param lodHeight Prototype height used for projected-size LOD selection.
   * @internal
   */
  constructor(
    prototypeId: string,
    packedMetadata: boolean,
    outputInstanceOffset: number,
    indirectRecordOffset: number,
    indirectRecordCount: number,
    ranges: ReadonlyMap<number, SurfaceStaticRangeState>,
    renderers: readonly MeshRenderer[],
    category: SurfaceCategory,
    lodIndex: number,
    prototypeRadius: number,
    lodHeight: number
  ) {
    this.prototypeId = prototypeId;
    this._packedMetadata = packedMetadata;
    this._outputInstanceOffset = outputInstanceOffset;
    this._indirectWordOffset = indirectRecordOffset * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE;
    this._indirectRecordCount = indirectRecordCount;
    this._ranges = ranges;
    this._renderers = renderers;
    this.category = category;
    this.lodIndex = lodIndex;
    this.prototypeRadius = prototypeRadius;
    this.lodHeight = lodHeight;
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
   * @param lodFade Signed LOD cross-fade factor shared by the retained records.
   */
  setRangeVisibleCount(rangeOffset: number, visibleCount: number, lodFade: number = 1): void {
    const state = this._ranges.get(rangeOffset);
    if (!state) throw new Error(`[SurfaceStaticBatcher] unknown source range ${rangeOffset}`);
    if (!Number.isInteger(visibleCount) || visibleCount < 0 || visibleCount > state.range.count) {
      throw new RangeError(`[SurfaceStaticBatcher] invalid visible count ${visibleCount} for range ${rangeOffset}`);
    }
    if (!Number.isFinite(lodFade) || lodFade < -1 || lodFade > 1) {
      throw new RangeError(`[SurfaceStaticBatcher] invalid LOD fade ${lodFade} for range ${rangeOffset}`);
    }
    if (state.visibleCount === visibleCount && state.lodFade === lodFade) return;
    state.visibleCount = visibleCount;
    state.lodFade = lodFade;
    this._dirty = true;
  }

  /** @internal */
  _needsFlush(): boolean {
    return this._dirty;
  }

  /**
   * Write this batch's indirect header and visible range copies into the shared command array.
   * @param commands Shared u32 command array.
   * @param batchWordOffset First word of this batch header.
   * @param copyWordOffset First word available for range-copy commands.
   * @returns Number of range-copy commands written.
   * @internal
   */
  _writeCommands(commands: Uint32Array, batchWordOffset: number, copyWordOffset: number): number {
    let instanceOffset = 0;
    let copyCommandCount = 0;
    for (const state of this._ranges.values()) {
      const count = state.visibleCount;
      if (count === 0) continue;
      const commandOffset = copyWordOffset + copyCommandCount * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
      commands[commandOffset] = state.sourceInstanceOffset;
      commands[commandOffset + 1] = this._outputInstanceOffset + instanceOffset;
      commands[commandOffset + 2] = count;
      commands[commandOffset + 3] = this._packedMetadata ? encodeLodFade(state.lodFade) + 1 : 0;
      instanceOffset += count;
      copyCommandCount++;
    }
    this._instanceCount = instanceOffset;
    commands[batchWordOffset] = this._indirectWordOffset;
    commands[batchWordOffset + 1] = this._indirectRecordCount;
    commands[batchWordOffset + 2] = instanceOffset;
    commands[batchWordOffset + 3] = 0;
    for (const renderer of this._renderers) {
      renderer.entity.isActive = instanceOffset > 0;
      (renderer.mesh as BufferMesh).instanceCount = instanceOffset;
    }
    this._dirty = false;
    return copyCommandCount;
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

function createBatcher(
  engine: Engine,
  root: Entity,
  plan: SurfaceStaticBatchPlan,
  sourceOffsets: ReadonlyMap<number, number>,
  outputBuffer: Buffer,
  indirectBuffer: Buffer,
  materials: ReadonlyMap<string, SurfaceMaterial>
): SurfaceStaticBatcher {
  const { prototype, lod, ranges, renderSources } = plan;
  const states = new Map<number, SurfaceStaticRangeState>();
  for (const item of ranges) {
    states.set(item.range.offset, {
      range: item.range,
      sourceInstanceOffset: sourceOffsets.get(item.range.offset)!,
      visibleCount: 0,
      lodFade: 1
    });
  }

  const renderers: MeshRenderer[] = [];
  let prototypeRadius = 0;
  let lodHeight = 0;
  let indirectRecordIndex = plan.indirectRecordOffset;
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
    renderer.mesh = createSurfaceInstancedMesh(
      engine,
      sourceMesh,
      outputBuffer,
      bounds,
      0,
      plan.outputInstanceOffset * SURFACE_INSTANCE_STRIDE
    );
    renderer.castShadows = rendererSpec.castShadows;
    renderer.receiveShadows = rendererSpec.receiveShadows;
    renderer.enableVertexColor = sourceMesh.vertexElements.some((element) => element.attribute === "COLOR_0");
    SurfaceMaterial.setRendererVertexColor(renderer.enableVertexColor, renderer.shaderData);
    SurfaceMaterial.setRendererInstanced(true, renderer.shaderData);
    SurfaceMaterial.setRendererPackedMetadata(prototype.lodCrossfade, renderer.shaderData);
    SurfaceMaterial.setRendererBillboard(prototype.impostor, renderer.shaderData);
    SurfaceMaterial.setRendererTransform(rendererSpec, renderer.shaderData);
    SurfaceMaterial.setRendererDebugInfo(prototype.category, [0, 0], renderer.shaderData);
    SurfaceMaterial.setRendererLodFade(false, 1, renderer.shaderData);
    SurfaceMaterial.setRendererWorldNoise(false, renderer.shaderData);
    SurfaceMaterial.setRendererWorldCellSize(0, renderer.shaderData);
    SurfaceMaterial.setRendererTuning([1, 1, 1], 1, renderer.shaderData);
    const materialId = rendererSpec.materials[Math.min(primitiveIndex, rendererSpec.materials.length - 1)];
    const material = materials.get(materialId);
    if (!material) throw new Error(`[SurfaceStaticBatcher] ${prototype.id} references unknown material ${materialId}`);
    for (let subMeshIndex = 0; subMeshIndex < sourceMesh.subMeshes.length; subMeshIndex++) {
      renderer.setMaterial(subMeshIndex, material);
      renderer._setIndirectDrawBuffer(
        subMeshIndex,
        indirectBuffer,
        indirectRecordIndex * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE * Uint32Array.BYTES_PER_ELEMENT
      );
      indirectRecordIndex++;
    }
    entity.isActive = false;
    renderers.push(renderer);
  }

  return new SurfaceStaticBatcher(
    prototype.id,
    prototype.lodCrossfade,
    plan.outputInstanceOffset,
    plan.indirectRecordOffset,
    plan.indirectRecordCount,
    states,
    renderers,
    prototype.category,
    lod.index,
    prototypeRadius,
    Math.max(lodHeight, 0.01)
  );
}

function collectRenderSources(
  lod: SurfacePrototypeLodSpec,
  models: ReadonlyMap<string, GLTFResource>,
  manifestUrl: string
): readonly SurfaceStaticRenderSource[] {
  return lod.renderers.flatMap((rendererSpec, rendererIndex) => {
    const modelUrl = new URL(rendererSpec.model, manifestUrl).href;
    return findSurfaceModelMeshes(models.get(modelUrl)!, rendererSpec.meshName).map((sourceMesh, primitiveIndex) => ({
      rendererSpec,
      rendererIndex,
      sourceMesh,
      primitiveIndex
    }));
  });
}

function validateGroupCapacity(
  engine: Engine,
  sourceInstanceCapacity: number,
  outputInstanceCapacity: number,
  commandCapacity: number,
  indirectRecordCapacity: number,
  dispatchWorkgroups: number
): void {
  const limits = engine.computeCapabilities;
  const storageBindings = [
    ["source instance", sourceInstanceCapacity * SURFACE_INSTANCE_STRIDE],
    ["output instance", outputInstanceCapacity * SURFACE_INSTANCE_STRIDE],
    ["compaction command", commandCapacity * SURFACE_COMPACTION_COMMAND_WORD_STRIDE * Uint32Array.BYTES_PER_ELEMENT],
    [
      "indirect argument",
      indirectRecordCapacity * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE * Uint32Array.BYTES_PER_ELEMENT
    ]
  ] as const;
  for (const [name, byteLength] of storageBindings) {
    if (byteLength > limits.maxStorageBufferBindingSize) {
      throw new RangeError(
        `[SurfaceStaticBatchGroup] ${name} storage requires ${byteLength} bytes, exceeding ` +
          `${limits.maxStorageBufferBindingSize}.`
      );
    }
  }
  if (dispatchWorkgroups > limits.maxWorkgroupsPerDimension) {
    throw new RangeError(
      `[SurfaceStaticBatchGroup] compaction requires ${dispatchWorkgroups} workgroups, exceeding ` +
        `${limits.maxWorkgroupsPerDimension}.`
    );
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

function encodeLodFade(lodFade: number): number {
  return Math.round((lodFade * 0.5 + 0.5) * 65535);
}
