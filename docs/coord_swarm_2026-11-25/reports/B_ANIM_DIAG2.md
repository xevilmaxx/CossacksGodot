---
id: B-ANIM-DIAG2
title: "B-ANIM-DIAG2 — read-only diagnosis: why a building peasant plays the wrong clip (current on-disk call chain)"
date: 2026-11-25
owner: B-ANIM-DIAG2 (read-only diagnosis micro-worker)
status: DELIVERED__ONE_REPORT_ONLY__NO_EDIT__NO_GODOT__NO_RUNNER__NO_GIT__NO_DONOR_ACCESS__NO_PARITY_CLAIM
scope: "Exactly one file authored (this report). No code/config/asset/test/scene edit; no Godot/Blender run, no runner job, no git operation. No donor binary read or copied: every donor citation below is CARRIED from a cited report and labelled as such."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/B_ANIM_DIAG2.md"
labels: [observed, derived, inferred, UNVERIFIED]
governing_rule: "Cite repo path:line; carry donor path:line only through a cited report; separate observed/derived/inferred/UNVERIFIED; never claim donor parity (DANIM_01 frontmatter :12; BUILD_ANIM_DIAG_01 frontmatter :12)."
verdict: "The briefing premise is STALE relative to the on-disk tree. PROGRESS play2-03 (2026-11-24) recorded a 3-action request set and no construct skin frames; both load-bearing fixes have since LANDED (world3d_entities.gd:1183-1191 requests construct for build/repair under the speed gate; convert_skins.py:80-81 and peasant.json:1 export construct frames [186,188,191,193,196,198]). A stationary building peasant therefore resolves 'construct' to real construct frames today (derived from code+JSON; rendered result UNVERIFIED). Remaining wrong-clip cases are gather/resow/carry/attack (no branch -> idle/walk), a builder still travelling (walk by gate), and stale status constants at world3d_entities.gd:194-198. NO new build fix is required."
---

# B-ANIM-DIAG2 — why a building peasant plays the wrong clip

## 0. Headline answer, bounded

- **Stale premise (observed vs briefing):** the brief describes
  `world3d_entities.gd` as asking only `dead/moving/else → death/walk/idle`.
  That is verbatim the 2026-11-24 note at
  `docs/coord_swarm_2026-11-24/PROGRESS.md:335-337` ("renderer asks only 3
  actions … gather/build/carry/attack all play idle/walk"). It is **not** the
  current on-disk code: `_unit_action()` now has a build/repair → `construct`
  branch (`world3d_entities.gd:1183-1191`), and the shipped peasant skin now
  carries `construct` (`variant3d/assets/models/skin/peasant.json:1`,
  `actions.construct.frames`).
- **Therefore (derived from code + JSON, not a rendered observation):** the
  original two-cause failure recorded in `BUILD_ANIM_DIAG_01.md:13,190-203`
  (missing action branch + missing skin frames) is **closed on disk**. A
  stationary, build-ordered peasant requests `"construct"` and resolves to
  donor frames 186/188/191/193/196/198. Visual correctness, parity and
  engine behaviour remain **UNVERIFIED**.
- **What is still wrong:** gather/resow/carry/attack have no branch in
  `_unit_action()` (`world3d_entities.gd:1192-1196`) and play `idle`/`walk`;
  a builder still travelling plays `walk` by the speed gate
  (`:1187-1188` → `:1192-1193`); the status constant at `:194-198` still
  claims the skins lack `construct` frames (now false — derived from
  `peasant.json:1`). These are separate from the build symptom.
- No parity or rendered-frame claim is made. All deformation stays
  `PORT APPROXIMATION — NOT DONOR PARITY` / `visual = "UNVERIFIED"`
  (`anim3d.gd:63,178,524`; `world3d_entities.gd:188-191`).

---

## 1. Sources read (all read-only; no donor access)

| # | Source (path:line) | Use |
|---|---|---|
| S1 | `variant3d/scripts/game.gd:2332,3209-3236,3249,3251-3256,4551,5528` | sim order/carry fields |
| S2 | `variant3d/scripts/world3d_entities.gd:192-198,217,1174-1196,1991-1996,2037-2045,2048-2061,2071-2075,2103-2104,2270` | 3D presentation feed |
| S3 | `variant3d/scripts/anim3d.gd:63,71-96,489-530,534-556,582-588,860,893-912,918-953` | clip table, lookup, fallback |
| S4 | `variant3d/assets/models/skin/peasant.json:1` (single-line JSON; field paths quoted) | shipped peasant action keys/frames |
| S5 | `variant3d/assets/models/skin/index.json:1` (single-line JSON; field paths quoted) | `actions_requested`, peasant entry |
| S6 | `variant3d/tools/convert_skins.py:72-81,148,221,287,314` | skin export action set |
| S7 | `variant3d/scripts/world.gd:470-499,537-555` | 2D sibling, 14 clip classes |
| S8 | `docs/coord_swarm_2026-11-24/PROGRESS.md:329-343` | the stale PLAY2-03 premise |
| S9 | `docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md:13,190-213,236-251` | two-cause diagnosis (carried) |
| S10 | `docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_02.md:13,76-91` | construct skin regen result (carried) |
| S11 | `docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md:110,159,205-207,322-332,398-405` | 62 names / donor map / ranges (carried) |
| S12 | `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:297,299,317,464` | owner/landed status |

---

## 2. Exact call chain (observed on disk)

### 2.1 Sim build command
`game.gd:3251-3256` `cmd_build()` checks `e.sid == "peasant"` then sets
`e.order = {"type":"build","target":site.id}` (`:3255`) and `e.moving = true`
(`:3256`). Repair sets `{"type":"repair",...}` (`:4551`). Gather sets
`{"type":"gather","res":<res>,"node":...}` (`:3228,:3235,:5044,:5594`); resow
sets `{"type":"resow",...}` (`:3249`). Carry state is `e.carry`/`e.carry_type`
(default at `:2332`, written at `:5528`). **Observed:** the sim supplies all
three signals; none is a `construct`-named flag.

### 2.2 `world3d_entities.sync()` → requested action string
- `sync()` advances one clock: `_anim_t += maxf(dt,0.0)` (`:1991,:1996`).
- Per unit: `speed := _measure_speed(uid, ed)` (`:2037`, method `:1203-1214`),
  then `action := _unit_action(ed, speed)` (`:2044`) and telemetry
  `rendered_actions[action]` (`:2045`, exported at `:2270`).
- `_unit_action()` (`:1174-1196`), **the entire selection policy**:
  - `dead` → `"death"` (`:1175-1176`);
  - `order.type in ["build","repair"]` **and** measured `speed < 0.15`
    (`WALK_SPEED_GATE_M_S`, `:217`) → `"construct"` (`:1183-1189`);
    without a measurement, `not moving` → `"construct"` (`:1190-1191`);
  - otherwise `speed >= 0` → `"walk"` if `speed >= gate` else `"idle"`
    (`:1192-1193`); legacy `moving` fallback → `"walk"`/`"idle"`
    (`:1194-1196`).

  | Entity state | Requested string today | Citation |
  |---|---|---|
  | build/repair, stationary (speed < gate) | `"construct"` | `:1186-1189` |
  | build/repair, still travelling (speed ≥ gate) | `"walk"` | `:1187-1188` → `:1192-1193` |
  | gather / resow (any speed) | `"walk"` or `"idle"` — **no branch** | `:1192-1196` |
  | carry (`carry>0`, `carry_type` set) | `"walk"` or `"idle"` — **no branch** | `:1192-1196` |
  | attack order | `"walk"` or `"idle"` — **no branch** | `:1192-1196` |

- Pose is requested via `anim.call("pose_for", ed, action, _anim_t)`
  (`:2054`) only when `has_skin(sid)` (`:2048-2049`); accepted only when
  `pose_source == "donor_flat_root_morph"` (`:2058-2061`); batch key includes
  `|a<action>|f<frame>` (`:2071-2075`). Rejected poses fall through to
  `static_units += 1` (`:2103-2104`), i.e. the un-morphed base mesh.

### 2.3 `anim3d` lookup
- `pose_for()` (`:489-530`): alias `attack→attack0` only (`ACTION_ALIAS`,
  `:94-96`), `row := _action_range_for(sid, donor_action)` (`:497`),
  `frame := _frame_at(first,last,t)` (`:507`, implementation `:582-588`,
  deterministic `fposmod` loop), payload `visual = "UNVERIFIED"` (`:524`).
- Clip tables: `AAF_ACTIONS` peaukr table (`:71-90`) with `construct`
  `[186,198,17,"morph"]` at `:86`, `workfood/workwood/workstone` at `:77-79`,
  carry variants `idlefood/idlewood/idlestone`, `walkfood/walkwood/walkstone`
  at `:80-85`. `_action_range_for()` (`:918-934`) prefers the per-sid compact
  skin action (`:921-931`) and falls back to the peaukr table (`:932-934`).
- Compact sampling: shipped skins are normalised with `compact = true`
  (`:860`); `_morph_fields()` maps donor frame → exported frame via
  `_nearest_exported_frame()` (`:546`; `:907-912` + `_nearest_local` `:893-904`).

### 2.4 Shipped peasant skin keys / frames (observed, JSON field paths)
`peasant.json:1` `actions` keys =
`idle, idle0, walk, death, attack0, construct` — **six**.
`construct` = `first 186, last 198, donor "data/animations/aaf/peaukr.aaf:17",
frames [186,188,191,193,196,198]`; `idle` `[64,74,84,93,103,113]`,
`walk` `[1,5,9,12,16,20]`, `death` `[115,...,149]`, `attack0` `[237,...,254]`.
Union `frames` has 30 entries including the six construct frames.
**Absent:** `workfood/workwood/workstone` and all six carry idles/walks.
`index.json:1` `actions_requested` =
`[idle,idle0,walk,walk0,death,attack0,attack1,construct]`; peasant entry
`frame_count = 30`. `convert_skins.py:80-81` `DEFAULT_ACTIONS` includes
`construct`. This is the landed result reported at `BUILD_SKIN_02.md:76-91`.

### 2.5 Fallback when an action/clip is missing
1. Action absent from skin **and** from `AAF_ACTIONS` → `_action_range_for()`
   returns `[]` (`:932-933`) → `pose_for()` returns `_unknown()`
   (`:498-503`, definition `:937-953`): `ok=false`, `frame=-1`, empty `verts`,
   `pose_source="donor_timing_only"` → rejected at `world3d_entities.gd:2061`
   → `static_units` (`:2103-2104`).
2. Action present in the AAF table but **not exported by the compact skin**
   → `_nearest_exported_frame()` snaps to the closest exported donor frame
   (`anim3d.gd:546,907-912`). **Derived from the union in `peasant.json:1`:**
   pre-regeneration `construct` snapped to death `149` / attack0 `237`
   (`BUILD_ANIM_DIAG_01.md:164-169`); today a requested `workwood` (range
   `237..254`, `anim3d.gd:78`) would resolve onto the attack0 frames, and
   `idlefood` (`405..454`, `:80`) onto the last attack0 frame `254` — i.e.
   another clip's pose. Rendered outcome **inferred/UNVERIFIED**.

---

## 3. Missing-link inventory

Sets (all **observed** except the carried donor count):
**3** historical 3D requests (`death/walk/idle`, `PROGRESS.md:335-337`) →
**4** current 3D requests (`death/construct/walk/idle`,
`world3d_entities.gd:1175-1196`) → **14** 2D clip classes
(`death, attack, workwood, workfood, workstone, construct, idlewood,
idlefood, idlestone, walkwood, walkfood, walkstone, walk, idle` —
`world.gd:471-499`) → **62** donor AAF names (carried, `DANIM_01:110`) →
**6** peasant skin action keys (`peasant.json:1`).

| Link | 3D request | 2D class | Donor name (carried) | `AAF_ACTIONS` | Peasant JSON key | Status |
|---|---|---|---|---|---|---|
| build/repair | `construct` `:1186-1189` | `construct` `world.gd:489-490` | `construct` `peaukr.aaf:17` (`DANIM_01:405`; S9/S10) | `:86` | **yes**, 6 frames | **CLOSED** (derived) |
| gather | idle/walk `:1192-1196` | `workwood/workfood/workstone` `world.gd:481-486` | `work*` `unit.script:10865-10873` (`DANIM_01:322-324`) | `:77-79` | **no** | **OPEN** ×2 |
| resow | idle/walk `:1192-1196` | `workfood` `world.gd:487-488` | `workfood` (same chain) | `:77` | **no** | **OPEN** ×2 |
| carry idle | idle `:1192-1196` | `idlewood/idlefood/idlestone` `world.gd:491-493` | `unit.script:10900-10921` (`DANIM_01:332`) | `:80-82` | **no** | **OPEN** ×2 |
| carry walk | walk `:1192-1196` | `walkwood/walkfood/walkstone` `world.gd:494-497` | same chain | `:83-85` | **no** | **OPEN** ×2 |
| attack | idle/walk `:1192-1196` | `attack` `world.gd:475-476` | `attack0` (`DANIM_01:326`) | `:76` + alias `:94-96` | **yes** | **OPEN** (request only); one-shot policy UNVERIFIED (`DANIM_01:559-563`) |
| death | `death` `:1175-1176` | `death` `world.gd:471-472` | `death` (`DANIM_01:400`) | `:75` | **yes** | Request exists; 3D reachability UNVERIFIED here (`PROGRESS.md:340-341`) |

`OPEN ×2` = missing request branch **and** missing exported frames. No parity
claim: every donor name/range above is **carried** through the cited report,
not re-probed by this worker.

---

## 4. Minimal fix and single owner per file

**For the reported build symptom: no code change is needed today.** Both
load-bearing fixes are already on disk and marked DONE
(`SWARM_BOARD.md:317,464`). Re-applying them would be a regression risk.

| Concern | One owning builder (source of truth) | Exact file:lines | Donor citation / label |
|---|---|---|---|
| Build→`construct` request | `world3d_entities.gd` — NATION-MODEL-01 (`SWARM_BOARD.md:297,464`) | `:1183-1191` — **already landed** | carried: `dmscript.global:13,926`, `unit.script:10877`, `peaukr.aaf:17` (S9 §2.1); not re-probed |
| `construct` skin frames | `convert_skins.py` + generated JSON — BUILD-SKIN-02 (`SWARM_BOARD.md:317`) | `:80-81`; `peasant.json:1 actions.construct` — **already landed** | observed JSON donor `peaukr.aaf:17`; frames `[186,188,191,193,196,198]` (S10:86) |
| `anim3d` lookup / alias | **none — no change** | `:86, :94-96, :918-934` already resolve `construct` | no donor citation needed for a no-op |
| Stale status text | `world3d_entities.gd` — same single owner NATION-MODEL-01 | `:194-198` — remove/correct the "no construct frames" claim (doc-only; not done by this worker) | derived contradiction with `peasant.json:1` |
| Gather/resow, carry, attack | `world3d_entities.gd` — same single owner NATION-MODEL-01 | `:1174-1196`: add branches mirroring `world.gd:481-488` (`work*`), `:491-497` (carry), `:475-476` (attack) | carried `unit.script:10865-10873,10900-10921` (`DANIM_01:322-332`); rendered result **UNVERIFIED** |
| Work*/carry exported frames | `convert_skins.py` — same single owner BUILD-SKIN-02 | `:80-81` add names, regenerate JSON | carried `peaukr.aaf:8-16` (`DANIM_01:402-404`); 3D visual **UNVERIFIED** |

No change is proposed for `anim3d.gd` (its table and fallback are correct);
`convert_skins.py` changes are only for the *remaining* gather/carry gaps, not
for build.

---

## 5. Cheap verification — probe recipe, NOT run

No gate, no full selftest, no Godot run by this worker. Shape: one temporary
read-only GDScript probe on a frozen peasant entity
(`sid="peasant"`, `dead=false`, `order={"type":"build","target":id}`,
`moving=true`, fixed `face`), driving `_unit_action()` and `pose_for()` at
`_anim_t = f/30` so the global clock cannot alias the frames.

1. `world3d_entities._unit_action(ed, 0.0) == "construct"` and
   `_unit_action(ed, 1.0) == "walk"` (gated travel) — citations `:1186-1193`.
2. For `f in [186,188,191,193,196,198]`:
   `pose_for(ed,"construct",f/30)` → `pose["action"]=="construct"`,
   `pose["frame"]` equals that `f` (six distinct values),
   `pose["pose_source"]=="donor_flat_root_morph"`,
   `pose["frame"] not in {149,237}` — citations `anim3d.gd:489-530,546,907-912`.
3. After one `sync(dt)` with a stationary builder:
   `rendered_actions["construct"] >= 1`, `rendered_actions["idle"] == 0`,
   batch key contains `|aconstruct|` — citations
   `world3d_entities.gd:2045,2071-2075,2270`.
4. Assert zero `SCRIPT ERROR` in the probe log. **Discriminator:** step 2
   separates a real construct sequence from an action-string-only fix
   (149/237 snapping). A negative *pixel* result is not evidence
   (`BUILD_ANIM_DIAG_01.md:253-257`, carried).

---

## 6. Labels and summary

- **Observed:** stale briefing source `PROGRESS.md:335-337`; landed build
  branch `world3d_entities.gd:1183-1191`; landed converter action
  `convert_skins.py:80-81`; six peasant skin action keys incl. `construct`
  with frames `[186,188,191,193,196,198]` (`peasant.json:1`); absent
  work*/carry keys; `anim3d` table/alias/lookup
  (`anim3d.gd:71-96,489-530,918-934`).
- **Derived:** the build chain is closed on disk; gather/resow/carry/attack
  still resolve to idle/walk; a travelling builder resolves to walk; stale
  constants at `:194-198` contradict the JSON; work*/carry requests would
  snap onto attack0/walk frames.
- **Inferred / UNVERIFIED:** any rendered appearance, one-shot/blend
  behaviour, donor visual parity, 3D death reachability, 8-azimuth
  equivalence, hammer tool and smoke. All donor facts are **carried**, not
  re-read; no donor binary was accessed by this worker.
- **No parity claim** is made. `PORT APPROXIMATION — NOT DONOR PARITY`,
  `visual = "UNVERIFIED"` retained (`anim3d.gd:63,524`;
  `world3d_entities.gd:188-191`). No code, asset, config, test, scene or git
  change was made; no Godot/Blender/runner job was started; this is the only
  file authored.

*End of B-ANIM-DIAG2 report.*
