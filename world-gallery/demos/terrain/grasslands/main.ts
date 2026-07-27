import {
  BloomEffect,
  Camera,
  DepthTextureMode,
  Entity,
  MSAASamples,
  PostProcess,
  Shader,
  TonemappingEffect,
  TonemappingMode,
  Vector3,
  WebGLEngine
} from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { FreeControl, OrbitControl } from "@galacean/engine-toolkit-controls";
import { TerrainMaterial } from "../src/TerrainMaterial";
import {
  TerrainFirstPersonController,
  type TerrainFirstPersonPose,
  type TerrainFirstPersonSnapshot
} from "../src/TerrainFirstPersonController";
import { TerrainClipmap } from "../src/clipmap/TerrainClipmap";
import {
  TERRAIN_DEBUG_VIEWS,
  type TerrainCameraPoseName,
  type TerrainDebugApi,
  type TerrainDebugViewName,
  type TerrainLightingSnapshot,
  type TerrainRenderingTuning
} from "../src/debug/TerrainDebugContract";
import { mountTerrainInspector } from "../src/debug/TerrainDebugInspector";
import {
  cloneTerrainDebugTuning,
  createTerrainDebugTuning,
  replaceTerrainDebugTuning,
  replaceTerrainMaterialTuning,
  replaceTerrainWorldNoiseTuning,
  terrainBackgroundModeToShader
} from "../src/debug/TerrainDebugTuning";
import { applyTerrainControlFixture } from "../src/debug/TerrainControlFixture";
import { createTerrainProbeSnapshot } from "../src/debug/TerrainProbe";
import { TerrainPerformancePanel } from "../src/performance/TerrainPerformancePanel";
import { loadLayerTextures } from "../src/loader/LayerTextureLoader";
import { loadMacroNoiseTexture } from "../src/loader/MacroNoiseLoader";
import { loadManifest } from "../src/loader/ManifestLoader";
import { loadTerrainData } from "../src/loader/TerrainDataLoader";
import surfaceShaderSource from "../src/shaders/Surface.shader?raw";
import terrainShaderSource from "../src/shaders/Terrain.shader?raw";
import { registerTerrainShaderIncludes } from "../src/shaders/registerTerrainShaderIncludes";
import { SurfaceWorld } from "../src/surface/SurfaceWorld";
import type { SurfaceRuntimeTuningUpdate } from "../src/surface/SurfaceRuntimeContract";
import { loadGrasslandsArchitecture, type GrasslandsArchitectureSpec } from "./src/GrasslandsArchitecture";
import {
  GrasslandsCloudSystem,
  type GrasslandsCloudPlacementSpec,
  type GrasslandsCloudPresetSpec
} from "./src/GrasslandsCloudSystem";
import { mountGrasslandsInspector, type GrasslandsSceneTuning } from "./src/GrasslandsDebugInspector";
import {
  createGrasslandsEnvironment,
  type GrasslandsEnvironmentSpec,
  type GrasslandsEnvironmentTuning
} from "./src/GrasslandsEnvironment";
import { GrasslandsExposurePass } from "./src/GrasslandsExposurePass";

interface GrasslandsSceneLayout {
  readonly camera: {
    readonly position: readonly [x: number, y: number, z: number];
    readonly rotation: readonly [x: number, y: number, z: number, w: number];
    readonly fieldOfView: number;
    readonly nearClip: number;
    readonly farClip: number;
  };
  readonly architecture: GrasslandsArchitectureSpec;
  readonly clouds: readonly GrasslandsCloudPlacementSpec[];
  readonly environment: GrasslandsEnvironmentSpec & {
    readonly cloudPresets: readonly GrasslandsCloudPresetSpec[];
    readonly postProcess: {
      readonly tonemapping: "aces";
      readonly postExposure: number;
      readonly bloom: {
        readonly threshold: number;
        readonly intensity: number;
        readonly scatter: number;
      };
    };
  };
}

const GRASSLANDS_POSES: readonly TerrainCameraPoseName[] = [
  "first-person",
  "hero",
  "overview",
  "valley-overview",
  "terrain-horizon",
  "grass-wind"
];

const GRASSLANDS_DIAGNOSTIC_CAMERAS = {
  "valley-overview": {
    position: [1473.834961, 23.960739, 1753.641479],
    rotation: [-0.026121, -0.01122, -0.000293, 0.999596],
    fieldOfView: 50
  },
  "terrain-horizon": {
    position: [1465.276489, 18.276848, 1729.573608],
    rotation: [0.011888, -0.466302, 0.006267, 0.884523],
    fieldOfView: 50
  }
} as const;

declare global {
  interface Window {
    /** Runtime diagnostics for the deterministic Grasslands surface scene. */
    grasslandsDebug?: {
      readonly ready: true;
      inspectSurface(): ReturnType<SurfaceWorld["inspect"]>;
      /** Returns deterministic cloud batches and animation time. */
      inspectClouds(): ReturnType<GrasslandsCloudSystem["inspect"]>;
      /** Returns authored architecture placement and renderer counts. */
      inspectArchitecture(): { readonly placements: number; readonly renderers: number };
      /** Returns the active first-person ground-follow state. */
      getFirstPerson(): TerrainFirstPersonSnapshot;
      /**
       * Updates camera height above the sampled terrain.
       * @param height Eye height in world metres.
       */
      setFirstPersonEyeHeight(height: number): void;
      /**
       * Updates first-person WASD movement speed.
       * @param speed Movement speed in world metres per second.
       */
      setFirstPersonMoveSpeed(speed: number): void;
      /**
       * Updates runtime-only surface visibility, density, wind, LOD, or debug values.
       * @param values Partial surface tuning values.
       */
      setSurface(values: SurfaceRuntimeTuningUpdate): void;
      /** Returns the current Grasslands scene-only rendering switches. */
      getScene(): GrasslandsSceneTuning;
      /**
       * Updates authored scene rendering without changing SurfaceWorld data.
       * @param values Partial architecture, sky, fog, light, environment, or post-process switches.
       */
      setScene(values: Partial<GrasslandsSceneTuning>): void;
    };
  }
}

const status = document.querySelector<HTMLDivElement>("#status");

void boot().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  setStatus(`error: ${message}`);
  console.error("[grasslands] boot failed", error);
});

async function boot(): Promise<void> {
  setStatus("initializing engine");
  const engine = await WebGLEngine.create({ canvas: "canvas", shaderCompiler: new ShaderCompiler() });
  const performancePanel = new TerrainPerformancePanel(engine);
  engine.canvas.resizeByClientSize();
  window.addEventListener("resize", () => engine.canvas.resizeByClientSize());
  registerTerrainShaderIncludes();
  Shader.create(terrainShaderSource);
  Shader.create(surfaceShaderSource);

  const scene = engine.sceneManager.activeScene;
  const root = scene.createRootEntity("grasslands");
  const cameraEntity = root.createChild("camera");
  const camera = cameraEntity.addComponent(Camera);
  camera.msaaSamples = MSAASamples.None;
  camera.enableHDR = true;
  camera.enablePostProcess = true;
  camera.depthTextureMode = DepthTextureMode.PrePass;
  const postProcess = root.createChild("post-process").addComponent(PostProcess);
  const tonemapping = postProcess.addEffect(TonemappingEffect);
  tonemapping.mode.value = TonemappingMode.ACES;
  const bloom = postProcess.addEffect(BloomEffect);
  const exposure = new GrasslandsExposurePass(engine);
  engine.addPostProcessPass(exposure);

  const manifestUrl = new URL("../data/grasslands/terrain-manifest.json", import.meta.url).href;
  const surfaceManifestUrl = new URL("../data/grasslands/surface-manifest.json", import.meta.url).href;
  const sceneLayoutUrl = new URL("../data/grasslands/scene-layout.json", import.meta.url);
  const sceneLayout = await loadJson<GrasslandsSceneLayout>(sceneLayoutUrl);
  const query = new URLSearchParams(location.search);
  camera.fieldOfView = sceneLayout.camera.fieldOfView;
  camera.nearClipPlane = sceneLayout.camera.nearClip;
  camera.farClipPlane = sceneLayout.camera.farClip;
  cameraEntity.transform.position.set(...sceneLayout.camera.position);
  cameraEntity.transform.worldRotationQuaternion.set(...sceneLayout.camera.rotation);

  setStatus("loading 3 km terrain");
  const manifest = await loadManifest(engine, manifestUrl);
  const [terrainData, layerTextures, macroNoise] = await Promise.all([
    loadTerrainData(engine, manifest, manifestUrl),
    loadLayerTextures(engine, manifest.layers, manifestUrl),
    loadMacroNoiseTexture(engine, new URL(manifest.material.macroVariation.noiseTexture, manifestUrl).href)
  ]);
  const controlFixture = query.get("fixture") === "control" ? applyTerrainControlFixture(terrainData) : undefined;
  const firstPerson = cameraEntity.addComponent(TerrainFirstPersonController);
  firstPerson.configure(terrainData);
  const orbit = cameraEntity.addComponent(OrbitControl);
  let freeControl: FreeControl | null = null;
  const environment = await createGrasslandsEnvironment(
    engine,
    scene,
    root,
    sceneLayout.environment,
    new URL("../data/grasslands/environment/sky.ambLight", import.meta.url).href,
    new URL("../data/grasslands/environment/skybox.ambLight", import.meta.url).href,
    sceneLayoutUrl.href
  );
  exposure.exposure = sceneLayout.environment.postProcess.postExposure;
  bloom.threshold.value = sceneLayout.environment.postProcess.bloom.threshold;
  bloom.intensity.value = sceneLayout.environment.postProcess.bloom.intensity;
  bloom.scatter.value = sceneLayout.environment.postProcess.bloom.scatter;
  bloom.enabled = false;

  const terrainMaterial = new TerrainMaterial(engine);
  terrainMaterial.bindTerrain(terrainData, manifest.clipmap.meshSize);
  terrainMaterial.setLayerLibrary(layerTextures.albedoHeight, layerTextures.normalRoughness, manifest.layers);
  terrainMaterial.configure(manifest.material, macroNoise);
  terrainMaterial.configureWorldNoise(manifest.world.noise);
  terrainMaterial.setBackgroundMode(terrainBackgroundModeToShader(manifest.world.background));
  terrainMaterial.setDebugLayer(Math.min(1, manifest.layers.length - 1));
  const terrainTuning = createTerrainDebugTuning(manifest);
  const clipmap = new TerrainClipmap(
    engine,
    root.createChild("terrain"),
    camera,
    terrainData,
    terrainMaterial,
    manifest.clipmap.meshSize,
    manifest.clipmap.meshLods
  );

  setStatus("loading 291,069 deterministic surface instances");
  const surfaceWorld = await SurfaceWorld.create(engine, root.createChild("surface-world"), camera, surfaceManifestUrl);
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
  const surfaceDefaults = surfaceWorld.getTuning();
  setStatus("loading authored architecture");
  const architecture = await loadGrasslandsArchitecture(
    engine,
    root,
    sceneLayout.architecture,
    new URL("../data/grasslands/scene-layout.json", import.meta.url).href
  );
  setStatus("loading authored clouds");
  const clouds = await GrasslandsCloudSystem.create(
    engine,
    root,
    sceneLayout.environment.cloudPresets,
    sceneLayout.clouds,
    sceneLayoutUrl.href,
    (worldX, worldZ) => terrainData.sampleHeightInterpolated(worldX, worldZ)
  );
  let terrainCompositionVisible = true;
  let architectureVisible = architecture.root.isActive;
  let cloudsVisible = clouds.inspect().visible;
  const applyTerrainCompositionVisibility = (): void => {
    architecture.root.isActive = terrainCompositionVisible && architectureVisible;
    clouds.setTuning({ visible: terrainCompositionVisible && cloudsVisible });
  };
  const setSurfaceTuning = (values: SurfaceRuntimeTuningUpdate): void => {
    surfaceWorld.setTuning(values);
    if (values.wind) {
      const wind = surfaceWorld.getTuning().wind;
      architecture.setWind(wind.enabled, wind.strength, wind.direction);
    }
  };
  const getSceneTuning = (): GrasslandsSceneTuning => ({
    ...environment.getTuning(),
    architecture: architectureVisible,
    clouds: cloudsVisible,
    postProcess: camera.enablePostProcess
  });
  const setSceneTuning = (values: Partial<GrasslandsSceneTuning>): void => {
    const environmentValues: Partial<GrasslandsEnvironmentTuning> = {
      ...(values.directLight === undefined ? {} : { directLight: values.directLight }),
      ...(values.shadows === undefined ? {} : { shadows: values.shadows }),
      ...(values.environment === undefined ? {} : { environment: values.environment }),
      ...(values.sky === undefined ? {} : { sky: values.sky }),
      ...(values.fog === undefined ? {} : { fog: values.fog }),
      ...(values.cloudShadows === undefined ? {} : { cloudShadows: values.cloudShadows }),
      ...(values.animation === undefined ? {} : { animation: values.animation })
    };
    environment.setTuning(environmentValues);
    if (values.directLight !== undefined) {
      terrainMaterial.setDirectLightingEnabled(values.directLight);
    }
    if (values.environment !== undefined) {
      terrainMaterial.setIndirectLightingEnabled(values.environment);
    }
    if (values.architecture !== undefined) {
      architectureVisible = values.architecture;
    }
    if (values.postProcess !== undefined) {
      camera.enablePostProcess = values.postProcess;
      exposure.isActive = values.postProcess;
    }
    if (values.clouds !== undefined) cloudsVisible = values.clouds;
    clouds.setTuning({ animation: values.animation });
    applyTerrainCompositionVisibility();
  };
  const grasslandsDebug: NonNullable<Window["grasslandsDebug"]> = {
    ready: true,
    inspectSurface: () => surfaceWorld.inspect(),
    inspectClouds: () => clouds.inspect(),
    inspectArchitecture: () => ({
      placements: architecture.placements,
      renderers: architecture.renderers
    }),
    getFirstPerson: () => firstPerson.snapshot,
    setFirstPersonEyeHeight: (height) => firstPerson.setEyeHeight(height),
    setFirstPersonMoveSpeed: (speed) => firstPerson.setMoveSpeed(speed),
    setSurface: setSurfaceTuning,
    getScene: getSceneTuning,
    setScene: setSceneTuning
  };
  window.grasslandsDebug = grasslandsDebug;

  const terrainDebug: TerrainDebugApi = {
    ready: true,
    manifestUrl,
    views: Object.keys(TERRAIN_DEBUG_VIEWS) as TerrainDebugViewName[],
    poses: GRASSLANDS_POSES,
    layers: manifest.layers.map(({ id, name, albedoHeight, normalRoughness }) => ({
      id,
      name,
      albedoHeight,
      normalRoughness
    })),
    setView(view) {
      if (!Object.hasOwn(TERRAIN_DEBUG_VIEWS, view)) {
        throw new Error(`[terrain-debug] unknown view ${view}`);
      }
      clipmap.setWireframe(view === "clipmap-lod" || view === "wireframe");
      terrainMaterial.setDebugView(TERRAIN_DEBUG_VIEWS[view]);
      terrainCompositionVisible = view === "surface";
      surfaceWorld.setVisible(terrainCompositionVisible);
      applyTerrainCompositionVisibility();
    },
    setPose(pose) {
      if (!GRASSLANDS_POSES.includes(pose)) {
        throw new Error(`[terrain-debug] unknown Grasslands pose ${pose}`);
      }
      freeControl = applyGrasslandsCameraPose(
        cameraEntity,
        camera,
        orbit,
        firstPerson,
        freeControl,
        pose,
        sceneLayout.camera
      );
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    getFirstPerson: () => firstPerson.snapshot,
    setFirstPersonEyeHeight(height) {
      firstPerson.setEyeHeight(height);
      clipmap.snap(cameraEntity.transform.worldPosition);
    },
    setFirstPersonMoveSpeed: (speed) => firstPerson.setMoveSpeed(speed),
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
      firstPerson.setFreeControl(null);
      freeControl?.destroy();
      freeControl = null;
      orbit.enabled = true;
      const [positionX, positionY, positionZ] = snapshot.position;
      cameraEntity.transform.setPosition(positionX, positionY, positionZ);
      cameraEntity.transform.worldRotationQuaternion.set(...snapshot.rotation);
      camera.fieldOfView = snapshot.fieldOfView;
      setOrbitTargetFromCamera(cameraEntity, orbit);
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
    setDebugLayer: (layer) => terrainMaterial.setDebugLayer(layer),
    getTuning: () => cloneTerrainDebugTuning(terrainTuning),
    setLayerTuning(layer, values) {
      terrainMaterial.setLayerTuning(layer, values);
      Object.assign(terrainTuning.layers[layer], values);
    },
    setSamplingTuning(values) {
      terrainMaterial.setSamplingTuning(values);
      Object.assign(terrainTuning.sampling, values);
    },
    setMaterialTuning(values) {
      terrainMaterial.setMaterialTuning(values);
      replaceTerrainMaterialTuning(terrainTuning.material, values);
    },
    setWorldBackground(mode) {
      terrainMaterial.setBackgroundMode(terrainBackgroundModeToShader(mode));
      terrainTuning.world.background = mode;
    },
    setWorldNoiseTuning(values) {
      terrainMaterial.setWorldNoiseTuning(values);
      replaceTerrainWorldNoiseTuning(terrainTuning.world.noise, values);
    },
    getWaterDebug: () => ({ enabled: false, height: 0 }),
    setWaterDebug: () => undefined,
    getLighting() {
      const tuning = environment.getTuning();
      return {
        directLight: tuning.directLight,
        shadows: tuning.shadows,
        environment: tuning.environment,
        skybox: tuning.sky
      };
    },
    setLighting(values) {
      setSceneTuning({
        directLight: values.directLight,
        shadows: values.shadows,
        environment: values.environment,
        sky: values.skybox
      });
    },
    getRendering() {
      const sceneTuning = environment.getTuning();
      return {
        lighting: {
          directLight: sceneTuning.directLight,
          shadows: sceneTuning.shadows,
          environment: sceneTuning.environment,
          skybox: sceneTuning.sky
        },
        camera: {
          hdr: camera.enableHDR,
          msaaSamples: camera.msaaSamples
        },
        postProcess: {
          enabled: camera.enablePostProcess,
          tonemapping: tonemapping.enabled,
          tonemappingMode: tonemapping.mode.value,
          bloom: {
            enabled: bloom.enabled,
            threshold: bloom.threshold.value,
            intensity: bloom.intensity.value,
            scatter: bloom.scatter.value
          }
        }
      };
    },
    setRendering(values: TerrainRenderingTuning) {
      if (values.lighting) {
        const lighting = values.lighting;
        setSceneTuning({
          directLight: lighting.directLight,
          shadows: lighting.shadows,
          environment: lighting.environment,
          sky: lighting.skybox
        });
      }
      if (values.camera?.hdr !== undefined) camera.enableHDR = values.camera.hdr;
      if (values.camera?.msaaSamples !== undefined) camera.msaaSamples = values.camera.msaaSamples;
      if (values.postProcess?.enabled !== undefined) {
        setSceneTuning({ postProcess: values.postProcess.enabled });
      }
      if (values.postProcess?.tonemapping !== undefined) {
        tonemapping.enabled = values.postProcess.tonemapping;
      }
      if (values.postProcess?.tonemappingMode !== undefined) {
        tonemapping.mode.value = values.postProcess.tonemappingMode;
      }
      const bloomValues = values.postProcess?.bloom;
      if (bloomValues) {
        if (bloomValues.enabled !== undefined) bloom.enabled = bloomValues.enabled;
        if (bloomValues.threshold !== undefined) bloom.threshold.value = bloomValues.threshold;
        if (bloomValues.intensity !== undefined) bloom.intensity.value = bloomValues.intensity;
        if (bloomValues.scatter !== undefined) bloom.scatter.value = bloomValues.scatter;
      }
    },
    getSurface: () => surfaceWorld.getTuning(),
    setSurface: setSurfaceTuning,
    inspectSurface: () => surfaceWorld.inspect(),
    setSurfaceDebugView: (view) => surfaceWorld.setTuning({ debugView: view }),
    resetTuning() {
      const defaults = createTerrainDebugTuning(manifest);
      for (const layer of defaults.layers) {
        const { layer: layerId, ...values } = layer;
        terrainMaterial.setLayerTuning(layerId, values);
      }
      terrainMaterial.setSamplingTuning(defaults.sampling);
      terrainMaterial.setMaterialTuning(defaults.material);
      terrainMaterial.configureWorldNoise(defaults.world.noise);
      terrainMaterial.setBackgroundMode(terrainBackgroundModeToShader(defaults.world.background));
      replaceTerrainDebugTuning(terrainTuning, defaults);
      surfaceWorld.setTuning(surfaceDefaults);
      const wind = surfaceWorld.getTuning().wind;
      architecture.setWind(wind.enabled, wind.strength, wind.direction);
    },
    inspect() {
      const segments = clipmap.inspectSegments();
      const segmentsPerLod = new Array<number>(manifest.clipmap.meshLods).fill(0);
      for (const segment of segments) segmentsPerLod[segment.lod]++;
      return {
        regionLocations: terrainData.regions.map((region) => region.location),
        regionSize: terrainData.regionSize,
        vertexSpacing: terrainData.vertexSpacing,
        meshSize: manifest.clipmap.meshSize,
        meshLods: manifest.clipmap.meshLods,
        segmentCount: clipmap.segmentCount,
        segmentsPerLod,
        segments
      };
    },
    readProbe(worldX, worldZ) {
      return createTerrainProbeSnapshot(terrainData, worldX, worldZ);
    },
    getControlFixture: () => controlFixture
  };
  window.terrainDebug = terrainDebug;
  const requestedView = query.get("view") as TerrainDebugViewName | null;
  const requestedPose = query.get("pose") as TerrainCameraPoseName | null;
  if (requestedView && requestedView in TERRAIN_DEBUG_VIEWS) terrainDebug.setView(requestedView);
  terrainDebug.setPose(requestedPose && GRASSLANDS_POSES.includes(requestedPose) ? requestedPose : "first-person");
  mountTerrainInspector(terrainDebug, {
    title: "Grasslands terrain inspector",
    showWater: false,
    extend: (inspector) => mountGrasslandsInspector(inspector, grasslandsDebug)
  });

  engine.run();
  const snapshot = surfaceWorld.inspect();
  setStatus(
    `ready · 9 terrain tiles · ${snapshot.totalInstances.toLocaleString()} surface instances · ` +
      `${architecture.placements} architecture placements · ${clouds.inspect().instances} sky clouds`
  );
}

function firstPersonPose(camera: GrasslandsSceneLayout["camera"]): TerrainFirstPersonPose {
  const [x, , z] = camera.position;
  const [rotationX, rotationY, rotationZ, rotationW] = camera.rotation;
  const forwardX = -2 * (rotationX * rotationZ + rotationW * rotationY);
  const forwardY = 2 * (rotationW * rotationX - rotationY * rotationZ);
  const forwardZ = -(1 - 2 * (rotationX * rotationX + rotationY * rotationY));
  return {
    x,
    z,
    yaw: Math.atan2(forwardX, -forwardZ),
    pitch: Math.asin(Math.max(-1, Math.min(1, forwardY)))
  };
}

function applyGrasslandsCameraPose(
  cameraEntity: Entity,
  camera: Camera,
  orbit: OrbitControl,
  firstPerson: TerrainFirstPersonController,
  freeControl: FreeControl | null,
  pose: TerrainCameraPoseName,
  authoredCamera: GrasslandsSceneLayout["camera"]
): FreeControl | null {
  if (pose === "first-person") {
    orbit.enabled = false;
    firstPerson.enter(firstPersonPose(authoredCamera));
    freeControl?.destroy();
    const nextFreeControl = cameraEntity.addComponent(FreeControl);
    firstPerson.setFreeControl(nextFreeControl);
    camera.fieldOfView = authoredCamera.fieldOfView;
    return nextFreeControl;
  }

  firstPerson.exit();
  firstPerson.setFreeControl(null);
  freeControl?.destroy();
  orbit.enabled = true;

  if (pose === "hero") {
    cameraEntity.transform.setPosition(...authoredCamera.position);
    cameraEntity.transform.worldRotationQuaternion.set(...authoredCamera.rotation);
    camera.fieldOfView = authoredCamera.fieldOfView;
    setOrbitTargetFromCamera(cameraEntity, orbit);
  } else if (pose === "overview") {
    const target = new Vector3(1500, 22, 1500);
    cameraEntity.transform.setPosition(1500, 140, 1835);
    cameraEntity.transform.lookAt(target);
    orbit.target.copyFrom(target);
    camera.fieldOfView = 58;
  } else if (pose === "grass-wind") {
    const target = new Vector3(1473, 21.2, 1752.5);
    cameraEntity.transform.setPosition(1473, 20.7, 1749.5);
    cameraEntity.transform.lookAt(target);
    orbit.target.copyFrom(target);
    camera.fieldOfView = 50;
  } else if (pose === "valley-overview" || pose === "terrain-horizon") {
    const diagnostic = GRASSLANDS_DIAGNOSTIC_CAMERAS[pose];
    cameraEntity.transform.setPosition(diagnostic.position[0], diagnostic.position[1], diagnostic.position[2]);
    cameraEntity.transform.worldRotationQuaternion.set(
      diagnostic.rotation[0],
      diagnostic.rotation[1],
      diagnostic.rotation[2],
      diagnostic.rotation[3]
    );
    camera.fieldOfView = diagnostic.fieldOfView;
    setOrbitTargetFromCamera(cameraEntity, orbit);
  } else {
    throw new Error(`[terrain-debug] unknown Grasslands pose ${pose}`);
  }
  return null;
}

function setOrbitTargetFromCamera(cameraEntity: Entity, orbit: OrbitControl): void {
  const position = cameraEntity.transform.worldPosition;
  const forward = cameraEntity.transform.worldForward;
  orbit.target.set(position.x + forward.x * 100, position.y + forward.y * 100, position.z + forward.z * 100);
}

async function loadJson<T>(url: URL): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`${url.pathname} returned ${response.status}`);
  return response.json() as Promise<T>;
}

function setStatus(message: string): void {
  if (status) status.textContent = message;
}
