import { TerrainData } from "../data/TerrainData";

/** Decoded terrain inputs used to accept or reject one surface-system candidate. */
export interface TerrainSurfaceSample {
  /** Terrain height in world metres. */
  readonly height: number;
  /** Unit-length terrain normal reconstructed from the exported height field. */
  readonly normal: readonly [x: number, y: number, z: number];
  /** Base texture identifier from the raw terrain control word. */
  readonly baseLayer: number;
  /** Overlay texture identifier from the raw terrain control word. */
  readonly overlayLayer: number;
  /** Four-bit surface classification decoded from reserved control-word bits 3 through 6. */
  readonly surfaceFeatureMask: number;
  /** Whether the candidate belongs to an authored terrain hole. */
  readonly hole: boolean;
  /** Stable sparse-region coordinate that owns the sample. */
  readonly region: readonly [x: number, z: number];
}

/**
 * Reads terrain's CPU height and control payloads without coupling scatter rules to raw bit layout.
 * @param terrain Sparse terrain dataset used by the production clipmap.
 */
export class TerrainSurfaceSampler {
  private readonly _spacing: number;

  constructor(private readonly _terrain: TerrainData) {
    this._spacing = this._terrain.vertexSpacing;
  }

  /**
   * Samples a position and its immediate height-field neighbourhood.
   * @param worldX World-space X coordinate in metres.
   * @param worldZ World-space Z coordinate in metres.
   * @returns Surface inputs, or undefined when any required texel is outside loaded regions.
   */
  sample(worldX: number, worldZ: number): TerrainSurfaceSample | undefined {
    const height = this._terrain.sampleHeight(worldX, worldZ);
    const control = this._terrain.sampleControl(worldX, worldZ);
    const spacing = this._spacing;
    const left = this._terrain.sampleHeight(worldX - spacing, worldZ);
    const right = this._terrain.sampleHeight(worldX + spacing, worldZ);
    const back = this._terrain.sampleHeight(worldX, worldZ - spacing);
    const forward = this._terrain.sampleHeight(worldX, worldZ + spacing);
    if (
      height === undefined ||
      control === undefined ||
      left === undefined ||
      right === undefined ||
      back === undefined ||
      forward === undefined
    ) {
      return undefined;
    }

    const normalX = left - right;
    const normalY = spacing * 2;
    const normalZ = back - forward;
    const inverseLength = 1 / Math.hypot(normalX, normalY, normalZ);
    const raw = control >>> 0;
    const gridX = Math.round(worldX / spacing);
    const gridZ = Math.round(worldZ / spacing);
    return {
      height,
      normal: [normalX * inverseLength, normalY * inverseLength, normalZ * inverseLength],
      baseLayer: (raw >>> 27) & 0x1f,
      overlayLayer: (raw >>> 22) & 0x1f,
      surfaceFeatureMask: (raw >>> 3) & 0xf,
      hole: (raw & 0x4) !== 0,
      region: [Math.floor(gridX / this._terrain.regionSize), Math.floor(gridZ / this._terrain.regionSize)]
    };
  }
}
