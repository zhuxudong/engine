import { expect, test, type Browser, type Page, type TestInfo } from "@playwright/test";

type Backend = "webgl2" | "webgpu";

interface FeatureCase {
  label: string;
  path: string;
}

const dualBackendFeatures: FeatureCase[] = [
  { label: "backend-init", path: "basics/backend-init" },
  { label: "shaderlab-triangle", path: "basics/shaderlab-triangle" },
  { label: "index-buffer", path: "resources/index-buffer" },
  { label: "buffer-update", path: "resources/buffer-update" },
  { label: "uniform-update", path: "resources/uniform-update" },
  { label: "texture-sampling", path: "resources/texture-sampling" },
  { label: "cube-texture", path: "resources/cube-texture" },
  { label: "instancing", path: "render/instancing" },
  { label: "render-target", path: "render/render-target" },
  { label: "depth-test", path: "render/depth-test" },
  { label: "msaa", path: "render/msaa" },
  { label: "instancing-benchmark", path: "benchmark/instancing" }
];

const webGPUFeatures: FeatureCase[] = [
  { label: "compute-sampled-texture", path: "compute/sampled-texture" },
  { label: "compute-storage-buffer", path: "compute/storage-buffer" },
  { label: "compute-atomics", path: "compute/atomics" },
  { label: "gpu-timing", path: "diagnostics/gpu-timing" }
];

test("navigation contains only the planned WebGPU feature cases", async ({ page }) => {
  await page.goto("/");
  const catalog = await page.evaluate(async () => (await fetch("/dist/.demoList.json")).json());
  expect(catalog.Advance.map((example: { label: string }) => example.label)).toEqual([
    "Device restore",
    "GLTF Loader",
    "Project Loader"
  ]);
  expect(JSON.stringify(catalog).toLowerCase()).not.toContain("splat");
  expect(catalog.WebGPU.map((example: { label: string }) => example.label)).toEqual([
    "01 Backend Initialization",
    "02 ShaderLab Triangle",
    "03 Index Buffer",
    "04 Buffer Update",
    "05 Uniform Update",
    "06 Texture Sampling",
    "07 Cube Texture",
    "08 Instanced Draw",
    "09 Render Target",
    "10 Depth Test",
    "11 MSAA Render Target",
    "12 Compute Sampled Texture",
    "13 Compute Storage Buffer",
    "14 Compute Atomics",
    "15 GPU Timing",
    "16 Grasslands Benchmark"
  ]);
  expect(catalog.WebGPU.map((example: { backend: Backend }) => example.backend)).toEqual(
    Array<Backend>(16).fill("webgpu")
  );

  await expect(page.getByRole("heading", { name: "WebGPU" })).toBeVisible();
  await expect(page.locator('[title="gaussian-splatting"]')).toHaveCount(0);
  await page.locator('[title="webgpu/basics/backend-init"]').click();
  await expect(page).toHaveURL(/#dist\/webgpu\/basics\/backend-init\?backend=webgpu$/);
  await expect(page.locator("iframe")).toHaveAttribute("src", "dist/webgpu/basics/backend-init.html?backend=webgpu");
  await expect(page.frameLocator("iframe").locator("#example-status")).toContainText("webgpu engine + swapchain ready");
});

test("backend selector reloads the document before creating the next engine", async ({ page }) => {
  const errors = collectRuntimeErrors(page);
  await page.goto("/dist/webgpu/basics/shaderlab-triangle.html?backend=webgl2");
  await waitUntilReady(page);
  await page.evaluate(() => {
    document.documentElement.dataset.backendSwitchSentinel = "old-document";
  });
  await Promise.all([
    page.waitForURL((url) => url.searchParams.get("backend") === "webgpu"),
    page.locator("#example-backend").selectOption("webgpu")
  ]);
  await waitUntilReady(page);

  expect(await page.evaluate(() => document.documentElement.dataset.backendSwitchSentinel)).toBeUndefined();
  expect(await page.evaluate(() => document.documentElement.dataset.exampleBackend)).toBe("webgpu");
  expect(errors).toEqual([]);
});

for (const feature of dualBackendFeatures) {
  test(`${feature.label} renders the same public API workload on both backends`, async ({
    browser,
    baseURL
  }, testInfo) => {
    expect(baseURL).toBeDefined();
    const webGL2 = await captureFeature(browser, baseURL!, feature.path, "webgl2");
    const webGPU = await captureFeature(browser, baseURL!, feature.path, "webgpu");
    await attachScreenshot(testInfo, `${feature.label}-webgl2`, webGL2.screenshot);
    await attachScreenshot(testInfo, `${feature.label}-webgpu`, webGPU.screenshot);

    expect(webGL2.errors).toEqual([]);
    expect(webGPU.errors).toEqual([]);
    const comparison = await analyzeScreenshots(browser, webGL2.screenshot, webGPU.screenshot);
    expect(comparison.baseline.uniqueColors).toBeGreaterThan(1);
    expect(comparison.candidate!.uniqueColors).toBeGreaterThan(1);
    expect(comparison.baseline.dominantColorRatio).toBeLessThan(0.97);
    expect(comparison.candidate!.dominantColorRatio).toBeLessThan(0.97);
    expect(comparison.meanAbsoluteDifference!).toBeLessThan(0.05);
  });
}

for (const feature of webGPUFeatures) {
  test(`${feature.label} renders through the WebGPU-only public API`, async ({ browser, baseURL }, testInfo) => {
    expect(baseURL).toBeDefined();
    const result = await captureFeature(browser, baseURL!, feature.path, "webgpu");
    await attachScreenshot(testInfo, `${feature.label}-webgpu`, result.screenshot);

    expect(result.errors).toEqual([]);
    const analysis = await analyzeScreenshots(browser, result.screenshot);
    expect(analysis.baseline.uniqueColors).toBeGreaterThan(1);
    expect(analysis.baseline.dominantColorRatio).toBeLessThan(0.97);
  });
}

test("benchmark defaults to WebGPU and reloads its backend and candidates controls", async ({ page }) => {
  const errors = collectRuntimeErrors(page);
  await page.goto("/dist/webgpu/benchmark/instancing.html");
  await waitUntilBenchmarkReady(page);

  expect(await inspectBenchmark(page)).toMatchObject({ backend: "webgpu", candidates: 2 ** 13 });
  expect(await page.locator("#benchmark-controls > label").allTextContents()).toEqual(["backend", "candidates"]);
  await expect(page.locator("#benchmark-controls > select")).toHaveCount(1);
  await expect(page.locator('#benchmark-controls > input[type="range"]')).toHaveCount(1);
  await expect.poll(() => page.locator("#fps").textContent()).toMatch(/\d/);

  await page.evaluate(() => {
    document.documentElement.dataset.backendSwitchSentinel = "old-document";
  });
  await Promise.all([
    page.waitForURL((url) => url.searchParams.get("backend") === "webgl2"),
    page.locator("#backend").selectOption("webgl2")
  ]);
  await waitUntilBenchmarkReady(page);
  expect(await page.evaluate(() => document.documentElement.dataset.backendSwitchSentinel)).toBeUndefined();
  expect(await inspectBenchmark(page)).toMatchObject({ backend: "webgl2", candidates: 2 ** 13 });
  expect(errors).toEqual([]);
});

test("benchmark slider can drive WebGL2 below the interactive frame budget", async ({ page }) => {
  const errors = collectRuntimeErrors(page);
  await page.goto("/dist/webgpu/benchmark/instancing.html?backend=webgl2");
  await waitUntilBenchmarkReady(page);
  await page.locator("#candidates").evaluate((control: HTMLInputElement) => {
    control.value = control.max;
    control.dispatchEvent(new Event("input", { bubbles: true }));
  });
  await expect.poll(async () => (await inspectBenchmark(page)).sampleCount).toBeGreaterThanOrEqual(120);

  const snapshot = await inspectBenchmark(page);
  expect(snapshot.candidates).toBe(2 ** 22);
  expect(snapshot.fpsMedian).toBeGreaterThan(0);
  expect(snapshot.fpsMedian).toBeLessThan(55);
  expect(snapshot.frameTimeP95).toBeGreaterThan(18);
  expect(errors).toEqual([]);
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

async function waitUntilReady(page: Page): Promise<void> {
  await page.waitForFunction(
    () => document.documentElement.dataset.exampleReady || document.documentElement.dataset.exampleError
  );
  const error = await page.evaluate(() => document.documentElement.dataset.exampleError);
  expect(error).toBeUndefined();
  await page.evaluate(
    () => new Promise<void>((resolve) => requestAnimationFrame(() => requestAnimationFrame(() => resolve())))
  );
}

async function waitUntilBenchmarkReady(page: Page): Promise<void> {
  await page.waitForFunction(() =>
    Boolean((window as Window & { webgpuBenchmark?: { ready: boolean } }).webgpuBenchmark?.ready)
  );
}

async function inspectBenchmark(page: Page): Promise<{
  backend: Backend;
  candidates: number;
  fpsMedian: number;
  frameTimeP95: number;
  sampleCount: number;
}> {
  return page.evaluate(() =>
    (
      window as unknown as Window & {
        webgpuBenchmark: {
          inspect(): {
            backend: Backend;
            candidates: number;
            fpsMedian: number;
            frameTimeP95: number;
            sampleCount: number;
          };
        };
      }
    ).webgpuBenchmark.inspect()
  );
}

async function captureFeature(
  browser: Browser,
  baseURL: string,
  featurePath: string,
  backend: Backend
): Promise<{ screenshot: Buffer; errors: string[] }> {
  const page = await browser.newPage({ viewport: { width: 1024, height: 576 } });
  const errors = collectRuntimeErrors(page);
  await page.goto(`${baseURL}/dist/webgpu/${featurePath}.html?backend=${backend}`);
  await waitUntilReady(page);
  const screenshot = await page.locator("canvas").screenshot({ type: "png" });
  await page.close();
  return { screenshot, errors };
}

async function attachScreenshot(testInfo: TestInfo, name: string, screenshot: Buffer): Promise<void> {
  await testInfo.attach(name, { body: screenshot, contentType: "image/png" });
}

async function analyzeScreenshots(
  browser: Browser,
  baseline: Buffer,
  candidate?: Buffer
): Promise<{
  baseline: { uniqueColors: number; dominantColorRatio: number };
  candidate?: { uniqueColors: number; dominantColorRatio: number };
  meanAbsoluteDifference?: number;
}> {
  const page = await browser.newPage();
  const dataUrls = [baseline, candidate]
    .filter(Boolean)
    .map((image) => `data:image/png;base64,${image!.toString("base64")}`);
  const result = await page.evaluate(async (sources) => {
    const loadPixels = async (source: string): Promise<Uint8ClampedArray> => {
      const image = await new Promise<HTMLImageElement>((resolve, reject) => {
        const element = new Image();
        element.onload = () => resolve(element);
        element.onerror = reject;
        element.src = source;
      });
      const canvas = new OffscreenCanvas(image.width, image.height);
      const context = canvas.getContext("2d")!;
      context.drawImage(image, 0, 0);
      return context.getImageData(0, 0, image.width, image.height).data;
    };
    const images = await Promise.all(sources.map(loadPixels));
    const stats = (pixels: Uint8ClampedArray) => {
      const histogram = new Map<number, number>();
      for (let offset = 0; offset < pixels.length; offset += 4) {
        const color = ((pixels[offset] >> 4) << 8) | ((pixels[offset + 1] >> 4) << 4) | (pixels[offset + 2] >> 4);
        histogram.set(color, (histogram.get(color) ?? 0) + 1);
      }
      return {
        uniqueColors: histogram.size,
        dominantColorRatio: Math.max(...histogram.values()) / (pixels.length / 4)
      };
    };
    const difference = images[1]
      ? images[0].reduce((total, value, index) => {
          if (index % 4 === 3) return total;
          return total + Math.abs(value - images[1][index]);
        }, 0) /
        ((images[0].length / 4) * 3 * 255)
      : undefined;
    return {
      baseline: stats(images[0]),
      candidate: images[1] ? stats(images[1]) : undefined,
      meanAbsoluteDifference: difference
    };
  }, dataUrls);
  await page.close();
  return result;
}
