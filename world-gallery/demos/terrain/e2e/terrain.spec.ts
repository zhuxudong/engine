import { expect, test, type Page, type TestInfo } from "@playwright/test";
import { readFileSync } from "node:fs";
import path from "node:path";
import type { TerrainFirstPersonSnapshot } from "../src/TerrainFirstPersonController";
import type { TerrainData } from "../src/data/TerrainData";
import { TerrainGroundSampler } from "../src/data/TerrainGroundSampler";
import type {
  TerrainCameraSnapshot,
  TerrainDebugViewName,
  TerrainProbeSnapshot
} from "../src/debug/TerrainDebugContract";
import { compileSurface } from "../src/surface/SurfaceCompiler";
import type { SurfaceCategory, SurfaceCompileInput, SurfaceTerrainSample } from "../src/surface/SurfaceContract";

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
        constraints: {
          height: [0, 32],
          slope: [0, 0.75],
          terrainLayers: [0],
          minimumLayerWeight: 0.5,
          excludeHoles: true
        },
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
        constraints: {
          height: [0, 32],
          slope: [0, 1],
          terrainLayers: [0, 1],
          minimumLayerWeight: 0.5,
          excludeHoles: true
        },
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

  const overlayRule = {
    ...input.rules[0],
    constraints: {
      ...input.rules[0].constraints,
      terrainLayers: [1],
      minimumLayerWeight: 0.5
    }
  } as const;
  const compileOverlay = (blend: number) =>
    compileSurface({
      ...input,
      rules: [overlayRule],
      explicitPlacements: [],
      terrain: {
        sample: () => ({
          height: 1,
          slope: 0,
          control: (1 << 22) | (blend << 14),
          hole: false
        })
      }
    });
  expect(compileOverlay(1).instances).toHaveLength(0);
  expect(compileOverlay(200).instances.length).toBeGreaterThan(0);
});

test("first-person ground sampling follows the active terrain background", () => {
  const terrain = {
    regionSize: 1024,
    vertexSpacing: 1,
    getRegionLayer: (x: number, z: number) => (x === 0 && z === 0 ? 0 : -1),
    sampleHeightInterpolated: (x: number, z: number) => (x >= 0 && x < 1024 && z >= 0 && z < 1024 ? 10 : undefined)
  } as unknown as TerrainData;
  const ground = new TerrainGroundSampler(terrain, "noise", {
    fragmentNormals: false,
    regionBlend: 0.3,
    maxOctaves: 8,
    minOctaves: 4,
    lodDistance: 8000,
    scale: 4,
    height: 300,
    offset: [0, 0, 0]
  });

  expect(ground.sampleHeightInterpolated(512, 512)).toBe(10);
  expect(ground.sampleHeightInterpolated(2048, 2048)).toBeDefined();
  ground.setWorldNoiseTuning({ height: 0, offset: [0, 1, 0] });
  expect(ground.sampleHeightInterpolated(2048, 2048)).toBe(100);
  ground.setBackground("flat");
  expect(ground.sampleHeightInterpolated(2048, 2048)).toBe(0);
  ground.setBackground("none");
  expect(ground.sampleHeightInterpolated(2048, 2048)).toBeUndefined();
});

test("Grasslands control maps preserve packed material semantics", () => {
  const manifestPath = path.resolve(__dirname, "../data/grasslands/terrain-manifest.json");
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8")) as {
    readonly terrain: {
      readonly regionSize: number;
      readonly regions: readonly { readonly controlMap: string }[];
    };
  };
  const baseLayers = new Set<number>();
  const overlayLayers = new Set<number>();
  const angleIndices = new Set<number>();
  const scaleIndices = new Set<number>();
  let sampleCount = 0;
  let holes = 0;
  let navigation = 0;
  let autoshader = 0;

  for (const region of manifest.terrain.regions) {
    const bytes = readFileSync(path.resolve(path.dirname(manifestPath), region.controlMap));
    const controls = new Uint32Array(bytes.buffer, bytes.byteOffset, bytes.byteLength / 4);
    sampleCount += controls.length;
    for (const raw of controls) {
      baseLayers.add(raw >>> 27);
      overlayLayers.add((raw >>> 22) & 0x1f);
      angleIndices.add((raw >>> 10) & 0xf);
      scaleIndices.add((raw >>> 7) & 0x7);
      holes += Number((raw & 0x4) !== 0);
      navigation += Number((raw & 0x2) !== 0);
      autoshader += Number((raw & 0x1) !== 0);
    }
  }

  expect(sampleCount).toBe(9 * manifest.terrain.regionSize * manifest.terrain.regionSize);
  expect([...baseLayers].sort()).toEqual([0, 1, 2, 3, 5, 6]);
  expect([...overlayLayers].sort()).toEqual([0, 1, 2, 3, 5, 6]);
  expect([...angleIndices]).toEqual([0]);
  expect([...scaleIndices]).toEqual([0]);
  expect({ holes, navigation, autoshader }).toEqual({ holes: 0, navigation: 0, autoshader: 0 });
});

test("Realistic control maps preserve packed material semantics", () => {
  const manifestPath = path.resolve(__dirname, "../data/manifest.json");
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8")) as {
    readonly terrain: {
      readonly regionSize: number;
      readonly regions: readonly { readonly controlMap: string }[];
    };
  };
  const baseLayers = new Set<number>();
  const overlayLayers = new Set<number>();
  const angleIndices = new Set<number>();
  const scaleIndices = new Set<number>();
  let sampleCount = 0;
  let holes = 0;
  let navigation = 0;
  let autoshader = 0;

  for (const region of manifest.terrain.regions) {
    const bytes = readFileSync(path.resolve(path.dirname(manifestPath), region.controlMap));
    const controls = new Uint32Array(bytes.buffer, bytes.byteOffset, bytes.byteLength / 4);
    sampleCount += controls.length;
    for (const raw of controls) {
      baseLayers.add(raw >>> 27);
      overlayLayers.add((raw >>> 22) & 0x1f);
      angleIndices.add((raw >>> 10) & 0xf);
      scaleIndices.add((raw >>> 7) & 0x7);
      holes += Number((raw & 0x4) !== 0);
      navigation += Number((raw & 0x2) !== 0);
      autoshader += Number((raw & 0x1) !== 0);
    }
  }

  expect(sampleCount).toBe(3 * manifest.terrain.regionSize * manifest.terrain.regionSize);
  expect([...baseLayers].sort()).toEqual([0, 1]);
  expect([...overlayLayers].sort()).toEqual([0, 1, 3]);
  expect([...angleIndices]).toEqual([0]);
  expect([...scaleIndices]).toEqual([0]);
  expect({ holes, navigation, autoshader }).toEqual({
    holes: 905,
    navigation: 281_281,
    autoshader: 3_131_514
  });
});

test("Grasslands terrain clips hidden vertices without NaN projection", async ({ page }) => {
  test.setTimeout(180_000);
  await installShaderDiagnostics(page);
  await page.goto("/demos/terrain/grasslands/index.html");
  await expect(page.locator("#status")).toContainText(
    "ready · 9 terrain tiles · 291,069 surface instances · 64 architecture placements · 8 sky clouds",
    { timeout: 120_000 }
  );

  const cameras = [
    {
      position: [1469.862549, 17.485165, 1714.755859],
      rotation: [0.04666, -0.065622, 0.003072, 0.996748],
      forward: [0.13053, 0.093421, -0.987033],
      fieldOfView: 50
    },
    {
      position: [1469.862549, 17.485165, 1714.755859],
      rotation: [0.045541, -0.141214, 0.006503, 0.98891],
      forward: [0.278703, 0.091909, -0.955969],
      fieldOfView: 50
    }
  ] satisfies readonly TerrainCameraSnapshot[];
  const fingerprints: number[] = [];
  for (const camera of cameras) {
    await page.evaluate(async (snapshot) => {
      window.terrainDebug!.setCamera(snapshot);
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    }, camera);
    fingerprints.push(await readFrameFingerprint(page));
  }
  expect(fingerprints[0]).not.toBe(fingerprints[1]);

  const shaders = await page.evaluate(() => window.__terrainGeneratedShaders);
  const vertexShaders = shaders.filter((shader) => shader.stage === "vertex");
  const fragmentShaders = shaders.filter((shader) => shader.stage === "fragment");
  expect(vertexShaders).not.toHaveLength(0);
  expect(fragmentShaders).not.toHaveLength(0);
  expect(vertexShaders.every((shader) => !shader.source.includes("sqrt(-1.0)"))).toBe(true);
  expect(vertexShaders.every((shader) => shader.source.includes("renderable"))).toBe(true);
  expect(fragmentShaders.every((shader) => /renderable\s*<\s*1\.0/.test(shader.source))).toBe(true);
  expect(await page.evaluate(() => window.__terrainShaderDiagnostics)).toEqual([]);
});

test.describe("terrain height/control data closure", () => {
  test.use({ viewport: { width: 513, height: 513 }, deviceScaleFactor: 1 });

  const demos = [
    {
      name: "Realistic",
      url: "/demos/terrain/index.html?fixture=control",
      ready: "ready · 3 regions · 144 clipmap segments",
      manifestPath: path.resolve(__dirname, "../data/manifest.json"),
      formalWorld: [512, -512] as const
    },
    {
      name: "Grasslands",
      url: "/demos/terrain/grasslands/index.html?fixture=control",
      ready: "ready · 9 terrain tiles · 291,069 surface instances",
      manifestPath: path.resolve(__dirname, "../data/grasslands/terrain-manifest.json"),
      formalWorld: [1500, 1500] as const
    }
  ] as const;

  for (const demo of demos) {
    test(`${demo.name} maps source texels through CPU, clipmap, and framebuffer`, async ({ page }) => {
      test.setTimeout(1_200_000);
      const pageErrors: string[] = [];
      const consoleErrors: string[] = [];
      page.on("pageerror", (error) => pageErrors.push(error.message));
      page.on("console", (message) => {
        if (message.type() === "error" || /INVALID_OPERATION|program not valid/i.test(message.text())) {
          consoleErrors.push(message.text());
        }
      });
      await installShaderDiagnostics(page);

      const formalSource = readTerrainSourceProbe(demo.manifestPath, demo.formalWorld[0], demo.formalWorld[1]);
      await page.goto(demo.url);
      await expect(page.locator("#status")).toContainText(demo.ready, { timeout: 180_000 });
      await expect.poll(() => page.evaluate(() => window.terrainDebug?.ready)).toBe(true);
      expect(
        await page.evaluate(() =>
          window.terrainDebug!.views.filter((view) =>
            [
              "height",
              "height-source",
              "region",
              "control-base",
              "control-overlay",
              "control-blend",
              "control-angle",
              "control-scale",
              "holes",
              "navigation",
              "autoshader"
            ].includes(view)
          )
        )
      ).toHaveLength(11);

      const formalCpu = await page.evaluate(
        ([worldX, worldZ]) => window.terrainDebug!.readProbe(worldX, worldZ),
        demo.formalWorld
      );
      expectProbeToMatchSource(formalCpu, formalSource);

      await prepareNumericTerrainReadback(page);
      const cameraForward = await page.evaluate(() => window.terrainDebug!.getCamera().forward);
      expect(cameraForward[0]).toBeCloseTo(0, 6);
      expect(cameraForward[1]).toBeCloseTo(-1, 6);
      expect(cameraForward[2]).toBeCloseTo(0, 6);

      const spacing = readTerrainVertexSpacing(demo.manifestPath);
      const formalControlWorld = [demo.formalWorld[0] + spacing * 0.25, demo.formalWorld[1] + spacing * 0.25] as const;
      const formalControlSource = readTerrainSourceProbe(demo.manifestPath, ...formalControlWorld);
      expectPixel(
        await readTerrainProbePixel(page, formalControlWorld, "height-source"),
        grayscale(heightDebugValue(formalControlSource.height)),
        `${demo.name} formal height source`
      );
      expectPixel(
        await readTerrainProbePixel(page, formalControlWorld, "region"),
        regionLayerColor(formalControlSource.region.layer),
        `${demo.name} formal region`
      );

      const formalControlCpu = await page.evaluate(
        ([worldX, worldZ]) => window.terrainDebug!.readProbe(worldX, worldZ),
        formalControlWorld
      );
      expectProbeToMatchSource(formalControlCpu, formalControlSource);
      await expectControlDebugPixels(page, formalControlWorld, formalControlSource.control, `${demo.name} formal`);

      const fixture = await page.evaluate(() => window.terrainDebug!.getControlFixture());
      expect(fixture).toBeDefined();
      expect(fixture!.cases.map(({ id }) => id)).toEqual(CONTROL_FIXTURE_EXPECTATIONS.map(({ id }) => id));
      for (const expected of CONTROL_FIXTURE_EXPECTATIONS) {
        const fixtureCase = fixture!.cases.find(({ id }) => id === expected.id);
        expect(fixtureCase, `${demo.name} missing fixture ${expected.id}`).toBeDefined();
        expect(fixtureCase!.probe.heightRaw).toBe(expected.heightRaw);
        expect(fixtureCase!.probe.control).toEqual(decodeControlOracle(expected.control));
      }

      const blend0 = fixture!.cases.find(({ id }) => id === "blend-0")!.probe;
      const blend128Navigation = fixture!.cases.find(({ id }) => id === "blend-128-navigation")!.probe;
      const blend255Autoshader = fixture!.cases.find(({ id }) => id === "blend-255-autoshader")!.probe;
      const hole = fixture!.cases.find(({ id }) => id === "hole")!.probe;

      await expectControlDebugPixels(
        page,
        blend0.world,
        decodeControlOracle(CONTROL_FIXTURE_EXPECTATIONS[0].control),
        `${demo.name} blend-0`
      );
      await expectControlDebugPixels(
        page,
        blend128Navigation.world,
        decodeControlOracle(CONTROL_FIXTURE_EXPECTATIONS[1].control),
        `${demo.name} blend-128-navigation`
      );
      await expectControlDebugPixels(
        page,
        blend255Autoshader.world,
        decodeControlOracle(CONTROL_FIXTURE_EXPECTATIONS[2].control),
        `${demo.name} blend-255-autoshader`
      );
      await expectControlDebugPixels(
        page,
        hole.world,
        decodeControlOracle(CONTROL_FIXTURE_EXPECTATIONS[3].control),
        `${demo.name} hole`
      );
      expectPixel(
        await readTerrainProbePixel(page, blend0.world, "height"),
        grayscale(heightDebugValue(blend0.height!)),
        `${demo.name} fixture height`
      );

      expect(pageErrors).toEqual([]);
      expect(consoleErrors).toEqual([]);
      expect(await page.evaluate(() => window.__terrainShaderDiagnostics)).toEqual([]);
      const debugFragments = await page.evaluate(() =>
        window.__terrainGeneratedShaders.filter(
          (shader) => shader.stage === "fragment" && shader.source.includes("material_DebugView")
        )
      );
      expect(debugFragments.length).toBeGreaterThan(0);
      expect(debugFragments.every((shader) => !shader.source.includes("color = fog("))).toBe(true);
    });
  }
});

test("terrain data, clipmap, and production shader stay coherent", async ({ page }, testInfo) => {
  test.setTimeout(1_200_000);
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
  const topLevelFolders = page.locator(".debug-inspector > ul > li.folder > .dg > ul > li.title");
  await expect(topLevelFolders).toHaveText(["Rendering / 渲染", "Terrain / 地形", "Surface / 地表"]);
  for (let index = 0; index < (await topLevelFolders.count()); index++) {
    await expect(topLevelFolders.nth(index).locator("..")).toHaveClass(/closed/);
  }
  const terrainFolderTitle = page.locator(".debug-inspector .title").filter({ hasText: "Terrain / 地形" });
  await terrainFolderTitle.click();
  await expect(terrainFolderTitle.locator("..")).not.toHaveClass(/closed/);
  const previewImages = page.locator(".debug-inspector__preview img");
  await expect(previewImages).toHaveCount(4);
  for (let index = 0; index < (await previewImages.count()); index++) {
    await previewImages.nth(index).scrollIntoViewIfNeeded();
  }
  await expect
    .poll(() =>
      previewImages.evaluateAll((images) =>
        images.every((image) => {
          const preview = image as HTMLImageElement;
          return preview.complete && preview.naturalWidth > 0;
        })
      )
    )
    .toBe(true);
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
    expect(
      generatedShaders.some((shader) => shader.stage === "fragment" && shader.source.includes("sampleShadowMap"))
    ).toBe(true);
    expect(
      generatedShaders.some(
        (shader) => shader.stage === "fragment" && shader.source.includes("diffuseIrradiance(shadingNormal)")
      )
    ).toBe(true);
    expect(
      generatedShaders.some(
        (shader) =>
          shader.stage === "vertex" &&
          (shader.source.includes("sampleShadowMap") || shader.source.includes("diffuseIrradiance"))
      )
    ).toBe(false);
    await page.evaluate(() => window.terrainDebug!.setLighting({ directLight: true, environment: true }));
  });

  await test.step("rendering controls use actual engine state", async () => {
    const renderingFolder = page.locator(".debug-inspector .title").filter({ hasText: "Rendering / 渲染" });
    const lightingFolder = page.locator(".debug-inspector .title").filter({ hasText: "Lighting / 光照" });
    const postProcessFolder = page.locator(".debug-inspector .title").filter({ hasText: "Post-process / 后处理" });
    await expect(renderingFolder.locator("..")).toHaveClass(/closed/);
    await renderingFolder.click();
    for (const title of [lightingFolder, postProcessFolder]) {
      await expect(title).toBeVisible();
      await expect(title.locator("..")).not.toHaveClass(/closed/);
    }
    for (const label of [
      "Bloom / 泛光",
      "Bloom threshold / 泛光阈值",
      "Bloom intensity / 泛光强度",
      "Bloom scatter / 泛光扩散"
    ]) {
      await expect(postProcessFolder.locator("..")).toContainText(label);
    }
    await expect(page.locator(".debug-inspector .title").filter({ hasText: "Camera / 相机" })).toHaveCount(0);

    const original = await page.evaluate(() => window.terrainDebug!.getRendering());
    expect(original.postProcess.bloom).toEqual({
      enabled: false,
      threshold: 0.8,
      intensity: 1,
      scatter: 0.7
    });
    const updated = await page.evaluate((initial) => {
      window.terrainDebug!.setRendering({
        camera: { hdr: !initial.camera.hdr, msaaSamples: initial.camera.msaaSamples },
        postProcess: {
          enabled: !initial.postProcess.enabled,
          tonemapping: !initial.postProcess.tonemapping,
          tonemappingMode: initial.postProcess.tonemappingMode,
          bloom: {
            enabled: true,
            threshold: 1.1,
            intensity: 0.5,
            scatter: 0.4
          }
        }
      });
      return window.terrainDebug!.getRendering();
    }, original);
    expect(updated.camera).toEqual({ hdr: !original.camera.hdr, msaaSamples: original.camera.msaaSamples });
    expect(updated.postProcess).toEqual({
      enabled: !original.postProcess.enabled,
      tonemapping: !original.postProcess.tonemapping,
      tonemappingMode: original.postProcess.tonemappingMode,
      bloom: {
        enabled: true,
        threshold: 1.1,
        intensity: 0.5,
        scatter: 0.4
      }
    });
    await attachScreenshot(page, testInfo, "rendering-controls");
    await page.evaluate((state) => window.terrainDebug!.setRendering(state), original);
    expect(await page.evaluate(() => window.terrainDebug!.getRendering())).toEqual(original);
  });

  await test.step("surface cells submit deterministic instanced batches", async () => {
    const compiled = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(compiled.totalInstances).toBe(8_613);
    expect(compiled.totalRanges).toBe(288);
    expect(compiled.rendererBatches).toBeGreaterThan(compiled.coverageRendererBatches);
    expect(compiled.visibleRendererBatches).toBeLessThan(compiled.rendererBatches);
    expect(compiled.worldSurfaceAvailable).toBe(true);
    expect(compiled.worldRendererBatches).toBe(13);
    expect(compiled.coverageAvailable).toBe(true);
    expect(compiled.coverageRendererBatches).toBeGreaterThan(0);
    expect(compiled).not.toHaveProperty("worldRules");
    expect(compiled).not.toHaveProperty("sourceRules");
    expect(compiled).not.toHaveProperty("debugMasks");
    expect(compiled.categoryCounts).toEqual({
      grass: 0,
      flower: 0,
      shrub: 4_817,
      tree: 864,
      rock: 2_932,
      cliff: 0
    });
    const sourceContract = await page.evaluate(async () => {
      const manifestUrl = new URL("/demos/terrain/data/surface/surface-manifest.json", location.href);
      const manifest = await fetch(manifestUrl).then((response) => response.json());
      const binaryBytes = await fetch(new URL(manifest.binary.url, manifestUrl)).then((response) =>
        response.arrayBuffer().then((buffer) => buffer.byteLength)
      );
      return {
        binaryBytes,
        binaryCount: manifest.binary.count,
        coverageStreaming: manifest.coverageStreaming,
        worldCategories: manifest.worldDistribution.rules.map((rule: { category: SurfaceCategory }) => rule.category),
        treeRule: manifest.sourceRules.find((rule: { category: SurfaceCategory }) => rule.category === "tree"),
        grassRule: manifest.sourceRules.find((rule: { category: SurfaceCategory }) => rule.category === "grass"),
        flowerRule: manifest.sourceRules.find((rule: { category: SurfaceCategory }) => rule.category === "flower"),
        grassBaseColor: manifest.materials.find((material: { id: string }) => material.id === "grass-2").baseColor,
        grassColorVariation: manifest.materials.find((material: { id: string }) => material.id === "grass-2")
          .colorVariation,
        runtimeDefaults: manifest.runtimeDefaults,
        masks: manifest.debugMasks.map((mask: { id: string; origin: [number, number]; size: [number, number] }) => ({
          id: mask.id,
          origin: mask.origin,
          size: mask.size
        }))
      };
    });
    expect(sourceContract.worldCategories).toEqual(["grass", "flower", "shrub", "tree", "rock"]);
    expect(sourceContract.binaryBytes).toBe(482_344);
    expect(sourceContract.binaryCount).toBe(8_613);
    expect(sourceContract.coverageStreaming).toEqual({
      enabled: true,
      cellSize: 32,
      rebuildDistance: 8,
      ruleIds: ["grass", "flower"]
    });
    expect(sourceContract.treeRule).toMatchObject({
      mode: "scatter",
      spacing: 24,
      cellSize: 256
    });
    expect(sourceContract.grassRule).toMatchObject({
      mode: "coverage",
      densityPerSquareMetre: 3,
      spacing: 0.25,
      cellSize: 128
    });
    expect(sourceContract.flowerRule).toMatchObject({
      mode: "coverage",
      densityPerSquareMetre: 0.075,
      spacing: 0.25,
      cellSize: 128
    });
    expect(sourceContract.grassBaseColor).toEqual([1, 1, 1, 0]);
    expect(sourceContract.runtimeDefaults).toEqual({
      color: {
        grass: [0.0822827071298148, 0.0822827071298148, 0.0595112381629812]
      },
      scale: { tree: 4 }
    });
    expect(sourceContract.grassColorVariation).toMatchObject({
      enabled: true,
      mode: "world-noise-2d",
      offset: 1
    });
    expect(sourceContract.masks).toEqual(
      ["grass", "flower", "shrub", "tree", "rock"].map((id) => ({
        id,
        origin: [0, -2048],
        size: [1024, 3072]
      }))
    );
    expect(
      await page.evaluate(() => {
        const tuning = window.terrainDebug!.getSurface();
        return { grassColor: tuning.color.grass, treeScale: tuning.scale.tree };
      })
    ).toEqual({
      grassColor: [0.0822827071298148, 0.0822827071298148, 0.0595112381629812],
      treeScale: 4
    });
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
    const coverageBaseline = await page.evaluate(() => {
      const surface = window.terrainDebug!.inspectSurface();
      return {
        instances: surface.coverageInstances,
        grass: surface.coverageCategoryCounts.grass,
        flower: surface.coverageCategoryCounts.flower,
        fingerprint: surface.coverageFingerprint
      };
    });
    expect(coverageBaseline.grass).toBeGreaterThan(30_000);
    expect(coverageBaseline.flower).toBeGreaterThan(200);
    expect(coverageBaseline.instances).toBe(coverageBaseline.grass + coverageBaseline.flower);
    await page.evaluate(() => window.terrainDebug!.setSurface({ density: { grass: 0.5 } }));
    await expect
      .poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().coverageCategoryCounts.grass))
      .toBeLessThan(coverageBaseline.grass);
    await page.evaluate(() => window.terrainDebug!.setSurface({ density: { grass: 1 } }));
    await expect
      .poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().coverageFingerprint))
      .toBe(coverageBaseline.fingerprint);
    await expect
      .poll(() =>
        page.evaluate(() =>
          window
            .terrainDebug!.inspectSurface()
            .lodCounts.slice(1)
            .some((count) => count > 0)
        )
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
      await page.evaluate(() =>
        window
          .terrainDebug!.inspectSurface()
          .lodCounts.slice(1)
          .some((count) => count > 0)
      )
    ).toBe(true);
    const surfaceFrame = await readFrameFingerprint(page);
    expect(await page.evaluate(() => window.__surfaceInstanceDraws.some((count) => count > 1))).toBe(true);

    await page.evaluate(() =>
      window.terrainDebug!.setSurface({
        color: { grass: [0.5, 0.75, 1] },
        scale: { grass: 1.25 }
      })
    );
    expect(
      await page.evaluate(() => {
        const tuning = window.terrainDebug!.getSurface();
        return { color: tuning.color.grass, scale: tuning.scale.grass };
      })
    ).toEqual({ color: [0.5, 0.75, 1], scale: 1.25 });

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
    await page.evaluate(() => window.terrainDebug!.setSurfaceDebugView("category"));
    expect((await page.evaluate(() => window.terrainDebug!.getSurface())).debugView).toBe("category");
    await page.evaluate(() => window.terrainDebug!.setSurfaceDebugView("cell"));
    expect((await page.evaluate(() => window.terrainDebug!.getSurface())).debugView).toBe("cell");
    await page.evaluate(() => window.terrainDebug!.setSurfaceDebugView("surface"));
  });

  await test.step("world-noise surface distribution is deterministic and live-tunable", async () => {
    await page.evaluate(async () => {
      await window.terrainDebug!.setPose("world-surface");
      window.terrainDebug!.setSurface({
        wind: { enabled: false },
        density: { grass: 1, flower: 1, shrub: 1, tree: 1, rock: 1, cliff: 1 },
        world: { enabled: true, biomeOffset: [0, 0] }
      });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    const baseline = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(baseline.worldInstances).toBeGreaterThan(0);
    expect(baseline.worldRejectedByBudget).toBe(0);
    expect(
      Object.values(baseline.worldCategoryCounts)
        .slice(0, 5)
        .every((count) => count > 0)
    ).toBe(true);

    await page.evaluate(() => window.terrainDebug!.setSurface({ density: { tree: 0.5 } }));
    const sparseTrees = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(sparseTrees.worldCategoryCounts.tree).toBeLessThan(baseline.worldCategoryCounts.tree);
    expect(sparseTrees.worldCategoryCounts.grass).toBe(baseline.worldCategoryCounts.grass);

    await page.evaluate(() => window.terrainDebug!.setSurface({ density: { tree: 1 } }));
    const restored = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(restored.worldFingerprint).toBe(baseline.worldFingerprint);
    expect(restored.worldCategoryCounts).toEqual(baseline.worldCategoryCounts);

    await page.evaluate(() => window.terrainDebug!.setSurface({ world: { biomeOffset: [256, -128] } }));
    expect((await page.evaluate(() => window.terrainDebug!.inspectSurface())).worldFingerprint).not.toBe(
      baseline.worldFingerprint
    );
    await page.evaluate(() => window.terrainDebug!.setSurface({ world: { biomeOffset: [0, 0] } }));
    expect((await page.evaluate(() => window.terrainDebug!.inspectSurface())).worldFingerprint).toBe(
      baseline.worldFingerprint
    );

    await page.evaluate(() => window.terrainDebug!.setSurfaceDebugView("world-biome"));
    await attachScreenshot(page, testInfo, "world-surface-biome");
    await page.evaluate(() => window.terrainDebug!.setSurfaceDebugView("surface"));

    await page.reload();
    await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments", {
      timeout: 120_000
    });
    await page.evaluate(async () => {
      window.terrainDebug!.setView("surface");
      await window.terrainDebug!.setPose("world-surface");
      window.terrainDebug!.setSurface({ wind: { enabled: false } });
      await new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())));
    });
    const refreshed = await page.evaluate(() => window.terrainDebug!.inspectSurface());
    expect(refreshed.worldFingerprint).toBe(baseline.worldFingerprint);
    expect(refreshed.worldCategoryCounts).toEqual(baseline.worldCategoryCounts);
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
    expect(fragmentShaders.some((shader) => /sampleGrid\s*\*\s*vertexSpacing\s*\(\s*\)/.test(shader.source))).toBe(
      true
    );
    expect(
      fragmentShaders.some((shader) =>
        /material_BilerpEnabled\s*!=\s*0\s*&&\s*regionMip\s*<\s*0\.0/.test(shader.source)
      )
    ).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("material_TriReduction"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("sampleIndex"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("worldBackgroundMaterialFade"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("materialCoordinateScale"))).toBe(true);
    expect(fragmentShaders.every((shader) => !shader.source.includes("sampleLayerWithWorldTransition"))).toBe(true);
    expect(vertexShaders.every((shader) => !shader.source.includes("sqrt(-1.0)"))).toBe(true);
    expect(vertexShaders.every((shader) => shader.source.includes("renderable"))).toBe(true);
    expect(fragmentShaders.every((shader) => /renderable\s*<\s*1\.0/.test(shader.source))).toBe(true);
    const packedControlShader = fragmentShaders.find(
      (shader) => shader.source.includes("decodeBase") && shader.source.includes("decodeHole")
    );
    expect(packedControlShader).toBeDefined();
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*27u/);
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*22u/);
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*14u/);
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*10u/);
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*7u/);
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*2u/);
    expect(packedControlShader!.source).toMatch(/control\s*>>\s*1u/);
    expect(packedControlShader!.source).toMatch(/control\s*&\s*0x1u/);
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
      angleIndex: 0,
      scaleIndex: 0,
      scale: 0.5,
      hole: false,
      navigation: false,
      autoshader: true
    });
    expect(probes.upperSeam.height).toBeCloseTo(46.32088197146564, 8);
    expect(probes.lowerSeam.height).toBeCloseTo(46.24415960936905, 8);
    expect(probes.outside.height).toBeUndefined();
    expect(probes.outside.control).toBeUndefined();
    await page.evaluate(() => {
      for (const view of [
        "height",
        "region",
        "control-base",
        "control-overlay",
        "control-blend",
        "control-angle",
        "control-scale",
        "autoshader",
        "holes",
        "navigation"
      ] as const) {
        window.terrainDebug!.setView(view);
      }
      window.terrainDebug!.setView("surface");
    });
    await page.evaluate(() => window.terrainDebug!.setView("control-base"));
    await expect
      .poll(() =>
        page.evaluate(() => {
          const surface = window.terrainDebug!.inspectSurface();
          return [surface.visibleInstances, surface.worldInstances, surface.visibleRendererBatches];
        })
      )
      .toEqual([0, 0, 0]);
    await page.evaluate(() => window.terrainDebug!.setView("surface"));
    await expect
      .poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().visibleInstances))
      .toBeGreaterThan(0);
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
      { name: "overview", view: "surface", pose: "overview", viewFirst: false, checksFramebuffer: false },
      { name: "region-seam", view: "region-grid", pose: "seam", viewFirst: true, checksFramebuffer: true },
      { name: "dual-factor", view: "dual-factor", pose: "dual", viewFirst: true, checksFramebuffer: true }
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
      if (diagnostic.checksFramebuffer) {
        expect((await readFrameStats(page)).uniqueColors, diagnostic.name).toBeGreaterThan(2);
      }
    }
    const initialBackground = await page.evaluate(() => window.terrainDebug!.getTuning().world.background);
    const flatWorldInstances = await page.evaluate(async () => {
      await window.terrainDebug!.setWorldBackground("flat");
      await window.terrainDebug!.setPose("background-seam");
      const worldInstances = window.terrainDebug!.inspectSurface().worldInstances;
      await window.terrainDebug!.setView("layer-detiled");
      return worldInstances;
    });
    expect(flatWorldInstances).toBe(0);
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
    expect(defaults.layers[1]).toMatchObject({
      layer: 1,
      uvScale: 1,
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
        dualScaling: { enabled: false, near: 90, far: 180 },
        macroVariation: { enabled: false, noise1Scale: 0.05, noise2Scale: 0.08 }
      });
      return window.terrainDebug!.getTuning();
    });
    expect(configured.material).toMatchObject({
      autoShader: { enabled: false, slope: 0.75 },
      projection: { enabled: false, threshold: 0.8 },
      dualScaling: { enabled: false, near: 90, far: 180 },
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

  expect(await page.evaluate(() => window.__terrainShaderDiagnostics)).toEqual([]);
  expect(pageErrors).toEqual([]);
  expect(consoleErrors).toEqual([]);
});

test("first-person camera follows the CPU heightfield", async ({ page }) => {
  test.setTimeout(120_000);
  await page.goto("/demos/terrain/index.html");
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments");
  const terrainFolder = page.locator(".debug-inspector .title").filter({ hasText: "Terrain / 地形" });
  await terrainFolder.click();
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

  await page.evaluate(() => {
    window.terrainDebug!.setView("grey");
    window.terrainDebug!.setLighting({ directLight: false, environment: false });
    window.terrainDebug!.setSurface({
      enabled: { grass: false, flower: false, shrub: false, tree: false, rock: false, cliff: false }
    });
    window.terrainDebug!.setFirstPersonMoveSpeed(30);
  });
  await page.keyboard.down("KeyD");
  await page.waitForTimeout(16_000);
  await page.keyboard.up("KeyD");
  const proceduralWorld = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
  expect(proceduralWorld.position[0]).toBeGreaterThan(1024);
  expect(proceduralWorld.groundHeight).toBeDefined();
  expect(proceduralWorld.position[1]).toBeCloseTo(proceduralWorld.groundHeight! + 2.25, 5);
});

test("Realistic distance LOD hides dense coverage from overview and restores it deterministically", async ({
  page
}) => {
  test.setTimeout(600_000);
  await page.goto("/demos/terrain/index.html");
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments", {
    timeout: 120_000
  });
  await expect
    .poll(async () => page.evaluate(() => window.terrainDebug!.inspectSurface().visibleCategoryCounts.grass))
    .toBeGreaterThan(30_000);
  await expect
    .poll(async () => page.evaluate(() => window.terrainDebug!.inspectSurface().visibleCategoryCounts.flower))
    .toBeGreaterThan(200);
  const nearSnapshot = await page.evaluate(() => window.terrainDebug!.inspectSurface());

  await page.evaluate(() => window.terrainDebug!.setPose("overview"));
  await expect
    .poll(async () => {
      const surface = await page.evaluate(() => window.terrainDebug!.inspectSurface());
      return {
        regionGrass: surface.visibleCategoryCounts.grass,
        regionFlowers: surface.visibleCategoryCounts.flower,
        worldGrass: surface.worldCategoryCounts.grass,
        worldFlowers: surface.worldCategoryCounts.flower
      };
    })
    .toEqual({ regionGrass: 0, regionFlowers: 0, worldGrass: 0, worldFlowers: 0 });

  await page.evaluate(() => window.terrainDebug!.setPose("world-surface"));
  await expect
    .poll(async () => page.evaluate(() => window.terrainDebug!.inspectSurface().worldCategoryCounts.grass))
    .toBeGreaterThan(0);
  const worldCamera = await page.evaluate(() => window.terrainDebug!.getCamera());
  const worldFingerprint = await page.evaluate(() => window.terrainDebug!.inspectSurface().worldFingerprint);
  await page.evaluate((camera) => {
    window.terrainDebug!.setCamera({
      ...camera,
      position: [camera.position[0], 2_000, camera.position[2]]
    });
  }, worldCamera);
  await expect
    .poll(async () => page.evaluate(() => window.terrainDebug!.inspectSurface().worldCategoryCounts.grass))
    .toBe(0);
  await page.evaluate((camera) => window.terrainDebug!.setCamera(camera), worldCamera);
  await expect
    .poll(async () => page.evaluate(() => window.terrainDebug!.inspectSurface().worldFingerprint))
    .toBe(worldFingerprint);

  await page.evaluate(() => window.terrainDebug!.setPose("first-person"));
  await expect
    .poll(async () => page.evaluate(() => window.terrainDebug!.inspectSurface().visibleCategoryCounts.grass))
    .toBe(nearSnapshot.visibleCategoryCounts.grass);
});

test("both terrain inspectors retain a minimal collapse smoke path", async ({ page }) => {
  test.setTimeout(900_000);
  await page.goto("/demos/terrain/index.html?pose=overview");
  await expect(page.locator("#status")).toContainText("ready · 3 regions · 144 clipmap segments", {
    timeout: 120_000
  });
  await page.evaluate(() => {
    window.terrainDebug!.setView("grey");
    window.terrainDebug!.setSurface({
      enabled: { grass: false, flower: false, shrub: false, tree: false, rock: false, cliff: false }
    });
  });
  await verifyInspectorCanReopen(page);
  await verifyCameraOutput(page);

  await page.goto("/demos/terrain/grasslands/index.html?pose=valley-overview");
  await expect(page.locator("#status")).toContainText(
    "ready · 9 terrain tiles · 291,069 surface instances · 64 architecture placements · 8 sky clouds",
    { timeout: 120_000 }
  );
  await page.evaluate(() => {
    window.terrainDebug!.setView("grey");
    window.terrainDebug!.setSurface({
      enabled: { grass: false, flower: false, shrub: false, tree: false, rock: false, cliff: false }
    });
    window.grasslandsDebug!.setScene({ architecture: false, clouds: false, animation: false });
  });
  await verifyInspectorCanReopen(page);
  await verifyCameraOutput(page);
});

test("both terrain entries expose live foldable performance metrics", async ({ page }) => {
  test.setTimeout(600_000);
  const entries = [
    {
      url: "/demos/terrain/index.html",
      ready: "ready · 3 regions · 144 clipmap segments"
    },
    {
      url: "/demos/terrain/grasslands/index.html",
      ready: "ready · 9 terrain tiles · 291,069 surface instances"
    }
  ] as const;

  for (const entry of entries) {
    await page.goto(entry.url);
    await expect(page.locator("#status")).toContainText(entry.ready, { timeout: 120_000 });
    await verifyPerformancePanel(page);
  }
});

test("both terrain entries expose disabled bloom controls", async ({ page }) => {
  test.setTimeout(300_000);
  const entries = [
    {
      url: "/demos/terrain/index.html",
      ready: "ready · 3 regions · 144 clipmap segments",
      bloom: { enabled: false, threshold: 0.8, intensity: 1, scatter: 0.7 }
    },
    {
      url: "/demos/terrain/grasslands/index.html",
      ready: "ready · 9 terrain tiles · 291,069 surface instances",
      bloom: { enabled: false, threshold: 0.5, intensity: 0.35, scatter: 0.6 }
    }
  ] as const;

  for (const entry of entries) {
    await page.goto(entry.url);
    await expect(page.locator("#status")).toContainText(entry.ready, { timeout: 120_000 });
    const renderingFolder = page.locator(".debug-inspector .title").filter({ hasText: "Rendering / 渲染" });
    await renderingFolder.click();
    const postProcessFolder = page.locator(".debug-inspector .title").filter({ hasText: "Post-process / 后处理" });
    for (const label of [
      "Bloom / 泛光",
      "Bloom threshold / 泛光阈值",
      "Bloom intensity / 泛光强度",
      "Bloom scatter / 泛光扩散"
    ]) {
      await expect(postProcessFolder.locator("..")).toContainText(label);
    }
    expect(await page.evaluate(() => window.terrainDebug!.getRendering().postProcess.bloom)).toEqual(entry.bloom);

    const updated = {
      enabled: true,
      threshold: entry.bloom.threshold + 0.1,
      intensity: entry.bloom.intensity + 0.1,
      scatter: entry.bloom.scatter - 0.1
    };
    await page.evaluate((bloom) => {
      window.terrainDebug!.setRendering({ postProcess: { bloom } });
    }, updated);
    expect(await page.evaluate(() => window.terrainDebug!.getRendering().postProcess.bloom)).toEqual(updated);
    await page.evaluate((bloom) => {
      window.terrainDebug!.setRendering({ postProcess: { bloom } });
    }, entry.bloom);
  }
});

test.describe("Grasslands authored scene", () => {
  test.use({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 });

  test("shares terrain diagnostics and reproducible camera poses", async ({ page }) => {
    test.setTimeout(600_000);
    await page.goto("/demos/terrain/grasslands/index.html?pose=valley-overview");
    await expect(page.locator("#status")).toContainText(
      "ready · 9 terrain tiles · 291,069 surface instances · 64 architecture placements · 8 sky clouds",
      { timeout: 120_000 }
    );
    await expect(page.locator('[aria-label="Grasslands terrain inspector"]')).toBeVisible();
    const topLevelFolders = page.locator(".debug-inspector > ul > li.folder > .dg > ul > li.title");
    await expect(topLevelFolders).toHaveText([
      "Rendering / 渲染",
      "Terrain / 地形",
      "Surface / 地表",
      "Scene / 场景复刻"
    ]);
    for (let index = 0; index < (await topLevelFolders.count()); index++) {
      await expect(topLevelFolders.nth(index).locator("..")).toHaveClass(/closed/);
    }
    for (const title of ["Composition / 场景构成", "Lighting / 光照", "Cloud & fog / 云雾"]) {
      const folder = page.locator(".debug-inspector .title").filter({ hasText: title });
      await expect(folder).toHaveCount(1);
      await expect(folder).toBeAttached();
      await expect(folder.locator("..")).not.toHaveClass(/closed/);
    }
    await expect(page.locator(".debug-inspector .title").filter({ hasText: "Camera / 相机" })).toHaveCount(0);
    await expect(page.locator(".debug-inspector")).not.toContainText("Compiled inputs / 编译输入");
    await expect(page.locator(".debug-inspector")).not.toContainText("World inputs / 世界输入");
    await expect(page.locator(".debug-inspector__preview-row")).toHaveCount(14);
    await expect(page.locator('.debug-inspector__preview[aria-label*="density mask"]')).toHaveCount(0);

    await page.evaluate(() => {
      window.terrainDebug!.setView("dual-factor");
      window.terrainDebug!.setView("surface");
      window.terrainDebug!.setMaterialTuning({ dualScaling: { enabled: true } });
    });
    expect(await page.evaluate(() => window.terrainDebug!.getTuning().material.dualScaling.enabled)).toBe(true);
    expect(await page.evaluate(() => window.terrainDebug!.poses)).toEqual([
      "first-person",
      "hero",
      "overview",
      "valley-overview",
      "terrain-horizon",
      "grass-wind"
    ]);
    await expect(page.locator('[aria-label="Grasslands terrain inspector"]')).not.toContainText("unity-source");
    await expect(page.locator('[aria-label="Grasslands terrain inspector"] [title*="Unity"]')).toHaveCount(0);
    const terrainContract = await page.evaluate(() => ({
      clipmap: window.terrainDebug!.inspect(),
      mountain: window.terrainDebug!.readProbe(500, 500),
      path: window.terrainDebug!.readProbe(1500, 1500),
      meadow: window.terrainDebug!.readProbe(1473.835, 1753.641),
      outside: window.terrainDebug!.readProbe(-1, 0)
    }));
    expect(terrainContract.clipmap).toMatchObject({
      regionLocations: [
        [0, 0],
        [1, 0],
        [2, 0],
        [0, 1],
        [1, 1],
        [2, 1],
        [0, 2],
        [1, 2],
        [2, 2]
      ],
      regionSize: 1024,
      vertexSpacing: 0.9765625,
      meshSize: 48,
      meshLods: 8
    });
    expect(terrainContract.mountain).toMatchObject({
      control: {
        raw: 2_097_152,
        base: 0,
        overlay: 0,
        blend: 128 / 255,
        angleIndex: 0,
        scaleIndex: 0,
        scale: 0.5,
        hole: false,
        navigation: false,
        autoshader: false
      }
    });
    expect(terrainContract.mountain.height).toBeCloseTo(384.7470817120623, 8);
    expect(terrainContract.path).toMatchObject({
      control: {
        raw: 8_388_608,
        base: 0,
        overlay: 2,
        blend: 0,
        angleIndex: 0,
        scaleIndex: 0,
        scale: 0.5,
        hole: false,
        navigation: false,
        autoshader: false
      }
    });
    expect(terrainContract.path.height).toBeCloseTo(42.13321126115816, 8);
    expect(terrainContract.meadow).toMatchObject({
      control: {
        raw: 26_460_160,
        base: 0,
        overlay: 6,
        blend: 79 / 255,
        angleIndex: 0,
        scaleIndex: 0,
        scale: 0.5,
        hole: false,
        navigation: false,
        autoshader: false
      }
    });
    expect(terrainContract.meadow.height).toBeCloseTo(22.37582970931563, 8);
    expect(terrainContract.outside).toEqual({ world: [-1, 0] });
    await page.evaluate(() => {
      for (const view of [
        "height",
        "region",
        "control-base",
        "control-overlay",
        "control-blend",
        "control-angle",
        "control-scale",
        "autoshader",
        "holes",
        "navigation"
      ] as const) {
        window.terrainDebug!.setView(view);
      }
      window.terrainDebug!.setView("surface");
    });
    const requestedComposition = await page.evaluate(() => window.grasslandsDebug!.getScene());
    await page.evaluate(() => window.terrainDebug!.setView("control-base"));
    await expect
      .poll(() =>
        page.evaluate(() => {
          const surface = window.terrainDebug!.inspectSurface();
          return [surface.visibleInstances, surface.worldInstances, surface.visibleRendererBatches];
        })
      )
      .toEqual([0, 0, 0]);
    expect(await page.evaluate(() => window.grasslandsDebug!.getScene())).toEqual(requestedComposition);
    await page.evaluate(() => window.terrainDebug!.setView("surface"));
    await expect
      .poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().visibleInstances))
      .toBeGreaterThan(0);

    const originalCamera = await page.evaluate(() => window.terrainDebug!.getCamera());
    const canvasBounds = await page.locator("#canvas").boundingBox();
    expect(canvasBounds).not.toBeNull();
    await page.mouse.move(canvasBounds!.x + canvasBounds!.width * 0.4, canvasBounds!.y + canvasBounds!.height * 0.5);
    await page.mouse.down();
    await page.mouse.move(canvasBounds!.x + canvasBounds!.width * 0.47, canvasBounds!.y + canvasBounds!.height * 0.54, {
      steps: 8
    });
    await page.mouse.up();
    await page.waitForTimeout(100);
    const orbitCamera = await page.evaluate(() => window.terrainDebug!.getCamera());
    expect(orbitCamera.rotation).not.toEqual(originalCamera.rotation);
    expect((await page.evaluate(() => window.terrainDebug!.getFirstPerson())).active).toBe(false);
    await page.evaluate(() => window.terrainDebug!.setPose("valley-overview"));

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

    await page.goto("/demos/terrain/grasslands/index.html");
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

    await expect.poll(() => page.evaluate(() => window.terrainDebug!.inspectSurface().transitioningRanges)).toBe(0);
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
    expect(await page.evaluate(() => window.grasslandsDebug!.inspectClouds().time)).toBeGreaterThan(cloudStart.time);
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
    await page.evaluate(() => {
      window.terrainDebug!.setPose("grass-wind");
      window.terrainDebug!.setSurfaceDebugView("wind-weight");
    });
    expect((await page.evaluate(() => window.terrainDebug!.getSurface())).debugView).toBe("wind-weight");
    await attachScreenshot(page, testInfo, "grasslands-wind-weight");
    await page.evaluate(() => {
      window.terrainDebug!.setSurfaceDebugView("category");
    });
    expect((await page.evaluate(() => window.terrainDebug!.getSurface())).debugView).toBe("category");
    await page.evaluate(() => {
      window.terrainDebug!.setSurfaceDebugView("cell");
    });
    expect((await page.evaluate(() => window.terrainDebug!.getSurface())).debugView).toBe("cell");
    await page.evaluate(() => {
      window.terrainDebug!.setSurfaceDebugView("surface");
      window.terrainDebug!.setPose("first-person");
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
          shader.source.includes("material_WindSupported") &&
          shader.source.includes("material_WindBaseLockUvInverted") &&
          /1\.0\s*-\s*TEXCOORD_0\.y/.test(shader.source)
      )
    );
    expect(windVertexShaders.some((shader) => shader.source.includes("scene_ShadowBias"))).toBe(true);
    expect(windVertexShaders.some((shader) => !shader.source.includes("scene_ShadowBias"))).toBe(true);
    const flowerFragmentShaders = await page.evaluate(() =>
      window.__surfaceGeneratedShaders.filter(
        (shader) =>
          shader.stage === "fragment" &&
          shader.source.includes("material_ColorVariationMode") &&
          shader.source.includes("material_SecondColor")
      )
    );
    expect(flowerFragmentShaders.some((shader) => /1\.0\s*-\s*[A-Za-z0-9_]+\.y/.test(shader.source))).toBe(true);
    await testInfo.attach("grasslands-submission-snapshot", {
      body: JSON.stringify(submitted, null, 2),
      contentType: "application/json"
    });
    await attachScreenshot(page, testInfo, "grasslands-hero-camera");

    const beforeMove = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
    await page.keyboard.down("KeyW");
    await page.waitForTimeout(180);
    await page.keyboard.up("KeyW");
    const afterMove = await page.evaluate(() => window.terrainDebug!.getFirstPerson());
    expect(
      Math.hypot(afterMove.position[0] - beforeMove.position[0], afterMove.position[2] - beforeMove.position[2])
    ).toBeGreaterThan(0);
    expect(afterMove.position[1]).toBeCloseTo(afterMove.groundHeight! + 1.7, 4);

    const route: TerrainFirstPersonSnapshot[] = [];
    for (const key of ["KeyW", "KeyW", "KeyD", "KeyW", "KeyA", "KeyW"]) {
      await page.keyboard.down(key);
      await page.waitForTimeout(180);
      await page.keyboard.up(key);
      route.push(await page.evaluate(() => window.terrainDebug!.getFirstPerson()));
    }
    for (const sample of route) {
      expect(sample.active).toBe(true);
      expect(sample.groundHeight).toBeDefined();
      expect(sample.position[1]).toBeCloseTo(sample.groundHeight! + sample.eyeHeight, 4);
    }

    expect(pageErrors).toEqual([]);
    expect(consoleErrors).toEqual([]);
  });
});

test.describe("Grasslands visual baseline", () => {
  test.use({ viewport: { width: 1280, height: 720 }, deviceScaleFactor: 2 });

  test("captures stable and animated hero-camera frames", async ({ page }, testInfo) => {
    test.skip(!captureScreenshots, "Set TERRAIN_E2E_CAPTURE=1 to record the DPR 2 visual baseline.");
    test.setTimeout(900_000);
    await page.goto("/demos/terrain/grasslands/index.html?pose=hero");
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
    await testInfo.attach("grasslands-hero-static-dpr2", { body: staticFrame, contentType: "image/png" });
    await testInfo.attach("grasslands-hero-animated-dpr2", { body: animatedFrame, contentType: "image/png" });
  });
});

async function verifyInspectorCanReopen(page: Page): Promise<void> {
  const title = page.locator(".debug-inspector li.title:visible").first();
  const folder = title.locator("..");
  await expect(folder).toHaveClass(/closed/);
  await title.click({ force: true });
  await expect(folder).not.toHaveClass(/closed/);
  await title.click({ force: true });
  await expect(folder).toHaveClass(/closed/);
  const panelToggle = page.locator(".debug-inspector .close-button");
  await panelToggle.click();
  await expect(panelToggle).toContainText("Open Controls");
  await panelToggle.click();
  await expect(panelToggle).toContainText("Close Controls");
}

async function verifyCameraOutput(page: Page): Promise<void> {
  const terrainTitle = page.locator(".debug-inspector .title").filter({ hasText: "Terrain / 地形" });
  await expect(terrainTitle).toHaveCount(1);
  if (await terrainTitle.locator("..").evaluate((folder) => folder.classList.contains("closed"))) {
    await terrainTitle.click();
  }
  const outputRow = page.locator("li.cr.function").filter({ hasText: "Output camera pose / 输出相机姿态" });
  await expect(outputRow).toHaveCount(1);
  await outputRow.click();
  const output = page.locator(".debug-inspector__readout-row").filter({ hasText: "Camera JSON / 相机 JSON" });
  await expect(output).toContainText('"position"');
  await expect(output).toContainText('"rotation"');
  await expect(output).toContainText('"forward"');
  await expect(output).toContainText('"fieldOfView"');
}

async function verifyPerformancePanel(page: Page): Promise<void> {
  const panel = page.locator("#terrain-performance-panel");
  const metrics = panel.locator("[data-role='metrics']");
  const toggle = panel.locator("[data-action='toggle']");
  const hide = panel.locator("[data-action='hide']");
  const show = panel.locator("[data-action='show']");
  await expect(panel).toHaveAttribute("data-state", "hidden");
  await expect(toggle).toHaveAttribute("aria-expanded", "false");
  await expect(metrics).toBeHidden();
  await expect(show).toBeVisible();

  await expect.poll(async () => numericMetric(page, "fps"), { timeout: 15_000 }).toBeGreaterThan(0);
  await expect.poll(async () => numericMetric(page, "gpuMemory")).toBeGreaterThan(0);
  await expect(page.locator("[data-metric='webgl']")).toHaveText("2.0");

  await expect
    .poll(async () => {
      const displayed = await numericMetric(page, "surfaceInstances");
      const runtime = await page.evaluate(() => window.terrainDebug!.inspectSurface().visibleInstances);
      return displayed === runtime;
    })
    .toBe(true);
  await expect
    .poll(async () => {
      const displayed = await page.locator("[data-metric='surfaceBatches']").textContent();
      const runtime = await page.evaluate(() => window.terrainDebug!.inspectSurface());
      return (
        displayed ===
        `${runtime.visibleRendererBatches.toLocaleString("en-US")} / ${runtime.rendererBatches.toLocaleString("en-US")}`
      );
    })
    .toBe(true);
  await expect
    .poll(async () => {
      const displayed = await numericMetric(page, "coverageInstances");
      const runtime = await page.evaluate(() => window.terrainDebug!.inspectSurface().coverageInstances);
      return displayed === runtime;
    })
    .toBe(true);
  await expect
    .poll(async () => {
      const displayed = await numericMetric(page, "worldInstances");
      const runtime = await page.evaluate(() => window.terrainDebug!.inspectSurface().worldInstances);
      return displayed === runtime;
    })
    .toBe(true);
  await expect
    .poll(async () => {
      const displayed = await numericMetric(page, "clipmapSegments");
      const runtime = await page.evaluate(() => window.terrainDebug!.inspect().segmentCount);
      return displayed === runtime;
    })
    .toBe(true);
  await expect(page.locator("[data-metric='surfaceLods']")).not.toHaveText("—");

  await show.click();
  await expect(panel).toHaveAttribute("data-state", "expanded");
  await expect(toggle).toHaveAttribute("aria-expanded", "true");
  await expect(metrics).toBeVisible();

  await toggle.click();
  await expect(panel).toHaveAttribute("data-state", "collapsed");
  await expect(toggle).toHaveAttribute("aria-expanded", "false");
  await expect(metrics).toBeHidden();
  await toggle.click();
  await expect(panel).toHaveAttribute("data-state", "expanded");
  await expect(metrics).toBeVisible();

  await hide.click();
  await expect(panel).toHaveAttribute("data-state", "hidden");
  await expect(show).toBeVisible();
  await show.click();
  await expect(panel).toHaveAttribute("data-state", "expanded");
  await expect(metrics).toBeVisible();
}

async function numericMetric(page: Page, key: string): Promise<number> {
  const value = (await page.locator(`[data-metric='${key}']`).textContent()) ?? "";
  return Number.parseFloat(value.replaceAll(",", "")) || 0;
}

interface SourceTerrainProbe {
  readonly world: readonly [x: number, z: number];
  readonly heightRaw: number;
  readonly height: number;
  readonly region: {
    readonly layer: number;
    readonly location: readonly [x: number, z: number];
    readonly texel: readonly [x: number, z: number];
    readonly sourceIndex: number;
  };
  readonly control: ReturnType<typeof decodeControlOracle>;
}

const CONTROL_FIXTURE_EXPECTATIONS = [
  {
    id: "blend-0",
    heightRaw: 8_192,
    control: encodeControlOracle(3, 5, 0, 2, 1, 0)
  },
  {
    id: "blend-128-navigation",
    heightRaw: 24_576,
    control: encodeControlOracle(7, 11, 128, 5, 3, 0x2)
  },
  {
    id: "blend-255-autoshader",
    heightRaw: 40_960,
    control: encodeControlOracle(13, 17, 255, 9, 6, 0x1)
  },
  {
    id: "hole",
    heightRaw: 57_344,
    control: encodeControlOracle(19, 23, 64, 12, 7, 0x4)
  }
] as const;

function readTerrainSourceProbe(manifestPath: string, worldX: number, worldZ: number): SourceTerrainProbe {
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8")) as {
    readonly terrain: {
      readonly regionSize: number;
      readonly vertexSpacing: number;
      readonly heightAtlas: {
        readonly url: string;
        readonly width: number;
        readonly minMetres: number;
        readonly maxMetres: number;
      };
      readonly regions: readonly {
        readonly location: readonly [x: number, z: number];
        readonly heightOffsetY: number;
        readonly controlMap: string;
      }[];
    };
  };
  const { terrain } = manifest;
  const gridX = Math.round(worldX / terrain.vertexSpacing);
  const gridZ = Math.round(worldZ / terrain.vertexSpacing);
  const regionX = Math.floor(gridX / terrain.regionSize);
  const regionZ = Math.floor(gridZ / terrain.regionSize);
  const layer = terrain.regions.findIndex(({ location }) => location[0] === regionX && location[1] === regionZ);
  if (layer < 0) {
    throw new Error(`[terrain-e2e] (${worldX}, ${worldZ}) is outside ${manifestPath}`);
  }

  const region = terrain.regions[layer];
  const localX = positiveModulo(gridX, terrain.regionSize);
  const localZ = positiveModulo(gridZ, terrain.regionSize);
  const sourceIndex = localZ * terrain.regionSize + localX;
  const directory = path.dirname(manifestPath);
  const heightBytes = readFileSync(path.resolve(directory, terrain.heightAtlas.url));
  const heightAtlasIndex = (region.heightOffsetY + localZ) * terrain.heightAtlas.width + localX;
  const heightRaw = heightBytes.readUInt16LE(heightAtlasIndex * 2);
  const controlBytes = readFileSync(path.resolve(directory, region.controlMap));
  const controlRaw = controlBytes.readUInt32LE(sourceIndex * 4);
  const height =
    terrain.heightAtlas.minMetres +
    (heightRaw / 65_535) * (terrain.heightAtlas.maxMetres - terrain.heightAtlas.minMetres);

  return {
    world: [worldX, worldZ],
    heightRaw,
    height,
    region: {
      layer,
      location: region.location,
      texel: [localX, localZ],
      sourceIndex
    },
    control: decodeControlOracle(controlRaw)
  };
}

function readTerrainVertexSpacing(manifestPath: string): number {
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8")) as {
    readonly terrain: { readonly vertexSpacing: number };
  };
  return manifest.terrain.vertexSpacing;
}

function expectProbeToMatchSource(actual: TerrainProbeSnapshot, source: SourceTerrainProbe): void {
  expect(actual.world).toEqual(source.world);
  expect(actual.heightRaw).toBe(source.heightRaw);
  expect(actual.height).toBeCloseTo(source.height, 10);
  expect(actual.region).toEqual(source.region);
  expect(actual.control).toEqual(source.control);
}

async function prepareNumericTerrainReadback(page: Page): Promise<void> {
  await page.evaluate(() => {
    window.terrainDebug!.setRendering({
      lighting: {
        directLight: false,
        shadows: false,
        environment: false,
        skybox: false
      },
      camera: { hdr: false, msaaSamples: 1 },
      postProcess: { enabled: false, tonemapping: false }
    });
    window.terrainDebug!.setWaterDebug({ enabled: false });
    window.terrainDebug!.focusProbe(0, 0);
    window.terrainDebug!.setView("grey");
  });
  await waitForTerrainFrames(page, 4);
}

async function readTerrainProbePixel(
  page: Page,
  world: readonly [x: number, z: number],
  view: TerrainDebugViewName
): Promise<readonly [r: number, g: number, b: number, a: number]> {
  await page.evaluate(
    ({ worldX, worldZ, viewName }) => {
      window.terrainDebug!.focusProbe(worldX, worldZ);
      window.terrainDebug!.setView(viewName);
    },
    { worldX: world[0], worldZ: world[1], viewName: view }
  );
  await waitForTerrainFrames(page, 4);
  const camera = await page.evaluate(() => window.terrainDebug!.getCamera());
  expect(camera.position[0]).toBeCloseTo(world[0], 6);
  expect(camera.position[2]).toBeCloseTo(world[1], 6);
  expect(camera.forward[0]).toBeCloseTo(0, 6);
  expect(camera.forward[1]).toBeCloseTo(-1, 6);
  expect(camera.forward[2]).toBeCloseTo(0, 6);
  return page.evaluate(
    () =>
      new Promise<readonly [r: number, g: number, b: number, a: number]>((resolve) => {
        requestAnimationFrame(() => {
          const canvas = document.querySelector<HTMLCanvasElement>("#canvas")!;
          const gl = canvas.getContext("webgl2")!;
          gl.finish();
          const pixel = new Uint8Array(4);
          gl.readPixels(
            Math.floor(canvas.width * 0.5),
            Math.floor(canvas.height * 0.5),
            1,
            1,
            gl.RGBA,
            gl.UNSIGNED_BYTE,
            pixel
          );
          resolve([pixel[0], pixel[1], pixel[2], pixel[3]]);
        });
      })
  );
}

async function expectControlDebugPixels(
  page: Page,
  world: readonly [x: number, z: number],
  control: ReturnType<typeof decodeControlOracle>,
  label: string
): Promise<void> {
  if (!control.hole) {
    expectPixel(
      await readTerrainProbePixel(page, world, "control-base"),
      grayscale(control.base / 31),
      `${label} base`
    );
    expectPixel(
      await readTerrainProbePixel(page, world, "control-overlay"),
      grayscale(control.overlay / 31),
      `${label} overlay`
    );
    const blendPixel = await readTerrainProbePixel(page, world, "control-blend");
    expectByte(blendPixel[0], toFramebufferByte(control.blend), `${label} blend.r`);
    expectByte(blendPixel[1], 0, `${label} blend.g`);
    expectPixel(
      await readTerrainProbePixel(page, world, "control-angle"),
      grayscale(control.angleIndex / 15),
      `${label} rotation`
    );
    expectPixel(await readTerrainProbePixel(page, world, "control-scale"), grayscale(control.scale), `${label} scale`);
    expectPixel(
      await readTerrainProbePixel(page, world, "navigation"),
      grayscale(Number(control.navigation)),
      `${label} navigation`
    );
    expectPixel(
      await readTerrainProbePixel(page, world, "autoshader"),
      grayscale(Number(control.autoshader)),
      `${label} autoshader`
    );
  }
  expectPixel(
    await readTerrainProbePixel(page, world, "holes"),
    control.hole ? normalizedRgb(1, 0, 0.2) : grayscale(0.08),
    `${label} hole`
  );
}

async function waitForTerrainFrames(page: Page, frameCount: number): Promise<void> {
  await page.evaluate(
    (count) =>
      new Promise<void>((resolve) => {
        let rendered = 0;
        const next = (): void => {
          rendered++;
          if (rendered >= count) {
            resolve();
          } else {
            requestAnimationFrame(next);
          }
        };
        requestAnimationFrame(next);
      }),
    frameCount
  );
}

function expectPixel(
  actual: readonly [r: number, g: number, b: number, a: number],
  expected: readonly [r: number, g: number, b: number],
  label: string
): void {
  expectByte(actual[0], expected[0], `${label}.r`);
  expectByte(actual[1], expected[1], `${label}.g`);
  expectByte(actual[2], expected[2], `${label}.b`);
  expectByte(actual[3], 255, `${label}.a`);
}

function expectByte(actual: number, expected: number, label: string): void {
  expect(Math.abs(actual - expected), `${label}: ${actual} vs ${expected}`).toBeLessThanOrEqual(1);
}

function heightDebugValue(height: number): number {
  const value = clamp01((0.5 + height / 300 + 0.1) / 2.1);
  return value * value * (3 - 2 * value);
}

function regionLayerColor(layer: number): readonly [r: number, g: number, b: number] {
  const colors = [
    [1, 0.2, 0.2],
    [1, 0.65, 0.1],
    [0.2, 1, 0.25],
    [0.1, 0.8, 1],
    [0.25, 0.35, 1],
    [0.75, 0.25, 1],
    [1, 0.25, 0.7]
  ] as const;
  const color = colors[Math.min(layer, colors.length - 1)];
  return normalizedRgb(color[0], color[1], color[2]);
}

function grayscale(value: number): readonly [r: number, g: number, b: number] {
  const byte = toFramebufferByte(value);
  return [byte, byte, byte];
}

function normalizedRgb(r: number, g: number, b: number): readonly [r: number, g: number, b: number] {
  return [toFramebufferByte(r), toFramebufferByte(g), toFramebufferByte(b)];
}

function toFramebufferByte(value: number): number {
  const linear = clamp01(value);
  const srgb = linear <= 0.0031308 ? linear * 12.9232102 : 1.055 * Math.pow(linear, 1 / 2.4) - 0.055;
  return Math.round(clamp01(srgb) * 255);
}

function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value));
}

function positiveModulo(value: number, divisor: number): number {
  return ((value % divisor) + divisor) % divisor;
}

function encodeControlOracle(
  base: number,
  overlay: number,
  blend: number,
  angle: number,
  scale: number,
  flags: number
): number {
  return (
    (((base & 0x1f) << 27) |
      ((overlay & 0x1f) << 22) |
      ((blend & 0xff) << 14) |
      ((angle & 0xf) << 10) |
      ((scale & 0x7) << 7) |
      (flags & 0x7)) >>>
    0
  );
}

function decodeControlOracle(value: number) {
  const raw = value >>> 0;
  const scaleIndex = (raw >>> 7) & 0x7;
  return {
    raw,
    base: (raw >>> 27) & 0x1f,
    overlay: (raw >>> 22) & 0x1f,
    blend: ((raw >>> 14) & 0xff) / 255,
    angleIndex: (raw >>> 10) & 0xf,
    scaleIndex,
    scale: 0.9 - (((scaleIndex + 3) % 8) + 1) * 0.1,
    hole: (raw & 0x4) !== 0,
    navigation: (raw & 0x2) !== 0,
    autoshader: (raw & 0x1) !== 0
  };
}

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
      if (source.includes("material_HeightMaps") || source.includes("material_ControlMaps")) {
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

async function attachScreenshot(page: Page, testInfo: TestInfo, name: string): Promise<void> {
  if (!captureScreenshots) {
    return;
  }
  const screenshotPath = testInfo.outputPath(`${name}.png`);
  await page.screenshot({ path: screenshotPath });
  await testInfo.attach(name, { path: screenshotPath, contentType: "image/png" });
}
