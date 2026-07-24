import * as CoreObjects from "@galacean/engine-core";
import { Engine, Loader, Polyfill, SystemInfo } from "@galacean/engine-core";
import { ShaderPool } from "./ShaderPool";
//@ts-ignore
export const version = `__buildVersion`;

console.log(`Galacean Engine Version: ${version}`);

export * from "@galacean/engine-core";
export * from "@galacean/engine-loader";
export * from "@galacean/engine-math";
export * from "@galacean/engine-rhi-webgl";
export * from "@galacean/engine-rhi-webgpu";

for (const key in CoreObjects) {
  Loader.registerClass(key, CoreObjects[key]);
}

// Bootstrap the Galacean engine flavor: browser polyfills first (must
// patch globals before anything else runs), then platform detection
// (other modules may read `SystemInfo.platform`), then built-in shader
// include registration. The built-in shader target is registered during Engine
// construction, after its WebGL/WebGPU backend is known and before BasicResources
// creates default materials.
//
// Keeping these here rather than inside `engine-core` lets `engine-core`
// stay flavor-agnostic (no top-level browser side effects, no built-in
// shader bundle dependency), which in turn lets the offline shader
// compiler import core's enums without dragging the full runtime closure.
Polyfill.registerPolyfill();
// @ts-ignore — `_initialize` is `SystemInfo` @internal.
SystemInfo._initialize();
ShaderPool.init();
// @ts-ignore — `_addConstructHandler` is the internal core-to-flavor initialization bridge.
Engine._addConstructHandler((engine) => ShaderPool.registerShaders(engine));
