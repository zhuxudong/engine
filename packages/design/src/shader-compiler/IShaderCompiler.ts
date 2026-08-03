import { IPrecompiledShader } from "./IPrecompiledShader";
import { IShaderProgramSource } from "./IShaderProgramSource";
import { IShaderSource } from "./shaderSource/IShaderSource";

/**
 * Shader compiler interface.
 */
export interface IShaderCompiler {
  /**
   * @internal
   * Parse shader source code to get the source structure of shader.
   */
  _parseShaderSource(sourceCode: string): IShaderSource;

  /**
   * @internal
   * Parse shader pass source code.
   * @param basePathForIncludeKey - The base path to resolve the relative path of `#include` directives.
   *   Must follow the specifications of [URL.origin](https://developer.mozilla.org/en-US/docs/Web/API/URL/origin),
   *   like: `shaders://root/`.
   */
  _parseShaderPass(
    shaderPassSource: string,
    vertexEntry: string | undefined,
    fragmentEntry: string | undefined,
    backend: any,
    basePathForIncludeKey: string,
    computeEntry?: string,
    computeWorkgroupSize?: readonly [string, string, string]
  ): IShaderProgramSource | undefined;

  /**
   * @internal
   */
  _precompile(sourceCode: string, platformTarget: any, basePathForIncludeKey: string): IPrecompiledShader;
}
