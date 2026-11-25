---
id: Y03
ticket: "URGENT follow-up — detail-pass neutralisation, ready-to-apply diff"
title: "Y03 — kill the surviving concentric maze in _apply_detail_pass() (game.gd owner file)"
agent: "Y03 (read-only analysis subagent; awaits COORD grant to apply)"
created: 2026-11-25
status: APPLIED__Y03_IMPL_GRANT__ONE_HUNK__NO_RUNNER__NO_GODOT__GATES_WITH_G04
scope: "Y03 read-only phase wrote one report only (a few Python PNG/JSON byte decodes to stdout). Y03-IMPL phase applied exactly one §3 hunk to variant3d/scripts/game.gd under COORD's exclusive-ownership grant and updated this report. No runner job, no Godot process, no .gdshader/asset/config/test/JSON/PNG/donor edit. See §10."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists (CHARTER §3). Every art/visual expectation is PORT APPROX or UNVERIFIED."
verdict: "RECOMMENDED: NEUTRALISE, DO NOT DELETE. Force every _apply_detail_pass() output to grass9 (idx 8) while KEEPING B03-P1's two _tb_pick() calls, so brng draw count/order is unchanged. This removes the height-following per-run ID switching that Y01b proved is the surviving maze. Deleting the pass entirely also kills the maze but shifts the brng stream for all later smoothing/border picks."
---

# Y03 — detail-pass fix (ready-to-apply)

> **Labels:** **OBSERVED** = literal source line, decoded file byte, or a pixel
> read directly from the named PNG; **DERIVED** = control-flow/arithmetic
> consequence of observed values; **INFERRED** = attribution with a caveat;
> **UNVERIFIED** = not provable with available instruments. No Godot was run,
> no runner job was submitted, no source file was edited. **Donor parity stays
> UNVERIFIED.**

---

## 0. Mandate and answer

Owner/COORD: the concentric maze survives B03's `terrain=5` removal in the fresh
windowed capture `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07c\realmap.png`.

**Answer:** neutralise `_apply_detail_pass()` by forcing all of its output ids to
**`grass9` (idx 8)**, keeping B03-P1's two `_tb_pick()` calls so the `brng` stream
is untouched. The exact one-hunk unified diff is in §3. Removing the pass
entirely is a valid but strictly worse alternative (§5 states the RNG
consequence). This is a **PORT APPROXIMATION diagnostic baseline**, not a donor
fidelity claim; L01's stamp-derived light/dark spots are the planned follow-up.

---

## 1. Evidence actually read this ticket (OBSERVED)

| Role | Path / lines | Fact |
|---|---|---|
| Fresh capture | `...\opencode\l07c\realmap.png` (1280×720, 1,770,781 B, mtime 15:44:48; L07c gate log §2) | Opened directly. Dense nested stair-stepped concentric bands across the whole meadow, closed ring chains around plateaus/buildings, plus tan/grey square aprons. The rings — not the aprons — are the target. |
| Current source | `variant3d/scripts/game.gd:1949-1998`, `:2003-2131`, `:2164-2210`, `:2212-2243`, `:2258-2330` | `_apply_detail_pass(brng)` traced end to end (§2). |
| Data proof | `Y01_maze_data_proof.md:300-449` (urgent follow-up Y01b) | Detail-id set `{14,15,16,78,79,8,7,77}` = **59,999 cells / 58.6%**, **0** overlap with `terrain==5`; 1–6 cell radial runs; radial corr up to **\|0.92\|** with height (`grass_ground1+3` vs height −0.922 at centre (201.5,233.0)); `h=0.1` discontinuity in the id columns. Strict complementarity with the rock set. |
| Detail bitmaps | `variant3d/assets/terrain/structs/tile_{lowground,highground}.png` | Decoded read-only (stdout): both 320×320 RGB8. R/2 values are **categorical ids** `{0,1,6,7,77,78,79,80,82,83,84,85}` (low) / `{1,7,8,9,78,79,80,83,84,85}` (high) — consistent with Y01b §8.3's finding that `corr(R,height)≈0`. Height enters only via the `:1976` bitmap **selection**. |
| Name table | `variant3d/assets/terrain/structs/presets_summer.json` (read-only parse) | `grass1=0, grass5=4, grass7=6, grass8=7, grass9=8, test7=78, test8=79, test9=80, test12/13/14=83/84/85`; 124 names. `grass9=8` is a valid in-atlas id (A03 §2/§4: best isotropic/seamless cell). |
| Art sanity | `variant3d/assets/terrain/blocks/rock1.png` vs `test8.png` (opened directly) | `rock1` = grey-brown vertical striation; `test8`/`grass9` class = clean olive. Confirms the surviving rings are **tile-id art**, not shading, and are inside the detail/smoothing id family. |
| Ownership / backup | `git status`, `git log`, `inbox/backup/game.gd*` | Working-tree `game.gd` blob `c0c884ce…` = committed L03 post-removal state (gradient pass collision-only, no `terrain=5` write). No uncommitted change; B03 has released the file. No `game.gd.bak-Y03` exists yet. |

**Honest caveat (DERIVED/UNVERIFIED):** I independently traced that the detail
pass cannot emit *rock* ids directly and has only one height branch (`h<0.1`);
before Y01b landed I therefore doubted the hypothesis. Y01b's decoded dump
resolves this: the ring cells carry `grass_ground1/3` and `test7/8` — **vein/
transition art**, in 1–6 cell height-following runs, strictly complementary to
the removed rock set. I accept the data proof as decisive and write the fix
against it. The exact `tileblock` of the `l07c` run remains **UNVERIFIED** (no
post-B03 dump exists); see §7.

---

## 2. Why neutralising the pass kills the maze (code trace)

1. `:2085` calls `_apply_detail_pass(brng)` **after** base blocks (`:2025-2077`)
   and shore/cliffs (`:2079`), and **before** the 3-pass smoother (`:2113`).
2. `:1973` restricts writes to cells still on `grass1` (id 0). Those are exactly
   the cells freed when the gradient pass stopped painting `terrain=5` — Y01b
   §8.2 measured **0** overlap between the detail set and the rock set.
3. `:1975-1981` selects `tile_lowground` **or** `tile_highground` by `h < 0.1`
   and reads `tex = R/2` — a **categorical id**, not a height value.
4. `:1989-1996` B03-P1 re-rolls `test7`/`test8` via `_tb_pick`, which consumes
   `brng` draws but only changes *which* non-base id appears.
5. `:1997-1998` writes `tileblock[i] = tex`. Because `tex ≠ grass1` for
   ~58.6% of the map, each height-following run is a visible colour step;
   `_smooth_tilemap(brng,3)` at `:2113` preserves short runs and reconciles
   their borders, so the contour geometry survives intact.
6. B03-P3 (`_tb_pick`, `:2237-2242`) redirects `grass_ground1/2/3 → grass9/test8/
   test7` — all still **≠ grass1**, so it cannot remove the pattern (Y01b §8.4).

**DERIVED:** making every write in step 5 resolve to the *same* id `grass9`
removes the per-run colour switching (the maze) while leaving run *geometry*,
bitmap reads, `brng` draws, terrain, height, blocked and all later passes
untouched. The field becomes one clean grass id; L01's mask-derived spots can
add organic light/dark variety in a separate, granted ticket.

---

## 3. Exact ready-to-apply unified diff — RECOMMENDED (neutralise, keep RNG)

File: `variant3d/scripts/game.gd`. Baseline: current working tree, blob
`c0c884ce…`, 243,752 bytes. One hunk, **12 added lines, 0 removed** (the
`tileblock[i] = tex` write is unchanged). The hunk header below is `-1982,17
+1982,29` — 17 context lines plus 12 additions.

```diff
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -1982,17 +1982,29 @@ func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
 			# B03-P1 (PORT APPROXIMATION, A04 §6 P1): the donor writes its two
 			# transition ids verbatim from the bitmap, which paints ~15% of the
 			# map one dark atlas cell. Re-roll ONLY those two through the donor
 			# lists that already contain them (RV-TRN-02 §7: Item 2 J=5
 			# test7/grass8/test6 cfg:267; Item 1 J=4 grass1/grass2/test8 cfg:155)
 			# using the port's existing weighted picker. No new id, no mask edit,
 			# no synthetic dither/noise field (charter S-25-09).
 			if tex == _blk("test7"):
 				var pick7 := _tb_pick(2, 5, brng)
 				if pick7 >= 0:
 					tex = pick7
 			elif tex == _blk("test8"):
 				var pick8 := _tb_pick(1, 4, brng)
 				if pick8 >= 0:
 					tex = pick8
+			# Y03 (PORT APPROXIMATION, diagnostic baseline — A08 §1.2, Y01b §8):
+			# the bitmap R is a CATEGORICAL tile id and the h<0.1 low/high
+			# selection makes its 1-6 cell runs follow height contours — the
+			# surviving concentric maze after B03 removed terrain=5. Collapse
+			# every detail-pass output to ONE clean donor grass id (grass9 idx 8,
+			# A03 §2 "best isotropic/seamless"). Keep the TWO _tb_pick calls
+			# ABOVE: they must consume the same brng draws so _smooth_tilemap
+			# and _stamp_forest_borders see an unchanged RNG stream. The donor
+			# uses these ids for mottling; removing their variety is a port-level
+			# substitution, not donor parity (UNVERIFIED). L01's stamp-mask
+			# spots are the planned organic-variety follow-up.
+			tex = _blk("grass9")
 			if tex >= 0 and tex < tbl_names.size():
 				tileblock[i] = tex
```

**Static sanity (no Godot):** `_blk("grass9")` returns `8` from `tbl_idx`
(124 names); `8 < tbl_names.size()` so the existing guard passes. No new
uniform, no new id, no new RNG draw, no `_hash2`/noise/dither token. Bracket/
quote balance unchanged (the hunk is a comment plus one assignment).

**Alternative one-liner with identical semantics** (if a smaller diff is
preferred — same RNG consequence as above):

```diff
-				tileblock[i] = tex
+				tileblock[i] = _blk("grass9")  # Y03 PORT APPROX: collapse detail ids; keep P1 draws above
```

Do **not** apply both; choose one hunk.

---

## 4. Backup command (Windows PowerShell, repo root)

```powershell
Copy-Item -LiteralPath 'variant3d\scripts\game.gd' -Destination 'inbox\backup\game.gd.bak-Y03' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y03' -Algorithm SHA256
```

Before-copy reference: size **243,752** bytes, git blob
`c0c884cefd048e9533bed6586dbf6b9a6d2d44be`. Do **not** overwrite
`game.gd.bak-B03` (238,546 B) or `game.gd.bak-B03-relief` (241,205 B).
Apply the §3 hunk only after the backup hash matches; verify after edit with
`git diff -- variant3d/scripts/game.gd` (expect exactly one hunk).

---

## 5. Alternative: remove the pass entirely — RNG consequence (stated, not recommended)

Deleting the call at `:2085` (`-	_apply_detail_pass(brng)`) and the function
would also kill the rings, but:

- **RNG stream shift:** B03-P1's `_tb_pick(2,5)` / `_tb_pick(1,4)` at `:1990`/
  `:1994` fire once per eligible `test7`/`test8` bitmap cell — Y01b §8.2 measured
  ~6,691 + 7,667 such cells in the 320² dump (before redirect). Removing the
  call removes **all** those `brng.randf()` draws, shifting every later
  `_smooth_tilemap(brng,3)` and `_stamp_forest_borders(brng)` pick. Tileblock
  bytes change for every seed (TRN-DATA precedent, `game.gd:2125-2126`).
- **What does NOT change:** `terrain`, `height`, `blocked`, `res_nodes`,
  `map_starts`, `rng`, `gen_rng` and `_gen_patterns()` replay — `brng` has no
  consumer outside tile decisions (B03 §4). So mapgen/gameplay streams stay
  byte-identical and `t_map_variety same_seed_byte_identical` still holds
  (same seed → same bytes). Only a **frozen tileblock hash** would fail, which
  is not a valid gate (B03 R1).
- **Fidelity cost is larger:** the donor detail pass is a real authored stage
  (A08 §1.2 item 2, `loadtextureterrainfrombitmap.inc:4,8-9,25-41`); deleting
  the function discards that structure, not just its output variety.

**Recommendation:** use §3 (neutralise, keep draws). It kills the colour rings
with **zero** RNG-stream delta and reversibility in one line.

---

## 6. Invariants (must hold after applying §3)

| Invariant | Status | Reason |
|---|---|---|
| RNG stream | **byte-identical** | `_tb_pick` calls at `:1990`/`:1994` kept; same draw count and order; `brng` sequence feeding `_smooth_tilemap(brng,3)` (`:2113`) and `_stamp_forest_borders(brng)` (`:2116`) unchanged. |
| Determinism | preserved | Same seed → same `brng` → same bytes; `t_map_variety same_seed_byte_identical`. No frozen hash gate. |
| `tileblock` contract | intact | `PackedByteArray` (`:53`), size `MAP_W*MAP_H`, uint8 id `grass9=8` valid in 124-name `tbl_names`; existing range guard at `:1997` unchanged; only cells equal to `grass1` are written, so `BLK_WATER=255` (`:52`) is never touched by this pass. |
| `height` / `terrain` / `blocked` | **untouched** | No write in this hunk; gradient pass already collision-only (`:1297-1310`); stone-quarry `terrain=5` disc at `:852` kept. |
| Shore / mine / winter authorities | intact | `_apply_shore_cliffs()` `:2079`, mine apron final authority `:2120-2122`, forest borders `:2116`, winter alias `:2127-2131` all unchanged and still run last. |
| Atlas / mesh / shader / tests / config / `app/` | untouched | Single-line change inside one function in `variant3d/scripts/game.gd`. |
| No synthetic field | honoured | No dither/noise/Bayer/gain/luminance term (CHARTER §3 S-25-09; A08 §7 #2). |
| No donor parity claim | honoured | Labelled **PORT APPROXIMATION**; no GPU A/B exists. |

---

## 7. Acceptance (measure; do not assert)

### 7.1 Structural / gate (COORD/G04 owns the runner; Y03 runs none)
- Gates unchanged and green: `t_map_variety` **5/5** including
  `same_seed_byte_identical`; variant selftest **29/29**; uitest **17/17**;
  `t_render_mode`; `assert_clean` **CLEAN**; 2D `app/` untouched.
- No threshold lowered, no assertion deleted, no expected-failure flipped.
- `git diff` shows exactly the §3 hunk; backup hash verified.

### 7.2 Post-fix dump probe (read-only; Y01b §8.5 recipe, new unique id)
Capture a dump from the same post-Y03 windowed seed-20261113 run and check:
1. detail-set ids `{14,15,16,78,79,8,7,77}` collapse — `grass9 (8)` becomes the
   dominant meadow id; near-zero `grass_ground1/3` and `test7/8` from the detail
   pass (residual ids may come from unrelated smoothing/forest-border paths);
2. radial-profile correlation of the *remaining* non-`grass9` detail ids with
   `height` drops toward 0 at ring centres (201.5,233.0), (124.8,64.6),
   (79.4,162.4) — the height-following colour signal is gone;
3. no out-of-atlas id; `terrain==5` count still only the stone discs;
4. `blocked[]` unchanged vs pre-Y03 same-seed run (collision preserved).

### 7.3 Visual (matched camera, C04/G05 protocol)
- **No concentric/maze rings, no nested contour bands** anywhere on the frame.
- No checker mosaic, no repeated dark blotches, no new seams/black rows;
  `non_black_fraction=1.0`, `full_width_dark_rows=0`.
- A11/C01 metrics (`BV32`, `grad`, luma std, `row_periodicity`, `tile_repeat`)
  measured on the AFTER frame with `terrain_ab_metric.py` on the identical crop
  as G05 — **movement indicators only, not thresholds or parity claims**.
  Expect the field to read flatter/more uniform until L01 spots land; a rise in
  `tile_repeat`/visible tiling is a real risk (mitigated by B01 mirror/warp).

### 7.4 Epistemic
- No donor parity: donor parity stays **UNVERIFIED** (CHARTER §3/§5). The exact
  `l07c` tileblock is still **UNVERIFIED** (Y01b §8.4/§8.5); this fix is
  justified by Y01b's dump correlation plus the unchanged visual geometry, not
  by a measured pixel-to-id mapping of that specific frame.
- Donor-fidelity cost is real and acknowledged: A08 §1.2 says the donor detail
  bitmaps select tile ids for 1–6 cell mottling. Collapsing them to one id
  removes that variety. **L01's stamp-mask, donor-weighted light/dark spot plan
  (`L01_spot_grass.md` §5) is the planned restoration** — separate ticket,
  separate COORD grant, its own backup and RNG note.

---

## 8. Rollback

```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y03' -Destination 'variant3d\scripts\game.gd' -Force
```

Verified by hash against the before-copy value in §4. No other file changed.

---

## 9. Scope statement

Under the original read-only Y03 ticket, only this report was written; the two
Python decodes (detail-bitmap PNG R channel; `presets_summer.json` name order)
printed to stdout only. Under the later **Y03-IMPL grant** (§10) the §3 primary
hunk was applied to `variant3d/scripts/game.gd` and this report updated. No
Godot process, no runner job, no queue/lock/counter mutation, no shader,
atlas, mesh, test, config, `app/` or donor edit was made. Donor parity is
**UNVERIFIED**.

---

## 10. APPLIED (Y03-IMPL, COORD exclusive-ownership grant)

Status: **APPLIED**. Exactly **one** hunk from §3 (the primary grass9
neutralisation) was applied. The §3 one-liner alternative and the §5
remove-the-pass option were **not** applied.

### 10.1 Preconditions and backup (OBSERVED)
- Pre-apply `game.gd`: git blob `c0c884cefd048e9533bed6586dbf6b9a6d2d44be`,
  243,752 bytes, no uncommitted change; no `game.gd.bak-Y03` existed.
- Backup created **before** the edit with the §4 command:
  `inbox/backup/game.gd.bak-Y03`.
- SHA-256 (**both files identical before the edit**):
  `8D1A7A3F7A84C77B2ACCA7CA3E92648827498D609B5640BE1D8AEA4F993EADD1`
- Backup git blob: `c0c884cefd048e9533bed6586dbf6b9a6d2d44be` (exact match).
- `git apply --check --verbose` → `Checking patch variant3d/scripts/game.gd...`,
  exit **0**. `git apply --verbose` → `Applied patch variant3d/scripts/game.gd
  cleanly.`, exit **0**. `git diff --check` → exit **0** (only pre-existing
  LF/CRLF warnings in *other* files; no whitespace error in this diff).
- Post-apply `game.gd` git blob: `e0c2b5ed28979d65ee0505b77ad33259a925847a`.

### 10.2 Exact applied diff (verbatim `git diff -- variant3d/scripts/game.gd`)

```diff
diff --git a/variant3d/scripts/game.gd b/variant3d/scripts/game.gd
index c0c884ce..e0c2b5ed 100644
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -1994,6 +1994,18 @@ func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
 				var pick8 := _tb_pick(1, 4, brng)
 				if pick8 >= 0:
 					tex = pick8
+			# Y03 (PORT APPROXIMATION, diagnostic baseline — A08 §1.2, Y01b §8):
+			# the bitmap R is a CATEGORICAL tile id and the h<0.1 low/high
+			# selection makes its 1-6 cell runs follow height contours — the
+			# surviving concentric maze after B03 removed terrain=5. Collapse
+			# every detail-pass output to ONE clean donor grass id (grass9 idx 8,
+			# A03 §2 "best isotropic/seamless"). Keep the TWO _tb_pick calls
+			# ABOVE: they must consume the same brng draws so _smooth_tilemap
+			# and _stamp_forest_borders see an unchanged RNG stream. The donor
+			# uses these ids for mottling; removing their variety is a port-level
+			# substitution, not donor parity (UNVERIFIED). L01's stamp-mask
+			# spots are the planned organic-variety follow-up.
+			tex = _blk("grass9")
 			if tex >= 0 and tex < tbl_names.size():
 				tileblock[i] = tex
```

`git diff --stat`: `variant3d/scripts/game.gd | 12 ++++++++++++` — **1 file,
12 insertions, 0 deletions**. No other file was changed by this ticket.

### 10.3 Invariance argument (DERIVED from the applied diff)
- **RNG stream byte-identical.** The only executable insertion is
  `tex = _blk("grass9")`; both `_tb_pick` calls at post-apply `:1990` and
  `:1994` remain verbatim and in the same order, with the same arguments.
  `_blk()` is a pure dictionary lookup and draws no RNG. Therefore the number
  and order of `brng.randf()` calls inside `_apply_detail_pass()` is unchanged,
  and the `brng` state entering `_smooth_tilemap(brng,3)` (post-apply `:2125`)
  and `_stamp_forest_borders(brng)` (`:2128`) is bit-identical for a given seed.
  The only behavioural delta is the *value written*: `grass9 (8)` instead of
  the bitmap-derived id.
- **Determinism:** same seed → same `brng` → same bytes;
  `t_map_variety same_seed_byte_identical` holds by construction. A frozen
  tileblock hash is not a valid gate (TRN-DATA / B03 R1 precedent); this change
  is *expected* to change tileblock bytes.
- **Tileblock contract:** `PackedByteArray` (`:53`) size `MAP_W*MAP_H` and
  uint8 ids unchanged; `grass9=8` exists in the 124-name `tbl_idx`; the guard
  `tex >= 0 and tex < tbl_names.size()` is untouched and passes for 8; the pass
  still touches only cells whose current id is `grass1` (`:1973` pre-apply),
  so `BLK_WATER=255` (`:52`) is never written here.
- **height / terrain / blocked / collision:** no write added or removed in any
  of them; the gradient pass remains collision-only (`:1297-1310`), with the
  stone-quarry `terrain=5` disc at `:852` retained.
- **Later authorities:** shore/cliffs, 3-pass smoother, forest borders, mine
  apron and winter alias all still run in the same order and win as before.
- **Guardrails:** no synthetic dither/noise/gain/`_hash2` field, no new donor
  constant, no shader/atlas/mesh/test/config/`app/` edit. PORT APPROXIMATION;
  no donor parity claim (CHARTER §3/§5).

### 10.4 Gate list for G04 (Y03 runs none — one Godot at a time)
Run on the post-Y03 tree with unique ids; no threshold or assertion may change:
1. `variant3d` selftest — expect **29/29**.
2. `variant3d` uitest — expect **17/17**.
3. `t_render_mode` — green.
4. `t_map_variety` — **5/5**, including `same_seed_byte_identical` (two runs
   of the same seed must match; frozen hash must **not** be used).
5. `assert_clean` — **CLEAN**.
6. 2D `app/` gates — untouched, still green.
7. Captures with `--seed 20261113`, unique ids, matched camera: fresh windowed
   **64² P0** and **real map** PNG; C04/G05 visual read for **zero concentric
   maze rings**, no checker mosaic, no repeated dark blotches, no new seams or
   black rows; `non_black_fraction=1.0`, `full_width_dark_rows=0`.
8. Optional decisive probe (Y01b §8.5): same post-Y03 run with
   `--dump-map` → decode `tileblock`, check the §7.2 id-collapse/correlation
   acceptance items. No donor access required.

G04 should record paths, timestamps, camera and result JSON fields verbatim;
treat A11/C01 metric numbers as movement indicators only.

### 10.5 Rollback
As §8. Restores blob `c0c884cefd048e9533bed6586dbf6b9a6d2d44be` exactly.

### 10.6 Epistemic status
No Godot process, no runner job, no queue mutation, no donor file read or
copied, and no other source file edit occurred in this implementation step.
Whether the maze is actually gone in the rendered frame is **UNVERIFIED**
until G04's matched-camera capture and the post-fix dump probe; no donor parity
claim is made.

*End of Y03 — report + one applied game.gd hunk; no runner, no parity claim.*
