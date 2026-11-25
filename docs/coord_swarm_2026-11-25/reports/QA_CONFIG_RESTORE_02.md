---
id: QA-CONFIG-RESTORE-02
title: "QA-CONFIG-RESTORE-02 — confirm CONFIG-RESTORE-01's report and gate jobs after it lands"
agent: "QA-CONFIG-RESTORE-02 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Read-only audit. Sources: reports/CONFIG_RESTORE_01.md (if landed), reports/QA_CONFIG_RESTORE_01.md, reports/QA_CONFIG_JSON_02.md, variant3d/config.json, inbox/backup/config.json.bak-CONFIGRESTORE, variant3d/.godot_queue (status.json history, results/, jobs/, now_serving, counter, godot.lock), git log/diff/status, SWARM_BOARD.md and cited stale docs. Sole output: docs/coord_swarm_2026-11-25/reports/QA_CONFIG_RESTORE_02.md. No source/config/backup/test/runner/doc edit; no Godot submission."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_CONFIG_RESTORE_02.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: "HOLD — NO PASS PROMOTION. The formal landing artifact reports/CONFIG_RESTORE_01.md is ABSENT, so there is no owner report with a 21-row table, backup path or honest job results to confirm. File-level state is good (21 features leaves / 8 groups, 20 default matches + 1 intentional terrain.relief_stamps: true override, map 320x320 / land, JSON parses, backup config.json.bak-CONFIGRESTORE present). Runner jobs configrestore01-smoke (ticket 540) is history-status ok / exit 0 but is a --check-only parse of config.gd with NO stdout/stderr/JSON artifact on disk; configrestore01-uitest (ticket 541) has NO history record and is still in-flight (now_serving=541). Neither job gates the 21-key block or relief at runtime. Runtime dump, stamping, visuals and donor parity remain UNVERIFIED."
snapshot: "status.json history_length=500, last entry ticket 540; now_serving=541; counter=546; godot.lock='541 1795606520.097 14764'; jobs/ holds 541-545. All counts are perishable while the runner advances."
---

# QA-CONFIG-RESTORE-02 — landing-artifact confirmation and job gating

**Label convention:** `observed` = read directly from a file/git/queue record; `derived` = computed or cross-referenced from observed data; `inferred` = best-supported explanation, not proven; `UNVERIFIED` = cannot be established from available evidence.

**Mutation statement:** read-only. No code, config, backup, test, runner, queue or other document was changed. The only file written is this report.

---

## 1. Sources

| # | Source | What it supplied | Label |
|---:|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/CONFIG_RESTORE_01.md` | **ABSENT** — repo-wide filename glob (`**/*CONFIG_RESTORE*`) and direct path read both fail; no file to confirm | observed / UNVERIFIED |
| S2 | `reports/QA_CONFIG_RESTORE_01.md` (151 lines) | Claims 21-row table (`:54-76`), backup path (`:24`), file-level PASS (`:106-112`); does **not** contain any `configrestore01-*` job result | observed |
| S3 | `reports/QA_CONFIG_JSON_02.md` (160 lines) | Sibling QA; independently reached "REPORT-LEVEL UNVERIFIED — NO PASS PROMOTION" while recording the same 21-leaf file state (`:11,105-113`) | observed |
| S4 | `variant3d/config.json` (full read, 872 lines) | `:16-54` 21 `features` leaves / 8 groups; `:29` `relief_stamps: true`; `:80-81` 320×320; `:82` `map_type: "land"` | observed |
| S5 | `inbox/backup/config.json.bak-CONFIGRESTORE` | Exists; 14,477 B; SHA-256 `bd80c2d10d1fbfee05ec6042cb90df02269a539d561f373355db1f86348bf0f5`; `features` = 1 leaf (`terrain.relief_stamps: true`); map 320² | observed |
| S6 | `variant3d/.godot_queue/status.json` | `history` length 500; ticket 540 `configrestore01-smoke` = `ok`, exit 0; **no** ticket 541 entry | observed |
| S7 | `variant3d/.godot_queue/results/00000540_configrestore01-smoke/`, `.../00000541_configrestore01-uitest/` | Both directories exist and contain **0 entries** — no `stdout.txt`, `stderr.txt` or gate-report JSON | observed |
| S8 | `variant3d/.godot_queue/results/*.json` | Files stop at `00000538.json`; no `00000540.json` / `00000541.json` per-job result artifact | observed |
| S9 | `variant3d/.godot_queue/jobs/00000541.json` | `configrestore01-uitest`, argv `--ui-test variant3d/uitest.json`, timeout 240 s, pid 14764, created 1795605657.5739274 | observed |
| S10 | `variant3d/.godot_queue/now_serving` = `541`, `counter` = `546`, `godot.lock` = `541 1795606520.097 14764` | Runner is currently serving ticket 541; queue still live | observed |
| S11 | `git log --name-only`, `git diff`, `git status --short` | Restore committed in `2411a752` together with the backup; `QA_CONFIG_RESTORE_01.md` committed then locally edited (line/commit-note corrections only); `QA_CONFIG_JSON_02.md` untracked | observed |
| S12 | `SWARM_BOARD.md:335,344,383,387`; `CONFIG_COUNT_RECONCILED.md:176-190,209,235`; `CONFIG_PIPELINE.md:294-297`; `reports/QA_CONFIG_01_getters.md:126`; `reports/QA_CONFIGJSON_01.md:95,108-113,135`; `README.md:106-108,290,443-445,508`; `reports/README_FINAL_01.md:33,51`; `reports/RELIEF_ENABLE_01.md:58,64-72,179-180`; `reports/QA_RELIEF_ON_01.md:226-230`; `reports/MAP_SMALL_01_report.md:20` | Current stale-doc claims and their live line numbers | observed |

Tooling: `python` 3.14 (Windows) with `json.load`, recursive leaf counting, SHA-256, and regex row counting; plus `git` and direct file reads. No Godot binary was launched and no queue file was submitted.

---

## 2. Verification table

### 2.1 Landing artifact and report-content checks

| # | Task check | Finding | Result | Label |
|---:|---|---|---|---|
| 1 | `reports/CONFIG_RESTORE_01.md` exists | File absent at the exclusive path and repo-wide (only `QA_CONFIG_RESTORE_01.md` / `QA_CONFIG_JSON_02.md` match `*CONFIG_RESTORE*`) | **FAIL — nothing to confirm** | observed |
| 2 | Report has a 21-row table | Owner report absent. The **QA** report `QA_CONFIG_RESTORE_01.md:54-76` does have exactly **21** numbered rows (programmatic count = 21), and `QA_CONFIG_JSON_02.md:56-78` likewise; neither is the owner report | **UNVERIFIED for the owner report**; verified for the two QA reports only | observed + derived |
| 3 | Report names the backup path | Owner report absent. Both QA reports cite `inbox/backup/config.json.bak-CONFIGRESTORE` (`QA_CONFIG_RESTORE_01.md:24`; `QA_CONFIG_JSON_02.md:23,26`); the backup itself exists and parses with the expected 1-leaf pre-restore state | **UNVERIFIED for the owner report**; backup path independently confirmed | observed |
| 4 | Report has honest job results | Owner report absent. Neither QA report contains any `configrestore01-smoke` / `configrestore01-uitest` result — both were written before/without job evidence (see §3) | **FAIL** | observed |
| 5 | Map 320² confirmed | `variant3d/config.json:80-81` = 320 / 320; `:82` = `land`. Independently parsed: `320 320 land` | **CONFIRMED** | observed |
| 6 | Relief true confirmed | `variant3d/config.json:29` = `"relief_stamps": true`; parsed as JSON boolean `True`, inside the 21-leaf block | **CONFIRMED** | observed |
| 7 | 21-key block intact at file level | 8 groups / 21 leaves; vs `config.gd:46-84` defaults: 20 exact matches + 1 intentional override (`terrain.relief_stamps` true vs default false); 0 missing, 0 extra | **CONFIRMED (file level only)** | observed + derived |
| 8 | JSON validity | `json.load()` succeeds on current config and on `.bak-CONFIGRESTORE` | **CONFIRMED** | observed |
| 9 | Gate evidence for the config restoration | No job exercises `--dump-config` getter resolution or `--dump-map` relief emission; 540 is a parse-only check, 541 is an unfinished UI test | **UNVERIFIED — do not promote** | observed / UNVERIFIED |

### 2.2 Runner jobs named by the task

| Job | Ticket | Artifact state | Result | Label |
|---|---:|---|---|---|
| `configrestore01-smoke` | 540 | `status.json` entry: `ok`, exit 0, wait 851.96 s, run 18.17 s, timeout 180 s; argv = `--headless --path variant3d --check-only --script res://scripts/config.gd`. Referenced `stdout.txt`/`stderr.txt` paths exist **only as strings** — the result directory is empty and there is no `00000540.json` | **`ok` parse-only, artifact-less; not a functional gate** | observed |
| `configrestore01-uitest` | 541 | No `status.json` history entry; result directory empty; no `00000541.json`; job file still in `jobs/` with pid 14764; `now_serving=541`, `godot.lock` held by 541 | **NO RECORD / in-flight — UNVERIFIED** | observed |

**Derived gate reading.** Ticket 540 proves only that `variant3d/scripts/config.gd` parses under `--check-only`; it does not load `config.json`, resolve any of the 21 getters, or emit a relief key. Ticket 541, if it completes, is a generic `--ui-test variant3d/uitest.json` run with no config-restoration assertion identified in the job file. Therefore an `ok` on 540 cannot be promoted to a PASS for CONFIG-RESTORE-01, and 541 supplies no evidence at the time of this audit. [derived + inferred]

**Why "skipped/failed" is not the label here.** Unlike the 19 explicit `skipped` records in `QA_RUNNER_ARTIFACTS_01.md:118`, neither 540 nor 541 carries a `skipped` or `failed` status: 540 is `ok` (parse-only), 541 has no status record at all. The correct reporting is *artifact-less ok* and *no record*, not "skipped" and not "failed" — and in neither case a gate PASS. [observed + derived]

---

## 3. Cross-check of the two existing QA reports

- `QA_CONFIG_RESTORE_01.md:108` labels its own result "FILE-LEVEL VERIFIED / PASS — do not promote beyond file level". This QA **accepts the file-level observations** (they match an independent parse) but **does not inherit the PASS label**, because PASS was conditioned on a landing artifact that still has not landed. [observed + derived]
- `QA_CONFIG_JSON_02.md:107-113` already reached the same conclusion — "REPORT-LEVEL: UNVERIFIED — NO PASS PROMOTION" — and its stale-doc list (`:121-135`) matches what §4 below restates with current line numbers. [observed]
- `SWARM_BOARD.md:335` still marks QA-CONFIG-RESTORE-01 `RUNNING`, and `:344` marks QA-CONFIG-JSON-02 `RUNNING`; neither board row has been closed despite both reports being delivered. This is the gating state: no owner report, no board closure, no functional job evidence. [observed + inferred]

---

## 4. Stale-document corrections still needed

Read-only audit — no edits made. Paths and line numbers below are the **current** ones observed at this audit (they have shifted since the older QA reports were written).

| Doc / line | Stale or incomplete text | Suggested correction | Label |
|---|---|---|---|
| `reports/CONFIG_RESTORE_01.md` | File absent | Land the owner report with its 21-row table, backup path and honest job results; until then cite only the two QA reports for file-level state | observed / UNVERIFIED |
| `SWARM_BOARD.md:335` | QA-CONFIG-RESTORE-01 still `RUNNING` | Close as DONE only once the coordinator accepts the file-level verdict — **not** as a PASS/gate closure | inferred |
| `SWARM_BOARD.md:344` | QA-CONFIG-JSON-02 `RUNNING` | Close as DONE on acceptance; its verdict is also "no PASS promotion" | inferred |
| `SWARM_BOARD.md:383` (QA-CONFIG-01) | "no `features` object in config.json" | Annotate as historical snapshot; 21-key object present again at 320², one intentional non-default leaf | observed + derived |
| `SWARM_BOARD.md:387` (CONFIG-COUNT-01) | "**`config.json` has NO `features` object** → all getters return defaults" | Mark historical; overlay now merges 21 keys (20 defaults + relief override) | observed + derived |
| `SWARM_BOARD.md:240` (QA-CONFIGJSON-01) | "21/21 MATCH … map 240²" | Historical; current parity is 20/21 default matches + 1 intentional override at 320² | observed + derived |
| `CONFIG_COUNT_RECONCILED.md:176-190,209,235` | "contains NO `features` object" / "nothing to merge" / "no `features` object … all getters return defaults" | Annotate as pre-restore snapshot; note the restored overlay | observed + derived |
| `CONFIG_PIPELINE.md:294-297` | "global JSON override does not [exist]" | Override exists again; no unintended value deviates from default | observed + derived |
| `reports/QA_CONFIG_01_getters.md:126` | "Main inconsistencies: no `features` object" | Historical snapshot; annotate, do not silently rewrite | observed |
| `reports/QA_CONFIGJSON_01.md:95,108-113,135` | "21/21 MATCH" at **240²** (and its stale-claim table) | Current block at `:16-54` but map is **320²**; parity 20/21 + 1 intentional override | observed |
| `reports/RELIEF_ENABLE_01.md:58,64-72,179-180` | 320² "with no `features` object"; decision "do **not** re-apply the … 21-key table" | Superseded by CONFIG-RESTORE-01: block re-applied at 320², not 240²; keep old text as history | observed + inferred |
| `reports/QA_RELIEF_ON_01.md:226-230` | "exactly one change — only leaf" at `config.json:18` | Pre-restore snapshot; leaf is now `config.json:29` inside a 21-key block | observed |
| `README.md:106-108,290,443-445,508`; `reports/README_FINAL_01.md:33,51` | "21/21 MATCH" with no caveat | Re-word to "20 default matches + 1 intentional `relief_stamps: true` override; 320²"; note JSON parity ≠ runtime override | derived |
| `reports/MAP_SMALL_01_report.md:20` | Reverted config "has no `features` object" | Accurate historically; add that CONFIG-RESTORE-01 re-added the block at 320² | inferred |

Note: the older QA reports cite `SWARM_BOARD.md:376`/`:380` for the two "no features" rows; those rows are now at `:383`/`:387`. Any doc-refresh ticket should use the current numbers above. [observed]

---

## 5. Verdict

**HOLD — NO PASS PROMOTION.** [observed / derived]

- **Not confirmed:** the task's primary artifact, `reports/CONFIG_RESTORE_01.md`, does not exist. There is therefore no owner report to verify for a 21-row table, a backup path, or honest job results. [observed]
- **Confirmed independently:** `variant3d/config.json` has 21 `features` leaves in 8 groups, parses cleanly, keeps `relief_stamps: true` at `:29`, and keeps 320×320 / `land` at `:80-82`; `inbox/backup/config.json.bak-CONFIGRESTORE` is present with the expected 1-leaf pre-restore state. This is a file-level observation only. [observed + derived]
- **Jobs do not gate the fix:** ticket 540 is `ok` but only a `--check-only` parse of `config.gd`, with its referenced stdout/stderr absent and no per-job JSON; ticket 541 has no history record and is still being served. Neither demonstrates getter resolution, relief dump emission, stamping or visuals. [observed + inferred]
- **Do not promote to PASS** until the owner report lands and at least one job actually exercises the restored config at runtime (e.g. `--dump-config` showing 21 leaves with `relief_stamps: true`, and a relief dump/stamp check). [derived]

---

## 6. Open questions

1. Will `reports/CONFIG_RESTORE_01.md` land, and will it quote job 540/541 honestly? Nothing found at audit time. [observed / UNVERIFIED]
2. Why is ticket 540 recorded `ok` in `status.json` while its result directory is empty and no `00000540.json` exists — were the output files cleaned, or was the history entry written without artifacts (cf. `QA_RUNNER_ARTIFACTS_01.md:265-269`)? [observed / UNVERIFIED]
3. Will ticket 541 complete, and will its UI test assert anything about `features` or relief? The job file shows only a generic `--ui-test variant3d/uitest.json`. [observed / UNVERIFIED]
4. Does a live `--dump-config` expose all 21 leaves with `relief_stamps: true`? Derived from `config.gd` wiring in the sibling QAs, but no probe was run here. [derived / UNVERIFIED]
5. Does a live `--dump-map` emit `relief_stamps` with non-empty `plt2` entries and visible hills? Unanswered per `QA_RELIEF_ON_01` and `QA_RELIEF_DUMP_01` (job 521 timed out). [inherited / UNVERIFIED]
6. `features.terrain.m_per_tile: 2.0` is exact in JSON, but the `_copy()` whole-float→int coercion (`QA_CONFIG_01_getters.md:74`) was not re-tested. [inherited / UNVERIFIED]
7. `camera.fov_deg = 17.27` donor grounding remains PORT APPROX / UNVERIFIED; this audit proves JSON parity only. [observed / UNVERIFIED]
8. Who owns `variant3d/config.json` going forward? The restore is committed in `2411a752`, but future change ownership is not established. [observed / UNVERIFIED]

---

## 7. Summary

- **Landing artifact:** absent. `reports/CONFIG_RESTORE_01.md` was not found at its path or anywhere in the repo; the requested confirmation of its 21-row table, backup path and job results cannot be performed. [observed]
- **Available reports:** `QA_CONFIG_RESTORE_01.md` has 21 table rows and cites the backup but ends at file-level PASS with an explicit "do not promote beyond file level"; `QA_CONFIG_JSON_02.md` explicitly refuses PASS promotion for the same reason. Neither reports job results. [observed]
- **File-level state:** 21 leaves / 8 groups, 20 default matches + 1 intentional `terrain.relief_stamps: true` override, JSON parses, backup `config.json.bak-CONFIGRESTORE` present (SHA `BD80C2D1…`), map **320×320 / land**. [observed + derived]
- **Jobs:** `configrestore01-smoke` (540) `ok`/exit 0 but parse-only and artifact-less; `configrestore01-uitest` (541) no history record, in-flight at `now_serving=541`. No skipped or failed status was observed for either; neither is a gate PASS. [observed + derived]
- **Verdict:** HOLD, no promotion. Stale-doc corrections remain (board `RUNNING` rows at `SWARM_BOARD.md:335,344`; "no features" claims at `SWARM_BOARD.md:383,387`, `CONFIG_COUNT_RECONCILED.md:176-190,209,235`, `CONFIG_PIPELINE.md:294-297`, `reports/QA_CONFIG_01_getters.md:126`, and others in §4). [observed + inferred]
- **Sole output:** this report. No code, config, backup, test, runner job or other document was touched. [observed]

*End of QA-CONFIG-RESTORE-02.*
