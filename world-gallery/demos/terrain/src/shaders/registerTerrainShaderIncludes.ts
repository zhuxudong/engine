import { ShaderFactory } from "@galacean/engine-core";
import grasslandsCloudShadowSource from "./Terrain/GrasslandsCloudShadow.glsl?raw";
import terrainWorldNoiseSource from "./Terrain/TerrainWorldNoise.glsl?raw";

const GRASSLANDS_CLOUD_SHADOW_INCLUDE = "Terrain/GrasslandsCloudShadow.glsl";
const TERRAIN_WORLD_NOISE_INCLUDE = "Terrain/TerrainWorldNoise.glsl";

/** Registers terrain-owned shader chunks before dependent shaders are compiled. */
export function registerTerrainShaderIncludes(): void {
  if (!ShaderFactory.includeMap[GRASSLANDS_CLOUD_SHADOW_INCLUDE]) {
    ShaderFactory.registerInclude(GRASSLANDS_CLOUD_SHADOW_INCLUDE, grasslandsCloudShadowSource);
  }
  if (!ShaderFactory.includeMap[TERRAIN_WORLD_NOISE_INCLUDE]) {
    ShaderFactory.registerInclude(TERRAIN_WORLD_NOISE_INCLUDE, terrainWorldNoiseSource);
  }
}
