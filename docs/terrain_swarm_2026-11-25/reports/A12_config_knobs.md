---
id: A12-CONFIG-KNOBS
title: "A12 — inventory of existing no-code-edit config knobs for terrain / selection / ghost A/B testing"
ticket: A12 (TERRAIN-SWARM-2026-11-25)
owner: A12 read-only analysis subagent
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDITS__NO_GODOT_JOBS
scope: "Read-only analysis. Exactly one file written: this report. No code, config, test, asset or doc outside this report was edited; no Godot/runner job was submitted."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
---

# A12 — configuration knobs for terrain / selection / ghost A/B testing

## 0. Boundary and answer in brief

**Observed.** A12 is a diagnosis-wave read-only ticket: every statement below comes from a
direct file read of the current working tree (`variant3d/scripts/config.gd`,
`variant3d/config.json`, `variant3d/scripts/{main,input_controller,camera3d,water3d,
world3d_terrain,world3d_fx,world3d_entities}.gd`, `variant3d/shaders/terrain_tileindex.
gdshader`) and the linked coord reports (`CONFIG_CORE_01`, `CONFIG_PLAN_01`,
`CONFIG_WIRE_{SEL,CAM,HUD,WATER,RELIEF}`, `B_SHADER_AB`, `Z3_VISUAL_BLEED`). **Derived** =
arithmetic/control-flow consequence of those reads; **inferred** = plausible but unproven;
**UNVERIFIED** = no accessible evidence. No donor GPU A/B exists, so no donor-parity claim
is made anywhere.

**Bottom line (derived):** today there are **16 `features.*` typed getters**, of which
**13 have a consumer** (2 of those — water `alpha_confine`/`shore_prox` — are audit-only)
and **3 are dead** (weather/snow, render/fog, gameplay/fog_of_war — see §2). **None of them can
directly A/B `uv_repeat`, `mask_to_alpha`, terrain `shadow_enabled`, the ghost final-stage
mesh, or water level/fade/glints.** The only two suspect knobs with live config-driven
effect are **`features.water.surface_y`** (real render effect, reversible) and
**`features.terrain.relief_stamps`** (real geometry effect via a dump marker, reversible).
Selection knobs (5) are fully live. **Season A/B is reachable without code edits** via
existing `gameplay.season` / `gameplay.biome` + `world3d_terrain.gd:season` public field
and the `world.season` setter. A **minimal additive set of 8 feature keys** (§5) would give
COORD a clean A/B matrix with one uniform binding line per knob and no shader edits.

`--config <file.json>` is a **third merge layer** (`main.gd:1338-1339` →
`config.gd:load_all()` `:275-304`) — this is the intended no-edit A/B mechanism: put the
override keys in a separate JSON and pass `--config`; delete/restore the file to revert.
`user://options.json` is merged **after** it (`:297-303`) and silently wins, so keep it
empty of conflicting keys during A/B.

---

## 1. Config load / override chain (observed, `config.gd:275-304`, `main.gd:175-200`)

| Layer | Source | Precedence | A/B relevance |
|---|---|---|---|
| 1 | `C3Config.DEFAULT` (incl. `FEATURES_DEFAULTS`, `config.gd:46-86,90-266`) | lowest | built-in fallback |
| 2 | first readable file from `_candidate_paths("")`: `res://config.json`, globalized res path, `user://config.json` (`config.gd:319-321`) | middle | shipped values |
| 3 | `--config <file.json>` passed by `main.gd:180`, merged over layer 2 (`config.gd:284-294`) | high | **the A/B layer** — no edits to shipped `config.json` |
| 4 | `user://options.json` merged last (`config.gd:297-303`) | highest | UI writes; may override layer 3, must be kept clean |

`--dump-config` (`main.gd:197-199`) prints the fully merged `data` (including all
`features.*`) then exits — use it to record each A/B arm's effective settings.

**Number coercion caveat (observed, `config.gd:356-376`; CONFIG_CORE_01 §6 Q3):** a whole
JSON float becomes `int` in `data`; the typed getter casts with `num()`/`int()` so the
consumer still sees a float. `features.camera.fov_deg: 17.0` reads as `17.0`, not `17`.

---

## 2. Master table — every existing feature knob (observed)

Line references are **current on-disk**. "Safe" means changing the key in a `--config`
overlay (or `config.json`) is reversible at runtime by restoring the original overlay and
re-launching; **all reads happen at bind/build time, never per frame**, so there is no
hot-reload today — a change requires a new game launch (derived from the consumer sites).

| # | Key `features.*` | Getter (`config.gd`) | Current value (`config.json:16-49` / default) | Consumer file:line | Effect | Safe & reversible? |
|---:|---|---|---|---|---|---|
| 1 | `selection.world_epsilon_m` | `feature_selection_world_epsilon_m()` `:425-426` | 0.005 (`config.json:18`; default `:48`) | `input_controller.gd:218` (`_selection_epsilon_m()`) | Drag epsilon for world pick; lower = donor-strict | **YES** — pure input threshold; restore value; 23/23 real-drag gate proves default (CONFIG_WIRE_SEL §6) |
| 2 | `selection.attack_epsilon_m` | `feature_selection_attack_epsilon_m()` `:428-429` | 0.25 (`config.json:19`) | `input_controller.gd:217` | Epsilon in attack-ground / guard mode | **YES** — same as above |
| 3 | `selection.marquee_color` | `feature_selection_marquee_color()` `:431-433` | `[1,1,0,1]` (`config.json:20`) | `input_controller.gd:98-99` (`SelectionRectPainter._draw()`) | Marquee outline colour (donor yellow) | **YES, with validation** — Array indices `[0..3]` are read as floats; a short array errors at draw time (CONFIG_WIRE_SEL §8 Q3) |
| 4 | `selection.marquee_width_px` | `feature_selection_marquee_width_px()` `:435-436` | 1 (`config.json:21`) | `input_controller.gd:99` | Marquee line width | **YES** — cosmetic only |
| 5 | `selection.double_click_s` | `feature_selection_double_click_s()` `:438-439` | 0.5 (`config.json:22`) | `input_controller.gd:224`, call `:755` | Double-click window | **YES** — input timing only |
| 6 | `terrain.relief_stamps` | `feature_terrain_relief_stamps()` `:441-442` | **true in `config.json:25`**; default **false** (`config.gd:62`) | `main.gd:789-790` → `dump["relief_stamps"]` gate at `:762-767`; consumed by `world3d_terrain.gd:522-557,1193` | When true, emits the RELIEF-02 donor `plt2` marker; consumer adds coarse 8×10 additive-clamped height stamps = **real terrain geometry change** | **YES for A/B, but note the shipped override is ON**: default false = no marker, byte-identical to pre-RELIEF-02 baseline. No `k_ravine_1` marker exists (BLOCKED). Revert by deleting the key → false. |
| 7 | `water.surface_y` | `feature_water_surface_y()` `:444-445` | -0.25 (`config.json:28`; default `:65`) | `water3d.gd:165` → `WATER_SURFACE_Y` (var at `:36`), uniform `:179`, plane vertices `:218-221`, audit `:266,270` | Water plane Y / wave-height driver. Value `>0.8333` restores the donor swell term | **YES** — uniformly flows into uniform *and* vertices; PORT APPROX / donor Y UNVERIFIED (CONFIG_WIRE_WATER §7 Q3). Revert to -0.25 |
| 8 | `water.alpha_confine` | `feature_water_alpha_confine()` `:447-448` | true (`config.json:29`) | `water3d.gd:166` → `stats["water_alpha_confine_config"]` `:277` | **AUDIT ONLY** — the shader `water_cell` multiply has no uniform; cannot disable the gate without a shader edit (CONFIG_WIRE_WATER §7 Q1) | Reversible but **no visual effect today** — do not use for A/B |
| 9 | `water.shore_prox` | `feature_water_shore_prox()` `:450-451` | false (`config.json:30`) | `water3d.gd:167` → `stats["shore_prox_config"]` `:278` | **AUDIT ONLY** — re-enabling the removed port-art multiplier needs shader work (CONFIG_WIRE_WATER §7 Q2) | Reversible but **no visual effect today** |
| 10 | `weather.snow` | `feature_weather_snow()` `:453-454` | false (`config.json:33`; default `:70`) | **NO consumer** (grep: only definition in `config.gd`) | Intended snow on/off gate; no driver calls `set_weather()` from config | **INERT** — safe but does nothing |
| 11 | `camera.fov_deg` | `feature_camera_fov_deg()` `:456-458` | 17.27 (`config.json:36`; default `:73`) | `camera3d.gd:195` (in `bind()`'s existing config block) | Camera FOV (PORT APPROX / UNVERIFIED; 2.90° is the only other coherent candidate — RV-CAM-01) | **YES** — read once at bind; no auto-refresh (CONFIG_WIRE_CAM §8 Q3); revert to 17.27 |
| 12 | `hud.minimap_size` | `feature_hud_minimap_size()` `:460-461` | 240 (`config.json:39`) | `hud.gd:322,1415` (helpers `_mm_size()` `:276-280`) | Minimap widget size; still passes through `_ms()` UI scale and 25%-viewport cap (CONFIG_WIRE_HUD §7 Q2) | **YES** — cosmetic; revert to 240 |
| 13 | `hud.minimap_inset` | `feature_hud_minimap_inset()` `:463-464` | -8 (`config.json:40`) | `hud.gd:335,1444-1448` | Minimap edge offset | **YES** — revert to -8 |
| 14 | `hud.minimap_corner` | `feature_hud_minimap_corner()` `:466-467` | `"bottom_right"` (`config.json:41`) | `hud.gd:1434-1440` (anchors) | Anchors only; **only bottom-right offsets are implemented**; other strings move anchors without re-partitioning (CONFIG_WIRE_HUD §7 Q1) | **YES but avoid non-default strings** — unvalidateable; unknown falls back bottom-right (CONFIG_CORE_01 §6 Q4) |
| 15 | `render.fog` | `feature_render_fog()` `:469-470` | false (`config.json:44`; default `:81`) | **NO consumer** | Intended shader fog gate; shader binds `fog_mode=0.0` unconditionally (`world3d_terrain.gd:711`) | **INERT** |
| 16 | `gameplay.fog_of_war` | `feature_gameplay_fog_of_war()` `:472-473` | false (`config.json:47`; default `:84`) | **NO consumer** (apply() still reads only `display.fog_of_war`, `config.gd:488`) | Intended visibility fog gate | **INERT** |

**Removed dead keys (observed, `config.gd:55-61`; P1-3 / B-D-DEAD-FLAGS):** `terrain.texgen_mode`,
`terrain.m_per_tile`, `terrain.lighting`, `terrain.alpha_patch_mode`, `terrain.tile_diversity`
were deleted from both `FEATURES_DEFAULTS` and the getter block. Writing them into a config
overlay creates **unread keys** — no effect. `CONFIG_CORE_01.md:43-48` still lists the old 21-key
schema; the current tree has 16 getters (16 live defaults), not 21.

### 2.1 Legacy, non-`features` knobs with real terrain/world effect (observed)

These are consumed directly by `config.gd:apply()` or `main.gd` and can be overridden in the
same `--config` file without editing code:

| Key | Where applied | Effect | Safe? |
|---|---|---|---|
| `gameplay.season` / `gameplay.biome` | `config.gd:536` → `Data.BIOME`; `world3d_terrain.gd:407-414` `_effective_season()`; also `main.gd:321` from menu cfg | **Season A/B**: `summer` (enum 0), `winter` (enum 2, winter atlas/manifest on disk), `desert` (enum 3, remap); value 1 UNVERIFIED and has no entry → falls back summer | **YES** — index-preserving set swap, no shader change (SP-6). `world3d_terrain.gd:season` public field also settable at runtime via the world node's setter |
| `gameplay.terrain_type` / `map_type` / `relief` / `relief_type` / `map_shape` | `config.gd:535,538,577-600` (+ `_donor_id()` validation `:696-701`) | Shape/relief family: changes generated tile data and height grid | YES for same-family A/B; unknown ids fall back to donor defaults with a `problems` entry |
| `gameplay.random_seed` | `config.gd:515`; `main.gd:187-190` CLI `--seed` wins | Identical-map pairing is **mandatory** for any A/B (B_SHADER_AB §5 step 2) | YES |
| `gameplay.map_width_tiles` / `map_height_tiles` | `config.gd:513-514`; min 16 | 64² fixture vs 240² real map | YES |
| `display.quality` (+ `terrain_px`/`sprite_cell`/`fx_cap`/`fog_interval`/`minimap_interval`) | `config.gd:491-496`; `data.gd:set_quality()` | Render cost / splat resolution, not shader art | YES; `terrain_px` clamped 1..64 |
| `camera.start_zoom` | `main.gd:183` (absent from `C3Config.DEFAULT`; read as `cfg.num` fallback 0.75) | Camera distance at bind = huge A/B confound; shipped 0.3448276 (`config.json:70`) | YES — but **pin it across arms** |
| `display.unit_scale` / `show_centroids` / `units_opaque` | `config.gd:497-499` | Unit visuals (distractors in terrain frames) | YES |
| `gameplay.render_mode` | `main.gd:185-186` | 3d vs 2d (3d here) | YES, but switching invalidates a 3D A/B |
| `display.fog_of_war` | `config.gd:488` → `Data.FOG_OF_WAR` | Legacy visibility flag, distinct from inert `features.gameplay.fog_of_war` | YES |

---

## 3. Direct answers: which knobs can test the charter's five suspects?

| Suspect (CHARTER §2) | Directly testable today? | Exact lever / gap |
|---|---|---|
| **uv_repeat** (hard 2 m repetition, diagonal streaks) | **NO** | Shader uniform exists at `terrain_tileindex.gdshader:214` `uniform vec2 uv_repeat = vec2(0.5, 0.5)`; use sites `:316` (`v_alpha_uv`) and `:392` (`tile_rgb(v_tile, fract(v_st * uv_repeat))`). **`world3d_terrain.gd:_tileindex_material()` `:682-721` never binds it** — grep of all `set_shader_parameter` lines `:689-711` confirms no `uv_repeat`. Shader defaults cannot be changed via JSON. Additive key + one binding line required (§5 K1). |
| **mask_to_alpha** (repeated dark blotches from patch fold) | **NO config key, but a fully published uniform A/B** | `terrain_tileindex.gdshader:235` `uniform float mask_to_alpha = 1.0`, effect at `:427` `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular`; contract `B_SHADER_AB.md:33-49` and shader comment block `:478-502`: `1.0` = shipped, `0.0` = flat opaque. `world3d_terrain.gd:718-719` explicitly leaves it at default ("no binding"). Requires the same one-line binding as uv_repeat (§5 K2). No donor GPU A/B exists (B_SHADER_AB §5). |
| **shadow** (shadow_enabled=0, no shadow map) | **NO** | Shader uniforms `shadow_enabled` (`:180`), `shadow_matrix` (`:183`), `shadow_offset` (`:186`), `shadow_taps` (`:187`), `shadow_color` (`:191`); PCF block `:429-452`. `world3d_terrain.gd:709` hard-binds `shadow_enabled = 0.0`; `sun.shadow_enabled = false` at `:1160`. No config key. Turning it on without a real shadow map/texture yields no meaningful A/B — keep OFF and record as a deliberate prior decision (Z3_VISUAL_BLEED §2.3); the minimal knob is a boolean default 0.0 (§5 K3). |
| **water** | **PARTIAL — one key** | `features.water.surface_y` is the **only** live visual water knob (§2 #7). Level `-0.25`, shore `-0.1`, `MAX_HEIGHT=2.96`, `COAST_FADE=0.57`, `DEEP_FADE=1.07`, spec powers 170/120, particles 30 are all `const` at `water3d.gd:24-45` and not config-driven. `alpha_confine`/`shore_prox` are audit-only. CONFIG_PLAN_01 §1.3 rows 41-44 proposed a full `features.render.water.*` set — **not shipped**. Minimal additive set in §5 K4-K5. |
| **season** | **YES — no code edit needed** | `gameplay.season`/`biome` in `--config` overlay → `config.gd:536` → `Data.BIOME` → `world3d_terrain.gd:407-414,581-585` selects V785 summer / SP-4 winter manifest+atlas / SP-3 desert remap. Enum values 0/2/3 (`data.gd:227 SEASON_ENUM`); winter art exists on disk. Donor runtime activity UNVERIFIED — label every comparison PORT APPROX. |

### 3.1 Selection quad and building ghost (charter §1b items 2-3)

- **Selection quad:** five selection knobs are live (§2 #1-5) and wired through the null-safe
  `C3ConfigScript.active` seam (`CONFIG_WIRE_SEL.md:41-55`). They can A/B drag tolerance,
  marquee colour/width and double-click timing **without code edits**. The quad's geometry,
  lifetime and hit semantics (Shift union `spmAdd`, no Ctrl-remove, `Rect2(p0,p1).abs()`,
  `rect.has_point(e.pos)`) are **hard-coded** in `input_controller.gd:692-757,772-788` and are
  NOT config-driven — an end-to-end quad audit (D-wave) cannot be done with config alone.
- **Building ghost stage:** `world3d_fx.gd:_ghost_resolve_mesh()` `:634-678` hard-calls
  `_stage_mesh_info(sid, "1", false)` at `:645` — **stage 0 / foundation, suffix "1"**
  (B-GHOST-FIX comment `:271-276`; donor floor(progress*4) rule at
  `world3d_entities.gd:1805-1811`). The "last / completed stage" the owner wants is
  **not reachable via any existing key**; `world3d_fx.gd` has no config preload and no
  `feature_*` call (E-wave code change required). A minimal config key is given in §5 K8.
  Green/red validity colour comes from `_ghost_ok` (`world3d_fx.gd:583`), not config.

---

## 4. Why a runtime-only A/B matrix is not possible today (derived)

- All getters are read at **bind/build time**: camera `bind()` (`camera3d.gd:195`), input
  painter/helpers (`input_controller.gd:98-99,217-224`), water `build()`
  (`water3d.gd:165-167`), HUD `_apply_scale()`/minimap build, `main.gd:_dump_map()`
  (`main.gd:789`). No `set_*` API, no per-frame getter poll, no config reload path exists
  (CONFIG_WIRE_SEL §8 Q4, CONFIG_WIRE_CAM §8 Q3). "Runtime change" therefore means
  **edit an overlay JSON + relaunch**, not hot-swap.
- Shader uniforms have **no config bridge**: the only consumer binding site is
  `_tileindex_material()` (`world3d_terrain.gd:682-721`), which binds 10 parameters, none
  of them the A/B knobs. `CONFIG_CORE_01`'s 5 removed terrain keys were deleted precisely
  because they had zero consumers (`config.gd:55-61`), so simply re-adding them to JSON
  without a binding line would recreate dead keys.
- `--config` overlay is the correct no-edit mechanism and is already exercised by the
  capture tools (`terrain_sample_shot.py:212`, `full_map_shot.py:144`, `bake_bench.py:62`).

---

## 5. MINIMAL additive config keys COORD could add for a clean A/B matrix

These are **proposals only** — A12 wrote no code. Following the CONFIG-CORE-01 pattern, each
key needs (a) an entry in `FEATURES_DEFAULTS` (`config.gd:46-86`, at the shown group), (b) a
typed getter in the feature-readers block (`config.gd:416-474`), and (c) **exactly one**
consumer binding call at the shown `file:line`. Defaults equal today's shipped behaviour so
an unchanged config is byte-identical. All are reversible by removing the overlay key.

| ID | Proposed key | Add to `FEATURES_DEFAULTS` / getter at `config.gd` | Default | Consumer binding / change (file:line) | A/B axis |
|---|---|---|---|---|---|
| K1 | `features.terrain.uv_repeat` | terrain group after `:62`; getter after `:442`, `num`-pair → `Vector2`/Array | `[0.5, 0.5]` | `world3d_terrain.gd:707-709` add `mat.set_shader_parameter("uv_repeat", Vector2(...))` | 0.5 (2 m cell, shipped) vs e.g. 0.25 (4 m), 1.0 (1 m); alternate arm tests streak/moiré geometry. Shader already declares uniform at `:214`; no shader edit. |
| K2 | `features.terrain.mask_to_alpha` | terrain group; getter `float` | `1.0` | `world3d_terrain.gd:718-719` replace comment-only with `mat.set_shader_parameter("mask_to_alpha", <float>)` | **1.0 shipped vs 0.0 flat opaque.** Contract at `shader:478-502`, `B_SHADER_AB.md:33-49`; identical camera & seed mandatory (prior A/B differed 1.352 m in camera x — `MASK_ALPHA_FIX_01.md:181-186`). |
| K3 | `features.terrain.shadow_enabled` | terrain group; getter `bool` | `false` | `world3d_terrain.gd:709` replace hard `0.0` with `0.0/1.0` from getter | Sanity A/B only; no shadow map shipped, so 1.0 is expected to be inert/flat. Keep OFF as shipped; label PORT APPROX. |
| K4 | `features.water.surface_y` | **already exists** (§2 #7) — no addition | -0.25 | already at `water3d.gd:165` | Shipped vs `>0.8333` swell restore (PORT APPROX). |
| K5 | `features.water.level` / `features.water.shore_height` / `features.water.max_height` / `features.water.coast_fade` / `features.water.deep_fade` | water group after `:68`; getters `float` | `-0.25 / -0.1 / 2.96 / 0.57 / 1.07` | `water3d.gd:24-39` consts → runtime vars bound at `build()` `:165-167`; shader uniforms already exist (`water3d.gdshader:26-36`), no shader edit | Water-band overlap / shoreline against the now-opaque terrain (`Z3_VISUAL_BLEED §2.2` rank 4). Same literal for classification and plane Y must be deliberately decoupled (already done for `surface_y`). |
| K6 | `features.terrain.relief_stamps` | **already exists** (§2 #6) — no addition | false (shipped `config.json:25` = true) | already at `main.gd:789-790` | ON/OFF with same seed; note current shipped value is ON. |
| K7 | `features.season` (alias of existing `gameplay.season`) | **no new key needed** — use existing `gameplay.season` | `"summer"` | already at `config.gd:536` → `world3d_terrain.gd:407-414` | summer/winter/desert at identical seed & camera. |
| K8 | `features.ghost.stage_suffix` | new `ghost` group after `:85`; getter `String` | `"1"` | `world3d_fx.gd:645` replace literal `"1"` with `str(cfg.call("feature_ghost_stage_suffix"))`, null-safe via `C3ConfigScript.active` (mirror `hud.gd:276-292`) | **First stage `"1"` (shipped) vs final stage `"4"`** — directly serves charter §1b item 3. Footprint BoxMesh fallback and `_ghost_ok` green/red stay byte-identical. No donor ghost config was readable — label PORT APPROX. |
| K9 | `features.selection.*` (5 keys) | **already exist** (§2 #1-5) | see table | already wired | Marquee colour/width, drag epsilons, double-click. |

**A/B matrix recipe (derived):** fix seed `20261113`, 64² fixture, 1280×720, identical camera
x/y/z **and target** (`B_SHADER_AB.md:162-168`), `start_zoom` pinned, `user://options.json`
clean, `--config` overlay per arm, `--dump-config` recorded per arm; measure with the
`y=12` sky-strip split (`Z3_VISUAL_BLEED.md:117-121`). One variable per arm. Restore by
removing the overlay key — no source file touched.

---

## 6. Safety / reversibility summary (observed + derived)

- **Fully safe & reversible, with visual effect:** #1-5 selection, #6 relief_stamps,
  #7 water.surface_y, #11 FOV, #12-14 minimap, legacy `gameplay.season`/seed/map-size/
  camera. Revert by restoring the original value in the overlay (or deleting the key →
  getter fallback).
- **Reversible but inert (audit only):** #8 alpha_confine, #9 shore_prox.
- **Reversible but dead (no consumer):** #10 weather.snow, #15 render.fog,
  #16 gameplay.fog_of_war; plus the 5 deleted terrain keys (writing them does nothing).
- **Unsafe / misleading:** short `marquee_color` array (draw-time error); non-default
  `minimap_corner` (anchor-only, no offsets); non-donor `season` value 1 (falls back);
  shadow ON without a map; unvalidated string modes in general (`CONFIG_CORE_01 §6 Q4`).
- **No hot reload:** every knob needs a fresh launch; `--dump-config` is the only built-in
  way to prove what an arm actually ran.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Does any current `--config` fixture already set `features.terrain.relief_stamps` to
   false for captures? `config.json:25` is true; the small-map fixtures were not read by
   this ticket. Must be checked before attributing bands to relief (Z3 §1.1 says the same-
   seed dump had `relief_stamps=[]` even when the producer ran).
2. Can `world.season` be set by the capture harness at runtime (public field at
   `world3d_terrain.gd:317`)? Likely yes via the world node, but the exact setter path was
   not traced here — UNVERIFIED.
3. Is a donor GPU A/B frame available for any of these levers? No — none exists; every
   comparison is PORT APPROXIMATION internal consistency only.
4. Would binding `uv_repeat` (K1) require a mesh/`UV2` change? No — the uniform multiplies
   `v_st` (world XZ) in the vertex shader (`shader:316,392`); `UV2` carries tile id/face only.
   Mesh invariants remain intact (derived).
5. Does `mask_to_alpha=0.0` still put the constant-0 sentinel patches at near-black
   (`specular_rgb` bound to `DONOR_SPECULAR`)? Yes in both arms — the fold only removes RGB
   mask modulation; `ALPHA=1.0` at `shader:475` is unchanged (Z3 §4 note).

---

## 8. Summary

- 16 typed `feature_*` getters shipped (`config.gd:425-473`); 13 consumed (2 audit-only), 3 dead.
- Only `features.water.surface_y` and `features.terrain.relief_stamps` change terrain/water
  visuals today without code edits; 5 selection knobs are fully live; season is live via a
  legacy key.
- `uv_repeat`, `mask_to_alpha`, terrain shadow, water level/fade/glints and ghost final
  stage have **existing shader code or constants but no config bridge** — 5 additive keys
  plus one binding line each (§5 K1/K2/K3/K5/K8) would close the matrix; K4/K6/K7/K9 need
  no new key.
- `--config <overlay.json>` + `--dump-config` is the safe, reversible no-code-edit A/B path;
  pin seed, camera, zoom and UI-scale between arms.
- **No code edits, no Godot jobs, no donor access. No parity claim.**

*End of A12 report.*
