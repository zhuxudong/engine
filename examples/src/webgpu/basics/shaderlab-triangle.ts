/**
 * @title 02 ShaderLab Triangle
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
Shader "WebGPU/ShaderLabTriangle" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }

      struct Attributes {
        vec3 POSITION;
        vec3 COLOR_0;
      };

      struct Varyings {
        vec3 color;
      };

      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.color = attributes.COLOR_0;
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
  const root = scene.createRootEntity("shaderlab-triangle");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = new Float32Array([
    0, 0.9, 0, 1, 0.25, 0.2, -0.9, -0.72, 0, 0.2, 0.8, 1, 0.9, -0.72, 0, 0.75, 0.3, 1
  ]);
  const mesh = new BufferMesh(engine, "shaderlab-triangle");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 24);
  mesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0),
    new VertexElement("COLOR_0", 12, VertexElementFormat.Vector3, 0)
  ]);
  mesh.addSubMesh(0, 3);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);

  const renderer = root.createChild("triangle").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  engine.run();
  await waitForFrames();
  markExampleReady(`${backend} ShaderLab codegen`);
});
