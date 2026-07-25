import { MSAASamples, TonemappingMode } from "@galacean/engine";
import { DebugInspector } from "./DebugInspector";
import { TERRAIN_DEBUG_VIEW_INFO } from "./TerrainDebugContract";
import type { SurfaceCategory } from "../surface/SurfaceContract";
import type { SurfaceRuntimeTuning } from "../surface/SurfaceRuntimeContract";
import type {
  TerrainBackgroundMode,
  TerrainCameraSnapshot,
  TerrainCameraPoseName,
  TerrainDebugApi,
  TerrainDebugLayerTuningSnapshot,
  TerrainDebugViewName,
  TerrainFirstPersonSnapshot,
  TerrainRenderingSnapshot,
  TerrainRenderingTuning
} from "./TerrainDebugContract";

const MSAA_OPTIONS = {
  "None / 无": MSAASamples.None,
  "2×": MSAASamples.TwoX,
  "4×": MSAASamples.FourX,
  "8×": MSAASamples.EightX
} as const;

const TONEMAPPING_OPTIONS = {
  "Neutral / 中性": TonemappingMode.Neutral,
  "ACES / 电影": TonemappingMode.ACES
} as const;

const SURFACE_CATEGORY_LABELS: Readonly<Record<SurfaceCategory, string>> = {
  grass: "Grass / 草",
  flower: "Flowers / 花",
  shrub: "Shrubs / 灌木",
  tree: "Trees / 树木",
  rock: "Rocks / 岩石",
  cliff: "Cliffs / 悬崖"
};

/** Optional composition hooks around the shared terrain inspector. */
export interface TerrainDebugInspectorOptions {
  /** Accessible dat.gui panel label. */
  readonly title?: string;
  /** Whether the demo exposes the independent water diagnostic. */
  readonly showWater?: boolean;
  /**
   * Adds demo-specific top-level folders to the same dat.gui instance.
   * @param inspector Shared inspector receiving the extension.
   */
  readonly extend?: (inspector: DebugInspector) => void;
}

/**
 * Mounts the terrain inspector over the production demo.
 * @param api Ready production terrain debug contract.
 * @param options Optional title, capabilities, and demo-specific extension.
 * @returns The shared inspector instance.
 */
export function mountTerrainInspector(
  api: TerrainDebugApi,
  options: TerrainDebugInspectorOptions = {}
): DebugInspector {
  const inspector = new DebugInspector(options.title ?? "Terrain material inspector");
  const snapshot = api.getTuning();
  const surfaceState = cloneSurfaceTuning(api.getSurface());
  const surfaceSnapshot = api.inspectSurface();
  const initialLayer = api.layers[Math.min(1, api.layers.length - 1)]?.id ?? 0;
  const query = new URLSearchParams(location.search);
  const requestedView = query.get("view") as TerrainDebugViewName | null;
  const requestedPose = query.get("pose");
  const sceneState = {
    view: requestedView && api.views.includes(requestedView) ? requestedView : ("surface" as TerrainDebugViewName),
    pose:
      requestedPose && api.poses.includes(requestedPose as TerrainCameraPoseName)
        ? requestedPose
        : (api.poses[0] ?? "first-person"),
    layer: initialLayer,
    reset: () => {
      api.resetTuning();
      replaceInspectorState(api, snapshot, layerState, materialState, worldState, worldNoiseState);
      replaceSurfaceState(surfaceState, api.getSurface());
      Object.assign(waterState, api.getWaterDebug());
      inspector.gui.updateDisplay();
      selectLayer(sceneState.layer);
      syncWorldNoiseVisibility();
      updateSurfaceReadout();
    }
  };
  const layerState: TerrainDebugLayerTuningSnapshot = { ...snapshot.layers[initialLayer] };
  const materialState = createMaterialState(snapshot);
  const worldState = { background: snapshot.world.background };
  const worldNoiseState = createWorldNoiseState(snapshot);
  const waterState = api.getWaterDebug();
  const firstPersonState: TerrainFirstPersonSnapshot = api.getFirstPerson();
  const renderingState = api.getRendering();
  const selectPreview = new Map<number, () => void>();
  options.extend?.(inspector);
  const renderingFolder = inspector.folder("Rendering / 渲染", true);
  const terrainFolder = inspector.folder("Terrain / 地形", true);
  const surfaceFolder = inspector.folder("Surface / 地表", true);

  const syncRenderingState = (): void => {
    replaceRenderingState(renderingState, api.getRendering());
    inspector.gui.updateDisplay();
  };
  const updateRendering = (values: TerrainRenderingTuning): void => {
    api.setRendering(values);
    syncRenderingState();
  };

  const sceneFolder = inspector.subfolder(terrainFolder, "Scene / 场景", true);
  annotate(
    sceneFolder.add(sceneState, "view", debugViewOptions(api)),
    "Debug output / 调试输出",
    "选择一个数据通道或生产材质输出；说明会在本组底部更新。"
  ).onChange((view: TerrainDebugViewName) => {
    api.setView(view);
    setViewExplanation(TERRAIN_DEBUG_VIEW_INFO[view].description);
  });
  const setViewExplanation = inspector.addReadout(sceneFolder, "View meaning / 视图说明");
  const eyeHeightController = annotate(
    sceneFolder.add(firstPersonState, "eyeHeight", 0.5, 3, 0.01),
    "Ground clearance / 离地高度",
    "仅在第一人称下生效；单位为米。"
  ).onChange((height: number) => api.setFirstPersonEyeHeight(height));
  const moveSpeedController = annotate(
    sceneFolder.add(firstPersonState, "moveSpeed", 1, 30, 0.1),
    "Move speed / 移动速度",
    "仅在第一人称下生效；单位为米/秒。FreeControl 提供左键拖动旋转与 WASD 移动，地形脚本只负责贴地。"
  ).onChange((speed: number) => api.setFirstPersonMoveSpeed(speed));
  const syncFirstPersonVisibility = (): void => {
    for (const controller of [eyeHeightController, moveSpeedController]) {
      const row = controller.domElement.parentElement;
      if (row) row.hidden = sceneState.pose !== "first-person";
    }
  };
  annotate(sceneFolder.add(sceneState, "pose", api.poses), "Camera pose / 相机视角", "第一人称使用 CPU 高度场贴地；其他选项为可重复截图视角。").onChange(
    (pose: string) => {
      api.setPose(pose as TerrainCameraPoseName);
      Object.assign(firstPersonState, api.getFirstPerson());
      syncFirstPersonVisibility();
      inspector.gui.updateDisplay();
    }
  );
  syncFirstPersonVisibility();
  annotate(sceneFolder.add(sceneState, "reset"), "Reset terrain values / 重置地形参数", "恢复 manifest 默认参数。");

  const lightingFolder = inspector.subfolder(renderingFolder, "Lighting / 光照", true);
  annotate(
    lightingFolder.add(renderingState.lighting, "directLight"),
    "Direct light / 直接光",
    "启用方向光与阴影接收；关闭后只保留烘焙环境光。"
  ).onChange((value: boolean) => updateRendering({ lighting: { directLight: value } }));
  annotate(
    lightingFolder.add(renderingState.lighting, "shadows"),
    "Shadows / 阴影",
    "让方向光生成并采样级联阴影图；关闭后保留同一盏方向光，只移除阴影投射与接收。"
  ).onChange((value: boolean) => updateRendering({ lighting: { shadows: value } }));
  annotate(
    lightingFolder.add(renderingState.lighting, "environment"),
    "Environment / 环境",
    "切换离线烘焙 `.ambLight` 的环境漫反射；与直接光共用逐片元地形与纹理法线。"
  ).onChange((value: boolean) => updateRendering({ lighting: { environment: value } }));
  annotate(
    lightingFolder.add(renderingState.lighting, "skybox"),
    "Skybox / 天空盒",
    "只切换 HDR 天空背景绘制，不改变地形的环境漫反射。"
  ).onChange((value: boolean) => updateRendering({ lighting: { skybox: value } }));

  const cameraFolder = inspector.subfolder(renderingFolder, "Camera / 相机", true);
  annotate(
    cameraFolder.add(renderingState.camera, "hdr"),
    "HDR / 高动态范围",
    "切换 Camera.enableHDR；引擎只会在 WebGL2 或支持 half-float 的设备上接受 HDR。"
  ).onChange((value: boolean) => updateRendering({ camera: { hdr: value } }));
  annotate(
    cameraFolder.add(renderingState.camera, "msaaSamples", MSAA_OPTIONS),
    "MSAA samples / 多重采样",
    "写入 Camera.msaaSamples 的真实引擎枚举：None=1、2×=2、4×=4、8×=8；超过硬件能力时引擎会钳制实际值。"
  ).onChange((value: number) => updateRendering({ camera: { msaaSamples: Number(value) as MSAASamples } }));
  const setCameraReadout = inspector.addReadout(cameraFolder, "Camera JSON / 相机 JSON");
  const cameraActions = {
    output: () => {
      const output = formatCameraSnapshot(api.getCamera());
      setCameraReadout(output);
      console.info("[terrain-camera]", output);
      void navigator.clipboard?.writeText(output).catch(() => undefined);
    }
  };
  annotate(
    cameraFolder.add(cameraActions, "output"),
    "Output camera pose / 输出相机姿态",
    "输出可复现的位置、世界旋转四元数、朝向和视场角；同时尝试复制到剪贴板。"
  );

  const postProcessFolder = inspector.subfolder(renderingFolder, "Post-process / 后处理", true);
  annotate(
    postProcessFolder.add(renderingState.postProcess, "enabled"),
    "Post process / 后处理",
    "切换 Camera.enablePostProcess；关闭时场景 post-process manager 不执行。"
  ).onChange((value: boolean) => updateRendering({ postProcess: { enabled: value } }));
  annotate(
    postProcessFolder.add(renderingState.postProcess, "tonemapping"),
    "Tonemapping / 色调映射",
    "切换 TonemappingEffect.enabled；它与 Camera 的后处理总开关是两个不同层级。"
  ).onChange((value: boolean) => updateRendering({ postProcess: { tonemapping: value } }));
  annotate(
    postProcessFolder.add(renderingState.postProcess, "tonemappingMode", TONEMAPPING_OPTIONS),
    "Tonemapping mode / 色调映射模式",
    "写入 TonemappingEffect.mode：Neutral 偏保留色相与饱和度，ACES 使用更电影化的近似。"
  ).onChange((value: number) => updateRendering({ postProcess: { tonemappingMode: Number(value) as TonemappingMode } }));

  const surfaceVisibilityFolder = inspector.subfolder(surfaceFolder, "Visibility & density / 可见性与密度", true);
  for (const category of Object.keys(SURFACE_CATEGORY_LABELS) as SurfaceCategory[]) {
    const categoryFolder = inspector.subfolder(surfaceVisibilityFolder, SURFACE_CATEGORY_LABELS[category], true);
    annotate(
      categoryFolder.add(surfaceState.enabled, category),
      "Enabled / 显示",
      "只筛选已经离线编译的确定性实例，不会重新生成位置。"
    ).onChange((enabled: boolean) => {
      api.setSurface({ enabled: { [category]: enabled } });
      updateSurfaceReadout();
    });
    annotate(
      categoryFolder.add(surfaceState.density, category, 0, 1, 0.01),
      "Density multiplier / 密度倍率",
      "按稳定实例顺序保留前 N%；相同值每次刷新得到相同结果。"
    ).onChange((density: number) => {
      api.setSurface({ density: { [category]: density } });
      updateSurfaceReadout();
    });
    const rule = surfaceSnapshot.sourceRules.find((candidate) => candidate.category === category);
    const count = surfaceSnapshot.categoryCounts[category];
    inspector.addReadout(categoryFolder, "Compiled inputs / 编译输入")(
      rule
        ? [
            `instances: ${count.toLocaleString("en-US")}`,
            `mode: ${rule.mode}`,
            `density: ${rule.densityPerSquareMetre}/m²`,
            `spacing: ${rule.spacing}m`,
            `scale XZ: ${rule.scale.horizontal[0]}..${rule.scale.horizontal[1]}`,
            `scale Y: ${rule.scale.vertical[0]}..${rule.scale.vertical[1]}`,
            `cell: ${rule.cellSize}m`
          ].join("\n")
        : `instances: ${count.toLocaleString("en-US")}\nno compiled rule`
    );
  }

  const surfaceWindFolder = inspector.subfolder(surfaceFolder, "Wind / 风动", true);
  annotate(surfaceWindFolder.add(surfaceState.wind, "enabled"), "Enabled / 启用", "关闭后冻结植被顶点位移，实例位置不变。")
    .onChange((enabled: boolean) => api.setSurface({ wind: { enabled } }));
  annotate(
    surfaceWindFolder.add(surfaceState.wind, "strength", 0, 2, 0.01),
    "Strength / 强度",
    "乘到每个材质的源风力；0 表示无位移。"
  ).onChange((strength: number) => api.setSurface({ wind: { strength } }));

  const surfaceLodFolder = inspector.subfolder(surfaceFolder, "LOD & culling / 层级与剔除", true);
  annotate(
    surfaceLodFolder.add(surfaceState.lod, "enabled"),
    "Mesh LOD / 网格层级",
    "按投影高度选择 prototype 的真实 mesh LOD；关闭后固定 LOD0。"
  ).onChange((enabled: boolean) => {
    api.setSurface({ lod: { enabled } });
    updateSurfaceReadout();
  });
  annotate(
    surfaceLodFolder.add(surfaceState.lod, "distanceScale", 0.25, 2, 0.01),
    "Distance scale / 距离倍率",
    "同时缩放 prototype 最大可见距离与 LOD 阈值；值越小越早剔除和降级。"
  ).onChange((distanceScale: number) => {
    api.setSurface({ lod: { distanceScale } });
    updateSurfaceReadout();
  });
  const setSurfaceReadout = inspector.addReadout(surfaceLodFolder, "Runtime cells / 运行时 cell");

  const surfaceDebugFolder = inspector.subfolder(surfaceFolder, "Debug / 调试", true);
  annotate(
    surfaceDebugFolder.add(surfaceState, "debugView", {
      "Surface / 材质": "surface",
      "World normal / 世界法线": "normal",
      "Wind weight / 风动权重": "wind-weight",
      "Category / 实例类别": "category",
      "Spatial cell / 空间 cell": "cell"
    }),
    "Debug output / 调试输出",
    "切换实际渲染实例的材质、世界法线、根部锁定、类别或离线空间 cell；风动权重中蓝色固定、黄色摆动。"
  ).onChange((view: SurfaceRuntimeTuning["debugView"]) => api.setSurfaceDebugView(view));
  for (const mask of surfaceSnapshot.debugMasks) {
    inspector.addImagePreview(surfaceDebugFolder, {
      label:
        `${mask.id} density mask / ${mask.id} 密度掩码` +
        ` · XZ (${mask.origin[0]}, ${mask.origin[1]})` +
        ` · ${mask.size[0]}×${mask.size[1]}m`,
      src: mask.url
    });
  }

  function updateSurfaceReadout(): void {
    const current = api.inspectSurface();
    setSurfaceReadout(
      [
        `visible: ${current.visibleInstances.toLocaleString("en-US")} / ${current.totalInstances.toLocaleString("en-US")}`,
        `cells: ${current.visibleRanges} / ${current.totalRanges}`,
        `crossfading cells: ${current.transitioningRanges}`,
        `renderer batches: ${current.rendererBatches}`,
        `LOD: ${current.lodCounts.map((count, index) => `${index}=${count.toLocaleString("en-US")}`).join(", ")}`,
        `impostor: ${current.impostorInstances.toLocaleString("en-US")}`
      ].join("\n")
    );
  }
  updateSurfaceReadout();

  const worldFolder = inspector.subfolder(terrainFolder, "World background / 世界背景", true);
  annotate(
    worldFolder.add(worldState, "background", { "None / 无": "none", "Flat / 平坦": "flat", "Noise / 噪声": "noise" }),
    "Background mode / 背景模式",
    "None 裁掉区域外网格；Flat 以 Y=0 延伸；Noise 使用程序化高度场在区域边缘连续过渡。"
  ).onChange((mode: TerrainBackgroundMode) => {
    api.setWorldBackground(mode);
    syncWorldNoiseVisibility();
  });

  const worldNoiseFolder = inspector.subfolder(worldFolder, "World noise / 世界噪声", worldState.background === "noise");
  annotate(worldNoiseFolder.add(worldNoiseState, "fragmentNormals"), "Fragment normals / 片元法线", "启用后在 fragment 重新采样 world noise 导数；关闭则使用 vertex 传递的导数。")
    .onChange((value: boolean) => api.setWorldNoiseTuning({ fragmentNormals: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "regionBlend", 0.05, 0.95, 0.01), "Region blend / 区域过渡", "区域边缘由 authored height 过渡到 world noise 的宽度。")
    .onChange((value: number) => api.setWorldNoiseTuning({ regionBlend: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "maxOctaves", 0, 15, 1), "Max octaves / 最大层数", "相机附近 morenoise 的最大 octave 数。")
    .onChange((value: number) => api.setWorldNoiseTuning({ maxOctaves: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "minOctaves", 0, 15, 1), "Min octaves / 最小层数", "远距离 morenoise 的最小 octave 数。")
    .onChange((value: number) => api.setWorldNoiseTuning({ minOctaves: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "lodDistance", 0, 40000, 1), "LOD distance / LOD 距离", "从最大 octave 衰减到最小 octave 的相机距离。")
    .onChange((value: number) => api.setWorldNoiseTuning({ lodDistance: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "scale", 0.25, 20, 0.01), "Scale / 频率", "world noise 的空间频率乘数。")
    .onChange((value: number) => api.setWorldNoiseTuning({ scale: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "height", 0, 1000, 0.1), "Height / 高度", "world noise 的高度乘数（米）。")
    .onChange((value: number) => api.setWorldNoiseTuning({ height: value }));
  annotate(worldNoiseFolder.add(worldNoiseState, "offsetX"), "Offset X / X 偏移", "world noise 在 region 坐标中的 X 平移。")
    .onChange((value: number) => api.setWorldNoiseTuning({ offset: [value, worldNoiseState.offsetY, worldNoiseState.offsetZ] }));
  annotate(worldNoiseFolder.add(worldNoiseState, "offsetY"), "Offset Y / Y 偏移", "world noise 的最终高度偏移，按 terrain 的 ×100 公式参与计算。")
    .onChange((value: number) => api.setWorldNoiseTuning({ offset: [worldNoiseState.offsetX, value, worldNoiseState.offsetZ] }));
  annotate(worldNoiseFolder.add(worldNoiseState, "offsetZ"), "Offset Z / Z 偏移", "world noise 在 region 坐标中的 Z 平移。")
    .onChange((value: number) => api.setWorldNoiseTuning({ offset: [worldNoiseState.offsetX, worldNoiseState.offsetY, value] }));

  const layerFolder = inspector.subfolder(terrainFolder, "Texture assets / 纹理资产", true);
  const manifestUrl = new URL(api.manifestUrl);
  for (const layer of api.layers) {
    const select = inspector.addImagePreview(layerFolder, {
      label: `${layer.id}: ${layer.name} · albedo`,
      src: new URL(layer.albedoHeight, manifestUrl).href,
      onSelect: () => {
        sceneState.layer = layer.id;
        selectLayer(layer.id);
        inspector.gui.updateDisplay();
      }
    });
    selectPreview.set(layer.id, select);
    inspector.addImagePreview(layerFolder, {
      label: `${layer.id}: ${layer.name} · normal`,
      src: new URL(layer.normalRoughness, manifestUrl).href,
      onSelect: () => {
        sceneState.layer = layer.id;
        selectLayer(layer.id);
        inspector.gui.updateDisplay();
      }
    });
  }
  annotate(layerFolder.add(layerState, "uvScale", 0.001, 2, 0.001), "UV scale / UV 缩放", "每米纹理重复率；值越大，纹理越密。")
    .onChange((value: number) => api.setLayerTuning(sceneState.layer, { uvScale: value }));
  annotate(layerFolder.add(layerState, "detilingRotation", 0, 1, 0.001), "Detiling rotation / 去重复旋转", "按地形单元随机旋转纹理的幅度。")
    .onChange((value: number) => api.setLayerTuning(sceneState.layer, { detilingRotation: value }));
  annotate(layerFolder.add(layerState, "detilingShift", 0, 1, 0.001), "Detiling shift / 去重复平移", "按地形单元随机平移纹理的幅度。")
    .onChange((value: number) => api.setLayerTuning(sceneState.layer, { detilingShift: value }));
  const normalDepthMaximum = Math.max(...snapshot.layers.map((layer) => layer.normalDepth), 1);
  annotate(layerFolder.add(layerState, "normalDepth", 0, normalDepthMaximum, 0.01), "Normal depth / 法线强度", "纹理法线对最终材质法线的强度；范围取自当前 manifest。")
    .onChange((value: number) => api.setLayerTuning(sceneState.layer, { normalDepth: value }));
  annotate(layerFolder.add(layerState, "aoStrength", 0, 2, 0.01), "AO strength / AO 强度", "纹理 height alpha 与 normal map 上朝分量共同衰减烘焙环境光；不改变直接光。")
    .onChange((value: number) => api.setLayerTuning(sceneState.layer, { aoStrength: value }));
  annotate(
    layerFolder.add(layerState, "roughnessMod", -1, 1, 0.01),
    "Roughness offset / 粗糙度偏移",
    "加到 normal/roughness alpha；随后与 color map alpha 合成为最终地形粗糙度。"
  )
    .onChange((value: number) => api.setLayerTuning(sceneState.layer, { roughnessMod: value }));
  annotate(layerFolder.add(snapshot.sampling, "bilerpEnabled"), "Bilerp / 四点插值", "开启后仅在放大采样的 loaded region 从四个 control texel 插值；默认开启以消除近处单 texel 的方块感。")
    .onChange((value: boolean) => api.setSamplingTuning({ bilerpEnabled: value }));
  annotate(layerFolder.add(snapshot.sampling, "blendSharpness", 0, 1, 0.01), "Blend sharpness / 高度混合锐度", "控制纹理 height alpha 对 base/overlay 混合的锐度。")
    .onChange((value: number) => api.setSamplingTuning({ blendSharpness: value }));
  annotate(samplingFolder.add(snapshot.sampling, "mipmapBias", 0.5, 1.5, 0.01), "Mipmap bias / Mip 偏差", "缩放 textureGrad 导数；更大更早使用低分辨率 Mip。")
    .onChange((value: number) => api.setSamplingTuning({ mipmapBias: value }));
  annotate(samplingFolder.add(snapshot.sampling, "biasDistance", 0, 16384, 1), "Bias distance / 偏差起距", "相机超过此距离后，Mip 导数向 Depth blur 过渡。")
    .onChange((value: number) => api.setSamplingTuning({ biasDistance: value }));
  annotate(samplingFolder.add(snapshot.sampling, "depthBlur", 0, 35, 0.1), "Depth blur / 远距模糊", "远距 Mip 导数附加值；用于抑制远处纹理闪烁。")
    .onChange((value: number) => api.setSamplingTuning({ depthBlur: value }));

  const autoFolder = inspector.subfolder(terrainFolder, "Auto shader / 自动材质", true);
  annotate(autoFolder.add(materialState.autoShader, "enabled"), "Enabled / 启用", "允许 control bit 0 用坡度与高度生成 base/overlay 混合。")
    .onChange((value: boolean) => api.setMaterialTuning({ autoShader: { enabled: value } }));
  annotate(autoFolder.add(materialState.autoShader, "slope", 0, 10, 0.01), "Auto slope / 自动坡度", "坡度越陡，混合越偏向 Base texture。")
    .onChange((value: number) => api.setMaterialTuning({ autoShader: { slope: value } }));
  annotate(autoFolder.add(materialState.autoShader, "heightReduction", 0, 1, 0.01), "Height reduction / 高度削减", "高度越高，自动混合越减少 Overlay texture。")
    .onChange((value: number) => api.setMaterialTuning({ autoShader: { heightReduction: value } }));
  annotate(autoFolder.add(materialState.autoShader, "baseTexture", layerOptions(api)), "Base texture / 基础纹理", "自动材质在陡坡或高处使用的 texture asset。")
    .onChange((value: number) => api.setMaterialTuning({ autoShader: { baseTexture: Number(value) } }));
  annotate(autoFolder.add(materialState.autoShader, "overlayTexture", layerOptions(api)), "Overlay texture / 覆盖纹理", "自动材质在平坦区域叠加的 texture asset。")
    .onChange((value: number) => api.setMaterialTuning({ autoShader: { overlayTexture: Number(value) } }));

  const dualFolder = inspector.subfolder(terrainFolder, "Dual scaling / 双尺度", true);
  annotate(dualFolder.add(materialState.dualScaling, "enabled"), "Enabled / 启用", "用一个更大尺度的 texture 样本平滑近远尺度过渡。")
    .onChange((value: boolean) => api.setMaterialTuning({ dualScaling: { enabled: value } }));
  annotate(dualFolder.add(materialState.dualScaling, "texture", layerOptions(api)), "Texture / 纹理", "参与 dual scaling 的 texture asset。")
    .onChange((value: number) => api.setMaterialTuning({ dualScaling: { texture: Number(value) } }));
  annotate(dualFolder.add(materialState.dualScaling, "reduction", 0.001, 1, 0.001), "Scale reduction / 尺度缩减", "第二尺度相对于原始 UV 的缩减系数。")
    .onChange((value: number) => api.setMaterialTuning({ dualScaling: { reduction: value } }));
  annotate(dualFolder.add(materialState.dualScaling, "triScaleReduction", 0.001, 1, 0.001), "World background scale / 世界背景缩放", "区域外 world background 同时缩放材质 UV、去重复单元与导数；与近远双尺度过渡无关。")
    .onChange((value: number) => api.setMaterialTuning({ dualScaling: { triScaleReduction: value } }));
  annotate(dualFolder.add(materialState.dualScaling, "near", 0, 1000, 1), "Near / 近距", "双尺度过渡开始的相机距离。")
    .onChange((value: number) => api.setMaterialTuning({ dualScaling: { near: value, far: materialState.dualScaling.far } }));
  annotate(dualFolder.add(materialState.dualScaling, "far", 1, 1000, 1), "Far / 远距", "双尺度过渡结束的相机距离。")
    .onChange((value: number) => api.setMaterialTuning({ dualScaling: { near: materialState.dualScaling.near, far: value } }));

  const projectionFolder = inspector.subfolder(terrainFolder, "Projection / 投影采样", true);
  annotate(projectionFolder.add(materialState.projection, "enabled"), "Enabled / 启用", "陡坡时从平面 UV 过渡到 terrain 的三向投影采样。")
    .onChange((value: boolean) => api.setMaterialTuning({ projection: { enabled: value } }));
  annotate(projectionFolder.add(materialState.projection, "threshold", 0, 0.99, 0.01), "Threshold / 阈值", "世界法线 Y 分量的投影转换阈值；值越高，越接近平面采样。")
    .onChange((value: number) => api.setMaterialTuning({ projection: { threshold: value } }));

  const macroFolder = inspector.subfolder(terrainFolder, "Macro variation / 宏观变化", true);
  annotate(macroFolder.add(materialState.macroVariation, "enabled"), "Enabled / 启用", "用低频 noise 打散大面积的 albedo 色调。")
    .onChange((value: boolean) => api.setMaterialTuning({ macroVariation: { enabled: value } }));
  annotate(macroFolder.addColor(materialState.macroVariation, "color1"), "Color 1 / 颜色一", "macro noise 第一端的颜色乘数。")
    .onChange((value: string) => api.setMaterialTuning({ macroVariation: { color1: hexToRgb(value) } }));
  annotate(macroFolder.addColor(materialState.macroVariation, "color2"), "Color 2 / 颜色二", "macro noise 第二端的颜色乘数。")
    .onChange((value: string) => api.setMaterialTuning({ macroVariation: { color2: hexToRgb(value) } }));
  annotate(macroFolder.add(materialState.macroVariation, "slope", 0, 1, 0.001), "Slope / 坡度", "混合低频 macro noise 时使用的坡度权重。")
    .onChange((value: number) => api.setMaterialTuning({ macroVariation: { slope: value } }));
  annotate(macroFolder.add(materialState.macroVariation, "noise1Scale", 0.001, 1, 0.001), "Noise 1 scale / 噪声一缩放", "第一低频噪声的 world UV 缩放。")
    .onChange((value: number) => api.setMaterialTuning({ macroVariation: { noise1Scale: value } }));
  annotate(macroFolder.add(materialState.macroVariation, "noise1Angle", 0, 6.283, 0.001), "Noise 1 angle / 噪声一角度", "第一低频噪声的 world UV 旋转（弧度）。")
    .onChange((value: number) => api.setMaterialTuning({ macroVariation: { noise1Angle: value } }));
  annotate(macroFolder.add(materialState.macroVariation, "noise1OffsetX", -4, 4, 0.01), "Noise 1 offset X / 噪声一 X 偏移", "第一低频噪声的 X 平移。")
    .onChange((value: number) => api.setMaterialTuning({ macroVariation: { noise1Offset: [value, materialState.macroVariation.noise1OffsetY] } }));
  annotate(macroFolder.add(materialState.macroVariation, "noise1OffsetY", -4, 4, 0.01), "Noise 1 offset Y / 噪声一 Y 偏移", "第一低频噪声的 Y 平移。")
    .onChange((value: number) => api.setMaterialTuning({ macroVariation: { noise1Offset: [materialState.macroVariation.noise1OffsetX, value] } }));
  annotate(macroFolder.add(materialState.macroVariation, "noise2Scale", 0.001, 1, 0.001), "Noise 2 scale / 噪声二缩放", "第二低频噪声的 world UV 缩放。")
    .onChange((value: number) => api.setMaterialTuning({ macroVariation: { noise2Scale: value } }));

  if (options.showWater !== false) {
    const waterFolder = inspector.subfolder(terrainFolder, "Water debug / 水体调试", true);
    annotate(waterFolder.add(waterState, "enabled"), "Enabled / 启用", "独立的 water-pcg 可视化；不会修改 control word、hole 或地形材质。")
      .onChange((enabled: boolean) => api.setWaterDebug({ enabled }));
    annotate(waterFolder.add(waterState, "height", -256, 512, 0.1), "Surface height / 水面高度", "水面 world Y；仅在水体调试开启时可见。")
      .onChange((height: number) => api.setWaterDebug({ height }));
  }

  selectLayer(initialLayer);
  syncWorldNoiseVisibility();
  setViewExplanation(TERRAIN_DEBUG_VIEW_INFO[sceneState.view].description);

  function selectLayer(layer: number): void {
    const tuning = snapshot.layers[layer] ?? snapshot.layers[0];
    if (!tuning) return;
    sceneState.layer = tuning.layer;
    Object.assign(layerState, tuning);
    api.setDebugLayer(tuning.layer);
    selectPreview.get(tuning.layer)?.();
    inspector.gui.updateDisplay();
  }

  function syncWorldNoiseVisibility(): void {
    const visible = worldState.background === "noise";
    const row = worldNoiseFolder.domElement.parentElement;
    if (row) row.hidden = !visible;
    if (visible) worldNoiseFolder.open();
  }
  return inspector;
}

function layerOptions(api: TerrainDebugApi): Record<string, number> {
  return Object.fromEntries(api.layers.map((layer) => [String(layer.id) + ": " + layer.name, layer.id]));
}

function debugViewOptions(api: TerrainDebugApi): Record<string, TerrainDebugViewName> {
  return Object.fromEntries(api.views.map((view) => [TERRAIN_DEBUG_VIEW_INFO[view].label, view]));
}

function createMaterialState(snapshot: ReturnType<TerrainDebugApi["getTuning"]>) {
  return {
    autoShader: { ...snapshot.material.autoShader },
    projection: { ...snapshot.material.projection },
    dualScaling: { ...snapshot.material.dualScaling },
    macroVariation: {
      ...snapshot.material.macroVariation,
      color1: rgbToHex(snapshot.material.macroVariation.color1),
      color2: rgbToHex(snapshot.material.macroVariation.color2),
      noise1OffsetX: snapshot.material.macroVariation.noise1Offset[0],
      noise1OffsetY: snapshot.material.macroVariation.noise1Offset[1]
    }
  };
}

function createWorldNoiseState(snapshot: ReturnType<TerrainDebugApi["getTuning"]>) {
  const { offset, ...noise } = snapshot.world.noise;
  return { ...noise, offsetX: offset[0], offsetY: offset[1], offsetZ: offset[2] };
}

function replaceInspectorState(
  api: TerrainDebugApi,
  snapshot: ReturnType<TerrainDebugApi["getTuning"]>,
  layerState: TerrainDebugLayerTuningSnapshot,
  materialState: ReturnType<typeof createMaterialState>,
  worldState: { background: TerrainBackgroundMode },
  worldNoiseState: ReturnType<typeof createWorldNoiseState>
): void {
  const defaults = api.getTuning();
  snapshot.layers.splice(0, snapshot.layers.length, ...defaults.layers.map((layer) => ({ ...layer })));
  Object.assign(snapshot.sampling, defaults.sampling);
  Object.assign(snapshot.material.autoShader, defaults.material.autoShader);
  Object.assign(snapshot.material.projection, defaults.material.projection);
  Object.assign(snapshot.material.dualScaling, defaults.material.dualScaling);
  Object.assign(snapshot.material.macroVariation, defaults.material.macroVariation);
  Object.assign(snapshot.world, defaults.world);
  Object.assign(layerState, snapshot.layers[layerState.layer] ?? snapshot.layers[0]);
  Object.assign(materialState.autoShader, snapshot.material.autoShader);
  Object.assign(materialState.projection, snapshot.material.projection);
  Object.assign(materialState.dualScaling, snapshot.material.dualScaling);
  Object.assign(materialState.macroVariation, {
    ...snapshot.material.macroVariation,
    color1: rgbToHex(snapshot.material.macroVariation.color1),
    color2: rgbToHex(snapshot.material.macroVariation.color2),
    noise1OffsetX: snapshot.material.macroVariation.noise1Offset[0],
    noise1OffsetY: snapshot.material.macroVariation.noise1Offset[1]
  });
  Object.assign(worldState, snapshot.world);
  Object.assign(worldNoiseState, createWorldNoiseState(snapshot));
}

function annotate<T extends { domElement: HTMLElement; name(label: string): T }>(controller: T, label: string, description: string): T {
  controller.name(label);
  controller.domElement.title = description;
  return controller;
}

function rgbToHex(rgb: readonly [number, number, number]): string {
  return `#${rgb
    .map((value) => Math.round(Math.min(1, Math.max(0, value)) * 255).toString(16).padStart(2, "0"))
    .join("")}`;
}

function hexToRgb(value: string): [number, number, number] {
  const hex = value.replace("#", "");
  if (!/^[0-9a-f]{6}$/i.test(hex)) throw new Error(`[terrain-debug] invalid color ${value}`);
  return [Number.parseInt(hex.slice(0, 2), 16) / 255, Number.parseInt(hex.slice(2, 4), 16) / 255, Number.parseInt(hex.slice(4, 6), 16) / 255];
}

function replaceRenderingState(target: TerrainRenderingSnapshot, source: TerrainRenderingSnapshot): void {
  Object.assign(target.lighting, source.lighting);
  Object.assign(target.camera, source.camera);
  Object.assign(target.postProcess, source.postProcess);
}

function cloneSurfaceTuning(source: SurfaceRuntimeTuning): {
  enabled: Record<SurfaceCategory, boolean>;
  density: Record<SurfaceCategory, number>;
  wind: { enabled: boolean; strength: number; direction: [number, number, number] };
  lod: { enabled: boolean; distanceScale: number };
  debugView: SurfaceRuntimeTuning["debugView"];
} {
  return {
    enabled: { ...source.enabled },
    density: { ...source.density },
    wind: { ...source.wind, direction: [...source.wind.direction] },
    lod: { ...source.lod },
    debugView: source.debugView
  };
}

function replaceSurfaceState(target: ReturnType<typeof cloneSurfaceTuning>, source: SurfaceRuntimeTuning): void {
  Object.assign(target.enabled, source.enabled);
  Object.assign(target.density, source.density);
  Object.assign(target.wind, source.wind, { direction: [...source.wind.direction] });
  Object.assign(target.lod, source.lod);
  target.debugView = source.debugView;
}

function formatCameraSnapshot(snapshot: TerrainCameraSnapshot): string {
  const round = (value: number): number => Number(value.toFixed(6));
  return JSON.stringify(
    {
      position: snapshot.position.map(round),
      rotation: snapshot.rotation.map(round),
      forward: snapshot.forward.map(round),
      fieldOfView: round(snapshot.fieldOfView)
    },
    null,
    2
  );
}
