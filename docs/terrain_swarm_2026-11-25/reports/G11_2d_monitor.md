---
id: G11
ticket: "G11 — read-only monitor: 2D app/ gates and untouched state"
wave: G — standing swarm
owner: G11 (this session)
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
board: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
created: 2026-11-25
snapshot_cutoff: 2026-11-25T14:47:51+01:00
status: MOMENT-IN-TIME — swarm still landing; re-check with §7 commands at integration
scope: "Report only. No code/config/test/backup edit; no Godot launch; no runner job submitted/cancelled/acked/reset; no git write. app/ was read, never modified by this agent."
labels: [observed, derived, inferred, UNVERIFIED]
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/coord_swarm_2026-11-25/FINAL_CHECKLIST.md (§I:451-478)
  - docs/terrain_swarm_2026-11-25/reports/C02_gate_plan.md (§G9:358-376)
  - docs/terrain_swarm_2026-11-25/reports/C03_ownership_audit.md
  - docs/coord_swarm_2026-11-25/reports/QA_2D_FRESH_01.md
  - app/selftest.json, app/uitest.json, app/app_selftest.json, app/report.json
  - app/.godot_queue/ (status.json, counter, now_serving, results/00001348-00001351*.json + stdout)
  - app/tools/godot_runner.py:46-53, variant3d/tools/godot_runner.py:46-53
  - variant3d/.godot_queue/status.json (history tail), .gitignore:37-38,65-79
---

# G11 — 2D `app/` gate & untouched-state monitor

## 0. Verdict (DERIVED, with one nuance flagged in §5)

**The invariant HOLDS at this snapshot for everything that matters: no Wave A–G source edit
leaked into `app/`, and both canonical 2D gates are green** — `app/selftest.json`
`passed=true`, **29/29**; `app/uitest.json` `passed=true`, **17/17**, both regenerated today by
fresh, successful runner jobs. All six B-owner edits and COORD's test fix are under `variant3d/`
only. Backups are under `inbox/backup/`; reports under `docs/`.

**Nuance (OBSERVED, not a defect):** three *tracked runtime artifacts* under `app/` —
`app/selftest.json`, `app/.godot_queue/counter`, `app/.godot_queue/now_serving` — were rewritten
and committed today by COORD's own 2D gate verification (commit `f744dd93`, 13:46:47 +0100).
So the literal statement "not one byte under `app/` changed today" is false; the defensible
statement is **no `app/` source, config, test, tool, scene, shader or asset was changed**. Do not
let a future gate log claim byte-level untouchedness without excluding the runner-owned outputs.

## 1. Method & scope (OBSERVED)

Read-only: `git status` / `git diff` / `git log`, direct file reads, Python `json` reads, and
filesystem timestamp listings. **No Godot process was started, no runner job was submitted, no
file other than this report was written.** All findings are pinned to the front-matter cut-off;
swarm activity continued during the audit, so §7 re-check is required at integration.

## 2. Git evidence — `app/` tree (OBSERVED)

| Check | Command | Result at cut-off |
|---|---|---|
| Working tree, all paths | `git status --porcelain=v1` | 11 entries: 10 modified under `variant3d/` (9 files + `variant3d/selftest.json`), 1 untracked `variant3d/tools/terrain_ab_metric.py`; plus untracked `docs/terrain_swarm_2026-11-25/` and 6 `inbox/backup/*.bak-B0X`. **Zero `app/` entries.** |
| `app/` working tree, incl. untracked | `git status --porcelain --untracked-files=all -- app/` | **empty** (RC 0) |
| `app/` diff vs HEAD | `git diff --exit-code --quiet -- app/` | **RC 0** — byte-identical to HEAD |
| `app/` diff stat | `git diff --stat -- app/` | empty |
| Commits today touching `app/` | `git log --since="2026-11-25 00:00:00 +0100" --name-only -- app/` | `f744dd93` (13:46:47) → `app/.godot_queue/counter`, `app/.godot_queue/now_serving`, `app/selftest.json`; `1d67e32b` (11:14:22) → same three. **No source path.** |

The three tracked spool files predate the ignore rule and remain tracked despite
`.gitignore:37-38,79`; `git check-ignore -v` confirms `app/.godot_queue/` *and* `app/.godot/` are
ignored for **new** files, so future runtime writes there — and ignored `app/shots/**/*.png` —
will not appear in `git status`. The timestamp scan in §7F closes that blind spot.

## 3. Shared-script path verification (OBSERVED)

`game.gd` and `mapgen.gd` each exist in **both** projects, so the charter's "shared scripts are
edited in `variant3d/` only" rule is testable:

| Path | State at cut-off |
|---|---|
| `app/scripts/game.gd` | **unmodified** — `git diff --exit-code --quiet` RC 0; no commit today |
| `app/scripts/mapgen.gd` | **unmodified** — RC 0; no commit today |
| `variant3d/scripts/game.gd` | **modified** (`M`) — B03's test7/test8 donor re-roll + tile-stamp redirect (per WAVE_G_CHARTER.md:20) |
| `variant3d/scripts/mapgen.gd` | **unmodified** — no `M` entry; no B ticket owns it |

**DERIVED:** B03 landed in the 3D copy only; the 2D copy is byte-identical to HEAD. No Wave
A–G edit leaked through the shared-name path. Other modified paths are all `variant3d/`:
`assets/terrain/atlas/tile_index_atlas{,_winter}.png.import` (B02),
`scripts/input_controller.gd` (B05 + COORD parse fixes), `scripts/tile_atlas_loader.gd` (B02),
`scripts/world3d_fx.gd` (B06), `scripts/world3d_terrain.gd` (B04),
`shaders/terrain_tileindex.gdshader` (B01), `tests/t_select_rect.gd` (COORD :525 fix),
`selftest.json` (generated). Backups: `game.gd.bak-B03`, `input_controller.gd.bak-B05`,
`terrain_tileindex.gdshader.bak-B01`, `tile_atlas_loader.gd.bak-B02`, `world3d_fx.gd.bak-B06`,
`world3d_terrain.gd.bak-B04` — all in `inbox/backup/`, none in `app/`.

## 4. 2D gate pass states & runner artifacts (OBSERVED)

### 4.1 Canonical gate outputs

| Artifact | `passed` | Steps | Failed steps | Last write |
|---|---|---|---|---|
| `app/selftest.json` | `true` | **29** | none | 2026-11-25 13:41:23 |
| `app/uitest.json` | `true` | **17** | none | 2026-11-25 13:42:59 |

Both are runner-generated, not hand-edited (stdout: `self-test report: .../app/selftest.json`,
`ui-test report: .../app/uitest.json`). Freshness is proved by the app runner spool
(`app/tools/godot_runner.py:47` → `SPOOL = ROOT/"app"/".godot_queue"`):

- `results/00001350.json` — ticket 1350 `qa2dfresh01-selftest`, `status: ok`, `exit: 0`,
  run 99.24 s, argv `--headless --path app -- --self-test app/selftest.json`.
- `results/00001351.json` — ticket 1351 `qa2dfresh01-uitest`, `status: ok`, `exit: 0`,
  run 87.41 s, argv `--headless --path app -- --ui-test app/uitest.json`.
- `status.json` `history` total **258**; entries 1350/1351 `ok`/`0`. Older confirmations:
  1348 `qa2d-selftest` (29/29) and 1349 `qa2d-uitest` (17/17), both `ok`/`0`.
- `assert_clean.py --json` was **CLEAN**, exit 0, `processes.count=0`, `failures=[]` at the
  time of `QA_2D_FRESH_01.md:44-60` (read by G11 as prior evidence; **not** re-run by G11).

**DERIVED:** the 2D gates are green on the current tree and were not weakened — failed-step
lists are empty and the two jobs exited 0 within their timeouts.

### 4.2 Non-gate artifacts that can be misread (OBSERVED)

| Artifact | State | Interpretation |
|---|---|---|
| `app/app_selftest.json` | `passed=true`, **28** steps, last write 2026-11-20 14:16:21 | stale earlier-format artifact, not written by the canonical gates |
| `app/report.json` | **`passed=false`**, 29 steps; failing `build`, `wall`, `shell`, `peasant_capture`, `farm_cap`; last write 2026-11-21 06:33:35 | **stale, pre-swarm failure artifact — not a 2D gate input and not a current regression.** Do not quote it as a red gate, and do not delete/alter it to "fix" a gate (no test weakening). Flag for annotation by COORD. |

### 4.3 Runner isolation (OBSERVED)

Two distinct spools, by explicit `SPOOL` constants: `app/tools/godot_runner.py:47` →
`app/.godot_queue`; `variant3d/tools/godot_runner.py:47` → `variant3d/.godot_queue`. A scan of
all 500 retained entries in `variant3d/.godot_queue/status.json` found **0 jobs with `--path app`
or an `app/…` argument** — the 3D wave never launched a Godot job against the 2D project. Tail
of the 3D spool: 579 `ok`, 580 `ok`, 582 `skipped`, **583 `terrainswarm-g1-selftest` `failed`
(exit 1)** — this is the blocked 3D gate described in WAVE_G_CHARTER.md:27, **out of G11's scope
and not evidence against the 2D invariant**. G11 submitted nothing to either spool.

## 5. Flags (OBSERVED / DERIVED)

| # | Severity | Finding | Evidence |
|---|---|---|---|
| F1 | **INFO, doc-only fix** | Three tracked runtime artifacts under `app/` were rewritten/committed today; "app/ byte-untouched" is too strong. Say "no `app/` source/config/test/tool/scene/shader/asset changed". | §2 `git log` → `f744dd93`, `1d67e32b`; §0 |
| F2 | WATCH | `app/report.json` is `passed=false` with 5 failing steps. Stale 11/21 artifact; do not treat as a live regression, do not "repair" it by editing test output. | §4.2 |
| F3 | INFO | `git status -- app/` alone cannot see writes into ignored `app/.godot*` or `app/shots/**/*.png`. Use the §7F timestamp scan as a second check. | `.gitignore:37-38,54-79`; §2 |
| F4 | INFO | 3D gate 583 is `failed`; irrelevant to 2D but means `assert_clean` can be `DIRTY` during 3D churn — never use a churn-time DIRTY to sign or reject the 2D gates. | §4.3; `C02_gate_plan.md:85-89,349-356` |
| F5 | **NONE** | No Wave A–G source edit in `app/`, no shared-script leak, no cross-tree backup, no hand-edited 2D gate, no weakening of a 2D assertion at cut-off. | §2, §3, §4.1 |

**UNVERIFIED:** that no *untracked-and-ignored* binary under `app/shots/` was written during the
swarm by something other than the two known 2D jobs — the §7F scan at cut-off showed only
`app/selftest.json`, `app/uitest.json` and `app/.godot_queue/*` files written after 13:00, but
that is a point-in-time observation, and Fig. F3's blind spot applies to later activity.

## 6. What would count as drift at integration (DERIVED)

Any of the following is a FAIL of the 2D invariant and must be routed to COORD, not silently
fixed: (a) any `M`/`??`/`D` entry under `app/scripts`, `app/scenes`, `app/shaders`, `app/assets`,
`app/tests`, `app/tools`, or for `app/project.godot`/`app/config.json`; (b) `app/scripts/game.gd`
or `app/scripts/mapgen.gd` differing from HEAD; (c) `app/selftest.json` not `passed=true` 29/29
or `app/uitest.json` not `passed=true` 17/17 after a fresh job; (d) a tracked change to
`app/.godot_queue/*` produced by a job other than a 2D gate verification; (e) a 2D gate changed
to obtain green (threshold/assertion/`expected_pre_fix_failure` edits).

## 7. Exact read-only verification commands for COORD (PowerShell, from repo root)

Windows `python` (not `python3`); one command per line (`;`, never `&&`); **all are read-only —
none launches Godot or submits a runner job**. Expected output at cut-off is stated after each.

**A — source tree untouched (primary):**
```
git status --porcelain=v1 -uall -- app/scripts app/scenes app/shaders app/assets app/tests app/tools app/project.godot app/config.json app/export_presets.cfg
git diff --exit-code --quiet -- app/scripts app/scenes app/shaders app/assets app/tests app/tools app/project.godot; if ($LASTEXITCODE -eq 0) { "APP_SOURCE_CLEAN" } else { "APP_SOURCE_DIRTY" }
```
Expect: no output from line 1; `APP_SOURCE_CLEAN` from line 2.

**B — whole `app/` tree vs HEAD (will include the tracked generated artifacts):**
```
git status --porcelain=v1 -uall -- app/
git diff --stat -- app/
git diff --name-only -- app/
```
Expect: empty at cut-off. If COORD has re-run the 2D gates without committing, expect only
`app/selftest.json` and/or `app/.godot_queue/counter`, `app/.godot_queue/now_serving` — that is
F1, not a leak. Any `app/scripts/...` name is drift.

**C — gate pass states (read-only JSON parse):**
```
python -c "import json; s=json.load(open('app/selftest.json',encoding='utf-8')); u=json.load(open('app/uitest.json',encoding='utf-8')); print('selftest',s['passed'],sum(1 for x in s['steps'] if x.get('passed')),'/',len(s['steps']),'failed',[x['step'] for x in s['steps'] if not x.get('passed')]); print('uitest',u['passed'],sum(1 for x in u['steps'] if x.get('passed')),'/',len(u['steps']),'failed',[x['step'] for x in u['steps'] if not x.get('passed')])"
```
Expect: `selftest True 29 / 29 failed []` and `uitest True 17 / 17 failed []`.

**D — shared-script path check:**
```
git diff --exit-code --quiet -- app/scripts/game.gd; "app/scripts/game.gd diff rc=$LASTEXITCODE"
git diff --exit-code --quiet -- app/scripts/mapgen.gd; "app/scripts/mapgen.gd diff rc=$LASTEXITCODE"
git status --porcelain -- variant3d/scripts/game.gd variant3d/scripts/mapgen.gd
```
Expect: two `rc=0` lines; the last line shows only ` M variant3d/scripts/game.gd` (B03), not
`app/…` and not `variant3d/scripts/mapgen.gd`.

**E — 2D runner artifacts (no job submitted):**
```
python -c "import json; d=json.load(open('app/.godot_queue/status.json',encoding='utf-8')); h=d['history']; print('total',len(h)); [print(x['ticket'],x['id'],x['status'],x['exit'],round(x['run'],2)) for x in h[-2:]]"
Get-ChildItem app\.godot_queue\results -Filter '*.json' | Sort-Object Name | Select-Object -Last 4 Name,LastWriteTime
```
Expect: `total` ≥ 258 and the last two lines `1350 qa2dfresh01-selftest ok 0 99.24`,
`1351 qa2dfresh01-uitest ok 0 87.41`; result JSONs `00001348…00001351.json`. Any `failed`,
`skipped`, `timed-out` or `error` in the last two lines invalidates the fresh-gate evidence.

**F — ignored-path blind-spot scan (catches writes `git status` cannot see):**
```
Get-ChildItem -Path app -File -Recurse -Force | Where-Object { $_.LastWriteTime -ge (Get-Date '2026-11-25 13:00:00') } | Select-Object FullName,Length,LastWriteTime | Sort-Object LastWriteTime | Format-Table -AutoSize
```
Expect: only `app/selftest.json`, `app/uitest.json` and `app/.godot_queue/**`. Any
`app/scripts/*`, `app/tests/*`, `app/shaders/*`, `app/scenes/*`, `app/assets/*` or unexpected
`app/shots/*.png` is drift. (Adjust the date to the window being audited.)

**G — optional clean-gate re-read (direct Python; NOT a Godot launch):**
```
python app\tools\assert_clean.py --json
```
Expected in a quiet window: `"verdict": "CLEAN"`, `reasons=[]`, `processes.count=0`,
`failures=[]`. During 3D churn a `DIRTY` is expected (§5 F4) — record it, do not sign it.

**H — prove the 3D wave never targeted `app`:**
```
python -c "import json; h=json.load(open('variant3d/.godot_queue/status.json',encoding='utf-8'))['history']; b=[(x['ticket'],x['id']) for x in h if any(str(a)=='app' or str(a).startswith(('app/','app\\\\')) for a in x.get('argv',[]))]; print('variant3d jobs targeting app:',len(b),b[:10])"
```
Expect: `variant3d jobs targeting app: 0 []`.

If COORD elects to re-prove the 2D gates (G9 of `C02_gate_plan.md`), that is a **separate,
owner-authorised action** using the app runner with new unique ids
`c02g-app-selftest` / `c02g-app-uitest`, never concurrently with a variant-runner job — G11 did
not do it and does not claim a fresh re-run beyond tickets 1350/1351.

## 8. Limitations (UNVERIFIED)

- Moment-in-time; edits landed during the audit. Only §7 re-check is authoritative at integration.
- Backup *contents* were listed, not diffed; backup fidelity and report correctness are out of scope.
- No donor access, no Godot process, no runner job, no process-tree inspection by G11; `assert_clean`
  result is read from `QA_2D_FRESH_01.md`, not re-measured here.
- "Donor parity" is untouched by this ticket and stays **UNVERIFIED**.

---

*End of G11 report. Read-only monitor — no code edit, no Godot, no runner job, no `app/` write.*
