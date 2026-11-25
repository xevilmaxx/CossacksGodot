---
id: P08-QUALITY-KNOBS
ticket: TERRAIN-SWARM-WAVE-G / P08 (quality & config levers, read-only)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_CODE_EDITS__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P08_quality_knobs.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). Every cost/throughput statement below is an analytical estimate labelled UNVERIFIED. Nothing here is a benchmark, a frame-time measurement, or a donor-parity claim."
scope: "Read-only inventory of every cost-reducing knob named in the P08 ticket, with real cost effect, visual tradeoff, file:line, and config.json safety. One report written; no code, config, asset, test or doc outside this report was touched. No Godot process started (WAVE_G_CHARTER §31/§67: only G04 runs the runner)."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
inputs: [WAVE_G_CHARTER.md §Wave P, CHARTER.md §3/§5, reports/A12_config_knobs.md, reports/G17_perf_audit.md]
---

# P08 — quality/config levers that reduce cost without changing donor art

## 0. Headline finding (OBSERVED code + DERIVED consequence)

**Most of the knobs named in the ticket are inert in the active 3D renderer.** The shipped
`gameplay.render_mode` is `"3d"` (`variant3d/config.json:74`; read at `main.gd:185-186`), and
the 3D scripts implement only a subset of the display knobs. Verified by direct grep of all
`variant3d/scripts`:

| Knob | Real 3D cost lever? | Why |
|---|---|---|
| `display.quality` | **PARTIAL — yes** | `config.gd:491` → `data.gd:183-194` sets FX_CAP / FOG_INTERVAL / MINIMAP_INTERVAL (live in 3D) **and** changes mapgen density/coastline (live in 3D). |
| ├ `terrain_px` | **NO (inert in 3D)** | Legacy slot; `world3d.gd:795-808` `_bake_px()` is a no-op, `_build_masks()` returns `[]`. No consumer in `world3d_terrain.gd`. |
| ├ `sprite_cell` | **NO (inert in 3D)** | `world3d.gd:811-820` `_anim_dir()` is a path string only; comment at `:812` says 3D never loads from it; `assets/models/` has no `anim64`/`anim96` dirs (only `manifest.json`). |
| ├ `fx_cap` | **YES** | `world3d_fx.gd:1506-1514` `_enforce_cap()` pops/frees FX nodes; called at `:549`. |
| ├ `fog_interval` | **YES** | `world3d_fog.gd:102,116-125` gates `_update_fog()` cadence; `world3d.gd:695` calls `fog.sync(dt)`. |
| └ `minimap_interval` | **YES** | `hud.gd:1509-1512` gates `_update_minimap()` redraw. |
| `unit_scale` | **NO (inert in 3D)** | Only consumer `world.gd:600,3244,3268` (2D `world.gd`, not `world3d*.gd`); `anim3d.gd` has no reference. `world3d_fx.gd:1279` is a comment only. |
| `show_centroids` | **NO (inert in 3D)** | Only `world.gd:764,2887` (2D). No `world3d*.gd` consumer. |
| `units_opaque` | **NO (inert in 3D)** | Only `world.gd:292-304` (2D canvas shader). No 3D consumer. |
| `weather.snow` | **NO (inert)** | Getter at `config.gd:453-454`; a helper reads it at `world3d_fx.gd:380-399` but `set_weather_from_config()` is **never called** (grep: 1 match = its own definition). Default snow band stays off (`world3d_fx.gd:320,939-940,954-966`). A12 §2 #10's "no consumer" is *almost* right: the getter is referenced by an uncalled helper. |
| `render.fog` | **NO (inert)** | Getter `config.gd:469-470`; no consumer. Terrain shader binds `fog_mode=0.0` unconditionally (`world3d_terrain.gd:743`). |
| `gameplay.fog_of_war` (`features.*`) | **NO (inert)** | Getter `config.gd:472-473`; `apply()` reads only legacy `display.fog_of_war` (`:488`). |
| `water.alpha_confine` / `water.shore_prox` | **NO (audit-only)** | `water3d.gd:159-167,273-278` put them in `stats` only; no shader uniform. `t_terrain_shore.gd:926-935` asserts `shore_prox` is absent. |
| map size | **YES, with semantics cost** | `config.gd:513-514` → `Data.MAP_W/MAP_H`; cell count scales as W×H (DERIVED). Changes map content, not just cost. |
| `camera.start_zoom` | **YES for the first frame only** | `main.gd:183,608`; `camera3d.gd:239-241` maps zoom to height. No steady-state effect after user input. |

**Consequence for the owner's complaint** (INFERRED, UNVERIFIED): none of these config keys
can touch G17's two real suspects — the +171 MiB mip chain and the synchronous main-thread
mip build (`G17_perf_audit.md §3`). Those need code changes outside P08's scope. The overlay
in §3 is a cheap A/B lever on the *live* 3D costs only; it is not a fix for the loading stall.

---

## 1. Inventory — one row per named knob

All cost labels are **UNVERIFIED** (no run, no capture, no profiler). `OBSERVED` = direct file
read; `DERIVED` = arithmetic/control-flow consequence; `INFERRED` = plausible but unproven.

### 1.1 `display.quality` (master preset)

| Field | Value |
|---|---|
| Evidence | `config.gd:491` calls `Data.set_quality(text("display.quality","high"))`; `data.gd:183-194` preset table; `data.gd:168-175` `MAPGEN` density table; `game.gd:458,1126,1162`; `mapgen.gd:219-224`. |
| Preset values (OBSERVED, `data.gd:186-194`) | **low**: `TERRAIN_PX=8, SPRITE_CELL=64, FX_CAP=60, FOG_INTERVAL=1.5, MINIMAP_INTERVAL=1.0`. **medium**: `12/96/120/0.8/0.5`. **high**: `16/160/220/0.5/0.25`. |
| Real cost effect | The three live 3D caps change (see §1.2). Additionally `mapgen_budget()` lowers relief-dome count (4→2), disables `decor`/`stamps`, lowers `lake_detail` (2→0) at low (`data.gd:168-175`; `game.gd:1162`), and coastal smoothing passes fall 3→1 (`mapgen.gd:219-224`). **UNVERIFIED** magnitude; generation is startup cost, not per-frame. |
| Visual tradeoff | **Not art-neutral**: fewer relief domes, crisper shoreline, less decor → *different generated map*, not merely fewer pixels. Per-frame: effects truncate sooner; fog/minimap update more slowly. |
| config.json safety | Reversible (restore key). **No test asserts the quality default**, so writing it does not break a gate. But for a weak-GPU A/B it is **better to keep `"quality": "high"` and override only the three live caps** — see §3. Do not use `low` if map shape must stay donor-shaped. |

### 1.2 Derived caps

| Knob | Evidence | Real cost effect (UNVERIFIED) | Visual tradeoff | config.json safe/reversible? |
|---|---|---|---|---|
| `display.terrain_px` | `config.gd:492` (`clampi 1..64`) → `Data.TERRAIN_PX`; `world3d.gd:159,795-808`; `main.gd:1542` | **None in 3D**: `_bake_px()` is a no-op and `_build_masks()` returns `[]`; no `world3d_terrain.gd` consumer. In 2D `app/` it drives sprite bake (out of scope, untouched). | None in 3D. | Yes technically, but **pointless** — do not include in overlay. |
| `display.sprite_cell` | `config.gd:493` → `Data.SPRITE_CELL`; `world3d.gd:811-820` `_anim_dir()`; `assets/models/` has only `manifest.json` | **None in 3D**: the knob only selects a legacy path string that the 3D branch never loads (`world3d.gd:812`). No `anim64`/`anim96` on disk. | None in 3D. | Yes technically, but **pointless** — do not include. |
| `display.fx_cap` | `config.gd:494` → `Data.FX_CAP`; `world3d_fx.gd:1506-1514`, call at `:549` | **Live.** While `fx_items.size() > cap`, oldest item is popped and its node/mat/light freed. Lower cap = fewer live FX nodes/materials/lights and fewer draw calls. INFERRED; magnitude UNVERIFIED. | Oldest effects (smoke, impacts, volleys) evicted sooner; heavy fire truncates. | **YES.** `t_smoke_fx.gd:198-205` only requires `cap > 0` and adherence — any positive value stays green. Prefer overlay over shipped default. |
| `display.fog_interval` | `config.gd:495` → `Data.FOG_INTERVAL`; `world3d_fog.gd:102,116-125`; `world3d.gd:695` | **Live.** `sync(dt)` returns until the accumulator expires, then `_update_fog()` runs. Larger interval = fewer FOV recounts. INFERRED; UNVERIFIED. `main.gd:237-238` proves the lever by setting `9999.0` in bench mode. | Visibility/fog overlay lags by up to the interval (1.5 s vs 0.5 s). | **YES.** No test asserts a specific interval. |
| `display.minimap_interval` | `config.gd:496` → `Data.MINIMAP_INTERVAL`; `hud.gd:1509-1516` | **Live.** Gates `_update_minimap()` redraw; `main.gd:237` bench-disables with `9999.0`. The viewport box still follows the camera every frame but is change-gated O(1) (`hud.gd:1513-1516`). INFERRED; UNVERIFIED. | Unit dots/resource marks lag up to the interval. | **YES.** No test asserts a specific interval. |

### 1.3 Unit/HUD display knobs

| Knob | Evidence | Real cost effect (UNVERIFIED) | Visual tradeoff | config.json safe/reversible? |
|---|---|---|---|---|
| `display.unit_scale` | `config.gd:497` (`clampf 0.25..4.0`) → `Data.UNIT_SCALE`; `data.gd:159` = 1.25; consumers `world.gd:600,3244,3268` | **None in 3D** (no `world3d*.gd`/`anim3d.gd` consumer). In 2D it scales sprite quads → larger scale means more overdraw, INFERRED/UNVERIFIED. | None in 3D. | **NO for config.json**: `visual_tuning_test.gd:49-58` asserts the shipped file's `unit_scale=1.25` via `defaults.load_all()`. Changing it breaks `config.defaults` (test weakening forbidden). In a `--config` overlay: safe but useless in 3D. |
| `display.show_centroids` | `config.gd:498` → `Data.SHOW_CENTROIDS`; `data.gd:160` = false; consumers `world.gd:764,2887` (2D; `:764` also gated by `QUALITY != "low"`) | **None in 3D.** In 2D, true draws extra `draw_circle` anchor disks → extra draw calls, UNVERIFIED. | None in 3D. | **NO for config.json**: `visual_tuning_test.gd:53,57` asserts shipped `false`. Overlay safe but useless. |
| `display.units_opaque` | `config.gd:499` → `Data.UNITS_OPAQUE`; `data.gd:161` = true; consumer `world.gd:292-304` (2D canvas shader: alpha `smoothstep` discard + colour lift) | **None in 3D.** In 2D the shader changes fragment work on unit sprites, INFERRED/UNVERIFIED. | None in 3D. | **NO for config.json**: `visual_tuning_test.gd:54,58` asserts shipped `true`. Overlay safe but useless. |

### 1.4 `features.*` audit-only / dead flags

| Knob | Evidence | Real cost effect | Visual tradeoff | config.json safe/reversible? |
|---|---|---|---|---|
| `features.weather.snow` | `config.gd:453-454`; `config.json:33` false; `world3d_fx.gd:380-399` (uncalled), `:175-176` `SNOW_COUNTS`, `:320,939-940,954-966` | **None as shipped** — snow emitters stay off; the only reader is `set_weather_from_config()`, which has **no callers**. If a future ticket wires it: 4 emitters × counts `[100,100,100,200]` particles (INFERRED, UNVERIFIED). | None today. | Yes (inert). **Do not credit it with FPS savings.** |
| `features.render.fog` | `config.gd:469-470`; `config.json:44` false; shader `fog_mode=0.0` at `world3d_terrain.gd:743` | **None** — no consumer. Terrain fog is not the per-frame overlay; that one is `world3d_fog.gd` driven by `Data.FOG_INTERVAL`. | None. | Yes (inert). |
| `features.gameplay.fog_of_war` | `config.gd:472-473`; `config.json:47` false; `apply()` uses only `display.fog_of_war` at `:488` | **None** — dead getter. | None. | Yes (inert). |
| `features.water.alpha_confine` | `config.gd:447-448`; `water3d.gd:159-167,273-278` | **None** — stats-only (`water_alpha_confine_config`), no shader uniform. | None. | Yes (inert). |
| `features.water.shore_prox` | `config.gd:450-451`; `water3d.gd:273-278`; `t_terrain_shore.gd:926-935` | **None** — stats-only; the port-art multiplier was removed; re-enabling needs shader work and would break `no_port_art_shore_prox`. | None. | Yes but **do not re-enable** — gate failure. |
| `features.selection.*` (5) | `config.gd:425-439`; `input_controller.gd:98-99,217-224` | Input thresholds/colour only; no render-cost effect. | Marquee colour/width, drag epsilon, double-click. | Yes, but out of scope for FPS. |

### 1.5 Map size and camera start zoom

| Knob | Evidence | Real cost effect (UNVERIFIED) | Visual tradeoff | config.json safe/reversible? |
|---|---|---|---|---|
| `gameplay.map_width_tiles` / `map_height_tiles` | `config.gd:513-514` (`maxi(16, ...)`) → `Data.MAP_W/MAP_H`; `config.json:75-76` = 240; `data.gd:119-121` says 240 is the smallest donor-backed skirmish size; `game.gd:459,1139-1140` | **Live and large (DERIVED):** cells scale as W×H — 64² = 4,096 vs 240² = 57,600 = **14× fewer** height/tile cells; fewer pattern stamps, entities and sim-grid traversals (INFERRED). Magnitude UNVERIFIED. | **Not art-neutral**: smaller playfield, fewer resources/starts, different map content; 64² capture fixtures are explicitly not donor-backed. | Reversible in config.json, but **changes gameplay semantics and visual baselines**. Exclude from the minimal overlay; at most a separate, clearly-labelled A/B arm. |
| `camera.start_zoom` | `main.gd:183` (`cfg.num(...,0.75)`), `:608` (`set_zoom_target(start_zoom,true)`); `config.json:70` = 0.3448276; `camera3d.gd:210-212,239-241` (`height = sqrt(20·58/z)`) | **First frame only:** z=0.3448276 → height 58 m (most zoomed-out donor-legal start); z=1.0 → ~34 m; z=2.9 → 20 m. A closer start culls more terrain/entities initially (INFERRED, UNVERIFIED); **no steady-state effect** after user zoom. | Changes donor framing; `config.json:14` says smaller is not donor-grounded (larger is also off-donor). | Reversible, but **pin it across A/B arms** (A12 §5) — it is a capture confound, not a sustained-FPS lever. |

---

## 2. Cost-effective ranking for a weak GPU (all INFERRED / UNVERIFIED)

1. `display.fx_cap` 220 → 60 — direct node/draw-call cap, live in 3D, gate-safe.
2. `display.fog_interval` 0.5 → 1.5 — fewer fog overlay recounts, gate-safe.
3. `display.minimap_interval` 0.25 → 1.0 — fewer HUD minimap redraws, gate-safe.
4. `gameplay.map_*_tiles` 240 → smaller — biggest single sim/geometry reduction, but **not art-neutral**; separate arm only.
5. `camera.start_zoom` — minor, first-frame-only, off-donor; pin, don't vary.
6. Everything in §1.2 (`terrain_px`, `sprite_cell`) and §1.3/§1.4 — **zero 3D benefit**; do not ship.

The real FPS suspects from G17 (atlas VRAM, synchronous mip build) are **not reachable by any
config key**; a code ticket is required (G17 §5 item 1, §8).

---

## 3. Proposed minimal weak-GPU overlay for COORD (read-only proposal)

File suggestion: `variant3d/config_weak_gpu.json` (NEW file — **P08 did not create it**).
Invoke as a third merge layer (`main.gd:180` → `config.gd:275-304`):

```
python variant3d\tools\godot_runner.py run --id <UNIQUE> -- --headless --path variant3d \
  --config config_weak_gpu.json --dump-config
```

Overlay contents — only the three keys with a proven 3D consumer:

```json
{
  "_purpose": "Wave P08 weak-GPU A/B arm; third-layer --config only; art/mapgen unchanged.",
  "display": {
    "fx_cap": 60,
    "fog_interval": 1.5,
    "minimap_interval": 1.0
  }
}
```

Design decisions (DERIVED from `config.gd:491-499`):

- **`display.quality` deliberately omitted** → stays `"high"`, so `mapgen_budget()` and coastal
  passes keep donor-shaped density (`data.gd:168-175`, `mapgen.gd:219-224`). If COORD instead
  writes `"quality": "low"`, FX_CAP/FOG/MINIMAP land on the same numbers, **but** relief domes,
  decor and coastline change — that is an art change, so it is a *different* arm, not this one.
- **`terrain_px` / `sprite_cell` omitted** — inert in 3D (§1.2).
- **`unit_scale` / `show_centroids` / `units_opaque` omitted** — inert in 3D **and** gate-sensitive
  if written into the shipped file (§1.3). They are safe only in the overlay, where they do nothing.
- **Seed, map size, camera/start_zoom, render_mode, season pinned** to the control arm; keep
  `user://options.json` free of conflicting keys (it is merged last and wins — `config.gd:297-303`).
- Record each arm's effective settings with `--dump-config` (`main.gd:197-200`).
- Revert by deleting the overlay / dropping `--config`; **no source file is touched**.

Optional second arm (NOT art-neutral, label explicitly): same three keys plus
`"gameplay": {"map_width_tiles": 120, "map_height_tiles": 120}` — ¼ the cells (DERIVED),
changes playfield content; or plus `"quality": "medium"` — changes domes/coastline. Do not mix
both into the minimal overlay.

---

## 4. Gates that must stay green (explicit)

From `CHARTER.md §5.3` and `G04_gate_log.md:95-97,140-141` — COORD/G04 owns the runner, P08 ran none:

| # | Gate | Exact condition | Why this overlay must not break it |
|---:|---|---|---|
| 1 | Variant selftest | `--self-test variant3d/selftest.json` → 29/29 `passed=true` | Overlay changes no sim rules, only FX count and update cadences. |
| 2 | UITest | `--ui-test variant3d/uitest.json` → 17/17 | Minimap redraw cadence changes; widget layout must still pass. |
| 3 | `t_render_mode` | `--script res://tests/t_render_mode.gd` → `result=PASS`, `seam_missing=false` | `render_mode` not touched (stays `3d`). |
| 4 | `assert_clean` | CLEAN | No code/config/test file edited by P08. |
| 5 | Windowed P0 capture | 1280×720, non-blank, no new streaks/grid/blotches (`CHARTER §5.1`) | `fx_cap` must not remove art needed for the frame; A/B at identical seed/camera. |
| 6 | Windowed real-map capture | same visual acceptance + no new seams/z-fighting/black rows (`CHARTER §5.2`) | Keeping `quality=high` preserves mapgen shape. |
| 7 | `t_smoke_fx` | `fx_cap_respected`: `cap > 0` and `fx_items.size() <= cap` (`t_smoke_fx.gd:198-205`) | 60 is positive; cap logic unchanged. |
| 8 | `visual_tuning_test` | `config.defaults`: shipped `unit_scale=1.25`, `show_centroids=false`, `units_opaque=true` (`visual_tuning_test.gd:49-58`) | **Only relevant if someone edits `config.json`**; the overlay must not touch these keys. |
| 9 | Mapgen/visual golden gates | e.g. `t_combo_all`, `t_terrain_trees`, `t_season_overlay`, `t_terrain_shore` `no_port_art_shore_prox` | Keeping `quality=high` and not re-enabling `shore_prox` avoids these. |
| 10 | 2D `app/` untouched | `CHARTER §5.3` | P08 wrote only this report. |

Re-run gates in the G04 order (selftest → uitest → t_render_mode → P0 → real map) with one
variable per arm; no new test weakening, no threshold edits.

---

## 5. Open questions / UNVERIFIED register

1. **All cost figures in this report are UNVERIFIED** — no frame time, no FPS capture, no
   profiler and no donor GPU A/B was produced by P08 (standing rule: only G04 runs Godot).
2. Whether `fx_cap=60` is visibly too aggressive during the first battle — UNVERIFIED without a
   windowed capture; if it is, 120 (medium preset) is the intermediate arm.
3. Whether `fog_interval=1.5` / `minimap_interval=1.0` produce a perceptible responsiveness
   regression on the MX130 windowed run — UNVERIFIED; `main.gd:237-238` shows the harness already
   disables both entirely for benchmarks, so the direction of the cost effect is OBSERVED, but
   the player-visible tradeoff is not.
4. Exact MX130 VRAM/resident set and the mip-build wall time — UNVERIFIED (G17 §7 #1-3); no
   config knob addresses either.
5. Whether `sprite_cell`/`terrain_px` ever affect 3D through an untraced path — no consumer was
   found in `variant3d/scripts`; if a future ticket adds one, re-open §1.2.
6. `set_weather_from_config()` has no callers today; if a weather ticket wires it,
   `features.weather.snow=true` becomes a real FX cost lever — re-open §1.4 then.

---

## 6. Summary for COORD

- Of the ticket's knobs, only **`fx_cap`, `fog_interval`, `minimap_interval`** (the three live
  derived caps) are real, gate-safe 3D cost levers; **`display.quality`** additionally changes
  mapgen shape, so keep it at `high` for an art-neutral A/B.
- **`terrain_px`, `sprite_cell`, `unit_scale`, `show_centroids`, `units_opaque`,
  `weather.snow`, `render.fog`, `gameplay.fog_of_war`, `water.alpha_confine`, `water.shore_prox`**
  have **no effect in the active 3D renderer** — do not spend A/B arms on them. Writing the three
  unit/HUD defaults into `config.json` would actually **break** `visual_tuning_test`.
- **Map size** is a real but art/gameplay-changing lever; **`start_zoom`** is first-frame-only and
  a capture confound — pin, don't vary.
- Minimal overlay: three display keys only (§3); all performance estimates **UNVERIFIED**;
  no Godot run, no code edits, no donor-parity claim.

*End of P08 report.*
