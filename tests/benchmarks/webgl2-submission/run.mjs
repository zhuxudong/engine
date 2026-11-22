import { chromium } from "@playwright/test";
import { readFile, mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

const [directory, ...requested] = process.argv.slice(2);
if (!directory) throw new Error("Pass the path to the built benchmark directory.");
const root = path.resolve(directory);
const scenarios = requested.length ? requested : ["S1", "S2", "S3", "S4", "S5"];
const results = [];
const captures = process.env.CAPTURE_DIRECTORY;
const prewarm = process.env.PREWARM === "1";
if (captures) await mkdir(captures, { recursive: true });
const backend = process.env.BACKEND ?? "webgl2";
for (const scenario of scenarios) {
  const browser = await chromium.launch({ args: ["--ignore-gpu-blocklist", "--use-gl=angle"] });
  try {
    const page = await browser.newPage({ viewport: { width: 800, height: 600 }, deviceScaleFactor: 1 });
    await page.route("http://localhost/**", async (route) => {
      const pathname = decodeURIComponent(new URL(route.request().url()).pathname);
      const file = path.resolve(root, "." + (pathname === "/" ? "/index.html" : pathname));
      if (!file.startsWith(root + path.sep)) return route.abort();
      await route.fulfill({
        body: await readFile(file),
        contentType: file.endsWith(".html")
          ? "text/html"
          : file.endsWith(".wasm")
            ? "application/wasm"
            : "text/javascript"
      });
    });
    await page.goto(
      `http://localhost/?scene=${encodeURIComponent(scenario)}&backend=${encodeURIComponent(backend)}${captures ? "&capture" : ""}${prewarm ? "&prewarm" : ""}`
    );
    await page.waitForFunction(() => !!document.querySelector("#result").dataset.status, undefined, {
      timeout: 180000
    });
    const result = page.locator("#result");
    const text = await result.innerText();
    if ((await result.getAttribute("data-status")) !== "complete") throw new Error(`${scenario}: ${text}`);
    if (captures) {
      const png = await page.evaluate(() => window.benchmarkCapture);
      await writeFile(path.join(captures, backend + "-" + scenario + ".png"), Buffer.from(png, "base64"));
    }
    results.push(JSON.parse(text));
  } finally {
    await browser.close();
  }
}
console.log(JSON.stringify(results, null, 2));
