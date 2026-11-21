# TERRAIN_BEAUTY_TRIAGE — coordinator handoff from research to build

Owner: coordinator. Status: **LIVE**. Updated 2026-11-21.
Sources: the 10 Lane-1 reports in `docs/audit/TERRAIN_*.md` (TDR-1…4, TPA-1…4, TS-1…2).
Protocol: `SWARM_OPS.md` §5b-QUALITY — evidence before edits, disjoint ownership,
backup before edit, Godot only via `godot_runner.py`, 29/29 + 17/17 gates.

This is the single place where the 10 reports are turned into **staged, assignable tickets**.
No ticket below authorises a speculative edit; each cites the report that justifies it.

---

## 1. Root causes, ranked by effect on visible beauty

| # | Root cause | Evidence (report / file:line) | Fixable in Stage 1 (sample-only)? |
|---|---|---|---|
| 1 | **The renderer discards the donor tile-block map.** `game.gd:1011-1080` computes donor-faithful per-cell block names; `world.gd:815-816,831` uses them only as a hash scalar blending `grass1`/`grass7`. Oriented `sandsea`/`rock` shore art never drawn. | TPA-1 B1/B2; TPA-2 §2 | **YES** — `world.gd` only |
| 2 | **Water is a cache-frozen crop.** One sheet loaded (`world.gd:675`); `variants[3]` dead (`:683-691`); phase sampled at bake (`:864`); standing camera never re-bakes. No depth colour, glints, foam, reflection. | TDR-4 §5; TPA-1 B3 | **YES** — `world.gd` + new shader |
| 3 | **Decor is three static billboards.** No bush/stump sprites (rock fallback), no rotation, no sway (`res_layer` redraw-gated at `world.gd:960-962`), no per-prop shadows by default. | TPA-4 G1–G6, G11 | **PARTLY** — `world.gd` art; new sprites need asset lane |
| 4 | **Season is a flat tint.** 27 winter + 12 desert blocks converted but unwired; `world.gd:880-890`. | TPA-2 C1; TDR-3 P0-2 | **YES** — `world.gd` + preset JSON |
| 5 | **Relief shape = round domes.** Donor ravine/plateau/mountain **stamps** (footprints 48–100 tiles) reduced to 4 paraboloids (14–26 tiles); height shading off for default `plains`. | TPA-3 H-1/H-3; TDR-1 stage 9, §3.5 | **NO** — generator = Stage 3; shading alone is `world.gd` |
| 6 | Pattern data gaps: 23 `donor_patterns.json` entries name non-existent files; only 11 of 60 donor families are stamped. | TDR-2 C4/C5 | Asset/generator = Stage 3 |
| 7 | `relief()` sign/R-code bug (TDR-1 C3) is **inert** on shipped masks — R/G binary, 255 only at starts (TDR-3 C3). Reconciled on board. | TDR-1 C3 + TDR-3 C3 | **NO visual effect** — deprioritise |

### Stage-1 beauty gate (from TS-1 measured spec)
Achievable with `world.gd`-only work: criteria **2** (grass palette), **5** (lighting/contrast),
**6** (hard rock/grass rim), **7** (micro-texture), **3** (tree variety, once new sprites land).
Criterion **1** (ravine rock morphology 8–18%) and **4** (biome tree density) require generator
work and are therefore **Stage 3 gates** — the sample's Stage-1 PASS is explicitly partial.

---

## 2. Ownership map (strictly disjoint — one file, one worker)

| File / family | Single owner for this wave | Note |
|---|---|---|
| `app/scripts/world.gd` + `app/shaders/**` | **RENDER-1** | All Stage-1 visual work is sequential sub-tickets under ONE owner; never two workers in this file. Back up before each edit. |
| `app/tools/export_donor_patterns.py`, `app/assets/terrain/patterns/donor_patterns.json` | ASSET-1 | Cheap name-resolution fix |
| `app/tools/convert_models.py`, `app/assets/models/**` (new env sprites) | ASSET-2 | Private-use conversion; no donor binary committed |
| `app/assets/terrain/structs/presets_winter.json` (new), `smooth_winter.json` (new) | ASSET-3 | Authored from donor `terrain.presets` Winter section |
| `app/scripts/game.gd` | SIM-1 | Stage 3 only |
| `app/scripts/pattern_gen.gd` | PAT-1 | Stage 3 only |
| `app/scripts/mapgen.gd` | GEN-1 | Stage 3 only; relief fix inert |
| `app/tools/scan_map.py` | QA-1 | Stage 3 relief metrics |
| `app/shots/terrain_sample.*`, `app/tools/terrain_sample_shot.py`, `app/tools/terrain_compare.py` | BUILDER-CAPTURE | TB-B0 harness (in progress) |

---

## 3. Build tickets

### Stage 1 — mini-map sample (gate: TS-1 criteria 2/3/5/6/7)

| ID | Ticket | Owner | Acceptance (measurable) | Evidence |
|---|---|---|---|---|
| TB-B0 | 64×64 sample harness + baseline capture + contact sheet | BUILDER-CAPTURE | runner job ok, PNG 1280×720 (not 800×600 CPU fallback), seed histogram water≥5/rock≥3/forest≥5, contact sheet produced | TS-2 §4/§7 |
| TB-B1a | Render the donor tile-block atlas instead of grass1/grass7 hash mix | RENDER-1 | same-seed sample shot shows ≥3 distinct block families across adjacent cells; max single-bake <250 ms; 2 chunks/frame + LRU 24 unchanged | TPA-1 TR-1 — **DONE** (jobs 613–615 ok, 29/29 + 17/17; perf not yet measured, flagged to QA) |
| TB-B1b | Replace coarse role overlays with per-cell oriented shore/cliff blocks | RENDER-1 | coastline shot shows ≥3 distinct beach/cliff tiles; perf unchanged | TPA-1 TR-2, TDR-3 §3.2 — **DONE** (same owner, sequential with B1a) |
| TB-B1c | Water: per-frame GPU overlay shader (2-octave scroll, depth colour, glints, foam), wire all 8 wave sheets, delete dead `variants[3]` | RENDER-1 | two frames 1 s apart with standing camera differ in water crop; no frame >250 ms (N-07); ≥2 distinct sheets bound | TDR-4 W-1…W-4/W-6, TPA-2 C2 — **DONE** (`app/shaders/water_overlay.gdshader`, 3 sheets, per-frame `time`, jobs 616–618 ok, 29/29 + 17/17; re-capture shows checker gone) |
| TB-B1d | Decor: dedicated bush/stump sprites or procedural fallback (never rock), size buckets + yaw, contact shadows, new env sprites | RENDER-1 | 0 bushes resolve to rock texture; ≥3 canopy silhouettes × ≥4 sizes; 29/29 + 17/17 | TPA-4 D1/D2, TDR-2 T2 — **DONE** (93 sids load, pools wired, jobs 631–634 ok, 29/29 + 17/17; trees still sparse at 64×64 due to stamp flooring → see TB-B0c iteration 2) |
| TB-B1e | Shore band softening: per-cell sandsea atlas + lower opacity/softer falloff instead of flat tan ring | RENDER-1 | coastline band shows texture, narrower visible edge; perf unchanged | visual baseline re-capture — **DONE** (max_alpha 0.55, falloff 1.7; effect modest in 64×64 shot) |
| TB-B1f | Enable slope/light height shading for default `plains` (render-only) | RENDER-1 | fixed-camera shot shows hill shading; luminance variance in hill bbox +10%; dump unchanged | TPA-3 H-3 — DEFERRED until B1d/B1e capture reviewed |
| TB-B2 | Fix 23 broken family-name entries; regenerate `donor_patterns.json` | ASSET-1 | missing-name count 23 → 0; `desert_forests_big` resolves ≥17 | TDR-2 T1 — **DONE** (tool-level aliases in `export_donor_patterns.py`; patterns 218→239, entries 266→264, 0 broken; `desert_mnt_14/15` absent in donor, dropped) |
| TB-B3 | Convert env meshes (spruce/pinedry/small conifers, rock/stonessea, bush/flower/reed) via private-use tools | ASSET-2 | ≥40 env sids in manifest; `sprites_hi/<sid>.png` per sid; distinct silhouettes in shot | TDR-2 T2, TPA-4 D6 — **DONE** (87 new env sids, manifest 29→116, 512² hi sprites + .import for all, 0 donor binaries added) |
| TB-B4 | Author `presets_winter.json` (124 entries) + `smooth_winter.json` | ASSET-3 | valid JSON; 27 distinct `winter*.png` referenced; no summer file modified | TPA-2 A1, TDR-3 P0-2 |

**Stage-1 exit gate:** re-run TB-B0 capture, side-by-side against `cossacks-3-v1-498085.jpg`
crops A/B/C, score TS-1 criteria 2/3/5/6/7. Only when those pass does Stage 3 open.

### Stage 2 — keep the sample permanent
Fixed runner command + PNG/contact-sheet committed; re-capture on every terrain change.
No ticket — this is a standing rule on the board.

### Stage 3 — full-map generation (opens only after Stage-1 exit gate)

| ID | Ticket | Owner | Acceptance | Evidence |
|---|---|---|---|---|
| TB-B5 | Stamped relief: use donor hill/ravine/plateau footprints to shape height inside `_gen_base` before collision; retire analytic domes | RELIEF-1 | scan `cliff≥80`, `tileflow≥99`; ≥2 seeds show contiguous `h>0.5` regions with length/width ≥1.5 | TDR-1 §5.7, TPA-3 H-1 — **DONE** (43 families/282 patterns, 6 new relief families; rock 2.3–3.7%, anisotropy 1.43–1.63, plateau ~20%, ravine cuts 4.5%; selftest 29/29, uitest 17/17, scans green, byte-identical dumps; rock% below 8–18% target deferred for walkability) |
| TB-B6 | Extend `recipes` with donor families (mountains, plateau*, ravine_big, plain_*, swamp_*, dcr2/3, decor_big) | PAT-1 | ≥12 distinct families stamped; no determinism regression | TDR-2 T4/T5, TPA-4 D4 |
| TB-B7 | Tile compatibility smoothing (3 passes) + forest-border feathering | SIM-1 | 0 incompatible adjacent tile pairs after passes | TDR-1 §5.9/§5.10 |
| TB-B8 | Wire winter/desert block pools into `_assign_tileblocks` | SIM-1 | 27 winter + 12 desert PNGs referenced by name; pixel difference beyond uniform tint | TDR-3 P0-2/3 |
| TB-B9 | Add relief metrics to `scan_map.py` (plateau/ravine fraction, ridge anisotropy) | QA-1 | metrics print for seeds 7/8/9; thresholds set only after baseline sweep | TPA-3 H-5 |
| TB-B10 | Convert missing DLC5 mask families (coastal 57, lakes 151, rivers 157) + nowater 42 | ASSET-1 | exact counts, pixel-identical samples, manifest keys added | TDR-3 P1-4/5 |

---

## 4. Explicitly NOT ticketed

- **R1–R6 relief parameters** — UNVERIFIED in donor plaintext (TDR-1 C27). No donor numeric source.
- **`postprocess.inc` Gaussian** — editor-only; random maps use pre-blurred `*_gauss.png` (TDR-1 C6).
- **Shore-foam texture family** — does not exist in donor (TDR-3 C1); any foam is port-authored.
- **`relief()` sign fix alone** — inert on shipped masks (board reconciliation); fold into TB-B5 if desired, not a standalone Stage-1 slot.
- **`main.gd` camera flag** — only if TB-B0 proves the showcase feature is off-screen; one owner then.

## 5. Open questions for owner
1. Confirm temperate-ravine biome for the sample (TS-1 Q1) — currently assumed from image #8.
2. Confirm windowed capture works in this environment (TS-2 Q2); if not, Stage 1 needs an offscreen render path.
3. Accept that Stage-1 PASS is partial (no ravine morphology until Stage 3)?
