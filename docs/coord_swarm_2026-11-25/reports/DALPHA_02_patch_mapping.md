---
id: DALPHA-02
task: "Replace the arbitrary tile→alpha patch choice with DALPHA-01's donor-grounded APPROX"
date: 2026-11-25
status: DELIVERED__ONE_SHADER_EDITED__HEADLESS_SMOKE_GREEN__NO_DONOR_EXECUTED
scope: "Exactly two owned files: variant3d/shaders/terrain_tileindex.gdshader and this report. Required backup in inbox/backup/. NO other file edited, reverted or re-submitted."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "NOT opened this task. All donor facts are cited from DALPHA-01 (read-only audit). No donor binary executed, copied or modified."
owner_file: "variant3d/shaders/terrain_tileindex.gdshader"
backup: "inbox/backup/terrain_tileindex.gdshader.bak-DALPHA02"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
selection_rule_label: "PORT APPROXIMATION — donor engine rule UNVERIFIED (CONFIRMED_UNVERIFIED in DALPHA-01 §5 item 5)"
smoke_job: {id: dalpha02-smoke, ticket: 382, runner: "variant3d/tools/godot_runner.py", status: ok, exit: 0, stderr_bytes: 0, script_errors: 0, atom_result: "T_TERRAIN3D RESULT: PASS 6/6"}
parity_claim: false
---

# DALPHA-02 — donor-grounded APPROX tile→alpha patch selection

## 0. Mandate

TRN-SHADER shipped a confirmed 64² alpha sub-rect sampler but chose the patch with an
explicitly arbitrary, UNVERIFIED `5 + mod(tile, 22)`. DALPHA-01 resolved the atlas
geometry and supplied derived direction/counterpart structure while keeping the actual
engine rule **CONFIRMED_UNVERIFIED**. This task replaces **only** that selection
arithmetic with the donor-grounded APPROX, without claiming donor parity and without
touching any other file.

Read before editing: `DALPHA_01_alpha_subrect.md` §3.2–§3.4, §4, §5 verdicts 1–5, §6;
`TRN_SHADER_implementation.md` §1 C1/C2, §3, §4 item 2; the full current shader.

## 1. Backup (taken before the first edit)

| Item | Value |
|---|---|
| Path | `inbox/backup/terrain_tileindex.gdshader.bak-DALPHA02` |
| Size | 25,517 B |
| SHA-256 | `AD82E83907BF8F658E02839EEB9B122B5EFA8B9546570972D04723CF737E245D` |
| Pre-edit shader SHA-256 | identical (`AD82E8…E245D`) — verified by hash before editing |

Post-edit shader: 27,042 B, SHA-256 `01C44B6EC3963D70FE90CDB657857199491BDC565FD7BC3B9E346C08CA235E09`.

## 2. DALPHA-01 citations used

Every donor-grounded element below is cited from DALPHA-01; nothing was newly inferred
from donor bytes by this agent.

| DALPHA-01 citation | Verdict / label | What was used here |
|---|---|---|
| §5 verdict 1; §3.2 | **RESOLVED** — `alpha.bmp` 512×256 = 8 cols × 4 rows of 64² patches; seams only at x/y multiples of 64; patch `(c,r)` = `[64c,64c+64) × [64r,64r+64)`; `reftile.lib:10-12`; two decoders | kept the existing 64² sub-rect sampler: `((c+u)/8, (r+v)/4)` = `(cell + t) / vec2(8.0,4.0)` |
| §5 verdict 2; §2.2 | **RESOLVED** — all 245 `tiles.lib` sections share the atlas; zero `AlphaRows/Cols/TileSize` overrides | justifies one shared 8×4 selection rule for every tile id |
| §5 verdict 4; §3.4 | **PARTIAL / DERIVED** — mean dark-edge ranks T/L/R/B → rows 0/1/2/3 = **N/W/E/S**; not a donor enum | `dir → row`, N=0, W=1, E=2, S=3 |
| §5 verdict 3; §3.3 | **PARTIAL / DERIVED** — closest graded complements are the 180° partner; counterpart `(r,c) ↔ (3−r,3−c)` (left half); MAD 9.77–17.6; **not exact** | `row = mix(row, 3.0−row, opposite)`, `variant = mix(variant, 3.0−variant, opposite)` within the same half |
| §6.2 | **DERIVED APPROX** — direction→row N/W/E/S = 0/1/2/3; corner variants c1/c2 or c0/c3 | row ranking adopted; per-corner variant role not separately encoded (see §5 open question 2) |
| §6.3 | **DERIVED APPROX** — counterpart `(3−c,3−r)` **within the same 4-column half**; approximate only; keep `mask_to_alpha` diagnostic | counterpart applied to the *local* column index so it stays in the selected half; `mask_to_alpha` untouched |
| §6.4 | **INFERRED** — `(0,0)/(4,0)` = constant 255, `(3,3)/(7,3)` = constant 0; `alphanull` is the explicit no-mask binding | sentinel patches are now treated as donor-authored roles, not avoided by an arbitrary guard (see §5 open question 4) |
| §6.5 | **INFERRED** — columns 0–3 and 4–7 are two organic variants of the same four roles; pick half from a stable hash if variety is wanted | `half = mod(floor(id/16.0), 2.0)` |
| §5 verdict 5; §4; §6 preamble | **CONFIRMED_UNVERIFIED** — no tile-pair→patch rule: 17,237-file scan, 11 binaries × 3 encodings, 0 matcher function names, packed `.bind` (entropy 7.96), UV comes from `gl_MultiTexCoord1` (`hf.pvl.sm.vert:34`, `hf.pvl.smx3.frag:14`) | the code comment carries the exact label **PORT APPROXIMATION — donor engine rule UNVERIFIED**; no parity claim |
| §6 acceptance wording | "64² patch grid and override geometry are donor-grounded; the tile-pair→patch index and the exact complement are APPROX. No donor visual parity claimed." | adopted verbatim as the reporting stance |

## 3. Before → after arithmetic

### Before (TRN-SHADER, arbitrary; UNVERIFIED)

```glsl
float patch = 5.0 + mod(abs(tile), 22.0);          // UNVERIFIED deterministic map
vec2 cell = vec2(mod(patch, 8.0), floor(patch / 8.0));
```

Linear patch index 5..26 only, chosen to dodge the measured constant sentinels.
No direction, half or counterpart structure; the half/row split (`mod 8`, `floor /8`)
was an artifact of the linear index, not a donor role.

### After (DALPHA-02, donor-grounded APPROX)

```glsl
float id = floor(abs(tile));
float dir = mod(id, 4.0);                           // tile-id stand-in for boundary direction
float row = dir;                                    // N/W/E/S = 0/1/2/3 (DALPHA-01 §3.4)
float variant = mod(floor(id / 4.0), 4.0);          // 4 column variants within the half
float half = mod(floor(id / 16.0), 2.0);            // 0 -> cols 0-3, 1 -> cols 4-7
float opposite = mod(floor(id / 64.0), 2.0);        // stable stand-in for the opposite tile
row = mix(row, 3.0 - row, opposite);                // counterpart (r,c) -> (3-r,3-c), §6.3
variant = mix(variant, 3.0 - variant, opposite);    // local column counterpart in same half
vec2 cell = vec2(half * 4.0 + variant, row);
```

Decomposition of the single available `UV2.x` tile id: bits 0–1 → direction/row
(N/W/E/S), bits 2–3 → column variant within the half, bit 4 → half (0–3 / 4–7),
bit 5 → opposite-tile stand-in that switches on the derived counterpart. All outputs
stay in range: `row ∈ {0,1,2,3}`, `variant ∈ {0..3}`, `cell.x ∈ {0..7}`, `cell.y ∈ {0..3}`.
The port has no neighbour direction input, so these are deterministic **stand-ins**,
not recovered donor values.

### Deliberately unchanged (byte-identical)

```glsl
	// Half-texel inset from the 64² sub-rect border (donor AlphaTileSize=64).
	vec2 t = clamp(local, 0.0078125, 0.9921875);       // 0.5/64 .. 1-0.5/64
	return (cell + t) / vec2(8.0, 4.0);
}
```

`git diff --no-index` between the backup and the edited shader shows **one hunk**,
confined to the selection comment and the eight arithmetic lines above. Everything
else is byte-identical: donor sun / ambient / diffuse / `lsParallel` direction, world-XZ
texgen and `uv_repeat=0.5`, both face planes and `face_scale`, shadow/fog equations,
`alpha_patch_uv()` signature, `v_alpha_uv` 2 m phase, face-alpha branch,
`mask_to_alpha = 1.0`, `unshaded`, `cull_disabled`, tile atlas path.

No new sampler, art asset, normal map, foam, dither/noise, shadows or physical constant
was introduced. The only new numbers are integer decomposition bases (4/16/64) and the
literal `3.0` of the `(r,c) ↔ (3−r,3−c)` counterpart; all are part of the cited
8×4/4-column structure, not donor measurements.

## 4. Validation — variant runner only

Command (exactly the sanctioned headless smoke path; no full gates, no windowed ladder,
no direct `godot`):

```
python variant3d\tools\godot_runner.py run --id dalpha02-smoke --timeout 180 -- --headless --path variant3d --script res://tests/t_terrain3d.gd
```

| Field | Result |
|---|---|
| Job id | `dalpha02-smoke` |
| Ticket / status / exit | **382** / `ok` / **0** |
| Wait / run | 0.00 s / 19.04 s |
| stderr | **0 bytes** ⇒ `SCRIPT ERROR == 0` (explicitly counted: 0) |
| stdout | `T_TERRAIN3D PASS 6/6` (`module_load_and_api`, `build_ok`, `surface_count`, `vertex_count`, `has_chunk_or_fallback`, `height_at_world_samples`) |
| Result file | `variant3d\.godot_queue\results\00000382.json` |
| Logs | `variant3d\.godot_queue\results\00000382_dalpha02-smoke\stdout.txt`, `…\stderr.txt` |

No transient error from another builder's concurrent work was observed in this job.
This smoke proves shader/GDScript parse, build and geometry health only — it is **not**
a visual A/B and does not establish donor parity.

## 5. Explicit UNVERIFIED label and open questions

The shader comment says verbatim: **PORT APPROXIMATION — donor engine rule UNVERIFIED**.
The exact `tile_id + boundary_direction → patch` rule remains **CONFIRMED_UNVERIFIED**
(DALPHA-01 §5 item 5). No donor visual parity is claimed anywhere in this report or the
code.

1. **Still unresolved:** what arithmetic converts `TileScheme=tsDouble`,
   `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2` and two neighbouring tile
   ids into a patch + `MultiTexCoord1` values (DALPHA-01 §8 Q1). Needs donor execution or
   unpacking the packed `.bind`; out of scope.
2. **No neighbour input:** the port vertex stream carries one tile id per cell
   (`UV2.x`) and no boundary direction or neighbour id, so direction/half/opposite are
   tile-id stand-ins. §6.2's finer corner-vs-full-edge role choice (c1/c2 vs c0/c3) is
   therefore not separately encoded; `variant` spans the four column roles generically.
3. **Counterpart is only approximate:** MAD 9.77–17.6 in the left half, 18–84 in the
   right (DALPHA-01 §3.3, §8 Q3). A small seam tone step is expected; `mask_to_alpha`
   stays at 1.0 as §6.3 requests, unchanged.
4. **Sentinels can now be selected:** `(0,0)/(4,0)` = constant 255 and `(3,3)/(7,3)` =
   constant 0 are donor-authored roles per §6.4, so TRN-SHADER's arbitrary graded-only
   guard was removed. Whether a fully-cut patch is visually acceptable needs a live A/B;
   DALPHA-01 §8 Q4 (sentinel vs unused atlas slack) is still open. `alphanull` could not
   be preferred for same-tile cells (§6.4) because that would require a new sampler
   binding, forbidden by this task's scope.
5. **Two-half equivalence is INFERRED**, not confirmed (DALPHA-01 §6.5, §8 Q3).
6. **No donor GPU A/B exists.** The `PLAN_IMPLEMENTATION.md:30` acceptance tests remain
   owned by COORD; this ticket only guarantees structural health via the smoke job.

## 6. No-forbidden-change declaration

I edited **only** `variant3d/shaders/terrain_tileindex.gdshader` (one hunk: the selection
comment and its arithmetic) and wrote **only** `docs/coord_swarm_2026-11-25/reports/
DALPHA_02_patch_mapping.md` (this report). The backup in `inbox/backup/` was copied as
required. I did **not** edit, revert or re-submit `world3d_terrain.gd`, water files, game
code, tests, `app/**`, the runner, any asset, config or git state. Many other files were
already modified by concurrently working builders; all were left untouched. During this
task another builder committed the working tree (`HEAD = f9dd8d16 step`), so `git status`
no longer lists the shader as a local modification — `git show HEAD:variant3d/shaders/
terrain_tileindex.gdshader` and the backup diff confirm the single-hunk edit is present.
I did not make, amend or revert that commit. No donor file was opened, executed or copied
for this task.

## 7. Summary

Replaced TRN-SHADER's arbitrary `5 + mod(tile,22)` linear patch choice with a
deterministic decomposition that encodes DALPHA-01's derived structure: row =
boundary-direction rank N/W/E/S = 0/1/2/3, half = columns 0–3 / 4–7, four column
variants per half, and the `(r,c) ↔ (3−r,3−c)` counterpart within the same half.
The donor-grounded 64² `((c+u)/8, (r+v)/4)` sampling, half-texel inset, donor sun,
world-XZ texgen, face planes, `mask_to_alpha` and every other shader line are unchanged.
The choice is labelled **PORT APPROXIMATION — donor engine rule UNVERIFIED** in code;
the underlying rule stays **CONFIRMED_UNVERIFIED** and no parity is claimed. Backup
hash-verified before edit. Headless smoke `dalpha02-smoke` (ticket 382) green: exit 0,
0-byte stderr, `SCRIPT ERROR == 0`, PASS 6/6. No other file edited.

*End of DALPHA-02.*
