import { expect, test, type Page } from "@playwright/test";

const webgpuEnabled = process.env.TERRAIN_E2E_WEBGPU === "1";
const benchmarkEnabled = process.env.TERRAIN_E2E_BENCHMARK === "1";

interface WebGPUComputeCounts {
  createComputePipeline: number;
  beginComputePass: number;
  dispatchWorkgroups: number;
  dispatchedWorkgroups: number;
  maxWorkgroupCountX: number;
}

interface ComputePassPrototype {
  dispatchWorkgroups(workgroupCountX: number, workgroupCountY?: number, workgroupCountZ?: number): void;
}

interface ComputeDevicePrototype {
  createComputePipeline(descriptor: unknown): unknown;
}

interface ComputeCommandEncoderPrototype {
  beginComputePass(descriptor?: unknown): ComputePassPrototype;
}

interface CapturedIndirectRecord {
  readonly indexCount: number;
  readonly instanceCount: number;
  readonly firstIndex: number;
  readonly baseVertex: number;
  readonly firstInstance: number;
}

interface SurfaceIndirectCapture {
  reset(): void;
  readForwardRecords(): Promise<CapturedIndirectRecord[]>;
}

interface NativeGPUBuffer {
  getMappedRange(): ArrayBuffer;
  mapAsync(mode: number): Promise<void>;
  unmap(): void;
  destroy(): void;
}

interface NativeGPUCommandEncoder {
  copyBufferToBuffer(
    source: NativeGPUBuffer,
    sourceOffset: number,
    destination: NativeGPUBuffer,
    destinationOffset: number,
    size: number
  ): void;
  finish(): unknown;
}

interface NativeGPUDevice {
  readonly queue: { submit(commands: unknown[]): void };
  createBuffer(descriptor: { size: number; usage: number }): NativeGPUBuffer;
  createCommandEncoder(): NativeGPUCommandEncoder;
}

interface NativeRenderPass {
  setPipeline(pipeline: NativeRenderPipeline): void;
  draw(vertexCount: number, instanceCount?: number, firstVertex?: number, firstInstance?: number): void;
  drawIndexed(
    indexCount: number,
    instanceCount?: number,
    firstIndex?: number,
    baseVertex?: number,
    firstInstance?: number
  ): void;
  drawIndexedIndirect(buffer: NativeGPUBuffer, offset: number): void;
}

interface NativeRenderPipeline {}

interface NativeComputePass {
  dispatchWorkgroups(x: number, y?: number, z?: number): void;
}

interface DepthPrimingPipelineCapture {
  readonly depthCompare?: string;
  readonly depthWriteEnabled?: boolean;
  readonly colorWriteMasks: readonly number[];
}

interface DepthPrimingPassCapture {
  readonly label: string;
  readonly colorAttachmentCount: number;
  readonly depthTextureId: number | null;
  readonly depthReadOnly: boolean;
  readonly depthLoadOp?: string;
  readonly depthStoreOp?: string;
  readonly pipelines: readonly DepthPrimingPipelineCapture[];
  readonly indirectPipelines: readonly DepthPrimingPipelineCapture[];
  readonly drawCount: number;
  readonly drawIndexedCount: number;
  readonly drawIndexedIndirectCount: number;
}

interface DepthPrimingCapture {
  reset(): void;
  read(): readonly DepthPrimingPassCapture[];
}

declare global {
  interface Window {
    __webgpuComputeCounts: WebGPUComputeCounts;
    __webgpuPassSequence: string[];
    __surfaceIndirectCapture: SurfaceIndirectCapture;
    __depthPrimingCapture: DepthPrimingCapture;
  }
}

async function installDepthPrimingCapture(page: Page): Promise<void> {
  await page.addInitScript(() => {
    const captures: DepthPrimingPassCapture[] = [];
    const textureIds = new WeakMap<object, number>();
    const viewTextureIds = new WeakMap<object, number>();
    const pipelineStates = new WeakMap<object, DepthPrimingPipelineCapture>();
    let nextTextureId = 1;

    const constructors = globalThis as unknown as {
      GPUTexture?: {
        prototype: {
          createView(descriptor?: unknown): object;
        };
      };
      GPUDevice?: {
        prototype: {
          createRenderPipeline(descriptor: {
            readonly fragment?: {
              readonly targets?: readonly ({ readonly writeMask?: number } | null)[];
            };
            readonly depthStencil?: {
              readonly depthCompare?: string;
              readonly depthWriteEnabled?: boolean;
            };
          }): NativeRenderPipeline;
        };
      };
      GPUCommandEncoder?: {
        prototype: {
          beginRenderPass(descriptor: {
            readonly label?: string;
            readonly colorAttachments: readonly (object | null)[];
            readonly depthStencilAttachment?: {
              readonly view: object;
              readonly depthReadOnly?: boolean;
              readonly depthLoadOp?: string;
              readonly depthStoreOp?: string;
            };
          }): NativeRenderPass;
        };
      };
    };
    if (!constructors.GPUTexture || !constructors.GPUDevice || !constructors.GPUCommandEncoder) {
      throw new Error("WebGPU constructors are unavailable.");
    }

    const texturePrototype = constructors.GPUTexture.prototype;
    const createView = texturePrototype.createView;
    texturePrototype.createView = function (descriptor) {
      const view = createView.call(this, descriptor);
      let textureId = textureIds.get(this);
      if (textureId == undefined) {
        textureId = nextTextureId++;
        textureIds.set(this, textureId);
      }
      viewTextureIds.set(view, textureId);
      return view;
    };

    const devicePrototype = constructors.GPUDevice.prototype;
    const createRenderPipeline = devicePrototype.createRenderPipeline;
    devicePrototype.createRenderPipeline = function (descriptor) {
      const pipeline = createRenderPipeline.call(this, descriptor);
      pipelineStates.set(pipeline, {
        depthCompare: descriptor.depthStencil?.depthCompare,
        depthWriteEnabled: descriptor.depthStencil?.depthWriteEnabled,
        colorWriteMasks: descriptor.fragment?.targets?.map((target) => target?.writeMask ?? 0xf) ?? []
      });
      return pipeline;
    };

    const encoderPrototype = constructors.GPUCommandEncoder.prototype;
    const beginRenderPass = encoderPrototype.beginRenderPass;
    encoderPrototype.beginRenderPass = function (descriptor) {
      const pass = beginRenderPass.call(this, descriptor);
      const depthAttachment = descriptor.depthStencilAttachment;
      const pipelines: DepthPrimingPipelineCapture[] = [];
      const indirectPipelines: DepthPrimingPipelineCapture[] = [];
      let activePipeline: DepthPrimingPipelineCapture | undefined;
      let drawCount = 0;
      let drawIndexedCount = 0;
      let drawIndexedIndirectCount = 0;
      const capture = {
        label: descriptor.label ?? "render",
        colorAttachmentCount: descriptor.colorAttachments.length,
        depthTextureId: depthAttachment ? (viewTextureIds.get(depthAttachment.view) ?? null) : null,
        depthReadOnly: depthAttachment?.depthReadOnly ?? false,
        depthLoadOp: depthAttachment?.depthLoadOp,
        depthStoreOp: depthAttachment?.depthStoreOp,
        get pipelines(): readonly DepthPrimingPipelineCapture[] {
          return pipelines;
        },
        get indirectPipelines(): readonly DepthPrimingPipelineCapture[] {
          return indirectPipelines;
        },
        get drawCount(): number {
          return drawCount;
        },
        get drawIndexedCount(): number {
          return drawIndexedCount;
        },
        get drawIndexedIndirectCount(): number {
          return drawIndexedIndirectCount;
        }
      };
      captures.push(capture);

      const setPipeline = pass.setPipeline.bind(pass);
      pass.setPipeline = (pipeline) => {
        activePipeline = pipelineStates.get(pipeline);
        if (activePipeline && !pipelines.includes(activePipeline)) {
          pipelines.push(activePipeline);
        }
        setPipeline(pipeline);
      };
      const draw = pass.draw.bind(pass);
      pass.draw = (...args) => {
        drawCount++;
        draw(...args);
      };
      const drawIndexed = pass.drawIndexed.bind(pass);
      pass.drawIndexed = (...args) => {
        drawIndexedCount++;
        drawIndexed(...args);
      };
      const drawIndexedIndirect = pass.drawIndexedIndirect.bind(pass);
      pass.drawIndexedIndirect = (buffer, offset) => {
        drawIndexedIndirectCount++;
        if (activePipeline) indirectPipelines.push(activePipeline);
        drawIndexedIndirect(buffer, offset);
      };
      return pass;
    };

    window.__depthPrimingCapture = {
      reset(): void {
        captures.length = 0;
      },
      read(): readonly DepthPrimingPassCapture[] {
        return captures;
      }
    };
  });
}

async function installSurfaceIndirectCapture(page: Page): Promise<void> {
  await page.addInitScript(() => {
    let device: NativeGPUDevice | null = null;
    let forwardCalls: Array<{ readonly buffer: NativeGPUBuffer; readonly offset: number }> = [];
    const sequence: string[] = [];
    window.__webgpuPassSequence = sequence;

    const constructors = globalThis as unknown as {
      GPUBufferUsage: { readonly COPY_DST: number; readonly MAP_READ: number };
      GPUMapMode: { readonly READ: number };
      GPUAdapter?: {
        prototype: {
          requestDevice(descriptor?: unknown): Promise<NativeGPUDevice>;
        };
      };
      GPUCommandEncoder?: {
        prototype: {
          beginRenderPass(descriptor: { readonly label?: string }): NativeRenderPass;
          beginComputePass(descriptor?: { readonly label?: string }): NativeComputePass;
        };
      };
    };
    if (!constructors.GPUAdapter || !constructors.GPUCommandEncoder) {
      throw new Error("WebGPU constructors are unavailable.");
    }

    const adapterPrototype = constructors.GPUAdapter.prototype;
    const requestDevice = adapterPrototype.requestDevice;
    adapterPrototype.requestDevice = async function (descriptor) {
      device = await requestDevice.call(this, descriptor);
      return device;
    };

    const encoderPrototype = constructors.GPUCommandEncoder.prototype;
    const beginRenderPass = encoderPrototype.beginRenderPass;
    encoderPrototype.beginRenderPass = function (descriptor) {
      const label = descriptor.label ?? "render";
      sequence.push(label);
      const pass = beginRenderPass.call(this, descriptor);
      if (label === "forward") {
        const drawIndexedIndirect = pass.drawIndexedIndirect.bind(pass);
        pass.drawIndexedIndirect = (buffer, offset) => {
          forwardCalls.push({ buffer, offset });
          drawIndexedIndirect(buffer, offset);
        };
      }
      return pass;
    };
    const beginComputePass = encoderPrototype.beginComputePass;
    encoderPrototype.beginComputePass = function (descriptor) {
      sequence.push(descriptor?.label ?? "compute");
      const pass = beginComputePass.call(this, descriptor);
      const dispatchWorkgroups = pass.dispatchWorkgroups.bind(pass);
      pass.dispatchWorkgroups = (workgroupCountX, workgroupCountY, workgroupCountZ) => {
        sequence.push("dispatch");
        dispatchWorkgroups(workgroupCountX, workgroupCountY, workgroupCountZ);
      };
      return pass;
    };

    window.__surfaceIndirectCapture = {
      reset(): void {
        forwardCalls = [];
        sequence.length = 0;
      },
      async readForwardRecords(): Promise<CapturedIndirectRecord[]> {
        if (!device) throw new Error("No WebGPU device was captured.");
        const unique: Array<{ readonly buffer: NativeGPUBuffer; readonly offset: number }> = [];
        for (const call of forwardCalls) {
          if (!unique.some((candidate) => candidate.buffer === call.buffer && candidate.offset === call.offset)) {
            unique.push(call);
          }
        }
        const recordByteLength = Uint32Array.BYTES_PER_ELEMENT * 5;
        const readback = device.createBuffer({
          size: Math.max(recordByteLength, unique.length * recordByteLength),
          usage: constructors.GPUBufferUsage.COPY_DST | constructors.GPUBufferUsage.MAP_READ
        });
        const encoder = device.createCommandEncoder();
        for (let index = 0; index < unique.length; index++) {
          const call = unique[index];
          encoder.copyBufferToBuffer(call.buffer, call.offset, readback, index * recordByteLength, recordByteLength);
        }
        device.queue.submit([encoder.finish()]);
        await readback.mapAsync(constructors.GPUMapMode.READ);
        const bytes = readback.getMappedRange().slice(0);
        const uints = new Uint32Array(bytes);
        const ints = new Int32Array(bytes);
        const records = unique.map((_, index) => {
          const offset = index * 5;
          return {
            indexCount: uints[offset],
            instanceCount: uints[offset + 1],
            firstIndex: uints[offset + 2],
            baseVertex: ints[offset + 3],
            firstInstance: uints[offset + 4]
          };
        });
        readback.unmap();
        readback.destroy();
        return records;
      }
    };
  });
}

async function compareScreenshots(
  page: Page,
  baseline: Buffer,
  candidate: Buffer
): Promise<{ readonly normalizedRmse: number; readonly changedPixels: number }> {
  return page.evaluate(
    async ({ baselineBase64, candidateBase64 }) => {
      const decode = async (base64: string): Promise<ImageBitmap> =>
        createImageBitmap(await (await fetch(`data:image/png;base64,${base64}`)).blob());
      const baselineImage = await decode(baselineBase64);
      const candidateImage = await decode(candidateBase64);
      if (baselineImage.width !== candidateImage.width || baselineImage.height !== candidateImage.height) {
        throw new Error("Screenshot dimensions differ.");
      }
      const canvas = new OffscreenCanvas(baselineImage.width, baselineImage.height);
      const context = canvas.getContext("2d")!;
      context.drawImage(baselineImage, 0, 0);
      const baselinePixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
      context.clearRect(0, 0, canvas.width, canvas.height);
      context.drawImage(candidateImage, 0, 0);
      const candidatePixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
      baselineImage.close();
      candidateImage.close();

      let squaredError = 0;
      let changedPixels = 0;
      for (let offset = 0; offset < baselinePixels.length; offset += 4) {
        let changed = false;
        for (let channel = 0; channel < 3; channel++) {
          const delta = baselinePixels[offset + channel] - candidatePixels[offset + channel];
          squaredError += delta * delta;
          changed ||= Math.abs(delta) > 5;
        }
        changedPixels += Number(changed);
      }
      return {
        normalizedRmse: Math.sqrt(squaredError / ((baselinePixels.length / 4) * 3)) / 255,
        changedPixels
      };
    },
    {
      baselineBase64: baseline.toString("base64"),
      candidateBase64: candidate.toString("base64")
    }
  );
}

test("Grasslands reloads into WebGPU and renders terrain surface categories", async ({ page }, testInfo) => {
  test.skip(!webgpuEnabled, "Set TERRAIN_E2E_WEBGPU=1 to launch Chromium with WebGPU.");

  await page.addInitScript(() => {
    const counts: WebGPUComputeCounts = {
      createComputePipeline: 0,
      beginComputePass: 0,
      dispatchWorkgroups: 0,
      dispatchedWorkgroups: 0,
      maxWorkgroupCountX: 0
    };
    window.__webgpuComputeCounts = counts;
    const constructors = globalThis as unknown as {
      GPUDevice?: { prototype: ComputeDevicePrototype };
      GPUCommandEncoder?: { prototype: ComputeCommandEncoderPrototype };
    };
    if (!constructors.GPUDevice || !constructors.GPUCommandEncoder) return;
    const devicePrototype = constructors.GPUDevice.prototype;
    const createComputePipeline = devicePrototype.createComputePipeline;
    devicePrototype.createComputePipeline = function (descriptor) {
      counts.createComputePipeline++;
      return createComputePipeline.call(this, descriptor);
    };
    const commandEncoderPrototype = constructors.GPUCommandEncoder.prototype;
    const beginComputePass = commandEncoderPrototype.beginComputePass;
    commandEncoderPrototype.beginComputePass = function (descriptor) {
      counts.beginComputePass++;
      const pass = beginComputePass.call(this, descriptor);
      const dispatchWorkgroups = pass.dispatchWorkgroups.bind(pass);
      pass.dispatchWorkgroups = (workgroupCountX, workgroupCountY, workgroupCountZ) => {
        counts.dispatchWorkgroups++;
        counts.dispatchedWorkgroups += workgroupCountX * (workgroupCountY ?? 1) * (workgroupCountZ ?? 1);
        counts.maxWorkgroupCountX = Math.max(counts.maxWorkgroupCountX, workgroupCountX);
        dispatchWorkgroups(workgroupCountX, workgroupCountY, workgroupCountZ);
      };
      return pass;
    };
  });

  const diagnostics: string[] = [];
  page.on("console", (message) => {
    const text = message.text();
    if (
      message.type() === "error" ||
      (message.type() === "warning" &&
        /webgpu|gpu|renderpipeline|commandbuffer|vertex buffer|validation|invalid|exceeds/i.test(text))
    ) {
      diagnostics.push(`${message.type()}: ${text}`);
    }
  });
  page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

  await page.goto("/demos/terrain/grasslands/?backend=webgl2&gpuTiming=1", { waitUntil: "networkidle" });
  await page.waitForFunction(() => window.terrainDebug?.ready === true);
  await expect(page.locator("#status")).toContainText("webgl2");
  expect(await page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming())).toEqual({
    supported: false,
    enabled: false,
    latestSample: null,
    droppedSampleCount: 0
  });
  await page.evaluate(() => {
    window.grasslandsDebug!.setScene({ animation: false });
  });
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
  const webglSurface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
  const webglTimeOrigin = await page.evaluate(() => performance.timeOrigin);

  await Promise.all([page.waitForURL(/backend=webgpu/), page.locator("#backend").selectOption("webgpu")]);
  await page.waitForFunction(() => window.terrainDebug?.ready === true);
  await expect(page.locator("#status")).toContainText("webgpu");
  expect(await page.evaluate(() => performance.timeOrigin)).not.toBe(webglTimeOrigin);
  const gpuTimingSupported = await page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().supported);
  expect(await page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().enabled)).toBe(gpuTimingSupported);
  if (gpuTimingSupported) {
    expect(await page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().latestSample)).toBeNull();
    expect(await page.evaluate(() => window.grasslandsDebug!.requestGPUTimingSample())).toBe(true);
    await expect
      .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().latestSample?.durationMs ?? 0))
      .toBeGreaterThan(0);
    const firstGpuSample = await page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().latestSample!);
    expect(firstGpuSample.passCount).toBeGreaterThan(0);
    expect(firstGpuSample.passes).toHaveLength(firstGpuSample.passCount);
    expect(firstGpuSample.passes.every((pass) => pass.durationMs >= 0)).toBe(true);
    expect(firstGpuSample.passes.every((pass) => pass.name.length > 0)).toBe(true);
    expect(firstGpuSample.durationMs).toBeGreaterThanOrEqual(
      Math.max(...firstGpuSample.passes.map((pass) => pass.durationMs))
    );
    expect(firstGpuSample.passes.map((pass) => pass.name)).toEqual(
      expect.arrayContaining([
        "shadow",
        "depth-prepass",
        "forward",
        "grasslands-exposure",
        "post-process-uber",
        "final-srgb"
      ])
    );
    const initialSubmissionId = await page.evaluate(
      () => window.grasslandsDebug!.inspectGPUTiming().latestSample!.submissionId
    );
    await page.evaluate(() => window.grasslandsDebug!.setScene({ shadows: false }));
    expect(await page.evaluate(() => window.grasslandsDebug!.requestGPUTimingSample())).toBe(true);
    await expect
      .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().latestSample?.submissionId ?? 0))
      .toBeGreaterThan(initialSubmissionId);
    const noShadowPasses = await page.evaluate(() =>
      window.grasslandsDebug!.inspectGPUTiming().latestSample!.passes.map((pass) => pass.name)
    );
    expect(noShadowPasses).toContain("forward");
    expect(noShadowPasses).not.toContain("shadow");

    const noShadowSubmissionId = await page.evaluate(
      () => window.grasslandsDebug!.inspectGPUTiming().latestSample!.submissionId
    );
    await page.evaluate(() => window.grasslandsDebug!.setScene({ shadows: true, postProcess: false }));
    expect(await page.evaluate(() => window.grasslandsDebug!.requestGPUTimingSample())).toBe(true);
    await expect
      .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().latestSample?.submissionId ?? 0))
      .toBeGreaterThan(noShadowSubmissionId);
    const noPostProcessPasses = await page.evaluate(() =>
      window.grasslandsDebug!.inspectGPUTiming().latestSample!.passes.map((pass) => pass.name)
    );
    expect(noPostProcessPasses).toContain("shadow");
    expect(noPostProcessPasses).toContain("depth-prepass");
    expect(noPostProcessPasses).toContain("forward");
    expect(noPostProcessPasses).not.toContain("grasslands-exposure");
    expect(noPostProcessPasses).not.toContain("post-process-uber");

    const noPostProcessSubmissionId = await page.evaluate(
      () => window.grasslandsDebug!.inspectGPUTiming().latestSample!.submissionId
    );
    await page.evaluate(() => window.grasslandsDebug!.setScene({ architecture: false }));
    expect(await page.evaluate(() => window.grasslandsDebug!.requestGPUTimingSample())).toBe(true);
    await expect
      .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().latestSample?.submissionId ?? 0))
      .toBeGreaterThan(noPostProcessSubmissionId);
    const surfaceOnlyPasses = await page.evaluate(() =>
      window.grasslandsDebug!.inspectGPUTiming().latestSample!.passes.map((pass) => pass.name)
    );
    expect(surfaceOnlyPasses).toContain("shadow");
    expect(surfaceOnlyPasses).toContain("forward");
    expect(surfaceOnlyPasses).not.toContain("depth-prepass");
    await page.evaluate(() => window.grasslandsDebug!.setScene({ architecture: true, postProcess: true }));
  }

  await page.evaluate(() => {
    window.grasslandsDebug!.setScene({ animation: false });
  });
  await expect
    .poll(async () => {
      const surface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
      return surface.visibleRendererBatches < surface.visibleRanges;
    })
    .toBe(true);
  const surface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
  expect(surface.categoryCounts.grass).toBeGreaterThan(0);
  expect(surface.categoryCounts.tree).toBeGreaterThan(0);
  expect(surface.categoryCounts.rock).toBeGreaterThan(0);
  expect(surface.visibleRendererBatches).toBeLessThan(webglSurface.visibleRendererBatches);
  expect(surface.indirectRendererBatches).toBe(6);
  expect(webglSurface.indirectRendererBatches).toBe(0);

  await page.evaluate(() => window.grasslandsDebug!.setSurface({ lod: { enabled: false } }));
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
  const lod0Surface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
  const transitioningSurface = await page.evaluate(() => {
    window.grasslandsDebug!.setSurface({ lod: { enabled: true } });
    return window.grasslandsDebug!.inspectSurface();
  });
  expect(transitioningSurface.transitioningRanges).toBeGreaterThan(0);
  expect(transitioningSurface.visibleRendererBatches).toBeGreaterThan(lod0Surface.visibleRendererBatches);
  expect(transitioningSurface.indirectRendererBatches).toBe(lod0Surface.indirectRendererBatches);
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
  expect(
    await page.evaluate(() =>
      window
        .grasslandsDebug!.inspectSurface()
        .lodCounts.slice(1)
        .some((count) => count > 0)
    )
  ).toBe(true);

  const computeCounts = await page.evaluate(() => window.__webgpuComputeCounts);
  await testInfo.attach("webgpu-compute-counts.json", {
    body: Buffer.from(JSON.stringify(computeCounts, null, 2)),
    contentType: "application/json"
  });
  expect(computeCounts.createComputePipeline).toBe(4);
  expect(computeCounts.dispatchWorkgroups).toBeGreaterThan(0);
  expect(computeCounts.dispatchedWorkgroups).toBeGreaterThan(computeCounts.dispatchWorkgroups);
  expect(computeCounts.beginComputePass).toBeLessThan(computeCounts.dispatchWorkgroups);
  expect(computeCounts.maxWorkgroupCountX).toBeGreaterThan(1);
  const settledDispatchCount = computeCounts.dispatchWorkgroups;
  await page.waitForTimeout(250);
  expect(await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups)).toBe(settledDispatchCount);

  const initialCamera = await page.evaluate(() => window.terrainDebug!.getCamera());
  const initialGrassScale = await page.evaluate(() => window.grasslandsDebug!.inspectSurface().tuning.scale.grass);
  await page.evaluate(() => window.terrainDebug!.setPose("terrain-horizon"));
  await expect
    .poll(() => page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups))
    .toBeGreaterThan(settledDispatchCount);
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
  const movedDispatchCount = await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups);
  await page.waitForTimeout(250);
  expect(await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups)).toBe(movedDispatchCount);

  await page.evaluate(() => window.grasslandsDebug!.setSurface({ scale: { grass: 4 } }));
  await expect
    .poll(() => page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups))
    .toBeGreaterThan(movedDispatchCount);
  const scaledDispatchCount = await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups);
  await page.waitForTimeout(250);
  expect(await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups)).toBe(scaledDispatchCount);

  await page.evaluate(() => window.grasslandsDebug!.setSurface({ enabled: { rock: false } }));
  await expect
    .poll(() => page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups))
    .toBeGreaterThan(scaledDispatchCount);
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
  const rockDisabledDispatchCount = await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups);
  await page.waitForTimeout(250);
  expect(await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups)).toBe(rockDisabledDispatchCount);

  await page.evaluate(
    ({ camera, grassScale }) => {
      window.terrainDebug!.setCamera(camera);
      window.grasslandsDebug!.setSurface({ enabled: { rock: true }, scale: { grass: grassScale } });
    },
    { camera: initialCamera, grassScale: initialGrassScale }
  );
  await expect
    .poll(() => page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups))
    .toBeGreaterThan(rockDisabledDispatchCount);
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);

  await page.waitForTimeout(1_000);
  const screenshot = await page.locator("#canvas").screenshot();
  await testInfo.attach("grasslands-webgpu.png", { body: screenshot, contentType: "image/png" });
  const metrics = await page.evaluate(async (pngBase64) => {
    const image = await createImageBitmap(await (await fetch(`data:image/png;base64,${pngBase64}`)).blob());
    const canvas = new OffscreenCanvas(80, 45);
    const context = canvas.getContext("2d")!;
    context.drawImage(image, 0, 0, canvas.width, canvas.height);
    image.close();
    const pixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
    const colors = new Set<number>();
    let luminance = 0;
    let darkPixels = 0;
    let brightPixels = 0;
    for (let offset = 0; offset < pixels.length; offset += 4) {
      const red = pixels[offset];
      const green = pixels[offset + 1];
      const blue = pixels[offset + 2];
      const value = red * 0.2126 + green * 0.7152 + blue * 0.0722;
      colors.add((red << 16) | (green << 8) | blue);
      luminance += value;
      darkPixels += Number(value < 48);
      brightPixels += Number(value > 160);
    }
    return {
      colors: colors.size,
      averageLuminance: luminance / (pixels.length / 4),
      darkPixels,
      brightPixels
    };
  }, screenshot.toString("base64"));

  expect(metrics.colors).toBeGreaterThan(128);
  expect(metrics.averageLuminance).toBeGreaterThan(40);
  expect(metrics.averageLuminance).toBeLessThan(220);
  expect(metrics.darkPixels).toBeGreaterThan(0);
  expect(metrics.brightPixels).toBeGreaterThan(0);
  expect(diagnostics).toEqual([]);
});

test("primes Grasslands Forward with the prepass depth attachment", async ({ page }, testInfo) => {
  test.skip(!webgpuEnabled, "Set TERRAIN_E2E_WEBGPU=1 to launch Chromium with WebGPU.");
  await installDepthPrimingCapture(page);

  const diagnostics: string[] = [];
  page.on("console", (message) => {
    const text = message.text();
    if (
      message.type() === "error" ||
      (message.type() === "warning" && /webgpu|gpu|renderpipeline|commandbuffer|validation|invalid|exceeds/i.test(text))
    ) {
      diagnostics.push(`${message.type()}: ${text}`);
    }
  });
  page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

  const captureStableFrame = async (
    url: string
  ): Promise<{
    readonly passes: readonly DepthPrimingPassCapture[];
    readonly screenshots: Readonly<Record<string, Buffer>>;
  }> => {
    await page.goto(url, { waitUntil: "networkidle" });
    await page.waitForFunction(() => window.grasslandsDebug?.ready === true);
    await page.evaluate(() => {
      window.grasslandsDebug!.setScene({ animation: false, architecture: false, clouds: false });
      window.grasslandsDebug!.setSurface({ wind: { enabled: false } });
    });
    await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
    await page.evaluate(() => window.__depthPrimingCapture.reset());
    const screenshots: Record<string, Buffer> = {};
    for (const pose of ["first-person", "hero", "terrain-horizon", "valley-overview"] as const) {
      await page.evaluate((nextPose) => window.terrainDebug!.setPose(nextPose), pose);
      await page.waitForTimeout(100);
      await expect
        .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges))
        .toBe(0);
      await page.waitForTimeout(100);
      screenshots[pose] = await page.locator("#canvas").screenshot();
    }
    return {
      passes: await page.evaluate(() => window.__depthPrimingCapture.read()),
      screenshots
    };
  };

  const baseline = await captureStableFrame("/demos/terrain/grasslands/?backend=webgpu&pose=terrain-horizon");
  const baselineRepeat = await captureStableFrame("/demos/terrain/grasslands/?backend=webgpu&pose=terrain-horizon");
  const candidate = await captureStableFrame(
    "/demos/terrain/grasslands/?backend=webgpu&depthPriming=1&pose=terrain-horizon"
  );
  const comparisons: Record<string, { readonly normalizedRmse: number; readonly changedPixels: number }> =
    Object.fromEntries(
      await Promise.all(
        Object.keys(baseline.screenshots).map(async (pose) => [
          pose,
          await compareScreenshots(page, baseline.screenshots[pose], candidate.screenshots[pose])
        ])
      )
    );
  const baselineNoise: Record<string, { readonly normalizedRmse: number; readonly changedPixels: number }> =
    Object.fromEntries(
      await Promise.all(
        Object.keys(baseline.screenshots).map(async (pose) => [
          pose,
          await compareScreenshots(page, baseline.screenshots[pose], baselineRepeat.screenshots[pose])
        ])
      )
    );

  const selectLastPassPair = (
    passes: readonly DepthPrimingPassCapture[]
  ): { readonly depth: DepthPrimingPassCapture; readonly forward: DepthPrimingPassCapture } => {
    for (let index = passes.length - 1; index >= 0; index--) {
      if (passes[index].label !== "forward") continue;
      const depth = passes.slice(0, index).findLast((pass) => pass.label === "depth-prepass");
      if (depth) return { depth, forward: passes[index] };
    }
    throw new Error("No depth-prepass/forward pair was captured.");
  };
  const baselineForward = baseline.passes.findLast((pass) => pass.label === "forward");
  if (!baselineForward) throw new Error("No baseline Forward pass was captured.");
  const candidatePair = selectLastPassPair(candidate.passes);

  await testInfo.attach("depth-priming-contract.json", {
    body: Buffer.from(
      JSON.stringify(
        {
          baseline: baselineForward,
          candidate: candidatePair,
          comparisons,
          baselineNoise
        },
        null,
        2
      )
    ),
    contentType: "application/json"
  });
  for (const pose of Object.keys(baseline.screenshots)) {
    await testInfo.attach(`depth-priming-${pose}-baseline.png`, {
      body: baseline.screenshots[pose],
      contentType: "image/png"
    });
    await testInfo.attach(`depth-priming-${pose}-candidate.png`, {
      body: candidate.screenshots[pose],
      contentType: "image/png"
    });
  }
  console.log(`DEPTH_PRIMING_VISUAL_SUMMARY ${JSON.stringify({ comparisons, baselineNoise })}`);

  expect(baseline.passes.some((pass) => pass.label === "depth-prepass")).toBe(false);
  expect(baselineForward.depthReadOnly).toBe(false);
  expect(baselineForward.indirectPipelines).toHaveLength(6);
  expect(
    baselineForward.indirectPipelines.every(
      (pipeline) => pipeline.depthCompare === "less" && pipeline.depthWriteEnabled === true
    )
  ).toBe(true);

  expect(candidatePair.depth.depthTextureId).toBe(candidatePair.forward.depthTextureId);
  expect(candidatePair.depth.colorAttachmentCount).toBe(0);
  expect(candidatePair.depth.depthReadOnly).toBe(false);
  expect(candidatePair.depth.depthLoadOp).toBe("clear");
  expect(candidatePair.depth.depthStoreOp).toBe("store");
  expect(candidatePair.depth.indirectPipelines).toHaveLength(6);
  expect(candidatePair.depth.indirectPipelines.every((pipeline) => pipeline.colorWriteMasks.length === 0)).toBe(true);
  expect(candidatePair.depth.pipelines.every((pipeline) => pipeline.colorWriteMasks.every((mask) => mask === 0))).toBe(
    true
  );
  expect(candidatePair.forward.colorAttachmentCount).toBeGreaterThan(0);
  expect(candidatePair.forward.depthReadOnly).toBe(true);
  expect(candidatePair.forward.depthLoadOp).toBeUndefined();
  expect(candidatePair.forward.depthStoreOp).toBeUndefined();
  expect(candidatePair.forward.indirectPipelines).toHaveLength(6);
  expect(
    candidatePair.forward.indirectPipelines.every(
      (pipeline) => pipeline.depthCompare === "less-equal" && pipeline.depthWriteEnabled === false
    )
  ).toBe(true);
  for (const [pose, comparison] of Object.entries(comparisons)) {
    expect(comparison.normalizedRmse).toBeLessThan(0.005);
    expect(comparison.changedPixels).toBeLessThan(1_000);
  }
  expect(diagnostics).toEqual([]);
});

test("builds conservative depth tiles between the Grasslands depth and forward passes", async ({ page }, testInfo) => {
  test.skip(!webgpuEnabled, "Set TERRAIN_E2E_WEBGPU=1 to launch Chromium with WebGPU.");

  await page.addInitScript(() => {
    const sequence: string[] = [];
    window.__webgpuPassSequence = sequence;
    const constructors = globalThis as unknown as {
      GPUCommandEncoder?: {
        prototype: {
          beginRenderPass(descriptor: { label?: string }): unknown;
          beginComputePass(descriptor?: { label?: string }): unknown;
        };
      };
    };
    if (!constructors.GPUCommandEncoder) return;
    const prototype = constructors.GPUCommandEncoder.prototype;
    const beginRenderPass = prototype.beginRenderPass;
    prototype.beginRenderPass = function (descriptor) {
      sequence.push(descriptor.label ?? "render");
      return beginRenderPass.call(this, descriptor);
    };
    const beginComputePass = prototype.beginComputePass;
    prototype.beginComputePass = function (descriptor) {
      sequence.push(descriptor?.label ?? "compute");
      return beginComputePass.call(this, descriptor);
    };
  });

  const diagnostics: string[] = [];
  page.on("console", (message) => {
    const text = message.text();
    if (
      message.type() === "error" ||
      (message.type() === "warning" && /webgpu|gpu|validation|invalid|exceeds/i.test(text))
    ) {
      diagnostics.push(`${message.type()}: ${text}`);
    }
  });
  page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

  await page.goto("/demos/terrain/grasslands/?backend=webgpu&surfaceHiZ=depth-tiles&pose=terrain-horizon", {
    waitUntil: "networkidle"
  });
  await page.waitForFunction(() => window.grasslandsDebug?.ready === true);
  await page.evaluate(() => window.grasslandsDebug!.setScene({ animation: false }));
  await expect
    .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectDepthTiles()?.dispatchCount ?? 0))
    .toBeGreaterThan(0);

  const snapshot = await page.evaluate(() => {
    const canvas = document.querySelector<HTMLCanvasElement>("#canvas")!;
    return {
      depthTiles: window.grasslandsDebug!.inspectDepthTiles()!,
      canvas: { width: canvas.width, height: canvas.height }
    };
  });
  expect(snapshot.depthTiles.width).toBe(snapshot.canvas.width);
  expect(snapshot.depthTiles.height).toBe(snapshot.canvas.height);
  expect(snapshot.depthTiles.tileEdge).toBeGreaterThan(0);
  expect(snapshot.depthTiles.tilesX).toBe(Math.ceil(snapshot.canvas.width / snapshot.depthTiles.tileEdge));
  expect(snapshot.depthTiles.tilesY).toBe(Math.ceil(snapshot.canvas.height / snapshot.depthTiles.tileEdge));

  const sequence = await page.evaluate(() => window.__webgpuPassSequence);
  expect(
    sequence.some((name, index) => {
      if (name !== "depth-prepass") return false;
      const computeIndex = sequence.indexOf("compute", index + 1);
      const forwardIndex = sequence.indexOf("forward", index + 1);
      return computeIndex > index && forwardIndex > computeIndex;
    })
  ).toBe(true);

  const screenshotPath = testInfo.outputPath("grasslands-depth-tiles.png");
  const screenshot = await page.locator("#canvas").screenshot({ path: screenshotPath });
  await testInfo.attach("grasslands-depth-tiles.png", { path: screenshotPath, contentType: "image/png" });
  expect(screenshot.byteLength).toBeGreaterThan(10_000);
  expect(diagnostics).toEqual([]);
});

test("copies six fine-cull batches into an equivalent after-depth Forward stream", async ({ page }, testInfo) => {
  test.skip(!webgpuEnabled, "Set TERRAIN_E2E_WEBGPU=1 to launch Chromium with WebGPU.");
  await installSurfaceIndirectCapture(page);

  const diagnostics: string[] = [];
  page.on("console", (message) => {
    const text = message.text();
    if (
      message.type() === "error" ||
      (message.type() === "warning" && /webgpu|gpu|validation|invalid|exceeds/i.test(text))
    ) {
      diagnostics.push(`${message.type()}: ${text}`);
    }
  });
  page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

  const configureStableSurface = async (): Promise<void> => {
    await page.waitForFunction(() => window.grasslandsDebug?.ready === true);
    await page.evaluate(() => {
      window.grasslandsDebug!.setScene({ animation: false });
      window.grasslandsDebug!.setSurface({ wind: { enabled: false } });
    });
    await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
    await page.evaluate(() => window.__surfaceIndirectCapture.reset());
    await page.waitForTimeout(250);
  };

  await page.goto("/demos/terrain/grasslands/?backend=webgpu&surfaceHiZ=depth-tiles&pose=terrain-horizon", {
    waitUntil: "networkidle"
  });
  await configureStableSurface();
  const baselineSurface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
  const baselineRecords = await page.evaluate(() => window.__surfaceIndirectCapture.readForwardRecords());
  const baselineScreenshot = await page.locator("#canvas").screenshot();

  await page.goto("/demos/terrain/grasslands/?backend=webgpu&surfaceHiZ=copy-survivors&pose=terrain-horizon", {
    waitUntil: "networkidle"
  });
  await configureStableSurface();
  const candidateSurface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
  const candidateOutput = await page.evaluate(() => window.grasslandsDebug!.inspectDepthTileOcclusion());
  const candidateRecords = await page.evaluate(() => window.__surfaceIndirectCapture.readForwardRecords());
  const candidateSequence = await page.evaluate(() => window.__webgpuPassSequence);
  const candidateScreenshot = await page.locator("#canvas").screenshot();
  const screenshotComparison = await compareScreenshots(page, baselineScreenshot, candidateScreenshot);

  await testInfo.attach("surface-output-identity.json", {
    body: Buffer.from(
      JSON.stringify(
        {
          baselineRecords,
          candidateRecords,
          candidateOutput,
          screenshotComparison
        },
        null,
        2
      )
    ),
    contentType: "application/json"
  });
  await testInfo.attach("surface-output-baseline.png", {
    body: baselineScreenshot,
    contentType: "image/png"
  });
  await testInfo.attach("surface-output-candidate.png", {
    body: candidateScreenshot,
    contentType: "image/png"
  });

  expect(baselineRecords).toHaveLength(6);
  expect(candidateRecords).toEqual(baselineRecords);
  expect(candidateRecords.every((record) => record.instanceCount > 0)).toBe(true);
  expect(candidateOutput).toMatchObject({
    batchCount: 6,
    indirectRecordCount: 6
  });
  expect(candidateOutput!.instanceCapacity).toBeGreaterThan(
    candidateRecords.reduce((count, record) => count + record.instanceCount, 0)
  );
  expect(candidateOutput!.dispatchCount).toBeGreaterThan(0);
  expect(candidateSurface).toEqual(baselineSurface);
  expect(
    candidateSequence.some((name, index) => {
      if (name !== "depth-prepass") return false;
      const forwardIndex = candidateSequence.indexOf("forward", index + 1);
      if (forwardIndex < 0) return false;
      return candidateSequence.slice(index + 1, forwardIndex).filter((entry) => entry === "dispatch").length >= 2;
    })
  ).toBe(true);
  expect(screenshotComparison.normalizedRmse).toBeLessThan(0.002);
  expect(screenshotComparison.changedPixels).toBeLessThan(2_000);
  expect(diagnostics).toEqual([]);
});

test("records matched Grasslands depth-priming GPU timings", async ({ page }, testInfo) => {
  test.skip(!webgpuEnabled || !benchmarkEnabled, "Set TERRAIN_E2E_WEBGPU=1 and TERRAIN_E2E_BENCHMARK=1.");

  const diagnostics: string[] = [];
  page.on("console", (message) => {
    const text = message.text();
    if (
      message.type() === "error" ||
      (message.type() === "warning" && /webgpu|gpu|validation|invalid|exceeds/i.test(text))
    ) {
      diagnostics.push(`${message.type()}: ${text}`);
    }
  });
  page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

  const workloads = [
    { name: "all", enabled: { grass: true, tree: true, rock: true } },
    { name: "no_grass", enabled: { grass: false, tree: true, rock: true } },
    { name: "no_tree", enabled: { grass: true, tree: false, rock: true } },
    { name: "no_rock", enabled: { grass: true, tree: true, rock: false } }
  ] as const;
  const results: Record<
    string,
    Record<
      string,
      {
        readonly samples: readonly {
          readonly durationMs: number;
          readonly passes: Readonly<Record<string, number>>;
        }[];
        readonly frameTimesMs: readonly number[];
        readonly visibleCategoryCounts: Readonly<Record<string, number>>;
      }
    >
  > = {};

  for (const workload of workloads) {
    results[workload.name] = {};
    for (const candidate of [false, true]) {
      const name = candidate ? "depth_priming" : "baseline";
      const query = new URLSearchParams({
        backend: "webgpu",
        gpuTiming: "1",
        pose: "terrain-horizon"
      });
      if (candidate) query.set("depthPriming", "1");
      await page.goto(`/demos/terrain/grasslands/?${query}`, { waitUntil: "networkidle" });
      await page.waitForFunction(() => window.grasslandsDebug?.ready === true);
      await page.evaluate((enabled) => {
        window.grasslandsDebug!.setScene({ animation: false, clouds: false });
        window.grasslandsDebug!.setSurface({ enabled, wind: { enabled: false } });
      }, workload.enabled);
      await expect
        .poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges))
        .toBe(0);
      await page.waitForTimeout(500);
      expect(await page.evaluate(() => window.grasslandsDebug!.inspectGPUTiming().supported)).toBe(true);

      const samples: Array<{ readonly durationMs: number; readonly passes: Readonly<Record<string, number>> }> = [];
      for (let sampleIndex = 0; sampleIndex < 20; sampleIndex++) {
        samples.push(
          await page.evaluate(async () => {
            const previousSubmissionId = window.grasslandsDebug!.inspectGPUTiming().latestSample?.submissionId ?? -1;
            if (!window.grasslandsDebug!.requestGPUTimingSample()) {
              throw new Error("GPU timing request was rejected.");
            }
            for (let frame = 0; frame < 300; frame++) {
              await new Promise<void>((resolve) => requestAnimationFrame(() => resolve()));
              const sample = window.grasslandsDebug!.inspectGPUTiming().latestSample;
              if (sample && sample.submissionId > previousSubmissionId) {
                const passes: Record<string, number> = {};
                for (const pass of sample.passes) {
                  passes[pass.name] = (passes[pass.name] ?? 0) + pass.durationMs;
                }
                return { durationMs: sample.durationMs, passes };
              }
            }
            throw new Error("GPU timing sample did not complete.");
          })
        );
      }
      const frameTimesMs = await page.evaluate(
        () =>
          new Promise<number[]>((resolve) => {
            const timestamps: number[] = [];
            const collect = (timestamp: number): void => {
              timestamps.push(timestamp);
              if (timestamps.length < 121) {
                requestAnimationFrame(collect);
              } else {
                resolve(timestamps.slice(1).map((value, index) => value - timestamps[index]));
              }
            };
            requestAnimationFrame(collect);
          })
      );
      results[workload.name][name] = {
        samples,
        frameTimesMs,
        visibleCategoryCounts: await page.evaluate(() => window.grasslandsDebug!.inspectSurface().visibleCategoryCounts)
      };
    }
  }

  await testInfo.attach("depth-priming-benchmark.json", {
    body: Buffer.from(JSON.stringify(results, null, 2)),
    contentType: "application/json"
  });
  const percentile = (values: readonly number[], ratio: number): number => {
    const sorted = [...values].sort((left, right) => left - right);
    const position = (sorted.length - 1) * ratio;
    const lower = Math.floor(position);
    const upper = Math.ceil(position);
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (position - lower);
  };
  const summarize = (values: readonly number[]) => ({
    median: percentile(values, 0.5),
    p25: percentile(values, 0.25),
    p75: percentile(values, 0.75),
    p95: percentile(values, 0.95)
  });
  const summary = Object.fromEntries(
    workloads.map((workload) => {
      const blocks = results[workload.name];
      const baseline = blocks.baseline;
      const candidate = blocks.depth_priming;
      const baselineForward = baseline.samples.map((sample) => sample.passes.forward);
      const candidateForward = candidate.samples.map((sample) => sample.passes.forward);
      const baselineTotal = baseline.samples.map((sample) => sample.durationMs);
      const candidateTotal = candidate.samples.map((sample) => sample.durationMs);
      const baselineForwardMedian = percentile(baselineForward, 0.5);
      const candidateForwardMedian = percentile(candidateForward, 0.5);
      const baselineTotalMedian = percentile(baselineTotal, 0.5);
      const candidateTotalMedian = percentile(candidateTotal, 0.5);
      return [
        workload.name,
        {
          baseline: {
            total: summarize(baselineTotal),
            forward: summarize(baselineForward),
            depthPrepass: summarize(baseline.samples.map((sample) => sample.passes["depth-prepass"] ?? 0)),
            frame: summarize(baseline.frameTimesMs)
          },
          depthPriming: {
            total: summarize(candidateTotal),
            forward: summarize(candidateForward),
            depthPrepass: summarize(candidate.samples.map((sample) => sample.passes["depth-prepass"] ?? 0)),
            frame: summarize(candidate.frameTimesMs)
          },
          medianDeltaPercent: {
            total: ((candidateTotalMedian - baselineTotalMedian) / baselineTotalMedian) * 100,
            forward: ((candidateForwardMedian - baselineForwardMedian) / baselineForwardMedian) * 100
          }
        }
      ];
    })
  );
  await testInfo.attach("depth-priming-benchmark-summary.json", {
    body: Buffer.from(JSON.stringify(summary, null, 2)),
    contentType: "application/json"
  });
  console.log(`DEPTH_PRIMING_BENCHMARK_SUMMARY ${JSON.stringify(summary)}`);
  expect(diagnostics).toEqual([]);
});

test("reduces known depth values into conservative far-depth tiles", async ({ page }) => {
  test.skip(!webgpuEnabled, "Set TERRAIN_E2E_WEBGPU=1 to launch Chromium with WebGPU.");

  const diagnostics: string[] = [];
  page.on("console", (message) => {
    if (message.type() === "error" || message.type() === "warning") {
      diagnostics.push(`${message.type()}: ${message.text()}`);
    }
  });
  page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

  await page.goto("/demos/terrain/e2e/fixtures/surface-depth-tiles/", { waitUntil: "networkidle" });
  await expect(page.locator("#result")).toContainText("PASS");
  await expect(page.locator("#result")).toContainText("3x2 tiles");
  expect(diagnostics).toEqual([]);
});
