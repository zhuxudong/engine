/**
 * @title Benchmark
 * @category WebGPU
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Engine,
  Material,
  MeshRenderer,
  Shader,
  Vector3,
  VertexElement,
  VertexElementFormat,
  WebGLEngine,
  WebGPUEngine
} from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";

type BenchmarkBackend = "webgl2" | "webgpu";

/** Read-only benchmark measurements collected from rendered animation frames. */
export interface WebGPUBenchmarkSnapshot {
  /** Rendering backend selected before Engine creation. */
  readonly backend: BenchmarkBackend;
  /** Instanced candidates submitted by the single benchmark draw. */
  readonly candidates: number;
  /** Median frames per second over the rolling sample window. */
  readonly fpsMedian: number;
  /** 95th-percentile frame time in milliseconds. */
  readonly frameTimeP95: number;
  /** Number of frame-time samples currently available. */
  readonly sampleCount: number;
  /** Whether the selected adapter exposes WebGPU timestamp queries. */
  readonly gpuTimingSupported: boolean;
  /** Median GPU command-submission span in milliseconds, or null when unavailable. */
  readonly gpuFrameTimeMedian: number | null;
  /** 95th-percentile GPU command-submission span in milliseconds, or null when unavailable. */
  readonly gpuFrameTimeP95: number | null;
  /** Number of distinct asynchronous GPU timing samples currently available. */
  readonly gpuSampleCount: number;
  /** Native render and compute passes covered by the latest GPU timing sample. */
  readonly gpuPassCount: number;
  /** Ordered native pass timings from the latest GPU timing sample. */
  readonly gpuPasses: readonly {
    /** Stable diagnostic pass name. */
    readonly name: string;
    /** Native pass kind. */
    readonly kind: "render" | "compute";
    /** GPU duration in milliseconds. */
    readonly durationMs: number;
  }[];
  /** GPU timing samples skipped rather than blocking on readback. */
  readonly gpuDroppedSampleCount: number;
}

/** Runtime API used by deterministic benchmark automation. */
export interface WebGPUBenchmarkApi {
  /** Whether Engine creation and the first benchmark frame have completed. */
  readonly ready: boolean;
  /**
   * Applies a candidate count through the same logarithmic slider mapping.
   * @param candidates - Requested instance count.
   */
  setCandidates(candidates: number): void;
  /** Clears the rolling frame-time window. */
  resetSamples(): void;
  /**
   * Requests one GPU timestamp measurement for the next command submission.
   * @returns True when a new sample was queued.
   */
  requestGPUTimingSample(): boolean;
  /**
   * Returns the current backend, workload, and timing distribution.
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

const minimumExponent = 14;
const maximumExponent = 26;
const defaultCandidates = 2 ** 20;
const sampleWindowSize = 120;
const shaderSource = `
Shader "WebGPU/BenchmarkCandidates" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = {
        Enabled = false;
        WriteEnabled = false;
      }
      RasterState = {
        CullMode = CullMode.Off;
      }

      struct Attributes {
        vec2 POSITION;
      };

      struct Varyings {
        vec3 color;
      };

      Varyings vert(Attributes attributes) {
        Varyings output;
        float candidate = float(gl_InstanceID);
        float x = fract(candidate * 0.754877666) * 2.0 - 1.0;
        float y = fract(candidate * 0.569840296) * 2.0 - 1.0;
        float scale = 0.0018;
        gl_Position = vec4(vec2(x, y) + attributes.POSITION * scale, 0.0, 1.0);
        output.color = vec3(
          0.25 + 0.75 * fract(candidate * 0.1031),
          0.2 + 0.8 * fract(candidate * 0.11369),
          0.35 + 0.65 * fract(candidate * 0.13787)
        );
        return output;
      }

      vec4 frag(Varyings varyings) {
        vec3 color = varyings.color;
        for (int iteration = 0; iteration < 4; iteration++) {
          color = color * color * 0.72 + vec3(0.18, 0.14, 0.11);
        }
        return vec4(color, 1.0);
      }

      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}
`;

const { backendControl, candidatesControl } = createControls();
const query = new URLSearchParams(location.search);
const backend: BenchmarkBackend = query.get("backend") === "webgpu" ? "webgpu" : "webgl2";
const initialCandidates = normalizeCandidates(
  Number(query.get("candidates")) || defaultCandidates
);

void boot();

async function boot(): Promise<void> {
  backendControl.value = backend;
  candidatesControl.value = sliderValueFromCandidates(initialCandidates).toString();
  const configuration = { canvas: "canvas", shaderCompiler: new ShaderCompiler() };
  const engine =
    backend === "webgpu"
      ? await WebGPUEngine.create({
          ...configuration,
          graphicDeviceOptions: { enableGPUTiming: true }
        })
      : await WebGLEngine.create(configuration);
  engine.canvas.resizeByClientSize();
  window.addEventListener("resize", () => engine.canvas.resizeByClientSize());

  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("benchmark");
  const cameraEntity = root.createChild("camera");
  cameraEntity.addComponent(Camera);
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());

  const renderer = root.createChild("candidates").addComponent(MeshRenderer);
  const mesh = createCandidateMesh(engine);
  mesh.instanceCount = initialCandidates;
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  const frameTimes: number[] = [];
  const gpuFrameTimes: number[] = [];
  let lastFrameTime = performance.now();
  let lastGpuSubmissionId = 0;
  const api: WebGPUBenchmarkApi = {
    ready: true,
    setCandidates(candidates) {
      const normalized = normalizeCandidates(candidates);
      mesh.instanceCount = normalized;
      candidatesControl.value = sliderValueFromCandidates(normalized).toString();
      updateCandidateQuery(normalized);
    },
    resetSamples() {
      frameTimes.length = 0;
      gpuFrameTimes.length = 0;
      lastFrameTime = performance.now();
      lastGpuSubmissionId = engine.gpuTiming.latestSample?.submissionId ?? 0;
      engine.gpuTiming.requestSample();
    },
    requestGPUTimingSample: () => engine.gpuTiming.requestSample(),
    inspect() {
      const sorted = [...frameTimes].sort((left, right) => left - right);
      const sortedGpu = [...gpuFrameTimes].sort((left, right) => left - right);
      const medianFrameTime = percentile(sorted, 0.5);
      const latestGpuSample = engine.gpuTiming.latestSample;
      return {
        backend,
        candidates: mesh.instanceCount,
        fpsMedian: medianFrameTime > 0 ? 1000 / medianFrameTime : 0,
        frameTimeP95: percentile(sorted, 0.95),
        sampleCount: sorted.length,
        gpuTimingSupported: engine.gpuTiming.supported,
        gpuFrameTimeMedian: sortedGpu.length > 0 ? percentile(sortedGpu, 0.5) : null,
        gpuFrameTimeP95: sortedGpu.length > 0 ? percentile(sortedGpu, 0.95) : null,
        gpuSampleCount: sortedGpu.length,
        gpuPassCount: latestGpuSample?.passCount ?? 0,
        gpuPasses: latestGpuSample?.passes.map(({ name, kind, durationMs }) => ({ name, kind, durationMs })) ?? [],
        gpuDroppedSampleCount: engine.gpuTiming.droppedSampleCount
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
    const candidates = candidatesFromSliderValue(Number(candidatesControl.value));
    mesh.instanceCount = candidates;
    updateCandidateQuery(candidates);
    api.resetSamples();
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
    requestAnimationFrame(sampleFrames);
  };
  requestAnimationFrame(sampleFrames);
  engine.run();
}

function createCandidateMesh(engine: Engine): BufferMesh {
  const mesh = new BufferMesh(engine, "benchmark-candidates");
  const positions = new Float32Array([-0.5, -0.5, 0.5, -0.5, 0, 0.5]);
  const vertexBuffer = new Buffer(
    engine,
    BufferBindFlag.VertexBuffer,
    positions,
    BufferUsage.Static
  );
  mesh.setVertexBufferBinding(vertexBuffer, 8);
  mesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector2, 0)
  ]);
  mesh.addSubMesh(0, 3);
  mesh.bounds.min.set(-2, -2, -2);
  mesh.bounds.max.set(2, 2, 2);
  return mesh;
}

function candidatesFromSliderValue(value: number): number {
  const exponent =
    minimumExponent + (Math.min(100, Math.max(0, value)) / 100) *
      (maximumExponent - minimumExponent);
  return normalizeCandidates(2 ** exponent);
}

function sliderValueFromCandidates(candidates: number): number {
  return (
    ((Math.log2(normalizeCandidates(candidates)) - minimumExponent) /
      (maximumExponent - minimumExponent)) *
    100
  );
}

function normalizeCandidates(candidates: number): number {
  return Math.round(
    Math.min(2 ** maximumExponent, Math.max(2 ** minimumExponent, candidates))
  );
}

function updateCandidateQuery(candidates: number): void {
  const url = new URL(location.href);
  url.searchParams.set("candidates", candidates.toString());
  history.replaceState(null, "", url);
}

function createControls(): {
  backendControl: HTMLSelectElement;
  candidatesControl: HTMLInputElement;
} {
  const style = document.createElement("style");
  style.textContent = `
    #benchmark-controls {
      position: fixed;
      top: 12px;
      right: 12px;
      z-index: 1;
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
    #candidates {
      width: 100%;
      margin: 0;
    }
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
  controls.append(
    backendLabel,
    backendControl,
    candidatesLabel,
    candidatesControl
  );
  document.body.appendChild(controls);
  return { backendControl, candidatesControl };
}

function percentile(sorted: readonly number[], value: number): number {
  if (sorted.length === 0) {
    return 0;
  }
  return sorted[Math.min(sorted.length - 1, Math.floor((sorted.length - 1) * value))];
}
