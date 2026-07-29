import { Camera } from "../Camera";
import type { RenderStateElementMap } from "../BasicResources";
import { Engine } from "../Engine";
import { PipelinePass } from "../RenderPipeline/PipelinePass";
import { GLCapabilityType } from "../base/Constant";
import { CameraClearFlags } from "../enums/CameraClearFlags";
import { ColorWriteMask } from "../shader/enums/ColorWriteMask";
import { RenderStateElementKey } from "../shader/enums/RenderStateElementKey";
import { TextureFilterMode, TextureFormat, TextureWrapMode } from "../texture";
import { RenderTarget } from "../texture/RenderTarget";
import { CullingResults } from "./CullingResults";
import { PipelineUtils } from "./PipelineUtils";
import { RenderContext } from "./RenderContext";
import { PipelineStage } from "./enums/PipelineStage";
import { RenderQueueMaskType } from "./enums/RenderQueueMaskType";

const DEPTH_ONLY_RENDER_STATES = <RenderStateElementMap>{
  [RenderStateElementKey.BlendStateColorWriteMask0]: ColorWriteMask.None
};
/** @internal */
export const depthPrimingOnlyStage = "DepthPrimingOnly";

/**
 * @internal
 * Depth only pass.
 */
export class DepthOnlyPass extends PipelinePass {
  readonly supportDepthTexture: boolean;
  renderTarget: RenderTarget;
  private _ownsRenderTarget = false;

  constructor(engine: Engine) {
    super(engine);
    this.supportDepthTexture = engine._hardwareRenderer.canIUse(GLCapabilityType.depthTexture);
  }

  onConfig(camera: Camera, sharedRenderTarget?: RenderTarget): void {
    const engine = this.engine;
    if (sharedRenderTarget) {
      if (this._ownsRenderTarget) {
        engine._renderTargetPool.freeRenderTarget(this.renderTarget);
      }
      this.renderTarget = sharedRenderTarget;
      this._ownsRenderTarget = false;
      return;
    }

    if (this.renderTarget && !this._ownsRenderTarget) {
      this.renderTarget = null;
    }
    const { width, height } = camera.pixelViewport;

    const renderTarget = PipelineUtils.recreateRenderTargetIfNeeded(
      engine,
      this.renderTarget,
      width,
      height,
      null,
      engine._hardwareRenderer.isWebGL2 ? TextureFormat.Depth24 : TextureFormat.Depth24Stencil8,
      true,
      false,
      false,
      1,
      TextureWrapMode.Clamp,
      TextureFilterMode.Point
    );

    this.renderTarget = renderTarget;
    this._ownsRenderTarget = true;
  }

  override onRender(
    context: RenderContext,
    cullingResults: CullingResults,
    depthPrimingEnabled: boolean = false
  ): void {
    const engine = this.engine;
    const renderTarget = this.renderTarget;
    const camera = context.camera;
    const rhi = engine._hardwareRenderer;
    context.setRenderTarget(renderTarget, PipelineUtils.defaultViewport, 0, undefined, "depth-prepass");
    rhi.clearRenderTarget(engine, CameraClearFlags.Depth, null);

    engine._renderCount++;
    cullingResults.opaqueQueue.render(
      context,
      PipelineStage.DepthOnly,
      RenderQueueMaskType.No,
      DEPTH_ONLY_RENDER_STATES
    );
    cullingResults.alphaTestQueue.render(
      context,
      PipelineStage.DepthOnly,
      RenderQueueMaskType.No,
      DEPTH_ONLY_RENDER_STATES
    );
    if (depthPrimingEnabled) {
      cullingResults.opaqueQueue.render(
        context,
        depthPrimingOnlyStage,
        RenderQueueMaskType.No,
        DEPTH_ONLY_RENDER_STATES
      );
      cullingResults.alphaTestQueue.render(
        context,
        depthPrimingOnlyStage,
        RenderQueueMaskType.No,
        DEPTH_ONLY_RENDER_STATES
      );
    }

    camera.shaderData.setTexture(Camera._cameraDepthTextureProperty, this.renderTarget.depthTexture);
  }

  release(): void {
    const renderTarget = this.renderTarget;
    if (renderTarget && this._ownsRenderTarget) {
      this.engine._renderTargetPool.freeRenderTarget(renderTarget);
    }
    this.renderTarget = null;
    this._ownsRenderTarget = false;
  }
}
