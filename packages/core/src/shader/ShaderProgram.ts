import type { IShaderUniformBlock, IShaderUniformVariable } from "@galacean/engine-design";
import type { IHardwareRenderer, IPlatformShaderProgram } from "../renderingHardwareInterface";
import { Vector2, Vector3, Vector4 } from "@galacean/engine-math";
import { Engine } from "../Engine";
import { Logger } from "../base/Logger";
import { Texture } from "../texture";
import { ShaderData, ShaderPropertyValueType } from "./ShaderData";
import { ShaderProperty } from "./ShaderProperty";
import { ShaderUniform } from "./ShaderUniform";
import { ShaderUniformBlock } from "./ShaderUniformBlock";
import { ShaderBlockProperty } from "./ShaderBlockProperty";
import { GlobalUniformBlock } from "./GlobalUniformBlock";
import { ConstantBufferBindingPoint } from "./enums/ConstantBufferBindingPoint";
import { ShaderDataGroup } from "./enums/ShaderDataGroup";
import { InstanceBufferLayout, ShaderFactory } from "./ShaderFactory";

/**
 * Shader program, corresponding to the GPU shader program.
 * @internal
 */
export class ShaderProgram implements IPlatformShaderProgram {
  private static _counter: number = 0;
  private static _legacyUniformTypes?: Record<number, string>;

  private static _addLineNum(str: string) {
    const lines = str.split("\n");
    const limitLength = (lines.length + 1).toString().length + 6;
    let prefix;
    return lines
      .map((line, index) => {
        prefix = `0:${index + 1}`;
        if (prefix.length >= limitLength) return prefix.substring(0, limitLength) + line;

        for (let i = 0; i < limitLength - prefix.length; i++) prefix += " ";

        return prefix + line;
      })
      .join("\n");
  }

  id: number;

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

  attributeLocation: Record<string, GLint> = Object.create(null);
  uniformBlockIds: number[] = [];

  // @todo: move to RHI.
  private _isValid: boolean;
  private _engine: Engine;
  private _gl: WebGL2RenderingContext;
  private _glProgram: WebGLProgram | null;
  private _activeTextureUint: number = 0;
  private _groupConflictVersion: number = 0;
  private _uniformBlocks?: GlobalUniformBlock[];

  /**
   * Whether this shader program is valid.
   */
  get isValid(): boolean {
    return this._isValid;
  }

  constructor(
    engine: Engine,
    vertexSource: string,
    fragmentSource: string,
    transformFeedbackVaryings?: string[],
    uniformBlocks?: readonly IShaderUniformBlock[],
    instanceBindingName?: string,
    looseUniforms?: readonly IShaderUniformVariable[]
  ) {
    this._engine = engine;
    this._gl = engine._hardwareRenderer.gl;
    this._glProgram = this._createProgram(vertexSource, fragmentSource, transformFeedbackVaryings);

    if (this._glProgram) {
      this._isValid = true;
      try {
        if (uniformBlocks) this._bindGlobalBlockLayouts(uniformBlocks);
        this._recordLocation(looseUniforms);
        if (instanceBindingName) {
          engine._hardwareRenderer.tryBindUniformBlock(
            this._glProgram,
            instanceBindingName,
            ConstantBufferBindingPoint.RendererInstance
          );
        }
      } catch (error) {
        this.destroy();
        throw error;
      }
    } else {
      this._isValid = false;
    }

    this.id = ShaderProgram._counter++;
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
      data != null && uniform.applyFunc(uniform, data);
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
      value != null && uniform.applyFunc(uniform, value);
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
        uniform.applyFunc(uniform, uniform.textureDefault);
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

  /**
   * Bind this shader program.
   * @returns Whether the shader program is switched.
   */
  bind(): boolean {
    const rhi: IHardwareRenderer = this._engine._hardwareRenderer;
    if (rhi._currentBindShaderProgram !== this) {
      this._gl.useProgram(this._glProgram);
      rhi._currentBindShaderProgram = this;
      return true;
    } else {
      return false;
    }
  }

  /**
   * Destroy this shader program.
   */
  destroy(): void {
    if (this._uniformBlocks) {
      for (const block of this._uniformBlocks) block.release();
      this._uniformBlocks = undefined;
    }
    const gl = this._gl;
    this._glProgram && gl.deleteProgram(this._glProgram);
  }

  private _regroupUniformBlock(block: ShaderUniformBlock, group: ShaderDataGroup): void {
    const { constUniforms, textureUniforms } = block;
    constUniforms.length > 0 && this._regroupUniforms(constUniforms, group, false);
    textureUniforms.length > 0 && this._regroupUniforms(textureUniforms, group, true);
  }

  private _regroupUniforms(uniforms: ShaderUniform[], group: ShaderDataGroup, isTexture: boolean): void {
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

  private _uploadTexture(uniform: ShaderUniform, value: ShaderPropertyValueType | undefined): void {
    if (
      value &&
      ((<Texture>value).destroyed === false || (Array.isArray(value) && Array.isArray(uniform.textureDefault)))
    ) {
      uniform.applyFunc(uniform, value);
    } else {
      uniform.applyFunc(uniform, uniform.textureDefault);
    }
  }

  private _groupingUniform(uniform: ShaderUniform, property: ShaderProperty, isTexture: boolean): void {
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

  /**
   * Init and link program with shader.
   */
  private _createProgram(
    vertexSource: string,
    fragmentSource: string,
    transformFeedbackVaryings?: string[]
  ): WebGLProgram | null {
    const gl = this._gl;

    // Create and compile shader
    const vertexShader = this._createShader(gl.VERTEX_SHADER, vertexSource);
    if (!vertexShader) {
      return null;
    }

    const fragmentShader = this._createShader(gl.FRAGMENT_SHADER, fragmentSource);
    if (!fragmentShader) {
      return null;
    }

    // Create program and link shader
    const program = gl.createProgram();
    if (!program) {
      return null;
    }

    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);

    // Set Transform Feedback varyings before linking
    if (transformFeedbackVaryings?.length) {
      gl.transformFeedbackVaryings(program, transformFeedbackVaryings, gl.INTERLEAVED_ATTRIBS);
    }

    gl.linkProgram(program);
    gl.validateProgram(program);

    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);

    if (Logger.isEnabled && !gl.getProgramParameter(program, gl.LINK_STATUS) && !gl.isContextLost()) {
      Logger.error(
        `Could not link WebGL program\n\n` +
          `Shader error: ${gl.getError()}\n\n` +
          `Validate status: ${gl.getProgramParameter(program, gl.VALIDATE_STATUS)}\n\n` +
          `Program information log: ${gl.getProgramInfoLog(program)}`
      );
      gl.deleteProgram(program);
      return null;
    }

    return program;
  }

  private _createShader(shaderType: number, shaderSource: string): WebGLShader | null {
    const gl = this._gl;
    const shader = gl.createShader(shaderType);

    if (!shader) {
      return null;
    }

    gl.shaderSource(shader, shaderSource);
    gl.compileShader(shader);

    if (Logger.isEnabled && !gl.getShaderParameter(shader, gl.COMPILE_STATUS) && !gl.isContextLost()) {
      console.warn(
        `Could not compile WebGL shader\n\n` +
          `Shader type: ${shaderType == gl.VERTEX_SHADER ? "vertex" : "fragment"}\n\n` +
          `Shader information log:\n${gl.getShaderInfoLog(shader)}\n` +
          `Shader source:\n${ShaderProgram._addLineNum(shaderSource)}`
      );
      gl.deleteShader(shader);
      return null;
    }

    return shader;
  }

  /**
   * record the location of uniform/attribute.
   */
  private _recordLocation(looseUniforms?: readonly IShaderUniformVariable[]): void {
    const gl = this._gl;
    const program = this._glProgram!;
    const uniformInfos = looseUniforms ?? this._getUniformInfos();
    const attributeInfos = this._getAttributeInfos();
    const basicResources = this._engine._basicResources;

    uniformInfos.forEach(({ name, arrayLength, type }) => {
      // Numeric loose arrays can defer a GLSL-only constant bound to the driver.
      const isArray = arrayLength !== 0;
      const size = arrayLength;
      let isTexture = false;

      const location = gl.getUniformLocation(program, name);
      // UBO members have no individual location, skip them
      if (location === null) return;

      const shaderUniform = new ShaderUniform(this._engine);
      shaderUniform.name = name;
      const property = ShaderProperty.getByName(name);
      shaderUniform.propertyId = property._uniqueId;
      shaderUniform.location = location;

      switch (type) {
        case "float":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload1fv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload1f;
            shaderUniform.cacheValue = 0;
          }
          break;
        case "vec2":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload2fv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload2f;
            shaderUniform.cacheValue = new Vector2(0, 0);
          }
          break;
        case "vec3":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload3fv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload3f;
            shaderUniform.cacheValue = new Vector3(0, 0, 0);
          }
          break;
        case "vec4":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload4fv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload4f;
            shaderUniform.cacheValue = new Vector4(0, 0, 0, 0);
          }
          break;
        case "bool":
        case "int":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload1iv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload1i;
            shaderUniform.cacheValue = 0;
          }
          break;
        case "bvec2":
        case "ivec2":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload2iv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload2i;
            shaderUniform.cacheValue = new Vector2(0, 0);
          }
          break;
        case "bvec3":
        case "ivec3":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload3iv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload3i;
            shaderUniform.cacheValue = new Vector3(0, 0, 0);
          }
          break;
        case "bvec4":
        case "ivec4":
          if (isArray) {
            shaderUniform.applyFunc = shaderUniform.upload4iv;
          } else {
            shaderUniform.applyFunc = shaderUniform.upload4i;
            shaderUniform.cacheValue = new Vector4(0, 0, 0);
          }
          break;
        case "mat2":
          shaderUniform.applyFunc = shaderUniform.uploadMat2;
          break;
        case "mat3":
          shaderUniform.applyFunc = shaderUniform.uploadMat3;
          break;
        case "mat4":
          shaderUniform.applyFunc = isArray ? shaderUniform.uploadMat4v : shaderUniform.uploadMat4;
          break;
        case "mat2x3":
          shaderUniform.applyFunc = shaderUniform.uploadMat2x3;
          break;
        case "mat2x4":
          shaderUniform.applyFunc = shaderUniform.uploadMat2x4;
          break;
        case "mat3x2":
          shaderUniform.applyFunc = shaderUniform.uploadMat3x2;
          break;
        case "mat3x4":
          shaderUniform.applyFunc = shaderUniform.uploadMat3x4;
          break;
        case "mat4x2":
          shaderUniform.applyFunc = shaderUniform.uploadMat4x2;
          break;
        case "mat4x3":
          shaderUniform.applyFunc = shaderUniform.uploadMat4x3;
          break;
        case "sampler2D":
        case "samplerCube":
        case "usampler2D":
        case "sampler2DArray":
        case "sampler2DShadow":
          let defaultTexture: Texture;
          switch (type) {
            case "sampler2D":
              defaultTexture = basicResources.whiteTexture2D;
              break;
            case "samplerCube":
              defaultTexture = basicResources.whiteTextureCube;
              break;
            case "usampler2D":
              defaultTexture = basicResources.uintWhiteTexture2D;
              break;
            case "sampler2DArray":
              defaultTexture = basicResources.whiteTexture2DArray;
              break;
            case "sampler2DShadow":
              defaultTexture = this._engine._depthTexture2D;
              shaderUniform.textureUseCompareMode = true;
              break;
          }

          isTexture = true;
          if (isArray) {
            const defaultTextures = new Array<Texture>(size);
            const textureIndices = new Int32Array(size);
            const glTextureIndices = new Array<number>(size);

            for (let i = 0; i < size; i++) {
              defaultTextures[i] = defaultTexture;
              textureIndices[i] = this._activeTextureUint;
              glTextureIndices[i] = gl.TEXTURE0 + this._activeTextureUint++;
            }
            shaderUniform.textureDefault = defaultTextures;
            shaderUniform.textureIndex = glTextureIndices;
            shaderUniform.applyFunc = shaderUniform.uploadTextureArray;
            this.bind();
            gl.uniform1iv(location, textureIndices);
          } else {
            const glTextureIndex = gl.TEXTURE0 + this._activeTextureUint;
            shaderUniform.textureDefault = defaultTexture;
            shaderUniform.textureIndex = glTextureIndex;
            shaderUniform.applyFunc = shaderUniform.uploadTexture;
            this.bind();
            gl.uniform1i(location, this._activeTextureUint++);
          }
          break;
        default:
          throw new Error("Unsupported uniform type");
      }

      this._groupingUniform(shaderUniform, property, isTexture);
    });
    this._groupConflictVersion = ShaderProperty._groupConflictVersion;

    attributeInfos.forEach(({ name }) => {
      this.attributeLocation[name] = gl.getAttribLocation(program, name);
    });

    // Compiled variants already assigned every block from their layout, including instancing.
    if (looseUniforms) return;
    // Record historical uniform block indices and bind legacy binding points.
    const bindingMap = ShaderFactory.uniformBlockBindingMap;
    const blockCount = gl.getProgramParameter(program, gl.ACTIVE_UNIFORM_BLOCKS) ?? 0;
    for (let i = 0; i < blockCount; i++) {
      const id = ShaderBlockProperty.getByName(gl.getActiveUniformBlockName(program, i)!)._uniqueId;
      this.uniformBlockIds[i] = id;
      const bindingPoint = bindingMap[id];
      if (bindingPoint !== undefined) {
        gl.uniformBlockBinding(program, i, bindingPoint);
      }
    }
  }

  private _bindGlobalBlockLayouts(layouts: readonly IShaderUniformBlock[]): void {
    const rhi = this._engine._hardwareRenderer;
    let nextAutoBinding = ConstantBufferBindingPoint.Auto;
    const used = new Set<number>();
    for (const layout of layouts) {
      const binding = layout.name === "Auto" ? nextAutoBinding++ : ConstantBufferBindingPoint[layout.name];
      if (!rhi.tryBindUniformBlock(this._glProgram!, layout.bindingName ?? layout.name, binding)) continue;
      if (used.has(binding)) {
        throw new Error(`Duplicate global uniform block '${layout.name}'.`);
      }
      used.add(binding);
      (this._uniformBlocks ??= []).push(GlobalUniformBlock.acquire(this._engine, layout, binding));
    }
  }

  private _getUniformInfos(): IShaderUniformVariable[] {
    const gl = this._gl;
    const program = this._glProgram!;
    // Only historical assets require driver enumeration. Their types are converted
    // once to the same representation as compiler-reflected sampler and loose fields.
    const types = (ShaderProgram._legacyUniformTypes ??= {
      [gl.FLOAT]: "float",
      [gl.FLOAT_VEC2]: "vec2",
      [gl.FLOAT_VEC3]: "vec3",
      [gl.FLOAT_VEC4]: "vec4",
      [gl.BOOL]: "bool",
      [gl.INT]: "int",
      [gl.BOOL_VEC2]: "bvec2",
      [gl.INT_VEC2]: "ivec2",
      [gl.BOOL_VEC3]: "bvec3",
      [gl.INT_VEC3]: "ivec3",
      [gl.BOOL_VEC4]: "bvec4",
      [gl.INT_VEC4]: "ivec4",
      [gl.FLOAT_MAT2]: "mat2",
      [gl.FLOAT_MAT3]: "mat3",
      [gl.FLOAT_MAT4]: "mat4",
      [gl.FLOAT_MAT2x3]: "mat2x3",
      [gl.FLOAT_MAT2x4]: "mat2x4",
      [gl.FLOAT_MAT3x2]: "mat3x2",
      [gl.FLOAT_MAT3x4]: "mat3x4",
      [gl.FLOAT_MAT4x2]: "mat4x2",
      [gl.FLOAT_MAT4x3]: "mat4x3",
      [gl.SAMPLER_2D]: "sampler2D",
      [gl.SAMPLER_CUBE]: "samplerCube",
      [gl.UNSIGNED_INT_SAMPLER_2D]: "usampler2D",
      [gl.SAMPLER_2D_ARRAY]: "sampler2DArray",
      [gl.SAMPLER_2D_SHADOW]: "sampler2DShadow"
    });
    const count = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS) ?? 0;
    const infos: IShaderUniformVariable[] = [];
    for (let i = 0; i < count; ++i) {
      const { name, size, type } = gl.getActiveUniform(program, i)!;
      const isArray = name.endsWith("[0]");
      infos.push({ name: isArray ? name.slice(0, -3) : name, type: types[type], arrayLength: isArray ? size : 0 });
    }
    return infos;
  }

  private _getAttributeInfos(): WebGLActiveInfo[] {
    const gl = this._gl;
    const program = this._glProgram!;
    const attributeInfos = new Array<WebGLActiveInfo>();

    // attributeCount is `null` when context lost.
    const attributeCount = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES) ?? 0;
    for (let i = 0; i < attributeCount; ++i) {
      const info = gl.getActiveAttrib(program, i)!;
      attributeInfos[i] = info;
    }

    return attributeInfos;
  }
}
