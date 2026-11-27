---
id: PORT1TO1-MAINGD-DRIFT-2026-11-27
title: "Read-only attribution of the live main.gd hash drift (93faea93… -> 94c61047…)"
worker: MAINGD-DRIFT (read-only subagent)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_maingd_drift.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_maingd_drift.md]
files_edited: []
scope_guard: "Repo file/line reads plus read-only Get-FileHash -Algorithm SHA256 and read-only git status/log/diff/show queries over existing repo files only. No source/shader/config/asset/test/fixture/result-JSON/backup/queue change; no git mutation/commit/checkout/stash/reset, no Godot process/runner job/gate/capture/ROI metric, no donor binary opened/hashed/executed/captured, no donor GPU A/B frame. Exactly one repository file written: this report."
labels: [OBSERVED, PRESERVE_ONLY, PORT_INTERNAL_PARITY, PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD, NO_PARITY_CLAIM, EXPLAINED_LANDED_EDITS]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "EXPLAINED-LANDED-EDITS — the 93faea93… -> 94c61047… drift is byte-exactly the two evidence-backed COORD claim-label fixes at variant3d/scripts/main.gd:1051-1052 and :1066. No unexplained change exists."
---

# PORT1TO1 — live `main.gd` hash-drift attribution (2026-11-27)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **What this is.** A read-only identity/provenance audit of one observation in `reports/PORT1TO1_checklist_final.md:63/143`: live `variant3d/scripts/main.gd` reads `94c610479b1df594c648e1aa236cbfdcdcc695319dbbcc5f9c86fb1939619ef6` and was flagged as drifted from `93faea93d911477303503a43a1457a3df1f485d256cec10ee8f70ac478acbb10` transcribed at `reports/PORT1TO1_handoff_checklist.md:81`, with provenance "not established by this read-in". This report establishes that provenance by byte-exact reconstruction only. It is **not** a parity result, not a gate, not a `[U]` closure and not a promote-to-value action. Every preserve-only mod stays untouched.

## 1. Scope and method (read-only)

- Hashes: `Get-FileHash -LiteralPath <file> -Algorithm SHA256`, lowercase, over existing repo files only. Hashes certify byte identity, never donor fidelity (`PORT1TO1_hash_manifest.md:32-37`).
- Diffs: `git diff --no-index --unified=0/3` between on-disk files, plus read-only `git status --short`, `git log`, `git diff --stat` and `git show HEAD:<path>` queries. No git state was changed; no commit, checkout, stash, reset, `--ignore-history` or re-baseline was performed.
- Reconstruction test: scratch copies were written **only** under `%TEMP%\opencode\` (outside the repo) to reverse candidate hunks and re-hash; all scratch files were deleted. No repository file was altered except this report.
- No Godot, runner, gate, capture, ROI metric or donor execution. No donor binary opened, hashed or captured. Parity remains `UNVERIFIED`.

## 2. Hash chain — identity of every state involved

| Id | File / state | Bytes | SHA-256 (lowercase) | mtime | Role |
|---|---|---|---|---|---|
| B4a | `inbox/backup/main.gd.bak-COORD-I11` | 86,133 | `3859b6056bfdfdd5a659931835fd0901dd03db36b02a453389d9338bac9e71f8` | 2026-11-25 15:32:05 | P-4a seam witness; unchanged, baseline-matched (`checklist_final.md:57`) |
| B-RM | `variant3d/scripts/main.gd.bak-RENDERMODE` | 86,619 | `fa9d93ed7c278f78afc2a8a316fb6b76d1ec1aa60c405a1ee572713f1dcbc3f3` | 2026-11-26 09:45:43 | pre-RENDERMODE snapshot; old labels, no flags |
| B-PM | `variant3d/scripts/main.gd.bak-PEACEMENU` | 86,622 | `bb74c26a22de6985e25b58b4061e66b6cc45d270cf11be58e77f029a3be18050` | 2026-11-26 20:42:14 | pre-PEACEMENU snapshot; old labels, no flags |
| B-FS | `variant3d/scripts/main.gd.bak-FIXEDSTEP` | 87,424 | `f491f4136ac4a0aad1515847a1c448871db8c79a73a85019d8ddd420e2f7f087` | 2026-11-26 21:38:35 | **pre-FIXEDSTEP snapshot**; 0 `deterministic-capture`, 0 `capture-ticks`, 0 `CAPTURE_TICKS`, 0 `port-internal parity` |
| S1 | reconstructed earlier-reading state | 90,662 | `93faea93d911477303503a43a1457a3df1f485d256cec10ee8f70ac478acbb10` | — | value transcribed at `handoff_checklist.md:81`; **no backup holds this state**; reconstructed exactly in §3 |
| S2 | live `variant3d/scripts/main.gd` | 90,703 | `94c610479b1df594c648e1aa236cbfdcdcc695319dbbcc5f9c86fb1939619ef6` | 2026-11-27 00:07:12 | current drifted state flagged at `checklist_final.md:63/143` |

- S2 mtime `2026-11-27 00:07:12` precedes `handoff_checklist.md` mtime `2026-11-27 00:07:36` by 24 s. The checklist text itself says its hash was "transcribed" (`checklist_final.md:63`), so the S1 value is a point-in-time transcription, not a protected baseline; §3 proves which point in time it was.
- No on-disk backup and no git commit contains S1 or S2. `git status --short -- variant3d/scripts/main.gd` = ` M variant3d/scripts/main.gd`; `git diff --stat` = `111 insertions(+), 27 deletions(-)` against HEAD. HEAD source blob `4adfd148…` is an older 86,641-byte state (SHA-256 `27439b7a7160f87b2c4092b5705b36eddb4004e688c1864df4774682ec377aa6`); all 11 commits touching this file (`ddf07b65` … `b6b1f2c5`, 2026-11-24…26) predate the backups. Therefore git cannot arbitrate this drift; the on-disk backups plus byte-exact reconstruction can.

## 3. Decisive reconstruction — the drift is exactly two label edits

A scratch copy of **S2 (current)** was reverted by exactly two string substitutions, with CRLF preserved (`main.gd` uses CRLF: 2,231 CRLF, 0 bare LF in B-FS):

1. `variant3d/scripts/main.gd:1051-1052` — comment text only.
2. `variant3d/scripts/main.gd:1066` — printed string only.

Result: 90,662 bytes, SHA-256 `93faea93d911477303503a43a1457a3df1f485d256cec10ee8f70ac478acbb10` — **byte-identical to the earlier transcribed hash**. Because a SHA-256 match over the whole file is exact, this proves:

- S1 **already contained the entire IMPL-FIXED-STEP implementation** (all 18 hunks of §4.2). The earlier checklist read a post-FIXEDSTEP, pre-label-fix tree.
- The flagged S1 → S2 drift changes **exactly 41 bytes**, all in those two label sites. There is no third changed byte, no value/behaviour/assertion/constant change, no hidden whitespace or line-ending change.

### 3.1 Exact old → new text at the two drift sites

**Site L1 — `variant3d/scripts/main.gd:1051-1052` (function `_load_self_base`)**

```gdscript
# S1 / pre-fix (also B-FS:1030-1031):
	# Parity gate: refuse the fast path unless the loaded game reproduces every
	# serialized field and the non-serialized map arrays byte-for-byte.

# S2 / current:
	# PORT-INTERNAL snapshot gate (NOT donor parity): refuse the fast path unless
	# the loaded game reproduces every serialized field and map array byte-for-byte.
```

**Site L2 — `variant3d/scripts/main.gd:1066` (same function)**

```gdscript
# S1 / pre-fix (also B-FS:1045):
	print("SELF-SNAPSHOT fast load parity: ", "OK" if same else "MISMATCH",

# S2 / current:
	print("SELF-SNAPSHOT fast load port-internal parity (NOT donor): ", "OK" if same else "MISMATCH",
```

Both are comment/telemetry-string hardening. The JSON gate logic (`g.serialize()`, `_same_json`, map-array size checks, `return same`) is untouched. No mod removed, no threshold changed.

## 4. Drift-source register (exact file:line)

### 4.1 The flagged drift S1 → S2 (the only difference)

| # | file:line (S2 = current) | Classification | Evidence |
|---|---|---|---|
| L1 | `variant3d/scripts/main.gd:1051-1052` | COORD claim-label fix — comment only; adds `PORT-INTERNAL … (NOT donor parity)` qualifier | `reports/PORT1TO1_claim_recheck2.md:94` records "**MR-5** … `variant3d/scripts/main.gd:1051,1066` now `port-internal parity (NOT donor)`" — cites these exact lines |
| L2 | `variant3d/scripts/main.gd:1066` | COORD claim-label fix — printed string only; adds `port-internal parity (NOT donor)` | same `claim_recheck2.md:94` MR-5 |

No other drift source. `IMPL-START-CAMERA-WIRE` contributes **zero** bytes here: its surfaces are `camera.gd`, `camera3d.gd` and the `game.gd` seam (`reports/PORT1TO1_handoff_sync.md:39`, `reports/PORT1TO1_claim_recheck3.md:29/138`, `PORT1TO1_PLAN.md:232`), never `main.gd`.

### 4.2 Earlier landed work B-FS → S1 (present at the earlier reading; not part of the flagged S1→S2 drift)

`git diff --no-index --unified=0 B-FS S1` yields **18 hunks**, all matching the IMPL-FIXED-STEP design/landing and none a label hunk. Exact current (S2/S1) line positions:

| # | file:line (current) | diff hunk (B-FS → S1) | Change |
|---|---|---|---|
| F1 | `variant3d/scripts/main.gd:38-39` | `@@ -37,0 +38,2 @@` | `--deterministic-capture` / `--capture-ticks <n>` doc comments |
| F2 | `variant3d/scripts/main.gd:175-182` | `@@ -172,0 +175,8 @@` | `capture_deterministic`, `capture_ticks_total/done`, `capture_ticks_per_frame`, `capture_error`, `CAPTURE_EXPECTED_W/H` |
| F3 | `variant3d/scripts/main.gd:231-239` | `@@ -220,0 +231,9 @@` | watchdog/deadline off; refuse headless/CLI/`--seed random`/ticks<=0; `capture_ticks_per_frame = maxi(1, int(round(seq_step * Data.FPS)))` |
| F4 | `variant3d/scripts/main.gd:258` | `@@ -239 +258 @@` | `capture_deterministic` added to test/capture menu-skip bypass |
| F5 | `variant3d/scripts/main.gd:272-273` | `@@ -252,0 +272,2 @@` | authoritative 3D texture window for `--seq` |
| F6 | `variant3d/scripts/main.gd:1223-1224` | `@@ -1201,0 +1223,2 @@` | synchronous setup closes `load_ready` in deterministic mode |
| F7 | `variant3d/scripts/main.gd:1408-1413` | `@@ -1384,0 +1408,6 @@` | parse `--deterministic-capture` / `--capture-ticks` (clamped 0..1000000) |
| F8 | `variant3d/scripts/main.gd:1653` | `@@ -1624 +1653 @@` | `_process` gate adds `or (capture_deterministic and not load_ready)` |
| F9 | (deleted lines; no current line) | `@@ -1636,2 +1664,0 @@` | frame-paced `dt = minf(...)` / `acc += dt * speed` removed from the unconditional path |
| F10 | `variant3d/scripts/main.gd:1669-1695` | `@@ -1642,14 +1669,27 @@` | fixed `1/Data.FPS` tick loop in the opt-in branch; old frame-paced loop retained in `else` for all non-flag users |
| F11 | `variant3d/scripts/main.gd:1732` | `@@ -1692 +1732 @@` | `world.sync(float(steps) * (1.0 / Data.FPS) if capture_deterministic else dt)` |
| F12 | `variant3d/scripts/main.gd:1791-1795` | `@@ -1751 +1791,5 @@` | screenshot taken on `capture_ticks_done >= capture_ticks_total`, not on frame count |
| F13 | `variant3d/scripts/main.gd:1915-1918` | `@@ -1870,0 +1915,4 @@` | headless CPU-screenshot refusal (`_quit(2)`) |
| F14 | `variant3d/scripts/main.gd:1950-1954` | `@@ -1901,0 +1950,5 @@` | blank / wrong-size (1280×720) screenshot refusal; no fallback |
| F15 | `variant3d/scripts/main.gd:2202-2207` | `@@ -2149 +2202,6 @@` | seq frame reads authoritative `capture_view3d` texture |
| F16 | `variant3d/scripts/main.gd:2211-2216` | `@@ -2152,0 +2211,6 @@` | seq blank/wrong-size refusal, `capture_error = true`, `_quit(2)` |
| F17 | `variant3d/scripts/main.gd:2221-2223` | `@@ -2157 +2221,3 @@` | `det_done` replaces time/winner stop only in deterministic mode |
| F18 | `variant3d/scripts/main.gd:2227-2232` | `@@ -2160,0 +2227,6 @@` | `seq_index.json` manifest fields `deterministic`, `capture_ticks`, `ticks_done`, `ticks_per_frame`, `winner` |

`git diff --no-index --unified=0 B-FS S2` = the same 18 hunks **plus** L1/L2 = 20 hunks total; the accounting is closed.

### 4.3 Change-class summary

| Class | Bytes/sites | Attribution | Unexplained? |
|---|---|---|---|
| IMPL-FIXED-STEP (F1–F18) | 18 hunks, present in both S1 and S2 | landed: `HANDOFF.md:441`, `PORT1TO1_PLAN.md:160` (task 149 DONE), `reports/PORT1TO1_parity_recheck.md:71-73/130-131` | No |
| COORD claim-label fix MR-5 (L1–L2) | 41 bytes, the whole flagged drift | landed: `reports/PORT1TO1_claim_recheck2.md:94` | No |
| IMPL-START-CAMERA-WIRE / -3D | 0 bytes in `main.gd` | `handoff_sync.md:39`, `claim_recheck3.md:29/138`, `PLAN.md:232` | N/A — no `main.gd` surface |
| Any other edit, value, gate, threshold, `[U]` flip, preserve-only flip | none found | §3 byte-exact reconstruction | No |

## 5. Git findings (read-only)

- `git status --short -- variant3d/scripts/main.gd` → ` M`; the file is uncommitted and has been throughout the relevant window.
- `git log --oneline -- variant3d/scripts/main.gd` → 11 commits, newest `ddf07b65` (2026-11-26 11:11:57 +0100). HEAD blob `4adfd148…` = 86,641 B / SHA-256 `27439b7a7160…`. No commit equals S1 or S2.
- `git diff --stat -- variant3d/scripts/main.gd` → 111 insertions, 27 deletions vs HEAD — consistent with the accumulated uncommitted RENDERMODE/PEACEMENU/FIXEDSTEP/label waves, not with a single unexplained edit.
- Read-only `git diff --no-index` is the operative comparison here because the committed baseline is older than every backup in the chain. No git mutation was made.

## 6. Evidence ledger

| # | Observation | Label / source |
|---|---|---|
| 1 | Live `main.gd` = `94c61047…` (90,703 B); earlier transcription = `93faea93…` | [O] `Get-FileHash` this pass; `checklist_final.md:63/143`; `handoff_checklist.md:81` |
| 2 | Reversing exactly `main.gd:1051-1052` and `:1066` in the live file reproduces `93faea93…` byte-for-byte (90,662 B, 41-byte delta) | [O] scratch reconstruction + `Get-FileHash`; no repo file written |
| 3 | Those two sites are the documented MR-5 label hardening | [D] `claim_recheck2.md:94` (cites `main.gd:1051,1066`) |
| 4 | All 18 remaining backup→S1 hunks are the opt-in fixed-step implementation | [O] `git diff --no-index` B-FS→S1; [D] `fixed_step_plan.md:60-66/179/252/261/361/382/404/453/459/473`, `HANDOFF.md:441`, `PLAN.md:160`, `parity_recheck.md:71-73` |
| 5 | Start-camera wire never touches `main.gd` | [D] `handoff_sync.md:39`, `claim_recheck3.md:29/138`, `PLAN.md:232`, `owner_brief2.md:44` |
| 6 | Neither drift state is in git; file is working-tree modified | [O] read-only `git status` / `log` / `show` / `diff --stat` this pass |
| 7 | Preserve-only witnesses unchanged: B4a `3859b605…`, `world3d.gd` `0a1f2319…` | [O] `Get-FileHash` this pass; `checklist_final.md:57-58/63` |
| 8 | Read-only worker; exactly one repository file written; no code/Godot/git-mutation/donor execution; no parity box marked complete | [O] scope guard |

## 7. Verdict and owner action

**VERDICT: `EXPLAINED-LANDED-EDITS`.**

- The flagged `93faea93… → 94c61047…` drift is fully and exclusively attributable to the two landed, evidence-backed COORD claim-label fixes at `variant3d/scripts/main.gd:1051-1052` and `:1066` (MR-5, `claim_recheck2.md:94`). §3 gives a byte-exact proof; there is **no unexplained change** and no unaccounted hunk.
- The larger backup→current delta is likewise fully accounted: 18 IMPL-FIXED-STEP hunks (`HANDOFF.md:441`, `PLAN.md:160`) plus the same two label hunks. The earlier checklist simply read a post-FIXEDSTEP, pre-MR-5 tree.
- **Required owner action:** none for provenance — this audit resolves the "provenance not established" note at `checklist_final.md:63/143`. The standing capture-time rule still applies unchanged: hash `main.gd` and all §1 witnesses before and after every capture, and let COORD record the S1/S2 values in the before/after table (`acceptance_runbook.md:78-95`, `checklist_final.md:66`). Any such record is label/identity bookkeeping only and does not re-baseline, revert or repair a preserve-only item.
- Labels to carry forward: identity observation resolved; `PORT APPROXIMATION`; `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`; chain 0/6; nine P0 rows OPEN; `RESULT IS NOT GOOD`; no approximation adopted; no mod flipped; no test weakened.

## 8. Claim register (this report)

| # | Claim | Label / source |
|---|---|---|
| 1 | Drift is byte-exactly two label edits; no unexplained change | [O] §3 reconstruction, exact hash match |
| 2 | FIXEDSTEP was already present at the earlier reading; MR-5 was applied later | [O]/[D] §4.2, `claim_recheck2.md:94`, `HANDOFF.md:441`, `PLAN.md:160` |
| 3 | IMPL-START-CAMERA-WIRE has no `main.gd` surface | [D] `handoff_sync.md:39`, `claim_recheck3.md:29/138` |
| 4 | Git holds neither state; working-tree modified only | [O] read-only git queries this pass |
| 5 | Preserve-only backups and witnesses untouched | [O] `Get-FileHash` this pass |
| 6 | No parity, gate, `[U]`, value or approximation result attaches to this audit | [O] scope guard + §7 |

---

*End of PORT1TO1_maingd_drift. Read-only attribution; exactly one repository file written. Verdict EXPLAINED-LANDED-EDITS. Parity UNVERIFIED; `parity.claim = NONE`; visual parity claim false. No approximation, no parity claim, no file flipped, no git mutation, no donor execution.*
