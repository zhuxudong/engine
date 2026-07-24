import { defineConfig } from "@playwright/test";
import os from "node:os";
import path from "node:path";

const examplesRoot = path.resolve(__dirname, "../..");
const configuredUrl = process.env.WEBGPU_BENCHMARK_E2E_URL;
const baseUrl = new URL(configuredUrl ?? "http://127.0.0.1:5176");
const port = baseUrl.port || (baseUrl.protocol === "https:" ? "443" : "80");

export default defineConfig({
  testDir: ".",
  testMatch: "benchmark.spec.ts",
  fullyParallel: false,
  workers: 1,
  timeout: 120_000,
  expect: { timeout: 30_000 },
  reporter: "list",
  outputDir:
    process.env.WEBGPU_BENCHMARK_E2E_OUTPUT ??
    path.join(os.tmpdir(), "galacean-webgpu-benchmark-e2e"),
  preserveOutput: "always",
  use: {
    baseURL: baseUrl.origin,
    viewport: { width: 1024, height: 576 },
    launchOptions: {
      args: [
        "--enable-unsafe-webgpu",
        ...(process.platform === "darwin" ? ["--use-angle=metal"] : [])
      ]
    },
    trace: "retain-on-failure",
    screenshot: "only-on-failure"
  },
  webServer: configuredUrl
    ? undefined
    : {
        command: `pnpm exec vite serve . --config vite.config.js --host ${baseUrl.hostname} --port ${port}`,
        cwd: examplesRoot,
        url: baseUrl.origin,
        reuseExistingServer: !process.env.CI,
        timeout: 120_000
      }
});
