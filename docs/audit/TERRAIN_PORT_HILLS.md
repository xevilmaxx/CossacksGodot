---
title: Deep audit — port hill / relief fidelity & beauty (TPA-3)
owner: coordinator
decision: D-22 / SWARM_OPS §5b-QUALITY
auditor: TPA-3 (port-side AUDIT lane, read-only)
updated: 2026-11-21
status: FINAL — read-only; no Godot run, no code edit
ticket: TB-A3 / SWARM_BOARD.md:142
---

# 🔬 Deep audit — hills / relief in the Cossacks 3 → Godot port

> [!IMPORTANT]
> Quality-first protocol (`SWARM_OPS.md:114-135`). Every statement is labelled
> `observed`, `derived` or `inferred`; nothing unmeasured is called green.
> Claims that cannot be measured from the files present in this repo are
> marked `UNVERIFIED`. **No code was edited and no Godot process was run.**
> Donor source line numbers quoted here come from the research docs
> (`docs/TERRAIN_GEN_RESEARCH.md`, `docs/audit/GEN.md`); the donor game
> installation is NOT in this workspace, so donor-side claims are second-hand
> unless a donor-derived constant is reproduced in-repo.

---

## 1. Sources read

| File | Lines | What was read |
|---|---|---|
| `app/scripts/game.gd` | 127-136, 222-272, 485-586, 588-751, 753-766, 835-873, 982-1006, 1011-1080, 1082-1161, 1264-1285, 1294-1312, 3310-3340, 3455-3475, 3725-3745 | stage reseed; `setup`/`setup_begin`; `_gen_patterns`; `_generate_map`/`_gen_base` (domes, terrain typing, shore ring, collision); `_gen_forests`; `_gen_finish`; detail pass; tileblock/shore/cliff orientation; `height_at`/`slope_to` |
| `app/scripts/mapgen.gd` | 1-199 (all) | donor constants 13-18, `relief()` 51-61, mask sampling 112-176, `_near_water` 86-110, coastal smoothing 179-196 |
| `app/scripts/pattern_gen.gd` | 1-267 (all) | `Stamp` 27-35, `build` 37-267, `scale_cells` 65-83, `can_stand`/`stand` 85-102, `stamp_family` 130-162, ellipses 164-178, mines 203-237, recipes 248-265 |
| `app/assets/terrain/patterns/donor_patterns.json` | parsed (single-line JSON) | family list (37 families), pattern list (218 patterns), cell counts/extents of `hil1-4`, `g_hil1-9`, `big_hill_1`, `desert_mnt_1` |
| `app/scripts/MAPGEN_STATUS.md` | 1-96 | liveness, scale coupling, dead `forest` output, multi-start CIRCLE2 note |
| `app/scripts/world.gd` | 557-568, 778-796, 798-918 | `_draw_sprite` contact shadow, `_relief_key`, `_build_chunk` terrain roles + season/relief shading |
| `app/tools/scan_map.py` | 1-274 (all), esp. 100-122, 185-208, 236-253 | `cliff_ring`, `scan_one`, pass/fail gates |
| `app/scripts/data.gd` | 33-45, 115, 128-143, 176-188 | `MAP_W/H` defaults, `GENERATOR_VERSION`, `QUALITY`, `MAPGEN` dome budget, `RELIEF_SCALE`, `RELIEF_DOME_DELTA` |
| `app/scripts/config.gd` | 46-47, 379-380 | configured `map_width_tiles=320` (overrides data.gd's 160 default) |
| `docs/TERRAIN_GEN_RESEARCH.md` | 1-86 | donor pipeline stages, relief formula, pattern families, water/shore thresholds |
| `docs/audit/GEN.md` | 1-423 | prior audit, `s`/`area_scale`/`mscale`, cliffs, forest flecks, claim table |
| `SWARM_BOARD.md` | 57-70, 136-142 | P-19, P-46/47/48 status; TB-A3 assignment |
| `SWARM_OPS.md` | 114-135 | §5b-QUALITY rules |

Donor-side facts used (all second-hand via the docs above, cited inline):
`dogenerate.inc`, `generatemap.inc` (`:4-7`, `:611-640`), `texturemap.inc`
(`:30-31`, `:426-447`, `:557-609`), `generator.cfg:2-28` + `Patterns` section.

---

## 2. Current hill / height pipeline (as built, in execution order)

`observed` — the configured map is **320×320** (`config.gd:46-47,379-380`), so
`_st_mscale = 2.0` (`game.gd:271`), pattern scale `s = 320/160 = 2.0`
(`pattern_gen.gd:47`) and `area_scale = 4.0` (`pattern_gen.gd:248`). Default
`QUALITY = "high"` (`data.gd:115`) → dome budget 4 (`data.gd:138`);
default `RELIEF = "plains"` (`data.gd:184`) → `relief_domes = 0`
(`data.gd:188`). Line numbers below are CURRENT; `docs/audit/GEN.md` quotes
pre-fix numbers (its `game.gd:487`, `:556-569`, `:621-642` now map to
`:555-561`, `:643-657`, `:709-730`).

| # | Stage | file:line | Exact math / action | Problem for hill beauty & fidelity |
|---|---|---|---|---|
| 1 | Pick donor RGB mask | `mapgen.gd:39-49,112-129` | `pick(type,seed)` = deterministic `seed^type.hash()+104729`; load `res://assets/terrain/masks/<file>` via `Texture2D.get_image()` | `observed` — shipped masks are `*gauss.png` (`GEN.md:68-70`): the R channel is blurred, not the donor's discrete plateau/hill/ravine codes. |
| 2 | Mask → base height | `mapgen.gd:142-176` | average RGB over each cell (skip pure-white starts); `hw = -1.1*(cb/255)*(1+(cr/255)*3.5)`; `height[i] = hw + relief(cr)`; `forest[i]=cg/255` | `observed` — matches donor formula (`TERRAIN_GEN_RESEARCH.md:24-28`). `derived` — `relief()` bands are narrow (below), so a gaussian R channel lands almost entirely in the linear fallback → smooth ramps, **no crisp plateaus or ravine cuts**. |
| 3 | `relief(v)` mapping | `mapgen.gd:51-61` | `v>=250 → +2.964`; `|v-96|<=12 → +1.317`; `|v-48|<=12 → -2.964`; else `2.964*(v/255)*0.5`; else 0 | `observed` — plateau/ravine constants are donor-derived (`generatemap.inc:4-6`), but the ±12 tolerance is port-authored; `derived` — a blurred mask never satisfies the plateaus for long, so flat tops are absent. |
| 4 | Coastal smoothing | `mapgen.gd:86-110,179-196` | `near[i]=1` if `h<0.8` or a neighbour within ±2 has `h<-0.1`; 3 passes (1 low / 2 medium): `h = h + (avg4diag - h)*0.5` | `observed` — donor-faithful (`generatemap.inc:611-640`); affects coast only, not hill interiors. No problem for hills. |
| 5 | Relief domes | `game.gd:643-657` | `count = budget.domes(4) + RELIEF_DOME_DELTA[relief]`; centre uniform in `[0.2,0.8]·MAP` (RNG from continuous `rng`, *not* `gen_rng`); `rr ∈ [7,13]` tiles; `h += (1-dd)^2 · (2.964/2.25) · relief_scale` for `dd<1`, skipping `h < WATER_SHORE(-0.1)` | `derived` — profile is a **radially symmetric paraboloid**, peak `1.317·scale` = 1.32/1.98/2.90 for plains/hills/mountains. `observed` — no plateau clamp, no negative (ravine) term, no anisotropy. `derived` — footprint Ø14-26 tiles vs donor hill-stamp footprints Ø48-100 tiles (§3 row 1) → domes are 2-7× too small and always round. |
| 6 | Terrain typing | `game.gd:664-674` | `h<-0.25 → terrain 3 + blocked`; `-0.25<=h<-0.05 → terrain 4`; else 0 | `observed` — no height-driven rock band; hill slopes stay meadow (terrain 0) unless made steep by pass 8 or stamped by pass 7. |
| 7 | Shore collar | `game.gd:681-705` | water cells touching non-water become sand (4), unblocked | `observed` — donor-like collar; not a hill defect. |
| 8 | Collision / cliff pass | `game.gd:709-730` | on non-water/non-sand: cardinal `|dh|>0.5` or diagonal `|dh|>0.55` → `terrain 5` + `set_blocked_tile` | `observed` — uses donor `texturemap.inc` thresholds. `derived` — runs **before** `_gen_patterns`; safe today only because pass 7 no longer writes height (P-47). Any future height write from hill stamps must be moved before this pass. |
| 9 | Pattern stamps | `pattern_gen.gd:130-162,248-265`; consumed `game.gd:485-586` | hill stamps: `hills_dark` 8 + `hills_light` 8 (=2×`area_scale=4`) placed by rejection sampling; footprint cells scaled by `s=2` at `pattern_gen.gd:76-77` | `observed` — `game.gd:555-561` "hill" branch only does `if dc<=2.2: terrain=5` (dc is distance from centre in tiles); **no height write** (P-47 removed it). `derived` — a 293-1153-cell donor footprint becomes a ≤2.2-tile (≈4.4 m) rock dot; the donor shape is discarded. |
| 10 | Grove / resource passes | `game.gd:753-766,835-858` | 4 grove discs `r=4.5·TILE·mscale=18 m = 9 tiles`; `mscale=2` | `observed` — P-46 DONE (`SWARM_BOARD.md:68`); not height-related. |
| 11 | Tileblock / rock art | `game.gd:1011-1080,1082-1161` | rock blocks chosen by RNG for `terrain=5`; cliff tile orientation by height gradient (`_cliff_tile_for`, `rock8` if `|h|>2.7`); 3-pass SmoothTileMap | `observed` — height affects *orientation* of rock tiles but not *whether* a hill is painted rocky; orientation only applies to already-rock cells. |
| 12 | Detail pass | `game.gd:982-1006` | `h<0.1` picks `tile_lowground` else `tile_highground`; `tex=R/2`, only cells still on default block | `observed` — donor-derived; one height threshold, no contour bands. |
| 13 | Render shading | `world.gd:778-796,876-905` | `relief_on = relief!="" and relief!="plain" and relief!="plains"` (`:882`); shade `= clampf(0.10 - hh*0.04*rscale, 0, 0.20)` (`:900`), bilinear upscale, RGBA8 blend | `observed` — **OFF by default** because `RELIEF="plains"`; when on, it darkens *low absolute height*, not slope, and has no directional light, contours or hill shadows. |
| 14 | Height sampling | `game.gd:1264-1279` (`height_at`); `slope_to` `:1281-1285` | bilinear over the 4 neighbouring height cells | `observed` — correct sampler; consumed by combat (`game.gd:3332,3468,3739`) and world shading. |

---

## 3. Divergence table (port vs donor)

| # | Port (observed) | Donor (documented / donor-derived) | Evidence | Beauty impact |
|---|---|---|---|---|
| 1 | Relief shape = round paraboloid domes Ø14-26 tiles, peak ≤2.90 | Relief = discrete mask codes (255 plateau / 96 hill / 48 ravine) **plus** hand-authored elongated hill/mountain stamps | `game.gd:657`; `mapgen.gd:51-61`; donor cell extents measured from `donor_patterns.json`: `hil1` 305 cells x[-12,12] y[-20,19], `g_hil1` 725 cells x[-16,15] y[-28,25], `big_hill_1` 1153 cells x[-25,25] y[-28,27] (×2 at s=2 → 48-100 tiles across); `TERRAIN_GEN_RESEARCH.md:24-28,49-53` | **Primary complaint.** Donor hills are long ridges/plateaus/cuts; port hills are small smooth blobs. `derived` footprint ratio 2-7×. |
| 2 | No plateaus, no ravines; domes only add positive height | Plateau `+2.964`, hill `+1.317`, ravine `-2.964` as distinct terrain forms | `mapgen.gd:51-61`; `game.gd:657` (`+=` only); `*gauss.png` masks in `GEN.md:68-70` | Flat-topped hills and cut ravines are missing; relief reads as gentle undulation. |
| 3 | Donor hill stamps used only to paint a ≤2.2-tile rock disc | Hill patterns are multi-cell clumps that shape the terrain themselves | `game.gd:555-561`; `pattern_gen.gd:258-259,265`; 293-1153 cells per hill pattern (`donor_patterns.json`) | Stamped hill geometry is invisible; only a tiny grey speck remains. |
| 4 | Mountain families absent from the port's data/recipes; "mountains" only scales domes ×2.2 and adds 2 domes | Task brief lists `g_mnt1-7`, `i_mnt` mountain families; exported JSON has only `hills_dark`, `hills_light`, `decor_big(big_hill_1)`, `desert_mountains` | `donor_patterns.json` families list (parsed); `pattern_gen.gd:248-262`; `data.gd:187-188`; donor family list in `TERRAIN_GEN_RESEARCH.md:49-53` does not mention g_mnt/i_mnt either | `UNVERIFIED` that g_mnt/i_mnt exist in the donor `generator.cfg`; `observed` that they are absent from port data. No mountain stamp shapes exist on the port. |
| 5 | Height shading disabled for the default relief (`plains`) | Relief affects the drawn terrain (rock tiles by height/gradient, donor texture selection) | `world.gd:882`; `data.gd:184`; `game.gd:1141-1148` | Default maps show no height cue at all even where height varies — hills look flat. |
| 6 | Shading is a uniform valley darkening by absolute `hh`; no slope/gradient, contours or directional shadow | Donor orients shore/cliff tiles by the height gradient and paints rock on hills | `world.gd:900`; `game.gd:1082-1161`; `scan_map.py:100-103` (comment: donor paints rock on *walkable* hills too) | No volumetric read (no lit/unlit ridge faces), no contour lines; hills lack depth. |
| 7 | Rock painting tied to collision steepness `|dh|>0.5` or a tiny stamp disc | Donor rock1 appears on walkable hill slopes as part of relief art | `game.gd:729-730,555-561`; `game.gd:1053-1065`; `scan_map.py:100-103` | Port hills stay green until unwalkably steep; donor hills have rocky faces. |
| 8 | `forest` field from the mask is computed but never read | Donor G channel is consumed by the pattern pass | `mapgen.gd:176,197`; `game.gd:626-627` (`_st_forest` only assigned); `GEN.md` claim 10 / `MAPGEN_STATUS.md:38-42` | Not a hill-geometry defect, but a lost donor input: the mask's forest/stone signal cannot influence relief-adjacent clustering. `observed`. |

---

## 4. Claim table

| # | Claim | Evidence | Verification method | Verdict | Correction needed |
|---|---|---|---|---|---|
| 1 | "Post-collision `height += 0.25` still makes cliffs wrong (seed 9 cliff 0%)" | `game.gd:555-561` hill branch now paints only `terrain[ii]=5`; no height write; `SWARM_BOARD.md:69` P-47 DONE (0%→100%) | full grep of `height[` writes in `game.gd`: only `:657` (domes, pre-collision) and `:1265-1279` read path; compare `GEN.md:249-251,293` | **CONTRADICTED** (was real, now fixed) | none — close; do not re-litigate P-47 |
| 2 | "Forest = 4 grove discs + ~300 one-tile flecks" | `SWARM_BOARD.md:68` P-46 DONE: patches 12/12/12, mean 83/86/85 | board status + `_gen_forests` `:753-766` / P-46 core-disc paint `:503-524` | **CONTRADICTED** (fixed) | none |
| 3 | "Mapgen.gd is implicated in the RED scan metrics" | `mapgen.gd:112-199` emits only height/forest/starts; `_st_forest` at `game.gd:627` never read; `GEN.md:296` claim 10 | full read + call-site grep | **CONFIRMED for scan metrics** | For *beauty*, scope changes: `mapgen.gd:51-61,174-175` IS the base relief source; `GEN.md`'s "do NOT edit mapgen.gd" must not be read as a beauty exemption. |
| 4 | "The `(1-dd)^2`, `2.964/2.25` dome profile is donor-faithful" | `game.gd:657`; donor plateau/hill constants reproduced at `mapgen.gd:14-16`, but no donor script in repo contains this profile or a `domes` count | grep of all in-repo donor-derived docs (`TERRAIN_GEN_RESEARCH.md`, `GEN.md`) for dome formula — none found | **UNVERIFIED** | requires TDR-1/TB-R1 to locate donor dome/stamp height code before calling it faithful |
| 5 | "Donor `g_mnt1-7` / `i_mnt` families exist and could beported" | task brief asserts them; `donor_patterns.json` parsed families (37) contain neither; `TERRAIN_GEN_RESEARCH.md:49-53` also silent | parse JSON; read research doc | **UNVERIFIED** (existence); **observed** absent from port data | needs TDR-2 / donor `generator.cfg` re-export; do not add speculative family names |
| 6 | "Height affects default-map shading" | `world.gd:882` gate excludes `"plains"`; `data.gd:184` default is `"plains"`; only shading code is `world.gd:891-904` | read `_relief_key` + all `height_at` call sites in world.gd (sole render use `:898`) | **CONTRADICTED** | default has zero height shading; see H-3 |
| 7 | "Donor hill stamps shape the terrain height" | donor hill footprints 293-1153 cells (`donor_patterns.json`); port stamps them (`pattern_gen.gd:258-259`) but `game.gd:555-561` discards the shape | cell-count measurement + read of hill branch | **CONFIRMED as a port divergence**; donor mechanism `inferred` (no donor height-on-stamp code in repo) | see H-1; TDR-1 to confirm donor behavior |
| 8 | "Cliff ring metric stays green after any fix" | `scan_map.py:100-122`, gate `:248`; board P-47 100% on all seeds | read scan + board | **UNVERIFIED for future edits** | any new height write must precede `game.gd:709-730`, then re-dump + re-scan |
| 9 | "The 320 size multipliers (s=2, area_scale=4, mscale=2) still drive hill count" | `config.gd:46-47`; `game.gd:271`; `pattern_gen.gd:47,248`; `data.gd:138` | read all entry points; `derived` values | **CONFIRMED** | none in this file |
| 10 | "Donor relief uses 3-pass coastal smoothing" | `mapgen.gd:179-196`; `TERRAIN_GEN_RESEARCH.md:24-28`; `generatemap.inc:611-640` | code read + doc | **CONFIRMED** | none |

---

## 5. Recommendations — build tickets (proposals, not edits)

Ownership is disjoint: **one worker per file**. No ticket below requires another
worker to edit the same file. None was implemented by this auditor.

### H-1 — Donor-shaped hill relief instead of round domes
- **Owner:** the single `game.gd` worker (IMPL-SIM / PORT-SIM).
- **Target:** `game.gd:643-657` (domes) and `game.gd:555-561` (hill stamp branch); keep the collision pass at `:709-730` strictly after every height write.
- **Proposed small diff:** stop treating the donor hill-stamp footprints as a rock dot. Use the already-available `pattern_stamps` cell lists to add donor-shaped height (elongated footprint, plateau/ravine profile) inside `_gen_base` **before** the collision pass, and reduce/remove the synthetic `(1-dd)^2` dome. This touches only `game.gd` (reuse `pattern_gen.gd` data read-only, no edit there).
- **Acceptance criterion (measurable):** on seeds 7/8/9, `scan_map.py` reports `cliff>=80` and `tileflow>=99` unchanged; a new dump shows contiguous height>0.5 regions whose length/width ratio ≥1.5 (ridge) on ≥2 seeds; screenshot A/B of seed 9 shows flat-topped or elongated relief. **Baseline must be measured first** — `UNVERIFIED` until then.
- **Gate:** do NOT implement until TDR-1 confirms the donor hill-stamp height behaviour (claim 7/4). No speculative profile.

### H-2 — Recover discrete plateau/ravine levels from the mask
- **Owner:** the single `mapgen.gd` worker (agentQ per `MAPGEN_STATUS.md`).
- **Target:** `mapgen.gd:51-61` (`relief()`) and `:174-175` (sampling).
- **Proposed small diff:** quantise the sampled R channel to the donor codes (255/96/48) before `relief()`, so gaussian masks produce the donor's discrete plateau/hill/ravine bands instead of a linear ramp. Confidence: `inferred` (a recovery method for blurred masks, not a donor statement).
- **Acceptance criterion:** new `scan_map.py` metric (H-5) shows ≥5% of land tiles within ±0.02 of `+2.964` (plateau) and ≥1% within ±0.02 of `-2.964` (ravine) on the land masks, with `water` vs mask still within ±5 pp. **Baseline UNVERIFIED.**

### H-3 — Height-based shading / contours on by default
- **Owner:** the single `world.gd` worker (PORT-VIS).
- **Target:** `world.gd:882` (gate) and `:891-904` (shade grid).
- **Proposed small diff:** drop the `relief!="plains"` exclusion so height shading is active for every map; shade from the local height gradient (slope magnitude + light direction) rather than only `hh`; optionally add subtle contour bands at the donor relief thresholds. Render-only: no gameplay dump changes.
- **Acceptance criterion:** screenshot A/B on seed 9 (fixed camera) shows visible hill shading; measured luminance variance inside a hill bounding box increases ≥10% vs baseline; `scan_map.py` metrics unchanged (render-only). **Baseline UNVERIFIED.**

### H-4 — Export / enable donor hill & mountain stamp families
- **Owner:** the single `pattern_gen.gd` worker (IMPL-PATTERN).
- **Target:** `pattern_gen.gd:248-262` recipes (and `home()` `:125-128` for biome variants).
- **Proposed small diff:** add the in-repo `decor_big` / `desert_mountains` families to the rest-stage recipes so mountain/hill stamps are actually placed; do NOT invent `g_mnt`/`i_mnt` names until TDR-2 exports them. Note: alone this only changes stamp counts — height shaping depends on H-1.
- **Acceptance criterion:** headless `C3PatternGen.build` result contains ≥N stamps with `family in ("decor_big","desert_mountains","hills_dark","hills_light")` on seeds 7/8/9; no increase in `scan_map.py` patches beyond 16. **Baseline UNVERIFIED.**

### H-5 — Measurable relief metrics in the QA harness
- **Owner:** the single `scan_map.py` worker (IMPL-DOCS).
- **Target:** `scan_map.py:100-122` (beside `cliff_ring`) and `:194-208` (`scan_one`), gates at `:236-253`.
- **Proposed small diff:** add `relief_profile` metrics from the `height` array already decoded at `:34-36`: plateau fraction, ravine fraction, ridge anisotropy (bbox ratio of contiguous `h>0.5` regions), and height-delta histogram. Set thresholds only AFTER a baseline dump sweep.
- **Acceptance criterion:** metrics print for seeds 7/8/9; existing gates stay green; thresholds agreed by coordinator before any new FAIL is asserted.

### Ownership map (single worker each)
| File | Proposed worker | Tickets |
|---|---|---|
| `app/scripts/game.gd` | IMPL-SIM / PORT-SIM | H-1 |
| `app/scripts/mapgen.gd` | agentQ | H-2 |
| `app/scripts/pattern_gen.gd` | IMPL-PATTERN | H-4 |
| `app/scripts/world.gd` | PORT-VIS | H-3 |
| `app/tools/scan_map.py` | IMPL-DOCS | H-5 |
| `app/assets/terrain/patterns/donor_patterns.json` | TDR-2 (TB-R2) | re-export g_mnt/i_mnt if they exist |

### Determinism caveat
`observed` — dome centres are drawn from the continuous `rng` stream
(`game.gd:645-647`), not the staged `gen_rng`. Any change to dome count or draw
count shifts downstream seed dumps (`GEN.md:354-355` warns about this). Acceptance
must therefore use scan metrics + screenshots, **not** byte-identical dumps.

---

## 6. Open questions

1. **UNVERIFIED — dome provenance.** No donor script in this repo contains `2.964/2.25` as a dome amplitude or `(1-dd)^2` as a profile. TDR-1/TB-R1 must locate the donor relief-stamp height code before H-1 is called faithful.
2. **UNVERIFIED — g_mnt/i_mnt existence.** Task brief names them; neither `donor_patterns.json` nor `TERRAIN_GEN_RESEARCH.md:49-53` lists them. Need a donor `generator.cfg` read (TDR-2).
3. **UNVERIFIED — do donor hill stamps mutate height?** Their 293-1153-cell footprints (`donor_patterns.json`) strongly suggest yes (`inferred`), but no donor height-on-stamp code was available. H-1 is gated on TDR-1.
4. **UNVERIFIED — mask quantisation.** Whether the donor shipped blurred masks (and used the raw ramp) or crisp masks (and used exact codes) is unknown; the port's `*gauss.png` names imply blur. H-2 must measure before/after.
5. **Baseline metrics missing.** None of the H-1/H-2/H-3/H-4 acceptance thresholds has a measured baseline on seeds 7/8/9; all are explicitly `UNVERIFIED`. H-5 should land first to supply them.
6. **Default `RELIEF="plains"`** (`data.gd:184`) disables all height shading (`world.gd:882`); if that is intentional, H-3 changes the shipping look for every default skirmish — coordinator decision needed.
7. **Multi-start asymmetry** (`MAPGEN_STATUS.md:61-67`) and `forest` field being dead (`game.gd:627`) are out of scope for hill geometry but may interact with H-4 clustering.
8. **Verification logistics.** Prior audits needed sequential dump jobs with `max_wait>=3600` due to runner saturation (`GEN.md:419-422`); re-verification dumps should follow that pattern.

---

## 7. Bottom line

`observed` — the port's base height formula and coastal smoothing are faithful
(`mapgen.gd:174-175,179-196`), and the two most-cited prior complaints
(post-collision height bump P-47; 300 forest flecks P-46) are already DONE in
the current code. The remaining hill problem is **shape and rendering**: the
donor's plateau/ravine codes and long hand-authored hill/mountain stamps
(48-100 tiles across) are reduced to four round paraboloids (14-26 tiles) plus
a ≤2.2-tile rock dot, and height shading is switched off for the default
`plains` relief. All of that is `observed`/`derived` from the files above; the
donor's exact hill-stamp height behaviour remains `UNVERIFIED` pending TDR-1.
