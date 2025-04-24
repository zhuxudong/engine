import { EngineObject } from "./base";
import { Camera } from "./Camera";
import { Engine } from "./Engine";
import { Material } from "./material";
import { Blitter } from "./RenderPipeline";
import { PipelineUtils } from "./RenderPipeline/PipelineUtils";
import { Shader } from "./shader";
import blitVs from "./shaderlib/extra/Blit.vs.glsl";
import finalFs from "./shaderlib/extra/finalPost.glsl";
import sRGBFs from "./shaderlib/extra/FinalSRGB.glsl";
import { RenderTarget, Texture2D, TextureFilterMode, TextureWrapMode } from "./texture";

/**
 * @internal
 */
export class FinalPass extends EngineObject {
  private _sRGBmaterial: Material;
  private _finalMaterial: Material;
  private _swapRenderTarget: RenderTarget;

  constructor(engine: Engine) {
    super(engine);

    // SRGB Material
    const sRGBmaterial = new Material(engine, Shader.find("FinalSRGB"));
    const sRGBdepthState = sRGBmaterial.renderState.depthState;
    sRGBdepthState.enabled = false;
    sRGBdepthState.writeEnabled = false;

    // Final Material
    const finalMaterial = new Material(engine, Shader.find("FinalPost"));
    const finalDepthState = finalMaterial.renderState.depthState;
    finalDepthState.enabled = false;
    finalDepthState.writeEnabled = false;

    this._sRGBmaterial = sRGBmaterial;
    this._finalMaterial = finalMaterial;
  }

  onRender(camera: Camera, srcTexture: Texture2D, destTarget: RenderTarget): void {
    const engine = this.engine;
    const sRGBMaterial = this._sRGBmaterial;
    const pixelViewport = camera.pixelViewport;
    const swapRenderTarget = PipelineUtils.recreateRenderTargetIfNeeded(
      engine,
      this._swapRenderTarget,
      pixelViewport.width,
      pixelViewport.height,
      camera._getTargetColorTextureFormat(),
      null,
      false,
      false,
      false,
      1,
      TextureWrapMode.Clamp,
      TextureFilterMode.Bilinear
    );

    this._swapRenderTarget = swapRenderTarget;

    Blitter.blitTexture(engine, srcTexture, swapRenderTarget, 0, camera.viewport, sRGBMaterial);

    Blitter.blitTexture(
      engine,
      <Texture2D>swapRenderTarget.getColorTexture(),
      destTarget,
      0,
      camera.viewport,
      this._finalMaterial
    );
  }

  /**
   * @inheritdoc
   */
  override _onDestroy() {
    super._onDestroy();

    const swapRT = this._swapRenderTarget;
    if (swapRT) {
      swapRT.getColorTexture(0).destroy(true);
      swapRT.destroy(true);
      this._swapRenderTarget = null;
    }

    this._sRGBmaterial.destroy(true);
    this._sRGBmaterial = null;
  }
}

Shader.create("FinalSRGB", blitVs, sRGBFs);
Shader.create("FinalPost", blitVs, finalFs);
