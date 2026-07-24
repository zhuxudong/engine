import {
  AssetType,
  BaseMaterial,
  Color,
  Engine,
  RenderFace,
  Shader,
  ShaderData,
  ShaderMacro,
  ShaderProperty,
  Texture2D,
  TextureFilterMode,
  TextureWrapMode,
  Vector2,
  Vector3,
  Vector4
} from "@galacean/engine";
import type { SurfaceMaterialSpec, SurfacePrototypeRendererSpec } from "./SurfaceRuntimeContract";

const WHITE_PIXEL = new Uint8Array([255, 255, 255, 255]);
const FLAT_NORMAL_PIXEL = new Uint8Array([128, 128, 255, 255]);

/** Instanced vegetation/PBR material configured from the portable surface manifest. */
export class SurfaceMaterial extends BaseMaterial {
  private static readonly _albedo = ShaderProperty.getByName("material_Albedo");
  private static readonly _normal = ShaderProperty.getByName("material_Normal");
  private static readonly _metallicSmoothness = ShaderProperty.getByName("material_MetallicSmoothness");
  private static readonly _occlusion = ShaderProperty.getByName("material_Occlusion");
  private static readonly _coverageAlbedo = ShaderProperty.getByName("material_CoverageAlbedo");
  private static readonly _coverageNormal = ShaderProperty.getByName("material_CoverageNormal");
  private static readonly _coverageMetallicSmoothness = ShaderProperty.getByName("material_CoverageMetallicSmoothness");
  private static readonly _coverageMask = ShaderProperty.getByName("material_CoverageMask");
  private static readonly _lodDither = ShaderProperty.getByName("material_LodDither");
  private static readonly _baseColor = ShaderProperty.getByName("material_BaseColor");
  private static readonly _secondColor = ShaderProperty.getByName("material_SecondColor");
  private static readonly _metallic = ShaderProperty.getByName("material_Metallic");
  private static readonly _roughness = ShaderProperty.getByName("material_Roughness");
  private static readonly _occlusionStrength = ShaderProperty.getByName("material_OcclusionStrength");
  private static readonly _normalScale = ShaderProperty.getByName("material_NormalScale");
  private static readonly _coverageColor = ShaderProperty.getByName("material_CoverageColor");
  private static readonly _coverageTiling = ShaderProperty.getByName("material_CoverageTiling");
  private static readonly _coverageNormalScale = ShaderProperty.getByName("material_CoverageNormalScale");
  private static readonly _coverageMetallic = ShaderProperty.getByName("material_CoverageMetallic");
  private static readonly _coverageRoughness = ShaderProperty.getByName("material_CoverageRoughness");
  private static readonly _coverageSmoothnessSource = ShaderProperty.getByName("material_CoverageSmoothnessSource");
  private static readonly _coverageOverlayMethod = ShaderProperty.getByName("material_CoverageOverlayMethod");
  private static readonly _coverageOffset = ShaderProperty.getByName("material_CoverageOffset");
  private static readonly _coverageBalance = ShaderProperty.getByName("material_CoverageBalance");
  private static readonly _coverageMaskContrast = ShaderProperty.getByName("material_CoverageMaskContrast");
  private static readonly _coverageNormalBlending = ShaderProperty.getByName("material_CoverageNormalBlending");
  private static readonly _coverageMaskTiling = ShaderProperty.getByName("material_CoverageMaskTiling");
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
  private static readonly _colorVariationMode = ShaderProperty.getByName("material_ColorVariationMode");
  private static readonly _colorNoiseScale = ShaderProperty.getByName("material_ColorNoiseScale");
  private static readonly _colorOffset = ShaderProperty.getByName("material_ColorOffset");
  private static readonly _colorFade = ShaderProperty.getByName("material_ColorFade");
  private static readonly _lightingFlatness = ShaderProperty.getByName("material_LightingFlatness");
  private static readonly _translucency = ShaderProperty.getByName("material_Translucency");
  private static readonly _translucencyColor = ShaderProperty.getByName("material_TranslucencyColor");
  private static readonly _fadeDistance = ShaderProperty.getByName("material_FadeDistance");
  private static readonly _fadeFalloff = ShaderProperty.getByName("material_FadeFalloff");
  private static readonly _debugView = ShaderProperty.getByName("material_DebugView");
  private static readonly _localPosition = ShaderProperty.getByName("renderer_SurfaceLocalPosition");
  private static readonly _localRotation = ShaderProperty.getByName("renderer_SurfaceLocalRotation");
  private static readonly _localScale = ShaderProperty.getByName("renderer_SurfaceLocalScale");
  private static readonly _lodFade = ShaderProperty.getByName("renderer_SurfaceLodFade");
  private static readonly _lodFadeEnabled = ShaderProperty.getByName("renderer_SurfaceLodFadeEnabled");
  private static readonly _vertexColorMacro = ShaderMacro.getByName("RENDERER_ENABLE_VERTEXCOLOR");
  private static readonly _billboardMacro = ShaderMacro.getByName("RENDERER_SURFACE_BILLBOARD");
  private static readonly _coverageMacro = ShaderMacro.getByName("MATERIAL_SURFACE_COVERAGE");

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
    this.renderFace = spec.kind === "pbr" ? RenderFace.Front : RenderFace.Double;
    this.shaderData.setColor(SurfaceMaterial._baseColor, new Color(...spec.baseColor));
    this.shaderData.setVector4(SurfaceMaterial._secondColor, new Vector4(...spec.secondColor));
    this.shaderData.setFloat(SurfaceMaterial._metallic, spec.metallic ?? 0);
    this.shaderData.setFloat(SurfaceMaterial._roughness, spec.roughness);
    this.shaderData.setFloat(SurfaceMaterial._occlusionStrength, spec.occlusionStrength ?? 1);
    this.shaderData.setFloat(SurfaceMaterial._normalScale, spec.normalScale);
    if (spec.coverage) {
      const coverage = spec.coverage;
      this.shaderData.enableMacro(SurfaceMaterial._coverageMacro);
      this.shaderData.setColor(SurfaceMaterial._coverageColor, new Color(...coverage.color));
      this.shaderData.setFloat(SurfaceMaterial._coverageTiling, coverage.tiling);
      this.shaderData.setFloat(SurfaceMaterial._coverageNormalScale, coverage.normalScale);
      this.shaderData.setFloat(SurfaceMaterial._coverageMetallic, coverage.metallic);
      this.shaderData.setFloat(SurfaceMaterial._coverageRoughness, coverage.roughness);
      this.shaderData.setInt(
        SurfaceMaterial._coverageSmoothnessSource,
        coverage.smoothnessSource === "albedo-alpha" ? 1 : 0
      );
      this.shaderData.setInt(
        SurfaceMaterial._coverageOverlayMethod,
        coverage.overlayMethod === "vertex-normal" ? 1 : 0
      );
      this.shaderData.setFloat(SurfaceMaterial._coverageOffset, coverage.offset);
      this.shaderData.setFloat(SurfaceMaterial._coverageBalance, coverage.balance);
      this.shaderData.setFloat(SurfaceMaterial._coverageMaskContrast, coverage.maskContrast);
      this.shaderData.setFloat(SurfaceMaterial._coverageNormalBlending, coverage.normalBlending);
      this.shaderData.setVector2(
        SurfaceMaterial._coverageMaskTiling,
        new Vector2(...coverage.maskTiling)
      );
    }
    this.shaderData.setFloat(SurfaceMaterial._windForce, spec.wind.force);
    this.shaderData.setFloat(SurfaceMaterial._windWavesScale, spec.wind.wavesScale);
    this.shaderData.setFloat(SurfaceMaterial._windFlowDensity, spec.wind.flowDensity);
    this.shaderData.setInt(SurfaceMaterial._windBaseLock, spec.wind.baseLock ? 1 : 0);
    this.shaderData.setInt(SurfaceMaterial._windEnabled, spec.wind.enabled ? 1 : 0);
    this.shaderData.setFloat(SurfaceMaterial._globalWindForce, 1);
    this.shaderData.setFloat(SurfaceMaterial._globalWavesScale, 1);
    this.shaderData.setFloat(SurfaceMaterial._globalFlowDensity, 1);
    this.shaderData.setInt(SurfaceMaterial._colorVariationEnabled, spec.colorVariation.enabled ? 1 : 0);
    this.shaderData.setInt(SurfaceMaterial._colorVariationMode, colorVariationMode(spec.colorVariation.mode));
    this.shaderData.setFloat(SurfaceMaterial._colorNoiseScale, spec.colorVariation.scale);
    this.shaderData.setFloat(SurfaceMaterial._colorOffset, spec.colorVariation.offset);
    this.shaderData.setFloat(SurfaceMaterial._colorFade, spec.colorVariation.fade);
    this.shaderData.setFloat(SurfaceMaterial._lightingFlatness, spec.lightingFlatness);
    this.shaderData.setFloat(SurfaceMaterial._translucency, spec.translucency);
    this.shaderData.setVector3(SurfaceMaterial._translucencyColor, new Vector3(...spec.translucencyColor.slice(0, 3)));
    this.shaderData.setFloat(SurfaceMaterial._fadeDistance, spec.fadeEnabled ? spec.fadeDistance : 0);
    this.shaderData.setFloat(SurfaceMaterial._fadeFalloff, spec.fadeFalloff);
    this.shaderData.setInt(SurfaceMaterial._debugView, 0);
  }

  /**
   * Loads manifest textures and constructs one shared material.
   * @param engine Engine that owns the textures and material.
   * @param spec Portable surface material values.
   * @param manifestUrl URL used to resolve material texture paths.
   * @param lodDitherUrl Screen-space threshold texture used by cross-fading LODs.
   * @returns Configured material sharing repeat/trilinear texture resources.
   */
  static async create(
    engine: Engine,
    spec: SurfaceMaterialSpec,
    manifestUrl: string,
    lodDitherUrl: string
  ): Promise<SurfaceMaterial> {
    const material = new SurfaceMaterial(engine, spec);
    const [albedo, normal, metallicSmoothness, occlusion, lodDither, coverageTextures] = await Promise.all([
      loadSurfaceTexture(engine, spec.albedo ? new URL(spec.albedo, manifestUrl).href : undefined, true, WHITE_PIXEL),
      loadSurfaceTexture(engine, spec.normal ? new URL(spec.normal, manifestUrl).href : undefined, false, FLAT_NORMAL_PIXEL),
      loadSurfaceTexture(
        engine,
        spec.metallicSmoothness ? new URL(spec.metallicSmoothness, manifestUrl).href : undefined,
        false,
        WHITE_PIXEL
      ),
      loadSurfaceTexture(
        engine,
        spec.occlusion ? new URL(spec.occlusion, manifestUrl).href : undefined,
        false,
        WHITE_PIXEL
      ),
      loadLodDitherTexture(engine, lodDitherUrl),
      loadCoverageTextures(engine, spec, manifestUrl)
    ]);
    material.shaderData.setTexture(SurfaceMaterial._albedo, albedo);
    material.shaderData.setTexture(SurfaceMaterial._normal, normal);
    material.shaderData.setTexture(SurfaceMaterial._metallicSmoothness, metallicSmoothness);
    material.shaderData.setTexture(SurfaceMaterial._occlusion, occlusion);
    material.shaderData.setTexture(SurfaceMaterial._lodDither, lodDither);
    if (coverageTextures) {
      material.shaderData.setTexture(SurfaceMaterial._coverageAlbedo, coverageTextures.albedo);
      material.shaderData.setTexture(SurfaceMaterial._coverageNormal, coverageTextures.normal);
      material.shaderData.setTexture(
        SurfaceMaterial._coverageMetallicSmoothness,
        coverageTextures.metallicSmoothness
      );
      material.shaderData.setTexture(SurfaceMaterial._coverageMask, coverageTextures.mask);
    }
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

  /**
   * Selects the source cylindrical billboard vertex path for an impostor prototype.
   * @param enabled Whether object rotation is replaced by the camera-facing billboard basis.
   * @param shaderData Renderer-local shader data.
   */
  static setRendererBillboard(
    enabled: boolean,
    shaderData: { enableMacro(macro: ShaderMacro): void; disableMacro(macro: ShaderMacro): void }
  ): void {
    enabled ? shaderData.enableMacro(SurfaceMaterial._billboardMacro) : shaderData.disableMacro(SurfaceMaterial._billboardMacro);
  }

  /**
   * Binds the renderer transform relative to its surface prototype root.
   * @param spec Source renderer transform exported from the prototype.
   * @param shaderData Renderer-local shader data.
   */
  static setRendererTransform(spec: SurfacePrototypeRendererSpec, shaderData: ShaderData): void {
    shaderData.setVector3(SurfaceMaterial._localPosition, new Vector3(...spec.localPosition));
    shaderData.setVector4(SurfaceMaterial._localRotation, new Vector4(...spec.localRotation));
    shaderData.setVector3(SurfaceMaterial._localScale, new Vector3(...spec.localScale));
  }

  /**
   * Binds a signed Unity-compatible cross-fade factor for one renderer batch.
   * @param enabled Whether the fragment shader applies screen-space dithering.
   * @param factor Positive values fade out; negative values fade in.
   * @param shaderData Renderer-local shader data.
   */
  static setRendererLodFade(enabled: boolean, factor: number, shaderData: ShaderData): void {
    shaderData.setInt(SurfaceMaterial._lodFadeEnabled, enabled ? 1 : 0);
    shaderData.setFloat(SurfaceMaterial._lodFade, factor);
  }
}

async function loadCoverageTextures(
  engine: Engine,
  spec: SurfaceMaterialSpec,
  manifestUrl: string
): Promise<
  | {
      albedo: Texture2D;
      normal: Texture2D;
      metallicSmoothness: Texture2D;
      mask: Texture2D;
    }
  | undefined
> {
  const coverage = spec.coverage;
  if (!coverage) return undefined;
  const [albedo, normal, metallicSmoothness, mask] = await Promise.all([
    loadSurfaceTexture(engine, new URL(coverage.albedo, manifestUrl).href, true, WHITE_PIXEL),
    loadSurfaceTexture(engine, new URL(coverage.normal, manifestUrl).href, false, FLAT_NORMAL_PIXEL),
    loadSurfaceTexture(
      engine,
      coverage.metallicSmoothness
        ? new URL(coverage.metallicSmoothness, manifestUrl).href
        : undefined,
      false,
      WHITE_PIXEL
    ),
    loadSurfaceTexture(
      engine,
      coverage.mask ? new URL(coverage.mask, manifestUrl).href : undefined,
      false,
      WHITE_PIXEL
    )
  ]);
  return { albedo, normal, metallicSmoothness, mask };
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

async function loadLodDitherTexture(engine: Engine, url: string): Promise<Texture2D> {
  const texture = await engine.resourceManager.load<Texture2D>({
    type: AssetType.Texture,
    url,
    params: {
      isSRGBColorSpace: false,
      mipmap: false,
      wrapModeU: TextureWrapMode.Repeat,
      wrapModeV: TextureWrapMode.Repeat,
      filterMode: TextureFilterMode.Point
    }
  });
  if (!(texture instanceof Texture2D)) throw new Error(`[SurfaceMaterial] ${url} did not resolve to Texture2D`);
  return texture;
}

function colorVariationMode(mode: SurfaceMaterialSpec["colorVariation"]["mode"]): number {
  switch (mode) {
    case "world-noise-2d":
      return 0;
    case "world-noise-3d":
      return 1;
    case "vertex-gradient":
      return 2;
    case "uv-gradient":
      return 3;
  }
}
