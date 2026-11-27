---
id: PORT1TO1-D-COSMETIC-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER D-COSMETIC — evidence-backed audit of the ten class-D tails; priority judgement vs donor-fidelity separation"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d_cosmetic.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; P0-1…P0-8 remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; ten class-D items remain [U] and are NOT CLOSED; no approximations; no parity claim"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc file reads only. No source, shader, asset, config, test, fixture, result JSON, backup, queue file or git state written; no donor binary executed/captured/copied; no Godot process, runner job, gate, harness, replay or port capture run. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md  (§2.3/§2.5/§3/§5 — source of the ten class-D ids and the mechanical class rule)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_final_register.md  (§0 tails; §3 E-ART; §5 F tail)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md  (§2.3 E-ART; §2.5 F tail; §3 C4; §5)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md  (§10 P-7 ghost tail; §11 claim 4 'tails are never promoted')
  - per-item evidence reports: DEC_U_ghost_blink.md, DEC_U_entities_art_collision.md, DEC_U_aaf_art_audit.md, DEC_U_pfx_scale.md, DEC_U_smoke_burn_ttl.md, DEC_U_bld_death_time.md, DEC_U_death_families.md, DEC_U_menu_peace.md, DEC_U_market_tail.md, DEC_U_victory_start.md, DEC_U_endgame_team_deep.md
---

# PORT1TO1 — Worker D-COSMETIC: the ten class-D tails, evidence and reclassification conditions (2026-11-27)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, ROI, still, hash or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `blocking_unverified` is non-empty (P0-1…P0-8 plus the tails), so the verdict is **`RESULT IS NOT GOOD`** unconditionally. No approximation is authorised; no donor GPU/runtime session was executed by this worker; no parity claim is made.

---

## 0. Scope of this pass and the single most important caveat

`PORT1TO1_u_classify.md` assigned exactly ten still-open `[U]` items to class **D** (4 in Domain E, 6 in Domain F; total 10 of 71). This report enumerates all ten, states what each controls, carries the donor evidence with `file:line`/byte citations, gives the scope under which it is non-blocking, and names the exact condition that would reclassify it as blocking.

**Class-D status is a priority judgement, not a donor-fidelity claim.** The mechanical rule in `PORT1TO1_u_classify.md §1` assigned D by precedence C > D > B > A to items listed in `DEC_U_final_register.md §0` / `PORT1TO1_u_register_update.md §2.5` tails. That assignment ranks the *next act*; it does **not** prove that the item cannot change a pixel or a simulation word. Several class-D items plainly can change pixels in a context where the port currently stands in an invented value (green/red ghost tint, procedural rally pole, square FX quads, missing `*a` child meshes); one can change simulation words in an edge case (market blend/economy-tracker float semantics). The honest non-blocking scope and the reclassification conditions are stated per item in §2/§3, and the items where the rationale is weakest are aggregated in §4 for the owner.

**None of the ten is CLOSED.** Every one remains `[U]`. This report promotes nothing, wires no value, and does not relax any experiment. `PORT1TO1_owner_decisions.md:351` (claim 4): "tails are never promoted"; `PORT1TO1_owner_decisions.md:338` (P-7): ghost colour/blink "is an explicit non-blocking TAIL ... never promote".

---

## 1. What class D does and does not assert

- **It does** record an owner-priority decision that the item is not one of the P0 blocking set and must not be used to close a P0 (`PORT1TO1_u_classify.md §1 rule 2`; `DEC_U_final_register.md §0`).
- **It does not** assert donor fidelity, a matched-frame pass, a zero-mismatch result, or absence of a visible/simulation effect. `visual_parity_claim = false` applies to these items exactly as to the P0s.
- Two discipline rules carried verbatim (`PORT1TO1_u_register_update.md:44-45`): a CLOSED-STATIC/CLOSED-NEGATIVE settles only the named static question, not the behaviour hanging off it; a structural closure is not a value closure. Therefore, e.g., the recovered ghost alpha law `[O]` does not close the tint `[U]`; the recovered death-art paths `[O]` do not close the stub-rendering `[U]`.
- The port behaviour for each tail (invented tint, `RALLY_TTL=2.0`, square FX quads, `LIFE` table, linear-market remnants, extension score victory, port team-continuation policy) remains **labelled** approximation/port-choice and is not endorsed as donor by this report.

---

## 2. Master register of the ten class-D items

Legend: **Genuinely NB** = non-blocking under any matched skirmish simulation/visible frame in which the item's context does not appear or the donor has nothing to match; **Scope-bound NB** = non-blocking only if the owner's matched-frame set excludes the transient/UI context (stated per item); **NOT genuinely NB** = the donor evidence shows a possible simulation divergence and the class-D rationale does not hold on donor-fidelity grounds.

| # | ID | Domain | What it controls | Donor evidence (cites) | Non-blocking scope / rationale | Exact reclassification condition | Honest verdict |
|---:|---|---|---|---|---|---|---|
| 1 | **D1** ghost colour/blink tint `[U]-G` | E — entities/FX | Placement-ghost preview: alpha law of `TXLifeColorEffect 'blink'`, mesh source, and the port's invented green/red tint + `sin(4t)` pulse | `DEC_U_ghost_blink.md §0/§2/§3/§8`: 3-key alpha `0.5→0.35→0.5` (OK) / `0.5→0.45→0.5` (BAD), period `2×0.525×1.25×speed/10` = 1.3125 s @ speed 10 `[O]`; all placement callers pass `bUseColor=False` → colour arms dead; live object is the building mesh, not `box.mesh` (strong inference); native key interpolation/Time semantics/`GetTimeSpeedFactor` `[U]`; `PORT1TO1_owner_decisions.md:338` P-7 explicitly non-blocking | Does not enter the skirmish simulation state; a transient build-placement UI overlay only. The alpha law is `[O]`; the residual `[U]` is tint/interpolation native-only. Owner already ruled it a non-blocking tail (P-7) | E-GHOST-CAP (`DEC_U_ghost_blink.md §7`) fails zero-mismatch **and** the owner's matched-frame set includes the ghost-placement preview (CAP-3 drag/ghost frames, `V21_gate_register.md GR-C04`) → visible-frame blocker. Also if the port tint is ever presented as donor-verbatim | Scope-bound NB |
| 2 | **D2** rally TTL / pennant `[U]-R` | F — UI/visual | Rally marker: retained mesh vs the port's procedural pole+finial+pennant and `RALLY_TTL=2.0` | `DEC_U_entities_art_collision.md §4.1` (`ev_ad12…`): `rallypoint.prop` = `rallypoint.mesh`, material `rallypoint`, `DefaultScale 0.0525³`, `DefaultRollAngle 45`, `ocoTerrainWater`; **no TTL key**; port `RALLY_TTL=2.0` is self-labelled port choice. `DEC_U_aaf_art_audit.md §2.3/§4`: art meshes + textures all present `[O]`; lifetime/flag motion `[U]-R` | Rally point as a sim order is set by an event; the marker's lifetime is a visual overlay only and cannot change unit orders, resource totals or victory state | E-U14 rally capture (`DEC_U_entities_art_collision.md §4.2` item 2) fails zero-mismatch **and** a matched frame includes a visible rally marker → visible-frame blocker; or if the port's 2.0 s TTL is wired into any sim/order-expiry path | Scope-bound NB |
| 3 | **D3** peace-menu labels `U-M*` | F — UI/visual | Displayed strings + order of the Peace Time dropdown rows (`No Peace Time`, `10 min`, `15 min`, …, `4 hours`) | `DEC_U_menu_peace.md §2/§3`: verbatim `gui.txt:553-575` labels; fill loop `showcustomgame.inc:1126-1150` gives display order/tags `{0,1,11,2,3,4,5,6,7,8,9}`, index 10 reserved/unselectable; port renders `No` and `%d min` for all non-zero rows (defect). `DEC_U_victory_start.md §2.1` corroborates the index table | Menu text is UI chrome; it does not enter the sim. The *seconds wiring* is a separate matter (`F-60` 60× defect, `DEC_U_menu_peace.md §7`, captured as U-M3/U-P2) and is not part of D3 — do not use D3 to excuse that defect | U-M1 (`DEC_U_menu_peace.md §8`) fails **and** the owner includes the expanded lobby dropdown in the matched-frame ROI set → visible-frame blocker. If F-60 is left unwired and a peace-expiry capture is in scope, that is a *different* item and is blocking there | Genuinely NB for skirmish sim; scope-bound for lobby frames |
| 4 | **D4** market blend edge `U6-T`/`DLT` | F — UI/visual id, E/S sim effect | Residual engine-defined float semantics at the edges of the already-recovered rational cost-push law and the `garr_res_dlt` economy tracker (ordering, `Lerp`/`ClampInt`/`floor` at `t=deltatime`, large-`w` trades) | `DEC_U_market_tail.md §1` law `(c+bound·w)/(1+w)` `res.script:337-342` `[O]` (linear guess withdrawn); §2 `garr_res_dlt` live in game mode `res.script:252-268` `[O]`; §6 U6-T and DLT remain `[U]` with 36-float / 600-tick zero-mismatch captures. `DEC_U_final_register.md §0` lists the edge as a tail | The *law* is recovered and ported; only edge float semantics remain. Under small-volume/trades-in-range captures the rational form and the engine semantics agree, so the tail is non-blocking **in that narrow scope** | Capture U6-T or DLT (`DEC_U_market_tail.md §1/§2`) fails zero-mismatch in a matched run that includes large-volume AI trades (`5000–600000` amounts, `progresseconomicai.inc:3016-3211`) or the 600-tick `dlt` window → market prices diverge → **simulation blocker**. This is the item where class-D status is least defensible on donor-fidelity grounds (see §4) | **NOT genuinely NB if market prices are in scope** |
| 5 | **D5** death-smoke TTL | E — entities/FX | Burning/death smoke looper visual tail: start/stop frames, rendered tail, per-layer duration; **not** the destroy scheduler | `DEC_U_smoke_burn_ttl.md §0/§1/§3/§6`: `buildingsmoke` 4 children `parentrandom=true`; survival is `samLoop` + `Free=False` + `BirthTime=1.792 s`; stop is event-driven (`MyGameObjectPFXClear` + misc-child clear + holder destroy), **no timer TTL** `[O]/[D]`. `DEC_U_bld_death_time.md §5/§6/§8`: schedulers pass raw `30`/mine ×2 with no `FramesToTime` multiply `[O]`; wall-clock time base (30 s vs 0.9375 s) and burn tail `[U]` (E-U14-ttl/burn) | Smoke is a PFX overlay; its stop is event-driven and cannot change sim state. The *scheduler time base* is a distinct `[U]` — D5 must not be read as closing it | E-U14-burn (`DEC_U_bld_death_time.md §6`) fails **and** a matched frame includes the `_death1→_death2→destroy` window → visible-frame blocker. Separately, if the port ever resolves the 30-value into a `life`/TTL argument (forbidden by `DEC_U_bld_death_time.md §7 T1`), or if E-U14-ttl shows the destroy timing differs → **simulation blocker** (distinct `[U]`, not settled by D5) | Scope-bound NB |
| 6 | **D6** PFX `PixelRatio`/`Interval` `[U]-F` | E — entities/FX | FX world size (`PixelRatio→metres` divisor) and frame-to-seconds stepping (`Interval×FrameRate`); port `LIFE` table + square quads are labelled stand-ins | `DEC_U_pfx_scale.md §1`: `Interval×FrameRate≈1000` on all 44 `source.pfx` sections, `secPerFrame=Interval/1000=1/FrameRate` `[O/D]`; exact TTLs smoke 1.28 s, flash 0.4 s, fire/smoke 1.792 s `[D]`. §2: `PixelRatio` bases 15..1250 `[O]`, divisor→world units `[U]`; §8 E-U3-time/size/curve zero-mismatch captures. `DEC_U_aaf_art_audit.md §4 [U]-F` | PFX are visual overlays; no sim field (HP, ownership, resource, victory) is driven by FX quad size or frame stepping in the recovered law. The FX RNG seed attribution (U7) is a **separate** class-A item and is not closed by D6 | E-U3-time/size/curve (`DEC_U_pfx_scale.md §8`) fails **and** a matched frame includes musket/cannon flash or smoke → visible-frame blocker. If PFX RNG is proven to share the sim stream (U7) and diverges, that is a sim blocker under its own id, not D6 | Scope-bound NB |
| 7 | **D7** `*a` child meshes | E — entities/FX | Building scaffold/debris attach children across birth and death stages; port converted only `eurmil` (`BLD_DEATH_STEMS = {"mil":"eurmil"}`), 11 families still `[U]-OTHER` | `DEC_U_aaf_art_audit.md §2.2/§3/§4 [U]-B`; `DEC_U_death_families.md §0/§3/§4`: donor death art **present for all 11 remaining families** (parent `_death1/2.osm`, attach `_death1a/2a.osm`, 7-slot actors, `Mesh[5..6]=…a` + `Materials[5..6]=debris`) `[O]`; mesh selection law fully determined by `ontagstates.inc:267-286` `[O]`; port conversion gap explicit; `ukrhou≡ukrbla` attach sizes recorded `[O]` | Mesh selection is static law `[O]`; the open piece is conversion coverage, not a value/behaviour unknown. No simulation field is driven by whether a debris child mesh is present | R-STAGE / conversion capture fails (`DEC_U_death_families.md §5 item 5`) **and** a matched frame includes a birth/death stage of a non-`mil` building → visible-frame blocker (missing scaffold/debris child). If a child mesh is wired into collision/occupancy, that is a separate sim item | Scope-bound NB; conversion coverage is real and audit-able |
| 8 | **D12** 660 B `eursto`/`eurtow` death-attach stubs | E — entities/FX | Degenerate 660 B `eursto/eurtow _death1a/2a.osm` death-attach children; whether the donor renderer shows/skips/culls them | `DEC_U_death_families.md §4.1` `[O]`: each exactly 660 B, first-64-byte headers byte-identical IDP2 v8 + near-empty frame table; donor still binds them at `Mesh[5..6]` with `debris` and the selector swaps them with no size guard `[O]`; `[U]-STUB` renderer behaviour; R-STUB capture specified; port must convert stubs as-is, never substitute eurmil/scaffold | Donor bytes are present and named; no simulation consequence (visual child only). Port must not fabricate geometry | R-STUB (`DEC_U_death_families.md §4.1`) fails **and** a matched frame includes a dying `sto`/`tow` building → visible-frame blocker; or if the port substitutes non-donor art for the stub (forbidden) → donor-fidelity violation under its own id | Scope-bound NB |
| 9 | **D8** score/time-limit absence | F — UI/visual | Port `Data.VICTORY="score"` / `SCORE_LIMIT=5000.0` port extension, absent in donor | `DEC_U_victory_start.md §1.3` `[O-absence]`: `startingsettings.cfg` has no `victory/score/scorelimit/timelimit/peaceful/wincondition` key; only `victorystate:=win` writes are scenario-trigger-gated (`scenario.script:2995-3008`); no donor score threshold/time literal exists; port extension gated by `PORT_EXTENSION_SCORE_VICTORY=false` (`game.gd:7088`). §6 V-score: closed-as-ABSENT, confirm by menu-cfg grep | Donor has nothing to match; with the extension disabled the port cannot diverge from a donor threshold that does not exist | If the owner enables the score/time-limit extension in a matched run → a victory condition absent in donor fires → **simulation blocker**. If a menu-cfg grep finds any skirmish-auto score/time-limit hit, the ABSENT verdict is overturned and the item is re-tagged | Genuinely NB while extension disabled |
| 10 | **D9** team-win policy (label only) | F — UI/visual | The port's team-continuation policy label; **behaviour** is `U-T1…U-T8`, already class A | `DEC_U_endgame_team_deep.md §2.5`: `winnerteam` is a DScript procedure-local (`miscext2.script:3809`), no field/wrapper/VA; donor persists only `victorystate` + `victorystategametime` `[O/D]`; §3 native-field-write test 0 hits. `PORT1TO1_u_register_update.md §3 C4`: two-phase team-win stamp law transcribed verbatim `[O]/[D]`, while `U-T1…U-T8` remain open. `DEC_U_victory_start.md §1.4/§5 item 4`: port `_team_alive/_winner_of_loser` is PORT POLICY, not donor law [SUPERSESSION-FIX: point-in-time/historical — donor-verbatim team-win law later confirmed at `DEC_U_scenario_win.md` §5/§7; D9 remains a label-only item, behaviour U-T1…U-T8 stays [U]; parity UNVERIFIED — NO PARITY CLAIM.] | As a *label*, it changes nothing; the donor stamp law is ported `[O]` and the behavioural unknowns are tracked separately as class A | If the port's team-win behaviour is claimed 1:1 without the U-T1…U-T8 2v2/FFA fixed-seed captures (`DEC_U_endgame_team_deep.md §5 U-E3/U-E5`; `PORT1TO1_owner_decisions.md`) → blocking **under those class-A ids**, not under D9; the label itself is never a donor-fidelity claim | Genuinely NB as a label; behaviour is class A elsewhere |

Reconciliation: 4 items from `PORT1TO1_u_classify.md §2.3` (D5, D6, D7, D12) + 6 from §2.5 (D1, D2, D3, D4, D8, D9) = 10; all ten remain `[U]`, zero CLOSED, zero promoted.

---

## 3. Per-item evidence and reasoning detail

### 3.1 D1 — ghost colour/blink tint `[U]-G`
- **Controls:** the placement-ghost preview overlay. Donor law: `TXLifeColorEffect 'blink'` on the placed object, alpha-only (all callers pass `bUseColor=False`), 3 keys, triangle period 1.3125 s at speed factor 10, red emission pulse enabled only in cannotbuild; `UseColor` rgb arms are dead code (`DEC_U_ghost_blink.md §2/§3`).
- **Donor evidence:** `unit.script:6674-6805` full read `[O]`; `constructiondummy.prop`/`box.actor`/`box.dds` present `[O]`; live object is the building mesh at its own prop scale, not `box.mesh` (strong inference, creation native) `[I]`; key interpolation, `Time[i]` meaning, `GetTimeSpeedFactor` table, `box.dds` pictorial decode all `[U]` (`§8`).
- **Why non-blocking in class-D scope:** transient placement UI, never a sim input; the alpha law is already `[O]`; the owner explicitly ruled the tint non-blocking (`PORT1TO1_owner_decisions.md:338` P-7). The port's green/red `GHOST_OK/GHOST_BAD` and `sin(4t)` pulse are inventions, not donor values — class D does **not** endorse them.
- **Reclassify:** E-GHOST-CAP zero-mismatch fails and the ghost preview is part of the matched-frame set → visible blocker for that frame. Never promote on a port-internal CAP-3 still.

### 3.2 D2 — rally TTL / pennant `[U]-R`
- **Controls:** the visual rally marker only. Donor art `rallypoint.mesh`/`.dds`/`.prop`/`.actor` all present; no TTL key; port procedural pole + `RALLY_TTL=2.0` is a labelled port choice (`DEC_U_entities_art_collision.md §4.1`; `DEC_U_aaf_art_audit.md §2.3/§4`).
- **Why non-blocking:** the rally order itself is set by script event; the marker's lifetime and any pennant motion do not feed unit behaviour, economy or victory.
- **Reclassify:** E-U14 rally capture fails with a visible marker in a matched frame → visible blocker; or if `RALLY_TTL` is wired into order expiry (not donor).

### 3.3 D3 — peace-menu labels `U-M*`
- **Controls:** rendered dropdown strings only. `U-M1` order/labels, `U-M5` reserved-10 absence; `U-M2/U-M3/U-M6` are tag/seconds/expiry behaviour and are **not** D3.
- **Donor evidence:** verbatim labels `gui.txt:553-575`; order/tags `showcustomgame.inc:1126-1150`; port `No` / `%d min` defect documented (`DEC_U_menu_peace.md §2/§3/§7`).
- **Why non-blocking:** UI chrome, no sim field. The 60× minutes→seconds defect (`F-60`) is a *different* still-open item with its own captures (U-M3/U-P2/U-P3) and must not be excused by D3.
- **Reclassify:** U-M1 fails and the expanded lobby is in the matched ROI set → visible blocker.

### 3.4 D4 — market blend edge `U6-T`/`DLT`
- **Controls:** residual float semantics of two recovered economy laws. Law itself is `[O]` (`res.script:337-342` rational push; `res.script:252-268` live `garr_res_dlt` tracker in game mode `dmscript.global:1420`); only ordering/`Lerp`/`ClampInt`/`floor` edge semantics stay `[U]` (`DEC_U_market_tail.md §6`).
- **Why it was classed D:** carried from `DEC_U_final_register.md §0` tail list "market blend edge U6-T/DLT"; the main cost-push and recovery laws are recovered and ported (`DEC_U_market_tail.md §1/§2`), so only edge semantics remained.
- **Honest caveat:** these edges govern market *prices*, i.e. simulation words. The report itself notes the linear form overshoots for large `w` (AI amounts 5000–600000) and the hardcoded `factor=1` is only a quiet-economy special case (`§1.1`, `§2`). Therefore "cannot change simulation" is **not** generally true; class D here is a pure priority call.
- **Reclassify:** U6-T 36-float capture or DLT 600-tick capture fails in a matched run with large-volume trades or an active `dlt` window → market price divergence → sim blocker; owner should re-tag as B/A if market prices are in scope.

### 3.5 D5 — death-smoke TTL
- **Controls:** burning/death smoke looper visual tail. Donor smoke stop is event-driven (transition clear + holder destroy), not a timer (`DEC_U_smoke_burn_ttl.md §3/§6`; `DEC_U_bld_death_time.md §5`); scheduler constants `30/30` mine ×2 are passed raw (`dmscript.global:183-184`, `settagstates.inc:39,46-50`).
- **Why non-blocking:** smoke overlay is visual; the destroy chain is a separate scheduler whose time base is its own `[U]` (E-U14-ttl), not settled by D5.
- **Reclassify:** E-U14-burn fails with the death window in a matched frame → visible blocker; scheduler time-base divergence or wiring the `30`/`0.9375 s` value into a `life`/TTL → sim blocker under a distinct `[U]`.

### 3.6 D6 — PFX `PixelRatio`/`Interval` `[U]-F`
- **Controls:** FX quad world size and frame-to-seconds stepping. `Interval×FrameRate=1000` and the TTL arithmetic are `[O]/[D]`; `PixelRatio→metres` divisor, alpha curve, native stepping rule and pool timing are `[U]` with zero-mismatch captures E-U3-time/size/curve/pool (`DEC_U_pfx_scale.md §1/§2/§8`).
- **Why non-blocking:** no recovered sim field is driven by FX scale/timing; the FX seed attribution (U7) is separately tracked.
- **Reclassify:** any E-U3 capture fails with FX in a matched frame → visible blocker; U7 proven to share the sim stream with divergence → sim blocker under U7.

### 3.7 D7 — `*a` child meshes
- **Controls:** building scaffold/debris attach children. Donor art is present for all 12 mapped families and the mesh-selection law is fully readable (`DEC_U_death_families.md §3`/`§2.2`); port converts `mil` only.
- **Why non-blocking:** static conversion coverage, not a value unknown; no sim field depends on child-mesh presence.
- **Reclassify:** missing child mesh in a matched birth/death-stage frame → visible blocker; if wired into collision/occupancy → separate sim item.

### 3.8 D12 — 660 B `eursto`/`eurtow` death-attach stubs
- **Controls:** degenerate death-attach children for two EUR families. Donor stubs are byte-present and bound; renderer show/skip/cull is `[U]-STUB` with R-STUB capture (`DEC_U_death_families.md §4.1`).
- **Why non-blocking:** visual-only, donor bytes known; port must convert as-is.
- **Reclassify:** R-STUB fails with a dying `sto`/`tow` in a matched frame → visible blocker; substituting non-donor geometry is a donor-fidelity violation under its own id.

### 3.9 D8 — score/time-limit absence
- **Controls:** nothing in donor; port score victory is an opt-in extension (`PORT_EXTENSION_SCORE_VICTORY=false`). Donor absence is `[O-absence]` with a confirming menu-cfg grep in V-score (`DEC_U_victory_start.md §1.3/§6`).
- **Why genuinely non-blocking:** no donor value exists to mismatch while the extension is disabled.
- **Reclassify:** owner enables the extension in a matched run → sim blocker; grep finds a skirmish-auto threshold → ABSENT verdict overturned.

### 3.10 D9 — team-win policy (label only)
- **Controls:** a policy label. Donor stamp law is ported verbatim (`PORT1TO1_u_register_update.md §3 C4`); `winnerteam` is local-only with no field/VA (`DEC_U_endgame_team_deep.md §2.5`); behavioural unknowns are U-T1…U-T8 (class A).
- **Why genuinely non-blocking as a label:** no value/behaviour is asserted by the label; the behaviour is tracked elsewhere.
- **Reclassify:** claiming the port's team-continuation behaviour as 1:1 without the U-T1…U-T8 2v2/FFA captures → blocking under those class-A ids.
- [SUPERSESSION-FIX: the "PORT POLICY, not donor law" reading above is point-in-time/historical; donor-verbatim team-win law later confirmed at `DEC_U_scenario_win.md` §5/§7. Label-only item; parity UNVERIFIED — NO PARITY CLAIM.]

---

## 4. Owner attention: where class-D rationale is weakest

Ranked by risk to a 1:1 claim. This is a priority assessment, **not** a re-tag: all ten stay `[U]`.

1. **D4 market blend edge** — can change simulation prices in large-`w` / active-`dlt` cases (`DEC_U_market_tail.md §1/§2/§6`). Recommend owner treat market-price captures as blocking unless explicitly excluded.
2. **D7 `*a` child meshes / D12 660 B stubs** — conversion coverage is open for 11 families; death/birth frames of `sto`/`tow`/other non-`mil` buildings will differ visibly (`DEC_U_death_families.md §0/§4`). Recommend matched-frame set either exclude those contexts or require R-STUB/R-STAGE.
3. **D1 ghost tint / D2 rally marker / D6 PFX** — port currently stands in invented values (green/red tint, pole+pennant, square quads, `LIFE` table) in visible contexts; scope-bound NB only. `PORT1TO1_owner_decisions.md:338` rules ghost non-blocking, but that is an owner priority call, not a donor-fidelity finding.
4. **D3 peace-menu labels** — visible in lobby ROI; the related 60× defect is a *separate* blocking-worthy item if peace expiry is in scope.
5. **D5 death-smoke TTL** — visual tail is event-driven, but the distinct scheduler time-base `[U]` must not be absorbed into D5.
6. **D8 / D9** — genuinely non-blocking under their stated conditions (extension disabled; label only).

---

## 5. What this report does not do

- No item is marked CLOSED; no `[U]` is promoted to `[D]`/`[O]`; no port value is wired or retuned.
- No approximation is adopted. The port approximations named above (tint, `RALLY_TTL`, FX quads/`LIFE`, port extension score, team policy, linear-market remnants where still present) remain labelled and unendorsed.
- No donor binary executed, no GPU/GL trace, no Godot process, no gate, harness, replay, paired-save, port capture or donor A/B frame produced or compared by this worker. All donor facts are `[O]`/`[D]`/`[U]` carried from the cited read-only reports against pin `t_87f0f3c130b0`.
- No reclassification is performed by this worker; §2/§3 name the *conditions* under which the owner/COORD could reclassify.

---

## 6. Verdict and claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | `PORT1TO1_u_classify.md` assigned exactly ten class-D items (4 E, 6 F); all ten enumerated here, none CLOSED, none promoted. | [D] `PORT1TO1_u_classify.md §2.3/§2.5/§3`, §2 |
| 2 | Class-D status is a priority judgement, not a donor-fidelity claim; it does not assert a matched frame, a zero-mismatch result, or absence of visible/simulation effect. | [D] `PORT1TO1_u_classify.md §1`, `PORT1TO1_owner_decisions.md:351`, §0/§1 |
| 3 | Every class-D item carries donor evidence with cited `path:line`/byte and an explicit per-item reclassification condition. | [D] §2/§3 cites |
| 4 | D4 can change simulation prices in edge cases; D7/D12/D1/D2/D3/D5/D6 can change matched visible frames if their context is in scope — reported honestly, not re-tagged. | [D]/[I] `DEC_U_market_tail.md §1/§2/§6`, `DEC_U_death_families.md §4`, `DEC_U_ghost_blink.md §7`, §4 |
| 5 | `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; six-condition chain 0/6 CLOSED (condition 6 PARTIAL port-internal only); no donor A/B frame, no COORD ruling. | [D] `PORT1TO1_u_register_update.md:200`, `PORT1TO1_u_classify.md §6` |
| 6 | No approximation adopted, no donor executed, no gate/capture/harness run; exactly one repository file written. | [O] scope guard |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the §2 tails); six-condition chain 0/6 CLOSED. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

*End of PORT1TO1_d_cosmetic. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; all ten class-D items remain `[U]` and are not CLOSED; class-D status is a priority judgement, not a donor-fidelity claim; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
