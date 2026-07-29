import { ShaderFactory } from "@galacean/engine-core";
import grasslandsCloudShadowSource from "./Terrain/GrasslandsCloudShadow.glsl?raw";
import surfaceDepthPassSource from "./Terrain/SurfaceDepthPass.glsl?raw";
import terrainGeometryPassSource from "./Terrain/TerrainGeometryPass.glsl?raw";
import terrainWorldNoiseSource from "./Terrain/TerrainWorldNoise.glsl?raw";

const GRASSLANDS_CLOUD_SHADOW_INCLUDE = "Terrain/GrasslandsCloudShadow.glsl";
const SURFACE_DEPTH_PASS_INCLUDE = "Terrain/SurfaceDepthPass.glsl";
const TERRAIN_GEOMETRY_PASS_INCLUDE = "Terrain/TerrainGeometryPass.glsl";
const TERRAIN_WORLD_NOISE_INCLUDE = "Terrain/TerrainWorldNoise.glsl";

/** Registers terrain-owned shader chunks before dependent shaders are compiled. */
export function registerTerrainShaderIncludes(): void {
  if (!ShaderFactory.includeMap[GRASSLANDS_CLOUD_SHADOW_INCLUDE]) {
    ShaderFactory.registerInclude(GRASSLANDS_CLOUD_SHADOW_INCLUDE, grasslandsCloudShadowSource);
  }
  if (!ShaderFactory.includeMap[SURFACE_DEPTH_PASS_INCLUDE]) {
    ShaderFactory.registerInclude(SURFACE_DEPTH_PASS_INCLUDE, surfaceDepthPassSource);
  }
  if (!ShaderFactory.includeMap[TERRAIN_GEOMETRY_PASS_INCLUDE]) {
    ShaderFactory.registerInclude(TERRAIN_GEOMETRY_PASS_INCLUDE, terrainGeometryPassSource);
  }
  if (!ShaderFactory.includeMap[TERRAIN_WORLD_NOISE_INCLUDE]) {
    ShaderFactory.registerInclude(TERRAIN_WORLD_NOISE_INCLUDE, terrainWorldNoiseSource);
  }
}
