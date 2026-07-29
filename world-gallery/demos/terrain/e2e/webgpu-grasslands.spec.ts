import { expect, test } from "@playwright/test";

const webgpuEnabled = process.env.TERRAIN_E2E_WEBGPU === "1";

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

declare global {
  interface Window {
    __webgpuComputeCounts: WebGPUComputeCounts;
  }
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

  await page.goto("/demos/terrain/grasslands/?backend=webgl2", { waitUntil: "networkidle" });
  await page.waitForFunction(() => window.terrainDebug?.ready === true);
  await expect(page.locator("#status")).toContainText("webgl2");
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
  expect(surface.indirectRendererBatches).toBeGreaterThan(1);
  expect(webglSurface.indirectRendererBatches).toBe(0);

  await page.evaluate(() => window.grasslandsDebug!.setSurface({ lod: { enabled: false } }));
  await expect.poll(() => page.evaluate(() => window.grasslandsDebug!.inspectSurface().transitioningRanges)).toBe(0);
  const lod0Surface = await page.evaluate(() => window.grasslandsDebug!.inspectSurface());
  const transitioningSurface = await page.evaluate(() => {
    window.grasslandsDebug!.setSurface({ lod: { enabled: true } });
    return window.grasslandsDebug!.inspectSurface();
  });
  expect(transitioningSurface.transitioningRanges).toBeGreaterThan(0);
  expect(transitioningSurface.indirectRendererBatches).toBeGreaterThan(lod0Surface.indirectRendererBatches);
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
  expect(computeCounts.createComputePipeline).toBe(7);
  expect(computeCounts.dispatchWorkgroups).toBeGreaterThan(0);
  expect(computeCounts.dispatchedWorkgroups).toBeGreaterThan(computeCounts.dispatchWorkgroups);
  expect(computeCounts.beginComputePass).toBeLessThan(computeCounts.dispatchWorkgroups);
  expect(computeCounts.maxWorkgroupCountX).toBeGreaterThan(1);
  const settledDispatchCount = computeCounts.dispatchWorkgroups;
  await page.waitForTimeout(250);
  expect(await page.evaluate(() => window.__webgpuComputeCounts.dispatchWorkgroups)).toBe(settledDispatchCount);

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
