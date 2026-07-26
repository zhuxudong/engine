import type { Engine } from "@galacean/engine";
import { Core } from "@galacean/engine-toolkit-stats";

const PANEL_ID = "terrain-performance-panel";
const STYLE_ID = "terrain-performance-panel-style";
const BYTES_PER_MEGABYTE = 1024 * 1024;
const FRAME_SAMPLE_COUNT = 120;

type PanelState = "expanded" | "collapsed" | "hidden";

interface WebGLEngineInternals {
  readonly _hardwareRenderer: {
    readonly gl: WebGLRenderingContext | WebGL2RenderingContext;
  };
}

interface PerformanceMemorySource {
  readonly memory?: {
    readonly usedJSHeapSize: number;
  };
}

interface MetricDefinition {
  readonly key: string;
  readonly label: string;
  readonly title: string;
}

const METRICS: readonly MetricDefinition[] = [
  {
    key: "fps",
    label: "FPS / 帧率",
    title: "最近一秒动画帧回调的平均每秒帧数。"
  },
  {
    key: "frameP95",
    label: "Frame P95 / 帧耗",
    title: "最近 120 帧中 95% 的帧耗不超过该毫秒值。"
  },
  {
    key: "jsMemory",
    label: "JS heap / JS 堆",
    title: "浏览器可用时报告已使用的 JavaScript 堆内存，单位 MB。"
  },
  {
    key: "gpuMemory",
    label: "GPU memory / GPU 内存",
    title: "引擎追踪的纹理与缓冲总内存，单位 MB。"
  },
  {
    key: "drawCalls",
    label: "Draw calls / 绘制调用",
    title: "Toolkit WebGL hook 在当前采样周期观察到的绘制调用数。"
  },
  {
    key: "meshTriangles",
    label: "Mesh tris / 网格三角形",
    title: "每笔绘制提交的网格三角形；实例数量单独显示，不重复乘入该值。"
  },
  {
    key: "surfaceInstances",
    label: "Surface / 可见实例",
    title: "当前通过距离、类别和密度筛选后可见的草、花、树木、灌木与岩石实例。"
  },
  {
    key: "surfaceBatches",
    label: "Batches / 可见批次",
    title: "当前活跃地表渲染批次与全部已加载批次。"
  },
  {
    key: "coverageInstances",
    label: "Coverage / 密集覆盖",
    title: "当前从有限区域密度图生成的草与花实例。"
  },
  {
    key: "worldInstances",
    label: "World / 世界流送",
    title: "当前从 world-noise 全局格点生成的地表实例。"
  },
  {
    key: "surfaceLods",
    label: "Sparse LOD / 稀疏层级",
    title: "当前树木、灌木与岩石等稀疏实例在各网格 LOD 的数量。"
  },
  {
    key: "clipmapSegments",
    label: "Clipmap / 地形区块",
    title: "当前几何裁剪图提交管理的网格区块数。"
  },
  {
    key: "textures",
    label: "Textures / 纹理",
    title: "Toolkit WebGL hook 观察到的活动纹理数。"
  },
  {
    key: "shaders",
    label: "Shaders / 着色器",
    title: "Toolkit WebGL hook 观察到的活动着色器数。"
  },
  {
    key: "webgl",
    label: "WebGL / 图形接口",
    title: "当前 WebGL 上下文版本。"
  }
];

/**
 * Scene-specific values appended to the common engine statistics.
 */
export interface TerrainPerformanceSceneMetrics {
  /** Number of geometry-clipmap segments managed by the terrain runtime. */
  readonly clipmapSegments: number;
  /** Number of surface instances visible after runtime LOD and density filtering. */
  readonly visibleSurfaceInstances: number;
  /** Number of active surface renderer batches. */
  readonly visibleSurfaceBatches: number;
  /** Number of all loaded surface renderer batches. */
  readonly totalSurfaceBatches: number;
  /** Number of visible instances generated from finite-region density masks. */
  readonly coverageInstances: number;
  /** Number of visible instances streamed over the procedural world. */
  readonly worldInstances: number;
  /** Visible sparse surface-instance counts per mesh LOD. */
  readonly surfaceLodCounts: readonly number[];
}

/**
 * Supplies current terrain and surface statistics without coupling the panel to
 * either validation entry.
 *
 * @returns Current scene metrics, or `null` while scene data is still loading.
 */
export type TerrainPerformanceSceneMetricsProvider = () => TerrainPerformanceSceneMetrics | null;

/**
 * Displays engine, WebGL, clipmap, and surface statistics in a shared foldable
 * overlay.
 */
export class TerrainPerformancePanel {
  private readonly _engine: Engine;
  private readonly _core: Core;
  private readonly _root: HTMLElement;
  private readonly _metrics: HTMLDListElement;
  private readonly _launcher: HTMLButtonElement;
  private readonly _toggle: HTMLButtonElement;
  private readonly _webglVersion: string;
  private readonly _values = new Map<string, HTMLElement>();
  private readonly _frameTimes: number[] = [];
  private _sceneMetrics: TerrainPerformanceSceneMetricsProvider = () => null;
  private _animationFrame = 0;
  private _lastFrameTime = performance.now();
  private _lastPanelUpdate = performance.now();
  private _frameCount = 0;
  private _state: PanelState = "hidden";

  /**
   * Creates the panel and starts sampling.
   *
   * @param engine Engine whose WebGL and graphics-memory statistics are observed.
   */
  constructor(engine: Engine) {
    this._engine = engine;
    ensureStyles();
    this._root = createPanelRoot();
    this._metrics = this._root.querySelector<HTMLDListElement>("[data-role='metrics']")!;
    this._launcher = this._root.querySelector<HTMLButtonElement>("[data-action='show']")!;
    this._toggle = this._root.querySelector<HTMLButtonElement>("[data-action='toggle']")!;
    for (const value of this._root.querySelectorAll<HTMLElement>("[data-metric]")) {
      this._values.set(value.dataset.metric!, value);
    }
    this._toggle.addEventListener("click", this._toggleCollapsed);
    this._root.querySelector<HTMLButtonElement>("[data-action='hide']")!.addEventListener("click", this._hide);
    this._launcher.addEventListener("click", this._show);
    this._setState("hidden");
    document.body.appendChild(this._root);

    // engine-toolkit-stats uses the same internal boundary because Engine does
    // not expose its WebGL context as public API.
    const gl = (engine as unknown as WebGLEngineInternals)._hardwareRenderer.gl;
    this._webglVersion =
      typeof WebGL2RenderingContext !== "undefined" && gl instanceof WebGL2RenderingContext ? "2.0" : "1.0";
    this._core = new Core(gl);
    this._animationFrame = requestAnimationFrame(this._update);
    window.addEventListener("beforeunload", this.destroy, { once: true });
  }

  /**
   * Connects scene-specific clipmap and surface values after their runtimes load.
   *
   * @param provider Function returning the current scene metrics.
   */
  setSceneMetricsProvider(provider: TerrainPerformanceSceneMetricsProvider): void {
    this._sceneMetrics = provider;
  }

  /**
   * Releases WebGL hooks and removes the overlay.
   */
  destroy = (): void => {
    if (!this._animationFrame) return;
    cancelAnimationFrame(this._animationFrame);
    this._animationFrame = 0;
    this._core.release();
    this._root.remove();
    window.removeEventListener("beforeunload", this.destroy);
  };

  private readonly _update = (time: number): void => {
    const frameTime = time - this._lastFrameTime;
    this._lastFrameTime = time;
    this._frameCount++;
    if (frameTime > 0 && frameTime < 1000) {
      this._frameTimes.push(frameTime);
      if (this._frameTimes.length > FRAME_SAMPLE_COUNT) this._frameTimes.shift();
    }

    const panelInterval = time - this._lastPanelUpdate;
    if (panelInterval >= 1000) {
      const fps = Math.round((this._frameCount * 1000) / panelInterval);
      this._setValue("fps", String(fps), fpsLevel(fps));
      this._setValue("frameP95", `${percentile95(this._frameTimes).toFixed(1)} ms`);
      const memory = (performance as unknown as PerformanceMemorySource).memory;
      this._setValue("jsMemory", memory ? `${Math.round(memory.usedJSHeapSize / BYTES_PER_MEGABYTE)} MB` : "—");
      this._setValue("gpuMemory", `${formatMegabytes(this._engine.renderingStatistics.totalMemory)} MB`);
      this._setValue("webgl", this._webglVersion);
      this._updateSceneMetrics();
      this._lastPanelUpdate = time;
      this._frameCount = 0;
    }

    const sample = this._core.update();
    if (sample) {
      this._setValue("drawCalls", sample.drawCall.toLocaleString("en-US"));
      this._setValue("meshTriangles", Math.round(sample.triangles).toLocaleString("en-US"));
      this._setValue("textures", sample.textures.toLocaleString("en-US"));
      this._setValue("shaders", sample.shaders.toLocaleString("en-US"));
    }
    this._animationFrame = requestAnimationFrame(this._update);
  };

  private readonly _toggleCollapsed = (): void => {
    this._setState(this._state === "collapsed" ? "expanded" : "collapsed");
  };

  private readonly _hide = (): void => {
    this._setState("hidden");
  };

  private readonly _show = (): void => {
    this._setState("expanded");
  };

  private _setState(state: PanelState): void {
    this._state = state;
    this._root.dataset.state = state;
    const expanded = state === "expanded";
    this._toggle.setAttribute("aria-expanded", String(expanded));
    this._metrics.hidden = !expanded;
    this._launcher.hidden = state !== "hidden";
  }

  private _setValue(key: string, text: string, level?: "good" | "warn" | "bad"): void {
    const value = this._values.get(key);
    if (!value) return;
    value.textContent = text;
    if (level) value.dataset.level = level;
    else delete value.dataset.level;
  }

  private _updateSceneMetrics(): void {
    const scene = this._sceneMetrics();
    if (!scene) return;
    this._setValue("surfaceInstances", scene.visibleSurfaceInstances.toLocaleString("en-US"));
    this._setValue(
      "surfaceBatches",
      `${scene.visibleSurfaceBatches.toLocaleString("en-US")} / ${scene.totalSurfaceBatches.toLocaleString("en-US")}`
    );
    this._setValue("coverageInstances", scene.coverageInstances.toLocaleString("en-US"));
    this._setValue("worldInstances", scene.worldInstances.toLocaleString("en-US"));
    this._setValue(
      "surfaceLods",
      scene.surfaceLodCounts.map((count, lod) => `${lod}:${formatCompactCount(count)}`).join(" ")
    );
    this._setValue("clipmapSegments", scene.clipmapSegments.toLocaleString("en-US"));
  }
}

function createPanelRoot(): HTMLElement {
  const root = document.createElement("section");
  root.id = PANEL_ID;
  root.className = "terrain-performance";
  root.dataset.state = "hidden";
  root.setAttribute("aria-label", "Terrain performance / 地形性能");

  const shell = document.createElement("div");
  shell.className = "terrain-performance__shell";

  const header = document.createElement("header");
  header.className = "terrain-performance__header";

  const toggle = document.createElement("button");
  toggle.className = "terrain-performance__toggle";
  toggle.type = "button";
  toggle.dataset.action = "toggle";
  toggle.setAttribute("aria-controls", `${PANEL_ID}-metrics`);
  toggle.setAttribute("aria-expanded", "false");
  toggle.innerHTML =
    '<span class="terrain-performance__chevron" aria-hidden="true">▾</span>' + "<span>Performance / 性能</span>";

  const hide = document.createElement("button");
  hide.className = "terrain-performance__hide";
  hide.type = "button";
  hide.dataset.action = "hide";
  hide.setAttribute("aria-label", "Hide performance panel / 隐藏性能面板");
  hide.textContent = "×";

  header.append(toggle, hide);
  shell.appendChild(header);

  const metrics = document.createElement("dl");
  metrics.id = `${PANEL_ID}-metrics`;
  metrics.className = "terrain-performance__metrics";
  metrics.dataset.role = "metrics";
  metrics.hidden = true;
  for (const definition of METRICS) {
    const term = document.createElement("dt");
    term.title = definition.title;
    term.textContent = definition.label;
    const value = document.createElement("dd");
    value.dataset.metric = definition.key;
    value.title = definition.title;
    value.textContent = "—";
    metrics.append(term, value);
  }
  shell.appendChild(metrics);

  const launcher = document.createElement("button");
  launcher.className = "terrain-performance__launcher";
  launcher.type = "button";
  launcher.dataset.action = "show";
  launcher.setAttribute("aria-label", "Show performance panel / 显示性能面板");
  launcher.innerHTML = '<span aria-hidden="true"></span> PERF / 性能';

  root.append(shell, launcher);
  return root;
}

function ensureStyles(): void {
  if (document.getElementById(STYLE_ID)) return;
  const style = document.createElement("style");
  style.id = STYLE_ID;
  style.textContent = `
    .terrain-performance {
      --perf-accent: #76e6ae;
      --perf-muted: #aeb7b5;
      position: fixed;
      left: 14px;
      bottom: 14px;
      z-index: 1000;
      width: min(350px, calc(100vw - 28px));
      color: #f1f5f4;
      font: 12px/1.15 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      letter-spacing: 0.01em;
    }

    .terrain-performance__shell {
      overflow: hidden;
      border: 1px solid rgba(195, 218, 210, 0.26);
      border-radius: 8px;
      background: rgba(13, 17, 16, 0.64);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2), inset 0 0 0 1px rgba(255, 255, 255, 0.025);
    }

    .terrain-performance__header {
      display: flex;
      align-items: center;
      min-height: 29px;
      border-bottom: 1px solid rgba(195, 218, 210, 0.14);
    }

    .terrain-performance__toggle,
    .terrain-performance__hide,
    .terrain-performance__launcher {
      border: 0;
      color: inherit;
      background: transparent;
      font: inherit;
      cursor: pointer;
    }

    .terrain-performance__toggle {
      display: flex;
      flex: 1;
      align-items: center;
      gap: 6px;
      min-width: 0;
      padding: 6px 9px;
      text-align: left;
      font-weight: 700;
    }

    .terrain-performance__toggle:hover,
    .terrain-performance__toggle:focus-visible {
      color: var(--perf-accent);
      background: rgba(118, 230, 174, 0.07);
      outline: none;
    }

    .terrain-performance__chevron {
      display: inline-block;
      color: var(--perf-accent);
      transition: transform 160ms ease;
    }

    .terrain-performance__hide {
      align-self: stretch;
      min-width: 30px;
      color: var(--perf-muted);
      font-size: 15px;
    }

    .terrain-performance__hide:hover,
    .terrain-performance__hide:focus-visible {
      color: #fff;
      background: rgba(255, 255, 255, 0.08);
      outline: none;
    }

    .terrain-performance__metrics {
      display: grid;
      grid-template-columns: minmax(138px, 1fr) auto;
      gap: 3px 10px;
      max-height: min(62vh, 450px);
      margin: 0;
      padding: 7px 10px 8px;
      overflow-y: auto;
      scrollbar-width: thin;
    }

    .terrain-performance__metrics[hidden] {
      display: none;
    }

    .terrain-performance__metrics dt,
    .terrain-performance__metrics dd {
      min-width: 0;
      margin: 0;
    }

    .terrain-performance__metrics dt {
      overflow: hidden;
      color: #e7ecea;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .terrain-performance__metrics dd {
      max-width: 170px;
      overflow: hidden;
      color: var(--perf-accent);
      text-align: right;
      text-overflow: ellipsis;
      white-space: nowrap;
      font-variant-numeric: tabular-nums;
    }

    .terrain-performance__metrics dd[data-level="warn"] {
      color: #ffd479;
    }

    .terrain-performance__metrics dd[data-level="bad"] {
      color: #ff8b8b;
    }

    .terrain-performance[data-state="collapsed"] .terrain-performance__header {
      border-bottom: 0;
    }

    .terrain-performance[data-state="collapsed"] .terrain-performance__chevron {
      transform: rotate(-90deg);
    }

    .terrain-performance[data-state="hidden"] {
      width: auto;
    }

    .terrain-performance[data-state="hidden"] .terrain-performance__shell {
      display: none;
    }

    .terrain-performance__launcher {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      min-height: 30px;
      padding: 6px 9px;
      border: 1px solid rgba(195, 218, 210, 0.26);
      border-radius: 7px;
      background: rgba(13, 17, 16, 0.64);
      box-shadow: 0 6px 18px rgba(0, 0, 0, 0.18);
    }

    .terrain-performance__launcher[hidden] {
      display: none;
    }

    .terrain-performance__launcher span {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--perf-accent);
      box-shadow: 0 0 10px rgba(118, 230, 174, 0.78);
    }

    .terrain-performance__launcher:hover,
    .terrain-performance__launcher:focus-visible {
      color: var(--perf-accent);
      transform: translateY(-1px);
      outline: none;
    }

    @media (max-width: 640px), (max-height: 620px) {
      .terrain-performance {
        left: 10px;
        bottom: 10px;
        width: min(310px, calc(100vw - 20px));
        font-size: 11px;
      }

      .terrain-performance__metrics {
        max-height: 46vh;
      }
    }
  `;
  document.head.appendChild(style);
}

function percentile95(values: readonly number[]): number {
  if (values.length === 0) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.min(sorted.length - 1, Math.ceil(sorted.length * 0.95) - 1)];
}

function formatMegabytes(bytes: number): string {
  return (bytes / BYTES_PER_MEGABYTE).toFixed(1);
}

function formatCompactCount(count: number): string {
  return new Intl.NumberFormat("en-US", {
    notation: "compact",
    maximumFractionDigits: 1
  }).format(count);
}

function fpsLevel(fps: number): "good" | "warn" | "bad" {
  if (fps >= 55) return "good";
  if (fps >= 30) return "warn";
  return "bad";
}
