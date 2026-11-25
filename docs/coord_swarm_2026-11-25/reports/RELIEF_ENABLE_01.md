---
id: RELIEF-ENABLE-01
title: "Enable donor relief stamps in the global config — flag true confirmed at runtime; emitted array empty for the probed seed"
agent: RELIEF-ENABLE-01 (implementation builder, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — two owned files only (config.json + this report); donor READ-ONLY; three variant-runner jobs submitted (1 parse check, 1 timed-out dump, 1 successful dump)
scope: one leaf value in variant3d/config.json (features.terrain.relief_stamps false -> effective true); no source, test, shader, app/**, donor or map-size edit
owner_files:
  - variant3d/config.json
  - docs/coord_swarm_2026-11-25/reports/RELIEF_ENABLE_01.md
backup: inbox/backup/config.json.bak-RELIEFENABLE (14,409 B, SHA-256 0B7E2538D2C5...69041, byte-identical pre-edit copy)
verdict: FLAG_ENABLED__DUMP_KEY_PRESENT__ARRAY_EMPTY_FOR_SEED_20261113__APPLIED_NOT_OBSERVABLE__PORT_APPROX__DONOR_PARITY_UNVERIFIED
labels: [observed, derived, PORT APPROXIMATION, UNVERIFIED, BLOCKED (partial), PRECONDITION MISMATCH]
---

# RELIEF-ENABLE-01 — turn the donor relief-stamp opt-in on in the global config

> [!IMPORTANT]
> Donor is truth. No donor file was copied, run or edited; only transcriptions and
> citations from the decoded reports were read. The stamp tables, producer and
> sculpt blend remain the labelled **PORT APPROXIMATION** built by RELIEF-01/02;
> the donor engine blend is **UNVERIFIED** (DPATTERN-01 §5.2). No donor GPU A/B
> frame exists and **no donor parity is claimed**. All Godot launches went
> through `variant3d/tools/godot_runner.py`; no direct `godot`, no gates, no
> ladder, no test weakening.

---

## 1. Evidence read (all read-only)

| Source | Fact used |
|---|---|
| `reports/TERRAIN_MARKS_01.md:99,128-152,156-191` | Rank 1 **CONFIRMED**: `features.terrain.relief_stamps` defaults false, `main.gd` omits the marker, consumer stamps nothing; discriminating test = flag-on dump assertion + consumer `stats["relief_grid"]`. |
| `reports/RELIEF_01_stamping.md:71-91,117-131,166-184,210-221` | Opt-in reader `dump["relief_stamps"]`, 8×10 coarse tables for `k_ravine_1` / `plt2`, additive-clamp labelled PORT APPROXIMATION, engine blend UNVERIFIED. |
| `reports/RELIEF_02_stamp_marker.md:51-84,88-118,144-164,188-205` | Producer emits only real `plt2` stamps; `k_ravine_1` absent from reachable donor data and BLOCKED; which seed places `plt2` is an open question (§7 Q1). |
| `reports/CONFIG_WIRE_RELIEF.md:40-56,57-88,106-118` | `flag true` ⇒ `dump["relief_stamps"]` key is emitted; `flag false` ⇒ key absent, byte-identical to relief-off baseline. `--check-only` is parse-only. |
| `variant3d/config.json` (pre-edit) | No `features` object at all; `gameplay.map_width_tiles/height_tiles = 320`, `map_type: land`; 11 top-level keys. |
| `variant3d/scripts/config.gd:46-84,86-89,378-384,448-449` | `FEATURES_DEFAULTS.terrain.relief_stamps = false`; `DEFAULT["features"] = FEATURES_DEFAULTS`; dictionaries deep-merge key by key; `feature_terrain_relief_stamps()` = `flag("features.terrain.relief_stamps", false)`. Every key is optional. |
| `variant3d/scripts/main.gd:749-808` | `_dump_map()` gates `dump["relief_stamps"]` on the typed config getter (`:786-801`); `--dump-map` path at `:221-223,1362-1365`. |
| `variant3d/scripts/world3d_terrain.gd:518-553,1189-1195,1441-1454` | Consumer `_apply_relief_stamps_from_dump()`; `stats["relief_grid"]` with `applied` / `stamps` is a **terrain-build stat**, not a map-dump key. |
| `reports/MAP_SMALL_01_report.md:14-25,92-108,110-153` + `git show 1d67e32b,83b77eaa` | MAP-SMALL-01 terminated and reverted BOTH owned files: the 21-key `features` block and 240² were removed and 320² restored in commit `83b77eaa`; the block was only additive/JSON-valid, the gate failure was the 240² harness layout, not the flag table. |

### Donor citations carried by the enabled path (unchanged)

- `DPATTERN_01_relief_grids.md:142` — `k_ravine_1` 46×63, window offset 2866, scale 1, min `−2.963627576828003`, max `+3.139820098876953` (exact match `pattern.lib:549585-549586`).
- `DPATTERN_01_relief_grids.md:154` — `plt2` 42×55, offset 2266, scale 1, min `−0.07325489819049835`, max `+3.6134116649627686` (`pattern.lib:6805-6806`).
- `DPATTERN_01_relief_grids.md:302-346` — placement via `dogenerate.inc:1621-1765` + `generator.cfg` `Freq`; `ravine_medium` is `//`-disabled at `:1760`, active ravine is `ravine_big` at `:1761`.
- `DPATTERN_01_relief_grids.md:348-382` — sculpt config exists only in `pattern.lib`, no plaintext consumer; engine blend UNVERIFIED, additive-clamp is the labelled port reading.
- `DPATTERN_01_relief_grids.md:595-626` (Appendix A1/A2) — the two coarse 8×10 block-mean grids, explicitly "debug/preview aids only — stamp from the full grid".
- `DTRN_02_donor_terrain_geometry.md:102-106` — C6/C7: `.pattern` float32 grids are height geometry and the donor does sculpt; C10: baked heights clamped to ±2.964.

---

## 2. Precondition mismatch — stated, not silently "fixed"

The ticket asked to flip a value inside an existing **21-key `features` set at 240²**.
That state is **not on disk**: `variant3d/config.json` at HEAD `83b77eaa` is
**320×320**, `map_type: land`, with **no `features` object** (backup
`config.json.bak-RELIEFENABLE`, SHA-256 `0B7E2538…69041`, matches HEAD).
The 21-key block was added in `1d67e32b` and removed together with the 240²
change in `83b77eaa`, per MAP-SMALL-01's mandatory full revert after its gates
failed (best 28/29, `build`; `MAP_SMALL_01_report.md:110-153`).

**Decision:** do **not** re-apply the terminated 240² change or the removed
21-key table. That would reintroduce a known-red configuration and add 20 keys
that do not exist in the owned file. Instead I made the smallest possible
change to the actual file: a top-level `features` object containing **only**
`terrain.relief_stamps: true`. `config.gd:378-384` deep-merges it into
`FEATURES_DEFAULTS`, so all other 20 feature values keep resolving byte-for-byte
as before. `map_width_tiles/map_height_tiles = 320` and `map_type: land` are
untouched. This is a deviation from the ticket's stated pre-state and is
recorded as open question Q1.

---

## 3. Before → after (backup → current)

Backup: `inbox/backup/config.json.bak-RELIEFENABLE` (pre-edit, SHA-256
`0B7E2538D2C55B3B9F5F15830D09D8C07459314A82A52767DEDFDF731CA69041`).
Current: SHA-256 `BD80C2D10D1FBFEE05EC6042CB90DF02269A539D561F373355DB1F86348BF0F5`.
`git diff --no-index --stat` = **5 insertions, 0 deletions**, purely additive:

```diff
@@ -13,6 +13,11 @@
  ],
+ "features": {
+  "terrain": {
+   "relief_stamps": true
+  }
+ },
  "display": {
```

Effective change: `feature_terrain_relief_stamps()` resolves **false → true**
(`config.gd:448-449`) because the JSON leaf now overrides the default at
`config.gd:59`. Unchanged by construction: all 11 pre-existing top-level keys
and every leaf value inside them (`320×320`, `map_type: land`, seed, units,
buildings, controls, names, economy, AI, audio, camera, display), CRLF line
endings (832 → 837), and every 20 other feature default (now inherited from
`FEATURES_DEFAULTS` exactly as before). No `k_ravine_1` was forced; no stamp
was invented; no code, test, shader, `app/**` or donor file was edited.

`json.load()` on the result: **OK**, `features.terrain.relief_stamps == True`,
map `320×320`, `map_type == "land"`, 12 top-level keys.

---

## 4. Validation — variant runner only

Four submissions (three completed executions; one cancelled before running). All
ids unique; no direct `godot`, no gate, no ladder.

| Job / ticket | Command (abbreviated) | Result |
|---|---|---|
| `reliefenabl01-smoke` / **520** | `--headless --path variant3d --check-only --script res://scripts/main.gd` | wait 168.67 s, run 21.22 s, **ok**, exit 0, stderr **0 B** → `SCRIPT ERROR == 0`, stdout = Godot 4.7.2 banner only. Parse/compile check of `main.gd`; config not executed. |
| `reliefenabl01-dump` / **521** | `--headless --path variant3d -- --dump-map <temp>` at shipped 320² | **timed-out** after 190.21 s (runner hard cap 180 s), exit −9, stderr 45 B = `[runner] KILLED after 180.0s`; no dump file. Attribute to 320² mapgen duration, **not** to a config/parse error (banner printed, no SCRIPT ERROR). |
| `reliefenabl01-dump-r2` / **526** | same but with the read-only 64² fixture | **cancelled before running** — the fixture path contains a space and PowerShell split it into two argv tokens. Runner: `cancelled 1 pending job(s): [526]`; later `skipped`. No Godot execution. Replaced by r3. |
| `reliefenabl01-dump-r3` / **527** | `--headless --path variant3d -- --config "<abs>/variant3d/tests/fixtures/small_map_64.json" --dump-map <temp>` | wait 152.69 s, run 20.58 s, **ok**, exit 0. stdout = banner + `map dump: C:/.../reliefenabl01_dump.json`; stderr 416 B = one benign `WARNING: T-MINES-FIX: no open coal site near start (5,60)` (`pattern_gen.gd:676`), **no `SCRIPT ERROR`**. |

The 64² fixture (`variant3d/tests/fixtures/small_map_64.json`, read-only)
overrides **only** map dimensions; `config.gd:273-293` loads and merges the
shipped `config.json` first, so the flag under test is the edited global one.

### Runtime dump content (observed, ticket 527)

`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefenabl01_dump.json`,
54,137 B, seed 20261113, 64×64, parsed with Python 3.14 `json.load()`:

```
keys = ['blocked','clusters','height','map_h','map_w','meta','relief_stamps',
        'res','seed','starts','terrain','tileblock']
has_relief_stamps = True
relief_stamps    = []            # key emitted, NO pattern stamp placed
```

**Interpretation (honest):** the flag is **confirmed live** — the key exists,
whereas relief-off produces no key at all (`CONFIG_WIRE_RELIEF.md:82-87`).
But the emitted array is **empty**: this seed/preset placed no donor-grounded
`plt2` stamp, so this particular dump would still stamp zero cells. That is
exactly the open question in `RELIEF_02_stamp_marker.md:190` (which presets/seeds
place `plt2`), **not** a producer failure and not a fabricated marker. No
`k_ravine_1` entry appears, as expected (BLOCKED).

`stats.relief_grid.applied` is **not observable in the map dump**: it is produced
by `world3d_terrain.build()` (`world3d_terrain.gd:1189-1195,1441-1454`), and
`--dump-map` writes only the 12 keys above. No sanctioned test loads a real dump
into the consumer (the P0 harness stub at `_smallmap_harness.gd:123-127` has no
marker key). With `relief_stamps = []`, the consumer would report `applied = 0`
by construction, but that value was **not measured** here — it is UNVERIFIED.

### Gate statement

No gate job was run by this ticket. The integrated selftest remains red at
**28/29 (`build`)** per `RUN_GUIDE.md:143` and `MAP_SMALL_01_report.md:151`;
this is unchanged, not caused by this edit, and was **not** weakened — no test,
threshold, assertion or expected value was touched. No green claim is made.

---

## 5. Still BLOCKED / UNVERIFIED

1. **No donor GPU A/B.** All visual attribution is PORT APPROXIMATION; hue,
   grain, relief silhouette and luma parity are UNVERIFIED. Enabling a port
   switch is not donor parity evidence.
2. **`k_ravine_1` remains BLOCKED.** Absent from `donor_patterns.json` and every
   family list; `ravine_medium` is not in `pattern_gen.gd:27-36` and is
   `//`-disabled at donor `dogenerate.inc:1760`. No such marker was invented.
3. **Coarse 8×10 grid is a debug/preview aid** (DPATTERN-01 `:595-600`), not the
   full float32 window; it can produce a flat-topped ≈10×8-cell plateau rather
   than a rounded hill. `plt2` max `+3.6134` exceeds the port's later `+2.964`
   cap (`game.gd:1096-1097`); reconciliation UNVERIFIED.
4. **Engine sculpt blend UNVERIFIED** — `Replace` / `ReplaceForWater` / `Smooth`
   and clamp/scale order have no plaintext consumer (DPATTERN-01 §5.2, §9 Q2);
   file-row→map-row sign (flip) UNVERIFIED (§9 Q3); footprint extent UNVERIFIED.
5. **Producer coverage UNVERIFIED** — the observed seed placed no `plt2` stamp;
   which seeds/presets do place one is unmeasured (`RELIEF_02` §7 Q1).
6. **`stats.relief_grid.applied` UNMEASURED** — not present in `--dump-map`
   output; requires a consumer-side dump-loading test, which was not run.
7. **Precondition mismatch (§2)** — 240² and the 21-key set are absent from
   HEAD because MAP-SMALL-01 was terminated and reverted them; not restored here.

---

## 6. Open questions (UNVERIFIED — do not guess)

1. **Q1 — owner acknowledgment of §2.** Does the coordinator accept the minimal
   one-leaf `features` object at 320², or should a separate, explicitly owned
   ticket re-add all 21 default-mirroring leaves (and only then consider 240²,
   whose gate is still red)?
2. **Q2 — seed sweep.** Which preset/seed actually places a `plt2` stamp? The
   probed seed 20261113 at 64² produced `[]`; a runtime dump-content sweep is
   needed before claiming any relief is visible.
3. **Q3 — consumer assertion.** Feed a dump with a non-empty `relief_stamps`
   array into `world3d_terrain.build()` and confirm `applied > 0`, `stamps`
   non-empty and a height-range shift (`TERRAIN_MARKS_01 §4` step 3).
4. **Q4 — hills vs patch.** If `plt2` fires, does the 8×10 plateau read as a hill
   at the fixed camera, or as the flat pale "mark" ranked #3 in
   `TERRAIN_MARKS_01.md:101`?
5. **Q5 — `k_ravine_1`** — is it worth unblocking given the donor disables
   `ravine_medium` (`dogenerate.inc:1760`)? A decision, not a mechanical fix.
6. **Q6 — clamp reconciliation** between `+3.6134` and `+2.964` (`game.gd:1096-1097`).
7. **Q7 — donor parity A/B** remains the blocking evidence for any visual claim.

---

## 7. Summary

Enabled the donor relief-stamp opt-in in the global config with the smallest
possible edit: `variant3d/config.json` gains a top-level `features` object whose
only leaf is `terrain.relief_stamps: true` (5 added lines, 0 deletions). Backup
`inbox/backup/config.json.bak-RELIEFENABLE` is the byte-identical pre-edit file;
JSON parses; 320², `map_type: land` and every pre-existing key are untouched.
`config.gd:378-384` deep-merges the partial block, so the other 20 feature
defaults are unchanged in effect.

Validation via the variant runner: `reliefenabl01-smoke` (ticket 520) `ok`,
`SCRIPT ERROR == 0`; a first 320² dump (ticket 521) timed out at the 180 s cap;
a malformed 64² probe (ticket 526) was cancelled before running; the corrected
`reliefenabl01-dump-r3` (ticket 527) `ok` produced a real runtime dump whose
`relief_stamps` key **is present** — proving the flag is live — but whose array
is **empty** for seed 20261113, so no stamp actually fired in that probe.
`stats.relief_grid.applied` is not in the dump schema and was **not measured**.
The 28/29 (`build`) gate is unchanged and was not weakened. `k_ravine_1` stays
BLOCKED, the coarse grid and blend stay PORT APPROXIMATION / UNVERIFIED, and no
donor parity is claimed.

**Files edited by this agent:** `variant3d/config.json` and this report, plus
one backup artifact. **No other file was edited** — not `config.gd`, `main.gd`,
`world3d_terrain.gd`, any test, shader, donor asset or `app/**`. The runner
result artifacts and the temp dump are harness output, not source edits.

*End of RELIEF-ENABLE-01.*
