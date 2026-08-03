/**
 * @title 10 Depth Test
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
Shader "WebGPU/DepthTest" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = true; WriteEnabled = true; CompareFunction = CompareFunction.Less; }
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
  const root = scene.createRootEntity("depth-test");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = new Float32Array([
    ...createQuad(-0.55, -0.18, 0.62, 0.92, 0.32, [1, 0.3, 0.18]),
    ...createQuad(-0.25, -0.82, 0.92, 0.48, 0.16, [0.68, 0.34, 1]),
    ...createQuad(-0.94, -0.62, 0.42, 0.72, 0, [0.12, 0.78, 1])
  ]);
  const mesh = new BufferMesh(engine, "overlapping-quads");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 24);
  mesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0),
    new VertexElement("COLOR_0", 12, VertexElementFormat.Vector3, 0)
  ]);
  mesh.addSubMesh(0, vertices.length / 6);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);

  const renderer = root.createChild("depth-layers").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(shaderSource)));

  engine.run();
  await waitForFrames();
  markExampleReady(`${backend} three depth-tested layers`);
});

function createQuad(
  left: number,
  bottom: number,
  right: number,
  top: number,
  depth: number,
  color: readonly [number, number, number]
): number[] {
  const vertex = (x: number, y: number): number[] => [x, y, depth, ...color];
  return [
    ...vertex(left, bottom),
    ...vertex(left, top),
    ...vertex(right, bottom),
    ...vertex(left, top),
    ...vertex(right, top),
    ...vertex(right, bottom)
  ];
}
