import { chromium } from "@playwright/test";
import { createServer } from "vite";
import { mkdir, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

const examples = [
  "ui-batch-order",
  "spriteMask-customStencil",
  "spine-tint-black",
  "spine-spineboy",
  "animator-multiSubMeshBlendShape",
  "animator-blendShape-quantization",
  "gpu-instancing-custom-data",
  "shadow-basic",
  "camera-ssao",
  "camera-opaque-texture",
  "material-pbr-clearcoat",
  "particleRenderer-sub-emitter",
  "particleRenderer-shape-mesh"
];
const root = fileURLToPath(new URL("../../../e2e/", import.meta.url));
const directory = process.env.CAPTURE_DIRECTORY;
const selected = process.argv.length > 2 ? process.argv.slice(2) : examples;
if (directory) await mkdir(directory, { recursive: true });
const browser = await chromium.launch({ args: ["--ignore-gpu-blocklist", "--use-gl=angle"] });
const captures = new Map();
let failures = 0;
try {
  for (const backend of ["webgl2", "webgpu"]) {
    const server = await createServer({
      root,
      publicDir: path.join(root, ".dev/public"),
      configFile: false,
      logLevel: "error",
      cacheDir: path.join(root, "node_modules/.vite-parity-" + backend),
      optimizeDeps: { exclude: ["web-naga"], noDiscovery: true },
      plugins: [
        {
          name: "run-existing-engine-case",
          enforce: "pre",
          transform(source, id) {
            if (backend === "webgpu" && id.includes("/e2e/case/")) {
              return source
                .replaceAll("WebGLEngine", "WebGPUEngine")
                .replaceAll('from "@galacean/engine"', 'from "@galacean/engine-webgpu"');
            }
          },
          configureServer(server) {
            server.middlewares.use((req, res, next) => {
              const url = new URL(req.url, "http://localhost");
              if (url.pathname !== "/") return next();
              const name = url.searchParams.get("case");
              if (!selected.includes(name)) {
                res.statusCode = 404;
                res.end();
                return;
              }
              res.setHeader("content-type", "text/html");
              res.end(
                '<!DOCTYPE html><style>canvas{width:900px;height:600px}</style><canvas id="canvas"></canvas><script type="module" src="/case/' +
                  encodeURIComponent(name) +
                  '.ts"></script>'
              );
            });
          }
        }
      ],
      server: { host: "127.0.0.1", port: 0 }
    });
    await server.listen();
    try {
      for (const entry of selected) {
        const page = await browser.newPage({ viewport: { width: 900, height: 600 } });
        const errors = [];
        page.on("pageerror", (error) => errors.push(error.message));
        await page.addInitScript(() => {
          window.validationErrors = [];
          if (navigator.gpu) {
            const request = GPUAdapter.prototype.requestDevice;
            GPUAdapter.prototype.requestDevice = async function (...args) {
              const device = await request.apply(this, args);
              device.addEventListener("uncapturederror", (e) => window.validationErrors.push(e.error.message));
              return device;
            };
          }
        });
        try {
          await page.goto(
            "http://127.0.0.1:" + server.httpServer.address().port + "/?case=" + encodeURIComponent(entry)
          );
          await page.waitForSelector('[data-testid="screenshot"]', { timeout: 60000 });
          const actual = await page.evaluate(async () => {
            const link = document.querySelector('[data-testid="screenshot"]');
            const blob = await (await fetch(link.href)).blob();
            const img = await createImageBitmap(blob);
            const canvas = document.createElement("canvas");
            canvas.width = img.width;
            canvas.height = img.height;
            canvas.getContext("2d").drawImage(img, 0, 0);
            img.close();
            return { image: canvas.toDataURL("image/png").split(",")[1], errors: window.validationErrors };
          });
          errors.push(...actual.errors);
          if (errors.length) throw new Error(errors[0]);
          if (directory)
            await writeFile(path.join(directory, backend + "-" + entry + ".png"), Buffer.from(actual.image, "base64"));
          if (backend === "webgl2") {
            captures.set(entry, actual.image);
            continue;
          }
          const delta = await page.evaluate(
            async ([a, b]) => {
              async function decode(data) {
                const bitmap = await createImageBitmap(await (await fetch("data:image/png;base64," + data)).blob());
                const canvas = new OffscreenCanvas(bitmap.width, bitmap.height),
                  ctx = canvas.getContext("2d");
                ctx.drawImage(bitmap, 0, 0);
                bitmap.close();
                return ctx.getImageData(0, 0, canvas.width, canvas.height).data;
              }
              const x = await decode(a),
                y = await decode(b);
              let diff = 0,
                changed = 0;
              for (let i = 0; i < x.length; i += 4) {
                const r = Math.abs(x[i] - y[i]),
                  g = Math.abs(x[i + 1] - y[i + 1]),
                  b = Math.abs(x[i + 2] - y[i + 2]);
                diff += r + g + b;
                if (Math.max(r, g, b) > 20) changed++;
              }
              return { meanRGB: diff / ((x.length / 4) * 3), changedFraction: changed / (x.length / 4) };
            },
            [captures.get(entry), actual.image]
          );
          console.log(entry, JSON.stringify(delta));
          if (delta.meanRGB > 3 || delta.changedFraction > 0.025)
            throw new Error("Image differs from the WebGL2 reference.");
        } catch (error) {
          console.error(backend, entry, error.message, errors.slice(0, 3));
          failures++;
        } finally {
          await page.close();
        }
      }
    } finally {
      await server.close();
    }
  }
} finally {
  await browser.close();
}
if (failures) process.exitCode = 1;
