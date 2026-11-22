import type { IShaderUniformBlock } from "@galacean/engine-design";
import type { IPlatformShaderProgram, IPlatformShaderSource, IPlatformUniform } from "../renderingHardwareInterface";
import type { Engine } from "../Engine";
import { Texture } from "../texture";
import { TextureFormat } from "../texture/enums/TextureFormat";
import { GLCapabilityType } from "../base/Constant";
import { ShaderData, ShaderPropertyValueType } from "./ShaderData";
import { ShaderProperty } from "./ShaderProperty";
import { ShaderUniformBlock } from "./ShaderUniformBlock";
import { GlobalUniformBlock } from "./GlobalUniformBlock";
import { ConstantBufferBindingPoint } from "./enums/ConstantBufferBindingPoint";
import { ShaderDataGroup } from "./enums/ShaderDataGroup";
import type { InstanceBufferLayout } from "./ShaderFactory";

/** Resolves ShaderData ownership and submits compiler-defined ranges to a native program. */
export class ShaderProgram {
  readonly sceneUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();
  readonly cameraUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();
  readonly rendererUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();
  readonly materialUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();
  readonly renderElementUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();
  readonly otherUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();
  readonly multiGroupUniformBlock: ShaderUniformBlock = new ShaderUniformBlock();

  /** @internal */
  _uploadRenderCount: number = -1;
  /** @internal */
  _uploadSceneId: number = -1;
  /** @internal */
  _uploadCameraId: number = -1;
  /** @internal */
  _uploadRendererId: number = -1;
  /** @internal */
  _uploadMaterialId: number = -1;

  /** @internal */
  _instanceLayout: InstanceBufferLayout | null = null;


  readonly _platformProgram: IPlatformShaderProgram;
  get id(): number { return this._platformProgram.id; }
  get attributeLocation(): Record<string, number> { return this._platformProgram.attributeLocation; }
  get uniformBlockIds(): readonly number[] { return this._platformProgram.uniformBlockIds; }
  get isValid(): boolean { return this._platformProgram.isValid; }
  private _groupConflictVersion = 0;
  private _uniformBlocks?: GlobalUniformBlock[];
  /** @internal Floating-point sampler inputs that can also read unfilterable resources. */
  readonly _filterableTextures?: ShaderProperty[];
  private readonly _float32Filterable: boolean;

  constructor(private _engine: Engine, source: IPlatformShaderSource, uniformBlocks?: readonly IShaderUniformBlock[], instanceBindingName?: string) {
    const platform = (this._platformProgram = _engine._hardwareRenderer.createPlatformShaderProgram(_engine, source));
    if (source.reflection) {
      this._float32Filterable = _engine._hardwareRenderer.canIUse(GLCapabilityType.textureFloatLinear);
      this._filterableTextures = source.reflection.textures.filter((texture) => texture.sampleType === "float").map((texture) => ShaderProperty.getByName(texture.name));
    }
    if (!platform.isValid) return;
    try {
      // WGSL reflection also describes blocks recovered from historical .shaderc assets.
      if (source.reflection) {
        uniformBlocks = source.reflection.uniformBlocks.filter((block) => block.name !== "Instance").sort((a,b) => a.physicalBinding - b.physicalBinding) as IShaderUniformBlock[];
      }
      if (uniformBlocks) this._bindGlobalBlockLayouts(uniformBlocks);
      if (instanceBindingName) platform.bindUniformBlock(instanceBindingName, ConstantBufferBindingPoint.RendererInstance);
      for (const uniform of platform.uniforms) {
        this._groupingUniform(uniform, ShaderProperty._propertyIdMap[uniform.propertyId], uniform.isTexture);
      }
      this._groupConflictVersion = ShaderProperty._groupConflictVersion;
    } catch (error) {
      this.destroy();
      throw error;
    }
  }

  /** @internal Inspect the resolved texture since a material or renderer can override its format. */
  _usesUnfilterableTexture(property: ShaderProperty, scene?: ShaderData, camera?: ShaderData, renderer?: ShaderData, material?: ShaderData, element?: ShaderData): boolean {
    const texture = ShaderData._findValue(property._uniqueId, scene, camera, renderer, material, element, property._groups) as Texture | undefined;
    if (!texture) return false;
    return texture._isDepthTexture || (!this._float32Filterable && (texture.format === TextureFormat.R32_SFloat || texture.format === TextureFormat.R32G32_SFloat || texture.format === TextureFormat.R32G32B32A32_SFloat));
  }

  /**
   * Upload all shader data in shader uniform block.
   * @param uniformBlock - shader Uniform block
   * @param shaderData - shader data
   */
  uploadAll(uniformBlock: ShaderUniformBlock, shaderData: ShaderData): void {
    this.uploadUniforms(uniformBlock, shaderData);
    this.uploadTextures(uniformBlock, shaderData);
  }

  /**
   * Upload constant shader data in shader uniform block.
   * @param uniformBlock - shader Uniform block
   * @param shaderData - shader data
   */
  uploadUniforms(uniformBlock: ShaderUniformBlock, shaderData: ShaderData): void {
    const propertyValueMap = shaderData._propertyValueMap;
    const constUniforms = uniformBlock.constUniforms;

    for (let i = 0, n = constUniforms.length; i < n; i++) {
      const uniform = constUniforms[i];
      const data = propertyValueMap[uniform.propertyId];
      data != null && uniform.apply(data);
    }
  }

  /**
   * Upload texture shader data in shader uniform block.
   * @param uniformBlock - shader Uniform block
   * @param shaderData - shader data
   */
  uploadTextures(uniformBlock: ShaderUniformBlock, shaderData: ShaderData): void {
    const propertyValueMap = shaderData._propertyValueMap;
    const textureUniforms = uniformBlock.textureUniforms;
    // textureUniforms property maybe null if ShaderUniformBlock not contain any texture.
    if (textureUniforms) {
      for (let i = 0, n = textureUniforms.length; i < n; i++) {
        const uniform = textureUniforms[i];
        this._uploadTexture(uniform, propertyValueMap[uniform.propertyId]);
      }
    }
  }

  /**
   * Bind global blocks and resolve uniforms shared by multiple shader data groups.
   */
  uploadSharedUniforms(
    sceneData: ShaderData,
    cameraData: ShaderData,
    rendererData?: ShaderData,
    materialData?: ShaderData,
    renderElementData?: ShaderData
  ): void {
    this.bindUniformBlocks(sceneData, cameraData, rendererData, materialData, renderElementData);
    const { constUniforms, textureUniforms } = this.multiGroupUniformBlock;
    for (let i = 0, n = constUniforms.length; i < n; i++) {
      const uniform = constUniforms[i];
      const value = ShaderData._findValue(
        uniform.propertyId,
        sceneData,
        cameraData,
        rendererData,
        materialData,
        renderElementData
      );
      value != null && uniform.apply(value);
    }
    for (let i = 0, n = textureUniforms.length; i < n; i++) {
      const uniform = textureUniforms[i];
      const value = ShaderData._findValue(
        uniform.propertyId,
        sceneData,
        cameraData,
        rendererData,
        materialData,
        renderElementData
      );
      this._uploadTexture(uniform, value);
    }
  }

  /** Bind the compiler-selected ranges for a draw or a renderer-only transform-feedback step. */
  bindUniformBlocks(
    scene: ShaderData | undefined,
    camera: ShaderData | undefined,
    renderer?: ShaderData,
    material?: ShaderData,
    element?: ShaderData
  ): void {
    const blocks = this._uniformBlocks;
    if (blocks) {
      for (let i = 0; i < blocks.length; ++i) blocks[i].bind(scene, camera, renderer, material, element);
    }
  }

  /**
   * Upload ungroup texture shader data in shader uniform block.
   */
  uploadUnGroupTextures(): void {
    const textureUniforms = this.otherUniformBlock.textureUniforms;
    // textureUniforms property maybe null if ShaderUniformBlock not contain any texture.
    if (textureUniforms) {
      for (let i = 0, n = textureUniforms.length; i < n; i++) {
        const uniform = textureUniforms[i];
        uniform.apply(uniform.textureDefault!);
      }
    }
  }

  /**
   * Regroup uniform blocks when shader property groups change.
   */
  regroupUniformBlocks(): void {
    const conflictVersion = ShaderProperty._groupConflictVersion;
    if (this._groupConflictVersion !== conflictVersion) {
      this._groupConflictVersion = conflictVersion;
      this._regroupUniformBlock(this.sceneUniformBlock, ShaderDataGroup.Scene);
      this._regroupUniformBlock(this.cameraUniformBlock, ShaderDataGroup.Camera);
      this._regroupUniformBlock(this.rendererUniformBlock, ShaderDataGroup.Renderer);
      this._regroupUniformBlock(this.materialUniformBlock, ShaderDataGroup.Material);
      this._regroupUniformBlock(this.renderElementUniformBlock, ShaderDataGroup.RenderElement);
    }
    this._regroupUniformBlock(this.otherUniformBlock, ShaderDataGroup.None);
  }

  bind(): boolean { return this._platformProgram.bind(); }

  destroy(): void {
    if (this._uniformBlocks) {
      for (const block of this._uniformBlocks) block.release();
      this._uniformBlocks = undefined;
    }
    this._platformProgram.destroy();
  }

  private _regroupUniformBlock(block: ShaderUniformBlock, group: ShaderDataGroup): void {
    const { constUniforms, textureUniforms } = block;
    constUniforms.length > 0 && this._regroupUniforms(constUniforms, group, false);
    textureUniforms.length > 0 && this._regroupUniforms(textureUniforms, group, true);
  }

  private _regroupUniforms(uniforms: IPlatformUniform[], group: ShaderDataGroup, isTexture: boolean): void {
    const propertyIdMap = ShaderProperty._propertyIdMap;
    for (let i = uniforms.length - 1; i >= 0; i--) {
      const uniform = uniforms[i];
      const property = propertyIdMap[uniform.propertyId];
      if (property._groups !== group) {
        uniforms.splice(i, 1);
        this._groupingUniform(uniform, property, isTexture);
      }
    }
  }

  private _uploadTexture(uniform: IPlatformUniform, value: ShaderPropertyValueType | undefined): void {
    if (
      value &&
      ((<Texture>value).destroyed === false || (Array.isArray(value) && Array.isArray(uniform.textureDefault)))
    ) {
      uniform.apply(value);
    } else {
      uniform.apply(uniform.textureDefault!);
    }
  }

  private _groupingUniform(uniform: IPlatformUniform, property: ShaderProperty, isTexture: boolean): void {
    let block: ShaderUniformBlock;
    switch (property._groups) {
      case ShaderDataGroup.None:
        block = this.otherUniformBlock;
        break;
      case ShaderDataGroup.Scene:
        block = this.sceneUniformBlock;
        break;
      case ShaderDataGroup.Camera:
        block = this.cameraUniformBlock;
        break;
      case ShaderDataGroup.Renderer:
        block = this.rendererUniformBlock;
        break;
      case ShaderDataGroup.Material:
        block = this.materialUniformBlock;
        break;
      case ShaderDataGroup.RenderElement:
        block = this.renderElementUniformBlock;
        break;
      default:
        block = this.multiGroupUniformBlock;
    }
    (isTexture ? block.textureUniforms : block.constUniforms).push(uniform);
  }

  private _bindGlobalBlockLayouts(layouts: readonly IShaderUniformBlock[]): void {
    let nextAutoBinding = ConstantBufferBindingPoint.Auto;
    const used = new Set<number>();
    for (const layout of layouts) {
      const binding = layout.name === "Auto" ? nextAutoBinding++ : ConstantBufferBindingPoint[layout.name];
      if (!this._platformProgram.bindUniformBlock(layout.bindingName ?? layout.name, binding)) continue;
      if (used.has(binding)) {
        throw new Error(`Duplicate global uniform block '${layout.name}'.`);
      }
      used.add(binding);
      (this._uniformBlocks ??= []).push(GlobalUniformBlock.acquire(this._engine, layout, binding));
    }
  }

}
