---
id: QA-CORRECTIONS-03
title: "QA-CORRECTIONS-03 — is CORRECTIONS.md still canonical after the late donor verifications?"
date: 2026-11-25
agent: QA-CORRECTIONS-03 (read-only QA subagent)
status: DELIVERED__READ_ONLY__NO_CODE_OR_DOC_EDIT_EXCEPT_THIS_REPORT
scope: "Read-only QA of one index file and nine late verification reports. No CORRECTIONS.md edit, no code/config/asset/test/git change, no runner job, no donor access. Recommendations only."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
target: "docs/coord_swarm_2026-11-25/CORRECTIONS.md"
output: "docs/coord_swarm_2026-11-25/reports/QA_CORRECTIONS_03.md"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: "STILL CANONICAL — no indexed row is reversed. Row 28/52 needs an evidence/wording correction (DENV_02 K2/K3); rows 14/51 need a pass-count refresh (DANIM_02); rows 58-60 and the duplicate-chain notice remain exact. Three genuinely new corrections/reversals are unindexed (winter LFS pointer, donor light space, naval stale-doc scope)."
---

# QA-CORRECTIONS-03 — late-verification canonicality check

## 0. Label key and discipline

- **observed** — literal line/byte/file content read from the cited document in this pass.
- **derived** — deterministic comparison or count over observed document content (row counts, id sets, status tallies).
- **inferred** — interpretation with an explicit caveat; not a donor literal read by this QA.
- **UNVERIFIED** — cannot be settled from the read-only documents; carried forward, never promoted.

No code, config, asset, test or git state was changed. `CORRECTIONS.md` was **not** edited; every change below is a recommendation for the coordinator.

---

## 1. Sources

All paths are relative to `docs/coord_swarm_2026-11-25/` unless marked otherwise.

| # | Source | Role in this QA |
|---|---|---|
| S0 | `CORRECTIONS.md` (180 lines, read in full) | Index under test: rows 1–60, usage rules, unresolved section, summary |
| S1 | `reports/DBIND_01_wus_bind.md` (384 lines) | Authority for the three CONFIRMED_INFEASIBLE verdicts and §5 byte reasons |
| S2 | `reports/DENV_02.md` | Late verification of rows 28/52 and row 29; new K1–K4 findings |
| S3 | `reports/DANIM_02.md` | Late verification of rows 14/51; refinements to DANIM-01 |
| S4 | `reports/DBUILD_02.md` | Late second pass on DBUILD-01 (not indexed) |
| S5 | `reports/DONAVAL_02.md` | Late second pass on DONAVAL-01 (not indexed); stale-doc refutations |
| S6 | `reports/INVENTORY_01_counts.md` | Authority for rows 58/59/60 (C1/C2/C3) |
| S7 | `reports/PW_VERIFY_01.md` | Late re-count of PROP-W-PLAN-01 (not indexed) |
| S8 | `reports/QA_WINTER_01.md` | Late Winter-atlas verification; old-pointer REFUTED (C10), C9 PARTIAL |
| S9 | `reports/LIGHT_02_light_space.md` | Independent donor light-space derivation; new correction |
| S10 | `reports/TERRAIN_DARK_FIX.md` | Implementation of S9's verdict; consistency gap left open |
| X1 | `reports/DENV_01_environment.md` (targeted grep of lines 349–350, 573) | Cross-check: source of the `0/1/2 → GL_LINEAR/GL_EXP/GL_EXP2` wording that DENV_02 K3 questions |

Not read directly: donor files, DEC report bodies, port sources other than the paths quoted inside S9/S10. All statements about those are **inferred from the cited reports**, not independently re-measured by this QA.

---

## 2. Gap table — new corrections / reversals in the late reports

"Not indexed" means: no row in S0 carries the claim, its reversal, or its authority citation. **None of the nine reports reverses an existing indexed row.**

| # | Late report | New correction or reversal not represented in S0 | Evidence (report path + locator / donor or port path) | Label | Effect on S0 |
|---:|---|---|---|---|---|
| G1 | `reports/DENV_02.md` | **New caveat (not promoted to a row by that lane):** the symbolic fog labels `GL_EXP` / `GL_EXP2` for modes 1 and 2 are UNVERIFIED against a GL header; raw GL-writer pushes are `0x0800` and `0x0801`, not canonical `0x2600` / `0x2601`. The claim lives in X1 `DENV_01 §2.10` lines 349–350, which is row 28's authority. | `DENV_02.md §2 (i)` (`cossacks.exe:0xD0101` = `68 00 08 00 00`; `:0xD0122` = `68 01 08 00 00`); `§3 K3`; `§4 Q2`. X1 `DENV_01:349-350`. | observed (bytes) + derived (constant mismatch) | Row 28/52 truth is unchanged; authority wording and the inline `0x4c883e` citation need correction (E1 below). |
| G2 | `reports/DENV_02.md` | **Evidence upgrade:** direct byte-level control flow proves mode byte 0 → `GL_LINEAR` (`0x2601`) with `GL_FOG_MODE=0x0B65` and `glFogi` thunk VA `0x4AFCFC`; the `0x4c883e` quoted in row 28 is the `TFogMode` RTTI VA, not the writer. | `DENV_02.md §2 (a)` (`cossacks.exe:0xC7C3C`, VA `0x4C883C`); `§2 (b)` (`cossacks.exe:0xD00E1, :0xD00F0`, VA `0x4D0CF0`); `§2.1` (config byte → record `+0x3C` at `:0x1848D4`; writer reads descriptor `+0x28` at `:0xD00E1`; no static link); `§3 K2/K4`. | observed | Row 28 inline citation is misattributed; status stays **PARTIAL** because the `+1` bridge is UNVERIFIED. |
| G3 | `reports/DENV_02.md` | No new correction for row 29 — the sky-label inversion is **re-affirmed**, with band-continuity evidence. | `DENV_02.md §2 (d)/(e)`, `§3 K1` (`skydome.cfg:8-9,11-20,28-40`). | observed + derived | No edit needed to row 29. |
| G4 | `reports/DANIM_02.md` | **Pass upgrade / bit-level artifact:** DEC-04's exact numbers are reproduced by reading bone-major tracks frame-major with max-component metrics (`peaukr` 0.09912 / 0.01189 / 0.09496 m; 175/335 frame-major "identity" count). Fresh census gives 1.09257e−6 m / 3.01639e−8 and all 22 `b=20` files pass. No reversal. | `DANIM_02.md §3.2` (table), `§3.4` (five-file artifact table), `§5` row 1; `DEC_04_anim_formats.md:422-447` as quoted there. | observed + derived | Rows 14/51 remain true; their "verification passes" counts are understated (E2/E3). |
| G5 | `reports/DANIM_02.md` | Report-level refinements to DANIM-01, not indexed and not row-worthy: §3.3 `modal span/dur` columns actually show the most-common span over all rows (59/62 differ); DEC-04's "frames 1..740" is max *start*, max *end* is 754; 277 blank lines = 218 trailing-CRLF fields + 59 genuine blank lines in 58 files. | `DANIM_02.md §2.2, §2.5, §5` rows 3–5, `§6 Q5` (`dragoon18fra.aaf:10`, `kingmusketeer.aaf:9`). | observed + derived | No S0 row affected; no numeric change to 14/51. Owner decision open (OQ4). |
| G6 | `reports/DBUILD_02.md` | Seven refinements to DBUILD-01, which S0 does not index: C1 ship-dummy "second read" is inert `[*] = ;` code; C2 `stage=4` reachable with on-screen result UNVERIFIED; C3 mine ×2 missing on the birth→stage_1 death shortcut; C4 88.75 % exact only for real-valued `maxhp/4`; C5 extra non-conforming meshes narrow the word "all"; C6 source-path typo; C7 12 `workconstruct` variants. | `DBUILD_02.md §3 C1–C7` (`doprogressorders.inc:82-94`; `unit.script:6594-6603`; `settagstates.inc:36-39` vs `:47-48`; `nothing.inc:37-38`; `sound.script:189-190` = `scripts\lib\sound.script`). | observed + derived | No indexed row reversed. C1 is consistent with row 6's `[*]=;` rule but does not change it. No new row recommended (E7). |
| G7 | `reports/DONAVAL_02.md` | **New minor correction:** DONAVAL-01's `.osm` magic hex is `0x32445049`; raw bytes are `b'IDP2'` = `0x32504449`. Substance unaffected. | `DONAVAL_02.md §0` bullet 3, `§2.2`, `§3` item 1 (`data\actors\units\<ship>.osm:0`). | observed | No indexed row; transcribed slip only. |
| G8 | `reports/DONAVAL_02.md` | **Stale prior-doc refutations not indexed:** "no shipyard/dock `.osm` anywhere under `data/actors`" refuted (15 base `*por*` actor families, 222 `*por*.osm`, `eurpor.osm` 341,276 B); "frigate/galley/xebec `.dds` presence not confirmed" closed (5,592,560 B each); fuller naval scope 30 AAF / 12 ACL / 6 crew `.oss` vs older 24/9 and 5-core counts, which are *subsets*. | `DONAVAL_02.md §2 C1–C7`, `§2.1`, `§3` item 3, `§4` stale-doc table. PORT comment `variant3d\tools\convert_models.py:279-280`; `docs/NAVAL_PORT_PLAN.md §5 Q5`; `docs/NAVAL_EVIDENCE.md §2.1/2.2/2.4/2.5`. | observed + derived | No indexed row; candidate consolidated new row (E6). UNVERIFIED set unchanged (OQ6). |
| G9 | `reports/INVENTORY_01_counts.md` | **No new correction beyond C1/C2/C3**, which are already rows 58, 59 and 60 verbatim. Minor internal tally discrepancy: §3 says "73 MATCH, 3 NO"; §6 says "72 match exactly, one scope clarification, three do not match" (both total 76). | `INVENTORY_01_counts.md §3.1 #1`, `§3.4 #48`, `§3.5 #71`, `§4 C1/C2/C3`, `§3` totals line, `§6`. | derived | Rows 58–60 confirmed exact; tally discrepancy is report-internal and immaterial (OQ9). |
| G10 | `reports/PW_VERIFY_01.md` | Nuances only, no headline refuted: 8,211 vs 8,210 asset files; `models/tex` 173 PNGs vs 346 total files; 1 literal `w` stem (`tow`) vs "0"; decal glob `*_w` vs bare `w` (226, correct count); 354 vs 353 `.prop` files. PROP-W-PLAN-01 is not indexed. | `PW_VERIFY_01.md §2` rows 17–19, `§3` items 1–6. | observed + derived | No S0 row; no new row recommended (E7). |
| G11 | `reports/QA_WINTER_01.md` | **New reversal not indexed:** the stale-pointer / silent-Summer-fallback precondition in `reports/LFS_PLAN_01.md` is **REFUTED as to current git state** — the index/HEAD pointer at the Winter PNG is a 134-byte LFS pointer to the new OID; the old OID is gone; both Winter paths are tracked and clean. C9 is separately **PARTIAL**: renderer constant aligned, test constant not. | `QA_WINTER_01.md §2 C10`, `§4`, `§5`, `§6 C10`; read-only `git ls-files -s`, `git cat-file -s`, `git show :path`, `git status --porcelain`. Pointer `cda2423a6ef6f10984add3636f18fc8d74cdd045` 134 B → `oid sha256:5d0dd8f3…3badb`, `size 124463306`; old `6b251045…` / 74,986,953 B absent. `variant3d/scripts/world3d_terrain.gd:269-273` aligned; `variant3d/tests/t_season_overlay.gd:59-60` not; 0 swapped-name files. | observed (git/file bytes) | Row 53 covers the **Summer** atlas; Winter pointer is a distinct new row candidate (E4). Runtime/remote UNVERIFIED (OQ7). |
| G12 | `reports/LIGHT_02_light_space.md` | **New donor-space correction not indexed:** "donor Z-up → Godot Y-up via `water.dev.vert:22`" is a misattribution; donor world is Y-up, config Y is elevation, the axis mapping is identity, and `water.dev.vert:22` is a water-*local* conversion with art scales. Donor-equivalent formula gives flat-ground `dot(l,n)=0.938701`; shipped `(x/4,z/2,y)` gives 0; intermediate `(x/4,y,z/2)` gives 0.995812 (PORT APPROX). | `LIGHT_02_light_space.md §3.3`, `§3.4`, `§4` rows A–E, `§5.3–5.6`, `§6.1–6.2`; `light.cfg:26-31`, `light.ref:13-16`, `env.cfg:6`, `light.presets:16-19,79-82`, `default.cameras UpY=1`, `water.dev.vert:18,22`, `water.dev.frag:192,215,217,220`, `hf.pvl.sm.vert:9,13,15,19`. | observed (donor lines) + derived (verified twice, rotation-invariance to 16 digits) | Row 49 ("donor sun wired") is not contradicted; candidate new row (E5). Engine GL `w`/modelview binding UNVERIFIED. |
| G13 | `reports/TERRAIN_DARK_FIX.md` | Implements G12's verdict; not itself a donor correction. Final shader uses `sun_world = normalize(vec3(P.x,P.y,P.z))`; P0 gates green. Open consistency gap: module `SUN_LIGHTVEC` still un-swapped with stale `[donor Z-up]` comment. | `TERRAIN_DARK_FIX.md §1.2`, `§3`, `§4.3` (ticket 496: `mean_luma=91.424`, `max_luma=154.448`, PASS 22/22, both gates PASS), `§5` item 4; `terrain_tileindex.gdshader:291-293`; `world3d_terrain.gd:121-126,138`. | observed (port files) + derived; parity UNVERIFIED | No S0 row reversed; fold into E5 as implementation evidence, carry gap to OQ8. |

---

## 3. Consistency checks

### 3.1 Mechanical checks on S0 (derived)

| Check | Expected | Observed | Result |
|---|---|---|---|
| Summary count vs max row id | "60 indexed corrections" (S0 line 171) and max id = 60 | 60 rows; ids are exactly 1…60, contiguous | **PASS** |
| Duplicate ids | none | none (60 distinct ids) | **PASS** |
| Missing ids | none | none | **PASS** |
| Status vocabulary in the corrections table | only RESOLVED / PARTIAL / CONFIRMED_UNVERIFIED / CONFIRMED_INFEASIBLE | RESOLVED ×44, PARTIAL ×14, CONFIRMED_UNVERIFIED ×1 (row 45), CONFIRMED_INFEASIBLE ×1 (row 50); total 60 | **PASS** |
| Usage rules present | worker rules (cite authority row, carry caveats, no re-open of S-25-06, no parity from metrics) + coordinator rules (update in place, point `SUMMARY.md §9` here, promote only with evidence) | S0 lines 141–167, all four worker and four coordinator points present | **PASS** |
| Unresolved table row count vs summary | "Eight engine-side values remain UNVERIFIED, three … CONFIRMED_INFEASIBLE by `DBIND_01`" (S0 lines 178–179) | 8 data rows in the unresolved table; 3 labelled CONFIRMED_INFEASIBLE | **PASS** (table scope) |
| Unresolved section vs DBIND-01 infeasibility | DBIND-01 frontmatter: eye planes, FOV, selection predicate all CONFIRMED_INFEASIBLE | S0 unresolved rows 1–3 cite `DBIND_01 §5.1`, `§5.2`, `§5.3` with the same label; row 50 carries the same verdict | **PASS** |
| Row-status wording in unresolved section | separate vocabulary allowed | uses `UNVERIFIED`, `PARTIAL / UNVERIFIED`, `CONFIRMED_UNVERIFIED`, `CONFIRMED_INFEASIBLE`; not part of the corrections-table status set | **PASS** if the status constraint is scoped to the corrections table |

### 3.2 Targeted row accuracy (observed + derived)

| Target | Verdict | Basis |
|---|---|---|
| **Rows 14 / 51** (frame-0 bind pose) | **Accurate, pass count understated.** No reversal. Both state 335/335 frame-0 identity, 22/22 `b=20`, ~1.09e−6 m, ~3.02e−8, 1.52e−7 m peaukr skin displacement, DEC-04 refuted as an indexing artifact, skin form/quaternion/visual A/B UNVERIFIED. DANIM_02 confirms all and adds a third method (seek-census) plus bit-exact artifact reproduction. | S0 lines 60, 98; S3 `§3.2–3.4`, `§5`, `§7` |
| **Rows 28 / 52** (FogMode / sky labels) | **Truth accurate; row 28 citation and authority wording need repair.** Reversals re-affirmed by DENV_02; status must stay PARTIAL (`+1` bridge UNVERIFIED). Row 28's `0x4c883e` is the RTTI VA (S2 §2a), not the GL writer (`0xD00F0`, VA `0x4D0CF0`, S2 §2b); the `GL_EXP`/`GL_EXP2` labels originate in X1 `DENV_01:349-350`, not in S0's row text, and are UNVERIFIED (S2 §2i/K3). | S0 lines 74, 99, 111–115; S2 `§2`, `§2.1`, `§3 K1–K4`; X1 lines 349–350, 573 |
| **Rows 58 / 59 / 60** (inventory counts) | **Exact.** Row 58's 24 root files and 8 omitted names match C1; row 59's 55/32 matches C2; row 60's 455 = 313 + 142 matches C3. Statuses and authority chains unchanged. | S0 lines 107–109; S6 `§4 C1/C2/C3`, `§3.1 #1`, `§3.4 #48`, `§3.5 #71` |
| **Duplicate-chain notice** (S0 lines 111–115) | **Still accurate.** Both late verifiers explicitly invoke it: S3 frontmatter `authority` and `§1 S3` treat row 51 as authoritative and row 14 as the trail; S2 `§1.1` cites "rows 28, 52 and the row 28/52 duplicate-chain notice (line 111–115)". Neither lane added a third row; S2 K3 explicitly declines to promote one. | S2 `§1.1`, `§3 K3`; S3 frontmatter, `§1 S3`, `§5` |

### 3.3 Inference on canonicality (inferred)

S0 remains the canonical index: all 60 rows survive the late verifications with their truth and status intact; the nine late reports either re-affirm indexed rows or address material that S0 never indexed. The only defects found are (a) one misattributed citation plus an inherited UNVERIFIED symbolic label in row 28, (b) stale pass counts on the duplicate rows, and (c) coverage gaps for three late findings. None is a reversal, so no row needs to be retired or re-labelled.

---

## 4. Recommended edits (do **not** apply without coordinator approval)

All edits are in place; the duplicate-chain notice forbids adding a third frame-0 or fog row.

**E1 — Row 28 (`CORRECTIONS.md:74`), in place. Status stays PARTIAL.**
- In the New truth cell, replace "`the GL writer maps 0 → `GL_LINEAR` (`0x4c883e`)`" with: "`the GL writer maps byte 0 → `GL_LINEAR` (`0x2601`, pname `GL_FOG_MODE=0x0B65`) at `cossacks.exe:0xD00F0` (VA `0x4D0CF0`, `glFogi` thunk VA `0x4AFCFC`); the `0x4c883e` previously quoted here is the `TFogMode` RTTI VA (`cossacks.exe:0xC7C3C`), not the writer. The symbolic labels `GL_EXP`/`GL_EXP2` for modes 1/2 (inherited from `DENV_01 §2.10`) are UNVERIFIED against a GL header: raw pushes are `0x0800`/`0x0801` at `cossacks.exe:0xD0101`/`:0xD0122`.`" Keep the existing 0-based-enum, 1-based-shader, `+1`-bridge-UNVERIFIED and "do not assert donor fog off" clauses.
- Authority cell: append "`reports/DENV_02.md §2 (a)/(b)/(i), §2.1, §3 K2/K3`".
- Verification passes: `3 (config + binary + RTTI)` → `4 (config + binary + RTTI + fresh raw-byte control-flow re-read)`.

**E2 — Row 52 (`CORRECTIONS.md:99`), in place. Status stays PARTIAL.**
- Authority cell: append "`reports/DENV_02.md §2 (a)–(f), §3 K1/K2/K4`".
- New truth: append "`DENV_02 K4: flat 'fog off' is REFUTED; off only for the shader uniform (`fogMode=0`), LINEAR 390–490 on the fixed-function path.`" Keep the sky-label sentence unchanged (re-affirmed by S2 K1).
- Verification passes: `fresh read + independent extraction` → `fresh read + independent extraction + third independent re-read (DENV_02)`.

**E3 — Row 51 (`CORRECTIONS.md:98`, authoritative frame-0 row), in place. Status stays RESOLVED.**
- Authority cell: append "`reports/DANIM_02.md §3.2–§3.4` (fresh `struct.unpack_from` seek census; DEC-04 numbers reproduced bit-for-bit as a frame-major + max-component artifact)".
- Verification passes: `2 independent methods` → `3 (sequential reader + offset-seek census + artifact bit-level reproduction)`.
- Optional precision refresh in New truth: `1.09e−6 m` → `1.09257e−6 m`, `3.02e−8` → `3.01639e−8`, add "`175/335` frame-major artifact identity count". Keep the UNVERIFIED skin-form / quaternion / rendered-A/B caveat verbatim.
- **Do not edit row 14** beyond an optional pointer "→ see row 51 (authoritative)"; it remains the original claim trail per the notice.

**E4 — New row 61 (winter atlas LFS pointer), if the coordinator wants coverage of S8.**
- Old claim: "The Winter atlas index still holds the old pointer; loading silently falls back to Summer art."
- Old source: `reports/LFS_PLAN_01.md` old-pointer / silent-fallback warning (as quoted in S8 `§2 C10`).
- New truth: "REFUTED as to current git state: index and HEAD carry a 134-byte LFS pointer `cda2423a6ef6f10984add3636f18fc8d74cdd045` → `oid sha256:5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb`, `size 124463306`; both Winter paths tracked and clean; the old `6b251045…` / 74,986,953-byte pointer is absent. Remote object availability, runtime binding and GPU parity UNVERIFIED. Renderer constants aligned (`world3d_terrain.gd:269-273`); test constants not (`t_season_overlay.gd:59-60`), 0 swapped-name files."
- Authority: "`reports/QA_WINTER_01.md §2 C9/C10, §4, §5, §6 C9/C10` (read-only `git ls-files -s` / `cat-file -s` / `show :path` / `status --porcelain`)".
- Verification passes: `1 (read-only git/file state; no network probe, no runner)`.
- Status: `RESOLVED` (current-state claim only; caveats carried in truth cell).

**E5 — New row 62 (donor light space / `water.dev.vert:22`), if the coordinator wants coverage of S9/S10.**
- Old claim: "Donor is Z-up; `water.dev.vert:22` `(x/4,z/2,y)` is a donor Z-up → Godot Y-up axis conversion; map donor Y into Godot Z and donor Z into Godot Y."
- Old source: "`reports/TERRAIN_DARK_01.md §2 step 4 / §5`; `terrain_tileindex.gdshader:136-139` comment; `world3d_terrain.gd:121-126,138`".
- New truth: "Refuted: donor world and Godot world are both Y-up; `light.cfg:26-31` `Position.Y=0.938701` is the up/elevation component (verified four ways: `light.ref:13-16` radius 20000 = `env.cfg:6` `LensFlareOrbitRadius`, `light.presets:16-19,79-82` keep +Y while Z flips, `default.cameras UpY=1`, water level from `pos.y`). `water.dev.frag:192,215,217,220` shows `water.dev.vert:22` is a water-local eye-Y-up → water-Z-up conversion with art scales, not a world-axis mapping. Donor-equivalent `sun_world = normalize(vec3(P.x,P.y,P.z))` → flat-ground `dot(l,n)=0.938701` at any tilt; shipped `(x/4,z/2,y)` → 0; intermediate `(x/4,y,z/2)` → 0.995812 (PORT APPROX). Final shader uses the donor-equivalent formula; engine GL `w`/modelview binding and visual parity UNVERIFIED."
- Authority: "`reports/LIGHT_02_light_space.md §3.3, §3.4, §4 rows A–C, §5.3–5.6, §6.1–6.2`; `reports/TERRAIN_DARK_FIX.md §1.2, §3, §4.3, §8` (ticket 496 gates PASS)"; donor `path:line` list as in G12.
- Verification passes: `2 independent derivations (LIGHT-02 + TERRAIN-DARK-FIX fresh re-read); flat-ground dot verified twice by rotation invariance`.
- Status: `PARTIAL` (axis correction resolved by readable evidence; engine binding and parity stay UNVERIFIED). If the coordinator prefers to index only the axis sub-claim, `RESOLVED` is defensible — but then the `PORT APPROXIMATION` clause must stay.

**E6 — Optional new row 63 (naval stale-doc refutations), if S0's remit is broadened beyond row 49-style arbitration.**
- Old claim: "'No shipyard/dock `.osm` anywhere under `data/actors` … Shipyard is a name only, not an actor'; frigate/galley/xebec `.dds` presence 'not confirmed'; 24 AAF / 9 ACL and 54-mesh / 5-`.oss` figures treated as totals."
- Old source: "`convert_models.py:279-280`; `reports/../NAVAL_PORT_PLAN.md §5 Q5`; `docs/NAVAL_EVIDENCE.md §2`".
- New truth: "Refuted/closed: 15 base `*por*` shipyard actor families, 222 `*por*.osm`, `eurpor.osm` 341,276 B; 10 ship-alias `.dds` with frigate/galley/xebec 5,592,560 B each; fuller naval scope 30 AAF / 12 ACL / 6 crew `.oss` — the older 24/9 and 5-core counts are scoped subsets, not totals. IDP2 hex literal corrected to `0x32504449` (`b'IDP2'`). Effective speed, `not … < 4` precedence, `xebeca.dds` selection, attach transforms and DDS pixels/parity remain UNVERIFIED."
- Authority: "`reports/DONAVAL_02.md §0, §2 C1–C7, §2.1, §2.2, §3, §4`"; evidence `data\actors\buildings\**\*por*.{actor,osm}`, `data\materials\units\*.dds`, `data\animations\{aaf,acl}`.
- Verification passes: `2 independent enumeration methods per count`.
- Status: `RESOLVED` for presence/scope; caveats in truth cell.

**E7 — No new rows for S4 (`DBUILD_02`) or S7 (`PW_VERIFY_01`).** Their C1–C7 and nuances are refinements to reports S0 never indexed and are non-material to any indexed row. Optional: add both report paths to S0's Sources section for completeness (derived).

**E8 — Summary / wording (apply only with E4–E6).**
- If E4–E6 are all adopted: change "60 indexed corrections" → "63 indexed corrections" and extend the scope list with "light space, naval scope, winter-atlas git state" (it already contains "atlas transport"). Adjust to 62 or 61 if only some are adopted.
- Independently of new rows, change "Eight engine-side values remain UNVERIFIED" → "Eight rows in the unresolved table (plus six further items listed below) remain UNVERIFIED" to avoid undercounting the six paragraph items (S0 lines 134–139).
- Optional: add "inventory counts" to the summary scope list so rows 58–60 are named.

---

## 5. Open questions

1. **UNVERIFIED / owner decision:** will the coordinator adopt E1–E8, and which of E4/E5/E6? This QA applied no edits.
2. **UNVERIFIED:** DENV_02 did not perform a GL-header/import cross-check; `0x0800`/`0x0801` remain unnamed. Who resolves OQ2 of S2, and does row 28 then gain symbolic labels?
3. **UNVERIFIED:** DENV_02 `§2.1`/`§4 Q1–Q2` — the config→shader `+1` bridge (record `+0x3C` vs descriptor `+0x28`), GL `w` binding and donor GPU A/B. Row 28/52 must stay PARTIAL until one is evidenced.
4. **UNVERIFIED / owner decision:** S3 `§6 Q5` — relabel DANIM-01 §3.3 columns as "modal span (rows)" or recompute them as span of the modal range. No S0 number changes either way.
5. **UNVERIFIED:** S4 C2/C3 on-screen `stage=4` outcome and birth-state mine timing are derived control flow only; no runtime capture.
6. **UNVERIFIED (unchanged from DONAVAL-01 §6):** effective `objbase.speed`, `not … < 4` precedence, `xebeca.dds` selection, attach transforms, DDS pixels/parity, `gc_obj_shipcontructrollangle` and `gc_WaterBorderSize` values.
7. **UNVERIFIED:** S8 `§7 Q1/Q2` — remote LFS object availability and actual season capture binding; C9 test-constant alignment may be completed later.
8. **UNVERIFIED / module owner:** S9 `§6.5` and S10 `§5` item 4 — `world3d_terrain.gd:121-126,138` still carries the un-swapped `SUN_LIGHTVEC=(x/4,z/2,y)` and `[donor Z-up]` comment while the shader is `unshaded`; other scene objects and `stats.sun_direction_yup` may disagree with the shader's final sun. Engine GL `w`/modelview binding, absolute-luma residual and rendered parity also remain open.
9. **UNVERIFIED (report-internal, immaterial):** S6 `§3` says "73 MATCH, 3 NO" while `§6` says "72 match exactly, one scope clarification, three do not match"; the origin of the discrepancy was not re-derived by this QA and no S0 row is affected.
10. **Inferred:** whether S0's "no new donor findings; only indexes existing, cited ones" charter should be read as excluding E4/E5/E6 (which index late findings that reverse *other* documents' claims) — a policy decision, not a factual gap.

---

## 6. Summary

- **Canonicality: PASS.** `CORRECTIONS.md` has 60 contiguous rows (ids 1–60), no duplicates, an allowed status set (44 RESOLVED, 14 PARTIAL, 1 CONFIRMED_UNVERIFIED, 1 CONFIRMED_INFEASIBLE), and a summary count equal to the max row id. The unresolved table has 8 rows with exactly the three DBIND-01 CONFIRMED_INFEASIBLE verdicts (eye planes §5.1, FOV §5.2, selection predicate §5.3; mirrored by row 50). Usage rules are intact.
- **Targeted rows: accurate.** Rows 14/51 (frame-0), 28/52 (fog/sky), and 58–60 (inventory) all survive; the duplicate-chain notice at lines 111–115 is explicitly invoked by both DENV_02 and DANIM_02 and remains authoritative. No late report adds a third row to either chain.
- **Repairs needed, not reversals:** row 28's inline `0x4c883e` is the RTTI VA rather than the GL writer (`cossacks.exe:0xD00F0`); the `GL_EXP`/`GL_EXP2` labels inherited from DENV_01 §2.10 are UNVERIFIED (`0x0800`/`0x0801`); rows 28/52 and 14/51 need pass-count refreshes (E1–E3).
- **Coverage gaps:** three late findings are genuinely unindexed — Winter-atlas LFS pointer state (QA_WINTER_01 C10), donor Y-up light space / `water.dev.vert:22` misattribution (LIGHT_02 + TERRAIN_DARK_FIX), and naval stale-doc refutations (DONAVAL_02). Recommended as rows 61–63 (E4–E6), with summary updates (E8). DBUILD_02 and PW_VERIFY_01 produced refinements only; no row is warranted (E7).
- **Labels:** all conclusions above are **observed** (document content) or **derived** (counts/comparisons); the policy reading in OQ10 is **inferred**; every runtime, remote and parity matter is **UNVERIFIED** and unpromoted.
- No file other than this report was edited.

*End of QA-CORRECTIONS-03. Read-only QA; recommendations only; no donor access, no runner job, no parity claim.*
