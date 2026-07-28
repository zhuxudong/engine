import { chromium } from "@playwright/test";

const variants = {
  beforeCompute:
    process.env.BASELINE_URL ?? "http://127.0.0.1:5188/demos/terrain/grasslands/?backend=webgpu",
  gpuCompaction:
    process.env.CANDIDATE_URL ?? "http://127.0.0.1:5187/demos/terrain/grasslands/?backend=webgpu"
};
const churnLods = process.env.BENCHMARK_LOD_CHURN === "1";
const executablePath = process.env.BENCHMARK_BROWSER_EXECUTABLE ?? chromium.executablePath();
const orders = [
  ["beforeCompute", "gpuCompaction"],
  ["gpuCompaction", "beforeCompute"],
  ["beforeCompute", "gpuCompaction"]
];
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
    await page.goto(variants[variant], { waitUntil: "networkidle", timeout: 120_000 });
    await page.waitForFunction(() => window.terrainDebug?.ready === true, undefined, { timeout: 120_000 });
    await page.evaluate(() => window.grasslandsDebug.setScene({ animation: false }));
    await page.waitForFunction(() => window.grasslandsDebug.inspectSurface().transitioningRanges === 0);
    await page.waitForTimeout(1_800);
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
      fps: (frameTimes.length * 1_000) / duration,
      p50: sorted[Math.floor(sorted.length * 0.5)],
      p95: sorted[Math.floor(sorted.length * 0.95)],
      surface: await page.evaluate(() => window.grasslandsDebug.inspectSurface()),
      diagnostics
    });
    await page.close();
  }
}

await browser.close();
console.log(JSON.stringify({ browser: { executablePath, version: browserVersion }, churnLods, results }, null, 2));
