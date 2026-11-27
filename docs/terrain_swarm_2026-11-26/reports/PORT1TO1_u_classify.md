---
id: PORT1TO1-U-CLASSIFY-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER U-CLASSIFY — mechanical A/B/C/D classification of every still-open [U] item"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; P0-1..P0-8 remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc file reads and read-only scans only. No source, shader, asset, config, test, fixture, result JSON, backup, queue file or git state written; no donor binary executed/captured/copied; no Godot process, runner job, gate, harness, replay or port capture run. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md  (current definitive remaining-[U] register; §1 P0, §2 tails, §4 new items, §5 settle classes)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_final_register.md  (base register; §0 P0-vs-tail split)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tree_recheck.md  (TR-2: register stale vs eight post-guard deep passes)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md  (§0 settle-class rule, §10 preserve-only P-1..P-9)
  - eight post-guard deep reports: DEC_U12_deep.md, DEC_U_fow_numeric_deep.md, DEC_U_blend_deep.md, DEC_U_save_deep.md, DEC_U_tick_deep.md, DEC_U_select_deep.md, DEC_U_water_shader_deep.md, DEC_U_hmap_num_deep.md
---

# PORT1TO1 — mechanical A/B/C/D classification of all still-open `[U]` items (2026-11-27)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, ROI, still, hash or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `blocking_unverified` is non-empty (P0-1…P0-8 plus the tails), so the verdict is **`RESULT IS NOT GOOD`** unconditionally. No approximation is authorised; no donor GPU/runtime session was executed by this worker; no parity claim is made.

---

## 0. Source corpus and method

- The task names `PORT1TO1_p0_final_status.md` as **pending**. A repo-wide search (`**/PORT1TO1_p0_final_status.md`, content grep `p0_final_status`) returned **no file and no reference**. There is therefore no final-status report to classify; the classification is built from the **current definitive register** `PORT1TO1_u_register_update.md`, cross-checked against `DEC_U_final_register.md`, `PORT1TO1_owner_decisions.md`, `PORT1TO1_tree_recheck.md` and the eight post-guard deep reports. This is an observed fact, not a silence to be filled by inference.
- `PORT1TO1_tree_recheck.md:72` (TR-2, MINOR) states the register predates the eight deep passes and lists newly narrowed unknowns that the register does not enumerate: **U12-A2, E-SURFACE, FOW numeric anchors, blend B1/B2/FB, save container, tick interleave, V1/V2, per-map hmap W/H/Min/Max**. Those deep-report rows are therefore included below so the classification covers "all still-open `[U]` items", not only the register rows. Items are **deduplicated by ID**: a deep row that merely refines a register row (e.g. `U-NUM` → `P0-2/W-U3-NUM`) is counted once.
- Every classification below is `[D]` over the cited reports' own explicit settle class / §6 experiment text. Nothing was promoted, closed, re-tagged in source, or invented.

---

## 1. Classification rule (mechanical, deterministic)

Each catalogued still-open `[U]` item receives **exactly one** primary class. Precedence, applied in order:

1. **C — owner policy / decision item** (preserve-only, matched-input/experimental setup, governance text repair, chain-condition/manifest decision). Such an item cannot be closed by any capture; it is an owner/COORD choice.
2. **D — cosmetic tail** explicitly labelled non-blocking in `DEC_U_final_register.md §0` / `PORT1TO1_u_register_update.md §2.5`, i.e. a decorative or absent-in-donor item that cannot by itself establish or break a 1:1 visible/simulation comparison and is never promoted to close a P0.
3. **B — additional static decomp still plausibly possible.** The latest reports name a concrete, still-unperformed **read-only** angle: a STATIC class in the register's `Class` column that is not marked CLOSED, or a §6 experiment that is an xref/caller sweep, file:line re-read, CODE-table extension, census or absence sweep. The exact next angle is recorded in §4.
4. **A — donor GPU/runtime capture required and forbidden to workers.** Everything else: the remaining act is an owner-authorised donor GPU/GL trace, a debugger/watchpoint session, or an owner/COORD fixed-seed hash or paired-save battery, with no named static angle left.

**Two discipline rules carried verbatim from `PORT1TO1_u_register_update.md:44-45`:** (i) CLOSED-STATIC / CLOSED-NEGATIVE settles only the named static question, not the behavioural item hanging off it; (ii) a structural closure is not a value closure. Consequently a class-B static result **never closes** a class-A value/behaviour; it only narrows structure or absence. The class assignment describes the **next available act**, not permission to substitute a value.

---

## 2. Master item register (all 71 still-open `[U]` items)

Legend: **A** runtime capture/harness, workers forbidden · **B** static decomp angle remains · **C** owner policy/preserve/experimental · **D** cosmetic tail. Basis column cites the register/deep row and why it falls in that class.

### 2.1 Domain W — water / render (15 items)

| ID | Cls | Basis |
|---|---|---|
| P0-1 / W-U12 (A/B/C/T/S/P reflection provenance, size/mips/unit, projective matrix, waves alias, pbuffer) | A | `RUNTIME-GPU`; live GL object history/matrix only |
| P0-1b / W-U4* (live scalar tuple + W0/W1, S10/S11) | A | `RUNTIME-GPU (structure STATIC CLOSED)` |
| P0-2 / W-U1 (live shader path DEV/BUILTIN/LEGACY) | A | NOT-CUSTOM proven static; live path needs `glShaderSource` hook |
| P0-2 / W-U3-NUM (live hmapMin/Max/W/H) | A | `RUNTIME-GPU`; getter values are engine runtime state |
| P0-2 / W-U3-TEX (`hmapTex` GL identity/provenance) | A | `RUNTIME-GPU`; live GL texture object |
| P0-2 / W-U5 (writer of double `C+0xc8`, live `time`) | A | `RUNTIME-GPU`; HW write-watchpoint required |
| P0-2 / W-U6-UV/WIND (dividend, winding, diagonal, cull) | A | `RUNTIME-GPU`; attribute/index arrays + GL state live |
| W-R1 (material floats, light+modelview, alpha arithmetic, `tiaAlphaFromIntensity` converter) | A | `RUNTIME-GPU` uploads; enums already `[O]` CLOSED |
| U-NUM (per-map live `(hmapW,H,Min,Max)`) | A | `DEC_U_hmap_num_deep §6 U-NUM`; GPU break + uniform hook |
| U-MAP (map bytes → live tuple linkage) | A | needs the captured U-NUM tuple; no static file→word link |
| U-TEX (`hmapTex` target/name/w/h + provenance) | A | `DEC_U_hmap_num_deep §6 U-TEX`; GL trace |
| N-9 gamma `U-G*` (LUT bytes, `fade`, tone/cont uniforms, selected program) | A | data-only/runtime; `U-G6` CLOSED-NEGATIVE, no static source |
| N-10 N17 feed-chain runtime bindings (packed atlas grid, `glTexImage2D` tuple, variant byte, `RandomExt`, `Objects[]`→mesh) | A | `RUNTIME-GPU` zero-mismatch byte dumps |
| W-U12 static sweep (copy-helper caller walk + `TOSW*` ctor→field-store; U12-A2/R1) | B | `DEC_U12_deep §8` leaves this native read-only pass open |
| U3-REG whole-binary caller sweep (`FUN_0082f060/114`, `00739bf8`, `0082f86c`) | B | `DEC_U_hmap_num_deep §6 U-REG` is static-only; N-7 |

### 2.2 Domain T — terrain / generation (5 items, all B)

| ID | Cls | Basis |
|---|---|---|
| T-SEED / T-CALLBACK (`GenerateMapRandKey` body, `randkey0/1` consumers, `renderer+0x40` producer, indirect `+0x0b` copy) | B | `STATIC` consumers re-read + runtime dump for bytes |
| T-SMOOTH / MINMAX / MOD (`SmoothTerrain(x,-y,False,3)`, `minx/miny`, `probsmall…huge`, `640/((W+H)/2)`) | B | `STATIC (reads)` remaining |
| T-VER / MDEN / HF / OBJ (`gc_MaxTerrainTypeCount`, `gRecordGeneratorVersion`, `mapsize`, `minesdensity` rounds, `pattern.lib Objects[]`, 16×8 fallback) | B | `STATIC (most)` per register |
| T-G0 (`G=0` zero-density closure) | B | `STATIC` fixed-seed mask check |
| U-speed-consumer / T-SPEED (18 defined-but-dead speed constants, native `TrackPoint` integration) | B | full-tree `\.speed :=` / `rotatespeed :=` STATIC sweeps |

### 2.3 Domain E — entities / AAF / FX / collision (18 items)

| ID | Cls | Basis |
|---|---|---|
| P0-5 / E-B1 (blend weight curve `w(t)`, window unit, per-channel application) | A | `RUNTIME-GPU` R-B1 |
| P0-5 / E-B2 (blend-window frame fetch) | A | `RUNTIME-GPU` R-B2 |
| P0-5 / E-B3 (arg polarity / FB semantic `randomfbcycles|frame`) | A | `RUNTIME-GPU` R-B3; native names resolved, semantic open |
| P0-5 / E-C1 (`acmPlayOnce` hold-last vs snap-to-idle) | A | `RUNTIME-GPU` R-C1 |
| P0-5 / E-C2 (`Attack` vs `AttackEnd` handler timing) | A | `RUNTIME-GPU` R-C2 |
| P0-5 / E-W/W2/S/A/R (weapon→`attack1/2`, `death0/1/2`, sticky T18–T20, `prepare/trans/walkprepare`, `reaction` orphan) | A | `RUNTIME-GPU` fixed-camera batteries |
| E-B4 (movie `0..5` window applicability to units) | A | `RUNTIME-GPU` R-B4 |
| E-B/P1 (native per-tick animation player not localized) | A | packed `.bind` region; `DEC_U_blend_deep §3/§7`; runtime trace needed |
| E-B/RND (`System.Round` / float helper near AAF frame evaluation) | A | no helper in readable bytes; runtime trace needed (`DEC_U_blend_deep §6`) |
| E-DMG / FF / flight (ballistic integration, victim pick, height metrology, FF gates, `PredictShot`, `randomsimulate`) | A | `RUNTIME-HARNESS`/`RUNTIME-GPU` F1–F7 series |
| N-4 tool attach T-A/T-B (runtime child swap/visibility, port 3D implementation) | A | needs close-up capture; not cosmetic-only (tool is visible in hand) |
| E-STATE / AAF tails (ACL completion family, `attack2before/after` gating, death hold-vs-return) | A | text map `STATIC CLOSED`; behaviour needs R-B/R-C batteries |
| E-COLL / LOS (per-sid radius/mask, footprint rotation/mirror, LOS engine impl, `SetGameObjectRayCastIntersectEnabled`) | B | STATIC census/audit residual + runtime LOS battery |
| E-WPN / SHIELD (shield/mount rows, upgrade per-value rows `country.script:2050-2210`) | B | `STATIC` mechanical read + runtime damage probe |
| D5 death-smoke TTL | D | register §0 tail; cosmetic |
| D6 PFX `PixelRatio`/`Interval` `[U]-F` | D | register §0 tail; cosmetic |
| D7 `*a` child meshes | D | register §0 tail; cosmetic |
| D12 660 B `eursto`/`eurtow` death-attach stubs | D | register §2.3 tail; cosmetic |

### 2.4 Domain S — skirmish / save / RNG / tick / AI / capture (16 items)

| ID | Cls | Basis |
|---|---|---|
| P0-4 / S-TICK-O1 + D1–D3 (plInd rotation, firing rate, interleave, mod-cohort, section micro-order) | A | `RUNTIME-HARNESS` fixed-seed hash battery |
| U-THR (ProgressPlayers thread/priority observable effect) | A | `DEC_U_tick_deep §5 U-THR`; port-side toggle harness |
| U-S1…U-S8 (rotation, rate, interleave, cohort, bank edge, jitter anchor, veto reachability, AI Econ/War split) | A | `DEC_U_tick_deep §5`; 3600-frame × 3-seed harness |
| P0-6 / S-SAVE-R1 a–g (container, float/bool, codepage, transform, victorystate tails, trailer) | A | `RUNTIME-HARNESS` paired saves |
| Save R1h-NEW (profile-store file identity/encoding/flush) | A | `DEC_U_save_deep §5`; needs executed donor (`E-A`/`E-B`) |
| P0-7 / S-RNG-G1 (round-Bankers, S-vs-G split, per-site counts, uniqrnd, attribution) | A | `RUNTIME-HARNESS` X20/X21 series |
| N-1 Class-N3 fisher-target unseeded `randf()` attribution | A | fixed-seed fisher-delivery dump |
| CS-* capture tails (ledger, garrison, hide, FOW, rally, Q-FLUSH-SEM/Q-REFUND/Q-CAPTURER) | A | `RUNTIME-HARNESS` 3-run dump batteries |
| N-3 AI think gate 1.0 s vs donor 2.4 s + `id·0.25` + anti-collision (U-A6r/U-A7) | A | `RUNTIME-HARNESS`; no default flip before batteries |
| N-6 U11-M port-side slot-11 mercenary flip | A | donor target recovered; port implementation + fixed-seed rebellion trace |
| N-12 team behaviour U-T1…U-T8 (FFA/2v2/leaver/shared vision/bneutral) | A | fixed-seed 2v2/FFA captures |
| N-13 audio U-AUD-1…3 (G-stream values, walk-counter init, native mixer DSP) | A | donor G values unrecoverable statically; runtime tape |
| S-SKIRM tables (T/D/Q/G/A/R/V/F/E/O per-sid rows) | B | `STATIC` script/cfg/write*.inc mechanical audits |
| S-AI-A1…A8 (build-order, army-commit, officer-wait, weights, resbalance, think-interval, AI RNG) | B | `STATIC` continuation reads + runtime batteries |
| S-MKT / Q2 / VIC / PEACE (rational cost, upgrade per-row literals, peace index↔seconds, U-F1 trigger rows) | B | `STATIC` country.script/res.script/donewgame.inc/menu-cfg reads |
| U-DSP (DScript dispatch loop with player-slice bounds/index/stage order) | B | `DEC_U_tick_deep §5 U-DSP`; static CODE-table sweep extension |

### 2.5 Domain F — fog / camera / UI (12 items)

| ID | Cls | Basis |
|---|---|---|
| P0-3 / F-GRID a–e + persistence (cell size, combine, occlusion, sticky/global, `GetFOWLOSData` sampling) | A | `RUNTIME-GPU` script LOS dumps; no script-side quantisation exists |
| F1-NUM-f (native RTTI layouts `TLOSInfo`/`TLOSData`/`TFOWLerp*`/`TOSWFOWRender`/`XFOWRender`) | A | `DEC_U_fow_numeric_deep §6`; debugger/memory read |
| F1-NUM-g (live knob defaults K1–K8) | A | runtime getter log; zero script/config/binary defaults |
| P0-8 / E-U13 pick (distance units, `SortRayCastList` order, engine AABB, FOW veto) | A | `RUNTIME-GPU` pick battery |
| V1-SENSOR / V2-PROJ-NF / V2-PROJ-ASPECT / V2-DRAG / V2-BOX / V2-MINI | A | `RUNTIME-GPU` pixel solves; numeric law absent from text |
| N-11 FOW engine surface absence sweep (`UpdateFOW`/`victorystate`/`GetFOWLOSData`/`FOWBuildFull`, `XFOWRender`) | B | static/native xref sweep remains; negatives `[O]` |
| D1 ghost colour/blink tint `[U]-G` | D | register §0 tail; blink alpha law `[O]`, tint cosmetic |
| D2 rally TTL / pennant `[U]-R` | D | register §0 tail; cosmetic |
| D3 peace-menu labels `U-M*` | D | register §0 tail; cosmetic |
| D4 market blend edge `U6-T`/`DLT` | D | register §0 tail; cosmetic |
| D8 score/time-limit absence | D | closed-absent in donor; nothing to match |
| D9 team-win policy (stamp law `[O]` ported; behaviour is U-T1…T8, class A) | D | register §0 tail; policy label only |

### 2.6 Domain GOV — governance / preserve-only / experimental setup (5 items, all C)

| ID | Cls | Basis |
|---|---|---|
| C1 N-2 Class-N replay hazards (N1 `--seed random`, N2 menu Random, N5 wall-clock watchdog, N6 frame-paced stepping, N7 async-load yields, N8 800×600 GPU fallback, N9 save/load seed rewrite) | C | `PRESERVE-ONLY` / conditional; documented, excluded by protocol, never "closed" or removed |
| C2 N-15 chain condition 6 PARTIAL + D0 preflight, matched-input manifest, `--assert-ab-verified` | C | owner/COORD gate + manifest decision, not a capture result |
| C3 N-16 port guard / policy MINOR defects (fallback literal without `[U]` tag; conditional `RESULT IS GOOD` qualifier) | C | label-only remediation; no gate promoted |
| C4 P-1…P-9 preserve-only owner choices (config backend/color_unify, demo_mill, manifest aliases, I11 seam, shader/mesh fixes, v5 save keys, ghost test/assets, preserved contradictions, tool hashes/donor pin) | C | `MUST NOT be changed`; hashes byte-preserved, re-verify at gate 0 |
| C5 experimental setup: temporary capture configs outside the port, deferred `"donor"` backend-flip ticket, out-of-scope network/replay-sync | C | owner policy / experimental setup; not a `[U]` value to settle |

---

## 3. Counts

### 3.1 Per class (total 71 still-open `[U]` items)

| Class | Meaning | Count |
|---|---|---|
| **A** | donor GPU/runtime capture or owner/COORD harness required; forbidden to workers | **42** |
| **B** | additional static decomp plausibly possible (exact next angle in §4) | **14** |
| **C** | owner policy / preserve-only / experimental setup | **5** |
| **D** | cosmetic tail that cannot affect a 1:1 visible/simulation result | **10** |
| | **Total** | **71** |

### 3.2 Per domain × class

| Domain | A | B | C | D | Total |
|---|---:|---:|---:|---:|---:|
| W — water / render | 13 | 2 | 0 | 0 | 15 |
| T — terrain / generation | 0 | 5 | 0 | 0 | 5 |
| E — entities / AAF / FX / collision | 12 | 2 | 0 | 4 | 18 |
| S — skirmish / save / RNG / tick / AI / capture | 12 | 4 | 0 | 0 | 16 |
| F — fog / camera / UI | 5 | 1 | 0 | 6 | 12 |
| GOV — governance / preserve / experimental | 0 | 0 | 5 | 0 | 5 |
| **Total** | **42** | **14** | **5** | **10** | **71** |

Totals reconcile: 42 + 14 + 5 + 10 = 71; column sums 15 + 5 + 18 + 16 + 12 + 5 = 71.

---

## 4. Class-B candidates — all 14, with the exact next angle

Each row is a **read-only** next step. None of them wires a value, promotes `[U]`→`[D]`, or closes the behavioural item hanging off it.

| # | Item | Domain | Exact next static angle (all donor reads pinned `t_87f0f3c130b0`, never executed) |
|---|---|---|---|
| B1 | W-U12 static sweep (U12-A2/R1) | W | Exhaustive whole-binary **caller/xref walk of every `glCopyTexImage2D`/`SubImage2D` helper**: from the singleton copy thunk `0x4afb3c` (call `0x4ed44c`) through the undiscovered gap `0x4ed38c…0x4ed44c`, up to `sub_4ed28c` → `sub_7715f4` (`address_taken:1`, 0 direct callers), naming the indirect callback head; **plus a `TOSW*` constructor→`C+0x4c` field-store sweep** over each `TOSW*` vtable / `ImageClassName` factory (≤5 passes per function). Stop when 0 unvisited xrefs remain. (`DEC_U12_deep §1 N1–N5, §8`.) |
| B2 | U3-REG whole-binary caller sweep | W | Static-only xref of `FUN_0082f060`/`FUN_0082f114`/`FUN_00739bf8`/`FUN_0082f86c`; decompile each new caller (≤5 passes), record which writes `h+0x50`/`h+0x200` and any reachable `glTexImage2D`/FBO writer; terminate on 0 unvisited xrefs. (`DEC_U_hmap_num_deep §6 U-REG`; register §4 N-7.) |
| B3 | T-SEED / T-CALLBACK | T | Re-read every `GenerateMapRandKey` derivation call site and `randkey0/1` consumer (`generatemap.inc:130-200`); enumerate all 15 `Random` callers; trace the indirect `renderer+0x0b` index-header copy and `sub_812e34` producer; bound the Delphi QPC-else-TickCount seeder. (`DEC_U_gen_seed`, `DEC_U_placement`.) |
| B4 | T-SMOOTH / MINMAX / MOD | T | Static lift of the `SmoothTerrain(x,-y,False,3)` kernel VA and `minx/miny` helper out-args; recompute the `probsmall/mid/large/huge` + `640/((W+H)/2)` modifier trip-count; assert `needed=floor(WA·HA·freq)` on ≥3 sizes. (`DEC_U_placement`; X51.) |
| B5 | T-VER / MDEN / HF / OBJ | T | STATIC live-settings dump + `country.script`/`pattern.lib Objects[]` reads for `gc_MaxTerrainTypeCount`, `gRecordGeneratorVersion`, `mapsize`, `minesdensity` rounds 3/4/5, per-pattern `HeightField*`/`minangle/maxangle`; re-check the 16×8 atlas fallback packing literals. (`DEC_U_atlas_layout`, `DEC_U_n17_gaps §0/§2`.) |
| B6 | T-G0 | T | Static fixed-seed mask check for `fdens==0` off-starts; confirm no zero-density branch writes height. (`DEC_U_placement` U-G0.) |
| B7 | U-speed-consumer / T-SPEED | T | Full-tree `\.speed :=` and `rotatespeed :=` sweeps; confirm every per-sid write is `//`-commented except `unit.script:618` forcing `1`; enumerate the only live mutators (`speedperc` divisor, `Floor(interval·speed)`). (`DEC_U_move_speed §§1-3/§8`.) |
| B8 | E-COLL / LOS | E | Finish the STATIC census/audit: per-sid radius/mask (354/369 `[O]`), `Rotate`/`Reflect`/`tmoRotate` footprint rotation/mirror grep, centred origin + inertia `[O]`, and the 12-float `ctpoEqual`/`ctpoGreater` + AABB inside-test typing and `SetGameObjectRayCastIntersectEnabled` sites. (`DEC_U_collision_full §10`, `DEC_U_inertia_rtti`.) |
| B9 | E-WPN / SHIELD | E | STATIC mechanical read of shield/mount rows (`yachttur 100`, `battleship 100`, `tow 5`, weakwall `15+80`) and upgrade per-value rows `country.script:2050-2210`; never copy a neighbour sid. (`DEC_U_weapon_tail §5`.) |
| B10 | S-SKIRM tables | S | STATIC audits of `unit.script` `SetObjBase*`, `weapon.script` `_weapon_AddWeapon`, `player.script` producers, `startingsettings.cfg:183-720+`, `write*.inc`/`read*.inc` field order; zero-fill where the donor is absent, never invent. (`DEC_U_skirmish §3`, `DEC_U_skirmish_tables §9`.) |
| B11 | S-AI-A1…A8 | S | STATIC continuation reads of `progresseconomicai`/`progresswarai` split, `resbalance` mine levels, officer-wait/squad timing, the 37 `ExecuteState` sites, and the `[*] = ;` container D-rows D-1…D-9; activate no D-row. (`DEC_U_ai_thresholds §8`, `DEC_U_ai_activation §§2-4`.) |
| B12 | S-MKT / Q2 / VIC / PEACE | S | STATIC `country.script`/`res.script`/`donewgame.inc`/menu-cfg per-row literal reads: rational cost-push/delivery/resonlife, upgrade time/cost/gate/preempt/dispatch/loss/cadence, peace index↔seconds/seed boundary, mission trigger→victory rows (U-F1); score/time-limit stay ABSENT. (`DEC_U_market_tail`, `DEC_U_upgrade_q2`, `DEC_U_menu_peace`.) |
| B13 | U-DSP | S | Extend the CODE-table sweep to neighbouring `0x68xxxx–0x6axxxx` prototype runs for any loop bound, stride, index increment or stage call-order literal; pair with the U-S1 census. **No `.bind` unpacking.** (`DEC_U_tick_deep §§2/5`.) |
| B14 | N-11 FOW engine surface sweep | F | Owner-authorised **static/native** sweep for `UpdateFOW`/`victorystate`/`GetFOWLOSData`/`FOWBuildFull` RTTI/layout (all 0-hit in scripts; `XFOWRender` is a `.rsrc` name with 0 xrefs); enumerate every xref with 0 unvisited remaining; never emulate a guessed FOW cell layout. (`DEC_U_endgame_fow §0 P2-P5`; register §4 N-11.) |

---

## 5. No class-A item can be closed under the read-only rule

- **All 42 class-A items require an act this worker cannot perform.** By the 2026-11-26 charter (`PORT1TO1_owner_decisions.md:36`, `PORT1TO1_u_register_update.md:53-55`, `DEC_U_final_register.md:122`) the donor binary is read-only and never executed; no GPU/GL trace, debugger/watchpoint, fixed-seed hash battery, paired-save run, Godot process, gate, runner job or port capture is permitted to an analysis worker. Each class-A experiment terminates only on its named **zero-mismatch** criterion (identical bytes/ticks/pixels/cells, 0 differing elements, with the stated repeats). "Close", a metric, a still, a green-looking test or a port fallback never counts.
- **Therefore none of the 42 is closeable by this or any read-only worker**; each remains `[U]` until the owner/COORD runs its experiment and the port keeps its current labelled hard-fail / provisional / PORT APPROXIMATION behaviour. This report closes **zero** items and promotes **zero** values.
- **Class B does not back-door class A.** The 14 class-B angles settle only structure, call graphs, censuses and absence; per `PORT1TO1_u_register_update.md:44-45` a structural closure is not a value closure and a static closure is not a behavioural closure. Even if every B angle were fully executed, the A values/behaviours they feed (reflection provenance, live hmap tuple, tick order, blend curve, save bytes, RNG attribution, projection numerics, FOW grid) would stay `[U]` until the A experiments terminate with zero mismatches. P0-1…P0-8 all remain open.

---

## 6. Verdict and claim register (audit-level, no parity)

| # | Claim | Label |
|---|---|---|
| 1 | `PORT1TO1_p0_final_status.md` is pending/nonexistent (repo-wide file + content search returned 0 hits); classification uses the definitive register + TR-2 + eight deep reports + owner-decision register. | [O] this pass |
| 2 | Exactly 71 still-open `[U]` items catalogued; each assigned one class with precedence C > D > B > A; per-class 42/14/5/10 and per-domain counts reconcile. | [D] §2/§3 |
| 3 | Every class-B candidate has a concrete, still-unperformed read-only next angle with pinned VA/file:line cites; none wires a value. | [D] §4 |
| 4 | No class-A item can be closed under the read-only rule; no donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared. | [O]/[D] scope guard + §5 |
| 5 | `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; six-condition chain 0/6 CLOSED (conditions 2 and 6 PARTIAL port-internal only, 1/3/4/5 BLOCKED); no donor A/B frame, no COORD ruling. | [D] `PORT1TO1_parity_chain.md:38-58`, `PORT1TO1_parity_recheck.md:44/63` |
| 6 | No approximation adopted, no `[U]` promoted, no test/gate weakened, no I11/preserve-only file touched; exactly one repository file written. | [O] scope guard |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the §2 tails); six-condition chain 0/6 CLOSED. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

*End of PORT1TO1_u_classify. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
