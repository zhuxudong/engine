import {applyExtra,applyToDemo,resolve,load} from "./extend.mjs";
/** Local Seed launch experiment for the pinned 679453a52 fixture. */
function only(source, before, after) {
  if (source.split(before).length !== 2) throw Error("Unexpected pinned source around: " + before.slice(0, 80));
  return source.replace(before, () => after);
}

function between(source, first, last, replacement) {
  const a = source.indexOf(first), b = source.indexOf(last, a + first.length);
  if (a < 0 || b < 0 || source.indexOf(first, a+first.length) >= 0) throw Error("Cannot replace " + first);
  return source.slice(0, a) + replacement + source.slice(b);
}

export default function localLoadingWarmup() {
  return {
    name: "seed-local-loading-warmup",
    enforce: "pre",
    resolveId: resolve, load,
    transform(source, id) {
      const extra = applyExtra(source,id,only); if(extra !== undefined) return extra;
      if (!id.endsWith("/world/demos/seed-world/SeedWorldDemo.ts")) return;
      source = 'import { ShaderPass as LoadingShaderPass } from "@galacean/engine";\n' + source;
      source = only(source, "let ready = false;", "let ready = false;\n  let renderingForWarmup = false;");
      source = only(source, "if (!ready) return;\n      readWorld()?.update(dt);", "if (!ready && !renderingForWarmup) return;\n      readWorld()?.update(dt);");
      source = only(source, "isActive: () => ready && !disposed,", "isActive: () => (ready || renderingForWarmup) && !disposed,");
      source = between(source, '    shaderAudit?.setPhase("reveal");\n    farmingHost', '    disconnectEditorAssets = timed("tools.connectProject"', `
    const warmSignal = editorLifetime.signal;
    const warmReceipt = {
      primaryRequested: startupWarmupReport?.requested ?? 0,
      primaryCompiled: startupWarmupReport?.compiled ?? 0,
      secondaryRequested: 0, secondaryCompiled: 0, shaderMisses: 0, exercisedFrames: 0,
      snapshotPrepared: false, interactionDepthPrepared: false, photoPanelPrepared: false, picksDrained: false,
      gpuDrained: false, completedAtMs: 0
    };
    if (warmReceipt.primaryRequested !== warmReceipt.primaryCompiled) throw Error("Primary shader manifest incomplete");
    const unsubscribeWarm = LoadingShaderPass.observeVariants(engine!, () => { warmReceipt.shaderMisses++; });
    warmSignal.addEventListener("abort", unsubscribeWarm, {once:true});
    const nextRenderedFrame = () => new Promise<void>((resolve, reject) => {
      const frame = engine!.time.frameCount;
      let handle = 0;
      const abort = () => { cancelAnimationFrame(handle); reject(warmSignal.reason); };
      const step = () => {
        if (engine!.time.frameCount === frame) { handle = requestAnimationFrame(step); return; }
        warmSignal.removeEventListener("abort", abort);
        warmReceipt.exercisedFrames++;
        resolve();
      };
      if (warmSignal.aborted) { reject(warmSignal.reason); return; }
      warmSignal.addEventListener("abort", abort, {once:true});
      handle = requestAnimationFrame(step);
    });
    camera.enabled = true;
    renderingForWarmup = true;
    loading.dataset.state = "fallback";
    loading.style.pointerEvents = "auto";
    canvas.inert = true;
    progress(0.98, "准备世界着色器");
    if (disposed) return;
    const allSecondary = [...deferredShaderVariants, ...((await collectDeferredVariants?.()) ?? [])];
    collectDeferredVariants = undefined;
    deferredShaderVariants = [];
    if (allSecondary.length) {
      const secondary = await timed("warmup.secondaryManifest", () => warmupSeedWorldShaderVariants(engine!, allSecondary, {
        strict: true, preserveOrder: true, signal: warmSignal, frameBudgetMilliseconds: 12,
        maximumPendingPrograms: startupWarmupReport?.parallelCompileSupported ? 8 : 1, ssrVerifyReceiverDepth
      }));
      warmReceipt.secondaryRequested = secondary.requested;
      warmReceipt.secondaryCompiled = secondary.compiled;
      if (secondary.compiled !== secondary.requested) throw Error("Secondary shader manifest incomplete");
    }
    warmSignal.throwIfAborted();
    publication?.current?.masonry?.startEntrance();
    readWorld()?.update(0);
    await timed("warmup.spawnDraw", nextRenderedFrame);
`);
      const navigation = `    if (debugSidebar) debugSidebar.setInputEnabled(true);
    else {
      navigation.enabled = true;
      navigation.setInputEnabled(true);
    }
    navigation.setGroundCollision(true);`;
      source = only(source, navigation, "");
      const show = '    if (options.showAssistant !== false) timed("tools.show", () => tools!.show());';
      source = only(source, show, "");
      const oldPublish = `    loading.hidden = true;
    canvas.dataset.status = "ready";
    document.body.dataset.worldReady = "true";
    seedWorldBootTrace.finish();`;
      source = only(source, oldPublish, '    progress(0.99, "准备拾取与截图");');
      source = between(source, "    // The world is already visible and navigable.", "    const photoPreparationStarted", "");
      source = only(source, '      canvas.dataset.snapshotWarmupMs = String(performance.now() - photoPreparationStarted);', `
      warmReceipt.snapshotPrepared = true;
      const interactionRay = camera.viewportPointToRay(new Vector2(0.5, 0.5), new Ray());
      await timed("worldPicker.prepareInteractionDepth", () => preparingPicker.depthAlongRay(
        (visitor) => snapshotPicks.visit(visitor), interactionRay, warmSignal
      ));
      warmReceipt.interactionDepthPrepared = true;
      canvas.dataset.snapshotWarmupMs = String(performance.now() - photoPreparationStarted);`);
      source = between(source, "    const bgWarmupDone: Promise<void> =", '      const [, { SeedWorldLassoPanel }', '    await (async () => {\n');
      const setPhoto = '      canvas.dataset.photoPreparation = "ready";';
      source = only(source, setPhoto, setPhoto + '\n      warmReceipt.photoPanelPrepared = true;');
      source = only(source, '      console.warn("[seed-world-planner] photo preparation failed", error);\n    });', `
      throw error;
    });
    warmSignal.throwIfAborted();
    // Exercise the actual camera, then drain picking programs derived from its draws
    // and await the submitted native render and compute work. A new variant restarts the check.
    const settle = async () => {
      let clean = 0;
      const queue = engine!._hardwareRenderer.device!.queue;
      while (clean < 2) {
        const before = warmReceipt.shaderMisses;
        await nextRenderedFrame();
        await preparingPicks.flush(warmSignal);
        await queue.onSubmittedWorkDone();
        warmSignal.throwIfAborted();
        clean = (warmReceipt.shaderMisses === before && preparingPicks.ready) ? clean + 1 : 0;
      }
      warmReceipt.gpuDrained = true;
      warmReceipt.picksDrained = preparingPicks.ready;
    };
    // The visible voice HUD uses additional glass and solid-colour pipelines.
    // Mount its final state behind the loader so the following real frames include those draws.
    if (lassoPanel) lassoPanel.button.inert = true;
` + show + `
    await timed("warmup.spawnQueue", settle);
    loading.dataset.state = "loading";
    shaderAudit?.setPhase("reveal");
    progress(1, "展示沙漠");
    await timed("orb.reveal", () => orb!.reveal());
    orb!.destroy();
    orb = undefined;
    // Replacing the loading camera can change attachment state on the first standalone frame.
    await timed("warmup.standaloneSpawn", settle);
    warmReceipt.completedAtMs = performance.now();
    canvas.dataset.wgslWarmup = JSON.stringify(warmReceipt);
    warmSignal.removeEventListener("abort", unsubscribeWarm);
    unsubscribeWarm();
    ready = true;
    renderingForWarmup = false;
    canvas.inert = false;
    if (lassoPanel) lassoPanel.button.inert = false;
    shaderAudit?.setPhase("post-ready");
    audio?.audio.setLoadDeferred(false);
` + navigation + '\n' + oldPublish + `
    if (bootTraceParam) void seedWorldBootTrace.reportToDiag("ready");`);
      return applyToDemo(source,only);
    }
  };
}
