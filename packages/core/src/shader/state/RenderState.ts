import { DataObject } from "../../base/DataObject";
import { ShaderData, ShaderProperty } from "..";
import { RenderStateElementMap } from "../../BasicResources";
import { Engine } from "../../Engine";
import { RenderQueueType } from "../enums/RenderQueueType";
import { RenderStateElementKey } from "../enums/RenderStateElementKey";
import { BlendState } from "./BlendState";
import { DepthState } from "./DepthState";
import { RasterState } from "./RasterState";
import { StencilState } from "./StencilState";

/**
 * Render state.
 */
export class RenderState extends DataObject {
  /** Blend state. */
  readonly blendState: BlendState = new BlendState();
  /** Depth state. */
  readonly depthState: DepthState = new DepthState();
  /** Stencil state. */
  readonly stencilState: StencilState = new StencilState();
  /** Raster state. */
  readonly rasterState: RasterState = new RasterState();

  /** Render queue type. */
  renderQueueType: RenderQueueType = RenderQueueType.Opaque;

  /**
   * @internal
   */
  _applyStates(
    engine: Engine,
    frontFaceInvert: boolean,
    renderStateDataMap: Record<number, ShaderProperty>,
    shaderData: ShaderData,
    customRenderStates?: RenderStateElementMap | null,
    renderElementData?: ShaderData
  ): void {
    const resolved = this._resolve(engine, renderStateDataMap, shaderData, renderElementData);
    engine._hardwareRenderer.applyRenderState(
      resolved, engine._lastRenderState, engine._renderContext.flipProjection ? !frontFaceInvert : frontFaceInvert, customRenderStates
    );
  }

  /** @internal Resolve pass inputs without mutating shared authored state. */
  _resolve(engine: Engine, renderStateDataMap: Record<number, ShaderProperty>, shaderData: ShaderData, renderElementData?: ShaderData): RenderState {
    let resolved: RenderState = this;
    let variable = false;
    for (const key in renderStateDataMap) {
      if (renderStateDataMap[key]) {
        variable = true;
        break;
      }
    }
    const context = engine._renderContext;
    if (variable || context.shadowDepthBias) {
      resolved = engine._resolvedRenderState;
      const blend = resolved.blendState.targetBlendState, sourceBlend = this.blendState.targetBlendState;
      blend.enabled = sourceBlend.enabled;
      blend.colorBlendOperation = sourceBlend.colorBlendOperation;
      blend.alphaBlendOperation = sourceBlend.alphaBlendOperation;
      blend.sourceColorBlendFactor = sourceBlend.sourceColorBlendFactor;
      blend.sourceAlphaBlendFactor = sourceBlend.sourceAlphaBlendFactor;
      blend.destinationColorBlendFactor = sourceBlend.destinationColorBlendFactor;
      blend.destinationAlphaBlendFactor = sourceBlend.destinationAlphaBlendFactor;
      blend.colorWriteMask = sourceBlend.colorWriteMask;
      resolved.blendState.blendColor.copyFrom(this.blendState.blendColor);
      resolved.blendState.alphaToCoverage = this.blendState.alphaToCoverage;
      const depth = resolved.depthState, sourceDepth = this.depthState;
      depth.enabled = sourceDepth.enabled;
      depth.compareFunction = sourceDepth.compareFunction;
      depth.writeEnabled = sourceDepth.writeEnabled;
      const stencil = resolved.stencilState, sourceStencil = this.stencilState;
      stencil.enabled = sourceStencil.enabled;
      stencil.referenceValue = sourceStencil.referenceValue;
      stencil.mask = sourceStencil.mask;
      stencil.writeMask = sourceStencil.writeMask;
      stencil.compareFunctionFront = sourceStencil.compareFunctionFront;
      stencil.compareFunctionBack = sourceStencil.compareFunctionBack;
      stencil.passOperationFront = sourceStencil.passOperationFront;
      stencil.passOperationBack = sourceStencil.passOperationBack;
      stencil.failOperationFront = sourceStencil.failOperationFront;
      stencil.failOperationBack = sourceStencil.failOperationBack;
      stencil.zFailOperationFront = sourceStencil.zFailOperationFront;
      stencil.zFailOperationBack = sourceStencil.zFailOperationBack;
      const raster = resolved.rasterState, sourceRaster = this.rasterState;
      raster.cullMode = sourceRaster.cullMode;
      raster.depthBias = sourceRaster.depthBias;
      raster.slopeScaledDepthBias = sourceRaster.slopeScaledDepthBias;
      resolved.blendState._applyShaderDataValue(renderStateDataMap, shaderData, renderElementData);
      resolved.depthState._applyShaderDataValue(renderStateDataMap, shaderData);
      resolved.stencilState._applyShaderDataValue(renderStateDataMap, shaderData);
      resolved.rasterState._applyShaderDataValue(renderStateDataMap, shaderData);
      if (context.shadowDepthBias) {
        resolved.rasterState.depthBias = 1;
        resolved.rasterState.slopeScaledDepthBias = 1;
      }
    }
    return resolved;
  }

  /**
   * @internal
   */
  _getRenderQueueByShaderData(
    renderStateDataMap: Record<number, ShaderProperty>,
    shaderData: ShaderData
  ): RenderQueueType {
    const renderQueueTypeProp = renderStateDataMap[RenderStateElementKey.RenderQueueType];
    if (renderQueueTypeProp !== undefined) {
      const renderQueueType = shaderData.getFloat(renderQueueTypeProp);
      if (renderQueueType !== undefined) return renderQueueType;
    }
    return this.renderQueueType;
  }
}
