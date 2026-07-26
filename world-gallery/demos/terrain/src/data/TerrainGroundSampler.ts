import type { TerrainBackgroundMode } from "../debug/TerrainDebugContract";
import type { TerrainWorldNoiseSpec } from "../loader/ManifestLoader";
import type { TerrainWorldNoiseTuning } from "../TerrainMaterial";
import type { TerrainData } from "./TerrainData";
import { TerrainWorldNoiseSampler } from "./TerrainWorldNoiseSampler";

/**
 * Resolves the CPU height represented by the active terrain background mode.
 * @remarks Region heights remain authored data; procedural height is the same additive continuation used by the shader.
 */
export class TerrainGroundSampler {
  private readonly _terrain: TerrainData;
  private readonly _worldNoise: TerrainWorldNoiseSampler;
  private _background: TerrainBackgroundMode;

  /**
   * Creates a ground sampler aligned with one terrain manifest.
   * @param terrain Loaded finite terrain regions.
   * @param background Initial terrain background mode.
   * @param worldNoise Procedural continuation parameters shared with the terrain shader.
   */
  constructor(terrain: TerrainData, background: TerrainBackgroundMode, worldNoise: TerrainWorldNoiseSpec) {
    this._terrain = terrain;
    this._background = background;
    this._worldNoise = new TerrainWorldNoiseSampler(terrain, worldNoise);
  }

  /**
   * Samples continuous terrain height for first-person ground contact.
   * @param worldX World-space X coordinate in metres.
   * @param worldZ World-space Z coordinate in metres.
   * @returns Active terrain height, or undefined where `None` mode has no loaded region.
   */
  sampleHeightInterpolated(worldX: number, worldZ: number): number | undefined {
    const authoredHeight = this._terrain.sampleHeightInterpolated(worldX, worldZ);
    if (this._background === "noise") {
      const proceduralHeight = this._worldNoise.sample(worldX, worldZ).height;
      return authoredHeight === undefined ? proceduralHeight : authoredHeight + proceduralHeight;
    }
    if (authoredHeight !== undefined) return authoredHeight;
    return this._background === "flat" ? 0 : undefined;
  }

  /**
   * Selects the CPU background-height behavior.
   * @param background `None`, flat zero-height continuation, or procedural noise.
   */
  setBackground(background: TerrainBackgroundMode): void {
    this._background = background;
  }

  /**
   * Applies live procedural-height tuning used by the terrain shader.
   * @param tuning Partial world-noise values.
   */
  setWorldNoiseTuning(tuning: TerrainWorldNoiseTuning): void {
    this._worldNoise.setTuning(tuning);
  }
}
