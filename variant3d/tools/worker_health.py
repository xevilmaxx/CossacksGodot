#!/usr/bin/env python3
"""
worker_health.py - periodic liveness check for swarm workers.

A worker is considered alive if EITHER:
  - one of its owned files was edited recently, OR
  - it produced a runner result recently, OR
  - it has a pending runner ticket (it is waiting in the FIFO, not stuck).

It is flagged STALLED only when all three are quiet for --stall-min minutes.
This is a *hint*: a worker may be reading donor files or thinking. The
coordinator then sends a short status ping, and only helps if there is a real
block (parse error, dead lock, missing API, queue wedge).

Usage:
  python app/tools/worker_health.py
  python app/tools/worker_health.py --stall-min 10 --json
"""
from __future__ import annotations

import argparse
import json
import re
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOARD = ROOT / "docs" / "SWARM_BOARD.md"
RESULTS = ROOT / "app" / ".godot_queue" / "results"
JOBS = ROOT / "app" / ".godot_queue" / "jobs"


def norm(name: str) -> str:
    return re.sub(r"[^a-z0-9]", "", name.lower())


def read_board() -> dict[str, list[Path]]:
    """owner -> owned file paths (from the board's IN_PROGRESS/DONE rows)."""
    owners: dict[str, list[str]] = {}
    text = BOARD.read_text(encoding="utf-8", errors="replace")
    for line in text.splitlines():
        if not line.startswith("| "):
            continue
        parts = [p.strip() for p in line.split("|")]
        if len(parts) < 6:
            continue
        ticket, owner, files, state = parts[1], parts[3], parts[4], parts[5]
        if not owner or owner in {"unassigned", "Owner", "---"} or owner.startswith(":"):
            continue
        if state not in {"IN_PROGRESS", "BLOCKED", "ASSIGNED"}:
            continue
        for f in re.split(r"[,/]", files):
            f = f.strip().strip("`")
            if f.endswith((".gd", ".py", ".json", ".md", ".cfg")):
                owners.setdefault(owner, []).append(f)
    out = {}
    search_dirs = (ROOT, ROOT / "app", ROOT / "app/scripts", ROOT / "app/tools",
                   ROOT / "app/tests", ROOT / "docs", ROOT / "app/assets")
    for owner, fs in owners.items():
        paths = []
        for f in set(fs):
            f = f.replace("\\", "/").lstrip("./")
            for base in search_dirs:
                p = base / f
                if p.exists():
                    paths.append(p)
                    break
        out[owner] = paths
    return out


def job_activity(prefix: str) -> tuple[float | None, int]:
    key = norm(prefix)
    latest = None
    pending = 0
    for p in RESULTS.glob("*.json"):
        try:
            d = json.loads(p.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if norm(str(d.get("id", ""))).startswith(key):
            t = p.stat().st_mtime
            latest = t if latest is None else max(latest, t)
    for p in JOBS.glob("*.json"):
        try:
            d = json.loads(p.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        if norm(str(d.get("id", ""))).startswith(key):
            pending += 1
    return latest, pending


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--stall-min", type=float, default=10.0)
    ap.add_argument("--json", action="store_true")
    ns = ap.parse_args()

    now = time.time()
    rows = []
    for owner, paths in sorted(read_board().items()):
        edits = [p.stat().st_mtime for p in paths if p.exists()]
        last_edit = max(edits) if edits else None
        last_job, pending = job_activity(owner)
        candidates = [t for t in (last_edit, last_job) if t is not None]
        last = max(candidates) if candidates else None
        quiet_min = (now - last) / 60.0 if last is not None else None
        stalled = pending == 0 and quiet_min is not None and quiet_min > ns.stall_min
        rows.append({
            "owner": owner,
            "files": len(paths),
            "last_edit_min": round((now - last_edit) / 60.0, 1) if last_edit else None,
            "last_job_min": round((now - last_job) / 60.0, 1) if last_job else None,
            "pending_jobs": pending,
            "quiet_min": round(quiet_min, 1) if quiet_min is not None else None,
            "state": "STALLED" if stalled else "ALIVE",
        })

    if ns.json:
        print(json.dumps(rows, indent=2))
    else:
        print(f"{'owner':<22} {'files':>5} {'edit_m':>7} {'job_m':>7} {'pend':>5}  state")
        for r in rows:
            print(f"{r['owner']:<22} {r['files']:>5} "
                  f"{str(r['last_edit_min']):>7} {str(r['last_job_min']):>7} "
                  f"{r['pending_jobs']:>5}  {r['state']}")
        bad = [r['owner'] for r in rows if r['state'] == 'STALLED']
        print(f"\nstalled (> {ns.stall_min} min quiet, no pending job): {bad or 'none'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
