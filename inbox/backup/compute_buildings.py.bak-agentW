#!/usr/bin/env python3
"""True-scale data for baked nation buildings (no re-bake needed).
Each building sheet was baked with ortho = maxrange*1.12 around the finished
mesh (bake_sprites.bake_building); stages/rubble share that framing.
This script recovers ortho from the donor .osm bounds and measures the ink
fraction of every finished/stage/dead PNG, so world.gd can draw true donor
sizes (a 12 m town hall next to 2 m peasants) instead of the 4.5-8 m fudge.
Writes assets/models/anim/buildings.json: {key: {ortho, cell, ink:[x0,y0,x1,y1]}}."""
import json, os, struct
from PIL import Image

GAME = r"C:\Games\Cossacks 3"
ANIM = r"C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app\assets\models\anim"
NATIONS = ["ukr","rus","pol","aus","fra","eng","spa","swe","pru","ven","tur","alg","net","den","por","pie","sax","bav","hun","swi"]
BLDS = [("cen","cen"),("hou","hou"),("bar","bar"),("sta","sta"),("bla","bla"),("aca","aca"),("art","art"),("sto","sto"),("mil","mil"),("mar","mar"),("tow","tow"),("ba2","bar18"),("dip","dip")]

def read_osm_bounds(path):
    with open(path,"rb") as f:
        h=dict(zip(["magic","version","sw","sh","fs","ns","nv","nu","nt","ng","nf","os","ou","ot","of","og","oe"],struct.unpack("<17i",f.read(68))))
        f.seek(h["of"]); f.read(16)
        verts=[struct.unpack("<3fI",f.read(16))[:3] for _ in range(h["nv"])]
    xs=[v[0] for v in verts]; ys=[v[1] for v in verts]; zs=[v[2] for v in verts]
    return (max(xs)-min(xs),max(ys)-min(ys),max(zs)-min(zs))

def resolve(nat,bld):
    for folder,base in ((nat,nat+bld),("commoneur","eur"+bld),("commontur","tur"+bld)):
        p=os.path.join(GAME,"data","actors","buildings",folder,base+".osm")
        if os.path.exists(p): return p
    return None

out={}
for nat in NATIONS:
    for bld,sid in BLDS:
        p=resolve(nat,bld)
        if not p: continue
        dx,dy,dz=read_osm_bounds(p)
        ortho=round(max(dx,dy,dz)*1.12,3)
        for suffix in [""]+["s%d"%i for i in range(1,5)]+["dead"]:
            key="%s_%s%s"%(nat,sid,"" if suffix=="" else "_"+suffix)
            png=os.path.join(ANIM,key+".png")
            if not os.path.exists(png): continue
            im=Image.open(png).convert("RGBA")
            bb=im.getbbox()
            if not bb: continue
            # centroid fix: anchor by the FOOTPRINT centre, not the union
            # centre.  Tall asymmetric parts (tower on one side) skew the
            # union box, which would shift the whole building off its logical
            # tile.  The footprint sits in the lowest ink rows: alpha-weighted
            # mean x of the bottom 15% band.  rm = visual half-width in meters.
            x0,y0,x1,y1=bb
            band_top=int(y1-(y1-y0)*0.15)
            px=im.load()
            tot=0.0; sx=0.0
            for yy in range(band_top,y1):
                for xx in range(x0,x1):
                    a=px[xx,yy][3]
                    if a>8:
                        tot+=a; sx+=xx*a
            cx=(sx/tot/im.width) if tot>0 else ((x0+x1)*0.5/im.width)
            rm=((x1-x0)/im.width*ortho)*0.5
            out[key]={"ortho":ortho,"cell":im.width,"ink":[x0,y0,x1,y1],
                      "cx":round(cx,4),"rm":round(rm,3)}
json.dump(out,open(os.path.join(ANIM,"buildings.json"),"w"),indent=1)
print("buildings:",len(out))
# sanity: print a few true heights
for k in ["ukr_cen","ukr_hou","rus_tow","ukr_bar"]:
    if k in out:
        e=out[k]; ink=e["ink"]; frac=(ink[3]-ink[1])/e["cell"]
        print(k,"ortho",e["ortho"],"inkfrac",round(frac,2),"truem",round(frac*e["ortho"],2))
