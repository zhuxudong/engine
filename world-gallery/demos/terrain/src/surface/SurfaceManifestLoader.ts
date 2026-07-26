import { AssetType, Engine, JSONAsset } from "@galacean/engine";
import {
  SURFACE_RUNTIME_SCALE_MAX,
  SURFACE_RUNTIME_SCALE_MIN,
  type SurfaceRuntimeManifest
} from "./SurfaceRuntimeContract";

/** Loaded and validated surface manifest with its exact binary payload. */
export interface LoadedSurfaceManifest {
  readonly manifest: SurfaceRuntimeManifest;
  readonly manifestUrl: string;
  readonly binary: ArrayBuffer;
}

/**
 * Loads and validates a compiled surface runtime bundle.
 * @param engine Engine whose resource manager owns the JSON asset.
 * @param manifestUrl Absolute URL of `surface-manifest.json`.
 * @returns Validated manifest and matching binary instance payload.
 * @throws If versions, counts, ranges, prototypes, or the payload checksum are invalid.
 */
export async function loadSurfaceManifest(engine: Engine, manifestUrl: string): Promise<LoadedSurfaceManifest> {
  const asset = await engine.resourceManager.load<JSONAsset>({ url: manifestUrl, type: AssetType.JSON });
  if (!(asset instanceof JSONAsset)) throw new Error(`[SurfaceManifest] ${manifestUrl} did not resolve to JSONAsset`);
  const manifest = asset.data as SurfaceRuntimeManifest;
  validateManifest(manifest);

  const response = await fetch(new URL(manifest.binary.url, manifestUrl));
  if (!response.ok) throw new Error(`[SurfaceManifest] ${response.url} returned ${response.status}`);
  const binary = await response.arrayBuffer();
  validateBinary(binary, manifest);
  return { manifest, manifestUrl, binary };
}

function validateManifest(manifest: SurfaceRuntimeManifest): void {
  if (manifest.version !== "1") throw new Error(`[SurfaceManifest] unsupported version ${String(manifest.version)}`);
  if (manifest.binary.format !== "surface-instances-v1-le" || manifest.binary.stride !== 56) {
    throw new Error("[SurfaceManifest] binary must use surface-instances-v1-le stride 56");
  }
  if (!Number.isInteger(manifest.binary.count) || manifest.binary.count < 0) {
    throw new Error("[SurfaceManifest] binary count must be a non-negative integer");
  }
  if (!manifest.lodDitherTexture || !(manifest.lodCrossfadeDuration > 0)) {
    throw new Error("[SurfaceManifest] LOD dither texture and positive crossfade duration are required");
  }
  const prototypes = new Set(manifest.prototypes);
  const libraryPrototypes = new Set(manifest.prototypeLibrary.map((prototype) => prototype.id));
  if (
    prototypes.size !== manifest.prototypes.length ||
    libraryPrototypes.size !== manifest.prototypeLibrary.length ||
    Array.from(prototypes).some((prototype) => !libraryPrototypes.has(prototype))
  ) {
    throw new Error("[SurfaceManifest] binary prototype ids must resolve to a unique runtime prototype");
  }
  for (const prototype of manifest.prototypeLibrary) {
    if (prototype.lods.length === 0 || !(prototype.maxDistance > 0)) {
      throw new Error(`[SurfaceManifest] invalid prototype ${prototype.id}`);
    }
    for (const lod of prototype.lods) {
      if (lod.index < 0 || lod.renderers.length === 0 || !Number.isFinite(lod.screenRelativeHeight)) {
        throw new Error(`[SurfaceManifest] invalid LOD ${lod.index} in ${prototype.id}`);
      }
    }
  }
  for (const material of manifest.materials) {
    const coverage = material.coverage;
    if (
      (material.kind !== "vegetation" && material.kind !== "pbr" && material.kind !== "impostor") ||
      (material.metallic ?? 0) < 0 ||
      (material.metallic ?? 0) > 1 ||
      material.roughness < 0 ||
      material.roughness > 1 ||
      (material.occlusionStrength ?? 1) < 0 ||
      (material.occlusionStrength ?? 1) > 1 ||
      (material.colorVariation.mode !== "world-noise-2d" &&
        material.colorVariation.mode !== "world-noise-3d" &&
        material.colorVariation.mode !== "vertex-gradient" &&
        material.colorVariation.mode !== "uv-gradient")
    ) {
      throw new Error(`[SurfaceManifest] invalid color variation mode in ${material.id}`);
    }
    if (
      coverage &&
      (!coverage.albedo ||
        !coverage.normal ||
        !(coverage.tiling > 0) ||
        coverage.normalScale < 0 ||
        coverage.metallic < 0 ||
        coverage.metallic > 1 ||
        coverage.roughness < 0 ||
        coverage.roughness > 1 ||
        (coverage.smoothnessSource !== "albedo-alpha" && coverage.smoothnessSource !== "metallic-alpha") ||
        (coverage.overlayMethod !== "perturbed-normal" && coverage.overlayMethod !== "vertex-normal") ||
        !Number.isFinite(coverage.offset) ||
        !Number.isFinite(coverage.balance) ||
        coverage.maskContrast < 0 ||
        coverage.maskContrast > 1 ||
        coverage.normalBlending < 0 ||
        coverage.normalBlending > 1 ||
        coverage.maskTiling.some((value) => !(value > 0)))
    ) {
      throw new Error(`[SurfaceManifest] invalid triplanar coverage in ${material.id}`);
    }
  }
  for (const [category, color] of Object.entries(manifest.runtimeDefaults?.color ?? {})) {
    if (
      !validCategory(category) ||
      !Array.isArray(color) ||
      color.length !== 3 ||
      color.some((value) => !Number.isFinite(value) || value < 0 || value > 2)
    ) {
      throw new Error(`[SurfaceManifest] invalid runtime color default for ${category}`);
    }
  }
  for (const [category, scale] of Object.entries(manifest.runtimeDefaults?.scale ?? {})) {
    if (
      !validCategory(category) ||
      !Number.isFinite(scale) ||
      scale < SURFACE_RUNTIME_SCALE_MIN ||
      scale > SURFACE_RUNTIME_SCALE_MAX
    ) {
      throw new Error(`[SurfaceManifest] invalid runtime scale default for ${category}`);
    }
  }
  const coverage = manifest.coverageStreaming;
  if (coverage) {
    const sourceRules = new Map((manifest.sourceRules ?? []).map((rule) => [rule.id, rule]));
    const masks = new Set((manifest.debugMasks ?? []).map((mask) => mask.id));
    const ruleIds = new Set(coverage.ruleIds);
    if (
      typeof coverage.enabled !== "boolean" ||
      !(coverage.cellSize > 0) ||
      !(coverage.rebuildDistance > 0) ||
      ruleIds.size !== coverage.ruleIds.length ||
      coverage.ruleIds.length === 0
    ) {
      throw new Error("[SurfaceManifest] finite coverage streaming requires unique rules and positive distances");
    }
    for (const ruleId of coverage.ruleIds) {
      const rule = sourceRules.get(ruleId);
      if (!rule || rule.mode !== "coverage" || !masks.has(rule.mask) || !libraryPrototypes.has(rule.prototype)) {
        throw new Error(`[SurfaceManifest] invalid finite coverage rule ${ruleId}`);
      }
    }
  }
  for (const mask of manifest.debugMasks ?? []) {
    if (
      !mask.id ||
      !mask.url ||
      mask.origin.length !== 2 ||
      mask.size.length !== 2 ||
      mask.origin.some((value) => !Number.isFinite(value)) ||
      mask.size.some((value) => !(value > 0))
    ) {
      throw new Error(`[SurfaceManifest] invalid debug mask ${mask.id}`);
    }
  }
  const world = manifest.worldDistribution;
  if (world) {
    if (
      typeof world.enabled !== "boolean" ||
      !Number.isInteger(world.seed) ||
      !Number.isFinite(world.rebuildDistance) ||
      !(world.rebuildDistance > 0) ||
      !Number.isInteger(world.biomeNoise?.octaves) ||
      world.biomeNoise.octaves < 1 ||
      world.biomeNoise.octaves > 8 ||
      !Number.isFinite(world.biomeNoise.lacunarity) ||
      !(world.biomeNoise.lacunarity > 1) ||
      !Number.isFinite(world.biomeNoise.persistence) ||
      !(world.biomeNoise.persistence > 0 && world.biomeNoise.persistence < 1) ||
      !Number.isFinite(world.biomeNoise.rotationRadians) ||
      !Array.isArray(world.rules) ||
      world.rules.length === 0
    ) {
      throw new Error("[SurfaceManifest] world distribution requires seed, rebuild distance, biome noise, and rules");
    }
    const worldRuleIds = new Set<string>();
    for (const rule of world.rules) {
      const prototype = manifest.prototypeLibrary.find((candidate) => candidate.id === rule.prototype);
      if (
        !rule.id ||
        worldRuleIds.has(rule.id) ||
        !prototype ||
        rule.category !== prototype.category ||
        (rule.mode !== "coverage" && rule.mode !== "scatter") ||
        !Number.isFinite(rule.densityPerSquareMetre) ||
        !(rule.densityPerSquareMetre > 0) ||
        !Number.isFinite(rule.spacing) ||
        !(rule.spacing > 0) ||
        !validIncreasingRange(rule.scale?.horizontal, 0) ||
        !validIncreasingRange(rule.scale?.vertical, 0) ||
        !validIncreasingRange(rule.yaw) ||
        !validIncreasingRange(rule.height) ||
        !validIncreasingRange(rule.slope, 0, 1) ||
        !Number.isFinite(rule.biomeScale) ||
        !(rule.biomeScale > 0) ||
        !validIncreasingRange(rule.biomeRange, 0, 1) ||
        !Number.isFinite(rule.biomeFeather) ||
        !Array.isArray(rule.biomeOffset) ||
        rule.biomeOffset.length !== 2 ||
        rule.biomeOffset.some((value: number) => !Number.isFinite(value)) ||
        !Number.isFinite(rule.cellSize) ||
        !(rule.cellSize > 0) ||
        rule.biomeFeather < 0 ||
        rule.biomeFeather > 0.5 ||
        !Number.isInteger(rule.maxInstances) ||
        rule.maxInstances <= 0
      ) {
        throw new Error(`[SurfaceManifest] invalid world distribution rule ${rule.id}`);
      }
      worldRuleIds.add(rule.id);
    }
  }
  let expectedOffset = 0;
  for (const range of manifest.ranges) {
    if (
      !prototypes.has(range.prototype) ||
      range.offset !== expectedOffset ||
      !Number.isInteger(range.count) ||
      range.count <= 0 ||
      range.bounds.length !== 6 ||
      range.bounds.some((value) => !Number.isFinite(value))
    ) {
      throw new Error(`[SurfaceManifest] invalid range at offset ${range.offset}`);
    }
    expectedOffset += range.count;
  }
  if (expectedOffset !== manifest.binary.count) {
    throw new Error(`[SurfaceManifest] ranges cover ${expectedOffset} records, expected ${manifest.binary.count}`);
  }
}

function validCategory(value: string): boolean {
  return (
    value === "grass" ||
    value === "flower" ||
    value === "shrub" ||
    value === "tree" ||
    value === "rock" ||
    value === "cliff"
  );
}

function validIncreasingRange(
  range: readonly number[] | undefined,
  minimum = Number.NEGATIVE_INFINITY,
  maximum = Number.POSITIVE_INFINITY
): boolean {
  return (
    Array.isArray(range) &&
    range.length === 2 &&
    range.every(Number.isFinite) &&
    range[0] >= minimum &&
    range[1] <= maximum &&
    range[0] <= range[1]
  );
}

function validateBinary(binary: ArrayBuffer, manifest: SurfaceRuntimeManifest): void {
  const bytes = new Uint8Array(binary);
  const expectedLength = 16 + manifest.binary.count * manifest.binary.stride;
  if (bytes.byteLength !== expectedLength) {
    throw new Error(`[SurfaceManifest] binary has ${bytes.byteLength} bytes, expected ${expectedLength}`);
  }
  if (String.fromCharCode(...bytes.subarray(0, 4)) !== "SFW1") {
    throw new Error("[SurfaceManifest] binary magic must be SFW1");
  }
  const view = new DataView(binary);
  if (view.getUint16(4, true) !== 1 || view.getUint16(6, true) !== manifest.binary.stride) {
    throw new Error("[SurfaceManifest] binary header version or stride does not match manifest");
  }
  if (view.getUint32(8, true) !== manifest.binary.count) {
    throw new Error("[SurfaceManifest] binary header count does not match manifest");
  }
  let checksum = 0x811c9dc5;
  for (let index = 16; index < bytes.length; index++) {
    checksum ^= bytes[index];
    checksum = Math.imul(checksum, 0x01000193);
  }
  checksum >>>= 0;
  if (view.getUint32(12, true) !== checksum || manifest.binary.checksum !== checksum) {
    throw new Error("[SurfaceManifest] binary checksum does not match manifest");
  }
}
