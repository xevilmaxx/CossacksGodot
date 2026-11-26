---
id: V57
ticket: "TERRAIN-SWARM-2026-11-26 / V57 — FINAL PARITY STATEMENT (paste-ready for HANDOFF / owner answer)"
agent: "V57 (read-only final-parity-statement subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V57_final_parity_statement.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V57_final_parity_statement.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists, no donor binary was executed and no gate result is asserted here. Nothing in this report certifies donor fidelity or a gate PASS."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
sources_read: "CHARTER.md, SWARM_BOARD.md (V45 refresh), HANDOFF.md (V46 refresh), spec/12_QA_AND_INTEGRATION.md, reports/V15_acceptance_without_reference.md, reports/X07_visual_reference_index.md, reports/X27_decode_coverage.md, reports/V36_integration_checklist.md, reports/V52_owner_qa.md, reports/X34_size_law_verification.md; board/reports directory enumerated twice."
multiple_passes: true
multiple_pass_note: "Every candidate overstatement in §3 was re-read with a second landed document or a second filesystem instrument; both readings are recorded and the weaker (honest) wording is kept. Point-in-time at the V57 read: X39_ab_feasibility.md and an X36 report were absent — glob 'X3[0-9]*.md' returned only X30 and X34, and explicit Test-Path on 'reports/X39_ab_feasibility.md' and 'reports/X36_parity.md' returned False. Both have since landed (V67 glob: X39_ab_feasibility.md and X36_mountain_visual_recheck.md); re-read before citing or disclaiming. V36_integration_checklist.md is a landed integration audit, not a visual/A-B feasibility source. The same-camera donor-capture requirement is unchanged and rests on V15 §2/§6/§8-Q8, X07 §8/Q2, V52 §7.3 and spec/12 §12.6; X39 §3 now supplies the owner procedure. No parity status or tier changes."
---

# V57 — FINAL PARITY STATEMENT (paste-ready, landed evidence only)

## 0. Executive summary

1. **[O] Donor-grounded *structure* is verified at the byte level for the terrain-relevant data set.** The eight load-bearing decodes in §1 are byte-exact and independently cross-read; the `.pattern` size law in particular now has a second, independent 710/710 verification (`reports/X34_size_law_verification.md` §4.1–§4.3, E1–E20) in addition to `X27 §2 E9`. This is **decode integrity**, not an owner-facing tier-1 verdict: V15 §2 requires a donor datum matching a **port-side** byte/count/id/hash **and** dump integrity D3, and neither is established today (`HANDOFF §0/§4`, `V52 §0`).
2. **[O] The self-consistent visual tier has criteria but no observation.** V15 §4 and `HANDOFF §3` draft per-class properties (silhouette ON/OFF, continuous shore band, mine mesh on its disc), but no admissible 1280×720 windowed capture, no frozen 240²/320² baseline and no `inbox/qa/captures/**` exist — only PENDING markers (`HANDOFF §2.1/§2.2`, `SWARM_BOARD` §Integration gates, `V36 §1.6`). Tier 2 would need a capture; none exists today.
3. **[U] The UNVERIFIED register is large and categorical** (§2.3): five no-reference visual classes (`X07 §4/§7`, `V15 §4`), packed stubs and whole untouched artifacts (`X27 §3.1/§4`), runtime activity of all 972 `;`-prefixed `.inc` excerpts (`X27 §3.2`), row-sign flip, blend pass count (unresolved after six passes) and true x87 precision. None is promoted by this report.
4. **[D] The honest one-sentence answer is in §4: terrain is not cloned.** A byte-faithful *specification* and a dormant, scaffolded port exist; no rendered comparison, no gate result and no runtime observation exist.
5. **[I] The only upgrade path is owner-supplied**: a same-camera, same-seed, same-size donor GPU frame, fresh green gates, and resolution of the spec `[U]` items (§5). Until then `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, and the conservative owner reading is `RESULT IS NOT GOOD` because `blocking_unverified` is non-empty (`V15 §2`, `V21 §10 Q7`, `HANDOFF §0`, `V52 Q2`).

**Mandatory reviewer wording (verbatim, V15 §2 / X07 §8 / V52 frontmatter):**

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

---

## 1. Evidence table — DONOR-GROUNDED STRUCTURE VERIFIED (decode integrity only)

**Reading rule.** Every row is **verified against donor bytes/instructions**, not against a rendered frame. Labels follow CHARTER §1/§4: `[O]` literal observation, `[D]` derived consequence, `[I]` interpretation, `[U]` unverified, `PORT APPROXIMATION` = port substitute. Donor paths are under `C:\Games\Cossacks 3\` (read-only, private use); report/spec paths are repo-root relative. Counts are mechanical counts of evidence/vector rows or byte records, **not QA gates and not fidelity measures** (`HANDOFF §1`).

| # | Byte-exact donor datum (claimed by task) | Landed evidence (path / evidence id) | Verified count / integrity | What it establishes | What it does **not** establish |
|---|---|---|---|---|---|
| 1 | `.pattern` format + size law | `reports/F01_pattern_format.md` §4.1/E4 via `X27 §2 E9`; **independent re-verification** `reports/X34_size_law_verification.md` §4.1–§4.3, E1–E20 | `S = 8+4wh+54(w−1)(h−1)` holds **710/710**, 0 residual bytes; 7 contiguous regions tile `[0,S)` **710/710**; 550,908 `Rec24`; **678/680** min/max bit-exact; corrected `G=8+(w−1)(h−1)` **13/13** bit-exact (X34 P1/P2/P3) | Byte-exact container/grid layout; I02 read-only self-test `PASS 29 / FAIL 0` and 710/710 on six independent output checks (X34 §6.1/§6.2) | `Rec24.id`, PRE/`tail4`, weight block and `Tail13` semantics, mask occupancy meaning, row flip, engine blend order, full grids for ~50+ active ids (`X27 §3.3`, `X34 §7`, spec/00 U14) |
| 2 | `pattern.lib` plaintext index | `reports/F02_pattern_lib.md` §0/X05 via `X27 §2 E10`; `V15 §1 V-E06/V-E07` | 30,309,138 B, **680** sections, 1,172,417 split lines, 205,571 struct pairs, **39,780** object records, 235 `BaseName`, 37-key prologue; 12 grid cross-checks bit-exact; 680 name→file (679 exact + 1 case); independently re-read 680 sections in `X34 §2 E18` | Container decode + name→file index | Engine consumption of fields; `m_swamp_12_old` 17×20 vs binary 18×23 (PRESERVED/quarantine); 217 sections in no family (`X27 §3.3`) |
| 3 | Terrainmask TGA corpus | `reports/F04_masks.md` §0/§5 + `reports/D03_mask_pipeline.md` via `X27 §2 E11` | **4,466** TGAs full-decoded = 1,331 vanilla + 1,856 dlc5 + 1,279 src; B spans all 256 values; `h = −1.1·B/255`; water at `B≥58` (`X27 §6 C7`); port covers only 56/1,331 (4.2%) and 0/1,856 | Full-corpus pixel decode + height formula | Native `SmoothTerrain`/`_misc_SmoothTerrainCustom` kernels, `fa`/road `broad` (unrecoverable from 24-bit), per-pixel dlc5 diff; runtime execution |
| 4 | Gen `.cfg` constants | `reports/F03_gen_config.md` §2 via `X27 §2 E7`; `V15 §1 V-E08/V-E09` | **7** files fully hashed/parsed: 20 global + 13 local keys; 8 tile sections/30 names; 22 chains/118 active groups/282 active entries/86 names/Σ174.0168; 64 families/493 `Pattern=Freq` pairs; 19 presets/61 masks/276 legend entries | Literal closure of all cfg files | Key semantics/`Freq` consumer; no seed, water-level or mine-count constant in cfg; `TileSmoothPasses=6` vs script `3` and `tilesmooth.cfg` vs `tilesmooth_scripts.cfg` preserved (`X27 §6 C5`) |
| 5 | RNG LCG | `reports/D02_seed_rng.md` §4.2 via `X27 §2 E5`; `reports/X21_rng_vectors.md`; `X03`/`V01` reseed list | Exact `s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, output `f32(s/2^32)` at `0x60f64c`–`0x60f696`; identical bytes in editor/config/modman; **11 `SetRandomKey` + 3 `SetRandomExtKey64`** reseed sites; A02 `mix64` derivation refuted (C8) | Recurrence + reseed boundaries | Key→state internals, `GenerateMapRandKey` body, saved-map key bytes, RNG instance identities, discarded-draw counts (`X27 §5 #5`) |
| 6 | Relief stamp blend opcodes | `reports/D05_relief_stamp.md` + `reports/X12_stamp_verification.md` (opcode level); `reports/X13_blend_test_vectors.md` | `sub_755f30` 25,175 B / 6,751 instructions / 5 callers; **three blend paths**; `Min` is the scale pivot; `HeightFieldMax` never read; `Offset` additive; divisor hardcoded `4.0f`; **19 blend vectors + 4 smooth snapshots** with exact float32 bits, 3 real donor grids bit-exact (`HANDOFF §1`) | Opcode-level three-path stamp formula | Row-sign flip, rotation rounding, global setter clamp, true x87 precision; Replace/Smooth vectors use **synthetic** flag overrides (`PORT APPROXIMATION`) |
| 7 | `bmTransparency` blend function | `reports/F06_alpha_masks.md` + `reports/D08_tile_select_bin.md` + `reports/X17_blendfunc_verification.md` via `X27 §2 E14` | `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)` at VA `0x4ef991`/`0x88fbb0` (table `0x8fb1c4`/`0x8fb1c8`; IAT `0x907d90` per `HANDOFF §1`); alpha.bmp 512×256 8bpp, alphavert.bmp 1024×512 24bpp, 124 tile ids/season | Blend **mechanism** and crossfade equation at instruction level | Composite **pass count `[U]` after six X17 passes**; `tiaAlphaFromIntensity`, tile→patch selector, `glBlendEquation` tail, atlas packing equivalence (`X27 §5 #3`) |
| 8 | `.map` 37-byte records | `reports/D04_map_format.md` §4/§7 via `X27 §2 E12` | `W×H×37` record invariants **102,400/102,400** and **147,456/147,456**; `(2W)²` tag grid; `(W+1)²−2` f32 heights; serializer `sub_739d3c`, loader `sub_73a0b8` | Byte layout + record invariants | Height-count shortfall vs writer loop `[U]` after 6 passes; tag-grid enum, byte-12 variation, `FFFF` marker, per-cell collision flags, owner/visibility/resource pointer, 41-byte gap, `−1.1` sentinel all `[U]` |

**Evidence-volume note (for the owner's "how much" question).** Beyond the eight rows, `X27 §2` carries **20** numbered evidence rows (E1–E20) and `X27 §6` **10** multi-pass contradictions (C1–C10); `V15 §1` carries **20** rows (V-E01–V-E20) and `V15 §5` **5** class ledgers (M1–M5, S1–S5, R1–R4, W1–W5, I1–I5) plus a two-pass false-positive finding; `X34 §2` carries **20** rows (E1–E20) and 3 independent passes on the grid offset; `V36 §2` carries **20** rows (EV01–EV20) and 11 multi-pass entries; `X07 §2` indexes **12** stills and `X07 §7` lists **11** UNVERIFIED items (U1–U11). Per-report evidence-row counts are quoted mechanically in `HANDOFF §1` (e.g. X17 ~47, D06 ~37, X22 ~38, A04 28, D08 ~23, X21 ~23, F07 22, F09 21, V20 20, D07 ~20, D05 15, X08 14, X13 12, X11 ~11). These are citation volumes, never gate passes.

---

## 2. Three-tier statement (V15 §2 vocabulary; no tier above 2 exists)

### 2.1 Tier 1 — DONOR-GROUNDED STRUCTURE VERIFIED — **donor decode side only; port verdict unsigned**

- **[O] Verified:** the eight byte-exact decodes in §1, with the counts shown. X34's independent pass makes the `.pattern` closure the strongest single datum: 710/710 size law, 710/710 seven-region tiling, 13/13 bit-exact corrected grid offset, I02 `PASS 29 / FAIL 0` (read-only dry-run) and 710/710 on six output checks.
- **[U] Not verified (and therefore not signed):** V15 §2's tier-1 *owner verdict* requires a cited donor datum matching a **port-side** byte/count/id/hash **and** dump integrity D3. D3 has not been run, no fresh determinism dump exists and all gate verdicts in `HANDOFF §4` are `TODO(COORD)` placeholders (`V21 §1`, `V52 Q2`). No class in `HANDOFF §3` is upgraded.
- **Exact sentence for the owner:** "Donor-side structure is byte-exactly decoded and cross-checked; the tier-1 port verdict is **prepared but unsigned** because no port-side byte match and no D3 dump integrity have been established."

### 2.2 Tier 2 — SELF-CONSISTENT VISUAL — **PORT APPROXIMATION; criteria drafted, result unobserved**

- **[D]/[I] Criteria exist** (V15 §4, `HANDOFF §3`): silhouette ≥ centre +4 m / footprint +2 m with props ON/OFF ≥200 changed px, ≥8 px rise and <1% outside change and `matched_stamps>0` (mountains); pale water body with foam **slightly offshore**, not a white rim (sea); continuous warm beach → bright foam → pale water with shore ids 93/97/98 (shore); organic soft wet patch with **no water plane** (swamps); deposit mesh on a centred disc, built mine centred, no orphan/concentric rings (iron/coal).
- **[U] None observed.** No admissible windowed non-blank 1280×720 capture, no pinned camera/seed/size, no frozen 240²/320² baseline, no `inbox/qa/terrain_qa_report.json` and no `inbox/qa/captures/` (`HANDOFF §2.1/§2.2`, `V36 §1.6`, `SWARM_BOARD` §gates). The 12 stills in `C:\Users\Maxym.Oboyshev\Downloads\c3\` are third-party images of unknown build/camera/zoom/world area/compression; they support only **direction of movement** on matched fractional ground ROIs (`X07 §0/§6 U1`, spec §12.6).
- **Exact sentence for the owner:** "A self-consistent visual verdict would require an admissible capture; none exists today, so every visual statement remains `PORT APPROXIMATION` and no metric, ROI or still may be promoted to a pass verdict."

### 2.3 Tier 3 — UNVERIFIED register (explicit; nothing silently promoted)

| # | UNVERIFIED class / item | Landed basis (evidence id / path:line / report §) | What would settle it |
|---|---|---|---|
| U1 | **Mountains** — donor visual silhouette | no still in corpus; `reports/X07_visual_reference_index.md` §4/§7 U3; `V15 §4/§5.1` M1–M5 | owner donor frame at matched camera; runtime `terrainmeshN` chooser |
| U2 | **Mountains** — "highlands" wallpaper | `X07 §3 A6`, U6: stone construction scene, **two-pass-confirmed** no mountains | never cite filename as evidence; excluded permanently |
| U3 | **Mountains** — `StandPatternWithAngle` yaw sign / metres-per-unit; whether props actually render (no QA atom result) | `V15 §4`; `A04` E10/R2; `V15 R11` | QA atom + donor frame |
| U4 | **Sea** — water-body identity; whether pale band in `maxresdefault_1.jpg` is sea, riverbank or wet sand | `X07 §4/§7 U2/U9`; `V15 §5.2` S5 | donor frame + donor water/shore data; not the still |
| U5 | **Sea** — plane Y, `hmapTex` bind/FBO, reflection target, foam pixel width, metres-per-cell | `D06 §11`, `X27 §3.3/§5 #4`, `V15 §4` | GL trace / permitted donor runtime |
| U6 | **Rivers** — only `generator.cfg:62-64` `hint=8.Rivers` mask path; no skirmish placement rule, no ford generator (`fordtyp` is a formation field) | `V15 §5.3` R1–R4, `D06 §8.2`, `X27 §4`; `OUT_OF_SCOPE` pending COORD/F10 (V16 O2) | DLC5 scope ticket + placement rule; inventing a ford threshold is forbidden |
| U7 | **Swamps** — no identifiable still; `[*] = ;` activation; `m_swamp_12_old` 17×20 vs binary 18×23 PRESERVED; `lake_big := plain*2*0` not repaired; no swamp/lake family exported | `X07 §4/§7 U5`, `V15 §4/§5.4` W1–W5, `A04` E20/E22, `X27 §3.3` | donor frame; declared activation gap; quarantine policy, never "fix" |
| U8 | **Iron/coal mines** — no identifiable still (A0 is an **inferred gold** mine from icon + on-screen text); capacity, snap activation, record-id→prop binding, native `SetupMines`, small-map ring-2 stale-`dst` quirk | `X07 §4/§7 U4/U8`, `V15 §4/§5.5` I1–I5, `D07`; A05's "≈9 sites/start" is a refuted **port belief** | donor frame + binary/VMT lift |
| U9 | **Packed stubs / whole artifacts** — `.bind` entropy 7.96 never unpacked; 23/34 D01 anchors absent; 4,265/18,918 (22.54%) cossacks + 12,254/22,384 (54.7%) editor functions garbled; `config.exe`/`modman.exe` one RNG byte cross-check only; `cdx` zero mentions; 49 baked DLC `.map` payload opaque | `X27 §0/§3.1/§4`, `§5 #9`, E1–E4, §6 C9; `V52 Q1` | VMT-pointer discovery + second lifter; "absence is not proof" (`X27 R6`) |
| U10 | **Runtime activity** — all 972 X03 `.inc` excerpts and all F03 cfg literals are `;`-prefixed intent; no donor binary executed; no compiled path observed consuming a decoded value | `X27 §0/§3.2/§4` Category A, `V52 Q1`, spec/00 §5 U10, X34 §7 U-X34-9 | permitted read-only donor runtime/GL trace; otherwise accept as **declared UNVERIFIED** |
| U11 | **Row sign** — file-row → map-row flip unresolved | `D05` U1, `X12` U1, `V16 O10`, `V26 X1` residue, `X34 §7 U-X34-8` | second-instrument binary read; extrema alone are invariant to row order |
| U12 | **Blend pass count** — `bmTransparency` composite pass count unresolved after **six** passes | `X27 §2 E14`, `§3.3`, `X17 §4.3`, `V16 O11` | GPU trace or packed `.bind` decode |
| U13 | **x87 precision** — true x87 precision, plus rotation rounding and global setter clamp | `HANDOFF §1`, `V26 X1` residue (`D05` U5, `V16 O10`) | native study with a second lifter; otherwise permanent declared unknown |
| U14 | Other named residues (carried, not promoted) — `tiaAlphaFromIntensity`, tile→patch selector, eye planes, atlas packing equivalence; `.pattern` field semantics; `.map` tag/owner/collision fields; native kernels `SmoothTerrain`/`PlateauTerrain`/`PaintTerrain`/`WaterFieldAdd`; generator version / `mapsize` enum; deposit capacity; alpha composite layer count; `hmapTex` binding; missing `CalcTerrain`/`test_shadow`/tile painting | `X27 §2 E12/E14`, `§4` Category B, `§5 #2–#8`; `V15 §4`; `HANDOFF §5 #3/§7` | second-instrument lift or permitted runtime; all stay `[U]` |
| U15 | **No donor GPU A/B frame** / no reliable still for mountains, sea, iron/coal mines, rivers, swamps | `X07 §7 U1/U3/U4/U5`, `V15 §0`, `X27 §5 #10`, `V52 Q4` | owner-run matched capture (§5.1) |

**Combination rule (V15 §2, binding):** tier 2 never implies tier 1; tier 1 never implies tier 2; no tier above 2 exists. An item stays at its highest *actually reached* tier and lower-evidence items remain visible in the same row. `declared_unverified` (accepted parity gaps U1–U15) is distinct from `blocking_unverified` (missing QA evidence); any non-empty `blocking_unverified` ⇒ `RESULT IS NOT GOOD` (`V15 §2`, spec §12.6:92-95). Today `blocking_unverified` is non-empty.

---

## 3. Multiple-pass guard against overstatement (CHARTER §4)

Each candidate overstatement was re-read with a second landed instrument; the weaker wording is kept. **No claim below is promoted on one reading.**

| # | Candidate overstatement | Pass 1 | Pass 2 / second instrument | Accepted wording |
|---|---|---|---|---|
| P1 | "710/710 means the whole binary was decoded" | `X27 §2 E9` closure 710/710 | `X27 §3.1`/§6 C9: 4,265 garbled cossacks functions, 11/34 anchors, packed `.bind`; `V52 Q1` | "710/710 **`.pattern` files** byte-closed; whole-binary semantics NOT decoded" |
| P2 | "Byte-exact decodes are a signed tier-1 port verdict" | §1 eight byte-exact decodes | `V15 §2` tier-1 rule + `HANDOFF §0/§4`: D3 not run, no port-side byte match, gates `TODO(COORD)` | "Tier-1 **evidence prepared**, donor-decode integrity verified; **port verdict unsigned**" |
| P3 | "Self-consistent visual ⇒ donor match / close to donor" | V15 §4 drafted visual properties | `V15 §2` combination rule; `X07 §6 U1/U2`; `V52 Q4`: no donor frame, `compare_shots.py` legal only candidate-vs-candidate | "PORT APPROXIMATION only; no parity, no similarity percentage, no metric pass verdict" |
| P4 | "X39 / X36 landed; cite them" | task brief mentions `X39_ab_feasibility.md` and X36 | V57-era `glob "X3[0-9]*.md"` → only X30 and X34; `Test-Path X39_ab_feasibility.md` / `X36_parity.md` → False; V67 glob: `X39_ab_feasibility.md` and `X36_mountain_visual_recheck.md` are present; V36 is an integration checklist | "Point-in-time: absent at the V57 read, **both have since landed (V67 glob)**; re-read before citing or disclaiming. The same-camera donor-capture requirement is unchanged and rests on V15/X07/V52/spec §12.6; X39 §3 now supplies the owner procedure." |
| P5 | "I02 self-test `PASS 29/29` = gate green" | `X34 §6.1` `CHECK SUMMARY: PASS 29 / FAIL 0` | `X34 §6.4`: read-only dry-run, structural verification only, `visual_parity_claim=false`; `SWARM_BOARD` gates all unchecked | "Decoder self-test PASS is **not** a gate result; no runner job, no Godot job" |
| P6 | "No capture ⇒ no verdict possible at all" | no capture on disk | `V15 §2`: tier 1 (structure) and tier 3 (explicit UNVERIFIED) remain expressible; `V52 Q3` class table | "No tier-2 result; tier 1 evidence prepared but unsigned; tier 3 declared" |
| P7 | "Blend function known ⇒ pass count known" | `X27 §2 E14` exact `glBlendFunc` VA | `X27 §5 #3`, `X17 §4.3`: pass count `[U]` after **six** passes; `V16 O11` | "Blend **mechanism** exact; **pass count UNVERIFIED**" |
| P8 | "The 12 stills are donor A/B frames" | X07 §2 indexed 12 images | `X07 §0/§6 U1`: unknown build/camera/zoom/compression, direction only; `V15 §5.6` "highlands" two-pass false positive | "Third-party direction cues only; never a gate, never donor evidence for a no-reference class" |

---

## 4. One-sentence answer to "is terrain cloned?"

> **No — terrain is not cloned: the donor's terrain-relevant data formats and a small set of named functions are byte-exactly decoded and a donor-shaped port scaffold exists, but no donor GPU A/B frame, no gate result and no runtime observation exist, so the honest verdict is `PORT APPROXIMATION` with donor parity `UNVERIFIED`.** `[D]/[U]`, sources: `X27 §7`, `V15 §2`, `HANDOFF §0/§5`, `V52 Q2`, `V36 §1.4/§6`, spec §12.5–§12.6.

---

## 5. Conditions under which this verdict could be upgraded

**Guard:** nothing here raises the verdict today. These are *conditions*, not achievements. `[I]` design reading, cited to landed documents.

### 5.1 Owner-run same-camera donor capture (the parity ceiling)

1. **A genuine donor GPU A/B frame at the same seed, map size and camera as the candidate capture** — the **only** thing that can lift a class above tier 2 and change `parity.status` (`V15 §2/§8 Q8`, `X07 §8/Q2`, `V52 §7.3 #1`, `HANDOFF §7 #1`, `X27 §5 #10`). No one has produced one; the owner must decide whether it is obtainable.
2. **Admissible candidate capture first** (G0-a…e, `A05 §4.1`; spec §12.6): windowed non-blank 1280×720 PNG, `script_error_lines = 0`, pinned seed/camera/size, identical fractional ground ROI on both sides; an ROI landing on sky/HUD/units is UNVERIFIED, **not** retried until green (`X07 §6 risk 7`, `V15 R10`). Metric and visual fields stay separate; no metric overrides the visual read (`V15 §6`, spec §12.6).
3. **Canonical size pinned** — 240² vs 320² is still OPEN (`X27 §6 C8`, `V15 Q7`, `V52 §7.3 #4`). Freeze explicit baselines labelled by actual size.
4. **Note on X39 (point-in-time):** `reports/X39_ab_feasibility.md` was absent at the V57 read (two instruments, see frontmatter) but **has since landed** (V67 glob). The same-camera donor-capture requirement is unchanged and rests on V15/X07/V52/spec §12.6; X39 §3 now supplies the exact owner procedure (320² enum 0, Land/TerrainTypes 0, season int, explicit `randkey0/1`, camera/ROI manifest, out-of-repo `.map` + PNG + SHA-256; donor frame **necessary but not sufficient**). Re-read before citing or disclaiming; this changes no tier or parity status.

### 5.2 Gates green (fresh, not stale)

5. **Freeze the tree and use V47 as the canonical contradiction register** before any gate: shader path, composer→I07 Object-vs-Dictionary, composer→I08 Dictionary-only ingest, composer→I09 missing `bind`, I12 hook arity/return shape, I02/I03 output ownership, I09 `DONOR_UNITS=160`, I01 permanent-red `--check`, tautological self-checks (`V36 §5`, `V52 Q7`, `V47 §5`). The four V36 API breaks were repaired by V48 caller-side patches; V61/V65 report **static PASS** on all six audited pairs. **A static PASS is NOT a gate PASS and proves no streams were produced**: runtime parse, stream assertions and gates remain COORD-owned. Do not claim donor mode is inert or green — keep explicit `gen_applied` / `mesh_built` / `props_applied` assertions and `missing_modules` empty (`V61 §5`, `V65 §9`).
6. **Run the gate sequence A′-0…A′-3 then D-0…D-6** (`V21 §6`, `V42 §0`, `V36 §6`, `V52 §7.1`) with fresh JSONs whose mtime follows job START. Required: selftest **29/29**, uitest **17/17**, `t_render_mode` PASS, `t_map_variety` 5/5, `scan_map ALL GREEN`, `assert_clean` CLEAN with **575/582/585 acknowledged with evidence-backed reasons** (never deleted, never `--ignore-history`), `app/**` byte-identical, one Godot at a time with unique `--id`.
7. **Determinism D1/D3:** five dump streams byte-identical across 64²/240²/320² at zero tolerance; run integrity status ∉ {timed-out,error,skipped}, `script_error_lines=0` (`V15 §3`, spec §12.6, `HANDOFF §4`). D3 is the precondition for signing any tier-1 port verdict.
8. **Resolve V16 O1–O14** and preserve (never "fix") donor contradictions C2/C3/C4/C9 (`SWARM_BOARD` §Contradiction register, `V26`).

### 5.3 Spec `[U]` items resolved

9. **Mark §§01–14 READY** after folding landed-but-unfolded reports; `spec/README.md` currently shows PENDING and V17/V26/V34/V36 identify stale text (`SWARM_BOARD` §Landed log, `V17`, `V26`). §00 has landed but no section is unconditionally READY.
10. **Close or formally accept the X27 §5 top-10 blockers**, especially runtime activation of the `;`-prefixed corpus (cannot be proven without donor execution → accept as `declared_unverified`), row-sign flip, blend pass count, `hmapTex` binding, key replay, `.pattern` field semantics, `.map` semantics, native kernels, whole-code gaps and the missing donor frame (`X27 §5`, `V52 Q1`).
11. **Complete and validate the toolchain/QA evidence**: N17 `terrain_qa_spec.json` population, N7 validator, `assets/terrain_new/**` outputs and I12 manifest registration. `terrain_qa_spec.json` was `SCHEMA_ONLY__UNPOPULATED__NO_PARITY_CLAIM` with all bands `value:null` and `signed:false` at V36 EV18 / V52 Q7. **Multi-pass drift note:** a second, read-only re-check at this writing found `variant3d/assets/terrain_new/**` **now present** (generated `cfg/*.json`, `patterns/*.json`, `manifest.json`), while `inbox/qa/terrain_qa_report.json` and `inbox/qa/captures/` remain **absent**. Presence is existence evidence only — no generated output was byte-validated or gate-tested by this worker. `--policy red` stays refused until a signed donor spec exists (spec §12.6).
12. **Only then** may COORD sign a three-tier report with `blocking_unverified = []`, three-tier verdicts per class and metric/visual fields separate. **Even after all gates pass, the best honest outcome is "gates green / internal consistency PASS / donor parity UNVERIFIED" unless item 1 (a real donor frame) is satisfied** (`V15 §2`, `V52 §7.3`, spec §12.5).

---

## 6. Risks

| # | Risk | Label / landed evidence | Mitigation (verbatim guard where applicable) |
|---|---|---|---|
| R1 | Byte-exact decode counts misread as "whole donor decoded" or as parity | `[O]/[U]`, `X27 §6 C9`, §8 R1, `V52 Q1` | Always quote 11/34 anchors, 22.54%/54.7% garble and packed `.bind` alongside 710/710; no parity wording |
| R2 | Tier-1 evidence preparation mislabelled a signed tier-1 verdict | `[U]`, `V15 §2`, `HANDOFF §0`, `V52 §0` | Say "prepared but unsigned, D3 missing"; never mark a class upgraded |
| R3 | Tier-2 self-consistency quietly promoted to donor fidelity | `[U]`, `V15 R2`, `A05 E09/E12`, `X07 §6 U1` | Fixed three-tier vocabulary; `parity.claim = NONE`; reviewer line verbatim in every owner-facing capture |
| R4 | Advisory bands hardened into red gates without a signed donor spec | `[D]/[I]`, `V15 R3`, spec §12.6, `V36 EV18` | Keep `--policy advisory`; no fabricated bands; thresholds stay `[D]`/`[I]`, never `[O]` |
| R5 | A still mis-cited for the wrong class ("highlands" mountain, A0 gold→iron/coal) | `[O]`, `X07 U3/U6/U8`, `V15 R4/§5.6` | Class→image map locked (`X07 §4`); per-class rows cite donor paths, not filenames |
| R6 | Missing QA evidence hidden behind an accepted declared gap | `[I]`, `V15 R8`, `V15 §2`, `HANDOFF §5 #6` | Keep `declared_unverified` vs `blocking_unverified` split; non-empty blocking ⇒ `RESULT IS NOT GOOD` |
| R7 | Stale "X39/X36 unlanded" disclaimer reused, or point-in-time board read as current | `[O]` V57-era two-instrument check (frontmatter); V67 glob: both now landed | Re-read before citing or disclaiming; COORD re-checks the directory before dispatch; no tier or parity status change |
| R8 | Row sign / pass count / x87 precision treated as settled because neighbours were decoded | `[U]`, `X34 §7 U-X34-7/U-X34-8`, `X27 E14` | Preserve `[U]`; multi-pass and record; no threshold invented |
| R9 | Contract-repaired opt-in backend shallow smoke "green" without streams | `[D] HIGH`, `V36 §1.4/§6 R1`, `V61 §5`, `V65 §9`, `V52 Q2` | Require explicit `mesh_built` / `gen_applied` / `props_applied` stats assertions and `missing_modules` empty; static PASS ≠ gate PASS; never re-run until green |
| R10 | ROI transferred onto sky/HUD/units and retried until green | `[I]`, `X07 §6 risk 7`, `V15 R10`, spec §12.6 | G0-e identical ROI both sides; failed ROI ⇒ UNVERIFIED, not retried |
| R11 | This statement read as a gate result or a donor-match certificate | `[U]`, CHARTER §4, `V52` parity guard | It is a **statement of landed evidence only**; no gate was run, no capture reviewed, no donor frame exists |

---

## 7. Open questions

1. **Q1 (owner):** is a same-camera, same-seed, same-size donor GPU frame obtainable at all? Until it is, `parity.status` stays `"UNVERIFIED"` (`V15 Q8`, `X07 Q2`, `V52 §7.3 #1`, `X27 §9 #2`).
2. **Q2 (COORD):** approve the `declared_unverified` / `blocking_unverified` split (`V15 Q1`)? Until approved, the conservative owner reading is `RESULT IS NOT GOOD`.
3. **Q3 (COORD/I13):** pin the canonical capture size (240² vs 320²) and the camera/ROI set (`V15 Q7`, `X07 Q1`, `X27 §6 C8`).
4. **Q4 (COORD/F10):** are DLC5 `lakes`/`rivers` masks in scope? If not, rivers stay `OUT_OF_SCOPE` with the `V15 §5.3` citations (`V15 Q2`, `V16 O2`).
5. **Q5 (COORD — point-in-time):** `X39_ab_feasibility.md` was absent at the V57 snapshot (two instruments, frontmatter) but **has since landed** (V67 glob). It adds the exact owner procedure (§3) and the necessary-but-not-sufficient rule (§4); capture-admissibility conditions are unchanged (V15/X07/V52/spec §12.6). Re-read before citing or disclaiming; no tier or parity status changes.
6. **Q6 (D03/D05):** will row-sign flip and global setter clamp ever be lifted above `[U]`, or accepted as permanent declared unknowns (`X27 §9 #5`)?
7. **Q7 (COORD):** who adjudicates V36 C1–C14 under one-owner-per-file (`V36 Q1–Q8`, `V11`), and when is D3 run so tier-1 port verdicts can be signed?
8. **Q8 (D02/V01):** can saved-map key bytes be validated read-only from a known-key `.map` (`X27 §9 #4`)?

---

## 8. Five-line summary (V57)

1. **[O] Verified donor structure (decode integrity only):** 710/710 `.pattern` closure (X27 E9 + independent X34 710/710, 13/13 bit-exact grid), 680-section `pattern.lib`, 4,466 masks, 7 cfg files, exact LCG, opcode-level stamp blend paths, `bmTransparency` blend func and 37-byte `.map` records — all cited in §1 with counts.
2. **[U] Signed tier-1 port verdict: NO** — V15 §2 needs a port-side byte match plus D3 dump integrity; neither exists, so the class table stays "evidence prepared, verdict unsigned" (`HANDOFF §0/§3`, `V52 §0`).
3. **[U] Self-consistent visual: criteria only** — no admissible capture, no 240²/320² baseline, no `inbox/qa/captures/**`; tier 2 would need a capture and none exists (`V15 §4`, `HANDOFF §2`, spec §12.6).
4. **[U] UNVERIFIED stays UNVERIFIED** — mountains/sea/rivers/swamps/iron-coal mines (`X07 §4/§7`), packed stubs and 22.54%/54.7% garbled functions (`X27`), runtime `;`-prefixed intent, row sign, blend pass count (6 passes), x87 precision (§2.3 U1–U15).
5. **[D] Terrain is not cloned; verdict upgrades only on an owner-run same-camera donor frame + fresh green gates + resolved spec `[U]` items** — X39/X36 were absent at the V57 read but have since landed (V67 glob; re-read before citing or disclaiming), no parity claim is made, and the reviewer line above is mandatory verbatim (`V15 §2`, `V52 §7.3`, `V36 §6`).

---

*End of V57. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V57_final_parity_statement.md`). No source, shader, asset, config, test, result JSON, git, runner or Godot state changed; no donor binary executed or copied; no capture, gate result, reference image or parity metric invented; no donor-parity claim asserted anywhere. All claims are point-in-time against landed documents — COORD must re-verify the live tree before acting.*
