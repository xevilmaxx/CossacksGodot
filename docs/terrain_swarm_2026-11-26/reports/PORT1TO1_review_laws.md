# PORT1TO1 REVIEW-LAWS — read-only completeness review: skirmish laws / save / fog / camera / HUD / minimap (2026-11-27)

- id: PORT1TO1-REVIEW-LAWS-2026-11-27
- worker: REVIEW-LAWS (read-only subagent, full 1:1 Cossacks 3 donor port)
- wave: PORT1TO1 / terrain_swarm_2026-11-26
- date: 2026-11-27
- scope_guard: "READ-ONLY. Donor-derived spec/landed reports re-read as text; port scripts read as text. No code/Godot/git/donor execution. Exactly one file written: this report."
- parity_status: UNVERIFIED
- parity_claim: NONE
- parity_claim_code: NONE
- visual_parity_claim: false
- chain: 0/6
- blocking_unverified: non-empty (P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 + domain tails below)
- verdict: "RESULT IS NOT GOOD while blocking_unverified non-empty; no parity claim."
- reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
- governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md (§1 rows 4–9)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_packet2.md (§1 rows, §2–§4)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_skirmish_logic.md (§1–§14, U1–U20 register)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_skirmish.md (§2.1–§2.11, §3 register M1/C1/T1/T2/D1/Q1/S1/R1/V1/V2/F1/E1/A1/O1/G1, §4 change list)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_skirmish_tables.md (§3 C1 RESOLVED)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_econ_deep.md (economy/upkeep/market law)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b12_peace.md (§1–§7 upgrade/peace law, §8 B12-TIME/COST/GATE/PREEMPT/DISP/LOSS/PEACE)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_capture_veto_deep.md + DEC_U_capture_state.md + DEC_U_capture_state2.md + DEC_U_capture_flush.md (§2.1/§4 capture head)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_stamp.md + DEC_U_endgame_fow.md + DEC_U_endgame_team_deep.md (§§2–4 team-win loop, §6 U-E1…U-E8/U-N1/U-C1)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b11_ai.md (§1 split/cadence, §6 U-B11-1…U-B11-5) + DEC_U_b10_skirmish_tables.md + DEC_U_ai_thresholds.md + DEC_U_ai_activation.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_deep.md (§§1–2 R1a…R1h) + DEC_U_save_trg_deep.md (E-T1) + DEC_U_save_float.md + DEC_U_save_bits.md + DEC_U_save_tobj.md + DEC_U_save_contract.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_audio_rng.md + DEC_U_rng_ledger (G1) + DEC_U_genseed_deep.md (T-SEED tail, not G1)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b14_fow_native.md + DEC_U_endgame_fow.md + DEC_U_fow_tint.md (FOW anchors/tint)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_camera_projection.md (§§1–5 V1-SENSOR/V2-PROJ/V2-BOX/V2-MINI) + DEC_U_cam_derive.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_selection.md + DEC_U_select_deep.md (§§2–4 U1–U5)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md + PORT1TO1_owner_brief2.md (owner brief coverage baseline)

## 0. Method and reading rule

Each element below is labelled exactly one of: IMPLEMENTED (port path + label cites donor law), PARTIAL (port path cites half the law; missing half named with spec report id), or ABSENT ("no file found" for that piece). Every finding carries an exact path or report id. "Prioritise anything NOT already covered by the final brief or owner packet" is honoured in §10: items already in `PORT1TO1_p0_final_status.md` / `PORT1TO1_owner_packet2.md` are marked [ALREADY-COVERED] and deduplicated; §10 lists only the delta.

## 1. Famine / rebellion law (DEC_U_skirmish.md §2.1; DEC_U_econ_deep.md upkeep engine)

- PARTIAL — `variant3d/scripts/game.gd:529` `"famine_t": 0.0, "famine": false, "rebellion": false` + `game.gd:6127-6176` `_tick_upkeep_for_player` (bfamine/brebellion set/clear shape per `player.script:294-321` cited in comments at `game.gd:6143-6154`).
- Missing half: the per-tick death roll `RandomInt<50/12/5` (`nothing.inc:482`, `misc.script:493-498`, thresholds `50/32768 hard/veryhard+LAN, 12/32768 normal, 5/32768 easy`) and rebellion flip `(diff>1 and RandomInt<6000)/(diff=0 and RandomInt<100)/(diff=1 and RandomInt<200)` (`nothing.inc:487-497`, mercenary-only gate) are NOT wired as rolls; port keeps timer accumulators `famine_t`/`gold_famine_t` (`game.gd:6154-6176`) which DEC_U_skirmish.md §2.1 orders deleted. No grace/drain value is donor. [ALREADY-COVERED by final-status row 6 context + DEC_U_skirmish §4 items 2/12.]
- No new delta beyond the known roll-vs-timer replacement.

## 2. Market dynamics (DEC_U_skirmish.md §2.2; DEC_U_b12_peace.md §6 boundary; DEC_U_d4_floats.md U6-T/DLT)

- PARTIAL — `variant3d/scripts/game.gd:5130-5230` `trade()` implements `buyamount=floor(sellamount*sellcost/buycost)` (`game.gd:5155`), per-res buy/sell table reads, cost-push weight `buyamount*MARKET_EXP` / `sellamt*MARKET_EXP` (`game.gd:5169-5175`, cites `res.script:337-342`), exponential recovery `dt=deltatime*0.025*Max(1,dlt*0.01)` (`game.gd:5223`, cites `res.script:291-308`); `game.gd:541-546` `garr_res_dlt/garr_res_trg` init 0 landed.
- Missing half: per-res six-column tables (food sell ≈15.20/min ×0.7/max ×1.3; stone sell ≈20.90/min ×0.75/max ×1.25; gold/wood/iron/coal buy/sell triples in `res.script:180-309`), `buyexp=sellexp=0.00002` / `buytime/selltime=0.0032` (`dmscript.global:810-811`), `_res_CalcDeltaResources` project-mode gate (`res.script:252-268`), and market-dip modes 0–4 (`dmscript.global:1077-1081`, effects `player.script:2741-2763`) have no port branch; single `Data.MARKET_EXP`/`Data.MARKET_RATE` constants remain structural substitutes. Float/round/`Lerp` semantics stay [U] per `DEC_U_d4_floats.md` (U6-T/DLT). [ALREADY-COVERED by final-status §2 U-split + DEC_U_skirmish §4 item 3.]

## 3. Capture predicate (DEC_U_skirmish.md §2.3; DEC_U_capture_veto_deep.md; DEC_U_capture_state.md §§1-2; DEC_U_capture_flush.md)

- PARTIAL — `variant3d/scripts/game.gd:4263-4284` `_building_capture_allowed` / `_capture_unit_allowed` (mode semantics `onlyartillery`/peasant-vs-soldier shape, cites `building.inc`/`nothing.inc:311-324`, `unit.script:461-470`) + `game.gd:8594-8602` capture-due gate with 100-frame lock shape; `variant3d/scripts/ai.gd:1293-1294` `TimeCheckCapture 1.875 / Art 0.475` (`dmscript.global:1479-1480`) landed.
- Missing half: cadence `lasttimecheckcapture+gametimewithrnd` + jitter init (`miscext2.script:2757`), scangrid `floor(captureradius/scangrid_size)+1` with `214/160/426 px` radii (`dmscript.global:208`), protector-count ANY-veto + AI-artillery majority table (C1 RESOLVED per `DEC_U_skirmish_tables.md` §3 / `DEC_U_capture_state.md` §§1-2; supersedes DEC_U_skirmish §2.3 tail), post-capture NO-cooldown (retire `capture_t` to dormant v5 key), and non-peasant + blockshot ⇒ 100-frame lock (`miscext.script:1036-1040`) wiring. [ALREADY-COVERED by DEC_U_skirmish §4 / capture-state reports; final brief carries C1 tail.]

## 4. Gold-fire-stop (DEC_U_skirmish.md §2.4)

- IMPLEMENTED — `variant3d/scripts/game.gd:5741-5742` region (`_GOLD_FIRE_STOP` threshold/delay wired as frames→s `/32`) cites `unit.script:8185-8209`; threshold 4 + 100-frame lock are exact donor literals. Keep + cite only.
- No delta. [ALREADY-COVERED.]

## 5. Defeat / liveness + peacetime (DEC_U_skirmish.md §2.5; DEC_U_b12_peace.md §7; DEC_U_endgame_team_deep.md §§3-4; DEC_U_endgame_stamp.md)

- PARTIAL — `variant3d/scripts/game.gd:8992-9029` `_check_victory` (OR-liveness + `Data.PEACE_TIME` guard at `game.gd:9022`, score behind `Data.PORT_EXTENSION_SCORE_VICTORY` at `game.gd:9027-9029`); `game.gd:8811-8973` `_misc_check_end_game` / defeat / surrender / `_check_victory` position (post-slice, `nothing.inc:646` analogue) matches ENDGAME-TEAM-DEEP §5 items 1–3 (every-survivor loop, unconditional-overwrite shape, no scenario skip gate).
- Missing half: `bexists=(farmused>0)` + peasant-fallback + center-fallback (`progress.inc:60-148`), `bbattle` exempt, first-transition `victorystate=lose + GetGameTime` + `_misc_KillPlayerUnits` + `_misc_LanServerSendResults`, tick-fragment order exists→income→consume→holdmode (`37.5 s`)→disband→ProgressAI, full peace chain (enum `dmscript.global:1055-1066`, seconds fn `misc.script:4262-4281` ×60, lobby `showcustomgame.inc:890-1150`, wire `miscext2.script:2375/2635`, init `dogenerate.inc:2054-2065`, expiry `progress.inc:658-695` strict-`>`), and score-limit deletion (no donor counterpart). Port `VICTORY`/`SCORE_LIMIT=5000`/`PEACE_TIME` defaults remain PORT EXTENSION. [ALREADY-COVERED by final-status row 6 context + owner-packet2 §1 row 6.]

## 6. Morale absence / disband / runaway (DEC_U_skirmish.md §2.6; DFORM-01)

- PARTIAL — absence correctly held: no numeric morale wired in sim path beyond labelled constants; `variant3d/scripts/data.gd:139-143` self-labels MORALE block as invention (ordered deleted per DEC_U_skirmish §4 item 2).
- Missing half: disband-fraction literal (`*0.25`, `dmscript.global:156`/`progress.inc:5-35`/`squad.script:98-107`) not re-read (M1), runaway move-mode wiring (`gc_obj_move_mode_runaway`, `miscext.script:628,1225,1258,1274`; `runawaydelay=1.3/runawaydist=3.5`, `dmscript.global:198-199`) not wired. [ALREADY-COVERED as M1.]

## 7. Damage/protection matrix (DEC_U_skirmish.md §2.7)

- PARTIAL — `variant3d/scripts/game.gd:7555-7735` `_apply_hit` + weapon-row damage/radius shape present with px→m conversion.
- Missing half: full per-sid row audit (`weapon.script:39-62,314-329`; `unit.script:510-517` + 6-kind `protection[6]` rows e.g. `:739/:762`), and the damage−protection application function + tower/wall kind-gate (T2) not located. [ALREADY-COVERED as T1/T2.]

## 8. Starts (DEC_U_skirmish.md §2.8; X09)

- PARTIAL — `variant3d/scripts/game.gd:1724-1930` start provisioning + `_mark_mine_mask` exists; `variant3d/scripts/data.gd:278-306` NATIONS/NATION_UNITS present.
- Missing half: `startingsettings.cfg:87-720+` six-resource blocks + `legends` peasant rows per `startid` (only foods transcribed: startid 1→1000, 2→20000, 3→20000), `addresources` ×6 + `allowedcountries` first-match + two-insertion quirk (`dogenerate.inc:230-300`), `MAX_PLAYERS=12` vs donor `gc_MaxNonSpectatorsCount=8` scoping, `FillOwnerMap` BFS + pre/post-shuffle quirk. `data.gd:START_PEASANTS=8` stays fallback-tagged. [ALREADY-COVERED as S1.]

## 9. Camera numbers (DEC_U_skirmish.md §2.9; DEC_U_camera_projection.md §§1–2; DEC_U_cam_derive.md)

- IMPLEMENTED (pins) — `variant3d/scripts/camera3d.gd:58-67` `DONOR_HEIGHT_MAX/MIN=58/20`, `DONOR_FOCAL=400`, `DONOR_PITCH_DEG=-32`, `DONOR_DYNFOG_*` + `DEPTH=False` cite `camera.cfg:1-65`; `variant3d/scripts/config.gd:72-76,109-121` mirror.
- PARTIAL (values) — `variant3d/scripts/camera3d.gd:109-113` `FOV_DEG_ASSUMED=17.27`, `NEAR_M=0.1`, `FAR_M=4096` correctly tagged PORT APPROXIMATION / UNVERIFIED with V1-SENSOR pointer (`camera3d.gd:72-105`); sensor width (216/36/121.4 all rejected as donor fact), near/far/aspect, pitch-order/`HeightTarget` handling stay [U] V1-SENSOR/V2-PROJ(-NF/-ASPECT). `variant3d/scripts/camera.gd:10-20,92-96` 2D mirror keeps pins only. [ALREADY-COVERED by final-status row 9 + owner-packet2 §1 row 9.]

## 10. DELTA — items NOT already covered by the final brief or owner packet (priority section)

The final brief (`PORT1TO1_p0_final_status.md` §1 rows + §2 tails) and owner packet (`PORT1TO1_owner_packet2.md` §1 nine rows + §2–§4) already carry: U12, U4*, U1/U3/U5/U6, F-GRID a–e/persist/OCC/tint, O1/D1–D3, B1–B4/C1/C2/W/S/A/R, R1a–g/E-T1, G1, E-U13/V1/V2. The following are in the landed laws reports but have NO dedicated row, packet, or experiment in either governing document; each is therefore named here with exact path/report id. Nothing below is promoted, wired, or parity-claimed.

1. PARTIAL — Upgrade time/cost/gate/preempt/dispatch/loss/cadence law: `DEC_U_b12_peace.md` §§1–5 maps the full verbatim law (`country.script:619-636` frames→`×0.03125`; pack `time=500`; six overwrites `:1173-1564`; AI surcharge `unit.script:5774-5778`; charge `:5792-5806`; cancel `:5837-5890`; gate `:6055-6074`; preempt `:4304-4328`; divisor `miscext.script:65-106`; cadence `building.inc/nothing.inc:128-136,438-492`). Port: "no file found" for any `country.upgrade[].time` per-row seconds, six-price charge-once, `inprogress`/`bindividual` gate, slot-0 preempt, or `delta=deltatime/upgTime` divisor — no `upgrade`-time/cost path exists in `variant3d/scripts/game.gd` or `variant3d/scripts/data.gd` (grep `upgrade.*time|country.*upgrade|performupgrade` returns only spec comments, no sim path). Status: ABSENT from port; law PRESENT in spec but with no P0 row, no owner-packet experiment, no §8 battery adoption. Experiment: `DEC_U_b12_peace.md` §8 B12-TIME/COST/GATE/PREEMPT/DISP/LOSS (fixed-seed Nothing-tick progress trace, 3-run zero-mismatch). Priority: highest delta — a complete class-A sim law with zero port surface and zero owner-packet slot.
2. PARTIAL — Peace lobby→sim chain values: `DEC_U_b12_peace.md` §7 maps enum/seconds/lobby/wire/init/expiry verbatim, but `variant3d/scripts/game.gd:9022` `Data.PEACE_TIME` is a single float with no enum-index, no `×60` seconds fn, no selectable-set `{0,1,11,2,3,4,5,6,7,8,9}`, no strict-`>` expiry with `ptborder` destroy + `WriteFreeList`/`WritePeaceTime` + minimap refresh. Status: port holds only the guard shape; the §8 B12-PEACE battery (tag dump `0,1,11,2…`; seconds `{600,900,2700,14400}`; `gbool_peacemode` false iff index 0; expiry boundary) is NOT in the owner packet. Priority: high — peace is currently folded into victory row 6 but its exact chain has no standalone capture.
3. PARTIAL — Team-win scope/stamp precedence (U-E1…U-E8, U-N1, U-C1): `DEC_U_endgame_team_deep.md` §§3–4/§6 proves every-survivor loop (`miscext2.script:3810-3818`), `winnerteam` local-only (§2.5, no port field), disjoint CheckEndGame/peacetime/scenario write sets (§4.3), and nine fixed-seed 2v2/FFA batteries (U-E1 same-frame `win_tick>=lose_tick`; U-E3 shared-team same-tick; U-E4 leaver/`lose→win` flip; U-E6 independence; U-C1 capture-no-stamp). Port `game.gd:8811-8973` matches the loop shape but the nine batteries are NOT in the owner packet (packet row 6 covers only generic victory). Priority: medium-high — the stamp-precedence law (W5 `<>win` skip vs W8/W9/W11 unconditional overwrite, `==0.0` time gate) has no dedicated capture.
4. PARTIAL — AI split/cadence + resbalance/officer/squad timing (U-B11-1…U-B11-5): `DEC_U_b11_ai.md` §§1–4 maps `Progress→ProgressAI→EconomicAI+WarAI` dispatch (`progressai.inc:6-14`), think cadence `2.4 s` (`dmscript.global:1486`) + stagger `id*0.25` + anti-collision (`squad.script:756-785`), resbalance mine bands `30/60/85` (`dmscript.global:503-506`), `OfficerWaitTime=20` definition with zero consumers, Bitva `8 s` / art `3 s` / sail `5 s` / holdmode ramp / seed-wheat gates. Port `variant3d/scripts/ai.gd` + `game.gd:475-485` `_TICK_*` constants carry the cadence labels but the five §6 batteries (2.4 s + stagger growth events; reqlevel-vs-upglevel per band; officer+36 sandbox; battle-timing sandbox; 37-site dispatch coverage) are NOT in the owner packet. Priority: medium — AI timing is the largest un-captured cadence after tick O1.
5. PARTIAL — Save outer-container/trailer/checksum + E-T1 routing: `DEC_U_save_deep.md` §§1–3 proves native-layer absence (F1–F24 zero-hits with evidence ids; `WriteFile` edge terminates at STD_ERROR reporter `sub_4051d8`), leaving R1a/R1b/R1c/R1d/R1f/R1g/R1h each with an owner-only paired-save battery. Port `variant3d/scripts/game.gd:9344-9455` `serialize()`/`deserialize()` is a v4/v5 PORT EXTENSION dict (base64 blobs) that does NOT serialize `tileblock`/`mine_mask`/`pattern_stamps`/`nav_version`/RNG+gen_rng states/projectiles/corpses/cooldowns/acq (save-gap already noted in skirmish-logic §10) and wires no E-T1 uid-vs-handle resolution (`DEC_U_save_trg_deep.md` §§1–4: in-memory `orders[i].info.trg` is a runtime handle; `ObjWriter` nested loop commented out `:807-823,:860-862`). The S5 single-field-divergence battery (R1a word `5C 00 00 00` prediction; R1b `00 00 80 3F`/`01`; R1d adjacent-word delta; R1g trailer bit-compare) exists only as a packet row, but the E-T1 trg-routing sub-question and R1h profile-store identity have no packet sub-slot. Priority: medium — fold E-T1/R1h explicitly into the S5 run sheet.
6. ABSENT — "no file found" for upgrade-queue build cap/batch/multiplier donor audit (Q1): `variant3d/scripts/game.gd:5455-5566` queue + `variant3d/scripts/hud.gd:968-981` train-batch UI exist, but no `player.script` producer cost-time/cap audit backs `BUILD_QUEUE_LIMIT=10`/`MAX_BUILDERS_SENT=8`/batch 5/100/endless. `DEC_U_skirmish.md` §3-Q1 names the exact read; neither governing document gives Q1 a battery. Priority: low-medium.
7. ABSENT — "no file found" for delivery-radius per-site split (E1): port `DELIVERY_RADIUS_M=3` is single-valued; donor splits global 3 (`dmscript.global:210`) vs carry-drop `resourceDropRadiusSqr=0.5` (`unit.script:9704-9705`) vs fisher `4*4` (`unit.script:12032-12033`). `DEC_U_skirmish.md` §2.11-E1 names the three call sites; no governing battery covers them. Priority: low (mechanical text branch, no capture needed beyond the three cited lines).
8. ABSENT — "no file found" for `orders[].info.trg` width/placement (E-T1b/T1c): beyond the uid-vs-handle question, the TObj/TProj tail widths and nested-transform placement (`DEC_U_save_deep.md` §3 R1f; `DEC_U_save_tobj.md`) have no port field and no packet sub-slot. Priority: low — stays inside S5 scope once named.

## 11. Fog / FOW (P0-3 tail; DEC_U_b14_fow_native.md; DEC_U_endgame_fow.md; DEC_U_fow_tint.md)

- IMPLEMENTED (law labels + telemetry, no rule) — `variant3d/scripts/world3d_fog.gd:39-106` pins vision law `floor(20+4*vision)` / `floor(dx)` + `>0` veto (`unit.script:11563-11614`), tag-109 fogreveal (`misc.script:5883-5944`), FOW viewer set/hook (`player.script:451-478`, `SetFOWDovFunc('_unit_GetVision')`), LOS veto `(not GetFOWEnable) or GetFOWLOSData>0`, engine knobs K1–K9 + `GetFOWLOSData @0x6a8412` + type names `TLOSInfo/TLOSData/TFOWLerpInfo/TFOWLerpData/TOSWFOWRender/XFOWRender/FOWRenderT`, DynFog-visual-only separation; `variant3d/scripts/world.gd:2186-2256` `_update_fog` + `fog_explored/fog_vis/fog_counts` arrays explicitly labelled port inventions; `variant3d/scripts/hud.gd:7-145` minimap-tail layer pins panel/mapping/refresh law and tags ×0.25 dim + terrain tint as PORT APPROXIMATION.
- PARTIAL — cell size (cells/tile, metres/cell), multi-viewer combine (max/OR/threshold/per-team), LOS occlusion (disc vs hill/forest/wall/slope), explored-vs-visible persistence (per-player vs recomputed), `GetFOWLOSData` sampling (point vs cell-area, domain 0/1 vs count), panel RGBA tint: all stay [U] F1-GRID-a…e / PERSIST-a…e / OCC-a…d / P6 per final-status row 4. [ALREADY-COVERED by owner-packet2 §1 row 4 (S2 transects + LOS dumps).]
- No new delta; FOW knobs K1–K9 engine-default-only status (`world3d_fog.gd:73-86`, zero shipped writers) is already recorded and needs no new capture.

## 12. HUD / minimap (DEC_U_camera_projection.md §§4–5; DEC_U_minimap_tail via hud.gd header)

- IMPLEMENTED — `variant3d/scripts/hud.gd:345-368` minimap 240² bottom-right inset −8 (`initminimap.inc:5-7,17,33`); `hud.gd:7-145` header pins sprite-atlas law (`misc.script:1137-1172` visible→`pl2x2/pl3x3.<color>`/`sel`; `gui.script:3472` per-pass refresh; `player.script:769` ownership path), highlight order (winner-colour recursive `unit.script:3860` → queue `miscext.script:920` → `gui.script:3383-3472`), alarm-primitive separation (`lens.0` ≠ viewport box), CriticalColor-Blue exclusion.
- PARTIAL — `variant3d/scripts/hud.gd:187-249` minimap image/box pipeline (`minimap_tex/img/base/view_img`, `_mm_box_cam_fov` change gate, `hud3d_adapter.get_minimap_box()` source) renders a box, but world→minimap affine (scale/offset, non-square maps, DPI factor `initminimap.inc:16`) and frustum `lens` quad projection stay [U] V2-MINI-SCALE/QUAD; `variant3d/scripts/input_controller.gd:126-162` marquee painter stays PORT APPROXIMATION (yellow RGBA(1,1,0,1) grounded per `selection.cfg:3-14`; inside-test centroid-in + four-corner AABB `input_controller.gd:693-742` awaits V2-BOX). Minimap click/drag jump helper law (`control.script:585-612`, `ArcTan @0x60a8c6`) is cited in `camera3d.gd:85-94` but not wired as a jump path. [ALREADY-COVERED by final-status row 9 + owner-packet2 §1 row 9 (S4 ≥6 markers, frustum 0 px).]

## 13. Selection / projection (DEC_U_select_deep.md §§2–4; DEC_U_selection.md; DEC_U_camera_projection.md §§3–4)

- IMPLEMENTED (static edges, no rule) — `variant3d/scripts/input_controller.gd:9-56` pins pick law (minimap-under-mouse early-out, `MouseRay→SortList`, triple gate Playable∧Visible∧CollisionDetection, priority table `my=1/wood=2/food=3/stone=4/goinside=5/build=6/enemy=7`, FOW veto `LOS>0`, `Begin→Start(spmRunTime)→Picked→Cancel-once`); `input_controller.gd:35-71` dual-model (`_rect_ground_anchor` press-frozen + `_sel_ground_start` first-move) faithfully mirrors `onmousemove.inc:141-152`; epsilon `0.005/0.25` (`input_controller.gd:290-298,1139-1154`); `spmAdd` Shift-union (`input_controller.gd:717-732`); `variant3d/scripts/picking3d.gd` 3D candidate source (labelled approximation).
- PARTIAL — pick-distance units, `SortRayCastList` order, engine AABB, FOW veto reachability, sensor→FOV, near/far/aspect, drag geometric anchor (press vs first-move), marquee inside-test, minimap affine + frustum quad: all [U] E-U13 / V1-SENSOR / V2-PROJ(-NF/-ASPECT/-DRAG) / V2-BOX / V2-MINI per final-status row 9. `gluProject @0x4afeec` (2 static callers `0x5811ec/0x582914`), `gluPickMatrix @0x907b80` (0 static users), `gluUnProject @0x907b74` (0 users) per `DEC_U_select_deep.md` §§2–3 prove the call path exists, not the values. [ALREADY-COVERED by owner-packet2 §1 row 9 (S4 fixed-rig 0 px / 0-mismatch probes).]

## 14. RNG / tick (DEC_U_audio_rng.md; RNG-LEDGER G1; DEC_U_genseed_deep.md; TICK-DEEP)

- PARTIAL — `variant3d/scripts/game.gd:197-244` `DonorRandomExt` (LCG `s*64525+1013904223`, `RandomExt=f32(s/2^32)`, key0 discarded, `GetRandom(n)=floor(RandomExt*n)`) + `sim_rng` single S stream; `game.gd:392-398` `_reseed_stage` is now identity (`gen_rng.seed=RANDOM_SEED`, stage ignored; `sim_rng` deliberately not reseeded per-stage); `game.gd:475-485` tick-cadence constants (`0.25/0.3/2.4/60.0/3.0`) + gate primitive `_check_progress_lasttime_and_increase`; `game.gd:3151-3164` order/progresstick draw sites (`uniqrnd:=RandomExt`, `progresstick:=floor(RandomExt*32)`); `variant3d/scripts/ai.gd:1250-1450` sampler draws `RandomExt<v/32768` on stream S with per-arm draw counts.
- Missing half: stream split (sim/mapgen/art/test), `floor(RandomExt*n)` wrapper at every sim draw, `brng`/local-`RandomNumber` removal, per-site draw-count ledger (X21 20-vector + S-vs-G attribution), global-vs-player-vs-unit-vs-projectile interleave + mod-cohort alignment + section micro-order (`plInd` rotation, per-player firing rate). All stay [U] G1/O1 per final-status rows 5/8. [ALREADY-COVERED by owner-packet2 §1 rows 5/8 (S6 hash harness; S7 R20/L20/C300/U50/F1M/K0/A600 vs X21 oracle).]

## 15. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Famine/rebellion timers present, rolls absent; market floor+push+recovery present, per-res tables/dip modes absent; capture mode shape present, cadence/radii/majority/cooldown absent; gold-fire-stop exact; defeat/peace guard shape present, bexists/chain/expiry absent; morale absence held, disband/runaway wiring absent; damage shape present, rows/application absent; starts present, X09 tables absent | [D] §§1–8 with exact port paths + DEC_U_skirmish.md file:lines |
| 2 | Camera 58/−32/400 + DynFog pins IMPLEMENTED; FOV 17.27/near/far/aspect, drag anchor, marquee inside-test, minimap affine/frustum stay [U] | [D] §9 + `camera3d.gd:58-113`, `DEC_U_camera_projection.md` §§1–5 |
| 3 | FOW vision/hook/knob labels + HUD panel/mapping/refresh law IMPLEMENTED as labels; grid/combine/occlusion/persistence/sampling/tint stay [U] | [D] §11 + `world3d_fog.gd:39-106`, `hud.gd:7-145` |
| 4 | Selection pick-law labels + dual-anchor + epsilon + spmRunTime shims IMPLEMENTED as labels; ray/projection/inside-test/minimap-scale stay [U] | [D] §13 + `input_controller.gd:9-162`, `DEC_U_select_deep.md` §§2–4 |
| 5 | RNG LCG + identity reseed + tick cadences + sampler draws PARTIAL; stream split/draw ledger/interleave stay [U] | [D] §14 + `game.gd:197-244,392-398,475-485`, `ai.gd:1250-1450` |
| 6 | Save v4/v5 PORT EXTENSION present; R1a–g/E-T1/R1h batteries open; upgrade/peace-team/AI/Q1/E1 deltas in §10 are NOT in the final brief or owner packet | [D] §10 (delta) vs `PORT1TO1_p0_final_status.md` §1 + `PORT1TO1_owner_packet2.md` §1 |
| 7 | No parity claimed; no donor executed; no value wired; exactly one file written | [O] scope guard |

## 16. Verdict

`port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; six-condition chain 0/6 CLOSED; `blocking_unverified` non-empty (P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 + §10 B12/peace-team/AI/Q1/E1 tails). **RESULT IS NOT GOOD.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made. If nothing else is taken from this review, take §10 items 1–2: the upgrade-law and peace-chain batteries are the two complete donor laws in this domain with no owner-packet slot.

*End of PORT1TO1_review_laws. Read-only; exactly one repository file written; no code/Godot/git/donor execution; parity UNVERIFIED; RESULT IS NOT GOOD while blocking_unverified is non-empty.*
