import type { TerrainData } from "../data/TerrainData";
import type { TerrainControlFixtureSnapshot } from "./TerrainDebugContract";
import { createTerrainProbeSnapshot } from "./TerrainProbe";

// The plateau keeps every clipmap morph endpoint contributing to the probe inside one encoded case.
const CASE_PLATEAU_SIZE = 32;
const PATCH_ORIGIN = 96;

const CASES = [
  {
    id: "blend-0",
    heightRaw: 8_192,
    control: encodeControl(3, 5, 0, 2, 1, 0)
  },
  {
    id: "blend-128-navigation",
    heightRaw: 24_576,
    control: encodeControl(7, 11, 128, 5, 3, 0x2)
  },
  {
    id: "blend-255-autoshader",
    heightRaw: 40_960,
    control: encodeControl(13, 17, 255, 9, 6, 0x1)
  },
  {
    id: "hole",
    heightRaw: 57_344,
    control: encodeControl(19, 23, 64, 12, 7, 0x4)
  }
] as const;

/**
 * Applies an atomic packed-control fixture to the first region's CPU arrays and bound GPU texture arrays.
 * @param terrain Loaded terrain data to patch after normal source loading.
 * @returns Fixed world-space probes for each encoded branch.
 * @throws If the loaded region is too small to contain the fixture.
 */
export function applyTerrainControlFixture(terrain: TerrainData): TerrainControlFixtureSnapshot {
  const patchWidth = CASES.length * CASE_PLATEAU_SIZE;
  const patchHeight = CASE_PLATEAU_SIZE;
  if (terrain.regionSize < PATCH_ORIGIN + patchWidth || terrain.regionSize < PATCH_ORIGIN + patchHeight) {
    throw new Error(`[TerrainControlFixture] region size ${terrain.regionSize} cannot contain the atomic fixture`);
  }

  const layer = 0;
  const region = terrain.regions[layer];
  const heightPixels = new Float32Array(patchWidth * patchHeight * 4);
  const controlPixels = new Uint8Array(patchWidth * patchHeight * 4);

  for (let caseIndex = 0; caseIndex < CASES.length; caseIndex++) {
    const fixtureCase = CASES[caseIndex];
    const height = terrain.decodeHeight(fixtureCase.heightRaw);
    for (let localZ = 0; localZ < CASE_PLATEAU_SIZE; localZ++) {
      for (let blockX = 0; blockX < CASE_PLATEAU_SIZE; blockX++) {
        const patchX = caseIndex * CASE_PLATEAU_SIZE + blockX;
        const patchIndex = localZ * patchWidth + patchX;
        const sourceX = PATCH_ORIGIN + patchX;
        const sourceZ = PATCH_ORIGIN + localZ;
        const sourceIndex = sourceZ * terrain.regionSize + sourceX;

        region.heights[sourceIndex] = fixtureCase.heightRaw;
        region.control[sourceIndex] = fixtureCase.control;

        const pixelOffset = patchIndex * 4;
        heightPixels[pixelOffset] = height;
        controlPixels[pixelOffset] = fixtureCase.control & 0xff;
        controlPixels[pixelOffset + 1] = (fixtureCase.control >>> 8) & 0xff;
        controlPixels[pixelOffset + 2] = (fixtureCase.control >>> 16) & 0xff;
        controlPixels[pixelOffset + 3] = fixtureCase.control >>> 24;
      }
    }
  }

  terrain.heightMaps.setPixelBuffer(layer, heightPixels, 0, PATCH_ORIGIN, PATCH_ORIGIN, patchWidth, patchHeight, 1);
  terrain.controlMaps.setPixelBuffer(layer, controlPixels, 0, PATCH_ORIGIN, PATCH_ORIGIN, patchWidth, patchHeight, 1);

  const [regionX, regionZ] = region.location;
  return {
    layer,
    cases: CASES.map((fixtureCase, caseIndex) => {
      const gridX = regionX * terrain.regionSize + PATCH_ORIGIN + caseIndex * CASE_PLATEAU_SIZE + 1.25;
      const gridZ = regionZ * terrain.regionSize + PATCH_ORIGIN + 1.25;
      return {
        id: fixtureCase.id,
        probe: createTerrainProbeSnapshot(terrain, gridX * terrain.vertexSpacing, gridZ * terrain.vertexSpacing)
      };
    })
  };
}

function encodeControl(
  base: number,
  overlay: number,
  blend: number,
  angle: number,
  scale: number,
  flags: number
): number {
  return (
    (((base & 0x1f) << 27) |
      ((overlay & 0x1f) << 22) |
      ((blend & 0xff) << 14) |
      ((angle & 0xf) << 10) |
      ((scale & 0x7) << 7) |
      (flags & 0x7)) >>>
    0
  );
}
