---
id: WAVE-N-N04-IMPL
ticket: "N04-IMPL — apply N04's validated 6-hunk nation fix, re-derived against the post-M03/post-P10 tree"
owner: N04 implementation subagent (EXCLUSIVE owner of world3d_entities.gd / anim3d.gd / data.gd for this tranche)
created: 2026-11-25
status: LANDED__NO_GODOT__NO_RUNNER__DISJOINT_FROM_F2_03
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md + WAVE_G_CHARTER.md read first"
prereads: [WAVE_G_CHARTER.md, CHARTER.md, N01_nation_building_audit.md, N02_donor_nation_objects.md, N03_peasant_forms.md, N04_nation_fix.md, N05_nation_qa.md, N06_nation_conversion.md, N07_all_nations_assets.md, M03_impl.md, P10_impl.md]
c01_asset_impl_status: "NOT LANDED at authoring time — no C01_asset_impl.md in reports/; new nation OBJ/PNG/skin/manifest assets verified directly on disk instead"
parity_guard: "No donor GPU A/B frame exists. Every nation label stays PORT APPROXIMATION — NOT DONOR PARITY with visual UNVERIFIED. Internal mesh/sid identity is a static derivation only; no rendered pixels were captured or inspected."
outputs: [variant3d/scripts/world3d_entities.gd, docs/terrain_swarm_2026-11-25/reports/N04_impl.md, inbox/backup/world3d_entities.gd.bak-N04, inbox/backup/anim3d.gd.bak-N04, inbox/backup/data.gd.bak-N04]
godot_runs: 0
runner_jobs: 0
tests_touched: 0
code_files_edited: [variant3d/scripts/world3d_entities.gd]
---

# N04-IMPL — nation-resolved sid, presentation-only peasant map, honest BLOCKED stage/ghost label

## 0. Verdict (OBSERVED / DERIVED)

Applied **six hunks, one file** (`variant3d/scripts/world3d_entities.gd`) to the exact
post-M03/post-P10 worktree: backup SHA-256
`DB20C179C1F0A289792652BC85C39215B7BAA1FBE1E9CA929F576C8FE2094EDC` —
the M03-reported post-edit SHA. `anim3d.gd` (P10 caches) and `data.gd` were **backed up
but never edited** (post hashes equal backup hashes, §3). No Godot process, no runner
job, no capture, no test/threshold/fixture change.

**Concurrent-land notice (OBSERVED):** after N04 landed, the FOLD-06 agent edited the
*same* file (asset-bucket path routing, `AssetPaths` preload, `ROTOR_TEX_IMPORT_PATH`
rewrite). Those edits are **not N04's**; N04 did not cause, revert or modify them. The
live file is N04 + FOLD-06. Section §3a isolates the six N04 hunks from the final tree
by reverse-applying this report's patch: it still applies cleanly and yields exactly
six hunks, proving N04's bytes survived the concurrent edit.

- **(a) genuine bug fixed:** the nation-resolved mesh sid is persisted on `_slot` in
  `_acquire()` (the *single* write point, so it also survives the `_release` →
  `_acquire` morph frame change), and `sync()` uses it for `has_skin`, `pose_for`,
  `_mesh_info`, `_morph_mesh` and the batch key. `pose_for()` receives the sid String,
  which P10's `_sid_of()` accepts (`anim3d.gd:685-690`). The sim entity's `sid` is never
  written.
- **(b) presentation-only peasant map:** donor-derived `NATION_PEASANT_SIDS` is appended
  as a candidate only for base sid `peasant`, and is used **only after the existing
  disk probe** (`_nation_mesh_on_disk()`). `data.gd` is untouched: adding
  `NATION_UNITS.rus.peasant` would be silently rejected by `resolve_sid()`'s UNITS trap
  (`data.gd:1565-1568`; N06 §4.3 / N07 §6.4). Sim stats/training/AI stay on `peasant`.
- **(c) smallest explicit BLOCKED label:** one new constant,
  `NATION_STAGE_GHOST_BLOCKED_STATUS`, appended to building `nation_mesh_label` only
  when the nation stage stem is absent on disk. All 15 new nation hall OBJs are on disk
  (`ruscen`, `bavcen`, `polcen`, `swecen`, …) but none has `<nat><sid>1.obj`, so the
  finished hall can be exact while construction/ghost art stays nation-blind: the
  label says so explicitly, with no fabricated mesh and no parity claim. The original
  N04 hall-specific `NATION_HALL_BLOCKED_STATUS` is deliberately **not** added — its
  premise (no `ruscen.obj`) is now false.

**Re-derivation note (DERIVED):** N04's patch was validated against a tree where the
nation art was absent. The C01ASSET tranche has since landed 299 manifest entries /
15 new donor-derived OBJ+MTL+PNG triples plus `skin/*.json` entries. Hunk 4 is
therefore re-derived: instead of N04's `add_unit()` write (which `_acquire()` would
overwrite on the next donor frame), the sid is written where the slot is created.
Hunks 1/2/3 keep N04's intent but are disk-gated for the new asset reality.

---

## 1. Exact diff applied

`git -c core.autocrlf=false diff --no-index -- inbox/backup/world3d_entities.gd.bak-N04 variant3d/scripts/world3d_entities.gd`
(6 hunks, **+49 net lines**; 51 added / 2 removed source lines, i.e. 52/3 if the
`+++`/`---` headers are counted; `git diff --check` on the owned file exits 0).
`+` line numbers below are post-edit
final-file offsets.

```diff
diff --git a/inbox/backup/world3d_entities.gd.bak-N04 b/variant3d/scripts/world3d_entities.gd
index 390fe934..73c76acf 100644
--- a/inbox/backup/world3d_entities.gd.bak-N04
+++ b/variant3d/scripts/world3d_entities.gd
@@ -215,6 +215,27 @@ const NATION_MESH_ROLE_SUB_STATUS: String = PORT_LABEL + " — generic donor rol
 const NATION_ROLE_SUB_SIDS: Array[String] = ["musketeer", "hussar"]
 const NATION_MESH_BLOCKED_EVIDENCE: String = "BLOCKED (NATION_DONOR_01 G7-G10/C6): 0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems); manifest generic peasant->peaukr.dds, 8 core buildings->ukr*.osm/ukr*.dds, 0 rus-keyed and 0 bav-keyed textures; Bavarian musketeer18bav/grenadierbav and Ukrainian chaika are absent from manifest+obj. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED."
 
+# WAVE-N/N04 (c): donor's eight nation peasant bases
+# (country.script:2655-2662,2915-2922; N02 B1; N03 §1). PRESENTATION ONLY:
+# the sim sid stays "peasant"; a candidate is used only when its OBJ/GLB is
+# on disk (_nation_mesh_on_disk), never fabricated. Sharing is donor-correct
+# (bav/pru/sax/swi/aus -> peaaus, pol/hun -> peapol, ...).
+const NATION_PEASANT_SIDS: Dictionary = {
+	"aus": "peaaus", "bav": "peaaus", "pru": "peaaus", "sax": "peaaus", "swi": "peaaus",
+	"eng": "peaeng", "fra": "peaeng", "swe": "peaeng", "den": "peaeng", "net": "peaeng",
+	"pol": "peapol", "hun": "peapol",
+	"rus": "pearus",
+	"spa": "peaspa", "por": "peaspa", "pie": "peaspa", "ven": "peaspa",
+	"tur": "peatur", "alg": "peatur",
+	"ukr": "peaukr",
+	"sco": "peasco",
+}
+# WAVE-N/N04 (c): smallest explicit label for the remaining nation-art gap.
+# Finished hall OBJs exist for rus/bav/pol/swe, but the donor build-stage and
+# ghost meshes (<nat><sid>1..4 / <nat><sid>a) are NOT converted; the base
+# stage/ghost art stays nation-blind. No parity claim; visual UNVERIFIED.
+const NATION_STAGE_GHOST_BLOCKED_STATUS: String = PORT_LABEL + " — BLOCKED: nation-specific construction-stage/ghost art unavailable on disk; base stage/ghost mesh reused; NOT a nation stage render; visual UNVERIFIED"
+
 # MOTION-ANIM-01 — presentation-only fixes for the VID-AN-01 faults. Every
 # number and rule here is a PORT APPROXIMATION over MEASURED sim values; none
 # is a donor-authored animation constant and no donor parity is claimed.
@@ -803,6 +824,17 @@ func _entity_mesh_sid(ed: Dictionary, base_sid: String, kind: String) -> Diction
 					# are NOT nation-unique art; gated to exact=false below.
 					if NATION_ROLE_SUB_SIDS.has(rsid):
 						role_sub = true
+				# WAVE-N/N04 (b): donor's eight nation peasant bases are
+				# PRESENTATION ONLY. Add the donor-derived stem as a candidate
+				# for base "peasant"; Data.resolve_sid() cannot do this (its
+				# UNITS trap: pea* have no UNITS_BASE row, N06 §4.3). The
+				# common disk probe below makes it inert if art is absent and
+				# leaves ed["sid"]/"peasant" (and all sim stats) untouched.
+				if base_sid == "peasant" and nation != "" \
+						and NATION_PEASANT_SIDS.has(nation):
+					var psid := str(NATION_PEASANT_SIDS[nation])
+					if psid != base_sid and not candidates.has(psid):
+						candidates.append(psid)
 			"buildings":
 				candidates.append(_donor_building_prefix(nation, base_sid) + base_sid)
 			"naval":
@@ -817,6 +849,12 @@ func _entity_mesh_sid(ed: Dictionary, base_sid: String, kind: String) -> Diction
 			exact = true
 			break
 	var status := NATION_MESH_EXACT_STATUS if exact else NATION_MESH_FALLBACK_STATUS
+	# WAVE-N/N04 (c): a nation hall can be exact while its stage/ghost art is
+	# not. Probe the donor-derived nation stage stem at bind time (never per
+	# frame) and make the remaining gap explicit; no stage/ghost mesh is invented.
+	if family == "buildings" and nation != "" and base_sid != "" \
+			and not _nation_mesh_on_disk(nation + base_sid + "1"):
+		status += " | " + NATION_STAGE_GHOST_BLOCKED_STATUS
 	# B-NATION-PLAN2 T2b role-substitution exactness: a disk hit on a generic
 	# role substitute (bav musketeer/hussar) keeps sid/candidate/candidates
 	# but is labelled role-substitute with exact=false, never exact nation art.
@@ -1533,7 +1571,12 @@ func _acquire(key: String, id: int, info: Dictionary, cls: String,
 	(b as Dictionary)["xforms"].append(Transform3D())
 	# Keep tint/player/pose on the slot so a frame change can re-acquire the
 	# matching batch without re-reading sim state or guessing a key.
+	# WAVE-N/N04 (a): persist the RESOLVED presentation sid on the slot.
+	# info["sid"] is the nation-resolved sid on both the static bind and the
+	# morph re-acquire path, so a frame change cannot silently revert sync()
+	# to the base sim sid. No sim field is written.
 	_slot[id] = {"key": key, "index": ix, "class": cls, "tint": tint,
+		"mesh_sid": str(info.get("sid", "")),
 		"player": player, "pose_source": str(pose.get("pose_source", "static_bind_pose")),
 		"frame": int(pose.get("frame", -1)), "action": str(pose.get("action", ""))}
 	var mm: MultiMesh = b["mm"]
@@ -2135,7 +2178,10 @@ func sync(dt: float) -> void:
 			continue
 		var ed := e as Dictionary
 		var uid := int(id)
-		var sid := str(ed.get("sid", ""))
+		# WAVE-N/N04 (a): use the nation-resolved sid persisted on the slot by
+		# _acquire(); it drives has_skin, pose_for, _mesh_info, _morph_mesh and
+		# the batch key. Legacy slots without the field keep base-sid behaviour.
+		var sid := str((sl as Dictionary).get("mesh_sid", str(ed.get("sid", ""))))
 		var old_key := str((sl as Dictionary).get("key", ""))
 		# MOTION-ANIM-01: measure SIM displacement first, then pick the donor
 		# action from that measurement. This is the walk-while-stalled fix:
@@ -2157,7 +2203,10 @@ func sync(dt: float) -> void:
 			if pose_memo.has(memo_key):
 				pose = pose_memo[memo_key] as Dictionary
 			else:
-				var p = anim.call("pose_for", ed, action, _anim_t)
+				# WAVE-N/N04 (a): pose_for() accepts a sid String
+				# (anim3d.gd:685-690), so the resolved sid selects that
+				# nation's skin and AAF range; the sim entity is untouched.
+				var p = anim.call("pose_for", sid, action, _anim_t)
 				if p is Dictionary:
 					pose = p as Dictionary
 				pose_memo[memo_key] = pose
```

---

## 2. Static verification performed (no Godot, no runner)

| Check | Result |
|---|---|
| Backup taken **before** first edit | 3 files, all pre-edit hashes equal backup hashes (§3) |
| `git diff --check -- variant3d/scripts/world3d_entities.gd` | exit 0, no output (worktree-wide `hud.gd` whitespace debt belongs to P12, not this ticket) |
| Hunk count / size | **6 hunks**, +49 net lines, 2387 → 2436 lines |
| Deletions from backup | **exactly two**, both intentional: `var sid := str(ed.get("sid", ""))` and `anim.call("pose_for", ed, …)`; every other backup line survives byte-identically |
| Line endings | LF-only before and after (**0 CR bytes**), unchanged convention |
| Indentation | 0 space-indented lines before and after; tab-only |
| Braces | 70/70 → 71/71 balanced (`{` +1 on both sides) |
| Parens | 1497/1501 → 1526/1530 (**same +4 pre-existing artefact**), no new imbalance |
| New symbol presence | `NATION_PEASANT_SIDS` def + 2 uses; `NATION_STAGE_GHOST_BLOCKED_STATUS` def + 1 use; `mesh_sid` write + read; `pose_for(sid, …)` call |
| On-disk peasant candidates | `pearus/peaaus/peaukr/peatur/peapol` OBJ **all present** (manifest bboxes real), so the N05 5-nation sids are distinct and file-backed **by static derivation** |
| Nation hall candidates | `ruscen/bavcen/polcen/swecen` OBJ present; `<nat>cen1.obj` absent for all four ⇒ hunk 3 label fires honestly |
| P10 cache invalidation contract | `anim3d.gd` byte-identical to `.bak-N04`; `_morph_cache` key `sid|frame` now receives the nation-resolved sid, still no cache mutation by callers |
| Tests | none created, edited, deleted or weakened; `variant3d/tests/**` untouched by this ticket |
| Post-FOLD-06 re-check | N04 markers still present in the live file: `NATION_PEASANT_SIDS` ×3, `NATION_STAGE_GHOST_BLOCKED_STATUS` ×2, `mesh_sid` ×5, `anim.call("pose_for", sid, action, _anim_t)` ×1; reverse-apply of the §1 patch succeeds and isolates exactly 6 hunks (§3a) |

---

## 3. Backup hashes and preservation proof

Backups were copied with `Copy-Item -LiteralPath` **before the first edit**; none existed
at that time. SHA-256 (uppercase, raw bytes):

| File | Pre-edit == backup SHA-256 | Final SHA-256 | Final state |
|---|---|---|---|
| `variant3d/scripts/world3d_entities.gd` | `DB20C179C1F0A289792652BC85C39215B7BAA1FBE1E9CA929F576C8FE2094EDC` | `44C3C60FCFEED4D05530949D0D645A46770B6ECC0D78A3DA869698770D1E86D1` immediately after N04; live file later `45742F4706981DBB1EB478950B94AE5A28ECAFC984B86562B152B8930267E00F` after FOLD-06 | edited by N04 (6 hunks) + concurrent FOLD-06 path routing |
| `variant3d/scripts/anim3d.gd` | `3C7FCD2D88778743685B5CC12FA6C9215655E0FE9BD07BD065D321060914D407` | `3C7FCD2D88778743685B5CC12FA6C9215655E0FE9BD07BD065D321060914D407` | **untouched** (P10 caches) |
| `variant3d/scripts/data.gd` | `89B1519D5CCA412B4572B657AD40572A2B8D94C95855050F369310E2F9F1E919` | `89B1519D5CCA412B4572B657AD40572A2B8D94C95855050F369310E2F9F1E919` | **untouched** (UNITS trap avoided) |

`inbox/backup/world3d_entities.gd.bak-N04` equals M03's reported post-edit SHA, so the
patch starts from the exact post-M03/post-P10 tree and rolls back no earlier landed fix.
`anim3d.gd.bak-N04` equals P10's reported post-remediation SHA
(`P10_impl.md:71`); `world3d_entities.gd.bak-M03` (pre-M03) is left untouched.

**Protected-region byte comparison** (anchor-delimited, line-number-independent, backup
vs final; `identical=True` for every row):

| Protected region | Result |
|---|---|
| M03 rotor axle-tip constants — `MILL_ROTOR_HUB_DONOR`, `MILL_ROTOR_AXLE_TIP_DONOR_Y`, `MILL_TOWER_BBOX_LO/HI`, `ROTOR_MOUNT_STATUS` | **IDENTICAL** (old 279-283 → new 300-304) |
| M03 `_attach_rotor()` hub/tower-centre derivation + metas | **IDENTICAL** (old 1840-1860 → new 1883-1903) |
| M03 fixed-axle rotor loop + `mill_rotor_*` stats | **IDENTICAL** (old 2241-2268 → new 2290-2317) |
| Mine disc / band mask (`MINE_DISC_STATUS`) | **IDENTICAL** (old 188 → new 188) |
| Construction stages — constants, `_build_progress01`, `_build_stage_suffix`, `_stage_mesh_info`, `_sync_building_stages` | **IDENTICAL** (old 309-313 / 1873-1934 / 1934-2022 → new 330-334 / 1916-1977 / 1977-2065) |
| Ghost provider API `_mesh_info()` | **IDENTICAL** (old 1148-1201 → new 1186-1239) |
| Field art — decal paths, tints, scale constants | **IDENTICAL** (old 290-294 → new 311-315) |
| P11 cache capacity / bind-time clear / `_tinted_material()` / `_new_batch()`+`_grow_batch()` / tint stats | **IDENTICAL** (old 119, 385-695, 1006-1068, 1439-1512, 2360 → new 119, 406-716, 1044-1106, 1477-1550, 2409) |
| P11 `_acquire()` grow call | **IDENTICAL** (the only `_acquire()` edit is the new `mesh_sid` slot field; the two grow lines are unchanged) |

Within the N04 patch the only two removed lines are the two intentional sync lines
listed in §2, so no protected byte could have been altered without appearing as an
extra deletion in that list. F2-03 field-geometry changes were **not** applied (ticket
says F2-03 must wait); `world3d_fx.gd`, `game.gd`, `hud.gd`, `main.gd`, `app/**`, all
tests, config and assets were not touched by this ticket.

### 3a. Isolation of the six N04 hunks after the concurrent FOLD-06 edit

Procedure (no Godot): copy the live file to a temp dir, rewrite the §1 patch headers to
that single file, `git apply -R` it, then `git diff --no-index` the reverse-applied copy
against the live file.

| Item | Result |
|---|---|
| `git apply -R` of the §1 patch onto the live (N04+FOLD-06) file | exit 0 — no context conflict with FOLD-06's path hunks |
| Isolated diff | **6 hunks**, byte-for-byte the §1 patch (only the diff headers differ) |
| Synthetic post-FOLD/pre-N04 baseline git blob | `183b24362892cc57a46af7f73c927abfccaa220d` |
| Live final git blob | `ad75da79461a419f20859cabd74f9cf4faac0c41` (SHA-256 `45742F4706981DBB1EB478950B94AE5A28ECAFC984B86562B152B8930267E00F` at verification time) |
| FOLD-06 regions touched (not by N04) | `AssetPaths` preload, `ROTOR_TEX_IMPORT_PATH`, `bind()` availability stats, `_jitter_factor`, `_nation_mesh_on_disk`, `_tinted_material`, `_mesh_info` path composition |

N04's hunk 3 (`_nation_mesh_on_disk(nation + base_sid + "1")`) routes through
`AssetPaths.existing(sid, "obj", suffix)` after FOLD-06, which checks the mapped bucket
path first and the legacy flat path second (`asset_paths.gd:69-93`); the BLOCKED label
therefore still fires only when no nation stage OBJ exists in either location. M03's
rotor constants and P10's cache code were not touched by FOLD-06 or by N04.

---

## 4. Gate list — G04 only, NONE run here

Standing rule `WAVE_G_CHARTER.md:31,67-70`: only G04 submits runner jobs. N04-IMPL
ran **zero** Godot processes and **zero** runner jobs; every row is
**NOT RUN / PENDING G04**.

| # | Gate | Expected after this patch | Status |
|---|---|---|---|
| 1 | N05 atom `t_nation_assoc_capture.gd` | **Not authored** (`variant3d/tests/t_nation_assoc_capture.gd` absent) — N05 supplied GDScript in its report only. When its owner authors it: checks 5/6 (boot hall `ruscen`, exact, real OBJ), 8/9/10/11 (5 distinct nation peasant sids, `pearus/peaaus/peaukr/peatur/peapol`, exact, file-backed, distinct meshes, player-slot constant) should go GREEN. Do **not** flip `expected_pre_fix_failure` until a real atom is authored and run | PENDING — atom absent |
| 2 | Variant selftest | **29/29**, `passed=true`, `SCRIPT ERROR=0`; no threshold/assertion changed | PENDING G04 |
| 3 | Uitest | **17/17** fresh (on-disk 17/17 is stale per `P11_impl.md:271`; re-run required) | PENDING G04 |
| 4 | `t_entities3d.gd` | GREEN: `api_surface`, `node_count_grows/shrinks`, `remove_below_baseline`, `no_sprite_sheet_loads`, `no_internal_errors`; peak 6 unchanged. No `anim/` literal added | PENDING G04 |
| 5 | `t_render_mode` | PASS / `seam_missing=false`; nation presentation is 3-D only | PENDING G04 |
| 6 | Parse smoke (G04 id of its choice) | `--check-only --script res://scripts/world3d_entities.gd`, `SCRIPT ERROR=0` | PENDING G04 |
| 7 | `t_motion_capture`, `t_anim_metrics`, `t_mass_army`, `assert_clean` | unchanged / CLEAN; resolved sid reaches P10 caches, sim sid untouched | PENDING G04 |
| 8 | Windowed 64² + real-map capture | No new seams/dark rows; `nation_mesh_usage` shows `buildings|rus|cen->ruscen` and `units|rus|peasant->pearus`; no donor-parity claim | PENDING G04 |

---

## 5. UNVERIFIED / open register

1. **UNVERIFIED:** rendered pixels. The exact sid/file associations are static (OBJ,
   manifest bbox, skin index), but no donor GPU A/B frame and no port capture exist.
2. **UNVERIFIED:** P10's Godot byte digest of `skin_vertices()` on cache miss
   (`P10_impl.md:488`) — unchanged by this ticket, still a mandatory G04 gate.
3. `NATION_MESH_BLOCKED_EVIDENCE` and `NATION_MESH_FALLBACK_STATUS` still describe the
   pre-C01ASSET tree ("0 prefixed OBJs", generic Ukrainian fallback). They were left
   byte-identical deliberately to keep this patch minimal and disjoint; a follow-up
   owner should refresh their wording without removing `PORT_LABEL` / `visual UNVERIFIED`.
4. Stage/ghost art remains nation-blind by construction; hunk 3 labels it, it does not
   fix it. Converting `ruscen1..4` / `ruscen1a..4a` (N06 §1.4) is a separate asset ticket.
5. `_acquire()` now writes `mesh_sid` for all classes (resource slots get their proxy
   sid too). This is inert for `res` slots, which `sync()` pass 1 never visits.
6. `C01_asset_impl.md` was not present; the asset reality was verified by direct reads
   of the 299-entry manifest, 15 new OBJ/MTL/PNG triples and `skin/index.json`.
7. **FOLD-06 concurrency (OBSERVED):** another owner rewrote asset-path calls in the
   same file after N04 landed. N04's six hunks survive (§3a), but the live file's
   parse/gate result is a combined N04+FOLD-06 product; G04 must gate the combination,
   and COORD must decide the merge order if further folder-split edits land.

## 6. Scope attestation

Only `variant3d/scripts/world3d_entities.gd` was edited by N04-IMPL; three `.bak-N04`
backups and this report were created. No Godot, no runner job, no donor file copy, no
test/config/asset/gate/result edit, no cross-touch of another owner's file. The later
FOLD-06 path-routing edit to the same file was made by another owner after N04 landed
and is documented but not claimed by this ticket. **N04-IMPL stays available for
COORD follow-up.**

*End of N04 implementation report.*
