---
id: SP-06
task: "SP-6 RENDER-HOOK — season -> atlas/manifest selection + SP-3 desert remap in world3d_terrain.gd (index-preserving, no shader edit)"
date: 2026-11-25
status: DELIVERED__ONE_OWNED_FILE_PLUS_TWO_BACKUPS_PLUS_REPORT__NO_SHADER_EDIT__NO_TEST_EDIT__NO_DONOR_COPY__NO_GATES
scope: "Exclusive owner of variant3d/scripts/world3d_terrain.gd and this report. Donor READ-ONLY (no donor file opened, executed or copied — all donor path:line facts are cited second-hand from SEASON-PLAN-01 / DENV-01 / ATLAS-01 / LIGHT-02). No shader, loader, data.gd, JSON, test, harness, camera/minimap or app/** file edited; no git add/commit by this worker; no LFS action; no gates, no ladder, no direct godot, no test weakened."
owner_files:
  - "variant3d/scripts/world3d_terrain.gd"
  - "docs/coord_swarm_2026-11-25/reports/SP_06_renderer_hook.md"
backups:
  - "inbox/backup/world3d_terrain.gd.bak-SP06"
  - "inbox/backup/world3d_terrain.gd.bak-SP06SUN"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/SP_06_renderer_hook.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 3
visual_parity_claim: false
parity_guard: "No donor GPU A/B and no visual comparison were run. All structural claims are derived from code/hashes; every donor-runtime and LFS/OID statement is explicitly UNVERIFIED or COORD-owned."
---

# SP-06 — season → atlas hook in `world3d_terrain.gd`

## 1. Goal and design decision

Execute ticket **SP-6 RENDER-HOOK** (`SEASON_PLAN_01.md:191`) plus its two follow-ups:

1. Map the season (SP-1 enum: summer 0 / winter 2 / desert 3; value 1 **UNVERIFIED**) to
   **both** the manifest path (SP-5 `manifest_path` override) and the atlas PNG path
   (SP-5 `single_atlas_path`).
2. Build the name→index dictionary from the **selected** manifest.
3. Apply SP-3's desert name remap to tile ids **before** `UV2.x` is written.
4. Report both selected paths in `stats` (`atlas_path`, `atlas.manifest`, plus a new
   `season` / `desert_remap` provenance block).
5. **Index-preserving swap ⇒ NO shader edit** (`SEASON_PLAN_01.md:159-174`, B4/B5;
   DALPHA-02's `alpha_patch_uv()` stays keyed on unchanged indices).
6. Path correction from the SP-4 follow-up: use the **actual** SP-4 filenames
   `tile_index_atlas_winter.*`, not the planned `tile_index_winter_atlas.*`.
7. LIGHT-02 follow-up: align `SUN_LIGHTVEC` with `normalize(vec3(P.x,P.y,P.z))`.

Every mesh invariant is untouched: one surface, `w*h` verts / `(w-1)*(h-1)*2` tris
(4,096 / 7,938 at 64²), `UV2` pair count, atlas grid `(16,8)`, `face_hist`, shadows OFF,
water bindings, donor light colours, and all RELIEF-01 stamp code (verified byte-identical,
§6). Summer behavior and all pre-existing `stats` values are unchanged.

---

## 2. Sources read (all read-only; none edited by this ticket)

| # | Source | Contribution / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | SP-6 row `:191`; derived mapping `:159-174`; blockers B1–B10 `:202-217`; label set `:220-238`; Q1–Q8 `:241-263` — observed |
| S2 | `docs/coord_swarm_2026-11-25/reports/SP_01_season_enum.md` | `data.gd:227-228` `SEASON_ENUM`/`SEASON_DEFAULT`; value 1 UNVERIFIED — observed |
| S3 | `docs/coord_swarm_2026-11-25/reports/SP_02_winter_dictionary.md` | `winter_aliases.json` 124 entries; `winterN` number is a filename, not an index — observed |
| S4 | `docs/coord_swarm_2026-11-25/reports/SP_03_desert_remap.md` | `desert_remap.json` schema `remap` (11 direct) + `height_gated` (1, DATA_ONLY); targets packed at 111–122 / 93–98 / 123 — observed |
| S5 | `docs/coord_swarm_2026-11-25/reports/SP_05_loader_override.md` | loader `manifest_path` / `single_atlas_path` config keys (`:77`, `:86`, `:114-117`, `:313`, `:405`) — observed |
| S6 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | donor season chain §3–§4: `terrain.lib:12-15`, `terrain.presets:2-6,134-263`, `texturemap.inc:525-526,605-606`, `miscext.script:1429-1543`, `:1547-1625`, `colors.lib:94-101`, `map.script:250`, `dmscript.global:237`, `dogenerate.inc:4,2079`; runtime UNVERIFIED (Q6) — observed (via S1/S6) |
| S7 | `docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md` | single/split/array contract, V7-85 manifest grid `(16,8)`, desert ids 111–122 packed, winter art unpacked at audit time — observed |
| S8 | `docs/coord_swarm_2026-11-25/reports/RELIEF_01_stamping.md` + owned file header/constants `/:185-243`, `/:461-...` | blocks preserved byte-identically (§6) — observed |
| S9 | `docs/coord_swarm_2026-11-25/reports/LIGHT_02_light_space.md` | verdict §3.4/§5.4: `sun_world = normalize(vec3(P.x,P.y,P.z))`, `P=light.cfg:27-29`; `:267-275` flags the old `SUN_LIGHTVEC` — observed |
| S10 | `variant3d/scripts/world3d_terrain.gd` (EXCLUSIVE owner) | pre-edit state (`inbox/backup/world3d_terrain.gd.bak-SP06`, 69,635 B, SHA-256 `B4B96538…F604`) and post-edit state — observed |
| S11 | `variant3d/assets/terrain/atlas/` (READ-ONLY) | `tile_index_atlas_winter.png` 124,463,306 B and `…manifest.json` 79,837 B verified on disk; `desert_remap.json`, `winter_aliases.json`, V785 manifest/PNG — observed, 3 passes |
| S12 | `variant3d/tools/godot_runner.py` | the only legal Godot launch path; `--id` / `--timeout` / `--max-wait` / `--` form — observed |

SP-8's `t_season_overlay.gd` was **read only** (never edited): its `_source_has(TERRAIN_PATH,"BIOME")`
and `"desert_remap"` probes are satisfied by this edit, but its own winter constants still use
the obsolete SP-4 name (§8 O1).

---

## 3. Donor citation ledger (all second-hand; donor not opened)

| Donor `path:line` | Literal / meaning | Label |
|---|---|---|
| `scripts\lib\map.script:250` | `gen.season` default `0` (Summer) — `SEASON_DEFAULT_NAME` | observed (S1/S6) |
| `scripts\dmscript.global:237` | `gc_MaxSeasonCount = 3` → 0/1/2 implied; value `1` **UNVERIFIED** | observed + UNVERIFIED |
| `scripts\lib\miscext2.script:3318-3323` | UI toggle only `0 ↔ 2` | observed |
| `scripts\dogenerate.inc:4`, `:2079` | desert branch `gen.season = 3` | observed |
| `terrain\tiles\terrain.lib:12-15` | Summer/Autumn/Spring → `Summer`; Winter → `Winter` (set selection) | observed |
| `terrain\tiles\terrain.presets:2-6`, `:134-263` | two **124-entry** sets, same indices, Winter `*_winter` names | observed |
| `scripts\common.inc\texturemap.inc:525-526,605-606` | append `_winter` to tile names at season 2 | observed; runtime **UNVERIFIED** (`;` prefix) |
| `scripts\lib\miscext.script:1447-1502` | `_misc_SetDesert` 11 explicit name pairs → SP-3 `remap` | observed; runtime **UNVERIFIED** |
| `miscext.script:1504-1505` | `rock8` height gate → SP-3 `height_gated`, **DATA_ONLY_NOT_EXECUTED** | observed; runtime **UNVERIFIED** |
| `miscext.script:1513-1520`, `:1531-1537` | `koef=0.8`, mine suffix `s`, env destruction — **not executed** (SP-6 is index-only) | observed; data only |
| `miscext.script:1547-1625` | `_misc_SetSeason` swap entry — donor intent only | observed; runtime **UNVERIFIED** |
| `env\colors\colors.lib:94-101` | winter/desert tables override only `ShadowBlendingDiffuse` → **PORT APPROXIMATION**, not a port colour change | observed |
| `env\lights\light.cfg:26-31` | sun `Position = (-0.344731,+0.938701,0,1)` — Y-up world vector | observed (S9) |

**No parity claim:** all donor swap mechanisms live in `;`-prefixed donor script lines;
the port implements donor **intent** as a PORT APPROXIMATION (SEASON-PLAN-01 B6/Q8,
DENV-01 Q6). No donor GPU A/B was run.

---

## 4. Before → after (final on-disk line numbers)

Backups taken **before** each edit stage:
`inbox/backup/world3d_terrain.gd.bak-SP06` (SHA-256 `B4B965382F8E745500D7643C1FA035DB089E16E359CF8C821A45175F2D3BF604`,
69,635 B) and `inbox/backup/world3d_terrain.gd.bak-SP06SUN`
(SHA-256 `D20EEAE93F667F99FEDB5A75AB318FF8482D0EFCF3B5C644FDA815E10290943A`,
79,939 B — byte-identical to the file at the moment of the LIGHT-02 follow-up).

### 4.1 LIGHT-02 follow-up — one line, `world3d_terrain.gd:138` (no line drift)

```gdscript
# before (bak-SP06SUN:138)
const SUN_LIGHTVEC := Vector3(SUN_POS.x / 4.0, SUN_POS.z / 2.0, SUN_POS.y)  # water.dev.vert:22, then Z-up->Y-up
# after (:138)
const SUN_LIGHTVEC := Vector3(SUN_POS.x, SUN_POS.y, SUN_POS.z)  # LIGHT-02 verdict: normalize(vec3(P.x,P.y,P.z)), light.cfg:26-31; reports/LIGHT_02_light_space.md §3.4/§5.4 — Y-up identity map, water-local /4,/2 dropped; |P|=0.99999999 and _make_environment() normalizes at :1107, shader normalizes donor_sun_position; PORT APPROXIMATION, no donor GPU parity claim
```

`P` is unit length to 8 digits (`|P| = 0.99999999`, S9 §3.4), the node already calls
`.normalized()` at `:1107`, and the shader normalizes its own `donor_sun_position` — so the
`DonorSun` direction and the shader now share the same donor-grounded world vector. No new
numeric constant was introduced; `const` form is retained. Stale `[donor Z-up]` comments at
`:122`/`:1579` were **left byte-identical** per the follow-up instruction (see O3).

### 4.2 SP-6 season table — `world3d_terrain.gd:257-280`

```gdscript
# new, after ATLAS_MODE_* (was :255 in the backup)
const DATA_SCRIPT = preload("res://scripts/data.gd")  # SP-1 BIOME / SEASON_ENUM
const SUMMER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas.png"
# SP-4 LANDED with these exact on-disk names (tile_index_atlas_winter.*), NOT the
# planned tile_index_winter_atlas.* of SEASON_PLAN_01.md:189 — path corrected here
# to the verified artifact bytes. No rename/copy and no git add/LFS action here.
const WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.manifest.json"   # :272
const WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.png"                # :273
const DESERT_REMAP_PATH := "res://assets/terrain/atlas/desert_remap.json"                           # :274
const SEASON_DEFAULT_NAME := "summer"                                                              # :275
const SEASON_ATLAS: Dictionary = {                                                                 # :276-280
	"summer": {"enum": 0, "manifest_path": V785_MANIFEST_PATH, "atlas_path": SUMMER_ATLAS_PATH},
	"winter": {"enum": 2, "manifest_path": WINTER_MANIFEST_PATH, "atlas_path": WINTER_ATLAS_PATH},
	# Desert has NO separate donor preset section: Summer atlas stays bound.
	"desert": {"enum": 3, "manifest_path": V785_MANIFEST_PATH, "atlas_path": SUMMER_ATLAS_PATH},
}
```

**Path correction (explicit):** the draft used `tile_index_winter_atlas.manifest.json` /
`.png` from the plan (`SEASON_PLAN_01.md:189`) and SP-8 (`t_season_overlay.gd:59-60`).
Those names do **not** exist on disk. SP-4 actually wrote
`tile_index_atlas_winter.manifest.json` (79,837 B) and `tile_index_atlas_winter.png`
(124,463,306 B). Only my owned constants were corrected; **no SP-4 file was renamed,
copied, added, committed or LFS-resolved**.

### 4.3 Season field and helpers — `:312`, `:397-446`

- `var season: String = SEASON_DEFAULT_NAME` (`:312`) — explicit field wins; otherwise
  `_effective_season()` (`:397`) reads `DATA_SCRIPT.BIOME` (`data.gd:199` ← `config.gd:546`),
  normalizes case and unknown values to Summer, and has **no value-1 path**.
- `_season_file_exists()` (`:408`) uses `FileAccess.file_exists()` on the `res://` path
  **and** `ProjectSettings.globalize_path()` (exported-build cover).
- `_select_season_atlas()` (`:413`) requires **both** manifest and PNG to exist; on a
  missing/unparseable pair it substitutes the Summer pair in one step and writes a labelled
  `_season_fallback` string — never throws, never binds a mixed index dictionary/texture.
- `_load_desert_remap()` (`:430`) loads only SP-3's 11 direct `source_index → atlas_index`
  pairs; the height-gated `rock8` row stays `DATA_ONLY_NOT_EXECUTED`.

### 4.4 Loader selection in `_load_atlas()` — `:559-603`

- Before: `_manifest = _read_json(V785_MANIFEST_PATH)` and
  `_atlas_loader = loader_script.new(atlas_mode)`.
- After: resolve season (`:567`), select both paths (`:569-572`), read the selected manifest
  (`:573`), fall back **with label** if it fails to parse (`:575-582`), load SP-3 data
  (`:582`), and pass SP-5's two config keys only when the paths differ from the Summer
  defaults (`:594-602`). Summer keeps the original no-config constructor call verbatim.
  Only one atlas is ever bound (SEASON-PLAN-01 B2 memory).

### 4.5 Desert remap immediately before UV2 — `:1244`, `:1332-1346`

```gdscript
var season_is_desert: bool = (_season_resolved == "desert")          # :1244
...
if season_is_desert and tiles_available and _desert_remap.has(tid):  # :1340
	var remapped: int = int(_desert_remap[tid])
	if remapped >= 0 and remapped <= max_tile_id:
		tid = remapped
		_desert_remap_cells += 1
uvs2[i] = Vector2(float(tid), float(face))                            # :1346 (unchanged line)
```

Applied after the donor face/shore branches and immediately before the existing UV2 write;
Summer/Winter never enter the branch. Tileblock bytes are never mutated, indices stay inside
the 124-cell atlas, and DALPHA-02's shader is untouched.

### 4.6 Stats — `:1424-1430`, `:1475`, `:1558`, `:1604-1630`

- `atlas_path` is now `_season_manifest_path + " (" + atlas_path_note + ")"`; for Summer
  the note is the **exact legacy string** `"V7-85 manifest; V7-91 loader transport"`.
- `atlas.manifest` (`:1558`) is the selected manifest path (Summer == legacy V785 value).
- New `stats["season"]` (`:1604`) carries `selected`, `field`, `biome`, donor `enum`,
  the enum/value-1 note, `manifest_path`, `atlas_path`, `fallback`, donor citations and the
  PORT APPROXIMATION / UNVERIFIED label.
- New `stats["desert_remap"]` (`:1619`) carries the JSON path, direct-entry count, remapped
  cell count, donor citations, the `koef=0.8` DATA_ONLY label and the no-parity label.
- All pre-existing `stats` keys and values (grid, relief_grid, mesh counts, face_hist,
  light_cols, water, donor_references, timing_ms, …) are unchanged.

---

## 5. Backups and hashes

| File | Size | SHA-256 | Note |
|---|---:|---|---|
| `inbox/backup/world3d_terrain.gd.bak-SP06` | 69,635 B | `B4B965382F8E745500D7643C1FA035DB089E16E359CF8C821A45175F2D3BF604` | exact pre-SP-6 source |
| `inbox/backup/world3d_terrain.gd.bak-SP06SUN` | 79,939 B | `D20EEAE93F667F99FEDB5A75AB318FF8482D0EFCF3B5C644FDA815E10290943A` | exact pre-LIGHT-02 source; matches S9's recorded `d20eeae93f667f99` |
| post-edit `variant3d/scripts/world3d_terrain.gd` | 79,939 B | `12667AE58A4AC6D88C1BE3190FDC2B407C33CDB4` | one-line SUN diff from `bak-SP06SUN`; 190 insertions / 4 deletions from `bak-SP06` |

Restore is a plain file copy from either backup. Note: an unrelated worker's `step` commit
(`49aa81f7`, 10:55:05 +0100) picked up this owned file while the LIGHT-02 smoke was queued;
the worktree blob equals HEAD (`12667ae5…`). **This worker did not run `git add` or commit.**

---

## 6. Invariant verification

| Check | Result |
|---|---|
| RELIEF-01 constants/tables (`RELIEF_COARSE_W` → `const SPLAT_PATH`) | **byte-identical** to backup |
| RELIEF-01 `apply_relief_grid` + marker reader + build stamp block + `stats.relief_grid` | **byte-identical** to backup (independent segment compare, 4/4 PASS) |
| `_relief_applied` reset in `invalidate()` | 1 occurrence in backup, 1 in edited file |
| Mesh builder (verts/tris/indices/UV2/1 surface) | no hunk outside the SP-6 desert-remap insert; face/shore/light blocks unchanged |
| Atlas grid `(16,8)` | read from selected manifest; SP-4 winter manifest declares `[16,8]`, `named_cells=124` |
| `face_hist` / shadow OFF / water bindings | code byte-identical; no new hunk in those regions |
| `get_minimap_box` / CAM-RV-01 | no such symbol in this file; camera/minimap files untouched; only pre-existing comment/stats citations of `camera.cfg` remain |
| Shader / loader / data.gd / JSON / tests / `app/**` | **no edit by this worker** |
| Summer byte-identity | default paths equal loader defaults ⇒ original constructor call and exact legacy `atlas_path` string retained; no remap branch entered |

---

## 7. Smoke checks (variant runner only — no direct `godot`, no gates, no ladder)

| Job id | Ticket | argv tail | Status | Exit | stderr | `SCRIPT ERROR` | `Parse Error` |
|---|---:|---|---|---:|---:|---:|---:|
| `sp06-smoke` | 431 | `--headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd` | `ok` | 0 | 0 B | **0** | 0 |
| `sp06-smoke-pathfix` | 443 | same (after SP-4 filename correction) | `ok` | 0 | 0 B | **0** | 0 |
| `sp06-sun-smoke` | 457 | same (after LIGHT-02 one-line fix) | **skipped** (queue waited 1,632 s; `serving=458`) | null | 0 B | n/a | n/a |
| `sp06-sun-smoke-r2` | 480 | same (retry, `--max-wait 5400`) | `ok` | 0 | 0 B | **0** | 0 |

Ticket details and independent records are in §12 and the runner spools below. Runner spools:
`variant3d/.godot_queue/results/00000431_sp06-smoke/`,
`00000443_sp06-smoke-pathfix/`, `00000457_sp06-sun-smoke/` (skipped, no run),
`00000480_sp06-sun-smoke-r2/`; result JSONs `00000431.json`, `00000443.json`,
`00000457.json`, `00000480.json`. Godot `4.7.2.stable.official.ed1daf0bf`; stdout is the
75-byte banner only on each executed job.

**Validation pass count: 3 of 3 executed smoke jobs PASS** (`SCRIPT ERROR == 0`, exit 0,
stderr 0 B each); one additional submission (`sp06-sun-smoke`, ticket 457) was **skipped by
the queue** after a 1,632 s wait and is not counted as a pass or a failure. No test atom was
executed, so **no test assertion count is claimed** — running `t_terrain3d.gd` would write
another owner's tracked `tests/results/t_terrain3d.json`, which this ticket's ownership
forbids. `--check-only` parses/validates; it does not execute a runtime atlas load (SP-8
remains the runtime atom).

---

## 8. Fallback behaviour when an atlas is absent

- **Winter atlas absent** (pre-SP-4 condition, still guarded): `_select_season_atlas()`
  sees either file missing → selects the Summer manifest **and** Summer PNG together,
  sets `stats.season.fallback` to
  `"SP-4 winter manifest/atlas absent — SP-6 fell back to the V7-85 Summer pair (index-preserving; winter art UNVERIFIED)"`,
  and `atlas_path_note` carries the same label. No crash, no mixed dictionary/texture,
  no invented art, Summer indices preserved.
- **Manifest exists but unparseable**: `_load_atlas()` (`:575-582`) applies the same labelled
  fallback.
- **Winter now present** (SP-4 landed): both files exist; their names are the corrected
  `tile_index_atlas_winter.*`; the winter manifest keeps Summer base names at indices 0–123
  (read-only check), so cliff/shore name lookups still resolve.
- **Desert**: no second atlas by design (DENV-01 §4); Summer manifest/PNG stay bound and
  cells change only through SP-3's 11 direct index remap before UV2.
- **Unknown season / enum 1**: normalized to Summer; no code path or guessed art.

## 9. Explicit UNVERIFIED / PORT APPROXIMATION labels

1. **Donor runtime activity** of all `;`-prefixed `.inc`/`.script` season lines is UNVERIFIED
   (SEASON-PLAN-01 B6/Q8; DENV-01 Q6). This implements donor intent, not proven runtime.
2. **Season value `1`** is UNVERIFIED (`gc_MaxSeasonCount=3` implies 0/1/2); no mapping.
3. **Cloud `season=2`** maps to no readable season mechanism (DENV-01 §2.7/Q4); not encoded.
4. **Desert height `koef=0.8`, mine suffix `s`, `rock8` gate** are data-only text observations,
   runtime UNVERIFIED; SP-6 does no height scaling (SEASON-PLAN-01 Q2).
5. **Lighting-table difference** (`colors.lib:94-101`) only overrides
   `ShadowBlendingDiffuse`; no port colour compensation was added — PORT APPROXIMATION.
6. **Atlas packing `(16,8)` / V7-85 order** is `APPROX_ATLAS_PACKING` (donor `tsDouble`/
   `ttExtended` engine-side); no visual parity claim.
7. **LIGHT-02** mapping is a donor-grounded world-vector derivation; the fixed-function GL
   submit and any donor GPU comparison remain UNVERIFIED; no donor parity claimed.
8. **LFS/OID choice for the winter PNG** (HEAD tracks a 3-line LFS pointer
   `oid 6b251045…`, 74,986,953 B; regenerated local PNG 124,463,306 B) is **COORD's
   decision**. This worker did not `git add`, commit, fetch, or resolve LFS.
9. **No donor GPU A/B** exists; all structural checks are code/hash based.

## 10. Open questions (do not guess)

1. **O1 — SP-8 path mismatch (handoff, not edited).** `t_season_overlay.gd:59-60` still
   binds `tile_index_winter_atlas.manifest.json` / `.png`, which do not exist on disk. Its
   winter dependency gate will therefore report `PENDING_DEP` even though SP-4 and this
   hook have landed. That file is outside SP-6 ownership; its owner/COORD must correct the
   two constants to `tile_index_atlas_winter.*`. No test was weakened here.
2. **O2 — SP-8 selector**: the atom drives `C3Data.BIOME`; this hook reads it through
   `DATA_SCRIPT.BIOME` when the public `season` field is left at its Summer default — the
   effect is asserted through `stats` + UV2, with no test edit.
3. **O3 — stale donor-Z-up comments**: `world3d_terrain.gd:122` and `:1579` still say
   `[donor Z-up]` / `SUN_POS, donor Z-up`, corrected by LIGHT-02 §6 but **left untouched**
   because the follow-up required every other line byte-identical. COORD may schedule a
   comment-only correction.
4. **O4 — transport drift**: `split` mode still reads the fixed `SPLIT_MANIFEST` and the
   `array` mode's second split loader supplies the 2D sampler (existing PORT LIMITATION).
   A Winter split-parts transport would be a separate COORD/loader ticket; B2 forbids
   accumulating both atlases.
5. **O5 — winter index dictionary**: the SP-4 manifest maps indices to Summer base names
   with winter `source_png`; `winter18/23/24/26` remain donor-unaliased and `winter25` is
   green grass (SP-02 Q1); no replacement was invented here.
6. **O6 — enum 1 / cloud `season=2`** remain UNVERIFIED; no code path created.
7. **O7 — LFS/OID and remote availability** are COORD-owned (§9 item 8); no resolution
   attempted.

## 11. Summary

One owned code file was extended additively: a Summer-default season field, an enum-keyed
season→`{manifest_path, atlas_path}` table using **SP-4's actual `tile_index_atlas_winter.*`
names**, `FileAccess.file_exists` dual-path checks with a labelled Summer fallback, SP-5's
two loader overrides passed only for non-Summer paths, a Summer-name dictionary built from
the selected manifest, and SP-3's 11 direct desert remaps applied to tile ids immediately
before the existing `UV2.x` write. `stats` now names the selected manifest/PNG in
`atlas_path`, `atlas.manifest` and two new provenance blocks, while every legacy Summer
stat value is preserved. The LIGHT-02 follow-up changed exactly one line (`SUN_LIGHTVEC` at
`:138`) to the donor Y-up identity mapping, with `light.cfg:26-31` and
`reports/LIGHT_02_light_space.md` cited inline.

Backups: `world3d_terrain.gd.bak-SP06` and `.bak-SP06SUN`. Validation: variant-runner
headless `--check-only` jobs `sp06-smoke` (431), `sp06-smoke-pathfix` (443) and the retry
`sp06-sun-smoke-r2` (480) all `ok`, exit 0, stderr 0 B, `SCRIPT ERROR == 0` (3/3 pass;
one queue-skipped submission at ticket 457 is recorded in §12). No shader edit, no index change beyond SP-3's labelled remap, no
mesh-invariant change, RELIEF-01 blocks byte-identical, `get_minimap_box`/CAM-RV-01
unaffected, no test weakened, no donor copy, no git add/commit by this worker, no LFS
action. **No other file was edited. No visual-parity claim is made.**

---

## 12. Final validation supplement (LIGHT-02 smoke)

| Field | Value |
|---|---|
| Submitted job | `sp06-sun-smoke` — ticket **457**, `--timeout 180 --max-wait 1800` |
| Submission outcome | `skipped`: waited 1,632.09 s, `run=0`, `exit=null`, error `ticket 457 was skipped (serving=458)` — **not a code failure**, queue congestion (status snapshot at that time: max wait 1,825 s) |
| Retry job | `sp06-sun-smoke-r2` — ticket **480**, `--timeout 180 --max-wait 5400` |
| Retry argv | `--headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd` |
| Wait / run | 58.26 s / 6.49 s |
| Status / exit | `ok` / `0` |
| stdout | 75 B — `Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org` |
| stderr | **0 B** ⇒ `SCRIPT ERROR == 0`, `Parse Error == 0` |
| Result JSON | `variant3d/.godot_queue/results/00000480.json` |
| Spool | `variant3d/.godot_queue/results/00000480_sp06-sun-smoke-r2/` |

**Verdict: `SCRIPT ERROR == 0` — PASS (3/3 executed jobs).** The LIGHT-02 one-line
`SUN_LIGHTVEC` change parses cleanly under Godot 4.7.2 `--check-only`. No test atom, no
runtime atlas load, no donor A/B, no visual-parity claim; no other file was edited by this
worker.

*End of SP-06. One owned code file, two backups, one report; no other file edited.*
