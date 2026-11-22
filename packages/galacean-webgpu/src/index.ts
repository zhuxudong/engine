import * as Core from "@galacean/engine-core";
import { WebGPUEngine as PlatformEngine, WebGPUEngineConfiguration } from "@galacean/engine-rhi-webgpu";
import * as sources from "@galacean/engine-shader/webgpu";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { createWebGPUShaderCompiler } from "@galacean/engine-shader-compiler/webgpu";

export * from "@galacean/engine-core";
export * from "@galacean/engine-loader";
export * from "@galacean/engine-math";
export * from "@galacean/engine-rhi-webgpu";

export const version = "__buildVersion";
for (const name in Core) Core.Loader.registerClass(name, Core[name]);
Core.Polyfill.registerPolyfill();
Core.SystemInfo._initialize();
Core.ShaderFactory._registerBuiltinIncludes(sources.shaderLibrary);
let builtinShaders: Core.BuiltinShaders;

/** Browser engine with the WebGPU runtime and its matching built-in shaders. */
export class WebGPUEngine extends PlatformEngine {
  static override async create(configuration: WebGPUEngineConfiguration): Promise<WebGPUEngine> {
    const webGPUShaderCompiler = configuration.webGPUShaderCompiler ?? (await createWebGPUShaderCompiler());
    return super.create({
      ...configuration,
      webGPUShaderCompiler,
      shaderCompiler: configuration.shaderCompiler ?? new ShaderCompiler(webGPUShaderCompiler),
      builtinShaders: configuration.builtinShaders ?? (builtinShaders ??= Core.createBuiltinShaders(sources))
    });
  }
}
