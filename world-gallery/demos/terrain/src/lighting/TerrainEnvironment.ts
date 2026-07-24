import {
  AmbientLight,
  AssetType,
  BackgroundMode,
  Color,
  DirectLight,
  Engine,
  Entity,
  PrimitiveMesh,
  Scene,
  ShadowCascadesMode,
  ShadowResolution,
  ShadowType,
  SkyBoxMaterial,
  Vector3
} from "@galacean/engine";

/** Mutable visibility state for terrain's direct and image-based lighting. */
export interface TerrainLightingSnapshot {
  /** Whether the shadow-casting directional light is active. */
  directLight: boolean;
  /** Whether the directional light renders and samples its shadow map. */
  shadows: boolean;
  /** Whether the sky background and baked ambient light are active. */
  environment: boolean;
}

/** Runtime controls for terrain's scene lighting. */
export interface TerrainEnvironment {
  /** Loads the current direct/environment visibility state. */
  getLighting(): TerrainLightingSnapshot;
  /** Updates direct-light and environment visibility without rebaking assets. */
  setLighting(values: Partial<TerrainLightingSnapshot>): void;
}

const SKY_HORIZON_COLOR = new Color(0.505882, 0.615686, 0.709804, 1);
const SUN_DIRECTION = new Vector3(0.500003, -0.749999, 0.43301);

/**
 * Loads the baked environment asset and configures the matching terrain light rig.
 * @param engine - Engine that owns the scene resources.
 * @param scene - Scene receiving the sky, ambient light, and shadow settings.
 * @param parent - Parent for the directional-light entity.
 * @param ambientLightUrl - URL of the baked `.ambLight` asset.
 * @returns Runtime controls for direct and environment lighting.
 */
export async function createTerrainEnvironment(
  engine: Engine,
  scene: Scene,
  parent: Entity,
  ambientLightUrl: string
): Promise<TerrainEnvironment> {
  const ambientLight = await engine.resourceManager.load<AmbientLight>({
    type: AssetType.AmbientLight,
    url: ambientLightUrl
  });
  ambientLight.diffuseIntensity = 1;
  ambientLight.specularIntensity = 1;
  scene.ambientLight = ambientLight;

  const skyMaterial = new SkyBoxMaterial(engine);
  skyMaterial.texture = ambientLight.specularTexture;
  scene.background.sky.material = skyMaterial;
  scene.background.sky.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
  scene.background.solidColor = SKY_HORIZON_COLOR;
  scene.background.mode = BackgroundMode.Sky;

  scene.castShadows = true;
  scene.shadowResolution = ShadowResolution.High;
  scene.shadowCascades = ShadowCascadesMode.FourCascades;
  scene.shadowDistance = 256;

  const directLightEntity = parent.createChild("terrain-directional-light");
  const directLight = directLightEntity.addComponent(DirectLight);
  directLight.color = new Color(1, 1, 1, 1);
  directLight.shadowType = ShadowType.Hard;
  directLightEntity.transform.lookAt(SUN_DIRECTION);

  const state: TerrainLightingSnapshot = { directLight: true, shadows: true, environment: true };
  return {
    getLighting() {
      return { ...state };
    },
    setLighting(values) {
      if (values.directLight !== undefined) {
        state.directLight = values.directLight;
        directLightEntity.isActive = values.directLight;
      }
      if (values.shadows !== undefined) {
        state.shadows = values.shadows;
        directLight.shadowType = values.shadows ? ShadowType.Hard : ShadowType.None;
      }
      if (values.environment !== undefined) {
        state.environment = values.environment;
        ambientLight.diffuseIntensity = values.environment ? 1 : 0;
        ambientLight.specularIntensity = values.environment ? 1 : 0;
        scene.background.mode = values.environment ? BackgroundMode.Sky : BackgroundMode.SolidColor;
      }
    }
  };
}
