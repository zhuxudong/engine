import {
  AssetPromise,
  AssetType,
  LoadItem,
  Loader,
  ResourceManager,
  Shader,
  resourceLoader
} from "@galacean/engine-core";
import { ShaderLanguage } from "@galacean/engine-core";

interface IPrecompiledShader {
  name: string;
  platformTarget: number;
  subShaders: {
    passes: {
      isUsePass: boolean;
      vertexShaderInstructions?: unknown;
      fragmentShaderInstructions?: unknown;
      reflection?: unknown;
    }[];
  }[];
}

@resourceLoader(AssetType.Shader, ["shader", "shaderc", "wgslc"])
class ShaderLoader extends Loader<Shader> {
  load(item: LoadItem, resourceManager: ResourceManager): AssetPromise<Shader> {
    const url = item.url!;
    const backend = getBackend(resourceManager);
    const isWebGPU = backend === "webgpu";
    const platformTarget = isWebGPU ? ShaderLanguage.WGSL : ShaderLanguage.GLSLES100;

    if (isPrecompiledShaderUrl(url)) {
      const artifactUrl = getArtifactUrl(url, isWebGPU);
      // @ts-ignore
      return resourceManager._request(artifactUrl, { ...item, type: "json" }).then((data: IPrecompiledShader) => {
        if (data.platformTarget !== platformTarget) {
          throw new Error(
            `Shader artifact "${artifactUrl}" targets ${ShaderLanguage[data.platformTarget]}, but ${backend} requires ${ShaderLanguage[platformTarget]}.`
          );
        }
        // @ts-ignore - _createFromPrecompiled is @internal
        const shader = Shader._createFromPrecompiled(data);
        applyReflection(shader, data, platformTarget);
        return shader;
      });
    }

    // @ts-ignore
    return resourceManager._request<string>(url, { ...item, type: "text" }).then((code: string) => {
      return Shader.create(code, platformTarget, url);
    });
  }
}

function isPrecompiledShaderUrl(url: string): boolean {
  return /\.(shaderc|wgslc)(?:[?#].*)?$/.test(url);
}

function getArtifactUrl(url: string, isWebGPU: boolean): string {
  if (isWebGPU && /\.shaderc(?:[?#].*)?$/.test(url)) {
    return url.replace(/\.shaderc(?=[?#]|$)/, ".wgslc");
  }
  return url;
}

function getBackend(resourceManager: ResourceManager): "webgl" | "webgpu" {
  // `IHardwareRenderer` is internal to engine-core, while loader needs its backend only
  // to select the already built artifact. Keep that bridge local instead of widening Engine's API.
  return (resourceManager.engine as unknown as { _hardwareRenderer: { backend: "webgl" | "webgpu" } })._hardwareRenderer
    .backend;
}

function applyReflection(shader: Shader, data: IPrecompiledShader, platformTarget: ShaderLanguage): void {
  for (let subShaderIndex = 0; subShaderIndex < data.subShaders.length; subShaderIndex++) {
    const sourcePasses = data.subShaders[subShaderIndex].passes;
    const passes = shader.subShaders[subShaderIndex].passes;
    for (let passIndex = 0; passIndex < sourcePasses.length; passIndex++) {
      const sourcePass = sourcePasses[passIndex];
      if (sourcePass.isUsePass) continue;
      // @ts-ignore - target registration is an internal bridge between the loader and ShaderPass.
      passes[passIndex]._setShaderTarget(platformTarget, {
        vertex: "",
        fragment: "",
        vertexShaderInstructions: sourcePass.vertexShaderInstructions,
        fragmentShaderInstructions: sourcePass.fragmentShaderInstructions,
        reflection: sourcePass.reflection
      });
    }
  }
}
