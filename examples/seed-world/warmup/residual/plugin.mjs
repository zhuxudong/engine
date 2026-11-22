import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
const manifest=fileURLToPath(new URL('./recipes.json',import.meta.url));
const runtime=fileURLToPath(new URL('./runtime.mjs',import.meta.url));
export default function recordedSeedVariants(){
  if(!fs.existsSync(manifest))return {name:'seed-no-recorded-variants'};
  return {
    name:'seed-recorded-variants',enforce:'pre',
    transform(code,id){
      if(id.endsWith('/world/demos/seed-world/SeedWorldDemo.ts')){
        return 'import '+JSON.stringify(runtime)+';\n'+code;
      }
    }
  };
}
