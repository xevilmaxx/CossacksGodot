---
id: AUDIO-SEL-01
title: "AUDIO-SEL-01 — add donor selection sounds to the 3D variant (API only)"
area: variant3d / audio / donor selection feedback
owner: AUDIO-SEL-01 (small implementation builder)
date: 2026-11-25
status: IMPLEMENTED__VALIDATED__INTEGRATION_TICKET_REQUIRED
scope: "Exactly two repo files in scope; only one was edited — variant3d/scripts/audio.gd — plus this report. Backup outside the repo tree: inbox/backup/audio.gd.bak-AUDIOSEL01. Donor READ-ONLY; no donor binary run, no donor asset copied. No caller wired in any other file."
owns:
  - "variant3d/scripts/audio.gd"
  - "docs/coord_swarm_2026-11-25/reports/AUDIO_SEL_01.md"
donor: "C:\\Games\\Cossacks 3 — read-only source/config reports consumed (DAUDIO-01, RV-SEL-01, DSEL-01, DEC_04 §8); no donor file copied or executed."
labels: [DONOR_CITED, PORT_APPROXIMATION, UNVERIFIED_DSP, API_ONLY]
backup: "inbox/backup/audio.gd.bak-AUDIOSEL01 — 16185 B — SHA256 8312EFDB2A029FE26820142D5905CD200E8FD014706A75632679E6ED747A4448 (pre-edit, matches original)"
smoke_job: {id: audiosel01-smoke, ticket: 424, runner: "variant3d/tools/godot_runner.py", status: ok, exit: 0, stderr_bytes: 0, script_errors: 0, wait_s: 235.22, run_s: 5.66}
---

# AUDIO-SEL-01 — donor selection sounds (3D variant)

## 0. Goal and guardrails

Add the donor's unit/ship **selection acknowledgement** to `variant3d/scripts/audio.gd`
using only the already-converted port audio assets, exposed as a small API. The
caller is deliberately **not** wired: `input_controller.gd` (SEL-01 / CONFIG-UI
boundary), `hud.gd` (MMJUMP-02), config files and tests are outside this ticket's
ownership. No positional `AudioStreamPlayer3D`, no new mixer defaults, no change
to any existing audio API or default, no donor copy.

## 1. Sources read (all read-only outside ownership)

| Source | What it supplied |
|---|---|
| `reports/DAUDIO_01_sound_events.md` §3.1, §4.3, §5 | Selection event→file chain, `cLoudFull=8000`, non-positional `_sound_PlaySound`, port MISSING verdict |
| `reports/RV_SEL_01_selection_reverify.md`, `reports/DSEL_01_donor_selection_rectangle.md` | `dmscript.global:1276-1277` constants, `sound.script:206-208`, confirmation that sound fires on panel rebuild |
| `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` §8 | 325/325 Ogg census; 247+51+27=325 declared clips vs 325 on-disk; 1:1 basename match |
| `reports/SEL_01_implementation.md` | Ownership boundary (`input_controller.gd` is SEL-01's, not mine) |
| `variant3d/scripts/audio.gd` (owned) | Existing non-positional `play()` path, player pool, `names_for()` rule |
| `variant3d/scripts/main.gd` (read-only) | `_play()` at `:1755-1757` and its `can_play` gate at `:1675`, `:1756`; `_consume_events()` at `:1703-1753` |
| `variant3d/scripts/data.gd` (read-only) | Ship sids at `:1169-1250` (all `naval: true`); `AUDIO_ENABLED := true` at `:109` |

## 2. Donor citations

| Implemented choice | Donor literal / chain | Citation |
|---|---|---|
| Peasant/unit selection clip family | `selectpeasant1..6.ogg` (F6), `gc_snd_ind_selectpeasant = 26`, registered with `cLoudFull` | `sounds\interface\interface.snd:132-158`; `scripts\dmscript.global:1276-1277` (namespace `:1250-1343`); `lib\sound.script:206-207`; DAUDIO-01 §3.1 / §4.2 |
| Ship selection clip | `selectship.ogg` (F1), `gc_snd_ind_selectship = 27`, registered with `cLoudFull` | `interface.snd:128-129`; `dmscript.global:1277`; `lib\sound.script:208`; DAUDIO-01 §3.1 |
| Playback trigger (why this is a UI/global sound) | on unit-control rebuild: `_sound_PlaySound(gc_sndlib_ind_interface, …)` for peasant at `:1024-1025` and ship at `:1026-1027` | `data\gui\menu.inc\showunitcontrol.inc:1024-1027` |
| Global/8000 radius, non-positional | `cLoudFull = 8000`; `_sound_PlaySound` sets `SetSndSoundRadius(8000)`, `SetSndSoundMaxRadius(0)` on the listener handle | `lib\sound.script:98-102`, `:494-530` (specifically `:524-525`); DAUDIO-01 §4.3 |
| Bank wiring | `interface → interface.snd`; `gc_sndlib_ind_interface = 1` | `data\sounds\sounds.slc:7-8`; `dmscript.global:1245-1247` |
| Six-variant family | 6 Ogg files present, all declared in `interface.snd`, switched to `svgSFX` | `interface.snd:132-158`; DEC_04 §8 census |
| Selection brush (visual, **not** the sound — cited for completeness only) | `SelectionBrushFileName = .\data\brushes\selection.cfg` | `data\resources\resource.lib:47` (RV-SEL-01, DSEL-01 claim 18) |
| Assets already converted | 325/325 donor Ogg present in `res://assets/sounds`; 51 non-empty `interface.snd` records | DEC_04 §8.1/§8.2; DAUDIO-01 §5.1 |

Every citation above is from a landed read-only report; no donor text was re-read
from the donor tree by this builder and no donor file was executed or copied.

## 3. Exact on-disk clip filenames (verified, not invented)

Confirmed with a directory listing of `variant3d\assets\sounds` (`select*.ogg`):

```
variant3d/assets/sounds/selectpeasant1.ogg
variant3d/assets/sounds/selectpeasant2.ogg
variant3d/assets/sounds/selectpeasant3.ogg
variant3d/assets/sounds/selectpeasant4.ogg
variant3d/assets/sounds/selectpeasant5.ogg
variant3d/assets/sounds/selectpeasant6.ogg
variant3d/assets/sounds/selectship.ogg
```

These match the donor `sounds\interface\*.ogg` basenames 1:1 (DEC_04 §8 325/325).
`selection_clip()` emits these exact basenames, so `play()`'s existing
`names_for()` rule and `_stream()` resolve them to `res://assets/sounds/<name>.ogg`
without any new asset or path table.

## 4. Backup

```
copy variant3d\scripts\audio.gd inbox\backup\audio.gd.bak-AUDIOSEL01
```

Created **before** the first edit. 16,185 bytes; SHA-256
`8312EFDB2A029FE26820142D5905CD200E8FD014706A75632679E6ED747A4448`,
identical to the pre-edit source hash. Retained.

## 5. Before → after (only `variant3d/scripts/audio.gd`)

| # | Before | After | Change |
|---|---|---|---|
| 1 | no `selectpeasant` / `selectship` token anywhere in `audio.gd`; DAUDIO-01 §5 verdict for both = **MISSING** | new constants `SELECT_PEASANT`, `SELECT_PEASANT_VARIANTS := 6`, `SELECT_SHIP`, `SHIP_SELECT_KINDS` (`:32-44`) | Additive declarations only; no existing constant touched |
| 2 | no selection resolver or playback API | `selection_clip(kind: String, count: int) -> String` (`:466-471`): ship tokens → `selectship`; otherwise deterministic `selectpeasant{((max(count,1)-1) % 6)+1}` | Pure, testable without audio; six variants wrap; `count <= 0` clamped to 1 |
| 3 | no way to fire donor selection feedback | `play_selection(kind: String, count: int) -> void` (`:476-477`) → `play([selection_clip(kind, count)])` | Routes through the **existing** non-positional/global `play()` path (`at` left at its `Vector2.INF` default); no `AudioStreamPlayer3D`, no new pool, no new volume default |
| 4 | n/a | donor citation block above the new API (`:437-465`) | Records `showunitcontrol.inc:1024-1027`, `dmscript.global:1276-1277`, `sound.script:206-208 / :98-102 / :494-530`, `interface.snd:128-129,132-158`, `sounds.slc:7-8`, `resource.lib:47` |

Ship tokens accepted: `ship`, `naval`, `boat` plus the seven port naval sids
`yacht`, `yachttur`, `fishboat`, `galley`, `frigate`, `xebec`, `battleship`
(`data.gd:1169-1250`). Any other `kind` resolves to a peasant variant. No
existing method, signature, default, debounce, pitch handling or volume was
changed; `stop_all()`, `_ready()` and the ambient loop are byte-identical to
the backup.

## 6. Validation — variant runner only, unique id

No gates, no ladder, no windowed run, no direct `godot`. Exactly one job:

```
python variant3d\tools\godot_runner.py run --id audiosel01-smoke --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/audio.gd
```

| Field | Result |
|---|---|
| Job id / ticket | `audiosel01-smoke` / **424** |
| Status / exit | **ok** / **0** |
| Wait / run | 235.22 s / 5.66 s (FIFO queue; no bypass) |
| stderr | **0 bytes ⇒ `SCRIPT ERROR == 0`** (explicitly counted: 0) |
| stdout | Godot 4.7.2 banner only — `--check-only` produced no parse errors |
| Result file | `variant3d\.godot_queue\results\00000424.json` |
| Logs | `variant3d\.godot_queue\results\00000424_audiosel01-smoke\stdout.txt`, `…\stderr.txt` |

This proves the edited script parses cleanly. It is a **parse smoke**, not a
runtime audio-gate or audible-output test (see open questions).

## 7. Integration ticket required (NOT done here)

The API is intentionally inert until a caller fires it. A follow-up ticket must
own the caller, most plausibly the unit-control / selection-rebuild site:

- **Ticket (proposed):** `AUDIO-SEL-02 — wire selection acknowledgement`.
- **Owner:** must be the owner of the call site (`input_controller.gd` for
  selection changes, or `main.gd` if routed through the event dispatch). Both
  are outside this ticket's ownership; neither was edited.
- **Call:** `audio.play_selection(kind, count)` whenever a selection is rebuilt
  — donor `showunitcontrol.inc:1024-1027` fires on **panel rebuild**, not on
  mouse-down or drag-move. `kind` = `ship`/naval sid for ships, otherwise a unit
  sid or `"unit"`; `count` = number of selected entities (the resolver makes
  the variant deterministic).
- **Gate:** mirror `main.gd::_play()` (`:1755-1757`) and its `can_play` check
  (`:1675`, `:1756`) so headless / pre-gesture runs stay silent. `play()` itself
  only checks `Data.AUDIO_ENABLED` (`data.gd:109`, always `true`), so the caller
  must apply the existing guard rather than invoking the API unconditionally.
- **Do not** add a positional emitter, duplicate the clip table, or change
  `audio.gd` defaults while wiring.
- **Verification:** a runtime probe asserting the chosen clip for a ship
  selection and for counts 1..7 (wrap back to 1), plus the existing
  selftest/uitest gates by their owners.

## 8. Open questions

1. **Exact donor variant choice.** DAUDIO-01 §4.3 records a random start index +
   linear probe in `_sound_PlaySound`, not a count-driven rule. The count-based
   deterministic mapping here is a **PORT APPROXIMATION** chosen for
   reproducibility; the donor's exact index for a given selection is
   UNVERIFIED. Resolve only if a donor trace becomes available.
2. **Trigger identity.** Donor fires on unit-control panel rebuild
   (`showunitcontrol.inc:1024-1027`); the port has no direct analogue. Which
   port event is the faithful equivalent (selection commit vs. panel refresh)
   is a decision for the integration ticket, not this one.
3. **Building cues.** Donor also plays `bld<sid-suffix>` on selection
   (`showunitcontrol.inc:1015-1021`). Out of scope here; the port's
   `building_sound()` already exists but is only wired on `"done"`
   (`main.gd:1752`). Separate ticket if desired.
4. **DSP / panning parity — UNVERIFIED.** Donor `cLoudFull=8000` disables
   attenuation on the isometric path; whether the engine pans stereo at all was
   never provable from read-only data (DAUDIO-01 §4.4, §7 Q2). This change makes
   **no donor parity claim** for DSP, panning, stereo image or mix level; it
   only routes the correct clip through the port's existing non-positional
   path. Pitch randomisation remains the pre-existing invented behaviour
   (`audio.gd:355`), untouched.
5. **Runtime audible verification.** The smoke is parse-only. No in-game
   capture or A/B was run, and none is claimed.

## 9. Summary

`variant3d/scripts/audio.gd` now exposes `selection_clip(kind, count)` and
`play_selection(kind, count)`, routing the donor `selectpeasant1..6` /
`selectship` clips through the existing non-positional, global `play()` path,
with full donor citations in code. Selection-size picks a peasant variant
deterministically; ships get `selectship`. The seven exact asset filenames were
verified on disk; no asset was copied and no donor binary was run. Backup
`inbox/backup/audio.gd.bak-AUDIOSEL01` was taken before the edit. Smoke
`audiosel01-smoke` (ticket 424) is green: exit 0, stderr 0 bytes, `SCRIPT ERROR
== 0`. An integration ticket is required to wire the caller and apply the
existing `can_play` gate; none was wired here. DSP/panning parity is
**UNVERIFIED**.

**No other file was edited by this builder** — no `input_controller.gd`,
`hud.gd`, `main.gd`, `data.gd`, config, test, asset, scene, shader, runner or git
state. Only `variant3d/scripts/audio.gd` and this report are in scope.

---
*AUDIO-SEL-01, 2026-11-25. Additive API only; integration intentionally deferred.*
