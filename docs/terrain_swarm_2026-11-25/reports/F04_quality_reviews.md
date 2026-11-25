---
id: F04
ticket: TERRAIN-SWARM-2026-11-25 / F04
title: "What 'good Cossacks 3 visual quality' means online — reviews, New Terrain Mod, and an implementation-ranked checklist for our port"
owner: F04 (online-research subagent, READ-ONLY)
created: 2026-11-25
status: DELIVERED
labels: [observed, derived, inferred, UNVERIFIED]
method: webfetch/websearch only; no code edits, no Godot jobs, no local render A/B
---

# F04 — Online donor quality research

## 0. Scope, method, guardrails

Charter read in full (`docs/terrain_swarm_2026-11-25/CHARTER.md`). This is a **read-only,
one-report** deliverable: no files touched except this report; no runner jobs submitted.

Label convention (binding per Charter §3):

- **OBSERVED** = a verbatim claim from a linked source, fetched this session (2026-11-25).
- **DERIVED** = my direct comparison of that claim to the Charter's reference samples / flat render.
- **INFERRED** = my judgement about what to implement in our port; not proven by a donor GPU frame.
- **UNVERIFIED** = donor parity. **No real donor GPU A/B frame exists** (Charter §3), so nothing here
  may be read as "confirmed donor behaviour". Reviewer prose is *context*, not a specification.
  Several reviews are of **pre-release / review-copy builds** (NoobFeed explicitly pre-release;
  HeyPoorPlayer and WGB disclose review copies), which further limits their authority.

The visual target, restated from Charter §1 (OBSERVED locally): reference A
`cossacks-3-v1-498085.jpg` = organic grass, large soft green mottling, dark/light patches,
ravines/cliffs with grey rock faces, trees, **no grid / diagonal streaks / repetition**; reference B
`articolo-787.jpg` = rolling relief, patchy grass, natural transitions. Our current render
`p0_final_formula.png` = flat uniform olive, fine grain, faint diagonal streaks/repeating bands,
soft blocky patches, no large-scale organic variation.

---

## 1. Source inventory (all fetched 2026-11-25)

| # | Source | URL | What it contributes |
|---|---|---|---|
| S1 | HeyPoorPlayer review (2016-09-28, review copy) | https://www.heypoorplayer.com/2016/09/28/cossacks-3-review/ | Terrain "bland green" repeats across random maps; fauna/geological objects "flat" and "no movement"; units/buildings strongest visually |
| S2 | NoobFeed review (2016-09-19/20, **pre-release build**) | https://www.noobfeed.com/reviews/cossacks-3-pc-review | "not a looker" vs modern RTS but visibly improved; style keeps old-school atmosphere and "letting you know where everything is" (legibility); naval clipping, bridge pathfinding bugs |
| S3 | WGB review (2016-09-28, review code) | https://wolfsgamingblog.com/2016/09/28/cossacks-3-review-less-sequel-more-hd-remaster/ | "graphics are actually quite pretty"; limited zoom-out a missed opportunity; cramped random maps |
| S4 | Gamekult game page + review teaser (score 4/10) | https://www.gamekult.com/jeux/cossacks-3-3050468591.html · https://www.gamekult.com/jeux/cossacks-3-3050468591/test.html | "La réalisation est on ne peut plus sommaire et les bugs foisonnent" (presentation extremely basic, bugs abound); mod-friendly, regular post-release support |
| S5 | JeuxVideo.com review via aggregator (score 9/20) | https://www.gamekult.com/jeux/cossacks-3-3050468591.html (aggregated) · https://www.commentchoisir.fr/test-Cossacks_3.htm | "topographie des terrains, pauvre au possible" (terrain topography extremely poor); no musket-range indicators |
| S6 | Gamepressure review | https://www.gamepressure.com/editorials/reviews/cossacks-3-review-a-sad-return-to-the-past/zee9 | "The graphics are the game's biggest asset"; models fantastic, animations smooth but only ~1 move + 1 combat animation per unit; low combat legibility |
| S7 | GamingOnPC review | https://www.gamingonpc.com/reviews/cossacks-3-review/ | "aesthetically pleasing, with detailed units and colorful maps… looks like a painting in motion"; maps "mostly static"; perf issues >4000 units |
| S8 | RealityRemake review (2025-07-30) | https://www.realityremake.com/articles/cossacks-3-review | "fresh textures and dynamic lighting… elevate the sense of scale"; "distinctly old-school RTS vibe — deliberate, functional, and not overly cinematic"; seasonal weather/terrain in DLCs; highly moddable |
| S9 | Rock Paper Shotgun (Alec Meer, 2016-09-22), **quote recovered via OpenCritic / Wikipedia** (direct fetch 403) | https://opencritic.com/game/3208/cossacks-3/reviews · https://fr.wikipedia.org/wiki/Cossacks_3 | "Straightforward, simple, but slick and solid… feels sufficiently of today despite its cheerfully throwback heart" |
| S10 | gameGPU technical review | https://en.gamegpu.com/test-gpu/rts-strategii/cossacks-3-test-gpu | Own OpenGL engine; min→max graphics settings difference "noticeable even to the naked eye"; **"Activating anti-aliasing has virtually no effect on anything"**; "cannot offer us any of the latest graphical delights" |
| S11 | Polygon 2015 dev interview | https://www.polygon.com/features/2015/5/18/8615339/cossacks-3-announcement-release-date-gsc-stalker/ | Terrain determines weapon range/fire effectiveness; "hide from the enemy's artillery behind mountains and high plains"; fortifications add tactical variety |
| S12 | Steam store page | https://store.steampowered.com/app/333420/Cossacks_3/ | "A significant influence of the landscape on the tactics of battles"; "Flexible map generator" |
| S13 | CossacksHQ — New Terrain Mod (NTM) | https://cossackshq.net/c3-mod-new-terrain-mod | Full NTM v1.6.0.3 additions/tweaks/fixes list; author Ebel; note `[Added to the base Game]` markers |
| S14 | cossacksworld — NewTerrainMod | http://cossacksworld.ucoz.co.uk/index/newterrainmod/0-335 | Same feature list + author's rationale: "lack of variation in the random maps GSC provided us with. They all look the same"; 736 new random map masks; `.tga type 10, 24 bits, rle compressed, gaussian blur format as the vanilla ones` |
| S15 | cossacksworld — New Random Map Mask Samples / EMOM v2.7.7.1 | http://cossacksworld.ucoz.co.uk/index/new_random_map_mask_samples/0-333 (direct 403; content recovered via websearch index) | Ebel's Map Option Mod (NTM predecessor): desert/arctic terrain types, lakes/coastal/river shapes, 736 masks; **Known Issues** list |
| S16 | cossacksworld — NTM file catalog | http://cossacksworld.ucoz.co.uk/load/c_iii_mods/c3_mods/new_terrain_mod/83-1-0-467 | NTM v1.6.0.3 for GOG/non-Steam game v2.2.1.92.5962 |
| S17 | cossacksworld — NTM animals update (2018-01-20) | http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod/2018-01-20-54 | v1.3.3.7 farm + wild animals added "to make the maps more lively" |
| S18 | cossacksworld — NTM flying birds (2018-01-26) | http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod_flying_birds/2018-01-26-55 | v1.4.2.5 flying birds; more decoration patterns; winter farmhouse textures; replaced 3 bad road textures |
| S19 | Steam Workshop — New Terrain Mod (id 1255766623) | https://steamcommunity.com/sharedfiles/filedetails/?id=1255766623 | Same catalogue; ~20,926 subscribers; **user comment about wild animals blocking building/walls**; creator "no longer with us" |
| S20 | CossacksHQ — Patch notes #22 (2017-02-24) | https://cossackshq.net/c3-news-patch-notes-22/ | **"Fixed lighting, now the map won't get too bright if you hover over to the lower left corner"**; "Ships now won't sail on land" |
| S21 | GOG/Steam patch notes via CossacksHQ & gogdb | https://www.gogdb.org/product/1797227701/releasenotes · http://cossacksworld.ucoz.co.uk/index/patch_notes/0-332 · https://cossackshq.net/c3-news-patch-notes-14/ | 2016-12 patch: "Tweaked the lightning for a snowier atmosphere", "Added some holiday trees to the map generator"; fog-of-war brightness fix; texture preloading; map-gen optimisations |
| S22 | Dedoimedo review | https://www.dedoimedo.com/games/cossacks-3.html | "zoom and camera pan freedom, lovely graphics and stunning details"; very GPU-heavy ~1500 units |

---

## 2. The feature list that separates the reference samples from our flat render

Each row: **OBSERVED** donor-side evidence → **DERIVED** gap against Charter §1 → status in donor.

| # | Feature | Donor evidence (OBSERVED) | Gap vs our render (DERIVED) | Vanilla / mod-only |
|---|---|---|---|---|
| F-1 | **Large-scale grass variation** ("large soft green mottling", dark/light patches) | Ref A/B (Charter §1); S1 "same bland green environment a lot"; S13/S14 item 13 "New patterns for more landscape variety (200+)", item 6 "New map textures (summer, winter, autumn, spring)"; S4/S5 "réalisation… sommaire" / "topographie… pauvre au possible" | Our field is one uniform olive with only fine grain: **no low-frequency colour field at all**. This is the single largest visual delta. | Base grass textures = **vanilla**; 200+ variety patterns and 4-season texture set = **mod-only (NTM)** |
| F-2 | **Repetition / pattern-free ground** | Ref A/B "no grid, no diagonal streaks, no repetition" (Charter §1); S14 author's rationale "They all look the same"; S10 "AA has virtually no effect" (so the fix must be in texture sampling, not post-AA) | Our faint diagonal streaks / repeating bands and soft blocky patches map to Charter suspects #1 (hard 2 m repeat), #2 (pseudo-random alpha patch), #3 (nearest/mipmap). Donor reviews never praise tiling; they *complain about sameness*, which is a different (data-variety) defect. | Not an explicit feature; a **quality property** of donor tile/pattern data |
| F-3 | **Relief — rolling hills, ravines, cliffs, grey rock faces** | Ref A "ravines/cliffs with grey rock faces"; Ref B "rolling relief" (Charter §1); S11 "hide… behind mountains and high plains"; S12 "significant influence of the landscape on the tactics"; S5 "topographie des terrains, pauvre au possible"; S13 item 23 "Hills generate hills and not plateaus/mountains" | Charter suspect #6: real donor relief grids exist but our screenshot is near-flat; cliffs/ravines that break up the surface are absent. | Relief + elevation = **vanilla** (tactical, per S11/S12); generation *corrections* (plain stays plain, hills stay hills) = **mod-only (NTM)** |
| F-4 | **Trees / decor density and variety** | S13 items 3–5: forest types Countryside / Taiga / Black forest (dense) / temperate; harvestable Willow, Oak, Beech, Birch, Cypress, Olive, Poplar, Maple, oak bushes; flowers/decor cabbage, cornflower, thistle, caluna, rubbled houses, farmsteads, graves; S18 "churches with graveyards, castles, rubbled buildings"; S1 fauna/geological objects "flat"; S7 "colorful maps", "painting in motion" | Our flat render has no decor mass to occlude/break the ground plane; even a modest organic scatter would raise perceived quality. | Base trees/decor = **vanilla**; the listed tree/flower/decor *variety* and density modes = **mod-only (NTM)** |
| F-5 | **Seasonal textures** | S13 item 2 "New seasons options: Spring and Autumn"; item 6 "New map textures (summer, winter, autumn, spring)"; item 21 "Changed the winter textures to be darker, as opposed to being blinded by the current snow textures"; S21 "Tweaked the lightning for a snowier atmosphere", "holiday trees"; S8 "seasonal weather, or terrain" in DLCs | Our port has one olive palette; no season axis at all (Charter suspect #4 flat/olive palette). | Winter/snow maps and snow lighting = **vanilla** (patch/DLC); Spring/Autumn seasons + full 4-season texture set + darker snow = **mod-only (NTM)** |
| F-6 | **Animated foliage** | S13 item 14 "Animated trees. They appear to be moving with the wind"; S1 "most environmental models feel very flat and have no movement… some subtle animations in fauna would've made the visual experience a bit better"; S7 "maps are mostly static" | Our ground and any decor are fully static; wind motion is a cheap way to make a simple port feel alive. | **Mod-only (NTM)** — vanilla is explicitly static per S1/S7 |
| F-7 | **Shoreline / water transitions** | S13 item 1 `[Added to the base Game]` "Lakes, Rivers and coastal. (360+ map masks)"; S14/S15 151 lake + 57 coastal + 157 river + 100 Mediterranean + island/peninsula masks; S20 "Ships now won't sail on land"; S2 bridge pathfinding complaints | Charter §1 feature list includes shoreline; our flat render has no water/land transition to read against. | **Vanilla in current builds** (explicitly marked added to base game) — the *extra 736 masks* are mod-only |
| F-8 | **Lighting** | S8 "dynamic lighting… elevate the sense of scale"; S10 "difference between min and max settings noticeable even to the naked eye"; S20 lighting corner bug fixed; S21 snowier lighting tweak; Charter suspect #4 "donor sun/ambient/diffuse + rgb * a * v_packed yield a uniform olive" | Our olive is uniform partly because the light/diffuse terms are not producing spatial variation; warm directional light plus relief is what makes donor grass read as mottled. | **Vanilla** engine feature; mod only *tweaks* winter texture darkness |

**Cross-cutting observation (OBSERVED, S1/S2/S6/S8/S9):** reviewers consistently say the donor's
*units/buildings* are the strong point and the *terrain* is the weak point — "bland green",
"topographie… pauvre au possible", "sommaire". **DERIVED:** the reference screenshots that the
owner loves are therefore likely the *best-case* donor output (patch/mod-augmented, favourable map
and camera), not the median 2016 review-build screenshot. We should target the reference samples,
not "average vanilla". This is **INFERRED** and cannot be settled without a real donor GPU A/B
frame (UNVERIFIED).

---

## 3. Vanilla vs mod-only — decision table (with URLs)

Markers copied verbatim from S13/S16/S19 where present.

| Feature | Status | URL |
|---|---|---|
| Lakes / Rivers / coastal map options, 360+ masks | `[Added to the base Game]` → **vanilla now** | https://cossackshq.net/c3-mod-new-terrain-mod |
| 15-minute peace time | `[Added to the base Game]` → vanilla (5 min is mod-only) | https://cossackshq.net/c3-mod-new-terrain-mod |
| 17th-c. barracks / log cabins / village / union of nations starts | `[Added to the base Game]` → vanilla | https://cossackshq.net/c3-mod-new-terrain-mod |
| Expensive mercenaries | `[Added to the base Game]` → vanilla | https://cossackshq.net/c3-mod-new-terrain-mod |
| 200+ landscape-variety patterns | **mod-only (NTM)** | https://cossackshq.net/c3-mod-new-terrain-mod |
| Spring/Autumn seasons; summer/autumn/spring map textures | **mod-only (NTM)** | https://cossackshq.net/c3-mod-new-terrain-mod |
| Darker winter textures (vs blinding vanilla snow) | **mod-only (NTM)** tweak | https://cossackshq.net/c3-mod-new-terrain-mod |
| Forest-type options (Countryside/Taiga/Black forest/temperate) | **mod-only (NTM)** | https://cossackshq.net/c3-mod-new-terrain-mod |
| Extra harvestable tree types; flowers/decor/ruined buildings | **mod-only (NTM)** | https://cossackshq.net/c3-mod-new-terrain-mod |
| Animated (wind) trees | **mod-only (NTM)** | https://cossackshq.net/c3-mod-new-terrain-mod |
| Wild/farm animals, flying birds | **mod-only (NTM)** | http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod/2018-01-20-54 · http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod_flying_birds/2018-01-26-55 |
| 736 new random map masks (EMOM→NTM) | **mod-only** | http://cossacksworld.ucoz.co.uk/index/newterrainmod/0-335 |
| Terrain generation corrections (plain→plain, hills→hills) | **mod-only (NTM)** tweak | https://cossackshq.net/c3-mod-new-terrain-mod |
| Elevation affecting range/cover; flexible map generator | **vanilla** | https://www.polygon.com/features/2015/5/18/8615339/cossacks-3-announcement-release-date-gsc-stalker/ · https://store.steampowered.com/app/333420/Cossacks_3/ |
| Dynamic lighting; snow-lighting patch | **vanilla** | https://www.realityremake.com/articles/cossacks-3-review · https://www.gogdb.org/product/1797227701/releasenotes |

**INFERRED port consequence:** items we must reproduce to hit the reference samples are mostly
**vanilla-quality baselines** (large-scale grass colour, relief, shoreline, lighting). The NTM-only
items (seasons, animated trees, decorated forests, animals) are **additive polish**, not
prerequisites for killing the diagonal streaks. Do not let a P2 item delay a P0 fix.

---

## 4. Donor bugs and anti-patterns we must NOT copy

All **OBSERVED** unless noted.

1. **Box selection failing after selecting a wall** — donor quirk recorded in Charter §1b item 2.
   Explicitly flagged there as "a donor bug we should NOT copy". Keep our selection quad correct.
2. **Lighting blows out when the cursor hovers the lower-left corner** — "Fixed lighting, now the map
   won't get too bright if you hover over to the lower left corner" (patch #22,
   https://cossackshq.net/c3-news-patch-notes-22/). Do not reproduce any view-dependent brightness
   coupling; our lighting must be camera/cursor independent.
3. **Uniform bland green terrain across random maps** — S1 "you will see the same bland green
   environment a lot"; S14 "They all look the same". This is the donor's *weakness*, not its look.
   Copying it would recreate the owner's complaint.
4. **Flat, unmoving environmental models** — S1 "fauna and geological objects feel very
   underwhelming; most environmental models feel very flat and have no movement"; S7 "maps are
   mostly static". Our port should at least not be *less* alive than flat donor static decor.
5. **Ships clip into each other and cancel each other's fire** — S2; and "ships sailed on land"
   before patch #22 (https://cossackshq.net/c3-news-patch-notes-22/). Relevant if we add shoreline:
   water/land masks must be geometrically honest.
6. **Bridge pathfinding strands units** — S2 "pathfinding difficulties, especially when coming up
   to bridges which made portions of larger groups to remain behind"; S5 blobs stuck at mountain
   feet. Do not let added relief/shore break traversability.
7. **Cannons move and fire with no crew** — S2, S5, S6. Cosmetic-animation debt; no gameplay value
   for our terrain port.
8. **High-brightness fog-of-war transparency** — patch #14 "Fog of War is no longer transparent on
   monitors with high brightness" (https://cossackshq.net/c3-news-patch-notes-14/). Do not copy.
9. **NTM animal placement blocks building/walls** — Steam comment: "wild animals … prevent you from
   putting up a building, or properly drawing a defensive line of walls, it's annoying that you can't
   kill them or move them to the side" (https://steamcommunity.com/sharedfiles/filedetails/?id=1255766623).
   If we add fauna/birds (P2), they must be non-blocking.
10. **NTM known terrain-rendering defects** (S15): "Weird grass texture on east/south border on
    normal maps on desert and arctic maps"; "Black spots around mines on artic maps"; plus NTM item 24
    "Fixed misdecor7 & 8 having a bad texture (tent texture pointing to wrong file.)". These are
    exactly the class of seam/border/texture artifact Charter §5 forbids — do not inherit them.
11. **NTM generation-time blow-up** — v1.3.3.7 "Improved the generation time for the 'black forest'
    option. Reduced the amount of trees/patterns that were being generated. Still one of the 'longest'
    generation times" (S17). Dense decor must be budgeted.
12. **NTM odd option combinations** — S14 "Some combinations of options may appear a bit weird eg;
    countryside + mountains"; "desert + foresttype: it will always be palm trees". Keep our
    biome/terrain rules mutually consistent.
13. **AA is not a fix** — S10 "Activating anti-aliasing has virtually no effect on anything". Our
    streaks must be fixed in tile sampling / tile-index data, not by post-process AA.

---

## 5. Ranked, implementation-relevant checklist for our port

Ranking criterion: Charter §5 (no visible repeats/streaks/blotches → multi-scale organic variation
and relief/shore → gates stay green). P0 items directly address the owner's complaint and Charter
suspects #1–#4; P1 adds the reference-sample structures; P2 is optional polish. **All entries are
INFERRED implementation guidance**, not proven donor parity (UNVERIFIED).

### P0 — must land before the render can be called "not synthetic"

| # | Action (INFERRED) | Donor evidence | Done looks like (Charter §5) |
|---|---|---|---|
| P0-1 | **Break the hard 2 m verbatim tile repeat.** Replace `fract(v_st * uv_repeat)` + single-cell lookup with stochastic/offset tiling or per-cell rotation-mirror variants plus a low-frequency warp; ensure no cell is copied verbatim on a fixed lattice. | F-2; Charter suspect #1; S14 "all look the same"; S10 AA useless | No diagonal streaks/moiré at shallow camera; no grid |
| P0-2 | **Decouple mask intensity from RGB and stop the repeated dark blotches.** Audit `alpha_patch_uv()` + `mask_to_alpha=1` fold (Charter suspect #2); keep mask/data-derived patch selection but remove its direct luminance contribution. Mark any substitute rule PORT APPROX. | F-2; Charter suspect #2; Ref A "no repeated dark blotches" | No repeated dark blotches; transitions read organic |
| P0-3 | **Add a real low-frequency grass colour field** (multi-scale hue/luma mottling, dark/light patches) layered over the fine grain — not a synthetic dither/noise field (Charter §3 S-25-09). Prefer modulating with existing tile/pattern data or donor relief. | F-1; Ref A/B; S1 bland green; S13 200+ patterns; S4/S5 | "multi-scale organic colour variation" visible in 64² and real-map captures |
| P0-4 | **Fix sampling: trilinear/anisotropic minification, no nearest magnification of a repeated cell.** Address Charter suspect #3 at the texture/filter level, not with AA. | F-2; Charter suspect #3; S10 | Fine grain stays fine; no banding; gates `assert_clean CLEAN` |

### P1 — required to actually resemble the reference samples

| # | Action (INFERRED) | Donor evidence | Done looks like |
|---|---|---|---|
| P1-5 | **Make relief read in the final screenshot.** Re-enable/raise the existing donor relief grids (Charter suspect #6) so ravines/cliffs with grey rock faces and rolling hills are visible; verify with `measure` of height variance, not just code presence. | F-3; Ref A/B; S11 elevation/tactics; S5 poor topography; S13 hills/hills rule | Cliff faces and rolling relief visible; no z-fighting/black rows |
| P1-6 | **Add shoreline / water-land transitions** where the map data supplies lakes/rivers/coastal masks; keep masks geometrically honest. | F-7; S13 `[Added to base Game]` lakes/rivers/coastal; S20 ships-on-land bug; Charter §1 feature list | Natural shore transitions; no new seams |
| P1-7 | **Raise tree/decor density and variety enough to break the ground plane** — a few forest-type clusters and simple scatter decor; budget generation time. | F-4; S13 items 3–5; S18 decoration patterns; S1 flat decor; S17 Black-forest cost | Ground no longer reads as an empty plane; generation time bounded |
| P1-8 | **Warm up and spatially vary lighting**; keep it camera/cursor independent; add a subtle directional response on relief. | F-8; S8 dynamic lighting; Charter suspect #4; S20 corner-brightness bug | Olive replaced by believable grass; no corner blow-out |

### P2 — optional, mod-only polish (do not block P0/P1)

| # | Action (INFERRED) | Donor evidence | Caution |
|---|---|---|---|
| P2-9 | Seasonal texture variants (autumn/spring; darker winter) | F-5; S13 items 2/6/21; S21 snow lighting | **mod-only**; large asset cost; keep variant selection data-driven |
| P2-10 | Animated foliage / wind sway on trees | F-6; S13 item 14; S1 "no movement"; S7 "mostly static" | **mod-only**; perf; must not reintroduce flicker/banding |
| P2-11 | Fauna/birds as ambient life | S17/S18/S13 item 15 | **mod-only**; **must be non-blocking** (bug #9) |

### Non-negotiable integration constraints (Charter §3/§5)

- Every change carries a donor URL **or** an explicit `PORT APPROX` label; no invented donor constants.
- No threshold lowered, no assertion deleted, no `expected_pre_fix_failure` flipped without a landed fix.
- **No synthetic dither/noise field** (decision S-25-09).
- Gates stay green: selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean CLEAN`; `app/` untouched.
- Donor parity remains **UNVERIFIED** until a real donor GPU A/B frame exists.

---

## 6. Confidence statement

- **OBSERVED:** all quoted review/mod/patch text in §§1–4, fetched this session; the local render/sample
  description is quoted from Charter §1.
- **DERIVED:** the feature→gap mapping in §2 and the vanilla/mod-only classification in §3 where
  explicitly marked by the source.
- **INFERRED:** the ranked checklist in §5 and the "target best-case donor" conclusion in §2.
- **UNVERIFIED:** any claim that our output matches donor pixels. No GPU A/B frame was produced by
  this ticket (read-only by assignment).

## 7. Reference list (all cited above)

1. https://www.heypoorplayer.com/2016/09/28/cossacks-3-review/
2. https://www.noobfeed.com/reviews/cossacks-3-pc-review
3. https://wolfsgamingblog.com/2016/09/28/cossacks-3-review-less-sequel-more-hd-remaster/
4. https://www.gamekult.com/jeux/cossacks-3-3050468591.html
5. https://www.commentchoisir.fr/test-Cossacks_3.htm
6. https://www.gamepressure.com/editorials/reviews/cossacks-3-review-a-sad-return-to-the-past/zee9
7. https://www.gamingonpc.com/reviews/cossacks-3-review/
8. https://www.realityremake.com/articles/cossacks-3-review
9. https://opencritic.com/game/3208/cossacks-3/reviews · https://fr.wikipedia.org/wiki/Cossacks_3
10. https://en.gamegpu.com/test-gpu/rts-strategii/cossacks-3-test-gpu
11. https://www.polygon.com/features/2015/5/18/8615339/cossacks-3-announcement-release-date-gsc-stalker/
12. https://store.steampowered.com/app/333420/Cossacks_3/
13. https://cossackshq.net/c3-mod-new-terrain-mod
14. http://cossacksworld.ucoz.co.uk/index/newterrainmod/0-335
15. http://cossacksworld.ucoz.co.uk/index/new_random_map_mask_samples/0-333
16. http://cossacksworld.ucoz.co.uk/load/c_iii_mods/c3_mods/new_terrain_mod/83-1-0-467
17. http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod/2018-01-20-54
18. http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod_flying_birds/2018-01-26-55
19. https://steamcommunity.com/sharedfiles/filedetails/?id=1255766623
20. https://cossackshq.net/c3-news-patch-notes-22/
21. https://www.gogdb.org/product/1797227701/releasenotes · http://cossacksworld.ucoz.co.uk/index/patch_notes/0-332 · https://cossackshq.net/c3-news-patch-notes-14/
22. https://www.dedoimedo.com/games/cossacks-3.html

*End of F04 report.*
