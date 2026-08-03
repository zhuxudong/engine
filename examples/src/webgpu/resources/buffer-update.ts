/**
 * @title 04 Buffer Update
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
Shader "WebGPU/BufferUpdate" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }

      struct Attributes { vec3 POSITION; };
      struct Varyings { vec3 color; };
      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.color = vec3(
          0.2 + attributes.POSITION.x * 0.25,
          0.65 + attributes.POSITION.y * 0.25,
          1.0
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
  const root = scene.createRootEntity("buffer-update");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const columnCount = 32;
  const collapsedVertices = new Float32Array(columnCount * 6 * 3);
  const visibleVertices = createBarVertices(columnCount);
  const vertexBuffer = new Buffer(engine, BufferBindFlag.VertexBuffer, collapsedVertices, BufferUsage.Dynamic);
  const mesh = new BufferMesh(engine, "dynamic-bars");
  mesh.setVertexBufferBinding(vertexBuffer, 12);
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0)]);
  mesh.addSubMesh(0, visibleVertices.length / 3);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);

  const renderer = root.createChild("bars").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  engine.run();
  await waitForFrames(1);
  vertexBuffer.setData(visibleVertices);
  await waitForFrames();
  markExampleReady(`${backend} Buffer.setData / ${columnCount} bars`);
});

function createBarVertices(columnCount: number): Float32Array {
  const vertices = new Float32Array(columnCount * 6 * 3);
  const bottom = -0.78;
  for (let column = 0; column < columnCount; column++) {
    const left = -0.94 + (column / columnCount) * 1.88;
    const right = -0.94 + ((column + 0.72) / columnCount) * 1.88;
    const phase = (column / (columnCount - 1)) * Math.PI * 3;
    const top = bottom + 0.28 + (Math.sin(phase) * 0.5 + 0.5) * 1.18;
    vertices.set(
      [left, bottom, 0, left, top, 0, right, bottom, 0, left, top, 0, right, top, 0, right, bottom, 0],
      column * 18
    );
  }
  return vertices;
}
