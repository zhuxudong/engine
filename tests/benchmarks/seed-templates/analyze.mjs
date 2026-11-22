import { createHash } from "node:crypto";
import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { chromium } from "@playwright/test";
import { compareImages, withinTolerance } from "../backend-parity/compare.mjs";

const [referenceDirectory, candidateDirectory, outputDirectory, ...flags] = process.argv.slice(2);
if (!outputDirectory)
  throw Error("Pass reference, candidate and output directories, followed by optional --key=value flags.");
const options = new Map(
  flags.map((flag) => {
    const match = /^--(reference-backend|candidate-backend|repeat-reference|repeat-candidate)=(.+)$/.exec(flag);
    if (!match) throw Error("Unknown analysis option: " + flag);
    return [match[1], match[2]];
  })
);
const output = path.resolve(outputDirectory);
const digest = (value) => createHash("sha256").update(JSON.stringify(value)).digest("hex");
const num = (value) => (Number.isFinite(value) ? value.toFixed(2) : "—");
const ratio = (value, baseline) => (Number.isFinite(value) && baseline > 0 ? (value / baseline - 1) * 100 : null);
const percent = (value) => (value == null ? "—" : (value > 0 ? "+" : "") + value.toFixed(1) + "%");
const timings = (data) => (data ? num(data.median) + " / " + num(data.p90) : "—");
const fit = (value) => (Number.isFinite(value) ? Number(value.toFixed(4)) : value);
const relativeLink = (file) => file && path.relative(output, file).split(path.sep).map(encodeURIComponent).join("/");

async function loadDirectory(directory, backend) {
  const runs = new Map();
  for (const file of await readdir(directory)) {
    const match = /^(.+?)-(full|(?:no|with)-[a-z0-9-]+)-(webgl2|webgpu)-(cpu|gpu)(-error)?\.json$/.exec(file);
    if (!match || match[3] !== backend) continue;
    const [, template, variant, , mode, failed] = match;
    const id = template + "/" + variant;
    const pair = runs.get(id) ?? { template, variant };
    const json = path.resolve(directory, file);
    const record = JSON.parse(await readFile(json, "utf8"));
    if (failed) (pair.failures ??= []).push({ mode, file: json, error: record.error, errors: record.errors });
    else {
      if (
        record.template !== template ||
        record.variant !== variant ||
        record.mode !== mode ||
        record.backend !== backend
      )
        throw Error("Result identity disagrees with its file name: " + json);
      pair[mode] = record;
      if (mode === "cpu") pair.imageFile = json.replace(/\.json$/, ".png");
    }
    runs.set(id, pair);
  }
  return runs;
}

function signature(record) {
  if (!record) return null;
  const pathHash = digest(record.path.map((p) => [p.position, p.rotation]));
  const poseHash = digest(
    record.usedPath.map((p) => [
      p.frame,
      p.position.map(fit),
      p.rotation.map((a) => fit(((((a + 180) % 360) + 360) % 360) - 180))
    ])
  );
  return {
    template: record.template,
    variant: record.variant,
    seed: record.seed,
    width: record.width,
    height: record.height,
    frames: record.frames,
    warmup: record.warmup,
    simulationEpoch: record.simulationEpoch,
    fixedDeltaSeconds: record.fixedDeltaSeconds,
    browser: record.browser,
    pathHash,
    poseHash
  };
}

function differences(a, b, { variantMustMatch = true } = {}) {
  if (!a || !b) return ["missing run"];
  return Object.keys(a).filter((k) => (k !== "variant" || variantMustMatch) && a[k] !== b[k]);
}

function summarize(pair) {
  if (!pair) return null;
  const cpu = pair.cpu,
    gpu = pair.gpu,
    record = cpu ?? gpu;
  const errors = [...(pair.failures ?? []).map((f) => f.error), ...(cpu?.errors ?? []), ...(gpu?.errors ?? [])];
  for (const visit of [cpu, gpu]) {
    if (visit?.webglErrors?.length) errors.push("WebGL error codes " + visit.webglErrors.join(", "));
    if (visit?.validation?.count)
      errors.push(visit.validation.count + " GPU validation errors: " + visit.validation.messages.join(", "));
  }
  if (!record) return { errors, missing: ["cpu", "gpu"] };
  const missing = ["cpu", "gpu"].filter((mode) => !pair[mode]);
  if (gpu && (!gpu.gpuSource || !gpu.gpuMs?.samples)) missing.push("native GPU timing");
  const inspections = record.inspections.map((s) => ({
    frame: s.frame,
    drawCalls: s.drawCalls,
    direct: s.direct,
    bundleDraws: s.bundleDraws,
    population: s.population,
    naturalMeshParts: s.naturalVegetationMeshParts ?? null,
    occludedRenderers: s.horizon.occludedRendererCount,
    testedRenderers: s.horizon.testedRendererCount,
    exactOccluded: s.exactInstances.terrainOccludedInstanceCount,
    exactCandidates: s.exactInstances.candidateInstanceCount,
    rockCells: s.rockCells ?? null,
    horizon: s.horizon.horizonBuildMode,
    shaderPassDraws: s.shaderPassDraws ?? {},
    nativePasses: s.nativePasses ?? null,
    bufferOps: s.bufferOps ?? null
  }));
  const passNames = new Set(inspections.flatMap((s) => Object.keys(s.shaderPassDraws)));
  const shaderPassDraws = Object.fromEntries(
    [...passNames].sort().map((name) => [name, inspections.map((s) => s.shaderPassDraws[name] ?? 0)])
  );
  const gpuPasses = new Map();
  for (const sample of gpu?.gpuSamples ?? []) {
    // Keep repeated passes (e.g. the Bloom chain) together within each sampled GPU frame.
    const frame = new Map();
    for (const pass of sample.passes ?? []) frame.set(pass.name, (frame.get(pass.name) ?? 0) + pass.milliseconds);
    for (const [name, value] of frame) {
      const values = gpuPasses.get(name) ?? [];
      values.push(value);
      gpuPasses.set(name, values);
    }
  }
  const gpuPassTiming = Object.fromEntries(
    [...gpuPasses].map(([name, values]) => {
      values.sort((a, b) => a - b);
      return [
        name,
        {
          frames: values.length,
          median: values[Math.ceil(values.length / 2) - 1],
          p90: values[Math.ceil(values.length * 0.9) - 1]
        }
      ];
    })
  );
  return {
    backend: record.backend,
    errors,
    missing,
    identity: signature(record),
    cpuGpuIdentityDifferences: cpu && gpu ? differences(signature(cpu), signature(gpu)) : null,
    before: record.before,
    effects: record.effects,
    cpu: cpu?.cpuUpdateMs ?? null,
    frameInterval: cpu?.frameIntervalMs ?? null,
    gpu: gpu?.gpuMs ?? null,
    gpuSource: gpu?.gpuSource ?? null,
    gpuTimingDiagnostics: gpu?.gpuTimingDiagnostics ?? null,
    cpuHash: cpu?.hash ?? null,
    gpuHash: gpu?.hash ?? null,
    inspections,
    shaderPassDraws,
    gpuPassTiming,
    imageFile: cpu ? pair.imageFile : null
  };
}

// Comparing RGB alone can hide a featureless image with similar overall exposure. Sum local
// SSIM over 8x8 luminance windows, report spatial variation, and verify every saved image's RGBA hash.
async function imageDetails(images) {
  const decoded = [];
  for (const base64 of images) {
    const bitmap = await createImageBitmap(await (await fetch("data:image/png;base64," + base64)).blob());
    const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
    const ctx = canvas.getContext("2d", { willReadFrequently: true });
    ctx.drawImage(bitmap, 0, 0);
    bitmap.close();
    const bytes = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    const rgbMin = [255, 255, 255],
      rgbMax = [0, 0, 0],
      luma = new Float32Array(bytes.length / 4);
    const histogram = new Uint32Array(4096);
    let hash = 2166136261,
      transparent = 0;
    for (let i = 0; i < bytes.length; i += 4) {
      for (let c = 0; c < 4; c++) {
        hash = Math.imul(hash ^ bytes[i + c], 16777619);
        if (c < 3) {
          rgbMin[c] = Math.min(rgbMin[c], bytes[i + c]);
          rgbMax[c] = Math.max(rgbMax[c], bytes[i + c]);
        }
      }
      if (!bytes[i + 3]) transparent++;
      histogram[(bytes[i] >> 4) * 256 + (bytes[i + 1] >> 4) * 16 + (bytes[i + 2] >> 4)]++;
      luma[i / 4] = 0.2126 * bytes[i] + 0.7152 * bytes[i + 1] + 0.0722 * bytes[i + 2];
    }
    decoded.push({
      luma,
      width: canvas.width,
      height: canvas.height,
      stats: {
        hash: (hash >>> 0).toString(16).padStart(8, "0"),
        rgbMin,
        rgbMax,
        dominantColorBinFraction: Math.max(...histogram) / luma.length,
        transparentFraction: transparent / luma.length,
        uniform: rgbMin.every((v, c) => v === rgbMax[c])
      }
    });
  }
  const [a, b] = decoded;
  if (a.width !== b.width || a.height !== b.height) throw Error("PNG dimensions differ");
  let total = 0,
    count = 0;
  for (let y = 0; y < a.height; y += 8)
    for (let x = 0; x < a.width; x += 8) {
      let n = 0,
        sx = 0,
        sy = 0,
        xx = 0,
        yy = 0,
        xy = 0;
      for (let dy = y; dy < Math.min(y + 8, a.height); dy++)
        for (let dx = x; dx < Math.min(x + 8, a.width); dx++) {
          const k = dy * a.width + dx,
            u = a.luma[k],
            v = b.luma[k];
          n++;
          sx += u;
          sy += v;
          xx += u * u;
          yy += v * v;
          xy += u * v;
        }
      const ax = sx / n,
        ay = sy / n;
      const vx = xx / n - ax * ax,
        vy = yy / n - ay * ay,
        cov = xy / n - ax * ay;
      total +=
        (((2 * ax * ay + 6.5025) * (2 * cov + 58.5225)) / ((ax * ax + ay * ay + 6.5025) * (vx + vy + 58.5225))) * n;
      count += n;
    }
  return { width: a.width, height: a.height, localLumaSSIM: total / count, reference: a.stats, candidate: b.stats };
}

let browser, page;
async function compare(a, b) {
  if (!a?.imageFile || !b?.imageFile) return null;
  try {
    const input = await Promise.all([a, b].map(async (x) => (await readFile(x.imageFile)).toString("base64")));
    if (!browser) {
      browser = await chromium.launch({ args: ["--disable-gpu"] });
      page = await browser.newPage();
    }
    const delta = await page.evaluate(compareImages, input);
    const details = await page.evaluate(imageDetails, input);
    const checksumsMatch = details.reference.hash === a.cpuHash && details.candidate.hash === b.cpuHash;
    const blank =
      details.reference.uniform ||
      details.candidate.uniform ||
      details.reference.transparentFraction === 1 ||
      details.candidate.transparentFraction === 1;
    const suspect =
      details.reference.dominantColorBinFraction > 0.995 || details.candidate.dominantColorBinFraction > 0.995;
    return {
      ...delta,
      ...details,
      checksumsMatch,
      status: !checksumsMatch
        ? "capture hash mismatch"
        : blank
          ? "empty or uniform"
          : suspect
            ? "near-uniform"
            : delta.maxRGB === 0
              ? "identical"
              : withinTolerance(delta)
                ? "within gallery tolerance"
                : "outside gallery tolerance"
    };
  } catch (error) {
    return { status: "unavailable", error: String(error) };
  }
}

function work(record) {
  if (!record?.inspections) return null;
  const frames = record.inspections,
    fromPass = (rx) =>
      frames.map((f) => Object.entries(f.shaderPassDraws).reduce((sum, [name, n]) => sum + (rx.test(name) ? n : 0), 0));
  return {
    drawCalls: frames.map((f) => f.drawCalls),
    grass: frames.map((f) => f.population.grass),
    natural: frames.map((f) => f.naturalMeshParts?.records ?? null),
    tree: frames.map((f) => f.population.tree),
    shrub: frames.map((f) => f.population.shrub),
    flower: frames.map((f) => f.population.flower),
    horizon: frames.map((f) => f.horizon),
    tested: frames.map((f) => f.testedRenderers),
    culled: frames.map((f) => f.occludedRenderers),
    exactOccluded: frames.map((f) => f.exactOccluded),
    rockTestedInstances: frames.map((f) => f.rockCells?.terrainOcclusionTestedInstanceCount ?? null),
    rockOccludedCells: frames.map((f) => f.rockCells?.terrainOccludedCellCount ?? null),
    rockOccludedInstances: frames.map((f) => f.rockCells?.terrainOccludedInstanceCount ?? null),
    rockCandidates: frames.map((f) => f.rockCells?.candidateInstanceCount ?? null),
    ssr: fromPass(/SSR|HiZTrace|TemporalResolve|BuildHiZMip|ScreenSpaceReflect/i),
    bloom: fromPass(/^Bloom /i)
  };
}

function change(summary, full) {
  if (!summary?.identity || !full?.identity) return null;
  const incompatible = differences(summary.identity, full.identity, { variantMustMatch: false });
  if (incompatible.length) return { incompatible };
  const timerChanged = summary.gpuSource !== full.gpuSource;
  const comparableGpu = !!summary.gpuSource && !timerChanged && summary.backend === full.backend;
  return {
    cpuMedian: ratio(summary.cpu?.median, full.cpu?.median),
    cpuP90: ratio(summary.cpu?.p90, full.cpu?.p90),
    gpuMedian: comparableGpu ? ratio(summary.gpu?.median, full.gpu?.median) : null,
    gpuP90: comparableGpu ? ratio(summary.gpu?.p90, full.gpu?.p90) : null,
    timerChanged
  };
}

const referenceBackend = options.get("reference-backend") ?? "webgl2",
  candidateBackend = options.get("candidate-backend") ?? "webgpu";
const [reference, candidate, repeatReference, repeatCandidate] = await Promise.all([
  loadDirectory(referenceDirectory, referenceBackend),
  loadDirectory(candidateDirectory, candidateBackend),
  options.has("repeat-reference") ? loadDirectory(options.get("repeat-reference"), referenceBackend) : null,
  options.has("repeat-candidate") ? loadDirectory(options.get("repeat-candidate"), candidateBackend) : null
]);
const ids = [...new Set([...reference.keys(), ...candidate.keys()])].sort((a, b) => {
  const [at, av] = a.split("/"),
    [bt, bv] = b.split("/");
  return at.localeCompare(bt) || (av === "full" ? -1 : bv === "full" ? 1 : av.localeCompare(bv));
});
if (!ids.length) throw Error("No Seed measurements found in the selected directories.");
const rows = [];
try {
  for (const id of ids) {
    const [template, variant] = id.split("/");
    const a = summarize(reference.get(id)),
      b = summarize(candidate.get(id));
    const incompatible = differences(a?.identity, b?.identity);
    const images = await compare(a, b);
    const checks = incompatible.length
      ? "unmatched inputs"
      : [a, b].some((s) => s.errors.length || s.missing.length || s.cpuGpuIdentityDifferences?.length)
        ? "incomplete or errored"
        : ["identical", "within gallery tolerance"].includes(images?.status)
          ? "inputs and gallery image check matched"
          : "diagnostic only: " + (images?.status ?? "missing captures");
    const repeat = async (primary, map) => {
      if (!primary || !map?.has(id)) return null;
      const extra = summarize(map.get(id));
      return {
        identityDifferences: differences(primary.identity, extra.identity),
        cpu: extra.cpu,
        gpu: extra.gpu,
        gpuSource: extra.gpuSource,
        errors: extra.errors,
        missing: extra.missing,
        cpuGpuIdentityDifferences: extra.cpuGpuIdentityDifferences,
        vsPrimary: change(extra, primary),
        image: await compare(primary, extra)
      };
    };
    const fullA = summarize(reference.get(template + "/full")),
      fullB = summarize(candidate.get(template + "/full"));
    rows.push({
      template,
      variant,
      reference: a,
      candidate: b,
      referenceWork: work(a),
      candidateWork: work(b),
      incompatible,
      checks,
      referenceVsFull: change(a, fullA),
      candidateVsFull: change(b, fullB),
      candidateVsReference: incompatible.length ? null : change(b, a),
      images,
      horizonImages:
        variant === "no-occlusion" ? { reference: await compare(fullA, a), candidate: await compare(fullB, b) } : null,
      repeatReference: await repeat(a, repeatReference),
      repeatCandidate: await repeat(b, repeatCandidate)
    });
  }
} finally {
  await browser?.close();
}

const report = [
  "# Seed template benchmark",
  "",
  "Durations are milliseconds. CPU times cover engine update. Separate visits collect diagnostic API GPU timings. WebGL2 uses its elapsed query. The default WebGPU timer spans the beginning of the first submitted native pass to the end of the last submitted native pass. The span can include gaps between passes and submissions. Each GPU row identifies its timer in gpuSource. Within-backend GPU percentages require the same timer. Direct cross-backend GPU comparisons use matched Metal System Trace active intervals. Workload triplets show the start, midpoint and end of the camera path.",
  ""
];
const triplet = (v) => (v ? v.map((n) => n ?? "—").join(" / ") : "—");
for (const template of new Set(rows.map((x) => x.template))) {
  const selected = rows.filter((x) => x.template === template);
  report.push(
    "## " + template,
    "",
    "| Backend | Variant | CPU median / P90 | API GPU median / P90 | CPU median vs full | API GPU median vs full | Native draws |",
    "| --- | --- | ---: | ---: | ---: | ---: | --- |"
  );
  for (const row of selected)
    for (const side of ["reference", "candidate"]) {
      const s = row[side],
        delta = row[side + "VsFull"];
      report.push(
        "| " +
          [
            side + " (" + (side === "reference" ? referenceBackend : candidateBackend) + ")",
            row.variant,
            timings(s?.cpu),
            timings(s?.gpu),
            row.variant === "full" ? "—" : percent(delta?.cpuMedian),
            row.variant === "full" ? "—" : percent(delta?.gpuMedian),
            triplet(row[side + "Work"]?.drawCalls)
          ].join(" | ") +
          " |"
      );
    }
  report.push(
    "",
    "| Candidate relative to reference | CPU median | CPU P90 | GPU median | GPU P90 | Comparison checks |",
    "| --- | ---: | ---: | ---: | ---: | --- |"
  );
  for (const row of selected) {
    const dx = row.candidateVsReference;
    report.push(
      "| " +
        [
          row.variant,
          percent(dx?.cpuMedian),
          percent(dx?.cpuP90),
          percent(dx?.gpuMedian),
          percent(dx?.gpuP90),
          row.checks
        ].join(" | ") +
        " |"
    );
  }
  report.push(
    "",
    "| Backend | Variant | Grass instances | Natural vegetation mesh-part records | Population horizon-culled renderers | SSR draws | Bloom draws |",
    "| --- | --- | --- | --- | --- | --- | --- |"
  );
  for (const row of selected)
    for (const side of ["reference", "candidate"]) {
      const w = row[side + "Work"];
      report.push(
        "| " +
          [
            side,
            row.variant,
            triplet(w?.grass),
            triplet(w?.natural),
            triplet(w?.culled),
            triplet(w?.ssr),
            triplet(w?.bloom)
          ].join(" | ") +
          " |"
      );
    }
  report.push(
    "",
    "| Terrain horizon | Variant | Rock instances tested | Rock cells rejected | Rock instances rejected | Rock candidates kept | Exact-prefab instances rejected | Final image vs horizon enabled |",
    "| --- | --- | --- | --- | --- | --- | --- | --- |"
  );
  for (const row of selected.filter((r) => r.variant === "full" || r.variant === "no-occlusion")) {
    for (const side of ["reference", "candidate"]) {
      const w = row[side + "Work"],
        image = row.horizonImages?.[side];
      report.push(
        "| " +
          [
            side,
            row.variant,
            triplet(w?.rockTestedInstances),
            triplet(w?.rockOccludedCells),
            triplet(w?.rockOccludedInstances),
            triplet(w?.rockCandidates),
            triplet(w?.exactOccluded),
            image
              ? image.status + (Number.isFinite(image.localLumaSSIM) ? " (SSIM " + num(image.localLumaSSIM) + ")" : "")
              : "—"
          ].join(" | ") +
          " |"
      );
    }
  }
  const repeated = selected.filter((r) => r.repeatReference || r.repeatCandidate);
  if (repeated.length) {
    report.push(
      "",
      "| Repeat vs primary | Variant | Repeat CPU median / P90 | Median change | Repeat GPU median / P90 | Median change | Consistency |",
      "| --- | --- | ---: | ---: | ---: | ---: | --- |"
    );
    for (const row of repeated) {
      for (const [side, r] of [
        ["reference", row.repeatReference],
        ["candidate", row.repeatCandidate]
      ]) {
        if (!r) continue;
        const checks = [
          ...r.identityDifferences,
          ...(r.cpuGpuIdentityDifferences ?? []),
          ...r.missing.map((s) => "missing " + s),
          ...(r.errors.length ? ["run errors"] : []),
          ...(r.vsPrimary?.timerChanged ? ["GPU timer changed"] : [])
        ];
        report.push(
          "| " +
            [
              side,
              row.variant,
              timings(r.cpu),
              percent(r.vsPrimary?.cpuMedian),
              timings(r.gpu),
              percent(r.vsPrimary?.gpuMedian),
              checks.join(", ") || "matched"
            ].join(" | ") +
            " |"
        );
      }
    }
  }
  report.push(
    "",
    "| Variant | Input path SHA-256 (first 12) | Paired input and checks | Final images | Mean RGB error / 255 | Pixels over 20 | Luma SSIM |",
    "| --- | --- | --- | --- | ---: | ---: | ---: |"
  );
  for (const row of selected) {
    const image = row.images;
    const reasons = [...row.incompatible];
    for (const side of ["reference", "candidate"]) {
      const s = row[side];
      if (!s) continue;
      reasons.push(
        ...s.missing.map((k) => side + " missing " + k),
        ...s.errors.slice(0, 1).map(() => side + " validation/run error"),
        ...(s.cpuGpuIdentityDifferences ?? []).map((k) => side + " CPU/GPU differ in " + k)
      );
    }
    const links = ["reference", "candidate"]
      .filter((k) => row[k]?.imageFile)
      .map((k) => "[" + k + "](" + relativeLink(row[k].imageFile) + ")");
    const hash = (s) => s?.identity?.pathHash.slice(0, 12) ?? "—";
    report.push(
      "| " +
        [
          row.variant,
          hash(row.reference) + " / " + hash(row.candidate),
          reasons.join(", ") || "matched",
          (image?.status ?? "unpaired") + " " + links.join(" "),
          num(image?.meanRGB),
          image?.changedFraction == null ? "—" : (image.changedFraction * 100).toFixed(1) + "%",
          num(image?.localLumaSSIM)
        ].join(" | ") +
        " |"
    );
    for (const side of ["repeatReference", "repeatCandidate"])
      if (row[side]) {
        const r = row[side],
          im = r.image;
        report.push(
          "| " +
            [
              row.variant + " " + side,
              "—",
              r.identityDifferences.join(", ") || "matched",
              im?.status ?? "unpaired",
              num(im?.meanRGB),
              im?.changedFraction == null ? "—" : (im.changedFraction * 100).toFixed(1) + "%",
              num(im?.localLumaSSIM)
            ].join(" | ") +
            " |"
        );
      }
  }
  report.push("");
}
report.push(
  "Each saved PNG is checked against its captured RGBA hash. The gallery image threshold requires mean RGB error ≤3 and at most 2.5% of pixels with a channel error above 20. SSIM uses an 8 × 8 luminance window. A near-uniform flag means over 99.5% of pixels share one 4-bit-per-channel color bin. The JSON includes measured camera poses rounded to 0.0001 in their verification hash, timing sample counts, effective switches, per-pass draws, native GPU pass durations where available, and validation errors.",
  "",
  "Grass is a subset of the vegetation ablation. The terrain-occlusion experiment disables Seed’s terrain horizon and leaves frustum culling and LOD active. Repeated world visits may differ due to time-budgeted streaming. A cross-backend time difference with mismatched inputs, validation errors or substantially different images is diagnostic.",
  ""
);
await mkdir(output, { recursive: true });
await writeFile(
  path.join(output, "summary.json"),
  JSON.stringify({ referenceBackend, candidateBackend, rows }, null, 2) + "\n"
);
await writeFile(path.join(output, "report.md"), report.join("\n"));
console.log(rows.length + " template/variant pairs written to " + output);
