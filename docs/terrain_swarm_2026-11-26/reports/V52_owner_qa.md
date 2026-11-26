---
id: V52
ticket: "TERRAIN-SWARM-2026-11-26 / V52 — owner QA: answer the owner's likely questions with brutal honesty, from landed reports only"
title: "V52 — owner-facing Q&A: what was decoded, what is built, what is *not* proven"
agent: "V52 (read-only owner-QA subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V52_owner_qa.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V52_owner_qa.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists, no donor binary was executed by any worker, and no gate result is asserted here. Nothing in this report is a PASS or a donor-match claim."
scope_guard: "Read-only. Drawn ONLY from landed reports and swarm docs; no source, shader, asset, config, test, result JSON, git, runner or Godot state touched; no donor file opened. V49_licence_credits.md and REPORT_INDEX.md were absent at the V52 snapshot; both have since landed (V67 glob) and are cited here only for point-in-time file presence/counts, never as a gate PASS. The earlier absence was point-in-time only."
sources_read: "CHARTER.md, SWARM_BOARD.md (V45 filesystem-authoritative refresh), HANDOFF.md (V29 draft), README.md, IMPLEMENTATION_PLAN.md, spec/README.md, reports/X27_decode_coverage.md, reports/V15_acceptance_without_reference.md, reports/X07_visual_reference_index.md, reports/V36_integration_checklist.md, reports/V42_gate_commands.md, reports/F10_dlc_terrain.md; other landed reports consulted via those documents' cited evidence tables (X01/X02/X03/F01–F06/D01–D08/A04/A05/V11/V16/V17/V21/V26/V28)."
multiple_passes: true
multiple_pass_note: "Point-in-time claims were cross-read in at least two landed documents each; where documents disagree (V36 09:52 snapshot vs the later V45 board refresh; HANDOFF 09:47 snapshot vs V36), BOTH readings are preserved and the later filesystem-authoritative board is used only for file presence — never as a gate pass or a proof that a defect was repaired. No claim here is promoted on one reading."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# V52 — Owner Q&A (brutal, report-grounded)

## 0. How to read this

Each answer below is a direct reply to the question the owner is most likely to ask.
Every load-bearing statement is cited to a **landed** report or swarm document. The
verdict vocabulary is V15 §2's three tiers only:

1. **DONOR-GROUNDED STRUCTURE VERIFIED** (a cited donor datum matches a port byte/count/id/hash **and** dump integrity D3 holds);
2. **SELF-CONSISTENT VISUAL** = `PORT APPROXIMATION` (admissible capture, property named from a donor rule, measured only inside the candidate);
3. **UNVERIFIED** (no admissible datum, or contradictory/unavailable evidence after ≥2 passes).

**No tier above 2 exists in this vocabulary.** A tier-1 or tier-2 *evidence preparation*
is not a signed verdict; there is no achieved tier-1 or tier-2 result today
(`HANDOFF §0/§3`, `V15 §2`). "Decoded" never means "matched"; "converted asset exists"
never means "feature runs"; "file present" never means "gate PASS"
(`X27 §1/§4`, `SWARM_BOARD` §Integration gates).

---

## Q1 — "Did you decode every single bit of the donor?"

**Answer: No. That was never achievable under this charter, and it did not happen.**
The instruction was executed as a *targeted, read-only* decode of terrain-relevant
artifacts, not a literal whole-donor decode (`X27 §0`, `CHARTER §2/§4`).

- **Honest ceiling (`X27 §0/§5/§7`):** high coverage of terrain-relevant **data**, medium
  coverage of terrain-relevant **code**, near-zero coverage of runtime **activity**.
  The realistic maximum under read-only/no-execution rules is "all readable
  terrain-relevant data bytes + on-demand instruction reads of named functions", with
  every runtime-dependent claim permanently `[U]` / `PORT APPROXIMATION`.
- **Data that *is* byte-exact (`X27 §2 E9–E14, §7`):** 710/710 `.pattern` files
  (closure `8+4wh+54(w−1)(h−1)`, zero residual; 678/680 min/max exact), `pattern.lib`
  plaintext (680 sections, 30,309,138 B, 39,780 object records, 235 `BaseName`),
  4,466 terrainmask TGAs (1,331 vanilla + 1,856 dlc5 + 1,279 src, `h=−1.1·B/255`),
  7 cfg files fully parsed, 124 tile ids/season, both water/tile shader sources, the
  37-byte `.map` record and the exact 32-bit LCG.
- **Garbled percentages — quote these, never the raw export totals alone (`X27 E1/E3`,
  §3.1, §6 C9, §8 R1):** `cossacks.exe` 18,918/18,918 **discovered** functions exported,
  of which **4,265 (22.54%)** are unstructured; `editor.exe` 22,384/22,384 exported,
  of which **12,254 (54.7%)** carry ≥1 garble marker (559 with ≥1,000). "18,918/18,918"
  is honest only *over discovered functions*: **11 of 34** D01 terrain anchors are
  present, **23 absent**; ~45/64 class constructors stay `[U]`.
- **Packed stubs (`X27 §3.1, §4 Category B`):** both binaries carry a packed/obfuscated
  `.bind` section (cossacks entropy **7.96**; editor VA `0x76f000`, size `0x23d70`,
  with a `VirtualAlloc(RWX)` unpack-staging hint). It was **never unpacked or executed**;
  a possible secondary stamp path, mesh builder and RNG code are beyond the corpus.
  "Absence is not proof" — it is `[U]`, not "absent" (`X27 R6`).
- **Runtime intent vs execution — the single biggest categorical gap (`X27 §0/§4/§7`,
  `HANDOFF §1`):** all **972** X03 verbatim `.inc` excerpts and all F03 cfg literals are
  `;`-prefixed *intent*. Every worker records execution in the shipped EXE as
  `[U] CONFIRMED_UNVERIFIED`; no decoded value was ever observed being consumed by a
  compiled path. Also native kernels (`SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`,
  `WaterFieldAdd`), `bmTransparency` pass count (unresolved after six X17 passes),
  `hmapTex` binding/plane Y, `.pattern` field semantics and `.map` tag semantics remain
  `[U]` after multiple passes.
- **Effectively untouched classes (`X27 §0/§3.3/§4`):** `config.exe` / `modman.exe`
  (only one RNG byte cross-check each), `cdx` (zero mentions in the whole corpus), the
  packed `.bind` stubs, and the 49 baked DLC mission `.map` files (2.877 GiB,
  deliberately deferred as closed campaign snapshots with no generator delta, `F10 §0`).
- **Consequence (`X27 §4`):** a port can be *structurally* faithful to decoded text yet
  behaviourally divergent in everything that depends on execution. Multi-pass work on
  contradictions is logged in `X27 §6` (C1–C10) — nothing was silently skipped.

**Owner-facing line:** "We decoded the terrain-relevant data thoroughly and a small set
of functions at instruction level. We did not decode every bit, cannot while the donor
is read-only and un-executed, and never claim a donor match."

---

## Q2 — "Is terrain now cloned?"

**Answer: No. The fresh module is partly built, wired behind a default-legacy switch,
contract-repaired but ungated, and no gate has been run on it.**

- **Current implementation state (`V36 §1/§3`, `SWARM_BOARD` V45 refresh):** the seam is
  LANDED and single-applied (`main.gd:125,189-191,593-594,1112-1113`;
  `world3d.gd:118,144-145,220-224,624,645,706-707`), with SHA-verified
  `.bak-COORD-I11` backups; decoders I01–I04, atlas compiler I05, modules I06–I10,
  composer N14, test I12 and harness/spec I13 are on disk. The later board refresh
  records all I-wave files present (its shader path is the canonical
  `terrain_donor_shader.gdshader`, differing from V36's 09:52 alias snapshot — presence
  only, no correctness implied). Absent/undone at last audit: `assets/terrain_new/**`
  generated atlas outputs, `inbox/qa/terrain_qa_report.json` + `inbox/qa/captures/`,
  I12's manifest registration (still 40 tests), and a variant-local `terrain_qa_spec.json`.
- **Default-legacy seam (`HANDOFF §2.3`, `V36 §1.1/A17`):** `terrain_backend` defaults to
  `"legacy"` in `main.gd:125` / `world3d.gd:144`; `world3d.gd:108` still uses
  `TERRAIN_SCRIPT = "res://scripts/world3d_terrain.gd"`; the ternary at `:624` picks it
  unless `"donor"` is explicitly selected. `config.gd`/`config.json` contain **no**
  `features.terrain.backend` key, so stock config cannot opt in (`V36 A17`, P11). Late
  switching is refused after `bind()` (`world3d.gd:220-224`).
- **API breaks from V36 — repaired at the contract level (`V36 §1.4, §4 A4–A6/A11–A12/A14,
  §5 C2–C5`; `V61 §1/§3`, `V65 §0/§3–§6`):** at V36's 09:52 snapshot the chain was **not
  composable** — (a) composer→I07 passed a game `Object` where `generate(data:
  C3TerrainData, p: Dictionary)` requires a Dictionary; (b) composer→I09 called `bind()`,
  which I09 does not define (`build(...)` only); (c) composer→I08 passed the bare I06
  Object to a Dictionary-only ingest; (d) I12's hook called `generate(SEED, GEN_KEYS,
  size, size)` and treated I07's telemetry as a container/dump. V48's four caller-side
  patches are present in the current bytes; V61 and V65 give **static PASS** on all six
  audited pairs (type, arity, contract). **A static PASS is NOT a gate PASS and proves no
  streams were produced**: no Godot parse, stream assertion or gate has run. The backend
  is **ungated rather than proven inert**; decoded donor inputs are still unwired
  (`gen_params={}`), and `gen_applied` / `mesh_built` / `props_applied` assertions remain
  mandatory (`V61 §5`, `V65 §9`).
- **No gates run (`V36 §1.6/§6`, `HANDOFF §4`, `SWARM_BOARD` §Integration gates, `V42 §0`):**
  gate JSONs on disk are stale (2026-11-25); `assert_clean --json` is `DIRTY` because
  575/582/585 remain unacked; no fresh 240²/320² baseline or admissible capture; the
  relief-props atom (A24) was a hard FAIL at HANDOFF snapshot (`t_relief_props_qa.gd:30`
  pointed at absent `terrainmesh_props.json`); all gate verdicts in `HANDOFF §4` are
  `TODO(COORD)` placeholders, never invented PASSes. V42 submitted **zero** runner jobs.
- **Verdict:** `RESULT IS NOT GOOD` is the conservative owner reading, because
  `blocking_unverified` is non-empty (no D3 dump integrity, no admissible capture,
  dirty runner, unresolved numeric contradictions) even though the declared parity
  gaps are accepted (`HANDOFF §0/§5`, `V15 §2` Q1; `V21 §10` Q7).

**Owner-facing line:** "Not cloned. A fresh donor-shaped pipeline is scaffolded behind a
legacy-by-default switch; its API contracts are repaired and statically PASS per V61/V65,
but it is ungated with no streams proven; no donor parity is claimed."

---

## Q3 — "Are hills / mountains / fields / sea / shore / forests / mines there?"

**Answer: every class has *decoded donor evidence* and *drafted acceptance criteria*,
but no class has an achieved tier-1 or tier-2 verdict, and none reaches donor parity**
(`HANDOFF §3`, `V15 §2/§4`, `X07 §4`). Reading rule: tier-1 evidence is prepared but
**unsigned because D3 dump integrity has not been run**; tier-2 criteria are drafted
but **unobserved because no admissible capture exists**; tier 3 is declared, not a gate
failure by itself.

| Class | Donor structure prepared (tier 1, unsigned) | Visual criteria (tier 2, PORT APPROXIMATION, unobserved) | Honest tier today | Must stay UNVERIFIED |
|---|---|---|---|---|
| **Hills / rolling relief** | A7/A5 stills only as `[D]` direction cue (`X07 §4`); relief grid decode D05/X12/X13; height shared with mesh (I08) | Readable mounds; no concentric rings / diagonal vein lattice / flat-only mound; ON/OFF pixel change | donor datum `[D]`; **visual UNVERIFIED** | donor appearance; camera/zoom unknown; no A/B frame |
| **Mountains** | `pattern.lib:337461-340273` `g_mnt_1` 43×38 all-zero + `BaseName=terrainmesh4`; `mountains` 7 / `desert_mountains` 13 families; 112 prop records / 30 sections; 4 converted `relief` assets | Silhouette ≥ centre +4 m, footprint +2 m; props ON/OFF ≥200 px, ≥8 px rise, <1% outside; `matched_stamps>0`; no rings/veins | tier-1 prepared; **tier-2 not observed**; parity 3 | donor silhouette; `terrainmeshN` chooser; yaw/metres-per-unit; prop rendering has **no QA atom result**; "highlands" wallpaper is a **two-pass-confirmed false positive** (`X07 U6`) |
| **Mill fields** | `generator.cfg` field families; A1/A3 stills `[D]` high for class shape; X22 verbatim `_unit_DoSeedWheat` + decal binding; **no food rects** in `SetupStartingResources` | Golden L/rectangular parcels with windmill footprint, no checkerboard, no synthetic dither | tier-1 prepared; **tier-2 not observed**; parity 3 | donor pixels; runtime activation of commented callers; season confound in A0 |
| **Sea** | `generator.cfg:5-6` `nowater2` for land maps; four water literals (−1.1/−0.5/−0.25/−0.1); water id 255; shore ids 93/97/98; shader/plane landed, no foam texture | Pale water body; foam **slightly offshore**, not a white waterline rim; continuous beach→foam→water band; foam metrics with **no pass verdict** | tier-1 prepared; **tier-2 not observed**; parity 3 | whether A11's pale band is sea/riverbank/wet sand (`X07 U2/U9`); plane Y, `hmapTex`, foam width, metres-per-cell; no donor still |
| **Shore / beach** | 8×45° `sandsea1/5/6` table; shore height smoother 3× power 0.35; `bmTransparency` crossfade confirmed at instruction level (X17) | Continuous warm beach → bright foam → pale water, no hard tile-aligned edge; no half-shore turned into blocked rock | tier-1 prepared; **tier-2 not observed**; parity 3 | donor pixels; pass count / `hmapTex` bind `[U]` after six passes; X11 missing stages |
| **Forests (conifer / mixed)** | Forest families/weights decoded (F08/F03); A10 high-confidence conifer, A7 groves on hills | Natural tree spacing, grove edge transitions, no grid; donor lighting shadows only | tier-1 prepared; **tier-2 not observed**; parity 3 | donor foliage pixels; two donor-authored forest-interior lists; A9 low detail |
| **Stone quarries** | **No donor asset named `quarr` (0 hits)**; `stones` 7 / `stoneforests` 8 records, `stn1=0.00016`, `stn2=0.00012`, scale 0.329 ±15% — mapping is `[D]/[I]` | Clustered boulders inside stamp footprint, no radial rings, no single-rock grid | **donor structure PARTIAL `[D]/[I]`**; tier-2 not observed; parity 3 | quarry↔stones identity; A0 snow confound; A6 is built masonry, not a quarry |
| **Gold / iron / coal mines** | Nested `minegold/mineiron/minecoal` in `mng/mni/mnc`; 6 cfg records each; ring→ore→256 tries; resource ids 4/5/6; mesh scale 0.3152, 5×5 dirt plate; **no finite deposit capacity** | Deposit mesh on centred disc, built mine centred, no orphan/concentric rings; ore differentiated by material only (meshes byte-identical — `PORT APPROX`) | tier-1 prepared; **tier-2 not observed**; parity 3 | which ore a still shows (A0 gold is `[I]` from icon/text; **no identifiable iron/coal reference** — `X07 U4/U8`); capacity, snap, record-id binding |
| **Swamps / lakes** | `generator.cfg:1290-1533` swamp 11+2+20=33 refs; zero height field with bushes/fern, no water plane; global pass in `dogenerate.inc` | Organic soft-edged wet patch with reed/bush/fern fringe, **no water plane**; donor-derived tile ids; no checkerboard/noise | tier-1 prepared; **conversion gap — presence gate fails until exported**; parity 3 | `[*] = ;` activation; `m_swamp_12_old` 17×20 vs 18×23 PRESERVED; `lake_big := plain*2*0` must not be "repaired"; no still |
| **Decor (towers/windmill/village/camp)** | A7 watchtowers, A1 windmill, A6 stone structures over-represented in corpus; decal/prop records decoded | Silhouettes only, no terrain-class claim; no HUD/unit ROI contamination | `[D]` from stills (direction only); parity 3 | donor pixel identity; third-party build/camera unknown |
| **Rivers (scoped out)** | Only `generator.cfg:62-64` `hint=8.Rivers` → `terrainmasks.dlc5\rivers`; no skirmish placement rule; `fordtyp` is a formation type, not a generator | **None permitted that names "river"** | **`OUT_OF_SCOPE`** pending COORD/F10 (`V16 O2`) | all river semantics/width/depth; inventing a ford threshold is forbidden |

Multi-pass adjudications behind this table are in `V15 §5` (mountains M1–M5, sea S1–S5,
rivers R1–R4, swamps W1–W5, mines I1–I5, "highlands" false positive) and `X07 §4/§7`.
**No row says "there" in the sense of a verified, rendered, donor-matching feature.**

---

## Q4 — "Why is there no donor A/B screenshot?"

**Answer: no such frame exists and none may be invented; the available stills cannot
support it.** This is an *epistemic ceiling*, not a decode defect (`X27 §5 #10`, `V15 §0`).

- **No donor GPU frame:** no donor binary was executed by any worker, so no matched-seed
  donor frame was captured; `parity.claim = NONE`, `parity.status = "UNVERIFIED"` by
  construction (`HANDOFF §5 #1`, `V15 §2`, `V42` parity guard). The reviewer line at the
  frontmatter is mandatory verbatim in every owner-facing capture.
- **The 12 stills are third-party, not donor captures (`X07 §0/§6 U1`, `HANDOFF §5 #2`):**
  all files in `C:\Users\Maxym.Oboyshev\Downloads\c3\` are of **unknown donor build,
  camera, zoom, world area and JPEG/WEBP compression** (11 JPEG, 1 WEBP, several
  YouTube-derived thumbnails). They support **direction of movement on matched
  fractional ground ROIs only** — never parity, never "matches / close to donor", never
  a numeric gate threshold. A fractional ROI landing on sky/HUD/units is UNVERIFIED,
  **not** retried until green.
- **No reliable mountain / sea reference (`X07 §4/§7`, `V15 §0/§4`):** no image shows
  mountains; `cossacks-3-guardians-of-the-highlands-...wallpaper-3.jpg` is a stone
  construction scene on two passes (filename is marketing). No unmistakable river or
  swamp; no identifiable iron/coal mine (A0's is an inferred **gold** mine from icon +
  on-screen text). The best "shore" candidate `maxresdefault_1.jpg` cannot certify sea
  vs riverbank vs wet sand.
- **No port-side capture either:** no admissible 1280×720 windowed non-blank capture, no
  frozen 240²/320² baseline, and the canonical size itself is unresolved (both 240² and
  320² literals exist — `X27 §6 C8`, `V15 Q7`). `compare_shots.py --threshold` is legal
  **only** candidate-vs-candidate determinism at a pinned camera, never donor-vs-candidate
  (`V15 §3`, `X07 §6 U2`). `terrain_ab_metric.py` is SMOKE-only, no ARI; no metric may
  override the visual read (`HANDOFF §4 caveats`).

**Owner-facing line:** "We have no screenshot to A/B against. The pictures we do have
are marketing/community stills with unknown camera and build; they can only tell us
whether we moved in roughly the right direction."

---

## Q5 — "Did you patch the old broken code?"

**Answer: No. The old code was deliberately left byte-untouched; new modules were added
behind a switch.**

- **Fresh modules, not patches (`CHARTER §1/§3.3`, `README §28-33`, `IMPLEMENTATION_PLAN §27-31`):**
  the day's rule was "understand first, build second"; the deliverable is
  `variant3d/scripts/terrain_donor_*.gd` composed by `world3d.gd`, with the legacy
  `world3d_terrain.gd` path retained behind a switch until A/B passes, then retired.
- **Legacy default seam (`HANDOFF §2.3`, `V36 §1.1`):** `terrain_backend` defaults to
  `"legacy"`; opt-in is exactly `"donor"`; `world3d.gd:108` still points at the legacy
  terrain script and the `:624` ternary instantiates it unless donor is explicitly
  selected (`V36 A17`).
- **Files untouched (`V36 §0/§2 EV03, §3 freeze-set check`, `HANDOFF §2.3`):** `game.gd`,
  `world3d_terrain.gd`, `world3d_relief.gd`, `shaders/terrain_tileindex.gdshader`,
  `water3d.gd`, `project.godot`, `assets/terrain/**` show no new edits; `git diff
  --exit-code -- app/` exited 0 and `git status --short -- app/` was empty at snapshot.
  No analysis worker edited source, shader, config, asset, test or git state.
- **No weakening (`HANDOFF §2.3`, `IMPLEMENTATION_PLAN §23-32`):** no threshold lowered,
  no assertion deleted, no synthetic noise/dither, no face promotion, no `HEIGHT_SCALE`
  multiplier, no donor-parity wording added to code. The seam was applied **once**
  (`V36 P5`), with SHA-exact `.bak-COORD-I11` rollback baselines.
- **Rollback is file-scoped (`V36 §7`, `HANDOFF §6`):** remove the I12 manifest entry by
  id, restore the two seam files from their verified backups, delete only creation-ledger
  files, keep inert tools/assets. **Forbidden:** `git reset --hard`, `git checkout .`,
  `git clean`, blanket `Copy-Item`, deleting `.bak`, or re-running until green.

**Owner-facing line:** "Nothing in the old terrain path was patched. The new pipeline is
additive and dormant by default; rollback is a short, file-scoped list."

---

## Q6 — "What do the 30+ board slots / worker roles actually do now?"

**Answer: they are a decode → verify → implementation swarm producing one disjoint report
each; the charter/board define 125 slots with a rule of at least 30 concurrent slots, and
finished slots are recycled. That is a staffing rule, not evidence of 30 simultaneously
live assistant sessions, so 'active' does not mean 'building'.**

- **Wave summary (`CHARTER §5`, `README §14-35`, `IMPLEMENTATION_PLAN`):**
  - **Wave D (D01–D09)** — donor binary / Ghidra: RTTI anchors, seed/RNG, mask pipeline,
    `.map` format, relief stamp, water/shore, resource placement, tile selection, editor binary.
  - **Wave F (F01–F10)** — donor data formats: `.pattern`, `pattern.lib`, gen cfg, mask
    TGAs, tile/atlas mapping, alpha masks, mill/field, flora/minerals, editor script, DLC.
  - **Wave P (P01–P06)** — port baseline audit: pipeline, assets, gates/capture, decoder
    reuse, 2D `app/` reuse, prior-wave root causes.
  - **Wave A (A01–A06)** — design: data model, algorithm, asset conversion, landscape
    props, QA/A-B harness, integration/rollback.
  - **Wave X (X01–X30)** — bulk pseudo-C corpora, verbatim DScript corpus, extra decode,
    cross-verification (blend, stamp, RNG, shore vectors, season texture) and X27's
    coverage audit.
  - **Wave V (V01–V45)** — verification/adjudication: UNVERIFIED resolution, contradiction
    register, spec readiness, gate register, code review, doc consistency, integration
    checklist, gate-command packet.
  - **Wave I (I01–I16)** — implementation: decoders/atlas compiler, SoA container,
    generator, mesh, props, shader, seam, determinism test, QA/capture.
- **Board slots, not a live-session count (`CHARTER §5`, `SWARM_BOARD` V45 refresh,
  `REPORT_INDEX` verdict box):** the board defines **125 worker slots** and a *staffing
  rule* of at least 30 concurrent slots, maintained by recycling finished slots into
  verification or implementation tickets (`SWARM_BOARD §0/§149-154`,
  `IMPLEMENTATION_PLAN §36-38`). **No ledger of 30 simultaneously live assistant sessions
  is available to this worker** — say "board slots / worker roles", not "30+ agents active
  now". The V45-era "76 of 125 rows have a report file; 49 have none" is a point-in-time
  snapshot, not a current count: a V67 re-glob found **103–111** report files and the V77
  index records **102→116→123→127** across five passes; the set is still growing. Re-glob before
  relying on any count. Empty slots at the V45 snapshot were marked `RUNNING` (e.g.
  X04/X10/X14/X16/X23–X25/X29/X31–X33; V02/V10/V14/V18–V19/V22–V25/V29–V32/V35/
  V38–V45; I14–I16 have no ticket definition and no invented owner). In every snapshot,
  `LANDED` = file presence only (never a gate PASS) and `RUNNING` = no report file at that
  snapshot (not evidence of a live session). I01–I13 files are **present** but explicitly
  **not** `LANDED`/`PASS` — presence is existence evidence only.
- **What they produce:** one report each under `reports/`, no source edits by analysis
  workers; COORD integrates landed reports into `spec/§00–§14`. All fifteen spec section
  files exist, but `spec/README.md` still shows `PENDING`, no section is marked READY,
  and no integration annotation certifies a gate result (`SWARM_BOARD` §Landed log,
  `V17`, `V26`, `V34`). This worker (V52) is a read-only owner-QA role — it changes no
  code and runs no Godot job.

**Owner-facing line:** "Most agents are decoding and cross-checking, not implementing.
The implementation agents have landed files, but 'file present' is not 'working' or
'tested'."

---

## Q7 — "What's next?" — exact steps, go/no-go, tools, owner-only inputs

### 7.1 Exact next steps (COORD-only sequence, `V36 §6`; gate order from `V42 §0` / V21)

1. **Step 0 — freeze the tree (GO/no-GO gate).** Re-run `git rev-parse --short HEAD`,
   `git status --short -- variant3d/ -- app/`, seam greps, `Get-FileHash` on E1–E4 + both
   `.bak-COORD-I11`, and `Test-Path` on absent paths. **GO:** HEAD stable, `app/` empty,
   exactly one seam, backup SHAs exact, no file changing across two reads 60 s apart.
   **NO-GO:** any file still moving, missing backup, second seam — *wait, do not restore*.
2. **Step 1 — resolve C1–C9 and C12 (`V36 §5`).** Written decision + owner + file:line for
   shader path, gen/props/mesh adapters, test hook, I02/I03 output ownership, I09
   `DONOR_UNITS=160`, I01 `--check` 20-vs-19 split, tautological self-checks.
   **NO-GO:** any HIGH conflict undecided. Preserve donor contradictions (6 vs 3 passes;
   `tilesmooth.cfg` path; `m_swamp_12_old` 17×20 vs 18×23) — never "fix" them.
3. **Step 2 — parse-before-switch.** Pin a Python interpreter (numpy/Pillow),
   `py_compile` all six tools; one Godot parse job via `godot_runner.py run --id
   V36-PARSE-1` after N10/N13 land or are formally retired. **NO-GO:** any parse error.
4. **Step 3 — decoders/assets.** Dry-run each tool, then `--write` into the single root
   `variant3d/assets/terrain_new/**` only after C7/C9; verify emitted paths, shas and
   labels; `--out` outside the donor root. **NO-GO:** write collision or permanent-red
   `--check`.
5. **Step 4 — re-verify runtime adapters (contract already repaired).** V48's caller-side
   patches are present and V61/V65 give static PASS on all six pairs (composer→I07
   Dictionary arg, composer→I08 `to_live()` handoff, composer→I09 `build(container,
   stamps, {})`, single shader path, guarded seam). Re-parse and keep the stream
   assertions (`gen_applied` / `mesh_built` / `props_applied`, `missing_modules` empty):
   **decoded donor inputs are still unwired (`gen_params={}`), so a smoke test is not an
   A/B and a static PASS is not a gate PASS** (`V61 §5`, `V65 §9`). **NO-GO:** any parse
   error, missing stream assertion, or stale contract after hash drift (`V48 §7.1`).
6. **Step 5 — register I12 LAST.** Take `inbox/backup/tests_manifest.json.bak-I12` first,
   append exactly one `{id:"t_terrain_donor"}` entry (40→41). **NO-GO:** backup missing or
   count ≠ 41. Remove by id only on rollback — never whole-file restore.
7. **Step 6 — legacy-default gates (no donor opt-in).** selftest 29/29, uitest 17/17,
   `t_render_mode` PASS, `assert_clean` CLEAN with **575/582/585 acknowledged with
   evidence-backed reasons**, `app/` byte-identical, freeze-set diff exit 0 — all from
   fresh result JSONs with mtime **after job START**. **NO-GO:** any red, stale JSON,
   unacked failure, blank capture. `--ignore-history` is forbidden (`V42 §0`, `V06`).
8. **Step 7 — opt-in donor A/B, only now.** Supply the backend via config override or
   direct `set_terrain_backend("donor")` before `bind()`; run `t_terrain_donor` and the
   harness with `--policy advisory` to `inbox/qa/terrain_qa_report.json`; fresh 240²/320²
   captures with pinned camera and explicit size labels. **GO:** determinism byte-identical
   on five streams, `missing_modules` empty, `mesh_built=true`, gates still green,
   `visual_parity_claim=false`. **NO-GO:** any hard FAIL, inert mesh, `app/` drift, or
   parity wording. Set backend back to `"legacy"` on rollback.
9. **Step 8 — owner sign-off.** Record three-tier verdicts per class, metric and visual
   fields separate, parity **UNVERIFIED** unless a real matched-seed donor GPU frame
   exists (it does not). Default flip to donor is a **separate, deferred ticket**.
   **NO-GO / hold:** any parity claim, signed `--policy red` without a READY donor spec,
   or a lowered threshold.

Gate stations to run in order: `A′-0 → A′-1 → A′-2 → A′-3 → D-0 → D-1 … D-6`
(`V42 §0`, `V21 §6`). One Godot at a time; `python variant3d\tools\godot_runner.py
status` after every `run`; unique `--id`; never combine `--dump-config` with
`--screenshot` (`HANDOFF §6`, `V42 §1/§4`). **Do not read any stale 2026-11-25 green
JSON as current.**

### 7.2 Free tools that would actually help (`README §37-54`; `X27 §7`, `§9`)

| Tool | Why it helps this specific stripped 32-bit Delphi/C++Builder target | Cost |
|---|---|---|
| **Ghidra 11.x** (NSA) | headless batch analysis + Python RTTI/vtable recovery; a true second lifter for the 4,265/12,254 garbled functions and a VMT-pointer-following discovery pass for the 23 missing anchors | free/open source |
| **IDR — Interactive Delphi Reconstructor** | purpose-built for stripped Delphi: class hierarchies, RTTI, DFM events, IDA/Ghidra-friendly maps — exactly the `X*`/`T*` problem in `DA_PE.md` | free |
| **ImHex** | pattern-language parser for `*.pattern` / `pattern.lib` — byte-accurate struct declarations, also a read-only hex inspector | free/open source |
| **Cutter / radare2** or **RetDec** | second-opinion decompilation where the built-in lifter produces unstructured pseudo-C (Rizin/objdump were `engine_missing` in D01) | free/open source |
| **HxD** (or ImHex) | read-only hex inspection of donor `.map` / `.pattern` bytes | free |

Craft Anything Deep mode remains the primary tool; none of these is *required* to
continue, but a second lifter plus VMT-pointer discovery is the cheapest path to
shrinking the garbled/missing-function ceiling (`X27 §7`, §9 Q1).

### 7.3 What only the owner can provide

1. **A genuine same-camera, same-seed, same-map-size donor GPU A/B frame.** This is the
   *only* thing that can lift a class above tier 2 and change `parity.status` from
   `UNVERIFIED`. Nobody has produced one; COORD/owner must decide whether it is
   obtainable at all (`V15 Q8`, `V16 Q6`, `V21 §10 Q8`, `HANDOFF §7 #1`, `X07 Q2`).
2. **DLC entitlements / DLC scope decision.** `F10` records that winter (`season=2`)
   requires `gc_lastknowndlc_dlc2` or deluxe and desert (`season=3`) requires
   `gc_lastknowndlc_dlc3` or deluxe; the 49 baked DLC `.map` files (2.877 GiB) were
   deliberately deferred, there is **no folder→DLC manifest** (`F10 E42`), and their
   `season` values were **not** decoded (the word `winter` occurs 0 times in every DLC
   map). If the owner wants season/lake/DLC5 terrain, someone must supply the
   entitlements and a scope ticket; otherwise those stay declared out-of-scope with
   reasons. Coastal/Lakes/Rivers masks are shipped skirmish content (no entitlement
   check) — the question is whether COORD opens the DLC5 rivers/lakes ticket (currently
   rivers `OUT_OF_SCOPE`, `V15 §5.3/Q2`).
3. **A decision on a read-only donor runtime / GL trace** (known-key `.map` replay pack,
   GPU capture). Without it, runtime activation of the `;`-prefixed DScript corpus,
   `bmTransparency` pass count and `hmapTex` binding stay permanently `[U]` (`X27 §9 Q2`).
4. **Sign-off on bookkeeping and pinning:** the `declared_unverified` /
   `blocking_unverified` split (`V15 Q1`), the canonical capture size (240² vs 320²) and
   camera/ROI set (`V15 Q7`, `X07 Q1`), and whether to fund the VMT-pointer discovery +
   Deep Ghidra re-lift (`X27 §9 Q1`).

**Best honest outcome even after all gate work succeeds:** "gates green / internal
consistency PASS / donor parity UNVERIFIED" — only *after* gates actually pass. Until
then, the conservative owner reading is `RESULT IS NOT GOOD`.

---

## 8. Five-line summary (V52)

1. **[O] "Every single bit" — no:** donor container/layout and cited constants are byte-exact (710/710 `.pattern` size closure, 680-section `pattern.lib`, 4,466 masks, 7 cfg, 124 tile ids, LCG), but **full w×h grids are bit-decoded for ~30 named patterns only and ~50+ active ids remain unbit-decoded** (`X27 §3.3`); 4,265 (22.54%) cossacks and 12,254 (54.7%) editor functions are garbled, only 11/34 anchors exist, the packed `.bind` (entropy 7.96) was never unpacked, `config/modman/cdx` are untouched, and all 972 `.inc` excerpts are `;`-prefixed intent with execution `[U]` (`X27`).
2. **[O] "Terrain cloned" — no:** fresh modules and a single-applied seam exist behind a `"legacy"`-by-default switch. V36's four hard API breaks (composer→gen Object-vs-Dictionary, composer→props missing `bind`, mesh Dictionary-only ingest, I12 hook arity/return) were repaired by V48's caller-side patches; V61/V65 report **static PASS** on six pairs — **not a gate PASS, no streams proven**, decoded donor inputs still unwired and no gate run (`V36`, `V61`, `V65`, `V42`).
3. **[O] "Are hills/mountains/fields/sea/shore/forests/mines there?"** — every class has tier-1 donor evidence prepared and tier-2 criteria drafted, but no tier-1 verdict is signed (D3 not run), no tier-2 result observed (no admissible capture), and parity is 3 throughout; quarries are `[D]/[I]` only and rivers are `OUT_OF_SCOPE` (`HANDOFF §3`, `V15 §4`, `X07 §4`).
4. **[O] "Why no donor A/B screenshot?"** — no donor binary was executed or GPU frame captured; the 12 third-party stills have unknown build/camera/zoom/world-area/compression and support direction only; mountains, sea, iron/coal, rivers/swamps have no reliable reference and the "highlands" wallpaper is a two-pass false positive (`X07`, `V15 §0/§5`).
5. **[O] "Old code patched?" — no** (`app/**` and the freeze set byte-untouched, file-scoped rollback from `.bak-COORD-I11`); **"30+ agents?"** — one disjoint report per worker across D/F/P/A/X/V/I waves, but this is a **125-slot board with a rule of at least 30 concurrent slots, not proof of 30 live sessions**; the "76/125 landed, 49 RUNNING" split is a V45-era point-in-time snapshot (V67/V77 globs found 103–127 files and still growing), `LANDED` = file presence only, `RUNNING` = no report file at that snapshot, presence ≠ PASS; **next:** COORD steps 0–8 with explicit go/no-go, free Ghidra/IDR/ImHex/Cutter/HxD, and only the owner can supply a same-camera donor GPU frame plus DLC entitlements/scope — otherwise parity stays UNVERIFIED and the honest result is `NOT GOOD`.

---

*End of V52 report. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V52_owner_qa.md`). No source, shader, asset, config, test, result JSON, git, runner or Godot state changed; no donor binary executed or copied; no reference image, gate result or donor-parity claim created. All claims are point-in-time against landed documents; COORD must re-verify the live tree before acting.*
