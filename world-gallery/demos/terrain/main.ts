import {
  BloomEffect,
  Camera,
  Entity,
  MSAASamples,
  PostProcess,
  Shader,
  TonemappingEffect,
  TonemappingMode,
  Vector3
} from "@galacean/engine";
import { FreeControl, OrbitControl } from "@galacean/engine-toolkit-controls";
import { TerrainClipmap } from "./src/clipmap/TerrainClipmap";
import { TerrainMaterial } from "./src/TerrainMaterial";
import {
  TERRAIN_DEBUG_VIEWS,
  type TerrainCameraPoseName,
  type TerrainDebugApi,
  type TerrainDebugViewName,
  type TerrainLightingSnapshot,
  type TerrainRenderingTuning,
  type TerrainWaterDebugSnapshot
} from "./src/debug/TerrainDebugContract";
import {
  cloneTerrainDebugTuning,
  createTerrainDebugTuning,
  replaceTerrainDebugTuning,
  replaceTerrainMaterialTuning,
  replaceTerrainWorldNoiseTuning,
  terrainBackgroundModeToShader
} from "./src/debug/TerrainDebugTuning";
import { TerrainWaterDebug } from "./src/debug/TerrainWaterDebug";
import { applyTerrainControlFixture } from "./src/debug/TerrainControlFixture";
import { createTerrainProbeSnapshot } from "./src/debug/TerrainProbe";
import { TerrainFirstPersonController, type TerrainFirstPersonPose } from "./src/TerrainFirstPersonController";
import { TerrainGroundSampler } from "./src/data/TerrainGroundSampler";
import { loadLayerTextures } from "./src/loader/LayerTextureLoader";
import { loadMacroNoiseTexture } from "./src/loader/MacroNoiseLoader";
import { loadManifest } from "./src/loader/ManifestLoader";
import { loadTerrainData } from "./src/loader/TerrainDataLoader";
import surfaceShaderSource from "./src/shaders/Surface.shader?raw";
import terrainShaderSource from "./src/shaders/Terrain.shader?raw";
import { registerTerrainShaderIncludes } from "./src/shaders/registerTerrainShaderIncludes";
import { mountTerrainInspector } from "./src/debug/TerrainDebugInspector";
import { createTerrainEnvironment } from "./src/lighting/TerrainEnvironment";
import { TerrainPerformancePanel } from "./src/performance/TerrainPerformancePanel";
import { SurfaceWorld } from "./src/surface/SurfaceWorld";
import { bindTerrainBackendSelector, createTerrainEngine } from "./src/TerrainEngineBootstrap";

export {
  TERRAIN_DEBUG_VIEWS,
  TERRAIN_DEBUG_VIEW_GROUP_LABELS,
  TERRAIN_DEBUG_VIEW_INFO,
  type TerrainBackgroundMode,
  type TerrainCameraPoseName,
  type TerrainDebugApi,
  type TerrainDebugLayerSnapshot,
  type TerrainDebugLayerTuningSnapshot,
  type TerrainDebugTuningSnapshot,
  type TerrainDebugViewGroup,
  type TerrainDebugViewInfo,
  type TerrainDebugViewName,
  type TerrainMaterialTuningSnapshot,
  type TerrainProbeSnapshot,
  type TerrainWorldNoiseTuning,
  type TerrainWaterDebugSnapshot
} from "./src/debug/TerrainDebugContract";

const STATIC_CAMERA_POSES = {
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
  },
  "world-surface": {
    position: [2450, 145, -1480],
    target: [2300, 100, -1650]
  }
} as const;

const CAMERA_POSES = {
  "first-person": true,
  ...STATIC_CAMERA_POSES
} as const;

const FIRST_PERSON_POSE: TerrainFirstPersonPose = {
  x: 600,
  z: -104,
  // Matches the sunward opening visible from the overview pose in terrain-sky.ambLight.
  yaw: 0.26,
  pitch: 0.12
};

type StaticCameraPoseName = keyof typeof STATIC_CAMERA_POSES;

const status = document.querySelector<HTMLDivElement>("#status");

void boot().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  setStatus(`error: ${message}`);
  console.error("[terrain] boot failed", error);
});

async function boot(): Promise<void> {
  setStatus("initializing engine");
  const { engine, backend } = await createTerrainEngine("canvas");
  bindTerrainBackendSelector(document.querySelector<HTMLSelectElement>("#backend"), backend);
  const performancePanel = new TerrainPerformancePanel(engine);
  engine.canvas.resizeByClientSize();
  window.addEventListener("resize", () => engine.canvas.resizeByClientSize());
  registerTerrainShaderIncludes();
  Shader.create(terrainShaderSource);
  Shader.create(surfaceShaderSource);

  const scene = engine.sceneManager.activeScene;
  const root = scene.createRootEntity("terrain-demo");
  const cameraEntity = root.createChild("camera");
  const camera = cameraEntity.addComponent(Camera);
  camera.fieldOfView = 75;
  camera.nearClipPlane = 1;
  camera.farClipPlane = 20000;
  camera.msaaSamples = MSAASamples.None;
  camera.enableHDR = true;
  camera.enablePostProcess = true;
  const postProcess = root.createChild("terrain-tonemapping").addComponent(PostProcess);
  const tonemappingEffect = postProcess.addEffect(TonemappingEffect);
  tonemappingEffect.mode.value = TonemappingMode.Neutral;
  const bloomEffect = postProcess.addEffect(BloomEffect);
  bloomEffect.enabled = false;
  bloomEffect.threshold.value = 0.8;
  bloomEffect.intensity.value = 1;
  bloomEffect.scatter.value = 0.7;
  const orbit = cameraEntity.addComponent(OrbitControl);
  orbit.minDistance = 20;
  orbit.maxDistance = 10000;
  applyCameraPose(cameraEntity, orbit, "overview");
  const query = new URLSearchParams(location.search);

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
  const controlFixture = query.get("fixture") === "control" ? applyTerrainControlFixture(terrainData) : undefined;
  const groundSampler = new TerrainGroundSampler(terrainData, manifest.world.background, manifest.world.noise);
  const firstPerson = cameraEntity.addComponent(TerrainFirstPersonController);
  firstPerson.configure(groundSampler);
  let freeControl: FreeControl | null = applyTerrainCameraPose(cameraEntity, orbit, firstPerson, null, "first-person");

  const material = new TerrainMaterial(engine);
  material.bindTerrain(terrainData, manifest.clipmap.meshSize);
  material.setLayerLibrary(layerTextures.albedoHeight, layerTextures.normalRoughness, manifest.layers);
  material.configure(manifest.material, macroNoise);
  material.configureWorldNoise(manifest.world.noise);
  material.setBackgroundMode(terrainBackgroundModeToShader(manifest.world.background));
  material.setDebugLayer(Math.min(1, manifest.layers.length - 1));
  const tuning = createTerrainDebugTuning(manifest);

  const clipmap = new TerrainClipmap(
    engine,
    root.createChild("geometry-clipmap"),
    camera,
    terrainData,
    material,
    manifest.clipmap.meshSize,
    manifest.clipmap.meshLods
  );
  setStatus("loading deterministic surface instances");
  const surfaceWorld = await SurfaceWorld.create(
    engine,
    root.createChild("surface-world"),
    camera,
    new URL("./data/surface/surface-manifest.json", import.meta.url).href,
    { terrain: terrainData, worldNoise: manifest.world.noise }
  );
  performancePanel.setSceneMetricsProvider(() => {
    const surface = surfaceWorld.inspect();
    return {
      clipmapSegments: clipmap.segmentCount,
      visibleSurfaceInstances: surface.visibleInstances,
      visibleSurfaceBatches: surface.visibleRendererBatches,
      totalSurfaceBatches: surface.rendererBatches,
      coverageInstances: surface.coverageInstances,
      worldInstances: surface.worldInstances,
      surfaceLodCounts: surface.lodCounts
    };
  });
  surfaceWorld.setProceduralTerrainActive(manifest.world.background === "noise");
  const surfaceDefaults = surfaceWorld.getTuning();
  const waterDebug = new TerrainWaterDebug(engine, root, terrainWaterBounds(terrainData));
  const waterDebugState: TerrainWaterDebugSnapshot = { enabled: false, height: 10 };
  waterDebug.setState(waterDebugState.enabled, waterDebugState.height);
  const updateLighting = (values: Partial<TerrainLightingSnapshot>): void => {
    environment.setLighting(values);
    if (values.directLight !== undefined) {
      material.setDirectLightingEnabled(values.directLight);
    }
    if (values.environment !== undefined) {
      material.setIndirectLightingEnabled(values.environment);
    }
  };

  const api: TerrainDebugApi = {
    ready: true,
    manifestUrl,
    views: Object.keys(TERRAIN_DEBUG_VIEWS) as TerrainDebugViewName[],
    poses: Object.keys(CAMERA_POSES) as TerrainCameraPoseName[],
    layers: manifest.layers.map(({ id, name, albedoHeight, normalRoughness }) => ({
      id,
      name,
      albedoHeight,
      normalRoughness
    })),
    setView(view) {
      if (!Object.hasOwn(TERRAIN_DEBUG_VIEWS, view)) throw new Error(`[terrain-debug] unknown view ${view}`);
      const debugView = TERRAIN_DEBUG_VIEWS[view];
      clipmap.setWireframe(view === "clipmap-lod" || view === "wireframe");
      material.setDebugView(debugView);
      surfaceWorld.setVisible(view === "surface");
    },
    setPose(pose) {
      if (!Object.hasOwn(CAMERA_POSES, pose)) throw new Error(`[terrain-debug] unknown pose ${pose}`);
      freeControl = applyTerrainCameraPose(cameraEntity, orbit, firstPerson, freeControl, pose);
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    getFirstPerson() {
      return firstPerson.snapshot;
    },
    setFirstPersonEyeHeight(height) {
      firstPerson.setEyeHeight(height);
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    setFirstPersonMoveSpeed(speed) {
      firstPerson.setMoveSpeed(speed);
    },
    getCamera() {
      const transform = cameraEntity.transform;
      const position = transform.worldPosition;
      const rotation = transform.worldRotationQuaternion;
      const forward = transform.worldForward;
      return {
        position: [position.x, position.y, position.z],
        rotation: [rotation.x, rotation.y, rotation.z, rotation.w],
        forward: [forward.x, forward.y, forward.z],
        fieldOfView: camera.fieldOfView
      };
    },
    setCamera(snapshot) {
      firstPerson.exit();
      orbit.enabled = false;
      if (!freeControl) freeControl = cameraEntity.addComponent(FreeControl);
      firstPerson.setFreeControl(freeControl);
      const [positionX, positionY, positionZ] = snapshot.position;
      cameraEntity.transform.setPosition(positionX, positionY, positionZ);
      cameraEntity.transform.worldRotationQuaternion.set(...snapshot.rotation);
      camera.fieldOfView = snapshot.fieldOfView;
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    focusProbe(worldX, worldZ) {
      const height = terrainData.sampleHeight(worldX, worldZ);
      if (height === undefined) {
        throw new Error(`[terrain-debug] no terrain height at (${worldX}, ${worldZ})`);
      }
      firstPerson.exit();
      firstPerson.setFreeControl(null);
      freeControl?.destroy();
      freeControl = null;
      orbit.enabled = false;
      cameraEntity.transform.setPosition(worldX, height + 80, worldZ);
      cameraEntity.transform.worldRotationQuaternion.set(-Math.SQRT1_2, 0, 0, Math.SQRT1_2);
      camera.fieldOfView = 20;
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    setDebugLayer(layer) {
      material.setDebugLayer(layer);
    },
    getTuning() {
      return cloneTerrainDebugTuning(tuning);
    },
    setLayerTuning(layer, values) {
      material.setLayerTuning(layer, values);
      Object.assign(tuning.layers[layer], values);
    },
    setSamplingTuning(values) {
      material.setSamplingTuning(values);
      Object.assign(tuning.sampling, values);
    },
    setMaterialTuning(values) {
      material.setMaterialTuning(values);
      replaceTerrainMaterialTuning(tuning.material, values);
    },
    setWorldBackground(mode) {
      material.setBackgroundMode(terrainBackgroundModeToShader(mode));
      surfaceWorld.setProceduralTerrainActive(mode === "noise");
      groundSampler.setBackground(mode);
      tuning.world.background = mode;
    },
    setWorldNoiseTuning(values) {
      material.setWorldNoiseTuning(values);
      surfaceWorld.setWorldNoiseTuning(values);
      groundSampler.setWorldNoiseTuning(values);
      replaceTerrainWorldNoiseTuning(tuning.world.noise, values);
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
      updateLighting(values);
    },
    getRendering() {
      return {
        lighting: environment.getLighting(),
        camera: {
          hdr: camera.enableHDR,
          msaaSamples: camera.msaaSamples
        },
        postProcess: {
          enabled: camera.enablePostProcess,
          tonemapping: tonemappingEffect.enabled,
          tonemappingMode: tonemappingEffect.mode.value,
          bloom: {
            enabled: bloomEffect.enabled,
            threshold: bloomEffect.threshold.value,
            intensity: bloomEffect.intensity.value,
            scatter: bloomEffect.scatter.value
          }
        }
      };
    },
    setRendering(values: TerrainRenderingTuning) {
      if (values.lighting) updateLighting(values.lighting);
      if (values.camera?.hdr !== undefined) camera.enableHDR = values.camera.hdr;
      if (values.camera?.msaaSamples !== undefined) camera.msaaSamples = values.camera.msaaSamples;
      if (values.postProcess?.enabled !== undefined) camera.enablePostProcess = values.postProcess.enabled;
      if (values.postProcess?.tonemapping !== undefined) tonemappingEffect.enabled = values.postProcess.tonemapping;
      if (values.postProcess?.tonemappingMode !== undefined) {
        tonemappingEffect.mode.value = values.postProcess.tonemappingMode;
      }
      const bloomValues = values.postProcess?.bloom;
      if (bloomValues) {
        if (bloomValues.enabled !== undefined) bloomEffect.enabled = bloomValues.enabled;
        if (bloomValues.threshold !== undefined) bloomEffect.threshold.value = bloomValues.threshold;
        if (bloomValues.intensity !== undefined) bloomEffect.intensity.value = bloomValues.intensity;
        if (bloomValues.scatter !== undefined) bloomEffect.scatter.value = bloomValues.scatter;
      }
    },
    getSurface() {
      return surfaceWorld.getTuning();
    },
    setSurface(values) {
      surfaceWorld.setTuning(values);
    },
    inspectSurface() {
      return surfaceWorld.inspect();
    },
    setSurfaceDebugView(view) {
      surfaceWorld.setTuning({ debugView: view });
    },
    resetTuning() {
      const defaults = createTerrainDebugTuning(manifest);
      for (const layer of defaults.layers) {
        const { layer: layerId, ...values } = layer;
        material.setLayerTuning(layerId, values);
      }
      material.setSamplingTuning(defaults.sampling);
      material.setMaterialTuning(defaults.material);
      material.configureWorldNoise(defaults.world.noise);
      surfaceWorld.setWorldNoiseTuning(defaults.world.noise);
      groundSampler.setWorldNoiseTuning(defaults.world.noise);
      material.setBackgroundMode(terrainBackgroundModeToShader(defaults.world.background));
      surfaceWorld.setProceduralTerrainActive(defaults.world.background === "noise");
      groundSampler.setBackground(defaults.world.background);
      replaceTerrainDebugTuning(tuning, defaults);
      waterDebugState.enabled = false;
      waterDebugState.height = 10;
      waterDebug.setState(waterDebugState.enabled, waterDebugState.height);
      surfaceWorld.setTuning(surfaceDefaults);
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
      return createTerrainProbeSnapshot(terrainData, worldX, worldZ);
    },
    getControlFixture: () => controlFixture
  };
  window.terrainDebug = api;
  const requestedView = query.get("view") as TerrainDebugViewName | null;
  const requestedPose = query.get("pose") as TerrainCameraPoseName | null;
  if (requestedView && requestedView in TERRAIN_DEBUG_VIEWS) api.setView(requestedView);
  if (requestedPose && requestedPose in CAMERA_POSES) api.setPose(requestedPose);

  if (document.body.dataset.terrainInspector === "true") {
    mountTerrainInspector(api);
  }
  engine.run();
  setStatus(
    `ready · ${terrainData.regions.length} regions · ${clipmap.segmentCount} clipmap segments · ` +
      `deterministic surface streaming · ${backend}`
  );
}

function applyTerrainCameraPose(
  cameraEntity: Entity,
  orbit: OrbitControl,
  firstPerson: TerrainFirstPersonController,
  freeControl: FreeControl | null,
  poseName: TerrainCameraPoseName
): FreeControl | null {
  if (poseName === "first-person") {
    orbit.enabled = false;
    firstPerson.enter(FIRST_PERSON_POSE);
    freeControl?.destroy();
    const nextFreeControl = cameraEntity.addComponent(FreeControl);
    firstPerson.setFreeControl(nextFreeControl);
    return nextFreeControl;
  }
  firstPerson.exit();
  firstPerson.setFreeControl(null);
  freeControl?.destroy();
  orbit.enabled = true;
  applyCameraPose(cameraEntity, orbit, poseName as StaticCameraPoseName);
  return null;
}

function applyCameraPose(cameraEntity: Entity, orbit: OrbitControl, poseName: StaticCameraPoseName): void {
  const pose = STATIC_CAMERA_POSES[poseName];
  cameraEntity.transform.setPosition(pose.position[0], pose.position[1], pose.position[2]);
  const target = new Vector3(pose.target[0], pose.target[1], pose.target[2]);
  cameraEntity.transform.lookAt(target);
  orbit.target.copyFrom(target);
}

function terrainWaterBounds(terrain: {
  readonly regionSize: number;
  readonly regions: readonly { location: readonly [number, number] }[];
}) {
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

function setStatus(message: string): void {
  if (status) status.textContent = message;
}
