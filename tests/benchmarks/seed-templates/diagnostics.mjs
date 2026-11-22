import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { pathToFileURL } from "node:url";

// Serialized into the page only when UPLOAD_SOURCES=1. Hooks live for one inspection frame.
export function captureTransfers(gl, update) {
  const rows = new Map(),
    undo = [];
  const oldLimit = Error.stackTraceLimit;
  Error.stackTraceLimit = 15;
  const normalize = (line) =>
    line
      .trim()
      .replace(/^at /, "")
      .replace(/https?:\/\/[^\s()]+?\/(?:@fs\/[^\s()]*?\/)?(packages\/|world\/)/g, "$1")
      .replace(/https?:\/\/[^/\s()]+\//g, "")
      .replace(/\?[^\s():]+(?=:\d+|\))/g, "");
  function hook(owner, method, describe) {
    const descriptor = Object.getOwnPropertyDescriptor(owner, method),
      original = owner[method];
    if (typeof original !== "function") return;
    function attributed(...args) {
      const [kind, bytes] = describe(args);
      const error = {};
      Error.captureStackTrace(error, attributed);
      const stack = error.stack.split("\n").slice(1).map(normalize).slice(0, 8);
      const key = [method, kind, ...stack].join("\n");
      let row = rows.get(key);
      if (!row) {
        row = { method, kind, calls: 0, bytes: 0, min: Infinity, max: 0, stack };
        rows.set(key, row);
      }
      ++row.calls;
      row.bytes += bytes;
      row.min = Math.min(row.min, bytes);
      row.max = Math.max(row.max, bytes);
      return original.apply(this, args);
    }
    Object.defineProperty(owner, method, { value: attributed, configurable: true, writable: true });
    undo.push(() => (descriptor ? Object.defineProperty(owner, method, descriptor) : delete owner[method]));
  }
  function sourceBytes(data, offset = 0, count) {
    const unit = data.BYTES_PER_ELEMENT ?? 1;
    return count === undefined ? data.byteLength - offset * unit : count * unit;
  }
  try {
    if (gl) {
      const targets = new Map(
        [
          "ARRAY_BUFFER",
          "ELEMENT_ARRAY_BUFFER",
          "UNIFORM_BUFFER",
          "TRANSFORM_FEEDBACK_BUFFER",
          "PIXEL_PACK_BUFFER",
          "PIXEL_UNPACK_BUFFER",
          "COPY_READ_BUFFER",
          "COPY_WRITE_BUFFER"
        ].map((k) => [gl[k], k])
      );
      hook(gl, "bufferSubData", ([t, , data, offset, length]) => [
        targets.get(t) ?? String(t),
        sourceBytes(data, offset, length || undefined)
      ]);
      hook(gl, "bufferData", ([t, data, , offset, length]) => [
        typeof data === "number" ? "allocate " + targets.get(t) : targets.get(t),
        typeof data === "number" ? data : data ? sourceBytes(data, offset, length || undefined) : 0
      ]);
      for (const base of ["f", "i", "ui"]) {
        for (let n = 1; n <= 4; ++n) {
          const method = "uniform" + n + base;
          hook(gl, method, () => ["uniform", n * 4]);
          hook(gl, method + "v", ([, data, offset = 0, count]) => ["uniform", (count || data.length - offset) * 4]);
        }
      }
      for (let cols = 2; cols <= 4; ++cols) {
        for (let rows = 2; rows <= 4; ++rows) {
          const shape = cols === rows ? cols : cols + "x" + rows;
          hook(gl, "uniformMatrix" + shape + "fv", ([, , data, offset = 0, count]) => [
            "uniform",
            (count || data.length - offset) * 4
          ]);
        }
      }
    } else {
      const usage = (buffer) =>
        ["UNIFORM", "VERTEX", "INDEX", "STORAGE"].find((k) => buffer.usage & GPUBufferUsage[k]) ?? "other";
      hook(GPUQueue.prototype, "writeBuffer", ([b, , data, offset, count]) => [
        usage(b),
        sourceBytes(data, offset, count)
      ]);
      hook(GPUCommandEncoder.prototype, "clearBuffer", ([b, offset = 0, count]) => [
        usage(b),
        count ?? b.size - offset
      ]);
    }
    update();
  } finally {
    for (const restore of undo.reverse()) restore();
    Error.stackTraceLimit = oldLimit;
  }
  return [...rows.values()].sort((a, b) => b.bytes - a.bytes);
}

export async function attachCpuProfiler(page, directory, id) {
  const client = await page.context().newCDPSession(page);
  const intervals = [],
    sampleIntervalMicros = 500;
  let start;
  await client.send("Profiler.enable");
  await client.send("Profiler.setSamplingInterval", { interval: sampleIntervalMicros });
  await mkdir(path.join(directory, "profiles"), { recursive: true });
  await page.exposeFunction("__seedProfileCpu", async (phase, frame) => {
    if (phase === "start" && start === undefined) {
      await client.send("Profiler.start");
      start = frame;
    } else if (phase === "stop" && start !== undefined) {
      const { profile } = await client.send("Profiler.stop");
      const file = path.join("profiles", id + "-" + start + "-" + frame + ".cpuprofile");
      await writeFile(path.join(directory, file), JSON.stringify(profile));
      intervals.push({ firstFrame: start, lastFrame: frame, sampleCount: profile.samples.length, file });
      start = undefined;
    } else throw Error("Unexpected profiler transition: " + phase + " at frame " + frame);
  });
  return {
    describe: () => ({ sampleIntervalMicros, intervals }),
    close: () => client.detach()
  };
}

function aggregate(list, key, time, count) {
  const sums = new Map();
  for (const row of list) {
    const name = key(row);
    const sum = sums.get(name) ?? { name, value: 0, calls: 0 };
    sum.value += time(row);
    sum.calls += count(row);
    sums.set(name, sum);
  }
  return [...sums.values()].sort((a, b) => b.value - a.value);
}

function cpuRows(profile) {
  const nodes = new Map(profile.nodes.map((n) => [n.id, n])),
    parents = new Map();
  for (const n of profile.nodes) for (const child of n.children ?? []) parents.set(child, n.id);
  const times = new Map();
  for (let i = 0; i < profile.samples.length; ++i) {
    const id = profile.samples[i],
      micros = profile.timeDeltas[i];
    times.set(id, (times.get(id) ?? 0) + micros / 1000);
  }
  const out = [];
  for (const [id, ms] of times) {
    const stack = [];
    for (let current = id; current; current = parents.get(current)) {
      const { functionName, url, lineNumber } = nodes.get(current).callFrame;
      const source = url?.split("?")[0] ?? "";
      const file = /(?:^|\/)(packages\/.*|world\/.*)/.exec(source)?.[1] ?? source.split("/").pop();
      stack.push((functionName || "(anonymous)") + (file ? " (" + file + ":" + (lineNumber + 1) + ")" : ""));
    }
    out.push({ ms, stack });
  }
  return out;
}

export async function summarizeVisits(directory) {
  const results = [];
  for (const name of (await readdir(directory)).sort()) {
    if (!/-(webgl2|webgpu)-cpu\.json$/.test(name)) continue;
    const data = JSON.parse(await readFile(path.join(directory, name), "utf8"));
    if (!data.cpuProfile && !data.inspections.some((i) => i.transfers)) continue;
    const cpu = [];
    for (const { file } of data.cpuProfile?.intervals ?? []) {
      cpu.push(...cpuRows(JSON.parse(await readFile(path.join(directory, file), "utf8"))));
    }
    const transfers = data.inspections
      .filter((i) => i.transfers)
      .map((i) => ({
        frame: i.frame,
        methods: aggregate(
          i.transfers,
          (r) => r.method + " " + r.kind,
          (r) => r.bytes,
          (r) => r.calls
        ),
        stacks: i.transfers
      }));
    const active = cpu.filter((r) => !/^\((idle|root|program)\)$/.test(r.stack[0]));
    const top = (rows, depth) =>
      aggregate(
        rows,
        (r) => r.stack.slice(0, depth).join(" ← "),
        (r) => r.ms,
        () => 0
      ).slice(0, 45);
    results.push({
      name,
      cpuUpdateMs: data.cpuUpdateMs,
      transfers,
      validation: data.validation,
      errors: data.errors,
      webglErrors: data.webglErrors,
      cpuProfile: data.cpuProfile ?? null,
      profiledMs: cpu.reduce((s, r) => s + r.ms, 0),
      activeMs: active.reduce((s, r) => s + r.ms, 0),
      self: top(active, 1),
      stacks: top(active, 6)
    });
  }
  if (!results.length) throw Error("No profiled or transfer-instrumented CPU visits in " + directory);
  await writeFile(path.join(directory, "diagnostics-summary.json"), JSON.stringify(results, null, 2));
  return results;
}

if (process.argv[1] && pathToFileURL(path.resolve(process.argv[1])).href === import.meta.url) {
  const results = await summarizeVisits(path.resolve(process.argv[2]));
  for (const visit of results) {
    console.log(visit.name, "profile ms", visit.activeMs.toFixed(1), "/", visit.profiledMs.toFixed(1));
    for (const inspection of visit.transfers) {
      console.log("frame", inspection.frame, inspection.methods.map((x) => x.name + "=" + x.value + "B").join(", "));
    }
  }
}
