/**
 * @title 03 Index Buffer
 * @category WebGPU
 * @backend webgpu
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  IndexFormat,
  Material,
  MeshRenderer,
  Shader,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const shaderSource = `
Shader "WebGPU/IndexBuffer" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec3 POSITION; vec3 COLOR_0; };
      struct Varyings { vec3 color; };
      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.color = attributes.COLOR_0;
        return output;
      }

      vec4 frag(Varyings varyings) { return vec4(varyings.color, 1.0); }
      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

runExample(async () => {
  const { engine, backend } = await createExampleEngine();
  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("index-buffer");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = new Float32Array([
    -0.88, 0.72, 0, 1, 0.28, 0.18, -0.88, -0.72, 0, 0.12, 0.85, 1, 0.88, -0.72, 0, 0.72, 0.3, 1, 0.88, 0.72, 0, 1, 0.82,
    0.18
  ]);
  const indices = new Uint16Array([0, 1, 2, 0, 2, 3]);
  const mesh = new BufferMesh(engine, "indexed-quad");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 24);
  mesh.setIndexBufferBinding(
    new Buffer(engine, BufferBindFlag.IndexBuffer, indices, BufferUsage.Static),
    IndexFormat.UInt16
  );
  mesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0),
    new VertexElement("COLOR_0", 12, VertexElementFormat.Vector3, 0)
  ]);
  mesh.addSubMesh(0, indices.length);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);

  const renderer = root.createChild("quad").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  engine.run();
  await waitForFrames();
  markExampleReady(`${backend} indexed draw / ${indices.length} indices`);
});
