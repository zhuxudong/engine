import type {
  CompiledSurfaceManifest,
  SurfaceCategory,
  SurfaceCompileInput,
  SurfaceCompileResult,
  SurfaceExplicitPlacement,
  SurfaceInstance,
  SurfaceMask,
  SurfaceRule,
  SurfaceTerrainSample
} from "./SurfaceContract";

const BINARY_HEADER_SIZE = 16;
const BINARY_RECORD_SIZE = 56;
const TWO_PI = Math.PI * 2;

const CATEGORY_IDS: Readonly<Record<SurfaceCategory, number>> = {
  grass: 0,
  flower: 1,
  shrub: 2,
  tree: 3,
  rock: 4,
  cliff: 5
};

/**
 * Compiles masks, terrain constraints and explicit placements into stable runtime records.
 * @param input Versioned source data and terrain sampler.
 * @param binaryUrl URL written into the generated runtime manifest.
 * @returns Deterministically ordered instances, manifest and little-endian binary payload.
 * @throws If the contract is invalid or references an unknown mask.
 */
export function compileSurface(input: SurfaceCompileInput, binaryUrl = "./surface-instances.bin"): SurfaceCompileResult {
  validateInput(input);
  const masks = new Map(input.masks.map((mask) => [mask.id, mask]));
  const generated: SurfaceInstance[] = [];

  for (const rule of input.rules) {
    const mask = masks.get(rule.mask);
    if (!mask) throw new Error(`[SurfaceCompiler] rule ${rule.id} references unknown mask ${rule.mask}`);
    if (rule.mode === "coverage") {
      compileCoverage(input, rule, mask, generated);
    } else {
      compileScatter(input, rule, mask, generated);
    }
  }
  for (const placement of input.explicitPlacements) generated.push(explicitInstance(placement));

  const prototypes = Array.from(new Set(generated.map((instance) => instance.prototype))).sort();
  const prototypeIndex = new Map(prototypes.map((prototype, index) => [prototype, index]));
  generated.sort((left, right) => compareInstances(left, right, prototypeIndex));

  const ranges = buildRanges(generated);
  const binary = encodeInstances(generated, prototypeIndex);
  const checksum = readUint32(binary, 12);
  const manifest: CompiledSurfaceManifest = {
    version: "1",
    seed: input.seed >>> 0,
    binary: {
      url: binaryUrl,
      format: "surface-instances-v1-le",
      stride: BINARY_RECORD_SIZE,
      count: generated.length,
      checksum
    },
    prototypes,
    ranges
  };
  return { manifest, instances: generated, binary };
}

function compileCoverage(input: SurfaceCompileInput, rule: SurfaceRule, mask: SurfaceMask, output: SurfaceInstance[]): void {
  const step = Math.sqrt(1 / rule.densityPerSquareMetre);
  const countX = Math.ceil(input.size[0] / step);
  const countZ = Math.ceil(input.size[1] / step);
  for (let gridZ = 0; gridZ < countZ; gridZ++) {
    for (let gridX = 0; gridX < countX; gridX++) {
      const sourceId = latticeId(gridX, gridZ, countX);
      const candidate = candidateAt(input, rule, gridX, gridZ, step, sourceId);
      const probability = sampleMask(mask, input, candidate.x, candidate.z);
      if (unitHash(input.seed, rule.id, sourceId, 4) >= probability) continue;
      const terrain = input.terrain.sample(candidate.x, candidate.z);
      if (!terrain || !passesConstraints(rule, terrain)) continue;
      output.push(instanceFor(rule, sourceId, candidate.x, candidate.z, terrain.height, input.seed));
    }
  }
}

function compileScatter(input: SurfaceCompileInput, rule: SurfaceRule, mask: SurfaceMask, output: SurfaceInstance[]): void {
  const step = rule.spacing / Math.SQRT2;
  const countX = Math.ceil(input.size[0] / step);
  const countZ = Math.ceil(input.size[1] / step);
  const radius = Math.ceil(rule.spacing / step);

  for (let gridZ = 0; gridZ < countZ; gridZ++) {
    for (let gridX = 0; gridX < countX; gridX++) {
      const sourceId = latticeId(gridX, gridZ, countX);
      const candidate = validScatterCandidate(input, rule, mask, gridX, gridZ, countX, countZ, step);
      if (!candidate) continue;

      let retained = true;
      for (let neighbourZ = Math.max(0, gridZ - radius); neighbourZ <= Math.min(countZ - 1, gridZ + radius) && retained; neighbourZ++) {
        for (let neighbourX = Math.max(0, gridX - radius); neighbourX <= Math.min(countX - 1, gridX + radius); neighbourX++) {
          if (neighbourX === gridX && neighbourZ === gridZ) continue;
          const neighbourId = latticeId(neighbourX, neighbourZ, countX);
          const neighbour = validScatterCandidate(input, rule, mask, neighbourX, neighbourZ, countX, countZ, step);
          if (!neighbour) continue;
          const dx = neighbour.x - candidate.x;
          const dz = neighbour.z - candidate.z;
          if (dx * dx + dz * dz >= rule.spacing * rule.spacing) continue;
          const candidatePriority = uintHash(input.seed, rule.id, sourceId, 9);
          const neighbourPriority = uintHash(input.seed, rule.id, neighbourId, 9);
          if (neighbourPriority < candidatePriority || (neighbourPriority === candidatePriority && neighbourId < sourceId)) {
            retained = false;
            break;
          }
        }
      }
      if (retained) {
        output.push(instanceFor(rule, sourceId, candidate.x, candidate.z, candidate.terrain.height, input.seed));
      }
    }
  }
}

function validScatterCandidate(
  input: SurfaceCompileInput,
  rule: SurfaceRule,
  mask: SurfaceMask,
  gridX: number,
  gridZ: number,
  countX: number,
  countZ: number,
  step: number
): { x: number; z: number; terrain: SurfaceTerrainSample } | undefined {
  if (gridX < 0 || gridX >= countX || gridZ < 0 || gridZ >= countZ) return undefined;
  const sourceId = latticeId(gridX, gridZ, countX);
  const candidate = candidateAt(input, rule, gridX, gridZ, step, sourceId);
  const maskDensity = sampleMask(mask, input, candidate.x, candidate.z);
  const cellArea = step * step;
  const probability = Math.min(1, maskDensity * rule.densityPerSquareMetre * cellArea);
  if (unitHash(input.seed, rule.id, sourceId, 4) >= probability) return undefined;
  const terrain = input.terrain.sample(candidate.x, candidate.z);
  if (!terrain || !passesConstraints(rule, terrain)) return undefined;
  return { ...candidate, terrain };
}

function candidateAt(
  input: SurfaceCompileInput,
  rule: SurfaceRule,
  gridX: number,
  gridZ: number,
  step: number,
  sourceId: number
): { x: number; z: number } {
  const jitterX = unitHash(input.seed, rule.id, sourceId, 0);
  const jitterZ = unitHash(input.seed, rule.id, sourceId, 1);
  return {
    x: input.origin[0] + (gridX + jitterX) * step,
    z: input.origin[1] + (gridZ + jitterZ) * step
  };
}

function passesConstraints(rule: SurfaceRule, terrain: SurfaceTerrainSample): boolean {
  const { constraints } = rule;
  if (constraints.excludeHoles && terrain.hole) return false;
  if (terrain.height < constraints.height[0] || terrain.height > constraints.height[1]) return false;
  if (terrain.slope < constraints.slope[0] || terrain.slope > constraints.slope[1]) return false;
  if (!constraints.terrainLayers || constraints.terrainLayers.length === 0) return true;
  const base = (terrain.control >>> 27) & 0x1f;
  const overlay = (terrain.control >>> 22) & 0x1f;
  return constraints.terrainLayers.includes(base) || constraints.terrainLayers.includes(overlay);
}

function sampleMask(mask: SurfaceMask, input: SurfaceCompileInput, worldX: number, worldZ: number): number {
  const normalizedX = (worldX - input.origin[0]) / input.size[0];
  const normalizedZ = (worldZ - input.origin[1]) / input.size[1];
  if (normalizedX < 0 || normalizedX >= 1 || normalizedZ < 0 || normalizedZ >= 1) return 0;
  const x = Math.min(mask.width - 1, Math.floor(normalizedX * mask.width));
  const z = Math.min(mask.height - 1, Math.floor(normalizedZ * mask.height));
  return mask.pixels[z * mask.width + x] / 255;
}

function instanceFor(
  rule: SurfaceRule,
  sourceId: number,
  x: number,
  z: number,
  height: number,
  seed: number
): SurfaceInstance {
  const scaleHorizontal = mix(rule.scale.horizontal, unitHash(seed, rule.id, sourceId, 5));
  const scaleVertical = mix(rule.scale.vertical, unitHash(seed, rule.id, sourceId, 6));
  return {
    prototype: rule.prototype,
    category: rule.category,
    position: [x, height, z],
    rotation: quaternionFromYaw(mix(rule.yaw, unitHash(seed, rule.id, sourceId, 2))),
    scale: [scaleHorizontal, scaleVertical, scaleHorizontal],
    windPhase: rule.wind ? unitHash(seed, rule.id, sourceId, 3) * TWO_PI : 0,
    color: 0xffffffff,
    sourceId,
    cell: [Math.floor(x / rule.cellSize), Math.floor(z / rule.cellSize)]
  };
}

function explicitInstance(placement: SurfaceExplicitPlacement): SurfaceInstance {
  return {
    prototype: placement.prototype,
    category: placement.category,
    position: placement.position,
    rotation: placement.rotation,
    scale: placement.scale,
    windPhase: placement.windPhase ?? 0,
    color: packColor(placement.color),
    sourceId: placement.id >>> 0,
    cell: [
      Math.floor(placement.position[0] / placement.cellSize),
      Math.floor(placement.position[2] / placement.cellSize)
    ]
  };
}

function buildRanges(instances: readonly SurfaceInstance[]): CompiledSurfaceManifest["ranges"] {
  const ranges: Array<CompiledSurfaceManifest["ranges"][number]> = [];
  for (let offset = 0; offset < instances.length; ) {
    const first = instances[offset];
    let end = offset + 1;
    while (
      end < instances.length &&
      instances[end].prototype === first.prototype &&
      instances[end].category === first.category &&
      instances[end].cell[0] === first.cell[0] &&
      instances[end].cell[1] === first.cell[1]
    ) {
      end++;
    }
    ranges.push({
      prototype: first.prototype,
      category: first.category,
      cell: first.cell,
      bounds: rangeBounds(instances, offset, end),
      offset,
      count: end - offset
    });
    offset = end;
  }
  return ranges;
}

function rangeBounds(instances: readonly SurfaceInstance[], start: number, end: number): SurfaceCellRangeBounds {
  let minX = Number.POSITIVE_INFINITY;
  let minY = Number.POSITIVE_INFINITY;
  let minZ = Number.POSITIVE_INFINITY;
  let maxX = Number.NEGATIVE_INFINITY;
  let maxY = Number.NEGATIVE_INFINITY;
  let maxZ = Number.NEGATIVE_INFINITY;
  for (let index = start; index < end; index++) {
    const instance = instances[index];
    const radius = Math.max(instance.scale[0], instance.scale[1], instance.scale[2]);
    minX = Math.min(minX, instance.position[0] - radius);
    minY = Math.min(minY, instance.position[1] - radius);
    minZ = Math.min(minZ, instance.position[2] - radius);
    maxX = Math.max(maxX, instance.position[0] + radius);
    maxY = Math.max(maxY, instance.position[1] + radius);
    maxZ = Math.max(maxZ, instance.position[2] + radius);
  }
  return [minX, minY, minZ, maxX, maxY, maxZ];
}

type SurfaceCellRangeBounds = readonly [
  minX: number,
  minY: number,
  minZ: number,
  maxX: number,
  maxY: number,
  maxZ: number
];

function encodeInstances(instances: readonly SurfaceInstance[], prototypes: ReadonlyMap<string, number>): Uint8Array {
  const bytes = new Uint8Array(BINARY_HEADER_SIZE + instances.length * BINARY_RECORD_SIZE);
  const view = new DataView(bytes.buffer);
  bytes.set([0x53, 0x46, 0x57, 0x31], 0);
  view.setUint16(4, 1, true);
  view.setUint16(6, BINARY_RECORD_SIZE, true);
  view.setUint32(8, instances.length, true);
  for (let index = 0; index < instances.length; index++) {
    const instance = instances[index];
    const offset = BINARY_HEADER_SIZE + index * BINARY_RECORD_SIZE;
    view.setUint16(offset, prototypes.get(instance.prototype)!, true);
    view.setUint8(offset + 2, CATEGORY_IDS[instance.category]);
    view.setUint8(offset + 3, instance.windPhase === 0 ? 0 : 1);
    view.setFloat32(offset + 4, instance.position[0], true);
    view.setFloat32(offset + 8, instance.position[1], true);
    view.setFloat32(offset + 12, instance.position[2], true);
    view.setFloat32(offset + 16, instance.rotation[0], true);
    view.setFloat32(offset + 20, instance.rotation[1], true);
    view.setFloat32(offset + 24, instance.rotation[2], true);
    view.setFloat32(offset + 28, instance.rotation[3], true);
    view.setFloat32(offset + 32, instance.scale[0], true);
    view.setFloat32(offset + 36, instance.scale[1], true);
    view.setFloat32(offset + 40, instance.scale[2], true);
    view.setFloat32(offset + 44, instance.windPhase, true);
    view.setUint32(offset + 48, instance.color, true);
    view.setUint32(offset + 52, instance.sourceId, true);
  }
  view.setUint32(12, fnv1a(bytes.subarray(BINARY_HEADER_SIZE)), true);
  return bytes;
}

function compareInstances(left: SurfaceInstance, right: SurfaceInstance, prototypes: ReadonlyMap<string, number>): number {
  return (
    prototypes.get(left.prototype)! - prototypes.get(right.prototype)! ||
    left.cell[1] - right.cell[1] ||
    left.cell[0] - right.cell[0] ||
    left.sourceId - right.sourceId ||
    left.position[2] - right.position[2] ||
    left.position[0] - right.position[0]
  );
}

function latticeId(x: number, z: number, width: number): number {
  return (z * width + x) >>> 0;
}

function mix(range: readonly [number, number], amount: number): number {
  return range[0] + (range[1] - range[0]) * amount;
}

function quaternionFromYaw(yaw: number): readonly [number, number, number, number] {
  const halfYaw = yaw * 0.5;
  return [0, Math.sin(halfYaw), 0, Math.cos(halfYaw)];
}

function packColor(color: readonly [number, number, number, number]): number {
  return (
    Math.round(clamp01(color[0]) * 255) |
    (Math.round(clamp01(color[1]) * 255) << 8) |
    (Math.round(clamp01(color[2]) * 255) << 16) |
    (Math.round(clamp01(color[3]) * 255) << 24)
  ) >>> 0;
}

function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value));
}

function unitHash(seed: number, ruleId: string, sourceId: number, channel: number): number {
  return uintHash(seed, ruleId, sourceId, channel) / 0x100000000;
}

function uintHash(seed: number, ruleId: string, sourceId: number, channel: number): number {
  let value = (seed ^ hashString(ruleId) ^ Math.imul(sourceId + 1, 0x9e3779b1) ^ Math.imul(channel + 1, 0x85ebca6b)) >>> 0;
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

function fnv1a(bytes: Uint8Array): number {
  let hash = 0x811c9dc5;
  for (const byte of bytes) {
    hash ^= byte;
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}

function readUint32(bytes: Uint8Array, offset: number): number {
  return new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength).getUint32(offset, true);
}

function validateInput(input: SurfaceCompileInput): void {
  if (input.version !== "1") throw new Error(`[SurfaceCompiler] unsupported version ${String(input.version)}`);
  if (!Number.isInteger(input.seed)) throw new Error("[SurfaceCompiler] seed must be an integer");
  if (!(input.size[0] > 0 && input.size[1] > 0)) throw new Error("[SurfaceCompiler] size must be positive");
  const maskIds = new Set<string>();
  for (const mask of input.masks) {
    if (!mask.id || maskIds.has(mask.id)) throw new Error(`[SurfaceCompiler] duplicate or empty mask id ${mask.id}`);
    if (!Number.isInteger(mask.width) || !Number.isInteger(mask.height) || mask.width <= 0 || mask.height <= 0) {
      throw new Error(`[SurfaceCompiler] mask ${mask.id} dimensions must be positive integers`);
    }
    if (mask.pixels.length !== mask.width * mask.height) {
      throw new Error(`[SurfaceCompiler] mask ${mask.id} has ${mask.pixels.length} pixels, expected ${mask.width * mask.height}`);
    }
    maskIds.add(mask.id);
  }
  const ruleIds = new Set<string>();
  for (const rule of input.rules) {
    if (!rule.id || ruleIds.has(rule.id)) throw new Error(`[SurfaceCompiler] duplicate or empty rule id ${rule.id}`);
    if (!(rule.densityPerSquareMetre > 0)) throw new Error(`[SurfaceCompiler] rule ${rule.id} density must be positive`);
    if (!(rule.spacing > 0) || !(rule.cellSize > 0)) throw new Error(`[SurfaceCompiler] rule ${rule.id} spacing and cellSize must be positive`);
    if (rule.scale.horizontal[0] <= 0 || rule.scale.vertical[0] <= 0) {
      throw new Error(`[SurfaceCompiler] rule ${rule.id} scale minima must be positive`);
    }
    ruleIds.add(rule.id);
  }
}
