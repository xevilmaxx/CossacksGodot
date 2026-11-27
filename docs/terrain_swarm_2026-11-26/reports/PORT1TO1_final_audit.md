---
id: PORT1TO1-FINAL-AUDIT-2026-11-27
title: "Definitive final audit — full 1:1 Cossacks 3 donor port (single authoritative state statement)"
worker: FINAL-AUDIT (read-only subagent; plan row 270)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM__NO_APPROXIMATION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_audit.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_audit.md]
files_edited: []
scope_guard: "Repo file/line reads, read-only glob/listing/Get-FileHash over existing files only. No source, shader, config, asset, test, fixture, result JSON, backup, queue, git state, Godot process, runner job, gate, capture, ROI metric, donor binary or donor GPU frame was created, modified, executed, copied or compared. Exactly one repository file written: this report. Every donor fact is carried [O]/[D]/[I] from cited landed reports; no value is promoted, no [U] closed, no gate run."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; parity.status=UNVERIFIED; parity.claim=NONE; no donor GPU A/B frame exists and none may be produced under the read-only rule; static [D] facts only narrow experiments; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_full_project_audit.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_counts_sync.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_verdict_sync.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_vsync.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (master table, rows 1-270, read this pass)
---

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

# PORT1TO1 — definitive final audit (2026-11-27)

**Purpose.** One authoritative state statement to stop report proliferation. This report does **not** re-adjudicate any prior report; it consolidates the landed governance set. Point-in-time at this read: master plan **270 rows**, `reports/*.md` **414 files** (this report is the 415th and is plan row 270). A `DONE` plan cell means a report/lane landed — **not** a gate PASS and **not** donor fidelity. Later or right-hand reports do not make earlier claims true. No parity claim is made and no approximation is adopted here.

## 1. What is implemented in `variant3d/` — with donor-exact evidence

Every implemented item below is a **labelled** donor-text/donor-literal transplant (`[O]` observed bytes/lines, `[D]` derived law) in source, or telemetry/annex data. **An implemented donor law is not a demonstrated donor-matching runtime value.** Where a value/behaviour remains open it is named in §2.

| Area | Implemented in `variant3d/` (donor-exact basis) | Still open (not implied by this row) |
|---|---|---|
| **Terrain / render** | `IMPL-GEN-1TO1`, `IMPL-RENDER1TO1`, `IMPL-U-TERRAIN-GLSTATE` (plan r1–2): exact stage order, `RandomExt` LCG `s=(s*0xFC0D+0x3C6EF35F)&U32`, 11+3 reseeds (D02/V58; `X21` 20-vector oracle), donor water thresholds (basin −1.1 / field −0.5 / classify −0.25 / shore −0.1 kept distinct, `generatemap.inc:7,688,704`, `texturemap.inc:29-31`), byte-exact lighting sun `(−0.3447,0.9387,0)`, ambient `(50,47,33)/255`, diffuse `(207,199,177)/255`, shininess 16, effective specular `vec3(0)` (`light.cfg`, X35 §4-5), `sceneColor=0.2` `[O]` bound. `IMPL-RELIEF-LABELS` (r96) authority labels. | Relief field-name seam (`grid` vs `relief_float_grid`) and missing `_stamp_pattern()` call ⇒ height stays mask-only; 2 of 3 F01 offsets (`plt2=2222`, `k_ravine_big_stone_1=8225`); f32-step precision; centre double-conversion; collision tags unpainted; 16×8 packed atlas + `[U]` alpha-patch decomposition (`full_project_audit` H-1…H-12, T-1…T-7). |
| **Water / shore (hard-fail)** | `IMPL-WATER-COMPILE`, `IMPL-WATER-LIB`, `IMPL-WATER-BRANCH-LABELS`, `IMPL-SHORE-ALPHA` (r3/74/82/100): BUILTIN path `[D]` default, two verbatim scalar tuples with explicit source gate, 30-key uniform tables, shore smoother 3× power 0.35 and tile ids 93/97/98 donor-grounded; 32-entry alpha set labelled. **Hard-fail preserved:** `water3d.gd:501-503` `bind_reflection_map(null)` refuses "[U12] requires a real reflectionMap" — **no water, no grey fallback**; U4* `null` = "no captured value", ENGINE selection hard-fails, no invention (`parity_chain §5`). | P0-1/1b/2 (U12 provenance, live U4* tuple, U1/U3/U5/U6); plane Y is labelled `PORT APPROX -0.25` placeholder; water-local sun vector wrong (`full_project_audit` W-2/W-3). |
| **Objects / AAF / art** | `IMPL-AAF-ART`, `IMPL-FX-ART`, `IMPL-BUILDING-DEATH`, `IMPL-TOOL-WIRING`, `IMPL-AAF-TRIGGERS` (r5/18/26-27/102/106): 40 actions; donor AAF T1–T26 table/resolver/cycle policy in `anim3d.gd`; death families 44 derived meshes + 11 texture rows + 12 stems; ghost-blink exact `TXLifeColorEffect 'blink'` 3-key alpha/period installed, green/red tint retired; PFX `secPerFrame` law + TTLs; **63 derived peasant tool skins + 3D attach** (`DEC_U_tool_attach`: 56 `pea<nat>_<tool>.oss` under `attach/`, superseding earlier "no `.oss`" claims — `claim_recheck8 §3.2`). Nation art: `country.script:138-206` prefix rule + EUR aliases/ukr-building labels in manifest. | Bone parent hierarchy unreadable ⇒ flat-root morph labelled `BLOCKED`; AAF blend curve `w(t)`, frame fetch, completion ticks `[U]`; atlas tier `assets/terrain_new/atlas/` absent (legacy 179.9 MB fallback); Objects[]/`families/*.json` feed unwired ⇒ zero props or Z08 `mountain_props.json` fallback; composer `bind`→`build` patched but volatile (`full_project_audit` P-1…P-4, A-1; `claim_recheck8` C7). |
| **Skirmish laws / rows** | `IMPL-SKIRMISH-LAWS`, `IMPL-SKIRMISH-ROWS`, `IMPL-TICK-ORDER`, `IMPL-MARKET-TAIL`, `IMPL-RNG-GAME/DATA` (r4/11/16/49/57/62-65/74): 8 donor law sets in `game.gd/data.gd`; **77 weapon rows + 33 protection rows**, T2 damage, C1/S/A1/O1/G1 heads; 140 literal per-sid vision rows; rational market law `(c+bound·w)/(1+w)`, buy-then-sell two-row scope, `MARKET_EXP` quirk, live `round(Lerp(ClampInt(...)))` dlt tracker; absolute-deadline tick progress gate + cadences + `progresstick id*2`; exact S stream/S0–S4 draw order + X21 telemetry; peace indices 60× minutes→seconds. | Native tick interleave (`TICK_ORDER v1 PORT APPROXIMATION`, `game.gd:5697/6058`), RNG G1 attribution/per-site counts, market float semantics U6-T/DLT/O1 (D4 `[U]`, blocking unless excluded), skirmish tables values live-`[U]` (`p0_final_status` rows 5/8; `u_register2 §5`). |
| **Save** | `IMPL-SAVE-CONTRACT`, `IMPL-SAVE-FLOAT`, `IMPL-SAVE-BITS`, `IMPL-ENDGAME-SAVE` (r21/32/43/46/76): 19-section order + widths `[O]`, Boolean **1-byte 0/1 not bit-packed** `[D]`, `.map` `OSWMap13` envelope `[D]` (shipped heads `35 00 00 00`=53, build 2843), TObj/TProj order telemetry, additive-only v5 keys (`victorystate_int` 0/1/2, setres/lanres/uniqrnd/orders12, `save_donor_version=92`), byte-compatible restore `>=5`. | Outer container, float Single-vs-Double wire, codepage, transform placement, tails/checksum, nested `orders[].info.trg` uid-vs-handle routing all `[U]`; fresh-save word `5C 00 00 00`(92) is a `[D]` **prediction, not an observed literal**; v5 explicitly "NOT a byte-parity claim" (`game.gd:9063`). |
| **Fog / camera / HUD** | `IMPL-FOG-HUD`, `IMPL-FOG-PATCHES`, `IMPL-MINIMAP-TAIL`, `IMPL-FOW-TINT`, `IMPL-TEAM-VISION`, `IMPL-START-CAMERA-WIRE/3D` (r12/38/95/117/129/221/227): donor vision law `floor(20+4·vision)` + `>0` veto (`DEC-U-FOW-NUMERIC-DEEP`); DPI-scaled bottom-right minimap with strict `los>0` resource law; exact `_fow_viewer_players` loop + terminal-victory gate; FOW tint/territory comment-only labels (no RGB/interval invented); first-camera start→camera wires found at `doprogress.inc:41` (producer `dogenerate.inc:1939`), Home `onshortcut.inc:1000`, origin `docreate.inc:297`, implemented via existing `jump_to_world()` API (`game.gd:94/709/686-694`, `camera.gd:179-187`, `camera3d.gd:485-492`), parses OK. | FOW cell size/multi-viewer/LOS/persistence/tint, pick/AABB/drag/marquee, sensor→FOV/near-far/aspect all `[U]`; `17.27°` = 216 mm sensor at focal 400 is **PORT APPROXIMATION**; matched camera explicitly `NOT_SHARED`. |
| **Tools / host** | MCP host **VERIFIED**: exactly 6 tools (`game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`), live 64×64 donor-backend QA probe, `game.tick({})` clean refusal (`t_mcp_host.gd`, protocol `2025-03-26`). Runner `godot_runner.py`, `capture_sequence.py`, `compare_frames.py`, `terrain_qa_harness.py`, `assert_clean.py`; opt-in `--deterministic-capture --capture-ticks N`; `--check-only` parse artifact `00000133.json` (syntax only, not verification). | Frame-step design originally unimplemented in the parity-chain read (`parity_chain §4.2`); later port-internal detcheck/detcheck2 shows the mode now runs (§3, point-in-time divergence preserved). No tool metric is a parity gate. |

## 2. What remains approximation / `[U]`

**Nine P0 rows — all `OPEN`; `CLOSED` appears for no row; `PARTIAL` is a chain-cell label only** (`p0_final_status §1`, `u_register2 §4`):

| Row | Domain | Still `[U]` |
|---|---|---|
| P0-1 / W-U12 | water | reflection provenance FBO vs `glCopyTexImage2D` vs static upload; `(w,h,format,filter,wrap,mips,unit)`, projective matrix, pbuffer path |
| P0-1b / W-U4* | water | which of two atomic tuples (ENGINE vs `water.lib` FILE) is live; W0/W1, S10/S11 |
| P0-2 / W-U1,U3,U5,U6 | water | live shader path, `(hmapW,H,Min,Max)`, hmap GL identity, writer of `C+0xc8`, UV dividend/winding/cull |
| P0-3 / F-GRID a–e | fog/UI | cell size, multi-viewer combine, LOS occlusion, explored-vs-visible persistence, `GetFOWLOSData`, panel RGBA tint |
| P0-4 / S-TICK-O1 + D1–D3 | skirmish | `plInd` rotation, firing rate, interleave, mod-cohort, micro-order, bank edge, veto, AI split |
| P0-5 / E-B1…B4, C1, C2 + W/S/A/R | AAF | blend `w(t)`, window fetch, `acmPlayOnce`, handler timing, weapon→token, sticky readback, `reaction` |
| P0-6 / S-SAVE-R1a…g | save | container, float/bool wire, codepage, transform, victorystate/tails, checksum/trailer, E-T1 trg |
| P0-7 / S-RNG-G1 | RNG | Bankers `round()`, S/G split, per-site draw counts, promotion, signed key0, attribution |
| P0-8 / E-U13 + F-V1/V2 | selection/camera | pick distance/order/AABB/FOW veto, sensor→FOV, near/far/aspect, drag anchor, marquee, minimap |

**71 open `[U]` rows** at authoritative register granularity — class **A42 / B14 / C5 / D10** (domains W15/T5/E18/S16/F12/GOV5). **Zero rows removed** by the final sweep; `U-base-speed` is a newly *named id split* of counted `U-speed-consumer/T-SPEED`, not a 72nd row (`u_register2 §1-3`, `counts_sync §0/§1.1`). A is donor GPU/harness-only, B additional static decomp, C owner policy, D cosmetic tail. **D4 remains `[U]` and NOT CLOSED** — blocking unless market prices/trades/active-dlt are all recorded as out of scope; it is an additional blocking non-P0 item.

**Discipline:** ten static/formula/structural closures (S-1…S-10: randkey derivation, relief field defaults, quad copy site, T-VER envelope-53, first-camera wire, UREG-CTOR, B-angle sweep, TOSW sweep, S0 kernel window, D4 refinement) **close only the named static question** — they never close class-A value/behaviour items or any P0 row. Structural blockers still stand: relief grid feed + stamp call; Objects feed/composer wiring; absent atlas tier + 16×8/alpha-patch approximation. The "8 exact recoveries" label = **4 IMPLEMENTED + 4 REPORTED-ONLY**, not eight donor-matching runtime results (`owner_brief2 §1`, `counts_sync §1.4`).

## 3. Verification status (honest)

- **MCP host: VERIFIED** (6 tools, live probe, no parity claim). **Parse checks** 18/18 GDScript `--check-only`, V90 static 13/13 — static only, Godot not run by that worker.
- **Deterministic repeat: port-internal PASS** — `detcheck`/`detcheck2` (seed 20261113, 64 ticks / 2 frames, 1280×720) byte-identical per-frame `sha256_pixels` (`def18ad9…`, `18e1e72…`); `repcheck`/`finalcheck` `byte_identical=true`; **chain condition 6 PARTIAL, not CLOSED** — 2 frames vs 24/768 design target, both manifests `parity=UNVERIFIED`, not a donor frame, camera match or geometry-byte equality. Point-in-time divergence: `parity_chain §4.2` recorded frame-step mode unimplemented; later owner brief records the opt-in mode running — both readings preserved.
- **ROI metrics: 14/14 executed, 0 refusals, all `parity=UNVERIFIED`**, camera `NOT_SHARED_donor-oblique_vs_port-17p27`; MAE/RMSE/histogram/diff PNGs are support cues with no threshold, no similarity % (`roi_metrics`).
- **Guard audits: PASS** — parity strings negated/guarded (C1–C6 clean through `claim_recheck8`; C7 = 13 stale `ABSENT`/`EXACT` supersession sites needing **inline footnotes only**); no weakening (`check()` counts unchanged vs `.bak`, changes adjudicated P0-GATE-01/DARKROW/D-22); preserve-only PASS with 3 recorded witnesses byte-identical; GF1–GF4 MINOR label gaps, prior G1–G3 fixed.
- **Gates: not green** — tickets 575/582/585 UNACKED with no result JSON; D1/D3 unruled; `terrain_qa_spec.json` SCHEMA_ONLY; `t_terrain_donor.json` `status=PASS 26/26` but `parity.claim=NONE`, `parity.status=UNVERIFIED`, all 18 advisories UNVERIFIED, S2=0/S3=0/S5=0; `selftest 29/29`, `uitest 17/17`, `t_render_mode 10/10`, `t_map_variety 5/5` are port-internal regressions only. No gate or ROI metric promotes parity.
- **Hashes: identity only** — `config_donor_capture.json` `aa857480…`, `main.gd.bak-COORD-I11` `3859b605…`, `world3d.gd.bak-COORD-I11` `44ee96c0…` match baselines; `config.json` `223767e5…` and `manifest.json` `36f6a378…` point-in-time, no baseline; `main.gd` live `94c61047…` **drifted** from earlier `93faea93…` (COORD adjudication open, plan r268); 4 decode-tool prefixes mismatch recorded values (provenance open, plan r267), 2 tool baselines match (`3A92D053`, `5A3B9E77`); donor pin `t_87f0f3c130b0` = `87f0f3c1…c16` quoted from X59, **never hashed/executed here**.

## 4. Canonical verdict

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

```
RESULT IS NOT GOOD — blocking_unverified is non-empty; parity.status=UNVERIFIED; parity.claim=NONE; no donor GPU A/B frame exists and none may be produced under the read-only rule; static [D] facts only narrow experiments; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximations; no parity claim.
```

Verbatim reviewer-line SHA-256 `30FEC6929276B30830D397D525EA1AC43D11AF773B0CA263F0F04A16EA3928E7` (167 B). All 78 frontmatter verdict strings and 10 fenced blocks differ only by **additive qualifiers**; no substantive claim exists (`verdict_sync §5-6`, `handoff_vsync §1-3`, `checklist_final`). `visual_parity_claim=false`. Six-condition chain **0/6 CLOSED** (conditions 2 and 6 PARTIAL port-internal; 1/3/4/5 BLOCKED). No tier above 2 exists.

## 5. No further worker action can close parity

**Explicit statement.** No worker action — no further report, label fix, static decomp angle, telemetry lane, green-looking test, ROI metric, deterministic repeat, file hash or `[D]` derivation — can close any `[U]`, retire any of the nine P0 rows, or establish donor parity. Conditions **1, 3 and 6** of the six-condition chain require artifacts that only the **owner/COORD** can produce: (1) a genuine same-size/seed/type/season/**matched-camera** donor **GPU frame** from an owner-launched `cossacks.exe` (Route A) with a written key/camera/ROI manifest; (3) matched-input labelling (same keys or importer-rendered same geometry); (6) a COORD-signed ruling of demonstrated geometry-byte equality and pixel-identical frame at zero mismatch. The read-only charter forbids workers to execute the donor binary, produce a capture, run a gate or wire a value. Until owner-authorized **donor GPU A/B with a matched camera** and the COORD ruling exist, `blocking_unverified` stays non-empty, parity remains `UNVERIFIED`, and **`RESULT IS NOT GOOD`** unconditionally. This audit neither adopts an approximation nor claims parity.

---

*End of PORT1TO1-FINAL-AUDIT. Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_audit.md`. No code, shader, config, asset, test, result JSON, backup, queue, git, Godot, gate, capture, ROI metric or donor execution. No approximation, no parity claim.*
