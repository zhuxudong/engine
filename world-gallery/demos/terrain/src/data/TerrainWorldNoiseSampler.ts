import type { TerrainWorldNoiseSpec } from "../loader/ManifestLoader";
import type { TerrainWorldNoiseTuning } from "../TerrainMaterial";
import type { TerrainData } from "./TerrainData";

/** CPU reference sample for the procedural terrain continuation. */
export interface TerrainWorldNoiseSample {
  readonly height: number;
  /** One minus the up component of the finite-difference terrain normal. */
  readonly slope: number;
  /** Zero inside authored regions and one in the fully procedural world. */
  readonly backgroundWeight: number;
}

/** CPU mirror of the production shader world-height definition used by surface PCG constraints. */
export class TerrainWorldNoiseSampler {
  private readonly _data: TerrainData;
  private readonly _spec: MutableTerrainWorldNoiseSpec;

  /**
   * Creates a stable sampler over one terrain dataset and world-noise definition.
   * @param data Region lookup and terrain dimensional invariants.
   * @param spec World-noise parameters shared with the terrain and surface shaders.
   */
  constructor(data: TerrainData, spec: TerrainWorldNoiseSpec) {
    this._data = data;
    this._spec = { ...spec, offset: [...spec.offset] };
  }

  /**
   * Replaces live world-noise parameters so PCG constraints stay aligned with terrain rendering.
   * @param tuning Partial values accepted by TerrainMaterial.
   */
  setTuning(tuning: TerrainWorldNoiseTuning): void {
    const { offset, ...values } = tuning;
    Object.assign(this._spec, values);
    if (offset) this._spec.offset = [...offset];
  }

  /**
   * Samples background height and slope at a world-space coordinate.
   * @param worldX World-space X coordinate in metres.
   * @param worldZ World-space Z coordinate in metres.
   * @returns Procedural height, normalized slope and region-background weight.
   */
  sample(worldX: number, worldZ: number): TerrainWorldNoiseSample {
    const height = this._height(worldX, worldZ);
    const step = this._data.vertexSpacing;
    const derivativeX = (this._height(worldX + step, worldZ) - this._height(worldX - step, worldZ)) / (2 * step);
    const derivativeZ = (this._height(worldX, worldZ + step) - this._height(worldX, worldZ - step)) / (2 * step);
    const normalY = 1 / Math.hypot(derivativeX, 1, derivativeZ);
    return {
      height,
      slope: 1 - normalY,
      backgroundWeight: this._regionBlend(this._regionCoordinate(worldX, worldZ))
    };
  }

  private _height(worldX: number, worldZ: number): number {
    const regionCoordinate = this._regionCoordinate(worldX, worldZ);
    const backgroundWeight = this._regionBlend(regionCoordinate);
    if (backgroundWeight <= 1 - this._spec.regionBlend) return 0;
    const regionSize = this._data.regionSize;
    const noiseX =
      (((regionCoordinate[0] + (this._spec.offset[0] * 1024) / regionSize) * this._spec.scale * regionSize) / 1024) *
      0.1;
    const noiseZ =
      (((regionCoordinate[1] + (this._spec.offset[2] * 1024) / regionSize) * this._spec.scale * regionSize) / 1024) *
      0.1;
    const noiseHeight =
      morenoise(noiseX, noiseZ, this._spec.maxOctaves) * this._spec.height * 10 + this._spec.offset[1] * 100;
    const weight = smoothstep(1 - this._spec.regionBlend, 1, backgroundWeight);
    return noiseHeight * weight;
  }

  private _regionCoordinate(worldX: number, worldZ: number): readonly [number, number] {
    const texelSize = 1 / this._data.regionSize;
    const vertexDensity = 1 / this._data.vertexSpacing;
    return [worldX * vertexDensity * texelSize + 0.5 * texelSize, worldZ * vertexDensity * texelSize + 0.5 * texelSize];
  }

  private _regionBlend(regionCoordinate: readonly [number, number]): number {
    const x = regionCoordinate[0] - 0.5;
    const z = regionCoordinate[1] - 0.5;
    const a = this._regionPresent(Math.floor(x), Math.floor(z));
    const b = this._regionPresent(Math.floor(x), Math.floor(z + 1));
    const c = this._regionPresent(Math.floor(x + 1), Math.floor(z));
    const d = this._regionPresent(Math.floor(x + 1), Math.floor(z + 1));
    const weightX = smoothstep(0, 1, fract(x));
    const weightZ = smoothstep(0, 1, fract(z));
    const loaded = mix(mix(a, c, weightX), mix(b, d, weightX), weightZ);
    return 1 - loaded;
  }

  private _regionPresent(x: number, z: number): number {
    return this._data.getRegionLayer(x, z) >= 0 ? 1 : 0;
  }
}

type MutableTerrainWorldNoiseSpec = {
  -readonly [Key in keyof Omit<TerrainWorldNoiseSpec, "offset">]: TerrainWorldNoiseSpec[Key];
} & {
  offset: [x: number, y: number, z: number];
};

function morenoise(positionX: number, positionZ: number, octaves: number): number {
  let amplitude = 0;
  let weight = 1;
  let derivativeX = 0;
  let derivativeZ = 0;
  for (let index = 0; index < octaves; index++) {
    const noise = valueNoiseWithDerivative(positionX, positionZ);
    derivativeX += noise[1];
    derivativeZ += noise[2];
    amplitude += (weight * noise[0]) / (1 + derivativeX * derivativeX + derivativeZ * derivativeZ);
    weight *= 0.5;
    const nextX = (0.8 * positionX + 0.6 * positionZ) * 2;
    const nextZ = (-0.6 * positionX + 0.8 * positionZ) * 2;
    positionX = nextX;
    positionZ = nextZ;
  }
  return amplitude;
}

function valueNoiseWithDerivative(x: number, z: number): readonly [number, number, number] {
  const fractionalX = fract(x);
  const fractionalZ = fract(z);
  const squaredX = fractionalX * fractionalX;
  const squaredZ = fractionalZ * fractionalZ;
  const interpolationX = squaredX * fractionalX * (6 * squaredX + (-15 * fractionalX + 10));
  const interpolationZ = squaredZ * fractionalZ * (6 * squaredZ + (-15 * fractionalZ + 10));
  const derivativeX = 30 * squaredX * (fractionalX - 1) * (fractionalX - 1);
  const derivativeZ = 30 * squaredZ * (fractionalZ - 1) * (fractionalZ - 1);
  const cellX = Math.floor(x);
  const cellZ = Math.floor(z);
  const a = worldNoiseHash(cellX, cellZ);
  const b = worldNoiseHash(cellX + 1, cellZ);
  const c = worldNoiseHash(cellX, cellZ + 1);
  const d = worldNoiseHash(cellX + 1, cellZ + 1);
  const k1 = b - a;
  const k2 = c - a;
  const k3 = d - (b + k2);
  return [
    k2 * interpolationZ + interpolationX * (k3 * interpolationZ + k1) + a,
    derivativeX * (k3 * interpolationZ + k1),
    derivativeZ * (k3 * interpolationX + k2)
  ];
}

function worldNoiseHash(x: number, z: number): number {
  return fract(10000 * Math.sin(17 * x + z * 0.1) * (0.1 + Math.abs(Math.sin(z * 13 + x))));
}

function fract(value: number): number {
  return value - Math.floor(value);
}

function smoothstep(edge0: number, edge1: number, value: number): number {
  const amount = Math.min(1, Math.max(0, (value - edge0) / (edge1 - edge0)));
  return amount * amount * (3 - 2 * amount);
}

function mix(left: number, right: number, amount: number): number {
  return left + (right - left) * amount;
}
