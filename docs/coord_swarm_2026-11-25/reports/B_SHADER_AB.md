---
id: B-SHADER-AB
title: "Publish mask_to_alpha A/B contract; 0.0 flat opaque vs 1.0 shipped RGB modulation at identical camera"
agent: "B-SHADER-AB (implementation builder), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__ADDITIVE_COMMENT_ONLY__SMOKE_GREEN__NO_CAPTURE_BY_BUILDER
scope: "Exactly two owned files: variant3d/shaders/terrain_tileindex.gdshader (one additive comment block at EOF) and this report. Backup in inbox/backup/. world3d_terrain.gd is FOREIGN (B-C-TERRAIN-AB live) and was READ ONLY - never edited. No test, fixture, config, result JSON, runner state, asset, app/** or other report touched."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: "variant3d/shaders/terrain_tileindex.gdshader"
foreign_file_read_only: "variant3d/scripts/world3d_terrain.gd"
backup: "inbox/backup/terrain_tileindex.gdshader.bak-BSHADER"
labels: [observed, derived, UNVERIFIED, PORT APPROXIMATION]
jobs:
  smoke: {id: bshaderab-smoke, ticket: 574, status: ok, exit: 0, stderr_bytes: 0, script_error_lines: 0, wait_s: 33.74, run_s: 6.17}
parity_claim: false
---

# B-SHADER-AB - published `mask_to_alpha` A/B contract

## 0. Mandate and boundary

Owner A (shader) in `Z3_VISUAL_BLEED.md:127-131`: keep `ALPHA=1.0`, expose the
**already-existing** `mask_to_alpha` knob as an A/B pair, retain every APPROXIMATION
label, and publish the exact uniform name so owner B (terrain-gd) can bind it by name.
The verifier (second agent C) captures and measures. This builder ran **no windowed
capture**, no gate, no queue mutation (no reset/ack/cancel), no direct `godot`, and
opened no donor file.

Labels: **observed** = literal source bytes, backup hash, runner artifact; **derived** =
arithmetic/control-flow consequence; **UNVERIFIED** = no pixel-registered donor A/B.
**No donor parity claim** - no donor GPU A/B frame exists.

## 1. PUBLISHED CONTRACT (for owner B and verifier C) - observed

| Item | Exact value | Evidence |
|---|---|---|
| Uniform name | `mask_to_alpha` | `terrain_tileindex.gdshader:235` - `uniform float mask_to_alpha = 1.0;` |
| Binding call (B) | `mat.set_shader_parameter("mask_to_alpha", <float>)` | name is source-confirmed verbatim; B binds by name only |
| Range | `0.0 .. 1.0` (float) | both endpoints consumed by `mix(1.0, a, mask_to_alpha)` at `:427` |
| Shipped default | `1.0` | `:235`; **unchanged** by this task |
| Value `1.0` | shipped RGB mask modulation: `rgb = rgb * mix(1.0,a,1.0) * v_packed + v_specular` at `:427` | `Z3_VISUAL_BLEED.md:53,56,114` |
| Value `0.0` | flat opaque terrain: `mix(1.0,a,0.0) == 1.0`, no RGB mask fold | `MASK_ALPHA_FIX_01.md:237-239`; `Z3_VISUAL_BLEED.md:114` |
| Framebuffer alpha | `ALPHA = 1.0` at `:475` in **both** paths | unchanged; no sky bleed |

Both endpoints are **runtime values of one compiled shader program**. There is no
second shader variant, no sampler, floor, patch rule, art or donor claim added. The
mask is already sampled at `:412/:419` and folded at `:427`; this task only documents
the existing knob. Exact patch decomposition (`:365-378`), albedo (`:392`) and the
`unshaded` rationale (`:31-38`) are untouched.

## 2. Backup evidence - observed

Pre-edit copy made and hash-verified before any shader write:

```
inbox/backup/terrain_tileindex.gdshader.bak-BSHADER
SRC_SHA256 = F9456E4F769EC7CF3527E16D1C05F59754852C6E76F56E2090406C150C9535F0
BAK_SHA256 = F9456E4F769EC7CF3527E16D1C05F59754852C6E76F56E2090406C150C9535F0
MATCH = True
BAK_SIZE = 27,920 bytes (pre-edit source size)
```

`git diff --no-index backup vs edited` shows **no hunk before line 475**: the edit is
a single `+26` line block appended after the closing `}` at `:476`.

## 3. Exact diff - observed

Additive, comment-only, EOF. Line numbers `:235`, `:427`, `:475`, `:365-378`, `:31-38`
are **preserved** (no insertion above them), so all existing citations remain valid.

```
@@ -474,3 +474,29 @@ void fragment() {
 	// The donor mask's modulation is now carried by RGB above (DTRN-01 C17).
 	ALPHA = 1.0;
 }
+
+// ============================================================================
+// B-SHADER-AB (Z3_VISUAL_BLEED.md §5.1/§5.3) — PUBLISHED A/B CONTRACT.
+// COMMENT-ONLY and additive: no shader behaviour, line or label above changed.
+// Every cited line above keeps its number; this block starts after :476.
+//
+// Exact uniform name for consumer binding by name (terrain-gd owner B):
+//     mask_to_alpha
+//   Declared at :235 as `uniform float mask_to_alpha = 1.0;`. B binds with
+//   set_shader_parameter("mask_to_alpha", <float>) — that exact spelling.
+// Range: 0.0 .. 1.0 (float). BOTH endpoints are runtime values of the SAME
+//   compiled shader program: no second variant, sampler, branch, patch rule,
+//   floor, art or donor claim is introduced here.
+//
+// A/B pair at IDENTICAL camera (verifier C):
+//   1.0 = SHIPPED DEFAULT, unchanged — `rgb = rgb * mix(1.0,a,1.0)
+//         * v_packed + v_specular` at :427 (mask folded into RGB); ALPHA=1.0
+//         at :475. This is the shipped mask-modulation path.
+//   0.0 = flat opaque terrain — `mix(1.0,a,0.0) == 1.0`, so no RGB mask
+//         modulation; ALPHA still 1.0 at :475. Only the mask factor differs.
+//
+// Default, albedo (:392), patch decomposition (:365-378), unshaded rationale
+// (:31-38) and all PORT APPROXIMATION / PORT GUARD / PORT SUBSTITUTE /
+// UNVERIFIED labels remain untouched. No donor GPU A/B is claimed here.
+// Procedure and validation record: reports/B_SHADER_AB.md.
+// ============================================================================
```

No new `uniform`, `sampler`, `floor()`, `texture()` call, `render_mode` change or donor
`path:line` claim. `ALPHA=1.0` at `:475` and the PORT APPROXIMATION labels at `:236-246`
and `:345-364` remain byte-identical to the backup.

## 4. Validation - one targeted job, variant runner only - observed

Pre-submit queue check: `pending = 0`, `godot.lock = free`, `next_ticket = 572` (not busy).

```
python variant3d\tools\godot_runner.py run --id bshaderab-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --script C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\bshaderab_smoke.gd
```

| Field | Value |
|---|---|
| Ticket / id | **574** / `bshaderab-smoke` (only job submitted by this task) |
| Status / exit | **`ok` / 0** |
| wait / run | 33.74 s / 6.17 s |
| stdout | 454 B, contains `B_SHADER_AB_SMOKE OK name=mask_to_alpha range=[0.0,1.0] default=1.0 program=shared` |
| stderr | **0 bytes** |
| `SCRIPT ERROR` count | **0** (`smallmap_capture.py scan-stderr` -> `script_error_lines: 0`, `lines: []`) |
| Artifacts | `variant3d/.godot_queue/results/00000574.json`, `00000574_bshaderab-smoke/{stdout,stderr}.txt` |

The headless probe loaded `res://shaders/terrain_tileindex.gdshader` as a `Shader`
(parse/compile smoke), created a `ShaderMaterial`, bound both endpoints in turn, and
read back: `mask_to_alpha=0.000000` and `mask_to_alpha=1.000000`. Full stdout:

```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

B_SHADER_AB_SMOKE NOTE: get_shader_parameter_list unavailable; name confirmed by source :235
B_SHADER_AB_SMOKE NOTE: no material override present; shader default 1.0 from source :235
B_SHADER_AB_SMOKE endpoint ok: mask_to_alpha=0.000000
B_SHADER_AB_SMOKE endpoint ok: mask_to_alpha=1.000000
B_SHADER_AB_SMOKE OK name=mask_to_alpha range=[0.0,1.0] default=1.0 program=shared
```

**Scope of this evidence (honest):** the shader resource loaded and compiled with zero
stderr/parse errors, and both values were accepted and round-tripped. This Godot build's
`Shader` did not expose `get_shader_parameter_list()` to the probe, so the *declaration
spelling* is confirmed by the source line `:235` (observed), not by a runtime reflection
list; the fresh material had no override, so the `1.0` default is likewise source-
confirmed. A headless smoke is **not** a GPU frame: both values share one compiled
program, so "both paths compile" means the single program compiles and both endpoint
values bind - not that two shaders were built. No windowed capture, near-white count,
luma or per-pixel delta was produced by this builder. Verifier C owns that step.

## 5. IDENTICAL-CAMERA A/B PROCEDURE (handoff to owner B, then verifier C)

Per `Z3_VISUAL_BLEED.md:117-121,127-131`, `CAPTURE_RECHECK.md:56-60,82` and
`MASK_ALPHA_FIX_01.md:164-186`. This section is a documented procedure only; this
builder ran none of it.

1. **B binds by name in `world3d_terrain.gd` (foreign to this agent).** Add a fixture-
   gated `mat.set_shader_parameter("mask_to_alpha", V)` with `V = 1.0` for the shipped
   arm and `V = 0.0` for the flat arm. No shader edit, no `UV2`/mesh/topology/light/
   water change, no simulation change. Leave the shipped default `1.0` unless the
   fixture explicitly overrides it. Nothing else in the render path may differ.
2. **Two windowed captures through the variant runner only** (`pending` check first;
   no direct `godot`, no `--headless`). Same seed **20261113**, same **64x64** fixture,
   same **1280x720**, ~10 frames. The camera must be **bit-identical** between arms:
   explicitly the same x/y/z **and** the same target. The prior A/B differed by
   **1.352 m in camera x** (`MASK_ALPHA_FIX_01.md:181-186`), so it was frame-wide only;
   do not repeat that error. Record both job tickets, status, exit, and run
   `python variant3d\tools\smallmap_capture.py scan-stderr <ticket>_<id>\stderr.txt`;
   require `script_error_lines: 0` in **both** arms.
3. **Measure both PNG sets with the same read-only Pillow/NumPy script outside the repo.**
   Strict near-white = `min(R,G,B) > 180`; fraction of 921,600 px; bbox; Rec.709 luma
   min/max/mean; `minRGB>200`; exact cyan `(181,234,255)+(182,233,255)`.
   **Split every cyan/near-white statistic at `y=12`** (`Z3_VISUAL_BLEED.md:96,120`):
   `y<12` is the legitimate rendered sky strip (99.2 % of the 6,989 remaining
   near-white pixels = 6,934; all 6,571 exact-cyan pixels), **not terrain**. Report
   `y>=12` separately; that is the arm-comparable ground signal (55 near-white px in
   the shipped frame). If cameras are truly registered, add per-pixel delta and the
   4x4 cell grid; otherwise state frame-wide only, never per-pixel.
4. **Reference numbers (shipped `1.0` arm, from `MASK_ALPHA_FIX_01.md:164-173`):**
   6,989 near-white / 0.7584 %; 6,571 exact cyan with **0 below `y=12`**; 55 near-white
   at `y>=12`; luma 0.000 / 253.628 / 79.256. The `0.0` arm is expected to differ only
   in RGB mask modulation (no sky bleed either way, since `ALPHA=1.0` in both).
   Interpretation per `Z3_VISUAL_BLEED.md:98`: if the 55 px below `y=12` go to 0 with
   `0.0`, the RGB fold is the cause; if unchanged, attribute to AA/tone map. Do not
   chase tile albedo or invent a floor.
5. **Second agent (C) opens both PNGs** and records "what the image shows" and
   "atom assertions satisfied" separately; `stats` is qualitative only
   (`CAPTURE_RECHECK.md:34-36,82,91`). Record all findings as **PORT APPROXIMATION -
   internal consistency only**. No donor GPU A/B frame exists: nothing here certifies
   donor parity of hue, grain, band geometry or luma.

## 6. No-weakening / no-parity statement

- Default `1.0`, albedo, patch decomposition (`:365-378`), `unshaded` rationale
  (`:31-38`), shadow-OFF decision and every PORT APPROXIMATION / PORT GUARD /
  PORT SUBSTITUTE / UNVERIFIED label are byte-identical to the backup.
- `ALPHA = 1.0` at `:475` in both A/B arms; the change is comment-only. No donor
  behaviour was weakened and no donor constant was invented.
- **No donor parity is claimed.** The smoke is a parse/compile and uniform-binding
  check of the port only; the A/B in §5 compares two *port* frames, never a donor frame.
- Other modified/untracked files in `git status` belong to concurrent swarm builders;
  none was touched, reverted or re-submitted by this task. `world3d_terrain.gd` was
  read only (`:683-721`) to confirm it currently leaves `mask_to_alpha` at its default.
