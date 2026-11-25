---
id: WAVE-N-N04
ticket: "N04 — ready-to-apply nation fix proposals (hall / object associations / peasants)"
owner: N04 subagent
created: 2026-11-25
status: DELIVERED — PROPOSAL ONLY (NO CODE EDIT, NO ASSET WRITE, NO GODOT, NO RUNNER JOB)
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (Wave N :157-169; standing rules :29-33)
  - docs/terrain_swarm_2026-11-25/CHARTER.md (guardrails :55-69; definition of good :122-131)
  - docs/terrain_swarm_2026-11-25/reports/N01_nation_building_audit.md
  - docs/terrain_swarm_2026-11-25/reports/N03_peasant_forms.md
  - docs/terrain_swarm_2026-11-25/reports/N05_nation_qa.md
  - docs/coord_swarm_2026-11-25/reports/NATION_DONOR_01.md
  - docs/coord_swarm_2026-11-25/reports/B_NATION_PLAN2.md
  - docs/coord_swarm_2026-11-25/reports/B_T2B_NATION_ENT.md
n02_status: "NOT LANDED at authoring time — donor truth re-derived by direct byte reads of the donor install C:\\Games\\Cossacks 3 (actors.lib, units.objects, country.script) plus the port manifest/OBJ tree"
parity_claim: none
outputs: [docs/terrain_swarm_2026-11-25/reports/N04_nation_fix.md]
godot_run: false
code_edits: false
line_number_basis: "current working tree after the P11 integration shifted world3d_entities.gd by +3 lines; re-verified at authoring time. §5 patch is authoritative."
---

# N04 — ready-to-apply nation fix diffs (hall / 3-D object association / peasants)

## 0. Boundary and verdict

**Mode.** READ-ONLY. The only file written is this report. No `.gd`, `.json`,
`.py`, `.obj`, `.png`, fixture, gate or result JSON was created or edited. No Godot
process and **no runner job** were started (`WAVE_G_CHARTER.md:31` — only G04
submits runner jobs). Every diff in §5 is *inside this report only*; COORD must
grant exclusive file ownership before any builder applies one.

| Requirement | Verdict | Why | Diff |
|---|---|---|---|
| (a) Russian initial hall uses correct Russian mesh/sid | **Asset BLOCKED; code already correct** | sid resolution is right (`ruscen`), but `obj/ruscen.obj` does not exist; base `cen.obj` is Ukrainian-derived (`manifest.json:1050-1056`). Donor `ruscen.osm/.actor/.dds` *is* on disk, unconverted. | §2 asset-conversion proposal + §5 hunks 1/3 (smallest safe fallback label). |
| (b) Other nation→3-D-object mismatches | **One real code mismatch found, fixable now** | `sync()` samples skin/topology/batch with the **base** sim sid while `add_unit()` binds the **nation-resolved** sid (N03 M6). On-disk skins/OBJs for `strelet`, `cossackdon`, `wingedhussar`, `jannisary`, … exist. | §5 hunks 4/5/6. |
| (c) Nation-specific peasant meshes/skins where assets exist | **No port assets on disk; donor-derived probe added safely** | Exactly one peasant OBJ/skin/texture (`peasant.*` ← donor `peaukr`), zero nation-keyed. Donor has 8 nation peasant `.oss`. | §5 hunks 1/2 (probe, inert until assets land). |

Every nation status string is `PORT APPROXIMATION — NOT DONOR PARITY`
(`world3d_entities.gd:191`) with `visual UNVERIFIED` embedded. No donor-parity
claim is made anywhere in this report.

---

## 1. Inputs, donor truth and asset inventory

`N01` and `N03` had landed; `N02` had not. Donor truth was re-derived by direct
byte reads: `C:\Games\Cossacks 3\data\actors\actors.lib` (`LODActorName =
pea{aus,eng,pol,rus,spa,tur,ukr,sco}` + `.actor` paths), `data\objects\units\
units.objects` (eight `pea*.prop`), `data\scripts\lib\country.script:2655-2662,
2915-2922` (nation→peasant), and `data\actors\buildings\rus\ruscen.osm`,
`ruscen.actor`, `data\materials\buildings\rus\ruscen.dds` (all present).
This agrees with `N01 §1-§3`, `N03 §0/§3/§4`, `NATION_DONOR_01 G7-G10/C5-C6`,
`B_NATION_PLAN2 §2.1/§2.2/§6`; `N05` supplies the expected QA baseline.

| Asset | Port disk | Donor disk | Status |
|---|---|---|---|
| `obj/cen.obj` + `tex/cen.png` (generic hall) | **on disk** (`manifest.json:1050-1056`) | donor `ukrcen.osm/.dds` | on disk but **Ukrainian-derived** |
| `obj/ruscen.obj`, `obj/ruscen.glb`, `tex/ruscen.png` | **MISSING** | `ruscen.osm`, `.actor`, `.dds` **present** | **BLOCKED** — conversion not done; owner = asset/manifest, not `world3d_entities.gd` |
| `obj/peasant.obj`, `tex/peasant.png`, `skin/peasant.json` | **on disk** | donor `peaukr.oss/.dds/.aaf` | on disk but Ukrainian-derived |
| `obj/pearus.obj` / `.glb` / `skin/pearus.json` | **MISSING** | `pearus.oss` present | **BLOCKED** |
| `obj/peaukr.obj`, `peaaus`, `peatur`, `peapol`, `peaeng`, `peaspa`, `peasco` | **MISSING** | `.oss` present for all 8 | **BLOCKED** |
| `obj/strelet.obj`, `cossackdon`, `wingedhussar`, `jannisary`, `sipahi`, `hackapell`, `bagpiper`, `sco_highlandersword` + matching `skin/*.json` | **on disk** | donor-derived | **available now** — §5 hunks 4/5/6 use these |
| 2D sheets `anim/rus/buildings/rus_cen.png`, `anim/rus/units/rus_peasant_*.png` | **on disk** | donor-derived | 2D only; `world3d_entities.gd:17-20` forbids the 2D bake pipeline — 3-D must **not** load them |

**Do not fabricate.** No OBJ, PNG, manifest row or skin JSON is invented by any
diff below. Where art is missing the code keeps the honest `cen.obj` /
`peasant.obj` fallback and says so in telemetry and status labels.

### 1.1 Code anchors (current working tree)

| Concern | Anchor |
|---|---|
| Hall boot spawn | `variant3d/scripts/game.gd:2950-2952` — `var cen := spawn("cen", i, c)` |
| Peasant boot spawn | `variant3d/scripts/game.gd:2955-2963` — `spawn("peasant", i, …)` |
| Nation recovery | `variant3d/scripts/world3d_entities.gd:679-697` `_nation_of()` |
| Disk-only mesh probe | `variant3d/scripts/world3d_entities.gd:702-706` `_nation_mesh_on_disk()` |
| Building prefix rule | `variant3d/scripts/world3d_entities.gd:715-740` `_donor_building_prefix()` — `cen` ∈ `OWN_FAMILIES` ⇒ `rus` ⇒ candidate `ruscen` (donor `country.script:138-206`) |
| Mesh sid selection | `variant3d/scripts/world3d_entities.gd:760-814` `_entity_mesh_sid()` |
| Unit static bind | `variant3d/scripts/world3d_entities.gd:1653-1699` `add_unit()` — uses resolved `ns["sid"]` |
| Unit animation/morph | `variant3d/scripts/world3d_entities.gd:2070-2160` `sync()` pass 1 at `:2109-2150` — uses **base** `ed.sid` (the mismatch) |
| Mesh load | `variant3d/scripts/world3d_entities.gd:1132-1182` `_mesh_info()` — OBJ → GLB → `donor_bbox_proxy`; manifest bbox needed for true height |
| Honest labels | `variant3d/scripts/world3d_entities.gd:191,206-216` |

---

## 2. (a) Russian initial hall — correct sid, safe fallback

### 2.1 Why no code-only fix can render a Russian hall today

`_donor_building_prefix("rus","cen") + "cen"` already equals `ruscen` and is
probed at `world3d_entities.gd:797-802`. The probe fails because
`res://assets/models/obj/ruscen.obj` does not exist; `:794` sets `sid = base_sid`
(`cen`) and `:803` returns `NATION_MESH_FALLBACK_STATUS`. That is the **correct,
honest** behaviour — the defect is asset availability (`N01 §7:197-198`,
`NATION_DONOR_01 G7/G10`). Hard-coding `ruscen` into `spawn()` would make
`_mesh_info()` fall through to `donor_bbox_proxy` (1 m box, no manifest bbox):
worse, and a fabricated claim.

### 2.2 Diff A — asset conversion proposal (donor-derived, NOT fabricated)

Not applied by N04; operative fix for an asset owner. `convert_models.py` is a
table-driven whole-pipeline converter: `unit_models()` at `:170`
(`"peasant": "peaukr"`), `building_models()` at `:253`
(`"cen": ("ukr","ukrcen","ukr","ukrcen")`), CLI at `:499-505`
(`--game`, `--out`, `--include-stages`). One asset owner must:

1. Back up first:
   `Copy-Item -LiteralPath 'variant3d\assets\models\manifest.json' -Destination 'inbox\backup\manifest.json.bak-N04'`
2. Convert into a **scratch** out dir, never over the shipped 280 OBJs: add one
   donor-derived `ruscen` row mirroring `:253` but
   `("rus","ruscen","rus","ruscen")`, then
   `python variant3d\tools\convert_models.py --game "C:\Games\Cossacks 3" --out <scratch>`.
3. Compute the true bbox/ortho with the shipped `variant3d\tools\compute_buildings.py`
   (or `compute_ortho.py`) — **do not hand-write a bbox**.
   `_mesh_info():1136-1141` uses `bbox[4]/bbox[5]` for native height; a missing
   placeholder bbox yields a 1 m proxy and fails N05 check 6.
4. Copy only `ruscen.obj`, `ruscen.png` and one manifest entry into the live
   tree; leave all 172 existing entries byte-identical.
5. Acceptance: `obj/ruscen.obj` + `tex/ruscen.png` exist; manifest sid `ruscen`
   has a real bbox; `_entity_mesh_sid()` returns `exact=true`;
   `mesh_source != donor_bbox_proxy`; N05 checks 5/6 turn GREEN.

No file above is modified by this ticket. If the owner declines the asset
ticket, §5 hunk 3 is the smallest safe fallback.

### 2.3 Backup command for the code hunks (owner: `variant3d/scripts/world3d_entities.gd`)

PowerShell `;`, not `&&`, per `CHARTER.md:69`. Single file; `game.gd`, `hud.gd`,
`main.gd` are already modified by other waves — do not cross-touch.

```
Test-Path -LiteralPath 'inbox\backup\world3d_entities.gd.bak-N04'   # expect False
Copy-Item -LiteralPath 'variant3d\scripts\world3d_entities.gd' -Destination 'inbox\backup\world3d_entities.gd.bak-N04'
Get-FileHash -Algorithm SHA256 'variant3d\scripts\world3d_entities.gd'
Get-FileHash -Algorithm SHA256 'inbox\backup\world3d_entities.gd.bak-N04'   # hashes must match
```

**PORT APPROX label added by hunk 1:**

```
NATION_HALL_BLOCKED_STATUS = PORT_LABEL + " — Russian starting hall base sid 'cen' resolves to donor-derived candidate 'ruscen' (country.script:138-206); converted OBJ/GLB absent; Ukrainian-derived cen.obj reused; NOT a Russian hall; visual UNVERIFIED"
```

**Behaviour today:** no visual/render change; only `nation_mesh_label` telemetry
for `buildings|rus|cen->cen` changes from the generic fallback string to the
explicit BLOCKED string. `exact` stays `false`, `sid` stays `cen`. After Diff A
lands, the `if not exact` guard is false and this label is never used — the hall
then binds `ruscen` with `NATION_MESH_EXACT_STATUS`.

---

## 3. (b) Other nation→3-D-object mismatches

### 3.1 Audited and rejected as code defects

All building families in `N01 §3A/§3B` (`cen/hou/bar/sta/bla/aca/art/dip` →
`ukr*`, `sto/mil/mar/tow/wal/gat` → `eur*`/env) and the naval `pass` branch are
**asset-blocked**, not wrong code: `_donor_building_prefix()`
(`world3d_entities.gd:715-740`) matches the donor sidmask
(`NATION_DONOR_01 §2.4`, `country.script:138-206`), and
`bavmil`/`bavpor`/`yachtrus` must **not** be invented (`B_NATION_PLAN2 §6`;
donor has none). The two Bavarian role-sub label bugs were already fixed by
`B_T2B_NATION_ENT` (`NATION_ROLE_SUB_SIDS` `:215`, gate `:809-811`) — do not
re-touch.

A further gap is **unwired**, not mis-associated: nation-unique meshes
`hetman.obj/.json` (ukr-only per `NATION_DONOR_01 C3`), `cossackregister` (ukr)
and `vityaz` (rus) are on disk but have no `NATION_UNITS` row
(`data.gd:294-306`; `UNITS_BASE` rows `:956,:965,:1090`). Adding those rows is
**DEFERRED**: it changes sim train/AI order and selftest seed traces (already
deferred in `B_NATION_PLAN2 §3/:69`) and would require owner sign-off plus a
trace re-baseline. Not part of the ready-to-apply patch; no test weakening.

### 3.2 The real code mismatch, fixable now

**Finding (DERIVED, N03 M6, re-verified this pass):** `add_unit()` binds the mesh
using `ns["sid"]` (`world3d_entities.gd:1673-1674`), but `sync()` pass 1 reads
`var sid := str(ed.get("sid", ""))` (`:2111`) and uses that base sid for
`has_skin()` (`:2128`), `pose_for(ed, …)` (`:2133`), `_mesh_info()` (`:2141`),
`_morph_mesh()` (`:2142`) and `new_key` (`:2150`). For a nation-remapped unit
(e.g. player-0 Russia `serdiuk → strelet`, `data.gd:295`) the static mesh is
`strelet` but the animated skin, morph topology and morph batch are generic
`serdiuk` — two nation objects disagree. Assets are **already on disk**:
`strelet`, `cossackdon`, `wingedhussar`, `jannisary`, `sipahi`, `hackapell`,
`bagpiper`, `sco_highlandersword`, `mullah`, `pope`, `musketeer`, `hussar`
(OBJ + skin each).

**Design (minimal; no per-frame disk probe, no sim write):** `add_unit()` stores
the already-resolved sid on `_slot[id]`; `sync()` reads it back with a base-sid
fallback for legacy slots. `pose_for()` accepts a sid String
(`anim3d.gd:655-660`) and uses `e` only via `_sid_of()` (`:656-660`,
`:489-550`), so passing the resolved sid is safe and makes skin/range lookup
nation-correct.

**PORT APPROX labels:** unchanged — `ANIM_STATUS` (`:194`) and
`NATION_MESH_EXACT_STATUS` (`:208`) already carry `PORT_LABEL` and
`visual UNVERIFIED`; no parity claim added. Owner file/backup: §2.3.

---

## 4. (c) Nation-specific peasant meshes/skins — safe probe, no fabricated art

### 4.1 Donor truth (direct read; corroborates N03 §1)

`country.script:2655-2662` and `:2915-2922`:

```
aus/pru/bav/sax/swi -> peaaus     ukr -> peaukr      rus -> pearus
pol/hun             -> peapol     spa/ven/por/pie -> peaspa
tur/alg             -> peatur     fra/eng/swe/den/net -> peaeng
sco                 -> peasco
```

Exactly eight donor peasant bases (`actors.lib` / `units.objects`; corroborating
`REPORT_ASSETS_BAKING.md:174`, `GUIDE1.md:126`). Bavaria has **no** own peasant —
`bav→peaaus` is donor-correct, not fabricated. The port has none converted:
`skin/index.json` has one peasant entry (`peasant.json` ← `peaukr.oss`), which
`N03 §0/§4` documents.

### 4.2 Diff D — donor-derived probe, inert until assets land

**Owner file/backup:** §2.3. **PORT APPROX labels:** uses existing
`NATION_MESH_EXACT_STATUS` / `NATION_MESH_FALLBACK_STATUS` (`:208-209`), both
`PORT_LABEL` + `visual UNVERIFIED`. See §5 hunks 1 and 2.

**Behaviour today:** `NATION_PEASANT_SIDS` candidates are appended, but
`_nation_mesh_on_disk()` (`:702-706`) returns false for all eight (0 on disk),
so `:794-803` still returns `sid="peasant"`, `exact=false`, base Ukrainian mesh
— byte-identical render, only a wider `candidates` trace. The moment an asset
owner lands `obj/pearus.obj` + `tex/pearus.png` + `skin/pearus.json` (+ manifest
bbox per §2.2 step 3), Russia's peasant binds `pearus` with no code change.

**Why not just add `NATION_UNITS.rus.peasant → pearus`:** `resolve_sid()`
(`data.gd:1565-1568`) rejects targets absent from `UNITS_BASE`; `pearus` has no
row, so the mapping would be inert and would need a sim row + trace re-baseline.
The presentation-only probe is the smallest safe change (no sim edit, no test
weakening).

### 4.3 Follow-up asset ticket (donor-derived, not part of the patch)

For a future asset owner only: extend `convert_models.py:170` `unit_models()`
with the eight `peasant → pea{nation}` rows mirroring `peasant → peaukr`,
generate skins with the shipped `convert_skins.py` (`skin/index.json` entries
carry `donor_oss`, `donor_aaf`, frame count), add bbox rows via
`compute_buildings.py`, and copy only new files + manifest entries. Do **not**
re-point the generic `peasant` sid at `pearus` — that would break the 2D alias
(`bake_sprites.py:43-48`, `peasant → ukr_peasant`) and every test fixture.

---

## 5. Ready-to-apply unified patch (ALL hunks, one file)

Single owner file: `variant3d/scripts/world3d_entities.gd`. Backup exactly as in
§2.3 before applying. Hunk headers were validated against the current working
tree (context/deletion lines match byte-for-byte; `+` line numbers are the
post-application offsets). Hunk 1 is `(a)+(c)` constants, hunk 2 `(c)` peasant
probe, hunk 3 `(a)` hall fallback label, hunks 4/5/6 `(b)` sync/mesh-sid fix.

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -215,4 +215,27 @@ const NATION_MESH_ROLE_SUB_STATUS: String = PORT_LABEL + " — generic donor role substitute on disk, NOT nation-unique art (bav serdiuk->musketeer / cossack->hussar via data.gd:296; donor generic U:771-785/U:1347-1353; bav uniques absent); visual UNVERIFIED"
 const NATION_ROLE_SUB_SIDS: Array[String] = ["musketeer", "hussar"]
 const NATION_MESH_BLOCKED_EVIDENCE: String = "BLOCKED (NATION_DONOR_01 G7-G10/C6): 0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems); manifest generic peasant->peaukr.dds, 8 core buildings->ukr*.osm/ukr*.dds, 0 rus-keyed and 0 bav-keyed textures; Bavarian musketeer18bav/grenadierbav and Ukrainian chaika are absent from manifest+obj. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED."
 
+# WAVE-N/N04 (a): honest status for the BLOCKED Russian starting hall.
+# The correct donor-derived sid ("ruscen") is already probed at :797-802;
+# this label only makes the miss explicit. No mesh is invented and no
+# false "Russian hall" claim is made; visual result stays UNVERIFIED.
+const NATION_HALL_BLOCKED_STATUS: String = PORT_LABEL + " — Russian starting hall base sid 'cen' resolves to donor-derived candidate 'ruscen' (country.script:138-206); converted OBJ/GLB absent; Ukrainian-derived cen.obj reused; NOT a Russian hall; visual UNVERIFIED"
+
+# WAVE-N/N04 (c): donor's eight nation-peasant bases
+# (country.script:2655-2662,2915-2922; REPORT_ASSETS_BAKING.md:174).
+# DONOR-DERIVED stubs only: each is probed with _nation_mesh_on_disk()
+# before use; a miss falls back to base "peasant". No art is invented.
+# Pru/Sax/Swi/Bav share peaaus; Hun shares peapol; Por/Ven/Pie share
+# peaspa; Fra/Eng/Swe/Den/Net share peaeng (all donor-derived).
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
+
 # MOTION-ANIM-01 — presentation-only fixes for the VID-AN-01 faults. Every
@@ -787,6 +810,16 @@ func _entity_mesh_sid(ed: Dictionary, base_sid: String, kind: String) -> Dictionary:
 					# are NOT nation-unique art; gated to exact=false below.
 					if NATION_ROLE_SUB_SIDS.has(rsid):
 						role_sub = true
+				# WAVE-N/N04 (c): donor peasants are eight distinct nation
+				# sids (country.script:2655-2662,2915-2922); data.gd
+				# NATION_UNITS has no peasant row, so resolve_sid() above is
+				# identity. Probe the DONOR-DERIVED nation stem ONLY when the
+				# converted OBJ/GLB is on disk; a miss leaves candidates empty
+				# and :794-803 falls back to "peasant". No mesh is invented.
+				if base_sid == "peasant" and NATION_PEASANT_SIDS.has(nation):
+					var psid := str(NATION_PEASANT_SIDS[nation])
+					if psid != base_sid and not candidates.has(psid):
+						candidates.append(psid)
 			"buildings":
 				candidates.append(_donor_building_prefix(nation, base_sid) + base_sid)
 			"naval":
@@ -801,5 +834,11 @@ func _entity_mesh_sid(ed: Dictionary, base_sid: String, kind: String) -> Dictionary:
 			exact = true
 			break
 	var status := NATION_MESH_EXACT_STATUS if exact else NATION_MESH_FALLBACK_STATUS
+	# WAVE-N/N04 (a): the boot-spawned Russian hall (base "cen", game.gd:2952)
+	# probes donor-derived "ruscen". With no converted OBJ the generic
+	# fallback above is correct; use the explicit hall label so QA can
+	# assert the BLOCKED state without claiming a Russian hall rendered.
+	if not exact and family == "buildings" and base_sid == "cen":
+		status = NATION_HALL_BLOCKED_STATUS
 	# B-NATION-PLAN2 T2b role-substitution exactness: a disk hit on a generic
 	# role substitute (bav musketeer/hussar) keeps sid/candidate/candidates
@@ -1686,4 +1725,11 @@ func add_unit(e) -> void:
 	var ix := _acquire(key, id, info, "unit", tint, player)
+	# WAVE-N/N04 (b): remember the RESOLVED nation mesh sid on the slot.
+	# sync() previously re-read the base sim sid, so nation-remapped units
+	# (rus serdiuk->strelet, pol cossack->wingedhussar, ...) sampled the
+	# generic skin/topology (N03 M6). Read-only; no sim field is written.
+	var uslot: Dictionary = _slot.get(id, {})
+	if not uslot.is_empty():
+		uslot["mesh_sid"] = sid
 	if ix >= 0:
 		var b: Dictionary = _batches[key]
 		# NATION-MODEL-01: tag the batch with the honest nation status so a
@@ -2109,5 +2155,8 @@ func sync(dt: float) -> void:
 		var ed := e as Dictionary
 		var uid := int(id)
-		var sid := str(ed.get("sid", ""))
+		# WAVE-N/N04 (b): use the nation-resolved sid stored by add_unit so
+		# skin, morph topology, mesh info and batch key all match the static
+		# mesh. Legacy slots without the field keep the base-sid behaviour.
+		var sid := str((sl as Dictionary).get("mesh_sid", str(ed.get("sid", ""))))
 		var old_key := str((sl as Dictionary).get("key", ""))
 		# MOTION-ANIM-01: measure SIM displacement first, then pick the donor
@@ -2130,5 +2179,7 @@ func sync(dt: float) -> void:
 			if pose_memo.has(memo_key):
 				pose = pose_memo[memo_key] as Dictionary
 			else:
-				var p = anim.call("pose_for", ed, action, _anim_t)
+				# pose_for() accepts a sid String (anim3d.gd:655-660): the
+				# resolved sid makes skin/range lookup nation-correct.
+				var p = anim.call("pose_for", sid, action, _anim_t)
 				if p is Dictionary:
```

If another owner edits this file before application, recompute offsets with
`git apply --3way`; the `-`/`+` line contents are authoritative.

---

## 6. Acceptance matrix (for COORD / G04 / G05)

| Gate | Method | After applying §5 (before asset conversion) | After §2.2/§4.3 assets |
|---|---|---|---|
| Parse smoke | `python variant3d\tools\godot_runner.py run --id n04-parse1 --timeout 300 -- --headless --path variant3d --check-only --script res://scripts/world3d_entities.gd` (G04 only; N04 did not run it) | `status ok`, `exit 0`, `SCRIPT ERROR` 0 | unchanged |
| Atomic 3-D entities | `t_entities3d.gd` | GREEN; `no_sprite_sheet_loads` PASS (no forbidden `anim/` literal added) | unchanged |
| Full gates | selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN | unchanged | unchanged |
| Other tests | `t_anim_metrics`, `t_mass_army`, `t_motion_capture`, `t_capture`, `t_roster_scotland`, `t_menu_roster` | GREEN / unchanged | unchanged |
| Nation QA atom | N05 `t_nation_assoc_capture.gd` (new file by its own owner) | checks 5/6/8/9/10/11 honestly RED (no threshold changed) | 5/6 GREEN for `ruscen`; 8/9/10/11 GREEN when 5 peasant OBJs land |
| Donor parity | donor GPU A/B frame | **UNVERIFIED** (none exists, `CHARTER.md:55-57`) | still **UNVERIFIED** — only mesh/sid identity proven |

Every applied hunk keeps `PORT_LABEL` ("PORT APPROXIMATION — NOT DONOR PARITY")
and `visual UNVERIFIED` on all nation status strings. No threshold lowered, no
assertion deleted, no `expected_pre_fix_failure` flipped, 2D `app/` untouched.

## 7. Scope attestation

Only this report was written. No code, config, manifest, asset, test, gate,
fixture or result JSON was edited. No donor binary was executed or copied; donor
reads were text/byte reads only. No Godot process and no runner job were started.
Line numbers are from the working tree read this session (after the P11 shift);
`git status` shows `game.gd`, `hud.gd`, `main.gd`, `world3d_entities.gd` already
modified by other waves — this proposal owns **only**
`variant3d/scripts/world3d_entities.gd` and never cross-touches them. COORD must
grant exclusive ownership before any builder applies these diffs, and G04
remains the sole runner owner.

*End of N04 report.*
