# T6-S01 — Donor projection branch and terrain heightfield resolution

**Ticket:** T6-S01 (LANE RESEARCH, read-only). **Executed by:** T6-RESEARCH parent
(no child session — `subagent` tool unavailable inside child sessions per
SWARM_OPS.md §7.2 lines 226–243; work done directly). **Date:** 2026-11-23.
**Boundaries:** private use only; donor never executed; no donor file copied into
the repo; no Godot job; no code/asset edit.

**Labels:** `observed` = literal file line / decompiled instruction / filesystem
fact; `derived` = arithmetic or structural consequence of observed facts;
`inferred` = plausible reading with a stated caveat; `UNVERIFIED` = not provable
from the evidence available without running the donor. An inference is never
promoted to a fact.

**Baselines read first:** `docs/audit/RENDER_ARCH_CAMERA.md`,
`docs/audit/RENDER_ARCH_CRAFT_ANYTHING.md`, `docs/audit/RENDER_ARCH_SHADERS.md`.

---

## 1. Question

1. Which branch of the donor's decompiled projection switch — `glFrustum`
   (perspective) or `glOrtho` (orthographic) — drives the **main RTS world view**?
   The camera config says focal length 400 / tilt −32°, but the binary contains
   both projection calls, so this was left as `unk_a6b4c11945b0a5fa`
   (RENDER_ARCH_CRAFT_ANYTHING.md §4) / open question 1
   (RENDER_ARCH_CAMERA.md §7).
2. What is the **terrain heightfield resolution** (`unk_48db9a938053a100`,
   high severity in RENDER_ARCH_CRAFT_ANYTHING.md §4)?

---

## 2. Evidence base

### 2.1 Craft Anything (this session, target `t_87f0f3c130b0`, `cossacks.exe`
sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`,
Deep/Ghidra + built-in engine, read-only)

| Evidence id | What it is |
|---|---|
| `ev_030dff8cf94750f365aed8d45cc37da9aff2b4388d86311bba996d057f51d5c3` | Ghidra pseudo-C of `FUN_004cd334` (projection setup, 114 lines) — the full switch |
| `ev_6a85f244121e38c9faa4434c6f4ddf0ff90d5b57db63823278852f46be2ef4fa` | Pseudo-C of `FUN_005d1c60` — viewport/clear path that calls the projection setup |
| `ev_0f24561cd300ffb179d26853e9642c50b9505e7389239a0e9b46cb406c8789ad` | Pseudo-C of `FUN_00777c80` — second caller of the projection setup |
| `ev_10f78080dba8e2bd3ca0717c2bb735ec1a8e5717f16d8b50984d07aebc29cfba` | Pseudo-C of `FUN_008127d8` — sets renderer byte `+0xC8 = 0` |
| `ev_f05b04f650726654ae5d861236ba9aa9a0975982ab6989d3dc89015621f9141a` | Pseudo-C of `FUN_00812ae0` — sets `+0xC8 = 0`, optionally `= 1` |
| `ev_e3a4cf1e4daad76f14fa995a466c317be19a89803b64d4e3bec33b88f5439721` | Pseudo-C of `FUN_008127b8` — wrapper around `FUN_00812ae0` |
| `ev_bc416c54b7291a915c5c1232175c5cc849136f0af937edc0149c41cdf2d2e0e3` | Pseudo-C of `sub_812a44` — object construction path that calls `FUN_008127d8` (built-in decompiler, lower confidence: `register_level`, `inline_asm`) |
| `ev_0f634d4b57f5c6f2ab79d885eea57263ba07ff702ff7509fccd2d4df1bf0f943` | Byte search `C6 80 C8 00 00 00 ??` → 3 writes to `[eax+0xC8]`: `0x8127d8`=0, `0x812ae3`=0, `0x812b06`=1 |
| `ev_cc0ee18b3825c0168423c9c077becad0299ad47c7bdd3aa95aa7016cb9131d5d` | `glFrustum` xrefs: one real call from `sub_4cd334` at `0x4cd626` |
| `ev_3e2611e359460b629cb1db1efd163e47f801a92f72130b2ecdcddcd9325bea5f` | `glOrtho` xrefs: one real call from `sub_4cd334` at `0x4cd771` |
| `ev_9974b6a2da79fdd18197f61b662c3b9789868c24341644e277617747da3cb277` | `gluOrtho2D` xrefs: one real call from `sub_4cd334` at `0x4cd38c` |
| `ev_c694939291946a2c756cdd05a85c18430c9f5f96b0ec03f64325517d5fca7dac` | `gluPerspective` imported but **0** call sites |
| `ev_18bd0b8462aad81d35313eadcdfd3536730005865592a4fc3f9369f7997276c7` | RTTI/string `HXHeightField` |
| `ev_d6218c9c01f6027c45ec6b041fc3a16d4d7f64d4861551e6ba6c35f58192ca90` | RTTI/string `XCamera` (+ `XCameraTrack`) |

The projection xref ids reproduce the earlier R-ARCH-CA ledger exactly
(`ev_cc0ee18b…`, `ev_3e2611e3…`, `ev_9974b6a2…`, `ev_c6949392…`) — **independent
re-verification** of the baseline (§5b-QUALITY rule 2).

### 2.2 Donor plaintext (all read-only)

| File:line | Fact |
|---|---|
| `data\cameras\camera.cfg:44-45` | `MinFocalLength = MaxFocalLength = 400` |
| `data\cameras\camera.cfg:32-35` | tilt pinned to `-32` at min and max height |
| `data\cameras\camera.cfg:51-64` | DOF / fog / near-far keys (fixed ⇒ effectively disabled) |
| `data\cameras\default.cameras:17-18` | `FocalLength=400`, `DepthOfView=1200` |
| `data\gui\menu.inc\docreate.inc:91,94` | `SetCameraControlMode('ccmRTS')`, `SetCameraDynamicFocalLength(...)` |
| `data\gui\menu.inc\onresize.inc:116-125` | forces focal 400 and the four tilt slots to −32 |
| `data\scripts\lib\miscext2.script:19-26,45` | random-map size enum → `w` ∈ {320,480,640,256}; `SetMapNeeded(..., w, w, ...)` |
| `data\scripts\dmscript.global:132-135` | `gc_MaxMapWidth/Height = 640`; `gc_MaxColMapWidth/Height = 2×640` |
| `data\gen\globalparams.cfg:2,6,8` | `Size = 512`, `CellsResolution = 1`, `DefaultMapSize = 256` |
| `data\scripts\lib\init.script:211` | `NewMap(128, 128, 0)` (engine startup default, before a map loads) |
| `data\scripts\common.inc\generatemap.inc:71,77` | editor form 'Map Size (320-640)'; `NewMap(genmapsize, genmapsize, 0)` |

### 2.3 Port (read-only)

`app/scripts/game.gd:16,20-21`: `TILE := 2.0`, `MAP_W := MAP_H := 160`;
`app/scripts/data.gd:33-34`: `MAP_W/H := 160` with comment "the port map;
original is 640". `app/scripts/camera.gd` is `Camera2D` (baseline findings).

---

## 3. Finding 1 — projection branch

### 3.1 The switch, verbatim from decompiled `FUN_004cd334` (observed)

The function takes the renderer object in `param_1` and branches on the byte at
`param_1 + 200` (= `+0xC8`):

| Byte at renderer+0xC8 | Projection call | Meaning |
|---|---|---|
| `0x00` | `glFrustum()` | **3D perspective** |
| `0x01` | `glOrtho()` | 3D orthographic |
| `0x02` | `gluOrtho2D()` | flat 2D overlay (HUD) |
| `0x03` | indirect call `**(code **)(param_1+0xe0)(param_1+0xe4)` | custom projection callback |
| `0x04` | 16-float matrix + `glMultMatrixf()` | custom projection matrix |
| other | no projection call | — |

**Correction to baseline:** RENDER_ARCH_CRAFT_ANYTHING.md F3 tabulated
"mode 2 / 3 → `gluOrtho2D`" and "mode 4 → custom callback". The full pseudo-C
shows **2 = `gluOrtho2D`, 3 = callback, 4 = custom matrix** (observed,
`ev_030dff8c…`). The baseline's high-level conclusion (three real 3D/2D passes)
is unchanged.

For modes 0 and 1 the frustum extents use
`*(float*)(param_1+0xac)`, `+0xa0`, `+0xcc`, `+0xd0`, near `param_4`, far
`param_6`; for mode 1 (`glOrtho`) the same expression is evaluated but the
orthographic branch is selected by the byte, not by the camera config.

### 3.2 Who sets the byte (observed)

- `FUN_008127d8(renderer)` is exactly `*(byte *)(renderer+0xC8) = 0` — set
  **perspective** (`ev_10f78080…`, 8-line Ghidra pseudo-C; also byte-write at
  `0x8127d8` in `ev_0f634d4b…`).
- `FUN_00812ae0(renderer, …)` sets `+0xC8 = 0` first, writes floats at
  `+0xb0/+0xb4`, then sets `+0xC8 = 1` if `*(short*)(renderer+0xB2) != 0`
  — i.e. orthographic is an **explicit alternative setter**, not the default
  (`ev_f05b04f6…`; byte-writes at `0x812ae3`=0, `0x812b06`=1).
- `FUN_008127b8(renderer)` only calls `FUN_00812ae0` when `+0xac == 0`
  (`ev_e3a4cf1e…`) — a conditional reset path.
- `sub_812a44` (an allocating/initialising routine: calls an allocator, sets
  fields at `+0x130/+0x140/+0x144`, then `FUN_008127d8`, then `sub_4c980c`)
  **calls the perspective setter during construction** (`ev_bc416c54…`;
  confidence lower — built-in decompiler, register-level, 3 inline-asm lines).

### 3.3 Who calls the projection switch (observed)

- `FUN_005d1c60` — after `glClear()` and a `glViewport()` recompute, calls
  `FUN_004cd334(*(renderer*)(*param_2+0x4c), …, width=*(param_1+0x44),
  near=*(renderer+0xa4), 0x60, height=*(param_1+0x48))`. This is the **main
  viewport/world render path** (`ev_6a85f244…`).
- `FUN_00777c80` — a thin helper that calls `FUN_00777cd0(...,0x60,h)` then the
  same projection function (`ev_0f24561c…`).

Both call sites use the same `0x60` parameter and the same renderer pointer;
there is no separate "main camera" object distinct from the renderer whose
`+0xC8` selects the pass.

### 3.4 Correlation with the camera config (observed + derived)

The main camera is parameterised by **focal length 400** and tilt −32° with an
orbital dolly (20…58), DOF and depth fog; no ortho extent key exists anywhere in
`data\**` (full-tree grep, RENDER_ARCH_CAMERA.md §2.4). Orthographic cameras have
an extent, not a focal length. The default constructor selects mode 0
(perspective). `gluPerspective` is imported but **never called**
(`ev_c6949392…`): the engine builds its own frustum via `glFrustum` from focal
length / near / far / viewport — exactly the code seen in `FUN_004cd334`.

### 3.5 Verdict

> **For the normal gameplay world view, the donor selects the perspective
> branch (`glFrustum`, renderer byte `+0xC8 == 0`).** The orthographic branch
> exists but is reached only when some other code calls the alternative setter
> `FUN_00812ae0` with its condition true; nothing in the camera configuration
> or scripts requests orthographic, and the renderer constructor sets mode 0.
> `gluOrtho2D` (mode 2) is the flat 2D HUD pass; mode 3/4 are custom projection
> callbacks. This resolves `unk_a6b4c11945b0a5fa` to **perspective**.

- Status: **`derived` (strong)** from observed binary control flow + observed
  config; **not `observed` at runtime**. A direct runtime observation of
  `renderer+0xC8` during a donor frame is forbidden by this lane's charter and
  is the only thing that would promote it to `observed`.
- `inferred` nuance: because a long focal length with a fixed tilt looks
  near-isometric, the orthographic branch may be used by the **editor minimap or
  a debug view**; no evidence found either way. Do not claim this as fact.

### 3.6 Absolute FOV remains UNVERIFIED
No sensor width / FOV constant exists in donor config (baseline open question).
`f = 400` ⇒ ≈5.2° only under an assumed 36 mm sensor. Keep UNVERIFIED.

---

## 4. Finding 2 — terrain heightfield resolution

### 4.1 Observed grid sizes

Random skirmish maps choose the square map grid from
`gMap.settings.gen.mapsize` (`data\scripts\lib\miscext2.script:19-26`):

| Setting value | `w` (= width **and** height passed to `SetMapNeeded` at `:45`) |
|---:|---:|
| 0 | 320 |
| 1 | 480 |
| 2 | 640 |
| 3 | 256 |
| else | 320 (default) |

`data\scripts\dmscript.global:132-135` caps the grid at 640×640 and allocates a
**2× collision grid** (1280×1280). `data\gen\globalparams.cfg:2,6,8` carries
`Size = 512`, `CellsResolution = 1`, `DefaultMapSize = 256`; the exact semantics
of `Size` and `CellsResolution` are **UNVERIFIED** (no script consumer found).

`SetHeightData(x, y, res)` / `GetHeightData(x, y)` are indexed by the same
grid coordinates (`generatemap.inc:242,574`; `texturemap.inc:434-437`), so the
**height data grid is the map grid**: 256², 320², 480² or 640² samples, one per
cell, variable by the skirmish size setting.

### 4.2 Port comparison (observed)

The port uses `MAP_W = MAP_H = 160` cells at `TILE = 2.0 m`
(`game.gd:16,20-21`), i.e. a 160² height sample grid. The donor's *smallest*
setting is 256²; the donor default (320²) is 2× the port in each axis, and the
maximum (640²) is 4×. In world extent the port covers 320 m (160×2 m); the
donor's 320-cell map plausibly covers the same 320 m at 1 m/cell — so the
difference is **sample resolution**, not necessarily world size. The 1 m/cell
identity is `inferred` from matching extents; no donor constant states it.

### 4.3 Verdict

> The donor heightfield is **not a fixed resolution**: it is the square map/height
> grid, selected by the skirmish size setting as **256² / 320² / 480² / 640²**
> with a 2× collision grid. The port's fixed 160² grid is 1.6–4× coarser per
> axis than the donor range. (`derived` from donor script constants + port code.)

**UNVERIFIED:** how the engine turns the height grid into the `hf.pvl.*` mesh
(vertex count, chunking, LOD, whether one vertex per height cell or a decimated
grid). Evidence: RTTI names `HXHeightField`, `XTerrainData`, `XTile`
(`ev_18bd0b84…`, `ev_800d07f5…` in RENDER_ARCH_CRAFT_ANYTHING.md); no plaintext
connector. The water shader's `hmapW`/`hmapH` uniforms index the engine height
texture in world units (`WATER_REPORT.md §2.2`); whether `hmapW == GetMapWidth`
is `inferred`, not proven.

---

## 5. Claim table

| # | Claim | Evidence | Method | Status |
|---|---|---|---|---|
| 1 | Projection switch is a 5-way byte at renderer+0xC8: 0=glFrustum, 1=glOrtho, 2=gluOrtho2D, 3=callback, 4=custom matrix | `ev_030dff8c…` | Ghidra pseudo-C | **observed** |
| 2 | Baseline mode table had 2/3 and 4 shifted by one | `ev_030dff8c…` vs RENDER_ARCH_CRAFT_ANYTHING F3 | re-verification | **observed** (correction) |
| 3 | glFrustum/glOrtho/gluOrtho2D each have exactly one real call, all from FUN_004cd334; gluPerspective has 0 | `ev_cc0ee18b…`, `ev_3e2611e3…`, `ev_9974b6a2…`, `ev_c6949392…` | xref | **observed** |
| 4 | Default setter FUN_008127d8 sets mode 0 (perspective) | `ev_10f78080…`, `ev_0f634d4b…` | pseudo-C + bytes | **observed** |
| 5 | Alternative setter FUN_00812ae0 can set mode 1 conditionally | `ev_f05b04f6…`, `ev_0f634d4b…` | pseudo-C + bytes | **observed** |
| 6 | Renderer construction path calls the perspective setter | `ev_bc416c54…` | built-in pseudo-C | **derived** (lower confidence) |
| 7 | Main viewport path FUN_005d1c60 calls the switch after glViewport/glClear | `ev_6a85f244…` | pseudo-C | **observed** |
| 8 | Main world view = perspective glFrustum | #1,#3,#4,#5,#6 + camera.cfg:44-45 | chained | **derived (strong)** — not runtime-observed |
| 9 | Orthographic branch is used by editor/minimap/debug | none | — | **UNVERIFIED** (do not assert) |
| 10 | Exact FOV for focal 400 | no sensor constant | — | **UNVERIFIED** |
| 11 | Donor random-map height grid = 256²/320²/480²/640², square, size-setting driven | `miscext2.script:19-26,45`; `dmscript.global:132-135` | direct read | **observed** |
| 12 | Port height grid = 160² at 2 m/cell | `game.gd:16,20-21`, `data.gd:33-34` | direct read | **observed** |
| 13 | Port grid is 1.6–4× coarser per axis than donor | #11,#12 | arithmetic | **derived** |
| 14 | Mesh vertex count / LOD from height grid | RTTI only | — | **UNVERIFIED** |
| 15 | `hmapW == GetMapWidth` | water shader indexing | — | **inferred** |

---

## 6. Open questions / hand-off

1. **Runtime confirmation of renderer+0xC8** would require observing a donor
   frame; forbidden here. Builders should treat "perspective" as high-confidence
   derived, not observed.
2. **If a 3D fidelity mode is funded**, build on the donor's *perspective*
   frustum (focal 400, tilt −32°, dolly 20…58), not an orthographic camera —
   this corrects the RENDER_ARCH_SHADERS §6 "ortho-leaning" framing at the
   projection level (the *look* is still near-isometric).
3. **Heightfield ticket:** if a donor-exact heightfield is wanted, the port must
   move from 160² to at least 256² per axis (and expose the size setting), or
   document the coarser grid as an accepted approximation. Do not guess mesh
   LOD — ticket a separate runtime/RE investigation.
4. `globalparams.cfg:2` `Size=512` and `:6` `CellsResolution=1` have no
   identified script consumer; treat semantics as UNVERIFIED.

No donor asset was copied; no donor executable was run; no code was changed.
