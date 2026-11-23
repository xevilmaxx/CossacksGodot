"""T6-R07 M0 visual gate: donor crop, A/B image and honest comparison stats.

Usage (from anywhere): python rustport/tests/tools/m0_compare.py

Reads:
  rustport/shots/m0/rust_terrain.png   (1024x1024, written by m0_capture)
  C:\\Users\\Maxym.Oboyshev\\Downloads\\c3\\cossacks-3-v1-498085.jpg  (donor, READ-ONLY)

Writes (all under rustport/shots/m0/):
  donor_crop.png        - donor crop upscaled to the rust render's exact size
  ab_side_by_side.png   - rust | donor, same size panels
  ab_luminance.png      - greyscale A/B diagnostic of the 256 analysis panels
  stats.json            - metrics + crop documentation + SHA-256 of all outputs

No donor bytes are copied into the repo: inputs are read read-only and the only
written files are our own generated comparison outputs.

CROP RECTANGLE (left, top, right, bottom) = (620, 380, 860, 620), 240x240, in the
1280x720 donor JPG. WHY this rectangle (observed by viewing the image and several
candidate crops, not guessed blindly):
  * It is the cleanest near-square homogeneous *terrain* patch in the reference:
    mottled green grass with fine speckle + a striated grey rock face at the
    top-right, plus a few small saplings/ferns at the edges.
  * It contains the two terrain families that dominate the Rust render (grass
    blocks and the rock block in R06's curated 8-block set), making the A/B a
    terrain-vs-terrain comparison rather than a units/decor comparison.
  * It avoids HUD (none present in this reference), water (none present), unit
    formations, watchtowers and buildings, all of which appear elsewhere in the
    frame. Larger squares always swallowed at least one formation or building.
  * Residual caveat (honest): a few tree saplings/ferns remain inside the crop;
    they are decor, not bare ground. The donor is a perspective/3D screenshot
    while the Rust patch is an orthographic top-down tile grid.

MATCHED SIZE: the 240x240 crop is upscaled with LANCZOS to the rust render's
1024x1024 so donor_crop.png matches rust_terrain.png exactly. Because that
upscale interpolates away fine donor detail, all NUMERIC metrics are computed on
both images resized to a COMMON 256x256 analysis resolution (documented in
stats.json) so the comparison is at matched scale and the upscale does not by
itself decide the spatial-frequency result.
"""

from __future__ import annotations

import hashlib
import json
import math
import statistics
from pathlib import Path

from PIL import Image

# --- Fixed, documented configuration ---------------------------------------
RUSTPORT = Path(__file__).resolve().parents[2]
M0 = RUSTPORT / "shots" / "m0"
DONOR_REF = Path(r"C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg")
CROP_RECT = (620, 380, 860, 620)  # left, top, right, bottom (inclusive-exclusive)
CROP_WHY = (
    "Observed from the 1280x720 donor JPG: cleanest near-square terrain-only "
    "patch (mottled green grass + striated grey rock face at top-right, a few "
    "small saplings/ferns); no HUD, water, unit formations, towers or buildings. "
    "Larger squares always included a formation/building. Contains the two "
    "families that dominate the Rust render (grass + rock)."
)
ANALYSIS_SIZE = (256, 256)  # common scale for numeric metrics
BLOCK = 16  # 16x16 blocks over 256x256 -> 16x16 coarse grid


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def luminance(rgb: tuple[int, int, int]) -> float:
    r, g, b = rgb
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def saturation(rgb: tuple[int, int, int]) -> float:
    r, g, b = rgb
    mx, mn = max(rgb), min(rgb)
    return 0.0 if mx == 0 else (mx - mn) / mx


def mean(xs: list[float]) -> float:
    return sum(xs) / len(xs) if xs else 0.0


def metrics(im: Image.Image) -> dict:
    """All numeric metrics on one RGB image (already at analysis size)."""
    w, h = im.size
    # Pillow 12 deprecates Image.getdata(); tobytes() is stable and equivalent.
    raw = im.tobytes()  # RGB channels, row-major
    px = [tuple(raw[i : i + 3]) for i in range(0, len(raw), 3)]
    n = len(px)

    rs = [p[0] for p in px]
    gs = [p[1] for p in px]
    bs = [p[2] for p in px]
    lum = [luminance(p) for p in px]
    sat = [saturation(p) for p in px]

    # Luminance histogram: 16 bins over [0,256).
    hist = [0] * 16
    for y in lum:
        hist[min(15, int(y // 16))] += 1

    # Saturation distribution: 10 bins over [0,1] plus quantiles.
    sath = [0] * 10
    for s in sat:
        sath[min(9, int(s * 10))] += 1
    sat_bands = {
        "lt_0.10": sum(1 for s in sat if s < 0.10) / n,
        "0.10_0.30": sum(1 for s in sat if 0.10 <= s < 0.30) / n,
        "0.30_0.50": sum(1 for s in sat if 0.30 <= s < 0.50) / n,
        "0.50_0.70": sum(1 for s in sat if 0.50 <= s < 0.70) / n,
        "ge_0.70": sum(1 for s in sat if s >= 0.70) / n,
    }

    # Coarse spatial frequency: per-pixel gradient magnitude on the luminance
    # plane, then averaged inside BLOCKxBLOCK tiles -> a 16x16 frequency map.
    lum_grid = [lum[y * w : (y + 1) * w] for y in range(h)]
    nb = w // BLOCK
    freq_map: list[list[float]] = []
    block_lum_map: list[list[float]] = []
    all_grad: list[float] = []
    for by in range(nb):
        frow: list[float] = []
        lrow: list[float] = []
        for bx in range(nb):
            gsum = 0.0
            lsum = 0.0
            cnt = 0
            for yy in range(by * BLOCK, (by + 1) * BLOCK):
                for xx in range(bx * BLOCK, (bx + 1) * BLOCK):
                    x0 = max(0, xx - 1)
                    x1 = min(w - 1, xx + 1)
                    y0 = max(0, yy - 1)
                    y1 = min(h - 1, yy + 1)
                    dx = lum_grid[yy][x1] - lum_grid[yy][x0]
                    dy = lum_grid[y1][xx] - lum_grid[y0][xx]
                    g = math.hypot(dx, dy)
                    all_grad.append(g)
                    gsum += g
                    lsum += lum_grid[yy][xx]
                    cnt += 1
            frow.append(gsum / cnt)
            lrow.append(lsum / cnt)
        freq_map.append(frow)
        block_lum_map.append(lrow)

    flat_freq = [v for row in freq_map for v in row]
    flat_blum = [v for row in block_lum_map for v in row]

    return {
        "mean_rgb": [round(mean(rs), 3), round(mean(gs), 3), round(mean(bs), 3)],
        "median_rgb": [
            round(statistics.median(rs), 3),
            round(statistics.median(gs), 3),
            round(statistics.median(bs), 3),
        ],
        "mean_luminance": round(mean(lum), 3),
        "median_luminance": round(statistics.median(lum), 3),
        "std_luminance": round(statistics.pstdev(lum), 3),
        "luminance_hist16_counts": hist,
        "luminance_hist16_fractions": [round(c / n, 5) for c in hist],
        "mean_saturation": round(mean(sat), 4),
        "median_saturation": round(statistics.median(sat), 4),
        "saturation_hist10_counts": sath,
        "saturation_bands_fraction": {k: round(v, 5) for k, v in sat_bands.items()},
        "mean_pixel_gradient_magnitude": round(mean(all_grad), 4),
        "block_averaged_gradient": {
            "grid_size": [nb, nb],
            "mean": round(mean(flat_freq), 4),
            "std": round(statistics.pstdev(flat_freq), 4),
            "min": round(min(flat_freq), 4),
            "max": round(max(flat_freq), 4),
            "grid": [[round(v, 2) for v in row] for row in freq_map],
        },
        "block_mean_luminance": {
            "mean": round(mean(flat_blum), 3),
            "std": round(statistics.pstdev(flat_blum), 3),
            "grid": [[round(v, 1) for v in row] for row in block_lum_map],
        },
    }


def compare(a: dict, b: dict) -> dict:
    """Honest deltas: rust (a) relative to donor (b), at analysis scale."""
    dr = [round(a["mean_rgb"][i] - b["mean_rgb"][i], 3) for i in range(3)]
    ga = a["block_averaged_gradient"]["mean"]
    gb = b["block_averaged_gradient"]["mean"]
    return {
        "mean_rgb_delta_rust_minus_donor": dr,
        "mean_luminance_delta": round(
            a["mean_luminance"] - b["mean_luminance"], 3
        ),
        "mean_saturation_delta": round(
            a["mean_saturation"] - b["mean_saturation"], 4
        ),
        "block_gradient_ratio_rust_over_donor": round(ga / gb, 4) if gb else None,
        "block_luminance_std_ratio_rust_over_donor": round(
            a["block_mean_luminance"]["std"] / b["block_mean_luminance"]["std"],
            4,
        )
        if b["block_mean_luminance"]["std"]
        else None,
    }


def main() -> None:
    M0.mkdir(parents=True, exist_ok=True)
    rust_path = M0 / "rust_terrain.png"
    if not rust_path.is_file():
        raise SystemExit(f"missing {rust_path}: run `cargo run --bin m0_capture` first")

    donor = Image.open(DONOR_REF)
    rust = Image.open(rust_path).convert("RGB")
    target = rust.size  # matching size = exact rust render size
    print(f"donor ref: {DONOR_REF} size={donor.size}")
    print(f"rust render: {rust_path} size={target}")
    print(f"crop rect: {CROP_RECT} (native {CROP_RECT[2]-CROP_RECT[0]}x{CROP_RECT[3]-CROP_RECT[1]})")

    crop_native = donor.convert("RGB").crop(CROP_RECT)
    crop_big = crop_native.resize(target, Image.Resampling.LANCZOS)
    crop_path = M0 / "donor_crop.png"
    crop_big.save(crop_path)

    # Side-by-side: equal-size panels, no scaling or colour transforms.
    ab = Image.new("RGB", (target[0] * 2, target[1]))
    ab.paste(rust, (0, 0))
    ab.paste(crop_big, (target[0], 0))
    ab_path = M0 / "ab_side_by_side.png"
    ab.save(ab_path)

    # Numeric metrics at a COMMON analysis scale (neutralises the donor upscale).
    rust_a = rust.resize(ANALYSIS_SIZE, Image.Resampling.LANCZOS)
    donor_a = crop_native.resize(ANALYSIS_SIZE, Image.Resampling.LANCZOS)
    rust_m = metrics(rust_a)
    donor_m = metrics(donor_a)
    delta = compare(rust_m, donor_m)

    # Fourth PNG: greyscale A/B diagnostic (derived only from the two panels;
    # no new donor pixels). Pillow "L" is ITU-R 601-2 luma; it is a visual aid,
    # the numeric Rec.709 luminance metrics above are the reported ones.
    lum_ab = Image.new("L", (ANALYSIS_SIZE[0] * 2, ANALYSIS_SIZE[1]))
    lum_ab.paste(rust_a.convert("L"), (0, 0))
    lum_ab.paste(donor_a.convert("L"), (ANALYSIS_SIZE[0], 0))
    lum_ab = lum_ab.resize((ANALYSIS_SIZE[0] * 4, ANALYSIS_SIZE[1] * 2), Image.Resampling.NEAREST)
    lum_path = M0 / "ab_luminance.png"
    lum_ab.save(lum_path)

    stats = {
        "ticket": "T6-R07",
        "scope": "16x16-tile software-rendered Rust terrain patch vs donor reference JPG",
        "inputs": {
            "rust_render": str(rust_path),
            "donor_reference_read_only": str(DONOR_REF),
        },
        "donor_crop": {
            "rectangle_left_top_right_bottom": list(CROP_RECT),
            "native_size": [crop_native.width, crop_native.height],
            "saved_size": list(crop_big.size),
            "matching_size_of": str(rust_path),
            "upscale_filter": "LANCZOS",
            "why": CROP_WHY,
            "residual_caveats": [
                "A few small saplings/ferns remain inside the crop (decor, not bare ground).",
                "Donor is a perspective 3D screenshot; Rust patch is an orthographic top-down tile grid.",
                "Donor JPG is lossy-compressed and was upscaled 240->1024 before downscaling for analysis.",
            ],
        },
        "analysis_method": {
            "analysis_size": list(ANALYSIS_SIZE),
            "why_analysis_size": (
                "Both saved 1024x1024 panels are downscaled to a common 256x256 "
                "before metrics; this matches the donor crop's native detail "
                "scale and prevents the 240->1024 upscale blur from deciding "
                "the spatial-frequency comparison."
            ),
            "luminance": "Rec.709 Y = 0.2126R + 0.7152G + 0.0722B (float)",
            "saturation": "HSV S = (max-min)/max per pixel",
            "spatial_frequency": (
                "per-pixel hypot(dL/dx, dL/dy) on the luminance plane, averaged "
                "inside 16x16 blocks -> 16x16 coarse gradient-magnitude map"
            ),
        },
        "rust": rust_m,
        "donor": donor_m,
        "delta": delta,
        "note": (
            "Metrics SUPPORT but never override visual review. Anything not "
            "directly measurable here (e.g. donor 3D lighting, shadows, normal "
            "maps, perspective) is UNVERIFIED in the report, not claimed PASS."
        ),
        "outputs_sha256": {},
    }

    for p in (rust_path, crop_path, ab_path, lum_path):
        stats["outputs_sha256"][p.name] = {
            "bytes": p.stat().st_size,
            "sha256": sha256_file(p),
        }

    stats_path = M0 / "stats.json"
    with open(stats_path, "w", encoding="utf-8") as f:
        json.dump(stats, f, indent=2)
        f.write("\n")

    print(f"WROTE {crop_path}")
    print(f"WROTE {ab_path}")
    print(f"WROTE {lum_path}")
    print(f"WROTE {stats_path}")
    for name, info in stats["outputs_sha256"].items():
        print(f"SHA256 {name} {info['sha256']} ({info['bytes']} bytes)")
    print(
        "delta mean_rgb rust-donor {} lum {} grad_ratio {}".format(
            delta["mean_rgb_delta_rust_minus_donor"],
            delta["mean_luminance_delta"],
            delta["block_gradient_ratio_rust_over_donor"],
        )
    )
    print("DONE m0_compare")


if __name__ == "__main__":
    main()
