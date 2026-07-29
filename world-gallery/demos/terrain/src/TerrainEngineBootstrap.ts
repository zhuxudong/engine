import { Engine, WebGLEngine, WebGPUEngine } from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";

/** Graphics backend selected for a terrain validation page. */
export type TerrainBackend = "webgl2" | "webgpu";

/** Engine and backend created from the current page URL. */
export interface TerrainEngineSession {
  /** Engine instance owning the page canvas. */
  readonly engine: Engine & { readonly canvas: { resizeByClientSize(): void } };
  /** Backend selected by the `backend` query parameter. */
  readonly backend: TerrainBackend;
}

/**
 * Creates the terrain page engine selected by `?backend=webgl2|webgpu`.
 * @param canvas Canvas element or element id owned by the new engine.
 * @returns Engine session using WebGL2 by default.
 */
export async function createTerrainEngine(
  canvas: HTMLCanvasElement | OffscreenCanvas | string
): Promise<TerrainEngineSession> {
  const backend = resolveTerrainBackend(location.search);
  const configuration = { canvas, shaderCompiler: new ShaderCompiler() };
  const engine =
    backend === "webgpu"
      ? await WebGPUEngine.create({
          ...configuration,
          graphicDeviceOptions: {
            enableGPUTiming: new URLSearchParams(location.search).get("gpuTiming") === "1"
          }
        })
      : await WebGLEngine.create(configuration);
  return { engine, backend };
}

/**
 * Binds a backend selector to full-page navigation so one canvas never owns two engine contexts.
 * @param selector Backend select element.
 * @param backend Backend used by the current document.
 */
export function bindTerrainBackendSelector(selector: HTMLSelectElement | null, backend: TerrainBackend): void {
  if (!selector) return;
  selector.value = backend;
  selector.addEventListener("change", () => {
    const url = new URL(location.href);
    url.searchParams.set("backend", selector.value);
    location.href = url.href;
  });
}

/**
 * Resolves the terrain backend without accepting unsupported fallback aliases.
 * @param search URL query string.
 * @returns WebGPU only for an explicit `backend=webgpu`; otherwise WebGL2.
 */
export function resolveTerrainBackend(search: string): TerrainBackend {
  return new URLSearchParams(search).get("backend") === "webgpu" ? "webgpu" : "webgl2";
}
