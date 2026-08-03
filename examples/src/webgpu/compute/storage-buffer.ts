/**
 * @title 13 Compute Storage Buffer
 * @category WebGPU
 * @backend webgpu
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  ComputePass,
  Material,
  MeshRenderer,
  Shader,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const computeShaderSource = `
Shader "WebGPU/ComputeStorageBuffer" {
  SubShader "Default" {
    Pass "GenerateGrid" {
      buffer vec4 outputPositions[];

      void generateGrid() {
        uint index = gl_GlobalInvocationID.x;
        if (index < 384u) {
          uint tile = index / 6u;
          uint corner = index - tile * 6u;
          uint column = tile % 8u;
          uint row = tile / 8u;
          vec2 local = vec2(-1.0, -1.0);
          if (corner == 1u || corner == 3u || corner == 4u) {
            local.y = 1.0;
          }
          if (corner == 2u || corner == 4u || corner == 5u) {
            local.x = 1.0;
          }
          float wave = 0.5 + 0.5 * sin(float(tile) * 0.73);
          float scale = 0.07 + wave * 0.035;
          vec2 center = vec2(-0.84 + float(column) * 0.24, -0.84 + float(row) * 0.24);
          outputPositions[index] = vec4(center + local * scale, 0.0, 1.0);
        }
      }

      ComputeShader = generateGrid;
    }
  }
}`;

const renderShaderSource = `
Shader "WebGPU/ComputeStorageDisplay" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec4 POSITION; };
      struct Varyings { vec3 color; };
      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * attributes.POSITION;
        output.color = vec3(
          0.3 + attributes.POSITION.x * 0.22,
          0.82 + attributes.POSITION.y * 0.16,
          0.62 + attributes.POSITION.x * 0.18
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
  const { engine, backend } = await createExampleEngine({ defaultBackend: "webgpu" });
  if (backend !== "webgpu") {
    throw new Error("ComputePass is not supported by the WebGL2 backend.");
  }

  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.025, 0.035, 0.055, 1);
  const root = scene.createRootEntity("compute-storage-buffer");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertexCount = 384;
  const positions = new Buffer(
    engine,
    BufferBindFlag.StorageBuffer | BufferBindFlag.VertexBuffer,
    vertexCount * 4 * Float32Array.BYTES_PER_ELEMENT,
    BufferUsage.Dynamic
  );
  const computePass = new ComputePass(engine, Shader.create(computeShaderSource));
  computePass.setBuffer("outputPositions", positions);
  computePass.dispatch(6);

  const mesh = new BufferMesh(engine, "compute-grid");
  mesh.setVertexBufferBinding(positions, 16);
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector4, 0)]);
  mesh.addSubMesh(0, vertexCount);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);
  const renderer = root.createChild("generated-grid").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(renderShaderSource)));

  engine.run();
  await waitForFrames(5);
  markExampleReady("webgpu compute -> 64 storage-buffer tiles");
});
