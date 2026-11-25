---
id: QA-SPEED-ALIGN-01
title: "QA-SPEED-ALIGN-01 — check whether SPEED_PLAN_01 was applied; keep pending if not"
area: coord_swarm_2026-11-25
task_id: SPEED-ALIGN-01
date: 2026-11-25
owner: QA-SPEED-ALIGN-01 (read-only QA subagent)
status: DONE__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT_ONLY
scope: "Read-only on-disk check of the four SPEED_PLAN_01 changes against current variant3d speed literals. No .gd/.json/test/config/fixture/queue edit; no Godot process; no godot_runner.py job; no result JSON written or hand-edited; no report promoted to PASS."
owns:
  - "docs/coord_swarm_2026-11-25/reports/QA_SPEED_ALIGN_01.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity: "NO donor-parity, visual-parity or runtime-PASS claim. Donor factor semantics (7/10/14) are engine-side UNVERIFIED; every numeric port speed value stays PORT APPROX. This report checks only whether the planned static edits landed."
output: docs/coord_swarm_2026-11-25/reports/QA_SPEED_ALIGN_01.md
---

# QA-SPEED-ALIGN-01 — SPEED_PLAN_01 application check

## 0. Label key

| Label | Meaning in this report |
|---|---|
| **observed** | Read directly this pass from the cited on-disk file/line, grep sweep, file listing or `git status --short`. |
| **derived** | Structural consequence of observed rows (e.g. a rename forces every call site to move). |
| **inferred** | Judgement about likely effect or risk; never asserted as fact. |
| **UNVERIFIED** | Engine-side, runtime-only or visual-only; no donor definition or A/B artifact exists. No absent artifact is assigned a cause. |
| **PORT APPROX** | Port value deliberately not donor-verbatim. Applied to every numeric speed multiplier/factor mapping below, because donor factor meaning is UNVERIFIED. |

**Parity rule:** this is a static landing check only. No donor parity, visual parity or runtime PASS is claimed. The `Normal`/`Fast`/`Very Fast` strings are donor-observed data, not proof that the port floats equal donor factors `7/10/14` (`SPEED_PLAN_01.md:29,58-60,69,144`; `QA_SPEED_01.md:90-96,145-147`).

---

## 1. Sources

| Source | Use | Label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/reports/SPEED_PLAN_01.md` (168 lines) | The four planned changes and their target lines: const rename `:99` + donor-truth constant `:100-102`, hud labels `:107-112`, main refs `:121`, atom literals `:127`; parity rule `:29,144`; ownership constraint `:91` | **observed** (full read) |
| `docs/coord_swarm_2026-11-25/reports/QA_SPEED_01.md` (149 lines) | Pre-plan state: landed `II/1x/2x/4x` labels `:55`, mislabelled const `:84-88`, no result JSON at that time `:61` | **observed** (full read) |
| `variant3d/scripts/data.gd:385,401` (read) | Current `DONOR_GAME_SPEED` const and `GAME_SPEED` default; plan cited `:384,:400` | **observed** |
| `variant3d/scripts/main.gd:354,362` (read) | Current config enum + speed application; plan cited same lines | **observed** |
| `variant3d/scripts/hud.gd:435-459` (read) | Current `_mkoption` speed item array, tooltip, `speed_label` | **observed** |
| `variant3d/tests/t_hud_layout.gd:50-69,394-423` (read) | Current `SPEED_LABELS`/`SPEED_META`, `EPS`, four speed predicates | **observed** |
| Repo-wide grep `*.gd` for `PORT_GAME_SPEED\|DONOR_GAME_SPEED_MODES\|DONOR_GAME_SPEED_ADJUSTABLE` | Zero matches anywhere in tracked `.gd` sources | **observed** (no match) |
| Repo-wide grep `variant3d/**/*.gd` for `DONOR_GAME_SPEED` | Five hits: `data.gd:385`, `main.gd:354,362`, `config.gd:598`, `menu.gd:757` | **observed** |
| `variant3d/scripts/config.gd:598`; `variant3d/scripts/menu.gd:757` (read) | Two additional `DONOR_GAME_SPEED` call sites the plan did not list | **observed** |
| `variant3d/scripts/main.gd:626-632,721-724,1145-1151,1616`; `hud.gd:591,599,629,636,642-643`; `uitest.gd:276,278` (grep) | Preserve-semantics anchors still present | **observed** |
| `variant3d/tests/results/t_hud_layout.json:58-81,186-204,312-330,440-444,609-613,690-694` (read/grep) | Atom now has a result; speed rows PASS against the **old** label literal | **observed** |
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_RUN_01.md:3,15` (read) | Untracked atom-run report declares overall `atom_verdict: FAIL`, no source edit | **observed** |
| `git status --short` | No `M` entry for the four target `.gd` files; only untracked `.import` files and `HUD_LAYOUT_RUN_01.md` | **observed** |
| `app/scripts/data.gd:333`, `main.gd:330,338`, `hud.gd:360,365` (grep) | 2D path keeps its own mislabelled const and four speed buttons; deliberately out of scope (`SPEED_PLAN_01.md:48,89,158`) | **observed** |

---

## 2. Four-change alignment table

| # | Planned change (`SPEED_PLAN_01.md`) | Status | Current on-disk evidence (`file:line`) | Label |
|---|---|---|---|---|
| 1 | Rename const `DONOR_GAME_SPEED` → `PORT_GAME_SPEED` in `variant3d/scripts/data.gd` (`:99`; plan snapshot `:384`), numbers/keys unchanged; plus add data-only `DONOR_GAME_SPEED_MODES` / `DONOR_GAME_SPEED_ADJUSTABLE` (`:100-102`) | **NOT APPLIED** | `variant3d/scripts/data.gd:385` still `const DONOR_GAME_SPEED := {"slow": 0.5, "normal": 1.0, "fast": 2.0, "very_fast": 4.0}`. Repo-wide `.gd` grep finds **zero** `PORT_GAME_SPEED`, `DONOR_GAME_SPEED_MODES` or `DONOR_GAME_SPEED_ADJUSTABLE`. `data.gd:401` `static var GAME_SPEED := "normal"` is unchanged (correct — plan said keep it). | **observed** |
| 2 | HUD labels to donor-exact in `variant3d/scripts/hud.gd:444`: `II` kept as port pause row, `1x→Normal`, `2x→Fast`, `4x→Very Fast`; floats `[0,1,2,4]` and default index `1` unchanged (`:107-112`) | **NOT APPLIED** | `variant3d/scripts/hud.gd:444` still `_mkoption([["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]], 1)`. No donor-exact speed label strings present. Metadata floats and default index match the plan's *unchanged* requirement; tooltip `:445` and `speed_label` `:452` unchanged as specified. | **observed** |
| 3 | Main refs updated in `variant3d/scripts/main.gd:354,362`: `Data.DONOR_GAME_SPEED.keys()`/`.get(...)` → `Data.PORT_GAME_SPEED` (`:121`) | **NOT APPLIED** | `variant3d/scripts/main.gd:354` still `Data.DONOR_GAME_SPEED.keys()`; `:362` still `Data.DONOR_GAME_SPEED.get(Data.GAME_SPEED, 1.0)` with clamp `0.1..8.0`. No numeric change has occurred. | **observed** |
| 4 | Atom literal updated in lockstep in `variant3d/tests/t_hud_layout.gd:59` after the HUD label change; `SPEED_META` unchanged at `:60`; predicates/threshold preserved (`:127-129`) | **NOT APPLIED** | `variant3d/tests/t_hud_layout.gd:59` still `const SPEED_LABELS := ["II", "1x", "2x", "4x"]`; `:60` still `const SPEED_META := [0.0, 1.0, 2.0, 4.0]` (unchanged as planned). `EPS := 2.0` at `:57` and predicates at `:399,404,412,420` are intact. | **observed** |

**Result: 0 of 4 APPLIED, 0 PARTIAL, 4 NOT APPLIED.** The current tree is internally consistent at the pre-plan state, so there is no half-applied mixed state in the four inspected files.

---

## 3. Corroboration and risk notes

### 3.1 The plan undercounts rename call sites (inconsistency risk)

`SPEED_PLAN_01.md:80,121` states the rename forces **two** call-site edits (`main.gd:354,362`). Observed repo-wide, there are **four** live references to `DONOR_GAME_SPEED`:

| File:line | Reference | In plan's list? |
|---|---|---|
| `variant3d/scripts/data.gd:385` | declaration | yes (`:99`) |
| `variant3d/scripts/main.gd:354` | `.keys()` | yes (`:121`) |
| `variant3d/scripts/main.gd:362` | `.get(...)` | yes (`:121`) |
| `variant3d/scripts/config.gd:598` | `_donor_id("game_speed", Data.DONOR_GAME_SPEED.keys(), "normal")` | **no** |
| `variant3d/scripts/menu.gd:757` | `_donor_items(Data.DONOR_GAME_SPEED.keys(), …)` | **no** |

**derived / inferred risk:** if a future worker applies only the two `main.gd` edits from §4.3 and renames the const, `config.gd:598` and `menu.gd:757` still address a now-missing identifier — a stale-reference inconsistency. The owner executing the hand-off must update **all four** call sites, not two. No fix was made here.

### 3.2 Atom result now exists but reflects the pre-plan literals

`QA_SPEED_01.md:61` recorded no atom result at authoring time. This pass observes `variant3d/tests/results/t_hud_layout.json` (20,236 B, mtime 2026-11-25 12:18) and the untracked `HUD_LAYOUT_RUN_01.md` (frontmatter `:3,15`: `atom_verdict: FAIL`, `NO_SOURCE_EDIT`). Its speed rows are:

- `t_hud_layout.json:65-68` `speed_options_1024x576` **PASS**, detail `options=["II","1x","2x","4x"] expected=["II","1x","2x","4x"]`; same pattern at `:186-204` (1280×720) and `:312-330` (1920×1080).
- `t_hud_layout.json:71-74` `speed_option_metadata` PASS on `[0.0,1.0,2.0,4.0]`; `:440-444,609-613,690-694` measured `speed_options` are the old four strings.

**derived:** these rows are internal consistency against the **old** atom literal. They are not evidence that SPEED_PLAN_01 landed. If the HUD labels are changed later without changing `t_hud_layout.gd:59`, `speed_options` will fail at all three viewports. **UNVERIFIED:** no post-plan atom run exists, and no visual A/B exists.

### 3.3 Preserved semantics anchored from the plan are still present

`main.gd:626-632,721-724,1145-1151,1616` (`speed_cb` closures, `set_speed`, `acc += dt * speed`), `hud.gd:591,599,629,636,642-643` (`_speed_index`, `_on_speed_idx`, `refresh_speed`, `_on_speed`), and `uitest.gd:276,278` (`main.set_speed(2.0)`/`1.0` bypass) are unchanged — **observed**. This confirms no numeric or behavioural change was smuggled in, but it does not constitute a PASS claim.

### 3.4 Line drift and working-tree state

The plan's `data.gd:384,400` citations now read `data.gd:385,401` (+1 shift) — **observed**. `hud.gd:444`, `main.gd:354,362` and `t_hud_layout.gd:59,60` citations still match. `git status --short` shows no `M` entry for any of the four target scripts, so the literals above are at committed HEAD state — **observed**. The 2D path (`app/scripts/data.gd:333`, `main.gd:330,338`, `hud.gd:360,365`) remains intentionally untouched — **observed**, out of scope per `SPEED_PLAN_01.md:48,89,158`.

---

## 4. Verdict

**SPEED_PLAN_01 is NOT APPLIED.** All four planned changes are absent from the current on-disk literals; none is partial. **Keep SPEED_PLAN_01 as a pending ticket** — do not close it, do not mark it landed, and do not promote any gate to PASS on the strength of this check.

Additional verdict notes:

- **No inconsistency to fix now** in the four inspected files; every file still uses the same old `DONOR_GAME_SPEED` vocabulary and old `II/1x/2x/4x` labels.
- **Future-application hazard:** the rename scope in the plan is incomplete (§3.1). Include `config.gd:598` and `menu.gd:757` in the hand-off, or the rename will leave stale references.
- **PORT APPROX retained:** port floats `0.5/1.0/2.0/4.0`, metadata `[0,1,2,4]`, clamps `0.1..8.0` / `0..8`, the `II` pause row and any mode→float mapping remain **PORT APPROX / INFERRED**. Donor factors `7/10/14` and modes `0/1/2/-1` are observed donor data, but factor meaning is **UNVERIFIED** and must not be fed into `acc += dt * speed` (`SPEED_PLAN_01.md:69,144`).
- **No runtime, visual or donor-parity claim** is made; atom speed rows currently PASS only against pre-plan literals, and no windowed A/B exists.

---

## 5. Open questions

1. **Execution ownership/timing** — `hud.gd`, `main.gd` and the atom had RUNNING owners at plan time (`SPEED_PLAN_01.md:91`); who now executes the hand-off and in which order, given `config.gd:598` and `menu.gd:757` must also move? [observed conflict + inferred risk]
2. **Rename scope correction** — should the pending ticket be amended from "two main refs" to "four call sites" before execution? [derived]
3. **Pause row** — keep `II`/`0.0` as the port-only pause affordance (plan's recommendation, `:108,117`) or remove it for donor-pure labels, needing a coordinated `refresh_speed` + atom rewrite? [inferred]
4. **Atom re-run** — after any label change, who re-runs `t_hud_layout` and updates `SPEED_LABELS` in lockstep? The existing result JSON's speed rows will otherwise FAIL at all three viewports. [derived, UNVERIFIED until run]
5. **Donor factor semantics** — multipliers, tick budgets or clock divisor? Engine-side `SetTimeSpeedFactor` has no donor definition (`SPEED_PLAN_01.md:69,151`). **UNVERIFIED**; blocks all numeric parity claims.
6. **Visual A/B** — no donor frame exists on disk; headless atom rows are `SKIP_CAPTURE` (`SPEED_PLAN_01.md:156`). Visual parity stays UNVERIFIED even after a structural atom PASS.
7. **Config back-compat** — user-saved configs were not read; whether keeping legacy `slow` in a renamed table suffices is **UNVERIFIED** (`SPEED_PLAN_01.md:154`).
8. **2D path** — the duplicate mislabelled const and four speed buttons in `app/scripts/**` remain deliberately out of scope; kept so 2D gates stay green (`SPEED_PLAN_01.md:158`). [observed]

---

## 6. Summary

- Checked all four `SPEED_PLAN_01` changes against current on-disk literals. **All four are NOT APPLIED** (0 APPLIED, 0 PARTIAL): `data.gd:385` still `DONOR_GAME_SPEED`; `hud.gd:444` still `II/1x/2x/4x`; `main.gd:354,362` still reference `DONOR_GAME_SPEED`; `t_hud_layout.gd:59` still expects the old labels.
- Repo-wide `.gd` grep finds no `PORT_GAME_SPEED`, `DONOR_GAME_SPEED_MODES` or `DONOR_GAME_SPEED_ADJUSTABLE`; no donor-exact speed labels exist in `hud.gd`.
- **Verdict: keep SPEED_PLAN_01 as a pending ticket.** No code was changed and no gate was promoted by this QA pass.
- Main new finding: the plan's rename scope is incomplete — `config.gd:598` and `menu.gd:757` also reference `DONOR_GAME_SPEED` but are not listed in §4.3. Flag this as an inconsistency risk for whoever executes the hand-off; do not fix here.
- The atom result JSON now exists (absent at `QA_SPEED_01` time) but its speed rows PASS against the old label literal; it is not evidence of plan application, and a post-change re-run is required.
- All numeric speed values remain **PORT APPROX**; donor factor meaning is **UNVERIFIED**; no donor-parity, visual-parity or runtime-PASS claim is made.
- **Read-only compliance:** exactly one file was written — this report. No code, test, config, result JSON, manifest or queue edit; no Godot process; no runner job; no report promoted to PASS.
