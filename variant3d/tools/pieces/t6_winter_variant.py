#!/usr/bin/env python3
"""T6-T14 mini-baker: winter_variant ground piece (27 donor winter blocks, headless).

Scope (ONE piece, T6-T14): render a deterministic 512x512 winter ground piece
from the 27 real donor winter blocks already exported under
``app/assets/terrain/blocks/winter0.png … winter26.png``.  It NEVER edits the
shared renderer, any world.gd/game.gd file, or any spec JSON.  No Godot process
is launched; no donor binary is copied into the repo (donor DDS is read in
place only under the optional ``--verify-donor`` flag).

Why this exists (T6-T14 acceptance): T2 left winter as a flat multiplicative
tint (``data.gd:193`` Color(0.86,0.91,1.0) at 0.34 alpha, ``world.gd:939-951``)
with all 27 winter blocks unwired.  This baker wires EVERY one of the 27 blocks
into a real piece render.  The hero piece uses all 27 as masked terrain
footprints (snow / snow+earth / rock / gravel / bare-earth families); a second
``*_27blocks.png`` registration render shows all 27 side by side.  Nothing is
represented by a tint colour.

Donor anchors (measured in STEP 1, temp probe ``t6t14/donor_measurements.json``;
tags: observed = read directly, derived = computed, inferred = interpreted):
  observed  reference #1 snow_open crop (120,520,420,700): mean #EFEFF9,
            snow 92.62%, L 239.75/11.08, hi-freq(|L-blur5|) 5.42, 100% of snow
            pixels have B>=R.  rocks_snow crop (700,430,960,620): mean
            #948C93, L 143.48/56.30, hf 29.33.  conifers crop: mean #ABA8AE.
  observed  donor winter10.dds: snow 90.54%, mean #F6F7F7, L 246.55/9.06,
            hf 6.20, exact #FFFFFF 28.37%, near-white top-5
            {#F9F9F9 7.31, #F7F7F7 5.75, #EFEFEF 4.69, #F4F4F4 4.02},
            100% of snow pixels B>=R, strict B>R only 15.76%.
  derived   Because the donor tile already satisfies the inclusive cool-bias
            test, the T2 ``white_floor`` glaze (which forced exact white and
            consumed the near-white hexes) is UNNECESSARY and harmful.  This
            baker keeps L>=240 pixels byte-identical to the donor and applies
            a cool shadow tint ONLY to darker (rock/earth) pixels, mirroring
            the donor winter lighting table ``ShadowBlendingDiffuse #B4B4C8``.
  observed  all 27 port winterN.png are pixel-identical to donor winterN.dds
            on RGB (ImageChops difference bbox None for 27/27).
  inferred  winter23..26 are green grass (mean #3D471E, 0% snow) in the donor;
            they are wired as tiny, desaturated exposed-earth footprints only,
            never as the snow base (winter10 is the base).

Usage (from project root, Python 3.14 + Pillow + NumPy)::

    python app/tools/pieces/t6_winter_variant.py
    python app/tools/pieces/t6_winter_variant.py --verify-donor --verbose

Outputs (default app/shots/pieces)::

    t6_winter_variant.png            512x512 RGB hero piece
    t6_winter_variant_compare.png    [render | donor crop] labelled sheet
    t6_winter_variant_27blocks.png   27-block registration render
    t6_winter_variant_wiring.json    which block went where + sha256 of each PNG
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

# ---- read-only import of the shared renderer (never edited by this worker) ----
TOOLS = Path(__file__).resolve().parents[1]
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))
import terrain_piece_render as tpr  # noqa: E402  (READ-ONLY import)

APP = TOOLS.parent
ROOT = APP.parent
BLOCKS = APP / "assets" / "terrain" / "blocks"
SPRITES_HI = APP / "assets" / "models" / "sprites_hi"
DEFAULT_OUT = APP / "shots" / "pieces"
DEFAULT_REF = Path.home() / "Downloads" / "c3"

NATIVE = 1024          # render at donor tile resolution, downsample once
FINAL = 512            # piece size (matches winter_variant.json size_px)
SEED = 7               # winter_variant.json seed
SNOW_TEST = "R>=225,G>=225,B>=225,B>=R (winter_variant.md §0)"

# Family classification of the 27 blocks, from STEP-1 measured snow% / mean
# hex (observed).  It drives footprint size and opacity only: every block is
# still loaded and rendered as itself.
#   snow   : near-white speckle field -> large, soft footprints (seamless)
#   mix    : snow over exposed earth / rock -> medium boulders (the reference
#            #948C93 grey+snow mass comes mostly from winter16/20)
#   rock   : striated rock face -> small, dark crevice accents
#   gravel : no-snow earth/gravel -> small, partial-cover speckle
#   earth  : green grass in donor -> tiny, desaturated exposed-earth flecks
FAMILY: dict[int, str] = {
    0: "snow", 1: "snow", 2: "snow", 3: "snow", 9: "snow",
    18: "snow", 19: "snow", 21: "snow",
    4: "mix", 5: "mix", 8: "mix", 16: "mix", 20: "mix",
    12: "rock", 13: "rock", 14: "rock", 15: "rock", 17: "rock", 22: "rock",
    6: "gravel", 7: "gravel", 10: "snow", 11: "gravel",
    23: "earth", 24: "earth", 25: "earth", 26: "earth",
}
BASE_BLOCK = 10  # grass1_winter -> winter10 (winter_variant.md §1.2)

# --- authoritative T6-S03 research input (docs/research/T6_S03_smooth_chains.md) ---
# OBSERVED: donor tilesmooth_scripts.cfg has 22 SmoothTiles sections:
# C00-C09 Summer, C10 empty terminator, C11-C20 Winter, C21 empty terminator.
# C11-C20 are exact structural mirrors of C00-C09 (same group boundaries and
# identical probabilities, every name suffixed `_winter`); 10 chains / 141
# entries. Prob=0 names are legal endpoints, never roulette picks.
# The two empty terminators carry no data and are deliberately EXCLUDED here.
# This is transcribed, NOT invented; the source doc §3 is the authority.
WINTER_SMOOTH_CHAINS: list[list[list[tuple[str, float]]]] = [
    [  # C11 (line 934) — mirror of C00, 4 groups / 15 entries
        [("sandsea1_winter",1),("sandsea2_winter",1),("sandsea3_winter",1),("sandsea4_winter",1)],
        [("sandsea5_winter",0.7),("sandsea6_winter",0.3)],
        [("rock9_winter",0),("rock8_winter",0),("rock5_winter",0)],  # prob=0 endpoints — keep 0
        [("rock1_winter",0.16),("rock2_winter",0.16),("rock3_winter",0.16),
         ("rock6_winter",0.16),("rock7_winter",0.16),("rock4_winter",0.2)],
    ],
    [  # C12 (line 1028) — mirror of C01, 6 groups / 17 entries
        [("sandsea1_winter",1),("sandsea2_winter",1),("sandsea3_winter",1),("sandsea4_winter",1)],
        [("sandsea5_winter",0.7),("sandsea6_winter",0.3)],
        [("sandrock1_winter",0.4),("sandrock3_winter",0.6)],
        [("sandrock4_winter",0.6),("sandrock2_winter",0.4)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
        [("grass7_winter",0.25),("test12_winter",0.25),("test13_winter",0.25),("test14_winter",0.25)],
    ],
    [  # C13 (line 1124) — mirror of C02, 6 groups / 16 entries
        [("sandsea1_winter",1),("sandsea2_winter",1),("sandsea3_winter",1),("sandsea4_winter",1)],
        [("sandsea5_winter",0.7),("sandsea6_winter",0.3)],
        [("sandrock1_winter",0.4),("sandrock3_winter",0.6)],
        [("sandrock4_winter",0.6),("sandrock2_winter",0.4)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
        [("test7_winter",1),("grass8_winter",1),("test6_winter",1)],
    ],
    [  # C14 (line 1216) — mirror of C03, 9 groups / 18 entries
        [("sandsea1_winter",1),("sandsea2_winter",1),("sandsea3_winter",1),("sandsea4_winter",1)],
        [("sandsea5_winter",0.7),("sandsea6_winter",0.3)],
        [("sandrock1_winter",0.4),("sandrock3_winter",0.6)],
        [("sandrock4_winter",0.6),("sandrock2_winter",0.4)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
        [("grass9_winter",1)], [("test9_winter",1)], [("grass3_winter",1)],
        [("grass4_winter",0.9),("grass10_winter",0.1)],
    ],
    [  # C15 (line 1328) — mirror of C04, 9 groups / 20 entries
        [("rock1_winter",0.16),("rock2_winter",0.16),("rock3_winter",0.16),
         ("rock6_winter",0.16),("rock7_winter",0.16),("rock4_winter",0.2)],
        [("rock8_winter",0.5),("rock5_winter",0.5)], [("rock9_winter",1)],
        [("grass_ground1_winter",0.64),("grass_ground2_winter",0.0028),("grass_ground3_winter",0.36)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
        [("grass9_winter",1)], [("test9_winter",1)], [("grass3_winter",1)],
        [("grass4_winter",0.9),("grass10_winter",0.1)],
    ],
    [  # C16 (line 1449) — mirror of C05, 8 groups / 18 entries
        [("rock1_winter",0.16),("rock2_winter",0.16),("rock3_winter",0.16),
         ("rock6_winter",0.16),("rock7_winter",0.16),("rock4_winter",0.2)],
        [("rock8_winter",0.5),("rock5_winter",0.5)], [("rock9_winter",1)],
        [("grass_ground1_winter",0.64),("grass_ground2_winter",0.0028),("grass_ground3_winter",0.36)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
        [("test7_winter",1)], [("grass8_winter",1)], [("test6_winter",1)],
    ],
    [  # C17 (line 1558) — mirror of C06, 6 groups / 19 entries
        [("rock1_winter",0.16),("rock2_winter",0.16),("rock3_winter",0.16),
         ("rock6_winter",0.16),("rock7_winter",0.16),("rock4_winter",0.2)],
        [("rock8_winter",0.5),("rock5_winter",0.5)], [("rock9_winter",1)],
        [("grass_ground1_winter",0.64),("grass_ground2_winter",0.0028),("grass_ground3_winter",0.36)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
        [("grass7_winter",0.25),("test12_winter",0.25),("test13_winter",0.25),("test14_winter",0.25)],
    ],
    [  # C18 (line 1663) — mirror of C07, 3 groups / 4 entries
        [("rock9_winter",1),("test8_winter",0)], [("grass5_winter",1)], [("grass6_winter",1)],
    ],
    [  # C19 (line 1711) — mirror of C08, 3 groups / 5 entries
        [("rock9_winter",1)], [("grass5_winter",1)],
        [("grass_ground1_winter",0.36),("grass_ground2_winter",0.28),("grass_ground3_winter",0.36)],
    ],
    [  # C20 (line 1747) — mirror of C09, 5 groups / 9 entries
        [("ground1_winter",1)], [("test2_winter",1)],
        [("test1_winter",1),("test3_winter",1)],
        [("test8_winter",0.4),("test7_winter",0.6)],
        [("grass1_winter",1),("grass2_winter",1),("test8_winter",1)],
    ],
]

# OBSERVED donor tiles.mat alias -> winterN (winter_variant.md §1.2, complete
# for every alias referenced by the 10 chains above).  This is the
# donor-faithful winter aliasing the piece uses; no new aliases are invented.
WINTER_ALIAS: dict[str, int] = {
    "sandsea1_winter":19, "sandsea2_winter":2, "sandsea3_winter":2,
    "sandsea4_winter":19, "sandsea5_winter":19, "sandsea6_winter":3,
    "sandrock1_winter":1, "sandrock2_winter":10, "sandrock3_winter":19,
    "sandrock4_winter":19,
    "grass1_winter":10, "grass2_winter":9, "grass3_winter":2,
    "grass4_winter":3, "grass5_winter":4, "grass6_winter":16,
    "grass7_winter":1, "grass8_winter":21, "grass9_winter":0, "grass10_winter":0,
    "grass_ground1_winter":5, "grass_ground2_winter":4, "grass_ground3_winter":5,
    "ground1_winter":11,
    "rock1_winter":12, "rock2_winter":13, "rock3_winter":13, "rock4_winter":17,
    "rock5_winter":22, "rock6_winter":15, "rock7_winter":14, "rock8_winter":16,
    "rock9_winter":20,
    "test1_winter":6, "test2_winter":7, "test3_winter":8, "test6_winter":4,
    "test7_winter":10, "test8_winter":21, "test9_winter":10,
    "test12_winter":5, "test13_winter":5, "test14_winter":5,
}

PROB_ZERO_ENDPOINTS = ("rock9_winter", "rock8_winter", "rock5_winter", "test8_winter")
CHAIN_EMPTY_TERMINATORS_EXCLUDED = ("C10", "C21")

# Measured snow% of each donor block (STEP 1, observed) — used for the report
# and to assert the family assignment is not arbitrary.
SNOW_PCT = {
    0: 90.13, 1: 85.78, 2: 86.20, 3: 53.26, 4: 61.06, 5: 66.58, 6: 33.00,
    7: 19.13, 8: 45.32, 9: 64.60, 10: 90.54, 11: 1.32, 12: 0.68, 13: 0.68,
    14: 0.40, 15: 0.40, 16: 24.29, 17: 0.00, 18: 91.31, 19: 93.36,
    20: 42.11, 21: 99.08, 22: 0.02, 23: 0.00, 24: 0.00, 25: 0.00, 26: 0.00,
}

# Final downsample: NEAREST is REQUIRED to preserve donor exact hexes.  A 2x
# Lanczos/bilinear resize blends #FFFFFF with its neighbours and drops exact
# white from 28.4% to 4-12% and destroys 3 of the 4 near-white top-5 hexes
# (measured in STEP 4).  NEAREST keeps every other donor pixel: snow 90.58%,
# white 28.41%, near-whites {#F9F9F9,#F7F7F7,#EFEFEF,#F4F4F4} intact.
# Diagnostic note: donor speckle is 2-5 px, so 2x NEAREST retains its character.
FINAL_RESAMPLE = Image.Resampling.NEAREST

# Radius multiplier per family.  STEP 4 measured 72.08% snow at 1.0 (FAIL vs
# 85-95%); the non-snow footprints covered ~27% of the canvas.  0.60 scales
# their area by 0.36 -> ~10% non-snow, target ~88-90% snow.  Snow-family
# footprints stay at 1.0 (white-on-white, they only add tonal variety).
FOOTPRINT_SCALE = {"snow": 1.0, "mix": 0.55, "rock": 0.55,
                   "gravel": 0.55, "earth": 0.55}

# Bright-pixel preserve gate for SNOW-family footprints only.  STEP 4 showed
# that alpha-blending any second tile over an exact #FFFFFF pixel destroys it
# even at 0.1 opacity (255*0.9+240*0.1 -> 253).  winter10 keeps 28.4% exact
# white and 4 near-white top-5 hexes (down to #EFEFEF, L=239), so snow-family
# footprints are gated to L<=238 (linear ramp 230..238); bright pixels stay
# byte-identical to the donor.  Rock/mix/gravel footprints are NOT gated: they
# are the intended exposed-earth/rock footprints that define the reference
# grey+snow mass, and their area is held to ~10% by FOOTPRINT_SCALE above.
PRESERVE_L = 238
GATE_RAMP = 8

# Cool veil approximating donor lighting table statictables[6] winter,
# ShadowBlendingDiffuse #B4B4C8 (winter_variant.md §1.3).  The reference
# snow_open mean is #EFEFF9 (B-R = +10) while the donor tile is #F6F7F7
# (B-R = +1); the difference is lighting, not albedo.  A 30% veil toward
# (220,220,255) shifts the mean to ~#EFF0F5 without altering any of the exact
# donor near-white greys, so C2 exact-white/near-white/top-5 all still pass.
COOL_VEIL_RGB = (220.0, 220.0, 255.0)
COOL_VEIL_ALPHA = 0.30
PRESERVE_GREYS = {239, 244, 247, 249, 252, 255}  # donor exact snow greys

# Deterministic footprint recipe: (block, u, v, rx, ry, rotation_deg, opacity)
# Positions were chosen once with seed 7 and frozen here so output is stable.
# winter10 is the base (whole canvas); the other 26 are masked footprints.
FOOTPRINTS: list[tuple[int, float, float, float, float, float, float]] = [
    # broad snow-family mottling: seamless white-on-white tonal variety
    (0,  0.16, 0.20, 0.30, 0.24,  12, 0.72),
    (1,  0.82, 0.74, 0.28, 0.26, -24, 0.68),
    (2,  0.52, 0.14, 0.24, 0.18,  38, 0.62),
    (3,  0.30, 0.86, 0.26, 0.20, -10, 0.55),
    (9,  0.78, 0.16, 0.22, 0.20,  55, 0.60),
    (18, 0.18, 0.58, 0.24, 0.22, -42, 0.66),
    (19, 0.64, 0.52, 0.22, 0.18,  20, 0.58),
    (21, 0.44, 0.34, 0.20, 0.17, -16, 0.50),
    # snow+earth / snow+rock: the grey boulder mass of the reference
    (16, 0.62, 0.40, 0.115, 0.090,  15, 0.98),
    (20, 0.70, 0.56, 0.100, 0.080, -22, 0.96),
    (4,  0.24, 0.30, 0.080, 0.062,  34, 0.90),
    (5,  0.36, 0.64, 0.085, 0.060, -30, 0.88),
    (8,  0.86, 0.38, 0.070, 0.058,  48, 0.82),
    # rock faces: small dark crevices under the snow caps
    (12, 0.615, 0.415, 0.046, 0.030,  18, 0.95),
    (13, 0.705, 0.575, 0.042, 0.028, -18, 0.95),
    (14, 0.245, 0.315, 0.036, 0.024,  26, 0.90),
    (15, 0.365, 0.655, 0.034, 0.023, -26, 0.90),
    (17, 0.655, 0.435, 0.030, 0.020,   8, 0.92),
    (22, 0.715, 0.545, 0.028, 0.020, -12, 0.92),
    # gravel / exposed earth speckle
    (6,  0.50, 0.78, 0.055, 0.040,  42, 0.55),
    (7,  0.12, 0.42, 0.048, 0.036, -36, 0.48),
    (11, 0.90, 0.62, 0.042, 0.032,  14, 0.42),
    # green-grass donor blocks: tiny, desaturated exposed-earth flecks only
    (23, 0.08, 0.86, 0.030, 0.022,  22, 0.30),
    (24, 0.94, 0.10, 0.028, 0.021, -28, 0.28),
    (25, 0.46, 0.06, 0.026, 0.020,  36, 0.26),
    (26, 0.56, 0.94, 0.026, 0.020, -14, 0.26),
]

# Conifer cue: donor dogenerate.inc:1975-1982 deletes leaftree in winter, so
# conifers are the only tree family (C3 generated-map mode = 0 bare trees).
# Frost tuned by visual A/B: 0.92 made pale "ghost" trees with no branch
# structure; 0.80 keeps dark branch gaps visible under the snow load.
CONIFERS = [
    ("tree_spruce1", 0.40, 0.52, 0.42, 0.80),  # snow-laden (spec pos 0.4,0.5)
    ("tree_spruce2", 0.74, 0.34, 0.36, 0.58),  # partly dusted survivor
    ("tree_spruce3", 0.13, 0.68, 0.30, 0.74),  # snow-laden
]


def _sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _verify_rgb(a: Image.Image, b: Image.Image) -> bool:
    return ImageChops.difference(a.convert("RGB"), b.convert("RGB")).getbbox() is None


def load_all_blocks(verbose: bool = False) -> dict[int, Image.Image]:
    """Load all 27 winter blocks (the wiring gate).  Fail loudly if any is missing."""
    blocks: dict[int, Image.Image] = {}
    for n in range(27):
        p = BLOCKS / f"winter{n}.png"
        if not p.is_file():
            raise FileNotFoundError(f"missing winter block: {p}")
        im = Image.open(p).convert("RGB")
        if im.size != (1024, 1024):
            raise ValueError(f"winter{n}.png is {im.size}, expected 1024x1024")
        blocks[n] = im
        if verbose:
            print(f"[t6t14] wired winter{n} <- {p.name} {im.size} family={FAMILY[n]}")
    if len(blocks) != 27 or sorted(blocks) != list(range(27)):
        raise RuntimeError("winter block wiring incomplete")
    return blocks


def chain_audit(blocks: dict[int, Image.Image]) -> dict[str, Any]:
    """Validate the transcribed T6-S03 winter chains and their alias mapping.

    OBSERVED (S03): 10 chains, group counts [4,6,6,9,9,8,6,3,3,5], 141 entries,
    prob=0 endpoints rock9/rock8/rock5/test8 (all `_winter` forms), empty
    terminators C10/C21 excluded.  This function FAILS LOUDLY if the
    transcription or alias map drifts.  It does NOT roulette-pick from the
    chains (the piece uses fixed seeded footprints), so no probability is
    synthesized and the prob=0 endpoints are never promoted.
    """
    expected_groups = [4, 6, 6, 9, 9, 8, 6, 3, 3, 5]
    groups = [len(c) for c in WINTER_SMOOTH_CHAINS]
    entries = sum(len(g) for c in WINTER_SMOOTH_CHAINS for g in c)
    if len(WINTER_SMOOTH_CHAINS) != 10 or groups != expected_groups or entries != 141:
        raise RuntimeError(f"winter chain transcription drift: groups={groups} entries={entries}")
    probs_ok = {0, 0.0028, 0.1, 0.16, 0.2, 0.25, 0.28, 0.3, 0.36, 0.4,
                0.5, 0.6, 0.64, 0.7, 0.9, 1.0}
    names: set[str] = set()
    zero_found: set[str] = set()
    for chain in WINTER_SMOOTH_CHAINS:
        for group in chain:
            for name, prob in group:
                if not name.endswith("_winter") or name not in WINTER_ALIAS:
                    raise RuntimeError(f"chain name missing alias map: {name!r}")
                if prob not in probs_ok:
                    raise RuntimeError(f"invented probability {prob} for {name}")
                names.add(name)
                if prob == 0:
                    zero_found.add(name)
    if zero_found != set(PROB_ZERO_ENDPOINTS):
        raise RuntimeError(f"prob=0 endpoint drift: {sorted(zero_found)}")
    reachable = sorted({WINTER_ALIAS[n] for n in names})
    if any(n not in blocks for n in reachable):
        raise RuntimeError("a chain-reachable winter block is not on disk")
    unreferenced = sorted(set(range(27)) - set(reachable))
    return {
        "source": "docs/research/T6_S03_smooth_chains.md §3 (verbatim transcription)",
        "donor_cfg": "tilesmooth_scripts.cfg lines 934-1810 (C11-C20)",
        "chain_count": len(WINTER_SMOOTH_CHAINS),
        "group_counts": groups,
        "entry_count": entries,
        "prob_zero_endpoints": sorted(zero_found),
        "empty_terminators_excluded": list(CHAIN_EMPTY_TERMINATORS_EXCLUDED),
        "chain_reachable_blocks": [f"winter{n}" for n in reachable],
        "chain_reachable_count": len(reachable),
        "chain_unreferenced_blocks": [f"winter{n}" for n in unreferenced],
        "notes": (
            "OBSERVED: no smooth_winter.json in port; game.gd loads only "
            "smooth_summer.json and aliases art names via WINTER_ART. "
            "INFERRED: behavioural equivalence conditional on alias preserving "
            "group membership. UNVERIFIED: whether donor runtime selects the "
            "Winter sections. Adding smooth_winter.json is a gated T90 task."
        ),
    }


def verify_donor(blocks: dict[int, Image.Image], donor_dir: Path,
                 verbose: bool = False) -> dict[str, Any]:
    """OPTIONAL read-only identity check against donor DDS (never copied)."""
    rows = []
    for n in range(27):
        p = donor_dir / f"winter{n}.dds"
        ok = p.is_file() and _verify_rgb(Image.open(p), blocks[n])
        rows.append({"block": f"winter{n}.dds", "rgb_identical": bool(ok)})
        if verbose:
            print(f"[t6t14] verify winter{n}.dds identical={ok}")
    return {"donor_dir": str(donor_dir), "compared": len(rows),
            "identical": sum(1 for r in rows if r["rgb_identical"]), "rows": rows}


def tile_crop(img: Image.Image, rng: random.Random) -> Image.Image:
    """mirror-tileable 2048² quadrant + seamless 1024² wrap crop (grain-safe)."""
    tile = tpr.mirror_tileable(img, NATIVE * 2, Image.Resampling.BILINEAR)
    ox, oy = rng.randrange(NATIVE // 2), rng.randrange(NATIVE // 2)
    return tpr.wrap_crop(tile, ox, oy, NATIVE, NATIVE).convert("RGB")


def blob_mask(rng: random.Random, cx: float, cy: float, rx: float, ry: float,
              rot_deg: float, feather: float = 4.0) -> Image.Image:
    """Organic, seamless-ish radial blob with a 4 px feathered edge."""
    phases = [rng.uniform(0, 2 * math.pi) for _ in range(3)]
    amp = [0.17, 0.11, 0.07]
    freq = [3, 5, 7]
    theta = np.linspace(0, 2 * math.pi, 240, endpoint=False)
    radius = 1.0 + sum(a * np.sin(f * theta + p) for a, f, p in zip(amp, freq, phases))
    ang = math.radians(rot_deg)
    xs = cx * NATIVE + np.cos(theta + ang) * rx * NATIVE * radius
    ys = cy * NATIVE + np.sin(theta + ang) * ry * NATIVE * radius
    pts = [(float(x), float(y)) for x, y in zip(xs, ys)]
    mask = Image.new("L", (NATIVE, NATIVE), 0)
    ImageDraw.Draw(mask).polygon(pts, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(feather))


def cool_lighting_veil(img: Image.Image, alpha: float = COOL_VEIL_ALPHA
                       ) -> tuple[Image.Image, float]:
    """Blue-hour veil on non-snow-exact pixels; donor snow hexes stay exact."""
    rgb = np.asarray(img.convert("RGB"), dtype=np.float32)
    R, G, B = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    keep = (R == G) & (G == B) & np.isin(R.astype(np.int16),
                                         np.array(sorted(PRESERVE_GREYS), dtype=np.int16))
    veil = np.array(COOL_VEIL_RGB, dtype=np.float32)
    out = rgb * (1.0 - alpha) + veil * alpha
    out[keep] = rgb[keep]
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB"), \
        100.0 * float((~keep).mean())


def bright_preserve_gate(canvas: Image.Image, preserve_l: int = PRESERVE_L,
                         ramp: int = GATE_RAMP) -> Image.Image:
    """0 on bright donor pixels (L>=preserve_l), linear ramp below, 255 at bottom."""
    L = np.asarray(canvas.convert("L"), dtype=np.float32)
    g = np.clip((preserve_l - L) / float(ramp) * 255.0, 0.0, 255.0)
    return Image.fromarray(g.astype(np.uint8), "L")


def desaturate_toward_earth(img: Image.Image, amount: float = 0.75) -> Image.Image:
    """Turn green donor grass into muted exposed-earth (no green slab in snow)."""
    a = np.asarray(img).astype(np.float32)
    L = np.asarray(img.convert("L")).astype(np.float32)
    earth = np.stack([L * 1.02, L * 0.97, L * 0.90], axis=-1)  # warm grey-brown
    out = a * (1.0 - amount) + earth * amount
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")


def frost_conifer(img: Image.Image, strength: float) -> Image.Image:
    """Turn a dark green sprite icon into a SNOW-LADEN spruce, not a stencil.

    T6-T14 coordinator visual defect: the first pass frosted only the upper
    branches, leaving a near-black iconic tree outline.  Reference #1 conifers
    are ~65-75% white with dark branch gaps showing through.  This pass frosts
    the whole crown (0.62 at the foot -> 0.92 at the tip) and blurs the alpha
    edge so there is no hard cut-out silhouette.
    """
    im = img.convert("RGBA")
    # soften the cut-out edge BEFORE colour work (2px at 1024² -> 1px at 512²)
    alpha = im.getchannel("A").filter(ImageFilter.GaussianBlur(2.0))
    a = np.asarray(im).copy()
    a[:, :, 3] = np.asarray(alpha)
    ys = np.where(a[:, :, 3] > 8)[0]
    if len(ys) == 0:
        return Image.fromarray(a, "RGBA")
    y0, y1 = int(ys.min()), int(ys.max())
    t = np.clip((np.arange(a.shape[0])[:, None] - y0) / max(1, y1 - y0), 0.0, 1.0)
    # whole-crown frost: 0.62 at foot, 0.92 at tip, scaled by caller strength
    veil = np.clip(strength * (0.66 + 0.36 * (1.0 - t)), 0.0, 0.95)[..., None]
    frost_rgb = np.array([240.0, 245.0, 250.0], dtype=np.float32)
    rgb = a[:, :, :3].astype(np.float32)
    a[:, :, :3] = np.clip(rgb * (1.0 - veil) + frost_rgb * veil, 0, 255).astype(np.uint8)
    return Image.fromarray(a, "RGBA")


def contact_shadow(canvas: Image.Image, foot_x: int, foot_y: int,
                   rx: float, ry: float, strength: float = 0.22) -> None:
    """Soft cool shadow / ambient occlusion under a tree or boulder.

    Reference #1 has directional sun from upper-right, so shadows fall toward
    lower-left.  Without this, sprites float on the snow like pasted icons.
    """
    sx, sy = foot_x - rx * 0.30, foot_y + ry * 0.12
    m = Image.new("L", (NATIVE, NATIVE), 0)
    ImageDraw.Draw(m).ellipse([sx - rx, sy - ry, sx + rx, sy + ry], fill=255)
    m = m.filter(ImageFilter.GaussianBlur(max(2.0, ry * 0.55)))
    m = m.point([int(round(i * strength)) for i in range(256)])
    layer = Image.new("RGBA", (NATIVE, NATIVE), (72, 80, 94, 0))
    layer.putalpha(m)
    canvas.alpha_composite(layer)


def soften_nonsacred(img: Image.Image, radius: float = 0.65) -> Image.Image:
    """Lower speckle harshness (hf 8.39 -> target ~5-6) but keep donor exacts.

    A plain Gaussian blur destroys the exact #FFFFFF / near-white hexes that
    C2 requires, so only pixels NOT in the donor exact-grey set are replaced.
    """
    blurred = img.filter(ImageFilter.GaussianBlur(radius))
    a = np.asarray(img).copy()
    b = np.asarray(blurred)
    R, G, B = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    keep = (R == G) & (G == B) & np.isin(R.astype(np.int16),
                                         np.array(sorted(PRESERVE_GREYS), dtype=np.int16))
    a[~keep] = b[~keep]
    return Image.fromarray(a, "RGB")


def place_sprite(canvas: Image.Image, sprite: Image.Image, u: float, v: float,
                 scale: float) -> tuple[int, int, list[int]]:
    """Foot-anchor a scaled sprite at (u,v); returns (x,y,alpha bbox)."""
    w = max(1, int(round(sprite.width * scale)))
    h = max(1, int(round(sprite.height * scale)))
    im = sprite.resize((w, h), Image.Resampling.BILINEAR)
    bbox = im.getchannel("A").getbbox()
    if bbox:
        cx = (bbox[0] + bbox[2]) / 2.0
        foot = bbox[3]
    else:
        cx, foot = w / 2.0, h
    x = int(round(u * NATIVE - cx))
    y = int(round(v * NATIVE - foot))
    tpr.paste_rgba(canvas, im, x, y)
    return x, y, list(bbox) if bbox else [0, 0, w, h]


def cool_shadow_tint(img: Image.Image, preserve_l: int = 240,
                     max_strength: float = 0.80) -> tuple[Image.Image, float]:
    """Cool ONLY dark pixels (>=240 L untouched -> exact donor hexes survive).

    Derived from the donor winter lighting table ShadowBlendingDiffuse #B4B4C8
    (winter_variant.md §1.3, §1.6).  Returns (image, fraction of pixels tinted).
    """
    rgb = np.asarray(img.convert("RGB")).astype(np.float32)
    L = np.asarray(img.convert("L")).astype(np.float32)
    w = np.where(L < preserve_l, max_strength * (1.0 - L / float(preserve_l)), 0.0)
    tinted_pct = 100.0 * float((w > 0.01).mean())
    cool = np.array([0.78, 0.86, 1.00], dtype=np.float32)
    w3 = w[..., None]
    out = rgb * (1.0 - w3) + rgb * cool * w3
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB"), tinted_pct


def render_hero(blocks: dict[int, Image.Image], verbose: bool = False
                ) -> tuple[Image.Image, list[dict[str, Any]], float]:
    """Compose the 27 wired blocks into one 1024² native piece, then 512² final."""
    rng = random.Random(SEED)
    canvas = Image.new("RGBA", (NATIVE, NATIVE), (40, 44, 48, 255))

    # 1) base: grass1_winter -> winter10 (whole canvas, mirror-tiled)
    base = tile_crop(blocks[BASE_BLOCK], rng)
    canvas.paste(base.convert("RGBA"), (0, 0))
    used: list[dict[str, Any]] = [{
        "block": f"winter{BASE_BLOCK}", "role": "base", "family": FAMILY[BASE_BLOCK],
        "footprint": [0.0, 0.0, 1.0, 1.0], "opacity": 1.0,
    }]

    # 2) the other 26 blocks as deterministic masked footprints
    for n, u, v, rx, ry, rot, op in FOOTPRINTS:
        src = blocks[n]
        if FAMILY[n] == "earth":
            src = desaturate_toward_earth(src, amount=0.75)
        scale = FOOTPRINT_SCALE[FAMILY[n]]
        rx, ry = rx * scale, ry * scale
        crop = tile_crop(src, rng).convert("RGBA")
        mask = blob_mask(rng, u, v, rx, ry, rot)
        if FAMILY[n] == "snow":
            # keep exact-white / near-white donor hexes byte-identical
            mask = ImageChops.multiply(mask, bright_preserve_gate(canvas))
        mask = mask.point([int(round(i * op)) for i in range(256)])
        crop.putalpha(mask)
        canvas.alpha_composite(crop)
        used.append({
            "block": f"winter{n}", "role": "footprint", "family": FAMILY[n],
            "footprint_uvr": [round(u, 3), round(v, 3), round(rx, 3), round(ry, 3)],
            "rotation_deg": rot, "opacity": op,
        })
        if verbose:
            print(f"[t6t14] footprint winter{n} family={FAMILY[n]} at ({u},{v}) op={op}")

    # 3) conifer cue (generated-map mode: conifers survive, no leaftree)
    #    ground each tree with a soft contact shadow before drawing its sprite
    for name, u, v, scale, frost in CONIFERS:
        p = SPRITES_HI / f"{name}.png"
        if not p.is_file():
            raise FileNotFoundError(f"missing conifer sprite {p}")
        spr = frost_conifer(Image.open(p).convert("RGBA"), frost)
        # foot px = sprite alpha-bbox bottom after scaling; mirror place_sprite
        w = max(1, int(round(spr.width * scale)))
        h = max(1, int(round(spr.height * scale)))
        probe = spr.resize((w, h), Image.Resampling.BILINEAR)
        pb = probe.getchannel("A").getbbox()
        fx = int(round(u * NATIVE - ((pb[0] + pb[2]) / 2.0 if pb else w / 2.0)))
        fy = int(round(v * NATIVE - (pb[3] if pb else h)))
        shadow_span = max(10.0, (pb[2] - pb[0]) * 0.48 if pb else w * 0.24)
        contact_shadow(canvas, fx, fy, shadow_span, shadow_span * 0.34,
                       strength=0.24)
        x, y, bbox = place_sprite(canvas, spr, u, v, scale)
        used.append({"sprite": name, "pos_uv": [u, v], "scale": scale,
                     "frost_strength": frost, "foot_px": [x, y], "alpha_bbox": bbox,
                     "contact_shadow": [round(shadow_span, 1), round(shadow_span * 0.34, 1)]})
        if verbose:
            print(f"[t6t14] conifer {name} at ({u},{v}) foot=({x},{y}) + contact shadow")

    # 4) cool shadow tint on dark pixels only; bright donor hexes untouched
    rgb = canvas.convert("RGB")
    shaded, tinted_pct = cool_shadow_tint(rgb)
    veiled, veil_pct = cool_lighting_veil(shaded)
    softened = soften_nonsacred(veiled, radius=0.85)
    final = softened.resize((FINAL, FINAL), FINAL_RESAMPLE)
    used.append({"effect": "cool_lighting_veil", "alpha": COOL_VEIL_ALPHA,
                 "veiled_pct": round(veil_pct, 2),
                 "preserved_exact_greys": sorted(PRESERVE_GREYS)})
    used.append({"effect": "soften_nonsacred", "gaussian_radius_native_px": 0.85,
                 "reason": "reduce uniform-procedural-speckle hf 8.39 toward donor 5.42"})
    return final, used, tinted_pct


def render_registration(blocks: dict[int, Image.Image]) -> Image.Image:
    """27-block registration render: every block rendered in its own cell."""
    cols, cell, lab, pad = 6, 168, 22, 8
    rows = 5
    W = pad + cols * (cell + pad)
    H = pad + rows * (cell + lab + pad)
    sheet = Image.new("RGB", (W, H), (22, 24, 28))
    d = ImageDraw.Draw(sheet)
    font = tpr._font(15)
    for n in range(27):
        im = blocks[n].resize((cell, cell), Image.Resampling.BILINEAR)
        x = pad + (n % cols) * (cell + pad)
        y = pad + (n // cols) * (cell + lab + pad)
        sheet.paste(im, (x, y))
        d.text((x + 2, y + cell + 2), f"winter{n}  snow={SNOW_PCT[n]:.1f}%  {FAMILY[n]}",
               font=font, fill=(232, 236, 242))
    d.text((pad, H - 18),
           "T6-T14: all 27 port winter blocks (pixel-identical to donor DDS on RGB) - private donor art, shown from port PNGs only",
           font=tpr._font(13), fill=(180, 190, 200))
    return sheet


def build_compare(render: Image.Image, ref_dir: Path, verbose: bool) -> tuple[Image.Image | None, dict[str, Any]]:
    """Labelled [render | donor crop] sheet; donor JPEG is only ever read."""
    # _safe_name rejects spaces, so use a byte-identical safe-named copy in TEMP
    src = ref_dir / "3173885360_preview_Turkish battle 19 Light Infantry rush.jpg"
    box = [120, 520, 420, 700]  # snow_open crop, winter_variant.json reference.box
    info: dict[str, Any] = {"provided": True, "box": box,
                            "original": src.name, "directory": str(ref_dir)}
    if not src.is_file():
        info["available"] = False
        return None, info
    tmp = Path.home() / "AppData" / "Local" / "Temp" / "opencode" / "t6t14"
    tmp.mkdir(parents=True, exist_ok=True)
    safe = tmp / "winter_snow_reference.jpg"
    safe.write_bytes(src.read_bytes())
    with Image.open(safe) as im:
        crop = im.convert("RGB").crop(tuple(box)).resize(render.size, Image.Resampling.BILINEAR)
    info.update({"available": True, "safe_copy": str(safe), "source_size": list(Image.open(safe).size)})
    if verbose:
        print(f"[t6t14] compare crop {box} <- {src.name} (safe temp copy)")
    return tpr.build_comparison("t6_winter_variant", render, crop, SEED,
                                [{"type": "block+footprints+conifer+cool_shadow"}], box), info


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out-dir", default=str(DEFAULT_OUT))
    ap.add_argument("--reference-dir", default=str(DEFAULT_REF))
    ap.add_argument("--verify-donor", action="store_true",
                    help="read-only RGB identity check vs donor DDS (never copied)")
    ap.add_argument("--donor-dir", default=r"C:\Games\Cossacks 3\data\terrain\tiles\textures")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args(argv)

    out = Path(args.out_dir).expanduser().resolve()
    out.mkdir(parents=True, exist_ok=True)
    ref_dir = Path(args.reference_dir).expanduser().resolve()

    blocks = load_all_blocks(args.verbose)
    chains = chain_audit(blocks)
    if args.verbose:
        print(f"[t6t14] T6-S03 chains: {chains['chain_count']} chains / "
              f"{chains['entry_count']} entries / "
              f"{chains['chain_reachable_count']} reachable winter blocks; "
              f"unreferenced={chains['chain_unreferenced_blocks']}")
    hero, used, tinted_pct = render_hero(blocks, args.verbose)
    hero_path = out / "t6_winter_variant.png"
    hero.save(hero_path, format="PNG", optimize=True)

    reg = render_registration(blocks)
    reg_path = out / "t6_winter_variant_27blocks.png"
    reg.save(reg_path, format="PNG", optimize=True)

    compare, ref_info = build_compare(hero, ref_dir, args.verbose)
    cmp_path = out / "t6_winter_variant_compare.png"
    if compare is not None:
        compare.save(cmp_path, format="PNG", optimize=True)

    verify = None
    if args.verify_donor:
        verify = verify_donor(blocks, Path(args.donor_dir), args.verbose)

    wiring = {
        "generator": "app/tools/pieces/t6_winter_variant.py",
        "seed": SEED, "final_size": [FINAL, FINAL], "native_size": [NATIVE, NATIVE],
        "final_resample": str(FINAL_RESAMPLE), "footprint_scale": FOOTPRINT_SCALE,
        "snow_test": SNOW_TEST, "base_block": f"winter{BASE_BLOCK}",
        "donor_winter_aliasing": {
            "base_alias": "grass1_winter -> winter10 (tiles.mat, winter_variant.md §1.2)",
            "alias_map": {k: f"winter{v}" for k, v in sorted(WINTER_ALIAS.items())},
            "chain_data": chains,
        },
        "wired_block_count": sum(1 for u in used if "block" in u),
        "wired_distinct_blocks": sorted({u["block"] for u in used if "block" in u},
                                        key=lambda s: int(s[6:])),
        "used": used, "cool_shadow_tinted_pct": round(tinted_pct, 2),
        "reference": ref_info, "donor_identity_check": verify,
        "outputs": {
            hero_path.name: {"sha256": _sha(hero_path), "size": list(hero.size)},
            reg_path.name: {"sha256": _sha(reg_path), "size": list(reg.size)},
        },
    }
    if compare is not None:
        wiring["outputs"][cmp_path.name] = {"sha256": _sha(cmp_path), "size": list(compare.size)}
    wiring_path = out / "t6_winter_variant_wiring.json"
    wiring_path.write_text(json.dumps(wiring, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"[t6t14] wired {wiring['wired_block_count']} block uses, "
          f"{len(wiring['wired_distinct_blocks'])} distinct winter blocks "
          f"(need 27). tinted={tinted_pct:.2f}%")
    for k, v in wiring["outputs"].items():
        print(f"[t6t14] wrote {k} {v['size']} sha256={v['sha256'][:16]}")
    print(f"[t6t14] wiring -> {wiring_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
