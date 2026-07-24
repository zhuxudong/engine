import { AssetType, Engine, JSONAsset } from "@galacean/engine";

/** Axis-aligned world-space area that can receive one surface prototype. */
export interface SurfaceAreaSpec {
  /** Inclusive minimum world X coordinate in metres. */
  minX: number;
  /** Inclusive maximum world X coordinate in metres. */
  maxX: number;
  /** Inclusive minimum world Z coordinate in metres. */
  minZ: number;
  /** Inclusive maximum world Z coordinate in metres. */
  maxZ: number;
}

/** Height and slope filters evaluated against the terrain control/height data. */
export interface SurfaceTerrainFilterSpec {
  /** Lowest accepted terrain height in metres. */
  minHeight: number;
  /** Highest accepted terrain height in metres. */
  maxHeight: number;
  /** Minimum accepted up-vector component. */
  minNormalY: number;
  /** Optional terrain control-map base texture IDs. */
  baseLayers?: number[];
  /** Optional terrain control-map overlay texture IDs. */
  overlayLayers?: number[];
  /**
   * Galacean surface-feature bits that must be present in the control word.
   * Bits 3 through 6 are intentionally reserved by the imported terrain control format.
   */
  featureBits?: number[];
}

/** One static glTF prototype placed by the terrain surface system. */
export interface SurfacePrototypeSpec {
  /** Stable identifier used by diagnostics and generated entity names. */
  id: string;
  /** glTF URL relative to this manifest. */
  asset: string;
  /** Source-space mesh bounds measured when importing the glTF. */
  localBounds: {
    /** Lowest local-space Y coordinate of the mesh. */
    minY: number;
    /** Highest local-space Y coordinate of the mesh. */
    maxY: number;
  };
  /** Deterministic candidate distribution. */
  distribution: {
    /** Candidate grid spacing in metres. */
    spacing: number;
    /** Fraction of each grid cell available to deterministic jitter. */
    jitter: number;
    /** Candidate acceptance probability after terrain filtering. */
    density: number;
    /** Uniform instance-scale range. */
    scale: [minimum: number, maximum: number];
    /** Extra world-space vertical offset after mesh-bottom grounding. */
    heightOffset: number;
    /** Stable hash seed. */
    seed: number;
    /** Area evaluated by this prototype. */
    area: SurfaceAreaSpec;
  };
  /** Terrain inputs that authorize an instance candidate. */
  terrain: SurfaceTerrainFilterSpec;
}

/** Complete portable input contract for the terrain surface system. */
export interface SurfaceManifest {
  /** Manifest schema version. */
  version: 1;
  /** Static glTF prototypes currently enabled in the demo. */
  prototypes: SurfacePrototypeSpec[];
}

/**
 * Loads and validates terrain surface placement inputs.
 * @param engine Engine whose resource manager owns the JSON asset.
 * @param url Absolute surface manifest URL.
 * @returns Validated static surface prototype definitions.
 * @throws If the manifest cannot be loaded or violates the surface data contract.
 */
export async function loadSurfaceManifest(engine: Engine, url: string): Promise<SurfaceManifest> {
  const asset = await engine.resourceManager.load<JSONAsset>({ url, type: AssetType.JSON });
  if (!(asset instanceof JSONAsset)) {
    throw new Error(`[SurfaceManifest] ${url} did not resolve to JSONAsset`);
  }
  const manifest = asset.data as SurfaceManifest;
  validateSurfaceManifest(manifest, url);
  return manifest;
}

function validateSurfaceManifest(manifest: SurfaceManifest, url: string): void {
  if (manifest.version !== 1) {
    throw new Error(`[SurfaceManifest] ${url} has unsupported version ${String(manifest.version)}`);
  }
  if (!Array.isArray(manifest.prototypes) || manifest.prototypes.length === 0) {
    throw new Error("[SurfaceManifest] prototypes must not be empty");
  }

  const ids = new Set<string>();
  for (const prototype of manifest.prototypes) {
    if (!prototype.id || ids.has(prototype.id)) {
      throw new Error("[SurfaceManifest] prototype ids must be non-empty and unique");
    }
    ids.add(prototype.id);
    if (!prototype.asset) {
      throw new Error(`[SurfaceManifest] ${prototype.id} must provide an asset URL`);
    }
    if (!(prototype.localBounds.maxY > prototype.localBounds.minY)) {
      throw new Error(`[SurfaceManifest] ${prototype.id} localBounds must be increasing`);
    }

    const { distribution, terrain } = prototype;
    if (!(distribution.spacing > 0) || !(distribution.jitter >= 0 && distribution.jitter <= 1) || !(distribution.density >= 0 && distribution.density <= 1)) {
      throw new Error(`[SurfaceManifest] ${prototype.id} distribution is invalid`);
    }
    if (!(distribution.scale[0] > 0) || !(distribution.scale[1] >= distribution.scale[0])) {
      throw new Error(`[SurfaceManifest] ${prototype.id} scale range is invalid`);
    }
    if (
      !(distribution.area.maxX > distribution.area.minX) ||
      !(distribution.area.maxZ > distribution.area.minZ) ||
      !(terrain.maxHeight >= terrain.minHeight) ||
      !(terrain.minNormalY >= -1 && terrain.minNormalY <= 1)
    ) {
      throw new Error(`[SurfaceManifest] ${prototype.id} terrain filter is invalid`);
    }
    validateLayerFilter(prototype.id, "baseLayers", terrain.baseLayers);
    validateLayerFilter(prototype.id, "overlayLayers", terrain.overlayLayers);
    validateFeatureBits(prototype.id, terrain.featureBits);
  }
}

function validateLayerFilter(id: string, name: string, values: number[] | undefined): void {
  if (values && values.some((value) => !Number.isInteger(value) || value < 0 || value > 31)) {
    throw new Error(`[SurfaceManifest] ${id} ${name} must contain texture IDs in 0..31`);
  }
}

function validateFeatureBits(id: string, bits: number[] | undefined): void {
  if (bits && bits.some((bit) => !Number.isInteger(bit) || bit < 3 || bit > 6)) {
    throw new Error(`[SurfaceManifest] ${id} featureBits must contain reserved control bits in 3..6`);
  }
}
