import { ShaderFactory } from "@galacean/engine-core";
import grasslandsCloudShadowSource from "./includes/GrasslandsCloudShadow.glsl?raw";

const GRASSLANDS_CLOUD_SHADOW_INCLUDE = "Terrain/GrasslandsCloudShadow.glsl";

/** Registers demo-owned shader chunks before terrain shaders are compiled. */
export function registerTerrainShaderIncludes(): void {
  if (!ShaderFactory.includeMap[GRASSLANDS_CLOUD_SHADOW_INCLUDE]) {
    ShaderFactory.registerInclude(GRASSLANDS_CLOUD_SHADOW_INCLUDE, grasslandsCloudShadowSource);
  }
}
