---
id: BUILD-ANIM-01
title: "BUILD-ANIM-01 — redirected: no anim3d.gd fix needed; diagnosis and minimal fix recipe for the peasant build animation"
date: 2026-11-25
owner: BUILD-ANIM-01 (implementation builder subagent)
status: REDIRECTED__IMPLEMENTATION_WITHDRAWN__REPORT_ONLY__NO_PASS_CLAIM
scope: "After the COORD redirect, exactly one report written (this file). No source, config, asset or test file was edited by me in the final state; no Godot/Blender run and no variant-runner job was started."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
input: "docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md (landed after my initial read); DANIM_01_action_ranges.md; DANIM_02.md"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: "The donor construct clip EXISTS in the port AAF table (anim3d.gd:86). The real faults are (a) world3d_entities.gd:_unit_action() has no order.type=='build' branch and (b) convert_skins.py:69-73 exports no construct frames, so a naive action-string-only fix would snap to death 149 / attack0 237. No anim3d.gd change is required or made."
---

# BUILD-ANIM-01 — redirected report (no implementation)

## 0. What happened

I began this ticket before `reports/BUILD_ANIM_DIAG_01.md` landed and, following the
original brief ("fix build action mapping in `anim3d.gd`"), made an interim edit to
`variant3d/scripts/anim3d.gd` (added a `build → construct` alias plus an
entity-order override in `play()`/`pose_for()`). The COORD redirect then arrived:
the diagnosis proves the `anim3d.gd` mapping was **not** the fault, and I was told
to stand down, restore the file and write only this report.

**Restoration performed (observed):** `variant3d/scripts/anim3d.gd` was copied
back byte-for-byte from `inbox/backup/anim3d.gd.bak-BUILDANIM01` (the backup I
created before the interim edit).

| Check | Result |
|---|---|
| SHA-256 of restored `anim3d.gd` | `54FACBB3DF19E358E13D6C9BB3417A4A87579C1FBFAEC803FF25BA01C314C381` |
| SHA-256 of pre-edit backup | same value — byte-identical |
| `git diff --exit-code -- variant3d/scripts/anim3d.gd` | exit 0, clean |
| Files authored by me in the final state | this report only (plus the backup artifact under `inbox/backup/`, which is not a source file) |

**Explicit statements required by the redirect:** no source file was edited by me
in the final state (the sole interim edit was fully reverted above); no `PASS`
claim is made; no gate, ladder, direct `godot` or variant-runner job was executed.
The requested smoke id `buildanim01-smoke` was **NOT** run, so there is no measured
`SCRIPT ERROR` count and no parse/runtime validation result from this ticket.

---

## 1. Donor truth for the peasant build animation (cited)

| Item | Value | Citation / label |
|---|---|---|
| State tag | `gc_statetag_action_build = 1 shl 8` | `data/scripts/dmscript.global:13` (BUILD_ANIM_DIAG_01 §2.1, observed) |
| Name constant | `gc_anim_construct = 'construct'` | `data/scripts/dmscript.global:926` (observed) |
| State → name | `gc_statetag_action_build : anim := gc_anim_construct;` | `data/scripts/lib/unit.script:10877`; `data/scripts/units/unit.inc/ontagstates.inc:318` (observed) |
| AAF row | `"construct",186,198,morph` | `data/animations/aaf/peaukr.aaf:17` (observed; I re-read the donor bytes read-only during this ticket) |
| Range / cadence | inclusive **186..198**, **13 frames**, 13/30 = **0.433 s** at fps 30 from `.oss` header int #1 | derived; `DANIM_01 §3.2/§5`, `DANIM_02 §2.3`; `data/actors/units/peaukr.oss:0x4` |
| ACL binding | `From = construct` / `Name = construct` / `items[0].AnimationName = construct` / `items[1].ExecuteStateName = OnAclAnimationReachedConstruct` | `data/animations/acl/peasant.acl:2245-2252`; `.prop:54` → `acl.lib:238-239` (observed) |
| Loop | AAF has no loop flag (1,434/1,434 rows are `morph`); donor debug UI plays `construct` with `bPlayOnce=False` → **loop**, unlike attacks/deaths (`True`) | `data/gui/menu.inc/showdebuganimations.inc:143` vs `:121-131`; `DANIM_01 §4.3/§5`, `DANIM_02 §4.2`. Engine semantics **UNVERIFIED** |
| Attached tool | same action name selects the single-bone hammer `.oss` (`gc_actor_peasant_hammer`) | `data/scripts/lib/unit.script:7008`; `unit.script:6993-7009` (observed) |
| Smoke | separate site PFX family, **not** part of the `construct` row/ACL | `buildsmoke*.actor`, `pfxbuildsmoke*.aaf` idle 1..90 (BUILD_ANIM_DIAG_01 §2.1, observed) |
| Azimuth | donor 8 azimuths are camera views (`bake_sprites.py:218-238`), never an AAF action | inferred/observed; equivalence to 3D continuous yaw **UNVERIFIED** |

The donor clip is therefore **`construct`, 186..198, 30 fps, looping**, and the
port's own AAF table already encodes exactly that:
`anim3d.gd:86 → "construct": [186, 198, 17, "morph"]`. The "missing clip"
hypothesis is **REFUTED** (`BUILD_ANIM_DIAG_01 §4` row "Not a cause"; `DANIM_01 §5`
`peaukr.aaf:17`; `DANIM_02 §4.1` 43/43 clip-table rows CORRECT).

---

## 2. Diagnosis findings — before → after

**Before (observed code/data, not a rendered observation):**

1. Sim writes `e.order = {"type": "build", "target": site.id}` (`game.gd:3115`);
   repair uses `{"type":"repair",...}` (`game.gd:4411`).
2. `world3d_entities.gd:_unit_action()` (`:1009-1016`) returns only
   `death / walk / idle`; the 0.15 m/s gate (`:199`, `:1023-1034`) makes a
   stationary builder resolve to **`idle`** (AAF 64..113) and a builder still
   walking to the site resolve to **`walk`** (AAF 1..20). No branch reads
   `order`, `build`, `repair` or `construct` (`BUILD_ANIM_DIAG_01 §3.2`).
   `MORPH_ACTION_MAP` at `:186` openly documents this 3-state PORT policy.
3. `anim3d.gd:pose_for()` is then asked for the wrong string; its own lookup is
   correct, so the fault is upstream.
4. Secondary fault: `convert_skins.py:69-73` `DEFAULT_ACTIONS` omits `construct`;
   `skin/index.json` and `skin/peasant.json` carry no `construct` action and the
   peasant frame union is
   `[1,5,9,12,16,20,64,74,84,93,103,113,115,122,129,135,142,149,237,240,244,247,251,254]`.
   Passing `"construct"` today would make `_nearest_exported_frame()`
   (`anim3d.gd:907-912`, called from `:546`) substitute **149** for donor frames
   186..192 and **237** for 194..198 — i.e. a death-frame or attack0-frame pose.
   Rendered appearance is **inferred**, not captured by me.
5. Contrast: the 2D sibling `world.gd:481-490` already implements the
   donor-grounded map, including `"build" or "repair" → "construct"` (`:489-490`).

**After (target state, recipe only — NOT implemented or validated by me):**

| Layer | Before | After |
|---|---|---|
| `_unit_action(ed, speed)` for stationary build-ordered peasant | `"idle"` (range 64..113) | `"construct"` (range 186..198) |
| `pose_for(..., "construct", t)` with regenerated skin | snaps to 149 / 237 | resolves to the exported construct frames below |
| `rendered_actions` telemetry (`:1830`) | `{"idle": N}` | includes `"construct"`; batch keys contain `|aconstruct|` |
| Labels | unchanged | `PORT APPROXIMATION — NOT DONOR PARITY`, `visual = "UNVERIFIED"` — unchanged |

---

## 3. Minimal fix recipe (owners are NOT me)

| Step | Owner / file | Minimal change |
|---|---|---|
| 1 | `variant3d/scripts/world3d_entities.gd` — `_unit_action()` `:1009-1016` (owner: NATION-MODEL-01 or assigned owner) | After the `dead` check and before the speed/moving fallbacks: when measured speed is below `WALK_SPEED_GATE_M_S` and `str(ed.get("order",{}).get("type",""))` is `"build"` or `"repair"`, return `"construct"`. Mirror `world.gd:489-490`. Keep dead-first priority and the VID-AN-01 speed gate; keep `rendered_actions` telemetry. Optionally mirror `gather`/`resow` → `work*` from `world.gd:481-488`, but that is a separate extension, not needed for build. |
| 2 | `variant3d/tools/convert_skins.py:69-73` + regenerated `variant3d/assets/models/skin/index.json` and per-sid skin JSON (asset/data owner; regenerate **offline**) | Add `construct` to `DEFAULT_ACTIONS` and re-run the converter so each skin's `actions`, `frames` and `anim` include donor frames 186..198. No runtime donor access. |
| 3 | `variant3d/scripts/anim3d.gd` | **No code change.** `_action_range_for()` `:918-934` already resolves `construct` from the skin first and falls back to the correct peaukr AAF row `:86`. Keep every `PORT APPROXIMATION` / `visual = UNVERIFIED` label and the flat-root sampled pose exactly as-is. |

**Expected peasant `construct` export (six frames): `[186, 188, 191, 193, 196, 198]`.**
Derivation: `convert_skins.py:140-148` `sample_frames(186, 198, 6)` uses
`first + round((last-first)*i/(n-1))` (Python half-to-even, donor
`bake_sprites.py:145-152`), giving offsets `[0,2,5,7,10,12]`. Independently
recomputed read-only during this ticket; matches `BUILD_ANIM_DIAG_01 §5/§6`.
These are donor-derived frame indices only — no new pose is invented.

**Discriminating check for the eventual owner (recipe, not run by me):** call
`pose_for(..., "construct", f/30)` for those six frames and require
`pose.frame` to equal the list above (six distinct vertex-buffer hashes), never
149/237, with `pose_source == "donor_flat_root_morph"` and
`visual == "UNVERIFIED"`. A sync-level builder capture should show
`rendered_actions["construct"] >= 1`, zero builder `idle`, and `|aconstruct|`
batch keys. Capture hygiene from `BUILD_ANIM_DIAG_01 §6` applies; a negative
pixel diff at the default zoom is not evidence (`VID_AN_01:150-153`).

**Explicitly out of this smallest fix:** hammer tool skin (`V764` Q3),
`buildsmoke` PFX, stage/scaffold OBJs (`BUILD_STAGES_01` Q1), and one-shot/blend
policy (`DANIM_01 §8.3`). None of these may be presented as donor parity.

---

## 4. Validation record — honest

- Variant runner: **not invoked**. The requested unique id `buildanim01-smoke`
  with `--check-only --script res://scripts/anim3d.gd` was not run; no existing
  animation atom was run either.
- `SCRIPT ERROR == 0`: **not measured** — no runner output exists for this ticket.
- Gates / ladder / direct `godot`: **not used**.
- **No PASS claim** is made for the diagnosis, the recipe, or the restored file.
  The only measured facts here are the read-only donor/port text and JSON reads,
  the SHA-256/hash and `git diff` restoration checks in §0, and the arithmetic
  for the six expected frames.

---

## 5. Remaining approximation labels and open questions

- Labels kept verbatim everywhere: `PORT APPROXIMATION — NOT DONOR PARITY`,
  `rig = BLOCKED: donor bone parent hierarchy unreadable … flat-root skin only`,
  `visual = "UNVERIFIED"`, `verified = false`, `pose_source` either
  `donor_flat_root_morph` or `donor_timing_only`.
- No donor-parity, rendered-frame or engine-behaviour claim is made (DEC-04 §7;
  DANIM-01 §8.5; CORRECTIONS rows 14/51).
- Open questions inherited from `BUILD_ANIM_DIAG_01 §7`: loop-vs-one-shot engine
  semantics; `buildsmoke` spawn trigger; 8-azimuth vs continuous-yaw equivalence;
  repair/gather donor tag distinction; hammer visibility at 3D zoom; stage art
  absence; visual A/B. None resolved here.

---

## 6. Summary

- Donor peasant build = **`construct`, AAF `peaukr.aaf:17` 186..198, 13 frames @
  30 fps = 0.433 s, looping per donor ACL/debug policy**; the state→name chain is
  `dmscript.global:13/:926` → `unit.script:10877` / `ontagstates.inc:318` →
  `peasant.acl:2245-2252`.
- The port AAF table already contains the correct row (`anim3d.gd:86`), so **no
  `anim3d.gd` change is needed**. The two real faults are the missing build branch
  in `world3d_entities.gd:_unit_action()` and the missing `construct` frames in
  the compact skin export (`convert_skins.py:69-73`).
- Smallest fix: those two owner files only; expected peasant frames
  **`[186,188,191,193,196,198]`**.
- My interim `anim3d.gd` edit was fully reverted byte-for-byte from
  `inbox/backup/anim3d.gd.bak-BUILDANIM01`; hash matches the pre-edit value and
  `git diff` is clean. **No source file was edited by me in the final state; this
  report is the only file I authored; no PASS claim is made.**

*End of BUILD_ANIM_01 report.*
