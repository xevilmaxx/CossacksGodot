---
id: SP-05
task: "Optional atlas manifest path override in tile_atlas_loader.gd (season atlas hook)"
date: 2026-11-25
status: DELIVERED__ONE_OWNED_FILE_PLUS_BACKUP_PLUS_REPORT__NO_SHADER_EDIT__NO_ATLAS_REGEN__NO_DONOR_READ__NO_GATES
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/SP_05_loader_override.md"
owner_file: "variant3d/scripts/tile_atlas_loader.gd"
backup: "inbox/backup/tile_atlas_loader.gd.bak-SP05"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 2
visual_parity_claim: false
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; not opened, executed or copied this task — donor facts cited second-hand from SEASON-PLAN-01 / DEC-05 / DENV-01)"
---

# SP-05 — optional atlas manifest override (`tile_atlas_loader.gd`)

## 1. Scope and ownership

Implemented the SP-5 row of `SEASON_PLAN_01.md:190`: add a `manifest_path` config
key/override parallel to `single_atlas_path` (`:68`, `:103-104` in the pre-edit file),
consume it in `_load_grid()` and `_load_array()`, and keep the V7-85 default and the
`single → split → array` fallback byte-identical.

**Files touched by this ticket (exactly three):**

| Path | Action |
|---|---|
| `variant3d/scripts/tile_atlas_loader.gd` | edited (EXCLUSIVE owner) |
| `inbox/backup/tile_atlas_loader.gd.bak-SP05` | created — exact pre-edit copy |
| `docs/coord_swarm_2026-11-25/reports/SP_05_loader_override.md` | created (EXCLUSIVE owner) |

**No other file was edited.** No shader edit; no atlas/PNG regeneration; no JSON created;
no `world3d_terrain.gd`, `game.gd`, `main.gd`, config, test or harness edit; no donor
read or copy; no gates, no ladder, no direct `godot`. The only Godot launch was the
one runner job in §5.

## 2. Sources read (all read-only)

| # | Source | Contribution / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md:159-174, 190, 211` | SP-5 ticket text; "index-preserving swap means no shader edit" decision; DALPHA-02 shader contract (observed) |
| S2 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md:405, 417-439` | 124 preset indices per season; Winter uses the same indices with `*_winter` names (observed, donor via DEC-05) |
| S3 | `inbox/backup/tile_atlas_loader.gd.bak-SP05` (pre-edit loader, read in full) | exact before state (observed) |
| S4 | `variant3d/scripts/tile_atlas_loader.gd` (owned, read in full before and after) | after state (observed) |
| S5 | `variant3d/tools/godot_runner.py:25-33, 349-437, 571-576` | the only legal launch path; `--id`/`--timeout`/`--max-wait`/`--` argument form (observed) |
| S6 | `docs/coord_swarm_2026-11-25/reports/MMJUMP_01_minimap_jump.md:95-101`, `HUD_01_minimap.md:89`, `TRN_GEOM_implementation.md:112` | precedent for `--headless --path variant3d --check-only --script res://…` smoke form and `SCRIPT ERROR == 0` reporting (observed) |

**`ATLAS_01_transport.md`: NOT LANDED.** A recursive glob for `**/ATLAS*` under the
repository root returned no files, so there is no ATLAS-01 report to cite. This ticket
does not depend on it; transport choice remains an open question (§8).

## 3. Before → after (exact change)

### 3.1 Added override surface

**Before** (`tile_atlas_loader.gd.bak-SP05:66-75, 103-105`):

```gdscript
const CONFIG_SINGLE_PATH_KEY := "single_atlas_path"
const CHUNK := 1 << 20
...
var single_atlas_path: String = SINGLE_ATLAS
...
	if cfg.has(CONFIG_SINGLE_PATH_KEY):
		single_atlas_path = str(cfg[CONFIG_SINGLE_PATH_KEY])
	set_mode(chosen)
```

**After** (`tile_atlas_loader.gd:76-86, 115-118`):

```gdscript
const CONFIG_SINGLE_PATH_KEY := "single_atlas_path"
const CONFIG_MANIFEST_PATH_KEY := "manifest_path"  # SP-5; optional override
const CHUNK := 1 << 20
...
var single_atlas_path: String = SINGLE_ATLAS
# SP-5: optional manifest override, default is the unchanged V7-85 Summer path.
var manifest_path: String = V785_MANIFEST
...
	if cfg.has(CONFIG_SINGLE_PATH_KEY):
		single_atlas_path = str(cfg[CONFIG_SINGLE_PATH_KEY])
	if cfg.has(CONFIG_MANIFEST_PATH_KEY):
		manifest_path = str(cfg[CONFIG_MANIFEST_PATH_KEY])
	set_mode(chosen)
```

`V785_MANIFEST` is still the literal
`res://assets/terrain/atlas/tile_index_atlas.manifest.json` (`:71`), so the default
path is unchanged. The override is read from the same config dictionary already used
for `single_atlas_path`; `TileAtlasLoader.new()` with no dict, or with a dict lacking
`manifest_path`, behaves exactly as before (observed by diff, derived).

### 3.2 Consumed in the two manifest-reading sites

**Before** (backup `:297-303`, `:390-392`):

```gdscript
func _load_grid() -> void:
	# Grid/packing comes from V7-85's manifest, never from a hardcoded table.
	var v785 := _read_json(V785_MANIFEST)
...
func _load_array() -> bool:
	var manifest := _read_json(V785_MANIFEST)
	if manifest.is_empty():
		return _fail("V7-85 manifest unavailable: " + last_error)
```

**After** (`tile_atlas_loader.gd:310-316`, `:403-407`):

```gdscript
func _load_grid() -> void:
	# Grid/packing comes from the selected manifest (default: V7-85's), never
	# from a hardcoded table. SP-5: manifest_path is caller-overridable.
	var v785 := _read_json(manifest_path)
...
func _load_array() -> bool:
	# SP-5: same manifest override as _load_grid(); default V785_MANIFEST.
	var manifest := _read_json(manifest_path)
	if manifest.is_empty():
		return _fail("V7-85 manifest unavailable: " + last_error)
```

The error string was deliberately left byte-identical. No index, slot, grid value,
mask path or UV math was touched.

### 3.3 Deliberately NOT changed

| Site | Why |
|---|---|
| `_load_split()` `:336` still `_read_json(SPLIT_MANIFEST)` | split mode has its own parts descriptor; SP-5 acceptance names only grid + array. Keeping it unchanged preserves the fallback chain (observed) |
| `load()` fallback `:173-200`, `_load_single()` `:280-290`, `_reset()` `:142-151` | no hunk in the diff — single → split → array order, warnings and reset semantics are byte-identical |
| `get_reassembly_info()` `:267-274` | still reports `mode/bytes/sha256/array_layers/single_path`; adding a key would change a stable API payload, so SP-6 reports the selected manifest from its own BIOME table instead |
| `_load_masks()`, `tile_uv()`, `tile_layer()` | no shader/UV contract change (SEASON-PLAN-01:211, B5) |

### 3.4 Diff size and hashes

`git diff --no-index <backup> <edited>` produced **6 hunks**: one header comment, four
functional additions/substitutions and their comments, plus the `_load_array` comment.
Net functional lines: `+1 const`, `+1 var`, `+2 in _init`, `2 × _read_json(V785_MANIFEST)
→ _read_json(manifest_path)`. No deletions of executable code.

| File | SHA-256 |
|---|---|
| `inbox/backup/tile_atlas_loader.gd.bak-SP05` (pre-edit) | `6CDF6B8946E009ADF43DA71953A5D5AF805005739D068D6ADE00B45FDF82BF0F` |
| `variant3d/scripts/tile_atlas_loader.gd` (post-edit) | `9B82A48DF4F8A7DD6FF6AD1C99DBC6A57AE1C374603AFCC243128643C5F23978` |

Sizes: backup 17,018 B → edited 17,986 B. The backup hash equals the pre-edit loader
hash measured before any edit (observed, 2 passes).

## 4. Backup

`inbox/backup/tile_atlas_loader.gd.bak-SP05` was copied from the loader **before** the
first edit; its SHA-256 is identical to the pre-edit baseline. Restore is a plain
file copy back over `variant3d/scripts/tile_atlas_loader.gd` if SP-5 is rejected.

## 5. Smoke check (runner only)

**Command (one launch, via the runner only — no direct `godot`):**

```powershell
python variant3d\tools\godot_runner.py run --id sp05-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/tile_atlas_loader.gd
```

**Result** (`variant3d/.godot_queue/results/00000409.json`, plus its spool dir
`00000409_sp05-smoke/`):

| Field | Value |
|---|---|
| ticket / id | 409 / `sp05-smoke` |
| argv | `--headless --path variant3d --check-only --script res://scripts/tile_atlas_loader.gd` |
| wait / run | 127.70 s / 5.88 s |
| status / exit | `ok` / `0` |
| stdout | 75 B — `Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org` |
| stderr | **0 bytes** |
| `SCRIPT ERROR` occurrences in stderr | **0** |

**`SCRIPT ERROR == 0`** — confirmed (observed). No gates, no ladder, no test atom,
no screenshot, no atlas regeneration. `--check-only` parses/validates the script; it
does not execute a runtime load, so the winter-atlas path itself stays UNVERIFIED
until SP-4 + SP-6 land (see §6/§8).

## 6. Acceptance mapping

| SP-5 acceptance (`SEASON_PLAN_01.md:190`) | Result |
|---|---|
| `TileAtlasLoader.new("single", {"manifest_path":…, "single_atlas_path":…})` loads the winter atlas | **capability delivered**: both keys are consumed; end-to-end winter load is blocked until SP-4 emits the winter manifest/PNG (UNVERIFIED by design) |
| Default path stays `V785_MANIFEST` so Summer is byte-identical | yes — `:86`, `:71`; no default-path hunk |
| Fallback chain unchanged | yes — no hunk in `load()`/`_load_single()`/`_load_split()`/`_reset()`; `_load_split()` still uses `SPLIT_MANIFEST` |
| No new indices | yes — index/slot code untouched |
| No shader edit | yes — no `.gdshader` file touched; index-preserving swap rationale at S1 `:171-173`, `:211` |

## 7. What remains for SP-4 / SP-6

**SP-4 (Winter atlas, not this ticket).** Build
`variant3d/assets/terrain/atlas/tile_index_winter_atlas.manifest.json` + PNG with the
same schema (`atlas.grid = [16,8]`, 124 `layout` entries at indices 0–123,
`source_png` pointing at the already-shipped `winter0..26` / reused `desert1..12`
PNGs, same label set), record SHA-256, keep the 4 spare cells spare, and copy the
GitHub >100 MB / LFS caveat from the loader header `:19-22`. Depends on SP-2's
124-entry Winter dictionary. No donor read/copy. Winter art is **unpacked, not
missing** (`SEASON_PLAN_01.md:68-77`, B1 `:206`).

**SP-6 (render hook, not this ticket).** In co-owned `world3d_terrain.gd`, map
BIOME → `{manifest, single_atlas_path, dict}`; pass both keys to `loader_script.new(...)`
(the current constructor call at `world3d_terrain.gd:289` passes only `atlas_mode`);
build `_tile_index_name` from the selected manifest (`:870-878`); apply SP-3's
`desert_remap.json` to `tid` before `uvs2[i]` (`:924-992`); report the selected
manifest/atlas in stats (`:1094`, `:1170-1179`). **Sequence after TRN-FACE merged
and re-read that file immediately before editing** (`SEASON_PLAN_01.md:214`, B8).
No shader edit: DALPHA-02's `alpha_patch_uv()` stays keyed on unchanged indices.

## 8. Open questions

1. **ATLAS-01 transport** — Git LFS vs `atlas_parts_winter/` remains undecided
   (`SEASON_PLAN_01.md:253`, Q4). No ATLAS-01 report has landed. This ticket is
   transport-agnostic: it only changes which manifest JSON is read.
2. **Winter manifest schema parity** — SP-4 must confirm the generated manifest has
   the same `atlas.grid` and `layout` fields; SP-5 does not validate schema beyond
   the existing `_load_grid()`/`_load_array()` reads (UNVERIFIED until SP-4 lands).
3. **Exposure surface** — I added a config-dict key only, mirroring
   `single_atlas_path`. A ProjectSettings key or CLI flag is **not** added; if SP-6
   needs one, that is a separate coordinated change (no caller in the port currently
   passes `manifest_path` — grep over `variant3d/` observed).
4. **Diagnostics** — `get_reassembly_info()` deliberately still omits `manifest_path`
   to keep the stable payload byte-identical. If a future ticket wants the loader to
   report its selected manifest, that is an API change needing its own ticket.
5. **Four donor-unaliased winter cells** (`winter18/23/24/26`, plus green `winter25`)
   remain UNVERIFIED for content choice (`SEASON_PLAN_01.md:243-245`, Q1). SP-2/SP-4
   must record them, not invent replacements.
6. **Donor runtime activity** of `;`-prefixed season scripts remains UNVERIFIED
   (`SEASON_PLAN_01.md:262`, Q8); implementation is donor intent, not runtime parity.

## 9. Summary

SP-5 added a single optional `manifest_path` field to `tile_atlas_loader.gd`,
parallel to the existing `single_atlas_path`: it defaults to `V785_MANIFEST` and is
read from the constructor config dict, then consumed by `_load_grid()` and
`_load_array()`. Default path, index math, masks, split-mode manifest and the whole
`single → split → array` fallback chain are unchanged; no shader, atlas, JSON, donor
file or other owned-by-others file was touched. Backup taken before the edit.
Smoke check: runner ticket 409 `sp05-smoke`, status `ok`, exit 0, stderr 0 bytes,
`SCRIPT ERROR == 0`. What remains is SP-4 (emit the Winter
manifest/PNG) and SP-6 (BIOME → both paths in `world3d_terrain.gd`), both outside
this ticket's ownership.

*End of SP-05. One owned code file, one backup, one report; no other file edited.*
