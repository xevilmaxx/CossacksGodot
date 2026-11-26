---
id: X54-GROUND-TRUTH-CARD-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X54 — one-page DONOR GROUND TRUTH CARD for owner + future agents"
agent: "X54 (read-only worker X54, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X54_ground_truth_card.md
files_created: [docs/terrain_swarm_2026-11-26/reports/X54_ground_truth_card.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists, no donor binary was executed by this worker, no gate was run. 'Corrected' means best cited donor byte/line/instruction, never visual fidelity."
scope_guard: "Exactly one repo file written (this card). Donor at C:\\Games\\Cossacks 3 read only via already-landed reports; no donor file opened for writing; no code/shader/asset/config/test/git/runner state touched."
sources_read: "Read in full: CHARTER.md, SWARM_BOARD.md, spec/00_EVIDENCE_INDEX.md, spec/02,03,04,05,06,07,09,10, reports/X27_decode_coverage.md, reports/V57_final_parity_statement.md, reports/X17_blendfunc_verification.md, reports/V08_coordinate_scale.md. Secondary verification via targeted grep of landed reports: X23,X26,X34,V37,V47,F01,D08,X08,V20,V21,V26,X19,X13,V33,V44,HANDOFF,REPORT_INDEX,spec/11. Claims about spec/01,08,11,13 come from spec/00's index rows, not a direct read of those files."
multiple_passes: true
multiple_pass_note: "Every row below was checked against at least two landed documents (spec text + source report, or two independent reports); contradictions were re-read in both readings and the later/instrument-cross-checked value kept (e.g. G=968/1864/2798/2222/8225 over X13's 1000/1912/2866; 19 keys over F03's '20'; B>=58 over B>58; 3 passes over cfg 6). No fact was invented or promoted on one reading."
---

# X54 — DONOR GROUND TRUTH CARD (one page)

**Label legend:** `[O]` observed literal donor byte/line/VA · `[D]` derived consequence · `[I]` interpretation · `[U]` UNVERIFIED · `PORT APPROX` = port-authored substitute. Donor paths are under `C:\Games\Cossacks 3\` (read-only). Nothing here is a parity claim.

## 1. Load-bearing constants / formulations (corrected → cite → label)

| # | Corrected load-bearing value / formulation (label) | Donor path:line / evidence (cross-read) |
|---|---|---|
| 1 | **RNG:** `s ← (s*0xFC0D + 0x3C6EF35F) mod 2^32`; `RandomExt() = f32(s / 2^32)`, in `[0,1)`. Reseed **same `key1` verbatim** — 11 `SetRandomKey(randkey1)` sites + 3 `SetRandomExtKey64(randkey0,randkey1)` resets; `GetRandomKey` returns `randkey1` (low word). No `mix64`. `[O]/[D]`; engine key→state `[U]`. | `cossacks.exe` CODE VA `0x60f64c`–`0x60f696`, divisor `2^32` at `0x60f698` (D02 §4.2; X27 E5); reseed sites D3:99,146; D1:1100,1161,1177,1213,1538,1616,1772,1909,1927 + D2:216,513,774 (X03 §6; V01 EV04–06; spec/02 §2/§4/§5; V57 §1 row 5) |
| 2 | **Mask→height:** `h = −1.1*B/255` (B=0→0 m; B=255→−1.1 m). Water `h<−0.25` ⇔ integer **B≥58**; shore `h<−0.1` ⇔ B≥24. **R/G = 0 on every non-start pixel** of all 1,331 shipped vanilla `_gauss` masks; only 5,125 single-pixel white starts (R=G=B=255); B spans all 256 values. Mask alone cannot yield ±2.964 m. `[O]` shipped pixels; R→class/G→forest code table is authored intent, inert `[O]` text; runtime `;`-prefixed lines `[U]`. | `generatemap.inc:4-7,567-574`; `texturemap.inc:29-31` (X03 §5c; spec/03 §1); F04 E11/E18 + X18/X19 full-corpus decode (spec/00 §3.3 rows, §4.2 P13; V57 §1 row 3); `B>58` is off-by-one ⇒ B≥59 (X27 §6 C7) |
| 3 | **Relief stamp — 3 blend paths** (governs stamp stage): `ReplaceForWater` → `new = g*Scale + Offset`; `Replace` → `new = base_h + (g−Min)*Scale + Min + Offset`; default `Smooth` → `new = h1 + (base_h−h0)*TerrainScale + (g−Min)*Scale + Min + Offset` (two `getHeight` reads). **`Min` is pivot, `HeightFieldMax` never read, `Offset` additive, no `[Min,Max]` clamp**; negative `Scale` (−0.925) inverts grid/pivot, not world height. `[O]` opcodes. | `sub_755f30` VA `0x755f30`, x87 `0x7563e8`–`0x7566e9` (D05 E9/E15; X12 E5/E11; X26 E8); zero `+0x60` operands in 6,751 instr; config offsets `Min +0x5c`/`Max +0x60`/`Offset +0x64` (spec/04 §6; spec/00 §2 row 9; V57 §1 row 6) |
| 4 | **Grid offsets:** `G = 8 + (w−1)(h−1)`; `filesize = 8+4wh+54(w−1)(h−1)` closes 710/710. Offsets **968 (`hil1`) / 1864 (`g_hil4`) / 2798 (`k_ravine_1`) / 2222 (`plt2`) / 8225 (`k_ravine_big_stone_1`)**. `[O]/[D]`; X13 `1000/1912/2866` = shifted windows, refuted for addressing. | `*.pattern:0-7` + F01 E4/E8–E11 (710/710; 550,908 `Rec24`); X23 E2 (5/5 offsets); X34 §4; V47 E06; spec/04 §4/§6; V57 §1 row 1 |
| 5 | **Stamp post-pass is IN-PLACE:** after the blend, interior-only, 8-neighbour gate, radial remap `(Radius−Offset)/d`, `Factor` iterations of a 4-neighbour mean with hardcoded divisor `4.0`; `sub_755db4` = 4 `getHeight` + 1 `setHeight`, **no snapshot/double buffer**. `[O]`; double-buffer = `PORT APPROX`. | `cossacks.exe:0x755db4`, `/4.0f` at `0x755ee4` (D05 E10/F5; X26 P5/S4/E8/E9; V47 V47-24; spec/04 §6; X27 §3.3) |
| 6 | **Four water levels — do not conflate:** `cWaterHeight = −1.1` basin depth (`generatemap.inc:7`); `cOffsetY = −0.5` `WaterFieldAdd` Y (`generatemap.inc:688,704`, runtime `[U]`); `cWaterHeight = −0.25` tile classify (`texturemap.inc:29-30,466-467`); `cWaterShoreHeight = −0.1` shore band (`texturemap.inc:31,463-472`). `[O]` text. | D06 §2/§3; X03 §5d/5e; spec/05 §1; spec/00 §2 row 10; V57 §1 row 8 |
| 7 | **`bmTransparency` = `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`** — VA `0x4ef991`/`0x88fbb0`/`0x88fbb7`, factor table `0x8fb1c4`/`0x8fb1c8` (770/771). Donor shader does **no mask→RGB multiply**: mask alpha is a framebuffer crossfade weight, `dst' = src.rgb*src.a + dst.rgb*(1−src.a)`; port `rgb*a` at `terrain_tileindex.gdshader:427` is `PORT APPROX`. Composite **pass count `[U]`** after six passes. `[O]/[D]`. | `hf.pvl.smx3.frag:13-17,50`; `shaders.lib:15-49` (X17 §3.1/§3.2/E1–E16; D08 §3.5; F06 §5; X27 E14; spec/06 §5; V57 §1 row 7) |
| 8 | **Tile ids / atlas:** **124 tile ids per season** (`terrain.presets:6-129` Summer, `:138-261` Winter, `DefaultIndex=0`); port **16×8** atlas `i → (i%16, i//16)` is a `PORT APPROX` container (121 filled/3 EMPTY, 36 `FACE_BASE_REUSE`); donor `alphanull` binds ids **86/110/123**. `[O]` ids / `PORT APPROX` atlas. | F05 E01/E04/E12/E13; X06 E01–E07 (121/121 cell-exact); spec/06 §1/§2/§7; spec/00 §2 row 11 |
| 9 | **Tile smoothing:** **22 chains** / 118 active groups / 282 active entries / 86 names / ΣProb=174.0168 (`tilesmooth_scripts.cfg:1-1863`); **3 passes**, each a horizontal sweep then a vertical sweep, **in place** on `atilemap`, one write-back (`smoothtiles.inc:200-242,237`). Atomic op = one axis-aligned adjacent tile pair. `[O]/[D]`; cfg `TileSmoothPasses=6` + `tilesmooth.cfg` are preserved editor contradictions. | D08 §0/§3.3/§4; X08 E08/V1–V11; V20 §5; F03 §6; V21 GR-A18; HANDOFF §36; `globalparams.cfg:9-10` |
| 10 | **Mines — radii in map CELLS:** ring0 `14+8R`, ring1 `32+10R`, ring2 `70+12R`, ring3 `22+16R` (v≥80, `mapsize>2`), ring4 skipped; bands **shared by all three ores** `j=0..2` (`mng/mni/mnc`), **256 angle tries** per ore per ring, rounds **3/4/5** for `minesdensity 0/1/2`. `[O]` text; cell unit `[D]`. `mapsize>2` = 256-cell TINY map; `gDataVersion=92`. | `dogenerate.inc:522-717` (`:525,:528-534,:544-557,:595-601,:704-713`); V12 §2; X03 §8; V01 P4; D07 §1; spec/07 §1/§7; `serial.script:27`; `donewgame.inc:42-46`. Cell proof: V08 C1/E14–E16 |
| 11 | **Keep-clear ellipses:** **5×7 / 12×15 / 22×18**, centred `(start.x, start.y+2)`. `[O]`. These are keep-clear, not placement regions. | `dogenerate.inc:407-416,769,947,984`; V01 EV09; V12 §2; spec/07 §2; spec/00 §2 row 12 |
| 12 | **No food rects + script-sown fields:** `SetupStartingResources` places **six attempted stone/forest items only — zero food/field rects** `[O]`; fields are created later by `_unit_DoSeedWheat` → **7×7 = 49 runtime nodes**, `size=1.6981` map cells, 45° lattice, `size2=√2·size`, 5 gold per field; `envfieldd`/`envfielddw` decals. `[O]` text / runtime `[U]`. | `dogenerate.inc:720-977`; `unit.script:6470-6570`; F07 E1; X22 X-E01–E10; V12 C-V4; V26 C2; spec/07 §1; spec/08; spec/00 §2 row 13 |
| 13 | **Start masks are per-country RELATIVE templates** (unit/building stamp around a start), **not terrain masks and not start-position selectors**; 19 presets / 61 masks / 276 legend entries; separate occupancy circles r=5 building / r=1 unit. `[O]` text / runtime `[U]`. | `startingsettings.cfg:1-3424` (SHA `17d4aedd…`); X09 E1–E24/§0/§2; spec/07 §9; spec/00 §3.7 row 183 |
| 14 | **`globalparams.cfg` has 19 flat keys** (`:2-20`, 537 B, 22 lines, SHA `15a8dc64…`). F03 summary "20" is an authoring error, not a missing 20th key. `[O]`. | spec/09 §1/§2; V37 §2 (two re-reads); X20:104,204-214 (four passes); F03 §2/§3.1 |
| 15 | **`DONOR_UNITS=160` REFUTED:** 1 generator distance unit = 1 map cell; port `s=W/160` (`donor_gen.py:59,147-158,193`; `pattern_gen.gd:9,92`) is port-invented and doubles radii at 320² (×1.5 at 240²). `[D]` refutation. | V08 C1/E23/E29/E30 + §3/C1 (three passes); `miscext2.script:19-26`; `dogenerate.inc:402-405,521,559-655,1335-1345`; spec/00 §4.2 P16; spec/07 §8 |
| 16 | **`TILE_M = 2.0` is donor-grounded HORIZONTALLY:** `gc_meters_to_tile=2` ⇒ 1 cell/tile = 2 m (`dmscript.global:170-173`, with `gc_pixels_to_meter=26.6666666`, `gc_pixels_to_tile=53.3333333`, `gc_tiles_to_pixels=0.01875`). Stored `height` unit remains `[U]` — no donor line assigns a unit; `HEIGHT_SCALE=1.0` is a port approximation. `[O]+[D]` horizontal / `[U]` vertical. | V08 C2/E5/E26 + §3/C2; `dmscript.global:2026-2030`; spec/00 §3.1 row 13; spec/07 §8; V57 §2.3 U13 |

## 2. Common wrong beliefs — DO NOT implement these

| Wrong belief | Corrected reading (evidence) |
|---|---|
| **`mix64` per-stage key derivation** | REFUTED — all reseeds pass `randkey1` verbatim; donor restarts the same stream, it does not derive independent stage keys (V01 P1/P2; spec/02 §5; SWARM_BOARD C8; V57 §1 row 5). |
| **`B>58` water test** | Off-by-one: integer `B>58` ⇒ B≥59; donor `h<−0.25` ⇔ **B≥58** (`−1.1*58/255 = −0.250196…`). Med/22 mismatch 22 px (X19 E5/E20; F04 §6; spec/00 §4.2 P13; X27 §6 C7). |
| **`HEIGHT_SCALE` fudge / non-1.0 multiplier** | Forbidden. Stored-height unit is `[U]`, but no donor line licenses a fudge factor; keep raw float + labelled `HEIGHT_SCALE=1.0` (P06 §2; spec/10 §3; V08 E26; V33; V44). |
| **6 smoothing passes** | Preserved donor contradiction only: `globalparams.cfg:9` says `TileSmoothPasses=6`, skirmish script hard-codes `SmoothTileMap(...,3)` (`smoothtiles.inc:237`). Follow the script = **3 in-place H-then-V passes**; never promote 6 (F03 §4; D08 §0; V20; X27 §6 C5; V21 MP2). |
| **3×3 smoothing kernel** | No 3×3 kernel exists. Atomic op = a single axis-aligned adjacent tile pair; 3 horizontal→vertical in-place sweeps, one write-back. Port `mapgen.gd:228-235` four-diagonal average is `PORT APPROX` (X08 §0:33-37/§5.4; V20 §0.3/E09; V33 D18). |
| **Height-as-albedo (H03/H05/H04)** | REFUTED — donor shader never multiplies mask into RGB; height drives geometry, tile art is a separate channel. Port `rgb*a` at `terrain_tileindex.gdshader:427` is `PORT APPROX` (P06 §2 #6; spec/10 §3; X17 §3.2/§4; F06). |
| **`DONOR_UNITS` doubling (`s=W/160`)** | REFUTED — all mine/ellipse/field radii are map cells, 1:1; do not multiply by W/160 (V08 C1; spec/00 §4.2 P16; spec/07 §8). |

## 3. Verification & guard

Every row above was re-read against a second landed source before writing; where two reports disagreed, both readings were recorded and the instrument-cross-checked value kept (§4.2 P1–P16 of `spec/00`, X27 §6 C1–C10, V57 §3 P1–P8). This card contains no new donor constant, no threshold change and no synthetic value. It is a **decode/spec aid only**: all script-derived constants come from `;`-prefixed `[*] = ;` text whose runtime activation is `[U]` (X27 §4 Category A); pass count, row sign, global setter clamp, `hmapTex` binding and the stored height unit remain `[U]`.

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

*End of X54 card. Exactly one repo file written; no donor binary executed or copied; no code, asset, config, test, git or Godot/runner state changed; no donor-parity claim.*
