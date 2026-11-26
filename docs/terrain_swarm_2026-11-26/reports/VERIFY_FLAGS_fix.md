---
id: VERIFY-FLAGS-FIX-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / donor-terrain VISUAL WAVE (SECONDARY verification)"
agent: "worker VERIFY-FLAGS, reporting to COORD"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/VERIFY_FLAGS_fix.md
files_created: [docs/terrain_swarm_2026-11-26/reports/VERIFY_FLAGS_fix.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "Source/numeric verification of a landed in-repo fix only. No donor GPU A/B frame exists; no donor binary was executed; no gate, capture or Godot job was run. Nothing here certifies donor fidelity or visual parity."
scope_guard: "Read-only verification. No code/shader/asset/config/test/gate/git edit and no Godot job; FIX-HEIGHT's concurrent edits were not touched. Exactly one repository file written: this report."
sources_read: "Read in full: VISUAL_WAVE_CHARTER.md, reports/X54_ground_truth_card.md, reports/FIX_CONFIG_shape.md, reports/W03_terrace_root_cause.md; targeted reads of variant3d/scripts/terrain_donor_gen.gd (_stamp_pattern and call sites), variant3d/scripts/terrain_donor_inputs.gd (_decode_pattern flags flattening), variant3d/assets/terrain_new/patterns/hil1.json (flags, w/h, relief_float_grid)."
---

# VERIFY-FLAGS — nested-`flags` fix in `_stamp_pattern()`

## 0. Verdict

**PASS — all four requested checks pass against the landed fix.** No blocker inside the verified scope.

| # | Check | Result | Exact location |
|---|---|---|---|
| 1 | Nested `flags` read with the 8 required mappings | PASS | `variant3d/scripts/terrain_donor_gen.gd:1779-1801` |
| 2 | Top-level canonical keys take precedence | PASS | `variant3d/scripts/terrain_donor_gen.gd:1786,1788,1790,1792,1794,1796,1798,1800` |
| 3 | hil1 `flags` + grid max 3.8613 ⇒ ReplaceForWater `g*Scale+Offset` ≤ 2.51 | PASS | `hil1.json:46-56,59,18324,18884,19357`; `terrain_donor_gen.gd:1864,1887` |
| 4 | No early return at the Stand guard for hil1 | PASS | `terrain_donor_gen.gd:1802-1803` (guard preceded by normalization at `:1786-1787`) |

Labels: `[O]` source/JSON literal, `[D]` deterministic consequence. No `[U]` value was promoted and no parity claim is made.

---

## 1. Check 1 — nested `flags` mappings (PASS)

`_stamp_pattern()` now reads `pat["flags"]` before the Stand guard and normalizes it into the flattened keys its D05/X26 blend body already consumes (`terrain_donor_gen.gd:1779-1801`):

| Donor flag | Written to | Line |
|---|---|---|
| `Stand` | `height_field_stand` | `:1786-1787` |
| `Scale` | `scale` | `:1788-1789` |
| `Min` | `min` | `:1790-1791` |
| `Offset` | `offset` | `:1792-1793` |
| `TerrainScale` | `terrain_scale` | `:1794-1795` |
| `Replace` | `replace` | `:1796-1797` |
| `ReplaceForWater` | `replace_for_water` | `:1798-1799` |
| `Smooth` | `height_field_smooth` | `:1800-1801` |

All eight mappings are present, correctly typed (`bool` for Stand/Replace/ReplaceForWater/Smooth; `float` for Scale/Min/Offset/TerrainScale) and feed the original consumers unchanged: `scale` `:1833`, `min` `:1839`, `offset` `:1840`, `terrain_scale` `:1841`, `replace` `:1842`, `replace_for_water` `:1843`, `height_field_stand` vertex gate `:1849`, smooth post-pass guard `:1906`. The blend bodies at `:1861-1864` and `:1885-1894` were not altered by this fix.

Two caller paths both resolve correctly:
- **Direct I02 JSON caller** (`hil1.json` has only nested `flags`): normalization at `:1783-1801` supplies all eight flattened keys.
- **I17 caller**: `terrain_donor_inputs.gd:683-697` already emits the flattened form from the same `flags`; `_stamp_pattern()`'s `if not pat.has(...)` guards leave those values intact. [D] Both paths therefore execute one shared implementation with no divergence.

## 2. Check 2 — canonical override precedence (PASS)

Every assignment is guarded by `if not pat.has(<canonical key>)` (`:1786,1788,1790,1792,1794,1796,1798,1800`). An explicitly supplied top-level key always wins over the nested flag; only absent keys inherit from `flags`. This matches the stated contract "top-level canonical overrides still take precedence" ([D] from the literal guard conditions).

## 3. Check 3 — hil1 ReplaceForWater magnitude (PASS)

`hil1.json:46-56` `[O]`: `Stand=true`, `ReplaceForWater=true`, `Replace=false`, `Smooth=false`, `Scale=0.649999976158142`, `Min=0.0`, `Offset=0.0`, `TerrainScale=1.0`, `Max=3.86130237579346`.

`relief_float_grid` (`hil1.json:18324`) has 1025 = 25×41 values (`w=25` at `:19357`, `h=41` at `:59`); its maximum is **3.86130237579346** (f32 bit pattern as read at `:18884`), equal to `flags.Max` — the F01 min/max cross-check. `[O]`

With `replace_for_water=true` the non-pivot branch runs: `g = _pf(g * scale)` at `terrain_donor_gen.gd:1864`, then `stamped = g + hoff` at `:1887`. With `Min` and `Offset` both zero, the output is exactly `g * Scale + Offset`. `[O]/[D]`

Numeric replay (two independent evaluations agreed):
`3.861302375793457 × 0.649999976158142 + 0.0 = 2.509846452205124` → **2.51 to two decimals**. [D]

Therefore the ReplaceForWater output for hil1 reaches at most **≈2.5098 (2.51)**, inside the requested bound. This is a source-derived consequence of the landed code and the decoded grid, not a runtime measurement.

## 4. Check 4 — Stand guard (PASS)

The old defect was a top-level-only `height_field_stand` lookup that returned early for I02 patterns carrying `flags.Stand=true` but no flattened key. The fix places normalization at `terrain_donor_gen.gd:1779-1801`, **before** the guard at `:1802-1803`. For hil1, `flags.Stand=true` (`hil1.json:54`) sets `pat["height_field_stand"] = true` at `:1787`, so `not bool(pat.get(...))` is false and the function proceeds into the grid decode (`:1804-1825`) and the stamp loops (`:1847+`). `[O]/[D]`

The I17 path yields the same result via `terrain_donor_inputs.gd:696` (`"height_field_stand": bool(flags.get("Stand", false))`). [D]

---

## 5. Remaining blockers / non-blocking observations

- **No blocker in the verified scope.** All four requested checks pass; no code change is requested by this worker.
- **Wave-level blocker (out of scope, unchanged by this verification):** donor visual parity stays **UNVERIFIED** — no donor GPU A/B frame and no Godot capture was run by this worker. `VISUAL_WAVE_CHARTER.md:35-42` still governs; re-capture/integration belongs to COORD.
- **Observed but not exercised:** relief-family placement calls now exist at `terrain_donor_gen.gd:2143-2174` (`_check_stand` at `:2166`, `_stamp_pattern` at `:2167`), and telemetry at `:2170` reads the normalized `height_field_stand`. This report verifies the flag-reading function, not the runtime stamp result; no claim is made that relief stamps actually fired in a capture.
- **Non-blocking doc mismatch [O]:** the comment at `terrain_donor_gen.gd:1780` says "Normalize a shallow copy", but the implementation mutates `pat` in place (`:1786-1801`). This is idempotent and does not affect correctness; it is a wording-only nit for the owner.

## 6. Handoff to COORD

1. The nested-`flags` fix in `_stamp_pattern()` is verified **PASS** on all four points above; no rework needed from VERIFY-FLAGS.
2. Keep parity labelled `UNVERIFIED`; do not treat this source/numeric check as a visual or gate pass.
3. If the shallow-copy wording at `:1780` matters for style, the owner may adjust the comment; no functional change is suggested.

**NO DONOR VISUAL PARITY CLAIM. Parity remains UNVERIFIED.**

*End of VERIFY-FLAGS. Exactly one repository file written; no donor binary executed, no code/shader/asset/config/test edit, no Godot job, no gate, no git operation.*
