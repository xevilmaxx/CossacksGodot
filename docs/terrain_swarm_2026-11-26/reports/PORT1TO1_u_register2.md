---
id: PORT1TO1-U-REGISTER2-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER U-REGISTER2 — FINAL definitive remaining-[U] register after the post-register B-angle / [D] derivation / first-camera / D4 sweep"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; all nine P0 rows OPEN; six-condition chain 0/6 CLOSED; class-B static closures and [D] derivations never close class-A value/behaviour items; no donor GPU A/B frame; no approximations; no parity claim"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc file reads and read-only filesystem listing/hash reads only. No source, shader, asset, config, test, fixture, result JSON, manifest, queue, backup or git state written; no donor binary executed/captured/copied; no Godot process, runner job, gate, harness, replay or port capture run. Exactly one repository file written: this report. Every donor fact below is carried [O]/[D]/[I]/[U] from cited landed reports; every port fact is an [O-PORT] read carried from cited reports."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md  (baseline definitive register: 71 open [U], §1 nine P0 rows, §3 C1…C16, §4 N1…N16)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md  (§2 master 71-row item register, §3 per-class A42/B14/C5/D10 and per-domain counts, §5 no class-A closure under read-only rule)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md  (§1 definitive 9-row P0 table, all OPEN; §2 one genuinely new [U] = U-base-speed)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md  (final B-angle sweep: 14/14 original + 6/7 NB executed; NB-4 [D]; NB-2 field defaults [D])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb4.md  (U-KEY derivation formula STATIC-CLOSED [D]; runtime state/behaviour [U])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb2.md  (relief field-default table [D])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb5.md  (quad copy site STATIC-CLOSED [D]; U-copy-values [U], no parity)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_tver_deep.md  (T-VER shipped envelope 53 / 320²-384² [O]/[D]; port 92/240² MISMATCH)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_start_deep.md  (first-camera wire found; prior ABSENT SUPERSEDED)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md  (§2 IMPLEMENTED 2D + 3D first-camera wire)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d_cosmetic.md  (§2/§3.4/§4 D4 not genuinely NB if prices in scope)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d4_reclass.md  (D4 stays [U], NOT CLOSED; blocking unless explicitly excluded)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_place_seed_deep.md, DEC_U_genseed_deep.md, DEC_U_speed_consumer_deep.md, DEC_U_ureg_ctor.md, DEC_U_nb1.md, DEC_U_nb7.md, DEC_U_b45_residual.md, DEC_U_hmap_num_deep.md, DEC_U3_reg_sweep.md
---

# PORT1TO1 — FINAL remaining-`[U]` register (2026-11-27)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **No metric, gate, replay pair, ROI, still, hash, byte dump, `[D]` derivation or "close" value constitutes parity.** `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `blocking_unverified` is non-empty, so the honest verdict is **`RESULT IS NOT GOOD`** unconditionally. No approximation is authorised by this register; no donor GPU/runtime session was executed by this or any worker.

---

## 0. Scope of this final register

`PORT1TO1_u_register_update.md` was the definitive register at 71 open `[U]` items (A42 / B14 / C5 / D10). It predates the final B-angle sweep, the NB `[D]` derivations (randkey, relief field defaults, quad copy site), the T-VER envelope-53 observation, the first-camera wire, and the D4 market reclassification. This report consumes those landed reports as carried `[O]`/`[D]` facts and restates the final register.

Two discipline rules govern every §2/§3 row, carried verbatim from `PORT1TO1_u_register_update.md:44-45` and `PORT1TO1_u_classify.md §1`:

1. **CLOSED-STATIC / CLOSED-NEGATIVE settles only the named static question — not the behavioural/runtime item hanging off it.** A `[D]` derivation of `GenerateMapRandKey` closes the derivation formula, not the live invocation, `U-KEY2`, `U-MAP` or `U-SS`; the quad copy-site instruction map closes the static offset question, not the value-level byte dump.
2. **A structural closure is not a value closure; a static closure is not a behavioural closure.** Every class-B static result in §2 narrows structure, call graphs, censuses or absence. **Static closures never close class-A value/behaviour items.** The nine P0 rows in §4 are unchanged by any row in §2.

**No row in this report is promoted to donor parity, no `[U]` is wired to a value, no experiment is weakened, and no gate is run.**

---

## 1. Final open count and classification

### 1.1 Total

| Quantity | Final value | Basis |
|---|---|---|
| Open `[U]` rows at authoritative register granularity | **71** | `PORT1TO1_u_register_update.md` §0/§2 (71 open), `PORT1TO1_u_classify.md §3.1` (71) — carried unchanged |
| Rows removed / fully closed by the post-register sweep | **0** | Every §2 closure is static-only; no source report marks any of the 71 rows CLOSED at value/behaviour level |
| P0 rows | **9**, all `OPEN` | `PORT1TO1_p0_final_status.md §1` |
| Six-condition parity chain | **0/6 CLOSED** (condition 6 PARTIAL, port-internal only) | `PORT1TO1_b_angle_final.md:141`, `PORT1TO1_handoff_sync.md §5`, `PORT1TO1_p0_final_status.md §4` |

The 71 is the **row count**, not a claim that nothing was learned. The sweep narrowed many rows and surfaced named sub-items (§3); no report produced a revised authoritative total, so this report does not invent one. In particular, `U-base-speed` is called "one genuinely new `[U]`" by `PORT1TO1_p0_final_status.md §2`, but it is a split of the already-counted `U-speed-consumer / T-SPEED` row (`PORT1TO1_u_classify.md §2.2`), so it adds a tracked id without removing or duplicating a register row. Likewise `U-KEY2`/`U-MAP`/`U-SS`, the camera `CAM-*` ids and the D4 `U6-T`/`DLT`/`O1` sub-items refine already-counted `T-SEED`, `F-V1/V2` and `D4` rows. Counting those sub-items as additional top-level rows would double-count; this register does not do so.

### 1.2 Per class (total 71)

| Class | Meaning | Count |
|---|---|---:|
| **A** | donor GPU/runtime capture or owner/COORD harness required; forbidden to workers | **42** |
| **B** | additional static decomp angle (exact next angle in `PORT1TO1_u_classify.md §4`) | **14** |
| **C** | owner policy / preserve-only / experimental setup | **5** |
| **D** | cosmetic tail not promoted to close a P0 (priority judgement, not donor-fidelity proof) | **10** |
| | **Total** | **71** |

### 1.3 Per domain × class (total 71)

| Domain | A | B | C | D | Total |
|---|---:|---:|---:|---:|---:|
| W — water / render | 13 | 2 | 0 | 0 | 15 |
| T — terrain / generation | 0 | 5 | 0 | 0 | 5 |
| E — entities / AAF / FX / collision | 12 | 2 | 0 | 4 | 18 |
| S — skirmish / save / RNG / tick / AI / capture | 12 | 4 | 0 | 0 | 16 |
| F — fog / camera / UI | 5 | 1 | 0 | 6 | 12 |
| GOV — governance / preserve / experimental | 0 | 0 | 5 | 0 | 5 |
| **Total** | **42** | **14** | **5** | **10** | **71** |

Source-derived from `PORT1TO1_u_classify.md §3.1/§3.2`; 42+14+5+10 = 71 and 15+5+18+16+12+5 = 71. **These are carried counts, not a recomputation.** The B-angle sweep executed the class-B static angles (§2 S-7), which may leave some class-B assignments stale at the "next act" granularity; no source report re-tagged the 71 rows, so this report does not re-tag them either. Class-D status remains a priority judgement: `PORT1TO1_d_cosmetic.md §0` explicitly states it is "not a donor-fidelity claim" and "does not assert ... absence of a visible/simulation effect."

---

## 2. Items newly CLOSED-STATIC or narrowed since the baseline register

Every row is a narrowing of a static/absence/formula question with a report id. **None closes a class-A value/behaviour item; none changes a P0 row in §4; none is a parity claim.**

| # | Item newly closed-static / narrowed | Closure label | Report id | Exact scope of closure | What remains `[U]` |
|---|---|---|---|---|---|
| S-1 | **`GenerateMapRandKey` derivation formula** (randkey derivation) | **CLOSED `[D]`** | `DEC_U_nb4.md §2.1–§3/§5`; `PORT1TO1_b_angle_final.md §3.2` (NB-4) | impl `0x6ac244` registered from `sub_69a70c`; `eax=$7FFFFFFF; call Random(sub_403a0c); cdq; store(hi→key0, lo→key1)` ⇒ `randkey0=0` constant, `randkey1=Random($7FFFFFFF)` single draw; var-out word order and slot offsets `+0x18/+0x1c`, `+0x108/+0x10c` `[D]` | Static donor-law derivation only. Runtime invocation timing, **U-KEY2** (key0-discard), **U-MAP**, **U-SS/U-ONLY/U-TIME** stay `[U]` (`DEC_U_nb4.md:135`); `IMPL-RANDKEY-DERIV` is an implementation lane, not a parity/behaviour closure |
| S-2 | **Relief field-default table** (NB-2) | **CLOSED-STATIC `[D]`** | `DEC_U_nb2.md §2–§3/§7`; `PORT1TO1_b_angle_final.md §3.3` | CODE-embedded property table VAs/order, `sub_75c314` name→offset→default→reader binding for all 37 entries (incl. `HeightFieldMin/Max` default `1.0f`, `HeightFieldSmoothOffset` default `2`), four wrapper arities, 5 shipped `pattern.lib` section concretes, `minangle/maxangle` key absence, prefix-collision rule `[O]/[D]`; parser binding is `[D]`, not a promoted generator value | Per-pattern floats (675 un-dumped sections), angle-use, `Objects[]→mesh`, `HeightFieldMax` outside-stamp consumer, MDEN 4th word, atlas literals stay `[U]` (`U-HF/U-ANG/U-OBJ/U-MAX/U-S0/U-MDEN/U-ATLAS`) |
| S-3 | **Quad copy site** (NB-5, `renderer+0x40` → `0x48`→`0x50`) | **CLOSED `[D]`** (static instruction/offset map) | `DEC_U_nb5.md §2–§3.4/§5` | invocation chain `sub_818920 → sub_818824 → sub_81ac54 (0x81ac68 call [ebx+0x40]) → sub_812e34` byte-proven; row source `+0x05` RGB / `+0x25` alpha, 2×32 B `rep movsd` + 4-iteration scatter into `Q+0x00/+0x10/+0x30`; every `+0x05…+0x44 → +0x10…+0x4f` byte and all four `+0x00…+0x0c` index words mapped with zero gaps; `+0x0b` shift closed arithmetically | **U-copy-values** value-level byte dump stays `[U]` (owner-only probe §5). Reporting discrepancy preserved: `PORT1TO1_b_angle_final.md:49/89/93` counted NB-5 PENDING ("no `DEC_U_nb5*.md` observed") while `DEC_U_nb5.md` is present on disk with a CLOSED-`[D]` verdict; this register follows the file, promotes no value either way |
| S-4 | **T-VER shipped envelope 53** | **CLOSED-STATIC `[O]`/`[D]`** | `DEC_U_tver_deep.md §2/§3/§4`; `PORT1TO1_b_angle_final.md §2 B5` | four shipped `.map` heads byte-identical: word0 `35 00 00 00` (=**53**), `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, snapshot framing; terrain 320² (ausmis1/bonmis1/engmis4) and 384² (battle1), sub=4; sole writer `gDataVersion:=92` (`serial.script:27`), `gc_MaxTerrainTypeCount=9`, mapsize enum `0→320,1→480,2→640,3→256` `[O]`; port pin 92/240² **MISMATCHES** shipped 53/320²-384² on word 0 and extent | Live `gRecordGeneratorVersion`, `mapsize`, live terraintype index, record `ver`, 4th-word 64-vs-25920 semantics stay `[U]`; no version invented |
| S-5 | **First-camera wire** — prior "ABSENT" verdict superseded | **STATIC CLAIM REFUTED `[O]`** (prior ABSENT verdict; wire found), wire IMPLEMENTED in port; no donor visual parity | `DEC_U_start_deep.md §3/§4/§7`; `PORT1TO1_handoff_sync.md §2` (tasks 221/227 DONE) | `doprogress.inc:41` `_control_MoveCameraToPosition(gMap.players[myPlInd].startx, starty, 0, True)` gated by one-shot `gbool_gui_mapgenerationfinished` (producer `dogenerate.inc:1939`); Home-hotkey `onshortcut.inc:1000`, origin wire `docreate.inc:297`; flag/ordering law `[O]/[D]`. Port: `game.gd:94/709/686-694`, `camera.gd:179-187`, `camera3d.gd:485-492` implemented, parses OK, no new FOV/zoom/height constant | **CAM-derive**, **CAM-0** (final target/height and `time=0` smoothing), **S-place**, **S-ver**, **N-native** stay `[U]` (`DEC_U_start_deep.md §6`); no donor camera value or clamp promoted |
| S-6 | **U-REG-TEX ctor sweep** | **CLOSED-STATIC negative `[D]`** | `DEC_U_ureg_ctor.md §§2–5` | zero `TOSW*`/`OSWTexture`/`TextureImage` ctor→`+0x54/+0x58/+0x5c/+0x60/+0x64`, →`C+0xe0`, →`C+0x4c`, →`texture+8` stores; shader ctor `0x856080` own-field defaults + `C+0xf4→0x853ad4` descriptor edge; `HeightMapTexUnit @0x852b84` single-hit VA `[D]` but valueless; single-instance ownership partially proven | `U3-TEX`/`U3-NUM`/`U-REG-TEX` GL name/id/unit/tuple stay `[U]`; `TOSWRefTextureImage` stays suggestive `[I]`; hard-fail retained |
| S-7 | **Final B-angle sweep** — 14/14 original + 6/7 NB executed | EXECUTED table, `[O]`/`[D]` outcomes only | `PORT1TO1_b_angle_final.md §§2–4` | B1–B14 all executed (B4/B5 partial); NB-1…NB-7 6 executed (NB-1-as-index-labelled pending, its TOSW sub-angle executed as NB-6; NB-5 pending per that report — see S-3). B6/B9 promoted zero values; B10 promoted byte-proven static `[D]` literals inside class B only | No class-A item closed; no parity claim; all A values/behaviours stay `[U]` pending owner zero-mismatch experiments |
| S-8 | **TOSW whole-binary ctor sweep** (NB-6) | **CLOSED-STATIC negative `[D]`** | `DEC_U_nb1.md`; `PORT1TO1_b_angle_final.md §3 NB-6` | 8-name family counts/VAs/sections `[O]/[D]`; sole static data edge `0x812999 → 0x812a44`; complete store lists of `sub_8127e0/sub_812a44/sub_7744cc/sub_7763f8` with zero `+0x4c/+0x8/+0xe0` writes; sole `C+0x4c` access is `0x6760a8` LOAD | U12 provenance (class, w/h/format/mips, sampler unit, matrix, pool rule, GL name) stays `[U]`; port hard-fail kept |
| S-9 | **S0 kernel window** | **CLOSED-NEGATIVE `[O]`** | `DEC_U_nb7.md`; `DEC_U_b45_residual.md`; `PORT1TO1_b_angle_final.md §2 B4` | `0x6a3900–0x6a3b80` proved DScript registration strings, not code; 1-byte ASCII aliases, `function_find` null, 0 xrefs/0 LE-imm32 for all three S0 VAs; `sub_608238` a 331-indirect-callee registrar | `U-S0-KERNEL/SCOPE/VM/MB3`, MINMAX/MOD trip-count stay `[U]`; no radius/sample count/weights invented |
| S-10 | **D4 port law refinement** (not a closure) | **CLOSED `[O-PORT]` for the two superseded approximations only** | `PORT1TO1_d4_reclass.md §2/§3`; `PORT1TO1_d_cosmetic.md §3.4` | old linear push `c+(bound-c)*w` and hardcoded recovery factor `1` are absent; port now carries rational `(c+bound*w)/(1+w)`, buy-then-sell order, two-row scope, `MARKET_EXP` quirk, live `round(Lerp(ClampInt(...)))` dlt tracker with `maxf(1, dlt*0.01)` | **D4 stays `[U]` and is NOT CLOSED**; residual is engine float semantics `U6-T`, `DLT`, coupled `O1` (see §3 N-5 and §5) |

**Audit note:** S-1, S-2, S-3, S-4, S-6, S-8, S-9 are the entries where a static/formula/structural `[D]` must not be read as a value, behaviour, gate or parity closure. S-5 closes the *absence* of a wire, not the camera numerics. S-7 closes zero P0 items. No row in §2 removes any row in §3/§4.

---

## 3. Newly surfaced / newly named `[U]` items

All are `[U]`. "Split/narrowed" means a sub-question of an already-counted 71 row received an explicit id; it is not a new top-level row. `U-base-speed` is the one item a source report explicitly calls "genuinely new" (`PORT1TO1_p0_final_status.md §2`).

| # | Item | Status / kind | Report id | Zero-mismatch closer (owner/COORD only) |
|---|---|---|---|---|
| N-1 | **U-base-speed** — no byte-proven global base speed or tick default; `2.225` 0 text/0 float32 hits, `1.0f` 1821 hits unusable | **Genuinely new `[U]`** (split of `U-speed-consumer / T-SPEED`); Domain T, class A | `DEC_U_speed_consumer_deep.md §3.3/§5/§6`; `PORT1TO1_p0_final_status.md §2`; `PORT1TO1_b_angle_final.md §2 B7` | **T-BASE**: `GetGameObjectTrackPointMoveStep(Interval)ByHandle` defaults from measured spawns, 10 trials × 3 classes (foot/horse/ship), exact Integer + ±1 ulp Float, never an assumed `1 tile` |
| N-2 | **U-KEY2** — strict runtime key0-discard (draw #1 folds `key0`; per-object setter bodies unanchored) | Newly named `[U]` (narrowed from `T-SEED`); Domain T | `DEC_U_place_seed_deep.md §5/§6`; `DEC_U_nb4.md §4` | ±1 probe: `key0=0` vs `key0=1`, K=1 and 12345, dump `D2:190` mask pick + first three `RandomExt` floats after each ext-reseed, 0 mismatches after draw #1 on both K and two map sizes |
| N-3 | **U-MAP** — (a) shipped-map seed override at `0x8f2008`; (b) map bytes → live hmap tuple linkage | Newly named `[U]` (narrowed from `T-SEED` / `P0-2`); Domains T/W | `DEC_U_genseed_deep.md §6`; `DEC_U_place_seed_deep.md §6`; `DEC_U_hmap_num_deep.md §6`; `DEC_U3_reg_sweep.md` | (a) map-load `0x8f2008` write-watch with source VA, two map sizes; (b) same-map terrain-block W/H + flat f32 grid dump vs same-session U3-NUM tuple; terminate only on one hypothesis with 0 mismatching bits/floats |
| N-4 | **U-SS** (with **U-ONLY**, **U-TIME**) — generation-time Delphi seed value at `0x83272f`; exclusivity; QPC-vs-TickCount branch | Newly named `[U]` (narrowed from `T-SEED`); Domain T | `DEC_U_genseed_deep.md §6`; `DEC_U_place_seed_deep.md §6`; `DEC_U_nb4.md §4` | `0x83272f` first-hit `state-before>>>24` + write-watch attribution + restart-changes-seed proof; any same-seed-same-pair repeat refutes wall-clock seeding without invention |
| N-5 | **D4 price semantics**: **U6-T** (36 floats), **DLT** (600 ticks, quiet + active windows), **O1** (economy interleave) | Newly named `[U]` (narrowed from `D4`); Domains S/F — **blocking unless explicitly excluded (§5)** | `PORT1TO1_d4_reclass.md §3/§4`; `DEC_U_market_tail.md §1/§2/§6`; `PORT1TO1_d_cosmetic.md §2 row 4` | U6-T: 36/36 cost floats bit-match oracle and current `trade()`; DLT: dlt vector + 12 costs zero-mismatch for 600 ticks with one quiet and one active window; O1 interleave fixed by the same seed |
| N-6 | **CAM-derive / CAM-0** — final first-frame target/height and `time=0` smoothing semantics | Newly named `[U]` (narrowed from `F-V1/V2`); Domain F, class A | `DEC_U_start_deep.md §6`; `PORT1TO1_handoff_sync.md §2` | 3 identical owner runs without input, byte-identical camera target and `startx/starty`; `bSetMaxHeight=True` height equals `SphereLength=58` clamp or deviation quoted, never patched; frame-1 == frame-5 target for instant |
| N-7 | **U-copy-values** — value-level dump behind the CLOSED-`[D]` quad copy map | Newly named `[U]` (narrowed from `E-COLL`/`B8`); Domain E | `DEC_U_nb5.md §5` | dump source rows `renderer+0x50+0x48·i` and appended `Q` records; 0 mismatches across ≥3 cells including a multi-tag cell |
| N-8 | **Other split/hardened `[U]` ids** carried by `p0_final_status §2` (all remain `[U]`, none promoted, none P0-closing) | Split/narrowed | `PORT1TO1_p0_final_status.md §2` | Each keeps its own cited zero-mismatch experiment in its source report: `U5-WRITER/U5-CLOCK`, `U6-UV/WIND/CULL/CLASS/ARR`, `E-T1/T1b/T1c`, `F1-PERSIST-a…e`, `OCC-a…d`, `[U]-C1/C2a–d`, `[U]-W/W2/WC/S/A/R/C1/C2`, `U-SS/U-ONLY/U-MAP/U-TIME/U-KEY`, `U-VETO-BYTE/WRAP/CENSUS/ORDER`, `U-E1…U-E8/U-N1/U-C1`, `[U]-P1`, `U-S0-KERNEL/SCOPE/VM/MB3`, `U-HF/U-ANG/U-OBJ/U-MAX`, `U-NUM/U-TEX/U-REG-TEX` |
| N-9 | **Class-N replay hazards** (N1 `--seed random`, N2 menu Random, N5 wall-clock watchdog, N6 frame-paced stepping, N7 async-load yields, N8 800×600 fallback, N9 save/load seed rewrite) | `[U]`/`PRESERVE-ONLY`, not "closed" | `PORT1TO1_u_register_update.md §4 N-2`; `PORT1TO1_determinism_audit.md §§1-6` | Document and exclude by capture protocol; any acceptance run must prove no Class-N path active |

**No new item in §3 removes a row in §1, closes a row in §2 or a P0 row in §4, or upgrades any `[U]` to a wired value.**

---

## 4. Current P0 set — 9 rows, all `OPEN`

Carried verbatim from `PORT1TO1_p0_final_status.md §1` (definitive current nine-row table). Status vocabulary is a closed set: `OPEN` and `PARTIAL`; `PARTIAL` is reserved for chain condition 6 and is **not** a P0-row status. **`CLOSED` appears for no row.** Every experiment is forbidden to workers; a "close", metric, still, replay pair, port fallback or labelled substitute never retires a row.

| # / row | Domain | Exact blocker (still `[U]`) | Packet / session | Status |
|---|---|---|---|---|
| **1 — P0-1 / W-U12** | Water / render | Reflection provenance A (FBO vs `glCopyTexImage2D` vs static upload), B/C `(w,h,format,filter,wrap,mips,unit)`, T projective matrix + viewport/scissor, S/P alias + pbuffer path; no class/name/size/unit/matrix is `[D]` | `PORT1TO1_water_owner_protocol.md` / **S1** | **OPEN (static narrowing only)** |
| **2 — P0-1b / W-U4\*** | Water / render | Which of exactly two atomic scalar tuples is live (ENGINE ctor vs `water.lib` FILE) plus `W0/W1`, `S10/S11`; structure `[D]`, value open; UNSET gate retained | `PORT1TO1_water_owner_protocol.md` / **S1** | **OPEN (structure closed, value open)** |
| **3 — P0-2 / W-U1, U3, U5, U6** | Water / render | U1 live shader path + globals; U3-NUM live `(hmapW,H,Min,Max)`; U3-TEX GL identity/provenance; U5 writer of `C+0xc8`; U6-UV dividend/winding/cull | `PORT1TO1_water_owner_protocol.md` / **S1** | **OPEN (structure closed, value open)** |
| **4 — P0-3 / F-GRID a–e + persistence + tint** | Fog / camera / UI | Cell size, multi-viewer combine, LOS occlusion, explored-vs-visible persistence, `GetFOWLOSData` sampling, panel RGBA tint | `PORT1TO1_fow_owner_protocol.md` / **S2** | **OPEN (static narrowing only)** |
| **5 — P0-4 / S-TICK-O1 + D1–D3** | Skirmish / tick | `plInd` rotation, firing rate, interleave, mod-cohort, section micro-order, bank edge, jitter anchor, veto reachability, AI Econ/War split | `PORT1TO1_tick_owner_protocol.md` / **S6** | **OPEN (static narrowing only)** |
| **6 — P0-5 / E-B1…B4, C1, C2 + W/S/A/R** | Entities / AAF | Blend curve `w(t)`, window unit/fetch, `acmPlayOnce`, handler timing, weapon→token map, sticky readback, `reaction` orphan | `PORT1TO1_blend_owner_protocol.md` / **S3** | **OPEN (structure closed, value open)** |
| **7 — P0-6 / S-SAVE-R1a…g** | Skirmish / save | Outer container, float/bool wire, codepage, transform, victorystate/tails, checksum/trailer, `E-T1` trg routing | `PORT1TO1_save_owner_protocol.md` / **S5** | **OPEN (structure closed, value open)** |
| **8 — P0-7 / S-RNG-G1** | Skirmish / RNG | `round()` Bankers, S-vs-G split, per-site draw counts, `uniqrnd`/`frnd`, f32/f64 promotion, signed `key0`, attribution | `PORT1TO1_rng_owner_protocol.md` / **S7** | **OPEN (algebra closed, attribution/counts open)** |
| **9 — P0-8 / E-U13 + F-V1/V2** | Selection / projection / camera | Pick distance/order/AABB/FOW veto; sensor width→FOV, near/far/aspect, drag anchor, marquee, minimap affine/frustum | `PORT1TO1_selection_owner_protocol.md` / **S4** | **OPEN (static narrowing only)** |

**P0 headline:** all nine rows remain `OPEN`. Water still draws nothing without U12 and has no live scalar source; FOW uses a provisional grid; tick order, blend, save bytes, RNG streams and pick/projection remain labelled approximations. **Nothing in §2 or §3 changes a single P0 row to CLOSED.**

---

## 5. D4 market reclassification — blocking unless explicitly excluded

`PORT1TO1_d_cosmetic.md §2 row 4/§3.4/§4` rated D4 the least defensible class-D item: "**NOT genuinely NB if market prices are in scope**". `PORT1TO1_d4_reclass.md` confirms the residual is now engine-float-semantics only, but those semantics reach **simulation words** (12 `market_cost` floats and trade payouts), not merely UI chrome:

- **U6-T** can change `buyamount` and all 12 cost floats under large `w` (donor AI amounts 5000–600000) or any float32-vs-float64/half-way difference.
- **DLT** can change both costs through `max(1, dlt*0.01)` in active windows (up to ×10 at `dlt=1000`) and through `round`/`Lerp` semantics; even a "quiet" window depends on keeping `dlt<100`.
- **O1** (coupled, separate id) fixes the `r` input to `dlt` and the sampling tick.
- Current HUD market-rate label is the static `Data.MARKET_RATE=0.65` mirror and is not driven by `market_cost`; no port displayed-price divergence is asserted from the present HUD. The exposure demonstrated is **transacted prices and cost state**.

**Owner decision rule (binary, not performed by any worker):**

1. **Keep D4 as a non-blocking tail ONLY if all four are recorded in the matched-scope document:** market prices excluded from in-scope observables; no `trade()` event in the matched window; only a quiet economy (`dlt<100`) in scope; the static HUD mirror treated as UI chrome. D4 remains `[U]`, NOT CLOSED, never promoted to close a P0.
2. **Otherwise D4 is BLOCKING** (simulation price divergence) until Capture U6-T (36 floats) **and** Capture DLT (600 ticks, one quiet + one active window) both return zero mismatch against the donor oracle (`PORT1TO1_d4_reclass.md §4.2`). No retune, approximation or port-internal self-consistency substitutes.

D4 is **not** one of the nine P0 rows; a blocking D4 is an additional blocking non-P0 item. `blocking_unverified` is non-empty either way.

---

## 6. Verdict, discipline and claim register

- **Static closures never close class-A value/behaviour items.** Reflection provenance, live hmap tuple, tick order, blend curve, save bytes, RNG attribution, projection numerics, FOW grid, shield/mount application and skirmish behaviour stay `[U]` until their named owner/COORD zero-mismatch experiments terminate (`PORT1TO1_u_classify.md §5`, `PORT1TO1_b_angle_final.md §4`).
- **No class-A item is closeable under the read-only rule.** All 42 class-A items require a donor GPU/GL trace, debugger/watchpoint, fixed-seed hash battery or paired-save run forbidden to workers. No "close", metric, still, green-looking test or port fallback counts.
- **Parity UNVERIFIED.** `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. No same-camera donor/port A/B frame exists; none was produced or examined by this worker. No metric, gate, ROI, still or replay pair promotes parity.
- **Chain 0/6 CLOSED.** Condition 6 is PARTIAL (two port-internal byte-identical `sha256_pixels` captures), port-internal repeatability only; conditions 1/3/4/5 BLOCKED, 2 PARTIAL (`PORT1TO1_parity_chain.md:38-58`, `PORT1TO1_parity_recheck.md`).
- **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty** — nine P0 rows plus the domain tails (§3/§5), including D4 unless explicitly excluded. Unconditional.

| # | Claim | Label |
|---|---|---|
| 1 | Final open count is 71 rows at authoritative register granularity; A42/B14/C5/D10 and per-domain W15/T5/E18/S16/F12/GOV5 are carried from `PORT1TO1_u_classify.md §3`; no row was removed by the post-register sweep | `[D]` §1 vs cited reports |
| 2 | Ten static/formula/structural closures or narrowings are listed in §2 with report ids; every one settles only the named static question and closes zero class-A items | `[D]` §2 with cited reports |
| 3 | Nine new/newly named `[U]` entries are listed in §3; `U-base-speed` is the only item a source report calls genuinely new; all remain `[U]` | `[D]` §3 with cited reports |
| 4 | All nine P0 rows are `OPEN` (no `CLOSED` row); statuses quoted from `PORT1TO1_p0_final_status.md §1` | `[D]` §4 |
| 5 | D4 remains `[U]` and NOT CLOSED; blocking unless all four out-of-scope conditions are recorded; U6-T and DLT zero-mismatch captures required otherwise | `[D]` `PORT1TO1_d4_reclass.md §4`, `PORT1TO1_d_cosmetic.md §2 row 4` |
| 6 | No donor binary executed, no GPU frame captured, no gate/harness/replay/paired-save run, no port capture compared by this worker; exactly one repository file written | `[O]` scope guard |
| 7 | No approximation adopted, no `[U]` wired to a value, no test/gate weakened, no parity claim; `parity.status = UNVERIFIED`, chain 0/6, `RESULT IS NOT GOOD` | `[O]`/`[D]` scope guard + governing verdicts |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the domain tails, D4 included unless explicitly excluded); six-condition chain 0/6 CLOSED. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made. Static closures never close class-A value/behaviour items.

*End of PORT1TO1_u_register2. Read-only; exactly one repository file written; no source/shader/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
