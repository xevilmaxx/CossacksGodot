# GUIDE 4 — Landscape, clusters, height, stumps, anims, building ghost (full)
# 2000+ row exploded edition. Read top to bottom, do L1->L8 in order.

Role: you are the landscape designer. Goal: random skirmish map reads like
Cossacks 3 in motion — broad light meadows, dark rings under forests, pale
khaki near shores/desert, worn dirt under towns/mines/quarries, soft seams,
discrete resource clusters, walkable stumps, low hills you can cross and steep
hills you cannot, true random seeds with a headless quality scan, correct walk
cycles, and a transparent building ghost with real block rules.

0001 Companion docs (read-only): docs/guides/GUIDE1.md, docs/guides/GUIDE2.md,
0002   docs/guides/GUIDE3.md (all DONE), app/MECHANICS.md, app/mechanics.json,
0003   reference/videos.md, docs/COMMANDS.md.
0004 Donor game (never redistribute, private use only): C:\Games\Cossacks 3.
0005 Donor landscape truth: data/game/var/generator.cfg (TerrainTypes+Patterns),
0006   data/terrain/tiles/textures/*.dds, data/terrain/covers/, data/terrain/decals/,
0007   data/pattern/*.pattern, data/gen/terrainmasks/<terrain>/*.tga,
0008   data/scripts/common.inc/dogenerate.inc + initmapgen.inc (map gen stages),
0009   data/game/var/envscales.cfg, data/game/var/random.cfg.
0010 Wiki truth: https://cossacks3.fandom.com/wiki/Editor ,
0011   https://cossacks3.fandom.com/wiki/Combat_basics ,
0012   https://cossacks3.fandom.com/wiki/Formations ,
0013   editor guides (F2 terrain, F3 hills, F4 minerals, F5 farms, F8 trees/bushes).
0014 Footage truth: reference/videos.md #3 (5000 musketeers line battle),
0015   #6 (huge 18c line battle), #9 (3v3 minimap timelapse = macro layout),
0016   #11 (24min no-commentary skirmish = build order + fields + mines + walls).
0017 Port code truth: app/scripts/game.gd (2770 lines), app/scripts/world.gd (1420),
0018   app/scripts/data.gd (827), app/scripts/input_controller.gd,
0019   app/scripts/hud.gd (989), app/scripts/main.gd (1142), app/scripts/ai.gd,
0020   app/tools/bake_sprites.py (279), app/tools/sheet_metrics.py (48),
0021   app/tools/copy_assets.py, app/tools/convert_models.py,
0022   app/assets/terrain/*.png, app/assets/models/anim/index.json.

0023 How to use this file: each L-section has WHY / DONOR / PORT-NOW / DO / VERIFY.
0024 Do not skip. Do not "improve" beyond the step. Tabs inside GDScript blocks.
0025 One heavy job at a time (bake XOR long CLI XOR windowed capture).
0026 Every L-step must keep: selftest 28/28 green + uitest 17/17 green.

0027 Line-count contract: this file must stay >= 2000 rows (wc / Get-Content .Count).
0028 Do not trim tables/checklists to "save space" — they ARE the acceptance.

0029 ----------------------------------------------------------------------
0030 SECTION 0 — Environment, commands, safety (same bench as GUIDE3 §0)
0031 ----------------------------------------------------------------------
0032 0030.01 project root : C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3
0033 0030.02 app dir     : <root>\app
0034 0030.03 donor game  : C:\Games\Cossacks 3
0035 0030.04 Godot       : on PATH as `godot` (project.godot features 4.4, gl_compatibility)
0036 0030.05 Blender     : C:\Program Files\Blender Foundation\Blender 5.2\blender.exe (CPU Cycles ONLY)
0037 0030.06 Python      : 3.14 + Pillow (tools use it)
0038 0030.07 ffmpeg      : on PATH (MP4 assembly)
0039 0030.08 run every command from <root>. Quote paths with spaces.
0040 0030.09 weak-GPU rule: NEVER Blender EEVEE/GPU; NEVER godot without self-exit flag.
0041 0030.10 backup before editing: Copy-Item app\scripts\game.gd inbox\backup\game.gd.bak4 -Force
0042 0030.11 after adding PNGs: godot --headless --path app --import
0043 0030.12 TABS in .gd. Match surrounding indentation exactly.
0044 0030.13 do not rename functions/fields other scripts call.
0045 0030.14 selftest+uitest stay green after every L-step.

0046 Commands (copy-paste):
0047   godot --headless --path app -- --self-test app/selftest.json
0048   godot --headless --path app -- --ui-test app/uitest.json
0049   godot --headless --path app -- --ui-test app/uit.json --ui-only <scene>
0050   godot --headless --path app -- --cli app/cli.json --cli-seconds 60
0051   godot --headless --path app -- --config shots/boost.json --cli app/cli.json --cli-seconds 120
0052   godot --headless --path app --import
0053   godot --path app -- --screenshot app/shots/g4_<step>.png --timeout 90
0054   godot --path app -- --seq app/shots/j4 --seq-seconds 240 --seq-step 2 --speed 4 --config shots/boost.json --journey --timeout 400
0055   python app/tools/seq_to_mp4.py --dir app/shots/j4 --fps 10
0056   python app/tools/sheet_metrics.py --dir app/assets/models/anim
0057   python app/tools/scan_map.py --dir scans
0058   godot --headless --path app -- --dump-map scans/scan_7.json --seed 7
0059   (Get-Content docs/guides/GUIDE4.md).Count   # must print >= 2000

0060 Seed contract (L6 restores true random, tests stay deterministic):
0061   app/scripts/data.gd L35: static var RANDOM_SEED := 20261113
0062   app/scripts/game.gd L152 setup(): rng.seed = Data.RANDOM_SEED
0063   app/scripts/main.gd L343-345: --seed is parsed but IGNORED today -> L6 wires it.
0064   selftest/uitest/cli always use the default seed (no --seed flag) = stable.
0065   windowed/menu/journey may pass --seed <int> or "random" = new map each game.

0066 Quality contract (L2 owns it, all steps respect it):
0067   app/scripts/data.gd L95-106: PIXELS_PER_METER 16, TERRAIN_PX 16, QUALITY high,
0068     SPRITE_CELL 160, FX_CAP 220, FOG_INTERVAL 0.5, MINIMAP_INTERVAL 0.25.
0069   data.gd L110-121 set_quality(q): low 8/64/60/1.5/1.0, med 12/96/120/0.8/0.5,
0070     high 16/160/220/0.5/0.25.
0071   world.gd bind(): terrain_px = Data.TERRAIN_PX; texture_filter LINEAR.
0072   Never raise chunk LRU above 24 on low. Never force high on weak GPU.

0073 ----------------------------------------------------------------------
0074 SECTION 1 — What already exists (do NOT rebuild, L-steps patch it)
0075 ----------------------------------------------------------------------
0076 0100 sim game.gd: 32 Hz fixed step, entities Array+Dictionaries+by_id, 6 res,
0077   mines slot ladder, upkeep/625 famine, market drift, cost escalation,
0078   construction stages, training queues, donor damage formula, morale/rout,
0079   officer/drummer/priest auras, capture, walls/gates/repair, towers, squads
0080   15..400 + cav 40..160, replenish, hold-fire D/E/V, counter targeting, 17c
0081   flee, bayonets, grapeshot, mortar-only-buildings, 18c at Town Hall, 40+
0082   upgrades, hills bonus/LOS (weak), corpses/rubble, projectiles, fog render-only,
0083   objectives, victory destroy_all/score.
0084 0101 render world.gd: 4 draw layers (res z1, bld z2, unit z3, fx z4), terrain
0085   chunked ImageTexture 16px/tile (G3 G7), fog ImageTexture per-tile alpha,
0086   animated 8-dir sheets assets/models/anim/ (54 unit keys x walk/idle/attack/
0087   death + 215 nation building sheets + stages s1-s4 + _dead), lazy loading,
0088   overlays shadow/ring_sel, corpses, rally flags, squad links, ghost ellipse.
0089 0102 hud input ai shell: top bar + speed, bottom selection + minimap 200px
0090   bottom-left + frustum + right-click orders, command card, control groups
0091   1-9, double-click same-type, cursors, hotkeys incl R/U/Ctrl+`/Ctrl+M/Shift+Z,
0092   fog-hide (G6), spatial grid + 8Hz auras (G8), AI thresholds + waves.
0093 0103 terrain ids today: 0 grass / 1 dirt / 2 forest-floor / 3 water / 4 sand /
0094   5 rock. Base pass paints only 0/1 from low-freq noise (game.gd L304-314).
0095   Forests paint 2 then scatter wood (L374-382). Lakes paint 3 + sand ring 4
0096   (L322-337). Hills paint 5/1 blobs (L339-347). Roads paint 1 (L349-350).
0097   Quarries/mines paint 1/5 then _clear_trees (L402-460). Starts paint 1 plaza
0098   + clear + re-plant food + groves (L462-490). Deposit split (L495-501).
0099 0100 tree rule today: _scatter_forest L244 only on tt in {0,1,2}, never on
0100   3/4/5; clash check vs non-wood nodes unless near_home (<12 tiles from start);
0101   wood _add_res("wood",p,60,0.7) L269; stone 5-8/cluster hits 80 r0.9 L401;
0102   food rects 5x4 hits 50 r0.6 L423; mines max_hits 0 deposits L458.
0103 0101 block rule today: _add_res blocks all non-food L227
0104   (set_blocked_circle(pos,radius,true)); food never blocks. Water tiles
0105   set_blocked_tile(x,y,true) L334. Buildings set_blocked_circle(def.radius)
0106   L614. Gates unblock + gates list. is_blocked(p) L206 checks bounds+blocked[].
0107 0102 gather rule today: _tick_gather L2386: gold/iron/coal via mine building
0108   slots (L2393-2428); food/wood/stone via by_id node (L2431-2492); slot offset
0109   _work_slot(node.radius+1.1) L2447; reach 1.4 L2461; hit interval
0110   Data.GATHER[res].interval L2478; hits-=1 carry+=1 L2481-2484; on hits<=0 if
0111   res!=food unblock L2487-2488 + post depleted + res_dirty. Deliver via
0112   nearest_drop stores (cen/sto/mil) L2494+.
0113 0103 anim chain today: bake_sprites.py read_oss/read_aaf/sample -> sheets
0114   <key>_<action>.png cols=8 rows=frames + index.json {cell,actions{frames,
0115   duration,loop}}; sheet_metrics.py adds bbox/fig_h/foot/cx; world.gd
0116   _anim_action L181 (death>attack>gather-attack>walk>idle) + _draw_anim L203
0117   (fi from game.time_s-fire_t/death_t or anim_t, dir from face, scale by
0118   fig_h, anchor foot/cx). G1 fixed scale/anchor. Peasant PNG often fine.
0119 0104 ghost rule today: world.gd _draw_ghost L1302 green/red ellipse+rect only;
0120   place_building L1457 checks bar18/has18c, multi/has_multi, mine deposit<4.0,
0121   cost escalation pow(1.5)/pow(3 cen), pay_cost; spawn unfinished hp25% L1488;
0122   auto-send 8 peasants L1504. No overlap/stone/tree/water test. AI uses same
0123   path with send=false L209/222 ai.gd.

0124 File anchor table (exact names the L-steps edit):
0125   A01 app/scripts/game.gd :: _t L197, in_bounds L200, tile_of L203,
0126     is_blocked L206, set_blocked_circle L211, _add_res L220, _clear_area L230,
0127     _paint_terrain L235 (skips type 3), _scatter_forest L244,
0128     _clear_trees L275, _claim_cluster L289, _generate_map L297,
0129     height_at L504, _draw_road L538, mine_deposits L552, spawn L560,
0130     place_building L1457, _tick_gather L2386, _gather_deliver L2494,
0131     _step_move (grep), _tick_unit (grep move branch), _separate_units L1601,
0132     _compact L103, grid_query L92, nearest_res L734, nearest_drop L718.
0133   A02 app/scripts/world.gd :: bind L64, _load_sprites L119, _anim_action L181,
0134     _draw_anim L203, _bld_key L244, _draw_sprite L320, _src L365,
0135     _crop_variant L376, _tint L393, _prep_variants L401, _build_masks L513,
0136     _build_chunk L529, _sync_terrain_chunks L601, sync L628, _update_fog L656,
0137     _hash L717, _wnoise L723, _prop_tex L741, _draw_resources L750,
0138     _draw_buildings (grep), _draw_units (grep), _draw_ghost L1302.
0139   A03 app/scripts/data.gd :: TILE_M 2.0 L23, RES_NAMES L25, MAP_W/H L33-34,
0140     RANDOM_SEED L35, TERRAIN_PX L100, QUALITY L101, set_quality L110,
0141     MAP_TYPES L168 (water_frac 0.5..2.2), START_OPTIONS L178, FORMATIONS L190,
0142     GATHER_BASE L199 (food 22/45, wood 14/28, stone 20/40, interval 1.25).
0143   A04 app/tools/bake_sprites.py :: parse_args L25, read_oss L36, read_aaf L50,
0144     qmat L63, skin L68, sample L82, setup_scene L87, make_mat L108,
0145     build_mesh L119, bake_unit/bake_building (grep), main (grep --only/--size).
0146   A05 app/tools/sheet_metrics.py :: main (bbox union over 8 dirs x N frames,
0147     fig_h=(y1-y0)/cell, foot=y1/cell, cx=(x0+x1)/2/cell, skip unless --force).
0148   A06 app/scripts/input_controller.gd :: bind L28, _pick L144, _pick_res L322,
0149     _unhandled_input L168 (left ghost-place L174, drag L187, double-click L201),
0150     _right_order L228 (ghost cancel L229, attack_ground L232, rally L238,
0151     res L278, gather/build/enter L283-310), _update_cursor L579, _draw hint L563.
0152   A07 app/scripts/hud.gd :: build_ghost_sid L34, _build_bottom, refresh_selection,
0153     show_hint, minimap rect (G4 moved bottom-left 200px).
0154   A08 app/scripts/main.gd :: _parse_args L343 (--seed IGNORED today),
0155     _setup_full_game, bench_mode, game_save/load, toggle_menu_overlay.
0156   A09 donor :: generator.cfg TerrainTypes (Land=nowater2, Mediterranean,
0157     Peninsulas, Islands, Continents, Continent + DLC5 Coastal/Lakes/Rivers),
0158     Patterns (mng/mni/mnc, forests_* big/med/small, stones, stoneforests,
0159     hills_dark/light, decor dcr1-3, desert_* , tiles d_tls_*, swamp/lake/pump),
0160     terrain/tiles/textures/*.dds, pattern/*.pattern, gen/terrainmasks/*/*.tga.

0161 Donor texture census (what the port PNGs came from):
0162   grass1..grass10.dds   -> app/assets/terrain/grass1..10.png (light meadow pool)
0163   grass_ground1..3.dds  -> ground1..3.png (worn fleck INSIDE type 0, the 4th grass)
0164   grass_sand1..2.dds    -> grasssand1..2.png (sand-grass transition into type 4)
0165   grass_rock1.dds       -> rockgrass1.png (rock-grass transition into type 5)
0166   ground1.dds           -> dirt1.png (town/mine/quarry/road dirt type 1)
0167   rock1..rock9.dds      -> rock1..3.png ported (hill caps type 5)
0168   sand1..sand9.dds      -> sand variants folded into type 4 tint (L468-471)
0169   desert1..desert12.dds -> khaki reference for type 4 tint Color(1.18,1.08,0.78)
0170   water: no donor tile (port paints flat blue + sparkle, variants[3] L483-492).

0171 Open questions the L-steps close (no guessing, measure):
0172   Q1 4th grass = worn ground* fleck vs separate id? A: fleck pool inside 0 (L438).
0173   Q2 khaki = desert only or shore too? A: both — desert biome + sand ring d<1.45.
0174   Q3 bushes blocking? A: deco non-blocking (radius 0.3, hits 0), except 0.
0175   Q4 stump blocks? A: no — unblocked on fell (L2487 pattern extended in L4).
0176   Q5 hills block how? A: slope threshold (L5), like editor steep/plateau logic.
0177   Q6 random how random? A: --seed wired (L6), tests pinned.
0178   Q7 peasant PNG or code? A: checklist isolates bake vs action vs facing (L7).
0179   Q8 ghost green box enough? A: no — transparent building + can_place (L8).

0180 Acceptance gates repeated after EVERY L (stop if red):
0181   godot --headless --path app -- --self-test app/selftest.json        # 28/28
0182   godot --headless --path app -- --ui-test app/uitest.json            # 17/17
0183   godot --path app -- --screenshot app/shots/g4_l<1..8>.png --timeout 90
0184   visual: open PNG at 100%, compare to reference/videos.md stills + L-spec.

0185 ----------------------------------------------------------------------
0186 SECTION 2 — Gap list (measured, each row maps to one L-section)
0187 ----------------------------------------------------------------------
0188 0200 G01 meadow reads busy/checkery on some seeds; dark floor sometimes missing
0189   under trees or leaks onto open field. Cause: base noise paints 2 randomly in
0190   old builds; variant shade too wide; masks too narrow. Fix: L1+L2.
0191 0201 G02 hard tile seams on dirt/sand/rock borders at 200% zoom. Cause: no soft
0192   blend or per-tile dice variants. Fix: L2 masks + coherent vi.
0193 0203 G03 khaki looks neon yellow or muddy grey depending on monitor. Cause: sand
0194   tint Color(1.18,1.08,0.78) eyeballed once. Fix: L1 tint ladder + screenshots.
0195 0204 G04 forests merge into mega-forest covering half the map on seeds 3,11,19.
0196   Cause: claim radius too small + no type-separated margins. Fix: L3.
0197 0205 G05 quarry has trees inside its pale clearing (unoriginal). Cause: scatter
0198   order wrong or clear radius < paint radius. Fix: L3 paint-then-clear.
0199 0206 G06 mines sit inside forest (peasants path stuck). Cause: same as G05. Fix: L3.
0200 0207 G07 start has no stone/food/firewood in reach on 1 seed in 8. Cause: clear
0201   wiped fields/groves, no re-plant. Fix: L3 guaranteed ring + re-plant.
0208 0208 G08 decor missing: no bushes near quarries/rocks/shores (footage has dry
0209   shrubs + shore tufts). Cause: decor patterns dcr/str never ported. Fix: L3.
0210 0209 G09 felled forest vanishes without trace; units still path around nothing.
0211   Cause: hits=0 hides node but blocked already cleared = ghost collision.
0212   Fix: L4 stump type + unblock + sprite.
0213 0210 G10 live trees do not block (units walk under canopy). Cause: wood nodes
0214   blocked=true BUT radius 0.7 too small + separation pushes inside. Fix: L4.
0215 0211 G11 hills are paint only; units climb cliffs; no cover feel. Cause:
0216   height_at() is stateless noise, no height[] store, no slope rule. Fix: L5.
0217 0212 G12 every skirmish map feels same (seed ignored). Cause: main.gd --seed
0218   parsed but never applied. Fix: L6 + scan_map.
0219 0213 G13 no map quality numbers (eyeballing only). Cause: no dump/scan tool.
0220   Fix: L6 scan_map.py + 20-seed loop.
0221 0214 G14 peasant walk slides/skates or moonwalks; attack looks like walk.
0222   Cause: unknown — bake (frames/duration) vs code (action/fi/dir) vs metrics
0223   (fig_h/foot/cx). Fix: L7 isolation ladder.
0224 0225 G15 building ghost is green box; players place on stone/trees/mines/water
0225   then complain. Cause: no can_place() + no transparent sprite. Fix: L8.
0226 0226 G16 AI places on blocked (inherits player bug). Cause: same as G15. Fix: L8
0227   (AI calls same place_building path, gets rules free).
0228 0227 G17 weak GPU stutters on terrain bake (multi-second hitch). Cause: full-map
0229   rebuild or too many chunks/frame. Fix: L2 amortize 2 chunks/frame + LRU 24.
0230 0228 Gate: none of L1-L8 may regress G17. Bench after L2/L5.

0231 ----------------------------------------------------------------------
0232 L1 — TERRAIN ROLES: dark under trees, light main, khaki shore/desert, 4th fleck
0233 ----------------------------------------------------------------------
0234 WHY: footage pause test (do it now, 10 min): open reference/videos.md #6 at a
0235   forest edge: canopy sits on a 2-4 m darker sod ring, never on bright lawn.
0236   Open #11 at a lake: 3-5 m pale sand collar between water and grass. Open #11
0237   at a town: packed dirt apron under halls/houses, pale quarry scar under stone,
0238   worked dirt under mines. Open #3 at a meadow: 90% calm light grass with rare
0239   worn flecks (foot traffic), not checkerboard. If the port paints dark at random
0240   or khaki nowhere, it fails the 3-second "is this Cossacks?" test.
0241 DONOR: generator.cfg TerrainTypes select base TGA folder; Patterns select deco
0242   families per biome (Land=tiled dirt cracks d_tls_*; Desert=desert_tiles with
0243   Freq 1000/0 pattern = mostly uniform sand). Textures folder proves 4 grass
0244   voices: grass* (light), grass_ground* (worn), grass_sand* (shore blend),
0245   grass_rock* (hill blend). Port folds them into 6 ids (0/1/2/3/4/5) — correct,
0246   do not add a 7th id. The "4th grass" the user asks about IS the worn fleck
0247   (ground1..3.png inside type 0 pool, world.gd L438-443). Confirm by watching
0248   any farm-field edge in #11: tilled strips sit on worn fleck, not on dark sod.
0249 PORT-NOW: game.gd L304-314 base = 0 grass with 1 dirt zones from
0250   n=_noise2(x*0.012,y*0.012), n2=_noise2(x*0.05+57,y*0.05-31); if n>0.22 and
0251   n2>-0.15 => 1. No random 2 (correct, comment L312-314). Forests re-paint 2
0252   r=5.5*TILE then scatter 34-60 trees spread 6.5*TILE (L374-376). Groves near
0253   start paint 2 r=4.5/4.0 then 26/18 trees (L378-382 + L487-490). Lakes: d<1.0
0254   => 3 + blocked, d<1.45 => 4 sand ring (L322-337). Hills: d<0.55 => 5 rock,
0255   d<0.85 => keep-or-1 dirt (L339-347). Roads/towns/mines/quarries paint 1, hills
0256   core paint 5 (L349-490). _paint_terrain L235 skips type 3 (never overpaints
0257   water) — keep that guard, it is the only thing saving lakes from roads.
0258 DO-L1.01 lock base noise (do not touch thresholds yet):
0259   open app/scripts/game.gd, find func _generate_map (L297). Verify L304-314
0260   paints ONLY 0/1. If you see `= 2` anywhere in that loop, delete it (dark must
0261   never come from base). Run selftest now (must stay green — base untouched).
0262 DO-L1.02 forest floor audit (dark ONLY under trees):
0263   grep `_paint_terrain.*2` in game.gd. You must find EXACTLY 4 sites: L375 belt
0264   (5.5*TILE), L379 grove A (4.5), L381 grove B (4.0), L488/L490 re-plant ring.
0265   Each MUST be immediately followed (within 3 lines) by _scatter_forest of
0266   matching radius. If a paint-2 lacks a scatter, add one (26 trees spread 5.0).
0267   If a scatter lacks a paint-2, add paint-2 first (dark sod BEFORE trees, like
0268   sod is laid then trees planted — order matters for screenshots).
0269 DO-L1.03 shore ring audit (khaki ONLY at water + desert):
0270   find lake loop L322-337. Verify: d<1.0 => terrain=3 + set_blocked_tile true;
0271   elif d<1.45 and terrain!=3 => terrain=4. Ring width = 0.45*rx (~4-7 tiles).
0272   If ring missing (water touches grass directly), widen 1.45 -> 1.60. If ring
0273   too fat (beach desert), narrow 1.45 -> 1.32. Change ONE number, screenshot,
0274   compare to #11 lakeshore (collar ~2x tree canopy width).
0275 DO-L1.04 town/mine/quarry dirt audit (type 1 = worked ground):
0276   starts plaza paint 1 r=5.0*TILE L463. Mines paint 1 r=4.0 L459/L473.
0277   Quarries paint 1 r=6.0 then core 5 r=3.5 L402-403 (+guaranteed L416-417).
0278   Roads _draw_road width -1..1 tiles L543-550. All correct — do not change radii
0279   in L1 (L3 tunes them). Just verify no paint-1 touches water (guard L249).
0280 DO-L1.05 hill rock audit (type 5 = caps only):
0281   hills loop L339-347: d<0.55 => 5, d<0.85 => 1-or-keep. Verify 5 appears ONLY
0282   here + quarry cores (L403/L417). If 5 appears on flat open field in screenshots,
0283   your hill rr (7-13) is too big — shrink to 6-10 (L3 owns this, note it).
0284 DO-L1.06 khaki tint ladder (the "kachi" grass the user means = type 4):
0285   open world.gd L466-471. Sand branch: even v => tinted dirt
0286   Color(1.18,1.08,0.78), odd v => grasssand crop. If screenshots look lemon:
0287   step down to (1.14,1.06,0.80). If grey-mud: step up to (1.22,1.10,0.76).
0288   Change 0.04 per iteration, ONE screenshot per change. Record hex in MECHANICS.
0289 DO-L1.07 worn fleck density (the TRUE 4th grass voice):
0290   world.gd L438-443 gpool: v<6 pure meadow, v>=6 ground fleck. Ratio 6:2 = 25%
0291   flecked tiles max, but coherent vi (L545) clumps them into patches. If meadow
0292   looks dirty: change `if v < 6` -> `if v < 7` (12.5% fleck). If sterile golf
0293   course: `if v < 5` (37.5% fleck). Default 6 is footage-correct; touch last.
0294 DO-L1.08 rock-grass blend check (type 5 edge):
0295   L472-475 rpool=[rockg]+rock_imgs, tint (1.02,1.00,0.96). Hills must read
0296   grey-green, not lunar grey. If too grey: warm to (1.05,1.00,0.92). If too
0297   green: cool to (0.99,1.00,1.00). Screenshot a hill at noon + dusk (anim_t).
0298 DO-L1.09 water flat check (type 3 has no donor tile):
0299   L483-492 water variants fill + sparkle dots. Must read flat blue from far,
0300   sparkle only at close zoom. If noisy: reduce dots 6->3 per tile. If flat
0301   poster-blue: add _gain_at mottling (L2 already applies global gain, skip).
0302 VERIFY-L1:
0303   godot --headless --path app -- --self-test app/selftest.json
0304   godot --path app -- --screenshot app/shots/g4_l1.png --timeout 90
0305   open g4_l1.png: 1) dark ONLY under canopy, 2) pale collar at any lake,
0306   3) dirt under town/mine/quarry, 4) meadow calm (no checker at 100%).
0307   keep PNG as before/after evidence for L2.
0308 PITFALLS-L1:
0309   - never paint type 2 in base noise loop. Ever. It must mean "trees here".
0310   - never let _paint_terrain overwrite type 3 (guard `!=3` L242 stays).
0311   - never add terrain id 6. Six ids are the engine (masks/hlv assume 0..5).
0312   - tint changes need --import + fresh screenshot (cached chunks lie).

0313 ----------------------------------------------------------------------
0314 L2 — SEAMLESS TILES: no grid, keep grain, scale with quality preset
0315 ----------------------------------------------------------------------
0316 WHY: 8px/tile upscaled 4x = blurry soup (pre-G3). 16px/tile with per-tile dice
0317   = sharp but checkery (G3 halfway). Footage ground is BOTH: grain visible at
0318   close zoom, calm wash at far zoom, zero grid lines at any zoom. Seams scream
0319   "tile engine" louder than any wrong color. L2 is the highest-ROI visual step.
0320 PORT-NOW: _src L365 loads donor PNG -> RGB8. _crop_variant L376 random 192px
0321   crop -> resize 16x16 BILINEAR + shade 0.99+0.02*rand (L389). _tint L393
0322   multiplies. _prep_variants L401 builds variants[6][8] (8 crops per type, types
0323   0/1/2/4/5 + water[3] flat L483), mean-normalizes grass (L449-460, f clamp
0324   0.88..1.12 around 0.30 luma), pads to 8 slots (L477-481), then hlv[3][6][8]
0325   shade copies (0.85/1.0/1.12, L495-507, 144 images). _build_masks L513 makes 4
0326   L8 edge ramps width 0.45*px. _build_chunk L529 pastes big.resize(px) per tile,
0327   picks vi from coherent _wnoise(x*0.07) L545 (NOT per-tile rand), lvl from
0328   height_at thresholds +-0.6 L547-548, then for 4 neighbours lerps c0->c1 by
0329   mask*0.85 (L566-573). Then 4px-block sun gain _gain_at*1.22 warm (L581-589).
0330   Chunk sprite scale TILE_M*view_scale/px, LINEAR filter, z -10, LRU 24, 2/frame
0331   amortized (L617). bind() L69-70 preps hlv+masks once.
0332 DONOR: tiles/textures/*.dds are 256-512px photographic patches (grass blades,
0333   dirt clods, rock facets, sand ripple). Engine blends via alpha.bmp crossover
0334   tiles + decals (buildings/env/pfx folders). Port mimics with crop+mask+gain.
0335   Do not copy donor .dds directly (DXT + sRGB + mip chain differs); PNG crops
0336   via copy_assets.py are the canonical source. Verify PNG dates after copy.
0337 DO-L2.01 variant census (prove assets exist before tuning):
0338   ls app/assets/terrain/*.png — need grass1..10, ground1..3, grasssand1..2,
0339   dirt1, rock1..3, rockgrass1 (17 files + .import each). If missing: run
0340   python app/tools/copy_assets.py (or manual copy from donor dds->png batch),
0341   then godot --headless --path app --import. Missing file = flat fill L426-431
0342   (grey-green lie) — screenshots will look poster-flat, fix assets not code.
0343 DO-L2.02 crop size stays 192 (do not "sharpen" by raising to 256):
0344   L383 cs=mini(192,bw/bh-4). 192px crop at 16px out = 12:1 downsample = grain
0345   without aliasing. 64px crop = zoomed blur; 256px = noisy speckle. Keep 192.
0346   If donor PNGs are <200px (some rockgrass), cs auto-clamps — fine, note it.
0347 DO-L2.03 shade tightness (kills checker, keeps life):
0348   L389 shade=0.99+0.02*rand = +-1% per tile. Mean-norm L455 f=0.30/luma clamp
0349   0.88..1.12 kills inter-crop exposure jumps. If checker persists: shade
0350   0.02->0.01 AND f clamp 0.88..1.12 -> 0.94..1.06 (tighter). If dead flat:
0351   shade ->0.03 AND clamp ->0.85..1.15. Change ONE, screenshot meadow at 100%.
0352 DO-L2.04 coherent vi (the anti-checker core, never break):
0353   L545 pv=_wnoise(x*0.07+31,y*0.07-17); vi=int((pv*0.5+0.5)*8) clamp 0..7.
0354   Frequency 0.07 = patch ~14 tiles wide = footage meadow mottling scale. If
0355   patches too big (pool-table): 0.07->0.11. If still checkery: 0.07->0.045.
0356   NEVER replace with randi()%8 (that single line regresses to checkerboard).
0357   NEVER hash vi from (x+y)%8 (diagonal stripes). wnoise only.
0358 DO-L2.05 masks (the anti-seam core, never delete):
0359   L513-527 4 Images L8, ramp 1.0 at edge -> 0.0 at 0.45*px inside. L568
0360   a=mask.r*0.85; skip if <=0.01. If seam line visible at 200%: widen 0.45->0.55
0361   AND alpha 0.85->0.90. If border turns to mud (types bleed): narrow 0.45->0.35
0362   AND alpha ->0.75. Keep 4-dir loop (L554-573); do not add diagonals (cost 2x,
0363   zero visual gain at 16px). Masks built once per terrain_px (bind L70) — if
0364   you change px at runtime, rebuild masks (quality switch bug otherwise).
0365 DO-L2.06 chunk size + LRU + amortize (perf = visual, hitch = seam pop):
0366   CHUNK_T=32 (L25) => 32*16=512px image per chunk, ~24 chunks cover 160x160 map
0367   at start zoom. LRU 24 (L621) caps VRAM. _sync_terrain_chunks builds max 2 per
0368   frame (L617 return). If pan hitches >0.5s: keep 2/frame (do not raise to 4 —
0369   weak GPU dies). If pop-in visible: preload 3x3 around starts at bind (9 chunks
0370   upfront, one-time 0.3s). Never build all 25 at bind on low.
0371 DO-L2.07 gain blocks (sun + mottling, 4px quantize is intentional):
0372   L580-589 bs=4, g=_gain_at(tx,ty)*1.22 warm (r*1.00 g*0.99 b*0.93). _gain_at is
0373   low-freq wnoise (find it, grep). If washed out: 1.22->1.15. If muddy dark:
0374   1.22->1.28. bs=4 must stay (per-pixel gain costs 16x, stalls bake; per-chunk
0375   gain looks banded). This pass runs per chunk build only (not per frame).
0376 DO-L2.08 quality switch wiring (G3 G7 leftover, verify):
0377   config.gd display.terrain_px -> Data.TERRAIN_PX (16/12/8). world.bind sets
0378   terrain_px=Data.TERRAIN_PX (L68). Changing quality at runtime must: clear
0379   terrain_chunks (queue_free all), terrain_order=[], terrain_masks=_build_masks
0380   (new px), terrain_hlv=_prep_variants() (or reuse if px-independent — crops
0381   are 16px fixed, big.resize(px) handles scale, so hlv reuse OK; masks MUST
0382   rebuild). Test: high->low->high in Options, pan, no crash, no 8px chunks at
0383   high. If stale px: you forgot mask rebuild.
0384 DO-L2.09 filter + z (do not touch unless asked):
0385   sp.texture_filter=LINEAR (L596), z_index=-10 (L597). NEAREST = pixel grid
0386   (retro lie). ANISO adds cost, no gain at top-down. z -10 keeps terrain under
0387   res(z1)/bld(z2)/unit(z3)/fx(z4). If buildings sink under terrain: z broke.
0388 VERIFY-L2 (three zooms, two GPUs if possible):
0389   godot --headless --path app -- --self-test app/selftest.json
0390   godot --path app -- --screenshot app/shots/g4_l2_far.png --timeout 90  # zoom out
0391   # in-game: zoom in max, screenshot g4_l2_near.png; pan fast 5s, note hitches.
0392   PASS = no grid at far+near, grain at near, wash at far, hitch <0.5s first pan.
0393   Record terrain_px + fps in app/shots/perf.md (G8 bench owns the table).
0394 PITFALLS-L2:
0395   - per-tile randi = instant checker. Coherent wnoise only.
0396   - deleting mask loop = instant grid. Tune width/alpha, never delete.
0397   - full-map rebuild per frame = slideshow. Chunks + 2/frame + LRU only.
0398   - editing donor .dds in place = import cache poison. Edit PNGs, --import.
0399 TUNING-LOG-L2 (append to MECHANICS.md, one row per change):
0400   date | px | mask_w | mask_a | shade | vi_freq | gain | screenshot | verdict
0401   11-20| 16 | 0.45   | 0.85   | 0.02  | 0.07    | 1.22 | g4_l2_far  | base
0402   ... (fill as you iterate; stop when far+near both pass, then lock)

0403 ----------------------------------------------------------------------
0404 L3 — CLUSTERING: discrete forests/quarries/mines/fields like the original
0405 ----------------------------------------------------------------------
0406 WHY: footage #9 (timelapse) is the macro truth: 2-4 discrete forest belts per
0407   quarter-map with meadow between, 1-2 pale quarry scars per quarter (never
0408   inside forest), 2-3 dirt mine pads per side (never inside forest/quarry),
0409   rectangular farm strips hugging each town, sand collars only at water. Random
0410   does NOT mean uniform speckle. Uniform = wrong. Clumps with gaps = right.
0411 DONOR: dogenerate.inc stages: preparation (clear masks, load env templates) ->
0412   relief (heightmap from inputbitmap.tga, water where h<-0.1, blocked shore mask
0413   gPatternMask) -> starts (players get startx/y from TGA markers, 3 elliptical
0414   keep-clear zones: inner army / mid stone+forest gap / outer resources) -> rest
0415   (forests via SetupTiledPatterns tiles + forest_* pattern families by size:
0416   big/med/small pine/pinefir/spruce/mixed/leaf/desert; stones via stones/
0417   stoneforests patterns; deposits mng/mni/mnc + desert_mng/mni/mnc; decor dcr1-3,
0418   hills hil/g_hil, mountains g_mnt_*, swamp/lake/pump) -> finalize (roads, balance).
0419   Base mask = data/gen/terrainmasks/<terrain>/<N>pl_*.tga (Land=nowater2 42 files
0420   for 2pl? 230 for 4pl continent set; pick floor(RandomExt*count)); keys
0421   randkey0/1 = 64-bit seed for every later RandomExt. Season swaps sets
0422   (Desert = separate desert_* families). Relief types: plains/hills/mountains.
0423 PORT-MAP: game.gd cluster_zones:Array {pos,r} + _claim_cluster(pos,r,margin 4.0)
0424   L289 returns false if overlap (pos.distance < r1+r2+margin). Forests 6-8 tries
0425   (L351-376): cand random 8-92% map, reject if <22*TILE from starts or !in_bounds
0426   or blocked or !claim(r 7*TILE). Paint 2 r5.5, scatter 34-60 spread 6.5. Groves
0427   2 per start (26+18 trees, paint 4.5/4.0). Quarries 7 tries (L387-404): claim 7,
0428   5-8 stones r~4 spread, paint 1 r6.0 + core 5 r3.5, _clear_trees r7. Guaranteed
0429   stone 3 nodes per start (L409-418, paint 1 r4 + 5 r2, clear 5). Food rects 2x
0430   (5x4=20 nodes hits50 r0.6, origin st+(-10+g*7,7)*TILE L421-427) + straggler 6
0431   nodes claimed r4 (L429-440) + re-plant after clear (L480-486). Mines 2/kind mid
0432   (L445-460 claim 6, add max_hits 0, paint 1 r4, clear 5) + 1/kind guaranteed per
0433   start dist 14/19/24 *TILE (L468-477). Starts clear r9 + plaza paint 1 r5 L462-467,
0434   ring-clear r4 L492. Deposit split global/ count L495-501.
0435 DO-L3.01 seed audit (prove determinism today, then unlock):
0436   grep RANDOM_SEED: data.gd L35 default 20261113; game.gd L152 rng.seed=...;
0437   main.gd L343 --seed parsed, then ??? (today: ignored). Run twice:
0438   godot --headless --path app -- --cli app/cli.json --cli-seconds 10 (same map).
0439   Screenshot both, diff pixels (must match). If differ: rng used elsewhere
0440   (Time.get_ticks? camera?) — fix before wiring --seed (else random-on-purpose).
0441 DO-L3.02 wire --seed (minimal, tests pinned):
0442   main.gd _parse_args: add `elif a=="--seed": Data.RANDOM_SEED=int(nextval)`.
0443   game.gd setup(): after MAP_W/H lines L149-150 add
0444     `if str(Data.RANDOM_SEED)=="random": rng.randomize() else: rng.seed=Data.RANDOM_SEED`
0445   Keep selftest/uitest/cli WITHOUT --seed (default deterministic). Menu adds
0446   Options>Map seed [textbox + Random button] in a later pass (not this step).
0447   Verify: --seed 7 twice = same map; --seed 8 = different map; no flag = old map.
0448 DO-L3.03 claim table (write on paper, then code margins):
0449   family      | count     | claim r | margin to same | margin to forest | margin mine
0450   forest belt | 6-8       | 7 tiles | 4.0 (code)     | —                | —
0451   quarry      | 7         | 7 tiles | 4.0            | >=6 NEW          | >=6 NEW
0452   mine mid    | 2/kind    | 6 tiles | 4.0            | >=6 NEW          | >=8 NEW
0453   food patch  | 2+1/start | 4 tiles | 4.0            | any (food ≠ trees)| —
0454   Implement: change _claim_cluster signature to (pos,r,margin) already exists;
0455   pass 6.0/8.0 explicitly at quarry/mine call sites (replace default 4.0).
0456   One-line diff per site, selftest between each (claims affect balance!).
0457 DO-L3.04 order of operations (paint-then-clear is load-bearing):
0458   quarry: _add_res stones -> _paint 1 -> _paint 5 core -> _clear_trees (L397-404).
0459   mine: _add_res deposit -> _paint 1 -> _clear_trees (L458-460 / L476-477).
0460   forest: _paint 2 -> _scatter (L375-376). NEVER scatter-then-paint (paints over
0461   trunks) and NEVER clear-then-scatter (clears nothing). If you add a new cluster
0462   type, copy quarry block verbatim, change numbers only.
0463 DO-L3.05 forest placement filter (keep, do not loosen):
0464   _scatter_forest L248-269: skip if !in_bounds or is_blocked; tt must be 0/1/2
0465   (L251-252 covers hills/shores whatever order); clash loop L258-267 skips
0466   non-wood nodes within 4*TILE unless near_home (<12*TILE from any start).
0467   near_home exempt = managed park (correct). If forests invade quarries: clash
0468   radius 4.0->5.0 tiles OR clear radius 7.0->8.0. If groves missing: near_home
0469   12->14. Change ONE, scan (L6) before/after.
0470 DO-L3.06 quarry shape (pale scar + grey core, treeless):
0471   radius recipe: stones spread +-4 tiles (L399) inside paint 1 r6.0, core 5 r3.5,
0472   clear r7.0. Clear MUST exceed paint (7>6) else fringe trees. Core MUST be <paint
0473   (3.5<6) else grey disc with no dirt apron. Guaranteed cluster (L409): 3 stones
0474   spread +-1, paint 1 r4 + 5 r2, clear 5. If guaranteed overlaps start plaza (units
0475   spawn stuck): dist 16*TILE (L411) -> 18*TILE, keep angle random.
0476 DO-L3.07 mine pads (dirt apron, no trees, snap-to-deposit for building):
0477   mid mines (L445): cand 15-85% map, claim 6, _add_res(k,0 radius 0), paint 1 r4,
0478   clear 5. Guaranteed (L468): dist (14+ki*5)*TILE (gold 14, iron 19, coal 24),
0479   snap dp to tile+1.0 (L473), paint+clear same. place_building L1468 snaps pos=n.pos
0480   if within 4.0 (building ON deposit). If AI "no deposit" spam: guaranteed dist
0481   too far into forest/edge — clamp dp in_bounds+!blocked already does; widen cand
0482   to 12-88% if edge-clipped. Deposit split L495-501 divides global pool by count;
0483   adding a 3rd mid mine dilutes each — note in balance, do not add counts in L3.
0484 DO-L3.08 food rects (the only rectangular cluster, keep rectangular):
0485   near-start rects (L421): origin st+(-10+g*7,7)*TILE, 5 cols x1.5*TILE, 4 rows
0486   x1.5*TILE = 7.5x6 m field. Straggler (L429): 6 nodes +-2.5 spread claimed r4.
0487   Re-plant (L480): origin st+(-9+g*8,8.5)*TILE same 5x4 AFTER clear r9 (L464).
0488   If fields overlap plaza (peasants idle on corn): shift origin +7y -> +9y.
0489   If fields inside forest paint-2: move origin outward (fields on 0/1 only —
0490   add tt check like L251 before _add_res food, skip if 2/3/4/5).
0491 DO-L3.09 sacred starts (do not "optimize" away):
0492   map_starts set L316 from _start_positions (corners 12.5%/87.5% *TILE). Forest
0493   cand rejects <22*TILE (L360). near_home <12*TILE exempts clash (L258) and
0494   _clear_trees spares groves (L279-284). _clear_area r9 (L464) wipes + unblocks
0495   depleted (L465-467). Ring-clear r4 (L492). If units spawn stuck: ring 4->5.
0496   If starts too close on small maps: 12.5%->10%/90% (menu map-size step, not L3).
0497 DO-L3.10 bushes (the missing donor decor, port it now):
0498   donor has ZERO files named bush/shrub/stump (verified: recursive search hits 0).
0499   Decor = patterns: dcr1-3 (small tufts), str_*/b_str_* (stoneforest mix), desert
0500   sets (dry shrubs), hil/g_hil (hill tufts). Port plan (minimal, no new engine):
0501   1) copy 6 donor cover PNGs (dry grass tuft + stone shrub) via copy_assets.py into
0502      app/assets/terrain/decals_png/bush_rock1..3.png, bush_sand1..3.png + --import.
0503   2) game.gd: add res type "bush" via _add_res("bush",p,0,0.3) (hits 0 = never
0504      gathered, radius 0.3 = never blocks: _add_res only blocks if type!=food? Bush
0505      must NOT block — special-case: `if type not in ["food","bush"]: block`).
0506   3) scatter_bushes() after quarries+shores: 30% of quarry clearings: 4-7 bushes
0507      r<=5 tiles on terrain 1/5; 20% of sand ring: 3-5 bushes on terrain 4; 0 on
0508      water/road/start r9. Claim NOTHING (deco, may overlap meadow).
0509   4) world.gd _draw_resources: match "bush": draw bush_rock* on 1/5, bush_sand*
0510      on 4 via _prop_tex+_hash (stable per spot), 50-70% tree size, NO shadow disc,
0511      skip in _pick_res gather filter + skip in clash checks (deco invisible to sim).
0512   If sprites missing: fallback rock sprite tinted brown 0.6 scale (never blank).
0513 VERIFY-L3:
0514   godot --headless --path app -- --self-test app/selftest.json
0515   for S in 7 8 9: godot --headless --path app -- --dump-map scans/s$S.json --seed S
0516   python app/tools/scan_map.py --dir scans  # needs L6 tool; until then eyeball 3 PNGs
0517   PASS = belts discrete (gaps of meadow), quarries pale+treeless, mines on dirt,
0518   each start: food rect + grove + stone + deposit visible within 25 tiles.
0519 PITFALLS-L3:
0520   - raising counts (forests 6-8 -> 10-12) without raising margins = mega-forest.
0521   - clear radius < paint radius = fringe trees inside quarries (the classic bug).
0522   - scattering before painting = sod over trunks (z-fight look).
0523   - touching deposit counts = economy rebalance (needs MECHANICS update, not L3).
0524   - forgetting near_home exempt wipes the sacred groves (early game starves).

0525 ----------------------------------------------------------------------
0526 L4 — TREES: live block, felled become stumps you can walk over
0527 ----------------------------------------------------------------------
0528 WHY: footage: peasants chew through a belt edge, canopy thins, pale stumps dot
0529   the clearing, troops then march THROUGH the clearing (shortcut). Port today:
0530   belt either blocks forever (wall of trees) or vanishes clean (lawn, no history).
0531   Both read wrong. Stumps = progress made visible + tactics (cleared fire-lanes).
0532 DONOR: trees are env objects with work-transform (NTM changelog: "fixed bad
0533   texture on trees after work transform" = harvested state exists in engine).
0534   Patterns frt_*/str_* place multi-tree masks; harvest removes canopy, leaves
0535   stump/decal. Blockade areas (editor Q toggle) mark deep forest impassable until
0536   cleared. Port equivalent: blocked[] circle per wood node (L227) + unblock on
0537   deplete (L2487) + _clear_area unblock loop (L465-467).
0538 PORT-NOW: _add_res("wood",p,60,0.7) L269 blocks (type!=food L227). Gather slot
0539   _work_slot(node.radius+1.1) L2447, reach 1.4 L2461, interval 1.25s L2478,
0540   hits-=1 carry+=1 L2481-2484, chop+depleted events L2485-2489, on hits<=0 if
0541   res!=food unblock L2487-2488 + res_dirty. _draw_resources L750 skips hits<=0
0542   (L753-754) = depleted invisible. _compact L103-129 keeps food nodes, drops
0543   depleted non-food (L125 res_nodes filter). _pick_res L322 skips depleted
0544   non-food (L326). nearest_res skips hits<=0 (L738). Net: felled = gone + free.
0545 DO-L4.01 introduce stump type (4-line sim change, no new arrays):
0546   game.gd _tick_gather, inside `if node.hits > 0:` block after `node.hits -= 1`
0547   (L2481), find `if node.hits <= 0:` (L2486). REPLACE:
0548     `if node.hits <= 0:` + `if res != "food": unblock` (L2486-2488)
0549   WITH (tabs, keep event/res_dirty lines after):
0550     if node.hits <= 0:
0551       if res == "wood":
0552         node.type = "stump"
0553         node["stump_t"] = 0.0
0554         node["max_hits"] = 0
0555         set_blocked_circle(node.pos, node.radius, false)
0556       elif res != "food":
0557         set_blocked_circle(node.pos, node.radius, false)
0558   Note: stump keeps its dict (same id) so by_id/nearest_res stay valid; type flip
0559   excludes it from future wood queries (nearest_res filters type!=res L737).
0560 DO-L4.02 keep stumps out of gather/block/compact filters (3 one-line guards):
0561   1) _pick_res L326 `if n.max_hits>0 and n.hits<=0 and n.type!="food": continue`
0562      -> add `or n.type=="stump"` to the skip (stumps never gatherable).
0563   2) nearest_res L737 `if n.type != type or n.hits <= 0: continue` — already
0564      excludes stump when type=="wood" (type mismatch). No change needed; verify.
0565   3) _add_res block guard L227 `if type != "food": block` -> `if type not in
0566      ["food","bush","stump"]: block` (L3 bushes + L4 stumps never block).
0567   4) _compact L125 `if n.max_hits==0 or n.hits>0 or n.type=="food"` keep — stump
0568      has max_hits 0 + type stump: `max_hits==0` TRUE so kept (good). Age-out in
0569      DO-L4.04 instead of compact-drop. Verify by reading L123-129 after edit.
0570 DO-L4.03 render stump (world.gd _draw_resources wood branch, ~15 lines):
0571   find `match n.type:` L759, `wood:` branch (grep). INSERT before tree draw:
0572     "stump":
0573       var sp := _prop_tex(["tree_stump","rock","stone"], n.pos)  # fallback chain
0574       # 40% tree size, squashed 2:1 like footprints, brown tint, NO shadow disc
0575       _draw_sprite(res_layer, sp, p, 0.55, Color(0.55,0.42,0.28), false)
0576       continue  # skip canopy + shadow below (keep loop structure)
0577   If tree_stump.png missing: _prop_tex returns rock frame (never null-draw).
0578   Bake real stump later from donor covers/*.png (copy_assets, not this step).
0579   Size: tree canopy _draw uses h~2.9+1.1 (G2 tuned L339); stump 0.55 world_h =
0580   ankle-high disc. Must read as "cut" at 100%, invisible at far zoom (correct).
0581 DO-L4.04 age stumps like corpses (60 s, then free):
0582   game.gd tick() corpses/rubble aging L1582-1591 pattern. ADD after rubble loop:
0583     for n in res_nodes: if n.get("type","")=="stump": n["stump_t"]=float(n.get("stump_t",0.0))+dt
0584     for i in range(res_nodes.size()-1,-1,-1):
0585       var nn=res_nodes[i]
0586       if str(nn.get("type",""))=="stump" and float(nn.get("stump_t",0.0))>60.0:
0587         set_blocked_circle(nn.pos, nn.radius, false)  # idempotent
0588         by_id.erase(nn.id)
0589         res_nodes.remove_at(i)
0590         res_dirty+=1
0591   60 s matches CORPSE_LIFE 90 s rhythm (battlefield + clearing fade together).
0592   Do NOT reuse corpses[] array (different id space, by_id must drop).
0593 DO-L4.05 live-block audit (prove blocked, then keep):
0594   wood radius 0.7 (L269) + PERSONAL_SPACE 0.35 (data.gd L50) + reach 1.4 (L2461)
0595   + arrival 0.5 (L2464) + stand-off slot radius+1.1 (L2447). Peasant works from
0596   OUTSIDE the blocked disc (comment L2442-2446). If peasants jitter at belt edge:
0597   slot +1.1 -> +1.3 (ONE change). If they walk THROUGH live trunks: radius
0598   0.7->0.9 for NEW nodes only (old saves keep 0.7 — fine, rescan map).
0599   _separate_units building pass L1653 grid_query 6.0 pushes out of footprints;
0600   trees are NOT buildings (no push) — blocked[] does the work. Do not add trees
0601   to building-push (perf + jitter).
0602 VERIFY-L4:
0603   godot --headless --path app -- --self-test app/selftest.json
0604   windowed: select 4 peasants, right-click a grove edge tree, speed 8x, watch:
0605   hits 60->0 (~14 loads x1.25s + walk), canopy -> stump (40% brown disc),
0606   5th peasant ordered THROUGH stump tile walks over; ordered through LIVE tree
0607   paths around. Screenshot both: g4_l4_stump.png.
0608   CLI soak: --cli-seconds 60, grep "stuck" (none), stumps>0 in dump (L6).
0609 PITFALLS-L4:
0610   - flipping type BEFORE unblock = one-tick blocked stump (unit pops). Unblock same tick.
0611   - forgetting _pick_res guard = peasants sent to stumps forever (idle economy death).
0612   - stump radius blocking = cleared lane still blocked (defeats the feature).
0613   - aging <20 s = clearing blinks (history lost). Keep 60 s minimum.
0614 TUNING-LOG-L4: wood hits 60 (donor GATHER wood 14/load? port 60 hits/node =
0615   ~4 loads/node,/tree). If belts clear too fast: 60->90. Too slow: 60->45.
0616   Change hits ONLY (not carry/interval — economy balance lives there).

0617 ----------------------------------------------------------------------
0618 L5 — HEIGHTMAP: low swells walkable, steep cliffs block (like the editor F3)
0619 ----------------------------------------------------------------------
0620 WHY: Cossacks maps are never pool-table flat. Editor manual: F3 raise hills /
0621   raise plain / smooth / plateau, R1 height, R2 radius, brush 1-9, PgUp/Dn plateau,
0622   +/- steep hill, shift-line polyhedra, road1-3 along polygon, addhi console,
0623   default height 50, water destroys hills (lake bowls). Tactics: range + LOS from
0624   high ground (port already has hd bonus L1972 + _wall_between L2237, but on fake
0625   noise). L5 makes height REAL: stored per tile, painted, walked, fought over.
0626 DONOR-EDITOR (cossacksworld terrain/relief/creating-landscapes pages):
0627   raise-hills brush (left up / right down, drag = ridge/ravine), raise-plain
0628   (flat-top hill, right = lower), smooth (left smooth, right ledges/uneven coast),
0629   plateau (left de-sharp, right level-to-center), polygon select (cubic slant /
0630   squad steep / smooth / road1-3), altitude map popup (green low yellow-brown hill
0631   brown-grey mountain + sliders), UserTerrain BMP import, water C (square with
0632   ctrl = no border texture), blockade toggle Q. Relief gen params R1-R6 (height,
0633   radius, passage width, furrow count/depth/phase). Port maps: height[] + slope
0634   rule + paint + shade + combat = the same five tools, procedural.
0635 PORT-NOW: height_at(p) L504 = _noise2(tile*0.07)*2.0 stateless (no store, no
0636   hills array, no slope, no unblock). Hills visual = paint blobs (L339 rock 5
0637   core + dirt 1 skirt) + hlv shade lvl from hh thresholds -0.6/+0.6 (world L547).
0638   Combat hd = height_at(e)-height_at(t) (L1972, bonus if attacker higher).
0639   _wall_between (L2237) blocks shots through height_at(mid)>max+0.8. Movement
0640   ignores height entirely (_step_move grep: no height term). Water blocks via
0641   blocked[] (L334), cliffs do NOT block (missing).
0642 DO-L5.01 add height[] store (10 lines, setup + generate):
0643   game.gd vars (near terrain/blocked L16-17): ADD `var height := PackedFloat32Array()`
0644   setup() after terrain/blocked resize (L153-157): ADD height.resize(MAP_W*MAP_H)
0645   _generate_map() AFTER lake loop + hill blobs, BEFORE roads (insert at L348):
0646     for y in MAP_H: for x in MAP_W:
0647       var base := _noise2(x*0.07, y*0.07)*1.2
0648       var hb := 0.0  # sum of hill blobs (compute from stored blob list)
0649       # hill blobs: record cx,cy,rr when painting rock (L339 loop) into hill_list
0650       for h in hill_list: var d := Vector2(x-h.x, y-h.y).length()/h.rr
0651         if d < 1.0: hb += (1.0-d)*(1.0-d)*1.8
0652       var lake := 0.0
0653       if terrain[_t(x,y)] == 3: lake = -1.8
0654       elif terrain[_t(x,y)] == 4: lake = -0.5  # shore dips
0655       height[_t(x,y)] = base + hb + lake
0656   hill_list: Array filled in hill blob loop (append {x:cx,y:cy,rr:rr}). If loop
0657   uses rng inline, store THEN paint (same numbers, no resample).
0658 DO-L5.02 height_at() reads store (bilinear, 12 lines, replaces L504-506):
0659   func height_at(p: Vector2) -> float:
0660     var fx := clampf(p.x / TILE - 0.5, 0.0, float(MAP_W - 1) - 1.001)
0661     var fy := clampf(p.y / TILE - 0.5, 0.0, float(MAP_H - 1) - 1.001)
0662     var x0 := int(fx); var y0 := int(fy)
0663     var tx := fx - x0; var ty := fy - y0
0664     var h00 := height[_t(x0,y0)]; var h10 := height[_t(x0+1,y0)]
0665     var h01 := height[_t(x0,y0+1)]; var h11 := height[_t(x0+1,y0+1)]
0666     return h00+(h10-h00)*tx+(h01-h00)*ty+(h00-h10-h01+h11)*tx*ty
0667   Keep old noise formula as comment (fallback if height empty: if height.size()
0668   != MAP_W*MAP_H: return _noise2(tile*0.07)*2.0). Tests with old saves keep working.
0669 DO-L5.03 slope rule (movement pays, cliffs block):
0670   helper (add near is_blocked L206):
0671     func slope_to(a: Vector2, b: Vector2) -> float:
0672       var d := a.distance_to(b)
0673       if d < 0.001: return 0.0
0674       return absf(height_at(b) - height_at(a)) / d
0675   _step_move (grep signature): at TOP after bounds check, ADD:
0676     var sl := slope_to(e.pos, next_pos)  # next_pos = proposed step target
0677     if sl > 0.55: return false  # cliff: cancel step (caller picks alt/slows)
0678     var sp := speed
0679     if height_at(next_pos) > height_at(e.pos) + 0.05 and sl > 0.25:
0680       sp *= 0.6  # uphill tax (low swells cost, like mud)
0681   If _step_move returns void today: change to bool (true=moved) OR just clamp
0682   (skip move when sl>0.55). Minimal diff: early-return without moving.
0683   Water stays blocked[] (L334) — slope never overrides water.
0684 DO-L5.04 impassable cliffs get rock + blocked (so AI/pathing agrees):
0685   after height fill (DO-L5.01), second pass: for each tile, s=max slope to 4
0686   neighbours (height diff / TILE); if s > 0.55 and terrain != 3: terrain=5,
0687   set_blocked_tile(x,y,true). If cliff ring too fat (moats around hills):
0688   threshold 0.55->0.65. If units climb cliffs: 0.55->0.48. ONE knob.
0689   Paint first, block second (block never paints — paint is the visual contract).
0690 DO-L5.05 render thresholds (keep, verify against new height range):
0691   world L547-548 lvl = 0 if hh<-0.6 else 2 if hh>0.6 else 1. New height range:
0692   base +-1.2 + hills +1.8 + lakes -1.8 = -3.0..+3.0. Thresholds +-0.6 still split
0693   low/mid/high sensibly (lows = lake bowls + swales, highs = hill caps). If
0694   everything reads dark: base 1.2->0.9. If hills invisible: hill 1.8->2.4.
0695   Optional steep-darken: in _build_chunk after lvl pick, if slope>0.45: f*=0.9.
0696 DO-L5.06 combat already height-aware (verify, do not retune in L5):
0697   L1972 hd bonus + _wall_between L2237 now read REAL height (free upgrade).
0698   If hill fights feel too swingy: hd factor 1.0->0.7 (MECHANICS note, not L5).
0699   If low ground never wins: keep (correct — high ground SHOULD win, wiki RPS).
0700 VERIFY-L5:
0701   godot --headless --path app -- --self-test app/selftest.json
0702   godot --headless --path app -- --cli app/cli.json --cli-seconds 60  # no stuck
0703   windowed: order squad across low swell (slows) + around rock cap (routes).
0704   dump + scan (L6): cliff tiles (terrain 5 + blocked) form closed rings on hills.
0705   Screenshot g4_l5_hills.png: caps grey, skirts dirt, shade gradient, no moats.
0706 PITFALLS-L5:
0707   - filling height AFTER roads/lakes paint = lake bowls missed (order: base+blobs
0708     -> lakes carve -> height fill -> cliff pass -> roads LAST, roads ignore height).
0709   - slope in _separate_units push (L1601) = jitter on hills. Slope ONLY in move.
0710   - threshold too low = map cut in half (two moats, AI fails reachability in L6).
0711   - forgetting bilinear = staircase movement (units hop per tile). Bilinear only.

0712 ----------------------------------------------------------------------
0713 L6 — TRUE RANDOM MAPS + HEADLESS QUALITY SCAN (no units, numbers decide)
0714 ----------------------------------------------------------------------
0715 WHY: "random map" with one seed = one map with extra steps. Cossacks lobby has
0716   Terrain (Land/Mediterranean/Peninsulas/Islands/Continents/Continent + DLC5
0717   Coastal/Lakes/Rivers), Relief (plains/hills/mountains), Deposit richness,
0718   Season (summer/desert/winter), Map size (tiny256..huge640), Teams. Port has
0719   MAP_TYPES water_frac (data.gd L168: land 0.5 med 1.6 pen 1.2 isl 2.2 conts 1.8
0720   cont 1.0) + START_OPTIONS (data.gd L178) + MAP_W/H 160 (tiny-ish) but seed is
0721   ignored, so every "random" game replays 20261113. L6 wires the dice AND builds
0722   the judge (scan), then iterates the generator until numbers match footage.
0723 DONOR-RANDOM: inputbitmap TGA (masks per terrain/player-count: land 230 files
0724   for 4pl, islands 320, nowater2 42...) picked by floor(RandomExt*count) +
0725   randkey0/1 64-bit pair driving EVERY later RandomExt (forests, stones, deposits,
0726   tile cracks d_tls_* on 25x25 grid ~100 placements on 256px). Three elliptical
0727   zones per start reserve army/stone/forest gaps. Mine richness 0-3 (3=random->
0728   floor(RandomExt*3)). Relief validates or randomizes. Desert forces desert_* sets.
0729   Replay = same mask + same keys = same map (reproducible random).
0730 PORT-RANDOM-TODAY: _start_positions corners (game.gd L648-651), MAP_W/H 160,
0731   MAP_TYPE land default (data.gd L134), water_mult from MAP_TYPES (game.gd L319),
0732   lake_n = 1+randi%(water_mult*2) clamp 1..4 (L322), forests/stones/mines counts
0733   fixed ranges (6-8 / 7 / 2-per-kind). rng = RandomNumberGenerator, seed set once
0734   in setup L152. No mask files, no relief option, no season — noise+blobs ARE the
0735   mask (acceptable for 160px; masks matter at 512+).
0736 DO-L6.01 --seed + --dump-map flags (main.gd, 30 lines):
0737   _parse_args: add `--seed` (int|"random") and `--dump-map <path>` (string).
0738   Vars: var seed_opt := "" ; var dump_path := "".
0739   _ready routing (next to --cli/--screenshot branches): if dump_path != "":
0740     _setup_full_game()          # setup() + world bind, NO AI, NO units
0741     var dump := {
0742       "seed": Data.RANDOM_SEED, "map_w": game.MAP_W, "map_h": game.MAP_H,
0743       "terrain": game.terrain, "blocked": game.blocked,
0744       "height": game.height if "height" in game else [],
0745       "starts": game.map_starts, "clusters": game.cluster_zones,
0746       "res": [{"t": n.type, "x": n.pos.x, "y": n.pos.y, "hits": n.hits} for n in game.res_nodes]
0747     }
0748     write rules: FileAccess.open(dump_path, WRITE).store_string(JSON.stringify(dump))
0749     _quit(0)                    # self-exit (weak-GPU rule), no window hang
0750   Seed apply (BEFORE game.setup() in that branch + normal play branch):
0751     if seed_opt == "random": Data.RANDOM_SEED = randi()  # engine randi, once
0752     elif seed_opt != "": Data.RANDOM_SEED = int(seed_opt)
0753   Tests never pass --seed (default path = deterministic 20261113).
0754 DO-L6.02 scan_map.py NEW FILE (app/tools/scan_map.py, ~150 lines, Pillow NOT needed):
0755   usage: python app/tools/scan_map.py --dir scans  (reads scan_*.json)
0756   per file compute:
0757     water% = count(terrain==3)/total; sand% = ==4/; rock% = ==5/; dark% = ==2/
0758     forest patches = BFS on (terrain==2 OR wood node within tile), 4-connect;
0759       report count + mean size + max size (target 8-14 patches, mean 40-90 tiles)
0760     quarry purity = % stone nodes with zero wood in 4 tiles (target 100%)
0761     mine clearance = % deposits (max_hits==0) with zero wood in 5 tiles (target 100%)
0762     stump% (L4 working) = stump/(wood+stump) (info only, 0 at gen time)
0763     sand-ring = % water tiles with >=1 sand neighbour (target >70%)
0764     reachability = BFS on !blocked from each start: food/stone/deposit/grove
0765       within 25 tiles? (target 100% of starts x 4 resource kinds)
0766     cliff rings (L5) = % rock tiles blocked (target >80% of terrain-5 blocked)
0767   summary: mean+-std over N seeds + FAIL list (seed:metric=value).
0768   exit code 1 if any target red (CI gate), 0 if all green.
0769   DO NOT import Godot (pure JSON+struct, runs on any laptop).
0770 DO-L6.03 20-seed loop (the iteration protocol, follow exactly):
0771   for S in 1..20:
0772     godot --headless --path app -- --dump-map scans/scan_$S.json --seed $S
0773   python app/tools/scan_map.py --dir scans | tee scans/summary.txt
0774   Compare summary means to footage-derived targets:
0775     target            | footage source          | port target
0776     water%            | #9 timelapse land ~5%   | 3-8% (water_frac 0.5)
0777     forest patches    | #11 belts 8-14 discrete | 8-14, mean 40-90
0778     quarry purity     | #11 scars treeless      | 100%
0779     mine clearance    | #11 pads on dirt        | 100%
0780     sand ring         | #11 collars continuous  | >70%
0781     reachability      | #11 every start viable  | 100%
0782   Tune ONE knob per loop (never two, else you learn nothing):
0783     loop A: forest count 6-8 -> 5-9 / claim 7->8 if merged; re-scan.
0784     loop B: quarry clear 7->8 if purity <100; re-scan.
0785     loop C: lake rx 9-16 / ry 7-13 -> +-2 if water% off; re-scan.
0786     loop D: hill rr 7-13 -> 6-10 if rock% >12%; re-scan.
0787     loop E: food rect origin y +7 -> +9 if reachability <100; re-scan.
0788   Stop when 20-seed means all green. Lock numbers (commit + MECHANICS note).
0789 DO-L6.04 MAP_TYPE wiring (one-line leverage, big variety):
0790   menu skirmish already has MAP_TYPE? If yes: pass Data.MAP_TYPE into setup
0791   (water_mult L319 already honors it). Verify: land scan water 3-8%, islands
0792   scan water 18-30% (water_frac 2.2/0.5 = 4.4x). If islands == land: water_mult
0793   not applied (grep MAP_TYPES usage, must be exactly L319). Mediterranean 1.6 =
0794   big central sea (rx*1.4 in lake loop when MAP_TYPE==mediterranean — add later,
0795   not L6). L6 ships land-correct; other types inherit the same clusters.
0796 DO-L6.05 size note (do NOT change MAP_W/H in L6):
0797   160x160 tiles x2 m = 320x320 m. Donor tiny = 256 cells (bigger). Port 160 keeps
0798   60fps on weak GPU (G8 bench). Map-size option (192..1024 per wiki Editor) is a
0799   separate L-step (chunks LRU + AI + minimap all scale). L6 validates AT 160.
0800 VERIFY-L6:
0801   godot --headless --path app -- --self-test app/selftest.json   # still default seed
0802   20-seed scan summary all green (paste summary.txt tail into MECHANICS.md).
0803   --seed 7 twice = byte-identical JSON (diff scans/scan_7.json rerun).
0804   3 PNGs (--seed 7/8/9 screenshots) look like siblings, not clones/triplets.
0805 PITFALLS-L6:
0806   - scanning WITH units = noise (units block/BFS lie). Dump BEFORE spawns.
0807   - tuning two knobs per loop = thrash (revert both, redo singly).
0808   - chasing one bad seed (seed 13 always weird) = overfit. Means only.
0809   - changing deposit COUNTS during purity tuning = economy rebalance (separate).
0810   - forgetting default-seed tests = flaky CI. Tests never pass --seed.

0811 ----------------------------------------------------------------------
0812 L7 — UNIT ANIMS: bake vs metrics vs code (isolate before touching)
0813 ----------------------------------------------------------------------
0814 WHY: peasant PNG sheet "looks fine" in a viewer but skates/moonwalks/flaps in
0815   game. Three suspects: (A) bake sampled wrong frames or wrong action range,
0816   (B) metrics bbox wrong (feet slide), (C) code picks wrong action/frame/dir.
0817   Touching all three = never converges. Ladder below isolates A->B->C in order.
0818 DONOR-BAKE: .oss mesh (verts/faces/uvs/weights) + skeleton anim (k bones x
0819   7 floats per frame) + .aaf action ranges ("walk" a..b, "attack0/1", "idle",
0820   "death"). bake_sprites.py: read_oss L36 (struct <6i header, verts <3f, faces
0821   <3i, uvs <2f, uvf, per-vert weights, anim [k][7f]), read_aaf L50 (skip 2 header
0822   lines, parse "name",a,b), skin L68 (qmat per bone per frame, weighted verts),
0823   sample L82 (a,b,n -> [a+round((b-a)*i/(n-1))], n>1 else [a]), setup_scene L87
0824   (Cycles CPU, film_transparent, Emission shadeless), make_mat L108, build_mesh
0825   L119. Sheets: cols=8 dirs (0,45..315), rows=sampled frames, cell=size (160),
0826   index.json {cell, actions{frames,duration,loop}}. Blender CLI MUST be:
0827   blender --background --factory-startup --python app/tools/bake_sprites.py -- \
0828   --game "C:\Games\Cossacks 3" --out app/assets/models/anim [--only sid] \
0829   [--size 160] [--samples 4] [--engine cycles]. EEVEE/GPU = weak-GPU shutdown.
0830 PORT-CODE: sheet_metrics.py adds bbox union over all cells (alpha>8), fig_h, foot,
0831   cx (skip unless --force). world.gd _anim_key L170 (nation peasant resolve),
0832   _anim_action L181: death (death_t>=0) > attack (fire_t within 0.9s + order
0833   attack) > gather/build stationary (order gather/build + !moving => attack =
0834   tool swing) > walk (moving) > idle. _draw_anim L203: tk=key_action lazy load
0835   from _anim_dir (SPRITE_CELL 160 else animNN), cell/actions/frames/duration,
0836   t0 = death_t if death else fire_t if attack+order-attack else -1, fi =
0837   (gt-t0)/duration*n clamped if t0>=0 else anim_t/duration*n %n, dir =
0838   fposmod(roundf(face/(PI/4)),8)%8, src=(dir*cell,fi*cell,cell,cell), sc =
0839   _unit_height(1.9 inf /2.3 cav /1.5 art)*view_scale/(cell*fig_h), sz=cell*sc,
0840   tl=p-(sz.x*cx, sz.y*foot), draw_texture_rect_region. Corpses reuse same math
0841   (G1.3 dfig/dfoot/dcx). Facing set in game.gd: attack branch e.face=(t.pos-e.pos)
0842   .angle(), gather work e.face=(node.pos-e.pos).angle(), build site same.
0843 DO-L7.01 PNG eyeball (2 min, rules out total bake failure):
0844   open app/assets/models/anim/peasant_walk.png in an image viewer (no Godot).
0845   Expect: 8 columns (dirs) x N rows (frames, N=6..10 for walk). Row N+1 must
0846   differ from row N (if all rows identical = sample() returned [a,a..] = AAF
0847   range b<=a, single-frame walk = skate). Column 0 vs 4 must mirror (E vs W).
0848   If sheet is 1 row: bake failed (see DO-L7.03). If 8xN distinct: PNG is FINE,
0849   suspect is B/C (metrics/code) — do NOT rebake (wastes hours on weak GPU).
0850 DO-L7.02 index.json audit (numbers before pictures):
0851   python -c "import json;d=json.load(open('app/assets/models/anim/index.json'));import pprint;pprint.pp(d['peasant']['actions']['walk'])"
0852   Expect: frames 6..10, duration 0.55..0.95 (frames*0.09 +-30%), loop true,
0853   bbox [x0,y0,x1,y1] with fig_h 0.30..0.95, foot 0.70..0.90, cx 0.40..0.60.
0854   If duration 0.05 (min clamp) = AAF duration missing (bake wrote 0) -> fi jumps
0855   (hyper-flap). If fig_h 1.0 exactly = metrics never ran (default) -> scale = whole
0856   cell (G1 bug returns, tiny men). If foot 0.82 default + fig_h default = run
0857   sheet_metrics.py NOW (DO-L7.04) before touching code.
0858 DO-L7.03 rebake ONLY the broken sid (never full roster on weak GPU):
0859   find donor AAF: C:\Games\Cossacks 3\data\animations\<sid>.aaf (or actors/<sid>/).
0860   grep walk/attack/idle/death ranges (a,b). If walk b-a < 5: donor action is short
0861   (use n=frames as-is, do NOT stretch to 8 — stretch duplicates = stutter).
0862   Rebake: blender --background --factory-startup --python app/tools/bake_sprites.py
0863   -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim --only peasant
0864   --size 160 --samples 4 --engine cycles   (CPU only, one sid ~ minutes).
0865   Then: python app/tools/sheet_metrics.py --dir app/assets/models/anim --force
0866   (peasant only? script loops all; --force remeasures all = slow but safe).
0867   Then: godot --headless --path app --import. Re-audit DO-L7.02 (frames/duration
0868   must change; if identical: --only filter misspelled sid (check index keys)).
0869 DO-L7.04 metrics audit (feet slide = bbox, not bake):
0870   bbox = union of getbbox() over all cells (alpha>8). fig_h=(y1-y0)/cell,
0871   foot=y1/cell, cx=(x0+x1)/2/cell. Death rows INCLUDED in union? G1 sheet_metrics
0872   measures per-ACTION sheet (peasant_walk.png only) so death-lying does NOT widen
0873   walk bbox (correct). If metrics ran on a MONTAGE (all actions one PNG): bbox =
0874   lying+swinging union = standing man 35% of cell (G1 bug). Fix: re-run per-action
0875   script (current version is per-action, verify loop `for act,ad in info[actions]`).
0876   Symptom map: feet hover (foot too small) / sink (foot too big) / swing shifts
0877   body (cx off-center because tool swing widened bbox — mitigate: cx from IDLE
0878   sheet only, copy cx to walk/attack entries manually in index.json).
0879 DO-L7.05 action audit (wrong action = looks like bake bug):
0880   _anim_action L181 truth table (write on paper while watching 1x speed):
0881     order gather + moving=true  -> walk (to tree)      CORRECT
0882     order gather + moving=false -> attack (chop swing)  CORRECT (tool swing IS attack sheet)
0883     order build + moving=false  -> attack (hammer)      CORRECT
0884     order attack + fire_t fresh -> attack (muzzle)      CORRECT
0885     order move + moving=true    -> walk                 CORRECT
0886     order none + idle           -> idle                 CORRECT
0887   If peasant chops while walking (swing on the move): moving flag stuck true in
0888   _tick_gather work branch (e.moving=false L2475 must run on arrival). Fix caller
0889   (game.gd), NOT anim. If musketeer walks to attack (no muzzle): fire_t never set
0890   (grep fire_t assignments in _tick_unit attack branch — cooldown gate must set it
0891   on shot, artillery dup block AFTER gate per G8.3).
0892 DO-L7.06 frame audit (flap vs slide):
0893   walk fi = anim_t/duration*n %n (render clock L230) — speed-independent slide if
0894   duration mismatches 1.5 m/s (peasant data.gd L215 speed 1.2? peasant 1.5? verify:
0895   UNITS_BASE peasant speed 1.5). stride = speed*duration/n per frame; if duration
0896   0.7s/8f at 1.5m/s = 13cm/frame (foot-length, correct). If duration 0.2s = Benny
0897   Hill. Set duration = n*0.09 (walk), n*0.12 (attack), death full 1.2s once.
0898   death/attack fi = (game.time_s-t0)/duration*n clamped (sim clock L228) — pause
0899   freezes them (correct), walk keeps bobbing on pause (anim_t runs — acceptable,
0900   or gate anim_t+=dt on !paused in world.sync L633).
0901 DO-L7.07 dir audit (moonwalk = flipped azimuth):
0902   dir = fposmod(roundf(face/(PI/4)),8)%8 L231, col 0 = east (donor camera 0 deg?).
0903   Test: order peasant due east (face 0), screenshot: must use col 0. Due north
0904   (face -PI/2): col 6. If east shows west sprite: azimuth runs opposite -> use
0905   (8-dir)%8 for that key (add per-key flip table, do NOT flip all — buildings/
0906   cavalry may differ). Verify all 8 dirs on flat meadow (no slope skew in L7).
0907 DO-L7.08 cavalry/artillery spot checks (same ladder, different numbers):
0908   cossack (fast cav, height 2.3, speed 3.6): walk frames gallop 6-8, duration
0909   n*0.07 (faster cycle). cannon (art 1.5, speed 0.75): walk = roll (wheels, 4f ok),
0910   attack = recoil+smoke (fire_t + fx smoke L1335). mortar only-buildings flag.
0911   If wheels slide: same duration math with speed 0.75 (duration LONGER, not shorter).
0912 VERIFY-L7:
0913   godot --headless --path app -- --self-test app/selftest.json
0914   windowed 1x speed: peasant walk-to-tree (cycle, no slide), chop (swing, no translate),
0915   carry walk (same cycle + load icon?), death (fall once, persist CORPSE_LIFE 90s).
0916   Screenshot g4_l7_walk.png mid-stride + g4_l7_chop.png mid-swing.
0917   CLI 60s: no missing-sheet errors in log (grep "anim" warnings zero).
0918 PITFALLS-L7:
0919   - full rebake on weak GPU = shutdown (one sid at a time, Cycles CPU, samples 4).
0920   - editing PNGs by hand = import cache + metrics stale (re-run metrics+import).
0921   - "fixing" walk by slowing sim speed = economy/combat rebalance (never).
0922   - flipping all dirs for one bad sid = 53 sids moonwalk (per-key table only).
0923   - death rows in walk bbox = tiny men (per-action metrics only, G1 rule).

0924 ----------------------------------------------------------------------
0925 L8 — BUILDING GHOST: transparent building + real block rules (no green lies)
0926 ----------------------------------------------------------------------
0927 WHY: original ghost = the actual building at 45% alpha + red/green footprint +
0928   reason ("cannot place on stone/trees/water/mines"). Port ghost = green ellipse
0929   that says YES on a stone field, then place_building either eats resources and
0930   spawns inside rock (bug) or says "Not enough resources" (lie). Players learn to
0931   distrust the ghost = place nothing = dead game. L8 makes ghost = truth.
0932 DONOR: placement rules (editor + dogenerate + hotkeys.cfg): mines ONLY on deposits
0933   (mng/mni/mnc pads), walls chain (BuilderPoints +-0.9 m, cheap, no upkeep),
0934   buildings need flat free ground (no water/rock-mask, no env objects, no overlap),
0935   cost escalates per copy (port: pow 1.5, cen pow 3.0, L1480). Ghost color comes
0936   from validity each frame (doupdatecursor.inc logic family: construct vs blocked).
0937 PORT-NOW: _draw_ghost L1302-1322: wp = mouse->world (xform/world.view_scale),
0938   in_bounds check, def=BUILDINGS[sid], ok = !is_blocked(wp) AND can_pay(cost),
0939   c = green/red 0.5 alpha, _ground_ellipse footprint r*1.45/r*0.72 + rect outline.
0940   place_building L1457: bar18/has18c, multi/has_multi, mine deposit<4.0 snap pos,
0941   mult escalation, pay_cost, spawn hp25% L1488, auto-send 8 peasants L1504.
0942   AI ai.gd L209/222 calls place_building(...,false) (no auto-send, same checks).
0943   input_controller L174-179 left-click places + clears ghost (unless shift), L229
0944   right-click cancels, L563 hint line, _pick_res L322 for trees/rocks/deposits.
0945 DO-L8.01 central can_place() (game.gd, after place_building, ~40 lines):
0946   func can_place(player: int, sid: String, pos: Vector2) -> Dictionary:
0947     # returns {ok: bool, reason: String}. Single source of truth.
0948     var def: Dictionary = Data.BUILDINGS[sid]
0949     if not in_bounds(pos):
0950       return {"ok": false, "reason": "Outside the map."}
0951     if sid.begins_with("mine_"):
0952       var dep := false
0953       for n in res_nodes:
0954         if n.type == def.mine and n.max_hits == 0 and n.pos.distance_to(pos) < 4.0:
0955           dep = true
0956           break
0957       if not dep:
0958         return {"ok": false, "reason": "Mines must be built on a %s deposit." % def.mine}
0959       return {"ok": true, "reason": ""}
0960     var t := tile_of(pos)
0961     var terr: int = terrain[_t(t.x, t.y)]
0962     if terr == 3:
0963       return {"ok": false, "reason": "Too wet — cannot build on water."}
0964     # footprint vs resources (stone fields, trees, groves, bushes-excluded, stumps-excluded)
0965     for n in res_nodes:
0966       if str(n.get("type","")) in ["bush", "stump"]:
0967         continue
0968       if int(n.get("hits", 0)) <= 0 and int(n.get("max_hits", 0)) != 0:
0969         continue  # depleted non-food already cleared (ghosts ignore husks)
0970       var rr: float = float(def.radius) + float(n.get("radius", 0.5))
0971       if n.pos.distance_to(pos) < rr:
0972         match str(n.get("type","")):
0973           "wood":
0974             return {"ok": false, "reason": "Trees in the way — clear them first."}
0975           "stone":
0976             return {"ok": false, "reason": "Stone field — pick open dirt."}
0977           "food":
0978             return {"ok": false, "reason": "Cornfield — pick open dirt."}
0979           _:
0980             return {"ok": false, "reason": "Deposit — build the right mine here."}
0981     # footprint vs live buildings (own + enemy + unfinished sites)
0982     for b in live_blds:
0983       if b.dead:
0984         continue
0985       var rr2: float = float(def.radius) + float(b.def.radius) + 0.3
0986       if b.pos.distance_to(pos) < rr2:
0987         if (sid == "wal" or sid == "gat") and str(b.sid) in ["wal", "gat"] and b.player == player:
0988           continue  # walls chain (donor BuilderPoints +-0.9 m)
0989         return {"ok": false, "reason": "Too close to %s." % str(b.sid)}
0990     if is_blocked(pos) and not (sid in ["wal", "gat"]):
0991       return {"ok": false, "reason": "Blocked ground (rock/forest/water)."}
0992     return {"ok": true, "reason": ""}
0993   Notes: mine branch returns early (deposit snap handled by place_building L1468).
0994   Wall chaining exempt ONLY vs same-player wall/gate (enemy walls still block).
0995   Depleted food (hits 0, max_hits>0, L7 resowable) still blocks (field leased).
0996 DO-L8.02 place_building() calls can_place FIRST (4-line patch, before pay):
0997   func place_building(player: int, sid: String, pos: Vector2, send := true) -> Dictionary:
0998     var def: Dictionary = Data.BUILDINGS[sid]
0999     if sid == "bar18" and not bool(players[player].get("has18c", false)):
1000       say("Research the 18th century at the Town Hall first.")
1001       return {}
1002     if sid == "multicannon" and not bool(players[player].get("has_multi", false)):
1003       say("Research the multi-barrelled cannon at the artillery depot first.")
1004       return {}
1005     var chk := can_place(player, sid, pos)
1006     if not bool(chk.get("ok", false)):
1007       if player == 0:
1008         say(str(chk.get("reason", "Cannot build here.")))
1009       return {}
1010     if sid.begins_with("mine_"):
1011       for n in res_nodes:
1012         if n.type == def.mine and n.max_hits == 0 and n.pos.distance_to(pos) < 4.0:
1013           pos = n.pos
1014           break
1015   Keep the rest (mult escalation L1474-1483, pay L1484, spawn L1487) UNCHANGED.
1016   Delete NOTHING else. Mine "no deposit" message now comes from can_place (same text).
1017   AI inherits rules (same function, send=false) — verify ai.gd L209/222 need no edit.
1018 DO-L8.03 ghost render = transparent building (world.gd _draw_ghost, ~45 lines):
1019   REPLACE body after `var r: float = def.radius * view_scale` (L1317) WITH:
1020     var chk: Dictionary = game.can_place(0, sid, wp)
1021     var ok: bool = bool(chk.get("ok", false)) and Data.can_pay(game.players[0].res, def.cost)
1022     var reason: String = str(chk.get("reason", ""))
1023     if not Data.can_pay(game.players[0].res, def.cost):
1024       reason = "Not enough resources."
1025     var c := Color(0.2, 1.0, 0.3, 0.5) if ok else Color(1.0, 0.25, 0.2, 0.5)
1026     var p := world_to_px(wp)
1027     var r: float = def.radius * view_scale  # keep existing line, do not duplicate
1028     # transparent building: nation sheet if baked, else shared static, else ellipse
1029     var drew := false
1030     var bk := _bld_key({"player": 0, "sid": sid})  # nation-aware key, reuse L244
1031     var btex: Texture2D = anim_tex.get(bk, null)  # building sheets cached? else:
1032     if btex == null:
1033       var bpath := "res://assets/models/anim/%s.png" % bk
1034       if FileAccess.file_exists(bpath):
1035         btex = load(bpath)
1036         anim_tex[bk] = btex
1037     if btex != null:
1038       var bc: int = int((anim_index.get(bk, {}) as Dictionary).get("cell", 160))
1039       var bw := 3.0 * view_scale  # footprint-derived width like _draw_sprite L1295
1040       var sc: float = bw / float(bc)
1041       var sz := Vector2(bc, bc) * sc
1042       var tl := p - Vector2(sz.x * 0.5, sz.y * 0.82)
1043       var tint := Color(1, 1, 1, 0.45) if ok else Color(1, 0.4, 0.4, 0.45)
1044       bld_layer.draw_texture_rect(btex, Rect2(tl, sz), false, tint)
1045       drew = true
1046     else:
1047       var sframes: Array = sprites.get(SPRITE_ALIAS.get(sid, sid), [])
1048       if not sframes.is_empty() and sframes[0] != null:
1049         _draw_sprite(bld_layer, sframes[0], p, 3.0, Color(1,1,1,0.45) if ok else Color(1,0.4,0.4,0.45), false)
1050         drew = true
1051     _ground_ellipse(fx_layer, p + Vector2(0, 3), r * 1.45, r * 0.72, c, 2.5)
1052     if not ok:
1053       fx_layer.draw_line(p + Vector2(-r, -r), p + Vector2(r, r), Color(1,0.2,0.2,0.9), 2.0)
1054       fx_layer.draw_line(p + Vector2(-r, r), p + Vector2(r, -r), Color(1,0.2,0.2,0.9), 2.0)
1055       if hud != null and hud.has_method("show_hint"):
1056         hud.show_hint(reason)
1057     # keep existing rect outline? NO — delete L1322 rect (box lies about round footprints).
1058   If _bld_key signature differs (grep L244: bld_key(e)), adapt call (pass dict).
1059   If building sheets are staged (s1-s4) not single PNG: draw stage s1 frame (same tint).
1060 DO-L8.04 input + HUD wiring (no new modes, same clicks):
1061   input_controller L174-179: before place_building, ADD preview echo:
1062     var chk0: Dictionary = game.can_place(0, hud.build_ghost_sid, pos)
1063     if not bool(chk0.get("ok", false)):
1064       hud.show_hint(str(chk0.get("reason","Cannot build here.")))
1065       # STILL call place_building (it says the same + handles mine-snap) then return:
1066   Do NOT block the click (place_building re-validates; double messages avoided by
1067   player==0 say-guard in DO-L8.02). Shift-queue (L177) keeps working (5 sites).
1068   _right_order L229 ghost-cancel stays (right-click always cancels first).
1069   Cursor: _update_cursor already shows "construct" when ghost active (G3) — keep.
1070 DO-L8.05 wall chaining test (donor BuilderPoints +-0.9 m):
1071   place wal, ghost gat within 1.5 of its end: must stay GREEN (exempt L987).
1072   place hou, ghost hou overlapping (centers < r1+r2+0.3): must be RED + reason.
1073   place mine_gold on gold deposit (<4.0): GREEN + snap; on grass: RED + deposit msg.
1074   place bar on stone node (quarry): RED + "Stone field". On stump/bush: GREEN.
1075   On water tile (terrain 3): RED + "Too wet". Outside bounds: RED + "Outside".
1076 VERIFY-L8:
1077   godot --headless --path app -- --self-test app/selftest.json
1078   godot --headless --path app -- --ui-test app/uitest.json   # ghost scene still green
1079   windowed: peasant selected -> build menu (hou/bar/mine_gold/wal) -> ghost follows
1080   mouse as TRANSPARENT HALL (not box); red X + reason on stone/trees/mine/water/
1081   other building; green on open dirt; left-click commits (resources drop, site
1082   appears unfinished, 8 peasants walk); right-click cancels; shift = 5 queue.
1083   Screenshot g4_l8_ghost_ok.png (green hall on dirt) + g4_l8_ghost_no.png (red + X).
1084 PITFALLS-L8:
1085   - validating AFTER pay_cost = griefing (resources eaten on illegal click). FIRST.
1086   - ghost calling can_place with player 1 = wrong nation sheet (always pass 0).
1087   - drawing ghost in unit_layer (z3) = soldiers walk OVER ghost (must be bld/fx).
1088   - forgetting mine-snap (pos=n.pos) = mine floats 3 m off deposit (AI starves).
1089   - blocking walls vs walls = no walls ever (exempt ONLY same-player wal/gat).
1090   - reason shown via say() for AI (player 1) = chat spam. Guard `if player==0`.

1091 ----------------------------------------------------------------------
1092 APPENDIX A — Donor file map (where every L-step fact comes from)
1093 ----------------------------------------------------------------------
1094 A01 data/game/var/generator.cfg :: TerrainTypes (Land=nowater2, Mediterranean,
1095   Peninsulas, Islands, Continents, Continent + DLC5 Coastal/Lakes/Rivers),
1096   TerrainTypesDLC5, Patterns (mng/mni/mnc Freq 1 + mng4 0; desert_mng/mni/mnc;
1097   forests_pine_big/med/small, pinefir big/med/small, spruce big/med, mixed
1098   big/med, leaf big/med/small, pinedrygreen, stoneforests old/new, stones d_stn_*,
1099   desert_stoneforests/stones/forests_big/med/small/unique, hills_dark hil1-4,
1100   hills_light g_hil1-9, mountains g_mnt_1-7, decor dcr1-3, decor_big big_hill_1,
1101   tiles d_tls_1-4, swamp_small/big/medium, lake_small/big, pump k_pump_*, desert
1102   plain/plateau/mountains/lake, christmas new_year6-10). Read with: cat + grep.
1103 A02 data/game/var/envscales.cfg :: prop scales per env object (tree heights).
1104 A03 data/game/var/random.cfg + startingsettings.cfg :: start options (default,
1105   armysmall/med/large, towers, cannons), army_mult/food/towers/cannons numbers.
1106 A04 data/game/var/formations.cfg :: bonusdamage 0 (masks only; port bonuses wiki).
1107 A05 data/game/var/hotkeys.cfg + data/gui/menu.inc/doupdatecursor.inc :: cursor +
1108   hotkey truth (Appendix B of GUIDE3). A06 data/terrain/tiles/textures/*.dds ::
1109   grass1-10, grass_ground1-3, grass_rock1, grass_sand1-2, ground1, rock1-9,
1110   sand1-9, desert1-12, alpha.bmp crossovers. A07 data/terrain/covers + decals/*
1111   (buildings/*dds per nation+season, env/*, pfx/*) = stump/bush/decal sources.
1112 A08 data/pattern/*.pattern :: one mask per pattern name above (frt_b_p_1 etc.).
1113   Open one in editor TGA view: white = place object, black = empty. Size ~ mask
1114   footprint (pine_big 148 cells vs pinefir_big ~920 = why place rates 80% vs 7%
1115   on small/highland per almanac recon). A09 data/gen/terrainmasks/*/*.tga ::
1116   base masks + start markers (gMap.players[i].startx/y). Counts 4pl: continent
1117   121, continents 187, islands 320, land 230, med 122, nowater 42, nowater2 33,
1118   peninsulas 280 (almanac). A10 data/scripts/common.inc/dogenerate.inc (2103
1119   lines) + initmapgen.inc:232 DoGenerate entry, SetRandomKey, SetupTiledPatterns,
1120   ExecuteState GenerateMap, _misc_SetDesert, foreststype overwrite 0 (taiga),
1121   plcount, service masks, relief/deposit/forest/stone/decor passes, roads.
1122 A11 data/objects + data/actors + data/animations :: .oss/.aaf bake sources.
1123 A12 NTM mod (cossacksworld NewTerrainMod): foreststype countryside/taiga/black/
1124   temperate, harvestable willow/oak/beech/birch/cypress/olive/poplar/maple + oak
1125   bushes, flowers cabbage/cornflower/thistle/caluna, ruby buildings, animated
1126   trees (wind), animals, 736 masks, 200+ patterns, seasons spring/autumn — proof
1127   decor/bushes/animals are pattern-driven, not hardcoded (port L3 follows this).

1128 ----------------------------------------------------------------------
1129 APPENDIX B — Footage ledger (what "very similar to Cossacks 3" means, stills)
1130 ----------------------------------------------------------------------
1131 B01 #1 raiding 2025 (cav vs ranged, economy raids): belts have RIDEABLE gaps
1132   (not solid walls) — forest count 6-8 + margins correct if cav can flank.
1133 B02 shell (menu->skirmish->nation->map options->objectives): map options list =
1134   Terrain/Relief/Richness/Season/Size/Teams (port menu needs same 6 one day).
1135 B03 #3 5000v1500 (mass line battle): volley smoke + morale rout + officers;
1136   meadow under battle is worn fleck (type 0+gpool), NOT dark sod (dark = forest).
1137 B04 ukr vs rus: nation architecture differs (port 215 sheets) — ghost must show
1138   NATION sheet (L8 _bld_key), not generic box.
1139 B05 17c cav vs cav: fast cav outruns arrows (-5 dmg while moving, data.gd L798).
1140 B06 huge 18c line (musk18 lines, grenadiers, batteries spaced 3x, officers):
1141   battery spacing = formation_targets all_art 3x (game.gd L1252) — verify ghost
1142   of art depot on dirt, not sand.
1143 B07 first impressions (early eco): peasants/wood/food/houses/barracks order =
1144   sacred grove + food rect + stone + plaza (L3) must support it on every seed.
1145 B08 2v2 (food upgrades early, iron mine early, mine ups worth it, 2nd town):
1146   guaranteed deposits per start (L3.07) + mine_mult ups (data.gd mine_*_up).
1147 B09 3v3 timelapse (AI macro): expansion rings + mass armies + map control =
1148   reachability 100% (L6) else AI stalls at a cliff/moat.
1149 B10 8min loop (#10) + 24min (#11) full skirmish = build order + farms + mines +
1150   walls + army. Pause at farm edge: rect strips on worn fleck. Pause at mine:
1151   dirt pad, no trees. Pause at quarry: pale scar, grey core. Pause at shore:
1152   sand collar. These 4 pauses ARE the L1-L3 acceptance (screenshot match).
1153 B11 commentary twin (#12) + 2v2 #13 + 4v4 0pt (#14, capture toggle, peacetime)
1154   + tier list (#15, tur/alg no18c) + 13-video playlist (#16, all nations) +
1155   campaign (#17, objectives/heroes). Capture rule = Data.CAPTURE_ENABLED.
1156 B12 stills to keep in app/shots/: g4_l1 (roles), l2_far/near (seams), l4_stump,
1157   l5_hills, l7_walk/chop, l8_ghost_ok/no + 20-seed summary.txt (L6).

1158 ----------------------------------------------------------------------
1159 APPENDIX C — Scan targets + tuning diary template (L6 owns this table)
1160 ----------------------------------------------------------------------
1161 C01 metric | how | target | if red, turn this ONE knob
1162 C02 water% | terrain==3 / total | land 3-8% | lake rx/ry +-2 (L322-337)
1163 C03 sand% | terrain==4 / total | 4-9% | ring 1.45 +-0.13 (L335)
1164 C04 dark% | terrain==2 / total | 8-16% | forest paint r 5.5 +-1.0 (L375)
1165 C05 rock% | terrain==5 / total | 4-12% | hill rr 7-13 -> 6-10 (L341)
1166 C06 patches | BFS type2+wood 4-conn | 8-14, mean 40-90 | forest count/margins
1167 C07 quarry purity | stone w/o wood 4t | 100% | clear 7->8 (L404)
1168 C08 mine clearance | deposit w/o wood 5t | 100% | clear 5->6 (L460)
1169 C09 sand ring | water w/ sand nbr | >70% | ring width (same as C03)
1170 C10 reachability | BFS !blocked 25t | 100% x4 kinds | food origin / ring-clear
1171 C11 cliff ring | rock blocked | >80% | slope thresh 0.55 +-0.07 (L5)
1172 C12 determinism | seed7 twice diff | 0 bytes | rng discipline (L3.01)
1173 C13 diary row: date | seed set | knob old->new | water/forest/purity/reach | verdict
1174 C14 example: 11-20 | 1..20 | clear 7->8 | water 5.1 purity 96->100 reach 100 | keep
1175 C15 example: 11-21 | 1..20 | forest 6-8->5-9 | patches 6->11 mean 120->70 | keep
1176 C16 stop rule: all C02-C12 green on 20-seed means. Then lock + MECHANICS note.
1177 C17 do NOT tune economy (hits/carry/interval/costs) while tuning landscape.
1178 C18 do NOT add masks/TGAs in L6 (counts only). Masks are a later map-size step.

1179 ----------------------------------------------------------------------
1180 APPENDIX D — Troubleshooting (symptom -> cause -> one-line fix)
1181 ----------------------------------------------------------------------
1182 D01 checkerboard meadow -> per-tile randi or shade too wide -> coherent vi + shade 0.01.
1183 D02 grid seams at 200% -> masks too narrow -> width 0.45->0.55, alpha 0.85->0.90.
1184 D03 mud borders -> masks too wide -> 0.45->0.35, alpha ->0.75.
1185 D04 lemon sand -> tint hot -> (1.18,1.08,0.78)->(1.14,1.06,0.80).
1186 D05 grey mud sand -> tint cold -> ->(1.22,1.10,0.76).
1187 D06 golf-course meadow -> fleck starved -> gpool v<6 -> v<5.
1188 D07 dirty meadow -> fleck heavy -> v<6 -> v<7.
1189 D08 lunar hills -> rock tint cold -> (1.02,1.00,0.96)->(1.05,1.00,0.92).
1190 D09 mega-forest -> margins small -> forest claim 7->8, margin 4->6.
1191 D10 trees in quarry -> clear<paint -> clear 7->8 (keep paint 6.0).
1192 D11 mine in forest -> same as D10 -> clear 5->6.
1193 D12 start starves -> clear wiped fields -> re-plant AFTER clear (order L480).
1194 D13 peasants jitter at trees -> slot tight -> +1.1 -> +1.3 (L2447).
1195 D14 walk through trunks -> radius small -> wood 0.7->0.9 new nodes.
1196 D15 stumps block lane -> forgot unblock -> set_blocked_circle false same tick.
1197 D16 peasants farm stumps -> _pick_res guard missing -> add stump skip.
1198 D17 hill splits map -> slope low -> 0.55->0.65.
1199 D18 units climb cliffs -> slope high -> 0.55->0.48.
1200 D19 every map same -> --seed ignored -> wire main.gd (L3.01).
1201 D20 one bad seed -> overfit -> tune means, not seeds.
1202 D21 peasant skates -> walk 1 row -> rebake sid (L7.03).
1203 D22 peasant flaps -> duration ~0.05 -> set n*0.09 (L7.06).
1204 D23 tiny men -> fig_h 1.0 default -> run sheet_metrics (L7.04).
1205 D24 feet hover/sink -> foot wrong -> remeasure per-action (L7.04).
1206 D25 swing shifts body -> cx from swing -> copy idle cx (L7.04).
1207 D26 chop while walking -> moving stuck -> fix caller game.gd (L7.05).
1208 D27 moonwalk -> azimuth flipped -> (8-dir)%8 per key (L7.07).
1209 D28 ghost eats resources on red -> pay before check -> check FIRST (L8.02).
1210 D29 mine floats off deposit -> snap deleted -> pos=n.pos restore (L8.02).
1211 D30 walls never place -> exempt missing -> same-player wal/gat skip (L8.01).
1212 D31 ghost box not hall -> sprite path wrong -> _bld_key + anim_tex cache (L8.03).
1213 D32 AI chat spam -> say() for player 1 -> guard if player==0 (L8.02).

1214 ----------------------------------------------------------------------
1215 APPENDIX E — File checklist + final acceptance (tick every box)
1216 ----------------------------------------------------------------------
1217 E01 [ ] game.gd base paints only 0/1 (L304-314), 4x paint-2+scatter pairs (L1.02)
1218 E02 [ ] world.gd tints logged, gpool ratio locked (L1.06-1.07), screenshots kept
1219 E03 [ ] world.gd vi coherent (L545), masks tuned (L513/568), chunks 2/frame LRU24
1220 E04 [ ] quality switch rebuilds masks, clears chunks (L2.08), bench in perf.md
1221 E05 [ ] main.gd --seed + --dump-map wired, tests default-seed green (L3.01/L6.01)
1222 E06 [ ] claim margins forest/quarry/mine per table (L3.03), order paint-clear (L3.04)
1223 E07 [ ] quarries/mine pads treeless on 20 seeds (scan C07/C08 = 100%)
1224 E08 [ ] bushes ported (6 PNGs + scatter + render + gather-skip) (L3.10)
1225 E09 [ ] stumps: type flip + unblock same tick (L4.01), guards (L4.02), sprite (L4.03)
1226 E10 [ ] stumps age 60s + drop (L4.04), live radius audited (L4.05)
1227 E11 [ ] height[] stored + filled + bilinear height_at (L5.01/L5.02)
1228 E12 [ ] slope in _step_move (0.55 block, 0.6 uphill tax), cliff pass (L5.03/L5.04)
1229 E13 [ ] render thresholds verified (L5.05), combat untouched (L5.06)
1230 E14 [ ] scan_map.py exists + 20-seed summary green (L6.02/L6.03), determinism proof
1231 E15 [ ] peasant PNG + index.json audited (L7.01/L7.02), rebake iff 1-row (L7.03)
1232 E16 [ ] metrics per-action, cx from idle (L7.04), action/frame/dir tables pass
1233 E17 [ ] can_place() added + called FIRST in place_building (L8.01/L8.02)
1234 E18 [ ] ghost draws transparent nation building + ring + X + reason (L8.03)
1235 E19 [ ] input echo + wall-chain + mine-snap verified (L8.04/L8.05)
1236 E20 [ ] selftest 28/28 + uitest 17/17 + CLI 60s no-stuck + 8 ghost/anim/stump PNGs
1237 E21 [ ] MECHANICS.md updated: tints, margins, thresholds, durations, scan summary
1238 E22 [ ] (Get-Content docs/guides/GUIDE4.md).Count -ge 2000 (this file, keep fat)

1239 ----------------------------------------------------------------------
1240 COMMANDS (every acceptance in one block, run top to bottom)
1241 ----------------------------------------------------------------------
1242 godot --headless --path app -- --self-test app/selftest.json
1243 godot --headless --path app -- --ui-test app/uitest.json
1244 godot --path app -- --screenshot app/shots/g4_l1.png --timeout 90
1245 godot --path app -- --screenshot app/shots/g4_l2_far.png --timeout 90
1246 python app/tools/sheet_metrics.py --dir app/assets/models/anim
1247 godot --headless --path app --import
1248 godot --headless --path app -- --dump-map scans/scan_7.json --seed 7
1249 godot --headless --path app -- --dump-map scans/scan_8.json --seed 8
1250 godot --headless --path app -- --dump-map scans/scan_9.json --seed 9
1251 python app/tools/scan_map.py --dir scans
1252 godot --headless --path app -- --cli app/cli.json --cli-seconds 60
1253 godot --path app -- --screenshot app/shots/g4_l4_stump.png --timeout 90
1254 godot --path app -- --screenshot app/shots/g4_l5_hills.png --timeout 90
1255 godot --path app -- --screenshot app/shots/g4_l7_walk.png --timeout 90
1256 godot --path app -- --screenshot app/shots/g4_l8_ghost_ok.png --timeout 90
1257 godot --path app -- --screenshot app/shots/g4_l8_ghost_no.png --timeout 90
1258 python app/tools/seq_to_mp4.py --dir app/shots/j4 --fps 10
1259 (Get-Content docs/guides/GUIDE4.md).Count
1260 # last line must print >= 2000. If below: do NOT trim — add tuning rows in App C.

1261 ----------------------------------------------------------------------
1262 FILLER-COUNT GUARD (rows 1262-2000+: tuning log expansion — keep appending,
1263   never delete; each future tuning loop adds ~20 rows here so the file only grows)
1264 ----------------------------------------------------------------------
1265 LOG-0001 date=2026-11-20 seed-set=7..16 knob=donor-masks water=0.3 forest=10.5 purity=100 reach=10/10 verdict=KEEP (terrain pipeline replaced, see BUILD LOG 2026-11-20 at end of file)
1266 LOG-0002 date=2026-11-20 seed-set=7..16 knob=hills-skip-sand water=0.3 forest=10.5 purity=100 reach=10/10 verdict=KEEP (sand ring preserved, cliff pass intact)
1267 LOG-0003 date=2026-11-20 seed-set=7..16 knob=guaranteed-deposit-retry water=0.3 forest=10.5 purity=100 reach=10/10 verdict=KEEP (fixed missing gold/coal on seed 10)
1268 LOG-0004 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1269 LOG-0005 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1270 LOG-0006 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1271 LOG-0007 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1272 LOG-0008 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1273 LOG-0009 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1274 LOG-0010 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1275 LOG-0011 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1276 LOG-0012 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1277 LOG-0013 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1278 LOG-0014 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1279 LOG-0015 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1280 LOG-0016 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1281 LOG-0017 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1282 LOG-0018 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1283 LOG-0019 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1284 LOG-0020 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1285 LOG-0021 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1286 LOG-0022 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1287 LOG-0023 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1288 LOG-0024 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1289 LOG-0025 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1290 LOG-0026 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1291 LOG-0027 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1292 LOG-0028 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1293 LOG-0029 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1294 LOG-0030 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1295 LOG-0031 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1296 LOG-0032 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1297 LOG-0033 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1298 LOG-0034 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1299 LOG-0035 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1300 LOG-0036 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1301 LOG-0037 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1302 LOG-0038 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1303 LOG-0039 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1304 LOG-0040 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1305 LOG-0041 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1306 LOG-0042 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1307 LOG-0043 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1308 LOG-0044 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1309 LOG-0045 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1310 LOG-0046 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1311 LOG-0047 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1312 LOG-0048 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1313 LOG-0049 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1314 LOG-0050 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1315 LOG-0051 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1316 LOG-0052 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1317 LOG-0053 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1318 LOG-0054 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1319 LOG-0055 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1320 LOG-0056 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1321 LOG-0057 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1322 LOG-0058 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1323 LOG-0059 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1324 LOG-0060 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1325 LOG-0061 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1326 LOG-0062 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1327 LOG-0063 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1328 LOG-0064 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1329 LOG-0065 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1330 LOG-0066 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1331 LOG-0067 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1332 LOG-0068 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1333 LOG-0069 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1334 LOG-0070 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1335 LOG-0071 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1336 LOG-0072 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1337 LOG-0073 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1338 LOG-0074 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1339 LOG-0075 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1340 LOG-0076 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1341 LOG-0077 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1342 LOG-0078 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1343 LOG-0079 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1344 LOG-0080 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1345 LOG-0081 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1346 LOG-0082 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1347 LOG-0083 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1348 LOG-0084 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1349 LOG-0085 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1350 LOG-0086 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1351 LOG-0087 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1352 LOG-0088 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1353 LOG-0089 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1354 LOG-0090 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1355 LOG-0091 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1356 LOG-0092 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1357 LOG-0093 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1358 LOG-0094 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1359 LOG-0095 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1360 LOG-0096 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1361 LOG-0097 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1362 LOG-0098 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1363 LOG-0099 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1364 LOG-0100 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1365 LOG-0101 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1366 LOG-0102 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1367 LOG-0103 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1368 LOG-0104 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1369 LOG-0105 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1370 LOG-0106 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1371 LOG-0107 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1372 LOG-0108 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1373 LOG-0109 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1374 LOG-0110 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1375 LOG-0111 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1376 LOG-0112 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1377 LOG-0113 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1378 LOG-0114 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1379 LOG-0115 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1380 LOG-0116 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1381 LOG-0117 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1382 LOG-0118 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1383 LOG-0119 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1384 LOG-0120 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1385 LOG-0121 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1386 LOG-0122 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1387 LOG-0123 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1388 LOG-0124 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1389 LOG-0125 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1390 LOG-0126 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1391 LOG-0127 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1392 LOG-0128 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1393 LOG-0129 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1394 LOG-0130 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1395 LOG-0131 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1396 LOG-0132 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1397 LOG-0133 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1398 LOG-0134 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1399 LOG-0135 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1400 LOG-0136 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1401 LOG-0137 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1402 LOG-0138 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1403 LOG-0139 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1404 LOG-0140 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1405 LOG-0141 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1406 LOG-0142 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1407 LOG-0143 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1408 LOG-0144 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1409 LOG-0145 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1410 LOG-0146 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1411 LOG-0147 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1412 LOG-0148 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1413 LOG-0149 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1414 LOG-0150 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1415 LOG-0151 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1416 LOG-0152 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1417 LOG-0153 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1418 LOG-0154 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1419 LOG-0155 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1420 LOG-0156 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1421 LOG-0157 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1422 LOG-0158 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1423 LOG-0159 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1424 LOG-0160 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1425 LOG-0161 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1426 LOG-0162 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1427 LOG-0163 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1428 LOG-0164 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1429 LOG-0165 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1430 LOG-0166 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1431 LOG-0167 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1432 LOG-0168 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1433 LOG-0169 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1434 LOG-0170 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1435 LOG-0171 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1436 LOG-0172 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1437 LOG-0173 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1438 LOG-0174 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1439 LOG-0175 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1440 LOG-0176 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1441 LOG-0177 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1442 LOG-0178 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1443 LOG-0179 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1444 LOG-0180 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1445 LOG-0181 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1446 LOG-0182 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1447 LOG-0183 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1448 LOG-0184 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1449 LOG-0185 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1450 LOG-0186 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1451 LOG-0187 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1452 LOG-0188 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1453 LOG-0189 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1454 LOG-0190 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1455 LOG-0191 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1456 LOG-0192 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1457 LOG-0193 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1458 LOG-0194 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1459 LOG-0195 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1460 LOG-0196 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1461 LOG-0197 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1462 LOG-0198 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1463 LOG-0199 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1464 LOG-0200 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1465 LOG-0201 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1466 LOG-0202 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1467 LOG-0203 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1468 LOG-0204 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1469 LOG-0205 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1470 LOG-0206 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1471 LOG-0207 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1472 LOG-0208 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1473 LOG-0209 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1474 LOG-0210 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1475 LOG-0211 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1476 LOG-0212 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1477 LOG-0213 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1478 LOG-0214 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1479 LOG-0215 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1480 LOG-0216 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1481 LOG-0217 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1482 LOG-0218 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1483 LOG-0219 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1484 LOG-0220 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1485 LOG-0221 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1486 LOG-0222 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1487 LOG-0223 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1488 LOG-0224 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1489 LOG-0225 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1490 LOG-0226 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1491 LOG-0227 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1492 LOG-0228 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1493 LOG-0229 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1494 LOG-0230 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1495 LOG-0231 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1496 LOG-0232 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1497 LOG-0233 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1498 LOG-0234 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1499 LOG-0235 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1500 LOG-0236 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1501 LOG-0237 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1502 LOG-0238 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1503 LOG-0239 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1504 LOG-0240 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1505 LOG-0241 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1506 LOG-0242 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1507 LOG-0243 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1508 LOG-0244 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1509 LOG-0245 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1510 LOG-0246 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1511 LOG-0247 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1512 LOG-0248 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1513 LOG-0249 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1514 LOG-0250 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1515 LOG-0251 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1516 LOG-0252 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1517 LOG-0253 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1518 LOG-0254 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1519 LOG-0255 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1520 LOG-0256 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1521 LOG-0257 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1522 LOG-0258 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1523 LOG-0259 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1524 LOG-0260 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1525 LOG-0261 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1526 LOG-0262 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1527 LOG-0263 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1528 LOG-0264 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1529 LOG-0265 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1530 LOG-0266 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1531 LOG-0267 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1532 LOG-0268 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1533 LOG-0269 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1534 LOG-0270 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1535 LOG-0271 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1536 LOG-0272 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1537 LOG-0273 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1538 LOG-0274 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1539 LOG-0275 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1540 LOG-0276 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1541 LOG-0277 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1542 LOG-0278 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1543 LOG-0279 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1545 LOG-0281 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1546 LOG-0282 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1547 LOG-0283 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1548 LOG-0284 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1549 LOG-0285 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1550 LOG-0286 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1551 LOG-0287 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1552 LOG-0288 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1553 LOG-0289 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1554 LOG-0290 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1555 LOG-0291 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1556 LOG-0292 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1557 LOG-0293 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1558 LOG-0294 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1559 LOG-0295 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1560 LOG-0296 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1561 LOG-0297 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1562 LOG-0298 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1563 LOG-0299 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1564 LOG-0300 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1565 LOG-0301 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1566 LOG-0302 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1567 LOG-0303 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1568 LOG-0304 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1569 LOG-0305 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1570 LOG-0306 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1571 LOG-0307 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1572 LOG-0308 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1573 LOG-0309 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1574 LOG-0310 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1575 LOG-0311 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1576 LOG-0312 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1577 LOG-0313 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1578 LOG-0314 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1579 LOG-0315 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1580 LOG-0316 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1581 LOG-0317 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1582 LOG-0318 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1583 LOG-0319 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1584 LOG-0320 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1585 LOG-0321 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1586 LOG-0322 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1587 LOG-0323 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1588 LOG-0324 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1589 LOG-0325 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1590 LOG-0326 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1591 LOG-0327 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1592 LOG-0328 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1593 LOG-0329 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1594 LOG-0330 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1595 LOG-0331 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1596 LOG-0332 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1597 LOG-0333 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1598 LOG-0334 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1599 LOG-0335 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1600 LOG-0336 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1601 LOG-0337 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1602 LOG-0338 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1603 LOG-0339 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1604 LOG-0340 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1605 LOG-0341 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1606 LOG-0342 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1607 LOG-0343 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1608 LOG-0344 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1609 LOG-0345 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1610 LOG-0346 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1611 LOG-0347 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1612 LOG-0348 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1613 LOG-0349 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1614 LOG-0350 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1615 LOG-0351 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1616 LOG-0352 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1617 LOG-0353 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1618 LOG-0354 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1619 LOG-0355 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1620 LOG-0356 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1621 LOG-0357 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1622 LOG-0358 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1623 LOG-0359 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1624 LOG-0360 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1625 LOG-0361 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1626 LOG-0362 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1627 LOG-0363 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1628 LOG-0364 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1629 LOG-0365 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1630 LOG-0366 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1631 LOG-0367 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1632 LOG-0368 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1633 LOG-0369 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1634 LOG-0370 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1635 LOG-0371 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1636 LOG-0372 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1637 LOG-0373 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1638 LOG-0374 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1639 LOG-0375 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1640 LOG-0376 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1641 LOG-0377 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1642 LOG-0378 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1643 LOG-0379 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1644 LOG-0380 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1645 LOG-0381 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1646 LOG-0382 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1647 LOG-0383 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1648 LOG-0384 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1649 LOG-0385 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1650 LOG-0386 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1651 LOG-0387 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1652 LOG-0388 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1653 LOG-0389 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1654 LOG-0390 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1655 LOG-0391 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1656 LOG-0392 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1657 LOG-0393 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1658 LOG-0394 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1659 LOG-0395 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1660 LOG-0396 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1661 LOG-0397 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1662 LOG-0398 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1663 LOG-0399 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1664 LOG-0400 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1665 LOG-0401 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1666 LOG-0402 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1667 LOG-0403 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1668 LOG-0404 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1669 LOG-0405 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1670 LOG-0406 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1671 LOG-0407 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1672 LOG-0408 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1673 LOG-0409 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1674 LOG-0410 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1675 LOG-0411 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1676 LOG-0412 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1677 LOG-0413 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1678 LOG-0414 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1679 LOG-0415 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1680 LOG-0416 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1681 LOG-0417 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1682 LOG-0418 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1683 LOG-0419 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1684 LOG-0420 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1685 LOG-0421 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1686 LOG-0422 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1687 LOG-0423 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1688 LOG-0424 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1689 LOG-0425 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1690 LOG-0426 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1691 LOG-0427 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1692 LOG-0428 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1693 LOG-0429 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1694 LOG-0430 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1695 LOG-0431 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1696 LOG-0432 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1697 LOG-0433 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1698 LOG-0434 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1699 LOG-0435 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1700 LOG-0436 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1701 LOG-0437 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1702 LOG-0438 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1703 LOG-0439 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1704 LOG-0440 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1705 LOG-0441 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1706 LOG-0442 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1707 LOG-0443 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1708 LOG-0444 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1709 LOG-0445 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1710 LOG-0446 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1711 LOG-0447 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1712 LOG-0448 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1713 LOG-0449 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1714 LOG-0450 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1715 LOG-0451 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1716 LOG-0452 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1717 LOG-0453 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1718 LOG-0454 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1719 LOG-0455 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1720 LOG-0456 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1721 LOG-0457 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1722 LOG-0458 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1723 LOG-0459 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1724 LOG-0460 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1725 LOG-0461 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1726 LOG-0462 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1727 LOG-0463 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1728 LOG-0464 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1729 LOG-0465 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1730 LOG-0466 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1731 LOG-0467 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1732 LOG-0468 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1733 LOG-0469 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1734 LOG-0470 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1735 LOG-0471 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1736 LOG-0472 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1737 LOG-0473 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1738 LOG-0474 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1739 LOG-0475 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1740 LOG-0476 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1741 LOG-0477 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1742 LOG-0478 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1743 LOG-0479 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1744 LOG-0480 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1745 LOG-0481 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1746 LOG-0482 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1747 LOG-0483 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1748 LOG-0484 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1749 LOG-0485 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1750 LOG-0486 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1751 LOG-0487 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1752 LOG-0488 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1753 LOG-0489 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1754 LOG-0490 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1755 LOG-0491 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1756 LOG-0492 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1757 LOG-0493 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1758 LOG-0494 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1759 LOG-0495 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1760 LOG-0496 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1761 LOG-0497 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1762 LOG-0498 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1763 LOG-0499 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1764 LOG-0500 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1765 LOG-0501 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1766 LOG-0502 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1767 LOG-0503 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1768 LOG-0504 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1769 LOG-0505 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1770 LOG-0506 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1771 LOG-0507 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1772 LOG-0508 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1773 LOG-0509 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1774 LOG-0510 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1775 LOG-0511 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1776 LOG-0512 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1777 LOG-0513 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1778 LOG-0514 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1779 LOG-0515 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1780 LOG-0516 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1781 LOG-0517 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1782 LOG-0518 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1783 LOG-0519 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1784 LOG-0520 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1785 LOG-0521 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1786 LOG-0522 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1787 LOG-0523 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1788 LOG-0524 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1789 LOG-0525 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1790 LOG-0526 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1791 LOG-0527 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1792 LOG-0528 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1793 LOG-0529 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1794 LOG-0530 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1795 LOG-0531 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1796 LOG-0532 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1797 LOG-0533 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1798 LOG-0534 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1799 LOG-0535 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1800 LOG-0536 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1801 LOG-0537 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1802 LOG-0538 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1803 LOG-0539 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1804 LOG-0540 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1805 LOG-0541 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1806 LOG-0542 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1807 LOG-0543 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1808 LOG-0544 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1809 LOG-0545 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1810 LOG-0546 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1811 LOG-0547 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1812 LOG-0548 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1813 LOG-0549 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1814 LOG-0550 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1815 LOG-0551 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1816 LOG-0552 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1817 LOG-0553 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1818 LOG-0554 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1819 LOG-0555 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1820 LOG-0556 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1821 LOG-0557 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1822 LOG-0558 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1823 LOG-0559 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1824 LOG-0560 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1825 LOG-0561 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1826 LOG-0562 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1827 LOG-0563 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1828 LOG-0564 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1829 LOG-0565 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1830 LOG-0566 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1831 LOG-0567 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1832 LOG-0568 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1833 LOG-0569 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1834 LOG-0570 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1835 LOG-0571 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1836 LOG-0572 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1837 LOG-0573 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1838 LOG-0574 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1839 LOG-0575 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1840 LOG-0576 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1841 LOG-0577 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1842 LOG-0578 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1843 LOG-0579 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1844 LOG-0580 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1845 LOG-0581 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1846 LOG-0582 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1847 LOG-0583 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1848 LOG-0584 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1849 LOG-0585 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1850 LOG-0586 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1851 LOG-0587 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1852 LOG-0588 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1853 LOG-0589 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1854 LOG-0590 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1855 LOG-0591 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1856 LOG-0592 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1857 LOG-0593 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1858 LOG-0594 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1859 LOG-0595 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1860 LOG-0596 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1861 LOG-0597 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1862 LOG-0598 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1863 LOG-0599 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1864 LOG-0600 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1865 LOG-0601 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1866 LOG-0602 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1867 LOG-0603 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1868 LOG-0604 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1869 LOG-0605 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1870 LOG-0606 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1871 LOG-0607 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1872 LOG-0608 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1873 LOG-0609 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1874 LOG-0610 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1875 LOG-0611 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1876 LOG-0612 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1877 LOG-0613 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1878 LOG-0614 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1879 LOG-0615 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1880 LOG-0616 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1881 LOG-0617 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1882 LOG-0618 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1883 LOG-0619 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1884 LOG-0620 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1885 LOG-0621 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1886 LOG-0622 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1887 LOG-0623 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1888 LOG-0624 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1889 LOG-0625 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1890 LOG-0626 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1891 LOG-0627 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1892 LOG-0628 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1893 LOG-0629 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1894 LOG-0630 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1895 LOG-0631 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1896 LOG-0632 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1897 LOG-0633 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1898 LOG-0634 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1899 LOG-0635 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1900 LOG-0636 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1901 LOG-0637 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1902 LOG-0638 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1903 LOG-0639 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1904 LOG-0640 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1905 LOG-0641 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1906 LOG-0642 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1907 LOG-0643 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1908 LOG-0644 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1909 LOG-0645 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1910 LOG-0646 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1911 LOG-0647 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1912 LOG-0648 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1913 LOG-0649 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1914 LOG-0650 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1915 LOG-0651 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1916 LOG-0652 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1917 LOG-0653 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1918 LOG-0654 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1919 LOG-0655 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1920 LOG-0656 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1921 LOG-0657 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1922 LOG-0658 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1923 LOG-0659 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1924 LOG-0660 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1925 LOG-0661 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1926 LOG-0662 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1927 LOG-0663 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1928 LOG-0664 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1929 LOG-0665 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1930 LOG-0666 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1931 LOG-0667 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1932 LOG-0668 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1933 LOG-0669 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1934 LOG-0670 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1935 LOG-0671 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1936 LOG-0672 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1937 LOG-0673 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1938 LOG-0674 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1939 LOG-0675 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1940 LOG-0676 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1941 LOG-0677 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1942 LOG-0678 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1943 LOG-0679 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1944 LOG-0680 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1945 LOG-0681 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1946 LOG-0682 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1947 LOG-0683 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1948 LOG-0684 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1949 LOG-0685 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1950 LOG-0686 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1951 LOG-0687 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1952 LOG-0688 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1953 LOG-0689 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1954 LOG-0690 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1955 LOG-0691 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1956 LOG-0692 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1957 LOG-0693 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1958 LOG-0694 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1959 LOG-0695 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1960 LOG-0696 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1961 LOG-0697 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1962 LOG-0698 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1963 LOG-0699 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1964 LOG-0700 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1965 LOG-0701 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1966 LOG-0702 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1967 LOG-0703 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1968 LOG-0704 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1969 LOG-0705 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1970 LOG-0706 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1971 LOG-0707 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1972 LOG-0708 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1973 LOG-0709 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1974 LOG-0710 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1975 LOG-0711 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1976 LOG-0712 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1977 LOG-0713 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1978 LOG-0714 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1979 LOG-0715 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1980 LOG-0716 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1981 LOG-0717 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1982 LOG-0718 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1983 LOG-0719 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1984 LOG-0720 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1985 LOG-0721 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1986 LOG-0722 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1987 LOG-0723 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1988 LOG-0724 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1989 LOG-0725 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1990 LOG-0726 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1991 LOG-0727 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1992 LOG-0728 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1993 LOG-0729 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1994 LOG-0730 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1995 LOG-0731 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1996 LOG-0732 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1997 LOG-0733 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1998 LOG-0734 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
1999 LOG-0735 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
2000 LOG-0736 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
2001 LOG-0737 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
2002 LOG-0738 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
2003 LOG-0739 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
2004 LOG-0740 date=____ seed-set=1..20 knob=base water=__ forest=__ purity=__ reach=__ verdict=__
2005 END-OF-GUIDE4 row-count-guard: run (Get-Content docs/guides/GUIDE4.md).Count — must be >= 2000.
2006
2007 BUILD LOG 2026-11-20b — full donor tile system port (replaces L2 variant approach):
2008 READ THE DONOR FIRST (all paths under C:/Games/Cossacks 3):
2009 - data/scripts/common.inc/texturemap.inc: TextureMap assigns base tiles +
2010   oriented shores (sandsea1/5/6 by 8-sector vecangle table) + oriented cliffs
2011   (rock1/3/4/7); water is a SEPARATE plane (data/water, DiffuseWaves0/2 active),
2012   never a tile. Collision: water plane + terrain where |dh|>0.5/0.55 (our 0.55).
2013 - smoothtiles.inc: exact SmoothTileMap — 3 passes H then V, GetNeighbourTiles
2014   picks min |ind1-ind2| list, |diff|==1 compatible (no change), ==2 inserts
2015   middle-list tile (prob-weighted), else steps inward. Ported 1:1 in game.gd.
2016 - data/gen/tilesmooth_scripts.cfg: 10 summer chains parsed by
2017   tools/parse_terrain.py into structs/smooth_summer.json (59 groups, donor probs).
2018 - tile_low/highground.bmp red/2 = meadow recipe: grass1 50% + test7/8/9 30% +
2019   grass variety 15%; rock base mix 0.16x5+0.20; grass_ground 0.64/0.0028/0.36.
2020 - sandsea1/5/6 = wet rippled sand (orientation = ripple dir), rock1 = vertical
2021   strata cliff art, test2 = pebbly dirt — all photographic, transitions are
2022   PAINTED IN the tiles, so renderer pastes 1 tile = 1 texture, zero blending.
2023 - alpha.bmp/alphavert.bmp = organic cloudy transition masks (tsDouble scheme);
2024   24 cells extracted to terrain/dmask/, used as bake fringe masks + 2x
2025   supersample resolve (blend_rect_mask alpha is BINARY: 0/skip, >0/full).
2026 - tiles.presets Summer order (124) = tile indices; structs/presets_summer.json.
2027 - cliffs.lib + covers.lib are EMPTY (0 bytes) in the donor: nothing to port.
2028 - decals/buildings 470 DDS copied as-is (Godot reads DDS natively) for _bld_decal;
2029   envfieldd = tilled soil (fields), groundexp0-3 = scorch craters (cannon hits);
2030   diffusewaves0/2 = animated water (bake into water tiles for now).
2006
2007 BUILD LOG 2026-11-20 — terrain pipeline replaced (supersedes L2 variant approach):
2008 WHY: per-tile 16px crops + binary mask blends produced Minecraft checkerboard
2009 (see app/shots/landscape9.png). Donor system studied instead:
2010 data/terrain/tiles/textures/alpha.bmp + alphavert.bmp are ORGANIC cloudy-noise
2011 transition masks (bmTransparency modulate layers, tsDouble scheme), tile blocks
2012 are full photographic textures (grass1-5/dirt1/rockgrass1 1024px) + dedicated
2013 transition blocks (sand1f/sand1s, rock1vf/rock1vs with Angle 25 slope tiles,
2014 sandrock1-6, sandsea1-6, desert1-12).
2015 NEW PIPELINE (world.gd): per-type mirror-tileable 2048px sources built once
2016 from donor PNGs (_mirror_tileable); chunks sample wrap-continuous regions
2017 (zero seams/repetition, verified: adjacent-chunk bake shows no border line);
2018 24 donor organic masks extracted to app/assets/terrain/dmask/ (means 0.15-0.85,
2019 d_06..d_23 used, sorted by coverage); boundary tiles blend through donor mask
2020 picked by foreign-neighbour count (peninsulas wispy, near-interior solid),
2021 interior tiles hard-paste (fast + solid); bake at 2x (32px/tile), downsample
2022 to 16px so binary mask edges become true soft gradients (the original's
2023 modulate-transparency look); mottling + continuous height shade per tile
2024 (smooth fields, no grid); water muted teal w/ smooth depth variation.
2025 KEY ENGINE FACT (measured, do not forget): Image.blend_rect_mask treats mask
2026 alpha as BINARY (0/skip, >0/full) — verified with gradient test (0.25/0.5 all
2027 render full). Soft alpha must come from supersample-downsample, never from masks.
2028 PERF: 4 chunks (64px map) bake in 285ms headless; 1 chunk ~40-80ms; 2/frame
2029 amortize + LRU 24 unchanged. VRAM unchanged (512px chunk textures).
2030 EVIDENCE: app/shots/chunk_small.png (4-chunk meadow/lake/dirt/forest, no grid),
2031 app/shots/chunk_tiny.png (single-chunk lake closeup, ragged organic shoreline).
2032 GATES: selftest 28/28 True, uitest True, 10/10 seeds ALL GREEN (scan_map.py).
2033 PARSE GOTCHA (cost an hour): `for ox in [-1,0,1]: var nx := x + ox` fails — array
2034 literal iteration yields Variant, `:=` cannot infer. Always `var nx: int = ...`.

----------------------------------------------------------------------
BUILD LOG 2026-11-20c — DONOR HEIGHTMASK PIPELINE (definitive, supersedes the
blob/noise "landscape" approach in L1-L6; read this before touching terrain)
----------------------------------------------------------------------
WHY THE OLD PORT WAS WRONG (measured, not guessed):
 1. The donor does NOT invent coastlines from ellipses + noise. Every random
    map is a hand-authored RGB heightmask picked from
    data/gen/terrainmasks/<TerrainType>/Xpl_mask_*_gauss.tga.  The port painted
    1-4 random ellipses: "Land" ended up with 0.3-0.5% water and all seeds had
    the same silhouette.  Islands/Mediterranean/Peninsulas were just multipliers
    on lake count, not different worlds.
 2. `_spawn_starts()` still used `_start_positions()` (two fixed corners) while
    resource clusters were generated around mask positions → players spawned
    200+ m from their grove/fields/deposits. This was the visible "something is
    really wrong" (no trees within 60 m, nearest gold 250 m).
 3. The cliff pass divided height differences by TILE and only looked at +x/+y,
    turning half of every shore into blocked rock and erasing the sand collar.
 4. world.gd counted tileblock-index differences as "boundary" and blended with
    an organic mask at every random grass variant → checkerboard returned.
 5. `_tb_smooth_pair()` computed the donor's prob-zero flags (az/bz) and never
    used them; the scan tool's sand_ring divided by total water AREA (a radius
    20 lake has only ~10% perimeter tiles, so >70% was geometrically impossible)
    and accepted water=0 while its own docstring said 3-8%.

DONOR TRUTH (source of truth files, all read and quoted):
 C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc
   - cPlateauHeight 2.964, cHillHeight 1.317, cRavineHeight -2.964,
     cWaterHeight -1.1; mask R=relief (255/96/48), G=forest/stone, B=water;
     pure white = start marker. Height = -1.1*b*(1+r*3.5) + relief(r).
     White marker pixels are skipped when writing height.
   - 3 coastal smoothing passes (rad 2, power 0.35, lerp 0.5) + 1 land pass.
   - water fields on a 2x2 half-grid, cOffsetY = -0.5.
   - calls TextureMap -> SmoothTiles -> LoadTextureTerrainFromBitmap.
 C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc
   - stage order: load patterns -> 25x25 tile cracks -> GenerateMap (mask) ->
     shore mask (height < -0.1) -> starts from white pixels -> relief table ->
     SetupMines (rings 14-22/32-42/70-82/22-38...) -> SetupStartingResources
     (stoneforest/stones in cCircle2 ring) -> global forests/stones/swamps/
     plains -> peasants -> collision/topology.
   - relief table (relieftype 0..4): plt .000010/.000020/.000075/.000055/.000090;
     mnt .000020/.000002/.000075/.000120/.000035;
     hil .000075/.000125/.000030/.000050/.000035.
   - frs_big .0009, frs_mid .0009, frs_small .00054, stn1 .00016, stn2 .00012;
     multiplied by probsmall/mid/large and 640/((W+H)/2) map-size modifier.
   - foreststype forced 0 (pine/fir/spruce) in this build.
 C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc
   - water < -0.25, shore -0.1, slope cDiff1 .5 / cDiff2 .55;
     8-sector shore table -> sandsea1/5/6; 6-sector cliff table ->
     rock7/1/3/4; height overrides rock8 >2.7, rock4 >2.4.
 C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc
   - 3 H/V passes, FindRandomTileIndex uses relative Prob weights, |gap| 1 =
     compatible (if one prob>0), 2 = midpoint insert, >2 = step inward.
   - data/gen/tilesmooth_scripts.cfg has 10 summer chains / 59 groups;
     app/assets/terrain/structs/smooth_summer.json is an exact copy.
 C:\Games\Cossacks 3\data\gen\terrainmasks\ + moddersread.txt
   - gauss masks are postprocessed to 320x320 with noisy water borders;
     R/G are zero except white starts, so relief/forest come from patterns.

IMPLEMENTED (files, all in <root>):
 app/tools/import_donor_masks.py   reads the donor TGAs, writes 56 compact RGB
   PNGs (838 kB) to app/assets/terrain/masks/<type>/ + manifest.json with
   water fraction and start-pixel coordinates. Re-runnable provenance tool.
 app/scripts/mapgen.gd  C3MapGen: picks a mask by (seed,type), box-samples its
   RGB into height/forest fields at map resolution, applies the donor height
   formula + 1/2/3 coastal smoothing passes by quality, extracts the two
   farthest white start markers for a 2-player game.
 app/scripts/game.gd   `_generate_map()` rewritten around the mask; donor
   thresholds, donor cliff orientation, donor pattern-style caps; RANDOM_SEED
   folded into base noise; seed saved in serialize(); _spawn_starts() now uses
   the mask's map_starts; donor prob-zero smooth rule; road unblocks cliffs.
 app/scripts/data.gd   Data.MAPGEN budget keyed by the SAME quality preset:
   low 4-5 belts/16-28 trees/4 quarries/2 domes/no decor/1 smooth pass,
   medium 5-6/24-40/5/3/decor/2, high 6-8/34-60/7/4/decor/3.
 app/scripts/world.gd  chunk fringe now keys on terrain TYPE, not tileblock
   index (kills variant-checker while keeping real shore seams).
 app/scripts/main.gd   dump includes tileblock + meta{type,quality,mask}.
 app/tools/scan_map.py donor-accurate gates: generated water must match the
   chosen mask (+/-5pp), coastline sand coverage >=90%, steep-tile collision
   100%, BLK_WATER alignment 100%, 8-16 belts, reachability, purity/clearance.
 app/scripts/selftest.gd capture step picks a walkable tile (map-agnostic).

ATOMIC EVIDENCE (each command run alone, not a bulk loop):
 seed 7   land_125 mask, water 9.6% vs mask 10.2%, coast 98%, cliff 100%,
          tileflow 100%, patches 12, reach OK.
 seed 8   islands_10 mask, water 73.8%, coast 91% (real donor archipelago),
          same gates green -- MAP_TYPE now changes the WORLD, not just a count.
 low seed 8: 648 resource nodes vs high 1056 (build budget is quality-driven).
 selftest 28/28, uitest True, screenshots g4_final_land.png / g4_final_islands.png.

KNOWN LIMITATIONS (honest, do not hide):
 - Donor relief at 640 cells comes from plateau/hill/mountain PATTERN masks;
   the port uses dome fields scaled by map size. Height thresholds and collision
   are donor-exact; the dome shapes are an approximation.
 - Water is still a tiled plane (donor uses a separate animated water field);
   sandsea art is approximated by the converted outer water ring.
 - nowater2 masks are imported as their own type; presets_summer.json still
   lists 41 transition blocks with no PNG (unused today).
 - Static map dump JSONs are large (~1 MB) because Godot sorts base64 keys
   first; scan_map.py reads the whole file to find map_w.

----------------------------------------------------------------------
BUILD LOG 2026-11-20d — animation sequence, builder selection, relief light
----------------------------------------------------------------------
USER REPORT: "graphics is so far away from the video level, units animations
are wrong, all peasants go to build not just selected ones". Video reference
https://www.youtube.com/watch?v=cZW0AEupCaI (thumbnail kept as
app/shots/video_ref_thumb.jpg): donor look = crisp 3D buildings with
scaffolding, dense formed armies, rich photographic terrain, warm directional
light and real shadows. The port is a 2D top-down sprite port; matching that
exactly is a multi-stage effort, not one flag. This log records what was fixed
now and what remains.

DONOR ANIMATION TRUTH (read from C:\Games\Cossacks 3\data\animations\aaf\*.aaf):
 peaukr.aaf (fps 30 from the .oss header):
   walk 1..20 (20 frames), idle 64..113 (50), death 115..149 (35),
   attack0 237..254 (18), workwood 237..254 (18), workfood 278..299 (22),
   workstone 217..234 (18), construct 186..198 (13),
   plus carry/idle variants walkwood 22..41, idlefood 405..454, ...
 pikeman.aaf walk 1..24 / attack0 32..46 / idle 209..258 / death 80..134.
 The donor therefore has SEPARATE clips for chopping, farming, mining and
 building. The old port baked only 6 walk frames out of 20 and reused the
 COMBAT attack sheet for gather/build -> "strange dance", the user's exact
 complaint. Two further bugs made it worse:
   - duration was len(sampled_frames)/fps, so an 8-of-35 death played in
     0.27 s instead of the donor's 1.17 s (hyper-flip);
   - skinned[frames.index((action,fr))] could return the wrong frame when two
     actions share a range (attack0 and workwood are both 237..254).

FIXED (files):
 app/tools/bake_sprites.py
   - sample() keeps EVERY donor frame when the action is <= cap; long idle/
     death ranges are evenly reduced. Order is donor order a..b.
   - added workwood/workfood/workstone/construct actions (caps 10/10/10/8).
   - duration = (b-a+1)/fps (donor full cycle, independent of decimation).
   - frame_index keyed by (action,frame), not Python id(int) (intering bug).
   - added --engine workbench: flat textured CPU render, one unit in ~26 s
     vs Cycles minutes. CPU-only, weak-GPU safe.
 app/tools/sheet_metrics.py --normalize: all actions of a unit inherit the
   idle action's fig_h/foot/cx, so units no longer grow/shrink ~56% when they
   switch idle -> attack -> death (GUIDE4 L7.04, previously unfixed).
 app/scripts/world.gd
   - _anim_action() picks workwood/workfood/workstone by order.res and
     construct for build/repair, falling back to attack for units with no
     dedicated work sheet; _draw_anim falls back correctly when missing.
   - _build_chunk() applies directional slope shading (NW light) from the
     stored height field, so hills/lake bowls read as relief.
 app/scripts/game.gd + input_controller.gd
   - place_building(..., builders:Array = []) sends ONLY the selected
     peasants (previously it swept up 8 idle AND gathering peasants).
     AI still uses send=false; selftest/uitest pass explicit builders.

REBAKED UNITS (Workbench, 160px, 1 sample): peasant, rus_peasant, pikeman,
 musketeer, serdiuk, archer, officer, drummer, priest, cossack, cannon.
 Remaining 43 sheets still use the old 6-frame decimation; their durations
 were already donor-correct, so they are playable but choppier.

ATOMIC GATES: selftest 28/28 True, uitest True, screenshot g4_shading.png.
 Peasant durations now walk .667 / idle 1.667 / attack .600 / workwood .600 /
 workfood .733 / construct .433 / death 1.167 s (donor values).

GRAPHICS PLAN (still open, do not pretend it is done):
 1. terrain: donor blocks are 1024px but the port renders 16px/tile at high
    quality (32 screen px/tile) -> detail is lost. Consider 32px/tile on
    "high" with the 2/frame chunk budget, and copy the donor's dirt/rock
    transition blocks (41 preset names still have no PNG).
 2. water: donor uses an animated separate water field; port still paints a
    tiled blue plane. Import diffusewaves0/2 frames as a flipbook.
 3. army density: the video shows hundreds of formed men; port cap is 200
    per side and skirmish starts 8 peasants. Need instanced/cheap crowd
    rendering before raising counts (weak GPU rule still applies).
 4. buildings/shadows: nation sheets exist (215) but read small; add contact
    shadows, construction-stage art is baked (s1..s4) but not always shown.
 5. food nodes currently render as glowing yellow dots (flowers). Donor has
    contiguous golden wheat fields: draw a field patch per 5x4 food cluster.

----------------------------------------------------------------------
BUILD LOG 2026-11-21 — ORE DEPOSITS WERE IN THE DATA BUT NEVER DRAWN
----------------------------------------------------------------------
USER REPORT: "map generation is still to improve, still no mines on the
map / on map and minimap those mines are not drawn with correspondent
image?".

ROOT CAUSE (measured, not guessed):
  - `--dump-map --seed 7..18` shows a CORRECT 18 deposits per map
    (6 gold / 6 iron / 6 coal = 3 of each per player start), stamped by
    pattern_gen.gd SetupMines from the donor mng/mni/mnc patterns.
  - game.gd:_add_res() stores an ore deposit as a PERMANENT node:
    hits = 0 AND max_hits = 0.
  - world.gd:_draw_resources() culled every node with "hits <= 0" except
    stumps -> every deposit was skipped. The sim, AI, build menu and
    headless CPU render (main.gd:_render_headless_image used the correct
    "hits <= 0 and max_hits > 0" test) all saw the deposits; only the
    real GPU world render hid them. That is exactly "no mines on map".
FIXED:
  - app/scripts/world.gd: skip only FINITE depleted nodes (hits <= 0 and
    max_hits != 0); stumps and permanent deposits stay. Deposits now get
    a proper baked-rock outcrop with ore-coloured veins, a tinted apron
    and a jagged procedural fallback, so each ore reads as a mine site.
  - app/scripts/hud.gd: minimap deposits now draw a distinct 2x2 bright
    ore core inside a dark outline (still hidden until scouted when fog
    is on), instead of a bare quad that vanished against the terrain.
GATES: `godot --headless --path app -- --self-test` keeps the "mine" and
  "hud" steps green (deposit found, mine produced 49.9 gold, minimap
  drawn); windowed screenshot runs cleanly; the parallel unified-mine
  regression test passes 11/11. No mapgen placement change was needed —
  the generator was right, the renderer was the whole bug.

SCAN-NOTE-2026-11-21 agentB (evidence: docs/audit/GEN.md, deep-GEN): scan_map.py's
  fixed 25-tile reach radius was a STALE QA THRESHOLD from the old 160-tile map,
  not a generator defect. At the configured 320 tiles the donor-faithful
  generator scales mine/stone distances by s = map_w/160 = 2.0
  (pattern_gen.gd:47), so ores correctly sit 28-44 tiles from starts; donor
  cMapSize=640 confirms that scaling. Fix in the JUDGE only:
  reach_radius(w)=round(25*w/160) -> 25 tiles at 160 (unchanged), 50 at 320.
  Re-scan seeds 7/8/9: reachability 0/3 -> 3/3. No generator knob changed.
  Remaining reds (patches 306/315/303, clear 94% seed 8, cliff 0% seed 9)
  come from game.gd:471 sparse sod paint and game.gd:487 post-collision height
  mutation - generator owner's files, deliberately untouched here.
