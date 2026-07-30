import { chromium } from "@playwright/test";

const url = process.env.PROBE_URL ?? "http://127.0.0.1:5187/demos/terrain/grasslands/?backend=webgpu";
const screenshotPath = process.env.PROBE_SCREENSHOT;
const requestGPUTiming = new URL(url).searchParams.get("gpuTiming") === "1";
const compactOutput = process.env.PROBE_COMPACT === "1";
const deterministicScene = process.env.PROBE_DETERMINISTIC_SCENE === "1";
const disableShadows = process.env.PROBE_DISABLE_SHADOWS === "1";
const cameraPose = process.env.PROBE_CAMERA_POSE;
const frameSampleCount = Number(process.env.PROBE_FRAME_SAMPLES ?? 120);
if (!Number.isInteger(frameSampleCount) || frameSampleCount < 1) {
  throw new RangeError(`PROBE_FRAME_SAMPLES must be a positive integer, received ${frameSampleCount}.`);
}
const disabledCategories = (process.env.PROBE_DISABLED_CATEGORIES ?? "")
  .split(",")
  .map((category) => category.trim())
  .filter(Boolean);
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
  const stateCommandNames = [
    "setPipeline",
    "setBindGroup",
    "setVertexBuffer",
    "setIndexBuffer",
    "setViewport",
    "setScissorRect",
    "setBlendConstant",
    "setStencilReference"
  ];
  const createCommandCounts = () => Object.fromEntries(commandNames.map((name) => [name, 0]));
  const createStateCommandCounts = () => Object.fromEntries(stateCommandNames.map((name) => [name, 0]));
  const createEmptyCounts = () => ({
    submissions: 0,
    createRenderPipeline: 0,
    createBindGroup: 0,
    createRenderBundleEncoder: 0,
    finishRenderBundle: 0,
    writeBuffer: 0,
    writeBufferBytes: 0,
    bufferWrites: {},
    renderPasses: 0,
    directInstances: { draw: 0, drawIndexed: 0 },
    commands: createCommandCounts(),
    redundantCommands: createStateCommandCounts(),
    bundleCommands: createCommandCounts(),
    byPass: {}
  });
  let counts = createEmptyCounts();
  const bufferIds = new WeakMap();
  const bufferDescriptors = new WeakMap();
  const indirectDrawTargets = new Map();
  let nextBufferId = 1;
  let activeDevice;
  const nativeObjectIds = new WeakMap();
  let nextNativeObjectId = 1;
  const stateCommandKeys = new Set(stateCommandNames);
  const getNativeObjectId = (value) => {
    let objectId = nativeObjectIds.get(value);
    if (objectId === undefined) {
      objectId = nextNativeObjectId++;
      nativeObjectIds.set(value, objectId);
    }
    return objectId;
  };
  const commandArgumentKey = (value) => {
    if (value === null) return "null";
    if (ArrayBuffer.isView(value)) return `${value.constructor.name}:${Array.from(value).join(",")}`;
    if (Array.isArray(value)) return `Array:${value.map(commandArgumentKey).join(",")}`;
    const valueType = typeof value;
    if (valueType === "object" || valueType === "function") {
      const entries = Object.entries(value);
      if (entries.length > 0) {
        return `Record:${entries.map(([key, entry]) => `${key}=${commandArgumentKey(entry)}`).join(",")}`;
      }
      return `Object:${getNativeObjectId(value)}`;
    }
    return `${valueType}:${String(value)}`;
  };
  const stateCommandSlot = (name, args) =>
    name === "setBindGroup" || name === "setVertexBuffer" ? `${name}:${args[0]}` : name;
  const stateCommandSignature = (args) => args.map(commandArgumentKey).join("|");
  const getPassCounts = (label) => {
    counts.byPass[label] ??= {
      renderPasses: 0,
      directInstances: { draw: 0, drawIndexed: 0 },
      commands: createCommandCounts(),
      redundantCommands: createStateCommandCounts()
    };
    return counts.byPass[label];
  };
  const incrementCommand = (label, name, args) => {
    counts.commands[name]++;
    const passCounts = getPassCounts(label);
    passCounts.commands[name]++;
    if (name === "draw" || name === "drawIndexed") {
      const instanceCount = args[1] ?? 1;
      counts.directInstances[name] += instanceCount;
      passCounts.directInstances[name] += instanceCount;
    }
  };
  window.__webgpuRenderCommandProbe = {
    reset() {
      counts = createEmptyCounts();
      indirectDrawTargets.clear();
    },
    snapshot() {
      return structuredClone(counts);
    },
    async readIndirectRecords() {
      const targets = [...indirectDrawTargets.values()];
      if (!activeDevice || targets.length === 0) return [];
      const recordByteLength = 5 * Uint32Array.BYTES_PER_ELEMENT;
      const readback = activeDevice.createBuffer({
        label: "Grasslands indirect probe readback",
        size: targets.length * recordByteLength,
        usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
      });
      const encoder = activeDevice.createCommandEncoder({ label: "Grasslands indirect probe copy" });
      for (let index = 0; index < targets.length; index++) {
        encoder.copyBufferToBuffer(
          targets[index].buffer,
          targets[index].offset,
          readback,
          index * recordByteLength,
          recordByteLength
        );
      }
      activeDevice.queue.submit([encoder.finish()]);
      await readback.mapAsync(GPUMapMode.READ);
      const words = new Uint32Array(readback.getMappedRange());
      const records = targets.map((target, index) => {
        const wordOffset = index * 5;
        const descriptor = bufferDescriptors.get(target.buffer);
        return {
          pass: target.pass,
          buffer: target.bufferId,
          bufferLabel: descriptor?.label ?? target.buffer.label ?? "unlabeled",
          bufferSize: descriptor?.size ?? null,
          offset: target.offset,
          viewport: target.viewport,
          indexCount: words[wordOffset],
          instanceCount: words[wordOffset + 1],
          firstIndex: words[wordOffset + 2],
          baseVertex: words[wordOffset + 3] | 0,
          firstInstance: words[wordOffset + 4]
        };
      });
      readback.unmap();
      readback.destroy();
      return records;
    }
  };

  const constructors = globalThis;
  if (!constructors.GPUDevice || !constructors.GPUCommandEncoder || !constructors.GPUQueue) {
    return;
  }

  const devicePrototype = constructors.GPUDevice.prototype;
  const createBuffer = devicePrototype.createBuffer;
  devicePrototype.createBuffer = function (descriptor) {
    activeDevice = this;
    const buffer = createBuffer.call(this, descriptor);
    bufferDescriptors.set(buffer, {
      label: descriptor.label || "",
      size: Number(descriptor.size),
      usage: descriptor.usage
    });
    return buffer;
  };
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
    const byteLength = size === undefined ? sourceByteLength - sourceOffset : size * bytesPerElement;
    counts.writeBufferBytes += byteLength;
    let bufferId = bufferIds.get(buffer);
    if (bufferId === undefined) {
      bufferId = nextBufferId++;
      bufferIds.set(buffer, bufferId);
    }
    const key = `${bufferId}:${buffer.label || "unlabeled"}`;
    const bufferWrite = (counts.bufferWrites[key] ??= {
      calls: 0,
      bytes: 0,
      minOffset: bufferOffset,
      maxEnd: bufferOffset
    });
    bufferWrite.calls++;
    bufferWrite.bytes += byteLength;
    bufferWrite.minOffset = Math.min(bufferWrite.minOffset, bufferOffset);
    bufferWrite.maxEnd = Math.max(bufferWrite.maxEnd, bufferOffset + byteLength);
    return writeBuffer.call(this, buffer, bufferOffset, data, dataOffset, size);
  };

  const commandEncoderPrototype = constructors.GPUCommandEncoder.prototype;
  const beginRenderPass = commandEncoderPrototype.beginRenderPass;
  commandEncoderPrototype.beginRenderPass = function (descriptor) {
    const label = descriptor?.label || "unlabeled";
    const pass = beginRenderPass.call(this, descriptor);
    const stateCommandSignatures = new Map();
    let activeViewport = null;
    counts.renderPasses++;
    getPassCounts(label).renderPasses++;
    for (const name of commandNames) {
      const command = pass[name];
      if (typeof command !== "function") continue;
      pass[name] = (...args) => {
        incrementCommand(label, name, args);
        if (name === "setViewport") {
          activeViewport = args.map(Number);
        }
        if (name === "drawIndexedIndirect") {
          let bufferId = bufferIds.get(args[0]);
          if (bufferId === undefined) {
            bufferId = nextBufferId++;
            bufferIds.set(args[0], bufferId);
          }
          const offset = args[1] ?? 0;
          indirectDrawTargets.set(`${label}:${bufferId}:${offset}`, {
            pass: label,
            buffer: args[0],
            bufferId,
            offset,
            viewport: activeViewport
          });
        }
        if (stateCommandKeys.has(name)) {
          const stateSlot = stateCommandSlot(name, args);
          const signature = stateCommandSignature(args);
          if (stateCommandSignatures.get(stateSlot) === signature) {
            counts.redundantCommands[name]++;
            getPassCounts(label).redundantCommands[name]++;
          }
          stateCommandSignatures.set(stateSlot, signature);
        } else if (name === "executeBundles") {
          stateCommandSignatures.clear();
        }
        return command.call(pass, ...args);
      };
    }
    return pass;
  };
});

await page.goto(url, { waitUntil: "networkidle", timeout: 120_000 });
await page.waitForFunction(() => window.terrainDebug?.ready === true, undefined, { timeout: 120_000 });
await page.evaluate(
  ({ deterministic, disableShadows, cameraPose }) => {
    if (cameraPose) {
      window.terrainDebug.setPose(cameraPose);
    }
    window.grasslandsDebug.setScene({
      animation: false,
      ...(disableShadows ? { shadows: false } : {}),
      ...(deterministic ? { cloudShadows: false, clouds: false, fog: false, postProcess: false } : {})
    });
    if (deterministic) {
      window.grasslandsDebug.setSurface({ wind: { enabled: false } });
    }
  },
  { deterministic: deterministicScene, disableShadows, cameraPose }
);
await page.evaluate(
  () =>
    new Promise((resolve) => {
      requestAnimationFrame(() => requestAnimationFrame(resolve));
    })
);
if (disabledCategories.length > 0) {
  await page.evaluate(
    (categories) =>
      window.grasslandsDebug.setSurface({
        enabled: Object.fromEntries(categories.map((category) => [category, false]))
      }),
    disabledCategories
  );
  await page.evaluate(
    () =>
      new Promise((resolve) => {
        requestAnimationFrame(() => requestAnimationFrame(resolve));
      })
  );
}
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
  (sampleCount) =>
    new Promise((resolve) => {
      const samples = [];
      let previous;
      const sample = (now) => {
        if (previous !== undefined) samples.push(now - previous);
        previous = now;
        if (samples.length < sampleCount) {
          requestAnimationFrame(sample);
        } else {
          resolve(samples);
        }
      };
      requestAnimationFrame(sample);
    }),
  frameSampleCount
);
const sorted = [...frameTimes].sort((left, right) => left - right);
const totalDuration = frameTimes.reduce((sum, value) => sum + value, 0);
const counts = await page.evaluate(() => window.__webgpuRenderCommandProbe.snapshot());
const indirectDrawRecords = await page.evaluate(() => window.__webgpuRenderCommandProbe.readIndirectRecords());
const perSubmission = Object.fromEntries(
  Object.entries(counts.commands).map(([name, count]) => [name, count / counts.submissions])
);
const byPassPerSubmission = Object.fromEntries(
  Object.entries(counts.byPass).map(([label, pass]) => [
    label,
    {
      renderPasses: pass.renderPasses / counts.submissions,
      directInstances: Object.fromEntries(
        Object.entries(pass.directInstances).map(([name, count]) => [name, count / counts.submissions])
      ),
      commands: Object.fromEntries(
        Object.entries(pass.commands).map(([name, count]) => [name, count / counts.submissions])
      ),
      redundantCommands: Object.fromEntries(
        Object.entries(pass.redundantCommands).map(([name, count]) => [name, count / counts.submissions])
      )
    }
  ])
);
const selectedPasses = ["shadow", "depth-prepass", "forward", "grasslands-exposure", "post-process-uber", "final-srgb"];
const selectPassCounts = (byPass) =>
  Object.fromEntries(selectedPasses.filter((label) => byPass[label]).map((label) => [label, byPass[label]]));
const summarizeBufferWrites = (bufferWrites, submissions) => {
  const writes = Object.entries(bufferWrites);
  const perSubmission = Math.max(1, submissions);
  return {
    targetBuffers: writes.length,
    calls: writes.reduce((sum, [, write]) => sum + write.calls, 0) / perSubmission,
    bytes: writes.reduce((sum, [, write]) => sum + write.bytes, 0) / perSubmission,
    coalescedCalls: writes.length,
    coalescedBytes: writes.reduce((sum, [, write]) => sum + write.maxEnd - write.minOffset, 0),
    hottest: writes
      .sort(([, left], [, right]) => right.calls - left.calls)
      .slice(0, 12)
      .map(([buffer, write]) => ({ buffer, ...write }))
  };
};
if (screenshotPath) {
  await page.locator("#canvas").screenshot({ path: screenshotPath });
}
const surface = await page.evaluate(() => window.grasslandsDebug.inspectSurface());
const report = {
  browser: { executablePath, version: browser.version() },
  url,
  deterministicScene,
  disableShadows,
  cameraPose: cameraPose ?? null,
  disabledCategories,
  frame: {
    samples: frameTimes.length,
    fps: (frameTimes.length * 1000) / totalDuration,
    p50: sorted[Math.floor(sorted.length * 0.5)],
    p95: sorted[Math.floor(sorted.length * 0.95)]
  },
  surface,
  gpuTiming,
  screenshotPath: screenshotPath ?? null,
  warmup: {
    ...warmupCounts,
    bufferWrites: summarizeBufferWrites(warmupCounts.bufferWrites, warmupCounts.submissions),
    byPass: selectPassCounts(warmupCounts.byPass)
  },
  totals: {
    ...counts,
    bufferWrites: summarizeBufferWrites(counts.bufferWrites, counts.submissions),
    byPass: selectPassCounts(counts.byPass)
  },
  indirectDrawRecords,
  perSubmission: {
    createRenderPipeline: counts.createRenderPipeline / counts.submissions,
    createBindGroup: counts.createBindGroup / counts.submissions,
    createRenderBundleEncoder: counts.createRenderBundleEncoder / counts.submissions,
    finishRenderBundle: counts.finishRenderBundle / counts.submissions,
    writeBuffer: counts.writeBuffer / counts.submissions,
    writeBufferBytes: counts.writeBufferBytes / counts.submissions,
    renderPasses: counts.renderPasses / counts.submissions,
    directInstances: Object.fromEntries(
      Object.entries(counts.directInstances).map(([name, count]) => [name, count / counts.submissions])
    ),
    commands: perSubmission,
    redundantCommands: Object.fromEntries(
      Object.entries(counts.redundantCommands).map(([name, count]) => [name, count / counts.submissions])
    ),
    byPass: byPassPerSubmission
  },
  diagnostics
};
console.log(
  JSON.stringify(
    compactOutput
      ? {
          browser: report.browser,
          url: report.url,
          deterministicScene: report.deterministicScene,
          disableShadows: report.disableShadows,
          cameraPose: report.cameraPose,
          disabledCategories: report.disabledCategories,
          frame: report.frame,
          surface: {
            visibleRendererBatches: surface.visibleRendererBatches,
            indirectRendererBatches: surface.indirectRendererBatches,
            visibleInstances: surface.visibleInstances,
            visibleCategoryCounts: surface.visibleCategoryCounts,
            lodCounts: surface.lodCounts
          },
          gpuTiming: report.gpuTiming,
          indirectDrawRecords: report.indirectDrawRecords,
          bufferWrites: report.totals.bufferWrites,
          perSubmission: report.perSubmission,
          diagnostics: report.diagnostics
        }
      : report,
    null,
    2
  )
);

await browser.close();
