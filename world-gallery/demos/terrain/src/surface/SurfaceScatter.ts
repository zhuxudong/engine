import { TerrainSurfaceSampler } from "./TerrainSurfaceSampler";

/** Stable identifier of one surface prototype declared by the surface manifest. */
export type SurfacePrototypeId = string;

/** Axis-aligned world-space scatter extent. */
export interface SurfaceScatterArea {
  /** Minimum world-space X coordinate in metres. */
  readonly minX: number;
  /** Maximum world-space X coordinate in metres. */
  readonly maxX: number;
  /** Minimum world-space Z coordinate in metres. */
  readonly minZ: number;
  /** Maximum world-space Z coordinate in metres. */
  readonly maxZ: number;
}

/** Declarative placement rule for one instanced surface asset. */
export interface SurfaceScatterRule {
  /** Stable name used for diagnostics and entity names. */
  readonly name: string;
  /** Shared mesh resource instantiated for each accepted candidate. */
  readonly asset: SurfacePrototypeId;
  /** Candidate grid spacing in world metres. */
  readonly spacing: number;
  /** Fraction of one cell used for deterministic candidate jitter. */
  readonly jitter: number;
  /** Candidate acceptance chance after terrain filters. */
  readonly density: number;
  /** Surface normal Y must be at least this value. */
  readonly minNormalY: number;
  /** Inclusive minimum terrain height in metres. */
  readonly minHeight: number;
  /** Inclusive maximum terrain height in metres. */
  readonly maxHeight: number;
  /** Allowed raw control base IDs. Omit to accept every base texture. */
  readonly baseLayers?: readonly number[];
  /** Allowed raw control overlay IDs. Omit to accept every overlay texture. */
  readonly overlayLayers?: readonly number[];
  /** Reserved control-word feature bits that must all be present. */
  readonly featureBits?: readonly number[];
  /** Uniform instance-scale range. */
  readonly scale: readonly [minimum: number, maximum: number];
  /** Vertical offset from the sampled terrain surface in metres. */
  readonly heightOffset: number;
  /** Lowest local-space model coordinate used to ground the mesh on terrain. */
  readonly localMinY: number;
  /** Seed that keeps results independent of iteration order. */
  readonly seed: number;
  /** Area evaluated by this rule. */
  readonly area: SurfaceScatterArea;
}

/** Final deterministic transform accepted by one scatter rule. */
export interface SurfacePlacement {
  /** Asset category selected by the rule. */
  readonly asset: SurfacePrototypeId;
  /** Rule name used to form a stable entity name. */
  readonly rule: string;
  /** World-space position in metres. */
  readonly position: readonly [x: number, y: number, z: number];
  /** World-space Y rotation in degrees. */
  readonly rotationY: number;
  /** Uniform entity scale. */
  readonly scale: number;
  /** Sampled terrain height before local-mesh grounding. */
  readonly terrainHeight: number;
  /** Lowest local-space model coordinate used for grounding. */
  readonly localMinY: number;
  /** Source sparse region that supplied the terrain sample. */
  readonly region: readonly [x: number, z: number];
}

/**
 * Builds a stable, terrain-conforming placement list for one surface asset type.
 * @param sampler Height/control sampler for the active terrain dataset.
 * @param rule Candidate distribution and terrain acceptance rule.
 * @returns Accepted transforms in deterministic grid order.
 */
export function scatterSurface(sampler: TerrainSurfaceSampler, rule: SurfaceScatterRule): SurfacePlacement[] {
  const placements: SurfacePlacement[] = [];
  const { area, spacing } = rule;
  const startX = Math.ceil(area.minX / spacing);
  const endX = Math.floor(area.maxX / spacing);
  const startZ = Math.ceil(area.minZ / spacing);
  const endZ = Math.floor(area.maxZ / spacing);
  for (let gridZ = startZ; gridZ <= endZ; gridZ++) {
    for (let gridX = startX; gridX <= endX; gridX++) {
      const candidateSeed = hashCell(gridX, gridZ, rule.seed);
      if (candidateSeed > rule.density) continue;
      const jitterX = (hashCell(gridX, gridZ, rule.seed + 1) - 0.5) * spacing * rule.jitter;
      const jitterZ = (hashCell(gridX, gridZ, rule.seed + 2) - 0.5) * spacing * rule.jitter;
      const worldX = gridX * spacing + jitterX;
      const worldZ = gridZ * spacing + jitterZ;
      const sample = sampler.sample(worldX, worldZ);
      if (!sample || sample.hole || sample.normal[1] < rule.minNormalY) continue;
      if (sample.height < rule.minHeight || sample.height > rule.maxHeight) continue;
      if (rule.baseLayers && !rule.baseLayers.includes(sample.baseLayer)) continue;
      if (rule.overlayLayers && !rule.overlayLayers.includes(sample.overlayLayer)) continue;
      if (rule.featureBits && !rule.featureBits.every((bit) => (sample.surfaceFeatureMask & (1 << (bit - 3))) !== 0)) {
        continue;
      }
      const scaleT = hashCell(gridX, gridZ, rule.seed + 3);
      const scale = rule.scale[0] + (rule.scale[1] - rule.scale[0]) * scaleT;
      placements.push({
        asset: rule.asset,
        rule: rule.name,
        position: [worldX, sample.height - rule.localMinY * scale + rule.heightOffset, worldZ],
        rotationY: hashCell(gridX, gridZ, rule.seed + 4) * 360,
        scale,
        terrainHeight: sample.height,
        localMinY: rule.localMinY,
        region: sample.region
      });
    }
  }
  return placements;
}

function hashCell(gridX: number, gridZ: number, seed: number): number {
  let state = Math.imul(gridX, 0x1f123bb5) ^ Math.imul(gridZ, 0x5f356495) ^ Math.imul(seed, 0x45d9f3b);
  state = Math.imul(state ^ (state >>> 16), 0x45d9f3b);
  state = Math.imul(state ^ (state >>> 16), 0x45d9f3b);
  return ((state ^ (state >>> 16)) >>> 0) / 0x1_0000_0000;
}
