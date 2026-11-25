---
id: QA-NATION-MODEL-01
task: "Verify NATION-MODEL-01's final report and runtime probe after landing"
date: 2026-11-25
status: COMPLETE — READ-ONLY QA; NO CODE EDIT, NO RUNNER JOB
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/QA_NATION_MODEL_01.md"
scope: "Read of the landed final report, the landed QA_NATION_IMPL_01 report, live vs pre-edit backup bytes, existing runner artifacts/status metadata, the temp probe script, donor/asset references and git state. No file outside this report was written; no Godot process started; no queue entry added."
labels: observed | derived | inferred | UNVERIFIED
label_key: "observed = literal bytes/artifact read this pass | derived = control-flow/arithmetic over observed bytes | inferred = strong but indirect attribution | UNVERIFIED = no direct evidence in this read set"
parity_claim: none
verdict: "FINAL REPORT + CODE CONFIRMED (structural); RUNTIME PROBE PARTIAL — NO nation_mesh_usage HISTOGRAM => runtime UNVERIFIED; exact-nation 3D art BLOCKED; NO PASS."
---

# QA-NATION-MODEL-01 — final report + runtime probe verification

## 1. Sources

| Tag | Source | Read this pass | Label |
|---|---|---|---|
| **R1** | `reports/NATION_MODEL_01.md` — landed; `status` at `:6`, scope `:7`, backup line `:11`, before→after `:49-66`, validation `:88-108`, open questions `:114-123` | direct read | observed |
| **R2** | `reports/QA_NATION_IMPL_01.md` — landed; verification `:35-50`, verdict `:59-64`, open questions `:66-75` | direct read; cross-checked | observed |
| **L1** | `variant3d/scripts/world3d_entities.gd` — 103,539 B, SHA-256 `4C763ABF…88951`, 2,263 lines | direct bytes | observed |
| **B1** | `inbox/backup/world3d_entities.gd.bak-NATIONMODEL01` — 93,632 B, SHA-256 `9C797DFB…75199`; matches hash cited by R1 `:11` | direct bytes | observed |
| **D1** | Python `difflib` unified diff L1 vs B1 (272 diff lines, 9 opcodes) + `git diff --no-index --numstat` scope check | direct command output | observed / derived |
| **A1** | `variant3d/.godot_queue/results/00000543_nationmodel01-smoke3/{stdout,stderr}.txt` — stdout 75 B (Godot banner only), stderr 0 B | direct read | observed |
| **A2** | `variant3d/.godot_queue/results/00000544_nationmodel01-probe3/{stdout,stderr}.txt` — stdout 1,249 B (banner + 10 `PROBE_MESH` + 6 `PROBE_ACTION` lines), stderr 0 B | direct read | observed |
| **A3** | `variant3d/.godot_queue/status.json` history entries 522/525/535/536/543/544 (id, status, exit, wait, run, argv, artifact paths) | direct read | observed |
| **T1** | `AppData/Local/Temp/opencode/nationmodel01_probe.gd` — 1,971 B temp probe; calls `_entity_mesh_sid()` / `_unit_action()` directly; writes no repo file; never reads `stats["nation_mesh_usage"]` | direct read | observed |
| **N1** | `reports/NATION_DONOR_01.md` §2.4 (`country.script:138-206`) and `data.gd:294-305` (`NATION_UNITS`) | direct read | observed |
| **O1** | Literal enumeration of `variant3d/assets/models/obj/*.obj` — 280 files this pass, 0 nation-prefixed stems; stem existence probed for each candidate | direct enumeration | observed |
| **G1** | `git status --short`, `git log --oneline -5`, `git diff --stat -- variant3d/tests/` | direct command output | observed / derived |

**Method.** L1 was compared only with its own named pre-edit backup B1. Protected regions were compared by content anchor (not line number), so insertions elsewhere cannot masquerade as identity. Runner verdicts were taken from A3 metadata and checked against A1/A2 bytes. No job was launched by this QA.

## 2. Verification table

| # | Claim under test | Expected | Observed this pass | Status | Label |
|---:|---|---|---|---|---|
| 1 | Final report landed and self-labelled honestly | Final section filled; no parity claim; visual not promoted | R1 `:6` ends `PARSE_SMOKE_OK`; `:13` `parity_claim: none`; `:12` `NO_VISUAL_PARITY`; `:21-23` says "BLOCKED, not 'fixed'", `visual = UNVERIFIED`; `:108` verdict admits `--check-only` executes no test. No PASS word in report. | **CONFIRMED** | observed |
| 2 | Backup identity | B1 hash/bytes equal to R1 `:11` | B1 = 93,632 B, SHA-256 `9C797DFBAD6864F61B9A38AAD4F4D4C600A64F79EEA4A34FB6302A9EB4E75199` — exact match to R1 `:11`. | **CONFIRMED** | observed |
| 3 | Diff scope | `+205 / −3` (R1 `:51`) | D1: 9 opcodes (6 insert, 3 replace), **+205 / −3**. Deleted lines are exactly the `MORPH_ACTION_MAP` label and the two `var sid := ed.get("sid")` lines; all other changes additive. Matches R2 `:43,:61`. | **CONFIRMED** | derived |
| 4 | Nation selection uses existing donor families only | Candidates donor-derived, probed on disk, no fabricated stem | L1 `:736-777`: units use `Data.resolve_sid()`; buildings use `_donor_building_prefix(nation,family)+base_sid`; naval appends nothing; every candidate gated by `_nation_mesh_on_disk()` → `ResourceLoader.exists(OBJ_DIR/GLB_DIR)`. Family list (`aca/art/ba2/bar/bla/cen/dip/hou/sta/tem`, `por`, `mil/tow/swa`, `wwa`, `sto/mar`, `blg/blg2`, `eur` default) matches donor §2.4; `gol/iro/coa` correctly take the donor `eur` default. O1: `strelet`, `cossackdon`, `musketeer`, `hussar` exist; `ruscen/eurmil/rusmil/bavbar` absent. | **CONFIRMED (no invention); missing art BLOCKED** | observed / derived |
| 5 | Build-order → `construct` branch present, other branches intact | `build`/`repair` + measured speed gate, dead-first | L1 `:1173-1195`: dead check first; `otype == "build" or "repair"` then `speed < WALK_SPEED_GATE_M_S` (0.15) when `speed >= 0`, else `not moving`; fall-through `walk`/`idle`/`moving` unchanged. A2 actions 6/6 match R1 `:106` verbatim (`build_still→construct`, `repair_still→construct`, `build_walking→walk`, `idle_still→idle`, `dead_builder→death`, `build_stub→construct`). | **CONFIRMED** | observed / derived |
| 6 | Rotor / stage / tree / motion blocks byte-identical | No hunk inside protected regions; declared exceptions only | Content-anchored comparison L1 vs B1: TREE consts 4,428 B equal (sha `4e247030…`), MOTION consts 1,289 B equal (`f6f14213…`), ROTOR consts 3,482 B equal (`5cfc8641…`), STAGE consts 2,129 B equal (`d387f649…`). Function-level diff: only `bind`, `_unit_action`, `add_unit`, `add_building` bodies changed + 5 new helpers; `_rotor_mesh`, `_rotor_material`, `_attach_rotor`, `_build_stage_suffix`, `_stage_mesh_info`, `_sync_building_stages`, `_measure_speed`, `_measure_band`, `_xf`, `sync`, `_player_index` all byte-identical. All 9 diff opcodes fall outside protected blocks except the declared `_unit_action` branch. | **CONFIRMED** | observed / derived |
| 7 | No invented art | No new OBJ/texture/manifest/converter write | L1 changes are constants, telemetry, helpers and meta tags only; no asset path added except the declared read-only `data.gd` preload. O1: 280 OBJs, 0 nation-prefixed. R1 `:78` explicitly states the Ukrainian look is NOT fixed. No new asset in G1 untracked set attributable to this ticket. | **CONFIRMED (absence observed); visual fix BLOCKED** | observed / derived |
| 8 | No test edits by this ticket | No test file edited; probe outside repo | R1 scope `:7` owns only L1 + R1; D1 touches no test file; T1 lives in `AppData/Local/Temp/opencode/` and writes no repo file. G1 does show two modified working-tree tests (`t_hud_layout.gd`, `t_load_usability.gd`), but their backups are named `…bak-HUDLAYOUTREPAIR` / `…bak-LOADPROBEREPAIR` and they are not in this ticket's owned set — attributed to other owners. | **CONFIRMED** (attribution of the two foreign edits **inferred**) | observed / inferred |
| 9 | Final runner artifacts match report | 543/544 ok, exit 0, zero stderr, timing as cited | A3: 543 `ok/0`, wait 671.43 s, run 24.97 s; 544 `ok/0`, wait 698.25 s, run 27.75 s — matches R1 `:103-104` exactly. A1 stdout = banner only (75 B), A2 stdout = banner + probe lines (1,249 B), both stderr 0 B, no `SCRIPT ERROR`. Earlier 522/525/535/536 also match R1 `:94-97` (525 failed = temp-script parse error, not a repo fault). | **CONFIRMED** | observed |
| 10 | Report's "verbatim selections" list is complete | All probe lines quoted | A2 has **10** `PROBE_MESH` lines. R1 `:106` quotes 8. Omitted: `sco/highlandersword chosen=highlandersword exact=false candidates=[]` and a second `tur/yacht` line (duplicate of the first). Every line R1 does quote matches A2 byte-for-byte; no false value quoted. | **PARTIAL — documentation incompleteness, not a code defect** | observed |
| 11 | Mesh-usage histogram produced | Exact `nation_mesh_usage` dict dump if the probe produced one | **No histogram exists.** A2 contains no `nation_mesh_usage` line or JSON dump; A1 is banner-only; no artifact JSON was written. T1 calls `_entity_mesh_sid()` directly and never calls `_record_nation_mesh()` nor reads `stats`. The telemetry dict exists in code (L1 `:467,:780-784`; R1 `:58,:65`) but is **not observable in any runner artifact**. Per task rule, no exact dict can be reported. | **UNVERIFIED (runtime)** — exact `nation_mesh_usage` not available | observed |
| 12 | "Generic target is conservative fallback" (R1 `:101`, `:119` item 3b) | Removed value-list heuristic labels generic targets fallback | Heuristic removal confirmed by A2 `bav/musketeer→musketeer exact=false`. **But** L1 `:166-168` appends any `rsid != base_sid` and `:176-182` sets `exact=true` on disk hit; `data.gd:296` maps `bav: serdiuk→musketeer` and `cossack→hussar`, both OBJs exist (O1), so `bav/serdiuk` would be `exact=true`. T1 does not exercise those cases. Same gap flagged by R2 `:49,:68`. | **PARTIAL** — structural **derived**, runtime **UNVERIFIED** | derived / UNVERIFIED |
| 13 | No visual-parity claim anywhere | `parity_claim: none`, labels honest | R1 `:12-13`, `:21-23`, `:78`, `:108`, `:116-123` all withhold visual/parity claims; A2 contains only structural selection/action strings, no render or capture. This QA likewise claims none. | **CONFIRMED** | observed |
| 14 | Smoke-only parse not promoted | Parse smoke reported as parse, not PASS | 543 argv is `--check-only` (A3); A1 stdout is the banner only. R1 `:108` itself states it "parses/validates but executes no test" and makes no PASS claim. This QA does not promote it. | **CONFIRMED** | observed / derived |

## 3. Runtime probe detail (A2, observed)

All 10 `PROBE_MESH` lines, verbatim:

```
rus  /units     base=musketeer       chosen=strelet           exact=true  candidates=["strelet"]
rus  /units     base=cossack         chosen=cossackdon        exact=true  candidates=["cossackdon"]
bav  /units     base=musketeer       chosen=musketeer         exact=false candidates=[]
tur  /naval     base=yacht           chosen=yacht             exact=false candidates=[]
sco  /units     base=highlandersword chosen=highlandersword   exact=false candidates=[]
rus  /buildings base=cen             chosen=cen               exact=false candidates=["ruscen"]
bav  /buildings base=mil             chosen=mil               exact=false candidates=["eurmil"]
rus  /buildings base=mil             chosen=mil               exact=false candidates=["rusmil"]
bav  /buildings base=bar             chosen=bar               exact=false candidates=["bavbar"]
tur  /naval     base=yacht           chosen=yacht             exact=false candidates=[]
```

Actions: `build_still→construct`, `repair_still→construct`, `build_walking→walk`, `idle_still→idle`, `dead_builder→death`, `build_stub→construct`.

Interpretation: these are **per-case helper return values** for 10 hand-built entity dictionaries, not a population-level `stats` dump. They confirm that nation recovery, donor candidate selection, disk gating and the build branch execute without error, and that building/naval candidates miss (fallback). They do **not** provide `nation_mesh_usage`, do not cover `bav/serdiuk` or `bav/cossack`, and do not assert any rendered result. Runtime verdict therefore stays **UNVERIFIED** for the histogram criterion and **BLOCKED / UNVERIFIED** for visual nation art.

## 4. Verdict

- **FINAL REPORT: CONFIRMED** — landed, internally consistent with artifacts, honestly self-labelled, no parity claim, no PASS promotion (items 1, 2, 9, 13, 14).
- **CODE: CONFIRMED** — `+205/−3` scope, donor-family-only candidate generation with on-disk gating, build→`construct` branch with dead-first + speed gate, rotor/stage/tree/motion blocks byte-identical, no invented art, no test edits by this ticket (items 3-8).
- **RUNTIME: PARTIAL / UNVERIFIED** — probe3 executed `ok/0` and produced helper-level selections/actions, but **no `nation_mesh_usage` histogram** was produced in any artifact; exact dict cannot be reported. The "generic target = fallback" claim is only proven for the identity case (`bav/musketeer`), not for the new `bav` remaps (items 11, 12).
- **EXACT-NATION 3D ART: BLOCKED / UNVERIFIED** — 0 nation-prefixed OBJs at both 172 and 280 file counts; Ukrainian-derived fallback remains, explicitly not visually fixed. No donor or visual parity is claimed by the report or by this QA.
- **Overall: NO PASS.** Parse smoke is parse-only and is not treated as a runtime pass.

## 5. Open questions

1. **UNVERIFIED** — Will any owner produce a `nation_mesh_usage` histogram (a probe that calls `_record_nation_mesh()` or dumps `stats`)? Until then the exact dict is unobservable and runtime stays UNVERIFIED.
2. **UNVERIFIED** — Runtime discriminator for `bav/serdiuk→musketeer` and `bav/cossack→hussar`: these were not in T1, so whether they are counted `exact=true` is derived only (item 12).
3. **observed** — R1 `:106` omits 2 of 10 probe lines while calling the list "verbatim"; will the owner amend the report? No value is misquoted.
4. **UNVERIFIED** — Visual consequence of any selector choice, donor parity of `exact=true` meshes, captured-nation sids, V7-74 morph re-acquire bypass, and `construct` pose frames in shipped skins (carried from R1 `:114-123`; no capture or render in this read set).
5. **observed / UNVERIFIED** — OBJ count moved 172 → 280 during the swarm; 0 nation-prefixed at both counts. No art owner has landed `rus*`/`bav*`/`eur*` meshes or textures, so the load-bearing fix remains blocked.
6. **observed** — `SWARM_BOARD.md` rows for nation sessions may still read RUNNING (noted in R2 `:48`); board lag, not a code fact.

## 6. Summary

- NATION-MODEL-01's final report and its two final runner artifacts are mutually consistent and were read first-hand; the backup hash and the `+205/−3` diff match its claims. [observed / derived]
- Nation mesh selection is donor-family-only and disk-gated; no art name is fabricated; the build/repair→`construct` branch is present with dead-first priority and the measured-speed gate. [observed / derived]
- Rotor, stage, tree and motion constants and method bodies are byte-identical to the pre-edit backup; only the declared regions changed. [observed / derived]
- No test was edited by this ticket; the temp probe lives outside the repo. Two working-tree test edits belong to other, named repair tickets. [observed / inferred]
- **probe3 produced no `nation_mesh_usage` histogram**, so the exact dict cannot be reported and runtime is **UNVERIFIED**; smoke3 is parse-only and was not promoted to PASS. [observed]
- Exact-nation 3D art is BLOCKED / UNVERIFIED and the Ukrainian look is explicitly not fixed; no donor or visual parity claim is made here or in the report under review. [observed / UNVERIFIED]
