---
id: PORT1TO1-FOW-OWNER-PROTOCOL
worker: FOW-OWNER-PROTOCOL (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "The single ordered, owner-only fixed-seed FOW experiment packet: controlled reveal transects, exact dumps (grid cell size, combine, occlusion, explored persistence, GetFOWLOSData domain, minimap tint), pinned VAs/signatures, zero-mismatch termination, and per-outcome port change. P0-3 / F-GRID a-e."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
labels: [O, D, I, U, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, patched, committed or opened as a target by this worker; no GPU frame captured. The owner-only session in §3-§4 is SPECIFIED, not performed."
scope_guard: "Repo/doc file reads and read-only symbol/line greps only. No source, shader, asset, config, test, fixture, result JSON, git state, Godot process, runner job, gate or capture was created/modified/executed. Exactly one repository file written: this report. No Craft Anything native call; no investigation memory written."
multi_pass: false
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty; P0-3 (F-GRID a-e + persistence + tint) stays open; six-condition parity chain 0/6 CLOSED; no donor GPU A/B frame; no cell size, occlusion slope or colour invented; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
upstream:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md (§1 P0-3; §5 RUNTIME-GPU class)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fog_camera_hud.md (§§0-1, 5, 9: closed vision/plumbing/gating/vetoes; F1-GRID/F1-MINI left [U])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_grid.md (§§3-6: F1-GRID a-e, E-GRID-a...e)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_grid_deep.md (§§2.1-2.5, 4-6: 24-name binding block, RTTI, E-KNOB-defaults)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_persist.md (§§3, 5-6: lifecycle, E-PERSIST-d)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_knobs.md (§§2, 5-7: K1-K9 signatures, shipped-active vs engine-default-only)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_tint.md (§§2-6: F1-MINI-TINT, S2-UNIT-TAIL)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fog_territory.md (§§1, 5-6: capture path issues no FOW invalidation) -- task brief named this file DEC_U_fow_territory.md; the on-disk filename is DEC_U_fog_territory.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (§0 owner rule; §2 F-GRID-a...e/F-TINT)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_endgame_protocol.md (§1.1 seed/config/Class-N; §1.2 fixture)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md (form template: one-session ordered owner protocol)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_fow.md (§§0-3: exactly 6 live UpdateFOW call sites, zero in victory/defeat/team-mutation paths)
  - variant3d/scripts/world3d_fog.gd (read-only symbol/line census this pass; key symbols now at :618-:1295)
---

# PORT1TO1 FOW — single owner-only fixed-seed experiment packet (read-only, no parity)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a protocol, not a result.** It introduces no cell size, no occlusion slope/blocker list, no tint colour/threshold, no combine operator, no explored lifetime, no LOS return domain and no knob default. Every open item stays `[U]` until its own **zero-mismatch** criterion terminates. No "close", no metric, no still, no green-looking test and no port fallback promotes anything to donor parity.

---

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim donor bytes/text/decompiled signature or verbatim port file line), `[D]` (deterministic reading of `[O]`), `[I]` (interpretation, flagged), or `[U]` (UNVERIFIED — retired **only** by the owner executing §3-§4 under §5).

- **This worker executed nothing.** No donor binary was run, no debugger/tracer invoked, no GPU frame captured, no Godot/gate/runner job launched, no source/shader/asset/config/test/git mutation. All donor VAs, evidence ids and script `file:line` cites below are **re-carried pinned `[O]/[D]` records** from the upstream reports in the frontmatter; they were not re-lifted by this worker. No Craft Anything native pass was made; the shared investigation memory was never written.
- **Owner-only / workers forbidden.** Per `CHARTER.md:66-84`, `PORT1TO1_owner_decisions.md §0` and `PORT1TO1_u_register_update.md §1/§5`, the whole §3-§4 packet is `RUNTIME-GPU` (owner-authorised donor GPU/runtime or fixed-seed harness). **A worker may not launch `C:\Games\Cossacks 3\cossacks.exe`, attach a debugger, capture a frame, run a Godot job, or promote a `[U]`.** This packet is an instruction to the owner, not an execution by any worker.
- **No approximation, no parity claim.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false` hold before, during and after this document. A terminating capture promotes one `[U]` to `[D]+capture-id`; it does **not** prove visual parity — a matched-seed donor-vs-port GPU A/B frame is still required, and none exists. `blocking_unverified` stays non-empty ⇒ **`RESULT IS NOT GOOD`** unconditionally.
- **Single session unit.** The canonical packet is **one** owner-authorised donor session at one fixed seed S with controlled reveal transects (§3). Where an upstream criterion mandates 3 runs (tint, sampler domain, knob defaults), the owner repeats the *identical* packet at two further recorded seeds; all repeats are logged with seed + config SHA-256, never averaged, never pooled across seeds within one zero-mismatch claim.
- **Filename normalization.** The task brief names `DEC_U_fow_territory.md`; the on-disk report is `DEC_U_fog_territory.md`. Both refer to the same landed report; no other file is implied.

**Load-bearing port fact `[D]` (read-only this pass, unchanged here):** `variant3d/scripts/world3d_fog.gd` currently drives a labelled provisional `1 res = 1 m` grid (`_vision_radius_m`), a `fog_counts > 0` combine and a sticky `fog_explored[i]=1` mirror. The donor has **no per-frame script FOW refresh**: `DEC_U_endgame_fow.md:36-67` finds exactly 6 live `UpdateFOW` call sites and **zero** calls in every victory/defeat/team-mutation path. The port's per-tick rebuild shape is `[U]`. This packet does not change any of that.

---

## 1. Closed `[O]` context reused verbatim (do not re-prove; file:line only)

These are already landed and implemented in the port; they are **not** what the owner must settle. They are the pinned preconditions for the transects in §4.

- `[O]` Vision law: `_unit_GetVision` (`unit.script:11563-11614`) — fogreveal tag `gc_properties_stringtag_fogreveal=109` (`dmscript.global:1439`) → `res := floor(pproj.dx)`; normal → `res := floor(cBaseVal + cModVal * vision)` with `cBaseVal=20`, `cModVal=4` (`:11567-11571`; `18`/`3.6`/`3.75` rows are `//` dead); dead/unbuilt/invisible → 0. Examples `[D]`: vision 0/1/3/8 → 20/24/32/52. **Units of `res` are engine-defined — that is F-GRID-a, still `[U]`.**
- `[O]` Reveal plumbing: `_misc_GetOrCreateFogReveal` / `_misc_RemoveFogReveal` (`misc.script:5883-5944`), epsilon scan (`:5901-5916`), `AddFOWObjects` + `visible=False` + `TProj.px/pz/dx := px/pz/radius`; `map_revealZone` (`scenario.script:1851-1864`) → `FOWBuildFull` under `if GetFOWEnable` (`:1862`).
- `[O]` Gating: `_player_UpdateFOW` (`player.script:451-478`) — balloon / balloon-with / `victorystate<>'none'` / `gbool_editor_fogofwar` (`dmscript.global:2120`) gates; unconditional `ClearFOWPlayers` (`:460`); own + same-team allies with the `plInd<>0 or not bneutral` guard (`:461-476`); `SetFOWDovFunc('_unit_GetVision')` (`:475`); `SetFOWEnable(bFOW)` (`:477`). Call order `control.script:712-720` (`SetPlayerHandleInterfaceIO → UpdateFOW → Deselect → DoUpdateSelection → InitMinimap`).
- `[O]` Vetoes: picking `bVisible := (not GetFOWEnable) or (GetFOWLOSData(x,z)>0)` (`control.script:270-273`); resource tint `bNotInFOW` / `userBlend 0.5/1.0` (`gui.script:3478-3496`, applied `:3488-3491`). **Only `>0` is grounded; the raw return domain is `[U]`.**
- `[O]` Minimap blip name law: `pl3x3` iff building else `pl2x2`, `.sel` iff picked, color `gMap.players[pl].color` (`misc.script:1019-1053,1137-1172`); `Interval = 50` (`:1042-1048`) with **unstated units**.
- `[O]` Camera pins for reproducibility: `SphereHeight/SphereLength=58`, `Min=20`, pitch `-32°` all heights, focal `400` fixed (`camera.cfg:6-10,32-35,44-45`). `DynFog*` (`:59-64`) is **visual depth fog** (`DynFogDepth=False` in the gameplay camera) — excluded from every FOW experiment.
- `[O]` Lifecycle (why the persistence arms are shaped as they are): map-gen `initmapgen.inc:214-216,221,223-227,276,285`; `onload.inc:49`; `onloadfull.inc:47-52` fogreveal `AddFOWObjects` re-merge; `onsave.inc` carries **no** fog/explored payload; fogreveal `DelFOWObjects` on `dodeath/ondestroy/onstopevent/onterraincollide`; unit/building `ondestroy.inc` has **no** FOW call (viewers drop via the `res:=0` dead arm). **No per-tick FOW merge in `progress.inc:37-180` or `nothing.inc:1-594`.**
- `[O]` Capture path (`DEC_U_fog_territory.md §1`, `miscext.script:892-959`) issues **zero** FOW calls: `FOWBuildFull` has one writer (`scenario.script:1862`), `ClearFOWPlayers` one (`player.script:460`), `SetFOWEnable` one (`:477`). `gScanGrid` is a **different** grid from the FOW visibility grid; `_unit_IsOnEnemyTerritory` reads `gScanGrid[gridX,gridY].owner` (`unit.script:11624`), owner init `-1` (`serial.script:277`). No territory-cell set or FOW rect invalidation is statically recoverable — **never add one on capture**.
- `[O]` Knob surface: shipped-active set = `Get/SetFOWEnable`, `Add/ClearFOWPlayers`, `Add/Del/ClearFOWObjects`, `Get/SetFOWDovFunc`, `GetFOWLOSData`, `FOWBuildFull`. `FOWElevation`, `FOWLerpFactor`, `FOWTextured`, `FOWDefDov`, `FOWColor`, `FOWFillMaxNum`, `FOWDateTime`, `FOWSmooth` have **zero shipped script writers** and zero `.ini`/`camera.cfg` keys (`DEC_U_fow_knobs.md §5`; `.inc` tree read-denied there, recorded as a boundary, not bypassed).

**Explicit exclusions `[D]`:** `gc_pixels_to_tile=53.3333333` (`dmscript.global:172`) is a render/tile conversion, **never** a FOW cell size. `colors.lib Fog=60,100,150,1` is scene grading, `CriticalColor Blue=1/0` is LOD fallback, `miscext2.script:268` blink `0.2/floor(10/0.2)*10` is the alarm `lens.0`, `camera.cfg:19 IntervalTime=10` is camera elasticity, `data.gd MINIMAP_INTERVAL=0.25` is a port cadence — **none** is minimap/FOW tint law.

---

## 2. Pinned native VA / signature / evidence register (all `t_87f0f3c130b0`)

Registration order, not call order. **No grid dims, stride, operator, threshold, slope, colour or default is co-located with any entry — static recovery ends here by evidence of absence.**

### 2.1 Entry points and evidence ids `[O]`

| Ref | Signature / site | File-off (VA) | Evidence id (pinned) | Break / hook | What is read |
|---|---|---|---|---|---|
| FOW-EN | `FOWEnable` engine gate pair in CODE | `0x1d9daa` (VA `0x5da9aa`), `0x2a74b5` (VA `0x6a80b5`), `0x2a74dd` (VA `0x6a80dd`) | `ev_ae7d083867057581f8221772ca24173249b3509085b3af3e7eed5728c5bac039` | script-side `SetFOWEnable(bFOW)` at `player.script:477` | sim gate; **says nothing about cell size** |
| FOW-LOS | `function GetFOWLOSData(x, z: Float): Integer` | `0x2a7812` (VA `0x6a8412`) | `ev_4f7e8d6440c11e327ccc728e5ffce9dc65313d95b50db44a85bb1b0090ef584d` | script dump at `(x,z)` | raw `Integer` return; domain `[U]`; call sites compare only `>0` |
| FOW-FULL | `procedure FOWBuildFull` | `0x2a7906` | (binding block P6, `DEC_U_fow_grid_deep.md §2.1:13`) | full-recompute trigger | recompute sentinel for every dump |
| FOW-NEG | `SetFOWEnable` / `GetFOWLOSData` feature-find | — | `ev_f476d16079a0ec18a1cd6b1313ddf233b7e834b1bd9093e5caee2ce087d9866f` / `ev_be8575b24af2ca658b9f3c3907485b142a0f9864816c376a39144fee18b08b3e` | expected negatives (0/0/0) | script-bound names; no engine symbol — expected, not absence of feature |
| FOW-TAG | `fogreveal` native bytes | — | `ev_d80780256b6c1c303f408eccf2422426b0d2bf85fe094a77e239b0d20d82870a` (parent form; `DEC_U_fow_persist.md` carries a variant `ev_d8078025…2f8059fe84b77e239…`) | expected negative (0 matches utf8+utf16le) | basename stored opaquely; law lives in script text. **Evidence-id variant noted; re-verify by hash before relying on it — negative result is not load-bearing for any verdict.** |
| FOW-RTTI | `TLOSInfo @0x361191`, `TLOSData @0x3611e9`, `TFOWLerpInfo @0x361241`, `TFOWLerpData @0x36129d`, `TOSWFOWRender @0x3613a9/@0x3613be`, `XFOWRender @0x3613d6/@0x361419/@0x549f0d`, `FOWRenderT @0x1d9c16` | feature row with `FOWEnable @0x1d9daa` | (P7 `DEC_U_fow_grid_deep.md`, P4 `DEC_U_fow_knobs.md`) | native RTTI/feature-slot re-dump | proves an engine LOS/render layer; **no field layout or colour** |

### 2.2 FOW script-binding block (`0x2a74b2–0x2a79d3`) — exact signatures `[O]`

| # | Signature (verbatim) | Anchor file-off |
|---|---|---|
| 1 | `function GetFOWEnable: Boolean` / `procedure SetFOWEnable(val: Boolean)` | `0x2a74b5` / `0x2a74dd` |
| 2 | `function GetFOWElevation: Float` / `procedure SetFOWElevation(val: Float)` | `0x2a750d` / `0x2a7539` |
| 3 | `function GetFOWLerpFactor: Float` / `procedure SetFOWLerpFactor(val: Float)` | `0x2a7569` / `0x2a7595` |
| 4 | `function GetFOWTextured: Boolean` / `procedure SetFOWTextured(val: Boolean)` | `0x2a75c5` / `0x2a75f1` |
| 5 | `procedure AddFOWPlayers(hnd: Integer)` / `procedure ClearFOWPlayers` | `0x2a761e` / `0x2a764e` |
| 6 | `procedure AddFOWObjects(hnd: Integer)` / `procedure DelFOWObjects(hnd: Integer)` / `procedure ClearFOWObjects` | `0x2a7675` / `0x2a76a5` / `0x2a76d2` |
| 7 | `function GetFOWDovFunc: String` / `procedure SetFOWDovFunc(val: String)` | `0x2a76f9` / `0x2a7721` |
| 8 | `function GetFOWDefDov: Integer` / `procedure SetFOWDefDov(val: Integer)` | `0x2a774e` / `0x2a7776` |
| 9 | `procedure GetFOWColor(var r, g, b, a: Float)` / `procedure SetFOWColor(r, g, b, a: Float)` | `0x2a77a9` / `0x2a77e1` |
| 10 | `function GetFOWLOSData(x, z: Float): Integer` | `0x2a7812` (VA `0x6a8412`) |
| 11 | `procedure SetFOWFillMaxNum(val: Integer)` / `function GetFOWFillMaxNum: Integer` | `0x2a784d` / `0x2a7881` |
| 12 | `function GetFOWDateTime: Boolean` / `procedure SetFOWDateTime(val: Boolean)` | `0x2a78ad` / `0x2a78d9` |
| 13 | `procedure FOWBuildFull` | `0x2a7906` |
| 14 | `procedure GetFOWSmooth(var pcfsmooth: boolean; var pcffactor: float; var aasmooth: boolean; var aafactor: float)` / `procedure SetFOWSmooth(...)` | `0x2a7929` / `0x2a79a5` |

`[D]` Allocate/combine loops live behind entries 5-8 + 10-11. Script contributes viewer/object **sets** plus one scalar radius per viewer via entry 7; the engine allocates the grid, walks viewers × cells, combines, and answers entry 10. Entries 2/3/4/8/9/11/12/14 are **engine-default-only** tuning surface, never ported until measured (§4 P0).

### 2.3 Port anchor register — read-only this worker, line drift flagged `[O]`

Upstream reports cite a **551-line** snapshot (`DEC_U_fow_grid.md`, `_persist.md`, `_knobs.md`, `_tint.md`) and an **804-line** snapshot (`DEC_U_fog_territory.md`). The file read this pass is materially longer — key symbols now sit at `:618`-`:1295`. **Line numbers are unstable; use the symbol name, re-read at apply time.** Nothing below was edited.

| Symbol (stable anchor) | Current line (read this pass) | Upstream snapshot line(s) | Role |
|---|---|---|---|
| `ALPHA_UNEXPLORED/EXPLORED/VISIBLE` | `:618-620` (`0.78/0.30/0.00`) | `:118-120` | port alpha ladder — `PORT APPROXIMATION` |
| `FOG_Y_OFFSET` | `:623` | `:66` | port overlay offset |
| `DONOR_VISION_BASE/PER_POINT`, `DONOR_FOGREVEAL_TAG` | `:625-628` (`20.0/4.0/109`) | `:232-234` | closed `[O]` coefficients — **do not touch** |
| `fog_explored / fog_vis / fog_counts` | `:632-634` | `:75-77` | port arrays — port inventions, never donor names |
| `bind()` / `sync()` | `:659` / `:709` | `:102-149` / `:152-160` | port lifecycle; per-tick cadence is PORT law |
| `_update_fog()` viewer disc loop / fogreveal disc loop / combine / commit | `:914-945` / `:945` / `:955` / `:957` | `:327-337`/`:361-370`/`:374`/`:375-376` (551) and `:507-544`/`:542`/`:543-544` (804) | reveal → count → commit order; `fog_counts>0`, `fog_explored[i]=1` |
| `rebuild_fow_enable()` / `_fow_viewer_players()` | `:992` / `:1072` | `:411-429`/`:411-448` (551), `:579-673` (804) | viewer/team set — grounded shape |
| `donor_unit_vision()` | `:1198` | `:461-477` (551), `:709-726` (804) | `floor(20+4*vision)` / `floor(dx)` — closed `[O]` |
| `_vision_radius_m()` | `:1221` | `:480-486` (551), `:729-737` (804) | **provisional `1 res = 1 m` driver** |
| `get_or_create_fog_reveal()` / `remove_fog_reveal()` | `:1245` / `:1259` | `:489-521` (551), `:750-781` (804) | closed `[O]` plumbing mirror |
| `rebuild_fow_full()` | `:1269` | `:523-530` (551), `:750-781` (804) | full-recompute mirror |
| `los_at()` / `is_visible_at()` | `:1279` / `:1295` | `:533-544`/`:547-550` (551), `:784-803` (804) | `>0` veto — grounded |

`hud.gd` anchors are carried from `DEC_U_fow_tint.md §6` and were **not** re-read this pass (`:2216-2218` never-seen `×0.25` dim; `:1-37` header; `:177-223` constants; `:1948-1953,2082-2084` white `.sel`) — re-read before applying any outcome in §6.

---

## 3. One fixed-seed owner session — setup and admissibility (pin before any run)

### 3.1 Pin / seed / fixture / camera

1. **Donor pin (text authority only):** `t_87f0f3c130b0`, sha256 `87f0f3c130b0…4e16c`, 5,768,048 B. Re-hash read-only; **never execute by a worker**. The owner launches the retail install themselves.
2. **Seed:** literal `S = 20261113` (acceptance pin, `PORT1TO1_endgame_protocol.md §1.1`: `gameplay.random_seed`, CLI `--seed 20261113`). **Never `--seed random`** (Class-N1), **never** the menu Random button (N2). Assert the seed in the run log.
3. **Fixture:** pinned skirmish fixture `land/med/plains`, peacetime 0, AI passive (`PORT1TO1_endgame_protocol.md §1.2`), or the 240×240 donor-backend random map from the pinned capture config. **Record which one; never compare across fixtures within one zero-mismatch claim.** No map geometry, hill height or forest density is invented here — interposition rows in §4 P3 use whatever the chosen fixture actually contains, logged by surveyed coordinates.
4. **Camera:** gameplay camera pinned `SphereHeight/SphereLength=58`, `Min=20`, pitch `-32°`, focal `400` (`camera.cfg:6-10,32-35,44-45`); `DynFogDepth=False` so visual fog never confounds a readout. One fixed camera target for the whole session; log pose at every dump.
5. **Port-side config (for the optional lane-B repeat only):** temp copy of `variant3d/config_donor_capture.json`, bytes + SHA-256 recorded before and after; `fov_deg=17.27` is a **PORT APPROXIMATION**, never a donor fact. Lane B requires the D0 preflight of `PORT1TO1_endgame_protocol.md §1.1:5`; if `--deterministic-capture`/`--capture-ticks` are absent, lane B is unavailable and the FOW packet stays donor-runtime/owner-only `[U]`. **Workers run neither lane.**

### 3.2 Class-N admissibility (from `PORT1TO1_determinism_audit.md §§1-6`)

Log an explicit "no Class-N path active" assertion per run. Hazards: N1 `--seed random`; N2 menu Random; N3 fisher `randf()` (`game.gd:8127-8130` — any fishing delivery is inadmissible); N4 audio (disable for pixel arms); N5 wall-clock watchdog; N6 frame-paced stepping; N7 async-load yields; N8 800×600 GPU fallback; **N9 save/load seed rewrite (`game.gd:9334-9335`)**.

> **N9 caveat, load-bearing for §4 P4:** the persistence arm deliberately performs **save + reload**. That arm is a **donor-runtime (lane A)** capture. It must **not** be fed into a lane-B deterministic-capture hash claim, where N9 would rewrite the seed. If a port-internal save/reload repeat is attempted, assert and log the seed before and after; a rewritten seed makes that repeat inadmissible, not a mismatch to be averaged.

### 3.3 Session-wide logging contract (every arm)

Each dump record carries: `{run_id, seed, config_sha256, fixture_id, tick, camera_pose, viewer_set_count, per_viewer_res[], FOWBuildFull_flag, knob_getter_values, readout_kind, raw_values[]}`. For grid/combine/occlusion/persistence/sampler arms the readout is **script `GetFOWLOSData(x,z)` dumps only — no pixels**: `FOWSmooth`/PCF (`K8`) moves a rendered edge without moving the script grid, so a pixel edge would mis-measure the grid. Pixel probes are used **only** in §4 P6, always paired with a script `GetFOWLOSData` read at the same cell centre.

**Dash rule:** never adjust `FOWElevation` (K1), `FOWLerpFactor` (K2), `FOWFillMaxNum` (K6), `FOWSmooth` (K8) or any other knob from defaults during P1-P5. Call each readable getter (`GetFOWElevation`, `GetFOWLerpFactor`, `GetFOWTextured`, `GetFOWDefDov`, `GetFOWColor`, `GetFOWFillMaxNum`, `GetFOWDateTime`, `GetFOWSmooth`) once per run (§4 P0) and ship the log. **Defaults are observed, never chosen.**

---

## 4. ONE ordered owner session with controlled reveal transects (★ = stop-and-gate)

Tooling: debugger with execution breakpoints (x64dbg / WinDbg) plus script-side dump hooks. One launch, one map, one seed. No donor file is written. Each phase ends with a ★ verdict gate; a failed gate records the divergent dump verbatim and leaves that field `[U]` — it never "close"s and never authorises a port constant.

### P0 — session gating and knob-default log (★ gate for everything)

1. Launch under the pinned seed; load the fixture; pause. Assert §3.1 pins and §3.2 Class-N exclusions.
2. Set FOW on via the shipped gate path (`_control_SetPlayer` → `_player_UpdateFOW`, `control.script:712-720`); confirm `GetFOWEnable=True`. Confirm `DynFogDepth=False`.
3. Call each FOW `Get*` knob once; log values with `run_id`. **No `Set*` calls in P1-P5.**
4. ★ **Gate:** any pin mismatch, Class-N path active, or missing knob log ⇒ session void for that run. Record and restart at the same seed; do not proceed with a void session.

### P1 — E-GRID-a: cell size via reveal-footprint stepping (★)

5. One peasant at map centre, no blockers, known `vision`. For each case `vision 0/3/8` (predict `res = 20/32/52`) and `map_revealZone` fogreveal radius `R = 10/20/30` (predict `floor(dx) = R`), run `FOWBuildFull` + one settled tick, then dump `GetFOWLOSData(x,z)` on **two perpendicular transects** through the viewer at **1.0-unit steps**, spanning `±(res + 8)` world units.
6. Repeat **one** transect across the predicted edge at **0.25-unit steps** to expose quantisation; log raw integers at every step.
7. ★ **Verdict:** all six radii fit **one linear scale `k`** (world-units per `res`) with **0 transect cells mismatching** `dist <= k*res` on the coarse passes **and** the fine pass shows a **single stable step width equal to the cell size with 0 off-step cells**. Report `k` + cell width + whether `res` is in metres or already in map tiles (`[D]` convert via `Data.TILE_M` only if the fit forces it). Otherwise `[U]`. **No `1.0`, `2.0`, `53.333`, `0.5` or one-tile value may be written into the port from this phase without the fit.**

### P2 — E-GRID-b: combine via overlapping viewers (★)

8. Two identical peasants (`res` from P1), separation `d ≈ 0.75 × diameter` so discs overlap. Dump the transect through both centres **plus the perpendicular bisector**. `[D]` note: max vs sum is **not** distinguishable for binary visibility — use stacking below, do not claim otherwise.
9. **Stacking:** three peasants co-located; remove one at a time with `FOWBuildFull` + settled tick between removals; dump the probe cell each time. Boolean-OR/max keeps it visible until the last viewer leaves; a counted/threshold>1 rule drops it earlier. Log `GetFOWFillMaxNum` and `GetFOWDefDov`; if the cap is small (below viewer count), repeat the stacking arm at a raised `SetFOWFillMaxNum` and report whether the drop-out point moves — **this is the only permitted knob write, and only inside this arm**.
10. **Team split:** same-team ally as second viewer (predict extends per `player.script:464-473`) vs enemy viewer (predict **no** extension for player 0's dump).
11. ★ **Verdict:** union-shape match on the pair transect **AND** removal sequence matches Boolean-OR (or a stated threshold `N`, with fill-cap dependence stated) **AND** ally/enemy split matches, with **0 mismatching cells across all sub-runs**. Else `[U]`.

### P3 — E-GRID-c: occlusion via terrain/building heights (★)

12. Fix P1 geometry (one viewer, known `res`). Control run with no interposition on the same seed. Then interpose in turn: (i) a hill ridge between viewer and far transect half, (ii) a forest block, (iii) a built wall/building row. Dump the **same transect** each time; use only coordinates actually present in the logged fixture.
13. Log `GetFOWElevation` default; **do not change it**. If an interposition shortens/shadows the run, map the shadow edge at 1.0-unit steps and fit the blocker rule (height-slope vs hard block), then confirm on a **second, rotated transect**.
14. ★ **Verdict:** all three interpositions **cell-identical to control (0 mismatches)** ⇒ pure-radius disc, closed as `[O]`-by-experiment. Otherwise the fitted rule must predict the rotated transect with **0 mismatches**. **Never write a slope, a blocker list, or a `FOWElevation` effect without that second-transect confirmation.**

### P4 — E-GRID-d / E-PERSIST-d: explored persistence via player switch and save/reload (★)

15. Viewer reveals a far probe cell; confirm `GetFOWLOSData > 0`. For each arm, `FOWBuildFull` + settled tick before dumping the probe **raw** integer:
    - (i) walk the viewer away beyond `res` + margin;
    - (ii) `_control_SetPlayer` round-trip (switch player and back — exercises `ClearFOWPlayers` at `player.script:460`); log **both legs**;
    - (iii) balloon / victory gate where scriptable (`bballoon:=True`, `victorystate` set, `gbool_editor_fogofwar:=False` per `player.script:455-459`);
    - (iv) kill the viewer (exercises the `res:=0` dead arm, **not** `DelFOWObjects`);
    - (v) **save + reload** in the donor session (`onload.inc:49`, `onloadfull.inc:47-52` fogreveal re-merge vs explored-cell restore; `onsave.inc` has no fog payload) — lane A only, N9 caveat §3.2.
16. **Per-player vs global:** dump the same probe cell immediately after switching the viewing player to an **ally** vs an **enemy**.
17. ★ **Verdict:** the full (i)+(ii)+(iii)+(iv)+(v)+ally/enemy matrix dumps **identically on two repeats with 0 mismatches**, yielding one verdict — sticky-explored vs visible-only, per-player vs global, and exactly which trigger clears what. Any flapping cell keeps `[U]`. This is a **script-dump + save-reload capture, not a pixel compare.** Also confirm the `DEC_U_fog_territory.md` finding: capture/transfer itself issues **no** FOW invalidation — if a cell changes at the capture tick with no recompute, that is itself a finding to quote, never to smooth over.

### P5 — E-GRID-e: `GetFOWLOSData` sampling domain (★)

18. On the P1 single-viewer setup, dump a **0.25-unit** fine transect across the visibility edge; log **raw `Integer` returns**, not just `>0`.
19. Test: repeated dumps in the same tick (stability); dumps just inside/outside tile borders (point-sample vs cell-area); any value ever `>1` (count vs boolean). The E-GRID-b arms inform the count hypothesis.
20. ★ **Verdict:** raw domain enumerated (e.g. exactly `{0,1}`, or counts) with **0 out-of-domain values** over the full fine transect **×3 repeats**, and the edge cell matches the stated point-vs-area rule with **0 mismatches**. The only portable port predicate remains the grounded `>0` until then.

### P6 — F1-MINI-TINT: minimap pixel probes (★; pixel arm only)

21. Mark three cells: (a) never-seen, (b) seen-now (viewer in range), (c) explored-not-visible (viewer walked away beyond `res` + margin). Fixed camera. Capture the **240² panel** at native resolution (live rect from `initminimap.inc:27-40`: `ViewerW − 240·scale − 8, −8`; `scale = 2 iff ViewerHeight > 1535 else 1` per `gui.script:140-162`) **and** dump `GetFOWLOSData` at each cell centre. Record exact panel RGBA per set.
22. Repeat at **both DPI arms** (viewer height above/below 1535). Where the criterion mandates 3 runs, repeat the identical packet at two further recorded seeds; do not pool seeds.
23. **Resource recheck (paired control):** for a `gc_baseid_res` row at the same three cells, sample `GetGUIElementUserBlend(hud_img)` + icon presence. Expected `1.0 / 0.5 / hidden` per `gui.script:3478-3491`; a failure reopens that arm but does **not** close terrain.
24. ★ **Verdict:** the three pixel sets are **pairwise disjoint with 0 misclassified samples** across all runs × both DPI arms, **and** per-cell `GetFOWLOSData` reads match the `>0` law on every sample. Report exact RGBA per set + the separating threshold, or keep `[U]`. **No RGBA, threshold or blend factor enters the port before this terminates.** `FOWColor` is engine-default-only with zero writers (`K5`) and cannot ground a panel colour.

**Session close:** export breakpoint/dump log + all transects + knob-default log + panel captures, each tagged with `run_id`, seed, config SHA-256, fixture and camera pose. One launch, one map, one canonical seed.

---

## 5. Zero-mismatch termination criteria (no partial credit)

A `[U]` item retires **iff** its stated pattern repeats with **0 differing cells / 0 out-of-domain values / 0 px membership errors** across the minimum repeats below, on the same seed/fixture/camera and with the same knob defaults. Any mismatch, missing dump, void session, Class-N path or cross-fixture comparison leaves it `[U]`. "Close" never counts.

| Item | Pattern that must repeat | Minimum sample / repeats |
|---|---|---|
| F-GRID-a (cell size) | one linear scale `k`; `dist<=k*res` matches on coarse transects; fine pass single stable step width | 6 radii (vision 0/3/8 + reveal R=10/20/30) × 2 perpendicular coarse transects + 1 fine transect; 0 off-step cells |
| F-GRID-b (combine) | union shape + Boolean-OR/threshold-N removal + ally/enemy split | pair transect + bisector + 3-viewer removal + team split; 0 mismatching cells across all sub-runs |
| F-GRID-b (fill-cap / default-radius) | drop-out point moves iff cap changed; radius follows `FOWDefDov` only if forced | stacking arm at raised `SetFOWFillMaxNum`; 0 unexplained cells |
| F-GRID-c (occlusion) | cell-identical to control ⇒ pure disc; else blocker rule predicts rotated transect | control + 3 interpositions + 1 rotated transect; 0 mismatches |
| F-GRID-d / persistence | full walk-away / player-switch / balloon-victory / kill / save-reload / ally-enemy matrix | entire matrix × 2 repeats; 0 flapping cells |
| F-GRID-e (sampler domain) | domain enumerated; 0 out-of-domain values; edge cell matches point/area rule | fine transect × 3 repeats, raw integers |
| E-KNOB-defaults | identical getter values across the P1 control setup | P1 × 3 repeats; 0 mismatches; no flapping value gains a port constant |
| F1-MINI-TINT-TERRAIN | three pixel sets pairwise disjoint; per-cell reads match `>0` | 3 runs × both DPI arms; 0 misclassified samples; exact RGBA + threshold reported |
| F1-MINI-RESOURCE-RECHECK | `1.0 / 0.5 / hidden` per cell class | every sampled resource row; failure reopens only this arm |
| Capture/territory (E-FOGT) | no cell changes at capture tick without recompute; name-swap `.<oldColor>`→`.<newColor>` with static blip position | 3 identical-seed runs; divergent dump quoted, never averaged |

Even after a clean termination: `parity.status="UNVERIFIED"`, `parity.claim=NONE`, `visual_parity_claim=false`; a matched-seed donor-vs-port GPU A/B frame is still required before any parity statement. Six-condition chain stays **0/6 CLOSED**.

---

## 6. Outcome → exact port change (owner/COORD applies; NO edits made here)

Each row fires **only** on its own zero-mismatch termination. Use the **symbol** column as the primary anchor; the listed current lines (read this pass) and upstream snapshot lines are advisory because the file drifts (§2.3). All changes land in `variant3d/scripts/world3d_fog.gd` unless `hud.gd` is named. `hud.gd` lines are carried from `DEC_U_fow_tint.md §6`, not re-read here.

| Terminating outcome | Exact port change | What stays `[U]` / hard-failed |
|---|---|---|
| **a: `res` in world units, scale `k`** | Replace `_vision_radius_m` (`:1221`; upstream `:480-486`/`:729-737`) body `return float(res)` with `return float(res) * GRID_K`; add `DONOR_FOW_METRES_PER_RES := <k>` and `DONOR_FOW_CELL_M := <step>` citing the experiment id; re-label the provisional comment. Mirror the scale into both reveal loops in `_update_fog` (`:914-945`; upstream `:327-337`/`:361-370`) | Wrong/partial fit ⇒ driver stays `1 res = 1 m` and labelled; no hard-coded 1.0/2.0/53.333 |
| **a: `res` already in map tiles** | Convert at the same `_vision_radius_m` site via `Data.TILE_M` (only if the fit forces it); do **not** introduce a metres constant | Any tile size not from the fit stays `[U]` |
| **b: Boolean-OR / max** | Keep `fog_counts[i] > 0` (`:955`; upstream `:374`/`:542`); re-label the `[U]` comment at `_update_fog` to grounded-OR with experiment id | No threshold/per-team structure added |
| **b: threshold `N`** | Replace the single `fog_counts` accumulation (`:914-955`; upstream `:339,355-359,361-370,374`) with the fitted operator; keep `fog_explored` sticky logic untouched unless P4 says otherwise | `N` not captured ⇒ no threshold |
| **b: per-team channels** | Replace the single `fog_counts` array (`:634`) with per-team arrays + the fitted compare; keep `_fow_viewer_players` (`:1072`) team law intact | Team key not captured ⇒ no per-team array |
| **b: `FOWFillMaxNum` is a live cap** | Add a `fill_max_num` clamp at the accumulation site, defaulting to the dumped `GetFOWFillMaxNum` value; cite E-GRID-b | Never a guessed cap; no effect ⇒ no clamp |
| **b: `FOWDefDov` is the unset-callback radius** | Document it at `donor_unit_vision` (`:1198`) as a fallback return defaulting to the dumped `GetFOWDefDov` value | Never mirrored without its arm |
| **c: pure-radius disc** | Add one negative-result comment at the viewer disc loop (`:914-945`; upstream `:355-359`) with experiment id; **no code change** | No blocker test added; `FOWElevation` still log-only |
| **c: blocker rule confirmed on rotated transect** | Insert the fitted blocker test inside the viewer disc loop (`:914-945`) and, **only if** fogreveal also occludes, the fogreveal loop (`:945`), using the port height/blocker grid actually present. `FOWElevation` gets no counterpart until measured. Keep `los_at` (`:1279`) reading the same grid the reveal pass writes | No slope/blocker list from a single transect; no `FOWElevation` constant |
| **d: sticky-explored, per-player or global stated** | Keep `fog_explored[i]=1` (`:957`; upstream `:375-376`/`:543-544`); document per-player-vs-global at the commit block (`_update_fog`, `:955-957`) | Untested trigger stays un-wired |
| **d: visible-only / a trigger clears cells** | Change `:957` to clear/set per the verdict; wire `rebuild_fow_full` (`:1269`) and `rebuild_fow_enable` (`:992`) to **only** the discovered triggers (e.g. `ClearFOWPlayers` on player switch clears per-player visible but not global explored; victory/balloon clears all; death clears nothing because corpses use `res:=0`; save-reload restores explored **iff** the save arm proves it) | Any unwired trigger stays `[U]`; no explored restore without the save arm |
| **d: map-load re-merge** (script `[O]`, no experiment needed) | Add a `load_remerge` loop at `bind()` (`:659`) re-registering persisted tag-109 reveal records via the existing `fog_reveals` array before the first `_update_fog()`, citing `onloadfull.inc:47-52`. No explored-cell restore until the save arm terminates | No grid law change |
| **e: domain `{0,1}` boolean point-sample** | Keep `los_at` (`:1279`) `>0` predicate (grounded by `control.script:270`); re-label the comment only | No count accessor |
| **e: counts / cell-area** | Expose a second accessor (e.g. `los_count_at`) without changing the `>0` veto in `is_visible_at` (`:1295`); document point-vs-cell-area at `los_at` using cell geometry from P1 | Veto is never weakened to no-veto |
| **P6: tint RGBA/threshold measured** | Replace `hud.gd:2216-2218 ×0.25` never-seen dim + `minimap_fog_base/minimap_fog_rev` cache, and `world3d_fog.gd` alpha ladder `ALPHA_UNEXPLORED/EXPLORED/VISIBLE` (`:618-620`) + `_make_fog_material` shader (`:741`), with the measured RGBA/threshold 1:1; cite experiment id. Resource `1.0/0.5` stays the only donor-grounded blend and is **never** extended to units or terrain | Never port `FOWColor`/`FOWTextured`/`FOWSmooth`/`FOWLerpFactor`/`FOWDateTime` as grid law; no RGBA before P6 |
| **knob defaults logged** | Add only the observed default values as documented constants, each citing E-KNOB-defaults and the getter that produced it | Any flapping value gets **no** port constant |

**Do-not-touch list (closed `[O]` or port-state encodings; F1-GRID changes must not alter them):** `donor_unit_vision` (`:1198`; coefficients `:625-628`), `rebuild_fow_enable` / `_fow_viewer_players` (`:992`/`:1072`), fogreveal create/remove (`:1245`/`:1259`), reveal→count→commit order in `_update_fog` (`:827-957`), alpha ladder (`:618-620`) and `FOG_Y_OFFSET` (`:623`) **until P6**, overlay build (`:764`). **Never add `rebuild_fow_full()` or any cell invalidation to a capture/transfer function** (`DEC_U_fog_territory.md §6.1`): donor capture issues none, and recompute is engine-lazy on the next poll.

---

## 7. Hard-fail / forbidden-substitute matrix (no cell size, slope or colour invented)

Any ✗ means the gap may **not** be filled by the port. Absence of a capture is not permission to invent.

| Forbidden substitute ↓ / Gap → | cell size unknown | combine unknown | occlusion unknown | persistence unknown | sampler unknown | tint unknown |
|---|---|---|---|---|---|---|
| `1 res = 1 m` / `2 m` / `53.333`-derived / one map tile presented as donor | ✗ | — | — | — | — | — |
| max/OR/threshold/per-team asserted without P2 | — | ✗ | — | — | — | — |
| `FOWFillMaxNum`/`FOWDefDov`/`FOWElevation` constant without its arm | — | ✗ | ✗ | — | — | — |
| Height/forest/wall slope or blocker list from one transect | — | — | ✗ | — | — | — |
| Sticky-explored / decay / per-player / global asserted without P4 | — | — | — | ✗ | — | — |
| Explored clear added on capture or on an untested trigger | — | — | — | ✗ | — | — |
| Explored-cell restore added to save/load without the save arm | — | — | — | ✗ | — | — |
| `GetFOWLOSData` domain beyond grounded `>0`; weakened/no veto | — | — | — | — | ✗ | — |
| Panel RGBA/threshold, `FOWColor`, `CriticalColor`-as-tint, `colors.lib Fog=…` presented as minimap tint | — | — | — | — | — | ✗ |
| Resource `0.5` blend extended to units or panel terrain | — | — | — | — | — | ✗ |
| `.sel` RGB invented (baked pixels live in `primitives.bmp`, 16,440 B, never decoded here); `Interval = 50` given unforced units | — | — | — | — | — | ✗ |
| Port per-tick FOW rebuild asserted as donor (donor has 6 `UpdateFOW` sites, zero per-frame) | — | — | — | ✗ | — | — |

Telemetry rule throughout: `visual_parity_claim=false`; each retired sub-item flips to `[D]+capture-id` **with its measured tuple**; everything else keeps `[U]` and the phase that would settle it.

---

## 8. Status until the owner executes §3-§4 (explicit, non-negotiable)

- **P0-3 stays open.** The port keeps the labelled provisional `1 res = 1 m` driver (`_vision_radius_m`, `:1221`), `fog_counts > 0` combine (`:955`) and sticky `fog_explored[i]=1` (`:957`) as **PORT APPROXIMATION / PORT law**, never donor claims.
- **No cell size, combine operator, occlusion slope, explored lifetime, LOS return domain, tint colour/threshold or knob default is adopted by this report.** No port constant is added on the strength of a static read.
- **Donor runtime remains forbidden to workers.** No donor binary was executed, no GPU frame captured, no debugger/tracer attached, no Godot/gate/runner job launched, no save/reload performed by this worker.
- **Parity UNVERIFIED.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; six-condition chain **0/6 CLOSED**; no donor GPU A/B frame; `blocking_unverified` non-empty ⇒ **`RESULT IS NOT GOOD`**. Even a fully terminated FOW packet leaves parity unverified until a matched-seed donor-vs-port frame comparison exists.

---

## 9. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared, no gate run. All donor facts are re-carried `[O]/[D]` from the pinned upstream reports; native VAs/file-offs/evidence ids are quoted, not re-lifted here.
- **No approximation supplied.** This packet chooses no texture, cell size, slope, blocker list, operator, threshold, lifetime, domain, RGBA, blend, knob default or time value. The port's current labelled posture is endorsed as the honest behaviour until a zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md`. No source/shader/asset/config/test/fixture/result-JSON/git/Godot state touched. The active donor target was never opened/selected/closed by this worker; no Craft Anything native call was made; no investigation memory was written.

*End of PORT1TO1-FOW-OWNER-PROTOCOL. Read-only; exactly one repository file written; no donor execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
