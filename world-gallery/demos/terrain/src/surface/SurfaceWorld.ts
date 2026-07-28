import {
  AssetType,
  BoundingBox,
  BoundingFrustum,
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Engine,
  Entity,
  GLTFResource,
  Matrix,
  MeshRenderer,
  Script,
  Vector3
} from "@galacean/engine";
import type { SurfaceCategory, SurfaceCellRange } from "./SurfaceContract";
import type { TerrainData } from "../data/TerrainData";
import type { TerrainWorldNoiseSpec } from "../loader/ManifestLoader";
import type { TerrainWorldNoiseTuning } from "../TerrainMaterial";
import { loadSurfaceManifest } from "./SurfaceManifestLoader";
import { surfaceCellDebugHue } from "./SurfaceDebugColor";
import { SurfaceMaterial } from "./SurfaceMaterial";
import { RegionCoverageStreamer } from "./RegionCoverageStreamer";
import {
  createSurfaceInstancedMesh,
  expandSurfaceBounds,
  findSurfaceModelMeshes,
  transformSurfaceBounds
} from "./SurfaceInstancedMesh";
import { SURFACE_RUNTIME_SCALE_MAX, SURFACE_RUNTIME_SCALE_MIN } from "./SurfaceRuntimeContract";
import { SurfaceStaticBatcher, type SurfaceStaticBatcherRange } from "./SurfaceStaticBatcher";
import type {
  SurfacePrototypeRendererSpec,
  SurfacePrototypeSpec,
  SurfaceRuntimeManifest,
  SurfaceRuntimeSnapshot,
  SurfaceRuntimeTuning,
  SurfaceRuntimeTuningUpdate
} from "./SurfaceRuntimeContract";
import { WorldSurfaceStreamer } from "./WorldSurfaceStreamer";

/** Optional terrain continuation inputs used only when the manifest declares streamed world rules. */
export interface SurfaceWorldCreateOptions {
  readonly terrain?: TerrainData;
  readonly worldNoise?: TerrainWorldNoiseSpec;
}

const CATEGORIES: readonly SurfaceCategory[] = ["grass", "flower", "shrub", "tree", "rock", "cliff"];

interface SurfaceBatch {
  readonly range: SurfaceCellRange;
  readonly prototype: SurfacePrototypeSpec;
  readonly lods: readonly SurfaceLodBatch[];
  readonly centre: Vector3;
  readonly renderBounds: BoundingBox;
  readonly placementRadius: number;
  readonly prototypeRadius: number;
  readonly maxInstanceScale: number;
  readonly staticBatcher: SurfaceStaticBatcher | null;
  activeLod: number;
  instanceCount: number;
  transition: SurfaceLodTransition | null;
}

interface SurfaceLodBatch {
  readonly index: number;
  readonly renderers: readonly MeshRenderer[];
  readonly height: number;
}

interface SurfaceLodTransition {
  from: number;
  to: number;
  elapsed: number;
}

/**
 * Streams deterministic surface records into explicit instanced mesh batches.
 * Instances never allocate entities. WebGPU single-LOD impostor ranges retain cell culling state
 * while sharing prototype renderer batches; the WebGL reference path retains cell renderers.
 */
export class SurfaceWorld {
  private readonly _manifest: SurfaceRuntimeManifest;
  private readonly _camera: Camera;
  private readonly _materials: readonly SurfaceMaterial[];
  private readonly _batches: readonly SurfaceBatch[];
  private readonly _staticBatchers: readonly SurfaceStaticBatcher[];
  private readonly _categoryCounts: Record<SurfaceCategory, number>;
  private readonly _impostorInstances: number;
  private readonly _worldStreamer: WorldSurfaceStreamer | null;
  private readonly _coverageStreamer: RegionCoverageStreamer | null;
  private readonly _tuning: MutableSurfaceRuntimeTuning;
  private readonly _viewProjection = new Matrix();
  private readonly _frustum = new BoundingFrustum();
  private _visible = true;
  private _time = 0;

  private constructor(
    manifest: SurfaceRuntimeManifest,
    camera: Camera,
    materials: readonly SurfaceMaterial[],
    batches: readonly SurfaceBatch[],
    staticBatchers: readonly SurfaceStaticBatcher[],
    categoryCounts: Record<SurfaceCategory, number>,
    impostorInstances: number,
    worldStreamer: WorldSurfaceStreamer | null,
    coverageStreamer: RegionCoverageStreamer | null
  ) {
    this._manifest = manifest;
    this._camera = camera;
    this._materials = materials;
    this._batches = batches;
    this._staticBatchers = staticBatchers;
    this._categoryCounts = categoryCounts;
    this._impostorInstances = impostorInstances;
    this._worldStreamer = worldStreamer;
    this._coverageStreamer = coverageStreamer;
    const defaultColors = categoryRecordFactory(() => [1, 1, 1] as [number, number, number]);
    const defaultScales = categoryRecord(1);
    for (const [category, color] of Object.entries(manifest.runtimeDefaults?.color ?? {}) as Array<
      [SurfaceCategory, readonly [number, number, number]]
    >) {
      defaultColors[category] = [...color];
    }
    Object.assign(defaultScales, manifest.runtimeDefaults?.scale);
    this._tuning = {
      enabled: categoryRecord(true),
      density: categoryRecord(1),
      color: defaultColors,
      scale: defaultScales,
      wind: {
        enabled: true,
        strength: 1,
        direction: [-0.788, 0, -0.615]
      },
      lod: {
        enabled: true,
        distanceScale: 1
      },
      world: {
        enabled: worldStreamer !== null,
        spacing: categoryRecord(1),
        biomeOffset: [0, 0]
      },
      debugView: "surface"
    };
  }

  /**
   * Loads a complete surface bundle and builds its spatial instance batches.
   * @param engine Engine that owns GPU buffers, models, textures and materials.
   * @param root Identity-transform entity receiving one child per renderer batch.
   * @param camera Camera used for LOD and distance culling.
   * @param manifestUrl Absolute surface manifest URL.
   * @returns Ready-to-render surface world.
   */
  static async create(
    engine: Engine,
    root: Entity,
    camera: Camera,
    manifestUrl: string,
    options: SurfaceWorldCreateOptions = {}
  ): Promise<SurfaceWorld> {
    const loaded = await loadSurfaceManifest(engine, manifestUrl);
    const lodDitherUrl = new URL(loaded.manifest.lodDitherTexture, manifestUrl).href;
    const materialList = await Promise.all(
      loaded.manifest.materials.map((spec) => SurfaceMaterial.create(engine, spec, manifestUrl, lodDitherUrl))
    );
    const materials = new Map(materialList.map((material) => [material.id, material]));
    const modelUrls = Array.from(
      new Set(
        loaded.manifest.prototypeLibrary.flatMap((prototype) =>
          prototype.lods.flatMap((lod) => lod.renderers.map((renderer) => new URL(renderer.model, manifestUrl).href))
        )
      )
    );
    const modelResources = await Promise.all(
      modelUrls.map(
        async (url) =>
          [
            url,
            await engine.resourceManager.load<GLTFResource>({
              type: AssetType.GLTF,
              url,
              params: { keepMeshData: true }
            })
          ] as const
      )
    );
    const models = new Map(modelResources);
    const prototypes = new Map(loaded.manifest.prototypeLibrary.map((prototype) => [prototype.id, prototype]));
    const binary = new DataView(loaded.binary);
    const decodedRanges = loaded.manifest.ranges.map((range) => ({
      range,
      decoded: decodeInstanceRange(binary, range)
    }));
    const staticSources = new Map<string, SurfaceStaticBatcherRange[]>();
    if (engine.graphicsBackend === "webgpu") {
      for (const item of decodedRanges) {
        const prototype = prototypes.get(item.range.prototype)!;
        if (!prototype.impostor || prototype.lods.length !== 1 || prototype.lodCrossfade) continue;
        const sources = staticSources.get(prototype.id) ?? [];
        sources.push({
          range: item.range,
          data: item.decoded.data,
          maxScale: item.decoded.maxScale
        });
        staticSources.set(prototype.id, sources);
      }
    }
    const staticBatchersByPrototype = new Map<string, SurfaceStaticBatcher>();
    for (const [prototypeId, sources] of staticSources) {
      staticBatchersByPrototype.set(
        prototypeId,
        SurfaceStaticBatcher.create(
          engine,
          root.createChild(`${prototypeId}-compacted`),
          prototypes.get(prototypeId)!,
          sources,
          models,
          materials,
          manifestUrl
        )
      );
    }
    const staticBatchers = Array.from(staticBatchersByPrototype.values());
    const batches: SurfaceBatch[] = [];

    for (const { range, decoded: decodedInstances } of decodedRanges) {
      const prototype = prototypes.get(range.prototype)!;
      const staticBatcher = staticBatchersByPrototype.get(range.prototype) ?? null;
      const lods: SurfaceLodBatch[] = [];
      let prototypeRadius = staticBatcher?.prototypeRadius ?? 0;
      if (staticBatcher) {
        lods.push({ index: prototype.lods[0].index, renderers: [], height: staticBatcher.lodHeight });
      } else {
        const instanceBuffer = new Buffer(
          engine,
          BufferBindFlag.VertexBuffer,
          decodedInstances.data,
          BufferUsage.Static
        );
        for (const lod of prototype.lods) {
          const renderers: MeshRenderer[] = [];
          let lodHeight = 0;
          for (let rendererIndex = 0; rendererIndex < lod.renderers.length; rendererIndex++) {
            const rendererSpec = lod.renderers[rendererIndex];
            const modelUrl = new URL(rendererSpec.model, manifestUrl).href;
            const sourceMeshes = findSurfaceModelMeshes(models.get(modelUrl)!, rendererSpec.meshName);
            for (let primitiveIndex = 0; primitiveIndex < sourceMeshes.length; primitiveIndex++) {
              const sourceMesh = sourceMeshes[primitiveIndex];
              const prototypeBounds = transformSurfaceBounds(sourceMesh.bounds, rendererSpec);
              lodHeight = Math.max(lodHeight, prototypeBounds.max.y - prototypeBounds.min.y);
              prototypeRadius = Math.max(prototypeRadius, boundsRadius(prototypeBounds));
              const entity = root.createChild(
                `${range.prototype}-${range.cell[0]}-${range.cell[1]}-lod${lod.index}-renderer${rendererIndex}-primitive${primitiveIndex}`
              );
              const renderer = entity.addComponent(MeshRenderer);
              renderer.mesh = createSurfaceInstancedMesh(
                engine,
                sourceMesh,
                instanceBuffer,
                expandSurfaceBounds(
                  range.bounds,
                  prototypeBounds,
                  decodedInstances.maxScale * SURFACE_RUNTIME_SCALE_MAX
                ),
                range.count
              );
              renderer.castShadows = rendererSpec.castShadows;
              renderer.receiveShadows = rendererSpec.receiveShadows;
              renderer.enableVertexColor = sourceMesh.vertexElements.some((element) => element.attribute === "COLOR_0");
              SurfaceMaterial.setRendererVertexColor(renderer.enableVertexColor, renderer.shaderData);
              SurfaceMaterial.setRendererInstanced(true, renderer.shaderData);
              SurfaceMaterial.setRendererBillboard(prototype.impostor, renderer.shaderData);
              SurfaceMaterial.setRendererTransform(rendererSpec, renderer.shaderData);
              SurfaceMaterial.setRendererDebugInfo(range.category, range.cell, renderer.shaderData);
              SurfaceMaterial.setRendererLodFade(false, 1, renderer.shaderData);
              SurfaceMaterial.setRendererWorldNoise(false, renderer.shaderData);
              SurfaceMaterial.setRendererTuning([1, 1, 1], 1, renderer.shaderData);
              const materialId = rendererSpec.materials[Math.min(primitiveIndex, rendererSpec.materials.length - 1)];
              const material = materials.get(materialId);
              if (!material)
                throw new Error(`[SurfaceWorld] ${range.prototype} references unknown material ${materialId}`);
              for (let subMeshIndex = 0; subMeshIndex < sourceMesh.subMeshes.length; subMeshIndex++) {
                renderer.setMaterial(subMeshIndex, material);
              }
              entity.isActive = lod.index === 0;
              renderers.push(renderer);
            }
          }
          lods.push({ index: lod.index, renderers, height: lodHeight });
        }
      }
      const bounds = range.bounds;
      const centre = new Vector3(
        (bounds[0] + bounds[3]) * 0.5,
        (bounds[1] + bounds[4]) * 0.5,
        (bounds[2] + bounds[5]) * 0.5
      );
      const scaledPrototypeRadius = prototypeRadius * decodedInstances.maxScale;
      batches.push({
        range,
        prototype,
        lods,
        centre,
        renderBounds: createConservativeRangeBounds(bounds, scaledPrototypeRadius * SURFACE_RUNTIME_SCALE_MAX),
        placementRadius: Math.hypot(bounds[3] - centre.x, bounds[4] - centre.y, bounds[5] - centre.z),
        prototypeRadius: scaledPrototypeRadius,
        maxInstanceScale: decodedInstances.maxScale,
        staticBatcher,
        activeLod: 0,
        instanceCount: range.count,
        transition: null
      });
    }

    const categoryCounts = categoryRecord(0);
    let impostorInstances = 0;
    for (const range of loaded.manifest.ranges) {
      categoryCounts[range.category] += range.count;
      if (prototypes.get(range.prototype)!.impostor) impostorInstances += range.count;
    }
    const resources = { models, materials, prototypes };
    const worldDistribution = loaded.manifest.worldDistribution;
    let worldStreamer: WorldSurfaceStreamer | null = null;
    if (worldDistribution) {
      if (!options.terrain || !options.worldNoise) {
        throw new Error("[SurfaceWorld] worldDistribution requires terrain and worldNoise inputs");
      }
      worldStreamer = WorldSurfaceStreamer.create(
        engine,
        root.createChild("world-noise-surface"),
        camera,
        options.terrain,
        options.worldNoise,
        worldDistribution,
        manifestUrl,
        resources
      );
    }
    let coverageStreamer: RegionCoverageStreamer | null = null;
    if (loaded.manifest.coverageStreaming?.enabled) {
      if (!options.terrain) {
        throw new Error("[SurfaceWorld] coverageStreaming requires finite terrain data");
      }
      coverageStreamer = await RegionCoverageStreamer.create(
        engine,
        root.createChild("region-coverage-surface"),
        camera,
        options.terrain,
        loaded.manifest,
        manifestUrl,
        resources
      );
    }
    const world = new SurfaceWorld(
      loaded.manifest,
      camera,
      materialList,
      batches,
      staticBatchers,
      categoryCounts,
      impostorInstances,
      worldStreamer,
      coverageStreamer
    );
    const follower = root.addComponent(SurfaceWorldFollower);
    follower.initialize(world);
    world.setTuning({});
    return world;
  }

  /**
   * Returns an immutable copy of all runtime controls.
   * @returns Current category, wind, LOD and debug tuning.
   */
  getTuning(): SurfaceRuntimeTuning {
    return cloneTuning(this._tuning);
  }

  /**
   * Applies category, wind, LOD or debug controls without recompiling placement data.
   * @param values Partial runtime tuning.
   */
  setTuning(values: SurfaceRuntimeTuningUpdate): void {
    if (values.enabled) Object.assign(this._tuning.enabled, values.enabled);
    if (values.density) {
      for (const [category, density] of Object.entries(values.density) as Array<[SurfaceCategory, number]>) {
        if (!(density >= 0 && density <= 1)) throw new Error(`[SurfaceWorld] ${category} density must be in 0..1`);
        this._tuning.density[category] = density;
      }
    }
    if (values.color) {
      for (const [category, color] of Object.entries(values.color) as Array<
        [SurfaceCategory, readonly [number, number, number]]
      >) {
        if (color.length !== 3 || color.some((value) => !(value >= 0 && value <= 2))) {
          throw new Error(`[SurfaceWorld] ${category} color components must be in 0..2`);
        }
        this._tuning.color[category] = [...color];
      }
    }
    if (values.scale) {
      for (const [category, scale] of Object.entries(values.scale) as Array<[SurfaceCategory, number]>) {
        if (!(scale >= SURFACE_RUNTIME_SCALE_MIN && scale <= SURFACE_RUNTIME_SCALE_MAX)) {
          throw new Error(
            `[SurfaceWorld] ${category} scale must be in ${SURFACE_RUNTIME_SCALE_MIN}..${SURFACE_RUNTIME_SCALE_MAX}`
          );
        }
        this._tuning.scale[category] = scale;
      }
    }
    if (values.wind) Object.assign(this._tuning.wind, values.wind);
    if (values.lod) Object.assign(this._tuning.lod, values.lod);
    if (values.world) {
      if (values.world.enabled !== undefined) this._tuning.world.enabled = values.world.enabled;
      if (values.world.spacing) {
        for (const [category, spacing] of Object.entries(values.world.spacing) as Array<[SurfaceCategory, number]>) {
          if (!(spacing >= 0.5 && spacing <= 4)) {
            throw new Error(`[SurfaceWorld] ${category} world spacing must be in 0.5..4`);
          }
          this._tuning.world.spacing[category] = spacing;
        }
      }
      if (values.world.biomeOffset) {
        if (values.world.biomeOffset.some((value) => !Number.isFinite(value))) {
          throw new Error("[SurfaceWorld] world biome offset must contain finite values");
        }
        this._tuning.world.biomeOffset = [...values.world.biomeOffset];
      }
    }
    if (values.debugView) this._tuning.debugView = values.debugView;
    const debugView =
      this._tuning.debugView === "normal"
        ? 1
        : this._tuning.debugView === "wind-weight"
          ? 2
          : this._tuning.debugView === "category"
            ? 3
            : this._tuning.debugView === "cell"
              ? 4
              : this._tuning.debugView === "world-biome"
                ? 5
                : 0;
    for (const material of this._materials) material.setDebugView(debugView);
    for (const batch of this._batches) {
      for (const lod of batch.lods) {
        for (const renderer of lod.renderers) {
          SurfaceMaterial.setRendererTuning(
            this._tuning.color[batch.range.category],
            this._tuning.scale[batch.range.category],
            renderer.shaderData
          );
        }
      }
    }
    for (const batcher of this._staticBatchers) {
      batcher.setTuning(this._tuning.color[batcher.category], this._tuning.scale[batcher.category]);
    }
    this.update(0);
  }

  /**
   * Keeps streamed surface grounding and CPU constraints aligned with live terrain noise.
   * @param tuning Validated terrain world-noise values.
   */
  setWorldNoiseTuning(tuning: TerrainWorldNoiseTuning): void {
    for (const material of this._materials) material.setWorldNoiseTuning(tuning);
    this._worldStreamer?.setWorldNoiseTuning(tuning);
  }

  /**
   * Aligns streamed world-surface visibility with the terrain background implementation.
   * @param active Whether terrain world noise is the active procedural continuation.
   */
  setProceduralTerrainActive(active: boolean): void {
    this._worldStreamer?.setProceduralTerrainActive(active);
    this.update(0);
  }

  /**
   * Shows or isolates every surface renderer without changing user category controls.
   * @param visible Whether finite and streamed surface batches may be submitted.
   */
  setVisible(visible: boolean): void {
    if (this._visible === visible) return;
    this._visible = visible;
    this._worldStreamer?.setVisible(visible);
    this._coverageStreamer?.setVisible(visible);
    this.update(0);
  }

  /**
   * Captures current compiled and visible instance counts.
   * @returns Stable diagnostics for GUI, E2E and performance capture.
   */
  inspect(): SurfaceRuntimeSnapshot {
    const visible = this._batches.filter((batch) => batch.activeLod >= 0);
    const lodCounts = new Array(Math.max(1, ...this._batches.map((batch) => batch.lods.length))).fill(0);
    let visibleInstances = 0;
    const visibleCategoryCounts = categoryRecord(0);
    for (const batch of visible) {
      const count = Math.floor(batch.range.count * this._tuning.density[batch.range.category]);
      visibleInstances += count;
      visibleCategoryCounts[batch.range.category] += count;
      if (batch.activeLod >= 0) lodCounts[batch.activeLod] += count;
    }
    const world = this._worldStreamer?.inspect() ?? {
      instances: 0,
      rendererBatches: 0,
      activeRendererBatches: 0,
      rejectedByBudget: 0,
      categoryCounts: categoryRecord(0),
      fingerprint: 0
    };
    const coverage = this._coverageStreamer?.inspect() ?? {
      instances: 0,
      rendererBatches: 0,
      activeRendererBatches: 0,
      categoryCounts: categoryRecord(0),
      fingerprint: 0
    };
    visibleInstances += coverage.instances;
    for (const category of CATEGORIES) {
      visibleCategoryCounts[category] += coverage.categoryCounts[category];
    }
    const directRendererBatches = this._batches.reduce(
      (count, batch) => count + batch.lods.reduce((lodCount, lod) => lodCount + lod.renderers.length, 0),
      0
    );
    const visibleDirectRendererBatches = visible.reduce(
      (count, batch) =>
        count +
        batch.lods.reduce(
          (lodCount, lod) => lodCount + lod.renderers.filter((renderer) => renderer.entity.isActive).length,
          0
        ),
      0
    );
    const finiteRendererBatches =
      directRendererBatches + this._staticBatchers.reduce((count, batcher) => count + batcher.rendererBatchCount, 0);
    const visibleFiniteRendererBatches =
      visibleDirectRendererBatches +
      this._staticBatchers.reduce((count, batcher) => count + batcher.activeRendererBatchCount, 0);
    return {
      totalInstances: this._manifest.binary.count,
      totalRanges: this._manifest.ranges.length,
      prototypes: this._manifest.prototypeLibrary.length,
      rendererBatches: coverage.rendererBatches + world.rendererBatches + finiteRendererBatches,
      visibleRendererBatches:
        coverage.activeRendererBatches + world.activeRendererBatches + visibleFiniteRendererBatches,
      visibleRanges: visible.length,
      visibleInstances,
      visibleCategoryCounts,
      transitioningRanges: visible.filter((batch) => batch.transition !== null).length,
      lodCounts,
      categoryCounts: { ...this._categoryCounts },
      impostorInstances: this._impostorInstances,
      worldSurfaceAvailable: this._worldStreamer !== null,
      worldInstances: world.instances,
      worldRendererBatches: world.rendererBatches,
      worldActiveRendererBatches: world.activeRendererBatches,
      worldRejectedByBudget: world.rejectedByBudget,
      worldCategoryCounts: { ...world.categoryCounts },
      worldFingerprint: world.fingerprint,
      coverageAvailable: this._coverageStreamer !== null,
      coverageInstances: coverage.instances,
      coverageRendererBatches: coverage.rendererBatches,
      coverageActiveRendererBatches: coverage.activeRendererBatches,
      coverageCategoryCounts: { ...coverage.categoryCounts },
      coverageFingerprint: coverage.fingerprint,
      tuning: this.getTuning()
    };
  }

  /** @internal Advances wind and selects one LOD per visible cell. */
  update(deltaTime: number): void {
    this._time += deltaTime;
    const direction = normalizeDirection(this._tuning.wind.direction);
    for (const material of this._materials) {
      material.setWind(this._time, this._tuning.wind.enabled, this._tuning.wind.strength, direction);
    }
    const cameraPosition = this._camera.entity.transform.worldPosition;
    const tangent = Math.tan((this._camera.fieldOfView * Math.PI) / 360);
    if (this._staticBatchers.length > 0 && this._camera.enableFrustumCulling) {
      Matrix.multiply(this._camera.projectionMatrix, this._camera.viewMatrix, this._viewProjection);
      this._frustum.calculateFromMatrix(this._viewProjection);
    }
    for (const batch of this._batches) {
      const categoryEnabled = this._tuning.enabled[batch.range.category];
      const density = this._tuning.density[batch.range.category];
      const runtimeScale = this._tuning.scale[batch.range.category];
      const centreDistance = Vector3.distance(cameraPosition, batch.centre);
      const cullingDistance = centreDistance - batch.placementRadius - batch.prototypeRadius * runtimeScale;
      let selectedLod = -1;
      if (
        this._visible &&
        categoryEnabled &&
        density > 0 &&
        cullingDistance <= batch.prototype.maxDistance * this._tuning.lod.distanceScale
      ) {
        selectedLod = this._tuning.lod.enabled
          ? selectLod(batch, Math.max(centreDistance, 0.01), tangent, this._tuning.lod.distanceScale, runtimeScale)
          : 0;
      }
      updateBatchLod(
        batch,
        selectedLod,
        Math.floor(batch.range.count * density),
        deltaTime,
        this._manifest.lodCrossfadeDuration
      );
      batch.staticBatcher?.setRangeVisibleCount(
        batch.range.offset,
        batch.activeLod >= 0 && (!this._camera.enableFrustumCulling || this._frustum.intersectsBox(batch.renderBounds))
          ? batch.instanceCount
          : 0
      );
    }
    for (const batcher of this._staticBatchers) batcher.flush();
    this._coverageStreamer?.update(this._tuning);
    this._worldStreamer?.update(this._tuning);
  }
}

interface MutableSurfaceRuntimeTuning {
  enabled: Record<SurfaceCategory, boolean>;
  density: Record<SurfaceCategory, number>;
  color: Record<SurfaceCategory, [number, number, number]>;
  scale: Record<SurfaceCategory, number>;
  wind: {
    enabled: boolean;
    strength: number;
    direction: [number, number, number];
  };
  lod: {
    enabled: boolean;
    distanceScale: number;
  };
  world: {
    enabled: boolean;
    spacing: Record<SurfaceCategory, number>;
    biomeOffset: [number, number];
  };
  debugView: "surface" | "normal" | "wind-weight" | "category" | "cell" | "world-biome";
}

class SurfaceWorldFollower extends Script {
  private _world!: SurfaceWorld;

  initialize(world: SurfaceWorld): void {
    this._world = world;
  }

  override onUpdate(deltaTime: number): void {
    this._world.update(deltaTime);
  }
}

function decodeInstanceRange(binary: DataView, range: SurfaceCellRange): { data: Float32Array; maxScale: number } {
  const output = new Float32Array(range.count * 16);
  let maxScale = 0;
  for (let localIndex = 0; localIndex < range.count; localIndex++) {
    const sourceOffset = 16 + (range.offset + localIndex) * 56;
    const targetOffset = localIndex * 16;
    output[targetOffset] = binary.getFloat32(sourceOffset + 4, true);
    output[targetOffset + 1] = binary.getFloat32(sourceOffset + 8, true);
    output[targetOffset + 2] = binary.getFloat32(sourceOffset + 12, true);
    output[targetOffset + 3] = hashToUnit(binary.getUint32(sourceOffset + 52, true));
    for (let component = 0; component < 4; component++) {
      output[targetOffset + 4 + component] = binary.getFloat32(sourceOffset + 16 + component * 4, true);
    }
    output[targetOffset + 8] = binary.getFloat32(sourceOffset + 32, true);
    output[targetOffset + 9] = binary.getFloat32(sourceOffset + 36, true);
    output[targetOffset + 10] = binary.getFloat32(sourceOffset + 40, true);
    maxScale = Math.max(maxScale, output[targetOffset + 8], output[targetOffset + 9], output[targetOffset + 10]);
    output[targetOffset + 11] = binary.getFloat32(sourceOffset + 44, true);
    const color = binary.getUint32(sourceOffset + 48, true);
    output[targetOffset + 12] = (color & 0xff) / 255;
    output[targetOffset + 13] = ((color >>> 8) & 0xff) / 255;
    output[targetOffset + 14] = ((color >>> 16) & 0xff) / 255;
    output[targetOffset + 15] = ((color >>> 24) & 0xff) / 255;
  }
  const sorted = sortInstanceDataByPriority(output);
  const cellHue = surfaceCellDebugHue(range.cell[0], range.cell[1]);
  for (let index = 0; index < range.count; index++) sorted[index * 16 + 3] = cellHue;
  return { data: sorted, maxScale };
}

function createConservativeRangeBounds(bounds: SurfaceCellRange["bounds"], prototypeRadius: number): BoundingBox {
  return new BoundingBox(
    new Vector3(bounds[0] - prototypeRadius, bounds[1] - prototypeRadius, bounds[2] - prototypeRadius),
    new Vector3(bounds[3] + prototypeRadius, bounds[4] + prototypeRadius, bounds[5] + prototypeRadius)
  );
}

function selectLod(
  batch: SurfaceBatch,
  distance: number,
  fovTangent: number,
  distanceScale: number,
  runtimeScale: number
): number {
  const projectedHeight = (batch.lods[0].height * batch.maxInstanceScale * runtimeScale) / (2 * distance * fovTangent);
  for (const lod of batch.prototype.lods) {
    if (projectedHeight >= lod.screenRelativeHeight / distanceScale) return lod.index;
  }
  return batch.lods[batch.lods.length - 1].index;
}

function boundsRadius(bounds: { readonly min: Vector3; readonly max: Vector3 }): number {
  return Math.max(
    Math.abs(bounds.min.x),
    Math.abs(bounds.min.y),
    Math.abs(bounds.min.z),
    Math.abs(bounds.max.x),
    Math.abs(bounds.max.y),
    Math.abs(bounds.max.z)
  );
}

function updateBatchLod(
  batch: SurfaceBatch,
  targetLod: number,
  instanceCount: number,
  deltaTime: number,
  duration: number
): void {
  if (batch.transition === null && targetLod === batch.activeLod && instanceCount === batch.instanceCount) {
    return;
  }
  batch.instanceCount = instanceCount;
  if (targetLod < 0) {
    batch.activeLod = -1;
    batch.transition = null;
    setBatchLodState(batch, -1, -1, 0, instanceCount);
    return;
  }

  if (batch.activeLod < 0) {
    batch.activeLod = targetLod;
    batch.transition = null;
    setBatchLodState(batch, targetLod, -1, 0, instanceCount);
    return;
  }

  const transition = batch.transition;
  if (transition) {
    if (targetLod === transition.from) {
      transition.from = transition.to;
      transition.to = targetLod;
      transition.elapsed = duration - transition.elapsed;
    } else if (targetLod !== transition.to) {
      batch.activeLod = transition.elapsed < duration * 0.5 ? transition.from : transition.to;
      batch.transition = null;
    }
  }

  if (!batch.transition && targetLod !== batch.activeLod) {
    if (!batch.prototype.lodCrossfade) {
      batch.activeLod = targetLod;
    } else {
      batch.transition = { from: batch.activeLod, to: targetLod, elapsed: 0 };
    }
  }

  if (!batch.transition) {
    setBatchLodState(batch, batch.activeLod, -1, 0, instanceCount);
    return;
  }

  batch.transition.elapsed = Math.min(batch.transition.elapsed + deltaTime, duration);
  const remaining = 1 - batch.transition.elapsed / duration;
  setBatchLodState(batch, batch.transition.from, batch.transition.to, remaining, instanceCount);
  if (batch.transition.elapsed >= duration) {
    batch.activeLod = batch.transition.to;
    batch.transition = null;
    setBatchLodState(batch, batch.activeLod, -1, 0, instanceCount);
  }
}

function setBatchLodState(
  batch: SurfaceBatch,
  primaryLod: number,
  secondaryLod: number,
  remaining: number,
  instanceCount: number
): void {
  for (const lod of batch.lods) {
    const isPrimary = lod.index === primaryLod;
    const isSecondary = lod.index === secondaryLod;
    const active = isPrimary || isSecondary;
    for (const renderer of lod.renderers) {
      renderer.entity.isActive = active;
      (renderer.mesh as BufferMesh).instanceCount = active ? instanceCount : 0;
      if (secondaryLod >= 0) {
        SurfaceMaterial.setRendererLodFade(true, isPrimary ? remaining : -remaining, renderer.shaderData);
      } else {
        SurfaceMaterial.setRendererLodFade(false, 1, renderer.shaderData);
      }
    }
  }
}

function hashToUnit(value: number): number {
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  value = Math.imul(value, 0x846ca68b);
  value ^= value >>> 16;
  return (value >>> 0) / 0x100000000;
}

function categoryRecord<T>(value: T): Record<SurfaceCategory, T> {
  return Object.fromEntries(CATEGORIES.map((category) => [category, value])) as Record<SurfaceCategory, T>;
}

function categoryRecordFactory<T>(factory: () => T): Record<SurfaceCategory, T> {
  return Object.fromEntries(CATEGORIES.map((category) => [category, factory()])) as Record<SurfaceCategory, T>;
}

function cloneTuning(tuning: MutableSurfaceRuntimeTuning): SurfaceRuntimeTuning {
  return {
    enabled: { ...tuning.enabled },
    density: { ...tuning.density },
    color: Object.fromEntries(CATEGORIES.map((category) => [category, [...tuning.color[category]]])) as Record<
      SurfaceCategory,
      [number, number, number]
    >,
    scale: { ...tuning.scale },
    wind: { ...tuning.wind, direction: [...tuning.wind.direction] as [number, number, number] },
    lod: { ...tuning.lod },
    world: {
      enabled: tuning.world.enabled,
      spacing: { ...tuning.world.spacing },
      biomeOffset: [...tuning.world.biomeOffset]
    },
    debugView: tuning.debugView
  };
}

function sortInstanceDataByPriority(source: Float32Array): Float32Array {
  const records = Array.from({ length: source.length / 16 }, (_, index) => index);
  records.sort((left, right) => source[left * 16 + 3] - source[right * 16 + 3] || left - right);
  const output = new Float32Array(source.length);
  for (let target = 0; target < records.length; target++) {
    output.set(source.subarray(records[target] * 16, records[target] * 16 + 16), target * 16);
  }
  return output;
}

function normalizeDirection(direction: readonly [number, number, number]): [number, number, number] {
  const length = Math.hypot(...direction);
  if (length < 0.000001) return [0, 0, 0];
  return [direction[0] / length, direction[1] / length, direction[2] / length];
}
