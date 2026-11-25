---
id: Y07
ticket: "URGENT — surviving concentric rings after Y04 guards + Y05 banding fix"
title: "Y07 — the surviving ring producer is the stale Y04 guard id, not a new stamp"
agent: "Y07 (read-only analysis subagent)"
created: 2026-11-25
status: DELIVERED__Y07_IMPL_APPLIED__FOUR_GUARD_LINES__NO_RUNNER__NO_GODOT__GATES_WITH_G04
scope: "Analysis phase wrote one report only (image/crop decodes read-only). Under COORD's Y07-IMPL exclusive-ownership grant exactly four one-line guard edits were applied to variant3d/scripts/game.gd at :2315/:2319/:2323/:2327, plus one pre-edit backup inbox/backup/game.gd.bak-Y07, and this report was updated with §8. No runner job, no Godot process, no queue/lock/counter mutation, no .gdshader/asset/config/test/JSON/result/donor edit. No donor parity claim."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "NO DONOR PARITY CLAIM. No donor file, donor screenshot or donor GPU A/B frame was read or executed for an attribution claim. All donor references are structural citations inherited from prior in-repo reports; every visual expectation here is internal consistency only."
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/Y04_remaining_rings.md
  - docs/terrain_swarm_2026-11-25/reports/Y05_horizontal_banding.md
  - docs/terrain_swarm_2026-11-25/reports/L01_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - variant3d/scripts/game.gd (current tree: :360-408, :845-862, :1959-2010, :2015-2152, :2233-2337, :2339-2343, :2365, :2480)
  - "IMAGE: C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y04b\\realmap.png (mtime 2026-11-25 16:35:59) and its six crops under y04b\\crops\\"
  - "On-disk dump inventory: app\\shots\\g32_dump.json (mtime 2026-11-24 11:35:49), app\\shots\\t6t90_dumps\\*, scans\\t2gen\\dump_*.json — all PRE-Y03/Y04/Y05"
verdict: "The surviving producer is the UNCHANGED 3-pass donor smoothing chain (_smooth_tilemap :2134 -> _tb_smooth_pair :2267-2328 -> _tb_pick :2233-2265, donor rules :1604-1760). It survived Y04 because Y05's one-line :2008 swap changed the neutralised meadow id from grass9 (idx 8) to test8 (idx 79) while the four Y04 midpoint guards at :2315/:2319/:2323/:2327 still test '!= _blk(\"grass9\")'. On a test8 meadow that predicate is always TRUE, so the guards are inert and midpoint transition ids are written back into the meadow; three passes turn each patch boundary into nested bands. MINIMAL FIX: realign all four guards to test8 AND retain the original grass9 exclusion (four one-line edits, no RNG/terrain/height/blocked delta). No donor parity claim."
---

# Y07 — surviving ring producers after Y04 + Y05

> **Labels:** **OBSERVED** = literal source line, decoded file byte, on-disk metadata, or
> a pixel read directly from `y04b/realmap.png` / its crops. **DERIVED** = control-flow or
> arithmetic consequence of OBSERVED facts. **UNVERIFIED** = cannot be proved with the
> available instruments. No Godot process was launched, no runner job submitted, no
> repository file but this report written. **Donor parity stays UNVERIFIED.**

---

## 0. Mandate

COORD: open the latest clean capture `y04b/realmap.png`; horizontal banding is fixed,
but concentric rings still surround every start/deposit and the town. Y04's four
smoothing guards did **not** remove them. Determine the surviving producer with exact
current `file:line` from the named candidate list, using code plus on-disk dump data,
and give the **minimal fix** that removes the rings while preserving Y03/Y05 detail
neutralisation, L01 spots, Y04 smoothing guards, mine apron authority, RNG stream and
all gates. Read-only; no runner, no Godot, no donor-parity claim.

---

## 1. What the capture shows (OBSERVED)

`y04b/realmap.png` (1280×720, mtime 16:35:59, after `game.gd` mtime 16:28:20) was
opened directly; six supplied crops under `y04b\crops\` were also read.

- **Concentric nested stair-stepped bands persist** in grey-brown/olive striated art:
  a large set wrapping the central hall and both thatched huts; a serpentine chain
  running down-left from the town; tight multi-ring sets around **every** reddish
  rubble/deposit disc; and bands along the border of the upper-right conifer clearing.
  The rings are 1–3 cells wide and nest 3–6 deep (`r2_center.png`, `tile_detail.png`).
- Each rubble disc sits inside a sharply bounded **checkerboard ground apron**; the
  rings sit *outside* that apron, in the olive meadow (`tile_detail.png`).
- The **fine screen-horizontal corrugation of `y03` is much reduced**: the open field
  now reads as broad olive swaths with only mild horizontal striping. This is a
  directional change only — no matched-camera A/B exists, so the attribution to Y05's
  `test8` swap is **UNVERIFIED** (Y05 §7 item 2, same caveat).
- No cyan water, no black rows, no new seams are visible in this frame.

The `y04b` directory contains only the PNG, its `.raw.png` twin, six crops and a crop
script — **no `--dump-map` JSON and no camera/stderr log**. The newest on-disk dumps
(`g32_dump.json` 11/24 11:35:49; `t6t90_dumps`; `scans\t2gen\dump_*.json`) all predate
Y03, Y04 and Y05. Therefore the exact tile id at any ring pixel is **UNVERIFIED**; the
attribution below is control-flow derivation from the current source plus unchanged
ring geometry, exactly as in Y04 §6 item 1.

---

## 2. Root cause — the guards were left pointing at the old id (OBSERVED + DERIVED)

This is the decisive finding.

| # | Fact | Label | Evidence |
|---|---|---|---|
| 1 | Y03 collapsed every detail-pass output to `grass9`, **idx 8**. | OBSERVED | L01_impl §2 hunk 1 historical comment; Y04 §8.2 |
| 2 | Y04 added four midpoint guards of the form `if ni >= 0 and int(tileblock[cell]) != _blk("grass9")`. | OBSERVED | current `game.gd:2315`, `:2319`, `:2323`, `:2327` |
| 3 | Y05 applied one line changing the neutralisation output to `test8`, **idx 79**, at the **same site** `:2008`. | OBSERVED | `game.gd:2008` `tex = _blk("test8")`; Y05 §9.2 |
| 4 | No other `grass9` reference in the guards was updated. Grep of `game.gd` finds `_blk("grass9")` only at `:2259` (B03-P3 redirect, intentional), `:2315/:2319/:2323/:2327` (the four stale guards), `:2365` (L01 `base_ids`, intentional) and `:2480` (L01 light-id picker, intentional). | OBSERVED | grep result |
| 5 | After Y05, the neutralised meadow cell holds **79**, so `int(tileblock[cell]) != _blk("grass9")` evaluates **79 != 8 → TRUE**. The guard no longer blocks the midpoint write. | DERIVED | facts 2–4 |
| 6 | The three `_smooth_tilemap` passes therefore write transition ids (`rock9`, `grass5`, `test7`, … from the donor lists at `:1604-1760`) back into meadow cells at every non-grass boundary, and successive passes nest them into the observed 3–6-deep bands. | DERIVED | `game.gd:2134`, `:2330-2337`, `:2286-2308`, `:2233-2265`; ring geometry in §1 |

**Short answer:** the producer that Y04 meant to suppress is still running; Y04's guard
was neutralised by Y05's *correct* banding fix. This is not a new stamp and not a
reintroduced `terrain=5` paint. It is a **stale-target-id interaction between two
already-applied fixes** (PORT APPROXIMATION throughout).

---

## 3. Candidate-by-candidate verdict (exact current `file:line`)

| Ticket candidate | Current `file:line` | Present? | Ring producer? | Label / note |
|---|---|---:|---:|---|
| Mine apron `ground1`/`test2`/`test3` | `:2084-2088` (apron), `:2141-2143` (final authority), `_finalize_mine_tiles()` `:372-398` (ground1 `:383-385`, start keep-clear `:386-408`) | YES | **NO — patch interior** | OBSERVED. Supplies the checkerboard squares and the non-grass boundaries the rings wrap. T2GEN P0-1 gate-protected; must not be removed. |
| B03-P2 `tile` stamps → `ground1` | `:2098-2121` (write at `:2121`) | YES | **NO — local seed** | OBSERVED: 4 stamps on shipped seed (B03 §9 / `g32_dump.json` meta `tile=4`). `ground1`, no RNG. Seeds a few boundaries only; cannot wrap every start/deposit. |
| Stone stamp `terrain=5` disc | `:847-852` (paint at `:852`), rock ids `:2071-2083`, oriented cliff `:2228-2231` / `_cliff_tile_for` `:2176-2209` | YES | **NO — minor seed** | OBSERVED: the only `terrain[…]=5` write in `game.gd` (grep). A ≤2-cell disc per stamp; seeds grey rock art but cannot by itself make multi-cell nested chains (Y04 §3 rank 3). |
| Start keep-clear ring | `_finalize_mine_tiles()` `:386-408`, called at `setup()` `:370` **after** `_assign_tileblocks()` `:368` | YES | **NO** | OBSERVED. Forces a 16-cell `grass1` disc (`terrain 2→0`, `:395-398`) and unblocks it **after** smoothing has run. Its edge is a hard post-smooth edge, not a smoothed band chain. |
| Detail pass now `test8` | `:1959-2010`, trigger at **`:2008`** | YES | **TRIGGER, not writer** | OBSERVED/DERIVED. `:2008` writes the neutral id; it creates no ring itself. Its `grass9→test8` swap is what made the four Y04 guards stale (§2). Do **not** revert. |
| `res_nodes` deposit discs | `_mark_mine_mask` `:628-629`, called `:2023-2025` and `:377-379`; apron marking `:597-623` | YES | **NO — patch seed** | OBSERVED. Marks `mine_mask`, which `:2084-2088`/`:2141-2143` render as `ground1`. Also causes the early-return in `_tb_smooth_pair` at `:2270-2271`, i.e. it actually *suppresses* smoothing inside the disc. |
| `terrain=5` rock paths | would require a `terrain=5` write in the gradient pass (`:1297-1310`) | **NO** | **REFUTED** | OBSERVED: grep finds exactly one `terrain=5` write (`game.gd:852`). B03 §11 / L03 made the gradient pass **collision-only**; no rock-art paint remains there. |
| **3-pass donor smoothing (not on the ticket list)** | call `:2134`; driver `:2330-2337`; writer `_tb_smooth_pair` `:2267-2328`, midpoint writes `:2313-2328`; picker `_tb_pick` `:2233-2265`; rules `:1604-1760` | YES | **YES — PRIMARY** | OBSERVED code + DERIVED control flow (§2). The only surviving code that manufactures multi-cell nested transition bands. The four guards meant to stop it are inert on `test8`. |
| L01 spots (must be preserved) | call `:2130`; function `:2359-2493`; `base_ids` `:2365` | YES | **NO** | OBSERVED. Forest-core-local 1–6-cell runs; writes `grass9/test9/test8/grass5` **before** smoothing. Not a ring source, but its `grass9` cells were protected by the old guard and must stay protected by the fix. |

**DERIVED causal chain (current tree):**

```
stone/road/mine/tile stamps (terrain roles + ground1 apron)
   -> local non-grass patch inside the meadow
   -> _apply_detail_pass :2008 neutralises meadow to test8 (79)
   -> _stamp_grass_spots :2130 (forest-local, must survive)
   -> _smooth_tilemap(brng,3) :2134
        -> _tb_smooth_pair :2270 mine_mask early-return (apron safe)
        -> midpoint _tb_pick :2314/:2318/:2322/:2326 (draws unchanged)
        -> guards :2315/:2319/:2323/:2327 test grass9 (8) — INERT on test8 (79)
        -> transition ids written into meadow, 3 passes nest them
   -> nested 1–3-cell bands = the surviving rings
```

The checkerboard squares are the patch interiors (deliberate, gate-protected); the
rings are the smoothing halo around them. Removing either the squares or the stone
disc would not remove the rings — it would only move the boundaries.

---

## 4. Minimal fix (proposed in analysis; applied under the Y07-IMPL grant — see §8)

**One file:** `variant3d/scripts/game.gd`. **Four one-line edits** in
`_tb_smooth_pair()` at current `:2315`, `:2319`, `:2323`, `:2327`. Keep every
`_tb_pick()` call verbatim; only change which *current* cell values are protected
from receiving a midpoint id.

Why two exclusions: `test8` is the current neutralised meadow id (Y05) — adding it is
what actually kills the rings. `grass9` is retained because L01's spot pass still
writes `grass9` cells (`:2480` picker) that the original Y04 guard protected; dropping
it would let smoothing erode those spots. This is a widening of the Y04 guards, never
a weakening.

```diff
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -2313,15 +2313,15 @@ func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGener
 	if bi1 - bi2 == 2:
 		var ni := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
+		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni
 	elif bi2 - bi1 == 2:
 		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
+		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni2
 	elif bi1 < bi2:
 		var ni3 := _tb_pick(best, bi1 + 1, brng)
-		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
+		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni3
 	else:
 		var ni4 := _tb_pick(best, bi2 + 1, brng)
-		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
+		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni4
```

A strictly smaller variant — swap `grass9`→`test8` in the four lines — is possible but
**not recommended**: it would stop protecting L01's `grass9` spot cells, violating the
"keep L01 spots" constraint (DERIVED from `:2365`/`:2480` and the guard semantics).

### 4.1 Invariants (DERIVED from the diff)

| Invariant | Status | Reason |
|---|---|---|
| Y03/Y05 detail neutralisation | **intact** | `:2008` `tex = _blk("test8")` and the two P1 draws at `:1989-1996` are untouched. |
| L01 spots | **intact** | `_stamp_grass_spots(brng)` call `:2130` and function `:2359-2493` untouched; `grass9` spot cells keep their old protection, `test8` spot cells gain protection. |
| Y04 smoothing guards | **intact, widened** | Same four sites, same `ni >= 0` checks, same `_tb_pick` calls; the predicate is broadened, never narrowed. |
| Mine apron authority | **intact** | `:2084-2088`, `:2141-2143`, `_finalize_mine_tiles()` `:372-398` and the `mine_mask` early-return `:2270-2271` are all untouched. |
| RNG stream | **byte-identical** | All four `_tb_pick` calls keep the same order and arguments; `_blk()` is a pure dictionary lookup and draws no RNG (Y03 §10.3, Y05 §9.4). `brng` entering later passes is unchanged. |
| `terrain` / `height` / `blocked` | **byte-identical** | No write added or removed in any of them; collision, start protection and walkability stay as-is. |
| `tileblock` contract | **intact** | `PackedByteArray` size/type, uint8 ids, `ni >= 0` checks and `_blk()` validity unchanged; no out-of-atlas id. |
| Guards / gates | **honoured** | No threshold lowered, no assertion deleted, no `expected_pre_fix_failure` flipped, no synthetic dither/noise/hash field. Same-seed determinism preserved. A frozen tileblock hash is **not** a valid gate (B03 R1 / TRN-DATA). |
| Donor parity | **none claimed** | PORT APPROXIMATION; no donor A/B frame exists. |

### 4.2 What NOT to do

1. **Do not revert `:2008` to `grass9`** — that reinstates Y05's horizontal corrugation
   (the tile-id-coupled alpha patch (2,0)). The banding fix was correct; the guard
   simply failed to follow it.
2. **Do not restore the `terrain=5` gradient paint** (`:1297-1310`) — L03/B03 §11 made
   it collision-only to kill the field maze.
3. **Do not remove the mine apron, B03-P2 stamps or the stone disc** — they are the
   patch seeds and gate-protected; removing them changes gameplay/collision and only
   moves the boundaries the rings sit on.
4. **Do not re-apply B04 face promotion or enable an anisotropy/noise field** —
   recorded regressions (L03 §2, CHARTER §3 S-25-09).

### 4.3 Gate list (G04 owns the runner; Y07 runs none)

1. `variant3d` selftest **29/29**; uitest **17/17**; `t_render_mode` green.
2. `t_map_variety` **5/5** including `same_seed_byte_identical` (two runs, not a
   frozen hash).
3. `assert_clean` **CLEAN**; 2D `app/` gates untouched; `script_error_lines == 0`,
   `full_width_dark_rows == 0`, `non_black_fraction == 1.0`.
4. Matched-camera windowed seed-20261113 real-map capture with a unique id; C04/G05
   R1–R6 read: expect zero nested stepped bands around town/deposits, L01 spots still
   present, aprons intact, no new seams/black rows. C01 metrics are movement
   indicators only, never thresholds.
5. **Decisive read-only probe** (new unique id, `--dump-map`): decode `tileblock` and
   confirm non-`test8`/non-`grass9` transition ids (`rock9`, `grass5`, `test7`,
   `test8`-adjacent ids) collapse in the meadow; radial profiles at the historical
   ring centres lose their peaks; `terrain==5` stays at the stone-disc level;
   `blocked[]` byte-identical to the same-seed pre-fix dump.

---

## 5. UNVERIFIED register — do not guess

1. **No post-Y05 dump exists.** `g32_dump.json` and all other on-disk dumps predate
   Y03/Y04/Y05; `y04b\` holds only images. The exact tile id at any ring pixel was
   **not** decoded. §2/§3 are control-flow derivations, not a measured histogram.
2. **No A/B with pinned camera.** The ring change from `l07c`/`y03` to `y04b` is a
   direction-of-change observation only; camera parameters for `y04b` were not
   available (no stderr/diag file in the folder).
3. **Whether the proposed fix actually removes the rings in the rendered frame is
   UNVERIFIED** until G04's matched-camera capture and the dump probe. No Godot,
   runner job or code edit was performed in this ticket.
4. **The residual mild horizontal striping's exact cause** is UNVERIFIED; it is not
   attributed to this fix and is Y05 §6.2 territory.
5. **No donor parity claim.** No donor image, binary or GPU frame was read or
   executed for attribution. PORT APPROXIMATION throughout.

---

## 6. Claim ledger

| Claim | Label | Evidence |
|---|---|---|
| Concentric bands still wrap the town, every deposit and the grove; banding much reduced | OBSERVED | direct reads of `y04b/realmap.png` + `crops\r2_center.png`, `crops\tile_detail.png` |
| Detail-pass neutral id is `test8` (79) at `:2008` | OBSERVED | `game.gd:2008`; Y05 §9.2 |
| Four Y04 guards still test `!= _blk("grass9")` at `:2315/:2319/:2323/:2327` | OBSERVED | grep + read of `game.gd:2310-2329` |
| Guards are inert on the neutralised meadow | DERIVED | `79 != 8` → write proceeds; §2 |
| Smoothing is the surviving ring amplifier | OBSERVED code + DERIVED | `:2134`, `:2330-2337`, `:2267-2328`, `:2233-2265`, `:1604-1760` |
| Mine apron / B03-P2 / stone disc / `res_nodes` are patch seeds, not ring writers | OBSERVED + DERIVED | `:2084-2088`, `:2141-2143`, `:372-398`, `:2098-2121`, `:852`, `:597-623`; early-return `:2270-2271` |
| `terrain=5` rock paths refuted | OBSERVED | one `terrain=5` write at `:852`; gradient pass collision-only (B03 §11) |
| Proposed guard realignment is gate-safe | DERIVED | §4.1; no RNG/terrain/height/blocked write changed |
| Exact ring-pixel ids; rendered effect of the fix; donor parity | UNVERIFIED | no post-Y05 dump, no Godot, no donor A/B |

---

## 7. Scope statement

Analysis phase (Y07) wrote one report only and performed no code edit, runner job,
Godot launch, queue/lock/counter mutation, donor read or scratch-file write. Under
COORD's subsequent **Y07-IMPL exclusive-ownership grant**, exactly four one-line guard
edits were applied to `variant3d/scripts/game.gd`, one pre-edit backup was created, and
this report was updated with §8. No `.gdshader`, asset, config, test, JSON, result or
donor file was edited in either phase; no runner job or Godot process was started.
**No donor parity claim is made.**

---

## 8. APPLIED — Y07-IMPL (COORD exclusive-ownership grant)

Status: **APPLIED**. Exactly the four one-line guard edits of §4 were applied at
current `game.gd:2315`, `:2319`, `:2323`, `:2327`. No explanatory comment was added —
the grant specified four one-line edits only. No Godot process, runner job, queue/lock/
counter mutation, donor access or other source edit occurred. Donor parity remains
**UNVERIFIED**.

### 8.1 Backup and hashes (OBSERVED)

- Backup created **before** the first edit: `inbox/backup/game.gd.bak-Y07` (`Test-Path`
  was `False` beforehand; no existing backup overwritten — `.bak-Y03`, `.bak-Y04`,
  `.bak-Y05`, `.bak-L01`, `.bak-B03*` all left intact).
- Pre-edit `game.gd` and backup SHA-256, **identical**:
  `248160354F1762E97FD73E2CCE7879D947681DA8F27286FBA06964DCE5847CF2`. This is exactly
  Y05 §9.1's post-edit hash, proving no intervening `game.gd` edit existed.
- Pre-edit size: **256,610 bytes**, mtime 2026-11-25 16:28:20.
- Post-edit `game.gd` SHA-256:
  `B9D07265B250BC458D4FEA703452D1CD7F6FCC7B45C4DD888C19F10FD212D890`.
- Post-edit size: **256,802 bytes** (+192 = four added `and int(tileblock[_t(…)]) !=
  _blk("test8")` fragments), mtime 2026-11-25 16:42:55.

### 8.2 Exact applied diff (verbatim `git diff --no-index -- inbox/backup/game.gd.bak-Y07 variant3d/scripts/game.gd`)

```diff
diff --git "a/inbox\\backup\\game.gd.bak-Y07" "b/variant3d\\scripts\\game.gd"
index c183794d..26191113 100644
--- "a/inbox\\backup\\game.gd.bak-Y07"
+++ "b/variant3d\\scripts\\game.gd"
@@ -2312,19 +2312,19 @@ func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGener
 		return
 	if bi1 - bi2 == 2:
 		var ni := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
+		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni
 	elif bi2 - bi1 == 2:
 		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
+		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni2
 	elif bi1 < bi2:
 		var ni3 := _tb_pick(best, bi1 + 1, brng)
-		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
+		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni3
 	else:
 		var ni4 := _tb_pick(best, bi2 + 1, brng)
-		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
+		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni4
```

`git diff --no-index --numstat` → **4 insertions, 4 deletions**, one hunk. No other
line changed relative to the backup.

### 8.3 Invariants verified after the edit (OBSERVED / DERIVED)

| Item | Status | Evidence |
|---|---|---|
| Exactly four lines changed | OBSERVED | §8.2 diff; numstat `4 4`; one hunk |
| All four `_tb_pick` calls kept, same order/arguments | OBSERVED | `:2314`, `:2318`, `:2322`, `:2326` verbatim in the diff context |
| `brng` stream byte-identical | DERIVED | no draw added/removed; `_blk()` is a pure dictionary lookup (Y03 §10.3, Y05 §9.4) |
| Y05 neutralisation intact | OBSERVED | `tex = _blk("test8")` still at `:2008` |
| Y03 P1 draws intact | OBSERVED | `_tb_pick(2,5)` `:1990`, `_tb_pick(1,4)` `:1994` |
| Y03 guarded write intact | OBSERVED | `if tex >= 0 and tex < tbl_names.size()` / `tileblock[i] = tex` at `:2009-2010` |
| L01 spot pass intact | OBSERVED | `_stamp_grass_spots(brng)` call `:2130`; function at `:2359` with `_tb_pick(7,1)` at `:2360`; `grass9` spot cells keep their exclusion |
| Y04 guards intact, **widened not weakened** | OBSERVED | same four sites; `ni >= 0` checks unchanged; both `grass9` and `test8` exclusions present |
| `_smooth_tilemap(brng,3)` intact | OBSERVED | call at `:2134`; driver `:2330-2337` |
| B03 `terrain=5` removal intact (collision-only gradient) | OBSERVED | grep finds exactly one `terrain[ii] = 5` at `:852` (stone stamp); `set_blocked_tile` still at `:1224` and `:1310` |
| Mine apron authority intact | OBSERVED | `:2049`, `:2088`, `:2121`, `:2143`; `_finalize_mine_tiles()` `:372` with `ground1` at `:382`/`:385`; `mine_mask` early-return `:2270-2271` unchanged |
| `terrain` / `height` / `blocked` | DERIVED | no write added or removed anywhere in the diff; collision/start protection/walkability byte-identical |
| `tileblock` contract | DERIVED | `PackedByteArray` size/type, uint8 ids, `ni >= 0` checks and `_blk()` validity unchanged; no out-of-atlas id |
| Static syntax (no Godot) | OBSERVED | comment/string-stripped bracket counts: `()` 3735/3735, `[]` 1350/1350, `{}` 257/257 — all balanced |
| Guardrails | DERIVED | no threshold lowered, no assertion deleted, no synthetic field; PORT APPROXIMATION, no donor parity |

### 8.4 Gate list for G04 (Y07 runs none — one Godot at a time)

1. `variant3d` selftest — expect **29/29**.
2. `variant3d` uitest — expect **17/17**.
3. `t_render_mode` — green.
4. `t_map_variety` — **5/5**, including `same_seed_byte_identical`. Do **not** use a
   frozen tileblock hash (B03 R1 / TRN-DATA precedent).
5. `assert_clean` — **CLEAN**; 2D `app/` gates untouched; `script_error_lines == 0`,
   `full_width_dark_rows == 0`, `non_black_fraction == 1.0`.
6. Matched-camera windowed seed-20261113 real-map + 64² P0 captures with unique ids;
   C04/G05 R1–R6 read: expect zero nested stepped bands around town/deposits, L01 spots
   still present, aprons intact, no new seams/black rows. C01 metrics (`tile_repeat`,
   `coherence`, `band_peak_deg`, row/col luma ratio) are **movement indicators only**,
   never thresholds or parity claims.
7. Decisive read-only probe (new unique id, `--dump-map`): decode `tileblock`, confirm
   non-`test8`/non-`grass9` transition ids collapse in the meadow and radial profiles
   at the historical ring centres lose their peaks; `terrain==5` stays at the
   stone-disc level; `blocked[]` byte-identical to the same-seed pre-fix dump.

G04 should record paths, timestamps, camera and result JSON fields verbatim.

### 8.5 Rollback

```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y07' -Destination 'variant3d\scripts\game.gd' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y07' -Algorithm SHA256
```

Both hashes must return to
`248160354F1762E97FD73E2CCE7879D947681DA8F27286FBA06964DCE5847CF2` (256,610 bytes:
the post-Y05 state with Y03 + L01 + Y04 + Y05 intact).
No other file is involved.

### 8.6 Epistemic status

No Godot process, runner job, queue mutation, donor file read/copy or other source edit
occurred in this implementation step. Whether the rings are actually gone in the
rendered frame is **UNVERIFIED** until G04's matched-camera capture and the dump probe
(§8.4 items 6–7). **No donor parity claim.**

---

*End of Y07 (analysis + Y07-IMPL). One report, four-line `game.gd` hunk, one backup;
no runner, no Godot, no donor-parity claim.*
