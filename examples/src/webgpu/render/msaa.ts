/**
 * @title 11 MSAA Render Target
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

const shapeShaderSource = `
Shader "WebGPU/MSAAShape" {
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
        output.color = vec3(0.95, 0.98, 1.0);
        return output;
      }

      vec4 frag(Varyings varyings) { return vec4(varyings.color, 1.0); }
      VertexShader = vert;
      FragmentShader = frag;
    }
  }
}`;

const displayShaderSource = `
Shader "WebGPU/MSAADisplay" {
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
  const root = scene.createRootEntity("msaa-render-target");
  const renderTexture = new Texture2D(engine, 512, 512, TextureFormat.R8G8B8A8, false, false);
  const renderTarget = new RenderTarget(engine, 512, 512, renderTexture, null, 4);

  const targetCameraEntity = root.createChild("target-camera");
  targetCameraEntity.transform.setPosition(0, 0, 3);
  targetCameraEntity.transform.lookAt(new Vector3());
  const targetCamera = targetCameraEntity.addComponent(Camera);
  targetCamera.cullingMask = Layer.Layer0;
  targetCamera.priority = -1;
  targetCamera.renderTarget = renderTarget;

  const shapeVertices = new Float32Array([-0.95, -0.72, 0, 0.9, -0.55, 0, -0.7, 0.82, 0]);
  const shapeMesh = new BufferMesh(engine, "msaa-shape");
  shapeMesh.setVertexBufferBinding(
    new Buffer(engine, BufferBindFlag.VertexBuffer, shapeVertices, BufferUsage.Static),
    12
  );
  shapeMesh.setVertexElements([new VertexElement("POSITION", 0, VertexElementFormat.Vector3, 0)]);
  shapeMesh.addSubMesh(0, 3);
  shapeMesh.bounds.min.set(-1, -1, -1);
  shapeMesh.bounds.max.set(1, 1, 1);
  const shape = root.createChild("shape");
  shape.layer = Layer.Layer0;
  const shapeRenderer = shape.addComponent(MeshRenderer);
  shapeRenderer.mesh = shapeMesh;
  shapeRenderer.setMaterial(new Material(engine, Shader.create(shapeShaderSource)));

  const displayCameraEntity = root.createChild("display-camera");
  displayCameraEntity.transform.setPosition(0, 0, 3);
  displayCameraEntity.transform.lookAt(new Vector3());
  const displayCamera = displayCameraEntity.addComponent(Camera);
  displayCamera.cullingMask = Layer.Layer1;

  const quadVertices = new Float32Array([
    -1, 0.78, 0, 0, 1, -1, -0.78, 0, 0, 0, 1, -0.78, 0, 1, 0, -1, 0.78, 0, 0, 1, 1, -0.78, 0, 1, 0, 1, 0.78, 0, 1, 1
  ]);
  const quadMesh = new BufferMesh(engine, "msaa-display");
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
  markExampleReady(`${backend} ${renderTarget.antiAliasing}x MSAA resolve`);
});
