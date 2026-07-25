import {
  BloomEffect,
  Camera,
  DepthTextureMode,
  MSAASamples,
  PostProcess,
  Shader,
  TonemappingEffect,
  TonemappingMode,
  WebGLEngine
} from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";
import { FreeControl } from "@galacean/engine-toolkit-controls";
import { Stats } from "@galacean/engine-toolkit-stats";
import { TerrainMaterial } from "../src/TerrainMaterial";
import {
  TerrainFirstPersonController,
  type TerrainFirstPersonPose,
  type TerrainFirstPersonSnapshot
} from "../src/TerrainFirstPersonController";
import { TerrainClipmap } from "../src/clipmap/TerrainClipmap";
import { loadLayerTextures } from "../src/loader/LayerTextureLoader";
import { loadMacroNoiseTexture } from "../src/loader/MacroNoiseLoader";
import { loadManifest } from "../src/loader/ManifestLoader";
import { loadTerrainData } from "../src/loader/TerrainDataLoader";
import surfaceShaderSource from "../src/shaders/Surface.shader?raw";
import terrainShaderSource from "../src/shaders/Terrain.shader?raw";
import { registerTerrainShaderIncludes } from "../src/shaders/registerTerrainShaderIncludes";
import { SurfaceWorld } from "../src/surface/SurfaceWorld";
import type { SurfaceRuntimeTuningUpdate } from "../src/surface/SurfaceRuntimeContract";
import {
  loadGrasslandsArchitecture,
  type GrasslandsArchitectureSpec
} from "./src/GrasslandsArchitecture";
import {
  GrasslandsCloudSystem,
  type GrasslandsCloudPlacementSpec,
  type GrasslandsCloudPresetSpec
} from "./src/GrasslandsCloudSystem";
import {
  mountGrasslandsInspector,
  type GrasslandsSceneTuning
} from "./src/GrasslandsDebugInspector";
import {
  createGrasslandsEnvironment,
  type GrasslandsEnvironmentSpec
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
      setScene(
        values: Partial<
          GrasslandsSceneTuning
        >
      ): void;
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
  if (new URLSearchParams(location.search).has("stats")) cameraEntity.addComponent(Stats);

  const manifestUrl = new URL("../data/grasslands/terrain-manifest.json", import.meta.url).href;
  const surfaceManifestUrl = new URL("../data/grasslands/surface-manifest.json", import.meta.url).href;
  const sceneLayoutUrl = new URL("../data/grasslands/scene-layout.json", import.meta.url);
  const sceneLayout = await loadJson<GrasslandsSceneLayout>(sceneLayoutUrl);
  camera.fieldOfView = sceneLayout.camera.fieldOfView;
  camera.nearClipPlane = sceneLayout.camera.nearClip;
  camera.farClipPlane = sceneLayout.camera.farClip;
  cameraEntity.transform.position.set(...sceneLayout.camera.position);

  setStatus("loading 3 km terrain");
  const manifest = await loadManifest(engine, manifestUrl);
  const [terrainData, layerTextures, macroNoise] = await Promise.all([
    loadTerrainData(engine, manifest, manifestUrl),
    loadLayerTextures(engine, manifest.layers, manifestUrl),
    loadMacroNoiseTexture(engine, new URL(manifest.material.macroVariation.noiseTexture, manifestUrl).href)
  ]);
  const firstPerson = cameraEntity.addComponent(TerrainFirstPersonController);
  firstPerson.configure(terrainData);
  firstPerson.enter(firstPersonPose(sceneLayout.camera));
  const freeControl = cameraEntity.addComponent(FreeControl);
  firstPerson.setFreeControl(freeControl);
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

  const terrainMaterial = new TerrainMaterial(engine);
  terrainMaterial.bindTerrain(terrainData, manifest.clipmap.meshSize);
  terrainMaterial.setLayerLibrary(layerTextures.albedoHeight, layerTextures.normalRoughness, manifest.layers);
  terrainMaterial.configure(manifest.material, macroNoise);
  terrainMaterial.configureWorldNoise(manifest.world.noise);
  terrainMaterial.setBackgroundMode(0);
  new TerrainClipmap(
    engine,
    root.createChild("terrain"),
    camera,
    terrainData,
    terrainMaterial,
    manifest.clipmap.meshSize,
    manifest.clipmap.meshLods
  );

  setStatus("loading 291,072 deterministic surface instances");
  const surfaceWorld = await SurfaceWorld.create(
    engine,
    root.createChild("surface-world"),
    camera,
    surfaceManifestUrl
  );
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
    sceneLayoutUrl.href
  );
  window.grasslandsDebug = {
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
    setSurface: (values) => {
      surfaceWorld.setTuning(values);
      if (values.wind) {
        const wind = surfaceWorld.getTuning().wind;
        architecture.setWind(wind.enabled, wind.strength, wind.direction);
      }
    },
    getScene: () => ({
      ...environment.getTuning(),
      architecture: architecture.root.isActive,
      clouds: clouds.inspect().visible,
      postProcess: camera.enablePostProcess
    }),
    setScene: (values) => {
      environment.setTuning(values);
      if (values.architecture !== undefined) {
        architecture.root.isActive = values.architecture;
      }
      if (values.postProcess !== undefined) {
        camera.enablePostProcess = values.postProcess;
        exposure.isActive = values.postProcess;
      }
      clouds.setTuning({
        visible: values.clouds,
        animation: values.animation
      });
    }
  };
  mountGrasslandsInspector(window.grasslandsDebug);

  engine.run();
  const snapshot = surfaceWorld.inspect();
  setStatus(
    `ready · 9 terrain tiles · ${snapshot.totalInstances.toLocaleString()} surface instances · ` +
      `${architecture.placements} architecture placements · ${clouds.inspect().instances} clouds`
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

async function loadJson<T>(url: URL): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`${url.pathname} returned ${response.status}`);
  return response.json() as Promise<T>;
}

function setStatus(message: string): void {
  if (status) status.textContent = message;
}
