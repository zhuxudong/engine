import { AssetType, Engine, Shader } from "@galacean/engine";
import type { TerrainBackend } from "../TerrainEngineBootstrap";

const TERRAIN_SHADER_ARTIFACT_URLS = [
  "/compiledShaders/terrain/Terrain.shaderc",
  "/compiledShaders/terrain/Surface.shaderc"
] as const;

/** Terrain ShaderLab registration mode selected for startup measurements. */
export type TerrainShaderMode = "runtime" | "precompiled";

/** Read-only result of registering the terrain ShaderLab programs. */
export interface TerrainShaderRegistrationSnapshot {
  /** Registration path used by the page. */
  readonly mode: TerrainShaderMode;
  /** Graphics backend consuming the registered shader instructions. */
  readonly backend: TerrainBackend;
  /** Artifact URLs fetched by the selected backend, empty in runtime mode. */
  readonly artifactUrls: readonly string[];
  /** Wall-clock time spent registering both terrain shaders. */
  readonly durationMs: number;
}

/**
 * Registers Terrain and Surface from source or existing build artifacts.
 * @param engine Engine that owns the shader asset loader.
 * @param backend Backend created for the current page.
 * @param search Current page query string.
 * @param terrainSource Terrain ShaderLab source used by runtime mode.
 * @param surfaceSource Surface ShaderLab source used by runtime mode.
 * @returns Registration mode, resolved artifact URLs, and elapsed time.
 */
export async function registerTerrainShaders(
  engine: Engine,
  backend: TerrainBackend,
  search: string,
  terrainSource: string,
  surfaceSource: string
): Promise<TerrainShaderRegistrationSnapshot> {
  const mode = resolveTerrainShaderMode(search);
  const startedAt = performance.now();

  if (mode === "precompiled") {
    await Promise.all(
      TERRAIN_SHADER_ARTIFACT_URLS.map((url) =>
        engine.resourceManager.load({
          type: AssetType.Shader,
          url
        })
      )
    );
  } else {
    Shader.create(terrainSource);
    Shader.create(surfaceSource);
  }

  return {
    mode,
    backend,
    artifactUrls:
      mode === "precompiled"
        ? TERRAIN_SHADER_ARTIFACT_URLS.map((url) => (backend === "webgpu" ? url.replace(/\.shaderc$/, ".wgslc") : url))
        : [],
    durationMs: performance.now() - startedAt
  };
}

/**
 * Resolves the terrain shader registration mode.
 * @param search URL query string.
 * @returns Precompiled only for an explicit `shaderMode=precompiled`.
 */
export function resolveTerrainShaderMode(search: string): TerrainShaderMode {
  return new URLSearchParams(search).get("shaderMode") === "precompiled" ? "precompiled" : "runtime";
}
