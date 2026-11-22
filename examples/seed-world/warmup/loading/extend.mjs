import { readFileSync } from 'node:fs';
const virt = 'virtual:seed-wgsl-defaults';
export function resolve(id) { return id===virt ? '\0'+virt : null; }
export function load(id) { return id==='\0'+virt ? readFileSync(new URL('./modules.mjs',import.meta.url),'utf8') : null; }
export function applyExtra(source,id,only) {
  if (id.endsWith('/rhi-webgpu/src/WebGPUShaderProgram.ts')) {
    source = 'import { loadOrCreateModule } from "'+virt+'";\n' + source;
    for(const stage of ['vertex','fragment'])source=only(source,
      'device.createShaderModule({ label: "Galacean '+stage+'", code: _source.'+stage+'Source })',
      'loadOrCreateModule(device, "Galacean '+stage+'", _source.'+stage+'Source)');
    return source;
  }
  if (id.endsWith('/runtime/SeedWorldPopulationRuntime.ts')) {
    return only(source, '  get rockSurfaceGrassDiagnostics():', `  get loadingSpawnWork() {
    const detail = this.details.isActiveInHierarchy;
    return {
      appearanceBatches:this._grassRockAppearancePending.size,
      rockWindow:detail && this._rockSurfaceGrassVisibilityDirty,
      detailResidency:detail && !this._detailCells.isResidencySettled,
      detailCompactions:detail ? this._detailCells.cells.filter(c=>c.resource.compactionTask).length : 0,
      sparseResidency:this.trees.isActiveInHierarchy && !this._sparseCells.isResidencySettled
    };
  }
  get rockSurfaceGrassDiagnostics():`);
  }
  if (id.endsWith('/world/SeedWorldViewSnapshot.ts')) {
    return only(source, '  capture(signal?: AbortSignal): Promise<{ snapshotId:', `  async duringStartupCapture(work: () => Promise<void>): Promise<void> {
    const previous = new Set(this.frames.keys());
    const serial = this.serial;
    try { await work(); } finally {
      for (const id of [...this.frames.keys()]) if (!previous.has(id)) {
        if (this.frames.get(id)!.pins) throw Error("Warm capture retained by a UI consumer");
        this.removeAttachment(id);
        this.drop(id);
      }
      this.serial = serial;
    }
  }
  capture(signal?: AbortSignal): Promise<{ snapshotId:`);
  }
  if (id.endsWith('/src/SeedWorldLassoPanel.ts')) {
    source=only(source, '  private photoSerial = 0;', '  private photoSerial = 0;\n  private startupCapture = false;');
    source=only(source, '      updateAttachment: (id, annotations) => {', '      updateAttachment: (id, annotations) => {\n        if (this.startupCapture) return;');
    return only(source, '  setAttachmentAnchor(x: number', `  async warmEditing(nextFrame:()=>Promise<void>, signal:AbortSignal):Promise<void> {
    const serial = this.photoSerial;
    const focus = document.activeElement as HTMLElement | null;
    this.startupCapture = true;
    try {
      await this.views.duringStartupCapture(async () => {
        try {
          await this.open();
          signal.throwIfAborted();
          if (this.workspace.phase !== "editing") throw Error("Opening the temporary photo editor failed");
          await nextFrame();
          await nextFrame();
        } finally { this.close(); }
      });
    } finally {
      this.startupCapture = false;
      this.photoSerial = serial;
      if (document.activeElement !== focus) {
        (document.activeElement as HTMLElement|null)?.blur?.();
        if (focus && focus !== document.body) focus.focus({preventScroll:true});
      }
    }
  }
  setAttachmentAnchor(x: number`);
  }
  if (id.endsWith('/world/SeedWorldPhotoWarmup.ts')) {
    return only(source, '    camera.renderTarget = target;\n    await warmupSeedWorldRendererVariants', '    camera.renderTarget = target;\n    camera.clearFlags = clear;\n    draw();\n    await warmupSeedWorldRendererVariants');
  }
}
export function applyToDemo(source, only) {
  source='import {warmDefaultModules} from "'+virt+'";\n'+source;
  source=only(source, '    const warmSignal = editorLifetime.signal;', `    const warmSignal = editorLifetime.signal;
    const measuredRecipes = await timed("warmup.measuredVariants", async () =>
      await globalThis.__seedLocalMeasuredWarmup?.(engine!, warmSignal));
`);
  source=only(source, '    const warmReceipt = {', '    const warmReceipt = { measuredRecipes,');
  source=only(source, '    let prewarmedRasterPlan: IslandPlan | undefined', `    const bundleDefaults = await timed("warmup.businessDefaultModules", async () =>
      warmDefaultModules(engine!._hardwareRenderer.device, await commonBinaryBundleTask,
        await (buildingBinaryBundleTask ??= loadSeedWorldBuildingBinaryBundle().then(assets => {
          prefetchedBuildingBinaryAssets = assets; syncPrefetchedBinaryAssets(); return assets;
        }))));
    let prewarmedRasterPlan: IslandPlan | undefined`);
  source=only(source, '      primaryRequested: startupWarmupReport', '      defaults: bundleDefaults, panoramaViews: 0, photoEditingPrepared:false,\n      primaryRequested: startupWarmupReport');
  source=only(source,'    await timed("warmup.spawnDraw", nextRenderedFrame);',`    await timed("warmup.spawnDraw", nextRenderedFrame);
    // Prefetch view-dependent draws around the authored spawn, restoring its exact quaternion before capture.
    await timed("warmup.spawnPanorama", async () => {
      const form = camera.entity.transform;
      const rotation = form.worldRotationQuaternion.clone(), origin=form.worldPosition.clone();
      try {
        for(let sector=1;sector<8;sector++){
          form.worldRotationQuaternion=rotation;
          form.rotate(new Vector3(0,sector*45,0), false);
          await nextRenderedFrame();
          warmReceipt.panoramaViews++;
        }
      } finally { form.worldRotationQuaternion=rotation;form.worldPosition=origin; }
      await nextRenderedFrame();
      warmReceipt.panoramaViews++;
    });`);
  source=only(source,'    await timed("warmup.spawnQueue", settle);', `    await timed("warmup.population", async () => {
      const world = readWorld();
      const opening = world.population.loadingSpawnWork;
      let drawFrames = 0;
      for (;;) {
        const w = world.population.loadingSpawnWork;
        if (!w) throw Error("Missing spawn population work state");
        if (!Object.values(w).some(Boolean)) {
          warmReceipt.population = {opening, completed:w, drawFrames};
          break;
        }
        await nextRenderedFrame();drawFrames++;
      }
    });
    await timed("warmup.spawnQueue", settle);`);
  return only(source, '      warmReceipt.photoPanelPrepared = true;', `      warmReceipt.photoPanelPrepared = true;
      await timed("warmup.photoEditor", () => preparingLasso.warmEditing(nextRenderedFrame, warmSignal));
      warmReceipt.photoEditingPrepared = true;`);
}
