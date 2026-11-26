---
id: V26
ticket: "TERRAIN-SWARM-2026-11-26 / V26 — resolve V17's four material SPEC conflicts (READ-ONLY)"
agent: "V26 (spec-conflict resolution worker, 30-agent DONOR-FIRST terrain swarm)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V26_spec_conflicts_resolved.md
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_SPEC_EDIT__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_GODOT_JOB
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists and none was produced here. 'Authoritative' below means best cited evidence for a donor path:line, value or working-tree state — NEVER visual fidelity. Every port consequence is PORT APPROXIMATION / [U] (CHARTER.md:43-44,122-135)."
scope: "Read CHARTER.md, SWARM_BOARD.md, IMPLEMENTATION_PLAN.md, V17_spec_readiness.md (its 4 material conflicts), V16_contradiction_register.md, spec/README.md and all spec files 01-14; re-read both sides of each conflict plus the cited reports (D05, X12, X13, A02, X03, F07, V12, V01, X22, V16, F04, D03, X18, X19, V04, V05, V11, P06, A06) and raw donor/port lines. Multiple passes on every disagreement. No spec, source, shader, config, asset, test, JSON, git, queue or app/ change; no donor binary run."
multiple_passes: true
read_only: true
---

# V26 — resolution of V17's four material SPEC conflicts

## 0. Executive summary

1. **[O] All four V17 conflicts were re-read in both named spec sections and in every cited report/donor file; each has a paste-ready resolution below.** V17 (`reports/V17_spec_readiness.md:19,70-75,166`) named: X1 blend math (§04 vs §10), X2/X3 food rects + reversed `mapsize>2` gating (§07/§10), X5 mask R/G semantics (§03 vs §01/§04/§10), X6 stale git/seam status (§12 vs §13/§14). No claim of donor visual parity is made anywhere in this report.
2. **[D] Conflict 1 is BOTH-STAGE-SPECIFIC (with one refutation).** D05/X12 (independently X13) govern the **native pattern-stamp** stage: three branches, `Min` as scale pivot, `Max` never read, `Offset` additive (`cossacks.exe:0x755f30`, `+0x5c/+0x60/+0x64`). A02/X03's DScript class×R amplitude formula is a **different stage** (mask→height, `generatemap.inc:4-7,567-574`) and stays cited at `spec/03 §2` and `spec/10 §2` "Height classes"; A02's `clamp(h_base+grid*Scale,Min,Max)` placeholder is refuted and must be struck from `spec/04 §3` and `spec/10 §2/§4`. Global setter clamp remains `[U]` (`D05 U2`, `X12 U2`).
3. **[O] Conflict 2 has one authoritative statement.** `SetupStartingResources` (`dogenerate.inc:720-977`) places **no food rects** (`V12 C-V4`, `X22 X-C6`, `F07 §0`, `D07 §3.6`); fields are **unit-script sown** by `_unit_DoSeedWheat` (`unit.script:6470-6570`, 7×7=49 nodes). `mapsize>2` is the **256-cell tiny map** (`donewgame.inc:42-46`: 0→320, 1→480, 2→640, 3→256; `V01 P4/EV08`), not the default 320/480/640 band; V12's `[U]` enum label is superseded. `V17 X3`'s "ring 4/5 skipped" must read `continue` with name-draw consumption (`V12 C-V7`).
4. **[O] Conflict 3 has one authoritative skirmish statement plus an explicit `[U]` residue.** F04/D03/X18/X19 measured R=G=0 on every non-start pixel of all 1,331 vanilla `_gauss` masks; `h=−1.1·B/255`. `generatemap.inc:21-32,454-485` is authored **intent** `[O]` text, inert on shipped pixels. What stays `[U]`: runtime execution of `[*] = ;` text, R/G semantics on `.src`/modded masks, density-from-G derivation, native smoothing kernels, stamp-vs-smooth stage order.
5. **[O]/[U] Conflict 4 must be split.** V04/V05/V11/V16 are AUTHORITATIVE that P06/A06's "three uncommitted Y08b/Y10/Y11 edits" are stale (committed in `e234ac9b`). But **at the V26 re-read that snapshot is itself stale**: HEAD is still `e234ac9b`, yet `main.gd`/`world3d.gd` carry **uncommitted I11-SEAM inserts** with `.bak-COORD-I11` backups and untracked donor files; `terrain_donor_world.gd` is absent. Any permanent spec sentence "all port files clean / seam unapplied" is UNVERIFIED — COORD must re-read status before dispatch. This is the single current statement in §4.4.

## 1. Evidence table (multiple passes recorded)

| # | Source re-read (spec:section + report:line + donor/port path:line) | Passes | Establishes | Label |
|---|---|---|---|---|
| E1 | `spec/04_PATTERN_STAMPING.md §3` (`:46-49`) vs `§6` (`:69-90`); `spec/10_STAGE_ORDER.md §2` (`:43`), `§4` (`:67-69`); `reports/D05_relief_stamp.md:17-25,92-171,227-238`; `reports/X12_stamp_verification.md:17-22,118-136`; `reports/X13_blend_test_vectors.md:9,99-129`; `reports/A02_algorithm.md:83-89,394-413`; `cossacks.exe:0x755f30` (`+0x3a/+0x3b/+0x48/+0x5c/+0x60/+0x64`); `pattern.lib:549563-549575` | 2 on spec + 2 on reports + raw opcode/x87 pass inherited from D05 P6/X12 P4–P5 | Three native stamp paths authoritative; `Min` pivot, `Max` zero `+0x60` reads in 6,751 instructions, `Offset` additive; A02 clamp placeholder refuted | [O]/[D] |
| E2 | `spec/03_MASK_TO_HEIGHT.md §2` (`:28-33`); `spec/10 §2` "Height classes" (`:41`); `spec/04 §3` (`:50-51`); `reports/X03_dscript_corpus.md:368-369,500`; `reports/A02_algorithm.md:251-304`; donor `generatemap.inc:4-7,21-32,454-485,537-547,563-574` | 2 (spec, then verbatim donor lines re-read in this ticket) | DScript class×R amplitude formula is donor-intent text for the mask→height stage, not the stamp blend | [O] text / [U] runtime |
| E3 | `spec/07_RESOURCES.md §1` (`:16-24`), `§2` (`:26-35`), `§7` (`:69-80`); `spec/10 §2` rows "Starting resources"/"Fields" (`:50,53`); `reports/F07_mill_fields.md:21-24,148-169`; `reports/V12_resource_spec.md:43-49,82,184-208,355,371`; `reports/V01_unverified_resolution.md:51,81-85,154,222-289`; `reports/X22_field_sowing_translation.md:53,60-66`; donor `dogenerate.inc:720-977`, `unit.script:6470-6570`, `donewgame.inc:42-46` | 3 (spec → V12/F07 → raw donor lines + V01 enum) | No food rects; fields script-sown; `mapsize>2` = 256 tiny; V12's enum `[U]` superseded | [O]/[D] |
| E4 | `spec/03 §1` (`:21-26`), `§2` (`:28-33`); `spec/01 §3` (`:41-53`); `spec/04 §3` (`:46-51`); `spec/10 §2` (`:41`); `reports/F04_masks.md:43-58,189-252,448-499`; `reports/D03_mask_pipeline.md:20-25,98-110`; `reports/X19_mask_decoder_gap.md:27-73,170-261`; `reports/X18_mask_channel_verification.md:28-52,301-303`; donor `generatemap.inc:413-490,537-547,563-574` | 3 (both spec sides → F04/D03 → X18/X19 + raw donor lines) | Shipped-pixel truth authoritative; class semantics intent-only; explicit `[U]` residue isolated | [O]/[U] |
| E5 | `spec/12_QA_AND_INTEGRATION.md §12.1` (`:22-24`), `§12.4` (`:70-88`); `spec/13_PRIOR_WAVE_MEMORY.md §4` (`:33-38`); `spec/14_CURRENT_PIPELINE.md §5` (`:31-36`); `reports/V04_tree_conflicts.md:19-25,§0 P1-P6`; `reports/V05_seam_reconciliation.md:31-33,39-45`; `reports/V11_ownership_ledger.md:19-25,§0 P1-P7`; `reports/V16_contradiction_register.md` V16-10/18/23; `reports/P06_prior_wave_distill.md:194-204`; `reports/A06_integration.md:69-70,255-258` | 4 (spec ×3 + three audits + raw P06/A06 lines) | P06/A06 "three uncommitted edits" stale; V04/V05/V11 snapshot correct at their read | [O]/[D] |
| E6 | Live read-only `git rev-parse --short HEAD`; `git status --porcelain=v1`; `git diff --stat`; `git diff -- variant3d/scripts/{main.gd,world3d.gd}`; `git log -3`; `git rev-parse HEAD:<path>`; `Get-FileHash` on `.bak-COORD-I11`; `variant3d/scripts/main.gd:125,189-191,593-594,1112-1113`; `variant3d/scripts/world3d.gd:118,144-145,220-224,624,706-707`; `Test-Path terrain_donor_world.gd` | 4 (status, diff/stat, symbol grep with line numbers, backup-hash + HEAD-blob comparison) | HEAD still `e234ac9b`; seam inserts now applied in the working tree; pre-seam backups exact; composer absent | [O] (point-in-time) |

**Pass discipline:** every conflict was re-read in *both* spec sections named by V17 and then in the cited report(s); E1, E3, E4 and E6 were additionally checked against raw donor bytes/lines or live git output with a second instrument. No disagreement was resolved on a single reading. V17's "orphan" list (`V17 §4`) is itself point-in-time: X12, X18 and X19 have since landed and are cited here; X09/X03-adjacent gaps are not re-adjudicated by V26.

---

## 2. Conflict 1 — §04 §6 vs §10 blend math

### 2.1 Multiple passes

- Pass 1 — `spec/04 §3:46-49` calls engine blend math `[U]`; `spec/04 §6:69-90` already carries D05's `[O]` three-branch math. `spec/10 §2:43` repeats "engine math `[U]`"; `spec/10 §4:67-69` lists blend-mode math among unresolved `[U]`.
- Pass 2 — `D05 §F4` (`reports/D05_relief_stamp.md:132-171`) derived the branches from raw x87 opcodes (`0x7563e8`–`0x7566e9`); `D05 E15` found **zero** accesses to `HeightFieldMax` (`+0x60`).
- Pass 3 — `X12` independently accepted the same three branches at opcode level (`X12:17-22,118-136`), rejected D05's intermediate call chain (`X12:21,78-100`) and confirmed `Min` (`+0x5c`) is subtracted before and added after the scale multiply.
- Pass 4 — `X13` emitted donor test vectors and explicitly flags A02's "task replace formula" as incomplete (`X13:9,33,122-129`). Re-read of `A02:394-413` shows the placeholder `h_final = clamp(h_base*TerrainScale + grid*Scale + Offset, Min, Max)` and a "REPLACE target UNVERIFIED" line — both superseded.
- Pass 5 — `X03:368-369,500` and donor `generatemap.inc:4-7,567-574` confirm the class×R amplitude formula is a **separate** mask→height rule, still cited at `spec/03 §2` and `spec/10 §2` "Height classes".

### 2.2 Verdict

**BOTH-STAGE-SPECIFIC**, with one AUTHORITATIVE refutation:

- **Governs the fresh module's stamp stage:** D05/X12 (X13 vectors) — native `sub_755f30` three paths. `Min` is the **pivot** `(g−Min)*Scale+Min`; `Max` is **never read in the stamp**; `Offset` is additive; the smooth post-pass is ordered after the per-cell blend (`/4.0`, iterations = `SmoothFactor`).
- **Still cited, different stage:** A02/X03 DScript class×R amplitude (`generatemap.inc:4-7,21-32,454-485,567-574`) at `spec/03 §2` and `spec/10 §2` "Height classes". On shipped masks R=0 off starts, so it is inert there (conflict 3).
- **Refuted (strike):** A02's additive-clamp placeholder and any `[Min,Max]` clamp in the stamp. Row-sign flip, global setter clamp (`sub_0059b934`), rotation rounding and the `.pattern` float-plane byte boundary stay `[U]` (`D05 U1-U5`, `X12 U1-U5`, `V16-15`, `V16 O10`).

### 2.3 Paste-ready replacement text

**Replace `spec/04_PATTERN_STAMPING.md §3` bullet beginning "Blend flags:" with:**

> - Blend flags: `HeightFieldStand/Scale/Min/Max/Replace/ReplaceForWater/Smooth` occur in `pattern.lib` with no plaintext consumer in the donor text files; engine math is nevertheless **decoded [O]** from the native stamp `cossacks.exe:0x755f30` (D05 §F2–F6; independently accepted by X12 claims 3–5 and exercised by X13 vectors; `editor.exe` cross-checked). Counts: `Replace=False` 680/680, `ReplaceForWater=True` 85/680, `Smooth=True` 41/680. **Superseded:** the A02/port additive-clamp placeholder `h = clamp(h_base + grid*Scale, Min, Max)` (A02 §4 Stage 4b) must not be implemented; see §6 for the three authoritative paths. Read all flags from decoded data (`pattern.lib:549563-549575`); carry row-sign flip and the global setter clamp as `[U]`/`PORT APPROXIMATION`.

**Replace `spec/04_PATTERN_STAMPING.md §6` and its §7 cross-check queue with:**

> ## 6. Native stamp function and blend math (from D05 + X12) [O] — governs the fresh module's stamp stage
>
> `sub_755f30` (`cossacks.exe` VA `0x755f30`–`0x75c187`; DScript `StandPattern` signature at `0x6a3474` → `0x6b28d8` → `0x75c228` → `sub_755f30` @`0x75c240`; `0x6b2878`/`0x6b2b60` are sibling natives that call the stamp directly — X12 claim 2 rejects D05's intermediate hop). Config-field→offset map in `sub_75c314`: `Replace=+0x3a`, `ReplaceForWater=+0x3b`, `Scale=+0x48`, `Smooth=+0x4c`, `Min=+0x5c`, `Max=+0x60`, `Offset=+0x64`, `TerrainScale=+0x68`.
>
> Three blend paths, `[O]` from raw x87 opcodes at `0x7563e8`–`0x7566e9` (X13 vectors):
>
> | Path | Formula |
> |---|---|
> | `ReplaceForWater=true` | `new = g*Scale + HeightFieldOffset` (no base height, no current-height read) |
> | `Replace=true` | `new = base_h + (g−Min)*Scale + Min + HeightFieldOffset` |
> | default `Smooth` | `new = h1 + (base_h−h0)*TerrainScale + (g−Min)*Scale + Min + HeightFieldOffset` (two `getHeight` reads; collapsing to one is `PORT APPROXIMATION`) |
>
> **`Min` is the scale pivot, `HeightFieldMax` is never read in this function (zero `+0x60` operands in 6,751 instructions), `HeightFieldOffset` is additive. There is no `[Min,Max]` clamp in the stamp.** Negative `Scale` (e.g. `-0.925`) inverts the grid/pivot, not world height. The smooth post-pass is ordered after the blend: interior-only, 8-neighbour mask test, radial remap `(Radius−Offset)/d`, `Factor` repetitions of a 4-neighbour mean divided by hardcoded `4.0` (`cossacks.exe:0x755ee4`). `globalparams.cfg` has no `HeightField*` keys.
>
> Still `[U]`/`PORT APPROXIMATION`: file-row sign, global `setHeight` clamp (`sub_0059b934`, D05 U2/X12 U2), rotated sub-cell rounding, `.pattern` float-plane byte boundary, `HeightFieldMax` consumers outside this function. The DScript class×R amplitude formula (`generatemap.inc:4-7,567-574`) is a **different stage** (mask→height, spec §03 §2 / §10 §2) and does not govern stamping. No donor visual parity claim.
>
> ## 7. Cross-check queue (updated)
>
> F01 (exact `.pattern` byte layout); D05/X12/X13 ✓ (stamp math); F08; D07; X05 ✓; V01 ✓ (16-item resolution). Row-flip/global-clamp owners remain a COORD dispatch decision — do not cite a non-existent X12 for them.

**Replace `spec/10_STAGE_ORDER.md §2` row "Blend flags" with:**

> | Blend flags | **Native three-path stamp math [O]** — D05 §F4 / X12 claims 3–5: `ReplaceForWater` `g*Scale+Offset`; `Replace` `base_h+(g−Min)*Scale+Min+Offset`; default Smooth `h1+(base_h−h0)*TerrainScale+(g−Min)*Scale+Min+Offset` with two height reads. `Min` pivot; `HeightFieldMax` never read in the stamp; **no `[Min,Max]` clamp**. A02's `clamp(...)` placeholder is **SUPERSEDED**; row-flip and global setter clamp stay `[U]`. | guessed additive clamp (`PORT APPROXIMATION`, remove) |

**In `spec/10 §4`, replace the phrase "especially … blend-mode math" with:**

> … especially per-stage key derivation (resolved as identity re-seed by V01, engine RNG still `[U]`) and row-flip/global-setter clamp (still `[U]`); **blend-mode math is resolved for the stamp by D05/X12/X13 — see `spec/04 §6`, do not re-open it as `[U]`**. V01 resolved 10 of A02's 16 `[U]` items (3 partial, 3 open); fold that table here before dispatch.

### 2.4 Affected tickets

**I02** (`.pattern` decoder — emit flag offsets/values, no clamp), **I07** (stage 4b stamp calls; two-read Smooth branch), **I12/I13** (determinism vectors from X13). No parity claim.

---

## 3. Conflict 2 — food-rect claim and reversed `mapsize>2` gating

### 3.1 Multiple passes

- Pass 1 — `spec/10 §2:50` "Starting resources … replaces port food rects" and `:53` "Fields: field decals `envfieldd`, food rects (GUIDE4:2029, TERRAIN_GEN_RESEARCH:75, D1:720-980)"; `spec/07 §1:18-19` calls `gRecordGeneratorVersion>=80, mapsize>2` the "current band".
- Pass 2 — `V12 C-V4` (`:82`) rules "D07 wins: zero food rects; A02/spec §10 assertion becomes red gate G9"; `V12 §3.4` (`:184-208`) lists six stone/forest attempts and explicitly "No `field`/`food` call exists in `:720-977`".
- Pass 3 — `X22 X-C6` (`:53`) re-scanned donor `dogenerate.inc:720-980` for `field|food|SeedWheat|gc_basename_field` → **zero hits**; `F07 §0` (`:21-22`) decoded `_unit_DoSeedWheat` at `unit.script:6468-6570` (7×7=49 nodes, step `1.6981` cells, 45°, 5 gold).
- Pass 4 — `V01 P4/EV08` (`:51,116,222-289`) read `donewgame.inc:42-46` (`0→320, 1→480, 2→640, 3→256`) and reversed A02's labels; `V12 C-V3` had left the "tiny" label `[U]` pending X09 — V01's enum reading supplies it. `V12 C-V7` corrects "ring 4/5 skipped" to `continue` (name draw consumed, no angle draw).

### 3.2 Verdict

**AUTHORITATIVE** — one statement governs both rows and both sections. V12/V01/F07/X22/D07 supersede A02/GUIDE4 on food rects and on the map-size label. `V17 X3`'s "V12 §5.1 still calls it 'large-map row'" is likewise superseded by V01's enum. All donor `.inc` caller activation remains `[U]` (`F07 §4` trigger chain is `;`-prefixed text); every port field implementation is `PORT APPROXIMATION` until a real A/B frame exists.

### 3.3 Paste-ready replacement text

**Single authoritative statement — insert/replace in `spec/07_RESOURCES.md §1` and reuse verbatim in `spec/10 §2`:**

> **[O] One correct statement (D07/V12/V01/F07/X22):** `SetupStartingResources` (`dogenerate.inc:720-977`) places **six attempted stone/forest items only — zero food rects**; fields are created later by the mill's unit script `_unit_DoSeedWheat` (`unit.script:6470-6570`: 7×7=49 nodes, `size=1.6981` map cells, 45° rotated lattice, `size2=√(2·size²)` snap, 5 gold per field), with `envfieldd`/`envfielddw` 2×2 decals bound to field objects at load/save (`writenewp.inc:23-29`, `readnewp.inc:41-47`, `misc.script:4286-4306`). A02 Stage 9 / GUIDE4's "guaranteed food rects inside `SetupStartingResources` (D1:720-980)" is **refuted** (V12 C-V4 = red gate G9; X22 X-C6; V01 §5 item 4). Runtime activation of the `;`-prefixed callers is `[U]`; any port field stage is `PORT APPROXIMATION`, not parity.
>
> **[O] The version/size gate is:** `gRecordGeneratorVersion := gDataVersion = 92` (`serial.script:27`, `initmapgen.inc:57`), so the `v>=80` branch is live. The literal `gRecordGeneratorVersion>=80 AND mapsize>2` selects only the **256-cell TINY map** — `donewgame.inc:42-46` maps `0→320, 1→480, 2→640, 3→256` (V01 P4/EV08); A02's "small/large" labels are reversed and V12 C-V3's `[U]` enum label is superseded. Default 320/480/640 maps therefore use the `mapsize<=2` rows (`dogenerate.inc:608-654`): for `spcount<=4, v>=80` the case labels are `0,1,3,4,5` with **no `case i of 2`** (ring 2 keeps a zero-initialised `dst` — reproduce structurally with a trace flag, `[I]/PORT APPROXIMATION`); "ring 4/5 skipped" means `continue` inside the `k` loop, where the name-pick draw at `:557` is still consumed 256× per ore and no angle draw occurs (V12 C-V7). Do not invent the missing band or rename the gate from the `// tiny` comment.

**Replace `spec/10 §2` row "Starting resources" with:**

> | Starting resources | `SetupStartingResources` (`dogenerate.inc:720-977`): six attempted stone/forest placements + three keep-clear ellipses; **no `food`/`field` rects** (V12 C-V4, X22 X-C6, D07 §3.6) | port food rects (REFUTED) |

**Replace `spec/10 §2` row "Fields" with:**

> | Fields | **Script-sown**, not a generation pattern stage: `_unit_DoSeedWheat` 49-node 45° lattice (`unit.script:6470-6570`); `envfieldd`/`envfielddw` decal per field object (`writenewp.inc:23-29`, `misc.script:4286-4306`); no pattern/lib field family (`F07 E15`); caller activation `[U]` | missing / invented food rects |

**Replace `spec/07 §6` cross-check queue with:**

> V12 ✓ (definitive resource spec + anomaly policy), V01 ✓ (`mapsize>2 = 256` tiny; `gDataVersion=92`), F07 ✓ (fields are script-sown), X22 ✓ (verbatim sow translation), F08 ✓, D04 (saved `.map` records). No X09 claim may be used to re-label `mapsize>2`.

### 3.4 Affected tickets

**I07** (stage pipeline: no food-rect stage; literal gate + ring-2 reproduction), **I09** (mill-field props as runtime seeding, not terrain tile ids), **I13** (V12 gate G9 "no food rects" as red assertion). No parity claim.

---

## 4. Conflict 3 — §03 mask R/G semantics

### 4.1 Multiple passes

- Pass 1 — `spec/03 §1:21-26` already demotes R/G class semantics to `[U]`, but `spec/01 §3:41-53`, `spec/04 §3:50-51` and `spec/10 §2:41` still treat R=class/G=forest/B=water/R×3.5 as live donor-confirmed semantics.
- Pass 2 — `F04 §5–§6` (`:189-252`) measured R/G ∈ {0,255} with 5,125 start pixels only; `h=−1.1·B/255`; water `B≥58`; all 56 port PNGs pixel-identical.
- Pass 3 — `D03 §3.2/E18` full-corpus census (`Rnz=Gnz=white`) and `X19 C-A/C-G` (`:170-261`) resolved the contradiction as **intent vs shipped pixels**, not an open conflict; `X18` independently reproduced the census (`X18:28-52,301-303`).
- Pass 4 — raw donor re-read in this ticket: `generatemap.inc:21-32` (codes), `:413-490` (class/forest enum from R/G), `:537-547` (second-pass sampler assigns `.r` and `.b`; **`.g := fg` is commented out at `:545`**), `:563-574` (`hwater=−1.1*fb*(1+fr*3.5)`; class×fr amplitudes; multiplier suffixes disabled).

### 4.2 Verdict

**AUTHORITATIVE** for the shipped-skirmish statement (F04/D03/X18/X19 pixel facts + donor formula), with an explicit `[U]` residue. A02's `generatemap.inc:454-485` citation is **valid as authored schema intent `[O]`**, not as shipped-pixel behaviour; `V16-22/O5` and `V17 X5` are resolved as a layer distinction, not a donor contradiction. No R→height mapping may be added for shipped masks, and I07 must **not** "fix" the port's already-correct `relief()` sign (`X19 C-F`).

### 4.3 Paste-ready replacement text

**Replace `spec/03_MASK_TO_HEIGHT.md §1` paragraph beginning "This refutes the port's assumption…" (`:21-26`) with:**

> **Authoritative skirmish statement [O]:** across all 1,331 shipped vanilla `_gauss` masks (independently re-verified by X18 and X19), R and G are **0 on every non-start pixel**; the only 255 values are 5,125 single-pixel white starts (R=G=B=255). B is the only continuous channel and `h = −1.1·B/255` (B=0→0 m, B=255→−1.1 m; water `h<−0.25` ⇔ integer **B≥58**, shore `h<−0.1` ⇔ B≥24; `generatemap.inc:4-7,567-574`, `texturemap.inc:29-31`). Mask pixels alone cannot yield ±2.964 m — relief amplitude comes from pattern stamps (spec §04, D05), not mask R; forest/stone comes from placement (spec §07/§08), not mask G.
>
> The R→class / G→forest-stone code table at `generatemap.inc:21-32,454-485` is **authored donor intent `[O]` text**, inert on all shipped final masks (the second-pass sampler even leaves `.g` unassigned at `generatemap.inc:545`). Keep the R/G enum decode as schema intent, preserve raw R unchanged with an `ENGINE/UNVERIFIED` label, and **never map R→height for shipped masks**. What stays `[U]`: runtime execution of the `[*] = ;` DScript text; R/G semantics on `.src`, custom/modded or editor-authoring masks; any forest/stone **density** derivation from G; native `SmoothTerrain`/`_misc_SmoothTerrainCustom` kernels; stamp-vs-smoothing stage order; `fa`/`broad` for a 24-bit TGA. No donor visual parity claim.

**Replace `spec/03 §2` heading with `[O] donor-intent, INERT on shipped masks` and prepend:**

> The class×R formula below is donor-intent text (`generatemap.inc:4-7,567-574`, X03 D2:4/570), **not a live shipped-mask rule** — on all vanilla `_gauss` masks R=0 off starts, so `hterrain=0` and §1's `h=−1.1·B/255` is the observed fact. Do not flip the port's `relief()` sign or add a per-code amplitude bump: X19 C-F shows `mapgen.gd:63-85` already matches the donor codes. Genuine I07 work is the B≥58 off-by-one, the coastal gate, the missing land/bsmooth passes and the manifest contract (X19 G1/G3/G13–G16).

**Replace `spec/01 §3` "Donor-confirmed sources: mask R=terrain class, G=forest, B=water weight, A=road (`generatemap.inc:413-480`, A01 E6); …" with:**

> Donor-confirmed **schema intent** (`generatemap.inc:413-490`, A01 E6): R=terrain class, G=forest/stone, B=water weight, `fa`→road — `[O]` text only. On shipped `_gauss` masks R/G are start-only (F04/X18/X19), so the `terrain_class`/`forest_density`/`mask_r`/`mask_g` side arrays are inert on those inputs (`PORT APPROXIMATION` until a mask carrying those codes is cited). Water `-0.25`/shore `-0.1` (`texturemap.inc:29-31`, E12) and "relief props are 3D objects, not height bumps" (`pattern.lib:338482` etc., E15) stand unchanged.

**In `spec/10 §2`, append to the "Height classes" row:**

> Class×R amplitudes are donor-intent text (`generatemap.inc:4-7,567-574`), **inert on shipped masks** (spec §03 §1/§2); the actual ±2.964 m relief comes from §04/D05 stamps.

### 4.4 Affected tickets

**I04** (mask decoder: raw R preserved, B≥58 excluding starts, V1–V7 validation vectors), **I07** (no R→height invention; correct coastal gate and passes), **I06** (side-array labels), **I13** (QA guard "non-start R/G sums zero"). No parity claim.

---

## 5. Conflict 4 — §12 vs §13/§14 stale git/seam status

### 5.1 Multiple passes

- Pass 1 — `spec/12 §12.1:22-24` says "HEAD `e234ac9b`, source files clean … (V04 report pending)"; `§12.4:70-88` says V04 supersedes the stale premise but still ends "V11 is assigning one owner per file"; `spec/13 §4:37-38` says "**3 uncommitted changes** … V04 worker is auditing"; `spec/14 §5:35-36` says "V05 is reconciling … see report when landed".
- Pass 2 — `V04 §0 P1–P6/§1` and `V05 §0` and `V11 §0 P1–P7` independently found HEAD `e234ac9b`, clean `variant3d/`/`app/`, seam unapplied; `P06 §5.1:194-204` and `A06 E12/E13:69-70,255-258` describe the older `0e9783f2` + three dirty source files — stale. `V16-10/18/23` adjudicated the same.
- Pass 3 (live, read-only) — `git rev-parse --short HEAD` → `e234ac9b`; `git log -3` unchanged; `git status --porcelain=v1` now lists `M variant3d/scripts/main.gd`, `M variant3d/scripts/world3d.gd`, `?? inbox/backup/{main,world3d}.gd.bak-COORD-I11`, and untracked donor scripts/tools/tests; `app/**` still clean.
- Pass 4 (live) — symbol/line re-read: `main.gd:125,189-191,593-594,1112-1113` carries the backend var, config read and both setter calls; `world3d.gd:118,144-145,220-224,624,706-707` carries the donor const, backend vars, setter, ternary and stats; `git diff --stat` = +9/+15 lines. `Get-FileHash` of `.bak-COORD-I11` = `3859B605…`/`44EE96C0…`, exactly V04/V11's pre-seam baselines; `git rev-parse HEAD:<path>` = `30262b23…`/`638f33e6…`. `Test-Path variant3d/scripts/terrain_donor_world.gd` → **False** (I11-COMPOSER file absent); `terrain_donor_data.gd`, `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, `terrain_donor.gdshader`, `t_terrain_donor.gd` and several decoders now exist untracked. Files were being written during this read (generator script appeared between passes) — this is a live, concurrent working tree.

### 5.2 Verdict

**AUTHORITATIVE** for the adjudication that P06/A06's "three uncommitted edits" are stale (V04/V05/V11/V16: Y08b/Y10/Y11 are committed in `e234ac9b`). **UNVERIFIED** for any permanent assertion that the port files are clean or the seam is unapplied: that was true at V04/V11/V16 read time but is **not** true at the V26 read. The single current statement is point-in-time and must be re-verified by COORD before dispatch. V26 did not apply, revert or otherwise mutate the seam.

### 5.3 Paste-ready replacement text

**Replace `spec/12 §12.1` final paragraph (`:22-24`) with:**

> Multi-pass status note (point-in-time, V26 re-read): V04/V05/V11/V16 audited HEAD `e234ac9b` with `variant3d/`/`app/` clean and the seam unapplied; **A06's E12/E13 and P01/A06-era "three uncommitted Y08b/Y10/Y11 source edits" are stale** — those edits are committed in `e234ac9b` (V04 §1, V05 §0, V16-10). At the **V26 read HEAD is still `e234ac9b`**, but `variant3d/scripts/main.gd` and `world3d.gd` now carry **uncommitted** I11-SEAM inserts with exact pre-seam `inbox/backup/{main,world3d}.gd.bak-COORD-I11` baselines (`main.gd:125,189-191,593-594,1112-1113`; `world3d.gd:118,144-145,220-224,624,706-707`), plus untracked donor scripts/tools/tests; `app/**` remains clean. `terrain_donor_world.gd` (I11-COMPOSER) does **not** exist yet, so the donor const points at a missing script until the composer lands. **Do not assert "port files clean / seam unapplied" as a permanent spec fact**; COORD must re-run `git status`, hashes and the seam anchors immediately before any dispatch. No gate result and no donor parity claim is implied.

**Replace `spec/12 §12.4` paragraph ending "V11 is assigning one owner per file" (`:83-84`) with:**

> Highest double-apply risk: the seam, now **applied once in the working tree at V26 read** (`main.gd` 4 inserts; `world3d.gd` const/vars/setter/ternary `:624`/stats) by the single COORD owner **I11-SEAM** with reserved suffix `COORD-I11` (V11 §2 E1/E2). Do **not** re-apply it; verify the two working-tree hashes against `.bak-COORD-I11` (`3859B605…`/`44EE96C0…`) and the HEAD blobs (`30262b23…`/`638f33e6…`) first. The Y08b/Y10/Y11 diffs are committed baselines and must never be re-applied either. `main.gd`+`world3d.gd` are the only seam files; default `"legacy"`. File-scoped `Copy-Item inbox/backup/<file>.bak-COORD-I11 <file>` with SHA checks; `git reset --hard`, `git checkout .` and `git clean` remain forbidden.

**Replace `spec/13_PRIOR_WAVE_MEMORY.md §4` two bullets (`:35-38`) with:**

> - P06 registers **28 open items (V-01…V-28)**; resolution status is point-in-time (V03 may close some) — re-check before claiming any closed.
> - **Stale git premise [O→D]:** P06 §5.1 (`:194-204`) and A06 E12/E13 listed three *uncommitted* source edits (Y08b `game.gd`, Y10 shader, Y11 `project.godot`) at `0e9783f2`. V04/V05/V11/V16 verified they are **committed in `e234ac9b`**; do not re-apply them. At the V26 read HEAD is still `e234ac9b` but new uncommitted I11-SEAM edits and untracked donor files are present — re-read live status before any edit (V11 §6 rule 4). Committed Z08/C01/Y08 machinery is the baseline to build on, not a patch set.

**Replace `spec/14_CURRENT_PIPELINE.md §5` (`:31-36`) with:**

> ## 5. Seam — P01 placement + V05 control flow, now reconciled and applied [D]/[O]
>
> Compose a fresh `terrain_donor_*.gd` behind the COORD-owned `terrain_backend` switch (`world3d.gd` ternary at current `:624`, gate/bind unchanged; `main.gd` config read and both `make_world3d()` sites) using the `world3d_relief.gd` sibling pattern; **no edits to the six legacy pipeline files**. V05 **has landed** and `spec/12 §12.1` is authoritative — remove the "when landed" qualifier and the "V05 is reconciling" sentence. At V26 read the seam inserts and `.bak-COORD-I11` backups are present in the working tree while the composer `terrain_donor_world.gd` is still absent; default remains `"legacy"` and no A/B or parity verdict exists.

### 5.4 Affected tickets

**I11** (sole seam owner + missing I11-COMPOSER), **I12** (manifest append LAST — no `t_terrain_donor` entry observed at V26 read), **I13** (fresh gate baseline before any PASS claim), **I06/I07/I08/I09** (untracked donor modules under active creation). No parity claim.

---

## 6. Affected-ticket summary

| Ticket | Conflicts touching it | Concrete consequence of the resolutions |
|---|---|---|
| I01 | — (unaffected by these four) | Keep `constants.json` emission per §09 |
| **I02** | C1 | Decode `.pattern` flags/offsets verbatim; no `[Min,Max]` clamp; row-flip `[U]` |
| **I03** | C1 | Emit `pattern.lib` 37 fields + flags; swamp-header policy unchanged (V16 O1) |
| **I04** | C3 | Raw R preserved with `ENGINE/UNVERIFIED`; `h=−1.1·B/255`; B≥58 excluding starts; V1–V7 vectors |
| **I05** | — | Atlas work unchanged by these four |
| **I06** | C3 | Side arrays `terrain_class`/`forest_density` labelled inert on shipped masks |
| **I07** | C1, C2, C3, C4 | Three-branch stamp; no food rects; literal `mapsize` gate + ring-2 reproduction; no R→height invention; re-verify live seam before composition |
| **I08** | — | Mesh unchanged by these four |
| **I09** | C2 | Mill fields as separate 49-node runtime seeding, not tile ids |
| **I10** | — | Shader unchanged by these four |
| **I11** | C4 | Two-file seam authoritative; verify current applied state; composer still missing |
| **I12** | C4 | Manifest append LAST; current manifest has no `t_terrain_donor` entry |
| **I13** | C1, C2, C3, C4 | X13 stamp vectors, G9 no-food-rect red gate, non-start R/G=0 guard, fresh gate baseline |

## 7. Risks

1. **[D] Stale-snapshot risk is now the top operational risk.** V04/V11/V16 were correct at their read; V26 shows the seam applied and donor files appearing during the read. Any COORD integration that pastes "tree clean" text without re-running status will be wrong again on the next write. Mitigation: every git sentence in spec carries "point-in-time (V26 read)" and a re-verify instruction.
2. **[D] Silent resolution of preserved contradictions** would still be damaging: promoting A02's clamp, adopting `TileSmoothPasses=6`, per-ore mine radii, or R-derived relief. The replacement text explicitly labels each as superseded/refuted.
3. **[D] Stamp-vs-class-stage conflation** could implement both formulas in one place; §2 text separates them by stage and keeps the DScript formula inert on shipped pixels.
4. **[U] Epistemic ceiling.** Every donor `.inc` line is `[*] = ;`; X12/X13 prove static opcode behaviour, not runtime activation or visual fidelity. No donor GPU A/B frame exists; none of these verdicts is a parity claim.
5. **[O] Composer gap.** The live seam's `TERRAIN_DONOR_SCRIPT` points at a file that does not exist; loading backend `"donor"` before I11-COMPOSER lands would fail. Keep default `"legacy"`.
6. **[D] Point-in-time report set.** X12/X18/X19 (and X13) landed after V17; V17's orphan list is stale. More reports/files may land after this read — re-check before dispatch.

## 8. Open questions

1. **COORD:** confirm the V26 live seam state is an authorised I11-SEAM application (comments name it) and assign the missing `terrain_donor_world.gd` composer before any `"donor"` default flip.
2. **COORD:** decide whether to mark §09 READY and fold V01's 10/3/3 resolution table into `spec/10 §4` in the same integration pass (V17 C6).
3. **D05/D03 + COORD:** assign owners for row-sign flip, global setter clamp and rotation rounding so `spec/04 §7` no longer points at a phantom ticket (V17 Q6).
4. **COORD + I04/I13:** adopt X19's V1–V7 validation vectors, including the exact B=58 `0.000214` manifest delta, as hard assertions.
5. **D09/X02:** can R1–R6 numeric relief parameters or `SmoothTerrain` native kernels ever be recovered? Until yes they stay `[U]`; no invented kernel.
6. **COORD:** V12's `mapsize` enum `[U]` is closed by V01's `donewgame.inc:46` reading — confirm no X09 data overrides it before freezing `spec/07`.
7. **Owner:** can a donor GPU A/B frame ever be produced? Until yes, every verdict here remains a value/line/count adjudication, never a parity claim.

## 9. Five-line summary

1. **[D] C1 BOTH-STAGE-SPECIFIC:** D05/X12 with X13 vectors govern the native stamp (Min pivot, Max never read, three branches); A02/X03 class×R amplitude stays cited only for mask→height; the A02 clamp placeholder is struck.
2. **[O] C2 AUTHORITATIVE:** no food rects in `SetupStartingResources`; fields are 49-node script-sown; `mapsize>2` is the 256 tiny map, default maps use `mapsize<=2`; `continue` consumes name draws.
3. **[O] C3 AUTHORITATIVE with `[U]` residue:** vanilla R/G are start-only, `h=−1.1·B/255`; `generatemap.inc:454-485` is intent text; runtime, density-from-G and native kernels stay UNVERIFIED.
4. **[O]/[U] C4 split:** V04/V05/V11 correctly refute P06/A06's stale uncommitted-edit premise, but at V26 read HEAD `e234ac9b` still has uncommitted I11-SEAM inserts and a missing composer — no permanent "clean/unapplied" claim.
5. **[U] No donor visual parity claim:** all verdicts are donor path:line / opcode / working-tree adjudications; every port consequence is `PORT APPROXIMATION` until a real donor A/B frame exists.

*End of V26 report. Exactly one repo file written; no spec, source, shader, config, asset, test, JSON, git, queue or `app/` change; no donor binary executed; no donor visual parity claimed.*
