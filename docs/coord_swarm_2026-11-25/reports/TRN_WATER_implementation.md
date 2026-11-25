---
id: TRN-WATER
task: "Donor-grounded shore/water fix — dark bands, swell, alpha confinement"
date: 2026-11-25
status: DELIVERED__HEADLESS_SMOKE_PASS__NO_FULL_GATE__NO_VISUAL_PARITY_CLAIM
scope: "Edited EXACTLY two owned source files + this report. world3d_terrain.gd, game.gd and all other files READ-ONLY."
owns:
  - variant3d/shaders/water3d.gdshader
  - variant3d/scripts/water3d.gd
  - docs/coord_swarm_2026-11-25/reports/TRN_WATER_implementation.md
backups:
  - inbox/backup/water3d.gdshader.bak-TRNWATER
  - inbox/backup/water3d.gd.bak-TRNWATER
smoke_job:
  runner: "python variant3d\\tools\\godot_runner.py run --id trnwater-smoke --timeout 180 -- --headless --path variant3d --script <temp>/trnwater_smoke.gd"
  ticket: 343
  runner_status: ok
  wait_s: 64.80
  run_s: 5.63
  stdout_verdict: "TRNWATER_SMOKE RESULT: PASS"
  stderr_script_error_lines: 0
labels: [observed, derived, port-approximation, UNVERIFIED]
visual_parity_claim: false
---

# TRN-WATER — donor-grounded shore/water fix

## 1. Read-first evidence (all citations re-read this session)

| Source | Fact used |
|---|---|
| `docs/coord_swarm_2026-11-25/GAPS.md` §2 "Shore / water" row (line 38) | Port feeds −0.25 as surface Y → swell zeroed; near-zero-alpha water cells clamp to `grass1`; `shore_prox` derived inert; confine alpha. |
| `docs/coord_swarm_2026-11-25/PLAN_IMPLEMENTATION.md` line 31 (TRN-WATER row) | Owned files; "confine water alpha to actual water cells; revisit hmapMin/Max ±2.96, coastfade; keep donor literals/equations; no foam image"; T2 acceptance. |
| `reports/DTRN_03_donor_shore_water.md` C16, C28, C29, C30, W1–W3, §3.3, §5 F1–F3, §7 | `waveheight=clamp(WATER_LEVEL*3−1.5,0,1)` is 0 for Y≤0.5; grass1 clamp at waterline; foam multiplier is port art; exact fade ramp and foam peak 0.535 m. |
| `reports/RV_TRN_03_water_bindings.md` §2, §5.2, §7.3, §9 | `hmapTex`/`hmapMin/Max`/`reflectionMap` UNVERIFIED; `shore_prox` **inert (=1)** under shipped constants; do not retune `water_level` to the 2D app's 1.0. |
| `decomp/DEC_05_terrain_formats.md` §4.3, §5.1, §5.3 | `heightmapwaves0.tga` alpha = 255 for all 65,536 px (cannot be `hmapTex`); `sandsea1..6` = preset ids 93–98; near-water tiles `sandsea1/5/6`. |
| `reports/V3D_02_terrain_render_audit.md` P6 (line 91), F6 (line 129), T2 (line 146) | Dark full-width bands are height-aware-water tinting of low land; F6 = confine alpha, keep donor literals; T2 = dark rows 0, one plane, land untinted, animation visible. |
| Donor `water.dev.vert:16-18`, `water.dev.frag:37,72-75,168,198-199,227,229-230`, `texturemap.inc:29-31,463-472,503-511` | Primary equations / classification literals (as re-cited in the two verification reports above; donor files READ-ONLY, not executed). |

## 2. Before → after (minimal, evidence-cited)

### 2.1 Surface Y decoupled from the −0.25 classification literal (task item 1)

| | `water3d.gdshader` | `water3d.gd` |
|---|---|---|
| **Before** | `float WATER_LEVEL = water_level;` — the **classification** literal `cWaterHeight=−0.25` (`texturemap.inc:30`) was fed in as the donor's plane Y `gl_TexCoord[1].z` (`water.dev.frag:167`, `water.dev.vert:18`). | Plane vertex Y = `WATER_LEVEL` (−0.25). No separate surface-Y concept. |
| **After** | New uniform `water_surface_y` (PORT APPROX placeholder −0.25) owns the `WATER_LEVEL` role; `water_level` is retained **only** as the static water-cell classification threshold. `waveheight = clamp(WATER_LEVEL*3−1.5,0,1)` is unchanged in form and now reads the surface Y, exactly as the donor reads `gl_TexCoord[1].z`. | New `const WATER_SURFACE_Y = -0.25` (labelled PORT APPROX for the UNVERIFIED engine plane Y); set as `water_surface_y`; plane vertices use it so shader and geometry agree. |

- Donor literals **preserved verbatim**: `water_level=−0.25`, `shore_height=−0.1`, `max_height=2.96`, `coast_fade_depth=0.57`, `deep_fade_depth=1.07`, spec 170/120, particle 30, colours, `texScaleS/T=0.1/0.01`, HDR 1.
- With the placeholder surface Y the swell still reads `clamp(−2.25,0,1)=0` — a **derived donor consequence** (DTRN-03 C16), not a retune. A labelled A/B value `>0.8333` restores the coarse swell; it is never presented as recovered donor truth (RV-TRN-03 §7.3 forbids adopting the 2D app's 1.0).
- Audit fields added to `stats`: `water_surface_y`, `water_surface_y_source`, `waveheight_from_surface_y` (both 0 under default), keeping the existing `waveheight_from_donor_literal=0` that RV-TRN-03 §7.1 expects T2 to assert.

### 2.2 Confine alpha to actual water cells (task item 2)

| | Shader |
|---|---|
| **Before** | Coverage relied solely on `if (height > level) discard;` (`water.dev.frag:176-183`); `alpha = coastfade2` with no water-cell gate. An animated `level` perturbation could tint dry low land (V3D_02 P6 "full-width dark rows"). |
| **After** | Added a labelled PORT GUARD `float water_cell = 1.0 - step(water_level, height);` (1 when `height < −0.25`, i.e. donor water class `mask.B>0 AND height<cWaterHeight`, `texturemap.inc:30,463-472`), and `float alpha = coastfade2 * water_cell;`. |

- The **exact donor ramp is untouched**: `coastfade = (level−height)/0.57` (colour), `coastfade2 = (level−height)/1.07` (alpha/deep tint). Inside water cells `alpha = coastfade2` bit-for-bit; outside, hard 0.
- At the exact waterline inside a water cell `coastfade2 = 0` → `alpha = 0`; foam `× coastfade` → 0; foam still peaks at depth ≈ 0.535 m (DTRN-03 §3.3 derived table). No alpha floor added (2D's 0.35 is explicitly not copied).
- Donor `height > level` discard retained unchanged; the new gate only prevents animated-level leakage onto dry cells.

### 2.3 Near-zero-alpha `grass1` water-cell clamp (task item 3) — CROSS-OWNER, NOT EDITED

This is the **one item outside exclusive ownership** and is reported, not silently dropped:

- The grass-coloured shoreline originates in `world3d_terrain.gd:697-702`, which clamps out-of-atlas `BLK_WATER` (`game.gd:52,255`) to UV2 tile 0 = `grass1`. At the waterline the water plane's `alpha→0` reveals that `grass1` substrate (DTRN-03 C30 / W2; V3D_02 P6).
- `world3d_terrain.gd` and `game.gd` are owned by another builder and were **not touched**. I documented the dependency in a `water3d.gd` comment above `bind_height_grid()` and give the exact recipe here for the terrain owner: at UV2 build time map water cells to a donor shore id (`sandsea1/5/6` = preset ids 93/97/98 per DEC-05 §5.1, or a `sandrock*` id already in the port atlas) instead of tile 0, following the donor's oriented `sandsea1/5/6` water-cell painting (`texturemap.inc:463-472,503-511`). No new art; no foam image. This is required for T2's "full-width dark rows = 0" and "no water pixel showing `grass1` substrate" (DTRN-03 §6.1 S5 / §6.2 M5).

### 2.4 `shore_prox` inert port-art multiplier (task item 4)

| | Shader |
|---|---|
| **Before** | `watercolor += watershade * shore_prox * coastfade * (1−coastfade2) * (...)` with `shore_prox = 1 − smoothstep(water_level, shore_height, level)` — an extra multiplier absent from the donor fragment. |
| **After** | `shore_prox` **removed**; foam is now the donor equation verbatim (`water.dev.frag:227`): `watershade * coastfade * (1−coastfade2) * (vec3(.5,.6,.7)*nautic(uv) + vec3(particles(uv)))`. `shore_height` is retained as a declared-but-inert uniform (classification traceability only), and `stats["shore_prox"] = "REMOVED — … INERT (=1) … PORT ART …"`. |

- RV-TRN-03 §5.2 derived that with `waveheight=0`, `level ≤ −0.25`, so `shore_prox=1` for every fragment — removing it changes no pixels but eliminates the unlabelled multiplier. No foam was added; no foam texture exists (DEC-05/DTRN-03 §1.2 census).

## 3. Validation — headless parse/smoke only (no full gates/ladder)

| Item | Value |
|---|---|
| Runner | `python variant3d\tools\godot_runner.py run --id trnwater-smoke --timeout 180 -- --headless --path variant3d --script <temp>/trnwater_smoke.gd` |
| Ticket | **343** — `[runner] END ok`, run 5.63 s (wait 64.80 s) |
| Smoke covers | shader resource load/compile (`shader_loaded=true`); `water3d.gd` parse + `build(64,64)` + `bind_height_grid()`; donor-literal read-back; new audit fields; plane vertex Y == surface Y |
| stdout | `TRNWATER_SMOKE shader_loaded=true problems=0` / `TRNWATER_SMOKE RESULT: PASS` |
| stderr | **0 lines**; `smallmap_capture.py scan-stderr` → `script_error_lines: 0` → **SCRIPT ERROR == 0** |
| Gates/ladder | **not run**, per task. No windowed capture, no T0–T4 ladder, no selftest/uitest re-run. |

- The smoke script is TEMPORARY and lives at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\trnwater_smoke.gd` — outside the repo, not part of any owned file, not committed. It defers all work (no `quit()` in `_initialize()`) per `AGENT_PROTOCOL.md` §1.
- No transient `SCRIPT ERROR` from other builders appeared in this job's stderr, so there was nothing cross-owned to report or revert. Other in-flight edits visible in `git status` (e.g. `config.gd`, `input_controller.gd`, `menu.gd`, `selftest.json`, `manifest.json`, `world3d_terrain.gd.bak-TRNGEOM`) were left untouched.

## 4. Remaining UNVERIFIED / omitted paths (unchanged, still documented)

- **Exact donor water surface Y** (`gl_TexCoord[1].z`, `water.dev.vert:18`): engine-supplied; only inactive-debug hints (1.5 / 0.94). The port's −0.25 placeholder is a PORT APPROXIMATION; the swell-restoring A/B is likewise approximate. **UNVERIFIED**.
- **`hmapTex` literal binding, `hmapMin/Max = ±2.96`, `hmapW → map_size.x/128`, 8-bit height quantisation (~0.023 m/level)**: port substitutes, engine values UNVERIFIED. `heightmapwaves0.tga` remains **unbound** (alpha all 255, commented `water.mat:86-106` / `water.lib:45`; DEC-05 §4.3, RV-TRN-03 §2).
- **Reflection**: `reflection_enabled=0`, `SCREEN_UV + wavejitter` substitute for the projected `reflectionMap` FBO; FBO binding UNVERIFIED.
- **PCF shadow**: `watershade=1.0` (donor unshadowed branch); no shadow sampler. **UNVERIFIED**.
- **Fog modes 1 (LINEAR) omitted**; modes 2/3 kept; default off (`colors.lib:36 FogMode=0`). Mode-1 `gl_Fog.end/scale` path stays UNVERIFIED.
- **Visual parity**: no donor GPU A/B frame; all statements are structural / donor-equation-faithful, not pixel parity (V3D_02 parity guard).
- **Donor `.inc` shore classification literals' active runtime execution** remains UNVERIFIED (comment-prefixed GSC text).

## 5. No-forbidden-change declaration

I declare that in this task I:
- **did not add foam** or any foam image/texture (foam is procedural `nautic`/`particles`, donor `water.dev.frag:106-127,227`);
- **did not bind `heightmapwaves0.tga`** (alpha constant 255, commented bindings only) or `DiffuseWaves2` as height;
- **did not change any donor constant** (−0.25 / −0.1 / 2.96 / 0.57 / 1.07 / 170 / 120 / 30 / colours / 0.1 / 0.01 / HDR 1 all intact);
- **did not add** a second water plane, reflection FBO, PCF sampler, LINEAR-fog path, or synthetic art;
- **did not edit any file** other than the three owned paths in the frontmatter — specifically **no edit to `world3d_terrain.gd`, `game.gd`, any test, config, asset, runner or gate file**;
- **did not run** a full gate or the T0–T4 ladder, and **did not invoke `godot` directly** (runner only);
- **did not revert** any other builder's in-flight changes.

## 6. Open questions

1. **Surface-Y A/B exposure**: should the labelled A/B be a runtime/exported value for a future T2 swell A/B, or stay a compile-time placeholder? Left as a constant placeholder pending owner decision (UNVERIFIED plane Y).
2. **Item 3 owner**: which donor shore id should the terrain owner clamp `BLK_WATER` to (`sandsea1/5/6` vs `sandrock*`), and should it reuse `game.gd`'s `_shore_tile_for()` sector logic on the water side? Not decidable inside this module.
3. **Water-cell gate fidelity**: the gate uses `height < water_level` because the water module has no `mask.B` grid. If exact donor parity requires mask-based classification, the terrain/water integration owner must supply a mask channel; until then this is a labelled PORT GUARD.
4. **T2 visual metrics**: "full-width dark rows = 0", alpha-vs-depth, foam confinement and grass-under-water = 0 were **not measured** here (no windowed capture, per task scope). They must be measured by the T2 owner after item 3 lands; this report makes no visual PASS claim.

## 7. Summary

Decoupled the water plane's surface Y from the −0.25 tile-classification literal (exposing a labelled PORT APPROX placeholder and keeping `waveheight` donor-faithful at 0), confined water alpha to actual water cells with a donor-cited `water_cell` gate while keeping the exact 0.57/1.07 fade ramp and foam peak, removed the inert `shore_prox` port-art multiplier so foam is the verbatim donor equation, and documented the cross-owner `grass1`→shore-tile fix that must be applied in `world3d_terrain.gd`. All donor constants, the single water plane, and the omitted reflection/PCF/LINEAR-fog paths are unchanged. Headless smoke (runner ticket 343, `--id trnwater-smoke`) passed with `SCRIPT ERROR == 0`; no full gate/ladder was run and no visual parity is claimed.

*End of TRN-WATER implementation report. Exactly two owned source files changed; all other files read-only.*
