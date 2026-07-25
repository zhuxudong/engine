import type {
  TerrainMaterialTuning,
  TerrainWorldNoiseTuning
} from "../TerrainMaterial";
import type { TerrainManifest } from "../loader/ManifestLoader";
import type {
  TerrainBackgroundMode,
  TerrainDebugTuningSnapshot,
  TerrainMaterialTuningSnapshot
} from "./TerrainDebugContract";

/**
 * Creates the mutable diagnostics state represented by a terrain manifest.
 * @param manifest Loaded terrain manifest.
 * @returns A deep copy suitable for runtime tuning.
 */
export function createTerrainDebugTuning(manifest: TerrainManifest): TerrainDebugTuningSnapshot {
  return {
    layers: manifest.layers.map((layer) => ({
      layer: layer.id,
      uvScale: layer.uvScale,
      detilingRotation: layer.detilingRotation,
      detilingShift: layer.detilingShift,
      normalDepth: layer.normalDepth,
      aoStrength: layer.aoStrength,
      roughnessMod: layer.roughnessMod
    })),
    sampling: { ...manifest.material.sampling },
    material: {
      autoShader: { ...manifest.material.autoShader },
      projection: { ...manifest.material.projection },
      dualScaling: { ...manifest.material.dualScaling },
      macroVariation: {
        ...manifest.material.macroVariation,
        color1: [...manifest.material.macroVariation.color1],
        color2: [...manifest.material.macroVariation.color2],
        noise1Offset: [...manifest.material.macroVariation.noise1Offset]
      }
    },
    world: {
      background: manifest.world.background,
      noise: { ...manifest.world.noise, offset: [...manifest.world.noise.offset] }
    }
  };
}

/**
 * Clones terrain diagnostics state without sharing nested arrays.
 * @param snapshot Source diagnostics state.
 * @returns Independent mutable copy.
 */
export function cloneTerrainDebugTuning(
  snapshot: TerrainDebugTuningSnapshot
): TerrainDebugTuningSnapshot {
  return {
    layers: snapshot.layers.map((layer) => ({ ...layer })),
    sampling: { ...snapshot.sampling },
    material: {
      autoShader: { ...snapshot.material.autoShader },
      projection: { ...snapshot.material.projection },
      dualScaling: { ...snapshot.material.dualScaling },
      macroVariation: {
        ...snapshot.material.macroVariation,
        color1: [...snapshot.material.macroVariation.color1],
        color2: [...snapshot.material.macroVariation.color2],
        noise1Offset: [...snapshot.material.macroVariation.noise1Offset]
      }
    },
    world: {
      background: snapshot.world.background,
      noise: { ...snapshot.world.noise, offset: [...snapshot.world.noise.offset] }
    }
  };
}

/**
 * Replaces all mutable terrain diagnostics state.
 * @param target State to mutate.
 * @param source Replacement values.
 */
export function replaceTerrainDebugTuning(
  target: TerrainDebugTuningSnapshot,
  source: TerrainDebugTuningSnapshot
): void {
  target.layers.splice(0, target.layers.length, ...source.layers.map((layer) => ({ ...layer })));
  Object.assign(target.sampling, source.sampling);
  replaceTerrainMaterialTuning(target.material, source.material);
  target.world.background = source.world.background;
  replaceTerrainWorldNoiseTuning(target.world.noise, source.world.noise);
}

/**
 * Applies a partial material update to the diagnostics snapshot.
 * @param target Material state to mutate.
 * @param source Partial material values.
 */
export function replaceTerrainMaterialTuning(
  target: TerrainMaterialTuningSnapshot,
  source: TerrainMaterialTuning
): void {
  if (source.autoShader) Object.assign(target.autoShader, source.autoShader);
  if (source.projection) Object.assign(target.projection, source.projection);
  if (source.dualScaling) Object.assign(target.dualScaling, source.dualScaling);
  if (source.macroVariation) {
    const macro = source.macroVariation;
    Object.assign(target.macroVariation, macro);
    if (macro.color1) target.macroVariation.color1 = [...macro.color1];
    if (macro.color2) target.macroVariation.color2 = [...macro.color2];
    if (macro.noise1Offset) target.macroVariation.noise1Offset = [...macro.noise1Offset];
  }
}

/**
 * Applies a partial world-noise update to the diagnostics snapshot.
 * @param target World-noise state to mutate.
 * @param source Partial world-noise values.
 */
export function replaceTerrainWorldNoiseTuning(
  target: Required<TerrainWorldNoiseTuning>,
  source: TerrainWorldNoiseTuning
): void {
  Object.assign(target, source);
  if (source.offset) target.offset = [...source.offset];
}

/**
 * Maps the portable background mode to the terrain shader enum.
 * @param mode Portable background mode.
 * @returns Terrain shader enum value.
 */
export function terrainBackgroundModeToShader(mode: TerrainBackgroundMode): 0 | 1 | 2 {
  if (mode === "flat") return 1;
  if (mode === "noise") return 2;
  return 0;
}
