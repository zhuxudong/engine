#!/usr/bin/env python3
"""Export Mac Metal System Trace activity and intersect native busy intervals with individual Seed frame windows."""
import argparse
import bisect
import collections
import datetime
import gzip
import shutil
import json
import math
import os
from pathlib import Path
import re
import statistics
import subprocess
import xml.etree.ElementTree as ET


def rows(file, columns):
    """Resolve Instruments' interned XML values, including process IDs first defined in a nested column."""
    stored = {}
    tags = {"start-time", "duration", "process", "gpu-channel-name", "thermal-state", "metal-nesting-level", "gpu-state"}
    keys = []
    node = None
    stream = gzip.open(file, "rb") if file.suffix == ".gz" else file.open("rb")
    for event, elem in ET.iterparse(stream, events=("start", "end")):
        if event == "start":
            if elem.tag == "node":
                node = elem
            continue
        if elem.tag == "schema":
            keys = [c.findtext("mnemonic") for c in elem.findall("col")]
            if not set(columns).issubset(keys):
                raise ValueError(f"Missing columns in {file}: {set(columns).difference(keys)}")
        if elem.tag in tags and elem.get("id"):
            stored[elem.get("id")] = (elem.text or "", elem.get("fmt") or elem.text or "")
        if elem.tag == "row":
            values = {}
            for key, e in zip(keys, elem):
                if key in columns:
                    values[key] = stored[e.get("ref")] if e.get("ref") else (e.text or "", e.get("fmt") or e.text or "")
            yield values
            if node is not None:
                node.remove(elem)
    stream.close()


def merge(spans):
    out = []
    for a, b in sorted(spans):
        if out and a <= out[-1][1]:
            out[-1][1] = max(out[-1][1], b)
        else:
            out.append([a, b])
    return out


def bucket(merged, edges):
    out = [0] * (len(edges) - 1)
    for a, b in merged:
        if a >= edges[-1]:
            break
        if b <= edges[0]:
            continue
        i = max(0, bisect.bisect_right(edges, a) - 1)
        while i < len(out) and edges[i] < b:
            out[i] += max(0, min(edges[i+1], b) - max(edges[i], a))
            i += 1
    return out


def samples(ns):
    v = sorted(x / 1e6 for x in ns)
    if not v:
        return {"frames": 0, "meanMs": None, "medianMs": None, "p90Ms": None,
                "p99Ms": None, "nonzero": 0}
    def q(frac):
        x = frac * (len(v) - 1)
        i, c = math.floor(x), x % 1
        return round(v[i] * (1-c) + v[math.ceil(x)] * c, 5)
    return {"frames": len(v), "meanMs": round(statistics.mean(v), 5), "medianMs": q(.5), "p90Ms": q(.9),
            "p99Ms": q(.99), "nonzero": sum(n > 0 for n in ns)}


def origin_and_duration(toc, expected_pid=None, expected_device=None):
    run = ET.parse(toc).find(".//run")
    info = run.find("info")
    if info is None:
        raise ValueError("Trace lacks a run info section")
    target = info.find("target")
    device = target.find("device")
    if device is None or device.get("platform") != "macOS":
        raise ValueError("The trace did not target the local desktop Mac")
    if expected_device and device.get("uuid", "").lower() != expected_device.lower():
        raise ValueError("Recorded Mac UUID differs from the capture host")
    if expected_pid is not None and not any(p.get("pid") == str(expected_pid) and p.get("type") == "attached"
                                           for p in target.findall("process")):
        raise ValueError("Recorded process differs from the browser GPU process")
    origin = datetime.datetime.fromisoformat(info.findtext("summary/start-date")).timestamp() * 1000
    return origin, float(info.findtext("summary/duration")) * 1e9


def channels(xml, pid, lo, hi):
    spans = collections.defaultdict(list)
    for r in rows(xml, ["process", "state", "start", "duration", "event-depth", "channel-name"]):
        if not r["process"][1].endswith("(" + str(pid) + ")") or r["state"][1] != "Active":
            continue
        a = int(r["start"][0])
        b = a + int(r["duration"][0])
        if lo < b and a < hi:
            spans[(r["event-depth"][1], r["channel-name"][1])].append((a, b))
    if not spans:
        raise ValueError(f"No attributed native Active GPU intervals for PID {pid}")
    return spans


def export(group, developer, compress=False):
    trace = group / "gpu.trace"
    reg = {**os.environ, "DEVELOPER_DIR": developer}
    names = ["toc", "metal-gpu-intervals", "device-thermal-state-intervals"]
    outputs = {}
    for name in names:
        file = group / (name + ".xml")
        if compress and name != "toc" and not file.exists():
            file = file.with_suffix(".xml.gz")
        outputs[name] = file
        if file.exists() and file.stat().st_size:
            continue
        tmp = file.with_suffix(".partial.xml")
        selector = ["--toc"] if name == "toc" else ["--xpath", f'/trace-toc/run[@number="1"]/data/table[@schema="{name}"]']
        command = ["/usr/bin/xcrun", "xctrace", "export", "--input", str(trace), *selector]
        if file.suffix == ".gz":
            with gzip.open(tmp, "wb", compresslevel=2) as output, subprocess.Popen(command, env=reg, stdout=subprocess.PIPE) as proc:
                shutil.copyfileobj(proc.stdout, output, length=1024*1024)
                if proc.wait() != 0:
                    raise RuntimeError(f"Could not export {name}")
        else:
            with tmp.open("wb") as f:
                subprocess.run(command, env=reg, stdout=f, check=True)
        tmp.replace(file)
    return outputs


def trace_report(directory, metadata, group, compress=False):
    base = directory / group["id"]
    xml = export(base, metadata["developer"], compress)
    group_pid = json.loads((base / f"0-{group['order'][0]}.json").read_text())["gpuPid"]
    if group_pid not in metadata.get("sessionPids", [metadata["gpuPid"]]):
        raise ValueError("Unrecognized local capture session")
    origin, duration = origin_and_duration(xml["toc"], group_pid, metadata.get("localDevice"))
    windows = []
    for i, backend in enumerate(group["order"]):
        file = base / f"{i}-{backend}.json"
        record = json.loads(file.read_text())
        work = record["benchmark"]
        if (record["gpuPid"] != group_pid or work["backend"] != backend or work["template"] != group["template"]
            or work["variant"] != group["variant"] or work["seed"] != metadata["seed"] or work["frames"] != metadata["frames"]
            or work["width"] != metadata["width"] or work["height"] != metadata["height"]
            or record["errors"] or record["validation"] or work["webglErrors"]):
            raise ValueError(f"Unexpected workload or rendering error in {file}")
        edges = [round((x - origin) * 1e6) for x in work["frameBoundariesEpochMs"]]
        if len(edges) != work["frames"]+1 or any(b <= a for a,b in zip(edges, edges[1:])) or edges[0] < 0 or edges[-1] > duration:
            raise ValueError(f"Invalid frame window against the actual trace duration: {file}")
        if windows and edges[0] <= windows[-1][1][-1]:
            raise ValueError("Overlapping workload windows")
        windows.append((work, edges))
    lo, hi = windows[0][1][0], windows[-1][1][-1]
    spans = channels(xml["metal-gpu-intervals"], group_pid, lo, hi)
    all_active = merge([s for per in spans.values() for s in per])
    depth0 = merge([s for (level,_), per in spans.items() if level == "0" for s in per])
    by_channel = {name: merge([s for (_, n), per in spans.items() if n == name for s in per]) for _, name in spans}
    thermals = [(int(r["start"][0]),int(r["end"][0]),r["thermal-state"][1]) for r in
                rows(xml["device-thermal-state-intervals"], ["start", "end", "thermal-state"])]
    report = []
    for work, edges in windows:
        ns = bucket(all_active, edges)
        if not any(ns):
            raise ValueError("Workload contains no native busy GPU activity")
        inspected = {q["frame"] for q in work["inspections"]}
        interior = [n for i,n in enumerate(ns) if i not in inspected and i-1 not in inspected and i not in (0,len(ns)-1)]
        rec = {"group":group["id"],"template":group["template"],"variant":group["variant"],"repetition":group["repetition"],
               "order":group["order"],"backend":work["backend"],"processId":group_pid,"clockAnchorEpochMs":origin,
               "windowTraceNs":[edges[0],edges[-1]],"nativeBusy":samples(ns),"nativeBusyInterior":samples(interior),
               "activeFraction":round(sum(ns)/(edges[-1]-edges[0]),6),"rootOnly":samples(bucket(depth0,edges)),
               "channels":{k:samples(bucket(v,edges)) for k,v in by_channel.items()},"busyNsByFrame":ns,
               "thermalStates":sorted({st for a,b,st in thermals if a<edges[-1] and edges[0]<b}),
               "frameInterval":work["frameIntervalMs"],"cpu":work["cpuUpdateMs"],"hash":work["hash"],"usedPath":work["usedPath"],
               "checkPointDraws":[i["drawCalls"] for i in work["inspections"]]}
        report.append(rec)
    return report


def self_test():
    # Three hardware stages overlap, and intervals straddle both ends of the captured frame range.
    per_stage = [[(-4, 4), (10, 14)], [(2, 9), (19, 21)], [(5, 9), (14, 17), (23, 30)]]
    active = merge([interval for stage in per_stage for interval in stage])
    assert active == [[-4, 9], [10, 17], [19, 21], [23, 30]]
    assert bucket(active, [0, 7, 10, 20, 25]) == [7, 2, 8, 3]
    assert sum(bucket(active, [30, 31, 32])) == 0
    assert samples([])["frames"] == 0
    print("Native interval union, frame boundaries and empty sample checks passed.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("directory", type=Path)
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--compress-exports", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        return self_test()
    manifest = json.loads((args.directory/"manifest.json").read_text())
    workloads = []
    for group in manifest["groups"]:
        workloads.extend(trace_report(args.directory, manifest, group, args.compress_exports))
    comparisons = []
    for template, variant in sorted({(w["template"],w["variant"]) for w in workloads}):
        selection = [w for w in workloads if w["template"] == template and w["variant"] == variant]
        runs = []
        for rep in sorted({w["repetition"] for w in selection}):
            gl, gpu = [next(w for w in selection if w["repetition"] == rep and w["backend"] == b) for b in ("webgl2","webgpu")]
            for left, right in zip(gl["usedPath"], gpu["usedPath"], strict=True):
                if (left["frame"] != right["frame"]
                    or max(abs(a-b) for a,b in zip(left["position"],right["position"])) > 0.002
                    or max(abs((a-b+180)%360-180) for a,b in zip(left["rotation"],right["rotation"])) > 0.002):
                    raise ValueError("Native comparison camera paths differ")
            a,b = gl["nativeBusy"]["meanMs"],gpu["nativeBusy"]["meanMs"]
            runs.append({"order":gl["order"],"webgl2MeanMs":a,"webgpuMeanMs":b,"differenceMs":round(b-a,5),
                         "webgpuVsWebgl2Percent":round(100*(b/a-1),2)})
        comparisons.append({"template":template,"variant":variant,"pairs":runs,
                            "meanOfPairedDifferencesMs":round(statistics.mean(r["differenceMs"] for r in runs),5)})
    ablations=[]
    for current in workloads:
        if current["variant"] == "full": continue
        baseline = next((w for w in workloads if w["variant"] == "full" and w["template"] == current["template"]
                         and w["backend"] == current["backend"] and w["repetition"] == current["repetition"]),None)
        if baseline:
            full = baseline["nativeBusy"]["meanMs"]
            reduced = current["nativeBusy"]["meanMs"]
            ablations.append({"template":current["template"],"backend":current["backend"],"variant":current["variant"],
                              "fullMs":full,"ablatedMs":reduced,"fullMinusAblatedMs":round(full-reduced,5),
                              "fractionOfFullPercent":round(100*(full-reduced)/full,2)})
    result={"method":"Union of local Chromium GPU-process Active Metal hardware intervals, intersected with native requestAnimationFrame epoch boundaries. Warmup excluded. Channels may overlap.",
            "interior":"Excludes inspection frames, their immediate successors and both end frames.",
            "workloads":workloads,"comparisons":comparisons,"ablations":ablations}
    (args.directory/"native-busy.json").write_text(json.dumps(result,indent=2)+"\n")
    print(json.dumps(comparisons,indent=2))

if __name__ == "__main__":
    main()
