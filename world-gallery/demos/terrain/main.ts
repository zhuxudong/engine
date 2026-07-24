import {
  Camera,
  Entity,
  PostProcess,
  Shader,
  TonemappingEffect,
  TonemappingMode,
  Vector3,
  WebGLEngine
} from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { FreeControl, OrbitControl } from "@galacean/engine-toolkit-controls";
import { Stats } from "@galacean/engine-toolkit-stats";
import { TerrainClipmap } from "./src/clipmap/TerrainClipmap";
import { TerrainMaterial, type TerrainLayerTuning, type TerrainMaterialTuning } from "./src/TerrainMaterial";
import {
  TERRAIN_DEBUG_VIEWS,
  type TerrainBackgroundMode,
  type TerrainCameraPoseName,
  type TerrainDebugApi,
  type TerrainDebugTuningSnapshot,
  type TerrainDebugViewName,
  type TerrainLightingSnapshot,
  type TerrainMaterialTuningSnapshot,
  type TerrainProbeSnapshot,
  type TerrainShaderStartupSnapshot,
  type TerrainWorldNoiseTuning,
  type TerrainWaterDebugSnapshot
} from "./src/debug/TerrainDebugContract";
import { TerrainWaterDebug } from "./src/debug/TerrainWaterDebug";
import { loadLayerTextures } from "./src/loader/LayerTextureLoader";
import { loadMacroNoiseTexture } from "./src/loader/MacroNoiseLoader";
import { loadManifest, type TerrainManifest } from "./src/loader/ManifestLoader";
import { loadTerrainData } from "./src/loader/TerrainDataLoader";
import { mountTerrainInspector } from "./src/debug/TerrainDebugInspector";
import { createTerrainEnvironment } from "./src/lighting/TerrainEnvironment";

export {
  TERRAIN_DEBUG_VIEWS,
  TERRAIN_DEBUG_VIEW_GROUP_LABELS,
  TERRAIN_DEBUG_VIEW_INFO,
  type TerrainBackgroundMode,
  type TerrainCameraPoseName,
  type TerrainDebugApi,
  type TerrainDebugLayerSnapshot,
  type TerrainDebugLayerTuningSnapshot,
  type TerrainLightingSnapshot,
  type TerrainDebugTuningSnapshot,
  type TerrainDebugViewGroup,
  type TerrainDebugViewInfo,
  type TerrainDebugViewName,
  type TerrainMaterialTuningSnapshot,
  type TerrainProbeSnapshot,
  type TerrainShaderRegistrationMode,
  type TerrainShaderStartupSnapshot,
  type TerrainWorldNoiseTuning,
  type TerrainWaterDebugSnapshot
} from "./src/debug/TerrainDebugContract";

interface CameraPose {
  position: readonly [x: number, y: number, z: number];
  target: readonly [x: number, y: number, z: number];
}

const CAMERA_POSES: Record<TerrainCameraPoseName, CameraPose> = {
  overview: {
    position: [1740, 1120, 1580],
    target: [512, 35, -512]
  },
  oblique: {
    position: [1180, 430, -420],
    target: [512, 20, -1024]
  },
  slope: {
    position: [760, 180, -620],
    target: [512, 50, -850]
  },
  dual: {
    position: [512, 90, -430],
    target: [512, 0, -650]
  },
  surface: {
    position: [590, 85, -690],
    target: [660, 45, -600]
  },
  "first-person": {
    position: [590, 25, -690],
    target: [660, 25, -600]
  },
  top: {
    position: [512, 3500, -448],
    target: [512, 0, -512]
  },
  seam: {
    position: [1120, 360, -1024],
    target: [512, 20, -1024]
  },
  "background-seam": {
    position: [1024, 900, -1536],
    target: [1024, 0, -1536]
  }
};

const status = document.querySelector<HTMLDivElement>("#status");
const backendSelector = document.querySelector<HTMLSelectElement>("#backend");

type TerrainBackend = "webgl2" | "webgpu";

void boot().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  setStatus(`error: ${message}`);
  console.error("[terrain] boot failed", error);
});

async function boot(): Promise<void> {
  const backend = resolveBackend();
  configureBackendSelector(backend);
  window.terrainBackend = backend;
  setStatus(`initializing ${backend}`);
  const configuration = { canvas: "canvas", shaderCompiler: new ShaderCompiler() };
  const engine =
    backend === "webgpu"
      ? await WebGPUEngine.create(configuration)
      : await WebGLEngine.create(configuration);
  engine.canvas.resizeByClientSize();
  window.addEventListener("resize", () => engine.canvas.resizeByClientSize());
  const terrainShaderStartup = await registerTerrainShader(engine, backend);

  const scene = engine.sceneManager.activeScene;
  const root = scene.createRootEntity("terrain-demo");
  const cameraEntity = root.createChild("camera");
  const camera = cameraEntity.addComponent(Camera);
  camera.fieldOfView = 75;
  camera.nearClipPlane = 1;
  camera.farClipPlane = 20000;
  camera.enableHDR = true;
  camera.enablePostProcess = true;
  const postProcess = root.createChild("terrain-tonemapping").addComponent(PostProcess);
  postProcess.addEffect(TonemappingEffect).mode.value = TonemappingMode.Neutral;
  const orbit = cameraEntity.addComponent(OrbitControl);
  orbit.minDistance = 20;
  orbit.maxDistance = 10000;
  applyCameraPose(cameraEntity, orbit, "overview");

  setStatus("loading manifest and region arrays");
  const manifestUrl = new URL("./data/manifest.json", import.meta.url).href;
  const environment = await createTerrainEnvironment(
    engine,
    scene,
    root,
    new URL("./data/environment/terrain-sky.ambLight", import.meta.url).href
  );
  const manifest = await loadManifest(engine, manifestUrl);
  const [terrainData, layerTextures, macroNoise] = await Promise.all([
    loadTerrainData(engine, manifest, manifestUrl),
    loadLayerTextures(engine, manifest.layers, manifestUrl),
    loadMacroNoiseTexture(engine, new URL(manifest.material.macroVariation.noiseTexture, manifestUrl).href)
  ]);

  const detailedMaterial = new TerrainMaterial(engine);
  const simplifiedMaterial = new TerrainMaterial(engine);
  const terrainMaterials = [detailedMaterial, simplifiedMaterial] as const;
  for (const terrainMaterial of terrainMaterials) {
    terrainMaterial.bindTerrain(terrainData, manifest.clipmap.meshSize);
    terrainMaterial.setLayerLibrary(layerTextures.albedoHeight, layerTextures.normalRoughness, manifest.layers);
    terrainMaterial.configure(manifest.material, macroNoise);
    terrainMaterial.configureWorldNoise(manifest.world.noise);
    terrainMaterial.setBackgroundMode(backgroundModeToShader(manifest.world.background));
    terrainMaterial.setDebugLayer(Math.min(1, manifest.layers.length - 1));
  }
  detailedMaterial.setMaterialDetailEnabled(true);
  simplifiedMaterial.setMaterialDetailEnabled(false);
  const tuning = createTuningSnapshot(manifest);

  const clipmap = new TerrainClipmap(
    engine,
    root.createChild("geometry-clipmap"),
    camera,
    terrainData,
    detailedMaterial,
    simplifiedMaterial,
    manifest.material.sampling.normalMapMaxLod,
    manifest.clipmap.meshSize,
    manifest.clipmap.meshLods
  );
  const waterDebug = new TerrainWaterDebug(engine, root, terrainWaterBounds(terrainData));
  const waterDebugState: TerrainWaterDebugSnapshot = { enabled: false, height: 10 };
  waterDebug.setState(waterDebugState.enabled, waterDebugState.height);
  setStatus("loading surface assets and terrain-conforming instances");
  const surfaceSystem = await SurfaceSystem.create({
    engine,
    parent: root,
    terrain: terrainData,
    manifestUrl: new URL("./data/surface/manifest.json", import.meta.url).href
  });
  const firstPersonPose = surfaceSystem.getFirstPersonPose();
  if (firstPersonPose) CAMERA_POSES["first-person"] = firstPersonPose;

  const api: TerrainDebugApi = {
    ready: true,
    views: Object.keys(TERRAIN_DEBUG_VIEWS) as TerrainDebugViewName[],
    poses: Object.keys(CAMERA_POSES) as TerrainCameraPoseName[],
    layers: manifest.layers.map(({ id, name, albedoHeight, normalRoughness }) => ({ id, name, albedoHeight, normalRoughness })),
    setView(view) {
      if (!Object.hasOwn(TERRAIN_DEBUG_VIEWS, view)) throw new Error(`[terrain-debug] unknown view ${view}`);
      const debugView = TERRAIN_DEBUG_VIEWS[view];
      clipmap.setWireframe(view === "clipmap-lod" || view === "wireframe");
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setDebugView(debugView);
    },
    setPose(pose) {
      if (!Object.hasOwn(CAMERA_POSES, pose)) throw new Error(`[terrain-debug] unknown pose ${pose}`);
      cameraControl.destroy();
      cameraControl = pose === "first-person" ? createFreeControl(cameraEntity) : createOrbitControl(cameraEntity);
      applyCameraPose(cameraEntity, pose);
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    setDebugLayer(layer) {
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setDebugLayer(layer);
    },
    getTuning() {
      return cloneTuningSnapshot(tuning);
    },
    setLayerTuning(layer, values) {
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setLayerTuning(layer, values);
      Object.assign(tuning.layers[layer], values);
    },
    setSamplingTuning(values) {
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setSamplingTuning(values);
      if (values.normalMapMaxLod !== undefined) clipmap.setMaterialDetailLod(values.normalMapMaxLod);
      Object.assign(tuning.sampling, values);
    },
    setMaterialTuning(values) {
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setMaterialTuning(values);
      replaceMaterialTuning(tuning.material, values);
    },
    setWorldBackground(mode) {
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setBackgroundMode(backgroundModeToShader(mode));
      tuning.world.background = mode;
    },
    setWorldNoiseTuning(values) {
      for (const terrainMaterial of terrainMaterials) terrainMaterial.setWorldNoiseTuning(values);
      replaceWorldNoiseTuning(tuning.world.noise, values);
    },
    getShaderStartup() {
      return { ...terrainShaderStartup, platforms: [...terrainShaderStartup.platforms] };
    },
    getWaterDebug() {
      return { ...waterDebugState };
    },
    setWaterDebug(values) {
      if (values.enabled !== undefined) waterDebugState.enabled = values.enabled;
      if (values.height !== undefined) waterDebugState.height = values.height;
      waterDebug.setState(waterDebugState.enabled, waterDebugState.height);
    },
    getLighting() {
      return environment.getLighting();
    },
    setLighting(values) {
      environment.setLighting(values);
      if (values.directLight !== undefined) {
        material.setDirectLightingEnabled(values.directLight);
      }
      if (values.environment !== undefined) {
        material.setIndirectLightingEnabled(values.environment);
      }
    },
    resetTuning() {
      const defaults = createTuningSnapshot(manifest);
      for (const layer of defaults.layers) {
        const { layer: layerId, ...values } = layer;
        for (const terrainMaterial of terrainMaterials) terrainMaterial.setLayerTuning(layerId, values);
      }
      for (const terrainMaterial of terrainMaterials) {
        terrainMaterial.setSamplingTuning(defaults.sampling);
        terrainMaterial.setMaterialTuning(defaults.material);
        terrainMaterial.configureWorldNoise(defaults.world.noise);
        terrainMaterial.setBackgroundMode(backgroundModeToShader(defaults.world.background));
      }
      clipmap.setMaterialDetailLod(defaults.sampling.normalMapMaxLod);
      replaceTuningSnapshot(tuning, defaults);
      waterDebugState.enabled = false;
      waterDebugState.height = 10;
      waterDebug.setState(waterDebugState.enabled, waterDebugState.height);
    },
    inspect() {
      const segmentCounts = new Array<number>(manifest.clipmap.meshLods).fill(0);
      const segments = clipmap.inspectSegments();
      for (const segment of segments) segmentCounts[segment.lod]++;
      return {
        regionLocations: terrainData.regions.map((region) => region.location),
        regionSize: terrainData.regionSize,
        vertexSpacing: terrainData.vertexSpacing,
        meshSize: manifest.clipmap.meshSize,
        meshLods: manifest.clipmap.meshLods,
        segmentCount: clipmap.segmentCount,
        segmentsPerLod: segmentCounts,
        segments
      };
    },
    readProbe(worldX, worldZ) {
      const rawControl = terrainData.sampleControl(worldX, worldZ);
      const snapshot: TerrainProbeSnapshot = {
        world: [worldX, worldZ],
        height: terrainData.sampleHeight(worldX, worldZ)
      };
      if (rawControl === undefined) return snapshot;
      const raw = rawControl >>> 0;
      const scaleIndex = (raw >>> 7) & 0x7;
      return {
        ...snapshot,
        control: {
          raw,
          base: (raw >>> 27) & 0x1f,
          overlay: (raw >>> 22) & 0x1f,
          blend: ((raw >>> 14) & 0xff) / 255,
          angleIndex: (raw >>> 10) & 0xf,
          scaleIndex,
          scale: 0.9 - (((scaleIndex + 3) % 8) + 1) * 0.1,
          surfaceFeatures: (raw >>> 3) & 0xf,
          hole: (raw & 0x4) !== 0,
          navigation: (raw & 0x2) !== 0,
          autoshader: (raw & 0x1) !== 0
        }
      };
    }
  };
  window.terrainDebug = api;

  const query = new URLSearchParams(location.search);
  const requestedView = query.get("view") as TerrainDebugViewName | null;
  const requestedPose = query.get("pose") as TerrainCameraPoseName | null;
  if (requestedView && requestedView in TERRAIN_DEBUG_VIEWS) api.setView(requestedView);
  if (requestedPose && requestedPose in CAMERA_POSES) api.setPose(requestedPose);

  if (document.body.dataset.terrainInspector === "true") mountTerrainInspector(api);
  engine.run();
  const surfaceSnapshot = surfaceSystem.inspect();
  setStatus(
    `ready · ${terrainData.regions.length} regions · ${clipmap.segmentCount} clipmap segments · ${surfaceSnapshot.instanceCount} surface instances · ${backend}`
  );
}

function resolveBackend(): TerrainBackend {
  return new URLSearchParams(location.search).get("backend") === "webgpu"
    ? "webgpu"
    : "webgl2";
}

async function registerTerrainShader(engine: Engine, backend: TerrainBackend): Promise<TerrainShaderStartupSnapshot> {
  const target = backend === "webgpu" ? ShaderLanguage.WGSL : ShaderLanguage.GLSLES100;
  const useRuntimeCompiler = new URLSearchParams(location.search).get("shader") === "runtime";

  if (useRuntimeCompiler) {
    const sourceLoadStarted = performance.now();
    const { default: terrainShaderSource } = await import("./src/shaders/Terrain.shader?raw");
    const runtimeSourceLoadMs = performance.now() - sourceLoadStarted;
    const registrationStarted = performance.now();
    Shader.create(terrainShaderSource);
    return {
      mode: "runtime",
      platforms: [target === ShaderLanguage.WGSL ? "wgsl" : "gles100"],
      registrationMs: performance.now() - registrationStarted,
      runtimeSourceLoadMs
    };
  }

  const registrationStarted = performance.now();
  await engine.resourceManager.load({
    url: new URL("/compiledShaders/terrain/Terrain.shaderc", location.origin).href,
    type: AssetType.Shader
  });
  return {
    mode: "precompiled",
    platforms: [shaderPlatformName(target)],
    registrationMs: performance.now() - registrationStarted
  };
}

function shaderPlatformName(target: number): "gles100" | "wgsl" {
  if (target === ShaderLanguage.GLSLES100) return "gles100";
  if (target === ShaderLanguage.WGSL) return "wgsl";
  throw new Error(`[terrain] unsupported compiled shader target: ${target}`);
}

function configureBackendSelector(backend: TerrainBackend): void {
  if (!backendSelector) {
    return;
  }
  backendSelector.value = backend;
  backendSelector.addEventListener("change", () => {
    const url = new URL(location.href);
    url.searchParams.set("backend", backendSelector.value);
    location.href = url.href;
  });
}

function installStatsPanelStyle(): void {
  const style = document.createElement("style");
  style.textContent = `
    body .gl-perf {
      top: auto;
      bottom: 12px;
      left: 12px;
      z-index: 10;
      min-width: 156px;
      padding: 9px 11px;
      border: 1px solid rgba(255, 255, 255, 0.14);
      border-radius: 4px;
      background: rgba(12, 15, 18, 0.82);
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.2);
      color: #f3f5f7;
      font: 11px/1.35 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    }

    body .gl-perf dl {
      display: grid;
      grid-template-columns: 1fr auto;
      gap: 3px 14px;
    }

    body .gl-perf dt,
    body .gl-perf dd {
      color: inherit;
      font-size: 11px;
      line-height: 1.35;
    }

    body .gl-perf dd {
      padding: 0;
      text-align: right;
      color: #76d6a5;
      font-variant-numeric: tabular-nums;
    }
  `;
  document.head.appendChild(style);
}

function configureStatsForDiagnostics(stats: Stats): void {
  const configure = () => {
    const core = (stats as unknown as { monitor?: { core?: { samplingFrames: number } } }).monitor?.core;
    if (!core) {
      requestAnimationFrame(configure);
      return;
    }
    // The toolkit defers its first sample for 60 seconds; diagnostics need live values.
    core.samplingFrames = 0;
  };
  requestAnimationFrame(configure);
}

function createOrbitControl(cameraEntity: Entity): OrbitControl {
  const control = cameraEntity.addComponent(OrbitControl);
  control.minDistance = 20;
  control.maxDistance = 10000;
  return control;
}

function createFreeControl(cameraEntity: Entity): FreeControl {
  const control = cameraEntity.addComponent(FreeControl);
  control.movementSpeed = 8;
  control.floorMock = false;
  return control;
}

function applyCameraPose(cameraEntity: Entity, poseName: TerrainCameraPoseName): void {
  const pose = CAMERA_POSES[poseName];
  cameraEntity.transform.setPosition(pose.position[0], pose.position[1], pose.position[2]);
  const target = new Vector3(pose.target[0], pose.target[1], pose.target[2]);
  cameraEntity.transform.lookAt(target);
  const orbit = cameraEntity.getComponent(OrbitControl);
  if (orbit) orbit.target.copyFrom(target);
}

function backgroundModeToShader(mode: TerrainBackgroundMode): 0 | 1 | 2 {
  if (mode === "flat") return 1;
  if (mode === "noise") return 2;
  return 0;
}

function terrainWaterBounds(terrain: { readonly regionSize: number; readonly regions: readonly { location: readonly [number, number] }[] }) {
  let minimumX = Infinity;
  let minimumZ = Infinity;
  let maximumX = -Infinity;
  let maximumZ = -Infinity;
  for (const region of terrain.regions) {
    const [x, z] = region.location;
    minimumX = Math.min(minimumX, x * terrain.regionSize);
    minimumZ = Math.min(minimumZ, z * terrain.regionSize);
    maximumX = Math.max(maximumX, (x + 1) * terrain.regionSize);
    maximumZ = Math.max(maximumZ, (z + 1) * terrain.regionSize);
  }
  return {
    center: [(minimumX + maximumX) * 0.5, (minimumZ + maximumZ) * 0.5] as const,
    size: Math.max(maximumX - minimumX, maximumZ - minimumZ)
  };
}

function createTuningSnapshot(manifest: TerrainManifest): TerrainDebugTuningSnapshot {
  return {
    layers: manifest.layers.map((layer) => ({
      layer: layer.id,
      uvScale: layer.uvScale,
      detilingRotation: layer.detilingRotation,
      detilingShift: layer.detilingShift,
      normalDepth: layer.normalDepth,
      aoStrength: layer.aoStrength,
      roughnessMod: layer.roughnessMod
    })),
    sampling: { ...manifest.material.sampling },
    material: {
      autoShader: { ...manifest.material.autoShader },
      projection: { ...manifest.material.projection },
      dualScaling: { ...manifest.material.dualScaling },
      macroVariation: {
        ...manifest.material.macroVariation,
        color1: [...manifest.material.macroVariation.color1],
        color2: [...manifest.material.macroVariation.color2],
        noise1Offset: [...manifest.material.macroVariation.noise1Offset]
      }
    },
    world: {
      background: manifest.world.background,
      noise: { ...manifest.world.noise, offset: [...manifest.world.noise.offset] }
    }
  };
}

function cloneTuningSnapshot(snapshot: TerrainDebugTuningSnapshot): TerrainDebugTuningSnapshot {
  return {
    layers: snapshot.layers.map((layer) => ({ ...layer })),
    sampling: { ...snapshot.sampling },
    material: {
      autoShader: { ...snapshot.material.autoShader },
      projection: { ...snapshot.material.projection },
      dualScaling: { ...snapshot.material.dualScaling },
      macroVariation: {
        ...snapshot.material.macroVariation,
        color1: [...snapshot.material.macroVariation.color1],
        color2: [...snapshot.material.macroVariation.color2],
        noise1Offset: [...snapshot.material.macroVariation.noise1Offset]
      }
    },
    world: {
      background: snapshot.world.background,
      noise: { ...snapshot.world.noise, offset: [...snapshot.world.noise.offset] }
    }
  };
}

function replaceTuningSnapshot(target: TerrainDebugTuningSnapshot, source: TerrainDebugTuningSnapshot): void {
  target.layers.splice(0, target.layers.length, ...source.layers.map((layer) => ({ ...layer })));
  Object.assign(target.sampling, source.sampling);
  replaceMaterialTuning(target.material, source.material);
  target.world.background = source.world.background;
  replaceWorldNoiseTuning(target.world.noise, source.world.noise);
}

function replaceMaterialTuning(target: TerrainMaterialTuningSnapshot, source: TerrainMaterialTuning): void {
  if (source.autoShader) Object.assign(target.autoShader, source.autoShader);
  if (source.projection) Object.assign(target.projection, source.projection);
  if (source.dualScaling) Object.assign(target.dualScaling, source.dualScaling);
  if (source.macroVariation) {
    const macro = source.macroVariation;
    Object.assign(target.macroVariation, macro);
    if (macro.color1) target.macroVariation.color1 = [...macro.color1];
    if (macro.color2) target.macroVariation.color2 = [...macro.color2];
    if (macro.noise1Offset) target.macroVariation.noise1Offset = [...macro.noise1Offset];
  }
}

function replaceWorldNoiseTuning(
  target: Required<TerrainWorldNoiseTuning>,
  source: TerrainWorldNoiseTuning
): void {
  Object.assign(target, source);
  if (source.offset) target.offset = [...source.offset];
}

function setStatus(message: string): void {
  if (status) status.textContent = message;
}
