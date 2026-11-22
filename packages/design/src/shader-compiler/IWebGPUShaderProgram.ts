import type { IShaderUniformBlock } from "./IShaderProgramSource";
import type { IShaderProgramSource } from "./IShaderProgramSource";

export type WebGPUShaderInputType = "float" | "sint" | "uint";

/** Concrete stage interface after macro and vertex format selection. */
export interface IWebGPUShaderAttribute {
  name: string;
  location: number;
  type: WebGPUShaderInputType;
  components: number;
}

export interface IWebGPUShaderUniformBlock {
  name: IShaderUniformBlock["name"] | "Instance";
  bindingName: string;
  physicalBinding: number;
  group: number;
  binding: number;
  visibility: number;
  byteLength: number;
  members: IShaderUniformBlock["members"];
}

export interface IWebGPUShaderTexture {
  name: string;
  /** Index in a ShaderData texture array when GLSL uses a combined sampler array. */
  arrayIndex?: number;
  group: number;
  textureBinding: number;
  samplerBinding?: number;
  /** Stages which sample with a sampler, excluding textureLoad/textureDimensions. */
  samplerVisibility?: number;
  visibility: number;
  sampleType: "float" | "unfilterable-float" | "sint" | "uint" | "depth";
  viewDimension: "2d" | "2d-array" | "cube" | "3d";
  samplerType?: "filtering" | "non-filtering" | "comparison";
}

export interface IWebGPUShaderReflection {
  uniformBlocks: IWebGPUShaderUniformBlock[];
  textures: IWebGPUShaderTexture[];
  vertexInputs: IWebGPUShaderAttribute[];
  vertexOutputs: IWebGPUShaderAttribute[];
  fragmentOutputs: number[];
}

/** Device-consumable program. Both modules and the layout describe exactly one variant. */
export interface IWebGPUShaderProgram {
  vertex: string;
  fragment: string;
  vertexEntryPoint: string;
  fragmentEntryPoint: string;
  reflection: IWebGPUShaderReflection;
}

export interface IWebGPUShaderOptions {
  uniformBlocks?: readonly IShaderUniformBlock[];
  instanceBindingName?: string;
  instanceByteLength?: number;
  vertexInputTypes?: Readonly<Record<string, WebGPUShaderInputType>>;
  unfilterableTextures?: ReadonlySet<string>;
  computeFeedback?: boolean;
  maxSamplersPerStage?: number;
  maxUniformBlockBytes?: number;
}

export interface IWebGPUShaderCompiler {
  compileWebGPUVariant(vertexSource: string, fragmentSource: string, options?: IWebGPUShaderOptions): IWebGPUShaderProgram;
  compileDefaultVariant(program: IShaderProgramSource): IWebGPUShaderProgram;
}
