#!/usr/bin/env python3
"""Capture/verify harness for the Wave-6 G3-2 heightmap 3D sandbox.

Pure Python + the shared runner. This file NEVER launches Godot itself: every
Godot launch goes through ``app/tools/godot_runner.py run --id g33-*``.

Two modes
---------
* verify only (default): measure an existing ``app/shots/hm3d_*.png`` with
  Pillow and print an honest, concise verdict. No Godot involved.
* ``--submit``: check G3-2's sandbox has landed, submit ONE capture job through
  the runner with a unique ``g33-*`` id, wait for it, then verify the PNG.

The sandbox (G3-2's ``heightmap3d_sandbox.gd``) captures itself after ~30
rendered frames; this tool only documents/validates the runner command and the
resulting image. It does not edit the 3D world.

Usage
-----
  python app/tools/heightmap3d_shot.py                       # verify existing shot
  python app/tools/heightmap3d_shot.py --submit              # submit capture + verify
  python app/tools/heightmap3d_shot.py --submit --id g33-hm3d-shot2 --timeout 180
  python app/tools/heightmap3d_shot.py --shot app/shots/hm3d_full.png --json app/shots/hm3d_full.json
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
RUNNER = ROOT / "app" / "tools" / "godot_runner.py"
SHOTS = ROOT / "app" / "shots"

DEFAULT_SHOT = SHOTS / "hm3d_full.png"
DEFAULT_STATS = SHOTS / "hm3d_full.json"
SANDBOX_GD = ROOT / "app" / "scripts" / "heightmap3d_sandbox.gd"
SANDBOX_SCENE_REL = "res://scenes/heightmap3d_sandbox.tscn"
SANDBOX_SCRIPT_REL = "res://scripts/heightmap3d_sandbox.gd"
SANDBOX_SCENE = ROOT / "app" / "scenes" / "heightmap3d_sandbox.tscn"

DONOR = Path(r"C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg")
M06_SHOT = SHOTS / "terrain3d_m06.png"          # documented M0.6 block heightfield

# Pillow-only image stats (no numpy dependency; keeps the tool portable).
_QUANT = 32  # rgb bucket size -> 8x8x8 colour histogram


def luma_hist(img: Image.Image) -> list[int]:
    """256-bin luminance histogram using the ITU-R 601 coefficients."""
    g = img.convert("L")  # Pillow's L ~= 0.299R + 0.587G + 0.114B
    return g.histogram()


def measure(path: Path) -> dict | None:
    """MEASURED stats for one image, or None if it does not exist / cannot open."""
    if not path.exists():
        return None
    try:
        with Image.open(path) as im:
            rgb = im.convert("RGB")
    except Exception as exc:  # noqa: BLE001 - corrupt/partial file is data
        return {"error": f"cannot open: {exc!r}", "path": str(path)}

    w, h = rgb.size
    n = max(w * h, 1)
    hist = luma_hist(rgb)
    mean_luma = sum(i * c for i, c in enumerate(hist)) / n
    var = sum(((i - mean_luma) ** 2) * c for i, c in enumerate(hist)) / n
    std_luma = var ** 0.5
    mode_luma = max(range(256), key=lambda i: hist[i])
    # Non-blank = luminance differs from the modal (background) tone by > 8.
    nonblank = sum(c for i, c in enumerate(hist) if abs(i - mode_luma) > 8) / n

    # Rough colour distribution: quantised RGB buckets, top 6 by share.
    q = rgb.quantize(colors=256, method=Image.Quantize.MEDIANCUT).convert("RGB")
    buckets: dict[tuple[int, int, int], int] = {}
    for r, g, b in q.getdata():
        key = (r // _QUANT, g // _QUANT, b // _QUANT)
        buckets[key] = buckets.get(key, 0) + 1
    top = sorted(buckets.items(), key=lambda kv: -kv[1])[:6]
    dist = [
        {
            "rgb_lo": [k[0] * _QUANT, k[1] * _QUANT, k[2] * _QUANT],
            "share": round(v / n, 4),
        }
        for k, v in top
    ]
    # Green dominance: a crude proxy for vegetation vs bare block mosaic.
    small = rgb.resize((min(w, 320), min(h, 180)))
    px = list(small.getdata())
    greenish = sum(1 for r, g, b in px if g > r and g > b) / max(len(px), 1)

    return {
        "path": str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path),
        "size": f"{w}x{h}",
        "mean_luma": round(mean_luma, 2),
        "stddev_luma": round(std_luma, 2),
        "mode_luma": mode_luma,
        "nonblank_fraction": round(nonblank, 4),
        "occupied_colour_buckets": len(buckets),
        "greenish_fraction": round(greenish, 4),
        "top_colours": dist,
    }


def candidate_shots(explicit: Path) -> list[Path]:
    """Explicit path first, then any app/shots/hm3d_*.png, then the default name."""
    out = [explicit]
    if explicit != DEFAULT_SHOT:
        out.append(DEFAULT_SHOT)
    out.extend(sorted(SHOTS.glob("hm3d_*.png")))
    seen: set[Path] = set()
    return [p for p in out if not (p in seen or seen.add(p))]


def submit_capture(job_id: str, timeout: float, headless: bool) -> tuple[int, str]:
    """Submit ONE capture job via the runner. Returns (returncode, combined tail)."""
    if not SANDBOX_GD.exists():
        print(f"[submit] PENDING: G3-2 sandbox not landed ({SANDBOX_GD})")
        return 2, ""
    target = SANDBOX_SCENE_REL if SANDBOX_SCENE.exists() else SANDBOX_SCRIPT_REL
    cmd = [sys.executable, str(RUNNER.relative_to(ROOT)), "run",
           "--id", job_id, "--timeout", str(int(timeout)), "--"]
    if headless:
        cmd.append("--headless")
    cmd += ["--path", "app", target]

    if target == SANDBOX_SCRIPT_REL:
        cmd.append("--script")
        # --script belongs before the path; rebuild cleanly for the script case.
        cmd = [sys.executable, str(RUNNER.relative_to(ROOT)), "run",
               "--id", job_id, "--timeout", str(int(timeout)), "--"]
        if headless:
            cmd.append("--headless")
        cmd += ["--path", "app", "--script", SANDBOX_SCRIPT_REL]

    print("[submit] runner: " + " ".join(cmd))
    try:
        proc = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True,
                              timeout=timeout + 30)
        tail = (proc.stdout + "\n" + proc.stderr).strip()[-1500:]
        return proc.returncode, tail
    except subprocess.TimeoutExpired as exc:
        return -9, f"runner call itself timed out: {exc!r}"


def heuristic_closer(donor: dict, a: dict, b: dict) -> str:
    """Heuristic distance in a tiny feature space. NOT proof of visual fidelity.

    Lower distance = numerically closer to the donor's coarse statistics.
    """
    keys = ("mean_luma", "stddev_luma", "greenish_fraction", "nonblank_fraction")
    def dist(m: dict) -> float:
        return sum(abs(float(m.get(k, 0)) - float(donor.get(k, 0))) for k in keys)
    da, db = dist(a), dist(b)
    if da < db:
        return f"NEW (hm3d) numerically closer: {da:.2f} < {db:.2f}"
    if da > db:
        return f"M0.6 numerically closer: {db:.2f} < {da:.2f}"
    return f"tie ({da:.2f})"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--shot", type=Path, default=DEFAULT_SHOT)
    ap.add_argument("--json", type=Path, default=DEFAULT_STATS,
                    help="where to write MEASURED stats (one of my owned hm3d_*.json)")
    ap.add_argument("--submit", action="store_true",
                    help="submit ONE capture job via godot_runner.py before verifying")
    ap.add_argument("--id", default="g33-hm3d-shot", help="unique runner job id (g33-*)")
    ap.add_argument("--timeout", type=float, default=120.0, help="runner hard timeout (s)")
    ap.add_argument("--no-headless", action="store_true",
                    help="launch with a window instead of --headless")
    ap.add_argument("--donor", type=Path, default=DONOR)
    args = ap.parse_args()

    if not str(args.id).startswith("g33-"):
        print(f"[id] refusing non-g33 job id: {args.id}", file=sys.stderr)
        return 2

    if args.submit:
        rc, tail = submit_capture(args.id, args.timeout, not args.no_headless)
        print(f"[submit] runner exit={rc}")
        if tail:
            print("[submit] runner tail:\n" + tail)

    shot = None
    for p in candidate_shots(args.shot):
        if p.exists():
            shot = p
            break
    if shot is None:
        print(f"VERDICT PENDING: no hm3d_*.png shot yet (looked for {args.shot}). "
              f"G3-2 sandbox landed={SANDBOX_GD.exists()}")
        return 2

    cur = measure(shot)
    print(f"[shot] {json.dumps(cur)}")
    if cur is None or "error" in cur:
        print("VERDICT UNVERIFIED: shot could not be measured")
        return 1

    w, h = (int(x) for x in cur["size"].split("x"))
    size_ok = (w == 1280 and h == 720)
    nonblank_ok = (cur["nonblank_fraction"] >= 0.05 and cur["stddev_luma"] >= 10.0)
    basic_ok = size_ok and nonblank_ok

    donor = measure(args.donor)
    m06 = measure(M06_SHOT)
    if donor:
        print(f"[donor] {json.dumps(donor)}")
    if m06:
        print(f"[m0.6 ] {json.dumps(m06)}")

    closer = "UNVERIFIED (donor or M0.6 missing)"
    if donor and m06:
        closer = heuristic_closer(donor, cur, m06)
        print(f"[compare] donor-vs-baseline heuristic: {closer}")

    stats = {
        "shot": cur,
        "donor": donor,
        "m06_block_heightfield": m06,
        "heuristic_closer": closer,
        "basic_ok": basic_ok,
        "limits": [
            "headless capture (software renderer, not a windowed donor-like frame)",
            "no units/trees/buildings/HUD/fog in the sandbox",
            "camera FOV UNVERIFIED (donor sensor constant unknown)",
            "heuristic distance is coarse statistics only, not a perceptual metric",
        ],
    }
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(stats, indent=2), encoding="utf-8")
    print(f"[stats] wrote {args.json.relative_to(ROOT)}")

    verdict = "PASS" if basic_ok else "FAIL"
    print(f"VERDICT image={verdict} size_ok={size_ok} nonblank_ok={nonblank_ok} "
          f"(semantic compare still needs human review; see report)")
    return 0 if basic_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
