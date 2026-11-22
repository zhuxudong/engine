"""Apply the baked WGSL catalog to a prepared copy of the pinned Seed fixture."""

import argparse
from hashlib import sha256
import json
from pathlib import Path
from tempfile import NamedTemporaryFile


TERRAIN = Path("packages/terrain/src/data/seed-world")
PROJECT = TERRAIN / "project.json"
CONVERSION = Path("packages/water/src/water/native/assets/conversion.json")


def digest(data):
    return sha256(data).hexdigest()


def compact(value):
    return json.dumps(value, separators=(",", ":"), ensure_ascii=False).encode()


def formatted(value):
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode()


def concrete_passes(shader):
    return [item for sub in shader["subShaders"] for item in sub["passes"] if not item.get("isUsePass")]


def patch_water(path, data, shaders, manifest_hashes):
    """Update all consumers of the water profiles' content-addressed shader files."""
    if path == PROJECT:
        changes = [manifest_hashes, *((old, new) for old, (new, size) in shaders.items())]
        for old, new in changes:
            data = data.replace(old.encode(), new.encode())
        return data

    records = json.loads(data)
    if path == CONVERSION:
        for record in records:
            old = record.get("sha256")
            if old in shaders:
                new, size = shaders[old]
                record.update(source=record["source"].replace(old, new), sha256=new, byteLength=size)
    else:
        for profile in records["profiles"]:
            old = profile["artifactSha256"]
            new, size = shaders[old]
            profile.update(path=profile["path"].replace(old, new), cacheKey=new, artifactSha256=new, artifactBytes=size)
        records["budgets"]["actualTotalArtifactBytes"] = sum(p["artifactBytes"] for p in records["profiles"])
        records["additionalCompiledTargets"] = ["wgsl"]
    return formatted(records)


def add_wgsl(data, asset, catalog_dir):
    shader = json.loads(data)
    passes = concrete_passes(shader)
    if len(passes) != len(asset["passes"]):
        raise ValueError(f'Pass count changed for {shader["name"]}')
    for item, baked in zip(passes, asset["passes"]):
        if item["name"] != baked["name"] or "wgsl" in item:
            raise ValueError(f'Unexpected source pass {item["name"]} in {shader["name"]}')
        wgsl = baked["wgsl"].copy()
        for stage in ("vertex", "fragment"):
            wgsl[stage] = (catalog_dir / wgsl[stage]).read_bytes().decode()
        item["wgsl"] = wgsl
    return compact(shader)


def stage(root, catalog_dir):
    catalog = json.loads((catalog_dir / "catalog.json").read_bytes())
    shaders = {a["source"]: (a["published"], a["bytes"]) for a in catalog["shaders"]}
    manifest = catalog["water"][0]
    manifest_hashes = (manifest["source"], manifest["published"])
    writes = {}
    removals = []

    def prepare(path, old, new, transform):
        source = root / path
        target = root / str(path).replace(old, new)
        # Reruns accept verified outputs, including a retry after publishing a renamed file.
        if target.exists():
            current = target.read_bytes()
            current_hash = digest(current)
            if current_hash == new:
                if target != source and source.exists():
                    if digest(source.read_bytes()) != old:
                        raise ValueError(f"Unexpected contents in {source}")
                    removals.append(source)
                return
            if target != source or current_hash != old:
                raise ValueError(f"Unexpected contents in {target}")
        data = source.read_bytes()
        if digest(data) != old:
            raise ValueError(f"Unexpected contents in {source}")
        result = transform(data)
        if digest(result) != new:
            raise ValueError(f"Output hash mismatch for {target}")
        writes[target] = result
        if source != target:
            removals.append(source)

    for asset in catalog["shaders"]:
        for path in asset["paths"]:
            prepare(path, asset["source"], asset["published"], lambda data: add_wgsl(data, asset, catalog_dir))
    for item in catalog["water"]:
        path = Path(item["path"])
        prepare(path, item["source"], item["published"], lambda data: patch_water(path, data, shaders, manifest_hashes))

    # All source/output hashes have been checked. Publish new names before removing old ones.
    for path, data in writes.items():
        with NamedTemporaryFile(dir=path.parent, delete=False) as temp:
            temp.write(data)
        tmp = Path(temp.name)
        tmp.chmod(0o644)
        tmp.replace(path)
    for path in removals:
        path.unlink()
    files = sum(len(a["paths"]) for a in catalog["shaders"])
    print(f"Verified {files} Seed shader assets and {len(catalog['water'])} water metadata files.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fixture", type=Path)
    stage(parser.parse_args().fixture.resolve(), Path(__file__).resolve().parent)
