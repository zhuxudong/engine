import type { SurfaceDebugMaskSpec } from "./SurfaceRuntimeContract";

/** CPU-readable grayscale mask with its exact world-space mapping. */
export interface LoadedSurfaceMask {
  readonly id: string;
  readonly width: number;
  readonly height: number;
  readonly pixels: Uint8Array;
  readonly origin: readonly [x: number, z: number];
  readonly size: readonly [width: number, depth: number];
}

/**
 * Decodes finite surface density masks without applying display color conversion.
 * @param specs Versioned mask URLs and world-space mappings.
 * @param manifestUrl Manifest URL used to resolve relative mask paths.
 * @returns CPU grayscale masks keyed by their stable ids.
 * @throws If a mask cannot be fetched or decoded through a 2D canvas.
 */
export async function loadSurfaceMasks(
  specs: readonly SurfaceDebugMaskSpec[],
  manifestUrl: string
): Promise<ReadonlyMap<string, LoadedSurfaceMask>> {
  const entries = await Promise.all(
    specs.map(async (spec) => {
      const url = new URL(spec.url, manifestUrl).href;
      const response = await fetch(url);
      if (!response.ok) throw new Error(`[SurfaceMask] ${url} returned ${response.status}`);
      const bitmap = await createImageBitmap(await response.blob(), {
        colorSpaceConversion: "none"
      });
      const canvas = document.createElement("canvas");
      canvas.width = bitmap.width;
      canvas.height = bitmap.height;
      const context = canvas.getContext("2d", { willReadFrequently: true });
      if (!context) throw new Error(`[SurfaceMask] ${url} could not create a 2D context`);
      context.drawImage(bitmap, 0, 0);
      bitmap.close();
      const rgba = context.getImageData(0, 0, canvas.width, canvas.height).data;
      const pixels = new Uint8Array(canvas.width * canvas.height);
      for (let index = 0; index < pixels.length; index++) pixels[index] = rgba[index * 4];
      return [
        spec.id,
        {
          id: spec.id,
          width: canvas.width,
          height: canvas.height,
          pixels,
          origin: spec.origin,
          size: spec.size
        }
      ] as const;
    })
  );
  return new Map(entries);
}
