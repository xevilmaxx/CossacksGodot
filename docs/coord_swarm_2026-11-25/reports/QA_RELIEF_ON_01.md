---
id: QA-RELIEF-ON-01
title: "Read-only QA — verify the relief-stamps config flip after the owner lands it"
agent: "QA-RELIEF-ON-01 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/asset/config/test/PNG/JSON/git edit; no Godot submission; no dump probe; no donor access; no ladder advancement."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_RELIEF_ON_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity is claimed anywhere in this report."
verdict: "CONFIG-LEVEL PASS (one additive key, JSON value true, everything else byte-identical); MARKER EMISSION DERIVED-ELIGIBLE IN CODE; RUNTIME + VISUAL UNVERIFIED. Owner report RELIEF_ENABLE_01.md NOT LANDED as of this read."
---

# QA RELIEF ON 01 — verification of the `features.terrain.relief_stamps` flip

## 0. Mandate and boundary

Read-only verification of the relief-stamps config change. Every statement below is
tagged **observed** (literal file bytes/lines or a directly executed read-only
parse/diff), **derived** (arithmetic or control-flow consequence of observed
code), **inferred** (attribution without a pixel-aligned donor A/B), or
**UNVERIFIED**. Nothing was edited and no runner job or dump probe was
submitted. **No parity claim is made.**

---

## 1. Sources consulted

| # | Source | What it supplied |
|---:|---|---|
| S1 | `variant3d/config.json` (working tree, `:16-20`) | Current value `features.terrain.relief_stamps: true`; parse target |
| S2 | `inbox/backup/config.json.bak-RELIEFENABLE` | Pre-edit baseline; exists, 14,409 B on disk (CRLF) |
| S3 | `docs/coord_swarm_2026-11-25/reports/RELIEF_ENABLE_01.md` | **ABSENT** — no file with this name anywhere in the repo; the owner report has **not** landed as of this read (observed) |
| S4 | `reports/TERRAIN_MARKS_01.md` (`:99`, `:107-124`, `:156-191`, `:204-223`) | Rank-1 diagnosis, discriminating A/C test, harness-stub caveat, open questions |
| S5 | `reports/RELIEF_01_stamping.md` (`:71-91`, `:117-131`, `:166-184`, `:225-241`) | Consumer marker contract, PORT APPROXIMATION blend, unrun stamp path |
| S6 | `reports/RELIEF_02_stamp_marker.md` (`:49-84`, `:88-118`, `:121-140`, `:144-164`) | Producer loop, `plt2` reachable, `k_ravine_1` BLOCKED, parse-only smoke |
| S7 | `reports/CONFIG_WIRE_RELIEF.md` (`:40-55`, `:57-88`, `:89-109`) | Flag→`_dump_map()` gate, flag-off byte-identity, runtime assertion still open |
| S8 | `variant3d/scripts/main.gd` (`:179-199`, `:765-802`, `:1338-1343`, `:1364-1366`) | `cfg.load_all()`/`apply()` before dump; `relief_enabled` gate; `--config`/`--dump-config`/`--dump-map` args |
| S9 | `variant3d/scripts/config.gd` (`:46-89`, `:273-300`, `:307-320`, `:376-402`, `:448-449`, `:743-744`) | Default `false`, merge order, dotted `flag()` reader, getter, full-config dump |
| S10 | `variant3d/scripts/world3d_terrain.gd` (`:518-553`, `:1146`, `:1186-1190`, `:1435-1452`) | Marker reader, `apply_relief_grid()` call, `stats.relief_grid` counters |
| S11 | `variant3d/tests/fixtures/_smallmap_harness.gd:118-128` | Stub dump has only `map_w/map_h/height/tileblock` — no marker key |
| S12 | `git diff -- variant3d/config.json`; `git show HEAD:variant3d/config.json`; in-line Python 3.14 `json.loads`/`difflib`/SHA-256 (read-only) | Structural and byte-level before/after proof |
| S13 | `reports/SWARM_BOARD.md:311` | QA-RELIEF-ON-01 listed RUNNING |

---

## 2. Before / after verification table

| Check | Before (backup S2 / HEAD blob S12) | After (working tree S1) | Label / basis |
|---|---|---|---|
| JSON validity | parses | **parses** (`json.loads` OK) | **observed** (S12) |
| Top-level `features` key | absent | present | **observed** (S12) |
| `features.terrain.relief_stamps` | `<ABSENT>` | **`true`** (JSON boolean, lowercase literal) | **observed** (S1:18, S12) |
| Other leaf values | — | all identical (`rest identical ignoring features: True`) | **observed** (S12 recursive leaf diff: **exactly 1** differing path) |
| Textual change | — | **+5 lines / 0 deletions**; one inserted 68-byte CRLF block before `"display"` | **observed** (`git diff`; byte insertion proof, S12) |
| File size / SHA-256 (disk) | 14,409 B / `0B7E2538…9041` | 14,477 B / `BD80C2D1…48BF` | **observed** (S12) |
| Backup vs HEAD | LF-normalized text is **identical** (SHA `FAF581D1…C424`); disk copies are CRLF, git blob is LF | — | **observed** (S12) |
| `config.gd` default | `false` (`FEATURES_DEFAULTS` `:59`, fallback at `:448-449`) | unchanged | **observed** (S9) |
| `--dump-config` printed config | would omit / show default false | **derived**: would show `"relief_stamps": true` — `cfg.dump()` stringifies the whole merged `data` (S9:743-744), printed at S8:197-199; **no probe run** | **derived** / runtime **UNVERIFIED** |
| `--dump-map` marker key | absent (gate false) | **derived**: `dump["relief_stamps"]` **will be emitted** (possibly `[]`) because the gate now resolves true; **no probe run** | **derived** / runtime **UNVERIFIED** |

**Proof of "only that key changed" (observed, S12):** the current file equals the
backup file with exactly one 68-byte, 5-line CRLF block inserted after `_readme`;
recursive JSON leaf comparison reports one and only one difference —
`features.terrain.relief_stamps`: `<ABSENT>` → `True`. No other value, key order,
or payload was touched. The backup itself is byte-identical to the HEAD blob
after LF normalization, so the baseline is genuine.

---

## 3. Can the dump marker now be emitted?

**derived — statically YES; runtime UNVERIFIED.**

1. **derived:** For a `--headless --path variant3d` run, `res://` resolves to
   `variant3d/`, so `_candidate_paths("")` reads `res://config.json`
   (S9:307-320) — i.e. the very file that was flipped. `load_all()` merges
   `DEFAULT` ← config.json ← optional `--config` extra ← `user://options.json`
   (S9:273-300).
2. **derived:** `flag()` returns `bool(v)` only for a JSON bool (S9:400-402), and
   the dotted reader walks `features.terrain.relief_stamps` (S9:387-394).
   Because S1 stores a JSON boolean `true`, `feature_terrain_relief_stamps()`
   (S9:448-449) returns `true` instead of the `false` fallback.
3. **observed:** `main.gd` creates/loads/applies `cfg` at `:179-181`, before any
   `_dump_map()` call, and the gate at `:786-801` calls the getter null-safely:
   `if relief_enabled: dump["relief_stamps"] = relief_stamps`. The producer loop
   at `:775-781` fills that array only from `game.pattern_stamps` entries named
   `plt2` or `k_ravine_1`.
4. **derived:** Therefore the map dump gains the `relief_stamps` **key**; its
   **contents** may be `[]` if the seed placed no `plt2` stamp. Key presence and
   non-empty content are different claims — only the first follows from the
   config flip.
5. **UNVERIFIED:** No `--dump-map`/`--dump-config` artifact produced after the
   flip exists. A read-only search of all repo JSON/TXT/LOG files found
   `relief_stamps` **only** in `variant3d/config.json:18`; no runtime dump,
   selftest result, or stderr contains the marker. `--check-only` parse checks
   cited in S6/S7 did not execute `_dump_map()`.
6. **UNVERIFIED:** A `--config <extra>` file or `user://options.json` third layer
   could override the flag in the capture environment; neither was probed.

---

## 4. Verdict

**CONFIG-LEVEL PASS; RUNTIME AND VISUAL UNVERIFIED. NO PARITY CLAIM.**

- **observed:** the owner's config flip is present in the working tree: exactly
  one additive key, exact value `true`, valid JSON, no collateral edit. The
  pre-edit backup exists and matches HEAD, so the before state is trustworthy.
- **observed:** the owner report `reports/RELIEF_ENABLE_01.md` has **not**
  landed (S3). The config change has landed in the working tree but is still an
  uncommitted modification (`git status`: ` M variant3d/config.json`).
- **derived:** the existing `main.gd` gate makes the dump marker eligible for
  emission with this value — the flip is wired to the consumer path, not inert.
- **UNVERIFIED:** that any dump actually contains the key, that a `plt2` marker
  was placed, that heights changed, and that hills are visible. No dump probe
  was permitted in this QA job, and the sole available P0 PNG is a deliberately
  flat 64² control (S4 §1) that cannot exhibit relief.
- **inferred:** enabling the flag is a necessary condition for the donor-grid
  path, but it does not by itself establish the owner's intended visual result.
- No donor GPU A/B exists; all visual statements are PORT APPROXIMATION and
  donor parity is **UNVERIFIED**.

---

## 5. Remaining blockers

### 5.1 BLOCKED (unchanged by the flip)

- **`k_ravine_1` producer hook remains BLOCKED** (S6 §5; S7 §6 Q2). It is absent
  from `donor_patterns.json`, `pattern_gen.gd:27-36` has no `ravine_medium`
  recipe, and donor `dogenerate.inc:1760` `//`-disables `ravine_medium` in favour
  of `ravine_big` at `:1761`. `main.gd:779` still filters for the name, but no
  such stamp can be emitted without an owner-gated donor export/recipe decision.
  The config flip does **not** unblock it (observed + derived).

### 5.2 UNVERIFIED (visual / donor)

- **Visual hills** — no matched-camera A/B frame exists. The port's separate
  analytic relief (S4 §2.1) is a labelled approximation later clamped to
  ±2.964; `plt2`'s coarse 8×10 block means and per-pattern clamp would produce a
  flat-topped patch rather than a rounded hill, and `plt2` max +3.6134 exceeds
  the global cap (S4 Q3; S5 §5.6). Whether a viewer sees a hill is UNVERIFIED.
- **Donor blend** — `Replace` / `ReplaceForWater` / `Smooth` order, clamp/scale
  order, `HeightFieldOffset` and file-row→map-row sign remain UNVERIFIED; the
  implemented additive-clamp is a PORT APPROXIMATION (S5 §5; S6 §6).
- **Donor blend + props** — mountain height grids are all zero and relief lives
  in `terrainmeshN` props, which the port does not have (S5 §6); not in scope
  here.
- **Pale marks attribution** — the supplied P0 PNG has **no** white marks (S4
  §1), so which frame/seed produced the owner's marks is UNVERIFIED/inferred.
- **Donor parity** of hue, grain, relief silhouette and luma: UNVERIFIED (no
  donor A/B). No parity claim.

### 5.3 Observed caveats (not blockers)

- `world3d_terrain.gd:1449` still labels the marker field
  `"dump['relief_stamps'] (NOT in the current dump schema)"` — now stale for the
  flag-on path (observed). It is a stats string only; no functional effect.
- The P0 harness stub (`_smallmap_harness.gd:123-127`) has no `relief_stamps`
  key, so the existing 64² capture path will **always** show the flat state
  regardless of this config flip (observed + derived; S4 §4 step 4).

---

## 6. Exact discriminating capture needed

One controlled A/B, same seed, fixture, camera and app path; **proposed, NOT run**:

1. **Config read (cheap, not discriminating alone):** `--dump-config` and confirm
   the printed settings show `features.terrain.relief_stamps: true`; record
   `settings file:` path to prove which config was loaded (S8:197-199).
2. **Producer assertion — `--dump-map` (flag ON):** run with the edited config;
   assert the output JSON **has** the `relief_stamps` key (even if `[]`). If a
   `plt2` entry exists, record its `(cx,cy)`. Counterpart run with the flag
   `false` must have the key **absent**. Assert `SCRIPT ERROR == 0` (0-byte
   stderr) on both.
3. **Consumer assertion:** feed each real dump to `world3d_terrain.build()` and
   read `stats["relief_grid"]` (S10:1435-1452): flag-on must show
   `applied > 0`, a non-empty `stamps`, and a `height_min_m`/`height_max_m`
   shift versus flag-off; topology must stay 4,096 / 7,938 / 1 surface at 64².
   If the key exists but `applied == 0`, the fault is in the reader/name match,
   not the flag.
4. **Visual capture (the actual discriminator):** fixed-camera terrain-only
   capture **built from the real dump** — replace the stub dict at
   `_smallmap_harness.gd:123-127` with step 2's dump; a plain re-run of the P0
   atom cannot discriminate. Compare the two PNGs by (i) a discrete patch at the
   stamp centre `(cx,cy)`, (ii) changed-pixel count / luma delta, and (iii)
   whether pale marks coincide with height-changed cells. Record `SCRIPT ERROR
   == 0` on both stderrs.
5. **Tile-id isolation (only if marks persist with relief off):** histogram
   `tileblock` for `test7/8/9` and `rock4/8` over the marked cells and check
   against local `|dh| < 0.5`; if present on flat cells, marks are tile-art-only.

**Interpretation guard:** this tests only the port's opt-in path. It does not
validate the donor engine blend and yields **no donor parity claim**.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Has `RELIEF_ENABLE_01.md` landed yet? **No** as of this read; re-check before
   treating the owner work as fully delivered.
2. Is the flip committed, or still only an uncommitted working-tree change?
   (observed: uncommitted at QA time.)
3. Which preset/seed actually places a `plt2` stamp at runtime? Only a dump
   assertion answers this (S6 Q1; S7 Q1).
4. Does the capture environment override the flag via `--config` or
   `user://options.json` (S9:282-301)?
5. How does the later global cap +2.964 interact with `plt2` max +3.6134, and
   would the coarse 8×10 plateau read as a "mark" rather than a hill?
6. Is the file-row→map-row sign correct (row flip UNVERIFIED)?
7. Should the producer also emit verified `scale`/`footprint_w`/`footprint_h`
   instead of RELIEF-01 defaults?
8. Which frame/seed/config produced the owner's white marks? The supplied P0 PNG
   contains none, so the visual attribution stays inferred.
9. Is `k_ravine_1` worth unblocking at all, given donor disables `ravine_medium`?
10. Donor parity of terrain hue, grain, relief silhouette and luma — blocked on
    a donor GPU A/B (no parity claim).

---

## 8. Summary

Read-only QA of QA-RELIEF-ON-01. The relief-stamps flip is **present and
clean**: `variant3d/config.json` parses, and a recursive JSON leaf diff plus a
byte-level insertion proof show exactly one change —
`features.terrain.relief_stamps` `<ABSENT>` → `true` — with every other value
identical to the backup, which itself matches HEAD. The pre-edit backup
`inbox/backup/config.json.bak-RELIEFENABLE` exists and is genuine. Reading
`main.gd` and `config.gd` only, the flag is wired: the loaded config resolves the
typed getter to true and the `if relief_enabled` branch will add
`dump["relief_stamps"]` to a `--dump-map` output (DERIVED). No dump probe was
run and no runtime artifact contains the marker, so emission, stamping and
visuals are **UNVERIFIED**; the existing P0 capture uses a stub dump with no
marker and cannot discriminate. The owner report `RELIEF_ENABLE_01.md` has
**not** landed. `k_ravine_1` remains **BLOCKED**; visual hills and donor blend
remain **UNVERIFIED**; the discriminating capture is a flag-on/flag-off
`--dump-map` pair plus a fixed-camera capture fed by the real dump, asserting
marker presence, `relief_grid.applied`, height-range shift and `SCRIPT ERROR ==
0`. **No donor parity claim. No file other than this report was edited; no
runner job or dump probe was submitted.**

---

*End of QA-RELIEF-ON-01. Read-only verification; no code/config/asset/PNG edit, no Godot job, no donor access, no ladder advancement.*
