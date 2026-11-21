---
title: Attack-action duration adjudication (P-34, last animation-data question)
owner: PORT-ANIM
ticket: P-34
decision: D-22
updated: 2026-11-21
status: CLOSED-ADJUDICATED (no data change)
---

# 🔬 Attack duration: data defect vs stale rule — P-34 / D-22

> [!IMPORTANT]
> Quality-first protocol (`SWARM_OPS.md` §5b-QUALITY, decision **D-22**):
> evidence before edits, independent re-verification by a different method,
> `observed` / `derived` / `inferred` kept separate, **no bulk data change to
> make a test green**. Ownership for **P-34** is limited to
> `app/assets/models/anim/index.json` (read + snapshot backup only) and this new
> audit file. **No value in `index.json` was changed**; no test, no game code and
> no other index was edited. Snapshot: `inbox/backup/index.json.bak-PORT-ANIM`
> (104,582 bytes), taken before analysis.

## Claim table

| # | Claim | Evidence | Verification method | Verdict | Correction needed |
|---|---|---|---|---|---|
| 1 | "50 attack actions have a bad `duration` because they fall below GUIDE4's `n*0.12` nominal" | **observed**: the current 54-key index has **51** attack actions, all below `frames*0.12` (range 0.2..1.233 s; 48×12-frame, plus mortar 6f/0.2, multicannon 7f/0.233, pikeman18 9f/0.3). GUIDE4 DO-L7.06 L897 sets `n*0.12` in the same breath as the walk-stride `n*0.09`, from a 1.5 m/s foot-length eyeball. | Read index.json with Python; re-derived every value from donor AAF (claim 2) | **CONTRADICTED** (rule wrong) | None to data. Retire the `n*0.12` attack threshold; see test proposal. |
| 2 | Attack `duration` = donor AAF range length ÷ donor fps | **observed**: 51/51 donor AAF files + `.oss` headers found and read read-only; **51/51 exact** (0 mismatches), e.g. `pikeman.aaf attack0 32..46` → 15/30 = 0.5; `archer.aaf attack1 130..157` → 28/30 = 0.933; `cannon.aaf attack1 301..337` → 37/30 = 1.233; `mortar.aaf attack0 301..306` → 6/30 = 0.2. Baker source: `bake_sprites.py:246` `duration=(last-first+1)/fps`, action priority `:231` (`attack1`,`attack0`,`attack2`,`attack`), key→base `:552-565`. | Independent script re-reading donor AAF text and `.oss` 6-int header (fps = 2nd int), NOT calling the baker — different method from the audit that produced the data | **CONFIRMED** | none |
| 3 | Attack frames are a one-shot sim-clock swing, not a looping animation | **observed**: `world.gd:257` selects `attack` only while `gt - fire_t < 0.9`; `:331` sets `t0 = fire_t`; `:337` `fi = min(n-1, int((gt-t0)/duration*n))` (clamped, no `% n`); `:339` uses `anim_t % n` only for the non-fire_t branch. `game.gd:3590` sets `fire_t = time_s` once per shot. **All 51 attack entries have `loop = false`**. GUIDE4 L898 itself documents `death/attack fi = (game.time_s-t0)/duration*n clamped (sim clock)`. | Source read + full index sweep of `loop`; second method = GUIDE4 L891/L898 textual cross-check | **CONFIRMED** | none |
| 4 | Some attack entries are the 0.05 s min-clamp mis-bake DO-L7.02 warns about | **observed**: no action anywhere in the 54-key index has `duration == 0.05`; minimum attack duration is **0.2** (mortar), minimum `frames` is **6**, all `duration > 0`, all `loop` bool. | Full index sweep over all 299 actions | **CONTRADICTED** | none |
| 5 | Attacking 51 entries to `n*0.12` would improve fidelity | **derived**: `n*0.12` = ~8.3 fps playback; donor is 30 fps. Slowing a clamped one-shot would stretch the muzzle flash / blade swing ~3.6× beyond the donor clip and desync it from `fire_t` (the sim fires every `cd` seconds, independent of animation). Locomotion has a foot-slide constraint a one-shot does not, so the walk-stride rationale does not transfer. | Calculation from claim 2 fps + claim 3 clock | **CONTRADICTED** (would be a regression) | none — do NOT retime |

**Verdict distribution (whole P-34 question):** **51/51 rule-wrong**, **0 data
defect**, **0 mixed** — i.e. **not mixed**. No entry was changed. This is the
same class of ruling as D-24/D-25/P-45: a stale GUIDE4 heuristic must not detune
correct donor-exact data.

## Independent re-verification (E1 — different method)

Temp script (outside the repo, no donor bytes copied into `res://`) reads each
donor `data\animations\aaf\<base>.aaf` as text and each
`data\actors\units\<base>.oss` 24-byte header, replicates
`bake_sprites.py:71-82`/`:59`/`:231`/`:246`, and compares to the stored value.
Result: `attack entries in index: 51; donor AAF found: 51; donor OSS found: 51;
MATCH (donor-exact): 51; MISMATCH: 0`. Full 51-row evidence table in Appendix A.

The baker's `frames` count is a **12-frame resample** of the donor range
(`:245`), so `frames/duration` is *not* expected to equal 30 for attacks —
using `frames` as a cadence proxy is exactly the P-45 mistake. The donor AAF
range, not the sampled row count, is the authority.

## E2 — count drift vs the deferred note (open question, low priority)

`UNIT_BAKING_FIX.md` §11.4 and `ANIM_ADJUDICATION.md` §"Genuine data defects
left" deferred **50** short attack durations and quoted a range of
**0.2..1.03 s**. Today's index has **51** and **0.2..1.233 s** (the two newest
maxima are `dragoon17` 1.133 and `cannon` 1.233). **observed**: both are
donor-exact (Appendix A), so the drift does not change the verdict; the current
index is the authority. **open**: whether the earlier count excluded a key or
was a transcription slip — cosmetic, no ticket needed unless the board tracks
exact deferred counts.

## Proposed test-rule change for the test owner (do NOT edit tests here)

`t_anim_metrics.gd` currently has **5 checks** and **no attack-duration rule**;
that is correct — do not add `duration ≈ frames*0.12`. If a guard is wanted,
the fidelity-grade option is a new `attack_one_shot` check backed by a checked-in
donor manifest (Appendix A is ready to copy): for all 51 attacks assert
`loop == false`, `duration > 0`, `frames >= 2` **and**
`duration == round((last-first+1)/fps, 3)` from the manifest (±0.001). That
catches the real failure mode DO-L7.02 describes (a 0.05 s min-clamp hyper-flap)
and any accidental retiming, without rejecting donor truth. A weaker
donor-plausibility fallback (`0.15 <= duration <= 2.0`, `loop == false`) is
acceptable but cannot detect a wrong-but-plausible retime.

**UNVERIFIED** (not claimed as done): no windowed/frame-step visual capture of
a swing at `t = fire_t` was made in this ticket; the data and the clock are
confirmed, the on-screen look is not. If required, raise a separate visual
ticket rather than re-timing data on eyeball.

## Gate verification (fresh runner jobs, no code/data change)

- **t_anim_metrics** — runner ticket **450** `portanim-tanim`: wait 126.57 s,
  run 0.60 s, `exit 0`, `status ok`. `app/tests/results/t_anim_metrics.json`
  **fresh** (`unix_ms 1795254024765`, mtime 10:40:24): `passed: true`, **5/5**
  (`main_index_54_units`, `action_structure`, `metric_ranges`, `walk_stride`,
  `naval_schema`).
- **selftest** — runner ticket **455** `portanim-selftest`: wait 81.77 s,
  run 32.33 s, `exit 0`, `status ok`. `app/selftest.json` **fresh** (mtime
  10:42:29): `passed: true`, **29/29 steps**, 0 failures.
- `index.json` sha256 equals the pre-analysis snapshot
  (`3a4a3a082285c47b5aab6d3056c9cc5f27548f296c329457ccf6ead51f24f821`) —
  zero data edits, gates are regression confirmations, not a repair.

## Files changed

- `docs/audit/ANIM_ATTACK.md` — this file (new).
- `inbox/backup/index.json.bak-PORT-ANIM` — snapshot only; `index.json` byte-identical.

## Appendix A — all 51 attack actions re-derived from donor (read-only)

| key | donor base | AAF action | AAF range | fps | expected=stored | frames |
|---|---|---|---|---|---|---|
| archer | archer | attack1 | 130..157 | 30 | 0.933 | 12 |
| aus_peasant | peaaus | attack0 | 237..254 | 30 | 0.600 | 12 |
| cannon | cannon | attack1 | 301..337 | 30 | 1.233 | 12 |
| chasseur | chasseur | attack1 | 99..121 | 30 | 0.767 | 12 |
| cossack | cossacksich | attack0 | 592..604 | 30 | 0.433 | 12 |
| cossackdon | cossackdon | attack0 | 656..669 | 30 | 0.467 | 12 |
| cossackregister | cossackregister | attack0 | 656..669 | 30 | 0.467 | 12 |
| croat | croat | attack0 | 640..653 | 30 | 0.467 | 12 |
| cuirassier | cuirassier | attack0 | 640..653 | 30 | 0.467 | 12 |
| dragoon | dragoon18 | attack0 | 592..604 | 30 | 0.433 | 12 |
| dragoon17 | dragoon | attack0 | 592..625 | 30 | 1.133 | 12 |
| eng_peasant | peaeng | attack0 | 237..254 | 30 | 0.600 | 12 |
| grenadier | grenadier | attack1 | 99..114 | 30 | 0.533 | 12 |
| hackapell | hackapell | attack0 | 640..653 | 30 | 0.467 | 12 |
| hetman | hetman | attack0 | 640..654 | 30 | 0.500 | 12 |
| highlander | highlander | attack1 | 99..124 | 30 | 0.867 | 12 |
| howitzer | howitzer | attack0 | 301..312 | 30 | 0.400 | 12 |
| hussar | hussar | attack0 | 592..605 | 30 | 0.467 | 12 |
| jannisary | jannisary | attack1 | 99..124 | 30 | 0.867 | 12 |
| lightcavalry | lightcavalry | attack0 | 592..604 | 30 | 0.433 | 12 |
| lightinfantry | lightinfantry | attack0 | 184..197 | 30 | 0.467 | 12 |
| mameluke | mameluke | attack0 | 656..669 | 30 | 0.467 | 12 |
| mortar | mortar | attack0 | 301..306 | 30 | 0.200 | 6 |
| mullah | mullah | attack0 | 136..166 | 30 | 1.033 | 12 |
| multicannon | multicannon | attack0 | 301..307 | 30 | 0.233 | 7 |
| musk18 | musketeer18 | attack1 | 99..113 | 30 | 0.500 | 12 |
| musketeer | musketeer | attack1 | 99..124 | 30 | 0.867 | 12 |
| officer | officer | attack0 | 29..42 | 30 | 0.467 | 12 |
| officer18 | officer18 | attack0 | 29..46 | 30 | 0.600 | 12 |
| padre | padre | attack0 | 143..173 | 30 | 1.033 | 12 |
| pandur | pandur | attack1 | 99..124 | 30 | 0.867 | 12 |
| peasant | peaukr | attack0 | 237..254 | 30 | 0.600 | 12 |
| pikeman | pikeman | attack0 | 32..46 | 30 | 0.500 | 12 |
| pikeman18 | pikeman18 | attack0 | 32..40 | 30 | 0.300 | 9 |
| pol_peasant | peapol | attack0 | 237..254 | 30 | 0.600 | 12 |
| pope | pope | attack0 | 136..159 | 30 | 0.800 | 12 |
| priest | priest | attack0 | 143..173 | 30 | 1.033 | 12 |
| reiter | reiter | attack0 | 640..653 | 30 | 0.467 | 12 |
| roundshier | roundshier | attack0 | 79..90 | 30 | 0.400 | 12 |
| rus_peasant | pearus | attack0 | 237..254 | 30 | 0.600 | 12 |
| sco_peasant | peasco | attack0 | 237..254 | 30 | 0.600 | 12 |
| serdiuk | serdiuk | attack1 | 99..114 | 30 | 0.533 | 12 |
| sipahi | sipahi | attack0 | 640..651 | 30 | 0.400 | 12 |
| spa_peasant | peaspa | attack0 | 237..254 | 30 | 0.600 | 12 |
| spakh | spakh | attack0 | 656..669 | 30 | 0.467 | 12 |
| strelet | strelet | attack0 | 32..53 | 30 | 0.733 | 12 |
| tatar | tatar | attack1 | 642..670 | 30 | 0.967 | 12 |
| tur_peasant | peatur | attack0 | 237..254 | 30 | 0.600 | 12 |
| ukr_peasant | peaukr | attack0 | 237..254 | 30 | 0.600 | 12 |
| vityaz | vityaz | attack0 | 640..651 | 30 | 0.400 | 12 |
| wingedhussar | wingedhussar | attack0 | 656..667 | 30 | 0.400 | 12 |
