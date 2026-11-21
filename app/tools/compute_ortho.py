#!/usr/bin/env python3
"""Ortho audit (no longer writes): bake_sprites.py owns per-action
ortho/center/ax/ay now. This script replicates the baker's torso-based
in-place logic in pure Python and REPORTS the expected global stand/death
orthos, so a bad bake can be spotted without Blender.

Usage: python tools/compute_ortho.py [--game PATH] [--idx PATH]
  --game defaults to $COSSACKS3_DIR (or C:\\Games\\Cossacks 3); --idx defaults to
  the project's app/assets/models/anim/index.json. Donor is private — never
  redistribute it.
"""
import argparse, json, os, struct
from pathlib import Path

APP = Path(__file__).resolve().parents[1]
DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
DEFAULT_IDX = APP / "assets" / "models" / "anim" / "index.json"

def parse_args():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--game", default=DEFAULT_GAME,
                    help="installed game folder (default: $COSSACKS3_DIR or "
                         "C:\\Games\\Cossacks 3)")
    ap.add_argument("--idx", default=str(DEFAULT_IDX),
                    help="anim/index.json to audit (default: project asset)")
    return ap.parse_args()

_args = parse_args()
GAME = str(Path(_args.game).expanduser())
IDX = str(Path(_args.idx).expanduser())

TABLE = {"peasant":"peaukr","pikeman":"pikeman","pikeman18":"pikeman18",
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
for nat, base in (("ukr","peaukr"),("rus","pearus"),("pol","peapol"),("aus","peaaus"),
                  ("eng","peaeng"),("spa","peaspa"),("tur","peatur"),("sco","peasco")):
    TABLE[nat+"_peasant"]=base

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
    return dict(fps=fps,verts=verts,weights=weights,anim=anim,k=k)

def read_aaf(path):
    acts={}
    if not os.path.exists(path): return acts
    for line in open(path,encoding="ascii",errors="replace").read().splitlines()[2:]:
        line=line.strip()
        if not line.startswith('"'): continue
        try:
            name,rest=line[1:].split('"',1)
            a,b,_=rest.strip().lstrip(",").split(",")
            acts[name]=(int(a),int(b))
        except Exception: pass
    return acts

def qmat(x,y,z,w):
    # Row-vector (transposed) convention, like bake_sprites.py: verified
    # tool-in-hand at idle rest pose.
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
    a,b=rng
    if b<=a: return [a]
    total=b-a+1
    if total<=n: return list(range(a,b+1))
    return [a+round((b-a)*i/(n-1)) for i in range(n)] if n>1 else [a]

idx=json.load(open(IDX,encoding="utf-8"))
for key,info in idx.items():
    base=TABLE.get(key,key)
    try:
        m=read_oss(os.path.join(GAME,"data","actors","units",base+".oss"))
        acts=read_aaf(os.path.join(GAME,"data","animations","aaf",base+".aaf"))
    except Exception as e:
        print("SKIP",key,e); continue
    root=0  # skeleton root, like the baker (never the max-weight bone)
    plan=[]
    for action,names,n in (("walk",("walk",),12),("idle",("idle","idle0"),6),
        ("attack",("attack1","attack0","attack2","attack"),12),
        ("workwood",("workwood",),10),("workfood",("workfood",),10),
        ("workstone",("workstone",),10),("construct",("construct",),8),
        ("death",("death","death0","death1"),8)):
        rng=next((acts[x] for x in names if x in acts),None)
        if rng: plan.append((action,sample(rng,n)))
    import math as _math
    home=None
    for action,frs in plan:
        if action=="idle":
            home=(m["anim"][root][frs[0]][0],m["anim"][root][frs[0]][1])
            break
    if home is None:
        home=(m["anim"][root][plan[0][1][0]][0],m["anim"][root][plan[0][1][0]][1])
    sk={}
    for action,frs in plan:
        ref=(m["anim"][root][frs[0]][0],m["anim"][root][frs[0]][1]) if action=="death" else home
        for fr in frs:
            if fr in sk: continue
            s=skin(m,fr)
            rx,ry=(m["anim"][root][fr][0]-ref[0],m["anim"][root][fr][1]-ref[1])
            sk[fr]=[(x-rx,y-ry,z) for x,y,z in s]
    def union(frlist):
        lo=[1e9]*3; hi=[-1e9]*3
        for fr in frlist:
            for x,y,z in sk[fr]:
                lo[0]=min(lo[0],x); lo[1]=min(lo[1],y); lo[2]=min(lo[2],z)
                hi[0]=max(hi[0],x); hi[1]=max(hi[1],y); hi[2]=max(hi[2],z)
        return lo,hi
    def por(frlist,cx,cy,cz):
        el=_math.radians(32.0); ce=_math.cos(el); se=_math.sin(el)
        w=1e-6
        for d in range(8):
            az=_math.radians(d*45.0); ca=_math.cos(az); sa=_math.sin(az)
            rx,ry,rz=(-sa,ca,0.0)
            bx,by,bz=(ca*ce,sa*ce,se)
            ux,uy,uz=(by*rz-bz*ry,bz*rx-bx*rz,bx*ry-by*rx)
            x0=y0=1e9; x1=y1=-1e9
            for fr in frlist:
                for x,y,z in sk[fr]:
                    dx,dy,dz=(x-cx,y-cy,z-cz)
                    px=dx*rx+dy*ry+dz*rz; py=dx*ux+dy*uy+dz*uz
                    x0=min(x0,px); x1=max(x1,px); y0=min(y0,py); y1=max(y1,py)
            w=max(w,2.0*max(abs(x0),abs(x1),abs(y0),abs(y1)))
        return w*1.12
    stand=[fr for a,frs in plan if a!="death" for fr in frs]
    dead=[fr for a,frs in plan if a=="death" for fr in frs]
    out=[]
    if stand:
        lo,hi=union(stand)
        out.append("stand %.2f" % por(stand,0.0,0.0,(lo[2]+hi[2])*0.5))
    if dead:
        lo,hi=union(dead)
        out.append("death %.2f" % por(dead,0.0,0.0,(lo[2]+hi[2])*0.5))
    baked=info.get("actions",{}).get("walk",{}).get("ortho",info.get("ortho"))
    print(key,"base",base,"root",root,"expect","/".join(out),"baked walk ortho",baked)
print("audit only: bake_sprites.py owns index.json now.")
