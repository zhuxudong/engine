/**
 * @title 05 Uniform Update
 * @category WebGPU
 * @backend webgpu
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Color,
  Material,
  MeshRenderer,
  Shader,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const shaderSource = `
Shader "WebGPU/UniformUpdate" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec3 POSITION; };
      struct Varyings { vec4 color; };
      mat4 renderer_MVPMat;
      vec4 material_Color;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.color = material_Color;
        return output;
      }

      vec4 frag(Varyings varyings) { return varyings.color; }
      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

runExample(async () => {
  const { engine, backend } = await createExampleEngine();
  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("uniform-update");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = createDiscVertices(48, 0.82);
  const mesh = new BufferMesh(engine, "uniform-disc");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 12);
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0)]);
  mesh.addSubMesh(0, vertices.length / 3);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);

  const material = new Material(engine, Shader.create(shaderSource));
  material.shaderData.setColor("material_Color", new Color(0.08, 0.08, 0.08, 1));
  const renderer = root.createChild("disc").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(material);

  engine.run();
  await waitForFrames(1);
  material.shaderData.setColor("material_Color", new Color(1, 0.48, 0.12, 1));
  await waitForFrames();
  markExampleReady(`${backend} material uniform update`);
});

function createDiscVertices(segmentCount: number, radius: number): Float32Array {
  const vertices = new Float32Array(segmentCount * 9);
  for (let segment = 0; segment < segmentCount; segment++) {
    const start = (segment / segmentCount) * Math.PI * 2;
    const end = ((segment + 1) / segmentCount) * Math.PI * 2;
    vertices.set(
      [
        0,
        0,
        0,
        Math.cos(start) * radius,
        Math.sin(start) * radius,
        0,
        Math.cos(end) * radius,
        Math.sin(end) * radius,
        0
      ],
      segment * 9
    );
  }
  return vertices;
}
