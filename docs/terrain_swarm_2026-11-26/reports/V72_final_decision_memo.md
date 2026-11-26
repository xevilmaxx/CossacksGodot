---
id: V72
ticket: "TERRAIN-SWARM-2026-11-26 / V72 — FINAL DECISION MEMO for COORD (now → owner-facing verdict)"
agent: "V72 (read-only final-decision-memo worker, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_SOURCE_EDIT__NO_BACKUP_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V72_final_decision_memo.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V72_final_decision_memo.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
parity_guard: "Nothing in this memo is a gate result, a fresh capture verdict, a green JSON, a spec-READY marker or a donor-parity claim. 'PASS' below means a *prerequisite is satisfied on disk* (V63 §0), never that a gate passed. A donor frame is necessary but not sufficient for parity (X39 §4)."
multiple_passes: true
multiple_pass_note: "Every prerequisite in §7 was verified twice: a PowerShell/JSON/filesystem read and an independent dedicated read/grep of the cited report or live source. The report set drifted during this audit (V65, V64, V81, V63, V66 landed between passes); live-tree observations are marked point-in-time and COORD must re-verify immediately before acting (V63 §2). V55_python_preflight.md does not exist on disk (three checks); V63's read-only ast.parse 6/6 is the substitute. V47 is the canonical contradiction register (V47 §0/§3); V63 is the go/no-go authority; V66 is the asset-gap authority; V81 is the owner packet this memo serves."
sources_read: [
  "docs/terrain_swarm_2026-11-26/CHARTER.md",
  "docs/terrain_swarm_2026-11-26/SWARM_BOARD.md (V45 snapshot)",
  "docs/terrain_swarm_2026-11-26/HANDOFF.md (V46 refresh)",
  "docs/terrain_swarm_2026-11-26/REPORT_INDEX.md",
  "reports/V06_gate_remediation.md", "reports/V21_gate_register.md", "reports/V42_gate_commands.md",
  "reports/V47_final_contradictions.md", "reports/V49_licence_credits.md", "reports/V56_final_doc_check.md",
  "reports/V57_final_parity_statement.md", "reports/V58_i07_audit.md", "reports/V59_i09_audit.md",
  "reports/V61_composer_api_audit.md", "reports/V62_asset_completeness.md", "reports/V63_go_no_go.md",
  "reports/V64_ownership_final.md", "reports/V65_patch_verification.md", "reports/V66_asset_gap_final.md",
  "reports/V81_owner_decision_packet.md", "reports/X39_ab_feasibility.md",
  "reports/V13_stale_qa_refs.md", "reports/V33_do_not_do_checklist.md", "reports/V36_integration_checklist.md",
  "reports/V44_code_review_r3.md", "reports/V48_api_fix_plan.md", "reports/V52_owner_qa.md"
]
---

# V72 — FINAL DECISION MEMO (COORD action list, no gate result)

> **Mandatory reviewer wording (verbatim, V15 §2 / V57 §0 / V81 frontmatter):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 0. Decision in one line

**[D] Current state is NO-GO for the Godot gate packet, exactly as V63 §3 rules.** The four V36/V48 API breaks, V58's three I07 defects and V44's F-01 ownership collision are **fixed in the live tree**; the remaining blockers are the dirty runner history, the missing runtime-critical asset tiers/feed shape, two gate atoms/contracts, unsettled spec status, and the absent preflight audit. **No gate has been run, no fresh capture exists, no spec section is READY, and no donor GPU A/B frame exists.** Everything below is an action *plan* for COORD; this memo runs nothing.

**Authority order used:** live tree (re-read twice) > V63 (go/no-go) > V66 (asset gaps) > V64/V65 (ownership/patches) > V47 (contradictions) > V21/V42 (gates/commands) > V06 (ack/capture) > V57/V81 (verdict wording). A landed report that has been overtaken by later writes is named as stale, never silently re-litigated (V63 §0/§1).

---

## 1. THE single ordered action list — "now" → owner-facing verdict

Phases 0–5 are strictly ordered. **Do not start Phase 1 until every Phase-0 row is accepted.** Every row carries its owner and its exact command or paste-ready patch; the second-read evidence is in §7.

### Phase 0 — blockers to clear before ANY Godot gate (V63 §3 order preserved)

| # | Blocker (status at this read) | Owner | Exact command / patch | Accept condition → GO; otherwise STOP |
|---|---|---|---|---|
| **0.1** | **575 / 582 / 585 still unacked** (`status.json` unacked list re-read twice: `575:timed-out, 582:skipped, 585:timed-out`; counter/now_serving 607/607, lock absent). A bare `assert_clean.py --json` is DIRTY. | **COORD only** | From V06 §4.1 / V42 §4.2, verbatim reasons:<br>`python variant3d\tools\godot_runner.py ack 575 --reason "COORD policy ack 2026-11-26: diagnostic-only --check-only game.gd parse probe timed out at 300s (exit -9, run 302.44s, SCRIPT ERROR 0; B_B_CLAMP_TIDY.md:148-149). Owner retired the probe without re-submit. This records retirement, NOT a passing gate and NOT a parse proof; fresh gates are re-run below."`<br>`python variant3d\tools\godot_runner.py ack 582 --reason "COORD policy ack 2026-11-26: terminal skipped bookkeeping remnant, run=0.0, bogus error serving=2581 (G12_runner_monitor.md:128-138; G04_gate_log.md:157-165); no Godot ran and COORD cleared the stale job file. Superseded by ok jobs 568/569 (MAP240_APPLY_01.md:100-109). Records retirement only, NOT a green selftest run."`<br>`python variant3d\tools\godot_runner.py ack 585 --reason "COORD policy ack 2026-11-26: g04-uitest hung in setup and was killed at 300s (exit -9, SCRIPT ERROR 0; G04_gate_log.md:183,197-211); follow-up 587 hit the 120s watchdog and the on-disk 17/17 predated both runs, so no fresh PASS was claimed. Superseded by ok job 569 at 240x240 (MAP240_APPLY_01.md:101,108-109). Records retirement, NOT a green uitest."`<br>Then `python variant3d\tools\godot_runner.py status` and `python variant3d\tools\assert_clean.py --json`. | `verdict=CLEAN`, exit 0, `reasons=[]`, `processes.count=0`, `lock.state=free`, `history.enabled=true`, `history.total=500`, `history.acknowledged>=3`, `history.failures=[]` (V42 §4.2 / V06 §4.1). A fourth leak gets **its own reason**; never `--ignore-history`, deletion, status hand-editing, `reset --yes`, `doctor`, `cancel` or `unwedge`. |
| **0.2** | **Volatile tree / unverified freeze.** HEAD `e234ac9b`; `app/` clean at this read, but gen/props hashes drifted twice during V61/V65 and reports landed mid-audit. | **COORD** | `git rev-parse --short HEAD`; `git status --short -- variant3d/ -- app/`; `git diff --exit-code -- app/`; `Get-FileHash -Algorithm SHA256 -LiteralPath 'inbox\backup\main.gd.bak-COORD-I11','inbox\backup\world3d.gd.bak-COORD-I11','variant3d\scripts\terrain_donor_world.gd','variant3d\scripts\terrain_donor_gen.gd','variant3d\scripts\terrain_donor_mesh.gd','variant3d\scripts\terrain_donor_props.gd','variant3d\scripts\terrain_donor_data.gd','variant3d\tests\t_terrain_donor.gd'`; re-run V48 §7.2 negative greps (expect **0** hits) and §7.3 positive greps (expect **1** each); seam greps `main.gd:125,189-191,593-594,1112-1113` / `world3d.gd:144,220-224,624,645`. | HEAD stable, `app/` empty + diff exit 0, backups equal `3859B605…` / `44EE96C0…` (re-read: exact full digests in V65 §8), seam present **once**, all six API pairs still static PASS, no file changes across two reads. Any moving file/missing backup/second seam → **wait, do not restore** (V36 §6 step 0). |
| **0.3** | **One-writer/ledger residue.** V44 F-01 is **fixed in source** (V64 §3; live `decode_pattern_lib.py:1059-1061` emits only `lib/pattern_lib_index.json`), but stale `patterns/family_index.json` + 64 `patterns/families/*.json` remain and V11 G3/G4 now have no emitter; G5 pins `patterns/` while I03 emits `lib/` and I09 reads `patterns/`. | **COORD + I02/I03/I09 owners** | Written decision, one canonical feed path and one writer (V64 §3 actions a–c; V62 §4 C2; V66-F3). Either amend V11 G3/G4/G5 **or** change the tool/consumer — **never both silently**. Quarantine stale outputs under file-scoped backup rules; add a write-collision guard to both decoders; pick the path I09 actually loads before running any `--write`. | One owner per emitted path; no two tools write the same file; decision recorded with owner + `file:line`; contradictions C2/C3/C4/C5 preserved (V47 §6 R1). |
| **0.4** | **Runtime-critical asset tiers absent (P0).** 780 JSON / 242,316,351 B in `cfg/` + `patterns/` only; `atlas/`, `masks/`, `lib/`, `schemas/`, root `manifest.json` all ABSENT (two disk passes + my two `Test-Path` passes). I08 falls back to the legacy 179.9 MB atlas; I09 falls back to legacy `mountain_props.json`. | **COORD + I05/I03; N6 unowned → COORD must name an owner** | Exact tool-source-reconstructed commands from V66 §3 (V53 report absent):<br>`python variant3d\tools\build_terrain_new_atlas.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\atlas --cell 128 --dry-run --check`<br>`python variant3d\tools\build_terrain_new_atlas.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\atlas --cell 128 --write --check`<br>`python variant3d\tools\decode_pattern_lib.py --game "C:\Games\Cossacks 3" --dry-run --check`<br>`python variant3d\tools\decode_pattern_lib.py --game "C:\Games\Cossacks 3" --write --check` (emits `lib/`; redirect with `--out ...\patterns` **only after 0.3**)<br>`python variant3d\tools\decode_donor_masks.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\masks --check` then the same with `--write` (P2, optional for first gate).<br>**M18 has no existing command:** author an I09 `_try_feed()`-compatible record shape keyed by stamp name (`props`/`objects`/`records`/`by_pattern`) from `patterns/families/*.json` `sections[].blocks[].records` (`BaseName.value`, `Position.*`, `Up.*`, `Scaling.*`) — V59 §4 / V66-F1. **M17/N6:** author or explicitly retire the X15-conformant root `manifest.json` producer; I05's `--emit-root-manifest` is explicitly partial and `cfg/manifest.json` is not a substitute (V66-F5/C5). | Before a donor-backend capture: I08 `stats.atlas.paths` points **inside** `terrain_new/atlas/`; I09 `stats.feed.source` is a `terrain_new` path **and** `fallback_used=false` **and** `counts.props_total > 0` (V66 §5 item 3). Do **not** close on `feed_source` alone: V66-F1 shows a `generator_families` array can make `_try_feed()` return true with **zero props** and a false `DONOR LITERALS` label. M04 must be X15-conformant, not the partial atlas-only file. |
| **0.5** | **GR-A24 relief-props atom hard FAIL.** `t_relief_props_qa.gd:30` = `res://assets/terrain/terrainmesh_props.json` (absent twice); live file is `mountain_props.json`. | **Named QA atom owner (V13 R-S1 / COORD deconflict)** | Single-line repoint: `const PROP_MANIFEST := "res://assets/terrain/mountain_props.json"`. Re-read the file before editing; keep `:89-93`, `:286-311`, `:337-439`, `:518-528`, `:710-731` and `expected_pre_fix_failure: true` (`:158`) intact; keep `SCALE_WANT=1.0` (`:42`), `BBOX_TOL=0.05` (`:41`) and the count unchanged. | Atom loads a real manifest with `by_pattern`/`bbox_m`; a zero-stamp or manifest-load failure is still rejected; remaining documented Z07/Z08 interface gaps stay honest FAILs, never lowered (V13 §3 R-S1, V21 GR-A24). |
| **0.6** | **I12 unregistered + 320² not hard.** manifest count **40**, last `t_select_rect`, no `t_terrain_donor`, no `.bak-I12` (two reads). Test has `SIZES := [64, 240]`, `RUN_320_OPTIONAL := false` (`:60-61`). | **COORD + I12** | Take `Copy-Item variant3d\tests\manifest.json inbox\backup\tests_manifest.json.bak-I12` first; append **exactly one** `{id:"t_terrain_donor"}` entry **last**; verify count 40→41 and last id. Then either add `320` to `SIZES` (`:60`) or attach a COORD-signed waiver for V21 D-2. | Backup exists; count 41; last id correct; 320² is hard or explicitly waived by COORD — never relabel a hard gate "optional" (V63 row 15, V38 F-V38-04). |
| **0.7** | **Spec status not READY; contradiction register not repointed; V55 absent.** V56 D-01/D-02/D-03/D-07 remain; V47 is the canonical register but the board/index still carry C1–C9-only tables; `V55_python_preflight.md` absent (three checks). | **COORD (docs only)** | Apply V56 paste-ready text (or record explicit "FILE PRESENT — not READY") and repoint board/index to `reports/V47_final_contradictions.md` as canonical. Record V63's read-only `ast.parse 6/6` + `numpy=True, PIL=True` as the Python preflight, or land V55. Keep `--policy advisory` everywhere (V21 §7.2). | No fabricated READY marker; no `--policy red` flip; `blocking_unverified` stays honest; V47's 33 RESOLVED / 4 PRESERVED / 2 IMPLEMENTATION / 4 UNVERIFIED counts and O-A…O-S owners preserved (V47 §2/§5). |
| **0.8** | **Donor settings not wired into the composer.** Live `terrain_donor_world.gd:220` still `var gen_params: Dictionary = {}`; I07 logs labelled PORT placeholder `0` seeds (V65 §3, V61 Q1). Static PASS ≠ donor inputs. | **COORD (composer) + I07 owner** | Pin `randkey0/1`, `mapsize`, `width/height`, `patterns`, `families` and tile dictionaries into that Dictionary from donor-cited values before any A/B; keep the labelled skip/placeholder behaviour for genuinely `[U]` inputs. Add explicit `gen_applied`/`mesh_built`/`props_applied` **stream** assertions (V48 §7.5) — `_call_adapt` returns true on dispatch only. | No invented donor constant; no assertion weakened; an inert backend cannot shallow-pass; every donor number carries `path:line`. |
| **0.9** | **Licence/CREDITS + private-use hygiene before owner-facing verdict.** V49 block missing from `variant3d/CREDITS.md` (0 hits, two checks); 780 untracked assets; four large legacy files still tracked with no ignore rule. | **COORD only; never touch `app/**`** | Append V49 §5 block to **`variant3d/CREDITS.md` only**; add V49 §6 private-use statement to `HANDOFF.md` §0/§5; re-check the absolute-donor-path issue before commit — **live re-read (Python, 780/780 JSON) found 0 files containing `C:\Games\Cossacks 3`**, so V49 §0 item 6 / V66-F4 are point-in-time and now corrected; re-verify anyway. Decide `.gitignore` / `git rm --cached` / LFS for the four large tracked files (V49 §4). | No donor binary committed; no `app/` edit; no parity wording; no absolute private path in committed bytes; owner-only/never-redistribute statement present. |

**Phase-0 GO gate:** all nine rows accepted. **NO-GO** means stop, fix the named cause, re-read; never "run until green" and never weaken an assertion (CHARTER §4, V21 §6).

### Phase 1 — exact gate sequence (V42 ids, V21 pass criteria)
See §2. One Godot at a time; unique `v42-` ids; `status` after every `run`; keep `terrain_backend` at `legacy`; `--policy advisory` throughout.

### Phase 2 — fresh captures and A/B protocol
See §4. Outside-repo `<T>`; three explicit overlays; one job at a time.

### Phase 3 — failure handling and rollback
See §3. Applied immediately on any trigger; never delete an assertion.

### Phase 4 — owner-facing verdict
See §5. Fill `TODO(COORD)` cells only from fresh result JSONs with mtime after job START; parity stays `UNVERIFIED` unless Phase 5 succeeds.

### Phase 5 — owner-only inputs
See §6. Without the owner's donor frame + manifest, parity is **permanently declared UNVERIFIED** (X39 §0 point 6), not a gate failure and not "donor match".

---

## 2. Exact gate sequence, unique ids and pass criteria

**[O] V42 §4 commands are copied from source-verified flags; this memo does not re-derive or invent any flag** (`godot_runner.py` `run --id/--timeout/--max-wait`, `status`, `ack <ticket> --reason`; `assert_clean.py --json/--max-lock-age/--ignore-history` — the last is forbidden here). **[U] V55_python_preflight.md is not landed; V63's `ast.parse 6/6` substitute is the preflight evidence — syntax OK is not decoder byte validation.** V21/V42/V57 supply pass criteria; no V55 criteria can be cited because no V55 file exists.

Conventions: run from repo root on Windows with `python`; PowerShell `;` never `&&`; `<T> = C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42` (**outside the repo**); Godot paths use forward slashes; substitute the real 8-digit ticket from `status` wherever `<ticketN>` appears; after **every** `run`, call `python variant3d\tools\godot_runner.py status` and re-check `pending=0`, lock free, counters aligned before the next job (V42 §4 intro). **Never accept exit 0 alone**: require result envelope `status=ok`, `exit=0`, `SCRIPT ERROR=0`, fresh result mtime **after that job's START**, and `smallmap_capture.py scan-stderr` `script_error_lines: 0` (V06:130, V42:86).

| Station | Unique ids to submit (V42 §4) | What it does | Pass criteria (V21 §4/§6 + V42 acceptance) |
|---|---|---|---|
| **A′-0** | **no run**: `status`, `assert_clean.py --json`, `git status --short -- app/`, `git diff --exit-code -- app/`; then the three `ack` calls of row 0.1 and repeat. | Preflight, evidence-backed acks, plain CLEAN. | GR-A00/GR-A22: `pending=0`, lock free, `now_serving==next_ticket`, CLEAN with `acknowledged>=3`, `failures=[]`, `app/` empty (§0.1). STOP if a fourth leak appears. |
| **A′-1** | `v42-parse-data`, `v42-parse-gen`, `v42-parse-mesh`, `v42-parse-props`, `v42-parse-world`, `v42-parse-main`, `v42-parse-seam-world`, `v42-parse-tdonor`; `v42-shader-smoke`. Plus `python -m py_compile` on all six tools. | One parse job per new `.gd`; headless test-script smoke for the `.gdshader` (no `--check-only --script` for shaders). | `SCRIPT ERROR=0`, no parse errors, no shader compile line; headless `SKIP_CAPTURE`/`passed=false` is expected here and is **not** a gate PASS (V42 §4.3). Do not add jobs for the absent `terrain_donor_tiles.gd` or retired shader alias (both optional). |
| **A′-2** | **no run**: `Test-Path` on `V17_spec_readiness.md`, `X13_blend_test_vectors.md`, `terrain_qa_harness.py`, `spec/terrain_qa_spec.json`. | Evidence checkpoint; record which class-B bands stay `[U]`; set `--policy advisory`. | GR-B01…B16 + GR-C09: **no `[U]` band promoted, no threshold changed**; policy recorded in gate log. STOP if a band is hardened (V21 A′-2). |
| **A′-3** | **no run**: `Get-FileHash` ledger over all tools/modules/test/shader/config/QA spec. | Freeze SHA-256 ledger; no gate result claimed. | Complete ledger; keyed to the Phase-0.2 freeze. |
| **D-0** | **no run**: repeat preflight + `manifest.json` count check. | Integrated-tree preflight. | Same as A′-0 **plus** count 41 with `t_terrain_donor` last, one const/var/setter/ternary seam (V11 §8). Any miss → rollback. |
| **D-1** | `v42-reparse-seam-main`, `v42-reparse-seam-world`, `v42-relief-props-atom`. | Final-tree static + stale relief atom. | Parse clean; **GR-A24 repointed without lowered `SCALE_WANT`/`BBOX_TOL`/count** (row 0.5). Re-run V58's nine I07 items against the frozen tree; do not inherit stale FAILs (V63 row 4). |
| **D-2** | `v42-dump-64-a`, `v42-dump-64-b`, `v42-dump-240-a`, `v42-dump-240-b`, `v42-dump-320-a`, `v42-dump-320-b`; then `scan_map.py --dir <T>/dumps`, `smallmap_capture.py scan-stderr ...`, `Get-FileHash` on the six dumps, `assert_clean.py --json`; optional N16 lane `terrain_qa_harness.py --dump-a ... --dump-b ... --seed-manifest ... --policy advisory --out ... --check`. | Determinism/structure lane, one job at a time, pinned overlays. | GR-A01: two runs per size ⇒ **all five streams byte-identical at zero tolerance** (`height` f32, `tileblock`, `terrain`, `blocked`, prop/cluster/stamp set); provisional whole-file SHA is `[D]` only until the harness fingerprint runs. GR-A02: status ∉ {`timed-out`,`error`,`skipped`}, `script_error_lines=0`, mtime after START, CLEAN. GR-B01 cross-size deltas advisory. `scan_map.py` **ALL GREEN** exit 0; never relax `scan_map.py:478-493` (V42 §4.8). |
| **D-3** | `v42-rendermode`, `v42-terraindonor`, `v42-mapvariety`; `smallmap_capture.py scan-stderr` on all three. | Headless structural gates. | `t_render_mode.json` `passed=true`, `result=PASS`, `seam_missing=false`, **10/10**; `t_terrain_donor.json` `passed=true`, **no class-A FAIL**, every `[U]`/HOOK_MISSING row advisory and never promoted; `t_map_variety.json` **5/5**; all mtimes after START (V42 §4.9). GR-A05…A21 red, GR-B02…B08 advisory statuses recorded verbatim. |
| **D-4** | `v42-cap-64`, `v42-cap-240`, `v42-cap-320`; `smallmap_capture.py stats`/`scan-stderr`; freeze `*_baseline.png` + SHA-256 manifest. | Fresh windowed captures (§4). | GR-C01/C02/C10: admissibility G0-a…e, 1280×720 non-blank, `full_width_dark_rows=0`, `script_error_lines=0`, stdout camera/config diag recorded, baselines frozen outside repo and labelled by **actual** size. Any inadmissible frame → UNVERIFIED, no rerun-for-green. |
| **D-5** | `v42-selftest`, `v42-uitest`, `v42-rendermode-final`, `v42-mapvariety-final`; `assert_clean.py --json`; `git status --short -- app/`; `git diff --exit-code -- app/`. | Final regression on the integrated tree. | **selftest 29/29**, **uitest 17/17**, `t_render_mode` PASS `seam_missing=false`, `t_map_variety` 5/5, `assert_clean` CLEAN, `app/**` byte-identical, every JSON fresh with mtime after START; `--timeout 600` after the second `--` is mandatory or selftest/uitest force-exit near 120 s (V42 §4.11, V06:221). |
| **D-6** | **no run**: read-only unacked check from `status.json`; `git status --short -- app/`; COORD writes the report. | Owner-facing sign-off (§5). | GR-A23/GR-C08: `blocking_unverified = []`, no hard FAIL, no parity wording, three-tier class verdicts, metric and visual fields separate. Any required UNVERIFIED ⇒ `RESULT IS NOT GOOD` + hold/rollback (V21 D-6). |

**Sequence invariant (V21 §6 / V42 §0):** A′-0 → A′-1 → A′-2 → A′-3 → D-0 → D-1 → D-2 → D-3 → D-4 → D-5 → D-6. Determinism precedes structure; structure precedes visual; regression runs last; no worker self-certifies. **No gate result is claimed by this memo.**

---

## 3. What to do on each failure class

**Universal rules:** stop the sequence at the failing station; record the ticket id, result envelope, stderr line and mtime in the gate log; never re-run until green; never lower a threshold, delete an assertion, invent a donor band/constant, or write a parity claim (CHARTER §4, V21 GR-A23). A decision to continue is COORD's alone and must be written with owner + `file:line`.

| Failure class | Immediate action | Forbidden |
|---|---|---|
| **Unacked runner leak (575/582/585 or a fourth)** | `godot_runner.py ack <ticket> --reason "<evidence-backed text>"` (row 0.1), then plain `status` + `assert_clean.py --json`; a fourth leak gets **its own** reason. Acks record **retirement of retired diagnostics**, not passing gates (V06 §4.1). | `--ignore-history`, deleting `results/*.json`, hand-editing `status.json`, `reset --yes`, `doctor`, `cancel`, `unwedge`, widening the failure set. |
| **`status.json` desync** (`now_serving != counter`) | STOP; report the desync; do not submit further jobs. Historical `serving=2581` on 582 is a documented spool artifact, not a live desync (V06 §3). | Speculative `unwedge`/`reset`. |
| **D1 byte mismatch / dirty runner / `timed-out|error|skipped`** | **ROLLBACK** via §3.1; record reason in the report `rollback` block; re-run **D-5** to green only after restore. | Re-running the failing job until green, accepting whole-file SHA as D1 (it is `[D]` only). |
| **Any red structural FAIL** (GR-A05…A24, illegal tile id, unknown stamp/family, smoothing-vector FAIL, stale relief atom, food rect, deposit capacity, mixed seed policy) | **ROLLBACK**; fix the cited cause with an owner-assigned patch using donor `path:line`; verify both sides of the call/value; re-enter at D-1. | "Fixing" a PRESERVED contradiction (V47 §6 R1): `TileSmoothPasses=6`, plain `tilesmooth.cfg`, swamp header `17×20`→`18×23`, port 8 zero ids vs `alphanull`, per-ore radii, `[Min,Max]` clamp, R→height. |
| **Threshold lowered / assertion deleted / invented band or constant / parity wording** | Treat as GR-A23 FAIL → **ROLLBACK**; restore assertion verbatim; if a boolean self-check is tautological (`terrain_qa_harness.py:784`, V44 E16), compute a real predicate without changing any shipped threshold. | Any silent edit; "cosmetic" justification; keeping the weakened gate. |
| **`app/**` hash drift / freeze-set diff nonzero** | **ROLLBACK** file-scoped; verify `git diff --exit-code -- app/` exit 0 at A′-0 and D-5. | `git reset --hard`, `git checkout .`, `git clean`, blanket `Copy-Item`, deleting `.bak`. |
| **Mixed aperture / headless fallback / blank / wrong-size / inadmissible capture** | Reject the frame as UNVERIFIED; verify stdout config/camera diag; inspect `<name>.png.raw.png` sidecar and record an **instrument defect**; use direct runner jobs with absolute paths (§4). | Editing the blank detector; accepting an 800×600 headless frame; calling a 240² config frame "320²"; retrying the same ROI until green. |
| **Advisory (class B) FAIL** | Record `PASS|FAIL|UNVERIFIED|NOT_APPLICABLE|RECORDED_NOT_APPLICABLE` verbatim with labels/evidence in `terrain_qa_report.json`; keep `--policy advisory`. | Silent promotion to PASS, promoting a band before V17 READY + N17 donor evidence + COORD sign-off. |
| **Visible R1–R6 artifact despite green metrics** | `RESULT IS NOT GOOD` + **ROLLBACK**; metric never overrides the visual read; a green `compare_shots.py` number cannot erase rings/veins/grid (V21 GR-C03). | Rerun-for-green, dropping the ROI, "close enough" wording. |
| **Non-empty `blocking_unverified` at D-6** | Hold; conservative owner reading `RESULT IS NOT GOOD`; keep `declared_unverified` accepted and `blocking_unverified` explicit (V15 §2). | Signing a report with `blocking_unverified=[]` while D3/capture/CLEAN are missing. |

### 3.1 File-scoped rollback (COORD only) — from `V42 §6` / `V36 §7`

```powershell
# 0) Re-verify baselines before touching anything
Get-FileHash -Algorithm SHA256 -LiteralPath 'inbox\backup\main.gd.bak-COORD-I11','inbox\backup\world3d.gd.bak-COORD-I11','variant3d\scripts\main.gd','variant3d\scripts\world3d.gd','variant3d\tests\manifest.json' | Format-Table -AutoSize

# 1) Backup the CURRENT integrated state (id-level), never blanket-copy
Copy-Item variant3d\scripts\main.gd inbox\backup\main.gd.bak-V42-ROLLBACK
Copy-Item variant3d\scripts\world3d.gd inbox\backup\world3d.gd.bak-V42-ROLLBACK
Copy-Item variant3d\tests\manifest.json inbox\backup\manifest.json.bak-V42-ROLLBACK

# 2) Restore the two EDIT files from their SHA-verified COORD-I11 backups
Copy-Item inbox\backup\main.gd.bak-COORD-I11 variant3d\scripts\main.gd -Force
Copy-Item inbox\backup\world3d.gd.bak-COORD-I11 variant3d\scripts\world3d.gd -Force
Get-FileHash variant3d\scripts\main.gd,variant3d\scripts\world3d.gd,inbox\backup\main.gd.bak-COORD-I11,inbox\backup\world3d.gd.bak-COORD-I11 -Algorithm SHA256
# expected: 3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8 (main)
#           44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A (world3d)

# 3) Manifest: id-level removal ONLY (no bak-I12 existed at V42; take one before any append)
python -c "import json,pathlib; p=pathlib.Path('variant3d/tests/manifest.json'); d=json.loads(p.read_text(encoding='utf-8')); d['tests']=[t for t in d['tests'] if t.get('id')!='t_terrain_donor']; p.write_text(json.dumps(d, indent=2)+chr(10), encoding='utf-8')"

# 4) Delete ONLY the explicit creation-ledger files (no wildcards)
Remove-Item variant3d\scripts\terrain_donor_world.gd,variant3d\scripts\terrain_donor_data.gd,variant3d\scripts\terrain_donor_gen.gd,variant3d\scripts\terrain_donor_mesh.gd,variant3d\scripts\terrain_donor_props.gd,variant3d\tests\t_terrain_donor.gd,variant3d\shaders\terrain_donor_shader.gdshader

# 5) Composition returns to legacy through the existing switch; do NOT edit the switch to force donor.
#    Keep inert tools/assets and every .bak; re-run D-5 to green; record the reason.
```

**Never** `git reset --hard`, `git checkout .`, `git clean`, blanket `Copy-Item`, delete `.bak` files, or delete assertions. Generated `assets/terrain_new/**` is a creation ledger: remove only files listed in its emitted root manifest, leaving `assets/terrain/**` untouched (V36 §7).

---

## 4. Fresh-capture protocol (V06 §4.4 / V42 §4.10)

**One Godot at a time; all artefacts outside the repo.** `<T> = C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42`. Pin all three overlays explicitly; the shipped `config.json:75-76` is 240² — never label it 320². Do not start Phase-2 captures before Phase-0 and D-1/D-3 are accepted.

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps" | Out-Null
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":64,"map_height_tiles":64}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_64.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":240,"map_height_tiles":240}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_240.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":320,"map_height_tiles":320}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_320.json" -Encoding ascii -NoNewline
```

```bat
python variant3d\tools\godot_runner.py run --id v42-cap-64 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_64.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_64.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-cap-240 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_240.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_240.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-cap-320 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_320.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_64.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_240.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v42-cap-64\stderr.txt variant3d\.godot_queue\results\<ticket>_v42-cap-240\stderr.txt variant3d\.godot_queue\results\<ticket>_v42-cap-320\stderr.txt
```

**Rules (both protocols agree):** **no `--headless`** (800×600 CPU fallback); `--screenshot-frames 10` selects the real viewport path; `--timeout 600` after the second `--` overrides the 120 s watchdog and runner `--timeout 700` must exceed it; **never combine `--dump-config` with `--screenshot`**; require 1280×720, non-blank, `full_width_dark_rows=0`, `script_error_lines=0`, and record stdout `camera_current=true`, `world_parent=Screenshot3DViewport`, plausible camera pos/target before accepting a frame. If the blank detector falsely rejects, inspect `<name>.png.raw.png` and record an instrument defect — do not edit the detector (V06 §4.4).

**Freeze outside the repo + SHA-256 manifest:** `Copy-Item <T>\cap_{64,240,320}.png <T>\cap_*_baseline.png`, then `Get-FileHash` the three baselines, three overlays and `--seed` in the gate log (V42 §4.10). Determinism dumps use the same `<T>/dumps` directory with unique ids `v42-dump-{64,240,320}-{a,b}`; `scan_map.py --dir <T>/dumps` never scans stale JSONs.

**Metric ceiling:** `terrain_ab_metric.py` is SMOKE-only — no `--baseline`, no ARI; like-with-like crops only, donor-folder distribution is a hint only; `compare_shots.py --threshold 0.9999` is legal **only** for candidate-vs-candidate same-scene determinism; donor-vs-candidate SSIM is forbidden unless COORD first proves A/B-L1/L2 matched scene/camera/ROI (X39 §4, V21 GR-C06/C07, V06 §4.5). **No metric overrides the visual read.**

**Aperture trap:** eight `variant3d/tools` scripts are byte-identical `app/tools` copies that still boot `app/` or read `app/.godot_queue`. Use the direct runner commands above; prefer explicit `--path variant3d` and absolute `--config`/`--screenshot`/`--dump-map`; verify aperture from **stdout config/camera diag**, never from the tool's folder (V06 §4.3, V42 §5). Never run `full_map_shot.py --gen-dump`, `terrain_sample_shot.py --capture` or `terrain_land_shot.py --capture` as a fresh gate (hardcoded `app/`).

---

## 5. Final honest verdict statement template (V57 three tiers)

Fill only from fresh evidence; keep the reviewer line verbatim in **every** owner-facing capture/report. `parity.claim = NONE`; `parity.status = "UNVERIFIED"` until Phase 5 is complete **and** COORD rules a demonstrated match.

```markdown
# Owner verdict — DONOR-FIRST terrain port (2026-11-26)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## Verdict
No — terrain is not cloned: the donor's terrain-relevant data formats and a small set of
named functions are byte-exactly decoded and a donor-shaped port scaffold exists, but no
donor GPU A/B frame, no gate result and no runtime observation exist, so the honest verdict
is PORT APPROXIMATION with donor parity UNVERIFIED. [V57 §4]

- Gates: <selftest N/N; uitest N/N; t_render_mode PASS/seam_missing; t_map_variety N/N;
  scan_map ALL GREEN; assert_clean CLEAN; app/** byte-identical; all JSON mtimes after START>
  — or "NOT RUN / TODO(COORD)" until COORD fills it from fresh result JSONs.
- Declared parity gaps (accepted): mountains, sea, iron/coal mines, rivers, swamps; packed
  stubs; 972 `;`-prefixed excerpts with execution [U]; row-sign flip; blend pass count;
  x87 precision; hmapTex binding; native kernels. [V57 §2.3 U1–U15]
- Blocking unverified (not accepted): <list missing D3 dump integrity / no admissible
  capture / dirty runner / unresolved numeric contradiction>. If non-empty ⇒ RESULT IS NOT GOOD.
- Best honest outcome after all gates pass: "gates green / internal consistency PASS /
  donor parity UNVERIFIED". There is no tier above 2 and no "donor match" tier. [V15 §2, V57 §5.3]

## Three-tier class table (V15 §2 vocabulary; no tier above 2)
| Class | Tier 1 DONOR-GROUNDED STRUCTURE | Tier 2 SELF-CONSISTENT VISUAL | Highest honest tier | Declared UNVERIFIED |
|---|---|---|---|---|
| Hills / relief | evidence prepared, unsigned (D3 not run) | criteria drafted, unobserved (no capture) | evidence only / parity 3 | donor look, camera unknown |
| Mountains | g_mnt grids + terrainmesh4 + 112 prop records | silhouette +4 m / +2 m, ON/OFF ≥200 px, matched_stamps>0 | parity 3 | no donor still; "highlands" false positive |
| Mill fields | 49-node _unit_DoSeedWheat, no food rects | golden parcels, no checkerboard/dither | parity 3 | runtime activation of commented callers |
| Sea / shore | four water literals, ids 93/97/98, blend func | continuous beach→foam→water, foam offshore | parity 3 | plane Y, hmapTex, pass count, foam width |
| Forests / stone | family weights; stones family mapping [D]/[I] | natural spacing, clustered boulders | parity 3 | donor pixels; quarry identity |
| Gold / iron / coal mines | mng/mni/mnc, ring→ore→256, no capacity | mesh on centred disc, no orphan rings | parity 3 | no identifiable iron/coal still; snap/capacity |
| Swamps / lakes | zero-height swamp, no water plane; PRESERVED header | soft wet patch, no water plane | conversion gap / parity 3 | activation; lake_big anomaly |
| Rivers | only DLC5 mask path | none permitted | OUT_OF_SCOPE | all semantics; no ford threshold invented |

Combination rule: tier 2 never implies tier 1; tier 1 never implies tier 2; an item stays at
its highest *actually reached* tier. Metric and visual fields are separate. [V57 §2.3]
```

**Upgrade conditions are conditions, not achievements** (V57 §5): owner-run same-camera donor frame (§6) + admissible candidate capture + proven matched manifest (A/B-L1 or L2) + fresh green gates/D1/D3 + spec/toolchain completed + COORD's explicit ruling of a byte-identical geometry and pixel-identical frame. Until **all** hold, `parity.status` stays `UNVERIFIED` and any "parity/cloned/confirmed" wording is a defect. When an owner frame first lands, update the reviewer line to "Donor frame supplied by owner; parity still UNVERIFIED pending demonstrated match" (X39 §4 note).

---

## 6. What ONLY the owner can provide

No worker or assistant may run or copy donor material (CHARTER §4). These are owner actions; the assistant issues no execution instruction to itself.

1. **A same-camera, same-seed, same-size donor GPU A/B frame — X39 Route A, the only viable route.** Owner personally launches `C:\Games\Cossacks 3\cossacks.exe`, generates/saves a map and captures a PNG; artefacts stay **outside the repo** (recommended `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.{map,png}`), never committed. Written manifest, one line each (X39 §3):
   - size `mapsize=0` → **320×320** (no donor 240² enum; 240² remains port-only; pin donor A/B at 320²);
   - map type **TerrainTypes 0 Land** (`nowater2`), or record the actual enum chosen;
   - season int **0 Summer** (2 Winter / 3 Desert only if deliberately testing those);
   - seed keys `randkey0` (u32 high) and `randkey1` (u32 low) supplied explicitly; `randkey1` appears in `game_v<ver>k<randkey1>.map`; mark `UNKNOWN` if `randkey0` is unreadable — that downgrades the comparison;
   - camera profile `data\cameras\camera.cfg` (not screenshot/debug), tilt **−32°**, focal **400**, dolly **20…58**, DepthOfView **1200**, actual zoom/dolly logged; donor absolute FOV is `[U]`, port assumes 17.27°;
   - **1280×720 windowed**, no HUD over the ROI, donor build/version string, PNG SHA-256, saved `.map` path;
   - ground-only fractional ROI `(x0,y0,x1,y1)` confirmed on **both** frames — an ROI on sky/HUD/units is UNVERIFIED, not retried until green;
   - written attestation "donor launched by owner; assistant never executed donor".
   **A donor frame is necessary but not sufficient** (X39 §4): `GenerateMapRandKey`, saved-map key bytes, donor FOV and runtime activation are `[U]`, so same seed keys do not guarantee the same scene. Parity needs a demonstrated match under a proven-matched manifest, labelled `DONOR (owner-run)` / `PORT (candidate)`, with metric and visual fields separate.
2. **DLC entitlements / scope decision.** Winter (`season=2`) needs `gc_lastknowndlc_dlc2` or deluxe; desert (`season=3`) needs `gc_lastknowndlc_dlc3` or deluxe (F10/X30). The 49 baked DLC `.map` files are deferred and there is no folder→DLC manifest (F10 E42). Decide whether season/lake/DLC5 terrain is in scope and supply entitlements; otherwise keep it declared out-of-scope with reasons. Coastal/Lakes/Rivers masks are shipped skirmish content (no entitlement check); the open question is whether COORD opens the DLC5 rivers/lakes ticket — rivers stay `OUT_OF_SCOPE` with no invented ford threshold (V47 V47-27, V52 §7.3 #2).
3. **Decision on a permitted read-only donor runtime / GL trace** (known-key `.map` replay pack, GPU capture). Without it, `;`-prefixed runtime activation, `bmTransparency` pass count, `hmapTex` binding and native kernels stay permanently `[U]`.
4. **Sign-offs:** the `declared_unverified` / `blocking_unverified` split (V15 Q1); canonical capture size (240² vs 320²) and camera/ROI set (V15 Q7); whether to fund VMT-pointer discovery + a second lifter (Ghidra/IDR/ImHex/Cutter/HxD) for the 4,265/12,254 garbled functions and 23 missing anchors.
5. **If the owner declines or cannot run the donor:** no route is viable; report parity as **permanently UNVERIFIED (declared, accepted)** — never as a gate failure and never as "donor match" (X39 §0 point 6, V81 §5.2).

---

## 7. Second-read verification ledger (every prerequisite included above)

Each row was checked with two independent instruments: pass **A** = PowerShell / JSON / filesystem read; pass **B** = dedicated `read`/`grep` of the live source or a second landed report. All states are **point-in-time**; the report set grew during this audit (V64/V65/V81 then V63/V66 landed), so COORD must re-glob and re-read before acting (V63 §2, V56 risk 1).

| # | Prerequisite included | Pass A (filesystem/JSON) | Pass B (report/source) | Accepted state |
|---|---|---|---|---|
| V0.1 | 575/582/585 unacked | `status.json` filter → `575:timed-out,582:skipped,585:timed-out`; counter/now_serving 607/607; lock absent | V06 §0/§4.1 + V42 §4.2 + V63 row 12 + V81 §3.3 | still unacked → row 0.1 |
| V0.2 | Freeze / seam / backups / app | HEAD `e234ac9b`; `app/` status 0 entries; diff exit 0; backup hashes `3859B605…`/`44EE96C0…` | V65 §8 + V36 §1.2 + V63 rows 1/13/14; live composer greps `:220/:235/:253` | clean but volatile → row 0.2 |
| V0.3 | I02/I03 ownership | `family_index.json` and `patterns/families/` still present; `lib/pattern_lib_index.json` absent | live `decode_pattern_lib.py:1059-1061` emits only the lib index; V64 §3; V63 row 2 | source fixed, stale artefacts/G5 path open → row 0.3 |
| V0.4 | Asset P0 tiers | `Test-Path`: atlas pair, `patterns/pattern_lib_index.json`, root `manifest.json`, `masks/`, `schemas/`, `lib/` all False | V62 §6 + V66 §2/§4 (F1–F5) + V63 rows 5/8 + V81 §5.1 #4 | FAIL → row 0.4 |
| V0.5 | GR-A24 atom | `terrainmesh_props.json` False; `mountain_props.json` True; grep `t_relief_props_qa.gd:30` stale literal, `:41-42/:158` thresholds intact | V13 §2 S1 / §3 R-S1 + V21 GR-A24 + V63 row 16 | hard FAIL → row 0.5 |
| V0.6 | I12 registration / 320² | manifest count 40, last `t_select_rect`; `.bak-I12` False; grep `SIZES=[64,240]`, `RUN_320_OPTIONAL=false` | V36 §6 step 5 + V63 row 15 + V65 §6 (F-V38-04) | FAIL → row 0.6 |
| V0.7 | Spec READY / V55 | `spec/README.md` re-grep (6 `PENDING` cells, point-in-time); `Get-ChildItem V55*` → ABSENT; `V63*` and `V66*` landed mid-audit | V56 items 1/5 + V63 row 9 (26 PENDING/READY lines) + V63 row 7 (`ast.parse 6/6`) | not READY; V55 absent → row 0.7 |
| V0.8 | Decoded inputs into generator | grep `terrain_donor_world.gd:220` `gen_params: Dictionary = {}`; `:221` typed call | V61 Q1 + V65 §3 / §9 #2 (placeholder 0 seeds) | functional gap → row 0.8 |
| V0.9 | Licence/CREDITS / donor paths | `variant3d/CREDITS.md` 0 `V49-TERRAIN-NEW` hits; Python scan 780 JSON → **0** abs-path files (normalised live) | V49 §5/§6 + V62 C4 + V66-F4 (both point-in-time) + V56 D-09 | CREDITS block missing; path issue now corrected → row 0.9 |
| V1 | API four breaks / V58 defects | grep `gen.gd:229-234` includes `plt2:2222`, `k_ravine_big_stone_1:8225`; `:1152/:1161` `set_collision`; composer patch forms present | V65 §3–§7 (all static PASS) + V63 rows 3/4 (V58 defects fixed) | CLOSED statically; parse still `[U]` |
| V2 | Gate ids / ack syntax | `V42_gate_commands.md` present; unique ids read from §4 | V42 §4 + V21 §6 + V63 row 10 | packet landed, **not executed** |
| V3 | Rollback backups | both `.bak-COORD-I11` present, SHA exact (Pass A) | V36 §1.2 + V42 §6 + V65 §8 | verified, do not delete |
| V4 | V47 canonical / V57 tiers / V81 verdict | `V47`, `V57`, `V81`, `X39` all present on disk (two listings) | V47 §0/§3/§5; V57 §2/§4/§5; V81 §1/§5/§6; X39 §3/§4 | adopted verbatim; no parity claim |
| V5 | V63/V65/V66 arrival | first `Test-Path`: V65 False, V63/V66 False; second listing: all three True | full reads of V63/V65/V66 | point-in-time; live tree wins |

**Not re-verified / not claimed:** no Godot process, runner subcommand (not even `status`/`ack`), gate, dump, capture, donor execution or git mutation was performed by V72. The `status.json` read was a direct file read, not a runner call. Nothing in this memo certifies decoder byte validation, spec READY, gate PASS, or donor fidelity.

---

## 8. Attestation and five-line summary

**Exactly one repo file written:** `docs/terrain_swarm_2026-11-26/reports/V72_final_decision_memo.md`. No source, shader, asset, config, test, result JSON, queue, backup, `app/` byte or git state was changed. No donor binary executed or copied; no gate result, capture, reference image or parity metric invented. **No donor-parity claim.**

1. **[D] NO-GO stands (V63 §3):** clear nine Phase-0 blockers in order — acks, freeze/re-verify, one-writer ledger, asset P0 + feed shape + root manifest, two gate atoms, spec status/preflight, decoded inputs, licence/CREDITS — before any Godot job.
2. **[O] Overtaken warnings are not carried forward:** V36's four API breaks, V58's three I07 FAILs, V44 F-01 and V59 item 6 are fixed in the live tree; V61/V65 give static PASS only, and V48 §7.4 parse plus §7.5 stream assertions remain COORD-owned.
3. **[O] Gate sequence is fixed:** V42 `A′-0…A′-3 → D-0…D-6` with the exact `v42-*` ids; pass criteria from V21/V42 (29/29, 17/17, 10/10, 5/5, five-stream D1 at zero tolerance, D3 clean, CLEAN with 575/582/585 acked, `app/**` byte-identical); V55 is absent, so V63's `ast.parse 6/6` is the recorded preflight.
4. **[D] Failure handling is file-scoped:** ack with reasons (never delete/`--ignore-history`), rollback from SHA-verified `.bak-COORD-I11` with id-level manifest removal and explicit file deletion, never `git reset --hard`, never delete/lower an assertion; advisory FAILs are recorded verbatim, not promoted.
5. **[U] Capture and verdict stay honest:** fresh 64²/240²/320² windowed captures outside the repo, one Godot at a time; V57 three tiers + mandatory reviewer line; best possible outcome is "gates green / internal consistency PASS / donor parity UNVERIFIED"; only the owner can supply the same-camera donor frame and DLC entitlements — without them parity stays permanently UNVERIFIED.

*End of V72 final decision memo. Planned only; no runner job, no gate result, no capture, no parity claim.*
