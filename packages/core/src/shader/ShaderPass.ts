import {
  finalizeShaderUniforms,
  type IShaderUniformBlock,
  type IShaderUniformPlan,
  type IShaderUniformSelection,
  type IShaderUniformVariable,
  type IWebGPUShaderProgram,
  type ShaderInstruction
} from "@galacean/engine-design";
import { Engine } from "../Engine";
import { InstanceBuffer } from "../RenderPipeline/InstanceBuffer";
import { PipelineStage } from "../RenderPipeline/enums/PipelineStage";
import { InstanceBufferLayout, ShaderFactory } from "./ShaderFactory";
import { ShaderMacro } from "./ShaderMacro";
import { ShaderMacroCollection } from "./ShaderMacroCollection";
import { ShaderPart } from "./ShaderPart";
import { ShaderProgramMap } from "./ShaderProgramMap";
import { ShaderProgram } from "./ShaderProgram";
import type { IPlatformShaderSource } from "../renderingHardwareInterface";
import type { Primitive } from "../graphic/Primitive";
import type { Mesh } from "../graphic/Mesh";
import type { Material } from "../material/Material";
import type { RenderTarget } from "../texture/RenderTarget";
import type { ShaderData } from "./ShaderData";
import { ShaderProperty } from "./ShaderProperty";
import { ShaderLanguage } from "./enums/ShaderLanguage";
import { ShaderMacroProcessor } from "./ShaderMacroProcessor";
import { RenderState } from "./state/RenderState";

const precisionStr = `
    precision highp float;
    precision highp int;
    `;

/**
 * Shader pass containing vertex and fragment source.
 */
export class ShaderPass extends ShaderPart {
  /** @internal */
  static _shaderPassCounter: number = 0;
  private static _shaderMacroList: ShaderMacro[] = [];
  private static _macroMap: Map<string, string> = new Map();

  /** @internal - Flat instruction array for vertex shader. */
  _vertexShaderInstructions: ShaderInstruction[];
  /** @internal */
  _fragmentShaderInstructions: ShaderInstruction[];

  /** @internal */
  _shaderPassId: number = 0;

  /** @internal Pass-level render state — always present, populated from ShaderLab declarations. */
  _renderState: RenderState = new RenderState();
  /** @internal */
  _renderStateDataMap: Record<number, ShaderProperty> = {};
  /** @internal */
  _shaderProgramMaps: ShaderProgramMap[] = [];

  private readonly _vertexOutputNames?: Readonly<Record<string, string>>;
  private readonly _uniformBlocks?: readonly IShaderUniformBlock[];
  private readonly _uniformPlan?: IShaderUniformPlan;
  private readonly _wgsl?: IWebGPUShaderProgram;

  /**
   * Create a shader pass from precompiled instructions.
   * @param name - Shader pass name
   * @param vertexShaderInstructions - Precompiled vertex instruction array
   * @param fragmentShaderInstructions - Precompiled fragment instruction array
   * @param _platformTarget - Target shader language
   * @param tags - Tags
   * @param vertexOutputNames - Source output names mapped to generated GLSL names
   * @param uniformBlocks - Explicit global uniform block layouts from the compiler
   * @param uniformPlan - Typed sites in the instruction streams used to specialize this pass
   */
  constructor(
    name: string,
    vertexShaderInstructions: ShaderInstruction[],
    fragmentShaderInstructions: ShaderInstruction[],
    _platformTarget: ShaderLanguage,
    tags?: Record<string, number | string | boolean>,
    vertexOutputNames?: Readonly<Record<string, string>>,
    uniformBlocks?: readonly IShaderUniformBlock[],
    uniformPlan?: IShaderUniformPlan,
    wgsl?: IWebGPUShaderProgram
  ) {
    super();
    this._shaderPassId = ShaderPass._shaderPassCounter++;

    this._name = name;
    this._vertexShaderInstructions = vertexShaderInstructions;
    this._fragmentShaderInstructions = fragmentShaderInstructions;
    this._vertexOutputNames = vertexOutputNames;
    this._uniformBlocks = uniformBlocks;
    this._uniformPlan = uniformPlan;
    this._wgsl = wgsl;

    const mergedTags = { pipelineStage: PipelineStage.Forward, ...tags };
    for (const key in mergedTags) {
      this.setTag(key, mergedTags[key]);
    }
  }

  /**
   * @internal
   */
  _getShaderProgram(
    engine: Engine,
    macroCollection: ShaderMacroCollection,
    feedbackVaryings?: string[],
    primitive?: Primitive,
    renderer?: ShaderData,
    material?: ShaderData,
    element?: ShaderData
  ): ShaderProgram {
    let shaderProgramMap = engine._getShaderProgramMap(this._shaderPassId, this._shaderProgramMaps);
    if (feedbackVaryings?.length) shaderProgramMap = shaderProgramMap.specialize("feedback:" + feedbackVaryings.join(","));
    if (primitive && engine._hardwareRenderer.backend === "webgpu") {
      shaderProgramMap = shaderProgramMap.specialize(primitive._getShaderInputs().key);
    }
    let shaderProgram = shaderProgramMap.get(macroCollection);
    if (!shaderProgram) {
      shaderProgram = this._compileShaderProgram(engine, macroCollection, feedbackVaryings, primitive);
      shaderProgramMap.cache(shaderProgram);
    }
    const properties = shaderProgram._filterableTextures;
    if (properties?.length) {
      const camera = engine._renderContext.camera;
      const sceneData = camera?.scene?.shaderData;
      const cameraData = camera?.shaderData;
      let specialized = shaderProgramMap;
      for (const property of properties) {
        if (shaderProgram._usesUnfilterableTexture(property, sceneData, cameraData, renderer, material, element)) {
          specialized = specialized.specialize("sampler:" + property.name);
        }
      }
      if (specialized !== shaderProgramMap) {
        const cached = specialized.get(macroCollection);
        if (cached) return cached;
        const names = new Set<string>();
        for (const property of properties) {
          if (shaderProgram._usesUnfilterableTexture(property, sceneData, cameraData, renderer, material, element)) names.add(property.name);
        }
        shaderProgram = this._compileShaderProgram(engine, macroCollection, feedbackVaryings, primitive, names);
        specialized.cache(shaderProgram);
      }
    }
    return shaderProgram;
  }

  /** Prepare the selected shader and pipeline for a mesh, material and render target before its first draw. */
  async preparePipeline(mesh: Mesh, material: Material, target: RenderTarget | null, macros: readonly ShaderMacro[] = [], subMeshIndex = 0, frontFaceInvert = false): Promise<void> {
    const engine = mesh.engine;
    if (material.engine !== engine || (target && target.engine !== engine)) throw new Error("Pipeline resources must belong to the same engine.");
    const subMesh = mesh.subMeshes[subMeshIndex];
    if (!subMesh) throw new RangeError("Cannot prepare a pipeline without the selected sub-mesh.");
    const collection = new ShaderMacroCollection();
    ShaderMacroCollection.unionCollection(engine._macroCollection, material.shaderData._macroCollection, collection);
    if (target) collection.disable(Engine._outputSRGBCorrectMacro);
    else collection.enable(Engine._outputSRGBCorrectMacro);
    for (const macro of macros) collection.enable(macro);
    const program = this._getShaderProgram(engine, collection, undefined, mesh._primitive, undefined, material.shaderData);
    if (!program.isValid) throw new Error(`Could not compile shader pass '${this.name}'.`);
    const state = this._renderState._resolve(engine, this._renderStateDataMap, material.shaderData);
    await program._platformProgram.prewarm?.(mesh._primitive, subMesh, target, state, frontFaceInvert);
  }

  /**
   * @internal
   */
  _destroy(): void {
    const shaderProgramMaps = this._shaderProgramMaps;
    for (let i = 0, n = shaderProgramMaps.length; i < n; i++) {
      const map = shaderProgramMaps[i];
      map.destroy();
      delete map.engine._shaderProgramMaps[this._shaderPassId];
    }
    shaderProgramMaps.length = 0;
  }

  /**
   * @internal
   */
  _compileShaderProgram(
    engine: Engine,
    macroCollection: ShaderMacroCollection,
    feedbackVaryings?: string[],
    primitive?: Primitive,
    unfilterableTextures?: ReadonlySet<string>
  ): ShaderProgram {
    const names = this._vertexOutputNames;
    if (names && feedbackVaryings?.length) {
      feedbackVaryings = feedbackVaryings.map((name) =>
        Object.prototype.hasOwnProperty.call(names, name) ? names[name] : name
      );
    }
    const isGPUInstance = macroCollection.isEnable(InstanceBuffer.gpuInstanceMacro);
    const device = engine._hardwareRenderer;
    const vertexInputTypes = device.backend === "webgpu" ? primitive?._getShaderInputs().types : undefined;
    const baked = this._wgsl;
    if (device.backend === "webgpu" && baked && !feedbackVaryings?.length && !unfilterableTextures?.size &&
        !macroCollection._mask.slice(0, macroCollection._length).some(Boolean) &&
        baked.reflection.vertexInputs.every((input) => !vertexInputTypes?.[input.name] || vertexInputTypes[input.name] === input.type)) {
      return new ShaderProgram(engine, {vertexSource: baked.vertex, fragmentSource: baked.fragment, vertexEntryPoint: baked.vertexEntryPoint, fragmentEntryPoint: baked.fragmentEntryPoint, reflection: baked.reflection});
    }
    const variant = this._compileShaderSource(engine, macroCollection, isGPUInstance && (device.backend !== "webgpu" || !!this._uniformPlan));
    let source: IPlatformShaderSource = { vertexSource: variant.vertexSource, fragmentSource: variant.fragmentSource, feedbackVaryings, looseUniforms: variant.looseUniforms };
    if (device.backend === "webgpu") {
      const compiler = engine._webGPUShaderCompiler;
      if (!compiler) throw new Error("WebGPU shader specialization requires a WebGPU shader compiler.");
      const layout = variant.instanceLayout;
      const compiled = compiler.compileWebGPUVariant(variant.vertexSource, variant.fragmentSource, {
        uniformBlocks: variant.uniformBlocks,
        vertexInputTypes,
        unfilterableTextures,
        computeFeedback: !!feedbackVaryings?.length,
        instanceBindingName: variant.instanceBindingName,
        instanceByteLength: layout ? (layout.headerBytes ?? 0) + layout.structSize * layout.instanceMaxCount : undefined
      });
      source = { vertexSource: compiled.vertex, fragmentSource: compiled.fragment, vertexEntryPoint: compiled.vertexEntryPoint, fragmentEntryPoint: compiled.fragmentEntryPoint, reflection: compiled.reflection, feedbackVaryings };
    }
    const program = new ShaderProgram(
      engine,
      source,
      variant.uniformBlocks,
      variant.instanceBindingName
    );
    program._instanceLayout = variant.instanceLayout;
    return program;
  }

  private _compileShaderSource(
    engine: Engine,
    macroCollection: ShaderMacroCollection,
    isGPUInstance: boolean
  ): {
    vertexSource: string;
    fragmentSource: string;
    instanceLayout: InstanceBufferLayout | null;
    uniformBlocks?: readonly IShaderUniformBlock[];
    instanceBindingName?: string;
    looseUniforms?: readonly IShaderUniformVariable[];
  } {
    const shaderMacroList = ShaderPass._shaderMacroList;
    shaderMacroList.length = 0;
    ShaderMacro._getMacrosElements(macroCollection, shaderMacroList);
    shaderMacroList.push(ShaderMacro.getByName(engine._hardwareRenderer.backend === "webgpu" ? "GRAPHICS_API_WEBGPU" : "GRAPHICS_API_WEBGL2"));
    shaderMacroList.push(ShaderMacro.getByName("HAS_TEX_LOD"));
    shaderMacroList.push(ShaderMacro.getByName("HAS_DERIVATIVES"));

    const macroMap = ShaderPass._macroMap;
    macroMap.clear();
    for (let i = 0, n = shaderMacroList.length; i < n; i++) {
      const macro = shaderMacroList[i];
      macroMap.set(macro.name, macro.value ?? "");
    }
    if (!isGPUInstance) macroMap.delete(InstanceBuffer.gpuInstanceMacro.name);
    // GLSL ES 3.00 predefined macros (§3.3) evaluated ahead of driver preprocessing
    macroMap.set("GL_ES", "1");
    macroMap.set("GL_FRAGMENT_PRECISION_HIGH", "1");
    macroMap.set("__VERSION__", "300");

    const plan = this._uniformPlan;
    const instancing = isGPUInstance ? plan?.instancing : undefined;
    const vertexSites: IShaderUniformSelection[] | undefined = plan ? [] : undefined;
    const fragmentSites: IShaderUniformSelection[] | undefined = plan ? [] : undefined;
    let vertexSource = ShaderMacroProcessor.evaluate(
      this._vertexShaderInstructions,
      macroMap,
      plan?.vertex,
      vertexSites
    );
    let fragmentSource = ShaderMacroProcessor.evaluate(
      this._fragmentShaderInstructions,
      macroMap,
      plan?.fragment,
      fragmentSites
    );
    let uniformBlocks = this._uniformBlocks;
    let instanceBindingName: string | undefined;
    let looseUniforms: readonly IShaderUniformVariable[] | undefined;
    let instanceLayout: InstanceBufferLayout | null = null;
    if (plan) {
      const device = engine._hardwareRenderer;
      const variant = finalizeShaderUniforms(vertexSource, fragmentSource, vertexSites!, fragmentSites!, {
        maxBlockBytes: device.maxUniformBlockSize,
        maxBindings: device.maxUniformBufferBindings,
        maxVertexBlocks: device.maxVertexUniformBlocks,
        maxFragmentBlocks: device.maxFragmentUniformBlocks,
        explicitBlocks: this._uniformBlocks?.length ?? 0,
        resolveConstant: device.resolveShaderConstant,
        instancing
      });
      if (variant.instanceOverflow && isGPUInstance) {
        return this._compileShaderSource(engine, macroCollection, false);
      }
      vertexSource = variant.vertexSource;
      fragmentSource = variant.fragmentSource;
      looseUniforms = variant.looseUniforms;
      if (variant.uniformBlocks.length) uniformBlocks = [...(uniformBlocks ?? []), ...variant.uniformBlocks];
      if (variant.instanceLayout) {
        instanceLayout = ShaderFactory.createInstanceLayout(variant.instanceLayout, vertexSites!, fragmentSites!);
        instanceBindingName = variant.instanceLayout.bindingName;
      }
    } else if (isGPUInstance) {
      // Historical .shaderc contains the original instructions without compiler declaration metadata.
      const injected = ShaderFactory.injectInstanceUBO(engine, vertexSource, fragmentSource);
      vertexSource = injected.vertexSource;
      fragmentSource = injected.fragmentSource;
      instanceLayout = injected.instanceLayout;
    }

    const versionStr = "#version 300 es";

    return {
      vertexSource: ` ${versionStr}
        ${vertexSource}
      `,
      fragmentSource: ` ${versionStr}
        ${precisionStr}
        ${fragmentSource}
      `,
      instanceLayout,
      uniformBlocks,
      instanceBindingName,
      looseUniforms
    };
  }
}
