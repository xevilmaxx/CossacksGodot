---
id: CORRECTIONS-REFRESH-01
title: "CORRECTIONS-REFRESH-01 — apply the exact repairs proposed by QA_CORRECTIONS_03"
date: 2026-11-25
agent: CORRECTIONS-REFRESH-01 (documentation repair worker)
status: DELIVERED__DOC_ONLY__NO_CODE_OR_RUNNER_JOB
scope: "In-place repairs E1–E3, new rows E4–E6 and summary update E8 in CORRECTIONS.md, plus this report. No code, config, asset, test, git-index or runner change; no donor access; no parity claim."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
target: "docs/coord_swarm_2026-11-25/CORRECTIONS.md"
output: "docs/coord_swarm_2026-11-25/reports/CORRECTIONS_REFRESH_01.md"
authority: "docs/coord_swarm_2026-11-25/reports/QA_CORRECTIONS_03.md §4 E1–E8; §2 G1/G2/G4/G8/G11/G12/G13; §3.2; §6"
labels: [observed, derived, inferred, UNVERIFIED]
---

# CORRECTIONS-REFRESH-01 — applied QA_CORRECTIONS_03 repairs

## 0. Label key and discipline

- **observed** — literal content read from `CORRECTIONS.md` or `QA_CORRECTIONS_03.md` in this pass.
- **derived** — deterministic count or comparison over that content (id set, status tally, summary equality), computed with `python` (3.14) by a temporary script outside the repository.
- **UNVERIFIED** — carried forward from the cited reports; not settled here, never promoted.
- **inferred** — explicitly flagged interpretation only (§5 item 8).

Every repair below is a transcription of a QA recommendation; no donor file was opened, no runner job was scheduled, and no verdict was re-decided.

---

## 1. Sources and exclusive ownership

| # | File | Role |
|---|---|---|
| S0 | `docs/coord_swarm_2026-11-25/CORRECTIONS.md` | Sole in-place edit target (before: 180 lines / 60 rows; after: 186 lines / 63 rows). |
| S1 | `docs/coord_swarm_2026-11-25/reports/QA_CORRECTIONS_03.md` | Authority for E1–E8 and for the no-reversal finding; read in full, not edited. |
| S2 | This report | Created by this worker. |

**Exclusive ownership respected:** this worker edited only `CORRECTIONS.md` and created `CORRECTIONS_REFRESH_01.md`. The other working-tree changes visible in `git status --porcelain` (e.g. `CONFIG_COUNT_RECONCILED.md`, `PROGRESS.md`, `variant3d/*`) were already present from other lanes and were **not** touched, read for content, staged or committed by this worker. DOC-02 was terminated and had no file in this scope.

---

## 2. Mechanical verification — exact before/after counts (derived)

Verification script: `python <temp>\verify_corrections.py <path to CORRECTIONS.md>`; regex `^\|\s*(\d+)\s*\|` for table ids, final cell for status, `(\d+) indexed corrections` for the summary count.

| Check | Before | After | Result |
|---|---|---|---|
| Table row count | 60 | 63 | **PASS** (+3 = E4/E5/E6) |
| Id range | 1…60 | 1…63 | **PASS** |
| Contiguous 1…max | True | True | **PASS** |
| Duplicate ids | none | none | **PASS** |
| Missing ids | none | none | **PASS** |
| Status tally | 44 RESOLVED / 14 PARTIAL / 1 CONFIRMED_UNVERIFIED / 1 CONFIRMED_INFEASIBLE (total 60) | 46 RESOLVED / 15 PARTIAL / 1 CONFIRMED_UNVERIFIED / 1 CONFIRMED_INFEASIBLE (total 63) | **PASS** |
| Statuses outside allowed set {RESOLVED, PARTIAL, CONFIRMED_UNVERIFIED, CONFIRMED_INFEASIBLE} | none | none | **PASS** |
| Summary count occurrences | [60] | [63] | **PASS** |
| Summary count = max id | True (60 = 60) | True (63 = 63) | **PASS** |

Delta matches the new rows exactly: +2 RESOLVED (rows 61 and 63), +1 PARTIAL (row 62), no change to the single CONFIRMED_UNVERIFIED (row 45) or CONFIRMED_INFEASIBLE (row 50). The duplicate-chain notice (S0 lines 111–115) and the entire "Claims that stay UNVERIFIED" table are byte-identical before and after (`git diff` confirms no hunk in either region).

---

## 3. Per-edit before → after

### E1 — Row 28, in place (authority: QA §4 E1, lines 107–110; §2 G1/G2, lines 57–58; §3.2, line 93)

| Field | Before | After |
|---|---|---|
| New truth | `the GL writer maps 0 → GL_LINEAR (0x4c883e)` | `the GL writer maps byte 0 → GL_LINEAR (0x2601, pname GL_FOG_MODE=0x0B65) at cossacks.exe:0xD00F0 (VA 0x4D0CF0, glFogi thunk VA 0x4AFCFC); the 0x4c883e previously quoted here is the TFogMode RTTI VA (cossacks.exe:0xC7C3C), not the writer. The symbolic labels GL_EXP/GL_EXP2 for modes 1/2 (inherited from DENV_01 §2.10) are UNVERIFIED against a GL header: raw pushes are 0x0800/0x0801 at cossacks.exe:0xD0101/:0xD0122.` |
| Authority | `DENV_01 §2.10, §6 C4 …; RV_TRN_03 §7 #8` | same, plus `; reports/DENV_02.md §2 (a)/(b)/(i), §2.1, §3 K2/K3` |
| Verification passes | `3 (config + binary + RTTI)` | `4 (config + binary + RTTI + fresh raw-byte control-flow re-read)` |
| Status | `PARTIAL` | `PARTIAL` (**unchanged**) |

Retained verbatim: the 0-based enum / 1-based shader statement, the `+1`-bridge UNVERIFIED clause, and "keep port fog off but do not assert 'donor fog off'". The trailing "Fixed-function LINEAR fog is active at 390–490" sentence was kept, with only its leading conjunction adjusted so the inserted sentence reads cleanly.

### E2 — Row 52, in place (authority: QA §4 E2, lines 112–115; §3.2, line 93; §2 G2)

| Field | Before | After |
|---|---|---|
| New truth | ends with `…the port mapping was correct` | same, appended: `DENV_02 K4: flat 'fog off' is REFUTED; off only for the shader uniform (fogMode=0), LINEAR 390–490 on the fixed-function path.` |
| Authority | `DENV_01 (env/** key tables, colors.lib statictables, RTTI crosswalk)` | same, plus `; reports/DENV_02.md §2 (a)–(f), §3 K1/K2/K4` |
| Verification passes | `fresh read + independent extraction` | `fresh read + independent extraction + third independent re-read (DENV_02)` |
| Status | `PARTIAL` | `PARTIAL` (**unchanged**) |

The sky-label sentence was not altered (re-affirmed by DENV_02 K1 per QA §3.3/§6).

### E3 — Rows 51 and 14, in place (authority: QA §4 E3, lines 117–121; §2 G4, line 60; §3.2, line 92)

| Field | Before | After |
|---|---|---|
| Row 51 authority | `DANIM_01_action_ranges.md` (two methods…) | same, plus `; reports/DANIM_02.md §3.2–§3.4 (fresh struct.unpack_from seek census; DEC-04 numbers reproduced bit-for-bit as a frame-major + max-component artifact)` |
| Row 51 passes | `2 independent methods` | `3 (sequential reader + offset-seek census + artifact bit-level reproduction)` |
| Row 51 truth numbers | `max |p|=1.09e−6 m; peaukr skin f0 displacement 1.52e−7 m` | `max |p|=1.09257e−6 m; max |q|=3.01639e−8; peaukr skin f0 displacement 1.52e−7 m; … DEC-04's 175/335 frame-major 'identity' count reproduced as an artifact` |
| Row 51 status | `RESOLVED` | `RESOLVED` (**unchanged**) |
| Row 14 | no pointer | appended `→ see row 51 (authoritative)` to the New truth cell only |

Per QA §4 E3's final bullet, row 14 received **only** the optional pointer: its pass count (`3 (sequential reader + whole-family offset-seek census + artifact reproduction)`), truth numbers and `RESOLVED` status are unchanged. See §5 item 1 for the internal inconsistency in E3's precision bullet.

### E4 — New row 61, Winter atlas LFS pointer (authority: QA §4 E4, lines 123–129; §2 G11, line 67)

- Old claim, old source, new truth (134-byte pointer `cda2423a6ef6f…3badb`, size 124463306; old `6b251045…` / 74,986,953 B absent; renderer constants aligned `world3d_terrain.gd:269-273`, test constants not `t_season_overlay.gd:59-60`, 0 swapped-name files), authority (`QA_WINTER_01.md §2 C9/C10, §4, §5, §6 C9/C10` with the read-only git commands), passes `1 (read-only git/file state; no network probe, no runner)` and status `RESOLVED` — all transcribed verbatim from E4.
- Caveat carried in the truth cell: remote object availability, runtime binding and GPU parity remain UNVERIFIED.

### E5 — New row 62, donor light space / `water.dev.vert:22` (authority: QA §4 E5, lines 131–137; §2 G12 line 68 and G13 line 69)

- Old claim/source, the four-way Y-up verification, the water-local `(x/4,z/2,y)` reattribution, the three `dot(l,n)` results (0.938701 / 0 / 0.995812 PORT APPROX), the authority list including the donor `path:line` set from G12 and `TERRAIN_DARK_FIX.md §1.2, §3, §4.3, §8` (ticket 496 gates PASS), passes `2 independent derivations … verified twice by rotation invariance`, and status `PARTIAL` — all transcribed from E5.
- Engine GL `w`/modelview binding and visual parity stay UNVERIFIED in the truth cell, as E5 requires.

### E6 — New row 63, naval stale-doc refutations (authority: QA §4 E6, lines 139–145; §2 G8, line 64)

- Old claim/source, the 15 `*por*` actor families / 222 `*por*.osm` / `eurpor.osm` 341,276 B, the 10 ship-alias `.dds` at 5,592,560 B each, the 30 AAF / 12 ACL / 6 crew `.oss` scope with the older 24/9 and 5-core counts as subsets, the IDP2 literal `0x32504449`, the authority citation and `2 independent enumeration methods per count`, status `RESOLVED` — all transcribed from E6.
- Caveats (effective speed, `not … < 4` precedence, `xebeca.dds` selection, attach transforms, DDS pixels/parity) remain UNVERIFIED in the truth cell.

### E8 — Summary / wording (authority: QA §4 E8, lines 149–152)

| Before | After |
|---|---|
| `60 indexed corrections` | `63 indexed corrections` |
| scope `… atlas transport, UI and stale-doc arbitration` | `… atlas transport, light space, naval scope, winter-atlas git state, inventory counts, UI and stale-doc arbitration` (the last item is E8's optional addition) |
| no status tally | added `Status tally: 46 RESOLVED, 15 PARTIAL, 1 CONFIRMED_UNVERIFIED, 1 CONFIRMED_INFEASIBLE.` (per task instruction "update summary count and status tally") |
| `Eight engine-side values remain UNVERIFIED` | `Eight rows in the unresolved table (plus six further items listed below) remain UNVERIFIED` |

Duplicate-chain notice and unresolved table: **unchanged**.

### Not applied (explicitly out of scope)

E7 (no new rows for `DBUILD_02` / `PW_VERIFY_01`, and the optional Sources-section addition) was not part of the assigned E1–E6/E8 set. No E7 edit was made.

---

## 4. No-reversal statement

**No verdict was reversed, retired or re-labelled.** All 60 pre-existing rows keep their original status; specifically rows 28 and 52 remain `PARTIAL` (the `+1` bridge is still UNVERIFIED), rows 14 and 51 remain `RESOLVED`, rows 29, 49 and 53 keep their truth and status, and the single `CONFIRMED_UNVERIFIED` (45) and `CONFIRMED_INFEASIBLE` (50) labels are untouched. The three added rows index *new* reversals of **other documents'** claims (as QA §2 line 53 and §3.3 line 99 distinguish) and do not overturn any indexed row. This is consistent with QA_CORRECTIONS_03's own verdict at §1 line 12 ("no indexed row is reversed") and §6 lines 173–175 ("Repairs needed, not reversals").

---

## 5. Open questions

1. **UNVERIFIED / owner decision (E3 inconsistency):** E3's optional precision bullet names literals `1.09e−6` and `3.02e−8` and an "UNVERIFIED skin-form / quaternion / rendered-A/B caveat" — these match **row 14's** literal text, not row 51's; yet the same bullet heads "Row 51" and its final sub-bullet forbids editing row 14 beyond a pointer. This worker applied the refreshed values to authoritative row 51 and added the permitted pointer to row 14; row 14's own `1.09e−6` / `3.02e−8` remain unrefreshed. Refreshing row 14 would require lifting E3's "do not edit row 14" constraint.
2. **UNVERIFIED (QA OQ2):** no GL-header/import cross-check was performed for raw pushes `0x0800`/`0x0801`; row 28/52 stay `PARTIAL` and the symbolic `GL_EXP`/`GL_EXP2` labels are carried only as UNVERIFIED.
3. **UNVERIFIED (QA OQ3):** config→shader `+1` bridge (record `+0x3C` vs descriptor `+0x28`), GL `w` binding and donor GPU A/B remain open.
4. **UNVERIFIED (QA OQ7):** remote LFS object availability and actual season capture binding; row 61's `RESOLVED` covers current git state only, with C9 test-constant alignment still open.
5. **UNVERIFIED / module owner (QA OQ8 / G13):** `world3d_terrain.gd:121-126,138` still carries the un-swapped `SUN_LIGHTVEC=(x/4,z/2,y)` and stale `[donor Z-up]` comment while the shader is `unshaded`; row 62 records the axis refutation but does not close that module gap.
6. **UNVERIFIED (QA OQ6):** naval effective speed, precedence, `xebeca.dds` selection, attach transforms and DDS pixels/parity are carried forward in row 63.
7. **UNVERIFIED / immaterial (QA OQ9):** `INVENTORY_01_counts.md §3` "73 MATCH, 3 NO" vs `§6` "72 match exactly, one scope clarification, three do not match"; no indexed row affected.
8. **Inferred / owner decision:** E8 did not propose the status-tally sentence; it was added because the task explicitly required the status tally to be updated. E8's optional "inventory counts" scope item was adopted. Either can be reverted without touching any row.
9. **Inferred / policy (QA OQ10):** whether this index's "does not add new donor findings" charter admits rows 61–63 — which index reversals of *other* documents — remains a coordinator policy call; the rows were added because the task explicitly required E4–E6.

---

## 6. Summary

- Applied exactly E1–E3 in place (row 28 writer offset `0xD00F0` / RTTI `0x4c883e` reattribution; modes 1/2 labels UNVERIFIED at `0x0800`/`0x0801`; authority appends; pass counts 3→4 for 28, +third re-read for 52, 2→3 for 51; precision refresh on 51; optional pointer on 14), E4–E6 as rows **61–63**, and E8 summary updates.
- `CORRECTIONS.md` now has **63 contiguous rows (ids 1–63)**, no duplicate or missing ids, all statuses in the allowed set, summary count 63 = max id, and status tally **46 RESOLVED / 15 PARTIAL / 1 CONFIRMED_UNVERIFIED / 1 CONFIRMED_INFEASIBLE**. Before: 60 rows, 44/14/1/1, summary 60. Both checks PASS.
- Duplicate-chain notice and unresolved table preserved verbatim; **no indexed verdict reversed**.
- **No other file was edited by this worker:** only `CORRECTIONS.md` was modified and this report was created. No code, config, asset, test, git-index or runner job was touched; no donor access or parity claim was made.

*End of CORRECTIONS_REFRESH-01.*
