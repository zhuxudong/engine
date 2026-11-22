"""Build both shader flavors used by the pinned Seed gallery, outside the input trees."""

import argparse
import json
from pathlib import Path
import re
import subprocess
import tempfile


BASE = "e5c0df036e7c6c292ea2c411d8156f7d57601cb2"
LIBRARY = Path("packages/shader/src")
CONFLICT = re.compile(
    r"^<<<<<<< [^\n]+\n(.*?)^\|{7} [^\n]+\n(.*?)^=======\n(.*?)^>>>>>>> [^\n]+\n", re.M | re.S
)


def merge_shader(name, ours, base, seed, scratch):
    if ours == base or not ours:
        return seed
    if seed == base or seed == ours or not seed:
        return ours
    files = [scratch / side for side in ("candidate", "base", "seed")]
    for file, data in zip(files, (ours, base, seed)):
        file.write_bytes(data)
    result = subprocess.run(["git", "merge-file", "--diff3", "-p", *files], stdout=subprocess.PIPE)
    if result.returncode == 0:
        return result.stdout

    def reconcile(match):
        current, ancestor, incoming = match.groups()
        if name.name == "Fog.glsl":
            return current + incoming[incoming.index("    #ifdef SCENE_FOG_CUSTOM_EXPONENT"):]
        if name.name == "SkyProcedural.shader":
            if "mat4 camera_VPMat" in ancestor:
                camera = '      #include "ShaderLibrary/Common/Camera.glsl"\n'
                lights = incoming[incoming.index("      #ifdef MATERIAL_SKY_MAIN_LIGHT"):]
                return camera + lights.replace("vec3 scene_SunlightDirection;", "uniform Scene { vec3 scene_SunlightDirection; };")
            return incoming
        raise ValueError("Unresolved cross-branch shader change in " + str(name))

    source, count = CONFLICT.subn(reconcile, result.stdout.decode())
    if not count or "<<<<<<<" in source:
        raise ValueError("Unexpected merge result for " + str(name))
    return source.encode()


def native_coordinates(root):
    # The camera reverses projection winding for native cube attachments. These
    # two fullscreen passes write clip coordinates directly, bypassing that camera.
    for name in ("RealtimeIBLResolve", "RealtimeIBLAccumulate"):
        file = root / "Shaders/Lighting" / (name + ".shader")
        source = file.read_text()
        line = "        gl_Position.y *= -1.0;"
        if source.count(line) != 1:
            raise ValueError("Cannot find the cube-face clip transform in " + name)
        file.write_text(source.replace(line, "        #ifndef GRAPHICS_API_WEBGPU\n" + line + "\n        #endif"))
    library = root / "ShaderLibrary/Lighting/ScreenSpaceReflection"
    common = library / "ScreenSpaceReflectionCommon.glsl"
    source = common.read_text().replace(
        "vec3 reconstructSSRViewPosition(",
        """vec2 ssrClipToTextureUV(vec4 p) {
  vec2 ndc = p.xy / p.w;
  #ifdef GRAPHICS_API_WEBGPU
    ndc.y = -ndc.y;
  #endif
  return ndc * 0.5 + 0.5;
}

vec3 reconstructSSRViewPosition("""
    ).replace(
        "vec2 ndc = uv * 2.0 - 1.0;",
        "vec2 ndc = uv * 2.0 - 1.0;\n  #ifdef GRAPHICS_API_WEBGPU\n    ndc.y = -ndc.y;\n  #endif",
    )
    common.write_text(source)
    for file in [library / "ScreenSpaceReflectionSample.glsl", root / "Shaders/Lighting/ScreenSpaceReflection.shader"]:
        source, count = re.subn(r"\b(\w+)\.xy / \1\.w \* 0.5 \+ 0.5", r"ssrClipToTextureUV(\1)", file.read_text())
        if not count:
            raise ValueError("Missing native SSR projection in " + str(file))
        file.write_text(source)
    for file in [root / "Shaders/Sky/SkyProcedural.shader", root / "ShaderLibrary/PostProcess/SunLensFlare.glsl"]:
        source = file.read_text().replace("#ifdef GRAPHICS_API_WEBGL2",
            "#if defined(GRAPHICS_API_WEBGL2) || defined(GRAPHICS_API_WEBGPU)")
        file.write_text(source.replace("texture2DLodEXT(", "textureLod("))


def prepare(fixture, candidate, merged, output):
    output.mkdir(parents=True, exist_ok=True)
    if any(output.iterdir()):
        raise ValueError("Choose an empty output directory")
    catalog = (merged / "packages/core/src/shader/BuiltinShaders.ts").read_text()
    required = set(re.findall(r"\bsources\.(\w+Source)\b", catalog))
    overrides = {
        Path(entry["original"]): fixture / entry["replacement"]
        for entry in json.loads((fixture / "packages/modify/native-overrides.json").read_text())
    }
    paths = set(overrides)
    for tree in (fixture, candidate):
        paths.update(file.relative_to(tree) for file in (tree / LIBRARY).rglob("*") if file.is_file())
    src = output / "shader-src"
    with tempfile.TemporaryDirectory(dir=output) as temp:
        for name in sorted(paths):
            if not name.is_relative_to(LIBRARY) or name.suffix not in (".shader", ".glsl"):
                continue
            current, incoming = candidate / name, overrides.get(name, fixture / name)
            ancestor = subprocess.run(["git", "-C", candidate, "show", BASE + ":" + name.as_posix()],
                                      stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            data = merge_shader(name, current.read_bytes() if current.is_file() else b"",
                                ancestor.stdout, incoming.read_bytes() if incoming.is_file() else b"", Path(temp))
            if data:
                target = src / name.relative_to(LIBRARY)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
    native_coordinates(src)
    library = [{"path": p.relative_to(src).as_posix(), "source": p.read_text()} for p in sorted(src.rglob("*.glsl"))]
    (output / "shader-library.mjs").write_text("export const shaderLibrary = " + json.dumps(library, ensure_ascii=False) + ";\n")
    header = 'export {shaderLibrary} from "./shader-library.mjs";\n'
    raw = [{"path": p.relative_to(src).as_posix(), "source": p.read_text()} for p in sorted(src.rglob("*.shader"))]
    (output / "shader-sources.mjs").write_text(header + "export const shaders=" + json.dumps(raw, ensure_ascii=False) + ";\n")
    cli = candidate / "packages/shader-compiler/bundler/cli.js"
    for flavor, target in [("webgl", "gles300"), ("webgpu", "wgsl")]:
        compiled = output / ("compiled-" + flavor)
        subprocess.run(["node", cli, src / "Shaders", compiled, "--target", target], cwd=output, check=True)
        programs = {p.stem + "Source": p.read_text() for p in sorted(compiled.rglob("*.shaderc"))}
        missing = required - programs.keys()
        if missing or len(programs) != len(raw):
            raise ValueError("Incomplete " + flavor + " catalog: " + ", ".join(sorted(missing)))
        (output / ("shaders-" + flavor + ".mjs")).write_text(header + "".join(
            f"export const {name} = {asset};\n" for name, asset in programs.items()))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("fixture", "candidate", "merged", "output"):
        parser.add_argument(name, type=lambda value: Path(value).resolve())
    args = parser.parse_args()
    prepare(args.fixture, args.candidate, args.merged, args.output)
