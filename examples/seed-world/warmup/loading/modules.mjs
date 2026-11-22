const programs = new WeakMap();

export function loadOrCreateModule(device, label, code) {
  const record = programs.get(device);
  if (record) {
    const found = record.modules.get(code);
    if (found) { record.receipt.programModuleHits++; return found; }
    record.receipt.programModuleMisses++;
  }
  return device.createShaderModule({ label, code });
}

export async function warmDefaultModules(device, common, buildings) {
  if (!common || !buildings) throw Error("Both local shader asset bundles are required");
  let files = 0, passes = 0, embedded = 0;
  const compiled = new Map();
  const checks = [];
  for (const [url, bytes] of new Map([...common, ...buildings])) {
    if (!new URL(url, location.href).pathname.endsWith(".shaderc")) continue;
    files++;
    const data = JSON.parse(new TextDecoder().decode(bytes));
    for (const sub of data.subShaders) for (const pass of sub.passes) {
      if (pass.isUsePass) continue;
      passes++;
      if (!pass.wgsl) continue;
      embedded++;
      for (const stage of ["vertex", "fragment"]) {
        const code = pass.wgsl[stage];
        if (!code) throw Error("Missing WGSL " + stage + " for " + url);
        if (compiled.has(code)) continue;
        const label = data.name + "/" + sub.name + "/" + pass.name + "/" + stage;
        const module = device.createShaderModule({ label, code });
        compiled.set(code, module);
        checks.push(module.getCompilationInfo().then(info => {
          const errors = info.messages.filter(x => x.type === "error");
          if (errors.length) throw Error(label + ": " + errors.map(x=>x.message).join(", "));
        }));
      }
    }
  }
  if (files !== 26 || passes !== 36 || (embedded && embedded !== passes))
    throw Error("Incomplete local Seed shader bundle: " + JSON.stringify({files,passes,embedded}));
  await Promise.all(checks);
  const receipt = {files, passes, embedded, uniqueModules:compiled.size,programModuleHits:0,programModuleMisses:0};
  programs.set(device, {modules:compiled, receipt});
  return receipt;
}
