import {
  AssetType,
  BoundingBox,
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Engine,
  Entity,
  GLTFResource,
  IndexBufferBinding,
  IndexFormat,
  MeshRenderer,
  ModelMesh,
  Script,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import type { SurfaceCategory, SurfaceCellRange } from "./SurfaceContract";
import { loadSurfaceManifest } from "./SurfaceManifestLoader";
import { SurfaceMaterial } from "./SurfaceMaterial";
import type {
  SurfacePrototypeSpec,
  SurfaceRuntimeManifest,
  SurfaceRuntimeSnapshot,
  SurfaceRuntimeTuning,
  SurfaceRuntimeTuningUpdate
} from "./SurfaceRuntimeContract";

const INSTANCE_STRIDE = 64;
const CATEGORIES: readonly SurfaceCategory[] = ["grass", "flower", "shrub", "tree", "rock", "cliff"];
const indexBindings = new WeakMap<ModelMesh, IndexBufferBinding>();

interface SurfaceBatch {
  readonly range: SurfaceCellRange;
  readonly prototype: SurfacePrototypeSpec;
  readonly lods: readonly SurfaceLodBatch[];
  readonly centre: Vector3;
  readonly radius: number;
  activeLod: number;
}

interface SurfaceLodBatch {
  readonly index: number;
  readonly renderers: readonly MeshRenderer[];
  readonly height: number;
}

/**
 * Streams deterministic surface records into explicit instanced mesh batches.
 * Instances never allocate entities; only prototype, cell, LOD and renderer combinations do.
 */
export class SurfaceWorld {
  private readonly _manifest: SurfaceRuntimeManifest;
  private readonly _manifestUrl: string;
  private readonly _camera: Camera;
  private readonly _materials: readonly SurfaceMaterial[];
  private readonly _batches: readonly SurfaceBatch[];
  private readonly _categoryCounts: Record<SurfaceCategory, number>;
  private readonly _impostorInstances: number;
  private readonly _tuning: MutableSurfaceRuntimeTuning;
  private _time = 0;

  private constructor(
    manifest: SurfaceRuntimeManifest,
    manifestUrl: string,
    camera: Camera,
    materials: readonly SurfaceMaterial[],
    batches: readonly SurfaceBatch[],
    categoryCounts: Record<SurfaceCategory, number>,
    impostorInstances: number
  ) {
    this._manifest = manifest;
    this._manifestUrl = manifestUrl;
    this._camera = camera;
    this._materials = materials;
    this._batches = batches;
    this._categoryCounts = categoryCounts;
    this._impostorInstances = impostorInstances;
    this._tuning = {
      enabled: categoryRecord(true),
      density: categoryRecord(1),
      wind: {
        enabled: true,
        strength: 1,
        direction: [-0.788, 0, -0.615]
      },
      lod: {
        enabled: true,
        distanceScale: 1
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
  static async create(engine: Engine, root: Entity, camera: Camera, manifestUrl: string): Promise<SurfaceWorld> {
    const loaded = await loadSurfaceManifest(engine, manifestUrl);
    const materialList = await Promise.all(
      loaded.manifest.materials.map((spec) => SurfaceMaterial.create(engine, spec, manifestUrl))
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
      modelUrls.map(async (url) => [
        url,
        await engine.resourceManager.load<GLTFResource>({
          type: AssetType.GLTF,
          url,
          params: { keepMeshData: true }
        })
      ] as const)
    );
    const models = new Map(modelResources);
    const prototypes = new Map(loaded.manifest.prototypeLibrary.map((prototype) => [prototype.id, prototype]));
    const binary = new DataView(loaded.binary);
    const batches: SurfaceBatch[] = [];

    for (const range of loaded.manifest.ranges) {
      const prototype = prototypes.get(range.prototype)!;
      const decodedInstances = decodeInstanceRange(binary, range);
      const instanceBuffer = new Buffer(
        engine,
        BufferBindFlag.VertexBuffer,
        decodedInstances.data,
        BufferUsage.Static
      );
      const lods: SurfaceLodBatch[] = [];
      for (const lod of prototype.lods) {
        const renderers: MeshRenderer[] = [];
        let lodHeight = 1;
        for (let rendererIndex = 0; rendererIndex < lod.renderers.length; rendererIndex++) {
          const rendererSpec = lod.renderers[rendererIndex];
          const modelUrl = new URL(rendererSpec.model, manifestUrl).href;
          const sourceMesh = findModelMesh(models.get(modelUrl)!, rendererSpec.meshName);
          lodHeight = Math.max(lodHeight, sourceMesh.bounds.max.y - sourceMesh.bounds.min.y);
          const entity = root.createChild(
            `${range.prototype}-${range.cell[0]}-${range.cell[1]}-lod${lod.index}-renderer${rendererIndex}`
          );
          const renderer = entity.addComponent(MeshRenderer);
          renderer.mesh = createInstancedMesh(
            engine,
            sourceMesh,
            instanceBuffer,
            range,
            decodedInstances.maxScale
          );
          renderer.castShadows = rendererSpec.castShadows;
          renderer.receiveShadows = rendererSpec.receiveShadows;
          renderer.enableVertexColor = sourceMesh.vertexElements.some((element) => element.attribute === "COLOR_0");
          SurfaceMaterial.setRendererVertexColor(renderer.enableVertexColor, renderer.shaderData);
          for (let materialIndex = 0; materialIndex < sourceMesh.subMeshes.length; materialIndex++) {
            const materialId = rendererSpec.materials[Math.min(materialIndex, rendererSpec.materials.length - 1)];
            const material = materials.get(materialId);
            if (!material) throw new Error(`[SurfaceWorld] ${range.prototype} references unknown material ${materialId}`);
            renderer.setMaterial(materialIndex, material);
          }
          entity.isActive = lod.index === 0;
          renderers.push(renderer);
        }
        lods.push({ index: lod.index, renderers, height: lodHeight });
      }
      const bounds = range.bounds;
      const centre = new Vector3(
        (bounds[0] + bounds[3]) * 0.5,
        (bounds[1] + bounds[4]) * 0.5,
        (bounds[2] + bounds[5]) * 0.5
      );
      const radius =
        Math.hypot(bounds[3] - centre.x, bounds[4] - centre.y, bounds[5] - centre.z) +
        Math.max(...lods.map((lod) => lod.height)) * decodedInstances.maxScale;
      batches.push({ range, prototype, lods, centre, radius, activeLod: 0 });
    }

    const categoryCounts = categoryRecord(0);
    let impostorInstances = 0;
    for (const range of loaded.manifest.ranges) {
      categoryCounts[range.category] += range.count;
      if (prototypes.get(range.prototype)!.impostor) impostorInstances += range.count;
    }
    const world = new SurfaceWorld(
      loaded.manifest,
      loaded.manifestUrl,
      camera,
      materialList,
      batches,
      categoryCounts,
      impostorInstances
    );
    const follower = root.addComponent(SurfaceWorldFollower);
    follower.initialize(world);
    world.update(0);
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
    if (values.wind) Object.assign(this._tuning.wind, values.wind);
    if (values.lod) Object.assign(this._tuning.lod, values.lod);
    if (values.debugView) this._tuning.debugView = values.debugView;
    for (const material of this._materials) material.setDebugView(this._tuning.debugView === "normal" ? 1 : 0);
    this.update(0);
  }

  /**
   * Captures current compiled and visible instance counts.
   * @returns Stable diagnostics for GUI, E2E and performance capture.
   */
  inspect(): SurfaceRuntimeSnapshot {
    const visible = this._batches.filter((batch) => batch.activeLod >= 0);
    const lodCounts = new Array(
      Math.max(1, ...this._batches.map((batch) => batch.lods.length)),
    ).fill(0);
    let visibleInstances = 0;
    for (const batch of visible) {
      const count = Math.floor(batch.range.count * this._tuning.density[batch.range.category]);
      visibleInstances += count;
      if (batch.activeLod >= 0) lodCounts[batch.activeLod] += count;
    }
    return {
      totalInstances: this._manifest.binary.count,
      totalRanges: this._manifest.ranges.length,
      prototypes: this._manifest.prototypeLibrary.length,
      rendererBatches: this._batches.reduce(
        (count, batch) => count + batch.lods.reduce((lodCount, lod) => lodCount + lod.renderers.length, 0),
        0
      ),
      visibleRanges: visible.length,
      visibleInstances,
      lodCounts,
      categoryCounts: { ...this._categoryCounts },
      impostorInstances: this._impostorInstances,
      debugMasks: (this._manifest.debugMasks ?? []).map((mask) => ({
        id: mask.id,
        url: new URL(mask.url, this._manifestUrl).href
      })),
      sourceRules: (this._manifest.sourceRules ?? []).map((rule) => ({
        ...rule,
        scale: {
          horizontal: [...rule.scale.horizontal],
          vertical: [...rule.scale.vertical]
        },
        yaw: [...rule.yaw],
        constraints: {
          ...rule.constraints,
          height: [...rule.constraints.height],
          slope: [...rule.constraints.slope],
          terrainLayers: rule.constraints.terrainLayers ? [...rule.constraints.terrainLayers] : undefined
        }
      })),
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
    for (const batch of this._batches) {
      const categoryEnabled = this._tuning.enabled[batch.range.category];
      const density = this._tuning.density[batch.range.category];
      const distance = Vector3.distance(cameraPosition, batch.centre) - batch.radius;
      let selectedLod = -1;
      if (categoryEnabled && density > 0 && distance <= batch.prototype.maxDistance * this._tuning.lod.distanceScale) {
        selectedLod = this._tuning.lod.enabled
          ? selectLod(batch, Math.max(distance, 0.01), tangent, this._tuning.lod.distanceScale)
          : 0;
      }
      if (selectedLod !== batch.activeLod || density !== 1) {
        batch.activeLod = selectedLod;
        for (const lod of batch.lods) {
          const active = lod.index === selectedLod;
          for (const renderer of lod.renderers) {
            renderer.entity.isActive = active;
            (renderer.mesh as BufferMesh).instanceCount = active ? Math.floor(batch.range.count * density) : 0;
          }
        }
      }
    }
  }
}

interface MutableSurfaceRuntimeTuning {
  enabled: Record<SurfaceCategory, boolean>;
  density: Record<SurfaceCategory, number>;
  wind: {
    enabled: boolean;
    strength: number;
    direction: [number, number, number];
  };
  lod: {
    enabled: boolean;
    distanceScale: number;
  };
  debugView: "surface" | "normal";
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

function createInstancedMesh(
  engine: Engine,
  source: ModelMesh,
  instanceBuffer: Buffer,
  range: SurfaceCellRange,
  maxScale: number
): BufferMesh {
  const mesh = new BufferMesh(engine, `${source.name}-instances-${range.offset}`);
  source.vertexBufferBindings.forEach((binding, index) => mesh.setVertexBufferBinding(binding, index));
  const indexBufferBinding = getIndexBufferBinding(engine, source);
  if (indexBufferBinding) mesh.setIndexBufferBinding(indexBufferBinding);
  const bindingIndex = source.vertexBufferBindings.length;
  mesh.setVertexBufferBinding(instanceBuffer, INSTANCE_STRIDE, bindingIndex);
  mesh.setVertexElements([
    ...source.vertexElements,
    new VertexElement("INSTANCE_POSITION_HASH", 0, VertexElementFormat.Vector4, bindingIndex, 1),
    new VertexElement("INSTANCE_ROTATION", 16, VertexElementFormat.Vector4, bindingIndex, 1),
    new VertexElement("INSTANCE_SCALE_WIND", 32, VertexElementFormat.Vector4, bindingIndex, 1),
    new VertexElement("INSTANCE_COLOR", 48, VertexElementFormat.Vector4, bindingIndex, 1)
  ]);
  for (const subMesh of source.subMeshes) mesh.addSubMesh(subMesh.start, subMesh.count, subMesh.topology);
  const sourceRadius = Math.max(
    Math.abs(source.bounds.min.x),
    Math.abs(source.bounds.min.y),
    Math.abs(source.bounds.min.z),
    Math.abs(source.bounds.max.x),
    Math.abs(source.bounds.max.y),
    Math.abs(source.bounds.max.z)
  ) * maxScale;
  mesh.bounds = new BoundingBox(
    new Vector3(
      range.bounds[0] - sourceRadius,
      range.bounds[1] - sourceRadius,
      range.bounds[2] - sourceRadius
    ),
    new Vector3(
      range.bounds[3] + sourceRadius,
      range.bounds[4] + sourceRadius,
      range.bounds[5] + sourceRadius
    )
  );
  mesh.instanceCount = range.count;
  return mesh;
}

function getIndexBufferBinding(engine: Engine, source: ModelMesh): IndexBufferBinding | null {
  const cached = indexBindings.get(source);
  if (cached) return cached;
  const indices = source.getIndices();
  if (!indices) return null;
  const format =
    indices instanceof Uint8Array
      ? IndexFormat.UInt8
      : indices instanceof Uint16Array
        ? IndexFormat.UInt16
        : IndexFormat.UInt32;
  const binding = new IndexBufferBinding(
    new Buffer(engine, BufferBindFlag.IndexBuffer, indices, BufferUsage.Static),
    format
  );
  indexBindings.set(source, binding);
  return binding;
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
  return { data: output, maxScale };
}

function findModelMesh(resource: GLTFResource, meshName: string): ModelMesh {
  const meshes = resource.meshes?.flat() ?? [];
  const exact = meshes.find((mesh) => mesh.name === meshName);
  if (exact) return exact;
  const normalized = meshes.find((mesh) => mesh.name.replace(/\.\d{3}$/, "") === meshName);
  if (normalized) return normalized;
  throw new Error(`[SurfaceWorld] ${resource.url} does not contain mesh ${meshName}`);
}

function selectLod(batch: SurfaceBatch, distance: number, fovTangent: number, distanceScale: number): number {
  const projectedHeight = batch.lods[0].height / (2 * distance * fovTangent);
  for (const lod of batch.prototype.lods) {
    if (projectedHeight >= lod.screenRelativeHeight / distanceScale) return lod.index;
  }
  return batch.lods[batch.lods.length - 1].index;
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

function cloneTuning(tuning: MutableSurfaceRuntimeTuning): SurfaceRuntimeTuning {
  return {
    enabled: { ...tuning.enabled },
    density: { ...tuning.density },
    wind: { ...tuning.wind, direction: [...tuning.wind.direction] as [number, number, number] },
    lod: { ...tuning.lod },
    debugView: tuning.debugView
  };
}

function normalizeDirection(direction: readonly [number, number, number]): [number, number, number] {
  const length = Math.hypot(...direction);
  if (length < 0.000001) return [0, 0, 0];
  return [direction[0] / length, direction[1] / length, direction[2] / length];
}
