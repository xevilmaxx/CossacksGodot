#!/usr/bin/env python3
"""Bake ANIMATED 8-direction sprite sheets from original .oss meshes.
Run: blender --background --factory-startup --python tools/bake_sprites.py -- \
     --game "C:\\Games\\Cossacks 3" --out assets/models/anim [--only sid,sid] [--size 160]
  Blender is found on PATH (a launcher can use shutil.which("blender")). On
  Linux/macOS set COSSACKS3_DIR or pass --game; --game defaults to
  $COSSACKS3_DIR (or C:\\Games\\Cossacks 3). Donor is private — never redistribute.
Sheets: <key>_<action>.png, cols=8 dirs (0,45..315), rows=sampled frames.
Default --layout nation writes sheets to <out>/<nation|common>/<units|buildings>/;
--layout flat keeps the legacy anim root. index.json stays in <out>/land_units/.
index.json: {key: {"cell": N, "actions": {action: {"frames": n, "duration": s, "loop": bool}}}}
GUIDE1.md (docs/guides) Step 1. Minimal syntax fixes vs plan draft:
- attack names ("attack0","attack") -> ("attack0","attack1","attack") (missing comma in draft = implicit concat)
- bake_building cands inner tuples missing comma fixed
- bake_building center Vector missing commas fixed
"""
import argparse, copy, json, math, os, struct, sys
from pathlib import Path

# Pure-python `--help` must parse without Blender installed, so defer the
# Blender-only imports when help was requested (no scene work happens then).
_WANT_HELP = any(a in ("-h", "--help") for a in sys.argv[1:])
if not _WANT_HELP:
    _BLENDER_PY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blender_py")
    if os.path.isdir(_BLENDER_PY) and _BLENDER_PY not in sys.path:
        sys.path.insert(0, _BLENDER_PY)
    import bpy
    from mathutils import Vector
    from PIL import Image
else:
    bpy = None
    Vector = None
    Image = None

# Portable donor-default: COSSACKS3_DIR overrides the historical Windows path.
DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")

# GPU-SAFE defaults: Cycles on CPU never touches the (weak) GPU.
# Overridden from CLI in main().
_ENGINE = "cycles"
_SAMPLES = 4

# T-BAKE-OPT: duplicate-key alias map. Both `peasant` and `ukr_peasant` resolve
# to donor base `peaukr` (see the table in main()), so their 14 action sheets
# are byte-identical. Bake/write the canonical once; other keys get a full
# metadata copy plus an `alias_of` marker in index.json instead of duplicate
# PNGs. Pass --no-alias to restore the old bake-every-key behaviour.
ALIAS_OF = {"peasant": "ukr_peasant"}

# Nation-first output layout. Every baked sheet is written under
# <nation>/<kind> or common/<kind>; index/metadata keep their old paths.
NATIONS = ("aus", "eng", "pol", "rus", "spa", "tur", "ukr", "bav", "den",
           "fra", "hun", "net", "pie", "por", "pru", "sax", "swe", "swi",
           "ven", "alg", "sco")

def nation_of(name):
    """Nation prefix of a sheet name, or "" for shared art (mirrors world.gd)."""
    stem = name[:-4] if name.endswith(".png") else name
    if len(stem) < 4 or stem[3] != "_":
        return ""
    p = stem[:3].lower()
    return p if p in NATIONS else ""

def sheet_out_dir(out, name, kind):
    """Nation-first target dir for one baked sheet."""
    nat = nation_of(name)
    return os.path.join(out, nat if nat else "common", kind)

def parse_args():
    # Under Blender the real arguments follow `--`; under plain
    # `python tools/bake_sprites.py ...` they are sys.argv[1:] (so --help works).
    rest = sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else sys.argv[1:]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="installed game folder (default: $COSSACKS3_DIR or "
                         "C:\\Games\\Cossacks 3)")
    ap.add_argument("--out", required=True); ap.add_argument("--only", default="")
    ap.add_argument("--size", type=int, default=160)
    ap.add_argument("--samples", type=int, default=4)
    ap.add_argument("--engine", default="cycles", choices=["cycles", "eevee", "workbench"])
    ap.add_argument("--buildings", action="store_true")
    ap.add_argument("--nations", default="ukr,rus,pol,aus,fra,eng,spa,swe,pru,ven,tur,alg,net,den,por,pie,sax,bav,hun,swi,sco")
    ap.add_argument("--layout", choices=["flat", "nested", "nation"], default="nation",
                    help="sheet layout: nation (default, out/<nation|common>/<kind>) "
                         "or flat (legacy out root); index.json stays in out/land_units/")
    ap.add_argument("--no-alias", action="store_true",
                    help="disable duplicate-sheet aliases (bake every key, "
                         "including `peasant`, as before)")
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
    # Donor rotations apply transposed (row-vector convention): with the
    # textbook matrix the right hand lands mirrored at (-0.98,-0.38,1.75)
    # and its tool 1.2 m away at idle; transposed, the hand hangs at
    # (+0.36,-0.03,0.85) with the tool gripped at (+0.27,+0.06,1.34).
    # Verified bone by bone against the bind pose (arms hang, tool in hand).
    M=((1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)),
       (2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)),
       (2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)))
    return ((M[0][0],M[1][0],M[2][0]),
            (M[0][1],M[1][1],M[2][1]),
            (M[0][2],M[1][2],M[2][2]))

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

def build_mesh(m, mat, m2=None, mat2=None):
    nB=len(m["verts"])
    av=list(m["verts"])+list(m2["verts"]) if m2 else list(m["verts"])
    af=list(m["faces"])+([(a+nB,b+nB,c+nB) for a,b,c in m2["faces"]]) if m2 else list(m["faces"])
    auv=list(m["uvs"])+list(m2["uvs"]) if m2 else list(m["uvs"])
    auvf=list(m["uvf"])+([(a+nB,b+nB,c+nB) for a,b,c in m2["uvf"]]) if m2 else list(m["uvf"])
    me=bpy.data.meshes.new("mesh"); me.from_pydata(av,[],af); me.update()
    uv=me.uv_layers.new(name="UVMap")
    for fi,tri in enumerate(af):
        for li in range(3):
            uv.data[fi*3+li].uv=auv[auvf[fi][li]]
    ob=bpy.data.objects.new("model",me); bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    if m2 and mat2:
        ob.data.materials.append(mat2)
        for i, poly in enumerate(ob.data.polygons):
            poly.material_index=0 if i < len(m["faces"]) else 1
    return ob

def camera_create():
    """T-BAKE-OPT: create the single ortho camera reused by an entire bake.

    The old loop created and destroyed a camera for every one of the 8 views
    of every frame. One camera per bake_unit()/bake_naval_unit() is retargeted
    with camera_set() instead; the rig (ortho, azimuth d*45 deg, elevation
    32 deg, 50 m distance) is identical, so pixels are unchanged.
    """
    cd=bpy.data.cameras.new("cam"); cd.type="ORTHO"; cd.ortho_scale=1.0
    cam=bpy.data.objects.new("cam",cd); bpy.context.collection.objects.link(cam)
    bpy.context.scene.camera=cam
    return cam

def camera_set(cam, center, az, ortho):
    """T-BAKE-OPT: retarget an existing camera to one donor view.

    Exact same maths as the old per-view camera() (8 azimuths d*45 deg,
    elevation 32 deg, same ortho_scale and 50 m offset), so the rendered
    pixels are byte-for-byte identical. view_layer.update() makes the new
    transform/depsgraph state visible to the renderer before render_cell().
    """
    cam.data.ortho_scale=ortho
    el=math.radians(32.0); azr=math.radians(az)
    pos=center+Vector((math.cos(azr)*math.cos(el),math.sin(azr)*math.cos(el),math.sin(el)))*50
    cam.location=pos
    cam.rotation_euler=(center-pos).normalized().to_track_quat("-Z","Y").to_euler()
    bpy.context.scene.camera=cam
    bpy.context.view_layer.update()
    return cam

def camera(center, az, ortho):
    """Create a fresh camera for one view (kept for single-view callers)."""
    return camera_set(camera_create(), center, az, ortho)

def ground_anchor_ay(cam, size):
    """Project the world origin (entity feet) into the cell.

    Returns (ax, ay) in 0..1 from top-left. With the camera centred at
    XZ=(0,0) the origin projects to x=0.5 for every azimuth and to a single
    y for the whole unit, so every action/dir shares one ground anchor:
    feet never slide when the pose changes (the old ink-union cx/foot moved
    with pikes and hammers, shifting soldiers off their tile).
    """
    from bpy_extras.object_utils import world_to_camera_view
    bpy.context.view_layer.update()
    sc=bpy.context.scene
    ndc=world_to_camera_view(sc, cam, Vector((0.0,0.0,0.0)))
    return (round(float(ndc.x),4), round(1.0-float(ndc.y),4))

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

def bake_unit(game,out,key,base,size,samples,tmp,out_dir=None):
    # out_dir lets the caller place sheets in a nation-first tree. Other
    # staging bakers omit it and keep writing flat into `out`.
    dest = out_dir if out_dir is not None else out
    os.makedirs(dest,exist_ok=True)
    m=read_oss(os.path.join(game,"data","actors","units",base+".oss"))
    acts=read_aaf(os.path.join(game,"data","animations","aaf",base+".aaf"))
    # Donor clips, in priority order. attack1 is the musket volley (musketeer,
    # serdiuk, grenadier...); attack0 is pike/sword melee. Preferring attack0
    # gave gunpowder units a melee lunge for "attack". Peasant carry/idle
    # variants (walkwood/idlewood/...) are baked so loaded peasants no longer
    # walk empty-handed.
    plan=[]
    for action,names,n,loop in (("walk",("walk",),12,True),
                                 ("idle",("idle","idle0"),6,True),
                                 ("attack",("attack1","attack0","attack2","attack"),12,False),
                                 ("workwood",("workwood",),10,True),
                                 ("workfood",("workfood",),10,True),
                                 ("workstone",("workstone",),10,True),
                                 ("construct",("construct",),8,True),
                                 ("walkwood",("walkwood",),10,True),
                                 ("walkfood",("walkfood",),10,True),
                                 ("walkstone",("walkstone",),10,True),
                                 ("idlewood",("idlewood",),6,True),
                                 ("idlefood",("idlefood",),6,True),
                                 ("idlestone",("idlestone",),6,True),
                                 ("death",("death","death0","death1"),8,False)):
        rng=next((acts[x] for x in names if x in acts),None)
        if rng:
            frs=sample(rng,n)
            plan.append((action,frs,loop,(rng[1]-rng[0]+1)/max(1,m["fps"])))
    if not plan: return False
    # In-place locomotion, tracked on skeleton root (bone 0 = hips/pelvis,
    # the stable central bone; the bind pose is already centred at the
    # origin with feet at z~0). Never use the max-weight bone here: on the
    # peasant that is the HEAD/HAT (z 1.6..2.0), and pinning the head blows
    # the union to ~6 m and makes the body swing around the hat.
    # Reference (HOME) is global for all standing clips, per-clip for death
    # (see below).
    root = 0
    skinned_all={}
    # HOME is the unit's defined position: root at the first idle frame
    # (bind-adjacent stance, feet at the origin). Every standing frame is
    # re-based to HOME, so Builder/work clips that roam metres around their
    # station (workfood spans y -1..+3: pacing around the field) render
    # centred on the entity instead of dragging the union to ~8 m. The roam
    # itself is entity motion in the donor, not sprite motion. Death keeps a
    # per-clip reference (its first frame ≈ standing): a fall must play out
    # relative to where the unit stood, not be pinned upright.
    idle_home = None
    for action, frs, loop, dur in plan:
        if action in ("idle",) and idle_home is None:
            idle_home = (m["anim"][root][frs[0]][0], m["anim"][root][frs[0]][1])
    if idle_home is None:
        idle_home = (m["anim"][root][plan[0][1][0]][0], m["anim"][root][plan[0][1][0]][1])
    for action, frs, loop, dur in plan:
        if action == "death":
            ref = (m["anim"][root][frs[0]][0], m["anim"][root][frs[0]][1])
        else:
            ref = idle_home
        for fr in frs:
            if fr in skinned_all: continue
            s = skin(m, fr)
            rx, ry = (m["anim"][root][fr][0] - ref[0], m["anim"][root][fr][1] - ref[1])
            skinned_all[fr] = [(x - rx, y - ry, z) for x, y, z in s]
    # Attached props: the donor keeps hand tools as SEPARATE meshes
    # (data/actors/units/attach/<base>_<tool>.oss: axe, hammer, hoe, pick,
    # bag, lumber, cart), each with its own single-bone 483-frame track over
    # the same AAF timeline. The action picks the tool: axe for chopping,
    # hammer for building, hoe/pick for field/mine, lumber/bag/cart for the
    # loaded carry walks and idles. Without them the peasant's hands are
    # empty - the stub verts inside the body mesh are NOT the tool.
    ATTACH_ACTIONS={"axe": ["workwood", "attack"], "hammer": ["construct"],
        "hoe": ["workfood"], "pick": ["workstone"],
        "lumber": ["walkwood", "idlewood"], "bag": ["walkfood", "idlefood"],
        "cart": ["walkstone", "idlestone"]}
    attach_mesh={}
    def attach_for(action):
        for _tool, _acts in ATTACH_ACTIONS.items():
            if action in _acts:
                return _tool
        return None
    def attach_load(tool):
        _key=(base, tool)
        if _key not in attach_mesh:
            _p=os.path.join(game, "data", "actors", "units", "attach", "%s_%s.oss" % (base, tool))
            attach_mesh[_key]=read_oss(_p) if os.path.exists(_p) else None
        return attach_mesh[_key]
    skinned_tool={}
    for _action, _frs, _loop, _dur in plan:
        _tool=attach_for(_action)
        if not _tool:
            continue
        _am=attach_load(_tool)
        if not _am:
            continue
        if _action == "death":
            _r2=(m["anim"][root][_frs[0]][0], m["anim"][root][_frs[0]][1])
        else:
            _r2=idle_home
        for _fr in _frs:
            if (_fr, _tool) in skinned_tool:
                continue
            _M=qmat(*_am["anim"][0][_fr][3:])
            _pp=_am["anim"][0][_fr][:3]
            _rx, _ry=(m["anim"][root][_fr][0]-_r2[0], m["anim"][root][_fr][1]-_r2[1])
            skinned_tool[(_fr, _tool)]=[(_M[0][0]*x+_M[0][1]*y+_M[0][2]*z+_pp[0]-_rx,
                _M[1][0]*x+_M[1][1]*y+_M[1][2]*z+_pp[1]-_ry,
                _M[2][0]*x+_M[2][1]*y+_M[2][2]*z+_pp[2]) for x, y, z in _am["verts"]]
    def tool_of(action):
        _t=attach_for(action)
        _a=attach_load(_t) if _t else None
        return (_t, _a) if _a else (None, None)
    # unions/framing include the attached prop of each action
    def union_of_group(group):
        lo=Vector((1e9,)*3); hi=Vector((-1e9,)*3)
        for _action, _frs, _loop, _dur in plan:
            _g="death" if _action == "death" else "stand"
            if _g != group:
                continue
            _t, _a=tool_of(_action)
            for _fr in _frs:
                _seqs=[skinned_all[_fr]]
                if _t and (_fr, _t) in skinned_tool:
                    _seqs.append(skinned_tool[(_fr, _t)])
                for _sq in _seqs:
                    for x,y,z in _sq:
                        if x<lo.x: lo.x=x
                        if y<lo.y: lo.y=y
                        if z<lo.z: lo.z=z
                        if x>hi.x: hi.x=x
                        if y>hi.y: hi.y=y
                        if z>hi.z: hi.z=z
        return lo,hi
    def projected_ortho_group(group, center):
        import math as _math
        el=_math.radians(32.0); ce=_math.cos(el); se=_math.sin(el)
        worst=1e-6
        for d in range(8):
            az=_math.radians(d*45.0); ca=_math.cos(az); sa=_math.sin(az)
            rx,ry,rz=(-sa,ca,0.0)
            bx,by,bz=(ca*ce,sa*ce,se)
            ux,uy,uz=(by*rz-bz*ry,bz*rx-bx*rz,bx*ry-by*rx)
            x0=y0=1e9; x1=y1=-1e9
            for _action, _frs, _loop, _dur in plan:
                _g="death" if _action == "death" else "stand"
                if _g != group:
                    continue
                _t, _a=tool_of(_action)
                for _fr in _frs:
                    _seqs=[skinned_all[_fr]]
                    if _t and (_fr, _t) in skinned_tool:
                        _seqs.append(skinned_tool[(_fr, _t)])
                    for _sq in _seqs:
                        for x,y,z in _sq:
                            dx,dy,dz=(x-center[0],y-center[1],z-center[2])
                            px=dx*rx+dy*ry+dz*rz; py=dx*ux+dy*uy+dz*uz
                            if px<x0: x0=px
                            if px>x1: x1=px
                            if py<y0: y0=py
                            if py>y1: y1=py
            worst=max(worst,2.0*max(abs(x0),abs(x1),abs(y0),abs(y1)))
        return worst*1.12
    def union_of(frlist):
        lo=Vector((1e9,)*3); hi=Vector((-1e9,)*3)
        for fr in frlist:
            for x,y,z in skinned_all[fr]:
                if x<lo.x: lo.x=x
                if y<lo.y: lo.y=y
                if z<lo.z: lo.z=z
                if x>hi.x: hi.x=x
                if y>hi.y: hi.y=y
                if z>hi.z: hi.z=z
        return lo,hi
    def projected_ortho(frlist, center):
        # Exact 2D extents: project every skinned vertex of every frame onto
        # the orthographic camera plane for all 8 azimuths (elevation 32 deg,
        # the same rig `camera()` builds in Blender) and fit the widest span.
        # Axis-aligned 3D bounds * 1.4 underestimate diagonal views (a long
        # cannon barrel at 45 deg spans the full cell), while over-padding
        # compact poses. Measured projection + 12 % AA bleed is tight and
        # never clips.
        import math as _math
        el=_math.radians(32.0); ce=_math.cos(el); se=_math.sin(el)
        worst=1e-6
        for d in range(8):
            az=_math.radians(d*45.0); ca=_math.cos(az); sa=_math.sin(az)
            rx,ry,rz=(-sa,ca,0.0)
            bx,by,bz=(ca*ce,sa*ce,se)
            ux,uy,uz=(by*rz-bz*ry,bz*rx-bx*rz,bx*ry-by*rx)
            x0=y0=1e9; x1=y1=-1e9
            for fr in frlist:
                for x,y,z in skinned_all[fr]:
                    dx,dy,dz=(x-center[0],y-center[1],z-center[2])
                    px=dx*rx+dy*ry+dz*rz; py=dx*ux+dy*uy+dz*uz
                    if px<x0: x0=px
                    if px>x1: x1=px
                    if py<y0: y0=py
                    if py>y1: y1=py
            # The camera is centred on `center`, so each half (not the full
            # span) must fit: lunges are asymmetric (min -2.0 / max +0.7),
            # and fitting the width alone clips the long side.
            worst=max(worst,2.0*max(abs(x0),abs(x1),abs(y0),abs(y1)))
        return worst*1.12
    groups={}
    if any(True for _a, _f, _l, _d in plan if _a != "death"):
        lo,hi=union_of_group("stand")
        center=Vector((0.0,0.0,(lo.z+hi.z)*0.5))
        # XZ pinned at the entity origin: the feet never leave the tile when
        # the pose changes. Z is the union mid-height.
        groups["stand"]=(center,projected_ortho_group("stand",center))
    if any(True for _a, _f, _l, _d in plan if _a == "death"):
        lo,hi=union_of_group("death")
        center=Vector((0.0,0.0,(lo.z+hi.z)*0.5))
        groups["death"]=(center,projected_ortho_group("death",center))
    png=dds_to_png(tex_png(game,"unit",base),os.path.join(tmp,base+".png"),True)
    _need_tool=any(tool_of(_a)[1] is not None for _a, _f, _l, _d in plan)
    tpng=None
    if _need_tool:
        tpng=dds_to_png(os.path.join(game,"data","materials","units","peaaustools.dds"),os.path.join(tmp,"tools.png"),True)
    setup_scene(); mat=make_mat(png)
    tmat=make_mat(tpng) if tpng else None
    # T-BAKE-OPT: ONE camera for the whole unit bake (anchors + every view of
    # every frame); it is only retargeted via camera_set(), never recreated.
    cam=camera_create()
    ob=None; me=None; cur_tool=object()
    # Ground anchor: project the world origin once per group. Identical for
    # every action/dir in the group, so switching walk->attack->construct
    # cannot shift the feet (the old per-action ink-union cx/foot did).
    anchors={}
    for g,(center,ortho) in groups.items():
        camera_set(cam,center,0.0,ortho)
        ax,ay=ground_anchor_ay(cam,size)
        anchors[g]=(ax,ay)
    entry={"cell":size,"actions":{}}
    for action,frs,loop,dur in plan:
        g="death" if action=="death" else "stand"
        center,ortho=groups[g]; ax,ay=anchors[g]
        _t,_a=tool_of(action)
        _key=_t if _a else None
        if ob is None or _key != cur_tool:
            if ob is not None:
                bpy.data.objects.remove(ob,do_unlink=True)
            if _a:
                ob=build_mesh(m,mat,_a,tmat)
            else:
                ob=build_mesh(m,mat)
            me=ob.data
            cur_tool=_key
        nB=len(m["verts"])
        sheet=Image.new("RGBA",(size*8,size*len(frs)),(0,0,0,0))
        for ri,fr in enumerate(frs):
            verts=skinned_all[fr]
            if _t and (fr,_t) in skinned_tool:
                verts=verts+skinned_tool[(fr,_t)]
            me.vertices.foreach_set("co",[c for v in verts for c in v]); me.update()
            for d in range(8):
                # T-BAKE-OPT: retarget the reused camera; same d*45 azimuths,
                # elevation and ortho as before => identical pixel output.
                camera_set(cam,center,d*45.0,ortho)
                cell=os.path.join(tmp,"cell.png"); render_cell(cell,size)
                img=Image.open(cell).convert("RGBA")
                sheet.paste(img,(d*size,ri*size),img)
        sheet.save(os.path.join(dest,"%s_%s.png"%(key,action)))
        entry["actions"][action]={"frames":len(frs),"duration":round(dur,3),"loop":loop,
            "ortho":round(ortho,3),
            "center":[round(center.x,3),round(center.y,3),round(center.z,3)],
            "ax":ax,"ay":ay,
            "tool":_t}
    bpy.data.objects.remove(cam,do_unlink=True)
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

def bake_building(game,out,nat,bld,size,tmp,out_sid="",out_dir=None):
    # out_dir lets the caller place sheets in a nation-first tree. Other
    # staging bakers omit it and keep writing flat into `out`.
    dest = out_dir if out_dir is not None else out
    os.makedirs(dest,exist_ok=True)
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
    render_cell(os.path.join(dest,"%s_%s.png"%(nat,sid_name)),size)
    ob.hide_render = True  # stages/rubble render alone, not inside the finished mesh
    for s in range(1,5):
        p=os.path.join(game,"data","actors","buildings",folder,"%s%d.osm"%(base,s))
        if os.path.exists(p):
            ms=read_osm_first(p)
            mo=build_mesh(ms,mat)
            render_cell(os.path.join(dest,"%s_%s_s%d.png"%(nat,sid_name,s)),size)
            bpy.data.objects.remove(mo,do_unlink=True)
    p=os.path.join(game,"data","actors","buildings",folder,base+"_death2.osm")
    if os.path.exists(p):
        ms=read_osm_first(p)
        mo=build_mesh(ms,mat)
        render_cell(os.path.join(dest,"%s_%s_dead.png"%(nat,sid_name)),size)
        bpy.data.objects.remove(mo,do_unlink=True)
    ob.hide_render = False
    bpy.data.objects.remove(cam,do_unlink=True); bpy.data.objects.remove(ob,do_unlink=True)
    return True

def make_alias_entries(idx, aliases, only, out_units, flat=False):
    """T-BAKE-OPT: add index.json records for duplicate-sheet keys.

    Returns (made, saved_bytes, saved_sheets). All metadata is deep-copied
    from the canonical entry so `_anim_info(alias)` still sees identical
    cell/actions/ortho/ax/ay; `alias_of` points at the real sheet (key level
    and per action) for a runtime redirect. No duplicate PNG is written.
    """
    saved_bytes=0; saved_sheets=0; made=[]
    for alias,canon in aliases.items():
        if only and alias not in only: continue
        ce=idx.get(canon)
        if not ce:
            print("WARN alias %s: canonical %s not baked, keeping old behaviour" % (alias,canon),flush=True)
            continue
        ae=copy.deepcopy(ce)
        ae["alias_of"]=canon
        for act,ad in ae.get("actions",{}).items():
            ad["alias_of"]="%s_%s" % (canon,act)
            canon_dir = out_units if flat else sheet_out_dir(out_units, canon, "units")
            sp=os.path.join(canon_dir,"%s_%s.png" % (canon,act))
            if os.path.exists(sp):
                saved_bytes+=os.path.getsize(sp); saved_sheets+=1
        idx[alias]=ae
        made.append("%s -> %s" % (alias,canon))
    return made,saved_bytes,saved_sheets

def main():
    global _ENGINE, _SAMPLES
    a=parse_args()
    a.game=str(Path(a.game).expanduser().resolve())
    a.out=str(Path(a.out).expanduser().resolve())
    _ENGINE=a.engine; _SAMPLES=a.samples
    os.makedirs(a.out,exist_ok=True)
    # --layout nation (default) writes sheets to out/<nation|common>/<kind>;
    # --layout flat keeps the legacy anim root. index.json stays in
    # out/land_units/ either way. Existing PNGs are never moved or deleted.
    nation_layout = a.layout != "flat"
    out_units = a.out
    out_buildings = a.out
    # Scratch renders + converted textures live OUTSIDE res:// (system temp):
    # keeping 800+ MB of intermediate PNGs inside the project made Godot
    # import them all (thousands of .import entries, gigabytes of .godot).
    import tempfile
    tmp=os.path.join(tempfile.gettempdir(),"cossacks_bake",os.path.basename(a.out)); os.makedirs(tmp,exist_ok=True)
    # Index moved to land_units/. Prefer the new path; an explicit --out at a
    # different index root (e.g. naval_units/) still resolves via the legacy
    # candidate, and the new path is the default when neither exists yet.
    idx_path=os.path.join(a.out,"land_units","index.json")
    if not os.path.exists(idx_path) and os.path.exists(os.path.join(a.out,"index.json")):
        idx_path=os.path.join(a.out,"index.json")
    if os.path.dirname(idx_path):
        os.makedirs(os.path.dirname(idx_path),exist_ok=True)
    idx=json.load(open(idx_path)) if os.path.exists(idx_path) else {}
    if a.buildings:
        for nat in a.nations.split(","):
            for bld,sid_name in (("cen","cen"),("hou","hou"),("bar","bar"),("sta","sta"),("bla","bla"),("aca","aca"),("art","art"),("sto","sto"),("mil","mil"),("mar","mar"),("tow","tow"),("ba2","bar18"),("dip","dip")):
                key = "%s_%s" % (nat, sid_name)
                bdir = sheet_out_dir(out_buildings, key, "buildings") if nation_layout else out_buildings
                try:
                    if bake_building(a.game,out_buildings,nat,bld,320,tmp,sid_name,out_dir=bdir): print("bld",nat,sid_name,flush=True)
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
    # T-BAKE-OPT: aliases reuse the canonical's already-baked sheets. If only
    # an alias was requested, make sure its canonical is baked too so the
    # alias record has metadata (and source PNGs) to point at.
    aliases={} if a.no_alias else {k:v for k,v in ALIAS_OF.items() if k in table and v in table}
    bake_keys=[k for k in table if (not only or k in only) and k not in aliases]
    for alias,canon in aliases.items():
        if (not only or alias in only) and canon not in bake_keys:
            bake_keys.append(canon)
    for key in bake_keys:
        base=table[key]
        udir = sheet_out_dir(out_units, key, "units") if nation_layout else out_units
        try:
            e=bake_unit(a.game,out_units,key,base,a.size,a.samples,tmp,out_dir=udir)
            if e: idx[key]=e; json.dump(idx,open(idx_path,"w"),indent=1); print("unit",key,flush=True)
        except Exception as ex: print("FAIL unit",key,ex,flush=True)
    # Write alias entries AFTER the canonical entries (--no-alias skips this).
    made,saved_bytes,saved_sheets=make_alias_entries(idx,aliases,only,out_units,flat=not nation_layout)
    if made:
        json.dump(idx,open(idx_path,"w"),indent=1)
        print("T-BAKE-OPT alias summary: %s; %d sheets, %d bytes saved (duplicate PNGs not baked/written)"
              % (", ".join(made),saved_sheets,saved_bytes),flush=True)
    return 0

if __name__ == "__main__":
    sys.exit(main())
