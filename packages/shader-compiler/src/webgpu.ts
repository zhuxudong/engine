import { ShaderMacroProcessor } from "@galacean/engine-core";
import {
  finalizeShaderUniforms,
  type IShaderUniformSelection,
  type IShaderInfo,
  type IWebGPUShaderCompiler,
  type IWebGPUShaderOptions,
  type IWebGPUShaderProgram
} from "@galacean/engine-design";
import { WGSLBackend } from "./webgpu/WGSLBackend";
import type { InitInput } from "web-naga";

/** Compile an instruction-based pass for a concrete macro set and vertex layout. */
export function compileWebGPUShaderPass(
  compiler: Pick<IWebGPUShaderCompiler, "compileWebGPUVariant">,
  pass: Pick<IShaderInfo, "uniformBlocks" | "uniformPlan" | "vertexShaderInstructions" | "fragmentShaderInstructions">,
  features: ReadonlyMap<string, string> = new Map(),
  options: IWebGPUShaderOptions = {}
): IWebGPUShaderProgram {
  const macros = new Map([
    ["GRAPHICS_API_WEBGPU", ""],
    ["HAS_TEX_LOD", ""],
    ["HAS_DERIVATIVES", ""],
    ["GL_ES", "1"],
    ["GL_FRAGMENT_PRECISION_HIGH", "1"],
    ["__VERSION__", "300"]
  ]);
  features.forEach((value, name) => macros.set(name, value));
  const vs: IShaderUniformSelection[] = [],
    fs: IShaderUniformSelection[] = [];
  const v = ShaderMacroProcessor.evaluate(pass.vertexShaderInstructions!, macros, pass.uniformPlan?.vertex, vs);
  const f = ShaderMacroProcessor.evaluate(pass.fragmentShaderInstructions!, macros, pass.uniformPlan?.fragment, fs);
  const variant = finalizeShaderUniforms(v, f, vs, fs, {
    maxBlockBytes: options.maxUniformBlockBytes ?? 16384,
    maxBindings: 24,
    explicitBlocks: pass.uniformBlocks?.length,
    instancing: macros.has("RENDERER_GPU_INSTANCE") ? pass.uniformPlan?.instancing : undefined
  });
  if (variant.instanceOverflow) throw new Error("The selected instance does not fit a uniform buffer binding.");
  const i = variant.instanceLayout;
  return compiler.compileWebGPUVariant(variant.vertexSource, variant.fragmentSource, {
    ...options,
    uniformBlocks: [...(pass.uniformBlocks ?? []), ...variant.uniformBlocks],
    instanceBindingName: i?.bindingName,
    instanceByteLength: i ? i.headerBytes + i.structSize * i.instanceMaxCount : undefined
  });
}

/** Load the WGSL translator only for applications or offline builds that request WebGPU. */
export async function createWebGPUShaderCompiler(moduleOrPath?: InitInput): Promise<IWebGPUShaderCompiler> {
  const naga = await import("web-naga");
  await naga.default(moduleOrPath ? { module_or_path: moduleOrPath } : undefined);
  const backend = new WGSLBackend((source, stage) => {
    const frontend = naga.GlslFrontend.new();
    try {
      const module = frontend.parse(source, stage === "vertex" ? naga.ShaderStage.Vertex : naga.ShaderStage.Fragment);
      try {
        return module.to_wgsl();
      } finally {
        module.free();
      }
    } catch (error) {
      throw new Error(`WGSL ${stage} compilation failed: ${error}`, { cause: error });
    } finally {
      frontend.free();
    }
  });
  return {
    compileWebGPUVariant: backend.compileWebGPUVariant.bind(backend),
    compileDefaultVariant(program: IShaderInfo) {
      return compileWebGPUShaderPass(backend, program);
    }
  };
}
