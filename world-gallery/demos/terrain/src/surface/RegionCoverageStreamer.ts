import {
  BoundingBox,
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Engine,
  Entity,
  GLTFResource,
  MeshRenderer,
  Vector3
} from "@galacean/engine";
import type { TerrainData } from "../data/TerrainData";
import type { SurfaceCategory, SurfaceRule, SurfaceTerrainSample } from "./SurfaceContract";
import {
  passesSurfaceConstraints,
  sampleSurfaceMask,
  surfaceCandidatePosition,
  surfaceInstanceVariation,
  surfaceLatticeId,
  surfaceSourcePriority,
  surfaceUnitHash
} from "./SurfaceDistribution";
import {
  createSurfaceInstancedMesh,
  findSurfaceModelMeshes,
  rebindSurfaceInstanceBuffer,
  SURFACE_INSTANCE_STRIDE,
  transformSurfaceBounds
} from "./SurfaceInstancedMesh";
import { loadSurfaceMasks, type LoadedSurfaceMask } from "./SurfaceMaskLoader";
import { SurfaceMaterial } from "./SurfaceMaterial";
import {
  SURFACE_RUNTIME_SCALE_MAX,
  type SurfaceCoverageStreamingSpec,
  type SurfacePrototypeSpec,
  type SurfaceRuntimeManifest,
  type SurfaceRuntimeTuning
} from "./SurfaceRuntimeContract";

/** Resource handles shared with the static and procedural surface runtimes. */
export interface RegionCoverageResources {
  readonly models: ReadonlyMap<string, GLTFResource>;
  readonly materials: ReadonlyMap<string, SurfaceMaterial>;
  readonly prototypes: ReadonlyMap<string, SurfacePrototypeSpec>;
}

/** Dynamic counters for finite density-mask coverage. */
export interface RegionCoverageSnapshot {
  readonly instances: number;
  readonly rendererBatches: number;
  readonly activeRendererBatches: number;
  readonly categoryCounts: Readonly<Record<SurfaceCategory, number>>;
  readonly fingerprint: number;
}

interface CoverageRuleBatch {
  readonly rule: SurfaceRule;
  readonly mask: LoadedSurfaceMask;
  readonly prototype: SurfacePrototypeSpec;
  readonly lods: readonly CoverageLodBatch[];
  readonly lod0Height: number;
  readonly prototypeRadius: number;
  readonly maxInstanceScale: number;
  readonly cells: Map<string, readonly CoverageCandidate[]>;
}

interface CoverageLodBatch {
  readonly index: number;
  buffer: Buffer;
  capacity: number;
  readonly renderers: readonly MeshRenderer[];
}

interface CoverageCandidate {
  readonly x: number;
  readonly height: number;
  readonly z: number;
  readonly sourceId: number;
  readonly priority: number;
}

const CATEGORIES: readonly SurfaceCategory[] = ["grass", "flower", "shrub", "tree", "rock", "cliff"];

/**
 * Generates finite high-density coverage from local masks only around the active camera.
 * Accepted candidates are cached by world cell; GPU buffers contain only the current distance-limited set.
 */
export class RegionCoverageStreamer {
  private readonly _engine: Engine;
  private readonly _camera: Camera;
  private readonly _terrain: TerrainData;
  private readonly _spec: SurfaceCoverageStreamingSpec;
  private readonly _seed: number;
  private readonly _batches: readonly CoverageRuleBatch[];
  private _lastCameraX = Number.POSITIVE_INFINITY;
  private _lastCameraY = Number.POSITIVE_INFINITY;
  private _lastCameraZ = Number.POSITIVE_INFINITY;
  private _lastSignature = "";
  private _visible = true;
  private _instances = 0;
  private _categoryCounts = categoryRecord(0);
  private _fingerprint = 0x811c9dc5;

  private constructor(
    engine: Engine,
    camera: Camera,
    terrain: TerrainData,
    spec: SurfaceCoverageStreamingSpec,
    seed: number,
    batches: readonly CoverageRuleBatch[]
  ) {
    this._engine = engine;
    this._camera = camera;
    this._terrain = terrain;
    this._spec = spec;
    this._seed = seed;
    this._batches = batches;
  }

  /**
   * Loads CPU density masks and creates growable instanced renderer batches.
   * @param engine Engine that owns the dynamic buffers.
   * @param root Root entity receiving coverage renderers.
   * @param camera Camera used for distance and LOD selection.
   * @param terrain Finite authored height/control data.
   * @param manifest Validated runtime manifest.
   * @param manifestUrl Manifest URL used to resolve masks and models.
   * @param resources Models, materials, and prototypes already loaded by `SurfaceWorld`.
   * @returns Ready finite coverage streamer.
   */
  static async create(
    engine: Engine,
    root: Entity,
    camera: Camera,
    terrain: TerrainData,
    manifest: SurfaceRuntimeManifest,
    manifestUrl: string,
    resources: RegionCoverageResources
  ): Promise<RegionCoverageStreamer> {
    const spec = manifest.coverageStreaming!;
    const sourceRules = new Map((manifest.sourceRules ?? []).map((rule) => [rule.id, rule]));
    const selectedRules = spec.ruleIds.map((ruleId) => sourceRules.get(ruleId)!);
    const requiredMaskIds = new Set(selectedRules.map((rule) => rule.mask));
    const masks = await loadSurfaceMasks(
      (manifest.debugMasks ?? []).filter((mask) => requiredMaskIds.has(mask.id)),
      manifestUrl
    );
    const batches: CoverageRuleBatch[] = [];
    for (const rule of selectedRules) {
      const prototype = resources.prototypes.get(rule.prototype)!;
      const lods: CoverageLodBatch[] = [];
      let lod0Height = 1;
      let prototypeRadius = 0;
      for (const lod of prototype.lods) {
        const buffer = new Buffer(engine, BufferBindFlag.VertexBuffer, SURFACE_INSTANCE_STRIDE, BufferUsage.Dynamic);
        const renderers: MeshRenderer[] = [];
        let lodHeight = 0;
        for (let rendererIndex = 0; rendererIndex < lod.renderers.length; rendererIndex++) {
          const rendererSpec = lod.renderers[rendererIndex];
          const modelUrl = new URL(rendererSpec.model, manifestUrl).href;
          const sourceMeshes = findSurfaceModelMeshes(resources.models.get(modelUrl)!, rendererSpec.meshName);
          for (let primitiveIndex = 0; primitiveIndex < sourceMeshes.length; primitiveIndex++) {
            const sourceMesh = sourceMeshes[primitiveIndex];
            const prototypeBounds = transformSurfaceBounds(sourceMesh.bounds, rendererSpec);
            lodHeight = Math.max(lodHeight, prototypeBounds.max.y - prototypeBounds.min.y);
            prototypeRadius = Math.max(prototypeRadius, boundsRadius(prototypeBounds));
            const entity = root.createChild(
              `coverage-${rule.id}-lod${lod.index}-renderer${rendererIndex}-primitive${primitiveIndex}`
            );
            const renderer = entity.addComponent(MeshRenderer);
            renderer.mesh = createSurfaceInstancedMesh(
              engine,
              sourceMesh,
              buffer,
              new BoundingBox(new Vector3(), new Vector3()),
              0
            );
            renderer.castShadows = rendererSpec.castShadows;
            renderer.receiveShadows = rendererSpec.receiveShadows;
            renderer.enableVertexColor = sourceMesh.vertexElements.some((element) => element.attribute === "COLOR_0");
            SurfaceMaterial.setRendererVertexColor(renderer.enableVertexColor, renderer.shaderData);
            SurfaceMaterial.setRendererInstanced(true, renderer.shaderData);
            SurfaceMaterial.setRendererBillboard(prototype.impostor, renderer.shaderData);
            SurfaceMaterial.setRendererWorldNoise(false, renderer.shaderData);
            SurfaceMaterial.setRendererTransform(rendererSpec, renderer.shaderData);
            SurfaceMaterial.setRendererDebugInfo(rule.category, [0, 0], renderer.shaderData);
            SurfaceMaterial.setRendererWorldCellSize(spec.cellSize, renderer.shaderData);
            SurfaceMaterial.setRendererLodFade(false, 1, renderer.shaderData);
            SurfaceMaterial.setRendererTuning([1, 1, 1], 1, renderer.shaderData);
            const materialId = rendererSpec.materials[Math.min(primitiveIndex, rendererSpec.materials.length - 1)];
            const material = resources.materials.get(materialId);
            if (!material)
              throw new Error(`[RegionCoverage] ${rule.prototype} references unknown material ${materialId}`);
            for (let subMeshIndex = 0; subMeshIndex < sourceMesh.subMeshes.length; subMeshIndex++) {
              renderer.setMaterial(subMeshIndex, material);
            }
            entity.isActive = false;
            renderers.push(renderer);
          }
        }
        if (lod.index === 0) lod0Height = Math.max(lodHeight, 0.01);
        lods.push({ index: lod.index, buffer, capacity: 1, renderers });
      }
      batches.push({
        rule,
        mask: masks.get(rule.mask)!,
        prototype,
        lods,
        lod0Height,
        prototypeRadius,
        maxInstanceScale: Math.max(rule.scale.horizontal[1], rule.scale.vertical[1]),
        cells: new Map()
      });
    }
    return new RegionCoverageStreamer(engine, camera, terrain, spec, manifest.seed, batches);
  }

  /**
   * Rebuilds visible coverage after meaningful camera or tuning changes.
   * @param tuning Shared surface runtime tuning.
   */
  update(tuning: SurfaceRuntimeTuning): void {
    this._applyRendererTuning(tuning);
    const cameraPosition = this._camera.entity.transform.worldPosition;
    const signature = tuningSignature(tuning);
    const movement = Math.hypot(
      cameraPosition.x - this._lastCameraX,
      cameraPosition.y - this._lastCameraY,
      cameraPosition.z - this._lastCameraZ
    );
    if (movement < this._spec.rebuildDistance && signature === this._lastSignature) return;
    this._lastCameraX = cameraPosition.x;
    this._lastCameraY = cameraPosition.y;
    this._lastCameraZ = cameraPosition.z;
    this._lastSignature = signature;
    this._instances = 0;
    this._categoryCounts = categoryRecord(0);
    this._fingerprint = 0x811c9dc5;

    for (const batch of this._batches) this._rebuildRule(batch, tuning, cameraPosition);
  }

  /**
   * Shows or hides all finite coverage without changing category controls.
   * @param visible Whether coverage renderers may submit draws.
   */
  setVisible(visible: boolean): void {
    if (this._visible === visible) return;
    this._visible = visible;
    this.invalidate();
  }

  /** Forces the next update to repack visible instances. */
  invalidate(): void {
    this._lastSignature = "";
  }

  /**
   * Returns current finite coverage counters.
   * @returns Submitted instances, renderer activity, category counts, and deterministic fingerprint.
   */
  inspect(): RegionCoverageSnapshot {
    return {
      instances: this._instances,
      rendererBatches: this._batches.reduce(
        (count, batch) => count + batch.lods.reduce((sum, lod) => sum + lod.renderers.length, 0),
        0
      ),
      activeRendererBatches: this._batches.reduce(
        (count, batch) =>
          count +
          batch.lods.reduce((sum, lod) => sum + lod.renderers.filter((renderer) => renderer.entity.isActive).length, 0),
        0
      ),
      categoryCounts: { ...this._categoryCounts },
      fingerprint: this._fingerprint >>> 0
    };
  }

  private _rebuildRule(batch: CoverageRuleBatch, tuning: SurfaceRuntimeTuning, cameraPosition: Vector3): void {
    const { rule, prototype } = batch;
    const enabled =
      this._visible && this._spec.enabled && tuning.enabled[rule.category] && tuning.density[rule.category] > 0;
    const radius = prototype.maxDistance * tuning.lod.distanceScale;
    if (!enabled) {
      setCoverageLodData(this._engine, batch, [], cameraPosition, radius, this._terrain);
      return;
    }

    syncCoverageCells(
      batch,
      this._spec.cellSize,
      cameraPosition.x,
      cameraPosition.z,
      radius,
      this._seed,
      this._terrain
    );
    const radiusSquared = radius * radius;
    const candidates: CoverageCandidate[] = [];
    for (const cell of batch.cells.values()) {
      for (const candidate of cell) {
        if (
          candidate.priority < tuning.density[rule.category] &&
          (candidate.x - cameraPosition.x) ** 2 +
            (candidate.height - cameraPosition.y) ** 2 +
            (candidate.z - cameraPosition.z) ** 2 <=
            radiusSquared
        ) {
          candidates.push(candidate);
        }
      }
    }
    candidates.sort((left, right) => left.priority - right.priority || left.sourceId - right.sourceId);
    this._instances += candidates.length;
    this._categoryCounts[rule.category] += candidates.length;
    this._fingerprint = fingerprintUint32(this._fingerprint, hashString(rule.id));
    for (const candidate of candidates) {
      this._fingerprint = fingerprintUint32(this._fingerprint, candidate.sourceId);
    }

    const tangent = Math.tan((this._camera.fieldOfView * Math.PI) / 360);
    const lodData = batch.lods.map(() => [] as number[]);
    for (const candidate of candidates) {
      const distance = Math.max(
        0.01,
        Math.hypot(candidate.x - cameraPosition.x, candidate.height - cameraPosition.y, candidate.z - cameraPosition.z)
      );
      const lodIndex = tuning.lod.enabled
        ? selectCoverageLod(
            prototype,
            batch.lod0Height * batch.maxInstanceScale * tuning.scale[rule.category],
            distance,
            tangent,
            tuning.lod.distanceScale
          )
        : 0;
      appendCoverageInstance(lodData[lodIndex], rule, candidate, this._seed);
    }
    setCoverageLodData(this._engine, batch, lodData, cameraPosition, radius, this._terrain);
  }

  private _applyRendererTuning(tuning: SurfaceRuntimeTuning): void {
    for (const batch of this._batches) {
      for (const lod of batch.lods) {
        for (const renderer of lod.renderers) {
          SurfaceMaterial.setRendererTuning(
            tuning.color[batch.rule.category],
            tuning.scale[batch.rule.category],
            renderer.shaderData
          );
        }
      }
    }
  }
}

function syncCoverageCells(
  batch: CoverageRuleBatch,
  cellSize: number,
  cameraX: number,
  cameraZ: number,
  radius: number,
  seed: number,
  terrain: TerrainData
): void {
  const mask = batch.mask;
  const domainMaxX = mask.origin[0] + mask.size[0];
  const domainMaxZ = mask.origin[1] + mask.size[1];
  const minimumCellX = Math.max(Math.floor(mask.origin[0] / cellSize), Math.floor((cameraX - radius) / cellSize));
  const maximumCellX = Math.min(Math.ceil(domainMaxX / cellSize) - 1, Math.floor((cameraX + radius) / cellSize));
  const minimumCellZ = Math.max(Math.floor(mask.origin[1] / cellSize), Math.floor((cameraZ - radius) / cellSize));
  const maximumCellZ = Math.min(Math.ceil(domainMaxZ / cellSize) - 1, Math.floor((cameraZ + radius) / cellSize));
  const required = new Set<string>();
  for (let cellZ = minimumCellZ; cellZ <= maximumCellZ; cellZ++) {
    for (let cellX = minimumCellX; cellX <= maximumCellX; cellX++) {
      const key = `${cellX},${cellZ}`;
      required.add(key);
      if (!batch.cells.has(key)) {
        batch.cells.set(key, generateCoverageCell(batch.rule, mask, cellSize, cellX, cellZ, seed, terrain));
      }
    }
  }
  for (const key of batch.cells.keys()) {
    if (!required.has(key)) batch.cells.delete(key);
  }
}

function generateCoverageCell(
  rule: SurfaceRule,
  mask: LoadedSurfaceMask,
  cellSize: number,
  cellX: number,
  cellZ: number,
  seed: number,
  terrain: TerrainData
): readonly CoverageCandidate[] {
  const step = rule.spacing;
  const countX = Math.ceil(mask.size[0] / step);
  const countZ = Math.ceil(mask.size[1] / step);
  const minimumX = cellX * cellSize;
  const maximumX = minimumX + cellSize;
  const minimumZ = cellZ * cellSize;
  const maximumZ = minimumZ + cellSize;
  const minimumGridX = Math.max(0, Math.floor((minimumX - mask.origin[0]) / step) - 1);
  const maximumGridX = Math.min(countX - 1, Math.ceil((maximumX - mask.origin[0]) / step));
  const minimumGridZ = Math.max(0, Math.floor((minimumZ - mask.origin[1]) / step) - 1);
  const maximumGridZ = Math.min(countZ - 1, Math.ceil((maximumZ - mask.origin[1]) / step));
  const densityProbability = Math.min(1, rule.densityPerSquareMetre * step * step);
  const output: CoverageCandidate[] = [];

  for (let gridZ = minimumGridZ; gridZ <= maximumGridZ; gridZ++) {
    for (let gridX = minimumGridX; gridX <= maximumGridX; gridX++) {
      const sourceId = surfaceLatticeId(gridX, gridZ, countX);
      const position = surfaceCandidatePosition(seed, rule.id, sourceId, mask.origin, step, gridX, gridZ);
      const x = position[0];
      const z = position[1];
      if (x < minimumX || x >= maximumX || z < minimumZ || z >= maximumZ) continue;
      const probability = sampleSurfaceMask(mask, x, z) * densityProbability;
      if (surfaceUnitHash(seed, rule.id, sourceId, 4) >= probability) continue;
      const terrainSample = sampleFiniteTerrain(terrain, x, z);
      if (!terrainSample || !passesSurfaceConstraints(rule.constraints, terrainSample)) continue;
      output.push({
        x,
        height: terrainSample.height,
        z,
        sourceId,
        priority: surfaceSourcePriority(sourceId)
      });
    }
  }
  return output;
}

function sampleFiniteTerrain(terrain: TerrainData, worldX: number, worldZ: number): SurfaceTerrainSample | undefined {
  const gridX = Math.floor(worldX / terrain.vertexSpacing);
  const gridZ = Math.floor(worldZ / terrain.vertexSpacing);
  const regionX = Math.floor(gridX / terrain.regionSize);
  const regionZ = Math.floor(gridZ / terrain.regionSize);
  const layer = terrain.getRegionLayer(regionX, regionZ);
  if (layer < 0) return undefined;
  const region = terrain.regions[layer];
  const localX = positiveModulo(gridX, terrain.regionSize);
  const localZ = positiveModulo(gridZ, terrain.regionSize);
  const heightAt = (x: number, z: number): number => terrain.decodeHeight(region.heights[z * terrain.regionSize + x]);
  const height = heightAt(localX, localZ);
  const derivativeX =
    (heightAt(Math.min(terrain.regionSize - 1, localX + 1), localZ) - heightAt(Math.max(0, localX - 1), localZ)) /
    (2 * terrain.vertexSpacing);
  const derivativeZ =
    (heightAt(localX, Math.min(terrain.regionSize - 1, localZ + 1)) - heightAt(localX, Math.max(0, localZ - 1))) /
    (2 * terrain.vertexSpacing);
  const control = region.control[localZ * terrain.regionSize + localX];
  return {
    height,
    slope: Math.atan(Math.hypot(derivativeX, derivativeZ)) / (Math.PI * 0.5),
    control,
    hole: (control & 4) !== 0
  };
}

function appendCoverageInstance(output: number[], rule: SurfaceRule, candidate: CoverageCandidate, seed: number): void {
  const variation = surfaceInstanceVariation(
    seed,
    rule.id,
    candidate.sourceId,
    rule.yaw,
    rule.scale.horizontal,
    rule.scale.vertical,
    rule.wind
  );
  output.push(
    candidate.x,
    candidate.height,
    candidate.z,
    candidate.priority,
    ...variation.rotation,
    ...variation.scale,
    variation.windPhase,
    1,
    1,
    1,
    1
  );
}

function setCoverageLodData(
  engine: Engine,
  batch: CoverageRuleBatch,
  data: readonly number[][],
  cameraPosition: Vector3,
  radius: number,
  terrain: TerrainData
): void {
  const extent = batch.prototypeRadius * batch.maxInstanceScale * SURFACE_RUNTIME_SCALE_MAX;
  const bounds = new BoundingBox(
    new Vector3(cameraPosition.x - radius - extent, terrain.minHeight - extent, cameraPosition.z - radius - extent),
    new Vector3(cameraPosition.x + radius + extent, terrain.maxHeight + extent, cameraPosition.z + radius + extent)
  );
  for (const lod of batch.lods) {
    const source = data[lod.index] ?? [];
    const instanceCount = source.length / 16;
    if (instanceCount > lod.capacity) growInstanceBuffer(engine, lod, instanceCount);
    if (source.length > 0) lod.buffer.setData(new Float32Array(source));
    for (const renderer of lod.renderers) {
      renderer.entity.isActive = instanceCount > 0;
      const mesh = renderer.mesh as BufferMesh;
      mesh.instanceCount = instanceCount;
      mesh.bounds = bounds;
    }
  }
}

function growInstanceBuffer(engine: Engine, lod: CoverageLodBatch, required: number): void {
  let capacity = lod.capacity;
  while (capacity < required) capacity *= 2;
  const replacement = new Buffer(
    engine,
    BufferBindFlag.VertexBuffer,
    capacity * SURFACE_INSTANCE_STRIDE,
    BufferUsage.Dynamic
  );
  for (const renderer of lod.renderers) {
    rebindSurfaceInstanceBuffer(renderer.mesh as BufferMesh, replacement);
  }
  lod.buffer.destroy();
  lod.buffer = replacement;
  lod.capacity = capacity;
}

function selectCoverageLod(
  prototype: SurfacePrototypeSpec,
  height: number,
  distance: number,
  fovTangent: number,
  distanceScale: number
): number {
  const projectedHeight = height / (2 * distance * fovTangent);
  for (const lod of prototype.lods) {
    if (projectedHeight >= lod.screenRelativeHeight / distanceScale) return lod.index;
  }
  return prototype.lods[prototype.lods.length - 1].index;
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

function positiveModulo(value: number, divisor: number): number {
  return ((value % divisor) + divisor) % divisor;
}

function tuningSignature(tuning: SurfaceRuntimeTuning): string {
  return JSON.stringify({
    enabled: tuning.enabled,
    density: tuning.density,
    scale: tuning.scale,
    lod: tuning.lod
  });
}

function categoryRecord<T>(value: T): Record<SurfaceCategory, T> {
  return Object.fromEntries(CATEGORIES.map((category) => [category, value])) as Record<SurfaceCategory, T>;
}

function fingerprintUint32(hash: number, value: number): number {
  for (let byte = 0; byte < 4; byte++) {
    hash ^= (value >>> (byte * 8)) & 0xff;
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}

function hashString(value: string): number {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index++) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}
