import manifest from './recipes.json';
import {captureDevice} from './device.mjs';
const hardware=new WeakMap();
if (globalThis.GPUAdapter && manifest.device.pipelines.length){
  const original=GPUAdapter.prototype.requestDevice;
  GPUAdapter.prototype.requestDevice=function(...args){
    return original.apply(this,args).then(device=>{
      hardware.set(device,captureDevice(device,manifest.device));return device;
    });
  };
}
globalThis.__seedLocalMeasuredWarmup=async(engine,signal)=>{
  const renderer=engine._hardwareRenderer,compiler=engine._webGPUShaderCompiler;
  const original=compiler.compileWebGPUVariant.bind(compiler);
  const srcId=new Map(manifest.sources.map((s,i)=>[s,i])),store=new Map();
  const metrics={requested:manifest.recipes.length,compiled:0,skippedForLimits:0,hits:0,native:null};
  const convert=(k,v)=>v instanceof Set?{__set:Array.from(v)}:v;
  const revive=(k,v)=>v && typeof v==='object'&&Array.isArray(v.__set)?new Set(v.__set):v;
  // Full source equality and complete compiler options guard hits. Unseen inputs use the ordinary compiler.
  compiler.compileWebGPUVariant=function(v,f,options){
    const vi=srcId.get(v),fi=srcId.get(f);if(vi===undefined||fi===undefined)return original(v,f,options);
    const id=JSON.stringify([vi,fi,options],convert);
    const known=store.get(id);if(known){metrics.hits++;return known;}
    return original(v,f,options);
  };
  let batchStart=performance.now();
  for(const [vi,fi,template] of manifest.recipes){
    signal.throwIfAborted();const options=JSON.parse(JSON.stringify(template),revive);
    const actual={maxTexturesPerStage:renderer.maxSampledTexturesPerShaderStage,maxSamplersPerStage:renderer.maxSamplersPerShaderStage,maxUniformBlockBytes:renderer.maxUniformBlockSize};
    // A recorded layout for a different device can exceed local limits. Natural scene warmup covers that device.
    if(Object.keys(actual).some(k=>k in options && options[k]!==actual[k])){metrics.skippedForLimits++;continue;}
    const id=JSON.stringify([vi,fi,options],convert);
    if(!store.has(id)){store.set(id,original(manifest.sources[vi],manifest.sources[fi],options));metrics.compiled++;}
    if(performance.now()-batchStart>12){await new Promise(requestAnimationFrame);batchStart=performance.now();}
  }
  const native=hardware.get(renderer.device);
  if(native)metrics.native=await native.prepare();
  return metrics;
};
