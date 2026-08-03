/**
 * @title 12 Compute Sampled Texture
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
  Texture2D,
  TextureFormat,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const computeShaderSource = `
Shader "WebGPU/ComputeSampledTexture" {
  SubShader "Default" {
    Pass "GenerateTextureGrid" {
      sampler2D inputTexture;
      buffer vec4 outputPositions[];
      buffer vec4 outputColors[];

      void generateTextureGrid() {
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
          vec2 center = vec2(-0.84 + float(column) * 0.24, -0.84 + float(row) * 0.24);
          outputPositions[index] = vec4(center + local * 0.105, 0.0, 1.0);
          outputColors[index] = texelFetch(inputTexture, ivec2(int(column), int(row)), 0);
        }
      }

      ComputeShader = generateTextureGrid;
    }
  }
}`;

const renderShaderSource = `
Shader "WebGPU/ComputeSampledTextureDisplay" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec4 POSITION; vec4 COLOR_0; };
      struct Varyings { vec4 color; };
      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * attributes.POSITION;
        output.color = attributes.COLOR_0;
        return output;
      }

      vec4 frag(Varyings varyings) { return varyings.color; }
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
  const root = scene.createRootEntity("compute-sampled-texture");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const texture = new Texture2D(engine, 8, 8, TextureFormat.R8G8B8A8, false, false);
  const pixels = new Uint8Array(8 * 8 * 4);
  for (let row = 0; row < 8; row++) {
    for (let column = 0; column < 8; column++) {
      const offset = (row * 8 + column) * 4;
      pixels[offset] = 45 + column * 27;
      pixels[offset + 1] = 55 + row * 25;
      pixels[offset + 2] = 240 - ((column + row) % 8) * 17;
      pixels[offset + 3] = 255;
    }
  }
  texture.setPixelBuffer(pixels);
  const vertexCount = 384;
  const positions = new Buffer(
    engine,
    BufferBindFlag.StorageBuffer | BufferBindFlag.VertexBuffer,
    vertexCount * 4 * Float32Array.BYTES_PER_ELEMENT,
    BufferUsage.Dynamic
  );
  const colors = new Buffer(
    engine,
    BufferBindFlag.StorageBuffer | BufferBindFlag.VertexBuffer,
    vertexCount * 4 * Float32Array.BYTES_PER_ELEMENT,
    BufferUsage.Dynamic
  );
  const computePass = new ComputePass(engine, Shader.create(computeShaderSource));
  computePass.setTexture("inputTexture", texture);
  computePass.setBuffer("outputPositions", positions);
  computePass.setBuffer("outputColors", colors);
  computePass.dispatch(6);

  const mesh = new BufferMesh(engine, "compute-texture-grid");
  mesh.setVertexBufferBinding(positions, 16, 0);
  mesh.setVertexBufferBinding(colors, 16, 1);
  mesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector4, 0),
    new VertexElement("COLOR_0", 0, VertexElementFormat.Vector4, 1)
  ]);
  mesh.addSubMesh(0, vertexCount);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);
  const renderer = root.createChild("texture-grid").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(new Material(engine, Shader.create(renderShaderSource)));

  engine.run();
  await waitForFrames(5);
  markExampleReady("webgpu sampled texture -> 8x8 storage-buffer grid");
});
