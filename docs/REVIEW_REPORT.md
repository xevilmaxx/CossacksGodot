# REVIEW_REPORT — agentM (review desk)

Snapshot: 2026-11-21, review of working tree at time of inspection. **Read-only** desk;
no builder file was modified. Note: the tree was still being edited during review
(new diffs in `menu.gd`, `cli.json`, `bake_sprites.py` appeared mid-inspection), so
verdicts reflect the state observed, not a final merge snapshot.

## Verdict summary

| Ticket | Verdict | Evidence (file:line / log) | Required action |
|---|---|---|---|
| A-01 (A, game.gd/selftest.gd/data.gd) | WARN | Owned files only ✓; `inbox/backup/game.gd.bak-agentA`, `selftest.gd.bak-agentA` ✓. `app/scripts/selftest.gd:81-90` adds a large debug string to the `build` step detail — diagnostic scaffolding beyond the ticket. `app/selftest.json` still `"passed": false` (gate 4 red; `farm_cap` 500→500→500 failing at `selftest.json:148-151`). Runner tickets 0,1,6,7,10 all selftest exit 1. | Remove debug instrumentation before merge; `farm_cap` red gate must be resolved/reported by QA (O), not "fixed" by editing the test. |
| B-01 (B, main.gd/scan_map.py/scans/**) | WARN | `main.gd:119,133-136,664-670,1091-1095` — `--seed random` and `_candidate_paths` change; inside owned file, `main.gd.bak-agentB` ✓, no direct `godot` call. Scope is broader than a VERIFY ticket; created both root `scans/scan_7.json` and `app/scans/scan_7.json` (ownership of `app/scans/**` is ambiguous). Jobs 2,4 (`agentB-dump7`, `dump7b`) exit 0. | Coordinator to confirm `scans/**` covers both paths; otherwise WARN is acceptable as pipeline-support. |
| C-01 (C/C2, anim index.json/sheet_metrics.py/anim assets) | **BLOCK** | `index.json:7` 0.667→1.08 is a clean 1-field fix ✓ (`index.json.bak-agentC2` ✓). BUT `docs/UNIT_BAKING_FIX.md:229-266` edited by "agentC/agentC2" — doc is **not** in C-01's owned files (gate 2 / disjoint ownership, unregistered worker id). Also `app/tools/bake_mill_rotor.py` (new, outside owned files) and deletion of `mill_sails.*` + `bake_mill_sails.py` are unassigned work. Compliance: new tool reads donor `eurmilanim.oss`/`eurmil.dds` from `C:\Games\Cossacks 3` and leaves donor-derived `app/assets/models/anim/_mill_tmp/eurmil.png` (+ `.import`) inside `res://` (`bake_mill_rotor.py:38-45`, unlike `bake_sprites.py` which uses system temp) — gate 5 exposure. | C/C2: revert the `docs/UNIT_BAKING_FIX.md` edit to E's ownership or get coordinator grant; remove `_mill_tmp/eurmil.png(.import)` from the project and route scratch renders to system temp; coordinator to assign the mill-rotor work to a ticket before merge. Do **not** merge C work until confirmed private-use only. |
| D-01 (D, world.gd/input_controller.gd/hud.gd) | WARN | Owned files only ✓; `input_controller.gd.bak-agentD` ✓, but **no `world.gd.bak-agentD`** (gate 3 warn). `world.gd:72-77,354-371,1124-1125` adds spinning mill-rotor rendering — outside L8 ghost/block scope (gate 6, minimal diffs). Job 7 (`agentD-selftest`) exit 1; selftest red. | Provide `world.gd.bak-agentD`; move mill-rotor drawing into the owning ticket (see C-01 BLOCK) or drop it from D-01. QA to re-run selftest. |
| E-01 (E, COMMANDS.md/app README/root README) | APPROVE | `README.md:92-109`, `app/README.md:42-54`, `docs/COMMANDS.md:5-64`; all in owned files; backups `README.md.bak-agentE`, `COMMANDS.md.bak-agentE` ✓; docs only, no code/test risk. | None. |
| F-01 (F, app/tests/**) | **BLOCK** | 4 tracked tests correctly changed `quit(...)` → `call_deferred("quit", ...)` with backups ✓ (job 8 `agentF-probe` ok). BUT new `app/tests/mill_render_test.gd:10,31,37` calls `quit()` **inside `_initialize()`** — exactly the forbidden hang pattern from AGENT_PROTOCOL §1 and the bug F-01 exists to fix. | F: change both `quit()` calls in `mill_render_test.gd` to `call_deferred("quit", code)`. Re-run through runner. No merge until fixed. |
| G-01 (G, ai.gd) | NO CHANGE | No working-tree diff for `ai.gd`; only old backups (`ai.gd.bak*`) predate this round. | Report status; job 9 `agentJ-cli` 60 s soak ok. |
| H-01 (H, menu.gd/scenes/**) | APPROVE | `menu.gd:15,29,347-393` seed UI; owned file, `menu.gd.bak-agentH` ✓; no `main.gd` edit (as instructed). Tabs used. | Watch uitest 17/17 when QA signs off (new UI row may shift layout). |
| I-01 (I, mechanics.json/MECHANICS.md) | NO CHANGE | No working-tree diff. | None. |
| J-01 (J, nav.gd) | NO CHANGE | No working-tree diff for `nav.gd`; job 9 `agentJ-cli` exit 0. | None. |
| K-01 (K, copy_assets.py/convert_models.py/bake_sprites.py/compute_ortho.py) | APPROVE | `copy_assets.py:15-22,66-70`, `convert_models.py:12-28`, `bake_sprites.py:1-50,530-535`; owned files; backups `*.bak-agentK` ✓; no direct `godot` invocation, only comments. Cross-platform changes preserve Windows default via `COSSACKS3_DIR`. | `compute_ortho.py` untouched — fine if no change needed. |
| L-01 (L, audio.gd) | NO CHANGE | No working-tree diff for `audio.gd`. | None. |
| Unowned artifacts (info) | WARN | `app/cli.json` (buildings 1→2, units 10→12, sim 30→60) and `app/scans/scan_7.json` / root `scans/`, `app/.godot_queue/**`, `app/shots/**`, `app/tests/README.md`, `*.uid` are generated/untracked outputs, not owned code. `cli.json` matches J's 60 s CLI soak result. | Coordinator to classify generated outputs vs deliverables before merge. |

## System-level observations

- **Gate 4 is currently RED.** `app/selftest.json` reports `"passed": false`. Relative to
  HEAD, A's work fixed `build`, `wall`, `shell`, `peasant_capture`; `farm_cap`
  (500→500→500) remains failing in both HEAD and working tree. Four selftest runner
  jobs failed (tickets 0, 1, 6, 7, plus in-flight 10) — all exit 1. QA (O) must own
  the red gate; do not close A-01 as green.
- **Queue telemetry** (`app/.godot_queue/status.json`): no `timed-out` status in
  history. Statuses seen: `ok` (2,3,4,5,8,9) and `failed` (0,1,6,7). Max observed
  wait ≈ 5.62 s (ticket 7), mean well under a second otherwise — no starvation
  observed. At review time `now_serving = 10`, `counter = 13`, with jobs 10
  (`agentA-diag2`) and 11 (`agentF-verify2`) still pending/in-flight; their final
  statuses were not yet recorded — open question.
- **Runner stderr logs**: only benign engine-exit noise — "ObjectDB instances were
  leaked at exit", "2 resources still in use at exit" (selftests), one texture leak
  in `agentD-ghost`, RID/ObjectDB leaks in `agentF-probe`. No GDScript parse/runtime
  script errors. No direct `godot` invocation found in any modified/new builder
  file; `godot_runner.py` is the sanctioned launcher.
- **Gate 6 scope creep**: mill-rotor asset/tool/draw work has no ticket on the board
  yet but spans C, D and an unregistered "agentC2"; this is the largest ownership
  gap in the current tree.
- **Backups**: present for A, B, E, F, H, K and `index.json`; absent for `world.gd`,
  `selftest.json` (generated report), deleted `mill_sails.*`/`bake_mill_sails.py`,
  and generated `cli.json`.
- **Tabs / minimal diffs**: sampled `.gd` diffs use tabs. `selftest.gd` debug block
  and `menu.gd` seed UI are the least minimal; `bake_sprites.py` changes are
  justified by K-01's cross-platform scope.

## Open questions

1. Is `app/scans/**` or root `scans/**` B-01's owned path? (both now exist)
2. Who owns the mill-rotor feature, and is there a backup requirement for the
   deleted `mill_sails` assets?
3. Are `app/cli.json`, `app/scans/scan_7.json`, `app/shots/**` deliverables or
   disposable QA output?
4. Final statuses of tickets 10 (`agentA-diag2`) and 11 (`agentF-verify2`), and
   whether `farm_cap` is a genuine regression or a known pre-existing red step.
5. Compliance sign-off that the donor-derived `mill_rotor.png` is private-use only
   and that no donor intermediate remains in the project tree after C's fix.
