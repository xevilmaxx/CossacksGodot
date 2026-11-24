# V7-38 — Variant manifest registration report (2026-11-24)

## Owned files
- `variant3d/tests/manifest.json`
- `docs/coord_swarm_2026-11-24/reports/V738_manifest.md` (this file)

No Godot runs (not required). No test files edited.

## Contract reference
`docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md` defines 7 test atoms
under `variant3d/tests/`:
`t_terrain3d.gd`, `t_camera3d.gd`, `t_pick3d.gd`, `t_entities3d.gd`,
`t_fx3d.gd`, `t_fog3d.gd`, `t_render_mode.gd`.

## Disk audit (authoritative)
Recursive, case-insensitive existence check across the whole repo for all 7
atomic test filenames returned **zero** matches. None are present on disk
`variant3d/tests/` contains only the inherited 2D test files plus `README.md`
and `_template_test.gd`.

## Registered vs pending
- **Registered: NONE.** Per the charter ("register ONLY the atomic test files
  that exist on disk", "Do NOT invent entries for missing files"), zero
  entries were added to `variant3d/tests/manifest.json`.
- **Pending (file absent, therefore not registered): all 7**
  - `t_terrain3d`  — pending (file missing)
  - `t_camera3d`   — pending (file missing)
  - `t_pick3d`     — pending (file missing)
  - `t_entities3d` — pending (file missing)
  - `t_fx3d`       — pending (file missing)
  - `t_fog3d`      — pending (file missing)
  - `t_render_mode`— pending (file missing)

These atoms are owned by separate test agents and must land on disk before
they can be registered. Re-run this registration once they exist; entries must
be appended LAST using the exact manifest schema (`id`, `path`, `feature`,
`status`, `owner`, `timeout`, and `windowed` where applicable), with `path`
values of the form `res://tests/<name>.gd`.

## Manifest state (unchanged)
All 24 pre-existing 2D entries are intact and byte-for-byte preserved:
`t_build_flow`, `t_mill_logic`, `t_mine_unified`, `t_visual_tuning`,
`t_mill_rotor`, `t_upgrades`, `t_roster_scotland`, `t_squads`, `t_multi_ai`,
`t_teams`, `t_smoke_fx`, `t_water`, `t_weather`, `t_hud_fidelity`,
`t_anim_metrics`, `t_naval`, `t_mass_army`, `t_map_variety`, `t_capture`,
`t_audio_events`, `t_pick_res`, `t_forest_dense`, `t_forest_bake`,
`t_forest_bake_render`. (23 `ready`, 1 `pending`.) The variant still runs the
29/29 + 17/17 2D baselines.

## Verification
```
python -c "import json; json.load(open('variant3d/tests/manifest.json'))"
```
Result: **VALID JSON** (`version` 1, 24 tests). No exceptions.

## Expected failure note
3D atomic tests currently FAIL with `MODULE_MISSING` until the `variant3d/scripts/`
modules land. This is expected during the port. Do NOT "fix" by removing or
weakening assertions in any test file — assertions must remain so the tests
actually validate the modules once they exist. MODULE_MISSING is a consequence
of module-less dynamic `load()`, not a manifest problem.
