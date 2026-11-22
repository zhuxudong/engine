import {
  AmbientOcclusionQuality,
  AssetType,
  Camera,
  DirectLight,
  MeshRenderer,
  MSAASamples,
  PrimitiveMesh,
  ShadowCascadesMode,
  ShadowResolution,
  ShadowType,
  UnlitMaterial
} from "@galacean/engine-core";
import { Vector3 } from "@galacean/engine-math";
import { inspectWebGPUFrame, captureRGBA, trackBundleEncoding } from "./webgpu";
import { prepareScene } from "./scenes";

function submissionScene(engine, root, camera) {
  camera.entity.transform.setPosition(0, 0, 10);
  camera.isOrthographic = true;
  camera.orthographicSize = 1;
  const shareGeometry = new URLSearchParams(location.search).has("sharedMesh");
  const createMesh = () => PrimitiveMesh.createCuboid(engine, 0.022, 0.022, 0.02);
  const sharedMesh = shareGeometry ? createMesh() : undefined;
  const materials = Array.from({ length: 8 }, (_, i) => {
    const material = new UnlitMaterial(engine);
    material.baseColor.set(i / 8, 0.5, 1 - i / 8, 1);
    return material;
  });
  const meshCount = 2048;
  for (let i = 0; i < meshCount; ++i) {
    const entity = root.createChild();
    entity.transform.setPosition(((i % 64) - 31.5) / 33, (Math.floor(i / 64) - 15.5) / 17, 0);
    const renderer = entity.addComponent(MeshRenderer);
    renderer.mesh = sharedMesh ?? createMesh();
    renderer.setMaterial(materials[i % materials.length]);
    renderer.priority = i;
  }
  return { details: { meshCount, uniqueMeshCount: shareGeometry ? 1 : meshCount } };
}

async function sponzaScene(engine, root, camera) {
  // The real Sponza asset used by this repository's glTF loader example.
  const url = "https://gw.alipayobjects.com/os/bmw-prod/ca50859b-d736-4a3e-9fc3-241b0bd2afef.gltf";
  const resource = await engine.resourceManager.load({ type: AssetType.GLTF, url });
  root.addChild(resource.instantiateSceneRoot());
  const light = root.createChild().addComponent(DirectLight);
  light.entity.transform.setRotation(-55, -30, 0);
  const scene = engine.sceneManager.activeScene;
  scene.ambientLight.diffuseSolidColor.set(0.6, 0.6, 0.6, 1);
  const effects = new URLSearchParams(location.search).get("effects");
  if (effects) {
    if (!["all", "no-sao", "no-shadows", "no-msaa"].includes(effects))
      throw new Error("Unknown S5 effects: " + effects);
    camera.enableHDR = true;
    camera.enablePostProcess = true;
    camera.msaaSamples = effects === "no-msaa" ? MSAASamples.None : MSAASamples.FourX;
    scene.ambientOcclusion.enabled = effects !== "no-sao";
    scene.ambientOcclusion.quality = AmbientOcclusionQuality.High;
    scene.shadowDistance = 32;
    scene.shadowResolution = ShadowResolution.Medium;
    scene.shadowCascades = ShadowCascadesMode.FourCascades;
    scene.shadowFourCascadeSplits.set(0.2, 0.44, 0.68);
    light.shadowType = effects === "no-shadows" ? ShadowType.None : ShadowType.SoftHigh;
  }
  const target = new Vector3();
  const move = (frame) => {
    // Fixed, closed walk along the central nave. The glTF root carries its own 0.008 scale.
    const angle = (2 * Math.PI * frame) / 300;
    const x = Math.cos(angle) * 8;
    const z = Math.sin(angle) * 1.5;
    camera.entity.transform.setPosition(x, 1.6, z);
    target.set(x - Math.sin(angle) * 8, 1.8, z + Math.cos(angle) * 1.5);
    camera.entity.transform.lookAt(target);
  };
  move(0);
  return {
    beforeFrame: move,
    details: { asset: url, primitives: 103, triangles: 262267, effects: effects ?? undefined }
  };
}

function countCalls(gl, render) {
  const counts = {};
  const hooks = new Set([
    "drawElements",
    "drawElementsInstanced",
    "drawArrays",
    "drawArraysInstanced",
    "beginTransformFeedback",
    "bufferSubData",
    "bindBufferRange",
    ...[WebGLRenderingContext, WebGL2RenderingContext].flatMap(({ prototype }) =>
      Object.getOwnPropertyNames(prototype).filter((name) => /^uniform[1-4M]/.test(name))
    )
  ]);
  for (const name of hooks) {
    const native = gl[name];
    counts[name] = 0;
    gl[name] = function (...args) {
      counts[name]++;
      return native.apply(this, args);
    };
  }
  try {
    render();
  } finally {
    for (const name of hooks) delete gl[name];
  }
  return Object.fromEntries(Object.entries(counts).filter(([, value]) => value > 0));
}

function stats(times) {
  const sorted = times.slice().sort((a, b) => a - b);
  const percentile = (fraction) => sorted[Math.ceil(sorted.length * fraction) - 1];
  return { median: percentile(0.5), p90: percentile(0.9), p99: percentile(0.99), max: sorted[sorted.length - 1] };
}

function framebufferHash(gl) {
  const previous = gl.getParameter(gl.READ_FRAMEBUFFER_BINDING);
  const pixels = new Uint8Array(gl.drawingBufferWidth * gl.drawingBufferHeight * 4);
  try {
    gl.bindFramebuffer(gl.READ_FRAMEBUFFER, null);
    gl.readPixels(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
  } finally {
    gl.bindFramebuffer(gl.READ_FRAMEBUFFER, previous);
  }
  captureRGBA(pixels, gl.drawingBufferWidth, gl.drawingBufferHeight, 4 * gl.drawingBufferWidth, true);
  let hash = 0x811c9dc5;
  for (const byte of pixels) hash = Math.imul(hash ^ byte, 0x01000193);
  return (hash >>> 0).toString(16).padStart(8, "0");
}

const frame = () => new Promise(requestAnimationFrame);
async function measure() {
  const scenario = new URLSearchParams(location.search).get("scene") ?? "S1";
  const canvas = document.querySelector("canvas");
  const width = scenario === "S1" ? 256 : 640;
  const height = scenario === "S1" ? 256 : 360;
  const options = new URLSearchParams(location.search);
  const gpu = options.get("backend") === "webgpu";
  const timing = options.has("timing");
  const loadStart = performance.now();
  const Engine = gpu
    ? (await import("@galacean/engine-webgpu")).WebGPUEngine
    : (await import("@galacean/engine")).WebGLEngine;
  const start = performance.now();
  const engine = await Engine.create({
    canvas,
    graphicDeviceOptions: gpu ? { enableGPUTiming: timing } : { antialias: false }
  });
  const initializationMs = performance.now() - start;
  if (scenario === "Recovery") {
    try {
      const { verifyRecovery } = await import("./recovery");
      return {
        scene: scenario,
        backend: gpu ? "webgpu" : "webgl2",
        ...(await verifyRecovery(engine, options.has("background")))
      };
    } finally {
      engine.destroy();
    }
  }
  const device = gpu && engine._hardwareRenderer.device;
  if (device) device.pushErrorScope("validation");
  try {
    engine.canvas.setResolution(width, height);
    const root = engine.sceneManager.activeScene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    const setup =
      scenario === "S1"
        ? submissionScene(engine, root, camera)
        : scenario === "S5"
          ? await sponzaScene(engine, root, camera)
          : await prepareScene(scenario, engine, root, camera);
    const stopTracking = gpu && trackBundleEncoding();
    let firstDrawMs, timeToFirstFrameMs;
    for (let i = 0; i < 30; ++i) {
      await frame();
      const drawStart = performance.now();
      engine.update();
      if (i === 0) {
        firstDrawMs = performance.now() - drawStart;
        timeToFirstFrameMs = performance.now() - loadStart;
      }
    }
    if (stopTracking) stopTracking();
    let preparationMs;
    if (setup.preparePipelines && options.has("prewarm")) {
      const before = performance.now();
      await setup.preparePipelines();
      preparationMs = performance.now() - before;
    }
    // Keep timing free of driver instrumentation, GL queries and GPU synchronization.
    const cpu = [],
      intervals = [];
    const drawSubmission = [];
    let drawStart;
    const measureSubmission = scenario === "S1" && options.has("submissionPhases");
    if (measureSubmission) {
      const pipeline = camera._renderPipeline;
      const draw = pipeline._drawRenderPass;
      pipeline._drawRenderPass = function (...args) {
        drawStart = performance.now();
        return draw.apply(this, args);
      };
    }
    const gpuTimes = [];
    let lastSubmission = 0;
    const gl = !gpu && canvas.getContext("webgl2");
    const extension = timing && gl && gl.getExtension("EXT_disjoint_timer_query_webgl2");
    const pendingQueries = [];
    const statistics = engine.renderingStatistics;
    let resourceBytesPeak = statistics.totalMemory;
    let previous = await frame();
    for (let i = 0; i < 300; ++i) {
      const time = await frame();
      intervals.push(time - previous);
      previous = time;
      let query;
      if (timing && gpu) engine._hardwareRenderer.gpuTiming.requestSample();
      if (extension) {
        while (pendingQueries.length && gl.getQueryParameter(pendingQueries[0], gl.QUERY_RESULT_AVAILABLE)) {
          const ready = pendingQueries.shift();
          if (!gl.getParameter(extension.GPU_DISJOINT_EXT))
            gpuTimes.push(gl.getQueryParameter(ready, gl.QUERY_RESULT) / 1e6);
          gl.deleteQuery(ready);
        }
        if (pendingQueries.length < 4) {
          query = gl.createQuery();
          gl.beginQuery(extension.TIME_ELAPSED_EXT, query);
        }
      }
      const start = performance.now();
      drawStart = undefined;
      setup.beforeFrame?.(i);
      engine.update();
      const end = performance.now();
      cpu.push(end - start);
      if (measureSubmission) {
        if (drawStart === undefined) throw new Error("The S1 camera skipped its draw pass.");
        drawSubmission.push(end - drawStart);
      }
      if (query) {
        gl.endQuery(extension.TIME_ELAPSED_EXT);
        pendingQueries.push(query);
      }
      if (timing && gpu) {
        const sample = engine._hardwareRenderer.gpuTiming.latestSample;
        if (sample && sample.submissionId !== lastSubmission) {
          gpuTimes.push(sample.durationMs);
          lastSubmission = sample.submissionId;
        }
      }
      resourceBytesPeak = Math.max(resourceBytesPeak, statistics.totalMemory);
    }
    for (const query of pendingQueries) gl.deleteQuery(query);
    if (canvas.width !== width || canvas.height !== height) throw new Error("Unexpected benchmark resolution");
    await frame();
    const render = () => {
      setup.beforeFrame?.(300);
      engine.update();
    };
    let rgbaHash, counts, renderer, evidence;
    if (device) {
      const result = await inspectWebGPUFrame(canvas, device, render);
      counts = result.counts;
      rgbaHash = result.hash;
      renderer = device.adapterInfo?.description;
      if (
        scenario === "S1" &&
        ((counts.drawIndexed ?? 0) + (counts.bundleDrawIndexed ?? 0) !== 2048 || counts.unknownBundles)
      )
        throw new Error("Unexpected WebGPU draw count " + JSON.stringify(counts));
      evidence = await setup.validate?.();
      const error = await device.popErrorScope();
      if (error) throw new Error(error.message);
    } else {
      const gl = canvas.getContext("webgl2");
      counts = countCalls(gl, render);
      const draws =
        (counts.drawElements || 0) +
        (counts.drawElementsInstanced || 0) +
        (counts.drawArrays || 0) +
        (counts.drawArraysInstanced || 0);
      if (!draws || (scenario === "S1" && (counts.drawElements !== 2048 || counts.drawElementsInstanced))) {
        throw new Error("Unexpected draw count " + JSON.stringify(counts));
      }
      rgbaHash = framebufferHash(gl);
      evidence = await setup.validate?.(gl);
      const debug = gl.getExtension("WEBGL_debug_renderer_info");
      renderer = debug && gl.getParameter(debug.UNMASKED_RENDERER_WEBGL);
      const driverError = gl.getError();
      if (driverError) throw new Error("WebGL error " + driverError);
    }
    return {
      scene: scenario,
      backend: gpu ? "webgpu" : "webgl2",
      initializationMs,
      moduleLoadMs: start - loadStart,
      engineResourceBytes: { peak: resourceBytesPeak, final: statistics.totalMemory },
      ...(timing && {
        gpuTimer: {
          scope: gpu ? "submission" : "frame",
          sampleCount: gpuTimes.length,
          milliseconds: gpuTimes.length ? stats(gpuTimes) : null
        }
      }),
      firstDrawMs,
      timeToFirstFrameMs,
      preparationMs,
      ...setup.details,
      ...evidence,
      frames: cpu.length,
      width,
      height,
      renderer,
      userAgent: navigator.userAgent,
      firstMeasuredFrameMs: cpu[0],
      rgbaHash,
      submissionMs: stats(cpu),
      ...(measureSubmission && { cameraDrawThroughSubmitMs: stats(drawSubmission) }),
      frameIntervalMs: stats(intervals),
      callsPerFrame: counts
    };
  } finally {
    engine.destroy();
  }
}

const result = document.querySelector("#result");
measure()
  .then((metrics) => {
    result.textContent = JSON.stringify(metrics, null, 2);
    result.dataset.status = "complete";
  })
  .catch((error) => {
    result.textContent = String(error.stack || error);
    result.dataset.status = "error";
  });
