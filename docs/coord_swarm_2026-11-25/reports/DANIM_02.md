---
id: DANIM-02
title: "DANIM-02 — independent verification of the DANIM-01 AAF catalog and frame-0 bind-pose reversal"
date: 2026-11-25
owner: DANIM-02 (independent donor verification worker)
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Exactly one report written. No repo code/config/asset/test/scene/git edit; no Godot/Blender run; no donor binary executed, unpacked or copied into the repo. Analysis scripts lived only in C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/struct/latin-1; never executed or copied)"
output: "docs/coord_swarm_2026-11-25/reports/DANIM_02.md"
labels: [observed, derived, inferred, UNVERIFIED]
method: "Fresh independent Python 3.14 parse; no DANIM-01 code reused. AAF: CRLF byte split + own regex. OSS: struct.unpack_from with independently computed bone-track base offset (seek census), not the sequential reader."
authority: "CORRECTIONS.md rows 14/51 are the same duplicate chain; row 51 is authoritative, row 14 is the original claim trail (QA-DOCS-01 C9 / CORRECTIONS.md:111-115)."
verdicts:
  aaf_catalog: "CONFIRMED — 246 files, 1,434 active rows, 62 names, all 'morph', duration (last-first+1)/30, 6 commented //attack2 rows"
  frame0_bind: "CONFIRMED — 335/335 exact closure and identity; 31-file sample (all 22 b=20) reproduces DEEPDEC-06 F4/F5; DEC-04's exact numbers reproduced as a frame-major misread"
  clip_table: "CORRECT — 43/43 §5 data rows match donor AAF bytes; 13 units verified through unit.script/dmscript.global/.prop/acl.lib/ACL inheritance chain"
  parity: "NO PARITY CLAIM — skin form, quaternion convention and rendered A/B remain UNVERIFIED (CORRECTIONS.md:98,132)"
---

# DANIM-02 — independent verification of DANIM-01

## 0. Goal and scope

Verify DANIM-01's three load-bearing results without reusing its code or accepting
its numbers: (1) the AAF catalog census and duration formula; (2) the frame-0 bind
-pose reversal of DEC-04 §6.1; (3) the §5 clip table against donor
`unit.script`/`acl.lib`. Every claim below is **observed** (fresh bytes/text read),
**derived** (computed from those bytes), or **UNVERIFIED**. **No donor-parity,
rendered-skin or engine-behaviour claim is made.**

---

## 1. Sources read (all read-only)

| id | Source | Use |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md` | claims under test (§3.1–3.3, §5, §6.2) |
| S2 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` | §4.1 `.oss` layout, §4.3 AAF, §6.1 numbers to reproduce |
| S3 | `docs/coord_swarm_2026-11-25/CORRECTIONS.md:60,98,111-115` | rows 14/51 duplicate-chain notice; authoritative state |
| S4 | `variant3d/tools/bake_sprites.py:91-103,118-143` | row-vector `qmat` / form (1) skin equation, for comparison only |
| S5 | fresh donor reads: `data/**/*.aaf` (246), `data/actors/**/*.oss` (335) | independent census and bind-pose check |
| S6 | `data/scripts/dmscript.global:868-926`, `data/scripts/lib/unit.script:369-373,2622-2625,6991-7009,10774-10777,10806-10809,10844-10893,10925-10956,11046-11093`, `data/scripts/lib/movie.script:854-859` | action-name constants, state→name map, duration/fallback/attach/one-shot |
| S7 | `data/objects/units/<sid>.prop`, `data/animations/acl/acl.lib`, `data/animations/acl/*.acl`, `data/animations/ref/refunit.acl`, `data/scripts/units/unit.inc/ontagstates.inc:302-589`, `data/scripts/units/unit.inc/initial.inc:17-19`, `data/gui/menu.inc/showdebuganimations.inc:45-66,113-155` | sid→ACL chain, state mapping, blend/loop policy |

Read-only rule observed: no donor file was run, unpacked into the repo or copied.
All measurements cite donor `path:line` (text) or `path:offset` (binary).

---

## 2. Verification 1 — AAF catalog (fresh parse)

### 2.1 Independent method

Walk `data/**/*.aaf` with `pathlib.rglob`; read bytes; check `AAF\r\n` at offset 0;
`bytes.split(b"\r\n")`; parse line 2 as declared integer count; classify each later
line as blank (skip), `//`-comment (record separately) or active row via own regex
`^"([^"]+)",(\d+),(\d+),([A-Za-z_]+)$`. Durations recomputed as `(last−first+1)/30`.
No code from DANIM-01, DEC-04 or `bake_sprites.py` was imported.

### 2.2 Headline census — all CONFIRMED

| Claim (DANIM-01 §3.1 / DEC-04 §4.3) | DANIM-02 fresh measurement | Verdict |
|---|---:|---|
| `.aaf` files under `data/**` = 246 | **246** (`194` in `animations/aaf/*.aaf` + `52` in `animations/aaf/pfx/`) | **CORRECT** |
| magic `AAF\r\n` on every file | **246/246** | **CORRECT** |
| active action rows = 1,434 | **1,434** | **CORRECT** |
| distinct action names = 62 | **62** (full sorted list matches §3.3) | **CORRECT** |
| declared count (line 2) == active rows | **246/246** | **CORRECT** |
| rows with a flag other than `morph` | **0** (1,434/1,434 `morph`) | **CORRECT** |
| 6 commented `//"attack2",630,679,morph` rows | **6** (see §2.4) | **CORRECT** |
| malformed active rows | **0** | **CORRECT** |
| 218 files with trailing blank line / 277 blank lines | **218** files end with CRLF; **59** genuine blank lines in **58** files → 218 + 59 = **277** | **CORRECT** (refined accounting) |
| frame starts 1..740 | starts **1..740**; ends **1..754** (`dragoon18fra.aaf:10`, `kingmusketeer.aaf:9` = `prepare0 740..754`) | **CORRECT**, refined |

### 2.3 Duration formula `(last−first+1)/30` — CONFIRMED (derived + donor code)

Recomputed over all 1,434 rows: min span **1** → 0.0333 s, max span **305** →
10.1667 s, mean span **45.3731** → mean **1.5124 s**; modal spans
`24 (192 rows), 50 (148), 2 (123), 90 (54), 26 (54), 85 (53), 51 (41), 22 (40),
280 (37), 23 (36), 12 (36), 63 (34)` — exactly DANIM-01 §3.2's values.

Donor-code cross-check (fresh read):

| Donor evidence | Text actually read |
|---|---|
| `data/scripts/lib/unit.script:10774-10777` | `GetGameObjectFrameAnimationDataByHandle(goHnd, anim, sf, ef)` → `frames := 1+ef-sf;` → `(frames/30)` |
| `data/scripts/lib/unit.script:2622-2625` | same inclusive count for weapon pause (`_misc_FramesToTime(frames)`) |
| `data/scripts/lib/movie.script:854-859` | `_movie_GetAnimationLength` → `Result := ((ef-sf)/30)` — **exclusive**, one frame shorter |
| `data/actors/units/peaukr.oss:0x4` | `fps = 30` |

Verdict: the inclusive recipe is donor-grounded; the movie-helper caveat in
DANIM-01 §3.2 is also correct. Rounding in the §5 table agrees to 3 decimals.

### 2.4 Commented `//attack2` rows — 6/6 CONFIRMED

| `path:line` | Verbatim row | Counted? |
|---|---|---|
| `data/animations/aaf/grenadier.aaf:33` | `//"attack2",630,679,morph` | no |
| `data/animations/aaf/grenadierbav.aaf:33` | `//"attack2",630,679,morph` | no |
| `data/animations/aaf/grenadierden.aaf:33` | `//"attack2",630,679,morph` | no |
| `data/animations/aaf/grenadierhun.aaf:33` | `//"attack2",630,679,morph` | no |
| `data/animations/aaf/grenadierpru.aaf:33` | `//"attack2",630,679,morph` | no |
| `data/animations/aaf/grenadiersax.aaf:33` | `//"attack2",630,679,morph` | no |

Each file declares 30 and has 30 active rows; the comment is excluded correctly.
Active `attack2` is `153..154` (`grenadier.aaf:23`), with the long action split into
`attack2before 630..663` / `attack2after 664..679` (`grenadier.aaf:31-32`).

### 2.5 Minor refinement to DANIM-01 §3.3 (not a core-claim failure)

The §3.3 header says "`span` = `last−first+1`" for the *modal range* column, but the
printed `modal span / modal dur` values are in fact the **most common span across all
rows of that name**. Examples from the fresh parse:

| action | modal range (files) | span of that range | §3.3 printed span/dur | actual most-common span (rows) |
|---|---|---:|---:|---:|
| `idle` | 1..90 (52) | 90 → 3.000 s | 50 / 1.667 | 50 (60 rows) |
| `attack0` | 1..280 (9) | 280 → 9.333 s | 14 / 0.467 | 14 (21 rows) |
| `close` | 70..140 (2) | 71 → 2.367 s | 101 / 3.367 | 101 (tied, 2 rows) |
| `idle0` | 204..254 (23) | 51 → 1.700 s | 50 / 1.667 | 50 (31 rows) |

59 of 62 rows follow this pattern; the three degenerate single-range names (`attack2`,
`death2`, `construct`, …) coincide either way. All §3.1/§3.2 totals, the 62-name list
and the duration formula remain **CORRECT**; only the §3.3 column semantics need
relabelling (see §6).

---

## 3. Verification 2 — frame-0 bind pose (independent `struct.unpack_from`)

### 3.1 Independent method

For each `.oss`: `<6i` header at `0x0` (`k,fps,b,v,fc,t`); compute the bone-track
base **by seeking**, not by sequential reads:

```
base = 24 + v·12 + fc·12 + t·8 + fc·12 + Σ_{i=0..v−1}(4 + 8·n_i)
frame-0 record of bone j = struct.unpack_from("<7f", raw, base + (j·k + 0)·28)
```

Identity metrics (defined explicitly; DEC-04 used the **max-component** variant,
DANIM-01 §6 used Euclidean norms — both are reported):
`|p| = max(|px|,|py|,|pz|)` or `sqrt(px²+py²+pz²)`;
`|q−I| = max(|qx|,|qy|,|qz|,|qw−1|)` or `sqrt(qx²+qy²+qz²+(qw−1)²)`.
Skin displacement recomputed as form (1) `v' = Σw(R_row(q)·v + p)` with the
transposed matrix at `bake_sprites.py:118-129` (column-vector form also checked;
it differs only at float32 noise for these files).

### 3.2 Whole-family census — 335/335 CONFIRMED

| Measure | DANIM-01 §6.2 Method B | DANIM-02 fresh census | Verdict |
|---|---:|---:|---|
| files with exact size closure | 335/335 | **335/335** (`base + b·k·28 == filesize`, tail 0) | **CORRECT** |
| max `\|p\|` @f0 (Euclidean) | 1.09e−6 m | **1.09257e−6 m** | **CORRECT** |
| max `\|q−I\|` @f0 (Euclidean) | 3.02e−8 | **3.01639e−8** | **CORRECT** |
| identity by bone count | `b=1` 124/124, `b=20` **22/22**, `b=24` 43/43, all buckets 100 % | identical bucket census (22 buckets; `b=1` 124/124, `b=20` **22/22**, `b=24` 43/43) | **CORRECT** |
| frame-major misread identity count | 175/335 | **175/335** | **CORRECT** (artifact reproduced) |

### 3.3 Sample table — 31 files, including all 22 `b=20` families

All rows: `closure = True`, metric = Euclidean `|p|`/`|q−I|`, `skin` = form (1)
max/mean displacement in metres, `FM` = the frame-major misread (max component).
`base` is the computed bone-track start (`path:offset`). Every verdict is
**IDENTITY** (frame 0 is bind to float32 noise).

| `path:offset` (track base) | b | k | max `\|p\|` @f0 | max `\|q−I\|` @f0 | skin max/mean | FM `\|p\|`/`\|q−I\|` | Verdict |
|---|---:|---:|---:|---:|---:|---:|---|
| `data/actors/pfx/shot/shotmusket1.oss:0x258` | 1 | 91 | 2.328e−10 | 2.312e−13 | 2.331e−10 / 2.328e−10 | 0.00000 / 0.00000 | IDENTITY |
| `data/actors/buildings/commoneur/attach/eurgolanim.oss:0x1a30` | 7 | 58 | 3.372e−07 | 2.328e−10 | 3.372e−07 / 1.530e−07 | 0.00000 / 0.00000 | IDENTITY |
| `data/actors/buildings/aus/attach/ausbaranim.oss:0x1188` | 10 | 43 | 9.830e−07 | 4.657e−10 | 9.830e−07 / 4.221e−07 | 0.00000 / 0.00000 | IDENTITY |
| `data/actors/buildings/aus/attach/ausdipanim.oss:0x3d48` | 13 | 58 | 1.066e−06 | 2.364e−10 | 1.066e−06 / 3.313e−07 | 0.00000 / 0.00000 | IDENTITY |
| `data/actors/units/attach/galley_paddle_r.oss:0x5058` | 13 | 301 | 2.666e−07 | 2.220e−16 | 2.666e−07 / 1.115e−07 | 5.45771 / 0.75166 | IDENTITY |
| `data/actors/units/cossackdon.oss:0xb048` | 16 | 671 | 3.373e−07 | 1.633e−08 | 3.601e−07 / 9.375e−08 | 2.74017 / 0.18547 | IDENTITY |
| `data/actors/units/dragoon18fra.oss:0xcb80` | 20 | 755 | 4.299e−07 | 2.251e−08 | 4.302e−07 / 1.620e−07 | 2.15379 / 0.00000 | IDENTITY |
| `data/actors/units/drummer18.oss:0xc0a8` | 20 | 133 | 1.687e−07 | 2.319e−08 | 1.378e−07 / 4.647e−08 | 0.11398 / 0.02945 | IDENTITY |
| `data/actors/units/ferry.oss:0xa8b0` | 20 | 311 | 2.393e−07 | 1.533e−08 | 2.421e−07 / 5.552e−08 | 0.05921 / 0.03249 | IDENTITY |
| `data/actors/units/fishboat.oss:0xa8b0` | 20 | 311 | 2.393e−07 | 1.533e−08 | 2.421e−07 / 5.552e−08 | 0.05921 / 0.03249 | IDENTITY |
| `data/actors/units/frigate.oss:0xa8b0` | 20 | 311 | 2.393e−07 | 1.533e−08 | 2.421e−07 / 5.552e−08 | 0.05921 / 0.03249 | IDENTITY |
| `data/actors/units/galley.oss:0xa8b0` | 20 | 311 | 2.393e−07 | 1.533e−08 | 2.421e−07 / 5.552e−08 | 0.05921 / 0.03249 | IDENTITY |
| `data/actors/units/hetman.oss:0xcd30` | 20 | 656 | 3.385e−07 | 2.243e−08 | 3.604e−07 / 1.297e−07 | 2.34927 / 0.00000 | IDENTITY |
| `data/actors/units/jannisary.oss:0xcaf0` | 20 | 633 | 1.690e−07 | 1.003e−08 | 1.695e−07 / 6.449e−08 | 0.12196 / 0.03816 | IDENTITY |
| `data/actors/units/kingmusketeer.oss:0xcab0` | 20 | 755 | 4.299e−07 | 2.251e−08 | 4.302e−07 / 1.767e−07 | 2.15379 / 0.00000 | IDENTITY |
| `data/actors/units/musketeer18.oss:0xd0e8` | 20 | 630 | 1.690e−07 | 1.054e−08 | 1.695e−07 / 8.151e−08 | 0.12123 / 0.03816 | IDENTITY |
| `data/actors/units/musketeer18bav.oss:0xbb60` | 20 | 631 | 1.690e−07 | 1.214e−08 | 1.695e−07 / 7.021e−08 | 0.12123 / 0.03816 | IDENTITY |
| `data/actors/units/musketeer18pru.oss:0xb738` | 20 | 630 | 1.892e−07 | 1.250e−08 | 1.956e−07 / 9.844e−08 | 0.12196 / 0.03816 | IDENTITY |
| `data/actors/units/musketeer18sax.oss:0xbfb8` | 20 | 631 | 1.690e−07 | 1.214e−08 | 1.695e−07 / 7.740e−08 | 0.12123 / 0.03816 | IDENTITY |
| `data/actors/units/musketeeraus.oss:0xccd8` | 20 | 346 | 1.690e−07 | 1.054e−08 | 1.695e−07 / 7.046e−08 | 0.12123 / 0.03816 | IDENTITY |
| `data/actors/units/musketeersco.oss:0xb690` | 20 | 631 | 1.690e−07 | 1.214e−08 | 1.695e−07 / 7.299e−08 | 0.12123 / 0.03816 | IDENTITY |
| `data/actors/units/peatur.oss:0xb780` | 20 | 483 | 2.982e−07 | 2.987e−08 | 3.089e−07 / 7.274e−08 | 0.08774 / 0.07166 | IDENTITY |
| `data/actors/units/peaukr.oss:0xa3a8` | 20 | 483 | 1.491e−07 | 2.253e−08 | 1.523e−07 / 7.349e−08 | 0.10129 / 0.01579 | IDENTITY |
| `data/actors/units/pikeman.oss:0xc5c8` | 20 | 312 | 2.393e−07 | 2.283e−08 | 2.421e−07 / 5.159e−08 | 0.11383 / 0.07160 | IDENTITY |
| `data/actors/units/pikemansco.oss:0xb568` | 20 | 311 | 1.735e−07 | 2.283e−08 | 1.322e−07 / 4.695e−08 | 0.11383 / 0.07160 | IDENTITY |
| `data/actors/units/pikemanspa.oss:0xa4e0` | 20 | 312 | 2.393e−07 | 2.283e−08 | 2.423e−07 / 5.966e−08 | 0.11383 / 0.07160 | IDENTITY |
| `data/actors/units/yacht.oss:0xa8b0` | 20 | 311 | 2.393e−07 | 1.533e−08 | 2.421e−07 / 5.552e−08 | 0.05921 / 0.03249 | IDENTITY |
| `data/actors/units/yachttur.oss:0xa8b0` | 20 | 311 | 2.393e−07 | 1.533e−08 | 2.421e−07 / 5.552e−08 | 0.05921 / 0.03249 | IDENTITY |
| `data/actors/units/attach/cossackdon_horse.oss:0xa9a8` | 24 | 671 | 1.686e−07 | 2.724e−08 | 2.235e−07 / 7.253e−08 | 0.47085 / 0.05267 | IDENTITY |
| `data/actors/units/attach/cossackregister_horse.oss:0xa9a8` | 24 | 671 | 2.666e−07 | 2.724e−08 | 2.710e−07 / 8.292e−08 | 0.43071 / 0.03918 | IDENTITY |
| `data/actors/units/attach/cossacksich_horse.oss:0xa998` | 24 | 605 | 2.458e−07 | 2.724e−08 | 2.539e−07 / 6.410e−08 | 1.33596 / 0.35466 | IDENTITY |

The six DANIM-01 §6.2 Method-A rows are independently reproduced to their reported
precision (`peaukr` 1.52e−7, `pikeman` 2.42e−7, `yacht` 2.42e−7, `cossackdon`
3.60e−7, `ausbaranim` 9.83e−7, `eurgolanim` 3.37e−7). Quaternion norms at frame 0
are unit to `1.0000000000` at 10 decimals in every sampled file.

### 3.4 DEC-04 §6.1 numbers — exact reproduction as an indexing artifact

DEC-04 `DEC_04_anim_formats.md:422-447` claimed multi-bone frame 0 is not bind.
My **correct bone-major** read contradicts it; reading the first `b` *contiguous*
records (`base + i·28`, i = 0..b−1) as "frame 0 of all bones", with
**max-component** metrics and form (1) skin, reproduces DEC-04's numbers exactly:

| File (`path:offset`) | DEC-04 claimed `\|p\|` / `\|q−I\|` / skin max | DANIM-02 bone-major (correct) | DANIM-02 frame-major misread, max-component | Verdict |
|---|---|---|---|---|
| `peaukr.oss:0xa3a8` | 0.09912 / 0.01189 / 0.09496 | 1.491e−7 / 2.253e−8 / 1.523e−7 | **0.09912 / 0.01189 / 0.09496** | DEC-04 REFUTED; artifact EXACTLY reproduced |
| `pikeman.oss:0xc5c8` | 0.11305 / 0.07122 / 0.14911 | 2.393e−7 / 2.283e−8 / 2.421e−7 | **0.11305 / 0.07122 / 0.14911** | ditto |
| `yacht.oss:0xa8b0` | 0.05872 / 0.03224 / 0.06822 | 2.393e−7 / 1.533e−8 / 2.421e−7 | **0.05872 / 0.03224 / 0.06822** | ditto |
| `cossackdon.oss:0xb048` | 2.3722 / 0.17200 / 2.55275 | 3.373e−7 / 1.633e−8 / 3.601e−7 | **2.37223 / 0.17200 / 2.55275** | ditto |
| `galley_paddle_r.oss:0x5058` | 4.9024 / — / — | 2.666e−7 / 2.220e−16 / 2.666e−7 | **4.90236** / 0.66762 / — | ditto |

DEC-04's "best identity frame" numbers are the same artifact (e.g. its peaukr
rotation f=4 with err 3.0e−8 is a frame-major slice, not the bind frame). This
upgrades DANIM-01 §6.2 Method C from "close to DEC-04's figures" to a **bit-level
explanation** of where every cited DEC-04 number came from.

Conclusion: **frame 0 is the bind pose; stored tracks are absolute** at the
deformation-data level (DEEPDEC-06 F4/F5). Bone-parent absence is real but parents
are pre-folded. Donor engine skin form, quaternion convention and any rendered A/B
stay **UNVERIFIED** (CORRECTIONS.md:98,132).

---

## 4. Verification 3 — the §5 clip table

DANIM-01 §5 has **43 data rows + 1 header = 44 table lines** (the "44-row table" in
the task). Every one of the 43 rows was parsed and compared against the fresh AAF
parse: name(s), inclusive range, cited `path:line`, and `(last−first+1)/30`
duration. Result: **43 CORRECT, 0 WRONG**. Verdict key:
**CORRECT** = all four fields match donor bytes and the name is present in the
unit's donor state/ACL chain; **WRONG** = any mismatch; **UNVERIFIED** = claims not
recoverable from donor text/bytes (port-skin status, engine consumption, visual).

### 4.1 Per-unit check (13 units, all above the required 10)

| Unit / sid | §5 rows | Representative AAF `path:line` checked | `.prop` → `acl.lib` → ACL chain (fresh read) | Name in donor state map | Verdict |
|---|---:|---|---|---|---|
| peasant (`peaukr`) | 8 | `peaukr.aaf:3,5-10,17` | `peaukr.prop:54` → `acl.lib:238-239` → `peasant.acl` → `refunit.acl` → `refspeed.acl` | `dmscript.global:868,872,876,920-922,926`; `unit.script:10865-10877,6993-7008` | **CORRECT** |
| pikeman | 4 | `pikeman.aaf:3,4,6,11` | `pikeman.prop:19` → `acl.lib:2-3` (duplicate `:242-243`) → `infantry.acl` | `unit.script:10880,10930-10939,11087` | **CORRECT** |
| archer | 4 | `archer.aaf:3,4,7-9` | `archer.prop:19` → `acl.lib:6-7` → `infantryarcher.acl` → `infantry.acl` | `unit.script:10881,10883,10945-10946` | **CORRECT** |
| musketeer | 4 | `musketeer.aaf:3,7,8,17` | `musketeer.prop:19` → `acl.lib:170-171` → `infantry.acl` | `dmscript.global:877,885`; `unit.script:11089` | **CORRECT** |
| grenadier | 4 | `grenadier.aaf:3,9,10,19` | `grenadier.prop:19` → `acl.lib:102-103` → `infantrygrenadier.acl` → `infantry.acl` | `unit.script:10878-10883` | **CORRECT** |
| cossack (`cossacksich`) | 4 | `cossacksich.aaf:3,6-8` | `cossacksich.prop:34` → `acl.lib:42-43` → `fasthorse.acl` | `dmscript.global:868,872,876,885`; `unit.script:10880,11087` | **CORRECT** |
| dragoon (`dragoon18`) | 4 | `dragoon18.aaf:3,6-8` | `dragoon18.prop:34` → `acl.lib:58-59` → `hardhorse.acl` | `unit.script:10880,11087` | **CORRECT** |
| cannon | 3 | `cannon.aaf:3-6` | `cannon.prop:45` → `acl.lib:22-23` → `cannon.acl` → `refunit.acl` → `refspeed.acl` | `cannon.acl:3-7,17-18,38-40` (`From/Name/AnimationName`) | **CORRECT** |
| hussar | 3 | `hussar.aaf:3,5,7` | `hussar.prop:34` → `acl.lib:122-123` → `fasthorse.acl` | `unit.script:10880,11087` | **CORRECT** |
| hetman | 2 | `hetman.aaf:5,7` | `hetman.prop:34` → `acl.lib:106-107` → `hardhorse.acl` | `unit.script:10880` | **CORRECT** |
| yacht (naval) | 1 (4 names) | `yacht.aaf:3-6` | `yacht.prop:99` → `acl.lib:318-319` → `yacht.acl` → `refunit.acl` → `refspeed.acl` | `ACL From/Name = idle,walk,death,attack0` | **CORRECT** |
| galley (naval) | 1 (4 names) | `galley.aaf:3-6` | `galley.prop:99` → `acl.lib:98-99` → `galley.acl` → `refunit.acl` → `refspeed.acl` | same ACL token set | **CORRECT** |
| battleship (naval) | 1 (4 names) | `battleship.aaf:3-6` | `battleship.prop:99` → `acl.lib:18-19` → `battleship.acl` → `refunit.acl` → `refspeed.acl` | same ACL token set | **CORRECT** |

For all 13 units, each §5 action name occurs as a `From`/`Name`/`AnimationName`
token in the unit's ACL file or one of its transitively inherited parents
(`refunit.acl:28-47` supplies `idle`/`walk`; `infantryarcher.acl:1` and
`infantrygrenadier.acl:1` inherit `infantry.acl`). No §5 name was absent from the
chain. Note that `acl.lib:2-3` and `:242-243` are duplicate `pikeman` entries,
both → `infantry.acl`; DANIM-01's citation of `:2-3` is the first occurrence and is
correct.

### 4.2 Donor state→name and loop/blend evidence (fresh read)

| DANIM-01 claim | Fresh donor read | Verdict |
|---|---|---|
| canonical name constants at `dmscript.global:868-926` | lines **868-926** are `gc_anim_idle='idle'` … `gc_anim_construct='construct'` (59 assignments) | **CORRECT** |
| extract/build/attack → `workfood/workwood/workstone/construct/attack0/1/2` | `unit.script:10865-10883` | **CORRECT** |
| weapon 0/1/2 idle/walk + transitions + weapon death | `unit.script:10935-10954`, `:11086-11093`; `ontagstates.inc:397-423,435-437,581-589` | **CORRECT** |
| missing-name fallbacks | `unit.script:11048-11051` (`animwalk` → `walk`), `:11092-11093` (weapon death → `death`) | **CORRECT** |
| peasant attached tool by action name | `unit.script:6993-7008` (hoe/axe/pick/hammer + bag/lumber/cart) | **CORRECT** |
| one-shot/death and blend constants | `unit.script:10808-10809,10852`; `initial.inc:17-19` (`6`/`8`/false); `showdebuganimations.inc:45-66,121-131` (`True` for attacks/deaths) | **CORRECT** |
| movie uses exclusive duration | `movie.script:854-859` (`(ef-sf)/30`) | **CORRECT** |
| `.inc` lines prefixed `[*] = ;` are live code, not comments | per `CORRECTIONS.md:52` (row 6); the cited `ontagstates.inc` / `initial.inc` lines all carry `[*] = ;` markers | **CORRECT** (row 6 governs) |

### 4.3 What is NOT verified by this check

| Claim | Status |
|---|---|
| `port status` SUBSET / DONOR-ONLY in §5 (shipped skin index) | **UNVERIFIED** from donor alone — not a donor fact; repo artifact not re-audited here |
| literal `morph` flag consumed by engine; `items[n].Action` semantics; meaning of blend `6/8` | **UNVERIFIED** — script/ACL strings only, no compiled engine body |
| donor skin equation form, quaternion convention, any rendered A/B | **UNVERIFIED** — no donor execution; **no parity claim** |

---

## 5. Corrections and refinements delivered

| Prior claim / item | DANIM-02 verdict | Evidence |
|---|---|---|
| CORRECTIONS rows 14/51 (duplicate frame-0 chain); row 51 authoritative | **CONFIRMED**, with an additional independent pass (fresh `struct.unpack_from` seek census) | CORRECTIONS.md:60,98,111-115; §3.2–3.4 here |
| DEC-04 §6.1 "frame 0 is not bind for multi-bone files" | **REFUTED again**, now with bit-level reproduction of every cited number as a frame-major + max-component artifact | §3.4 table; `DEC_04:422-447` |
| DANIM-01 §3.3 "`span` = last−first+1" for the modal-range column | **REFINEMENT**: printed `modal span/dur` values are the most-common span over all rows of that name, not the span of the printed modal range (59/62 rows differ). Core census/duration claims unaffected | §2.5 table |
| DEC-04 §4.3/§11 "inclusive frames 1..740" | **REFINEMENT**: 740 is the maximum *start*; maximum *end* is 754 | `dragoon18fra.aaf:10`, `kingmusketeer.aaf:9` |
| 277 blank lines / 218 files | **REFINEMENT**: 218 trailing-CRLF empty fields + 59 genuine blank lines in 58 files | §2.2 |
| §5 clip table (43 data rows) | **CONFIRMED without correction** — 43/43 CORRECT, 0 WRONG | §4.1 |

No prior correction row is reversed; no new donor finding is promoted to a parity
claim.

---

## 6. Open questions (unchanged unless noted)

1. Engine consumption of the literal `morph` flag: 0 readable script/config hits; implementation UNVERIFIED.
2. ACL `items[n].Action` (`actAnimation` / `actTrackPoint` / `actExecuteState`) semantics: data-level only.
3. Frame-blend `6/8`: cross-fade, delay or interpolation? UNVERIFIED.
4. Donor skin equation form, donor→Godot quaternion convention and rendered A/B: UNVERIFIED; keep `PORT APPROXIMATION — NOT DONOR PARITY`.
5. Owner decision: relabel DANIM-01 §3.3 columns as "modal span (rows)" to match their values, or recompute them as span of the modal range. No numeric change to §3.1/§3.2.
6. Port `SUBSET`/`DONOR-ONLY` statuses in §5 were not re-audited against the shipped skin index here; they remain repo-artifact claims, not donor facts.
7. Why DEC-04 indexed bone-major tracks frame-major is explained mechanically (§3.4), but the originating scripting mistake is not recoverable.

---

## 7. Summary

- **AAF catalog CONFIRMED:** fresh parse of all **246** files gives **1,434** active rows,
  **62** action names, **246/246** declared-count matches, **1,434/1,434** `morph`
  flags, **0** malformed rows, and exactly **6** commented `//"attack2",630,679,morph`
  rows in six `grenadier*` files. Duration `(last−first+1)/30` reproduces all §3.2
  statistics and is backed by `unit.script:10774-10777` (movie helper is exclusive).
- **Frame-0 reversal CONFIRMED independently:** `struct.unpack_from` seek census over
  **335/335** `.oss` files closes exactly and gives frame-0 identity (max
  `|p|=1.09257e−6 m`, max `|q−I|=3.01639e−8`); **all 22 `b=20`** files pass. A 31-file
  sample (including those 22 plus `b=1/7/10/13/16/24`) lists `path:offset`, metrics and
  IDENTITY verdicts. DEC-04's claimed 0.09912 m / 0.01189 / 0.09496 m figures are
  reproduced **exactly** only by the frame-major misread with max-component metrics —
  DEC-04 §6.1 is refuted at the number level, not just qualitatively.
- **Clip table CONFIRMED:** all **43** data rows of DANIM-01 §5 match donor AAF bytes,
  citation lines and duration rounding; **13 units** additionally verified through
  `dmscript.global`/`unit.script` state names, `.prop` → `acl.lib` → ACL inheritance
  chain. Verdicts: **43 CORRECT / 0 WRONG**; port status and engine semantics **UNVERIFIED**.
- **No parity claim:** deformation-data identity does not settle engine skin form,
  quaternion convention or visual parity; those stay UNVERIFIED per CORRECTIONS rows 14/51.

No donor file was executed or copied; no repo file other than this report was
written; no Godot/Blender/runner job was started. Temporary analysis scripts lived
only in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode`.
