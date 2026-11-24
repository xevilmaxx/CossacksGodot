# Aggregated donor-vs-port gap matrix — 2026-11-24 session

Consolidated from landed wave-1 recon reports. `reports/` holds the full evidence.
Legend: `C` CONFIRMED · `P` PARTIAL · `M` MISSING · `U` UNVERIFIED.
Labels: `observed` / `derived` / `inferred` (quality-first, D-22).
**No perf row is a win until same-workload before/after numbers exist** (PERFORMANCE_SWARM §5).

## 1. Donor feature gaps (verified against current code, not board prose)

| ID | Family | Verified finding | Verdict | Source | Action |
|---|---|---|---|---|---|
| G-F1 | Farming | Mill 7×7/49 field ring, Grain Crops button+Y hotkey, 60 s auto re-sow, worker slots, field visuals, work/windmill audio are ALL present in code | **C** (implemented) | R01 claims 1,2,4,7,15,16,17 | No ticket. `docs/audit/MICRO.md` rows 1–4,6–8,10,13,65 are STALE — do not re-ticket. |
| G-F2 | Farming | `aca_rye1` is +50% (not +40%); `mil_food2` is +180% (not +250%) | **C** (docs wrong) | R01 claims 11,13 | MICRO stale; no code change. |
| G-F3 | Farming | Donor aca.3 "Agriculturists' salary +50%" (`upgrades.txt:5-6`) has NO port row | **M** | R01 claim 12 | **I1 builder** adding one `UPGRADES_BASE` row (data.gd). |
| G-F4 | Farming | Field regrowth is binary 60 s full restore; donor = 31.25 s gated +10% HP increments | **P** | R01 claim 5 | Optional fidelity ticket; deterministic hash-based increments, version flag for dumps. |
| G-F5 | Farming | Human auto-sow adviser gate absent (donor adviser-controlled) | **M but charter-deferred (D-12)** | R01 claim 8 | Waiver or optional config flag, default OFF. Do not claim P-51 full parity. |
| G-F6 | Farming | Ring collision fidelity: no 5×5 rotated probe, no `size2` snap, no ore-radius skip | **P** | R01 claim 3 | Low-cost follow-up in game.gd; changes dumps → byte-identity gate. |
| G-F7 | Farming | Donor "field capacity +200%" IS `gc_upg_type_fieldlifeperc` (decay slowdown), not a separate yield upgrade | **C** (correction) | R01 claim 9 | MICRO §2.3 wrong; mechanism differs but harvest count ≈ equivalent. |
| G-N1 | Naval | Donor family fully present/readable (54 core meshes, 5 animated `.oss`, 30 `.aaf`/12 `.acl`, 5 shipyard `.prop`, ship stats/ship-stop/balloon scripts) but port wires ONLY `yacht` + `dock`; 5 baked families staged-unwired, 2 hull PNGs orphaned | **M/P** | R09 | Follow-up integration ticket (data.gd + anim assets) after I1 releases data.gd. |
| G-N2 | Naval | Donor gold-shortage firing-stop rule has no port implementation | **M** | R09 | Pairs with T6-M01/M02 economy gaps; needs game.gd (sequence after D1/other game.gd work). |
| G-E1 | Economy | Drop radius 3 tiles, worker slots 3/2/3, upkeep ÷625, market Buy/Sell/Exchange UI already ported with donor-backed values | **C** (implemented) | R07 | No ticket. MICRO/SWARM_BOARD line refs stale. |
| G-E2 | Economy | Gold-shortage desertion + ship-stop absent; donor two-sided market price model absent; 0.35 price floor is a port-only invention | **M** | R07 | Real gaps; needs game.gd (sequence after other game.gd work). |
| G-E3 | Economy | T6-M02 "iron+coal shortage stops firing" claim stale — ammo gate already exists at game.gd:4798 | **C** (correction) | R07 | Do not re-ticket. |
| G-M1 | Micro | 6 NEW gaps: log-message ticker, off-screen alarm event, capture-blocked-by-gunfire, capture cancels queue/upgrade, artillery capture rate, staged corpse decay | **M** | R12 | New tickets after high-value work; each needs donor evidence + port file. |
| G-M2 | Micro | Stage sprites CONFIRMED present; squad disband CONFIRMED implemented + double-tested; formation-order-after-moving CONTRADICTED (no persistent slot map, only array-index fan-out) | **C** (corrections) | R12 | MICRO open questions resolved; formation order = real fidelity gap. |
| G-C1 | Capture | G-01/G-07/G-09 STALE: capturable economy buildings, guarded-capture blocking, foreign town hall unlock all implemented (`t_capture` 6/6) | **C** (implemented) | R02 | Do not re-ticket. |
| G-C2 | Capture | G-11 AI demolition denial still MISSING; donor capture modes govern what may be captured (port inverted); port lets peasants/artillery capture buildings (donor does not); HUD % divides by 8.0 s vs sim HP-based 6–9 s; AI captures call raw `say()` | **M/P** | R02 | Real fidelity gaps; game.gd/hud.gd/ai.gd — sequence after current owners. |
| G-K1 | Hotkeys | Core order/select keys at parity incl. 4 Z variants, guard/cancel, D/E, R dual-use, Alt+M; MICRO guard/cancel/same-type gaps closed. Real gaps: control-group append + double-tap-jump, no speed keys, no PGUP/PGDN/Home, donor P=Shipyard vs port P=patrol, F9/Space semantics | **P/M** | R05 | Donor path is `data\game\var\hotkeys.cfg`, 55 bindings/243 lines (task brief was wrong). FP-3 "hotkey parity DONE" overstated. |
| G-A1 | Assets | 613.57 MiB unreferenced DDS decals (468 files, zero `.import`, zero runtime refs); 259.36 MiB sha256 duplicates; 144.6 MiB stale `.godot` cache | **M** (dead weight) | P03 | DDS deletion = large tracked-file change → document as follow-up, not silent. |
| G-A2 | Audio/startup | `audio.gd:46-47` eagerly `load()`s all 325 OGGs (281.81 MiB) despite lazy `_stream()` | **C** | P03 | **I5 builder** removing 2-line loop. |
| G-R1 | Runner | Queue poll calls `pid_alive()`→`tasklist` (~993 ms) every 0.15 s | **M** | P04 | Fix after I4 jobs drain. |
| G-AI1 | AI | Survival fixes genuinely wired (food reserve ai.gd:117-120, mill-first :325-332, thresholds :89-96); elimination is ALREADY AND at game.gd:5371 — board "OR at 4590" stale; only grace timer open | **C** (corrections) | R06 | Do not re-ticket survival/elimination; grace open. |
| G-AI2 | AI | Mine starvation: 400 starting stone spent on mill150+barracks150+gold100 → no iron/coal mine → no metal → force<120 → `_waves` never fires | **M** (structural) | R06 C4 | **I6 LANDED (partial)**: iron mine from t=42, coal at t=290 final run; iron 415. Wave stall remains a SEPARATE cause. |
| G-AI4 | AI/train | With mine fix in, 300 s soak still shows `force` max 40, `military=4`, `wave=0` despite food 849, iron 415, finished barracks — `_train` gates are the next root cause (not the mine fix) | **M** (MEASURED FAIL) | I06 scorecard | New follow-up ticket on `_train` behaviour; not assigned this wave. |
| G-AI3 | AI | No wave cadence (`wave` increments every think tick), no 5 difficulty tiers, no adviser auto-control, no randomized strategies, resource cheat on hard; donor has all | **M/P** | R06 C1,C8,C12,C15,C19 | Follow-up tickets; keep default traces stable. |
| G-FM1 | Formations | P-30/P-40 genuinely wired: 149 donor tuples imported with 0 value diffs, SQUAD_MAX=403 enforced; but only 3 of 149 families reachable; donor 37.5 s hold timer + 25% auto-disband absent | **C/M** | R03 | MICRO rows 52–59 stale; fidelity follow-ups. |
| G-FM2 | Morale | No donor morale/veteran/experience/rout system in scripts at all — those port features are UNVERIFIED inventions, not parity | **U** | R03 | Do not claim donor parity; mark honestly. |
| G-W1 | Combat | P-06 PROT_SLOT fix + P-23 upgrades wired; pikeman/roundshier `prot` arrays match donor exactly; MICRO 60–64 line refs and "P-06 BLOCKED" stale | **C** (corrections) | R04 | No ticket. |
| G-W2 | Combat | Cannon grapeshot range 175 px vs donor 450 px (`data.gd:659` vs `unit.script:1710`); port invented howitzer cannister donor lacks | **M** | R04 | Real fidelity gap; data.gd + game.gd follow-up (after I1 released data.gd). |
| G-RO1 | Roster | Port ahead of RA_ROSTER/P-24: 21 nations incl sco, 48 units, 19 buildings, 71 upgrades, 1524 building keys, 18 sco sheets — older counts stale | **C** (corrections) | R08 | No defect; refresh docs. |
| G-RO2 | Roster | Scotland 1/8 unique units, 3/13 skinned building families; `t_roster_scotland` `>=3` token check miscounts generic `highlander`; upgrade tree wrong firepower/wheellock/bayonet values, Mathematics typed as range not accuracy, all naval upgrades absent | **M/P** | R08 | Depth tickets after high-value work. |
| G-ENV1 | Environment | Donor DISABLES day/night in skirmish (`lib/init.script:99 SetDateTimeManagerEnabled(false)`, never re-enabled) — port's lack of day/night is PARITY, not a gap | **C** (correction) | R10 | Do not ticket day/night. |
| G-ENV2 | Environment | Port has season tint/winter art + donor-equation water PER FRAME (stale P-21 note says chunk-only); only 2/5 ambient beds, no clouds/weather/snow/PFX textures | **P/M** | R10 | `CONFIG_EFFICIENCY.md` G12/CFG-02 and "rain" parity claims stale; fidelity follow-ups. |
| G-HUD1 | HUD | P-25 "DONE" stale: donor net worker counts in `( )`, red negative gold/iron/coal, `9999999+` cap; port gross `[N]`, red only food/gold, no cap. No resource tooltips; idle-peasant/free-mine indicators are text not donor clickable buttons (handlers exist in input_controller.gd). Donor minimap bottom-right 240px vs port bottom-left 200px | **M/P** | R11 | Real fidelity gaps; hud.gd + input_controller.gd follow-up (after current owners). |

## 2. Test infrastructure (owner directive: small, logical, fast sets)

| ID | Finding | Verdict | Source | Action |
|---|---|---|---|---|
| G-T1 | `--self-test <path>` is OUTPUT-only; `C3SelfTest.run()` is a hardcoded 29-step monolith, no filter | **C** | T02 | Add `--self-only` + `run_only()` mirroring `--ui-only`/`run_only` precedent (uitest.gd:64-102; main.gd:819-822,1517). |
| G-T2 | 3 hard state deps only: `squad→formation`, `wall→shell`, `formation_bonus→replenish`; other 26 self-spawn | **C** | T01 | Keep those pairs co-located in subsets. |
| G-T3 | Proposed 8 subsets partition all 29 exactly once: core_movement(3), economy_gather(4), economy_trade_tech(3), buildings(4), combat_ranged(5), formations_morale(5), capture(2), generator_state_ui(3) | **C** | T01 | Awaiting T3 cost/dep report before implementation. |
| G-T4 | Subset results MUST NOT overwrite canonical `app/selftest.json`; use `app/tests/results/selftest_<subset>.json` | **C** (hazard) | T02 | Enforce in implementation + gate docs. |
| G-T5 | `grid_equiv` assertion is inert (always true; mismatch branch is `pass`) | **C** | T01 | Separate strengthening ticket; NOT part of split ("no weakening"). |
| G-T6 | Fresh runner job 1232: 28/29, only `resow` fails; `peasant_capture` flaky (failed in stale report, passed fresh) | **C** | baseline + T01 | D1 diagnosing; fix truth, not hide. |
| G-T7 | Full selftest MEASURED 88.82 s wall (job 1102); ~43.6 s is fixed startup (job 1192 proxy). Per-step wall UNKNOWN. 8 subsets ⇒ 3–5× slower total if all run | **C** | T03 | Subsets are targeted diagnostics only; monolith stays the gate. Decision doc `DECISIONS_TEST_SPLIT.md`. |
| G-T8 | `resow` FAIL is a TEST bug: assertion observes `fnode.hits` AFTER a sim window in which the successful restore's follow-up `gather` order (game.gd:4605) re-drains the ~50-hit field. D1's `_sim(30)→_sim(10)` was insufficient — job 1235 still failed | **C** | D01 + coordinator follow-up | Correct fix = latch `resow_ok` at the first tick where `hits>0` (observe restoration, not the later drain). Sent to **I4** as follow-up. |

## 3. Performance opportunities (ESTIMATE until measured)

| ID | Hotspot | Evidence | Gain label | Proposed fix | Determinism risk | Source |
|---|---|---|---|---|---|---|
| G-P1 | `_grid_rebuild()` allocates `Vector2i` + array per cell EVERY tick; `grid_query()` allocates result + empty defaults at 11 sites | game.gd:213-249 | ESTIMATE (rank 1) | int key `cx+cy*65536` (proven pattern at :3883), in-place bucket clear, shared empty default | NONE–LOW (runtime-only grid) | P01 |
| G-P2 | `enemies_preferred()` recomputes `_kind_class(a)` + TARGET_TABLE row per candidate; ai.gd:520 double call | game.gd:2747-2782, ai.gd:520 | ESTIMATE (rank 4) | Hoist `ac`/`row` out of loop; call once in ai.gd | NONE (pure hoist) | P01 |
| G-P3 | `res_nodes` scanned 3×/tick (stump age, removal, field regrow) at ~1700 nodes | game.gd:3863-3872, 2249-2269 | ESTIMATE (rank 3) | Maintain `stumps`/`fields` arrays; preserve `res_nodes` order | LOW–MED (replay order) | P01 |
| G-P4 | `enemies_preferred`/`_check_victory` rebuild building/unit arrays per call/tick | game.gd:2592-2606, 5371, 2180-2185 | ESTIMATE (rank 5) | Direct live-list loops; `mills` cache | NONE–LOW | P01 |
| G-P5 | HUD status counters scan all units/buildings EVERY FRAME before dirty-text guard | hud.gd:1096-1103 | ESTIMATE (top render) | 0.5 s throttle of counter recompute | NONE | P02 → **I2 builder** |
| G-P6 | One Dictionary allocated per visible unit per frame (`pending_unit_sprites`) | world.gd:590,3061,3127 | ESTIMATE | Preallocate descriptor pool, reset size | NONE | P02 |
| G-P7 | Post-bake chunk scheduling still scans/sorts map every frame at steady state | world.gd:1744-1762,1792-1801 | ESTIMATE | `lod_complete` early-out; shared range | LOW (bake order) | P02 |
| G-P8 | `_bld_key` re-resolved 3×/building/redraw; missing death-sheet probed per corpse/redraw | world.gd:2808-2824,3298-3305 | ESTIMATE | Hoist + negative-cache | NONE | P02 |
| G-P9 | `fx_items.filter()` allocates every frame even when empty | world.gd:2082-2084 | ESTIMATE (trivial) | Guard with `is_empty()` | NONE | P02 |
| G-P10 | Water shader: no further SAFE fetch reduction (~58 deep after T-WATER-FAST) | water_overlay.gdshader:176-271 | **NO_WIN** | Do NOT taper normals (fidelity gate); optional ALU `fract()` removal after A/B | HIGH for normals | P02 |
| G-P11 | Runner queue poll calls `pid_alive()` → `tasklist` (~993 ms MEASURED) every 0.15 s per waiting job | godot_runner.py:296 | MEASURED cost | Gate on `lock_free` + ~2 s throttle | NONE (tooling only) | P04; implement AFTER builders' queued jobs drain |
| G-P12 | `scan_map.py --dir scans` 28.5 s / 39 dumps (~512 ms/file: tuple-set BFS + duplicate `json.load`) | scan_map.py (P04 report) | MEASURED | Single `json.load`, optimize ring loops | NONE | P04 |

## 4. Stale-claim register

| Claim source | Claim | Truth found | Correction | Evidence |
|---|---|---|---|---|
| `RESUME.md`, `STATUS_SKIRMISH.md` | selftest 29/29 PASS | On disk `passed:false`; fresh job 1232 = 28/29 (only `resow`) | Do not cite stale green; D1 diagnosing | `PROGRESS.md`, job 1232 |
| `RESUME.md` | clean gate CLEAN | Was DIRTY from 4 unacked 2026-11-23 timeouts | **RESOLVED 2026-11-24**: ack #1132/#1135/#1184/#1205 after verifying superseding `ok` runs; gate now CLEAN (140 jobs, 4 acked) | `PROGRESS.md` |
| `docs/audit/MICRO.md` | rows 1–4,6–8,10,13,65 missing | All implemented | Do not assign work from MICRO without re-verifying | R01 §2 |
| `README.md`, `COMMANDS.md` | "28-step" selftest | Actual 29 steps | Doc drift; non-blocking | T02 hazard 5 |

## 5. Status of recon lanes

LANDED: R1, R7, R9, R12, P1, P2, P4, T1, T2, T3. Still running: R2–R6, R8, R10, R11, P3, D1, plus builders I1/I2/I3. Test-split decision recorded in `DECISIONS_TEST_SPLIT.md`.
