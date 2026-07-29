import {
  BlinnPhongMaterial,
  PBRMaterial,
  UnlitMaterial,
  MeshRenderer,
  PrimitiveMesh,
  Entity,
  Camera,
  ModelMesh,
  RenderElement,
  DirectLight,
  ShadowType
} from "@galacean/engine-core";
import type { Buffer, MeshRendererShadowViewProvider, VertexBufferBinding } from "@galacean/engine-core";
import { Vector3 } from "@galacean/engine-math";
import { WebGLEngine } from "@galacean/engine";
import { describe, beforeAll, expect, it } from "vitest";

describe("MeshRenderer", async function () {
  let engine: WebGLEngine;
  let rootEntity: Entity;
  let cubeEntity: Entity;
  let cubeMesh: ModelMesh;
  let camera: Camera;

  beforeAll(async function () {
    engine = await WebGLEngine.create({ canvas: document.createElement("canvas") });
    const scene = engine.sceneManager.activeScene;

    rootEntity = scene.createRootEntity();
    const cameraEntity = rootEntity.createChild("Camera");
    cameraEntity.transform.setPosition(0, 0, 10);
    cameraEntity.transform.lookAt(new Vector3(0, 0, 0));
    camera = cameraEntity.addComponent(Camera);

    // create a cube entity and add a mesh renderer component.
    cubeEntity = rootEntity.createChild("Cube");
    cubeEntity.addComponent(MeshRenderer);

    engine.run();
  });

  it("mesh", () => {
    // Test set mesh and get mesh work correctly.
    const mr = cubeEntity.getComponent(MeshRenderer);
    const cubeMesh2 = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    mr.mesh = cubeMesh2;
    expect(mr.mesh).to.be.equal(cubeMesh2);
    expect(cubeMesh2.refCount).to.be.equal(1);

    // Test that repeated assignment does not increase the reference count.
    mr.mesh = cubeMesh2;
    expect(cubeMesh2.refCount).to.be.equal(1);

    cubeMesh = PrimitiveMesh.createCuboid(engine, 2, 2, 2);
    mr.mesh = cubeMesh;
    expect(mr.mesh).to.equal(cubeMesh);
    expect(cubeMesh2.refCount).to.be.equal(0);

    mr.mesh = null;
  });

  it("enableVertexColor", () => {
    // Test set and get enableVertexColor work correctly.
    const mr = cubeEntity.getComponent(MeshRenderer);
    mr.enableVertexColor = true;
    expect(mr.enableVertexColor).to.be.true;

    // Test that repeated assignment works correctly.
    mr.enableVertexColor = true;
    expect(mr.enableVertexColor).to.be.true;

    // Test that set false value works correctly.
    mr.enableVertexColor = false;
    expect(mr.enableVertexColor).to.be.equal(false);
  });

  it("does not CPU-batch indirect draw elements", () => {
    const renderer = cubeEntity.getComponent(MeshRenderer);
    const direct = { indirectBuffer: null } as RenderElement;
    const indirect = { indirectBuffer: {} } as RenderElement;

    expect(renderer._canBatch(indirect, direct)).toBe(false);
    expect(renderer._canBatch(direct, indirect)).toBe(false);
  });

  it("selects cascade bindings without changing the forward primitive", () => {
    const entity = rootEntity.createChild("ShadowViewBinding");
    const renderer = entity.addComponent(MeshRenderer);
    const forwardMesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    const shadowMesh = PrimitiveMesh.createCuboid(engine, 2, 2, 2);
    renderer.mesh = forwardMesh;
    renderer.setMaterial(new UnlitMaterial(engine));

    const shadowBuffer = {} as Buffer;
    const vertexBufferBindings = [{} as VertexBufferBinding];
    const provider: MeshRendererShadowViewProvider = {
      prepareShadowViews: () => {},
      getShadowViewBinding: (_renderer, shadowCascadeIndex, subMeshIndex) => {
        expect(shadowCascadeIndex).toBe(2);
        expect(subMeshIndex).toBe(0);
        return {
          primitive: shadowMesh._primitive,
          indirectBuffer: shadowBuffer,
          indirectOffset: 40,
          vertexBufferBindings
        };
      }
    };
    renderer._setShadowViewProvider(provider);

    const context = engine._renderContext;
    context.camera = camera;
    context.applyVirtualCamera(camera._virtualCamera, false);
    const cullingResults = camera._renderPipeline._cullingResults;

    cullingResults.reset();
    context.shadowCascadeIndex = -1;
    renderer._prepareRender(context);
    const forwardElement = cullingResults.opaqueQueue.elements.find((element) => element.component === renderer);
    expect(forwardElement.primitive).toBe(forwardMesh._primitive);
    expect(forwardElement.indirectBuffer).toBeNull();
    expect(forwardElement.vertexBufferBindings).toBeNull();

    cullingResults.reset();
    context.shadowCascadeIndex = 2;
    renderer._prepareRender(context);
    const shadowElement = cullingResults.opaqueQueue.elements.find((element) => element.component === renderer);
    expect(shadowElement.primitive).toBe(shadowMesh._primitive);
    expect(shadowElement.indirectBuffer).toBe(shadowBuffer);
    expect(shadowElement.indirectOffset).toBe(40);
    expect(shadowElement.vertexBufferBindings).toBe(vertexBufferBindings);

    context.shadowCascadeIndex = -1;
    renderer._setShadowViewProvider(null);
    entity.destroy();
    shadowMesh.destroy();
  });

  it("accepts direct shadow-view bindings with cascade-owned primitives", () => {
    const entity = rootEntity.createChild("DirectShadowViewBinding");
    const renderer = entity.addComponent(MeshRenderer);
    const forwardMesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    const shadowMesh = PrimitiveMesh.createCuboid(engine, 2, 2, 2);
    shadowMesh._primitive.instanceCount = 7;
    renderer.mesh = forwardMesh;
    renderer.setMaterial(new UnlitMaterial(engine));
    renderer._setShadowViewProvider({
      prepareShadowViews: () => {},
      getShadowViewBinding: () => ({ primitive: shadowMesh._primitive })
    });

    const context = engine._renderContext;
    context.camera = camera;
    context.applyVirtualCamera(camera._virtualCamera, false);
    const cullingResults = camera._renderPipeline._cullingResults;
    cullingResults.reset();
    context.shadowCascadeIndex = 0;
    renderer._prepareRender(context);

    const shadowElement = cullingResults.opaqueQueue.elements.find((element) => element.component === renderer);
    expect(shadowElement.primitive).toBe(shadowMesh._primitive);
    expect(shadowElement.primitive.instanceCount).toBe(7);
    expect(shadowElement.indirectBuffer).toBeNull();
    expect(shadowElement.indirectOffset).toBe(0);

    context.shadowCascadeIndex = -1;
    entity.destroy();
    shadowMesh.destroy();
  });

  it("omits shadow elements when a cascade binding has no instances", () => {
    const entity = rootEntity.createChild("EmptyShadowViewBinding");
    const renderer = entity.addComponent(MeshRenderer);
    renderer.mesh = PrimitiveMesh.createCuboid(engine, 1, 1, 1);
    renderer.setMaterial(new UnlitMaterial(engine));
    renderer._setShadowViewProvider({
      prepareShadowViews: () => {},
      getShadowViewBinding: () => null
    });

    const context = engine._renderContext;
    context.camera = camera;
    context.applyVirtualCamera(camera._virtualCamera, false);
    const cullingResults = camera._renderPipeline._cullingResults;
    cullingResults.reset();
    context.shadowCascadeIndex = 1;
    renderer._prepareRender(context);

    expect(cullingResults.opaqueQueue.elements.some((element) => element.component === renderer)).toBe(false);
    context.shadowCascadeIndex = -1;
    entity.destroy();
  });

  it("prepares each shared shadow-view provider once before rendering cascades", () => {
    const scene = engine.sceneManager.activeScene;
    const lightEntity = rootEntity.createChild("ShadowViewLight");
    const light = lightEntity.addComponent(DirectLight);
    light.shadowType = ShadowType.Hard;
    scene.sun = light;

    const rendererEntityA = rootEntity.createChild("ShadowViewA");
    const rendererEntityB = rootEntity.createChild("ShadowViewB");
    const rendererA = rendererEntityA.addComponent(MeshRenderer);
    const rendererB = rendererEntityB.addComponent(MeshRenderer);
    rendererA.castShadows = false;
    rendererB.castShadows = false;

    let prepareCount = 0;
    let preparedSliceCount = 0;
    const provider: MeshRendererShadowViewProvider = {
      prepareShadowViews: (_context, shadowSlices, shadowSliceCount) => {
        prepareCount++;
        preparedSliceCount = shadowSliceCount;
        for (let i = 0; i < shadowSliceCount; i++) {
          const forward = shadowSlices[i].virtualCamera.forward;
          const lightDirection = light.direction;
          expect(forward.x).toBeCloseTo(lightDirection.x, 6);
          expect(forward.y).toBeCloseTo(lightDirection.y, 6);
          expect(forward.z).toBeCloseTo(lightDirection.z, 6);
        }
      },
      getShadowViewBinding: () => {
        throw new Error("Non-casting renderers must not request a shadow-view binding.");
      }
    };
    rendererA._setShadowViewProvider(provider);
    rendererB._setShadowViewProvider(provider);

    try {
      engine.update();
      prepareCount = 0;
      camera.render();

      expect(prepareCount).toBe(1);
      expect(preparedSliceCount).toBe(scene.shadowCascades);
      expect(engine._renderContext.shadowCascadeIndex).toBe(-1);
    } finally {
      rendererEntityA.destroy();
      rendererEntityB.destroy();
      scene.sun = null;
      lightEntity.destroy();
    }
  });

  it("bounds", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);
    expect(mr.bounds.min).to.deep.include({ x: 0, y: 0, z: 0 });
    expect(mr.bounds.max).to.deep.include({ x: 0, y: 0, z: 0 });

    mr.mesh = cubeMesh;
    expect(mr.bounds.min).to.deep.include({ x: -1, y: -1, z: -1 });
    expect(mr.bounds.max).to.deep.include({ x: 1, y: 1, z: 1 });

    cubeEntity.transform.translate(1.5, 1.5, 1.5);
    expect(mr.bounds.min.x).to.closeTo(0.5, 0.01, "test bounds min x equal 0.5, delta 0.01");
    expect(mr.bounds.min.y).to.closeTo(0.5, 0.01, "test bounds min y equal 0.5, delta 0.01");
    expect(mr.bounds.min.z).to.closeTo(0.5, 0.01, "test bounds min z equal 0.5, delta 0.01");
    expect(mr.bounds.max.x).to.closeTo(2.5, 0.01, "test bounds max x equal 2.5, delta 0.01");
    expect(mr.bounds.max.y).to.closeTo(2.5, 0.01, "test bounds max y equal 2.5, delta 0.01");
    expect(mr.bounds.max.z).to.closeTo(2.5, 0.01, "test bounds max z equal 2.5, delta 0.01");

    cubeEntity.transform.rotate(new Vector3(0, 30, 0));
    expect(mr.bounds.min.x).to.closeTo(0.134, 0.001, "test bounds min x equal 0.134, delta 0.001");
    expect(mr.bounds.min.y).to.closeTo(0.5, 0.01, "test bounds min y equal 0.5, delta 0.001");
    expect(mr.bounds.min.z).to.closeTo(0.134, 0.001, "test bounds min z equal 0.134, delta 0.001");
    expect(mr.bounds.max.x).to.closeTo(2.866, 0.001, "test bounds max x equal 2.866, delta 0.001");
    expect(mr.bounds.max.y).to.closeTo(2.5, 0.001, "test bounds max y equal 2.5, delta 0.001");
    expect(mr.bounds.max.z).to.closeTo(2.866, 0.001, "test bounds max z equal 2.866, delta 0.001");

    cubeEntity.transform.setScale(3, 3, 3);
    expect(mr.bounds.min.x).to.closeTo(-2.598, 0.01, "test bounds min x equal -2.598, delta 0.01");
    expect(mr.bounds.min.y).to.closeTo(-1.5, 0.01, "test bounds min y equal -1.5, delta 0.01");
    expect(mr.bounds.min.z).to.closeTo(-2.598, 0.01, "test bounds min z equal -2.598, delta 0.01");
    expect(mr.bounds.max.x).to.closeTo(5.598, 0.01, "test bounds max x equal 5.598, delta 0.01");
    expect(mr.bounds.max.y).to.closeTo(4.5, 0.01, "test bounds max y equal 4.5, delta 0.01");
    expect(mr.bounds.max.z).to.closeTo(5.598, 0.01, "test bounds max z equal 5.598, delta 0.01");
  });

  it("clone", () => {
    // Test that clone works correctly.
    const cloneCube = cubeEntity.clone();
    const mr = cloneCube.getComponent(MeshRenderer);
    expect(mr.mesh).to.be.equal(cubeEntity.getComponent(MeshRenderer).mesh);

    // Test that mesh reference count is increased by 1 after clone.
    expect(cubeMesh.refCount).to.be.equal(2);

    cloneCube.destroy();
  });

  it("receiveShadows", () => {
    // Test that set and get receiveShadows work correctly.
    const mr = cubeEntity.getComponent(MeshRenderer);
    mr.receiveShadows = true;
    expect(mr.receiveShadows).to.be.true;

    // Test that set false value works correctly.
    mr.receiveShadows = false;
    expect(mr.receiveShadows).to.be.false;

    // Test that repeated assignment works correctly.
    mr.receiveShadows = true;
    expect(mr.receiveShadows).to.be.true;
  });

  it("material", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);

    // Add BlinnPhong, Unlit and PBR materials.
    mr.setMaterial(0, new BlinnPhongMaterial(engine));
    mr.setMaterial(0, new UnlitMaterial(engine));
    mr.setMaterial(1, new PBRMaterial(engine));

    // Test that get material works correctly.
    expect(mr.getMaterial()).to.be.instanceOf(UnlitMaterial);
    expect(mr.getMaterial(1)).to.be.instanceOf(PBRMaterial);

    // Test that return null when index is out of range.
    expect(mr.getMaterial(2)).to.be.null;
    expect(mr.getMaterial(-1)).to.be.null;

    mr.getInstanceMaterials();
    mr.setMaterial(1, new UnlitMaterial(engine));
    expect(mr.getMaterial(1)).to.be.instanceOf(UnlitMaterial);
  });

  it("materials", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);

    // Test that set materials works correctly.
    mr.setMaterials([new UnlitMaterial(engine), new PBRMaterial(engine), null, new BlinnPhongMaterial(engine)]);

    // Test that get materials works correctly.
    const materials = mr.getMaterials();
    expect(materials[0]).to.be.instanceOf(UnlitMaterial);
    expect(materials[1]).to.be.instanceOf(PBRMaterial);
    expect(materials[2]).to.be.null;
    expect(materials[3]).to.be.instanceOf(BlinnPhongMaterial);
  });

  it("materialCount", () => {
    // Test that get materialCount works correctly.
    const mr = cubeEntity.getComponent(MeshRenderer);
    mr.setMaterials([new UnlitMaterial(engine), new PBRMaterial(engine), new BlinnPhongMaterial(engine)]);
    mr.getInstanceMaterials();
    expect(mr.materialCount).to.be.equal(3);

    // Test that set materialCount works correctly.
    mr.materialCount = 2;
    expect(mr.materialCount).to.be.equal(2);

    // Test that set materialCount with negative value works correctly.
    mr.materialCount = 0;
    expect(mr.materialCount).to.be.equal(0);
  });

  it("getInstanceMaterial", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);

    // Test that getInstanceMaterial works correctly.
    expect(mr.getInstanceMaterial()).to.be.null;

    const unlitMaterial = new UnlitMaterial(engine);
    const pbrMaterial = new PBRMaterial(engine);
    mr.setMaterials([unlitMaterial, null, pbrMaterial]);

    // Test that getInstanceMaterial works correctly.
    const material = mr.getInstanceMaterial();
    expect(material).to.be.instanceOf(UnlitMaterial);
    expect(material.name).to.be.equal("Unlit(Instance)");

    // Test that material0 is same as material.
    const material0 = mr.getInstanceMaterial(0);
    expect(material0).to.be.eq(material);

    const material2 = mr.getInstanceMaterial(2);
    expect(material2).to.be.instanceOf(PBRMaterial);
    expect(material2.name).to.be.equal("PBR(Instance)");

    expect(mr.getInstanceMaterial(1)).to.be.null;

    // Test that return null when index is out of range.
    expect(mr.getInstanceMaterial(3)).to.be.null;
    expect(mr.getInstanceMaterial(-1)).to.be.null;
  });

  it("getInstanceMaterials", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);
    mr.setMaterials([new UnlitMaterial(engine), new PBRMaterial(engine)]);

    // Test that getInstanceMaterials works correctly.
    const materials = mr.getInstanceMaterials();
    expect(materials[0]).to.be.instanceOf(UnlitMaterial);
    expect(materials[0].name).to.be.equal("Unlit(Instance)");
    expect(materials[1]).to.be.instanceOf(PBRMaterial);
    expect(materials[1].name).to.be.equal("PBR(Instance)");
  });

  it("priority", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);

    // Test that set and get priority works correctly.
    expect(mr.priority).to.be.equal(0);

    mr.priority = 1;
    expect(mr.priority).to.be.equal(1);

    // Test that repeated assignment works correctly.
    mr.priority = 1;
    expect(mr.priority).to.be.equal(1);

    // Test that set negative value works correctly.
    mr.priority = -1;
    expect(mr.priority).to.be.equal(-1);
  });

  it("destroy", () => {
    const mr = cubeEntity.getComponent(MeshRenderer);
    cubeEntity.destroy();

    // Test that the mesh reference count is reduced by 1 after the entity is destroyed.
    expect(cubeMesh.refCount).to.be.equal(0);
    expect(mr.mesh).to.be.null;
    expect(mr.destroyed).to.be.true;
  });
});
