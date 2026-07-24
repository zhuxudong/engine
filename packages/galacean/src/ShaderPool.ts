import { Engine, Shader, ShaderFactory, ShaderLanguage } from "@galacean/engine-core";
import {
  shaderLibrary,
  PBRSource,
  PBRWGSLSource,
  BlinnPhongSource,
  BlinnPhongWGSLSource,
  UnlitSource,
  UnlitWGSLSource,
  SpriteSource,
  SpriteWGSLSource,
  SpriteMaskSource,
  SpriteMaskWGSLSource,
  TextSource,
  TextWGSLSource,
  TrailSource,
  TrailWGSLSource,
  UIDefaultSource,
  UIDefaultWGSLSource,
  SkyboxSource,
  SkyboxWGSLSource,
  BackgroundTextureSource,
  BackgroundTextureWGSLSource,
  SkyProceduralSource,
  SkyProceduralWGSLSource,
  DepthOnlySource,
  DepthOnlyWGSLSource,
  ShadowCasterSource,
  ShadowCasterWGSLSource,
  BlitSource,
  BlitWGSLSource,
  BlitScreenSource,
  BlitScreenWGSLSource,
  ParticleSource,
  ParticleWGSLSource,
  ParticleFeedbackSource,
  ParticleFeedbackWGSLSource,
  UberSource,
  UberWGSLSource,
  FinalSRGBSource,
  FinalSRGBWGSLSource,
  FinalAntiAliasingSource,
  FinalAntiAliasingWGSLSource,
  BloomSource,
  BloomWGSLSource,
  ProbeDepthCaptureSource,
  ProbeDepthCaptureWGSLSource,
  ScalableAmbientOcclusionSource,
  ScalableAmbientOcclusionWGSLSource,
  GaussianSplatSource,
  GaussianSplatWGSLSource
} from "@galacean/engine-shader";

/**
 * Built-in shader pool. Lives in the `@galacean/engine` umbrella because the
 * specific set of bundled shaders is a property of the Galacean flavor of the
 * engine — `engine-core` is a generic runtime that knows nothing about which
 * shaders ship in the box.
 *
 * @internal
 */
export class ShaderPool {
  private static _registeredBackend?: "webgl" | "webgpu";

  static init(): void {
    // Register every entry of the built-in shader library so `#include` can resolve them.
    for (const item of shaderLibrary) {
      ShaderFactory.registerInclude(item.path, item.source);
    }
  }

  /**
   * Register built-in shaders from the precompiled artifact for the engine backend.
   *
   * @param engine - The engine whose backend selects the artifact set.
   */
  static registerShaders(engine: Engine): void {
    const backend = (engine as unknown as { _hardwareRenderer: { backend: "webgl" | "webgpu" } })._hardwareRenderer
      .backend;
    if (this._registeredBackend) {
      if (this._registeredBackend !== backend) {
        throw new Error(
          `Built-in shaders are already registered for ${this._registeredBackend}; reload before creating a ${backend} engine.`
        );
      }
      return;
    }

    const sources =
      backend === "webgpu"
        ? [
            BlitWGSLSource,
            BlitScreenWGSLSource,
            ShadowCasterWGSLSource,
            DepthOnlyWGSLSource,
            PBRWGSLSource,
            BlinnPhongWGSLSource,
            UnlitWGSLSource,
            SkyboxWGSLSource,
            SkyProceduralWGSLSource,
            BackgroundTextureWGSLSource,
            SpriteWGSLSource,
            SpriteMaskWGSLSource,
            TextWGSLSource,
            TrailWGSLSource,
            UIDefaultWGSLSource,
            ParticleWGSLSource,
            ParticleFeedbackWGSLSource,
            UberWGSLSource,
            FinalSRGBWGSLSource,
            FinalAntiAliasingWGSLSource,
            BloomWGSLSource,
            ProbeDepthCaptureWGSLSource,
            ScalableAmbientOcclusionWGSLSource,
            GaussianSplatWGSLSource
          ]
        : [
            // Pipeline / Blit shaders must be created first — material shaders UsePass from them
            BlitSource,
            BlitScreenSource,
            ShadowCasterSource,
            DepthOnlySource,
            // Material shaders
            PBRSource,
            BlinnPhongSource,
            UnlitSource,
            // Sky shaders
            SkyboxSource,
            SkyProceduralSource,
            BackgroundTextureSource,
            // 2D shaders
            SpriteSource,
            SpriteMaskSource,
            TextSource,
            TrailSource,
            UIDefaultSource,
            // Particle shaders
            ParticleSource,
            ParticleFeedbackSource,
            // PostProcess shaders
            UberSource,
            FinalSRGBSource,
            FinalAntiAliasingSource,
            BloomSource,
            // Probe baking shader
            ProbeDepthCaptureSource,
            // AO shader
            ScalableAmbientOcclusionSource,
            // Gaussian Splatting shader
            GaussianSplatSource
          ];

    for (const source of sources) {
      // @ts-ignore — `_createFromPrecompiled` is `Shader` @internal.
      const shader = Shader._createFromPrecompiled(source);
      if (backend === "webgpu") {
        for (let subShaderIndex = 0; subShaderIndex < source.subShaders.length; subShaderIndex++) {
          const sourcePasses = source.subShaders[subShaderIndex].passes;
          const passes = shader.subShaders[subShaderIndex].passes;
          for (let passIndex = 0; passIndex < sourcePasses.length; passIndex++) {
            const sourcePass = sourcePasses[passIndex];
            if (sourcePass.isUsePass) continue;
            // @ts-ignore — loader and shader pool bridge the internal target cache.
            passes[passIndex]._setShaderTarget(ShaderLanguage.WGSL, {
              vertex: "",
              fragment: "",
              vertexShaderInstructions: sourcePass.vertexShaderInstructions,
              fragmentShaderInstructions: sourcePass.fragmentShaderInstructions,
              reflection: sourcePass.reflection
            });
          }
        }
      }
    }

    // Configure the particle feedback pass's transform-feedback varyings.
    // The pass itself is later looked up via `Shader.find` inside
    // `ParticleTransformFeedbackSimulator`, so no caching needed here.
    const feedbackPass = Shader.find("Effect/ParticleFeedback").subShaders[0].passes[0];
    // @ts-ignore — `_feedbackVaryings` is `ShaderPass` @internal.
    feedbackPass._feedbackVaryings = ["v_FeedbackPosition", "v_FeedbackVelocity"];
    this._registeredBackend = backend;
  }
}
