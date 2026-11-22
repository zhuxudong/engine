import { execFileSync, spawn } from "node:child_process";
import { constants } from "node:fs";
import { cp, mkdir, mkdtemp, readFile, readdir, rename, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { pipeline } from "node:stream/promises";
import { parseArgs } from "node:util";
import { fileURLToPath } from "node:url";
import { buildSeed, previewSeed } from "./fixture-vite.mjs";

const seed = "679453a52c8aa874b81124b9990320f9580369a8";
const directory = path.dirname(fileURLToPath(import.meta.url));
const engine = path.resolve(directory, "../..");
const { positionals, values } = parseArgs({
  allowPositionals: true,
  options: { backend: { type: "string", default: "webgpu" }, port: { type: "string" } }
});
const [action, destination] = positionals;
if (positionals.length !== 2 || !["prepare", "warmup", "serve"].includes(action)) {
  throw Error("Usage: pnpm seed prepare DIRECTORY | pnpm seed warmup DIRECTORY | pnpm seed serve DIRECTORY [--backend webgpu|webgl2|webgpu-warmup] [--port PORT]");
}
const work = path.resolve(destination);
const fixture = path.join(work, "fixture");
const manifest = path.join(work, "seed-preview.json");

function completed(child, command) {
  return new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("exit", (code, signal) =>
      code === 0 ? resolve() : reject(Error(command + " failed with " + (signal ?? code)))
    );
  });
}

function run(command, args, cwd) {
  return completed(spawn(command, args, { cwd, stdio: "inherit" }), command);
}

async function prepareFixture() {
  await mkdir(fixture, { recursive: true });
  const marker = path.join(fixture, ".seed-source");
  const recorded = await readFile(marker, "utf8").catch((error) => {
    if (error.code !== "ENOENT") throw error;
    return "";
  });
  if (!recorded && (await readdir(fixture)).length) throw Error("Choose a dedicated Seed preview directory.");
  if (recorded && recorded.trim() !== seed) throw Error("This preview directory belongs to another Seed revision.");
  await writeFile(marker, seed + "\n");
  const paths = [
    "package.json",
    "pnpm-lock.yaml",
    "pnpm-workspace.yaml",
    ".npmrc",
    "tsconfig.base.json",
    "tsconfig.json",
    "rollup.config.js",
    "scripts",
    "packages",
    "world"
  ];
  const archive = spawn("git", ["archive", seed, "--", ...paths], {
    cwd: engine,
    stdio: ["ignore", "pipe", "inherit"]
  });
  const extract = spawn("tar", ["xf", "-", "-C", fixture], { stdio: ["pipe", "inherit", "inherit"] });
  await Promise.all([
    pipeline(archive.stdout, extract.stdin),
    completed(archive, "git archive"),
    completed(extract, "tar")
  ]);
  await run("pnpm", ["install", "--frozen-lockfile", "--prefer-offline", "--ignore-scripts"], fixture);
  await run("pnpm", ["b:module"], fixture);
  await run(process.execPath, ["packages/modify/build/prepare.mjs"], fixture);
}

if (action === "prepare") {
  await mkdir(work, { recursive: true });
  try {
    execFileSync("git", ["cat-file", "-e", seed + "^{commit}"], { cwd: engine, stdio: "ignore" });
  } catch {
    await run("git", ["fetch", "--no-tags", "https://github.com/galacean/engine.git", seed], engine);
  }
  const revision = execFileSync("git", ["rev-parse", "HEAD"], { cwd: engine, encoding: "utf8" }).trim();
  await prepareFixture();
  const build = await mkdtemp(path.join(work, "build-"));
  try {
    const merged = path.join(build, "engine");
    const shaders = path.join(build, "shaders");
    await run("python3", [path.join(directory, "merge-engine.py"), engine, merged, seed, revision], work);
    await run(
      "python3",
      [path.join(directory, "prepare-shaders.py"), fixture, engine, merged, shaders, revision],
      work
    );
    for (const backend of ["webgl2", "webgpu"]) {
      await buildSeed({ root: fixture, engine, merged, shaders, backend, outDir: path.join(build, backend) });
    }
    const next = path.join(build, "seed-preview.json");
    await writeFile(next, JSON.stringify({ seed, engine: revision, build: path.basename(build) }, null, 2) + "\n");
    await rename(next, manifest);
  } catch (error) {
    await rm(build, { recursive: true, force: true });
    throw error;
  }
  console.log("Prepared WebGL2 and WebGPU previews for engine " + revision + " in " + work);
} else if (action === "warmup") {
  const snapshot = JSON.parse(await readFile(manifest, "utf8"));
  const revision = execFileSync("git", ["rev-parse", "HEAD"], { cwd: engine, encoding: "utf8" }).trim();
  if (snapshot.seed !== seed || snapshot.engine !== revision) {
    throw Error("Run pnpm seed prepare for this checkout before building the warmup preview.");
  }
  const build = path.join(work, snapshot.build);
  const experiment = await mkdtemp(path.join(build, "warmup-"));
  const sources = path.join(experiment, "fixture");
  try {
    await cp(fixture, sources, { recursive: true, verbatimSymlinks: true, mode: constants.COPYFILE_FICLONE });
    await run("python3", [path.join(directory, "warmup/assets/stage.py"), sources], work);
    await buildSeed({
      root: sources, engine, merged: path.join(build, "engine"), shaders: path.join(build, "shaders"),
      backend: "webgpu", warmup: true, outDir: path.join(experiment, "webgpu")
    });
    await rm(sources, { recursive: true, force: true });
    // Existing previews keep serving their snapshot until the complete build is published.
    const next = path.join(experiment, "preview.json");
    await writeFile(next, JSON.stringify({ directory: path.basename(experiment) }) + "\n");
    await rename(next, path.join(build, "warmup.json"));
  } catch (error) {
    await rm(experiment, { recursive: true, force: true });
    throw error;
  }
  console.log("Prepared the Titan Wasteland WebGPU warmup preview in " + experiment);
} else {
  const { backend } = values;
  if (!["webgl2", "webgpu", "webgpu-warmup"].includes(backend)) throw Error("Unknown Seed backend " + backend);
  const port = Number(values.port ?? ({ webgpu: 15482, webgl2: 15483, "webgpu-warmup": 15484 }[backend]));
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw Error("Invalid port " + values.port);
  const snapshot = JSON.parse(await readFile(manifest, "utf8"));
  const build = path.join(work, snapshot.build);
  const outDir = backend === "webgpu-warmup"
    ? path.join(build, JSON.parse(await readFile(path.join(build, "warmup.json"), "utf8")).directory, "webgpu")
    : path.join(build, backend);
  await previewSeed(fixture, outDir, port);
  console.log(backend + " · engine " + snapshot.engine + " · Seed " + snapshot.seed);
  const templates = backend === "webgpu-warmup" ? ["titan-wasteland"] : ["sakura-pearl", "titan-wasteland"];
  for (const template of templates) {
    console.log(
      "http://127.0.0.1:" + port + "/world/demos/seed-world/index.html?template=" + template + "&seed=20261122&view=3d"
    );
  }
}
