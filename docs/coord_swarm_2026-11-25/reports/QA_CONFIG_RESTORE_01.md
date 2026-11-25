---
id: QA-CONFIG-RESTORE-01
title: "Read-only QA — verify CONFIG-RESTORE-01's 21-key `features` block after it lands"
agent: "QA-CONFIG-RESTORE-01 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/config/backup/test/asset/git edit; no Godot submission; no runner job. Sole output: docs/coord_swarm_2026-11-25/reports/QA_CONFIG_RESTORE_01.md."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_CONFIG_RESTORE_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: "FILE-LEVEL VERIFIED — 21-key `features` block present at 320²; 20/21 MATCH, 1 intentional MISMATCH (`terrain.relief_stamps: true` vs code default `false`); JSON parses; no pre-existing key changed vs `config.json.bak-CONFIGRESTORE`. Restore committed in `2411a752`; owner report `reports/CONFIG_RESTORE_01.md` NOT LANDED; runtime/dump/visual UNVERIFIED."
landing_note: "The restore landed DURING this audit: first read showed the 1-leaf pre-restore state; re-read after 12:20:00 showed the 21-leaf post-restore state. Both snapshots are recorded below."
---

# QA-CONFIG-RESTORE-01 — 21-key `features` block verification

## 1. Sources and tooling

| Source | Lines / role | Label |
|---|---|---|
| `variant3d/scripts/config.gd` | `:42-45` CONFIG-CORE-01 comment; `:46-84` `FEATURES_DEFAULTS` (21 leaves / 8 groups); `:88-89` `DEFAULT.features = FEATURES_DEFAULTS`; `:414-483` typed getter block (21 getters) | observed |
| `variant3d/config.json` (pre-landing read) | `:16-20` — `features` held exactly one leaf, `terrain.relief_stamps: true`; 837 CRLF lines; SHA-256 prefix `bd80c2d1…` | observed (T0) |
| `variant3d/config.json` (post-landing read) | `:16-54` — full 21-leaf `features` object; `:29` `relief_stamps: true`; `:80-81` `map_width_tiles/map_height_tiles = 320`; `:82` `map_type: "land"`; 15,163 bytes / 871 CRLF lines; SHA-256 prefix `0514f3ff…` | observed (T1) |
| `inbox/backup/config.json.bak-CONFIGRESTORE` | `:16-20` — pre-restore 1-leaf `features`; 14,477 bytes / 837 CRLF lines; SHA-256 prefix `bd80c2d1…`; untracked file created 12:19:48 | observed |
| `inbox/backup/config.json.bak-CFGJSON` | `:16` start of `display` (no `features`); `:41-42` map 240×240; 14,409 bytes / 832 CRLF lines | observed |
| `inbox/backup/config.json.bak-RELIEFENABLE`, `.bak-MAPSMALL01`, `.bak-CFG02` | all 14,409 bytes, 320×320, **no** `features` — corroborating snapshots | observed |
| `reports/CONFIG_RESTORE_01.md` | **ABSENT** at every checked path (repo-wide filename search); owner report has not landed | observed / UNVERIFIED |
| `SWARM_BOARD.md` (final read) | `:335` QA-CONFIG-RESTORE-01 still `RUNNING`; `:376` QA-CONFIG-01 "no `features` object"; `:380` CONFIG-COUNT-01 "config.json has NO `features` object" | observed |
| `reports/RELIEF_ENABLE_01.md` | `:56-72` documented the 1-leaf deviation; `:78-99` backup SHA `BD80C2D1…` and +5-line insertion proof | observed |
| `reports/QA_RELIEF_ON_01.md` | `:226-238` "exactly one change" / "only leaf" audit of the pre-restore state | observed |
| `reports/QA_CONFIGJSON_01.md`, `reports/MAP_SMALL_01_report.md` | historical 21-key/240² and mandatory-revert context | observed |
| `git status --short`, `git diff --numstat`, `git show --stat` | At first observation `M variant3d/config.json` (+39/−0 vs HEAD) and untracked backup; commit `2411a752` then landed both (39-line config change plus the backup); final status is clean for both paths, with only this report untracked. `variant3d/scripts/config.gd` unmodified. | observed |

Tooling: `python` 3.14 (Windows) with `json.load`, a GDScript-literal-to-JSON extraction of `FEATURES_DEFAULTS`, recursive flatten/deep-diff, SHA-256 and CRLF counts. No Godot binary, runner job, or repo file other than this report was written. [observed]

### Landing timeline (both states observed)

| Time (local, 2026-11-25) | State | Label |
|---|---|---|
| First read, before 12:19:48 | `features` = 1 leaf only (`terrain.relief_stamps: true`); no `bak-CONFIGRESTORE`; no owner report | observed |
| 12:19:48 | Pre-restore backup created; matches the 1-leaf state byte-for-byte (SHA prefix `bd80c2d1…`) | observed |
| 12:20:00 | `variant3d/config.json` rewritten with the 21-leaf block; re-read confirms it | observed |
| Before report write | Commit `2411a752` captured `variant3d/config.json` (+39 lines) and `inbox/backup/config.json.bak-CONFIGRESTORE`; working tree clean for both | observed |
| At report time | Owner report `reports/CONFIG_RESTORE_01.md` still absent (not in `2411a752` either) | observed / UNVERIFIED |

The conditional in the task ("if the restore has not landed, report 1 leaf and mark UNVERIFIED") therefore applied at T0 but **not** at T1: the restore landed, so the file-level state is verified below. Runtime claims are still not promoted. [derived + inferred]

---

## 2. 21-row verification table

Dotted keys are `features.<group>.<key>`. "config.gd default" is the literal in `FEATURES_DEFAULTS` (`:46-84`); "JSON value" is the parsed value at `variant3d/config.json:16-54`. `MATCH` = parsed value equals the code default; `MISSING` = key absent; `MISMATCH` = present but different.

| # | Dotted key (features.*) | config.gd default | JSON value | Result | Label |
|---|---|---|---|---|---|
| 1 | `selection.world_epsilon_m` | `0.005` | `0.005` | MATCH | observed + derived |
| 2 | `selection.attack_epsilon_m` | `0.25` | `0.25` | MATCH | observed + derived |
| 3 | `selection.marquee_color` | `[1, 1, 0, 1]` | `[1, 1, 0, 1]` | MATCH | observed + derived |
| 4 | `selection.marquee_width_px` | `1` | `1` | MATCH | observed + derived |
| 5 | `selection.double_click_s` | `0.5` | `0.5` | MATCH | observed + derived |
| 6 | `terrain.texgen_mode` | `"world_xz"` | `"world_xz"` | MATCH | observed + derived |
| 7 | `terrain.m_per_tile` | `2.0` | `2.0` | MATCH | observed + derived |
| 8 | `terrain.lighting` | `"donor"` | `"donor"` | MATCH | observed + derived |
| 9 | `terrain.alpha_patch_mode` | `"donor_approx"` | `"donor_approx"` | MATCH | observed + derived |
| 10 | `terrain.relief_stamps` | `false` | `true` | **MISMATCH — intentional override** (`RELIEF_ENABLE_01`, verified by `QA_RELIEF_ON_01`) | observed + derived |
| 11 | `terrain.tile_diversity` | `true` | `true` | MATCH | observed + derived |
| 12 | `water.surface_y` | `-0.25` | `-0.25` | MATCH | observed + derived |
| 13 | `water.alpha_confine` | `true` | `true` | MATCH | observed + derived |
| 14 | `water.shore_prox` | `false` | `false` | MATCH | observed + derived |
| 15 | `weather.snow` | `false` | `false` | MATCH | observed + derived |
| 16 | `camera.fov_deg` | `17.27` | `17.27` | MATCH | observed + derived |
| 17 | `hud.minimap_size` | `240` | `240` | MATCH | observed + derived |
| 18 | `hud.minimap_inset` | `-8` | `-8` | MATCH | observed + derived |
| 19 | `hud.minimap_corner` | `"bottom_right"` | `"bottom_right"` | MATCH | observed + derived |
| 20 | `render.fog` | `false` | `false` | MATCH | observed + derived |
| 21 | `gameplay.fog_of_war` | `false` | `false` | MATCH | observed + derived |

Group counts: `selection` 5, `terrain` 6, `water` 3, `weather` 1, `camera` 1, `hud` 3, `render` 1, `gameplay` 1 = **21 leaves / 8 groups**. [observed + derived]

Result totals: **20 MATCH, 1 MISMATCH (intentional), 0 MISSING, 0 EXTRA**. The 20 matching leaves are exact value-and-type matches at the parsed-JSON level; the single non-default leaf is the pre-existing relief opt-in, not a restore defect. [derived]

---

## 3. Integrity checks

### 3.1 JSON parses
- `json.load()` succeeded for the current config and all five backups (current, `bak-CONFIGRESTORE`, `bak-CFGJSON`, `bak-RELIEFENABLE`, `bak-MAPSMALL01`, `bak-CFG02`). [observed]
- Current top-level keys: `_readme`, `features`, `display`, `camera`, `gameplay`, `economy`, `ai`, `audio`, `controls`, `names`, `units`, `buildings` — same set as the backup, with `features` expanded in place. [observed]

### 3.2 `terrain.relief_stamps = true`
- `variant3d/config.json:29` reads `"relief_stamps": true` (JSON boolean). [observed]
- It is preserved from the 1-leaf pre-restore state (`bak-CONFIGRESTORE:18`, SHA `BD80C2D1…`, cited in `RELIEF_ENABLE_01:80`) rather than reverted to the code default. [derived]

### 3.3 Map size remains 320²
- `gameplay.map_width_tiles = 320` and `map_height_tiles = 320` at `:80-81`; `map_type: "land"` at `:82`. [observed]
- No 240² value was reintroduced. This is the intentional state until the build-step/harness fix; the 21-key block did not depend on 240² (`MAP_SMALL_01_report.md:92-108`). [derived + inferred]

### 3.4 No other pre-existing key changed
- Recursive deep diff of `current minus features` vs `bak-CONFIGRESTORE minus features`: **0 differences** — every pre-existing value, list and mapping is unchanged. [derived]
- Line endings CRLF preserved: backup 837 lines → current 871 lines (+34), consistent with expanding the `features` object only. `git diff --numstat` shows +39 / −0 against HEAD (HEAD is the 832-line, no-`features` commit `83b77eaa`). [observed + derived]
- Comparison against `bak-CFGJSON` shows exactly two differences, both map dimensions (`240 → 320`); that backup predates the MAP-SMALL-01 revert and is not the restore baseline. No other key differs there either. [derived]
- `variant3d/scripts/config.gd` is unmodified (mtime 10:32:24, before the restore); `git status` shows only `variant3d/config.json` modified plus the new backup. [observed]

---

## 4. Verdict

**FILE-LEVEL VERIFIED / PASS — do not promote beyond file level.** [observed + derived]

- The CONFIG-RESTORE-01 edit landed at 12:20:00 and the 21-key block is present, JSON-valid, and mirrors `FEATURES_DEFAULTS` 20/21 exactly, with `terrain.relief_stamps: true` as the deliberate override carried over from RELIEF_ENABLE_01. [observed + derived]
- 320² and `land` are intact; no pre-existing key changed relative to the pre-restore backup; no code, backup or harness file was touched by this QA. [derived]
- **UNVERIFIED / not promoted:** `reports/CONFIG_RESTORE_01.md` (owner report) has not landed; no `--dump-config`/`--dump-map` probe was run; getter resolution, `dump["relief_stamps"]` emission, stamp placement and visual hills remain untested at runtime (inheriting `QA_RELIEF_ON_01:90-100,226-238`). No donor parity claim is made. [observed / UNVERIFIED]

---

## 5. Stale-document corrections needed

Read-only audit — no edits made. Recommended follow-ups (owner: COORD / doc-refresh ticket):

| Doc / line | Stale or incomplete text | Suggested correction | Label |
|---|---|---|---|
| `reports/CONFIG_RESTORE_01.md` | File absent | Land the owner report; until then cite only this QA for file-level state | observed / UNVERIFIED |
| `SWARM_BOARD.md:335` | QA-CONFIG-RESTORE-01 still `RUNNING` | Update to DONE (this QA delivered) once the coordinator accepts the verdict | inferred |
| `SWARM_BOARD.md:366,370`; `CONFIG_COUNT_RECONCILED.md:176`; `CONFIG_PIPELINE.md:298` | "`config.json` has NO `features` object" / "the global JSON override does not" | Mark as historical snapshots: 21-key object present again at 320² (one intentional non-default leaf) | observed + derived |
| `reports/QA_RELIEF_ON_01.md:96,226-230` | "`relief_stamps` only in `config.json:18`" / "exactly one change — only leaf" | Annotate as pre-CONFIG-RESTORE snapshot; the leaf is now `config.json:29` inside a 21-key block | observed |
| `reports/RELIEF_ENABLE_01.md:64-72,179-180` | Decision "do **not** re-apply the ... 21-key table" | Now superseded by CONFIG-RESTORE-01 — the block was re-applied *without* 240²; keep the old text as historical context | observed + inferred |
| `reports/QA_CONFIGJSON_01.md:18,80-85,132-135` | 21 keys at **240²** (`config.json:16-54`, `:80-81`) | Current block is at `:16-54` but map is **320²** (`:80-81`); parity still 21/21 modulo the relief override | observed |
| `README.md:305,353`; `reports/README_FINAL_01.md:33,51` | "21/21 MATCH" with no caveat | Re-word to "20 default matches + 1 intentional `relief_stamps: true` override; 320²" | derived |
| `reports/MAP_SMALL_01_report.md:14-25,92-108` | Says the 21-key block was removed by the mandatory revert | Accurate historically; add that CONFIG-RESTORE-01 re-added it at 320² after the harness decision | inferred |

---

## 6. Open questions

1. Will `reports/CONFIG_RESTORE_01.md` land, and will it claim any gate/runner evidence? None was found; this QA found none. [observed / UNVERIFIED]
2. Does a live `--dump-config` show 21 `features` leaves with `relief_stamps: true`? Derived yes via `config.gd:88-89,331-337,420-483`, but no probe was run. [derived / UNVERIFIED]
3. Does a live `--dump-map` now emit the `relief_stamps` key with non-empty `plt2` entries? Still unanswered per `QA_RELIEF_ON_01:90-100` and `QA_RELIEF_DUMP_01`. [inherited / UNVERIFIED]
4. `features.terrain.m_per_tile: 2.0` is exact in JSON, but the documented `_copy()` whole-float→int coercion (`QA_CONFIG_01_getters.md:74`) was not re-tested. [inherited / UNVERIFIED]
5. `features.camera.fov_deg = 17.27` donor grounding stays `PORT APPROX / UNVERIFIED` (`config.gd:71,467`); this audit proves parity only. [observed / UNVERIFIED]
6. Is 320² to be kept indefinitely, or replaced only after the build-step fix? Task says keep it until then; no ticket-state proof beyond that instruction. [inferred / UNVERIFIED]
7. Who owns `variant3d/config.json` now (inherited from `QA_CONFIGJSON_01 §6 Q2`)? The file is uncommitted and its backup is untracked. [observed / UNVERIFIED]

---

## 7. Summary

- The restore **landed during the audit**: 1 feature leaf at first read → **21 leaves** at `:16-54` after 12:20:00; backup `config.json.bak-CONFIGRESTORE` captured the 1-leaf pre-state. [observed]
- Against `config.gd:46-84`: **20 MATCH, 1 intentional MISMATCH** (`terrain.relief_stamps: true` vs default `false`), **0 MISSING, 0 EXTRA**. [derived]
- JSON parses; map remains **320×320 / land** at `:80-82`; deep diff vs the pre-restore backup excluding `features` is **empty** — no other pre-existing key changed. [observed + derived]
- Owner report `reports/CONFIG_RESTORE_01.md` is **absent**; runtime dump, stamping and visuals remain **UNVERIFIED**. File-level PASS is not a runtime or donor-parity claim. [observed / UNVERIFIED]
- Sole output: this report. No code, config, backup, test or runner job was touched. [observed]
