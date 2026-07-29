import { expect, test, type Browser, type Page, type TestInfo } from "@playwright/test";

const comparisonCandidates = 2 ** 20;
const maximumCandidates = 2 ** 24;

test("backend selector reloads the document and preserves candidates", async ({ page }) => {
  const errors = collectRuntimeErrors(page);
  await page.goto(
    `/dist/webgpu-benchmark.html?backend=webgl2&candidates=${comparisonCandidates}`
  );
  await waitUntilReady(page);

  await page.evaluate(() => {
    document.documentElement.dataset.backendSwitchSentinel = "old-document";
  });
  await Promise.all([
    page.waitForURL(
      (url) =>
        url.searchParams.get("backend") === "webgpu" &&
        url.searchParams.get("candidates") === comparisonCandidates.toString()
    ),
    page.locator("#backend").selectOption("webgpu")
  ]);
  await waitUntilReady(page);

  expect(
    await page.evaluate(() => document.documentElement.dataset.backendSwitchSentinel)
  ).toBeUndefined();
  expect(await page.evaluate(() => window.webgpuBenchmark!.inspect())).toMatchObject({
    backend: "webgpu",
    candidates: comparisonCandidates
  });
  await expect(page.locator("#benchmark-controls > *")).toHaveCount(4);
  expect(await page.locator("#benchmark-controls > label").allTextContents()).toEqual([
    "backend",
    "candidates"
  ]);
  await expect(page.locator("#benchmark-controls > select")).toHaveCount(1);
  await expect(page.locator('#benchmark-controls > input[type="range"]')).toHaveCount(1);
  expect(errors).toEqual([]);
});

test("the same candidate workload renders on WebGL2 and WebGPU", async (
  { browser, baseURL },
  testInfo
) => {
  expect(baseURL).toBeDefined();
  const webGL2 = await captureBackend(browser, baseURL!, "webgl2");
  const webGPU = await captureBackend(browser, baseURL!, "webgpu");

  expect(webGL2.errors).toEqual([]);
  expect(webGPU.errors).toEqual([]);
  expect(webGPU.snapshot.candidates).toBe(webGL2.snapshot.candidates);
  expect(webGPU.snapshot.candidates).toBe(comparisonCandidates);
  expect(webGL2.snapshot.gpuTimingSupported).toBe(false);
  if (webGPU.snapshot.gpuTimingSupported) {
    expect(webGPU.snapshot.gpuSampleCount).toBeGreaterThanOrEqual(5);
    expect(webGPU.snapshot.gpuFrameTimeMedian).toBeGreaterThan(0);
    expect(webGPU.snapshot.gpuFrameTimeP95).toBeGreaterThan(0);
    expect(webGPU.snapshot.gpuPassCount).toBeGreaterThan(0);
  } else {
    expect(webGPU.snapshot.gpuSampleCount).toBe(0);
    expect(webGPU.snapshot.gpuFrameTimeMedian).toBeNull();
    expect(webGPU.snapshot.gpuFrameTimeP95).toBeNull();
  }

  await attachBackendScreenshot(testInfo, "webgl2", webGL2.screenshot);
  await attachBackendScreenshot(testInfo, "webgpu", webGPU.screenshot);
  const comparison = await analyzeScreenshots(
    browser,
    webGL2.screenshot,
    webGPU.screenshot
  );
  expect(comparison.baseline.uniqueColors).toBeGreaterThan(20);
  expect(comparison.candidate.uniqueColors).toBeGreaterThan(20);
  expect(comparison.baseline.dominantColorRatio).toBeLessThan(0.9);
  expect(comparison.candidate.dominantColorRatio).toBeLessThan(0.9);
  expect(comparison.histogramTotalVariation).toBeLessThan(0.01);
});

test("the candidates slider can push WebGL2 into a stable low-FPS workload", async ({
  page
}) => {
  const errors = collectRuntimeErrors(page);
  await page.goto("/dist/webgpu-benchmark.html?backend=webgl2");
  await waitUntilReady(page);

  await page.locator("#candidates").evaluate((control: HTMLInputElement) => {
    control.value = control.max;
    control.dispatchEvent(new Event("input", { bubbles: true }));
  });
  await expect
    .poll(() => page.evaluate(() => window.webgpuBenchmark!.inspect().sampleCount))
    .toBeGreaterThanOrEqual(60);

  const snapshot = await page.evaluate(() => window.webgpuBenchmark!.inspect());
  expect(snapshot).toMatchObject({
    backend: "webgl2",
    candidates: maximumCandidates
  });
  expect(new URL(page.url()).searchParams.get("candidates")).toBe(
    maximumCandidates.toString()
  );
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
  await page.waitForFunction(() => window.webgpuBenchmark?.ready);
  await expect
    .poll(() => page.evaluate(() => window.webgpuBenchmark!.inspect().sampleCount))
    .toBeGreaterThanOrEqual(30);
  const gpuTimingSupported = await page.evaluate(
    () => window.webgpuBenchmark!.inspect().gpuTimingSupported
  );
  if (gpuTimingSupported) {
    await collectGPUTimingSamples(page, 5);
  }
}

async function collectGPUTimingSamples(page: Page, targetCount: number): Promise<void> {
  await expect
    .poll(() =>
      page.evaluate((target) => {
        const benchmark = window.webgpuBenchmark!;
        const sampleCount = benchmark.inspect().gpuSampleCount;
        if (sampleCount < target) {
          benchmark.requestGPUTimingSample();
        }
        return sampleCount;
      }, targetCount)
    )
    .toBeGreaterThanOrEqual(targetCount);
}

async function captureBackend(
  browser: Browser,
  baseURL: string,
  backend: "webgl2" | "webgpu"
): Promise<{
  screenshot: Buffer;
  snapshot: ReturnType<NonNullable<Window["webgpuBenchmark"]>["inspect"]>;
  errors: string[];
}> {
  const page = await browser.newPage({ viewport: { width: 1024, height: 576 } });
  const errors = collectRuntimeErrors(page);
  await page.goto(
    `${baseURL}/dist/webgpu-benchmark.html?backend=${backend}&candidates=${comparisonCandidates}`
  );
  await waitUntilReady(page);
  await page.addStyleTag({ content: "#benchmark-controls{display:none!important}" });
  await page.evaluate(
    () =>
      new Promise<void>((resolve) =>
        requestAnimationFrame(() => requestAnimationFrame(() => resolve()))
      )
  );
  const snapshot = await page.evaluate(() => window.webgpuBenchmark!.inspect());
  const screenshot = await page.screenshot({ type: "png" });
  await page.close();
  return { screenshot, snapshot, errors };
}

async function attachBackendScreenshot(
  testInfo: TestInfo,
  backend: "webgl2" | "webgpu",
  screenshot: Buffer
): Promise<void> {
  await testInfo.attach(`benchmark-${backend}`, {
    body: screenshot,
    contentType: "image/png"
  });
}

async function analyzeScreenshots(
  browser: Browser,
  baseline: Buffer,
  candidate: Buffer
): Promise<{
  baseline: { uniqueColors: number; dominantColorRatio: number };
  candidate: { uniqueColors: number; dominantColorRatio: number };
  histogramTotalVariation: number;
}> {
  const page = await browser.newPage();
  const dataUrls = [baseline, candidate].map(
    (image) => `data:image/png;base64,${image.toString("base64")}`
  );
  const result = await page.evaluate(async ([baselineUrl, candidateUrl]) => {
    const loadPixels = async (
      source: string
    ): Promise<{ width: number; height: number; pixels: Uint8ClampedArray }> => {
      const image = await new Promise<HTMLImageElement>((resolve, reject) => {
        const element = new Image();
        element.onload = () => resolve(element);
        element.onerror = reject;
        element.src = source;
      });
      const canvas = new OffscreenCanvas(image.width, image.height);
      const context = canvas.getContext("2d")!;
      context.drawImage(image, 0, 0);
      return {
        width: image.width,
        height: image.height,
        pixels: context.getImageData(0, 0, image.width, image.height).data
      };
    };
    const [baselineImage, candidateImage] = await Promise.all([
      loadPixels(baselineUrl),
      loadPixels(candidateUrl)
    ]);
    if (
      baselineImage.width !== candidateImage.width ||
      baselineImage.height !== candidateImage.height
    ) {
      throw new Error("Backend screenshots have different dimensions.");
    }

    const imageStats = (
      pixels: Uint8ClampedArray
    ): { uniqueColors: number; dominantColorRatio: number } => {
      const histogram = new Map<number, number>();
      for (let offset = 0; offset < pixels.length; offset += 4) {
        const color =
          ((pixels[offset] >> 4) << 8) |
          ((pixels[offset + 1] >> 4) << 4) |
          (pixels[offset + 2] >> 4);
        histogram.set(color, (histogram.get(color) ?? 0) + 1);
      }
      return {
        uniqueColors: histogram.size,
        dominantColorRatio:
          Math.max(...histogram.values()) / (pixels.length / 4)
      };
    };

    // Subpixel triangles intentionally amplify backend rasterization rules, so compare their rendered distribution.
    const histogram = (pixels: Uint8ClampedArray): Map<number, number> => {
      const counts = new Map<number, number>();
      for (let offset = 0; offset < pixels.length; offset += 4) {
        const color =
          ((pixels[offset] >> 4) << 8) |
          ((pixels[offset + 1] >> 4) << 4) |
          (pixels[offset + 2] >> 4);
        counts.set(color, (counts.get(color) ?? 0) + 1);
      }
      return counts;
    };
    const baselineHistogram = histogram(baselineImage.pixels);
    const candidateHistogram = histogram(candidateImage.pixels);
    const colors = new Set([
      ...baselineHistogram.keys(),
      ...candidateHistogram.keys()
    ]);
    let histogramDifference = 0;
    for (const color of colors) {
      histogramDifference += Math.abs(
        (baselineHistogram.get(color) ?? 0) -
          (candidateHistogram.get(color) ?? 0)
      );
    }
    const pixelCount = baselineImage.pixels.length / 4;
    return {
      baseline: imageStats(baselineImage.pixels),
      candidate: imageStats(candidateImage.pixels),
      histogramTotalVariation: histogramDifference / (pixelCount * 2)
    };
  }, dataUrls);
  await page.close();
  return result;
}
