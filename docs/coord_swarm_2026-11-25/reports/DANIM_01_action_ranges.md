---
id: DANIM-01
title: "DANIM-01 — donor AAF action ranges → per-unit animation clip truth for the 3D variant"
date: 2026-11-25
owner: DANIM-01 (donor deep-dive micro-worker)
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Exactly one report written. No repo code/config/asset/test/scene/git edit; no Godot/Blender run; no donor binary executed, unpacked or copied into the repo."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/struct/latin-1; never executed or copied)"
output: "docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md"
labels: [observed, derived, inferred, UNVERIFIED]
governing_rule: "Cite donor path:line or path:offset; separate observed / derived / inferred / UNVERIFIED; verify each key claim two ways (DEC-04 frontmatter :7; WAVE7_3D_VARIANT_CHARTER.md:29-38)."
methods:
  - "M1 — full read-only Python latin-1/CRLF parse of all 246 .aaf files (regex rows, blank/comment filtering, declared-count equality, duration arithmetic) + 62-name catalog + range-group/outlier aggregation"
  - "M2 — donor text-chain read: scripts/dmscript.global, scripts/lib/unit.script, scripts/units/unit.inc/ontagstates.inc, animations/acl/*.acl + acl.lib, objects/units/*.prop, gui/menu.inc/showdebuganimations.inc, animations/tpl/tpl.library"
  - "M3 — second-method bind-pose verification: (a) sequential struct.unpack reader + quaternion Hamilton-product cross-check + verbatim bake_sprites.qmat/skin, (b) independent bone-major offset-seek census over all 335 .oss files, (c) diagnostic reproduction of the frame-major misread"
  - "M4 — repo cross-check of variant3d/scripts/anim3d.gd (READ ONLY) and variant3d/assets/models/skin/index.json (offline donor-derived shipped skin index)"
corrections:
  DEC_04_frame0_claim: "REFUTED — DEC-04 §6.1 'frame 0 is not bind for multi-bone files' is an artifact of reading the bone-major track array as frame-major; 335/335 .oss have frame-0 identity (max |p| 1.09e-6 m, max |q-I| 3.02e-8)"
  DEEPDEC_06_F4_F5: "CONFIRMED at deformation-data level by two independent methods; frame 0 IS the bind pose and stored tracks are absolute"
  DEC_04_AAF_core: "CONFIRMED — 246/246 parse, 1,434 active rows, all 'morph', durations (last-first+1)/30"
verdicts:
  clip_truth: "READABLE AND CATALOGED — 62 action names, per-family inclusive ranges, donor engine consumes them by name via GetGameObjectFrameAnimationDataByHandle"
  donor_parity_deformation: "NOT BLOCKED BY MISSING BONE PARENTS (parents are pre-folded); still pose-decimated + visual UNVERIFIED → PORT APPROXIMATION label retained"
  loop_policy: "AAF has NO loop flag; donor-authored loop/one-shot + blend policy exists in scripts/ACL (readable)"
  engine_morph_consumption: "UNVERIFIED — the literal token 'morph' has 0 hits in all readable donor scripts/configs; only the engine can consume that flag"
---

# DANIM-01 — donor AAF action ranges → per-unit animation clip truth

## 0. Goal

Give the `anim3d.gd` owner the missing layer between DEC-04's binary decode and a
usable per-unit clip table:

1. Which **action names** exist in all donor `.aaf` files, their **inclusive frame
   ranges**, the duration formula, and any loop/transition metadata.
2. The **state → AAF-name chain** actually authored by the donor (scripts, ACL,
   `.prop`, `.actor`, ACL library), with `path:line` citations.
3. A second-method **verification** of DEC-04's corrected frame-0/bind-pose claims,
   and an honest statement of what blocks donor-parity skeletal animation.
4. A concrete **clip table** keyed to the port's shipped sid → donor AAF base map.

All donor reads are `bytes`/`latin-1`, read-only. No donor binary was run or copied.

---

## 1. Sources read (all read-only)

| id | Source | Use |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` | AAF layout/§4.3, census §2, "frame 0 refutation" §6.1, blockers §7. **Corrected here in §7.** |
| S2 | `docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md` | §3.2 `.oss` header table, §3.3 bone-parent blocker, Table B1/C labels |
| S3 | `docs/coord_swarm_2026-11-24/reports/V764_donor_morph_anim.md` | `AAF_ACTIONS` constants `:63-84`, `AAF_ACTIONS` 18-row peaukr table, `ACTION_ALIAS` `:94-96`, `_frame_at` `:582-588` |
| S4 | `docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md` | `_unit_action(ed)` PORT policy `dead→death / moving→walk / else idle` at `:506-517` |
| S5 | `docs/coord_swarm_2026-11-24/reports/V779_pose_memo.md` | per-`(sid,action)` pose memo; frame derives from `(sid, action, donor time)` |
| S6 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_06_models_anim.md` | F4/F5 "frame 0 = bind; absolute tracks"; skin equation §4; decoder plan §5. **Confirmed here in §6.** |
| S7 | `variant3d/scripts/anim3d.gd` (read only, no edit) | `AAF_ACTIONS` `:71-90`, `ACTION_ALIAS` `:94-96`, `_frame_at` `:582-588`, `_action_range_for` `:918-934`, shipped-skin actions from each unit's own AAF `:843-857` |
| S8 | `variant3d/tools/bake_sprites.py:91-103,105-116,118-143,145-152` | verbatim donor `.oss` reader, AAF reader, `qmat`, `skin`, `sample` |
| S9 | `variant3d/assets/models/skin/index.json` | 55 shipped sids → donor `.oss`/`.aaf`, sampled frames (offline converter output) |
| S10 | direct read-only Python passes over the donor (M1–M3) | all `[MEASURE]` lines below |

### 1.1 Donor citation ledger (governing-rule compliance)

| Decision | Donor source (read-only) | Repo decode / evidence |
|---|---|---|
| AAF magic/count/rows | `data/animations/aaf/peaukr.aaf:1-20` (18 rows; `walk 1..20` at `:5`) | DEC-04 §4.3 `:245-281`; `docs/decomp/DC_FORMATS.md:96-109` |
| 246 AAF files, 1,434 active rows, 62 names, all `morph` | recursive `data/**/*.aaf` census (M1) | DEC-04 §2/§4.3 (independent parse) |
| Duration = `(last-first+1)/30` | `data/scripts/lib/unit.script:10774-10777` (`frames := 1+ef-sf`; `(frames/30)`), `:2622-2625`; `data/scripts/lib/movie.script:854-858` (`(ef-sf)/30`) | DEC-04 §4.3 `:261`, §6.3 `:472-482` |
| State→name constants | `data/scripts/dmscript.global:868-926` (`gc_anim_idle='idle'` … `gc_anim_construct='construct'`) | first full donor citation for this chain |
| State→name selection | `data/scripts/lib/unit.script:10856-11090`; `data/scripts/units/unit.inc/ontagstates.inc:302-589` | first full donor citation for this chain |
| `.prop` → ACL library | `data/objects/units/peaukr.prop:53-55` (`FrameAnimationCyclesLibName = peaukr`); `data/objects/units/archer.prop:18-19` (`= archer`) | new chain link |
| ACL library → ACL file | `data/animations/acl/acl.lib:238-239` (`peaukr` → `peasant.acl`); `:2-3` (`pikeman` → `infantry.acl`) | DEC-04 §5 `:382-389` |
| ACL clip name = AAF name | `data/animations/acl/cannon.acl:3-7,17-18,38-40,81-83`; `peasant.acl:2141-2145,2246-2250` | DEC-04 §4.4 `:283-356` |
| `.actor` → AAF + `.oss` | `data/actors/units/peaukr.actor:4-6` | DEC-04 §5 `:375-380` |
| Loop/one-shot/blend | `data/gui/menu.inc/showdebuganimations.inc:45-66,113-155`; `data/scripts/lib/unit.script:10846-10847`; `data/scripts/units/unit.inc/initial.inc:17-19`; `data/animations/acl/cannon.acl:19-24` | new; DEC-04 only said "AAF has no loop flag" |
| Frame-0 bind pose | `data/actors/units/peaukr.oss:0xa3a8` (bone 0 frame 0 ≈ identity) plus bone-major census of all 335 `.oss` | S6 F4/F5; **DEC-04 §6.1 refuted in §6** |

---

## 2. Method and label discipline

Every key claim is checked by **two means** (DEC-04 frontmatter `:7`):

| Key claim | Method A | Method B (independent) | Result |
|---|---|---|---|
| 246 files / 1,434 active rows / 62 names / all `morph` | M1 direct CRLF regex parse, blank/comment rows excluded | declared count at AAF line 2 equals active-row count on **246/246** files; DEC-04's separate parse (`DEC_04:99,278-281`) | **CONFIRMED** (observed) |
| `duration = (last-first+1)/30` | arithmetic over 1,434 spans | donor engine `unit.script:10774-10777` computes `frames := 1+ef-sf` and divides by 30; `movie.script:857-858`; DEC-04 P4/P5 51/51 attacks | **CONFIRMED** (derived + donor code) |
| AAF names are consumed by name | `_unit_IsAnimationExists` → `GetGameObjectFrameAnimationDataByHandle` (`unit.script:369-373`) | ACL `From`/`Name`/`AnimationName` + debug buttons call the same names (`cannon.acl:3-7`, `showdebuganimations.inc:113-155`) | **OBSERVED** (script level); engine internals UNVERIFIED |
| Frame 0 is bind for all bones | sequential `struct.unpack` reader (verbatim `bake_sprites:91-103`) + quaternion Hamilton-product cross-check (max diff `4.57e-8`) on 7 samples | bone-major offset-seek census over **335/335** `.oss`, max `|p|=1.09e-6 m`, `|q-I|=3.02e-8` | **CONFIRMED**; DEC-04 refuted (§6) |
| No bone-parent table | DEC-04 §6.1 three methods (zero-slack closure, zero text hits, 7 floats fully consumed) | this pass re-measured exact size closure on 6 samples (`peaukr` 312,376 B, tail 0; etc.) | **CONFIRMED absent** (observed); interpretation "parents pre-folded" = inferred but donor-baker-validated |
| No loop flag in AAF | 1,434/1,434 rows carry token `morph`, 0 other flags | literal `morph` has **0 hits** in all readable donor scripts/configs (M2 sweep) → engine-side only | **OBSERVED** / engine consumption **UNVERIFIED** |

Labels used below: **observed** (bytes/text actually read), **derived** (computed from
observations), **inferred** (best explanation, not provable read-only), **UNVERIFIED**
(absent or not provable without donor code / a rendered A/B).

---

## 3. Full action catalog

### 3.1 File and row census (observed, M1)

| Item | Measured |
|---|---:|
| `.aaf` files under `data/**` | **246** |
| — `data/animations/aaf/*.aaf` | 194 |
| — `data/animations/aaf/pfx/*.aaf` (FX) | 52 |
| Active action rows (`"name",first,last,morph`) | **1,434** |
| Distinct action names | **62** |
| Files where declared count (line 2) == active rows | **246/246** |
| Rows with flag other than `morph` | **0** |
| Files with a trailing blank line (277 total blank lines) | 218 |
| Commented-out rows `//"attack2",630,679,morph` | **6**, in 6 `grenadier*` files at line 33 |
| Unexpected malformed active rows | **0** |

**Refinement to DEC-04 §4.3:** DEC-04 states "246/246 files parse, line-2 count equals
row count, 1,434/1,434 rows match the regex" — **confirmed**, with the added detail
that the count equality holds only for *active* rows: six `grenadier*` files declare
30 rows, contain 30 active rows plus one `//`-prefixed row, and 218 files end with
an extra CRLF. The commented `attack2 630..679` is **not** an available action
(`attack2` itself is `153..154`, a 2-frame stub — see §3.5).

### 3.2 Duration formula (derived; donor-code cross-check)

- Inclusive span: `span = last - first + 1` frames; `duration = span / 30` seconds,
  where `30` is the `.oss` header `fps` (int #1, 335/335 files — DEC-04 §4.1).
- Donor engine proof: `GetGameObjectFrameAnimationDataByHandle(hnd, anim, sf, ef)`
  returns the inclusive bounds; `data/scripts/lib/unit.script:10774-10777` computes
  `frames := 1+ef-sf` and compares `frames/30` to weapon pause.
- **Convention caveat (new):** `data/scripts/lib/movie.script:854-858` computes the
  *movie* animation length as `(ef-sf)/30` — **one frame shorter** than the inclusive
  span. Both are donor-authored; the clip table below uses the inclusive
  `(last-first+1)/30` recipe from DEC-04 §4.3 and `unit.script:10776-10777`.
- Measured over 1,434 rows: min `0.0333 s` (1 frame), max `10.1667 s` (305 frames),
  mean `1.5124 s`. Modal spans: 24 frames (192 rows), 50 (148), 2 (123), 90 (54),
  26 (54), 85 (53), 51 (41), 22 (40), 280 (37), 23 (36), 12 (36), 63 (34).

### 3.3 All 62 action names — frequency and range groups

`modal range` = most common exact `(first..last)` across files; `span` = `last-first+1`;
`dur` = `span/30`. **observed/derived**, M1.

| action | files | distinct ranges | modal range (files) | modal span | modal dur s | span min..max |
|---|---:|---:|---|---:|---:|---|
| `attack0` | 93 | 36 | 1..280 (9) | 14 | 0.467 | 6..280 |
| `attack0after` | 4 | 2 | 148..157 (3) | 10 | 0.333 | 10..17 |
| `attack0before` | 4 | 2 | 130..147 (3) | 18 | 0.600 | 12..18 |
| `attack0full` | 1 | 1 | 168..197 (1) | 30 | 1.000 | 30..30 |
| `attack0v1` | 1 | 1 | 168..184 (1) | 17 | 0.567 | 17..17 |
| `attack1` | 29 | 8 | 99..124 (9) | 26 | 0.867 | 14..37 |
| `attack1after` | 4 | 2 | 148..157 (3) | 10 | 0.333 | 10..17 |
| `attack1before` | 4 | 2 | 130..147 (3) | 18 | 0.600 | 12..18 |
| `attack2` | 7 | 1 | 153..154 (7) | 2 | 0.067 | 2..2 |
| `attack2after` | 7 | 1 | 664..679 (7) | 16 | 0.533 | 16..16 |
| `attack2before` | 7 | 1 | 630..663 (7) | 34 | 1.133 | 34..34 |
| `attackpause0` | 1 | 1 | 166..182 (1) | 17 | 0.567 | 17..17 |
| `close` | 5 | 4 | 70..140 (2) | 101 | 3.367 | 39..101 |
| `construct` | 8 | 1 | 186..198 (8) | 13 | 0.433 | 13..13 |
| `death` | 114 | 21 | 49..119 (28) | 71 | 2.367 | 23..280 |
| `death0` | 37 | 10 | 564..628 (21) | 65 | 2.167 | 40..72 |
| `death1` | 25 | 5 | 498..561 (11) | 64 | 2.133 | 60..72 |
| `death2` | 7 | 1 | 433..495 (7) | 63 | 2.100 | 63..63 |
| `fly` | 1 | 1 | 230..299 (1) | 70 | 2.333 | 70..70 |
| `idle` | 236 | 36 | 1..90 (52) | 50 | 1.667 | 1..305 |
| `idle0` | 85 | 15 | 204..254 (23) | 50 | 1.667 | 50..100 |
| `idle0_rest` | 1 | 1 | 335..402 (1) | 68 | 2.267 | 68..68 |
| `idle1` | 28 | 3 | 256..305 (24) | 50 | 1.667 | 50..85 |
| `idle1_rest` | 1 | 1 | 335..402 (1) | 68 | 2.267 | 68..68 |
| `idle2` | 7 | 1 | 153..202 (7) | 50 | 1.667 | 50..50 |
| `idle_closed` | 1 | 1 | 83..84 (1) | 2 | 0.067 | 2..2 |
| `idle_open` | 1 | 1 | 80..81 (1) | 2 | 0.067 | 2..2 |
| `idle_rest` | 32 | 7 | 335..415 (15) | 81 | 2.700 | 68..83 |
| `idle_to_walk` | 9 | 5 | 60..89 (4) | 30 | 1.000 | 29..31 |
| `idlefood` | 8 | 2 | 405..454 (7) | 50 | 1.667 | 50..50 |
| `idlestone` | 8 | 2 | 303..352 (7) | 50 | 1.667 | 49..50 |
| `idlewood` | 8 | 2 | 354..403 (7) | 50 | 1.667 | 50..50 |
| `next` | 1 | 1 | 308..331 (1) | 24 | 0.800 | 24..24 |
| `open` | 5 | 3 | 1..70 (3) | 70 | 2.333 | 40..100 |
| `prepare0` | 92 | 16 | 504..505 (17) | 2 | 0.067 | 2..24 |
| `prepare1` | 28 | 5 | 353..379 (17) | 27 | 0.900 | 2..27 |
| `prepare2` | 7 | 1 | 153..154 (7) | 2 | 0.067 | 2..2 |
| `reaction` | 8 | 2 | 456..481 (7) | 26 | 0.867 | 26..26 |
| `rope` | 1 | 1 | 195..229 (1) | 35 | 1.167 | 35..35 |
| `trans01` | 28 | 5 | 408..420 (14) | 13 | 0.433 | 2..13 |
| `trans02` | 7 | 1 | 329..351 (7) | 23 | 0.767 | 23..23 |
| `trans10` | 28 | 5 | 420..431 (15) | 12 | 0.400 | 2..12 |
| `trans12` | 7 | 1 | 380..405 (7) | 26 | 0.867 | 26..26 |
| `trans20` | 7 | 1 | 307..328 (7) | 22 | 0.733 | 22..22 |
| `trans21` | 7 | 1 | 353..378 (7) | 26 | 0.867 | 26..26 |
| `transform` | 1 | 1 | 1..134 (1) | 134 | 4.467 | 134..134 |
| `unprepare0` | 92 | 15 | 504..505 (17) | 2 | 0.067 | 2..23 |
| `unprepare1` | 28 | 4 | 380..405 (16) | 26 | 0.867 | 2..27 |
| `unprepare2` | 7 | 1 | 153..154 (7) | 2 | 0.067 | 2..2 |
| `walk` | 124 | 22 | 1..24 (58) | 24 | 0.800 | 16..280 |
| `walk0` | 34 | 2 | 26..49 (24) | 24 | 0.800 | 24..24 |
| `walk2` | 12 | 6 | 1..24 (7) | 24 | 0.800 | 24..93 |
| `walk_` | 1 | 1 | 143..166 (1) | 24 | 0.800 | 24..24 |
| `walk_to_idle` | 9 | 8 | 120..149 (2) | 30 | 1.000 | 20..31 |
| `walkfood` | 8 | 2 | 257..276 (7) | 20 | 0.667 | 20..20 |
| `walkprepare0` | 34 | 3 | 50..73 (24) | 24 | 0.800 | 24..25 |
| `walkstone` | 8 | 1 | 43..62 (8) | 20 | 0.667 | 20..20 |
| `walkunprepare0` | 34 | 3 | 74..97 (24) | 24 | 0.800 | 24..25 |
| `walkwood` | 8 | 1 | 22..41 (8) | 20 | 0.667 | 20..20 |
| `workfood` | 8 | 3 | 278..299 (6) | 22 | 0.733 | 22..24 |
| `workstone` | 8 | 1 | 217..234 (8) | 18 | 0.600 | 18..18 |
| `workwood` | 8 | 1 | 237..254 (8) | 18 | 0.600 | 18..18 |

### 3.4 Identical-range groups (observed)

The single most-shared exact ranges are the canonical "family" timelines:

| Exact range | Action | Files | Duration | Typical families |
|---|---|---:|---:|---|
| `1..24` | `walk` | 58 | 0.800 s | pikeman, archer, musketeer, grenadier, officer, serdiuk, … |
| `1..90` | `idle` | 52 | 3.000 s | infantry/cavalry families |
| `26..49` | `walk0` | 24 | 0.800 s | armed-state walk |
| `49..119` | `death` | 28 | 2.367 s | cavalry/most infantry |
| `505..589` | `idle` | 30 | 2.833 s | `dragoon*`, `hussar`, `hetman`, `cossacksich`, … |
| `433..495` | `death` | 22 | 2.100 s | grenadier/musketeer/serdiuk family |
| `204..254` | `idle0` | 23 | 1.700 s | armed-state idle |
| `256..305` | `idle1` | 24 | 1.667 s | weapon-1 idle |
| `504..505` | `prepare0` / `unprepare0` | 17 / 17 | 0.067 s | 2-frame state markers |
| `186..198` | `construct` | 8 | 0.433 s | peasant family (all 8 nation variants) |
| `217..234` / `237..254` / `278..299` | `workstone` / `workwood` / `workfood` | 8 each | 0.600 / 0.600 / 0.733 s | peasant family |
| `1..280` | `idle`/`walk`/`death`/`attack0` | 9–10 each | 9.333 s | naval: `battleship`, `chaika`, `ferry`, `fishboat`, `frigate`, `galley`, `xebec`, `yacht`, `yachttur` (+ `bui` idle) |

**Grouping rule (derived):** all 246 `.aaf` files share a small set of *timeline
templates*; the 62 names are suffixes on those templates. A port builder should
never assume a name implies a frame range — always read the sid's own `.aaf`.

### 3.5 Outliers (observed/derived)

**185 exact-range groups** have a span different from their name's modal span. Notable:

1. **Full-timeline aliases** — nine naval AAFs (`battleship`, `chaika`, `ferry`,
   `fishboat`, `frigate`, `galley`, `xebec`, `yacht`, `yachttur`) define `idle`,
   `walk`, `death`, `attack0` all as `1..280` (9.333 s). One `bui.aaf` adds an
   `idle 1..280`. These are NOT short loops.
2. **Static artillery** — `cannon`, `framegun`, `howitzer`, `mortar`, `multicannon`
   have `idle 1..1` (0.033 s) while `walk` is still a real `1..99` (3.3 s)
   (`data/animations/aaf/cannon.aaf:3-4`).
3. **2-frame state stubs** — `prepare0/unprepare0/prepare2/unprepare2/attack2`,
   `trans01/trans10` sometimes resolve to 2 frames (e.g. `archer.aaf:10-15`
   `28..29` / `77..78`; `peaukr.aaf:19-20` `64..65`). These look like
   execute-state markers, not visible motion (**inferred**; ACL `actExecuteState`
   items support this, `cannon.acl:33-45`).
4. **Commented-out duplicate** — six `grenadier*` AAFs carry
   `//"attack2",630,679,morph` at line 33, excluded from the declared count;
   the active `attack2` is `153..154` and the real long action is split into
   `attack2before 630..663` / `attack2after 664..679` (`grenadier.aaf:23,31-32`).
5. **Single-use names** — `attack0full 168..197`, `attack0v1 168..184`,
   `attackpause0 166..182`, `walk_ 143..166`, `next 308..331`, `rope 195..229`,
   `fly 230..299`, `transform 1..134`, `idle_open 80..81`, `idle_closed 83..84`,
   `idle0_rest`/`idle1_rest 335..402` (balloon/building attach families).
6. **One-off long outlier** — `walk2 193..285` (3.1 s) and `walk2 181..269`,
   `walk2 170..249` in a few cavalry AAFs vs the modal 24-frame `walk2 1..24`.

---

## 4. State → AAF action-name chain (donor-authored)

### 4.1 The chain, end to end

```
data/objects/units/<sid>.prop
  frameanimationproperty : section.begin
     FrameAnimationCyclesLibName = <lib-name>       ; peaukr.prop:54 -> peaukr
                                                    ; archer.prop:19 -> archer
        |
        v
data/animations/acl/acl.lib  (Name -> FileName)
  Name = peaukr -> .\data\animations\acl\peasant.acl   ; acl.lib:238-239
  Name = pikeman -> ...\infantry.acl                   ; acl.lib:2-3
  Name = archer -> ...\infantryarcher.acl              ; acl.lib:6-7
  Name = cannon -> ...\cannon.acl                      ; acl.lib:22-23
  Name = cossackdon -> ...\hardhorse.acl               ; acl.lib:34-35
  Name = cossacksich -> ...\fasthorse.acl              ; acl.lib:42-43
        |
        v
data/animations/acl/<lib>.acl
  From = <AAF action name> / Name = <clip name>       ; cannon.acl:3-4,10-11,17-18
  items[0].AnimationName = <AAF action name>          ; cannon.acl:7,14,83
  Action = actAnimation; AnimationName = attack0      ; cannon.acl:38-40
  NumberCycle = 1 ; CyclesList = False                ; cannon.acl:40,19
  acoSmoothAnimation / acoRandomFrame /
  acoRandomCycle / acoSkipActions                     ; cannon.acl:21-24
        |
        v
names are declared in data/scripts/dmscript.global:868-926
  gc_anim_idle = 'idle' ... gc_anim_construct = 'construct'
        |
        v
state selection: data/scripts/lib/unit.script:10856-11090
                data/scripts/units/unit.inc/ontagstates.inc:302-589
        |
        v
data/actors/units/<sid>.actor:4-6
  Animations.LoadFromFile = .\data\animations\aaf\<sid>.aaf
  ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile = ...\<sid>.oss
        |
        v
engine API (called from readable scripts; implementation UNVERIFIED)
  GetGameObjectFrameAnimationDataByHandle(hnd, anim, sf, ef)   ; unit.script:10774,369-373
  GameObjectSwitchToTreeAnimationCyclesBlendByHandle(...)      ; unit.script:10891,11016,...
  SetGameObjectAnimationCyclesModeByHandle(hnd, 'acmPlayOnce'|'acmLoop'|'acmNone')
                                                               ; movie.script:648-656
```

**Labels:** every arrow above is **observed** text in a donor file except the final
engine API box, whose *existence/signature* is observed in script calls but whose
*implementation* is **UNVERIFIED** (compiled donor code was not executed).

### 4.2 State → name mapping (observed, donor script)

`data/scripts/dmscript.global:868-926` declares the canonical name constants.
The selection logic in `data/scripts/lib/unit.script` and
`data/scripts/units/unit.inc/ontagstates.inc` is:

| Donor state / tag | AAF action name | Citation |
|---|---|---|
| `gc_statetag_action_extract` + `resource_food` | `workfood` | `unit.script:10865-10873` / `ontagstates.inc:302` |
| `gc_statetag_action_extract` + `resource_wood` | `workwood` | `unit.script:10872` / `ontagstates.inc:306` |
| `gc_statetag_action_extract` + `resource_stone` | `workstone` | `unit.script:10873` / `ontagstates.inc:310` |
| `gc_statetag_action_build` | `construct` | `unit.script:10877` / `ontagstates.inc:318` |
| `gc_statetag_action_attack` + weapon none/0/1/2 | `attack0` / `attack1` / `attack2` | `unit.script:10878-10883` / `ontagstates.inc:323-325` |
| `weapon_none` + move idle/turn | `idle` | `unit.script:10928-10932` / `ontagstates.inc:399-401` |
| `weapon_none` + move walk | `walk` | `unit.script:10932` / `ontagstates.inc:401` |
| `weapon_0` + idle/turn/walk | `idle0` / `walk0` | `unit.script:10935-10940` / `ontagstates.inc:406-408` |
| `weapon_1` + idle/turn/walk | `idle1` / `walk1` | `unit.script:10942-10947` / `ontagstates.inc:413-415` |
| `weapon_2` + idle/turn/walk | `idle2` / `walk2` | `unit.script:10949-10954` / `ontagstates.inc:420-422` |
| resource carried + idle/turn/walk | `idlefood`/`idlewood`/`idlestone`, `walkfood`/`walkwood`/`walkstone` | `unit.script:10900-10921` / `ontagstates.inc:372-388` |
| transition from weapon-state N | `trans01`/`trans10`/`trans02`/`trans20`/`trans12`/`trans21` | `unit.script:10977-10980,11026-11029` / `ontagstates.inc:435-437,485-487` |
| `essential_death` + weapon none/0/1/2 | `death` / `death0` / `death1` / `death2` | `unit.script:11086-11093` / `ontagstates.inc:583-589` |

Important detail (**observed**): when a preferred name is missing from the unit's
AAF, the donor falls back — e.g. `_unit_IsAnimationExists(hnd, animwalk)` else
`gc_anim_walk` (`unit.script:11048-11051`), and weapon-specific death falls back
to plain `death` (`:11092-11093`). A port using a hard-coded name will diverge on
units whose AAF lacks that name.

Attached peasant tools are selected by the *same action name*:
`unit.script:6993-7009` maps `gc_anim_workfood → gc_actor_peasant_hoe`,
`workwood → axe`, `workstone → pick`, `construct → hammer`, and the peasant
family's `walkfood/idlefood → bag`, `walkwood/idlewood → lumber`,
`walkstone/idlestone → cart`. Runtime call: `_unit_ManagePeasantAttach(hnd, anim)`
(`unit.script:11068-11069`). Port currently skins only the body (V764 §6 Q3).

### 4.3 How `morph` rows and transitions are consumed

- **AAF consumption by name (observed):** `GetGameObjectFrameAnimationDataByHandle`
  is called with the action-name string (`unit.script:369-373,10774,2622`;
  `movie.script:857`). It returns `sf, ef`. That is the donor engine's direct read
  of the inclusive AAF range.
- **The literal flag `morph` is never referenced in readable donor text** (0 hits
  across 2,816 script/config files, M2). Its consumption is **engine-side and
  UNVERIFIED**; only the AAF decoder (DEC-04 §4.3) establishes the token.
- **Loop / one-shot (observed, donor-authored, not in AAF):**
  - `data/gui/menu.inc/showdebuganimations.inc:45-66` takes a `bPlayOnce` boolean;
    attacks and deaths are created with `True` (`:121-123,129-131`), walks/idles/
    work/construct with `False` (`:113-120,136-155`).
  - `data/scripts/lib/movie.script:648-656` sets `acmPlayOnce` / `acmLoop` /
    `acmNone` via `SetGameObjectAnimationCyclesModeByHandle`.
  - `data/scripts/lib/unit.script:10808-10809,10852` sets `acmPlayOnce` +
    `aamPlayOnce` for death; `:11079-11080` sets `acmNone`/`aamNone` when hidden.
  - ACL carries `CyclesList = False` and `acoSmoothAnimation`, `acoRandomFrame`,
    `acoRandomCycle`, `acoSkipActions` options (`cannon.acl:19-24`; 2,316 such
    hits across 30 ACL files).
  - **Conclusion (derived):** DEC-04's "AAF has no loop flag" is correct, but the
    *port's* `fposmod` loop (`anim3d.gd:582-588`) is an approximation of a policy
    the donor actually authors elsewhere. One-shot `death`/`attack` should clamp
    or signal completion rather than wrap.
- **Blend / interpolation (observed, donor-authored):**
  - `minFrameBlend = 6`, `maxFrameBlend = 8` at `unit.script:10846-10847`;
    installed per object via `SetGameObjectMinFrameBlendByHandle(...,6)` /
    `SetGameObjectMaxFrameBlendByHandle(...,8)` / `SetGameObjectDeferredFrameBlendByHandle(...,false)`
    at `scripts/units/unit.inc/initial.inc:17-19`; same constants at
    `unit.script:10846-10847` and `ontagstates.inc:263-264`.
  - Passed into transitions as `GameObjectSwitchToTreeAnimationCyclesBlendByHandle(..., minFrameBlend, maxFrameBlend)`
    (`unit.script:10970,11016,11055,11100`; `ontagstates.inc:474,513,596`).
  - Some transitions deliberately pass `0, 0` with the comment "dont use blend cause
    it kills animation" (`unit.script:10891-10892,11042`).
  - **UNVERIFIED:** whether these frame-blend numbers mean linear pose interpolation,
    cross-fade, or a state-machine delay — the engine implementation is not readable.
    The port's nearest exported frame (`anim3d.gd:893-912`) has **no** interpolation.

---

## 5. Concrete clip table for the `anim3d.gd` owner

`first..last` inclusive; `dur = (last-first+1)/30`. Donor paths are relative to
`C:\Games\Cossacks 3`. `port status` refers to the shipped skin index (S9):
**SUBSET** = the sid has a `c3_skin_v1` asset with a donor-order sampled frame set;
**DONOR-ONLY** = readable AAF but no shipped skin asset.

| unit_family (port sid) | donor action name | first..last | duration s | donor path:line | port status |
|---|---|---:|---:|---|---|
| peasant (`peaukr`) | idle | 64..113 | 1.667 | `data/animations/aaf/peaukr.aaf:3` | SUBSET |
| peasant (`peaukr`) | walk | 1..20 | 0.667 | `data/animations/aaf/peaukr.aaf:5` | SUBSET |
| peasant | death | 115..149 | 1.167 | `data/animations/aaf/peaukr.aaf:6` | SUBSET |
| peasant | attack0 | 237..254 | 0.600 | `data/animations/aaf/peaukr.aaf:7` | SUBSET |
| peasant | workfood | 278..299 | 0.733 | `data/animations/aaf/peaukr.aaf:8` | SUBSET |
| peasant | workwood | 237..254 | 0.600 | `data/animations/aaf/peaukr.aaf:9` | SUBSET |
| peasant | workstone | 217..234 | 0.600 | `data/animations/aaf/peaukr.aaf:10` | SUBSET |
| peasant | construct | 186..198 | 0.433 | `data/animations/aaf/peaukr.aaf:17` | SUBSET |
| pikeman | idle | 209..258 | 1.667 | `data/animations/aaf/pikeman.aaf:11` | SUBSET |
| pikeman | walk | 1..24 | 0.800 | `data/animations/aaf/pikeman.aaf:3` | SUBSET |
| pikeman | attack0 | 32..46 | 0.500 | `data/animations/aaf/pikeman.aaf:4` | SUBSET |
| pikeman | death | 80..134 | 1.833 | `data/animations/aaf/pikeman.aaf:6` | SUBSET |
| archer | idle | 28..78 | 1.700 | `data/animations/aaf/archer.aaf:4` | SUBSET |
| archer | walk | 1..24 | 0.800 | `data/animations/aaf/archer.aaf:3` | SUBSET |
| archer | attack0 / attack1 | 130..157 | 0.933 | `data/animations/aaf/archer.aaf:8-9` | SUBSET |
| archer | death | 80..129 | 1.667 | `data/animations/aaf/archer.aaf:7` | SUBSET |
| musketeer | idle | 153..202 | 1.667 | `data/animations/aaf/musketeer.aaf:8` | SUBSET |
| musketeer | walk | 1..24 | 0.800 | `data/animations/aaf/musketeer.aaf:3` | SUBSET |
| musketeer | attack1 | 99..124 | 0.867 | `data/animations/aaf/musketeer.aaf:7` | SUBSET |
| musketeer | death | 433..495 | 2.100 | `data/animations/aaf/musketeer.aaf:17` | SUBSET |
| grenadier | idle | 153..202 | 1.667 | `data/animations/aaf/grenadier.aaf:10` | SUBSET |
| grenadier | walk | 1..24 | 0.800 | `data/animations/aaf/grenadier.aaf:3` | SUBSET |
| grenadier | attack0 | 126..141 | 0.533 | `data/animations/aaf/grenadier.aaf:9` | SUBSET |
| grenadier | death | 433..495 | 2.100 | `data/animations/aaf/grenadier.aaf:19` | SUBSET |
| cossack (`cossacksich`) | idle | 505..589 | 2.833 | `data/animations/aaf/cossacksich.aaf:3` | SUBSET |
| cossack | walk | 1..48 | 1.600 | `data/animations/aaf/cossacksich.aaf:6` | SUBSET |
| cossack | attack0 | 592..604 | 0.433 | `data/animations/aaf/cossacksich.aaf:8` | SUBSET |
| cossack | death | 50..119 | 2.333 | `data/animations/aaf/cossacksich.aaf:7` | SUBSET |
| dragoon (`dragoon18`) | idle | 505..589 | 2.833 | `data/animations/aaf/dragoon18.aaf:3` | SUBSET |
| dragoon | walk | 614..637 | 0.800 | `data/animations/aaf/dragoon18.aaf:6` | SUBSET |
| dragoon | attack0 | 592..604 | 0.433 | `data/animations/aaf/dragoon18.aaf:8` | SUBSET |
| dragoon | death | 49..119 | 2.367 | `data/animations/aaf/dragoon18.aaf:7` | SUBSET |
| cannon | idle | 1..1 | 0.033 | `data/animations/aaf/cannon.aaf:3` | SUBSET |
| cannon | walk | 1..99 | 3.300 | `data/animations/aaf/cannon.aaf:4` | SUBSET |
| cannon | attack0 / attack1 | 301..337 | 1.233 | `data/animations/aaf/cannon.aaf:5-6` | SUBSET |
| hussar | idle | 505..589 | 2.833 | `data/animations/aaf/hussar.aaf:3` | SUBSET |
| hussar | walk | 1..16 | 0.533 | `data/animations/aaf/hussar.aaf:5` | SUBSET |
| hussar | attack0 | 592..605 | 0.467 | `data/animations/aaf/hussar.aaf:7` | SUBSET |
| hetman | walk | 614..637 | 0.800 | `data/animations/aaf/hetman.aaf:5` | SUBSET |
| hetman | attack0 | 640..654 | 0.500 | `data/animations/aaf/hetman.aaf:7` | SUBSET |
| yacht (naval) | idle / walk / death / attack0 | 1..280 | 9.333 | `data/animations/aaf/yacht.aaf:3-6` | DONOR-ONLY |
| galley (naval) | idle / walk / death / attack0 | 1..280 | 9.333 | `data/animations/aaf/galley.aaf:3-6` | DONOR-ONLY |
| battleship (naval) | idle / walk / death / attack0 | 1..280 | 9.333 | `data/animations/aaf/battleship.aaf:3-6` | DONOR-ONLY |

**Builder notes (observed/derived):**

- The port already carries the correct per-sid AAF ranges in each shipped
  `variant3d/assets/models/skin/<sid>.json` (`actions` map + `frames` subset),
  generated by `variant3d/tools/convert_skins.py:200-217` from the donor AAF;
  `anim3d.gd:_action_range_for:918-934` reads them and ignores its legacy
  peaukr-only table when a compact skin is registered. **No hard-coded ranges
  should be added for the 55 shipped sids** — this table is the verification truth.
- Port aliases: `attack → attack0` at `anim3d.gd:94-96` matches donor
  `gc_statetag_weapon_none/0 → attack0` (`unit.script:10880`), but donor also has
  `attack1` (weapon 1) and `attack2` (weapon 2) — currently unmapped by the port.
- The renderer's coarse state map (`V774:506-517`: `dead→death`, `moving→walk`,
  else `idle`) covers only 3 of 62 names. Donor's real map (§4.2) is the upgrade path.

---

## 6. Bind-pose verification (second method) — DEC-04 corrected

### 6.1 What DEC-04 claimed

`DEC_04:422-441` claims DEEPDEC-06 F4 ("frame 0 is an exact bind pose for every
bone") is **false for multi-bone unit files**, reporting for `peaukr.oss`:
`max|p| @f0 = 0.09912 m`, `max|q-I| @f0 = 0.01189`, "best identity frame = 4";
and that **0 of 22 `b=20` files** have frame-0 identity while 175/335 do.

### 6.2 Verification — two independent methods, both contradict DEC-04

**Method A (sequential reader + two rotation implementations).** I re-read the
donor `.oss` with the exact `struct.unpack` sequence of `bake_sprites.py:91-103`
(bone-major `anim[bone][frame]`), then:

- cross-checked my quaternion→matrix implementation against the Hamilton product
  `q · (v,0) · q⁻¹` on `peaukr` bone 3 frame 7 — max difference `4.57e-8`;
- applied both the row-vector (transposed, `bake_sprites.qmat:118-129`) and textbook
  column-vector rotations, forms `Σw(R·v+p)` and `Σw(R·(v−p)+p)`.

Measured at stored frame index 0 (all bones):

| File | b | max `|p|` @f0 | max `|q-I|` @f0 | skin displacement @f0 (max / mean) |
|---|---:|---:|---:|---:|
| `peaukr.oss` | 20 | `1.49e-7 m` | `2.25e-8` | `1.52e-7 / 7.35e-8 m` |
| `pikeman.oss` | 20 | `2.39e-7 m` | `2.28e-8` | `2.42e-7 / 5.16e-8 m` |
| `yacht.oss` | 20 | `2.39e-7 m` | `1.53e-8` | `2.42e-7 / 5.55e-8 m` |
| `cossackdon.oss` | 16 | `3.37e-7 m` | `1.63e-8` | `3.60e-7 / 9.37e-8 m` |
| `ausbaranim.oss` | 10 | `9.83e-7 m` | `4.66e-10` | `9.83e-7 / 4.22e-7 m` |
| `eurgolanim.oss` | 7 | `3.37e-7 m` | `2.33e-10` | `3.37e-7 / 1.53e-7 m` |

These reproduce DEEPDEC-06 F4's `1.6e-7 m` peaukr figure (float32 noise) and
**contradict** DEC-04's `0.09496 m` / `0.09912 m` figures.

**Method B (whole-family bone-major offset-seek census).** For all **335** `.oss`
files I computed the exact anim-block offset
`base = 24 + v·12 + fc·12 + t·8 + fc·12 + Σ_v(4+8·nᵢ)`, then read record
`bone·k + 0` for each bone (the **bone-major** layout documented at `DEC_04:135`
and `bake_sprites.py:102`). Result:

- **335/335** files have frame-0 identity: max over all files `|p| = 1.09e-6 m`,
  `|q-I| = 3.02e-8`.
- Identity by bone count: `b=1` 124/124, `b=20` **22/22**, `b=24` 43/43,
  and every other b bucket 100% — directly refuting DEC-04's "0 of the 22
  `b=20` files".

**Method C (diagnostic — cause of the discrepancy).** Reading the first `b`
*contiguous* records as "frame 0 of all bones" (i.e. treating the track block as
frame-major) returns, for `peaukr`, `max|p| = 0.101292 m`, `max|q-I| = 0.015791`
— close to DEC-04's `0.09912 / 0.01189` — and reproduces the exact identity
pattern DEC-04 reported (`b=1` 124/124, `b=20` 0/22, `b=13` 20/23). The reported
numbers are therefore an **indexing artifact**, not donor data.

### 6.3 What this means

- **CONFIRMED (observed, two methods):** stored frame 0 is the bind pose for all
  335 `.oss` files; DEEPDEC-06 F4/F5 stand. Bone-parent absence (DEC-04 §6.1) is
  real, but parents are **pre-folded** into the absolute per-bone transforms —
  a joint hierarchy is **not** required to reproduce the readable deformation.
- **CONFIRMED (derived):** the shipped skin equation `Σw(R_row(q)·v + p)`
  (`bake_sprites.py:118-143`, mirrored at `anim3d.gd:410-459`) reproduces the
  stored bind vertices at frame 0 to float32 noise. DEC-04 P2's `1.6e-7 m` is
  reproducible; its "not reproducible" claim (DEC_04:447) is retracted by this pass.
- **Still UNVERIFIED:** which of forms (1)/(2)/(3) the donor *engine* uses at
  non-bind frames; the donor→glTF/Godot quaternion convention; any rendered A/B.
  The row-vector transpose remains donor-backed by the baker's bone-by-bone
  validation (`bake_sprites.py:119-123`), not by a rendered frame comparison.
- **What remains possible (honest):** CPU-sampled flat-root posed vertices per
  donor frame (already implemented in `anim3d.gd` and consumed by
  `world3d_entities.gd`, V764/V774/V779) — donor geometry + donor sampled poses,
  **PORT APPROXIMATION — NOT DONOR PARITY**, visual UNVERIFIED. No invented rig.

---

## 7. Corrections to prior docs

| Prior claim | Verdict this pass | Evidence |
|---|---|---|
| DEC-04 §6.1 "frame 0 is NOT bind for multi-bone files"; peaukr `0.09912 m / 0.01189`, best frame 4 | **REFUTED** (frame-major misread of bone-major tracks) | §6.2 methods A/B/C; 335/335 identity |
| DEC-04 §6.1 "P2's 1.6e-7 m not reproducible" | **REFUTED** — reproduced (`1.52e-7 m`) | §6.2 method A |
| DEC-04 §6.1 "0 of 22 `b=20` files have frame-0 identity" | **REFUTED** — 22/22 do | §6.2 method B |
| DEC-04 §4.3 "1,434 rows all `morph`, 246/246 parse" | **CONFIRMED**, refined: 6 commented rows in 6 grenadier AAFs + 218 trailing blank lines are excluded from the count | §3.1 |
| DEC-04 §6.3 duration `(last-first+1)/30` | **CONFIRMED**; refined: donor movie script uses exclusive `(ef-sf)/30` | §3.2, `movie.script:857-858` |
| DEEPDEC-06 F4/F5 frame-0 bind / absolute tracks | **CONFIRMED** (deformation-data level) | §6.2 |
| V7-2 Table B1 "donor-faithful skin BLOCKED by missing bone parents" | **Refined, as DEEPDEC-06 already argued:** absence confirmed, blockage for deformation data removed; only semantics/visual remain UNVERIFIED | §6.3 |
| V764/V774 "733/733 verts changed" | **Confirmed interpretation** (DEC-04 §6.2): 733 = OBJ `vt`/de-indexed corners; donor morph = 577 verts | S1, S3, DEC-04 §6.2 |
| `anim3d.gd` `AAF_ACTIONS` peaukr table | **Confirmed exact** against `peaukr.aaf:3-20` (all 18 names/ranges) | `anim3d.gd:71-90`; §3.3 |

---

## 8. Port implications (no edits made)

1. **Do not hard-code ranges for the 55 shipped sids.** `anim3d.gd:918-934`
   already prefers each unit's own AAF ranges embedded in the compact skin by
   `convert_skins.py`. Use §5 as an *audit* of those ranges.
2. **Beat-accurate state mapping.** The current 3-state map (`dead/moving/idle`)
   misses ~59 donor names. The donor map in §4.2 is readable and can be ported
   verbatim: `workfood/workwood/workstone`, `construct`, `attack0/1/2`,
   `prepare*/unprepare*`, `trans*`, `death0/1/2`, `idle0/1/2`, `walk0/2`,
   resource-carrying variants. Gate each name with an existence check like the
   donor's `_unit_IsAnimationExists` (`unit.script:369-373`) — many units lack them.
3. **One-shot handling is a real donor behaviour, not a port invention.** Clamp
   `death`/`attack*` at `last` (or fire a completion signal) instead of
   `fposmod` wrap; donor sets `acmPlayOnce`/`aamPlayOnce` for death
   (`unit.script:10808-10809,10852`) and `NumberCycle = 1` for attacks
   (`cannon.acl:40,72`).
4. **Frame blending is donor-authored but not reproducible exactly without the
   engine**: `minFrameBlend=6 / maxFrameBlend=8` (`unit.script:10846-10847`,
   `unit.inc/initial.inc:17-19`) and ACL `acoSmoothAnimation`. The nearest-exported
   snap (`anim3d.gd:893-912`) is an honest approximation; any port interpolation
   would be a new policy, not a donor copy.
5. **Nothing here unblocks a rendered visual-parity claim.** Bind pose is now
   double-verified, but quaternion convention for the Y-up entity and a donor
   render A/B remain **UNVERIFIED**. Keep `PORT APPROXIMATION — NOT DONOR PARITY`
   and `visual = "UNVERIFIED"` exactly as they are.
6. **Attached tools still matter for peasants** (§4.2): the donor switches a
   separate single-bone `.oss` by the same action name; the port body-only morph
   is an explicit approximation (V764 §6 Q3).

---

## 9. Open questions

1. **Engine consumption of `morph`** — the flag has 0 readable script/config hits.
   Is it only a binary decoder tag, or does the engine pick a different skinning
   path for it? Needs donor code or a runtime trace (not performed).
2. **ACL `items[n].Action` semantics** (`actAnimation`, `actTrackPoint`,
   `actExecuteState`) — data-level only; mapping to playback UNVERIFIED (DEC-04 Q4).
3. **Frame-blend meaning** — do `6/8` frames mean cross-fade, delay, or
   interpolation? Donor engine implementation UNVERIFIED.
4. **Yaw** — still no donor citation for discrete 8-way vs continuous renderer
   transform; DEC-04 §7 and V7-2 open question 7 unchanged.
5. **One-shot completion** — should the port clamp at `last` and hold, or return
   to idle as the donor state machine does (`unit.script:11021-11043`)?
6. **Missing-name fallback** — port should mirror `_unit_IsAnimationExists`
   fallbacks (`attack2 → death`, `walk1 → walk`, …). Which fallbacks to keep for
   the 55 shipped sids is an owner decision.
7. **Buildings/naval** — 52 `.aaf` are under `aaf/pfx/` and naval AAFs are
   `1..280`; none of the 55 shipped skins cover them. Scope decision, not a
   data gap.
8. **Visual A/B and GLES3 skinning perf** — unchanged from DEC-04 §7/V7-2 C11.

---

## 10. Summary

- **Catalog (observed):** 246 `.aaf` files, 1,434 active rows, **62 action names**,
  all flagged `morph`, 0 other flags; 6 commented-out rows and 218 trailing blank
  lines accounted for. Duration is `(last-first+1)/30` s (inclusive), cross-checked
  against donor engine code; the movie helper uses the exclusive variant.
- **Chain (observed):** `.prop FrameAnimationCyclesLibName` → `acl.lib` → ACL
  `From/Name/AnimationName` → `dmscript.global gc_anim_*` → `unit.script` /
  `ontagstates.inc` state map → `.actor` AAF load → engine
  `GetGameObjectFrameAnimationDataByHandle(hnd, anim, sf, ef)`. Loop/one-shot and
  blend policy are authored in scripts/ACL, **not** in AAF.
- **Correction (confirmed by two methods + diagnostic):** DEC-04's frame-0
  refutation is wrong — it read bone-major tracks as frame-major. **335/335**
  `.oss` files have frame-0 identity (max `1.09e-6 m` / `3.02e-8`); DEEPDEC-06
  F4/F5 and the 1.6e-7 m skin reproduction stand. Bone parents are absent but
  pre-folded, so flat-root sampled poses remain the defensible donor-derived path.
- **Deliverable to builder:** §5 clip table (peasant/pikeman/archer/musketeer/
  grenadier/cossack/dragoon/cannon/hussar/hetman/naval) plus §4.2 full state map;
  use per-sid AAF ranges already embedded in shipped skins, add existence-check
  fallbacks, clamp one-shot actions, and keep the approximation label.

No donor file was executed or copied; no repo file other than this report was
written; no Godot/Blender/runner job was started. Temporary analysis scripts lived
only in the approved system temp folder (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode`),
not in the repository. All donor facts above cite a donor `path:line`, a donor
`path:offset`, or a prior evidence id.
