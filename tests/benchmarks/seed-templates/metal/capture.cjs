const fs = require("node:fs/promises");
const { createWriteStream } = require("node:fs");
const { spawn } = require("node:child_process");
const { createHash } = require("node:crypto");
const path = require("node:path");
const os = require("node:os");
const { execFileSync } = require("node:child_process");

const env = process.env;
const repo = path.resolve(env.REPO || process.cwd());
const cameraDir = path.resolve(env.CAMERA_DIR || path.join(process.cwd(), "seed-measurements"));
const output = path.resolve(env.RESULTS || path.join(process.cwd(), "seed-metal-results"));
const width = Number(env.WIDTH || 960),
  height = Number(env.HEIGHT || 540);
const frames = Number(env.FRAMES || 120),
  warmup = Number(env.WARMUP || 90),
  seed = Number(env.SEED || 20261122);
const templates = (env.TEMPLATES || "sakura-pearl,titan-wasteland").split(",");
const variants = (env.VARIANTS || "full").split(",");
const urls = { webgl2: env.GL_URL || "http://127.0.0.1:15483", webgpu: env.GPU_URL || "http://127.0.0.1:15482" };
const groups = [];
const reps = Number(env.REPS || 2);
const diskGiB = Number(env.DISK_GIB || 0);
if (!Number.isInteger(reps) || reps < 1 || reps > 8 || !Number.isFinite(diskGiB) || diskGiB < 0)
  throw Error("Invalid REPS or DISK_GIB");
for (const [variantIndex, variant] of variants.entries())
  for (let repetition = 0; repetition < reps; ++repetition) {
    for (const template of repetition ? [...templates].reverse() : templates) {
      // Every template runs AB and BA; alternate which API opens each group across templates.
      const templateIndex = templates.indexOf(template);
      const order = (repetition + templateIndex + variantIndex) % 2 ? ["webgpu", "webgl2"] : ["webgl2", "webgpu"];
      groups.push({
        id: [template, variant, repetition + 1].join("-"),
        template,
        variant,
        repetition: repetition + 1,
        order
      });
    }
  }

function childEnd(child) {
  return new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("exit", (code, signal) => resolve({ code, signal }));
  });
}
async function timed(promise, ms, message) {
  let timer;
  try {
    return await Promise.race([
      promise,
      new Promise((_, reject) => {
        timer = setTimeout(() => reject(Error(message)), ms);
      })
    ]);
  } finally {
    clearTimeout(timer);
  }
}
async function json(file, data) {
  await fs.writeFile(file, JSON.stringify(data, null, 2) + "\n");
}
function samePid(actual, expected) {
  if (actual !== expected) throw Error("Chromium GPU PID changed from " + expected + " to " + actual);
}
function recordValidation() {
  globalThis.__seedMetalErrors = [];
  if (!globalThis.GPUAdapter) return;
  const original = GPUAdapter.prototype.requestDevice;
  GPUAdapter.prototype.requestDevice = async function (...args) {
    const device = await original.apply(this, args);
    device.addEventListener("uncapturederror", (event) => {
      globalThis.__seedMetalErrors.push(event.error.message);
    });
    return device;
  };
}
async function pauseAndDrain(page) {
  return page.evaluate(async () => {
    const { engine, canvas } = globalThis.__seedBenchmarkContext;
    engine.pause();
    if (engine._hardwareRenderer.device) await engine._hardwareRenderer.device.queue.onSubmittedWorkDone();
    else canvas.getContext("webgl2").finish();
    return engine.isPaused;
  });
}
async function prepare(browser, backend, template, install) {
  const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 1 });
  const errors = [];
  page.on("pageerror", (e) => errors.push(String(e)));
  page.on("console", (msg) => {
    if (msg.type() === "error" && /validat|shader|pipeline|device lost/i.test(msg.text()))
      errors.push(msg.text().slice(0, 1500));
  });
  try {
    await page.addInitScript({ content: install });
    const url = new URL("/world/demos/seed-world/index.html", urls[backend]);
    url.search = new URLSearchParams({ template, seed: String(seed), view: "3d" });
    await page.goto(url.href, { waitUntil: "commit" });
    const handle = await page.waitForFunction(
      () =>
        globalThis.__seedBenchmarkContext
          ? { ready: true }
          : document.querySelector('canvas[data-status="error"]')?.dataset || false,
      undefined,
      { timeout: 150000 }
    );
    const status = await handle.jsonValue();
    if (!status.ready) throw Error("Seed publication failed: " + JSON.stringify(status));
    if (!(await pauseAndDrain(page))) throw Error("Could not pause the published engine");
    const lifecycle = await page.context().newCDPSession(page);
    await lifecycle.send("Page.setWebLifecycleState", { state: "frozen" });
    return { page, lifecycle, frozen: true, url: url.href, errors };
  } catch (e) {
    await page.close();
    throw e;
  }
}
async function recorder(pid, dir, group, developer, nativeArch) {
  const command = execFileSync("/bin/ps", ["-p", String(pid), "-o", "command="], { encoding: "utf8" });
  if (!/(?:^|\s)--type=gpu-process(?:\s|$)/.test(command)) throw Error("Expected a local Chromium GPU subprocess");
  const key = "com.galacean.seedmetal." + process.pid + "." + Math.random().toString(36).slice(2);
  const notify = spawn("/usr/bin/notifyutil", ["-1", key], { stdio: "ignore" });
  const ready = childEnd(notify);
  const log = createWriteStream(path.join(dir, "xctrace.log"));
  const proc = spawn(
    "/usr/bin/arch",
    [
      "-" + nativeArch,
      "/usr/bin/xcrun",
      "xctrace",
      "record",
      // Omitting --device selects the host. The exported trace is also checked against the Mac's hardware UUID.
      "--template",
      "Metal System Trace",
      "--no-prompt",
      "--notify-tracing-started",
      key,
      "--run-name",
      group.id,
      "--output",
      path.join(dir, "gpu.trace"),
      "--time-limit",
      "150s",
      "--attach",
      String(pid)
    ],
    { env: { ...env, DEVELOPER_DIR: developer }, stdio: ["ignore", "pipe", "pipe"] }
  );
  proc.stdout.pipe(log, { end: false });
  proc.stderr.pipe(log, { end: false });
  const ended = childEnd(proc);
  try {
    await timed(
      Promise.race([
        ready.then((r) => {
          if (r.code !== 0) throw Error("Trace start notification failed");
        }),
        ended.then((r) => {
          throw Error("Mac xctrace exited before attach: " + JSON.stringify(r));
        })
      ]),
      65000,
      "Trace attach timed out"
    );
  } catch (e) {
    // A failed local Instruments service connection can ignore SIGINT while blocked in Mach IPC.
    // At this point no recording started. Reap only the xctrace child created for this pair.
    if (proc.exitCode === null && !proc.signalCode) proc.kill("SIGTERM");
    try {
      await timed(ended, 5000, "The failed local attach did not terminate.");
    } catch {
      if (proc.exitCode === null && !proc.signalCode) proc.kill("SIGKILL");
      await ended;
    } finally {
      log.end();
    }
    throw e;
  } finally {
    if (notify.exitCode === null) notify.kill();
  }
  return {
    ended,
    async stop() {
      if (proc.exitCode === null && !proc.signalCode) proc.kill("SIGINT");
      const result = await timed(ended, 720000, "Timed out finalizing local Metal trace");
      log.end();
      if (result.code !== 0) throw Error("xctrace recording failed: " + JSON.stringify(result));
    }
  };
}
async function main() {
  if (process.platform !== "darwin") throw Error("Mac desktop tracing requires macOS.");
  const localDevice = /"IOPlatformUUID" = "([\da-f-]{36})"/i.exec(
    execFileSync("/usr/sbin/ioreg", ["-rd1", "-c", "IOPlatformExpertDevice"], { encoding: "utf8" })
  )?.[1];
  if (!localDevice) throw Error("Cannot identify the local Mac for Metal System Trace.");
  const nativeArch =
    execFileSync("/usr/sbin/sysctl", ["-in", "hw.optional.arm64"], { encoding: "utf8" }).trim() === "1"
      ? "arm64"
      : "x86_64";
  if (
    ![frames, warmup, width, height].every(Number.isSafeInteger) ||
    frames < 4 ||
    width < 1 ||
    height < 1 ||
    warmup < 1
  )
    throw Error("Invalid measurement workload");
  const metrics = (await fs.readFile(path.join(repo, "tests/benchmarks/seed-templates/metrics.mjs"), "utf8")).replace(
    /^export /gm,
    ""
  );
  if (!metrics.includes("frameBoundariesEpochMs")) throw Error("metrics.mjs must expose native frame boundaries");
  const cameras = Object.fromEntries(
    await Promise.all(
      templates.map(async (template) => [
        template,
        JSON.parse(await fs.readFile(path.join(cameraDir, template + "-camera.json")))
      ])
    )
  );
  const provenance = {
    engineCommit: execFileSync("git", ["-C", repo, "rev-parse", "HEAD"], { encoding: "utf8" }).trim(),
    metricsSha256: createHash("sha256").update(metrics).digest("hex"),
    cameraSha256: Object.fromEntries(
      Object.entries(cameras).map(([name, data]) => [
        name,
        createHash("sha256").update(JSON.stringify(data)).digest("hex")
      ])
    )
  };
  const available = await fs.readdir("/Applications");
  const xcodes = available.filter((name) => /^Xcode([- ._0-9].*)?\.app$/.test(name)).sort();
  const developer =
    env.DEVELOPER_DIR || (xcodes.length && path.join("/Applications", xcodes.at(-1), "Contents/Developer"));
  if (!developer) throw Error("Set DEVELOPER_DIR to a Mac Xcode installation");
  await fs.access(path.join(developer, "usr/bin/xctrace"));
  if (process.argv.includes("--plan")) {
    console.log(
      JSON.stringify({ output, developer, urls, seed, width, height, frames, warmup, cameraDir, groups }, null, 2)
    );
    return;
  }
  if (!process.argv.includes("--record")) throw Error("Use --plan or --record");
  await fs.mkdir(output, { recursive: true });
  let previousManifest;
  try {
    previousManifest = JSON.parse(await fs.readFile(path.join(output, "manifest.json")));
  } catch (e) {
    if (e.code !== "ENOENT") throw e;
  }
  if (previousManifest) {
    if (env.RESUME !== "1") throw Error("Results exist; use a new RESULTS directory or RESUME=1");
    for (const [key, value] of Object.entries({
      urls,
      seed,
      width,
      height,
      frames,
      warmup,
      cameraDir,
      groups,
      ...provenance
    }))
      if (JSON.stringify(previousManifest[key]) !== JSON.stringify(value))
        throw Error("Resume configuration differs: " + key);
  }
  const completed = new Set();
  for (const g of groups) {
    const dir = path.join(output, g.id);
    try {
      await fs.access(dir);
    } catch (e) {
      if (e.code === "ENOENT") continue;
      throw e;
    }
    if (env.RESUME !== "1") throw Error("Choose a new RESULTS directory; workload exists: " + g.id);
    try {
      const status = JSON.parse(await fs.readFile(path.join(dir, "complete.json")));
      if (status.id !== g.id || !Number.isSafeInteger(status.gpuPid)) throw Error("Invalid completion record");
      await fs.access(path.join(dir, "gpu.trace"));
      for (const [i, b] of g.order.entries()) await fs.access(path.join(dir, i + "-" + b + ".json"));
      completed.add(g.id);
    } catch (e) {
      if (e.code !== "ENOENT") throw e;
      // Only touch our interrupted cohort; keep its trace/logs if it had started.
      await fs.rename(dir, path.join(output, "interrupted-" + g.id + "-" + Date.now()));
    }
  }
  if (completed.size === groups.length) return;
  const { chromium } = require(require.resolve("@playwright/test", { paths: [repo] }));
  const args = [
    "--ignore-gpu-blocklist",
    "--use-gl=angle",
    "--disable-background-timer-throttling",
    "--disable-renderer-backgrounding",
    "--disable-backgrounding-occluded-windows"
  ];
  const browser = await chromium.launch({ headless: true, args, ...(env.CHANNEL && { channel: env.CHANNEL }) });
  const install =
    "(() => {" +
    metrics +
    "\ninstallSeedMetrics();(" +
    recordValidation.toString() +
    ")(); globalThis.measureSeedTemplate=measureSeedTemplate;})();";
  try {
    await browser.newPage();
    const cdp = await browser.newBrowserCDPSession();
    const pid = async () => {
      const gpu = (await cdp.send("SystemInfo.getProcessInfo")).processInfo.find((x) => x.type.toLowerCase() === "gpu");
      if (!gpu || !Number.isSafeInteger(gpu.id)) throw Error("Chromium has no local GPU subprocess");
      return gpu.id;
    };
    const gpuPid = await pid();
    const metadata = {
      gpuPid,
      localDevice,
      nativeArch,
      browser: browser.version(),
      chromiumExecutable: env.CHANNEL || chromium.executablePath(),
      urls,
      width,
      height,
      frames,
      warmup,
      seed,
      cameraDir,
      developer,
      args,
      groups,
      ...provenance,
      host: os.hostname(),
      kernel: os.release(),
      adapter: (await cdp.send("SystemInfo.getInfo")).gpu.devices
    };
    metadata.sessionPids = [...new Set([...(previousManifest?.sessionPids || []), gpuPid])];
    await json(path.join(output, "manifest.json"), metadata);
    for (const group of groups) {
      if (completed.has(group.id)) continue;
      if (diskGiB) {
        const used = Number(execFileSync("/usr/bin/du", ["-sk", output], { encoding: "utf8" }).split(/\s/)[0]) * 1024;
        if (used > (diskGiB - 1.5) * 1024 ** 3)
          throw Error("Reserve the remaining trace budget or compact completed cohorts before resuming.");
      }
      const disk = await fs.statfs(output);
      if (disk.bavail * disk.bsize < 4 * 1024 ** 3) throw Error("Less than 4 GiB free on trace volume");
      const dir = path.join(output, group.id);
      await fs.mkdir(dir);
      const pages = new Map();
      let trace;
      try {
        for (const backend of group.order) pages.set(backend, await prepare(browser, backend, group.template, install));
        samePid(await pid(), gpuPid);
        trace = await recorder(gpuPid, dir, group, developer, nativeArch);
        for (const [index, backend] of group.order.entries()) {
          const record = pages.get(backend);
          const { page, lifecycle, errors, url } = record;
          await lifecycle.send("Page.setWebLifecycleState", { state: "active" });
          record.frozen = false;
          await page.bringToFront();
          await page.waitForFunction(() => document.visibilityState === "visible");
          for (const [other, record] of pages)
            if (other !== backend) {
              if (!record.frozen) throw Error(other + " page is not frozen");
            }
          samePid(await pid(), gpuPid);
          const opts = {
            template: group.template,
            seed,
            variant: group.variant,
            mode: "cpu",
            frames,
            warmup,
            width,
            height,
            path: cameras[group.template],
            image: false,
            frameBoundaries: true
          };
          const benchmark = await Promise.race([
            page.evaluate((opts) => globalThis.measureSeedTemplate(undefined, opts), opts),
            trace.ended.then((r) => {
              throw Error("xctrace ended during workload: " + JSON.stringify(r));
            })
          ]);
          if (!(await pauseAndDrain(page))) throw Error("Inactive scene continued rendering");
          samePid(await pid(), gpuPid);
          const validation = await page.evaluate(() => globalThis.__seedMetalErrors);
          await lifecycle.send("Page.setWebLifecycleState", { state: "frozen" });
          record.frozen = true;
          const marks = benchmark.frameBoundariesEpochMs;
          if (
            benchmark.backend !== backend ||
            !marks ||
            marks.length !== frames + 1 ||
            marks.some((v, i) => !Number.isFinite(v) || (i && v <= marks[i - 1]))
          )
            throw Error("Unexpected backend or frame boundary counts");
          if (JSON.stringify(benchmark.path) !== JSON.stringify(opts.path)) throw Error("Measured a different route");
          await json(path.join(dir, index + "-" + backend + ".json"), { gpuPid, url, errors, validation, benchmark });
          console.log(
            new Date().toISOString(),
            group.id,
            backend,
            benchmark.hash,
            benchmark.inspections.map((x) => x.drawCalls)
          );
          if (errors.length || validation.length || benchmark.webglErrors.length)
            throw Error("Seed reported rendering errors; see workload JSON");
        }
      } finally {
        try {
          if (trace) await trace.stop();
        } finally {
          await Promise.all([...pages.values()].map((r) => r.page.close()));
        }
      }
      await json(path.join(dir, "complete.json"), { id: group.id, gpuPid });
    }
  } finally {
    await browser.close();
  }
}
main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
