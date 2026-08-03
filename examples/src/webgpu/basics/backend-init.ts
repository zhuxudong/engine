/**
 * @title 01 Backend Initialization
 * @category WebGPU
 * @backend webgpu
 */
import { Camera, MeshRenderer, PrimitiveMesh, RenderFace, UnlitMaterial, Vector3 } from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

runExample(async () => {
  const { engine, backend } = await createExampleEngine();
  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("backend-init");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const renderer = root.createChild("cube").addComponent(MeshRenderer);
  renderer.entity.transform.setRotation(28, 38, 0);
  renderer.mesh = PrimitiveMesh.createCuboid(engine, 1.2, 1.2, 1.2);
  const material = new UnlitMaterial(engine);
  material.baseColor.set(0.15, 0.55, 1, 1);
  material.renderFace = RenderFace.Double;
  renderer.setMaterial(material);

  engine.run();
  await waitForFrames();
  markExampleReady(`${backend} engine + swapchain ready`);
});
