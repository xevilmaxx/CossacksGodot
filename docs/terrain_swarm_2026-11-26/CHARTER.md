---
id: TERRAIN-SWARM-2026-11-26
title: "DONOR-FIRST terrain port — decode the donor bit by bit, then clone its behaviour in variant3d"
owner: COORD (this session)
created: 2026-11-26
status: ACTIVE
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
supersedes_in_scope: docs/terrain_swarm_2026-11-25/CHARTER.md
---

# CHARTER — donor-first terrain port (2026-11-26)

## 1. Why this wave exists

Previous waves patched `variant3d/scripts/game.gd`, `world3d_terrain.gd` and the
tile-index shader directly. They produced green functional gates but **no donor
visual parity**: radial "maze" rock rings, repeated diagonal veins, flat relief,
no readable hills/mountains/mill fields/shore. The owner's directive today:

> "instead of trying to fix existent things directly ... try to understand how
> donor did it and how we can do in similar way ... clone donor behaviour at
> least regarding terrain generation with all needed assets properly, hills
> mountains, mill fields, sea, shore and other parts of landshaft like forests
> stone mines other kind of mines and so on."

**Today's rule: understand first, build second.** No existing terrain file is
edited until a donor-grounded specification exists. We work **only in
`variant3d/`**; `app/` stays byte-untouched. Donor at `C:\Games\Cossacks 3`
(read-only, private use, never execute a donor binary, never commit donor
binaries).

## 2. What "decode EVERY SINGLE bit of the DONOR" means operationally

Four complementary evidence sources, all read-only:

| Source | Tool | Goal |
|---|---|---|
| `cossacks.exe` 5.18 MB `CODE` + RTTI | Craft Anything **Deep mode / Ghidra lifter** (`native_functions_list`, `native_function_pseudocode`, `core_feature_find`, `native_strings_find`) | Anchor terrain subsystems (`XMapGenerator`, `XTerrainDataLite`, `XTileSmooth`, `XWater`, `XPattern`, `XSeason`) to concrete functions; decompile seed/RNG, mask decode, relief stamp, smooth, water/shore, resource placement, tile selection. |
| `data/pattern/*.pattern` + `pattern.lib` (30 MB) | Python `bytes` + latin-1 | Recover the exact binary layout of every pattern record: relief float grids, object lists (trees/rocks/mines/fields/pumps), footprint/collision, weights. Build a real parser, not a guess. |
| `data/gen/*.cfg`, `data/gen/terrainmasks/**`, `data/terrain/**`, `data/scripts/**`, `data/shaders/**` | text + TGA/BMP decoders | Recover constants (heights, thresholds, frequencies, counts), mask channel semantics, tile/atlas mapping, `bmTransparency` masks, editor/DScript generation commands. |
| donor screenshots / almanac evidence | read-only | Define the visual acceptance target (hills, mountains, fields, sea, shore, forests, mines) without claiming parity until a real A/B GPU frame exists. |

Every finding carries a **donor path:offset:line or evidence id**. Anything not
directly recovered is labelled **UNVERIFIED** or **PORT APPROXIMATION**.

## 3. Deliverable for the day

A **donor-faithful terrain specification + conversion toolchain + clean
implementation in `variant3d/`**, in this order:

1. **Spec** (`docs/terrain_swarm_2026-11-26/spec/`): data model and algorithms,
   each claim cited to donor evidence.
2. **Decoder/compiler** (`variant3d/tools/`): Python tools that turn donor
   `.pattern` / terrainmask / cfg / block PNG data into runtime assets a new
   Godot terrain module can consume. Donor binaries are never copied into the
   repo; only derived, labelled assets.
3. **Fresh terrain module** (`variant3d/scripts/terrain_donor_*.gd` + shader if
   needed): reproduces the donor pipeline stage-for-stage (mask → height →
   relief stamp → smooth → water/shore → tile ids → props/mines/fields). It is
   composed by `world3d.gd`; the legacy `world3d_terrain.gd` path is retained
   behind a switch until A/B passes, then retired. No gate weakening.
4. **QA**: deterministic seed replay, histogram + capture A/B against donor
   screenshots, gates: selftest 29/29, uitest 17/17, `t_render_mode`,
   `assert_clean` CLEAN, `app/` byte-identical.

## 4. Guardrails (binding on every worker)

- **Read-only donor.** No donor executable is run, no donor binary is copied or
  committed. Craft Anything read tools only. Donor material = private use only.
- **Labels mandatory.** `[O]` observed / `[D]` derived / `[I]` inferred /
  `[U]` UNVERIFIED / `PORT APPROXIMATION`. No donor-parity claim without a real
  donor GPU A/B frame.
- **One report per worker, disjoint ownership.** Analysis workers edit ONLY
  their own report file under `reports/`. No source/shader/config/asset/test/git
  edits. COORD integrates.
- **Craft Anything is a shared session.** `core_target_open` / `core_target_select`
  change the *global active target*. Always state which target you used; prefer
  `path=` parameters on `core_target_triage` / `core_text_read`. Do not overwrite
  another worker's investigation plan; append findings, never reset the brief.
- **One Godot at a time**, via `python variant3d\tools\godot_runner.py run --id
  <UNIQUE>`. Analysis workers submit **no** runner jobs. Implementation workers
  ask COORD first.
- **No invention.** No new donor constants, no synthetic noise/dither field
  (S-25-09), no threshold lowered, no assertion deleted, no fake A/B.
- **Multiple passes on anomalies (owner directive).** If a decompiled function,
  struct, constant or byte pattern looks strange, garbled, unstructured or
  contradictory, do NOT skip it after one attempt. Re-run it with a second
  instrument: `native_function_study` (Deep/Ghidra dossier) vs
  `native_function_pseudocode` (clean-room lifter), assembly/bytes, callers/
  callees, xrefs, vtable pointers, and where possible a second target
  (`editor.exe` vs `cossacks.exe`) or a second decoder. Record every pass,
  what changed, and why the final reading was accepted — or mark it
  `[U] UNVERIFIED` with the passes attempted. Silent skipping is a defect.
- **Windows:** use `python`, PowerShell `;`, paths quoted.

## 5. Swarm board — 30 concurrent workers

All reports land in `docs/terrain_swarm_2026-11-26/reports/`.

### Wave D — donor binary / Ghidra (D01–D08)
D01 RTTI→function anchor map · D02 seed + RNG · D03 terrainmask decode/blur/smooth ·
D04 `.map`/`TTile` format · D05 relief stamp + height field scale · D06 water/shore ·
D07 mines/stone/forest placement · D08 tile/atlas/shader selection.

### Wave F — donor data formats (F01–F10)
F01 `.pattern` binary format · F02 `pattern.lib` index · F03 gen cfg constants ·
F04 terrainmask TGA channels/counts · F05 `reftile.mat`/`texturemap.inc` tile ids ·
F06 alpha/alphavert `bmTransparency` · F07 mill/field/pump assets ·
F08 forest/stone/mine families · F09 `editor.inc` + `editor.aix` DScript terrain API ·
F10 DLC/expansion terrain additions.

### Wave P — port baseline audit (P01–P06)
P01 current terrain pipeline end-to-end · P02 donor-derived asset inventory ·
P03 tests/gates/capture tooling · P04 existing decoder tools ·
P05 2D `app/` reusable pieces (read-only) · P06 2026-11-25 report distillation.

### Wave A — design (A01–A06)
A01 data model · A02 generation algorithm · A03 asset conversion pipeline ·
A04 landscape prop rendering (hills/mountains/fields/sea/shore/forests/mines) ·
A05 QA / A-B harness · A06 integration + rollback plan.

## 6. Definition of "good" (owner-facing)

1. Every landscape class in the donor is accounted for with a cited rule:
   hills, mountains, mill fields, sea, shore, forests, stone quarries, gold/iron/
   coal mines, rivers/swamps, decor — either implemented or explicitly
   out-of-scope with reason.
2. The new terrain module is a **fresh, donor-shaped pipeline**, not a patch on
   the radial-dome/rock-art code; its data and stage order match the spec.
3. Same seed ⇒ byte-identical output; 240² and 320² maps both work.
4. A fresh windowed capture shows readable relief, natural shore and organic
   field/forest/mine placement; no concentric rings, no diagonal vein lattice,
   no hard grid.
5. Gates remain green; `app/` untouched; no donor parity claim unless a real
   donor GPU A/B frame is produced.

## 7. Outcome / honest ceiling (point-in-time, 2026-11-26)

> This section records what the day actually achieved. It changes no rule above:
> the read-only/no-execution/label/parity guardrails of §4 and the owner-facing
> criteria of §6 remain binding. Every count is point-in-time; file presence is
> evidence of existence only, never correctness, a gate PASS or donor fidelity.

- **[O] Data formats are byte-exact, with counts.** `.pattern` size law
  `S = 8+4wh+54(w−1)(h−1)` holds **710/710** with zero residual (**678/680** min/max
  bit-exact, **550,908** `Rec24`); `pattern.lib` **30,309,138 B** plaintext / **680**
  sections / **39,780** object records / **235** `BaseName`; **4,466** terrainmask
  TGAs (**1,331** vanilla + **1,856** dlc5 + **1,279** src) with `h = −1.1·B/255`;
  **7** gen cfg files (**64** families / **493** `Pattern=Freq` pairs, **22** chains /
  **118** active groups / **282** active entries / **86** names); exact 32-bit LCG;
  **124** tile ids/season; 37-byte `.map` records **102,400/102,400** and
  **147,456/147,456**. These are decode-integrity results, **not** tier-1 verdicts
  and **not** fidelity (X27 §2, V81 §2.1).
- **[O] Binaries are complete over discovered functions only.** **18,918/18,918**
  `cossacks.exe` and **22,384/22,384** `editor.exe` *discovered* functions were
  exported, but the lifter marks **4,265 (22.54%)** and **12,254 (54.7%)** as
  garbled/unstructured; only **11/34** D01 terrain anchors are present (**23 absent**)
  and ~45/64 class constructors stay `[U]`. Never quote the export totals without
  the garble and anchor counts; "whole binary decoded" is false (X27 §2/§6 C9).
- **[O] The packed stub is genuinely undecodable: 2.786%.** Five PEs carry a
  **146,800-byte**, entropy-**7.965** `.bind`/`WUS1` tail = **835,376 / 29,987,184 B**
  (**2.786%** of seven PEs; **2.152%** of the two terrain-relevant PEs). X31
  statically recovered the GetPC stub and a 240-byte rolling-XOR descriptor (magic
  `0xC0DEC0DF`, OEP equal to the already-readable `.exe` entry), but the residual
  high-entropy payload was never unpacked or executed; a complete offline unpacker
  is not feasible under §4 and would yield no new terrain code. No strings/functions
  there is `[U]`, not proof of absence (X31 §6/§8).
- **[U] Runtime intent is not execution — the single biggest categorical gap.**
  All **972** X03 `.inc` excerpts and all F03 cfg literals are `;`-prefixed; no donor
  binary was run, so no compiled path was observed consuming a decoded value.
  `bmTransparency` pass count (six X17 passes), `hmapTex` binding/plane Y, native
  kernels (`SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`, `WaterFieldAdd`),
  `.pattern` field semantics, `.map` tag/owner/collision fields, `GenerateMapRandKey`
  and saved-map key bytes remain `[U]`; every port visual stays `PORT APPROXIMATION`.
- **[D] "Every single bit" is not achievable under these read-only rules and was not
  achieved.** The honest ceiling is byte-level closure of readable terrain-relevant
  data plus on-demand instruction reads of named functions, with every
  runtime-dependent claim permanently `[U]`/`PORT APPROXIMATION`. Lifting it needs a
  VMT-pointer discovery pass plus a second lifter, or a permitted donor runtime/GL
  trace — both outside today's rules (X27 §7).
- **[O] No parity claim.** No donor GPU A/B frame exists: `parity.claim = NONE`,
  `parity.status = "UNVERIFIED"`, no tier above 2 in the V15 vocabulary, and
  `blocking_unverified` is non-empty ⇒ `RESULT IS NOT GOOD`. The scaffold
  (I01–I13 + N14, 780 `terrain_new` JSONs, V48 patches applied, V61/V65 **static**
  API PASS) is default-legacy and ungated; **no gate was run for today's tree**, so
  none of it is a green result, a cloned terrain, or a donor match. (V81 §1/§3/§7.)

*End of charter.*
