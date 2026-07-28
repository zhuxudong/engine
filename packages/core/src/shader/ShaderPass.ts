import type {
  IShaderReflection,
  IShaderProgramSource,
  IShaderUniformReflection,
  ShaderInstruction
} from "@galacean/engine-design";
import { Engine } from "../Engine";
import { InstanceBuffer } from "../RenderPipeline/InstanceBuffer";
import { PipelineStage } from "../RenderPipeline/enums/PipelineStage";
import { GLCapabilityType } from "../base/Constant";
import { InstanceBufferLayout, ShaderFactory } from "./ShaderFactory";
import { ShaderMacro } from "./ShaderMacro";
import { ShaderMacroCollection } from "./ShaderMacroCollection";
import { ShaderPart } from "./ShaderPart";
import { ShaderProgramMap } from "./ShaderProgramMap";
import { ShaderProgram } from "./ShaderProgram";
import { ShaderProperty } from "./ShaderProperty";
import { ShaderLanguage } from "./enums/ShaderLanguage";
import { ShaderMacroProcessor } from "./ShaderMacroProcessor";
import { RenderState } from "./state/RenderState";

const precisionStr = `
    #ifdef GL_FRAGMENT_PRECISION_HIGH
      precision highp float;
      precision highp int;
    #else
      precision mediump float;
      precision mediump int;
    #endif
    `;

/**
 * Shader pass containing vertex and fragment source.
 */
export class ShaderPass extends ShaderPart {
  /** @internal */
  static _shaderPassCounter: number = 0;
  /** @internal */
  static _shaderRootPath = "shaders://root/";

  /** @internal */
  _platformTarget: ShaderLanguage;

  /** @internal - Flat instruction array for vertex shader. */
  _vertexShaderInstructions: ShaderInstruction[];
  /** @internal */
  _fragmentShaderInstructions: ShaderInstruction[];
  /** @internal */
  _computeShaderInstructions?: ShaderInstruction[];
  /** @internal */
  _computeWorkgroupSize?: readonly [string, string, string];
  /** @internal */
  _shaderTargets: Partial<Record<ShaderLanguage, IShaderProgramSource>> = {};

  /** @internal */
  _shaderPassId: number = 0;

  /** @internal Pass-level render state — always present, populated from ShaderLab declarations. */
  _renderState: RenderState = new RenderState();
  /** @internal */
  _renderStateDataMap: Record<number, ShaderProperty> = {};
  /** @internal */
  _shaderProgramMaps: ShaderProgramMap[] = [];
  /** @internal Transform feedback output varyings (WebGL2 only). */
  _feedbackVaryings?: string[];

  private static _shaderMacroList: ShaderMacro[] = [];
  private static _macroMap: Map<string, string> = new Map();

  /**
   * Create a shader pass from precompiled instructions.
   * @param name - Shader pass name
   * @param vertexShaderInstructions - Precompiled vertex instruction array
   * @param fragmentShaderInstructions - Precompiled fragment instruction array
   * @param platformTarget - Target shader language
   * @param tags - Tags
   * @param reflection - Backend resource and stage-input reflection.
   * @param computeShaderInstructions - Precompiled compute instruction array.
   * @param computeWorkgroupSize - Compile-time compute workgroup dimensions.
   */
  constructor(
    name: string,
    vertexShaderInstructions: ShaderInstruction[],
    fragmentShaderInstructions: ShaderInstruction[],
    platformTarget: ShaderLanguage,
    tags?: Record<string, number | string | boolean>,
    reflection?: IShaderReflection,
    computeShaderInstructions?: ShaderInstruction[],
    computeWorkgroupSize?: readonly [string, string, string]
  ) {
    super();
    this._shaderPassId = ShaderPass._shaderPassCounter++;

    this._name = name;
    this._vertexShaderInstructions = vertexShaderInstructions;
    this._fragmentShaderInstructions = fragmentShaderInstructions;
    this._computeShaderInstructions = computeShaderInstructions;
    this._computeWorkgroupSize = computeWorkgroupSize;
    this._platformTarget = platformTarget;
    this._shaderTargets[platformTarget] = {
      vertex: "",
      fragment: "",
      vertexShaderInstructions,
      fragmentShaderInstructions,
      reflection,
      computeShaderInstructions,
      computeWorkgroupSize
    };

    const mergedTags = { pipelineStage: PipelineStage.Forward, ...tags };
    for (const key in mergedTags) {
      this.setTag(key, mergedTags[key]);
    }
  }

  /**
   * Register code generated from the same ShaderLab pass for another backend.
   * @param platformTarget - Target shader language.
   * @param source - Encoded stage instructions and reflection for the target.
   * @internal
   */
  _setShaderTarget(platformTarget: ShaderLanguage, source: IShaderProgramSource): void {
    this._shaderTargets[platformTarget] = source;
  }

  /**
   * @internal
   */
  _getShaderProgram(engine: Engine, macroCollection: ShaderMacroCollection): ShaderProgram {
    const shaderProgramMap = engine._getShaderProgramMap(this._shaderPassId, this._shaderProgramMaps);
    let shaderProgram = shaderProgramMap.get(macroCollection);
    if (shaderProgram) {
      return shaderProgram;
    }

    shaderProgram = this._compileShaderProgram(engine, macroCollection);

    shaderProgramMap.cache(shaderProgram);
    return shaderProgram;
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
  _compileShaderProgram(engine: Engine, macroCollection: ShaderMacroCollection): ShaderProgram {
    const isGPUInstance = macroCollection.isEnable(InstanceBuffer.gpuInstanceMacro);
    const { vertexSource, fragmentSource, instanceLayout, platformTarget, reflection } = this._compileShaderSource(
      engine,
      macroCollection,
      isGPUInstance
    );
    const program = new ShaderProgram(
      engine,
      vertexSource,
      fragmentSource,
      this._feedbackVaryings,
      platformTarget,
      reflection,
      instanceLayout
    );
    program._instanceLayout = instanceLayout;
    return program;
  }

  /**
   * Compile the compute target selected by the engine backend.
   * @param engine - Engine that owns the target device.
   * @returns Resolved WGSL source, reflection, and workgroup dimensions.
   * @internal
   */
  _compileComputeShaderSource(engine: Engine): {
    source: string;
    reflection: IShaderReflection;
    workgroupSize: readonly [number, number, number];
  } {
    const renderer = engine._hardwareRenderer;
    if (!renderer.computeCapabilities.supported) {
      throw new Error(`Compute passes are not supported by the ${renderer.backend} backend.`);
    }

    const target = this._shaderTargets[ShaderLanguage.WGSL];
    if (!target?.computeShaderInstructions || !target.reflection) {
      throw new Error(`Shader pass "${this.name}" has no WGSL compute target.`);
    }

    const macros = new Map<string, string>([
      ["GRAPHICS_API_WEBGPU", ""],
      ["GRAPHICS_API_WEBGL2", ""],
      ["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", renderer.computeCapabilities.recommendedWorkgroupSizeX.toString()]
    ]);
    const discoveredMacros = new Map<string, string>();
    ShaderMacroProcessor.evaluate(target.computeShaderInstructions, macros, discoveredMacros);
    const macroSeed = ShaderPass._createWGSLMacroSeed(macros, discoveredMacros, target.reflection);
    const evaluatedMacros = new Map<string, string>();
    const source = ShaderMacroProcessor.evaluate(target.computeShaderInstructions, macroSeed, evaluatedMacros);
    const reflection = ShaderPass._resolveReflection(target.reflection, evaluatedMacros);
    if (!reflection) {
      throw new Error(`Shader pass "${this.name}" has no compute reflection.`);
    }

    const workgroupExpressions = target.computeWorkgroupSize ?? ["GALACEAN_COMPUTE_WORKGROUP_SIZE_X", "1", "1"];
    const workgroupSize = workgroupExpressions.map((expression) =>
      ShaderMacroProcessor._evaluateIntegerExpression(expression, evaluatedMacros)
    ) as [number, number, number];
    const capabilities = renderer.computeCapabilities;
    if (
      workgroupSize[0] > capabilities.maxWorkgroupSizeX ||
      workgroupSize[1] > capabilities.maxWorkgroupSizeY ||
      workgroupSize[2] > capabilities.maxWorkgroupSizeZ ||
      workgroupSize[0] * workgroupSize[1] * workgroupSize[2] > capabilities.maxInvocationsPerWorkgroup
    ) {
      throw new RangeError(`Compute workgroup ${workgroupSize.join("x")} exceeds ${renderer.backend} device limits.`);
    }

    return { source, reflection, workgroupSize };
  }

  private _compileShaderSource(
    engine: Engine,
    macroCollection: ShaderMacroCollection,
    isGPUInstance: boolean
  ): {
    vertexSource: string;
    fragmentSource: string;
    instanceLayout: InstanceBufferLayout | null;
    platformTarget: ShaderLanguage;
    reflection?: IShaderReflection;
  } {
    const isWebGPU = engine._hardwareRenderer.backend === "webgpu";
    const isWebGL2: boolean = engine._hardwareRenderer.isWebGL2;
    const platformTarget = isWebGPU ? ShaderLanguage.WGSL : this._platformTarget;
    const target = this._shaderTargets[platformTarget];
    if (!target?.vertexShaderInstructions || !target.fragmentShaderInstructions) {
      throw new Error(
        `Shader pass "${this.name}" has no ${ShaderLanguage[platformTarget]} target for the ${engine._hardwareRenderer.backend} backend.`
      );
    }
    const shaderMacroList = ShaderPass._shaderMacroList;
    shaderMacroList.length = 0;
    ShaderMacro._getMacrosElements(macroCollection, shaderMacroList);
    shaderMacroList.push(
      ShaderMacro.getByName(isWebGPU ? "GRAPHICS_API_WEBGPU" : isWebGL2 ? "GRAPHICS_API_WEBGL2" : "GRAPHICS_API_WEBGL1")
    );
    if (isWebGPU) {
      // Existing built-in shader branches use this as a modern integer/texture capability gate.
      shaderMacroList.push(ShaderMacro.getByName("GRAPHICS_API_WEBGL2"));
    }
    if (isWebGPU || engine._hardwareRenderer.canIUse(GLCapabilityType.shaderTextureLod)) {
      shaderMacroList.push(ShaderMacro.getByName("HAS_TEX_LOD"));
    }
    if (isWebGPU || engine._hardwareRenderer.canIUse(GLCapabilityType.standardDerivatives)) {
      shaderMacroList.push(ShaderMacro.getByName("HAS_DERIVATIVES"));
    }

    const macroMap = ShaderPass._macroMap;
    macroMap.clear();
    for (let i = 0, n = shaderMacroList.length; i < n; i++) {
      const macro = shaderMacroList[i];
      macroMap.set(macro.name, macro.value ?? "");
    }
    let evaluatedMacros: Map<string, string>;
    let vertexSource: string;
    let fragmentSource: string;
    if (isWebGPU && target.reflection) {
      const discoveredVertexMacros = new Map<string, string>();
      const discoveredFragmentMacros = new Map<string, string>();
      ShaderMacroProcessor.evaluate(target.vertexShaderInstructions, macroMap, discoveredVertexMacros);
      ShaderMacroProcessor.evaluate(target.fragmentShaderInstructions, macroMap, discoveredFragmentMacros);
      const vertexMacroSeed = ShaderPass._createWGSLMacroSeed(macroMap, discoveredVertexMacros, target.reflection);
      const fragmentMacroSeed = ShaderPass._createWGSLMacroSeed(macroMap, discoveredFragmentMacros, target.reflection);
      const finalVertexMacros = new Map<string, string>();
      const finalFragmentMacros = new Map<string, string>();
      vertexSource = ShaderMacroProcessor.evaluate(target.vertexShaderInstructions, vertexMacroSeed, finalVertexMacros);
      fragmentSource = ShaderMacroProcessor.evaluate(
        target.fragmentShaderInstructions,
        fragmentMacroSeed,
        finalFragmentMacros
      );
      evaluatedMacros = new Map([...macroMap, ...finalVertexMacros, ...finalFragmentMacros]);
    } else {
      evaluatedMacros = new Map<string, string>();
      vertexSource = ShaderMacroProcessor.evaluate(target.vertexShaderInstructions, macroMap, evaluatedMacros);
      fragmentSource = ShaderMacroProcessor.evaluate(target.fragmentShaderInstructions, macroMap);
    }
    if (isWebGPU) {
      vertexSource = ShaderPass._rewriteWGSLComparisonSamples(vertexSource, target.reflection);
      fragmentSource = ShaderPass._rewriteWGSLComparisonSamples(fragmentSource, target.reflection);
      vertexSource = ShaderPass._removeEmptyWGSLStructs(vertexSource);
      fragmentSource = ShaderPass._removeEmptyWGSLStructs(fragmentSource);
      ({ vertexSource, fragmentSource } = ShaderPass._compactWGSLLocations(vertexSource, fragmentSource));
    }
    let reflection = ShaderPass._resolveReflection(
      target.reflection,
      evaluatedMacros,
      isWebGPU ? vertexSource : undefined,
      isWebGPU ? fragmentSource : undefined
    );
    if (isWebGPU && reflection) {
      let lowered = ShaderFactory.lowerWGSLDepthTextures(vertexSource, reflection);
      vertexSource = lowered.source;
      reflection = lowered.reflection;
      lowered = ShaderFactory.lowerWGSLDepthTextures(fragmentSource, reflection);
      fragmentSource = lowered.source;
      reflection = lowered.reflection;
    }

    let instanceLayout: InstanceBufferLayout | null = null;
    if (isGPUInstance) {
      if (isWebGPU) {
        if (!reflection) {
          throw new Error("WebGPU GPU instancing requires ShaderLab reflection.");
        }
        const injected = ShaderFactory.injectInstanceWGSL(engine, vertexSource, fragmentSource, reflection);
        vertexSource = injected.vertexSource;
        fragmentSource = injected.fragmentSource;
        reflection = injected.reflection;
        instanceLayout = injected.instanceLayout;
      } else {
        const injected = ShaderFactory.injectInstanceUBO(engine, vertexSource, fragmentSource);
        vertexSource = injected.vertexSource;
        fragmentSource = injected.fragmentSource;
        instanceLayout = injected.instanceLayout;
      }
    }

    if (isWebGL2 && platformTarget === ShaderLanguage.GLSLES100) {
      vertexSource = ShaderFactory.convertTo300(vertexSource);
      fragmentSource = ShaderFactory.convertTo300(fragmentSource, true);
    }

    if (isWebGPU) {
      return {
        vertexSource,
        fragmentSource,
        instanceLayout,
        platformTarget,
        reflection
      };
    }

    return {
      vertexSource: ` ${isWebGL2 ? "#version 300 es" : "#version 100"}
        ${vertexSource}
      `,
      fragmentSource: ` ${isWebGL2 ? "#version 300 es" : "#version 100"}
        ${isWebGL2 ? "" : ShaderFactory.shaderExtension}
        ${precisionStr}
        ${fragmentSource}
      `,
      instanceLayout,
      platformTarget,
      reflection
    };
  }

  private static _resolveReflection(
    reflection: IShaderReflection | undefined,
    macros: ReadonlyMap<string, string>,
    vertexSource?: string,
    fragmentSource?: string
  ): IShaderReflection | undefined {
    if (!reflection) {
      return undefined;
    }

    const activeByMacros = <T extends { conditions?: readonly { name: string; defined: boolean }[] }>(
      item: T
    ): boolean =>
      !item.conditions || item.conditions.every((condition) => macros.has(condition.name) === condition.defined);
    const sources = `${vertexSource ?? ""}\n${fragmentSource ?? ""}`;
    const uniformBody = `${ShaderPass._extractWGSLStructBody(
      vertexSource,
      "GSUniforms"
    )}\n${ShaderPass._extractWGSLStructBody(fragmentSource, "GSUniforms")}`;
    const vertexInputBody = ShaderPass._extractWGSLStructBody(vertexSource, "GSVertexInput");
    const resolveUniform = (uniform: IShaderUniformReflection, body?: string): IShaderUniformReflection => ({
      ...uniform,
      arrayLength: uniform.arrayLength
        ? ShaderMacroProcessor._evaluateIntegerExpression(
            (body ? ShaderPass._extractWGSLArrayLength(body, uniform.name) : undefined) ?? uniform.arrayLength,
            macros
          ).toString()
        : undefined,
      conditions: undefined
    });

    return {
      uniforms: reflection.uniforms
        .filter((uniform) =>
          vertexSource || fragmentSource
            ? ShaderPass._hasWGSLStructMember(uniformBody, uniform.name)
            : activeByMacros(uniform)
        )
        .map((uniform) => resolveUniform(uniform, uniformBody)),
      structs: reflection.structs.map((struct) => ({
        name: struct.name,
        members: (() => {
          const body = `${ShaderPass._extractWGSLStructBody(
            vertexSource,
            struct.name
          )}\n${ShaderPass._extractWGSLStructBody(fragmentSource, struct.name)}`;
          return struct.members
            .filter((member) => {
              if (!vertexSource && !fragmentSource) {
                return activeByMacros(member);
              }
              return ShaderPass._hasWGSLStructMember(body, member.name);
            })
            .map((member) => resolveUniform(member, body));
        })()
      })),
      resources: reflection.resources
        .filter((resource) =>
          vertexSource || fragmentSource
            ? new RegExp(`\\bvar\\s+${ShaderPass._escapeRegExp(resource.name)}\\s*:`).test(sources)
            : activeByMacros(resource)
        )
        .map(({ conditions: _conditions, ...resource }) => resource),
      vertexInputs: reflection.vertexInputs
        .filter((input) => (vertexSource ? ShaderPass._hasWGSLStructMember(vertexInputBody, input.name) : true))
        .map((input) => ({
          ...input,
          location: ShaderPass._extractWGSLLocation(vertexInputBody, input.name) ?? input.location
        })),
      fragmentOutputs: reflection.fragmentOutputs,
      ...(reflection.storageBuffers
        ? {
            storageBuffers: reflection.storageBuffers.filter(activeByMacros).map((storageBuffer) => ({
              ...storageBuffer,
              conditions: undefined,
              arrayLength: storageBuffer.arrayLength
                ? ShaderMacroProcessor._evaluateIntegerExpression(storageBuffer.arrayLength, macros).toString()
                : undefined
            }))
          }
        : {})
    };
  }

  private static _createWGSLMacroSeed(
    runtimeMacros: ReadonlyMap<string, string>,
    discoveredMacros: ReadonlyMap<string, string>,
    reflection: IShaderReflection
  ): Map<string, string> {
    const seed = new Map(runtimeMacros);
    const addConditions = (item: { conditions?: readonly { name: string; defined: boolean }[] }): void => {
      for (const condition of item.conditions ?? []) {
        if (!condition.name.endsWith("_INCLUDED")) {
          const value = discoveredMacros.get(condition.name);
          if (value !== undefined) {
            seed.set(condition.name, value);
          }
        }
      }
    };
    for (const uniform of reflection.uniforms) {
      addConditions(uniform);
    }
    for (const struct of reflection.structs) {
      for (const member of struct.members) {
        addConditions(member);
      }
    }
    for (const resource of reflection.resources) {
      addConditions(resource);
    }
    for (const storageBuffer of reflection.storageBuffers ?? []) {
      addConditions(storageBuffer);
    }
    return seed;
  }

  private static _rewriteWGSLComparisonSamples(source: string, reflection: IShaderReflection): string {
    const comparisonResources = new Set(
      reflection.resources.filter((resource) => resource.comparison).map((resource) => resource.name)
    );
    const comparisonParameterPattern =
      /\b([A-Za-z_]\w*)\s*:\s*texture_depth_[A-Za-z0-9_]+(?:<[^>]+>)?\s*,\s*\1_sampler\s*:\s*sampler_comparison\b/g;
    for (const match of source.matchAll(comparisonParameterPattern)) {
      comparisonResources.add(match[1]);
    }
    if (comparisonResources.size === 0) {
      return source;
    }

    const callPrefix = "textureSampleLevel(";
    let searchFrom = 0;
    while (true) {
      const callStart = source.indexOf(callPrefix, searchFrom);
      if (callStart < 0) {
        return source;
      }
      const argsStart = callStart + callPrefix.length;
      let depth = 1;
      let cursor = argsStart;
      const separators: number[] = [];
      while (cursor < source.length && depth > 0) {
        const character = source[cursor];
        if (character === "(") {
          depth++;
        } else if (character === ")") {
          depth--;
        } else if (character === "," && depth === 1) {
          separators.push(cursor);
        }
        cursor++;
      }
      if (depth !== 0) {
        return source;
      }
      const callEnd = cursor;
      const boundaries = [argsStart - 1, ...separators, callEnd - 1];
      const args: string[] = [];
      for (let i = 0; i < boundaries.length - 1; i++) {
        args.push(source.slice(boundaries[i] + 1, boundaries[i + 1]).trim());
      }
      if (args.length === 4 && comparisonResources.has(args[0])) {
        const coordinate = args[2];
        const replacement = `textureSampleCompareLevel(${args[0]}, ${args[1]}, (${coordinate}).xy, (${coordinate}).z)`;
        source = source.slice(0, callStart) + replacement + source.slice(callEnd);
        searchFrom = callStart + replacement.length;
      } else {
        searchFrom = callEnd;
      }
    }
  }

  private static _removeEmptyWGSLStructs(source: string): string {
    const emptyWrapperNames: string[] = [];
    source = source.replace(/\bstruct\s+(GSVertexInput|GSFragmentInput)\s*\{\s*\}\s*/g, (_match, name: string) => {
      emptyWrapperNames.push(name);
      return "";
    });
    source = source.replace(/\bstruct\s+\w+\s*\{\s*\}\s*/g, "");
    for (const name of emptyWrapperNames) {
      source = source.replace(new RegExp(`\\(\\s*input\\s*:\\s*${name}\\s*\\)`), "()");
    }
    return source;
  }

  private static _compactWGSLLocations(
    vertexSource: string,
    fragmentSource: string
  ): { vertexSource: string; fragmentSource: string } {
    const vertexInputNames = ShaderPass._extractWGSLLocatedMembers(vertexSource, "GSVertexInput");
    const vertexInputLocations = new Map(vertexInputNames.map((name, location) => [name, location]));
    vertexSource = ShaderPass._rewriteWGSLStructLocations(vertexSource, "GSVertexInput", vertexInputLocations);

    const varyingNames = ShaderPass._extractWGSLLocatedMembers(vertexSource, "GSVertexOutput");
    for (const name of ShaderPass._extractWGSLLocatedMembers(fragmentSource, "GSFragmentInput")) {
      if (!varyingNames.includes(name)) {
        varyingNames.push(name);
      }
    }
    const varyingLocations = new Map(varyingNames.map((name, location) => [name, location]));
    vertexSource = ShaderPass._rewriteWGSLStructLocations(vertexSource, "GSVertexOutput", varyingLocations);
    fragmentSource = ShaderPass._rewriteWGSLStructLocations(fragmentSource, "GSFragmentInput", varyingLocations);
    return { vertexSource, fragmentSource };
  }

  private static _extractWGSLLocatedMembers(source: string, structName: string): string[] {
    const body = ShaderPass._extractWGSLStructBody(source, structName);
    const names: string[] = [];
    for (const match of body.matchAll(/@location\(\d+\)(?:\s+@\w+(?:\([^)]*\))?)*\s+([A-Za-z_]\w*)\s*:/g)) {
      names.push(match[1]);
    }
    return names;
  }

  private static _rewriteWGSLStructLocations(
    source: string,
    structName: string,
    locations: ReadonlyMap<string, number>
  ): string {
    const structPattern = new RegExp(`(\\bstruct\\s+${ShaderPass._escapeRegExp(structName)}\\s*\\{)([\\s\\S]*?)(\\})`);
    return source.replace(structPattern, (_struct, prefix: string, body: string, suffix: string) => {
      const rewritten = body.replace(
        /@location\(\d+\)((?:\s+@\w+(?:\([^)]*\))?)*)\s+([A-Za-z_]\w*)\s*:/g,
        (member, attributes: string, name: string) => {
          const location = locations.get(name);
          return location === undefined ? member : `@location(${location})${attributes} ${name}:`;
        }
      );
      return `${prefix}${rewritten}${suffix}`;
    });
  }

  private static _extractWGSLStructBody(source: string | undefined, structName: string): string {
    if (!source) {
      return "";
    }
    return (
      new RegExp(`\\bstruct\\s+${ShaderPass._escapeRegExp(structName)}\\s*\\{([\\s\\S]*?)\\}`).exec(source)?.[1] ?? ""
    );
  }

  private static _hasWGSLStructMember(body: string, memberName: string): boolean {
    return new RegExp(`(?:^|\\n)\\s*(?:@[^\\n]+\\s+)?${ShaderPass._escapeRegExp(memberName)}\\s*:`).test(body);
  }

  private static _extractWGSLLocation(body: string, memberName: string): number | undefined {
    const match = new RegExp(
      `@location\\((\\d+)\\)(?:\\s+@\\w+(?:\\([^)]*\\))?)*\\s+${ShaderPass._escapeRegExp(memberName)}\\s*:`
    ).exec(body);
    return match ? Number(match[1]) : undefined;
  }

  private static _extractWGSLArrayLength(body: string, memberName: string): string | undefined {
    const match = new RegExp(
      `(?:^|\\n)\\s*(?:@[^\\n]+\\s+)?${ShaderPass._escapeRegExp(memberName)}\\s*:\\s*array<([^\\n]+)>\\s*,`
    ).exec(body);
    if (!match) {
      return undefined;
    }
    const separator = match[1].lastIndexOf(",");
    return separator >= 0 ? match[1].slice(separator + 1).trim() : undefined;
  }

  private static _escapeRegExp(value: string): string {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }
}
