import type { SurfaceWorld } from "../../src/surface/SurfaceWorld";
import { DebugInspector } from "../../src/debug/DebugInspector";
import type { GrasslandsCloudSnapshot } from "./GrasslandsCloudSystem";
import type { GrasslandsEnvironmentTuning } from "./GrasslandsEnvironment";
import type { TerrainFirstPersonSnapshot } from "../../src/TerrainFirstPersonController";

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
  /** Returns the active first-person ground-follow state. */
  getFirstPerson(): TerrainFirstPersonSnapshot;
  /**
   * Updates camera height above terrain.
   * @param height Eye height in world metres.
   */
  setFirstPersonEyeHeight(height: number): void;
  /**
   * Updates first-person WASD movement speed.
   * @param speed Movement speed in world metres per second.
   */
  setFirstPersonMoveSpeed(speed: number): void;
  /** Returns the shared SurfaceWorld runtime snapshot. */
  inspectSurface(): ReturnType<SurfaceWorld["inspect"]>;
}

/**
 * Mounts the Grasslands-only composition controls over the scene.
 * @param api Ready scene runtime contract.
 */
export function mountGrasslandsInspector(api: GrasslandsSceneDebugApi): void {
  const inspector = new DebugInspector("Grasslands scene inspector");
  const state = { ...api.getScene() };
  const sceneFolder = inspector.folder("Scene / 场景复刻", true);

  const cameraState = { ...api.getFirstPerson() };
  const camera = inspector.subfolder(sceneFolder, "Camera / 相机", true);
  annotate(
    camera.add(cameraState, "eyeHeight", 0.5, 3, 0.01),
    "Eye height / 视点高度",
    "复用写实地形的 GroundFollow，在 Unity 起始 XZ 上保持相机距地表的高度。"
  ).onChange((height: number) => api.setFirstPersonEyeHeight(height));
  annotate(
    camera.add(cameraState, "moveSpeed", 1, 30, 0.1),
    "Move speed / 移动速度",
    "FreeControl 的 WASD 移动速度，单位为米/秒；左键拖动改变朝向。"
  ).onChange((speed: number) => api.setFirstPersonMoveSpeed(speed));

  const composition = inspector.subfolder(sceneFolder, "Composition / 场景构成", true);
  annotate(
    composition.add(state, "architecture"),
    "Architecture / 建筑",
    "显示 Unity authored 的 Arch、Bridge、Shrine、Columns、Walls、Fence 与藤蔓；不属于 SurfaceWorld PCG。"
  ).onChange((architecture: boolean) => api.setScene({ architecture }));
  annotate(
    composition.add(state, "clouds"),
    "Clouds / 云",
    "显示 27 个固定 seed 的 world-space mesh 云；保留源 emitter 旋转，按 4 个预设进行 GPU instancing。"
  ).onChange((clouds: boolean) => api.setScene({ clouds }));
  annotate(
    composition.add(state, "animation"),
    "Animation / 动画",
    "同时推进云漂移与方向光 cookie 云影；关闭后时间冻结，便于截图差异验证。"
  ).onChange((animation: boolean) => api.setScene({ animation }));

  const lighting = inspector.subfolder(sceneFolder, "Lighting / 光照", true);
  annotate(
    lighting.add(state, "directLight"),
    "Direct light / 直接光",
    "切换 Grasslands 导出的方向光，不改变烘焙环境光。"
  ).onChange((directLight: boolean) => api.setScene({ directLight }));
  annotate(
    lighting.add(state, "shadows"),
    "Shadows / 阴影",
    "切换方向光四级联软阴影；植被可见 pass 与阴影 pass 使用同一风动位移。"
  ).onChange((shadows: boolean) => api.setScene({ shadows }));
  annotate(
    lighting.add(state, "environment"),
    "Environment / 环境光",
    "切换从 Grasslands Skybox.hdr 烘焙的 diffuse/specular ambient light。"
  ).onChange((environment: boolean) => api.setScene({ environment }));
  annotate(
    lighting.add(state, "cloudShadows"),
    "Cloud shadows / 云影",
    "切换 1000m world-space light-cookie 投影；源方向光局部 X 轴以 12m/s 移动。"
  ).onChange((cloudShadows: boolean) => api.setScene({ cloudShadows }));

  const atmosphere = inspector.subfolder(sceneFolder, "Atmosphere / 大气", true);
  annotate(
    atmosphere.add(state, "sky"),
    "Sky / 天空",
    "显示 Grasslands HDR 天空，使用导出的 exposure 0.45、rotation 64° 与 tint。"
  ).onChange((sky: boolean) => api.setScene({ sky }));
  annotate(
    atmosphere.add(state, "fog"),
    "Fog / 雾",
    "切换导出的指数雾；density 0.0004，同时作用于地形、地表、建筑和云。"
  ).onChange((fog: boolean) => api.setScene({ fog }));
  annotate(
    atmosphere.add(state, "postProcess"),
    "Post-process / 后处理",
    "切换 Grasslands 专属 HDR post exposure、ACES 与 Bloom。"
  ).onChange((postProcess: boolean) => api.setScene({ postProcess }));

  const diagnostics = inspector.subfolder(sceneFolder, "Diagnostics / 诊断", true);
  const setReadout = inspector.addReadout(diagnostics, "Runtime / 运行时");
  const updateReadout = (): void => {
    const clouds = api.inspectClouds();
    const surface = api.inspectSurface();
    setReadout(
      [
        `clouds: ${clouds.instances} instances / ${clouds.drawGroups} draw groups`,
        `cloud time: ${clouds.time.toFixed(2)}s`,
        `surface: ${surface.visibleInstances.toLocaleString("en-US")} / ${surface.totalInstances.toLocaleString("en-US")}`,
        `surface batches: ${surface.rendererBatches}`,
        `surface cells: ${surface.visibleRanges} / ${surface.totalRanges}`
      ].join("\n")
    );
  };
  updateReadout();
  window.setInterval(updateReadout, 500);
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
