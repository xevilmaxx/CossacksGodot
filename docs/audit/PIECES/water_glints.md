# T2-PIECE-WATER-GLINTS — Donor truth vs port speckles (Cossacks 3 → Godot)

**Lane:** RESEARCH only. Read-only donor/reference; no Godot run, no code edit, no donor asset copied into the repo.
**Date:** 2026-11-21. **Ticket:** T2-PIECE-WATER-GLINTS (swarm child of the Cossacks 3 → Godot port).
**Scope:** sun-linked water glints/specular only. Companion doc: `docs/audit/TERRAIN_DONOR_WATER.md` (TDR-4; §3c, §4.7, W-3).
**Labels:** `observed` = read from a file or measured with Pillow; `derived` = arithmetic on observed values; `inferred` = plausible interpretation not proven by the plaintext; `UNVERIFIED` = no evidence found.

---

## 1. Method (measurement reproducibility)

- Donor plaintext read with PowerShell `Get-Content -Encoding Default`; line numbers below are 1-based from those files. Donor root `C:\Games\Cossacks 3\data\...` (read-only).
- Port plaintext read from repo root; `app/shaders/water_overlay.gdshader`, `app/scripts/world.gd`.
- Pillow 12.1.1 + NumPy 2.4.3 scripts lived **only** in `%LOCALAPPDATA%\Temp\opencode\` (`water_glint_measure.py`, `water_glint_final.py`, `water_shader_sim.py`, `water_ref_refine.py`). Nothing from that work is part of this repo.
- Glint classifier: a pixel is a *bright-neutral glint candidate* when `min(R,G,B) ≥ 150` **and** `max(R,G,B) − min(R,G,B) ≤ 50` (8-bit RGB). Connected components are 8-connected. "Isolated speckle" = component of 1–3 px; "coherent highlight" = component of ≥ 2 px, capped at 12 px for acceptance. Luminance is Rec.709 `0.2126R + 0.7152G + 0.0722B`; variance is over the whole crop (8-bit² units).
- Crops measured: port `app/shots/terrain_sample_128.png` (1280×720) deep-water boxes `(60,20)–(300,180)` and `(500,520)–(1000,700)`; reference `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` (960×540) river water `(890,12)–(960,30)` and band `(880,10)–(960,32)`; reference `maxresdefault_1.jpg` (512×288) shallow surf `(355,168)–(432,300)`.
- A numerical replay of the port glint terms was run against the real wave PNGs (`app/assets/terrain/water_png/diffusewaves0/1/2.png`, sampled bilinearly with the shader's `p/7, p/11, p/17`, slopes at +0.7 m, `z=0.15`, `sun_dir=(-0.086175,0.9387)`) over a 64 m × 64 m / 512² patch. Its 1.38 % glint fraction and 795 luminance variance reproduce the screenshot's 1.46–1.61 % / 805–832 — i.e. the defect is explained by the shader's own constants, not by an old bake.

---

## 2. Donor evidence + constants (the truth to match)

### 2a. Active pipeline and light

| Fact | Value | File:line |
|---|---|---|
| Active fragment program is the `.dev` variant | `FragmentProgramFileName = .\data\shaders\water\water.dev.frag` | `data\water\water.lib:68` (vertex at `:67`) |
| Directional sun, `LightStyle = lsParallel` | `Position = (-0.344731152057648, 0.938701450824738, 0, 1)` | `data\env\lights\light.cfg:17, 26–30` |
| Sun → shader light vector (note the axis swap and `/4, /2, /1`) | `lightVector = vec3(gl_LightSource[0].position.x/4.0, gl_LightSource[0].position.z/2.0, gl_LightSource[0].position.y/1.0)` | `data\shaders\water\water.dev.vert:22` |
| Fragment copies it verbatim | `vec3 light = vec3(lightVector.x, lightVector.y, lightVector.z);` | `water.dev.frag:48` |
| Derived mapped vector | `(-0.3447/4, 0/2, 0.9387/1) = (-0.08618, 0, 0.93870)`; normalized `(-0.0913, 0, 0.9958)`, ≈ 5.2° from +Z | `derived` from the two rows above |

### 2b. Glint constants — `water.dev.frag`

| Constant | Value | Line | Role |
|---|---|---|---|
| `coast2water_fadedepth` | `0.57` | `:37` | shoreline band (foam is gated by it; glints are not) |
| `water_softlight_fact` | `170.` (comment `range [1..200]`) | `:42` | soft highlight exponent |
| `water_glossylight_fact` | `120.` | `:43` | glossy highlight exponent |
| `water_specularcolor` | `vec3(0.4, 0.4, 0.4)` | `:47` | neutral grey glint tint (not white, not per-channel boosted) |
| `normwater` | `normalize(vec3(h3-h4, h1-h2, 0.15))` from 9-octave `water_map` finite differences at `dif=(0,0.01)` | `:186–192` (fBm `:85–104`) | per-pixel wave normal; z = 0.15 |
| Light ray (per pixel!) | `r0 = vec3(uv, WATER_LEVEL); rd = normalize(light - r0)` | `:215–216` | direction *from the water point to the sun*, varies over the surface |
| Soft + glossy terms | `grad = dot(normwater, rd); specular = pow(grad, 170); specular2 = pow(grad, 120)` | `:217–219` | no `×8`, no `×4` |
| Corona | `gradpos = dot(vec3(0,0,1), rd); specular1 = smoothstep(0,1,pow(gradpos,5))` | `:220–221` | used as a **divisor/darkener** |
| Composite | `watercolor *= 2.2+watershade; watercolor += (.2+.8*watershade)*((grad-1.)*.5+specular)*.25; watercolor /= (1.+specular1*1.25); watercolor += watershade*specular2*water_specularcolor;` | `:222–226` | max glossy add ≈ `1 × 1 × 0.4 = 0.4` linear; soft term additionally damped by `0.25` and by the negative `(grad-1)*0.5` |

**Derived from 2b:** the donor's brightest possible specular add is ≈ `0.25 + 0.4 = 0.65` linear at a single aligned pixel; the corona *reduces* the body colour there. The highlight is grey, spatially localized (because `rd` is a position-to-sun ray, not a constant), and coherent (because `normwater` comes from a smooth 9-octave field).

**Alternate build, explicitly not active** (`water.frag`, not named by `water.lib`): exponents `15` / `120` at `:26–27`, specular colour `(1.3, 1.3, 0.9)` at `:31`, same composite at `:223–231`. The non-`.dev` pair is materially different (also `coast2water_fadedepth = 0.10`, `:21`); do not mix its constants into the spec. (`observed` + TDR-4 §3c open question 4.)

### 2c. Reference stills — what glints actually look like in the donor

| Crop | Bright-neutral glints | Largest component | Luminance variance | Reading |
|---|---|---|---|---|
| `articolo-787.jpg` river water `(890,12)–(960,30)`, 1,260 px | **0 px (0.00 %)** at threshold | — | 153.3 (`bg` 153.3) | flat grey-blue river; no white points at all |
| `articolo-787.jpg` wider band `(880,10)–(960,32)`, 1,760 px | **0 px (0.00 %)** | — | 204.4 | same |
| `maxresdefault_1.jpg` shallow surf `(355,168)–(432,300)`, 10,164 px | 4,613 px (45.4 %) but **one 4,533-px connected patch** | 4,533 px | 3,782 | broad shore **foam/surf**, not discrete glints; excluded from deep-water glint density |

So in both provided donor references the *isolated glint* density is **0.00 %**; the only bright water features are a large foam patch in a shallow shore crop. The donor shader nevertheless defines sparse glints analytically (`pow(grad,170/120)`), so the acceptance target below allows a small non-zero budget rather than demanding literally zero.

---

## 3. Port defect — file:line

| # | Defect | Port evidence | Donor contrast | Effect |
|---|---|---|---|---|
| D1 | Glint amplitudes invented: `spec = pow(grad,170.0) * 8.0`, `spec2 = pow(grad,120.0) * 4.0` | `app/shaders/water_overlay.gdshader:71–72` | `water.dev.frag:218–219` has bare `pow`, composite at `:224–226` scales by `0.25` / `0.4` | peak add `0.4×(8+4)=4.8` linear vs donor ≈ `0.65` → **≈ 7.4×**, or 12× on the glossy term alone; values clip to white |
| D2 | Light is a **constant near-vertical vector**, not a per-pixel ray | `water_overlay.gdshader:69` `L = normalize(vec3(sun_dir.x, 0.0, sun_dir.y))`, fed by `world.gd:820` `Vector2(-0.3447/4.0, 0.9387)`; `grad = max(dot(n,L),0.0)` at `:70` | `water.dev.frag:215–216` `rd = normalize(light - r0)` with `r0 = vec3(uv, WATER_LEVEL)` → direction varies with map position | every wave facet that happens to face up gets a glint → glints appear **uniformly across all water**, instead of in one sun-linked region |
| D3 | Corona role inverted: `(0.20 + 0.80*corona)` **multiplies** the glint | `water_overlay.gdshader:73–74` | `water.dev.frag:221,225` divides by `(1.0 + specular1*1.25)` | brightens rather than darkens the corona |
| D4 | Normal is a 3-lookup low-frequency field with fixed `z=0.15` and slope gain `1.2` | `water_overlay.gdshader:35–43, 60` | donor 9-octave fBm + finite differences at 0.01 (`water.dev.frag:85–104, 186–192`) | at 64 m/512² the slope is ~0 at isolated bilinear-grid points; with `L≈+Z` that makes `grad≈1` on single pixels only — the exact 1–3 px salt-and-pepper seen in the shot. Simulation: `grad p99 = 0.9896`, glint fraction 1.38 % |
| D5 | Extra broad sheen term not in the donor composite | `water_overlay.gdshader:75` `0.35 × pow(grad,24) × (0.10,0.12,0.14)` | no analogue in `water.dev.frag:222–227` | adds a second near-vertical halo that reinforces D2 |

**Measured port defect (Pillow, threshold min RGB ≥150 / chroma ≤50):**

| Crop | Glint px | Glint fraction | Components | Median / max size | Singleton share of components | Whole-crop luminance variance |
|---|---|---|---|---|---|---|
| deep top `(60,20)–(300,180)` | 560 / 38,400 | **1.458 %** | 520 | 1 px / 3 px | **93.5 %** | **832.4** (non-glint bg 435.0) |
| deep bottom `(500,520)–(1000,700)` | 1,452 / 90,000 | **1.613 %** | 1,358 | 1 px / 3 px | **93.8 %** | **805.4** (non-glint bg 256.5) |

Sensitivity: fraction stays 0.95–1.83 % for brightness cutoffs 120–200, so the result is not a threshold artefact. **Verdict:** the port water reads as a uniform field of dense white 1–3 px speckles; it is a specular-term bug (D1–D5), not the donor's sun-linked, sparse, coherent glint.

---

## 4. JSON spec

```json
{"name":"water_glints","size_px":[512,512],"seed":7,"layers":[{"type":"water","sheet":"diffusewaves2","mode":"deep","glints":true}],"reference":{"glint_fraction_pct":0.0,"glint_fraction_measured_in":"articolo-787.jpg river (890,12,960,30) + maxresdefault_1.jpg surf, isolated components only","isolated_glint_cap_pct":0.3,"glint_exponents":[170,120],"specular_color":[0.4,0.4,0.4],"sun_dir_mapped":[-0.08618,0.0,0.9387],"reference_max_glint_size_px":12,"reference_luminance_variance":153.3}}
```

Field notes: `glint_fraction_pct = 0.0` is the measured reference value (both refs, no isolated glint pixels); `isolated_glint_cap_pct = 0.3` is the tolerance carried into §5. `glint_exponents` and `specular_color` are the active donor constants (`water.dev.frag:42,43,47`). `sun_dir_mapped` is `light.cfg:27–29` through `water.dev.vert:22`. `reference_luminance_variance` is the clean river crop from §2c. The requested top-level shape is preserved verbatim.

---

## 5. Acceptance criteria — 512×512 PNG, seed 7, deep-water layer

Render `water_glints` at 512² with the water mask forced to deep (`G = B = 1`, coverage = 1) so shoreline foam cannot contaminate the count. Apply the §1 classifier to the whole crop. A pass requires **all four**:

| # | Metric | Target | Port today | Donor reference |
|---|---|---|---|---|
| A1 | Isolated bright-neutral glint fraction (components 1–12 px) | **≤ 0.30 %** (stretch ≤ 0.10 %); must be > 0 so glints are not deleted | 1.46–1.61 % — **FAIL** | 0.00 % measured; small analytic budget from `pow(grad,170/120)` |
| A2 | Largest glint connected component | **≤ 12 px**, and **≥ 50 % of glint pixels in components ≥ 2 px** (coherence; pure 1-px salt noise fails) | max 3 px but 93 % singleton components, ≈ 7 % of glint pixels coherent — **FAIL** | no isolated glints in refs; foam patch 4,533 px is out of scope (deep-water mask) |
| A3 | Whole-crop luminance variance (Rec.709, 8-bit²) | **≤ 400** (stretch ≤ 250) | 805–832 — **FAIL** | 153 (river); 92 in the replay with the spec term damped |
| A4 | Sun linkage | rotating `sun_dir` by ≥ 30° moves/removes the glint cluster; glints are not uniformly distributed over the tile | constant `L` at `:69` → uniform field — **FAIL** | `rd = normalize(light - r0)` at `water.dev.frag:216` |

A1–A3 are measured from the single 512² PNG; A4 needs a second render with a rotated `sun_dir` (same seed/size). Numeric rule of thumb for the fix: keep the donor exponents 170/120 and grey `(0.4,0.4,0.4)`, but remove the `×8/×4` boosts (D1), use a per-pixel `rd` (D2), and let the corona divide rather than multiply (D3).

---

## 6. Claim table

| Claim | Evidence | Method | Verdict | Correction / note |
|---|---|---|---|---|
| Donor soft/glossy exponents are 170 / 120 | `water.dev.frag:42–43` | Read (plaintext) | **observed** | Active per `water.lib:68`; the `15 / 120` pair at `water.frag:26–27` belongs to the inactive build |
| Donor glint colour is grey `(0.4,0.4,0.4)` | `water.dev.frag:47` | Read | **observed** | Not `(1.3,1.3,0.9)` — that is `water.frag:31` (inactive) |
| Donor sun reaches water as `(-0.086, 0, 0.939)` | `light.cfg:17,27–29` → `water.dev.vert:22` | Read + derived arithmetic | **derived** (inputs observed) | Axes are swapped and scaled by `/4, /2, /1`; normalized ≈ 5.2° off +Z |
| Donor glints are sparse and coherent | `pow(grad,170/120)` at `:218–219`; smooth fBm normal at `:186–192`; per-pixel `rd` at `:216`; refs show 0 isolated glints | Read + Pillow + inference | **inferred** (analytic form observed; density not render-verified) | No GPU donor render was made in this lane; treat 0.00 % as a still-image measurement, not a runtime guarantee |
| Reference river has no bright-white glint pixels | `(890,12,960,30)` → 0 / 1,260 px; wider band → 0 / 1,760 px | Pillow | **observed** | JPEG compression could erase sub-pixel glints — caveat |
| Reference bright water in `maxresdefault_1.jpg` is foam, not glints | 4,613 bright px form one 4,533-px component | Pillow | **observed** (classification inferred) | Excluded from glint density; consistent with donor `nautic()`/`particles()` foam at `water.dev.frag:227` |
| Port has dense uniform white speckles | 1.46 % / 1.61 % bright px; 93 % singleton components; 520–1,358 components per crop | Pillow | **observed** | Matches the visual read of `terrain_sample_128.png` |
| Port speckle fraction is caused by `×8/×4` + constant `L` + inverted corona | `water_overlay.gdshader:69–75`; replay gives 1.38 % / variance 795 vs screenshot 1.46–1.61 % / 805–832 | Shader read + numerical replay | **derived** (replay is a CPU analogue, not a Godot render) | Strong match, but confirm in-engine after the fix; replay used `t=0..7.7` and a 64 m span |
| Port "sparkle" is the wave PNG's own bright pixels | TDR-4 §5/§6 said the old bake had no shader | Historical claim | **superseded** | The shader now exists (`world.gd:803–848`, `water_overlay.gdshader`); sparkle is the shader specular term, not baked PNG pixels |
| Exact donor glint density at runtime | none | — | **UNVERIFIED** | Requires a donor GPU capture; not attempted (read-only lane, no donor run) |
| Which of `.dev` / non-`.dev` ships in retail | `water.lib:67–68` names `.dev`; constants differ | Read | **UNVERIFIED** | Carried over from TDR-4 open question 4; spec pins the `.dev` constants |

---

## 7. Open questions

1. Does the retail binary bind `water.dev.frag` (as `water.lib:68` states) or the non-`.dev` variant? If the latter, exponents 15/120 and colour `(1.3,1.3,0.9)` would be the target instead.
2. What is the true donor glint fraction at 512² under an in-engine capture? The two supplied stills are the only reference evidence and both show zero isolated glints.
3. Does `sun_dir` need a time-of-day override? `env.cfg`/`time.cfg` contain no water keys (TDR-4 §3c); only the static `light.cfg` was available here.
4. Can the `z=0.15` normal and slope gain `1.2` be retuned so `pow(grad,170)` yields coherent patches without the `×8/×4` boosts? Requires a render loop, out of scope for this research lane.
