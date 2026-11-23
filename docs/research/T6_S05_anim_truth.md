# T6-S05 — Per-action animation truth for the 5 owner-flagged families

**Ticket:** T6-S05 · **Lane:** RESEARCH · **Role:** micro-worker; output feeds the T6-UNITS bakers directly.
**Date:** 2026-11-23.
**Owned outputs (ONLY these two files):** `docs/research/T6_S05_anim_truth.md` and `docs/t6/reports/T6-S05.md`.
**Boundaries:** private-use licence. Donor (`C:\Games\Cossacks 3`) read-only; no donor file copied into the repo; donor executable never run; no Godot job; no Blender bake; no edit to `app/**`, `rustport/**`, live anim assets, `SWARM_BOARD.md`, `SWARM_OPS.md`, `AGENT_PROTOCOL.md`, other lanes' docs or any donor file.
**Labels:** `observed` = literal file line / parsed byte / field value; `derived` = arithmetic consequence of observed values; `inferred` = plausible reading with caveat; `UNVERIFIED` = not proven by the files read.

**One-line headline:** Across these 5 families there is **exactly one port-vs-donor duration divergence** — `peasant.walk` 0.667 s donor vs **1.08 s port**, a *deliberate port-authored stride fix*, not bad donor truth. Every other port duration in scope is donor-exact. All gaps are **coverage** gaps (unbaked donor actions and one un-baked cavalry mount), not timing errors.

---

## 1. Sources and method

### 1.1 Sources read (all read-only)

| Source | Role |
|---|---|
| `C:\Games\Cossacks 3\data\actors\units\<base>.oss` | 24-byte header `k,fps,bones,verts,faces,uvs` (bytes `0x00..0x17`, six little-endian int32). Format per `docs/decomp/DC_FORMATS.md` §2.1. |
| `C:\Games\Cossacks 3\data\animations\aaf\<base>.aaf` | Plain text `AAF`, action count, then `"name",start,end,morph` lines; **inclusive** bounds. Format per `DC_FORMATS.md` §2.3. |
| `C:\Games\Cossacks 3\data\actors\units\attach\` | Directory enumerated for `<base>_*` files (hand props, manifests, mounts). |
| `app\tools\bake_sprites.py:111-119` | `sample()` — exact decimation formula. |
| `app\tools\bake_sprites.py:220-246` | `bake_unit()` — action plan, name priority, n-frames, loop, and the duration formula `(end-start+1)/fps`. |
| `app\tools\bake_sprites.py:281-303` | `ATTACH_ACTIONS` tool→action map and prop loader path. |
| `app\tools\bake_sprites.py:552-565` | port-key → donor-base table (confirms `peasant→peaukr`, `musk18→musketeer18`, `dragoon→dragoon18`, `cannon→cannon`, `officer→officer`). |
| `app\assets\models\anim\index.json` | Port truth: `peasant` block starts line 2, `musk18` line 814, `officer` line 1082, `dragoon` line 1276, `cannon` line 1373. `peasant.walk.duration = 1.08` at line 7. |
| `docs\UNIT_BAKING_FIX.md` §10, §11.1, §11.2 | Provenance of the 1.08 hand-edit (GUIDE4 DO-L7.06 stride rule); cavalry-mount caveat §7. |
| `docs\decomp\DC_FORMATS.md` §2.1 / §2.3 | OSS header and AAF text layout (read first, as directed). |

### 1.2 Independent re-verification (§5b-QUALITY method rule)

The parent's pre-gathered summary (`%TEMP%\opencode\t6_anim_truth.py`, `struct.unpack` + regex) was **re-derived with a different method** (`%TEMP%\opencode\t6_s05_verify.py`): `int.from_bytes(...,"little",signed=True)` for the header instead of `struct.unpack`; raw-line split on commas instead of regex for the AAF; `os.listdir` enumeration of the attach directory instead of probing known tool names. Command: `python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\t6_s05_verify.py` (Python 3.14; never `python3`).

**Result: full agreement** on all header values, all 18/18/9/4/8 action ranges, all chosen actions, all durations and all sampled-frame counts. The second method additionally yielded: exact AAF line numbers, byte-level header hex, on-disk sizes for all five `.oss` files, UV counts, the exact sampled frame index lists, and three structural observations the parent summary omitted (identical-range action pairs, the `dragoon18_horse` mount, and the `peaukr_tools.actor` manifest). Those additions are marked `observed` below.

### 1.3 Derivation rules

- `derived`: **donor duration = (end − start + 1) / fps**. All five `.oss` headers report `fps = 30` (`observed`, byte `0x04..0x07` = `1E 00 00 00` in every file), so duration in seconds = inclusive frame count ÷ 30.
- `observed`: **port duration** is the literal `duration` value in `index.json`; **port frames** is the literal `frames` value.
- `observed`: the baker's sampled-frame list is `[a+round((b-a)*i/(n-1)) for i in range(n)]` (`bake_sprites.py:118`) when `b-a+1 > n`, else the full inclusive range (`:117`), else `[a]` (`:115`).
- **Important for bakers (`derived`):** port `frames` is the **sampled pose count**, not the donor inclusive frame count. Donor duration is computed from the donor range, **never** reconstructed from port `frames`. Do not "correct" one from the other.

### 1.4 Baker priority list (verbatim from `bake_sprites.py:229-242`, identical for all five families)

| Port action | Donor candidate names, in order | n (sampled frames) | loop |
|---|---|---:|---|
| `walk` | `walk` | 12 | true |
| `idle` | `idle`, `idle0` | 6 | true |
| `attack` | `attack1`, `attack0`, `attack2`, `attack` | 12 | false |
| `workwood` | `workwood` | 10 | true |
| `workfood` | `workfood` | 10 | true |
| `workstone` | `workstone` | 10 | true |
| `construct` | `construct` | 8 | true |
| `walkwood` | `walkwood` | 10 | true |
| `walkfood` | `walkfood` | 10 | true |
| `walkstone` | `walkstone` | 10 | true |
| `idlewood` | `idlewood` | 6 | true |
| `idlefood` | `idlefood` | 6 | true |
| `idlestone` | `idlestone` | 6 | true |
| `death` | `death`, `death0`, `death1` | 8 | false |

Selection is `next((acts[x] for x in names if x in acts), None)` (`:243`) — first present name wins. An action absent from the plan is never baked.

---

## 2. Family tables

### 2.1 `peasant` ← donor base `peaukr`

#### Donor header facts (`observed`)

| Field | Value | Evidence |
|---|---:|---|
| file | `data\actors\units\peaukr.oss` | — |
| k (frames/bone) | 483 | bytes `0x00..0x03` = `E3 01 00 00` |
| fps | 30 | bytes `0x04..0x07` = `1E 00 00 00` |
| bones | 20 | bytes `0x08..0x0B` = `14 00 00 00` |
| verts | 577 | bytes `0x0C..0x0F` = `41 02 00 00` |
| faces | 921 | bytes `0x10..0x13` = `99 03 00 00` |
| uvs | 733 | bytes `0x14..0x17` = `DD 02 00 00` |
| file size | 312,376 B | `os.path.getsize`; closes the DC_FORMATS §2.1 size equation |

AAF header: line 1 `AAF`, line 2 `18` (`observed`). 18 action lines (lines 3–20).

#### Every donor action (`observed` ranges, `derived` durations)

| AAF line | action | start..end | inclusive frames | donor duration (s) |
|---:|---|---:|---:|---:|
| 3 | `idle` | 64..113 | 50 | 1.667 |
| 4 | `idle0` | 64..113 | 50 | 1.667 |
| 5 | `walk` | 1..20 | 20 | 0.667 |
| 6 | `death` | 115..149 | 35 | 1.167 |
| 7 | `attack0` | 237..254 | 18 | 0.600 |
| 8 | `workfood` | 278..299 | 22 | 0.733 |
| 9 | `workwood` | 237..254 | 18 | 0.600 |
| 10 | `workstone` | 217..234 | 18 | 0.600 |
| 11 | `idlefood` | 405..454 | 50 | 1.667 |
| 12 | `idlewood` | 354..403 | 50 | 1.667 |
| 13 | `idlestone` | 303..352 | 50 | 1.667 |
| 14 | `walkfood` | 257..276 | 20 | 0.667 |
| 15 | `walkwood` | 22..41 | 20 | 0.667 |
| 16 | `walkstone` | 43..62 | 20 | 0.667 |
| 17 | `construct` | 186..198 | 13 | 0.433 |
| 18 | `reaction` | 456..481 | 26 | 0.867 |
| 19 | `prepare0` | 64..65 | 2 | 0.067 |
| 20 | `unprepare0` | 64..65 | 2 | 0.067 |

> `observed` structural facts: `attack0` (line 7) and `workwood` (line 9) are **byte-identical ranges** `237..254`; `idle` and `idle0` are both `64..113`; `prepare0` and `unprepare0` are both `64..65`. The baker therefore renders the same donor motion for `attack` and `workwood` but samples them at n=12 vs n=10 and attaches different tools (§3).

#### Chosen-action mapping, sampled frames, port values, delta

| Port action | chosen donor action | donor range | sampled frames (`observed` list from `sample()`) | # | port frames | port dur (s) | donor dur (s) | loop | tool | Δ |
|---|---|---|---|---:|---:|---:|---:|---|---|---|
| `walk` | `walk` | 1..20 | `1,3,4,6,8,10,11,13,15,17,18,20` | 12 | 12 | **1.08** | 0.667 | true | null | **+0.413 deliberate fix** |
| `idle` | `idle` | 64..113 | `64,74,84,93,103,113` | 6 | 6 | 1.667 | 1.667 | true | null | 0 |
| `attack` | `attack0` | 237..254 | `237,239,240,242,243,245,246,248,249,251,252,254` | 12 | 12 | 0.600 | 0.600 | false | axe | 0 |
| `workwood` | `workwood` | 237..254 | `237,239,241,243,245,246,248,250,252,254` | 10 | 10 | 0.600 | 0.600 | true | axe | 0 |
| `workfood` | `workfood` | 278..299 | `278,280,283,285,287,290,292,294,297,299` | 10 | 10 | 0.733 | 0.733 | true | hoe | 0 |
| `workstone` | `workstone` | 217..234 | `217,219,221,223,225,226,228,230,232,234` | 10 | 10 | 0.600 | 0.600 | true | pick | 0 |
| `construct` | `construct` | 186..198 | `186,188,189,191,193,195,196,198` | 8 | 8 | 0.433 | 0.433 | true | hammer | 0 |
| `walkwood` | `walkwood` | 22..41 | `22,24,26,28,30,33,35,37,39,41` | 10 | 10 | 0.667 | 0.667 | true | lumber | 0 |
| `walkfood` | `walkfood` | 257..276 | `257,259,261,263,265,268,270,272,274,276` | 10 | 10 | 0.667 | 0.667 | true | bag | 0 |
| `walkstone` | `walkstone` | 43..62 | `43,45,47,49,51,54,56,58,60,62` | 10 | 10 | 0.667 | 0.667 | true | cart | 0 |
| `idlewood` | `idlewood` | 354..403 | `354,364,374,383,393,403` | 6 | 6 | 1.667 | 1.667 | true | lumber | 0 |
| `idlefood` | `idlefood` | 405..454 | `405,415,425,434,444,454` | 6 | 6 | 1.667 | 1.667 | true | bag | 0 |
| `idlestone` | `idlestone` | 303..352 | `303,313,323,332,342,352` | 6 | 6 | 1.667 | 1.667 | true | cart | 0 |
| `death` | `death` | 115..149 | `115,120,125,130,134,139,144,149` | 8 | 8 | 1.167 | 1.167 | false | null | 0 |

`peasant.walk.duration = 1.08` is at `index.json:7` (`observed`). The 8 national-peasant variants (`ukr_`/`rus_`/`pol_`/`aus_`/`eng_`/`spa_`/`tur_`/`sco_peasant`) carry the same 1.08 fix per `UNIT_BAKING_FIX.md` §11.2, but they are **not** among this ticket's 5 families.

---

### 2.2 `musk18` ← donor base `musketeer18`

#### Donor header facts (`observed`)

| Field | Value | Evidence |
|---|---:|---|
| file | `data\actors\units\musketeer18.oss` | — |
| k | 630 | bytes `0x00..0x03` = `76 02 00 00` |
| fps | 30 | `1E 00 00 00` |
| bones | 20 | `14 00 00 00` |
| verts | 809 | `29 03 00 00` |
| faces | 1,074 | `32 04 00 00` |
| uvs | 1,013 | `F5 03 00 00` |
| file size | 406,280 B | `os.path.getsize` |

AAF header lines 1–2: `AAF`, `18` (`observed`). 18 action lines (3–20).

#### Every donor action

| AAF line | action | start..end | incl. frames | donor dur (s) |
|---:|---|---:|---:|---:|
| 3 | `walk` | 1..24 | 24 | 0.800 |
| 4 | `walk0` | 26..49 | 24 | 0.800 |
| 5 | `walkprepare0` | 50..73 | 24 | 0.800 |
| 6 | `walkunprepare0` | 74..97 | 24 | 0.800 |
| 7 | `attack1` | 99..113 | 15 | 0.500 |
| 8 | `attack0` | 126..139 | 14 | 0.467 |
| 9 | `idle` | 153..202 | 50 | 1.667 |
| 10 | `idle0` | 204..254 | 51 | 1.700 |
| 11 | `idle1` | 256..305 | 50 | 1.667 |
| 12 | `prepare0` | 307..329 | 23 | 0.767 |
| 13 | `unprepare0` | 329..351 | 23 | 0.767 |
| 14 | `prepare1` | 353..379 | 27 | 0.900 |
| 15 | `unprepare1` | 380..406 | 27 | 0.900 |
| 16 | `trans01` | 408..420 | 13 | 0.433 |
| 17 | `trans10` | 420..431 | 12 | 0.400 |
| 18 | `death` | 433..495 | 63 | 2.100 |
| 19 | `death1` | 498..562 | 65 | 2.167 |
| 20 | `death0` | 564..628 | 65 | 2.167 |

> `observed`: `prepare0`/`unprepare0` share endpoint frame 329; `trans01`/`trans10` share 420 (inclusive bounds overlap by one frame). Not a defect — the baker only reads the chosen action's range.

#### Chosen-action mapping, sampled frames, port values, delta

| Port action | chosen donor action | donor range | sampled frames | # | port frames | port dur | donor dur | loop | tool | Δ |
|---|---|---|---|---:|---:|---:|---:|---|---|---|
| `walk` | `walk` | 1..24 | `1,3,5,7,9,11,14,16,18,20,22,24` | 12 | 12 | 0.800 | 0.800 | true | null | 0 |
| `idle` | `idle` | 153..202 | `153,163,173,182,192,202` | 6 | 6 | 1.667 | 1.667 | true | null | 0 |
| `attack` | **`attack1`** (first in priority) | 99..113 | `99,100,102,103,104,105,107,108,109,110,112,113` | 12 | 12 | 0.500 | 0.500 | false | null | 0 |
| `death` | `death` | 433..495 | `433,442,451,460,468,477,486,495` | 8 | 8 | 2.100 | 2.100 | false | null | 0 |

**Port durations are donor-exact for all four actions.** `attack1` selection is the documented gunpowder-volley preference (`UNIT_BAKING_FIX.md` §1.2, baker comment `:223-227`).

---

### 2.3 `dragoon` ← donor base `dragoon18`

#### Donor header facts (`observed`)

| Field | Value | Evidence |
|---|---:|---|
| file | `data\actors\units\dragoon18.oss` | — |
| k | 639 | `7F 02 00 00` |
| fps | 30 | `1E 00 00 00` |
| bones | 16 | `10 00 00 00` |
| verts | 814 | `2E 03 00 00` |
| faces | 1,124 | `64 04 00 00` |
| uvs | 1,039 | `0F 04 00 00` |
| file size | 341,144 B | `os.path.getsize` |

AAF header lines 1–2: `AAF`, `9` (`observed`). 9 action lines (3–11).

#### Every donor action

| AAF line | action | start..end | incl. frames | donor dur (s) |
|---:|---|---:|---:|---:|
| 3 | `idle` | 505..589 | 85 | 2.833 |
| 4 | `idle0` | 418..502 | 85 | 2.833 |
| 5 | `idle_rest` | 335..415 | 81 | 2.700 |
| 6 | `walk` | 614..637 | 24 | 0.800 |
| 7 | `death` | 49..119 | 71 | 2.367 |
| 8 | `attack0` | 592..604 | 13 | 0.433 |
| 9 | `prepare0` | 214..227 | 14 | 0.467 |
| 10 | `unprepare0` | 200..213 | 14 | 0.467 |
| 11 | `death0` | 124..195 | 72 | 2.400 |

#### Chosen-action mapping, sampled frames, port values, delta

| Port action | chosen donor action | donor range | sampled frames | # | port frames | port dur | donor dur | loop | tool | Δ |
|---|---|---|---|---:|---:|---:|---:|---|---|---|
| `walk` | `walk` | 614..637 | `614,616,618,620,622,624,627,629,631,633,635,637` | 12 | 12 | 0.800 | 0.800 | true | null | 0 |
| `idle` | `idle` | 505..589 | `505,522,539,555,572,589` | 6 | 6 | 2.833 | 2.833 | true | null | 0 |
| `attack` | `attack0` | 592..604 | `592,593,594,595,596,597,599,600,601,602,603,604` | 12 | 12 | 0.433 | 0.433 | false | null | 0 |
| `death` | `death` | 49..119 | `49,59,69,79,89,99,109,119` | 8 | 8 | 2.367 | 2.367 | false | null | 0 |

**Port durations donor-exact for all four.** `attack0` chosen because no `attack1` exists in `dragoon18.aaf`.

---

### 2.4 `cannon` ← donor base `cannon`

#### Donor header facts (`observed`)

| Field | Value | Evidence |
|---|---:|---|
| file | `data\actors\units\cannon.oss` | — |
| k | 339 | `53 01 00 00` |
| fps | 30 | `1E 00 00 00` |
| bones | 3 | `03 00 00 00` |
| verts | 736 | `E0 02 00 00` |
| faces | 564 | `34 02 00 00` |
| uvs | 1,827 | `23 07 00 00` |
| file size | 74,316 B | `os.path.getsize` |

AAF header lines 1–2: `AAF`, `4` (`observed`). 4 action lines (3–6).

#### Every donor action

| AAF line | action | start..end | incl. frames | donor dur (s) |
|---:|---|---:|---:|---:|
| 3 | `idle` | 1..1 | 1 | 0.033 |
| 4 | `walk` | 1..99 | 99 | 3.300 |
| 5 | `attack0` | 301..337 | 37 | 1.233 |
| 6 | `attack1` | 301..337 | 37 | 1.233 |

> `observed`: **no `death` action exists in the donor AAF** — the port has no `death` action either (`index.json` cannon block, lines 1373+). Consistent; no mismatch. `attack0` and `attack1` are byte-identical ranges.

#### Chosen-action mapping, sampled frames, port values, delta

| Port action | chosen donor action | donor range | sampled frames | # | port frames | port dur | donor dur | loop | tool | Δ |
|---|---|---|---|---:|---:|---:|---:|---|---|---|
| `walk` | `walk` | 1..99 | `1,10,19,28,37,46,54,63,72,81,90,99` | 12 | 12 | 3.300 | 3.300 | true | null | 0 |
| `idle` | `idle` | 1..1 | `1` (single frame; `sample()` `:115`) | 1 | 1 | 0.033 | 0.033 | true | null | 0 |
| `attack` | **`attack1`** (first in priority) | 301..337 | `301,304,308,311,314,317,321,324,327,330,334,337` | 12 | 12 | 1.233 | 1.233 | false | null | 0 |

**Port durations donor-exact for all three.** The 3.3 s "walk" is donor truth (`walk 1..99`), not a port invention; `UNIT_BAKING_FIX.md` §11.1 allows longer artillery locomotion.

---

### 2.5 `officer` ← donor base `officer`

#### Donor header facts (`observed`)

| Field | Value | Evidence |
|---|---:|---|
| file | `data\actors\units\officer.oss` | — |
| k | 228 | `E4 00 00 00` |
| fps | 30 | `1E 00 00 00` |
| bones | 22 | `16 00 00 00` |
| verts | 826 | `3A 03 00 00` |
| faces | 1,021 | `FD 03 00 00` |
| uvs | 961 | `C1 03 00 00` |
| file size | 192,488 B | `os.path.getsize` |

AAF header lines 1–2: `AAF`, `8` (`observed`). 8 action lines (3–10).

#### Every donor action

| AAF line | action | start..end | incl. frames | donor dur (s) |
|---:|---|---:|---:|---:|
| 3 | `idle` | 115..164 | 50 | 1.667 |
| 4 | `walk` | 1..24 | 24 | 0.800 |
| 5 | `death` | 49..102 | 54 | 1.800 |
| 6 | `attack0` | 29..42 | 14 | 0.467 |
| 7 | `prepare0` | 104..113 | 10 | 0.333 |
| 8 | `unprepare0` | 216..226 | 11 | 0.367 |
| 9 | `idle0` | 166..215 | 50 | 1.667 |
| 10 | `attackpause0` | 166..182 | 17 | 0.567 |

#### Chosen-action mapping, sampled frames, port values, delta

| Port action | chosen donor action | donor range | sampled frames | # | port frames | port dur | donor dur | loop | tool | Δ |
|---|---|---|---|---:|---:|---:|---:|---|---|---|
| `walk` | `walk` | 1..24 | `1,3,5,7,9,11,14,16,18,20,22,24` | 12 | 12 | 0.800 | 0.800 | true | null | 0 |
| `idle` | `idle` | 115..164 | `115,125,135,144,154,164` | 6 | 6 | 1.667 | 1.667 | true | null | 0 |
| `attack` | `attack0` | 29..42 | `29,30,31,33,34,35,36,37,38,40,41,42` | 12 | 12 | 0.467 | 0.467 | false | null | 0 |
| `death` | `death` | 49..102 | `49,57,64,72,79,87,94,102` | 8 | 8 | 1.800 | 1.800 | false | null | 0 |

**Port durations donor-exact for all four.**

---

## 3. Attach props (`observed`)

Enumeration was `os.listdir(C:\Games\Cossacks 3\data\actors\units\attach)` filtered by `<base>_*`, with `os.path.getsize` for bytes. Tool→action usage is the literal `ATTACH_ACTIONS` map at `bake_sprites.py:288-291`; the port's `tool` field was read from `index.json` and matches exactly.

### 3.1 Hand props present for `peaukr` (and only for `peaukr` among these 5)

| Donor file | Bytes | Tool | Port actions using it (all `peasant.*`) | Port `tool` value |
|---|---:|---|---|---|
| `peaukr_axe.oss` | 20,876 | axe | `attack`, `workwood` | `"axe"` on both |
| `peaukr_hammer.oss` | 20,316 | hammer | `construct` | `"hammer"` |
| `peaukr_hoe.oss` | 21,500 | hoe | `workfood` | `"hoe"` |
| `peaukr_pick.oss` | 18,044 | pick | `workstone` | `"pick"` |
| `peaukr_lumber.oss` | 70,348 | lumber | `walkwood`, `idlewood` | `"lumber"` on both |
| `peaukr_bag.oss` | 25,780 | bag | `walkfood`, `idlefood` | `"bag"` on both |
| `peaukr_cart.oss` | 39,524 | cart | `walkstone`, `idlestone` | `"cart"` on both |
| `peaukr_tools.actor` | 1,665 | manifest (not a mesh) | lists the seven props against `peaukr.aaf` | n/a |

Every other `peasant.*` action (`walk`, `idle`, `death`) has `tool: null` (`observed`), consistent with `ATTACH_ACTIONS`.

### 3.2 Non-hand attach asset found for `dragoon18`

| Donor file | Bytes | Nature | Baked? | Port `tool` |
|---|---:|---|---|---|
| `dragoon18_horse.oss` | 484,992 | **mount** (single attach mesh, not a hand tool) | **No** | `null` on all 4 |
| `dragoon18_horse.actor` | 382 | mount manifest | n/a | n/a |

`derived`/`inferred`: the horse is a mount, not listed in `ATTACH_ACTIONS` (`:288-291`), so `dragoon.tool = None` is **consistent with the baker's hand-tool scope** and is *not* a wrong `tool` value. It is a real donor attach asset that is not represented in the baked rider — matching the open cavalry-mount follow-up in `UNIT_BAKING_FIX.md` §7. This is a **coverage gap**, flagged in §5 R3.

### 3.3 Families with no matching attach files

`musketeer18`, `cannon`, `officer`: `os.listdir` returned **no** `<base>_*` entries in `attach\` (`observed`). All their port actions have `tool: null` — consistent.

---

## 4. Unbaked donor actions (present in donor AAF, no baked sheet)

Derived by set difference: donor names minus the set of names actually chosen by the priority list (§1.4). These are **not** errors in the existing sheets; they are donor actions with no port sheet.

| Family | Donor actions present but NOT baked | Count / total |
|---|---|---:|
| `peaukr` | `idle0`, `reaction`, `prepare0`, `unprepare0` | 4 / 18 |
| `musketeer18` | `walk0`, `walkprepare0`, `walkunprepare0`, `attack0`, `idle0`, `idle1`, `prepare0`, `unprepare0`, `prepare1`, `unprepare1`, `trans01`, `trans10`, `death1`, `death0` | 14 / 18 |
| `dragoon18` | `idle0`, `idle_rest`, `prepare0`, `unprepare0`, `death0` | 5 / 9 |
| `cannon` | `attack0` (identical range `301..337` to the chosen `attack1`) | 1 / 4 |
| `officer` | `prepare0`, `unprepare0`, `idle0`, `attackpause0` | 4 / 8 |

Notes (`observed` + `derived`):
- `peaukr.idle0` is a duplicate of `idle` (`64..113`); `musk18.idle0` is `204..254` (51 frames, 1.700 s); `officer.idle0` is `166..215`. The priority list takes `idle` first in each case.
- `cannon.attack0` being "unbaked" is harmless: it is byte-identical to `attack1`, which **is** baked.
- `musk18.death1`/`death0` and `dragoon18.death0` are alternate death clips; the baker uses the first-present `death`.
- Whether any of these is **needed** for donor-equivalent skirmish behaviour is `UNVERIFIED` (§7) — the AAF gives ranges only, not runtime state→action binding.

---

## 5. Mismatches ranked, with direct baker actions

### R1 — `peasant.walk` duration: port 1.08 s vs donor 0.667 s — **DELIBERATE PORT FIX; DO NOT REVERT**

- **Observed:** `index.json:7` `"duration": 1.08`; donor `peaukr.aaf:5` `walk 1..20` → 0.667 s (`derived`). `frames=12`, `loop=true`, `tool=null` match.
- **Provenance (`observed` in `docs/UNIT_BAKING_FIX.md`):** §10 agentC2 and §11.2 agentSE changed `0.667 → 1.08` for base `peasant` and the 8 national peasants under GUIDE4 DO-L7.06 (`n*0.09`; stride 1.5 m/s × 1.08 / 12 = 0.135 m/frame ≈ foot length). The original 0.667 gave 0.083 m/frame = foot slide.
- **Baker action:** **leave 1.08 exactly as-is.** Do not regenerate `peasant_walk` duration from donor 20/30. If a fresh mini-baker emits 0.667, post-process it back to 1.08 for all 9 walk keys (only the base key is in this ticket's scope).
- **Why it is not a donor-truth defect:** it is a documented, accepted port-authored stride correction, not a misread of the AAF. As a **visual** improvement it was not re-verified by me (no Godot job permitted) — inherited as a recorded decision, labelled `inferred` for its visual effect.

### R2 — Unbaked donor actions (coverage, all 5 families) — **DECIDE, don't silently substitute**

- **Observed:** §4 lists 4/14/5/1/4 unbaked actions respectively.
- **Baker action:** If the UNITS lane requires a donor state that currently has no sheet (e.g. musketeer `prepare1`/`trans01`, dragoon `idle_rest`, officer `attackpause0`, peasant `reaction`), add it as a **new action** via a scoped baker + `index.json` entry (integration ticket, new files), sampling with the same `sample()` rule and duration `(end-start+1)/30`. Otherwise record it as intentionally out of scope. **Do not** map a missing state onto an existing sheet (e.g. never play `attack` for `prepare0`, never play `idle` for `idle_rest`) — that would fabricate runtime behaviour not read from any donor file.
- **Why:** the AAF proves the clips exist and their exact ranges; it does not prove which game state triggers them (§7). Coverage is a choice; mis-binding is a new defect.

### R3 — `dragoon18_horse.oss` mount not baked — **COVERAGE GAP, not a `tool` error**

- **Observed:** `attach\dragoon18_horse.oss` 484,992 B + `.actor` 382 B exist; `dragoon.tool = null` on all 4 port actions; `ATTACH_ACTIONS` has no mount entry.
- **Baker action:** no change to the `tool` field (leaving it `null` is correct for hand-tool semantics). If donor-equivalent dragoon silhouette is required, open a separate cavalry-mount ticket that combines `dragoon18.oss` with `attach\dragoon18_horse.oss` — the same class of follow-up already recorded in `UNIT_BAKING_FIX.md` §7. Until then, describe the dragoon bake as **rider-only**; do not claim mount fidelity.

### R4 — Port `frames` ≠ donor inclusive frame count — **NO MISMATCH; leave alone**

- **Observed:** e.g. `peasant.walk` donor 20 frames, port 12 frames, donor duration 0.667. `sample()` at `bake_sprites.py:111-119` intentionally decimates.
- **Baker action:** keep port `frames` at the sampled count (12/6/8/10/8/1); keep duration derived from the **donor range**, not from `frames`. Do not "fix" 12→20 or recompute 0.667 from 12/30.

### R5 — Identical-range donor action pairs — **NO MISMATCH; leave alone**

- **Observed:** `peaukr` `attack0 == workwood == 237..254`; `cannon` `attack0 == attack1 == 301..337`.
- **Baker action:** cannon correctly picks `attack1` (first in priority); peasant correctly picks `attack0` (no `attack1` in the AAF) for `attack` and `workwood` for the work action, with n=12 vs n=10 and different tools. Do not deduplicate or "correct" either choice.

### R6 — Everything else in the 4 non-peasant families — **NO MISMATCH**

- `musk18`, `dragoon`, `cannon`, `officer`: every port `frames`, `duration`, `loop`, `tool` value is consistent with the donor range and the baker plan (§2.2–2.5). No scalar change is warranted from this research.

---

## 6. Claim table

| # | Claim | Evidence | Method | Verdict |
|---:|---|---|---|---|
| 1 | All 5 donor `.oss` headers report fps=30 | bytes `0x04..0x07` = `1E 00 00 00` in each file | byte parse (`int.from_bytes`) | **observed** |
| 2 | Header values (k/bones/verts/faces/uvs) and file sizes in §2 are exact | `.oss` bytes `0x00..0x17`; `os.path.getsize` | two independent parsers, full agreement | **observed** |
| 3 | AAF ranges, line numbers and counts in §2 are exact literal text | `data\animations\aaf\<base>.aaf` lines 3–20 / 3–11 / 3–6 / 3–10 | raw-line dump + regex parse | **observed** |
| 4 | Donor durations = inclusive_frames/30; port durations equal donor durations except `peasant.walk` | §2 tables | arithmetic + field read | **derived** |
| 5 | `peasant.walk` 0.667→1.08 is a deliberate port stride fix, not donor truth | `peaukr.aaf:5`; `index.json:7`; `UNIT_BAKING_FIX.md` §10/§11.2 | chained read | **observed** (values + documented decision); **inferred** for its visual benefit |
| 6 | `attack0 == workwood` (peaukr) and `attack0 == attack1` (cannon) are byte-identical ranges | `peaukr.aaf:7,9`; `cannon.aaf:5,6` | raw-line read | **observed** |
| 7 | 7 hand props + manifest exist for `peaukr`; none for the other 4 bases | `os.listdir` + `getsize` of `attach\` | directory enumeration | **observed** |
| 8 | `dragoon18_horse.oss` (484,992 B) mount exists and is not baked | `attach\dragoon18_horse.oss/.actor` | directory enumeration + plan diff | **observed** |
| 9 | `dragoon.tool = null` is correct for hand-tool scope | `ATTACH_ACTIONS` `:288-291`; all 4 port `tool` fields | code + field read | **derived** |
| 10 | Unbaked action lists in §4 are exact | donor AAF names − chosen set (§1.4) | set difference | **derived** |
| 11 | No `death` action exists for `cannon` in either donor or port | `cannon.aaf` (4 lines); cannon block in `index.json` | read | **observed** |
| 12 | Runtime state→action binding for unbaked clips | — | — | **UNVERIFIED** |
| 13 | Visual quality of the 1.08 stride fix and rider-only dragoon | — | — | **UNVERIFIED** (no Godot/Blender job permitted here) |

---

## 7. Open questions / UNVERIFIED

1. **UNVERIFIED — runtime binding.** The `.aaf` is plaintext ranges only. Whether the donor actually plays `prepare0`/`trans01`/`reaction`/`idle_rest`/`attackpause0` in a skirmish, and in which state, was **not** read (would require `.acl`/script analysis, outside this ticket). Do not assert these clips are needed.
2. **UNVERIFIED — visual effect of the 1.08 fix.** Inherited from `UNIT_BAKING_FIX.md` as a recorded decision; I did not render or view a peasant walk. Treat as `inferred` for benefit; the duration *value* itself is `observed`.
3. **UNVERIFIED — dragoon mount appearance.** Whether baking rider-only changes perceived donor fidelity is not measured. Flagged R3, not claimed as a defect.
4. **UNVERIFIED — per-nation attach grip bones.** `UNIT_BAKING_FIX.md` §6 caveat notes attach grip bones must be re-verified per nation prefix; this ticket covers only base `peaukr`, not the 8 national variants.
5. **UNVERIFIED — `morph` flag semantics.** Every AAF line ends in `morph`; the baker ignores it. Its donor meaning was not read.
6. **Inherited, not re-derived here:** the 3.3 s cannon `walk` is donor truth (`walk 1..99`); `UNIT_BAKING_FIX.md` §11.1 permits long artillery locomotion. No change proposed.
7. **Scope note:** the other 8 national-peasant 0.667→1.08 edits are outside these 5 families; a baker re-baking the full roster must apply the same fix to all 9 walk keys, but that is a roster-wide integration concern, not this ticket's finding.

---

*End of T6-S05 research output. Boundaries restated: donor read-only private use; nothing copied into the repo; no donor executable run; no Godot job, no Blender bake; no file edited except this document and `docs/t6/reports/T6-S05.md`.*
