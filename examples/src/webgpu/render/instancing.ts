/**
 * @title 08 Instanced Draw
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
Shader "WebGPU/InstancedDraw" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }

      struct Attributes { vec3 POSITION; };
      struct Varyings { vec3 color; };
      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        float instance = float(gl_InstanceID);
        vec2 offset = vec2(
          fract(instance * 0.754877666) * 2.0 - 1.0,
          fract(instance * 0.569840296) * 1.35 - 0.675
        );
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION + vec3(offset, 0.0), 1.0);
        output.color = vec3(
          0.25 + 0.75 * fract(instance * 0.1031),
          0.2 + 0.8 * fract(instance * 0.11369),
          0.35 + 0.65 * fract(instance * 0.13787)
        );
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

runExample(async () => {
  const { engine, backend } = await createExampleEngine();
  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("instanced-draw");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = new Float32Array([0, 0.045, 0, -0.038, -0.03, 0, 0.038, -0.03, 0]);
  const mesh = new BufferMesh(engine, "instanced-triangle");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 12);
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0)]);
  mesh.addSubMesh(0, 3);
  mesh.instanceCount = 384;
  mesh.bounds.min.set(-2, -2, -1);
  mesh.bounds.max.set(2, 2, 1);

  const renderer = root.createChild("instances").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  engine.run();
  await waitForFrames();
  markExampleReady(`${backend} one draw / ${mesh.instanceCount} instances`);
});
