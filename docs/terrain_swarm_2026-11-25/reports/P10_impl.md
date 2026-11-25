---
id: TERRAIN-SWARM-P10-IMPL
ticket: "WAVE P / P10-IMPL — apply validated 14-hunk diff to anim3d.gd"
owner: P10 implementation subagent
created: 2026-11-25
status: IMPLEMENTED__PRECISION_REMEDIATED__STATIC_VALIDATED__GATES_DELEGATED_TO_G04
labels: [observed, derived, inferred, UNVERIFIED]
files_edited:
  - variant3d/scripts/anim3d.gd
files_created:
  - inbox/backup/anim3d.gd.bak-P10
  - inbox/backup/anim3d.gd.bak-P10-prec
  - docs/terrain_swarm_2026-11-25/reports/P10_impl.md
godot_jobs_run: 0
runner_jobs_submitted: 0
head_baseline: 032f2678833f623af4b0774d670e6b83764aee9c
committed_at: 3418d1e116ea163c87bbb692735249ebc13eff8b
backup_sha256: 54FACBB3DF19E358E13D6C9BB3417A4A87579C1FBFAEC803FF25BA01C314C381
new_file_sha256: 3C7FCD2D88778743685B5CC12FA6C9215655E0FE9BD07BD065D321060914D407
prec_backup_sha256: 4A229A24C37AD8AF20B9B68E54B52FEC1E87A2DB5BDB0B1F5F773F186C3922A6
parity_guard: "No Godot process was started and no runner job was submitted (WAVE_G_CHARTER.md:31,67-70). Every cost claim remains INFERRED/UNVERIFIED; no FPS, frame-time or donor-parity result is asserted. After the P10-prec remediation, a non-Godot static model shows 0 coefficient and 0 vertex byte differences; the Godot byte digest is still a mandatory G04 gate and remains UNVERIFIED until run."
---

# P10 — implementation report: `variant3d/scripts/anim3d.gd`

## 1. Scope / authority compliance

- **Exclusive file touched:** `variant3d/scripts/anim3d.gd` only (`WAVE_G_CHARTER.md:83`).
  No runner, no test, no shader, no other `.gd`, no config and no asset was edited.
- **No Godot was launched, no runner job submitted.** All gates in §7 are delegated to
  G04, the sole runner owner (`WAVE_G_CHARTER.md:31,67-70`).
- Inputs read before editing: `WAVE_G_CHARTER.md`, `docs/terrain_swarm_2026-11-25/CHARTER.md`,
  `reports/P03_anim_cpu.md`, `reports/P10_anim_fix_proposal.md`, `reports/L04_perf_integration.md`,
  and the full on-disk `anim3d.gd` (962 lines at HEAD).
- `git status --short` after the edit shows exactly one modified source file
  (` M variant3d/scripts/anim3d.gd`) plus the new untracked backup. No cross-touch.

## 2. Backup BEFORE edit — SHA verified against HEAD

Created with `shutil.copyfile` from the clean worktree file, **before the first edit**:

```
inbox/backup/anim3d.gd.bak-P10      35383 bytes
```

| Object | SHA-256 |
|---|---|
| `git show HEAD:variant3d/scripts/anim3d.gd` blob | `54FACBB3DF19E358E13D6C9BB3417A4A87579C1FBFAEC803FF25BA01C314C381` |
| worktree `anim3d.gd` **before** edit | `54FACBB3DF19E358E13D6C9BB3417A4A87579C1FBFAEC803FF25BA01C314C381` |
| backup `.bak-P10` (verified after copy) | `54FACBB3DF19E358E13D6C9BB3417A4A87579C1FBFAEC803FF25BA01C314C381` |

All three are identical (OBSERVED, computed with Python `hashlib.sha256` on the raw bytes);
`HEAD` = `032f2678833f623af4b0774d670e6b83764aee9c` and the file was clean at handover,
so the backup snapshots exactly the P10 baseline and no earlier landed fix is rolled back.
Final edited file SHA-256 = `4A229A24C37AD8AF20B9B68E54B52FEC1E87A2DB5BDB0B1F5F773F186C3922A6`.
Full-file rollback: replace `anim3d.gd` with `.bak-P10`.

**Second backup (COORD follow-up, precision remediation).** Created from the
post-P10 file with `shutil.copyfile` **before** the follow-up edit:

```
inbox/backup/anim3d.gd.bak-P10-prec   39123 bytes
```

| Object | SHA-256 |
|---|---|
| worktree `anim3d.gd` before follow-up | `4A229A24C37AD8AF20B9B68E54B52FEC1E87A2DB5BDB0B1F5F773F186C3922A6` |
| backup `.bak-P10-prec` (verified after copy) | `4A229A24C37AD8AF20B9B68E54B52FEC1E87A2DB5BDB0B1F5F773F186C3922A6` |

Both identical (OBSERVED). Final edited file SHA-256 after remediation =
`3C7FCD2D88778743685B5CC12FA6C9215655E0FE9BD07BD065D321060914D407`.
Rollback of **only** the remediation: replace `anim3d.gd` with `.bak-P10-prec`;
full P10 rollback: restore `.bak-P10`.

## 3. What was applied

The 14 logical hunks of `P10_anim_fix_proposal.md` §4 were applied **verbatim** (same
comments, same expression order, tab indentation, LF endings):

1. `_range_cache`, `_morph_cache`, `_morph_keys` (FIFO order), `_skin_scratch`,
   `MORPH_CACHE_MAX = 512`, and `_clear_frame_caches()` added after `_shipped_error`.
2. `play()` → `_morph_fields(skin, frame, sid)`.
3. `register_skin()` → `_clear_frame_caches()`.
4. `unregister_skin()` → `_clear_frame_caches()`.
5. `skin_vertices()` public 3-arg signature kept; body moved to
   `_skin_vertices_impl(..., sid)`; tool/probe callers get `sid=""` (fresh buffers).
6. Per-bone `Array[PackedFloat32Array]`/`Array[Vector3]` replaced by one flat float
   `Array` (`bones*9`) + one position `Array`, cached per `sid` in `_skin_scratch`.
7. Bone loop: `_qmat(...)` → `_qmat_into(mats, bi*9, ...)` (in place).
8. Vertex loop: `m[0..8]` → `mats[mo..mo+8]`.
9. `pose_for()` → `_morph_fields(skin, frame, sid)`.
10. `_morph_fields()` gains private optional `sid: String = ""`, builds
    `ck := sid + "|" + str(frame)`, returns cached Dictionary on hit.
11. On miss: store `morph` into `_morph_cache[ck]`, append `ck` to `_morph_keys`,
    FIFO-evict when `> MORPH_CACHE_MAX`, return `morph`. Empty skins are never cached.
12. `_qmat_into()` added: the same nine expressions, same flattened order
    `[m00,m10,m20,m01,m11,m21,m02,m12,m22]` as `_qmat():594-603`.
13. `_load_shipped_skin()` → `_clear_frame_caches()`.
14. `_action_range_for()` → `_range_cache` keyed `sid|action`; AAF `.duplicate()`
    happens once per key, not once per call.

**One additional defensive hunk (15)** was added to satisfy the ticket's explicitly
named fourth invalidation point (`_ensure_shipped_skins`): a
`_clear_frame_caches()` at the end of the shipped-skin load loop, matching
`P03_anim_cpu.md:234-238` §4-A. This is redundant with the `_load_shipped_skin()`
clear (hunk 13) but harmless (rare, first-load-only path) and makes all four
mandatory invalidation sites literal.

`git diff` (final, post-remediation) prints **16 hunks / +97 / -18 lines**: git
splits proposal hunks 6/7 into one hunk, and proposal hunks 11 and 14 into two each
because of context distance; 15 proposal hunks + splitting = 16. The precision
remediation (§6.1) modifies two of those hunks in place; it adds no new hunk and
touches no other region. No other change exists in the file.

### 3.1 Exact diff (verbatim, baseline `032f2678` → landed file)

The block below is the exact patch relative to the baseline HEAD `032f2678…`
(byte-identical to `.bak-P10`). COORD committed the landed file at
`3418d1e1 step` during this follow-up, so a live `git diff` against the
*current* HEAD is empty. The patch was reproduced from
`git diff 032f2678 3418d1e1 -- variant3d/scripts/anim3d.gd` and verified
byte-for-byte against that command (OBSERVED).

```diff
diff --git a/variant3d/scripts/anim3d.gd b/variant3d/scripts/anim3d.gd
index e25bba1e..0eef8f66 100644
--- a/variant3d/scripts/anim3d.gd
+++ b/variant3d/scripts/anim3d.gd
@@ -123,6 +123,24 @@ var _shipped_count: int = 0
 var _shipped_bytes: int = 0
 var _shipped_error: String = ""
 
+# P10 (INFERRED): per-frame caches. Keyed only by immutable inputs; cleared by
+# _clear_frame_caches() whenever _skins changes. Cached morph Dictionaries and
+# verts are shared READ-ONLY (world3d_entities.gd:2077-2124,
+# t_motion_capture.gd:234-244). No label, clip table or test is touched.
+var _range_cache: Dictionary = {}   # "sid|action" -> resolved AAF/shipped row
+var _morph_cache: Dictionary = {}   # "sid|frame"  -> _morph_fields() result
+var _morph_keys: Array[String] = [] # FIFO eviction order for _morph_cache
+var _skin_scratch: Dictionary = {}  # sid -> {"mats":Array,"poss":Array}
+const MORPH_CACHE_MAX: int = 512    # INFERRED cap; speed benefit UNVERIFIED
+
+# P10: invalidate every frame cache when the skin set changes. Called only on
+# register/unregister/shipped-load (rare), never from the per-frame path.
+func _clear_frame_caches() -> void:
+	_range_cache.clear()
+	_morph_cache.clear()
+	_morph_keys.clear()
+	_skin_scratch.clear()
+
 
 # ---------------------------------------------------------------------------
 # EXACT CONTRACT API (V73_ATOMIC_CONTRACT.md:17 — signatures unchanged)
@@ -162,7 +180,7 @@ func play(e, action, t):
 	var donor_cite: String = str(row[4]) if row.size() >= 5 else "data/animations/aaf/peaukr.aaf:%d" % line
 	var frame: int = _frame_at(first, last, t)
 
-	var morph := _morph_fields(skin, frame)
+	var morph := _morph_fields(skin, frame, sid)
 	var sample_frame: int = int(morph.get("sample_frame", frame))
 	var pose: Dictionary = {
 		"action": donor_action,
@@ -307,6 +325,7 @@ func register_skin(sid, skin: Dictionary) -> bool:
 	if not _valid_skin(norm):
 		return false
 	_skins[key] = norm
+	_clear_frame_caches()
 	return true
 
 
@@ -317,6 +336,7 @@ func has_skin(sid) -> bool:
 
 func unregister_skin(sid) -> void:
 	_skins.erase(str(sid))
+	_clear_frame_caches()
 
 
 func skin_info(sid) -> Dictionary:
@@ -407,7 +427,13 @@ func capabilities() -> Dictionary:
 # bind vertex i == OBJ vertex i. If ref_frame >= 0, subtract the bone-0 root
 # translation delta the same way bake_sprites.bake_unit does (:310-342); the
 # default (-1) leaves the raw skin output untouched.
+# P10: public signature unchanged; sid="" keeps original per-call buffers for
+# tool/probe callers. The registered-skin hot path passes a sid so the impl
+# reuses scratch buffers instead of allocating per bone per frame.
 func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVector3Array:
+	return _skin_vertices_impl(skin, fr, ref_frame, "")
+
+func _skin_vertices_impl(skin: Dictionary, fr: int, ref_frame: int, sid: String) -> PackedVector3Array:
 	var empty := PackedVector3Array()
 	if skin.is_empty() or not _valid_skin(skin):
 		last_error = "skin_vertices: invalid skin"
@@ -420,14 +446,27 @@ func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVect
 	var nf: int = int(skin.get("frame_count", k))
 	var frame: int = _nearest_local(skin, fr) if compact else clampi(fr, 0, k - 1)
 	var anim: PackedFloat32Array = skin["anim"]
-	var mats: Array[PackedFloat32Array] = []
-	var poss: Array[Vector3] = []
-	mats.resize(bones)
-	poss.resize(bones)
+	# P10: reuse one flat matrix buffer + one position buffer per sid.
+	# P10-prec: the matrix buffer MUST be a PackedFloat32Array so each
+	# coefficient is rounded to float32 exactly as _qmat() did. Reading it
+	# back from the scratch Dictionary may copy-on-write, so store it back
+	# once per sample (one packed-array copy, not B per-bone allocations).
+	var mats: PackedFloat32Array = PackedFloat32Array()
+	var poss: Array = []
+	if sid != "" and _skin_scratch.has(sid):
+		var sc: Dictionary = _skin_scratch[sid]
+		mats = sc.get("mats", PackedFloat32Array())
+		poss = sc.get("poss", [])
+	if mats.size() != bones * 9:
+		mats.resize(bones * 9)
+	if poss.size() != bones:
+		poss.resize(bones)
 	for bi in range(bones):
 		var base := (bi * nf + frame) * 7
 		poss[bi] = Vector3(anim[base], anim[base + 1], anim[base + 2])
-		mats[bi] = _qmat(anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
+		_qmat_into(mats, bi * 9, anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
+	if sid != "":
+		_skin_scratch[sid] = {"mats": mats, "poss": poss}
 	var rx := 0.0
 	var ry := 0.0
 	if ref_frame >= 0:
@@ -450,11 +489,11 @@ func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVect
 		for j in range(w_off[i], w_off[i + 1]):
 			var bi: int = w_bone[j]
 			var w: float = w_val[j]
-			var m: PackedFloat32Array = mats[bi]
+			var mo: int = bi * 9
 			var p: Vector3 = poss[bi]
-			sx += w * (m[0] * vv.x + m[1] * vv.y + m[2] * vv.z + p.x)
-			sy += w * (m[3] * vv.x + m[4] * vv.y + m[5] * vv.z + p.y)
-			sz += w * (m[6] * vv.x + m[7] * vv.y + m[8] * vv.z + p.z)
+			sx += w * (mats[mo] * vv.x + mats[mo + 1] * vv.y + mats[mo + 2] * vv.z + p.x)
+			sy += w * (mats[mo + 3] * vv.x + mats[mo + 4] * vv.y + mats[mo + 5] * vv.z + p.y)
+			sz += w * (mats[mo + 6] * vv.x + mats[mo + 7] * vv.y + mats[mo + 8] * vv.z + p.z)
 		out[i] = Vector3(sx - rx, sy - ry, sz)
 	return out
 
@@ -506,7 +545,7 @@ func pose_for(e, action, t) -> Dictionary:
 	var line: int = int(row[2])
 	var frame: int = _frame_at(first, last, t)
 	var donor_cite: String = str(row[4]) if row.size() >= 5 else "data/animations/aaf/peaukr.aaf:%d" % line
-	var morph := _morph_fields(skin, frame)
+	var morph := _morph_fields(skin, frame, sid)
 	var sample_frame: int = int(morph.get("sample_frame", frame))
 	var out: Dictionary = {
 		"ok": true,
@@ -531,7 +570,13 @@ func pose_for(e, action, t) -> Dictionary:
 
 
 # Produce the morph fields once, shared by play() and pose_for().
-func _morph_fields(skin: Dictionary, frame: int) -> Dictionary:
+# P10: morph output is a pure function of (skin, frame). Repeated frames are
+# served from cache with zero skinning (idle / single-frame clips / off-screen
+# units re-synced at the same donor clock).
+func _morph_fields(skin: Dictionary, frame: int, sid: String = "") -> Dictionary:
+	var ck := sid + "|" + str(frame)
+	if sid != "" and _morph_cache.has(ck):
+		return _morph_cache[ck] as Dictionary
 	if skin.is_empty():
 		return {
 			"pose_source": POSE_SOURCE_TIMING,
@@ -544,8 +589,9 @@ func _morph_fields(skin: Dictionary, frame: int) -> Dictionary:
 		}
 	var k: int = int(skin["k"])
 	var src_frame: int = _nearest_exported_frame(skin, frame) if bool(skin.get("compact", false)) else frame
-	var verts := skin_vertices(skin, src_frame)
-	return {
+	var verts := _skin_vertices_impl(skin, src_frame, -1, sid) if sid != "" \
+			else skin_vertices(skin, src_frame)
+	var morph := {
 		"pose_source": POSE_SOURCE_MORPH,
 		"skin_registered": true,
 		"vertex_count": verts.size(),
@@ -554,6 +600,12 @@ func _morph_fields(skin: Dictionary, frame: int) -> Dictionary:
 		"sample_frame": src_frame,
 		"skin_math": str(skin.get("skin_math", SKIN_CITE)),
 	}
+	if sid != "":
+		_morph_cache[ck] = morph
+		_morph_keys.append(ck)
+		if _morph_keys.size() > MORPH_CACHE_MAX:
+			_morph_cache.erase(_morph_keys.pop_front())
+	return morph
 
 
 # ---------------------------------------------------------------------------
@@ -602,6 +654,21 @@ func _qmat(x: float, y: float, z: float, w: float) -> PackedFloat32Array:
 	var m22 := 1.0 - 2.0 * (x * x + y * y)
 	return PackedFloat32Array([m00, m10, m20, m01, m11, m21, m02, m12, m22])
 
+# P10: byte-identical twin of _qmat's nine expressions and their flattening
+# order ([m00,m10,m20,m01,m11,m21,m02,m12,m22]). dst is a PackedFloat32Array,
+# so each assignment rounds to float32 exactly like _qmat()'s constructor;
+# the flat buffer is reused per sid (one COW copy per sample, not B arrays).
+func _qmat_into(dst: PackedFloat32Array, off: int, x: float, y: float, z: float, w: float) -> void:
+	dst[off] = 1.0 - 2.0 * (y * y + z * z)
+	dst[off + 1] = 2.0 * (x * y + z * w)
+	dst[off + 2] = 2.0 * (x * z - y * w)
+	dst[off + 3] = 2.0 * (x * y - z * w)
+	dst[off + 4] = 1.0 - 2.0 * (x * x + z * z)
+	dst[off + 5] = 2.0 * (y * z + x * w)
+	dst[off + 6] = 2.0 * (x * z + y * w)
+	dst[off + 7] = 2.0 * (y * z - x * w)
+	dst[off + 8] = 1.0 - 2.0 * (x * x + y * y)
+
 
 # Python round() is half-to-even for nonnegative frame indices.
 func _py_round_i(x: float) -> int:
@@ -763,6 +830,10 @@ func _ensure_shipped_skins() -> void:
 			_shipped_bytes += int((item as Dictionary).get("bytes", 0))
 		else:
 			_shipped_error = "last failure " + file_name + ": " + last_error
+	# P10 (defensive, P03 §4-A): the shipped-skin loop replaced/extended the
+	# skin set on this first load. _load_shipped_skin() already clears per skin;
+	# clear once more here so no cache entry can outlive the load.
+	_clear_frame_caches()
 
 
 # Load one c3_skin_v1 asset and register it under its real roster sid. Uses the
@@ -885,6 +956,7 @@ func _load_shipped_skin(path: String) -> bool:
 	if not _valid_skin(skin):
 		return false
 	_skins[sid] = skin
+	_clear_frame_caches()
 	return true
 
 
@@ -916,6 +988,10 @@ func _nearest_exported_frame(skin: Dictionary, donor_frame: int) -> int:
 # donor AAF ranges (converter read them from data/animations/aaf/<base>.aaf);
 # unregistered/legacy skins keep the V7-18 peaukr table unchanged.
 func _action_range_for(sid: String, action: String) -> Array:
+	var ck := sid + "|" + action
+	if _range_cache.has(ck):
+		return _range_cache[ck] as Array
+	var out: Array = []
 	if _skins.has(sid):
 		var skin: Dictionary = _skins[sid] as Dictionary
 		if bool(skin.get("compact", false)):
@@ -927,11 +1003,14 @@ func _action_range_for(sid: String, action: String) -> Array:
 				var colon: int = donor_path.rfind(":")
 				if colon >= 0:
 					line = int(donor_path.substr(colon + 1))
-				return [int(a["first"]), int(a["last"]), line,
+				out = [int(a["first"]), int(a["last"]), line,
 					str(a.get("kind", "morph")), donor_path]
-	if not AAF_ACTIONS.has(action):
-		return []
-	return (AAF_ACTIONS[action] as Array).duplicate()
+	if out.is_empty() and AAF_ACTIONS.has(action):
+		# P10: duplicate ONCE per (sid, action), not once per frame. Callers
+		# (play/pose_for) only read row[0..4]; the const table is never exposed.
+		out = (AAF_ACTIONS[action] as Array).duplicate()
+	_range_cache[ck] = out
+	return out
 
 
 func _unknown(requested: String, aliased: bool) -> Dictionary:
```

## 4. Static hunk validation (all performed, no runner)

| Check | Result |
|---|---|
| `git diff --check -- variant3d/scripts/anim3d.gd` | exit **0**, no stdout; stderr only the benign `LF will be replaced by CRLF next time Git touches it` warning (file is LF, unchanged convention) |
| Hunk count / size | 16 git hunks, **+97 / -18** lines; 962 → 1041 lines |
| Proposal hunk order | applied in ascending original-line order; every context/removed line matched the baseline at its stated line |
| Tab-only indentation | **0** lines start with a space (was 0 before) |
| LF endings | CRLF count 0 before / 0 after — unchanged |
| Braces | 42/42 before → 47/47 after (balanced) |
| Parens imbalance | 573/574 before → 622/623 after (same pre-existing one-paren string artefact; no new imbalance) |
| `Array[PackedFloat32Array]` occurrences | 1 → **0** (per-bone typed array removed) |
| `mats[bi] = _qmat(` occurrences | 1 → **0** |
| `_qmat(` call sites in code | **0** (the 2 text matches are the definition + the header comment) |
| `_qmat_into(` occurrences | 2 = 1 definition + 1 bone-loop call; signature now `dst: PackedFloat32Array` |
| `MORPH_CACHE_MAX` / FIFO | `const ... = 512` present; `_morph_keys.pop_front()` present; keys `sid + "|" + str(frame)` and `sid + "|" + action` present |
| `_clear_frame_caches()` call sites | **4** real calls: `register_skin`, `unregister_skin`, `_ensure_shipped_skins`, `_load_shipped_skin` (+1 definition, +1 comment) |

## 5. Contracts preserved (OBSERVED, byte-level counts old/new)

| Contract | old/new |
|---|---|
| `PORT_LABEL` = `"PORT APPROXIMATION — NOT DONOR PARITY"` | 2/2 |
| `BLOCKED_RIG` full `BLOCKED: donor bone parent hierarchy ...` string | 1/1 |
| `DONOR_FPS = 30.0` | 1/1 |
| `"UNVERIFIED — flat-root donor skin, no bone hierarchy, visual A/B pending"` | 1/1 |
| `"UNVERIFIED — AAF entries carry no loop flag; all are 'morph' (peaukr.aaf:3-20)"` | 1/1 |
| `AAF_ACTIONS` whole block | **byte-identical**, 18 `morph` rows |
| `ACTION_ALIAS` whole block | **byte-identical** |
| `POSE_KEY`, `SKIN_INDEX_PATH`, `POSE_SOURCE_MORPH`, `POSE_SOURCE_TIMING` | 1/1, 1/1, 2/2, 2/2 |

`DONOR-SAMPLED FLAT-ROOT MORPH — ` lives in `world3d_entities.gd:191` (not P10-owned) and
was not touched.

**All public signatures unchanged** (old/new = 1/1 for each): `bind`, `play`,
`parse_donor_oss`, `register_skin`, `has_skin`, `unregister_skin`, `skin_info`,
`load_skin_from_donor`, `shipped_skin_info`, `capabilities`, `skin_vertices` (3 args,
with default), `sample_frames`, `pose_for`, `action_info`, `_frame_at`, `_qmat`.
`_morph_fields` gains only a private optional 3rd arg (`sid := ""`), so external
2-arg callers keep the original timing-only behaviour.

**Flat-root morph math preserved:** `mats`/`poss`/root-delta code still applies every
bone track directly to the bind vertex; no parent matrix, no interpolation, no RNG,
no invented frame index, no new donor constant. Cache keys depend only on inputs that
determine the output (`sid`, `frame`, `action`), and all four skin-set mutations clear
every cache. No test file, threshold or status label was weakened.

## 6. Byte-identity on cache miss — precision remediation applied (G04 digest still mandatory)

### 6.1 The risk found in the first implementation

The original proposal marks `_qmat_into` bit-identity **UNVERIFIED**
(`P10_anim_fix_proposal.md:94-95,383-385`; `L04_perf_integration.md:101,325-326`).
A static, **non-Godot** model of the first implementation (Python `float64` scalar math
+ `struct` float32 packing to emulate `PackedFloat32Array` vs plain `Array`, then
float32 rounding at the `Vector3` write) showed 176,703 of 600,000 weighted vertex
components differing by 1 ULP (max |Δ| = 4.768e-07 m, 29.45 %). Cause: `_qmat()`
stored the nine coefficients in a `PackedFloat32Array` (rounds each to float32) while
the first `_qmat_into()` wrote the same expressions into a plain `Array` (keeps
float64). This was a **storage-precision difference, not an algebra error**.

### 6.2 COORD-authorised remediation (P10-prec) — applied

Per the follow-up directive, the scratch matrix buffer is now a
`PackedFloat32Array`, written in place by `_qmat_into(dst: PackedFloat32Array, ...)`
and **stored back** into `_skin_scratch[sid]` once per sample after the bone loop:

```gdscript
var mats: PackedFloat32Array = PackedFloat32Array()
...
if sid != "" and _skin_scratch.has(sid):
    var sc: Dictionary = _skin_scratch[sid]
    mats = sc.get("mats", PackedFloat32Array())
...
for bi in range(bones):
    ...
    _qmat_into(mats, bi * 9, anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
if sid != "":
    _skin_scratch[sid] = {"mats": mats, "poss": poss}
```

Reading a packed array back out of the scratch Dictionary may invoke
copy-on-write, so the store-back is what keeps the reused buffer authoritative.
This costs **one** `bones*9`-float packed-array copy per sample (≈180 floats for a
peasant skin) instead of the original **B = 20** separate `PackedFloat32Array(9)`
allocations — still a large allocation reduction, and now with the correct rounding.

### 6.3 Static byte-identity argument (NOT a Godot run)

| Property | Original `_qmat()` | Remediated `_qmat_into()` | Equal? |
|---|---|---|---|
| Nine expressions | `m00..m22` at `_qmat():594-602` | copied verbatim, same order | YES |
| Flattening order | `[m00,m10,m20,m01,m11,m21,m02,m12,m22]` | `dst[off+0..8]` in exactly that order | YES |
| Coefficient storage | `PackedFloat32Array([...])` → each value rounded to float32 | index assignment into `PackedFloat32Array` → each value rounded to float32 | YES |
| Scalar arithmetic | Python-equivalent `float64` intermediates, then float32 store | identical (only the container changed) | YES |
| Vertex accumulation | `m[0..8]` read back as float32-promoted-to-float64 | `mats[mo..mo+8]` read back identically | YES |

Static model rerun with the remediated container: **1,800,000 coefficients → 0 byte
differences** and **600,000 weighted vertex components → 0 byte differences**
(`struct.pack('<f', ...)` comparison). The previous 29.45 % / 1-ULP discrepancy is
eliminated by construction because both paths now round the same nine float64
expressions into float32 before any vertex arithmetic.

**Verdict:** byte identity is now supported by an expression-for-expression and
storage-for-storage static argument, but remains **UNVERIFIED in Godot** until G04
runs the digest in §7 item 10. If that digest still fails, the remaining suspects
are Godot-specific Variant/coercion details, not the algebra or the container type.

## 7. G04 gate list — delegated, NOT run by P10

P10 ran **zero** Godot processes and submitted **zero** runner jobs. The following
gates are the handoff acceptance list; each must be run by G04 only:

| # | Gate | Expected | Status |
|---|---|---|---|
| 1 | variant3d selftest | **29/29**, `SCRIPT ERROR=0` | PENDING G04 |
| 2 | uitest | **17/17** — NOTE `L04_perf_integration.md:62-70,316`: the on-disk 17/17 is **stale**; a fresh run (or explicit COORD waiver) is required and is not P10's to decide | PENDING G04 / COORD |
| 3 | `t_render_mode` | PASS, `seam_missing=false`, 10/10 | PENDING G04 |
| 4 | `t_motion_capture` | identical pose fields `action`, `frame`, `donor`, `pose_source`, `visual` (`:234-244`) — most direct `pose_for()` consumer | PENDING G04 |
| 5 | `t_entities3d` | pass (mesh/batch unaffected) | PENDING G04 |
| 6 | `t_mass_army` | pass, no new errors (exercises cache-hit path with many units) | PENDING G04 |
| 7 | `t_anim_metrics` | pass (schema unchanged) | PENDING G04 |
| 8 | `assert_clean` | **CLEAN**, no leaked nodes/errors | PENDING G04 |
| 9 | `t_render_mode` (repeat after the full set) | PASS / `seam_missing=false` | PENDING G04 |
| 10 | **verts byte-identity digest check** | digest of `skin_vertices(skin, fr)` on forced cache miss for several `(sid, fr)` pairs equal to `.bak-P10` baseline — see §6.3 static argument | PENDING G04 |
| 11 | windowed P0 + real-map capture | DONOR-SAMPLED status text byte-identical; `donor_morph_pose_samples` unchanged; no new seams/dark rows; `SCRIPT ERROR=0` | PENDING G04 |

Rollback for any failure: restore `inbox/backup/anim3d.gd.bak-P10` in full (or
`.bak-P10-prec` to drop only the precision remediation); do **not** hand-patch hunks to
force a gate green (`L04_perf_integration.md:302-305`). Note the byte digests must be
computed against the **original baseline** `.bak-P10`, not the post-P10 backup.

## 8. UNVERIFIED / open register

1. No FPS, frame time, allocation count or per-stage timing was measured (ticket rule).
   The ~50 % idle-frame cache-hit rate and the ≈1.7–2.4 ms/frame extrapolation are
   **INFERRED from P03** and remain **UNVERIFIED** for this tree/machine.
2. `_qmat_into` byte-identity has a **static proof by identical expressions + float32
   storage** (§6.3), but only a Godot digest can confirm it (§7 item 10).
3. Shared read-only pose safety: all in-tree readers use `.get()` only
   (`world3d_entities.gd:2077-2124`, `t_motion_capture.gd:234-244`); a future caller that
   mutates a cached pose or the returned `verts` would poison the cache. No `duplicate()`
   was added on return, per the proposal's immutability contract.
4. Donor parity stays **UNVERIFIED**; flat-root morph remains
   `PORT APPROXIMATION — NOT DONOR PARITY`. No donor GPU A/B frame exists.
5. `play()` is still unreferenced in-tree; its cache path is covered but unexercised by
   the per-frame gates.
6. The defensive `_ensure_shipped_skins` clear (§3, hunk 15) is a ticket-mandated
   addition beyond the 14 proposal hunks; it is behaviour-neutral because the shipped
   load already clears caches per skin.
7. The P10-prec store-back makes `_skin_scratch` hold a packed-array snapshot that is
   replaced each sample; Godot's exact COW semantics for that Dictionary read are
   UNVERIFIED, but copying the buffer once per sample (rather than relying on in-place
   mutation surviving the read) is correct under either semantics.

## 9. Bottom line

P10's validated diff is **landed**, backed up and **statically clean**: caches are keyed
only on immutable inputs, all four mandatory invalidation points are present, the
per-bone `PackedFloat32Array` churn is gone from the hot path, and every label, clip
table, signature and test is untouched. Performance benefit remains **INFERRED**
until G04 measures. The precision risk is **remediated** (§6): both matrix paths now
use the same nine expressions and the same float32 container, and a static model
reports 0 byte differences. The digest remains a mandatory G04 gate before the MED
tier is accepted.

*End of P10 implementation report — P10 ran no Godot and submitted no runner job.*
