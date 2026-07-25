import {
  AmbientLight,
  AssetType,
  BackgroundMode,
  Color,
  DirectLight,
  Engine,
  Entity,
  FogMode,
  PrimitiveMesh,
  Quaternion,
  Scene,
  Script,
  ShaderMacro,
  ShaderProperty,
  ShadowCascadesMode,
  ShadowResolution,
  ShadowType,
  SkyBoxMaterial,
  Texture2D,
  TextureFilterMode,
  TextureWrapMode,
  Vector3,
  Vector4
} from "@galacean/engine";

const CLOUD_SHADOW_MACRO = ShaderMacro.getByName("SCENE_GRASSLANDS_CLOUD_SHADOW");
const CLOUD_SHADOW_TEXTURE = ShaderProperty.getByName("scene_GrasslandsCloudShadow");
const CLOUD_SHADOW_RIGHT = ShaderProperty.getByName("scene_GrasslandsCloudRight");
const CLOUD_SHADOW_UP = ShaderProperty.getByName("scene_GrasslandsCloudUp");
const CLOUD_SHADOW_PARAMS = ShaderProperty.getByName("scene_GrasslandsCloudParams");

/** Unity-authored Grasslands atmosphere and directional-light values. */
export interface GrasslandsEnvironmentSpec {
  readonly ambientIntensity: number;
  readonly reflectionIntensity: number;
  readonly fog: {
    readonly enabled: boolean;
    readonly mode: "exponential";
    readonly color: readonly [r: number, g: number, b: number];
    readonly density: number;
  };
  readonly sky: {
    readonly hdr: string;
    readonly exposure: number;
    readonly rotationDegrees: number;
    readonly tint: readonly [r: number, g: number, b: number, a: number];
  };
  readonly light: {
    readonly position: readonly [x: number, y: number, z: number];
    readonly rotation: readonly [x: number, y: number, z: number, w: number];
    readonly color: readonly [r: number, g: number, b: number];
    readonly intensity: number;
    readonly shadows: boolean;
    readonly shadowStrength: number;
    readonly bias: number;
    readonly normalBias: number;
    readonly cookie: string;
    readonly cookieSize: number;
    readonly cookieSpeed: number;
  };
}

/** Mutable scene-only rendering switches, separate from SurfaceWorld. */
export interface GrasslandsEnvironmentTuning {
  readonly directLight: boolean;
  readonly shadows: boolean;
  readonly environment: boolean;
  readonly sky: boolean;
  readonly fog: boolean;
  readonly cloudShadows: boolean;
  readonly animation: boolean;
}

/** Runtime environment controls for Grasslands diagnostics. */
export interface GrasslandsEnvironment {
  /** Returns the current scene-only environment switches. */
  getTuning(): GrasslandsEnvironmentTuning;
  /**
   * Applies scene-only environment switches.
   * @param values Direct light, shadow, IBL, sky, or fog changes.
   */
  setTuning(values: Partial<GrasslandsEnvironmentTuning>): void;
}

/**
 * Loads the Grasslands-specific baked HDR environment and authored direct-light rig.
 * @param engine Engine owning environment resources.
 * @param scene Scene receiving sky, fog, ambient light, and cascaded shadows.
 * @param parent Parent of the directional light.
 * @param spec Exact exported Unity environment values.
 * @param ambientLightUrl URL of the source-authored ambient probe and prefiltered reflection asset.
 * @param skyboxAmbientLightUrl URL of a neutral cubemap compiled from `spec.sky.hdr` for background rendering.
 * @param layoutUrl URL used to resolve the exported light-cookie path.
 * @returns Scene-only environment controls.
 */
export async function createGrasslandsEnvironment(
  engine: Engine,
  scene: Scene,
  parent: Entity,
  spec: GrasslandsEnvironmentSpec,
  ambientLightUrl: string,
  skyboxAmbientLightUrl: string,
  layoutUrl: string
): Promise<GrasslandsEnvironment> {
  const [ambientLight, skyboxAmbientLight, cloudShadowTexture] = await Promise.all([
    engine.resourceManager.load<AmbientLight>({
      type: AssetType.AmbientLight,
      url: ambientLightUrl
    }),
    engine.resourceManager.load<AmbientLight>({
      type: AssetType.AmbientLight,
      url: skyboxAmbientLightUrl
    }),
    engine.resourceManager.load<Texture2D>({
      type: AssetType.Texture,
      url: new URL(spec.light.cookie, layoutUrl).href,
      params: {
        isSRGBColorSpace: false,
        mipmap: true,
        wrapModeU: TextureWrapMode.Repeat,
        wrapModeV: TextureWrapMode.Repeat,
        filterMode: TextureFilterMode.Trilinear,
        anisoLevel: 4
      }
    })
  ]);
  if (!(cloudShadowTexture instanceof Texture2D)) {
    throw new Error(`[GrasslandsEnvironment] ${spec.light.cookie} did not resolve to Texture2D`);
  }
  ambientLight.diffuseIntensity = spec.ambientIntensity;
  ambientLight.specularIntensity = spec.reflectionIntensity;
  scene.ambientLight = ambientLight;

  const skyMaterial = new SkyBoxMaterial(engine);
  skyMaterial.texture = skyboxAmbientLight.specularTexture;
  skyMaterial.exposure = spec.sky.exposure;
  skyMaterial.rotation = spec.sky.rotationDegrees;
  skyMaterial.tintColor = new Color(...spec.sky.tint);
  scene.background.sky.material = skyMaterial;
  scene.background.sky.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
  scene.background.solidColor = new Color(...spec.fog.color, 1);
  scene.background.mode = BackgroundMode.Sky;

  scene.fogMode = spec.fog.enabled ? FogMode.Exponential : FogMode.None;
  scene.fogColor = new Color(...spec.fog.color, 1);
  scene.fogDensity = spec.fog.density;
  scene.castShadows = true;
  scene.shadowResolution = ShadowResolution.High;
  scene.shadowCascades = ShadowCascadesMode.FourCascades;
  scene.shadowDistance = 500;

  const lightEntity = parent.createChild("grasslands-directional-light");
  lightEntity.transform.position.set(...spec.light.position);
  lightEntity.transform.rotationQuaternion = new Quaternion(...spec.light.rotation);
  const directLight = lightEntity.addComponent(DirectLight);
  directLight.color = new Color(
    spec.light.color[0] * spec.light.intensity,
    spec.light.color[1] * spec.light.intensity,
    spec.light.color[2] * spec.light.intensity,
    1
  );
  directLight.shadowType = spec.light.shadows ? ShadowType.SoftLow : ShadowType.None;
  directLight.shadowStrength = spec.light.shadowStrength;
  directLight.shadowBias = spec.light.bias;
  directLight.shadowNormalBias = spec.light.normalBias;

  const cloudShadow = lightEntity.addComponent(GrasslandsCloudShadow);
  cloudShadow.initialize(scene, cloudShadowTexture, spec.light.cookieSize, spec.light.cookieSpeed);

  const tuning: MutableGrasslandsEnvironmentTuning = {
    directLight: true,
    shadows: spec.light.shadows,
    environment: true,
    sky: true,
    fog: spec.fog.enabled,
    cloudShadows: true,
    animation: true
  };
  return {
    getTuning: () => ({ ...tuning }),
    setTuning(values) {
      Object.assign(tuning, values);
      lightEntity.isActive = tuning.directLight;
      directLight.shadowType = tuning.shadows ? ShadowType.SoftLow : ShadowType.None;
      ambientLight.diffuseIntensity = tuning.environment ? spec.ambientIntensity : 0;
      ambientLight.specularIntensity = tuning.environment ? spec.reflectionIntensity : 0;
      scene.background.mode = tuning.sky ? BackgroundMode.Sky : BackgroundMode.SolidColor;
      scene.fogMode = tuning.fog ? FogMode.Exponential : FogMode.None;
      cloudShadow.cloudShadowEnabled = tuning.cloudShadows;
      cloudShadow.animation = tuning.animation;
    }
  };
}

interface MutableGrasslandsEnvironmentTuning {
  directLight: boolean;
  shadows: boolean;
  environment: boolean;
  sky: boolean;
  fog: boolean;
  cloudShadows: boolean;
  animation: boolean;
}

class GrasslandsCloudShadow extends Script {
  cloudShadowEnabled = true;
  animation = true;

  private readonly _right = new Vector3();
  private readonly _up = new Vector3();
  private readonly _params = new Vector4();
  private _scene?: Scene;
  private _inverseSize = 0;
  private _speed = 0;
  private _originU = 0;
  private _originV = 0;
  private _time = 0;

  initialize(scene: Scene, texture: Texture2D, size: number, speed: number): void {
    this._scene = scene;
    this._inverseSize = 1 / size;
    this._speed = speed;
    this._right.copyFrom(this.entity.transform.worldRight);
    this._up.copyFrom(this.entity.transform.worldUp);
    const position = this.entity.transform.worldPosition;
    this._originU = 0.5 - Vector3.dot(position, this._right) * this._inverseSize;
    this._originV = 0.5 - Vector3.dot(position, this._up) * this._inverseSize;
    const shaderData = scene.shaderData;
    shaderData.enableMacro(CLOUD_SHADOW_MACRO);
    shaderData.setTexture(CLOUD_SHADOW_TEXTURE, texture);
    shaderData.setVector3(CLOUD_SHADOW_RIGHT, this._right);
    shaderData.setVector3(CLOUD_SHADOW_UP, this._up);
    this._updateShaderData();
  }

  override onUpdate(deltaTime: number): void {
    if (this.animation) this._time += deltaTime;
    this._updateShaderData();
  }

  private _updateShaderData(): void {
    const scene = this._scene;
    if (!scene) return;
    this._params.set(
      this._inverseSize,
      this._originU - this._time * this._speed * this._inverseSize,
      this._originV,
      this.cloudShadowEnabled ? 1 : 0
    );
    scene.shaderData.setVector4(CLOUD_SHADOW_PARAMS, this._params);
  }
}
