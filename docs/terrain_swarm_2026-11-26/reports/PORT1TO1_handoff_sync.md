---
id: PORT1TO1-HANDOFF-SYNC-2026-11-27
title: "Final handoff sync addendum — donor-exact corrections since HANDOFF §9.22"
worker: HANDOFF-SYNC (read-only subagent, full 1:1 Cossacks 3 donor port)
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM__NO_APPROXIMATION
date: 2026-11-27
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md]
files_edited: []
scope_guard: "Repo/doc file reads and read-only filesystem listings only. No source, shader, config, asset, test, fixture, result JSON, backup, queue, git, Godot, runner, gate, capture, ROI metric or donor change; no donor binary executed or opened; no donor GPU A/B frame produced or compared; no gate run. Every donor fact below is carried [O]/[D] from the cited landed reports."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; no donor GPU A/B frame."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/HANDOFF.md (§9.16–§9.22)
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (tasks 1–235)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_deep_index2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md
---

# PORT1TO1 HANDOFF SYNC — addendum to HANDOFF §9.16–§9.22

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

HANDOFF §9.16–§9.22 is a point-in-time snapshot: it records the plan at 186 tasks and the final sign-off state. The post-§9.22 task band is **187–235** in `PORT1TO1_PLAN.md`. This addendum syncs only that delta; it changes no earlier section, closes no `[U]`, and asserts no parity.

## 1. New donor-exact corrections landed since §9.22

- **First-camera wire** (`DEC_U_start_deep.md`, task 217). Supersedes `DEC_U_start_positions.md` §6 EV-CAM-1 ("NO start→camera wiring"): the earlier grep covered `data/scripts` only and missed `data/gui`. File-scope ABSENT stands; path-scope verdict flips to **WIRED-VIA-DOPROGRESS** (deep index 2 flag X-1). Exact wire: `doprogress.inc:41` `_control_MoveCameraToPosition(gMap.players[myPlInd].startx, starty, 0, True)`, gated by one-shot `gbool_gui_mapgenerationfinished` (producer `dogenerate.inc:1939`, after unit spawn and final `SetRandomKey`); second wire Home-hotkey `onshortcut.inc:1000`, third origin wire `docreate.inc:297`. Camera target/height and `time=0` smoothing remain `[U]` CAM-derive/CAM-0 with §6 zero-mismatch captures.
- **ACL class / prototype tables** (`DEC_U_blend_deep.md`, task 189). Byte-anchored CODE-embedded RTTI/property tables: `0x550900` (`TXAnimation`/`TXAnimations`/`TXBaseActor`), `0x550c00` (`TXBaseActor` frame properties), `0x550dd0` (blend properties), `0x4f6d00` (`aar*`/`afp*`/`aam*` enums), ACL dispatch `0x86d800` (`acsaDefault/First/Random`, `actAnimation/TrackPoint/TrackPointPreset/ExecuteState`), script-API signature table `0x62f300–0x630700` with the 8-arg blend prototype at `0x630100`. Names/prototypes are `[O]`; weight curve B1, frame fetch B2 and the per-tick native player P1 stay `[U]`. Data-section string search finds none of these symbols — they live in CODE tables.
- **randkey API VAs** (`DEC_U_place_seed_deep.md`, task 230). RandomExt family `0x60a662/0x60a68a/0x60a6b2/0x60a6e2/0x60a72e(+0x60a731)`; map-key family `0x69f440–0x69f5b2` + `0x6a46fd`; `randkey0`/`randkey1` 6 hits each. Arities byte-proven: `SetRandomKey` 1 in, `SetRandomExtKey64` 2 const, `GenerateMapRandKey` 2 var-out. Zero static xrefs at all table VAs = VM dispatch via `FUN_00608238`; 0 DATA-string hits explain D02 Anomaly A. Derivation `U-KEY`, strict runtime key0-discard `U-KEY2`, shipped-map seed override `U-MAP` stay `[U]`.
- **Shipped-map version / envelope: 53 vs port 92/240²** (`DEC_U_tver_deep.md`, task 228). Four shipped `.map` heads byte-identical: word 0 `35 00 00 00` (=**53**), `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, snapshot framing; terrain `320²` (ausmis1/bonmis1/engmis4) and `384²` (battle1), sub=4. Sole whole-tree writer is `gDataVersion:=92` (`serial.script:27`); `gc_MaxTerrainTypeCount=9`; mapsize enum `0→320,1→480,2→640,3→256`. Port pins `generator_version=92` and `config.json` `240²` (declared **PORT DEBUG ALIAS**; donor sizes `[256,320,480,640]`) → zero-mismatch **FAILS** on word 0 and on extent; both selectors stay `[U]`. Companion smooth-kernel pass (`DEC_U_smooth_kernel_deep.md`): signature table `0x6a3390–0x6a3e6e` gives `SmoothTerrain(x,y,round,mb:Integer)`; the literal `3` binds to `mb`, **not** a float radius; no kernel body/weights; port hook stays NULL/`SKIPPED`.
- **Other post-§9.22 depth** (all `[O]/[D]` with named zero-mismatch experiments, no value promoted): 14 new deep-pass reports enumerated in `PORT1TO1_deep_index2.md` at 368 report files (tasks 204–217); U12 copy-helper caller walk (224), U3 texture registry sweep (225), collision mask census 369/354 (226), economy static angle (229), class-C owner decisions (232), definitive nine-row P0 table (219), remaining-`[U]` classification **71 items = A42/B14/C5/D10** (220), claim recheck 3 (222), minimal owner bundle index 34 files (223).

## 2. Implemented in port code vs only reported

- **IMPLEMENTED — 2D + 3D first-camera wire** (tasks 221 `IMPL-START-CAMERA-WIRE` and 227 `IMPL-START-CAMERA-3D` DONE, parses OK): `game.gd:94` declares `gui_mapgenerationfinished` (default false); armed at `:709` in the `setup_spawns()` generation tail; `consume_start_camera_target()` (`:686–694`) clears the flag one-shot and returns the local player's `map_starts[0]`. `camera.gd:179–187` `_consume_start_camera_wire()` is called from `_process` (`:246`) and applies the target through the existing `jump_to_world()` API; `camera3d.gd:485–492` is the 3D mirror, called at `:663–666`, through the 3D `jump_to_world()`. No new FOV/zoom/height constant, no `HEIGHT_SCALE`; donor height/time args and native clamp stay `[U]`. `camera.gd.bak-STARTWIRE`/`camera.gd.bak-STARTCAM` backups exist.
- **REPORTED ONLY — no IMPL lane recorded:** ACL class/prototype tables, randkey API VAs, shipped 53-vs-92/240² mismatch and the `mb`-not-radius correction. The plan records these rows as report/decision only; no value was wired into port code, no gate PASS follows. Every deep pass leaves `[U]` labels, hard-fails, UNSET gates and preserve-only files intact.

## 3. Current plan state

- `PORT1TO1_PLAN.md` is at **235 tasks** (§9.22 recorded 186). Lanes 187–230 are DONE (report/decision or parse-checked file-scoped edits). **Task 186 "final owner review" is BLOCKED**, not TODO: it needs an owner-authorized matched donor GPU A/B frame + camera manifest; 575/582/585 remain owner-only unacked.
- **No active implementation or execution lane.** The only DOING rows are 231 `B-ANGLE-INDEX`, 233 `D-COSMETIC`, 234 `PLAN-SYNC` and 235 `HANDOFF-SYNC` — an outcome index, cosmetic-tail classification, and two audits/syncs. The plan's "Current active workers (0)" heading is stale (it lists completed ids); filesystem state cannot prove live sessions.
- Nine P0 rows all `OPEN` (`PORT1TO1_p0_final_status.md`); 71 open `[U]` items classified A42 donor-runtime / B14 static / C5 owner-policy / D10 cosmetic. Chain 0/6.

## 4. Current verification state

- **MCP host** `cossacksgodotmcp`: protocol handshake (integer id echo, `2025-03-26` echoed, `serverInfo.name`, 6 tool schemas, `notifications/initialized`, `GET /mcp` 202) and all six tools exercised live on the QA 64×64 donor-backend map; valid PNG image block, exact `isError` reason on invalid sid. Host stopped; Godot lock free.
- **Deterministic repeats:** opt-in `--deterministic-capture --capture-ticks N` (fixed 1/32 ticks, authoritative `capture_view3d`, 1280×720 asserts, no CPU fallback, `audio_seed` in manifest). `detcheck`/`detcheck2` and post-label `finalcheck`/`finalcheck2` produced byte-identical per-frame `sha256_pixels` (`def18ad9…`, `18e1e72…`); `--verify-repeat` `repcheck_20261113` reported `byte_identical=TRUE`. Plain `--screenshot` is frame-paced (`cap_fullport8` vs `cap_fullport9` SHA differ) and is **not** replay evidence.
- **ROI metrics:** 14/14 `compare_frames.py` comparisons executed, 0 refusals, every run printed `parity=UNVERIFIED`; 14 diff PNGs + 14 JSONs under `inbox/qa/captures/roi_metrics_20261113/`. Metrics are screening/support cues only; camera label `NOT_SHARED_donor-oblique_vs_port-17p27` asserts no camera match; no threshold, similarity score or donor PASS.
- **Preserve hashes:** `PORT1TO1_hash_manifest.md` point-in-time SHA-256 — `config.json` `223767e5…` and `manifest.json` `36f6a378…` (no earlier baseline), `config_donor_capture.json` `aa857480…` (matches recorded baseline P-2), plus I11 seam backups. Identity only, never fidelity. §9.22 identity hygiene: four `decode_*.py` prefix differences are stale recorded prefixes — `git diff` shows those files byte-identical to HEAD; no re-baseline or revert. A matched hash certifies byte preservation, not a `[U]` closure.

## 5. Unchanged verdict

- `parity.status = UNVERIFIED`, `parity.claim = NONE`, `visual_parity_claim = false`. Six-condition chain **0/6 CLOSED** (condition 6 PARTIAL, port-internal repeatability only). Nine P0 rows OPEN. 575/582/585 unacked. No donor GPU A/B frame exists or was invented under the read-only rule; HANDOFF §4 gate cells remain `TODO(COORD)` and unit-test gates are explicitly not acceptance.
- `blocking_unverified` is non-empty (nine P0 rows plus domain tails) ⇒ **`RESULT IS NOT GOOD`**. Nothing in this addendum closes a `[U]`, promotes a metric, accepts an approximation or upgrades a report to a gate PASS. Rollback stays file-scoped from `inbox/backup/*.bak-COORD-I11`; never `git reset --hard`.

*End of PORT1TO1-HANDOFF-SYNC. Exactly one repo file written by this worker (`docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md`). No source, shader, config, asset, test, result JSON, backup, queue, git, Godot or donor change; no gate run, no capture, no donor A/B frame, no donor-parity or gate-PASS claim.*
