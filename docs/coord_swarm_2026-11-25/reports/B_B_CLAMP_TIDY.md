---
id: B-B-CLAMP-TIDY
title: "Z2 §1.4 no-op clamp tidy — fold PORT ±2.964 into donor stamp clamp, drop redundant second clamp"
agent: "B-B-CLAMP-TIDY (implementation builder, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__CODE_EDIT_LANDED__RUNTIME_UNVERIFIED__NO_PARITY_CLAIM
scope: "Two files only: variant3d/scripts/game.gd (tidy) + this report. No other file written. app/, pattern_gen.gd, world3d_terrain.gd, shader, config, adapter untouched (foreign)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, UNVERIFIED]
parity_guard: "PORT APPROXIMATION throughout. No donor GPU A/B exists; no donor parity is claimed. Byte-equivalence below is port-old-vs-port-new only."
---

# B-B-CLAMP-TIDY — report

## 0. Task and verdict

- Task: apply ONLY the Z2-HEIGHT-TILES §1.4 no-op tidy (fold pattern min/max into the
  stamp clamp at old `game.gd:1052`; remove the double clamp). No ±2.964 change, no
  analytic-profile / smoothing / detail / cliff / start-flatten change (P1-2 separate).
- Verdict: **CODE EDIT LANDED — RUNTIME UNVERIFIED (single parse job timed-out, no
  negative signal) — NO PARITY CLAIM.** Byte-equivalence is carried by an exact
  analytic proof (§4); the runtime dump-hash compare could not be run cleanly within
  the one-validation budget (§5).

## 1. Governance compliance

| Check | Result | Evidence |
|---|---|---|
| Backup first | done, **byte-identical** | `inbox/backup/game.gd.bak-BBCLAMP` SHA-256 `965036df…8d806b3f4e8` == pre-edit `variant3d/scripts/game.gd` SHA-256 `965036df…8d806b3f4e8` (compared in-shell before any edit; §2) |
| Files owned / touched | `variant3d/scripts/game.gd` + this report only | `git status`: no other file touched by this agent; foreign working-tree mods (`config.json`, `config.gd`, `pattern_gen.gd`, `world3d_terrain.gd`) pre-existed and were NOT touched |
| Threshold/seed/cost change | none | diff-scope assertion: exactly 1 added + 1 removed executable line; added line contains no `rng/randf/randi/_reseed/RANDOM_SEED` and no numeric literal other than the pre-existing `RELIEF_*` const refs (§3) |
| Test weakening | none | no test/config/seed file touched |
| Constants intact | `RELIEF_PLATEAU := 2.964`, `RELIEF_RAVINE := -2.964` unchanged; analytic `:1099` clamp unchanged; dump-ledger strings unchanged (dump-meta bytes preserved) | asserted in-shell (§3) |

## 2. Backup evidence

- Pre-edit `variant3d/scripts/game.gd` SHA-256: `965036DF7579A9FF4D5CDC9CADBEA1106130F44128A461F5C353C8D806B3F4E8`
- `inbox/backup/game.gd.bak-BBCLAMP` SHA-256: identical (`IDENTICAL=True`), copied before any edit.
- Post-edit `variant3d/scripts/game.gd` SHA-256: `0e46047b7b3cfc0d97a047c2b7bd7fd463b3f4000a54d8c316478ad352e3e7df` (diff = §3 only).

## 3. Exact diff (`git diff -- variant3d/scripts/game.gd`; full diff, 2 hunks)

Hunk 1 — donor-grid stamp clamp folded (old `:1052`, new `:1055` after the +3 comment shift):

```gdscript
-					height[i] = clampf(height[i] + gv0 * gscale, gmin, gmax)
+					height[i] = clampf(height[i] + gv0 * gscale, maxf(gmin, RELIEF_RAVINE), minf(gmax, RELIEF_PLATEAU))
```

plus 3 comment lines documenting the fold (no behaviour). Hunk 2 — composite loop
(old `:1219-1229`, new `:1222-1231`): the now-redundant second clamp line deleted,
donor branch keeps its dither-skip `continue`, comment refreshed to stay true:

```gdscript
 		if _relief_donor_mask[hi] != 0:
-			# ... (8-line RELIEF-LIVE-FIX-01 comment describing the second clamp)
-			height[hi] = clampf(height[hi], RELIEF_RAVINE, RELIEF_PLATEAU)
+			# RELIEF-LIVE-FIX-01 clamp reconciliation (Z2 §1.4 no-op tidy).
+			# The single PORT ±2.964 bound is folded into the stamp clamp
+			# (maxf(gmin, RELIEF_RAVINE), minf(gmax, RELIEF_PLATEAU)), so no
+			# second clamp runs here; donor cells still skip the 0.03 dither
+			# cap below (no dither-as-shape on donor cells).  The donor clamp
+			# itself is UNVERIFIED — generatemap.inc has no height clamp
+			# (HEIGHT-GEN-DEEP-01 §5.4/§8 Q1).  cMaxHeight=2.96 is a
+			# tile-class constant.
 			continue
```

### 3.1 Documented deviation from the literal ticket wording (deliberate, proved in §4)

- The ticket says "delete the donor-cell `continue` at `:1229`". Taken literally
  (delete only the `continue`, keep the `:1228` clamp), donor cells would fall through
  into the dither-cap clamp (`hcap = 2.964` or `2.964-0.03` at `:1232-1239`), which
  lowers saturated donor cells with `hq >= 0.58` from 2.964 to 2.934 — a REAL
  behaviour change on any seed that places a donor stamp (e.g. seed 20261150,
  `applied_cells=443`). That reading contradicts the ticket's own "numerically
  identical" requirement and the BYTE-EQUIVALENT-ONLY governance, so it was NOT done.
- What was done instead: delete the redundant `:1228` clamp (provably a no-op after
  the fold), KEEP the `continue` (donor cells still skip dither, exactly as before).
  This is the unique reading under which "removes the double clamp" AND "numerically
  identical" are both true. Flagged here explicitly for COORD review; one-line revert
  path is the backup in §2.

## 4. Byte-equivalence proof (analytic; derived — exact, no rounding involved)

- Donor cells. Old value: `h2 = clampf(clampf(h0, gmin, gmax), RAVINE, PLATEAU)`.
  New value: `h1 = clampf(h0, maxf(gmin, RAVINE), minf(gmax, PLATEAU))`. Clamp
  composition `clamp(clamp(x,a,b),c,d) = clamp(x,max(a,c),min(b,d))` holds exactly;
  `minf/maxf/clampf` are exact (no rounding). Identical for every `h0`, every
  `(gmin, gmax, gscale)` — **observed** consts: `k_ravine_1 min -2.9636276 ≥ -2.964`,
  `plt2 max +3.6134117` (fold bites only on the upper side, as Z2 §1.4 states).
- No-op status of the deleted `:1228` line post-fold: folded stamp output already lies
  in `[maxf(gmin,RAVINE), minf(gmax,PLATEAU)] ⊆ [-2.964, +2.964]`; nothing between the
  stamp call (`:1209`) and the composite loop (`:1219`) writes `height[]` (verified:
  only comments + the `_pattern_build` assignment precede the loop), and donor cells
  `continue` past the analytic branch inside the stamp loop (`:1058`). Hence the
  deleted clamp was the identity on donor cells. **derived**.
- Non-donor land cells: identical code path (dither block byte-untouched). Water
  (`terrain==3`): skipped before and after. No RNG call added/removed/reordered, so
  all downstream streams (stamps, tiles, collision, meta) are bit-stable given equal
  inputs; ledger strings untouched so dump-meta bytes are preserved. **derived**.
- Untouched as required: `:81/:83` constants, `:1099` analytic clamp, `:1059-1102`
  analytic profiles, smoothing, detail pass, cliffs, start-flatten. **observed**
  (diff contains none of them).

## 5. Validation (ONE runner job — the allowed max; no re-submit)

- Job: ticket **575** `bbclamptidy01-parse`:
  `godot_runner.py run --id bbclamptidy01-parse --timeout 300 --max-wait 900 -- --headless --path variant3d -- --check-only res://scripts/game.gd`
- Result (verbatim from `variant3d/.godot_queue/results/00000575.json`): status
  **timed-out**, `exit: -9`, `wait: 0.0007s`, `run: 302.44s` (hard-killed at 300s).
  Queue was FREE at submit (`pending=0`, lock free); waited 0.00s; no other job touched.
- Streams: `stdout.txt` 75 B = Godot banner only (engine booted, still in
  project-import/scan when killed); `stderr.txt` 45 B = runner KILLED line only.
  **SCRIPT ERROR count = 0** in both streams (a GDScript syntax error would print and
  exit fast; none did). **No negative signal — but no parse PASS either: runtime
  verdict INCONCLUSIVE / UNVERIFIED.** Not re-submitted (one-validation-max + no
  re-submit rule). Precedent: repo parse/check jobs routinely time out in this band
  (tickets 215/218/221/227/237: 120–312 s).
- Why no `--dump-map` hash compare (and why the ticket's "seed 20261113" number could
  not be used): the only on-disk pre-change baselines — `reliefseedprobe/dump.json`
  (seed 20261150, 13:21, height sha16 `1ab1573a4738709a`, tileblock `72cfda93c7354088`,
  `applied_cells=443`) and `relieflive01_dump.json` (seed 20261113, height sha16
  `12750f48bd17e919`) — both predate FOREIGN working-tree edits that went live at
  13:56–13:57 (`pattern_gen.gd` stamp-path changes incl. `size_mod` multiplier and the
  `needed`-count rule; `config.gd`/`config.json` overlay changes). A recorded-hash
  compare would therefore be CONFOUNDED (a mismatch would be un attributable; a match
  would prove nothing about this tidy). A clean before/after pair needs two jobs,
  barred by the one-validation cap. Method readiness verified locally (no runner):
  base64→raw→SHA-256-first-16 of the on-disk `dump.json` reproduces the recorded
  `1ab1573a4738709a` / `72cfda93c7354088` exactly — COORD can run the pair when the
  tree is quiet. Seed-20261113 note: on that seed the donor branch is dead
  (`applied_cells=0`), so the edited lines never execute there; seed 20261150
  (`applied_cells=443`) is the discriminating seed for any future pair.

## 6. Before → after dump hashes

- **Not measured** (see §5 for the blocking reason). No dump job submitted; no
  selftest/uitest run (COORD-last rule). No parity claim of any kind.

## 7. Files

- Modified: `variant3d/scripts/game.gd` (2 hunks, §3).
- Created: `inbox/backup/game.gd.bak-BBCLAMP` (pre-edit, hash-verified §2); this report.
- Explicitly NOT touched: `app/**`, `pattern_gen.gd`, `world3d_terrain.gd`, shaders,
  configs, adapters, tests, docs (other builders live).

*End of B-B-CLAMP-TIDY. One code file + one backup + one report; one runner job
(ticket 575, timed-out, SCRIPT ERROR 0); no parity claim.*
