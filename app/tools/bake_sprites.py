#!/usr/bin/env python3
"""Bake ANIMATED 8-direction sprite sheets from original .oss meshes.
Run: blender.exe --background --factory-startup --python tools/bake_sprites.py -- \
     --game "C:\\Games\\Cossacks 3" --out assets/models/anim [--only sid,sid] [--size 160]
Sheets: <key>_<action>.png, cols=8 dirs (0,45..315), rows=sampled frames.
index.json: {key: {"cell": N, "actions": {action: {"frames": n, "duration": s, "loop": bool}}}}
GUIDE1.md (docs/guides) Step 1. Minimal syntax fixes vs plan draft:
- attack names ("attack0","attack") -> ("attack0","attack1","attack") (missing comma in draft = implicit concat)
- bake_building cands inner tuples missing comma fixed
- bake_building center Vector missing commas fixed
"""
import argparse, json, math, os, struct, sys
_BLENDER_PY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blender_py")
if os.path.isdir(_BLENDER_PY) and _BLENDER_PY not in sys.path:
    sys.path.insert(0, _BLENDER_PY)
import bpy
from mathutils import Vector
from PIL import Image

# GPU-SAFE defaults: Cycles on CPU never touches the (weak) GPU.
# Overridden from CLI in main().
_ENGINE = "cycles"
_SAMPLES = 4

def parse_args():
    rest = sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--only", default=""); ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="cycles", choices=["cycles", "eevee", "workbench"])
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
    """Frames a..b in DONOR ORDER. Keep every frame when the action is short:
    decimating a 20-frame walk to 6 poses made movement look strange."""
    a,b=rng
    if b<=a: return [a]
    total=b-a+1
    if total<=n: return list(range(a,b+1))
    return [a+round((b-a)*i/(n-1)) for i in range(n)] if n>1 else [a]

def setup_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    w=bpy.data.worlds.new("w"); bpy.context.scene.world=w; w.use_nodes=True
    sc=bpy.context.scene
    if _ENGINE == "workbench":
        sc.render.engine="BLENDER_WORKBENCH"
        try:
            sc.display.shading.light="FLAT"
            sc.display.shading.color_type="TEXTURE"
            sc.display.shading.show_shadows=False
            sc.display.shading.show_cavity=False
        except Exception: pass
    elif _ENGINE == "eevee":
        try: sc.render.engine="BLENDER_EEVEE_NEXT"
        except Exception: sc.render.engine="BLENDER_EEVEE"
        try: sc.eevee.taa_render_samples=max(1,_SAMPLES)
        except Exception: pass
    else:
        # CPU-only Cycles: no GPU load; shadeless emission looks identical.
        sc.render.engine="CYCLES"
        try: sc.cycles.samples=max(1,_SAMPLES)
        except Exception: pass
        try: sc.cycles.device="CPU"
        except Exception: pass
        try: sc.cycles.use_denoising=False
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
    # The donor AAF has DISTINCT actions for combat and for work. Reusing
    # "attack0" for chopping/carrying (the old port) made peasants dance.
    plan=[]
    for action,names,n,loop in (("walk",("walk","walk0"),12,True),
                                 ("idle",("idle","idle0"),6,True),
                                 ("attack",("attack0","attack1","attack"),12,False),
                                 ("workwood",("workwood",),10,True),
                                 ("workfood",("workfood",),10,True),
                                 ("workstone",("workstone",),10,True),
                                 ("construct",("construct",),8,True),
                                 ("death",("death",),8,False)):
        rng=next((acts[x] for x in names if x in acts),None)
        if rng:
            frs=sample(rng,n)
            plan.append((action,frs,loop,(rng[1]-rng[0]+1)/max(1,m["fps"])))
    if not plan: return False
    frames=[]
    for action,frs,loop,dur in plan:
        for fr in frs: frames.append((action,fr))
    # In-place locomotion, tracked on the torso bone (the bone carrying the
    # most vertices): the donor engine moves the entity while the animation
    # plays in place, but the .oss walk keys (horse gallop: 6m per cycle at
    # 3.6 m/s) carry travel.  Subtracting the torso's per-frame XZ delta keeps
    # every frame centred (no sliding across the cell, tight union bboxes).
    # Bone 0 is NOT the root for horses (it barely moves).
    torso=0; best=-1.0
    for bi in range(len(m["anim"])):
        wsum=sum(w for vw in m["weights"] for b2,w in vw if b2==bi)
        if wsum>best: best=wsum; torso=bi
    skinned_all={}
    for action,frs,loop,dur in plan:
        ref=(m["anim"][torso][frs[0]][0],m["anim"][torso][frs[0]][1])
        for fr in frs:
            if fr in skinned_all: continue
            s=skin(m,fr)
            rx,ry=(m["anim"][torso][fr][0]-ref[0],m["anim"][torso][fr][1]-ref[1])
            skinned_all[fr]=[(x-rx,y-ry,z) for x,y,z in s]
    png=dds_to_png(tex_png(game,"unit",base),os.path.join(tmp,base+".png"),True)
    setup_scene(); mat=make_mat(png); ob=build_mesh(m,mat)
    me=ob.data
    entry={"cell":size,"actions":{}}
    for action,frs,loop,dur in plan:
        # Per-action framing: every action gets its own centre+ortho from its
        # own in-place union (walk bodies fill walk cells even though attack
        # swings span 5m).  One shared ortho shrank everyday bodies to ~40%
        # of the cell; true-scale drawing keeps world sizes exact across
        # actions (see world.gd _draw_anim).
        lo=Vector((1e9,)*3); hi=Vector((-1e9,)*3)
        for fr in frs:
            for x,y,z in skinned_all[fr]:
                lo=Vector((min(lo.x,x),min(lo.y,y),min(lo.z,z))); hi=Vector((max(hi.x,x),max(hi.y,y),max(hi.z,z)))
        center=(lo+hi)*0.5; ortho=max(hi.x-lo.x,hi.y-lo.y,hi.z-lo.z)*1.12
        sheet=Image.new("RGBA",(size*8,size*len(frs)),(0,0,0,0))
        for ri,fr in enumerate(frs):
            verts=skinned_all[fr]
            me.vertices.foreach_set("co",[c for v in verts for c in v]); me.update()
            for d in range(8):
                cam=camera(center,d*45.0,ortho)
                cell=os.path.join(tmp,"cell.png"); render_cell(cell,size)
                img=Image.open(cell).convert("RGBA")
                sheet.paste(img,(d*size,ri*size),img)
                bpy.data.objects.remove(cam,do_unlink=True)
        sheet.save(os.path.join(out,"%s_%s.png"%(key,action)))
        entry["actions"][action]={"frames":len(frs),"duration":round(dur,3),"loop":loop,
            "ortho":round(ortho,3),
            "center":[round(center.x,3),round(center.y,3),round(center.z,3)]}
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

def bake_building(game,out,nat,bld,size,tmp,out_sid=""):
    cands=[(nat,nat+bld),("commoneur","eur"+bld),("commontur","tur"+bld)]
    pick=None
    for folder,base in cands:
        if os.path.exists(os.path.join(game,"data","actors","buildings",folder,base+".osm")):
            pick=(folder,base); break
    if not pick: return False
    folder,base=pick
    sid_name = out_sid if out_sid else bld
    m=read_osm_first(os.path.join(game,"data","actors","buildings",folder,base+".osm"))
    png=dds_to_png(os.path.join(game,"data","materials","buildings",folder,base+".dds"),os.path.join(tmp,base+".png"),True)
    xs=[v[0] for v in m["verts"]]; ys=[v[1] for v in m["verts"]]; zs=[v[2] for v in m["verts"]]
    center=Vector(((min(xs)+max(xs))/2,(min(ys)+max(ys))/2,(min(zs)+max(zs))/2))
    ortho=max(max(xs)-min(xs),max(ys)-min(ys),max(zs)-min(zs))*1.12
    setup_scene(); mat=make_mat(png); ob=build_mesh(m,mat)
    cam=camera(center,0.0,ortho)
    render_cell(os.path.join(out,"%s_%s.png"%(nat,sid_name)),size)
    ob.hide_render = True  # stages/rubble render alone, not inside the finished mesh
    for s in range(1,5):
        p=os.path.join(game,"data","actors","buildings",folder,"%s%d.osm"%(base,s))
        if os.path.exists(p):
            ms=read_osm_first(p)
            mo=build_mesh(ms,mat)
            render_cell(os.path.join(out,"%s_%s_s%d.png"%(nat,sid_name,s)),size)
            bpy.data.objects.remove(mo,do_unlink=True)
    p=os.path.join(game,"data","actors","buildings",folder,base+"_death2.osm")
    if os.path.exists(p):
        ms=read_osm_first(p)
        mo=build_mesh(ms,mat)
        render_cell(os.path.join(out,"%s_%s_dead.png"%(nat,sid_name)),size)
        bpy.data.objects.remove(mo,do_unlink=True)
    ob.hide_render = False
    bpy.data.objects.remove(cam,do_unlink=True); bpy.data.objects.remove(ob,do_unlink=True)
    return True

def main():
    global _ENGINE, _SAMPLES
    a=parse_args(); a.game=os.path.abspath(a.game); a.out=os.path.abspath(a.out)
    _ENGINE=a.engine; _SAMPLES=a.samples
    os.makedirs(a.out,exist_ok=True)
    tmp=os.path.join(a.out,"tmp"); os.makedirs(tmp,exist_ok=True)
    idx_path=os.path.join(a.out,"index.json")
    idx=json.load(open(idx_path)) if os.path.exists(idx_path) else {}
    if a.buildings:
        for nat in a.nations.split(","):
            for bld,sid_name in (("cen","cen"),("hou","hou"),("bar","bar"),("sta","sta"),("bla","bla"),("aca","aca"),("art","art"),("sto","sto"),("mil","mil"),("mar","mar"),("tow","tow"),("ba2","bar18"),("dip","dip")):
                try:
                    if bake_building(a.game,a.out,nat,bld,320,tmp,sid_name): print("bld",nat,sid_name,flush=True)
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
