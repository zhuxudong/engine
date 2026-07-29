import { chromium } from "@playwright/test";

const url = process.env.PROBE_URL ?? "http://127.0.0.1:5187/demos/terrain/grasslands/?backend=webgpu";
const screenshotPath = process.env.PROBE_SCREENSHOT;
const requestGPUTiming = new URL(url).searchParams.get("gpuTiming") === "1";
const executablePath = process.env.PROBE_BROWSER_EXECUTABLE ?? chromium.executablePath();
const browser = await chromium.launch({
  executablePath,
  headless: true,
  args: ["--enable-unsafe-webgpu", "--use-angle=metal"]
});
const context = await browser.newContext({
  viewport: { width: 1024, height: 576 },
  deviceScaleFactor: 2
});
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

await page.addInitScript(() => {
  const commandNames = [
    "setPipeline",
    "setBindGroup",
    "setVertexBuffer",
    "setIndexBuffer",
    "draw",
    "drawIndexed",
    "drawIndirect",
    "drawIndexedIndirect",
    "executeBundles",
    "setViewport",
    "setScissorRect",
    "setBlendConstant",
    "setStencilReference"
  ];
  const createEmptyCounts = () => ({
    submissions: 0,
    createRenderPipeline: 0,
    createBindGroup: 0,
    createRenderBundleEncoder: 0,
    finishRenderBundle: 0,
    writeBuffer: 0,
    writeBufferBytes: 0,
    renderPasses: 0,
    commands: Object.fromEntries(commandNames.map((name) => [name, 0])),
    bundleCommands: Object.fromEntries(commandNames.map((name) => [name, 0])),
    byPass: {}
  });
  let counts = createEmptyCounts();
  const getPassCounts = (label) => {
    counts.byPass[label] ??= {
      renderPasses: 0,
      commands: Object.fromEntries(commandNames.map((name) => [name, 0]))
    };
    return counts.byPass[label];
  };
  const incrementCommand = (label, name) => {
    counts.commands[name]++;
    getPassCounts(label).commands[name]++;
  };
  window.__webgpuRenderCommandProbe = {
    reset() {
      counts = createEmptyCounts();
    },
    snapshot() {
      return structuredClone(counts);
    }
  };

  const constructors = globalThis;
  if (!constructors.GPUDevice || !constructors.GPUCommandEncoder || !constructors.GPUQueue) {
    return;
  }

  const devicePrototype = constructors.GPUDevice.prototype;
  const createRenderPipeline = devicePrototype.createRenderPipeline;
  devicePrototype.createRenderPipeline = function (descriptor) {
    counts.createRenderPipeline++;
    return createRenderPipeline.call(this, descriptor);
  };
  const createBindGroup = devicePrototype.createBindGroup;
  devicePrototype.createBindGroup = function (descriptor) {
    counts.createBindGroup++;
    return createBindGroup.call(this, descriptor);
  };
  const createRenderBundleEncoder = devicePrototype.createRenderBundleEncoder;
  devicePrototype.createRenderBundleEncoder = function (descriptor) {
    counts.createRenderBundleEncoder++;
    const encoder = createRenderBundleEncoder.call(this, descriptor);
    for (const name of commandNames) {
      const command = encoder[name];
      if (typeof command !== "function") continue;
      encoder[name] = (...args) => {
        counts.bundleCommands[name]++;
        return command.call(encoder, ...args);
      };
    }
    const finish = encoder.finish.bind(encoder);
    encoder.finish = (finishDescriptor) => {
      counts.finishRenderBundle++;
      return finish(finishDescriptor);
    };
    return encoder;
  };

  const queuePrototype = constructors.GPUQueue.prototype;
  const submit = queuePrototype.submit;
  queuePrototype.submit = function (commandBuffers) {
    counts.submissions++;
    return submit.call(this, commandBuffers);
  };
  const writeBuffer = queuePrototype.writeBuffer;
  queuePrototype.writeBuffer = function (buffer, bufferOffset, data, dataOffset, size) {
    counts.writeBuffer++;
    const sourceByteLength = data.byteLength;
    const bytesPerElement = data.BYTES_PER_ELEMENT ?? 1;
    const sourceOffset = (dataOffset ?? 0) * bytesPerElement;
    counts.writeBufferBytes += size === undefined ? sourceByteLength - sourceOffset : size * bytesPerElement;
    return writeBuffer.call(this, buffer, bufferOffset, data, dataOffset, size);
  };

  const commandEncoderPrototype = constructors.GPUCommandEncoder.prototype;
  const beginRenderPass = commandEncoderPrototype.beginRenderPass;
  commandEncoderPrototype.beginRenderPass = function (descriptor) {
    const label = descriptor?.label || "unlabeled";
    const pass = beginRenderPass.call(this, descriptor);
    counts.renderPasses++;
    getPassCounts(label).renderPasses++;
    for (const name of commandNames) {
      const command = pass[name];
      if (typeof command !== "function") continue;
      pass[name] = (...args) => {
        incrementCommand(label, name);
        return command.call(pass, ...args);
      };
    }
    return pass;
  };
});

await page.goto(url, { waitUntil: "networkidle", timeout: 120_000 });
await page.waitForFunction(() => window.terrainDebug?.ready === true, undefined, { timeout: 120_000 });
await page.evaluate(() => window.grasslandsDebug.setScene({ animation: false }));
await page.waitForFunction(() => window.grasslandsDebug.inspectSurface().transitioningRanges === 0);
await page.waitForTimeout(1_800);
let gpuTiming = null;
if (requestGPUTiming && (await page.evaluate(() => window.grasslandsDebug.inspectGPUTiming().supported))) {
  await page.evaluate(() => window.grasslandsDebug.requestGPUTimingSample());
  await page.waitForFunction(() => window.grasslandsDebug.inspectGPUTiming().latestSample !== null);
  gpuTiming = await page.evaluate(() => window.grasslandsDebug.inspectGPUTiming().latestSample);
}
const warmupCounts = await page.evaluate(() => window.__webgpuRenderCommandProbe.snapshot());
await page.evaluate(() => window.__webgpuRenderCommandProbe.reset());
const frameTimes = await page.evaluate(
  () =>
    new Promise((resolve) => {
      const samples = [];
      let previous;
      const sample = (now) => {
        if (previous !== undefined) samples.push(now - previous);
        previous = now;
        if (samples.length < 120) {
          requestAnimationFrame(sample);
        } else {
          resolve(samples);
        }
      };
      requestAnimationFrame(sample);
    })
);
const sorted = [...frameTimes].sort((left, right) => left - right);
const totalDuration = frameTimes.reduce((sum, value) => sum + value, 0);
const counts = await page.evaluate(() => window.__webgpuRenderCommandProbe.snapshot());
const perSubmission = Object.fromEntries(
  Object.entries(counts.commands).map(([name, count]) => [name, count / counts.submissions])
);
const byPassPerSubmission = Object.fromEntries(
  Object.entries(counts.byPass).map(([label, pass]) => [
    label,
    {
      renderPasses: pass.renderPasses / counts.submissions,
      commands: Object.fromEntries(
        Object.entries(pass.commands).map(([name, count]) => [name, count / counts.submissions])
      )
    }
  ])
);
const selectedPasses = ["shadow", "depth-prepass", "forward", "grasslands-exposure", "post-process-uber", "final-srgb"];
const selectPassCounts = (byPass) =>
  Object.fromEntries(selectedPasses.filter((label) => byPass[label]).map((label) => [label, byPass[label]]));
if (screenshotPath) {
  await page.locator("#canvas").screenshot({ path: screenshotPath });
}
console.log(
  JSON.stringify(
    {
      browser: { executablePath, version: browser.version() },
      url,
      frame: {
        samples: frameTimes.length,
        fps: (frameTimes.length * 1000) / totalDuration,
        p50: sorted[Math.floor(sorted.length * 0.5)],
        p95: sorted[Math.floor(sorted.length * 0.95)]
      },
      surface: await page.evaluate(() => window.grasslandsDebug.inspectSurface()),
      gpuTiming,
      screenshotPath: screenshotPath ?? null,
      warmup: {
        ...warmupCounts,
        byPass: selectPassCounts(warmupCounts.byPass)
      },
      totals: {
        ...counts,
        byPass: selectPassCounts(counts.byPass)
      },
      perSubmission: {
        createRenderPipeline: counts.createRenderPipeline / counts.submissions,
        createBindGroup: counts.createBindGroup / counts.submissions,
        createRenderBundleEncoder: counts.createRenderBundleEncoder / counts.submissions,
        finishRenderBundle: counts.finishRenderBundle / counts.submissions,
        writeBuffer: counts.writeBuffer / counts.submissions,
        writeBufferBytes: counts.writeBufferBytes / counts.submissions,
        renderPasses: counts.renderPasses / counts.submissions,
        commands: perSubmission,
        byPass: byPassPerSubmission
      },
      diagnostics
    },
    null,
    2
  )
);

await browser.close();
