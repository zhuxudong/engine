import { chromium } from "@playwright/test";
import { readFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

/** Runs in a browser so saved captures and historical JPEGs use the same decoder as the gallery tests. */
export async function compareImages([a, b]) {
  async function decode(data) {
    const bitmap = await createImageBitmap(await (await fetch("data:application/octet-stream;base64," + data)).blob());
    const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
    const context = canvas.getContext("2d");
    context.drawImage(bitmap, 0, 0);
    bitmap.close();
    return context.getImageData(0, 0, canvas.width, canvas.height);
  }
  const first = await decode(a);
  const second = await decode(b);
  if (first.width !== second.width || first.height !== second.height) throw new Error("Image dimensions differ.");
  const x = first.data;
  const y = second.data;
  const histogram = new Uint32Array(256);
  let sum = 0;
  for (let i = 0; i < x.length; i += 4) {
    const r = Math.abs(x[i] - y[i]);
    const g = Math.abs(x[i + 1] - y[i + 1]);
    const b = Math.abs(x[i + 2] - y[i + 2]);
    sum += r + g + b;
    histogram[Math.max(r, g, b)]++;
  }
  const pixels = x.length / 4;
  function percentile(fraction) {
    let count = 0;
    for (let error = 0; error < histogram.length; error++) {
      count += histogram[error];
      if (count >= pixels * fraction) return error;
    }
  }
  return {
    meanRGB: sum / (3 * pixels),
    changedFraction: histogram.subarray(21).reduce((a, b) => a + b, 0) / pixels,
    p99MaxRGB: percentile(0.99),
    maxRGB: percentile(1)
  };
}

/** Shared tolerances for the gallery and the standalone framebuffer comparison. */
export function withinTolerance({ meanRGB, changedFraction }) {
  return meanRGB <= 3 && changedFraction <= 0.025;
}

if (process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url) {
  if (process.argv.length !== 4) throw new Error("Pass a reference image and a captured image.");
  const images = await Promise.all(
    process.argv.slice(2).map(async (file) => (await readFile(file)).toString("base64"))
  );
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    const delta = await page.evaluate(compareImages, images);
    console.log(JSON.stringify(delta, null, 2));
    if (!withinTolerance(delta)) process.exitCode = 1;
  } finally {
    await browser.close();
  }
}
