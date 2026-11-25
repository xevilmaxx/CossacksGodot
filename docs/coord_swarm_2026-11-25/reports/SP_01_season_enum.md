---
id: SP-01
task: "SP-1 SEASON-ENUM — add the donor season/climate enum constants to variant3d/scripts/data.gd"
date: 2026-11-25
status: DELIVERED__DATA_CONSTANTS_ONLY__SMOKE_PASS__NO_BEHAVIOUR_CHANGE
scope: "Exclusive owner of variant3d/scripts/data.gd and this report only. Donor READ-ONLY (no donor file opened, copied, executed or changed this task — donor path:line facts cited second-hand from DENV-01 / DEC-03 / DEC-05 / SEASON-PLAN-01). No gates, no ladder, no direct godot, no test weakened, no other file edited."
owner_files:
  - "variant3d/scripts/data.gd"
  - "docs/coord_swarm_2026-11-25/reports/SP_01_season_enum.md"
backup: "inbox/backup/data.gd.bak-SP01"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/SP_01_season_enum.md"
labels: [observed, derived, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 3
visual_parity_claim: false
---

# SP-01 — donor season/climate enum in `data.gd`

## 1. Goal

Execute ticket **SP-1 SEASON-ENUM** from `SEASON-PLAN-01` §5: add the donor-grounded
season/climate **enum constants** and a **summer/default value** to
`variant3d/scripts/data.gd`, with `path:line` donor citations, as **data only**.
No behaviour change, no renames, no new mechanics, no wiring into `config.gd`,
`game.gd`, the renderer, the loader or the shader.

---

## 2. Sources (read first, none edited by this task)

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | SP-1 ticket row (§5 line 186): add `SEASON_ENUM {summer:0,winter:2,desert:3}`; comment `TERRAIN_TINT` as legacy, not delete; value `1` UNVERIFIED (B7, Q5); flat-tint caveat (B9) — observed |
| S2 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | donor season enum and swap truth: §3.5 (`:420-425`), §3.6 (`:430-445`), §3.1 (`:362-375`), §4 (`:474-495`), §5.2 (`:520-531`), Q5 (`:615`), C9 (`:596-599`) — observed, 2 passes |
| S3 | `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` | donor config inventory/method; `env.cfg:16` loads `colors.lib`; no fog key in `env.cfg` — observed |
| S4 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | two 124-entry `terrain.presets` sets (§4.6 `:405`), `_winter` names (§5.1 `:437-439`), `gc_meters_to_tile=2` (§5.4 `:494`), donor not opened — observed |
| S5 | `variant3d/scripts/data.gd` (EXCLUSIVE owner) | before-state constants: `BIOME` at `:199`, `TERRAIN_TINT` at `:219-225`, `terrain_tint()` at `:224-225` — observed |

No donor binary was opened this task; every donor `path:line` below is a citation
from S1–S4 (which read them in earlier read-only passes). The report does not
claim donor runtime parity — donor `;`-prefixed script activity remains
**UNVERIFIED** (SEASON-PLAN-01 B6; DENV-01 Q6).

---

## 3. Donor citation ledger (why these numbers)

| Donor `path:line` | Literal / meaning | Label |
|---|---|---|
| `scripts\lib\map.script:250` | `map.settings.gen.season` default `0` (Summer) | observed (via S2 §3.5) |
| `scripts\dmscript.global:237` | `gc_MaxSeasonCount = 3` → `0/1/2` implied; value `1` **UNVERIFIED** | observed + UNVERIFIED (S2 §3.5) |
| `scripts\lib\miscext2.script:3318-3323` | UI toggle `season=2 → _misc_SetSeason(0)`, else `_misc_SetSeason(2)` (only `0↔2`) | observed (S2 §3.5) |
| `scripts\dogenerate.inc:4`, `:2079` | desert branch `gMap.settings.gen.season = 3` | observed (S2 §3.5) |
| `scripts\lib\miscext.script:1549` | `SetSeasonType(season)` — season swap entry point | observed (S2 §3.6) |
| `terrain\tiles\terrain.lib:12` | `seasons.Summer = Summer` — default alias | observed (S2 §3.1) |
| `terrain\tiles\terrain.presets:2-6`, `:134-263` | two **124-entry** sets (Summer / Winter); not a colour tint | observed (S2 §3.3; S4 §4.6) |
| `env\colors\colors.lib:94-101` | winter/desert tables override only `ShadowBlendingDiffuse` | observed (S2 §2.5) |

Derived: the readable enum is `{summer:0, winter:2, desert:3}`; `1` is implied by
`gc_MaxSeasonCount=3` but has no readable literal, so it is **not encoded**.
The two suffixes are distinct and neither is conflated here: tile aliases append
`_winter` (`terrain.presets:138`), prop materials append `w` (`fir1w`) — S2 §4,
SEASON-PLAN-01 §4.2.

---

## 4. Before → after (the complete diff)

Backup first: `inbox/backup/data.gd.bak-SP01`, SHA-256
`286F5632E88111E23C26B65AFB920F7F6143D0BFBA46E0C03D4FD4C10AD8B6A9`
(byte-identical to the pre-edit `variant3d/scripts/data.gd`).

`git diff -- variant3d/scripts/data.gd` is **additions only** (16 inserted lines,
0 deletions, 0 modifications). Final on-disk positions: `data.gd:217-228` (new
block), `data.gd:231-234` (legacy-tint comment), `data.gd:235-239` (`TERRAIN_TINT`
values unchanged).

### 4.1 Before (pre-edit, from backup)

```gdscript
const RELIEF_SCALE := {"plains": 1.0, "hills": 1.5, "mountains": 2.2}
const RELIEF_DOME_DELTA := {"plains": 0, "hills": 1, "mountains": 2}
# Season tint exposed for world.gd (separate worker); never stored in map_meta
# because map_meta is serialised into every --dump-map file.
const TERRAIN_TINT := {
	"summer": Color(1.0, 1.0, 1.0, 1.0),
	"winter": Color(0.86, 0.91, 1.0, 1.0),
	"desert": Color(1.0, 0.90, 0.70, 1.0),
}
static func terrain_tint(biome: String = "") -> Color:
	return TERRAIN_TINT.get(biome if biome != "" else str(BIOME), TERRAIN_TINT["summer"])
```

### 4.2 After (current `data.gd:215-241`)

```gdscript
const RELIEF_SCALE := {"plains": 1.0, "hills": 1.5, "mountains": 2.2}
const RELIEF_DOME_DELTA := {"plains": 0, "hills": 1, "mountains": 2}
# --- SP-1 SEASON / CLIMATE ENUM (donor season values; DATA ONLY) --------------
# Donor season values, read-only from the shipped donor scripts (via DENV-01):
#   scripts\lib\map.script:250          gen.season default = 0 (Summer)
#   scripts\dmscript.global:237         gc_MaxSeasonCount = 3  (0/1/2 implied)
#   scripts\lib\miscext2.script:3318-3323  UI toggle season 0 <-> 2
#   scripts\dogenerate.inc:4, :2079     desert branch gen.season = 3
#   scripts\lib\miscext.script:1549     SetSeasonType(season)
# Season 1 is UNVERIFIED (DENV-01 Q5 / SEASON-PLAN-01 B7) and is deliberately NOT
# encoded here. Additive data constants only: no behaviour change, no renames,
# no new mechanics. The existing string BIOME (data.gd:199) is left untouched.
const SEASON_ENUM := {"summer": 0, "winter": 2, "desert": 3}
const SEASON_DEFAULT := 0  # summer/default: map.script:250 (gen.season=0); terrain.lib:12 (seasons.Summer=Summer)
# Season tint exposed for world.gd (separate worker); never stored in map_meta
# because map_meta is serialised into every --dump-map file.
# LEGACY FLAT TINT / PORT APPROXIMATION: the donor winter/desert swap is a tile-SET
# swap plus colors.lib lighting tables (DENV-01 §4/§5.2; SEASON-PLAN-01 B9), NOT a
# colour multiply. Kept for the 2D sibling which consumes it; do not delete or
# mistake this for the donor swap mechanism.
const TERRAIN_TINT := {
	"summer": Color(1.0, 1.0, 1.0, 1.0),
	"winter": Color(0.86, 0.91, 1.0, 1.0),
	"desert": Color(1.0, 0.90, 0.70, 1.0),
}
static func terrain_tint(biome: String = "") -> Color:
	return TERRAIN_TINT.get(biome if biome != "" else str(BIOME), TERRAIN_TINT["summer"])
```

### 4.3 Explicit non-changes

- **`BIOME` (`data.gd:199`) unchanged** — still the string `"summer"`; no rename, no
  type change, no rewiring to `SEASON_ENUM`.
- **`TERRAIN_TINT` values unchanged** — only a comment was added above it, per
  SEASON-PLAN-01 §5 SP-1 (comment as legacy; do not delete — 2D sibling consumes it).
- **`terrain_tint()` unchanged** — no function added or modified; SP-1 adds no
  `season_enum()` helper and no enum round-trip logic (that would be a new mechanic,
  explicitly out of scope for this ticket's brief).
- No `config.gd`, `game.gd`, `main.gd`, renderer, loader, shader, asset, config,
  test or gate file touched.

---

## 5. Backup verification

| Check | Result |
|---|---|
| Backup path | `inbox/backup/data.gd.bak-SP01` (created this task) |
| Backup length | 83,766 bytes |
| Backup SHA-256 | `286F5632E88111E23C26B65AFB920F7F6143D0BFBA46E0C03D4FD4C10AD8B6A9` |
| Pre-edit source SHA-256 | identical to backup (verified before edit) |
| Post-edit source SHA-256 | `D131928661E1EC6D67A6E835A5752540757817C24D354C26C2ED1B641A918FE8` |

Backup is untracked (inbox artifacts are not part of the tracked source tree).

---

## 6. Smoke check — variant runner only

No direct `godot`, no gates, no ladder. Single targeted job through
`variant3d/tools/godot_runner.py`:

```
python variant3d/tools/godot_runner.py run --id sp01-smoke --timeout 120 -- \
  --headless --path variant3d --check-only --script res://scripts/data.gd
```

| Field | Value |
|---|---|
| Runner job id | `sp01-smoke` |
| Ticket | `410` |
| Status | `ok` |
| Exit code | `0` |
| Wait / run | 128.81 s / 7.15 s |
| Godot | `4.7.2.stable.official.ed1daf0bf` |
| stdout | `variant3d/.godot_queue/results/00000410_sp01-smoke/stdout.txt` (Godot banner only) |
| stderr | `variant3d/.godot_queue/results/00000410_sp01-smoke/stderr.txt` (empty) |
| Result JSON | `variant3d/.godot_queue/results/00000410.json` |
| **`SCRIPT ERROR` count** | **`0`** |
| `Parse Error` count | `0` |

**Verdict: `SCRIPT ERROR == 0` — PASS.** The script parses cleanly under Godot
4.7.2 `--check-only`; the two new `const` declarations are valid GDScript and
introduce no load-time error.

---

## 7. Scope discipline statement

**No other file was edited by this task.** The only source file changed is
`variant3d/scripts/data.gd`; the only other file written is this report; the only
other artifact created is the backup `inbox/backup/data.gd.bak-SP01`. The runner
wrote only to its gitignored spool (`variant3d/.godot_queue/**`). Other modified /
untracked files visible in `git status` belong to concurrent tickets (e.g.
SP-03, SP-05, RELIEF-01, MMJUMP-01) and were **not** touched here. Donor remained
READ-ONLY; no donor data was copied into the repo. No test was weakened and no
visual-parity claim is made.

---

## 8. Open questions (do not guess; inherited / narrowed)

1. **No `season_enum()` helper added.** The brief forbids new mechanics, so SP-1
   ships the enum **data** only. Any future consumer must add its own lookup;
   SEASON-PLAN-01 §5 mentions `season_enum(biome)` and an "enum round-trip for
   0/2/3" acceptance — this ticket deliberately narrows that to parse success
   (`SCRIPT ERROR == 0`). **Open for COORD:** confirm data-only is sufficient.
2. **Season value `1` remains UNVERIFIED** (`gc_MaxSeasonCount=3` implies 0/1/2;
   DENV-01 Q5 / SEASON-PLAN-01 B7). Not encoded; no code path created.
3. **Donor runtime activity UNVERIFIED** — all season `.inc` lines carry the
   donor `;` prefix (SEASON-PLAN-01 B6; DENV-01 Q6). The enum records donor
   *intent*, not proven shipped behaviour.
4. **Cloud preset `season=2`** is not part of this enum and stays UNVERIFIED
   (DENV-01 §2.7/Q4; SEASON-PLAN-01 §4.2).
5. **Downstream wiring is out of scope** — consuming `SEASON_ENUM` for atlas /
   dictionary selection belongs to SP-5/SP-6, not to this data-only ticket.
6. **`TERRAIN_TINT` comment scope** — added because SEASON-PLAN-01 SP-1 explicitly
   requires labelling it as legacy; it is comment-only and no value changed.
   Flag to COORD if the narrower "constants only" reading is preferred.

---

## 9. Summary

Added the donor-grounded season/climate enum as **two additive constants** in
`variant3d/scripts/data.gd:227-228` — `SEASON_ENUM = {summer:0, winter:2, desert:3}`
and `SEASON_DEFAULT = 0` — with `path:line` donor citations at `data.gd:219-228`
(`map.script:250`, `dmscript.global:237`, `miscext2.script:3318-3323`,
`dogenerate.inc:4,2079`, `miscext.script:1549`, `terrain.lib:12`). Value `1` is
recorded as **UNVERIFIED** and deliberately omitted. A comment-only note at
`data.gd:231-234` marks `TERRAIN_TINT` as a legacy flat tint / PORT APPROXIMATION,
not the donor tile-set swap mechanism; its values and `terrain_tint()` are
unchanged. `BIOME` is untouched.

Backup: `inbox/backup/data.gd.bak-SP01` (byte-identical to pre-edit source).
Smoke: runner ticket `410` / `sp01-smoke`, `--headless --path variant3d
--check-only --script res://scripts/data.gd`, exit `0`, status `ok`,
**`SCRIPT ERROR == 0`**, `Parse Error == 0`.

No behaviour change, no renames, no new mechanics, no donor copy, no gates, no
direct `godot`, no test weakened. **No other file edited.** Visual parity not
claimed.

*End of SP-01.*
