/**
 * @title 09 Render Target
 * @category WebGPU
 * @backend webgpu
 */
import {
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Camera,
  Layer,
  Material,
  MeshRenderer,
  RenderTarget,
  Shader,
  Texture2D,
  TextureFormat,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import { createExampleEngine, markExampleReady, runExample, waitForFrames } from "../_shared/example";

const targetShaderSource = `
Shader "WebGPU/RenderTargetPattern" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec3 POSITION; vec2 TEXCOORD_0; };
      struct Varyings { vec2 uv; };
      mat4 renderer_MVPMat;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.uv = attributes.TEXCOORD_0;
        return output;
      }

      vec4 frag(Varyings varyings) {
        vec2 centered = varyings.uv * 2.0 - 1.0;
        float rings = 0.5 + 0.5 * cos(length(centered) * 28.0);
        float diagonal = 0.5 + 0.5 * sin((varyings.uv.x + varyings.uv.y) * 32.0);
        vec3 first = vec3(0.08, 0.75, 1.0);
        vec3 second = vec3(1.0, 0.22, 0.55);
        vec3 color = mix(first, second, rings * 0.65 + diagonal * 0.35);
        return vec4(color, 1.0);
      }
      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

const displayShaderSource = `
Shader "WebGPU/RenderTargetDisplay" {
  SubShader "Default" {
    Pass "Forward" {
      DepthState = { Enabled = false; WriteEnabled = false; }
      RasterState = { CullMode = CullMode.Off; }
      struct Attributes { vec3 POSITION; vec2 TEXCOORD_0; };
      struct Varyings { vec2 uv; };
      mat4 renderer_MVPMat;
      sampler2D material_RenderTexture;

      Varyings vert(Attributes attributes) {
        Varyings output;
        gl_Position = renderer_MVPMat * vec4(attributes.POSITION, 1.0);
        output.uv = vec2(attributes.TEXCOORD_0.x, 1.0 - attributes.TEXCOORD_0.y);
        return output;
      }

      vec4 frag(Varyings varyings) { return texture2D(material_RenderTexture, varyings.uv); }
      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

runExample(async () => {
  const { engine, backend } = await createExampleEngine();
  const scene = engine.sceneManager.activeScene;
  scene.background.solidColor.set(0.018, 0.028, 0.05, 1);
  const root = scene.createRootEntity("render-target");

  const renderTexture = new Texture2D(engine, 512, 512, TextureFormat.R8G8B8A8, false, false);
  const renderTarget = new RenderTarget(engine, 512, 512, renderTexture, null, 1);

  const targetCameraEntity = root.createChild("target-camera");
  targetCameraEntity.transform.setPosition(0, 0, 3);
  targetCameraEntity.transform.lookAt(new Vector3());
  const targetCamera = targetCameraEntity.addComponent(Camera);
  targetCamera.cullingMask = Layer.Layer0;
  targetCamera.priority = -1;
  targetCamera.renderTarget = renderTarget;

  const targetVertices = new Float32Array([
    -1, 1, 0, 0, 1, -1, -1, 0, 0, 0, 1, -1, 0, 1, 0, -1, 1, 0, 0, 1, 1, -1, 0, 1, 0, 1, 1, 0, 1, 1
  ]);
  const targetMesh = new BufferMesh(engine, "target-pattern");
  targetMesh.setVertexBufferBinding(
    new Buffer(engine, BufferBindFlag.VertexBuffer, targetVertices, BufferUsage.Static),
    20
  );
  targetMesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0),
    new VertexElement("TEXCOORD_0", 12, VertexElementFormat.Vector2, 0)
  ]);
  targetMesh.addSubMesh(0, 6);
  targetMesh.bounds.min.set(-1, -1, -1);
  targetMesh.bounds.max.set(1, 1, 1);
  const targetPattern = root.createChild("target-pattern");
  targetPattern.layer = Layer.Layer0;
  const targetRenderer = targetPattern.addComponent(MeshRenderer);
  targetRenderer.mesh = targetMesh;
  targetRenderer.setMaterial(new Material(engine, Shader.create(targetShaderSource)));

  const displayCameraEntity = root.createChild("display-camera");
  displayCameraEntity.transform.setPosition(0, 0, 3);
  displayCameraEntity.transform.lookAt(new Vector3());
  const displayCamera = displayCameraEntity.addComponent(Camera);
  displayCamera.cullingMask = Layer.Layer1;
  displayCamera.priority = 0;

  const quadVertices = new Float32Array([
    -1, 0.78, 0, 0, 1, -1, -0.78, 0, 0, 0, 1, -0.78, 0, 1, 0, -1, 0.78, 0, 0, 1, 1, -0.78, 0, 1, 0, 1, 0.78, 0, 1, 1
  ]);
  const quadMesh = new BufferMesh(engine, "target-display");
  quadMesh.setVertexBufferBinding(
    new Buffer(engine, BufferBindFlag.VertexBuffer, quadVertices, BufferUsage.Static),
    20
  );
  quadMesh.setVertexElements([
    new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0),
    new VertexElement("TEXCOORD_0", 12, VertexElementFormat.Vector2, 0)
  ]);
  quadMesh.addSubMesh(0, 6);
  quadMesh.bounds.min.set(-1, -1, -1);
  quadMesh.bounds.max.set(1, 1, 1);
  const displayMaterial = new Material(engine, Shader.create(displayShaderSource));
  displayMaterial.shaderData.setTexture("material_RenderTexture", renderTexture);
  const display = root.createChild("display");
  display.layer = Layer.Layer1;
  const displayRenderer = display.addComponent(MeshRenderer);
  displayRenderer.mesh = quadMesh;
  displayRenderer.setMaterial(displayMaterial);

  engine.run();
  await waitForFrames(5);
  markExampleReady(`${backend} render target sampled`);
});
