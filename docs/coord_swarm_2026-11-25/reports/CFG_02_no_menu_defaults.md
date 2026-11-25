---
id: CFG-02
owner: CFG-02 subagent (tiny follow-up builder)
date: 2026-11-25
status: reverted-after-gate-failure
---

# CFG-02 — no-menu / menu-skipping default map size 240×240 (`variant3d/config.json`)

## Outcome

**Change attempted, then fully reverted.** The mandated selftest gate fails with
`gameplay.map_width_tiles`/`map_height_tiles` = 240 (26/29 steps pass, 3 fail).
Per the task rule *"If a gate fails, revert the change and report — never weaken a
test"*, `variant3d/config.json` is back to its original content (320×320, `land`)
and is **no longer modified** in `git status`. The smaller-map request remains
un delivered on the no-menu path until the test-harness limitation below is
resolved by its owner.

## Step 1 — key confirmation (read-only investigation)

`variant3d/config.json` gameplay map keys (`:41-42`, `:73`) and the code that
reads them on the no-menu path:

| Concern | Exact key / location | How it is read |
| --- | --- | --- |
| Map width | `gameplay.map_width_tiles` (`config.json:41`) | `config.gd:407` `Data.MAP_W = maxi(16, int(num("gameplay.map_width_tiles", 240)))` |
| Map height | `gameplay.map_height_tiles` (`config.json:42`) | `config.gd:408` `Data.MAP_H = maxi(16, int(num("gameplay.map_height_tiles", 240)))` |
| Shape | `gameplay.map_type` (`config.json:73`, `"land"`) | `config.gd:429` `Data.MAP_TYPE = text("gameplay.terrain_type", text("gameplay.map_type", "mediterranean"))` |
| Relief | **no key** in `config.json` | `config.gd:432` → `hills`; `config.gd:492-494` re-resolves via `DONOR_RELIEF_TYPE` (`low_mountains` → `hills`) |
| Fog | `display.fog_of_war` (`config.json:22`, `false`) | already off; no change needed |

No-menu path confirmation: `main.gd:175-177` loads + applies `config.json`;
`main.gd:230-231` calls `_setup_full_game()` **directly** for selftest / uitest /
bench / screenshot / battle-request modes. `_apply_menu_cfg()` — the only place
that reads the menu's own `terrain_type`/`relief`/map_size dictionary — is called
solely from the interactive menu path (`main.gd:253-256`). So the no-menu default
comes entirely from `config.gd:apply()` reading `config.json`.

**Finding that corrects CFG-01:** CFG-01 reported that `map_type: land` was
"superseded by `terrain_type`" and that shape/relief were already Mediterranean +
hills on the menu-skipping path. That is not what the code does. `config.json`
has **no** `terrain_type` key, so `config.gd:429` falls back to the *present*
`gameplay.map_type` value (`"land"`); the guard at `config.gd:489`
(`if not gsec.has("terrain_type") and not gsec.has("map_type")`) is skipped for
the same reason. I verified this empirically: with map size 240, `map_type=land`
and `map_type=mediterranean` produced the **identical** 3 failing steps
(tickets 317 and 319) — map type is read, but is not the cause of the failure.
Relief is the only field already correct via fallback, and `config.json` has no
relief key to align (adding one would be a new key, not a value-only change).

## Step 2 — backup

`copy variant3d\config.json inbox\backup\config.json.bak-CFG02` →
`inbox/backup/config.json.bak-CFG02`, 14,409 bytes (original 320×320 / `land`).
This backup is the file restored at the end.

## Step 3 — change attempted (before → after), then reverted

Value-only edits to `variant3d/config.json` (240 sourced from the Tiny option in
the port skirmish dropdown, `variant3d/scripts/menu.gd:696-699`, as documented in
`CFG_01_skirmish_defaults.md:42-49`; no donor value invented):

| Key | Before | After (tested) | Final (reverted) |
| --- | --- | --- | --- |
| `gameplay.map_width_tiles` (`:41`) | `320` | `240` | `320` |
| `gameplay.map_height_tiles` (`:42`) | `320` | `240` | `320` |
| `gameplay.map_type` (`:73`) | `"land"` | `"mediterranean"` (isolation run only) | `"land"` |

`json.load` parse check passed after the edits; `git diff --no-index` against the
backup showed exactly the 3 value-only lines. No relief/terrain_type key was
added; fog and nations were untouched (already correct).

## Step 4 — validation through the variant runner (only)

All launches went through `python variant3d\tools\godot_runner.py run`. No `godot`
binary was invoked directly. No test was edited or weakened.

| Ticket | Job id | Gate | Config under test | Result |
| --- | --- | --- | --- | --- |
| 315 | `cfg02-selftest` | selftest (timeout 300) | 240×240 / `mediterranean` | **failed**, run 129.52 s — but the failure was external (see caveat 1) |
| 317 | `cfg02-selftest-r2` | selftest (timeout 300) | 240×240 / `mediterranean` | **failed**, run 51.86 s — **26/29 steps passed**, 3 failed |
| 319 | `cfg02-selftest-iso1` | selftest (timeout 300) | 240×240 / `land` | **failed**, run 52.74 s — **26/29 steps passed**, same 3 failures (isolates map type out) |
| 322 | `cfg02-selftest-iso2` | selftest (timeout 300) | 320×320 / `land` (reverted baseline) | **ok**, run 89.14 s — **29/29 steps passed** |
| 325 | `cfg02-uitest` | uitest (timeout 240) | 240×240 / `land` | **ok**, run 47.37 s — **17/17 steps passed** |

Failing selftest steps at 240 (both tickets 317 and 319):

- `wall` — "stone wall missing"
- `shell` — "wall missing, rally set, objectives 2"
- `farm_cap` — "farm 500 -> 500 -> 500"

Causality: 320/land passes 29/29; 240 fails the same 3 steps with either shape.
Therefore the **map size value itself** is what breaks the gate.

## Caveats / why the gate fails (not fixed — test not weakened)

1. **Transient external failure (ticket 315):** the first run died on a
   concurrent agent's in-progress edit — `SCRIPT ERROR: Parse Error: Cannot find
   member "is_empty" in base "Rect2"` at `input_controller.gd:89,115` (backup
   `input_controller.gd.bak-SEL01` shows that agent's work). That agent fixed the
   lines to `has_area()` before my retry; I did not touch that file (outside my
   ownership).
2. **Root cause of the 240 failure:** `selftest.gd:123-133` `_spot()` searches
   only a fixed 6/10/14/18/24 m ring around the peasant for a buildable point.
   The 240×240 mapgen layout leaves no valid spot in that ring for `wal`
   (`selftest.gd:434-446`) and `hou` (`selftest.gd:690-709`), so `_spot()` returns
   `Vector2.INF`, the buildings are never placed, and those 3 steps fail. This is
   a test-harness assumption about the map layout, not a gameplay value that can
   be repaired by another config value (changing `random_seed` to hunt for a
   friendly layout would be test-gaming, so I did not do it). Fixing or widening
   `_spot()` belongs to the selftest owner; this task forbids editing it.
3. Ticket 317's stderr also showed a missing `.godot/imported/mill_rotor...ctex`
   (asset-import race with concurrent agents). It is unrelated to config values;
   the deterministic step failures above reproduce without it (ticket 319).
4. The mandated selftest command regenerates `variant3d/selftest.json` as its
   normal output (last baseline run: `passed: true`, 29/29). I did not hand-edit
   that file. `variant3d/uitest.json` was regenerated byte-identically.
5. Donor-literal Tiny is 256; 240 is the port dropdown Tiny (`menu.gd:696-699`).
   Carried forward from CFG-01; unchanged here.

## Files touched

- Edited then restored: `variant3d/config.json` — final content byte-identical
  to original; **no net change**.
- Created: `inbox/backup/config.json.bak-CFG02` (backup).
- Created: this report.

**No other file was edited.** In particular, `variant3d/scripts/**`, `app/**`,
`variant3d/selftest.json` and `variant3d/uitest.json` were not hand-edited by me;
their working-tree differences are other agents' work or runner-generated output.

## Summary

The exact no-menu keys are `gameplay.map_width_tiles`/`map_height_tiles`
(`config.json:41-42`), read at `config.gd:407-408`; 240 is the Tiny dropdown value
from `menu.gd:696-699`. I backed up `config.json`, applied the value-only 320→240
change, and also corrected `map_type: land` → `mediterranean` after verifying it
is genuinely still read on the no-menu path (CFG-01's "superseded" claim was
inaccurate). Validation: uitest passed 17/17 at 240, but selftest failed 26/29 —
`wall`, `shell`, `farm_cap` — because `_spot()`'s fixed search ring finds no
buildable spot on the smaller map. Baseline 320 passed 29/29, isolation runs
proved map type was not the cause, so per the "revert on gate failure" rule I
restored `config.json` from the backup. Net result: no delivered change; the
blocker is the selftest harness's map-layout assumption, which is outside this
task's ownership.
