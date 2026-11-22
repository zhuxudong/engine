import {
  AssetType,
  Camera,
  DirectLight,
  MeshRenderer,
  PrimitiveMesh,
  UnlitMaterial,
  Vector3,
  WebGLEngine
} from "@galacean/engine";
import { prepareScene } from "./scenes";

function submissionScene(engine, root, camera) {
  camera.entity.transform.setPosition(0, 0, 10);
  camera.isOrthographic = true;
  camera.orthographicSize = 1;
  const mesh = PrimitiveMesh.createCuboid(engine, 0.022, 0.022, 0.02);
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
    renderer.mesh = mesh;
    renderer.setMaterial(materials[i % materials.length]);
    renderer.priority = i;
  }
  return { details: { meshCount } };
}

async function sponzaScene(engine, root, camera) {
  // The real Sponza asset used by this repository's glTF loader example.
  const url = "https://gw.alipayobjects.com/os/bmw-prod/ca50859b-d736-4a3e-9fc3-241b0bd2afef.gltf";
  const resource = await engine.resourceManager.load({ type: AssetType.GLTF, url });
  root.addChild(resource.instantiateSceneRoot());
  const light = root.createChild().addComponent(DirectLight);
  light.entity.transform.setRotation(-55, -30, 0);
  engine.sceneManager.activeScene.ambientLight.diffuseSolidColor.set(0.6, 0.6, 0.6, 1);
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
  return { beforeFrame: move, details: { asset: url, primitives: 103, triangles: 262267 } };
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
  let hash = 0x811c9dc5;
  for (const byte of pixels) hash = Math.imul(hash ^ byte, 0x01000193);
  return (hash >>> 0).toString(16).padStart(8, "0");
}

const frame = () => new Promise(requestAnimationFrame);
async function measure() {
  const scenario = new URLSearchParams(location.search).get("scene") ?? "S1";
  const canvas = document.querySelector("canvas");
  if (scenario !== "S1") {
    canvas.width = 640;
    canvas.height = 360;
  }
  const engine = await WebGLEngine.create({ canvas, graphicDeviceOptions: { antialias: false } });
  try {
    const root = engine.sceneManager.activeScene.createRootEntity();
    const camera = root.createChild().addComponent(Camera);
    const setup =
      scenario === "S1"
        ? submissionScene(engine, root, camera)
        : scenario === "S5"
          ? await sponzaScene(engine, root, camera)
          : await prepareScene(scenario, engine, root, camera);
    for (let i = 0; i < 30; ++i) {
      await frame();
      engine.update();
    }
    // Keep timing free of driver instrumentation, GL queries and GPU synchronization.
    const cpu = [],
      intervals = [];
    let previous = await frame();
    for (let i = 0; i < 300; ++i) {
      const time = await frame();
      intervals.push(time - previous);
      previous = time;
      const start = performance.now();
      setup.beforeFrame?.(i);
      engine.update();
      cpu.push(performance.now() - start);
    }
    const gl = canvas.getContext("webgl2");
    await frame();
    const counts = countCalls(gl, () => {
      setup.beforeFrame?.(300);
      engine.update();
    });
    const draws =
      (counts.drawElements || 0) +
      (counts.drawElementsInstanced || 0) +
      (counts.drawArrays || 0) +
      (counts.drawArraysInstanced || 0);
    if (!draws || (scenario === "S1" && (counts.drawElements !== 2048 || counts.drawElementsInstanced))) {
      throw new Error("Unexpected draw count " + JSON.stringify(counts));
    }
    const rgbaHash = framebufferHash(gl);
    const evidence = await setup.validate?.(gl);
    const debug = gl.getExtension("WEBGL_debug_renderer_info");
    const driverError = gl.getError();
    if (driverError) throw new Error("WebGL error " + driverError);
    return {
      scene: scenario,
      ...setup.details,
      ...evidence,
      frames: cpu.length,
      width: gl.drawingBufferWidth,
      height: gl.drawingBufferHeight,
      renderer: debug && gl.getParameter(debug.UNMASKED_RENDERER_WEBGL),
      userAgent: navigator.userAgent,
      firstMeasuredFrameMs: cpu[0],
      rgbaHash,
      submissionMs: stats(cpu),
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
