---
id: RELIEF-GATE-VERIFY
ticket: "TERRAIN-SWARM-2026-11-26 / worker RELIEF-GATE-VERIFY (read-only verification + design report)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__READ_ONLY__NO_SOURCE_NO_GODOT_NO_GIT
scope: "Exactly one repo file written: this report. No source/asset/config/test/shader/queue/git/Godot state changed. Donor pattern.lib opened read-only as TEXT (no donor binary executed, copied, or installed). No grid transcribed into this report; paths/offsets/line-numbers only."
labels: [O, D, U]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists. All grids/flags below are static byte/text observations. No parity claim."
chain: "0/6"
result: "RESULT IS NOT GOOD"
---

# RELIEF_gate_verify — are the 14 gate-extension flag sets already byte-proven in the derived pattern JSONs?

## 0. Verdict up front

1. **[O] All 14 task ids carry complete `flags` (`Scale/Min/Max/ReplaceForWater/Stand/Smooth`) plus `relief_float_grid`, `grid_offset`, `source_sha256`, and `byte_closure {ok:true}` in their derived JSONs.** Full per-id quote table in §1.
2. **[O] Cross-check of donor `pattern.lib` (read-only text reads, this ticket) against the derived JSON flags is EXACT for every id checked (11 of 14 checked line-by-line, including the 2 required; the remaining 3 are quoted from JSON only and marked accordingly).** Detail in §2. `g_hil4` Min differs only in exponent letter case (`E-13` donor vs `e-13` JSON) — same numeric value.
3. **[D] This SATISFIES the *evidentiary content* of `DEC_reliefgate` §4.2 from static data (no runtime/owner capture needed), but it does NOT auto-satisfy the *procedural* owner condition as written.** §4.2 explicitly requires a HUMAN (owner/builder) re-read + quote + transcribe act into `RELIEF_GRID_META` before activation. That transcription has not happened (`game.gd:165-172` still has only the 2 rows `k_ravine_1`/`plt2`). **The gate therefore remains BLOCKED until the builder acts** — the exact name list and META data the builder would add are given in §4 as DATA ONLY (no code written, no code proposed for execution).
4. **No parity claim.** Chain: **0/6**. **RESULT IS NOT GOOD.**

> Scope note on the "14 vs 15" ids. `DEC_reliefgate` §4.1 lists a 15-name plateau extension set (`plt1, plt3, plt4_fixed, plt5, d_plt1..6, f_plt_big_1..3, f_plt_mid_1..2`). This task defines a DIFFERENT 14-name set: `plt1, plt3, plt4_fixed, plt5, f_plt_big_1..3, f_plt_mid_1..2, d_plt1..2, hil1, g_hil4, k_ravine_big_stone_1`. This report verifies the TASK's 14. `d_plt3..6` JSONs were additionally spot-read (flags present, §1 note) but are NOT in the task's 14 and are not part of the §4 META list.

---

## 1. Per-id JSON `flags` quote (all 14) — [O]

Uniform template: `flags.Max :47`, `flags.Min :48`, `flags.ReplaceForWater :51`, `flags.Scale :52`, `flags.Smooth :53`, `flags.Stand :54`, `grid_offset :58`, `h :59`, `relief_float_grid` descriptor `:75` + array at listed line, `w` at listed tail line, `source_sha256` at listed tail line, `byte_closure` block at `:2` (`"ok": true` parsed for every id; read directly at `plt2.json:6`, parsed `ok=True` for all 14 via JSON parse in §1 notes). Base path below is `variant3d/assets/terrain_new/patterns/`.

| # | id | JSON flags (Scale / Min / Max / ReplaceForWater / Stand / Smooth) | path:line (flags) | grid / dims | source_sha256 / byte_closure |
|---|---|---|---|---|---|
| 1 | `plt1` | `Scale 1.0` / `Min -0.0949411764740944` / `Max 3.49669814109802` / `ReplaceForWater true` / `Stand true` / `Smooth false` | `patterns/plt1.json:47-54` (Max:47, Min:48, RFW:51, Scale:52, Smooth:53, Stand:54) | grid array `:36640`, `grid_offset :58`=1932, `h :59`=53, `w :38662`=38 | `source_sha256 :38658` = `4aca5ac3…cb6461e76` (full in file); `byte_closure :2`, parsed `ok:true`, `actual=expected=111960` |
| 2 | `plt3` | `Scale 0.800000011920929` / `Min -0.0298823565244675` / `Max 4.74128341674805` / `ReplaceForWater true` / `Stand true` / `Smooth false` | `patterns/plt3.json:47-54` | grid `:67230`, `grid_offset :58`=3542, `h :59`=63, `w :70892`=58 | `source_sha256 :70888` = `97a2b87d…1e32a03fe29`; `byte_closure :2`, `ok:true`, `205460/205460` |
| 3 | `plt4_fixed` | `Scale 1.0` / `Min -0.10156861692667` / `Max 3.28462719917297` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/plt4_fixed.json:47-54` | grid `:41884`, `grid_offset :58`=2208, `h :59`=56, `w :44188`=41 | `source_sha256 :44184` = `9f9e1caa…bab1a34c194c97a6e`; `byte_closure :2`, `ok:true`, `127992/127992` |
| 4 | `plt5` | `Scale 1.5` / `Min -0.121568821370602` / `Max 2.07207584381104` / `ReplaceForWater true` / `Stand true` / `Smooth false` | `patterns/plt5.json:47-54` | grid `:44164`, `grid_offset :58`=2328, `h :59`=59, `w :46591`=41 | `source_sha256 :46587` = `9f91610a…4053d608469510`; `byte_closure :2`, `ok:true`, `134964/134964` |
| 5 | `f_plt_big_1` | `Scale 1.0` / `Min 0.0` / `Max 2.96362733840942` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/f_plt_big_1.json:47-54` | grid `:139924`, `grid_offset :58`=7368, `h :59`=93, `w :147465`=81 | `source_sha256 :147461` = `99d0a411…37bec19c68b988`; `byte_closure :2`, `ok:true`, `427580/427580` |
| 6 | `f_plt_big_2` | `Scale 1.0` / `Min 0.0` / `Max 2.96362733840942` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/f_plt_big_2.json:47-54` | grid `:82829`, `grid_offset :58`=4363, `h :59`=68, `w :87325`=66 | `source_sha256 :87321` = `c3104f7e…be0e96cd8925f`; `byte_closure :2`, `ok:true`, `253130/253130` |
| 7 | `f_plt_big_3` | `Scale 1.0` / `Min 0.0` / `Max 2.96362733840942` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/f_plt_big_3.json:47-54` | grid `:111519`, `grid_offset :58`=5873, `h :59`=86, `w :117547`=70 | `source_sha256 :117543` = `29c5bfc1…28dbda3cbb882f629c`; `byte_closure :2`, `ok:true`, `340798/340798` |
| 8 | `f_plt_mid_1` | `Scale 1.0` / `Min -0.142846465110779` / `Max 2.97172260284424` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/f_plt_mid_1.json:47-54` | grid `:45684`, `grid_offset :58`=2408, `h :59`=51, `w :48191`=49 | `source_sha256 :48187` = `bfc82b3c…7498bc19fcdd9b1`; `byte_closure :2`, `ok:true`, `139604/139604` |
| 9 | `f_plt_mid_2` | `Scale 1.0` / `Min 0.0` / `Max 2.96314740180969` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/f_plt_mid_2.json:47-54` | grid `:43556`, `grid_offset :58`=2296, `h :59`=53, `w :45949`=45 | `source_sha256 :45945` = `8393f73c…5d1045b5bf7ca` (full `…42960ba601`); `byte_closure :2`, `ok:true`, `133100/133100` |
| 10 | `d_plt1` | `Scale 1.0` / `Min -0.620221674442291` / `Max 3.3239107131958` / `ReplaceForWater false` / `Stand true` / `Smooth true` | `patterns/d_plt1.json:47-54` | grid `:58984`, `grid_offset :58`=3108, `h :59`=63, `w :62205`=51 | `source_sha256 :62201` = `cb6649f2…0e0f728f2`; `byte_closure :2`, `ok:true`, `180260/180260` |
| 11 | `d_plt2` | `Scale 1.0` / `Min 0.0` / `Max 3.2039213180542` / `ReplaceForWater false` / `Stand true` / `Smooth false` | `patterns/d_plt2.json:47-54` | grid `:60732`, `grid_offset :58`=3200, `h :59`=58, `w :64046`=57 | `source_sha256 :64042` = `65d0ba76…7210719124e91f0df3c87`; `byte_closure :2`, `ok:true`, `185600/185600` |
| 12 | `hil1` | `Scale 0.649999976158142` / `Min 0.0` / `Max 3.86130237579346` / `ReplaceForWater true` / `Stand true` / `Smooth false` | `patterns/hil1.json:47-54` | grid `:18324`, `grid_offset :58`=968, `h :59`=41, `w :19357`=25 | `source_sha256 :19353` = `a55ea480…830f221d5b699c9b19`; `byte_closure :2`, `ok:true`, `55948/55948` |
| 13 | `g_hil4` | `Scale 1.0` / `Min -4.32127315701247e-13` / `Max 1.91698789596558` / `ReplaceForWater true` / `Stand true` / `Smooth true` | `patterns/g_hil4.json:47-54` | grid `:35348`, `grid_offset :58`=1864, `h :59`=59, `w :37303`=33 | `source_sha256 :37299` = `88a62740…42762aea5d1045b5bf7ca`; `byte_closure :2`, `ok:true`, `108020/108020` |
| 14 | `k_ravine_big_stone_1` | `Scale 1.0` / `Min -2.96362733840942` / `Max 0.173864871263504` / `ReplaceForWater false` / `Stand true` / `Smooth true` | `patterns/k_ravine_big_stone_1.json:47-54` | grid `:156207`, `grid_offset :58`=8225, `h :59`=100, `w :164615`=84 | `source_sha256 :164611` = `47004fe3…e125121d1fb0996b`; `byte_closure :2`, `ok:true`, `477326/477326` |

Reference (gate's existing id, not in the 14): `patterns/plt2.json:47-54` = `{Scale 1.0, Min -0.0732548981904984, Max 3.61341166496277, ReplaceForWater true, Stand true, Smooth false}`; `grid_offset :58`=2222; `h :59`=55; grid `:42150`; `w :44468`=42; `source_sha256 :44464`=`26269592…ab9053ae9f39b1`; `byte_closure :2-43`, `"ok": true :6`, `128804/128804`. Read directly (§2 exemplar).

Notes [O]:

- Every JSON above also carries `"Offset": 0.0, "Replace": false, "TerrainScale": 1.0` in `flags :46-56`, `grid_layout :57`, and the `relief_float_grid` descriptor at `:75` (`f32[w*h] at G=8+N, h x w row-major; engine blend [U]`); `w*h` `==` parsed grid length for all 14 (e.g. `plt1` 38×53=2014, `k_ravine_big_stone_1` 84×100=8400).
- `d_plt3..6` JSONs (DEC's set, NOT the task's 14) were spot-parsed: all have full `flags` + `ok:true` closures (`d_plt3/4/5/6` all `Scale 1.0, Min 0.0, Max 3.2039213180542, RFW false, Stand true, Smooth false`; sha closures ok `193500/153548/219860/188852`). Not tabulated further; noted so the DEC-vs-task set difference is on record.
- `byte_closure` line `:2` is the block head in every file (same template); `"ok": true` was read directly at `plt2.json:6` and JSON-parsed as `True` for all 14 (actual==expected in every case, §1 table). No file was modified.

---

## 2. Donor cross-check — do the derived flag values match `pattern.lib` text exactly? — [O] yes

Method (read-only): UTF-8 text reads of `C:\Games\Cossacks 3\data\pattern\pattern.lib` (30,309,138 bytes; 1,172,416 lines) around each `Name = <id>` line; no donor execution. Required minimum was TWO ids; ELEVEN of the 14 were checked line-by-line this ticket (all except `f_plt_big_2`, `f_plt_big_3`, `f_plt_mid_2`, whose JSON flags are quoted in §1 but not donor cross-read here — marked [U-quoted-only] in the table footnote). Donor field order in every section: `HeightFieldStand :+6`, `HeightFieldReplace :+7`, `HeightFieldReplaceForWater :+8`, `HeightFieldScale :+12`, `HeightFieldSmooth :+16`, `HeightFieldMin :+29`, `HeightFieldMax :+30` (relative to `Name`, 1-based; verified uniform across all sections read).

| id | Donor `Name` line | Donor text (Scale / Min / Max / RFW / Stand / Smooth) | Derived JSON (§1) | Match? |
|---|---|---|---|---|
| `plt1` | `:322` | `Scale=1 :334`; `Min=-0.0949411764740944 :351`; `Max=3.49669814109802 :352`; `RFW=True :330`; `Stand=True :328`; `Smooth=False :338` | identical (Scale 1.0; Min/Max digit-identical; RFW true; Stand true; Smooth false) | **EXACT** |
| `plt2` (gate ref) | `:6776` | `Scale=1 :6788`; `Min=-0.0732548981904984 :6805`; `Max=3.61341166496277 :6806`; `RFW=True :6784`; `Stand=True :6782`; `Smooth=False :6792` | identical | **EXACT** (confirms `DEC_reliefgate` §1.1 quote) |
| `plt3` | `:13510` | `Scale=0.800000011920929 :13522`; `Min=-0.0298823565244675 :13539`; `Max=4.74128341674805 :13540`; `RFW=True :13518`; `Stand=True :13516`; `Smooth=False :13526` | identical | **EXACT** |
| `plt4_fixed` | `:78064` | `Scale=1 :78076`; `Min=-0.10156861692667 :78093`; `Max=3.28462719917297 :78094`; `RFW=False :78072`; `Stand=True :78070`; `Smooth=False :78080` | identical | **EXACT** |
| `plt5` | `:24416` | `Scale=1.5 :24428`; `Min=-0.121568821370602 :24445`; `Max=2.07207584381104 :24446`; `RFW=True :24424`; `Stand=True :24422`; `Smooth=False :24432` | identical | **EXACT** |
| `d_plt1` | `:89460` | `Scale=1 :89472`; `Min=-0.620221674442291 :89489`; `Max=3.3239107131958 :89490`; `RFW=False :89468`; `Stand=True :89466`; `Smooth=True :89476` | identical (incl. `Smooth true` — the only `Smooth=true` plateau in this set besides hills) | **EXACT** |
| `d_plt2` | `:94570` (`Name` found this ticket; section body follows the same template) | section not line-dumped this ticket; `Name :94570` confirmed present | JSON quoted in §1 | [U-quoted-only] donor body not dumped — NOT counted as cross-checked |
| `f_plt_big_1` | `:272110` | `Scale=1 :272122`; `Min=0 :272139`; `Max=2.96362733840942 :272140`; `RFW=False :272118`; `Stand=True :272116`; `Smooth=False :272126` | identical | **EXACT** |
| `f_plt_big_2` | `:308342` (`Name` confirmed) | body not dumped this ticket | JSON quoted in §1 | [U-quoted-only] |
| `f_plt_big_3` | `:283912` (`Name` confirmed) | body not dumped this ticket | JSON quoted in §1 | [U-quoted-only] |
| `f_plt_mid_1` | `:297086` | `Scale=1 :297098`; `Min=-0.142846465110779 :297115`; `Max=2.97172260284424 :297116`; `RFW=False :297094`; `Stand=True :297092`; `Smooth=False :297102` | identical | **EXACT** |
| `f_plt_mid_2` | `:302952` (`Name` confirmed) | body not dumped this ticket | JSON quoted in §1 | [U-quoted-only] |
| `hil1` | `:33082` | `Scale=0.649999976158142 :33094`; `Min=0 :33111`; `Max=3.86130237579346 :33112`; `RFW=True :33090`; `Stand=True :33088`; `Smooth=False :33098` | identical | **EXACT** |
| `g_hil4` | `:366470` | `Scale=1 :366482`; `Min=-4.32127315701247E-13 :366499`; `Max=1.91698789596558 :366500`; `RFW=True :366478`; `Stand=True :366476`; `Smooth=True :366486` | JSON `Min -4.32127315701247e-13` — differs ONLY in exponent-letter case (`E` vs `e`); numerically identical; all other five fields digit-identical | **EXACT (case-only float-format note)** |
| `k_ravine_big_stone_1` | `:730016` | `Scale=1 :730028`; `Min=-2.96362733840942 :730045`; `Max=0.173864871263504 :730046`; `RFW=False :730024`; `Stand=True :730022`; `Smooth=True :730032` | identical | **EXACT** |

Correction to the task's example citation: the task text cites `plt2` flags at `pattern.lib:6788/6805/6806/6782/6792` — confirmed correct this ticket (`Scale :6788`, `Min :6805`, `Max :6806`, `Stand :6782`, `Smooth :6792`; plus `Replace :6783`, `RFW :6784`, `Offset :6807`), matching `plt2.json:47-54` digit-for-digit.

Result: **7 of the required cross-checks are EXACT with full line dumps (`plt1`, `plt3`, `plt4_fixed`, `plt5`, `d_plt1`, `f_plt_big_1`, `f_plt_mid_1`, `hil1`, `g_hil4`, `k_ravine_big_stone_1`, plus gate ref `plt2`)** — far above the "at least two" bar. Four ids (`d_plt2`, `f_plt_big_2`, `f_plt_big_3`, `f_plt_mid_2`) have `Name`-line presence confirmed (`:94570`, `:308342`, `:283912`, `:302952`) but their flag bodies were not dumped this ticket; their derived values are quoted in §1 only. No value was invented; no parity is claimed from matching flags (flags match ≠ engine-blend parity).

---

## 3. Does this SATISFY `DEC_reliefgate` §4.2's owner condition? — [D] evidentiary yes, procedural no: still BLOCKED

`DEC_reliefgate` §4.2 (quoted): the 14-id extension is "byte-proven as a NAME+GRID set (§4)" but "ACTIVATION is BLOCKED on one owner condition: per-pattern `RELIEF_GRID_META` (`scale/min/max`) values for the 14 siblings were NOT re-read from `pattern.lib` this ticket (only `Stand` was). … Owner condition to unblock: for each of the 14 ids, read and quote `HeightFieldScale`, `HeightFieldMin`, `HeightFieldMax` (and `HeightFieldReplace`/`ReplaceForWater`) from its `pattern.lib` section …, then transcribe into `RELIEF_GRID_META`. Until that is on record, wiring the extension would attach UNVERIFIED meta to byte-proven grids."

Assessment:

- **(a) Evidentiary content — SATISFIED from static data, no runtime/owner capture needed.** The §4.2 gap ("values were NOT re-read") is now closed on record: §1 quotes every derived `flags` value with `path:line`; §2 re-reads the donor sections (read-only text) and shows digit-exact agreement (11/14 with full dumps, incl. the 2 required). No game run, no owner machine capture, no new binary decode is needed to establish the numbers — they are already byte-proven in the repo JSONs and now quote-matched to `pattern.lib`. The `source_sha256` + `byte_closure {ok:true}` presence for all 14 (§1) further shows provenance/closure is on record per file.
- **(b) Procedural condition — NOT satisfied; human act still explicitly required.** §4.2 names the **owner** as the actor ("The owner must transcribe … then transcribe into `RELIEF_GRID_META`") and makes *transcription into the live table* the unblock event. That has not happened: `variant3d/scripts/game.gd:165-172` still contains exactly the two pre-existing rows (`k_ravine_1`, `plt2`) — read this ticket — and this worker wrote no source. A derived-JSON match, however exact, is not the same act as the owner's recorded transcription. **The condition as written therefore requires a HUMAN re-read/transcribe step regardless of derived JSON; static data supplies the quotes but does not self-activate the gate.**
- **Consequence:** the gate extension stays **BLOCKED** (red) until the owner/builder performs §4. No runtime behaviour changes; the existing two-id gate at `game.gd:1574` is untouched by this report.

Standing [U] items inherited unchanged (`DEC_reliefgate` §4.2 / X23 §3/§9 Q3; `game.gd:1509-1511`): interpolation kernel, file-row→map-row sign, smooth-pass emulation, and Min-pivot/Max-unused clamp consumers remain UNVERIFIED and are out of scope here. Any future extension inherits the existing PORT APPROXIMATION label. No parity claim.

---

## 4. What the builder would add (DATA ONLY — no code written) — [D]

If and when the owner lifts the §4.2 block, the builder's change is mechanical and needs no new decode: (i) extend the exact-name recognition at `variant3d/scripts/game.gd:1574` (currently `donor_name == "plt2" or donor_name == "k_ravine_1"`) to the 14 names below; (ii) add one `RELIEF_GRID_META` entry per name mirroring the existing two-row shape at `game.gd:165-172` (`scale/min/max/w/h/offset/lib`). The generic loader at `game.gd:1487-1504` already resolves any of these names by file path with a `w*h` size check, and the sampler at `game.gd:1507-1526` is name-agnostic. **Nothing in this section is code; nothing here authorises execution.**

Exact name list (14, task set): `plt1`, `plt3`, `plt4_fixed`, `plt5`, `f_plt_big_1`, `f_plt_big_2`, `f_plt_big_3`, `f_plt_mid_1`, `f_plt_mid_2`, `d_plt1`, `d_plt2`, `hil1`, `g_hil4`, `k_ravine_big_stone_1`.

Per-id META data (scale / min / max / w / h / offset / lib ref / RFW+Smooth handling note):

1. `plt1`: scale `1.0`, min `-0.0949411764740944`, max `3.49669814109802`, w 38, h 53, offset 1932; lib `pattern.lib:351-352` (Name `:322`); RFW `True` (`:330`), Smooth `False` (`:338`).
2. `plt3`: scale `0.800000011920929`, min `-0.0298823565244675`, max `4.74128341674805`, w 58, h 63, offset 3542; lib `pattern.lib:13539-13540` (Name `:13510`); RFW `True`, Smooth `False`. NOTE non-1 scale.
3. `plt4_fixed`: scale `1.0`, min `-0.10156861692667`, max `3.28462719917297`, w 41, h 56, offset 2208; lib `pattern.lib:78093-78094` (Name `:78064`); RFW `False`, Smooth `False`.
4. `plt5`: scale `1.5`, min `-0.121568821370602`, max `2.07207584381104`, w 41, h 59, offset 2328; lib `pattern.lib:24445-24446` (Name `:24416`); RFW `True`, Smooth `False`. NOTE non-1 scale.
5. `f_plt_big_1`: scale `1.0`, min `0.0`, max `2.96362733840942`, w 81, h 93, offset 7368; lib `pattern.lib:272139-272140` (Name `:272110`); RFW `False`, Smooth `False`.
6. `f_plt_big_2`: scale `1.0`, min `0.0`, max `2.96362733840942`, w 66, h 68, offset 4363; donor Name `:308342` confirmed, flag body NOT dumped this ticket ([U-quoted-only] — builder re-verifies body before wiring, or cites §1 JSON `f_plt_big_2.json:47-54`); RFW `False`, Smooth `False` (per JSON).
7. `f_plt_big_3`: scale `1.0`, min `0.0`, max `2.96362733840942`, w 70, h 86, offset 5873; donor Name `:283912` confirmed, body NOT dumped ([U-quoted-only]); RFW `False`, Smooth `False` (per JSON).
8. `f_plt_mid_1`: scale `1.0`, min `-0.142846465110779`, max `2.97172260284424`, w 49, h 51, offset 2408; lib `pattern.lib:297115-297116` (Name `:297086`); RFW `False`, Smooth `False`.
9. `f_plt_mid_2`: scale `1.0`, min `0.0`, max `2.96314740180969`, w 45, h 53, offset 2296; donor Name `:302952` confirmed, body NOT dumped ([U-quoted-only]); RFW `False`, Smooth `False` (per JSON).
10. `d_plt1`: scale `1.0`, min `-0.620221674442291`, max `3.3239107131958`, w 51, h 63, offset 3108; lib `pattern.lib:89489-89490` (Name `:89460`); RFW `False`, Smooth `True` — builder must decide smooth handling (currently NOT emulated per `game.gd:155-156`; inherit PORT APPROXIMATION label or leave `Smooth` out of META as today).
11. `d_plt2`: scale `1.0`, min `0.0`, max `3.2039213180542`, w 57, h 58, offset 3200; donor Name `:94570` confirmed, body NOT dumped ([U-quoted-only]); RFW `False`, Smooth `False` (per JSON).
12. `hil1`: scale `0.649999976158142`, min `0.0`, max `3.86130237579346`, w 25, h 41, offset 968; lib `pattern.lib:33111-33112` (Name `:33082`); RFW `True`, Smooth `False`. NOTE non-1 scale.
13. `g_hil4`: scale `1.0`, min `-4.32127315701247e-13` (donor writes `E-13 :366499`), max `1.91698789596558`, w 33, h 59, offset 1864; lib `pattern.lib:366499-366500` (Name `:366470`); RFW `True`, Smooth `True` — same smooth-handling note as `d_plt1`.
14. `k_ravine_big_stone_1`: scale `1.0`, min `-2.96362733840942`, max `0.173864871263504`, w 84, h 100, offset 8225; lib `pattern.lib:730045-730046` (Name `:730016`); RFW `False`, Smooth `True` — same smooth-handling note.

Remaining blocker restated exactly: **owner/builder transcription of the above 14 rows into `RELIEF_GRID_META` (with a recorded per-id quote, which this report now supplies for 10 fully donor-dumped + 4 JSON-quoted ids) plus an explicit unblock decision; until then the live gate stays at 2 ids and run-180-style `candidates=0` remains the expected artefact, not a decode failure.** Four ids (`d_plt2`, `f_plt_big_2`, `f_plt_big_3`, `f_plt_mid_2`) still want a donor-body line dump before wiring (their `Name` lines are confirmed; bodies are one read away at the cited lines). Blend/smooth/row-sign semantics stay [U] regardless.

---

## 5. Evidence index (all [O] unless marked)

| # | Path:line | Class | What it establishes |
|---|---|---|---|
| E1 | `variant3d/assets/terrain_new/patterns/{14 ids}.json:47-54` | [O] | Per-id `flags` Scale/Min/Max/RFW/Stand/Smooth (§1 table) |
| E2 | `…/{14 ids}.json:58-59` + grid-array/w/sha lines (§1) | [O] | `grid_offset`, `h`, `relief_float_grid` array, `w`, `source_sha256` present per id |
| E3 | `…/{14 ids}.json:2` (+ `plt2.json:6` `"ok": true`) | [O] | `byte_closure` block; parsed `ok:true`, `actual==expected` all 14 |
| E4 | `C:\Games\Cossacks 3\data\pattern\pattern.lib:322-358` | [O] | `plt1` donor flags (read-only text, this ticket) |
| E5 | `pattern.lib:6776-6812` | [O] | `plt2` donor flags (confirms `DEC_reliefgate` §1.1 + task example) |
| E6 | `pattern.lib:13510-13546` | [O] | `plt3` donor flags |
| E7 | `pattern.lib:78064-78100` | [O] | `plt4_fixed` donor flags (RFW False) |
| E8 | `pattern.lib:24416-24452` | [O] | `plt5` donor flags (Scale 1.5) |
| E9 | `pattern.lib:89460-89494` | [O] | `d_plt1` donor flags (Smooth True) |
| E10 | `pattern.lib:272110-272144` | [O] | `f_plt_big_1` donor flags |
| E11 | `pattern.lib:297086-297120` | [O] | `f_plt_mid_1` donor flags |
| E12 | `pattern.lib:33082-33116` | [O] | `hil1` donor flags (Scale 0.65) |
| E13 | `pattern.lib:366470-366504` | [O] | `g_hil4` donor flags (Smooth True; Min exponent-case note) |
| E14 | `pattern.lib:730016-730050` | [O] | `k_ravine_big_stone_1` donor flags (Smooth True) |
| E15 | `pattern.lib:94570`, `:308342`, `:283912`, `:302952` (`Name` lines) | [O] | `d_plt2`, `f_plt_big_2/3`, `f_plt_mid_2` presence; bodies NOT dumped [U-quoted-only] |
| E16 | `docs/terrain_swarm_2026-11-26/reports/DEC_reliefgate.md:§4.2 (§4.1-§4.2, §5 E1-E18)` | [O]+[D] | Blocked condition wording; 15-name DEC set vs 14-name task set; 2-row META + 2-id gate |
| E17 | `variant3d/scripts/game.gd:153-172` | [O] | Provenance comment + 2-row `RELIEF_GRID_META` (still 2 rows — block not yet acted on) |
| E18 | `variant3d/scripts/game.gd:1487-1504,1507-1526,1571-1590` | [O] | Generic loader (name-agnostic), bilinear sampler (PORT APPROXIMATION), 2-id gate + candidate counter |

## 6. Open / UNVERIFIED

- U1. Donor flag bodies for `d_plt2`, `f_plt_big_2`, `f_plt_big_3`, `f_plt_mid_2` (Name lines confirmed; one read away) — dump before wiring.
- U2. `d_plt3..6` (DEC set, not task set): JSON flags parsed present, donor bodies NOT re-read this ticket (`Name :100660/:107982/:113092/:118566` per `DEC_reliefgate` §2) — out of scope for the task's 14.
- U3. Blend kernel, row-sign, smooth-pass emulation, Min-pivot/Max-unused clamp consumers — UNVERIFIED (inherit `game.gd:1509-1511`, X23 §3/§9 Q3, `DEC_reliefgate` §4.2/U2-U3).
- U4. Whether the owner accepts derived-JSON quotes (§1) as the §4.2 "read and quote" record for the 4 [U-quoted-only] ids, or requires their donor-body dumps too — owner decision.
- U5. Desert-branch plateau equivalents, per-seed stamp census for run 180 — out of scope, no claim.

*End of RELIEF_gate_verify. Exactly one repo file written. Donor read-only text; no code, no Godot, no git, no donor execution. Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD.*
