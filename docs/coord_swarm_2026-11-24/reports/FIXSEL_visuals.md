---
id: FIX-SELECTVIS
owner: FIX-SELECTVIS
date: 2026-11-24
scope: "variant3d/scripts/world3d_fx.gd + world3d.gd ONLY — add a 3D selection ring and donor-coloured owner indicator driven by the existing selection mirror; no picking, sim, app/, config, test-manifest or git edits."
status: "IMPLEMENTED — procedural stand-in; PORT APPROXIMATION — NOT DONOR PARITY"
governing_rule: "WAVE7 donor-evidence policy: cite path:line or label UNVERIFIED; translate 2D semantics, never copy 2D sprites; no RNG, no sprite sheets, no 2D bake outputs."
---

# FIX-SELECTVIS — 3D selection ring / owner-colour feedback

## 1. Evidence (what was broken, and what 2D actually does)

| Source | Evidence | Reading |
|---|---|---|
| `app/scripts/world.gd:3011-3041` | Selected **building** aura: `rr = e.def.radius * view_scale + 9` (`:3017`), `pc = _player_color(e.player)` (`:3018`), pulse `0.85 + 0.15*sin(anim_t*3 + id*0.7)` (`:3019`), squashed player glow (`:3021-3023`), unfinished-site progress arc (`:3024-3029`), dark under-ring (`:3032`), tinted donor `ring_sel` overlay (`:3033-3035`), four pulsing corner diamonds in player colour (`:3036-3041`), garrison pips (`:3042-3049`) | The 2D cue has **two distinct meanings**: "this is selected" (ring/pulse) and "this is owned by player N" (`pc`). |
| `app/scripts/world.gd:3252-3254` | Selected **unit** ring: `ov_ring[int(e.player)]`, squashed ellipse under the unit, `rw = vr * 2.9` | Same two meanings for units. No owner colour if no selection, but the ring is per-player. |
| `app/scripts/world.gd:2845`, `:2969-2972`, `:3094`, `:3103` | `col := _player_color(e.player)` drives building flags and base stripes | Owner colour is a continuous world-space cue, not only a selection effect. |
| `app/scripts/world.gd:2165-2182` | Port `PLAYER_COLORS` is a 12-entry **hardcoded** palette; `_player_color` wraps with `wrapi()` | Port palette is UNVERIFIED-INVENTED relative to donor (AUDIT3D-02 §2.1). |
| `docs/coord_swarm_2026-11-24/reports/AUDIT3D_02_colors.md:34-40,103-108` | Donor `gKeyColor` table at `classes.script:7986-8015` with `gc_MaxColorCount = 13`; applied recursively to units/buildings (`unit.script:3860`, `player.script:2971`, `misc.script:5070-5073`). G3: "*no player colour is rendered in the 3D world at all*"; `draw_rally()` had no caller before V7-76 (`:47`, `:103-105`). | Root donor evidence: the missing cue is both selection feedback **and** owner colour. |
| `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_02_vs_2d.md:81,127` | "*Selection rings / player aura / selected ring* — `world.gd:210-211,319-320`, `:3012-3035`, `:3252-3254,3364-3366` vs `no 3D mesh/shader found in world3d_*`" — Critical, "cannot tell what is selected/owned" | Confirms a correct picker alone gives no visual feedback in 3D. |
| `variant3d/data/donor_key_colors.json:46-195` | 13 slots, `index 0..12`, `rgb_godot_float`, slot 12 = mercenary; alpha UNVERIFIED (`:210-225`) | The 13 donor colours are the only owner-colour source used by this fix; no invented fallback. |

The donor glow itself is engine-side (`gGuiUpdateHighlights` / `SetHighlightRenderSettings`) and its textures are private-use. **Everything added here is a procedural stand-in: `PORT APPROXIMATION — NOT DONOR PARITY`.** No `ring_sel.png` / `ring_p0.png` / sprite sheet is loaded, no 2D bake output is touched, and no RNG is used (the pulse is the 2D deterministic `sin(anim_t*3 + id*0.7)`).

## 2. Exact diff

Only the two exclusively-owned files were edited. No picking/input, entities, terrain, app/, config or test-manifest file was touched; no git command was run.

### `variant3d/scripts/world3d_fx.gd` (additive, no existing call changed)

- `:35-49` — header block recording the 2D/donor citations and the `PORT APPROXIMATION — NOT DONOR PARITY` label.
- `:130-134` — `stats` gains `selection_rings`, `selection_entries`, `selection_owner_colors` (measured node/colour counts).
- `:147-150` — new private state: `_selection_root`, `_selection_markers` (id → marker dict), `_selection_positions` (id → map-origin Vector2).
- `:245-254` — `_shift_created_nodes()` re-places live selection markers on a V7-73 `world_offset` change (same handling as FX/rally).
- `:303` — `sync()` now calls `_update_selection()` (pulse only).
- `:379-435` — **new public API `sync_selection(entries)`**. Entries are `{id, pos, player, kind, radius}` dictionaries; set semantics — ids missing from the array are removed **in the same call**, so a cleared selection clears its rings immediately. Each entry creates or refreshes a marker; owner colour is re-resolved from the 13 donor slots on every sync so a player/capture change recolours it. Stats are updated on every call. No sim state is written.
- `:444-451` — `clear_all()` also frees selection markers and zeroes their stats.
- `:556-559` — `_ensure_roots()` creates the `Selection3D` Node3D child.
- `:726-834` — new construction/animation helpers:
  - `_make_selection_marker()` — holder `SelRing_<id>` with three `MeshInstance3D` children: `Ring` (flat `TorusMesh`, donor-coloured, alpha 0.92), `UnderRing` (thin dark torus, `world.gd:3032`), `OwnerPip` (small `CylinderMesh` disc, donor colour at alpha 1.0).
  - `_scale_selection_marker()` — footprint radius from sim metres with a modest screen margin; TorusMesh already lies in XZ, so no rotation is needed.
  - `_set_selection_color()` — recolours ring + pip from `_player_color(player)` (the same V7-65 13-slot loader used by the rally pennant). No palette fallback; out-of-range/missing JSON → transparent, never invented.
  - `_free_selection_marker()` — immediate `free()` (not `queue_free()`) so 2D's same-frame aura clear is matched and a synchronous probe can observe it.
  - `_update_selection()` — deterministic pulse `0.82 + 0.18*sin(_time*3 + id*0.7)`; ring alpha/emission are recomputed from the base value each frame (no drift, no RNG).

### `variant3d/scripts/world3d.gd` (additive, no sim/state change)

- `:54-58` — composition-map entry: selection aura derives from the existing `selected_ids` / `selected` mirror and calls `fx.sync_selection(entries)`.
- `:85-95` — donor/port citations added to the header block (2D aura/unit ring/flags, COMPLETENESS_02, AUDIT3D-02 G1/G3, `donor_key_colors.json` slots 0..12).
- `:521-553` — **new `_sync_selection_aura()`** plus `_entity_by_id()` and `_selection_radius()` helpers. It iterates `selected_ids`, resolves the entity from the read-only `selected` mirror (or `game.entities`/`by_id` fallback), skips dead/unknown kinds, and passes `{id, pos, player, kind, radius}` to FX. Radius uses `e.def.radius` (2D `world.gd:2846/3244`) or the same sid-keyed `Data.BUILDINGS`/`Data.UNITS` table used by FX. `e["selected"]` is never written.
- `:681` — `sync()` calls `_sync_selection_aura()` immediately after `_sync_selection()` and before the V7-76 ghost/rally sync and `fx.sync(dt)`. All V7-62 entity feed, V7-76 ghost/rally, V7-92 terrain/water integration, `anim_t` and all `dbg_*` counters are untouched.

## 3. Verification

Every Godot launch went through `variant3d/tools/godot_runner.py run` (FIFO ticket, hard timeout); no direct `godot` invocation. Jobs were run sequentially against the shared queue.

| Ticket | Job id | Command (abridged) | Result |
|---|---|---|---|
| 263 | `fixselvis-parse-fx` | `--headless --path variant3d --script res://scripts/world3d_fx.gd --check-only` | `ok`, run 2.54 s |
| 265 | `fixselvis-parse-world` | `--headless --path variant3d --script res://scripts/world3d.gd --check-only` | `ok`, run 4.25 s |
| 267 | `fixselvis-probe` | `--headless --path variant3d --script res://tests/_fixselvis_probe.gd` | `failed` — 12/13 checks passed; the two `SelRing_*` nodes were still present after clear because `queue_free()` is deferred until the next frame. No stderr. |
| 270 | `fixselvis-parse-fx-r2` | same parse as 263, after switching marker removal to immediate `free()` | `ok`, run 12.02 s (waited 295.98 s behind other agents) |
| 273 | `fixselvis-probe-r2` | same probe as 267 | **`ok`**, run 7.95 s — all 13 checks passed |
| 277 | `fixselvis-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json --timeout 180` | **`ok`**, run 102.20 s; `variant3d/selftest.json` → `"passed": true`, **29 steps / 29 passed / 0 failed** |

### Measured node / colour counts (ticket 273, `variant3d/tests/results/fixselvis_probe.json`)

The probe set the **existing** `world3d.gd` mirror directly (`selected_ids = [11, 22]`, `selected` = a unit with `player 0` / `def.radius 0.35` at `Vector2(12,14)` and a building with `player 1` / `def.radius 2.0` at `Vector2(40,44)`), then called `world3d.gd.sync(0.016)`. No sim or picker code was involved.

- `fx.stats.donor_key_colors_loaded = true`, `slots = 13`.
- **After sync:** `Selection3D` held **2** nodes — `SelRing_11`, `SelRing_22`; each had both `Ring` and `OwnerPip` `MeshInstance3D` children. `stats.selection_entries = 2`, `stats.selection_rings = 2`.
- **Colours (albedo of `Ring`, read back from the live material):** player 0 = `[0.73960787, 0.0, 0.0]` = donor slot 0 (`donor_key_colors.json:54`); player 1 = `[0.07058824, 0.40000001, 0.90352941]` = donor slot 1 (`donor_key_colors.json:66`). They are pairwise different and match the donor JSON within 0.02 (both colour-match checks passed). Before this fix the count was **0** rings / **0** owner-coloured nodes (`COMPLETENESS_02_vs_2d.md:81,127`).
- **After clearing** (`selected_ids = []`, `selected = {}`, `sync(0.016)` again): `Selection3D` held **0** nodes; `stats.selection_entries = 0`, `stats.selection_rings = 0`. Removal is synchronous, so no one-frame lingering ring.

The temporary probe `variant3d/tests/_fixselvis_probe.gd` was **deleted** after the passing run (no `.uid` left). Its result JSON is retained as the measurement artifact. **No visual-parity claim is made**: this is node-count and material-colour evidence for procedural stand-in geometry only, not a pixel comparison against the donor highlight effect.

## 4. Open questions

- **Q1** — The donor's actual highlight rendering (`SetHighlightRenderSettings` / `gGuiUpdateHighlights`) is engine-side and private-use; its glow texture and exact ring geometry remain UNMAPPED. The flat torus/disc here is a semantic translation only.
- **Q2** — 2D uses only two `ring_p*.png` overlays with `wrapi()` over 12 palette slots; the donor has 13 slots with slot 12 reserved for mercenaries (`donor_key_colors.json:193`). Slot 12 now renders from the donor table; whether the port should expose a 13th faction is an owner decision.
- **Q3** — Donor key-colour alpha is UNVERIFIED (`donor_key_colors.json:210-225`); this fix keeps the V7-65 port choice of alpha 1.0 for the pip and 0.92 base for the pulsing ring.
- **Q4** — Building aura 2D extras (unfinished-site progress arc, four corner diamonds, garrison pips; `world.gd:3024-3049`) are not reproduced; the ring + owner pip are the minimum feedback the user reported missing. Squad links / officer & capture flags remain 2D-only (`COMPLETENESS_02_vs_2d.md:85`).
