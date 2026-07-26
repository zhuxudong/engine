import type { TerrainData } from "../data/TerrainData";
import type { TerrainProbeSnapshot } from "./TerrainDebugContract";

/**
 * Decodes one packed terrain control word using the versioned control-map bit layout.
 * @param value Packed unsigned 32-bit control value.
 * @returns Stable browser-facing control fields.
 */
export function decodeTerrainControl(value: number): NonNullable<TerrainProbeSnapshot["control"]> {
  const raw = value >>> 0;
  const scaleIndex = (raw >>> 7) & 0x7;
  return {
    raw,
    base: (raw >>> 27) & 0x1f,
    overlay: (raw >>> 22) & 0x1f,
    blend: ((raw >>> 14) & 0xff) / 255,
    angleIndex: (raw >>> 10) & 0xf,
    scaleIndex,
    scale: 0.9 - (((scaleIndex + 3) % 8) + 1) * 0.1,
    hole: (raw & 0x4) !== 0,
    navigation: (raw & 0x2) !== 0,
    autoshader: (raw & 0x1) !== 0
  };
}

/**
 * Reads the retained CPU height/control payload at one world-space coordinate.
 * @param terrain Loaded terrain data whose CPU arrays mirror the bound GPU arrays.
 * @param worldX World-space X coordinate in metres.
 * @param worldZ World-space Z coordinate in metres.
 * @returns Raw source address, height, and decoded control fields when a region is present.
 */
export function createTerrainProbeSnapshot(terrain: TerrainData, worldX: number, worldZ: number): TerrainProbeSnapshot {
  const sample = terrain.resolveSample(worldX, worldZ);
  if (!sample) return { world: [worldX, worldZ] };

  const region = terrain.regions[sample.layer];
  const heightRaw = region.heights[sample.index];
  const rawControl = region.control[sample.index];
  return {
    world: [worldX, worldZ],
    heightRaw,
    height: terrain.decodeHeight(heightRaw),
    region: {
      layer: sample.layer,
      location: sample.regionLocation,
      texel: sample.texel,
      sourceIndex: sample.index
    },
    control: decodeTerrainControl(rawControl)
  };
}
