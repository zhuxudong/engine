/** Expose the original Seed World only after its publication and reveal have completed. */
export function exposeSeedBenchmarkContext(source) {
  const ready = 'canvas.dataset.status = "ready";';
  if (source.split(ready).length !== 2) throw new Error("Cannot locate the Seed World readiness marker.");
  return source.replace(
    ready,
    `
    globalThis.__seedBenchmarkContext = {
      engine, scene, camera, root, canvas, sun, post, wind, environment, water,
      publication, navigation, orbit, perfPanel, vistaControls, tools, readWorld
    };
    ` + ready
  );
}
