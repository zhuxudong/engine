import {
  AssetType,
  BaseMaterial,
  Color,
  Engine,
  RenderFace,
  Shader,
  ShaderMacro,
  ShaderProperty,
  Texture2D,
  TextureFilterMode,
  TextureWrapMode,
  Vector3,
  Vector4
} from "@galacean/engine";
import type { SurfaceMaterialSpec } from "./SurfaceRuntimeContract";

const WHITE_PIXEL = new Uint8Array([255, 255, 255, 255]);
const FLAT_NORMAL_PIXEL = new Uint8Array([128, 128, 255, 255]);

/** Instanced vegetation/PBR material configured from the portable surface manifest. */
export class SurfaceMaterial extends BaseMaterial {
  private static readonly _albedo = ShaderProperty.getByName("material_Albedo");
  private static readonly _normal = ShaderProperty.getByName("material_Normal");
  private static readonly _baseColor = ShaderProperty.getByName("material_BaseColor");
  private static readonly _secondColor = ShaderProperty.getByName("material_SecondColor");
  private static readonly _roughness = ShaderProperty.getByName("material_Roughness");
  private static readonly _normalScale = ShaderProperty.getByName("material_NormalScale");
  private static readonly _time = ShaderProperty.getByName("material_Time");
  private static readonly _windForce = ShaderProperty.getByName("material_WindForce");
  private static readonly _windWavesScale = ShaderProperty.getByName("material_WindWavesScale");
  private static readonly _windFlowDensity = ShaderProperty.getByName("material_WindFlowDensity");
  private static readonly _windBaseLock = ShaderProperty.getByName("material_WindBaseLock");
  private static readonly _windEnabled = ShaderProperty.getByName("material_WindEnabled");
  private static readonly _windDirection = ShaderProperty.getByName("material_WindDirection");
  private static readonly _globalWindForce = ShaderProperty.getByName("material_GlobalWindForce");
  private static readonly _globalWavesScale = ShaderProperty.getByName("material_GlobalWavesScale");
  private static readonly _globalFlowDensity = ShaderProperty.getByName("material_GlobalFlowDensity");
  private static readonly _colorVariationEnabled = ShaderProperty.getByName("material_ColorVariationEnabled");
  private static readonly _colorNoiseScale = ShaderProperty.getByName("material_ColorNoiseScale");
  private static readonly _colorOffset = ShaderProperty.getByName("material_ColorOffset");
  private static readonly _colorFade = ShaderProperty.getByName("material_ColorFade");
  private static readonly _lightingFlatness = ShaderProperty.getByName("material_LightingFlatness");
  private static readonly _translucency = ShaderProperty.getByName("material_Translucency");
  private static readonly _translucencyColor = ShaderProperty.getByName("material_TranslucencyColor");
  private static readonly _fadeDistance = ShaderProperty.getByName("material_FadeDistance");
  private static readonly _debugView = ShaderProperty.getByName("material_DebugView");
  private static readonly _vertexColorMacro = ShaderMacro.getByName("RENDERER_ENABLE_VERTEXCOLOR");

  readonly id: string;
  readonly kind: SurfaceMaterialSpec["kind"];
  private readonly _baseWindForce: number;
  private readonly _baseWindEnabled: boolean;

  private constructor(engine: Engine, spec: SurfaceMaterialSpec) {
    const shader = Shader.find("Terrain/Surface");
    if (!shader) throw new Error('[SurfaceMaterial] Shader "Terrain/Surface" is not registered');
    super(engine, shader);
    this.id = spec.id;
    this.kind = spec.kind;
    this._baseWindForce = spec.wind.force;
    this._baseWindEnabled = spec.wind.enabled;
    this.alphaCutoff = spec.alphaCutoff;
    this.renderFace = spec.kind === "vegetation" ? RenderFace.Double : RenderFace.Front;
    this.shaderData.setColor(SurfaceMaterial._baseColor, new Color(...spec.baseColor));
    this.shaderData.setVector4(SurfaceMaterial._secondColor, new Vector4(...spec.secondColor));
    this.shaderData.setFloat(SurfaceMaterial._roughness, spec.roughness);
    this.shaderData.setFloat(SurfaceMaterial._normalScale, spec.normalScale);
    this.shaderData.setFloat(SurfaceMaterial._windForce, spec.wind.force);
    this.shaderData.setFloat(SurfaceMaterial._windWavesScale, spec.wind.wavesScale);
    this.shaderData.setFloat(SurfaceMaterial._windFlowDensity, spec.wind.flowDensity);
    this.shaderData.setInt(SurfaceMaterial._windBaseLock, spec.wind.baseLock ? 1 : 0);
    this.shaderData.setInt(SurfaceMaterial._windEnabled, spec.wind.enabled ? 1 : 0);
    this.shaderData.setFloat(SurfaceMaterial._globalWindForce, 1);
    this.shaderData.setFloat(SurfaceMaterial._globalWavesScale, 1);
    this.shaderData.setFloat(SurfaceMaterial._globalFlowDensity, 1);
    this.shaderData.setInt(SurfaceMaterial._colorVariationEnabled, spec.colorVariation.enabled ? 1 : 0);
    this.shaderData.setFloat(SurfaceMaterial._colorNoiseScale, spec.colorVariation.scale);
    this.shaderData.setFloat(SurfaceMaterial._colorOffset, spec.colorVariation.offset);
    this.shaderData.setFloat(SurfaceMaterial._colorFade, spec.colorVariation.fade);
    this.shaderData.setFloat(SurfaceMaterial._lightingFlatness, spec.lightingFlatness);
    this.shaderData.setFloat(SurfaceMaterial._translucency, spec.translucency);
    this.shaderData.setVector3(SurfaceMaterial._translucencyColor, new Vector3(...spec.translucencyColor.slice(0, 3)));
    this.shaderData.setFloat(SurfaceMaterial._fadeDistance, spec.fadeEnabled ? spec.fadeDistance : 0);
    this.shaderData.setInt(SurfaceMaterial._debugView, 0);
  }

  /**
   * Loads manifest textures and constructs one shared material.
   * @param engine Engine that owns the textures and material.
   * @param spec Portable surface material values.
   * @param manifestUrl URL used to resolve material texture paths.
   * @returns Configured material sharing repeat/trilinear texture resources.
   */
  static async create(engine: Engine, spec: SurfaceMaterialSpec, manifestUrl: string): Promise<SurfaceMaterial> {
    const material = new SurfaceMaterial(engine, spec);
    const [albedo, normal] = await Promise.all([
      loadSurfaceTexture(engine, spec.albedo ? new URL(spec.albedo, manifestUrl).href : undefined, true, WHITE_PIXEL),
      loadSurfaceTexture(engine, spec.normal ? new URL(spec.normal, manifestUrl).href : undefined, false, FLAT_NORMAL_PIXEL)
    ]);
    material.shaderData.setTexture(SurfaceMaterial._albedo, albedo);
    material.shaderData.setTexture(SurfaceMaterial._normal, normal);
    return material;
  }

  /**
   * Updates animation time and global wind controls.
   * @param time Accumulated runtime seconds.
   * @param enabled Whether all surface wind is enabled.
   * @param strength Multiplier applied to source material wind force.
   * @param direction Normalized world-space wind direction.
   */
  setWind(time: number, enabled: boolean, strength: number, direction: readonly [number, number, number]): void {
    this.shaderData.setFloat(SurfaceMaterial._time, time);
    this.shaderData.setInt(SurfaceMaterial._windEnabled, enabled && this._baseWindEnabled ? 1 : 0);
    this.shaderData.setFloat(SurfaceMaterial._windForce, this._baseWindForce * strength);
    this.shaderData.setVector3(SurfaceMaterial._windDirection, new Vector3(...direction));
  }

  /**
   * Selects a shared material diagnostic.
   * @param view Zero for shaded surface and one for world normal.
   */
  setDebugView(view: 0 | 1): void {
    this.shaderData.setInt(SurfaceMaterial._debugView, view);
  }

  /**
   * Enables vertex-color wind weighting for a renderer that owns `COLOR_0`.
   * @param enabled Whether the source mesh contains a vertex color stream.
   * @param shaderData Renderer-local shader data.
   */
  static setRendererVertexColor(enabled: boolean, shaderData: { enableMacro(macro: ShaderMacro): void; disableMacro(macro: ShaderMacro): void }): void {
    enabled ? shaderData.enableMacro(SurfaceMaterial._vertexColorMacro) : shaderData.disableMacro(SurfaceMaterial._vertexColorMacro);
  }
}

async function loadSurfaceTexture(
  engine: Engine,
  url: string | undefined,
  srgb: boolean,
  fallback: Uint8Array
): Promise<Texture2D> {
  if (!url) {
    const texture = new Texture2D(engine, 1, 1);
    texture.setPixelBuffer(fallback);
    return texture;
  }
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
  if (!(texture instanceof Texture2D)) throw new Error(`[SurfaceMaterial] ${url} did not resolve to Texture2D`);
  return texture;
}
