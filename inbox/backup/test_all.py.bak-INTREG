#!/usr/bin/env python3
"""
test_all.py - run the small single-feature test registry and aggregate results.

Why: the 29-step monolithic self-test could only be edited by one worker and
could only report one verdict. Each feature now owns one test script in
app/tests/ with its own result JSON, so many agents can author tests in
parallel without touching each other's files.

Usage:
  python app/tools/test_all.py --list
  python app/tools/test_all.py --only t_upgrades t_squads
  python app/tools/test_all.py                    # all status=ready tests
  python app/tools/test_all.py --include-pending  # also attempt not-yet-landed tests

Every Godot launch goes through godot_runner.py (FIFO lock + hard timeout).
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "app" / "tests" / "manifest.json"
RESULTS = ROOT / "app" / "tests" / "results"
RUNNER = ROOT / "app" / "tools" / "godot_runner.py"


def load_manifest() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def run_one(test: dict) -> dict:
    tid = test["id"]
    timeout = float(test.get("timeout", 60))
    windowed = bool(test.get("windowed", False))
    argv = [sys.executable, str(RUNNER), "run", "--id", f"manifest-{tid}",
            "--timeout", str(timeout + 30), "--"]
    argv += ([] if windowed else ["--headless"])
    argv += ["--path", "app", "--script", test["path"]]
    if windowed:
        argv += ["--timeout", str(timeout)]
    started = time.time()
    proc = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True,
                          timeout=timeout + 300)
    result_file = RESULTS / f"{tid}.json"
    payload = None
    if result_file.exists():
        try:
            payload = json.loads(result_file.read_text(encoding="utf-8"))
        except ValueError:
            pass
    if payload is None:
        payload = {"id": tid, "passed": False,
                   "checks": [{"name": "result-json", "passed": False,
                               "detail": "no result JSON written"}],
                   "runner_stdout": proc.stdout[-2000:],
                   "runner_stderr": proc.stderr[-2000:]}
    payload["runner_exit"] = proc.returncode
    payload["wall"] = round(time.time() - started, 2)
    return payload


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--only", nargs="+")
    ap.add_argument("--include-pending", action="store_true")
    ns = ap.parse_args()

    data = load_manifest()
    tests = data["tests"]
    if ns.list:
        for t in tests:
            print(f"{t['id']:<22} {t['status']:<8} {t['feature']}")
        return 0

    chosen = [t for t in tests
              if (ns.only is None or t["id"] in ns.only)
              and (ns.include_pending or t["status"] == "ready")]
    if not chosen:
        print("no tests selected")
        return 2

    RESULTS.mkdir(parents=True, exist_ok=True)
    results = []
    for t in chosen:
        print(f"[test_all] {t['id']} ...", flush=True)
        results.append(run_one(t))

    summary = {"generated": time.time(), "count": len(results),
               "passed": sum(1 for r in results if r.get("passed")),
               "failed": sum(1 for r in results if not r.get("passed")),
               "results": results}
    (RESULTS / "summary.json").write_text(json.dumps(summary, indent=2),
                                          encoding="utf-8")
    for r in results:
        flag = "PASS" if r.get("passed") else "FAIL"
        print(f"{flag:<4} {r['id']:<22} {r.get('wall')}s")
        for c in r.get("checks", []):
            if not c.get("passed"):
                print(f"       - {c.get('name')}: {c.get('detail','')}")
    print(f"\n{summary['passed']}/{summary['count']} passed -> "
          f"{RESULTS / 'summary.json'}")
    return 0 if summary["failed"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
