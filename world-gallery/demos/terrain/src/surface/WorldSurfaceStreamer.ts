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
  ModelMesh,
  Vector3
} from "@galacean/engine";
import type { TerrainData } from "../data/TerrainData";
import { TerrainWorldNoiseSampler } from "../data/TerrainWorldNoiseSampler";
import type { TerrainWorldNoiseSpec } from "../loader/ManifestLoader";
import type { TerrainWorldNoiseTuning } from "../TerrainMaterial";
import type { SurfaceCategory } from "./SurfaceContract";
import {
  createSurfaceInstancedMesh,
  findSurfaceModelMeshes,
  SURFACE_INSTANCE_STRIDE,
  transformSurfaceBounds
} from "./SurfaceInstancedMesh";
import { SurfaceMaterial } from "./SurfaceMaterial";
import { SURFACE_RUNTIME_SCALE_MAX } from "./SurfaceRuntimeContract";
import type {
  SurfacePrototypeSpec,
  SurfaceRuntimeTuning,
  SurfaceWorldDistributionSpec,
  SurfaceWorldRule
} from "./SurfaceRuntimeContract";

/** Resource handles already loaded by the finite surface runtime. */
export interface WorldSurfaceResources {
  readonly models: ReadonlyMap<string, GLTFResource>;
  readonly materials: ReadonlyMap<string, SurfaceMaterial>;
  readonly prototypes: ReadonlyMap<string, SurfacePrototypeSpec>;
}

/** Dynamic counters for streamed procedural background instances. */
export interface WorldSurfaceSnapshot {
  readonly instances: number;
  readonly rendererBatches: number;
  readonly activeRendererBatches: number;
  readonly rejectedByBudget: number;
  readonly categoryCounts: Readonly<Record<SurfaceCategory, number>>;
  readonly fingerprint: number;
}

interface WorldRuleBatch {
  readonly rule: SurfaceWorldRule;
  readonly prototype: SurfacePrototypeSpec;
  readonly lods: readonly WorldLodBatch[];
  readonly lod0Height: number;
  readonly prototypeRadius: number;
  readonly maxInstanceScale: number;
}

interface WorldLodBatch {
  readonly index: number;
  readonly buffer: Buffer;
  readonly renderers: readonly MeshRenderer[];
}

interface WorldCandidate {
  readonly x: number;
  readonly height: number;
  readonly z: number;
  readonly sourceId: number;
  readonly priority: number;
  readonly biome: number;
}

const SURFACE_CATEGORIES: readonly SurfaceCategory[] = ["grass", "flower", "shrub", "tree", "rock", "cliff"];

/**
 * Regenerates deterministic candidates from a global integer lattice and compacts them into one
 * instance buffer per prototype LOD. Finite region placements remain owned by SurfaceWorld.
 */
export class WorldSurfaceStreamer {
  private readonly _camera: Camera;
  private readonly _terrain: TerrainData;
  private readonly _terrainSampler: TerrainWorldNoiseSampler;
  private readonly _spec: SurfaceWorldDistributionSpec;
  private readonly _batches: readonly WorldRuleBatch[];
  private _lastCameraX = Number.POSITIVE_INFINITY;
  private _lastCameraY = Number.POSITIVE_INFINITY;
  private _lastCameraZ = Number.POSITIVE_INFINITY;
  private _lastSignature = "";
  private _visible = true;
  private _proceduralTerrainActive = true;
  private _instances = 0;
  private _rejectedByBudget = 0;
  private _categoryCounts = categoryRecord(0);
  private _fingerprint = 0x811c9dc5;

  private constructor(
    camera: Camera,
    terrain: TerrainData,
    terrainSampler: TerrainWorldNoiseSampler,
    spec: SurfaceWorldDistributionSpec,
    batches: readonly WorldRuleBatch[]
  ) {
    this._camera = camera;
    this._terrain = terrain;
    this._terrainSampler = terrainSampler;
    this._spec = spec;
    this._batches = batches;
  }

  /**
   * Builds shared renderer/LOD buffers for every streamed world rule.
   * @param engine Engine that owns dynamic buffers.
   * @param root Root entity for compacted world-surface renderers.
   * @param camera Camera used for generation radius and LOD selection.
   * @param terrain Terrain data used to exclude finite authored regions.
   * @param noise Exact terrain world-noise settings used by shader grounding.
   * @param spec Versioned deterministic world distribution rules.
   * @param manifestUrl Surface manifest URL used to resolve model references.
   * @param resources Models, materials and prototypes shared with SurfaceWorld.
   * @returns Ready world streamer.
   */
  static create(
    engine: Engine,
    root: Entity,
    camera: Camera,
    terrain: TerrainData,
    noise: TerrainWorldNoiseSpec,
    spec: SurfaceWorldDistributionSpec,
    manifestUrl: string,
    resources: WorldSurfaceResources
  ): WorldSurfaceStreamer {
    const batches: WorldRuleBatch[] = [];
    for (const rule of spec.rules) {
      const prototype = resources.prototypes.get(rule.prototype)!;
      const lods: WorldLodBatch[] = [];
      let lod0Height = 1;
      let prototypeRadius = 0;
      for (const lod of prototype.lods) {
        const buffer = new Buffer(
          engine,
          BufferBindFlag.VertexBuffer,
          rule.maxInstances * SURFACE_INSTANCE_STRIDE,
          BufferUsage.Dynamic
        );
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
              `world-${rule.id}-lod${lod.index}-renderer${rendererIndex}-primitive${primitiveIndex}`
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
            SurfaceMaterial.setRendererWorldNoise(true, renderer.shaderData);
            SurfaceMaterial.setRendererTransform(rendererSpec, renderer.shaderData);
            SurfaceMaterial.setRendererDebugInfo(rule.category, [0, 0], renderer.shaderData);
            SurfaceMaterial.setRendererLodFade(false, 1, renderer.shaderData);
            SurfaceMaterial.setRendererTuning([1, 1, 1], 1, renderer.shaderData);
            SurfaceMaterial.setRendererWorldCellSize(rule.cellSize, renderer.shaderData);
            const materialId = rendererSpec.materials[Math.min(primitiveIndex, rendererSpec.materials.length - 1)];
            const material = resources.materials.get(materialId);
            if (!material)
              throw new Error(`[WorldSurface] ${rule.prototype} references unknown material ${materialId}`);
            for (let subMeshIndex = 0; subMeshIndex < sourceMesh.subMeshes.length; subMeshIndex++) {
              renderer.setMaterial(subMeshIndex, material);
            }
            entity.isActive = false;
            renderers.push(renderer);
          }
        }
        if (lod.index === 0) lod0Height = Math.max(lodHeight, 0.01);
        lods.push({ index: lod.index, buffer, renderers });
      }
      batches.push({
        rule,
        prototype,
        lods,
        lod0Height,
        prototypeRadius,
        maxInstanceScale: Math.max(rule.scale.horizontal[1], rule.scale.vertical[1])
      });
    }
    for (const material of resources.materials.values()) material.bindWorldNoise(terrain, noise);
    return new WorldSurfaceStreamer(camera, terrain, new TerrainWorldNoiseSampler(terrain, noise), spec, batches);
  }

  /**
   * Rebuilds compacted instance buffers after meaningful camera or tuning changes.
   * @param tuning Shared live surface tuning.
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
    this._rejectedByBudget = 0;
    this._categoryCounts = categoryRecord(0);
    this._fingerprint = 0x811c9dc5;

    for (const batch of this._batches) {
      this._rebuildRule(batch, tuning, cameraPosition);
    }
  }

  /** Hides every dynamic renderer and forces regeneration when re-enabled. */
  invalidate(): void {
    this._lastSignature = "";
  }

  /**
   * Isolates terrain diagnostic outputs without mutating category visibility controls.
   * @param visible Whether streamed surface renderers may be submitted.
   */
  setVisible(visible: boolean): void {
    if (this._visible === visible) return;
    this._visible = visible;
    this.invalidate();
  }

  /**
   * Prevents noise-grounded instances from rendering over non-noise terrain backgrounds.
   * @param active Whether the terrain currently renders its procedural noise continuation.
   */
  setProceduralTerrainActive(active: boolean): void {
    if (this._proceduralTerrainActive === active) return;
    this._proceduralTerrainActive = active;
    this.invalidate();
  }

  /** Returns current compacted instance, renderer and budget counters. */
  inspect(): WorldSurfaceSnapshot {
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
      rejectedByBudget: this._rejectedByBudget,
      categoryCounts: { ...this._categoryCounts },
      fingerprint: this._fingerprint >>> 0
    };
  }

  /**
   * Keeps CPU placement constraints aligned with live terrain world-noise controls.
   * @param tuning Validated terrain world-noise values.
   */
  setWorldNoiseTuning(tuning: TerrainWorldNoiseTuning): void {
    this._terrainSampler.setTuning(tuning);
    this.invalidate();
  }

  private _rebuildRule(batch: WorldRuleBatch, tuning: SurfaceRuntimeTuning, cameraPosition: Vector3): void {
    const { rule, prototype } = batch;
    const enabled =
      this._visible &&
      this._proceduralTerrainActive &&
      this._spec.enabled &&
      tuning.world.enabled &&
      tuning.enabled[rule.category] &&
      tuning.density[rule.category] > 0;
    if (!enabled) {
      setWorldLodData(batch, [], cameraPosition, prototype.maxDistance);
      return;
    }

    const spacingScale = tuning.world.spacing[rule.category];
    const radius = prototype.maxDistance * tuning.lod.distanceScale;
    const runtimePrototypeExtent = batch.prototypeRadius * batch.maxInstanceScale * tuning.scale[rule.category];
    const verticalDistance =
      cameraPosition.y < rule.height[0]
        ? rule.height[0] - cameraPosition.y
        : cameraPosition.y > rule.height[1]
          ? cameraPosition.y - rule.height[1]
          : 0;
    if (verticalDistance > radius + runtimePrototypeExtent) {
      setWorldLodData(batch, [], cameraPosition, radius);
      return;
    }
    const candidates = generateCandidates(
      rule,
      this._spec.seed,
      this._spec.biomeNoise,
      cameraPosition.x,
      cameraPosition.y,
      cameraPosition.z,
      radius,
      spacingScale,
      tuning.density[rule.category],
      tuning.world.biomeOffset,
      this._terrain,
      this._terrainSampler
    );
    candidates.sort((left, right) => left.priority - right.priority || left.sourceId - right.sourceId);
    const retained = candidates.slice(0, rule.maxInstances);
    this._rejectedByBudget += Math.max(0, candidates.length - retained.length);
    this._instances += retained.length;
    this._categoryCounts[rule.category] += retained.length;
    this._fingerprint = fingerprintUint32(this._fingerprint, hashString(rule.id));
    for (const candidate of retained) {
      this._fingerprint = fingerprintUint32(this._fingerprint, candidate.sourceId);
    }

    const tangent = Math.tan((this._camera.fieldOfView * Math.PI) / 360);
    const lodData = batch.lods.map(() => [] as number[]);
    for (const candidate of retained) {
      const distance = Math.max(
        0.01,
        Math.hypot(candidate.x - cameraPosition.x, candidate.height - cameraPosition.y, candidate.z - cameraPosition.z)
      );
      const lodIndex = tuning.lod.enabled
        ? selectWorldLod(
            prototype,
            batch.lod0Height * batch.maxInstanceScale * tuning.scale[rule.category],
            distance,
            tangent,
            tuning.lod.distanceScale
          )
        : 0;
      appendInstance(lodData[lodIndex], rule, candidate, this._spec.seed);
    }
    setWorldLodData(batch, lodData, cameraPosition, radius);
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

function generateCandidates(
  rule: SurfaceWorldRule,
  seed: number,
  biomeNoise: SurfaceWorldDistributionSpec["biomeNoise"],
  cameraX: number,
  cameraY: number,
  cameraZ: number,
  radius: number,
  spacingScale: number,
  densityMultiplier: number,
  biomeOffset: readonly [number, number],
  terrain: TerrainData,
  terrainSampler: TerrainWorldNoiseSampler
): WorldCandidate[] {
  const spacing = rule.mode === "coverage" ? rule.spacing * spacingScale : (rule.spacing * spacingScale) / Math.SQRT2;
  const minimumX = Math.floor((cameraX - radius) / spacing);
  const maximumX = Math.ceil((cameraX + radius) / spacing);
  const minimumZ = Math.floor((cameraZ - radius) / spacing);
  const maximumZ = Math.ceil((cameraZ + radius) / spacing);
  const output: WorldCandidate[] = [];
  const cache = new Map<string, WorldCandidate | null>();
  const accepted = (gridX: number, gridZ: number): WorldCandidate | undefined => {
    const key = `${gridX},${gridZ}`;
    const cached = cache.get(key);
    if (cached !== undefined) return cached ?? undefined;
    const sourceId = hashCoordinates(seed, rule.id, gridX, gridZ, 0);
    const x = (gridX + unitHash(seed, rule.id, gridX, gridZ, 1)) * spacing;
    const z = (gridZ + unitHash(seed, rule.id, gridX, gridZ, 2)) * spacing;
    if (terrain.sampleHeight(x, z) !== undefined) {
      cache.set(key, null);
      return undefined;
    }
    const terrainSample = terrainSampler.sample(x, z);
    if (
      terrainSample.height < rule.height[0] ||
      terrainSample.height > rule.height[1] ||
      terrainSample.slope < rule.slope[0] ||
      terrainSample.slope > rule.slope[1]
    ) {
      cache.set(key, null);
      return undefined;
    }
    const biome = ecologyNoise(
      (x + rule.biomeOffset[0] + biomeOffset[0]) * rule.biomeScale,
      (z + rule.biomeOffset[1] + biomeOffset[1]) * rule.biomeScale,
      seed,
      biomeNoise
    );
    const biomeWeight = intervalWeight(biome, rule.biomeRange, rule.biomeFeather);
    const probability = Math.min(1, biomeWeight * rule.densityPerSquareMetre * spacing * spacing);
    if (unitHash(seed, rule.id, gridX, gridZ, 3) >= probability) {
      cache.set(key, null);
      return undefined;
    }
    const candidate = {
      x,
      height: terrainSample.height,
      z,
      sourceId,
      priority: unitHash(seed, rule.id, gridX, gridZ, 4),
      biome
    };
    cache.set(key, candidate);
    return candidate;
  };

  for (let gridZ = minimumZ; gridZ <= maximumZ; gridZ++) {
    for (let gridX = minimumX; gridX <= maximumX; gridX++) {
      const candidate = accepted(gridX, gridZ);
      if (
        !candidate ||
        (candidate.x - cameraX) ** 2 + (candidate.height - cameraY) ** 2 + (candidate.z - cameraZ) ** 2 >
          radius * radius ||
        candidate.priority >= densityMultiplier
      ) {
        continue;
      }
      if (rule.mode === "scatter") {
        let retained = true;
        for (let neighbourZ = gridZ - 2; neighbourZ <= gridZ + 2 && retained; neighbourZ++) {
          for (let neighbourX = gridX - 2; neighbourX <= gridX + 2; neighbourX++) {
            if (neighbourX === gridX && neighbourZ === gridZ) continue;
            const neighbour = accepted(neighbourX, neighbourZ);
            if (!neighbour) continue;
            const distanceSquared = (neighbour.x - candidate.x) ** 2 + (neighbour.z - candidate.z) ** 2;
            const minimumSpacing = rule.spacing * spacingScale;
            if (distanceSquared >= minimumSpacing * minimumSpacing) continue;
            if (
              neighbour.priority < candidate.priority ||
              (neighbour.priority === candidate.priority && neighbour.sourceId < candidate.sourceId)
            ) {
              retained = false;
              break;
            }
          }
        }
        if (!retained) continue;
      }
      output.push(candidate);
    }
  }
  return output;
}

function appendInstance(output: number[], rule: SurfaceWorldRule, candidate: WorldCandidate, seed: number): void {
  const yaw = mix(rule.yaw, unitHash(seed, rule.id, candidate.sourceId, 0, 5));
  const halfYaw = yaw * 0.5;
  const horizontalScale = mix(rule.scale.horizontal, unitHash(seed, rule.id, candidate.sourceId, 0, 6));
  const verticalScale = mix(rule.scale.vertical, unitHash(seed, rule.id, candidate.sourceId, 0, 7));
  output.push(
    candidate.x,
    0,
    candidate.z,
    candidate.priority,
    0,
    Math.sin(halfYaw),
    0,
    Math.cos(halfYaw),
    horizontalScale,
    verticalScale,
    horizontalScale,
    rule.category === "rock" || rule.category === "cliff"
      ? 0
      : unitHash(seed, rule.id, candidate.sourceId, 0, 8) * Math.PI * 2,
    1,
    1,
    1,
    candidate.biome
  );
}

function setWorldLodData(
  batch: WorldRuleBatch,
  data: readonly number[][],
  cameraPosition: Vector3,
  radius: number
): void {
  const extent = batch.prototypeRadius * batch.maxInstanceScale * SURFACE_RUNTIME_SCALE_MAX;
  const bounds = new BoundingBox(
    new Vector3(cameraPosition.x - radius - extent, batch.rule.height[0] - extent, cameraPosition.z - radius - extent),
    new Vector3(cameraPosition.x + radius + extent, batch.rule.height[1] + extent, cameraPosition.z + radius + extent)
  );
  for (const lod of batch.lods) {
    const source = data[lod.index] ?? [];
    const instanceCount = source.length / 16;
    if (source.length > 0) lod.buffer.setData(new Float32Array(source));
    for (const renderer of lod.renderers) {
      renderer.entity.isActive = instanceCount > 0;
      const mesh = renderer.mesh as BufferMesh;
      mesh.instanceCount = instanceCount;
      mesh.bounds = bounds;
    }
  }
}

function selectWorldLod(
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

function ecologyNoise(x: number, z: number, seed: number, spec: SurfaceWorldDistributionSpec["biomeNoise"]): number {
  let amplitude = 0;
  let weight = 1;
  let weightSum = 0;
  const cosine = Math.cos(spec.rotationRadians) * spec.lacunarity;
  const sine = Math.sin(spec.rotationRadians) * spec.lacunarity;
  for (let octave = 0; octave < spec.octaves; octave++) {
    amplitude += valueNoise(x, z, seed + octave * 0x9e3779b1) * weight;
    weightSum += weight;
    weight *= spec.persistence;
    const nextX = x * cosine + z * sine;
    z = z * cosine - x * sine;
    x = nextX;
  }
  return amplitude / weightSum;
}

function valueNoise(x: number, z: number, seed: number): number {
  const cellX = Math.floor(x);
  const cellZ = Math.floor(z);
  const fractionX = smoothCurve(x - cellX);
  const fractionZ = smoothCurve(z - cellZ);
  const lower = lerp(coordinateHash(seed, cellX, cellZ), coordinateHash(seed, cellX + 1, cellZ), fractionX);
  const upper = lerp(coordinateHash(seed, cellX, cellZ + 1), coordinateHash(seed, cellX + 1, cellZ + 1), fractionX);
  return lerp(lower, upper, fractionZ);
}

function intervalWeight(value: number, range: readonly [number, number], feather: number): number {
  const lower = smoothstep(range[0] - feather, range[0] + feather, value);
  const upper = 1 - smoothstep(range[1] - feather, range[1] + feather, value);
  return lower * upper;
}

function coordinateHash(seed: number, x: number, z: number): number {
  let value = (seed ^ Math.imul(x, 0x9e3779b1) ^ Math.imul(z, 0x85ebca77)) >>> 0;
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  value = Math.imul(value, 0x846ca68b);
  value ^= value >>> 16;
  return (value >>> 0) / 0x100000000;
}

function unitHash(seed: number, ruleId: string, x: number, z: number, channel: number): number {
  return hashCoordinates(seed, ruleId, x, z, channel) / 0x100000000;
}

function hashCoordinates(seed: number, ruleId: string, x: number, z: number, channel: number): number {
  let value =
    seed ^
    hashString(ruleId) ^
    Math.imul(x, 0x9e3779b1) ^
    Math.imul(z, 0x85ebca77) ^
    Math.imul(channel + 1, 0xc2b2ae3d);
  value >>>= 0;
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  value = Math.imul(value, 0x846ca68b);
  value ^= value >>> 16;
  return value >>> 0;
}

function hashString(value: string): number {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index++) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}

function smoothCurve(value: number): number {
  return value * value * (3 - 2 * value);
}

function smoothstep(edge0: number, edge1: number, value: number): number {
  if (edge0 === edge1) return value < edge0 ? 0 : 1;
  return smoothCurve(Math.min(1, Math.max(0, (value - edge0) / (edge1 - edge0))));
}

function lerp(left: number, right: number, amount: number): number {
  return left + (right - left) * amount;
}

function mix(range: readonly [number, number], amount: number): number {
  return lerp(range[0], range[1], amount);
}

function tuningSignature(tuning: SurfaceRuntimeTuning): string {
  return JSON.stringify({
    enabled: tuning.enabled,
    density: tuning.density,
    scale: tuning.scale,
    lod: tuning.lod,
    world: tuning.world
  });
}

function categoryRecord<T>(value: T): Record<SurfaceCategory, T> {
  return Object.fromEntries(SURFACE_CATEGORIES.map((category) => [category, value])) as Record<SurfaceCategory, T>;
}

function fingerprintUint32(hash: number, value: number): number {
  for (let byte = 0; byte < 4; byte++) {
    hash ^= (value >>> (byte * 8)) & 0xff;
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}
