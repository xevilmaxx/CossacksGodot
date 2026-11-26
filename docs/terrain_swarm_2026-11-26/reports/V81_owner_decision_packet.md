---
id: V81
ticket: "TERRAIN-SWARM-2026-11-26 / V81 — FINAL OWNER DECISION PACKET (the single document the owner should read)"
agent: "V81 (read-only final-decision-packet worker, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V81_owner_decision_packet.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V81_owner_decision_packet.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists, no donor binary was executed by any worker, and no gate result is asserted here. Nothing in this packet is a gate PASS, a green verdict, or a donor-match claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Read-only. Every claim below was re-read against a second landed document before writing. No source, shader, asset, config, test, result JSON, git, runner or Godot state touched; no donor file opened or executed; no reference image or capture fabricated."
sources_read: "CHARTER.md, SWARM_BOARD.md, HANDOFF.md (V46 refresh), REPORT_INDEX.md, reports/V52_owner_qa.md, reports/V57_final_parity_statement.md, reports/X39_ab_feasibility.md, reports/X27_decode_coverage.md, reports/V15_acceptance_without_reference.md, reports/V61_composer_api_audit.md, reports/V62_asset_completeness.md, reports/V65_patch_verification.md, reports/X36_mountain_visual_recheck.md."
multiple_passes: true
multiple_pass_note: "Requested files V63_go_no_go.md, V67_owner_answer_check.md and V72_final_decision_memo.md were checked and DO NOT EXIST on disk; no content was invented for them. V61/V62/V65/X36 (later than V57) were read in addition because they update the implementation/asset/reference picture. Point-in-time claims are quoted with the weaker (honest) wording kept; file presence is never promoted to correctness, a gate result or parity."
---

# V81 — FINAL OWNER DECISION PACKET (2026-11-26)

> **Mandatory reviewer wording (verbatim, V15 §2 / X07 §8 / V52 frontmatter):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

This is the single owner-facing document. It supersedes no report; it consolidates the
landed evidence. **Nothing here is green.** No gate was run for today's tree, no donor
binary was executed, and no donor GPU A/B frame exists.

---

## 1. The one-sentence honest answer — "is terrain cloned?"

Quoted verbatim from `V57 §4` (the final parity statement), re-read against `X27 §7`,
`V15 §2`, `HANDOFF §0/§5`, `V52 §2` and `V36 §1.4/§6`:

> **No — terrain is not cloned: the donor's terrain-relevant data formats and a small set of named functions are byte-exactly decoded and a donor-shaped port scaffold exists, but no donor GPU A/B frame, no gate result and no runtime observation exist, so the honest verdict is `PORT APPROXIMATION` with donor parity `UNVERIFIED`.** `[D]/[U]`

Plain reading: we produced a **byte-faithful specification** and a **dormant, scaffolded
port**, not a clone. The conservative owner verdict today is `RESULT IS NOT GOOD`,
because `blocking_unverified` is non-empty (no D3 dump integrity, no admissible capture,
dirty runner) even though the declared parity gaps themselves are accepted
(`V15 §2`, `V21 §10 Q7`, `HANDOFF §0`, `V52 Q2`).

---

## 2. What was decoded vs what remains UNVERIFIED

### 2.1 Byte-exact closure counts — DECODED (decode integrity only)

All counts are mechanical counts of recovered bytes/records/instructions, cross-read in
`X27 §2` and `V57 §1`. They establish **decode integrity**, not a port-side tier-1
verdict and not fidelity (`V57 §2.1`).

| Artifact | Byte-exact count / closure | Verified against |
|---|---|---|
| `.pattern` format | size law `S = 8+4wh+54(w−1)(h−1)` holds **710/710**, zero residual; 7 regions tile `[0,S)` **710/710**; **550,908** `Rec24`; **678/680** min/max bit-exact; corrected grid offset `G=8+(w−1)(h−1)` **13/13** bit-exact | `X27 §2 E9`, `V57 §1 #1`, independent `X34 §4.1–4.3` |
| `pattern.lib` | **30,309,138 B** plaintext; **680** sections; 1,172,417 split lines; **39,780** object records; **235** `BaseName`; 37-key prologue; 12 grid cross-checks bit-exact; 680 name→file (679 exact + 1 case) | `X27 §2 E10`, `V57 §1 #2`, `X05` |
| Terrainmask TGAs | **4,466** full-decoded = 1,331 vanilla + 1,856 dlc5 + 1,279 src; B spans all 256 values; `h = −1.1·B/255`; water at `B≥58` | `X27 §2 E11`, `V57 §1 #3`, `F04`/`D03` |
| Gen `.cfg` files | **7** files hashed/parsed: 20 global + 13 local keys; 8 tile sections/30 names; 22 chains / 118 active groups / 282 active entries / 86 names; 64 families / 493 `Pattern=Freq` pairs; 19 presets / 61 masks / 276 legend entries | `X27 §2 E7`, `V57 §1 #4`, `F03` |
| RNG LCG | exact `s=(s·0xFC0D+0x3C6EF35F) mod 2³²`, output `f32(s/2³²)` at `0x60f64c`–`0x60f696`; identical bytes in editor/config/modman; **11 `SetRandomKey` + 3 `SetRandomExtKey64`** reseed sites; `mix64` refuted | `X27 §2 E5`, `V57 §1 #5`, `D02`/`X21`/`V01` |
| Relief stamp | `sub_755f30` **25,175 B / 6,751 instructions / 5 callers**; **three blend paths**; `Min` is scale pivot; `HeightFieldMax` never read; `Offset` additive; divisor hardcoded `4.0f`; 19 blend vectors + 4 smooth snapshots with exact float32 bits | `V57 §1 #6`, `D05`/`X12`/`X13` |
| `bmTransparency` blend function | `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)` at VA `0x4ef991`/`0x88fbb0` (IAT `0x907d90` per `HANDOFF §1`) | `X27 §2 E14`, `V57 §1 #7`, `F06`/`D08`/`X17` |
| `.map` 37-byte records | `W×H×37` record invariants **102,400/102,400** and **147,456/147,456**; `(2W)²` tag grid; `(W+1)²−2` f32 heights; serializer `sub_739d3c`, loader `sub_73a0b8` | `X27 §2 E12`, `V57 §1 #8`, `D04` |
| Tiles | **124 tile ids/season**; 112 shipped DDS (108 referenced); three-file id→picture chain; port atlas 16×8 | `X27 §2 E13`, `F05` |

### 2.2 What remains UNVERIFIED — quote these alongside the counts

1. **Garbled percentages (`X27 §3.1/§6 C9`, `V52 Q1`, `V57 §2.3 U9`).** `cossacks.exe`
   18,918/18,918 **discovered** functions exported, of which **4,265 (22.54%)** are
   unstructured; `editor.exe` 22,384/22,384 exported, of which **12,254 (54.7%)** carry
   ≥1 garble marker (559 with ≥1,000). The "18,918/18,918 and 22,384/22,384" totals are
   honest **for discovered functions only**: only **11 of 34** D01 terrain anchors are
   present (**23 absent**), and ~45/64 class constructors stay `[U]`. Never say "whole
   binary decoded".
2. **Packed stubs (`X27 §3.1`, `§4 Category B`).** Both binaries carry a packed/obfuscated
   `.bind` section (cossacks entropy **7.96**; editor VA `0x76f000`, size `0x23d70`,
   with a `VirtualAlloc(RWX)` unpack-staging hint). It was **never unpacked or executed**;
   a possible secondary stamp path, mesh builder and RNG code lie beyond the corpus.
   "Absence is not proof" — it is `[U]`, not "absent".
3. **Runtime intent vs execution — the single biggest categorical gap (`X27 §0/§4`,
   `V52 Q1`, `V57 §2.3 U10`).** All **972** X03 verbatim `.inc` excerpts and all F03 cfg
   literals are `;`-prefixed *intent*. No donor binary was run by any worker; no compiled
   path was observed consuming a decoded value. `bmTransparency` **pass count** stays `[U]`
   after **six** X17 passes; `hmapTex` binding/plane Y, native kernels
   (`SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`, `WaterFieldAdd`), `.pattern` field
   semantics (`Rec24.id`, PRE, weights, `Tail13`), `.map` tag/owner/collision semantics,
   `GenerateMapRandKey` body and saved-map key bytes all remain `[U]`.
4. **No-reference visual classes (`X07 §4/§7`, `V15 §0/§4`, `X36 §0/§3`).** No reliable
   still exists for **mountains, sea, iron/coal mines, rivers or swamps**. The
   `guardians-of-the-highlands` wallpaper is a stone-construction scene on three
   independent crops (`X36`), not mountain evidence. `X36` newly resolves foam texture in
   A11 and a **second mine icon** in A0, but sea-vs-riverbank-vs-wet-sand and iron-vs-coal
   stay `[U]`. The 12 images in `C:\Users\Maxym.Oboyshev\Downloads\c3\` are third-party
   stills of unknown build/camera/zoom/world area/compression: **direction of movement
   only**, never parity, never a numeric gate.
5. **Effectively untouched artifacts (`X27 §0/§3.3`).** `config.exe`/`modman.exe` (one RNG
   byte cross-check each), `cdx` (zero mentions), the packed `.bind` stubs, and the 49
   baked DLC `.map` files (2.877 GiB, deferred as closed campaign snapshots with no
   generator delta, `F10`).
6. **Named residues (`V57 §2.3 U11–U14`).** Row-sign flip, rotation rounding, global setter
   clamp, true x87 precision, `HeightFieldMax` consumers, `tiaAlphaFromIntensity`,
   tile→patch selector, eye planes, atlas packing equivalence, generator version /
   `mapsize` enum, deposit capacity, alpha composite layer count, missing `CalcTerrain`
   / `test_shadow` / tile painting. Nothing was silently skipped; multi-pass logs are in
   `X27 §6` (C1–C10).
7. **Consequence (`X27 §4`).** A port can be *structurally* faithful to decoded text while
   behaviourally divergent in everything dependent on execution. All visual claims are
   `PORT APPROXIMATION` / self-consistent only.

---

## 3. What was built in `variant3d` today — and the default-legacy / ungated state

### 3.1 Files on disk (presence only, never correctness)

Cross-read in `HANDOFF §2.1`, `SWARM_BOARD` §Filesystem inventory, `V61`, `V62`, `V65`:

- **Decoders / compiler:** `decode_donor_cfg.py` (I01), `decode_donor_pattern.py` (I02),
  `decode_pattern_lib.py` (I03), `decode_donor_masks.py` (I04),
  `build_terrain_new_atlas.py` (I05, dry-run by default), `terrain_qa_harness.py`
  (I13/N16, `--policy advisory`).
- **Fresh pipeline modules:** `terrain_donor_data.gd` (I06, SoA container),
  `terrain_donor_gen.gd` (I07, stage pipeline), `terrain_donor_mesh.gd` (I08),
  `terrain_donor_props.gd` (I09), `terrain_donor_shader.gdshader` (I10, V37 canonical
  name; old alias `terrain_donor.gdshader` absent), `terrain_donor_world.gd` (N14 composer).
- **Seam / test / rollback:** `main.gd` + `world3d.gd` (I11-SEAM, single-applied),
  `inbox/backup/main.gd.bak-COORD-I11` and `world3d.gd.bak-COORD-I11` (SHA-verified),
  `variant3d/tests/t_terrain_donor.gd` (I12, not run), `spec/terrain_qa_spec.json` (N17,
  schema-only/unpopulated at V36 EV18).
- **Generated asset tier (`V62`, three filesystem passes):** `assets/terrain_new/**`
  exists with **780 files / 242,316,351 B**, but only in `cfg/` (3 JSON) and
  `patterns/` (713 JSON + `families/` 64 JSON). **No** `atlas/`, `masks/`, `lib/`,
  `schemas/` or root `manifest.json`; all 780 files are **untracked**. I08 therefore falls
  back to the legacy 179,912,941 B atlas, and I09 falls back to legacy
  `mountain_props.json` (`fallback_used=true`) — a labelled `TRANSFORM_FALLBACK`, not a
  donor asset path (`V62 §1/§3/§4 C1–C2`).

### 3.2 API state (static reading only)

`V61` and `V65` report all six audited caller→callee pairs as **static PASS on
type/arity/contract** — (a) composer→I07 `generate(C3TerrainData, Dictionary)`,
(b) composer→I08 via I06 `to_live()`/`to_dump()` Dictionary, (c) composer→I09
`build(Object, Array, Dictionary)`, (d) I12→I07 container + settings, (e) canonical
shader path, (f) seam default `legacy` with both `make_world3d()` sites guarded. The
V36 four breaks were repaired by V48 caller-side text patches applied by their owners
mid-audit. **These are line-level static verdicts, expressly NOT gate results:** V61/V65
ran no parse job, runner, gate, capture or Godot process; `gen.gd`/`props.gd` hashes
drifted twice and must be re-hashed immediately before any gate (`V61 §5 Q6`, `V65 §5`).
`_call_adapt` returns `true` on dispatch only, so `gen_applied=true` does not prove valid
streams (`V61 §5 Q4`). `gen_params = {}` means no decoded donor inputs are wired
(`V61 §5 Q1`, `V65 §9 #2`).

### 3.3 Backend default and absence of gates

- **Default is legacy.** Exact config key is **`features.terrain.backend`** (`main.gd:189`),
  read with default `"legacy"`; only the exact string **`"donor"`** opts in; every other
  value is coerced back to `legacy` (`main.gd:190-191`, `world3d.gd:224`). `world3d.gd:144`
  also defaults to `legacy`. There is **no** `features.terrain.backend` key in
  `config.gd`/`config.json`, so stock config cannot opt in (`V36 A17`) — an override or
  direct `set_terrain_backend("donor")` before `bind()` is required. Late switching is
  refused after `bind()` (`world3d.gd:220-224`, `:645`).
- **Nothing is green; no gate was run (`REPORT_INDEX` verdict box, `SWARM_BOARD` §gates,
  `HANDOFF §4`, `V52 §7.1`).** All result JSONs on disk are stale (2026-11-25);
  `assert_clean --json` was `DIRTY` with **575/582/585 unacked**; no fresh 240²/320²
  baseline; no admissible 1280×720 windowed capture; `inbox/qa/terrain_qa_report.json` and
  `inbox/qa/captures/` are **absent** (only PENDING markers); the A24 relief-props atom was
  a hard FAIL at the HANDOFF snapshot (`t_relief_props_qa.gd:30` points at absent
  `terrainmesh_props.json`). Every `HANDOFF §4` verdict is a `TODO(COORD)` placeholder.
  V52/V57/V61/V62/V65 submitted **zero** runner jobs; none of the above stale states was
  re-measured or repaired by those workers.
- **Legacy files untouched.** `game.gd`, `world3d_terrain.gd`, `world3d_relief.gd`,
  `shaders/terrain_tileindex.gdshader`, `water3d.gd`, `project.godot`, `app/**` show no new
  edits; `git diff --exit-code -- app/` exit 0 at V65 P9. No threshold lowered, no
  assertion deleted, no synthetic noise/dither, no donor-parity wording in code.

---

## 4. Three-tier verdict per landscape class

Vocabulary is `V15 §2` only: **Tier 1 = DONOR-GROUNDED STRUCTURE VERIFIED** (cited donor
datum matching a port-side byte/count/id/hash **and** dump integrity D3); **Tier 2 =
SELF-CONSISTENT VISUAL / `PORT APPROXIMATION`** (admissible capture, property named from
a donor rule, measured only inside the candidate); **Tier 3 = UNVERIFIED**. No tier above
2 exists. Combination rule: tier 2 never implies tier 1; tier 1 never implies tier 2.

**Reading rule (brutal):** tier-1 evidence is *prepared but unsigned* because **D3 dump
integrity has not been run**; tier-2 criteria are *drafted but unobserved* because **no
admissible capture exists**; tier 3 is declared, not a gate failure by itself. **No class
is upgraded by this packet** (`HANDOFF §3`, `V57 §2`, `V15 §4`).

| Class | Tier-1 donor evidence prepared (unsigned — D3 missing) | Tier-2 criteria drafted (unobserved — no capture) | Highest honest tier today | Must stay UNVERIFIED |
|---|---|---|---|---|
| **Hills / rolling relief** | A7/A5 stills as `[D]` direction cue only (`X07 §4`); relief grid decode `D05`/`X12`/`X13`; height shared with mesh (I08) | Readable mounds; no concentric rings / diagonal vein lattice / flat-only mound; ON/OFF pixel change | evidence prepared; **no signed tier**; **parity 3** | donor appearance; camera/zoom unknown; no A/B frame |
| **Mountains** | `pattern.lib:337461-340273` `g_mnt_1` 43×38 all-zero + `BaseName=terrainmesh4`; `mountains` 7 / `desert_mountains` 13 families; 112 prop records / 30 sections; 4 converted `relief` assets | Silhouette ≥ centre +4 m and footprint +2 m; props ON/OFF ≥200 px, ≥8 px rise, <1% outside; `matched_stamps>0`; two non-blank 1280×720 PNGs | evidence prepared; **tier-2 not observed**; **parity 3** | no donor mountain still (`X07 U3`, `X36` confirms); `terrainmeshN` chooser; yaw/metres-per-unit; prop rendering has no QA atom; "highlands" wallpaper is a three-pass false positive (`X36`) |
| **Mill fields** | `generator.cfg` field families; A1/A3 stills `[D]`; X22 verbatim `_unit_DoSeedWheat` + decal binding; no food rects in `SetupStartingResources` | Golden L/rectangular parcels with windmill footprint, no checkerboard, no synthetic dither | evidence prepared; **tier-2 not observed**; **parity 3** | donor pixels; runtime activation of commented callers; season confound |
| **Sea** | `generator.cfg:5-6` `nowater2` for land maps; four water literals (−1.1/−0.5/−0.25/−0.1); water id 255; shore ids 93/97/98; shader/plane landed, no foam texture | Pale water body; foam **slightly offshore**, not a white waterline rim; continuous beach→foam→water band; foam metrics with no pass verdict | evidence prepared; **tier-2 not observed**; **parity 3** | no reliable sea still (`X07 U2/U9`; `X36`: A11 identity still `[U]`); plane Y, `hmapTex`, foam width, metres-per-cell |
| **Shore / beach** | 8×45° `sandsea1/5/6` table; shore height smoother 3× power 0.35; `bmTransparency` crossfade confirmed at instruction level (`X17`) | Continuous warm beach → bright foam → pale water, no hard tile-aligned edge; no half-shore turned into blocked rock | evidence prepared; **tier-2 not observed**; **parity 3** | donor pixels; pass count / `hmapTex` bind `[U]` after six passes; `X11` missing stages |
| **Forests (conifer / mixed)** | Donor forest families/weights decoded (`F08`/`F03`); A10 high-confidence conifer, A7 groves on hills | Natural tree spacing, grove edge transitions, no grid; donor lighting shadows only | evidence prepared; **tier-2 not observed**; **parity 3** | donor foliage pixels; donor-authored forest-interior lists; A9 low detail |
| **Stone quarries** | **No donor asset named `quarr` (0 hits)**; `stones` 7 / `stoneforests` 8 records, `stn1=0.00016`, `stn2=0.00012`, scale 0.329 ±15% — mapping is `[D]/[I]` | Clustered boulders inside stamp footprint, no radial rings, no single-rock grid | **donor structure PARTIAL (`[D]/[I]`)**; **tier-2 not observed**; **parity 3** | quarry↔stones identity; A0 snow confound; A6 is built masonry, not a quarry |
| **Gold / iron / coal mines** | Nested `minegold/mineiron/minecoal` in `mng/mni/mnc` (`pattern.lib:713410/715244/716910`), 6 cfg records each; ring→ore→256 tries; resource ids 4/5/6; mesh scale 0.3152, 5×5 dirt plate; no finite deposit capacity | Deposit mesh on its centred disc; built mine centred; no orphan/concentric rings; ore differentiated by material only (meshes byte-identical — `PORT APPROX`) | evidence prepared; **tier-2 not observed**; **parity 3** | A0 gold is `[I]` from icon/text; **no identifiable iron/coal reference** (`X07 U4/U8`; `X36` finds a second ore icon but cannot name it); capacity, snap, record-id binding |
| **Swamps / lakes** | `generator.cfg:1290-1533` swamp 11+2+20=33 refs; `m_swamp_small_1` 16×13 zero height field with bushes/fern, no water plane; global pass in `dogenerate.inc`; port `donor_patterns.json` has **no** swamp/lake families | Organic soft-edged wet patch with reed/bush/fern fringe, **no water plane**; donor-derived tile ids; no checkerboard/noise | evidence prepared; **conversion gap — presence gate fails until exported**; **parity 3** | `[*] = ;` activation; `m_swamp_12_old` 17×20 vs 18×23 PRESERVED; `lake_big := plain*2*0` must not be "repaired"; no still |
| **Decor (towers / windmill / village / camp)** | A7 watchtowers, A1 windmill, A6 stone structures over-represented; decal/prop records decoded; no dedicated family spec | Silhouettes only, no terrain-class claim; no HUD/unit ROI contamination | `[D]` from stills (direction only); **parity 3** | donor pixel identity; third-party build/camera unknown |
| **Rivers (adjacent, scoped out)** | Only `generator.cfg:62-64` `hint=8.Rivers` → `terrainmasks.dlc5\rivers`; no skirmish placement rule; `fordtyp` is a formation field, not a generator | **None permitted that names "river"** | **`OUT_OF_SCOPE`** pending COORD/F10 (`V16 O2`); **parity 3** | no river reference (`X07 U5`); all river semantics/width/depth; inventing a ford threshold is forbidden |

**Booking split that governs the verdict (`V15 §2`):** `declared_unverified` (the accepted
gaps above) is allowed, but any non-empty `blocking_unverified` (no D3 dump, no admissible
capture, dirty runner, unresolved numeric contradiction) ⇒ `RESULT IS NOT GOOD`. Today
`blocking_unverified` is non-empty. No class reaches donor parity because no admissible
capture and no donor GPU A/B frame exists.

---

## 5. Exact next actions, in order

### 5.1 COORD actions (COORD-only; analysis workers submit no Godot jobs)

Sequence from `V52 §7.1`, `V36 §6`, `V21 §6`/`V42 §0`, updated with `V61`/`V62`/`V65`:

1. **Step 0 — freeze the tree (GO/no-GO gate).** Re-run `git rev-parse --short HEAD`,
   `git status --short -- variant3d/ -- app/`, seam greps, `Get-FileHash` on E1–E4 + both
   `.bak-COORD-I11`, and `Test-Path` on absent paths. **GO:** HEAD stable, `app/` empty,
   exactly one seam, backup SHAs exact, no file changing across two reads 60 s apart.
   **NO-GO:** any file still moving, missing backup, second seam — wait, do not restore.
   Re-hash `gen.gd`/`props.gd` (drifted twice, `V65 §5`).
2. **Step 1 — resolve C1–C9 and C12 (`V36 §5`).** Written decision + owner + file:line for
   shader path, gen/props/mesh adapters, test hook, I02/I03 output ownership, I09
   `DONOR_UNITS=160`, I01 `--check` 20-vs-19 split, tautological self-checks. **NO-GO:** any
   HIGH conflict undecided. Preserve donor contradictions (6 vs 3 passes; `tilesmooth.cfg`
   path; `m_swamp_12_old` 17×20 vs 18×23) — never "fix" them.
3. **Step 2 — parse-before-switch.** Pin a Python interpreter (numpy/Pillow),
   `py_compile` all six tools; one Godot parse job via
   `python variant3d\tools\godot_runner.py run --id V36-PARSE-1` after N10/N13 land or are
   formally retired. **NO-GO:** any parse error (this settles V48 R6's `class_name`
   cache question).
4. **Step 3 — decoders/assets.** Dry-run each tool, then `--write` into the single root
   `variant3d/assets/terrain_new/**` only after C7/C9; verify emitted paths, shas and
   labels; `--out` outside the donor root. `V62 §6` must-generate order before any gate:
   (P0) I05 atlas pair `atlas/tile_index_atlas.png` + `.manifest.json` and assert I08 stats
   point inside `terrain_new/atlas/`; (P0) I03 object feed at
   `patterns/pattern_lib_index.json` **with a record shape I09 accepts** (do not count
   `family_index.json` — `V62 §4 C1`); (P0) X15-conformant root `manifest.json` (do not
   accept `cfg/manifest.json`); then schema and mask tiers. Normalise absolute
   `C:\Games\Cossacks 3\...` paths in the landed cfg JSONs before any commit (`V62 C4`).
5. **Step 4 — repair runtime adapters.** V61/V65 already recorded static PASS on all six
   pairs; **re-verify both sides and hashes against the frozen tree** rather than assuming
   the earlier reading, and keep explicit `gen_applied` / `mesh_built` / `props_applied`
   stream assertions (dispatch ≠ success). Wire decoded donor inputs into `gen_params`
   instead of `{}` before any A/B. **NO-GO:** any of the four original breaks reappears.
6. **Step 5 — register I12 LAST.** Take `inbox/backup/tests_manifest.json.bak-I12` first,
   append exactly one `{id:"t_terrain_donor"}` entry (40→41). **NO-GO:** backup missing or
   count ≠ 41. Remove by id only on rollback — never whole-file restore.
7. **Step 6 — legacy-default gates (no donor opt-in).** selftest **29/29**, uitest
   **17/17**, `t_render_mode` PASS, `t_map_variety` 5/5, `scan_map ALL GREEN`,
   `assert_clean` CLEAN with **575/582/585 acknowledged with evidence-backed reasons**,
   `app/**` byte-identical, freeze-set diff exit 0 — all from fresh result JSONs with mtime
   **after job START**. `--ignore-history` is forbidden. Gate stations in order:
   `A′-0 → A′-1 → A′-2 → A′-3 → D-0 → D-1 … D-6`. One Godot at a time; `godot_runner.py
   status` after every `run`; unique `--id`; never combine `--dump-config` with
   `--screenshot`. **NO-GO:** any red, stale JSON, unacked failure, blank capture.
8. **Step 7 — opt-in donor A/B, only now.** Supply the backend via config override or
   direct `set_terrain_backend("donor")` before `bind()`; run `t_terrain_donor` and the
   harness with `--policy advisory` to `inbox/qa/terrain_qa_report.json`; fresh 240²/320²
   captures with pinned camera and explicit size labels (pin donor A/B at **320² enum 0**,
   per `X39 §3`). **GO:** determinism byte-identical on five streams across 64²/240²/320²,
   D3 run integrity status ∉ {timed-out,error,skipped} with `script_error_lines=0`,
   `missing_modules` empty, `mesh_built=true`, gates still green,
   `visual_parity_claim=false`. **NO-GO:** any hard FAIL, inert mesh, `app/` drift, or
   parity wording. Set backend back to `"legacy"` on rollback.
9. **Step 8 — owner sign-off.** Record three-tier verdicts per class, metric and visual
   fields separate, parity **UNVERIFIED** unless a real matched-seed donor GPU frame plus
   a demonstrated match exists. Default flip to donor is a **separate, deferred ticket**.
   **NO-GO / hold:** any parity claim, signed `--policy red` without a READY donor spec, or
   a lowered threshold.

**Rollback (any hard FAIL, dirty runner, `app/` drift, inadmissible capture, visible
artifact, parity wording, or non-empty `blocking_unverified`):** remove the I12 manifest
entry **by id**, restore `world3d.gd`/`main.gd` from their SHA-verified
`.bak-COORD-I11` files, delete only creation-ledger files, keep inert tools/assets,
re-run D-5 to green. **Forbidden:** `git reset --hard`, `git checkout .`, `git clean`,
blanket `Copy-Item`, deleting `.bak`, re-running until green, weakening any gate.

### 5.2 OWNER-ONLY actions (no worker or assistant may perform these)

1. **Same-camera donor capture — `X39` Route A (the only admissible route).** The owner
   personally launches `C:\Games\Cossacks 3\cossacks.exe`, generates/saves a map and
   captures a PNG; the assistant never runs or copies the donor (`CHARTER §4`). Pin and
   manifest, in one line each:
   - size **`mapsize = 0` → 320×320** (no donor 240² enum; 240² stays a port-only
     determinism atom, `X39 P2/U5`);
   - map type **TerrainTypes 0 Land** (`nowater2`) as the closest match to port
     `map_type="land"` (record the actual enum if different);
   - season int **0 Summer** (or 2 Winter / 3 Desert if deliberately testing those);
   - seed keys `randkey0` (u32 high) and `randkey1` (u32 low) supplied explicitly —
     `randkey1` is embedded in the save filename `game_v<ver>k<randkey1>.map`; mark
     `UNKNOWN` if `randkey0` cannot be read, which downgrades the comparison;
   - camera profile: main view uses `data\cameras\camera.cfg` (not the screenshot/debug
     preset); tilt **−32°**, focal **400** (Min=Max), dolly/SphereHeight/Length **20…58**,
     DepthOfView **1200**; record actual zoom/dolly at capture (donor absolute FOV is
     `[U]`; port assumes 17.27°);
   - window **1280×720 windowed**, no HUD over the ROI; donor build/version string;
   - saved `.map` and donor PNG **outside the repo** (recommended
     `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.{map,png}`),
     with PNG SHA-256;
   - a ground-only fractional ROI `(x0,y0,x1,y1)` confirmed on **both** frames; an ROI
     landing on sky/HUD/units is UNVERIFIED, **not** retried until green;
   - written attestation "donor launched by owner; assistant never executed donor".
   
   A donor PNG is **necessary but not sufficient** (`X39 §4`): because `GenerateMapRandKey`,
   saved-map key bytes, donor FOV and script runtime activation are `[U]`, same seed keys
   do not guarantee the same scene. Parity requires a demonstrated match, not merely a
   donor PNG.
2. **DLC entitlements / scope decision.** Winter (`season=2`) requires
   `gc_lastknowndlc_dlc2` or deluxe; desert (`season=3`) requires `gc_lastknowndlc_dlc3` or
   deluxe (`F10`). The 49 baked DLC `.map` files are deferred and there is **no
   folder→DLC manifest** (`F10 E42`). The owner must decide whether season/lake/DLC5
   terrain is in scope and supply the entitlements; otherwise those stay declared
   out-of-scope with reasons. Coastal/Lakes/Rivers masks are shipped skirmish content
   (no entitlement check) — the open question is whether COORD opens the DLC5
   rivers/lakes ticket (rivers currently `OUT_OF_SCOPE`, `V15 §5.3/Q2`, `V16 O2`).
3. **Decision on a read-only donor runtime / GL trace** (known-key `.map` replay pack,
   GPU capture). Without it, runtime activation of the `;`-prefixed corpus,
   `bmTransparency` pass count and `hmapTex` binding stay permanently `[U]` (`X27 §9 Q2`).
4. **Sign-off on bookkeeping and pinning:** the `declared_unverified` /
   `blocking_unverified` split (`V15 Q1`), canonical capture size (240² vs 320²) and
   camera/ROI set (`V15 Q7`), and whether to fund the VMT-pointer discovery + Deep Ghidra
   re-lift (`X27 §9 Q1`). If the owner declines or cannot run the donor, no route is
   viable and parity stays **permanently UNVERIFIED** — reported as declared/accepted,
   never as "donor match" (`X39 §0 point 6`, `§8`).

### 5.3 Free tools to install (owner/COORD decision; none is required to continue)

From `V52 §7.2`, `X27 §7/§9`:

| Tool | Why it helps this stripped 32-bit Delphi/C++Builder target | Cost |
|---|---|---|
| **Ghidra 11.x** (NSA) | headless batch analysis + Python RTTI/vtable recovery; a true second lifter for the 4,265/12,254 garbled functions and a VMT-pointer-following discovery pass for the 23 missing anchors | free / open source |
| **IDR — Interactive Delphi Reconstructor** | purpose-built for stripped Delphi: class hierarchies, RTTI, DFM events, IDA/Ghidra-friendly maps — exactly the `X*`/`T*` problem | free |
| **ImHex** | pattern-language parser for `*.pattern` / `pattern.lib`; byte-accurate struct declarations, read-only hex inspector | free / open source |
| **Cutter / radare2** or **RetDec** | second-opinion decompilation where the built-in lifter produces unstructured pseudo-C | free / open source |
| **HxD** (or ImHex) | read-only hex inspection of donor `.map` / `.pattern` bytes | free |

Craft Anything Deep mode remains the primary tool. A second lifter plus VMT-pointer
discovery is the cheapest path to shrinking the garbled/missing-function ceiling; a
permitted donor runtime/GL trace is the only path to settling runtime intent.

---

## 6. What would change the verdict from UNVERIFIED to "donor match"

**Short answer: nothing within the swarm's current rules and vocabulary can.** There is
no "donor match" tier in `V15 §2` — no tier above 2 exists by construction — and the
phrases "donor match / parity / confirmed" are explicitly forbidden in owner-facing
reports (`X39 §4`, `A05 §4.2`). Even if every gate went green, the best honest outcome
remains **"gates green / internal consistency PASS / donor parity UNVERIFIED"**
(`V57 §5.3 item 12`, `V52 §7.3`, `HANDOFF §7 #4`).

The **only conceivable chain** that could justify even discussing a demonstrated match
(conditions, not achievements — `V57 §5`) is:

1. **Owner supplies a genuine donor GPU frame** at the same size, seed keys, map type,
   season, camera and ROI as the candidate capture (`X39 Route A`; `V15 §2/§8 Q8`;
   `X07 §8 Q2`; `V52 §7.3 #1`). No one has produced one. This is **necessary but not
   sufficient** (`X39 §4`).
2. **An admissible candidate capture exists:** windowed non-blank 1280×720 PNG,
   `script_error_lines = 0`, pinned seed/camera/size, identical fractional ground ROI on
   both sides; metric and visual fields separate; no metric overrides the visual read
   (`A05 G0-a…e`, `spec §12.6`).
3. **Inputs are actually matched and labelled:** A/B-L1 (matched seed keys, size enum,
   map type, season, pinned camera, same ROI, both sides generated/rendered, each labelled
   `DONOR (owner-run)` / `PORT (candidate)`) or A/B-L2 (owner's saved `.map` imported after
   the D04 §7 importer upgrade so both sides render the same geometry — a rendering A/B,
   not a generator A/B). An unmatched seed, unknown `randkey0`, or an unverified ROI
   degrades the comparison to direction-of-movement only (`X39 §4`).
4. **Fresh gates green, not stale:** freeze tree, resolve V36 C1–C14 and V16 O1–O14,
   run `A′-0…A′-3` then `D-0…D-6`, determinism D1/D3 byte-identical at zero tolerance,
   `assert_clean` CLEAN with 575/582/585 acknowledged, `app/**` byte-identical (`V57 §5.2`).
5. **Spec/toolchain evidence completed:** §§01–14 marked READY, X15-conformant root
   manifest and I05 atlas/I03 feed landed (`V62 §6`), N17 bands populated and signed,
   `blocking_unverified = []` (`V57 §5.3`).
6. **A demonstrated match, ruled by COORD explicitly:** a byte-identical geometry plus
   pixel-identical frame under the proven-matched manifest — not "looks similar". Only
   after COORD signs that ruling would `parity.status` change, and even then the reviewer
   line must be updated from "No donor GPU A/B frame exists" to "Donor frame supplied by
   owner; parity still UNVERIFIED pending demonstrated match" (`X39 §4 note`).

Until **all six** hold, `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, and any
claim of parity or "cloned terrain" is a defect. A green `compare_shots.py` number, a
still, or a self-consistent visual score cannot substitute for items 1–6
(`V15 §2/§6`, `X39 §4`).

---

## 7. Five-line summary

1. **[O] Not cloned (V57 §4):** byte-faithful spec + dormant scaffold; no donor A/B frame, no gate result, no runtime observation → `PORT APPROXIMATION`, parity `UNVERIFIED`, `RESULT IS NOT GOOD`.
2. **[D] Decoded vs unverified:** 710/710 `.pattern`, 680-section `pattern.lib`, 4,466 masks, 7 cfg, exact LCG, opcode-level stamp/blend, 124 tile ids — but 22.54%/54.7% garbled functions, 23/34 missing anchors, packed `.bind` (7.96), 972 `;`-prefixed excerpts with execution `[U]`, and no reference for five visual classes (`X27`, `X36`).
3. **[O] Built but inert-by-default and ungated:** I01–I13 modules/tools, N14 composer, I10 canonical shader, I11 seam (`features.terrain.backend` = `legacy`/`donor`, default legacy, no stock config key); V61/V65 static API verdicts are not gate results; V62's 780-file asset tier lacks atlas/feed/root manifest; no gates run, all verdicts `TODO(COORD)`.
4. **[U] No class is donor-matching:** every landscape class has tier-1 evidence *prepared but unsigned* (D3 not run) and tier-2 criteria *drafted but unobserved* (no capture); rivers `OUT_OF_SCOPE`, quarries `[D]/[I]`; parity 3 throughout, nothing upgraded (`V15 §4`, `HANDOFF §3`).
5. **[I] Next:** COORD steps 0–8 (freeze → contradictions → parse → assets → adapters → I12 → legacy gates → donor opt-in → sign-off); OWNER-ONLY same-camera 320² donor capture + manifest per X39, DLC entitlements/scope, runtime-trace decision, and free Ghidra/IDR/ImHex/Cutter/HxD — otherwise parity stays permanently UNVERIFIED and "donor match" is never claimed.

---

*End of V81. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V81_owner_decision_packet.md`). Read-only: every claim re-read against a second landed document; no source, shader, asset, config, test, result JSON, git, runner or Godot state changed; no donor binary executed or copied; no capture, gate result, reference image or parity metric invented; no PASS/green/parity claim asserted.*
