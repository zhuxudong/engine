// Serialize explicit WebGPU descriptors on creation. IDs refer to the exact WGSL strings.
export function captureDevice(device, input, training=false) {
  const modules=input?.modules?.slice()??[], sourceIds=new Map(modules.map((s,i)=>[s,i]));
  const programs=new WeakMap(), groups=new WeakMap(), layouts=new WeakMap();
  const makeGroups=new Map(),makeLayouts=new Map(),makeModules=new Map();
  const records=[], events=[], indices=new Map(), cache=new Map(), supported=new Set((input?.pipelines??[]).map(row=>key(row)));
  const groupKeys=new Set(),layoutKeys=new Set();
  for(const {desc} of input?.pipelines??[]){if(desc.layout!=='auto'){layoutKeys.add(key(desc.layout));for(const g of desc.layout.bindGroupLayouts)if(g!==null)groupKeys.add(key(g));}}
  const stats={prepared:0,hits:0,incompatible:false};const originals={};
  function clone(v) {
    if(Array.isArray(v)||ArrayBuffer.isView(v))return Array.from(v,clone);
    if(v===null||typeof v!=='object')return v;
    return Object.fromEntries(Object.keys(v).sort().filter(k=>v[k]!==undefined).map(k=>[k,clone(v[k])]));
  }
  function key(v){return JSON.stringify(clone(v));}
  function intercept(name,fn){const old=device[name].bind(device);originals[name]=old;device[name]=(...args)=>fn(old,...args);}
  const noLabel=d=>Object.fromEntries(Object.entries(d).filter(([k])=>k!=='label'));
  intercept('createShaderModule',(old,d)=>{const v=old(d);let id=sourceIds.get(d.code);if(id===undefined&&training){id=modules.length;modules.push(d.code);sourceIds.set(d.code,id);}if(id!==undefined){programs.set(v,id);if(!training)makeModules.set(id,v);}return v;});
  intercept('createBindGroupLayout',(old,d)=>{const desc=clone(noLabel(d)),k=key(desc);
    if(!training&&makeGroups.has(k))return makeGroups.get(k);const v=old(d);groups.set(v,desc);if(!training&&groupKeys.has(k))makeGroups.set(k,v);return v;});
  intercept('createPipelineLayout',(old,d)=>{const g=d.bindGroupLayouts.map(x=>x===null?null:groups.get(x));if(g.includes(undefined))return old(d);
    const desc={...noLabel(d),bindGroupLayouts:g},k=key(desc);if(!training&&makeLayouts.has(k))return makeLayouts.get(k);
    const v=old(d);layouts.set(v,desc);if(!training&&layoutKeys.has(k))makeLayouts.set(k,v);return v;});
  function flatten(type,d){
    const b=noLabel(d);b.layout=d.layout==='auto'?'auto':layouts.get(d.layout);if(b.layout===undefined)return null;
    for(const stage of ['vertex','fragment','compute'])if(d[stage]){
      const m=programs.get(d[stage].module);if(m===undefined)return null;
      b[stage]={...d[stage],module:m};
    }
    return {type,desc:clone(b)};
  }
  for(const name of ['createRenderPipeline','createRenderPipelineAsync','createComputePipeline','createComputePipelineAsync'])intercept(name,(old,d)=>{
    const t=performance.now(),row=flatten(name.includes('Render')?'render':'compute',d);if(!row)return old(d);
    const k=key(row);if(training){
      let id=indices.get(k);if(id===undefined){id=records.length;indices.set(k,id);records.push(row);}events.push([t,id]);
    }else if(supported.has(k)&&cache.has(k)){
      stats.hits++;const p=cache.get(k);return name.endsWith('Async')?Promise.resolve(p):p;
    }
    const v=old(d);
    if(!training&&supported.has(k)){if(name.endsWith('Async'))v.then(p=>cache.set(k,p),()=>{});else cache.set(k,v);}
    return v;
  });
  const profile={features:Array.from(device.features).sort(),maxColorAttachments:device.limits.maxColorAttachments};
  async function prepare(){if(!input?.pipelines?.length)return stats;
    if(key(profile)!==key(input.profile)){stats.incompatible=true;return stats;}
    for(const row of input.pipelines){
      const k=key(row);if(cache.has(k))continue;
      const d={...row.desc};
      if(d.layout!=='auto')d.layout=device.createPipelineLayout({...d.layout,bindGroupLayouts:d.layout.bindGroupLayouts.map(b=>b===null?null:device.createBindGroupLayout(b))});
      for(const s of ['vertex','fragment','compute'])if(d[s]){
        const idx=d[s].module,mod=makeModules.get(idx)??device.createShaderModule({code:modules[idx]});d[s]={...d[s],module:mod};
      }
      const p=await originals[row.type==='render'?'createRenderPipelineAsync':'createComputePipelineAsync'](d);cache.set(k,p);
    }
    stats.prepared=cache.size;return stats;
  }
  return {prepare,stats,export:()=>({modules,records,events,profile})};
}
