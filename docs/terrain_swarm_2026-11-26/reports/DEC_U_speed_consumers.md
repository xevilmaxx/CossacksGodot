---
id: DEC-U-SPEED-CONSUMERS-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-SPEED — mechanical full-tree `.speed :=` / `rotatespeed :=` / `speedperc` re-sweep; live vs commented vs definition-only classification; U-base-speed double-count ruling"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_speed_consumers.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; chain 0/6 CLOSED; no parity claim"
scope_guard: "Read-only donor text sweep under `C:\\Games\\Cossacks 3\\data\\scripts\\**` via Get-ChildItem/Select-String/Get-Content plus repo report reads. No code, Godot, git, config, asset, test, fixture, runner or harness edit. No donor binary executed, copied, or captured. No native craftanything call made in this job, so native pin verification was not applicable. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (B7 angle: full-tree `.speed :=` / `rotatespeed :=` sweeps)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md (U-base-speed split id; must NOT be double-counted as 72nd [U] row)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_move_speed.md (18 defined constants; defined-but-dead verdict; live 1)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_speed_consumer_deep.md (native two-channel model; U-base-speed)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md (U-base-speed genuinely-new-but-split statement)
---

# DEC-U — speed consumers re-sweep (`speed` / `rotatespeed` / `speedperc`)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, still, hash, byte dump, `[D]` derivation or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `blocking_unverified` is non-empty, so the verdict is **`RESULT IS NOT GOOD`** unconditionally. No approximation is authorised; no donor binary was executed; no parity claim is made.

## 0. Tooling and method

- **Tooling:** read-only PowerShell only — `Get-ChildItem -Recurse` + `Select-String` + `Get-Content` over `C:\Games\Cossacks 3\data\scripts` (`*.script`, `*.inc`), plus read-only repo report reads. No file was written except this report. No donor executable was run; no donor bytes were copied into the repo.
- **Native craftanything:** NOT used in this job. No `native_*` call was made, so the `t_87f0f3c130b0` pin-verification step has no applicable act. All binary-level claims below are carried `[O]/[D]` cites from `DEC_U_move_speed` / `DEC_U_speed_consumer_deep`, not re-run here.
- **Corpus note:** several top-level `*.inc` shims (`common.inc`, `env/env.inc`, `misc/*.inc`, `progress/progress.inc`, `units/*.inc`, `user/user.inc`) return access-denied on direct `Select-String -Path`; the recursive `Get-ChildItem | Select-String` path used for every table below still traverses their readable nested copies (e.g. `misc/projectile.inc/nothing.inc`, `progress/progress.inc/nothing.inc`, `units/unit.inc/*.inc`, `units/building.inc/nothing.inc`). Errors were `SilentlyContinue`; every hit below is a verbatim `path:line` observation.
- **Classification rule (mechanical):**
  - `LIVE` = uncommented `:=` that executes in shipped script flow (constructor default, init overwrite, upgrade divisor, serial pin, per-sid turn-rate write, live consumer read).
  - `COMMENTED` = line begins with `//` (dead text, never executes).
  - `DEFINITION-ONLY` = constant/type/dispatch/case-label/deactivated-container row that defines a value or routes control but performs no locomotion write by itself.
  - `EXCLUDED-NON-LOCOMOTION` = uncommented `:=` on an unrelated `speed` (game speed, camera/scroll speed, projectile `weapon.speed`, local death-stage variable, `fishingspeed` economy cadence). Recorded so the sweep is exhaustive, excluded from the locomotion writer set with reason.
- Labels: **[O]** = observed donor file:line in this job. **[D]** = arithmetic/counting over cited [O]. **[I]** = withheld reading. **[U]** = unresolved; every live value semantic requiring execution stays `[U]` with exact zero-mismatch termination (§6).

## 1. Full-tree `\.speed :=` sweep (unit locomotion writers)

Command (read-only): `Get-ChildItem -Recurse | Select-String -Pattern '\.speed\s*:='`.

| # | Donor path:line | Verbatim text [O] | Class |
|---|---|---|---|
| S-01 | `data/scripts/lib/unit.script:618` | `objbase.speed := 1;` (inside `_unit_InitBase`, after `objbase.shield := 0;`) | **LIVE** — universal overwrite; every sid reaching `InitBase` leaves with `1` |
| S-02 | `data/scripts/lib/player.script:1930` | `gPlayer[plInd].objbase[cid][iarr2[i]].speed := 1/(gPlayer[plInd].objbase[cid][iarr2[i]].speed*(1+value/100));` (inside `gc_upg_type_speedperc` branch) | **LIVE** — only live mutator of the divisor (see §4) |
| S-03 | `data/scripts/lib/serial.script:516` | `gPlayer[i].objbase[cid][id].speed := 1;` (compat pin, `gSerialVersion<91` region) | **LIVE** — serial compat pin restoring pre-upgrade divisor |
| S-04 | `data/scripts/lib/unit.script:1192` | `//objbase.speed := gc_obj_speed_peasant;` | COMMENTED (dead) |
| S-05 | `data/scripts/lib/unit.script:1322` | `//objbase.speed := gc_obj_speed_fasthorse;` | COMMENTED (dead) |
| S-06 | `data/scripts/lib/unit.script:1420` | `//objbase.speed := gc_obj_speed_hardhorse;` | COMMENTED (dead) |
| S-07 | `data/scripts/lib/unit.script:1546` | `//objbase.speed := gc_obj_speed_hardhorse;` | COMMENTED (dead) |
| S-08 | `data/scripts/lib/unit.script:1699` | `//objbase.speed := gc_obj_speed_cannon;` | COMMENTED (dead) |
| S-09 | `data/scripts/lib/unit.script:1735` | `//objbase.speed := gc_obj_speed_howitzer;` | COMMENTED (dead) |
| S-10 | `data/scripts/lib/unit.script:1767` | `//objbase.speed := gc_obj_speed_mortar;` | COMMENTED (dead) |
| S-11 | `data/scripts/lib/unit.script:1796` | `//objbase.speed := gc_obj_speed_multicannon;` | COMMENTED (dead) |
| S-12 | `data/scripts/lib/unit.script:1826` | `//objbase.speed := gc_obj_speed_cannon;` | COMMENTED (dead) |
| S-13 | `data/scripts/lib/unit.script:1857` | `//objbase.speed := gc_obj_speed_fishboat;` | COMMENTED (dead) |
| S-14 | `data/scripts/lib/unit.script:1875` | `//objbase.speed := gc_obj_speed_yacht;` | COMMENTED (dead) |
| S-15 | `data/scripts/lib/unit.script:1906` | `//objbase.speed := gc_obj_speed_yachttur;` (deeper-indented but still `//`-prefixed) | COMMENTED (dead) |
| S-16 | `data/scripts/lib/unit.script:1924` | `//objbase.speed := gc_obj_speed_galley;` | COMMENTED (dead) |
| S-17 | `data/scripts/lib/unit.script:1961` | `//objbase.speed := gc_obj_speed_frigate;` | COMMENTED (dead) |
| S-18 | `data/scripts/lib/unit.script:1991` | `//objbase.speed := gc_obj_speed_xebec;` | COMMENTED (dead) |
| S-19 | `data/scripts/lib/unit.script:2001` | `//objbase.speed := gc_obj_speed_battleship;` | COMMENTED (dead) |
| S-20 | `data/scripts/lib/unit.script:2015` | `//objbase.speed := gc_obj_speed_chaika;` | COMMENTED (dead) |
| S-21 | `data/scripts/lib/unit.script:2035` | `//objbase.speed := gc_obj_speed_ferry;` | COMMENTED (dead) |
| S-22 | `data/scripts/lib/weapon.script:59` | `gc_weapon_propagation_random, gc_weapon_propagation_random1, gc_weapon_propagation_fly, gc_weapon_propagation_randomsimulate : weapon.speed := physvalue;` | EXCLUDED-NON-LOCOMOTION — projectile propagation setter, not unit locomotion |

**[D] counts:** 22 `\.speed :=` hits total = **3 LIVE** locomotion writers (S-01/S-02/S-03) + **18 COMMENTED** per-sid writes (S-04…S-21) + **1 EXCLUDED** projectile writer (S-22).

**Observed discrepancy vs prior prose:** `DEC_U_move_speed` / `DEC_U_speed_consumer_deep` prose says "17 per-sid writes". This mechanical sweep observes **18** `//objbase.speed := gc_obj_speed_*` lines (S-04…S-21). The 18th is real file text (the `ferry` row at `unit.script:2035` alongside the `chaika` row at `:2015`; both present on disk). No row is promoted or invented by this correction — all 18 are COMMENTED dead text, so the defined-but-dead verdict is unchanged; the count correction is `[D]` over the [O] table above.

**B7 confirmation:** every per-sid `objbase.speed` write is `//`-commented **except** `unit.script:618` forcing `1`. Confirmed mechanically: S-01 is the sole uncommented `objbase.speed :=` in `unit.script`; the only other uncommented locomotion writers in the whole tree are S-02 and S-03. No other live `\.speed :=` locomotion writer exists in the swept corpus.

## 2. Full-tree `rotatespeed :=` sweep

Command (read-only): `Get-ChildItem -Recurse | Select-String -Pattern 'rotatespeed\s*:='`.

| # | Donor path:line | Verbatim text [O] | Class |
|---|---|---|---|
| R-00 | `data/scripts/lib/classes.script:3660` | `rotatespeed := gc_obj_rotatespeed_default;` (inside `TObjProp.Create`) | **LIVE** — class default (value 5); every sid inherits unless overridden |
| R-01 | `data/scripts/lib/unit.script:1701` | `objprop.rotatespeed := gc_obj_rotatespeed_cannon;` | **LIVE** — cannon branch |
| R-02 | `data/scripts/lib/unit.script:1737` | `objprop.rotatespeed := gc_obj_rotatespeed_howitzer;` | **LIVE** — howitzer branch |
| R-03 | `data/scripts/lib/unit.script:1770` | `objprop.rotatespeed := gc_obj_rotatespeed_mortar;` | **LIVE** — mortar branch |
| R-04 | `data/scripts/lib/unit.script:1798` | `objprop.rotatespeed := gc_obj_rotatespeed_multicannon;` | **LIVE** — multicannon branch |
| R-05 | `data/scripts/lib/unit.script:1828` | `objprop.rotatespeed := gc_obj_rotatespeed_cannon;` | **LIVE** — framegun-cannon branch |
| R-06 | `data/scripts/lib/unit.script:1859` | `objprop.rotatespeed := gc_obj_rotatespeed_ships;` | **LIVE** — fishboat branch |
| R-07 | `data/scripts/lib/unit.script:1877` | `objprop.rotatespeed := gc_obj_rotatespeed_ships;` | **LIVE** — yacht branch |
| R-08 | `data/scripts/lib/unit.script:1926` | `objprop.rotatespeed := gc_obj_rotatespeed_ships;` | **LIVE** — galley branch (xebec/battleship/chaika inherit frigate-branch context) |
| R-09 | `data/scripts/lib/unit.script:1963` | `objprop.rotatespeed := gc_obj_rotatespeed_ships;` | **LIVE** — frigate branch |
| R-10 | `data/scripts/lib/unit.script:2037` | `objprop.rotatespeed := gc_obj_rotatespeed_ships;` | **LIVE** — ferry branch |

**[D] counts:** 11 `rotatespeed :=` hits total = **11 LIVE, 0 COMMENTED**. Unlike `speed`, the whole turn-rate table is live text (no `//` prefix on any row). The only commented turn-rate row in the corpus is the superseded definition `dmscript.global:622` (`//gc_obj_rotatespeed_default = 16;`), which is DEFINITION-ONLY (§3), not a write.

Live consumers of `rotatespeed` [O] (reads, not writes — recorded for completeness, all LIVE text):
- `unit.script:10996`, `:11001`, `:11066`: `gObjProp[…].rotatespeed*2.225` passed as `animangle` to `GameObjectSetupRotatingToDirection/TargetByHandle(…, 50, GetGameObjectEpsilonAngleByHandle(hnd), True)`.
- `units/unit.inc/ontagstates.inc:454`, `:459`: same `rotatespeed*2.225` shape via `GameObjectMySetupRotatingToDirection/Target`, but each line is prefixed `[*] = ;` (deactivated container) — classified DEFINITION-ONLY/deactivated, not a live consumer.

## 3. `speedperc` sweep (assignments and activation)

Command (read-only): `Get-ChildItem -Recurse | Select-String -Pattern 'speedperc'`. Case-insensitive; whole tree.

| # | Donor path:line | Verbatim text [O] | Class |
|---|---|---|---|
| P-01 | `data/scripts/dmscript.global:759` | `gc_upg_type_speedperc = 22;` | DEFINITION-ONLY — upgrade-type enum value |
| P-02 | `data/scripts/lib/player.script:1721` | `gc_upg_type_speedperc : begin` (first `case` dispatch: `sarrparam2` → `iarr2` id mapping, `:1721-1729`) | DEFINITION-ONLY — registration/dispatch, performs no speed write |
| P-03 | `data/scripts/lib/player.script:1927` | `gc_upg_type_speedperc : begin` (second `case` dispatch: divisor + TrackPoint rewrite, `:1927-1946`) | LIVE dispatch — guards the S-02 writer and the Floor rewrite below |
| P-04 | `data/scripts/lib/country.script:3639` | `_country_AddUpgradeWithAccessControl(country, upgplace+'.28', 1, gc_upg_type_none, gc_upg_type_speedperc, 40, …)` | DEFINITION-ONLY — single shipped upgrade row binding `speedperc` value `40` (shipspeed +40); the only shipped `speedperc` value literal |
| P-05 | `data/scripts/lib/player.script:1930` | (same as S-02) divisor write | **LIVE** — the sole live `speedperc` assignment (cross-listed) |

No `speedperc` hit exists in any `*.inc`, `user.inc`/`resetdefaults.inc`, or map script in the swept corpus [O-negative within sweep limits]. The `fishingperc` neighbour (`dmscript.global:756`, `player.script:1902`, `unit.script:11934`) is a separate economy-cadence upgrade scaling `fishingspeed`, not locomotion — EXCLUDED with reason (§5).

## 4. The only live locomotion mutators (enumerated, nothing else)

1. **`objbase.speed` divisor chain (Float, script-side):**
   - Init: `unit.script:618` → `1` (LIVE).
   - Class default it overwrites: `classes.script:3589` (`speed := gc_obj_speed_default;` = 32, inside `TObjBase.Create`) — LIVE constructor default, definitionally superseded by `:618` for every sid reaching `InitBase`. Classified LIVE-default/superseded, not a second live value.
   - Sole mutator: `player.script:1930` → `1/(s·(1+value/100))` (LIVE; shipped value `40` from `country.script:3639`).
   - Sole reset: `serial.script:516` → `1` (LIVE compat pin).
   - Bridge to native (both LIVE text, same branch): `player.script:1941` `SetGameObjectTrackPointMoveStepIntervalByHandle(trgHnd, Floor(movestepinterval*speed))` and `:1943` `SetGameObjectTrackPointTurnStepIntervalByHandle(trgHnd, Floor(turnstepinterval*speed))`, gated by `:1938` `if (pobj2<>nil) {and _unit_IsWaterUnit(trgHnd)} and (speed>0) and (speed<>1)`. The `{…}` brace semantics (comment vs condition) are DSL-ambiguous on static text alone — gate scope stays **[U] U-upg-gate**; stacking behaviour (oscillation vs compounding) stays **[U] U-upg-stack**. Neither is decided here.
2. **`rotatespeed` table (Float, script-side) + native rotate consumer:**
   - 11 LIVE writes (§2, R-00…R-10) + 6 DEFINITION-ONLY constants (`dmscript.global:623-628`; `:622` commented superseded `16` kept as comment).
   - Live consumer: `rotatespeed*2.225` → `animangle` at `unit.script:10996/11001/11066` (LIVE). Native signature/timing (`animtimeinterval=50`, `minturnangle`, `usecycles`) is engine-native and unrecovered statically — stays **[U] U-turn / U-motionstyle**.
3. **Nothing else in the corpus writes unit locomotion speed.** In particular: no `accel/decel/MaxSpeed` locomotion row; no terrain-cost scalar; no formation/carry speed scalar (all P11-T-class greps negative, carried from `DEC_U_move_speed` §§2/4/5). Those absences are negative grep results, not positive donor laws — they stay **[U]** (§6), never fitted.

## 5. Exhaustiveness: other `speed` writes seen and excluded (with reason)

These uncommented `:=` hits contain `speed` but are NOT unit locomotion and are NOT counted in the §1 live set:

- **Game-speed / time-scale plumbing:** `control.script:540-542/556-559/566`, `misc.script:6342-6349`, `map.script:326/328`, `miscext2.script:2382/2642`, `movie.script:270/295/299`, `unit.script:6681`, `progress/progress.inc/nothing.inc:512-514/520/545/548/553/556/558-559/585/609/614-615` (`speedfactor`, `gamespeed`, `timespeedfactor`, `newspeed/curspeed`, `progressspeedfactor`). Match-session speed, not per-unit velocity.
- **Camera/scroll speeds:** `classes.script:5099-5103/5134`, `profile.script:17-21/50/250-256/301/513-517`, `gui.script:3332` (`keyscrollspeed/mousescrollspeed/middlemousescrollspeed/wheelspeed/igamespeed`, `cDeltaSpeed`, `bCheatNoSpeedLimit`, `ach…towerattspeed`).
- **Projectile behaviour:** `weapon.script:59` (S-22), `:821/831/845-847/908/936/938/953` (`weapon.speed`, `CalcSpeedByDirAndTrgPos`, `cModifierSpeed`, `rotspeed`, `ThrowByHSpeed`); `misc/projectile.inc/nothing.inc:43-45` (`HSpeed/VSpeed` locals). Ballistics, not locomotion.
- **Death-stage locals:** `units/unit.inc/deathstage2.inc:29/35/38` (`speed := 0.022/disp…`, `GetTimeSpeedFactor/10` scaling). Corpse-slide staging, not locomotion.
- **Gathering cadence (`fishingspeed`):** `classes.script:3579` (field decl), `unit.script:1865` (`:= 50 div 4`), `player.script:1902` / `unit.script:11934` (`Round(…*(1+value/100))` via `fishingperc`). Economy cadence, not velocity; never conflated with `speedperc` here.
- **Deactivated containers:** `units/unit.inc/ontagstates.inc:454/459` (`[*] = ;` prefix) and any `[*] = ;` speed line in `units/building.inc/nothing.inc` are DEFINITION-ONLY/deactivated, not live.

## 6. Definitions carried (definition-only, no write)

- `dmscript.global:603-620`: 17 `gc_obj_speed_*` constants (default 32, peasant 40, hardhorse 56, fasthorse 96, cannon 20, mortar 24, howitzer 20, multicannon 16, fishboat 16, ferry 28, yacht 40, yachttur 70, chaika 55, galley 40, frigate 30, xebec 28, battleship 16). DEFINITION-ONLY — no live consumer; the 18 per-sid write sites that referenced them are all COMMENTED (§1).
- `dmscript.global:622-628`: 6 live `gc_obj_rotatespeed_*` constants (default 5, cannon 1, mortar 4, howitzer 4, multicannon 5, ships 2) + commented superseded `:622` (`16`). DEFINITION-ONLY values consumed by the 11 LIVE writes (§2).
- `dmscript.global:303-305`: `gc_obj_motionstyle_*` (0/1/2). DEFINITION-ONLY; native effect unrecovered — **[U] U-motionstyle**.
- `dmscript.global:756/759`: `gc_upg_type_fishingperc = 19` / `gc_upg_type_speedperc = 22`. DEFINITION-ONLY enum values.

## 7. U-base-speed double-count ruling

**Ruling: U-base-speed is strictly a split (sub-id) of the already-counted `U-speed-consumer / T-SPEED` row. It MUST NOT be counted as a 72nd top-level `[U]` row. Register total stays 71.**

Evidence chain (all carried, no new binary work in this job):

1. `PORT1TO1_u_register2.md:65` states the 71 is the row count at authoritative register granularity and that `U-base-speed` "is a split of the already-counted `U-speed-consumer / T-SPEED` row …, so it adds a tracked id without removing or duplicating a register row." `PORT1TO1_u_classify.md §2.2` lists `U-speed-consumer / T-SPEED` as the single Domain-T row covering "18 defined-but-dead speed constants, native TrackPoint integration" with the B7 full-tree sweep as its next angle.
2. `PORT1TO1_p0_final_status.md:69` calls `U-base-speed` the new `[U]` but scopes it to "no byte-proven global base speed or tick default" with closer **T-BASE** (spawn-measured `GetGameObjectTrackPointMoveStep(Interval)ByHandle` defaults) — i.e. the native-default half of the same consumer question whose script half is this sweep. `DEC_U_speed_consumer_deep.md §3.3/§6` defines it the same way: the two-channel model (Float step + Integer interval, §2.3 of that report) constrains the SHAPE of any answer but supplies no VALUES.
3. This sweep supplies the script half mechanically (§§1-4): live value after `InitBase` is `1` for every sid; the only live script mutator is the `speedperc` divisor + `Floor(interval·speed)` Integer-interval rewrite; the 18 per-sid constants are dead text. It does NOT supply native step/interval defaults — no `MoveStep/MoveStepInterval/TurnStep/TurnStepInterval` default, no `1 tile per interval`, no tick default is byte-proven anywhere in this text sweep, consistent with the carried `2.225`-0-hit / `1.0f`-1821-hit negative result.
4. Therefore U-base-speed introduces **no new top-level unknown**: it names the native-default sub-question of T-SPEED (script constants dead → what does native actually integrate?). Counting it as a 72nd row would double-count the same `U-speed-consumer / T-SPEED` register entry. The split id is tracked (T-BASE terminator below) at zero register-count cost.

## 8. What stays `[U]` (execution-required; exact zero-mismatch termination)

No live value semantic below is decided by this static sweep. Each ends in a named owner/COORD-only fixed-seed trace; ANY single mismatch keeps the item `[U]` and forbids wiring. No speed value is invented here; nothing is promoted to port behaviour.

- **U-speed-consumer / T-SPEED** (steady-state velocity per class): carried from `DEC_U_move_speed §8` / `DEC_U_speed_consumer_deep §6` — 5 trials × 15 classes, middle-50% mean velocity vs §6-defined constants within ±1 tick / ±0.05 m, 0 mismatches. Prediction recorded (trace FAILS — live `objbase.speed` is 1 for all classes) is never fitted.
- **U-base-speed / T-BASE** (native step/interval defaults — the split id): carried from `DEC_U_speed_consumer_deep §6` — 10 trials × 3 classes (foot/horse/ship), spawned `MoveStep/MoveStepInterval/TurnStep/TurnStepInterval` defaults identical within exact Integer + ±1 ulp Float equality, per-tick displacement equals `MoveStep` every `MoveStepInterval` ticks within ±1 tick, 0 mismatches. Closes only with MEASURED defaults, never an assumed `1 tile`.
- **U-turn / U-motionstyle / T-TURN**, **U-accel / T-ACCEL**, **U-terrain / T-TERRAIN**, **U-formation / T-FORM**, **U-carry / T-CARRY**, **U-upg-gate + U-upg-stack / T-UPG**, **U-walkinterval / T-WALK**: all carried unchanged from `DEC_U_move_speed §8` / `DEC_U_speed_consumer_deep §6`. This sweep adds no value, ramp, scalar, gate, or default to any of them.

## 9. Verdict and claim register

| # | Claim | Label |
|---|---|---|
| 1 | Full-tree `\.speed :=`: 22 hits = 3 LIVE locomotion writers (`unit.script:618`, `player.script:1930`, `serial.script:516`) + 18 COMMENTED per-sid writes + 1 EXCLUDED projectile writer; every per-sid write `//`-commented except `:618` forcing `1` | [O] §1 |
| 2 | Full-tree `rotatespeed :=`: 11 hits, all LIVE (1 class default + 10 per-sid writes); live consumer `rotatespeed*2.225` at `unit.script:10996/11001/11066` | [O] §2 |
| 3 | `speedperc`: 1 definition + 2 dispatches + 1 shipped value-40 row + sole live divisor writer; no `.inc`/user/map hit | [O] §3 |
| 4 | Only live locomotion mutators are the §4 divisor chain + Floor interval rewrite and the §2 turn-rate table; all other `speed` writes excluded with reason | [D] §§4-5 |
| 5 | U-base-speed is strictly a split of counted `U-speed-consumer / T-SPEED`; NOT a 72nd row; register total stays 71 | [D] §7 vs cited registers |
| 6 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared; exactly one repository file written; no value invented or promoted | [O] scope guard |
| 7 | `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; six-condition chain 0/6 CLOSED; no parity claim | [D] governing verdicts |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the domain tails, including the still-`[U]` speed family T-SPEED/T-BASE/T-TURN/T-ACCEL/T-TERRAIN/T-FORM/T-CARRY/T-UPG/T-WALK); six-condition chain 0/6 CLOSED. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made. Static closures never close class-A value/behaviour items.

## 10. Provenance appendix (read-only commands)

Donor sweeps (all read-only; `SilentlyContinue` on locked shims; sorted `path:line` output):

1. `Get-ChildItem -Path 'C:\Games\Cossacks 3\data\scripts' -Include *.script,*.inc -Recurse -ErrorAction SilentlyContinue | Select-String -Pattern '\.speed\s*:='` → §1 table (22 rows).
2. `Get-ChildItem … | Select-String -Pattern 'rotatespeed\s*:='` → §2 table (11 rows).
3. `Get-ChildItem … | Select-String -Pattern 'speedperc'` → §3 table (5 rows incl. cross-listed writer).
4. `Get-ChildItem … | Select-String -Pattern 'gc_obj_speed_'` + `Get-Content dmscript.global | Select-String -Pattern 'gc_obj_speed_|gc_obj_rotatespeed_|gc_obj_motionstyle_'` → §6 definitions (17 + 6 + 1 commented + 3 motionstyle).
5. `Get-ChildItem … | Select-String -Pattern 'speed' | Where-Object { $_.Line -match ':=' }` (broad `speed` `:=` audit incl. `fishingspeed`, `gamespeed`, `weapon.speed`, death-stage locals) → §5 exclusions.
6. `Get-Content classes.script | Select-String 'speed|Speed'`; `Select-Object -Index` windows for `unit.script:610-625` (`:618` context), `player.script:1919-1949` (Floor rewrite), `serial.script:509-519` (compat pin), `unit.script:11059-11069` (rotate consumer), `classes.script:3584-3610/3654-3670` (constructor defaults), `player.script:1715-1735` (dispatch), `unit.script:1860-1870` (fishingspeed) → §4 contexts.
7. Repo reads: `PORT1TO1_u_classify.md` (B7), `PORT1TO1_u_register2.md:65/§3-N-1` (split ruling), `PORT1TO1_p0_final_status.md:69` (T-BASE), `DEC_U_move_speed` + `DEC_U_speed_consumer_deep` (carried binary/negative results, not re-run).

*End of DEC_U_speed_consumers. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
