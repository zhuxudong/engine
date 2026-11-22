// Seed ships these shaders as compiled instruction streams. Change only the text at
// screen-space coordinate conversions, keeping every branch and absolute jump target.
function orientSeedScreenSpaceInstructions(data) {
  const water = /^(?:Water\/|AIWorld\/(?:HeightfieldWater|Ocean))/.test(data.name);
  // These precompiled wet-surface shaders inline the same SSR clip-to-texture conversion.
  const terrain = /^Terrain\/(?:Grass|Surface|Vegetation|Terrain)$/.test(data.name);
  if (!water && !terrain) return data;
  const orient = (source) =>
    source
      .replace(
        /(vec2\s+(screenU[vV])\s*=[^;]*?\b(?:clipPosition|positionCS)\s*\.\s*xy[^;]*;)/g,
        "$1 $2.y = 1.0 - $2.y;"
      )
      .replace(/(vec2\s+(refractionNormalDelta|refractionOffset)\s*=[^;]+;)/g, "$1 $2.y = -$2.y;")
      .replace(/(vec2\s+ndc\s*=\s*uv\s*\*\s*2\.0\s*-\s*1\.0\s*;)/g, "$1 ndc.y = -ndc.y;");
  return {
    ...data,
    subShaders: data.subShaders.map((sub) => ({
      ...sub,
      passes: sub.passes.map((pass) =>
        pass.isUsePass
          ? pass
          : {
              ...pass,
              fragmentShaderInstructions: pass.fragmentShaderInstructions.map((ins) =>
                ins[0] === 0 ? [0, orient(ins[1])] : ins
              )
            }
      )
    }))
  };
}

/** Translate the pinned Seed demo's GL-specific device probes to the corresponding WebGPU limits. */
export function adaptSeedCapabilities(source, id) {
  if (id.endsWith("/farming/PlanningFarmGrassOverlay.ts")) {
    // The same atlas layout and uploads apply on both backends. Query the active device's 2D limit.
    const query =
      /    const canvas = [^\n]+\n    const context = canvas\.getContext\("webgl2"\)[^\n]+\n    if \(!context\) throw new Error\("Farm ground appearance requires WebGL2"\);\n    this\.maximumTextureSize = Number\(context\.getParameter\(context\.MAX_TEXTURE_SIZE\)\);/;
    if (!query.test(source)) throw Error("Cannot locate the Seed farm atlas texture limit.");
    return source.replace(
      query,
      "    this.maximumTextureSize = scene.engine._hardwareRenderer.capability.maxTextureSize;"
    );
  }
  if (id.endsWith("/core/src/shader/Shader.ts")) {
    const marker = "const subShaderList = data.subShaders.map";
    if (source.split(marker).length !== 2) throw Error("Cannot locate Seed compiled shader loading.");
    return source.replace(marker, "data = (" + orientSeedScreenSpaceInstructions.toString() + ")(data);\n" + marker);
  }
  if (id.endsWith("/building/runtime/BrickPackKernel.ts")) {
    // The PBO path publishes four RGBA32UI texels per computed brick. Preserve that byte layout in the same GPU command stream.
    const start = source.indexOf("function uploadGlBufferToTexture(");
    const end = source.indexOf("\n}", start);
    if (start < 0 || end < 0) throw Error("Cannot locate the Seed brick buffer-to-texture transfer.");
    const copy = `function uploadGlBufferToTexture(engine, buffer, texture, count) {
      const encoder = engine._hardwareRenderer._getCommandEncoder();
      const platform = texture._platformTexture;
      const width = texture.width, stride = width * 16;
      const texels = count * 4, rows = Math.floor(texels / width), rest = texels % width;
      const gpuBuffer = buffer._gpuBuffer;
      if (rows && stride % 256 === 0) {
        encoder.copyBufferToTexture({ buffer: gpuBuffer, bytesPerRow: stride }, { texture: platform._gpuTexture }, [width, rows]);
      } else {
        for (let y = 0; y < rows; y++) {
          encoder.copyBufferToTexture({ buffer: gpuBuffer, offset: y * stride }, { texture: platform._gpuTexture, origin: [0, y] }, [width, 1]);
        }
      }
      if (rest) encoder.copyBufferToTexture({ buffer: gpuBuffer, offset: rows * stride }, { texture: platform._gpuTexture, origin: [0, rows] }, [rest, 1]);
      buffer._markUsed(0, texels * 16);
      platform._invalidatePixels();
    }`;
    return (source.slice(0, start) + copy + source.slice(end + 2)).replace(/(\._platformBuffer)\s*\._glBuffer/g, "$1");
  }
  if (id.endsWith("/world-planning/src/runtime/SeedWorldTerrainRuntime.ts")) {
    // Seed packs and resamples imported RGBA8 layers synchronously during publication.
    // Acquire the same pixels at its existing asynchronous barrier before constructing the clipmap.
    const layers = "const layers = buildLayerSources(fields, surfaceIntent, soilTexture, surface);";
    if (source.split(layers).length !== 2) throw Error("Cannot locate terrain layer preparation.");
    return source.replace(
      layers,
      layers +
        `
      const textures = new Set(layers.flatMap(region => region.layers.flatMap(layer =>
        [layer.diffuse, layer.normal, layer.mask].filter(Boolean))));
      await Promise.all(Array.from(textures, texture => texture.makePixelBufferReadable()));
      signal?.throwIfAborted();`
    );
  }
  if (id.endsWith("/terrain/lighting/TerrainIBLProfiler.ts")) {
    // The optional IBL stage timers have a built-in "extension-unavailable" result.
    return source
      .replaceAll("this._gl.isContextLost()", "this._gl?.isContextLost()")
      .replace("this._gl.getExtension(", "this._gl?.getExtension(");
  }
  if (id.endsWith("/asset-assembly/ProceduralTreeLeafGpuData.ts")) {
    return source.replace(
      "const context = webGl2Context(engine);\n    const maximumTextureSize = Number(context.getParameter(context.MAX_TEXTURE_SIZE));",
      "const maximumTextureSize = engine._hardwareRenderer.device.limits.maxTextureDimension2D;"
    );
  }
  if (id.endsWith("/terrain/clipmap/TerrainClipmapMaterial.ts")) {
    return source
      .replace(
        /  const nativeCanvas = [^\n]+\n  const context = [^\n]+\n  if \(!context\) throw new Error\("Geometry Clipmap height rendering requires WebGL2"\);/,
        "  const limits = engine._hardwareRenderer.device.limits;"
      )
      .replace("Number(context.getParameter(context.MAX_TEXTURE_SIZE))", "limits.maxTextureDimension2D")
      .replace("Number(context.getParameter(context.MAX_ARRAY_TEXTURE_LAYERS))", "limits.maxTextureArrayLayers");
  }
  if (id.endsWith("/water/runtime/river/RiverLocalMapTextureFactory.ts")) {
    return source.replace(
      /  const canvas = [^\n]+\n  const gl = [^\n]+\n  const maximum = [^\n]+/,
      "  const maximum = engine._hardwareRenderer.device.limits.maxTextureDimension2D;"
    );
  }
}
