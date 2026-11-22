function installFpsHud(engine, lifetime) {
  const hud = document.createElement("span");
  hud.dataset.seedFps = "";
  hud.style.cssText =
    "position:fixed;top:calc(env(safe-area-inset-top,0px) + 8px);left:calc(env(safe-area-inset-left,0px) + 8px);" +
    "z-index:100001;pointer-events:none;background:#111d;color:white;padding:4px 8px;border-radius:4px;" +
    "font:600 14px/1.3 ui-monospace,monospace;font-variant-numeric:tabular-nums";
  document.body.append(hud);
  let since, frames;
  function reset() {
    since = performance.now();
    frames = engine.time.frameCount;
    hud.textContent = "FPS …";
  }
  reset();
  const timer = setInterval(() => {
    if (document.hidden) return;
    const now = performance.now();
    const current = engine.time.frameCount;
    hud.textContent = "FPS " + (((current - frames) * 1000) / (now - since)).toFixed(1);
    since = now;
    frames = current;
  }, 500);
  document.addEventListener("visibilitychange", reset, { signal: lifetime });
  lifetime.addEventListener(
    "abort",
    () => {
      clearInterval(timer);
      hud.remove();
    },
    { once: true }
  );
}

/** Expose the original Seed World only after its publication and reveal have completed. */
export function exposeSeedBenchmarkContext(source) {
  const ready = 'canvas.dataset.status = "ready";';
  const start = "engine.run();";
  if (source.split(ready).length !== 2) throw new Error("Cannot locate the Seed World readiness marker.");
  if (source.split(start).length !== 2) throw new Error("Cannot locate the Seed World frame loop.");
  return source
    .replace(
      start,
      () =>
        start +
        '\nif (pageUrl.searchParams.get("fps") === "1") (' +
        installFpsHud.toString() +
        ")(engine, editorLifetime.signal);"
    )
    .replace(
      ready,
      `
    globalThis.__seedBenchmarkContext = {
      engine, scene, camera, root, canvas, sun, post, wind, environment, water,
      publication, navigation, orbit, perfPanel, vistaControls, tools, readWorld
    };
    ` + ready
    );
}
