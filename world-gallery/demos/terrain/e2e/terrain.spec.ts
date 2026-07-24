import { expect, test, type Browser, type Page, type TestInfo } from "@playwright/test";

const captureScreenshots = process.env.TERRAIN_E2E_CAPTURE === "1";

interface ShaderDiagnostic {
  readonly stage: "vertex" | "fragment" | "link";
  readonly log: string;
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
    /** Terrain shaders after Galacean's ShaderLab-to-GLSL lowering. */
    __terrainGeneratedShaders: GeneratedShaderSource[];
  }
}

test("backend selector creates a new engine after a full document navigation", async ({ page }) => {
  const errors = collectRuntimeErrors(page);
  await page.goto("/demos/terrain/index.html?backend=webgl2&pose=first-person");
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments");
  expect(await page.evaluate(() => window.terrainBackend)).toBe("webgl2");

  await page.evaluate(() => {
    document.documentElement.dataset.backendSwitchSentinel = "old-document";
  });
  await Promise.all([
    page.waitForURL((url) => url.searchParams.get("backend") === "webgpu"),
    page.locator("#backend").selectOption("webgpu")
  ]);
  await expect(page.locator("#status")).toContainText(
    "ready · 3 regions · 144 clipmap segments · 56 surface instances · webgpu"
  );

  expect(await page.evaluate(() => document.documentElement.dataset.backendSwitchSentinel)).toBeUndefined();
  expect(await page.evaluate(() => window.terrainBackend)).toBe("webgpu");
  expect(errors).toEqual([]);
});

test("terrain and trees render equivalently on WebGL2 and WebGPU", async (
  { browser, baseURL },
  testInfo
) => {
  expect(baseURL).toBeDefined();
  const webGL2 = await captureBackendScene(browser, baseURL!, "webgl2");
  const webGPU = await captureBackendScene(browser, baseURL!, "webgpu");

  expect(webGL2.errors).toEqual([]);
  expect(webGPU.errors).toEqual([]);
  expect(webGL2.shaderArtifactRequests).toContain("Terrain.shaderc");
  expect(webGPU.shaderArtifactRequests).toContain("Terrain.wgslc");
  expect(webGPU.surface).toEqual(webGL2.surface);
  expect(webGPU.surface).toMatchObject({
    enabled: true,
    counts: { tree: 46, "tree-tall": 10 },
    instanceCount: 56,
    instancing: "engine-auto"
  });

  await testInfo.attach("terrain-webgl2-first-person", {
    body: webGL2.screenshot,
    contentType: "image/png"
  });
  await testInfo.attach("terrain-webgpu-first-person", {
    body: webGPU.screenshot,
    contentType: "image/png"
  });
  const comparison = await compareScreenshots(browser, webGL2.screenshot, webGPU.screenshot);
  expect(comparison.meanAbsoluteError).toBeLessThan(1.5);
  expect(comparison.largeDifferenceRatio).toBeLessThan(0.02);
});

test("terrain backend selects its single-target artifact while runtime codegen remains measurable", async (
  { browser, baseURL },
  testInfo
) => {
  expect(baseURL).toBeDefined();
  const precompiledWebGL2 = await measureTerrainShaderRegistration(browser, baseURL!, "webgl2", "precompiled");
  const precompiledWebGPU = await measureTerrainShaderRegistration(browser, baseURL!, "webgpu", "precompiled");
  const runtimeWebGL2 = await measureTerrainShaderRegistration(browser, baseURL!, "webgl2", "runtime");
  const runtimeWebGPU = await measureTerrainShaderRegistration(browser, baseURL!, "webgpu", "runtime");

  expect(precompiledWebGL2).toMatchObject({ mode: "precompiled", platforms: ["gles100"] });
  expect(precompiledWebGPU).toMatchObject({ mode: "precompiled", platforms: ["wgsl"] });
  expect(runtimeWebGL2).toMatchObject({ mode: "runtime", platforms: ["gles100"] });
  expect(runtimeWebGPU).toMatchObject({ mode: "runtime", platforms: ["wgsl"] });
  expect(runtimeWebGL2.registrationMs).toBeGreaterThan(precompiledWebGL2.registrationMs);
  expect(runtimeWebGPU.registrationMs).toBeGreaterThan(precompiledWebGPU.registrationMs);

  const result = {
    metric: "selected artifact or runtime Shader.create registrationMs; dynamic raw-module fetch is reported separately",
    webgl2: { precompiled: precompiledWebGL2, runtime: runtimeWebGL2 },
    webgpu: { precompiled: precompiledWebGPU, runtime: runtimeWebGPU }
  };
  console.info("[terrain-shader-registration]", JSON.stringify(result));
  await testInfo.attach("terrain-shader-registration", {
    body: JSON.stringify(result, null, 2),
    contentType: "application/json"
  });
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
  await expect(page.locator(".debug-inspector__preview img")).toHaveCount(4);
  expect(await page.locator(".debug-inspector__preview img").evaluateAll((images) => images.every((image) => {
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

function collectRuntimeErrors(page: Page): string[] {
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(`pageerror: ${error.message}`));
  page.on("console", (message) => {
    if (message.type() === "error") {
      errors.push(`console: ${message.text()}`);
    }
  });
  page.on("requestfailed", (request) => {
    errors.push(`request: ${request.url()} ${request.failure()?.errorText ?? ""}`);
  });
  return errors;
}

async function measureTerrainShaderRegistration(
  browser: Browser,
  baseURL: string,
  backend: "webgl2" | "webgpu",
  shader: "precompiled" | "runtime"
): Promise<TerrainShaderStartup> {
  const page = await browser.newPage({ viewport: { width: 1024, height: 576 } });
  const errors = collectRuntimeErrors(page);
  const shaderQuery = shader === "runtime" ? "&shader=runtime" : "";
  await page.goto(`${baseURL}/demos/terrain/index.html?backend=${backend}${shaderQuery}`);
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments");
  const startup = await page.evaluate(() => window.terrainDebug!.getShaderStartup());
  expect(errors).toEqual([]);
  await page.close();
  return startup;
}

async function captureBackendScene(
  browser: Browser,
  baseURL: string,
  backend: "webgl2" | "webgpu"
): Promise<{
  screenshot: Buffer;
  surface: ReturnType<NonNullable<Window["terrainDebug"]>["getSurface"]>;
  errors: string[];
  shaderArtifactRequests: string[];
}> {
  const page = await browser.newPage({ viewport: { width: 1024, height: 576 } });
  const errors = collectRuntimeErrors(page);
  const shaderArtifactRequests: string[] = [];
  page.on("request", (request) => {
    const pathname = new URL(request.url()).pathname;
    if (pathname.endsWith(".shaderc") || pathname.endsWith(".wgslc")) {
      shaderArtifactRequests.push(pathname.split("/").at(-1)!);
    }
  });
  await page.goto(`${baseURL}/demos/terrain/index.html?backend=${backend}&pose=first-person`);
  await expect(page.locator("#status")).toContainText(
    `ready · 3 regions · 144 clipmap segments · 56 surface instances · ${backend}`
  );
  if (backend === "webgpu") {
    expect(await page.evaluate(() => "gpu" in navigator)).toBe(true);
  }
  await page.evaluate(
    () =>
      new Promise<void>((resolve) =>
        requestAnimationFrame(() => requestAnimationFrame(() => resolve()))
      )
  );
  await page.waitForTimeout(2000);
  await page.addStyleTag({
    content: "#status,#backend-control,.debug-inspector{display:none!important}"
  });
  const surface = await page.evaluate(() => window.terrainDebug!.getSurface());
  const screenshot = await page.screenshot({ type: "png" });
  await page.close();
  return { screenshot, surface, errors, shaderArtifactRequests };
}

async function compareScreenshots(
  browser: Browser,
  baseline: Buffer,
  candidate: Buffer
): Promise<{ meanAbsoluteError: number; largeDifferenceRatio: number }> {
  const page = await browser.newPage();
  const dataUrls = [baseline, candidate].map(
    (image) => `data:image/png;base64,${image.toString("base64")}`
  );
  const result = await page.evaluate(async ([baselineUrl, candidateUrl]) => {
    const loadImage = (source: string): Promise<HTMLImageElement> =>
      new Promise((resolve, reject) => {
        const image = new Image();
        image.onload = () => resolve(image);
        image.onerror = reject;
        image.src = source;
      });
    const [baselineImage, candidateImage] = await Promise.all([
      loadImage(baselineUrl),
      loadImage(candidateUrl)
    ]);
    if (
      baselineImage.width !== candidateImage.width ||
      baselineImage.height !== candidateImage.height
    ) {
      throw new Error("Backend screenshots have different dimensions.");
    }

    const canvas = new OffscreenCanvas(baselineImage.width, baselineImage.height);
    const context = canvas.getContext("2d")!;
    context.drawImage(baselineImage, 0, 0);
    const baselinePixels = context.getImageData(
      0,
      0,
      baselineImage.width,
      baselineImage.height
    ).data;
    context.clearRect(0, 0, canvas.width, canvas.height);
    context.drawImage(candidateImage, 0, 0);
    const candidatePixels = context.getImageData(
      0,
      0,
      candidateImage.width,
      candidateImage.height
    ).data;

    let absoluteError = 0;
    let largeDifferencePixels = 0;
    const pixelCount = baselinePixels.length / 4;
    for (let offset = 0; offset < baselinePixels.length; offset += 4) {
      let maximumChannelDifference = 0;
      for (let channel = 0; channel < 3; channel++) {
        const difference = Math.abs(
          baselinePixels[offset + channel] - candidatePixels[offset + channel]
        );
        absoluteError += difference;
        maximumChannelDifference = Math.max(maximumChannelDifference, difference);
      }
      if (maximumChannelDifference > 20) {
        largeDifferencePixels++;
      }
    }
    return {
      meanAbsoluteError: absoluteError / (pixelCount * 3),
      largeDifferenceRatio: largeDifferencePixels / pixelCount
    };
  }, dataUrls);
  await page.close();
  return result;
}

async function installShaderDiagnostics(page: Page): Promise<void> {
  await page.addInitScript(() => {
    const diagnostics: ShaderDiagnostic[] = [];
    Object.defineProperty(window, "__terrainShaderDiagnostics", { value: diagnostics });
    Object.defineProperty(window, "__terrainDrawCalls", { value: 0, writable: true });
    const generatedShaders: GeneratedShaderSource[] = [];
    Object.defineProperty(window, "__terrainGeneratedShaders", { value: generatedShaders });
    const prototype = WebGL2RenderingContext.prototype;
    const shaderSource = prototype.shaderSource;
    prototype.shaderSource = function (shader, source): void {
      if (source.includes("material_RegionMap")) {
        generatedShaders.push({
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
        diagnostics.push({ stage, log: this.getShaderInfoLog(shader) ?? "Unknown shader compile error" });
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
      drawElements.apply(this, args);
    };
    const drawElementsInstanced = prototype.drawElementsInstanced;
    prototype.drawElementsInstanced = function (...args): void {
      window.__terrainDrawCalls++;
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
