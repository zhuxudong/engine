import { Engine, Texture2DArray, TextureFilterMode, TextureFormat, TextureWrapMode } from "@galacean/engine";
import { TerrainLayerSpec } from "./ManifestLoader";

/** Loaded terrain texture-asset arrays. */
export interface TerrainLayerTextures {
  readonly albedoHeight: Texture2DArray;
  readonly normalRoughness: Texture2DArray;
}

/**
 * Loads contiguous terrain texture assets without resampling their exported pixels.
 * @param engine Engine that owns the texture arrays.
 * @param layers terrain texture asset descriptors in slot order.
 * @param manifestUrl Absolute manifest URL used to resolve image paths.
 * @returns Albedo/height and normal/roughness texture arrays.
 * @throws If an image cannot load or layer dimensions differ.
 */
export async function loadLayerTextures(
  engine: Engine,
  layers: readonly TerrainLayerSpec[],
  manifestUrl: string
): Promise<TerrainLayerTextures> {
  const images = await Promise.all(
    layers.map(async (layer) => ({
      albedoHeight: await loadImage(new URL(layer.albedoHeight, manifestUrl).href),
      normalRoughness: await loadImage(new URL(layer.normalRoughness, manifestUrl).href)
    }))
  );
  const width = images[0].albedoHeight.width;
  const height = images[0].albedoHeight.height;
  for (let index = 0; index < images.length; index++) {
    const pair = images[index];
    if (
      pair.albedoHeight.width !== width ||
      pair.albedoHeight.height !== height ||
      pair.normalRoughness.width !== width ||
      pair.normalRoughness.height !== height
    ) {
      throw new Error(`[TerrainLayers] layer ${index} does not match ${width}x${height}`);
    }
  }

  const albedoHeight = new Texture2DArray(engine, width, height, layers.length, TextureFormat.R8G8B8A8, true, true);
  const normalRoughness = new Texture2DArray(engine, width, height, layers.length, TextureFormat.R8G8B8A8, true, false);
  for (let layer = 0; layer < layers.length; layer++) {
    albedoHeight.setImageSource(layer, images[layer].albedoHeight);
    normalRoughness.setImageSource(layer, images[layer].normalRoughness);
  }
  for (const texture of [albedoHeight, normalRoughness]) {
    texture.generateMipmaps();
    texture.filterMode = TextureFilterMode.Trilinear;
    texture.wrapModeU = texture.wrapModeV = TextureWrapMode.Repeat;
    texture.anisoLevel = 16;
  }
  return { albedoHeight, normalRoughness };
}

async function loadImage(url: string): Promise<ImageBitmap> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`[TerrainLayers] failed to load ${url}: ${response.status}`);
  }
  return createImageBitmap(await response.blob(), {
    colorSpaceConversion: "none",
    premultiplyAlpha: "none"
  });
}
