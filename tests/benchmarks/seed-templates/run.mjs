import { chromium } from "@playwright/test";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";

const out = path.resolve(process.env.RESULTS || process.argv[2] || "seed-measurements");
const templates = (process.env.TEMPLATES || "sakura-pearl,titan-wasteland").split(",");
const backends = (process.env.BACKENDS || "webgl2,webgpu").split(",");
const variants = (process.env.VARIANTS || "full,no-grass,no-vegetation,no-occlusion,no-ssr,no-bloom").split(",");
const modes = (process.env.MODES || "cpu,gpu").split(",");
const seed = Number(process.env.SEED || 20261122);
const frames = Number(process.env.FRAMES || 180),
  warmup = Number(process.env.WARMUP || 30);
const width = Number(process.env.WIDTH || 960),
  height = Number(process.env.HEIGHT || 540);
const profileCpu = process.env.PROFILE_CPU === "1",
  uploadSources = process.env.UPLOAD_SOURCES === "1";
if ((profileCpu || uploadSources) && modes.some((mode) => mode !== "cpu")) {
  throw Error("Run CPU diagnostics separately with MODES=cpu.");
}
if (profileCpu && frames < 4) throw Error("CPU profiling needs at least one frame outside the three inspections.");
const diagnostics = profileCpu || uploadSources ? await import("./diagnostics.mjs") : null;
const metrics = (await readFile(new URL("./metrics.mjs", import.meta.url), "utf8")).replace(/^export /gm, "");
function observeValidationErrors() {
  const errors = (globalThis.seedGPUValidation = { count: 0, messages: [] });
  if (!globalThis.GPUAdapter) return;
  const requestDevice = GPUAdapter.prototype.requestDevice;
  GPUAdapter.prototype.requestDevice = async function (...args) {
    const device = await requestDevice.apply(this, args);
    device.addEventListener("uncapturederror", (event) => {
      errors.count++;
      const message = event.error.message;
      if (errors.messages.length < 20 && !errors.messages.includes(message)) errors.messages.push(message);
    });
    return device;
  };
}
const setup =
  "(() => {" +
  metrics +
  "\ninstallSeedMetrics(); (" +
  observeValidationErrors.toString() +
  ")(); globalThis.measureSeedTemplate = measureSeedTemplate; " +
  (uploadSources ? "globalThis.__seedCaptureTransfers = " + diagnostics.captureTransfers.toString() + ";" : "") +
  "})();";
const urls = {
  webgl2: process.env.GL_URL ?? "http://127.0.0.1:15483",
  webgpu: process.env.GPU_URL ?? "http://127.0.0.1:15482"
};
await mkdir(out, { recursive: true });
const browser = await chromium.launch({ args: ["--ignore-gpu-blocklist", "--use-gl=angle"] });
let failures = 0;
try {
  for (const template of templates) {
    const pathFile = path.join(out, template + "-camera.json");
    let cameraPath;
    try {
      cameraPath = JSON.parse(await readFile(pathFile, "utf8"));
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
    }
    for (const [variantIndex, variant] of variants.entries()) {
      const order = (templates.indexOf(template) + variantIndex) % 2 ? [...backends].reverse() : backends;
      for (const backend of order) {
        for (const mode of modes) {
          const id = [template, variant, backend, mode].join("-");
          const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 1 });
          let profiler;
          const errors = [];
          page.on("pageerror", (error) => errors.push(String(error)));
          page.on("console", (message) => {
            if (message.type() === "error" && /validat|shader|pipeline|device lost/i.test(message.text()))
              errors.push(message.text().slice(0, 1200));
          });
          try {
            if (profileCpu) profiler = await diagnostics.attachCpuProfiler(page, out, id);
            await page.addInitScript({ content: setup });
            const url = new URL("/world/demos/seed-world/index.html", urls[backend]);
            url.search = new URLSearchParams({ template, seed: String(seed), view: "3d" });
            await page.goto(url.href, { waitUntil: "commit" });
            const ready = await page.waitForFunction(
              () => {
                if (globalThis.__seedBenchmarkContext) return { ready: true };
                const canvas = document.querySelector('canvas[data-status="error"]');
                return canvas ? { error: canvas.dataset.error || "Seed startup failed" } : false;
              },
              undefined,
              { timeout: 150000 }
            );
            const status = await ready.jsonValue();
            if (status.error) throw Error(status.error);
            const options = {
              template,
              seed,
              variant,
              mode,
              frames,
              warmup,
              width,
              height,
              gpuPassTimings: process.env.PASS_TIMINGS === "1",
              ...(profileCpu && { profileCpu }),
              ...(uploadSources && { uploadSources }),
              path: cameraPath,
              image: mode === "cpu"
            };
            const result = await page.evaluate(
              (options) => globalThis.measureSeedTemplate(undefined, options),
              options
            );
            if (result.backend !== backend) throw Error("Unexpected active backend " + result.backend);
            if (!cameraPath) {
              cameraPath = result.path;
              await writeFile(pathFile, JSON.stringify(cameraPath, null, 2));
            }
            if (result.png) {
              await writeFile(path.join(out, id + ".png"), Buffer.from(result.png, "base64"));
              delete result.png;
            }
            const validation = await page.evaluate(() => globalThis.seedGPUValidation);
            const adapter = await page.evaluate(() => {
              const { canvas, engine } = globalThis.__seedBenchmarkContext;
              const hardware = engine._hardwareRenderer;
              if (hardware.adapter) {
                const { vendor, architecture, device, description } = hardware.adapter.info;
                return { vendor, architecture, device, description };
              }
              const gl = canvas.getContext("webgl2");
              const info = gl.getExtension("WEBGL_debug_renderer_info");
              return { description: gl.getParameter(info?.UNMASKED_RENDERER_WEBGL ?? gl.RENDERER) };
            });
            Object.assign(result, { browser: browser.version(), adapter, url: url.href, errors, validation });
            if (profiler) result.cpuProfile = profiler.describe();
            await writeFile(path.join(out, id + ".json"), JSON.stringify(result, null, 2));
            await rm(path.join(out, id + "-error.json"), { force: true });
            console.log(
              id,
              JSON.stringify({
                cpu: result.cpuUpdateMs,
                gpu: result.gpuMs,
                errors: errors.length,
                validation: validation.count
              })
            );
            if (
              errors.length ||
              validation.count ||
              result.webglErrors?.length ||
              (mode === "gpu" && !result.gpuMs?.samples)
            ) {
              failures++;
            }
          } catch (error) {
            failures++;
            console.error(id, String(error), errors.slice(0, 3));
            await writeFile(
              path.join(out, id + "-error.json"),
              JSON.stringify({ error: String(error), errors }, null, 2)
            );
          } finally {
            if (profiler) await profiler.close();
            await page.close();
          }
        }
      }
    }
  }
} finally {
  await browser.close();
}
if (failures) process.exitCode = 1;
