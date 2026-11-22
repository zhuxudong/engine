"""Extract portable WGSL additions from a freshly re-exported set of Seed shaderc files."""

import argparse
import json
from pathlib import Path
import re

from stage import CONVERSION, PROJECT, TERRAIN, compact, concrete_passes, digest, formatted, patch_water


def generate(fixture, published, output):
    assets = {}
    modules = {}
    for file in sorted(published.rglob("*.shaderc")):
        path = file.relative_to(published)
        source = (fixture / path).read_bytes()
        old = digest(source)
        data = file.read_bytes()
        new = digest(data)
        if old in assets:
            if new != assets[old]["published"]:
                raise ValueError(f"Different WGSL produced for the same source at {path}")
            assets[old]["paths"].append(path.as_posix())
            continue

        after = json.loads(data)
        shader_dir = next(i for i, part in enumerate(path.parts) if part in ("Shader", "Shaders"))
        directory = Path("modules", path.parts[1], *path.parts[shader_dir + 1 : -1])
        basename = re.sub(r"\.[0-9a-f]{64}$", "", path.stem)
        passes = []
        for item in concrete_passes(after):
            wgsl = item.pop("wgsl")
            for stage in ("vertex", "fragment"):
                code = wgsl[stage]
                if code not in modules:
                    name = directory / f"{basename}.{item['name']}.{stage}.wgsl"
                    target = output / name
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_bytes(code.encode())
                    modules[code] = name.as_posix()
                wgsl[stage] = modules[code]
            passes.append({"name": item["name"], "wgsl": wgsl})
        if not passes or compact(after) != source:
            raise ValueError(f"Re-export changed original shader data in {path}")
        assets[old] = {"paths": [path.as_posix()], "source": old, "published": new, "bytes": len(data), "passes": passes}

    if len(assets) != 24 or sum(len(a["paths"]) for a in assets.values()) != 26:
        raise ValueError("Expected all 26 shaderc files from the pinned Seed build")
    water_dir = fixture / TERRAIN / "public/Shader/Water"
    (manifest_path,) = water_dir.glob("WaterAotManifest.*.json")
    shaders = {old: (asset["published"], asset["bytes"]) for old, asset in assets.items()}
    manifest_hashes = None
    water = []
    for path in (manifest_path.relative_to(fixture), PROJECT, CONVERSION):
        data = (fixture / path).read_bytes()
        old = digest(data)
        new = digest(patch_water(path, data, shaders, manifest_hashes))
        if manifest_hashes is None:
            if old not in path.name:
                raise ValueError("Water manifest name does not match its contents")
            manifest_hashes = (old, new)
        water.append({"path": path.as_posix(), "source": old, "published": new})

    (output / "catalog.json").write_bytes(formatted({"shaders": list(assets.values()), "water": water}))
    print(f"Extracted {len(assets)} distinct assets and {len(modules)} WGSL modules.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fixture", type=Path)
    parser.add_argument("published", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    generate(args.fixture, args.published, args.output)
