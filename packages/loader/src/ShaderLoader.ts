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
      computeShaderInstructions?: unknown;
      computeWorkgroupSize?: readonly [string, string, string];
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
        return Shader._createFromPrecompiled(data);
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
  return resourceManager.engine.graphicsBackend;
}
