#!/usr/bin/env python3
"""Compute per-unit bake ortho (max skinned extent * 1.12) exactly as bake_sprites.py does,
and store it in assets/models/anim/index.json as info['ortho'].
Pure Python (no Blender) - replicates read_oss/skin/sample from the baker."""
import json, os, struct

GAME = r"C:\Games\Cossacks 3"
IDX = r"C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app\assets\models\anim\index.json"

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
    total=b-a+1
    if total<=n: return list(range(a,b+1))
    return [a+round((b-a)*i/(n-1)) for i in range(n)] if n>1 else [a]

idx=json.load(open(IDX,encoding="utf-8"))
changed=0
for key,info in idx.items():
    base=TABLE.get(key,key)
    try:
        m=read_oss(os.path.join(GAME,"data","actors","units",base+".oss"))
        acts=read_aaf(os.path.join(GAME,"data","animations","aaf",base+".aaf"))
    except Exception as e:
        print("SKIP",key,e); continue
    plan=[]
    for names,n in ((("walk","walk0"),12),(("idle","idle0"),6),(("attack0","attack1","attack"),12),
                    (("workwood",),10),(("workfood",),10),(("workstone",),10),(("construct",),8),(("death",),8)):
        rng=next((acts[x] for x in names if x in acts),None)
        if rng: plan.append((sample(rng,n)))
    frs=sorted({f for grp in plan for f in grp})
    # same in-place fix as bake_sprites.py: root XZ removed per frame
    raw={fr: skin(m,fr) for fr in frs}
    for fr in frs:
        rx,ry=m["anim"][0][fr][0],m["anim"][0][fr][1]
        raw[fr]=[(x-rx,y-ry,z) for x,y,z in raw[fr]]
    lo=[1e9]*3; hi=[-1e9]*3
    for fr in frs:
        for x,y,z in raw[fr]:
            lo[0]=min(lo[0],x); lo[1]=min(lo[1],y); lo[2]=min(lo[2],z)
            hi[0]=max(hi[0],x); hi[1]=max(hi[1],y); hi[2]=max(hi[2],z)
    ortho=max(hi[0]-lo[0],hi[1]-lo[1],hi[2]-lo[2])*1.12
    info["ortho"]=round(ortho,3)
    changed+=1
    print(key,base,"ortho",round(ortho,3))
json.dump(idx,open(IDX,"w",encoding="utf-8"),indent=1)
print("wrote ortho for",changed,"units")
