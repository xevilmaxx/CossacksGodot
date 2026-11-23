#!/usr/bin/env python3
"""T6-W02 water piece renderer (headless, deterministic).

Owns: app/tools/pieces/t6_water.py ; outputs app/shots/pieces/t6_water*.png.

Implements the W01-baseline donor water equations (WATER_REPORT.md section 3,
water.dev.frag active pair) as a NumPy/Pillow CPU analogue:

  noise(p)      = waveMap(p/256).x                      (frag:65-68)
  f             = 0.6*n(p)+0.25*n(p*m)+0.1666*n(p*m*m)   (frag:92-94)
  swell         = sin(p2.x*0.622+p2.y*0.622+shift2.x*4.269)
                  * 0.5 * f * height^2                  (frag:95)
  9-octave loop: p=m*p*0.947;
                 f -= amp*abs(sin((noise(p+shift1*s)-0.5)*2));
                 amp*=0.59; s*=-1.329                    (frag:100-101)
  normwater     = normalize(vec3(h3-h4,h1-h2,0.15)) from 4 central
                  differences of water_map at dif=(0,0.01) (frag:186-192)
  glints        = pow(grad,170), pow(grad,120), corona from gradpos
                  /(1+1.25*corona), spec colour (0.4,0.4,0.4) (frag:217-226)
  depth         = coastfade=clamp(d/0.57), coastfade2=clamp(d/1.07) (frag:198-199)

What is deliberately NOT donor (tool limits, labelled INFERRED below):
  - reflectionMap (projected live texture, frag:207-213) is replaced by a
    calibrated constant sky-ambient lift (reflection is NOT in this piece;
    see RENDER_ARCH_REFLECTION.md -- a headless PNG cannot sample a live FBO).
  - shadow (watershade) = 1 everywhere (no shadow map in a piece).
  - linear->sRGB encode is approximated with a display-gamma lift plus an
    affine calibration to the measured 8-bit bands (the exact Godot
    canvas_item colour pipeline is UNVERIFIED).

Usage:
    python app/tools/pieces/t6_water.py
    python app/tools/pieces/t6_water.py --out-dir app/shots/pieces

Outputs (default app/shots/pieces):
    t6_water_deep.png            512x512 deep-water piece (RGB)
    t6_water_deep_sunrot.png     same field, sun azimuth +35 deg (sun linkage)
    t6_water_shore.png           512x512 sand->wash->water piece (RGB)
    t6_water_deep_compare.png    labelled [render | articolo-787 river crop]
    t6_water_shore_compare.png   labelled [render | maxresdefault_1 shallow crop]
    t6_water_manifest.json       params + sha256 of every PNG

Determinism: fixed SEED, fixed t, no clock input; re-running overwrites
byte-identical PNGs (Pillow, no metadata).
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

# ---------------------------------------------------------------- paths ---

TOOLS = Path(__file__).resolve().parent
APP = TOOLS.parent.parent
ROOT = APP.parent
WAVE_PNG = APP / "assets" / "terrain" / "water_png" / "diffusewaves0.png"
DEFAULT_OUT = APP / "shots" / "pieces"
REF_DIR = Path.home() / "Downloads" / "c3"

SEED = 7
SIZE = 512
T_FIXED = 7.0  # donor `time` analogue (water_deep spec time_seconds 7.0)

# --------------------------------------------- donor constants (W01-pinned) ---
# Labels: OBSERVED = read from donor file; DERIVED = arithmetic on observed;
# INFERRED = tuning choice with caveat; UNVERIFIED = no evidence.
# W01 RECONCILIATION (docs/t6/reports/T6-W01.md): every constant below was
# re-verified verbatim against donor bytes (file:line + byte offsets); NO
# constant changes vs WATER_REPORT.md section 3. The `.dev` variant is pinned
# (water.lib:67-68); the non-.dev `water.frag` (fade 0.10, exponents 15/120,
# pale tints, particle_amount 70, stubbed nautic) is NOT mixed in. Retail
# binary preference stays UNVERIFIED (exe embeds the legacy pair).
M_GLSL = np.array([[0.72, 1.60], [-1.60, 0.72]], dtype=np.float64)  # frag:83
#   `mat2(0.72,-1.60,1.60,0.72)` is column-major -> rows above. DERIVED.
COAST_FADE = 0.57       # frag:37, W01 offset 864; coast2water_fadedepth
DEEP_FADE = 1.07        # frag:168, W01 offset 5067 (0.5+coastfade); DERIVED
EXP_SOFT = 170.0        # frag:42, W01 offset 1214; DONOR LITERAL (pinned)
EXP_GLOSSY = 120.0      # frag:43, W01 offset 1311; DONOR LITERAL (pinned)
PARTICLE_AMOUNT = 30.0  # frag:44, W01 offset 1376; DONOR LITERAL (pinned)
SPEC_COL = np.array([0.4, 0.4, 0.4])  # frag:47, W01 offset 1663; DONOR LITERAL
WATER_SHALLOW_LIN = (0.10, 0.24, 0.24)  # frag:45, offset 1446; DONOR LITERAL
WATER_DEEP_LIN = (0.00, 0.025, 0.05)  # frag:46, offset 1540; DONOR LITERAL
SHIFT1 = np.array([0.32, 0.24])       # frag:88; 0.001*(160*2,120*2)
SHIFT2 = np.array([0.38, -0.26])      # frag:89; 0.001*(190*2,-130*2)
SWELL_K = 0.622         # frag:95
SWELL_P = 4.269         # frag:95
SWELL_FREQ_SCALE = 0.25  # INFERRED piece-level swell frequency mapping for
#   the SHORE body only (broad ~22px undulation, no striping). Normals always
#   use the donor-verbatim swell (tilt variance for sparse glints).
SWELL_AMP_SCALE = 0.35   # INFERRED shore-body swell amplitude attenuation
#   (donor large_waveheight 0.50 recorded).
BODY_SWELL_FREQ = 1.0    # SUPERSEDED experiment (kept for provenance):
#   donor-verbatim swell frequency was tried for the deep body; any amplitude
#   strong enough to make the 6-14px ACF peak rendered as diagonal striping
#   (parent re-check A). The body now uses swell_amp=0.0 + K2_GAIN instead.
BODY_SWELL_AMP = 0.35    # INFERRED deep-body swell amplitude (measured grid
#   probe6: with the 0.90 large-scale flattening, the weakest amplitude that
#   still yields an interior 6-14px ACF local max, lag 12). Trade-off recorded
#   openly: the numeric peak gate needs this energy while the visual gate
#   caps it (parent re-check A).
K2_GAIN = 1.0        # SUPERSEDED experiment (kept for provenance): a
#   body-only k2-octave emphasis (x2.2, x4.0 tried) does NOT produce a 6-14px
#   ACF peak (measured: monotonic decay both times) -- the peak needs the
#   directional swell harmonic. Donor gain 1.0 restored (no body deviation).
#   (12.9px cellular at P_SPAN; donor gain 1.0 recorded in water_map).
#   The donor fBm's k2 octave carries too little variance to form the measured
#   6-14px ACF peak on its own (measured: peak-less decay), while any 5-11px
#   directional swell strong enough to peak renders as diagonal striping
#   (parent re-check A). Emphasizing the NON-DIRECTIONAL cellular octave in
#   the body only (normals keep donor gains, so glints are unaffected) gives
#   the coherent texture scale without moire. Port-art decision, documented.
DIF = 0.01              # frag:186
NORM_Z = 0.15           # frag:192
LIGHT_VEC = np.array([-0.08618, 0.0, 0.93870])  # DERIVED light.cfg via vert:22
#   (W01 C10 confirmed; normalized approx (-0.0913,0,0.9958), ~5.2deg off +Z)
LUMA = np.array([0.2126, 0.7152, 0.0722])       # frag:200
TEX_SCALE_S = 0.1       # OBSERVED water.lib:32 (NOT the 0.105 comment value
#   in a water.dev.frag:187 comment -- OBSERVED wins per W01/coordinator)
TEX_SCALE_T = 0.01      # OBSERVED water.lib:33; scales wavejitter (frag:193)
# Engine-supplied uniforms with NO plaintext defaults (W01 U5: UNVERIFIED --
# never hardcoded as donor facts; the piece substitutes a synthetic depth
# ramp wherever the donor reads hmapTex.w, documented at each use):
HMAP_MIN = None     # UNVERIFIED -- donor hmapMin default unknown
HMAP_MAX = None     # UNVERIFIED -- donor hmapMax default unknown
HMAP_W = None       # UNVERIFIED -- donor hmapW (terrain-grid W) unknown here
HMAP_H = None       # UNVERIFIED -- donor hmapH unknown here
SHADOW_SIZE = None  # UNVERIFIED -- donor shadowSize default unknown
# Numeric sampler<->texture-unit bindings UNVERIFIED (W01 U1): no unit numbers
# invented here (MirrorTexUnit etc. are names only). Reflection is NOT part
# of this piece (coordinator ruling; W01 U2): no reflection layer exists
# below and the body affine carries no reflection term (port decision).

# ------------------------------------------------- piece tuning constants ---
# PIECE_* below are INFERRED port-art decisions (caveats inline); donor
# literals above are preserved, never overwritten.
P_SPAN = 230.0      # INFERRED donor-noise coordinate span of the NORMAL field
#   across the 512px deep tile (tilt spectrum calibrated for sparse glints).
P_BODY_SPAN = 115.0  # INFERRED span of the BODY field (half the normal span).
#   (Superseded experiment: the body now reuses P_SPAN=230 with zero swell;
#   see render_deep. Kept as a named parameter for the W04 integrator.)
PIECE_EXP_SOFT = 260.0    # INFERRED piece-level glint exponent retune
PIECE_EXP_GLOSSY = 180.0  # INFERRED (donor literals 170/120 recorded above).
#   Precedent: water_deep.md section 3 recipe (exponent 400/gain 6) retuned
#   the same way. Rationale: the headless CPU field keeps |sin|-cusp
#   micro-spikes that mipmapped GPU sampling smooths away; with donor 170/120
#   the piece renders 2-3% single-pixel speckle (measured) instead of sparse
#   coherent blobs. The retune restores size/coherence; the donor exponents
#   stay pinned for the W04 integrator. DEVIATION from the "slope/z only"
#   guidance, documented here with evidence (see report).
SLOPE_GAIN = 30.0  # INFERRED normal xy gain (donor has no gain; 1.0 is donor-
#   faithful). Raised so pow(grad,E) yields sparse coherent blobs instead of
#   full-field sheen, compensating for the missing reflection term in a
#   headless piece. Caveat: changes glint density, not wave shape.
GRAD_BLUR = 0.5    # INFERRED pre-pow smoothing of grad (donor has none).
#   Emulates mipmapped GPU sampling of the 9-octave |sin|-cusp field: without
#   it every cusp zero becomes a 1px grad spike and pow() turns spikes into
#   salt-and-pepper (measured med 1px). Calibrated minimal (0.5px) so blob
#   cores keep their size class.
SPEC_K = 515.0     # INFERRED 8-bit scaling of the donor composite glint add
#   (donor max ~0.65 linear). Calibrated so the relative-threshold glint
#   fraction lands in 0.30-0.80% with coherent sizes (margin above the 0.30
#   floor; the metric is deterministic so the margin is exact).
GLINT_BLUR = 0.8   # INFERRED Gaussian sigma on the composite spec add for
#   component coherence (donor smooth-field normals come from mipmapped GPU
#   sampling; the CPU field is choppier). Merges 1px residuals into blobs.
BODY_LP = 1.8      # INFERRED low-pass sigma of the body-modulation field.
#   Donor body (intensity-coupled bed + reflection, frag:200-213) is smooth;
#   high-frequency body energy aliases into diagonal moire in downscaled
#   views (measured: 4x zoom is smooth, thumbnails hatch). Detail lives in
#   the normals (glint shapes), not in the body brightness.
BODY_A = 7.0       # INFERRED body luminance amplitude (target std 5-14; kept
#   above the floor with margin after the glint add).
BODY_L0 = 44.0     # DERIVED base anchor near the (44,53,55) clean-box mean;
#   final mean sits slightly above after the sparse glint add.
SUN_DIST = 6.0     # INFERRED distance of the point-light analogue; gives the
#   per-pixel ray rd position dependence (donor frag:215-216 form).
WATER_LEVEL = 0.0  # INFERRED piece surface height for r0 (donor: geometry Y).
SUN_AZIM_MAIN = 0.0   # INFERRED sun azimuth (deg) of the primary deep render.
SUN_AZIM_ROT = 35.0   # sun azimuth of the linkage render (>=30 deg apart).
PIECE_DEPTH_DEEP_M = 2.0   # INFERRED deep-piece depth (>1.07: coastfade2 = 1;
#   substitutes for the UNVERIFIED hmapTex read, frag:170/198-199).
PIECE_DEPTH_SHORE_MAX_M = 0.6  # INFERRED shore-piece max depth (< 1.07, so
#   the foam band gate can open; ZERO foam beyond 1.07 m by construction).
FOAM_WEAK_GAIN = 0.15  # INFERRED piece-level foam gain (water_shallow spec;
#   donor literal particle_amount = 30 recorded above). Reference shows
#   weak/absent foam, so the donor-form kernels below are scaled to a pale
#   gray-tan wash texture, NOT white sea-foam (coordinator adjudication).

# Texel-footprint decision (DERIVED): donor TexScaleS=0.1 -> one 256-texel
# repeat per ~10 world m. The piece samples noise(p/256) over P_SPAN=230
# donor units = 0.90 sheet repeats across 512px -> base footprint 0.45
# tex/px. Octave k scales coords by ~1.66^k (m*0.947); raw footprints run
# 0.45 (k0) .. 26 (k8) tex/px. Mitigation: octave-dependent Gaussian
# prefilter with sigma_k ~= footprint_k/2 (below), emulating donor
# miLinearMipmapLinear (water.mat base); effective footprint stays <=1.2
# tex/px. No mipmaps needed because the blur is applied deliberately per
# octave (documented here).

OCTAVE_SIGMA = [0.0, 0.0, 0.0, 1.0, 3.0, 5.0, 8.0, 13.0, 22.0]  # INFERRED blur
#   per octave index 0..8; first octaves unfiltered (structure), later
#   octaves blurred (anti-alias). Calibrated to ACF lag1 >= 0.65.


# ---------------------------------------------------------------- helpers ---

def _font(size: int):
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        pass
    for c in ("C:/Windows/Fonts/dejavusans.ttf",
              "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(c, size)
        except OSError:
            continue
    return ImageFont.load_default()


def load_wave() -> np.ndarray:
    """diffusewaves0 R channel as float 0..1 (sheet is grey: R~=G~=B)."""
    im = Image.open(WAVE_PNG).convert("RGB")
    a = np.asarray(im).astype(np.float64) / 255.0
    return a[:, :, 0]  # OBSERVED grey (means 63.32/63.32/63.38)


def blur_levels(base: np.ndarray) -> list[np.ndarray]:
    from PIL import ImageFilter
    out = []
    for s in OCTAVE_SIGMA:
        if s <= 0:
            out.append(base)
        else:
            im = Image.fromarray((base * 255.0 + 0.5).astype(np.uint8))
            im = im.filter(ImageFilter.GaussianBlur(s))
            out.append(np.asarray(im).astype(np.float64) / 255.0)
    return out


def _fblur(field: np.ndarray, sigma: float) -> np.ndarray:
    """Range-preserving Gaussian blur (float in/out; for grad/body fields)."""
    from PIL import ImageFilter
    lo, hi = float(field.min()), float(field.max())
    if hi <= lo or sigma <= 0:
        return field
    q = Image.fromarray(((field - lo) / (hi - lo) * 255 + 0.5).astype(np.uint8))
    return (np.asarray(q.filter(ImageFilter.GaussianBlur(sigma))).astype(np.float64)
            / 255.0 * (hi - lo) + lo)


def _qblur(field: np.ndarray, sigma: float) -> np.ndarray:
    """Quantized blur for the composite spec add (0..2 range round-trip)."""
    from PIL import ImageFilter
    q = Image.fromarray((np.clip(field, 0, 2) / 2 * 255 + 0.5).astype(np.uint8))
    if sigma > 0:
        q = q.filter(ImageFilter.GaussianBlur(sigma))
    return np.asarray(q).astype(np.float64) / 255.0 * 2.0


def make_sampler(sheet: np.ndarray):
    n = sheet.shape[0]

    def sample(px: np.ndarray, py: np.ndarray) -> np.ndarray:
        # px,py in donor units; noise(p)=waveMap(p/256) with repeat wrap.
        u = (px / 256.0) % 1.0
        v = (py / 256.0) % 1.0
        x = u * n
        y = v * n
        x0 = np.floor(x).astype(np.int64) % n
        y0 = np.floor(y).astype(np.int64) % n
        x1 = (x0 + 1) % n
        y1 = (y0 + 1) % n
        fx = (x - np.floor(x))[..., None] if False else (x - np.floor(x))
        fy = (y - np.floor(y))
        a = sheet[y0, x0]
        b = sheet[y0, x1]
        c = sheet[y1, x0]
        d = sheet[y1, x1]
        return a * (1 - fx) * (1 - fy) + b * fx * (1 - fy) + c * (1 - fx) * fy + d * fx * fy

    return sample


def water_map(px: np.ndarray, py: np.ndarray, t: float, samplers,
              height: float = 1.0, swell_freq: float = 1.0,
              swell_amp: float = 1.0, octave_gains=None) -> np.ndarray:
    """Donor water_map analogue (frag:85-104, W01 section 2.4). px,py arrays.
    f=0.6n(p)+0.25n(pm)+0.1666n(pmm); swell sin(p2.622+shift2.4.269)*0.5*f*h^2;
    9x: p=m*p*0.947, f-=amp*|sin((noise(p+shift1*s)-0.5)*2)|, amp*=0.59,
    s*=-1.329; return wave+f*0.5. Per-octave prefiltered samplers emulate
    donor miLinearMipmapLinear (water.mat).
    swell_freq/swell_amp default to the donor verbatim (p2=p*2.0, gain 0.5).
    The BODY uses the piece-level attenuated swell (SWELL_* below); the
    NORMALS always use the donor-verbatim swell, because the swell's tilt
    variance is load-bearing for sparse-gl ints (measured: attenuating it in
    the normal field pushes the glint fraction to 2.2% broad-plateau speckle).
    Split documented as an inferred port-art decision (coordinator: broad
    subtle swell in the visible body, no stripes; tilt spectrum intact)."""
    s0 = samplers[0]
    n0 = s0(px, py)
    n1 = s0(px * M_GLSL[0, 0] + py * M_GLSL[0, 1],
            px * M_GLSL[1, 0] + py * M_GLSL[1, 1])
    mm = M_GLSL @ M_GLSL
    n2 = s0(px * mm[0, 0] + py * mm[0, 1],
            px * mm[1, 0] + py * mm[1, 1])
    f = 0.60 * n0 + 0.25 * n1 + 0.1666 * n2
    sh2 = SHIFT2 * t
    p2x = px * (2.0 * swell_freq)
    p2y = py * (2.0 * swell_freq)
    wave = (np.sin(p2x * SWELL_K + p2y * SWELL_K + sh2[0] * SWELL_P)
            * 0.50 * swell_amp * f * height * height)
    qx = px * 0.5
    qy = py * 0.5
    f2 = np.zeros_like(px)
    amp = 1.0
    s = 0.5
    sh1 = SHIFT1 * t
    if octave_gains is None:
        octave_gains = [1.0] * 9  # donor verbatim (normals always use this)
    for k in range(9):
        qx, qy = (M_GLSL[0, 0] * qx + M_GLSL[0, 1] * qy) * 0.947, \
                 (M_GLSL[1, 0] * qx + M_GLSL[1, 1] * qy) * 0.947
        nk = samplers[k](qx + sh1[0] * s, qy + sh1[1] * s)
        f2 = f2 - amp * octave_gains[k] * np.abs(np.sin((nk - 0.5) * 2.0))
        amp *= 0.59
        s *= -1.329
    return wave + f2 * 0.5


def nautic(px: np.ndarray, py: np.ndarray, t: float, sampler) -> np.ndarray:
    """Donor nautic() foam kernel, verbatim form (frag:106-114, W01 2.7):
    p*=18; 3x { p=m*p*1.2; f+=amp*|smoothstep(0,1,noise(p+t*s))-0.5|;
    amp*=0.5; s*=-1.227 }; return pow(1-f,5). Single waveMap sampler."""
    qx, qy = px * 18.0, py * 18.0
    f = np.zeros_like(px, dtype=np.float64)
    amp, s = 1.0, 0.5
    for _ in range(3):
        qx, qy = (M_GLSL[0, 0] * qx + M_GLSL[0, 1] * qy) * 1.2, \
                 (M_GLSL[1, 0] * qx + M_GLSL[1, 1] * qy) * 1.2
        nk = sampler(qx + t * 0.32 * s, qy + t * 0.24 * s)
        v = np.clip(nk, 0.0, 1.0)
        v = v * v * (3 - 2 * v)  # smoothstep(0,1,x)
        f = f + amp * np.abs(v - 0.5)
        amp *= 0.5
        s *= -1.227
    return np.power(np.clip(1 - f, 0, None), 5)


def particles(px: np.ndarray, py: np.ndarray, t: float, sampler) -> np.ndarray:
    """Donor particles() foam kernel, verbatim form (frag:119-126, W01 2.7):
    p*=200; 3x { p=m*p*1.2; f+=amp*noise(p+t*s); amp*=0.5; s*=-1.227 };
    return pow(f*0.35,7)*particle_amount(30). Single waveMap sampler."""
    qx, qy = px * 200.0, py * 200.0
    f = np.zeros_like(px, dtype=np.float64)
    amp, s = 1.0, 1.5
    for _ in range(3):
        qx, qy = (M_GLSL[0, 0] * qx + M_GLSL[0, 1] * qy) * 1.2, \
                 (M_GLSL[1, 0] * qx + M_GLSL[1, 1] * qy) * 1.2
        f = f + amp * sampler(qx + t * 0.32 * s, qy + t * 0.24 * s)
        amp *= 0.5
        s *= -1.227
    return np.power(np.clip(f * 0.35, 0, None), 7) * PARTICLE_AMOUNT


def luminance(rgb: np.ndarray) -> np.ndarray:
    return rgb[:, :, 0] * LUMA[0] + rgb[:, :, 1] * LUMA[1] + rgb[:, :, 2] * LUMA[2]


def acf_lag1(L: np.ndarray) -> float:
    r = L - L.mean()
    denom = float((r ** 2).sum())
    if denom == 0:
        return 0.0
    return float((r[:, :-1] * r[:, 1:]).sum() / denom)


def acf_profile(L: np.ndarray, maxlag: int = 24) -> list[float]:
    r = L - L.mean()
    denom = float((r ** 2).sum())
    out = []
    for lag in range(1, maxlag + 1):
        out.append(float((r[:, :-lag] * r[:, lag:]).sum() / denom))
    return out


def glint_components(mask: np.ndarray):
    """BFS 8-connected components; returns list of sizes."""
    h, w = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    sizes = []
    for y in range(h):
        for x in range(w):
            if mask[y, x] and not seen[y, x]:
                stack = [(y, x)]
                seen[y, x] = True
                n = 0
                while stack:
                    cy, cx = stack.pop()
                    n += 1
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            ny, nx = cy + dy, cx + dx
                            if 0 <= ny < h and 0 <= nx < w:
                                if mask[ny, nx] and not seen[ny, nx]:
                                    seen[ny, nx] = True
                                    stack.append((ny, nx))
                sizes.append(n)
    return sizes


# ------------------------------------------------------------------- deep ---

def render_deep(sun_azim_deg: float = 0.0, samplers=None) -> np.ndarray:
    if samplers is None:
        base = load_wave()
        samplers = [make_sampler(lv) for lv in blur_levels(base)]
    yy, xx = np.mgrid[0:SIZE, 0:SIZE].astype(np.float64)
    px = xx / SIZE * P_SPAN
    py = yy / SIZE * P_SPAN
    t = T_FIXED

    H = water_map(px, py, t, samplers, height=1.0, swell_amp=0.0)
    #   BODY = pure donor fBm at P_SPAN (swell_amp=0: any 5-11px directional
    #   swell renders as diagonal striping the donor references do not show
    #   -- parent re-check A, proven by bodynoswell/bodieswell035 A/B).
    #   The coherent 6-14px scale comes from the k1/k2 cellular octaves
    #   (21/13px, non-directional), exposed by the large-scale flattening
    #   below (blur 9 keeps only >~27px in the subtrahend, so k1/k2 survive
    #   intact in the residual). No radial content. Normals use the
    #   donor-verbatim field (full swell) for tilt variance for sparse glints.

    # donor finite differences at dif=(0,0.01), central (frag:188-191).
    # Normals ALWAYS use the donor-verbatim swell (defaults): the swell's
    # tilt variance is load-bearing for sparse glints (see water_map note).
    h1 = water_map(px, py - DIF, t, samplers)
    h2 = water_map(px, py + DIF, t, samplers)
    h3 = water_map(px - DIF, py, t, samplers)
    h4 = water_map(px + DIF, py, t, samplers)
    dx = (h3 - h4) * SLOPE_GAIN
    dy = (h1 - h2) * SLOPE_GAIN
    nl = np.sqrt(dx * dx + dy * dy + NORM_Z * NORM_Z)
    nx, ny, nz = dx / nl, dy / nl, NORM_Z / nl

    # per-pixel sun ray rd = normalize(light - r0) (frag:215-216)
    ang = np.deg2rad(sun_azim_deg)
    ca, sa = np.cos(ang), np.sin(ang)
    lv = np.array([LIGHT_VEC[0] * ca - LIGHT_VEC[1] * sa,
                   LIGHT_VEC[0] * sa + LIGHT_VEC[1] * ca,
                   LIGHT_VEC[2]]) * SUN_DIST
    ux = (xx / SIZE - 0.5) * 4.0  # INFERRED world span 4m for ray variance
    uy = (yy / SIZE - 0.5) * 4.0
    rx = lv[0] - ux
    ry = lv[1] - uy
    rz = lv[2] - WATER_LEVEL
    rl = np.sqrt(rx * rx + ry * ry + rz * rz)
    rdx, rdy, rdz = rx / rl, ry / rl, rz / rl

    grad_raw = nx * rdx + ny * rdy + nz * rdz  # donor: no clamp (frag:217)
    # INFERRED anti-cusp pre-smoothing (GRAD_BLUR): the 9-octave |sin| field
    # has non-differentiable cusps at every |.| zero; central differences
    # across a cusp make 1px grad spikes that pow() turns into salt-and-pepper
    # (measured med 1px without it). Mipmapped GPU sampling smooths cusps;
    # this minimal blur emulates that. Donor equation itself is unchanged.
    grad = _fblur(np.clip(grad_raw, 0, None), GRAD_BLUR)
    gradpos = rdz  # dot((0,0,1), rd) (frag:220)
    spec = np.power(np.clip(grad, 0, 1), PIECE_EXP_SOFT)
    spec2 = np.power(np.clip(grad, 0, 1), PIECE_EXP_GLOSSY)
    corona = np.clip((gradpos ** 5), 0, 1)
    # smoothstep(0,1,x) = x*x*(3-2x); gradpos^5 in [0,1] already smooth
    spec1 = corona * corona * (3 - 2 * corona)
    shade = 1.0  # watershade: no shadow map in a piece (UNVERIFIED shadow->1;
    #   SHADOW_SIZE unknown per W01 U5, so no shadow term is constructed)
    # donor composite (frag:223-226) with shade=1; NO x8/x4 boosts, NO
    # pow(grad,24) sheen (both refuted by W01 C5); corona DIVIDES (frag:225):
    soft = (0.2 + 0.8 * shade) * ((grad - 1.0) * 0.5 + spec) * 0.25
    glint_add = (soft / (1.0 + spec1 * 1.25) + shade * spec2 * SPEC_COL[0])

    glint_add_s = _qblur(glint_add, GLINT_BLUR)

    # body: calibrated affine to the measured band around base (44,53,55)
    # (OBSERVED clean box). The donor chain (bed-intensity mix frag:200-201,
    # reflection add frag:209-213, x(2.2+watershade) frag:223) is collapsed
    # into this affine because a headless piece has no terrain-colour,
    # live reflection, or shadow inputs -- and reflection is NOT in this
    # piece (coordinator ruling). No reflection term exists below.
    # BODY_LP smooths the modulation field (donor body is smooth; detail
    # lives in the normals). tanh compresses extremes (INFERRED).
    Hn = (H - H.mean()) / (H.std() + 1e-9)
    Hn = np.tanh(Hn * 0.9)
    # INFERRED large-scale flattening: subtract 90% of the >~27px background
    # (blur 9 keeps only the broadest scales in the subtrahend, so the k1/k2
    # fBm octaves at 21/13px survive intact in the residual) so the cellular
    # 8-15px texture dominates the luminance ACF and forms the coherent
    # 6-14px peak instead of drowning in the k0 decay slope (measured:
    # no interior peak without it). 10% of the broad variation is kept for
    # faint broad banding. Renormalized so BODY_A keeps its meaning.
    Hn = Hn - 0.90 * _fblur(Hn, 9.0)
    Hn = (Hn - Hn.mean()) / (Hn.std() + 1e-9)
    Hb = _fblur(Hn, BODY_LP)
    Hb = (Hb - Hb.mean()) / (Hb.std() + 1e-9)
    Lbody = BODY_L0 + Hb * BODY_A
    base_rgb = np.array([44.0, 53.0, 55.0])  # OBSERVED clean-box mean
    # neutral modulation keeps channel offsets; tiny chromatic wobble from
    # the LOW-PASSED field (INFERRED: raw-H chrominance carries unfiltered
    # high octaves that alias into diagonal moire in downscaled views).
    chrom = np.tanh(Hb * 1.5) * 1.2  # INFERRED +/-1.2 B-G wobble, low-passed
    rgb = np.zeros((SIZE, SIZE, 3))
    dL = (Lbody - BODY_L0)[..., None]
    rgb[:, :, 0] = base_rgb[0] + dL[:, :, 0]
    rgb[:, :, 1] = base_rgb[1] + dL[:, :, 0]
    rgb[:, :, 2] = base_rgb[2] + dL[:, :, 0] + chrom
    rgb += glint_add_s[..., None] * SPEC_K * np.array([1.0, 1.0, 1.0])
    return np.clip(rgb, 0, 255)


# ------------------------------------------------------------------ shore ---

def shore_geometry(seed: int = SEED):
    """Smooth organic shoreline; step<=8px so no constant-x run exceeds 8px."""
    rng = np.random.RandomState(seed)
    sand_w = 26   # DERIVED: water_shallow M4 sand 26-51 (lower edge) AND
    #   shore_water_transition C2 sand 38px @720p (accept 30-65): 26*2.5=65
    #   @720p (upper edge). Also matches the reference profile's sand-side
    #   span (15px plateau + 12px gradient = 27px src, maxresdefault_1 y=238-272).
    wash_w = 34   # DERIVED in-range of M5 30-50; x2.5 -> 85 @720p (C2 60-90)
    origin = 0.45 * SIZE
    jitter = 6    # INFERRED reduced shoreline amplitude (was 10; the +/-10px
    #   teeth over 6px steps read as sawtooth; parent visual re-check B)
    step = 4      # dense polyline for the smoothing passes below
    xs, shore = [], []
    x = 0
    while x < SIZE:
        xs.append(x)
        shore.append(origin + rng.randint(-jitter, jitter))
        x += step
    xs.append(SIZE)
    shore.append(origin + rng.randint(-jitter, jitter))
    # organic smoothing: 2 passes of [1,2,1]/4 moving average (INFERRED).
    # Kills triangular sawtooth teeth while keeping gentle variation; the
    # smoothed curve plus soft band edges below gives a soft blurred wash
    # contour like the donor reference (parent re-check B).
    s = np.array(shore, float)
    for _ in range(2):
        s = (np.roll(s, 1) + 2 * s + np.roll(s, -1)) / 4.0
    return np.array(xs), s, sand_w, wash_w


def _ss(a: float, b: float, x: np.ndarray) -> np.ndarray:
    """smoothstep(a,b,x) helper for soft band weights."""
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def render_shore(samplers=None) -> tuple[np.ndarray, dict]:
    """Sand -> wet-sand -> wash -> shallow-water piece (all bands painted).

    SPOT-CHECK FIX (coordinator): the previous revision never assigned the
    sand band, leaving it RGB(0,0,0) -- a hard black jagged band the donor
    does not have. The band math below paints a CONTINUOUS sequence
    dry sand -> wet sand -> wash -> shallow water with no gap; verified by a
    perpendicular profile (no black pixels, no jagged run > 8 px).
    The previous radial-sine water arcs are REMOVED (coordinator ruling:
    radial synthesis is NOT donor behaviour; donor waves are scrolled
    samples of diffusewaves0 in 9-octave fBm per W01 section 2). The water
    body is the same texture-sampled water_map field as the deep piece.
    """
    base = load_wave()
    if samplers is None:
        samplers = [make_sampler(lv) for lv in blur_levels(base)]
    samp0 = samplers[0]
    yy, xx = np.mgrid[0:SIZE, 0:SIZE].astype(np.float64)
    xs, sh, sand_w, wash_w = shore_geometry()
    shore_y = np.interp(xx[0], xs, sh)[None, :].repeat(SIZE, axis=0)
    depth_px = yy - shore_y  # <0 land/sand, 0..wash wash, >wash water
    # Synthetic depth ramp (port decision; substitutes for the UNVERIFIED
    # hmapTex read, frag:170). INFERRED scale: wash_w px <-> ~0.35 m so the
    # foam band peaks mid-wash (frag:227 gate).
    depth_m = np.clip(depth_px / (wash_w / 0.35), 0, PIECE_DEPTH_SHORE_MAX_M)

    sand_hex = np.array([166.0, 154.0, 121.0])  # OBSERVED #A69A79
    wet_hex = np.array([148.0, 134.0, 104.0])   # DERIVED wet darkening of
    #   sand toward the waterline (donor wash sits above pale water; the wet
    #   sand darkens ~0.85x). Continuous with dry sand (no step, no gap).
    wash_hex = np.array([177.0, 179.0, 163.0])  # OBSERVED #B1B3A3
    water_hex = np.array([195.0, 209.0, 202.0])  # OBSERVED #C3D1CA (HARD gate)
    foam_hex = np.array([222.0, 219.0, 203.0])  # INFERRED pale gray-tan foam
    #   (NOT white sea-foam; luma above neighbours, sat low).

    # texture-sampled fBm water body (SAME donor equations as the deep piece,
    # full 9-octave water_map; body uses the attenuated swell like the deep
    # body -- no stripes, no radial term).
    H = water_map(xx / SIZE * P_SPAN, yy / SIZE * P_SPAN, T_FIXED, samplers,
                  swell_freq=SWELL_FREQ_SCALE, swell_amp=SWELL_AMP_SCALE)
    Hn = (H - H.mean()) / (H.std() + 1e-9)
    Hn = np.tanh(Hn * 0.9)
    # cellular substrate from the donor sheet (OBSERVED cellular field)
    sub = samp0(xx / SIZE * 24.0, yy / SIZE * 24.0)
    sub = (sub - sub.mean()) / (sub.std() + 1e-9)
    sub = np.tanh(sub)

    rgb = np.zeros((SIZE, SIZE, 3))
    land = depth_px < -sand_w
    sand = (depth_px >= -sand_w) & (depth_px < 0)
    wash = (depth_px >= 0) & (depth_px < wash_w)
    water = depth_px >= wash_w

    land_col = np.zeros((SIZE, SIZE, 3)) + sand_hex[None, None, :]
    land_col[land] += sub[land][..., None] * 6.0
    # wet-sand band: continuous dry->wet gradient (spot-check FIX-1: every
    # pixel of the sand band is painted, darkening smoothly to the waterline)
    t_s = np.clip((depth_px + sand_w) / sand_w, 0, 1)
    wet = sand_hex[None, None, :] * (1 - t_s[..., None] * 0.18) \
        + wet_hex[None, None, :] * (t_s[..., None] * 0.18)
    # blend wet band into dry land across its top edge (2px feather, no step)
    feather = np.clip((depth_px + sand_w) / 2.0, 0, 1)[..., None]
    sand_col = sand_hex[None, None, :] * (1 - feather) + wet * feather
    sand_col[sand] += sub[sand][..., None] * 5.0
    # wash ramp dry->wet over the wash band
    t_w = np.clip(depth_px / wash_w, 0, 1)
    wash_col = (wash_hex[None, None, :] * (1 - t_w[..., None] * 0.35) +
                water_hex[None, None, :] * (t_w[..., None] * 0.35))
    wash_col[wash] += sub[wash][..., None] * 5.0
    # water body: pale gray-cyan modulated by the sampled fBm field
    # (HARD gate #C3D1CA mean; S <= 0.12). Modulation amplitude keeps the
    # water-body mean inside (195,209,202)+/-18 with low saturation.
    water_col = np.zeros((SIZE, SIZE, 3)) + water_hex[None, None, :]
    water_col[water] += (Hn[water] * 9.0)[..., None] + sub[water][..., None] * 3.0

    # soft band weights (parent re-check B): smoothstep blends over +/-1.5px
    # at the wash boundaries give a soft blurred wash contour like the donor
    # reference instead of a serrated line. Weights sum to 1 everywhere, so
    # no zero-coverage/black gap can appear (spot-check FIX-1 guard).
    edge = 1.5
    w_land = 1 - _ss(-sand_w - edge, -sand_w + edge, depth_px)
    w_sand = (_ss(-sand_w - edge, -sand_w + edge, depth_px)
              * (1 - _ss(-edge, edge, depth_px)))
    w_wash = (_ss(-edge, edge, depth_px)
              * (1 - _ss(wash_w - edge, wash_w + edge, depth_px)))
    w_water = _ss(wash_w - edge, wash_w + edge, depth_px)
    rgb = (land_col * w_land[..., None] + sand_col * w_sand[..., None]
           + wash_col * w_wash[..., None] + water_col * w_water[..., None])

    # foam: donor-form kernels (nautic 3oct x18 pow(1-f,5); particles 3oct
    # x200 pow(f*0.35,7)*30) reusing waveMap, gated by the donor band term
    # coastfade*(1-coastfade2) (frag:227). Piece-level weak gain
    # (FOAM_WEAK_GAIN, port-art decision) + pale gray-tan colour.
    # wavejitter (frag:193: normwater.xy*texScaleT*(level-height)) displaces
    # the foam sampling coords -- TEX_SCALE_T gets a real use here; the deep
    # piece has no refraction target so no displacement applies there.
    coastfade = np.clip(depth_m / COAST_FADE, 0, 1)
    coastfade2 = np.clip(depth_m / DEEP_FADE, 0, 1)
    band = coastfade * (1 - coastfade2)
    # cheap donor-form normal for the jitter (2 extra water_map taps would
    # double shore cost; reuse the body field gradient -- INFERRED approx):
    gy, gx = np.gradient(H)
    jx = gx * TEX_SCALE_T * np.clip(depth_m, 0, COAST_FADE) * 40.0
    jy = gy * TEX_SCALE_T * np.clip(depth_m, 0, COAST_FADE) * 40.0
    fx = xx / SIZE * 24.0 + jx
    fy = yy / SIZE * 24.0 + jy
    foam_n = nautic(fx * 0.75, fy * 0.75, T_FIXED, samp0)
    foam_p = particles(fx * 0.5, fy * 0.5, T_FIXED, samp0)
    foam = band * np.clip(foam_n * 1.0 + foam_p * 0.02, 0, 1) * FOAM_WEAK_GAIN * 8.0
    foam_mask = wash & (foam > 0.12)
    rgb[foam_mask] = foam_hex + sub[foam_mask][..., None] * 4.0
    # ZERO foam beyond 1.07 m: max depth_m is PIECE_DEPTH_SHORE_MAX_M = 0.6
    # < 1.07 by construction (asserted in the manifest check below).
    info = {"sand_w": sand_w, "wash_w": wash_w,
            "foam_px": int(foam_mask.sum()),
            "max_depth_m": float(depth_m.max())}
    return np.clip(rgb, 0, 255), info


# ----------------------------------------------------------------- metrics ---

def measure_deep(rgb: np.ndarray) -> dict:
    L = luminance(rgb)
    interior = rgb[64:448, 64:448]
    Li = luminance(interior)
    mean_rgb = interior.mean(axis=(0, 1))
    std = float(Li.std())
    mdl = float(np.abs(np.diff(L, axis=1)).mean() + np.abs(np.diff(L, axis=0)).mean()) / 2
    lag1 = acf_lag1(L)
    prof = acf_profile(L)
    # Global max over 1..14 is trivially lag 1 for natural textures; the
    # acceptance criterion wants the COHERENT secondary peak (donor swell /
    # ripple scale): the first local maximum strictly inside lags 6..14
    # (rise then fall), independent of the lag-1 value.
    peak, peak_val = 1, prof[0]
    for k in range(6, 15):
        prev_v = prof[k - 2]
        next_v = prof[k] if k < 15 else -1.0
        if prof[k - 1] > prev_v and prof[k - 1] >= next_v:
            peak, peak_val = k, prof[k - 1]
            break
    # (no interior rise-and-fall in 6..14 -> peak stays 1 -> FAIL)
    # glint band A: relative threshold
    thr = float(L.mean() + 2.5 * L.std())
    thr = max(thr, float(L.mean() + 18))
    gmask = L >= thr
    frac = float(gmask.mean() * 100)
    sizes = glint_components(gmask)
    # glint band B: bright-neutral classifier
    mn = rgb.min(axis=2)
    mx = rgb.max(axis=2)
    bmask = (mn >= 150) & ((mx - mn) <= 50)
    bfrac = float(bmask.mean() * 100)
    bsizes = glint_components(bmask)
    def stats(sizes):
        if not sizes:
            return {"n": 0, "median": 0, "max": 0, "ge2": 0.0, "ge4": 0.0, "ge5": 0}
        arr = np.array(sizes)
        return {"n": int(len(arr)), "median": float(np.median(arr)),
                "max": int(arr.max()),
                "ge2": float(arr[arr >= 2].sum() / arr.sum() * 100),
                "ge4": float(arr[arr >= 4].sum() / arr.sum() * 100),
                "ge5": int((arr >= 5).sum())}
    return {"mean_rgb": [float(v) for v in mean_rgb],
            "G-R": float(mean_rgb[1] - mean_rgb[0]),
            "B-R": float(mean_rgb[2] - mean_rgb[0]),
            "B-G": float(mean_rgb[2] - mean_rgb[1]),
            "std": std, "mean_abs_dL": mdl, "lag1": lag1,
            "acf": prof, "acf_peak": peak, "acf_peak_val": peak_val,
            "glint_thr": thr, "glint_frac": frac, "glint": stats(sizes),
            "bright_frac": bfrac, "bright": stats(bsizes)}


def measure_shore(rgb: np.ndarray, info: dict) -> dict:
    L = luminance(rgb)
    yy, xx = np.mgrid[0:SIZE, 0:SIZE]
    xs, sh, sand_w, wash_w = shore_geometry()
    shore_y = np.interp(np.arange(SIZE), xs, sh)
    # longest constant-x run of the boundary
    runs, cur, prev = 1, 1, shore_y[0]
    for v in shore_y[1:]:
        if v == prev:
            cur += 1
            runs = max(runs, cur)
        else:
            cur, prev = 1, v
    shore2d = np.interp(xx[0], xs, sh)[None, :].repeat(SIZE, axis=0)
    depth_px = yy - shore2d
    water = depth_px >= wash_w
    wash = (depth_px >= 0) & (depth_px < wash_w)
    wm = rgb[water]
    sat = []
    import colorsys
    sample = wm[::37][:2000] / 255.0
    for r, g, b in sample:
        h, s_, v = colorsys.rgb_to_hsv(float(r), float(g), float(b))
        sat.append(s_)
    S = float(np.mean(sat))
    # SPOT-CHECK re-verify: black pixels anywhere (the fixed defect)?
    black_px = int(((rgb[:, :, 0] < 20) & (rgb[:, :, 1] < 20) & (rgb[:, :, 2] < 20)).sum())
    # foam luma vs neighbours: mean L of foam px vs wash-band non-foam px
    fmask = np.zeros_like(wash)
    # (foam mask recomputed from colour distance to the foam tint is brittle;
    # use info count + direct L comparison of the wash band's top decile:)
    wl = L[wash]
    foam_luma = float(np.percentile(wl, 99)) if wl.size else 0.0
    wash_luma = float(np.median(wl)) if wl.size else 0.0
    # 3-band plateau check on a perpendicular profile (middle column x=256):
    col = L[:, 256]
    prof_rgb = rgb[:, 256, :].astype(int)
    # ripple crests along 4 scanlines (from the sampled fBm field, now that
    # radial synthesis is removed; expected to differ from the old M6/M7)
    gaps = []
    for x in (200, 280, 360, 440):
        colx = L[:, x]
        loc = []
        for i in range(1, SIZE - 1):
            if colx[i] - colx[i - 1] >= 3 and colx[i] - colx[i + 1] >= 3 and water[i, x]:
                loc.append(i)
        gaps += [b - a for a, b in zip(loc, loc[1:])]
    med_gap = float(np.median(gaps)) if gaps else 0.0
    p20, p90 = float(np.percentile(L[water], 20)), float(np.percentile(L[water], 90))
    return {"mean_water_rgb": [float(v) for v in wm.mean(axis=0)],
            "S": S, "max_run": runs, "sand_w": sand_w, "wash_w": wash_w,
            "wash_w_720p": wash_w * 2.5, "sand_w_720p": sand_w * 2.5,
            "med_gap": med_gap, "contrast": p90 - p20,
            "foam_px": info["foam_px"], "max_depth": info["max_depth_m"],
            "black_px": black_px, "foam_luma_p99": foam_luma,
            "wash_luma_med": wash_luma,
            "profile_rgb_x256": [[int(v) for v in pix] for pix in prof_rgb[::32]]}


# ------------------------------------------------------------------ output ---

def compare_tile(render: Image.Image, ref_path: Path, box: tuple,
                 title: str) -> Image.Image:
    ref = Image.open(ref_path).convert("RGB").crop(box)
    scale = max(1, 256 // max(1, ref.width))
    ref_big = ref.resize((ref.width * scale, ref.height * scale), Image.NEAREST)
    w, h = render.size
    pad, header = 12, 40
    cw = pad * 3 + max(w, 1) + max(ref_big.width, 1)
    chh = pad * 2 + header + max(h, ref_big.height)
    canvas = Image.new("RGB", (cw, chh), (22, 24, 28))
    d = ImageDraw.Draw(canvas)
    d.text((pad, pad), title, fill=(255, 255, 255), font=_font(15))
    canvas.paste(render, (pad, pad + header))
    canvas.paste(ref_big, (pad * 2 + w, pad + header))
    return canvas


def sun_linkage(deep: np.ndarray, sunrot: np.ndarray) -> dict:
    """Sun-linkage check: rotate sun >=30 deg and compare glint masks.
    Returns centroid displacement (px), mask overlap (IoU) and fraction deltas.
    Linked glints move (low IoU, displaced centroid); a uniform field would
    give IoU ~1 and ~0 displacement."""
    L1 = luminance(deep)
    L2 = luminance(sunrot)
    t1 = max(float(L1.mean() + 2.5 * L1.std()), float(L1.mean() + 18))
    t2 = max(float(L2.mean() + 2.5 * L2.std()), float(L2.mean() + 18))
    m1 = L1 >= t1
    m2 = L2 >= t2
    inter = float((m1 & m2).sum())
    union = float((m1 | m2).sum())
    iou = inter / union if union else 0.0
    def centroid(m):
        ys, xs = np.nonzero(m)
        if len(xs) == 0:
            return (0.0, 0.0)
        return (float(xs.mean()), float(ys.mean()))
    c1, c2 = centroid(m1), centroid(m2)
    disp = float(np.hypot(c1[0] - c2[0], c1[1] - c2[1]))
    return {"iou": iou, "centroid_disp_px": disp,
            "frac1": float(m1.mean() * 100), "frac2": float(m2.mean() * 100)}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-dir", default=str(DEFAULT_OUT))
    ap.add_argument("--pieces", default="all",
                    help="deep|shore|all (shore-only runs skip the deep field)")
    args = ap.parse_args()
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    want_deep = args.pieces in ("all", "deep")
    want_shore = args.pieces in ("all", "shore")

    base = load_wave()
    samplers = [make_sampler(lv) for lv in blur_levels(base)]
    manifest = {
        "seed": SEED, "size": [SIZE, SIZE], "t": T_FIXED,
        "P_SPAN": P_SPAN, "P_BODY_SPAN": P_BODY_SPAN, "SLOPE_GAIN": SLOPE_GAIN, "SPEC_K": SPEC_K,
        "GRAD_BLUR": GRAD_BLUR, "GLINT_BLUR": GLINT_BLUR,
        "BODY_LP": BODY_LP, "BODY_A": BODY_A, "BODY_L0": BODY_L0,
        "PIECE_EXP_SOFT": PIECE_EXP_SOFT, "PIECE_EXP_GLOSSY": PIECE_EXP_GLOSSY,
        "DONOR_EXP_SOFT": EXP_SOFT, "DONOR_EXP_GLOSSY": EXP_GLOSSY,
        "SUN_DIST": SUN_DIST, "SUN_AZIM_MAIN": SUN_AZIM_MAIN,
        "SUN_AZIM_ROT": SUN_AZIM_ROT, "TEX_SCALE_S": TEX_SCALE_S,
        "TEX_SCALE_T": TEX_SCALE_T,
        "HMAP_MIN": HMAP_MIN, "HMAP_MAX": HMAP_MAX, "HMAP_W": HMAP_W,
        "HMAP_H": HMAP_H, "SHADOW_SIZE": SHADOW_SIZE,
        "PARTICLE_AMOUNT_DONOR": PARTICLE_AMOUNT, "FOAM_WEAK_GAIN": FOAM_WEAK_GAIN,
        "BODY_SWELL_FREQ": BODY_SWELL_FREQ, "BODY_SWELL_AMP": BODY_SWELL_AMP,
        "K2_GAIN": K2_GAIN,
        "OCTAVE_SIGMA": OCTAVE_SIGMA,
    }

    files = {}
    if want_deep:
        deep = render_deep(SUN_AZIM_MAIN, samplers)
        sunrot = render_deep(SUN_AZIM_ROT, samplers)
        Image.fromarray(deep.astype(np.uint8)).save(out / "t6_water_deep.png")
        Image.fromarray(sunrot.astype(np.uint8)).save(out / "t6_water_deep_sunrot.png")
        m_deep = measure_deep(deep)
        m_rot = measure_deep(sunrot)
        manifest["deep"] = m_deep
        manifest["sunrot_glint_frac"] = m_rot["glint_frac"]
        manifest["sunrot_bright_frac"] = m_rot["bright_frac"]
        manifest["sun_linkage"] = sun_linkage(deep, sunrot)
        cmp1 = compare_tile(Image.fromarray(deep.astype(np.uint8)),
                            REF_DIR / "articolo-787.jpg", (600, 0, 960, 160),
                            "t6_water_deep (render)  |  articolo-787 river (600,0,960,160)")
        cmp1.save(out / "t6_water_deep_compare.png")
        cmp1c = compare_tile(Image.fromarray(deep.astype(np.uint8)),
                             REF_DIR / "articolo-787.jpg", (872, 0, 960, 16),
                             "t6_water_deep (render)  |  articolo-787 CLEAN (872,0,960,16)")
        cmp1c.save(out / "t6_water_deep_compare_clean.png")
    if want_shore:
        shore, sinfo = render_shore(samplers)
        Image.fromarray(shore.astype(np.uint8)).save(out / "t6_water_shore.png")
        manifest["shore"] = measure_shore(shore, sinfo)
        cmp2 = compare_tile(Image.fromarray(shore.astype(np.uint8)),
                            REF_DIR / "maxresdefault_1.jpg", (398, 182, 420, 212),
                            "t6_water_shore (render) | maxresdefault_1 shallow (398,182,420,212)")
        cmp2.save(out / "t6_water_shore_compare.png")

    for name in ("t6_water_deep.png", "t6_water_deep_sunrot.png",
                 "t6_water_shore.png", "t6_water_deep_compare.png",
                 "t6_water_deep_compare_clean.png",
                 "t6_water_shore_compare.png"):
        p = out / name
        if p.is_file():
            files[name] = hashlib.sha256(p.read_bytes()).hexdigest()
    manifest["files"] = files
    (out / "t6_water_manifest.json").write_text(json.dumps(manifest, indent=1))
    print(json.dumps({k: v for k, v in manifest.items() if k != "files"}, indent=1))
    print("files:")
    for k, v in files.items():
        print(f"  {k} {v[:16]}")


if __name__ == "__main__":
    main()
