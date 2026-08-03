import type { ShaderInstruction } from "./ICondition";

/**
 * Shader value type used by backend reflection.
 */
export type ShaderReflectionType =
  | "bool"
  | "i32"
  | "u32"
  | "f32"
  | "vec2<bool>"
  | "vec3<bool>"
  | "vec4<bool>"
  | "vec2<i32>"
  | "vec3<i32>"
  | "vec4<i32>"
  | "vec2<u32>"
  | "vec3<u32>"
  | "vec4<u32>"
  | "vec2<f32>"
  | "vec3<f32>"
  | "vec4<f32>"
  | "mat2x2<f32>"
  | "mat2x3<f32>"
  | "mat2x4<f32>"
  | "mat3x2<f32>"
  | "mat3x3<f32>"
  | "mat3x4<f32>"
  | "mat4x2<f32>"
  | "mat4x3<f32>"
  | "mat4x4<f32>"
  | string;

/**
 * Compile-time macro condition attached to a reflected declaration.
 */
export interface IShaderReflectionCondition {
  /** Macro name tested by the source declaration. */
  name: string;
  /** Whether the declaration requires the macro to be defined. */
  defined: boolean;
}

/**
 * Reflected uniform field.
 */
export interface IShaderUniformReflection {
  /** Shader property name. */
  name: string;
  /** Backend-neutral value type. */
  type: ShaderReflectionType;
  /** Source expression for an optional fixed array length. */
  arrayLength?: string;
  /** Macro conditions controlling whether the field exists in a compiled variant. */
  conditions?: readonly IShaderReflectionCondition[];
}

/**
 * Reflected structure used by uniform fields.
 */
export interface IShaderStructReflection {
  /** Structure type name. */
  name: string;
  /** Structure members in source declaration order. */
  members: IShaderUniformReflection[];
}

/**
 * Reflected texture and sampler binding.
 */
export interface IShaderResourceReflection {
  /** Shader property name. */
  name: string;
  /** Texture binding index. */
  textureBinding: number;
  /** Sampler binding index. */
  samplerBinding: number;
  /** WebGPU texture declaration type. */
  textureType: string;
  /** Whether the sampler performs depth comparison. */
  comparison: boolean;
  /** Macro conditions controlling whether the resource exists in a compiled variant. */
  conditions?: readonly IShaderReflectionCondition[];
}

/**
 * Reflected vertex input.
 */
export interface IShaderVertexInputReflection {
  /** Engine vertex semantic. */
  name: string;
  /** Shader location. */
  location: number;
  /** Backend-neutral value type. */
  type: ShaderReflectionType;
}

/**
 * Structured shader reflection generated from the ShaderLab AST.
 */
export interface IShaderReflection {
  /** Uniform fields stored in the draw uniform block. */
  uniforms: IShaderUniformReflection[];
  /** User structures referenced by uniform fields. */
  structs: IShaderStructReflection[];
  /** Texture and sampler resources. */
  resources: IShaderResourceReflection[];
  /** Vertex-stage inputs. */
  vertexInputs: IShaderVertexInputReflection[];
  /** Fragment color output locations written by the variant. */
  fragmentOutputs: number[];
}

/**
 * Generated vertex and fragment source for one backend target.
 */
export interface IShaderProgramSource {
  /** Vertex shader source. */
  vertex: string;
  /** Fragment shader source. */
  fragment: string;
  /** Encoded vertex shader macro instructions. */
  vertexShaderInstructions?: ShaderInstruction[];
  /** Encoded fragment shader macro instructions. */
  fragmentShaderInstructions?: ShaderInstruction[];
  /** Structured resource and input reflection. */
  reflection?: IShaderReflection;
}
