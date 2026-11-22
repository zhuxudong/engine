import { chromium } from "@playwright/test";
import { createServer } from "vite";
import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { compareImages, withinTolerance } from "./compare.mjs";

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
  "particleRenderer-shape-mesh",
  "gltf-meshopt",
  "animator-play",
  "material-pbr-specular",
  "material-white-furnace",
  "texture-hdr",
  "texture-hdr-ktx2",
  "texture-sRGB-KTX2",
  "postProcess-HDR-bloom-ACES",
  "postProcess-LDR-bloom-neutral",
  "postProcess-customPass",
  "trailRenderer-basic",
  "text-character-spacing",
  "text-typed",
  "shadow-transparent",
  "shader-mrt",
  "multi-camera-no-clear",
  "camera-fxaa"
];
const root = fileURLToPath(new URL("../../../e2e/", import.meta.url));
const galleryRoot = path.join(root, ".dev");
const template = await readFile(path.join(galleryRoot, "template/iframe.ejs"), "utf8");
const directory = process.env.CAPTURE_DIRECTORY;
const requested = process.argv.slice(2);
const selected = requested.includes("--all")
  ? (await readdir(path.join(root, "case")))
      .filter((file) => !file.startsWith(".") && file.endsWith(".ts"))
      .sort()
      .map((file) => file.slice(0, -3))
  : requested.length
    ? requested
    : examples;
if (directory) await mkdir(directory, { recursive: true });
const goldenDirectory = path.join(root, "fixtures/originImage");
const goldenFiles = process.env.GOLDENS === "1" ? await readdir(goldenDirectory) : null;

async function readGolden(entry) {
  const filename = goldenFiles.find((name) => name.endsWith("_" + entry + ".jpg"));
  if (!filename) throw new Error("Missing gallery reference for " + entry);
  const bytes = await readFile(path.join(goldenDirectory, filename));
  const pointer = /^version https.*\noid sha256:([a-f0-9]{64})\n/.exec(bytes.subarray(0, 150).toString("ascii"));
  if (!pointer) return bytes;
  const oid = pointer[1];
  const gitDir = execFileSync("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], {
    cwd: root,
    encoding: "utf8"
  }).trim();
  return readFile(path.join(gitDir, "lfs/objects", oid.slice(0, 2), oid.slice(2, 4), oid));
}

const browser = await chromium.launch({ args: ["--ignore-gpu-blocklist", "--use-gl=angle"] });
const captures = new Map();
let failures = 0;
try {
  for (const backend of ["webgl2", "webgpu"]) {
    const server = await createServer({
      root: galleryRoot,
      publicDir: path.join(galleryRoot, "public"),
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
              const name = /^\/mpa\/([^/]+)\.html$/.exec(url.pathname)?.[1];
              if (!name) return next();
              if (!selected.includes(name)) {
                res.statusCode = 404;
                res.end();
                return;
              }
              res.setHeader("content-type", "text/html");
              const source = path
                .join(root, "case", name + ".ts")
                .split(path.sep)
                .join("/");
              res.end(template.replace("<%= title %>", name).replace("<%= url %>", "/@fs/" + source));
            });
          }
        }
      ],
      server: { host: "127.0.0.1", port: 0 }
    });
    await server.listen();
    try {
      for (const entry of selected) {
        const page = await browser.newPage({ viewport: { width: 1200, height: 800 } });
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
            "http://127.0.0.1:" + server.httpServer.address().port + "/mpa/" + encodeURIComponent(entry) + ".html"
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
          if (goldenFiles) {
            const reference = await readGolden(entry);
            const golden = await page.evaluate(compareImages, [reference.toString("base64"), actual.image]);
            console.log(backend, entry, "gallery reference", JSON.stringify(golden));
            if (!withinTolerance(golden)) {
              console.error(backend, entry, "Image differs from the existing gallery reference.");
              failures++;
            }
          }
          if (backend === "webgl2") {
            captures.set(entry, actual.image);
            continue;
          }
          const reference = captures.get(entry);
          if (!reference) throw new Error("Missing WebGL2 capture for this scene.");
          const delta = await page.evaluate(compareImages, [reference, actual.image]);
          console.log(entry, JSON.stringify(delta));
          if (!withinTolerance(delta)) throw new Error("Image differs from the WebGL2 reference.");
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
