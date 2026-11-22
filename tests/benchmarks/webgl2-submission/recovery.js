import {
  Camera,
  EngineEventType,
  MeshRenderer,
  PrimitiveMesh,
  RenderTarget,
  Texture2D,
  TextureFormat,
  UnlitMaterial
} from "@galacean/engine-core";

/** Check a live mesh, shader and camera target across page suspension and an explicit device loss. */
export async function verifyRecovery(engine, waitForVisibility) {
  const root = engine.sceneManager.activeScene.createRootEntity();
  const camera = root.createChild().addComponent(Camera);
  camera.entity.transform.setPosition(0, 0, 3);
  const color = new Texture2D(engine, 16, 16, TextureFormat.R8G8B8A8_UNorm, false, false);
  camera.renderTarget = new RenderTarget(engine, 16, 16, color, TextureFormat.Depth24Stencil8);
  const renderer = root.createChild().addComponent(MeshRenderer);
  renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
  const material = new UnlitMaterial(engine);
  renderer.setMaterial(material);
  async function sample(red, green) {
    material.baseColor.set(red, green, 0, 1);
    camera.render();
    const pixels = new Uint8Array(16 * 16 * 4);
    await color.getPixelBufferAsync(pixels);
    const center = Array.from(pixels.subarray(544, 548));
    if (center.join() !== [red * 255, green * 255, 0, 255].join())
      throw new Error("Unexpected restored framebuffer pixel " + center);
    return center;
  }
  let losses = 0,
    restorations = 0;
  engine.on(EngineEventType.DeviceLost, () => ++losses);
  engine.on(EngineEventType.DeviceRestored, () => ++restorations);
  const before = await sample(1, 0);
  const visibility = [document.visibilityState];
  if (waitForVisibility) {
    document.querySelector("#result").dataset.recovery = "awaiting-background";
    await new Promise((resolve) => {
      function onChange() {
        visibility.push(document.visibilityState);
        if (!document.hidden && visibility.includes("hidden")) {
          document.removeEventListener("visibilitychange", onChange);
          resolve();
        }
      }
      document.addEventListener("visibilitychange", onChange);
    });
    if (losses > restorations) {
      const restored = new Promise((resolve) => engine.once(EngineEventType.DeviceRestored, resolve));
      engine.forceRestoreDevice();
      await restored;
    }
    await sample(1, 0);
  }
  const lossesWhileHidden = losses;
  const lost = new Promise((resolve) => engine.once(EngineEventType.DeviceLost, resolve));
  const restored = new Promise((resolve) => engine.once(EngineEventType.DeviceRestored, resolve));
  engine.forceLoseDevice();
  await lost;
  // Restoring WebGL in its context-lost event handler can precede the browser's restoration point.
  await new Promise(requestAnimationFrame);
  engine.forceRestoreDevice();
  await restored;
  const after = await sample(0, 1);
  return { before, after, visibility, lossesWhileHidden, losses, restorations };
}
