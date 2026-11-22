import { spawn } from "node:child_process";
import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { parseArgs } from "node:util";
import { fileURLToPath } from "node:url";
import { createSeedServer } from "./fixture-vite.mjs";

const seedCommit = "92ea60eaee49b2f1188b373c178c34ca511c9f87";
const engine = fileURLToPath(new URL("../../..", import.meta.url));
const { positionals, values } = parseArgs({
  allowPositionals: true,
  options: {
    repository: { type: "string", default: engine },
    backend: { type: "string", default: "reference" },
    merged: { type: "string" },
    shaders: { type: "string" },
    port: { type: "string", default: "15481" }
  }
});
const [action, destination] = positionals;
if (!destination || !["prepare", "serve"].includes(action)) {
  throw Error(
    "Usage: node fixture.mjs prepare DIRECTORY [--repository PATH] | serve DIRECTORY [--backend reference|webgl2|webgpu --merged PATH --shaders PATH --port PORT]"
  );
}
const root = path.resolve(destination);
const marker = path.join(root, ".seed-benchmark-ref");

function complete(process, label) {
  return new Promise((resolve, reject) => {
    process.once("error", reject);
    process.once("exit", (code, signal) =>
      code === 0 ? resolve() : reject(Error(label + " failed with " + (signal ?? code)))
    );
  });
}
async function run(command, args) {
  await complete(spawn(command, args, { cwd: root, stdio: "inherit" }), command);
}
if (action === "prepare") {
  await mkdir(root, { recursive: true });
  const entries = await readdir(root);
  if (!entries.length) {
    const files = [
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
    const archive = spawn("git", ["-C", values.repository, "archive", seedCommit, "--", ...files], {
      stdio: ["ignore", "pipe", "inherit"]
    });
    const extract = spawn("tar", ["xf", "-", "-C", root], { stdio: ["pipe", "inherit", "inherit"] });
    archive.stdout.pipe(extract.stdin);
    await Promise.all([complete(archive, "git archive"), complete(extract, "tar")]);
    await writeFile(marker, seedCommit + "\n");
  } else if ((await readFile(marker, "utf8").catch(() => "")).trim() !== seedCommit) {
    throw Error("Choose an empty directory or the existing fixture for " + seedCommit);
  }
  await run("pnpm", ["install", "--frozen-lockfile", "--prefer-offline", "--ignore-scripts"]);
  await run("pnpm", ["b:module"]);
  await run(process.execPath, ["packages/modify/build/prepare.mjs"]);
} else {
  const port = Number(values.port);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw Error("Invalid port " + values.port);
  const server = await createSeedServer({
    root,
    engine,
    backend: values.backend,
    merged: values.merged,
    shaders: values.shaders,
    port
  });
  await server.listen();
  server.printUrls();
}
