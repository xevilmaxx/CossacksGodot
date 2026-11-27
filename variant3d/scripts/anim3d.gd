# anim3d.gd — donor-sampled flat-root morph/pose source for the 3D variant.
#
# SCOPE: SINGLEPLAYER SKIRMISH ONLY (WAVE7_3D_VARIANT_CHARTER.md:37-38).
# GOVERNING RULE: leverage donor code, cite donor path:line, leave unreadable
# semantics UNVERIFIED (WAVE7_3D_VARIANT_CHARTER.md:29-36).
#
# WHAT THIS MODULE IS NOW (V7-64):
#   A deterministic donor-frame clock PLUS a donor-sampled flat-root skinner.
#   The readable part of the donor .oss payload (vertices, per-vertex weights,
#   per-bone position+quaternion tracks) is translated verbatim from
#   variant3d/tools/bake_sprites.py into GDScript:
#       read_oss  :91-103   -> parse_donor_oss()
#       qmat      :118-129  -> _qmat()
#       skin      :131-143  -> skin_vertices()
#       sample    :145-152  -> sample_frames()
#   Given a registered donor skin for a sid, pose_for()/play() return the ACTUAL
#   skinned vertex array at the resolved donor AAF frame. That array is a donor
#   morph target in donor Z-up metres, index-for-index identical to the bind
#   vertices written to assets/models/obj/<sid>.obj by convert_models.py:43-66,
#   :109-125 (both readers consume the same first vertex block of the same
#   .oss). The entity renderer can therefore replace its static mesh vertices
#   with this array after applying its existing bbox/Y-up transform.
#
# WHAT THIS MODULE IS STILL NOT:
#   It is NOT donor-faithful SKELETAL animation. V7-2 proved the donor .oss skin
#   payload is readable but the BONE PARENT HIERARCHY is absent; the skin below
#   applies every bone track DIRECTLY to the bind vertex (flat root), exactly
#   as bake_sprites.skin does. No parent matrix is invented
#   (V72_mesh_conversion_feasibility.md:180-186, :264-284, Table B1 :380-386).
#   There is no sprite sheet, no PNG bake, no 2D bake output and no RNG.
#   Every status keeps the label:
#       PORT APPROXIMATION — NOT DONOR PARITY
#   and the VISUAL result stays UNVERIFIED until a frame A/B proves it.
#
# V7-78 — SHIPPED SKIN ASSETS (automatic, no manual registration):
#   variant3d/tools/convert_skins.py exports a deterministic donor-frame SUBSET
#   to res://assets/models/skin/<sid>.json + index.json. _ensure_shipped_skins()
#   loads that index lazily on first bind()/has_skin()/pose_for() call and
#   registers every sid itself. The shipped runtime therefore morphs units
#   WITHOUT any probe calling register_skin()/load_skin_from_donor(). No donor
#   bytes are read at runtime; only the offline-converted JSON assets.
#
# DEC-U-AAF-ART C2 (2026-11-26): the shipped index now exports each sid's OWN
# donor AAF action windows (work/carry/reaction/prepare/trans/attack2/death*
# families, convert_skins.py C1). This module keeps the per-sid lookup, adds
# donor loop/clamp-once policy for named actions and carries the donor
# minFrameBlend=6/maxFrameBlend=8 nearest-frame window as a labelled diagnostic.
# Every status stays [U] U2 where the donor completion/blend semantics are
# unrecovered; no visual parity is claimed and no art is synthesised.
#
# DONOR CITATIONS (all private-use, read-only bytes/ASCII; no donor binary run):
#   data\animations\aaf\peaukr.aaf:1-20  — 18 named actions, inclusive ranges,
#       "walk",1,20,morph at :5; AAF dialect at docs/decomp/DC_FORMATS.md:96-109.
#   data\actors\units\peaukr.oss byte 0 — <6i k,fps,b,v,fc,t> header; layout at
#       docs/decomp/DC_FORMATS.md:46-64; measured k=483, fps=30, b=20, v=577,
#       fc=921, t=733, exact 312376-byte closure (V72 report :159, :163-165).
#   variant3d\tools\bake_sprites.py:91-103, :118-129, :131-143, :145-152 —
#       the donor skin math copied here, never re-derived from donor bytes.
#   variant3d\tools\convert_models.py:43-66, :109-125 — identical vertex order
#       in the shipped OBJ (morph index i == OBJ vertex i).
#
# TABS ONLY. NO RNG. NO SPRITE SHEETS. NO 2D BAKE OUTPUTS.
extends Node

# Donor fps from the .oss header second int (see header citation above).
# NOT an invented cadence: 30 fps is measured on three donors in V7-2.
const DONOR_FPS: float = 30.0

# Exact label mandated by V7-2 §4.4 / Table C (reports/V72...:305-311, :400-410)
# and by WAVE7_3D_VARIANT_CHARTER.md:54-57. Never omit it.
const PORT_LABEL: String = "PORT APPROXIMATION — NOT DONOR PARITY"

# Why no donor-parity skin is possible today (V7-2 §3.3 item 1, :180-183).
const BLOCKED_RIG: String = "BLOCKED: donor bone parent hierarchy unreadable (V7-2 §3.3.1 / Table B1); flat-root skin only"

# All 18 action ranges from data\animations\aaf\peaukr.aaf:3-20.
# Value = [first_frame, last_frame, donor_line, type_token]. Bounds are INCLUSIVE
# (docs/decomp/DC_FORMATS.md:109). No frame value is invented here.
const AAF_ACTIONS: Dictionary = {
	"idle": [64, 113, 3, "morph"],
	"idle0": [64, 113, 4, "morph"],
	"walk": [1, 20, 5, "morph"],
	"death": [115, 149, 6, "morph"],
	"attack0": [237, 254, 7, "morph"],
	"workfood": [278, 299, 8, "morph"],
	"workwood": [237, 254, 9, "morph"],
	"workstone": [217, 234, 10, "morph"],
	"idlefood": [405, 454, 11, "morph"],
	"idlewood": [354, 403, 12, "morph"],
	"idlestone": [303, 352, 13, "morph"],
	"walkfood": [257, 276, 14, "morph"],
	"walkwood": [22, 41, 15, "morph"],
	"walkstone": [43, 62, 16, "morph"],
	"construct": [186, 198, 17, "morph"],
	"reaction": [456, 481, 18, "morph"],
	"prepare0": [64, 65, 19, "morph"],
	"unprepare0": [64, 65, 20, "morph"],
}

# PORT-LEVEL alias only (not a donor statement): the 2D sim emits "attack" at
# world.gd:475-476 while the donor AAF names the clip "attack0" at :7.
const ACTION_ALIAS: Dictionary = {
	"attack": "attack0",
}

# PORT1TO1-ENT1TO1 (D1/D2/D3) — donor AAF is PER SID: 194 .aaf files on disk,
# and each shipped skin carries its OWN decoded ranges (convert_skins.py:80-81).
# AAF_ACTIONS below is the peaukr table (peaukr.aaf:3-20) and is now used ONLY
# when no skin exists for the sid. Every such pose is tagged, never silent.
# DEC-U-AAF-ART C2: for a REGISTERED sid _action_range_for() returns only that
# sid's own exported actions; the peaukr range table is unreachable there and
# an unknown action returns ok:false (never a silent idle/walk substitution).
const AAF_FALLBACK_STATUS: String = "UNVERIFIED [U] U2 — per-sid donor AAF authoritative; peaukr.aaf:3-20 table only for a sid with no shipped skin (sid unknown); no visual parity claim"
# DEC-U-AAF-ART C2: donor AAF tokens are attack0 (peaukr.aaf:7), attack1
# (musketeer.aaf:7, [99,124]) and the grenadier family attack2 /
# attack2before 630..663 / attack2after 664..679 (grenadier.aaf:28-30). No
# 'attack' token exists in any donor AAF; ACTION_ALIAS is a port bridge only.
# Weapon/order gating for attack1/attack2 is [U] U2 (DEC_U §1.2 / §5 C2-C3).
const AAF_ATTACK_TOKENS: Array = ["attack0", "attack1", "attack2", "attack2before", "attack2after"]
const ACTION_ALIAS_STATUS: String = "PORT-LEVEL BRIDGE ONLY — no 'attack' token exists in any donor AAF; donor names are attack0 (peaukr.aaf:7), attack1 (musketeer.aaf:7, [99,124]) and attack2/attack2before/attack2after (grenadier.aaf:28-30); weapon/order selection [U] U2; no parity claim"
# DEC-U-AAF-ART C2: cycle policy is NOT in the AAF (every row is 'morph').
# Donor scripts supply it: bPlayOnce=True for attacks+deaths, False for
# walks/idles/work/construct (showdebuganimations.inc:45-66,113-155 carried by
# DANIM_01 §4.3). This module now applies loop=walks/idles/work/construct,
# clamp (play-once)=death/attack* including attack2before/after. The donor
# COMPLETION SIGNAL for the clamp (acmPlayOnce/aamPlayOnce,
# unit.script:10808-10809,10852) was not recovered: clamping to the last frame
# is a port stand-in, labelled [U] U2, never a donor-parity claim.
const AAF_LOOP_STATUS: String = "PORT-LEVEL CYCLE POLICY [U] U2 — donor AAF rows carry only 'morph' (peaukr.aaf:3-20); loop for walk*/idle*/work*/carry*/construct/reaction, clamp once for death*/attack* per bPlayOnce (showdebuganimations.inc:45-66,113-155); no recovered completion signal (acmPlayOnce/aamPlayOnce unit.script:10808-10809,10852) so clamp-at-last-frame is a port stand-in; visual UNVERIFIED, no parity claim"
# Donor blend literals: minFrameBlend=6 / maxFrameBlend=8
# (unit.script:10846-10847; initial.inc:17-19, carried by DANIM_01 §4.3).
# Their ENGINE SEMANTICS are unrecovered ([U] U2). They are used here only as a
# nearest-exported-frame window over the deterministic 6-frame subset; no
# interpolation, no invented donor frame, no visual-parity claim.
const DONOR_MIN_FRAME_BLEND: int = 6
const DONOR_MAX_FRAME_BLEND: int = 8
const FRAME_BLEND_STATUS: String = "PORT-LEVEL NEAREST-FRAME POLICY [U] U2 — donor minFrameBlend=6/maxFrameBlend=8 literals (unit.script:10846-10847, initial.inc:17-19) used as a diagnostic window around the nearest EXPORTED donor frame; donor blend semantics unrecovered; no interpolation and no invented frame; visual UNVERIFIED, no parity claim"

# ══ DEC-U-AAF-TRIGGERS (2026-11-26) — read-only donor facts [O] ════════════════
# This block carries ONLY statically resolved donor facts from
# docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_triggers.md (§1.2 T1–T26,
# §2 cycle, §3 completion, §4 blend). It does NOT read entity state and does
# NOT invent a selector or a fallback: rows with no donor set-site (T23–T25)
# and every unrecovered operator ([U]-B/C1/C2/S/W/W2/A/R/T) stay labelled.
# Entity-state→token wiring belongs to world3d_entities.gd (exact patch
# recommendation in reports/IMPL_U_aaf_triggers.md) and is NOT done here.

# Blend parameter carried at each donor emission site [O] (DEC-U §1.2/§4.1):
#   DONOR_BLEND_NONE   "0,0": GameObjectResetFrameAnimationBlend + explicit
#     0,0 at the bSkip early-out (unit.script:10891-10893, "dont use blend cause
#     it kills animation") and at idle re-entry (unit.script:11042, "to reset
#     blend ... needed to prevent 2 shooting animation effect"); mirrors at
#     ontagstates.inc:329-343, :474, :513.
#   DONOR_BLEND_MINMAX "6,8": SwitchToTreeAnimationCyclesBlendByHandle(
#     ..., minFrameBlend, maxFrameBlend) at unit.script:10970,11016,11055,11100
#     and ontagstates.inc:474,513,596; literals unit.script:10846-10847;
#     installed initial.inc:17-19 with DeferredFrameBlend(false).
# The 0,0 bypass is donor-proven [O]. The ENGINE meaning of 6/8 is [U]-B
# (capture R-B); no interpolation is performed here.
const DONOR_BLEND_NONE: String = "0,0"
const DONOR_BLEND_MINMAX: String = "6,8"
const DONOR_BLEND_SITES: String = "literal unit.script:10846-10847; install initial.inc:17-19 (SetGameObjectMin/MaxFrameBlendByHandle 6/8, DeferredFrameBlend(false) = EAGER, not deferred); consume unit.script:10970,11016,11055,11100 + ontagstates.inc:474,513,596; THIRD literal site progress.inc/nothing.inc:8-9,61 (own 6/8 locals + deferred walk switch + walkintervalfactor), not the sim tag engine; 4-level walk cascade walk2->walk1->walk0->walk (nothing.inc:27-31); movie window 0..5 NOT 6..8 (movie.script:644-646, maxblend=5 iff bBlend) [U]-B4; debug buttons ALWAYS 0,0 (eventdebuganimations.inc: Switch(0,0) -> Reset -> TrackPointClear -> SetCyclesMode -> ManagePeasantAttach, rest forced bRandomFrame=True); 0,0 bypass unit.script:10891-10893,11042 + ontagstates.inc:329-343. Engine operator [U]-B, capture R-B."

# DEC-U-BLEND-OP §7 F1 [O] — the seven donor 0,0 bypass sites V1-V7, as READ-ONLY
# status data. Under 0,0 the engine plays the clip exactly as authored: V1 unit.script:10891-10893 (bSkip early-out, "dont use blend cause it kills animation"), V2 unit.script:11041-11042 (idle re-entry, "to reset blend ... prevent 2 shooting animation effect"), V3 ontagstates.inc:355-357 (early-out mirror), V4 ontagstates.inc:500 (idle re-entry mirror, a3=True [U]-B3), V5 movie.script:636-637,639 (empty-token reset pulse), V6 movie.script:586,1022,1076 (revive/rebuild idle), V7 eventdebuganimations.inc (debug always 0,0). Death is NOT a bypass: unit.script:11100-11102 / ontagstates.inc:596-598 do Switch(6,8) then Reset (reset-after). No interpolation, no invented weight.
const DONOR_BLEND_BYPASS_SITES: String = "SEVEN DONOR 0,0 BYPASSES [O] V1 unit.script:10891-10893 (Switch(0,0)->Reset, bSkip early-out); V2 unit.script:11041-11042 (Reset->Switch(0,0), idle re-entry); V3 ontagstates.inc:355-357; V4 ontagstates.inc:500 (a3=True, [U]-B3); V5 movie.script:636-637,639 (empty token reset pulse); V6 movie.script:586,1022,1076; V7 eventdebuganimations.inc (always 0,0). Under 0,0 sample_frame MUST equal requested_frame — any snap contradicts unit.script:10891-10893,11042. Death unit.script:11100-11102 is Reset-after, not a bypass. NO interpolation, NO invented weight."

# DEC-U-BLEND-OP §7 F8 [O] — four read-only operator-argument observations plus
# [U]-B3. a3 True ONLY at ontagstates.inc:500 (aix idle 0,0 re-switch), a5/a6
# False at every observed site; acoSmoothAnimation=True on EVERY sampled ACL
# block with ZERO False in any *.acl (a constant authoring flag, NOT the per-call
# min/max switch, whose engine effect is [U]-B1); NumberCycle=1 everywhere
# sampled except balloon.acl:48,78 (0) and fasthorse/hardhorse.acl:210 (idle 10,
# then idle_rest 1). CyclesList=False / acoSkipActions polarity stay [U]-B3 (R-B3).
# NO behavioural branch on a3/a5/a6 anywhere in this module.
const DONOR_BLEND_ARGS_STATUS: String = "READ-ONLY DONOR ARGUMENT FACTS [O] — a3=True ONLY ontagstates.inc:500 (aix idle 0,0), False at every other site; a5/a6=False everywhere; acoSmoothAnimation=True every sampled ACL block (zero False in *.acl; constant authoring flag, NOT the per-call blend switch, effect [U]-B1); NumberCycle=1 except balloon.acl:48,78 (0) and fasthorse/hardhorse.acl:210 (idle 10, idle_rest 1); a3/a5/a6, CyclesList, acoSkipActions semantics UNVERIFIED [U]-B3 / capture R-B3 — no port branch on them"

# DEC-U-BLEND-OP §7 F2 [O] — the donor (6,8) fetch-window sites are donor DATA,
# not a port fetch rule. No readable donor text names a two-frame fetch or a
# snap-vs-interpolate rule ([U]-B2, capture R-B2). The port's single nearest
# exported frame, ascending tie-lower and 6-frame subset are PORT choices with
# zero donor counterpart. Movie's 0..5 window stays [U]-B4; "0,5" is NOT added.
const DONOR_BLEND_FETCH_SITES: String = "(6,8) FETCH-WINDOW SITES [O] — literal/install unit.script:10846-10847 + initial.inc:17-19; consume unit.script:10970,11016,11055,11100 + ontagstates.inc:474,513,596; THIRD literal progress.inc/nothing.inc:8-9,61 with 4-level walk cascade walk2->walk1->walk0->walk at :27-31; movie window 0..5 movie.script:644-646 [U]-B4. NO donor frame-fetch rule in readable text [U]-B2 / R-B2; nearest-single + ascending tie-lower + 6-frame subset are PORT choices, never blend evidence."

# Cycle policy sources (DEC-U §2) [O]. None of this is in the AAF (all rows
# carry only 'morph'); the flag lives in scripts/ACL:
#   loop  (bPlayOnce=False): showdebuganimations.inc:45-66,113-156 —
#     walk/walk0, idle/idle0/idle1/idle2, construct, work*, carry*.
#   once  (bPlayOnce=True): showdebuganimations.inc:121-123,129-131 —
#     attack0/attack1/attack2, death/death0/death1 (debug offers both for attacks).
#   mode mapping: movie.script:648-656 — bLoop→acmLoop, bOnce→acmPlayOnce, else acmNone.
#   sim: unit.script:10808-10809 (DoDeath acmPlayOnce/aamPlayOnce), :10852
#     (visual_stage_0 acmPlayOnce), :11076-11080 (hidden acmNone/aamNone).
#   ACL: cannon.acl:33-45 — attack0/attack1 CyclesList=False + NumberCycle=1
#     bracketed by OnAclAnimationReachedAttack / ...AttackEnd.
const DONOR_CYCLE_SITES: String = "loop/once bPlayOnce showdebuganimations.inc:45-66,113-156; acmLoop/acmPlayOnce/acmNone movie.script:648-656; DoDeath acmPlayOnce/aamPlayOnce unit.script:10808-10809,10852; hidden acmNone/aamNone unit.script:11076-11080; ACL tree shape [O] acoSmoothAnimation=True on every sampled block (zero False in *.acl, not a per-call switch); NumberCycle=1 cannon.acl:33-45 and infantry/peasant combat items, EXCEPT balloon.acl:48,78 (NumberCycle=0) and fasthorse/hardhorse.acl:210 (idle 10, idle_rest 1); attack0/attack1 bracketed by OnAclAnimationReachedAttack / OnAclAnimationReachedAttackEnd (cannon.acl:33-45, peasant.acl:315-349); AttackEnd body RECOVERED as a re-attack gate (_unit_TryAttack(...True) then SwitchTo('Nothing'), onaclanimationreachedattackend.inc:2-14), FIRING TICK [U]-C2; effects ride the OPENING Attack handler"

# Completion signals remain UNVERIFIED (DEC-U §3.2): clamp-at-last is a port
# stand-in, never a recovered signal. Both stay [U] with named captures.
const AAF_COMPLETION_STATUS: String = "PORT-LEVEL STAND-IN [U]-C1/C2 — no armed non-empty OnStateEndCyclesReached/OnStateFBEndCyclesReached/OnStateEndFrameReached handler found on the unit path (unit.script:10811-10815 clears all four to ''); death completion is the delayed DeathStage1 state (:11085); attack completion is the ACL AttackEnd RE-ATTACK GATE — body RECOVERED (_unit_TryAttack retrigger + SwitchTo('Nothing'), onaclanimationreachedattackend.inc:2-14; effects ride the OPENING Attack handler), FIRING TICK unrecovered [U]-C2. clamp-at-last-frame is a labelled stand-in, not donor parity. Captures R-C1 (hold vs return-to-idle, fixed-camera 30 Hz vertex-hash trace) and R-C2 (effect-to-handler-tick offsets) are required before any completion hook is fired."

# DEC-U-BLEND-OP §7 F4 [O] — two DISTINCT donor length laws. The sim uses an
# INCLUSIVE span frames = 1 + ef - sf, duration = frames/30 (unit.script:10774-
# 10777), which is the side _frame_at's span follows. Movie uses an EXCLUSIVE
# duration = (ef - sf)/30 (movie.script:854-858). Which law a blend window counts
# in is engine-side and stays [U]-B1/B2; no parity is claimed for either.
const DONOR_FRAME_LAW_STATUS: String = "DONOR FRAME LAWS [O] — sim INCLUSIVE frames=1+ef-sf, duration=frames/30 (unit.script:10774-10777); movie EXCLUSIVE duration=(ef-sf)/30 (movie.script:854-858); port _frame_at uses the sim inclusive span, never the movie law; interval factors walk=walkintervalfactor / death=0.7+random*0.6 / movie reset=1 / building construct=4; which law the blend window counts in UNVERIFIED [U]-B1 (R-B1) / [U]-B2 (R-B2), fixed-camera vertex-hash captures only"

# Orphan / readback-only / vocabulary-only vocabulary (DEC-U §1.1, T23–T25).
# These tokens exist in AAF data or as name constants but have NO donor
# set-site. They stay explicitly labelled; there is NO invented selector and
# NO fallback. The only port path is the caller's explicit anim_action request,
# availability-gated and gap-recorded (DEC-U §7 F7).
const DONOR_ORPHAN_TOKENS: Dictionary = {
	"reaction": "orphan: AAF peaukr.aaf:18 [456,481] but zero script/ACL refs (ev_P5a/P5d); no gc_anim_reaction constant; [U]-R / R-R",
	"attack2before": "orphan: AAF grenadier 630..663, no set-site; debug button showdebuganimations.inc:123 only; [U]-W / R-W",
	"attack2after": "orphan: AAF grenadier 664..679, no set-site; debug button showdebuganimations.inc:127 only; [U]-W / R-W",
	"walk1": "donor-dead name: selected unit.script:10946 but zero AAF rows in 246-file census; degrades to walk :11048-11051 [D]; never request",
}
# Prefix families: readback-only (prepare/unprepare/trans/walkprepare/
# walkunprepare — DEC-U T25, no anim := site) and vocabulary-only
# (turn*/collide* — no AAF rows, turning uses rotate calls, ev_P3a/P2d).
const DONOR_ORPHAN_PREFIXES: Array = ["prepare", "unprepare", "trans", "walkprepare", "walkunprepare", "turn", "collide"]
const AAF_ORPHAN_STATUS: String = "PORT-LEVEL LABEL ONLY [U]-A/R/W — orphan/readback-only/vocabulary-only tokens have NO donor set-site; no selector or fallback is invented; explicit anim_action request only, availability-gated and gap-recorded. Captures R-A/R-R/R-W required before any auto-trigger."

# T1–T26 rows of DEC-U §1.2. Each value is a READ-ONLY donor fact bundle:
#   token  : concrete AAF token(s) emitted [O]; Dictionary when a tag field
#            selects (resource/weapon/move), Array when child swap (T22).
#   blend  : DONOR_BLEND_* at emission [O]; Dictionary when idle/turn/walk split.
#   gate   : existence gate citation [O]; caller gates with has_action(sid, token).
#   cite   : donor set-site path:line [O].
#   port   : port-read status carried from DEC-U §1.2 (yes/partial/no).
#   orphan : true when no donor set-site exists (T23–T25) — explicit request only.
#   note   : extra donor fact (dead name / readback-only / vocabulary-only).
# No row is a port choice; no row selects from entity state by itself.
const DONOR_TRIGGER_TOKENS: Dictionary = {
	"T1": {"token": "workfood", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10865-10871; ontagstates.inc:302-304", "port": "yes", "orphan": false, "note": "iAction=extract + food; bSkip 0,0 early-out, sequencer skipped"},
	"T2": {"token": "workwood", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10872; ontagstates.inc:305-308", "port": "yes", "orphan": false, "note": "extract + wood; same early-out site as T1"},
	"T3": {"token": "workstone", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10873; ontagstates.inc:309-312", "port": "yes", "orphan": false, "note": "extract + stone; same early-out site as T1"},
	"T4": {"token": "construct", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10877; ontagstates.inc:316-343", "port": "yes", "orphan": false, "note": "iAction=build; aix path sets bBlend=True then funnels to same 0,0 early-out"},
	"T5": {"token": "attack0", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10878-10880; ontagstates.inc:321-325", "port": "yes", "orphan": false, "note": "iAction=attack + iWeapon in {none,0}"},
	"T6": {"token": "attack1", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10881; ontagstates.inc:324", "port": "partial", "orphan": false, "note": "iWeapon=1; port bullet-kind mapping [U]-W"},
	"T7": {"token": "attack2", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists unit.script:10888", "cite": "unit.script:10882; ontagstates.inc:325", "port": "partial", "orphan": false, "note": "iWeapon=2; no donor grenade-order proof; port explicit anim_action or fallback only [U]-W"},
	"T8": {"token": "idlefood", "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE}, "gate": "animidle -> gc_anim_idle unit.script:11036-11037", "cite": "unit.script:10901-10906,11016,11042; ontagstates.inc:372-388", "port": "yes", "orphan": false, "note": "food + idle/turn (deferred split); walk uses T9"},
	"T9": {"token": "walkfood", "blend": DONOR_BLEND_MINMAX, "gate": "animwalk -> gc_anim_walk unit.script:11048-11051", "cite": "unit.script:10905,11055", "port": "yes", "orphan": false, "note": "food + walk"},
	"T10": {"token": "idlewood", "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE}, "gate": "animidle -> gc_anim_idle unit.script:11036-11037", "cite": "unit.script:10910-10912", "port": "yes", "orphan": false, "note": "wood + idle/turn; same deferred split"},
	"T11": {"token": "walkwood", "blend": DONOR_BLEND_MINMAX, "gate": "animwalk -> gc_anim_walk unit.script:11048-11051", "cite": "unit.script:10913", "port": "yes", "orphan": false, "note": "wood + walk"},
	"T12": {"token": "idlestone", "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE}, "gate": "animidle -> gc_anim_idle unit.script:11036-11037", "cite": "unit.script:10916-10918", "port": "yes", "orphan": false, "note": "stone + idle/turn; same deferred split"},
	"T13": {"token": "walkstone", "blend": DONOR_BLEND_MINMAX, "gate": "animwalk -> gc_anim_walk unit.script:11048-11051", "cite": "unit.script:10919", "port": "yes", "orphan": false, "note": "stone + walk"},
	"T14": {"token": {"idle": "idle", "turn": "idle", "walk": "walk"}, "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE, "walk": DONOR_BLEND_MINMAX}, "gate": "animidle/animwalk fallbacks unit.script:11036-11037,11048-11051", "cite": "unit.script:10928-10933,10963-11018,11042,11055", "port": "yes", "orphan": false, "note": "no action/res + iWeapon=none; turn 6,8 code commented out :10963-10972 so turn falls to idle sticky"},
	"T15": {"token": {"idle": "idle0", "turn": "idle0", "walk": "walk0"}, "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE, "walk": DONOR_BLEND_MINMAX}, "gate": "animidle/animwalk fallbacks unit.script:11036-11037,11048-11051", "cite": "unit.script:10935-10940", "port": "yes", "orphan": false, "note": "iWeapon=0; only if sid exports them"},
	"T16": {"token": {"idle": "idle1", "turn": "idle1", "walk": "walk"}, "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE, "walk": DONOR_BLEND_MINMAX}, "gate": "walk1 dead name -> walk unit.script:11048-11051", "cite": "unit.script:10942-10947,11048-11051", "port": "yes", "orphan": false, "note": "iWeapon=1 selects walk1 :10946 but ZERO AAF rows in 246-file census; donor always degrades to walk [D]; never request walk1"},
	"T17": {"token": {"idle": "idle2", "turn": "idle2", "walk": "walk2"}, "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE, "walk": DONOR_BLEND_MINMAX}, "gate": "animidle/animwalk fallbacks unit.script:11036-11037,11048-11051", "cite": "unit.script:10949-10954", "port": "yes", "orphan": false, "note": "iWeapon=2; only if sid exports them"},
	"T18": {"token": "idle0", "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE}, "gate": "animidle existence re-check unit.script:10987-10988,11036-11037", "cite": "unit.script:10977-10978,11027; ontagstates.inc:435,485", "port": "no", "orphan": false, "note": "readback-only: current anim in {trans10,trans20,walk0,prepare0,attack0,idle0}; no donor anim := set-site; [U]-S dwell"},
	"T19": {"token": "idle1", "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE}, "gate": "animidle existence re-check unit.script:10987-10988,11036-11037", "cite": "unit.script:10979,11028; ontagstates.inc:436,486", "port": "no", "orphan": false, "note": "readback-only: {trans01,trans21,walk1,prepare1,attack1,idle1}; [U]-S dwell"},
	"T20": {"token": "idle2", "blend": {"turn": DONOR_BLEND_MINMAX, "idle": DONOR_BLEND_NONE}, "gate": "animidle existence re-check unit.script:10987-10988,11036-11037", "cite": "unit.script:10980,11029; ontagstates.inc:437,487", "port": "no", "orphan": false, "note": "readback-only: {trans02,trans12,walk2,prepare2,attack2,idle2}; [U]-S dwell"},
	"T21": {"token": {"none": "death", "0": "death0", "1": "death1", "2": "death2"}, "blend": DONOR_BLEND_MINMAX, "gate": "weapon token -> plain death unit.script:11092-11093,588-589", "cite": "unit.script:11086-11103; ontagstates.inc:583-596", "port": "yes", "orphan": false, "note": "iEssential=death; min/max then ResetFrameAnimationBlend for artillery + ReloadGameObjectProperties(basename+'_death'); 0.7+random*0.6 interval desync; port has no weapon split [U]-W2"},
	"T22": {"token": ["hoe", "axe", "pick", "hammer", "bag", "lumber", "cart", "hide"], "blend": "n/a", "gate": "peasant usage + child count unit.script:11068", "cite": "unit.script:6993-7009,11068-11069; movie.script:657; DEC_U_tool_attach.md §2.1/§2.3/§4", "port": "no", "orphan": false, "note": "child visibility swap, not an AAF token; stale 'tool prop has no .oss bone tracks [U]-T' is REFUTED: all 7 tool .oss exist under data/actors/units/attach/ (<6i k,fps,b,v,fc,t> peaukr_axe.oss k=483 fps=30 b=1 v=124 fc=138 t=130 20876 B; every tool b=1, k=k_body, same pid=aaf — peaukr_tools.actor:1-30 / peaukr.aaf; DEC_U_tool_attach.md §1.1,§2.3). Runtime swap [U]-T-A and port 3D render [U]-T-B remain unresolved with fixed-camera close-up captures; no parity claim"},
	"T23": {"token": "", "blend": "", "gate": "none found (ev_P5b/P5d)", "cite": "NO donor set-site: zero hits in unit.script and D:scripts/**; AAF rows grenadier 630..663 / 664..679; debug buttons showdebuganimations.inc:123,127", "port": "partial", "orphan": true, "note": "attack2before/attack2after reachable only via debug button or explicit anim_action; no sim trigger; [U]-W stays open"},
	"T24": {"token": "", "blend": "", "gate": "none found (ev_P5a/P5d)", "cite": "NO donor set-site: no gc_anim_reaction constant; zero hits unit.script, D:scripts/**, D:animations/acl/**; AAF row peaukr.aaf:18 456..481", "port": "partial", "orphan": true, "note": "reaction orphan on both sides; explicit anim_action only; [U]-R capture R-R"},
	"T25": {"token": "", "blend": "", "gate": "ACL-driven, no anim := set-site (ev_P5c)", "cite": "readback names only unit.script:10977-10980,11026-11029; fired by GameObjectSwitchToTreeAnimationCyclesBlendByHandle + ACL items chain", "port": "partial", "orphan": true, "note": "prepare*/unprepare*/trans*/walkprepare*/walkunprepare* readback-only; explicit anim_action only; [U]-A capture R-A"},
	"T26": {"token": "", "blend": "", "gate": "n/a (visibility state)", "cite": "unit.script:11076-11080; DoDeath :10801-10826", "port": "no", "orphan": false, "note": "iVisual=hide: DoDeath + acmNone/aamNone + invisible; no AAF token, no port hide path; outside this worker's port scope"},
}

# ══ DEC-U-STATE-MAP (2026-11-26) — donor-settled facts [O] ══════════════════════
# READ-ONLY labels/telemetry from docs/terrain_swarm_2026-11-26/reports/
# DEC_U_state_map.md (§1.1, §1.3, §2, §2.1, §3, §6 F1-F9, §7 claims). Everything
# below is DATA ONLY: no selector reads it, no completion hook is wired, no frame
# is interpolated and no entity state is read. The nine [U] captures (R-W, R-W2,
# R-S, R-A, R-R, R-C1, R-C2, R-B, R-T) stay OPEN with fixed-camera zero-mismatch
# termination (§4); no parity claim (§7 claim 9 denied) and no token, state or
# trigger is invented here.

# Corrected scoping (§1.1 / claim 2, ev_P3b/P4a-e/P5d) [O]. `Nothing` is the only
# readable engine state (nothing.inc:1-13); Work/Construct/Attack are ACL
# completion events (unit.aix:130-152), each ending SwitchTo('Nothing'); there is
# NO Build state/handler/constant — build/repair is order + action tag -> token
# `construct` (T4, unit.script:10877). Any "Build state" reading was a misnomer.
const DONOR_STATE_MAP_SCOPE: String = "DEC-U-STATE-MAP §1.1 [O] — ONLY readable unit engine state is Nothing (nothing.inc:1-13); Work/Construct/Attack are ACL completion events (OnAclAnimationReachedWork/Construct/Attack/AttackEnd, unit.aix:130-152) each ending SwitchTo('Nothing'); NO Build state/handler/constant — build/repair is order gc_obj_order_type_build/repair + action tag gc_statetag_action_build -> construct (T4, unit.script:10877). LABEL ONLY — no port Build state, no parity claim."

# Completion-event effects (§1.3/§2, claim 3, ev_P4b-e) [O]. Donor handler bodies,
# never port triggers; NONE is fired by this module ([U]-C1/C2 stays open).
const DONOR_STATE_MAP_COMPLETION: String = "DEC-U-STATE-MAP §1.3/§2 [O] completion events (NOT states, NOT port triggers): death -> OnDeath unit.script:11075 -> delayed DeathStage1 after gc_unit_deathtime_0 :11085 (four OnState*Reached cleared :10811-10816; artillery <basename>_death prop reload :11096-11099; 0.7+random*0.6 desync :11103); Attack -> ...Attack applies weapon cost/pause/damage/projectile per weapind (onaclanimationreachedattack.inc:15-29,54-110) and ...AttackEnd re-issues _unit_TryAttack(trg,True) unless guard/gainres/build (...attackend.inc:9-12); both end SwitchTo('Nothing'); Work -> res HP / resamount+1 on gainres (...work.inc:9,15-51) -> SwitchTo('Nothing') :59; Construct -> buildprogress/hp or repair HP on build/repair (...construct.inc:9,23-43) -> SwitchTo('Nothing') :51. NONE wired here; clamp-at-last remains the [U]-C1/C2 stand-in."

# Full T1-T26 per-site table (§2/§3). Every field is a [O] donor fact:
# state, token, blend, gate, cycle (loop/once/none), advancing, cite.
# No row selects from entity state by itself; no row is a port choice.
const DONOR_STATE_MAP_ROWS: Dictionary = {
	"T1": {"state": "iAction=extract + res=food", "token": "workfood", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "loop", "advancing": "OnAclAnimationReachedWork -> res HP/resamount+1 -> SwitchTo('Nothing')", "cite": "unit.script:10865-10871; ontagstates.inc:302-304"},
	"T2": {"state": "extract + wood", "token": "workwood", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "loop", "advancing": "OnAclAnimationReachedWork -> res HP/resamount+1 -> SwitchTo('Nothing')", "cite": "unit.script:10872; ontagstates.inc:305-308"},
	"T3": {"state": "extract + stone", "token": "workstone", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "loop", "advancing": "OnAclAnimationReachedWork -> res HP/resamount+1 -> SwitchTo('Nothing')", "cite": "unit.script:10873; ontagstates.inc:309-312"},
	"T4": {"state": "iAction=build (any res/weapon)", "token": "construct", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "loop", "advancing": "OnAclAnimationReachedConstruct -> build/repair HP -> SwitchTo('Nothing')", "cite": "unit.script:10877; ontagstates.inc:316-320", "note": "aix sets bBlend=True then funnels to same 0,0 switch :329-358; NO donor Build state — order/action tag only"},
	"T5": {"state": "attack + iWeapon in {none,0}", "token": "attack0", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "once (NumberCycle=1, bPlayOnce=True)", "advancing": "...Attack -> damage/cost/pause/projectile per weapind (...attack.inc:15-110) -> ...AttackEnd -> _unit_TryAttack re-issue (:9-12); both SwitchTo('Nothing')", "cite": "unit.script:10878-10880; ontagstates.inc:321-325"},
	"T6": {"state": "attack + iWeapon=1", "token": "attack1", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "once", "advancing": "same Attack/AttackEnd pair as T5", "cite": "unit.script:10881; ontagstates.inc:324"},
	"T7": {"state": "attack + iWeapon=2", "token": "attack2", "blend": DONOR_BLEND_NONE, "gate": "_unit_IsAnimationExists :10888", "cycle": "once", "advancing": "same Attack/AttackEnd pair as T5", "cite": "unit.script:10882; ontagstates.inc:325", "note": "grenadier attack2before/after have NO set-site — orphan T23"},
	"T8": {"state": "res=food + iMove in {idle,turn}", "token": "idlefood -> animidle", "blend": "turn 6,8 / idle 0,0", "gate": "animidle -> gc_anim_idle :11036-11037", "cycle": "loop", "advancing": "next tag evaluation (turn via rotate calls :10990-11008)", "cite": "unit.script:10901-10906,11016,11042; ontagstates.inc:372-388"},
	"T9": {"state": "food + walk", "token": "walkfood -> animwalk", "blend": DONOR_BLEND_MINMAX, "gate": "animwalk -> gc_anim_walk :11048-11051", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10905,11055"},
	"T10": {"state": "res=wood + idle/turn", "token": "idlewood -> animidle", "blend": "turn 6,8 / idle 0,0", "gate": "animidle -> gc_anim_idle :11036-11037", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10910-10912; ontagstates.inc:377-382"},
	"T11": {"state": "wood + walk", "token": "walkwood -> animwalk", "blend": DONOR_BLEND_MINMAX, "gate": "animwalk -> gc_anim_walk :11048-11051", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10913"},
	"T12": {"state": "res=stone + idle/turn", "token": "idlestone -> animidle", "blend": "turn 6,8 / idle 0,0", "gate": "animidle -> gc_anim_idle :11036-11037", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10916-10918"},
	"T13": {"state": "stone + walk", "token": "walkstone -> animwalk", "blend": DONOR_BLEND_MINMAX, "gate": "animwalk -> gc_anim_walk :11048-11051", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10919"},
	"T14": {"state": "no action/res + iWeapon=none + idle/turn/walk", "token": "idle/idle/walk", "blend": "turn 6,8 (code commented :10963-10972) / idle 0,0 / walk 6,8", "gate": "animidle/animwalk fallbacks :11036-11037,11048-11051", "cycle": "loop", "advancing": "turn: rotate calls; idle: 0,0 re-switch to prevent 2 shooting animation effect (:11042); walk: walkintervalfactor (:11054)", "cite": "unit.script:10928-10933,10963-11018,11042,11055"},
	"T15": {"state": "iWeapon=0 + idle/turn/walk", "token": "idle0/idle0/walk0", "blend": "turn 6,8 / idle 0,0 / walk 6,8", "gate": "animidle/animwalk fallbacks :11036-11037,11048-11051", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10935-10940", "note": "only where sid exports walk0/idle0"},
	"T16": {"state": "iWeapon=1 + idle/turn/walk", "token": "idle1/idle1/walk (walk1 dead name)", "blend": "turn 6,8 / idle 0,0 / walk 6,8", "gate": "walk1 donor-dead -> walk :11048-11051", "cycle": "loop (walk1 never plays)", "advancing": "next tag evaluation", "cite": "unit.script:10942-10947,11048-11051", "note": "walk1 selected :10946 but ZERO AAF rows; donor always degrades to walk [D]; never request"},
	"T17": {"state": "iWeapon=2 + idle/turn/walk", "token": "idle2/idle2/walk2", "blend": "turn 6,8 / idle 0,0 / walk 6,8", "gate": "animidle/animwalk fallbacks :11036-11037,11048-11051", "cycle": "loop", "advancing": "next tag evaluation", "cite": "unit.script:10949-10954", "note": "only where sid exports walk2/idle2"},
	"T18": {"state": "readback current in {trans10,trans20,walk0,prepare0,attack0,idle0}", "token": "idle0", "blend": "turn 6,8 / idle 0,0", "gate": "animidle existence re-check :10987-10988,11036-11037", "cycle": "loop", "advancing": "readback only — honoured when caller supplies current_anim; [U]-S dwell", "cite": "unit.script:10977-10978,11027; ontagstates.inc:435,485"},
	"T19": {"state": "readback current in {trans01,trans21,walk1,prepare1,attack1,idle1}", "token": "idle1", "blend": "turn 6,8 / idle 0,0", "gate": "animidle existence re-check :10987-10988,11036-11037", "cycle": "loop", "advancing": "readback only; [U]-S dwell", "cite": "unit.script:10979,11028; ontagstates.inc:436,486"},
	"T20": {"state": "readback current in {trans02,trans12,walk2,prepare2,attack2,idle2}", "token": "idle2", "blend": "turn 6,8 / idle 0,0", "gate": "animidle existence re-check :10987-10988,11036-11037", "cycle": "loop", "advancing": "readback only; [U]-S dwell", "cite": "unit.script:10980,11029; ontagstates.inc:437,487"},
	"T21": {"state": "iEssential=death + iWeapon in {none,0,1,2}", "token": "death/death0/death1/death2", "blend": "6,8 then ResetFrameAnimationBlend (artillery)", "gate": "weapon token -> plain death :11092-11093,588-589", "cycle": "once (DoDeath acmPlayOnce/aamPlayOnce :10808-10809; stage_0 :10851-10852)", "advancing": "OnDeath :11075 -> delayed DeathStage1 after gc_unit_deathtime_0 :11085; all four OnState*Reached blanked :10811-10816; artillery <basename>_death reload :11096-11099; 0.7+random*0.6 desync :11103", "cite": "unit.script:11086-11103; ontagstates.inc:583-596"},
	"T22": {"state": "peasant tool attach", "token": "hoe/axe/pick/hammer/bag/lumber/cart/hide (child swap, NOT an AAF token)", "blend": "n/a", "gate": "peasant usage + child-count guard :11068", "cycle": "n/a", "advancing": "SetGameObjectActorIndexByHandle + SetGameObjectVisible(child) :11069; per-action child swap/visibility DEC_U_tool_attach.md §2.1; [U]-T-A / [U]-T-B / R-T fixed-camera captures stay open", "cite": "unit.script:6993-7009,11068-11069; movie.script:657; DEC_U_tool_attach.md §2.1/§4"},
	"T23": {"state": "attack2before/attack2after", "token": "", "blend": "", "gate": "NO set-site (zero hits unit.script, D:scripts/**, D:animations/acl/**); debug buttons only", "cycle": "orphan-once", "advancing": "explicit anim_action only", "cite": "AAF grenadier 630..663 / 664..679; showdebuganimations.inc:123,127", "note": "[U]-W / R-W stays open"},
	"T24": {"state": "reaction", "token": "", "blend": "", "gate": "NO set-site; no gc_anim_reaction constant; zero refs incl. debug list", "cycle": "orphan (loop-shaped 26-frame row, never fired)", "advancing": "explicit anim_action only", "cite": "peaukr.aaf:18 456..481", "note": "[U]-R / R-R stays open"},
	"T25": {"state": "prepare*/unprepare*/trans*/walkprepare*/walkunprepare*", "token": "", "blend": "", "gate": "ACL-driven, no anim := set-site", "cycle": "once (transitional NumberCycle=1)", "advancing": "engine tree traversal; explicit anim_action only until R-A", "cite": "readback names only unit.script:10977-10980,11026-11029", "note": "[U]-A / R-A stays open"},
	"T26": {"state": "iVisual=hide (inside mine/transport)", "token": "", "blend": "n/a", "gate": "visibility state; no AAF token", "cycle": "none", "advancing": "SetGameObjectVisible(False) + playable/collision off", "cite": "unit.script:11076-11080; DoDeath :10801-10826", "note": "no port hide path; outside this worker's port scope"},
}

# Per-sid availability grouped by family (§2.1; 194 shipped AAF files, ev_P1b /
# ev_P1c-g). The selector is IDENTICAL for every sid; only the AAF row set differs
# and has_action(sid, token) (unit.script:369-373) resolves it per sid. A miss stays
# a per-sid HAS_ACTION_MISS gap — never a substitution. Group facts only: no sid
# is enumerated exhaustively beyond the cited representatives.
const DONOR_SID_FAMILIES: Dictionary = {
	"peasant_8_files": {"files": 8, "example": "peaukr.aaf (18 rows)", "present": "idle/walk/death/attack0/workfood/workwood/workstone/idlefood/idlewood/idlestone/walkfood/walkwood/walkstone/construct/prepare0/unprepare0; reaction row 456..481 exported; idle0 = idle 64..113 alias", "absent": "attack1/attack2 family, death0/1/2, walk0/1/2, idle1/2 distinct, attack2before/after (no set-site)", "families": "T1-T4, T8-T15, T21(death only), T22 attach"},
	"line_infantry": {"example": "musketeer.aaf (17 rows)", "present": "walk 1..24, walk0 26..49, attack1 99..124, idle/idle0/idle1 153..305, prepare*/unprepare*/trans*, death/death0/death1", "absent": "attack2 family, death2, all carry/work, reaction", "families": "T5(attack0 gap -> fallback), T6, T14-T16, T18-T19, T21(death/death0/death1)"},
	"grenadier": {"example": "grenadier.aaf (30 rows + 1 commented)", "present": "musketeer set + attack0 126..141, attack2 153..154 stub, attack2before 630..663, attack2after 664..679, death2, idle2, prepare2/unprepare2/trans*", "absent": "attack2before/after have no set-site (T23), all carry/work, reaction", "families": "T5-T7, T17, T20, T21 full set"},
	"artillery": {"example": "cannon.aaf (4 rows) + cannon_death.aaf", "present": "idle 1..1, walk 1..99, attack0/attack1 301..337 (same window)", "absent": "attack2, carry/work, prepare*/trans*, death0/1/2 distinct", "families": "T5-T6, T14-T16 degraded, T21 via _death props reload"},
	"ships": {"example": "yacht.aaf (4 rows, all 1..280); chaika/ferry/galley/frigate/battleship per ev_P5d", "present": "idle/walk/death/attack0 in one shared window", "absent": "everything else is a gap", "families": "T5, T14, T21(death)"},
	"cavalry": {"example": "fasthorse/hardhorse acl carry attack2 blocks (DEC_U ev_P4e); AAF rows not re-read in this pass", "present": "attack2 rows where their AAF declares them", "absent": "carry/work, reaction", "families": "T7 resolvable where declared"},
}
const DONOR_AAF_FALLBACK_ORDER: String = "DEC-U-STATE-MAP §2.1 [O] — selector identical for all 194 shipped AAFs; only row sets differ. A miss stays a per-sid HAS_ACTION_MISS gap, never a substitution; caller follows animwalk->walk, weapon death->death, animidle->idle, attack2->attack1->attack0->idle. No sid invents a token."
const DONOR_STATE_MAP_CAPTURES: String = "OPEN [U]-W/W2/S/A/R/C1/C2/B/T — DEC-U §4 fixed-camera zero-mismatch captures: R-W weapon->attack1/attack2 + grenade sequence; R-W2 death0/1/2 by weapon; R-S sticky T18-T20 dwell; R-A prepare/trans entry; R-R reaction; R-C1 hold vs return at last frame; R-C2 AttackEnd effect offsets; R-B blend 6/8 vs 0,0 response; R-T peasant tool attach. No trigger, token or state invented before these land; no parity claim (§7 claim 9 denied)."

# Key written onto an entity Dictionary (or Object metadata) per play() call.
const POSE_KEY: String = "anim3d_pose"

# Honest provenance tags for the payload. "donor_flat_root_morph" means the
# verts are real donor skin output; "donor_timing_only" means there was no
# readable skin for that sid and only the donor frame number is available.
const POSE_SOURCE_MORPH: String = "donor_flat_root_morph"
const POSE_SOURCE_TIMING: String = "donor_timing_only"
const MORPH_COORD: String = "donor Z-up metres; vertex i == assets/models/obj/<sid>.obj vertex i (bake_sprites.py:94 / convert_models.py:47)"
const SKIN_CITE: String = "variant3d/tools/bake_sprites.py:118-143 (qmat + skin)"
const OSS_CITE: String = "data/actors/units/<sid>.oss <6i k,fps,b,v,fc,t> (docs/decomp/DC_FORMATS.md:46-64)"

# V7-78: shipped donor-derived skin assets, written offline by
# variant3d/tools/convert_skins.py. Never read the private donor at runtime.
const SKIN_INDEX_PATH: String = "res://assets/models/skin/index.json"
const SKIN_ASSET_DIR: String = "res://assets/models/skin/"
const SHIPPED_SKIN_SOURCE: String = "donor_oss_subset_v1"

# ── DEC-U-TOOL-ATTACH / IMPL-TOOL-WIRING (2026-11-26) — additive tool attach ──
# IMPL-TOOL-BAKER derived 63 tool skins (9 peasant sids × 7 tools) into
# res://assets/models/skin/attach/<sid>_<tool>.json and appended ONLY an
# `attach` block to each peasant index entry. No body entry, frame list, AAF
# window or roster skin is touched by this reader.
const TOOL_SKIN_SUBDIR: String = "attach/"
# Registration key prefix: tool skins are loaded through the SAME shipped-skin
# loader but registered under TOOL|<sid>|<tool>, never under the roster sid.
const TOOL_SKIN_KEY_PREFIX: String = "TOOL|"
# actorInd is a donor constant (dmscript.global:928-934), not a port choice;
# the index carries the action->tool map but not the slot index.
const ATTACH_ACTOR_INDEX: Dictionary = {
	"axe": 0, "bag": 1, "cart": 2, "hammer": 3,
	"hoe": 4, "lumber": 5, "pick": 6,
}
const TOOL_ATTACH_CITE: String = "docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md §2.1,§4,§5 C3/C4; data/scripts/lib/unit.script:6991-7012,11068-11069; data/scripts/dmscript.global:928-934; data/actors/units/attach/<base>_tools.actor:1-30; data/materials/units/units.mat:18-19"
const TOOL_ATTACH_STATUS: String = "PORT APPROXIMATION — NOT DONOR PARITY — donor tool attach: exported tool skin sampled at the BODY's own donor frame (single bone 0, no new window, no alias beyond attack->attack0, no blend); tool material peaaustools.dds via approved DDS->PNG; identity relative transform; [U]-T-A (runtime swap) and [U]-T-B (port pixel proof) stay UNRESOLVED with fixed-camera close-up captures; no parity claim"
const TOOL_HIDDEN_STATUS: String = "UNRESOLVED [U]-T — no mapped tool for this action (''/walk/idle/death/reaction/else): child hidden, never a body mesh and never another nation's tool (DEC_U_tool_attach.md §2.1)"
const TOOL_DATA_GAP_STATUS: String = "UNRESOLVED [U]-T — DATA GAP: attach slot missing / not exported / no body frame / no exported tool frame at the body's donor frame; child hidden, no synthesis and no fallback (DEC_U_tool_attach.md §4)"

var _game = null
var _entities = null
var _skins: Dictionary = {}     # sid -> normalised donor skin Dictionary
var last_error: String = ""     # reason for the last failed parse/register
# V7-78 automatic shipped-skin load state (lazy, once, deterministic).
var _shipped_loaded: bool = false
var _shipped_count: int = 0
var _shipped_bytes: int = 0
var _shipped_error: String = ""
# DEC-U-TOOL-ATTACH: the same parsed index is kept for attach_for(); no second
# file read and no separate source of truth for the per-sid attach block.
var _shipped_index: Dictionary = {}
# DEC-U-AAF-TRIGGERS §7 F2: EMPTY completion callback registry. Wired ONLY when
# captures R-C1/R-C2 land; until then nothing invokes it and clamp-at-last stays
# the labelled [U]-C1/C2 stand-in. Never a fabricated completion event.
var _aaf_completion_hook: Callable = Callable()

# P10 (INFERRED): per-frame caches. Keyed only by immutable inputs; cleared by
# _clear_frame_caches() whenever _skins changes. Cached morph Dictionaries and
# verts are shared READ-ONLY (world3d_entities.gd:2077-2124,
# t_motion_capture.gd:234-244). No label, clip table or test is touched.
var _range_cache: Dictionary = {}   # "sid|action" -> resolved AAF/shipped row
var _morph_cache: Dictionary = {}   # "sid|frame"  -> _morph_fields() result
var _morph_keys: Array[String] = [] # FIFO eviction order for _morph_cache
var _skin_scratch: Dictionary = {}  # sid -> {"mats":Array,"poss":Array}
const MORPH_CACHE_MAX: int = 512    # INFERRED cap; speed benefit UNVERIFIED

# P10: invalidate every frame cache when the skin set changes. Called only on
# register/unregister/shipped-load (rare), never from the per-frame path.
func _clear_frame_caches() -> void:
	_range_cache.clear()
	_morph_cache.clear()
	_morph_keys.clear()
	_skin_scratch.clear()


# ---------------------------------------------------------------------------
# EXACT CONTRACT API (V73_ATOMIC_CONTRACT.md:17 — signatures unchanged)
# ---------------------------------------------------------------------------

# Store the sim and the 3D entity renderer. Neither is used to fabricate rig
# data: this module only computes donor frame numbers and samples donor skin.
func bind(game, entities) -> void:
	_game = game
	_entities = entities
	_ensure_shipped_skins()


# Resolve action -> donor frame at donor 30 fps, sample the registered donor
# skin at that frame when one exists, and publish the pose request.
# "ok" means the DONOR-TIMED CLOCK was computed; it never means donor-parity
# visual deformation was achieved.
# DEC-U-BLEND-OP §7 F3: optional `requested_blend` is LOGGED INTENT ONLY. The
# caller (world3d_entities.gd, not in this worker's scope) may pass
# resolve_donor_action()["blend"] ("0,0"/"6,8"); it is threaded into
# _frame_blend_fields telemetry ONLY, never into pose math. "0,5" is NOT added
# until R-B4 lands. All existing 3-arg callers keep identical behaviour.
func play(e, action, t, requested_blend: String = DONOR_BLEND_MINMAX):
	_ensure_shipped_skins()
	var requested := str(action)
	var donor_action: String = str(ACTION_ALIAS.get(requested, requested))
	var aliased: bool = donor_action != requested
	var sid := _sid_of(e)
	var skin: Dictionary = {}
	if _skins.has(sid):
		skin = _skins[sid] as Dictionary
	# PORT1TO1-ENT1TO1 / D1: a shipped skin carries its unit's OWN donor AAF
	# ranges. The peaukr.AAF_ACTIONS table is used only for an unregistered sid
	# and is tagged in the returned pose (never a silent per-sid substitution).
	var row: Array = _action_range_for(sid, donor_action)
	if row.is_empty():
		return _unknown(requested, aliased, sid)

	var first: int = int(row[0])
	var last: int = int(row[1])
	var line: int = int(row[2])
	var kind: String = str(row[3])
	var donor_cite: String = str(row[4]) if row.size() >= 5 else "data/animations/aaf/peaukr.aaf:%d" % line
	var action_source: String = str(row[5]) if row.size() >= 6 else "per_sid_aaf"
	var frame: int = _frame_at(first, last, t, donor_action)

	var morph := _morph_fields(skin, frame, sid)
	var sample_frame: int = int(morph.get("sample_frame", frame))
	var blend := _frame_blend_fields(frame, sample_frame, requested_blend)
	var pose: Dictionary = {
		"action": donor_action,
		"requested": requested,
		"frame": sample_frame,
		"requested_frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": kind,
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
		"sid": sid,
		"pose_source": str(morph["pose_source"]),
		"donor_action_source": action_source,
		"aaf_loop_status": AAF_LOOP_STATUS,
		"aaf_cycle": "once_clamp" if _is_once_action(donor_action) else "loop",
	}
	for key in blend.keys():
		pose[key] = blend[key]
	for key in morph.keys():
		pose[key] = morph[key]
	_publish(e, pose)
	var out := {
		"ok": true,
		"action": donor_action,
		"requested": requested,
		"aliased": aliased,
		"frame": sample_frame,
		"sample_frame": sample_frame,
		"requested_frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": kind,
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED — flat-root donor skin, no bone hierarchy, visual A/B pending",
		"verified": false,
		"cycle": "once_clamp" if _is_once_action(donor_action) else "loop",
		"aaf_loop_status": AAF_LOOP_STATUS,
		"frame_blend_status": FRAME_BLEND_STATUS,
		"donor_action_source": action_source,
		"aaf_fallback_status": AAF_FALLBACK_STATUS,
		"alias_status": ACTION_ALIAS_STATUS,
		"sid": sid,
		"pose_source": str(morph["pose_source"]),
		"skin_registered": not skin.is_empty(),
		"vertex_count": int(morph["vertex_count"]),
		"pose": pose,
	}
	for key in blend.keys():
		out[key] = blend[key]
	return out


# ---------------------------------------------------------------------------
# DONOR SKIN DATA — read-only translation of bake_sprites.read_oss / skin
# ---------------------------------------------------------------------------

# Parse a donor .oss file into the normalised skin Dictionary consumed by
# skin_vertices(). Private-use, read-only; the caller supplies a readable path
# (the shipped game must NOT rely on this — register_skin() takes the converted
# data in production). Mirrors bake_sprites.py:91-103 byte for byte.
# Returns {} on failure; last_error holds the reason.
func parse_donor_oss(path: String) -> Dictionary:
	last_error = ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		last_error = "cannot open donor .oss: " + path
		return {}
	var file_bytes: int = f.get_length()
	# Donor files are little-endian ('<6i', '<3f', ...). Godot's get_32/get_float
	# default to NATIVE byte order, which is little-endian on the target (Win32);
	# documented rather than guessed.
	var k: int = f.get_32()
	var fps: int = f.get_32()
	var bones: int = f.get_32()
	var vcount: int = f.get_32()
	var fcount: int = f.get_32()
	var tcount: int = f.get_32()
	if k <= 0 or k > 100000 or fps <= 0 or bones <= 0 or bones > 4096 \
			or vcount <= 0 or vcount > 200000 or fcount < 0 or fcount > 500000 \
			or tcount < 0 or tcount > 500000:
		last_error = "implausible .oss header k=%d fps=%d b=%d v=%d fc=%d t=%d" % [k, fps, bones, vcount, fcount, tcount]
		f.close()
		return {}

	var verts := PackedVector3Array()
	verts.resize(vcount)
	for i in range(vcount):
		verts[i] = Vector3(f.get_float(), f.get_float(), f.get_float())
	# Faces, UVs and UV-face indices are not needed by the skinner; skip them
	# by SEEK, never by inventing replacements (bake_sprites.py:95-97).
	f.seek(f.get_position() + fcount * 12 + tcount * 8 + fcount * 12)
	var w_bone := PackedInt32Array()
	var w_val := PackedFloat32Array()
	var w_off := PackedInt32Array()
	w_off.resize(vcount + 1)
	for i in range(vcount):
		w_off[i] = w_bone.size()
		var n: int = f.get_32()
		if n < 0 or n > 16:
			last_error = "implausible weight count %d at vertex %d" % [n, i]
			f.close()
			return {}
		for _j in range(n):
			w_bone.append(f.get_32())
			w_val.append(f.get_float())
	w_off[vcount] = w_bone.size()
	var anim := PackedFloat32Array()
	anim.resize(bones * k * 7)
	for i in range(anim.size()):
		anim[i] = f.get_float()
	var consumed: int = f.get_position()
	f.close()
	if consumed != file_bytes:
		last_error = "size closure failed: consumed %d of %d bytes" % [consumed, file_bytes]
		return {}
	return {
		"ok": true,
		"source": "donor_oss",
		"path": path,
		"k": k,
		"fps": fps,
		"bones": bones,
		"v": vcount,
		"verts": verts,
		"w_bone": w_bone,
		"w_val": w_val,
		"w_off": w_off,
		"anim": anim,
		"bytes": consumed,
		"cite": OSS_CITE,
		"skin_math": SKIN_CITE,
	}


# Register a normalised skin (from parse_donor_oss) OR a raw Dictionary in the
# read_oss shape (verts/weights/anim as nested Arrays, e.g. from a converted
# JSON). No motion is invented: only the arrays donor actually contains.
func register_skin(sid, skin: Dictionary) -> bool:
	last_error = ""
	var key := str(sid)
	if key == "":
		last_error = "empty sid"
		return false
	var norm: Dictionary = skin
	if not skin.has("w_off"):
		norm = _normalise_raw(skin)
	if norm.is_empty():
		return false
	if not _valid_skin(norm):
		return false
	_skins[key] = norm
	_clear_frame_caches()
	return true


func has_skin(sid) -> bool:
	_ensure_shipped_skins()
	return _skins.has(str(sid))


# PORT1TO1-ENT1TO1 (D1/D5): per-sid action availability. Reads the shipped
# skin's OWN donor AAF `actions` export (skin/<sid>.json), never the peaukr
# table. An unregistered sid has no donor AAF evidence here and returns false,
# so a caller cannot silently reuse another unit's clip.
func has_action(sid, action) -> bool:
	_ensure_shipped_skins()
	var s := str(sid)
	if not _skins.has(s):
		return false
	var skin: Dictionary = _skins[s] as Dictionary
	if not bool(skin.get("compact", false)):
		return false
	var actions: Dictionary = skin.get("actions", {})
	return actions.has(str(action))


func unregister_skin(sid) -> void:
	_skins.erase(str(sid))
	_clear_frame_caches()


func skin_info(sid) -> Dictionary:
	_ensure_shipped_skins()
	var skin: Dictionary = {}
	if _skins.has(str(sid)):
		skin = _skins[str(sid)] as Dictionary
	if skin.is_empty():
		return {"registered": false, "sid": str(sid)}
	var out := {
		"registered": true,
		"sid": str(sid),
		"source": str(skin.get("source", "?")),
		"k": int(skin.get("k", 0)),
		"fps": int(skin.get("fps", 0)),
		"bones": int(skin.get("bones", 0)),
		"verts": int(skin.get("v", 0)),
		"weight_pairs": (skin["w_bone"] as PackedInt32Array).size(),
		"cite": str(skin.get("cite", "")),
		"skin_math": str(skin.get("skin_math", "")),
	}
	if bool(skin.get("compact", false)):
		out["compact"] = true
		out["shipped_asset"] = str(skin.get("asset", ""))
		out["sample_frames"] = (skin.get("frames", []) as Array).duplicate()
		out["actions"] = (skin.get("actions", {}) as Dictionary).keys()
		out["label"] = str(skin.get("label", PORT_LABEL))
		out["visual"] = "UNVERIFIED"
	return out


# Parse a donor file AND register it under sid. Convenience for tools/probes.
func load_skin_from_donor(sid, path: String) -> bool:
	var skin := parse_donor_oss(path)
	if skin.is_empty():
		return false
	return register_skin(str(sid), skin)


# V7-78 observability: how many shipped skins were auto-registered, from which
# index and with what total on-disk size. No donor path is touched at runtime.
func shipped_skin_info() -> Dictionary:
	_ensure_shipped_skins()
	return {
		"auto_loaded": _shipped_count,
		"index": SKIN_INDEX_PATH,
		"asset_dir": SKIN_ASSET_DIR,
		"total_bytes": _shipped_bytes,
		"error": _shipped_error,
		"registered_sids": _skins.keys(),
		"label": PORT_LABEL,
		"visual": "UNVERIFIED",
	}


# Honest summary of the readable / unreadable split for integration agents.
func capabilities() -> Dictionary:
	_ensure_shipped_skins()
	return {
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"shipped_skins": _shipped_count,
		"shipped_skin_bytes": _shipped_bytes,
		"shipped_skin_index": SKIN_INDEX_PATH,
		"readable": [
			"donor .oss header <6i k,fps,b,v,fc,t> (docs/decomp/DC_FORMATS.md:46-64)",
			"donor .oss verts / per-vertex bone+weight pairs / flat bone tracks (bake_sprites.py:91-103)",
			"donor AAF inclusive action ranges (peaukr.aaf:3-20; per-sid exported windows after DEC-U-AAF-ART C1)",
			"flat-root skin output via bake_sprites.skin (bake_sprites.py:118-143)",
			"donor cycle intent bPlayOnce: attacks+deaths once, walks/idles/work/construct loop (showdebuganimations.inc:45-66,113-155 carried)",
			"donor blend literals minFrameBlend=6/maxFrameBlend=8 (unit.script:10846-10847, initial.inc:17-19)",
		],
		"unreadable": [
			"donor bone PARENT hierarchy (V7-2 3.3 / Table B1)",
			"donor-to-god quaternion convention (V7-2 open question 2)",
			"AAF loop/clamp flag (peaukr.aaf:3-20 carries only 'morph'); port cycle policy applied from scripts, [U] U2",
			"attack/death completion signal (acmPlayOnce/aamPlayOnce, unit.script:10808-10809,10852), [U] U2",
			"minFrameBlend/maxFrameBlend engine semantics, [U] U2 (DEC_U §4 captures)",
		],
		"aaf_loop_status": AAF_LOOP_STATUS,
		"frame_blend_status": FRAME_BLEND_STATUS,
		# DEC-U-STATE-MAP — additive LABEL/TELEMETRY only; no behaviour change.
		"donor_state_map_scope_label": DONOR_STATE_MAP_SCOPE,
		"donor_state_map_rows": DONOR_STATE_MAP_ROWS.duplicate(true),
		"donor_state_map_completion_label": DONOR_STATE_MAP_COMPLETION,
		"donor_state_map_sid_families": DONOR_SID_FAMILIES.duplicate(true),
		"donor_state_map_fallback_order": DONOR_AAF_FALLBACK_ORDER,
		"donor_state_map_captures": DONOR_STATE_MAP_CAPTURES,
		"coord": MORPH_COORD,
		"visual": "UNVERIFIED",
		"registered_sids": _skins.keys(),
	}


# ---------------------------------------------------------------------------
# DONOR MORPH SAMPLING
# ---------------------------------------------------------------------------

# Exact flat-root skin at donor frame `fr`, copied from bake_sprites.skin
# (:131-143) with qmat from :118-129. Output is donor Z-up metres, index i ==
# bind vertex i == OBJ vertex i. If ref_frame >= 0, subtract the bone-0 root
# translation delta the same way bake_sprites.bake_unit does (:310-342); the
# default (-1) leaves the raw skin output untouched.
# P10: public signature unchanged; sid="" keeps original per-call buffers for
# tool/probe callers. The registered-skin hot path passes a sid so the impl
# reuses scratch buffers instead of allocating per bone per frame.
func skin_vertices(skin: Dictionary, fr: int, ref_frame: int = -1) -> PackedVector3Array:
	return _skin_vertices_impl(skin, fr, ref_frame, "")

func _skin_vertices_impl(skin: Dictionary, fr: int, ref_frame: int, sid: String) -> PackedVector3Array:
	var empty := PackedVector3Array()
	if skin.is_empty() or not _valid_skin(skin):
		last_error = "skin_vertices: invalid skin"
		return empty
	var k: int = int(skin["k"])
	var bones: int = int(skin["bones"])
	var compact: bool = bool(skin.get("compact", false))
	# V7-78: a shipped skin shares this same skinner but stores only the
	# exported donor frames; map donor frame -> compact slot position first.
	var nf: int = int(skin.get("frame_count", k))
	var frame: int = _nearest_local(skin, fr) if compact else clampi(fr, 0, k - 1)
	var anim: PackedFloat32Array = skin["anim"]
	# P10: reuse one flat matrix buffer + one position buffer per sid.
	# P10-prec: the matrix buffer MUST be a PackedFloat32Array so each
	# coefficient is rounded to float32 exactly as _qmat() did. Reading it
	# back from the scratch Dictionary may copy-on-write, so store it back
	# once per sample (one packed-array copy, not B per-bone allocations).
	var mats: PackedFloat32Array = PackedFloat32Array()
	var poss: Array = []
	if sid != "" and _skin_scratch.has(sid):
		var sc: Dictionary = _skin_scratch[sid]
		mats = sc.get("mats", PackedFloat32Array())
		poss = sc.get("poss", [])
	if mats.size() != bones * 9:
		mats.resize(bones * 9)
	if poss.size() != bones:
		poss.resize(bones)
	for bi in range(bones):
		var base := (bi * nf + frame) * 7
		poss[bi] = Vector3(anim[base], anim[base + 1], anim[base + 2])
		_qmat_into(mats, bi * 9, anim[base + 3], anim[base + 4], anim[base + 5], anim[base + 6])
	if sid != "":
		_skin_scratch[sid] = {"mats": mats, "poss": poss}
	var rx := 0.0
	var ry := 0.0
	if ref_frame >= 0:
		var rb: int = _nearest_local(skin, ref_frame) if compact else clampi(ref_frame, 0, k - 1)
		var hb := rb * 7
		var fb := frame * 7
		rx = anim[fb] - anim[hb]
		ry = anim[fb + 1] - anim[hb + 1]
	var verts: PackedVector3Array = skin["verts"]
	var w_bone: PackedInt32Array = skin["w_bone"]
	var w_val: PackedFloat32Array = skin["w_val"]
	var w_off: PackedInt32Array = skin["w_off"]
	var out := PackedVector3Array()
	out.resize(verts.size())
	for i in range(verts.size()):
		var vv: Vector3 = verts[i]
		var sx := 0.0
		var sy := 0.0
		var sz := 0.0
		for j in range(w_off[i], w_off[i + 1]):
			var bi: int = w_bone[j]
			var w: float = w_val[j]
			var mo: int = bi * 9
			var p: Vector3 = poss[bi]
			sx += w * (mats[mo] * vv.x + mats[mo + 1] * vv.y + mats[mo + 2] * vv.z + p.x)
			sy += w * (mats[mo + 3] * vv.x + mats[mo + 4] * vv.y + mats[mo + 5] * vv.z + p.y)
			sz += w * (mats[mo + 6] * vv.x + mats[mo + 7] * vv.y + mats[mo + 8] * vv.z + p.z)
		out[i] = Vector3(sx - rx, sy - ry, sz)
	return out


# Frames a..b in DONOR ORDER, copied from bake_sprites.sample (:145-152).
# Python's round() is half-to-even; _py_round_i() reproduces it so sampled
# morph targets are byte-for-byte the same frame indices the 2D bake uses.
# DEC-U-BLEND-OP §7 F7 LABEL ONLY: this bake-subset stride (_py_round_i /
# sample_frames) reproduces the 2D bake, NOT any donor blend fetch. Never cite
# it as blend evidence [U]-B2 / R-B2. No math change here.
func sample_frames(first: int, last: int, n: int) -> Array[int]:
	var out: Array[int] = []
	if last <= first:
		out.append(first)
		return out
	var total: int = last - first + 1
	if total <= n:
		for fr in range(first, last + 1):
			out.append(fr)
		return out
	if n > 1:
		for i in range(n):
			out.append(first + _py_round_i(float(last - first) * float(i) / float(n - 1)))
		return out
	out.append(first)
	return out


# THE HANDOFF CALL. Returns the donor morph target for `e` (entity Dictionary,
# Object with a `sid` property, or a sid String), action and sim time t.
# `verts` is a PackedVector3Array of donor-space skinned vertices (empty when
# no skin is registered); `pose_source` says which case applies. The entity
# renderer maps these through its existing bbox/Y-up transform and writes them
# to the mesh vertex buffer. No visual parity is claimed.
# DEC-U-BLEND-OP §7 F3: optional `requested_blend` mirrors play() — the caller
# may pass resolve_donor_action()["blend"] as LOGGED INTENT into _frame_blend_fields
# only. `sample_frame` is computed before that call and is NEVER branched on it;
# no interpolation and no "0,5" value until R-B4. 3-arg callers are unchanged.
func pose_for(e, action, t, requested_blend: String = DONOR_BLEND_MINMAX) -> Dictionary:
	_ensure_shipped_skins()
	var requested := str(action)
	var donor_action: String = str(ACTION_ALIAS.get(requested, requested))
	var sid := _sid_of(e)
	var skin: Dictionary = {}
	if _skins.has(sid):
		skin = _skins[sid] as Dictionary
	var row: Array = _action_range_for(sid, donor_action)
	if row.is_empty():
		var u := _unknown(requested, donor_action != requested, sid)
		u["verts"] = PackedVector3Array()
		u["pose_source"] = POSE_SOURCE_TIMING
		u["coord"] = MORPH_COORD
		return u
	var first: int = int(row[0])
	var last: int = int(row[1])
	var line: int = int(row[2])
	var frame: int = _frame_at(first, last, t, donor_action)
	var donor_cite: String = str(row[4]) if row.size() >= 5 else "data/animations/aaf/peaukr.aaf:%d" % line
	var action_source: String = str(row[5]) if row.size() >= 6 else "per_sid_aaf"
	var morph := _morph_fields(skin, frame, sid)
	var sample_frame: int = int(morph.get("sample_frame", frame))
	var blend := _frame_blend_fields(frame, sample_frame, requested_blend)
	var out: Dictionary = {
		"ok": true,
		"action": donor_action,
		"requested": requested,
		"sid": sid,
		"frame": sample_frame,
		"requested_frame": frame,
		"fps": DONOR_FPS,
		"range": [first, last],
		"donor": donor_cite,
		"kind": str(row[3]),
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
		"coord": MORPH_COORD,
		"cycle": "once_clamp" if _is_once_action(donor_action) else "loop",
		"donor_action_source": action_source,
		"aaf_loop_status": AAF_LOOP_STATUS,
		"frame_blend_status": FRAME_BLEND_STATUS,
	}
	for key in blend.keys():
		out[key] = blend[key]
	for key in morph.keys():
		out[key] = morph[key]
	return out


# Produce the morph fields once, shared by play() and pose_for().
# P10: morph output is a pure function of (skin, frame). Repeated frames are
# served from cache with zero skinning (idle / single-frame clips / off-screen
# units re-synced at the same donor clock).
func _morph_fields(skin: Dictionary, frame: int, sid: String = "") -> Dictionary:
	var ck := sid + "|" + str(frame)
	if sid != "" and _morph_cache.has(ck):
		return _morph_cache[ck] as Dictionary
	if skin.is_empty():
		return {
			"pose_source": POSE_SOURCE_TIMING,
			"skin_registered": false,
			"vertex_count": 0,
			"verts": PackedVector3Array(),
			"frame_clamped": false,
			"sample_frame": frame,
			"skin_math": "NONE — timing only",
		}
	var k: int = int(skin["k"])
	var src_frame: int = _nearest_exported_frame(skin, frame) if bool(skin.get("compact", false)) else frame
	var verts := _skin_vertices_impl(skin, src_frame, -1, sid) if sid != "" \
			else skin_vertices(skin, src_frame)
	var morph := {
		"pose_source": POSE_SOURCE_MORPH,
		"skin_registered": true,
		"vertex_count": verts.size(),
		"verts": verts,
		"frame_clamped": frame < 0 or frame >= k,
		"sample_frame": src_frame,
		"skin_math": str(skin.get("skin_math", SKIN_CITE)),
	}
	if sid != "":
		_morph_cache[ck] = morph
		_morph_keys.append(ck)
		if _morph_keys.size() > MORPH_CACHE_MAX:
			_morph_cache.erase(_morph_keys.pop_front())
	return morph


# ---------------------------------------------------------------------------
# Helpers (donor-backed, deterministic, no RNG)
# ---------------------------------------------------------------------------

# Inclusive-frame lookup. Returns {} when the donor AAF has no such action.
func action_info(action) -> Dictionary:
	var key := str(action)
	if ACTION_ALIAS.has(key):
		key = str(ACTION_ALIAS[key])
	if not AAF_ACTIONS.has(key):
		return {}
	var row: Array = AAF_ACTIONS[key]
	return {
		"action": key,
		"first": int(row[0]),
		"last": int(row[1]),
		"donor": "data/animations/aaf/peaukr.aaf:%d" % int(row[2]),
		"kind": str(row[3]),
	}


# DEC-U-AAF-ART C2: donor cycle policy. The AAF carries only 'morph'; loop /
# one-shot flags live in scripts/ACL (DANIM_01 §4.3 carried): bPlayOnce=True for
# attacks+deaths, False for walks/idles/work/construct
# (showdebuganimations.inc:45-66,113-155). Death/attack* therefore clamp at the
# last donor frame; every other token loops. The completion SIGNAL for the
# clamp (acmPlayOnce/aamPlayOnce, unit.script:10808-10809,10852) is unrecovered
# ([U] U2), so clamp-at-last is a labelled port stand-in, not donor parity.
func _is_once_action(action: String) -> bool:
	for token in ["death", "death0", "death1", "death2"]:
		if action == str(token):
			return true
	return _is_attack_action(action)


# Explicit donor attack tokens only; the port-only "attack" alias is resolved
# to attack0 before this is called (ACTION_ALIAS_STATUS). No synthesized art.
func _is_attack_action(action: String) -> bool:
	for token in AAF_ATTACK_TOKENS:
		if action == str(token):
			return true
	return false


# Donor frame index for time t in seconds at the donor's 30 fps. Frame a
# occupies [a/30, (a+1)/30). Loop actions fposmod the span; once actions clamp
# to the last donor frame. The optional 4th arg keeps V7-64 3-arg callers on
# the original loop clock while named actions get the donor cycle policy.
func _frame_at(first: int, last: int, t, action: String = "") -> int:
	var span: int = maxi(1, last - first + 1)
	var donor_s := float(t) * DONOR_FPS
	var offset: int
	if _is_once_action(action):
		offset = int(floor(donor_s))
		if offset < 0:
			offset = 0
		if offset >= span:
			offset = span - 1
		return first + offset
	offset = int(floor(fposmod(donor_s, float(span))))
	if offset >= span:
		offset = span - 1
	return first + offset


# DEC-U-AAF-ART C2: nearest-frame diagnostic window over the deterministic
# 6-frame subset. Donor minFrameBlend=6/maxFrameBlend=8 literals are carried;
# their ENGINE semantics are not recovered ([U] U2). This reports the offset
# and whether it falls inside the window; it never interpolates and never
# invents a donor frame.
# DEC-U-BLEND-OP §7 F1 [O]: under the donor-proven "0,0" bypass (V1-V7 in
# DONOR_BLEND_BYPASS_SITES) the displayed frame MUST equal the requested clock
# frame — any nearest-frame snap there contradicts unit.script:10891-10893,
# :11042. ENFORCED AS LABELED STATUS ONLY: `blend_bypass_violation` is set when
# a "0,0" caller supplies sample_frame != requested_frame; pose math is NOT
# changed, no weight is invented and no hard assert is raised (no behaviour
# change); the weight curve itself stays [U]-B1 / R-B1 (fixed-camera vertex-hash
# step-response capture), never named by a guessed w(t).
# F2: `fetch_policy` labels the single-nearest fetch as a PORT choice
# [U]-B2; donor (6,8)/(0,5) window sites are donor data in DONOR_BLEND_FETCH_SITES.
# F8: argument facts (a3/a5/a6, acoSmoothAnimation, NumberCycle) are read-only
# in DONOR_BLEND_ARGS_STATUS [U]-B3 — no branch on them here.
func _frame_blend_fields(requested_frame: int, sample_frame: int, requested_blend: String = DONOR_BLEND_MINMAX) -> Dictionary:
	var delta: int = absi(sample_frame - requested_frame)
	# DEC-U-AAF-TRIGGERS §7 F3: mirror the donor call site as LOGGED INTENT only.
	# "0,0" is the donor-proven early-out bypass; "6,8" is the deferred switch.
	# No interpolation is performed; the engine operator stays [U]-B (R-B).
	var bypass: bool = requested_blend == DONOR_BLEND_NONE
	var bypass_violation: bool = bypass and sample_frame != requested_frame
	return {
		"frame_blend_min": DONOR_MIN_FRAME_BLEND,
		"frame_blend_max": DONOR_MAX_FRAME_BLEND,
		"frame_blend_delta": delta,
		"frame_blend_within_window": delta <= DONOR_MAX_FRAME_BLEND,
		"frame_blend_policy": FRAME_BLEND_STATUS,
		"requested_blend": requested_blend,
		"requested_blend_sites": DONOR_BLEND_SITES,
		"blend_bypass": bypass,
		"blend_bypass_violation": bypass_violation,
		"blend_bypass_sites": DONOR_BLEND_BYPASS_SITES,
		"fetch_policy": "nearest_single_no_blend [U]-B2",
		"fetch_window_sites": DONOR_BLEND_FETCH_SITES,
		"blend_args_status": DONOR_BLEND_ARGS_STATUS,
	}


# Transposed donor rotation matrix, flattened row-major, copied verbatim from
# bake_sprites.qmat (:118-129, row-vector convention verified bone by bone).
func _qmat(x: float, y: float, z: float, w: float) -> PackedFloat32Array:
	var m00 := 1.0 - 2.0 * (y * y + z * z)
	var m01 := 2.0 * (x * y - z * w)
	var m02 := 2.0 * (x * z + y * w)
	var m10 := 2.0 * (x * y + z * w)
	var m11 := 1.0 - 2.0 * (x * x + z * z)
	var m12 := 2.0 * (y * z - x * w)
	var m20 := 2.0 * (x * z - y * w)
	var m21 := 2.0 * (y * z + x * w)
	var m22 := 1.0 - 2.0 * (x * x + y * y)
	return PackedFloat32Array([m00, m10, m20, m01, m11, m21, m02, m12, m22])

# P10: byte-identical twin of _qmat's nine expressions and their flattening
# order ([m00,m10,m20,m01,m11,m21,m02,m12,m22]). dst is a PackedFloat32Array,
# so each assignment rounds to float32 exactly like _qmat()'s constructor;
# the flat buffer is reused per sid (one COW copy per sample, not B arrays).
func _qmat_into(dst: PackedFloat32Array, off: int, x: float, y: float, z: float, w: float) -> void:
	dst[off] = 1.0 - 2.0 * (y * y + z * z)
	dst[off + 1] = 2.0 * (x * y + z * w)
	dst[off + 2] = 2.0 * (x * z - y * w)
	dst[off + 3] = 2.0 * (x * y - z * w)
	dst[off + 4] = 1.0 - 2.0 * (x * x + z * z)
	dst[off + 5] = 2.0 * (y * z + x * w)
	dst[off + 6] = 2.0 * (x * z + y * w)
	dst[off + 7] = 2.0 * (y * z - x * w)
	dst[off + 8] = 1.0 - 2.0 * (x * x + y * y)


# Python round() is half-to-even for nonnegative frame indices.
func _py_round_i(x: float) -> int:
	var fl := floorf(x)
	var frac := x - fl
	if frac > 0.5:
		return int(fl) + 1
	if frac < 0.5:
		return int(fl)
	var f := int(fl)
	return f if f % 2 == 0 else f + 1


# Accept a Dictionary with a sid, an Object exposing a sid, or a sid String.
func _sid_of(e) -> String:
	if e is String:
		return e as String
	if e is Dictionary:
		return str((e as Dictionary).get("sid", ""))
	if e is Object:
		var v = (e as Object).get("sid")
		return str(v) if v != null else ""
	return ""


func _valid_skin(skin: Dictionary) -> bool:
	for key in ["k", "fps", "bones", "v", "verts", "w_bone", "w_val", "w_off", "anim"]:
		if not skin.has(key):
			last_error = "skin missing key: " + str(key)
			return false
	if int(skin["k"]) <= 0 or int(skin["bones"]) <= 0 or int(skin["v"]) <= 0:
		last_error = "skin has non-positive k/bones/v"
		return false
	# V7-78: a shipped subset skin stores only `frame_count` donor frames,
	# laid out as bones * frame_count * 7; a full parsed skin keeps bones*k*7.
	var nf: int = int(skin.get("frame_count", int(skin["k"])))
	if (skin["anim"] as PackedFloat32Array).size() != int(skin["bones"]) * nf * 7:
		last_error = "skin anim size != bones*frame_count*7"
		return false
	if (skin["verts"] as PackedVector3Array).size() != int(skin["v"]):
		last_error = "skin verts size != v"
		return false
	if (skin["w_off"] as PackedInt32Array).size() != int(skin["v"]) + 1:
		last_error = "skin w_off size != v+1"
		return false
	return true


# Convert a raw read_oss-shaped Dictionary (JSON-friendly nested Arrays) into
# the packed normal form. Strict: never fills missing data with invented values.
func _normalise_raw(raw: Dictionary) -> Dictionary:
	last_error = ""
	var vraw: Variant = raw.get("verts", null)
	var wraw: Variant = raw.get("weights", null)
	var araw: Variant = raw.get("anim", raw.get("animation", null))
	if not (vraw is Array) or not (wraw is Array) or not (araw is Array):
		last_error = "raw skin needs Array verts/weights/anim"
		return {}
	var verts := PackedVector3Array()
	var w_bone := PackedInt32Array()
	var w_val := PackedFloat32Array()
	var w_off := PackedInt32Array()
	w_off.resize((vraw as Array).size() + 1)
	for i in range((vraw as Array).size()):
		var vv: Variant = (vraw as Array)[i]
		if vv is Vector3:
			verts.append(vv)
		elif vv is Array and (vv as Array).size() >= 3:
			verts.append(Vector3(float((vv as Array)[0]), float((vv as Array)[1]), float((vv as Array)[2])))
		else:
			last_error = "raw vert %d is not Vector3/3-array" % i
			return {}
		w_off[i] = w_bone.size()
		if i >= (wraw as Array).size():
			last_error = "raw weights shorter than verts"
			return {}
		var pairs: Variant = (wraw as Array)[i]
		if not (pairs is Array):
			last_error = "raw weights[%d] not Array" % i
			return {}
		for p in (pairs as Array):
			var pair: Variant = p
			if not (pair is Array) or (pair as Array).size() < 2:
				last_error = "raw weight pair malformed at vertex %d" % i
				return {}
			w_bone.append(int((pair as Array)[0]))
			w_val.append(float((pair as Array)[1]))
	w_off[(vraw as Array).size()] = w_bone.size()
	var k: int = int(raw.get("k", raw.get("frames", 0)))
	var bones: int = int(raw.get("bones", raw.get("b", 0)))
	if k <= 0 or bones <= 0:
		last_error = "raw skin needs k/frames and bones/b"
		return {}
	var anim := PackedFloat32Array()
	anim.resize(k * bones * 7)
	var ai := 0
	for bi in range(bones):
		if bi >= (araw as Array).size():
			last_error = "raw anim has fewer bones than declared"
			return {}
		var rows: Variant = (araw as Array)[bi]
		if not (rows is Array) or (rows as Array).size() < k:
			last_error = "raw anim bone %d has fewer than k frames" % bi
			return {}
		for fr in range(k):
			var row: Variant = (rows as Array)[fr]
			if not (row is Array) or (row as Array).size() < 7:
				last_error = "raw anim row malformed bone %d frame %d" % [bi, fr]
				return {}
			for q in range(7):
				anim[ai] = float((row as Array)[q])
				ai += 1
	return {
		"ok": true,
		"source": str(raw.get("source", "registered_raw")),
		"path": str(raw.get("path", "")),
		"k": k,
		"fps": int(raw.get("fps", DONOR_FPS)),
		"bones": bones,
		"v": verts.size(),
		"verts": verts,
		"w_bone": w_bone,
		"w_val": w_val,
		"w_off": w_off,
		"anim": anim,
		"cite": str(raw.get("cite", OSS_CITE)),
		"skin_math": str(raw.get("skin_math", SKIN_CITE)),
	}


# ---------------------------------------------------------------------------
# V7-78: automatic shipped-skin assets (offline converter output only)
# ---------------------------------------------------------------------------

# Lazy, once. Safe to call from bind()/has_skin()/pose_for()/play(); the guard
# makes the per-unit sync path free after the first call. No donor path is read
# here: only the offline-converted index + JSON assets under res://.
func _ensure_shipped_skins() -> void:
	if _shipped_loaded:
		return
	_shipped_loaded = true
	_shipped_error = ""
	if not FileAccess.file_exists(SKIN_INDEX_PATH):
		_shipped_error = "no shipped skin index: " + SKIN_INDEX_PATH
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SKIN_INDEX_PATH))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("entries"):
		_shipped_error = "invalid shipped skin index: " + SKIN_INDEX_PATH
		return
	# DEC-U-TOOL-ATTACH: keep the parsed index for the additive attach lookup.
	_shipped_index = parsed as Dictionary
	var entries: Array = (parsed as Dictionary)["entries"]
	for item in entries:
		if not (item is Dictionary):
			continue
		var file_name := str((item as Dictionary).get("file", ""))
		if file_name == "":
			continue
		if _load_shipped_skin(SKIN_ASSET_DIR + file_name):
			_shipped_count += 1
			_shipped_bytes += int((item as Dictionary).get("bytes", 0))
		else:
			_shipped_error = "last failure " + file_name + ": " + last_error
	# P10 (defensive, P03 §4-A): the shipped-skin loop replaced/extended the
	# skin set on this first load. _load_shipped_skin() already clears per skin;
	# clear once more here so no cache entry can outlive the load.
	_clear_frame_caches()


# Load one c3_skin_v1 asset and register it under its real roster sid. Uses the
# SAME packed representation and skinner as parse_donor_oss(); only the anim
# block is frame-subsetted. Strict rejection: no fill values, no guesswork.
# DEC-U-TOOL-ATTACH: `reg_key` is OPTIONAL and defaults to the roster sid, so all
# existing callers are byte-unchanged. Tool skins pass TOOL|<sid>|<tool> and can
# never clobber the roster skin at _skins[sid].
func _load_shipped_skin(path: String, reg_key: String = "") -> bool:
	last_error = ""
	if not FileAccess.file_exists(path):
		last_error = "shipped skin missing: " + path
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		last_error = "shipped skin is not a JSON object: " + path
		return false
	var d := parsed as Dictionary
	if str(d.get("schema", "")) != "c3_skin_v1":
		last_error = "shipped skin schema mismatch: " + path
		return false
	var sid := str(d.get("sid", ""))
	if sid == "":
		last_error = "shipped skin has empty sid: " + path
		return false
	var frames: Array = d.get("frames", [])
	var nf: int = frames.size()
	var bones: int = int(d.get("bones", 0))
	var vraw: Array = d.get("verts", [])
	var wraw: Array = d.get("weights", [])
	var araw: Array = d.get("anim", [])
	if nf <= 0 or bones <= 0 or vraw.is_empty() or wraw.size() != vraw.size() or araw.size() != bones:
		last_error = "shipped skin structural mismatch: " + path
		return false
	var verts := PackedVector3Array()
	verts.resize(vraw.size())
	for i in range(vraw.size()):
		var vv: Variant = vraw[i]
		if not (vv is Array) or (vv as Array).size() < 3:
			last_error = "shipped vert %d malformed: %s" % [i, path]
			return false
		var a3: Array = vv as Array
		verts[i] = Vector3(float(a3[0]), float(a3[1]), float(a3[2]))
	var w_bone := PackedInt32Array()
	var w_val := PackedFloat32Array()
	var w_off := PackedInt32Array()
	w_off.resize(vraw.size() + 1)
	for i in range(vraw.size()):
		w_off[i] = w_bone.size()
		var pairs: Variant = wraw[i]
		if not (pairs is Array):
			last_error = "shipped weights[%d] malformed: %s" % [i, path]
			return false
		for p in (pairs as Array):
			if not (p is Array) or (p as Array).size() < 2:
				last_error = "shipped weight pair malformed at %d: %s" % [i, path]
				return false
			var pair: Array = p as Array
			w_bone.append(int(pair[0]))
			w_val.append(float(pair[1]))
	w_off[vraw.size()] = w_bone.size()
	var anim := PackedFloat32Array()
	anim.resize(bones * nf * 7)
	var ai := 0
	for bi in range(bones):
		var rows: Variant = araw[bi]
		if not (rows is Array) or (rows as Array).size() != nf:
			last_error = "shipped anim bone %d frame count mismatch: %s" % [bi, path]
			return false
		for fi in range(nf):
			var row: Variant = (rows as Array)[fi]
			if not (row is Array) or (row as Array).size() < 7:
				last_error = "shipped anim row malformed bone %d frame %d: %s" % [bi, fi, path]
				return false
			for q in range(7):
				anim[ai] = float((row as Array)[q])
				ai += 1
	var frame_index := {}
	for i in range(nf):
		frame_index[int(frames[i])] = i
	var actions := {}
	var raw_actions: Variant = d.get("actions", {})
	if raw_actions is Dictionary:
		for name in (raw_actions as Dictionary).keys():
			var av: Variant = (raw_actions as Dictionary)[name]
			if not (av is Dictionary):
				continue
			var ad := av as Dictionary
			actions[str(name)] = {
				"first": int(ad.get("first", -1)),
				"last": int(ad.get("last", -1)),
				"kind": str(ad.get("kind", "morph")),
				"donor": str(ad.get("donor", "")),
				"frames": (ad.get("frames", []) as Array).duplicate(),
			}
	var skin := {
		"ok": true,
		"compact": true,
		"source": SHIPPED_SKIN_SOURCE,
		"path": str(d.get("path", "")),
		"asset": path,
		"aaf_path": str(d.get("aaf_path", "")),
		"k": int(d.get("k", 0)),
		"fps": int(d.get("fps", DONOR_FPS)),
		"bones": bones,
		"v": verts.size(),
		"verts": verts,
		"w_bone": w_bone,
		"w_val": w_val,
		"w_off": w_off,
		"anim": anim,
		"frame_count": nf,
		"frames": frames,
		"frame_index": frame_index,
		"actions": actions,
		"cite": str(d.get("cite", OSS_CITE)),
		"skin_math": str(d.get("skin_math", SKIN_CITE)),
		"label": str(d.get("label", PORT_LABEL)),
		"rig": str(d.get("rig", BLOCKED_RIG)),
		"visual": "UNVERIFIED",
		"coord": str(d.get("coord", MORPH_COORD)),
	}
	if not _valid_skin(skin):
		return false
	# Tool skins register under TOOL|<sid>|<tool>; the roster skin stays intact.
	var key := reg_key if reg_key != "" else sid
	_skins[key] = skin
	_clear_frame_caches()
	return true


# DEC-U-TOOL-ATTACH §2.1 / §5 C3 — donor-faithful tool lookup for one action.
# `body_frame` is the BODY's CURRENT donor frame index (pose["frame"] in
# world3d_entities.gd). The tool .oss shares the body's AAF timeline and the
# same exported frames, so this is the ONLY frame index used to sample anim[0].
# No new window, no blend fetch, no nearest-frame substitute, no fallback skin
# and no cross-sid range. visible=false means: hide the tool child — never a
# body mesh, never another nation's tool.
func attach_for(sid, action, body_frame: int = -1) -> Dictionary:
	_ensure_shipped_skins()
	var s := str(sid)
	var donor_action := str(ACTION_ALIAS.get(str(action), str(action)))
	var out: Dictionary = {
		"ok": false, "visible": false, "sid": s, "action": donor_action,
		"tool": "", "actor_ind": -1, "asset": "", "donor_frame": body_frame,
		"local_frame": -1, "anim": [], "verts": PackedVector3Array(),
		"status": "hidden", "reason": "", "cite": TOOL_ATTACH_CITE,
		"label": TOOL_HIDDEN_STATUS,
	}
	# 1. Per-sid index attach block (IMPL-TOOL-BAKER C2), never the roster skin.
	var entry: Dictionary = {}
	for item in _shipped_index.get("entries", []):
		if item is Dictionary and str((item as Dictionary).get("sid", "")) == s:
			entry = item as Dictionary
			break
	if entry.is_empty():
		out["status"] = "DATA_GAP"
		out["reason"] = "no shipped skin index entry for sid '" + s + "'"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var blk_v: Variant = entry.get("attach", null)
	if not (blk_v is Dictionary):
		out["status"] = "DATA_GAP"
		out["reason"] = "index entry has no attach block (sid '" + s + "')"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var blk := blk_v as Dictionary
	var map_v: Variant = blk.get("action_tool_map", null)
	if not (map_v is Dictionary):
		out["status"] = "DATA_GAP"
		out["reason"] = "attach block has no action_tool_map (sid '" + s + "')"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	# 2. ACTION_ALIAS runs FIRST: port "attack" -> donor "attack0" -> axe.
	var tool := str((map_v as Dictionary).get(donor_action, ""))
	if tool == "":
		# '', walk, idle, death, reaction, attack1/2 and every else stay hidden.
		out["reason"] = "unmapped action '" + donor_action + "' (hidden: §2.1)"
		return out
	# 3. Gate on the derived tool slot status; no silent substitute.
	var tools_v: Variant = blk.get("tools", null)
	if not (tools_v is Dictionary) or not (tools_v as Dictionary).has(tool):
		out["status"] = "DATA_GAP"
		out["reason"] = "attach.tools has no '" + tool + "' slot for sid '" + s + "'"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var rec_v: Variant = (tools_v as Dictionary)[tool]
	if not (rec_v is Dictionary):
		out["status"] = "DATA_GAP"
		out["reason"] = "attach.tools['" + tool + "'] malformed"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var rec := rec_v as Dictionary
	if str(rec.get("status", "")) != "exported":
		out["status"] = "DATA_GAP"
		out["reason"] = "tool '" + tool + "' status=" + str(rec.get("status", "missing")) \
			+ ": " + str(rec.get("error", "no detail"))
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	# 4. Load via the EXISTING shipped-skin loader under a TOOL key. The asset
	#    path is the baker's own value, never built from a foreign nation stem.
	var asset_rel := str(rec.get("asset", TOOL_SKIN_SUBDIR + s + "_" + tool + ".json"))
	if not asset_rel.begins_with(TOOL_SKIN_SUBDIR) \
			or not asset_rel.ends_with(s + "_" + tool + ".json"):
		out["status"] = "DATA_GAP"
		out["reason"] = "attach asset path is not this sid's own tool: " + asset_rel
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var key := TOOL_SKIN_KEY_PREFIX + s + "|" + tool
	if not _skins.has(key) and not _load_shipped_skin(SKIN_ASSET_DIR + asset_rel, key):
		out["status"] = "DATA_GAP"
		out["reason"] = "tool skin load failed: " + asset_rel + ": " + last_error
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var tskin: Dictionary = _skins[key] as Dictionary
	# 5. Sample at the BODY's donor frame only: exact exported-frame lookup,
	#    no nearest snap, no new window, no invented frame, no fallback.
	if body_frame < 0:
		out["status"] = "DATA_GAP"
		out["reason"] = "no body donor frame (body pose not sampled)"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var fi_v: Variant = tskin.get("frame_index", null)
	if not (fi_v is Dictionary) or not (fi_v as Dictionary).has(body_frame):
		out["status"] = "DATA_GAP"
		out["reason"] = "tool '" + tool + "' has no exported frame at donor frame " \
			+ str(body_frame) + " (no nearest/fallback)"
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var li: int = int((fi_v as Dictionary)[body_frame])
	var nf: int = int(tskin.get("frame_count", 0))
	var anim_arr: PackedFloat32Array = tskin.get("anim", PackedFloat32Array())
	var off: int = li * 7   # b==1 single-bone rigid track: bone 0 only
	if li < 0 or li >= nf or off + 7 > anim_arr.size():
		out["status"] = "DATA_GAP"
		out["reason"] = "tool anim[0] frame out of range at donor frame " + str(body_frame)
		out["label"] = TOOL_DATA_GAP_STATUS
		return out
	var row: Array = []
	for q in range(7):
		row.append(float(anim_arr[off + q]))
	# Same single-bone skinner as the body; ref_frame=-1 keeps the donor bone-0
	# placement, so NO root-relative offset/rotation/scale is invented.
	out["ok"] = true
	out["visible"] = true
	out["tool"] = tool
	out["actor_ind"] = int(ATTACH_ACTOR_INDEX.get(tool, -1))
	out["asset"] = asset_rel
	out["status"] = "exported"
	out["label"] = TOOL_ATTACH_STATUS
	out["local_frame"] = li
	out["anim"] = row   # anim[0] position+quaternion at the BODY's donor frame
	out["verts"] = skin_vertices(tskin, body_frame)
	return out


# Deterministic nearest exported donor frame. `frames` is ascending, so a tie
# keeps the lower frame. No interpolation and no invented frame index.
func _nearest_local(skin: Dictionary, donor_frame: int) -> int:
	var frames: Array = skin.get("frames", [])
	if frames.is_empty():
		return 0
	var best := 0
	var best_dist: int = absi(int(frames[0]) - donor_frame)
	for i in range(1, frames.size()):
		var dist: int = absi(int(frames[i]) - donor_frame)
		if dist < best_dist:
			best_dist = dist
			best = i
	return best


# DEC-U-BLEND-OP §7 F2 LABEL ONLY — single nearest exported donor frame. `frames`
# is ascending, so a tie KEEPS THE LOWER frame; the ascending scan and the
# 6-frame shipped subset are PORT (converter) choices with ZERO donor counterpart.
# No readable donor text names a two-frame fetch or a snap-vs-interpolate rule
# ([U]-B2 / R-B2). The donor (6,8) window sites (unit.script:10846-10847,
# :10970,11016,11055,11100; ontagstates.inc:474,513,596; THIRD literal site
# progress.inc/nothing.inc:8-9,61 with 4-level walk cascade walk2->walk1->walk0->
# walk at :27-31) and the movie 0..5 window (movie.script:644-646, [U]-B4) are
# donor DATA carried in DONOR_BLEND_FETCH_SITES / DONOR_BLEND_SITES — NOT
# reproduced by this fetch. NO second frame is fetched; no interpolation.
func _nearest_exported_frame(skin: Dictionary, donor_frame: int) -> int:
	var frames: Array = skin.get("frames", [])
	var local := _nearest_local(skin, donor_frame)
	if local >= frames.size():
		return donor_frame
	return int(frames[local])


# [first, last, line, kind, donor_cite]. A shipped skin carries its unit's OWN
# donor AAF ranges (converter read them from data/animations/aaf/<base>.aaf);
# unregistered/legacy skins keep the V7-18 peaukr table unchanged.
func _action_range_for(sid: String, action: String) -> Array:
	var ck := sid + "|" + action
	if _range_cache.has(ck):
		return _range_cache[ck] as Array
	var out: Array = []
	if _skins.has(sid):
		var skin: Dictionary = _skins[sid] as Dictionary
		if bool(skin.get("compact", false)):
			var actions: Dictionary = skin.get("actions", {})
			if actions.has(action):
				var a: Dictionary = actions[action] as Dictionary
				var donor_path := str(a.get("donor", ""))
				var line := 0
				var colon: int = donor_path.rfind(":")
				if colon >= 0:
					line = int(donor_path.substr(colon + 1))
				out = [int(a["first"]), int(a["last"]), line,
					str(a.get("kind", "morph")), donor_path]
	if out.is_empty() and AAF_ACTIONS.has(action) and not _skins.has(sid):
		# PORT1TO1-ENT1TO1 / D1: the peaukr table is ONLY for an unregistered
		# sid (no per-sid donor AAF evidence in this runtime). row[5] tags the
		# substitution so it can never be mistaken for the sid's own AAF.
		# P10: duplicate ONCE per (sid, action), not once per frame.
		var fallback: Array = (AAF_ACTIONS[action] as Array).duplicate()
		fallback.append("sid_unknown_peaukr_fallback")
		out = fallback
	_range_cache[ck] = out
	return out


func _unknown(requested: String, aliased: bool, sid: String = "") -> Dictionary:
	var reason := "action not present in data/animations/aaf/peaukr.aaf:3-20 (sid unknown fallback table)"
	if sid != "" and _skins.has(sid):
		reason = "per-sid donor AAF for '%s' has no '%s' action; DEC-U-AAF-ART C2: no peaukr range and no silent idle/walk substitution (PORT1TO1-ENT1TO1 D1)" % [sid, requested]
	return {
		"ok": false,
		"action": "",
		"requested": requested,
		"aliased": aliased,
		"frame": -1,
		"fps": DONOR_FPS,
		"range": [],
		"donor": "UNVERIFIED — no readable AAF entry for '%s'" % requested,
		"kind": "UNVERIFIED",
		"label": PORT_LABEL,
		"rig": BLOCKED_RIG,
		"visual": "UNVERIFIED",
		"verified": false,
		"reason": reason,
		"cycle": "none_no_donor_action",
		"aaf_loop_status": AAF_LOOP_STATUS,
		"frame_blend_status": FRAME_BLEND_STATUS,
		"frame_blend_min": DONOR_MIN_FRAME_BLEND,
		"frame_blend_max": DONOR_MAX_FRAME_BLEND,
		"frame_blend_delta": -1,
		"frame_blend_within_window": false,
	}


# Entities in this sim are Dictionaries (game.gd:82); accept Object metadata too
# so a Node3D-based entity can read the same pose request without a type error.
func _publish(e, pose: Dictionary) -> void:
	if e is Dictionary:
		(e as Dictionary)[POSE_KEY] = pose
	elif e is Object:
		(e as Object).set_meta(POSE_KEY, pose)


# ══ DEC-U-AAF-TRIGGERS — donor trigger resolver (read-only facts) ═══════════════
# Everything below is additive. play()/pose_for()/action_info() and every
# pre-existing helper are unchanged; no existing caller is redirected. The
# entity-state→fields decode and the call into these functions belong to
# world3d_entities.gd (exact patch recommendation in IMPL_U_aaf_triggers.md).

# Row accessor. Returns {} for an unknown id; never fabricates a row.
func donor_trigger_row(id: String) -> Dictionary:
	var v: Variant = DONOR_TRIGGER_TOKENS.get(id, null)
	if v is Dictionary:
		return v as Dictionary
	return {}


# Concrete token for a row. A Dictionary token is keyed by resource/weapon/move;
# a String token is returned directly; an Array (T22 child swap) is NOT a single
# AAF token and returns "". No fallback token is ever chosen here.
func donor_row_token(row: Dictionary, key: String = "") -> String:
	var tok: Variant = row.get("token", "")
	if tok is Dictionary:
		var d: Dictionary = tok as Dictionary
		return str(d.get(key, d.get("idle", d.get("none", ""))))
	if tok is Array:
		return ""
	return str(tok)


# T18–T20 readback sets (DEC-U §1.2). READBACK-ONLY: this classifies a CURRENT
# anim name for the donor's turn/idle re-entry; it is NOT a selector. Dormant
# until capture R-S proves dwell; no pose or state is invented.
func _donor_sticky_idle(current: String) -> String:
	if current == "":
		return ""
	for t in ["trans10", "trans20", "walk0", "prepare0", "attack0", "idle0"]:
		if current == t:
			return "T18"
	for t in ["trans01", "trans21", "walk1", "prepare1", "attack1", "idle1"]:
		if current == t:
			return "T19"
	for t in ["trans02", "trans12", "walk2", "prepare2", "attack2", "idle2"]:
		if current == t:
			return "T20"
	return ""


# Pure donor-fact resolver: decoded tag fields (DEC-U §1.2; unit.script:10837-
# 10843) -> donor-faithful token, per-site blend and existence-gate citation.
# Branch order is the donor's own, by cited line number: extract/build/attack
# :10865-10882, carry :10901-10919, weapon-state :10928-10954, sticky
# :10977-11029, hide :11076-11080, death :11086-11103. It never reads entity
# state, never substitutes a token for an orphan row, and never performs a
# fallback. The caller gates with has_action(sid, token) — see
# resolve_donor_action() below.
func resolve_donor_trigger(fields: Dictionary) -> Dictionary:
	var action := str(fields.get("iAction", ""))
	var essential := str(fields.get("iEssential", ""))
	var visual := str(fields.get("iVisual", ""))
	var weapon := str(fields.get("iWeapon", "none"))
	var resource := str(fields.get("iResource", ""))
	var move := str(fields.get("iMove", ""))
	var tid := ""
	var token := ""
	if visual == "hide":
		tid = "T26"
		token = ""
	elif essential == "death":
		tid = "T21"
		token = donor_row_token(donor_trigger_row(tid), weapon)
	elif action == "extract":
		tid = "T2" if resource == "wood" else ("T3" if resource == "stone" else "T1")
		token = donor_row_token(donor_trigger_row(tid))
	elif action == "build":
		tid = "T4"
		token = donor_row_token(donor_trigger_row(tid))
	elif action == "attack":
		tid = "T6" if weapon == "1" else ("T7" if weapon == "2" else "T5")
		token = donor_row_token(donor_trigger_row(tid))
	elif resource != "":
		# Carry rows T8–T13; deferred blend split on idle/turn vs walk.
		var carry_walk: bool = move == "walk"
		if resource == "wood":
			tid = "T11" if carry_walk else "T10"
		elif resource == "stone":
			tid = "T13" if carry_walk else "T12"
		else:
			tid = "T9" if carry_walk else "T8"
		token = donor_row_token(donor_trigger_row(tid))
	else:
		# Weapon-state idle/turn/walk T14–T17. Sticky readback T18–T20 is
		# honoured ONLY if the caller supplies current_anim; off by default.
		var current := str(fields.get("current_anim", ""))
		var sticky := _donor_sticky_idle(current)
		if sticky != "":
			tid = sticky
			token = donor_row_token(donor_trigger_row(tid))
		else:
			tid = "T15" if weapon == "0" else ("T16" if weapon == "1" else ("T17" if weapon == "2" else "T14"))
			token = donor_row_token(donor_trigger_row(tid), move)
	var row := donor_trigger_row(tid)
	var blend = row.get("blend", DONOR_BLEND_MINMAX)
	var chosen_blend: String = ""
	if blend is Dictionary:
		var bd: Dictionary = blend as Dictionary
		chosen_blend = str(bd.get(move, bd.get("idle", "")))
	else:
		chosen_blend = str(blend)
	var once: bool = token != "" and _is_once_action(token)
	return {
		"ok": true,
		"trigger_id": tid,
		"token": token,
		"blend": chosen_blend,
		"gate": str(row.get("gate", "")),
		"cite": str(row.get("cite", "")),
		"orphan": bool(row.get("orphan", false)),
		"port": str(row.get("port", "")),
		"note": str(row.get("note", "")),
		"completion": AAF_COMPLETION_STATUS if once else "n/a",
		"cycle_sites": DONOR_CYCLE_SITES,
		"blend_sites": DONOR_BLEND_SITES,
		"visual_hide": tid == "T26",
	}


# Resolver + existence gate. Gates the donor token with the sid's OWN shipped
# AAF export (has_action, anim3d.gd:398-407) — the runtime mirror of
# _unit_IsAnimationExists (unit.script:369-373, '' -> true). No silent fallback:
# an absent token reports available=false and the caller follows its own
# labelled chain, never an invented substitute.
func resolve_donor_action(sid, fields: Dictionary) -> Dictionary:
	var r := resolve_donor_trigger(fields)
	var key := _sid_of(sid)
	var token := str(r["token"])
	r["sid"] = key
	r["available"] = token != "" and has_action(key, token)
	if not bool(r["available"]) and token != "":
		r["gate"] = str(r["gate"]) + "; HAS_ACTION_MISS for sid " + key
	return r


# Loop vs clamp-once with the exact donor sources (DEC-U §2). bPlayOnce=False
# (loop) vs True (once) from showdebuganimations.inc:45-66,113-156; mode mapping
# acmLoop/acmPlayOnce/acmNone from movie.script:648-656; DoDeath
# acmPlayOnce/aamPlayOnce from unit.script:10808-10809,10852; hidden acmNone
# from :11076-11080; NumberCycle=1 from cannon.acl:33-45. The completion hook
# is EMPTY until R-C1/R-C2 land; clamp-at-last stays the labelled stand-in.
func donor_cycle_policy(action: String) -> Dictionary:
	if _is_once_action(action):
		return {
			"donor_mode": "acmPlayOnce",
			"port_cycle": "once_clamp",
			"completion": AAF_COMPLETION_STATUS,
			"cite": DONOR_CYCLE_SITES,
		}
	return {
		"donor_mode": "acmLoop",
		"port_cycle": "loop",
		"completion": "n/a (loop has no end-of-cycles completion)",
		"cite": DONOR_CYCLE_SITES,
	}


# Per-call blend-parameter passthrough (DEC-U §7 F3). Mirrors the donor call
# sites as LOGGED INTENT only: "0,0" early-out rows vs "6,8" deferred rows.
# No interpolation; the engine operator stays [U]-B with capture R-B.
func frame_blend_for_trigger(trigger_id: String, requested_frame: int, sample_frame: int) -> Dictionary:
	var row := donor_trigger_row(trigger_id)
	var blend: Variant = row.get("blend", DONOR_BLEND_MINMAX)
	# An idle/turn/walk split cannot be reduced to one number without a move
	# tag; the caller resolves that via resolve_donor_trigger()["blend"]. Here
	# a split falls back to the documented deferred default "6,8" — a cited
	# donor value, never an invented one.
	if blend is Dictionary:
		blend = DONOR_BLEND_MINMAX
	return _frame_blend_fields(requested_frame, sample_frame, str(blend))


# Empty completion callback registry (DEC-U §7 F2). Wired ONLY when R-C1/R-C2
# land; until then nothing invokes it and clamp-at-last is the only behaviour.
func set_aaf_completion_hook(cb: Callable) -> void:
	_aaf_completion_hook = cb


func has_aaf_completion_hook() -> bool:
	return _aaf_completion_hook.is_valid()


# Diagnostic probe: reports the unresolved completion WITHOUT firing a
# fabricated event. Never called from play()/pose_for()/_frame_at() while
# [U]-C1/C2 are open. DEC-U-BLEND-OP §7 F4: the clamp stays; `completion` records
# "clamp-at-last [U]-C1, no EndCyclesReached handler armed" and `frame_law_status`
# records the inclusive sim vs exclusive movie laws (DONOR_FRAME_LAW_STATUS).
# NOTHING is wired to the empty hook (_aaf_completion_hook) until R-C1 lands.
func aaf_completion_probe(action: String, frame: int, last: int) -> Dictionary:
	return {
		"action": action,
		"frame": frame,
		"last": last,
		"at_last_frame": frame >= last,
		"hook_registered": _aaf_completion_hook.is_valid(),
		"status": AAF_COMPLETION_STATUS,
		"completion": "clamp-at-last [U]-C1, no EndCyclesReached handler armed (unit.script:10811-10815)",
		"frame_law_status": DONOR_FRAME_LAW_STATUS,
	}


# Orphan classification — LABEL ONLY. No selector, no fallback, no auto-trigger.
func is_donor_orphan_token(token: String) -> bool:
	if DONOR_ORPHAN_TOKENS.has(token):
		return true
	for prefix in DONOR_ORPHAN_PREFIXES:
		if token.begins_with(str(prefix)):
			return true
	return false


func donor_orphan_note(token: String) -> String:
	if DONOR_ORPHAN_TOKENS.has(token):
		return str(DONOR_ORPHAN_TOKENS[token])
	if is_donor_orphan_token(token):
		return "prefix family " + token + ": readback-only or vocabulary-only per DEC-U §1.1/T25; no anim := set-site; " + AAF_ORPHAN_STATUS
	return ""
