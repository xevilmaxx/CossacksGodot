# Swarm feature backlog — Cossacks 3 → Godot port

Triage desk N (worker `agentN`), ticket N-01. This file is the **only** file I own.
It turns the brief "port every single micro aspect of this donor" into a finite,
small, assignable set of tickets. It does **not** edit game code and is **not** the
live board — `SWARM_BOARD.md` stays the source of truth for state; only the
coordinator moves rows to DONE.

Priorities (per brief): **P0** blocks playability or test stability · **P1** visible
fidelity · **P2** polish · **P3** nice-to-have. Every ticket is one file or one
donor file family so it can be owned by exactly one worker (SWARM_OPS §3.2).

Sources used: root `README.md`, `app/README.md`, `docs/guides/GUIDE4.md` gap list
(rows 0186–0230, G01–G17) and file checklist (rows 1214–1238, E01–E22),
`reference/videos.md`, `SWARM_BOARD.md`, and grep of the current code markers.

---

## 1. A — Open defects from current worker reports

These are residuals surfaced by A–L. Where a board ticket already owns the file,
the row is marked **MERGE** — the coordinator should fold it into that ticket or
reassign it only after the owning ticket closes, never assign both at once.

| ID | Title | Source | Scope (files likely touched) | Acceptance criteria (measurable) | Priority | Risk | Suggested worker role |
|---|---|---|---|---|---|---|---|
| N-01 | Convert `mill_render_test.gd` to deferred quit | worker report F-01 (residual) — **MERGE F-01** | `app/tests/mill_render_test.gd` | No direct `quit(` in `_initialize()` path; all exits via `call_deferred("quit", code)` as the other 5 scripts do. Runner job `run --id agentN-milltest --timeout 30 -- --path app --script res://tests/mill_render_test.gd` exits 0; 3 consecutive runs leave 0 orphans under `doctor`. | P0 | Low | Builder F (or QA O after F-01 closes) |
| N-02 | Fix failing `build` self-test step | worker report A-01 — **MERGE A-01** | `app/scripts/selftest.gd`, `app/scripts/game.gd`, `app/selftest.json` | `app/selftest.json` reports 28/28 with step `build` = `passed:true`; the build step creates a real building entity and deducts resources. | P0 | Med | Builder A |
| N-03 | AI stuck states / wave timing / chat spam soak | worker report G-01 — **MERGE G-01** | `app/scripts/ai.gd` | 60 s CLI soak with `--cli --cli-seconds 60`: 0 units without an order for >5 s while idle; expansion occurs within 60 s; chat lines per player ≤ 1 per 10 s (guard `player==0` per GUIDE4 D32). | P0 | High | Builder G |
| N-04 | Audit `nav.gd` AStarGrid2D API usage | worker report J-01 — **MERGE J-01** | `app/scripts/nav.gd` | 0 deprecated-API warnings in runner log; unit paths around stumps (L4) and hills (L5) reach target in selftest; 0 path errors in 60 s CLI. No new standalone scripts (board constraint). | P0 | Med | Builder J |
| N-05 | Audio wiring / missing donor sound assets | worker report L-01 — **MERGE L-01** | `app/scripts/audio.gd` | Every event→sound mapping in `config.gd` resolves to an existing `res://` file; 0 "missing audio"/load-error lines in 60 s CLI log; donor count 305 documented in `CREDITS.md` unchanged. | P1 | Med | Builder L |
| N-06 | Fix stale README wording for GUIDE4 state | worker report E-01 — **MERGE E-01** | `README.md`, `app/README.md`, `docs/COMMANDS.md` | Docs state L1–L8 implemented and name which gates are green vs pending; GUIDE4 line-count claim matches `(Get-Content GUIDE4.md).Count` (board note 2296); no "verification pass in progress" claim left where QA has signed. | P2 | Low | Builder E |

---

## 2. B — Unported / unverified GUIDE4 gaps (gap rows 0186–0230, checklist 1214–1238)

Grep confirms L1–L8 **code** is present (stumps, bushes, height/slope, seed, can_place,
battery spacing, capture rule, water). The gaps that remain are the measurable
verification artifacts the guide demands — without them the gaps cannot be declared closed.

| ID | Title | Source | Scope (files likely touched) | Acceptance criteria (measurable) | Priority | Risk | Suggested worker role |
|---|---|---|---|---|---|---|---|
| N-07 | Weak-GPU terrain bake bench + `perf.md` (G17/E04) | GUIDE4 G17 (0227–0230), E04 (1219) | `docs/perf.md` (new), `app/scripts/world.gd` (read-only audit) | Code marker confirms 2 chunks/frame + LRU 24; `perf.md` records max frame hitch over 120 frames on the low preset < 250 ms; bench run logged via runner; `G17` not regressed. | P1 | Med | QA O |
| N-08 | 20-seed scan quality summary + determinism proof (G13/E14) | GUIDE4 G13 (0219–0220), E14 (1230) — **MERGE B-01** | `app/tools/scan_map.py`, `scans/**`, `docs/COMMANDS.md` | 20 seeds scanned; C07/C08 quarry+mine pads 100 % treeless; start ring 100 % has reachable stone/food/wood; same seed → byte-identical `--dump-map` JSON across 3 runs. | P1 | Med | Builder B |
| N-09 | Record GUIDE4 constants in `MECHANICS.md` (E21) | GUIDE4 E21 (1237) — **MERGE I-01** | `app/MECHANICS.md`, `app/mechanics.json` | Every L1–L8 magic value (tints 1.14/1.06/0.80, margins 7→8/4→6, slope 0.55, uphill tax 0.6, anim durations, scan summary) has a row with donor source and `estimated` flag; 0 undocumented new values flagged by review. | P1 | Low | Builder I |
| N-10 | Produce the 8 fidelity screenshot set (E20) | GUIDE4 E20 (1236), COMMANDS block (1274–1285) — **MERGE O-01** | `app/shots/g4_l*.png` (captures), `reference/videos.md` (still refs) | 8 PNGs exist (ghost, anim walk, stump, hills, terrain ×2, shore, forest); each ≥1 non-blank region; each mapped to a `videos.md` still or L-spec line in a review note. | P2 | Low | QA O |

---

## 3. C — Donor micro-aspects with no port yet (one donor file family per ticket)

Grep evidence: no `yacht|ship|boat|naval|dock` symbols, no `weather|day_night|season|time.cfg`
handling, no `TranslationServer`/`tr(`, no `dlcs/` reader, no donor `.pfx` importer.

| ID | Title | Source | Scope (files likely touched) | Acceptance criteria (measurable) | Priority | Risk | Suggested worker role |
|---|---|---|---|---|---|---|---|
| N-11 | Naval / yacht unit family | donor `data/actors` (ship `.oss`/`.osm`) + `data/animations` + `data/objects` (docks); `videos.md` item 15 | `app/scripts/data.gd`, `app/assets/models/anim/**`, `app/tools/bake_sprites.py` | ≥1 naval sid (yacht/galley) with 8-dir baked sprite from a donor mesh, buildable from a dock; OR a signed waiver in `MECHANICS.md` naming the exact donor files that are missing/unreadable. Donor files never copied outside approved asset dirs. | P2 | High | Builder C or K |
| N-12 | Environment / weather / time-of-day | donor `data/env` (`env.cfg`, `time.cfg`, `skydome`, `clouds`, `lights`, `flares`); `videos.md` footage | `app/scripts/world.gd`, `app/scripts/main.gd`, `app/scripts/config.gd` | Config flag toggles ≥2 donor-equivalent sky/cloud states; screenshot shows cloud/skydome layer; `--headless` CPU render unchanged; 0 new hangs; selftest 28/28. | P2 | High | Builder D |
| N-13 | Donor particle/post-effect family | donor `data/pfx` (`*.pfx`, `fx.tree`) + `data/shaders` + `data/posteffects`; `videos.md` volley/muzzle footage | `app/scripts/world.gd`, `app/assets/**` one effect family | One donor effect family (e.g. muzzle flash + smoke) imported and drawn on `fx_layer` in Compatibility renderer; 2 event types fire it; shot comparison attached; 0 GPU dependency. | P2 | Med | Builder D |
| N-14 | Localization string table | donor `data/locale`; root README "20 nations" + user brief "every micro aspect" | `app/scripts/config.gd` (`UNIT_NAMES`/`BUILDING_NAMES`→table), `app/scripts/menu.gd`, `app/scripts/hud.gd`, `app/assets/locale/**` (new) | All UI labels resolve through one lookup; ≥2 locales load without crash; missing key falls back to English; selftest 28/28 + uitest 17/17. | P3 | Med | Builder H |
| N-15 | DLC content inventory + one micro-set | donor `dlcs/dlc1..4`, `exp1`, `summer`, `winter` (directory confirmed) | `docs/DLC_INVENTORY.md` (new), `app/CREDITS.md`, `app/scripts/data.gd` | Table of all 7 DLC families with file counts and ported/waived status; 1 small DLC unit/building family added if donor files are readable, else waiver with file names. No redistribution. | P3 | High | Builder I or E |
| N-16 | Donor cinematics inventory / waiver | donor `data/video`; brief "every single micro aspect" | `docs/CREDITS.md` or `docs/DLC_INVENTORY.md` | Inventory of `data/video` files with size/format and an explicit keep/waive decision per file; waivers state why they are non-playable. No donor video committed. | P3 | Low | Builder E |

---

## 4. D — Cross-platform / CLI / hang-safety (original brief)

| ID | Title | Source | Scope (files likely touched) | Acceptance criteria (measurable) | Priority | Risk | Suggested worker role |
|---|---|---|---|---|---|---|---|
| N-17 | Cross-platform `compute_ortho.py` paths | user brief cross-platform; **MERGE K-01** (in progress) | `app/tools/compute_ortho.py` | 0 literal `C:\` strings in code (docstring examples allowed with forward slashes); root derived from `__file__` + `COSSACKS3_DIR`; dry-run with a POSIX-style `--game` path completes and reports orthos. | P1 | Med | Builder K |
| N-18 | Cross-platform `import_donor_masks.py` donor path | user brief cross-platform; grep found hardcoded `DONOR = Path(r"C:\Games\Cossacks 3\data\gen\terrainmasks")` | `app/tools/import_donor_masks.py` | Donor root comes from `--game` arg or `COSSACKS3_DIR` env with pathlib; 0 hardcoded absolute Windows donor paths; runs against a POSIX-style path; output PNGs byte-identical to current Windows run. | P1 | Med | Builder K (after K-01) |
| N-19 | Cross-platform `extract_map.py` default donor path | user brief cross-platform; grep found `DEFAULT_GAME = Path(r"C:\Games\Cossacks 3")` with no env override | `app/tools/extract_map.py` | Env override mirrors `copy_assets.py`; docstring examples use forward slashes; `--game` with a POSIX path extracts the same map JSON structure. | P2 | Low | Builder K |
| N-20 | Runner clean-exit / zero-orphan assertion gate | user brief "Godot must never hang"; `godot_runner.py` has timeout + doctor but no post-job assert | `app/tools/godot_runner.py`, `docs/COMMANDS.md` | New `doctor --assert-clean` exits non-zero if any Godot process started by the runner is alive > 2 s after job end; selftest, uitest, screenshot and CLI each run 3× with 0 orphans and bounded max wait. | P0 | Med | QA O |
| N-21 | CLI / headless cross-platform proof | user brief cross-platform + fast CLI; `app/README.md` §Cross-platform | `app/scripts/world.gd`, `app/scripts/main.gd`, `docs/COMMANDS.md` | Identical `--cli --cli-seconds 60` outcome on Windows and a POSIX host (final unit counts within ±5 %, 0 stuck, 0 errors); `--headless --screenshot` yields a non-blank CPU map on a no-GPU host; all launches via runner with `--timeout`. | P0 | High | QA O |

---

## 5. E — Review / QA process improvements

| ID | Title | Source | Scope (files likely touched) | Acceptance criteria (measurable) | Priority | Risk | Suggested worker role |
|---|---|---|---|---|---|---|---|
| N-22 | Donor-licence compliance gate at REVIEW | SWARM_OPS §3.5 "no redistribution"; compliance folded into M | `app/tools/AGENT_PROTOCOL.md`, `docs/COMMANDS.md`, `app/CREDITS.md` | Review checklist runs a grep for donor binaries (`.oss/.osm/.map/.dds/.ogv`) outside approved `app/assets/**` dirs → 0 hits; each release report attaches the result. | P1 | Med | Review M |
| N-23 | Ownership + diff-size review template | SWARM_OPS §3.2/§3.6; M can BLOCK merge | `app/tools/AGENT_PROTOCOL.md`, `docs/COMMANDS.md` | Review template has pass/fail fields for: owned files only, backup present, diff ≤ ticket scope, no renames of shared symbols; M records evidence id (runner log path) per sign-off. | P2 | Low | Review M |
| N-24 | Fidelity screenshot comparison harness | GUIDE4 acceptance line 0206 "compare PNG to reference/videos.md stills"; currently manual | `app/tools/compare_shots.py` (new), `docs/COMMANDS.md` | Tool takes a shot + reference crop, reports SSIM/diff score; documented threshold makes it a red gate in `O-01`; runs headless without Godot. | P2 | High | QA O |
| N-25 | Backup-before-edit verification in review | SWARM_OPS §3.3 | `app/tools/AGENT_PROTOCOL.md`, `docs/COMMANDS.md` | Review step verifies `inbox/backup/<name>.bak-<worker-id>` exists for every edited file before REVIEW→QA; missing backup blocks merge with a one-line reason. | P3 | Low | Review M |

---

## 6. Verified DONE — deliberately **no** ticket

Grep markers checked so the queue does not re-port finished work:

| Item | Evidence in tree | Why not ticketed |
|---|---|---|
| Peasant stride 0.667 → 1.08 s | `app/assets/models/anim/index.json:7` `"duration": 1.08` | C-01 fix applied; board state QA. Remaining risk tracked in open question Q1, not a new code ticket. |
| Building ghost / `can_place()` | `game.gd:2192`, `world.gd:1581–1625` (transparent sprite + reason) | L8 implemented. |
| `--seed` / `--dump-map` | `main.gd:663–671`, `470–496` | L6 implemented. |
| Stumps (type flip, 60 s ageing, gather guard) | `game.gd:2384–2388`, `3413–3414`, `2218` | L4 implemented. |
| Bushes scatter + gather skip | `game.gd:379–407`, `487` | L3 implemented. |
| height[] / `height_at` / slope block + uphill tax | `game.gd:1133–1154`, `2657`, `2757–2761` | L5 implemented. |
| Artillery battery ×3 spacing | `game.gd:1988` + `mechanics.json:1026` | Not a gap despite videos.md checklist item 8. |
| Peasant-capture rule toggle, wedge, campaigns, 18c, priest/morale | `config.gd:351`, `data.gd:47,220`, `menu.gd:121–320`, `mechanics.json:602–652,1050–1184` | Ported. |
| Donor water waves, `scan_map.py`, cross-platform `copy_assets.py`/`convert_models.py`/`bake_sprites.py` | `world.gd:601–605`; tool files present with pathlib + `expanduser` | Ported / owned by K-01. |
| Test-script hang pattern | 5 of 6 scripts already use `call_deferred("quit", …)` | Only N-01 (mill_render_test.gd) remains. |

---

## 7. Definition of done

A backlog ticket reaches **DONE** only when all of these hold (mirrors `SWARM_OPS.md` §2–§3):

1. **Ownership & backup** — diff touches only files granted by the coordinator; a
   `inbox/backup/<name>.bak-<worker-id>` exists for every edited file.
2. **Green before review** — `app/selftest.json` 28/28 **and** `app/uitest.json`
   17/17 after the change.
3. **Serialized tools** — every Godot launch via
   `python app\tools\godot_runner.py run --id agentN-<purpose> --timeout <sec> -- …`;
   never a direct `godot` call. Hangs are killed by the runner timeout; 0 orphans.
4. **Minimal diff** — no improvements beyond the ticket; no renames of functions
   or fields other scripts call.
5. **Private use** — no donor asset copied, uploaded or published; donor file
   families are named in documentation only.
6. **Review M sign-off** — protocol and ownership check passed, with a runner log
   path as evidence; M may BLOCK.
7. **QA O sign-off** — 28/28, 17/17, CLI 60 s no-stuck, relevant screenshot and
   (for N-20/N-21) the clean-exit / cross-platform gate.
8. **Coordinator merge** — the board row is moved to DONE; this backlog file is
   **not** edited to record state (board remains the source of truth).

---

## 8. Report / open questions

**Ticket count by priority:** P0 = 6 · P1 = 7 · P2 = 8 · P3 = 4 — **total 25**.

**Top 5 P0/P1 tickets (recommended queue order):**
1. **N-01** (P0) — mill_render_test.gd direct-quit hang: last known orphan source.
2. **N-20** (P0) — runner zero-orphan assertion: makes "never hangs" measurable.
3. **N-02** (P0) — failing `build` self-test step: blocks the 28/28 gate.
4. **N-03** (P0) — AI stuck/waves/chat soak: blocks the 60 s CLI gate.
5. **N-21** (P0) — CLI/headless cross-platform proof: required by original brief.

**Files created:** `SWARM_BACKLOG.md` (project root) only. No game code, docs,
runner, or board files were modified.

**Open questions for the coordinator:**
- **Q1** — Is C-01 fully QA-signed, or does peasant stride still skate in the
  `g4_l7_walk` frame sequence? If it skates, reopen C-01 rather than filing N-xx.
- **Q2** — Does K-01's in-progress diff already cover `compute_ortho.py`? If so,
  N-17 is redundant; N-18/N-19 remain outside K-01's owned file list.
- **Q3** — Are naval meshes actually readable in `data/actors`, or only referenced
  by `.aaf`? If absent, N-11 becomes a documented waiver, not a port.
- **Q4** — Should `data/video` cinematics (N-16) be waived as non-playable under a
  reasonable reading of "every micro aspect", or ported literally?
- **Q5** — Does `perf.md` (N-07) need to exist before O-01 signs E20, or after?
- **Q6** — Should N-01 be merged into F-01, or split to a fresh owner once F-01
  closes? Ownership must stay disjoint either way.

## Coordinator decisions (2026-11-21)

- **Q1:** C-01 stays in QA. Stride fix is a verified 1-field data change; QA (O-01)
  will capture a `g4_l7_walk` frame sequence as part of the release gate. Reopen
  only if that visual check fails.
- **Q2:** K-01 is COMPLETE and did cover `compute_ortho.py` (env-var default,
  pathlib-derived index path, new argparse front-end). **N-17 is CLOSED as
  redundant.** N-18/N-19 remain open and are assigned to worker W-01.
- **Q3:** N-11 (naval meshes) becomes a documented waiver pending evidence.
  Worker W-01 will inspect `C:\Games\Cossacks 3\data\actors` read-only and record
  whether `.oss` mesh files exist; no port without readable meshes.
- **Q4:** `data/video` cinematics are **waived** as non-playable. Record the
  waiver in the backlog; do not port video files.
- **Q5:** `perf.md` (N-07) is **required before** O-01 signs E20. Worker T-01 owns
  performance telemetry capture.
- **Q6:** N-01 is **merged into F-01** (already actioned: worker F received a
  follow-up to convert `quit()` to `call_deferred` in `mill_render_test.gd`).
- **Roster:** N's 25 tickets plus existing A–O/P–X tickets form the 100-ticket
  roster. New tickets are pulled in priority order as WIP slots free.
