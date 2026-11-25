---
id: G26
title: "WAVE G follow-up: reference shoreline/water vs variant3d water shader — remaining visual gaps + smallest disjoint follow-up"
ticket: G26
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_SOURCE_EDIT
scope: "This report is the ONLY file written. No .gd/.gdshader/config/test/fixture/result/git edit. No Godot process started, no runner job submitted, no donor binary executed, no donor asset copied."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
path_correction: "WAVE_G_CHARTER.md lives in docs/terrain_swarm_2026-11-25/, NOT docs/coord_swarm_2026-11-25/."
visual_parity_claim: false
---

# G26 — reference shoreline/water vs our water shader

## 0. Authority and honesty

- `WAVE_G_CHARTER.md:31`: **only G04** may submit runner jobs. This ticket running under G26 therefore used **zero** Godot calls and made **zero** captures. Charter label rules (`CHARTER.md:55-69`) and "disjoint ownership" (`:67-68`) apply.
- `DTRN_03_donor_shore_water.md` is the donor-grounded baseline (3 verification passes, `visual_parity_claim: false`); it is read, not re-derived here. Its §5 F1–F4 have **since landed** in the port (§3 below), so its §4.3 defect table is not copied forward uncritically.
- Donor = truth; 2D `app/` = secondary helper only (`coord_swarm/CHARTER.md:36-38`). No donor-parity claim is made anywhere in this report (`CHARTER.md:57-58,124-130`).

## 1. Sources and method

| Role | Path / source | Label |
|---|---|---|
| Charters | `docs/terrain_swarm_2026-11-25/CHARTER.md`, `WAVE_G_CHARTER.md`; `docs/coord_swarm_2026-11-25/CHARTER.md` | observed |
| Donor baseline | `docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md` (C01–C32, §3–§7) | observed (prior report) |
| Port shader | `variant3d/shaders/water3d.gdshader` (261 lines, read end-to-end) | observed |
| Port module | `variant3d/scripts/water3d.gd` (321 lines, read end-to-end) | observed |
| Port integration | `variant3d/scripts/world3d_terrain.gd:1394-1508`; `variant3d/scripts/game.gd:1185-1205,2087-2164` | observed |
| Reference folder | `C:\Users\Maxym.Oboyshev\Downloads\c3\` — 12 files, no subdirectories; each opened at native size, candidate shore crops enlarged in `%LOCALAPPDATA%\Temp\opencode\g26_crops\` (non-repo scratch, not a source edit) | observed |
| Geometry-free metric | Pillow `Image`/`numpy` pixel transects on JPEGs (read-only) | derived |
| Port capture | **NONE** — `G04_gate_log.md:25-102` shows G04 blocked at pre-flight, zero jobs submitted; the only recent 768² PNG (`g05_r1_pixel.png`) has 0 teal/water pixels | UNVERIFIED |

## 2. What the reference samples actually show (observed pixels)

### 2.1 Image inventory

All 12 reference files were inspected. Water/shoreline is visible in **two**:

- `maxresdefault_1.jpg` (512×288) — the dominant water example: right-hand shore with a broad tan beach, bright foam band and pale water. Crops: `g26_crops/shore_maxres_5x.png`, `g26_crops/maxres_full3x.png`.
- `articolo-787.jpg` (960×540) — thin dark blue-grey water strip at the top-right behind the camp (`g26_crops/shore_articolo_5x.png`).
- The other 10 (battle/wallpaper/village/mill/winter/building shots) show **no water surface** at readable scale. Important: "the c3 folder" is not a uniform water reference; water appearance varies between these two samples (bright pale vs dark blue-grey), so one crop is **not** a universal target.

### 2.2 `maxresdefault_1.jpg` transect, x=400, y=160–283 (observed; sRGB 0–255)

| y | RGB | Read |
|---:|---|---|
| 160–178 | ~`(153,146,120)` → `(193,192,171)` | tan/beige wet beach, warm (`B−R ≈ −30…−20`) |
| 181–184 | `(199,206,190)` → `(215,228,218)` | transition to cool (`B−R` crosses 0) |
| **187** | **`(224,241,235)`** | **foam peak — near-white cyan, luma ≈237** |
| 190–196 | `(210,222,220)` → `(221,234,227)` | foam persists just offshore |
| 199–211 | `(192,205,198)` → `(182,180,157)` | pale grey-green water starts |
| 214–262 | ~`(186,193,177)` → `(167,171,157)` | water body, desaturated, *not* dark navy |
| 265–283 | `(162,164,150)` → `(170,166,141)` | far/shallow water returning warm |

Aggregates (derived): water band y185–280, x390–410 → mean `(184.1, 189.8, 176.5)`, p10 `(156,157,140)`, p90 `(207,217,208)`; foam rows y183–199 → mean `(205.1, 217.3, 207.6)`, max `(228,242,237)`.

Visual signature to reproduce in a real-map capture: **broad warm beach → short, bright near-white cyan foam band hugging the boundary → bright desaturated grey-green water**, with soft mottling and no hard tile seams. The donor's `sandsea1/5/6` raw DDS means (`#807856`-ish, DTRN-03 §3.7) cannot be compared directly to these lit JPEG pixels — that comparison is **UNVERIFIED**.

### 2.3 Caveats (binding)

- 512×288 JPEG with HUD text and a minimap overlay covering part of the water; JPEG/downscale uncertainty ±25% is already recorded in DTRN-03 §7.10. **No pixel width here is donor truth.**
- No camera calibration / donor GPU A/B frame exists (`DTRN_03 §4.2.8`, `CHARTER.md:57`). All reference-derived widths are **screen-pixel observations of one screenshot**, not metres.

## 3. Port state — which DTRN-03 fixes have already landed (observed code)

DTRN-03 §5 prescribed F1–F8. The current tree (read this ticket) shows:

| Fix | Landed? | Evidence |
|---|---|---|
| F1 surface Y decoupled from `-0.25` | **yes** | shader `:32,161` (`water_surface_y`); `water3d.gd:36,165,179`; fallback still `-0.25` so `waveheight=0` |
| F2 water cells off `grass1` | **yes** | `world3d_terrain.gd:1400-1480` remaps `BLK_WATER` via 8×45° shore table; `stats` at `:1725-1731` |
| F3 `shore_prox` removed | **yes** | shader `:231-239` uses verbatim donor foam; `water3d.gd:273-274` |
| F4 alpha = `coastfade2`, no 0.35 floor | **yes** | shader `:246`; floor absent |
| F5–F8 (height hygiene, 8×45° table, reflection/shadow/fog approximations, single plane) | **partial** | shader `:188` `map_size.x/128`; `water3d.gd:310-316` 8-bit alpha; `:199` reflection off; `world3d_terrain.gd:1132-1133` fallback plane only |

Therefore the remaining gaps below are **new, post-F1–F4 residues**, not a replay of DTRN-03 §4.3.

## 4. Concrete remaining visual gaps (visible-in-a-real-map-capture candidates)

Each row: reference fact → port code fact → donor citation → label. "Visible" means *would be visible if a capture were made*; it is **not** a claim that a capture was compared.

### G26-1 — Water colour / brightness: bright pale reference vs dark, reflection-less port

- Reference: water body mean `(184,190,177)` sRGB, desaturated grey-green, not deep blue (§2.2). Donor colour inputs are **linear pre-composite** (`(0.1,0.24,0.24)` shallow, `(0,0.025,0.05)` deep, `water.dev.frag:45-47`) then multiplied by `2.2+ watershade`, specular-added, corona-divided, and **reflection-added** (`water.dev.frag:207-226`; DTRN-03 §3.4).
- Port: `SHALLOW_COLOR/DEEP_COLOR` wired (`water3d.gd:80-82`), but `reflection_enabled=0.0` (`water3d.gd:199`) so the bright projected reflection term is absent; `CalcTerrain` bed lighting and 3-tap PCF are omitted (shader `:141-147` comment; DTRN-03 §4.2.2); fog off (`:196`, `colors.lib:36 FogMode=0`).
- **Gap (inferred):** with the reflection/terrain-bed/shadow terms missing, the port water surface likely reads flatter and darker/greener than the reference's pale silvery band. Magnitude **UNVERIFIED** without a fixed-camera capture. Donor FBO binding is UNVERIFIED (DTRN-03 §7.4), so "enable reflection" is not a donor-faithful fix; any A/B must be labelled PORT APPROX.
- Citations: `water.dev.frag:45-47,207-226`; `water.lib:25,32-33`; DTRN-03 §3.4, §4.2.2/§4.2.4.

### G26-2 — Foam band: bright near-white rim in reference; port foam amplitude unverified

- Reference: foam peak `(224,241,235)` at the boundary, mean over y183–199 `(205,217,208)` (§2.2) — the single strongest visual cue in the sample.
- Port: donor foam equation is verbatim (shader `:238-239`: `watershade*coastfade*(1−coastfade2)*(vec3(.5,.6,.7)*nautic + vec3(particles))`), with `nautic()`/`particles()` at ×18/×200 over the **single** 256² `diffusewaves0.png` (shader `:111-139`; DTRN-03 C17/C22). By DTRN-03 §3.3, foam is 0 at depth 0 and ≥1.07 m, peaks at 0.535 m.
- **Gap (derived):** foam is added to `watercolor` *before* `rescolor = mix(rescolor, watercolor, coastfade)` and then multiplied by `alpha = coastfade2`; at the exact waterline it is necessarily invisible, so the visible band sits slightly offshore. Whether the port band reaches the reference's near-white brightness/width is **UNVERIFIED** — no capture, and donor foam itself is procedural so no exact pixel band width is provable (DTRN-03 §7.10). Do **not** re-import the 2D `×8`/`×4`/`pow(grad,24)` glints or `FOAM_GAIN` (DTRN-03 §4.2 helper warning).
- Citations: `water.dev.frag:106-127,227`; DTRN-03 C10, C22, §3.3.

### G26-3 — Coastfade transition: port's `water_cell` guard can create a hard alpha edge

- Reference: continuous warm beach → cool foam → pale water over a short but **soft** band (§2.2, transition rows y181–196 show `B−R` crossing zero gradually).
- Port: donor uses `level = WATER_LEVEL + 0.2*water_map(...)` (animated perturbation, shader `:170`) and the only coverage test is `height > level → discard` (`water.dev.frag:176-183`). The port adds a **PORT GUARD** absent from the donor: `water_cell = 1.0 - step(water_level, height)` (shader `:182`) and `alpha = coastfade2 * water_cell` (`:246`). This hard-zeros alpha at the *classification* height `-0.25` regardless of the animated `level`.
- **Gap (derived port divergence):** where the animated `level` rises above `-0.25` over a dry cell, donor would paint a soft translucent wash but the port shows no water at all → a possible crisp, classification-aligned cut along the shore instead of the reference's soft fade. Whether it is visible in practice depends on the actual surface Y (UNVERIFIED, DTRN-03 §7.1) and cell height distribution; severity **UNVERIFIED**.
- Citations: `water.dev.frag:175-183,198-199,230`; `texturemap.inc:30`; shader `:170-182,246`; DTRN-03 C08/C09.

### G26-4 — Wave animation: coarse swell is zero; scale/precision are PORT APPROX

- Reference stills cannot verify motion at all → **UNVERIFIED** by construction.
- Port: `waveheight = clamp(WATER_SURFACE_Y*3 − 1.5, 0, 1)` (`:169`) with fallback `WATER_SURFACE_Y = -0.25` (`water3d.gd:36`) ⇒ 0, so the donor large-swell term `sin(...)*0.5*f*hgt²` (`:95`) contributes nothing (DTRN-03 C16, W1). Noise `pos` uses `map_size.x/1280 * 10 = map_size.x/128` (`:188`): a 320-cell grid gives ×2.5 vs an UNVERIFIED donor `hmapW` (W4). Height grid is quantised to 8-bit alpha over 5.92 m ≈ 0.023 m/step (`water3d.gd:310-316`, W5), which can terrace the 0.57 m fade.
- **Gap (derived):** animation is driven only by the 3+9-octave chop and foam time terms (shader `:88-108,119,134`); the slow, coherent swell the donor shader associates with real water level is absent under shipped constants. Restoring it requires an actual surface Y, which is engine-supplied and **UNVERIFIED** (`water.dev.vert:18`, `water.frag:182` debug hint 1.5/comment 0.94; DTRN-03 §7.1) — any value is a labelled PORT APPROX, never recovered donor truth.
- Citations: `water.dev.frag:34,88-89,95,174-175,187`; `water.dev.vert:18`; DTRN-03 C14–C16, W1/W4/W5.

### G26-5 — Shore tile ids: right ids now reach atlas, but strip width/gate are port choices

- Reference: beach band in `maxresdefault_1.jpg` spans roughly y163–184 at x=400 (~21 px at 512×288) before foam — a visually substantial tan collar, not a hairline.
- Port: live shore ids are the donor's exact three — `sandsea1`/`sandsea5`/`sandsea6` (shader/atlas ids 93/97/98, `world3d_terrain.gd:1452-1453`; 8×45° sector table `:1450-1480`, `game.gd:2087-2116`), and `BLK_WATER` now maps to shore art rather than `grass1` (`:1400-1404`). But: (a) the land-side wet strip is only 0.15 height units (`-0.25..-0.1`, `game.gd:1190-1205`; DTRN-03 C05/C31) — a ~1-cell rim, plausibly narrower than the reference visually; (b) the substrate gate is `water_sentinel or base_name.begins_with("sandsea") or height < water_level and sand*` with the donor `mask.b > 0` test unreadable → **PORT APPROX** (`:1455-1458`); (c) flat water cells fall back to `sandsea1` (`:1467-1474`) rather than the donor bed `(0.175,0.1375,0.1)+waveMap(p*8)*0.25` (`water.dev.frag:77-81`); (d) `rock9`/`sand1`/`sand2` must stay out of the active shore (donor block commented, `texturemap.inc:934-954`; DTRN-03 C24/C25).
- **Gap (inferred):** id selection is donor-faithful, but whether the *on-screen collar width* matches the reference is UNVERIFIED without a capture and without a donor cell-size-to-metres calibration (`DTRN_03 §7.8`: `TILE_M=2.0` is port-only). Do not widen the strip by inventing a new height threshold — that would leave the donor literals.
- Citations: `texturemap.inc:29-31,463-472,474-511,934-954`; DTRN-03 C05/C23/C24/C31, §3.7.

## 5. Smallest disjoint follow-up proposal (NO edits made)

The smallest safe next step is **measurement, not a shader tweak**: no new visual claim can be made until a capture exists, and G04 is the only runner owner.

**Atom G26b — shore-pixel metric, read-only, one report file (`G26b_shore_metric.md`), owned by this session or G05; zero source edits, zero runner jobs.**
- Inputs: the already-read reference crop `maxresdefault_1.jpg` x390–410/y160–283 (§2.2), and any future G04 `realmap.png` (blocked as of `G04_gate_log.md:25-102`) or existing 64² capture that actually contains water.
- Define and record, with donor anchors, but do **not** assert parity:
  1. `foam_peak_sRGB` and its depth-band location, compared with reference `(224,241,235)` and donor peak depth `0.535 m` (`water.dev.frag:227`, DTRN-03 §3.3).
  2. `water_body_mean_sRGB` vs reference `(184,190,177)`; report Δ per channel, no "match" verdict.
  3. `beach_band_screen_px` and count of `sandsea1/5/6` cells in the near-shore tile histogram (`world3d_terrain.gd:1725-1731`; ids 93/97/98).
  4. `alpha_at_waterline` and half-alpha depth, donor targets 0 and 0.535 m (`water.dev.frag:198-199,230`).
  5. `animation_delta` needs two fixed-camera frames 1 s apart — **only G04** may produce them.
- Pass condition: all five numbers recorded with evidence ids and labels. **No donor-parity PASS** is defined (DTRN-03 §6 gate note).

**Contingent, mutually exclusive implementation atoms — one file per owner, gated on G26b, never both at once:**
- **G27** (exclusive `variant3d/shaders/water3d.gdshader` only): a *labelled PORT APPROX* A/B of the foam/colour composite (G26-1/2) and/or removal of the `water_cell` alpha cut in favour of the donor's `height>level` coverage (G26-3). Back up to `inbox/backup/water3d.gdshader.bak-G27`. Reflection FBO and donor surface Y stay UNVERIFIED and untouched.
- **G28** (exclusive `variant3d/scripts/world3d_terrain.gd` only): shore-substrate/collar A/B (G26-5), e.g. replace the `sandsea1` flat-water fallback with the donor bed colour path **only if** a donor-readable binding is found; otherwise leave as declared PORT APPROX. Back up `world3d_terrain.gd.bak-G28`.
- G27 and G28 are **disjoint** (shader vs integration script), require COORD integration, one Godot at a time via G04, and keep all 29/29 + 17/17 gates green. `game.gd`, `config.json`, tests and 2D `app/` are out of scope for both.

## 6. UNVERIFIED register (do not promote)

1. Exact donor water surface Y (`water.dev.vert:18`; debug hints 1.5 / comment 0.94 at `water.frag:182`) — controls whether the swell exists (DTRN-03 §7.1).
2. `hmapTex` literal binding and `hmapMin/hmapMax/hmapW` values (DTRN-03 §7.2/§7.3).
3. `reflectionMap` FBO: projected coordinate observed, target not proven (§7.4).
4. Runtime execution of the `;`-prefixed `-0.25/-0.1` GSC lines (§7.5).
5. Donor cell size in metres — port `TILE_M=2.0` is port-only (§7.8), so no screen-width parity criterion.
6. Any port-side visual comparison: **no fresh water-containing capture exists** (G04 blocked); the only current frame is all-olive grass with zero water pixels.
7. Reference pixel values come from one 512×288 JPEG plus one thin 960×540 strip with HUD overlay — not a clean donor GPU A/B.
8. Donor foam band width in pixels; foam is procedural (§7.10).
9. Whether the port's actual water reads too dark / foam too weak / edge too crisp — all **inferred from code**, not observed in a port frame.

## 7. Summary

- Reference water in this folder is pale, desaturated grey-green with a **bright near-white cyan foam band** at the beach boundary and a broad tan collar; the other water sample is darker blue-grey, so no single universal target exists.
- The port's structural donor port has improved: F1–F4 are landed (surface Y decoupled, water cells remapped off grass1, `shore_prox` removed, exact `coastfade2` alpha, correct three shore ids).
- Remaining candidate gaps, all labelled and none visually verified: flat/dark water without reflection or bed lighting (G26-1); unverified foam brightness/width (G26-2); a non-donor hard `water_cell` alpha gate (G26-3); zero coarse swell plus inflated/invalidated noise scale and 8-bit height terracing (G26-4); donor-faithful ids but ~1-cell collar, unreadable mask gate and sandsea fallback instead of donor bed (G26-5).
- Smallest disjoint follow-up: **G26b** (read-only shore metric, one new report file, no runner, no source edit), then at most one of **G27** (shader) / **G28** (terrain script), each exclusive and backed up, gated on G04 captures.
- **No visual parity is claimed.** Donor parity stays UNVERIFIED until a fixed-camera donor A/B frame exists.

*End of G26. Read-only: no donor binary executed, no donor asset copied, no Godot process started, no runner job submitted, no source/config/test/git file modified.*
