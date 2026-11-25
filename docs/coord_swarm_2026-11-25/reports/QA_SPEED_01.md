---
id: QA-SPEED-01
title: "QA-SPEED-01 — speed dropdown landing verification and donor-value divergence"
area: coord_swarm_2026-11-25
task_id: QA-SPEED-01
date: 2026-11-25
owner: QA-SPEED-01 (read-only QA subagent)
status: DONE__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT_ONLY
scope: "Read-only on-disk verification of the speed control in variant3d/scripts/hud.gd against inbox/backup/hud.gd.bak-UITOPBAR01, the donor truth in UITOP_DONOR_01.md and the authored HUD_LAYOUT_01.md atom. No code/config/test/manifest/queue edit; no Godot process; no godot_runner.py job; no result JSON written; no report promoted to PASS."
owns:
  - "docs/coord_swarm_2026-11-25/reports/QA_SPEED_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
parity: "NO donor-parity, visual-parity or runtime-PASS claim. Port speed values are PORT APPROX unless the owner corrects them."
output: docs/coord_swarm_2026-11-25/reports/QA_SPEED_01.md
---

# QA-SPEED-01 — speed dropdown landing verification and donor-value divergence

## 0. Label key

- **observed** — read directly this pass: numbered file reads, repo-wide globs,
  symbol/keyword sweeps, `git status --short` and file-size checks.
- **derived** — structural conclusion from observed rows (e.g. "the array is
  declared but never appended, so it is empty at runtime").
- **inferred** — judgement about likely effect or risk; never asserted as fact.
- **UNVERIFIED** — not checkable without a runner job, a windowed observation or
  an artifact that does not exist. No absent artifact is assigned a cause.

This worker does not promote any owner report, atom or code diff to PASS. Where
"PASS" appears below it is either a quoted status from another artifact or an
explicitly labelled absence of one.

## 1. Sources

| Source | Use | Label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/reports/UITOP_DONOR_01.md` (215 lines, frontmatter `:1-12`) | Donor speed truth: factors `7/10/14` (`:142-145`, T1–T4), mode `-1` Adjustable (`:142`, `:149`), no in-game top-bar speed widget (`:157-160`, U1–U4), `hotkeys.cfg` zero speed rows (`:117-119`, H1–H3), R05's wrong `:2079-2130` citation vs real `:1010-1075` (`:121`, `:202`) | **observed** (full-file read) |
| `reports/HUD_LAYOUT_01.md` (231 lines) | Atom authoring status `AUTHORED__NO_GODOT_RUN__NO_PASS_CLAIM` (`:1-13`); speed-check predicates (`:128-129`); `UI_TOPBAR_01.md` absent at authoring time (`:47`, `:185-189`); no-runner declaration (`:205-214`) | **observed** |
| `reports/UI_TOPBAR_01.md` | Owner landing report | **UNVERIFIED** — file absent (repo-wide glob, this pass) |
| `variant3d/scripts/hud.gd` (live, 86,604 B) | Speed widget construction `:106-112`, `:439-453`; `_mkoption()` `:490-502`; `_speed_index()`/`_on_speed_idx()` `:591-602`; `refresh_speed()`/`_on_speed()` `:629-643`; responsive sizing `:581-583` | **observed** |
| `inbox/backup/hud.gd.bak-UITOPBAR01` (80,873 B) | Pre-UI-TOPBAR-01 baseline: four speed `Button`s at `:428-433` (`speed_buttons.append(sb)`); `refresh_speed()` without dropdown sync at `:491-493` | **observed** |
| `variant3d/scripts/data.gd:384` | `DONOR_GAME_SPEED := {"slow": 0.5, "normal": 1.0, "fast": 2.0, "very_fast": 4.0}` | **observed** |
| `variant3d/scripts/main.gd:360-362` | Port speed clamp `clampf(..., 0.1, 8.0)` from `Data.DONOR_GAME_SPEED` | **observed** |
| `variant3d/scripts/uitest.gd:274-280` | Existing gate step calls `main.set_speed()` directly; does not touch the dropdown | **observed** |
| Glob for `UI_TOPBAR_01.md` and `variant3d/tests/results/t_hud_layout.json` | Both absent; only `t_hud_fidelity.json` present in the results dir | **observed** (no match / file listing) |
| `git status --short` (targeted) | `variant3d/scripts/hud.gd` `M`; backup and `t_hud_layout.gd` `??`; no `QA_SPEED_01.md` yet | **observed** |
| `reports/QA_UI_FIXES_01.md:92-109` | Prior QA R2 reached the same landed-code / unverified-runtime split; cited for continuity, not as authority | **observed** (via cited doc) |

## 2. Verification table

| # | Check | Evidence | Label | Verdict |
|---|---|---|---|---|
| V1 | Exactly one dropdown widget exists | `hud.gd:112` declares `var speed_menu: OptionButton`; `:491` is the **only** `OptionButton.new()` in the file; `:444-447` creates it and adds it once to `top_bar`. Keyword sweep finds **no** `MenuButton` and **no** `PopupMenu` anywhere in `hud.gd`. | **observed** | **PASS (code, static)** |
| V2 | No leftover speed `Button`s | `hud.gd:108` keeps `speed_buttons: Array = []` "for API readers, now empty"; no `speed_buttons.append` call exists in the live file. The backup's four-button loop (`bak:428-433`) is gone. `Button.new()` survives only in the generic helpers `_mkbtn()` (`:248`) and `_unit_button()` (`:705`), neither speed-specific. | **observed**, **derived** | **PASS (code, static)** |
| V3 | Speed item labels and metadata intact | `hud.gd:444` passes `[["II",0.0],["1x",1.0],["2x",2.0],["4x",4.0]]` to `_mkoption()`; `:496` `add_item(str(it[0]))` and `:498` `set_item_metadata(idx, float(it[1]))` give texts `II/1x/2x/4x` with float metadata `[0.0,1.0,2.0,4.0]`; default `selected = 1` (`:499`). No other speed label string exists in the file. | **observed** | **PASS (code, static)** |
| V4 | `refresh_speed` intact | `hud.gd:629-638` sets `speed_label.text` to `PAUSED` or `"%.0fx" % sp` (identical to `bak:491-493`) **and** adds dropdown mirroring: `want = 0 if paused else _speed_index(sp)`, assigned only when different (`:635-638`). The comment at `:632-634` states a programmatic `selected` assignment emits no `item_selected`, so no feedback loop into `speed_cb`. | **observed** | **PASS (code, static)** |
| V5 | `speed_cb` and dispatch intact / wired | `var speed_cb: Callable` at `:106`; `_on_speed()` at `:640-643` still calls `speed_cb.call(sp)`. New bridge: `_on_speed_idx()` (`:599-602`) reads `get_item_metadata(idx)` → `_on_speed()`; `item_selected.connect(_on_speed_idx)` at `:446`. `_speed_index()` (`:591-597`) maps a float back to an item within `0.01`, defaulting to index `1`. | **observed** | **PASS (code, static)** |
| V6 | `speed_label` readout is intentional, not a leftover button | `hud.gd:109,452-453` declares and adds a `Label` showing `1x`/`PAUSED`; it is a readout, not a clickable speed control, and is explicitly preserved by the `:441` comment. | **observed**, **derived** | **PASS (code, static)** |
| V7 | Landing is on disk but uncommitted | `git status --short`: `M variant3d/scripts/hud.gd`; backup and `variant3d/tests/t_hud_layout.gd` are `??`. Live file 86,604 B vs backup 80,873 B. | **observed** | **LANDED (working tree only)** |
| V8 | Owner report landed? | Repo-wide glob for `UI_TOPBAR_01.md` returns no file; `HUD_LAYOUT_01.md:47,185-189` also records its absence. | **observed** | **NOT LANDED** |
| V9 | HUD-layout atom speed-row result | `variant3d/tests/results/t_hud_layout.json` does **not** exist; results dir contains only `t_hud_fidelity.json`. `HUD_LAYOUT_01.md:1-13,205-214` declares authoring only, no Godot run, no PASS. Checks `single_speed_widget`/`speed_options`/`speed_option_metadata` are specified at `:128-129` but were never executed. | **observed** | **UNVERIFIED** — no result to pass or fail |
| V10 | Existing gate covers the dropdown? | `uitest.gd:275-280` calls `main.set_speed(2.0)` / `main.set_speed(1.0)` directly; it does not instantiate or click the dropdown, so it cannot detect a regression back to buttons. | **observed**, **inferred** | **GAP** — no dropdown-specific gate observed |
| V11 | Runtime behaviour / visual placement | No Godot process or windowed capture was run this pass. | — | **UNVERIFIED** |

**derived summary:** the speed control is converted in the working tree from four
`Button`s to exactly one `OptionButton` with intact label/metadata, `refresh_speed`
and `speed_cb` wiring, plus a new index bridge. This is a **static code landing**,
not a runtime PASS. The owner report is absent and the acceptance atom has not
produced a result JSON.

## 3. Donor-value divergence statement

**No parity claim is made.** The port dropdown and the donor speed model differ in
values, labels and widget form:

| Aspect | Donor (per `UITOP_DONOR_01.md`) | Port (live tree) |
|---|---|---|
| Step table | 3 modes `0/1/2` → factors `7/10/14`; mode `3=20` commented out (`dmscript.global:1025-1030`, T1) | 4 items `II/1x/2x/4x` → floats `0.0/1.0/2.0/4.0` (`hud.gd:444`), clamped `0.1..8.0` (`main.gd:362`) |
| Labels | **Normal / Fast / Very Fast**; `-1` = **Adjustable** (`tools.txt:197-206`, T4) | `II` (pause), `1x`, `2x`, `4x` — no Normal/Fast/Very Fast, no Adjustable |
| Pause | Separate flag (`GetProgressingPauseMode`), keys `Pause` / `Ctrl+Shift+P`; `Space` = camera-to-selected (T5, S8–S9, U4) | `II` item is a port pause convention; tooltip says "Space pauses" (`hud.gd:445`) |
| In-game top-bar widget | **None** — speed UI lives in settings/skirmish dropdowns and the pause overlay; no speed element in `showresourcepanel.inc` (U1–U4) | A top-bar dropdown is a port design addition |
| Key bindings | Static registrations in `registershortcuts.inc`; `hotkeys.cfg` has **zero** speed rows (H1–H3) | Not applicable to the widget; no donor key mapping reproduced |

Additional corroboration (**observed**): `variant3d/scripts/data.gd:384` labels
`{"slow":0.5, "normal":1.0, "fast":2.0, "very_fast":4.0}` as `DONOR_GAME_SPEED`,
but those floats are not the donor factors `7/10/14` — the constant is mislabelled
relative to donor truth. `UITOP_DONOR_01.md` §6 Q8 already records this as an owner
decision.

**Therefore:** the dropdown's `II/1x/2x/4x` values are **PORT APPROX** — they are
neither donor factors nor donor-labelled steps, and nothing in this pass establishes
behavioural or visual parity. They should be treated as port-only unless the owner
corrects them (rename the table as port-only, or add a true donor-mode mapping).
The R05 handler citation `:2079-2130` cited in prior docs is **wrong**; the real
handler is `onshortcut.inc:1010-1075` (`UITOP_DONOR_01.md:121,202`) — recorded here
to prevent a false locator from being reused.

## 4. HUD-layout atom result — speed row

**UNVERIFIED.** No `variant3d/tests/results/t_hud_layout.json` exists on disk, so
there is no `single_speed_widget`, `speed_options` or `speed_option_metadata` row to
report as pass or fail. `HUD_LAYOUT_01.md` explicitly disclaims a PASS
(`:1-13,205-214`); the atom was authored with those checks (`:128-129`) but never
run. No runner job was submitted by this worker, and none is inferred to have been
submitted by another. If a result appears later, its speed rows should be re-read
against V1–V3 and V9 above; the expected pre-fix failures documented at
`HUD_LAYOUT_01.md:151-154` are *predictions*, not outcomes.

## 5. Open questions

1. **Owner report** — `UI_TOPBAR_01.md` has not landed. When it does, re-check that
   its claimed item labels/metadata and responsive modes still match `hud.gd:444,
   495-498,581-583`; do not edit the atom green if they drift — raise an integration
   ticket (`HUD_LAYOUT_01.md:185-189`).
2. **Speed policy** — will the owner keep `II/1x/2x/4x` as port-only, rename
   `DONOR_GAME_SPEED`, or add a true donor mapping (`7/10/14`, Normal/Fast/Very
   Fast, `-1` Adjustable)? No parity claim is valid until this is decided.
3. **Dropdown-specific gate** — who adds a test that actually exercises the
   `OptionButton` (rather than `uitest.gd:276` calling `main.set_speed()` directly),
   and where is it registered?
4. **Atom execution** — who runs `t_hud_layout` and performs the mandatory
   second-agent capture re-check (`HUD_LAYOUT_01.md:202-203`)? Its speed rows remain
   UNVERIFIED until then.
5. **Runtime mirroring** — `refresh_speed()`'s `selected` mirroring is static-verified
   only; whether headless/windowed `item_selected` behaviour produces a feedback loop
   in practice is UNVERIFIED without a run.
6. **Line drift** — `hud.gd` is uncommitted and may be edited again by its owner;
   citations here are a 2026-11-25 snapshot.

## 6. Summary

- **Landed (static, code-level):** exactly one `OptionButton` speed widget
  (`hud.gd:112,444-447,490-502`), zero `MenuButton`/`PopupMenu`, zero leftover speed
  `Button`s (`speed_buttons` empty at `:108`), item texts `II/1x/2x/4x` with float
  metadata `[0.0,1.0,2.0,4.0]`, `refresh_speed()` intact and extended at `:629-638`,
  and `speed_cb` intact with a new `_on_speed_idx()` bridge at `:599-602`.
- **Not landed:** `reports/UI_TOPBAR_01.md` is absent. The change is an uncommitted
  working-tree edit (`git status M`) against the untracked
  `inbox/backup/hud.gd.bak-UITOPBAR01` baseline.
- **Donor divergence, stated plainly:** the port's `II/1x/2x/4x` floats are **not**
  the donor's `Normal/Fast/Very Fast` `7/10/14` factors, the donor has no in-game
  top-bar speed widget, no `4x`/`II` step and no `Space`-pauses binding; `hotkeys.cfg`
  has zero speed rows. All port speed values are **PORT APPROX** unless the owner
  corrects them. No donor parity is claimed.
- **HUD-layout atom speed row:** **UNVERIFIED** — no result JSON exists; no PASS or
  FAIL is assigned. No runtime, visual or windowed claim is made anywhere in this
  report.
- **Read-only compliance:** exactly one file was written — this report. No code,
  config, test, manifest or queue edit; no Godot process; no runner job.
