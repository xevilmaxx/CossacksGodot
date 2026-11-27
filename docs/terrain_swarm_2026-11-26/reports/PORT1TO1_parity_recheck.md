---
id: PORT1TO1-PARITY-RECHECK-2026-11-26
title: "Read-only re-audit of the six-condition donor-parity chain against the CURRENT tree and the IMPL-FIXED-STEP / COORD deterministic-capture evidence"
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER PARITY-RECHECK — read-only update report; exactly one report written
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_recheck.md
updates: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (corrects one stale claim; no parity claim)
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; no condition of the six-condition chain is CLOSED"
scope_guard: "Repo file/line reads and read-only PowerShell Get-ChildItem/Get-FileHash of existing files only. No source, shader, asset, config, test, fixture, result JSON, backup, git state, Godot process, runner job, gate, capture or donor binary was modified, created or executed. No donor frame was produced or compared. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md (:74, :91)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (:12-15, :32, :319-322, :333)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (:38-58, :86, :89, :152)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (:28-29, :31, :177-190, :252, :269, :273-291)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md (:27, :86, :211-214, :220)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fixed_step_plan.md (:29-34, :665-671, :696-699)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_runbook.md (:132, :146, :154, :299, :326)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_endgame_protocol.md (:59-60)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_artifact_layout.md (:114, :238, :270)
  - docs/terrain_swarm_2026-11-26/HANDOFF.md (:441, :444, :445)
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (:160, :163)
  - variant3d/scripts/main.gd (:38-39, :231-239, :1408-1413)
  - variant3d/tools/acceptance/capture_sequence.py (:152-154, :293-296, :310-317, :359)
  - inbox/qa/captures/detcheck_20261113/manifest.json, inbox/qa/captures/detcheck2_20261113/manifest.json
---

# PORT1TO1 — six-condition parity chain, re-audit against CURRENT tree (2026-11-26)

> **Mandatory reviewer line (verbatim, `PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a read-only correction, not a new claim.** It re-reads the six-condition chain against the files as they exist on 2026-11-26. It does not execute the donor, Godot, a runner job, a gate or a capture; it does not close any `[U]`, weaken any test or promote any metric. It changes **one** status cell of `PORT1TO1_parity_chain.md` (condition 6, BLOCKED → PARTIAL) because that document's stated reason — "no `deterministic-capture`/`capture-ticks` symbol in `variant3d/`, no two-run byte-identical frame-hash demonstration" — is now factually stale. All other statuses are retained.

## 0. Bottom line (do not quote selectively)

- **The chain is defined at `V109_owner_answer_final.md:91` and `PORT1TO1_owner_decisions.md:319`: all six conditions are required.** Until all six hold, `parity.claim = NONE`, `parity.status = "UNVERIFIED"` and **`RESULT IS NOT GOOD`** (`V109:74/91`, `owner_decisions:12-14/39/320/322`). No tier above 2 exists.
- **Prior audit stated 0/6 closed (`PORT1TO1_parity_chain.md:38-58,152`). Its claim that the two flags do not exist in `variant3d/` (`:86`, claim register `:143`) is now FALSE in the current tree** — see §2. `HANDOFF.md:441` records `IMPL-FIXED-STEP` landing the opt-in flags, and `PORT1TO1_PLAN.md:160` records task 149 DONE.
- **Re-audit result: still 0/6 conditions CLOSED.** Exactly one status is corrected: **condition 6 is PARTIAL, not BLOCKED** — internal two-run repeatability (byte-identical pixels) is demonstrated, but the donor A/B + camera match + proven-matched manifest + explicit COORD ruling required by `V109:91` are still open. A PARTIAL is not a CLOSE. Condition 2 remains PARTIAL (port-internal only); conditions 1, 3, 4, 5 remain BLOCKED — no new evidence was found that closes or upgrades any of them.
- **`blocking_unverified` is non-empty** — P0-1…P0-8 remain open (`acceptance_plan:273-291`; `owner_decisions:39/322`; `roi_register:220`; `parity_chain:93-108`). Therefore **`RESULT IS NOT GOOD`**, unconditionally.
- **No metric/gate promotes parity.** Both new manifests themselves record `parity=UNVERIFIED` (`detcheck_20261113/manifest.json:22`, `detcheck2_20261113/manifest.json:22`); `compare_frames.py` always prints `parity=UNVERIFIED` (`roi_register:27/211-214`); no gate is green (`acceptance_runbook:326`, `PORT1TO1_gate_audit.md` posture).

---

## 1. The six-condition chain — current status after re-audit

Source: `V109_owner_answer_final.md:91` (verbatim) / `PORT1TO1_owner_decisions.md:319`. Column "Closes only with" names the exact artifact/act; none of these artifacts exists in the current tree.

| # | Condition (`V109:91`) | Status now | Evidence from current tree | Exact artifact that would close it |
|---|---|---|---|---|
| 1 | Owner supplies a genuine same-size/seed/type/season/camera/ROI **donor GPU frame** | **BLOCKED** (unchanged) | `X39_ab_feasibility.md:32-37/74-81/104-110` — no worker route may produce a donor GPU frame; only owner-launched `cossacks.exe` Route A is viable, not executed. `acceptance_plan:188-190`; `roi_register:45-70` — the 12 frames are third-party H.264 stills of unknown build/camera/zoom/compression. No owner-supplied donor PNG is on disk or named in any report. `HANDOFF:445` restates the guard. | Owner-run donor PNG **outside the repo** + written key/camera/size/season/ROI manifest per `X39 §3`; donor binary never executed by a worker. Necessary, not sufficient (`X39:34/178`). |
| 2 | An admissible non-blank 1280×720 candidate capture, `script_error_lines=0`, pinned seed/camera/size, identical ROI | **PARTIAL (port-internal only)** (unchanged) | The two new manifests are mechanically admissible (`status=ok` `:30`, `headless=false` `:15`, `resolution_observed=1280×720` + `resolution_matches_request=true` `:101-105`, seed `20261113` `:28`, pinned config SHA `aa857480…202da` `:78`, per-frame `sha256_file`/`sha256_pixels` `:86-94`). **But** they are port-vs-port runs of the same config, with `parity=UNVERIFIED` `:22`; `acceptance_plan:184` admits such captures "as port-internal evidence only — still no donor A/B"; no pinned donor-matched camera exists (`roi_register:86` `--camera NOT_SHARED_donor-oblique_vs_port-17p27`); `cap_fullport6/7/8.png` remain absent on disk this pass (read-only listing), as at `parity_chain:52`. | Fresh windowed capture with `status=ok`, `complete=true`, 1280×720, `script_error_lines=0`, pinned seed/camera/size, paired with a real donor frame at the same ROI (`acceptance_plan:177-186`). |
| 3 | Inputs **matched and labelled** (A/B-L1 same keys, or A/B-L2 importer-rendered same geometry) | **BLOCKED** (unchanged) | `X39:137` donor has no numeric seed UI; `randkey0/1` derivation `[U]`; `X39:169-171` L1 requires matched keys/size/type/season/camera/ROI and still does not certify parity; L2 needs the D04 §7 importer upgrade. `roi_register:86` asserts no shared camera. The new captures use `config_donor_capture.json` (a port config) and record `audio_seed_note` "cosmetic-only … not a simulation RNG stream" (`detcheck manifest:41-42`) — no donor-matched input claim. | Owner manifest with both donors' `randkey0/1`, size enum, map type, season, camera constants and fractional ROI per `X39 §3`; plus D04 importer upgrade for L2. No such manifest exists. |
| 4 | Fresh gates green, not stale, 575/582/585 acknowledged, `app/**` byte-identical | **BLOCKED** (unchanged) | `owner_decisions:322` — result JSONs stale, `assert_clean` last read DIRTY with 575/582/585 unacked, `inbox/qa/**` PENDING; `full_project_audit:101` Q-1 "No gate green"; `ack_evidence:36` 575/582/585 still UNACKED; `terrain_qa_spec.json` SCHEMA_ONLY. No fresh COORD-ruled gate battery, D1 dumps (5 streams × 3 sizes, zero byte difference) or D3 run integrity exists. | Fresh runner result JSONs with mtime after job START; D1 dumps zero byte difference; D3 CLEAN, `script_error_lines=0`; selftest 29/29, uitest 17/17, `t_render_mode` PASS, `t_map_variety` 5/5; `assert_clean` CLEAN with 575/582/585 acknowledged with evidence-backed reasons; `app/**` byte-identical (`owner_decisions:319-320`). |
| 5 | Spec/toolchain evidence completed — §§01–14 READY, X15 root manifest, I05 atlas/I03 feed, N17 populated and signed, **`blocking_unverified = []`** | **BLOCKED** (unchanged) | `full_project_audit:13-16/49/61-63/101/117` — ~45 approximations, atlas tier ABSENT, Objects feed unwired, N17 SCHEMA_ONLY, root `manifest.json` absent; `N17_gaps` records 17 runtime gaps `[U]`; `owner_decisions:322` `blocking_unverified` non-empty; `acceptance_plan:289` additional RUNTIME-only blockers. The deterministic captures do not touch any of these. | All §§01–14 READY, X15 root `manifest.json` emitted, I05 atlas built and bound, I03 feed consumed with `props_total>0 && fallback_used=false`, N17 populated and signed, `blocking_unverified = []` ruled by COORD (`owner_decisions:319-320`). |
| 6 | **Demonstrated byte-identical geometry + pixel-identical frame** under the proven-matched manifest, ruled by **COORD explicitly** | **PARTIAL — corrected this pass (was BLOCKED)** | **New, [O]:** two deterministic capture runs produced byte-identical per-frame pixels (§2/§3). This establishes *internal repeatability* of the port under a fixed seed/config only. **Not closed:** `parity=UNVERIFIED` in both manifests `:22`; no donor A/B frame (condition 1) and no shared camera (condition 3); no geometry-byte equality demonstrated (only the port's own two PNG/pixel hash sets match); only 2 frames / 64 ticks, not the `fixed_step_plan §8` 24-frame / 768-tick test; no COORD ruling exists (`acceptance_runbook:326`, `artifact_layout:270`, `final_guard_audit:34`, `HANDOFF:445` "does NOT close donor A/B, camera match, or any `[U]`"); `fixed_step_plan:665-671` a passing replay pair still leaves `parity=UNVERIFIED`. | A COORD-signed owner report with demonstrated geometry-byte equality and a pixel-identical **matched** frame (zero mismatch), explicitly ruling condition 6 under the proven-matched manifest. No such report exists. |

**Chain result: `parity.claim = NONE`, `parity.status = UNVERIFIED`, `RESULT IS NOT GOOD`.** Zero of six conditions is CLOSED (one port-internal PARTIAL at condition 2, one repeatability PARTIAL at condition 6, four BLOCKED). Even if conditions 2, 4 and 6 were later made green, the ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED" (`owner_decisions:39/320`, `V109:91`, `acceptance_plan:368`).

---

## 2. The corrected claim — deterministic capture mode IS live in the current tree

`PORT1TO1_parity_chain.md:86` and artifact-layout `:114/:238` stated that a full-tree read found **no** `deterministic-capture`/`capture-ticks` symbol in `variant3d/` and that the flags existed only as an unapplied design (`fixed_step_plan:29-34/696`). That statement is **stale** for the current tree:

- **Engine flags, `variant3d/scripts/main.gd`:** `:38-39` documents `--deterministic-capture` / `--capture-ticks <n>`; `:1408-1409` parses `--deterministic-capture` → `capture_deterministic = true`; `:1410-1413` parses `--capture-ticks` → `capture_ticks_total` (clamped `0..1000000`); `:231-239` disables watchdog/deadline, refuses headless/CLI/`--seed random`/`capture_ticks_total <= 0` with `printerr("deterministic-capture: …")` and sets `capture_ticks_per_frame = maxi(1, int(round(seq_step * Data.FPS)))`; refusals also at `:1916`, `:1952`, `:2213` (no CPU fallback).
- **Harness flags, `variant3d/tools/acceptance/capture_sequence.py`:** `:293-296` defines `--deterministic` and `--capture-ticks`; `:310-317` refuses `--headless`/`--mode shot`, requires `capture_ticks > 0` and `capture_ticks == frames*max(1,round(step*32))`; **`:153-154` passes `--deterministic-capture --capture-ticks <N>` through to the engine**; `:359` records `deterministic_capture` in the manifest; `:252` scans stderr for `deterministic-capture:`/`watchdog:` refusal lines.
- **Landing record:** `HANDOFF.md:441` — "Deterministic capture mode landed: opt-in `--deterministic-capture --capture-ticks N` in `main.gd` + `capture_sequence.py`, fixed `1/32` ticks, authoritative `capture_view3d`, 1280×720 asserts, no CPU fallback, audio seed in manifest; I11 seam and both config hashes unchanged." `PORT1TO1_PLAN.md:160` — task 149 DONE, "two runs byte-identical `sha256_pixels` (`detcheck`/`detcheck2`); port-internal replay demonstrated".
- **`PORT1TO1_endgame_protocol.md:59-60` D0 preflight is now satisfied in fact** (manifest `deterministic=true` `:4`, `deterministic_capture=true` `:5`, `capture_ticks=64` `:3`, `seq_index.ticks_done=64`/`ticks_per_frame=32`/`sim_seconds=2.0`/`winner=-1` `:120-131`). **D0 satisfied is a protocol preflight, not a chain condition and not a parity result.**

The corrections above change **only** status cell 6 and the stale "no symbols" assertion. No other status, label or threshold was changed.

---

## 3. New evidence — exact lines and hashes (read-only)

### 3.1 The two COORD deterministic captures on disk

| Item | `detcheck_20261113` | `detcheck2_20261113` |
|---|---|---|
| manifest SHA-256 (re-hashed [O] this pass) | `4B3EDA01CA4DB8376FB87396B8F0C4ACFCC59C6C645A0421B39901976CA16681` | `BC2880F3FA0805B77E5ACD6FAE8A8D981C1E4E5C0D18DE8F79E1E67823CAE0D0` |
| `deterministic` / `deterministic_capture` | `true` / `true` (`:4-5`) | `true` / `true` (`:4-5`) |
| `capture_ticks` / `seed` / `status` / `parity` | `64` / `20261113` / `ok` / `UNVERIFIED` (`:3,:28,:30,:22`) | same (`:3,:28,:30,:22`) |
| engine argv | `--deterministic-capture --capture-ticks 64` (`:40`, `:61-63`) | same (`:40`, `:61-63`) |
| config SHA-256 in manifest | `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` (`:78`) | same (`:78`) |
| `frame_0000.png` `sha256_pixels` | `def18ad94e6abb22d698679be77cba96e3b21dda739eee8779315efffcc9842f` (`:87`) | identical (`:87`) |
| `frame_0001.png` `sha256_pixels` | `18e1e7217aac9c6680f91f1504922dcd92d00545bd67c427a993209a467f7265` (`:94`) | identical (`:94`) |
| `frame_0000.png` file SHA-256 [O] | `A776159F6233DE53EA51EEB1E8FA9FE91655091F60ED2821AA941E5996B7C876` | identical |
| `frame_0001.png` file SHA-256 [O] | `167764BFFE19EC7A8421E3B4D36528E08A20AAF85245D28477B2A2EF4C64EA3B` | identical |
| `seq_index.json` SHA-256 [O] | `07E0B2AF960B23FB1A1AC7E1406C399203350E7FEE179D5AACBECDF2C83ED187` | identical |
| `runner_stderr.txt` SHA-256 [O] | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` (empty file) | identical (empty) |
| `seq_index` fields | `ticks_done=64`, `ticks_per_frame=32`, `sim_seconds=2.0`, `winner=-1` (`:120-131`) | identical (`:120-131`) |

Both manifests are byte-identical apart from run metadata (`generated_utc`/`finished_utc` `:12-13`, lock path `:19`, argv/label/ticket `:40-73`, engine result path `:79-80`, `runner_ticket` `:118`, durations `:111/114/119`, output paths `:84/91/99/116-117`). The **frame PNGs, `seq_index.json` and per-frame `sha256_pixels` are byte-identical** across the two runs; this was independently confirmed by read-only `Get-FileHash` this pass, not merely inherited from the manifests. `HANDOFF.md:444` describes this as validating "the opt-in mode only; it does NOT close donor A/B, camera match, or any `[U]`".

### 3.2 Scope limits of that evidence (why condition 6 is PARTIAL, not CLOSED)

- **Two frames / 64 ticks, not the design target.** `fixed_step_plan §8` / `acceptance_runbook:141/154/299` call for 24 frames / 768 ticks (`768 = 24 × 32`) at `--step 1`; these runs used `--seq-seconds 2`, `--seq-step 1`, 2 frames, 64 ticks (`manifest:24/29-31/81`, `seq_index:2-4`). This is a scaled-down repeatability check, not the full §8 two-run test.
- **Pixels only, no geometry-byte equality.** The evidence is equality of the port's own two PNG/pixel hash sets; no donor height/geometry dump byte comparison is present (condition 6 requires "byte-identical geometry + pixel-identical frame").
- **No matched manifest.** Both runs use `config_donor_capture.json` with `parity=UNVERIFIED`; no shared camera, no donor keys/ROI, and `HANDOFF:444` explicitly denies closing donor A/B or camera match.
- **No COORD ruling.** `acceptance_runbook:326` still lists all six conditions unclosed and condition 6 as "no COORD-signed zero-mismatch geometry/frame ruling"; `artifact_layout:270` and `final_guard_audit:34/172` agree. `HANDOFF:442/445` records `PORT1TO1_parity_chain.md` as "0 of 6 conditions closed" and the guard unchanged.
- **Engine stderr is not silence.** `variant3d/.godot_queue/results/00000118_acapt-detcheck-donor/stderr.txt` and `00000119_acapt-detcheck2-donor/stderr.txt` (8603 B each) contain the **deliberate** water U4* hard-fail line plus benign Godot teardown messages ("Texture with GL ID of 85: leaked…", "RenderingServer::get_singleton() is null", "1 resources still in use at exit"); no `watchdog:`, `cli: wall-clock limit reached` or `deterministic-capture:` refusal line was found. The manifests do **not** record a `script_error_lines` field, so this recheck does not assert `script_error_lines=0` from them — the runner-side `runner_stderr.txt` files are empty (hash above). Water U4* stays `[U]` (`parity_chain:98`).

### 3.3 Preserve-only contract held

`config_donor_capture.json` re-hashed [O] this pass = `AA857480474399DC4674104744EA292BF84094D8321CDD4D0889C24CF9A202DA`, matching the P-2 baseline at `owner_decisions.md:333`, `parity_chain:113` and both new manifests `:78`. The deterministic-mode landing did not flip `backend`/`demo_mill` or the I11 seam (`HANDOFF:441`). This is a preservation check, **not** parity evidence.

---

## 4. Unambiguous statements

1. **No unit-test gate promotes parity.** A `PASS` selftest, `t_render_mode`/`t_map_variety`, D1 hash equality, the two deterministic replay manifests and all `compare_frames.py` outputs are port-internal support cues only (`acceptance_plan:31/252`, `roi_register:27/211-214`, `determinism_audit:204`, `fixed_step_plan:665-671`). No gate is green (`acceptance_runbook:326`).
2. **No ROI metric promotes parity.** Every `compare_frames.py` run and every refusal prints `parity=UNVERIFIED`; MAE/RMSE/max error/differing-pixel fraction/Pearson/histogram correlation/intersection/chi-square/the absolute-difference PNG/`--assert-ab-verified` are support cues only, with no promotion threshold (`roi_register:27/196-222`; `X39:169-171`). The byte-identical `sha256_pixels` pair is an internal repeatability cue, not a metric gate and not a donor comparison.
3. **Parity stays UNVERIFIED** — `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim=false`; the two new manifests themselves record `parity=UNVERIFIED` (`:22`). No tier above 2 exists (`owner_decisions:12-14/39-40/320`, `V109:91`, `acceptance_plan:368`).
4. **`RESULT IS NOT GOOD`** because `blocking_unverified` is non-empty — P0-1…P0-8 open, no donor GPU A/B frame, no matched capture, no COORD ruling (`owner_decisions:14/39/322/353`, `V109:74/91`, `acceptance_plan:33/269`, `roi_register:220`, `parity_chain:132`).
5. **No approximation was adopted, no parity claim made, no test/gate weakened, and no code/Godot/git/donor execution performed.** Exactly one repository file was written: this report. The sole status change is condition 6 BLOCKED → PARTIAL; it does not close the condition.

---

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Chain is `V109:91` / `owner_decisions:319`; all six required; **0/6 CLOSED** after re-audit | [D] report read |
| 2 | Prior "no `deterministic-capture`/`capture-ticks` symbol in `variant3d/`" claim is now stale; flags live at `main.gd:38-39/231-239/1408-1413` and `capture_sequence.py:152-154/293-296/310-317` | [O] current-tree reads; supersedes `parity_chain:86/143` |
| 3 | `IMPL-FIXED-STEP` landed; task 149 DONE; D0 preflight satisfied | [D] `HANDOFF:441`, `PORT1TO1_PLAN:160`, manifests `:3-5/120-131` |
| 4 | Two COORD deterministic captures on disk; per-frame `sha256_pixels`, PNG files and `seq_index.json` byte-identical | [O] manifest `:87/:94` + read-only `Get-FileHash` |
| 5 | Condition 6 is PARTIAL (internal repeatability only): no donor A/B, no shared camera, no geometry-byte equality, no COORD ruling, 2 frames/64 ticks not 24/768 | [O]/[D] §3.2, `HANDOFF:444`, `acceptance_runbook:326`, `artifact_layout:270` |
| 6 | Conditions 1/3/4/5 remain BLOCKED; condition 2 remains PARTIAL; no new evidence closes or upgrades them | [D] §1 + `parity_chain:45-58` re-read |
| 7 | P-2 config SHA unchanged at `aa857480…202da`; preserve-only contract held | [O] read-only `Get-FileHash` + `owner_decisions:333` |
| 8 | No metric/gate promotes parity; parity UNVERIFIED; `RESULT IS NOT GOOD` | [D] `roi_register:27/220`, `V109:74/91`, `owner_decisions:39/353`, manifests `:22` |
| 9 | This worker wrote exactly one repository file; no code, Godot, git, donor execution, capture, gate or ROI metric produced | [O] scope |

---

*End of PORT1TO1_parity_recheck. Read-only correction; exactly one repository file written. Six-condition chain: 0/6 CLOSED (condition 6 corrected BLOCKED → PARTIAL; all others unchanged). Internal two-run repeatability demonstrated, but no donor GPU A/B frame, no matched camera, no COORD ruling. No unit-test gate or ROI metric promotes parity; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation, no parity claim.*
