import { chromium } from "@playwright/test";

const variants = {
  beforeCompute: process.env.BASELINE_URL ?? "http://127.0.0.1:5188/demos/terrain/grasslands/?backend=webgpu",
  gpuCompaction: process.env.CANDIDATE_URL ?? "http://127.0.0.1:5187/demos/terrain/grasslands/?backend=webgpu"
};
const churnLods = process.env.BENCHMARK_LOD_CHURN === "1";
const compactOutput = process.env.BENCHMARK_COMPACT === "1";
const roundCount = Number(process.env.BENCHMARK_ROUNDS ?? 3);
const gpuSampleCount = Number(process.env.BENCHMARK_GPU_SAMPLES ?? 0);
if (!Number.isInteger(roundCount) || roundCount < 1) {
  throw new RangeError(`BENCHMARK_ROUNDS must be a positive integer, received ${roundCount}.`);
}
if (!Number.isInteger(gpuSampleCount) || gpuSampleCount < 0) {
  throw new RangeError(`BENCHMARK_GPU_SAMPLES must be a non-negative integer, received ${gpuSampleCount}.`);
}
const disabledCategories = (process.env.BENCHMARK_DISABLED_CATEGORIES ?? "")
  .split(",")
  .map((category) => category.trim())
  .filter(Boolean);
const executablePath = process.env.BENCHMARK_BROWSER_EXECUTABLE ?? chromium.executablePath();
const labels = {
  beforeCompute: process.env.BASELINE_LABEL ?? "beforeCompute",
  gpuCompaction: process.env.CANDIDATE_LABEL ?? "gpuCompaction"
};
const orders = Array.from({ length: roundCount }, (_, round) =>
  round % 2 === 0 ? ["beforeCompute", "gpuCompaction"] : ["gpuCompaction", "beforeCompute"]
);
const browser = await chromium.launch({
  executablePath,
  headless: true,
  args: ["--enable-unsafe-webgpu", "--use-angle=metal"]
});
const browserVersion = browser.version();
const context = await browser.newContext({
  viewport: { width: 1280, height: 720 },
  deviceScaleFactor: 2
});
const results = [];

for (let round = 0; round < orders.length; round++) {
  for (const variant of orders[round]) {
    const page = await context.newPage();
    const diagnostics = [];
    page.on("console", (message) => {
      if (
        message.type() === "error" ||
        (message.type() === "warning" &&
          /webgpu|gpu|renderpipeline|commandbuffer|vertex buffer|validation|invalid|exceeds/i.test(message.text()))
      ) {
        diagnostics.push(`${message.type()}: ${message.text()}`);
      }
    });
    page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));
    const navigationStartedAt = performance.now();
    const pageUrl = new URL(variants[variant]);
    if (gpuSampleCount > 0) pageUrl.searchParams.set("gpuTiming", "1");
    await page.goto(pageUrl.href, { waitUntil: "networkidle", timeout: 120_000 });
    await page.waitForFunction(() => window.terrainDebug?.ready === true, undefined, { timeout: 120_000 });
    const readyMs = performance.now() - navigationStartedAt;
    await page.evaluate(() => window.grasslandsDebug.setScene({ animation: false }));
    if (disabledCategories.length > 0) {
      await page.evaluate(
        (categories) =>
          window.grasslandsDebug.setSurface({
            enabled: Object.fromEntries(categories.map((category) => [category, false]))
          }),
        disabledCategories
      );
    }
    await page.waitForFunction(() => window.grasslandsDebug.inspectSurface().transitioningRanges === 0);
    await page.waitForTimeout(1_800);
    const gpuSamples = [];
    if (gpuSampleCount > 0) {
      const gpuTiming = await page.evaluate(() => window.grasslandsDebug.inspectGPUTiming());
      if (!gpuTiming.supported || !gpuTiming.enabled) {
        throw new Error(`${labels[variant]} does not support the requested GPU timestamp samples.`);
      }
      for (let sampleIndex = 0; sampleIndex < gpuSampleCount; sampleIndex++) {
        const previousSubmissionId = await page.evaluate(
          () => window.grasslandsDebug.inspectGPUTiming().latestSample?.submissionId ?? 0
        );
        const requested = await page.evaluate(() => window.grasslandsDebug.requestGPUTimingSample());
        if (!requested) {
          throw new Error(`${labels[variant]} rejected GPU timestamp sample ${sampleIndex + 1}.`);
        }
        await page.waitForFunction(
          (submissionId) => (window.grasslandsDebug.inspectGPUTiming().latestSample?.submissionId ?? 0) > submissionId,
          previousSubmissionId,
          { timeout: 15_000 }
        );
        gpuSamples.push(await page.evaluate(() => window.grasslandsDebug.inspectGPUTiming().latestSample));
      }
    }
    const frameTimes = await page.evaluate(
      (churn) =>
        new Promise((resolve) => {
          const samples = [];
          let startedAt;
          let previous;
          let nextLodToggle = 400;
          let expandedLodDistance = false;
          const sample = (now) => {
            if (startedAt === undefined) {
              startedAt = now;
              previous = now;
            } else {
              samples.push(now - previous);
              previous = now;
            }
            const elapsed = now - startedAt;
            if (churn && elapsed >= nextLodToggle) {
              expandedLodDistance = !expandedLodDistance;
              window.grasslandsDebug.setSurface({
                lod: { distanceScale: expandedLodDistance ? 1.5 : 0.5 }
              });
              nextLodToggle += 400;
            }
            if (elapsed < 3_000) {
              requestAnimationFrame(sample);
            } else {
              resolve(samples);
            }
          };
          requestAnimationFrame(sample);
        }),
      churnLods
    );
    const sorted = [...frameTimes].sort((left, right) => left - right);
    const duration = frameTimes.reduce((sum, value) => sum + value, 0);
    results.push({
      round: round + 1,
      variant,
      label: labels[variant],
      readyMs,
      fps: (frameTimes.length * 1_000) / duration,
      p50: sorted[Math.floor(sorted.length * 0.5)],
      p95: sorted[Math.floor(sorted.length * 0.95)],
      gpuSamples,
      surface: await page.evaluate(() => window.grasslandsDebug.inspectSurface()),
      diagnostics
    });
    await page.close();
  }
}

await browser.close();
const outputResults = compactOutput
  ? results.map(({ round, label, fps, p50, p95, gpuSamples, surface, diagnostics }) => ({
      round,
      label,
      fps,
      p50,
      p95,
      gpuSamples,
      surface: {
        visibleRendererBatches: surface.visibleRendererBatches,
        indirectRendererBatches: surface.indirectRendererBatches,
        visibleInstances: surface.visibleInstances,
        visibleCategoryCounts: surface.visibleCategoryCounts,
        lodCounts: surface.lodCounts
      },
      diagnostics
    }))
  : results;
console.log(
  JSON.stringify(
    {
      browser: { executablePath, version: browserVersion },
      roundCount,
      gpuSampleCount,
      churnLods,
      disabledCategories,
      results: outputResults
    },
    null,
    2
  )
);
