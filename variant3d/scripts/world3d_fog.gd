extends Node3D

# V7-16 — per-tile fog-of-war shading for the 3D variant.
# Owns ONE file. The 2D path (app/scripts/world.gd) is untouched.
#
# PORT SOURCES (read-only this session, cited):
#   app/scripts/world.gd:27-28       fog_explored / fog_vis PackedByteArray
#   app/scripts/world.gd:333-338     bind() sizes arrays to MAP_W*MAP_H, fog_img fill
#   app/scripts/world.gd:2186-2256   _update_fog(): reveal requests, search radius,
#                                    fog_counts, visible/explored transitions and the
#                                    0.78 / 0.30 / 0.00 black-alpha ladder (:2250-2255)
#   app/scripts/world.gd:2258-2272   tile_visible() / tile_explored()
#   app/scripts/game.gd:2834-2836    reveal_requests + game_reveal(pos, r)
#   variant3d/scripts/game.gd:2834-2836, :3456-3461  same sim API in the 3D project
#   variant3d/scripts/world3d.gd:215-224  centred tile-corner -> world quad mapping
#   variant3d/tests/t_fog3d.gd:37-48,150-184  stub-game shape and structural checks
#
# DONOR SOURCES OF TRUTH (read via evidence reports, NOT re-read here):
#   E19  pvl.smx3.id0.frag:29-43  view-space LINEAR/EXP/EXP2 fog  (RENDER_ARCH_SHADERS.md:150)
#   E20  def.pvl.sm.vert:38-42    fog depth = view-space distance (RENDER_ARCH_SHADERS.md:151)
#   camera.cfg:51-64 DynFog* keys; DynFogDepth=False in game mode (:59)
#        (RENDER_ARCH_CAMERA.md:59-62)
#   V71_mechanics_inventory.md:166 — fog overlay PARTIAL; donor fog<->explored
#        engine binding UNVERIFIED; "do not invent a new fog rule".
#
# HONEST LIMIT: the donor depth fog above is a *view-distance* effect and is
# disabled in the gameplay camera (DynFogDepth=False). The 2D fog-of-war arrays
# are a different mechanic. Their sim state is ported verbatim; the donor's
# binding of that state to any shader is UNVERIFIED, so no donor fog constant
# is fabricated here. The alpha ladder below is the port's own state encoding
# (world.gd:2251-2255), not a claimed donor value.
#
# Rendering: ONE transparent ArrayMesh of per-tile quads with vertex-colour
# alpha, NOT a full-map Sprite2D / ImageTexture (the 2D path at world.gd:337-347).

# ─── DEC-U-FOG-CAMERA-HUD — IMPL-FOG-HUD resolved-law layer ────────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_fog_camera_hud.md.
# RESOLVED donor law, implemented 1:1 (all [O] with file:line in that report):
#   §1.1 unit.script:11563-11614 _unit_GetVision — fogreveal -> floor(pproj.dx);
#        normal -> floor(20 + 4*vision); dead / unbuilt / not-visible -> 0.
#        cBaseVal=20, cModVal=4 (:11567-11571); 18/3.6/3.75 rows are DEAD.
#   §1.2 misc.script:5883-5944 — tag-109 fogreveal objects (dmscript.global:1439),
#        get-or-create by px/pz scan, AddFOWObjects, visible=False,
#        TProj.px/pz/dx := px/pz/radius; remove destroys the first match.
#        scenario.script:1851-1864 map_revealZone + FOWBuildFull on enable.
#   §1.3 player.script:451-478 — FOW off for balloon / victory / editor flag,
#        own handle + same-team allies share vision, SetFOWDovFunc('_unit_GetVision'),
#        SetFOWEnable(bFOW); control.script:712-720 set-player call order.
#   §4.1/§5.1 LOS veto — (not GetFOWEnable) or GetFOWLOSData(x,z)>0 drives
#        picking (control.script:270-273) and resource tint (gui.script:3478-3496).
# UNRESOLVED [U] — NOT substituted; each keeps its experiment:
#   F1-GRID cell size, max/sum combine, LOS occlusion, explored persistence;
#   F1-MINI explored-vs-visible tint thresholds.
#   DynFog* (camera.cfg:59-64) is a VISUAL depth fog, DynFogDepth=False in the
#   gameplay camera — never used as gameplay FOW.
# NO PARITY CLAIM.

# ─── DEC-U-FOW-KNOBS — donor-settled labels / telemetry ───────────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_knobs.md (§§2/4/5/8).
# STATIC PASS ONLY. Donor binary never executed. NO PARITY CLAIM. Labels below
# are donor-settled facts; they add NO behaviour and NO port constant.
#
# SHIPPED-ACTIVE bindings [O] — each has >=1 shipped lib/*.script writer/call:
#   Get/SetFOWEnable (sim gate) · Add/ClearFOWPlayers (viewer set,
#     player.script:460-472) · Add/Del/ClearFOWObjects (misc.script:5927) ·
#     Get/SetFOWDovFunc · GetFOWLOSData · FOWBuildFull (scenario.script:1861-1862).
#   K9  GetFOWLOSData(x, z: Float): Integer @ file-off 0x2a7812 (VA 0x6a8412).
#       Script call sites compare only >0 (control.script:270, gui.script:3479);
#       Integer domain (boolean-vs-count) stays [U] until E-GRID-e.
#   Single shipped SetFOWDovFunc site: player.script:475
#       SetFOWDovFunc('_unit_GetVision'); — the only FOW hook consumer shipped.
#
# ENGINE-DEFAULT-ONLY knobs [D] — zero shipped lib/*.script writers, zero FOW
#   keys in cossacks.ini/editor.ini, zero knob mentions in camera.cfg. Their
#   live values are engine defaults readable only via the paired Get* entry
#   points. ALL eight stay [U]; NO default invented; NO port constant added
#   until E-KNOB-defaults terminates (§7 change list is CONDITIONAL, not applied
#   by this label pass). Signatures/file-offs re-dumped verbatim (§2):
#     K1 Get/SetFOWElevation (Float)                       @0x2a750d / 0x2a7539
#     K2 Get/SetFOWLerpFactor (Float)                      @0x2a7569 / 0x2a7595
#     K3 Get/SetFOWTextured (Boolean)                      @0x2a75c5 / 0x2a75f1
#     K4 Get/SetFOWDefDov (Integer)                        @0x2a774e / 0x2a7776
#     K5 Get/SetFOWColor (r,g,b,a: Float)                  @0x2a77a9 / 0x2a77e1
#     K6 Get/SetFOWFillMaxNum (Integer)                    @0x2a784d / 0x2a7881
#     K7 Get/SetFOWDateTime (Boolean)                      @0x2a78ad / 0x2a78d9
#     K8 Get/SetFOWSmooth (pcfsmooth,pcffactor,aasmooth,
#                          aafactor)                       @0x2a7929 / 0x2a79a5
#   E-KNOB-defaults log: call each getter once per run alongside E-GRID-a x3;
#   terminate only on identical values with zero mismatches. Any flapping
#   value stays [U] and gets no port constant. Never set a knob to match a look.
#   K2/K3/K5/K8 are render-edge/tint/smoothing only — they move pixels, never
#   the script grid; all §6 readouts dump GetFOWLOSData, never pixels.
#
# RTTI / renderer types — shipped-active engine internals [D]: byte traces in
#   the shipped image (P4), but NO script construction site and NO readable
#   field layout. Layouts and the cell-to-map transform are UNRECOVERABLE [U]:
#     TLOSInfo @0x361191 · TLOSData @0x3611e9 ·
#     TFOWLerpInfo @0x361241 · TFOWLerpData @0x36129d ·
#     TOSWFOWRender @0x3613a9 / 0x3613be ·
#     XFOWRender @0x3613d6 / 0x361419 / 0x549f0d · FOWRenderT @0x1d9c16.
#   These are engine-internal records, never port structures. The port
#   fog_explored / fog_vis / fog_counts arrays (below) are port inventions,
#   not donor names.
#
# camera.cfg DynFog* is VISUAL view-depth fog only (DynFogDepth=False in game
#   mode, camera.cfg:59-64) — never gameplay FOW (see also header :21-22/:54-55).
#
# STILL [U] — fixed-camera transects, zero-mismatch termination, NO value
#   substituted: E-GRID-a cell size; E-GRID-b combine/FOWFillMaxNum cap/
#   FOWDefDov fallback; E-GRID-c occlusion/FOWElevation; E-GRID-d persistence;
#   E-GRID-e K9 Integer domain. No slope, cell size, combine operator, cap or
#   default is invented here. The provisional metre driver and sticky-explored
#   mirror remain PORT labels until their arms terminate.

# ─── DEC-U-FOW-TINT — donor-settled labels / [U] telemetry ─────────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_tint.md §§2/6/7.
# STATIC PASS ONLY. Donor binary never executed. NO PARITY CLAIM. Labels below
# add NO behaviour, NO colour, NO interval unit and NO threshold.
# [D] FOWColor (K5) signature / [U] value — Get/SetFOWColor(r,g,b,a: Float)
#     @0x2a77a9 / 0x2a77e1 in the DEC-U-FOW-KNOBS block above is
#     ENGINE-DEFAULT-ONLY: zero shipped lib/*.script writers (P-B7: 0 matches),
#     no value in any readable file. It is a render-edge tint/smoothing knob,
#     NOT a grid law, and CANNOT ground any panel-terrain colour. No port
#     constant mirrors it here.
# [U] TELEMETRY — no readable terrain/explored tint RGBA, threshold or blend
#     factor exists in the donor minimap/HUD path (full text reads P-B1..P-B7:
#     minimap.cfg / colors.lib / gui.script / misc.script). Native renderer
#     names (P-A3: TOSWFOWRender / XFOWRender / FOWRenderT) prove an engine FOW
#     render layer but expose no layout, colour or threshold. This is a
#     RECORDED [U], not a gap to fill — no value is substituted.
# [U] PORT APPROXIMATION (DEC-U-FOW-TINT §6.10) — ALPHA_UNEXPLORED/EXPLORED/
#     VISIBLE 0.78 / 0.30 / 0.00 and the black-RGB shader below are the port's
#     own state encoding, NOT donor tint values. F1-MINI-TINT-TERRAIN keeps its
#     fixed-camera, zero-mismatch 3-run × 2-DPI capture; only a terminating
#     capture may replace the ladder/shader with measured values.
# [O] camera.cfg:59-64 DynFog* is visual view-depth fog (DynFogDepth=False in
#     gameplay) — never an explored tint. minimap.cfg:28-723 LOD CriticalColor
#     Blue=1/0 is a CriticalScale zoom-out fallback, NOT a tint. miscext2.script
#     :260-272 lens.0 blink (0.2, floor(10/0.2)*10) is the ALARM primitive,
#     never a unit blink. misc.script:1042-1048 `Interval = 50` has NO stated
#     unit — a bare integer, recorded [U] beside hud.gd's S2 label.
# visual_parity_claim = false — unchanged. The six minimap [U] items keep their
#     zero-mismatch captures; no test weakened and no behaviour changed.

# ─── DEC-U-TEAMS / IMPL-TEAMVIS — viewer-team law + [U] captures ───────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_teams.md §§2/4/5/8/9
#            + DEC_U_fog_camera_hud.md §1.3 + donor player.script:451-478.
# STATIC PASS ONLY. Donor binary never executed. NO PARITY CLAIM. No test
# weakened. This block adds labels/telemetry; the three donor facts below are
# applied in rebuild_fow_enable() / _fow_viewer_players() with exact cites.
#
# DONOR LAW IMPLEMENTED HERE (decomposed from player.script:451-478 [O]):
#   V1 viewer set = AddFOWPlayers(self) + every i<>viewer with the SAME SIM
#      TEAM (gPlayer[i].team = team), player.script:464-473; DEC_U_teams §5.1.
#   V2 slot-0 / bneutral exception: `(plInd<>0) or (not gPlayer[i].bneutral)`,
#      player.script:470-472; the broad commented form at :470 is NOT taken.
#      bneutral is a TPlayer boolean (classes.script:3674-3698) written by
#      trigger action 20 (scenario.script:2225-2249) — NOT a team id.
#   V3 ANY terminal victorystate of the viewer (`<> none`, win=1 OR lose=2)
#      disables FOW entirely = full map vision, player.script:454-456;
#      enum none/win/lose = 0/1/2 (dmscript.global:777-779).
# LAYERS KEPT DISTINCT (DEC_U_teams §4): layer A = gPlayer[].team, the ONLY
#   key FOW/win/AI read; layer B = enemyplmask/myplmask + engine friend/enemy
#   handles, targeting only. FOW must never consult layer B or a lobby team.
# FFA SHAPE [D] §2 (player.script:2139-2173): lobby [0,0,0,0] -> sim [1,2,3,4];
#   shared lobby [1,1,2,2] -> sim [1,1,2,2]. This file does NOT synthesise
#   those dense ids — game.gd/data.gd own SetupTeams (§8 change 1, OUT OF
#   SCOPE here). It reads the existing game `_sim_team` accessor when present
#   (§8 change 2) else the port's -1-unique mapping (game.gd:8283-8285), which
#   yields the same no-share outcome without inventing a team matrix.
#
# PORT GAPS (labelled, not filled):
#   G1 no _player_SetupTeams; post-setup sim teams absent.
#   G2 no enemyplmask/myplmask or engine friend/enemy handles.
#   G3 no bneutral TPlayer flag — `nation == "neutral"` fallback is a PORT
#      APPROXIMATION retained from the landed viewer set.
#   G4 one global fog grid / interface viewer (slot 0), no per-viewer set.
#   §5 law 4 requires re-resolve on every team-id merge/split and victorystate
#   transition; game.gd must call rebuild_fow() there (exact recs in report).
#
# [U] CAPTURES below are the report's §9 fixed-seed zero-mismatch criteria.
# NONE was executed by this worker; no team matrix, tick or vision value is
# substituted. Owner-authorised donor runs only.

# ─── DEC-U-FOG-TERRITORY — donor-settled labels / [U] telemetry ─────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_fog_territory.md §§1-7.
# STATIC PASS ONLY. Donor binary never executed. NO PARITY CLAIM. Labels/telemetry
# below add NO behaviour, NO FOW write, NO repaint rule, NO rect, NO colour and NO
# threshold. Landed layers (FOG-HUD / FOG-PATCHES / MINIMAP-TAIL / FOW-KNOBS /
# FOW-TINT / TEAMVIS) are untouched — this block only cites them.
#
# [O] CAPTURE RE-KEYS ScanGrid membership but issues ZERO FOW writes (P6 census):
#     _misc_ChangePlayer (miscext.script:894-959) strips counters under the loser
#     (:914), flips TObj.pl (:915-917), adds counters under the winner (:919) and
#     queues gGuiUpdateHighlights.Add (:920). ScanGrid re-key is
#     _unit_ScanGridRemoveUnit (unit.script:3974 -> :3157-3167, OLD pl) and
#     _unit_ScanGridAddUnit (unit.script:3856 -> :3135-3153, NEW pl).
#     EV-FT-ZERO — each FOW writer resolves to ONE non-capture site:
#       FOWBuildFull      -> scenario.script:1862 only
#       SetFOWEnable      -> player.script:477 only
#       ClearFOWPlayers   -> player.script:460 only (via control.script:712-720)
#       AddFOWPlayers     -> player.script:463,472 only
#       AddFOWObjects     -> misc.script:5927 only
#       SetFOWDovFunc     -> player.script:475 only
#     The capture path calls NONE. The next scheduled _update_fog() re-poll
#     (movement / `_fog_tick % 6` / reveal gate) IS the donor recompute. Never add
#     rebuild_fow_full() to any capture/transfer function.
# [O+I] Territory `.owner` repaint and FOW-cell recompute are ENGINE-LAZY downstream
#     of the Add/Remove calls: the only script `.owner` write is the init
#     `gScanGrid[i,j].owner := -1` (serial.script:277); the capture predicate only
#     READS it (miscext.script:970-971,986; unit.script:11624). Add/Remove carry
#     (material, pl), so the repaint is engine-side [I-flagged]. No cell set, no
#     repaint radius and no fog-texture invalidation is recoverable or invented.
# [O-absence -> D] Explored state is RETAINED at script level on capture: no clear
#     on miscext.script:894-959; FOWBuildFull is absent; ClearFOWPlayers fires only
#     on player switch (player.script:460 via control.script:714-716); serial
#     carries scangrid owner/dist with no explored payload (serial.script:2549-2578).
#     The engine channel (sticky vs visible-only, per-player vs global) stays [U]
#     (E-FOGT-b). Never wire an explored clear to the capture flip itself.
# [O] Highlight/keycolor/minimap are exact name-swap laws on capture:
#     winner color recursive SetGameObjectUniform4f(gKeyColor[colorInd], ...)
#     (misc.script:5067-5083 via unit.script:3860) BEFORE the highlight queue
#     (miscext.script:920 -> gui.script:3383-3470 friend/ally/enemy table, walls
#     invisible); minimap blip _misc_UnitUpdateMiniMapPrimitive (gui.script:3472,
#     misc.script:1137-1172) swaps only `.<color>` (and `.sel` if IO-selection is
#     dropped per unit.script:3980-3998); position/size class is static.
#     No EffectHighlight argument beyond the donor literals (gui.script:3372-3377):
#     selection.friend/building/ship, highlight.friend/ally/enemy. No material or
#     highlight applier exists in this file, so no arg is invented here.
# DO NOT TOUCH (landed law, not this pass): DONOR_VISION_BASE/PER_POINT coefficients,
#     rebuild_fow_enable/_fow_viewer_players team law, fogreveal create/remove +
#     rebuild_fow_full (scenario.script:1862 counterpart), los_at/is_visible_at
#     `>0` predicate (control.script:270, gui.script:3479), AIData/Topology mirrors.
# STILL [U] — four fixed-camera + minimap-transect captures below keep their
#     zero-mismatch criteria; NONE was executed by this worker and NO repaint
#     rule / colour / rect is substituted. Provisional `_vision_radius_m` and the
#     `fog_counts > 0` combine stay labelled PORT law until E-FOGT-a terminates.

# ─── DEC-U-CAPTURE-STATE2 §7 items 5-6 — IMPL-CAPTURE-FOW labels / telemetry ────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_capture_state2.md §§5-7
#            (items 5-6) + exact findings. STATIC PASS ONLY. Donor binary never
#            executed. NO PARITY CLAIM. Labels/telemetry ONLY: NO behaviour change,
#            NO FOW write, NO repaint rule, NO rect, NO colour, NO constant wired
#            into the sim. Landed FOG-HUD / FOG-PATCHES / MINIMAP-TAIL / FOW-KNOBS /
#            FOW-TINT / TEAMVIS / FOGTERR blocks above are UNTOUCHED — cited, not
#            rewired.
#
# [O] CAPTURE RE-KEY (§7.5 a/b/c) — the transfer re-keys THREE script tables but
#     writes NO FOW/territory field: ScanGrid remove OLD pl (unit.script:3157-3167
#     via :3974) + add NEW pl (:3135-3153 via :3856); AIData remove/add per
#     processingAI/adviser flags (:3601-3615, :3688-3700); Topology danger/attract
#     deltas by OLD pl (:3250-3283, pre-flip) then changeDanger/changeAttract[NEWpl]
#     (:3171-3205, post-flip). All driven by the TObj.pl flip miscext.script:915-919.
# [O] LIVE-OWNER VISION ATTRIBUTION (§7.5f) — _unit_GetVision
#     (unit.script:11563-11614) returns floor(20 + 4*vision) iff visible AND
#     not bdead AND bbuilt (:11597-11598 gate; coeffs :11567-11571), else 0.
#     ChangePlayer touches NO visual/essential tag, so RADIUS is UNCHANGED and only
#     PL ATTRIBUTION flips with the scangrid key. This file already reads e.player
#     LIVE at poll time (_is_fow_viewer_entity / donor_unit_vision) — DO NOT animate
#     fog or territory here: fog-texture invalidation, gScanGrid.owner repaint and
#     enemy-minimap unveil are ENGINE-SIDE [I-flagged], CS-FOW open, no rule added.
# [O] SELECTION / CTRLGROUP / KEYCOLOR ORDER (§7.5 d/e) — inside
#     RemoveObjFromPlayerCounters, PRE-swap under the loser: IO party only, picked
#     -> gSelectedObjects.Remove + Picked(False) + gui flags (unit.script:3981-3988);
#     then UNCONDITIONALLY ctrlgroupmask>0 -> wipe all 10 gCtrlGroups[pl][i] + mask
#     zero (:3990-3998). Non-IO selection is NOT touched. Winner key colour is
#     applied RECURSIVELY BEFORE the highlight queue: ApplyKeyColorRecursiveChild
#     (unit.script:3860 -> misc.script:5067-5083) then gGuiUpdateHighlights.Add
#     (miscext.script:920-921 -> gui.script:3383-3472, cleared :3569). hud.gd:96-119
#     carries the name-swap; no deselect/highlight code is added or removed here.
# [O-port / PORT RULE G-09] PROTOTYPE LABEL — the port guard-block
#     (game.gd:8354-8363) is a PORT RULE with NO donor counterpart and MUST BE
#     KEPT AFTER the donor protector veto (game.gd:8330-8345); never merge the two
#     scans and never delete the block. Donor capture (miscext.script:963-1185)
#     NEVER reads order_type_guard: the ONLY donor veto is _unit_SearchProtectors
#     + distSqr<protectionradiusSqr (miscext.script:1041-1072; unit.script:4617-4637).
#     This label adds NO code — the live rule stays in game.gd (out of this scope).
# visual_parity_claim = false. SIX [U] register items keep their fixed-seed
#     THREE-RUN ZERO-MISMATCH criteria (CS-VETO / CS-LEDGER / CS-GARRISON /
#     CS-HIDE / CS-FOW / CS-RALLY); NONE executed here, NONE weakened.

# DEC-U-CAPTURE-STATE2 §7.5-6 — read-only labelled data. NO behaviour, NO FOW
# write, NO repaint rule, NO parity claim; the six [U] three-run captures stay open.
const CAPFOW_CAPTURE_TELEMETRY: Dictionary = {
	"cite": "DEC_U_capture_state2.md §§5-7 (items 5-6); miscext.script:894-959,963-1185; unit.script:3135-3205,3250-3283,3601-3615,3688-3700,3980-3998,11563-11614",
	"rekey": {
		"scangrid": "remove OLD pl unit.script:3157-3167 (via :3974); add NEW pl unit.script:3135-3153 (via :3856) — TObj.pl flip miscext.script:915-919",
		"aidata": "remove when processingAI unit.script:3601-3615 / :3965-3966; add post-flip when (processingAI and winner-AI) or (winner-human and adviser) unit.script:3688-3700 / :3853-3854",
		"topology": "danger/attract deltas by OLD pl unit.script:3250-3283 (TopologyRemove, pre-flip); changeDanger/changeAttract[NEWpl] unit.script:3171-3205 (TopologyAdd, post-flip)",
	},
	"vision_attribution": {
		"law": "floor(20 + 4*vision) iff visible AND not bdead AND bbuilt, else 0 — unit.script:11563-11614 (:11567-11571 coeffs, :11597-11598 gate)",
		"radius": "UNCHANGED by ChangePlayer — no visual/essential tag touched (DEC-U-CAPTURE-STATE2 §5.4 [D])",
		"owner": "follows the live scangrid key / TObj.pl; this file reads e.player at poll time (_is_fow_viewer_entity / donor_unit_vision)",
		"repaint_rule": "NONE — fog-texture invalidation / gScanGrid.owner repaint / minimap unveil are ENGINE-SIDE [I-flagged]; CS-FOW open; no rect, cell set or colour invented",
	},
	"selection": {
		"deselect": "IO party ONLY: picked -> gSelectedObjects.Remove + Picked(False) + gui flags (unit.script:3981-3988); non-IO selection NOT touched",
		"ctrlgroup": "UNCONDITIONAL ctrlgroupmask>0 -> wipe all 10 gCtrlGroups[pl][i] + mask zero (unit.script:3990-3998)",
	},
	"order": "winner key colour recursive (unit.script:3860 -> misc.script:5067-5083) BEFORE highlight queue (miscext.script:920-921 -> gui.script:3383-3472, cleared :3569)",
	"guard_block": {
		"label": "PORT RULE G-09 (no donor counterpart) — KEEP after donor veto (game.gd:8354-8363 after :8330-8345); never merge scans; do not delete",
		"donor": "capture path miscext.script:963-1185 never reads order_type_guard; ONLY veto = _unit_SearchProtectors + distSqr<protectionradiusSqr (miscext.script:1041-1072; unit.script:4617-4637)",
	},
	"still_U": "CS-VETO / CS-LEDGER / CS-GARRISON / CS-HIDE / CS-FOW / CS-RALLY — six fixed-seed three-run zero-mismatch captures; none executed or weakened here",
	"visual_parity_claim": false,
}

const TEAMVIS_CAPTURES: Dictionary = {
	"U-T1": {"name": "FFA expansion 4-slot",
		"input": "lobby [0,0,0,0] -> sim [1,2,3,4]; seed S; eliminate 3->2->1 on fixed ticks",
		"zero": "No win stamp while >=2 live non-leavers; final survivor victorystate_int=1, others 2; lose_tick/win_tick identical across 3 runs; win_tick >= last lose_tick",
		"cite": "DEC_U_teams.md:226 (§9 U-T1) + :82-95 (§2)"},
	"U-T2": {"name": "2v2 shared-team win",
		"input": "lobby [1,1,2,2] -> sim [1,1,2,2]; seed S; wipe team B on fixed ticks",
		"zero": "BOTH team-A slots stamp win on the SAME tick; ticks identical across 3 runs; no win before the last B-slot loss",
		"cite": "DEC_U_teams.md:227 (§9 U-T2) + :95 (§2)"},
	"U-T3": {"name": "2v1 menu shape [0,0,1]",
		"input": "3-slot lobby [0,0,1]; seed S; kill slot 2 then slot 1",
		"zero": "No win after slot-2 death (two distinct live teams); slot 0 alone wins after slot-1 death; any win with 2 live teams = fail",
		"cite": "DEC_U_teams.md:228 (§9 U-T3) + :96 (§2)"},
	"U-T4": {"name": "Leaver exclusion",
		"input": "2v2 seed S; _surrender team-A slot 0 with units alive",
		"zero": "Leaver keeps lose, never flips to win; surviving team-B slots stamp win same tick; identical across 3 runs",
		"cite": "DEC_U_teams.md:229 (§9 U-T4) + miscext2.script:3796-3811"},
	"U-T5": {"name": "Trigger set-enemy does NOT split win team",
		"input": "2v2 seed S + trigger engine; action 18 between team-A slots; wipe team B",
		"zero": "Both A slots still win same tick (team ids unchanged) while mutually hostile at targeting layer; collapse = fail",
		"cite": "DEC_U_teams.md:230 (§9 U-T5) + scenario.script:2175-2197"},
	"U-T6": {"name": "Trigger set-ally merges win team",
		"input": "FFA 3-slot seed S; action 19 between slots 0,1; wipe slot 2",
		"zero": "Slots 0+1 win same tick (merged team1); without trigger only the survivor wins (U-T1 control)",
		"cite": "DEC_U_teams.md:231 (§9 U-T6) + scenario.script:2202"},
	"U-T7": {"name": "Shared vision follows sim team",
		"input": "2v2 seed S, FOW on; ally scout vs FFA foe scout vs bneutral mate",
		"zero": "Reveal bitmaps equal across 3 runs; FFA leak or neutral leak = fail; port FOW stays stubbed until this passes",
		"cite": "DEC_U_teams.md:232 (§9 U-T7) + player.script:453-478"},
	"U-T8": {"name": "bneutral + slot-0 exception",
		"input": "Mission-shape fixture: slot 0 + neutral mate",
		"zero": "Slot 0 gains no vision from the neutral mate; a non-zero mate does",
		"cite": "DEC_U_teams.md:233 (§9 U-T8) + player.script:470-472"},
}

# DEC-U-FOG-TERRITORY §5 — four fixed-camera + minimap-transect [U] captures.
# Labels/telemetry only: NONE executed by this worker; each keeps its exact
# zero-mismatch termination; no rule/cell set/rect/colour is asserted until its
# three identical-seed runs match. No parity claim.
const FOGTERR_CAPTURES: Dictionary = {
	"E-FOGT-a": {"name": "Which FOW + territory cells recompute on capture",
		"input": "seed S; lone viewer + victim barracks; W-E GetFOWLOSData transect (1.0-unit steps, ±(res+8)) + gScanGrid.owner 3x3 neighbourhood, tick-before -> tick-after -> +3 ticks, plus one FOWBuildFull+settle control",
		"zero": "3 runs identical; report first tick LOS transect reflects new attribution and first tick .owner neighbourhood does; any script-tick-synchronous rect must show zero off-rect cells, else verdict = lazy engine recompute and port invalidates no rect on capture",
		"cite": "DEC_U_fog_territory.md:68 (§5 E-FOGT-a) + :34-40 (§1)"},
	"E-FOGT-b": {"name": "Explored retention for the new owner",
		"input": "seed S; viewer A reveals far probe cell, (i) capture the revealing unit's post to player B and dump probe as A and as B via _control_SetPlayer round-trip (log both legs), (ii) walk winner's viewers away + FOWBuildFull, dump probe, (iii) save+reload, dump probe",
		"zero": "3 runs identical; verdict must state retained-vs-cleared per leg with zero flapping cells, else stays [U]; never wire a clear to the capture flip",
		"cite": "DEC_U_fog_territory.md:69 (§5 E-FOGT-b) + :51-53 (§3)"},
	"E-FOGT-c": {"name": "Combine/occlusion after the flip",
		"input": "seed S; two-viewer overlap with victim as one contributor pre-capture; pair-transect + perpendicular bisector before/after + FOWBuildFull+settle; then interpose hill/forest/wall between captured contributor and far transect half (control: same seed, no interposition)",
		"zero": "3 runs identical; union-shape match for the pair AND cell-identical control-vs-interposition (pure-disc) or a fitted blocker rule predicting a second rotated transect with zero mismatches",
		"cite": "DEC_U_fog_territory.md:70 (§5 E-FOGT-c) + :49 (§2)"},
	"E-FOGT-d": {"name": "Highlight/keycolor/minimap repaint on capture",
		"input": "seed S; fixed-camera 3-run capture of a building + a unit; per tick dump EffectHighlight mat/visibility args, gKeyColor uniform index (object + one child), minimap primitive pl2x2|pl3x3.<color>[.sel] name + position, gSelectedObjects/ctrlgroup membership, plus a fixed minimap-viewport transect (donor blip row across the victim's cell, 1-px steps) before/after",
		"zero": "3 runs identical; assert name-swap .<oldColor>->.<newColor> with static position, highlight friend->enemy flip on the next GUI tick, selection dropped iff IO-party; any pixel/tick deviation fails the item",
		"cite": "DEC_U_fog_territory.md:71 (§5 E-FOGT-d) + :55-60 (§4)"},
}

# ─── DEC-U-ENDGAME-FOW — donor-settled labels / [U] telemetry ───────────────────
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_fow.md §§1-7.
# STATIC PASS ONLY. Donor binary never executed. NO PARITY CLAIM. Labels/telemetry
# below add NO behaviour, NO FOW write, NO hook, NO cadence, NO threshold. Landed
# blocks (FOG-HUD / FOG-PATCHES / MINIMAP-TAIL / FOW-KNOBS / FOW-TINT / TEAMVIS /
# FOGTERR / CAPFOW) are UNTOUCHED — cited, not rewired.
#
# LAZY RE-RESOLVE LAW [O] — every victory/defeat/team path STAMPS ONLY: full
# procedure reads (P8, §3) show ZERO immediate FOW re-resolve on any of them.
# Vision flips at the NEXT of exactly four donor callers (§1/§2):
#   R1 _control_SetPlayer ....... control.script:712-720 — viewer switch (init +
#      manual UI/spectator), event-driven, NOT per-tick; minimap clear FIRST,
#      vision SECOND, selection/minimap last.
#   R2 diplomacy bupdateally tail scenario.script:3302-3306 — end of trigger
#      evaluation, ONLY if the flag was set by actions 18/19/20
#      (:2196/:2223/:2248); UpdateFOW(plIO) then UpdateMiniMap(False).
#   R3 balloon upgrade .......... player.script:1910-1913 (self) / :1915-1921
#      (allied mirror); upgrade-apply event, shares the :456 victory kill-switch.
#   R4 save-compat gen .......... initmapgen.inc:272-277 (<53) / :280-285 (<89),
#      once per generation, NEVER a live-game victory hook.
# 8-hit UpdateFOW DScript census (P6/EV-D) — 1 def + 1 comment + 6 live call sites:
#   def player.script:451-478; callers control.script:716, scenario.script:3305,
#   player.script:1913/:1921, initmapgen.inc:276/:285. Zero hits in miscext2,
#   progress.inc, serial.script, nothing.inc [O-absence]. Only SetFOWEnable writer
#   is player.script:477. The engine re-polls the LAST viewer set + enable flag
#   each frame; a stamp alone changes NO pixels until the next R-call rebuilds
#   the set/flag. There is no hidden per-frame UpdateFOW.
#
# ZERO-IMMEDIATE-HOOK CENSUS [O] (§3) — W1 auto-defeat (progress.inc:124-135),
#   W5 team-win (miscext2.script:3810-3842), W8/W9 surrender (:3849-3896),
#   W10/W11 trigger win/lose (scenario.script:2995-3065), team-id mutations
#   (player.script:2177-2271), mask-only diplomacy (:2175-2197/:2225-2249),
#   spectator purge W13 (initmapgen.inc:256-264), init clears W12/W14
#   (player.script:110-117, initmaphistoricalbattle.inc:124-129), and the global
#   tick + peacetime path (nothing.inc:646-695): ALL write ZERO UpdateFOW /
#   ClearFOWPlayers / AddFOWPlayers / SetFOWEnable / SetFOWDovFunc / FOWBuildFull
#   / UpdateMiniMap* calls. Minimap death-dots ride the generic per-tick primitive
#   path, never the stamp; FOWBuildFull fires only at scenario.script:1862.
#
# NO IMPLEMENTED HOOK — this worker adds NO rebuild_fow_full() to any stamp path;
#   game.gd is OUT OF SCOPE and the donor has NO transition hook (§5 items 1-3 are
#   game.gd-only recommendations, NOT landed here). This file's per-tick
#   rebuild_fow_enable() at _update_fog() top is the EAGER cadence SUBSTITUTION,
#   labelled PORT APPROXIMATION — NOT the donor hook, and NOT gated behind a stamp
#   flag (§5 item 4; do not throttle it to fake laziness). The V3 terminal gate
#   (rebuild_fow_enable / _is_terminal_victory) is KEPT: W8/W9 win->lose overwrites
#   and W13's no-time lose both trip it on the next rebuild; any same-frame
#   timeliness would come from a game.gd hook, NOT from this predicate (§5 item 5).
#   The terminal-mate skip and _is_fow_viewer_entity dead/finished/hidden gates are
#   KEPT as labelled PORT APPROXIMATION / _unit_GetVision ports (§5 item 6).
# The 8 §6 [U] captures below stay OPEN with their exact zero-mismatch criteria;
#   NONE was executed by this worker. NO value, Hz, tick, threshold or VA invented.

const ENDGAME_FOW_CAPTURES: Dictionary = {
	"U-F1": {"name": "Re-resolve latency after W1 defeat (core hook)",
		"static": "Donor: NO inline refresh (§3-1); next R is manual viewer switch (R1) or diplomacy/balloon event. Port: eager per-tick rebuild (§4).",
		"input": "1v1 skirmish, seed S, FOW on. Kill P1 last peasant/center at fixed tick T (port harness). Dump viewer-0 fow_enabled + viewer set + los_at transect + minimap blip row at T-1, T, T+1, T+5. Control leg: same seed, no kill.",
		"zero": "3 runs identical bitmaps/transects/primitives. DONOR arm: fog STALE (los_at=0 in dead zone, blip present) at T through next R1 — same-tick full-vision = invented hook. PORT arm (after §5-1 lands): viewer grid off EXACTLY from stamp tick; stale one extra tick = hook missing. Until both arms terminate, no cadence claimed.",
		"cite": "DEC_U_endgame_fow.md:119 (§6 U-F1) + §3-1 progress.inc:124-135"},
	"U-F2": {"name": "Re-resolve latency after W5 team-win",
		"static": "Donor: NO inline refresh (§3-2); W1+W5 same frame collapse to one later R-call.",
		"input": "2v2 seed S. Wipe team B on fixed ticks. Dump both team-A viewers (donor: interface viewer; port: slot-0 proxy) + minimap at last-kill tick and next R1.",
		"zero": "Same dual-arm criterion as U-F1. Both A slots win same tick (DEC-U-ENDGAME-STAMP U-S2 control); vision flips for BOTH in the same R-call — split-frame flip = fail.",
		"cite": "DEC_U_endgame_fow.md:120 (§6 U-F2) + §3-2 miscext2.script:3810-3842"},
	"U-F3": {"name": "Surrender double-stamp ordering (lose + crown, zero intermediate refresh)",
		"static": "Donor: lose then CheckEndGame in the same call (§3-3), no refresh between.",
		"input": "2v2 seed S. _surrender team-A slot 0 with units alive at fixed tick. Dump leaver + survivor viewers + minimap at T, T+1.",
		"zero": "Leaver 2, survivors 1, survivor gametime UNCHANGED by later passes (first-write-wins); single vision transition (no lose-frame then win-frame); 3 runs identical. Any intermediate full-vision-only-leaver frame = invented refresh.",
		"cite": "DEC_U_endgame_fow.md:121 (§6 U-F3) + §3-3 miscext2.script:3849-3896"},
	"U-F4": {"name": "Trigger win/lose with no diplomacy (R2 absent)",
		"static": "Donor: W10/W11 set NO bupdateally (§3-4); mission trigger engine cadence = per-fire (scenario.inc:71-77).",
		"input": "Mission-harness future: fire endgame_win on myplind with NO diplomacy action in the same trigger; dump bupdateally flag + UpdateFOW call log + transect at fire tick and next trigger tick.",
		"zero": "Flag stays False; NO UpdateFOW(plIO) in the fire evaluation; vision flips only at a LATER R1/R2/R3. Any inline refresh = fail. Until the trigger engine lands, port asserts nothing here (DEC-U-ENDGAME-STAMP U-S8 retained).",
		"cite": "DEC_U_endgame_fow.md:122 (§6 U-F4) + §3-4 scenario.script:2995-3065"},
	"U-F5": {"name": "Trigger merge + win same evaluation (action 19 + W10/W11 or W5)",
		"static": "Donor: MakeAlly (real team merge at scenario.script:2202) + R2 tail same evaluation (:2223 -> :3302-3306), stamp elsewhere in the same evaluation.",
		"input": "FFA 3-slot seed S + future trigger engine: fire action 19 between slots 0,1, then wipe slot 2 (or fire W10). Log team ids + bupdateally + UpdateFOW order.",
		"zero": "Merge precedes the :3302 tail (flag True, UpdateFOW(plIO) + UpdateMiniMap(False) logged AFTER the team write); slots 0+1 win same tick; 3 runs identical. Tail-before-merge = ordering bug.",
		"cite": "DEC_U_endgame_fow.md:123 (§6 U-F5) + §3-5 player.script:2177-2271"},
	"U-F6": {"name": "Mask-only diplomacy refresh changes nothing (actions 18/20)",
		"static": "Donor: mask/engine-handles only, team UNCHANGED, but R2 refresh fires (§3-6).",
		"input": "2v2 seed S + future trigger engine: fire action 18 between team-A mates, wipe team B. Dump viewer set + transect before/after the diplomacy fire and after the wipe.",
		"zero": "Viewer set IDENTICAL across the 18-fire (only enable/primitive timestamps move); both A slots still win same tick post-wipe; FFA-leak or neutral-leak = fail (DEC-U-TEAMS U-T5/U-T7 controls).",
		"cite": "DEC_U_endgame_fow.md:124 (§6 U-F6) + §3-6 scenario.script:2175-2249"},
	"U-F7": {"name": "Spectator purge -> init R1 ordering",
		"static": "Donor: W13 no inline refresh (§3-7); init SetPlayer loop later in the same generation (initmapgen.inc:204-225).",
		"input": "Init fixture: 1 spectator + 2 humans, seed S. Dump purge slot victorystate/gametime at gen end + viewer-0 set + transect + minimap at first playable tick.",
		"zero": "Purge slot 2 with gametime == 0.0 (no-time write, DEC-U-ENDGAME-STAMP U-S6); viewer set excludes the purged slot from tick 0; identical across 3 runs. Any invented purge tick = fail.",
		"cite": "DEC_U_endgame_fow.md:125 (§6 U-F7) + §3-7 initmapgen.inc:256-264"},
	"U-F8": {"name": "Balloon x victory kill-switch precedence + minimap tail",
		"static": "Donor: same :456 switch (balloon OR terminal => off); geology upgrade (player.script:1905-1909) refreshes MINIMAP ONLY (UpdateMiniMap(True), no FOW) — the contrast case.",
		"input": "1v1 seed S, FOW on: (a) balloon the interface viewer, then W1-defeat it; (b) separate run: geology upgrade only. Dump bballoon/victorystate/fow_enabled + transect + minimap per tick.",
		"zero": "(a) fow_enabled False from the balloon tick and STAYS False across the later terminal stamp (no double transition); (b) geology changes minimap, fow_enabled UNCHANGED. Any FOW flip on geology = fail.",
		"cite": "DEC_U_endgame_fow.md:126 (§6 U-F8) + §3/§2 player.script:1910-1921"},
}

const ENDGAME_FOW_TELEMETRY: Dictionary = {
	"cite": "DEC_U_endgame_fow.md §§1-7; player.script:451-478; control.script:712-720; scenario.script:3302-3306; player.script:1910-1921; initmapgen.inc:272-285",
	"lazy_law": "Every victory/defeat/team path stamps only; ZERO immediate FOW re-resolve (§3 skip census). Vision flips at the next R1/R2/R3/R4 call, not on the stamp.",
	"re_resolve_callers": {
		"R1": "control.script:712-720 — viewer switch (init + manual), event-driven, not per-tick",
		"R2": "scenario.script:3302-3306 — bupdateally tail, only if actions 18/19/20 set the flag (:2196/:2223/:2248)",
		"R3": "player.script:1910-1913 self / :1915-1921 allied mirror — balloon upgrade, shares :456 kill-switch",
		"R4": "initmapgen.inc:272-277 (<53) / :280-285 (<89) — save-compat gen, once, never a live victory hook",
	},
	"updatefow_census": "8 hits: def player.script:451-478 + comment + 6 call sites (control.script:716, scenario.script:3305, player.script:1913/1921, initmapgen.inc:276/285); zero elsewhere [O-absence]",
	"zero_hook_census": "W1/W5/W8/W9/W10/W11/team-mutation/mask-diplomacy/purge/init-clear/global-tick paths all write ZERO UpdateFOW/ClearFOWPlayers/AddFOWPlayers/SetFOWEnable/SetFOWDovFunc/FOWBuildFull/UpdateMiniMap*; FOWBuildFull only scenario.script:1862",
	"implemented_hook": "NONE — no rebuild_fow_full() added to any stamp path; game.gd out of scope; donor has no transition hook",
	"per_tick_cadence": "PORT APPROXIMATION — rebuild_fow_enable() at _update_fog() top is the eager cadence substitution, NOT the donor hook; not gated behind a stamp flag",
	"v3_gate": "KEPT — terminal victorystate (<> none) disables FOW (player.script:456, dmscript.global:777-779); W8/W9 win->lose and W13 no-time lose trip it on the next rebuild",
	"captures": ENDGAME_FOW_CAPTURES,
	"parity_claim": false,
}

# ─── DEC-U-ENDGAME-STAMP §7 items 6-7 — IMPL-ENDGAME-STAMP-FOG labels/telemetry ─
# Authority: docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_stamp.md §§1-8,
#            §7 port change list, world3d_fog.gd items 6-7 ONLY (game.gd items 1-5
#            are OUT OF SCOPE for this worker).
# STATIC PASS ONLY. Donor binary never executed. NO PARITY CLAIM. Labels/telemetry
# below add NO behaviour, NO FOW write, NO hook, NO stamp, NO cadence, NO value and
# NO threshold. All landed blocks (FOG-HUD / FOG-PATCHES / MINIMAP-TAIL / FOW-KNOBS /
# FOW-TINT / TEAMVIS / FOGTERR / CAPFOW / ENDFOW) are UNTOUCHED — cited, not rewired.
#
# [O] STAMP CENSUS — 14 victorystate / victorystategametime WRITE statements across
#     7 donor files (§1 table W1-W14; reads at miscext2.script:3674-3680/3696-3699/
#     3728-3756, dmscript.global:777-779 and classes.script:3684-3685 are NOT writes).
#     Every guarded stamp writes victorystate FIRST, then victorystategametime iff 0
#     (§4 field order). Exact sites + first-transition / time gates (§3):
#       W1  progress.inc:130-132                 lose; STATE iff bPrevExists True->False edge; TIME iff 0
#       W2  miscext2.script:3053-3054            win, slot-0 console; NO time; unguarded + exit — DO NOT PORT
#       W3  miscext2.script:3057-3058            lose, slot-0 console; NO time; unguarded + exit — DO NOT PORT
#       W4  miscext2.script:3109-3110            none/0 clear, slot-0 scenario-start — DO NOT PORT
#       W5  miscext2.script:3813-3818            win, per TEAM; STATE iff <>win (lose->win flip); TIME iff 0
#       W6  miscext2.script:3824-3826            LAN-human win flip — EXCLUDE (§6)
#       W7  miscext2.script:3832-3834            LAN-human lose fill — EXCLUDE (§6)
#       W8  miscext2.script:3859-3861            surrender server lose; NO state guard (overwrites win); TIME iff 0
#       W9  miscext2.script:3891-3893            surrender offline lose; NO state guard; TIME iff 0
#       W10 scenario.script:2996-2998           trigger win myplind; NO state guard; TIME iff 0
#       W11 scenario.script:3050-3052           trigger lose myplind; NO state guard; TIME iff 0
#       W12 player.script:111-112               init none/0 clear, unconditional
#       W13 initmapgen.inc:263                  spectator purge lose; NO time write; unguarded
#       W14 initmaphistoricalbattle.inc:127-128 historical clear none/0, unconditional
#     TIME is first-write-wins everywhere (§3.1 `= 0` precedes GetGameTime, except the
#     three no-time writes W2/W3/W13 and the clears). STATE is edge/inequality-gated
#     ONLY at W1 (bPrevExists) and W5 (<> win); W8/W9/W10/W11 overwrite unconditionally
#     (§3.2). Two INDEPENDENT logics are required — one boolean cannot reproduce W5's
#     lose->win flip or W10's win->lose overwrite. game.gd owns those gates (§7 items
#     1-4, OUT OF SCOPE here); this file only reads the resulting state at rebuild time.
#
# [O] STAMP WRITES NO FOW FIELD (§5.1, corroborates DEC-U-ENDGAME-FOW §§1-3) —
#     W1/W5/W8/W9/W10/W11 (and W2/W3/W13) contain ZERO UpdateFOW / ClearFOWPlayers /
#     AddFOWPlayers / SetFOWEnable / SetFOWDovFunc / FOWBuildFull / UpdateMiniMap*
#     calls. Vision flips ONLY at the NEXT _player_UpdateFOW (player.script:451-478),
#     i.e. R1 control.script:712-720 / R2 scenario.script:3302-3306 /
#     R3 player.script:1910-1921 / R4 initmapgen.inc:272-285. R1-R4 lazy paths are
#     ALREADY LABELLED in the DEC-U-ENDGAME-FOW block above — CORROBORATED, NOT
#     re-added. NO rebuild_fow_full() is added to any stamp path: §7 item 5 is a
#     game.gd-only recommendation, NOT landed in this file. rebuild_fow_enable() at
#     _update_fog() top stays the labelled eager PORT APPROXIMATION, not a donor hook.
#
# [O] §7 ITEM 6 — rebuild_fow_enable / _is_terminal_victory: KEEP the V3 gate
#     unchanged (`<> none`, player.script:456 + enum none/win/lose = 0/1/2 at
#     dmscript.global:777-779). W8/W9 unconditional win->lose overwrites AND W13's
#     no-time lose BOTH trip this gate on the NEXT rebuild; same-frame timeliness would
#     come ONLY from the item-5 game.gd hook (OUT OF SCOPE / NOT landed here), NEVER
#     from this predicate. Gate KEPT; no behaviour change.
# [O] §7 ITEM 7 — _fow_viewer_players / _is_fow_viewer_entity: KEEP both. (a) terminal
#     mates are skipped from the viewer set; donor adds them unconditionally
#     (player.script:463-473 has NO terminal check inside the loop), harmless while
#     their units are dead (W1 kill precedes the stamp) — labelled PORT APPROXIMATION.
#     (b) dead/finished/hidden gates port _unit_GetVision's not-bdead/bbuilt/visible
#     gates (unit.script:11563-11614) — KEPT, cite added. Neither alters the stamp law.
#
# LAN / NET EXCLUDED (§6 — OUT OF SCOPE): W6/W7 lanid>0 human flips, trigger net
#     actions 90-98 (_net_* gates, scenario.script:3196-3280), LanServerSendResults /
#     GetFirstLeaver / LanCloseSessionSetScores (miscext2.script:3660-3760), the
#     surrender server/client arms + LanSendParser (miscext2.script:3854-3887), and
#     WritePeaceTime/WriteFreeList broadcasts: cited ONLY as exclusion boundaries;
#     none is specified, audited or changed here.
#
# EIGHT [U] CAPTURES (§8, U-S1..U-S8) keep their fixed-seed THREE-RUN ZERO-MISMATCH
#     criteria verbatim in ENDGAME_STAMP_CAPTURES below; NONE executed by this worker,
#     NONE weakened. NO stamp, cadence, tick, threshold or value invented. Same seed
#     convention as §8: map land/med/plains, peacetime 0, AI passive unless stated.

const ENDGAME_STAMP_CAPTURES: Dictionary = {
	"U-S1": {"name": "Stamp-tick granularity (GetGameTime vs tick)",
		"static": "Field order closed (§4: state first, time iff 0); tick quantisation open",
		"input": "1v1 skirmish, seed S, land/med/plains, peacetime 0, AI passive: kill P1 last peasant/center at fixed tick T (port harness). Log lose_tick (W1) + win_tick (W5) + both gametime values.",
		"zero": "3 runs identical lose_tick/win_tick/gametime triple; win_tick >= lose_tick (same frame allowed per §2.2); any win_tick < lose_tick = ordering bug. No invented timestamp.",
		"cite": "DEC_U_endgame_stamp.md:220 (§8 U-S1)"},
	"U-S2": {"name": "winnerteam init on the empty path",
		"static": "Donor var zero-init => >0 guard false [D] §2.4; port -1 equivalent unproven at runtime",
		"input": "1v1, seed S, no kills for N ticks: assert NO stamp and NO LAN send. Then FFA 4-slot wipe in fixed order.",
		"zero": "No-write phase: zero victorystate_int/gametime deltas across 3 runs. Wipe phase: final survivor 1, rest 2, identical ticks. Any win with >=2 live teams = fail.",
		"cite": "DEC_U_endgame_stamp.md:221 (§8 U-S2)"},
	"U-S3": {"name": "lose->win flip vs win->lose overwrite precedence",
		"static": "W5 flips lose->win (<> win); W8/W9/W11 overwrite anything (incl. win->lose) [O] §3",
		"input": "2v2 seed S: (a) wipe team B -> both A win; then surrender one A slot -> that slot lose, mate stays win. (b) Trigger-harness future: W10 win then W9 surrender same slot.",
		"zero": "(a) Post-surrender: leaver 2, mate 1, gametime of mate UNCHANGED (first-write-wins); (b) surrender keeps original win tick in gametime. Any time overwrite = fail.",
		"cite": "DEC_U_endgame_stamp.md:222 (§8 U-S3)"},
	"U-S4": {"name": "FOW re-resolve timing after each stamp (the DEC-U-TEAMS hook)",
		"static": "Donor lazy (UpdateFOW at next SetPlayer/diplomacy/balloon) [O] §5; port eager hook proposed §7-5 (game.gd, NOT landed here)",
		"input": "1v1 seed S with FOW on: stamp lose (W1) on P1; dump viewer fow_enabled + viewer set + los_at the same tick and next tick.",
		"zero": "Post-hook: viewer-0 grid off (los_at = 1 everywhere) EXACTLY from the stamp tick; 3 runs identical bitmaps. Stale fog one extra tick = hook missing. Donor arm stays lazy (R1-R4); no cadence claimed.",
		"cite": "DEC_U_endgame_stamp.md:223 (§8 U-S4)"},
	"U-S5": {"name": "Surrender spectator guard + client no-stamp arm",
		"static": "Donor :3852-3853 skips bleave for spectators; client sends parser, no local write [O] §2.5",
		"input": "Spectator-slot fixture (W13 shape): call _surrender on the spectator slot.",
		"zero": "bleave stays False, state stays lose from purge (no double write), gametime unchanged. Any flip to win by later W5 = fail (leaver exclusion).",
		"cite": "DEC_U_endgame_stamp.md:224 (§8 U-S5)"},
	"U-S6": {"name": "W13 no-time purge vs guarded stamps",
		"static": "W13 writes NO gametime [O] §2.7; all other runtime stamps gate iff 0",
		"input": "Init fixture with 1 spectator + 2 humans, seed S: read purge slot victorystate/gametime at gen end, then run 1 kill.",
		"zero": "Purge slot: 2 with gametime == 0.0 until/unless a LATER guarded stamp (W6-excluded in 1:1 -> stays 0.0); identical across 3 runs. Any invented purge tick = fail.",
		"cite": "DEC_U_endgame_stamp.md:225 (§8 U-S6)"},
	"U-S7": {"name": "bneutral/diplomacy vs win team (mask-only actions)",
		"static": "Actions 18/20 mask-only, 19 merges (DEC-U-TEAMS §4, scenario:3302-3306 refresh) — win law reads team only",
		"input": "2v2 seed S + future trigger engine: fire action 18 between team-A mates, wipe team B.",
		"zero": "Both A slots still win same tick (team ids unchanged) while mutually hostile at targeting layer; vision set UNCHANGED by the mask edit (only bupdateally refresh). Collapse = fail.",
		"cite": "DEC_U_endgame_stamp.md:226 (§8 U-S7)"},
	"U-S8": {"name": "net_IsOffline trigger blackout after interface terminal",
		"static": "Condition 24 requires myplind victorystate = none (scenario:1686-1688) [O]",
		"input": "Mission-harness future: fire W10 win on myplind, then evaluate an IsOffline-gated trigger next tick.",
		"zero": "Second trigger does NOT fire (blackout); 3 runs identical. Firing = gate bug. Until the trigger engine lands, port asserts nothing here.",
		"cite": "DEC_U_endgame_stamp.md:227 (§8 U-S8)"},
}

const ENDGAME_STAMP_FOG_TELEMETRY: Dictionary = {
	"cite": "DEC_U_endgame_stamp.md §§1-8 (§7 items 6-7); progress.inc:124-135; miscext2.script:3052-3058,3109-3110,3810-3842,3849-3896; scenario.script:2995-3065; player.script:110-124,451-478; initmapgen.inc:256-264; initmaphistoricalbattle.inc:124-129; dmscript.global:777-779",
	"stamp_census": "14 victorystate/victorystategametime writes W1-W14 across donor files [O]; reads are NOT writes. State first, time iff 0 (§4).",
	"first_transition_gates": "STATE gated ONLY at W1 (bPrevExists True->False) and W5 (<>win lose->win flip); W8/W9/W10/W11 overwrite unconditionally (§3.2)",
	"time_gate": "victorystategametime first-write-wins: `= 0` before GetGameTime everywhere except clears and the three no-time writes W2/W3/W13 (§3.1)",
	"stamp_writes_no_fow": "[O] §5.1 — all stamp paths write ZERO UpdateFOW/ClearFOWPlayers/AddFOWPlayers/SetFOWEnable/SetFOWDovFunc/FOWBuildFull/UpdateMiniMap*; vision flips at the NEXT _player_UpdateFOW (player.script:451-478)",
	"lazy_calls_corroborated": "R1 control.script:712-720 / R2 scenario.script:3302-3306 / R3 player.script:1910-1921 / R4 initmapgen.inc:272-285 — already labelled by DEC-U-ENDGAME-FOW; corroborated here, NOT re-added",
	"implemented_hook": "NONE — §7 item 5 is a game.gd-only recommendation, NOT landed here; no rebuild_fow_full() on any stamp path",
	"v3_gate": "KEPT unchanged — terminal victorystate <> none disables FOW (player.script:456; enum dmscript.global:777-779); W8/W9 win->lose and W13 no-time lose both trip it on the next rebuild; timeliness would need the out-of-scope game.gd hook, NOT this predicate",
	"viewer_set": "KEPT as labelled PORT APPROXIMATION — terminal mates skipped (donor player.script:463-473 has no terminal check); harmless while units are dead (W1 kill precedes stamp)",
	"entity_filter": "KEPT — dead/finished/hidden port _unit_GetVision not-bdead/bbuilt/visible (unit.script:11563-11614); cite added, no behaviour change",
	"lan_excluded": "§6 OUT OF SCOPE — W6/W7 lanid>0 flips, net actions 90-98, Lan* results/scores, surrender net arms, WritePeaceTime/WriteFreeList; cited only as exclusion boundaries",
	"captures": ENDGAME_STAMP_CAPTURES,
	"parity_claim": false,
}

const Data = preload("res://scripts/data.gd")

# Verbatim from app/scripts/world.gd:2251-2255 (port state encoding).
# [U] PORT APPROXIMATION (DEC-U-FOW-TINT §6.10, F1-MINI-TINT-TERRAIN): no donor
# RGBA / threshold / blend is readable; no FOWColor or CriticalColor value is
# used here. Do not re-label these port numbers as donor facts.
const ALPHA_UNEXPLORED: float = 0.78
const ALPHA_EXPLORED: float = 0.30
const ALPHA_VISIBLE: float = 0.0
# PORT-SIDE, no donor source: lift the overlay a few cm above the sampled
# terrain height so it does not z-fight with the top quads.
const FOG_Y_OFFSET: float = 0.03
# Donor _unit_GetVision coefficients — unit.script:11567-11571 [O] (resolved).
const DONOR_VISION_BASE: float = 20.0
const DONOR_VISION_PER_POINT: float = 4.0
# gc_properties_stringtag_fogreveal = 109 — dmscript.global:1439 [O].
const DONOR_FOGREVEAL_TAG: int = 109

var game = null
# Public: HUD minimap reads these (contract V73_ATOMIC_CONTRACT.md:15,24).
var fog_explored: PackedByteArray = PackedByteArray()
var fog_vis: PackedByteArray = PackedByteArray()
var fog_counts: PackedInt32Array = PackedInt32Array()

var _map_w: int = 0
var _map_h: int = 0
var _tile_m: float = 2.0
var _built: bool = false
var _fog_timer: float = 0.0
var _fog_tick: int = 0
var _fog_last_pos: Dictionary = {}
var _fog_unit_count: int = 0
var _tile_alpha: PackedFloat32Array = PackedFloat32Array()
# DEC-U §1.2 tag-109 fogreveal objects: [{px, pz, dx, tag}] in world metres.
var fog_reveals: Array = []
# DEC-U §1.3 mirrors of SetFOWEnable and the sharing viewer-player set.
var _fow_enabled: bool = false
var _fow_viewers: Array = []

var _overlay: MeshInstance3D = null
var _overlay_mesh: ArrayMesh = null
var _fog_vertices: PackedVector3Array = PackedVector3Array()
var _fog_uvs: PackedVector2Array = PackedVector2Array()
var _fog_indices: PackedInt32Array = PackedInt32Array()
var _fog_colors: PackedColorArray = PackedColorArray()


func bind(g) -> void:
	C3Log.info("fog", "bind begin game_null=%s" % str(g == null))
	game = g
	if game == null:
		C3Log.warn("fog", "bind SKIP game is null")
		return
	_map_w = int(game.get("MAP_W"))
	_map_h = int(game.get("MAP_H"))
	if _map_w <= 0 or _map_h <= 0:
		C3Log.warn("fog", "bind SKIP bad grid w=%d h=%d; no usable MAP_W/MAP_H" % [_map_w, _map_h])
		push_error("world3d_fog: game has no usable MAP_W/MAP_H")
		return
	C3Log.info("fog", "bind grid w=%d h=%d tiles=%d" % [_map_w, _map_h, _map_w * _map_h])
	_tile_m = float(Data.TILE_M)
	var n: int = _map_w * _map_h

	# Mirror game-owned arrays when present and correctly sized (the stub game
	# in t_fog3d.gd:40-48 pre-fills them); otherwise start clean like 2D bind()
	# at world.gd:333-335.
	var src_exp = game.get("fog_explored")
	if src_exp is PackedByteArray and (src_exp as PackedByteArray).size() == n:
		fog_explored = (src_exp as PackedByteArray).duplicate()
	else:
		fog_explored = PackedByteArray()
		fog_explored.resize(n)
	var src_vis = game.get("fog_vis")
	if src_vis is PackedByteArray and (src_vis as PackedByteArray).size() == n:
		fog_vis = (src_vis as PackedByteArray).duplicate()
	else:
		fog_vis = PackedByteArray()
		fog_vis.resize(n)
	fog_counts = PackedInt32Array()
	fog_counts.resize(n)
	_tile_alpha = PackedFloat32Array()
	_tile_alpha.resize(n)

	_fog_timer = float(Data.FOG_INTERVAL)
	_fog_tick = 0
	_fog_last_pos.clear()
	_fog_unit_count = 0
	# DEC-U §1.3 — _control_SetPlayer order: UpdateFOW before any pick/HUD draw
	# (control.script:712-720). Rebuilt again at each _update_fog() tick so live
	# balloon/victory/team changes are honoured without another bind().
	rebuild_fow_enable()
	C3Log.debug("fog", "bind fow_enabled=%s viewers=%d occlusion=none combine=fog_counts>0 vision_base=%.1f per=%.1f" % [str(_fow_enabled), _fow_viewers.size(), DONOR_VISION_BASE, DONOR_VISION_PER_POINT])
	_built = _build_overlay()
	if not _built:
		C3Log.warn("fog", "bind SKIP overlay build failed grid=%dx%d" % [_map_w, _map_h])
		return
	for i in n:
		_tile_alpha[i] = _alpha_for(i)
		_set_tile_color(i, _tile_alpha[i])
	_refresh_mesh()
	_update_fog()


func sync(dt: float) -> void:
	if game == null or not _built:
		return
	# 2D gates the recount on FOG_INTERVAL (world.gd:833-836, :336). dt is
	# sim-agnostic; this accumulator keeps the same cadence.
	_fog_timer -= dt
	if _fog_timer > 0.0:
		return
	_fog_timer = float(Data.FOG_INTERVAL)
	_update_fog()


func _alpha_for(i: int) -> float:
	# [U] PORT APPROXIMATION (DEC-U-FOW-TINT §6.10): ladder, not a donor tint law.
	if fog_vis[i] == 1:
		return ALPHA_VISIBLE
	if fog_explored[i] == 1:
		return ALPHA_EXPLORED
	return ALPHA_UNEXPLORED


func _set_tile_color(i: int, a: float) -> void:
	var base: int = i * 4
	if base + 3 >= _fog_colors.size():
		return
	var c := Color(0.0, 0.0, 0.0, a)
	_fog_colors[base] = c
	_fog_colors[base + 1] = c
	_fog_colors[base + 2] = c
	_fog_colors[base + 3] = c


func _make_fog_material() -> ShaderMaterial:
	# Spatial port of the 2D fog overlay: multiply black by per-tile alpha.
	# No donor shader is claimed: donor E19 depth fog is a different effect and
	# is off in the gameplay camera (camera.cfg:59).
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled, depth_draw_never;
// Per-tile fog-of-war tint. COLOR.a is the port's 0.78 / 0.30 / 0.00 ladder
// (app/scripts/world.gd:2251-2255); COLOR.rgb is black. Deliberately NOT a
// port of donor view-depth fog (E19/E20) - that binding is UNVERIFIED.
// [U] PORT APPROXIMATION (DEC-U-FOW-TINT §6.10, F1-MINI-TINT-TERRAIN): these
// are port numbers, not a donor tint — no FOWColor / CriticalColor value here.
void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	return mat


func _build_overlay() -> bool:
	_fog_vertices = PackedVector3Array()
	_fog_uvs = PackedVector2Array()
	_fog_indices = PackedInt32Array()
	_fog_colors = PackedColorArray()
	var n: int = _map_w * _map_h

	# game.height is optional: the t_fog3d.gd stub has no such field. Use a
	# flat y=0 overlay there; in a real game sample the generated height grid
	# (variant3d/scripts/game.gd:44, :364). Alignment with world3d_terrain.gd's
	# dump-derived heights is an OPEN QUESTION (see report).
	var hs = game.get("height")
	var h: PackedFloat32Array = PackedFloat32Array()
	if hs is PackedFloat32Array and (hs as PackedFloat32Array).size() == n:
		h = hs

	for ty in range(_map_h):
		for tx in range(_map_w):
			var i: int = ty * _map_w + tx
			var wy: float = (h[i] if h.size() == n else 0.0) + FOG_Y_OFFSET
			# Centred tile-corner mapping mirrors variant3d/scripts/world3d.gd:215-220.
			var wx: float = (float(tx) - float(_map_w) * 0.5) * _tile_m
			var wz: float = (float(ty) - float(_map_h) * 0.5) * _tile_m
			var base: int = _fog_vertices.size()
			_fog_vertices.append(Vector3(wx, wy, wz))
			_fog_vertices.append(Vector3(wx + _tile_m, wy, wz))
			_fog_vertices.append(Vector3(wx + _tile_m, wy, wz + _tile_m))
			_fog_vertices.append(Vector3(wx, wy, wz + _tile_m))
			_fog_uvs.append(Vector2(0.0, 0.0))
			_fog_uvs.append(Vector2(1.0, 0.0))
			_fog_uvs.append(Vector2(1.0, 1.0))
			_fog_uvs.append(Vector2(0.0, 1.0))
			_fog_indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
			var a: float = _alpha_for(i)
			for k in 4:
				_fog_colors.append(Color(0.0, 0.0, 0.0, a))

	_overlay_mesh = ArrayMesh.new()
	_overlay = MeshInstance3D.new()
	_overlay.name = "FogOverlay"
	_overlay.mesh = _overlay_mesh
	_overlay.material_override = _make_fog_material()
	# 2D draws fog above units at world.gd:346 (z_index = 10). In 3D the
	# equivalent transparent-sort bias is VisualInstance3D.sorting_offset.
	_overlay.sorting_offset = 10.0
	_overlay.visible = bool(Data.FOG_OF_WAR)
	add_child(_overlay)
	return true


func _refresh_mesh() -> void:
	if _overlay_mesh == null or _fog_vertices.is_empty():
		return
	_overlay_mesh.clear_surfaces()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _fog_vertices
	arrays[Mesh.ARRAY_TEX_UV] = _fog_uvs
	arrays[Mesh.ARRAY_COLOR] = _fog_colors
	arrays[Mesh.ARRAY_INDEX] = _fog_indices
	_overlay_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)


func _update_fog() -> void:
	C3Log.debug("fog", "update begin tick=%d built=%s fow_enabled=%s viewers=%d" % [_fog_tick, str(_built), str(_fow_enabled), _fow_viewers.size()])
	if game == null or not _built:
		C3Log.warn("fog", "update SKIP game_null=%s built=%s" % [str(game == null), str(_built)])
		return
	# DEC-U §1.3 — SetFOWEnable mirror, not the raw Data flag: balloon /
	# victory / editor-flag gates switch FOW off even when the option is on.
	# DEC-U-ENDGAME-FOW §5 item 4 [O] PORT APPROXIMATION — this per-tick rebuild
	# is the EAGER cadence substitution: the donor re-resolves ONLY at R1-R4
	# events (§1/§2), never on a stamp (§3). Do NOT gate it behind a stamp flag
	# to fake laziness — that would invent a hook — and do NOT throttle it.
	# A later ticket may relax it ONLY after U-F1 terminates with zero mismatches.
	# This call is NOT the donor re-resolve hook; no such hook is added here.
	rebuild_fow_enable()
	if not _fow_enabled:
		C3Log.info("fog", "update SKIP fow_disabled viewers=%d grid=%dx%d" % [_fow_viewers.size(), _map_w, _map_h])
		return
	if not game.has_method("tile_of"):
		C3Log.warn("fog", "update SKIP no tile_of; grid=%dx%d" % [_map_w, _map_h])
		return

	# Cheap change gate, structure verbatim from world.gd:2191-2211. Viewer set
	# is now the team-shared list from _player_UpdateFOW, not a hardcoded player 0.
	_fog_tick += 1
	var forced: bool = _fog_tick % 6 == 0
	var reqs = game.get("reveal_requests")
	var has_reveals: bool = (reqs is Array and not (reqs as Array).is_empty()) or not fog_reveals.is_empty()
	var any_moved: bool = forced or has_reveals
	if not any_moved:
		var ents = game.get("entities")
		if not (ents is Array):
			C3Log.debug("fog", "update SKIP no entities array tick=%d" % _fog_tick)
			return
		var live_n: int = 0
		for e in ents:
			if not _is_fow_viewer_entity(e):
				continue
			live_n += 1
			var lp: Vector2 = _fog_last_pos.get(int(e.id), Vector2.INF)
			if lp == Vector2.INF or lp.distance_squared_to(e.pos) > 0.25:
				any_moved = true
				break
		if not any_moved and live_n != _fog_unit_count:
			any_moved = true
	if not any_moved:
		C3Log.debug("fog", "update SKIP no change tick=%d forced=%s reveals=%s live=%d" % [_fog_tick, str(forced), str(has_reveals), _fog_unit_count])
		return
	_fog_last_pos.clear()
	var ents2 = game.get("entities")
	if ents2 is Array:
		for e in ents2:
			if not _is_fow_viewer_entity(e):
				continue
			_fog_last_pos[int(e.id)] = e.pos
	_fog_unit_count = _fog_last_pos.size()

	# Explicit reveal requests from sim abilities — game.gd:2834-2836,
	# world.gd:2218-2227. game_reveal(Vector2(MAP_W,MAP_H), 1e9) is the
	# "reveal whole map" call at game.gd:3461 and is handled by this same loop.
	# DEC-U §1.2 — tag-109 fogreveal objects are the scenario map_revealZone path.
	# TProj.dx was set to `radius` at creation; _unit_GetVision reads floor(dx).
	# The resolved floor() is applied here at the reveal site, never an estimate.
	var reveal_jobs: Array = []
	if reqs is Array:
		for rq in (reqs as Array):
			reveal_jobs.append({"c": Vector2(rq.pos), "r": float(rq.r)})
		(reqs as Array).clear()
	for rv in fog_reveals:
		reveal_jobs.append({
			"c": Vector2(float(rv.get("px", 0.0)), float(rv.get("pz", 0.0))),
			"r": floor(float(rv.get("dx", 0.0))),
		})
	for job in reveal_jobs:
		var c: Vector2 = job.c
		var rr: float = job.r
		var t0: Vector2i = game.tile_of(c - Vector2(rr, rr))
		var t1: Vector2i = game.tile_of(c + Vector2(rr, rr))
		for ty in range(maxi(0, t0.y), mini(_map_h, t1.y + 1)):
			for tx in range(maxi(0, t0.x), mini(_map_w, t1.x + 1)):
				# world.gd:2225 uses tx*2+1 (TILE_M=2 tile centre).
				var centre := Vector2((float(tx) + 0.5) * _tile_m, (float(ty) + 0.5) * _tile_m)
				if centre.distance_to(c) <= rr:
					fog_explored[ty * _map_w + tx] = 1

	# DEC-U-FOG-TERRITORY §6.1 [O] EV-FT-ZERO — this is the capture-path handoff,
	# NOT an FOW invalidation: donor capture (miscext.script:894-959) re-keys
	# ScanGrid membership (unit.script:3157-3167 / :3135-3153) but issues ZERO
	# FOW writes (FOWBuildFull -> scenario.script:1862 only; SetFOWEnable ->
	# player.script:477 only; ClearFOWPlayers -> player.script:460 only).
	# The next scheduled _update_fog() re-poll (movement / `_fog_tick % 6` /
	# reveal gate) IS the donor recompute. Never add rebuild_fow_full() here or
	# to any capture/transfer function. `fog_counts > 0` combine stays PORT law
	# until E-FOGT-a terminates — no cell/rect/color is invented.
	fog_counts.fill(0)
	# DEC-U §1.1 — every eligible viewer contributes floor(20+4*vision).
	# [U] F1-GRID: donor `res` unit (cell vs metre) is engine-defined and absent
	# from readable text; _vision_radius_m() is a labelled grid driver, not a
	# donor claim. Cell size, combine rule and occlusion stay unresolved.
	var ents3 = game.get("entities")
	if ents3 is Array:
		for e in ents3:
			if not _is_fow_viewer_entity(e):
				C3Log.trace("fog", "vision SKIP non-viewer id=%s" % str(e.get("id", -1)))
				continue
			var res: int = donor_unit_vision(e)
			if res <= 0:
				C3Log.trace("fog", "vision SKIP res<=0 id=%s" % str(e.get("id", -1)))
				continue
			var r: float = _vision_radius_m(res)
			var t0: Vector2i = game.tile_of(e.pos - Vector2(r, r))
			var t1: Vector2i = game.tile_of(e.pos + Vector2(r, r))
			for y in range(maxi(0, t0.y), mini(_map_h, t1.y + 1)):
				for x in range(maxi(0, t0.x), mini(_map_w, t1.x + 1)):
					var c := Vector2((float(x) + 0.5) * _tile_m, (float(y) + 0.5) * _tile_m)
					if c.distance_to(e.pos) <= r:
						fog_counts[y * _map_w + x] += 1
	# fogreveal objects feed the same visible grid (AddFOWObjects in donor).
	for rv2 in fog_reveals:
		var rr2: float = floor(float(rv2.get("dx", 0.0)))
		var pc := Vector2(float(rv2.get("px", 0.0)), float(rv2.get("pz", 0.0)))
		var q0: Vector2i = game.tile_of(pc - Vector2(rr2, rr2))
		var q1: Vector2i = game.tile_of(pc + Vector2(rr2, rr2))
		for y2 in range(maxi(0, q0.y), mini(_map_h, q1.y + 1)):
			for x2 in range(maxi(0, q0.x), mini(_map_w, q1.x + 1)):
				var cc := Vector2((float(x2) + 0.5) * _tile_m, (float(y2) + 0.5) * _tile_m)
				if cc.distance_to(pc) <= rr2:
					fog_counts[y2 * _map_w + x2] += 1

	# DEC-U-FOG-TERRITORY §6.2 [O-absence -> D] — sticky explored commit: NEVER
	# clear on an owner change. Donor has no clear on miscext.script:894-959,
	# FOWBuildFull is absent, and the only reset is ClearFOWPlayers on player
	# switch (player.script:460 via control.script:714-716); serial carries no
	# explored payload (serial.script:2549-2578). If E-FOGT-b proves a clear,
	# wire it to player-switch / victory / save-load legs only — never the flip.
	var changed: bool = false
	for i in _map_w * _map_h:
		if i % 4096 == 0:
			C3Log.trace("fog", "combine sampled i=%d n=%d" % [i, _map_w * _map_h])
		var v: int = 1 if fog_counts[i] > 0 else 0
		if v == 1:
			fog_explored[i] = 1
		if fog_vis[i] == v:
			continue
		fog_vis[i] = v
		var a: float = _alpha_for(i)
		_tile_alpha[i] = a
		_set_tile_color(i, a)
		changed = true
	if changed:
		if _overlay != null:
			_overlay.visible = _fow_enabled
		_refresh_mesh()
	C3Log.debug("fog", "update done tick=%d live=%d changed=%s occlusion=none combine=fog_counts>0" % [_fog_tick, _fog_unit_count, str(changed)])


# ──────────────────────────────────────────────────────────────────────────────
# DEC-U-FOG-CAMERA-HUD §§1.1-1.3 — resolved donor laws.
# ──────────────────────────────────────────────────────────────────────────────

func _player(pi: int) -> Dictionary:
	if game == null or not is_instance_valid(game):
		return {}
	var ps: Variant = game.get("players")
	if not (ps is Array) or pi < 0 or pi >= (ps as Array).size():
		return {}
	var p: Variant = (ps as Array)[pi]
	return p if p is Dictionary else {}


func _player_count() -> int:
	if game == null or not is_instance_valid(game):
		return 0
	var ps: Variant = game.get("players")
	return (ps as Array).size() if ps is Array else 0


func rebuild_fow_enable() -> void:
	# _player_UpdateFOW (player.script:451-478), verbatim gate order:
	# bFOW := True; False if balloon / mapsetting-balloon-with / victory /
	# not editor_fogofwar; then own handle + same-team allies + DovFunc + Enable.
	var on: bool = bool(Data.FOG_OF_WAR)
	if on and str(Data.BALLOON_MODE) == "balloons":
		on = false  # gc_mapsettings_balloon_with (player.script:454-457)
	if on:
		var pl0 := _player(0)
		if bool(pl0.get("balloon", false)):
			on = false  # gPlayer[pl].bballoon (player.script:454-456)
		# V3 [O] player.script:454-456 + dmscript.global:777-779: ANY terminal
		# victorystate of the viewer (win=1 OR lose=2, `<> none`) = full vision.
		# The port carries the donor enum mirror `victorystate_int` beside the
		# display string (game.gd:494); check BOTH, never the string alone.
		if _is_terminal_victory(pl0):
			on = false
			# DEC-U-ENDGAME-STAMP §7 item 6 [O] — KEEP this V3 gate unchanged: it is
			# player.script:456 (`victorystate <> none`) + enum none/win/lose = 0/1/2
			# (dmscript.global:777-779). W8/W9 unconditional win->lose overwrites and
			# W13's no-time lose BOTH trip it on the NEXT rebuild; same-frame timeliness
			# would need the item-5 game.gd hook (OUT OF SCOPE / NOT landed here), never
			# this predicate. The rebuild is the labelled eager PORT APPROXIMATION.
		if game != null and game.get("editor_fogofwar") == false:
			on = false  # gbool_editor_fogofwar (dmscript.global:2120)
	_fow_enabled = on
	_fow_viewers = _fow_viewer_players()
	if _overlay != null:
		_overlay.visible = on


func _is_terminal_victory(p: Dictionary) -> bool:
	# V3 [O] player.script:454-456 (`victorystate <> none`) + enum
	# none=0/win=1/lose=2 [O] dmscript.global:777-779. The port keeps the
	# display string (game.gd:8334/8359) AND the donor int mirror
	# `victorystate_int` (game.gd:494); either terminal value disables FOW.
	# DEC-U-ENDGAME-FOW §5 item 5: W8/W9 win->lose overwrites and W13's no-time
	# lose (miscext2.script:3849-3896; initmapgen.inc:256-264) BOTH trip this gate
	# on the NEXT rebuild — the donor issues NO inline refresh (§3). Same-frame
	# timeliness would come from a game.gd hook (OUT OF SCOPE here), NOT from this
	# predicate. Gate KEPT; no behaviour change.
	# DEC-U-ENDGAME-STAMP §7 item 6 [O] corroborates this exact coverage: W8/W9
	# (miscext2.script:3859-3861 / :3891-3893) and W13 (initmapgen.inc:263) both
	# trip the gate at the next rebuild; no stamp writes any FOW field (§5.1).
	var vi: int = int(p.get("victorystate_int", 0))
	if vi != 0:
		return true
	var vs: String = str(p.get("victorystate", "none")).to_lower()
	return vs != "none" and vs != ""


func _is_bneutral(p: Dictionary) -> bool:
	# V2 [O] player.script:470-472 reads gPlayer[i].bneutral — a TPlayer
	# boolean (classes.script:3674-3698) set by trigger action 20
	# (scenario.script:2225-2249), a LAYER-B flag, never a team id.
	# PORT APPROXIMATION (landed viewer set): the port has no bneutral field;
	# `nation == "neutral"` is a null-safe fallback, NOT a donor value.
	if p.has("bneutral"):
		return bool(p.get("bneutral", false))
	return str(p.get("nation", "")).to_lower() == "neutral"


func _sim_team_key(pi: int) -> int:
	# V1 [O] player.script:464-473 shares by SIM team gPlayer[i].team, i.e.
	# post-SetupTeams ids (DEC_U_teams §2/§5): FFA [0,0,0,0] -> [1,2,3,4],
	# shared [1,1,2,2] -> [1,1,2,2]. Those ids are built in game.gd (§8
	# change 1, OUT OF SCOPE here); no dense id is synthesised in this file.
	# Port keeps `team=0` as a REAL shared id (game.gd:8282) — a port mapping
	# vs the donor's pre-setup sentinel (player.script:110-117), not a law.
	# §8 change 2 keeps game `_sim_team` as the single layer-A accessor for
	# win/FOW/AI: use it when present, else the same port -1-unique mapping
	# (game.gd:8283-8285). Both give "each FFA slot its own team, no sharing".
	if game == null or pi < 0 or pi >= _player_count():
		return -1
	if game.has_method("_sim_team"):
		return int(game.call("_sim_team", pi))
	var t: int = int(_player(pi).get("team", -1))
	return t if t >= 0 else -(pi + 2)


func _fow_viewer_players() -> Array:
	# DEC_U_teams §5 [O] player.script:451-478 / :464-473 — ClearFOWPlayers,
	# AddFOWPlayers(self), then every i<>plInd with gPlayer[i].team = team
	# (the VIEWER's sim team) and `(plInd<>0) or (not gPlayer[i].bneutral)`.
	# The port has ONE global fog grid, i.e. interface viewer plInd=0; keep the
	# full two-branch condition so a per-viewer set needs no law change.
	# Layer A only — enemyplmask / engine handles (DEC_U_teams §4) are NEVER
	# consulted for vision sharing.
	var out: Array = []
	var viewer: int = 0
	var viewer_team: int = _sim_team_key(viewer)
	for i in _player_count():
		var p := _player(i)
		# PORT APPROXIMATION (landed): terminal mates are skipped from the
		# viewer set. Donor adds them unconditionally but their units are gone;
		# the viewer's own terminal state already disables FOW at V3 above.
		# DEC-U-ENDGAME-FOW §5 item 6a [O] — player.script:468-472 has NO terminal
		# check; this skip stays a labelled PORT APPROXIMATION, no behaviour change.
		# DEC-U-ENDGAME-STAMP §7 item 7a [O] corroborates the skip: donor adds
		# terminal mates unconditionally (player.script:463-473), harmless while
		# their units are dead (W1 kill precedes the stamp). No behaviour change.
		if _is_terminal_victory(p):
			continue
		if i == viewer:
			out.append(i)  # AddFOWPlayers(self)
			continue
		if _sim_team_key(i) != viewer_team:
			continue
		# V2 slot-0 / bneutral exception (player.script:470-472). The broad
		# commented form at :470 is NOT taken. For viewer 0 a bneutral mate is
		# excluded; for any other viewer it would be included.
		if viewer != 0 or not _is_bneutral(p):
			out.append(i)
	return out


func team_vision_telemetry() -> Dictionary:
	# Read-only labels + the report's [U] fixed-seed captures. NO behaviour,
	# NO port constant, NO parity claim.
	var rows: Array = []
	for pi in _fow_viewers:
		var p := _player(int(pi))
		rows.append({"player": int(pi), "sim_team_key": _sim_team_key(int(pi)),
			"bneutral_approx": _is_bneutral(p), "terminal": _is_terminal_victory(p)})
	return {
		"cite": "DEC_U_teams.md §§2/4/5/8/9; player.script:451-478; dmscript.global:777-779",
		"viewer_slot": 0,
		"fow_enabled": _fow_enabled,
		"fow_viewers": _fow_viewers.duplicate(),
		"viewer_team_keys": rows,
		"sim_team_source": "game._sim_team() when present, else port -1-unique mapping (game.gd:8283-8285)",
		"layer_A": "gPlayer[].team — FOW / win / AI key",
		"layer_B": "enemyplmask/myplmask + engine handles — targeting only, NOT read by FOW",
		"gaps": ["G1_no_SetupTeams", "G2_no_enemy_mask", "G3_no_bneutral_flag", "G4_single_global_viewer"],
		"captures": TEAMVIS_CAPTURES,
		"parity_claim": false,
	}


func fog_territory_telemetry() -> Dictionary:
	# DEC-U-FOG-TERRITORY §§1-7 — read-only labels + the four [U] captures. NO
	# behaviour, NO FOW write, NO repaint rule, NO port constant, NO parity claim.
	return {
		"cite": "DEC_U_fog_territory.md §§1-7; miscext.script:894-959; unit.script:3135-3167; serial.script:277",
		"capture_path": "re-keys ScanGrid membership only; ZERO FOW writes on capture (P6 census)",
		"fow_writers": {
			"FOWBuildFull": "scenario.script:1862 only",
			"SetFOWEnable": "player.script:477 only",
			"ClearFOWPlayers": "player.script:460 only (player switch via control.script:712-720)",
			"AddFOWPlayers": "player.script:463,472 only",
			"AddFOWObjects": "misc.script:5927 only",
			"SetFOWDovFunc": "player.script:475 only",
		},
		"recompute": "engine-lazy downstream of ScanGrid Add/Remove; no script rect/cell invalidation; port invalidates no rect on capture (E-FOGT-a)",
		"territory_owner": "engine repaint inside Add/Remove [I-flagged]; only script .owner write is init -1 (serial.script:277); no radius/rect invented",
		"explored": "retained at script level on capture; no clear on miscext.script:894-959; engine sticky-vs-visible channel [U] (E-FOGT-b)",
		"name_swap": {
			"keycolor": "misc.script:5067-5083 via unit.script:3860 (winner color recursive)",
			"highlight": "miscext.script:920 -> gui.script:3383-3470 (friend/ally/enemy, walls invisible)",
			"minimap": "gui.script:3472 -> misc.script:1137-1172 (pl2x2|pl3x3.<color>[.sel], static position)",
			"deselect": "unit.script:3980-3998 (IO-party picked dropped, ctrlgroups wiped)",
		},
		"captures": FOGTERR_CAPTURES,
		"parity_claim": false,
	}


func capture_fow_telemetry() -> Dictionary:
	# DEC-U-CAPTURE-STATE2 §7.5-6 — read-only labels + the six [U] captures.
	# Adds NO behaviour, NO FOW write, NO repaint rule, NO parity claim.
	return CAPFOW_CAPTURE_TELEMETRY.duplicate(true)


func endgame_fow_telemetry() -> Dictionary:
	# DEC-U-ENDGAME-FOW §§1-7 — read-only labels + the eight §6 [U] captures.
	# Adds NO behaviour, NO FOW write, NO hook, NO cadence, NO parity claim.
	return ENDGAME_FOW_TELEMETRY.duplicate(true)


func endgame_stamp_fog_telemetry() -> Dictionary:
	# DEC-U-ENDGAME-STAMP §7 items 6-7 — read-only labels + the eight §8 [U]
	# captures. Adds NO behaviour, NO FOW write, NO hook, NO stamp, NO parity claim.
	return ENDGAME_STAMP_FOG_TELEMETRY.duplicate(true)


func _is_fow_viewer_entity(e: Dictionary) -> bool:
	# DEC-U-FOG-TERRITORY §6.3 [O] — e.player is read LIVE here and in
	# donor_unit_vision(): after a capture the object's radius re-attributes to
	# the winner on the next pass (donor _unit_GetVision reads TObj.pl at poll
	# time; owner flip miscext.script:915-919; ScanGrid re-key unit.script:3135-3167).
	# No enemyplmask/myplmask consult here — the layer-A/B viewer split stays in
	# _fow_viewer_players() (:645-673). No behaviour change: still the live read.
	# DEC-U-ENDGAME-FOW §5 item 6b [O] — dead/finished/hidden gates are the port
	# of _unit_GetVision's not-bdead / bbuilt / visible gates (unit.script:11563-
	# 11614); KEPT, cite added. Does not alter the stamp / skip law.
	# DEC-U-ENDGAME-STAMP §7 item 7b [O] corroborates these gates as the port of
	# _unit_GetVision (unit.script:11563-11614); KEPT, no behaviour change.
	if not _fow_viewers.has(int(e.get("player", -1))):
		return false
	if bool(e.get("hidden", false)):
		return false  # GetGameObjectVisibleByHandle (unit.script:11576)
	if bool(e.get("dead", false)) or not bool(e.get("finished", true)):
		return false  # not bdead and bbuilt
	return true


func donor_unit_vision(e: Dictionary) -> int:
	# _unit_GetVision (unit.script:11563-11614) — installed by the ONE shipped
	# SetFOWDovFunc site, player.script:475. The integer floor() is
	# load-bearing: vision 0/1/3/8 -> 20/24/32/52.
	# DEC-U-FOG-TERRITORY §6.3 [O] — reads live e.player/TObj.pl at poll time, so
	# a captured object's radius follows the winner with no script FOW write
	# (miscext.script:915-919; unit.script:3135-3167). No team-mask consult here.
	if str(e.get("sid", "")).to_lower() == "fogreveal" or bool(e.get("fogreveal", false)):
		# TProj(pproj).dx is set to the caller radius at creation
		# (misc.script:5942); any absent dx is 0 + ErrorLog in the donor.
		return int(floor(float(e.get("dx", e.get("r", 0.0)))))
	if not _is_fow_viewer_entity(e):
		return 0
	var def: Variant = e.get("def", {})
	if not (def is Dictionary) or not (def as Dictionary).has("vision"):
		# [U] F1-GRID — port data.gd has no per-sid integer `vision` field yet.
		# Never invent one: the donor vision=0 row (res=20) is the loaded law.
		# IMPL-FOG-HUD's report carries the exact data.gd patch to close this.
		return int(floor(DONOR_VISION_BASE))
	var vision := int((def as Dictionary).get("vision", 0))
	return int(floor(DONOR_VISION_BASE + DONOR_VISION_PER_POINT * float(vision)))


func _vision_radius_m(res: int) -> float:
	# [U] F1-GRID — the donor unit of `res` (FOW cell vs world metre) is
	# engine-defined and no readable text gives the cell size. 1 res = 1 port
	# metre is a PROVISIONAL grid driver ONLY, NOT a donor claim. Experiment
	# E-GRID-a fits the true scale by dumping GetFOWLOSData(x,z) along a
	# fixed-camera transect for known vision values; no combine/occlusion rule
	# is assumed. The eight ENGINE-DEFAULT-ONLY knobs (K1-K8) get NO port
	# counterpart here — their values stay [U] until E-KNOB-defaults logs them.
	# DEC-U-FOG-TERRITORY §6.1 — this metre driver and the `fog_counts > 0`
	# combine stay labelled PORT law until E-FOGT-a terminates; no cell size,
	# combine operator, rect or radius is invented on capture.
	return float(res)


func get_fog_reveal(px: float, pz: float) -> int:
	# _misc_GetFogReveal (misc.script:5901-5916): px/pz epsilon scan. Godot's
	# is_equal_approx is used so NO donor epsilon literal is invented.
	for i in fog_reveals.size():
		var r: Dictionary = fog_reveals[i]
		if is_equal_approx(float(r.get("px", INF)), px) and is_equal_approx(float(r.get("pz", INF)), pz):
			return i
	return -1


func get_or_create_fog_reveal(px: float, pz: float, radius: float) -> Dictionary:
	# _misc_GetOrCreateFogReveal (misc.script:5918-5944): reuse by px/pz, else
	# CreatePlayerGameObjectHandleByHandle(miscPlHnd,'misc','fogreveal',px,
	# RayCastHeight,pz) + AddFOWObjects + visible=False + TProj.px/pz/dx.
	# The port has no engine object table; the tag-109 record IS the object.
	var i := get_fog_reveal(px, pz)
	if i >= 0:
		return fog_reveals[i]
	var o := {"px": px, "pz": pz, "dx": radius, "tag": DONOR_FOGREVEAL_TAG}
	fog_reveals.append(o)
	rebuild_fow_full()  # scenario.script:1862 — if GetFOWEnable then FOWBuildFull
	return o


func remove_fog_reveal(px: float, pz: float) -> bool:
	# _misc_RemoveFogReveal (misc.script:5883-5897): destroy first tag-109 match.
	var i := get_fog_reveal(px, pz)
	if i < 0:
		return false
	fog_reveals.remove_at(i)
	rebuild_fow_full()  # same FOWBuildFull call as the scenario trigger
	return true


func rebuild_fow_full() -> void:
	# FOWBuildFull (scenario.script:1862): force a full recompute next tick,
	# bypassing the `_fog_tick % 6` / movement change gate.
	_fog_tick += 1
	_fog_timer = 0.0
	_fog_last_pos.clear()
	_fog_unit_count = -1
	_update_fog()


func los_at(pos: Vector2) -> int:
	# K9 GetFOWLOSData(x, z: Float): Integer @0x2a7812 (VA 0x6a8412), a getter
	# with no script writer; call sites compare only >0 (control.script:270).
	# [U] E-GRID-a/b/c/e: grid quantisation, combine, occlusion and Integer
	# domain are not statically known; this reads the SAME port grid the reveal
	# pass writes, so picking and tint use one source of truth.
	if not _fow_enabled or not _built:
		C3Log.trace("fog", "los SKIP disabled built=%s enabled=%s" % [str(_built), str(_fow_enabled)])
		return 1
	if game == null or not game.has_method("tile_of"):
		C3Log.trace("fog", "los SKIP no tile_of")
		return 1
	var t: Vector2i = game.tile_of(pos)
	if t.x < 0 or t.y < 0 or t.x >= _map_w or t.y >= _map_h:
		return 0
	return int(fog_vis[t.y * _map_w + t.x])


func is_visible_at(pos: Vector2) -> bool:
	# control.script:270-273 and gui.script:3479-3490:
	# bVisible := (not GetFOWEnable) or (GetFOWLOSData(x,z) > 0).
	return (not _fow_enabled) or los_at(pos) > 0

