---
id: CONFIG-WIRE-HUD
title: "CONFIG-WIRE-HUD — 3D minimap geometry reads the global feature config"
owner: CONFIG-WIRE-HUD (implementation builder / subagent)
date: 2026-11-25
status: IMPLEMENTED__PARSE_SMOKE_CLEAN__UITEST_17_17__NO_GATES
scope: "Variant3d/scripts/hud.gd + this report + one required backup. Getter call sites wired only; defaults identical, no behaviour change. No config.json, no hud3d_adapter.gd, no camera3d.gd, no uitest.gd, no app/** edit."
labels: [observed, derived, UNVERIFIED]
---

# CONFIG-WIRE-HUD — minimap geometry from global feature config

## 1. Goal and ownership

Close the consumer side of CONFIG-CORE-01 for the 3D minimap: the three hard-coded
geometry literals in `hud.gd` (`240` size, `-8`/`8` inset, bottom-right corner)
now go through the typed getters CONFIG-CORE-01 added to `config.gd`. Their
defaults are the same literals, so this is a **read-path refactor, not a layout
change**.

**Exclusive ownership honoured:** edited only
`variant3d/scripts/hud.gd`, created `inbox/backup/hud.gd.bak-CONFIGWIREH` and
this report. Read-only: `config.gd`, `hud3d_adapter.gd` (MINIMAP-QUAD-01),
`camera3d.gd`, `uitest.gd`, `config.json`, `app/**`, donor files.

Sources read first: `reports/CONFIG_CORE_01.md` (getter table + line numbers),
`variant3d/scripts/config.gd:266-269,387-406,414-483` (getters, `active`,
`value/num/text/flag`), `reports/HUD_01_minimap.md` (geometry diff, donor
citations), `reports/MMJUMP_02_minimap_jump.md` (`_cam3d_jump` contract),
`hud.gd:270-344` (`_apply_scale`) and `hud.gd:1385-1468` (minimap build,
`_on_minimap_input`, `_minimap_jump_3d`, `_cam3d_jump`).

## 2. Getter map

CONFIG-CORE-01 getters are **instance** methods on `C3Config` (`config.gd`
`extends RefCounted`, `class_name C3Config`) and read `data` through
`value()/num()/text()`, so missing keys fall back to the literal default.
`hud.gd` reaches them through the existing `ConfigScript.active` singleton,
using dynamic `call()` exactly like MMJUMP-02's camera call — no new static
dependency on config internals. Each helper falls back to the donor literal if
no config is active or the method is absent.

| Config path | config.gd getter (default) | hud.gd helper (`:276-292`) | Read at (after-lines) |
|---|---|---|---|
| `features.hud.minimap_size` | `feature_hud_minimap_size() -> int` (`:470-471`, `240`) | `_mm_size() -> int` (`:276-280`, fallback `240`) | `:322` `_apply_scale` resize size; `:1415` build size + meta `:1417-1418` |
| `features.hud.minimap_inset` | `feature_hud_minimap_inset() -> int` (`:473-474`, `-8`) | `_mm_inset() -> int` (`:282-286`, fallback `-8`) | `:335` `_apply_scale` edge inset; `:1444` build offsets `:1445-1448` |
| `features.hud.minimap_corner` | `feature_hud_minimap_corner() -> String` (`:476-477`, `"bottom_right"`) | `_mm_corner() -> String` (`:288-292`, fallback `"bottom_right"`) | `:1434-1440` panel anchors |

Donor citations kept in comments: `initminimap.inc:5-7,17,29-35,33`;
`showunitcontrol.inc:109-110,586`; DEC-08 `initminimap.inc:17`.

## 3. Before → after (`variant3d/scripts/hud.gd`)

| # | Before (pre-edit line) | After (line) | Behaviour at default |
|---:|---|---|---|
| 1 | no config read helpers | `:270-292` three helpers `_mm_size/_mm_inset/_mm_corner` via `ConfigScript.active.call(...)` with literal fallbacks | no-op until a config with `features` is loaded |
| 2 | `:297` `var mm := minf(_ms(240.0), ui_vp.x * 0.25)` | `:322` `var mm := minf(_ms(float(_mm_size())), ui_vp.x * 0.25)` | `_mm_size()==240` → `_ms(240.0)`, identical |
| 3 | `:308` `var mm_inset := _ms(8.0)   # donor cMinimapOffsetX/Y = -8` | `:335` `var mm_inset := _ms(-float(_mm_inset()))   # …` | `_mm_inset()==-8` → `-(-8)=8` → `_ms(8.0)`, identical |
| 4 | `:1387-1389` `Vector2(240,240)`, meta `uimw/uimh = 240.0` | `:1415-1418` `mm_size := float(_mm_size())`; `Vector2(mm_size,mm_size)`, meta `mm_size` | `mm_size==240.0`, identical |
| 5 | `:1400-1403` `panel.anchor_* = 1.0` hard-coded | `:1434-1440` `mm_corner := _mm_corner()`; `mm_anchor_x/y` derived, then assigned to all four anchors | `"bottom_right"` → `1.0/1.0`; `anchor_left == 1.0` (UITEST-ANCHOR) unchanged |
| 6 | `:1406-1409` `left=-(240+30+8)`, `top=-(240+22+8)`, `right=-8`, `bottom=-8` | `:1444-1448` `mm_inset := float(_mm_inset())`; `left=mm_inset-mm_size-30`, `top=mm_inset-mm_size-22`, `right=bottom=mm_inset` | `-8-240-30=-278`, `-8-240-22=-270`, `-8`, `-8` — identical |

Byte-identical (verified against the backup with a line diff): HUD-01's bottom
strip partition (the `sel_panel`/`cmd_panel` computations, including
`_ms(8.0)` gaps, `mm_pad_w=30`, `mm_pad_h=22`), `minimap_tex` / `_draw_minimap_viewport_box`,
`_on_minimap_input`, `_minimap_jump_3d`, and MMJUMP-02's `_cam3d_jump` including
the `cam.call("jump_to_world_donor_offset", world_pos)` line and its comments.
No key was added to any JSON, no constant renamed, no layout block restructured.
Net: 3 helper functions + comment-only additions; the only executable literals
replaced are the six geometry lines above.

Corner scope: only the donor **bottom-right offsets** are implemented. The
corner getter drives the four anchor values (`top_left`/`bottom_left` → x=0,
`top_left`/`top_right` → y=0; any unknown string → bottom-right fallback).
Supporting correct offsets for the other three corners would require a
separate HUD partition pass and is explicitly **not** done here.

## 4. Backup

| Item | Value |
|---|---|
| File | `inbox/backup/hud.gd.bak-CONFIGWIREH` |
| Taken | before the first edit (plain copy of `variant3d/scripts/hud.gd`) |
| Bytes | 78,740 |
| SHA-256 | `AEFA633CFBCB1D566ABF51F1B8943969FED77A6C77340B61827B97900B2EC0DE` |

Restore by copying the backup back over `variant3d/scripts/hud.gd`.

## 5. Validation — variant runner only

Launch form (single legal Godot door; no direct `godot`, no gates, no ladder):

```powershell
python variant3d\tools\godot_runner.py run --id configwireh-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/hud.gd
python variant3d\tools\godot_runner.py run --id configwireh-uitest --timeout 240 --max-wait 1800 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
```

| Ticket | Job id | Command target | Result | exit | wait / run | `SCRIPT ERROR` |
|---:|---|---|---|---:|---|---:|
| 432 | `configwireh-smoke` | `--check-only res://scripts/hud.gd` | `ok` | 0 | 91.58 s / 8.00 s | **0** |
| 440 | `configwireh-uitest` | `--ui-test variant3d/uitest.json` | `ok` | 0 | 146.89 s / 221.35 s | **0** |

Result JSONs: `variant3d/.godot_queue/results/00000432.json`,
`00000440.json`, each with its own `stdout.txt`/`stderr.txt`.

- **Smoke:** stdout 75 B (Godot 4.7.2 banner), stderr **0 B**, `SCRIPT ERROR == 0`.
  `--check-only` parses hud.gd; it does not execute the game or a getter call.
- **UI test:** `variant3d/uitest.json` → `passed: true`, **17/17 steps passed**,
  including step `minimap_frustum` with detail **"minimap bottom-right: yes"**
  — UITEST-ANCHOR (`anchor_left == 1.0`) is green. `variant3d/uitest.json` was
  byte-identical before and after the run (SHA-256
  `EBB9AC0E0E81B4F98B0EF269F04CB9BE43B6786355F61BFF5BE1C23E9BA2E69B`); it was
  not hand-edited. stderr is 3,280 B of **pre-existing, unrelated** engine
  output (`world3d_entities` DONOR-SAMPLED warning, `mill_rotor.png` `.ctex`
  resource-load ERROR from `world3d_entities.gd:1435`); `SCRIPT ERROR` count is
  **0** and the runner exited 0. No hud.gd or minimap assertion failure.

Not run, by design: full gates, selftest, terrain ladder, direct `godot`,
selftest/ladder jobs, donor A/B or visual parity.

## 6. No-behaviour-change statement

The three getter defaults are exactly the literals they replace (`240`, `-8`,
`"bottom_right"`, CONFIG-CORE-01 §2), and `config.json` has no `features` table
yet, so both the active-config path and the fallback path return the same
values in every current configuration. Arithmetic was checked explicitly:
`-8-240-30 = -278`, `-8-240-22 = -270`, `-(-8) = 8`, and
`"bottom_right" → anchors 1.0/1.0`. HUD-01's panel partition, the 2D branch,
`_on_minimap_input`, `_minimap_jump_3d` and MMJUMP-02's donor-offset call are
byte-identical to the backup. The 17/17 UI run confirms the observable
behaviour (including the minimap anchor assertion) is unchanged. This is an
**observed** no-behaviour-change claim for the current default configuration,
not a claim about hypothetical non-default corner strings.

## 7. Open questions

1. **Non-default corner offsets.** The corner getter drives anchors but only
   bottom-right offsets are implemented. A `features.hud.minimap_corner` value
   such as `top_left` would move the anchors without re-partitioning the panel;
   a follow-up ticket would need to mirror the inset/left/top offset signs and
   the `_apply_scale` bottom-strip partition. No config currently sets it.
2. **`_ms()` scaling vs donor literal.** `mm` still passes through the port's
   `_ms(ui_us)` and the `ui_vp.x*0.25` cap; a configured size is a base-resolution
   value, not necessarily an exact pixel size at every window width
   (HUD-01 §9 Q3). UNVERIFIED at non-1280 widths.
3. **No config runtime check.** `--check-only` proves parse validity, not a
   real getter call with a populated `features` table; a JSON-owner ticket
   adding `features.hud.*` should verify the wiring at runtime (17/17 exercises
   the default/fallback path only).
4. **String validation.** `feature_hud_minimap_corner()` passes strings through
   unchanged (CONFIG-CORE-01 §6 Q4); unknown values currently fall back to the
   bottom-right layout. Owner of the JSON schema may add an allow-list.

## 8. Changed-file list / summary

- **Edited:** `variant3d/scripts/hud.gd` (3 config-read helpers + 6 geometry
  value sources; all donor comments and MMJUMP-02 paths preserved).
- **Created:** `inbox/backup/hud.gd.bak-CONFIGWIREH`, this report.
- **Not edited:** `hud3d_adapter.gd`, `camera3d.gd`, `uitest.gd`, `config.gd`,
  `config.json`, `variant3d/uitest.json` (byte-identical after the runner), any
  other source, test, shader, fixture or `app/**`. Donor READ-ONLY. No new keys,
  no gates, no ladder, no direct `godot`.

**Bottom line:** the 3D minimap size, inset and corner now flow from the global
feature-config getters with behaviour-identical defaults; parse smoke is clean
(`SCRIPT ERROR == 0`) and the UI test reports 17/17 with "minimap bottom-right: yes".
