---
id: MAP240-APPLY-01
title: "Skirmish default restored to 240×240 now that the harness gate is green — 29/29 + 17/17 confirmed"
owner: MAP240-APPLY-01 subagent
date: 2026-11-25
status: GREEN__240_DEFAULT_APPLIED
owns:
  - "variant3d/config.json"
  - "docs/coord_swarm_2026-11-25/reports/MAP240_APPLY_01.md"
labels: [observed, derived, inferred]
---

# MAP240-APPLY-01 — final report

## 0. Direct answer

`variant3d/config.json` now ships the **240×240 skirmish default** again. The only
change is two values: `gameplay.map_width_tiles` and `map_height_tiles` `320 → 240`.
Everything else — including the full 21-key `features` block with
`features.terrain.relief_stamps: true` and `gameplay.map_type: "land"` — is
byte-identical to the pre-edit file. Both mandated gates passed on the current
tree through the variant runner only: **selftest 29/29**, **uitest 17/17**, both
`status=ok`, `exit=0`. No test, threshold, assertion or other file was touched.

## 1. Evidence read first (observed)

- `reports/SELFTEST_ALL_FIX_01.md:17-22,137,175-183` — ticket 567 proved **29/29 at
  240²** (`selftestallfix01-selftest-r2`, exit 0, `passed: true`, 29 steps,
  `sim_seconds 366.5625`); the four previously red steps (`wall`, `shell`,
  `farm_cap`, `flee`) are green via harness setup/geometry only, with no assertion
  weakened and diagnostics removed byte-identically. §6.1 records that the 240²
  default still lived only in the temp override and that the tree's `config.json`
  remained 320×320 — the hand-off this ticket closes.
- `reports/CFG_02_no_menu_defaults.md:12-18,64-68,87-94` — CFG-02 had applied 240
  (and briefly `mediterranean`) but **reverted** to 320 because the *old* harness
  failed 26/29 (`wall`, `shell`, `farm_cap`); 320 passed 29/29 (ticket 322) and
  uitest passed 17/17 at 240 (ticket 325). That harness limitation is now fixed,
  so the revert reason is void.
- Current `variant3d/config.json` (clean at HEAD `65a1f49a` before this edit):
  `map_width_tiles: 320`, `map_height_tiles: 320`, `map_type: "land"`,
  `features.terrain.relief_stamps: true`, 8 feature groups / 21 feature keys.
- Backups, read for provenance only (none were modified):
  - `inbox/backup/config.json.bak-CONFIGRESTORE` and `.bak-CFGJSON` — confirm the
    21-key `features` block and `relief_stamps: true` are the work of
    CONFIG-RESTORE-01 / RELIEF-ENABLE-01 and must survive byte-identically.
  - `inbox/backup/config.json.bak-CFGJSON` and `.bak-CFG02` — earlier 240-era
    snapshots *without* the features block; not restored (this is a value-only
    change on the current, feature-complete tree).

## 2. Backup (observed)

`Copy-Item variant3d\config.json inbox\backup\config.json.bak-MAP240APPLY`

- Backup: **`inbox/backup/config.json.bak-MAP240APPLY`, 15,163 bytes**, SHA-equivalent
  to the pre-edit file (`git diff --no-index` exit **0** before any edit).
- Post-edit `variant3d/config.json` is also 15,163 bytes (320→240 is same-width).

## 3. Before → after (exact, minimal value-only change)

| Key | Before | After |
| --- | --- | --- |
| `gameplay.map_width_tiles` (`:80`) | `320` | **`240`** |
| `gameplay.map_height_tiles` (`:81`) | `320` | **`240`** |
| `gameplay.map_type` (`:112`) | `"land"` | `"land"` (unchanged) |
| `features.*` (`:16-54`, 21 keys) | full block, `relief_stamps: true` | **byte-identical** |
| every other key / `_readme` / formatting | — | byte-identical |

Exact diff (`git diff --no-index inbox/backup/config.json.bak-MAP240APPLY
variant3d/config.json`) — one hunk, two value lines, nothing else:

```diff
@@ -77,8 +77,8 @@
  "gameplay": {
   "mode": "skirmish",
   "render_mode": "3d",
-  "map_width_tiles": 320,
-  "map_height_tiles": 320,
+  "map_width_tiles": 240,
+  "map_height_tiles": 240,
   "random_seed": 20261113,
   "start_resources": {
    "food": 800,
```

Post-edit `json.load` parse check: **passed**. Invariants re-read from the parsed
file: `map 240×240`, `map_type land`, `relief_stamps True`, `8` feature groups,
`21` feature keys (`selection, terrain, water, weather, camera, hud, render,
gameplay`). CRLF line endings and 2-space indentation preserved.

## 4. Validation — variant runner only, unique ids, no re-submit loops

Both launches used `python variant3d\tools\godot_runner.py run`. **No direct
`godot` invocation, no queue mutation, no `ack`/`cancel`/`reset`/`unwedge`, no
retries and no re-submit loop.** Queue was free at submission (`now_serving 568`,
`pending 0`, `godot.lock free`); both jobs started with ~0.001 s wait and ended
cleanly; final `status` again shows `pending 0`, lock free.

| Ticket | Job id | Gate / command (after `run --id … --timeout … --`) | Result | Wait / run | Artifact |
| ---: | --- | --- | --- | --- | --- |
| 568 | **`map240apply01-selftest`** | `--timeout 900 --max-wait 3600 -- --headless --path variant3d -- --self-test variant3d/selftest.json` | **ok**, exit 0 | 0.001 s / 86.78 s | `variant3d/.godot_queue/results/00000568.json` |
| 569 | **`map240apply01-uitest`** | `--timeout 240 --max-wait 3600 -- --headless --path variant3d -- --ui-test variant3d/uitest.json` | **ok**, exit 0 | 0.001 s / 146.17 s | `variant3d/.godot_queue/results/00000569.json` |

Result artifacts, read back (observed):

- Ticket 568: `id=map240apply01-selftest`, `status=ok`, `exit=0`; regenerated
  `variant3d/selftest.json` → **`passed: true`, 29 steps, `sim_seconds 366.5625`,
  zero failed steps** (`wall`, `shell`, `farm_cap`, `flee` among the passes).
- Ticket 569: `id=map240apply01-uitest`, `status=ok`, `exit=0`; regenerated
  `variant3d/uitest.json` → **`passed: true`, 17 steps, zero failed steps**.

No gate failed; no failing step needed reporting and nothing was reverted.

## 5. Explicit no-weakening statement

**No test, assertion, predicate, threshold, expected value, seed, cost, tick
count or pass condition was changed or weakened.** The only edit is the two
map-dimension *values* in `variant3d/config.json`; the game and the fixed harness
decide everything at runtime. In particular:

- `variant3d/scripts/selftest.gd`, `game.gd`, `hud.gd`, `mapgen.gd` and every other
  script were not edited — their working-tree differences are other agents' work.
- `variant3d/selftest.json` and `variant3d/uitest.json` were **not hand-edited**;
  they are runner-generated output from the two gate jobs above.
- No `steps.append(...)`, no `wall_ms`/measure, no AI flag, no affordability or
  placement bypass, no `random_seed` hunt for a friendly layout: SEG-02's
  "test-gaming" prohibition is respected.
- The 29/29 and 17/17 were achieved by the *current tree's* code with the
  delivered 240² default — not by a temp override, an `ack`, a skip or a
  weakened gate.

## 6. 2D gates remain untouched

This ticket is variant-3D-only. The 2D shipping port under `app/**` was not read
for editing, not modified, and not validated here; its gates and defaults are
outside this ticket's ownership and remain exactly as they were. No `app/**`
file was edited.

## 7. Open questions

1. COORD may still want a final whole-tree gate sweep by the queue executor after
   other agents' in-flight edits settle; this ticket only owns the config value
   and ran the two mandated gates on the tree as found (HEAD `65a1f49a` plus the
   concurrent working-tree changes).
2. The 240² default now matches the temp override used by ticket 567, so the
   override is redundant for future runs; no cleanup of temp files was performed
   (outside ownership).
3. `uitest` runtime grew to 146.17 s (CFG-02 ticket 325 measured 47.37 s at 240);
   the gate still passed within the 240 s timeout. If future runs trend slower,
   COORD may raise the timeout; no change was made here.

## 8. Summary

| Item | Result |
| --- | --- |
| Before | `variant3d/config.json`: 320×320, `land`, full 21-key features block |
| After | **`variant3d/config.json`: 240×240**, `land`, full 21-key features block, `relief_stamps: true` — all else byte-identical |
| Diff | One hunk, exactly 2 value lines (`map_width_tiles`, `map_height_tiles`), JSON parses |
| Backup | `inbox/backup/config.json.bak-MAP240APPLY` (15,163 B, byte-identical pre-edit copy) |
| Gate 1 | ticket 568 `map240apply01-selftest` — **ok / exit 0 — 29/29**, run 86.78 s |
| Gate 2 | ticket 569 `map240apply01-uitest` — **ok / exit 0 — 17/17**, run 146.17 s |
| Runner | `variant3d/tools/godot_runner.py run` only; no direct `godot`, no queue mutation, no re-submit loop |
| No weakening | Explicit: no assertion, threshold, seed, cost, tick count or predicate changed |
| 2D gates | Untouched (`app/**` not edited) |
| Other files edited | **None** — only `variant3d/config.json` and this report |
| Verdict | **GREEN — 240×240 skirmish default applied and validated (29/29 + 17/17)** |
