#!/usr/bin/env python3
"""Land (nowater2) terrain-sample harness - thin profile over terrain_sample_shot.py.

Reuses the scan/capture/validation logic of ``terrain_sample_shot.py`` unchanged,
but redirects every artefact to ``terrain_land*`` and every Godot job id to the
unique ``tbb0-land-*`` namespace. Nothing here launches Godot directly; all
runs go through app/tools/godot_runner.py.

Usage (from the project root)::

    python app/tools/terrain_land_shot.py --scan
    python app/tools/terrain_land_shot.py --capture --seed 20261113
    python app/tools/terrain_land_shot.py --validate-only
"""
from __future__ import annotations

import argparse
import base64
import importlib.util
import json
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location("terrain_sample_shot", TOOLS / "terrain_sample_shot.py")
base = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(base)

# ---- distinct paths / seeds / job namespace --------------------------------
base.CONFIG_REL = "shots/terrain_land.json"
base.CONFIG_PATH = base.SHOTS / "terrain_land.json"
base.PNG_REL = "shots/terrain_land.png"
base.PNG_PATH = base.SHOTS / "terrain_land.png"
base.DUMP_REL = "shots/terrain_land_seedscan_{seed}.json"
base.SCAN_REPORT = base.SHOTS / "terrain_land_seedscan.json"
base.BEST_FILE = base.SHOTS / "terrain_land_seedscan_best.json"
base.CANDIDATE_SEEDS = (9, 7, 20261113, 20261114)


def _land_run_job(job_id: str, args: list[str]) -> dict:
    if not job_id.startswith("tbb0-land-"):
        job_id = job_id.replace("tbb0-", "tbb0-land-", 1)
    return _original_run_job(job_id, args)


_original_run_job = base.run_job
base.run_job = _land_run_job


def _print_reference(seed: int) -> None:
    print("=" * 78)
    print("land (nowater2) runner commands - all ids in tbb0-land-* namespace")
    print("=" * 78)
    for candidate in base.CANDIDATE_SEEDS:
        base.print_runner_command("tbb0-land-128-seed-%d" % candidate,
                                  base.scan_godot_args(candidate))
    base.print_runner_command("tbb0-land-128-capture", base.capture_godot_args(seed))
    print("-" * 78)


base.print_reference_commands = _print_reference


# ---- land-specific seed choice ---------------------------------------------
def _land_choose_seed(records: list[dict]) -> tuple[dict | None, str]:
    """Highest forest count, with rock>0, and a land (non-water) centre cell."""
    for r in records:
        try:
            data = json.loads((base.APP / base.DUMP_REL.format(seed=r["seed"]))
                              .read_text(encoding="utf-8"))
            raw = base64.b64decode(data.get("terrain", ""))
            w, h = int(data["map_w"]), int(data["map_h"])
            r["centre_xy"] = [w // 2, h // 2]
            r["centre_code"] = (raw[(h // 2) * w + (w // 2)]
                                if len(raw) == w * h else None)
        except (OSError, ValueError, KeyError, TypeError) as exc:
            r["centre_code"] = None
            r["centre_error"] = repr(exc)

    scored = [r for r in records if r.get("counts")]
    if not scored:
        return None, "no usable dump - cannot choose a seed"
    land = [r for r in scored if r.get("centre_code") not in (None, 3)]
    rocky = [r for r in land if r["counts"].get("rock", 0) > 0]
    pool = rocky or land or scored
    best = max(pool, key=lambda r: (r["counts"].get("forest", 0),
                                    r["counts"].get("rock", 0)))
    reason = ("highest forest count with rock>0 and land centre cell "
              "(centre_code=%s, forest=%d, rock=%d)" % (
                  best.get("centre_code"),
                  best["counts"].get("forest", 0),
                  best["counts"].get("rock", 0)))
    return best, reason


base.choose_seed = _land_choose_seed


def print_centres() -> None:
    report = json.loads(base.SCAN_REPORT.read_text(encoding="utf-8"))
    print("\n[land] centre-cell check (terrain code 3 = water):")
    for r in report["records"]:
        counts = r.get("counts") or {}
        xy = r.get("centre_xy") or [None, None]
        print("  seed %-10s centre=(%s,%s) code=%s  forest=%-5s rock=%-4s water=%-5s "
              "mask=%s" % (
                  r["seed"], xy[0], xy[1],
                  r.get("centre_code"), counts.get("forest"), counts.get("rock"),
                  counts.get("water"), r.get("mask_file")))
    print("[land] chosen seed: %s (%s)" % (
        report["chosen_seed"], report["chosen_reason"]))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--scan", action="store_true", help="headless dump-map seed scan")
    ap.add_argument("--capture", action="store_true", help="windowed real-renderer capture")
    ap.add_argument("--seed", type=int, default=None, help="capture seed (default: config)")
    ap.add_argument("--validate-only", action="store_true",
                    help="re-validate the existing PNG without running Godot")
    args = ap.parse_args(argv)

    seed = args.seed if args.seed is not None else base.config_seed()
    _print_reference(seed)

    rc = 0
    if args.scan:
        rc |= base.do_scan(len(base.CANDIDATE_SEEDS))
        print_centres()
    if args.capture:
        rc |= base.do_capture(seed)
    if args.validate_only:
        report = base.validate_png({"id": "n/a (validate-only)", "status": "ok"},
                                   skip_log_check=True)
        rc |= 0 if report["real_renderer_gate"] else 1
    if not (args.scan or args.capture or args.validate_only):
        print("No action requested: pass --scan and/or --capture --seed S.")
    return rc


if __name__ == "__main__":
    sys.exit(main())
