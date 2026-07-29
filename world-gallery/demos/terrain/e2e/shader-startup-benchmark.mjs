import { chromium } from "@playwright/test";
import { gzipSync } from "node:zlib";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const baseUrl = process.env.BENCHMARK_URL ?? "http://127.0.0.1:5175";
const roundCount = Number(process.env.BENCHMARK_ROUNDS ?? 10);
if (!Number.isInteger(roundCount) || roundCount < 1) {
  throw new RangeError(`BENCHMARK_ROUNDS must be a positive integer, received ${roundCount}.`);
}

const executablePath = process.env.BENCHMARK_BROWSER_EXECUTABLE ?? chromium.executablePath();
const browser = await chromium.launch({
  executablePath,
  headless: true,
  args: ["--enable-unsafe-webgpu", "--use-angle=metal"]
});
const results = [];

for (const backend of ["webgl2", "webgpu"]) {
  for (let round = 0; round < roundCount; round++) {
    const modes = round % 2 === 0 ? ["runtime", "precompiled"] : ["precompiled", "runtime"];
    for (const mode of modes) {
      const context = await browser.newContext({
        viewport: { width: 1024, height: 576 },
        deviceScaleFactor: 2
      });
      const page = await context.newPage();
      const diagnostics = [];
      const artifactRequests = [];
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
      page.on("request", (request) => {
        const pathname = new URL(request.url()).pathname;
        if (/\.(shaderc|wgslc)$/.test(pathname)) artifactRequests.push(pathname);
      });

      const url = new URL("/demos/terrain/grasslands/", baseUrl);
      url.searchParams.set("backend", backend);
      url.searchParams.set("shaderMode", mode);
      url.searchParams.set("pose", "terrain-horizon");
      const navigationStartedAt = performance.now();
      await page.goto(url.href, { waitUntil: "networkidle", timeout: 120_000 });
      await page.waitForFunction(() => window.grasslandsDebug?.ready === true, undefined, {
        timeout: 120_000
      });
      const navigationReadyMs = performance.now() - navigationStartedAt;
      const startup = await page.evaluate(() => window.grasslandsDebug.inspectStartup());
      const surface = await page.evaluate(() => {
        const snapshot = window.grasslandsDebug.inspectSurface();
        return {
          visibleInstances: snapshot.visibleInstances,
          visibleRendererBatches: snapshot.visibleRendererBatches,
          indirectRendererBatches: snapshot.indirectRendererBatches,
          visibleCategoryCounts: snapshot.visibleCategoryCounts,
          lodCounts: snapshot.lodCounts
        };
      });
      results.push({
        round: round + 1,
        backend,
        mode,
        navigationReadyMs,
        startup,
        artifactRequests,
        surface,
        diagnostics
      });
      await context.close();
    }
  }
}

const browserVersion = browser.version();
await browser.close();

const summary = Object.fromEntries(
  ["webgl2", "webgpu"].flatMap((backend) =>
    ["runtime", "precompiled"].map((mode) => {
      const samples = results.filter((sample) => sample.backend === backend && sample.mode === mode);
      return [
        `${backend}-${mode}`,
        {
          shaderRegistrationMs: summarize(samples.map((sample) => sample.startup.durationMs)),
          sceneReadyMs: summarize(samples.map((sample) => sample.startup.sceneReadyDurationMs)),
          navigationReadyMs: summarize(samples.map((sample) => sample.navigationReadyMs))
        }
      ];
    })
  )
);

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const artifactDirectory = path.resolve(scriptDirectory, "../../../public/compiledShaders/terrain");
const artifactSizes = Object.fromEntries(
  ["Terrain.shaderc", "Surface.shaderc", "Terrain.wgslc", "Surface.wgslc"].map((name) => {
    const bytes = readFileSync(path.join(artifactDirectory, name));
    return [name, { rawBytes: bytes.byteLength, gzipBytes: gzipSync(bytes).byteLength }];
  })
);

const failedSamples = results.filter((sample) => sample.diagnostics.length > 0);
console.log(
  JSON.stringify(
    {
      browser: { executablePath, version: browserVersion },
      cache: "cold; a new browser context is created for every sample",
      viewport: { width: 1024, height: 576, deviceScaleFactor: 2 },
      roundCount,
      summary,
      artifactSizes,
      results
    },
    null,
    2
  )
);
if (failedSamples.length > 0) {
  throw new Error(`${failedSamples.length} shader startup sample(s) reported diagnostics.`);
}

function summarize(values) {
  const sorted = [...values].sort((left, right) => left - right);
  return {
    median: percentile(sorted, 0.5),
    p95: percentile(sorted, 0.95),
    min: sorted[0],
    max: sorted.at(-1)
  };
}

function percentile(sortedValues, fraction) {
  return sortedValues[Math.min(sortedValues.length - 1, Math.floor(sortedValues.length * fraction))];
}
