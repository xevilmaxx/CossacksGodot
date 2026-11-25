---
id: QA-RELIEF-LIVE-01
title: "Read-only QA — verify RELIEF-LIVE-DIAG-01's root-cause ranking against current source"
agent: "QA-RELIEF-LIVE-01 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source, config, asset, test, PNG, JSON, shader, git, queue or runner edit; no Godot submission; no ladder advancement."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_RELIEF_LIVE_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION — internal consistency only. No donor GPU A/B frame exists; no donor parity is claimed anywhere in this report."
head_at_read: "2101e66ed43b2000485e2b649874c43d02edf57b (2026-11-25T12:28:33+01:00); variant3d source files clean at read"
diag_state: "RELIEF_LIVE_DIAG_01.md was absent at QA start and landed mid-QA; all rows below were graded against its final text (v1, 433 lines)."
verdict: "5_OF_7_CONFIRMED__2_PARTIAL__RANK3_CLAMP_CLAIM_REFUTED__RANK6_OVERSTATED__PROBE_EXECUTABLE_IN_PRINCIPLE_BUT_BLOCKED_ON_PLANT_SEED__UNVERIFIED"
---

# QA-RELIEF-LIVE-01 — verify the live-relief root-cause ranking

## 1. Sources and boundary

- `reports/RELIEF_LIVE_DIAG_01.md` (v1, 433 lines) landed **during** this QA: absent on the first two checks, present on the third before the final write. Its ranking (§4, `:273-281`), data-flow trace (§2), findings (§3) and probe (§5) are the subject of this report — **observed**. No earlier/draft version was available, so "the diag's claims" means the landed text.
- Live tree is `variant3d/` (diag frontmatter `:9`); `app/**` contains no `relief_stamps` producer (grep over `app/` returned no matches) — **observed**.
- All source lines below were re-read at HEAD `2101e66`; drift is measured from the diag's printed line numbers. Concurrent swarm commits moved reports only in the last commits; source files were clean at read — **observed**.
- Read-only measurements made here: parsed `donor_patterns.json` and `presets_summer.json` with Python 3.14 `json`; re-measured six block PNGs with read-only PIL; parsed the existing flag-on dump artifact under `%LOCALAPPDATA%\Temp\opencode\`. No file was written except this report — **observed**.

| Source | Use | Label |
|---|---|---|
| `reports/RELIEF_LIVE_DIAG_01.md:52-79,83-178,181-267,271-297,301-340,344-369` | Claims under test | observed (document) |
| `variant3d/scripts/game.gd:44-75,870-994,995-1134,1783-1807,1812-1907,1949-1995,2016-2083` | Live height/tile producers | observed (source) |
| `variant3d/scripts/main.gd:751-810,1338,1356,1364-1365,1932-1942` | Dump producer/gate, CLI | observed (source) |
| `variant3d/scripts/config.gd:46-89,448-449`; `variant3d/config.json:16-54` | Flag default and effective value | observed (source) |
| `variant3d/scripts/world3d.gd:224-234,599-639` | Live height feed | observed (source) |
| `variant3d/scripts/world3d_terrain.gd:185-244,465-513,522-557,916-953,1163-1199,1435-1458` | Synthesized dump, consumer, stats | observed (source) |
| `variant3d/scripts/pattern_gen.gd:40-114,474-549`; `variant3d/scripts/mapgen.gd:63-73` | Stamp footprint / analytic band relief | observed (source) |
| `variant3d/assets/terrain/patterns/donor_patterns.json`; `presets_summer.json`; `blocks/*.png` | Data contract, tile ids, art brightness | observed (read-only parse/PIL) |
| `variant3d/shaders/terrain_tileindex.gdshader:322-335,338-347,386-390,469` | Colour path / alpha seam | observed (source) |
| `reports/RELIEF_VISUAL_01.md:127-174,224-246`; `reports/RELIEF_ENABLE_01.md:118-149`; `%LOCALAPPDATA%\Temp\opencode\reliefenabl01_dump.json` | Corroborating live evidence; landed/verified after the diag was written | observed (document/artifact) |
| `reports/DPATTERN_01_relief_grids.md:142,154,237-249,595-626` | Donor truth carried by citation only | observed (document); donor engine UNVERIFIED |

---

## 2. Verification table — diag's seven ranked causes

Verdicts grade the diag row as written. "Drift" = printed line → current line at `2101e66`.

| Rank | Diag claim | Cited lines / drift | Verdict | Basis and labels |
|---:|---|---|---|---|
| **1** | Flag is wired only to `--dump-map`; live boot synthesizes a marker-free dump, so "relief on" never reaches the renderer | `main.gd:788-803` **exact**; `config.json:29` **exact**; `world3d.gd:635-639` **exact**; `world3d_terrain.gd:916-953` **exact** (keys `:945-953`), `:1193,522-524` **exact**; `config.gd:54-61` → defaults block `:46-89`, leaf still `:59` | **CONFIRMED** | Gate is the sole flag consumer (`main.gd:788-803`); live boot binds/builds from `game.height` (`world3d.gd:635-639`) and `_dump_from_game()` accepts only `dump`/`map_dump`/`self_base` before synthesizing a 3–4-key dict with **no** `relief_stamps` (`world3d_terrain.gd:916-953`); reader then returns 0 (`:524-526`). **observed + derived.** The flag-on artifact has the key and `[]`, confirming emission without live effect — **observed**. |
| **2** | No donor float32 relief grid reaches live `game.height`; footprints are donor-derived but the profile is analytic band/dome/radial approximation | `game.gd:871-875,893-993` **exact** (function ends `:994`); `pattern_gen.gd:50-57,88-107,474-549` **exact**; `mapgen.gd:63-73` **exact**; `DPATTERN_01` cites **exact** | **CONFIRMED** | `Stamp` fields are `family/name/kind/res/x/y/cells` with no grid (`pattern_gen.gd:50-57`); read-only parse: 282 patterns, `plt2` keys **only** `w/h/cells`, plateau family = five equal-weight members — **observed**. `_shape_stamp_relief()` says the donor height fields are "undecoded" (`game.gd:871-875`) and writes `clampf(h+amp*f, -2.964, 2.964)` with analytic `f` (`game.gd:964-993`) — **observed**. Donor grid floats exist in DPATTERN only (`DPATTERN_01:142,154`) and are used solely by the opt-in consumer tables (`world3d_terrain.gd:185-244`) — **derived**. |
| **3** | Later clamping flattens every land cap to ≈2.96; would also truncate `plt2`'s +3.6134 "if the dump path fired" | `game.gd:993` **exact**, `:1093-1109` **exact** (dither `:1105-1108`); `DPATTERN_01:154,237-249` **exact** | **PARTIAL** — live clamp CONFIRMED; dump-path truncation claim **REFUTED** | Stamp clamp and global land clamp/dither are real and do saturate live caps (`game.gd:993,1099-1109`) — **observed/derived**. But the consumer applies `height[idx] = clampf(height[idx]+delta, lo, hi)` on a **local decoded copy** (`world3d_terrain.gd:1178-1199`) with `plt2 hi = +3.6134116649627686` (`:232-240`); the live sim clamp cannot truncate a post-dump stamp — **derived**. The diag's §3.2/§4 wording "this clamp would truncate it further" is wrong; the correct caveat is that the consumer bypasses the sim cap. |
| **4** | `test7/8/9` tile-id art on flat cells from donor detail-bitmap bytes and smoothing; bright speckles explain marks | `game.gd:1783-1807,1894-1898,2016-2077` **exact**; `shader:322-335,386-390` **exact**; tile ids/art **verified** | **CONFIRMED mechanism; attribution INFERRED (as labelled)** | Detail pass writes `tex = R div 2` on grass1 cells with only a bitmap-select height gate (`game.gd:1797-1807`); smoothing inserts transition ids with **no height read** (`:2016-2077`); atlas supplies RGB (`shader:330-335,390`). Ids verified: grass1=0, rock4=20, rock8=24, test7=78, test8=79, test9=80. My read-only PIL re-measurement reproduced the diag's table **exactly**: bright-pixel counts `test7=109`, `test8=245`, `test9=0`, `rock4=68`, `rock8=21`, `grass1=0`, with matching max RGB — **observed**. `RELIEF_VISUAL_01.md:134-174` (landed after the diag) reports 4.8156% near-white stepped/grid-aligned bands in a real 64² frame with no relief — this **upgrades** the diag's "UNVERIFIED attribution" to **inferred** corroboration, not proof; no donor A/B. |
| **5** | Analytic domes are tiny at map scale (<1 m ≈0.2%); do not "fix" by raising amplitude | `game.gd:1042-1055` **exact**; `mapgen.gd:63-73` **exact** | **CONFIRMED source; effect INFERRED** | Domes are `(1-dd)² × (2.964/2.25) × relief_scale` over radius 7–13 tiles (`game.gd:1042-1055`), i.e. ≤1.317 m before `relief_scale`; ≈0.206% of a 640 m span — **derived**. No synthetic-amplitude claim is made here either. |
| **6** | `rock8`/`rock4` refuted as flat-land mark cause — both require real height (`>2.7`/`>2.4`) and a steep cell | `game.gd:1975-1982,1992-1995,1868-1880,1110-1134` **exact** | **PARTIAL** — CONFIRMED for the cliff path, OVERSTATED globally | `_cliff_tile_for()` is height-gated and returns "" below `abs(h)<0.1` (`game.gd:1975-1982`), and is called only on `terrain==5` cells (`:1992-1995`) created by the `|dh|>0.5/0.55` collision pass (`:1110-1134`) — **observed**. However `rock4`/`rock8` also occur in donor smoothing chains (`game.gd:1433,1464`), and `_tb_smooth_pair()` picks ids with **no height read** (`:2016-2077`); so the diag's "cannot appear at `abs(h)<0.1`" is not guaranteed for `tileblock`. The probe's decision table ("rock id ⇒ cell is high/steep", diag `:332-333`) must therefore classify by **measured local height**, not id alone — **derived**. |
| **7** | Alpha-patch / sky-blend seam UNVERIFIED (low); refuted for tile id 0 in P0 | `shader:338-347,469` **exact** | **CONFIRMED as UNVERIFIED** | Patch decoder and constant-patch behaviour are present (`terrain_tileindex.gdshader:338-375,469`) but the tile→patch rule is labelled `CONFIRMED_UNVERIFIED` at `:361`; no isolating A/B exists. No parity claim. |

### 2.1 Ranking-order check

- The diag's central reordering versus `TERRAIN_MARKS_01.md` — rank 1 becomes *dump-only flag wiring*, rank 2 becomes *no donor grid in live height*, and tile art drops to rank 4 — is **supported by current source** — **observed/derived**.
- The split conclusion ("missing donor hills" ≠ "pale marks") survives — **derived**; corroborated by the landed live capture.
- Two corrections are required: rank 3's clamp claim about the dump path (REFUTED) and rank 6's absolute exclusion of rock ids from flat cells (OVERSTATED) — **derived**.
- Stale cross-reference: diag `:46-48` says `RELIEF-VISUAL-01` is still RUNNING and no frame was available; it has since landed with a report frame. This does not change ranks 1–3/5–7 and strengthens rank 4 — **observed**.

---

## 3. Is the diag's discriminating probe executable and actually discriminating?

Spec: `RELIEF_LIVE_DIAG_01.md:301-340`.

### 3.1 Executability with existing hooks

| Step | Hook | Current source | Executable? |
|---|---|---|---|
| 1 — sweep seeds for a `plt2` marker via `--config` override | `--config` `main.gd:1338`; `--seed` `main.gd:1356`; dump `:1364-1365` → `_dump_map()` `:751-810`; cfg loaded `:179-181`, `:221-223` | **Yes in principle** — both CLI hooks exist and a 64² flag-on dump succeeded (reported `RELIEF_ENABLE_01.md:118`, ticket 527). At 320² the earlier dump timed out at 180 s (ticket 521), so the sweep must stay at 64² through the runner. **derived**. |
| 2 — decode `height`/`tileblock` in Python | `main.gd:795-796` base64 fields; dump keys verified in the existing artifact | **Yes**, read-only; no engine hook needed — **observed**. |
| 3 — four metrics, global + `plt2` window | window `s = MAP_W/160` (`pattern_gen.gd:71`), cells scaled `:88-107`, centre `cx/cy` at `:523-533`, `plt2` 42×55 verified in JSON → ≈17×22 at 64² | **Yes**, arithmetic verified: 42×0.4≈17, 55×0.4≈22 — **derived**. Caveat: the footprint may be clipped near map edges (`:499-505` rejects out-of-range cells), so window counts need an overlap check. |
| 4 — decision table (`|dh|<0.5` tile art vs cap ≈2.96 analytic vs ≈3.2–3.5 donor) | dump `height` is `game.height` pre-consumer (`main.gd:755,795`); live consumer never sees marker (§2 rank 1) | **Partially**: separates live analytic height from a hypothetical donor-grid cap, and flat-cell tile art from cliff art, but see §3.2 — **derived**. |
| 5 — guard | donor blend UNVERIFIED (`DPATTERN_01:348-382`) | **Yes**; preserved — **observed**. |

### 3.2 Would it distinguish donor-grid relief from synthetic/tile-colour marks?

- **It would distinguish the two height regimes in a dump** if a marked seed existed: the live analytic profile caps at ≈2.964/2.934 (`game.gd:993,1109`) with radial falloff, whereas a donor `plt2` cap is ≈3.2–3.5 (`DPATTERN_01:237-249,615-626`). That is a real, source-grounded discriminator — **derived**.
- **It would tile-attribute marks**: `test7/8` with local `|dh|<0.5` supports tile art (`game.gd:1797-1807`), and white art speckles were independently reproduced here — **observed/derived**.
- **Blocked at step 1 today.** The only observed flag-on dump (artifact re-parsed here) has `relief_stamps: []`, seed 20261113, 64², and `meta.stamp_counts.plateau = 2` (the two plateaus were not `plt2`, one of five equal-weight family members). No seed with a `plt2` marker has been produced — **observed**. Until the sweep finds one, the probe returns a null result and cannot discriminate.
- **It cannot observe the consumer path.** `stats.relief_grid.applied` (`world3d_terrain.gd:1445-1455`) is produced only by `build()` (`:1163-1199`) and is absent from `--dump-map`; no sanctioned test feeds a real marked dump into it (all `variant3d/tests/*.gd` `.dump =` assignments are synthetic 4-key dicts). The probe correctly makes no claim about a live donor stamp, but "donor grid applied" remains **UNVERIFIED** for any path — **derived/observed**.
- **Rock-id inference needs tightening** (rank 6 above): classify by measured `|h|`/`|dh|`, not merely by id 20/24 — **derived**.

---

## 4. Verdict

- **Five of seven diag rows are CONFIRMED as written** (ranks 1, 2, 4 [mechanism], 5, 7) — **observed/derived**.
- **Two rows are PARTIAL**: rank 3's live clamp is real but its "dump-path `plt2` would be truncated" claim is **REFUTED**; rank 6's height gate is real for cliff tiles but its global "cannot appear on flat cells" claim is **OVERSTATED** given smoothing — **derived**.
- The diag's core correction — the relief flag is dump-only and live `game.height` contains no donor grid — is **CONFIRMED**. Its owner-file recommendation (`game.gd:_shape_stamp_relief()` + later clamp) is consistent with that trace — **derived**.
- The proposed probe is **executable in principle** with existing `--config`/`--seed`/`--dump-map` hooks and offline decoding, and its height/tile logic would discriminate, **but** it is currently blocked by the absence of any seed that emits a `plt2` marker, and it deliberately does not measure `stats.relief_grid.applied` — **derived**.
- Latest live evidence (`RELIEF_VISUAL_01.md`) corroborates rank 4 at the **inferred** level; no donor A/B exists and **no donor parity claim** is made.

---

## 5. Open questions (UNVERIFIED — do not guess)

1. Which seed/preset actually emits a `plt2` marker? Seed 20261113 yields `[]` despite `plateau: 2`; no runtime dump with `plt2` exists here.
2. If such a dump is found, does feeding it to `world3d_terrain.build()` yield `relief_grid.applied > 0` and a shift past the live ±2.964 cap (given the consumer's own `hi=+3.6134`)?
3. Can donor smoothing actually place ids 20/24 on flat cells for a real seed? Resolve by dump histogram plus local-height classification.
4. Do the owner's marks coincide with `test7/8` cells and `|dh|<0.5`? The in-engine tileblock histogram has never been dumped (TRN_DATA used an offline replay).
5. Would a donor-grid stamp read as a hill at the fixed camera, or as another flat pale patch (coarse 8×10 means are debug aids only)?
6. Donor engine blend (`Replace`/`Smooth`, clamp/scale order, row flip) is engine-side and UNVERIFIED (`DPATTERN_01:348-382`).
7. Donor parity of hue, grain, relief silhouette and luma is blocked on a donor GPU A/B; none exists.

---

## 6. Summary

QA of the landed `RELIEF_LIVE_DIAG_01.md`. Its seven-row ranking holds up well against current source: the dump-only flag wiring (rank 1), absence of donor float32 grids from live height (rank 2), tile-id art as the best mark explanation (rank 4), tiny analytic domes (rank 5) and the unverified alpha seam (rank 7) are **CONFIRMED**; all cited source lines match except minor drift in `config.gd`'s defaults block and the `world3d_terrain.gd` stats block. Two claims need correction: the live ±2.964 cap cannot truncate a `plt2` stamp applied later by the dump consumer (rank 3 **REFUTED** on that point), and `rock4`/`rock8` are not strictly excluded from flat cells because smoothing chains can insert them without a height read (rank 6 **OVERSTATED**). My independent read-only re-measurement of the six tile-art PNGs reproduced the diag's brightness figures exactly, and the landed live capture corroborates the tile-art attribution at the **inferred** level. The proposed seed-sweep probe is executable with existing `--config`/`--seed`/`--dump-map` and offline decoding and would separate analytic caps from donor caps, but it is blocked until a seed emitting `plt2` is found and it does not measure `stats.relief_grid.applied`. **No donor parity claim. No file other than this report was edited; no runner job was submitted.**

*End of QA-RELIEF-LIVE-01. Read-only; no code/asset/config/test/shader/git edit, no Godot job, no donor access, no ladder advancement.*
