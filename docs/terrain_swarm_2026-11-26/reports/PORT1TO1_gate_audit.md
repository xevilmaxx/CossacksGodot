---
id: PORT1TO1-GATE-AUDIT-2026-11-26
title: "Read-only audit of the current test/gate surface — full 1:1 Cossacks 3 donor port"
role: WORKER AUDIT-GATES — read-only audit; exactly one report written
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_gate_audit.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_gate_audit.md]
files_edited: []
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; no gate or ROI metric promotes parity"
scope_guard: "Repo file/line reads, read-only glob/Get-ChildItem/Get-Content/Select-String/Get-Item/Test-Path only. No source, shader, asset, config, test, fixture, manifest, result JSON, backup, queue file, app/ byte, git state, Godot process, runner subcommand (not even status), gate, capture, ROI metric or donor binary was modified, created or executed. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (:13, :36-41, :54, :118-133)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (:15, :36-40, :322, :326-341, :353)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (:31-33, :108-112, :234-254, :258-291, :355-370)
  - docs/terrain_swarm_2026-11-26/reports/V21_gate_register.md (:30-42, :70-123, :125-135, :154-181, :202-222)
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md (:34-39, :104-136, :242-254, :288-313, :332-357)
  - docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md (:24-30, :83-98, :100-130)
  - docs/terrain_swarm_2026-11-26/reports/V76_gate_preflight.md (:22-27, :53-65)
  - docs/terrain_swarm_2026-11-26/reports/V112_gate_witness.md (:31-37, :43-68)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_metrics.md (:25-27, :56-81)
  - variant3d/selftest.json, variant3d/uitest.json, variant3d/tests/manifest.json
  - variant3d/tests/results/{t_terrain_donor,t_render_mode,t_map_variety,summary}.json
  - variant3d/tools/{godot_runner,assert_clean}.py, variant3d/.godot_queue/{status.json,counter,now_serving}
---

# PORT1TO1 — gate-surface audit (current tree, 2026-11-26)

> **Mandatory reviewer line (verbatim, `PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a read-only audit, not a gate run and not a new claim.** It inventories what each gate actually checks, its advisory/blocking posture, its `parity.claim` value, its ack state and its misread risk. It does **not** run, close, weaken, promote or re-classify any gate. It does not close any `[U]`. It does not edit an assertion, threshold, manifest, result JSON or queue file.

## 0. Bottom line (do not quote selectively)

- **No unit-test gate and no ROI metric promotes parity.** Every artifact audited below is port-internal consistency, advisory structure, owner-only capture bookkeeping or a support-cue metric. `t_terrain_donor.json` — the only result JSON with an explicit `parity` object — carries `claim=NONE`, `status=UNVERIFIED`, `visual_parity_claim=false` (`variant3d/tests/results/t_terrain_donor.json:518-523`); all its advisories are `status=UNVERIFIED` and its determinism equality is port-internal 64²/240² only (`:401-454`). All other result JSONs have **no `parity` field at all** (`parity.claim = ABSENT`).
- **`PORT1TO1_parity_chain.md` condition 4 remains BLOCKED.** The owner register (`owner_decisions.md:322`) records exactly three unacked leak tickets **575/582/585**, `inbox/qa/**` PENDING, stale-gate history and no D1/D3 ruling. This audit preserves that verdict: ack is owner-only and unperformed; no D1/D3 ruling exists; `assert_clean` CLEAN is not claimed.
- **The fresh mtimes seen on some result JSONs on this date do not close a gate.** `selftest.json` (2026-11-26 15:57:48), `uitest.json` (15:59:33), `t_render_mode.json` (14:26:38), `t_map_variety.json` (14:27:04), `t_terrain_donor.json` (15:56:31) are point-in-time file reads [O]. Freshness is necessary, not sufficient: no COORD gate run, no mtime-after-START envelope verification, no D1/D3 ruling, no owner ack, no donor A/B frame and no `blocking_unverified=[]` ruling was performed by this audit.
- **`parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`.** No tier above 2 exists (`owner_decisions.md:40`, `acceptance_plan.md:368`).
- **`RESULT IS NOT GOOD`** because `blocking_unverified` is non-empty — P0-1…P0-8 remain open (`parity_chain.md:40`, `acceptance_plan.md:269/273-291`).

---

## 1. Scope, method and notation

- `[O]` literal file/line or read-only filesystem read; `[D]` deterministic consequence of cited lines; `[I]` interpretation with caveat; `[U]` unresolved.
- `parity.claim` values used in the tables: `NONE` = explicit `parity` object whose `claim` is `NONE`; `ABSENT` = the artifact contains no `parity` field and therefore makes no parity claim; `UNVERIFIED` = tool/report prints `parity=UNVERIFIED` with `claim=null`.
- "Advisory" = `--policy advisory` / class-B / SMOKE / support cue, never a gate pass. "Blocking" = red class-A/class-C integrity criterion that must fail if violated; **being blocking never means "passes" and never means "confers parity."** "Owner-only" = COORD/I13/owner submits or rules; analysis workers do not.
- "Ack state" refers only to the runner's historical leak-ticket acknowledgement (`godot_runner.py ack <ticket> --reason`, `:586-612,644-647`). Gate ids themselves have no ack field; where noted, the ack of 575/582/585 is a *prerequisite* to GR-A00 CLEAN, not a gate result.

---

## 2. Current on-disk state — point-in-time read [O]

| Item | Observed at final read | Label / caveat |
|---|---|---|
| `variant3d/.godot_queue/counter` = `115`, `now_serving` = `115` | read-only `Get-Content` | [O] Differs from the 607/607 figure in V42/V76 — that figure is historical report-era state, not this read. |
| `variant3d/.godot_queue/jobs/` file count = `0`; `results/` count = `115`; `status.json` history = tickets `0…113` | read-only listing/line count | [O] No live pending job visible. |
| `godot.lock` | `Get-Item`/`Get-Content` returned "does not exist" | [O] A directory entry named `godot.lock` appeared in the directory listing but no file resolves. No lock file content was read. |
| Result directories `00000575_bbclamptidy01-parse`, `00000582_terrainswarm-g1-selftest`, `00000585_g04-uitest` | present under `variant3d/.godot_queue/results/` | [O] Contain only `stdout.txt`/`stderr.txt` (e.g. 75 B / 7653 B). **No `00000575.json`/`00000582.json`/`00000585.json` result JSON resolves anywhere in the tree** (recursive read-only search). Reports V06/V42/V76 recorded those JSONs as present; they are absent at this read. |
| `variant3d/.godot_queue/status.json` | no `acknowledged`/`ack_reason`/`ack_at` fields, no 575/582/585 rows | [O] The historical unacked rows have rolled off this history. There is **no on-disk evidence of an evidence-backed owner ack** for 575/582/585. Ack state stands as UNACKED per the governing register. |
| `app/.godot_queue/status.json` | counter/now_serving = `1352`; 523 results; many *other* tickets acknowledged with reasons | [O] These acks are unrelated to 575/582/585; they do not ack those tickets. |
| `variant3d/tests/manifest.json` | `41` test ids, last `t_terrain_donor` (`:333-339`) | [O] Registration (V76 B2) is now done on disk. Registration is not a gate PASS. |
| `terrain_qa_spec.json` | `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` present, SCHEMA-ONLY / UNPOPULATED (V42:29, V76 row 6) | [O]/[D] Advisory evidence only; never a passing gate. |

**Interpretation [I]:** the spool counters and JSON presence have changed since the predecessor reports. This audit reports the divergence but does **not** use it to promote any gate: absence of an ack JSON is not an ack, a rolled history is not a CLEAN verdict, and fresh mtimes are not an accepted gate run.

---

## 3. Gate inventory

### 3.1 Runner / spool gates (`variant3d/tools/godot_runner.py`, `assert_clean.py`)

| Gate id | What it actually checks | Advisory / blocking | `parity.claim` | Ack state | Misread as donor parity? |
|---|---|---|---|---|---|
| `godot_runner status` (`:488-509,626-627`) | Reads spool counters, `godot.lock`, pending jobs and wait statistics. No arguments; no `--id`/`--json`. | Blocking *precondition* for every gate (one Godot at a time); not itself a gate pass. | ABSENT | n/a | No — provenance/queue state only. |
| `godot_runner ack <int> --reason` (`:586-612,644-647`) | Requires an existing result JSON (else returns 2); writes `acknowledged`/`ack_reason`/`ack_at` to **both** the result JSON and the `status.json` history row. Positional int ticket; `--reason` required; no `--id`, no `--ignore-history`, no deletion. | Advisory bookkeeping; retirement of a diagnostic, **not** a passing gate and **not** a parse proof (V42:125). | ABSENT | **575/582/585 UNACKED** (owner-only; no evidence of ack at this read). | No — explicitly records *non*-pass. |
| `godot_runner unwedge()` (`:294-320,641-642`) | Refuses while `godot.lock` is held or any Godot process is alive; otherwise advances past dead holders. | Forbidden remediation (V42:125, V76 §4, `acceptance_plan.md:112`); must never be used to manufacture a clean run. | ABSENT | n/a | No. |
| `godot_runner reset --yes` (`:541-553,632-633`), `doctor` (`:512-539,629-630`), `cancel` (`:555-584,636-638`) | Maintenance: clear state, kill orphaned processes, cancel pending jobs. | Forbidden remediation in this gate path (same citations as above). | ABSENT | n/a | No. |
| `assert_clean.py --json` (`assert_clean.py:33-42,154-188,199-218,262-272`) | Three signals: no live Godot process; lock free/`held_recent`; `status.json` history contains no job in `{timed-out,error,skipped}` (`failed` deliberately excluded). Only `--json`, `--max-lock-age`, `--ignore-history`. | **Blocking** CLEAN precondition (GR-A00/A02/A03/D-5/D-6). `--ignore-history` is forbidden: it returns `enabled:false,total:null,failures=[]`, hiding the reasons. | ABSENT | Depends on 575/582/585 ack; CLEAN is not claimed by this audit. | No — machine-clean assertion, not donor fidelity. |
| `GR-A00` (V21:72) | Preflight: pending 0, lock free, `now_serving==next_ticket`, no live Godot, `assert_clean` CLEAN with `acknowledged>=3`, `app/**` byte-identical. | **Blocking red.** | ABSENT | Prerequisite acks 575/582/585 outstanding. | No. |

### 3.2 Unit-test / result-JSON gates

| Gate id (artifact) | What it actually checks | Advisory / blocking | `parity.claim` | Ack state | Misread as donor parity? |
|---|---|---|---|---|---|
| `selftest` — `variant3d/selftest.json` (29 steps: `move…nav_detour`) | Port-internal gameplay smoke: movement, gather, combat, build, train, mine, HUD, formation, market, capture, save round-trip, grid equivalence, nav detour. `passed=true`; no `parity` object. File mtime 2026-11-26 15:57:48 [O]. | **Blocking red** as non-negotiable regression gate (V21 GR-A03, V42:304) *when COORD runs it with a fresh mtime-after-START envelope*; on disk alone it is a stale/fresh file, not an accepted run. | ABSENT | n/a | **YES if read alone.** `passed=true` / `29/29` says nothing about the donor; it is a port-internal smoke battery (`acceptance_plan.md:31`). |
| `uitest` — `variant3d/uitest.json` (17 steps) | UI/skirmish flow: menu shell, box select, order keys, build/train, formation, HUD, save/load. `passed=true`; no `parity` object. | **Blocking red** regression gate (GR-A03); 17/17 required (V42:304). | ABSENT | n/a | **YES if read alone.** UI flow, not donor frames. |
| `t_render_mode` — `variant3d/tests/results/t_render_mode.json` | 10 checks that `main.gd` exposes `render_mode`, `make_world3d`/`make_camera3d`, 2D default and `seam_missing=false` (`:1-69`). | **Blocking red** (GR-A03); PASS/10-of-10 required. | ABSENT | n/a | **YES if read alone.** It is a seam/source-structure probe, not a 3D fidelity gate. |
| `t_map_variety` — `variant3d/tests/results/t_map_variety.json` | 5 checks: different seeds differ, same seed byte-identical, map type changes water fraction, size option respected, starts have reachable resources (`:1-32`). | **Blocking red** regression gate (GR-A03); 5/5 required. | ABSENT | n/a | **YES if read alone.** Byte-identical *self*-repeat is port-internal determinism, not donor match. |
| `t_final_gate` — `variant3d/tests/t_final_gate.gd` (no result JSON in `results/`) | Loads 11 scripts, greps 7 source tokens, checks 5 doc files; prints `FINAL_GATE n/m`. Read-only source/doc probe. | Advisory (not in V21 GR register); no gate result on disk. | ABSENT | n/a | Low — but any `n/m` must not be quoted as donor parity. |
| `summary.json` — `variant3d/tests/results/summary.json` | Aggregated 19 small-feature tests, `count=19 passed=19 failed=0`, mtime 2026-11-21 [O]. | Advisory aggregation of stale per-feature results; not an acceptance gate. | ABSENT | n/a | **YES if read alone.** 19/19 is a stale aggregate, not fresh or parity-bearing. |
| `t_*.json` feature results (e.g. `t_water`, `t_terrain3d`, `t_naval`, `t_pick3d`, `t_forest_bake`, `t_hud_fidelity`, `t_audio_events`, `t_mines_*`, `t_combo_*`) | Single-feature assertions recorded as `checks[]` with `passed`. `t_water` checks port lake/sand-ring/water-blocked/sim-finite; `t_terrain3d` checks surface/vertex/triangle/UV domains; others analogous. | Advisory/port-internal feature tests registered `ready`/`pending` in `manifest.json`; not V21 red gates. | ABSENT (no `parity` field in any audited `t_*.json`) | n/a | **YES if a `passed=true` is quoted out of context** — e.g. `t_water` PASS is a port water model check, while P0-1/P0-1b/P0-2 water `[U]` hard-fails remain open (`parity_chain.md:97-99`). |
| **`t_terrain_donor` — `variant3d/tests/results/t_terrain_donor.json`** | 26 class-A checks (`total=26`, `status=PASS`): module presence, water thresholds, `visual_parity_claim=false`, no synthetic noise, two in-process generations at 64² and 240² with zero-tolerance hash equality of `height`/`tileblock`/`terrain`/`blocked`/`props`, grid size, tile-id domain, mesh surface/vertex/triangle/UV invariants; 18 class-B advisories all `UNVERIFIED`; 2 `HOOK_MISSING` vector advisories. `passed=true`. | **Advisory selftest carrying red-in-principle class-A structural checks.** `parity_chain.md:41/54/121` classifies it explicitly as advisory self-test, **not** the acceptance path. Only COORD's fresh, non-advisory gate battery can close condition 4. | **`NONE`** (`parity.claim=NONE`, `parity.status=UNVERIFIED`, `visual_parity_claim=false`, note "PORT APPROXIMATION — internal consistency only; no donor GPU A/B frame", `:518-523`) | n/a | **HIGHEST RISK.** `status=PASS`/`26` plus `determinism.*.pairwise_equal=true` looks like a parity proof; the file itself denies it. Advisories are all `UNVERIFIED`; S2 water fraction = 0, S3 shore = 0, S5 stamps = 0 (`:52-113`); determinism is 64²/240² port-vs-port, **not 320², not a frame replay, not donor** (`parity_chain.md:88`). |

### 3.3 V21 consolidated gate register (`V21_gate_register.md:70-123`)

All rows below keep their source ids. `parity.claim` is `ABSENT` for the register as a whole (`V21:9 parity_claim: false`); no row is a donor-parity gate. Ack state: "n/a" except GR-A00 (prerequisite acks). Misread column: "No" means mechanically clear; "YES" flags a concrete out-of-context risk.

| Gate id | What it actually checks | Advisory / blocking | `parity.claim` | Ack state | Misread as donor parity? |
|---|---|---|---|---|---|
| GR-A00 | Preflight CLEAN + `app/` integrity + acks (see §3.1) | Blocking red | ABSENT | 575/582/585 unacked | No |
| GR-A01 | D1 determinism: 5 canonical streams × 3 sizes (64²/240²/320²), zero byte difference | Blocking red (hard) | ABSENT | n/a | **YES** — port-internal hash equality only; no donor frame |
| GR-A02 | D3 run integrity: status ∉ {timed-out,error,skipped}, `script_error_lines=0`, mtime after START, CLEAN | Blocking red (hard) | ABSENT | n/a | No |
| GR-A03 | Non-negotiable regression: selftest 29/29, uitest 17/17, `t_render_mode` PASS/seam_missing=false, `t_map_variety` 5/5, `scan_map ALL GREEN`, CLEAN, fresh JSONs | Blocking red | ABSENT | n/a | **YES** — a green battery is internal consistency only |
| GR-A04 | Dump `meta` key completeness; unknown field ⇒ `[U]`, never silent drop | Blocking red | ABSENT | n/a | No |
| GR-A05 | V12-G1 mine loop ring→ore→256 attempts; red on attempts>256/accepted>1 | Blocking red | ABSENT | n/a | No |
| GR-A06 | V12-G2 radius matrix + ring-2 audit trail (`legacy_ring2_gap`) | Blocking red (with `[U]` semantics in B10) | ABSENT | n/a | No |
| GR-A07 | V12-G3 `continue` RNG bookkeeping: name draws consumed, zero angle draws | Blocking red | ABSENT | n/a | No |
| GR-A08 | V12-G4 density/rounds/clamp/caller branch rules | Blocking red | ABSENT | n/a | No |
| GR-A09 | V12-G5 corner relocation formula | Blocking red | ABSENT | n/a | No |
| GR-A10 | V12-G6 ellipses + dead C3 block emits zero stamps | Blocking red | ABSENT | n/a | No |
| GR-A11 | V12-G7 six placement attempts, mindst spans, one family draw per placement, no food | Blocking red | ABSENT | n/a | No |
| GR-A12 | V12-G8 occupancy-only rejection predicate | Blocking red | ABSENT | n/a | No |
| GR-A13 | V12-G9 no food rects in start resources | Blocking red | ABSENT | n/a | No |
| GR-A14 | V12-G10 no finite deposit amount | Blocking red | ABSENT | n/a | No |
| GR-A15 | V12-G11 `FillOwnerMap` 160² wavefront and call order | Blocking red | ABSENT | n/a | No |
| GR-A16 | V12-G12 stage seam + reseed ledger (11 SetRandomKey + 3 SetRandomExtKey64) | Blocking red | ABSENT | n/a | No |
| GR-A17 | V12-G13 weighted roulette pick + damping | Blocking red | ABSENT | n/a | No |
| GR-A18 | D08/X08 smoothing structure: 22 items/118 lists/282 entries/86 names, raw weights, 3 in-place H-then-V passes | Blocking red | ABSENT | n/a | **YES** — donor-text structure, not pixel fidelity |
| GR-A19 | X08 exact smoothing vectors V1–V11, one pass, `RandomExt=0` except V11 | Blocking red (derived `[D]`; RNG position `[U]` in B20) | ABSENT | n/a | **YES** — vector match is not donor parity |
| GR-A20 | Hard tile-id/catalogue domain: 124 Summer ids, water id 255 port sentinel, illegal ids 0, stamp catalogue, unknown family 0 | Blocking red (hard parts) | ABSENT | n/a | No |
| GR-A21 | V15 shared stage/render invariants: shared `height[]`, shore after water, props render-only, no synthetic noise/invented constant | Blocking red | ABSENT | n/a | No |
| GR-A22 | `app/**` + freeze-set byte identity | Blocking red | ABSENT | n/a | No |
| GR-A23 | Threshold/assertion integrity: any lowered threshold, deleted assertion, fabricated green JSON, invented band or parity wording ⇒ FAIL | Blocking red | ABSENT | n/a | No |
| GR-A24 | `t_relief_props_qa` is not a vacuous blind spot (stale path `terrainmesh_props.json`; live `mountain_props.json`) | Blocking red (regression detector); currently hard FAIL | ABSENT | n/a | No |
| GR-B01 | D2 cross-size structural similarity ±0.02 / ±0.05 | **Advisory** until V17 + N17 + COORD | ABSENT | n/a | **YES** — numeric band looks like a donor threshold |
| GR-B02 | S1 height decile occupancy (no decile >0.85; ≥3 of 5 bands) | Advisory | ABSENT | n/a | **YES** |
| GR-B03 | S2 water fraction `[0.05,0.45]`; water-free 64² ⇒ RECORDED_NOT_APPLICABLE | Advisory | ABSENT | n/a | **YES** — conflicts with observed S2=0 |
| GR-B04 | S3 shore fraction `[0.02,0.25]`, ratio `[0.2,1.5]` | Advisory | ABSENT | n/a | **YES** — observed S3=0 |
| GR-B05 | S4 distinct land ids ≥8, top-1 ≤0.60 | Advisory | ABSENT | n/a | **YES** — observed 1 / 1.0 |
| GR-B06 | S5 relief-stamp count; `k_ravine_1` occurrence ⇒ `[U]` | Advisory | ABSENT | n/a | **YES** — observed count 0 |
| GR-B07 | S6 family-count ratio `[0.5,2.0]` | Advisory | ABSENT | n/a | **YES** |
| GR-B08 | S7 mine/field/forest counts — superseded port belief, must be rewritten | Advisory (must be rewritten) | ABSENT | n/a | **YES** — port belief presented as donor range is a named risk (V21 R10) |
| GR-B09 | Runtime generator-version / mapsize branch selection; branch `[U]` | Advisory (telemetry) | ABSENT | n/a | No |
| GR-B10 | Ring-2 VM initialisation semantics (`ring2_dst_mode="zero"`, `[U]`) | Advisory (trace presence is red in A06) | ABSENT | n/a | No |
| GR-B11 | `bmTransparency` visual semantics; port `rgb *= mask` is PORT APPROX | Advisory (X13 absent) | ABSENT | n/a | **YES** — CODE-derived factors are not pixel fidelity |
| GR-B12 | Eye-plane texgen / UV scale effective arithmetic `[U]` | Advisory | ABSENT | n/a | **YES** |
| GR-B13 | Detail-bitmap runtime activation `[U]` (script lines commented) | Advisory (text intent only) | ABSENT | n/a | No |
| GR-B14 | Atlas packing equivalence (112 DDS vs port 16×8 PORT APPROX) | Advisory | ABSENT | n/a | **YES** |
| GR-B15 | Swamp/header contradiction preserved; rivers OUT_OF_SCOPE | Advisory | ABSENT | n/a | No |
| GR-B16 | DScript runtime activation / deposit capacity `[U]` | Advisory | ABSENT | n/a | No |
| GR-C01 | Capture admissibility G0-a…e: windowed, 1280×720 non-blank, camera/world diag, `script_error_lines=0`, pinned seed/camera/size, identical fractional ROI | Blocking red **when attempted**; owner-only | ABSENT | n/a | **YES** — an admissible port frame is not a donor A/B |
| GR-C02 | Frozen fresh 240²/320² baselines outside repo + SHA manifest | Blocking red prerequisite; owner-only | ABSENT | n/a | No |
| GR-C03 | Visual cards R1–R6, eye read over metric | Blocking red visual; owner-only | ABSENT | n/a | **YES** — "looks right" is not parity |
| GR-C04 | R7/R8 CAP-3 drag/ghost frames; absent ⇒ UNVERIFIED | Advisory/UNVERIFIED | ABSENT | n/a | No |
| GR-C05 | V15 tier-2 self-consistent visual properties (labelled PORT APPROXIMATION only) | Advisory/self-consistent | ABSENT | n/a | **YES** — tier 2 never implies donor grounding |
| GR-C06 | Same-scene self-determinism `compare_shots.py --threshold 0.9999` (0.80 is a smoke placeholder) | Blocking red when attempted (self-determinism) | ABSENT | n/a | **YES** — self-vs-self ≈1.0 proves nothing about donor |
| GR-C07 | Like-with-like SMOKE metric `terrain_ab_metric.py`; tool label "NOT a fidelity gate or donor proof" | Advisory (SMOKE) | ABSENT | n/a | **YES** |
| GR-C08 | Genuine donor GPU A/B frame — **does not exist** | UNVERIFIED (parity ceiling) | ABSENT (parity stays `NONE`/`UNVERIFIED`) | n/a | This is the *only* route to a parity claim and it is absent; no worker may produce it. |
| GR-C09 | X13 blend test vectors — not landed ⇒ no vector gate | Advisory/UNVERIFIED | ABSENT | n/a | No |
| GR-C10 | Tool aperture verification per capture (`--path variant3d`, absolute paths, stdout diag) | Blocking red when attempted; owner-only | ABSENT | n/a | No |
| GR-C11 | Fresh relief-props ON/OFF windowed capture; stale `expected_pre_fix_failure` must be strengthened, never lowered | Blocking red when attempted (regression); needs A24 repoint | ABSENT | n/a | No |

### 3.4 ROI / capture metric gates

| Gate id | What it actually checks | Advisory / blocking | `parity.claim` | Ack state | Misread as donor parity? |
|---|---|---|---|---|---|
| `compare_frames.py` (`PORT1TO1_roi_metrics.md:56-81`, 14 executed ROIs R01–R14) | Same pixel box on two frames; MAE/RMSE/max/differing-pixel/Pearson/histogram metrics + absolute-diff PNG. No rescaling, clamping or inferred alignment; cannot verify donor identity, camera equality or ROI correctness. | **Advisory support cues only; no threshold defined.** Never a gate. | `UNVERIFIED` (`claim=null`, `owner_assertion=null` on all 14 reports; `--assert-ab-verified` not supplied) | n/a | **YES — named risk.** Near-1.0 differing-pixel fractions and histogram correlations are measurements of two unrelated images; `PORT1TO1_roi_metrics.md:25-27` forbids similarity %, donor-threshold PASS and "matches donor". |
| `--assert-ab-verified` (`acceptance_plan.md:252`) | Optional human assertion text written as `claim=owner-supplied`; tool still prints `parity=UNVERIFIED` and cannot verify identity/camera/ROI. | Advisory; explicitly forbidden as verification. | `UNVERIFIED` (claim=owner-supplied does **not** promote parity) | n/a | **YES** — forbidden phrasing if treated as verification. |
| `compare_shots.py` | Same-candidate repeat at `--threshold`; 0.80 default is a smoke placeholder. | Advisory/SMOKE default; 0.9999 for self-determinism (GR-C06). | ABSENT | n/a | **YES** |
| `terrain_ab_metric.py` | Candidate vs frozen baseline at identical crop; `--compare-ref` distribution hints. No `--baseline`, no ARI; label "NOT a fidelity gate or donor proof" (V06:29, GR-C07). | Advisory (SMOKE) | ABSENT | n/a | **YES** |

---

## 4. Ack-state register (consolidated)

| Ticket | Report-era state | Current on-disk evidence at final read [O] | Ack state now | Permitted action |
|---|---|---|---|---|
| 575 `bbclamptidy01-parse` | `timed-out`; result JSON `00000575.json` present (V06 E07, V42 E05, V76 row 10) | Result directory `00000575_bbclamptidy01-parse/` present with stdout/stderr; **no result JSON resolves**; no ack fields in current `status.json` | **UNACKED** — no evidence of owner approval | COORD/owner `ack 575 --reason "<evidence-backed text>"` using the V42 §4.2 / V06 §4.1 string, only if the result JSON prerequisite is satisfied; otherwise record the provenance gap. Ack records retirement, **not** a passing gate. |
| 582 `terrainswarm-g1-selftest` | `skipped`, run=0.0, bogus `serving=2581`; superseded by ok 568/569 | Same shape as 575 | **UNACKED** | Same as above; reason must state "NOT a green selftest run". |
| 585 `g04-uitest` | `timed-out` at 300 s; on-disk 17/17 predated both runs | Same shape as 575 | **UNACKED** | Same as above; reason must state "NOT a green uitest". |
| Other acked tickets in `app/.godot_queue/status.json` | various | acknowledged with reasons present | ACKED (unrelated) | No action; they do not ack 575/582/585. |

**Forbidden at all times** (V42:125/357, `acceptance_plan.md:112`, V76 §4): `--ignore-history`, result-JSON deletion, hand-edited status, `reset --yes`, `doctor`, `cancel`, `unwedge`, re-running until green, lowering a threshold, deleting an assertion, or fabricating a green JSON to obtain CLEAN.

---

## 5. Exact remediation — PRESERVES every gate

1. **Ack only with owner approval.** Execute `python variant3d\tools\godot_runner.py ack <ticket> --reason "<evidence-backed text>"` for 575/582/585 using the exact V42 §4.2 / V06 §4.1 reason strings, and only after COORD confirms the result-JSON prerequisite (a missing result makes `ack` return 2 — do **not** fabricate one). Verify the write triple (`acknowledged`/`ack_reason`/`ack_at`) in both the result JSON and `status.json` history. **An ack retires a diagnostic; it never becomes a PASS, a parse proof or a selftest/uitest result.** Leave CLEAN unclaimed rather than suppress reasons.
2. **Regenerate stale/fresh result JSONs with unique-id runner jobs.** COORD runs one job at a time; `status` after each. Accept only envelope `status=ok`, `exit=0`, `SCRIPT ERROR=0`, `smallmap_capture.py scan-stderr script_error_lines=0`, and **result mtime after that job's START**. Never re-submit a pending job, never re-run until green, never lower a threshold, never delete an assertion. Freshness alone does not close a gate.
3. **D1/D3 must be ruled, not inferred.** D1's five-stream zero-difference fingerprint must come from a real `terrain_qa_harness.py --dump-a/--dump-b/--seed-manifest/--policy advisory --check` run at 64²/240²/320²; a whole-file SHA equality is port-internal `[D]` only (V42:240, V21 U6). D3 requires status ∉ {timed-out,error,skipped}, `script_error_lines=0`, mtime after START and CLEAN. **Until both are ruled, D1/D3 are UNVERIFIED** — this audit does not rule them.
4. **Keep class-B band policy `advisory`.** Promotion requires *all* of: V17 marks the spec section READY, `terrain_qa_spec.json` (N17) populated with donor `path:line` evidence, COORD sign-off, and no OPEN V16 §4 item changing the numeric gate (V21 §7.2). The observed S2=0, S3=0 and S5=0 advisories in `t_terrain_donor.json` are recorded as `UNVERIFIED`, never flipped to PASS and never "corrected" to hit a band.
5. **GR-A24 repoint, do not weaken.** Change only the stale literal `t_relief_props_qa.gd:30` from `terrainmesh_props.json` to the live `mountain_props.json`, keeping `SCALE_WANT=1.0`, `BBOX_TOL=0.05`, count and `expected_pre_fix_failure=true` unchanged (V42:211, V76 B3). A zero-stamp or manifest-load-failure capture is rejected, never green.
6. **Manifest is id-level only.** `t_terrain_donor` is now registered last (41 ids) — leave it. Rollback would remove that single id, never whole-file restore (V42:348). No blanket `Copy-Item`, no `git reset --hard`/`checkout .`/`clean`, no `.bak` deletion.
7. **Gate-packet path corrections are documentation-only.** Replace `variant3d\shaders\terrain_donor.gdshader` → `terrain_donor_shader.gdshader` and `variant3d\spec\terrain_qa_spec.json` → `docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json` (V42 header note, V76 B1) without touching any id, threshold or assertion. Keep `terrain_qa_spec.json` labelled SCHEMA-ONLY/advisory.
8. **ROI metrics stay support cues.** Keep every `compare_frames.py` report at `parity=UNVERIFIED`, `claim=null`; do not supply `--assert-ab-verified` as verification; do not attach a threshold, similarity %, "donor threshold PASS" or "matches donor" wording to any metric; keep metric fields and visual fields separate (`acceptance_plan.md:254`, V21 GR-C07).
9. **Owner-only donor A/B frame stays owner-only.** No worker or COORD executes the donor. Until an owner supplies a genuine matched-seed/size/season/camera/ROI donor GPU frame with a written manifest and COORD explicitly rules a demonstrated zero-mismatch match, `parity.claim=NONE`, `parity.status=UNVERIFIED`; if the owner declines, parity is permanently UNVERIFIED (declared, accepted) — not a gate failure (V112 row "OWNER-ONLY").
10. **No promotion by this audit.** None of the above was performed here; all steps are a preserve-only plan. No gate, assertion, threshold, manifest, result JSON or queue file was changed.

---

## 6. Explicit statements

1. **No gate promotes parity.** A `PASS` selftest, `29/29`, `17/17`, `10/10`, `5/5`, D1 hash equality, CLEAN, a class-A structural PASS or a V15 tier-2 card is port-internal support only (`acceptance_plan.md:31/252/264`, `parity_chain.md:41/129`, `determinism_audit:204`, `fixed_step_plan:670-671`).
2. **No ROI metric promotes parity.** Every successful `compare_frames.py` run and every refusal prints `parity=UNVERIFIED`; MAE/RMSE/max error/differing-pixel fraction/Pearson/histogram correlation/intersection/chi-square/the absolute-difference PNG and `--assert-ab-verified` are support cues only; no threshold is defined (`roi_register:27/196-222`, `PORT1TO1_roi_metrics.md:25-27`).
3. **Parity stays UNVERIFIED.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; no tier above 2 exists (`owner_decisions.md:12-14/39-40`, `parity_chain.md:131`, `acceptance_plan.md:368`).
4. **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — P0-1…P0-8 remain open, no donor GPU A/B frame, no admissible matched capture, no D1/D3 ruling, no COORD sign-off and no owner ack for 575/582/585 (`owner_decisions.md:14/39/322/353`, `parity_chain.md:40/132`, `acceptance_plan.md:33/269`).
5. **No approximation, no parity claim, no test weakening, no gate run, no code/Godot/git/donor execution was performed by this audit.** Exactly one repository file was written: this report.

---

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Every audited gate is port-internal consistency, advisory structure, owner bookkeeping or a support cue; none carries a donor-parity claim | [D] V21 §4/§7, V42, V06, V112, parity chain §7-8 |
| 2 | `t_terrain_donor.json` is an advisory selftest: `status=PASS`, `26` checks, `parity.claim=NONE`, all advisories `UNVERIFIED`, determinism 64²/240² port-vs-port only | [O] result JSON :2-215, :401-454, :518-523; [D] `parity_chain.md:41/54/88/121` |
| 3 | All other `t_*.json`, `selftest.json`, `uitest.json` and `summary.json` have no `parity` field (`parity.claim=ABSENT`) | [O] direct reads of cited JSONs |
| 4 | 575/582/585 remain unacked; current spool shows no ack evidence and no result JSON for those tickets | [O] read-only spool reads; [D] `owner_decisions.md:322`, V06:27, V42 §4.2, V76 row 10 |
| 5 | `godot_runner unwedge/reset/doctor/cancel` and `assert_clean --ignore-history` are forbidden remediations; ack is owner-only and requires a reason | [O] source reads + V42:125/357, V76 §4, `acceptance_plan.md:112` |
| 6 | Class-B bands are advisory; promotion requires V17 READY + N17 evidence + COORD sign-off; no band raised here | [D] V21 §7.2, V42:180, parity chain §7 |
| 7 | D1/D3 have no ruling in this audit; whole-file SHA and self-repeat are port-internal only | [O]/[D] V42:240, V21 U6, parity chain §4.2 |
| 8 | ROI metrics print `parity=UNVERIFIED` / `claim=null`; no threshold exists; no metric promotes parity | [O] `PORT1TO1_roi_metrics.md:25-27,56-81`; V21 GR-C07 |
| 9 | Parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` non-empty | [D] governing reports as cited in §6 |
| 10 | This worker wrote exactly one repository file; no gate, runner subcommand, Godot, donor, code or git action occurred | [O] scope |

---

*End of PORT1TO1_gate_audit. Read-only audit; exactly one repository file written. All gates preserved — none weakened, none promoted, none acked without owner approval. No donor GPU A/B frame, no admissible matched capture, no D1/D3 ruling, no COORD sign-off. No unit-test gate and no ROI metric promotes parity; parity UNVERIFIED; `RESULT IS NOT GOOD`. No approximation, no parity claim.*
