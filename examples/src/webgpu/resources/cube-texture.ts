/**
 * @title 07 Cube Texture
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
  TextureCube,
  TextureCubeFace,
  TextureFormat,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const shaderSource = `
Shader "WebGPU/CubeTexture" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec3 POSITION; vec2 TEXCOORD_0; };
      struct Varyings { vec2 uv; };
      mat4 renderer_MVPMat;
      samplerCube material_CubeTexture;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.uv = attributes.TEXCOORD_0;
        return output;
      }

      vec4 frag(Varyings varyings) {
        vec2 coordinates = varyings.uv * 2.0 - 1.0;
        return textureCube(material_CubeTexture, normalize(vec3(coordinates, 0.55)));
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
  const root = scene.createRootEntity("cube-texture");
  const cameraEntity = root.createChild("camera");
  cameraEntity.transform.setPosition(0, 0, 3);
  cameraEntity.transform.lookAt(new Vector3());
  cameraEntity.addComponent(Camera);

  const vertices = new Float32Array([
    -1, 0.72, 0, 0, 1, -1, -0.72, 0, 0, 0, 1, -0.72, 0, 1, 0, -1, 0.72, 0, 0, 1, 1, -0.72, 0, 1, 0, 1, 0.72, 0, 1, 1
  ]);
  const mesh = new BufferMesh(engine, "cube-texture-quad");
  mesh.setVertexBufferBinding(new Buffer(engine, BufferBindFlag.VertexBuffer, vertices, BufferUsage.Static), 20);
  mesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0),
    new VertexElement("TEXCOORD_0", 12, VertexElementFormat.Vector2, 0)
  ]);
  mesh.addSubMesh(0, 6);
  mesh.bounds.min.set(-1, -1, -1);
  mesh.bounds.max.set(1, 1, 1);

  const texture = new TextureCube(engine, 1, TextureFormat.R8G8B8A8, false, false);
  const faceColors: ReadonlyArray<readonly [TextureCubeFace, Uint8Array]> = [
    [TextureCubeFace.PositiveX, new Uint8Array([255, 72, 92, 255])],
    [TextureCubeFace.NegativeX, new Uint8Array([70, 230, 155, 255])],
    [TextureCubeFace.PositiveY, new Uint8Array([80, 145, 255, 255])],
    [TextureCubeFace.NegativeY, new Uint8Array([255, 205, 64, 255])],
    [TextureCubeFace.PositiveZ, new Uint8Array([175, 85, 255, 255])],
    [TextureCubeFace.NegativeZ, new Uint8Array([60, 210, 255, 255])]
  ];
  for (const [face, color] of faceColors) {
    texture.setPixelBuffer(face, color);
  }

  const material = new Material(engine, Shader.create(shaderSource));
  material.shaderData.setTexture("material_CubeTexture", texture);
  const renderer = root.createChild("quad").addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(material);

  engine.run();
  await waitForFrames();
  markExampleReady(`${backend} cube texture sampling`);
});
