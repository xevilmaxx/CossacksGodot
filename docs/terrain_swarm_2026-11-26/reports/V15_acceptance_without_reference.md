---
id: V15
swarm: TERRAIN-SWARM-2026-11-26
role: DESIGN / QA — honest acceptance criteria for classes with no reliable donor visual reference
owner_file: docs/terrain_swarm_2026-11-26/reports/V15_acceptance_without_reference.md
status: DELIVERED__DESIGN_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only. No donor GPU A/B frame exists and none is invented here. No reference image, no parity metric and no donor-match wording is used; donor parity stays UNVERIFIED for every class."
scope: "Five no-reference classes from X07 (true mountains, sea, rivers, swamps, iron/coal mines) plus the 'highlands' false-positive trap. Hills/fields/forests/gold-mine stills are NOT re-certified here."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md — §2, §4, §6
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md — V15 slot, integration gates
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md — §0, §4, §6, §7, §8
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md — §2.3, §3, §4, §5, §7, §11
  - docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md — §12.5, §12.6
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md — §0.1, §2, §4, §8
  - docs/terrain_swarm_2026-11-26/reports/D07_resources_bin.md — §0, §3, §6
  - docs/terrain_swarm_2026-11-26/reports/D06_water_shore.md — §0, §3, §4, §7, §11
  - docs/terrain_swarm_2026-11-26/reports/F02_pattern_lib.md — §5, §8
  - docs/terrain_swarm_2026-11-26/reports/F03_gen_config.md — §2, §6, §7, §9
---

# V15 — acceptance without a donor visual reference

## 0. Executive summary

1. **[O] The premise is X07's, not an assumption of this worker.** The 12 stills in
   `C:\Users\Maxym.Oboyshev\Downloads\c3\` yield *no* reliable reference for true
   mountains, sea, rivers/swamps or identifiable iron/coal mines
   (`reports/X07_visual_reference_index.md:33-36,214-232`, UNVERIFIED register U2–U6,
   U9 at `:284-299`). The file
   `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` is a stone
   construction scene with no mountain relief on two passes (X07 §3 A6 card
   `:155-164`) — its filename must never be cited as evidence (X07 U6).
2. **[D] Stills are not the only donor evidence.** `pattern.lib` object records,
   `generator.cfg` family/weight counts, donor script line constants, decoded height
   extrema, asset presence, RNG reset boundaries and dump-stream determinism survive
   independently of any screenshot. These support a *structural* verdict for all five
   classes (§1, §3, §4).
3. **[D] A self-consistent visual verdict is still possible**, but only for internal
   properties named from donor *rules*: silhouette present (props ON/OFF),
   no concentric rings or diagonal vein lattice, a continuous shore transition band,
   a visible mine mesh on its ground disc. These are `PORT APPROXIMATION` observations,
   never donor parity (A04 §4.2/§4.4/§4.5/§4.8; A05 §4.2).
4. **[U] Five unavoidable visual-parity gaps must be reported to the owner**, one per
   class: no donor mountain still; no certifiable sea/riverbank identity; no river
   class rule in scope; no swamp still; no identifiable iron/coal mine family in the
   corpus. Additional per-class gaps are listed in §4 and §5.
5. **[I] Verdict vocabulary is deliberately three-tier**: DONOR-GROUNDED STRUCTURE
   VERIFIED / SELF-CONSISTENT VISUAL / UNVERIFIED (§2). A tier-1 or tier-2 result never
   promotes a tier-3 item; the owner-facing report separates `declared_unverified`
   (accepted parity gaps) from `blocking_unverified` (missing QA evidence), so an
   honest "gates green / internal consistency PASS / donor parity UNVERIFIED" outcome
   is expressible without a fake donor A/B (A05 §9, spec §12.6:96-100).
6. **[D] Contradictory evidence was multi-passed, not skipped** (§5): the "all mountain
   grids zero" claim vs `i_mnt_big_1`'s non-zero window; `mng` read as "market?" vs
   nested `minegold` objects; A05's "9 sites/start" band vs D07's ring refutation;
   three distinct donor water levels; `m_swamp_12_old` 17×20 vs 18×23; and the DLC5
   `rivers` mask vs A04's out-of-scope ruling. Every pass is recorded with what was
   accepted and why (CHARTER §4).
7. **[O] No repo file other than this report was written; no Godot job was submitted;
   no donor binary was run or copied; no reference image or parity metric was invented.**

---

## 1. Evidence table — what survives without stills

Legend: `[O]` literal donor line/byte/report observation; `[D]` arithmetic or control-flow
consequence; `[I]` interpretation; `[U]` unavailable/unproven; `PORT APPROXIMATION` =
port substitute. Donor paths are under `C:\Games\Cossacks 3\` (read-only, private use).
Report paths are repo-root relative.

| ID | Label | Source (donor path:line or report §) | Establishes | Used as |
|---|---|---|---|---|
| V-E01 | `[O]` | `reports/X07_visual_reference_index.md:33-36,214-232,284-299` | No visual reference for the five classes; "highlands" false positive; U1 parity ceiling | Problem statement; verdict ceiling |
| V-E02 | `[O]` | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-44,66-93,121-135` | Read-only donor, mandatory labels, multi-pass on anomalies, no parity without GPU A/B, definition of "good" | Binding method |
| V-E03 | `[O]` | `reports/A05_qa_harness.md:87-136` (`main.gd:751-810`, `full_map_shot.py:191-227`) | Five canonical dump streams; same seed ⇒ SHA-256 byte identity at 64²/240²/320²; zero tolerance | Shared determinism baseline |
| V-E04 | `[D]` | `reports/A05_qa_harness.md:138-158` | S1 height deciles, S2 water id 255, S3 shore fraction, S4 tile-id histogram, illegal ids = 0 | Shared histogram baseline |
| V-E05 | `[D]/[I]` | `reports/A05_qa_harness.md:152-155`; `variant3d/tools/donor_gen.py:49-59` via A05 E06 | S5 stamp catalogue, S6 family ratios, S7 mine/field/forest counts; bands `[D]`/`[I]`, never `[O]` | Advisory structural checks only |
| V-E06 | `[O]` | `data/pattern/pattern.lib:1-39,338480-338507,713410,715244,716910` via `reports/F02_pattern_lib.md:17-55,160-180,227-238` | 680 plaintext sections, 39,780 `Objects` records, 235 `BaseName` values; mine props nested in `mng/mni/mnc`, not named as families | Class structure: mountains, mines, swamps |
| V-E07 | `[O]` | `data/pattern/pattern.lib:337461-340273` (`:338482`), `:819028-819060`, `:913980-914095`; F02 §5.4/§5.8 | `g_mnt_1` 43×38 all-zero grid + `terrainmesh4` prop; lake window −2.132…+0.454; swamp zero grid; `m_swamp_12_old` 17×20 vs binary 18×23 | Mountains, swamps; contradiction register |
| V-E08 | `[O]` | `data/game/var/generator.cfg:2-66,69-140,1290-1533`; `reports/F03_gen_config.md:33-39,660-759` | 6 base + 9 DLC5 mask types (hint 8 = Rivers); 64 families / 493 `Pattern=Freq`; mng/mni/mnc 6 each; swamp 11+2+20 | Sea/rivers/swamps/mines counts |
| V-E09 | `[O]/[D]` | `data/gen/tilesmooth_scripts.cfg:4-96,934-1810`; `reports/F03_gen_config.md:570-597,797-815` | 22 chains, `sandsea5=0.7/sandsea6=0.3`, `rock9=0`; no seed/RNG/water-level/mine-count constant in cfg; all consumers `;`-prefixed `[U]` | Shore band; "counts only, no semantics" |
| V-E10 | `[O]` | `data/scripts/common.inc/dogenerate.inc:522-717`; `reports/D07_resources_bin.md:27-40,138-221,368-379` | `SetupMines`: ring → ore (mng/mni/mnc) → 256 angle tries; rounds 3/4/5; bands `14+8R/32+10R/70+12R/22+16R` on `v>=80,mapsize>2`; refutes per-ore radii | Iron/coal mine placement |
| V-E11 | `[O]` | `data/scripts/common.inc/dogenerate.inc:407-415,720-947,980-988,1370-1425,1538-1909`; D07 §3.6/§3.10 | Start ellipses 5×7/12×15/22×18; stone/forest ring passes; repeated `SetRandomKey(randkey1)` resets; global swamps/lakes at `:1774-1906` | Seed determinism; swamps; no food rects |
| V-E12 | `[O]/[U]` | `data/objects/env/initial.inc:49-51,74-103`; `data/scripts/lib/res.script:23-32`; D07 §3.8/§6 U1–U3 | Ore resource ids gold 4/iron 5/coal 6; no finite deposit amount; `[*] = ;` activation unproven | Mine acceptance ceiling |
| V-E13 | `[O]/[D]` | `data/scripts/common.inc/generatemap.inc:7,560-574,580-643,686-707`; `reports/D06_water_shore.md:17-24,92-105,150-176` | Three water levels −1.1 basin / −0.5 field / −0.25 & −0.1 classification (band 0.15); shore height smoother = 3× power 0.35 | Sea/shore/rivers structure |
| V-E14 | `[O]/[D]` | `data/shaders/water/water.dev.frag:37-47,167-232`; `data/gen/texturemap.inc:463-529`; D06 §6.1/§7.1/§11 | Foam peak at depth 0.535, zero at waterline and ≥1.07; no foam texture; shore tiles only `sandsea1/5/6`; `hmapTex` bind `[U]` | Shore-band visual rule |
| V-E15 | `[O]/[U]` | `data/scripts/lib/misc.script:5271-5346`; `data/scripts/classes.script:4201`; D06 §8.2 | Bridges are objects + collision; `fordtyp` is a squad formation type; **no** ford-generation rule found | Rivers out-of-scope basis |
| V-E16 | `[O]` | `reports/A04_landscape_props.md:76-89,131-163,225-269` (E02–E04, E07–E10) | Donor renders relief in H/P/T channels; mountain height grids zero ⇒ `terrainmeshN` props carry silhouette; 112 prop records/30 sections; 4 converted `relief` assets; NO QA atom result | Mountains structural + UNVERIFIED |
| V-E17 | `[O]` | `reports/A04_landscape_props.md:154-163,377-398,432-464` (E14, E17, E21, E22, E26) | Mine mesh scale 0.3152/no jitter, 5×5 dirt plate, port richness clusters; swamps zero height + bushes/fern; no swamp/lake export; zero donor files named `quarr` | Swamps, mines, quarry note |
| V-E18 | `[D]/[I]` | `reports/A04_landscape_props.md:265-269,429-430,265-269`; A05 §4.1 G0-a…e | Internal cues: silhouette ≥ centre +4 m, ON/OFF ≥200 changed px and ≥8 px rise, <1% outside change; mine disc + centred built mine | Self-consistent visual tier |
| V-E19 | `[O]` | `reports/A05_qa_harness.md:160-205,240-295`; `spec/12_QA_AND_INTEGRATION.md:71-100` | Admissibility G0-a…e; metric and visual fields separate; `parity.claim = NONE`, `status = UNVERIFIED`; metric never overrides eye | Final-report schema contract |
| V-E20 | `[D]/[I]` | `reports/X07_visual_reference_index.md:214-232` §4 class map | Mountains/sea/iron-coal/rivers-swamps confidence `[U]`; hills/fields/conifer forest/gold mine have usable references (out of V15 scope) | Scope boundary |

---

## 2. Verdict vocabulary (three tiers, binding)

The tiers describe **what kind of claim is being made**, not whether a gate is green.
They are orthogonal to A05's gate statuses `PASS|FAIL|UNVERIFIED|NOT_APPLICABLE|
RECORDED_NOT_APPLICABLE` and to `--policy advisory|red` (A05 §3, §7).

| Tier | Name | Admission rule | What it permits | What it forbids |
|---|---|---|---|---|
| **1** | **DONOR-GROUNDED STRUCTURE VERIFIED** | At least one cited donor datum (`path:line` or evidence id, label `[O]`/`[D]`) matches a port-side observable **byte, count, record, id or hash** exactly; dump integrity D3 holds (A05 §2.3). | "The port's mine-family record count equals `generator.cfg`'s 6 per ore (V-E08)." "Every mine stamp name is in the donor-derived catalogue (A05 S5/S6)." | Any statement about how it *looks*; any claim that a numeric advisory band is donor-measured; promotion of `[I]`/`[U]` to `[O]`. |
| **2** | **SELF-CONSISTENT VISUAL** | G0-a…e admissibility passes (windowed, non-blank 1280×720 PNG, `script_error_lines = 0`, pinned seed/camera/size, identical ROI on both sides — A05 §4.1). Property is named from a donor *rule* but checked only inside the candidate capture. Metric field and visual field are recorded separately (A05 §4.2.4). | "A silhouette rises above the surrounding height field when props are ON"; "the shore band is continuous beach → foam → water with no hard tile edge"; "a mine mesh is visible on its ground disc". Label `PORT APPROXIMATION`. | "Matches donor", "close to donor", a percentage similarity, `compare_shots.py` donor-vs-candidate SSIM/MAD, a z-score used as fidelity, a "PASS" verdict from a foam/water metric, reuse of a still as a gate. |
| **3** | **UNVERIFIED** | No admissible donor datum exists for the property, or evidence is contradictory/unavailable after ≥2 passes; or a required QA item is missing. | Explicit listing with reason, passes attempted and "what would settle it". | Silent promotion to PASS; deleting the item to make a gate green; inventing a reference image, threshold or parity metric. |

**Combination rule.** A class's honest verdict is the **highest tier actually reached**, and
every lower-evidence item stays visible in the same row. Tier 2 never implies tier 1;
tier 1 never implies tier 2. No class in §4 reaches "donor parity" because no tier above
2 exists in this vocabulary by construction.

**Two kinds of tier-3 items (owner-facing bookkeeping, `[I]` design decision):**

- `declared_unverified` — parity gaps that cannot be settled in this wave (no donor GPU
  frame, no still, unproven runtime activation). Recorded per class; accepted as a known
  limitation, not a gate failure.
- `blocking_unverified` — required QA evidence that is *missing or contradictory at the
  point of sign-off* (no dump, no admissible capture, dirty runner, unresolved
  contradiction that changes a numeric gate). **Any non-empty list ⇒ `RESULT IS NOT GOOD`
  and hold/rollback** (A05 §5 G4, §6; `spec/12_QA_AND_INTEGRATION.md:92-95`).

COORD must confirm this split (§8 Q1); until then the conservative reading is to list both
and mark the overall result `RESULT IS NOT GOOD`.

**Required reviewer wording, verbatim (A05 §4.2, X07 §8):**

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU
> A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

---

## 3. Shared baseline — checks that apply to all five classes

These are not class-specific; they are prerequisites for any tier-1 or tier-2 verdict.

1. **Determinism (hard).** Two runs per size `S ∈ {64,240,320}` with the same key
   manifest ⇒ all five `--dump-map` streams SHA-256 equal (height f32 raw bytes,
   tileblock, terrain, blocked, canonical prop/cluster/stamp set with `float.hex()`);
   zero tolerance. Run integrity: runner status ∉ {timed-out,error,skipped},
   `scan-stderr.script_error_lines = 0`, `assert_clean` exit 0 (V-E03, A05 §2.3 D1/D3).
   Cross-size fractions remain **advisory** until D02 settles RNG size-invariance
   (A05 D2; `spec/12_QA_AND_INTEGRATION.md:80-84`).
2. **Histogram gates (advisory unless spec populated).** Height deciles and five donor
   bands, `tileblock == 255` water id (hard), shore fraction, tile-id histogram with
   illegal ids = 0 (hard), stamp/family/resource counts (V-E04, V-E05). Numeric ranges
   are still `[D]`/`[I]` slots from D03–D08/F03–F08; `--policy red` is not authorised
   (A05 §3, spec §12.6:80-84).
3. **Stage-order contract.** Relief and water must be derived from the same `height[]`
   used by the mesh; shore tiles run after water classification; props are render-only
   and never write `blocked[]`/`nav_version`/RNG state
   (A04 §4.1/§4.4/§4.5, §5 items 3–4; D07 §3.10 `SetRandomKey` resets at `:1616,:1772,:1909,:1927`).
4. **No fabricated substitutes.** No synthetic foam image or `FOAM_GAIN`, no radial rock
   rings, no diagonal vein lattice, no per-cell hash/dither/noise, no fabricated quarry
   asset, no new donor constant without `path:line` (CHARTER §4, A04 §5 item 5, D06 I8).
5. **Capture admissibility.** G0-a…e before any visual read; same fractional ROI on both
   candidate sides; if the ROI lands on sky/HUD/units the comparison is UNVERIFIED, not
   retried until green (A05 §4.1; X07 §6 risk 7). `compare_shots.py --threshold 0.9999`
   is legal **only** for candidate-A vs candidate-B self-determinism at a pinned camera
   (A05 §4.2.3).

---

## 4. Per-class acceptance criteria table

"Structural" = tier 1; "Visual" = tier 2; "Must stay UNVERIFIED" = tier 3. Every row is
`PORT APPROXIMATION` for visual acceptance; no donor-parity claim.

| Class | (1) DONOR-GROUNDED STRUCTURE — checkable now | (2) SELF-CONSISTENT VISUAL — no donor claim | (3) MUST STAY UNVERIFIED — report to owner | Highest honest tier |
|---|---|---|---|---|
| **True mountains** | `pattern.lib:337461-340273` `g_mnt_1` 43×38 `min=max=0` and `BaseName=terrainmesh4` at `:338482` (V-E07); `mountains` family 7 records, `desert_mountains` 13 (F02 §5.4; `generator.cfg:660,:1867`); 112 `Objects` records / 30 sections, scale 0.3539–0.6562 (A04 E03); manifest has exactly 4 `relief` sids, `mountain_props.json` 20 stampable sections/45 records (A04 E07/E08); every emitted stamp name ∈ `donor_patterns.json` catalogue + D1 prop-set hash (A05 S5, V-E03) | Silhouette rises ≥ centre terrain +4 m and ≥ footprint max +2 m; props-ON/OFF ≥200 changed px, ≥8 px upward rise, <1% outside change; `matched_stamps>0` guard; no concentric rings, no diagonal vein lattice, no flat-only mound; two non-blank windowed 1280×720 PNGs (A04 §4.2, §4.8; V-E18) | Donor visual silhouette; runtime chooser among multiple `terrainmeshN`; `StandPatternWithAngle` yaw sign and metres-per-unit; whether Z08 props actually render (no QA atom result); winter/desert props, `terrainplateau1..4`; "highlands" wallpaper is not a mountain reference (X07 U3/U6, A04 §8 #1–#5) | **1 + 2** (parity 3) |
| **Sea** | `generator.cfg:5-6` Land uses `nowater2` (`land` path commented) ⇒ presence depends on map type; V-E13 three levels (−1.1 / −0.5 / −0.25 & −0.1, band 0.15 [D]); shore smoother 3× power 0.35 in 5×5 water neighbourhood; water id 255 hard, advisory water fraction `[0.05,0.45]` on `map_type=land`, water-free 64² ⇒ `RECORDED_NOT_APPLICABLE` (A05 S2); `sandsea1/5/6` ids 93/97/98 + 8×45° sector table (D06 §7.1); shader/plane landed, no foam texture (A04 E18/E19, D06 §6.1) | Pale desaturated water body; bright cyan foam band **slightly offshore**, never a white rim at the mathematical waterline; shore transition band continuous warm beach → bright foam → pale water with no hard classification-aligned edge; live shore-id histogram contains 93/97/98; no half-shore turned into blocked rock. Record foam peak RGB / water mean / alpha-at-waterline as **measurements with no pass verdict** (A04 §4.4/§4.5; D06 §6.1/DTRN-01 C15) | Whether the pale band in `maxresdefault_1.jpg` is sea, riverbank or wet sand (X07 U2/U9); runtime plane Y, `hmapTex` texture/FBO bind, reflection target, foam pixel width, metres-per-cell (D06 §11 #1/#5/#9); any donor pixel appearance (X07 U1) | **1 + 2** (parity 3) |
| **Rivers** | Only direct donor datum: `generator.cfg:62-64` `hint = 8.Rivers`, path `.\data\gen\terrainmasks.dlc5\rivers` (F03 §3.6/§7.1); no skirmish river pattern family decoded (A04 §4.9); no ford rule, `fordtyp` is formation type, bridges are objects + collision (D06 §8.2); S2/S3 can detect a water corridor but **cannot** distinguish river from sea (V-E04) | **None permitted that names "river".** If COORD puts DLC5 rivers in scope, the only legal internal property is "connected water corridor with the same shore band rule, no isolated puddles, no hard grid"; otherwise the class is reported `OUT_OF_SCOPE` with the two cited reasons above | River semantics, placement rule, width/depth thresholds (inventing a ford threshold is forbidden — D06 I11); whether any skirmish seed places rivers; all visual reference (X07 U5); DLC5 scope decision | **1 (mask path only)**; otherwise `OUT_OF_SCOPE` — parity 3 |
| **Swamps** | `generator.cfg:1290-1533` swamp_small 11 / swamp_big 2 / swamp_medium 20 = 33 refs (V-E08; F02 §5.4); `m_swamp_small_1` at `pattern.lib:913980+` is 16×13, `HeightFieldMin=Max=0`, `HeightFieldReplaceForWater=False`, Objects `bushes`/`fern` (A04 E21); global pass at `dogenerate.inc:1774-1906` (V-E11); port `donor_patterns.json` has **no** swamp/lake families ⇒ presence gate (A04 E22) | Organic soft-edged wet patch with reed/bush/fern fringe; **no water plane** (zero height field is donor truth); tile patch uses donor-derived ids only; no checkerboard, no synthetic noise field; scale histogram centred on donor object scaling where decoded (A04 §4.9, R10/R11) | Runtime activation of `[*] = ;` `.inc` lines (D07 U1); whether skirmish seeds place swamp stamps; `m_swamp_12_old` 17×20 vs 18×23 mismatch (F02 R4/U-F02-8); visual parity; adjacent `lake_big := plain*2*0` anomaly (A04 E20) | **1 + 2** (parity 3) |
| **Iron / coal mines** | No section name contains "mine"; nested props `minegold/mineiron/minecoal` in `mng_1..5/mni_1..5/mnc_1..5` (`pattern.lib:713410,715244,716910`; V-E06); mng/mni/mnc 6 cfg records each, `Freq=0` base + 5 live (`generator.cfg:69-140`; V-E08); `SetupMines` ring→ore→256 tries, rounds 3/4/5, bands `14+8R/32+10R/70+12R/22+16R` with version gate and corner relocation (D07 §3.2–3.4); near call `(0,1)`, global `(1,0)`; resource ids gold 4/iron 5/coal 6 (V-E12); mesh scale 0.3152 no jitter, 5×5 dirt plate (A04 E14/E25); asset presence `mine_gold/iron/coal` + built mines | Deposit mesh visible on its olive/beige ground disc; built mine centred on it; no mine without a deposit in range; 5×5 dirt plate centred; no concentric deposit rings; ore differentiation by material only (meshes byte-identical — `PORT APPROXIMATION`); count stream stable under D1 | Which ore a still shows (X07 U8 gold inferred from icon/text; U4 iron/coal none); finite deposit amount (D07 U3); magnetic snap activation (D07 U1, A04 §8 #7); record-id→prop binding (D07 U7, A04 §8 #11); native `SetupMines` method (D07 U2); small-map ring-2 stale-`dst` quirk (D07 U6); A05's "≈9 sites/start" is a **port belief**, not a donor range; visual parity | **1 + 2** (parity 3) |

**Adjacent class, compact note (`[D]/[I]`).** "Stone quarries" has no literal donor asset:
a read-only filename scan for `quarr` returns 0 hits (A04 E26). Structural evidence is
`stones` 7 records / `stoneforests` 8 records (`generator.cfg:802,876`), `stn1=0.00016`,
`stn2=0.00012`, scale 0.329 ±15% (A04 E20/E23). Self-consistent cue: clustered boulders
inside the stamp footprint, no radial rings, no single-rock grid. The "quarry ↔ stones"
mapping stays `[D]/[I]`; A0's stone reference is snow-confounded (X07 §6 risk 4).

---

## 5. Multi-pass adjudication of contradictory evidence

Owner directive (CHARTER §4): re-run with a second instrument or second reading, record
every pass, then accept or mark `[U]`. Each subsection below is one class's ledger.

### 5.1 Mountains — "all mountain grids are zero" is not blanket-true

| Pass | Instrument / source | Result | Accepted? |
|---|---|---|---|
| M1 | A04 E02 / `pattern.lib:337491-337492`; F02 §5.8 | `g_mnt_1` `min=max=0`, 43×38, all-zero decoded grid | Accepted for `g_mnt_*` / `desert_mnt_*` only |
| M2 | F02 §5.8 `i_mnt_big_1` | Non-zero window −0.641090035438538…+0.464331328868866 | Contradiction to M1's blanket wording |
| M3 | F02 §5.3 / §5.4 | `i_mnt_*` are among 217 sections reachable by **no** `generator.cfg` family; family rollup counts only `mountains` 7 + `desert_mountains` 13 | Accepted: likely editor brushes `[I]`, not skirmish stamps — still `[U]` for runtime use |
| M4 | A04 E03/E04 + Z03 §1.2/Z06 §1 | 112 prop records / 30 sections; `terrainmeshN` z span 6.93–9.55 donor units; `BaseName = terrainmesh4` in `g_mnt_1` | Accepted: silhouette is channel P, not height |
| M5 | X07 §3 A6 full frame + upscaled `highlands_check.png` | No mountains or meaningful hills; filename is marketing | Accepted: image excluded from all mountain evidence (U3/U6) |

**Final reading:** structural verdict may cite M1/M3/M4; M2 prevents the sentence
"every mountain pattern has a zero grid". Visual silhouette is tier 2 only.

### 5.2 Sea — three "water levels" and a smoothing-count contradiction

| Pass | Instrument | Result | Accepted? |
|---|---|---|---|
| S1 | D06 §3.1 `generatemap.inc:7` vs `:688,704` vs `texturemap.inc:29-31,463-472` | −1.1 basin, −0.5 generated field, −0.25 water / −0.1 wet-shore classification | Accepted as three distinct roles; conflating them is an error |
| S2 | D06 §3.3 shader wet/dry test `water.dev.frag:167-199` | Plane Y is engine-supplied; `waveheight = clamp(3Y−1.5,0,1)` is 0 for the recovered −0.5/−0.25 ⇒ coarse swell exactly zero | Accepted: do not claim visible coarse swell from −0.5 |
| S3 | F03 §3.1/§9 F3 + D06 P22 | `TileSmoothPasses = 6` in cfg vs `SmoothTileMap(...,3)`; no consumer of the 6 found | Preserved as `[U]` contradiction; harness uses 3, never silently adopts 6 |
| S4 | D06 §4.1 vs §4.2 | Shore *height* smoothing 3× power 0.35 (radius 2) is a different chain from *tile* smoothing 3 sweeps | Accepted as separate rules |
| S5 | X07 §3 A11 `shore_check.png`, A5 `top_water_check.png` | Pale band + ship silhouette; water body identity not certifiable | Accepted as `[U]`; no sea gate from stills |

**Final reading:** sea structure is verifiable (ids, bands, smoothing, water fraction);
sea *identity* and appearance are not.

### 5.3 Rivers — mask path exists, placement rule does not

| Pass | Instrument | Result | Accepted? |
|---|---|---|---|
| R1 | F03 §3.6 `generator.cfg:62-64` | `hint = 8.Rivers` → `terrainmasks.dlc5\rivers` | Accepted as literal DLC5 mask path only |
| R2 | A04 §4.9 | No skirmish river pattern family decoded; "treat rivers as out-of-scope `[U]` unless a separate DLC mask ticket lands" | Accepted as current scope ruling `[I]` |
| R3 | D06 §8.2 | No ford generator; `fordtyp` is a squad formation field; bridges are objects + collision tag 10 | Accepted: no invented ford threshold |
| R4 | D07 §3.10 pass order | Shore collision at `:2068`, no river placement stage | Corroborates R2/R3 |

**Final reading:** river class is `OUT_OF_SCOPE` with two citations unless COORD opens a
DLC5 ticket; no visual criterion is drafted for a class with no placement rule.

### 5.4 Swamps — authoring data vs one mismatched record

| Pass | Instrument | Result | Accepted? |
|---|---|---|---|
| W1 | A04 E21 `pattern.lib:913980+` | Swamp `HeightFieldMin=Max=0`, bushes/fern, no water plane | Accepted; a water plane over a swamp would be fabricated |
| W2 | F02 §5.8 / R4 | `m_swamp_12_old`: lib 17×20, binary 18×23 | Preserved as anomaly; strict validator must declare a policy, not "fix" the number |
| W3 | F03 §7.3 + F02 §5.4 | 11 + 2 + 20 = 33 swamp refs joined to sections | Accepted as donor-grounded count |
| W4 | A04 E22 | Port `donor_patterns.json` has no swamp/lake families | Accepted as conversion gap; class presence gate fails until exported |
| W5 | A04 E20 / D07 V1 | `swamp_*` frequency lines are `[*] = ;`; `lake_big := plain*2*0` literal zero | Accepted as text intent; activation `[U]`; do not "repair" the zero |

**Final reading:** structure tier 1 available after W3/W4 pass; visual tier 2 limited to
the no-water-plane organic patch cue; all five items in §4 stay tier 3.

### 5.5 Iron/coal mines — three conflicting count claims

| Pass | Instrument | Result | Accepted? |
|---|---|---|---|
| I1 | A05 S7 (`donor_gen.py:49-59`) | "gold/iron/coal ≈9 sites per start (3 kinds × 3 rounds, `[6,9]`)", ring peaks 28–44/64–84/100–124 cells | Label `[D]`/`[I]` **port belief**, not a donor range |
| I2 | D07 §3.2–3.4 (`dogenerate.inc:544-553,595-601`) | Loop is ring → ore → 256 tries; 14–22/32–42/70–82/22–38 are **ring radii shared by all three ores**, with `3/4/5` rounds by density and corner relocation at `v>=90` | Accepted as authority; I1's per-ore grouping is refuted; I1 band never promoted to `red` |
| I3 | F03 §7.2 note "mng/mni/mnc = market/iron/coal? `[U]`" | Family name alone ambiguous | Rejected as sole semantics |
| I4 | F02 §5.3 (`pattern.lib:713410,715244,716910`) + D07 §3.8 | Nested `BaseName = minegold/mineiron/minecoal`; resource ids 4/5/6 | Accepted: ore family binding is `[O]` from nested objects; "gold" label still `[I]` for a specific still (X07 U8) |
| I5 | A04 E14/E17 + D07 §3.8/U3 | Shared mesh byte-identical, scale 0.3152 no jitter; port richness clusters + 11-tile separation; no deposit capacity | Accepted: port placement is documented `PORT APPROXIMATION` divergence; no capacity invented |

**Final reading:** only I2/I4/I5 support tier 1. A05's S7 band must be rewritten as
advisory before any owner-facing claim.

### 5.6 Cross-cutting: the "highlands" false positive

Two passes (X07 §3 A6: full frame + `highlands_check.png`) found stone construction and
conifers, **no mountains**. A6 stays ranked for stone/decor only (X07 §4). Any capture
review that cites this filename as mountain evidence is a defect; any mountain fixture
that yields `matched_stamps = 0` is a vacuous PASS and must be rejected (A04 R2).

---

## 6. Final owner-facing report template

Fill one instance per capture batch. It reuses A05's `terrain_qa_report/1` field
separation (V-E19); metric and visual fields are never merged. No field may contain a
donor-parity claim or a reference image path presented as evidence.

```text
---
schema: terrain_qa_report/1
run_id: V15-<timestamp>
worker/reviewer: <capture worker> / <independent second reader>
created_utc: <...>
swarm: TERRAIN-SWARM-2026-11-26
labels: [O, D, I, U, PORT APPROXIMATION]
parity: {claim: NONE, status: UNVERIFIED}
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity
  UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity
  nor a gate pass."
---

# Owner-facing acceptance — landscape classes with no donor visual reference

## 1. Scope and class mapping
  in_scope: [mountains, sea, rivers, swamps, iron_coal_mines]
  out_of_scope: [rivers]  # only if COORD has not opened the DLC5 rivers ticket; cite §5.3
  excluded_from_this_report: [hills, fields, conifer_forest, gold_mine]  # X07 §4 has refs
  reference_images_used_as_evidence: NONE
  parity_metric_used: NONE

## 2. Key manifest (pinned)
  generation: {random_seed, map_w, map_h, map_type, start_option, nations,
               start_resources, deposits, relief_stamps, seed_keys_sha256}
  capture: {pitch_degrees, fov_deg, start_zoom, pixels_per_meter, window}
  config_sha256: <...>   overlay_sha256: <...>
  evidence: A05 §2.1; spec/12 §12.6

## 3. Gates (status / policy / threshold / observed / labels / evidence)
  D1_within_size_64_240_320: PASS|FAIL   # zero byte difference, hard
  D3_run_integrity:         PASS|FAIL   # status, script_error_lines, assert_clean
  S1..S7_advisory:          PASS|FAIL|UNVERIFIED|NOT_APPLICABLE|RECORDED_NOT_APPLICABLE
  policy: advisory   # red only after signed donor spec + COORD sign-off
  regression: {selftest: 29/29, uitest: 17/17, t_render_mode: PASS,
               assert_clean: CLEAN, app_sha256_unchanged: true}

## 4. Per-class verdict table (one row per class)
| Class | Tier-1 evidence (path:line / id) | Tier-1 verdict | Tier-2 property + ROI | Tier-2 verdict | Metric field (separate) | Visual field (separate) | Declared UNVERIFIED (why / passes / settles by) |
|-------|----------------------------------|----------------|-----------------------|----------------|--------------------------|--------------------------|--------------------------------------------------|
| mountains | pattern.lib:337461-340273; generator.cfg:660; A04 E03/E08 | DONOR-GROUNDED STRUCTURE VERIFIED or FAIL | silhouette ON/OFF, no rings/veins; ROI <...> | SELF-CONSISTENT VISUAL or FAIL | <ON/OFF changed px, rise px, outside %> | <reader prose, no parity word> | <list from V15 §4> |
| sea | generatemap.inc:7,688-707; texturemap.inc:463-529; A05 S2 | ... | shore band beach→foam→water; ROI <...> | ... | <foam peak RGB, water mean, alpha (no verdict)> | <reader prose> | <X07 U2/U9; D06 §11> |
| rivers | generator.cfg:62-64 only | DONOR-GROUNDED STRUCTURE VERIFIED (mask path) or OUT_OF_SCOPE | none permitted / connected corridor only if in scope | UNVERIFIED or N/A | <none> | <reader prose> | <no placement rule; D06 §8.2> |
| swamps | generator.cfg:1290-1533; pattern.lib:913980+; A04 E22 | ... | soft wet patch, no water plane; ROI <...> | ... | <tile-id patch counts> | <reader prose> | <activation, mismatch, parity> |
| iron/coal mines | pattern.lib:713410/715244/716910; generator.cfg:69-140; dogenerate.inc:522-717 | ... | mesh on disc, built centred, no orphan mine; ROI <...> | ... | <deposit counts per D07 rings> | <reader prose> | <ore type, capacity, snap, parity> |

## 5. UNVERIFIED register
  declared_unverified: [<one item per class from V15 §4, with reason + pass ids>]
  blocking_unverified: []            # must be empty for owner acceptance
  rule: non-empty blocking_unverified => RESULT IS NOT GOOD; hold/rollback per A05 §6

## 6. Rollback
  triggered: true|false
  reason: <hard FAIL / dirty runner / app hash drift / donor-parity wording / etc.>
  restored_to: <inbox/backup/<file>.bak-<id>>   # COORD only; no git reset --hard

## 7. Overall verdict (choose exactly one)
  RESULT IS GOOD — DONOR-GROUNDED STRUCTURE VERIFIED + SELF-CONSISTENT VISUAL;
                   donor parity UNVERIFIED (declared, accepted)
  RESULT IS NOT GOOD — <one blocking item; rollback/hold>

## 8. Sign-off
  capture worker: <...>   independent visual reader: <...>   COORD: <...>
  no donor binary executed: true   no donor file copied: true
  no reference image invented: true   no parity metric invented: true
```

**Template invariants:** every numeric claim carries `labels` + `evidence`; tier-3 items
never become PASS; `parity.status` is always `UNVERIFIED`; the reviewer line is verbatim;
a green metric cannot erase a visible ring/vein/grid and a red metric cannot invent one
(A05 §4.2.4; X07 §6 risk 8).

---

## 7. Risks

| # | Risk | Label / evidence | Mitigation |
|---|---|---|---|
| R1 | A "no visual reference" verdict is misread as "no acceptance possible" | `[I]`, X07 §7 | Use §2 tiers: structure and self-consistency are still hard checks; only parity is barred |
| R2 | Tier-2 self-consistency is quietly promoted to donor fidelity | `[U]`, A05 E09/E12 | Fixed vocabulary; `parity.claim = NONE`; reviewer line verbatim |
| R3 | Advisory bands (A05 S2/S3/S7) harden into red gates without donor spec | `[D]/[I]`, A05 §3 | Keep `--policy advisory`; D07 refutation of S7 recorded in §5.5 |
| R4 | "Highlands" wallpaper or A0's gold mine is cited as evidence for a different class | `[O]`, X07 U3/U6/U8 | Class→image map is locked (X07 §4); per-class rows cite only donor paths |
| R5 | Sea/river/swamp conflated because three water levels or mask types look alike | `[O]/[D]`, D06 §3.1, F03 §3.6 | §5.2/§5.3 multi-pass; class rows keep separate water semantics |
| R6 | Swamp receives an invented water plane or lake receives a fabricated window | `[O]`, A04 E21/E22/R10 | Zero grid is donor truth; lake window must be byte-derived (F02 §5.8) |
| R7 | Mine type/count asserted from a still or from A05's port belief | `[I]/[U]`, X07 U4/U8, D07 §3.11 | Nested `BaseName` + cfg counts are structural; ore-in-still stays UNVERIFIED |
| R8 | Missing QA evidence hidden by a declared parity gap | `[I]`, A05 §5 G4 | `declared_unverified` vs `blocking_unverified` split; owner signs both |
| R9 | Contradictions silently resolved for convenience (`TileSmoothPasses`, `m_swamp_12_old`, `mng` naming, ring-2 quirk) | `[O]/[U]`, F03 §9 F3, F02 R4, §5.5 | Preserve literal, mark `[U]`, record passes; no threshold lowered |
| R10 | ROI transfers onto HUD/units and a reviewer "reruns until green" | `[I]`, X07 §6 risk 7; A05 §4.1 | G0-e identical ROI on both sides; failed ROI ⇒ UNVERIFIED, not retry |
| R11 | No QA atom result for the landed mountain props ⇒ vacuous PASS | `[O]/[U]`, A04 E10/R2 | `matched_stamps>0` setup guard + ON/OFF pixel A/B; zero-stamp capture rejected |

---

## 8. Open questions

1. **Q1 (COORD):** approve the `declared_unverified` / `blocking_unverified` split in §2?
   Until approved, the conservative reading marks the owner result `RESULT IS NOT GOOD`
   because every class has a declared parity gap.
2. **Q2 (COORD/F10):** are DLC5 `lakes`/`rivers` masks (F03 §3.6) in scope? If not,
   rivers stay `OUT_OF_SCOPE` with the §5.3 citations; if yes, who supplies the
   placement rule that A04 §4.9 says is missing?
3. **Q3 (D02):** does `SetRandomKey(randkey1)` reset idempotently (D07 §3.10 ⇒ D07 Q3)?
   Stage-by-stage determinism is a structural gate for all five classes.
4. **Q4 (D08/F01):** can the native `StandPatternWithAngle` transform and the deposit
   record-id→prop binding be recovered, converting two mountain/mine tier-3 items to
   tier 1?
5. **Q5 (F08):** is `mng` definitively the gold family (F02 nested `minegold` objects)
   or does F03's "market?" reading survive for some build? §5.5 I4 currently wins on
   nested-object evidence but the label remains `[I]` for a specific still.
6. **Q6 (D05/A04):** can a donor `.pattern`-derived mountain silhouette be accepted on
   height-window evidence alone (`g_mnt_*` are zero; props carry relief), or is an
   almanac/manual still required? X07 Q4 is still open.
7. **Q7 (A05/P03):** which map size is canonical (240² vs 320²) and who supplies the
   240²/320² overlays? A wrong canonical size would make determinism runs identical.
8. **Q8 (owner):** is a genuine donor GPU A/B frame obtainable at all? Until it is,
   no tier above 2 exists and every owner-facing verdict must say donor parity UNVERIFIED.

---

## 9. Claim register

| # | Claim | Source | Label |
|---|---|---|---|
| 1 | Stills give no reference for the five classes; "highlands" is a false positive | X07 §0/§4/§7 | `[O]` |
| 2 | Structure can be verified from pattern.lib / cfg / scripts / asset presence / dumps | V-E03…V-E13 | `[O]/[D]` |
| 3 | Silhouette, shore band and mine mesh are checkable self-consistently | A04 §4.2/§4.4/§4.5/§4.8; V-E18 | `[D]/[I]`, PORT APPROXIMATION |
| 4 | Three-tier vocabulary is sufficient and parity is always UNVERIFIED | §2; A05 §4/§7 | `[I]` design |
| 5 | A05 S7 mine band is a port belief superseded by D07's ring reading | §5.5 I1/I2 | `[D]` |
| 6 | Rivers have a DLC5 mask path but no skirmish placement rule | §5.3 R1–R4 | `[O]/[I]` |
| 7 | Every owner-facing capture must keep metric and visual fields separate | A05 §4.2.4/§7 | `[O]` |
| 8 | **No donor parity claim is made anywhere in this report** | CHARTER §4; this §9 | `[U]` |

---

*End of V15. Exactly one report file written; no code, asset, config, test, shader,
fixture, runner-job or git edit; no donor file executed or copied; no reference image
or parity metric invented; no donor-parity claim.*
