---
id: G19
title: "G19 — donor hotkey / control-group contract vs the 3D port (proposals only)"
area: variant3d / selection hotkeys / control groups / recruitment modifiers
owner: G19 (READ-ONLY audit subagent)
date: 2026-11-25
status: READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_RUNNER_JOBS__PROPOSALS_ONLY
scope: "Read-only audit of variant3d/scripts/{input_controller.gd,hud.gd,game.gd,config.gd,uitest.gd,world3d.gd,world3d_fx.gd}, variant3d/config.json, variant3d/uitest.json, the landed D05/F03/B05 reports and the gamepressure UI guide (charter §6 URL, fetched this session). No code, config, test, asset, gate, queue or git state touched. Exactly one file written — this report."
labels: [observed, derived, inferred, UNVERIFIED, DONOR_CITED, PORT_APPROXIMATION, ALREADY_FIXED_BY_B05]
donor: "gamepressure 'Cossacks 3: User interface' https://www.gamepressure.com/cossacks3/user-interface/zd91b1 (live webfetch this session, last update 17 Oct 2016) + F03 sources S3/S4 as landed online recon. No donor binary, no donor GPU A/B frame."
---

# G19 — donor hotkey/control-group contract vs the 3D port

Label key: **[O]** observed in a cited file/artifact; **[D]** derived from observed control flow;
**[I]** inferred; **UNVERIFIED** = no live key test / no donor A/B evidence obtained.
All `file:line` values refer to the **current working tree at audit time**
(`input_controller.gd` is 1572 lines; its numbering moved after B05's edits, so D05's
line numbers are stale). Donor parity is never claimed: donor text is **DONOR_CITED**,
port substitutions are **PORT APPROXIMATION**.

## 0. Executive verdict

1. **[O] Donor contract confirmed** from the live guide + F03: control groups `Ctrl+0..9`
   assign / `Alt+0..9` select / `Shift+0..9` add (guide states the 0–9 assign form;
   F03 S4 §8.1–8.3 supplies the full native map and the green `TXGroupSelectionViewer`
   highlight), `Ctrl+A`, `Z` / `Ctrl` / double-click same-type with `Shift` add,
   `DELETE` deny-capture, `Shift` ×5 / `Ctrl` unlimited recruitment.
2. **[O] Six of the eight contract items are implemented in code** in the 3D port;
   `Ctrl+A`, `Z`, `Ctrl`-click and the recruitment modifiers are **code-complete but
   live-key UNVERIFIED** (no runner atom names them). `DELETE` and `Ctrl+1`/`1` are the
   only contract keys with a green runner step (`uitest.json:50-53,65-68`).
3. **[O] What remains is a control-group/verification gap, not a same-type-selection gap.**
   D05's four open click defects (#1–#4) were closed by B05 in the current tree. The live
   gaps are: no group **0**, no donor **Shift+add** group semantics (port uses `Shift+digit`
   to jump the camera), no dedicated **Alt+0..9** path (Alt+1..9 selects only by accident
   of an unguarded `else`), no **green group highlight**, and one **recruitment subtract
   asymmetry** (RMB removes a whole batched job and ignores `Shift`).
4. **[I] Smallest disjoint repair set = three tickets** (H1 groups/hotkey conflicts,
   H2 green highlight, H3 recruitment subtract), each owning a different file set;
   see §6. **No file was edited by G19; H1 would own B05's `input_controller.gd` only after
   a fresh backup and a different owner — this report is proposal-only.**

---

## 1. Sources read (read-only)

| Source | What it establishes |
|---|---|
| `https://www.gamepressure.com/cossacks3/user-interface/zd91b1` (fetched with webfetch this session) | Verbatim donor key text for grouping, DELETE, Shift-add, same-type/Z/Ctrl/double-click, Ctrl+A, Shift ×5, Ctrl unlimited, Shift path. |
| `docs/.../reports/F03_selection_online.md:123-191,224-243,279-292` | S3 guide quotes and S4 almanac native map: reserved digits, `Ctrl/Shift/Alt+0..9`, `TXGroupSelectionViewer` green highlights, gaps G7/G8. |
| `docs/.../reports/D05_selection_ui.md:47-85` | D05's ranked defects and its "already correct" table; **superseded** where B05 landed. |
| `docs/.../reports/B05_selection_impl.md:8,34-36` | B05 owned `input_controller.gd`; backup path and current-size note. |
| `variant3d/scripts/input_controller.gd:57,167,340-372,671-702,762-992,1173-1475` | Hotkey resolver, click branch, digit/group branch, select-family combos, DELETE. |
| `variant3d/scripts/hud.gd:928-989`, `variant3d/scripts/game.gd:4169-4266,4633-4640` | Recruitment modifier dispatcher, batch/infinite sim, DELETE sim call. |
| `variant3d/scripts/config.gd:183-224`, `variant3d/config.json:160-204` | Bound hotkeys and shipped overrides. |
| `variant3d/scripts/world3d.gd:526-559`, `variant3d/scripts/world3d_fx.gd:732-775,1244-1351` | Selection-ring/owner feedback; no group consumer. |
| `variant3d/scripts/uitest.gd:289-302`, `variant3d/uitest.json:50-53,65-68,80-83` | The only runner steps touching group/DELETE/hotkeys. |
| `variant3d/tests/` grep | **No** `t_hotkey*`/`t_group*` atom exists; no Ctrl+A/Z/modifier-recruit key test found. |

---

## 2. Donor contract (DONOR_CITED)

All quotes below are from the live gamepressure page unless a F03 source id is given.

| # | Action | Donor binding | Evidence |
|---:|---|---|---|
| C1 | Assign control group | **Ctrl + 0..9** | "Unit and building groupping: CTRL + a number from 0 to 9." F03 S4 §8.2 adds `Ctrl+0..9`=assign, `Shift+0..9`=add, `Alt+0..9`=select, `Shift+Alt+0..9` reserved; §8.1: `0`–`9` and `NUM0`–`NUM9` reserved for group select. |
| C2 | Recall group | bare **0..9** / `NUM0..NUM9`; **Alt+0..9** select | F03 S4 §8.1–8.2 (native map). |
| C3 | Add to group | **Shift+0..9** | F03 S4 §8.2. |
| C4 | Group feedback | **green highlights** around units of the active group (`TXGroupSelectionViewer`, native) | F03 S4 §8.3. |
| C5 | Select whole army | **Ctrl+A** | "CTRL + A will select every unit on the map." |
| C6 | Same type | **double-click**, **Ctrl+click**, or **Z**; **Shift** adds more | "Double clicking a unit, clicking a unit while holding CTRL, or selecting a unit and pressing Z selects all units of the same kind. Combine this with holding SHIFT to instantly add more units to selection." F03 S4 §7.3 adds `Shift+Z`, `Ctrl+Z`, `Ctrl+Shift+Z` (`Repeat=True` cycles). |
| C7 | Deny capture | **DELETE** destroys own units/buildings so the enemy cannot loot them | "DELETE - you can terminate your units and buildings. It can be used as scorched earth tactic: if the enemy is sure to capture your buildings/units you can destroy them, and deny the opponent loot." |
| C8 | Queue orders | LMB add, RMB subtract; **Shift = five at a time**; **Ctrl = unlimited** | "left click adds a unit to queue, and right click subtracts a unit from cueue. If you hold SHIFT, you will add/subtract fife units at a time. Holding CTRL will set the recruitment to unlimited mode". |
| C9 | Shift path | Holding **SHIFT** sets a waypoint path | "By holding SHIFT you can set a path for your troops to follow." Port's `P` two-click route is a PORT APPROX (input_controller.gd:1283-1287), not audited further here. |

**Not a contradiction:** the guide's "Ctrl+N group" describes the common assign action;
S4 documents the full native modifier map. Both are **observed**; where S4 is more
specific, this report uses it and labels it F03-S4-derived (not independently re-fetched).

---

## 3. Port audit matrix

Status key: **IMPLEMENTED** (code observed), **PARTIAL**, **ABSENT**, **CONFLICT**,
**PORT APPROX**, **FIXED-B05**; the separate "Verification" column is where live-key
evidence is missing.

| # | Donor item | Port implementation (`file:line`) | Status | Verification |
|---:|---|---|---|---|
| C1 | `Ctrl+0..9` assign | `input_controller.gd:1218-1225` — `KEY_1..KEY_9` → `gi=1..9`; `groups[gi]=ids` of current selection | **PARTIAL** — group `0` absent; `Ctrl+Shift+digit` also assigns (no `shift/alt` guard) | `uitest.json:65-68` green for **Ctrl+1** only, via synthetic `InputEventKey` straight into `_handle_key` (`uitest.gd:289-302`); Ctrl+0/2..9 **UNVERIFIED** |
| C2 | bare / Alt `0..9` select | `input_controller.gd:1226-1233` — the `else` branch runs for **any** non-Ctrl digit, including `Alt+digit`; recalls `groups[gi]`, no `0` | **PARTIAL / accidental** — Alt+1..9 works by lack of an `alt_pressed` test, not by a donor contract path; numpad and `0` absent | bare `1` green in the same `groups` step; **Alt+digit UNVERIFIED** |
| C3 | `Shift+0..9` add to group | `input_controller.gd:1234-1245` — with Shift held the port recalls the group **and jumps the camera to its first entity** | **CONFLICT / ABSENT** — no union-into-group code; `groups` is written only at `:1224` (repo-wide grep) | no runner step; **UNVERIFIED** |
| C4 | green group highlight | none. `groups` has no visual consumer; rings use the donor **player** colour at `world3d_fx.gd:1254-1288` and `:1312-1324`, fed by `world3d.gd:535-559` | **ABSENT** | no capture; **UNVERIFIED** visually |
| C5 | `Ctrl+A` select all army | `config.json:168`, `input_controller.gd:1455-1459` → `game.units_of(0)` (`game.gd:2971`) | **IMPLEMENTED** (own units; donor "every unit on the map" most plausibly own — PORT APPROX on wording) | **UNVERIFIED** — `uitest.json` `hotkeys_live` names only hold_fire/engage/attack_ground (`:80-83`) |
| C6a | `Z` same type | `config.json:171`, `input_controller.gd:1467-1475`; `Shift+Z` `:1427-1435`; `Ctrl+Z`/`Ctrl+Shift+Z` via `_donor_combo` `:1256-1261` + `config.gd:214-215` | **IMPLEMENTED** | **UNVERIFIED** live; plain double-click was runtime-observed in an earlier job (`D05_selection_ui.md:81`, CAM_RV-01) |
| C6b | `Ctrl`+click remove / same-type | `input_controller.gd:899-925` (remove `:903-908`, same-type `:909-925`) | **FIXED-B05** (D05 #1/#2) | **UNVERIFIED** live-key; click path code-observed |
| C6c | double-click same-type + Shift add | `input_controller.gd:877-898`; Shift union `:885-898` | **FIXED-B05** (D05 #4) | plain case runtime-observed (D05 :81); Shift case **UNVERIFIED** |
| C6d | Shift-add click / drag | click `:928-932`; drag union `:678-691`; empty-ground Shift click `:933-937` keeps selection | **FIXED-B05** (D05 #3 + existing drag) | real-drag PASS recorded by D05 :79; empty-ground Shift click **UNVERIFIED** |
| C7 | `DELETE` deny capture | `input_controller.gd:1308-1324` → `game.cmd_delete` `game.gd:4633-4640` (`_kill(e,null,false)`, score preserved) | **IMPLEMENTED** as self-destruction; "deny loot" outcome **UNVERIFIED** (no loot model audited) | `uitest.json:50-53` `delete_key` PASS (owned peasant) |
| C8a | `Shift` LMB queue ×5 | `hud.gd:928,955-956` → `game.gd:4204-4236` (`TRAIN_BATCH=5`, one paid job with `count=5`) | **IMPLEMENTED** code | **UNVERIFIED**; `uitest.json:25-28` `train_flow` covers only queue 0→1 |
| C8b | `Ctrl` unlimited recruitment | `hud.gd:957-958` → `game.gd:4238-4246` (`infinite:true` jobs, re-armed at `:5697`); label `∞` at `hud.gd:941-943` | **IMPLEMENTED** code | **UNVERIFIED** live/modifier |
| C8c | RMB subtract, `Shift+RMB` subtract ×5 | `hud.gd:977-982` → `game.gd:4249-4264` `cancel_train()` reads **no modifier** and removes a **whole job** (`count` may be 5 or 100) | **ABSENT / PARITY GAP** — donor subtracts 1 (or 5 with Shift) *units*, not the entire batch | **UNVERIFIED** live; code-derived gap |
| — | Digit-key conflict | `input_controller.gd:1218-1246` is an unconditional early `return` for **all** `KEY_1..KEY_9` presses with any modifier set; build-menu keys at `:1345-1357`/`config.json:173-188` preempt unit orders at `:1358-1475` | **CONFLICT** (Shift digit = camera jump vs donor add; Ctrl+Alt digit = assign; any future digit-bound action is shadowed). Build-menu preemption is a **context conflict**, donor parity UNVERIFIED | **UNVERIFIED** live beyond Ctrl+1/1 |
| — | `Alt+M` minimap | `config.json:203`, `input_controller.gd:1436-1438` | no conflict with digit groups | **UNVERIFIED** live |

### 3.1 What B05 closed (do not re-litigate)

**[O]** The current click branch at `input_controller.gd:873-942` contains all four D05
fixes. This report treats D05 rows #1–#4 as **closed by B05** and proposes no edits there:

| D05 defect | B05 code now | Evidence |
|---|---|---|
| #1 Ctrl+click same-type | `:899`, `:909-925` (`game.units_of(0)` filtered by `sid`) | current tree |
| #2 Ctrl+click remove | `:903-908` (id removed from `get_selected()`, `_set_selection`) | current tree |
| #3 Shift+click empty ground no deselect | `:933-937` (`pass`, no `_set_selection([])`) | current tree |
| #4 Shift+double-click adds | `:885-898` (dedup union before `_set_selection(arr2)`) | current tree |

`B05_selection_impl.md:8` confirms exclusive ownership of `input_controller.gd` for that
ticket and an external backup; any follow-up touching that file needs its **own** owner
and backup (see H1).

---

## 4. Remaining gaps, ranked

| Rank | Sev | Gap | Why it matters | Basis |
|---:|---|---|---|---|
| 1 | **P1** | Group `0` missing, `Shift+digit` = camera jump instead of donor add, `Ctrl+Shift+digit` silently assigns, Alt-select is an accident of an unguarded `else` (`input_controller.gd:1218-1246`) | Core RTS control contract; also shadows any future digit binding | **[O]** code + **[O]** F03 S4 §8.1–8.2 |
| 2 | **P2** | No green active-group highlight (`world3d.gd:535-559`, `world3d_fx.gd:1254-1288`) | Donor `TXGroupSelectionViewer` feedback absent; recalled groups are indistinguishable | **[O]** repo-wide grep + **[O]** F03 S4 §8.3 |
| 3 | **P2** | RMB subtract ignores Shift and deletes the whole batched job (`hud.gd:977-982`, `game.gd:4249-4264`) | Breaks the donor "1 / ×5 at a time" subtraction contract; with Ctrl+Alt (100) a single RMB removes 100 units | **[D]** code + **[O]** guide C8 |
| 4 | **P2** | No live-key atom for Ctrl+A, Z/Ctrl+Z, Alt+digit, group 0, Shift+digit, recruitment modifiers (`uitest.gd:289-302` covers only Ctrl+1/1; `uitest.json:80-83` names other keys) | All those rows stay **UNVERIFIED**; a green gate cannot be claimed | **[O]** artifacts |
| 5 | **P3** | Context conflict: build menu `:1345-1357` shadows `S`/`L`/etc. unit orders when open (build keys `config.json:173-188`) | Possible owner-visible key surprise; **do not change** without donor/owner decision | **[D]**; donor parity UNVERIFIED |

---

## 5. Proposal rules

- **Disjoint file ownership:** each ticket below owns a different file set. H2 depends on
  data H1 exposes but **does not edit H1's file**; H3 is independent.
- **Backups** before any edit: `inbox/backup/<file>.bak-<TICKET>` (Wave G charter §guardrails).
- **Runner:** G19 ran none. Only **G04** submits Godot jobs during Wave G; atoms authored
  by H1/H2/H3 are executed by G04 or a later runner owner.
- **No donor parity claim** until a donor frame/key trace exists; all new visuals labelled
  `PORT APPROXIMATION` / `DONOR_CITED + UNVERIFIED raster`.
- H1 is explicitly a *new* owner for B05's former file; **this report changes nothing in it**.

---

## 6. Smallest disjoint follow-up tickets (proposal only)

### H1 — Control-group + digit-hotkey contract  (P1)

**Owner files:** `variant3d/scripts/input_controller.gd` **only** + NEW atom
`variant3d/tests/t_group_hotkeys.gd` (same owner).
**Backup:** `inbox/backup/input_controller.gd.bak-H1` before first edit.

**Exact sites / changes (proposed, not applied):**
- `input_controller.gd:57` — add `active_group: int` (0–9) for H2; keep `groups: Dictionary`.
- `input_controller.gd:1218-1225` — accept `KEY_0` (`gi := 0` for `KEY_0`, else
  `keycode - KEY_1 + 1`); `Ctrl` **and not Shift and not Alt** ⇒ assign; copy only
  live own-entity ids into the group (current code stores raw `get_selected()` ids,
  which can include an enemy picked for info — label any filter change PORT APPROX).
- `input_controller.gd:1226-1233` — bare digit or `Alt+digit` ⇒ recall group, set
  `active_group`, no camera move (donor C2).
- `input_controller.gd:1234-1245` — `Shift+digit` ⇒ **union new ids into `groups[gi]`**
  (dedupe by id, preserve existing order) then recall; **do not jump the camera** on
  this chord unless the owner explicitly keeps the jump as a non-donor convenience.
  This resolves the C3 conflict and the unconditional-`return` shadowing at `:1246`.
- Leave the B05 click branch `:873-942`, `_donor_combo` `:1177-1183` and the select
  family `:1250-1261` byte-identical.

**Acceptance atom** (`t_group_hotkeys.gd`, synthetic `InputEventKey` → `_handle_key`, same
pattern as `uitest.gd:289-302`): Ctrl+3 assign → 3 recall; Alt+3 recall; Shift+3 adds a
new unit without dropping the old; Ctrl+0 / 0 round-trip; assert no camera `jump_to_world`
call on Shift+3; re-run the existing `groups` uitest step unchanged.

### H2 — Green active-group highlight  (P2, disjoint from H1)

**Owner files:** `variant3d/scripts/world3d.gd`, `variant3d/scripts/world3d_fx.gd`
(+ optional NEW capture atom `variant3d/tests/t_group_highlight.gd`). **No**
`input_controller.gd` edit.

**Exact sites / changes (proposed, not applied):**
- `world3d.gd:535-559` (`_sync_selection_aura`) — add an `in_group: bool` field to each
  `sync_selection` entry. Read `active_group`/`groups` **read-only** from the node in
  group `c3_input` (`input_controller.gd:167`) via
  `get_tree().get_first_node_in_group("c3_input")`; no write back. If H1 has not landed,
  derive "active" by matching the current selection to a stored group and label the
  fallback `PORT APPROXIMATION`.
- `world3d_fx.gd:732-775` (`sync_selection`) — pass the flag through to
  `_make_selection_marker` / `_set_selection_color`.
- `world3d_fx.gd:1254-1288` and `:1312-1324` — tint the **ring** green
  (`TXGroupSelectionViewer`, F03 S4 §8.3) for `in_group` entities while keeping the
  player-colour owner pip and the deterministic pulse at `:1342-1350`. Label the tint
  `DONOR_CITED (semantics) + PORT APPROX (pixels); donor raster UNVERIFIED`.

**Acceptance:** a capture/probe shows green-dominant rings only for the active group's
selected members, normal player-colour rings otherwise; no change to selection-set
semantics or to `game.*`/HUD state.

### H3 — Recruitment subtract contract  (P2, disjoint from H1/H2)

**Owner files:** `variant3d/scripts/hud.gd`, `variant3d/scripts/game.gd`
(+ NEW atom `variant3d/tests/t_train_modifiers.gd`).

**Exact sites / changes (proposed, not applied):**
- `hud.gd:977-982` (`_on_train_gui`, RMB) — read `KEY_SHIFT` (and decide explicitly
  whether `Ctrl` is meaningful on subtract) and call a count-aware cancel API instead
  of the zero-argument `cancel_train`; keep the 80 ms dedup at `:976/:984` and the
  LMB path `:983-989` byte-identical.
- `game.gd:4249-4264` (`cancel_train`) — accept an explicit amount (1 default,
  5 for Shift as in `hud.gd:928` `TRAIN_BATCH`), refund per unit and remove partial
  job `count` rather than the whole job. Preserve the `∞` job handling at `:4256` and
  the `Ctrl` unlimited add path `game.gd:4238-4246` / `hud.gd:957-958`.
- **Owner decision required:** donor semantics are "subtract 1 / 5 units"; the port
  models batches as one paid job. Decide whether a partial refund is acceptable before
  implementation — do **not** silently flip the batched-job model.

**Acceptance atom:** queue a 5-batch with Shift+LMB, RMB once → 4 left and one-unit
refund; Shift+RMB → 5 removed; Ctrl+LMB still yields an `∞` job; no train-unit changes.

### Verification ledger (fold into H1/H2/H3, no extra ticket)

The atoms above close the **UNVERIFIED** cells in §3 for their own feature only. Until a
runner executes them, `Ctrl+A`, `Z`/`Ctrl+Z`, `Alt+digit`, group 0, `Shift+digit`,
green highlights and recruitment modifiers must stay labelled **UNVERIFIED**

---

## 7. Open questions for COORD / owner

1. Keep the port's `Shift+digit` camera jump as a convenience under a different chord,
   or remove it entirely to honour donor `Shift+0..9` = add? (H1 decision.)
2. Bind `0` and `NUM0..NUM9`, and should `Alt+digit` get a distinct code path rather than
   relying on the current unguarded `else`? (H1 decision.)
3. Is a partial refund of a 5/100 paid batch acceptable, or should the port keep
   whole-job cancellation and document the divergence? (H3 decision.)
4. Does the donor build menu shadow unit-order keys as the port does at `:1345-1357`?
   No donor A/B key trace — **UNVERIFIED**; do not change on this report's authority.

---

## 8. Scope / honesty statement

- **Exactly one file was written: this report.** No code, config, test, asset, scene,
  gate, queue or git state was modified. No Godot process, runner job or donor binary
  was run; no donor GPU A/B frame was produced.
- The donor key text was **fetched read-only this session** from the charter's
  gamepressure URL; the fuller modifier map and green-highlight claim are quoted from
  the landed F03 report (S4 almanac recon), **not** independently re-fetched here.
- All port-side "live key" statements are either **[O]** control-flow reads or runner
  artifact reads; where an atom does not name a key, the row is **UNVERIFIED**, not green.
- Donor parity of port visuals/audio/loot semantics remains **UNVERIFIED** per charter
  guardrail 1. The `DELETE` "deny loot" outcome is code-observed as self-destruction
  only; no loot model was audited.
- H1/H2/H3 are **proposals only**. H1 names B05's former file as a future owner's
  responsibility; this audit did not touch it.

---
*G19, 2026-11-25. READ-ONLY. Donor contract established, port audit tabled, three disjoint follow-up tickets proposed.*
