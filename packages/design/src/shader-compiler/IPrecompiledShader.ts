import type { ShaderInstruction } from "./ICondition";
import type { IShaderReflection } from "./IShaderProgramSource";

/** Serialized ShaderLab artifact for one backend target. */
export interface IPrecompiledShader {
  /** Shader name. */
  name: string;
  /** Backend language encoded by this artifact. */
  platformTarget: number;
  /** Precompiled sub-shaders. */
  subShaders: IPrecompiledSubShader[];
}

/**
 * Serialized sub-shader and its ordered passes.
 */
export interface IPrecompiledSubShader {
  /** Sub-shader name. */
  name: string;
  /** Sub-shader tags. */
  tags?: Record<string, number | string | boolean>;
  /** Ordered shader passes. */
  passes: IPrecompiledPass[];
}

/**
 * Serialized pass state and one backend shader program.
 */
export interface IPrecompiledPass {
  /** Pass name or UsePass path. */
  name: string;
  /** Whether this entry references another pass. */
  isUsePass: boolean;
  /** Pass tags. */
  tags?: Record<string, number | string | boolean>;
  /** Serialized render-state values and property references. */
  renderStates: {
    /** Constant render-state values keyed by state element. */
    constantMap: Record<string, number | string | boolean | number[]>;
    /** Shader property names keyed by state element. */
    variableMap: Record<string, string>;
  };
  /** Encoded vertex-stage source and macro instructions. */
  vertexShaderInstructions?: ShaderInstruction[];
  /** Encoded fragment-stage source and macro instructions. */
  fragmentShaderInstructions?: ShaderInstruction[];
  /** Encoded compute-stage source and macro instructions. */
  computeShaderInstructions?: ShaderInstruction[];
  /** Compile-time compute workgroup dimensions. */
  computeWorkgroupSize?: readonly [string, string, string];
  /** Structured reflection for this backend target. */
  reflection?: IShaderReflection;
}
