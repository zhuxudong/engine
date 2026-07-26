import type { SurfaceWorld } from "../../src/surface/SurfaceWorld";
import type { DebugInspector } from "../../src/debug/DebugInspector";
import type { GrasslandsCloudSnapshot } from "./GrasslandsCloudSystem";
import type { GrasslandsEnvironmentTuning } from "./GrasslandsEnvironment";

/** Scene-composition switches that remain outside the portable SurfaceWorld contract. */
export interface GrasslandsSceneTuning extends GrasslandsEnvironmentTuning {
  readonly architecture: boolean;
  readonly clouds: boolean;
  readonly postProcess: boolean;
}

/** Runtime API consumed by the Grasslands-only scene inspector. */
export interface GrasslandsSceneDebugApi {
  /** Returns the current scene-composition switches. */
  getScene(): GrasslandsSceneTuning;
  /**
   * Applies authored scene controls without mutating SurfaceWorld inputs.
   * @param values Partial scene-composition switches.
   */
  setScene(values: Partial<GrasslandsSceneTuning>): void;
  /** Returns deterministic cloud batching and animation diagnostics. */
  inspectClouds(): GrasslandsCloudSnapshot;
  /** Returns authored architecture placement and renderer counts. */
  inspectArchitecture(): { readonly placements: number; readonly renderers: number };
  /** Returns the shared SurfaceWorld runtime snapshot. */
  inspectSurface(): ReturnType<SurfaceWorld["inspect"]>;
}

/**
 * Adds Grasslands-only composition controls to the shared terrain inspector.
 * @param inspector Shared terrain inspector.
 * @param api Ready scene runtime contract.
 */
export function mountGrasslandsInspector(inspector: DebugInspector, api: GrasslandsSceneDebugApi): void {
  const state = { ...api.getScene() };
  const sceneFolder = inspector.folder("Scene / 场景复刻", false);

  const composition = inspector.subfolder(sceneFolder, "Composition / 场景构成", true);
  annotate(
    composition.add(state, "architecture"),
    "Architecture / 建筑",
    "显示 Arch、Bridge、Shrine、Columns、Walls、Fence 与藤蔓等场景建筑；不属于 SurfaceWorld PCG。"
  ).onChange((architecture: boolean) => api.setScene({ architecture }));
  annotate(
    composition.add(state, "clouds"),
    "Clouds / 云",
    "显示离地净空足够的 world-space 天空云；贴地 emitter 归为谷雾并排除，保留源旋转与固定 seed。"
  ).onChange((clouds: boolean) => api.setScene({ clouds }));
  annotate(
    composition.add(state, "animation"),
    "Animation / 动画",
    "同时推进云漂移与方向光 cookie 云影；关闭后时间冻结，便于截图差异验证。"
  ).onChange((animation: boolean) => api.setScene({ animation }));

  const atmosphere = inspector.subfolder(sceneFolder, "Cloud & fog / 云雾", true);
  annotate(
    atmosphere.add(state, "cloudShadows"),
    "Cloud shadows / 云影",
    "切换 1000m world-space light-cookie 投影；源方向光局部 X 轴以 12m/s 移动。"
  ).onChange((cloudShadows: boolean) => api.setScene({ cloudShadows }));
  annotate(
    atmosphere.add(state, "fog"),
    "Fog / 雾",
    "切换导出的指数雾；density 0.0004，同时作用于地形、地表、建筑和云。"
  ).onChange((fog: boolean) => api.setScene({ fog }));
}

function annotate<T extends { domElement: HTMLElement; name(label: string): T }>(
  controller: T,
  label: string,
  description: string
): T {
  controller.name(label);
  controller.domElement.title = description;
  return controller;
}
