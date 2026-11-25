---
id: B01b
ticket: "WAVE Y / B01b — Branch B UV-scale A/B probe (exclusive shader owner)"
title: "B01b — uv_repeat (0.5,0.5) -> (0.25,0.25): one atlas cell per 4 m, PORT APPROX A/B probe"
owner: B01b (exclusive owner of variant3d/shaders/terrain_tileindex.gdshader)
created: 2026-11-25
status: REVERTED__AB_NEGATIVE__NO_RUNNER_JOB_BY_B01B__NO_GODOT__NO_DONOR_PARITY_CLAIM
ab_result: "NEGATIVE — owner visual: horizontal striping WORSE than the matched 2 m baseline"
reverted_to_sha256: E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3
capture: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\uvprobe\\realmap.png"
capture_job: "uvprobe-realmap (ticket 603, runner owned by G04, not B01b)"
file_owned: variant3d/shaders/terrain_tileindex.gdshader
backup: inbox/backup/terrain_tileindex.gdshader.bak-B01b
backup_sha256: E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3
pre_edit_sha256: E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3
post_edit_sha256: 998E9BBEB482FCE2A2258FF19353D4398ABEA0FD84BEE2EA7298635263CE0B57
parity_guard: "NO DONOR PARITY CLAIM. 4 m per cell is an explicit PORT APPROX departure from donor gc_meters_to_tile=2 (A03 E06/R07, dmscript.global:171). This is an A/B probe only, not a promised donor match and not a claimed fix. Donor parity stays UNVERIFIED (CHARTER §3/§5)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/Y08_checkerboard.md (§9 Branch B, esp. §9.2/§9.4/§9.6/§11)
  - docs/terrain_swarm_2026-11-25/reports/B01_shader_impl.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md (§5 R07)
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
---

# B01b — Branch B UV-scale A/B probe

> **Labels.** **OBSERVED** = literal file line / command output; **DERIVED** = arithmetic or
> control-flow consequence; **INFERRED** = prediction with caveat; **UNVERIFIED** = cannot be
> proved without a GPU capture. B01b itself started no Godot process and submitted no runner
> job; the capture in §4 was submitted by G04. Donor parity stays **UNVERIFIED**; no donor GPU
> A/B frame exists (CHARTER §3/§5).

## FINAL STATUS — REVERTED, A/B NEGATIVE

> **OBSERVED (COORD notice, this session):** the 4 m UV probe was captured as `uvprobe-realmap`
> and the **owner visual verdict was that horizontal striping became WORSE than the matched 2 m
> baseline**. The A/B result is **NEGATIVE**. COORD reverted
> `variant3d/shaders/terrain_tileindex.gdshader` to this ticket's pre-edit backup
> `.bak-B01b`. B01b verified the revert directly: shader SHA-256
> `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` — byte-identical to
> `inbox/backup/terrain_tileindex.gdshader.bak-B01b`, with an empty `git diff --numstat` for
> the shader. **Do NOT re-apply** the `uv_repeat = vec2(0.25, 0.25)` change. The shader is back
> to the B01-released / matched-baseline state and B01b makes no further edit to it.
>
> Capture path: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\uvprobe\realmap.png`
> (1,418,152 bytes, written 2026-11-25 17:06:23; runner job `uvprobe-realmap`, ticket **603**,
> result `variant3d\.godot_queue\results\00000603.json`, full log
> `docs/terrain_swarm_2026-11-25/reports/UVPROBE_capture_log.md`). The frame is a **B2** frame
> (Branch A + this Branch B probe) on seed 20261113, `--screenshot-frames 10`; its camera was
> `(145.4698, 58.0, -87.21319)` target `(385.4698, 59.96741)`, close to the `y03`/`y04b` cluster
> and **not** the matched `g04`/`y07`/`y08` pose `(144.1104, 58.0, -88.57262)` — so the A/B is
> comparative, not pixel-aligned. That caveat is recorded (UVPROBE log §2); the **negative
> verdict is COORD's owner-visual call** and is authoritative for the revert.

## 0. Mandate and answer in one paragraph

COORD granted exclusive ownership of `variant3d/shaders/terrain_tileindex.gdshader` (released by
B01) for **Branch B of Y08 §9** only. Branch B is a **separate A/B**, applied only on a
Branch-A build, and must never be merged into a Branch-A capture without a labelled branch id
(Y08 §9). The mandated change is exactly one line at the `uv_repeat` knob: `vec2(0.5, 0.5)` →
`vec2(0.25, 0.25)` — **one atlas cell per 4 m** — labelled `PORT APPROX` and `A/B`, an honest
probe rather than a promised donor parity. Applied verbatim from Y08 §9.2; **nothing else**
in the shader changed (§3). B01's warp/inset/`textureGrad`/mirror-removed path, A02's sentinel
guard and contrast compression, the `mask_to_alpha` A/B contract and the 502-line anchor block
are byte-identical (§3). Verification of the *rendered* effect was the G04 capture
`uvprobe-realmap` (§4); B01b ran no Godot and no runner job. That capture returned a **negative**
owner-visual result — horizontal striping worse than the matched 2 m baseline — so the probe
was applied, captured, then **reverted** (FINAL STATUS above). Sections 1–3 below are the
historical record of the applied state; §4 now records both the planned acceptance and its
actual, negative outcome.

## 1. Backup (taken BEFORE the first edit)

| Item | Value |
|---|---|
| Command | `Copy-Item -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader' -Destination 'inbox\backup\terrain_tileindex.gdshader.bak-B01b' -Force` |
| `Test-Path` before | **False** — no existing `.bak-B01b` overwritten; `.bak-B01`, `.bak-BSHADER`, `.bak-DALPHA02`, `.bak-MASKALPHAFIX`, `.bak-TERRAINDARKFIX`, `.bak-TERRAINDARKFIX2`, `.bak-TRNSHADER` left intact |
| Pre-edit shader | **30,133 bytes**, SHA-256 `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` — exactly Y08 §9.4's recorded pre-Branch-B baseline, so no intervening shader edit existed |
| `inbox/backup/terrain_tileindex.gdshader.bak-B01b` | **30,133 bytes**, SHA-256 `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` — **byte-identical to the pre-edit source** |
| Post-edit shader (historical intermediate state; **reverted**, see FINAL STATUS) | **30,195 bytes** (+62 = the inline label comment), SHA-256 `998E9BBEB482FCE2A2258FF19353D4398ABEA0FD84BEE2EA7298635263CE0B57` |
| Current shader (post-revert, OBSERVED this follow-up) | **30,133 bytes**, SHA-256 `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` — identical to backup/pre-edit; `git diff --numstat` empty |

Rollback is a byte copy of the backup over the shader (§5). The B01 rollback point
`.bak-B01` is untouched.

## 2. Exact applied diff (verbatim `git diff -- variant3d/shaders/terrain_tileindex.gdshader`)

```diff
diff --git a/variant3d/shaders/terrain_tileindex.gdshader b/variant3d/shaders/terrain_tileindex.gdshader
index 4f4d00c6..33045265 100644
--- a/variant3d/shaders/terrain_tileindex.gdshader
+++ b/variant3d/shaders/terrain_tileindex.gdshader
@@ -211,7 +211,7 @@ uniform float fog_use_abs_z = 0.0;
 // ----------------------------------------------------------------------------
 // PORT APPROXIMATION knobs (no donor constant exists for any of them).
 // ----------------------------------------------------------------------------
-uniform vec2 uv_repeat = vec2(0.5, 0.5);
+uniform vec2 uv_repeat = vec2(0.25, 0.25);  // Y08 PORT APPROX A/B: 1 atlas cell per 4 m (A03 §5 R07)
 // TRN-SHADER: 0.5 = 1 / 2 m — donor `gc_meters_to_tile = 2`
 // (dmscript.global:171, read verbatim). Multiplier on fract(s,t) AFTER the
 // world-ground XZ projection, so one atlas cell repeats every 2 m of ground.
```

This is Y08 §9.2's diff verbatim, including the inline label. The donor citation on the
**following, unchanged** line (`// TRN-SHADER: 0.5 = 1 / 2 m — donor \`gc_meters_to_tile = 2\``,
`:215`) is deliberately left byte-identical: it documents the value we are departing **from**.
The label carries all three required marks: `PORT APPROX`, `A/B`, and the `A03 §5 R07`
justification; the "not a promised donor parity" stance is explicit in this report's frontmatter
and in §4.4/§5, and the donor `gc_meters_to_tile=2` line remains adjacent.

**Diff size (OBSERVED):** `git diff --numstat` → **1 insertion, 1 deletion**, one hunk;
`git diff --stat` → `1 file changed, 1 insertion(+), 1 deletion(-)`.
`git diff --no-index --numstat -- inbox/backup/terrain_tileindex.gdshader.bak-B01b variant3d/shaders/terrain_tileindex.gdshader`
→ **1 / 1** — i.e. the working edit differs from the backup by exactly the same one line.
`git diff --no-index --check` printed **no whitespace errors** (exit 1 is the normal "files
differ" status of `--no-index`). The Git warning *"LF will be replaced by CRLF the next time Git
touches it"* is a `core.autocrlf` notice, not a content change: both files are LF-only and the
edit preserved LF (checked below).

## 3. Invariant verification (no Godot)

A line-by-line UTF-8 comparison of backup vs edited file reported:

| Check | Result |
|---|---|
| Lines (backup / edited) | **503 / 503** split elements = **502 / 502 lines** (both end with a trailing newline) — anchor line numbers unchanged |
| Differing line numbers | **214 only** — every other line byte-identical |
| Line endings | `CRLF_backup=False`, `CRLF_edited=False` — LF preserved |
| Uniform declarations | **31 → 31**, name sequence `-ceq` identical; only `uv_repeat`'s value changed |
| `git status` at the applied state (historical) | `M variant3d/shaders/terrain_tileindex.gdshader`, `?? inbox/backup/terrain_tileindex.gdshader.bak-B01b`, plus this report; the pre-existing untracked `Y08_capture_log.md` was left untouched. **Post-revert:** shader is no longer `M`; the backup/report remain untracked |

Because only line 214 differs from the backup, all cited anchors and protected paths are
byte-identical by construction. Independently confirmed present in the edited file (count in
parentheses):

| Invariant (Y08 §9.5 / B01 §6/§8/§9) | Status | Evidence |
|---|---|---|
| 502-line anchor block | intact | 502 lines; `:235`, `:365-378`, `:392`, `:419`, `:427`, `:475`, `:476`, `:478-502` all at their original numbers |
| All 31 uniform names | intact | `-ceq` identical name sequence; no add/rename/remove |
| `mask_to_alpha` A/B contract | intact | `:235` `uniform float mask_to_alpha = 1.0;`; `:392` albedo call ×1; `:427` `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;` ×1; `:475` `ALPHA = 1.0;`; `:476`/`:478-502` A/B comment block incl. `:492`/`:495` endpoint definitions and `:498` still byte-identical. Both endpoints remain the same compiled program; binding name is the exact string `mask_to_alpha` |
| `textureGrad` / inset / mirror-removed path | intact | `textureGrad` ×1, `dFdx` ×1, `dFdy` ×1, `vec2 inset` ×1, `half-texel` ×2; the B01 §9 removed-mirror form `vec2 cell = vec2(mod(idx, cols), floor(idx / cols));` is present and the old `key`/`v`/`f` mirror variant has **0** remnants |
| A02-P1 sentinel guard | intact | `:419` `step(2.5, scol) * step(2.5, srow)` ×1, same id decomposition; no pure-black sentinel cells reintroduced |
| A02-P4 contrast compression | intact | `:419` `clamp(a, 0.35, 1.0)` ×1 inside `a = mix(mix(1.0, clamp(a, 0.35, 1.0), 0.5), 1.0, sentinel);` |
| Samplers / atlas / donor literals | intact | `tile_atlas` filter hint `filter_linear_mipmap` (B01 hunk 1) unchanged; no sampler, `atlas_grid`, sun/ambient/diffuse/specular, fog or eye-plane uniform touched |
| S-25-09 | honoured | no dither, Bayer, hash, noise or synthetic luminance field; this is a UV-scale change only |
| Donor parity | **none claimed** | 4 m per cell is PORT APPROX, not donor-grounded |

**DERIVED consequences of the one-line change** (Y08 §9.2, to be A/B-tested, not assumed):

- RGB phase `fract(v_st*uv_repeat)` at `:392` doubles the world footprint of the cell: 1024 px
  now covers 4 m (256 px/m) instead of 2 m. Helps only isotropic cells (`test8` A03 §4 aniso
  1.27, Sx 0.95, Sy 0.96); Branch A's normalised ordinary-land id is `test8` (Y08 §11), so this
  is the relevant case. Exceptions (water/sand/rock/road/apron) keep their own art.
- `v_alpha_uv = v_st * uv_repeat * alpha_uv_scale` at `:316` likewise shifts the mask-patch
  phase to 4 m; on `test8` cells the patch (0,0) is constant 1.0 (Y08 E06), so this is inert
  there.
- `textureGrad(..., dFdx/dFdy(v_st*uv_repeat))` at `:337` gets half the gradient → LOD about one
  level lower (sharper grain). The warp, inset, mips and sentinel guard are untouched.
- A03 F02 measured no atlas cell contains donor-scale mottling (LF 0.09–0.25). UV scale alone
  cannot manufacture it. **Branch B is therefore an honest A/B probe, not a promised fix.**

## 4. Capture acceptance (for G04 + C01; B01b ran NONE of this)

All of the following are **movement indicators, never thresholds and never donor-parity PASS
criteria** (Y08 §9.6 §5; CHARTER §3/§5). Three branches, **same seed 20261113, same camera (the
y07/g04 pose), same `--screenshot-frames 10`**, no threshold changed:

- `B0` = current y07 baseline, `B1` = Branch A only (Y08-IMPL tree), `B2` = Branch A **+ this
  Branch B shader**. This report is the B2 shader; it must be read/captured as **B2**, never
  merged into B1. (Y08 §11 states Branch A is applied to `game.gd`; that file is a disjoint
  owner and was **not** opened or verified by B01b.)

### 4.0 Actual capture and outcome — NEGATIVE (OBSERVED via COORD)

G04 submitted exactly one job, `uvprobe-realmap` (ticket **603**, result
`variant3d\.godot_queue\results\00000603.json`, `status=ok`, `exit=0`, run 39.51 s, seed
20261113, `--screenshot-frames 10`, windowed). Full log:
`docs/terrain_swarm_2026-11-25/reports/UVPROBE_capture_log.md`.

- **Capture path:** `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\uvprobe\realmap.png`
  (1,418,152 bytes, 1280×720, written 2026-11-25 17:06:23; sidecar `realmap.png.raw.png`).
- **Stats (verbatim):** `non_black_fraction=1.0`, `mean_luma=79.478`, `full_width_dark_rows=0`,
  `script_error_lines=0`. Three exit-time engine `ERROR:` lines were present, identical in class
  to prior captures; no asset-load or script error.
- **Camera caveat:** captured `(145.4698, 58.0, -87.21319)` target `(385.4698, 59.96741)` — close
  to the `y03`/`y04b` cluster, **not** the matched `g04`/`y07`/`y08` pose. The A/B is therefore
  comparative, not pixel-aligned (UVPROBE log §2); this is recorded as a caveat, not as a
  counter-claim to the owner verdict.
- **Owner visual verdict (COORD, authoritative):** the 4 m probe made **horizontal striping
  WORSE than the matched 2 m baseline**. A/B result **NEGATIVE**. COORD reverted the shader to
  `.bak-B01b` (§FINAL STATUS); B01b verified the revert and **did not re-apply**.
- Consequence for §4.2/§4.3: the hoped-for `BV128` mottling increase / `tile_repeat` peak shift
  was **not demonstrated by an accepted frame**; the probe is recorded as a failed A/B, not a
  pending one. The §§4.1–4.5 criteria below remain the *planned* acceptance design and are not
  claimed to have passed. No C01 metric scoring was run by B01b.

### 4.1 Matched camera vs y08 baseline

- Use the **y07/g04 camera** `camera_pos=(144.1104,58,-88.57262)`, target
  `(384.1104,58.60797)` — **not** the y04b pose `(145.2856,58,-87.39741)` (Y08 E16). The y04b
  pair differs by >1 m and is **comparative, not pixel-aligned**; don't reuse it for a B1↔B2
  A/B. Record path, timestamp, camera diag and result JSON fields verbatim for all three
  frames.
- C01 `terrain_ab_metric.py` on the **identical crop** for B0/B1/B2 (G05 §3
  `--crop 120,60,1040,580`), plus the clean meadow crop `(1000,600)-(1270,700)` measured as in
  Y08 §1/§8.

### 4.2 C01 `tile_repeat` / `BV32` / `grad`

- **`tile_repeat`:** the 2 m cell pitch measured at E05 (34 px near / 51 px far) should **not**
  survive as a 2 m cadence in B2 — a 4 m cell doubles the world footprint, so any surviving
  repeat peak should move to roughly double the pixel period, and Branch A's one-id meadow
  should already have collapsed the 34/51 px peak in B1. Expect **no new 2 m cadence** and no
  new direction-locked streak (`band_peak_deg`, `coherence` must not worsen). Optional
  `--dump-map` probe: ordinary cells dominated by id 79 with only `ground1`/sand/rock
  exceptions, no out-of-atlas id.
- **`BV32`:** must stay **low** in B2 (Branch A removed the per-id checkerboard that fed the
  34/51 px peak). If `BV32` rises with a new periodic peak, that is a regression, not mottling.
- **`grad`:** must **not spike**. The 4 m cell gives a lower LOD via half gradients, which
  points `grad n640` slightly down; A11 §5 wants energy moved from HIGH to LOW frequency, not
  a fresh high-frequency spike.
- **Organic mottling (B2 vs B1 only):** `BV128 between_block_var` and block-scale luma std
  should **increase** relative to B1 while `BV32` stays low and `grad` does not spike; no new
  seam, black row or direction-locked streak. **If B2 shows no such movement, record that UV
  scaling alone did not create mottling** — A03 F02 predicts this — **do not** substitute a
  synthetic field (S-25-09) or reintroduce per-cell ids to force it.
- Clean-crop sanity that must hold in **all** frames: `non_black_fraction=1.0`,
  `full_width_dark_rows=0`.

### 4.3 Gates unchanged (G04 owns the runner; B01b runs none)

selftest **29/29**, uitest **17/17**, `t_render_mode`, `t_map_variety` **5/5** incl.
`same_seed_byte_identical`, `assert_clean` **CLEAN**, `script_error_lines == 0`, 2D `app/`
untouched. Optional `--dump-map` diff: `terrain`/`blocked`/`height` byte-identical to the
same-seed B0 dump (the shader cannot touch them).

### 4.4 Cosmetic note (out of scope)

The diagnostic string at `world3d_terrain.gd:1555` still prints `uv_repeat=(0.5,0.5)`. Syncing
it is optional and **not** in this diff (disjoint owner, Y08 §9.2). Treat that string as stale
when labelling captures; do not read it as evidence that B2 failed to apply.

### 4.5 Epistemic

The only rendered evidence is the G04 frame at §4.0. It did **not** show the hoped-for larger-scale
grain; the owner-visual result was **worse horizontal striping**, so the probe was rejected. The
camera was not matched to the `g04`/`y07`/`y08` baseline, so a pixel-aligned C01 delta was never
obtained; no C01 metric score is claimed. Every metric in §§4.1–4.3 is a movement indicator;
**no donor parity and no gate PASS is claimed** (CHARTER §3/§5).

## 5. Rollback (already performed by COORD) and availability

COORD performed the rollback; B01b verified it and performed **no** further code edit or runner
job. Verification command/output this follow-up:

```powershell
Get-FileHash -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader','inbox\backup\terrain_tileindex.gdshader.bak-B01b' -Algorithm SHA256
git diff --numstat -- variant3d/shaders/terrain_tileindex.gdshader
```

Both hashes return `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3`
(30,133 bytes) — the exact B01-released / pre-B01b state; `git diff --numstat` for the shader is
**empty**. Should a manual rollback ever be needed again, the copy is:

```powershell
Copy-Item -LiteralPath 'inbox\backup\terrain_tileindex.gdshader.bak-B01b' -Destination 'variant3d\shaders\terrain_tileindex.gdshader' -Force
```

No other file needs rolling back for B01b, and the probe **must not be re-applied**.

**Scope statement.** Repo files written by this ticket across its lifetime: the (now-reverted)
shader edit, its `.bak-B01b` backup, and **this report only**. B01b never started a Godot process,
submitted a runner job, mutated queue/lock/counter state, read/copied a donor file, edited
`.gd`/asset/config/test/JSON/git state, or changed any other shader line. This follow-up edited
**this report only** — no code, no runner, no re-application. No donor parity and no gate PASS is
claimed. **B01b stays available for any further COORD follow-up.**

*End of B01b report.*
