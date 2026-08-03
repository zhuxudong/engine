/**
 * @title 16 Grasslands Benchmark
 * @category WebGPU
 * @backend webgpu
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Engine,
  IndexFormat,
  Material,
  MeshRenderer,
  PrimitiveMesh,
  RenderFace,
  Shader,
  UnlitMaterial,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { OrbitControl } from "@galacean/engine-toolkit-controls";
import {
  createExampleEngine,
  markExampleReady,
  runExample,
  waitForFrames,
  type ExampleBackend
} from "../_shared/example";
import { grasslandsGrassIndices, grasslandsGrassPositions } from "./_grasslands-grass";

/** Read-only measurements collected from rendered benchmark frames. */
export interface WebGPUBenchmarkSnapshot {
  /** Rendering backend selected before Engine creation. */
  readonly backend: ExampleBackend;
  /** Instances submitted by the benchmark draw. */
  readonly candidates: number;
  /** Median frames per second over the rolling sample window. */
  readonly fpsMedian: number;
  /** 95th-percentile frame time in milliseconds. */
  readonly frameTimeP95: number;
  /** Number of frame-time samples currently available. */
  readonly sampleCount: number;
  /** Whether GPU timestamp queries are available. */
  readonly gpuTimingSupported: boolean;
  /** Median GPU command-submission span in milliseconds, or null when unavailable. */
  readonly gpuFrameTimeMedian: number | null;
  /** Number of distinct asynchronous GPU timing samples currently available. */
  readonly gpuSampleCount: number;
}

/** Runtime API used by deterministic benchmark automation. */
export interface WebGPUBenchmarkApi {
  /** Whether Engine creation and the first benchmark frames have completed. */
  readonly ready: boolean;
  /**
   * Apply a candidate count through the logarithmic slider mapping.
   * @param candidates - Requested instance count.
   * @returns Nothing.
   */
  setCandidates(candidates: number): void;
  /** Clear the rolling CPU and GPU frame-time windows. */
  resetSamples(): void;
  /**
   * Request one GPU timestamp measurement for the next command submission.
   * @returns True when a sample was queued.
   */
  requestGPUTimingSample(): boolean;
  /**
   * Read the current backend, workload, and timing distribution.
   * @returns Current benchmark snapshot.
   */
  inspect(): WebGPUBenchmarkSnapshot;
}

declare global {
  interface Window {
    /** Runtime benchmark controls and measurements. */
    webgpuBenchmark?: WebGPUBenchmarkApi;
  }
}

const minimumExponent = 8;
const maximumExponent = 22;
const defaultCandidates = 2 ** 13;
const sampleWindowSize = 120;
const shaderSource = `
Shader "WebGPU/GrasslandsBenchmark" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = true; WriteEnabled = true; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec3 POSITION; };
      struct Varyings { vec3 color; };
      mat4 renderer_MVPMat;
      float material_GridSize;
      float material_Time;

      Varyings vert(Attributes attributes) {
        Varyings output;
        float instance = float(gl_InstanceID);
        float column = mod(instance, material_GridSize);
        float row = floor(instance / material_GridSize);
        float random = fract(instance * 0.754877666);
        float angle = random * 6.283185307;
        float cosine = cos(angle);
        float sine = sin(angle);
        float scale = 0.72 + fract(instance * 0.569840296) * 0.55;
        vec3 position = attributes.POSITION * scale;
        float rotatedX = position.x * cosine - position.z * sine;
        float rotatedZ = position.x * sine + position.z * cosine;
        vec2 offset = vec2(
          ((column + random * 0.7) / material_GridSize - 0.5) * 50.0,
          ((row + fract(instance * 0.13787) * 0.7) / material_GridSize - 0.5) * 50.0
        );
        float wind = sin(material_Time * 1.7 + offset.x * 0.32 + offset.y * 0.21);
        position.x = rotatedX + wind * max(position.y, 0.0) * 0.09 + offset.x;
        position.z = rotatedZ + offset.y;
        gl_Position = renderer_MVPMat * vec4(position, 1.0);
        float tip = clamp((attributes.POSITION.y + 0.1) / 0.83, 0.0, 1.0);
        vec3 baseColor = vec3(0.035, 0.28, 0.045);
        vec3 tipColor = vec3(0.28, 0.68, 0.11);
        output.color = mix(baseColor, tipColor, tip) * (0.82 + random * 0.3);
        return output;
      }

      vec4 frag(Varyings varyings) {
        return vec4(varyings.color, 1.0);
      }

      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

const { backendControl, candidatesControl, fpsValue } = createControls();
const initialCandidates = normalizeCandidates(
  Number(new URLSearchParams(location.search).get("candidates")) || defaultCandidates
);

runExample(boot);

async function boot(): Promise<void> {
  const { engine, backend } = await createExampleEngine({
    defaultBackend: "webgpu",
    enableGPUTiming: true,
    showBackendControl: false
  });
  backendControl.value = backend;
  candidatesControl.value = sliderValueFromCandidates(initialCandidates).toString();

  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.22, 0.42, 0.68, 1);
  const root = scene.createRootEntity("grasslands-benchmark");
  const cameraEntity = root.createChild("camera");
  cameraEntity.addComponent(Camera);
  cameraEntity.transform.setPosition(0, 7, 11);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(OrbitControl).target.set(0, 1, 0);

  const groundRenderer = root.createChild("ground").addComponent(MeshRenderer);
  groundRenderer.mesh = PrimitiveMesh.createPlane(engine, 400, 400);
  const groundMaterial = new UnlitMaterial(engine);
  groundMaterial.baseColor.set(0.08, 0.19, 0.055, 1);
  groundMaterial.renderFace = RenderFace.Double;
  groundRenderer.setMaterial(groundMaterial);

  const renderer = root.createChild("grass-clusters").addComponent(MeshRenderer);
  const mesh = createCandidateMesh(engine);
  mesh.instanceCount = initialCandidates;
  renderer.mesh = mesh;
  const material = new Material(engine, Shader.create(shaderSource));
  material.shaderData.setFloat("material_GridSize", Math.ceil(Math.sqrt(initialCandidates)));
  material.shaderData.setFloat("material_Time", 0);
  renderer.setMaterial(material);

  const frameTimes: number[] = [];
  const gpuFrameTimes: number[] = [];
  let lastFrameTime = performance.now();
  let lastGpuSubmissionId = 0;
  let framesSinceReadout = 0;
  let ready = false;
  const resetSamples = (): void => {
    frameTimes.length = 0;
    gpuFrameTimes.length = 0;
    fpsValue.textContent = "--";
    lastFrameTime = performance.now();
    lastGpuSubmissionId = engine.gpuTiming.latestSample?.submissionId ?? 0;
    engine.gpuTiming.requestSample();
  };
  const api: WebGPUBenchmarkApi = {
    get ready() {
      return ready;
    },
    setCandidates(candidates) {
      const normalized = normalizeCandidates(candidates);
      mesh.instanceCount = normalized;
      material.shaderData.setFloat("material_GridSize", Math.ceil(Math.sqrt(normalized)));
      candidatesControl.value = sliderValueFromCandidates(normalized).toString();
      updateCandidateQuery(normalized);
      resetSamples();
    },
    resetSamples,
    requestGPUTimingSample: () => engine.gpuTiming.requestSample(),
    inspect() {
      const sorted = [...frameTimes].sort((left, right) => left - right);
      const sortedGpu = [...gpuFrameTimes].sort((left, right) => left - right);
      const medianFrameTime = percentile(sorted, 0.5);
      return {
        backend,
        candidates: mesh.instanceCount,
        fpsMedian: medianFrameTime > 0 ? 1000 / medianFrameTime : 0,
        frameTimeP95: percentile(sorted, 0.95),
        sampleCount: sorted.length,
        gpuTimingSupported: engine.gpuTiming.supported,
        gpuFrameTimeMedian: sortedGpu.length > 0 ? percentile(sortedGpu, 0.5) : null,
        gpuSampleCount: sortedGpu.length
      };
    }
  };
  window.webgpuBenchmark = api;

  backendControl.addEventListener("change", () => {
    const url = new URL(location.href);
    url.searchParams.set("backend", backendControl.value);
    url.searchParams.set("candidates", mesh.instanceCount.toString());
    location.href = url.href;
  });
  candidatesControl.addEventListener("input", () => {
    api.setCandidates(candidatesFromSliderValue(Number(candidatesControl.value)));
  });

  const sampleFrames = (now: number): void => {
    frameTimes.push(now - lastFrameTime);
    if (frameTimes.length > sampleWindowSize) {
      frameTimes.shift();
    }
    lastFrameTime = now;
    const gpuSample = engine.gpuTiming.latestSample;
    if (gpuSample && gpuSample.submissionId !== lastGpuSubmissionId) {
      lastGpuSubmissionId = gpuSample.submissionId;
      gpuFrameTimes.push(gpuSample.durationMs);
      if (gpuFrameTimes.length > sampleWindowSize) {
        gpuFrameTimes.shift();
      }
    }
    framesSinceReadout++;
    if (framesSinceReadout >= 15) {
      const sorted = [...frameTimes].sort((left, right) => left - right);
      const medianFrameTime = percentile(sorted, 0.5);
      fpsValue.textContent = medianFrameTime > 0 ? (1000 / medianFrameTime).toFixed(1) : "--";
      framesSinceReadout = 0;
    }
    material.shaderData.setFloat("material_Time", now * 0.001);
    requestAnimationFrame(sampleFrames);
  };
  requestAnimationFrame(sampleFrames);
  engine.run();
  await waitForFrames();
  ready = true;
  markExampleReady(`${backend} Grasslands grass benchmark`);
}

function createCandidateMesh(engine: Engine): BufferMesh {
  const mesh = new BufferMesh(engine, "grasslands-grass-lod0");
  mesh.setVertexBufferBinding(
    new Buffer(engine, BufferBindFlag.VertexBuffer, grasslandsGrassPositions, BufferUsage.Static),
    12
  );
  mesh.setIndexBufferBinding(
    new Buffer(engine, BufferBindFlag.IndexBuffer, grasslandsGrassIndices, BufferUsage.Static),
    IndexFormat.UInt16
  );
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0)]);
  mesh.addSubMesh(0, grasslandsGrassIndices.length);
  mesh.bounds.min.set(-200, -1, -200);
  mesh.bounds.max.set(200, 2, 200);
  return mesh;
}

function candidatesFromSliderValue(value: number): number {
  const exponent = minimumExponent + (Math.min(100, Math.max(0, value)) / 100) * (maximumExponent - minimumExponent);
  return normalizeCandidates(2 ** exponent);
}

function sliderValueFromCandidates(candidates: number): number {
  return ((Math.log2(normalizeCandidates(candidates)) - minimumExponent) / (maximumExponent - minimumExponent)) * 100;
}

function normalizeCandidates(candidates: number): number {
  return Math.round(Math.min(2 ** maximumExponent, Math.max(2 ** minimumExponent, candidates)));
}

function updateCandidateQuery(candidates: number): void {
  const url = new URL(location.href);
  url.searchParams.set("candidates", candidates.toString());
  history.replaceState(null, "", url);
}

function createControls(): {
  backendControl: HTMLSelectElement;
  candidatesControl: HTMLInputElement;
  fpsValue: HTMLOutputElement;
} {
  const style = document.createElement("style");
  style.textContent = `
    #benchmark-controls {
      position: fixed;
      top: 12px;
      right: 12px;
      z-index: 10;
      display: grid;
      grid-template-columns: auto minmax(180px, 26vw);
      gap: 10px 12px;
      align-items: center;
      padding: 10px 12px;
      border: 1px solid rgb(255 255 255 / 16%);
      border-radius: 6px;
      color: #f5f7fa;
      background: rgb(12 15 22 / 88%);
      font: 12px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    #backend {
      width: 100%;
      color: inherit;
      border: 1px solid rgb(255 255 255 / 20%);
      border-radius: 4px;
      background: #232936;
      font: inherit;
    }
    #candidates { width: 100%; margin: 0; }
  `;
  document.head.appendChild(style);

  const controls = document.createElement("div");
  controls.id = "benchmark-controls";
  const backendLabel = document.createElement("label");
  backendLabel.htmlFor = "backend";
  backendLabel.textContent = "backend";
  const backendControl = document.createElement("select");
  backendControl.id = "backend";
  for (const backend of ["webgl2", "webgpu"] as const) {
    const option = document.createElement("option");
    option.value = backend;
    option.textContent = backend;
    backendControl.appendChild(option);
  }
  const candidatesLabel = document.createElement("label");
  candidatesLabel.htmlFor = "candidates";
  candidatesLabel.textContent = "candidates";
  const candidatesControl = document.createElement("input");
  candidatesControl.id = "candidates";
  candidatesControl.type = "range";
  candidatesControl.min = "0";
  candidatesControl.max = "100";
  candidatesControl.step = "1";
  const fpsLabel = document.createElement("span");
  fpsLabel.textContent = "fps";
  const fpsValue = document.createElement("output");
  fpsValue.id = "fps";
  fpsValue.textContent = "--";
  controls.append(backendLabel, backendControl, candidatesLabel, candidatesControl, fpsLabel, fpsValue);
  document.body.appendChild(controls);
  return { backendControl, candidatesControl, fpsValue };
}

function percentile(sorted: readonly number[], value: number): number {
  if (sorted.length === 0) {
    return 0;
  }
  return sorted[Math.min(sorted.length - 1, Math.floor((sorted.length - 1) * value))];
}
