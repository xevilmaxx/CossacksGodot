# AUDIT — Field stage timing: why ripe `field` art is (not) selected at screenshot time

Date: 2026-11-26. Scope: READ-ONLY trace of `game.gd` field creation/state,
`world3d_entities.gd:_field_spec` stage selection, and capture timing.
Question: mature donor `field.png` is golden wheat and all converted stage
textures exist, yet `cap_donor_240m.png` / `cap_donor_240n.png` still show dark
olive field parcels (field ROI x950–1280 y230–500, gold fraction ~0.078) even
after the field decal/stage fixes landed.

Headline finding: **stage-selection timing is exonerated.** Fresh demo-mill
fields are born `hits = max_hits`, so `field_state()` returns `"ripe"` and
`_field_spec()` selects the mature `"field"` material from t = 0. A frozen or
early capture clock cannot demote them. The olive in the ROI is therefore NOT a
wrong growth stage — it is either (a) terrain paint because no mill/fields
spawned in that capture's config, or (b) the ground-decal layer, whose two
known BLOCKED items (missing mip chain, unimplementable donor dst-alpha blend)
survive the landed code fixes. No invented gold art is proposed; no parity is
claimed.

## 1. Creation path (all lines in `variant3d/scripts/game.gd`)

1. Gate: `_spawn_demo_mill` runs only `if _demo_mill_enabled()` (`game.gd:3237-3238`).
   `_demo_mill_enabled()` (`game.gd:3242-3246`) reads
   `C3Config.flag("features.terrain.demo_mill", false)` — **default false**,
   null-safe. Per `docs/terrain_swarm_2026-11-26/reports/AUDIT_FEATURES.md:44`,
   the flag is absent from shipped `variant3d/config.json` and `true` only in
   `map_donor_240.json` / `map_donor_64.json` / `map_donor_240_hires.json`.
2. `_spawn_demo_mill` (`game.gd:3248-3278`) spawns with `finished := true`
   (`game.gd:3277`: `spawn("mil", 0, mill_pos, true)`).
3. `spawn()` with `finished=true` calls `_on_building_finished(e)`
   (`game.gd:2682-2683`), which for `sid == "mil"` calls
   `_sow_field_ring(e, _demo_mill_enabled())` (`game.gd:2715-2718`).
4. The donor ring (`_sow_donor_field_ring`, `game.gd:2782-2835`) creates each
   parcel with `_add_res("food", p, 50, 0.6)` (`game.gd:2831`; legacy ring is
   identical at `game.gd:2773`). The `mill` link is stamped at `game.gd:2833`.
5. `_add_res` (`game.gd:576-588`): `hits = 50, max_hits = 50`, and because
   `hits > 0`, `growth = 1.0, regrow_t = 0.0, regrow_time = FIELD_REGROW_TIME`
   (`game.gd:579-582`, `FIELD_REGROW_TIME := 60.0` at `game.gd:212`).

Result at boot: every demo-mill parcel is full-HP with `growth = 1.0`.

## 2. State functions (`game.gd:2896-2916`)

- `field_state(n)` (`game.gd:2898-2906`): `hits (50) > 0` → ratio `50/50 = 1.0`
  → `1.0 >= 0.75` → returns `"ripe"`. Threshold at `game.gd:2903`.
- `field_growth01(n)` (`game.gd:2910-2916`): `hits > 0` → returns
  `hits / max_hits = 1.0` (`game.gd:2912`).

Neither function reads the sim clock. A frozen `time_s` changes nothing here.

## 3. Stage selection (`variant3d/scripts/world3d_entities.gd:788-838`)

`_field_spec(fe)` (`world3d_entities.gd:788-838`):

- Reads `game.field_state()` / `game.field_growth01()` (`:792-795`); fallback
  when unbound is `"ripe" if g > 0.0 else "depleted"` (`:796-797`).
- `"ripe"` → `donor_material = "field"` (mature), unconditionally
  (`world3d_entities.gd:802-803`). The `"growing"` branch (`:804-810`) maps
  `g >= 13000/25000 (0.52)` → `"field"`, `g >= 5000/25000 (0.20)` → `"field5"`,
  else `"field6"`; `"regrowing"` maps the 0..1 timer across
  `FIELD_GROWTH_MATERIALS = ["field1".."field4"]` (`:328`, `:820-821`);
  default/depleted → `"field7"` (`:800`, `:822-823`).
- Texture bind `_field_texture_path` (`world3d_entities.gd:761-785`) resolves
  the requested name directly against converted art; `"field"` binds the donor
  mature `field.png` conversion. Fallback to `field1` happens ONLY when the
  requested conversion is absent (`skipped=true`, `:779-782`) — never
  synthesized gold (`:775-777`).
- The per-frame audit mirror (`world3d_entities.gd:2751-2756`) counts
  `field_ripe_mature` only when `state == "ripe"` AND
  `texture_material in ("field", "fieldw")`, so a capture log carrying
  `field_visual_states` / `field_visual_ripe_count` (`:2776-2780`) directly
  answers "was ripe art bound?" without eyeballing pixels.

With fresh parcels (`state="ripe"`, `g=1.0`) the selector deterministically
yields material `"field"` + mature texture whenever the conversion exists —
which it does per the task context.

## 4. Capture timing (why the frozen/early clock is not the cause)

- Screenshots fire at `frame >= screenshot_frames` with default
  `screenshot_frames := 120` (`variant3d/scripts/main.gd:69`, `:1739-1741`).
- Sim advances in `_process` via `game.tick(step)`, `step = 1.0 / Data.FPS`,
  `Data.FPS = 32.0` (`main.gd:1626-1634`, `data.gd:32`), so a 120-frame capture
  reaches roughly `time_s ≈ 120/32 ≈ 3.75` sim-seconds — even a fully frozen
  clock (`paused`, `game.gd:4624-4625`, or `time_s = 0`) leaves fresh parcels at
  `hits = 50 > 0`.
- Per-tick `_tick_fields(dt)` (`game.gd:2942-2962`, called at `game.gd:4642`)
  explicitly skips live parcels (`hits > 0`, `game.gd:2945-2947`); it only
  advances depleted mill-linked fields toward `_restore_field` at 60 s.
- The bulk `_tick_field_growth()` (`game.gd:2969-2979`) fires only every
  `sow_t >= 60.0` sim-seconds (`game.gd:4643-4646`). Its restore loop
  (`game.gd:2976-2979`) would also restore mill-linked parcels — but at
  t ≈ 0–4 s it never runs, and fresh parcels do not need it.

Conclusion: at screenshot time the sim state feeding `_field_spec` is
`ripe / 1.0` → mature `"field"` art is selected. Timing cannot explain
`gold fraction ~0.078`.

## 5. What the olive ROI most likely is (two donor-grounded branches)

Branch A — no fields spawned in that capture. If the 240m/240n run used a
config without `features.terrain.demo_mill = true` (the shipped default is
false; only the `map_donor_*.json` fixtures set it — see §1.1), then
`_spawn_demo_mill` never runs, `field_visual_states` is empty, and the olive
parcels in x950–1280 y230–500 are terrain detail paint (test2/test3 blend or
dirt pads), not field entities at all. Check: capture stdout map path +
`field_visual_states` / `field_visual_ripe_count` in the log. Empty states dict
confirms Branch A; no code change is indicated — re-run under
`map_donor_240.json`.

Branch B — fields spawned, crop stage correct, decal layer wrong. Each parcel
also draws a terrain-conforming ground quad from `envfieldd.png`
(`FIELD_DECAL_SUMMER`, `world3d_entities.gd:318`) at 1.3× size, 45°/225°
(`:320-327`). Two items the landed fixes explicitly leave BLOCKED/UNVERIFIED:

- Missing mip chain: `field.png` and `envfieldd/w.png` imports carry
  `mipmaps/generate=false`; donor `miLinearMipmapLinear` is requested but the
  imported mip chain is absent — asset-import owner required
  (`world3d_entities.gd:355-358`, `FIELD_TEXTURE_IMPORT_STATUS`).
- Donor blend `GL_DST_ALPHA/GL_ONE_MINUS_DST_ALPHA` (decals.mat) cannot be
  encoded in Godot; the port uses conventional `TRANSPARENCY_ALPHA +
  BLEND_MODE_MIX` with `DEPTH_DRAW_DISABLED` + `render_priority -1` as a
  labelled substitute (`world3d_entities.gd:344-354`,
  `FIELD_DECAL_STATUS` / `FIELD_DECAL_MATERIAL_STATUS`).
- Related: the warm mature Emission `(232,218,195)/255` is applied as an
  UNSHADED ALBEDO MULTIPLIER, never additive emission — a multiplier can only
  darken the PNG (`world3d_entities.gd:333-343`, `FIELD_EMISSION_STATUS`).

Any stale import cache or opaque-quad fallback renders the decal as a flat
olive square sitting exactly where a "field parcel" is expected, while the
standing crop mesh above it correctly binds golden `field.png`. That matches
"stage fixes landed, ROI still olive, gold ≈ 0.078".

Camera note: default `screenshot_focus = "start"` (`main.gd:71,183`);
a `relief`-focus capture may frame ground without the mill ring in view —
verify the mill parcel positions against the capture camera before reading the
ROI as field evidence.

## 6. Smallest donor-grounded way to show mature crop art in QA (no default-gameplay change)

No sim or gameplay constant needs to move: fresh parcels are already born ripe
(§1–§3). The minimal QA-only path is:

1. **Config, not code (first step).** Run the QA capture with the fixture that
   already sets the flag — `map_donor_240.json` (`demo_mill: true`) — and assert
   on `field_visual_states`/`field_visual_ripe_count` (`world3d_entities.gd:2776-2780`)
   plus `texture_status = "DONOR_CONVERTED field -> …"` rather than on ROI gold
   alone. If Branch A was the cause, this alone turns the capture golden with
   zero code delta; default gameplay is untouched because the flag defaults to
   false (`game.gd:3246`).
2. **If Branch B is confirmed (fields present, decal olive):** hand the
   `.import` mip-chain fix to the asset-import owner
   (`world3d_entities.gd:358`) and re-import `field.png` / `envfieldd/w.png`
   before judging decal pixels. Code-side, everything else is already gated and
   labelled; do not invent gold tint or emission energy (explicitly refused at
   `world3d_entities.gd:346-354`).
3. **Optional belt-and-braces, QA-gated only:** if a future capture must be
   robust against pre-harvested/depleted parcels, advance the sim behind the
   existing screenshot/seq gate instead of touching spawn state — e.g. in
   `main.gd` drive `game.tick(1.0/Data.FPS)` until `game.time_s` passes one
   `FIELD_REGROW_TIME` (60 s, `game.gd:212`) before `_save_screenshot()`
   (`main.gd:1739-1741`), guarded by `screenshot_path != ""` / `seq_dir != ""`
   so interactive and default play never see it. Depleted mill-linked parcels
   then pass through `_restore_field` (`game.gd:2852-2859`: `hits = max_hits`,
   `growth = 1.0`) → `field_state() = "ripe"` → `_field_spec` selects `"field"`
   (`world3d_entities.gd:802-803`). This reuses the single restoration path and
   changes no threshold, no HP band, and no default-spawn value.
   Deliberately NOT recommended as a first step: fresh fields do not need it,
   and it lengthens capture wall-clock.

Exact file/line checklist for the implementer:

- `variant3d/scripts/game.gd:2831` — parcels sown at `hits = max_hits = 50`
  (born ripe; leave unchanged).
- `variant3d/scripts/game.gd:2903` — ripe threshold `ratio >= 0.75`
  (leave unchanged).
- `variant3d/scripts/world3d_entities.gd:802-803` — `ripe → "field"` mature
  binding (leave unchanged; assert `field_ripe_mature > 0` at `:2753-2756`).
- `variant3d/scripts/world3d_entities.gd:355-358` — `.import`
  `mipmaps/generate=false` BLOCKED item (asset-import owner fix).
- `variant3d/scripts/main.gd:1739-1741` + `main.gd:69` — screenshot gate where
  any QA-only sim-advance would live, strictly behind `screenshot_path != ""`.
- Capture fixture — `map_donor_240.json` (`demo_mill: true`) as the QA launch
  config; `variant3d/config.json` stays without the flag so default play is
  byte-identical.

## 7. Non-claims

- No gold art is invented or recolored here; the only sanctioned fallback is
  converted `field1.png`, explicitly labelled PORT APPROXIMATION
  (`world3d_entities.gd:775-782`).
- No parity claim: port HP/timer semantics vs donor HP bands (13000/5000/25000,
  `world3d_entities.gd:329-331`, `game.gd:2967`) and all decal/blend/emission
  substitutes remain APPROXIMATION / UNVERIFIED per the constants cited above.
- ROI gold fraction ~0.078 is taken as given context, not re-measured in this
  read-only audit (no Godot run, no new capture).
