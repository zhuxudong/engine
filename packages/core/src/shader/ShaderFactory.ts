import { Matrix, Vector2, Vector3, Vector4 } from "@galacean/engine-math";
import type { IShaderReflection, IShaderUniformReflection } from "@galacean/engine-design";
import { Logger } from "../base/Logger";
import { Engine } from "../Engine";
import { Renderer } from "../Renderer";
import { ConstantBufferBindingPoint } from "./enums/ConstantBufferBindingPoint";
import { ShaderDataGroup } from "./enums/ShaderDataGroup";
import { ShaderBlockProperty } from "./ShaderBlockProperty";
import { ShaderProperty } from "./ShaderProperty";

/**
 * Shader registry and GLSL utilities. Holds the `#include` lookup table
 * the runtime preprocessor reads, the GLSL ES 100 → 300 syntax converter
 * the WebGL2 path uses, and the GPU-instancing UBO injector that
 * `ShaderPass` runs over compiled GLSL source.
 */
export class ShaderFactory {
  static readonly RENDERER_INSTANCE_BLOCK_NAME = "RendererInstanceData";

  static readonly uniformBlockBindingMap: Record<number, number> = {
    [ShaderBlockProperty.getByName(ShaderFactory.RENDERER_INSTANCE_BLOCK_NAME)._uniqueId]:
      ConstantBufferBindingPoint.RendererInstance
  };

  static readonly includeMap: Record<string, string> = {};

  static readonly shaderExtension = [
    "GL_EXT_shader_texture_lod",
    "GL_OES_standard_derivatives",
    "GL_EXT_draw_buffers",
    "GL_EXT_frag_depth"
  ]
    .map((e) => `#extension ${e} : enable\n`)
    .join("");

  private static readonly _std140TypeInfoMap: Record<string, { size: number; align: number }> = {
    float: { size: 4, align: 4 },
    int: { size: 4, align: 4 },
    uint: { size: 4, align: 4 },
    bool: { size: 4, align: 4 },
    vec2: { size: 8, align: 8 },
    ivec2: { size: 8, align: 8 },
    uvec2: { size: 8, align: 8 },
    bvec2: { size: 8, align: 8 },
    vec3: { size: 12, align: 16 },
    ivec3: { size: 12, align: 16 },
    uvec3: { size: 12, align: 16 },
    bvec3: { size: 12, align: 16 },
    vec4: { size: 16, align: 16 },
    ivec4: { size: 16, align: 16 },
    uvec4: { size: 16, align: 16 },
    bvec4: { size: 16, align: 16 },
    mat4: { size: 64, align: 16 },
    mat3x4: { size: 48, align: 16 }
  };

  // [layout(location = 0)] out [highp] vec4 [color];
  private static readonly _has300OutInFragReg = /\bout\s+(?:\w+\s+)?vec4\s+\w+\s*;/;

  // Derived built-ins re-exposed on top of `renderer_ModelMat`.
  // `renderer_NormalMat` uses the cofactor (cross-product) form, which algebraically equals
  // `det(M) · transpose(inverse(M))`. After `normalize()` it's directionally identical to the
  // classic `transpose(inverse(M))`, but stays NaN-free when `M` is singular (e.g. any scale
  // axis is 0 — common in animations that pop / hide via scale). `sign(det)` (`s` below)
  // keeps mirrored matrices facing the right way
  private static readonly _derivedDefines = `\
mat3 _normalMatFromModel(mat3 m) {
    vec3 c0 = cross(m[1], m[2]);
    vec3 c1 = cross(m[2], m[0]);
    vec3 c2 = cross(m[0], m[1]);
    float s = (dot(m[0], c0) < 0.0) ? -1.0 : 1.0;
    return mat3(c0 * s, c1 * s, c2 * s);
}
#define renderer_MVMat (camera_ViewMat * renderer_ModelMat)
#define renderer_MVPMat (camera_VPMat * renderer_ModelMat)
#define renderer_NormalMat mat4(_normalMatFromModel(mat3(renderer_ModelMat)))`;

  // Built-in renderer uniforms. value=true means derived (remove but not added to UBO)
  // NOTE: keep this in sync with _derivedDefines / _cameraMatrixCandidates above.
  private static readonly _builtinRendererUniforms: Record<string, boolean> = {
    renderer_ModelMat: false,
    renderer_Layer: false,
    renderer_MVMat: true,
    renderer_MVPMat: true,
    renderer_NormalMat: true
  };

  // Camera matrices the derived defines reference; declared on demand because
  // shader-compiler DCE may have stripped them from Transform.glsl.
  // NOTE: keep this in sync with _derivedDefines above.
  private static readonly _cameraMatrixCandidates: ReadonlyArray<string> = ["camera_ViewMat", "camera_VPMat"];

  private static readonly _uboUniformRegex =
    /^[ \t]*uniform\s+(?:(?:lowp|mediump|highp)\s+)?(\w+)\s+(\w+)\s*(\[.+?\])?\s*;/gm;

  private static _packFuncMap: Record<string, InstancePackFunc> = (() => {
    const packScalar = (v: Float32Array | Int32Array, o: number, val: number) => {
      v[o] = val;
    };
    const packVec2 = (v: Float32Array | Int32Array, o: number, val: Vector2) => {
      v[o] = val.x;
      v[o + 1] = val.y;
    };
    const packVec3 = (v: Float32Array | Int32Array, o: number, val: Vector3) => {
      v[o] = val.x;
      v[o + 1] = val.y;
      v[o + 2] = val.z;
    };
    const packVec4 = (v: Float32Array | Int32Array, o: number, val: Vector4) => {
      v[o] = val.x;
      v[o + 1] = val.y;
      v[o + 2] = val.z;
      v[o + 3] = val.w;
    };
    return {
      float: packScalar,
      int: packScalar,
      uint: packScalar,
      bool: packScalar,
      vec2: packVec2,
      ivec2: packVec2,
      uvec2: packVec2,
      bvec2: packVec2,
      vec3: packVec3,
      ivec3: packVec3,
      uvec3: packVec3,
      bvec3: packVec3,
      vec4: packVec4,
      ivec4: packVec4,
      uvec4: packVec4,
      bvec4: packVec4,
      mat4: (v: Float32Array | Int32Array, o: number, val: Matrix) => {
        const e = val.elements;
        for (let k = 0; k < 16; k++) v[o + k] = e[k];
      },
      // Affine mat4 stored as mat3x4: write 3 transposed rows (row3 is always 0,0,0,1)
      mat3x4: (v: Float32Array | Int32Array, o: number, val: Matrix) => {
        const e = val.elements;
        v[o] = e[0];
        v[o + 1] = e[4];
        v[o + 2] = e[8];
        v[o + 3] = e[12];
        v[o + 4] = e[1];
        v[o + 5] = e[5];
        v[o + 6] = e[9];
        v[o + 7] = e[13];
        v[o + 8] = e[2];
        v[o + 9] = e[6];
        v[o + 10] = e[10];
        v[o + 11] = e[14];
      }
    };
  })();

  /**
   * Register a chunk source so `#include` resolves it.
   * @param includeName - The path key referenced in `#include "..."`.
   * @param includeSource - GLSL chunk source text.
   */
  static registerInclude(includeName: string, includeSource: string): void {
    if (ShaderFactory.includeMap[includeName]) {
      throw `The "${includeName}" shader include already exist`;
    }
    ShaderFactory.includeMap[includeName] = includeSource;
  }

  /**
   * Remove a registered shader chunk.
   * @param includeName - The path key passed to `registerInclude`.
   */
  static unRegisterInclude(includeName: string): void {
    delete ShaderFactory.includeMap[includeName];
  }

  /**
   * Convert lower GLSL version to GLSL 300 es.
   * @param shader - code
   * @param isFrag - Whether it is a fragment shader.
   */
  static convertTo300(shader: string, isFrag?: boolean): string {
    shader = shader.replace(/\bvarying\b/g, isFrag ? "in" : "out");
    shader = shader.replace(/\btexture(2D|Cube)\b/g, "texture");
    shader = shader.replace(/\btexture2DProj\b/g, "textureProj");
    shader = shader.replace(/\btexture(2D|Cube)LodEXT\b/g, "textureLod");
    shader = shader.replace(/\btexture(2D|Cube)GradEXT\b/g, "textureGrad");
    shader = shader.replace(/\btexture2DProjLodEXT\b/g, "textureProjLod");
    shader = shader.replace(/\btexture2DProjGradEXT\b/g, "textureProjGrad");

    if (isFrag) {
      shader = shader.replace(/\bgl_FragDepthEXT\b/g, "gl_FragDepth");

      if (!ShaderFactory._has300OutInFragReg.test(shader)) {
        const isMRT = /\bgl_FragData\[.+?\]/g.test(shader);
        if (isMRT) {
          shader = shader.replace(/\bgl_FragColor\b/g, "gl_FragData[0]");
          const result = shader.match(/\bgl_FragData\[.+?\]/g);
          shader = ShaderFactory._replaceMRTShader(shader, result);
        } else {
          shader = "out vec4 glFragColor;\n" + shader;
          shader = shader.replace(/\bgl_FragColor\b/g, "glFragColor");
        }
      }
    } else {
      shader = shader.replace(/\battribute\b/g, "in");
    }

    return shader;
  }

  /**
   * Scan VS/FS for renderer-group `uniform` declarations, replace them with a shared
   * std140 UBO (instanced array), and emit `#define` remapping so original uniform
   * names resolve to `rendererData[instanceID].field`.
   *
   * Inputs are expected to be already preprocessor-evaluated (no `#ifdef` left).
   */
  static injectInstanceUBO(
    engine: Engine,
    vertexSource: string,
    fragmentSource: string
  ): { vertexSource: string; fragmentSource: string; instanceLayout: InstanceBufferLayout | null } {
    const fieldMap: Record<number, string> = Object.create(null);
    vertexSource = ShaderFactory._scanInstanceUniforms(vertexSource, fieldMap);
    fragmentSource = ShaderFactory._scanInstanceUniforms(fragmentSource, fieldMap);

    // Even when fieldMap is empty, derived built-ins (e.g. `renderer_MVPMat`) may have
    // had their declarations stripped by scan and still need a `#define` to compile
    const instanceLayout = ShaderFactory._buildLayout(engine, fieldMap);

    const { instanceFields } = instanceLayout;
    const uboDecl = ShaderFactory._buildUBODeclaration(instanceLayout);
    const fieldDefinesVS = ShaderFactory._buildFieldDefines(instanceFields, "gl_InstanceID");
    const fieldDefinesFS = ShaderFactory._buildFieldDefines(instanceFields, "v_instanceID");
    const derivedDefines = ShaderFactory._derivedDefines;
    const vsCameraDecls = ShaderFactory._buildMissingCameraDecls(vertexSource);
    const fsCameraDecls = ShaderFactory._buildMissingCameraDecls(fragmentSource);

    const vsBlock = `${uboDecl}flat out int v_instanceID;\n${vsCameraDecls}${fieldDefinesVS}\n${derivedDefines}\n`;
    const fsBlock = `${uboDecl}flat in int v_instanceID;\n${fsCameraDecls}${fieldDefinesFS}\n${derivedDefines}\n`;

    vertexSource = vsBlock + vertexSource;
    vertexSource = vertexSource.replace(
      /void\s+main\s*\(\s*\)\s*\{/,
      "void main() {\n    v_instanceID = gl_InstanceID;"
    );
    fragmentSource = fsBlock + fragmentSource;

    return { vertexSource, fragmentSource, instanceLayout };
  }

  /**
   * Inject the WebGPU renderer-instance uniform block into generated WGSL.
   * @param engine - Owning engine.
   * @param vertexSource - Macro-resolved WGSL vertex source.
   * @param fragmentSource - Macro-resolved WGSL fragment source.
   * @param reflection - Macro-resolved ShaderLab reflection.
   * @returns Rewritten WGSL, filtered reflection, and instance packing layout.
   * @internal
   */
  static injectInstanceWGSL(
    engine: Engine,
    vertexSource: string,
    fragmentSource: string,
    reflection: IShaderReflection
  ): {
    vertexSource: string;
    fragmentSource: string;
    reflection: IShaderReflection;
    instanceLayout: InstanceBufferLayout;
  } {
    const fieldMap: Record<number, string> = Object.create(null);
    const instanceUniforms = new Map<string, IShaderUniformReflection>();
    const derivedUniforms = ShaderFactory._builtinRendererUniforms;

    for (const uniform of reflection.uniforms) {
      const name = uniform.name;
      const derived = derivedUniforms[name];
      const isRendererUniform =
        derived !== undefined || ShaderProperty._getShaderPropertyGroup(name) === ShaderDataGroup.Renderer;
      if (!isRendererUniform) {
        continue;
      }
      instanceUniforms.set(name, uniform);
      if (!derived) {
        const storageType =
          name === "renderer_ModelMat" ? "mat3x4" : ShaderFactory._wgslInstanceStorageType(uniform.type);
        if (!storageType) {
          throw new Error(
            `WebGPU GPU instancing does not support renderer uniform "${name}" of type "${uniform.type}".`
          );
        }
        fieldMap[ShaderProperty.getByName(name)._uniqueId] = storageType;
      }
    }

    const instanceLayout = ShaderFactory._buildLayout(engine, fieldMap);
    const location = ShaderFactory._nextWGSLVaryingLocation(vertexSource, fragmentSource);
    const declaration = ShaderFactory._buildWGSLInstanceDeclaration(instanceLayout);
    vertexSource = ShaderFactory._rewriteWGSLInstanceUniforms(vertexSource, instanceUniforms, true, location);
    fragmentSource = ShaderFactory._rewriteWGSLInstanceUniforms(fragmentSource, instanceUniforms, false, location);

    return {
      vertexSource: `${declaration}\n${vertexSource}`,
      fragmentSource: `${declaration}\n${fragmentSource}`,
      reflection: {
        ...reflection,
        uniforms: reflection.uniforms.filter((uniform) => !instanceUniforms.has(uniform.name))
      },
      instanceLayout
    };
  }

  private static _scanInstanceUniforms(source: string, fieldMap: Record<number, string>): string {
    const builtinUniforms = ShaderFactory._builtinRendererUniforms;
    const std140Map = ShaderFactory._std140TypeInfoMap;
    return source.replace(ShaderFactory._uboUniformRegex, (match, type, name, arraySize) => {
      if (type.includes("sampler")) return match;
      const isDerived = builtinUniforms[name];
      if (isDerived === undefined && ShaderProperty._getShaderPropertyGroup(name) !== ShaderDataGroup.Renderer)
        return match;
      if (isDerived) return "";
      if (arraySize) {
        Logger.error(`GPU Instancing does not support array uniform "${name}${arraySize}"`);
        return match;
      }
      // ModelMat is affine, stored as mat3x4 (3 columns) to save 16 bytes per instance
      const storageType = type === "mat4" && name === "renderer_ModelMat" ? "mat3x4" : type;
      if (!std140Map[storageType]) {
        Logger.error(`GPU Instancing does not support uniform "${name}" of type "${type}"`);
        return match;
      }
      fieldMap[ShaderProperty.getByName(name)._uniqueId] = storageType;
      return "";
    });
  }

  private static _wgslInstanceStorageType(type: string): string | undefined {
    return (
      {
        f32: "float",
        i32: "int",
        u32: "uint",
        bool: "bool",
        "vec2<f32>": "vec2",
        "vec3<f32>": "vec3",
        "vec4<f32>": "vec4",
        "vec2<i32>": "ivec2",
        "vec3<i32>": "ivec3",
        "vec4<i32>": "ivec4",
        "vec2<u32>": "uvec2",
        "vec3<u32>": "uvec3",
        "vec4<u32>": "uvec4",
        "mat4x4<f32>": "mat4"
      } as Record<string, string>
    )[type];
  }

  private static _buildLayout(engine: Engine, fieldMap: Record<number, string>): InstanceBufferLayout {
    const maxUBOSize = engine._hardwareRenderer.maxUniformBlockSize;
    const std140Map = ShaderFactory._std140TypeInfoMap;
    const instanceFields: InstanceFieldInfo[] = [];
    let currentOffset = 0;

    const packFuncMap = ShaderFactory._packFuncMap;
    const addField = (id: number): void => {
      const type = fieldMap[id];
      // Unsupported types are filtered out in `_scanInstanceUniforms` with a clear error;
      // this only triggers if the scan/build contract is violated
      const info = std140Map[type];
      if (!info) return;
      currentOffset = Math.ceil(currentOffset / info.align) * info.align;
      instanceFields.push({
        property: ShaderProperty._propertyIdMap[id],
        type,
        offset: currentOffset,
        offsetInElements: currentOffset / 4,
        useIntView: type[0] === "i" || type[0] === "u" || type[0] === "b",
        pack: packFuncMap[type]
      });
      currentOffset += info.size;
    };

    // renderer_ModelMat is always required: derived defines reference it, so
    // even shaders that never declared the plain uniform need it in the UBO.
    const modelMatId = Renderer._worldMatrixProperty._uniqueId;
    const layerId = Renderer._rendererLayerProperty._uniqueId;
    if (!(modelMatId in fieldMap)) fieldMap[modelMatId] = "mat3x4";

    // Priority order: ModelMat first, Layer second, rest by property id.
    addField(modelMatId);
    if (layerId in fieldMap) addField(layerId);
    const keys: number[] = [];
    for (const k in fieldMap) {
      const id = +k;
      if (id !== modelMatId && id !== layerId) keys.push(id);
    }
    keys.sort((a, b) => a - b);
    for (let i = 0; i < keys.length; i++) addField(keys[i]);

    const structSize = Math.ceil(currentOffset / 16) * 16;
    const instanceMaxCount = Math.floor(maxUBOSize / structSize);

    return { instanceFields, instanceMaxCount, structSize };
  }

  private static _buildMissingCameraDecls(source: string): string {
    let out = "";
    const candidates = ShaderFactory._cameraMatrixCandidates;
    for (let i = 0; i < candidates.length; i++) {
      const name = candidates[i];
      const decl = new RegExp(`^\\s*uniform\\s+(?:(?:lowp|mediump|highp)\\s+)?mat4\\s+${name}\\s*;`, "m");
      if (!decl.test(source)) {
        out += `uniform mat4 ${name};\n`;
      }
    }
    return out;
  }

  private static _buildUBODeclaration(layout: InstanceBufferLayout): string {
    const { instanceFields, instanceMaxCount } = layout;
    const structLines: string[] = [];
    for (let i = 0; i < instanceFields.length; i++) {
      const { type, property } = instanceFields[i];
      structLines.push(`        ${type} ${property.name};`);
    }
    return (
      `#define INSTANCE_MAX_COUNT ${instanceMaxCount}\n` +
      `struct RendererInstanceStruct {\n${structLines.join("\n")}\n};\n` +
      `layout(std140) uniform ${ShaderFactory.RENDERER_INSTANCE_BLOCK_NAME} {\n` +
      `    RendererInstanceStruct rendererData[INSTANCE_MAX_COUNT];\n};\n`
    );
  }

  private static _buildWGSLInstanceDeclaration(layout: InstanceBufferLayout): string {
    const fields = layout.instanceFields.map(({ type, property }) => {
      const wgslType = (
        {
          float: "f32",
          int: "i32",
          uint: "u32",
          bool: "u32",
          vec2: "vec2<f32>",
          ivec2: "vec2<i32>",
          uvec2: "vec2<u32>",
          bvec2: "vec2<u32>",
          vec3: "vec3<f32>",
          ivec3: "vec3<i32>",
          uvec3: "vec3<u32>",
          bvec3: "vec3<u32>",
          vec4: "vec4<f32>",
          ivec4: "vec4<i32>",
          uvec4: "vec4<u32>",
          bvec4: "vec4<u32>",
          mat4: "mat4x4<f32>",
          mat3x4: "mat3x4<f32>"
        } as Record<string, string>
      )[type];
      if (!wgslType) {
        throw new Error(`WebGPU GPU instancing has no WGSL storage type for "${type}".`);
      }
      return `  ${property.name}: ${wgslType},`;
    });
    return `struct GSRendererInstance {
${fields.join("\n")}
}
struct GSRendererInstanceBlock {
  rendererData: array<GSRendererInstance, ${layout.instanceMaxCount}>,
}
@group(1) @binding(0) var<uniform> gsRendererInstances: GSRendererInstanceBlock;

fn gs_rendererModelMatrix() -> mat4x4<f32> {
  let model = gsRendererInstances.rendererData[u32(_gsInstanceIndex)].renderer_ModelMat;
  return mat4x4<f32>(
    vec4<f32>(model[0].x, model[1].x, model[2].x, 0.0),
    vec4<f32>(model[0].y, model[1].y, model[2].y, 0.0),
    vec4<f32>(model[0].z, model[1].z, model[2].z, 0.0),
    vec4<f32>(model[0].w, model[1].w, model[2].w, 1.0)
  );
}

fn gs_rendererNormalMatrix() -> mat4x4<f32> {
  let model = gs_rendererModelMatrix();
  let matrix = mat3x3<f32>(model[0].xyz, model[1].xyz, model[2].xyz);
  let c0 = cross(matrix[1], matrix[2]);
  let c1 = cross(matrix[2], matrix[0]);
  let c2 = cross(matrix[0], matrix[1]);
  let direction = select(1.0, -1.0, dot(matrix[0], c0) < 0.0);
  return mat4x4<f32>(
    vec4<f32>(c0 * direction, 0.0),
    vec4<f32>(c1 * direction, 0.0),
    vec4<f32>(c2 * direction, 0.0),
    vec4<f32>(0.0, 0.0, 0.0, 1.0)
  );
}`;
  }

  private static _rewriteWGSLInstanceUniforms(
    source: string,
    uniforms: ReadonlyMap<string, IShaderUniformReflection>,
    vertex: boolean,
    varyingLocation: number
  ): string {
    for (const name of uniforms.keys()) {
      source = source.replace(new RegExp(`^\\s*${ShaderFactory._escapeRegExp(name)}\\s*:[^\\n]+\\n?`, "m"), "");
    }
    source = source.replace(
      /struct GSUniforms\s*\{\s*\}\s*@group\(0\)\s*@binding\(0\)\s*var<uniform>\s+gsUniforms:\s*GSUniforms;\s*/,
      ""
    );

    for (const [name] of uniforms) {
      const access =
        name === "renderer_ModelMat"
          ? "gs_rendererModelMatrix()"
          : name === "renderer_MVMat"
            ? "(gsUniforms.camera_ViewMat * gs_rendererModelMatrix())"
            : name === "renderer_MVPMat"
              ? "(gsUniforms.camera_VPMat * gs_rendererModelMatrix())"
              : name === "renderer_NormalMat"
                ? "gs_rendererNormalMatrix()"
                : `gsRendererInstances.rendererData[u32(_gsInstanceIndex)].${name}`;
      source = source.replace(new RegExp(`\\bgsUniforms\\.${ShaderFactory._escapeRegExp(name)}\\b`, "g"), access);
    }

    if (vertex) {
      if (!source.includes("@builtin(instance_index) instanceIndex: u32")) {
        source = source.replace(
          "struct GSVertexInput {",
          "struct GSVertexInput {\n  @builtin(instance_index) instanceIndex: u32,"
        );
      }
      if (!source.includes("var<private> _gsInstanceIndex: i32;")) {
        source = `var<private> _gsInstanceIndex: i32;\n${source}`;
      }
      source = source.replace(
        "struct GSVertexOutput {",
        `struct GSVertexOutput {\n  @location(${varyingLocation}) @interpolate(flat) gsInstanceIndex: u32,`
      );
      if (!source.includes("_gsInstanceIndex = i32(input.instanceIndex);")) {
        source = source.replace(
          /(^|\n)(\s*)gs_vertexEntry\(\);/,
          "$1$2_gsInstanceIndex = i32(input.instanceIndex);\n$2gs_vertexEntry();"
        );
      }
      source = source.replace(
        /(^|\n)(\s*)var output: GSVertexOutput;/,
        "$1$2var output: GSVertexOutput;\n$2output.gsInstanceIndex = input.instanceIndex;"
      );
    } else {
      if (!source.includes("var<private> _gsInstanceIndex: i32;")) {
        source = `var<private> _gsInstanceIndex: i32;\n${source}`;
      }
      source = source.replace(
        "struct GSFragmentInput {",
        `struct GSFragmentInput {\n  @location(${varyingLocation}) @interpolate(flat) gsInstanceIndex: u32,`
      );
      source = source.replace(
        /(^|\n)(\s*)gs_fragmentEntry\(\);/,
        "$1$2_gsInstanceIndex = i32(input.gsInstanceIndex);\n$2gs_fragmentEntry();"
      );
    }
    return source;
  }

  private static _nextWGSLVaryingLocation(...sources: string[]): number {
    let maxLocation = -1;
    for (const source of sources) {
      for (const match of source.matchAll(/@location\((\d+)\)/g)) {
        maxLocation = Math.max(maxLocation, Number(match[1]));
      }
    }
    return maxLocation + 1;
  }

  private static _escapeRegExp(value: string): string {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  private static _buildFieldDefines(fields: InstanceFieldInfo[], idExpr: string): string {
    const accessor = `rendererData[${idExpr}]`;
    const lines: string[] = [];
    for (let i = 0; i < fields.length; i++) {
      const { type, property } = fields[i];
      const n = property.name;
      if (type === "mat3x4") {
        const m = `${accessor}.${n}`;
        lines.push(
          `#define ${n} mat4(` +
            `vec4(${m}[0].x,${m}[1].x,${m}[2].x,0.0),` +
            `vec4(${m}[0].y,${m}[1].y,${m}[2].y,0.0),` +
            `vec4(${m}[0].z,${m}[1].z,${m}[2].z,0.0),` +
            `vec4(${m}[0].w,${m}[1].w,${m}[2].w,1.0))`
        );
      } else {
        lines.push(`#define ${n} ${accessor}.${n}`);
      }
    }
    return lines.join("\n");
  }

  private static _replaceMRTShader(shader: string, result: string[]): string {
    let declaration = "";
    const mrtIndexSet = new Set();

    for (let i = 0; i < result.length; i++) {
      const res = result[i].match(/\bgl_FragData\[(.+?)\]/);
      mrtIndexSet.add(res[1]);
    }

    mrtIndexSet.forEach((index) => {
      declaration += `layout(location=${index}) out vec4 fragOutColor${index};\n`;
    });
    declaration += `void main(`;

    shader = shader.replace(/\bgl_FragData\[(.+?)\]/g, "fragOutColor$1");

    shader = shader.replace(/void\s+?main\s*\(/g, declaration);
    return shader;
  }
}

/**
 * @internal
 */
export interface InstanceFieldInfo {
  property: ShaderProperty;
  type: string;
  offset: number;
  /** offset / 4, precomputed to avoid repeated division in upload loop */
  offsetInElements: number;
  useIntView: boolean;
  pack: InstancePackFunc;
}

/**
 * @internal
 */
export interface InstanceBufferLayout {
  instanceFields: InstanceFieldInfo[];
  instanceMaxCount: number;
  structSize: number;
}

type InstancePackFunc = (view: Float32Array | Int32Array, offset: number, value: any) => void;
