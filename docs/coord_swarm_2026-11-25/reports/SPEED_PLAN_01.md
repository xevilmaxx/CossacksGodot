---
id: SPEED-PLAN-01
title: "SPEED-PLAN-01 — minimal plan to align the HUD speed dropdown with donor speed truth"
area: coord_swarm_2026-11-25
task_id: SPEED-PLAN-01
date: 2026-11-25
owner: SPEED-PLAN-01 (read-only planning worker)
status: PLANNING_ONLY__NO_CODE_EDIT__NO_RUNNER__NO_PASS_CLAIM
scope: "Exactly ONE file written — this report. No .gd/.json/test/fixture/result-JSON/git/queue edit; no donor access; no Godot process; no gate promotion."
owns:
  - "docs/coord_swarm_2026-11-25/reports/SPEED_PLAN_01.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity: "NO donor-parity, visual-parity or runtime-PASS claim. Donor factor semantics are engine-side UNVERIFIED; all numeric port speed values stay PORT APPROX until a visual/runtime A/B exists."
output: docs/coord_swarm_2026-11-25/reports/SPEED_PLAN_01.md
---

# SPEED-PLAN-01 — align the HUD speed dropdown with donor speed truth

## 0. Label key and parity rule

| Label | Meaning |
|---|---|
| **observed** | Read directly this pass from the cited on-disk file/line. |
| **derived** | Structural consequence of observed rows (e.g. a rename forces two call-site edits). |
| **inferred** | Judgement about likely effect or mapping; never asserted as fact. |
| **UNVERIFIED** | Engine-side or runtime-only; no donor definition or result artifact exists. |
| **PORT APPROX** | Port value/label that is deliberately not donor-verbatim. Used for every numeric speed multiplier here because donor factor meaning is UNVERIFIED. |

**Parity rule:** this document is a plan only. No donor parity, visual parity or runtime PASS is claimed anywhere; parity requires a visual/runtime A/B that does not yet exist (`QA_SPEED_01.md:8,13,63,145-147`; `HUD_LAYOUT_01.md:180`). "Exact donor labels" below means the observed English strings, **not** a claim that the port's float multipliers equal donor factors.

---

## 1. Sources

| Source | Use | Label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/reports/UITOP_DONOR_01.md` (215 lines) | Donor speed truth: factors `7/10/14`, modes `0/1/2`, `-1` Adjustable, labels Normal/Fast/Very Fast (`:142-145` T1–T4, `:149` T8); `SetTimeSpeedFactor` engine-side UNVERIFIED (`:151` T10, `:197` §6 Q2); no top-bar speed widget (`:157-160` U1–U4); zero speed rows in `hotkeys.cfg` (`:117-119` H1–H3); handler `:1010-1075` not `:2079-2130` (`:121,202`); constraints 5/8/9 (`:186-190`) | observed (full read) |
| `docs/coord_swarm_2026-11-25/reports/QA_SPEED_01.md` (149 lines) | Landed dropdown `II/1x/2x/4x`, floats `[0,1,2,4]` (`:55` V3); `refresh_speed` / `speed_cb` intact (`:56-57` V4–V5); atom result absent (`:61` V9); `uitest.gd` bypass gap (`:62` V10); divergence table (`:76-93`); mislabelled constant (`:84-88`) | observed (full read) |
| `docs/coord_swarm_2026-11-24/reports/R05_hotkeys_controls.md` (86 lines) | Speed keys static registrations (`:32` row 17; `:65` mapping); donor `Pause` not `Space` (`:37` row 22; `:67`) | observed (full read) |
| `variant3d/scripts/data.gd:384,400` | `DONOR_GAME_SPEED := {"slow":0.5,"normal":1.0,"fast":2.0,"very_fast":4.0}`; `GAME_SPEED := "normal"` | observed |
| `variant3d/scripts/main.gd:354,361-362,626-632,721-724,1145-1151,1616` | Config enum + apply; two `speed_cb` wirings; `set_speed` clamp `0..8`; sim step `acc += dt * speed` | observed |
| `variant3d/scripts/hud.gd:106,108-112,444-447,490-501,581-583,591-602,629-638,640-643` | Dropdown items/metadata, index bridge, `refresh_speed`, `_on_speed`, sizing | observed |
| `variant3d/scripts/uitest.gd:274-280` | `speed_pause` gate calls `main.set_speed(2.0)`/`1.0` directly; never touches dropdown | observed |
| `variant3d/tests/t_hud_layout.gd:59-60,404-421` | Atom hard-codes `SPEED_LABELS = ["II","1x","2x","4x"]`, `SPEED_META = [0,1,2,4]` and gates on them | observed |
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_01.md:128-129,145-171` | Atom speed-row predicates and expected pre-fix failures; no-run declaration `:205-214` | observed |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:270-272` | Live owners: UI-TOPBAR-01 → `hud.gd`, LOAD-ASYNC-01 → `main.gd`, HUD-LAYOUT-01 → atom (all RUNNING) | observed |
| `docs/coord_swarm_2026-11-25/RUN_GUIDE.md:57`; `CAPTURE_RECHECK.md:250` | 17/17 uitest + 29/29 selftest + CLEAN gate definition | observed |
| `app/scripts/data.gd:333`, `app/scripts/hud.gd:95,365,423`, `app/scripts/main.gd:330,338` | 2D path has its own copy and four speed buttons; untouched by this plan | observed |

---

## 2. Donor truth table (exact labels and values)

All donor evidence is from the read-only verification in `UITOP_DONOR_01.md`; no donor file was read or copied in this pass.

| Donor mode | Factor (constant) | English label | Evidence | Label |
|---|---|---|---|---|
| `0` | `gc_settings_gamespeed_0 = 7` | **Normal** | `dmscript.global:1025`; `control.script:535-547,551-570`; `tools.txt:197-206` (`UITOP_DONOR_01.md:142-145` T1–T4) | observed (strings/constants); **factor meaning UNVERIFIED** (`:151,197`) |
| `1` | `_1 = 10` | **Fast** | same | observed; factor meaning UNVERIFIED |
| `2` | `_2 = 14` | **Very Fast** | same | observed; factor meaning UNVERIFIED |
| `-1` | no factor — online/map-enforced | **Adjustable** | `dmscript.global:1026`; `tools.txt:205-206`; dropdown count 3 offline / 4 online (`:149` T8) | observed (label), inferred (port cannot represent: no LAN replication) |
| `3` | `_3 = 20` (commented out) | none live | `dmscript.global:1030` (`UITOP_DONOR_01.md:142`) | intent-only `;` — must NOT be added |
| n/a | separate `GetProgressingPauseMode` flag | **Pause** keys `Pause` / `Ctrl+Shift+P`; `Space` = camera-to-selected | `onshortcut.inc:1040-1075,951-975`; `registershortcuts.inc:47-48,27,30`; `R05_hotkeys_controls.md:37,67` (`UITOP_DONOR_01.md:132-136` S6–S9) | observed — pause is **not** a donor speed step |

Additional donor facts that constrain the plan:

- Speed keys are static registrations (`Sub/Add/-/=`, `[`/`]`, `Ctrl+Sub/Add`); **`hotkeys.cfg` has zero speed rows** (`UITOP_DONOR_01.md:117-119,127-133` H1,H3,S1–S2) — observed census.
- **No in-game top-bar speed widget exists**; speed UI lives in settings/skirmish dropdowns and the pause overlay (`UITOP_DONOR_01.md:157-160` U1–U4) — observed census. A port HUD dropdown is a design addition, not donor parity.
- `7/10/14` are passed to engine APIs `SetTimeSpeedFactor`/`GetTimeSpeedFactor` via `WriteTimeSpeed`; no donor definition exists and `control.script:563` even has the direct call commented out (`UITOP_DONOR_01.md:151` T10, `:197` §6 Q2; `:143-147` T3,T5–T7) — **UNVERIFIED** whether they are multipliers, tick budgets or a clock divisor. **Therefore they must not be fed into the port's `acc += dt * speed`** (`main.gd:1616`).
- Real handler is `onshortcut.inc:1010-1075`; the `:2079-2130` locator in `R05_hotkeys_controls.md:32` and `UITOP_DONOR_01.md:121` is wrong and must not be copied into new docs — observed/correction.

---

## 3. Current port state (observed, read-only snapshot)

| Path:line | Current value / behaviour | Note |
|---|---|---|
| `data.gd:384` | `const DONOR_GAME_SPEED := {"slow":0.5,"normal":1.0,"fast":2.0,"very_fast":4.0}` | Mislabelled: floats are neither donor factors nor donor labels (`QA_SPEED_01.md:84-88`; `UITOP_DONOR_01.md:203` Q8). No donor `slow` step. |
| `data.gd:400` | `static var GAME_SPEED := "normal"` | Default key vocabulary consumed by `main.gd:354`. |
| `main.gd:354,361-362` | Config `gamespeed` validated against `Data.DONOR_GAME_SPEED.keys()`; if CLI did not force speed, `speed = clampf(float(...get(Data.GAME_SPEED,1.0)),0.1,8.0)` | Rename of the const forces these two call-site edits (derived). |
| `hud.gd:444` | `_mkoption([["II",0.0],["1x",1.0],["2x",2.0],["4x",4.0]],1)`; tooltip `Game speed (Space pauses)` at `:445` | Labels are port-only; tooltip contradicts donor `Space` semantics (R05 row 22). |
| `hud.gd:490-501` | `_mkoption`: `add_item(str(it[0]))`, `set_item_metadata(idx,float(it[1]))`, `selected = 1` | Generic helper — keep byte-identical. |
| `hud.gd:591-602` | `_speed_index(sp)` matches metadata within `0.01`, default `1`; `_on_speed_idx(idx)` reads metadata → `_on_speed(float)` | Bridge — keep byte-identical. |
| `hud.gd:629-638` | `refresh_speed` sets label `PAUSED`/`"%.0fx"` and mirrors `selected = 0 if paused else _speed_index(sp)`; programmatic `selected` emits no `item_selected` | Semantics to preserve (`QA_SPEED_01.md:56` V4). |
| `hud.gd:640-643`, `main.gd:626-632,1145-1151` | `_on_speed` → `speed_cb.call(sp)`; main: `s<=0` → `game.paused=true`, else unpause + `set_speed(s)` + `refresh_speed` | Semantics to preserve (`QA_SPEED_01.md:57` V5). |
| `main.gd:721-724`, `:1616` | `set_speed` clamps `0..8` then mirrors HUD; sim advances `acc += dt * speed` | Clamp/multiplier must stay: `uitest` asserts `main.speed == 2.0`. |
| `uitest.gd:274-280` | `speed_pause` calls `main.set_speed(2.0)` then `1.0`; no dropdown interaction | Bypass gate — preserving it keeps 17/17 (`QA_SPEED_01.md:62` V10). |
| `t_hud_layout.gd:59-60,404-421` | Atom expects exactly `["II","1x","2x","4x"]` / `[0,1,2,4]`; gates `single_speed_widget`, `speed_options`, `speed_option_metadata`, `no_legacy_speed_buttons` per viewport | Any label change requires a coordinated atom-literal update; no result JSON exists yet (`QA_SPEED_01.md:61` V9). |
| `app/scripts/**` (2D) | Separate `DONOR_GAME_SPEED` at `app/scripts/data.gd:333`, four speed buttons at `hud.gd:365` | Out of scope; 2D gates must remain green (`SWARM_BOARD.md:372`). |

**Ownership / conflict constraint (observed):** `hud.gd` belongs to **UI-TOPBAR-01** (RUNNING), `main.gd` to **LOAD-ASYNC-01** (RUNNING), and the atom to **HUD-LAYOUT-01** (RUNNING) (`SWARM_BOARD.md:270-272`; `PROGRESS.md:120`). `variant3d/scripts/data.gd` has no owner row in `SWARM_BOARD.md:270-277`, but an untracked backup `data.gd.bak-MORALE02` exists, so confirm before editing (observed via `git status --short`). **This plan is a hand-off specification, not a licence to edit those files concurrently.** Sequence: data.gd → (owner-coordinated) hud.gd + main.gd → atom literals → gates.

---

## 4. File-owned plan (minimal, each change assigned to one owner)

### 4.1 `variant3d/scripts/data.gd` — constants (owner: whoever holds data.gd; no active owner row)

1. **Rename the mislabelled table** `DONOR_GAME_SPEED` → `PORT_GAME_SPEED` and annotate it `PORT APPROX — port float multipliers for acc += dt * speed; NOT donor factors 7/10/14 (factor meaning UNVERIFIED)`. Keep keys `slow/normal/fast/very_fast` and floats `0.5/1.0/2.0/4.0` **unchanged** to preserve config vocabulary and saved profiles; mark `slow` as a port-only legacy key (donor has no slow step). Rationale: fixes the mislabelling defect (`UITOP_DONOR_01.md:203` Q8; `QA_SPEED_01.md:84-88`) without changing any runtime number (derived from `main.gd:354,362`).
2. **Add a separate donor-truth constant**, data-only, never applied to the sim:
   `DONOR_GAME_SPEED_MODES = [{"mode":0,"factor":7,"label":"Normal"},{"mode":1,"factor":10,"label":"Fast"},{"mode":2,"factor":14,"label":"Very Fast"}]`
   plus `DONOR_GAME_SPEED_ADJUSTABLE = -1` with comment `label "Adjustable"; online/map-enforced; not representable in port HUD`. Cite `dmscript.global:1025-1030`, `tools.txt:197-206`, `UITOP_DONOR_01.md:142-145,149`. Mark `factor semantics engine-side UNVERIFIED` (`UITOP_DONOR_01.md:151,197`). Do **not** add mode `3`/factor `20` (intent-only).
3. Keep `static var GAME_SPEED := "normal"` (`data.gd:400`) unchanged — default stays donor-labelled "Normal".

### 4.2 `variant3d/scripts/hud.gd` — labels (owner: **UI-TOPBAR-01**, hand-off only)

1. Change **only the label strings** passed to `_mkoption` at `hud.gd:444`, keeping metadata floats `0.0/1.0/2.0/4.0`, default index `1`, and the port pause row at index `0`:
   `["II",0.0]` → keep as the **port-only pause affordance** (flag `PORT APPROX`; donor pause is a separate flag, not a speed step — §2);
   `["1x",1.0]` → `["Normal",1.0]`;
   `["2x",2.0]` → `["Fast",2.0]`;
   `["4x",4.0]` → `["Very Fast",4.0]`.
   This makes the three speed rows donor-label-exact while preserving `_speed_index` (which matches metadata, not text) and `refresh_speed`'s paused→index-0 mirror (`hud.gd:591-597,635-638`).
2. **Do not touch** `speed_cb` (`:106`), `_mkoption` (`:490-501`), responsive sizing (`:581-583`), `_speed_index`/`_on_speed_idx` (`:591-602`), `refresh_speed` (`:629-638`), `_on_speed` (`:640-643`), `speed_label` (`:452-453`), or the single-widget structure (`:108-112,439-453`). These are exactly the predicates QA verified as PASS (`QA_SPEED_01.md:53-58` V1–V6).
3. Leave tooltip `:445` and the `Space`-pause convention unchanged **for this ticket**; log the donor conflict (`Pause`/`Ctrl+Shift+P` pause, `Space` = camera-to-selected; `R05_hotkeys_controls.md:37,67`) as a separate hotkey ticket (open question Q6). No hotkey behaviour is changed here.
4. Do **not** expose factor `7/10/14` in the dropdown: feeding them to `acc += dt * speed` would be a ~7–14x sim change and is UNVERIFIED (§2). Label alignment is the whole scope; metadata stays PORT APPROX.

**Why keep the `II` row:** removing it would break `speed_cb(0.0)` → `game.paused=true` (`main.gd:626-628,1145-1147`) and force a rewrite of `refresh_speed`'s paused mirror (`hud.gd:636`), violating the preserve-semantics requirement and donor constraint 5 ("keep a reachable speed/pause control", `UITOP_DONOR_01.md:186`). Dropping it is a larger separately-owned ticket if the owner prefers donor-pure labels (Q1).

### 4.3 `variant3d/scripts/main.gd` — speed application (owner: **LOAD-ASYNC-01**, hand-off only)

1. Update the two references to the renamed const: `main.gd:354` (`Data.DONOR_GAME_SPEED.keys()` → `Data.PORT_GAME_SPEED.keys()`) and `main.gd:362` (`Data.DONOR_GAME_SPEED.get(...)` → `Data.PORT_GAME_SPEED.get(...)`). No numeric change; config default "normal" and clamp `0.1..8.0` stay (derived from `data.gd` plan §4.1).
2. **Do not touch** `set_speed` (`:721-724`, clamp `0..8`), either `speed_cb` closure (`:626-632`, `:1145-1151`), or `acc += dt * speed` (`:1616`). `uitest.gd:276-279` depends on `set_speed(2.0)` leaving `main.speed == 2.0`; any multiplier/clamp change breaks the 17/17 gate (observed + derived).
3. Do **not** call `DONOR_GAME_SPEED_MODES` from the sim. It is documentation/data only until factor semantics are verified (UNVERIFIED). If a donor-facing mode API is wanted later, it belongs in a new ticket with its own gate.

### 4.4 `variant3d/tests/t_hud_layout.gd` — atom literals (owner: **HUD-LAYOUT-01**, hand-off only)

1. After the `hud.gd` label change lands, update `SPEED_LABELS` at `:59` to the exact new item array (pause row + `Normal`/`Fast`/`Very Fast`). Keep `SPEED_META` at `:60` as `[0.0,1.0,2.0,4.0]` — unchanged.
2. Keep all four speed predicates at `:399-421` verbatim: `single_speed_widget`, `speed_options`, `speed_option_metadata`, `no_legacy_speed_buttons`; keep `EPS = 2.0` (`:57`) and the `SKIP_CAPTURE`/loud-blank-frame policy (`:499-576`). **No assertion deleted, no threshold relaxed, no recorded-only row promoted** (no test weakening).
3. The atom must then be run by COORD/owner with a fresh `t_hud_layout.json` (`HUD_LAYOUT_01.md:96-113`). This plan submits no runner job.

---

## 5. Acceptance gates

| Gate | Requirement | Evidence / label |
|---|---|---|
| **A1 — static label alignment** | Dropdown item texts are exactly the port pause row + donor labels `Normal`, `Fast`, `Very Fast` in that order; metadata floats remain `[0,1,2,4]`; no `slow`/`II`-as-speed/`1x`/`2x`/`4x` speed row; no leftover speed Buttons | `hud.gd:444,495-498`; `QA_SPEED_01.md:53-57` V1–V5 — **observed target** (not yet achieved) |
| **A2 — semantics preserved** | `speed_cb`, `_on_speed`, `_speed_index`, `_on_speed_idx`, `refresh_speed`, `set_speed` clamp and `acc += dt * speed` byte-identical; pause still routes through `s<=0`; atom literals updated in lockstep | `hud.gd:591-602,629-643`; `main.gd:626-632,721-724,1616`; `t_hud_layout.gd:59-60` — **derived** requirement |
| **A3 — HUD-layout atom speed row** | `variant3d/tests/results/t_hud_layout.json` exists; `single_speed_widget`, `speed_options`, `speed_option_metadata`, `no_legacy_speed_buttons` **PASS at 1024×576, 1280×720 and 1920×1080**; headless capture rows are `SKIP_CAPTURE` (never PASS); windowed A/B still required for any visual claim | `t_hud_layout.gd:53,399-421,499-576`; `HUD_LAYOUT_01.md:117-143`; currently no result JSON (`QA_SPEED_01.md:61` V9) — **UNVERIFIED** until run |
| **A4 — uitest 17/17** | Fresh `variant3d/uitest.json` `"passed": true`, **17/17**, including `speed_pause`; the direct `main.set_speed()` bypass stays valid; selftest 29/29 and 2D gates 29/29 + 17/17 + CLEAN untouched | `RUN_GUIDE.md:57`; `uitest.gd:274-280`; `SWARM_BOARD.md:372` — **observed gate definition**, fresh result UNVERIFIED |
| **A5 — no test weakening** | Zero deleted assertions, zero relaxed thresholds (`EPS`, `0.01`, `0.001`, `0.1` all unchanged), no FAIL→PASS edit, no result promoted by this plan | `HUD_LAYOUT_01.md:139-143,168-171`; `t_hud_layout.gd:57,338,410,421`; `QA_SPEED_01.md:30-31` — **observed** requirement |
| **A6 — PORT APPROX honesty** | Every numeric speed value in the report and in code comments is labelled PORT APPROX; donor `7/10/14` recorded but never applied; no parity claim until visual/runtime A/B | `UITOP_DONOR_01.md:151,197`; `QA_SPEED_01.md:90-96,145-147`; frontmatter `parity` — **observed/derived** |

**Explicit PORT APPROX flags:** port multipliers `1.0/2.0/4.0` (and legacy `slow:0.5`), clamp `0.1..8.0` / `0..8`, the `II` pause row, the tooltip, and any mode→float mapping are **PORT APPROX / INFERRED**, because donor factor semantics are engine-side UNVERIFIED (`UITOP_DONOR_01.md:151,197`). The label strings `Normal`/`Fast`/`Very Fast`/`Adjustable`, mode ids `0/1/2/-1` and constants `7/10/14` are **observed** donor data — but observed constants are not verified behaviour.

---

## 6. Open questions

1. **Pause row** — keep `II`/`0.0` as port-only pause (recommended, preserves `refresh_speed` mirror) or remove it for donor-pure three-row labels (requires a coordinated `refresh_speed` + atom rewrite)? Decision by UI-TOPBAR-01/HUD-LAYOUT-01. [inferred risk]
2. **Factor semantics** — are `7/10/14` multipliers, tick budgets or a clock divisor? Engine-side `SetTimeSpeedFactor` has no donor definition (`UITOP_DONOR_01.md:151,197`). **UNVERIFIED**; blocks any numeric parity claim.
3. **`Adjustable` (-1)** — online/map-enforced; port has no LAN replication path for it. Represent as a disabled/explanatory item or omit? Currently omitted by the plan; [inferred].
4. **Ownership timing** — all three target files have RUNNING owners (`SWARM_BOARD.md:270-272`). Who executes the hand-off and in which session, without overwriting uncommitted `hud.gd` edits? [observed conflict]
5. **Config back-compat** — any saved profile using `slow` or old float semantics; does keeping the legacy key in `PORT_GAME_SPEED` suffice? `variant3d/config.json` has no `gamespeed` key this pass [observed], but user-saved configs were not read [UNVERIFIED].
6. **Tooltip/hotkey conflict** — `hud.gd:445` says "Space pauses" while donor `Space` = camera-to-selected and pause is `Pause`/`Ctrl+Shift+P` (`R05_hotkeys_controls.md:37,67`). Separate hotkey ticket; not changed here. [observed conflict]
7. **Visual A/B** — no donor frame exists on disk; headless atom rows are `SKIP_CAPTURE` (`HUD_LAYOUT_01.md:180`; `t_hud_layout.gd:499-504`). Visual parity remains UNVERIFIED even after the structural atom passes.
8. **Line drift** — `hud.gd`, `data.gd` and `main.gd` are modified working-tree files; all citations are a 2026-11-25 snapshot and may move after owner edits [observed].
9. **2D path** — `app/scripts/**` keeps its own mislabelled constant and four buttons (`app/scripts/data.gd:333`, `hud.gd:365`); deliberately out of scope so the 2D gates stay green [observed].

---

## 7. Summary

- The donor's game-speed truth is **three** steps — mode `0/1/2` → factors `7/10/14` labelled **Normal / Fast / Very Fast**, plus `-1` **Adjustable** online — with pause as a **separate** flag; keys are static registrations, `hotkeys.cfg` has no speed rows, and there is **no** donor in-game top-bar speed widget (`UITOP_DONOR_01.md:117-160`). Factor *meaning* is engine-side **UNVERIFIED** (`:151,197`).
- The port's live dropdown offers `II/1x/2x/4x` with floats `[0,1,2,4]` and a mislabelled `DONOR_GAME_SPEED` constant (`QA_SPEED_01.md:55,84-88`). **No parity claim** is made.
- Minimal plan: **data.gd** renames the mislabelled table to `PORT_GAME_SPEED` (numbers unchanged) and adds a donor-truth data constant with the exact labels/modes/factors; **hud.gd** (UI-TOPBAR-01) swaps the three speed labels to the exact donor strings while keeping the port pause row and all metadata/callback plumbing; **main.gd** (LOAD-ASYNC-01) only updates the two renamed-const references; **t_hud_layout.gd** (HUD-LAYOUT-01) updates its label literal in lockstep. Sim multiplier, clamps, `speed_cb`/`refresh_speed` and the `uitest` `set_speed()` bypass remain untouched.
- Acceptance: donor-exact labels + unchanged metadata (A1/A2), atom speed rows PASS at all three viewports with a fresh result JSON (A3), uitest **17/17** and selftest 29/29 (A4), zero test weakening (A5), and explicit **PORT APPROX** on every numeric speed value until a visual/runtime A/B exists (A6).
- Planning only: no code, config, test, result JSON, git state or queue was changed; no Godot job was run; no PASS was promoted.
