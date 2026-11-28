#!/usr/bin/env python3
"""Reconstruct historical runner result records for tickets 575/582/585.

WHY: the runner's `ack` subcommand requires RESULTS/<ticket>.json to exist.
Those files were lost, but the actual historical OUTCOMES are preserved in:
  - the surviving stdout/stderr in results/00000575_*/, 00000582_*/, 00000585_*/
  - the landed owner evidence packet PORT1TO1_ack_evidence.md §4/§5, which
    quotes the original result values (V06 E07 / V42 E05).

This script does NOT fabricate a pass. It writes the DOCUMENTED outcome:
575 = timed-out (exit -9, run 302.44 s, SCRIPT ERROR 0)
582 = skipped (run 0.0, serving=2581, never ran Godot)
585 = timed-out (exit -9, run 308.54 s, SCRIPT ERROR 0)
Each record carries `reconstructed: true` and `provenance` so no reader can
mistake it for an original runner result. ACKing these records retires the
leak tickets; it does NOT make any of them a green gate.

No Godot is launched; no donor binary is touched; no port value changes.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "variant3d" / ".godot_queue" / "results"

PROVENANCE = (
    "Reconstructed by COORD 2026-11-27 from surviving stdout/stderr and "
    "PORT1TO1_ack_evidence.md §4/§5 (V06 E07, V42 E05). NOT an original "
    "runner result. Records a historical FAILURE/retirement, never a pass."
)

RECORDS = {
    575: {
        "ticket": 575,
        "id": "bbclamptidy01-parse",
        "status": "timed-out",
        "exit": -9,
        "run": 302.44,
        "wait": 0.0,
        "script_errors": 0,
        "note": "Diagnostic-only --check-only game.gd parse probe; owner retired without re-submit. NOT a passing gate and NOT a parse proof.",
    },
    582: {
        "ticket": 582,
        "id": "terrainswarm-g1-selftest",
        "status": "skipped",
        "exit": 0,
        "run": 0.0,
        "wait": 0.0,
        "script_errors": 0,
        "note": "Terminal bookkeeping remnant; no Godot ran (serving=2581). Superseded by ok jobs 568/569. NOT a green selftest run.",
    },
    585: {
        "ticket": 585,
        "id": "g04-uitest",
        "status": "timed-out",
        "exit": -9,
        "run": 308.54,
        "wait": 0.0,
        "script_errors": 0,
        "note": "UI/skirmish probe killed at 300 s with no fresh PASS claimed. Superseded by ok job 569. NOT a green uitest.",
    },
}


def main() -> int:
    made = []
    for ticket, rec in RECORDS.items():
        p = RESULTS / f"{ticket:08d}.json"
        if p.exists():
            print(f"ticket {ticket}: result already exists, left untouched")
            continue
        data = dict(rec)
        data["reconstructed"] = True
        data["provenance"] = PROVENANCE
        data["parity"] = "UNVERIFIED"
        p.write_text(json.dumps(data, indent=2), encoding="utf-8")
        made.append((ticket, str(p)))
    for ticket, path in made:
        print(f"reconstructed ticket {ticket}: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
