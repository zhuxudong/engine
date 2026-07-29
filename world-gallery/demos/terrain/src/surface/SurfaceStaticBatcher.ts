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
  Vector3,
  VertexBufferBinding
} from "@galacean/engine";
import type { MeshRendererShadowViewBinding, MeshRendererShadowViewProvider, Primitive } from "@galacean/engine";
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
  createSurfaceStaticCompactionPasses,
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
  fineCulling: boolean;
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
  readonly fineCulling: boolean;
  readonly fineCullBatchIndex: number;
  readonly fineCullRadius: number;
}

interface SurfaceFineCullBatchState {
  readonly index: number;
  readonly maxDistance: number;
  readonly radius: number;
  runtimeScale: number;
}

interface InternalIndirectDrawRenderer extends MeshRenderer {
  _setIndirectDrawBuffer(subMeshIndex: number, buffer: Buffer | null, offset?: number): void;
  _setShadowViewProvider(provider: MeshRendererShadowViewProvider | null): void;
}

interface InternalBufferMesh extends BufferMesh {
  readonly _primitive: Primitive;
}

interface SurfaceShadowSlice {
  readonly cullPlaneCount: number;
  readonly cullPlanes: readonly {
    readonly normal: { readonly x: number; readonly y: number; readonly z: number };
    readonly distance: number;
  }[];
}

const SURFACE_SHADOW_CASCADE_CAPACITY = 4;
const SURFACE_SHADOW_PARAMETER_VECTOR_COUNT = 46;

/**
 * Owns one storage atlas and one compute dispatch for all finite prototype LOD batches.
 *
 * @internal
 */
export class SurfaceStaticBatchGroup {
  private readonly _commandBuffer: Buffer;
  private readonly _commands: Uint32Array;
  private readonly _fineCullBatchBuffer: Buffer;
  private readonly _fineCullBatchData: Float32Array;
  private readonly _fineCullParameterBuffer: Buffer;
  private readonly _fineCullParameters = new Float32Array(4);
  private readonly _compactionPasses: ReturnType<typeof createSurfaceStaticCompactionPasses>;
  private readonly _batchers: readonly SurfaceStaticBatcher[];
  private readonly _shadowViewProvider: SurfaceStaticShadowViewProvider | null;
  private _fineCullCameraX = Number.NaN;
  private _fineCullCameraY = Number.NaN;
  private _fineCullCameraZ = Number.NaN;
  private _fineCullDistanceScale = Number.NaN;

  private constructor(
    commandBuffer: Buffer,
    commands: Uint32Array,
    fineCullBatchBuffer: Buffer,
    fineCullBatchData: Float32Array,
    fineCullParameterBuffer: Buffer,
    compactionPasses: ReturnType<typeof createSurfaceStaticCompactionPasses>,
    batchers: readonly SurfaceStaticBatcher[],
    shadowViewProvider: SurfaceStaticShadowViewProvider | null
  ) {
    this._commandBuffer = commandBuffer;
    this._commands = commands;
    this._fineCullBatchBuffer = fineCullBatchBuffer;
    this._fineCullBatchData = fineCullBatchData;
    this._fineCullParameterBuffer = fineCullParameterBuffer;
    this._compactionPasses = compactionPasses;
    this._batchers = batchers;
    this._shadowViewProvider = shadowViewProvider;
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
    const fineCullWorkgroupSize = engine.computeCapabilities.recommendedWorkgroupSizeX;
    for (const [prototypeId, ranges] of sourcesByPrototype) {
      const prototype = prototypes.get(prototypeId);
      if (!prototype) throw new Error(`[SurfaceStaticBatchGroup] unknown prototype ${prototypeId}`);
      const batchCapacity = ranges.reduce((count, item) => count + item.range.count, 0);
      for (const lod of prototype.lods) {
        const renderSources = collectRenderSources(lod, models, manifestUrl);
        const fineCulling = isSurfaceFineCullingEligible(prototype);
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
          indirectRecordCount,
          fineCulling,
          fineCullBatchIndex: plans.length,
          fineCullRadius: renderSources.reduce(
            (radius, source) =>
              Math.max(
                radius,
                boundsSphereRadius(transformSurfaceBounds(source.sourceMesh.bounds, source.rendererSpec))
              ),
            0
          )
        });
        outputInstanceCapacity += batchCapacity;
        copyCommandCapacity += fineCulling
          ? ranges.reduce((count, item) => count + Math.ceil(item.range.count / fineCullWorkgroupSize), 0)
          : ranges.length;
        indirectRecordCapacity += indirectRecordCount;
      }
    }

    validateGroupCapacity(
      engine,
      sourceInstanceCapacity,
      outputInstanceCapacity,
      1 + plans.length + copyCommandCapacity,
      indirectRecordCapacity,
      Math.max(plans.length, copyCommandCapacity),
      plans.length
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
    const fineCullStates: SurfaceFineCullBatchState[] = plans.map((plan) => ({
      index: plan.fineCullBatchIndex,
      maxDistance: plan.prototype.maxDistance,
      radius: plan.fineCullRadius,
      runtimeScale: 1
    }));
    const fineCullBatchData = new Float32Array(plans.length * 4);
    writeFineCullBatchData(fineCullBatchData, fineCullStates);
    const fineCullBatchBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      fineCullBatchData,
      BufferUsage.Dynamic
    );
    const fineCullParameterBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      new Float32Array(4),
      BufferUsage.Dynamic
    );
    const fineCullCounterBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      new Uint32Array(plans.length),
      BufferUsage.Dynamic
    );
    const compactionPasses = createSurfaceStaticCompactionPasses(engine);
    compactionPasses.copy.setBuffer("sourceInstances", sourceBuffer);
    compactionPasses.copy.setBuffer("compactionCommands", commandBuffer);
    compactionPasses.copy.setBuffer("outputInstances", outputBuffer);
    compactionPasses.copy.setBuffer("indirectArguments", indirectBuffer);
    compactionPasses.resetFineCullCounters.setBuffer("compactionCommands", commandBuffer);
    compactionPasses.resetFineCullCounters.setBuffer("fineCullCounters", fineCullCounterBuffer);
    compactionPasses.fineCull.setBuffer("sourceInstances", sourceBuffer);
    compactionPasses.fineCull.setBuffer("compactionCommands", commandBuffer);
    compactionPasses.fineCull.setBuffer("fineCullBatches", fineCullBatchBuffer);
    compactionPasses.fineCull.setBuffer("fineCullParameters", fineCullParameterBuffer);
    compactionPasses.fineCull.setBuffer("outputInstances", outputBuffer);
    compactionPasses.fineCull.setBuffer("fineCullCounters", fineCullCounterBuffer);
    compactionPasses.finalizeFineCull.setBuffer("compactionCommands", commandBuffer);
    compactionPasses.finalizeFineCull.setBuffer("fineCullCounters", fineCullCounterBuffer);
    compactionPasses.finalizeFineCull.setBuffer("indirectArguments", indirectBuffer);

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
        materials,
        plan.fineCulling ? fineCullStates[plan.fineCullBatchIndex] : null
      )
    );
    const shadowViewProvider = SurfaceStaticShadowViewProvider.create(
      engine,
      sourceBuffer,
      plans,
      batchers,
      materials,
      compactionPasses
    );
    return new SurfaceStaticBatchGroup(
      commandBuffer,
      commands,
      fineCullBatchBuffer,
      fineCullBatchData,
      fineCullParameterBuffer,
      compactionPasses,
      batchers,
      shadowViewProvider
    );
  }

  /**
   * Prototype LOD batches sharing this group's storage atlas.
   * @returns Immutable batcher list.
   */
  get batchers(): readonly SurfaceStaticBatcher[] {
    return this._batchers;
  }

  /**
   * Updates camera-relative fine-culling inputs and invalidates only eligible batches.
   * @param cameraPosition Current world-space camera position.
   * @param distanceScale Live LOD distance multiplier shared with CPU range selection.
   */
  setCullingState(cameraPosition: Vector3, distanceScale: number): void {
    if (
      this._fineCullCameraX === cameraPosition.x &&
      this._fineCullCameraY === cameraPosition.y &&
      this._fineCullCameraZ === cameraPosition.z &&
      this._fineCullDistanceScale === distanceScale
    ) {
      return;
    }
    this._fineCullCameraX = cameraPosition.x;
    this._fineCullCameraY = cameraPosition.y;
    this._fineCullCameraZ = cameraPosition.z;
    this._fineCullDistanceScale = distanceScale;
    const parameters = this._fineCullParameters;
    parameters[0] = cameraPosition.x;
    parameters[1] = cameraPosition.y;
    parameters[2] = cameraPosition.z;
    parameters[3] = distanceScale;
    this._fineCullParameterBuffer.setData(parameters);
    this._shadowViewProvider?.setFineCullingState(cameraPosition, distanceScale);
    for (const batcher of this._batchers) {
      batcher._invalidateFineCulling();
    }
  }

  /**
   * Compacts every dirty prototype LOD through one flattened compute dispatch.
   */
  flush(): void {
    const dirtyBatchers = this._batchers.filter((batcher) => batcher._needsFlush());
    if (dirtyBatchers.length === 0) return;

    const fineCullBatchers = dirtyBatchers.filter((batcher) => batcher._hasFineCullCommands());
    const legacyBatchers = dirtyBatchers.filter((batcher) => !batcher._hasFineCullCommands());
    const orderedBatchers = legacyBatchers.concat(fineCullBatchers);
    const commands = this._commands;
    const copyCommandStart = 1 + dirtyBatchers.length;
    for (let index = 0; index < orderedBatchers.length; index++) {
      orderedBatchers[index]._writeBatchHeader(
        commands,
        (1 + index) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE,
        index >= legacyBatchers.length
      );
    }
    let legacyCommandCount = 0;
    for (const batcher of orderedBatchers) {
      legacyCommandCount += batcher._writeLegacyCommands(
        commands,
        (copyCommandStart + legacyCommandCount) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE
      );
    }
    let fineCullCommandCount = 0;
    for (const batcher of fineCullBatchers) {
      fineCullCommandCount += batcher._writeFineCullCommands(
        commands,
        (copyCommandStart + legacyCommandCount + fineCullCommandCount) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE,
        this._compactionPasses.fineCull.workgroupSize[0]
      );
    }
    commands[0] = orderedBatchers.length;
    commands[1] = legacyCommandCount;
    commands[2] = fineCullCommandCount;
    commands[3] = legacyBatchers.length;
    this._commandBuffer.setData(
      commands,
      0,
      0,
      (copyCommandStart + legacyCommandCount + fineCullCommandCount) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE
    );
    if (legacyCommandCount > 0 || legacyBatchers.length > 0) {
      this._compactionPasses.copy.dispatch(Math.max(legacyCommandCount, legacyBatchers.length));
    }
    if (fineCullBatchers.length > 0) {
      for (const batcher of fineCullBatchers) {
        batcher._writeFineCullBatchData(this._fineCullBatchData);
      }
      this._fineCullBatchBuffer.setData(this._fineCullBatchData);
      this._compactionPasses.resetFineCullCounters.dispatch(1);
      if (fineCullCommandCount > 0) {
        this._compactionPasses.fineCull.dispatch(fineCullCommandCount);
      }
      this._compactionPasses.finalizeFineCull.dispatch(fineCullBatchers.length);
    }
  }
}

interface SurfaceShadowBatch {
  readonly plan: SurfaceStaticBatchPlan;
  readonly batcher: SurfaceStaticBatcher;
  readonly outputInstanceOffset: number;
  readonly indirectWordOffset: number;
  readonly indirectRecordCount: number;
  readonly materials: readonly SurfaceMaterial[];
}

/**
 * Produces four independent instance and indirect streams before directional shadow rendering starts.
 *
 * @internal
 */
class SurfaceStaticShadowViewProvider implements MeshRendererShadowViewProvider {
  private readonly _shadowDataBuffer: Buffer;
  private readonly _shadowData: Float32Array;
  private readonly _shadowDataSnapshot: Float32Array;
  private readonly _shadowParameterBuffer: Buffer;
  private readonly _shadowParameters: Float32Array;
  private readonly _shadowParameterSnapshot: Float32Array;
  private readonly _shadowOutputBuffer: Buffer;
  private readonly _shadowCounterBuffer: Buffer;
  private readonly _shadowIndirectBuffer: Buffer;
  private readonly _shadowBatches: readonly SurfaceShadowBatch[];
  private readonly _bindings = new Map<MeshRenderer, readonly (readonly MeshRendererShadowViewBinding[])[]>();
  private readonly _compactionPasses: ReturnType<typeof createSurfaceStaticCompactionPasses>;
  private readonly _outputInstanceCapacity: number;
  private readonly _indirectWordCapacity: number;
  private readonly _fineCullCamera = new Vector3();
  private _fineCullDistanceScale = 1;
  private _shadowDataWordCount = 0;
  private _prepared = false;

  /**
   * Creates a provider only when at least one compacted renderer casts directional shadows.
   * @param engine Engine owning the shared shadow resources.
   * @param sourceBuffer Immutable source instance atlas.
   * @param plans Static prototype LOD plans.
   * @param batchers Runtime visibility state aligned with `plans`.
   * @param materials Shared surface materials keyed by manifest id.
   * @param compactionPasses Shared ShaderLab compute passes.
   * @returns A configured provider, or null when no static renderer casts shadows.
   */
  static create(
    engine: Engine,
    sourceBuffer: Buffer,
    plans: readonly SurfaceStaticBatchPlan[],
    batchers: readonly SurfaceStaticBatcher[],
    materials: ReadonlyMap<string, SurfaceMaterial>,
    compactionPasses: ReturnType<typeof createSurfaceStaticCompactionPasses>
  ): SurfaceStaticShadowViewProvider | null {
    const shadowPlanCount = plans.reduce(
      (count, plan) => count + (plan.renderSources.some((source) => source.rendererSpec.castShadows) ? 1 : 0),
      0
    );
    return shadowPlanCount > 0
      ? new SurfaceStaticShadowViewProvider(engine, sourceBuffer, plans, batchers, materials, compactionPasses)
      : null;
  }

  private constructor(
    engine: Engine,
    sourceBuffer: Buffer,
    plans: readonly SurfaceStaticBatchPlan[],
    batchers: readonly SurfaceStaticBatcher[],
    materials: ReadonlyMap<string, SurfaceMaterial>,
    compactionPasses: ReturnType<typeof createSurfaceStaticCompactionPasses>
  ) {
    this._compactionPasses = compactionPasses;
    const shadowBatches: SurfaceShadowBatch[] = [];
    let outputInstanceCapacity = 0;
    let indirectRecordCapacity = 0;
    let commandCapacity = 0;
    const workgroupSize = compactionPasses.cullShadowInstances.workgroupSize[0];
    for (let index = 0; index < plans.length; index++) {
      const plan = plans[index];
      const casterSources = plan.renderSources.filter((source) => source.rendererSpec.castShadows);
      if (casterSources.length === 0) continue;
      const batchCapacity = plan.ranges.reduce((count, item) => count + item.range.count, 0);
      const batchIndirectRecordCapacity = casterSources.reduce(
        (count, source) => count + source.sourceMesh.subMeshes.length,
        0
      );
      const batchMaterials = new Set<SurfaceMaterial>();
      for (const source of casterSources) {
        const materialId =
          source.rendererSpec.materials[Math.min(source.primitiveIndex, source.rendererSpec.materials.length - 1)];
        const material = materials.get(materialId);
        if (!material) {
          throw new Error(`[SurfaceStaticShadowViewProvider] unknown material ${materialId}`);
        }
        batchMaterials.add(material);
      }
      shadowBatches.push({
        plan,
        batcher: batchers[index],
        outputInstanceOffset: outputInstanceCapacity,
        indirectWordOffset: indirectRecordCapacity * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE,
        indirectRecordCount: batchIndirectRecordCapacity,
        materials: Array.from(batchMaterials)
      });
      outputInstanceCapacity += batchCapacity;
      indirectRecordCapacity += batchIndirectRecordCapacity;
      commandCapacity += plan.ranges.reduce((count, item) => count + Math.ceil(item.range.count / workgroupSize), 0);
    }

    validateShadowCapacity(
      engine,
      outputInstanceCapacity,
      indirectRecordCapacity,
      shadowBatches.length,
      commandCapacity
    );
    this._shadowBatches = shadowBatches;
    this._outputInstanceCapacity = outputInstanceCapacity;
    this._indirectWordCapacity = indirectRecordCapacity * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE;
    this._shadowData = new Float32Array(
      (1 + shadowBatches.length * 2 + commandCapacity) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE
    );
    this._shadowDataSnapshot = new Float32Array(this._shadowData.length);
    this._shadowDataBuffer = new Buffer(engine, BufferBindFlag.StorageBuffer, this._shadowData, BufferUsage.Dynamic);
    this._shadowOutputBuffer = new Buffer(
      engine,
      BufferBindFlag.VertexBuffer | BufferBindFlag.StorageBuffer,
      outputInstanceCapacity * SURFACE_SHADOW_CASCADE_CAPACITY * SURFACE_INSTANCE_STRIDE,
      BufferUsage.Dynamic
    );
    this._shadowCounterBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      new Uint32Array(shadowBatches.length * SURFACE_SHADOW_CASCADE_CAPACITY),
      BufferUsage.Dynamic
    );
    this._shadowParameters = new Float32Array(SURFACE_SHADOW_PARAMETER_VECTOR_COUNT * 4);
    this._shadowParameterSnapshot = new Float32Array(this._shadowParameters.length);
    this._shadowParameterBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      this._shadowParameters,
      BufferUsage.Dynamic
    );

    const indirectArguments = new Uint32Array(
      indirectRecordCapacity * SURFACE_SHADOW_CASCADE_CAPACITY * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE
    );
    for (let cascadeIndex = 0; cascadeIndex < SURFACE_SHADOW_CASCADE_CAPACITY; cascadeIndex++) {
      for (const batch of shadowBatches) {
        let wordOffset = cascadeIndex * this._indirectWordCapacity + batch.indirectWordOffset;
        for (const source of batch.plan.renderSources) {
          if (!source.rendererSpec.castShadows) continue;
          for (const subMesh of source.sourceMesh.subMeshes) {
            indirectArguments[wordOffset] = subMesh.count;
            indirectArguments[wordOffset + 2] = subMesh.start;
            wordOffset += SURFACE_COMPACTION_INDIRECT_WORD_STRIDE;
          }
        }
      }
    }
    this._shadowIndirectBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer | BufferBindFlag.IndirectBuffer,
      indirectArguments,
      BufferUsage.Dynamic
    );

    this._createRendererBindings();
    compactionPasses.resetShadowCounters.setBuffer("shadowData", this._shadowDataBuffer);
    compactionPasses.resetShadowCounters.setBuffer("shadowParameters", this._shadowParameterBuffer);
    compactionPasses.resetShadowCounters.setBuffer("shadowCounters", this._shadowCounterBuffer);
    compactionPasses.cullShadowInstances.setBuffer("sourceInstances", sourceBuffer);
    compactionPasses.cullShadowInstances.setBuffer("shadowData", this._shadowDataBuffer);
    compactionPasses.cullShadowInstances.setBuffer("shadowParameters", this._shadowParameterBuffer);
    compactionPasses.cullShadowInstances.setBuffer("shadowInstances", this._shadowOutputBuffer);
    compactionPasses.cullShadowInstances.setBuffer("shadowCounters", this._shadowCounterBuffer);
    compactionPasses.finalizeShadowCulling.setBuffer("shadowData", this._shadowDataBuffer);
    compactionPasses.finalizeShadowCulling.setBuffer("shadowParameters", this._shadowParameterBuffer);
    compactionPasses.finalizeShadowCulling.setBuffer("shadowCounters", this._shadowCounterBuffer);
    compactionPasses.finalizeShadowCulling.setBuffer("shadowIndirectArguments", this._shadowIndirectBuffer);
  }

  /**
   * Keeps shadow distance culling identical to the Forward compaction boundary.
   * @param cameraPosition Current world-space camera position.
   * @param distanceScale Live LOD distance multiplier.
   */
  setFineCullingState(cameraPosition: Vector3, distanceScale: number): void {
    this._fineCullCamera.copyFrom(cameraPosition);
    this._fineCullDistanceScale = distanceScale;
  }

  /** @inheritdoc */
  prepareShadowViews(_context: unknown, shadowSlices: unknown, shadowSliceCount: number): void {
    if (shadowSliceCount > SURFACE_SHADOW_CASCADE_CAPACITY) {
      throw new RangeError(
        `[SurfaceStaticShadowViewProvider] ${shadowSliceCount} cascades exceed ` +
          `${SURFACE_SHADOW_CASCADE_CAPACITY} prepared streams.`
      );
    }
    const data = this._shadowData;
    const batchCount = this._shadowBatches.length;
    data[0] = batchCount;
    let commandCount = 0;
    const commandWordOffset = (1 + batchCount * 2) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
    const workgroupSize = this._compactionPasses.cullShadowInstances.workgroupSize[0];
    for (let index = 0; index < batchCount; index++) {
      const batch = this._shadowBatches[index];
      const batchWordOffset = (1 + index * 2) * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
      data[batchWordOffset] = batch.outputInstanceOffset;
      data[batchWordOffset + 1] = batch.indirectWordOffset;
      data[batchWordOffset + 2] = batch.indirectRecordCount;
      data[batchWordOffset + 3] = index;
      data[batchWordOffset + 4] = batch.plan.fineCullRadius;
      data[batchWordOffset + 5] = batch.batcher._getRuntimeScale();
      data[batchWordOffset + 6] = batch.materials.reduce(
        (radius, material) => Math.max(radius, material.windDisplacementRadius),
        0
      );
      data[batchWordOffset + 7] = batch.plan.prototype.maxDistance * this._fineCullDistanceScale;
      commandCount += batch.batcher._writeShadowCommands(
        data,
        commandWordOffset + commandCount * SURFACE_COMPACTION_COMMAND_WORD_STRIDE,
        index,
        workgroupSize
      );
    }
    data[1] = commandCount;
    const usedWordCount = commandWordOffset + commandCount * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
    let shadowDataChanged = !this._prepared || usedWordCount !== this._shadowDataWordCount;
    if (!shadowDataChanged) {
      const snapshot = this._shadowDataSnapshot;
      for (let index = 0; index < usedWordCount; index++) {
        if (data[index] !== snapshot[index]) {
          shadowDataChanged = true;
          break;
        }
      }
    }
    if (shadowDataChanged) {
      this._shadowDataSnapshot.set(data.subarray(0, usedWordCount));
      this._shadowDataBuffer.setData(data, 0, 0, usedWordCount);
      this._shadowDataWordCount = usedWordCount;
    }

    const resetWorkgroupSize = this._compactionPasses.resetShadowCounters.workgroupSize[0];
    const slices = shadowSlices as readonly SurfaceShadowSlice[];
    const parameters = this._shadowParameters;
    parameters[0] = shadowSliceCount;
    parameters[1] = this._outputInstanceCapacity;
    parameters[2] = this._indirectWordCapacity;
    parameters[3] = batchCount;
    parameters[4] = this._fineCullCamera.x;
    parameters[5] = this._fineCullCamera.y;
    parameters[6] = this._fineCullCamera.z;
    parameters[7] = 0;
    for (let cascadeIndex = 0; cascadeIndex < shadowSliceCount; cascadeIndex++) {
      const slice = slices[cascadeIndex];
      const cascadeWordOffset = (2 + cascadeIndex * 11) * 4;
      parameters[cascadeWordOffset] = slice.cullPlaneCount;
      parameters[cascadeWordOffset + 1] = 0;
      parameters[cascadeWordOffset + 2] = 0;
      parameters[cascadeWordOffset + 3] = 0;
      for (let planeIndex = 0; planeIndex < slice.cullPlaneCount; planeIndex++) {
        const plane = slice.cullPlanes[planeIndex];
        const offset = cascadeWordOffset + (1 + planeIndex) * 4;
        parameters[offset] = plane.normal.x;
        parameters[offset + 1] = plane.normal.y;
        parameters[offset + 2] = plane.normal.z;
        parameters[offset + 3] = plane.distance;
      }
    }
    let parametersChanged = !this._prepared;
    if (!parametersChanged) {
      const snapshot = this._shadowParameterSnapshot;
      for (let index = 0; index < parameters.length; index++) {
        if (parameters[index] !== snapshot[index]) {
          parametersChanged = true;
          break;
        }
      }
    }
    if (!shadowDataChanged && !parametersChanged) return;
    if (parametersChanged) {
      this._shadowParameterSnapshot.set(parameters);
      this._shadowParameterBuffer.setData(parameters);
    }
    this._compactionPasses.resetShadowCounters.dispatch(
      Math.ceil((batchCount * shadowSliceCount) / resetWorkgroupSize)
    );
    if (commandCount > 0) {
      this._compactionPasses.cullShadowInstances.dispatch(commandCount);
    }
    this._compactionPasses.finalizeShadowCulling.dispatch(batchCount);
    this._prepared = true;
  }

  /** @inheritdoc */
  getShadowViewBinding(
    renderer: MeshRenderer,
    shadowCascadeIndex: number,
    subMeshIndex: number
  ): MeshRendererShadowViewBinding {
    const binding = this._bindings.get(renderer)?.[shadowCascadeIndex]?.[subMeshIndex];
    if (!binding) {
      throw new Error(
        `[SurfaceStaticShadowViewProvider] missing cascade ${shadowCascadeIndex}, sub-mesh ${subMeshIndex} binding.`
      );
    }
    return binding;
  }

  private _createRendererBindings(): void {
    for (const batch of this._shadowBatches) {
      const renderers = batch.batcher._getRenderers();
      let batchRecordIndex = 0;
      for (let sourceIndex = 0; sourceIndex < batch.plan.renderSources.length; sourceIndex++) {
        const source = batch.plan.renderSources[sourceIndex];
        if (!source.rendererSpec.castShadows) continue;
        const renderer = renderers[sourceIndex] as InternalIndirectDrawRenderer;
        const forwardMesh = renderer.mesh as InternalBufferMesh;
        const instanceBindingIndex = forwardMesh.vertexBufferBindings.length - 1;
        const cascadeBindings: MeshRendererShadowViewBinding[][] = [];
        for (let cascadeIndex = 0; cascadeIndex < SURFACE_SHADOW_CASCADE_CAPACITY; cascadeIndex++) {
          const vertexBufferBindings: Array<VertexBufferBinding | undefined> = new Array(instanceBindingIndex + 1);
          vertexBufferBindings[instanceBindingIndex] = new VertexBufferBinding(
            this._shadowOutputBuffer,
            SURFACE_INSTANCE_STRIDE,
            (cascadeIndex * this._outputInstanceCapacity + batch.outputInstanceOffset) * SURFACE_INSTANCE_STRIDE
          );
          cascadeBindings.push(
            source.sourceMesh.subMeshes.map((_subMesh, subMeshIndex) => ({
              primitive: forwardMesh._primitive,
              indirectBuffer: this._shadowIndirectBuffer,
              indirectOffset:
                (cascadeIndex * this._indirectWordCapacity +
                  batch.indirectWordOffset +
                  (batchRecordIndex + subMeshIndex) * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE) *
                Uint32Array.BYTES_PER_ELEMENT,
              vertexBufferBindings
            }))
          );
        }
        batchRecordIndex += source.sourceMesh.subMeshes.length;
        this._bindings.set(renderer, cascadeBindings);
        renderer._setShadowViewProvider(this);
      }
    }
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
  /** Prototype-space sphere radius used by conservative instance-distance culling. */
  readonly fineCullRadius: number;
  /** Whether this batch uses instance-distance compute culling. */
  readonly fineCulling: boolean;

  private readonly _packedMetadata: boolean;
  private readonly _outputInstanceOffset: number;
  private readonly _indirectWordOffset: number;
  private readonly _indirectRecordCount: number;
  private readonly _ranges: ReadonlyMap<number, SurfaceStaticRangeState>;
  private readonly _renderers: readonly MeshRenderer[];
  private readonly _fineCullState: SurfaceFineCullBatchState | null;
  private _dirty = true;
  private _instanceCount = 0;
  private _runtimeScale = 1;

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
   * @param fineCullState Shared fine-culling state, or null for range-copy batches.
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
    lodHeight: number,
    fineCullState: SurfaceFineCullBatchState | null
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
    this.fineCulling = fineCullState !== null;
    this.fineCullRadius = fineCullState?.radius ?? 0;
    this._fineCullState = fineCullState;
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
   * @param fineCulling Whether this range crosses the camera-distance boundary.
   */
  setRangeVisibleCount(
    rangeOffset: number,
    visibleCount: number,
    lodFade: number = 1,
    fineCulling: boolean = false
  ): void {
    const state = this._ranges.get(rangeOffset);
    if (!state) throw new Error(`[SurfaceStaticBatcher] unknown source range ${rangeOffset}`);
    if (!Number.isInteger(visibleCount) || visibleCount < 0 || visibleCount > state.range.count) {
      throw new RangeError(`[SurfaceStaticBatcher] invalid visible count ${visibleCount} for range ${rangeOffset}`);
    }
    if (!Number.isFinite(lodFade) || lodFade < -1 || lodFade > 1) {
      throw new RangeError(`[SurfaceStaticBatcher] invalid LOD fade ${lodFade} for range ${rangeOffset}`);
    }
    const nextFineCulling = this.fineCulling && visibleCount > 0 && fineCulling;
    if (state.visibleCount === visibleCount && state.lodFade === lodFade && state.fineCulling === nextFineCulling) {
      return;
    }
    state.visibleCount = visibleCount;
    state.lodFade = lodFade;
    state.fineCulling = nextFineCulling;
    this._dirty = true;
  }

  /** @internal */
  _needsFlush(): boolean {
    return this._dirty;
  }

  /** @internal */
  _hasFineCullCommands(): boolean {
    if (!this._fineCullState) return false;
    for (const state of this._ranges.values()) {
      if (state.visibleCount > 0 && state.fineCulling) return true;
    }
    return false;
  }

  /** @internal */
  _invalidateFineCulling(): void {
    if (this.fineCulling) {
      this._dirty = true;
    }
  }

  /** @internal */
  _writeFineCullBatchData(output: Float32Array): void {
    if (this._fineCullState) {
      writeFineCullBatchData(output, [this._fineCullState]);
    }
  }

  /** @internal */
  _getRenderers(): readonly MeshRenderer[] {
    return this._renderers;
  }

  /** @internal */
  _getRuntimeScale(): number {
    return this._runtimeScale;
  }

  /**
   * Writes workgroup-sized source ranges consumed by cascade shadow compaction.
   * @param output Shared f32 command storage.
   * @param wordOffset First available scalar word.
   * @param batchIndex Shadow batch receiving the compacted records.
   * @param workgroupSize Maximum source records described by one command.
   * @returns Number of commands written.
   * @internal
   */
  _writeShadowCommands(output: Float32Array, wordOffset: number, batchIndex: number, workgroupSize: number): number {
    let commandCount = 0;
    for (const state of this._ranges.values()) {
      let rangeOffset = 0;
      while (rangeOffset < state.visibleCount) {
        const commandOffset = wordOffset + commandCount * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
        const metadataCode = this._packedMetadata ? encodeLodFade(state.lodFade) + 1 : 0;
        output[commandOffset] = state.sourceInstanceOffset + rangeOffset;
        output[commandOffset + 1] = Math.min(workgroupSize, state.visibleCount - rangeOffset);
        output[commandOffset + 2] = batchIndex;
        output[commandOffset + 3] = state.fineCulling ? -metadataCode - 1 : metadataCode;
        rangeOffset += workgroupSize;
        commandCount++;
      }
    }
    return commandCount;
  }

  /**
   * Writes this batch's indirect header and updates its renderer state.
   * @param commands Shared u32 command array.
   * @param batchWordOffset First word of this batch header.
   * @param fineExecution Whether this batch has boundary ranges assigned to fine culling.
   * @internal
   */
  _writeBatchHeader(commands: Uint32Array, batchWordOffset: number, fineExecution: boolean): void {
    let instanceCount = 0;
    let copiedInstanceCount = 0;
    for (const state of this._ranges.values()) {
      instanceCount += state.visibleCount;
      if (!fineExecution || !state.fineCulling) {
        copiedInstanceCount += state.visibleCount;
      }
    }
    this._instanceCount = instanceCount;
    commands[batchWordOffset] = this._indirectWordOffset;
    commands[batchWordOffset + 1] = this._indirectRecordCount;
    commands[batchWordOffset + 2] = copiedInstanceCount;
    commands[batchWordOffset + 3] = this._fineCullState?.index ?? 0;
    for (const renderer of this._renderers) {
      renderer.entity.isActive = instanceCount > 0;
      (renderer.mesh as BufferMesh).instanceCount = instanceCount;
    }
    this._dirty = false;
  }

  /**
   * Writes direct-copy commands for legacy batches and fully-inside fine-cull ranges.
   * @param commands Shared u32 command array.
   * @param copyWordOffset First word available for range-copy commands.
   * @returns Number of range-copy commands written.
   * @internal
   */
  _writeLegacyCommands(commands: Uint32Array, copyWordOffset: number): number {
    let instanceOffset = 0;
    let copyCommandCount = 0;
    for (const state of this._ranges.values()) {
      const count = state.visibleCount;
      if (count === 0) continue;
      if (state.fineCulling) continue;
      const commandOffset = copyWordOffset + copyCommandCount * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
      commands[commandOffset] = state.sourceInstanceOffset;
      commands[commandOffset + 1] = this._outputInstanceOffset + instanceOffset;
      commands[commandOffset + 2] = count;
      commands[commandOffset + 3] = this._packedMetadata ? encodeLodFade(state.lodFade) + 1 : 0;
      instanceOffset += count;
      copyCommandCount++;
    }
    return copyCommandCount;
  }

  /**
   * Writes one workgroup-sized command for each visible boundary-range tile.
   * @param commands Shared u32 command array.
   * @param copyWordOffset First word available for fine-cull commands.
   * @param fineCullWorkgroupSize Maximum instances described by one fine-cull command.
   * @returns Number of fine-cull commands written.
   * @internal
   */
  _writeFineCullCommands(commands: Uint32Array, copyWordOffset: number, fineCullWorkgroupSize: number): number {
    if (!this._fineCullState) return 0;
    let commandCount = 0;
    for (const state of this._ranges.values()) {
      if (!state.fineCulling) continue;
      let rangeOffset = 0;
      while (rangeOffset < state.visibleCount) {
        const commandOffset = copyWordOffset + commandCount * SURFACE_COMPACTION_COMMAND_WORD_STRIDE;
        commands[commandOffset] = state.sourceInstanceOffset + rangeOffset;
        commands[commandOffset + 1] = this._outputInstanceOffset;
        commands[commandOffset + 2] = Math.min(fineCullWorkgroupSize, state.visibleCount - rangeOffset);
        commands[commandOffset + 3] = this._fineCullState.index;
        rangeOffset += fineCullWorkgroupSize;
        commandCount++;
      }
    }
    return commandCount;
  }

  /**
   * Applies live category tint and scale to every compacted renderer.
   * @param tint Linear RGB category multiplier.
   * @param scale Uniform prototype scale multiplier.
   */
  setTuning(tint: readonly [number, number, number], scale: number): void {
    this._runtimeScale = scale;
    if (this._fineCullState && this._fineCullState.runtimeScale !== scale) {
      this._fineCullState.runtimeScale = scale;
      this._dirty = true;
    }
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
  materials: ReadonlyMap<string, SurfaceMaterial>,
  fineCullState: SurfaceFineCullBatchState | null
): SurfaceStaticBatcher {
  const { prototype, lod, ranges, renderSources } = plan;
  const states = new Map<number, SurfaceStaticRangeState>();
  for (const item of ranges) {
    states.set(item.range.offset, {
      range: item.range,
      sourceInstanceOffset: sourceOffsets.get(item.range.offset)!,
      visibleCount: 0,
      lodFade: 1,
      fineCulling: false
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
    SurfaceMaterial.setRendererFineCulling(false, 0, 0, renderer.shaderData);
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
    Math.max(lodHeight, 0.01),
    fineCullState
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
  dispatchWorkgroups: number,
  fineCullBatchCapacity: number
): void {
  const limits = engine.computeCapabilities;
  if (limits.maxStorageBuffersPerStage < 6) {
    throw new RangeError(
      `[SurfaceStaticBatchGroup] fine culling requires 6 storage buffers, but the device supports ` +
        `${limits.maxStorageBuffersPerStage}.`
    );
  }
  const storageBindings = [
    ["source instance", sourceInstanceCapacity * SURFACE_INSTANCE_STRIDE],
    ["output instance", outputInstanceCapacity * SURFACE_INSTANCE_STRIDE],
    ["compaction command", commandCapacity * SURFACE_COMPACTION_COMMAND_WORD_STRIDE * Uint32Array.BYTES_PER_ELEMENT],
    [
      "indirect argument",
      indirectRecordCapacity * SURFACE_COMPACTION_INDIRECT_WORD_STRIDE * Uint32Array.BYTES_PER_ELEMENT
    ],
    ["fine-cull batch", fineCullBatchCapacity * 4 * Float32Array.BYTES_PER_ELEMENT],
    ["fine-cull parameter", 4 * Float32Array.BYTES_PER_ELEMENT],
    ["fine-cull counter", fineCullBatchCapacity * Uint32Array.BYTES_PER_ELEMENT]
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

function validateShadowCapacity(
  engine: Engine,
  outputInstanceCapacity: number,
  indirectRecordCapacity: number,
  batchCapacity: number,
  commandCapacity: number
): void {
  const limits = engine.computeCapabilities;
  const storageBindings = [
    ["shadow output instance", outputInstanceCapacity * SURFACE_SHADOW_CASCADE_CAPACITY * SURFACE_INSTANCE_STRIDE],
    [
      "shadow indirect argument",
      indirectRecordCapacity *
        SURFACE_SHADOW_CASCADE_CAPACITY *
        SURFACE_COMPACTION_INDIRECT_WORD_STRIDE *
        Uint32Array.BYTES_PER_ELEMENT
    ],
    [
      "shadow command",
      (1 + batchCapacity * 2 + commandCapacity) *
        SURFACE_COMPACTION_COMMAND_WORD_STRIDE *
        Float32Array.BYTES_PER_ELEMENT
    ],
    ["shadow counter", batchCapacity * SURFACE_SHADOW_CASCADE_CAPACITY * Uint32Array.BYTES_PER_ELEMENT],
    ["shadow parameter", SURFACE_SHADOW_PARAMETER_VECTOR_COUNT * 4 * Float32Array.BYTES_PER_ELEMENT]
  ] as const;
  for (const [name, byteLength] of storageBindings) {
    if (byteLength > limits.maxStorageBufferBindingSize) {
      throw new RangeError(
        `[SurfaceStaticShadowViewProvider] ${name} storage requires ${byteLength} bytes, exceeding ` +
          `${limits.maxStorageBufferBindingSize}.`
      );
    }
  }
  if (commandCapacity > limits.maxWorkgroupsPerDimension) {
    throw new RangeError(
      `[SurfaceStaticShadowViewProvider] shadow compaction requires ${commandCapacity} workgroups, exceeding ` +
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

function boundsSphereRadius(bounds: BoundingBox): number {
  return Math.hypot(
    Math.max(Math.abs(bounds.min.x), Math.abs(bounds.max.x)),
    Math.max(Math.abs(bounds.min.y), Math.abs(bounds.max.y)),
    Math.max(Math.abs(bounds.min.z), Math.abs(bounds.max.z))
  );
}

function writeFineCullBatchData(output: Float32Array, states: readonly SurfaceFineCullBatchState[]): void {
  for (const state of states) {
    const offset = state.index * 4;
    output[offset] = state.maxDistance;
    output[offset + 1] = state.radius;
    output[offset + 2] = state.runtimeScale;
    output[offset + 3] = 0;
  }
}

function encodeLodFade(lodFade: number): number {
  return Math.round((lodFade * 0.5 + 0.5) * 65535);
}

/**
 * Tests whether a prototype can use camera-only instance compaction without changing shadows or LOD transitions.
 * @param prototype Runtime prototype contract.
 * @returns True for one-LOD, non-cross-fading prototypes whose renderers do not cast shadows.
 */
export function isSurfaceFineCullingEligible(prototype: SurfacePrototypeSpec): boolean {
  return (
    prototype.lods.length === 1 &&
    !prototype.lodCrossfade &&
    prototype.lods[0].renderers.every((renderer) => !renderer.castShadows)
  );
}
