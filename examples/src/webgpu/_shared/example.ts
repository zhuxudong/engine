import { Engine, WebGLEngine, WebGLMode, WebGPUEngine } from "@galacean/engine";
import { ShaderCompiler } from "@galacean/engine-shader-compiler";

/** Rendering backend selectable by the WebGPU feature examples. */
export type ExampleBackend = "webgl2" | "webgpu";

/** Options shared by WebGPU feature example initialization. */
export interface ExampleEngineOptions {
  /** Backend used when the example URL does not contain a `backend` query parameter. */
  defaultBackend?: ExampleBackend;
  /** Whether WebGPU timestamp collection should be requested during device creation. */
  enableGPUTiming?: boolean;
  /** Whether the shared backend selector should be displayed. */
  showBackendControl?: boolean;
}

/** Initialized example engine and the backend selected before its creation. */
export interface ExampleEngineContext {
  /** Newly initialized engine. */
  readonly engine: Engine;
  /** Backend selected from the current page URL. */
  readonly backend: ExampleBackend;
}

/**
 * Create exactly one engine for the backend selected by the page query.
 * @param options - Default backend and optional WebGPU device features.
 * @returns Initialized engine and its stable backend label.
 */
export async function createExampleEngine(options: ExampleEngineOptions = {}): Promise<ExampleEngineContext> {
  const query = new URLSearchParams(location.search);
  const defaultBackend = options.defaultBackend ?? "webgpu";
  const requestedBackend = query.get("backend");
  const backend: ExampleBackend =
    requestedBackend === "webgpu" || requestedBackend === "webgl2" ? requestedBackend : defaultBackend;
  if (options.showBackendControl !== false) {
    createBackendControl(backend);
  }
  document.documentElement.dataset.exampleBackend = backend;
  const configuration = { canvas: "canvas", shaderCompiler: new ShaderCompiler() };
  const engine =
    backend === "webgpu"
      ? await WebGPUEngine.create({
          ...configuration,
          graphicDeviceOptions: { enableGPUTiming: options.enableGPUTiming }
        })
      : await WebGLEngine.create({
          ...configuration,
          graphicDeviceOptions: { webGLMode: WebGLMode.WebGL2 }
        });

  engine.canvas.resizeByClientSize();
  window.addEventListener("resize", () => engine.canvas.resizeByClientSize());
  return { engine, backend };
}

/**
 * Mark a feature example as visibly rendered and ready for browser verification.
 * @param summary - Short result displayed beside the backend selector.
 * @returns Nothing.
 */
export function markExampleReady(summary: string): void {
  const status = document.getElementById("example-status");
  if (status) {
    status.textContent = summary;
  }
  document.documentElement.dataset.exampleReady = "true";
}

/**
 * Run an asynchronous example and expose failures in both the page and console.
 * @param task - Complete example initialization task.
 * @returns Nothing.
 */
export function runExample(task: () => Promise<void>): void {
  void task().catch((error: unknown) => {
    const message = error instanceof Error ? error.message : String(error);
    document.documentElement.dataset.exampleError = message;
    const status = document.getElementById("example-status") ?? createStatusElement();
    status.textContent = message;
    status.dataset.state = "error";
    console.error(error);
  });
}

/**
 * Wait for the requested number of browser animation frames.
 * @param count - Positive number of frames to wait.
 * @returns Promise resolved after the final animation frame.
 */
export async function waitForFrames(count: number = 3): Promise<void> {
  for (let frame = 0; frame < count; frame++) {
    await new Promise<void>((resolve) => requestAnimationFrame(() => resolve()));
  }
}

function createBackendControl(backend: ExampleBackend): void {
  const style = document.createElement("style");
  style.textContent = `
    #example-controls {
      position: fixed;
      top: 12px;
      right: 12px;
      z-index: 10;
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 9px 11px;
      border: 1px solid rgb(255 255 255 / 18%);
      border-radius: 6px;
      color: #f5f7fa;
      background: rgb(12 15 22 / 88%);
      font: 12px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    #example-backend {
      color: inherit;
      border: 1px solid rgb(255 255 255 / 20%);
      border-radius: 4px;
      background: #232936;
      font: inherit;
    }
    #example-status[data-state="error"] { color: #ff8a8a; }
  `;
  document.head.appendChild(style);

  const controls = document.createElement("div");
  controls.id = "example-controls";
  const label = document.createElement("label");
  label.htmlFor = "example-backend";
  label.textContent = "backend";
  const select = document.createElement("select");
  select.id = "example-backend";
  for (const value of ["webgl2", "webgpu"] as const) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = value;
    select.appendChild(option);
  }
  select.value = backend;
  select.addEventListener("change", () => {
    const url = new URL(location.href);
    url.searchParams.set("backend", select.value);
    location.href = url.href;
  });

  controls.append(label, select, createStatusElement());
  document.body.appendChild(controls);
}

function createStatusElement(): HTMLSpanElement {
  const status = document.createElement("span");
  status.id = "example-status";
  status.textContent = "initializing";
  return status;
}
