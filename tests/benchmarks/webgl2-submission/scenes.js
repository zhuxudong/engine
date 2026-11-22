import {
  AmbientOcclusionQuality,
  BloomEffect,
  Burst,
  DirectLight,
  MeshRenderer,
  MeshShape,
  MSAASamples,
  ParticleCompositeCurve,
  ParticleMaterial,
  ParticleRenderer,
  ParticleSubEmitterType,
  PBRMaterial,
  PostProcess,
  PrimitiveMesh,
  ShadowCascadesMode,
  ShadowResolution,
  ShadowType,
  Texture2D,
  TextureFormat,
  Vector3
} from "@galacean/engine";

function addMesh(root, mesh, material, x, y, z) {
  const entity = root.createChild();
  entity.transform.setPosition(x, y, z);
  const renderer = entity.addComponent(MeshRenderer);
  renderer.mesh = mesh;
  renderer.setMaterial(material);
  return entity;
}

function texture(engine, pixel) {
  const texture = new Texture2D(engine, 1, 1, TextureFormat.R8G8B8A8_UNorm, false, false);
  texture.setPixelBuffer(new Uint8Array(pixel));
  return texture;
}

function addLight(root) {
  const light = root.createChild().addComponent(DirectLight);
  light.entity.transform.setRotation(-55, -28, 0);
  light.intensity = 1.8;
  return light;
}

function multipass(engine, root, camera) {
  camera.isOrthographic = false;
  camera.fieldOfView = 58;
  camera.farClipPlane = 55;
  camera.entity.transform.setPosition(0, 3, 12);
  camera.entity.transform.lookAt(new Vector3(0, 0.9, -4));
  camera.enablePostProcess = true;
  camera.enableHDR = true;
  camera.msaaSamples = MSAASamples.FourX;
  camera.opaqueTextureEnabled = true;

  const scene = engine.sceneManager.activeScene;
  scene.shadowDistance = 40;
  scene.shadowCascades = ShadowCascadesMode.FourCascades;
  scene.shadowFourCascadeSplits.set(0.2, 0.44, 0.68);
  scene.shadowResolution = ShadowResolution.Medium;
  scene.ambientOcclusion.enabled = true;
  scene.ambientOcclusion.quality = AmbientOcclusionQuality.High;
  addLight(root).shadowType = ShadowType.SoftHigh;
  const bloom = root.createChild().addComponent(PostProcess).addEffect(BloomEffect);
  bloom.threshold.value = 0.7;
  bloom.intensity.value = 0.6;

  const color = texture(engine, [192, 126, 86, 255]);
  const normal = texture(engine, [135, 121, 254, 255]);
  const surface = texture(engine, [228, 140, 94, 255]);
  const coated = new PBRMaterial(engine);
  coated.baseTexture = color;
  coated.normalTexture = normal;
  coated.roughnessMetallicTexture = surface;
  coated.occlusionTexture = surface;
  coated.clearCoat = 0.9;
  coated.clearCoatRoughness = 0.24;
  coated.anisotropy = 0.4;
  coated.iridescence = 0.4;
  coated.sheenColor.set(0.25, 0.12, 0.08, 1);
  const glass = new PBRMaterial(engine);
  glass.transmission = 0.7;
  glass.thickness = 0.4;
  glass.roughness = 0.26;
  const emissive = new PBRMaterial(engine);
  emissive.emissiveColor.set(2.4, 1.1, 0.5, 1);
  const materials = [coated, coated, glass, emissive];
  const sphere = PrimitiveMesh.createSphere(engine, 0.68);
  addMesh(root, PrimitiveMesh.createCuboid(engine, 22, 0.2, 46), new PBRMaterial(engine), 0, -0.1, -8);
  for (let row = 0; row < 10; row++) {
    for (let column = 0; column < 7; column++) {
      addMesh(root, sphere, materials[(row + column) % materials.length], (column - 3) * 1.7, 0.68, 9 - row * 3.7);
    }
  }
  return { details: { pbrMeshes: 71, shadowCascades: 4, msaaSamples: 4, bloom: true, saoQuality: "High" } };
}

function particles(engine, root, camera) {
  camera.isOrthographic = true;
  camera.orthographicSize = 3;
  camera.entity.transform.setPosition(0, 0, 8);
  camera.entity.transform.lookAt(new Vector3());
  // Each animation tick advances exactly 1/60 simulation second on both browsers, even if a GPU frame stalls.
  engine.time.maximumDeltaTime = 0.000001;
  engine.time.timeScale = 1 / (60 * engine.time.maximumDeltaTime);

  const parentCount = 1000;
  const childrenPerParent = 49;
  const childCount = parentCount * childrenPerParent;
  const parentSeed = 2051;
  const childSeed = 2052;
  const material = new ParticleMaterial(engine);
  material.baseColor.set(0.3, 0.65, 0.95, 0.65);
  const shape = new MeshShape();
  shape.mesh = PrimitiveMesh.createSphere(engine, 1.2, { subdivisionLevel: 4, keepMeshData: true });

  function emitter(capacity, seed) {
    const entity = root.createChild();
    entity.isActive = false;
    const renderer = entity.addComponent(ParticleRenderer);
    renderer.setMaterial(material);
    const generator = renderer.generator;
    generator.randomSeed = seed;
    generator.main.playOnEnabled = false;
    generator.main.maxParticles = capacity;
    generator.main.startLifetime.constant = 60;
    generator.main.startSize.constant = 0.024;
    generator.main.startSpeed.constant = 0.15;
    generator.emission.rateOverTime.constant = 0;
    generator.noise.enabled = true;
    generator.noise.strengthX.constant = 0.12;
    generator.noise.scrollSpeed = 0.1;
    entity.isActive = true;
    return renderer;
  }

  const children = emitter(childCount, childSeed);
  children.generator.main.isLoop = false;
  children.generator.emission.addBurst(new Burst(0, new ParticleCompositeCurve(childrenPerParent)));
  const parents = emitter(parentCount, parentSeed).generator;
  parents.emission.shape = shape;
  parents.subEmitters.addSubEmitter(children, ParticleSubEmitterType.Birth);
  parents.subEmitters.enabled = true;
  parents.play(false);
  parents.emit(parentCount);
  return {
    details: { particleCapacity: parentCount + childCount, parentCount, childrenPerParent, parentSeed, childSeed },
    async validate(gl) {
      // Query a separate steady-state frame after all timed samples. Each simulated particle writes one point.
      await new Promise(requestAnimationFrame);
      const target = gl.TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN;
      const query = gl.createQuery();
      if (!query) throw new Error("Could not allocate particle feedback query");
      try {
        gl.beginQuery(target, query);
        try {
          engine.update();
        } finally {
          gl.endQuery(target);
        }
        const deadline = performance.now() + 10000;
        while (!gl.getQueryParameter(query, gl.QUERY_RESULT_AVAILABLE)) {
          if (gl.isContextLost() || performance.now() > deadline) throw new Error("Particle feedback query timed out");
          await new Promise(requestAnimationFrame);
        }
        const feedbackParticles = gl.getQueryParameter(query, gl.QUERY_RESULT);
        if (feedbackParticles !== parentCount + childCount) {
          throw new Error("Expected 50,000 simulated particles, GPU reported " + feedbackParticles);
        }
        return { feedbackParticles };
      } finally {
        gl.deleteQuery(query);
      }
    }
  };
}

function variants(engine, root, camera) {
  const variantCount = 50;
  const batchSize = 5;
  const batchInterval = 10;
  camera.isOrthographic = true;
  camera.orthographicSize = 6;
  camera.entity.transform.setPosition(0, 0, 12);
  camera.entity.transform.lookAt(new Vector3());
  addLight(root);
  const sphere = PrimitiveMesh.createSphere(engine, 0.48);
  const map = texture(engine, [205, 176, 145, 255]);
  const normal = texture(engine, [141, 120, 254, 255]);
  const entities = [];
  for (let mask = 0; mask < variantCount; mask++) {
    const material = new PBRMaterial(engine);
    if (mask & 1) material.baseTexture = map;
    if (mask & 2) material.normalTexture = normal;
    if (mask & 4) material.roughnessMetallicTexture = map;
    if (mask & 8) material.occlusionTexture = map;
    if (mask & 16) {
      material.emissiveTexture = map;
      material.emissiveColor.set(0.12, 0.08, 0.04, 1);
    }
    if (mask & 32) material.clearCoat = 0.8;
    const entity = addMesh(root, sphere, material, ((mask % 10) - 4.5) * 1.14, (Math.floor(mask / 10) - 2) * 1.14, 0);
    entity.isActive = false;
    entities.push(entity);
  }
  let active = 0;
  return {
    details: { variantCount, batchSize, batchInterval },
    beforeFrame(index) {
      if (index < 0 || active === variantCount) return;
      const required = Math.min((Math.floor(index / batchInterval) + 1) * batchSize, variantCount);
      while (active < required) entities[active++].isActive = true;
    }
  };
}

export async function prepareScene(scenario, engine, root, camera) {
  switch (scenario) {
    case "S2":
      return multipass(engine, root, camera);
    case "S3":
      return particles(engine, root, camera);
    case "S4":
      return variants(engine, root, camera);
    default:
      throw new Error("Unknown benchmark scene " + scenario);
  }
}
