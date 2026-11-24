---
owner: W5-2 (micro-builder)
date: 2026-11-24
wave: 5
scope: app/scripts/main.gd + app/scripts/selftest.gd only (+ this report)
backups: inbox/backup/main.gd.bak-W52, inbox/backup/selftest.gd.bak-W52
status: RESIDUAL-1 FIXED + VERIFIED; RESIDUAL-2 fast path IMPLEMENTED/Parity-FIXED but <30 s NOT-ACHIEVED
runner_jobs: [1296, 1297, 1303, 1305, 1307, 1314, 1318, 1321, 1323, 1325, 1328, 1329, 1330, 1333, 1335, 1336, 1337]
---

# W5-2 — per-slot AI tier plumbing + pre-baked fast subset startup

## 0. Verdicts (all prior claims re-verified from current source, not inherited)

| Residual | Verdict | Evidence |
|---|---|---|
| 1. Per-slot AI tier reaches the sim | **FIXED + VERIFIED (code + full gate)** | `main.gd:363-384,390`; full gate 1337 29/29 PASS; hand-off API below |
| 2. Standalone subset wall < 30 s | **NOT-ACHIEVED (measured)** | final fast subset 1335 **41.83 s** vs no-snapshot 1336 **61.72 s** (32 % faster) — still above 30 s |
| 2a. Pre-baked snapshot fast startup mechanism | **FIXED + PARITY-PROVEN** | `main.gd:711-926`; dump 1333 round-trip OK; check 1329 OK; subset 1335 OK |
| Canonical `app/selftest.json` unchanged | **VERIFIED** | §6 |
| selftest.gd modifications | **NONE** (backup taken only) | byte-identical to `selftest.gd.bak-W52` |

No assertions, steps, `detail` strings, called symbols, RNG draws, tick order or
mapgen semantics were changed. All edits are `main.gd` only.

## 1. Residual 1 — per-slot AI tier plumbing

### 1.1 Verified starting state (prior claims checked, not trusted)

- `config.gd:19` `AI_DIFFICULTIES = [easy, normal, hard, veryhard, impossible]`;
  `config.gd:460-465` publishes `Data.PLAYER_AI_DIFFICULTY` from
  `gameplay.player_ai_difficulty` (per-slot, per W2-12).
- `menu.gd:662-665` emits BOTH `"ai_difficulty"` (raw donor id) and
  `"difficulty"` (legacy collapsed id) in every roster slot.
- `data.gd:193` `static var PLAYER_AI_DIFFICULTY: Array = []`.
- `main.gd:339-359` (pre-edit backup) read only `entry["difficulty"]` and
  whitelisted `["easy", "normal", "hard"]` — residual confirmed.
- `ai.gd:53-65` (W5-1, read-only) already consumes the array at
  `Data.PLAYER_AI_DIFFICULTY[player]` with `"none"` falling through to
  `Data.AI_DIFFICULTY`. I did **not** edit `ai.gd`.

### 1.2 Exact diff (`app/scripts/main.gd`, tabs preserved)

```diff
@@ _apply_roster_cfg, pre-loop
 	var ai := []
 	var ai_diff := []
+	# W5-2 / R06 C1: the raw per-slot donor id is authoritative. AI_DIFFICULTIES
+	# is the five-tier sim whitelist; "none" is the donor's human-slot marker and
+	# is stored verbatim so the array stays index-aligned with PLAYER_AI/NATIONS.
+	var allowed: Array = C3ConfigScript.AI_DIFFICULTIES.duplicate()
+	allowed.append("none")
 	for i in count:
@@ per slot
-		var mapped := str(entry.get("difficulty", "normal"))
-		if not ["easy", "normal", "hard"].has(mapped):
+		# Prefer the menu's "ai_difficulty" (raw donor id) over the legacy
+		# collapsed "difficulty" key so veryhard/impossible reach ai.gd (W5-1).
+		# Old configs without the new key fall back byte-identically to normal.
+		var mapped := str(entry.get("ai_difficulty", entry.get("difficulty", "normal")))
+		if not allowed.has(mapped):
 			mapped = "normal"
 		ai_diff.append(mapped)
```

`main.gd:390` `Data.PLAYER_AI_DIFFICULTY = ai_diff` unchanged.

### 1.3 API contract for W5-1 (already consumed; documented for the record)

- Key: `entry["ai_difficulty"]` in each `players[]` roster entry from `menu.gd`.
- Sim sink: `Data.PLAYER_AI_DIFFICULTY[i]`, `0 <= i < Data.PLAYER_COUNT`.
- **Index convention:** index `i` is the **sim player index** — the same `i` as
  `Data.PLAYER_NATIONS[i]`, `Data.PLAYER_AI[i]`, `Data.PLAYER_NAMES[i]`,
  `Data.TEAMS[i]` and `game.players[i].index`. `C3AI.player` is that same index.
- Values: `"none"` (human slot, not a tier), `"easy"`, `"normal"`, `"hard"`,
  `"veryhard"`, `"impossible"`. Unknown ids are coerced to `"normal"`.
- Legacy path: if a config/roster lacks `ai_difficulty`, the old `difficulty`
  key is used; if that is absent or not in the whitelist, `"normal"`. Default
  behaviour is byte-identical to before.
- Global `Data.AI_DIFFICULTY` (cfg `"difficulty"`) is **untouched**; W5-1's
  `_tier()` correctly prefers the per-slot value and falls back to the global.
- Game-over / save-load: no extra key is written into `game.players[]`, so
  `game.serialize()` output is unchanged.

## 2. Residual 2 — pre-baked fast startup

### 2.1 What the runner actually measured at the start

Re-read of current `_setup_full_game()` (`main.gd:928-995`): every selftest
process — subset or not — calls `game.setup(start_mode)` (`game.gd:306-315`:
`_gen_base` → `_gen_patterns` → `_gen_forests` → `_gen_resources` →
`_gen_finish` → `_assign_tileblocks` → `setup_spawns` → `_finalize_mine_tiles`).
W26's snapshot was taken *after* that call, so it could not remove per-process
map generation. Confirmed: residual 2 was real.

### 2.2 Mechanism implemented (all in `main.gd`)

New CLI flags (header `main.gd:9-12`, state `:76-78`, argparse `:1094-1105`,
dispatch `:200-208`):

| Flag | Effect |
|---|---|
| `--dump-self-base <file>` | one full mapgen, then writes `var_to_str(snapshot)` and exits; the built-in probe immediately reloads the file into a second `C3Game` and prints `SELF-SNAPSHOT dump round-trip: OK/MISMATCH` (non-zero exit on mismatch) |
| `--check-self-base <file>` | load-only into a fresh `C3Game`, print parity, exit |
| `--self-snapshot <file>` | **only honoured when `--self-only` is non-empty**: `_setup_full_game()` (`:938-945`) skips `game.setup()` and calls `_load_self_base()` |

`_load_self_base()` (`:828-926`):

1. validates format marker, `version`, `seed`, `map_w`/`map_h` against current
   `Data` statics (any mismatch ⇒ `false` ⇒ caller falls back to full setup);
2. calls the canonical `game.deserialize()` on a **1×1 stub** copy of the blob,
   so entities/players/stats/rest-node state is restored by the authoritative
   deserializer while its own `_assign_tileblocks()` touches one cell, not
   320×320;
3. installs the real `terrain`/`blocked`/`height`/`tileblock`/`mine_mask`/
   `map_starts`/`cluster_zones`/`map_meta` verbatim, reconfigures `nav`,
   restores `rng`/`gen_rng` stream positions, `sow_t` and `Data.AI_ENABLED`;
4. **parity gate**: re-serialises and refuses the fast path unless every
   serialized field and every extra map array matches the snapshot.
   A failed gate prints `self-snapshot: first difference at …` and falls back
   to full mapgen — no silently degraded state is possible.

`var_to_str` (not JSON) is deliberate: `JSON.parse_string` turns every integer
into a float and `Rect2` into a `"[P: …, S: …]"` string, which produced real
runtime corruption (`e.id % 3` float/int error, `block_rect` String→Rect2
assignment errors). See §4.

### 2.3 Exact diff summary (`app/scripts/main.gd`)

| location | change |
|---|---|
| `:9-12` | three CLI help lines |
| `:76-78` | `self_snapshot_path`, `self_base_dump_path`, `self_base_check_path` |
| `:200-208` | `_ready()` dispatch for the two new modes |
| `:363-384` | residual-1 tier plumbing (§1.2) |
| `:711-743` | `_dump_self_base()` — snapshot writer + built-in round-trip probe |
| `:744-750` | `_check_self_base()` |
| `:753-821` | `_same_json()`, `_json_rect()`, `_json_diff()` — parity helpers |
| `:828-926` | `_load_self_base()` — validated fast restore + parity gate |
| `:938-945` | `_setup_full_game()` chooses fast load only for `--self-only` + snapshot |
| `:1094-1105` | argparse arms for the three flags |

`selftest.gd` untouched. No RNG, no tick/order/step change.

### 2.4 Snapshot artefact

`app/tests/results/w52_self_base.json` — 2,943,049 bytes, seed 20261113,
320×320, 18 entities, 2,252 resource nodes. Despite the `.json` extension the
content is a Godot `var_to_str()` Variant literal with a `"format":
"w52-self-base-2"` marker; the inner `"base"` blob is ordinary
`game.serialize()` base64. A rename to `.snap` is an open question (§7).

## 3. Runner jobs and MEASURED wall times

All launches were `python app/tools/godot_runner.py run --id … --timeout … -- …`;
no direct `godot` call. Times are the runner's `run` seconds.

| ticket | id | job | run (s) | exit | note |
|---|---|---|---|---|---|
| 1296 | w52-parse | `--check-only main.gd` | 13.97 | 0 | parse OK |
| 1297 | w52-dump-base | first dump | 100.81 | 1 | **MISMATCH** (diagnosis, §4) |
| 1303 | w52-parse2 | `--check-only main.gd` | 7.86 | 0 | parse OK |
| 1305 | w52-dump-base2 | dump retry | 8.66 | 1 | transient: empty stdout/stderr (swarm churn) |
| 1307 | w52-dump-base3 | dump retry | 34.76 | 1 | **MISMATCH at `entities`** (real float32 issue) |
| 1314 | w52-check-base | check | 7.96 | 1 | relative path not resolved by `FileAccess` |
| 1318 | w52-check-base2 | check | 7.08 | 1 | `entities[0].pos[1]` float32/float64 |
| 1321 | w52-check-base3 | check | 16.43 | 0 | parity OK (float32 quantised compare) |
| 1323 | w52-full | full selftest | **98.95** | 0 | 29/29 PASS (pre-final-edit) |
| 1325 | w52-subset-fast | fast subset | **83.14** | 0 | 5/5 PASS but Rect2 stderr corruption |
| 1328 | w52-check-base4 | check | 16.03 | 1 | Rect2 parsed as `0,0,0,0` (spaces) |
| 1329 | w52-check-base5 | check | 5.22 | 0 | parity OK after `strip_edges()` |
| 1330 | w52-subset-fast2 | fast subset | **45.44** | 0 | 5/5 PASS but `e.id % 3` float/int stderr |
| 1333 | w52-dump-base-v2 | Variant dump | 28.26 | 0 | **dump round-trip OK**, stderr empty |
| **1335** | **w52-subset-fast3** | **final fast subset** | **41.83** | 0 | **5/5 PASS, clean stderr, fast path used** |
| **1336** | **w52-baseline-subset** | same subset, **no** snapshot | **61.72** | 0 | 5/5 PASS, baseline for comparison |
| **1337** | **w52-full-final** | **final full selftest** | **60.10** | 0 | **29/29 PASS**, final code |

Comparison: **41.83 s fast vs 61.72 s baseline = 19.89 s (32.2 %) faster**, and
the final full gate at 60.10 s is itself 38.85 s faster than the earlier
98.95 s run (machine contention varies). The target is **< 30 s**, so the fast
subset is **NOT-ACHIEVED** by 11.83 s. I did not weaken any assertion, shorten
any `_sim()` window, or skip any step to approach the number.

Per-step report for 1335 (`selftest_w52_subset.json`):
`morale 156 ms`, `squad 0`, `formation 0`, `formation_bonus 0`, `replenish 0`
— ≈0.16 s of step work, so ≈41.7 s is startup (Godot boot + sprite load +
world/hud bind + fast restore). `--check-self-base` alone is only 5.22 s, so
the remaining ≈36 s is `world`/`hud` setup, not mapgen and not the snapshot
load. `BAKE_BENCH preset=low px=8 chunks=120 max_ms=2389.44 mean_ms=2028.95`
is printed on every subset run; forest-bake scheduling belongs to W5-3's
`world.gd`, outside my exclusive ownership.

## 4. Mismatch diagnosis and fix (exact evidence)

The coordinator flagged job 1297's `MISMATCH`. It was **two separate causes**,
both fixed; neither was a deliberate field omission in the final design.

1. **False positive — JSON numeric typing (jobs 1297, 1318).**
   `JSON.parse_string` returns float for integer-looking numbers. The dump's
   `seed` printed as `20261113.0` while a fresh `serialize()` returns int
   `20261113`; `str()` comparison called that a mismatch. Positions added a
   second variant: a float32 `Vector2` re-encoded as float64 text differs in
   the last bit (`root.entities[0].pos[1] 43.0032005310059 -> 43.0032005310059`).
   Fix: recursive `_same_json()` with float32-quantised numeric comparison.
   Evidence: 1321 `SELF-SNAPSHOT fast load parity: OK`.
2. **Real corruption — JSON type loss (jobs 1325, 1330).**
   - `block_rect` (a `Rect2`) became the string
     `"[P: (591.9894, 30.53222), S: (13.1562, 12.47098)]"`, causing repeated
     `SCRIPT ERROR: Trying to assign value of type 'String' to a variable of
     type 'Rect2'` at `game.gd:129`. First string-parsing repair (1328) produced
     `0,0,0,0` because the comma-separated parts had leading spaces; adding
     `strip_edges()` fixed it (1329 OK).
   - `e.id` became a float, causing `SCRIPT ERROR: Invalid operands 'float'
     and 'int' in operator '%'` at `game.gd:4461`.
   Both are symptoms of the same root cause: JSON cannot preserve Godot
   Variant types. Final fix: switch the outer snapshot container from
   `JSON.stringify` to `var_to_str` / `str_to_var` (`:712-743`, `:834`); the
   inner `game.serialize()` blob stays base64 as `deserialize()` expects.
   Evidence: 1333 round-trip OK with empty stderr; 1335 subset OK with empty
   stderr; no `SCRIPT ERROR` lines in either.

The first `raw_to_base64 ret.is_empty()` stderr lines in 1297 came from the
original 0×0 stub; the stub is now 1×1 and 1333/1335 stderr is empty.

**No broken snapshot path is left enabled.** Every load is gated by
seed/dimension validation plus full state parity; a bad or stale file falls
back to `game.setup()` with a `printerr`. The snapshot is only consulted when
`--self-only` is non-empty, so the canonical gate never touches it.

## 5. Snapshot parity evidence (verbatim stdout)

Job 1333 (`w52-dump-base-v2`):
```
self-base dump: C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/app/tests/results/w52_self_base.json
SELF-SNAPSHOT fast load parity: OK (320x320, 18 ents, seed 20261113)
SELF-SNAPSHOT dump round-trip: OK
```
Job 1335 (`w52-subset-fast3`):
```
SELF-SNAPSHOT fast load parity: OK (320x320, 18 ents, seed 20261113)
sprites: 116 sets loaded (sids=173)
SELFTEST baseline restore #1 parity: res_nodes=OK, stats=OK, blocked=OK, squads=OK, objectives=OK, ai=OK
self-test report: .../app/tests/results/selftest_w52_subset.json
```
Interpretation: the pre-baked file reproduces the freshly generated post-setup
world exactly (all serialized fields, terrain/blocked/height, tileblock,
mine_mask, starts, zones); W26's independent restore parity still passes inside
the loaded game. The full gate 1337 printed no snapshot lines, confirming the
fast path is subset-only.

## 6. Canonical artifact unchanged

Before runs: `app/selftest.json` size **4468**, sha256
`ba919cac5e19eaf422575651741bb6ec0fa69627da7197b9263e46c835c1630a`, mtime
`2026-11-24T09:49:09.704406Z`.

After all runs (including 1337): size **4468**, sha256 **identical**, mtime
**identical**. Verification reports were written only to
`app/tests/results/selftest_w52_full.json`,
`…selftest_w52_subset.json`, `…selftest_w52_baseline_subset.json`. No full
gate was run by me (coordinator owns it); the "full" runs here are the
required targeted verification to a non-canonical path.

## 7. Backups / determinism / open questions

Backups taken **before the first edit**, hashes recorded at copy time:

```
inbox/backup/main.gd.bak-W52     61528 bytes  sha256 1e996660cfe1c20b6592b4f273b4936f8bc2805a8a3cb1767d4c8a086d4fce32
inbox/backup/selftest.gd.bak-W52 34094 bytes  sha256 b0bfc4558cd3df30d3e2f596953124bd7705e390c06e2c384d6ec761c7645847
```

Tabs preserved; no called-symbol rename; no new RNG; no change to mapgen, seed,
tick size/order, assertion predicates or report shape.

Open questions:

1. **<30 s residual.** Measured 41.83 s; ~36 s of it is `world`/`hud`
   construction and forest-bake work in `world.gd` (W5-3's file). A guarded
   "no visual setup" mode for subsets whose step list excludes `hud` could
   plausibly reach <30 s, but it changes the process environment and was not
   attempted here — it belongs with W5-3 / coordinator review.
2. The snapshot is tied to `seed`, `map_w`, `map_h` and the current config
   statics; the loader validates and falls back on mismatch. Refresh via
   `--dump-self-base` after any config/mapgen change.
3. The `.json` filename now holds a `var_to_str` Variant literal. Renaming to
   `w52_self_base.snap` is cosmetic; the `format` marker prevents confusion.
4. `run_groups()` (comma-separated `--self-only`) still has no independent
   wall measurement (W26 open question 2); it would now also benefit from the
   fast load, but that combination was not benchmarked.
5. W5-1's consumer (`ai.gd:53-65`) landed concurrently; I did not touch it.
   No further action is needed from W5-2 for the hand-off.
