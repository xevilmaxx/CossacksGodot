---
id: TERRAIN-SWARM-P10-PROPOSAL
ticket: P10 (Wave P — PERFORMANCE)
status: PROPOSAL ONLY — READ-ONLY, NOT APPLIED
owner: P10 subagent
created: 2026-11-25
labels: [observed, derived, inferred, UNVERIFIED]
file_under_proposal: variant3d/scripts/anim3d.gd
---

# P10 — exact per-frame anim3d.gd allocation fix (proposal, not applied)

## 0. Scope / authority / sequencing

- **READ-ONLY ticket.** No code was edited. No Godot was launched. No runner job was
  submitted (Wave G standing rule at `WAVE_G_CHARTER.md:31,67-70`: only G04 runs Godot).
  This report is the only file written.
- **Do not apply this diff yet.** G04 is running gates against the current tree.
  COORD must grant exclusive ownership of `variant3d/scripts/anim3d.gd` after G04
  finishes (`WAVE_G_CHARTER.md:83,87`). P10's ticket names that file as its exclusive
  output; until COORD hands it over, the diff below is inert.
- **P03 report status: NOT LANDED.** The only P03 trace is the charter row
  (`WAVE_G_CHARTER.md:76`: `reports/P03_anim_cpu.md`); that file does not exist in
  `docs/terrain_swarm_2026-11-25/reports/`. Therefore the optimisation below is
  **reconstructed from the dispatch wording** ("cache pose lookups, remove
  per-entity per-frame Array/Dictionary/Transform3D allocations, skip
  off-screen/idle recomputation if safe") **plus file:line code evidence**, not
  quoted from P03. Every benefit estimate is **INFERRED / UNVERIFIED** as required by
  `CHARTER.md:57-58` and `WAVE_G_CHARTER.md:69-70`.

## 1. Backup instruction (run only after COORD grants ownership)

PowerShell (`CHARTER.md:69`: `;`, not `&&`):

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
Copy-Item -Path 'variant3d\scripts\anim3d.gd' -Destination 'inbox\backup\anim3d.gd.bak-P10'
(Get-FileHash 'variant3d\scripts\anim3d.gd' -Algorithm SHA256).Hash
```

- OBSERVED: no `inbox/backup/anim3d.gd.bak-P10` exists yet.
- OBSERVED: current `anim3d.gd` SHA-256 =
  `54FACBB3DF19E358E13D6C9BB3417A4A87579C1FBFAEC803FF25BA01C314C381`.
  Verify the backup hash equals this before applying. Naming follows the charter's
  `inbox/backup/<name>.bak-P1X` rule (`WAVE_G_CHARTER.md:87`) and the existing
  B01–B06 backup convention.

## 2. Evidence: the actual hot path (all OBSERVED, file:line)

`world3d_entities.gd:sync()` already memoises `pose_for()` once per
`(sid, action)` per sync (`:2032-2041`, `:2071-2081`). So the remaining anim3d
cost is **per distinct (sid, action) per donor frame**, not literally per unit.
Inside anim3d.gd the repeated allocations are:

| Site | Allocation | Observed code |
|---|---|---|
| `:934` | a fresh `Array` **every call** | `(AAF_ACTIONS[action] as Array).duplicate()` in `_action_range_for()` |
| `:930-931` | a fresh 5-element `Array` every shipped-skin call | compact branch of `_action_range_for()` |
| `:423-424` | two typed Arrays per skin sample | `mats: Array[PackedFloat32Array]`, `poss: Array[Vector3]` |
| `:430` → `:593-603` | one `PackedFloat32Array(9)` **per bone per sample** | `_qmat()` returns a new packed array (~20 bones for a peasant skin) |
| `:443-444`, `:458` | one output `PackedVector3Array` per sample | `out.resize(verts.size())`, `out[i] = Vector3(...)` (≈577 verts for peasant) |
| `:536-544`, `:548-556`, `:511-527`, `:167-208` | several fresh Dictionaries per call | `_morph_fields()` / `pose_for()` / `play()` result objects |

- **OBSERVED: there is no `Transform3D` in anim3d.gd** (grep: zero matches) and no
  camera/visibility input (`Camera`, `visible` — zero matches). The "Transform3D"
  item in the dispatch wording maps in this file to the per-bone packed float
  matrix from `_qmat()`; the off-screen item cannot be decided here.
- **OBSERVED: donor frame is coarse.** `DONOR_FPS = 30.0` (`:59`), `_frame_at()`
  (`:582-588`) returns `first + floor(fposmod(t*30, span))`. Consecutive syncs at
  render rates above 30 fps (or a frozen sim) resolve to the same frame ⇒ the same
  skin output. This is the safe skip condition.
- **OBSERVED: skinning is pure.** `skin_vertices()` (`:410-459`) depends only on
  `(skin, fr, ref_frame)`; `_morph_fields()` (`:534-556`) only on `(skin, frame)`;
  `_action_range_for()` (`:918-934`) only on `(sid, action)` after load. No RNG, no
  sim mutation, no clock state. This justifies the caches.

## 3. What the diff changes (INFERRED benefit; UNVERIFIED without a run)

1. `_range_cache` — resolve each `(sid, action)` row once; the AAF `.duplicate()`
   happens once instead of per frame. Callers only read `row[0..4]`
   (`:158-162`, `:504-508`).
2. `_morph_cache` (bounded FIFO, `MORPH_CACHE_MAX = 512`) — key `"sid|frame"`.
   A repeated donor frame (idle, one-frame clips such as `prepare0`/`unprepare0`
   at `:88-89`, or an off-screen unit re-synced at the same clock) is served with
   **zero** re-skinning. This is the in-file implementation of "skip
   idle/off-screen recomputation **if safe**": the cache is keyed only on inputs
   that actually determine the output, and is cleared whenever the skin set
   changes.
3. `_skin_scratch` — one flat `Array` of `bones*9` floats and one `Array` of
   `bones` positions per sid, reused on cache misses. A **flat Array**, not
   `PackedFloat32Array`, is used because packed arrays are copy-on-write when
   read back out of a container, which would silently re-allocate on every bone.
4. `_qmat_into()` — writes the same nine expressions in the same flattened order
   as `_qmat()` (`:594-603`), in place. Byte-identity of skinned verts is a hard
   requirement and is **UNVERIFIED** until a run/digest check (§6.3).
5. All result dictionaries and labels stay per-call and unchanged in content;
   no caller mutates a returned pose (`world3d_entities.gd:2077-2124`,
   `t_motion_capture.gd:234-244` — all `.get()` reads). The cached objects are
   shared **read-only**; a "treat pose as read-only" comment is added.

**INFERRED, UNVERIFIED:** expected win scales with unit count × render fps ÷ 30.
No FPS number is claimed; `P09_measurement.md`/G04 own measurement. The
world3d-side `pose_for()` call count (`donor_morph_pose_samples`,
`world3d_entities.gd:2282`) should stay unchanged — this diff does not touch that
file.

## 4. Exact unified diff (apply ONLY after ownership is granted)

```diff
--- a/variant3d/scripts/anim3d.gd
+++ b/variant3d/scripts/anim3d.gd
@@ -124,1 +124,19 @@
 var _shipped_error: String = ""
+
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
@@ -165,4 +183,4 @@
-	var morph := _morph_fields(skin, frame)
+	var morph := _morph_fields(skin, frame, sid)
 	var sample_frame: int = int(morph.get("sample_frame", frame))
 	var pose: Dictionary = {
 		"action": donor_action,
@@ -305,7 +323,8 @@
 	if norm.is_empty():
 		return false
 	if not _valid_skin(norm):
 		return false
 	_skins[key] = norm
+	_clear_frame_caches()
 	return true
 
@@ -318,4 +337,5 @@
 func unregister_skin(sid) -> void:
 	_skins.erase(str(sid))
+	_clear_frame_caches()
 
 
@@ -410,2 +430,8 @@
-func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVector3Array:
+# P10: public signature unchanged; sid="" keeps original per-call buffers for
+# tool/probe callers. The registered-skin hot path passes a sid so the impl
+# reuses scratch buffers instead of allocating per bone per frame.
+func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVector3Array:
+	return _skin_vertices_impl(skin, fr, ref_frame, "")
+
+func _skin_vertices_impl(skin: Dictionary, fr: int, ref_frame: int, sid: String) -> PackedVector3Array:
 	var empty := PackedVector3Array()
@@ -422,5 +448,16 @@
 	var anim: PackedFloat32Array = skin["anim"]
-	var mats: Array[PackedFloat32Array] = []
-	var poss: Array[Vector3] = []
-	mats.resize(bones)
-	poss.resize(bones)
+	# P10: reuse one flat float matrix buffer + one position buffer per sid.
+	# A flat Array is used (not PackedFloat32Array) because packed arrays are
+	# copy-on-write when read back from a container, which would re-allocate.
+	var mats: Array = []
+	var poss: Array = []
+	if sid != "" and _skin_scratch.has(sid):
+		var sc: Dictionary = _skin_scratch[sid]
+		mats = sc.get("mats", [])
+		poss = sc.get("poss", [])
+	if mats.size() != bones * 9:
+		mats.resize(bones * 9)
+	if poss.size() != bones:
+		poss.resize(bones)
+	if sid != "" and not _skin_scratch.has(sid):
+		_skin_scratch[sid] = {"mats": mats, "poss": poss}
@@ -427,4 +464,4 @@
 	for bi in range(bones):
 		var base := (bi * nf + frame) * 7
 		poss[bi] = Vector3(anim[base], anim[base + 1], anim[base + 2])
-		mats[bi] = _qmat(anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
+		_qmat_into(mats, bi * 9, anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
@@ -450,9 +487,9 @@
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
@@ -509,4 +546,4 @@
-	var morph := _morph_fields(skin, frame)
+	var morph := _morph_fields(skin, frame, sid)
 	var sample_frame: int = int(morph.get("sample_frame", frame))
 	var out: Dictionary = {
 		"ok": true,
@@ -533,3 +570,9 @@
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
@@ -545,12 +588,19 @@
 	var k: int = int(skin["k"])
 	var src_frame: int = _nearest_exported_frame(skin, frame) if bool(skin.get("compact", false)) else frame
-	var verts := skin_vertices(skin, src_frame)
+	var verts := _skin_vertices_impl(skin, src_frame, -1, sid) if sid != "" \
+			else skin_vertices(skin, src_frame)
-	return {
+	var morph := {
 		"pose_source": POSE_SOURCE_MORPH,
 		"skin_registered": true,
 		"vertex_count": verts.size(),
 		"verts": verts,
 		"frame_clamped": frame < 0 or frame >= k,
 		"sample_frame": src_frame,
 		"skin_math": str(skin.get("skin_math", SKIN_CITE)),
 	}
+	if sid != "":
+		_morph_cache[ck] = morph
+		_morph_keys.append(ck)
+		if _morph_keys.size() > MORPH_CACHE_MAX:
+			_morph_cache.erase(_morph_keys.pop_front())
+	return morph
@@ -601,3 +651,17 @@
 	var m21 := 2.0 * (y * z + x * w)
 	var m22 := 1.0 - 2.0 * (x * x + y * y)
 	return PackedFloat32Array([m00, m10, m20, m01, m11, m21, m02, m12, m22])
+
+# P10: in-place, byte-identical twin of _qmat's nine expressions and their
+# flattening order ([m00,m10,m20,m01,m11,m21,m02,m12,m22]). Writes into a flat
+# Array so no PackedFloat32Array is created per bone per frame.
+func _qmat_into(dst: Array, off: int, x: float, y: float, z: float, w: float) -> void:
+	dst[off] = 1.0 - 2.0 * (y * y + z * z)
+	dst[off + 1] = 2.0 * (x * y + z * w)
+	dst[off + 2] = 2.0 * (x * z - y * w)
+	dst[off + 3] = 2.0 * (x * y - z * w)
+	dst[off + 4] = 1.0 - 2.0 * (x * x + z * z)
+	dst[off + 5] = 2.0 * (y * z + x * w)
+	dst[off + 6] = 2.0 * (x * z + y * w)
+	dst[off + 7] = 2.0 * (y * z - x * w)
+	dst[off + 8] = 1.0 - 2.0 * (x * x + y * y)
@@ -885,4 +949,5 @@
 	if not _valid_skin(skin):
 		return false
 	_skins[sid] = skin
+	_clear_frame_caches()
 	return true
@@ -918,17 +983,24 @@
 func _action_range_for(sid: String, action: String) -> Array:
-	if _skins.has(sid):
-		var skin: Dictionary = _skins[sid] as Dictionary
-		if bool(skin.get("compact", false)):
-			var actions: Dictionary = skin.get("actions", {})
-			if actions.has(action):
-				var a: Dictionary = actions[action] as Dictionary
-				var donor_path := str(a.get("donor", ""))
-				var line := 0
-				var colon: int = donor_path.rfind(":")
-				if colon >= 0:
-					line = int(donor_path.substr(colon + 1))
-				return [int(a["first"]), int(a["last"]), line,
-					str(a.get("kind", "morph")), donor_path]
-	if not AAF_ACTIONS.has(action):
-		return []
-	return (AAF_ACTIONS[action] as Array).duplicate()
+	var ck := sid + "|" + action
+	if _range_cache.has(ck):
+		return _range_cache[ck] as Array
+	var out: Array = []
+	if _skins.has(sid):
+		var skin: Dictionary = _skins[sid] as Dictionary
+		if bool(skin.get("compact", false)):
+			var actions: Dictionary = skin.get("actions", {})
+			if actions.has(action):
+				var a: Dictionary = actions[action] as Dictionary
+				var donor_path := str(a.get("donor", ""))
+				var line := 0
+				var colon: int = donor_path.rfind(":")
+				if colon >= 0:
+					line = int(donor_path.substr(colon + 1))
+				out = [int(a["first"]), int(a["last"]), line,
+					str(a.get("kind", "morph")), donor_path]
+	if out.is_empty() and AAF_ACTIONS.has(action):
+		# P10: duplicate ONCE per (sid, action), not once per frame. Callers
+		# (play/pose_for) only read row[0..4]; the const table is never exposed.
+		out = (AAF_ACTIONS[action] as Array).duplicate()
+	_range_cache[ck] = out
+	return out
```

### 4.1 Diff notes / application checks

- Indentation is **tabs** throughout, matching the file.
- The `_qmat_into()` write order is `[m00, m10, m20, m01, m11, m21, m02, m12, m22]`,
  exactly `_qmat():594-603`. Do not "simplify" it to row-major.
- `skin_vertices()` keeps its public 3-arg signature; only its internals now go
  through `_skin_vertices_impl(..., "")`. No tool/probe caller changes.
- `_morph_fields()` gains a **private optional** 3rd arg (`sid := ""`); all
  existing external callers keep calling it with 2 args, so empty-skin
  timing-only behaviour is unchanged. The two internal call sites in `play()`
  (`:165`) and `pose_for()` (`:509`) are changed to
  `_morph_fields(skin, frame, sid)` in the main diff above (hunks
  `@@ -165,4 +183,4 @@` and `@@ -509,4 +546,4 @@`). Without those two one-line
  changes the caches would never be populated — they are mandatory parts of
  the patch, not optional tuning.
- Hunk headers are in ascending original-line order (`124, 165, 305, 318, 410,
  422, 427, 450, 509, 533, 545, 601, 885, 918`). New-line offsets are cumulative
  from the preceding hunks. The block was **structurally validated read-only**
  (every context/removed line matches the current file at its stated line;
  counts and cumulative new offsets are self-consistent). It was NOT applied or
  executed. Re-verify with `git diff --check` and by reading the file after
  applying.

## 5. Explicitly preserved (no hunk touches these)

- **Flat-root morph semantics**: `mats`/`poss`/root-delta code at `:427-459` and
  the `bake_sprites.py:118-143` citation are preserved; only storage changes.
  No parent matrix, no interpolation, no RNG, no invented frame index.
- **DONOR-SAMPLED warning text**: the literal lives in
  `variant3d/scripts/world3d_entities.gd:191` (`ANIM_STATUS =
  "DONOR-SAMPLED FLAT-ROOT MORPH — " + PORT_LABEL + ...`), a file P10 does not
  own. Unchanged. Inside anim3d.gd these exact strings are untouched:
  - `:63` `"PORT APPROXIMATION — NOT DONOR PARITY"`
  - `:66` `"BLOCKED: donor bone parent hierarchy unreadable (V7-2 §3.3.1 / Table B1); flat-root skin only"`
  - `:200` `"UNVERIFIED — flat-root donor skin, no bone hierarchy, visual A/B pending"`
  - `:202` `"UNVERIFIED — AAF entries carry no loop flag; all are 'morph' (peaukr.aaf:3-20)"`
- **All animation clip tables**: `AAF_ACTIONS` (`:71-90`, 18 rows), `ACTION_ALIAS`
  (`:94-96`), `DONOR_FPS` (`:59`), and each shipped skin's `actions`/`frames` are
  read-only inputs to the new caches — no value is changed.
- **Every test**: no test file is edited; no threshold, assertion, expected value
  or status label is weakened. Public API signatures of `play`, `pose_for`,
  `skin_vertices`, `action_info`, `skin_info`, `capabilities`,
  `shipped_skin_info`, `register_skin`, `unregister_skin`, `has_skin`,
  `parse_donor_oss`, `sample_frames`, `load_skin_from_donor` are unchanged.

## 6. Regression list — run by G04 ONLY (P10 runs nothing)

| Gate | Purpose | Expected |
|---|---|---|
| `variant3d` selftest (29/29) | no sim regression from anim module | 29/29 |
| uitest (17/17) | UI untouched | 17/17 |
| `t_render_mode` | world construction untouched | pass |
| `t_motion_capture.gd` | most direct `pose_for()` consumer (`:234-244`) | identical pose fields (`action`, `frame`, `donor`, `pose_source`, `visual`) |
| `t_entities3d.gd` | entity renderer/mesh batch | pass |
| `t_terrain_trees.gd` | calls `_entities.sync(0.0)` (`:813`) | pass |
| `t_mass_army.gd` | many units → cache hit path | pass, no new errors |
| `t_anim_metrics.gd` | data-only, unaffected | pass (schema unchanged) |
| `assert_clean` | no leaked nodes/errors | CLEAN |
| windowed P0 + real-map capture | visual honesty | DONOR-SAMPLED status text byte-identical; no new seams/z-fighting; `donor_morph_pose_samples` unchanged |

Additional **static** checks (no runner needed, can be done by G14-type audit):
1. `git diff --check` — whitespace/EOF.
2. grep: no new `duplicate()` inside `_action_range_for` hot return path beyond
   the once-per-key call; no `Array[PackedFloat32Array]`/`_qmat(` in the hot
   skinning loop.
3. **Byte-identity of skinned verts (UNVERIFIED)**: compare a stored digest of
   `skin_vertices(skin, fr)` before/after for several `(sid, fr)` pairs. Suggested
   as a follow-up atom; not added here because P10 must not edit tests.

## 7. Unknowns / open questions

- **UNVERIFIED**: any FPS/alloc-count improvement. No capture or profiler run was
  permitted; `P09_measurement.md` + G04 own measurement.
- **UNVERIFIED**: `_qmat_into` == `_qmat` at the bit level. Algebra is copied
  expression-for-expression, but Godot float behavior must be confirmed by §6.3.
- **UNVERIFIED**: shared read-only pose safety. All in-tree readers use `.get()`
  only (evidence in §3), but a future caller that mutates the returned Dictionary
  would poison the cache. If COORD prefers zero sharing risk, the conservative
  fallback is: keep `_morph_cache` but drop `_range_cache` sharing by returning
  `(AAF_ACTIONS[action] as Array).duplicate()` on every call — that forfeits one
  INFERRED win while keeping the dominant skinning win.
- **OUT OF SCOPE (INFERRED)**: true off-screen culling. anim3d.gd has no camera or
  visibility input (OBSERVED: zero matches). The frame-keyed cache removes
  recomputation for any re-synced unit at an unchanged donor frame, which covers
  idle and frozen/off-screen units *only when they share `(sid, action, frame)`*;
  explicit visibility gating belongs to `world3d_entities.gd`, owned by P11
  (`WAVE_G_CHARTER.md:84`). Do not expand P10's file scope.
- **UNKNOWN**: whether P03 (when it lands) names a different cache key or a
  different bound than `MORPH_CACHE_MAX = 512`. The bound is INFERRED from
  exported-frame counts (peasant exports 30 frames; ~54 roster sids), not from a
  measurement; reconcile with P03 before final integration.

*End of P10 proposal — nothing applied.*
