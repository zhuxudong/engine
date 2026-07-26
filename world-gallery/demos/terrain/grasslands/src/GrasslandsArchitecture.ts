import {
  AssetType,
  BaseMaterial,
  Color,
  Engine,
  Entity,
  GLTFResource,
  MeshRenderer,
  ModelMesh,
  PBRMaterial,
  Script,
  Texture2D,
  TextureFilterMode,
  TextureWrapMode
} from "@galacean/engine";
import { SurfaceMaterial } from "../../src/surface/SurfaceMaterial";
import type { SurfaceMaterialSpec, SurfaceRuntimeTuning } from "../../src/surface/SurfaceRuntimeContract";

/** One authored architecture material using the engine's standard metallic-roughness path. */
export interface GrasslandsArchitecturePbrMaterialSpec {
  readonly id: string;
  readonly kind: "pbr";
  readonly albedo: string;
  readonly normal?: string;
  readonly roughnessMetallic: string;
  /** Linear-RGB tint multiplied with the decoded albedo texture. */
  readonly baseColor: readonly [r: number, g: number, b: number, a: number];
  readonly metallic: number;
  readonly roughness: number;
  readonly normalScale: number;
}

/** Architecture material rendered by the shared vegetation shader. */
export type GrasslandsArchitectureVegetationMaterialSpec = SurfaceMaterialSpec & {
  readonly kind: "vegetation";
};

/** One standard PBR or wind-animated vegetation material used by authored architecture. */
export type GrasslandsArchitectureMaterialSpec =
  | GrasslandsArchitecturePbrMaterialSpec
  | GrasslandsArchitectureVegetationMaterialSpec;

/** Runtime resources for the authored Grasslands architecture composition. */
export interface GrasslandsArchitectureSpec {
  /** Color space used by every material color tuple in this section. */
  readonly colorSpace: "linear";
  readonly bundle: string;
  readonly placements: readonly unknown[];
  readonly materials: readonly GrasslandsArchitectureMaterialSpec[];
}

/** Loaded architecture root and diagnostics, intentionally outside the SurfaceWorld contract. */
export interface GrasslandsArchitecture {
  readonly root: Entity;
  readonly placements: number;
  readonly renderers: number;
  /**
   * Applies the shared vegetation wind controls to authored foliage such as Ivy.
   * @param enabled Whether authored foliage animation is active.
   * @param strength Source wind-force multiplier.
   * @param direction Normalized world-space wind direction.
   */
  setWind(enabled: boolean, strength: number, direction: SurfaceRuntimeTuning["wind"]["direction"]): void;
}

/**
 * Loads the authored architecture bundle and replaces export placeholders with shared PBR materials.
 * @param engine Engine owning the glTF, textures, and materials.
 * @param parent Scene entity receiving the architecture root.
 * @param spec Authored architecture resource section.
 * @param layoutUrl URL used to resolve bundle and texture paths.
 * @returns Loaded architecture diagnostics and visibility root.
 */
export async function loadGrasslandsArchitecture(
  engine: Engine,
  parent: Entity,
  spec: GrasslandsArchitectureSpec,
  layoutUrl: string
): Promise<GrasslandsArchitecture> {
  const vegetationMaterials: SurfaceMaterial[] = [];
  const materialEntries = await Promise.all(
    spec.materials.map(async (materialSpec) => {
      if (materialSpec.kind === "vegetation") {
        const material = await SurfaceMaterial.create(engine, materialSpec, layoutUrl);
        vegetationMaterials.push(material);
        return [materialSpec.id, material] as const;
      }
      const material = new PBRMaterial(engine);
      material.name = materialSpec.id;
      material.baseColor = new Color(...materialSpec.baseColor);
      material.metallic = materialSpec.metallic;
      material.roughness = materialSpec.roughness;
      material.normalTextureIntensity = materialSpec.normalScale;
      const [albedo, normal, roughnessMetallic] = await Promise.all([
        loadTexture(engine, new URL(materialSpec.albedo, layoutUrl).href, true),
        materialSpec.normal ? loadTexture(engine, new URL(materialSpec.normal, layoutUrl).href, false) : undefined,
        loadTexture(engine, new URL(materialSpec.roughnessMetallic, layoutUrl).href, false)
      ]);
      material.baseTexture = albedo;
      if (normal) material.normalTexture = normal;
      material.roughnessMetallicTexture = roughnessMetallic;
      return [materialSpec.id, material] as const;
    })
  );
  const materials = new Map<string, BaseMaterial>(materialEntries);
  const resource = await engine.resourceManager.load<GLTFResource>({
    type: AssetType.GLTF,
    url: new URL(spec.bundle, layoutUrl).href
  });
  const root = resource.instantiateSceneRoot();
  root.name = "grasslands-architecture";
  parent.addChild(root);
  const renderers = root.getComponentsIncludeChildren(MeshRenderer, []);
  for (const renderer of renderers) {
    for (let materialIndex = 0; materialIndex < renderer.materialCount; materialIndex++) {
      const exportedMaterial = renderer.getMaterial(materialIndex);
      const material = exportedMaterial && materials.get(exportedMaterial.name);
      if (!material) {
        throw new Error(
          `[GrasslandsArchitecture] renderer ${renderer.entity.name} references unknown material ${exportedMaterial?.name}`
        );
      }
      renderer.setMaterial(materialIndex, material);
      if (material instanceof SurfaceMaterial) {
        renderer.enableVertexColor =
          renderer.mesh instanceof ModelMesh &&
          renderer.mesh.vertexElements.some((element) => element.attribute === "COLOR_0");
        SurfaceMaterial.setRendererVertexColor(renderer.enableVertexColor, renderer.shaderData);
        SurfaceMaterial.setRendererInstanced(false, renderer.shaderData);
        SurfaceMaterial.setRendererBillboard(false, renderer.shaderData);
        SurfaceMaterial.setRendererWorldNoise(false, renderer.shaderData);
        SurfaceMaterial.setRendererTuning([1, 1, 1], 1, renderer.shaderData);
      }
      renderer.castShadows = true;
      renderer.receiveShadows = true;
    }
  }
  const wind = root.addComponent(GrasslandsArchitectureWind);
  wind.materials = vegetationMaterials;
  return {
    root,
    placements: spec.placements.length,
    renderers: renderers.length,
    setWind(enabled, strength, direction) {
      wind.windEnabled = enabled;
      wind.strength = strength;
      wind.direction = direction;
    }
  };
}

class GrasslandsArchitectureWind extends Script {
  materials: SurfaceMaterial[] = [];
  windEnabled = true;
  strength = 1;
  direction: SurfaceRuntimeTuning["wind"]["direction"] = [-0.788, 0, -0.615];
  private _time = 0;

  onUpdate(deltaTime: number): void {
    this._time += deltaTime;
    for (const material of this.materials) {
      material.setWind(this._time, this.windEnabled, this.strength, this.direction);
    }
  }
}

async function loadTexture(engine: Engine, url: string, srgb: boolean): Promise<Texture2D> {
  const texture = await engine.resourceManager.load<Texture2D>({
    type: AssetType.Texture,
    url,
    params: {
      isSRGBColorSpace: srgb,
      mipmap: true,
      wrapModeU: TextureWrapMode.Repeat,
      wrapModeV: TextureWrapMode.Repeat,
      filterMode: TextureFilterMode.Trilinear,
      anisoLevel: 8
    }
  });
  if (!(texture instanceof Texture2D)) throw new Error(`[GrasslandsArchitecture] ${url} did not resolve to Texture2D`);
  return texture;
}
