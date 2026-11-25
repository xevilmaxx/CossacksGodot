# SEASON-TEST-PATH-01 — align Winter atlas filenames in the season-overlay atom

Owner: tiny fix builder. Exclusive ownership: `variant3d/tests/t_season_overlay.gd`
and this report. No other source/asset/config file was edited.

## 1. Why this ticket existed

`QA_WINTER_01.md:92-105` independently verified the delivered Winter atlas and
found a split state:

| Location | QA citation | Observed before this ticket |
|---|---|---|
| `variant3d/scripts/world3d_terrain.gd:269-273` | `QA_WINTER_01.md:94-96` | already correct: `tile_index_atlas_winter.manifest.json` / `tile_index_atlas_winter.png` |
| `variant3d/tests/t_season_overlay.gd:59-60` | `QA_WINTER_01.md:98-100` | **not aligned**: `tile_index_winter_atlas.manifest.json` / `tile_index_winter_atlas.png` |
| On disk | `QA_WINTER_01.md:102-103` | `tile_index_atlas_winter.png` (124,463,306 B), `tile_index_atlas_winter.manifest.json` (79,837 B), `tile_index_atlas_winter.png.import` (993 B); recursive `**/tile_index_winter_atlas*` glob → **0 files** |

`QA_WINTER_01.md:66` labels C9 **PARTIAL**; `QA_WINTER_01.md:141` left the
alignment question open. `SP_08_season_test.md:157` also recorded the Winter
variant as `PENDING_DEP` because the swapped-name files were absent.

## 2. Backup

- `inbox/backup/t_season_overlay.gd.bak-SEASONPATH` — byte copy of the pre-edit
  file, 40,761 B, SHA-256
  `FBAAFF38B6EA467E20EDC7393172B7D89CDFBE07E5CC582B2F899E1D3E089F98`.
  Created before the first edit, per `variant3d/tools/AGENT_PROTOCOL.md:11`.

## 3. Before → after (complete diff vs backup)

```diff
@@ -56,8 +56,8 @@
-const WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_winter_atlas.manifest.json"  # SP-4
-const WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_winter_atlas.png"   # SP-4
+const WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.manifest.json"  # SP-4
+const WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.png"   # SP-4
```

Grep first, as instructed: the swapped name occurred **only** at `:59-60` in
this file (a repo-wide grep found the same stale name in docs/history and in
`inbox/backup/world3d_terrain.gd.bak-SP06SUN`, all outside my ownership and all
left untouched). The two values now match the on-disk artifacts and
`world3d_terrain.gd:272-273` exactly. Comments, spacing and the `# SP-4` tags
are unchanged. Every assertion, dependency guard, `PENDING_DEP` branch and
capture path is byte-identical. No test weakening; no donor read/copy.

### Additional, separately discovered defect (also in this owned file)

The first validation job exposed **5 pre-existing parse errors** at
`:212/245/468/514/979` — `var parsed := _read_json_variant(...)` /
`var summer_names := _read_json_variant(...)` inferring a type from an untyped
return (Godot 4.7.2, warnings-as-errors). They were present in the pre-edit
copy and in HEAD; they are unrelated to the filename values. Because a script
with parse errors can never reach its three-variant verdict, I applied the
sibling-atom pattern (`t_terrain_only.gd:291`, `t_smallmap_terrain.gd:190`,
`t_motion_capture.gd:535`): explicit `: Variant` on those 5 declarations. An
intermediate attempt with `-> Variant` on the helper was reverted (it merely
converted the error into a warnings-as-errors failure at the same 5 sites).

```diff
@@ -209,7 +209,7 @@ func _read_json_variant(path: String):
-	var parsed := _read_json_variant(path)
+	var parsed: Variant = _read_json_variant(path)
@@ -242,7 +242,7 @@
-		var parsed := _read_json_variant(path)
+		var parsed: Variant = _read_json_variant(path)
@@ -465,7 +465,7 @@
-	var parsed := _read_json_variant(WINTER_DICT_PATH)
+	var parsed: Variant = _read_json_variant(WINTER_DICT_PATH)
@@ -511,7 +511,7 @@
-	var parsed := _read_json_variant(DESERT_REMAP_PATH)
+	var parsed: Variant = _read_json_variant(DESERT_REMAP_PATH)
@@ -976,7 +976,7 @@
-	var summer_names := _read_json_variant(SUMMER_DICT_PATH)
+	var summer_names: Variant = _read_json_variant(SUMMER_DICT_PATH)
```

Total diff vs backup: 7 lines (2 assigned filename values + 5 behavior-neutral
type annotations). No condition, comparison, check message, status constant,
guard or capture code was altered.

Note: after the edits `git status --porcelain -- variant3d/tests/t_season_overlay.gd`
is empty — the repaired working file now matches HEAD, i.e. the pre-edit working
copy was stale relative to HEAD for both the filenames and the annotations.

## 4. Validation — variant runner only, no direct `godot`, no gates/ladder

All launches used
`python variant3d\tools\godot_runner.py run --id <id> --timeout … --max-wait 1800 -- --headless --path variant3d …`.

| Job id | Ticket | Command tail | Result |
|---|---|---|---|
| `seasonpath01-smoke` | 466 | `--check-only --script res://tests/t_season_overlay.gd` | **skipped** after 812 s wait: `serving=467`. Foreign queue event — tickets 456,457,458,465,469-473 of other workers were skipped in the same window; no stdout/stderr produced. Not a code result. |
| `seasonpath01-smoke-r2` | 484 | same | runner `failed`, exit 1; 5 `SCRIPT ERROR` "Cannot infer the type of parsed / summer_names" at `:212,245,468,514,979`. Pre-existing parse defect (see §3). |
| `seasonpath01-smoke-r3` | 492 | same | runner `failed`, exit 1; same 5 sites now "type inferred from Variant … (Warning treated as error)" from the discarded `-> Variant` experiment. |
| **`seasonpath01-smoke-r4`** | **499** | same | **runner `ok`, exit 0**, wait 22.15 s / run 10.42 s; stdout 75 B (Godot banner), stderr **0 B**; `smallmap_capture.py scan-stderr` → `script_error_lines: 0`. **SCRIPT ERROR == 0 — required smoke gate satisfied.** |
| `seasonpath01-atom` | 502 | `--script res://tests/t_season_overlay.gd` (headless, no `--check-only`) | runner `failed`, exit 1 (atom's own `quit(1)` on a failed check). stderr `SCRIPT ERROR == 0` (warnings only: image-import warnings, 3 ObjectDB leaks). Honest verdict **FAIL** — see §5. |

## 5. Honest atom verdict (not forced to PASS)

`variant3d/tests/results/t_season_overlay.json` (written by the atom itself;
untracked test artifact) and stdout of ticket 502:

- `verdict: FAIL`, `passed: false`, **31 evaluated-true / 3 false / 1
  skipped-or-pending**, `headless: true`, `capture_status: SKIP_CAPTURE`,
  harness `shared:res://tests/fixtures/_smallmap_harness.gd`.
- All three variants now reach `BUILT`; no `missing[]` entries; each has
  `uv2_out_of_range: 0`.
- **Winter is unblocked by this ticket**: `winter_dependency_state`,
  `winter_build_ok`, `winter_manifest_resolves`
  (`res://assets/terrain/atlas/tile_index_atlas_winter.manifest.json`,
  named_cells 124, layout 124), `winter_manifest_grid`, `winter_atlas_selection`
  (stats reports the same winter manifest path), `winter_uv2_entry_count`,
  `winter_uv2_x_in_range`, `winter_dict_124_entries`,
  `winter_entries_index_and_names`, `winter_names_resolve` and the cross-variant
  `uv2_x_summer_winter_identical` all PASS. Winter is no longer `PENDING_DEP`.
- The three FAILs are **desert-only** and unrelated to SEASON-TEST-PATH-01:
  - `desert_remap_parsed` — SP-3 direct = **38**, assertion expects 11,
    height_gated = 1 (expected 1). Confirmed by reading
    `variant3d/assets/terrain/atlas/desert_remap.json`: `len(remap)=38`.
  - `desert_remap_targets_resolve` — 39 unresolved records (expected 0).
  - `uv2_x_desert_remap_consistent` — 1252 mismatched cells (expected 0).
  Assertions were deliberately left byte-identical per the assignment; no
  re-baselining was attempted here.
- `script_error_scan_external` remains `PENDING_EXTERNAL_SCAN` by design. The
  external scan was run separately for ticket 502 and returned 0 lines, but the
  atom has no stderr API, so its own status stays pending (as specified).

The atom's three-variant verdict is therefore now *reachable*: **FAIL on stale
desert expectations, not on Winter**. No PASS was forced and no assertion was
weakened to obtain it.

## 6. Open questions

1. Should the SP-3 desert assertions (11 direct pairs / 0 unresolved / 0 UV2
   mismatches) be re-baselined against the current 38-pair remap? That is a
   separate ticket; this lane left them byte-identical by instruction.
2. Windowed capture is still unverified (headless run only, `SKIP_CAPTURE`).
   A three-PNG capture run would need the atom's `--<id>-png` args and a fresh
   job id; not done here (no full gates/ladder).
3. Provenance of the 993-B `tile_index_atlas_winter.png.import` sidecar remains
   open (`QA_WINTER_01.md:142`); not investigated.
4. The atom's own `script_error_scan_external` row stays pending by design even
   when an out-of-band scanner reports 0; a future ticket may choose to wire
   that in.

## 7. Summary

- Filename values at `t_season_overlay.gd:59-60` changed from
  `tile_index_winter_atlas.*` to `tile_index_atlas_winter.*`, exactly matching
  the delivered artifacts and `world3d_terrain.gd:272-273`
  (`QA_WINTER_01.md:94-103`).
- Backup: `inbox/backup/t_season_overlay.gd.bak-SEASONPATH`.
- Smoke: `seasonpath01-smoke-r4` / ticket 499 — `SCRIPT ERROR == 0`.
- Atom: `seasonpath01-atom` / ticket 502 — honest `FAIL` (31/3/1), Winter fully
  built and all Winter assertions PASS; remaining FAILs are pre-existing desert
  data/assertion drift.
- **No other file edited.** Only `variant3d/tests/t_season_overlay.gd` and this
  report were written by this ticket; the backup file was created as instructed,
  and the atom itself wrote its untracked result artifact
  `variant3d/tests/results/t_season_overlay.json`.
