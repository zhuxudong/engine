// Browser-side instrumentation for the published Seed world. Install before creating the engine.
const stateKey = Symbol.for("galacean.seed.benchmark.metrics");
const frame = () => new Promise(requestAnimationFrame);
const drawNames = ["draw", "drawIndexed", "drawIndirect", "drawIndexedIndirect"];

function replace(owner, name, value) {
  const previous = Object.getOwnPropertyDescriptor(owner, name);
  Object.defineProperty(owner, name, { configurable: true, writable: true, value });
  return () => (previous ? Object.defineProperty(owner, name, previous) : delete owner[name]);
}

export function installSeedMetrics() {
  if (globalThis[stateKey]) return;
  const state = (globalThis[stateKey] = { bundles: new WeakMap(), devices: [] });
  if (!globalThis.GPUAdapter) return;
  const request = GPUAdapter.prototype.requestDevice;
  replace(GPUAdapter.prototype, "requestDevice", async function (descriptor = {}) {
    const features = new Set(descriptor.requiredFeatures);
    if (this.features.has("timestamp-query")) features.add("timestamp-query");
    const device = await request.call(this, { ...descriptor, requiredFeatures: Array.from(features) });
    state.devices.push(device);
    return device;
  });
  const proto = GPURenderBundleEncoder.prototype;
  const encoders = new WeakMap();
  for (const name of drawNames) {
    const native = proto[name];
    replace(proto, name, function (...args) {
      encoders.set(this, (encoders.get(this) ?? 0) + 1);
      return native.apply(this, args);
    });
  }
  const finish = proto.finish;
  replace(proto, "finish", function (...args) {
    const bundle = finish.apply(this, args);
    state.bundles.set(bundle, encoders.get(this) ?? 0);
    return bundle;
  });
}

function worldOf(context) {
  const current = context.publication?.current?.world ?? context.readWorld?.();
  const world = current?.world ?? current;
  if (!world?.population) throw Error("Seed has not published its terrain and population.");
  return world;
}

function namedChild(parent, name) {
  const matches = parent.children.filter((entity) => entity.name === name);
  if (matches.length !== 1) throw Error(`Expected one '${name}' under '${parent.name}', found ${matches.length}.`);
  return matches[0];
}

function diagnosticSubtree(context, world, variant) {
  if (variant !== "no-landmark-tree" && variant !== "no-animals") return null;
  let entity, modelFit;
  if (variant === "no-animals") {
    entity = namedChild(context.root, "Seed animals");
  } else {
    const { template } = context.publication.current;
    const id = template?.template?.id;
    const landmark = { "sakura-pearl": "pearl-cherry-tree", "titan-wasteland": "oasis-scarlet-tree" }[id];
    if (!landmark || namedChild(world.root, "World template: " + id) !== template.root)
      throw Error("Expected the published Sakura or Titan template for the landmark-tree diagnostic.");
    entity = namedChild(template.root, landmark);
    modelFit = namedChild(entity, "Model fit");
    if (!modelFit.childCount) throw Error("Landmark tree has no imported model: " + landmark);
  }
  if (!entity.childCount || !entity.isActiveInHierarchy)
    throw Error("Expected a populated, active subtree: " + entity.name);
  const names = [];
  for (let node = entity; node; node = node.parent) names.push(node.name);
  return { entity, path: names.reverse().join("/"), modelFit };
}

function status(context, world, subtree) {
  const pop = world.population;
  const post = context.post.getDebugSnapshot();
  return {
    grass: pop.isDetailCategoryVisible("grass"),
    trees: pop.trees.isActiveInHierarchy,
    details: pop.details.isActiveInHierarchy,
    ssr: "enableScreenSpaceReflection" in context.camera ? context.camera.enableScreenSpaceReflection : null,
    bloom: post.enabled && post.bloom.enabled,
    horizon: world.getTerrainOcclusionDiagnostics().horizonBuildMode,
    ...(subtree && {
      subtree: {
        path: subtree.path,
        active: subtree.entity.isActiveInHierarchy,
        childCount: subtree.entity.childCount,
        ...(subtree.modelFit && { modelSceneRoots: subtree.modelFit.childCount })
      }
    })
  };
}

function ablate(context, world, variant, undo, subtree) {
  const pop = world.population;
  switch (variant) {
    case "full":
      break;
    case "no-landmark-tree":
    case "no-animals": {
      const { entity } = subtree;
      const saved = entity.isActive;
      undo.push(() => {
        entity.isActive = saved;
      });
      entity.isActive = false;
      break;
    }
    case "no-grass": {
      const saved = pop.isDetailCategoryVisible("grass");
      undo.push(() => pop.setDetailCategoryVisible("grass", saved));
      pop.setDetailCategoryVisible("grass", false);
      break;
    }
    case "no-vegetation": {
      // These are the two roots switched by SeedWorldPerfPanel's vegetation control.
      const trees = pop.trees.isActive,
        details = pop.details.isActive;
      undo.push(() => {
        pop.trees.isActive = trees;
        pop.details.isActive = details;
      });
      pop.trees.isActive = false;
      pop.details.isActive = false;
      break;
    }
    case "no-occlusion": {
      const culler = world.terrainOcclusion;
      const invalidate = () => {
        culler.invalidate();
        pop.invalidateTerrainOcclusionVisibility();
        world.exactInstanceCells.invalidate();
      };
      invalidate();
      undo.push(invalidate);
      // beginFrame normally clears this one-frame signal. A stale publication flag would
      // invalidate all population visibility every frame throughout the disabled run.
      undo.push(replace(culler, "horizonPublishedThisFrame", false));
      // The publication shares this instance with population, exact-prefab and water consumers.
      // Invalidate their retained decisions, then suppress the horizon builder and only its rejection tests.
      for (const name of [
        "beginFrame",
        "isOccluded",
        "isSubCellOccluded",
        "isBoundsOccluded",
        "isWaterBoundsOccluded"
      ]) {
        if (typeof culler[name] !== "function") throw Error("Unexpected terrain horizon API: " + name);
        undo.push(replace(culler, name, name === "beginFrame" ? () => {} : () => false));
      }
      break;
    }
    case "with-ssr":
    case "no-ssr": {
      if (!("enableScreenSpaceReflection" in context.camera)) throw Error("Camera has no native SSR control.");
      const saved = context.camera.enableScreenSpaceReflection;
      undo.push(() => {
        context.camera.enableScreenSpaceReflection = saved;
      });
      context.camera.enableScreenSpaceReflection = variant === "with-ssr";
      break;
    }
    case "with-bloom":
    case "no-bloom": {
      const saved = context.post.getDebugSnapshot().bloom.enabled;
      undo.push(() => context.post.setBloomEnabled(saved));
      context.post.setBloomEnabled(variant === "with-bloom");
      break;
    }
    default:
      throw Error("Unknown Seed variant: " + variant);
  }
}

function triple(v) {
  return [v.x, v.y, v.z];
}

function initialPath(transform) {
  const position = triple(transform.worldPosition),
    rotation = triple(transform.worldRotation);
  const forward = transform.worldForward,
    right = transform.worldRight;
  return [
    [0, 0, 0],
    [10, -2, -10],
    [20, 1, 8],
    [10, 3, 14],
    [0, 0, 0]
  ].map(([ahead, side, yaw]) => ({
    position: [
      position[0] + forward.x * ahead + right.x * side,
      position[1],
      position[2] + forward.z * ahead + right.z * side
    ],
    rotation: [rotation[0], rotation[1] + yaw, rotation[2]]
  }));
}

function applyPath(transform, path, fraction) {
  const offset = fraction * (path.length - 1);
  const index = Math.min(Math.floor(offset), path.length - 2),
    t = offset - index;
  const a = path[index],
    b = path[index + 1];
  const mix = (v, w, axis) => v[axis] + (w[axis] - v[axis]) * t;
  transform.setWorldPosition(
    mix(a.position, b.position, 0),
    mix(a.position, b.position, 1),
    mix(a.position, b.position, 2)
  );
  transform.setWorldRotation(
    mix(a.rotation, b.rotation, 0),
    mix(a.rotation, b.rotation, 1),
    mix(a.rotation, b.rotation, 2)
  );
}

function oneFrameDraws(gl, state, engine, update) {
  let drawCalls = 0,
    bundleDraws = 0,
    unknownBundles = 0;
  const shaderPassDraws = Object.create(null),
    programNames = new WeakMap();
  const undo = [];
  const bufferOps = {};
  const nativePasses = gl ? null : { render: 0, compute: 0, submits: 0, labels: {} };
  const countBytes = (owner, method, bytes) => {
    const native = owner[method];
    const entry = (bufferOps[method] = { calls: 0, bytes: 0 });
    undo.push(
      replace(owner, method, function (...args) {
        ++entry.calls;
        entry.bytes += bytes(...args);
        return native.apply(this, args);
      })
    );
  };
  const sourceBytes = (data, offset = 0, length) => {
    const units = data.BYTES_PER_ELEMENT ?? 1;
    return length === undefined ? data.byteLength - offset * units : length * units;
  };
  try {
    if (gl) {
      const allocate = gl.bufferData;
      const storage = (bufferOps.bufferData = { calls: 0, bytes: 0, sizeOnlyCalls: 0, sizeOnlyBytes: 0 });
      undo.push(
        replace(gl, "bufferData", function (target, data, usage, start, length) {
          ++storage.calls;
          const size = typeof data === "number" ? data : data ? sourceBytes(data, start, length || undefined) : 0;
          storage.bytes += size;
          if (typeof data === "number") {
            ++storage.sizeOnlyCalls;
            storage.sizeOnlyBytes += size;
          }
          return allocate.apply(this, arguments);
        })
      );
      countBytes(gl, "bufferSubData", (_target, _offset, data, start, length) =>
        sourceBytes(data, start, length || undefined)
      );
    } else {
      for (const [name, kind] of [
        ["beginRenderPass", "render"],
        ["beginComputePass", "compute"]
      ]) {
        const proto = GPUCommandEncoder.prototype,
          original = proto[name];
        undo.push(
          replace(proto, name, function (descriptor) {
            nativePasses[kind]++;
            const label = descriptor?.label || kind;
            nativePasses.labels[label] = (nativePasses.labels[label] ?? 0) + 1;
            return original.apply(this, arguments);
          })
        );
      }
      const submit = GPUQueue.prototype.submit;
      undo.push(
        replace(GPUQueue.prototype, "submit", function () {
          nativePasses.submits++;
          return submit.apply(this, arguments);
        })
      );
      countBytes(GPUQueue.prototype, "writeBuffer", (_buffer, _offset, data, start, length) =>
        sourceBytes(data, start, length)
      );
      countBytes(
        GPUCommandEncoder.prototype,
        "clearBuffer",
        (buffer, offset = 0, size) => size ?? buffer.size - offset
      );
      countBytes(GPUCommandEncoder.prototype, "copyBufferToBuffer", (source, offset, dest, _destOffset, size) =>
        typeof offset === "number" ? (size ?? source.size - offset) : (dest ?? source.size)
      );
    }
    const samplePass = engine._basicResources.blitMaterial.shader.subShaders[0].passes[0];
    const passPrototype = Object.getPrototypeOf(samplePass);
    const getProgram = passPrototype._getShaderProgram;
    undo.push(
      replace(passPrototype, "_getShaderProgram", function (...args) {
        const program = getProgram.apply(this, args);
        if (program) programNames.set(program._platformProgram ?? program, this.name);
        return program;
      })
    );
    const renderer = engine._hardwareRenderer,
      draw = renderer.drawPrimitive;
    undo.push(
      replace(renderer, "drawPrimitive", function (primitive, sub, program) {
        const name = programNames.get(program) ?? "(cached program)";
        shaderPassDraws[name] = (shaderPassDraws[name] ?? 0) + 1;
        return draw.apply(this, arguments);
      })
    );
    const owner = gl ?? GPURenderPassEncoder.prototype;
    const names = gl ? ["drawArrays", "drawElements", "drawArraysInstanced", "drawElementsInstanced"] : drawNames;
    for (const name of names) {
      const original = owner[name];
      undo.push(
        replace(owner, name, function (...args) {
          ++drawCalls;
          return original.apply(this, args);
        })
      );
    }
    if (!gl) {
      const execute = owner.executeBundles;
      undo.push(
        replace(owner, "executeBundles", function (bundles) {
          const array = Array.isArray(bundles) ? bundles : Array.from(bundles);
          for (const b of array) {
            if (state.bundles.has(b)) bundleDraws += state.bundles.get(b);
            else ++unknownBundles;
          }
          return execute.call(this, array);
        })
      );
    }
    update();
  } finally {
    for (const restore of undo.reverse()) restore();
  }
  if (unknownBundles) throw Error("A bundle was recorded before installSeedMetrics().");
  if (drawCalls + bundleDraws === 0) throw Error("Inspection frame produced no native draws.");
  return {
    drawCalls: drawCalls + bundleDraws,
    direct: drawCalls,
    bundleDraws,
    shaderPassDraws,
    bufferOps,
    nativePasses
  };
}

function snapshot(context, world) {
  const pop = world.population;
  const { tree, shrub, flower, grass } = pop.submittedCounts;
  const horizon = world.getTerrainOcclusionDiagnostics();
  const published = context.publication?.current;
  // RockLodView owns a separate exact-instance scheduler on the published rock root.
  const rockRoot = published?.solids?.root.findByName("Rock formations");
  const rockCells = rockRoot?._components
    .find((c) => c.terrainOcclusion === world.terrainOcclusion && typeof c.getSnapshot === "function")
    ?.getSnapshot();
  // Published template vegetation has separate renderers underneath the population roots.
  // One logical plant can supply several bark, leaf or understory mesh-part records.
  const natural = published?.vegetation;
  const naturalMeshParts = { batches: 0, records: 0 };
  natural?.visitPickBatches((batch) => {
    ++naturalMeshParts.batches;
    naturalMeshParts.records += batch.count;
  });
  return {
    population: {
      tree: pop.trees.isActiveInHierarchy ? tree : 0,
      shrub: pop.trees.isActiveInHierarchy ? shrub : 0,
      flower: pop.details.isActiveInHierarchy && pop.isDetailCategoryVisible("flower") ? flower : 0,
      grass: pop.details.isActiveInHierarchy && pop.isDetailCategoryVisible("grass") ? grass : 0
    },
    resident: { ...pop.residentAcceptedCounts },
    naturalVegetationMeshParts: natural ? naturalMeshParts : null,
    exactInstances: { ...world.getExactInstanceSpatialSnapshot() },
    rockCells: rockCells ? { ...rockCells } : null,
    horizon: { ...horizon }
  };
}

function pixels(source, image) {
  const canvas = document.createElement("canvas");
  canvas.width = source.width;
  canvas.height = source.height;
  const context = canvas.getContext("2d", { willReadFrequently: true });
  context.drawImage(source, 0, 0);
  const { data } = context.getImageData(0, 0, canvas.width, canvas.height);
  let hash = 2166136261,
    variation = false;
  for (let i = 0; i < data.length; ++i) {
    hash = Math.imul(hash ^ data[i], 16777619);
    if (data[i] !== data[i & 3]) variation = true;
  }
  if (!variation) throw Error("Inspected presentation canvas has a uniform color.");
  return {
    hash: (hash >>> 0).toString(16).padStart(8, "0"),
    ...(image && { png: canvas.toDataURL("image/png").split(",")[1] })
  };
}

function glTimer(gl) {
  const ext = gl.getExtension("EXT_disjoint_timer_query_webgl2");
  if (!ext) return null;
  return {
    source: "EXT_disjoint_timer_query_webgl2",
    async sample(update) {
      const query = gl.createQuery();
      try {
        if (gl.getQuery(ext.TIME_ELAPSED_EXT, gl.CURRENT_QUERY)) throw Error("Another WebGL GPU timer is active.");
        gl.beginQuery(ext.TIME_ELAPSED_EXT, query);
        try {
          update();
        } finally {
          gl.endQuery(ext.TIME_ELAPSED_EXT);
        }
        gl.flush();
        for (let attempt = 0; attempt < 120; ++attempt) {
          if (gl.getParameter(ext.GPU_DISJOINT_EXT)) return null;
          if (gl.getQueryParameter(query, gl.QUERY_RESULT_AVAILABLE))
            return { milliseconds: gl.getQueryParameter(query, gl.QUERY_RESULT) / 1e6 };
          await frame();
        }
        throw Error("Timed out waiting for a WebGL GPU query.");
      } finally {
        gl.deleteQuery(query);
      }
    },
    destroy() {}
  };
}

// WebGL elapsed queries cannot be nested. Profile individual post-processing draws in separate visits.
function glPostTimer(gl, engine) {
  const ext = gl.getExtension("EXT_disjoint_timer_query_webgl2");
  if (!ext) return null;
  const prototype = Object.getPrototypeOf(engine._basicResources.blitMaterial.shader.subShaders[0].passes[0]);
  const renderer = engine._hardwareRenderer;
  const postDraw = /^(?:ColorPyramidPrefilter|DownsampleAndBuildHiZMip0|SSRReceiver|HiZTrace|TemporalResolve|Bloom )/;
  return {
    source: "WebGL2 diagnostic: sum of native queries around selected SSR and Bloom draws",
    async sample(update) {
      const names = new WeakMap(),
        queries = [];
      const getProgram = prototype._getShaderProgram,
        draw = renderer.drawPrimitive;
      const restoreProgram = replace(prototype, "_getShaderProgram", function (...args) {
        const program = getProgram.apply(this, args);
        if (program) names.set(program._platformProgram ?? program, this.name);
        return program;
      });
      const restoreDraw = replace(renderer, "drawPrimitive", function (primitive, sub, program) {
        const name = names.get(program);
        if (!postDraw.test(name)) return draw.apply(this, arguments);
        const query = gl.createQuery();
        queries.push({ name, query });
        gl.beginQuery(ext.TIME_ELAPSED_EXT, query);
        try {
          return draw.apply(this, arguments);
        } finally {
          gl.endQuery(ext.TIME_ELAPSED_EXT);
        }
      });
      try {
        try {
          update();
        } finally {
          restoreDraw();
          restoreProgram();
        }
        if (!queries.length) throw Error("This frame had no SSR or Bloom draw to time.");
        gl.flush();
        for (let attempt = 0; attempt < 120; ++attempt) {
          if (gl.getParameter(ext.GPU_DISJOINT_EXT)) return null;
          if (queries.every(({ query }) => gl.getQueryParameter(query, gl.QUERY_RESULT_AVAILABLE))) {
            const passes = queries.map(({ name, query }) => ({
              name,
              milliseconds: gl.getQueryParameter(query, gl.QUERY_RESULT) / 1e6
            }));
            return { milliseconds: passes.reduce((sum, p) => sum + p.milliseconds, 0), passes };
          }
          await frame();
        }
        throw Error("Timed out waiting for WebGL post-processing timestamps.");
      } finally {
        for (const { query } of queries) gl.deleteQuery(query);
      }
    },
    destroy() {}
  };
}

function nativeTimer(device) {
  if (!device?.features.has("timestamp-query")) return null;
  const capacity = 4096;
  const queries = device.createQuerySet({ type: "timestamp", count: capacity });
  // Two independent resolve destinations must each be 256-byte aligned.
  const resolve = device.createBuffer({ size: 264, usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC });
  const readback = device.createBuffer({ size: 16, usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST });
  const diagnostics = { calibratedLastPass: null, skipped: [] };
  let terminal = null;

  function observe(update, stamp) {
    const encoders = new WeakMap(),
      commands = new WeakMap(),
      undo = [];
    let first,
      final,
      passes = 0,
      submissions = 0,
      writes = 0;
    function allocate() {
      if (writes >= capacity) throw Error("Seed frame boundary timestamps exceeded the native query capacity.");
      return writes++;
    }
    try {
      const proto = GPUCommandEncoder.prototype;
      for (const [method, kind] of [
        ["beginRenderPass", "render"],
        ["beginComputePass", "compute"]
      ]) {
        const begin = proto[method];
        undo.push(
          replace(proto, method, function (descriptor = {}) {
            let state = encoders.get(this);
            const label = kind + ": " + (descriptor.label || "(unlabeled)");
            // Multiple encoders may be recorded before the first submit, in a different order
            // from their eventual execution. Mark the first pass of each candidate encoder.
            const start = stamp && !first && !state ? allocate() : -1;
            const end = stamp && label === terminal ? allocate() : -1;
            if (!state) {
              state = { firstLabel: label, start, count: 0 };
              encoders.set(this, state);
            }
            ++state.count;
            state.lastLabel = label;
            state.end = end;
            if (start < 0 && end < 0) return begin.call(this, descriptor);
            if (descriptor.timestampWrites) throw Error("Disable the engine timer when using the Seed frame timer.");
            const timestampWrites = { querySet: queries };
            if (start >= 0) timestampWrites.beginningOfPassWriteIndex = start;
            if (end >= 0) timestampWrites.endOfPassWriteIndex = end;
            return begin.call(this, { ...descriptor, timestampWrites });
          })
        );
      }
      const finish = proto.finish;
      undo.push(
        replace(proto, "finish", function (...args) {
          const buffer = finish.apply(this, args);
          commands.set(buffer, encoders.get(this) ?? null);
          return buffer;
        })
      );
      const queuePrototype = GPUQueue.prototype,
        submit = queuePrototype.submit;
      undo.push(
        replace(queuePrototype, "submit", function (buffers) {
          if (this !== device.queue) return submit.call(this, buffers);
          const ordered = Array.isArray(buffers) ? buffers : Array.from(buffers);
          for (const buffer of ordered) {
            if (!commands.has(buffer)) throw Error("A Seed command buffer was recorded outside the sampled frame.");
            const state = commands.get(buffer);
            if (!state) continue; // A copy-only command buffer has no pass boundary.
            first ??= state;
            final = state;
            passes += state.count;
          }
          if (ordered.length) ++submissions;
          return submit.call(this, ordered);
        })
      );
      update();
    } finally {
      for (const restore of undo.reverse()) restore();
    }
    if (!passes) throw Error("The sampled Seed frame submitted no native render or compute passes.");
    return { first, final, passes, submissions, writes };
  }

  return {
    source: "WebGPU native pass-boundary timestamps: first submitted pass begin to final submitted pass end",
    diagnostics,
    calibrate(update) {
      terminal = observe(update, false).final.lastLabel;
      diagnostics.calibratedLastPass = terminal;
    },
    async sample(update, frameIndex) {
      const previous = terminal;
      const { first, final, passes, submissions, writes } = observe(update, previous !== null);
      terminal = final.lastLabel;
      if (previous !== terminal) {
        diagnostics.skipped.push({ frame: frameIndex, expected: previous, actual: terminal });
        return null;
      }
      if (first.start < 0 || final.end < 0 || first.start === final.end || first.start >= writes || final.end >= writes)
        throw Error("Missing native first or final pass timestamp.");
      const encoder = device.createCommandEncoder();
      encoder.resolveQuerySet(queries, first.start, 1, resolve, 0);
      encoder.resolveQuerySet(queries, final.end, 1, resolve, 256);
      encoder.copyBufferToBuffer(resolve, 0, readback, 0, 8);
      encoder.copyBufferToBuffer(resolve, 256, readback, 8, 8);
      device.queue.submit([encoder.finish()]);
      await readback.mapAsync(GPUMapMode.READ);
      try {
        const [start, end] = new BigUint64Array(readback.getMappedRange());
        if (!start || !end || end < start) throw Error("Invalid native pass boundary timestamps.");
        return {
          milliseconds: Number(end - start) / 1e6,
          firstPass: first.firstLabel,
          lastPass: final.lastLabel,
          passesSubmitted: passes,
          submissions,
          timestampWrites: writes
        };
      } finally {
        readback.unmap();
      }
    },
    destroy() {
      queries.destroy();
      resolve.destroy();
      readback.destroy();
    }
  };
}

function nativePassTimer(device) {
  if (!device?.features.has("timestamp-query")) return null;
  const capacity = 4096;
  const queries = device.createQuerySet({ type: "timestamp", count: capacity });
  const resolve = device.createBuffer({
    size: capacity * 8,
    usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC
  });
  const readback = device.createBuffer({
    size: capacity * 8,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
  });
  return {
    source: "WebGPU per-pass diagnostic, first-pass start to last-pass end",
    async sample(update) {
      const undo = [],
        passes = [];
      try {
        for (const name of ["beginRenderPass", "beginComputePass"]) {
          const owner = GPUCommandEncoder.prototype,
            original = owner[name];
          undo.push(
            replace(owner, name, function (descriptor = {}) {
              const offset = passes.length * 2;
              if (offset + 2 > capacity) throw Error("Native GPU timestamp query capacity exceeded.");
              if (descriptor.timestampWrites) throw Error("Disable the engine timer when using the Seed pass timer.");
              passes.push(descriptor.label || name);
              return original.call(this, {
                ...descriptor,
                timestampWrites: {
                  querySet: queries,
                  beginningOfPassWriteIndex: offset,
                  endOfPassWriteIndex: offset + 1
                }
              });
            })
          );
        }
        update();
      } finally {
        for (const restore of undo.reverse()) restore();
      }
      if (!passes.length) throw Error("No native WebGPU passes were encoded.");
      const count = passes.length * 2;
      const encoder = device.createCommandEncoder();
      encoder.resolveQuerySet(queries, 0, count, resolve, 0);
      encoder.copyBufferToBuffer(resolve, 0, readback, 0, count * 8);
      device.queue.submit([encoder.finish()]);
      await readback.mapAsync(GPUMapMode.READ, 0, count * 8);
      try {
        const stamps = new BigUint64Array(readback.getMappedRange(0, count * 8));
        let first, last;
        const perPass = passes.map((name, i) => {
          const start = stamps[2 * i],
            end = stamps[2 * i + 1];
          if (!start || !end || end < start) throw Error("Missing or invalid WebGPU pass timestamps.");
          if (first === undefined || start < first) first = start;
          if (last === undefined || end > last) last = end;
          return { name, milliseconds: Number(end - start) / 1e6 };
        });
        return { milliseconds: Number(last - first) / 1e6, passes: perPass };
      } finally {
        readback.unmap();
      }
    },
    destroy() {
      queries.destroy();
      resolve.destroy();
      readback.destroy();
    }
  };
}

function distribution(values) {
  if (!values.length) return null;
  const sorted = values.slice().sort((a, b) => a - b);
  const percentile = (p) => sorted[Math.ceil(sorted.length * p) - 1];
  return { samples: sorted.length, median: percentile(0.5), p90: percentile(0.9), p99: percentile(0.99) };
}

/** Run one freshly loaded template/variant per page. Pass a reference run's returned path to each comparison. */
export async function measureSeedTemplate(context = globalThis.__seedBenchmarkContext, options = {}) {
  const { engine, camera, navigation, orbit } = context;
  const canvas = context.canvas;
  const {
    template,
    seed,
    variant = "full",
    mode = "cpu",
    frames = 120,
    warmup = 30,
    width = 640,
    height = 360,
    image = true,
    gpuStride = 10
  } = options;
  if (
    !Number.isInteger(frames) ||
    frames < 4 ||
    !Number.isInteger(warmup) ||
    warmup < 0 ||
    !Number.isInteger(gpuStride) ||
    gpuStride < 1 ||
    !["cpu", "gpu"].includes(mode)
  )
    throw Error("Invalid measurement parameters.");
  const state = globalThis[stateKey];
  if (!state) throw Error("Call installSeedMetrics() before starting Seed.");
  const renderer = engine._hardwareRenderer,
    world = worldOf(context),
    transform = camera.entity.transform;
  const plan = context.publication.current.plan.parameters;
  const publishedTemplate = plan.worldTemplate?.id ?? "original";
  if (seed !== undefined && plan.seed !== seed)
    throw Error("Published Seed differs from the requested seed: " + plan.seed);
  if (template !== undefined && publishedTemplate !== template)
    throw Error("Published template differs from the requested template: " + publishedTemplate);
  const path = options.path ?? initialPath(transform);
  if (
    !Array.isArray(path) ||
    path.length < 2 ||
    path.some(({ position, rotation }) =>
      [position, rotation].some((v) => v?.length !== 3 || !v.every(Number.isFinite))
    )
  )
    throw Error("Invalid camera path.");
  const gl = canvas.getContext("webgl2");
  const device = gl ? null : (renderer.device ?? state.devices.at(-1));
  if (!gl && !device) throw Error("No active WebGL2 or WebGPU device.");
  const subtree = diagnosticSubtree(context, world, variant);
  const timer =
    mode === "gpu"
      ? gl
        ? options.gpuPassTimings
          ? glPostTimer(gl, engine)
          : glTimer(gl)
        : options.gpuPassTimings
          ? nativePassTimer(device)
          : nativeTimer(device)
      : null;
  const before = status(context, world, subtree),
    undo = [];
  const cpu = [],
    intervals = [],
    gpu = [],
    inspections = [],
    usedPath = [];
  const boundaries = options.frameBoundaries ? [] : null;
  const checkpoints = new Set([0, Math.floor((frames - 1) / 2), frames - 1]);
  const wasRunning = !engine.isPaused;
  engine.pause();
  try {
    for (const control of [navigation, orbit]) {
      if (typeof control?.enabled === "boolean") {
        const enabled = control.enabled;
        undo.push(() => {
          control.enabled = enabled;
        });
        control.enabled = false;
      }
    }
    const savedPosition = triple(transform.worldPosition),
      savedRotation = triple(transform.worldRotation);
    undo.push(() => {
      transform.setWorldPosition(...savedPosition);
      transform.setWorldRotation(...savedRotation);
    });
    const canvasWidth = canvas.width,
      canvasHeight = canvas.height;
    undo.push(() => engine.canvas.setResolution(canvasWidth, canvasHeight));
    engine.canvas.setResolution(width, height);
    ablate(context, world, variant, undo, subtree);
    // Pin the simulation clock to frame index. CPU, RAF and GPU timers still use their native clocks.
    const clock = engine.time;
    const values = ["_deltaTime", "_actualDeltaTime", "_elapsedTime", "_actualElapsedTime", "_lastSystemTime"];
    if (values.some((key) => typeof clock[key] !== "number")) throw Error("Unrecognized engine time implementation.");
    // Seed's LOD trackers have already consumed the clock during publication. Select the same
    // future epoch across cold starts so resetting the benchmark never moves a live tracker backward.
    const simulationEpoch = options.simulationEpoch ?? 120;
    if (simulationEpoch < Math.max(clock.elapsedTime, clock.actualElapsedTime))
      throw Error("Simulation epoch predates the published scene.");
    undo.push(() => clock._reset());
    let step = 0;
    undo.push(
      replace(clock, "_update", function () {
        this._deltaTime = this._actualDeltaTime = 1 / 60;
        this._elapsedTime = this._actualElapsedTime = simulationEpoch + ++step / 60;
        this._frameCount++;
      })
    );
    for (let i = 0; i < warmup; ++i) {
      await frame();
      // Traverse the measured route to compile visible material/LOD variants before sampling.
      applyPath(transform, path, warmup > 1 ? i / (warmup - 1) : 0);
      if (i === warmup - 1 && timer?.calibrate) timer.calibrate(() => engine.update());
      else engine.update();
    }
    let previous,
      skipNextInterval = true;
    const update = () => engine.update();
    const effects = status(context, world, subtree);
    let captured;
    for (let i = 0; i < frames; ++i) {
      if (options.profileCpu && i > 0 && checkpoints.has(i) && !checkpoints.has(i - 1)) {
        await globalThis.__seedProfileCpu("stop", i - 1);
      }
      const time = await frame();
      if (boundaries) boundaries.push(performance.timeOrigin + time);
      if (mode === "cpu" && previous !== undefined && !skipNextInterval) intervals.push(time - previous);
      previous = time;
      applyPath(transform, path, i / (frames - 1));
      const inspect = checkpoints.has(i),
        timed = !!timer && i < frames - 1 && i % gpuStride === 0;
      skipNextInterval = inspect;
      const position = inspect ? triple(transform.worldPosition) : null;
      const direction = inspect ? triple(transform.worldForward) : null;
      let draws, transfers;
      const draw = inspect
        ? () => {
            const inspectedUpdate = options.uploadSources
              ? () => {
                  transfers = globalThis.__seedCaptureTransfers(gl, update);
                }
              : update;
            draws = oneFrameDraws(gl, state, engine, inspectedUpdate);
          }
        : update;
      if (timed) {
        const sample = await timer.sample(draw, i);
        if (sample) gpu.push({ frame: i, ...sample });
      } else {
        const start = performance.now();
        draw();
        if (mode === "cpu" && !inspect) cpu.push(performance.now() - start);
      }
      if (inspect) {
        if (subtree && (subtree.entity.destroyed || !subtree.entity.parent || subtree.entity.isActiveInHierarchy)) {
          throw Error("Expected the diagnostic subtree to stay attached and hidden: " + subtree.path);
        }
        const actual = triple(transform.worldPosition);
        if (
          actual.some((v, j) => Math.abs(v - position[j]) > 0.02) ||
          triple(transform.worldForward).some((v, j) => Math.abs(v - direction[j]) > 0.001)
        ) {
          throw Error("Template overwrote the benchmark camera path.");
        }
        usedPath.push({ frame: i, position: actual, rotation: triple(transform.worldRotation) });
        inspections.push({ frame: i, ...draws, ...snapshot(context, world), ...(transfers && { transfers }) });
        if (options.profileCpu && i + 1 < frames && !checkpoints.has(i + 1)) {
          await globalThis.__seedProfileCpu("start", i + 1);
        }
      }
      if (i === frames - 1) {
        // A canvas can be discarded at the next animation frame. Capture immediately after the final draw.
        captured = pixels(canvas, image);
      }
    }
    if (canvas.width !== width || canvas.height !== height)
      throw Error("Presentation canvas resolution changed during the benchmark.");
    const webglErrors = [];
    if (gl) {
      for (let i = 0; i < 16; ++i) {
        const error = gl.getError();
        if (error === gl.NO_ERROR) break;
        webglErrors.push(error);
      }
    }
    return {
      template: publishedTemplate,
      seed: plan.seed,
      variant,
      backend: gl ? "webgl2" : "webgpu",
      mode,
      frames,
      warmup,
      width,
      height,
      warmupPath: "replay",
      fixedDeltaSeconds: 1 / 60,
      simulationEpoch,
      path,
      usedPath,
      before,
      effects,
      inspections,
      cpuUpdateMs: distribution(cpu),
      frameIntervalMs: distribution(intervals),
      gpuSource: timer?.source ?? null,
      ...(timer?.diagnostics && { gpuTimingDiagnostics: timer.diagnostics }),
      gpuMs: distribution(gpu.map((x) => x.milliseconds)),
      gpuSamples: gpu,
      ...(boundaries && { frameBoundariesEpochMs: [...boundaries, performance.timeOrigin + (await frame())] }),
      webglErrors,
      ...captured
    };
  } finally {
    timer?.destroy();
    for (const restore of undo.reverse()) restore();
    if (wasRunning) engine.resume();
  }
}
