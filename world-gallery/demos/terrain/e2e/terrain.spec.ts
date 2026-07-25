import { expect, test, type Page, type TestInfo } from "@playwright/test";
import { compileSurface } from "../src/surface/SurfaceCompiler";
import type { SurfaceCompileInput, SurfaceTerrainSample } from "../src/surface/SurfaceContract";

const captureScreenshots = process.env.TERRAIN_E2E_CAPTURE === "1";

interface ShaderDiagnostic {
  readonly stage: "vertex" | "fragment" | "link";
  readonly log: string;
  readonly source?: string;
}

interface GeneratedShaderSource {
  readonly stage: "vertex" | "fragment";
  readonly source: string;
}

interface TerrainShaderStartup {
  readonly mode: "precompiled" | "runtime";
  readonly platforms: readonly ("gles100" | "wgsl")[];
  readonly registrationMs: number;
  readonly runtimeSourceLoadMs?: number;
}

declare global {
  interface Window {
    /** Shader compile/link failures captured before the engine starts. */
    __terrainShaderDiagnostics: ShaderDiagnostic[];
    /** WebGL draw calls captured before the engine starts. */
    __terrainDrawCalls: number;
    /** Submitted triangles captured from indexed WebGL draws. */
    __terrainTriangles: number;
    /** Submitted instance count captured from instanced WebGL draws. */
    __terrainSubmittedInstances: number;
    /** Instance counts submitted by explicit surface batches. */
    __surfaceInstanceDraws: number[];
    /** Terrain shaders after Galacean's ShaderLab-to-GLSL lowering. */
    __terrainGeneratedShaders: GeneratedShaderSource[];
    /** Surface shaders after Galacean's ShaderLab-to-GLSL lowering. */
    __surfaceGeneratedShaders: GeneratedShaderSource[];
  }
}

test("surface compiler is deterministic and enforces placement constraints", () => {
  const samples = new Map<string, SurfaceTerrainSample>();
  const terrain = {
    sample(worldX: number, worldZ: number): SurfaceTerrainSample {
      const key = `${Math.floor(worldX)},${Math.floor(worldZ)}`;
      return (
        samples.get(key) ?? {
          height: worldX + worldZ,
          slope: worldX / 16,
          control: worldZ < 8 ? 0 : 1 << 27,
          hole: worldX > 12
        }
      );
    }
  };
  const input: SurfaceCompileInput = {
    version: "1",
    seed: 42,
    origin: [0, 0],
    size: [16, 16],
    masks: [{ id: "full", width: 2, height: 2, pixels: new Uint8Array([255, 255, 255, 255]) }],
    rules: [
      {
        id: "grass",
        prototype: "grass-a",
        category: "grass",
        mode: "coverage",
        mask: "full",
        densityPerSquareMetre: 0.25,
        spacing: 0.25,
        scale: { horizontal: [0.8, 1.2], vertical: [0.9, 1.4] },
        yaw: [0, Math.PI * 2],
        constraints: { height: [0, 32], slope: [0, 0.75], terrainLayers: [0], excludeHoles: true },
        cellSize: 8,
        wind: true
      },
      {
        id: "trees",
        prototype: "tree-a",
        category: "tree",
        mode: "scatter",
        mask: "full",
        densityPerSquareMetre: 0.2,
        spacing: 3,
        scale: { horizontal: [0.9, 1.1], vertical: [0.9, 1.2] },
        yaw: [0, Math.PI * 2],
        constraints: { height: [0, 32], slope: [0, 1], terrainLayers: [0, 1], excludeHoles: true },
        cellSize: 8,
        wind: true
      }
    ],
    explicitPlacements: [
      {
        id: 7,
        prototype: "hero-rock",
        category: "rock",
        position: [3.25, 9.5, 4.75],
        rotation: [0.1, 0.2, 0.3, 0.9],
        scale: [2, 1.5, 1.25],
        color: [0.25, 0.5, 0.75, 1],
        cellSize: 8
      }
    ],
    terrain
  };

  const first = compileSurface(input);
  const second = compileSurface(input);
  expect(first.binary).toEqual(second.binary);
  expect(first.manifest).toEqual(second.manifest);
  expect(first.instances).toEqual(second.instances);
  expect(first.instances.some((instance) => instance.position[0] > 12)).toBe(false);
  expect(first.instances.find((instance) => instance.prototype === "hero-rock")).toMatchObject({
    position: [3.25, 9.5, 4.75],
    rotation: [0.1, 0.2, 0.3, 0.9],
    scale: [2, 1.5, 1.25],
    cell: [0, 0]
  });

  const trees = first.instances.filter((instance) => instance.prototype === "tree-a");
  for (let left = 0; left < trees.length; left++) {
    for (let right = left + 1; right < trees.length; right++) {
      const dx = trees[left].position[0] - trees[right].position[0];
      const dz = trees[left].position[2] - trees[right].position[2];
      expect(Math.hypot(dx, dz)).toBeGreaterThanOrEqual(3);
    }
  }

  const changedSeed = compileSurface({ ...input, seed: 43 });
  expect(changedSeed.binary).not.toEqual(first.binary);
});

test("terrain data, clipmap, and production shader stay coherent", async ({ page }, testInfo) => {
  const pageErrors: string[] = [];
  const consoleErrors: string[] = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (message.type() === "error" || /INVALID_OPERATION|program not valid/i.test(message.text())) {
      consoleErrors.push(message.text());
    }
  });
  await installShaderDiagnostics(page);

  await page.goto("/demos/terrain/index.html?view=clipmap-lod&pose=top");
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments");
  await expect(page.locator('[aria-label="Terrain material inspector"]')).toBeVisible();
  const previewImages = page.locator(".debug-inspector__preview img");
  await expect(previewImages).toHaveCount(9);
  for (let index = 0; index < (await previewImages.count()); index++) {
    await previewImages.nth(index).scrollIntoViewIfNeeded();
  }
  await expect.poll(() => previewImages.evaluateAll((images) => images.every((image) => {
    const preview = image as HTMLImageElement;
    return preview.complete && preview.naturalWidth > 0;
  }))).toBe(true);
  await test.step("direct and baked environment lighting stay fragment-side", async () => {
    expect(await page.evaluate(() => window.terrainDebug!.getLighting())).toEqual({
      directLight: true,
      shadows: true,
      environment: true,
      skybox: true
    });
    await page.evaluate(async () => {
      window.terrainDebug!.setView("surface");
      window.terrainDebug!.setPose("oblique");
      window.terrainDebug!.setLighting({ directLight: false, environment: true });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    const environmentOnly = await readFrameFingerprint(page);
    await page.evaluate(async () => {
      window.terrainDebug!.setLighting({ directLight: true, environment: false });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    const directOnly = await readFrameFingerprint(page);
    expect(directOnly).not.toBe(environmentOnly);
    const generatedShaders = await page.evaluate(() => window.__terrainGeneratedShaders);
    expect(generatedShaders.some((shader) => shader.stage === "fragment" && shader.source.includes("sampleShadowMap"))).toBe(true);
    expect(generatedShaders.some((shader) => shader.stage === "fragment" && shader.source.includes("diffuseIrradiance(shadingNormal)"))).toBe(true);
    expect(
      generatedShaders.some((shader) => shader.stage === "vertex" && (shader.source.includes("sampleShadowMap") || shader.source.includes("diffuseIrradiance")))
    ).toBe(false);
    await page.evaluate(() => window.terrainDebug!.setLighting({ directLight: true, environment: true }));
  });

  await test.step("rendering controls use actual engine state", async () => {
    const renderingFolder = page.locator(".debug-inspector .title").filter({ hasText: "Rendering / 渲染" });
    const lightingFolder = page.locator(".debug-inspector .title").filter({ hasText: "Lighting / 光照" });
    const cameraFolder = page.locator(".debug-inspector .title").filter({ hasText: "Camera / 相机" });
    const postProcessFolder = page.locator(".debug-inspector .title").filter({ hasText: "Post-process / 后处理" });
    for (const title of [renderingFolder, lightingFolder, cameraFolder, postProcessFolder]) {
      await expect(title).toBeVisible();
      await expect(title.locator("..")).not.toHaveClass(/closed/);
    }

    const original = await page.evaluate(() => window.terrainDebug!.getRendering());
    const updated = await page.evaluate((initial) => {
      window.terrainDebug!.setRendering({
        camera: { hdr: !initial.camera.hdr, msaaSamples: initial.camera.msaaSamples },
        postProcess: {
          enabled: !initial.postProcess.enabled,
          tonemapping: !initial.postProcess.tonemapping,
          tonemappingMode: initial.postProcess.tonemappingMode
        }
      });
      return window.terrainDebug!.getRendering();
    }, original);
    expect(updated.camera).toEqual({ hdr: !original.camera.hdr, msaaSamples: original.camera.msaaSamples });
    expect(updated.postProcess).toEqual({
      enabled: !original.postProcess.enabled,
      tonemapping: !original.postProcess.tonemapping,
      tonemappingMode: original.postProcess.tonemappingMode
    });
    await attachScreenshot(page, testInfo, "rendering-controls");
    await page.evaluate((state) => window.terrainDebug!.setRendering(state), original);
    expect(await page.evaluate(() => window.terrainDebug!.getRendering())).toEqual(original);
  });

  await test.step("surface cells submit deterministic instanced batches", async () => {
    const compiled = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(compiled.totalInstances).toBe(406_179);
    expect(compiled.totalRanges).toBe(649);
    expect(compiled.rendererBatches).toBe(1_177);
    expect(compiled.categoryCounts).toEqual({
      grass: 396_969,
      flower: 597,
      shrub: 4_817,
      tree: 864,
      rock: 2_932,
      cliff: 0
    });
    expect(compiled.sourceRules.find((rule) => rule.category === "tree")).toMatchObject({
      mode: "scatter",
      spacing: 24,
      cellSize: 256
    });
    expect(compiled.debugMasks.map((mask) => mask.id)).toEqual(["grass", "flower", "shrub", "tree", "rock"]);
    const materialContract = await page.evaluate(async () => {
      const manifest = await fetch("/demos/terrain/data/surface/surface-manifest.json").then((response) =>
        response.json()
      );
      return {
        colorSpace: manifest.colorSpace,
        translucencyModels: Array.from(
          new Set(manifest.materials.map((material: { translucencyModel: string }) => material.translucencyModel))
        )
      };
    });
    expect(materialContract).toEqual({ colorSpace: "linear", translucencyModels: ["none"] });
    const generatedSurfaceShaders = await page.evaluate(() => window.__surfaceGeneratedShaders);
    expect(
      generatedSurfaceShaders.some(
        (shader) =>
          shader.stage === "vertex" &&
          shader.source.includes("worldPosition = surfacePosition") &&
          shader.source.includes("worldNormal = surfaceNormal")
      )
    ).toBe(true);
    expect(
      generatedSurfaceShaders.every(
        (shader) =>
          !shader.source.includes("worldPosition = worldPosition") &&
          !shader.source.includes("worldNormal = worldNormal")
      )
    ).toBe(true);
    expect(
      generatedSurfaceShaders.some(
        (shader) =>
          shader.stage === "fragment" &&
          shader.source.includes("material_MetallicSmoothness") &&
          shader.source.includes("evaluateIBL")
      )
    ).toBe(true);

    await page.evaluate(async () => {
      await window.terrainDebug!.setPose("first-person");
      window.terrainDebug!.setSurface({ wind: { enabled: false } });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    await expect
      .poll(() =>
        page.evaluate(() => window.terrainDebug!.inspectSurface().lodCounts.slice(1).some((count) => count > 0))
      )
      .toBe(true);
    await page.evaluate(() => window.terrainDebug!.setSurface({ lod: { enabled: false } }));
    await expect.poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().transitioningRanges)).toBe(0);
    const transitioningRanges = await page.evaluate(() => {
      window.terrainDebug!.setSurface({ lod: { enabled: true } });
      return window.terrainDebug!.inspectSurface().transitioningRanges;
    });
    expect(transitioningRanges).toBeGreaterThan(0);
    await expect.poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().transitioningRanges)).toBe(0);
    expect(
      await page.evaluate(() => window.terrainDebug!.inspectSurface().lodCounts.slice(1).some((count) => count > 0))
    ).toBe(true);
    const surfaceFrame = await readFrameFingerprint(page);
    expect(await page.evaluate(() => window.__surfaceInstanceDraws.some((count) => count > 1))).toBe(true);

    await page.evaluate(() =>
      window.terrainDebug!.setSurface({
        enabled: { grass: false, flower: false, shrub: false, tree: false, rock: false, cliff: false }
      })
    );
    expect((await page.evaluate(() => window.terrainDebug!.inspectSurface())).visibleInstances).toBe(0);
    expect(await readFrameFingerprint(page)).not.toBe(surfaceFrame);

    await page.evaluate(() => {
      window.terrainDebug!.resetTuning();
      window.terrainDebug!.setSurfaceDebugView("normal");
    });
    expect((await page.evaluate(() => window.terrainDebug!.getSurface())).debugView).toBe("normal");
    await attachScreenshot(page, testInfo, "surface-normal");
    await page.evaluate(() => window.terrainDebug!.setSurfaceDebugView("surface"));
  });

  await test.step("world-position varying survives shader lowering", async () => {
    const terrainShaders = await page.evaluate(() => window.__terrainGeneratedShaders);
    const vertexShaders = terrainShaders.filter((shader) => shader.stage === "vertex");
    const fragmentShaders = terrainShaders.filter((shader) => shader.stage === "fragment");
    expect(vertexShaders).not.toHaveLength(0);
    for (const shader of vertexShaders) {
      expect(shader.source).not.toMatch(/(?:^|\n)\s*worldPosition\s*=\s*worldPosition\s*;/m);
      expect(shader.source).toMatch(/(?:^|\n)\s*worldPosition\s*=\s*terrainWorldPosition\s*;/m);
    }
    expect(fragmentShaders).not.toHaveLength(0);
    for (const shader of fragmentShaders) {
      expect(shader.source).not.toMatch(/(?:^|\n)\s*worldNoiseDdxDdy\s*=\s*worldNoiseDdxDdy\s*;/m);
      expect(shader.source).toMatch(/backgroundNoiseDerivatives\s*=\s*worldNoiseDdxDdy\s*;/);
    }
    expect(fragmentShaders.some((shader) => /sampleGrid\s*\*\s*vertexSpacing\s*\(\s*\)/.test(shader.source))).toBe(true);
    expect(fragmentShaders.some((shader) => /material_BilerpEnabled\s*!=\s*0\s*&&\s*regionMip\s*<\s*0\.0/.test(shader.source))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("material_TriReduction"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("sampleIndex"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("worldBackgroundMaterialFade"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("materialCoordinateScale"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("sampleLayerWithWorldTransition"))).toBe(true);
  });

  await test.step("inspector folders and panel can scroll", async () => {
    const terrainFolderTitle = page.locator(".debug-inspector .title").filter({ hasText: "Terrain / 地形" });
    const sceneFolderTitle = page.locator(".debug-inspector .title").filter({ hasText: "Scene / 场景" });
    await terrainFolderTitle.click();
    await expect(terrainFolderTitle.locator("..")).toHaveClass(/closed/);
    await expect(sceneFolderTitle).toBeHidden();
    await terrainFolderTitle.click();
    await expect(terrainFolderTitle.locator("..")).not.toHaveClass(/closed/);
    await expect(sceneFolderTitle).toBeVisible();

    const textureAssetsTitle = page.locator(".debug-inspector .title").filter({ hasText: "Texture assets" });
    await textureAssetsTitle.click();
    await expect(textureAssetsTitle.locator("..")).toHaveClass(/closed/);
    await expect(page.locator(".debug-inspector__preview-row").first()).toBeHidden();
    await textureAssetsTitle.click();
    await expect(textureAssetsTitle.locator("..")).not.toHaveClass(/closed/);
    await expect(page.locator(".debug-inspector__preview-row").first()).toBeVisible();

    const sceneFolder = page.locator(".debug-inspector .title").filter({ hasText: "Scene / 场景" }).locator("..");
    await expect(sceneFolder).not.toContainText("Texture layer / 纹理层");
    const worldNoiseFolder = page.locator(".debug-inspector .title").filter({ hasText: "World noise / 世界噪声" });
    await expect(worldNoiseFolder).toBeVisible();
    const worldFolder = page.locator(".debug-inspector .title").filter({ hasText: "World background / 世界背景" }).locator("..");
    for (const folder of [worldFolder, textureAssetsTitle.locator(".."), page.locator(".debug-inspector .title").filter({ hasText: "Macro variation / 宏观变化" }).locator("..")]) {
      await expect(folder).not.toHaveClass(/closed/);
    }

    const inspectorScroll = await page.evaluate(() => {
      const panel = document.querySelector<HTMLElement>('[aria-label="Terrain material inspector"]')!;
      panel.scrollTop = panel.scrollHeight;
      return { clientHeight: panel.clientHeight, scrollHeight: panel.scrollHeight, scrollTop: panel.scrollTop };
    });
    expect(inspectorScroll.scrollHeight).toBeGreaterThan(inspectorScroll.clientHeight);
    expect(inspectorScroll.scrollTop).toBeGreaterThan(0);
  });

  await test.step("region and control fixtures", async () => {
    const snapshot = await page.evaluate(() => window.terrainDebug!.inspect());
    expect(snapshot.regionLocations).toEqual([
      [0, -2],
      [0, -1],
      [0, 0]
    ]);
    expect(snapshot.regionSize).toBe(1024);
    expect(snapshot.vertexSpacing).toBe(1);
    expect(snapshot.meshSize).toBe(48);
    expect(snapshot.meshLods).toBe(7);
    expect(snapshot.segmentsPerLod).toEqual([24, 20, 20, 20, 20, 20, 20]);

    const probes = await page.evaluate(() => ({
      centre: window.terrainDebug!.readProbe(512, -512),
      upperSeam: window.terrainDebug!.readProbe(512, -1023),
      lowerSeam: window.terrainDebug!.readProbe(512, -1024),
      outside: window.terrainDebug!.readProbe(-1, 0)
    }));
    expect(probes.centre.height).toBeCloseTo(-7.1993591210803345, 8);
    expect(probes.centre.control).toMatchObject({
      raw: 4_194_305,
      base: 0,
      overlay: 1,
      blend: 0,
      scale: 0.5,
      surfaceFeatures: 0,
      autoshader: true
    });
    expect(probes.upperSeam.height).toBeCloseTo(46.32088197146564, 8);
    expect(probes.lowerSeam.height).toBeCloseTo(46.24415960936905, 8);
    expect(probes.outside.height).toBeUndefined();
    expect(probes.outside.control).toBeUndefined();
  });

  await test.step("geometry clipmap topology and snap", async () => {
    await page.evaluate(async () => {
      await window.terrainDebug!.setPose("top");
      await window.terrainDebug!.setView("clipmap-lod");
    });
    const snapshot = await page.evaluate(() => window.terrainDebug!.inspect());
    expect(snapshot.segmentCount).toBe(144);
    expect(snapshot.segments[0]).toEqual({
      lod: 0,
      group: "tile",
      instance: 0,
      position: [512, -400],
      scale: 1
    });
    expect(snapshot.segments[24]).toEqual({
      lod: 1,
      group: "tile",
      instance: 0,
      position: [516, -348],
      scale: 2
    });
    await attachScreenshot(page, testInfo, "clipmap-topology");
  });

  await test.step("surface, region seam, and dual factor", async () => {
    const cases = [
      { name: "overview", view: "surface", pose: "overview", viewFirst: false, minimumUniqueColors: 0 },
      { name: "region-seam", view: "region-grid", pose: "seam", viewFirst: true, minimumUniqueColors: 3 },
      { name: "dual-factor", view: "dual-factor", pose: "dual", viewFirst: true, minimumUniqueColors: 3 },
      { name: "surface-features", view: "surface-features", pose: "top", viewFirst: true, minimumUniqueColors: 2 },
      { name: "world-material-scale", view: "world-material-scale", pose: "background-seam", viewFirst: true, minimumUniqueColors: 3 }
    ] as const;
    for (const diagnostic of cases) {
      await page.evaluate(async ({ view, pose, viewFirst }) => {
        if (viewFirst) {
          await window.terrainDebug!.setView(view);
          await window.terrainDebug!.setPose(pose);
        } else {
          await window.terrainDebug!.setPose(pose);
          await window.terrainDebug!.setView(view);
        }
      }, diagnostic);
      if (diagnostic.minimumUniqueColors > 0) {
        expect((await readFrameStats(page)).uniqueColors, diagnostic.name).toBeGreaterThanOrEqual(
          diagnostic.minimumUniqueColors
        );
      }
    }
    const initialBackground = await page.evaluate(() => window.terrainDebug!.getTuning().world.background);
    await page.evaluate(async () => {
      await window.terrainDebug!.setWorldBackground("flat");
      await window.terrainDebug!.setPose("background-seam");
      await window.terrainDebug!.setView("layer-detiled");
    });
    expect((await readFrameStats(page)).uniqueColors).toBeGreaterThan(2);
    await attachScreenshot(page, testInfo, "flat-background-detile-seam");
    await page.evaluate(async (background) => {
      await window.terrainDebug!.setWorldBackground(background);
      await window.terrainDebug!.setView("surface");
    }, initialBackground);

    await page.evaluate(async () => {
      await window.terrainDebug!.setWorldBackground("noise");
      await window.terrainDebug!.setWorldNoiseTuning({ lodDistance: 0 });
      await window.terrainDebug!.setPose("background-seam");
      await window.terrainDebug!.setView("surface");
    });
    expect((await readFrameStats(page)).uniqueColors).toBeGreaterThan(2);
    await attachScreenshot(page, testInfo, "world-noise-material-continuity");
    await page.evaluate(() => window.terrainDebug!.resetTuning());
  });

  await test.step("production debug controls", async () => {
    const defaults = await page.evaluate(() => window.terrainDebug!.getTuning());
    expect(defaults.sampling.linearControlBlend).toBe(false);
    expect(defaults.sampling.normalMapMaxLod).toBe(1);
    expect(defaults.layers[1]).toMatchObject({
      layer: 1,
      uvScale: 0.5,
      detilingRotation: 0.161,
      detilingShift: 0
    });
    expect(defaults.sampling.bilerpEnabled).toBe(true);
    await page.evaluate(() => window.terrainDebug!.setSamplingTuning({ bilerpEnabled: false }));
    expect(await page.evaluate(() => window.terrainDebug!.getTuning().sampling.bilerpEnabled)).toBe(false);

    await page.evaluate(async () => {
      await window.terrainDebug!.setPose("oblique");
      await window.terrainDebug!.setView("layer-source");
    });
    const sourceFingerprint = await readFrameFingerprint(page);
    await page.evaluate(async () => {
      await window.terrainDebug!.setView("layer-detiled");
    });
    expect(await readFrameFingerprint(page)).not.toBe(sourceFingerprint);
    await attachScreenshot(page, testInfo, "detiled-surface");

    await page.evaluate(async () => {
      await window.terrainDebug!.setPose("top");
      await window.terrainDebug!.setView("detile-rotation-axis");
      await window.terrainDebug!.setLayerTuning(1, { detilingRotation: 0, detilingShift: 0 });
    });
    const zeroRotationFingerprint = await readFrameFingerprint(page);
    await page.evaluate(() => window.terrainDebug!.setLayerTuning(1, { detilingRotation: 0.5 }));
    const rotatedAxisFingerprint = await readFrameFingerprint(page);
    await page.evaluate(() => window.terrainDebug!.setLayerTuning(1, { detilingShift: 0.5 }));
    expect(rotatedAxisFingerprint).not.toBe(zeroRotationFingerprint);
    expect(await readFrameFingerprint(page)).toBe(rotatedAxisFingerprint);

    const configured = await page.evaluate(() => {
      window.terrainDebug!.setMaterialTuning({
        autoShader: { enabled: false, slope: 0.75 },
        projection: { enabled: false, threshold: 0.8 },
        dualScaling: { enabled: false, near: 90, far: 180, triScaleReduction: 0.25 },
        macroVariation: { enabled: false, noise1Scale: 0.05, noise2Scale: 0.08 }
      });
      return window.terrainDebug!.getTuning();
    });
    expect(configured.material).toMatchObject({
      autoShader: { enabled: false, slope: 0.75 },
      projection: { enabled: false, threshold: 0.8 },
      dualScaling: { enabled: false, near: 90, far: 180, triScaleReduction: 0.25 },
      macroVariation: { enabled: false, noise1Scale: 0.05, noise2Scale: 0.08 }
    });
    const rejectedNear = await page.evaluate(() => {
      const before = window.terrainDebug!.getTuning().material.dualScaling.near;
      let message = "";
      try {
        window.terrainDebug!.setMaterialTuning({ dualScaling: { near: 180 } });
      } catch (error) {
        message = error instanceof Error ? error.message : String(error);
      }
      return { before, after: window.terrainDebug!.getTuning().material.dualScaling.near, message };
    });
    expect(rejectedNear).toMatchObject({ before: 90, after: 90 });
    expect(rejectedNear.message).toContain("far must be greater than dualScaling.near");

    await page.evaluate(async () => {
      await window.terrainDebug!.setView("wireframe");
    });
    await attachScreenshot(page, testInfo, "production-wireframe");

    await page.evaluate(async () => {
      await window.terrainDebug!.setLayerTuning(1, { detilingRotation: 0 });
      await window.terrainDebug!.resetTuning();
      await window.terrainDebug!.setView("surface");
    });
    expect(await page.evaluate(() => window.terrainDebug!.getTuning())).toEqual(defaults);
    await attachScreenshot(page, testInfo, "surface-color-map");

    await page.evaluate(async () => {
      await window.terrainDebug!.setPose("surface");
      await window.terrainDebug!.setView("bilerp");
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    const fastControlBlend = await readFrameFingerprint(page);
    await page.evaluate(async () => {
      window.terrainDebug!.setSamplingTuning({ linearControlBlend: true });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    expect(await page.evaluate(() => window.terrainDebug!.getTuning().sampling.linearControlBlend)).toBe(true);
    expect(await readFrameFingerprint(page)).not.toBe(fastControlBlend);
    await page.evaluate(async () => {
      window.terrainDebug!.setSamplingTuning({ linearControlBlend: false });
      await window.terrainDebug!.setView("surface");
    });

    expect(
      await page.evaluate(() => {
        window.terrainDebug!.setWaterDebug({ enabled: true, height: 10 });
        return window.terrainDebug!.getWaterDebug();
      })
    ).toEqual({ enabled: true, height: 10 });
    expect((await readFrameStats(page)).uniqueColors).toBeGreaterThan(2);
    await attachScreenshot(page, testInfo, "water-debug");
    expect(
      await page.evaluate(() => {
        window.terrainDebug!.setWaterDebug({ enabled: false });
        return window.terrainDebug!.getWaterDebug();
      })
    ).toEqual({ enabled: false, height: 10 });
  });

  await test.step("surface-system placement and batching", async () => {
    await page.evaluate(() => window.terrainDebug!.setSurface({ enabled: true }));
    const surface = await page.evaluate(() => window.terrainDebug!.getSurface());
    expect(surface.enabled).toBe(true);
    expect(surface.counts.tree).toBeGreaterThan(0);
    expect(surface.counts["tree-tall"]).toBeGreaterThan(0);
    expect(surface.instancing).toBe("engine-auto");
    expect(surface.instanceCount).toBeGreaterThan(20);
    for (const asset of ["tree", "tree-tall"] as const) {
      expect(surface.samples[asset].length).toBeGreaterThan(0);
    }
    const sampledTerrain = await page.evaluate(() => {
      const surface = window.terrainDebug!.getSurface();
      return Object.fromEntries(
        Object.entries(surface.samples).map(([asset, placements]) => [
          asset,
          placements.map((placement) => ({
            placement,
            probe: window.terrainDebug!.readProbe(placement.position[0], placement.position[2])
          }))
        ])
      );
    });
    for (const [asset, entries] of Object.entries(sampledTerrain)) {
      for (const { placement, probe } of entries) {
        expect(probe.height, asset).toBeCloseTo(placement.position[1] + placement.localMinY * placement.scale, 8);
        expect(probe.control?.hole, asset).toBe(false);
        expect(placement.region).toEqual([0, -1]);
        expect(probe.control?.overlay, asset).toBe(1);
        expect(probe.control?.surfaceFeatures, asset).toBe(1);
      }
    }

    await page.evaluate(async () => {
      window.__terrainDrawCalls = 0;
      await window.terrainDebug!.setView("surface");
      await window.terrainDebug!.setPose("surface");
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    expect((await readFrameStats(page)).uniqueColors).toBeGreaterThan(2);
    expect(await page.evaluate(() => window.__terrainDrawCalls)).toBeLessThan(300);
    const withSurface = await readFrameFingerprint(page);
    await page.evaluate(() => window.terrainDebug!.setSurface({ enabled: false }));
    expect(await readFrameFingerprint(page)).not.toBe(withSurface);
    await page.evaluate(() => window.terrainDebug!.setSurface({ enabled: true }));
    await page.evaluate(() => window.terrainDebug!.setPose("first-person"));
    expect((await readFrameStats(page)).uniqueColors).toBeGreaterThan(2);
    await attachScreenshot(page, testInfo, "surface-system");
  });

  await test.step("direct shadows and baked environment lighting", async () => {
    await page.evaluate(async () => {
      window.terrainDebug!.setSurface({ enabled: false });
      await window.terrainDebug!.setView("surface");
      await window.terrainDebug!.setPose("oblique");
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });

    const directLightPattern = /DirectLight\s+directLight\s*=\s*getDirectLight\(0\)/;
    const indirectLightPattern = /lighting\s*\+=\s*albedo\s*\*\s*ambientOcclusion\s*\*\s*varyings\.bakedIrradiance/;
    const initialLightingShaderCount = await page.evaluate(() => window.__terrainGeneratedShaders.length);
    await page.evaluate(async () => {
      window.terrainDebug!.setLighting({ directLight: false, environment: true });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    expect(await page.evaluate(() => window.terrainDebug!.getLighting())).toEqual({ directLight: false, shadows: true, environment: true });
    const environmentOnlyShaders = await page.evaluate((count) => window.__terrainGeneratedShaders.slice(count), initialLightingShaderCount);
    expect(environmentOnlyShaders.some((shader) => shader.stage === "fragment" && !directLightPattern.test(shader.source))).toBe(true);
    const environmentOnly = await readCompositedFrameFingerprint(page);
    await attachScreenshot(page, testInfo, "lighting-environment-only");

    const compiledShaderCount = await page.evaluate(() => window.__terrainGeneratedShaders.length);
    await page.evaluate(async () => {
      window.terrainDebug!.setLighting({ directLight: true, environment: false });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    expect(await page.evaluate(() => window.terrainDebug!.getLighting())).toEqual({ directLight: true, shadows: true, environment: false });
    const directOnlyShaders = await page.evaluate((count) => window.__terrainGeneratedShaders.slice(count), compiledShaderCount);
    expect(directOnlyShaders.some((shader) => shader.stage === "fragment" && directLightPattern.test(shader.source) && !indirectLightPattern.test(shader.source))).toBe(true);
    const directOnly = await readCompositedFrameFingerprint(page);
    await attachScreenshot(page, testInfo, "lighting-direct-shadow-only");

    await page.evaluate(() => window.terrainDebug!.setLighting({ directLight: true, environment: true }));
    expect(await page.evaluate(() => window.terrainDebug!.getLighting())).toEqual({ directLight: true, shadows: true, environment: true });
    const combined = await readCompositedFrameFingerprint(page);
    await attachScreenshot(page, testInfo, "lighting-direct-and-environment");

    expect(new Set([environmentOnly, directOnly, combined]).size).toBe(3);
    await page.evaluate(() => window.terrainDebug!.setSurface({ enabled: true }));
  });

  expect(await page.evaluate(() => window.__terrainShaderDiagnostics)).toEqual([]);
  expect(pageErrors).toEqual([]);
  expect(consoleErrors).toEqual([]);
});

test("first-person camera follows the CPU heightfield", async ({ page }) => {
  await page.goto("/demos/terrain/index.html");
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments");
  await expect(page.getByText("Ground clearance / 离地高度", { exact: true })).toBeVisible();

  const initial = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
  expect(initial.active).toBe(true);
  expect(initial.eyeHeight).toBe(1.7);
  expect(initial.moveSpeed).toBe(8);
  expect(initial.groundHeight).toBeDefined();
  expect(initial.position[1]).toBeCloseTo(initial.groundHeight! + 1.7, 5);

  const adjusted = await page.evaluate(() => {
    window.terrainDebug!.setFirstPersonEyeHeight(2.25);
    window.terrainDebug!.setFirstPersonMoveSpeed(12);
    return window.terrainDebug!.getFirstPerson();
  });
  expect(adjusted.eyeHeight).toBe(2.25);
  expect(adjusted.moveSpeed).toBe(12);
  expect(adjusted.position[1]).toBeCloseTo(adjusted.groundHeight! + 2.25, 5);

  await page.keyboard.down("KeyW");
  await page.waitForTimeout(180);
  await page.keyboard.up("KeyW");
  const moved = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
  expect(moved.position[0]).not.toBe(initial.position[0]);
  expect(moved.position[1]).toBeCloseTo(moved.groundHeight! + 2.25, 5);
});

test.describe("Grasslands authored scene", () => {
  test.use({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });

  test("shares terrain diagnostics and reproducible camera poses", async ({ page }) => {
    await page.goto("/demos/terrain/grasslands/index.html?pose=source");
    await expect(page.locator("#status")).toContainText(
      "ready · 9 terrain tiles · 291,069 surface instances · 64 architecture placements · 8 sky clouds",
      { timeout: 120_000 }
    );
    await expect(page.locator('[aria-label="Grasslands terrain inspector"]')).toBeVisible();
    for (const title of [
      "Rendering / 渲染",
      "Terrain / 地形",
      "Surface / 地表",
      "Scene / 场景复刻",
      "Camera / 相机",
      "Composition / 场景构成",
      "Lighting / 光照",
      "Cloud & fog / 云雾"
    ]) {
      const folder = page.locator(".debug-inspector .title").filter({ hasText: title });
      await folder.scrollIntoViewIfNeeded();
      await expect(folder).toBeVisible();
      await expect(folder.locator("..")).not.toHaveClass(/closed/);
    }

    await page.evaluate(() => {
      window.terrainDebug!.setView("dual-factor");
      window.terrainDebug!.setView("surface");
      window.terrainDebug!.setMaterialTuning({ dualScaling: { enabled: true } });
    });
    expect(await page.evaluate(() => window.terrainDebug!.getTuning().material.dualScaling.enabled)).toBe(true);

    const originalCamera = await page.evaluate(() => window.terrainDebug!.getCamera());
    const movedCamera = await page.evaluate((camera) => {
      window.terrainDebug!.setCamera({
        ...camera,
        position: [camera.position[0] + 2, camera.position[1], camera.position[2] - 3],
        fieldOfView: camera.fieldOfView + 1
      });
      return window.terrainDebug!.getCamera();
    }, originalCamera);
    expect(movedCamera.position[0]).toBeCloseTo(originalCamera.position[0] + 2, 5);
    expect(movedCamera.position[2]).toBeCloseTo(originalCamera.position[2] - 3, 5);
    expect(movedCamera.rotation).toEqual(originalCamera.rotation);
    expect(movedCamera.fieldOfView).toBeCloseTo(originalCamera.fieldOfView + 1, 5);
    await page.evaluate((camera) => {
      window.terrainDebug!.setCamera(camera);
      window.terrainDebug!.resetTuning();
    }, originalCamera);

    const cameraOutput = page
      .locator(".debug-inspector li.cr.function")
      .filter({ hasText: "Output camera pose / 输出相机姿态" });
    await cameraOutput.scrollIntoViewIfNeeded();
    await cameraOutput.click();
    await expect(page.locator(".debug-inspector__readout").filter({ hasText: '"position"' })).toBeVisible();
  });

  test("matches deterministic surface, atmosphere, cloud, and architecture contracts", async ({ page }, testInfo) => {
    test.setTimeout(600_000);
    const pageErrors: string[] = [];
    const consoleErrors: string[] = [];
    page.on("pageerror", (error) => pageErrors.push(error.message));
    page.on("console", (message) => {
      if (message.type() === "error" || /INVALID_OPERATION|program not valid/i.test(message.text())) {
        consoleErrors.push(message.text());
      }
    });
    await installShaderDiagnostics(page);

    await page.goto("/demos/terrain/grasslands/index.html?pose=source");
    await expect(page.locator("#status")).toContainText(
      "ready · 9 terrain tiles · 291,069 surface instances · 64 architecture placements · 8 sky clouds",
      { timeout: 120_000 }
    );
    const firstPerson = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
    expect(firstPerson).toMatchObject({ active: true, eyeHeight: 1.7, moveSpeed: 8 });
    expect(firstPerson.groundHeight).toBeDefined();
    expect(firstPerson.position[1]).toBeCloseTo(firstPerson.groundHeight! + 1.7, 5);
    expect(firstPerson.forward[0]).toBeCloseTo(-0.1849809, 5);
    expect(firstPerson.forward[1]).toBeCloseTo(0, 5);
    expect(firstPerson.forward[2]).toBeCloseTo(-0.9827429, 5);

    const adjustedFirstPerson = await page.evaluate(() => {
      window.terrainDebug!.setFirstPersonEyeHeight(2.25);
      window.terrainDebug!.setFirstPersonMoveSpeed(12);
      return window.terrainDebug!.getFirstPerson();
    });
    expect(adjustedFirstPerson).toMatchObject({ active: true, eyeHeight: 2.25, moveSpeed: 12 });
    expect(adjustedFirstPerson.position[1]).toBeCloseTo(adjustedFirstPerson.groundHeight! + 2.25, 5);
    await page.evaluate(() => {
      window.terrainDebug!.setFirstPersonEyeHeight(1.7);
      window.terrainDebug!.setFirstPersonMoveSpeed(8);
    });

    await expect
      .poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().transitioningRanges))
      .toBe(0);
    const surface = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(surface.totalInstances).toBe(291_069);
    expect(surface.totalRanges).toBe(1_344);
    expect(surface.categoryCounts).toEqual({
      grass: 254_518,
      flower: 18_052,
      shrub: 492,
      tree: 14_878,
      rock: 3_129,
      cliff: 0
    });
    expect(surface.categoryCounts.tree + surface.categoryCounts.shrub).toBe(15_370);
    expect(surface.impostorInstances).toBe(14_367);
    expect(surface.visibleInstances).toBeGreaterThan(0);
    expect(surface.visibleRanges).toBeLessThan(surface.totalRanges);
    expect(surface.lodCounts.slice(1).some((count) => count > 0)).toBe(true);
    expect(await page.evaluate(() => window.grasslandsDebug!.inspectArchitecture())).toEqual({
      placements: 64,
      renderers: 77
    });

    const cloudStart = await page.evaluate(() => window.grasslandsDebug!.inspectClouds());
    expect(cloudStart).toMatchObject({
      visible: true,
      animation: true,
      authoredInstances: 27,
      instances: 8,
      drawGroups: 2
    });
    const sourceContracts = await page.evaluate(async () => {
      const [surfaceManifest, sceneLayout] = await Promise.all([
        fetch("/demos/terrain/data/grasslands/surface-manifest.json").then((response) => response.json()),
        fetch("/demos/terrain/data/grasslands/scene-layout.json").then((response) => response.json())
      ]);
      return {
        surfaceColorSpace: surfaceManifest.colorSpace,
        invertedWindBaseLock: surfaceManifest.materials
          .filter((material: { wind: { baseLock: boolean } }) => material.wind.baseLock)
          .every((material: { wind: { baseLockUvInverted: boolean } }) => material.wind.baseLockUvInverted),
        vegetationTranslucency: Array.from(
          new Set(
            surfaceManifest.materials
              .filter((material: { kind: string }) => material.kind === "vegetation")
              .map((material: { translucencyModel: string }) => material.translucencyModel)
          )
        ),
        architectureColorSpace: sceneLayout.architecture.colorSpace,
        cloudPresets: sceneLayout.clouds.map((cloud: { preset: number }) => cloud.preset)
      };
    });
    expect(sourceContracts).toEqual({
      surfaceColorSpace: "linear",
      invertedWindBaseLock: true,
      vegetationTranslucency: ["unity-additive-albedo"],
      architectureColorSpace: "linear",
      cloudPresets: [3, 2, 2, 2, 1, 1, 3, 0, 0, 0, 2, 2, 0, 1, 0, 0, 0, 2, 2, 0, 2, 1, 3, 0, 2, 2, 0]
    });
    await page.waitForTimeout(250);
    expect((await page.evaluate(() => window.grasslandsDebug!.inspectClouds().time))).toBeGreaterThan(cloudStart.time);
    await page.evaluate(() => window.grasslandsDebug!.setScene({ animation: false }));
    const frozenCloudTime = await page.evaluate(() => window.grasslandsDebug!.inspectClouds().time);
    await page.waitForTimeout(250);
    expect(await page.evaluate(() => window.grasslandsDebug!.inspectClouds().time)).toBe(frozenCloudTime);

    await page.evaluate(() => window.grasslandsDebug!.setScene({ architecture: false, clouds: false }));
    expect(await page.evaluate(() => window.grasslandsDebug!.getScene())).toMatchObject({
      architecture: false,
      clouds: false
    });
    expect(await page.evaluate(() => window.grasslandsDebug!.inspectClouds())).toMatchObject({ visible: false });
    await page.evaluate(() =>
      window.grasslandsDebug!.setScene({
        architecture: true,
        clouds: true,
        animation: true
      })
    );

    await page.evaluate(() =>
      window.grasslandsDebug!.setScene({
        directLight: false,
        environment: false,
        cloudShadows: false
      })
    );
    expect(await page.evaluate(() => window.grasslandsDebug!.getScene())).toMatchObject({
      directLight: false,
      environment: false,
      cloudShadows: false
    });
    await page.evaluate(() =>
      window.grasslandsDebug!.setScene({
        directLight: true,
        environment: true,
        cloudShadows: true
      })
    );

    await page.evaluate(() => {
      window.grasslandsDebug!.setScene({ animation: false });
      window.terrainDebug!.setSurface({ wind: { enabled: false } });
    });
    expect(await page.evaluate(() => window.terrainDebug!.inspectSurface().tuning.wind.enabled)).toBe(false);
    await page.evaluate(() => {
      window.grasslandsDebug!.setScene({ animation: true });
      window.terrainDebug!.setSurface({ wind: { enabled: true } });
    });

    const submitted = await page.evaluate(() => ({
      drawCalls: window.__terrainDrawCalls,
      triangles: window.__terrainTriangles,
      instances: window.__terrainSubmittedInstances,
      surface: window.terrainDebug!.inspectSurface(),
      diagnostics: window.__terrainShaderDiagnostics,
      hasInstancedDraw: window.__surfaceInstanceDraws.some((count) => count > 1)
    }));
    expect(submitted.drawCalls).toBeGreaterThan(0);
    expect(submitted.triangles).toBeGreaterThan(0);
    expect(submitted.instances).toBeGreaterThan(0);
    expect(submitted.diagnostics).toEqual([]);
    expect(submitted.hasInstancedDraw).toBe(true);
    const windVertexShaders = await page.evaluate(() =>
      window.__surfaceGeneratedShaders.filter(
        (shader) =>
          shader.stage === "vertex" &&
          shader.source.includes("material_WindBaseLockUvInverted") &&
          /1\.0\s*-\s*TEXCOORD_0\.y/.test(shader.source)
      )
    );
    expect(windVertexShaders.some((shader) => shader.source.includes("scene_ShadowBias"))).toBe(true);
    expect(windVertexShaders.some((shader) => !shader.source.includes("scene_ShadowBias"))).toBe(true);
    await testInfo.attach("grasslands-submission-snapshot", {
      body: JSON.stringify(submitted, null, 2),
      contentType: "application/json"
    });
    await attachScreenshot(page, testInfo, "grasslands-source-camera");

    const beforeMove = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
    await page.keyboard.down("KeyW");
    await page.waitForTimeout(180);
    await page.keyboard.up("KeyW");
    const afterMove = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
    expect(Math.hypot(
      afterMove.position[0] - beforeMove.position[0],
      afterMove.position[2] - beforeMove.position[2]
    )).toBeGreaterThan(0);
    expect(afterMove.position[1]).toBeCloseTo(afterMove.groundHeight! + 1.7, 4);

    expect(pageErrors).toEqual([]);
    expect(consoleErrors).toEqual([]);
  });
});

test.describe("Grasslands visual baseline", () => {
  test.use({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 2 });

  test("captures stable and animated source-camera frames", async ({ page }, testInfo) => {
    test.skip(!captureScreenshots, "Set TERRAIN_E2E_CAPTURE=1 to record the DPR 2 visual baseline.");
    test.setTimeout(900_000);
    await page.goto("/demos/terrain/grasslands/index.html?pose=source");
    await expect(page.locator("#status")).toContainText(
      "ready · 9 terrain tiles · 291,069 surface instances · 64 architecture placements · 8 sky clouds",
      { timeout: 120_000 }
    );
    await page.evaluate(() => {
      window.grasslandsDebug!.setScene({ animation: false });
      window.terrainDebug!.setSurface({ wind: { enabled: false } });
    });
    const canvas = page.locator("#canvas");
    const staticFrame = await canvas.screenshot();
    await page.waitForTimeout(250);
    expect(await canvas.screenshot()).toEqual(staticFrame);

    await page.evaluate(() => {
      window.grasslandsDebug!.setScene({ animation: true });
      window.terrainDebug!.setSurface({ wind: { enabled: true } });
    });
    await page.waitForTimeout(500);
    const animatedFrame = await canvas.screenshot();
    expect(animatedFrame).not.toEqual(staticFrame);
    await testInfo.attach("grasslands-source-static-dpr2", { body: staticFrame, contentType: "image/png" });
    await testInfo.attach("grasslands-source-animated-dpr2", { body: animatedFrame, contentType: "image/png" });
  });
});

async function installShaderDiagnostics(page: Page): Promise<void> {
  await page.addInitScript(() => {
    const diagnostics: ShaderDiagnostic[] = [];
    Object.defineProperty(window, "__terrainShaderDiagnostics", { value: diagnostics });
    Object.defineProperty(window, "__terrainDrawCalls", { value: 0, writable: true });
    Object.defineProperty(window, "__terrainTriangles", { value: 0, writable: true });
    Object.defineProperty(window, "__terrainSubmittedInstances", { value: 0, writable: true });
    const surfaceInstanceDraws: number[] = [];
    Object.defineProperty(window, "__surfaceInstanceDraws", { value: surfaceInstanceDraws });
    const generatedShaders: GeneratedShaderSource[] = [];
    Object.defineProperty(window, "__terrainGeneratedShaders", { value: generatedShaders });
    const generatedSurfaceShaders: GeneratedShaderSource[] = [];
    Object.defineProperty(window, "__surfaceGeneratedShaders", { value: generatedSurfaceShaders });
    const prototype = WebGL2RenderingContext.prototype;
    const shaderSources = new WeakMap<WebGLShader, string>();
    const shaderSource = prototype.shaderSource;
    prototype.shaderSource = function (shader, source): void {
      shaderSources.set(shader, source);
      if (source.includes("material_RegionMap")) {
        generatedShaders.push({
          stage: this.getShaderParameter(shader, this.SHADER_TYPE) === this.VERTEX_SHADER ? "vertex" : "fragment",
          source
        });
      }
      if (source.includes("INSTANCE_POSITION_HASH") || source.includes("material_DebugView")) {
        generatedSurfaceShaders.push({
          stage: this.getShaderParameter(shader, this.SHADER_TYPE) === this.VERTEX_SHADER ? "vertex" : "fragment",
          source
        });
      }
      shaderSource.call(this, shader, source);
    };
    const compileShader = prototype.compileShader;
    prototype.compileShader = function (shader): void {
      compileShader.call(this, shader);
      if (!this.getShaderParameter(shader, this.COMPILE_STATUS)) {
        const stage = this.getShaderParameter(shader, this.SHADER_TYPE) === this.VERTEX_SHADER ? "vertex" : "fragment";
        diagnostics.push({
          stage,
          log: this.getShaderInfoLog(shader) ?? "Unknown shader compile error",
          source: shaderSources.get(shader)
        });
      }
    };
    const linkProgram = prototype.linkProgram;
    prototype.linkProgram = function (program): void {
      linkProgram.call(this, program);
      if (!this.getProgramParameter(program, this.LINK_STATUS)) {
        diagnostics.push({ stage: "link", log: this.getProgramInfoLog(program) ?? "Unknown shader link error" });
      }
    };
    const drawElements = prototype.drawElements;
    prototype.drawElements = function (...args): void {
      window.__terrainDrawCalls++;
      window.__terrainTriangles += args[1] / 3;
      drawElements.apply(this, args);
    };
    const drawElementsInstanced = prototype.drawElementsInstanced;
    prototype.drawElementsInstanced = function (...args): void {
      window.__terrainDrawCalls++;
      window.__terrainTriangles += (args[1] / 3) * args[4];
      window.__terrainSubmittedInstances += args[4];
      if (surfaceInstanceDraws.length < 100_000) surfaceInstanceDraws.push(args[4]);
      drawElementsInstanced.apply(this, args);
    };
  });
}

async function readFrameStats(page: Page): Promise<{ uniqueColors: number }> {
  return page.evaluate(
    () =>
      new Promise((resolve) => {
        requestAnimationFrame(() => {
          const canvas = document.querySelector<HTMLCanvasElement>("#canvas")!;
          const gl = canvas.getContext("webgl2")!;
          const pixels = new Uint8Array(canvas.width * canvas.height * 4);
          gl.readPixels(0, 0, canvas.width, canvas.height, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
          const colors = new Set<number>();
          const stepX = Math.max(1, Math.floor(canvas.width / 80));
          const stepY = Math.max(1, Math.floor(canvas.height / 45));
          for (let y = 0; y < canvas.height && colors.size < 256; y += stepY) {
            for (let x = 0; x < canvas.width && colors.size < 256; x += stepX) {
              const offset = (y * canvas.width + x) * 4;
              colors.add((pixels[offset] << 16) | (pixels[offset + 1] << 8) | pixels[offset + 2]);
            }
          }
          resolve({ uniqueColors: colors.size });
        });
      })
  );
}

async function readFrameFingerprint(page: Page): Promise<number> {
  return page.evaluate(
    () =>
      new Promise((resolve) => {
        requestAnimationFrame(() => {
          const canvas = document.querySelector<HTMLCanvasElement>("#canvas")!;
          const gl = canvas.getContext("webgl2")!;
          const pixels = new Uint8Array(canvas.width * canvas.height * 4);
          gl.readPixels(0, 0, canvas.width, canvas.height, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
          let hash = 2_166_136_261;
          const stepX = Math.max(1, Math.floor(canvas.width / 80));
          const stepY = Math.max(1, Math.floor(canvas.height / 45));
          for (let y = 0; y < canvas.height; y += stepY) {
            for (let x = 0; x < canvas.width; x += stepX) {
              const offset = (y * canvas.width + x) * 4;
              hash = Math.imul(hash ^ pixels[offset], 16_777_619);
              hash = Math.imul(hash ^ pixels[offset + 1], 16_777_619);
              hash = Math.imul(hash ^ pixels[offset + 2], 16_777_619);
            }
          }
          resolve(hash >>> 0);
        });
      })
  );
}

async function readCompositedFrameFingerprint(page: Page): Promise<number> {
  const pixels = await page.screenshot({ type: "png" });
  let hash = 2_166_136_261;
  for (const pixel of pixels) {
    hash = Math.imul(hash ^ pixel, 16_777_619);
  }
  return hash >>> 0;
}

async function attachScreenshot(page: Page, testInfo: TestInfo, name: string): Promise<void> {
  if (!captureScreenshots) {
    return;
  }
  const screenshotPath = testInfo.outputPath(`${name}.png`);
  await page.screenshot({ path: screenshotPath });
  await testInfo.attach(name, { path: screenshotPath, contentType: "image/png" });
}
