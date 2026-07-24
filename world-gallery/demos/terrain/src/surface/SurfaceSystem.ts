import { AssetType, Engine, Entity, GLTFResource } from "@galacean/engine";
import { TerrainData } from "../data/TerrainData";
import { loadSurfaceManifest, type SurfacePrototypeSpec } from "./SurfaceManifestLoader";
import { scatterSurface, type SurfacePlacement, type SurfaceScatterRule } from "./SurfaceScatter";
import { TerrainSurfaceSampler } from "./TerrainSurfaceSampler";

/** Eye-level camera pose derived from one grounded tree placement. */
export interface SurfaceFirstPersonPose {
  /** Camera world position at human eye height. */
  readonly position: readonly [x: number, y: number, z: number];
  /** Forward point used to orient the initial camera view. */
  readonly target: readonly [x: number, y: number, z: number];
}

/** Observable state for the terrain demo's surface-system inspector group. */
export interface SurfaceSystemSnapshot {
  /** Whether all generated surface instances are visible. */
  readonly enabled: boolean;
  /** Number of accepted placements by surface prototype. */
  readonly counts: Readonly<Record<string, number>>;
  /** Representative terrain-conforming placements retained for runtime diagnostics. */
  readonly samples: Readonly<Record<string, readonly SurfacePlacement[]>>;
  /** Total generated placement count. */
  readonly instanceCount: number;
  /** Rendering path used by all loaded static glTF prototypes. */
  readonly instancing: "engine-auto";
  /** Placement criteria by prototype, exposed without engine objects. */
  readonly rules: Readonly<Record<string, SurfaceRuleSnapshot>>;
}

/** Declarative placement inputs retained for the terrain surface inspector. */
export interface SurfaceRuleSnapshot {
  /** Candidate grid spacing in metres. */
  readonly spacing: number;
  /** Candidate acceptance probability after terrain filtering. */
  readonly density: number;
  /** Required Galacean surface-feature bits. */
  readonly featureBits: readonly number[];
  /** Required terrain overlay texture IDs. */
  readonly overlayLayers: readonly number[];
  /** Inclusive terrain-height range in metres. */
  readonly heightRange: readonly [minimum: number, maximum: number];
  /** Minimum accepted terrain normal Y component. */
  readonly minNormalY: number;
  /** Uniform instance-scale range. */
  readonly scale: readonly [minimum: number, maximum: number];
}

/** Inputs required to build terrain-conforming surface instances. */
export interface SurfaceSystemOptions {
  /** Engine used to load shared glTF resources. */
  readonly engine: Engine;
  /** Parent entity that owns generated meshes. */
  readonly parent: Entity;
  /** Sparse terrain dataset queried by surface filters. */
  readonly terrain: TerrainData;
  /** Absolute URL of the static surface manifest. */
  readonly manifestUrl: string;
}

/**
 * Loads static glTF prototypes and instantiates deterministic terrain-conforming placements.
 * Identical static glTF mesh/material pairs are submitted through the engine's automatic GPU-instancing path.
 */
export class SurfaceSystem {
  readonly root: Entity;

  private readonly _content: Entity;
  private readonly _counts: Record<string, number> = {};
  private readonly _samples: Record<string, SurfacePlacement[]> = {};
  private readonly _rules: Record<string, SurfaceRuleSnapshot> = {};
  private readonly _placements: SurfacePlacement[] = [];
  private _enabled = true;

  private constructor(parent: Entity) {
    this.root = parent.createChild("surface-system");
    this._content = this.root.createChild("instances");
  }

  /**
   * Loads the configured tree prototypes and generates their initial terrain-derived placement set.
   * @param options Runtime dependencies and the surface-data contract.
   * @returns Ready surface system with shared static glTF resources and grounded instances.
   */
  static async create(options: SurfaceSystemOptions): Promise<SurfaceSystem> {
    const system = new SurfaceSystem(options.parent);
    const manifest = await loadSurfaceManifest(options.engine, options.manifestUrl);
    const resources = await loadSurfaceResources(options.engine, options.manifestUrl, manifest.prototypes);
    const sampler = new TerrainSurfaceSampler(options.terrain);

    for (const prototype of manifest.prototypes) {
      const rule = toScatterRule(prototype);
      const placements = scatterSurface(sampler, rule);
      system._counts[prototype.id] = 0;
      system._samples[prototype.id] = placements.slice(0, SURFACE_DIAGNOSTIC_SAMPLE_COUNT);
      system._rules[prototype.id] = snapshotRule(rule);
      system._placements.push(...placements);
      system._createInstances(resources.get(prototype.id)!, placements);
    }
    return system;
  }

  /**
   * Shows or hides generated instances without destroying their deterministic placement data.
   * @param enabled Whether terrain surface instances are rendered.
   */
  setEnabled(enabled: boolean): void {
    this._enabled = enabled;
    this._content.isActive = enabled;
  }

  /**
   * Returns an eye-level pose located beside a deterministic generated tree.
   * @returns A stable scene pose, or undefined when the manifest has no accepted placements.
   */
  getFirstPersonPose(): SurfaceFirstPersonPose | undefined {
    const placement = this._placements[Math.floor(this._placements.length * 0.5)];
    if (!placement) return undefined;
    const angle = (placement.rotationY + 180) * (Math.PI / 180);
    const distance = 8;
    const [x, , z] = placement.position;
    return {
      position: [x + Math.sin(angle) * distance, placement.terrainHeight + 1.7, z + Math.cos(angle) * distance],
      target: [x, placement.terrainHeight + Math.min(3, (placement.scale * 2) / 3), z]
    };
  }

  /**
   * Returns generated placement diagnostics without exposing engine renderer objects.
   * @returns Current surface-system state.
   */
  inspect(): SurfaceSystemSnapshot {
    return {
      enabled: this._enabled,
      counts: { ...this._counts },
      samples: Object.fromEntries(Object.entries(this._samples).map(([id, samples]) => [id, [...samples]])),
      instanceCount: this._placements.length,
      instancing: "engine-auto",
      rules: Object.fromEntries(Object.entries(this._rules).map(([id, rule]) => [id, { ...rule }]))
    };
  }

  private _createInstances(resource: GLTFResource, placements: readonly SurfacePlacement[]): void {
    for (const placement of placements) {
      const entity = resource.instantiateSceneRoot();
      const instanceIndex = this._counts[placement.asset]++;
      entity.name = `${placement.rule}-${instanceIndex}`;
      this._content.addChild(entity);
      entity.transform.setPosition(...placement.position);
      entity.transform.setRotation(0, placement.rotationY, 0);
      entity.transform.setScale(placement.scale, placement.scale, placement.scale);
    }
  }
}

const SURFACE_DIAGNOSTIC_SAMPLE_COUNT = 6;

function toScatterRule(prototype: SurfacePrototypeSpec): SurfaceScatterRule {
  const { distribution, terrain } = prototype;
  return {
    name: prototype.id,
    asset: prototype.id,
    spacing: distribution.spacing,
    jitter: distribution.jitter,
    density: distribution.density,
    minNormalY: terrain.minNormalY,
    minHeight: terrain.minHeight,
    maxHeight: terrain.maxHeight,
    baseLayers: terrain.baseLayers,
    overlayLayers: terrain.overlayLayers,
    featureBits: terrain.featureBits,
    scale: distribution.scale,
    heightOffset: distribution.heightOffset,
    localMinY: prototype.localBounds.minY,
    seed: distribution.seed,
    area: distribution.area
  };
}

function snapshotRule(rule: SurfaceScatterRule): SurfaceRuleSnapshot {
  return {
    spacing: rule.spacing,
    density: rule.density,
    featureBits: [...(rule.featureBits ?? [])],
    overlayLayers: [...(rule.overlayLayers ?? [])],
    heightRange: [rule.minHeight, rule.maxHeight],
    minNormalY: rule.minNormalY,
    scale: [rule.scale[0], rule.scale[1]]
  };
}

async function loadSurfaceResources(
  engine: Engine,
  manifestUrl: string,
  prototypes: readonly SurfacePrototypeSpec[]
): Promise<Map<string, GLTFResource>> {
  const entries = await Promise.all(
    prototypes.map(async (prototype) => {
      const resource = await engine.resourceManager.load<GLTFResource>({
        url: new URL(prototype.asset, manifestUrl).href,
        type: AssetType.GLTF
      });
      return [prototype.id, resource] as const;
    })
  );
  return new Map(entries);
}
