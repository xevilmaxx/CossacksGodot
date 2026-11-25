---
id: QA-CONFIG-JSON-02
title: "QA-CONFIG-JSON-02 — verify CONFIG-RESTORE-01's 21-key `features` block after it lands"
owner: "QA-CONFIG-JSON-02 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Read-only. Sources: variant3d/scripts/config.gd:46-84 defaults, variant3d/config.json (full read), inbox/backup/config.json.bak-CONFIGRESTORE (and .bak-RELIEFENABLE), git log/show/status, reports/QA_CONFIG_RESTORE_01.md, reports/RELIEF_ENABLE_01.md, SWARM_BOARD.md and related stale docs. Sole output: docs/coord_swarm_2026-11-25/reports/QA_CONFIG_JSON_02.md. No code/config/backup/test/doc edit, no Godot submission, no runner job."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_CONFIG_JSON_02.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: "REPORT-LEVEL UNVERIFIED — NO PASS PROMOTION: the formal landing artifact `reports/CONFIG_RESTORE_01.md` is ABSENT at every checked path, so the task's 'if not landed' branch applies. The file-level change itself HAS landed: current `variant3d/config.json` holds 21 `features` leaves (20/21 default matches + 1 intentional `terrain.relief_stamps: true` override), JSON parses, map is 320×320/land, and no pre-existing key changed vs the pre-restore backup. Restore is committed in `2411a752`. Runtime/dump/visual/donor-parity remain UNVERIFIED."
landing_premise: "The task's expected '1 feature leaf' on-disk state was the PRE-restore/T0 state; it survives only in `inbox/backup/config.json.bak-CONFIGRESTORE` (SHA BD80C2D1…). Current on-disk state (T1, observed at report time) is 21 leaves (SHA 0514F3FF…). Both exact states are recorded in §2."
---

# QA-CONFIG-JSON-02 — 21-key `features` block verification

## 1. Sources and tooling

| Source | Lines / role | Label |
|---|---|---|
| `variant3d/scripts/config.gd` | `:42-45` CONFIG-CORE-01 comment; `:46-84` `FEATURES_DEFAULTS` (21 leaves / 8 groups); `:88-89` `DEFAULT.features = FEATURES_DEFAULTS`; `:414-483` 21 typed getters | observed |
| `variant3d/config.json` | full read (872 lines): `:16-54` 21-leaf `features`; `:29` `relief_stamps: true`; `:80-81` map 320×320; `:82` `map_type: "land"` | observed |
| `inbox/backup/config.json.bak-CONFIGRESTORE` | full read (838 lines): `:16-20` exactly 1 leaf `features.terrain.relief_stamps: true`; pre-restore baseline | observed |
| `inbox/backup/config.json.bak-RELIEFENABLE` | full read (833 lines): **no** `features`; SHA `0B7E2538…69041` | observed |
| `app/config.json`, `app/scripts/config.gd` | `app/config.json` has **0** matches for `features`; `app/config.gd` has no `FEATURES_DEFAULTS` block — the 2D port is not the subject; subject is `variant3d/**` per `QA_CONFIGJSON_01` precedent | observed |
| `reports/CONFIG_RESTORE_01.md` | **ABSENT** — repo-wide filename glob and direct path read both fail; owner report has not landed | observed / UNVERIFIED |
| `reports/QA_CONFIG_RESTORE_01.md` | full read (150 lines): sibling QA's T0 (1 leaf) → T1 (21 leaf) timeline and file-level verdict | observed |
| `reports/RELIEF_ENABLE_01.md` | `:54-72` precondition mismatch and minimal 1-leaf decision; `:78-104` backup SHA + insertion proof; `:186-190` Q1 | observed |
| `SWARM_BOARD.md` | `:335` QA-CONFIG-RESTORE-01 RUNNING; `:344` QA-CONFIG-JSON-02 RUNNING; `:86` CFG-02 revert (240² failed 26/29, 320² passed 29/29); `:378,382` stale "no features" claims | observed |
| `git log/show/status` | `2411a752` added `variant3d/config.json` +39/−0 (the 21-key block); `83b77eaa` reverted MAP-SMALL-01's block; file now clean at HEAD | observed |

Tooling: `python` 3.14 (Windows) with `json.load`, recursive flatten + deep diff, SHA-256; plus `git log`/`git show`. No Godot binary, no runner job, no repo file written other than this report. [observed]

**Label legend:** `observed` = read directly from file/git; `derived` = computed from two observed sources; `inferred` = reasoned consequence, not proven; `UNVERIFIED` = no accessible evidence.

---

## 2. Landing-state check — exact on-disk states (task condition #3)

| Snapshot | `features` leaf count | Relief leaf | Map | SHA-256 (prefix) | Label |
|---|---|---|---|---|---|
| **T0 (pre-restore)** — preserved in `.bak-CONFIGRESTORE`; first read by sibling QA before 12:19:48 | **1** — only `terrain.relief_stamps: true` | `true` | 320×320 / land | `BD80C2D10D1FB…BF0F5` | observed |
| **T1 (current, at this report's read time)** — `variant3d/config.json` | **21** — 8 groups, all 21 shipped keys | `true` | 320×320 / land | `0514F3FF126F…4D648` | observed |
| Owner report `reports/CONFIG_RESTORE_01.md` | — | — | — | — | **UNVERIFIED — absent** |

**Premise reconciliation.** The task says "if not landed, state exact on-disk state (**1 feature leaf**) and mark UNVERIFIED. No PASS promotion." The 1-leaf state is real but is **not** the current on-disk state: it is the pre-restore snapshot captured in `.bak-CONFIGRESTORE` and recorded as the sibling QA's T0. At T1 the restore **is** present on disk (21 leaves, committed in `2411a752`). This report therefore does **not** assert "1 leaf on disk" (that would be false) and does **not** promote the ticket to PASS — the formal landing artifact named by the task is missing. [observed + derived]

Consequently this report marks the **ticket/landing verdict UNVERIFIED — no PASS promotion**, while recording the file-level content as observed fact (§3–§5). The sibling `QA_CONFIG_RESTORE_01.md` reached the same content observations but labelled its file-level result "VERIFIED / PASS"; that label is not adopted here. [derived / inferred]

---

## 3. 21-row verification table — default vs current JSON value

Dotted keys are under the top-level `features` object (`variant3d/config.json:16-54`). "config.gd default" is the literal in `FEATURES_DEFAULTS` (`:46-84`); "JSON value" is the `json.load()`-parsed value. `MATCH` = equal value **and** type; `INTENTIONAL OVERRIDE` = present, different, and expected.

| # | Dotted key | config.gd default | JSON value | Result | Label |
|---:|---|---|---|---|---|
| 1 | `selection.world_epsilon_m` | `0.005` | `0.005` | MATCH | observed + derived |
| 2 | `selection.attack_epsilon_m` | `0.25` | `0.25` | MATCH | observed + derived |
| 3 | `selection.marquee_color` | `[1, 1, 0, 1]` | `[1, 1, 0, 1]` | MATCH | observed + derived |
| 4 | `selection.marquee_width_px` | `1` (int) | `1` (int) | MATCH | observed + derived |
| 5 | `selection.double_click_s` | `0.5` | `0.5` | MATCH | observed + derived |
| 6 | `terrain.texgen_mode` | `"world_xz"` | `"world_xz"` | MATCH | observed + derived |
| 7 | `terrain.m_per_tile` | `2.0` | `2.0` | MATCH | observed + derived |
| 8 | `terrain.lighting` | `"donor"` | `"donor"` | MATCH | observed + derived |
| 9 | `terrain.alpha_patch_mode` | `"donor_approx"` | `"donor_approx"` | MATCH | observed + derived |
| 10 | `terrain.relief_stamps` | `false` | `true` | **INTENTIONAL OVERRIDE** (relief opt-in, `RELIEF_ENABLE_01`; carried from the 1-leaf pre-restore state) | observed + derived |
| 11 | `terrain.tile_diversity` | `true` | `true` | MATCH | observed + derived |
| 12 | `water.surface_y` | `-0.25` | `-0.25` | MATCH | observed + derived |
| 13 | `water.alpha_confine` | `true` | `true` | MATCH | observed + derived |
| 14 | `water.shore_prox` | `false` | `false` | MATCH | observed + derived |
| 15 | `weather.snow` | `false` | `false` | MATCH | observed + derived |
| 16 | `camera.fov_deg` | `17.27` | `17.27` | MATCH (donor grounding still PORT APPROX / UNVERIFIED at `config.gd:71,467`) | observed + UNVERIFIED |
| 17 | `hud.minimap_size` | `240` | `240` | MATCH | observed + derived |
| 18 | `hud.minimap_inset` | `-8` | `-8` | MATCH | observed + derived |
| 19 | `hud.minimap_corner` | `"bottom_right"` | `"bottom_right"` | MATCH | observed + derived |
| 20 | `render.fog` | `false` | `false` | MATCH | observed + derived |
| 21 | `gameplay.fog_of_war` | `false` | `false` | MATCH | observed + derived |

Group counts: `selection` 5, `terrain` 6, `water` 3, `weather` 1, `camera` 1, `hud` 3, `render` 1, `gameplay` 1 = **21 leaves / 8 groups**. [observed + derived]

Programmatic totals: **20 MATCH, 1 INTENTIONAL OVERRIDE, 0 MISSING, 0 EXTRA, 0 unintended MISMATCH**; 21 default keys vs 21 JSON leaves, `missing: []`, `extra: []`. [derived]

---

## 4. Required integrity checks

### 4.1 JSON parses
`json.load()` succeeded on `variant3d/config.json`, `.bak-CONFIGRESTORE` and `.bak-RELIEFENABLE`. Current top-level keys: `_readme, features, display, camera, gameplay, economy, ai, audio, controls, names, units, buildings` — same set as the pre-restore backup, with `features` expanded in place. [observed]

### 4.2 `relief_stamps` is true
`config.json:29` = `"relief_stamps": true` (JSON boolean). It is preserved from the 1-leaf pre-restore state (`.bak-CONFIGRESTORE:18`, same SHA as `RELIEF_ENABLE_01`'s post-edit file), **not** reverted to the code default `false`. This is the deliberate override, not a restore defect. [observed + derived]

### 4.3 Map 320² is intentional
`gameplay.map_width_tiles = 320` (`:80`) and `map_height_tiles = 320` (`:81`), `map_type: "land"` (`:82`); no 240² was reintroduced. Intent evidence: `SWARM_BOARD.md:86` (CFG-02: 240² broke `wall`/`shell`/`farm_cap` 26/29; 320² passed 29/29), `RELIEF_ENABLE_01.md:54-72` (explicit decision not to re-apply the reverted 240²), `MAP_SMALL_01_report.md` mandatory-revert context. **320² is the correct/intentional state; it is not a defect of this restore.** [observed + derived + inferred]

### 4.4 No other pre-existing key changed
Recursive deep diff of `current minus features` vs `.bak-CONFIGRESTORE minus features` = **0 differences** (verified `EQUAL excluding features: True`). Same result vs `.bak-RELIEFENABLE`. Byte/line evidence: backup 14,477 B / SHA `BD80C2D1…` → current 15,163 B / SHA `0514F3FF…`; `git show 2411a752 -- variant3d/config.json` = **+39 / −0 lines**, confined to the `features` object. `variant3d/scripts/config.gd` is unmodified. [observed + derived]

### 4.5 Change provenance
`git log -- variant3d/config.json` shows `2411a752` (restore) after `83b77eaa` (MAP-SMALL-01 revert that had removed the 21-key block and 240²). The file is clean at HEAD at report time; the `.bak-CONFIGRESTORE` backup is untracked. [observed]

---

## 5. Verdict

**REPORT-LEVEL: UNVERIFIED — NO PASS PROMOTION.** [observed / UNVERIFIED]

- Task condition #3 applies to the **owner-report landing artifact**: `reports/CONFIG_RESTORE_01.md` is absent at every checked path. The ticket is therefore **not promoted to PASS/DONE by this QA**. [observed]
- **File-level content (observed, not a promotion):** the restore's 21-key block is present and committed (`2411a752`); it mirrors `FEATURES_DEFAULTS` at 20/21 with the single deliberate `relief_stamps: true` override; JSON parses; map is 320²/land; no pre-existing key changed vs the pre-restore backup. [observed + derived]
- **Explicitly UNVERIFIED:** any runtime claim — `--dump-config` getter resolution (derived only), `--dump-map` `relief_stamps` emission with non-empty `plt2` entries (inherited from `QA_RELIEF_ON_01`, `QA_RELIEF_DUMP_01`), relief-grid application, visual hills, and donor parity. No gate, ladder or runner job was run. [UNVERIFIED]

Net: the on-disk artifact is exactly what a CONFIG-RESTORE-01 success state should look like, but this QA will not certify it as landed while its report is missing. [inferred]

---

## 6. Stale-document list

Read-only audit — no edits made. Recommended follow-ups (owner: COORD / doc-refresh ticket):

| Doc / line | Stale or incomplete text | Suggested correction | Label |
|---|---|---|---|
| `reports/CONFIG_RESTORE_01.md` | File absent | Land the owner report; until then cite only `QA_CONFIG_RESTORE_01.md` / this report for file-level state | observed / UNVERIFIED |
| `SWARM_BOARD.md:335` | QA-CONFIG-RESTORE-01 `RUNNING` | Update to DONE once coordinator accepts the sibling QA verdict | inferred |
| `SWARM_BOARD.md:344` | QA-CONFIG-JSON-02 `RUNNING` | Update on acceptance of this report (still UNVERIFIED at ticket level) | inferred |
| `SWARM_BOARD.md:378` (QA-CONFIG-01) | "no `features` object in config.json" | Annotate as historical snapshot; 21-key object present again at 320² | observed |
| `SWARM_BOARD.md:382` (CONFIG-COUNT-01) | "**`config.json` has NO `features` object** → all getters return defaults" | Mark historical; overlay now exists with one non-default leaf | observed + derived |
| `CONFIG_COUNT_RECONCILED.md:176-190` | "contains NO `features` object" + "nothing to merge" consequences | Historical; overlay now merges 21 keys, 20 at defaults + relief override | observed + derived |
| `CONFIG_PIPELINE.md:296-297` | "global JSON override does not [exist]" | Override exists; no unintended value deviates from default | observed |
| `reports/QA_CONFIG_01_getters.md:126` | "Main inconsistencies: no `features` object" | Historical snapshot; annotate, do not silently rewrite | observed |
| `reports/QA_CONFIGJSON_01.md:18,59,80-85,132-135` | "21/21 MATCH" at **240²** | Current block is at `:16-54` but map is **320²**; parity is 20/21 + 1 intentional relief override | observed |
| `reports/RELIEF_ENABLE_01.md:64-72,179-180` | "do **not** re-apply the ... 21-key table" | Superseded: block re-applied at 320² (not 240²) by CONFIG-RESTORE-01; keep old text as history | observed + inferred |
| `reports/QA_RELIEF_ON_01.md:226-230` | "exactly one change — only leaf" (`config.json:18`) | Pre-restore snapshot; leaf is now `config.json:29` inside a 21-key block | observed |
| `README.md:305,353`; `reports/README_FINAL_01.md:33,51` | "21/21 MATCH" with no caveat | Re-word: 20 default matches + 1 intentional `relief_stamps: true` override, map 320² | derived |
| `reports/MAP_SMALL_01_report.md:14-25,92-108` | 21-key block removed by mandatory revert | Accurate historically; add that CONFIG-RESTORE-01 re-added it at 320² | inferred |

---

## 7. Open questions

1. Will `reports/CONFIG_RESTORE_01.md` land, and what will it claim? None found; no gate/runner evidence from this QA. [observed / UNVERIFIED]
2. Does a live `--dump-config` show 21 `features` leaves with `relief_stamps: true`? Derived yes from `config.gd:88-89,387-406,420-483`; no probe was run. [derived / UNVERIFIED]
3. Does a live `--dump-map` emit `relief_stamps` with non-empty `plt2` entries? Unanswered per `QA_RELIEF_ON_01:90-100` and `QA_RELIEF_DUMP_01`. [inherited / UNVERIFIED]
4. Who owns `variant3d/config.json` now that the block is restored and committed (inherited `QA_CONFIGJSON_01 §6 Q2`)? [observed / UNVERIFIED]
5. Is 320² permanent, or only until the build-step/harness fix allows 240²? No ticket-state proof beyond the stated instruction. [inferred / UNVERIFIED]
6. `m_per_tile: 2.0` is exact in JSON, but the `_copy()` whole-float→int coercion (`QA_CONFIG_01_getters.md:74`) was not re-tested. [inherited / UNVERIFIED]
7. `camera.fov_deg = 17.27` donor grounding stays PORT APPROX / UNVERIFIED (`config.gd:71,467`); parity only is proven here. [observed / UNVERIFIED]
8. Relief visual hills / donor sculpt blend remain UNVERIFIED; no donor parity is claimed. [inherited / UNVERIFIED]

---

## 8. Summary

- **Landing artifact:** `reports/CONFIG_RESTORE_01.md` is **absent** → ticket verdict **UNVERIFIED, no PASS promotion**. The task's "1 feature leaf" state is the pre-restore snapshot (`.bak-CONFIGRESTORE`), not the current file. [observed / UNVERIFIED]
- **Current on-disk state:** `variant3d/config.json` has **21 `features` leaves / 8 groups** at `:16-54`, committed in `2411a752`; **20 MATCH, 1 intentional override** (`terrain.relief_stamps: true` vs code default `false`), **0 MISSING, 0 EXTRA**. [observed + derived]
- **Integrity:** JSON parses; map **320×320 / land** (intentional; 240² was reverted); deep diff vs the pre-restore backup excluding `features` is empty — **no other pre-existing key changed**. [observed + derived]
- **Not promoted:** runtime dump, stamping, visuals and donor parity remain UNVERIFIED; no Godot/runner job was launched. [UNVERIFIED]
- **Sole output:** this report. No code, config, backup, test or other document was edited. [observed]

*End of QA-CONFIG-JSON-02.*
