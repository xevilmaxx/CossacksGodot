# T2-PIECE-SHORE-TRANSITION — Sand→Water Edge Visual Recipe

**Lane:** RESEARCH only. No Godot runs, no code edits, no donor assets copied into the repo.
**Date:** 2026-11-21.
**Sources:** donor read-only `C:\Games\Cossacks 3\...`; raster references `C:\Users\Maxym.Oboyshev\Downloads\c3\`;
port `app/shots/terrain_sample_128.png` + `app/scripts/{game.gd,world.gd}` + `app/shaders/water_overlay.gdshader`.
**Prior:** `docs/audit/TERRAIN_REFERENCE_IMAGES.md` §3.4/§5, `docs/audit/TERRAIN_DONOR_WATER.md` §3d/§4.
**Method:** Pillow 12.1.1 crop/upscale + per-pixel/box means; all intermediate crops written only to
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (`mr_*_4x.png`, `a787_*_3x.png`, `port_shore_*_2x.png`).
Labels: `observed` (seen/read directly), `derived` (computed from pixels/constants), `inferred`, `UNVERIFIED`.

---

## 1. Donor evidence — crop boxes, hex, band widths

### 1.1 Primary raster: `maxresdefault_1.jpg` (512×288) — shallow shore

Crops (source px, upscaled 4×, nearest-neighbour, into temp only):
`mr_shore_4x.png` = `(300,130,440,250)`; `mr_bottomright_4x.png` = `(330,150,512,288)`;
`mr_water_4x.png` = `(360,180,500,288)`.
Numeric profile: **one-pixel-wide columns x = 350…423, mean over y = 238…272** (avoids units above and the
minimap, which starts at x≈422). The "coolness index" **B−R** separates the bands cleanly:
sand ≈ −45 → wash ≈ −14 → water ≈ +3.

| Band | src x (profile) | Mean hex / RGB | B−R | Width src px | Width @720p (×2.5) |
|---|---|---|---|---|---|
| Dry sand plateau | 361–375 | **`#A69A79`** (166,154,121) | ≈ −45 | 15 | **≈ 38 px** |
| Sand→wash gradient | 376–387 | `#AEA990` → `#B1B09C` | −40 → −21 | 12 | **≈ 30 px** |
| Pale wash plateau (foam) | 388–402 | **`#B1B3A3`** (177,179,163) | ≈ −14 | 15 | **≈ 38 px** |
| Wash→water gradient | 403–407 | `#B1B4A6` → `#A5ACA4` | −8 → −1 | 5 | **≈ 12.5 px** |
| Shallow-water plateau | 408–419 | **`#A8B1AB`** (168,177,171) | ≈ +3 | 12 | **≈ 30 px** (truncated by minimap) |
| x ≥ 420 | dark object / minimap border `#7C8482`…`#4D504F` | — | — | excluded | — |

Aggregated three-band recipe (`derived`):
* **Band 1 — sand:** `#A69A79`, plateau ≈ **38 px @720p** (≈ 65 px if the darker approach x=350–360,
  `#918863`→`#A59978`, is included).
* **Band 2 — wash:** `#B1B3A3`, **≈ 80 px @720p** total (30 px gradient + 38 px plateau + 12.5 px gradient).
* **Band 3 — shallow water:** `#A8B1AB`, **≥ 30 px @720p** before it continues into deeper water.

**Foam (`observed`, `derived`):** the wash plateau is ≈ **+25 luma** above sand (179 vs 154) and ≈ +2 above
water, and carries pale concentric arc structure (`mr_water_4x.png`). Foam is **present but pale gray-tan, not
white sea-foam**. This is a **CORRECTION** to `TERRAIN_REFERENCE_IMAGES.md` §3.4 ("Foam is weak/absent") and to
its water hex `#696B65` — that earlier box `(330,120,470,260)` was sand/infantry-contaminated; the clean shallow
water is `#A8B1AB`. Source is a 512×288 thumbnail upscaled 2.5×, so all widths are `derived`/**UNVERIFIED at
native game resolution** (±25%).

### 1.2 Secondary raster: `articolo-787.jpg` (960×540) — dark river

Crops: `a787_river_2x.png` = `(600,0,960,130)`; `a787_river_tight_3x.png` = `(700,0,960,80)`.
Box `(860,0,958,40)` = **`#333C3F`** (51,60,62), std ≈ 15; wider box `(700,0,900,28)` = `#444D53` (68,77,83),
std ≈ 30 (smoke/units contamination). Scale 720/540 = **1.333**. `observed`: green bank meets dark water directly
with **no foam band** — the pale wash belongs to the shallow (`#12`) case only. Consistent with prior §2
water-dark `#3A4246` (same magnitude, different crop).

### 1.3 Donor plaintext (read-only, no copies)

| Evidence | Value | Source |
|---|---|---|
| Shore height interval | `cWaterHeight = -0.25`, `cWaterShoreHeight = -0.1` → **0.15 m** band | `texturemap.inc:30-31`; `dogenerate.inc:1576` |
| Water/shore flags | `gMapMask[ix,iy].b>0` AND `height<-0.25` (`bWater`) / `<-0.1` (`bWaterShore`) | `texturemap.inc:67-74,463-470` |
| **Oriented sandsea rim** | `bLB/bRT → sandsea5`; `bRB/bL/bR/bLT → sandsea6`; `bB/bT → sandsea1` — applied to the flagged cell by an 8-sector height-gradient angle (`cAngle=45`, `vecangle+180`) | `texturemap.inc:472-511` (`observed`, active) |
| Sand1/sand2 replacement | `if (bWater) or (bWaterShore)` block is **commented out** | `texturemap.inc:934-954` |
| Coast fade | `coast2water_fadedepth = 0.57`; deep fade `= 0.5+0.57 = 1.07` | `water.dev.frag:37,168,198-199` |
| Water tints | shallow `(0.1,0.24,0.24)`; deep `(0,0.025,0.05)`; specular `(0.4,0.4,0.4)` | `water.dev.frag:45-47` |
| Foam | `nautic()=pow(1-f,5)` (3 oct, ×18) + `particles()=pow(f*0.35,7)*30` (3 oct, ×200), multiplied by `coastfade*(1-coastfade2)` **only**; no foam texture asset exists | `water.dev.frag:106,119,227`; `water\textures\` listing (TDR-4 §2) |
| Composite | `rescolor = mix(rescolor, watercolor, coastfade)`; `resalpha = coastfade2` | `water.dev.frag:229-230` |
| Depth/alpha range | `MinDepth/MaxDepth 0/1`, `MinAlpha/MaxAlpha 0/1.1`; `.dev` shader pair is active | `water.lib` (TDR-4 §3a/§1) |

**Donor conclusion (`derived`):** the sandsea art is an **oriented, effectively one-cell rim** on water/shore cells;
the *visual* three-band softness (sand→wash→water) comes from the **shader's coast fade + procedural foam**, not
from a wide sand tile collar. A hard, tile-aligned tan collar of several cells is therefore not donor behaviour.

---

## 2. Port gap — measured symptom + file:line chain

**Symptom** (`observed` on `app/shots/terrain_sample_128.png`, 1280×720; config `app/shots/terrain_sample.json`:
128×128 tiles, Mediterranean, seed 20261113):
* water body is a flat teal-blue (dominant quantized **`#205060`** ≈ (32,80,96)) with white speckle;
* the landward band is a wide, uniform tan/oatmeal ring — `app/assets/terrain/blocks/sandsea5.png` mean
  **`#7B7252`** (123,114,82), std ≈ 11 — with **no pale wash band at all**;
* the water edge is a hard **stair-step**: tracing leftmost water-x over y=250…470 gives constant-x runs of
  **17–81 px** (x=688/32 px, 656/17, 594/81, 532/19, 502/23) and horizontal jumps of **30–62 px**.

**Timing note (`observed` from file timestamps):** shot 12:38 PM, `world.gd` 1:31 PM,
`water_overlay.gdshader` 12:18 PM. The shot already contains the overlay shader but **predates** the in-code
TB-B1e sandsea mitigation; it is valid evidence of the ring/stair-step symptom, not of the newest code state.

| # | Gap | File:line (port) | Why it breaks the recipe |
|---|---|---|---|
| G1 | Sand collar too wide | `game.gd:777-782` (`height<-0.05 → t=4`, comment "≈2–3 tile band") + `game.gd:785-813` (outermost water ring promoted to type 4) + `game.gd:1195-1226`, `1263-1274` (`_shore_tile_for` paints `sandsea1/5/6` on **every** type-4 cell) | ≈3–4 tiles of uniform sandsea art instead of a 1-cell oriented rim (donor `texturemap.inc:472-511`) → wide flat tan ring |
| G2 | No wash band on the collar | `world.gd:835-837` sets water-mask `wet=0` for type 4; `water_overlay.gdshader:46-48` `discard` when `coverage<0.004` | the foam/gradient shader cannot draw on the sand collar — the donor's 80 px wash band is structurally impossible here |
| G3 | Stair-step edge | `world.gd:829-845`: coverage mask is `MAP_W×MAP_H` (one texel per tile), `TEXTURE_FILTER_LINEAR` feathers only ~1 tile; sprite scaled by `TILE_M*view_scale` | edge quantizes to tile boundaries (17–81 px runs) instead of a ≤30 px sub-tile gradient |
| G4 | Flat water colour | `world.gd:1125-1130` bakes `ter_blue` substrate; shader `water_overlay.gdshader:63-64,80-88` does depth/foam only where coverage=1 | no shallow pale `#A8B1AB` band adjacent to land; deep and shallow read the same flat blue |
| G5 | Partial mitigation only | `world.gd:1081-1083` comment explicitly names "the wide flat tan ring"; `:1100-1103` applies gamma falloff 1.7 + ceiling 0.55 to the role-4 pass | narrows the feather but does not add a wash band and does not fix the per-tile coverage mask |

**Root cause in one line:** donor softness is shader-driven coast fade over a *1-cell* oriented rim
(`texturemap.inc:472-511` + `water.dev.frag:198-199,227`); the port renders the shore as *baked land tiles*
(`game.gd:785-813`, `world.gd:1081-1103`) and masks water at *tile* resolution (`world.gd:831-845`), so neither
the wash band nor a sub-tile edge can exist.

---

## 3. Render spec (JSON) — target for a 512×512 seed-7 comparison tile

Layer list, size, seed and water parameters are exactly as specified by the ticket; `reference` carries the
measured donor band widths. This is a **recipe for a generated comparison tile**, not a donor copy.

```json
{
  "name": "shore_water_transition",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "sandsea5", "tile": true},
    {"type": "water", "mode": "shallow", "opacity": 0.8}
  ],
  "reference": {
    "source": "maxresdefault_1.jpg",
    "source_size_px": [512, 288],
    "crop_box_src_px": [340, 238, 420, 272],
    "scale_to_720p": 2.5,
    "bands": [
      {"name": "sand",  "hex": "#A69A79", "src_x": [361, 375], "width_px_src": 15, "width_px_720": 38},
      {"name": "wash",  "hex": "#B1B3A3", "src_x": [376, 407], "width_px_src": 32, "width_px_720": 80, "foam": true},
      {"name": "water", "hex": "#A8B1AB", "src_x": [408, 419], "width_px_src": 12, "width_px_720": 30}
    ],
    "transitions_px_720": {"sand_to_wash": 30, "wash_to_water": 13},
    "secondary_source": {
      "file": "articolo-787.jpg",
      "crop_box_src_px": [700, 0, 960, 80],
      "dark_water_hex": "#333C3F",
      "foam": false
    },
    "foam": "pale gray-tan wash band (not white); donor procedural nautic()+particles() in coast band",
    "donor_shader": {
      "coast_fade_m": 0.57,
      "deep_fade_m": 1.07,
      "shallow_rgb": [0.1, 0.24, 0.24],
      "deep_rgb": [0.0, 0.025, 0.05]
    }
  }
}
```

---

## 4. Measurable acceptance criteria

All measurable on a rendered PNG with Pillow (1-px profile perpendicular to the shoreline; B−R index = blue−red).

| ID | Criterion | Target | How to measure | Port today |
|---|---|---|---|---|
| **C1** | **Band count** | **3** distinct bands (sand / wash / water) with ≥8 px plateau each @720p; B−R index monotonic ≈ −45 → −14 → +3 | Sample a perpendicular profile; quantize to 8×8 RGB bins; count plateaus separated by >3 B−R units | **1** (flat tan directly to flat blue) — FAIL |
| **C2** | **Band widths @720p** | sand **38 px** (accept 30–65); wash **80 px** (accept 60–90, incl. both gradients); shallow water **≥30 px** | Measure src-x spans of §1.1 profile ×2.5; or pixel-run lengths on the target render | wash band width **0 px** — FAIL |
| **C3** | **Colours** | sand `#A69A79`±15; wash `#B1B3A3`±15 (luma ≈ sand+25); shallow water `#A8B1AB`±15; dark river `#333C3F`±15 | Box means on each plateau | sand ≈ `#7B7252`, water ≈ `#205060` — FAIL |
| **C4** | **Foam presence** | pale wash band visible, luma above both neighbours; zero foam where depth > 1.07 m | Compare plateau luma; check foam pixels absent in deep water | none on collar (`world.gd:835` + shader `:48`) — FAIL |
| **C5** | **Shore edge hardness / smoothness** | sand→wash gradient **≤30 px**, wash→water **≤13 px** @720p; boundary x(y) has **no constant-x run >8 px** and **no per-row jump >8 px** | Trace edge x over ≥200 rows; run-length + Δx histogram | runs **17–81 px**, jumps **30–62 px** — FAIL |
| **C6** | **Rock/grass rim gradient** | **≤3 px** hard edge with tuft overhang, not a smooth gradient (inherited `TERRAIN_REFERENCE_IMAGES.md` §3.1 / §5 rank 6) | 1-px profile perpendicular to rim; count pixels grass-hue→rock-hue | not re-measured here (carried from prior doc) |
| **C7** | **Depth colour** | shallow cells measurably paler/bluer than deep cells (Δ ≥20/255 in one channel); dark river case `#333C3F` | Sample paired shallow/deep pixels | flat `#205060` everywhere — FAIL |

Global gate: C1–C5 must pass simultaneously; a wide tan ring with a correct sand hex still fails C1/C2/C5.

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Correction / caveat |
|---|---|---|---|---|
| Shore is 3-band sand→wash→water | `maxresdefault_1.jpg` profile x=350…419 | B−R index + 4× crop | **observed** | wash is pale gray-tan, not white foam |
| Sand `#A69A79`, wash `#B1B3A3`, shallow water `#A8B1AB` | boxes (361–376), (388–403), (408–420), y 238…272 | Pillow column means | **derived** | ±15 RGB; prior doc sand `#A89E7F` agrees within ±4 |
| Band widths 38 / 80 / ≥30 px @720p | same profile ×2.5 | Arithmetic | **derived** | thumbnail upscaled 2.5× → **UNVERIFIED at native res**, ±25% |
| Foam weak/absent (prior §3.4) | wash plateau +25 luma over sand, arc structure | Pillow luma + crop | **CORRECTION** | pale foam **is** present and measurable; prior "absent" rejected |
| Prior water hex `#696B65` for #12 | box `(330,120,470,260)` | Re-sample | **CORRECTION** | box was sand/infantry-contaminated; clean water is `#A8B1AB` |
| Dark river `#333C3F`, no foam | `articolo-787.jpg` box `(860,0,958,40)` | Pillow mean | **derived** | smoke/units contaminate wider box (`#444D53`) |
| Donor sandsea = oriented one-cell rim, not a wide collar | `texturemap.inc:472-511` active; `:934-954` commented | Plaintext read | **observed** | orientation mapping matches `game.gd:1195-1226` |
| Donor foam procedural, coast band only | `water.dev.frag:106,119,198-199,227`; no foam texture | Plaintext + dir listing | **observed** | scene foam requires shader-side coverage on land-adjacent cells |
| Port shows wide flat tan ring | shot + `sandsea5.png` mean `#7B7252` + `game.gd:785-813` | Visual + Pillow + read | **confirmed** | shot predates TB-B1e mitigation at `world.gd:1081-1103` |
| Port water edge is a 17–81 px stair-step | x(y) run-length on shot | Pillow trace | **confirmed** | root cause: per-tile coverage mask `world.gd:831-845` |
| Port cannot draw wash/foam on collar | `world.gd:836` (wet=0 for type 4) + shader `:48` discard | Read | **confirmed** | structural, not a tuning issue |
| TB-B1e/B1c already fix the shore | `world.gd:1081-1103`, `:1125-1130` | Read | **partial** | they narrow the tan feather; no wash band, mask still tile-aligned |
| Rock/grass rim ≤3 px | prior §3.1/§5 rank 6 | Inherited | **observed** (prior) | not re-measured in this lane |

### Open questions
1. Native-resolution donor water frame needed to confirm the 38/80/30 px widths (current source is a 512×288 thumbnail; `UNVERIFIED` ±25%).
2. Is there a post-TB-B1e render showing the narrowed ring, and does it add any wash band? Not captured in `app/shots/`.
3. `game.gd:780` claims a "≈2–3 tile band"; exact tile width in metres (`Data.TILE_M`) at the reference camera zoom was not measured here.
