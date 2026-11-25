---
id: G09
ticket: "TERRAIN-SWARM-2026-11-25 / Wave G — ghost footprint honesty: donor .prop mask vs radius (F05)"
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
status: PROPOSAL ONLY — READ-ONLY, ONE REPORT, NO CODE EDIT, NO RUNNER
owner_files:
  - docs/terrain_swarm_2026-11-25/reports/G09_footprint.md
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
visual_parity_claim: false
---

# G09 — Ghost footprint honesty: a minimal follow-up keyed to the port's placement radius

## 0. Scope, method, guardrails

Read in full: `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (assignment G09,
standing rule 1: only G04 runs Godot), `CHARTER.md` (§1b.3 owner requirement —
"pixel-honest footprint"; §3 no test weakening / no invented donor constants /
disjoint ownership / backups), and the four required reports
`F02_almanac_building_ghost.md`, `F05_online_vs_local.md`, `B06_ghost_impl.md`,
`E04_ghost_qa.md`.

Read-only source inspection this pass: `variant3d/scripts/world3d_fx.gd`,
`world3d.gd`, `game.gd`, `data.gd`, `variant3d/tools/compute_buildings.py`,
`convert_models.py`, `variant3d/assets/models/anim/buildings/buildings.json`,
`variant3d/tests/t_ghost_final_stage.gd` (the G02-created atom), plus repo-wide
globs/greps for `.prop` files and decoded collision-mask data. **No code, test,
config, asset or git edit; no Godot process; no runner job.** Donor parity stays
**UNVERIFIED** — there is no donor GPU A/B frame.

---

## 1. OBSERVED — is any "collision-mask" data available in the port?

### 1.1 The donor `.prop` collision mask is NOT in this repo

| Check | Result | Evidence |
|---|---|---|
| `**/*.prop` in workspace | **none** | glob this pass (0 files) |
| Decoded per-building cell mask | **none** | repo-wide grep for `collisionmaskproperty`, `CollisionMask`, `Mask =`, `prop_mask`, `mask_cell` — no port data hit |
| `.prop` format status | "Not inspected in this pass" | `docs/decomp/DC_FORMATS.md:23` (`.prop`/`.actor` 1285/976 files, "Not inspected"; `.pattern` at `:16` is *terrain brush* footprints, unrelated) |
| Port reads donor `.prop` only for material names | scaffold auto-child / base material | `variant3d/tools/convert_models.py:307-325` cites `ukrcen.prop:13-43` (`DefaultMaterialName`) and `engcen.prop:72-112` (scaffold child) — no mask bytes read |
| `mines_display.json` `"prop"` key | a **path string only** | `variant3d/tools/piece_specs/mines_display.json:24` |

**Conclusion (OBSERVED):** the donor footprint source F02/S1 quotes —
`collisionmaskproperty.Mask` in `<sid>.prop`, 1 mask cell = 0.5 map cells, separate
from the render/selection `CustomBoundingAABB` (F02 §1/§2.5, F05 row 4) — is
**not available as port data**. A true donor-mask footprint overlay cannot be
built from existing files; doing so would require decoding donor `.prop` assets
(a separate, out-of-scope data ticket). This answers the dispatch's "if available
in port": **it is not.**

### 1.2 What footprint data the port *does* have, and what `can_place()` uses

| Data | Source | Label |
|---|---|---|
| `Data.BUILDINGS[sid].radius` — "footprint, **estimated**" | `data.gd:1303-1337` (e.g. `hou` = 1.5, `cen` = 3.0) | PORT APPROX |
| `game.bld_rm(player, sid)` — **visual half-width in metres** for nation sprite buildings | `game.gd:1822-1835`; index `assets/models/anim/buildings/buildings.json` (`ukr_hou.rm = 4.113`), computed as `rm=((x1-x0)/width*ortho)*0.5` from the sprite alpha ink box (`tools/compute_buildings.py:91-105`) | PORT APPROX (sprite-derived, i.e. the port's *visible* AABB analogue, **not** donor mask) |
| `game.bld_block_r(e)` — "impassable footprint: visual size when known, else gameplay radius" | `game.gd:1837-1842` | PORT APPROX |
| `can_place()` legality | `game.gd:3986-4058`: bounds → water → `var _mr = bld_rm(player, sid); my_r0 = _mr if _mr > 0.0 else def.radius` (`:4022-4023`) → resources/resource-grid `:4024-4046` → buildings/`grid_query` `:4047-4055` → `is_blocked` `:4056` | OBSERVED |

**DERIVED:** the port's *effective collision footprint* is `bld_rm(player,sid)`
with `def.radius` fallback. This is the only in-repo footprint datum that the
placement verdict actually enforces.

### 1.3 The ghost indicator uses a different radius source than the verdict

`variant3d/scripts/world3d_fx.gd`:

- `draw_ghost()` `:597-598`: `var r: float = _building_radius(s)`;
  `_ghost_mesh.scale = Vector3(r * 2.0, 1.0, r * 2.0)`.
- `_building_radius()` `:1553-1558`: returns `Data.BUILDINGS[sid].radius` only
  (min 0.25; else 1.5). **It never calls `bld_rm`.**
- `Footprint` node `_ensure_roots()` `:909-916`: `BoxMesh(1, 0.05, 1)`, named
  `"Footprint"`, shared `_ghost_mat` (so green/red pulse applies to it too).
- `_ghost_swap_building_mesh()` `:621-637`: when a building mesh resolves,
  `_ghost_building.visible = true` **and `_ghost_mesh.visible = false`**; the
  footprint is shown **only** in the no-art fallback branch (`:633-637`).

OBSERVED divergence: with a baked nation sheet, `bld_rm(0,"hou") = 4.113` m but
`_building_radius("hou") = 1.5` m. The gate checks ≈4.11 m clearance while the
ghost draws a 1.5 m square — the indicator **under-reports** the footprint. F02
§4.3 / B06 §3 "indicator and verdict share one radius" was true of the older
`can_place()` F02 read (`game.gd:3932-3986`) but is **stale** after the T-PERF-SIM
hoist of `bld_rm` into `my_r0` (`:4022-4023`). This is an internal port honesty
gap, independent of the donor-mask question.

### 1.4 E04 / G02 keep the footprint check STRICT (binding constraint)

`E04_ghost_qa.md`: check 7 `footprint_matches_donor_mask` (`:80`, `:512-529`)
requires the `Footprint` node **visible**, `BoxMesh(1,0.05,1)`, and
`scale == Vector3(2r, 1, 2r)` where `r = bld_rm(0,SID)` else `def.radius` —
explicitly the *same radius the gate uses*. E04 §7 open question resolves it as
"do NOT weaken the check: keep visibility explicit"; the created atom
`variant3d/tests/t_ghost_final_stage.gd` (by G02) implements exactly that at
`:445-469` with the header note `:14-17`: "expected to remain RED; it is recorded
as `expected_pre_fix_failure`, NOT weakened, re-scoped to geometry-only, or
flipped to green." G02 ran no Godot (Wave G standing rule 1).

**DERIVED:** the atom goes green only if the follow-up **both** (a) shows the
footprint alongside the finished mesh **and** (b) scales it with `can_place()`'s
radius source (`bld_rm` else `def.radius`), not `_building_radius`.

---

## 2. Minimal follow-up design (DERIVED — proposal, no edit made)

**Exact file:** `variant3d/scripts/world3d_fx.gd` — B06's exclusive file. File it
as a **follow-up ticket after B06 is integrated** (no concurrent edit), with
backup `inbox/backup/world3d_fx.gd.bak-G09`, owner renamed node kept as
`GhostBuildingFinished` (B06).

**Data source (read-only):** `game.bld_rm(0, sid)` with fallback to
`Data.BUILDINGS[sid].radius` — i.e. the exact branch `can_place()` uses at
`game.gd:4022-4023`. Reach `game` through the existing FX→parent seam: the FX
module's parent is `world3d` (`world3d.gd:132 var game`, FX bound at `:606`), the
same parent `_ghost_entities_provider()` already queries at
`world3d_fx.gd:610-618`. Add a sibling `_ghost_game()` helper that does
`get_parent().get("game")` and guard with `has_method("bld_rm")`; never call into
the sim, never edit `game.gd`.

**Three small edits in that one file:**

1. **New helper** `_ghost_footprint_radius(sid: String) -> Dictionary` returning
   `{"r": float, "source": "bld_rm|def.radius"}`; cache by sid like
   `_ghost_mesh_cache`; write telemetry
   `stats["ghost_footprint_radius"]` / `stats["ghost_footprint_source"]`
   so the indicator's radius source is auditable.
2. **`draw_ghost()` `:597-598`:** replace `var r = _building_radius(s)` with
   `var r = _ghost_footprint_radius(s).r`; keep the `Vector3(r*2,1,r*2)` scale
   and the `BoxMesh(1,0.05,1)` geometry byte-identical.
3. **`_ghost_swap_building_mesh()` `:628-637`:** when a building mesh resolves,
   keep `_ghost_mesh.visible = true` (flat ground overlay under the translucent
   finished mesh — it already uses the shared `_ghost_mat`, so green/red stays
   consistent) instead of `false`. No-art fallback branch unchanged. Leave
   `_building_radius()` itself untouched (keep the diff minimal).

**Do NOT touch:** `game.gd` (`can_place`, `bld_rm`, `bld_block_r` stay byte-identical
— "without changing can_place()"), `world3d_entities.gd`, `world3d.gd:463-498`,
`world.gd`, `hud.gd`, `input_controller.gd`, any test, config, manifest or asset,
and the entire 2D `app/`. No new config key. No new donor constant. No donor-mask
parity claim: label the new comments
`PORT APPROX — sprite-derived visual half-width / estimated radius, NOT the donor
.prop collision mask (F02 §1/§2.5, F05 row 4)`.

**Residual risk to record, not to silently "fix":** the flat box sits at
`y = 0` with half-thickness 0.025 m, so showing it may z-fight with terrain; if a
small y-lift is needed, keep it within this same file and re-verify check 7's
BoxMesh/scale assertions (they do not test position). Donor partial-validity
(e.g. "a wall crossing a rock", S4) remains uncommunicated — PORT APPROX.

---

## 3. Acceptance test (DERIVED — decisive, but not run by G09)

**Primary gate — E04/G02 atom, unweakened:** run
`variant3d/tests/t_ghost_final_stage.gd` windowed under the G04 runner lock
(unique id; `python variant3d\tools\godot_runner.py status` first; G09 submits
nothing). Check 7 `footprint_matches_donor_mask` must flip from its current
expected RED to **PASS** with all three operands unchanged:
`fp.visible == true` (alongside `GhostBuildingFinished`), BoxMesh size
`(1,0.05,1)`, `fp.scale ≈ Vector3(2*bld_rm(0,"hou"), 1, 2*bld_rm(0,"hou"))`
(or the `def.radius` fallback when `bld_rm` returns 0). `expected_pre_fix_failure`
stays `true` as provenance only — never flipped, `fp.visible` never dropped, no
geometry-only re-scope (E04 §7; G02 header `:14-17`). `stats.ghost_footprint_source`
must equal the same `bld_rm`/`def.radius` branch the atom computed for `r_sim`.

**Regression gates (all stay green; no threshold lowered):**
- variant selftest 29/29, uitest 17/17 (ghost→site→builder flow),
  `t_render_mode`, `assert_clean` CLEAN — CHARTER §5 / B06 §5;
- `t_ghost_final_stage.gd` checks 4/5 (finished mesh identity, no foundation)
  and 8/9/10/11/12 (PNG during placement, pixel diff, blocked tint, cancel,
  convert-to-construction) stay PASS — the footprint change must not alter mesh
  selection, tint or lifecycle;
- placement-related tests (`t_mines_place.gd`, `t_mine_build.gd`,
  `building_block_test.gd`) unchanged — proof that `can_place()` was not edited;
- 2D `app/` untouched; donor parity remains UNVERIFIED (no A/B frame).

**If COORD instead chooses re-scope option (b)** from E04 §7, the integrating
owner must update `_probe_ghost()` / check 7 in the atom — never delete or weaken
it. This report recommends option (a): show the overlay.

---

## 4. Ledger and direct answers

| Question | Answer | Label |
|---|---|---|
| Does the port hold donor `.prop` collision-mask data usable for the overlay? | **No** — no `.prop` file, no decoded mask; `.prop` only inventoried (`DC_FORMATS.md:23`) / mined for material names (`convert_models.py:307-325`). | OBSERVED |
| What footprint data is available and drives placement? | `game.bld_rm()` (sprite half-width, `buildings.json`) with `Data.BUILDINGS[sid].radius` fallback; `can_place()` uses it at `game.gd:4022-4023`. | OBSERVED / PORT APPROX |
| Is the ghost indicator honest today? | Internally **not quite**: overlay uses `_building_radius` (1.5 m for `hou`) while the gate uses `bld_rm` (4.113 m for `ukr_hou`). F02/B06's "shared radius" claim is stale. | OBSERVED / DERIVED |
| Exact file for the follow-up? | `variant3d/scripts/world3d_fx.gd` only (B06's file, as follow-up); data via read-only `game.bld_rm` through the FX parent seam; `can_place()` untouched. | DERIVED |
| Acceptance test? | E04/G02 check 7 green with visibility + BoxMesh + gate-radius scale preserved; selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN; no donor parity claim. | DERIVED |

- **OBSERVED:** all source/code/test reads cited above.
- **DERIVED:** the three-edit plan, the radius-source alignment, the acceptance
  criteria, and the staleness of the F02/B06 "one shared radius" statement.
- **INFERRED:** that check 7 will go green once visibility and radius source are
  aligned (not verified — G09 ran no Godot).
- **UNVERIFIED / PORT APPROX:** donor-parity of any footprint; exact donor ghost
  appearance (F02 §3.1); donor `.prop` mask shape/scale; visual result of the
  proposed overlay (no capture).

*End of G09 report. One report written; no code, test, config, asset, git or
runner state changed; no donor binary executed or copied; no visual-parity claim.*
