---
id: QA-TERRAIN-DEEP-01
title: "Read-only QA — cross-check of the four donor terrain deep dives against each other and current source"
agent: "QA-TERRAIN-DEEP-01 (read-only QA subagent, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source, asset, config, test, shader, PNG, JSON, stderr, donor or git edit; no Godot job; no queue mutation; no ladder advancement."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_TERRAIN_DEEP_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame was read or produced by this QA. No donor parity claim is made."
primary_verdict: "INCOMPLETE_INPUT — none of the four Batch-Z deep dives has landed; cross-check between them is impossible at this snapshot. The four landed supporting reports were cross-checked against current source instead; their consensus and conflicts are recorded below."
db_snapshot_utc: "2026-11-25T11:46:13.809Z (session_v2.time_updated max for the four target sessions)"
---

# QA TERRAIN DEEP 01 — cross-check of the four donor terrain deep dives

> [!IMPORTANT]
> Labels used throughout: **observed** (literal source line, file presence/absence,
> DB row, or decoded field read by this QA or by a cited landed report), **derived**
> (arithmetic / control-flow consequence of observed lines), **inferred** (attribution
> without a pixel-aligned donor A/B), **UNVERIFIED** (not provable from the material
> available). **No donor parity claim.** This QA edited no file but this report.

---

## 0. Mandate and decisive input fact

The mandate is to cross-check `HEIGHT_GEN_DEEP_01`, `PATTERN_STAMP_DEEP_01`,
`RCODE_DEEP_01`, `PALE_TILES_DEEP_01` ("that have landed") against each other and
against current source, then cross-check `RELIEF_LIVE_DIAG_01.md`, `DPATTERN_01`,
`TERRAIN_MARKS_01`, `QA_WHITE_MARKS_01`.

**Observed (this QA, 2026-11-25 11:47 local / 11:46 UTC):** none of the four deep
dives exists on disk. A directory listing and `glob` of
`docs/coord_swarm_2026-11-25/reports/` and of the whole `docs/` tree returned no
`*DEEP*` file for Batch Z, no `HEIGHT_GEN*`, `RCODE*` or `PALE*` report, and no
`QA_TERRAIN_DEEP_01.md`. A read-only SQLite query on
`~/.local/share/opencode/opencode.db` shows all four owning sessions still
**BUSY** (`time_idle IS NULL`, `idle_outcome IS NULL`) at DB snapshot
`2026-11-25T11:46:13.809Z`; only the four support reports are available for a
substantive cross-check. This is a **input-availability finding, not a verdict on
the deep dives' future content**.

Consequently §2 gives every deep-dive column as **NOT LANDED** (with the scope it
was assigned, from `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:415-418`) and fills
the report columns from the four landed support reports plus current source. Any
later landing of the deep dives requires a fresh QA pass; nothing here should be
read as agreeing or disagreeing with reports that do not yet exist.

---

## 1. Sources

### 1.1 Target deep dives — NOT LANDED (observed)

| ID | Expected file | Session id | DB state at snapshot | Scope assigned (`SWARM_BOARD.md`) |
|---|---|---|---|---|
| HEIGHT-GEN-DEEP-01 | `reports/HEIGHT_GEN_DEEP_01.md` | `ses_ded837aabffejfLh3ybomrgH2n` | BUSY (`time_idle=NULL`) | donor height generation + R-code deep dive (`:415`) |
| PATTERN-STAMP-DEEP-01 | `reports/PATTERN_STAMP_DEEP_01.md` | `ses_ded837aabffddkfZI25InbqAeY` | BUSY | donor relief pattern grid stamping (`:416`) |
| RCODE-DEEP-01 | `reports/RCODE_DEEP_01.md` | `ses_ded837a9bffeYmWl0s7Ixk0Ee1` | BUSY | donor R-code decode vs port `relief()` (`:417`) |
| PALE-TILES-DEEP-01 | `reports/PALE_TILES_DEEP_01.md` | `ses_ded837a94ffeSMzceWm3VhZt7O` | BUSY | donor pale tile art / white marks (`:418`) |

All paths are relative to `docs/coord_swarm_2026-11-25/`. File-not-found is
**observed**; the session states are **observed** from the DB; the scopes are
**observed** from the board row. Their answers to any of §2's questions are
**UNVERIFIED** by definition.

### 1.2 Landed support reports read in full (observed)

| Short name | Path | Own verdict / scope relevant here |
|---|---|---|
| RELIEF-LIVE-DIAG-01 | `docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_DIAG_01.md` | live path: flag is dump-only; no donor grid in live height; tile-art marks ranked 4 (`:12`, `:271-297`, `:398-429`) |
| DPATTERN-01 | `docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md` | 26 float32 grids decoded bit-exact to `pattern.lib`; engine blend UNVERIFIED (`:11`, `:289-298`, `:366-382`) |
| TERRAIN-MARKS-01 | `docs/coord_swarm_2026-11-25/reports/TERRAIN_MARKS_01.md` | P0 control has no white marks; dump flag off at capture time; tile-id rank 2 (`:12`, `:90-124`, `:227-251`) |
| QA-WHITE-MARKS-01 | `docs/coord_swarm_2026-11-25/reports/QA_WHITE_MARKS_01.md` | independent pixel reproduction + source confirmation; marks seen, attribution INFERRED (`:13`, `:61-91`, `:143-180`) |

Also consulted for context (not treated as new evidence by this QA):
`RELIEF_VISUAL_01.md` (reproduced frame), `DTRN_02_donor_terrain_geometry.md`
(donor R-code/geometry), `RV_TRN_02_smoothing_rules.md`,
`DALPHA_01_alpha_subrect.md` (alpha patch grid), `DALPHA_02_patch_mapping.md`,
`DEC_05_terrain_formats.md`, `RELIEF_01_stamping.md`, `RELIEF_02_stamp_marker.md`,
`QA_RELIEF_DUMP_01.md`, `QA_RELIEF_ON_01.md`, `TRN_DATA_implementation.md`,
and `SWARM_BOARD.md:411-421`.

### 1.3 Current source verified read-only by this QA (observed)

| File | Authoritative `path:line` read now |
|---|---|
| `variant3d/scripts/game.gd` | `:76` `RELIEF_PLATEAU := 2.964`; `:78` `RELIEF_RAVINE := -2.964`; `:901` `_generate_map()`; `:913` `_shape_stamp_relief()` definition; `:947/:951/:955` kind→amplitude; `:1033` in-stamp clamp; `:1135` call to `_shape_stamp_relief()`; `:1139` parabolic dome; `:1151-1152` global clamp/hcap; `:1852-1884` `_apply_detail_pass()` (bitmap by `h<0.1`, `tex = R div 2` at `:1869`); `:1937` detail-pass call; `:2018` `_cliff_tile_for()`; `:2085` `_tb_smooth_pair()` |
| `variant3d/scripts/main.gd` | `:751` `_dump_map()`; `:767-783` producer; `:788-790` flag read; `:791-798` dump dict; `:802-803` marker emit |
| `variant3d/scripts/config.gd` | `:59` default `relief_stamps: false`; `:448-449` getter |
| `variant3d/config.json` | `:29` `features.terrain.relief_stamps = true` (current file state) |
| `variant3d/scripts/mapgen.gd` | `:3` mask R-channel comment (255 plateau / 96 hill / 48 ravine); `:26-28` constants; `:63-73` `relief()` bands (`>=250`, `|v-96|<=12`, `|v-48|<=12`) |
| `variant3d/scripts/world3d_terrain.gd` | `:522-524` marker reader (`dump.get("relief_stamps", null)`); `:1193` consumer call; `:1443-1453` `stats["relief_grid"]` |
| `variant3d/scripts/world3d.gd` | `:224-234` live height source; `:635-639` `terrain.bind(game)` / `build()` |
| `variant3d/shaders/terrain_tileindex.gdshader` | cited by support reports at `:322-335` (`tile_rgb`), `:338-347` / `:469` (alpha), `:386-390` (fragment RGB) — not re-read byte-for-byte by this QA; cited via reports |

**Derived (this QA):** the good reports' *conclusions* survive a current-source
check, but most of their `game.gd` line anchors do not — the file has shifted
since they were written (likely `RELIEF-LIVE-FIX-01`, board row `:419`). This QA
uses the current `path:line` values above as authoritative and flags the drift in
§3.

---

## 2. Consensus table

Legend: **NL** = NOT LANDED (no answer available); **n/a** = report does not
address that question. "Each report's answer" cells report *that report's* claim,
not this QA's endorsement; labels are carried where the source report used them.

| Question | HEIGHT_GEN_DEEP_01 | PATTERN_STAMP_DEEP_01 | RCODE_DEEP_01 | PALE_TILES_DEEP_01 | RELIEF_LIVE_DIAG_01 | DPATTERN_01 | TERRAIN_MARKS_01 | QA_WHITE_MARKS_01 | Agreement / conflict | Authoritative evidence `path:line` |
|---|---|---|---|---|---|---|---|---|---|---|
| **Q1. How does the donor sculpt hills?** | NL | NL | NL | NL | Embedded row-major `w×h` float32 height windows; engine blend UNVERIFIED; mountains are 3D `terrainmesh*` props, not bumps (`:160-165`, `:195-199`) | **observed:** 26 grids, min/max bit-exact to `pattern.lib`; hills = narrow crests on flat-zero surround; `HeightFieldScale` is part of shape; mountains have **zero** grid and embed props (`:101-124`, `:251-285`, `:289-298`) | Donor relief is authored height geometry + optional props; "32–64% exactly 0.0" describes base flat land, not stamps (`:102`) | n/a | **Agreement** among all landed reports that answer. No report-vs-report conflict. Engine blend explicitly UNVERIFIED by both DPATTERN and RELIEF-LIVE-DIAG. | `DPATTERN_01:103-107,251-285,289-298`; `DTRN_02:102,104`; donor anchors `pattern.lib:549585-549586,6805-6806` (as cited by those reports) |
| **Q2. Does the live port use donor grids?** | NL | NL | NL | NL | **No.** Live height = `mapgen` bands + analytic domes + analytic `_shape_stamp_relief()`; live boot synthesizes a marker-free dump; RELIEF-01/02 path is dump-only (`:121-159`, `:183-199`) | Port gap: no grids in `variant3d`; `game.gd` still calls fields "undecoded"; safe fix = derived numeric table (`:585-588`) | The *donor-grid* path is off in the captured config; the port's separate analytic relief still runs (`:99`, `:112-119`) | **CONFIRMED** source claim: accessor read only in `_dump_map()`; live boot calls `_shape_stamp_relief()` unconditionally and builds from `game.height` (`:143-172`) | **Agreement**, no conflict. Do **not** conflate "analytic relief exists" with "donor grid used" — both are true statements about different paths. | current source: `game.gd:913-1033,1135,1151-1152`; `main.gd:788-803`; `world3d_terrain.gd:522-524,1193`; `world3d.gd:224-234,635-639`; `config.json:29` |
| **Q3. Source of the pale white bands** | NL | NL | NL | NL | **Tile-id art (inferred attribution):** donor `tile_low/highground` bytes and 3-pass smoothing put `test7/8/9` on flat cells; atlas supplies bright speckles; `rock8/4` require real height and are refuted for flat cells (`:212-236`, `:238-255`, `:271-280`) | n/a | Tile-id colour = rank 2, best explanation **if** the frame is a real generated map; **refuted for the supplied P0 PNG**, which contains no white marks at all (`:45-49`, `:100`, `:120-124`) | White marks **independently observed** in the reproduced raw frame; visual match to tile-id explanation but attribution **INFERRED / UNVERIFIED** — no histogram, no flag-off A/B (`:80-86`, `:174-180`) | **Agreement on mechanism as the leading hypothesis; attribution INFERRED, not confirmed.** Scope difference (P0 control vs real 64² frame) is not a contradiction — see conflict C5. | `game.gd:1852-1884,1937,2018,2085`; `terrain_tileindex.gdshader:322-335,386-390` (via reports); `QA_WHITE_MARKS_01:61-78,80-86`; `TERRAIN_MARKS_01:45-49,100` |
| **Q4. R-code semantics** | NL | NL | NL | NL | Port `relief()` uses bands `v>=250→+2.964`, `|v−96|<=12→+1.317`, `|v−48|<=12→−2.964`, else scaled half-amplitude; donor is the exact class×R formula (`:126-131`) | n/a (documents donor *placement* probabilities, not R-channel decode; `:304-346`) | n/a | n/a | **No landed report disagrees.** This is a **donor-vs-port divergence**, not a report conflict: port bands are an explicit APPROX and are wrong for smooth R codes. RCODE-DEEP-01 was tasked with exactly this and has **not landed** → final semantics UNVERIFIED. | `mapgen.gd:3,26-28,63-73`; `DTRN_02:98,100,135-137,319-320` (donor R `255/96/48`, smooth `191/112/88`, `cRColorSmooth=64`) |
| **Q5. Do alpha masks contribute?** | NL | NL | NL | NL | Rank 7, **UNVERIFIED (low)**; refuted for tile id 0 in P0 (`:281`) | n/a | Rank 5, **refuted for P0; UNVERIFIED generally** (`:103`) | Not tested; attribution left INFERRED, no parity claim (`:174-180`) | **Agreement: no evidence alpha masks cause the bands.** The 8×4×64 patch grid is donor-grounded but the tile→patch rule is CONFIRMED_UNVERIFIED, so a real-frame seam cannot be excluded or promoted. | `DALPHA_01:541-545`; `TERRAIN_MARKS_01:103`; `RELIEF_LIVE_DIAG_01:281`; shader alpha cites at `terrain_tileindex.gdshader:338-347,469` (via reports) |

### 2.1 What this table does and does not establish

- **Established (observed/derived):** donor sculpt = float32 grids + props; live port
  = analytic approximation, no grids; the reproduced pale bands exist as pixels;
  the flag is a dump-only marker; port R-code decode diverges from donor C2/C4.
- **Inferred only:** the pale bands are `test7/8` tile art. No landed report ran a
  dump histogram or a flag-off A/B on the reproduced frame; this QA ran neither.
- **UNVERIFIED:** all four deep dives' contents; donor engine blend; exact
  tile→alpha patch rule; whether the reproduced frame's marks are tile art vs an
  alpha seam; donor parity.

---

## 3. Conflicts and citation recommendations

No code was edited. The following are **report-vs-current-source** or
**report-vs-report scope** conflicts; each entry states the exact `path:line`
pair and which report to cite.

### C1 — Relief-flag state: stale snapshot vs current file (observed)
- `TERRAIN_MARKS_01.md:99,135,195,235` says `features.terrain.relief_stamps`
  defaults false, the accessor returns false, and there is no `features` block in
  `config.json` — i.e. "flag off" is its **rank-1** cause.
- `RELIEF_LIVE_DIAG_01.md:61,87-90,259` says `config.json:29 = true`, and the
  flag-on dump artifact carries the key.
- Current source confirms **both** are right *at different times*:
  `config.gd:59` still defaults `false`, but `config.json:29` is now `true`.
- **Cite:** `RELIEF_LIVE_DIAG_01.md` for the **current live** state; cite
  `TERRAIN_MARKS_01.md` only for the **historical P0/dump capture** it analysed.
  Do not repeat "flag off" as the live root cause.

### C2 — Owner file for a fix (conflict, resolved)
- `TERRAIN_MARKS_01.md:193-200`: primary owner `variant3d/scripts/config.gd`.
- `RELIEF_LIVE_DIAG_01.md:344-369`: primary owner `variant3d/scripts/game.gd`
  (`_shape_stamp_relief()` + clamp); explicitly "not the owner for a live fix:
  `main.gd`/`config.gd`/`world3d_terrain.gd`".
- **Cite:** `RELIEF_LIVE_DIAG_01.md` for any **live** fix; `TERRAIN_MARKS_01.md`'s
  recommendation is superseded because the flag is now true (C1) and gates only
  the dump key.

### C3 — `game.gd` line anchors are stale in both reports (observed)
- `TERRAIN_MARKS_01.md` cites `game.gd:858-981`, `:1080`, `:1087-1097`,
  `:1771-1795`, `:1420-1494`, `:1937-1970`.
- `RELIEF_LIVE_DIAG_01.md` cites `game.gd:870-993`, `:1092`, `:1093-1109`,
  `:1042-1055`, `:1783-1807`, `:861-868`.
- Current source (this QA): `_shape_stamp_relief()` at `:913-1033`, its call at
  `:1135`, global clamp at `:1151-1152`, `_apply_detail_pass()` at `:1852-1884`,
  `_cliff_tile_for()` at `:2018`, `_tb_smooth_pair()` at `:2085` — the reports'
  anchors are ~40–55 lines behind.
- **Cite:** current `game.gd` path:line values from §1.3 for any new work; treat the
  reports' `game.gd` numbers as historical pointers, and re-read before acting.

### C4 — `main.gd` line anchors: one report current, one stale (observed)
- `TERRAIN_MARKS_01.md:99` cites `main.gd:741-761` / `:762-777` for the producer /
  key emit; current `:741-750` is `_setup_cli_only()`.
- `RELIEF_LIVE_DIAG_01.md:91-93` cites `main.gd:767-783` / `:788-803`, and
  `QA_WHITE_MARKS_01.md:44-46,148-151` cites `:751`, `:788-790`, `:802-803` —
  these match current source.
- **Cite:** `RELIEF_LIVE_DIAG_01.md` / `QA_WHITE_MARKS_01.md` for the dump-path
  line anchors.

### C5 — "No white marks" vs "white marks present": scope, not contradiction
- `TERRAIN_MARKS_01.md:45-49,131-133` — supplied `p0_final_formula.png` is a flat
  64² P0 control with **zero** pixels above luma 160.
- `RELIEF_VISUAL_01.md:141-146` / `QA_WHITE_MARKS_01.md:80-86,219-233` — the real
  generated 64² raw frame has 44,381 near-white pixels (4.8156 %), stepped bands,
  no hills.
- **Cite:** both, with their artifact named. `TERRAIN_MARKS_01` refutes the marks
  **in the P0 artifact only**; it does not refute the reproduced real-map frames.

### C6 — R-code: donor truth vs port approximation (not a report conflict)
- `DTRN_02:98,100,135-137` gives donor R `255/96/48`, smooth `191/112/88`,
  `cRColorSmooth=64`, class×R amplitude; `DTRN_02:319-320` explicitly says the
  port's `relief()` is **wrong for smooth R codes**.
- `mapgen.gd:63-73` (current) still uses the ±12 bands.
- **Cite:** `DTRN_02` for donor semantics, `mapgen.gd:63-73` for what the port
  actually does. The dedicated `RCODE_DEEP_01` has **not landed**, so a deeper
  resolution is UNVERIFIED.

### C7 — Alpha masks: consistent UNVERIFIED, often over-claimed in passing
- `TERRAIN_MARKS_01.md:103`, `RELIEF_LIVE_DIAG_01.md:281` both refuse to promote
  the alpha-seam hypothesis; `DALPHA_01:545` marks the tile→patch rule
  CONFIRMED_UNVERIFIED.
- **Cite:** `DALPHA_01:541-545` for what is donor-grounded vs engine-side. Any
  claim that alpha seams *are* the white bands is **UNVERIFIED** and must be
  labelled as such.

### C8 — Donor engine blend: consistent UNVERIFIED (no conflict)
- `DPATTERN_01:366-382` (no plaintext consumer; additive-clamp APPROX) and
  `RELIEF_LIVE_DIAG_01:387-388,337-339` agree. No report claims the blend is
  solved. **Cite:** `DPATTERN_01:373-382` as the labelled port approximation.

---

## 4. Verdict

**Primary (observed).** The requested four-way cross-check **cannot be performed**
at this snapshot: `HEIGHT_GEN_DEEP_01.md`, `PATTERN_STAMP_DEEP_01.md`,
`RCODE_DEEP_01.md`, `PALE_TILES_DEEP_01.md` do not exist on disk and their four
sessions are still BUSY (`SWARM_BOARD.md:415-418`; DB snapshot
`2026-11-25T11:46:13.809Z`). Their answers to Q1–Q5 are UNVERIFIED. This is a
completion gate, not a criticism of their eventual content.

**Secondary (observed/derived).** Among the four landed support reports:
1. **Consensus, no conflict:** donor hills come from embedded float32 height
   grids plus real 3D props; the engine blend is UNVERIFIED (Q1). The live port
   uses no donor grids — its relief is analytic over donor footprints, and the
   `relief_stamps` flag is a dump-only marker (Q2). Alpha masks are not shown to
   cause the pale bands (Q5).
2. **Leading hypothesis, inferred:** the reproduced pale stepped bands are
   `test7/8` tile art placed on flat cells by donor detail-bitmap bytes and
   smoothing; `rock8/4` are height-gated and cannot explain flat-cell marks (Q3).
   Attribution to the owner's exact frame remains INFERRED/UNVERIFIED.
3. **Divergence, not conflict:** donor exact R-code semantics vs port ±12 bands
   (Q4) — `DTRN_02:319-320` already flags the port approximation as wrong for
   smooth codes; the dedicated deep dive has not landed.
4. **Most dangerous stale claim:** "the relief flag is off" as a **live** root
   cause. It is true for the historical P0/dump capture but false for current
   source (`config.json:29 = true`), and even when true it only changes a dump
   key. Treat `RELIEF_LIVE_DIAG_01.md` as the live-path authority and
   `TERRAIN_MARKS_01.md` as the historical capture authority.

**Citation guide (which report to cite):** Q1 → `DPATTERN_01`; Q2 →
`RELIEF_LIVE_DIAG_01.md` (confirmed independently by `QA_WHITE_MARKS_01.md:143-172`);
Q3 → `RELIEF_LIVE_DIAG_01.md` for mechanism + `QA_WHITE_MARKS_01.md` for the
reproduced pixels, always labelled inferred; Q4 → `DTRN_02` for donor, current
`mapgen.gd:63-73` for port; Q5 → `DALPHA_01:541-545`.

**No parity claim.** No donor GPU A/B frame was read or produced by this QA; all
visual statements are PORT APPROXIMATION.

---

## 5. Open questions (UNVERIFIED — do not guess)

1. What do the four Batch-Z deep dives actually conclude? None has landed; every
   column of §2 for them is empty by necessity. Re-run this cross-check once they
   land (poll the files, then the DB `time_idle` values).
2. Donor engine blend (`Replace` / `ReplaceForWater` / `Smooth`, clamp/scale order,
   row flip) — engine-side, UNVERIFIED (`DPATTERN_01:348-382`, `RELIEF_LIVE_DIAG_01:387-388`).
3. Exact tile → alpha-patch rule — CONFIRMED_UNVERIFIED (`DALPHA_01:545`);
   an alpha-seam contribution to the real-frame bands can be neither excluded nor
   promoted.
4. Which seed/preset places a real `plt2` marker? Seed 20261113 yields
   `relief_stamps: []` (`QA_RELIEF_DUMP_01`, `RELIEF_LIVE_DIAG_01:257-267`);
   no in-engine histogram exists for a marked seed.
5. Do the reproduced pale bands coincide with `test7/8` cells at `|dh| < 0.5` in
   that exact frame? No dump tileblock histogram or flag-off A/B was run by any
   landed report; attribution stays inferred.
6. Did `RELIEF-LIVE-FIX-01` (board `:419`) change `game.gd` after the two diagnosis
   reports were written? Current line drift (C3) suggests yes; the functional
   conclusions were re-checked here against current source, but the reports'
   numeric line anchors were not retroactively validated.
7. Donor R-code smooth classes (`191/112/88`) — the dedicated `RCODE_DEEP_01` has
   not landed; `DTRN_02:319-320` remains the authority for the port divergence.
8. Donor parity of hue, grain, relief silhouette and luma — no donor GPU A/B exists.

---

## 6. Summary

Read-only QA for Batch Z. **The four donor terrain deep dives have not landed**
(file-not-found; all four sessions still BUSY at `2026-11-25T11:46:13.809Z`), so
the requested four-way cross-check is **INCOMPLETE_INPUT** and their answers to
the five consensus questions are UNVERIFIED. No code, config, asset or queue was
touched; no runner job was submitted.

The four landed support reports were cross-checked against each other and against
current source. They agree that the donor sculpts hills with embedded `w×h`
float32 grids plus `terrainmesh*` props (engine blend UNVERIFIED), that the live
port uses **no** donor grids (analytic `_shape_stamp_relief()` at
`game.gd:913-1033` and a dump-only flag at `main.gd:788-803`), and that alpha
masks are not demonstrated as the source of the pale bands. The pale bands are
best explained as tile-id art — an **inference**, not a confirmed mechanism. Port
R-code decode (`mapgen.gd:63-73`) diverges from donor C2/C4 semantics
(`DTRN_02:98,319-320`); `RCODE_DEEP_01` has not landed.

Eight conflicts/staleness findings were logged (§3): the most important are that
"flag off" is a **historical dump-path** claim, not the current live cause
(`config.json:29 = true`), that the fix owner for the live path is `game.gd`, not
`config.gd`, and that both diagnosis reports' `game.gd` line anchors are behind
current source. No donor parity claim is made.

---

*End of QA TERRAIN DEEP 01. Read-only QA; one new report file; no source, asset, config, test, shader, PNG, JSON, stderr, donor, git or queue change; no Godot job; no donor parity claim.*
