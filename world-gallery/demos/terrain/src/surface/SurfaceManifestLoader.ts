import { AssetType, Engine, JSONAsset } from "@galacean/engine";
import type { SurfaceRuntimeManifest } from "./SurfaceRuntimeContract";

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
  if (prototypes.size !== manifest.prototypes.length || prototypes.size !== manifest.prototypeLibrary.length) {
    throw new Error("[SurfaceManifest] prototype ids and library must be unique and complete");
  }
  for (const prototype of manifest.prototypeLibrary) {
    if (!prototypes.has(prototype.id) || prototype.lods.length === 0 || !(prototype.maxDistance > 0)) {
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
      (
        material.kind !== "vegetation" &&
        material.kind !== "pbr" &&
        material.kind !== "impostor"
      ) ||
      (material.metallic ?? 0) < 0 ||
      (material.metallic ?? 0) > 1 ||
      material.roughness < 0 ||
      material.roughness > 1 ||
      (material.occlusionStrength ?? 1) < 0 ||
      (material.occlusionStrength ?? 1) > 1 ||
      material.colorVariation.mode !== "world-noise-2d" &&
      material.colorVariation.mode !== "world-noise-3d" &&
      material.colorVariation.mode !== "vertex-gradient" &&
      material.colorVariation.mode !== "uv-gradient"
    ) {
      throw new Error(`[SurfaceManifest] invalid color variation mode in ${material.id}`);
    }
    if (
      coverage &&
      (
        !coverage.albedo ||
        !coverage.normal ||
        !(coverage.tiling > 0) ||
        coverage.normalScale < 0 ||
        coverage.metallic < 0 ||
        coverage.metallic > 1 ||
        coverage.roughness < 0 ||
        coverage.roughness > 1 ||
        (
          coverage.smoothnessSource !== "albedo-alpha" &&
          coverage.smoothnessSource !== "metallic-alpha"
        ) ||
        (
          coverage.overlayMethod !== "perturbed-normal" &&
          coverage.overlayMethod !== "vertex-normal"
        ) ||
        !Number.isFinite(coverage.offset) ||
        !Number.isFinite(coverage.balance) ||
        coverage.maskContrast < 0 ||
        coverage.maskContrast > 1 ||
        coverage.normalBlending < 0 ||
        coverage.normalBlending > 1 ||
        coverage.maskTiling.some((value) => !(value > 0))
      )
    ) {
      throw new Error(`[SurfaceManifest] invalid triplanar coverage in ${material.id}`);
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
