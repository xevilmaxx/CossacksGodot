---
id: AUDIO-SEL-02
title: "AUDIO-SEL-02 — wire the donor selection sound into the 3D selection rebuild"
area: variant3d / input / audio / donor selection feedback
owner: AUDIO-SEL-02 (small integration builder / subagent)
date: 2026-11-25
status: PENDING_VALIDATION
scope: "Exactly two repo files in scope; only variant3d/scripts/input_controller.gd was edited plus this report. Backup outside the repo tree: inbox/backup/input_controller.gd.bak-AUDIOSEL02. Donor READ-ONLY; no donor binary run and no donor asset copied. audio.gd, hud.gd, config, tests, harness, fixtures, manifest and git state untouched."
owns:
  - "variant3d/scripts/input_controller.gd"
  - "docs/coord_swarm_2026-11-25/reports/AUDIO_SEL_02.md"
donor: "C:\\Games\\Cossacks 3 — read-only source/config reports consumed (AUDIO_SEL_01, SEL_01_implementation, CONFIG_WIRE_SEL, DAUDIO-01, RV-SEL-01, DSEL-01, DEC_04 §8); no donor file copied or executed."
backup: "inbox/backup/input_controller.gd.bak-AUDIOSEL02 — 58428 B — SHA-256 BD626E700AF2F1AC2CADC99736750C05A34556043F3D87C619AB89658941BD81 (pre-edit, matches original)"
labels: [DONOR_CITED, NO_BEHAVIOUR_CHANGE_WHEN_AUDIO_UNAVAILABLE, VARIANT_RUNNER_ONLY]
validation: "pending"
---

# AUDIO-SEL-02 — selection acknowledgement wired into the 3D rebuild

## 1. Goal and guardrails

`AUDIO-SEL-01` added `audio.play_selection(kind, count)` to
`variant3d/scripts/audio.gd` but deliberately wired no caller. This ticket wires
that existing API into the **one** point where a new selection is applied —
`C3Input._set_selection()` — so the donor's selection acknowledgement fires
**once per selection rebuild**, not per unit and not every frame.

No other file was edited. In particular `audio.gd` (AUDIO-SEL-01's file),
`hud.gd`, `main.gd`, config, tests and harness are untouched. No positional
emitter, no new clip table, no new audio path and no donor asset copy.

## 2. Sources read (all read-only outside ownership)

| Source | What it supplied |
|---|---|
| `reports/AUDIO_SEL_01.md` §2, §5, §7 | Donor citation chain, exact API names `selection_clip(kind,count)` / `play_selection(kind,count)`, ship-token set, and the integration instructions (caller = selection-rebuild site, gate = `main.gd::_play()`). |
| `reports/SEL_01_implementation.md` §"Backup", §"Before → after" | `_set_selection()` is SEL-01's selection-apply point; drag/click/Shift/`cmd_*` branches are byte-identical and out of scope here. |
| `reports/CONFIG_WIRE_SEL.md` §3, §4, §7 | Post-CONFIG-WIRE-SEL line map of the owned file and its explicit no-behaviour-change baseline; the current file is that state plus this ticket's hunk. |
| `variant3d/scripts/input_controller.gd` (owned) | `_set_selection()` at pre-edit `:305-315`; existing `c3_main` group access pattern at `:1093/:1098/:1123`; ship detection in `_select_ships()` at `:1016`. |
| `variant3d/scripts/main.gd` (read-only) | `var audio: C3Audio` at `:110`, group `c3_main` at `:170`, `can_play` meta at `:638-641`/`:1135-1138`, gate at `:1675` and `_play()` at `:1755-1757`. |
| `variant3d/scripts/audio.gd` (read-only) | `SHIP_SELECT_KINDS` at `:41-44`, `selection_clip()` at `:466-471`, `play_selection()` at `:476-477` (routes through the existing non-positional `play()`). |

## 3. Donor citations

Every citation below is carried over from the landed, read-only
`AUDIO_SEL_01.md` §2 / §5; no donor text was re-read or executed by this builder.

| Implemented choice | Donor literal / chain | Citation |
|---|---|---|
| Fire once on **unit-control rebuild**, not per unit, not per frame | `_sound_PlaySound(gc_sndlib_ind_interface, ...)` in `showunitcontrol` | `data\gui\menu.inc\showunitcontrol.inc:1024-1027` (peasant `:1024-1025`, ship `:1026-1027`) |
| Peasant/unit clip family | `selectpeasant1..6.ogg`, `gc_snd_ind_selectpeasant = 26`, registered `cLoudFull` | `sounds\interface\interface.snd:132-158`; `scripts\dmscript.global:1276-1277`; `lib\sound.script:206-207`; DAUDIO-01 §3.1/§4.2 |
| Ship clip | `selectship.ogg`, `gc_snd_ind_selectship = 27` | `interface.snd:128-129`; `dmscript.global:1277`; `lib\sound.script:208`; DAUDIO-01 §3.1 |
| Global / non-positional, no world emitter | `cLoudFull = 8000`; `SetSndSoundRadius(8000)`, `SetSndSoundMaxRadius(0)` | `lib\sound.script:98-102`, `:494-530` (`:524-525`); DAUDIO-01 §4.3 |
| Interface bank | `interface → interface.snd`; `gc_sndlib_ind_interface = 1` | `data\sounds\sounds.slc:7-8`; `dmscript.global:1245-1247` |
| Visual brush (cited for completeness, **not** the sound) | `SelectionBrushFileName = .\data\brushes\selection.cfg` | `data\resources\resource.lib:47` |
| Assets already converted | 325/325 donor Ogg present in `res://assets/sounds`, 1:1 basename match | DEC_04 §8; DAUDIO-01 §5.1 |

This ticket adds **no new donor claim**: it only chooses *when* to call the API
that AUDIO-SEL-01 built around those citations.

## 4. Where the call was placed, and why

`_set_selection(arr)` is the single selection-apply point: it clears old flags,
sets `selected_ids` and `e["selected"]`, bumps `game.bld_dirty`, then refreshes
the HUD. The donor acknowledgement belongs **after** that refresh (the donor
plays on the rebuilt unit-control panel), so the call is appended at the end of
`_set_selection()`. Every other path — real drag LMB-up, short click, Shift
union, double-click, minimap release, build placement, hotkey/group selection,
idle-peasant/mine buttons — funnels through this one method, so the sound fires
exactly once for each of them without touching any of their branches. Nothing
was added to `_process()`, `_unhandled_input()` or any per-frame path.

## 5. Backup

| Item | Value |
|---|---|
| File | `inbox/backup/input_controller.gd.bak-AUDIOSEL02` |
| Taken | before the first edit (plain copy of `variant3d/scripts/input_controller.gd`) |
| Size | 58,428 bytes (backup and pre-edit source) |
| SHA-256 (both) | `BD626E700AF2F1AC2CADC99736750C05A34556043F3D87C619AB89658941BD81` |

Restore is a plain copy back over `variant3d/scripts/input_controller.gd`.

## 6. Before → after (only `variant3d/scripts/input_controller.gd`)

`git diff --stat` for the owned file: **45 insertions, 3 deletions** versus HEAD;
23 insertions / 3 deletions of those are the already-landed CONFIG-WIRE-SEL
hunks. **This ticket's own change is 22 insertions, 0 deletions, one hunk**, at
the end of `_set_selection()`.

| # | Before (pre-edit `:305-315`) | After (`:305-337`) | Change |
|---|---|---|---|
| 1 | `game.bld_dirty += 1` then `hud.refresh_selection(get_selected())` was the end of `_set_selection()` | Same two lines, then a donor-cited comment and a one-shot call block | Additive only; the two original lines are byte-identical |

The added block, in order:

1. `var first: Dictionary = arr[0] if not arr.is_empty() else {}` — first selected entity (empty selection ⇒ no entity).
2. `var def: Dictionary = first.get("def", {})` and `var sid_lc := str(first.get("sid", "")).to_lower()` — read its definition and sid.
3. `var is_ship := bool(def.get("ship", false)) or bool(def.get("naval", false)) or sid_lc.contains("ship") or sid_lc in [yacht, yachttur, fishboat, galley, frigate, xebec, battleship, cog]` — mirrors this file's existing `_select_ships()` predicate (`:1016`) plus `audio.gd`'s `SHIP_SELECT_KINDS` (`audio.gd:41-44`); the clip table itself is **not** duplicated.
4. `var kind := "ship" if is_ship else "unit"`.
5. `var tree := get_tree()` guarded with `if tree != null:`; the main node is obtained via `tree.get_first_node_in_group("c3_main")` — the same null-checked seam already used in this file at `:1093/:1098/:1123` (`main.gd:170` registers the group).
6. `var snd = m.get("audio")`, then `if snd != null and is_instance_valid(snd) and bool(snd.get_meta("can_play", false)) and snd.has_method("play_selection"):` — **main.gd's exact gate** (`main.gd:1675`, `:1756`) plus a method check for older audio instances.
7. `snd.play_selection(kind, arr.size())` — routes through the existing AUDIO-SEL-01 API; `count` is the size of the applied selection (AUDIO-SEL-01 §7: "number of selected entities").

**Byte-identical and untouched:** the drag/click split, LMB press/release
branches, world-ground epsilon, Shift-add union (`spmAdd`), omitted Ctrl-remove,
double-click branch, overlay creation/refresh/clearing, world `sel_rect`
mirror, minimap early-out, click-pick branch, all `_pick`/`_pick_res` calls,
every `game.cmd_*` call, all hotkeys/groups/build-ghost code, every symbol and
signature, and every other repo file.

## 7. Explicit no-behaviour-change statement

- The call is the **only** runtime addition. Selection flags, `selected_ids`,
  `game.bld_dirty`, `hud.refresh_selection()` and every ordering/threshold in the
  file are unchanged. No selection set, event, order or HUD state can differ.
- When audio is unavailable — headless (`main.gd:638`, `:1135` set
  `can_play = false`), no `c3_main` node, no `audio` member, invalid instance,
  or an audio object without `play_selection` — the gate short-circuits and
  **nothing is called**: no sound, no error, no allocation on the hot path
  beyond the local reads. This is the intended "no behaviour change when audio
  is unavailable".
- No gate, default, debounce, pitch, volume or mixer value was changed; no
  `AudioStreamPlayer3D` was added; no donor asset was copied; no donor binary
  was run.

## 8. Validation — variant runner only, unique ids

PENDING — see updated report after runner jobs finish.

## 9. Open questions

1. **Empty selection still fires.** `_set_selection([])` (click on empty
   ground) reaches the same apply point, so `play_selection("unit", 0)` runs
   and `selection_clip()` clamps count to 1 ⇒ `selectpeasant1`. Donor
   `showunitcontrol` rebuild on a cleared panel is UNVERIFIED; suppressing the
   sound on an empty selection would be a separate decision.
2. **`count` on Shift-add.** The count passed is `arr.size()` of the *applied*
   selection (union), not the number of strictly-new ids. AUDIO-SEL-01 §7
   asks for "number of selected entities", so this matches the API contract;
   the donor's exact count is UNVERIFIED.
3. **Variant choice.** `selection_clip()` uses a deterministic count-driven
   variant while the donor used a random start index + linear probe
   (DAUDIO-01 §4.3) — a labelled PORT APPROXIMATION inherited from
   AUDIO-SEL-01, not changed here.
4. **Building selections.** A building-only selection is classified `"unit"`
   by the first-entity test (no ship tokens), so it plays a peasant variant.
   Donor also plays `bld<sid-suffix>` on selection
   (`showunitcontrol.inc:1015-1021`), which AUDIO-SEL-01 §8 Q3 left to a
   separate ticket; not implemented here.
5. **DSP / audibility.** No donor parity claim for DSP, panning, stereo image
   or mix level (AUDIO-SEL-01 §8 Q4); the smoke is parse-only unless the
   windowed drag job is green, and neither is an audible A/B test.

## 10. Summary

Wired the AUDIO-SEL-01 API into the 3D selection rebuild at the single
selection-apply point `C3Input._set_selection()`, after flags and the HUD
refresh. One call per apply, `kind = "ship"` when the first selected entity
carries ship/naval tokens or sids else `"unit"`, `count = arr.size()`. The
existing `c3_main` group seam and `main.gd`'s exact `can_play` gate are reused,
so headless/audio-less runs are silent and all drag/click/Shift/overlay/`cmd_*`
logic is byte-identical. Backup `input_controller.gd.bak-AUDIOSEL02` was taken
before the edit (SHA-256 verified). Validation: PENDING.

**No other file was edited by this builder** — no `audio.gd`, `hud.gd`,
`main.gd`, config, test, harness, fixture, manifest, asset, scene, shader or
git state. Only the owned file and this report (plus the requested backup copy
outside the repo's game tree).

---
*AUDIO-SEL-02, 2026-11-25. Additive one-call integration; no behaviour change when audio is unavailable.*
