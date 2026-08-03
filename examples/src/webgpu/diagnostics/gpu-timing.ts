/**
 * @title 15 GPU Timing
 * @category WebGPU
 * @backend webgpu
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Material,
  MeshRenderer,
  Shader,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const shaderSource = `
Shader "WebGPU/GPUTiming" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec2 POSITION; };
      struct Varyings { vec3 color; };
      Varyings vert(Attributes attributes) {
        Varyings output;
        float instance = float(gl_InstanceID);
        float x = fract(instance * 0.754877666) * 1.8 - 0.9;
        float y = fract(instance * 0.569840296) * 1.65 - 0.825;
        gl_Position = vec4(vec2(x, y) + attributes.POSITION * 0.018, 0.0, 1.0);
        output.color = vec3(
          0.55 + 0.45 * fract(instance * 0.1031),
          0.25 + 0.55 * fract(instance * 0.13787),
          1.0
        );
        return output;
      }

      vec4 frag(Varyings varyings) { return vec4(varyings.color, 1.0); }
      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

runExample(async () => {
  const { engine, backend } = await createExampleEngine({ defaultBackend: "webgpu", enableGPUTiming: true });
  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("gpu-timing");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = new Float32Array([0, 0.5, -0.5, -0.5, 0.5, -0.5]);
  const mesh = new BufferMesh(engine, "timed-instances");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 8);
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector2, 0)]);
  mesh.addSubMesh(0, 3);
  mesh.instanceCount = 2048;
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);
  const renderer = root.createChild("instances").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  engine.run();
  if (backend !== "webgpu" || !engine.gpuTiming.supported) {
    await waitForFrames();
    markExampleReady(`${backend} timestamp-query unsupported`);
    return;
  }

  engine.gpuTiming.requestSample();
  for (let attempt = 0; attempt < 30 && !engine.gpuTiming.latestSample; attempt++) {
    await waitForFrames(1);
  }
  const sample = engine.gpuTiming.latestSample;
  if (!sample) {
    throw new Error("GPU timing sample did not resolve.");
  }
  markExampleReady(`webgpu ${mesh.instanceCount} instances / ${sample.durationMs.toFixed(3)} ms`);
});
