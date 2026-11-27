---
id: PORT1TO1-B-ANGLE-FINAL-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER B-ANGLE-FINAL — definitive final class-B outcome table (original B1–B14 + new NB-1..NB-7) for the full 1:1 Cossacks 3 donor port"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; P0-1..P0-8 remain open; six-condition chain 0/6 CLOSED; class-B static results never close class-A value/behaviour items; NB-4 is the only new numeric derivation [D] and NB-2's field-default table is a parser binding [D], neither is a parity or behaviour closure; no donor GPU A/B frame; no approximations; no parity claim"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc file reads only. No source, shader, asset, config, test, fixture, result JSON, backup, queue file or git state written; no donor binary executed/captured/copied; no Godot process, runner job, gate, harness, replay or port capture run. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_index.md (baseline index: §1 B1–B14, §2 per-row [D]/[U], §3 NB-1..NB-7, §4/§5 discipline)
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (rows 238–248: B6/B9/B10 landed; NB-2/NB-3/NB-4/NB-7 DONE; NB-5 DOING; IMPL-RANDKEY-DERIV DOING; B-ANGLE-FINAL DOING)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b6_g0.md, DEC_U_b9_wpn_shield.md, DEC_U_b10_skirmish_tables.md (the three original B candidates that landed after the index)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb1.md, DEC_U_nb2.md, DEC_U_nb3.md, DEC_U_nb4.md, DEC_U_nb7.md (new-candidate reports landed after the index)
---

# PORT1TO1 — final class-B outcome table (2026-11-27)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, ROI, still, hash or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`. **Class-B static results never close class-A value/behaviour items** (`PORT1TO1_u_classify.md §1 rule (ii)`, `§5`; `PORT1TO1_b_angle_index.md §4`): CLOSED-STATIC / CLOSED-NEGATIVE settles only the named static question; a structural closure is not a value closure. `blocking_unverified` is non-empty (P0-1, P0-1b, P0-2…P0-8 plus the §2 tails), so the verdict is **`RESULT IS NOT GOOD`** unconditionally. No approximation is authorised; no donor GPU/runtime session was executed by this worker; no parity claim is made.

---

## 0. Method, status key and counting rule

- **EXECUTED** = a delivered read-only report exists whose role/ticket explicitly attacks that candidate's §4 angle (or its named sub-angle), with byte/text evidence. **PENDING** = no such report file was observed in the corpus at this read; where the plan shows an active worker, its plan row and ticket id are quoted.
- Outcome labels are the executing reports' own `[O]`/`[D]`/`[I]`/`[U]`/CLOSED-STATIC/CLOSED-NEGATIVE labels. This table promotes nothing, closes nothing and re-tags nothing in source. A byte-proven *structural* fact (`[D]`) is not a promoted *generator value* and never closes a class-A item.
- This worker read docs only. No donor binary was executed, no GPU frame captured, no harness/gate/replay run, no port capture compared. All execution-status statements are report-to-report observations `[O]`/`[D]` over the named files.

---

## 1. Delta since `PORT1TO1_b_angle_index.md` (the reason this table supersedes §1/§3 of the index)

| Change | Evidence (read-only) | Effect on outcome |
|---|---|---|
| **B6, B9, B10 were NOT EXECUTED in the index and are now EXECUTED** | `PORT1TO1_PLAN.md:249-251` rows 238–240 DONE; `DEC_U_b6_g0.md`, `DEC_U_b9_wpn_shield.md`, `DEC_U_b10_skirmish_tables.md` all `status: DELIVERED__…` | Original B count becomes **14/14 EXECUTED** (B4, B5 still partial). B6/B9 promoted zero values; B10 promoted byte-proven *static* literals to `[D]` only (§2). |
| **New NB-2 relief fields landed** | `DEC_U_nb2.md` (DELIVERED); `PORT1TO1_PLAN.md:253` DONE | Property table + parser field-default table + wrapper arities `[D]` (§3.2); no per-pattern float promoted. |
| **New NB-3 LOS quadtree landed** | `DEC_U_nb3.md` (DELIVERED); `PORT1TO1_PLAN.md:254` DONE | Flat XZ segment probe, placement/selection callers only; FOW call edge `[U]`. |
| **New NB-4 randkey derivation landed** | `DEC_U_nb4.md` (DELIVERED); `PORT1TO1_PLAN.md:255` DONE | U-KEY derivation formula CLOSED `[D]` — the only new numeric derivation `[D]` (§3). |
| **TOSW ctor sweep landed under worker `DEC-U-NB1`** | `DEC_U_nb1.md` (DELIVERED); `PORT1TO1_PLAN.md:252` row 241 "New class-B NB-6 ctor sweep … `DEC_U_nb1.md`" | Full-binary negative `[D]`; U12 provenance stays `[U]`. See numbering collision (§3.1). |
| **NB-7 S0 kernel body landed** | `DEC_U_nb7.md` (DELIVERED); `PORT1TO1_PLAN.md:257` row 246 DONE | Window is registration strings, no kernel body; S0/VM `[U]`. The task brief for this worker called NB-7 "pending"; the repo file and plan both show DELIVERED/DONE — this table follows the repo, not the brief shorthand. |
| **NB-5 copy site still active** | `PORT1TO1_PLAN.md:256` row 245 DOING, `DEC-U-NB5` active; no `DEC_U_nb5*.md` observed | PENDING; U-copy-site stays `[U]` (carried from B8). |
| **`IMPL-RANDKEY-DERIV` active** | `PORT1TO1_PLAN.md:258` row 247 DOING, `IMPL-RANDKEY-DERIV` active; no report file observed | The randkey *law* is `[D]` as a static derivation in `DEC_U_nb4.md`; implementation/telemetry is an active lane, not a parity or behaviour closure and not written by this worker. |

---

## 2. Final outcome — all 14 original class-B candidates (B1–B14)

| # | Candidate | Status | Report id(s) | What became `[D]` / CLOSED / stayed `[U]` |
|---|---|---|---|---|
| **B1** | W-U12 static sweep (U12-A2/R1) | **EXECUTED** | `DEC_U12_caller_walk.md`; residual `DEC_U_nb1.md` (index NB-6) | Copy/allocation GL edges, table-slot reading, registrar pool shape, `C+0x4c` LOAD, `TOSW*` zero code xrefs, full-binary zero `+0x4c/+0x8/+0xe0` stores — all structural `[O]/[D]`/`CLOSED-NEGATIVE`. **Every U12 provenance value stays `[U]`**; port hard-fail (no water) kept. |
| **B2** | U3-REG whole-binary caller sweep | **EXECUTED** | `DEC_U3_reg_sweep.md`; partial `DEC_U_nb1.md` | 7-name CODE table + schema→slot mapping `[D]`; two-specimen absence `[O]`; H1-vs-H2 neither proven. **Live texture name/id, unit, per-map tuple, U-REG/U-REG-TEX enumeration stay `[U]`.** |
| **B3** | T-SEED / T-CALLBACK | **EXECUTED** | `DEC_U_genseed_deep.md`, `DEC_U_place_seed_deep.md`, `DEC_U_nb4.md` | LCG/seeder/caller set/RTTI arities/verbatim reseeds `[O]/[D]`; **U-KEY derivation formula now CLOSED `[D]` via NB-4**. **U-KEY2, U-MAP, U-SS/U-ONLY/U-TIME, runtime timing stay `[U]`.** |
| **B4** | T-SMOOTH / MINMAX / MOD | **EXECUTED (partial)** | `DEC_U_smooth_kernel_deep.md`, `DEC_U_nb7.md` | `mb: Integer` correction `[D]`; alternative entries + commented kernel CLOSED-NEGATIVE; S0 window proved to be registration strings, no kernel body. **U-S0-KERNEL/SCOPE/VM/MB3 and MINMAX/MOD trip-count stay `[U]`.** |
| **B5** | T-VER / MDEN / HF / OBJ | **EXECUTED (partial)** | `DEC_U_tver_deep.md`, `DEC_U_nb2.md` | Header/version literals + mapsize enum `[D]`; port pin 92/240² **mismatches** shipped 53-envelope/320²-384²; NB-2 property table + field-default table `[D]` (§3.2). **Per-pattern floats, `minesdensity` rounds, 4th-word 64-vs-25920, atlas literals stay `[U]`.** |
| **B6** | T-G0 forest density | **EXECUTED** (was NOT EXECUTED in index) | `DEC_U_b6_g0.md` | No `ig/fdens→count` native edge in packed bytes `[D]` CLOSED-STATIC; shipped-mask non-start G≠0 = 0 on 5 re-decoded masks `[O]`/`[D]` port match. **Live count dials / T-G0 stay `[U]`; zero value promoted; no density invented.** |
| **B7** | U-speed-consumer / T-SPEED | **EXECUTED** | `DEC_U_speed_consumer_deep.md` | Byte-proven two-channel native shape (Float step + Integer interval), closed writer set `[D]`. **All rate/base/turn/terrain values stay `[U]`.** |
| **B8** | E-COLL / LOS | **EXECUTED** | `DEC_U_coll_census_deep.md`; NB-5 pending | Full 369/354 mask census, identity rotation, packed-metadata false positives, `renderer+0x40` disjointness CLOSED-STATIC. **U-copy-site stays `[U]` (byte proof goes the other way); U12-ships/forms, inertia engine, LOS consumer stay `[U]`.** |
| **B9** | E-WPN / SHIELD | **EXECUTED** (was NOT EXECUTED in index) | `DEC_U_b9_wpn_shield.md` | Packed-CODE weapon/shield angle executed as a **bounded negative** `[D]` (no native table, no wrapper arity, no damage matrix, no live override in stored bytes; packed-region reserve stated); 77/77 weapon + 33/33 protection text closures carried. **W1–W6 shield/mount/upgrade application values stay `[U]`; zero promotions; no neighbour-sid copy.** |
| **B10** | S-SKIRM tables | **EXECUTED** (was NOT EXECUTED in index) | `DEC_U_b10_skirmish_tables.md` | Byte-proven **static** values promoted `[D]`: 54-field `gProfile` shipped defaults, `resbalance≡0` + dormancy, mercy CLOSED-NEGATIVE, `victorystate` enum + first-stamp-wins, score-victory ABSENT, arities/text shape. **All live behaviours (AI-T, MERCY/VIC, SCORE, PROF, TICK, F1) stay `[U]` behind six zero-mismatch batteries.** No class-A item closed. |
| **B11** | S-AI-A1…A8 | **EXECUTED** | `DEC_U_econ_deep.md` | Script-side-only shape + native helper arities/negatives `[O]/[D]`; **ZERO promotions; U-A1…A8 + tails stay `[U]`.** |
| **B12** | S-MKT / Q2 / VIC / PEACE | **EXECUTED** | `DEC_U_peace_deep.md`, `DEC_U_econ_deep.md` | Peace-name absence, `GetGameTime` VA, no comparator wrapper, latch-and-order `[O]/[D]`. **Equality tick, port identity, capture rows stay `[U]`; ZERO promotions.** |
| **B13** | U-DSP | **EXECUTED** | `DEC_U_tick_deep.md` | Table names/VAs, thread-object existence, ascending global loops, data-as-code discard `[O]/[D]`; no dispatch loop literal. **`[U]-DSP`, `[U]-THR`, U-S1…S8 stay `[U]`.** |
| **B14** | N-11 FOW engine surface sweep | **EXECUTED** | `DEC_U_fow_numeric_deep.md`, `DEC_U_fow_persist_deep.md`, `DEC_U_fow_occ_deep.md` | Full name/VA/arity census + absences `[O]/[D]`; `XFOWRender` `.rsrc`-only premise refined to CODE RTTI also found. **Every numeric (cell size, combine, occlusion, persistence, sampler domain, layout, knob defaults) and OCC-a…d stays `[U]`.** |

**Counts:** EXECUTED **14/14** (B4, B5 partial); PENDING **0**. This supersedes the index's "11 executed + 3 not executed" (`PORT1TO1_b_angle_index.md:57`) because B6/B9/B10 landed afterwards. **No original B execution closed a class-A value/behaviour item and no execution made a parity claim.** B10 added byte-proven static `[D]` literals inside class B only; it did not close a class-A behaviour item.

---

## 3. Final outcome — new class-B candidates NB-1..NB-7

### 3.1 Numbering note (read before using the table)

`PORT1TO1_b_angle_index.md §3` labels the U-REG-TEX residual **NB-1** and the whole-binary `TOSW*` ctor→field-store sweep **NB-6**. The delivered worker report `DEC_U_nb1.md` (worker id `DEC-U-NB1`) attacks the **NB-6** angle, and `PORT1TO1_PLAN.md:252` calls it "New class-B NB-6 ctor sweep". The task brief for this worker used the shorthand "NB-1 (TOSW ctor)". Both readings are recorded below; no candidate was silently renumbered by this table.

| New id (index §3) | Status | Report id | What became `[D]` / stayed `[U]` |
|---|---|---|---|
| **NB-1** — U-REG-TEX residual (`TOSW*` vtable + `ImageClassName` factory; write into `C+0x4c`/`C+0xe0`; terminate iff each ctor has 0 unvisited xrefs) | **PENDING as index-labelled** — no dedicated report observed. Its TOSW-ctor sub-angle was executed under index **NB-6** by `DEC_U_nb1.md` (the "NB-1 (TOSW ctor)" of the task brief). | `DEC_U_nb1.md` (sibling-labelled NB-6); upstream `DEC_U3_reg_sweep.md` | Full-binary enumeration `[O]/[D]`, zero ctor→`C+0x4c`/`C+0xe0`/`texture+8` stores `[D]` negative. **`TOSWRefTextureImage` stays suggestive `[I]`; `HeightMapTexUnit` and all U12 provenance stay `[U]`; the NB-1 termination condition (visited ctors with 0 unvisited xrefs) is not claimed met** — `DEC_U_nb1.md:79` leaves a computed-pointer-respecting carve of `sub_4e72f8` open. |
| **NB-2** — HF/MDEN/OBJ relief residual (refines B5) | **EXECUTED** | `DEC_U_nb2.md` | **Field-default table `[D]`** (§3.2 below) + CODE property table VAs/order, parser bindings, 4 wrapper arities, `RotationAngle=0` sample, prefix-collision rule `[O]/[D]`; 5 shipped `pattern.lib` section concretes transcribed `[O]`. **No per-pattern float promoted into the generator; angle-use, `Objects[]→mesh` binding, `HeightFieldMax` outside-stamp consumer, 675 un-dumped sections, MDEN 4th word and atlas literals stay `[U]`.** |
| **NB-3** — LOS native call-edge (refines B14) | **EXECUTED** | `DEC_U_nb3.md` | Verbatim signatures + file-off/RVA/VA `[O]`; argument shape is a flat XZ segment probe selected by a Topology `prior`/`quadtree` pair `[D]`; 3 live script callers + 1 dead comment, all placement/selection; 2 `GetFOWLOSData` sites pass plain `(x,z)>0` `[O]`. **No byte-proven FOW call edge; `TraceLineQuadTree(Ext)` classified as placement/selection ray on positive caller evidence; NB3-a/b and OCC-a…d stay `[U]`. No blocker/slope/step invented.** |
| **NB-4** — `GenerateMapRandKey` derivation body (refines B3) | **EXECUTED** | `DEC_U_nb4.md` | **The only new numeric derivation `[D]`:** impl `0x6ac244` registered from `sub_69a70c`; body `eax=$7FFFFFFF; call Random(sub_403a0c); cdq; store(hi→key0, lo→key1)` ⇒ **`randkey0 = 0` constant, `randkey1 = Random($7FFFFFFF)` single draw**; var-out word order + slot offsets `+0x18/+0x1c`, `+0x108/+0x10c` `[D]`. Static **U-KEY CLOSED `[D]`**. **Runtime invocation timing, U-KEY2 (key0-discard), U-MAP, U-SS/U-ONLY/U-TIME stay `[U]`.** `IMPL-RANDKEY-DERIV` is an active implementation lane (`PORT1TO1_PLAN.md:258`), not a parity/behaviour closure. |
| **NB-5** — `U-copy-site` native side (refines B8) | **PENDING** — no `DEC_U_nb5*.md` observed; `PORT1TO1_PLAN.md:256` row 245 DOING, `DEC-U-NB5` active (`renderer+0x40 0x48→0x50` copy instruction chain) | — (plan ticket `DEC-U-NB5`) | **No value promoted; U-copy-site stays `[U]`**, carried from `DEC_U_coll_census_deep.md §4.3`. The census proved the collision centred-write path statically disjoint from the renderer mesh path; this remains a terrain-mesh static/capture angle. |
| **NB-6** — `TOSW*` whole-binary ctor→field-store sweep (refines B1/B2) | **EXECUTED** | `DEC_U_nb1.md` (worker `DEC-U-NB1`) | 8-name family counts/VAs/sections `[O]/[D]`; sole static data edge `0x812999 → 0x812a44`; complete store lists of `sub_8127e0/sub_812a44/sub_7744cc/sub_7763f8` with zero `+0x4c/+0x8/+0xe0` writes `[D]`; sole `C+0x4c` access is the `0x6760a8` LOAD. **U12 provenance (class, w/h/format/mips, sampler unit, matrix, pool rule, GL name) stays `[U]`; port hard-fail kept.** Static non-link bounded by the builtin DB, not a runtime absence proof. |
| **NB-7** — S0 kernel body (refines B4) | **EXECUTED** (see §1 note on the brief's "pending") | `DEC_U_nb7.md` | `0x6a3900–0x6a3b80` proved to be DScript registration strings; linear decode yields 1-byte ASCII aliases, not code; `function_find` null and 0 xrefs/0 LE-imm32 hits for all three S0 VAs `[O]`; `sub_608238` shown to be a 331-indirect-callee registrar `[O]/[D]`. **No neighbour array/loop/load/store, no radius/sample count, no weights, no VM-dispatch confirmation; U-S0-KERNEL/SCOPE/VM/MB3 stay `[U]` with the 320²+640² hook byte-dump termination. No blur/kernel invented.** |

**Counts:** EXECUTED **6/7** (NB-1 as index-labelled is PENDING; its TOSW-ctor sub-angle is EXECUTED as NB-6); PENDING **1** (NB-5). **One new numeric derivation became `[D]` (NB-4). NB-2's `[D]` are byte-proven parser field-defaults, not promoted generator values. No new candidate closed a class-A item or claimed parity.**

---

## 3.2 Highlight A — NB-4: the only new numeric derivation `[D]`

From `DEC_U_nb4.md §2.1–§3` (all pinned `t_87f0f3c130b0`, evidence ids `ev_e3d17104…/ev_dc243dd3…/ev_073af193…/ev_2aee671b…–ev_54398df9…`):

```pascal
procedure GenerateMapRandKey(var randkey0, randkey1: Integer);
begin
  randkey1 := Random($7FFFFFFF);  // one Delphi LCG draw, 0..$7FFFFFFE
  randkey0 := 0;                  // cdq sign word of the non-negative draw
end;
```

- Single input constant `$7FFFFFFF`; no map-name pointer, settings pointer, second constant, second `Random` call or time/hardware source in the body `[D]`.
- Var-out order: 1st var (`eax`) = `randkey0` = hi word; 2nd (`edx`) = `randkey1` = lo word; stored layouts `+0x18/+0x108 ← randkey1`, `+0x1c/+0x10c ← randkey0` `[D]`.
- Scope of the closure: **U-KEY derivation formula only.** `DEC_U_nb4.md:135` explicitly leaves U-KEY2/U-MAP/U-SS/U-ONLY/U-TIME `[U]`. **This is a static donor-law derivation, not a port behaviour match, not a gate pass and not parity.**

## 3.3 Highlight B — NB-2 field-default table (byte-proven parser bindings `[D]`)

From `DEC_U_nb2.md §3` (`sub_75c314`, 237 insns; every CODE table VA consumed once as an `edx` immediate feeding a typed reader stored into `[ebx+off]`). Reader-type names are `[I]` (inferred from `cl/ecx/push-f32` patterns and `fstp` vs `mov` sinks), not recovered prototypes.

| Property (table VA) | Struct offset | Pushed default `[O]` |
|---|---|---|
| `Name` (`0x75c6b8`) | `+0x14` | string slot (no numeric default) |
| `Width` / `Height` (`0x75c6c8`/`0x75c6d8`) | `+0x1c` / `+0x20` | `0` / `0` |
| `TilesStand` / `GameObjectsStand` / `DecalsStand` | `+0x18` / `+0x19` / `+0x1a` | `True` / `True` / `True` |
| `HeightFieldStand` / `Replace` / `ReplaceForWater` / `UseRndScale` | `+0x39`/`+0x3a`/`+0x3b`/`+0x3c` | `True` / `False` / `False` / `False` |
| `HeightFieldMinScale` / `MaxScale` / `Scale` / `TerrainScale` / `ObjectsScale` / `RotationAngle` | `+0x40`/`+0x44`/`+0x48`/`+0x68`/`+0x6c`/`+0x70` | **`1.0f` each** (`push 0x3F800000`) |
| `HeightFieldSmooth` / `SmoothRadius` / `SmoothFactor` / `SmoothOffset` | `+0x4c`/`+0x50`/`+0x54`/`+0x58` | `False` / `0` / `0` / **`2`** (only non-zero int default) |
| `PatternMaskStand` / `PatternMaskReverceStand` / `CollisionStand` | `+0x80`/`+0x81`/`+0x82` | `False` / `False` / `True` |
| `OffsetX` / `OffsetZ` / `HeightFieldOffset` | `+0x74`/`+0x78`/`+0x64` | `0.0f` each (`push 0`) |
| `ObjectsOffset` / `ObjectsHeightOffset` / `IgnoreMatrix` / `ObjAutoOffset` | `+0x7c`/`+0x7d`/`+0x7e`/`+0x7f` | `False` each (scalar gates, **not** `Objects[]`) |
| `HeightFieldMin` / `HeightFieldMax` (`0x75c998`/`0x75c9b0`) | `+0x5c` / `+0x60` | **`1.0f` / `1.0f` — one, not zero** |
| `Summer` / `NativeSeason` / `Autumn` / `Winter` / `Spring` | `+0x84`–`+0x88` | enum→bool / `True` each |

- Wrapper arities byte-proven `[O]`: `StandPatternWithAngle` **7**, `StandPattern` **5**, `StandPatternAdv` **10**, `StandPatternWithAngleAdv` **12**; wrapper bodies remain undiscovered `[U]`.
- Downstream stamp reader `sub_755f30` reads `+0x48`, `+0x5c`, `+0x64`, `+0x68` and **never** `+0x60` (Max) `[O]` carried; `HeightFieldMax` has no in-stamp consumer `[U]`.
- **These defaults are a class-B parser-binding fact only.** No `pattern.lib` float was promoted into the port; U-HF/U-ANG/U-OBJ/U-MAX/U-S0/U-MDEN/U-ATLAS remain `[U]` with §6 zero-mismatch experiments (`DEC_U_nb2.md §§6–7`).

---

## 4. Discipline, parity and verdict

- **Class-B static results never close class-A value/behaviour items.** `PORT1TO1_u_classify.md §1 rule (ii)` and `§5`: CLOSED-STATIC / CLOSED-NEGATIVE settles only the named static question; a structural closure is not a value closure. Reflection provenance, live hmap tuple, tick order, blend curve, save bytes, RNG attribution, projection numerics, FOW grid, shield/mount application and skirmish behaviour stay `[U]` until class-A zero-mismatch experiments terminate. **This table closes zero P0 items and wires zero values into port code.**
- No class-A item was made closeable by these passes: all 42 class-A items still require an owner/COORD GPU/GL trace, debugger/watchpoint, fixed-seed hash battery or paired-save run forbidden to workers. P0-1…P0-8 all remain open.
- `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`. No donor GPU A/B frame exists; no same-camera donor/port frame was produced or examined by this worker. Six-condition chain **0/6 CLOSED** (conditions 2 and 6 PARTIAL port-internal only, 1/3/4/5 BLOCKED — `PORT1TO1_u_classify.md §6 claim 5`, `PORT1TO1_parity_chain.md:38-58`, `PORT1TO1_claim_recheck4.md:143-144`).
- `blocking_unverified` is non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the §2/§3 tails), so **`RESULT IS NOT GOOD`** unconditionally — including despite NB-4's `[D]` derivation and NB-2's `[D]` field-default table.
- **No approximations** are adopted or authorised; no `[U]` promoted to a wired value, no test/gate weakened, no threshold or band flipped; exactly one repository file written.

---

## 5. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | 14 original B candidates enumerated: **14/14 EXECUTED** (B4, B5 partial); B6/B9/B10 landed after the index. Counts reconcile and supersede the index's 11+3. | `[O]`/`[D]` over §2 + `PORT1TO1_PLAN.md:249-251` |
| 2 | 7 new NB candidates enumerated: 6 EXECUTED (NB-1's TOSW-ctor sub-angle executed as index-NB-6 via `DEC_U_nb1.md`), NB-5 PENDING (plan DOING). Numbering collision stated explicitly, nothing silently renumbered. | `[O]`/`[D]` §1/§3.1 |
| 3 | NB-4 is the **only** new numeric derivation `[D]` (`randkey0=0`, `randkey1=Random($7FFFFFFF)`); NB-2's `[D]` are parser field-defaults, not promoted generator values; no other NB candidate promoted a value. | `[D]` `DEC_U_nb4.md §2`, `DEC_U_nb2.md §3` |
| 4 | B10 promoted byte-proven static literals `[D]` inside class B only; B6/B9 promoted zero values; all live behaviours in B6/B9/B10 and every NB candidate stay `[U]` with zero-mismatch experiments. | `[D]` `DEC_U_b6_g0.md`, `DEC_U_b9_wpn_shield.md §4/§6`, `DEC_U_b10_skirmish_tables.md §5/§6` |
| 5 | Class-B static results never close class-A value/behaviour items; no P0 closed; chain 0/6; `blocking_unverified` non-empty ⇒ `RESULT IS NOT GOOD`. | `[D]` `PORT1TO1_u_classify.md §1/§5/§6`, `PORT1TO1_b_angle_index.md §4/§5` |
| 6 | `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; no donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared by this worker. | `[O]` scope guard |
| 7 | No approximation adopted, no `[U]` wired, no I11/preserve-only file touched; exactly one repository file written. | `[O]` scope guard |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the tails); six-condition chain 0/6 CLOSED. **RESULT IS NOT GOOD.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made. Class-B results never close class-A value/behaviour items.

*End of PORT1TO1_b_angle_final. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
