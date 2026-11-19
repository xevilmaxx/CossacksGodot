# EXECUTION PLAN — Cossacks 3 Godot clone, next improvement round (SUPERSEDED by GUIDE2.md — all steps verified complete, see GUIDE2.md + status below)

**STATUS 2026-11-18: EXECUTION PLAN 100% COMPLETE.** Steps 1 (54 unit sheets
+ 215 nation-building sheets, CPU-only Cycles), 2 (anim wiring + lazy
nation-sheet loading), 3 (26-unit roster + nation variants), 4 (formation
bonuses/replenish/academy gate/flee/mine upgrade/battery/wedge/capture
toggle/AI opener + wiki round 2: 17c-lock, cav values, grapeshot,
mortar-only-buildings, tower fortification, Delete key), 5 (docs: 156
mechanics values) — verified: self-test 21/21, CLI clean, windowed
screenshots (animated peasants, ukr wooden town center). Known gaps kept in
MECHANICS.md (unit capture, mine-slot ladder, tower upgrades, garrison,
repair, elevation bonus). Construction stages/rubble skipped: stage meshes
have different topology (baker renders only matching-topology stages; none
matched) — unfinished buildings fall back to finished sprite + scaffold
tint. Fandom wiki is 403 to the fetcher; rules mined via search snippets.**

**Read this whole file before doing anything.** It is self-contained: every
format fact below was verified by measurement on this machine (2026-11-18),
every path exists, every command was checked. Execute steps IN ORDER. Each
step has an acceptance check; do not proceed until it passes. Work cheaply:
use `grep`/offset reads, never re-read whole big files, run bakes in
background, never re-derive what is written here.

Companion research: `reference/videos.md` (14+ gameplay videos + wiki
mechanics). Existing mechanics sources: `app/MECHANICS.md`, `app/mechanics.json`.

---

## 0. Environment (verified)

| thing | value |
|---|---|
| project app dir | `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app` |
| donor game | `C:\Games\Cossacks 3` |
| Godot | 4.7.2 on PATH as `godot` (`godot.exe`) |
| Blender | `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe` (verified exists) |
| Python | 3.14.3, Pillow 12.1.1 installed |
| repo | NOT git. Before editing any existing script, copy it to `inbox/backup/<name>.bak` |

Commands (run from project root `...\cossacks-3-3`; quote paths with spaces):

```
godot --headless --path app -- --self-test app/selftest.json          # core loop, exits alone
godot --headless --path app -- --cli app/cli.json --cli-seconds 10    # AI-vs-AI fast match
godot --headless --path app -- --screenshot app/shots/headless.png    # CPU map fallback
godot --path app -- --screenshot app/shots/window.png --timeout 90    # REAL viewport picture
godot --headless --path app --import                                  # import new PNGs, exits
```

NEVER run godot without a test flag (it would hang the harness). All test
modes self-exit; `--timeout` is the safety net.

## 1. What already exists (DO NOT rebuild)

- Full skirmish sim: economy (6 resources, gathering hits/carry, mines
  1.664/s, upkeep /625, famine), construction, training queues, combat with
  donor damage formula, morale/rout, officers/drummers/priests auras,
  capture, market barter+drift, upgrades subset, walls, rally, squads +
  formations (line/column/square), fog, minimap, HUD, objectives, menu
  (20 nations, map types, start options), historical battles, AI, audio.
- Tools: `app/tools/convert_models.py` (reads .oss/.osm → obj+png, 29 models),
  `app/tools/render_models.py` (Blender static sprite baker), copy_assets.py,
  extract_map.py, build_missions.py.
- Assets: `app/assets/models/{obj,tex,sprites}` (92 static sprites),
  terrain tiles, UI atlas, 305 sounds, missions.json.
- Rendering: 2D top-down sprites in `app/scripts/world.gd`; sim in
  `game.gd`; stats in `data.gd`; input in `input_controller.gd`; HUD `hud.gd`;
  shell `main.gd`/`menu.gd`; tests `selftest.gd`.

**Architecture decision (keep it):** stay 2D-sprite rendering. "Improve 2D/3D
models" = bake BETTER sprites from the original 3D meshes (animated, all
nations), NOT a 3D engine rewrite. A true-3D mode is a stretch goal, out of
scope this round.

## 2. Verified binary format facts (measured, do not re-derive)

### 2.1 `.oss` (skinned units) — layout, little-endian
```
header <6i>: k_count(frames), fps, b_count(bones), v_count, f_count, t_count
verts   v_count * <3f>          (bind pose)
faces   f_count * <3i>
uvs     t_count * <2f>
uvfaces f_count * <3i>
weights per vertex: <i> n, then n * <if> (bone_index, weight)   # sums = 1.0
anim    b_count * k_count * <7f> (px,py,pz, qx,qy,qz,qw)  # bone-major: bone0 all frames, then bone1...
# file ends exactly there (verified: archer.oss 146872 bytes)
```
**Skinning model VERIFIED:** frame 0 of every bone is identity (max deviation
1.5e-7). Transforms are DELTAS from bind pose. For frame f:
`v' = Σ_i w_i * (R(quat_i(f)) · v_bind + p_i(f))`.
Tested on archer frames 0/12/60/100/140 → sane bboxes (~2 m tall; death frame
lies down; attack lunges). No bone hierarchy needed. `fps` field = 30
(animation rate; game logic is 32 fps — irrelevant for baking).

### 2.2 `.aaf` (action frame ranges) — PLAIN TEXT, next to mesh via `.actor`
`data/animations/aaf/<meshbase>.aaf`: line 1 `AAF`, line 2 version, then lines
`"name",start,end,morph`. Example archer.aaf: walk 1–24, idle 28–78,
death 80–129, attack0 130–157 (also attack0before 130–147 / after 148–157).
Ranges inclusive; frame indices within 0..k_count-1. The `.actor` text file
(`Animations.LoadFromFile = .\data\animations\aaf\<base>.aaf`) confirms the
pairing; just use same base name. Some meshes use `walk0`/`idle0` — fall back.

### 2.3 `.osm` (buildings/props) — IDP2/MD2-style; existing `read_osm` works.
**Buildings have construction stages and rubble as separate files** (verified
listings): `<nat><bld>.osm` finished, `<nat><bld>1..4.osm` build stages,
`<nat><bld>_death1/2.osm` destruction. Nation folders
`data/actors/buildings/<nat>/` with prefix `<nat>` (ukr, rus, pol, aus, fra,
eng, spa, swe, pru, ven, tur, alg, net, den, por, pie, sax, bav, hun, swi).
Shared: `commoneur/eur{sto,mil,mar,tow}.osm`; `commontur` exists for tur/alg
fallback. Textures mirror under `data/materials/buildings/<folder>/<base>.dds`.

### 2.4 Texture alpha
unit/building .dds have garbage alpha → convert RGB (force_opaque). env trees
keep alpha. Existing `convert_texture` already does this.

### 2.5 Unit mesh inventory (verified list, `data/actors/units/*.oss`)
Shared: pikeman, pikeman18, roundshier, musketeer(17c), musketeer18, serdiuk,
strelet, archer, grenadier, lightinfantry, officer, officer18, drummer,
drummer18, priest, pope, padre, mullah, bagpiper, cannon, howitzer, mortar,
multicannon (+`_death` and `_wheel_left/right` companions — ignore wheels).
Cavalry: cossacksich, cossackdon, cossackregister, dragoon(17c), dragoon18,
hussar, wingedhussar, cuirassier, reiter, lightcavalry, hackapell, tatar,
sipahi, spakh, mameluke, vityaz, hetman, croat, pandur, chasseur, highlander,
lancersco, raidersco, swordsmansco, archersco, archertur, jannisary,
kingmusketeer, jagerpor, jagerswi, gauduk.
Nation peasants: peaukr, pearus, peapol, peaaus, peaeng, peaspa, peatur, peasco.
Nation variants exist for many (musketeer18pru, grenadierpru, hussarpru,
pikemanrus, officerrus, drummerrus, dragoonpol, reiterpol, pikeman18swe...).

## 3. Integration points (verified line numbers, current files)

`world.gd`:
- L32 `var anim_t` ambient clock (reuse for looping anims).
- L36 `sprites` dict; L37 `SPRITE_ALIAS` (musk18→serdiuk etc. — DELETE an alias
  once the real sid has baked assets); L40 SPRITE_TINT.
- L83 `_load_sprites()` probes `sprites/%s_%03d.png` (8 dirs) then `%s.png`;
  uses FileAccess.file_exists then load(). L119 `_sprite_frames`, L122
  `_sprite_for(sid, face)` dir idx = `fposmod(roundf(face/(PI/4)),8)`.
- L132 `_draw_sprite(layer,tex,p,world_h,tint,shadow)`: scales by
  `world_h*view_scale/tex.height`, anchor `p - (sz.x*0.5, sz.y*0.82)`.
- L422–428 building draw (`_sprite_for(e.sid,-1)`), L585–589 mines,
  L634–640 unit draw branch `"__sprite__"`, L765–768 corpse draw.
- L112 `_unit_height`: artillery 1.5, cavalry 2.3, else 1.9.

`game.gd`:
- L332 `spawn()` entity dict fields: order{type}, cooldown, moving, face,
  hold, hit_t, morale, routing, deploy_t, finished, progress... ADD
  `"death_t": -1.0` here.
- order types: none/move/attack/attackmove/gather/build/guard/patrol.
- L1072 `_kill()` (corpses created here — set death_t), L1147 `_tick_unit`,
  L850 `effective_speed`, L858 `effective_damage`, L761 `research`,
  L900 `train_unit`, L613 `squad_form`, L687 `squad_set_formation`,
  L721 `formation_targets`. Grep `hit_t` before repurposing it (it exists;
  if used for hit-flash, add separate `fire_t` instead).
- `Data.PLAYER_NATIONS[player]` gives nation sid for sprite keying.

`data.gd`: UNITS_BASE / BUILDINGS_BASE / UPGRADES_BASE / NATIONS (L117) /
apply_damage L428. All stats live here; config.json overrides.

## 4. STEP 1 — animated unit sprite baker (the big visual win)

Create `app/tools/bake_sprites.py` with EXACTLY this code (verified design;
Blender 5.2 + Pillow). It CPU-skins frames, builds the mesh directly in
Blender (no OBJ import needed), renders 8 azimuths per frame, composites
sprite sheets with Pillow, writes `assets/models/anim/index.json`.

```python
#!/usr/bin/env python3
"""Bake ANIMATED 8-direction sprite sheets from original .oss meshes.
Run: blender.exe --background --factory-startup --python tools/bake_sprites.py -- \
     --game "C:\Games\Cossacks 3" --out assets/models/anim [--only sid,sid] [--size 160]
Sheets: <key>_<action>.png, cols=8 dirs (0,45..315), rows=sampled frames.
index.json: {key: {"cell": N, "actions": {action: {"frames": n, "duration": s, "loop": bool}}}}
"""
import argparse, json, math, os, struct, sys
import bpy
from mathutils import Vector
from PIL import Image

def parse_args():
    rest = sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--only", default=""); ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=8)
    ap.add_argument("--buildings", action="store_true")
    ap.add_argument("--nations", default="ukr,rus,pol,aus,fra,eng,spa,swe,pru,ven,tur,alg,net,den,por,pie,sax,bav,hun,swi")
    return ap.parse_args(rest)

def read_oss(path):
    with open(path,"rb") as f:
        k,fps,b,v,fc,t = struct.unpack("<6i", f.read(24))
        verts=[struct.unpack("<3f",f.read(12)) for _ in range(v)]
        faces=[struct.unpack("<3i",f.read(12)) for _ in range(fc)]
        uvs=[struct.unpack("<2f",f.read(8)) for _ in range(t)]
        uvf=[struct.unpack("<3i",f.read(12)) for _ in range(fc)]
        weights=[]
        for _ in range(v):
            n=struct.unpack("<i",f.read(4))[0]
            weights.append([struct.unpack("<if",f.read(8)) for _ in range(n)])
        anim=[[struct.unpack("<7f",f.read(28)) for _ in range(k)] for _ in range(b)]
    return dict(fps=fps,verts=verts,faces=faces,uvs=uvs,uvf=uvf,weights=weights,anim=anim,k=k)

def read_aaf(path):
    acts={}
    if not os.path.exists(path): return acts
    for line in open(path,"r",encoding="ascii",errors="replace").read().splitlines()[2:]:
        line=line.strip()
        if not line.startswith('"'): continue
        try:
            name,rest=line[1:].split('"',1)
            a,b,_=rest.strip().lstrip(",").split(",")
            acts[name]=(int(a),int(b))
        except Exception: pass
    return acts

def qmat(x,y,z,w):
    return ((1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)),
            (2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)),
            (2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)))

def skin(m, fr):
    mats=[qmat(*m["anim"][bi][fr][3:]) for bi in range(len(m["anim"]))]
    poss=[m["anim"][bi][fr][:3] for bi in range(len(m["anim"]))]
    out=[]
    for i,(x,y,z) in enumerate(m["verts"]):
        sx=sy=sz=0.0
        for bi,w in m["weights"][i]:
            M=mats[bi]; px,py,pz=poss[bi]
            sx+=w*(M[0][0]*x+M[0][1]*y+M[0][2]*z+px)
            sy+=w*(M[1][0]*x+M[1][1]*y+M[1][2]*z+py)
            sz+=w*(M[2][0]*x+M[2][1]*y+M[2][2]*z+pz)
        out.append((sx,sy,sz))
    return out

def sample(rng, n):
    a,b=rng
    if b<=a: return [a]
    return [a+round((b-a)*i/(n-1)) for i in range(n)] if n>1 else [a]

def setup_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    w=bpy.data.worlds.new("w"); bpy.context.scene.world=w; w.use_nodes=True
    sc=bpy.context.scene
    try: sc.render.engine="BLENDER_EEVEE_NEXT"
    except Exception: sc.render.engine="BLENDER_EEVEE"
    try: sc.eevee.taa_render_samples=8
    except Exception: pass
    sc.render.film_transparent=True
    sc.render.image_settings.file_format="PNG"; sc.render.image_settings.color_mode="RGBA"

def make_mat(png):
    mat=bpy.data.materials.new("m"); mat.use_nodes=True; nt=mat.node_tree
    out=nt.nodes.get("Material Output"); em=nt.nodes.new("ShaderNodeEmission")
    tex=nt.nodes.new("ShaderNodeTexImage"); img=bpy.data.images.load(png,check_existing=True)
    img.colorspace_settings.name="sRGB"; tex.image=img
    nt.links.new(tex.outputs["Color"],em.inputs["Color"]); em.inputs["Strength"].default_value=1.0
    nt.links.new(em.outputs["Emission"],out.inputs["Surface"])
    for n in list(nt.nodes):
        if n.type=="BSDF_PRINCIPLED": nt.nodes.remove(n)
    return mat

def build_mesh(m, mat):
    me=bpy.data.meshes.new("mesh"); me.from_pydata(m["verts"],[],m["faces"]); me.update()
    uv=me.uv_layers.new(name="UVMap")
    for fi,tri in enumerate(m["faces"]):
        for li in range(3):
            uv.data[fi*3+li].uv=m["uvs"][m["uvf"][fi][li]]
    ob=bpy.data.objects.new("model",me); bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    return ob

def camera(center, az, ortho):
    cd=bpy.data.cameras.new("cam"); cd.type="ORTHO"; cd.ortho_scale=ortho
    cam=bpy.data.objects.new("cam",cd); bpy.context.collection.objects.link(cam)
    bpy.context.scene.camera=cam
    el=math.radians(32.0); azr=math.radians(az)
    pos=center+Vector((math.cos(azr)*math.cos(el),math.sin(azr)*math.cos(el),math.sin(el)))*50
    cam.location=pos
    cam.rotation_euler=(center-pos).normalized().to_track_quat("-Z","Y").to_euler()
    return cam

def render_cell(path,size):
    sc=bpy.context.scene; sc.render.resolution_x=size; sc.render.resolution_y=size
    sc.render.resolution_percentage=100; sc.render.filepath=path
    bpy.ops.render.render(write_still=True)

def tex_png(game, kind, base, folder=None):
    sub={"unit":"units","building":"buildings","env":"env"}[kind]
    p=os.path.join(game,"data","materials",sub,folder or "",base+".dds")
    return p

def dds_to_png(src,dst,opaque):
    if os.path.exists(dst): return dst
    img=Image.open(src); img.load()
    img=img.convert("RGB") if opaque else img.convert("RGBA")
    img.save(dst,"PNG"); return dst

def bake_unit(game,out,key,base,size,samples,tmp):
    m=read_oss(os.path.join(game,"data","actors","units",base+".oss"))
    acts=read_aaf(os.path.join(game,"data","animations","aaf",base+".aaf"))
    plan=[]
    for action,names,n,loop in (("walk",("walk","walk0"),6,True),
                                ("idle",("idle","idle0"),2,True),
                                ("attack",("attack0","attack"),6,False),
                                ("death",("death",),6,False)):
        rng=next((acts[x] for x in names if x in acts),None)
        if rng: plan.append((action,sample(rng,n),loop,(rng[1]-rng[0]+1)/max(1,m["fps"])))
    if not plan: return False
    frames=[]
    for action,frs,loop,dur in plan:
        for fr in frs: frames.append((action,fr))
    skinned=[skin(m,fr) for _,fr in frames]
    lo=Vector((1e9,)*3); hi=Vector((-1e9,)*3)
    for s in skinned:
        for x,y,z in s:
            lo=Vector((min(lo.x,x),min(lo.y,y),min(lo.z,z))); hi=Vector((max(hi.x,x),max(hi.y,y),max(hi.z,z)))
    center=(lo+hi)*0.5; ortho=max(hi.x-lo.x,hi.y-lo.y,hi.z-lo.z)*1.12
    png=dds_to_png(tex_png(game,"unit",base),os.path.join(tmp,base+".png"),True)
    setup_scene(); mat=make_mat(png); ob=build_mesh(m,mat)
    me=ob.data; co=[c for v in m["verts"] for c in v]
    entry={"cell":size,"actions":{}}
    for action,frs,loop,dur in plan:
        sheet=Image.new("RGBA",(size*8,size*len(frs)),(0,0,0,0))
        for ri,fr in enumerate(frs):
            verts=skinned[frames.index((action,fr))]
            me.vertices.foreach_set("co",[c for v in verts for c in v]); me.update()
            for d in range(8):
                cam=camera(center,d*45.0,ortho)
                cell=os.path.join(tmp,"cell.png"); render_cell(cell,size)
                sheet.paste(Image.open(cell).convert("RGBA"),(d*size,ri*size))
                bpy.data.objects.remove(cam,do_unlink=True)
        sheet.save(os.path.join(out,"%s_%s.png"%(key,action)))
        entry["actions"][action]={"frames":len(frs),"duration":round(dur,3),"loop":loop}
    bpy.data.objects.remove(ob,do_unlink=True)
    return entry

def read_osm_first(path):
    with open(path,"rb") as f:
        h=dict(zip(["magic","version","sw","sh","fs","ns","nv","nu","nt","ng","nf","os","ou","ot","of","og","oe"],struct.unpack("<17i",f.read(68))))
        f.seek(h["ou"]); uvs=[struct.unpack("<2f",f.read(8)) for _ in range(h["nu"])]
        f.seek(h["ot"]); tris=[]; tuv=[]
        for _ in range(h["nt"]):
            i=struct.unpack("<6i",f.read(24)); tris.append((i[0],i[2],i[1])); tuv.append((i[3],i[5],i[4]))
        f.seek(h["of"]); f.read(16)
        verts=[struct.unpack("<3fI",f.read(16))[:3] for _ in range(h["nv"])]
    return dict(verts=verts,faces=tris,uvs=uvs,uvf=tuv)

def bake_building(game,out,nat,bld,size,tmp):
    cands=[(nat,nat+bld),( "commoneur","eur"+bld),("commontur","tur"+bld)]
    pick=None
    for folder,base in cands:
        if os.path.exists(os.path.join(game,"data","actors","buildings",folder,base+".osm")):
            pick=(folder,base); break
    if not pick: return False
    folder,base=pick
    m=read_osm_first(os.path.join(game,"data","actors","buildings",folder,base+".osm"))
    png=dds_to_png(os.path.join(game,"data","materials","buildings",folder,base+".dds"),os.path.join(tmp,base+".png"),True)
    xs=[v[0] for v in m["verts"]]; ys=[v[1] for v in m["verts"]]; zs=[v[2] for v in m["verts"]]
    center=Vector(((min(xs)+max(xs))/2,(min(ys)+max(ys))/2,(min(zs)+max(zs))/2))
    ortho=max(max(xs)-min(xs),max(ys)-min(ys),max(zs)-min(zs))*1.12
    setup_scene(); mat=make_mat(png); ob=build_mesh(m,mat)
    cam=camera(center,0.0,ortho)  # single south view, like existing sprites
    render_cell(os.path.join(out,"%s_%s.png"%(nat,bld)),size)
    for s in range(1,5):
        p=os.path.join(game,"data","actors","buildings",folder,"%s%d.osm"%(base,s))
        if os.path.exists(p):
            ms=read_osm_first(p)
            me=ob.data
            me.vertices.foreach_set("co",[c for v in ms["verts"] for c in v]) if len(ms["verts"])==len(m["verts"]) else None
            if len(ms["verts"])==len(m["verts"]):
                me.update(); render_cell(os.path.join(out,"%s_%s_s%d.png"%(nat,bld,s)),size)
    p=os.path.join(game,"data","actors","buildings",folder,base+"_death2.osm")
    if os.path.exists(p):
        ms=read_osm_first(p)
        if len(ms["verts"])==len(m["verts"]):
            ob.data.vertices.foreach_set("co",[c for v in ms["verts"] for c in v]); ob.data.update()
            render_cell(os.path.join(out,"%s_%s_dead.png"%(nat,bld)),size)
    bpy.data.objects.remove(cam,do_unlink=True); bpy.data.objects.remove(ob,do_unlink=True)
    return True

def main():
    a=parse_args(); os.makedirs(a.out,exist_ok=True)
    tmp=os.path.join(a.out,"tmp"); os.makedirs(tmp,exist_ok=True)
    idx_path=os.path.join(a.out,"index.json")
    idx=json.load(open(idx_path)) if os.path.exists(idx_path) else {}
    if a.buildings:
        for nat in a.nations.split(","):
            for bld in ("cen","hou","bar","sta","bla","aca","art","sto","mil","mar","tow"):
                try:
                    if bake_building(a.game,a.out,nat,bld,320,tmp): print("bld",nat,bld,flush=True)
                except Exception as e: print("FAIL bld",nat,bld,e,flush=True)
        return 0
    table={"peasant":"peaukr","pikeman":"pikeman","pikeman18":"pikeman18",
      "roundshier":"roundshier","musketeer":"musketeer","serdiuk":"serdiuk","strelet":"strelet",
      "archer":"archer","grenadier":"grenadier","musk18":"musketeer18","lightinfantry":"lightinfantry",
      "officer":"officer","officer18":"officer18","drummer":"drummer","drummer18":"drummer18",
      "priest":"priest","pope":"pope","padre":"padre","mullah":"mullah","bagpiper":"bagpiper",
      "cossack":"cossacksich","cossackdon":"cossackdon","cossackregister":"cossackregister",
      "dragoon17":"dragoon","dragoon":"dragoon18","hussar":"hussar","wingedhussar":"wingedhussar",
      "cuirassier":"cuirassier","reiter":"reiter","lightcavalry":"lightcavalry","hackapell":"hackapell",
      "tatar":"tatar","sipahi":"sipahi","spakh":"spakh","mameluke":"mameluke","vityaz":"vityaz",
      "hetman":"hetman","croat":"croat","pandur":"pandur","chasseur":"chasseur","highlander":"highlander",
      "jannisary":"jannisary","cannon":"cannon","howitzer":"howitzer","mortar":"mortar","multicannon":"multicannon"}
    for nat,base in (("ukr","peaukr"),("rus","pearus"),("pol","peapol"),("aus","peaaus"),
                     ("eng","peaeng"),("spa","peaspa"),("tur","peatur"),("sco","peasco")):
        table[nat+"_peasant"]=base
    only=set(x for x in a.only.split(",") if x)
    for key,base in table.items():
        if only and key not in only: continue
        try:
            e=bake_unit(a.game,a.out,key,base,a.size,a.samples,tmp)
            if e: idx[key]=e; json.dump(idx,open(idx_path,"w"),indent=1); print("unit",key,flush=True)
        except Exception as ex: print("FAIL unit",key,ex,flush=True)
    return 0

sys.exit(main())
```

Notes / traps:
- `frames.index((action,fr))` is O(n²) but n≈20 — fine.
- Stage meshes may have DIFFERENT vert counts than finished; the code skips
  them then. If stages skipped for a nation, fallback: draw finished sprite
  with scaffold tint (step 3 handles missing files gracefully). If you want
  stages with different topology, rebuild mesh per stage instead (optional).
- Camera azimuth convention MUST stay `d*45` with elevation 32° to match
  `_sprite_for` dir indexing (0 = +X east, same as existing static sprites).
- Same `center`/`ortho` for ALL frames/dirs of a unit → cells align, feet stay
  put. Do not "improve" per-frame framing.
- Run in background; ~0.2 s/cell EEVEE. Phase A (12 sids) ≈ 1900 cells ≈ 7 min.

Commands:
```
# Phase A — current roster gets real animations first:
"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup --python app\tools\bake_sprites.py -- --game "C:\Games\Cossacks 3" --out app\assets\models\anim --only peasant,pikeman,roundshier,serdiuk,archer,cossack,dragoon,officer,cannon,drummer,priest,grenadier,musk18,howitzer,mortar
# Phase B — everything else (background, can run while you do step 3):
... same without --only
# Buildings all nations:
... --buildings
godot --headless --path app --import
```
Acceptance: `app/assets/models/anim/index.json` has entries; open
`peasant_walk.png` — 8 cols × 6 rows, transparent bg, walking poses differ per
row, directions differ per col. `ukr_cen.png`, `rus_cen.png` visibly different.

## 5. STEP 2 — wire animation into world.gd + game.gd

Backup both files first. Edits:

game.gd:
1. `spawn()` dict: add `"death_t": -1.0, "fire_t": -1.0`.
2. Find where a shot is fired (grep `post_event("shot"` / cooldown reset in
   `_tick_unit` combat branch): set `e.fire_t = time` (grep `var time` — if the
   sim has no clock, add `var time := 0.0` and `time += dt` at top of `tick`).
3. `_kill()`: set `e.death_t = time` on the corpse entity (corpses are separate
   dicts with `sid` — add the field there too).

world.gd:
1. Add vars: `var anim_index := {}`, `var anim_tex := {}`.
2. In `bind()` after `_load_sprites()`:
```
var j := FileAccess.get_file_as_string("res://assets/models/anim/index.json")
if j != "": anim_index = JSON.parse_string(j)
```
3. Helpers:
```
func _anim_key(sid: String, player: int) -> String:
	var nat := "%s_%s" % [Data.PLAYER_NATIONS[player], sid]
	return nat if anim_index.has(nat) else sid

func _anim_action(e: Dictionary) -> String:
	if e.get("death_t", -1.0) >= 0.0: return "death"
	var o: Dictionary = e.order
	if o.type == "attack" and e.get("fire_t", -1.0) >= 0.0 and anim_t - e.fire_t < 0.9: return "attack"
	if (o.type == "gather" or o.type == "build") and e.get("hit_t", 0.0) > 0.0: return "attack"
	if e.get("moving", false): return "walk"
	return "idle"

func _draw_anim(e: Dictionary, p: Vector2, tint: Color) -> bool:
	var key := _anim_key(e.sid, e.player)
	var info: Dictionary = anim_index.get(key, {})
	if info.is_empty(): return false
	var act := _anim_action(e)
	var a: Dictionary = info.actions.get(act, info.actions.get("idle", {}))
	if a.is_empty(): return false
	var tk := key + "_" + act
	if not anim_tex.has(tk):
		var path := "res://assets/models/anim/%s.png" % tk
		if not FileAccess.file_exists(path): return false
		anim_tex[tk] = load(path)
	var tex: Texture2D = anim_tex[tk]
	var cell: int = info.cell
	var n: int = a.frames
	var t0: float = e.get("death_t", -1.0) if act == "death" else (e.get("fire_t", -1.0) if act == "attack" and e.order.type == "attack" else -1.0)
	var fi: int
	if t0 >= 0.0: fi = mini(n - 1, int((anim_t - t0) / maxf(0.05, a.duration) * n))
	else: fi = int(anim_t / maxf(0.05, a.duration) * n) % n
	var dir := int(fposmod(roundf(float(e.get("face", 0.0)) / (PI / 4.0)), 8.0)) % 8
	var src := Rect2(dir * cell, fi * cell, cell, cell)
	var world_h := _unit_height(e)
	var sc: float = world_h * view_scale / float(cell)
	var sz := Vector2(cell, cell) * sc
	var tl := p - Vector2(sz.x * 0.5, sz.y * 0.82)
	unit_layer.draw_texture_rect_region(tex, Rect2(tl, sz), src, tint)
	return true
```
4. Unit draw branch (~L636): BEFORE the `_sprite_for` fallback, call
   `if _draw_anim(e, pb, tint): ...skip old sprite draw...` (restructure the
   match so animated units return early; keep procedural fallback intact).
5. Corpse draw (~L765): if `anim_index` has key with "death", draw last death
   frame (fi = n-1, same region math, tint fade) instead of darkened sprite.
6. Buildings (~L422): key = `"%s_%s" % [Data.PLAYER_NATIONS[e.player], e.sid]`;
   probe `sprites/%s.png % key` in `_load_sprites` too (add nation keys loop:
   for nat in Data.NATIONS, for sid in Data.BUILDINGS: probe nat_sid). If
   `not e.finished`: pick stage `s1..s4` by `int(e.progress / e.def.build_time * 4)`
   (clamp 0..3; if stage file missing use finished sprite with
   `Color(0.8,0.8,0.8,0.9)` tint + existing scaffold overlay). Destroyed
   buildings: optional rubble — if you keep a corpse-like entity, use
   `%s_dead.png`.
7. Delete SPRITE_ALIAS entries for sids that now have real anim (musk18,
   grenadier, officer18, drummer, priest, howitzer, mortar) — keep alias as
   fallback ONLY if anim missing (check `anim_index.has(sid)` first).

Acceptance: `godot --path app -- --screenshot app/shots/anim.png --timeout 90`
shows textured marching peasants (not circles); self-test still passes:
`godot --headless --path app -- --self-test app/selftest.json`.

## 6. STEP 3 — roster & nation variety (data.gd)

Add to UNITS_BASE (style-copy existing entries; stats marked estimated unless
wiki-sourced; keep donor formula compat: prot array 6 slots, prices, eat):
- pikeman18 (hp 120, pike 10, prot bullet 8; est), musketeer (=serdiuk stats,
  no_melee true), strelet (=serdiuk, rus), dragoon17 (hp 200, bullet 15, hard
  horse), hussar (fast cav hp 220 sword 15), wingedhussar (fast cav hp 260
  pike 18, pol), cuirassier (hard cav hp 300 sword 20), reiter (hard cav
  bullet 14), lightcavalry (fast hp 180), lightinfantry (bullet 10, cheap),
  tatar (fast cav ARROW 12, mounted archer), sipahi (hard cav hp 260),
  jannisary (bullet 14, tur), spakh/mameluke (tur/alg cav), vityaz (rus heavy
  cav), hetman (ukr officer-cav), croat/pandur/chasseur (light inf variants),
  highlander/swordsmansco (sco melee), multicannon (cannister volley: use
  weapon kind cannister, dmg 600 close bands → simplify dmg 300 splash 60,
  est), priest variants pope/padre/mullah (=priest), drummer18 (=drummer).
- Add `"no_melee": true` to serdiuk/archer/musketeer/strelet/lightinfantry/
  jannisary/tatar? (tatar mounted archer also no melee) — 17c ranged.
- Add melee sword weapon to musk18 + grenadier (bayonet, dmg 8, 25–60 px).
- drummer: `"search": 6000 * PX_TO_M` (wiki sight 6000).
- NATIONS: add `"no18c": true` for tur, alg.
- NATION_UNITS override map (train lists): rus bar→strelet instead of serdiuk,
  sta→cossackdon+dragoon17; pol sta→wingedhussar+dragoonpol(use dragoon18
  mesh); tur bar→jannisary, sta→sipahi+tatar, priest→mullah; alg≈tur; swe
  sta→hackapell; ukr sta→cossackregister+cossacksich; generic eu bar→musketeer.
  Implement in `train_unit`/HUD train buttons: resolve sid via
  `NATION_UNITS[nat].get(sid, sid)`; keep sim sids stable by spawning the
  resolved sid (add resolved entries to UNITS).
- Peasants: spawn resolves `nat_peasant` sid for visuals but SAME stats:
  simplest = keep sid "peasant", world._anim_key already tries nat_peasant.

Acceptance: menu pick Turkey → barracks trains janissaries; screenshot shows
tur_cen architecture; self-test passes.

## 7. STEP 4 — mechanics from research (game.gd / data.gd)

Numbers sourced in reference/videos.md; mark new estimates in mechanics.json.
1. Formation sizes & gate: `squad_form` snaps member count to
   [15,36,72,120,196,400] (inf) / [40,90,160] (cav, no officer req); infantry
   requires officer AND drummer present. Overflow stays loose.
2. Formation bonuses: store on squad dict; attacker in formed squad: melee
   +2 dmg, ranged +2; defender prot +3; if `e.hold` (stand ground): melee
   +9/+9, ranged +2/+9. Apply in `effective_damage` (attacker) and where
   `apply_damage` is called (defender prot bonus param).
3. Replenish: `cmd_replenish(officer)` absorbs loose same-type units within
   6 m up to current formation size; HUD button on officer panel.
4. Academy gate: `train_unit` officer/drummer/priest? (priest stays bar) —
   officer+drummer require finished `aca` owned.
5. 17c ranged flee: in `_tick_unit` attack branch, if `def.no_melee` and
   dist < weapon.min: `e.order = {"type":"move","pos": e.pos + (e.pos-en.pos).normalized()*4.0}`.
6. Mine upgrade: UPGRADES_BASE `mine_up1` per mine building, cost wood 200
   stone 100, effect produce ×1.5 (est; reddit confirms existence).
7. Artillery battery: `formation_targets` spacing ×3 for artillery sids.
8. Cavalry wedge: FORMATIONS add "wedge" (triangular rows) for cav squads.
9. Capture rule toggle: config.json `rules.peasant_capture` (default true);
   menu checkbox optional.
10. AI opener: ai.gd — prioritize iron mine after first barracks if
    pike-heavy; research food gather upgrade earlier (threshold tweak).

Acceptance: self-test steps squad/formation still pass; add selftest assertions
for flee + formation bonus if cheap (selftest.gd pattern exists); cli 10 s runs
clean; windowed screenshot shows formed lines with officer+drummer.

## 8. STEP 5 — polish & final verification

1. Corpses use death sheets (step 2.5); remove old darkened-sprite corpse path
   only when anim present.
2. Construction stages visible (step 2.6); verify stage ORDER visually
   (s1 should look like scaffold; if reversed, map 4→1).
3. `godot --headless --path app -- --cli app/cli.json --cli-seconds 30` — no
   errors, both AIs build/attack.
4. `godot --path app -- --screenshot app/shots/final.png --timeout 90` —
   compare against reference/videos.md expectations: textured animated
   units, nation buildings, fields/forest, HUD intact.
5. Update app/MECHANICS.md + mechanics.json with new values (source/estimated
   tags), README.md feature list, CREDITS.md (new original files used:
   animations/aaf, nation buildings).
6. Keep never-hang: every godot invocation in tests uses a self-exiting flag.

## 9. Budget / order summary

1. Step 1 Phase A bake (background ~7 min) → 2. Step 2 wiring → 3. screenshot
check → 4. Step 1 Phase B + buildings (background) → 5. Step 3 roster →
6. Step 4 mechanics → 7. Step 5 polish/tests/docs.
If tokens run short: STOP after Step 2 (animated core roster already makes the
clone look dramatically closer). Steps 3–4 are incremental, each independently
shippable. Never leave the project in a state where self-test fails.
