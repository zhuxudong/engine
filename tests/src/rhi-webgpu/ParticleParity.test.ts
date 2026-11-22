import { afterEach, describe, expect, it } from "vitest";
import { WebGLEngine } from "@galacean/engine";
import {
  Engine, MeshShape, ModelMesh, ParticleCompositeCurve, ParticleInheritVelocityMode, ParticleMaterial, ParticleRenderer,
  ParticleSimulationSpace, ParticleStopMode, Vector3, Rand, WebGPUEngine, WebGPUGraphicDevice
} from "@galacean/engine-webgpu";

describe.skipIf(!navigator.gpu)("WebGPU particle simulation", () => {
  const engines: Engine[] = [];

  afterEach(() => {
    for (const engine of engines) engine.destroy();
    engines.length = 0;
  });

  it("matches transform feedback on the same seeded Noise, Limit, Inherit and Orbital simulation", async () => {
    const gl = await WebGLEngine.create({canvas:document.createElement("canvas")});
    engines.push(gl);
    const gpu = await WebGPUEngine.create({canvas:document.createElement("canvas")});
    engines.push(gpu);
    const device = (gpu._hardwareRenderer as WebGPUGraphicDevice).device;
    device.pushErrorScope("validation");

    async function simulate(engine: Engine) {
      const entity = engine.sceneManager.activeScene.createRootEntity();
      const renderer = entity.addComponent(ParticleRenderer);
      renderer.setMaterial(new ParticleMaterial(engine));
      const g = renderer.generator;
      g.stop(false, ParticleStopMode.StopEmittingAndClear);
      g.randomSeed = 317;
      g.emission.rateOverTime.constant = 0;
      g.main.simulationSpace = ParticleSimulationSpace.World;
      g.main.startLifetime.constant = 4;
      g.main.startSpeed.constant = 0.9;
      g.noise.strengthX.constant = 0.24;
      g.noise.enabled = true;
      g.limitVelocityOverLifetime.speed = new ParticleCompositeCurve(0.8);
      g.limitVelocityOverLifetime.dampen = 0.32;
      g.limitVelocityOverLifetime.enabled = true;
      g.inheritVelocity.mode = ParticleInheritVelocityMode.Current;
      g.inheritVelocity.curve = new ParticleCompositeCurve(0.35);
      g.inheritVelocity.enabled = true;
      g.velocityOverLifetime.orbitalY = new ParticleCompositeCurve(0.4);
      g.velocityOverLifetime.centerOffset.set(-1,0,0);
      g.velocityOverLifetime.enabled = true;
      const first = g._firstFreeElement;
      g.emit(6);
      for (let i=0; i<6; i++) {
        entity.transform.setPosition(i/100,0,-i/120);
        g._update(1/60);
      }
      const {buffer, stride} = g._feedbackSimulator!.readBinding;
      const values = new Float32Array(6*stride/4);
      await buffer.getDataAsync(values,first*stride);
      return values;
    }
    const reference = await simulate(gl);
    const values = await simulate(gpu);
    expect((await device.popErrorScope())?.message).toBeUndefined();
    expect(reference.some(x=>Math.abs(x)>0.1)).toBe(true);
    expect(values.length).toBe(reference.length);
    for(let i=0;i<values.length;i++) expect(values[i], "feedback float " + i).toBeCloseTo(reference[i], 3);
  });

  it("samples GPU-only emission meshes asynchronously and ignores a completed read from a replaced mesh", async () => {
    const engine = await WebGPUEngine.create({canvas:document.createElement("canvas")});
    engines.push(engine);
    const shape = new MeshShape();
    function mesh(x: number) {
      const mesh = new ModelMesh(engine);
      mesh.setPositions([new Vector3(x,3,4)]);
      mesh.setNormals([new Vector3(0,1,0)]);
      mesh.uploadData(true);
      return mesh;
    }
    const g=engine.sceneManager.activeScene.createRootEntity().addComponent(ParticleRenderer).generator;
    g.stop(false, ParticleStopMode.StopEmittingAndClear);
    g.emission.rateOverTime.constant=0;
    shape.mesh = mesh(1);
    const earlier = shape.prepare();
    shape.mesh = mesh(9);
    g.emission.shape=shape;
    g.emit(2);
    await Promise.all([earlier,shape.prepare()]);
    const position=new Vector3(),normal=new Vector3();
    shape._generateLocalPositionAndDirection(new Rand(0,17),0,position,normal);
    expect([position.x,position.y,position.z,normal.x,normal.y,normal.z]).toEqual([9,3,4,0,1,0]);
    g._update(1/60);
    expect(g._getAliveParticleCount()).toBe(2);
  });
});
