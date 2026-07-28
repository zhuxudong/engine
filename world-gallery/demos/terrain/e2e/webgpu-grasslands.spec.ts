import { expect, test } from "@playwright/test";

const webgpuEnabled = process.env.TERRAIN_E2E_WEBGPU === "1";

test("Grasslands reloads into WebGPU and renders terrain surface categories", async ({ page }, testInfo) => {
  test.skip(!webgpuEnabled, "Set TERRAIN_E2E_WEBGPU=1 to launch Chromium with WebGPU.");

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
