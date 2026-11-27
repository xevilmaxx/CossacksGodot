#!/usr/bin/env python3
"""Exact donor-vs-port ROI metrics. Metrics are NOT a parity verdict.

A donor frame and a port frame are accepted ONLY with explicit provenance:
--donor, --port, --roi x,y,w,h, --roi-source (human-provided ROI metadata) and
--camera (shared camera label). Both frames must have identical dimensions;
there is no rescaling, no clamping and no inferred alignment. When two config
files are supplied their SHA-256 must match, otherwise the run is refused.

Reported: per-channel MAE / RMSE / max absolute error, hist-to-hist correlation
and intersection/chi-square, per-channel and overall Pearson pixel correlation,
and an exact absolute pixel-difference PNG (optionally amplified, labelled).

PARITY RULE: stdout ALWAYS prints `parity=UNVERIFIED`. This tool cannot verify
that a file is a genuine donor frame or that a human's A/B pairing is correct.
`--assert-ab-verified REASON` only records `claim=owner-supplied` in the
report; it never promotes the result to PASS or to donor parity.

Example:
  python variant3d/tools/acceptance/compare_frames.py \
      --donor "%TEMP%/opencode/donor_videos/selected/cZW0AEupCaI/t_600.png" \
      --port inbox/qa/captures/abrun_20261113/00_wide/frame_0060.png \
      --roi 100,100,640,360 --roi-source "manual ROI: town hall + shore, video cZW0AEupCaI t=600" \
      --camera wide --out-diff inbox/qa/captures/diff_wide.png \
      --report inbox/qa/captures/diff_wide.json
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path

from imgio import Raster, hash_file, load_rgb, save_png

ROOT = Path(__file__).resolve().parents[3]
EXIT_OK, EXIT_BAD = 0, 2
CHANNELS = ("R", "G", "B")


def parse_roi(text: str) -> tuple[int, int, int, int]:
    parts = text.split(",")
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("--roi must be x,y,w,h (four integers)")
    try:
        x, y, w, h = (int(p.strip()) for p in parts)
    except ValueError:
        raise argparse.ArgumentTypeError("--roi must be x,y,w,h (four integers)")
    if x < 0 or y < 0 or w < 1 or h < 1:
        raise argparse.ArgumentTypeError("--roi needs x,y >= 0 and w,h >= 1")
    return x, y, w, h


def pearson(n: int, sx: float, sy: float, sxy: float, sx2: float, sy2: float) -> float | None:
    num = n * sxy - sx * sy
    den2 = (n * sx2 - sx * sx) * (n * sy2 - sy * sy)
    if den2 <= 0.0:
        return None  # a flat channel has no defined correlation
    value = num / math.sqrt(den2)
    return max(-1.0, min(1.0, value))


def channel_metrics(a: bytes, b: bytes, bins: int) -> dict:
    """Exact streaming metrics for one channel; bins scales 256 values down."""
    n = len(a)
    if n != len(b) or n == 0:
        raise ValueError("channel length mismatch/empty")
    ha = [0] * bins
    hb = [0] * bins
    sum_abs = sum_sq = max_abs = 0
    sx = sy = sxy = sx2 = sy2 = 0
    differing = 0
    for va, vb in zip(a, b):
        d = abs(va - vb)
        sum_abs += d
        sum_sq += d * d
        if d > max_abs:
            max_abs = d
        if d:
            differing += 1
        ha[va * bins // 256] += 1
        hb[vb * bins // 256] += 1
        sx += va
        sy += vb
        sxy += va * vb
        sx2 += va * va
        sy2 += vb * vb
    inter = sum(min(x, y) for x, y in zip(ha, hb))
    chi = sum((x - y) ** 2 / (x + y) for x, y in zip(ha, hb) if x + y)
    return {
        "pixels": n,
        "mae": sum_abs / n,
        "rmse": math.sqrt(sum_sq / n),
        "max": max_abs,
        "differing_pixels": differing,
        "differing_fraction": differing / n,
        "hist_correlation": pearson(bins, float(sum(ha)), float(sum(hb)),
                                   float(sum(x * y for x, y in zip(ha, hb))),
                                   float(sum(x * x for x in ha)),
                                   float(sum(y * y for y in hb))),
        "hist_intersection_fraction": inter / n,
        "hist_chi_square": chi,
        "pixel_correlation": pearson(n, sx, sy, sxy, sx2, sy2),
        "histogram_donor": ha,
        "histogram_port": hb,
    }


def difference_raster(a: Raster, b: Raster, amplify: float) -> Raster:
    out = bytearray(len(a.data))
    for i, (va, vb) in enumerate(zip(a.data, b.data)):
        out[i] = min(255, int(abs(va - vb) * amplify + 0.5))
    return Raster(a.w, a.h, bytes(out))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--donor", required=True, metavar="PNG", help="donor frame (never inferred)")
    ap.add_argument("--port", required=True, metavar="PNG", help="port capture frame")
    ap.add_argument("--roi", required=True, type=parse_roi, metavar="x,y,w,h",
                    help="EXACT pixel ROI, applied identically to both frames")
    ap.add_argument("--roi-source", required=True, metavar="TEXT",
                    help="human-provided ROI provenance (metadata, mandatory)")
    ap.add_argument("--camera", required=True, metavar="NAME",
                    help="shared camera label asserted by the human (mandatory)")
    ap.add_argument("--config-donor", metavar="JSON", help="optional donor-side config")
    ap.add_argument("--config-port", metavar="JSON", help="optional port-side config")
    ap.add_argument("--out-diff", required=True, metavar="PNG",
                    help="pixel-difference image output path")
    ap.add_argument("--report", metavar="JSON", help="metrics JSON (default <out-diff>.json)")
    ap.add_argument("--hist-bins", type=int, default=16, choices=(8, 16, 32, 64, 256),
                    help="histogram bins (default 16; 256 = full byte histogram)")
    ap.add_argument("--amplify", type=float, default=1.0, metavar="FACTOR",
                    help="difference-image brightness multiplier (default 1 = exact)")
    ap.add_argument("--assert-ab-verified", metavar="REASON",
                    help="human assertion ONLY: records claim=owner-supplied; "
                         "never changes parity=UNVERIFIED")
    ns = ap.parse_args(argv)

    if len(ns.roi_source.strip()) < 10:
        ap.error("--roi-source must be real provenance text (>= 10 chars)")
    if not math.isfinite(ns.amplify) or ns.amplify < 1.0 or ns.amplify > 64.0:
        ap.error("--amplify must be a finite factor in [1, 64]")
    assertion = None
    if ns.assert_ab_verified is not None:
        if len(ns.assert_ab_verified.strip()) < 10:
            ap.error("--assert-ab-verified needs a substantive reason (>= 10 chars)")
        assertion = {
            "status": "owner-supplied",
            "reason": ns.assert_ab_verified.strip(),
            "utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "scope": "Human-supplied A/B pairing only; tool cannot verify donor identity.",
        }

    try:
        donor_path, port_path = Path(ns.donor), Path(ns.port)
        donor, port = load_rgb(donor_path), load_rgb(port_path)
        if (donor.w, donor.h) != (port.w, port.h):
            raise ValueError(
                f"refusing: donor {donor.w}x{donor.h} vs port {port.w}x{port.h} "
                "differ; identical ROI/camera requires identical resolution, "
                "no rescaling is performed")
        x, y, w, h = ns.roi
        if x + w > donor.w or y + h > donor.h:
            raise ValueError(
                f"refusing: ROI {ns.roi} outside {donor.w}x{donor.h}; no clamping")
        if ns.config_donor and ns.config_port:
            hd, hp = hash_file(ns.config_donor), hash_file(ns.config_port)
            if hd != hp:
                raise ValueError("refusing: donor/port config SHA-256 differ "
                                 f"({hd[:12]} vs {hp[:12]}); cameras are not identical")

        cropped_d, cropped_p = donor.crop((x, y, x + w, y + h)), port.crop((x, y, x + w, y + h))
        per_channel = {}
        for ci, label in enumerate(CHANNELS):
            da = bytes(cropped_d.data[ci::3])
            db = bytes(cropped_p.data[ci::3])
            per_channel[label] = channel_metrics(da, db, ns.hist_bins)

        diff = difference_raster(cropped_d, cropped_p, ns.amplify)
        out_diff = Path(ns.out_diff)
        out_diff = out_diff if out_diff.is_absolute() else (ROOT / out_diff).resolve()
        save_png(out_diff, diff)

        n = w * h
        overall = {
            "mae": sum(m["mae"] for m in per_channel.values()) / 3.0,
            "rmse": math.sqrt(sum(m["rmse"] ** 2 for m in per_channel.values()) / 3.0),
            "max": max(m["max"] for m in per_channel.values()),
            "differing_pixels_any_channel": sum(
                1 for i in range(n)
                if cropped_d.data[i * 3:i * 3 + 3] != cropped_p.data[i * 3:i * 3 + 3]),
        }
        overall["differing_fraction_any_channel"] = overall["differing_pixels_any_channel"] / n

        report = {
            "tool": "compare_frames.py",
            "schema": 1,
            "utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "donor": str(donor_path.resolve()),
            "donor_sha256_file": hash_file(donor_path),
            "port": str(port_path.resolve()),
            "port_sha256_file": hash_file(port_path),
            "frame_size": [donor.w, donor.h],
            "roi": [x, y, w, h],
            "roi_source": ns.roi_source.strip(),
            "camera": ns.camera,
            "config_donor": str(Path(ns.config_donor).resolve()) if ns.config_donor else None,
            "config_port": str(Path(ns.config_port).resolve()) if ns.config_port else None,
            "hist_bins": ns.hist_bins,
            "per_channel": per_channel,
            "overall": overall,
            "difference_image": {
                "path": str(out_diff),
                "sha256_file": hash_file(out_diff),
                "mode": "abs_diff_amplified" if ns.amplify != 1.0 else "abs_diff_exact",
                "amplify": ns.amplify,
                "size": [diff.w, diff.h],
            },
            "owner_assertion": assertion,
            "parity": "UNVERIFIED",
            "claim": "owner-supplied" if assertion else None,
            "note": ("Metrics quantify a pair of images; they cannot prove donor "
                     "identity, camera equality or visual parity. No metric alone "
                     "constitutes parity."),
        }
        report_path = Path(ns.report) if ns.report else out_diff.with_suffix(".json")
        report_path = report_path if report_path.is_absolute() else (ROOT / report_path).resolve()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    except (OSError, ValueError, RuntimeError) as exc:
        print(f"REFUSED: {exc}", file=sys.stderr)
        print("parity=UNVERIFIED", flush=True)
        return EXIT_BAD

    def fmt(value: float | None) -> str:
        return "n/a" if value is None else f"{value:.6f}"

    print(f"[compare] ROI {ns.roi} camera={ns.camera} frames={donor.w}x{donor.h}")
    for label in CHANNELS:
        m = per_channel[label]
        print(f"  {label}: MAE={m['mae']:.4f} RMSE={m['rmse']:.4f} max={m['max']} "
              f"pixel_corr={fmt(m['pixel_correlation'])} "
              f"hist_corr={fmt(m['hist_correlation'])} "
              f"hist_intersection={m['hist_intersection_fraction']:.6f} "
              f"chi2={m['hist_chi_square']:.4f}")
    print(f"  overall: MAE={overall['mae']:.4f} RMSE={overall['rmse']:.4f} "
          f"max={overall['max']} differing_px={overall['differing_pixels_any_channel']} "
          f"({overall['differing_fraction_any_channel']:.6f})")
    print(f"[compare] diff image: {out_diff}; report: {report_path}")
    if assertion:
        print("claim=owner-supplied (human A/B assertion recorded, not verified)")
    print("parity=UNVERIFIED (metrics never constitute donor parity)")
    return EXIT_OK


if __name__ == "__main__":
    raise SystemExit(main())
