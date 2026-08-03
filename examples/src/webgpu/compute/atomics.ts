/**
 * @title 14 Compute Atomics
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

const reduceShaderSource = `
Shader "WebGPU/ComputeAtomicMax" {
  SubShader "Default" {
    Pass "Reduce" {
      buffer uint maximumValues[];

      void reduceMaximum() {
        atomicMax(maximumValues[0u], gl_LocalInvocationID.x * 3u + 7u);
      }

      ComputeShader = reduceMaximum;
    }
  }
}`;

const geometryShaderSource = `
Shader "WebGPU/ComputeAtomicGeometry" {
  SubShader "Default" {
    Pass "Generate" {
      readonly buffer uint maximumValues[];
      buffer vec4 outputPositions[];

      void generateBars() {
        uint index = gl_GlobalInvocationID.x;
        float expectedMaximum = float((GALACEAN_COMPUTE_WORKGROUP_SIZE_X - 1) * 3 + 7);
        if (index < 48u) {
          uint bar = index / 6u;
          uint corner = index - bar * 6u;
          float ratio = float(maximumValues[0u]) / expectedMaximum;
          float left = -0.9 + float(bar) * 0.23;
          float right = left + 0.16;
          float bottom = -0.78;
          float top = bottom + ratio * (0.3 + float(bar) * 0.16);
          float x = left;
          float y = bottom;
          if (corner == 1u || corner == 3u || corner == 4u) {
            y = top;
          }
          if (corner == 2u || corner == 4u || corner == 5u) {
            x = right;
          }
          outputPositions[index] = vec4(x, y, 0.0, 1.0);
        }
      }

      ComputeShader = generateBars;
    }
  }
}`;

const renderShaderSource = `
Shader "WebGPU/ComputeAtomicDisplay" {
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
          1.0,
          0.48 + attributes.POSITION.y * 0.24,
          0.12 + attributes.POSITION.x * 0.12
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
  const root = scene.createRootEntity("compute-atomics");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const maximum = new Buffer(engine, BufferBindFlag.StorageBuffer, new Uint32Array([0]), BufferUsage.Dynamic);
  const vertexCount = 48;
  const positions = new Buffer(
    engine,
    BufferBindFlag.StorageBuffer | BufferBindFlag.VertexBuffer,
    vertexCount * 4 * Float32Array.BYTES_PER_ELEMENT,
    BufferUsage.Dynamic
  );
  const reducePass = new ComputePass(engine, Shader.create(reduceShaderSource));
  reducePass.setBuffer("maximumValues", maximum);
  reducePass.dispatch(1);
  const geometryPass = new ComputePass(engine, Shader.create(geometryShaderSource));
  geometryPass.setBuffer("maximumValues", maximum);
  geometryPass.setBuffer("outputPositions", positions);
  geometryPass.dispatch(1);

  const mesh = new BufferMesh(engine, "atomic-bars");
  mesh.setVertexBufferBinding(positions, 16);
  mesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector4, 0)]);
  mesh.addSubMesh(0, vertexCount);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);
  const renderer = root.createChild("bars").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(renderShaderSource)));

  engine.run();
  await waitForFrames(5);
  markExampleReady("webgpu atomicMax -> 8 generated bars");
});
