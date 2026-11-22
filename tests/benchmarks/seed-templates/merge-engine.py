"""Materialize the pinned Seed native overrides and the WebGPU engine outside either checkout."""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile

BASE = "e5c0df036e7c6c292ea2c411d8156f7d57601cb2"
SEED = "92ea60eaee49b2f1188b373c178c34ca511c9f87"
CANDIDATE = "35b6c4547879abc5ebc8dd267202eec1b962ceaf"
PACKAGES = [
    "core", "design", "loader", "math", "rhi-webgl", "rhi-webgpu", "rhi-null",
    "galacean", "galacean-webgpu", "physics-physx", "ui", "shader-parser", "shader-compiler",
]
ROOTS = ["packages/" + package for package in PACKAGES]


def materialize(repository, destination, patch):
    def git(*args):
        return subprocess.check_output(["git", "-C", str(repository), *args])

    def changed(revision):
        return set(git("diff", "--name-only", BASE, revision, "--", *ROOTS).decode().splitlines())

    overrides = {
        entry["original"]: entry["replacement"]
        for entry in json.loads(git("show", SEED + ":packages/modify/native-overrides.json"))
        if entry["original"].split("/")[1] in PACKAGES
    }
    changed_candidate = changed(CANDIDATE)
    paths = sorted(name for name in changed(SEED) | overrides.keys() if "/src/" in name)
    destination.mkdir(parents=True, exist_ok=True)
    if any(destination.iterdir()):
        raise ValueError("Choose an empty destination for the generated engine")
    with subprocess.Popen(["git", "-C", str(repository), "archive", CANDIDATE, *ROOTS], stdout=subprocess.PIPE) as archive:
        subprocess.run(["tar", "-xf", "-", "-C", str(destination)], stdin=archive.stdout, check=True)
        if archive.wait():
            raise RuntimeError("Could not extract the candidate")
    # Read Git objects through a single batch process so large fixtures do not spawn
    # a separate Git process for every source file.
    with subprocess.Popen(["git", "-C", str(repository), "cat-file", "--batch"],
                          stdin=subprocess.PIPE, stdout=subprocess.PIPE) as objects:
        def blob(revision, name):
            objects.stdin.write((revision + ":" + name + "\n").encode())
            objects.stdin.flush()
            header = objects.stdout.readline().split()
            if header[-1] == b"missing":
                return None
            if header[1] != b"blob":
                raise ValueError("Expected a source file at " + name)
            result = objects.stdout.read(int(header[2]))
            assert objects.stdout.read(1) == b"\n"
            return result

        with tempfile.TemporaryDirectory() as temporary:
            files = [Path(temporary) / side for side in ("candidate", "base", "seed")]
            for name in paths:
                seed = blob(SEED, overrides.get(name, name))
                if seed is None:
                    continue
                target = destination / name
                result = seed
                if name in changed_candidate:
                    current = blob(CANDIDATE, name)
                    base = blob(BASE, name)
                    if current is None or seed == current or seed == base:
                        continue
                    for file, data in zip(files, (current, base or b"", seed)):
                        file.write_bytes(data)
                    # Auto-merge disjoint edits. The checked-in patch reconciles the
                    # overlapping rendering, shader and texture behavior of both versions.
                    result = subprocess.check_output(["git", "merge-file", "-p", "--ours", *map(str, files)])
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(result)
        objects.stdin.close()
    if patch:
        subprocess.run(["git", "apply", "--no-index", "--whitespace=nowarn", str(patch)], cwd=destination, check=True)


if __name__ == "__main__":
    here = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--repository", type=Path, default=here.parents[2])
    parser.add_argument("--without-patch", action="store_true", help="materialize the unmodified three-way merge")
    args = parser.parse_args()
    materialize(args.repository.resolve(), args.destination.resolve(), None if args.without_patch else here / "seed-native.patch")
