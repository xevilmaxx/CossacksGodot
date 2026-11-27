# DEC_U_final_register — definitive remaining-[U] register (READ-ONLY audit)

Date: 2026-11-26 · Worker: REGISTER-U · Scope: full 1:1 Cossacks 3 donor port
Rule: donor read-only (`C:\Games\Cossacks 3`), never execute donor binaries. No code/Godot/git edits by this worker. Exactly one file written: this report.

Corpus scanned: `docs/terrain_swarm_2026-11-26/reports/DEC_U_*.md` (45 files, [U]-hit counts verified per file 3–39) + `docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md` (tasks 1–71, statuses DONE/DOING/TODO/BLOCKED).
Prior context: ~70 decomp reports + implementation lanes landed. Owner rule: every remaining `[U]` is a decomp/runtime blocker, never permission to invent.

**Parity status: UNVERIFIED. No donor A/B frame exists. No parity claim is made anywhere in this register. No approximation is authorised by this register.**

Labels: `[O]` observed donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED with named settling experiment · `STATIC` = closable by text/bytes re-read, no donor execution · `RUNTIME` = requires owner-authorised donor GPU/runtime session (forbidden to workers; stays open until owner runs it).

---

## 0. Minimum blocking set (P0) vs cosmetic tails

P0 = blocks a donor-faithful visible or simulation result. Everything else = tail (ship only after P0, never as substitute).

| # | P0 blocker | Why load-bearing | Report |
|---|---|---|---|
| P0-1 | WATER U12 (reflection provenance/unit/matrix/viewport) | Port hard-fails water draw without it (`water3d.gd:520-527`, `bind_reflection_map` null-refusal); largest visual blocker | `DEC_U_water_runtime.md`, `DEC_U_water_fbo.md`, `DEC_U_water_capture.md`, `DEC_U_water_mesh_uv.md` |
| P0-2 | WATER U1/U3/U5/U6 (shader path, hmap numerics/identity, time writer, UV/winding) | Wrong path/numbers = wrong water pixels or wrong animation phase | same as above |
| P0-3 | FOW GRID a–e (cell size, combine, occlusion, persistence, LOS sampling) | Visibility gates AI, picking, tint vetoes; provisional `1 res = 1 m` driver is not donor | `DEC_U_fow_grid.md`, `DEC_U_fow_persist.md` |
| P0-4 | Native tick interleave O1a/O1b/O1c + DRIVER D1–D3 (plInd rotation/rate/stage order) | `TICK_ORDER v1` is labelled PORT APPROXIMATION; wrong order = deterministic sim divergence | `DEC_U_tick_order.md`, `DEC_U_tick_driver.md` |
| P0-5 | Animation blend B1/B2 + completion C1/C2 + trigger gaps W/S/A/R | No interpolation permitted until bounded; attack↔idle seam, death hold-vs-return, weapon→attack1/2 gating unverified | `DEC_U_blend_op.md`, `DEC_U_aaf_triggers.md` |
| P0-6 | Save container R1a + primitive bytes R1b/R1c + transform R1d + victorystate R1e | Save is PORT EXTENSION, no byte-parity; round-trip determinism only | `DEC_U_save_contract.md`, `DEC_U_save_float.md`, `DEC_U_save_bits.md` |
| P0-7 | RNG ledger G1 (round-Bankers, S vs G streams, per-site draw counts, uniqrnd) | Wrong stream = desync; X21 20-vector oracle exists, attribution open | `DEC_U_rng_ledger.md` |
| P0-8 | Selection E-U13 (distance units, SortRayCastList order, engine AABB, FOW veto) + projection V1-SENSOR/V2-PROJ | Wrong pick = wrong sim input; port `FOV 17.27°`, `cull_disabled`, `nearest-single` are scaffolding | `DEC_U_selection.md`, `DEC_U_camera_projection.md` |

Tails (explicitly NOT blocking): ghost colour/blink `[U]-G`, rally TTL `[U]-R`, minimap scale/tint/frustum V2-MINI, peace-menu labels U-M*, market blend edge U6-T/DLT, death-smoke TTL, PFX PixelRatio/Interval `[U]-F`, tool-attach `[U]-T` cosmetics, `*a` child-mesh cosmetics, score/time-limit absence (closed-absent), team-win policy. Listed in-domain below, never promoted. [SUPERSESSION-FIX: point-in-time/historical "team-win policy" tail label, not current — superseded by `DEC_U_scenario_win.md` §5/§7 (donor-verbatim team law); only mission mapping/stamp residuals stay [U]; tail status unchanged; parity UNVERIFIED — NO PARITY CLAIM.]

---

## 1. Domain W — water / render (GPU-bound; all RUNTIME)

All items require an owner-authorised donor GPU frame / GL trace (RenderDoc/apitrace/Nsight-GL or debugger + GL hooks). Forbidden to workers. Zero-mismatch rule throughout: identical bytes across ≥2 water-visible frames + 1 camera move (level→pitched), same Phase-1 PATH tag; any mismatch or missing dump = stays `[U]`, port keeps hard-fail.

| ID | Exact blocker | Evidence report | Experiment / capture | Termination | Settle class |
|---|---|---|---|---|---|
| W-U1 | Live shader path DEV vs BUILTIN vs LEGACY; runtime `C+0x184`, `[0x8fc6b8]`, `FUN_00855fe8` globals | `DEC_U_water_runtime.md` §4; `DEC_U_water_capture.md` Phase 1; PLAN task 8/9 | Break `FUN_00855b38` + `FUN_00856530`; hook `glShaderSource` (`hmapTex` = DEV, `alphaDepth`/`deepColor` = BUILTIN) | `(PATH, C+0x184, globals, program-hash)` identical 2 draws + camera move | RUNTIME |
| W-U3-NUM | Numeric `hmapMin/Max/W/H` at live frame | `DEC_U_water_runtime.md` §6; `DEC_U_water_mesh_uv.md` §5 | Break `FUN_00854054` bits 7e.10–7f.1; record 4 pushed values + gate `C+0xe0`/`[C+0xe0+8]` | Same 4-tuple, 0 differing bits, 2 frames + move | RUNTIME |
| W-U3-TEX | `hmapTex` GL identity (name/target/provenance) | same | `glActiveTexture(GL_TEXTURE0+C+0xdc)` + `glBindTexture` + `glGetTexLevelParameteriv`; FBO-vs-upload history | Same `(target,name,w,h)`, 0 mismatches, 2 frames | RUNTIME |
| W-U4* | Ctor defaults vs `water.lib` layer values (`C+0x88..+0xc4`, Speed `+0xc4=1.0`) | `DEC_U_water_runtime.md` §5 | Break `FUN_00851bdc`; record `param_2` layer ptr + scalar block | Distinguishes engine-default vs layer path; identical 2 frames | RUNTIME |
| W-U5 | `time` writer of double `C+0xc8`; formula `(float)(dbl[+0xc8]*dbl[+0xc4])` proven, writer not found | `DEC_U_water_runtime.md` §5.3; `DEC_U_water_mesh_uv.md` §6 | Hook `glUniform1f(time)` ≥3 frames over ≥2 s; if animated, HW write-watchpoint on `+0xc8` → writer EIP | Constant-0 (0 samples differ, 10 s window) or single writer, 0 missed frames, formula 0 ULP error | RUNTIME |
| W-U6-UV | Per-vertex dividend behind `MultiTexCoord0/(hmapW,H)-0.5` | `DEC_U_water_mesh_uv.md` §4 | Break vtable `+0x98` from `FUN_00826b30`; dump `MultiTexCoord0` array + `hmapW/H` uniforms; compare vs `gl_TexCoord[1]` | `max\|uv_pred-uv_actual\|==0.0` bit-exact, 4 verts, 2 fields + move | RUNTIME |
| W-U6-WIND | Triangle winding/diagonal/cull | same §4.3 | Same break; dump index array + `GL_CULL_FACE`/`GL_FRONT_FACE` trace | Index sequence 0 mismatches, 2 fields; cull state identical 2 frames | RUNTIME |
| W-U12-A | Reflection provenance: FBO attachment vs framebuffer copy vs static upload | `DEC_U_water_fbo.md` §5/§8; `DEC_U_water_capture.md` Phase 2 | Break reflection-bind gate; `GL_FRAMEBUFFER_BINDING` + FBO/copy/upload call lists; classify name | Unanimous class (a/b/c), 2 frames + move | RUNTIME |
| W-U12-B/C | Reflection size/mips/sampler state + unit `C+0xf8` | same | `glGetTexLevelParameteriv` + filter/wrap + `glUniform1i(reflectionMap)` hook | Captured `(w,h,fmt,filter,wrap,unit)`, 0 mismatches | RUNTIME |
| W-U12-T | Reflection projective matrix (`FUN_004cdd9c(...,0x60,.)`) + viewport/scissor | same | Break `FUN_0085756c` entry/exit; dump 4×4 at caller `+0x60` + viewport/FBO state; level vs pitched | Self-identical per pose, 2 frames each; no `*0.5+0.5` bias invented | RUNTIME |
| W-U12-S/P | `DiffuseWaves2` alias? pbuffer/`wglMakeCurrent` path? | same | Upload-name correlation; `wgl*`/`pbuffer` sweep one frame | Distinct-vs-identical verdict; null pbuffer retires hypothesis | RUNTIME |
| W-R1 | Terrain material floats / light pos+modelview / alpha-state at GL upload (slot→enum maps `[O]`, floats/w/alpha-arith/fog/callList `[U]`) | `DEC_U_renderer_residual.md` §§3–7; `DEC_U_scenecolor_glstate.md`; `DEC_U_alpha_pass_quad.md` (U4 enum `[O]`, converter `[U]`; U6 ENABLED `[O]`; U9 one-list-per-cell `[O]`; U10 0x48→0x50 map `[O]`) | Probes P-MAT/P-LIGHT + U4 upload probe + `glCallList` dispatch count | Zero-mismatch byte dumps; residual tails stay `[U]` | RUNTIME (U4-converter, uploads) / STATIC for enums already closed |

PORT1TO1_PLAN cross-ref: tasks 3 (DOING, `IMPL-WATER-COMPILE` landed, U12 hard-fail retained), 8 (DONE), 9 (DOING), 19 (DONE), 20 (DONE), 50 (DONE plan), 62 (DONE, `17.27°` stays APPROX).

---

## 2. Domain T — terrain / generation (mixed STATIC + RUNTIME)

| ID | Exact blocker | Evidence report | Experiment / capture | Termination | Settle class |
|---|---|---|---|---|---|
| T-SEED | `GenerateMapRandKey` derivation; `randkey0/1` consumers (`generatemap.inc:130-200`); Delphi seeder QPC-else-TickCount, image `0x8f2008=0`, 15 `Random` callers | `DEC_U_gen_seed.md` §2; `DEC_U_placement.md` U-SEED/U-DELPHI | STATIC: re-read derivation call sites; RUNTIME (owner): authorised-trace `0x83272f` dump, key0-only vs key1-varying comparison | STATIC closes consumers; RUNTIME: every byte `state>>>24`, 0 mismatches, restart changes seed | STATIC + RUNTIME |
| T-CALLBACK | `renderer+0x40` default producer `sub_812e34` proven; indirect `+0x0b` index-header copy | `DEC_U_gen_seed.md` §3.3 | Write-break on indirect slot | Copy path identified, 0 mismatches | RUNTIME (owner trace) |
| T-SMOOTH/MINMAX/MOD | `SmoothTerrain(x,-y,False,3)` kernel (native, high VA); `minx/miny` numerics; `probsmall/mid/large/huge` + `640/((W+H)/2)` modifier application | `DEC_U_placement.md` U-S0/U-MM/U-MOD | Byte-proven kernel dump (hook signature); helper out-arg logging; modifier trip-count recompute | Kernel bytes match; `needed=floor(WA·HA·freq)` exact on ≥3 sizes | STATIC (reads) + RUNTIME (kernel dump) |
| T-VER/MDEN/HF/OBJ | `gc_MaxTerrainTypeCount`, `gRecordGeneratorVersion`, `mapsize` enum; `minesdensity` rounds 3/4/5; per-pattern `HeightField*`/`minangle/maxangle` concretes in `pattern.lib Objects[]` | `DEC_U_placement.md` U-VER/U-MDEN/U-HF/U-OBJ; `DEC_U_atlas_layout.md` (per-block 1024² DXT1 `[O]`; 16×8 stays `[U]` fallback) | STATIC: live-settings dump + `country.script`/`pattern.lib` reads; fixed-seed `generate()` diff | Dumped integers select observed branch; X13 vectors 19/19 on `g_mnt_1/g_hil4` | STATIC (mostly) |
| T-G0 | `G=0` zero-density closure | `DEC_U_placement.md` U-G0 | Fixed-seed mask check | `fdens==0` off-starts, 0 mismatches | STATIC |

---

## 3. Domain E — entities / AAF / FX / collision (mixed; motion items are RUNTIME)

| ID | Exact blocker | Evidence report | Experiment / capture | Termination | Settle class |
|---|---|---|---|---|---|
| E-B1 | Blend weight curve `w(t)`; window unit; per-channel application (`6/8` literals/install/bypass sites `[O]`, operator `[U]`) | `DEC_U_blend_op.md` §2; `DEC_U_aaf_triggers.md` §4 | R-B1: `walk 1..20 → idle 64..113` seam, ticks `[-2,+10]`, `(6,8)` vs forced `(0,0)`, joint-track/vertex-hash | Step-response length + per-tick table, byte-identical 3/3 per setting; `(0,0)` = single-tick hard cut | RUNTIME |
| E-B2 | Blend-window frame fetch (which exported frames co-occur) | same §3 | R-B2: same seam, log `GetGameObjectFrameAnimationName/Data` + displayed frame/tick | Sequence byte-identical 3/3; until then port fetches ONE nearest frame (labelled) | RUNTIME |
| E-B3 | `a3/a5/a6`, `CyclesList`, `acoSkipActions` polarity | same §5 | R-B3: sim-path (`a3=False`) vs aix-idle-shaped (`a3=True`) differential | Identical-or-different verdict 3/3; no semantic named either way | RUNTIME |
| E-C1 | `acmPlayOnce` end behaviour (hold last vs snap to idle between evaluations) | `DEC_U_blend_op.md` §5; `DEC_U_aaf_triggers.md` §3 | R-C1: musketeer `attack1 [99,124]`, peasant `death [115,149]`, `t0..t0+span+10` @30 Hz | Hold-vs-return + tick numbers, 0 mismatch 3/3 per sid | RUNTIME |
| E-C2 | Handler timing: opening `Attack` (damage/PFX/sound) vs `AttackEnd` re-attack gate (`onaclanimationreachedattackend.inc:2-14` body `[O]`) | same | R-C2: cannon `attack0/1 [301,337]`; log PFX/damage/sound ticks relative to handler ticks | Effect-to-handler offsets 3/3, or absence logged | RUNTIME |
| E-W/W2/S/A/R | Weapon→`attack1/2` (`iWeapon` vs port `kind==bullet`); `death0/1/2` by weapon; sticky readback T18–T20; `prepare/trans/walkprepare` triggers; `reaction` orphan (no constant, no site) | `DEC_U_aaf_triggers.md` §6 | R-W/W2/S/A/R fixed-camera batteries (grenadier/musketeer/peasant; tag dumps + frame traces) | `attack1 iff iWeapon=1` 3/3; `attack2before→after` on grenade order or logged absence; sticky dwell or 3 clean seams; ≥1 trigger per family or logged absence | RUNTIME |
| E-B4 | Movie `0..5` window applicability to units | `DEC_U_blend_op.md` §6 | R-B4: `_movie_UnitPlayAnimation` bBlend true/false same seam | Differ-or-identical 3/3; until then no `"0,5"` in port | RUNTIME |
| E-ART-G/R/T/B/F/S | Ghost colour/blink; rally TTL/pennant; peasant tool attach (no `peaukr_*.oss` this pass) [SUPERSESSION-FIX: point-in-time/historical claim, not current — superseded by `DEC_U_tool_attach.md` (56 attach `.oss` exist; recursive parent-glob landed); T-A/T-B stay [U]; parity UNVERIFIED — NO PARITY CLAIM.]; building `*a` child meshes (glob-first); PFX `PixelRatio/Interval`→world/time law; FX `Random` seed isolation | `DEC_U_aaf_art_audit.md` §4; `DEC_U_entities_art_collision.md` §§1–4; `DEC_U_pfx_scale.md`; `DEC_U_ghost_blink.md` (3-key triangle alpha `[O]`, tint `[U]`); `DEC_U_smoke_burn_ttl.md`; `DEC_U_death_families.md` | STATIC glob `D:actors/**` + RUNTIME close-up captures per action/PFX spawn | (mesh, parent bone, rigid-vs-animated) / (TTL seconds) / `worldSize=f(PixelRatio,dist)` + `secPerFrame=g(Interval,FrameRate)` with capture ids | STATIC (glob) + RUNTIME (captures); all TAIL except tool-attach law |
| E-COLL | Per-sid radius/mask census (354/369 `[O]`); centred origin + inertia `[O]`; rotation/mirror of footprint `[U]`; LOS engine impl (12-float signature typing, `ctpoEqual/Greater`, AABB inside-test) `[U]`; `SetGameObjectRayCastIntersectEnabled` `[U]` | `DEC_U_collision_full.md`; `DEC_U_entities_art_collision.md` §5 | STATIC census/audit; RUNTIME LOS ray battery + mask-rotation capture | Census cite-or-tag complete; ray rule predicts 2nd rotated transect 0 mismatches | STATIC + RUNTIME |
| E-DMG/FF | Ballistic integration (`TXThrowBehaviour` gravity/speed/landing); victim pick; height-threshold metrology; FF gates (`FriendOnLine`, cannister 4:1, building immunity); `PredictShot` stub (`stand` → no projectile + 1 s penalty, port currently fires = known mismatch); `randomsimulate` Gaussian; `round()` Bankers | `DEC_U_damage_height.md` U1–U8; `DEC_U_ff_predict.md` F4–F7/U1 | Series F1–F7 (flat map, 50–360 shots/cell, fixed seeds); X21 fixture for `round()` | Zero mismatches across FULL series per item; any mismatch = stays `[U]`, gate not wired | RUNTIME (owner shot series) |
| E-WPN/SHIELD | Shield/mount rows in live sim (`yachttur 100`, `battleship 100`, `tow 5`, weakwall `15+80` `[O]` literals, port unwired); upgrade per-value rows (`country.script:2050-2210` open) | `DEC_U_weapon_tail.md` §5 (77/77 + 33/33 CLOSED, shields/mounts `[U]`) | STATIC mechanical read + RUNTIME per-sid damage probe `dealt=max(1,indamage-shield-prot…)` | 0 mismatches built-vs-unbuilt; never copy neighbour sid | STATIC + RUNTIME |
| E-VIS/SEL | Full sid→vision table (140 literal rows `[O]`, expression keys removed); unwritten-building default 0; selection `(1+dist)/prio` shape `[O]`, units/tie/AABB/marquee `[U]` | `DEC_U_vision_audit.md`; `DEC_U_selection.md` | STATIC table landed; RUNTIME E-U13-pick + V2-BOX/V2-DRAG | Predicted winner + membership 0 mismatches incl. exact-tie + FOW-veto probes | STATIC (table) + RUNTIME (predicate) |

---

## 4. Domain S — skirmish / save / RNG / tick (STATIC reads + RUNTIME hashes; save bytes need paired-save runs)

| ID | Exact blocker | Evidence report | Experiment / capture | Termination | Settle class |
|---|---|---|---|---|---|
| S-TICK-O1 | plInd rotation order / per-player firing rate / global-vs-player-vs-unit-vs-projectile interleave / mod-cohort alignment / section micro-order | `DEC_U_tick_order.md` U-O1a–g; `DEC_U_tick_driver.md` U-D1–D9 | Fixed-seed hash harness (headless fixed-dt, canonical JSON state hash per tick/firing, 12 mixed players, 3600 frames, 3 seeds + restarts) | Byte-identical hash sequences, 0 mismatches; single surviving order, losers listed; until then `TICK_ORDER v1` stays PORT APPROXIMATION | RUNTIME (owner/headless; no donor binary) |
| S-TICK-O2–O6 | Bank `floor` edge; capture jitter anchor; `not res` current-value read; `CheckProgress…` float-equality veto reachability; AI Econ-vs-War split (body order stays `[U]`-A1) | same | Fixed-dt sweeps + 200-capturer + shortfall-tick + phase-crafting batteries | 0 mismatches per battery | RUNTIME |
| S-RNG-G1 | `round()` Bankers on binary; S-vs-G stream split; per-site draw counts (musket/archer/cannon/`stand`+2/`random1`+4); `uniqrnd`/frnd order; f32-vs-f64 promotion; signed-`key0` edge; AI/capture/economy attribution | `DEC_U_rng_ledger.md` G1a–g (+G1h generation-owned) | Series R20/L20/C300/U50/F1M/K0/A600 vs X21 20-vector oracle `(0x44A108F9,0x00000001)` | Exact S sequence `3C6FEF6C…A2C21855`; counts exact; G values count-only; 0 mismatches | RUNTIME (owner/headless) |
| S-SAVE-R1 | R1a outer container (`.sav` unknown; `.map` `OSWMap13` wrapper `[O]`); R1b float Single-vs-Double + Boolean `0/1` pattern; R1c string codepage; R1d engine transform placement; R1e `victorystate` int table + `TWall/Cluster/Cell`, `TGrid/ResGrid`, `TInterface`, `TScenario`, `TProj` tails; R1g checksum/trailer | `DEC_U_save_contract.md` §8; `DEC_U_save_float.md` §R1; `DEC_U_save_bits.md` §R1 (Boolean 1 B `[D]`, `.map` envelope `[D]`, TProj order `[O]`) | E-R1a–g paired-save batteries (vary one field, single-word divergence; identical-state re-save bit-compare) | Single-field divergence asserted; re-save byte-identical; until then contract = key-order parity + round-trip determinism, never byte parity; v5 wire unchanged | RUNTIME (owner paired saves) |
| S-SKIRM-T/D/Q/G/A/R/V/F/E/O | Per-sid stat rows; damage/tower-gate; dispersion/height; queue/batch caps; `round()` tails; build order; save framing; FOV/selection/fog/delivery (pointers to S-TICK/S-RNG/S-SAVE/V/F/E/O1 batteries) | `DEC_U_skirmish.md` §3; `DEC_U_skirmish_tables.md` §9; `DEC_U_skirmish_impl_patch.md` §U-register | STATIC mechanical audits (`unit.script` `SetObjBase*`, `weapon.script` `_weapon_AddWeapon`, `player.script` producers, `startingsettings.cfg:183-720+`, `write*.inc/read*.inc` field order) + RUNTIME batteries per pointer | Every row cite-or-tag; zero-fill where donor absent; batch-5/100 deleted if absent; never invent | STATIC (audits) + RUNTIME (batteries) |
| S-AI-A1–A8 | Build-order winner; army-commit; officer-wait/squad timing; target weights; `resbalance` mine levels; `[*]` activation; think-interval + plInd stagger; AI RNG attribution | `DEC_U_ai_thresholds.md` §8 | STATIC `progresseconomicai/warai` continuation reads + RUNTIME fixed-seed 600 s AI-vs-idle batteries | Choice/tick/composition byte-identical 3 seeds, 0 mismatches; until then port AI stays DONOR-TEXT-DRIVEN | STATIC + RUNTIME |
| S-MKT/Q2/VIC/PEACE | Rational cost-push/delivery sites/resonlife (port wrong-shape sites noted); upgrade time/cost/gate/preempt/dispatch/loss/cadence per-row literals; defeat/score-absent/peace-table/starts/queue/camera-literal; peace index↔seconds/seed boundary | `DEC_U_market_tail.md`; `DEC_U_upgrade_q2.md` Q2-TIME/COST/GATE/ORDER/DONE/LOSS/CAD; `DEC_U_victory_start.md`; `DEC_U_menu_peace.md` | STATIC `country.script`/`res.script`/`donewgame.inc`/menu-cfg reads + RUNTIME fixed-seed research/peace/expiry batteries | Identical deltas/traces 3 runs; per-row literal cited before adopted; score/time-limit stay ABSENT | STATIC + RUNTIME |

PLAN cross-ref: tasks 4/11/16/22/32/33/40/42/43/46/48/49/53/55/57–61/63–69 DONE (laws/rows implemented, tails labelled); 58/60/68/69/71 DOING/TODO with experiments above.

---

## 5. Domain F — fog / camera / UI (script side CLOSED `[O]`; grid/projection items are RUNTIME)

Closed and implemented (do not re-open): `_unit_GetVision` scalar law, tag-109 fogreveal plumbing, team-gated `SetFOWEnable`, picking/tint `>0` vetoes, vision radius table, ghost-blink donor keys, minimap geometry/DPI/resource arm/unit name-swap, peace enum/labels/order + 60× defect, camera `58/-32/400` + drag epsilon.

| ID | Exact blocker | Evidence report | Experiment / capture | Termination | Settle class |
|---|---|---|---|---|---|
| F-GRID-a | FOW cell size (cells/tile, metres/cell) | `DEC_U_fow_grid.md` §4–5 | E-GRID-a: single viewer + fogreveal radii transects (1.0 + 0.25 fine steps), visions 0/3/8 | One linear scale `k` + stable step width, 0 mismatching cells, 6 radii | RUNTIME (script `GetFOWLOSData` dumps only, no pixels) |
| F-GRID-b | Multi-viewer combine (max/OR vs threshold vs per-team) | same | E-GRID-b: overlapping discs + 3-stacked removal + ally/enemy split | Union shape + removal sequence + team split, 0 mismatches | RUNTIME |
| F-GRID-c | LOS occlusion (pure disc vs hill/forest/wall block + slope) | same | E-GRID-c: hill/forest/wall interpositions vs control + rotated 2nd transect | Cell-identical = pure disc; else fitted rule predicts 2nd transect 0 mismatches | RUNTIME |
| F-GRID-d | Explored-vs-visible persistence + per-player-vs-global + trigger clears | `DEC_U_fow_grid.md`; `DEC_U_fow_persist.md` §§2–5 | E-GRID-d: walk-away / player-switch / balloon-victory matrix + reload pairs | Full matrix identical ×2 repeats, 0 mismatches | RUNTIME |
| F-GRID-e | `GetFOWLOSData` sampling (point vs cell-area, domain 0/1 vs count) | same | E-GRID-e: 0.25 fine transect, raw returns, stability + border tests | Domain enumerated, edge rule 0 mismatches ×3 | RUNTIME |
| F-V1/V2 | Sensor width→FOV; near/far/aspect; drag geometric anchor (press vs first-move); marquee inside-test; minimap affine + frustum quad | `DEC_U_camera_projection.md` §§1–5; `DEC_U_minimap_tail.md`; `DEC_U_selection.md` §§3–4; `DEC_U_fog_camera_hud.md` (pins) | V1-SENSOR / V2-PROJ / V2-DRAG / V2-BOX / V2-MINI (surveyed markers, 0 px / 0.0 m / 0-membership mismatches) | ≥5 surveyed points 0 px; clip boundary exact; all rects incl. 1-px edges 0 mismatches | RUNTIME |

---

## 6. Settling-class summary + what the owner must run

- **STATIC-settleable (no donor execution; workers may continue):** per-sid/per-weapon/per-shield/per-upgrade mechanical audits; `startingsettings.cfg`/menu-cfg/`pattern.lib`/`country.script`/`player.script`/`write*.inc` reads; mask/RTTI/prop censuses; FBO-name/pbuffer-name sweeps already done (negatives logged); `*a.osm`/tool-`.oss` full-tree globs; peace-lobby tag enumeration text side. [SUPERSESSION-FIX: point-in-time/historical "tool-`.oss` full-tree globs" static-settleable label, not current — superseded by `DEC_U_tool_attach.md` (56 attach `.oss` found; recursive parent-glob landed); T-A/T-B stay [U]; parity UNVERIFIED — NO PARITY CLAIM.]
- **RUNTIME-only (owner-authorised donor session; forbidden to workers — this is why the register stays open):** every W-U row (GL hooks + frame captures), every E-B/C/W/S/A/R row (fixed-camera frame-index/vertex-hash traces), every F-GRID/V row (script LOS dumps + pixel solves), every S-TICK/S-RNG row (fixed-seed hash batteries), every S-SAVE-R1 row (paired-save bit-compares), every damage/FF shot series. No worker — including this one — executed the donor binary, captured a GPU frame, or compared a port capture. All such captures are specified with zero-mismatch gates above; "close" never counts.
- **Out of scope:** network/multiplayer. Temporary capture configs under `%TEMP%`/inbox stay out of the port.

## 7. Claim register (audit-level; no parity)

1. Every `[U]` above names its evidence report + exact experiment + zero-mismatch termination. [D] this register.
2. P0-1…P0-8 are the only items that block a donor-faithful visible/simulation result; tails are listed but never promoted. [D] §§0–5.
3. Water has no draw until W-U12 (plus path-gated W-U1/U3/U5/U6) is captured; FOW uses a labelled provisional driver; `TICK_ORDER v1` is PORT APPROXIMATION; animation performs no interpolation; saves carry no byte-parity; `17.27°`/screen-UV bias/`cull_disabled`/nearest-single/depth-tie-break stay scaffolding. [O] per cited reports + PLAN tasks 3/12/42/49/55/62.
4. Any port behaviour equalling donor timing/pose/blend/selection/save-bytes/vision-grid without a §1–§5 cite is **denied**. No same-camera donor/port A/B exists; visual parity is UNVERIFIED. [D] this audit.
5. No donor binary was executed, no GPU frame captured, no port capture compared by this worker. [O] subagent context (repo/doc reads only).

*End of DEC_U_final_register. Read-only; one file written; no source/asset/config/test/runner/Godot/git state changed.*
