/** Naga emits one WGSL function per overload and declares callees before callers.
 * Drop sampler arguments of helpers that only issue textureLoad/textureDimensions.
 * A texture is still required, but no sampler object or sampler slot is needed. */
export function removeUnusedSamplers(source: string): {
  source: string;
  bindings: Set<string>;
} {
  const removed = new Map<string, Set<number>>();
  function splitArguments(text: string): string[] {
    const fields: string[] = [];
    let start = 0, depth = 0;
    for (let i=0;i<text.length;i++) {
      const ch=text[i];
      if (ch==="(" || ch==="[" || ch==="<") depth++;
      else if (ch===")" || ch==="]" || ch===">") depth--;
      else if (ch==="," && !depth) { fields.push(text.slice(start,i)); start=i+1; }
    }
    fields.push(text.slice(start));
    return fields;
  }
  function replaceCalls(text: string): string {
    for (const [name, skip] of removed) {
      const call = new RegExp("\\b"+name+"\\(","g");
      let match: RegExpExecArray | null;
      while ((match=call.exec(text))) {
        const start=call.lastIndex;
        let end=start, depth=1;
        for(;end<text.length && depth;end++) {
          if(text[end]==="(")depth++;
          else if(text[end]===")") depth--;
        }
        const args=splitArguments(text.slice(start,end-1)).filter((_,i)=>!skip.has(i)).join(",");
        text=text.slice(0,start)+args+text.slice(end-1);
        call.lastIndex=start+args.length+1;
      }
    }
    return text;
  }
  // Naga prints a closing function brace at column zero; nested control flow
  // and expression statements are indented inside the function.
  source = source.replace(/\bfn (\w+)\(([^()]*)\)([^{}]*)\{([\s\S]*?\n)\}/g,
    (_, name: string, parameters: string, result: string, body: string) => {
      body = replaceCalls(body);
      const unused = new Set<number>();
      const fields = splitArguments(parameters);
      fields.forEach((field, index) => {
        const param = /^\s*(\w+):\s*sampler(?:_comparison)?\s*$/.exec(field);
        if (param && !new RegExp("\\b" + param[1] + "\\b").test(body)) unused.add(index);
      });
      if (unused.size) removed.set(name, unused);
      return "fn " + name + "(" + fields.filter((_, index) => !unused.has(index)).join(",") + ")" + result + "{" + body + "}";
    });
  const bindings = new Set<string>();
  source = source.replace(/@group\((\d+)\)\s*@binding\((\d+)\)\s*var (\w+): sampler(?:_comparison)?;/g,
    (declaration, group: string, binding: string, name: string) => {
      const occurrences = source.match(new RegExp("\\b" + name + "\\b", "g"));
      if (occurrences?.length === 1) return "";
      bindings.add(group + ":" + binding);
      return declaration;
    });
  return { source, bindings };
}
