import type { SurfaceMask, SurfacePlacementConstraints, SurfaceTerrainSample } from "./SurfaceContract";

/** World-space mapping required to sample one grayscale density mask. */
export interface SurfaceMaskMapping {
  readonly width: number;
  readonly height: number;
  readonly pixels: Uint8Array;
  readonly origin: readonly [x: number, z: number];
  readonly size: readonly [width: number, depth: number];
}

/**
 * Returns the stable row-major id of one candidate lattice coordinate.
 * @param x Zero-based lattice X coordinate.
 * @param z Zero-based lattice Z coordinate.
 * @param width Complete lattice width.
 * @returns Unsigned deterministic source id.
 */
export function surfaceLatticeId(x: number, z: number, width: number): number {
  return (z * width + x) >>> 0;
}

/**
 * Generates the stable world-space candidate position shared by offline and streamed coverage.
 * @param seed Integer world seed.
 * @param ruleId Stable rule id.
 * @param sourceId Stable candidate lattice id.
 * @param origin World-space lower-left input origin.
 * @param step Candidate lattice spacing in metres.
 * @param gridX Candidate lattice X coordinate.
 * @param gridZ Candidate lattice Z coordinate.
 * @returns Jittered world-space XZ position.
 */
export function surfaceCandidatePosition(
  seed: number,
  ruleId: string,
  sourceId: number,
  origin: readonly [x: number, z: number],
  step: number,
  gridX: number,
  gridZ: number
): readonly [x: number, z: number] {
  return [
    origin[0] + (gridX + surfaceUnitHash(seed, ruleId, sourceId, 0)) * step,
    origin[1] + (gridZ + surfaceUnitHash(seed, ruleId, sourceId, 1)) * step
  ];
}

/**
 * Samples one mask with the nearest-texel convention shared by the compiler and runtime.
 * @param mask CPU grayscale pixels.
 * @param worldX World-space X coordinate.
 * @param worldZ World-space Z coordinate.
 * @returns Normalized density in `0..1`, or zero outside the mask.
 */
export function sampleSurfaceMask(mask: SurfaceMaskMapping, worldX: number, worldZ: number): number {
  const normalizedX = (worldX - mask.origin[0]) / mask.size[0];
  const normalizedZ = (worldZ - mask.origin[1]) / mask.size[1];
  if (normalizedX < 0 || normalizedX >= 1 || normalizedZ < 0 || normalizedZ >= 1) return 0;
  const x = Math.min(mask.width - 1, Math.floor(normalizedX * mask.width));
  const z = Math.min(mask.height - 1, Math.floor(normalizedZ * mask.height));
  return mask.pixels[z * mask.width + x] / 255;
}

/**
 * Applies the versioned height, slope, hole, and top-two terrain-layer constraints.
 * @param constraints Rule constraints.
 * @param terrain Sampled terrain values at the candidate position.
 * @returns Whether the candidate belongs to the distribution.
 */
export function passesSurfaceConstraints(
  constraints: SurfacePlacementConstraints,
  terrain: SurfaceTerrainSample
): boolean {
  if (constraints.excludeHoles && terrain.hole) return false;
  if (terrain.height < constraints.height[0] || terrain.height > constraints.height[1]) return false;
  if (terrain.slope < constraints.slope[0] || terrain.slope > constraints.slope[1]) return false;
  if (!constraints.terrainLayers || constraints.terrainLayers.length === 0) return true;
  const base = (terrain.control >>> 27) & 0x1f;
  const overlay = (terrain.control >>> 22) & 0x1f;
  const overlayWeight = ((terrain.control >>> 14) & 0xff) / 255;
  const selectedWeight =
    (constraints.terrainLayers.includes(base) ? 1 - overlayWeight : 0) +
    (overlay !== base && constraints.terrainLayers.includes(overlay) ? overlayWeight : 0);
  return selectedWeight >= constraints.minimumLayerWeight!;
}

/**
 * Returns a deterministic unit value for a rule, source id, and semantic channel.
 * @param seed Integer world seed.
 * @param ruleId Stable rule id.
 * @param sourceId Stable candidate id.
 * @param channel Independent semantic channel.
 * @returns Floating-point value in `[0, 1)`.
 */
export function surfaceUnitHash(seed: number, ruleId: string, sourceId: number, channel: number): number {
  return surfaceUintHash(seed, ruleId, sourceId, channel) / 0x100000000;
}

/**
 * Returns the deterministic unsigned hash used by placement conflict resolution.
 * @param seed Integer world seed.
 * @param ruleId Stable rule id.
 * @param sourceId Stable candidate id.
 * @param channel Independent semantic channel.
 * @returns Unsigned 32-bit hash.
 */
export function surfaceUintHash(seed: number, ruleId: string, sourceId: number, channel: number): number {
  let value =
    (seed ^ hashSurfaceString(ruleId) ^ Math.imul(sourceId + 1, 0x9e3779b1) ^ Math.imul(channel + 1, 0x85ebca6b)) >>> 0;
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  value = Math.imul(value, 0x846ca68b);
  value ^= value >>> 16;
  return value >>> 0;
}

/**
 * Derives the category-density priority stored in the GPU instance stream.
 * @param sourceId Stable candidate id.
 * @returns Floating-point value in `[0, 1)`.
 */
export function surfaceSourcePriority(sourceId: number): number {
  let value = sourceId;
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  value = Math.imul(value, 0x846ca68b);
  value ^= value >>> 16;
  return (value >>> 0) / 0x100000000;
}

/**
 * Produces the deterministic per-instance yaw, scale, and wind phase.
 * @param seed Integer world seed.
 * @param ruleId Stable rule id.
 * @param sourceId Stable candidate id.
 * @param yaw Inclusive yaw range.
 * @param horizontalScale Inclusive horizontal scale range.
 * @param verticalScale Inclusive vertical scale range.
 * @param wind Whether the prototype participates in wind.
 * @returns Transform variation shared by offline and streamed instances.
 */
export function surfaceInstanceVariation(
  seed: number,
  ruleId: string,
  sourceId: number,
  yaw: readonly [number, number],
  horizontalScale: readonly [number, number],
  verticalScale: readonly [number, number],
  wind: boolean
): {
  readonly rotation: readonly [number, number, number, number];
  readonly scale: readonly [number, number, number];
  readonly windPhase: number;
} {
  const angle = mixRange(yaw, surfaceUnitHash(seed, ruleId, sourceId, 2));
  const halfAngle = angle * 0.5;
  const horizontal = mixRange(horizontalScale, surfaceUnitHash(seed, ruleId, sourceId, 5));
  const vertical = mixRange(verticalScale, surfaceUnitHash(seed, ruleId, sourceId, 6));
  return {
    rotation: [0, Math.sin(halfAngle), 0, Math.cos(halfAngle)],
    scale: [horizontal, vertical, horizontal],
    windPhase: wind ? surfaceUnitHash(seed, ruleId, sourceId, 3) * Math.PI * 2 : 0
  };
}

/** @internal Adapts compiler masks to the shared world-space sampler. */
export function mapCompilerMask(
  mask: SurfaceMask,
  origin: readonly [x: number, z: number],
  size: readonly [width: number, depth: number]
): SurfaceMaskMapping {
  return { ...mask, origin, size };
}

function mixRange(range: readonly [number, number], amount: number): number {
  return range[0] + (range[1] - range[0]) * amount;
}

function hashSurfaceString(value: string): number {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index++) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}
